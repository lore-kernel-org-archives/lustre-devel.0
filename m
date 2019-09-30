From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:27 -0400
Subject: [lustre-devel] [PATCH 068/151] lustre: lov: rework write intent on
 componect instantiation
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-69-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

It's revised to do in the I/O initialization.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 47a07d5e7933 ("LU-9971 lov: rework write intent on componect instantiation")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29086
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  4 ++++
 fs/lustre/llite/vvp_io.c      | 25 +++++------------------
 fs/lustre/lov/lov_io.c        | 46 +++++++++++++++++++++++++++++--------------
 3 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index f573c6f..45068ca 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1889,6 +1889,10 @@ struct cl_io {
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
 	unsigned int		ci_owned_nr;
+	/**
+	 * Range of write intent. Valid if ci_need_write_intent is set.
+	 */
+	struct lu_extent	ci_write_intent;
 };
 
 /** @} cl_io */
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 8518423..dc9ccef 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -347,32 +347,17 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	 * RPC.
 	 */
 	if (io->ci_need_write_intent) {
-		loff_t end = OBD_OBJECT_EOF;
-		loff_t start = 0;
-
 		io->ci_need_write_intent = 0;
 
 		LASSERT(io->ci_type == CIT_WRITE ||
 			cl_io_is_trunc(io) || cl_io_is_mkwrite(io));
 
-		if (io->ci_type == CIT_WRITE) {
-			if (!cl_io_is_append(io)) {
-				start = io->u.ci_rw.crw_pos;
-				end = start + io->u.ci_rw.crw_count;
-			}
-		} else if (cl_io_is_trunc(io)) {
-			end = io->u.ci_setattr.sa_attr.lvb_size;
-		} else { /* mkwrite */
-			pgoff_t index = io->u.ci_fault.ft_index;
-
-			start = cl_offset(io->ci_obj, index);
-			end = cl_offset(io->ci_obj, index + 1);
-		}
-
-		CDEBUG(D_VFSTRACE, DFID" type %d [%llx, %llx)\n",
+		CDEBUG(D_VFSTRACE, DFID" write layout, type %u " DEXT "\n",
 		       PFID(lu_object_fid(&obj->co_lu)), io->ci_type,
-		       start, end);
-		rc = ll_layout_write_intent(inode, start, end);
+		       PEXT(&io->ci_write_intent));
+
+		rc = ll_layout_write_intent(inode, io->ci_write_intent.e_start,
+					    io->ci_write_intent.e_end);
 		io->ci_result = rc;
 		if (!rc)
 			io->ci_need_restart = 1;
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 12ea614..22ca77e 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -302,6 +302,8 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 			     struct cl_io *io)
 {
+	struct lu_extent ext;
+	int index;
 	int result = 0;
 
 	io->ci_result = 0;
@@ -382,6 +384,35 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		LBUG();
 	}
 	result = lov_io_mirror_init(lio, obj, io);
+	if (result)
+		return result;
+
+	/* check if it needs to instantiate layout */
+	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
+	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0)))
+		return 0;
+
+	ext.e_start = lio->lis_pos;
+	ext.e_end = lio->lis_endpos;
+
+	/* for truncate, it only needs to instantiate the components
+	 * before the truncated size.
+	 */
+	if (cl_io_is_trunc(io)) {
+		ext.e_start = 0;
+		ext.e_end = io->u.ci_setattr.sa_attr.lvb_size;
+	}
+
+	index = 0;
+	lov_foreach_io_layout(index, lio, &ext) {
+		if (!lsm_entry_inited(obj->lo_lsm, index)) {
+			io->ci_need_write_intent = 1;
+			io->ci_write_intent = ext;
+			result = 1;
+			break;
+		}
+	}
+
 	return result;
 }
 
@@ -499,7 +530,6 @@ static int lov_io_iter_init(const struct lu_env *env,
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
-	struct cl_io *io = ios->cis_io;
 	struct lov_io_sub *sub;
 	struct lu_extent ext;
 	int rc = 0;
@@ -517,15 +547,6 @@ static int lov_io_iter_init(const struct lu_env *env,
 		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
 		       index, lsm->lsm_entries[index]->lsme_flags);
 		if (!lsm_entry_inited(lsm, index)) {
-			/* truncate IO will trigger write intent as well, and
-			 * it's handled in lov_io_setattr_iter_init()
-			 */
-			if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io)) {
-				io->ci_need_write_intent = 1;
-				rc = -ENODATA;
-				break;
-			}
-
 			/* Read from uninitialized components should return
 			 * zero filled pages.
 			 */
@@ -641,7 +662,6 @@ static int lov_io_setattr_iter_init(const struct lu_env *env,
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct cl_io *io = ios->cis_io;
-	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	int index;
 
 	if (cl_io_is_trunc(io) && lio->lis_pos > 0) {
@@ -650,10 +670,6 @@ static int lov_io_setattr_iter_init(const struct lu_env *env,
 		if (index < 0) {
 			io->ci_result = -ENODATA;
 			return io->ci_result;
-		} else if (!lsm_entry_inited(lsm, index)) {
-			io->ci_need_write_intent = 1;
-			io->ci_result = -ENODATA;
-			return io->ci_result;
 		}
 	}
 
-- 
1.8.3.1
