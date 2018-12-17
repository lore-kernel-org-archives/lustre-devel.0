From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:55 -0500
Subject: [lustre-devel] [PATCH 21/28] lustre: pfl: Read should not trigger
 layout write intent
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

In lov_io_rw_iter_init(), only write not read operation should
trigger layout write intent.

For append write, it has to make sure all uninited components
are instantiated.

Page mkwrite should also trigger write intent.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9008
Reviewed-on: https://review.whamcloud.com/26499
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/vvp_io.c | 20 ++++++++++++-----
 drivers/staging/lustre/lustre/lov/lov_io.c   | 33 +++++++++++++++++-----------
 2 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 5323fea..37f415f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -323,18 +323,26 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	 * RPC.
 	 */
 	if (io->ci_need_write_intent) {
+		loff_t end = OBD_OBJECT_EOF;
 		loff_t start = 0;
-		loff_t end = 0;
-
-		LASSERT(io->ci_type == CIT_WRITE || cl_io_is_trunc(io));
 
 		io->ci_need_write_intent = 0;
 
+		LASSERT(io->ci_type == CIT_WRITE ||
+			cl_io_is_trunc(io) || cl_io_is_mkwrite(io));
+
 		if (io->ci_type == CIT_WRITE) {
-			start = io->u.ci_rw.crw_pos;
-			end = io->u.ci_rw.crw_pos + io->u.ci_rw.crw_count;
-		} else {
+			if (!cl_io_is_append(io)) {
+				start = io->u.ci_rw.crw_pos;
+				end = start + io->u.ci_rw.crw_count;
+			}
+		} else if (cl_io_is_trunc(io)) {
 			end = io->u.ci_setattr.sa_attr.lvb_size;
+		} else { /* mkwrite */
+			pgoff_t index = io->u.ci_fault.ft_index;
+
+			start = cl_offset(io->ci_obj, index);
+			end = cl_offset(io->ci_obj, index + 1);
 		}
 
 		CDEBUG(D_VFSTRACE, DFID" type %d [%llx, %llx)\n",
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 8a1bb85..0d809b1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -378,6 +378,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 {
 	struct lov_io	*lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	struct cl_io *io = ios->cis_io;
 	struct lov_layout_entry *le;
 	struct lov_io_sub    *sub;
 	struct lu_extent ext;
@@ -394,15 +395,28 @@ static int lov_io_iter_init(const struct lu_env *env,
 		u64 start;
 		u64 end;
 
-		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
-		       index, lsm->lsm_entries[index]->lsme_flags);
-		if (!lsm_entry_inited(lsm, index))
-			break;
-
 		index++;
 		if (!lu_extent_is_overlapped(&ext, &le->lle_extent))
 			continue;
 
+		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
+		       index - 1, lsm->lsm_entries[index - 1]->lsme_flags);
+		if (!lsm_entry_inited(lsm, index - 1)) {
+			/* truncate IO will trigger write intent as well, and
+			 * it's handled in lov_io_setattr_iter_init()
+			 */
+			if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io)) {
+			    io->ci_need_write_intent = 1;
+				rc = -ENODATA;
+				break;
+			}
+
+			/* Read from uninitialized components should return
+			 * zero filled pages.
+			 */
+			continue;
+		}
+
 		for (stripe = 0; stripe < r0->lo_nr; stripe++) {
 			if (!lov_stripe_intersects(lsm, index - 1, stripe,
 						   &ext, &start, &end))
@@ -498,13 +512,6 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	       start, lio->lis_pos, lio->lis_endpos,
 	       lio->lis_io_endpos);
 
-	index = lov_lsm_entry(lsm, lio->lis_endpos - 1);
-	if (index > 0 && !lsm_entry_inited(lsm, index)) {
-		io->ci_need_write_intent = 1;
-		io->ci_result = -ENODATA;
-		return io->ci_result;
-	}
-
 	/*
 	 * XXX The following call should be optimized: we know, that
 	 * [lio->lis_pos, lio->lis_endpos) intersects with exactly one stripe.
@@ -520,7 +527,7 @@ static int lov_io_setattr_iter_init(const struct lu_env *env,
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	int index;
 
-	if (cl_io_is_trunc(io) && lio->lis_pos) {
+	if (cl_io_is_trunc(io) && lio->lis_pos > 0) {
 		index = lov_lsm_entry(lsm, lio->lis_pos - 1);
 		if (index > 0 && !lsm_entry_inited(lsm, index)) {
 			io->ci_need_write_intent = 1;
-- 
1.8.3.1
