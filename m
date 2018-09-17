From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:21 -0400
Subject: [lustre-devel] [PATCH 8/8] lustre: obd: add md_stats to MDC and LMV
 devices
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Enable md_stats for MDC and LMV devices. These stats track usage of
the md_ops methods (from the OBD layer, not to be confused with
md_device methods) and are exported through the files
/sys/fs/lustre/{lmv,mdc}/*/md_stats.

Rename m_sync to m_fsync making the counter name (fsync) more
intuitive. The operations counted are close, create, enqueue,
getattr, intent_lock, link, rename, setattr, fsync, readpage, unlink,
setxattr, getxattr, intent_getattr_async, and revalidate_lock.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-2484
Reviewed-on: http://review.whamcloud.com/4827
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       | 4 ++--
 drivers/staging/lustre/lustre/include/obd_class.h | 6 +++---
 drivers/staging/lustre/lustre/llite/file.c        | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       | 9 +++++----
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c     | 6 ++++++
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c     | 7 +++++++
 drivers/staging/lustre/lustre/mdc/mdc_request.c   | 8 +++++---
 7 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6e78c50..11e7ae8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -942,8 +942,8 @@ struct md_ops {
 		      struct ptlrpc_request **);
 	int (*setattr)(struct obd_export *, struct md_op_data *, void *,
 		       size_t, struct ptlrpc_request **);
-	int (*sync)(struct obd_export *, const struct lu_fid *,
-		    struct ptlrpc_request **);
+	int (*fsync)(struct obd_export *, const struct lu_fid *,
+		     struct ptlrpc_request **);
 	int (*read_page)(struct obd_export *, struct md_op_data *,
 			 struct md_callback *cb_op, __u64 hash_offset,
 			 struct page **ppage);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 2514b39..824d378 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1350,8 +1350,8 @@ static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	return MDP(exp->exp_obd, setattr)(exp, op_data, ea, ealen, request);
 }
 
-static inline int md_sync(struct obd_export *exp, const struct lu_fid *fid,
-			  struct ptlrpc_request **request)
+static inline int md_fsync(struct obd_export *exp, const struct lu_fid *fid,
+			   struct ptlrpc_request **request)
 {
 	int rc;
 
@@ -1362,7 +1362,7 @@ static inline int md_sync(struct obd_export *exp, const struct lu_fid *fid,
 	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
 			     LPROC_MD_FSYNC);
 
-	return MDP(exp->exp_obd, sync)(exp, fid, request);
+	return MDP(exp->exp_obd, fsync)(exp, fid, request);
 }
 
 static inline int md_read_page(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 94760eb..092fa99 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2656,7 +2656,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		}
 	}
 
-	err = md_sync(ll_i2sbi(inode)->ll_md_exp, ll_inode2fid(inode), &req);
+	err = md_fsync(ll_i2sbi(inode)->ll_md_exp, ll_inode2fid(inode), &req);
 	if (!rc)
 		rc = err;
 	if (!err)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index cf2a4c6..71bd843 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1989,8 +1989,8 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	return md_setattr(tgt->ltd_exp, op_data, ea, ealen, request);
 }
 
-static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
-		    struct ptlrpc_request **request)
+static int lmv_fsync(struct obd_export *exp, const struct lu_fid *fid,
+		     struct ptlrpc_request **request)
 {
 	struct obd_device	 *obd = exp->exp_obd;
 	struct lmv_obd	    *lmv = &obd->u.lmv;
@@ -2000,7 +2000,7 @@ static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	return md_sync(tgt->ltd_exp, fid, request);
+	return md_fsync(tgt->ltd_exp, fid, request);
 }
 
 /**
@@ -2502,6 +2502,7 @@ static int lmv_precleanup(struct obd_device *obd)
 {
 	fld_client_debugfs_fini(&obd->u.lmv.lmv_fld);
 	lprocfs_obd_cleanup(obd);
+	ldebugfs_free_md_stats(obd);
 	return 0;
 }
 
@@ -3079,7 +3080,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.rename			= lmv_rename,
 	.setattr		= lmv_setattr,
 	.setxattr		= lmv_setxattr,
-	.sync			= lmv_sync,
+	.fsync			= lmv_fsync,
 	.read_page		= lmv_read_page,
 	.unlink			= lmv_unlink,
 	.init_ea_size		= lmv_init_ea_size,
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index efc12ad..4e30026 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -168,6 +168,12 @@ int lmv_tunables_init(struct obd_device *obd)
 	if (rc)
 		return rc;
 
+	rc = ldebugfs_alloc_md_stats(obd, 0);
+	if (rc) {
+		lprocfs_obd_cleanup(obd);
+		return rc;
+	}
+
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lmv_debugfs_target_fops);
 
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index a205c61..ffc1085 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -210,8 +210,15 @@ int mdc_tunables_init(struct obd_device *obd)
 	if (rc)
 		return rc;
 
+	rc = ldebugfs_alloc_md_stats(obd, 0);
+	if (rc) {
+		lprocfs_obd_cleanup(obd);
+		return rc;
+	}
+
 	rc = sptlrpc_lprocfs_cliobd_attach(obd);
 	if (rc) {
+		ldebugfs_free_md_stats(obd);
 		lprocfs_obd_cleanup(obd);
 		return rc;
 	}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 2108877..8f8e3d2 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2487,8 +2487,8 @@ static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-static int mdc_sync(struct obd_export *exp, const struct lu_fid *fid,
-		    struct ptlrpc_request **request)
+static int mdc_fsync(struct obd_export *exp, const struct lu_fid *fid,
+		     struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
 	int		    rc;
@@ -2677,6 +2677,7 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	return 0;
 
 err_llog_cleanup:
+	ldebugfs_free_md_stats(obd);
 	ptlrpc_lprocfs_unregister_obd(obd);
 err_osc_cleanup:
 	client_obd_cleanup(obd);
@@ -2716,6 +2717,7 @@ static int mdc_precleanup(struct obd_device *obd)
 	obd_cleanup_client_import(obd);
 	ptlrpc_lprocfs_unregister_obd(obd);
 	lprocfs_obd_cleanup(obd);
+	ldebugfs_free_md_stats(obd);
 	mdc_llog_finish(obd);
 	return 0;
 }
@@ -2772,7 +2774,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.setattr		= mdc_setattr,
 	.setxattr		= mdc_setxattr,
 	.getxattr		= mdc_getxattr,
-	.sync			= mdc_sync,
+	.fsync			= mdc_fsync,
 	.read_page		= mdc_read_page,
 	.unlink			= mdc_unlink,
 	.cancel_unused		= mdc_cancel_unused,
-- 
1.8.3.1
