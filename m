From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:12 -0500
Subject: [lustre-devel] [PATCH 504/622] lustre: flr: avoid reading unhealthy
 mirror
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-505-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

* Fix an error in lov_io_mirror_init() which would wait unnecessarily
  if we're retrying the last mirror of the file.

* In osc_io_iter_init() we'd check its OSC import status so that the
  read path can quickly switch another mirror.
  sanity-flr test_33b is added to test this case.

* And with all mirrors have been tried, we'd turn off the quick switch
  so that when all mirrors contain bad OSTs, the read will still try
  its best to get partial data from a component before trying another
  mirror.
  sanity-flr test_33c is added to test this case.

Fixes: 4b102da53ad ("lustre: ptlrpc: idle connections can disconnect")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12328
Lustre-commit: 39da3c06275e ("LU-12328 flr: avoid reading unhealthy mirror")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34952
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  8 +++++++-
 fs/lustre/lov/lov_io.c        | 25 ++++++++++++++++---------
 fs/lustre/osc/osc_io.c        | 16 +++++++++++++++-
 3 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 75ece62..c3376a4 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1906,7 +1906,13 @@ struct cl_io {
 	/**
 	 * Set if IO is triggered by async workqueue readahead.
 	 */
-				ci_async_readahead:1;
+				ci_async_readahead:1,
+	/**
+	 * Set if we've tried all mirrors for this read IO, if it's not set,
+	 * the read IO will check to-be-read OSCs' status, and make fast-switch
+	 * another mirror if some of the OSTs are not healthy.
+	 */
+				ci_tried_all_mirrors:1;
 	/**
 	 * How many times the read has retried before this one.
 	 * Set by the top level and consumed by the LOV.
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 56e4a982..971f9ba 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -140,6 +140,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 	sub_io->ci_lock_no_expand = io->ci_lock_no_expand;
 	sub_io->ci_ndelay = io->ci_ndelay;
 	sub_io->ci_layout_version = io->ci_layout_version;
+	sub_io->ci_tried_all_mirrors = io->ci_tried_all_mirrors;
 
 	rc = cl_io_sub_init(sub->sub_env, sub_io, io->ci_type, sub_obj);
 	if (rc < 0)
@@ -395,13 +396,13 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 				found = true;
 				break;
 			}
-		}
-
+		} /* each component of the mirror */
 		if (found) {
 			index = (index + i) % comp->lo_mirror_count;
 			break;
 		}
-	}
+	} /* each mirror */
+
 	if (i == comp->lo_mirror_count) {
 		CERROR(DFID ": failed to find a component covering I/O region at %llu\n",
 		       PFID(lu_object_fid(lov2lu(obj))), lio->lis_pos);
@@ -423,16 +424,21 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 	 * of this client has been partitioned. We should relinquish CPU for
 	 * a while before trying again.
 	 */
-	++io->ci_ndelay_tried;
-	if (io->ci_ndelay && io->ci_ndelay_tried >= comp->lo_mirror_count) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC)); /* 10ms */
+	if (io->ci_ndelay && io->ci_ndelay_tried > 0 &&
+	    (io->ci_ndelay_tried % comp->lo_mirror_count == 0)) {
+		schedule_timeout_interruptible(HZ / 100 + 1); /* 10ms */
 		if (signal_pending(current))
 			return -EINTR;
 
-		/* reset retry counter */
-		io->ci_ndelay_tried = 1;
+		/**
+		 * we'd set ci_tried_all_mirrors to turn off fast mirror
+		 * switching for read after we've tried all mirrors several
+		 * rounds.
+		 */
+		io->ci_tried_all_mirrors = io->ci_ndelay_tried %
+					   (comp->lo_mirror_count * 4) == 0;
 	}
+	++io->ci_ndelay_tried;
 
 	CDEBUG(D_VFSTRACE, "use %sdelayed RPC state for this IO\n",
 	       io->ci_ndelay ? "non-" : "");
@@ -668,6 +674,7 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 	case CIT_READ:
 	case CIT_WRITE: {
 		io->u.ci_wr.wr_sync = cl_io_is_sync_write(parent);
+		io->ci_tried_all_mirrors = parent->ci_tried_all_mirrors;
 		if (cl_io_is_append(parent)) {
 			io->u.ci_wr.wr_append = 1;
 		} else {
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index f340266..1ff2df2 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -368,6 +368,13 @@ int osc_io_commit_async(const struct lu_env *env,
 }
 EXPORT_SYMBOL(osc_io_commit_async);
 
+static bool osc_import_not_healthy(struct obd_import *imp)
+{
+	return imp->imp_invalid || imp->imp_deactive ||
+	       !(imp->imp_state == LUSTRE_IMP_FULL ||
+		 imp->imp_state == LUSTRE_IMP_IDLE);
+}
+
 int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct osc_object *osc = cl2osc(ios->cis_obj);
@@ -376,7 +383,14 @@ int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 	int rc = -EIO;
 
 	spin_lock(&imp->imp_lock);
-	if (likely(!imp->imp_invalid)) {
+	/**
+	 * check whether this OSC device is available for non-delay read,
+	 * fast switching mirror if we haven't tried all mirrors.
+	 */
+	if (ios->cis_io->ci_type == CIT_READ && ios->cis_io->ci_ndelay &&
+	    !ios->cis_io->ci_tried_all_mirrors && osc_import_not_healthy(imp)) {
+		rc = -EWOULDBLOCK;
+	} else if (likely(!imp->imp_invalid)) {
 		atomic_inc(&osc->oo_nr_ios);
 		oio->oi_is_active = 1;
 		rc = 0;
-- 
1.8.3.1
