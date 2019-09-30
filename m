From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:05 -0400
Subject: [lustre-devel] [PATCH 046/151] lustre: mdc: add IO methods to the
 MDC
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-47-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Add CL IO methods specific for MDC. Update and export
related OSC functions to be used from MDC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 59bd024b7117 ("LU-3285 mdc: add IO methods to the MDC")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28015
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  39 +++++++++--
 fs/lustre/mdc/mdc_dev.c        | 155 ++++++++++++++++++++++++++++++++++++++---
 fs/lustre/osc/osc_cache.c      |   4 ++
 fs/lustre/osc/osc_dev.c        |   2 +
 fs/lustre/osc/osc_internal.h   |  13 +++-
 fs/lustre/osc/osc_io.c         |  76 +++++++++++---------
 fs/lustre/osc/osc_page.c       |   1 +
 fs/lustre/osc/osc_request.c    |  25 ++++---
 8 files changed, 253 insertions(+), 62 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 5723261..290f3c9 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -447,18 +447,19 @@ struct osc_page {
 
 #define OSC_FLAGS (ASYNC_URGENT | ASYNC_READY)
 
+/* osc_page.c */
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, pgoff_t ind);
 
 void osc_index2policy(union ldlm_policy_data *policy,
 		      const struct cl_object *obj,
 		      pgoff_t start, pgoff_t end);
-int osc_lvb_print(const struct lu_env *env, void *cookie,
-		  lu_printer_t p, const struct ost_lvb *lvb);
-
 void osc_lru_add_batch(struct client_obd *cli, struct list_head *list);
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		     enum cl_req_type crt, int brw_flags);
+int lru_queue_work(const struct lu_env *env, void *data);
+
+/* osc_cache.c */
 int osc_set_async_flags(struct osc_object *obj, struct osc_page *opg,
 			u32 async_flags);
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
@@ -480,7 +481,6 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 			      pgoff_t start, pgoff_t end, int hp, int discard);
 int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
 			 pgoff_t start, pgoff_t end);
-
 int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 		    struct osc_object *osc, int async);
 
@@ -539,6 +539,37 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 int osc_ldlm_resource_invalidate(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 				 struct hlist_node *hnode, void *arg);
 
+int osc_punch_send(struct obd_export *exp, struct obdo *oa,
+		   obd_enqueue_update_f upcall, void *cookie);
+
+/* osc_io.c */
+int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
+		  enum cl_req_type crt, struct cl_2queue *queue);
+int osc_io_commit_async(const struct lu_env *env,
+			const struct cl_io_slice *ios,
+			struct cl_page_list *qin, int from, int to,
+			cl_commit_cbt cb);
+int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios);
+void osc_io_iter_fini(const struct lu_env *env,
+		      const struct cl_io_slice *ios);
+int osc_io_write_iter_init(const struct lu_env *env,
+			   const struct cl_io_slice *ios);
+void osc_io_write_iter_fini(const struct lu_env *env,
+			    const struct cl_io_slice *ios);
+int osc_io_fault_start(const struct lu_env *env, const struct cl_io_slice *ios);
+void osc_io_setattr_end(const struct lu_env *env,
+			const struct cl_io_slice *slice);
+int osc_io_read_start(const struct lu_env *env,
+		      const struct cl_io_slice *slice);
+int osc_io_write_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice);
+void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice);
+
+int osc_io_fsync_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice);
+void osc_io_fsync_end(const struct lu_env *env,
+		      const struct cl_io_slice *slice);
+
 /****************************************************************************
  *
  * Accessors and type conversions.
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index aa86d93..77e152e 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -38,23 +38,156 @@
 
 #include "mdc_internal.h"
 
-int mdc_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, pgoff_t index)
-{
-	return -ENOTSUPP;
-}
-
 int mdc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
 		  const struct cl_io *unused)
 {
-	return -ENOTSUPP;
+	return 0;
+}
+
+/**
+ * IO operations.
+ *
+ * An implementation of cl_io_operations specific methods for MDC layer.
+ *
+ */
+static int mdc_async_upcall(void *a, int rc)
+{
+	struct osc_async_cbargs *args = a;
+
+	args->opc_rc = rc;
+	complete(&args->opc_sync);
+	return 0;
+}
+
+static int mdc_io_setattr_start(const struct lu_env *env,
+				const struct cl_io_slice *slice)
+{
+	struct cl_io *io = slice->cis_io;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct cl_object *obj = slice->cis_obj;
+	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+	struct obdo *oa = &oio->oi_oa;
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	u64 size = io->u.ci_setattr.sa_attr.lvb_size;
+	unsigned int ia_valid = io->u.ci_setattr.sa_avalid;
+	enum op_xvalid ia_xvalid = io->u.ci_setattr.sa_xvalid;
+	int rc;
+
+	/* silently ignore non-truncate setattr for Data-on-MDT object */
+	if (cl_io_is_trunc(io)) {
+		/* truncate cache dirty pages first */
+		rc = osc_cache_truncate_start(env, cl2osc(obj), size,
+					      &oio->oi_trunc);
+		if (rc < 0)
+			return rc;
+	}
+
+	if (oio->oi_lockless == 0) {
+		cl_object_attr_lock(obj);
+		rc = cl_object_attr_get(env, obj, attr);
+		if (rc == 0) {
+			struct ost_lvb *lvb = &io->u.ci_setattr.sa_attr;
+			unsigned int cl_valid = 0;
+
+			if (ia_valid & ATTR_SIZE) {
+				attr->cat_size = attr->cat_kms = size;
+				cl_valid = (CAT_SIZE | CAT_KMS);
+			}
+			if (ia_valid & ATTR_MTIME_SET) {
+				attr->cat_mtime = lvb->lvb_mtime;
+				cl_valid |= CAT_MTIME;
+			}
+			if (ia_valid & ATTR_ATIME_SET) {
+				attr->cat_atime = lvb->lvb_atime;
+				cl_valid |= CAT_ATIME;
+			}
+			if (ia_xvalid & OP_XVALID_CTIME_SET) {
+				attr->cat_ctime = lvb->lvb_ctime;
+				cl_valid |= CAT_CTIME;
+			}
+			rc = cl_object_attr_update(env, obj, attr, cl_valid);
+		}
+		cl_object_attr_unlock(obj);
+		if (rc < 0)
+			return rc;
+	}
+
+	if (!(ia_valid & ATTR_SIZE))
+		return 0;
+
+	memset(oa, 0, sizeof(*oa));
+	oa->o_oi = loi->loi_oi;
+	oa->o_mtime = attr->cat_mtime;
+	oa->o_atime = attr->cat_atime;
+	oa->o_ctime = attr->cat_ctime;
+
+	oa->o_size = size;
+	oa->o_blocks = OBD_OBJECT_EOF;
+	oa->o_valid = OBD_MD_FLID | OBD_MD_FLGROUP | OBD_MD_FLATIME |
+		      OBD_MD_FLCTIME | OBD_MD_FLMTIME | OBD_MD_FLSIZE |
+		      OBD_MD_FLBLOCKS;
+	if (oio->oi_lockless) {
+		oa->o_flags = OBD_FL_SRVLOCK;
+		oa->o_valid |= OBD_MD_FLFLAGS;
+	}
+
+	init_completion(&cbargs->opc_sync);
+
+	rc = osc_punch_send(osc_export(cl2osc(obj)), oa,
+			    mdc_async_upcall, cbargs);
+	cbargs->opc_rpc_sent = rc == 0;
+	return rc;
 }
 
-int mdc_io_init(const struct lu_env *env,
-		struct cl_object *obj, struct cl_io *io)
+static struct cl_io_operations mdc_io_ops = {
+	.op = {
+		[CIT_READ] = {
+			.cio_iter_init	= osc_io_iter_init,
+			.cio_iter_fini	= osc_io_iter_fini,
+			.cio_start	= osc_io_read_start,
+		},
+		[CIT_WRITE] = {
+			.cio_iter_init	= osc_io_write_iter_init,
+			.cio_iter_fini	= osc_io_write_iter_fini,
+			.cio_start	= osc_io_write_start,
+			.cio_end	= osc_io_end,
+		},
+		[CIT_SETATTR] = {
+			.cio_iter_init	= osc_io_iter_init,
+			.cio_iter_fini	= osc_io_iter_fini,
+			.cio_start	= mdc_io_setattr_start,
+			.cio_end	= osc_io_setattr_end,
+		},
+		/* no support for data version so far */
+		[CIT_DATA_VERSION] = {
+			.cio_start	= NULL,
+			.cio_end	= NULL,
+		},
+		[CIT_FAULT] = {
+			.cio_iter_init	= osc_io_iter_init,
+			.cio_iter_fini	= osc_io_iter_fini,
+			.cio_start	= osc_io_fault_start,
+			.cio_end	= osc_io_end,
+		},
+		[CIT_FSYNC] = {
+			.cio_start	= osc_io_fsync_start,
+			.cio_end	= osc_io_fsync_end,
+		},
+	},
+	.cio_submit		= osc_io_submit,
+	.cio_commit_async	= osc_io_commit_async,
+};
+
+int mdc_io_init(const struct lu_env *env, struct cl_object *obj,
+		struct cl_io *io)
 {
-	return -ENOTSUPP;
+	struct osc_io *oio = osc_env_io(env);
+
+	CL_IO_SLICE_CLEAN(oio, oi_cl);
+	cl_io_slice_add(io, &oio->oi_cl, obj, &mdc_io_ops);
+	return 0;
 }
 
 /**
@@ -78,7 +211,7 @@ static void mdc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 }
 
 static const struct cl_object_operations mdc_ops = {
-	.coo_page_init		= mdc_page_init,
+	.coo_page_init		= osc_page_init,
 	.coo_lock_init		= mdc_lock_init,
 	.coo_io_init		= mdc_io_init,
 	.coo_attr_get		= osc_attr_get,
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 65fdbc1..cda8791 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2309,6 +2309,7 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 
 	return 0;
 }
+EXPORT_SYMBOL(osc_prep_async_page);
 
 int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		       struct osc_page *ops)
@@ -2798,6 +2799,7 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
 
 	return result;
 }
+EXPORT_SYMBOL(osc_cache_truncate_start);
 
 /**
  * Called after osc_io_setattr_end to add oio->oi_trunc back to cache.
@@ -2883,6 +2885,7 @@ int osc_cache_wait_range(const struct lu_env *env, struct osc_object *obj,
 	OSC_IO_DEBUG(obj, "sync file range.\n");
 	return result;
 }
+EXPORT_SYMBOL(osc_cache_wait_range);
 
 /**
  * Called to write out a range of osc object.
@@ -3004,6 +3007,7 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 	OSC_IO_DEBUG(obj, "pageout [%lu, %lu], %d.\n", start, end, result);
 	return result;
 }
+EXPORT_SYMBOL(osc_cache_writeback_range);
 
 /**
  * Returns a list of pages by a given [start, end] of @obj.
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index 7178e6b..fb1d31c 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -126,6 +126,7 @@ struct lu_context_key osc_key = {
 	.lct_init		= osc_key_init,
 	.lct_fini		= osc_key_fini
 };
+EXPORT_SYMBOL(osc_key);
 
 static void *osc_session_init(const struct lu_context *ctx,
 			      struct lu_context_key *key)
@@ -151,6 +152,7 @@ struct lu_context_key osc_session_key = {
 	.lct_init		= osc_session_init,
 	.lct_fini		= osc_session_fini
 };
+EXPORT_SYMBOL(osc_session_key);
 
 /* type constructor/destructor: osc_type_{init,fini,start,stop}(). */
 LU_TYPE_INIT_FINI(osc, &osc_key, &osc_session_key);
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 873556a..f9ab069 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -65,9 +65,6 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		      obd_enqueue_update_f upcall, void *cookie,
 		      struct ptlrpc_request_set *rqset);
-int osc_punch_base(struct obd_export *exp, struct obdo *oa,
-		   obd_enqueue_update_f upcall, void *cookie,
-		   struct ptlrpc_request_set *rqset);
 int osc_sync_base(struct osc_object *exp, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset);
@@ -169,4 +166,14 @@ unsigned long osc_cache_shrink_count(struct shrinker *sk,
 unsigned long osc_cache_shrink_scan(struct shrinker *sk,
 				    struct shrink_control *sc);
 
+static inline void osc_set_io_portal(struct ptlrpc_request *req)
+{
+	struct obd_import *imp = req->rq_import;
+
+	/* Distinguish OSC from MDC here to use OST or MDS portal */
+	if (OCD_HAS_FLAG(&imp->imp_connect_data, IBITS))
+		req->rq_request_portal = MDS_IO_PORTAL;
+	else
+		req->rq_request_portal = OST_IO_PORTAL;
+}
 #endif /* OSC_INTERNAL_H */
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index f7169e9..176ebe8 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -104,9 +104,8 @@ static int osc_io_read_ahead(const struct lu_env *env,
  * or, if page is already submitted, changes osc flags through
  * osc_set_async_flags().
  */
-static int osc_io_submit(const struct lu_env *env,
-			 const struct cl_io_slice *ios,
-			 enum cl_req_type crt, struct cl_2queue *queue)
+int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
+		  enum cl_req_type crt, struct cl_2queue *queue)
 {
 	struct cl_page *page;
 	struct cl_page *tmp;
@@ -212,6 +211,7 @@ static int osc_io_submit(const struct lu_env *env,
 	CDEBUG(D_INFO, "%d/%d %d\n", qin->pl_nr, qout->pl_nr, result);
 	return qout->pl_nr > 0 ? 0 : result;
 }
+EXPORT_SYMBOL(osc_io_submit);
 
 /**
  * This is called when a page is accessed within file in a way that creates
@@ -258,10 +258,10 @@ static void osc_page_touch_at(const struct lu_env *env,
 	cl_object_attr_unlock(obj);
 }
 
-static int osc_io_commit_async(const struct lu_env *env,
-			       const struct cl_io_slice *ios,
-			       struct cl_page_list *qin, int from, int to,
-			       cl_commit_cbt cb)
+int osc_io_commit_async(const struct lu_env *env,
+			const struct cl_io_slice *ios,
+			struct cl_page_list *qin, int from, int to,
+			cl_commit_cbt cb)
 {
 	struct cl_io *io = ios->cis_io;
 	struct osc_io *oio = cl2osc_io(env, ios);
@@ -331,9 +331,9 @@ static int osc_io_commit_async(const struct lu_env *env,
 	CDEBUG(D_INFO, "%d %d\n", qin->pl_nr, result);
 	return result;
 }
+EXPORT_SYMBOL(osc_io_commit_async);
 
-static int osc_io_iter_init(const struct lu_env *env,
-			    const struct cl_io_slice *ios)
+int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct osc_object *osc = cl2osc(ios->cis_obj);
 	struct obd_import *imp = osc_cli(osc)->cl_import;
@@ -351,9 +351,10 @@ static int osc_io_iter_init(const struct lu_env *env,
 
 	return rc;
 }
+EXPORT_SYMBOL(osc_io_iter_init);
 
-static int osc_io_write_iter_init(const struct lu_env *env,
-				  const struct cl_io_slice *ios)
+int osc_io_write_iter_init(const struct lu_env *env,
+			   const struct cl_io_slice *ios)
 {
 	struct cl_io *io = ios->cis_io;
 	struct osc_io *oio = osc_env_io(env);
@@ -371,9 +372,10 @@ static int osc_io_write_iter_init(const struct lu_env *env,
 
 	return osc_io_iter_init(env, ios);
 }
+EXPORT_SYMBOL(osc_io_write_iter_init);
 
-static void osc_io_iter_fini(const struct lu_env *env,
-			     const struct cl_io_slice *ios)
+void osc_io_iter_fini(const struct lu_env *env,
+		      const struct cl_io_slice *ios)
 {
 	struct osc_io *oio = osc_env_io(env);
 
@@ -386,9 +388,10 @@ static void osc_io_iter_fini(const struct lu_env *env,
 			wake_up_all(&osc->oo_io_waitq);
 	}
 }
+EXPORT_SYMBOL(osc_io_iter_fini);
 
-static void osc_io_write_iter_fini(const struct lu_env *env,
-				   const struct cl_io_slice *ios)
+void osc_io_write_iter_fini(const struct lu_env *env,
+			    const struct cl_io_slice *ios)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_object *osc = cl2osc(ios->cis_obj);
@@ -401,9 +404,9 @@ static void osc_io_write_iter_fini(const struct lu_env *env,
 
 	osc_io_iter_fini(env, ios);
 }
+EXPORT_SYMBOL(osc_io_write_iter_fini);
 
-static int osc_io_fault_start(const struct lu_env *env,
-			      const struct cl_io_slice *ios)
+int osc_io_fault_start(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct cl_io *io;
 	struct cl_fault_io *fio;
@@ -422,6 +425,7 @@ static int osc_io_fault_start(const struct lu_env *env,
 				  fio->ft_index, fio->ft_nob);
 	return 0;
 }
+EXPORT_SYMBOL(osc_io_fault_start);
 
 static int osc_async_upcall(void *a, int rc)
 {
@@ -563,9 +567,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 		init_completion(&cbargs->opc_sync);
 
 		if (ia_avalid & ATTR_SIZE)
-			result = osc_punch_base(osc_export(cl2osc(obj)),
-						oa, osc_async_upcall,
-						cbargs, PTLRPCD_SET);
+			result = osc_punch_send(osc_export(cl2osc(obj)),
+						oa, osc_async_upcall, cbargs);
 		else
 			result = osc_setattr_async(osc_export(cl2osc(obj)),
 						   oa, osc_async_upcall,
@@ -575,8 +578,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	return result;
 }
 
-static void osc_io_setattr_end(const struct lu_env *env,
-			       const struct cl_io_slice *slice)
+void osc_io_setattr_end(const struct lu_env *env,
+			const struct cl_io_slice *slice)
 {
 	struct cl_io *io = slice->cis_io;
 	struct osc_io *oio = cl2osc_io(env, slice);
@@ -608,6 +611,7 @@ static void osc_io_setattr_end(const struct lu_env *env,
 		oio->oi_trunc = NULL;
 	}
 }
+EXPORT_SYMBOL(osc_io_setattr_end);
 
 struct osc_data_version_args {
 	struct osc_io *dva_oio;
@@ -710,10 +714,10 @@ static void osc_io_data_version_end(const struct lu_env *env,
 	}
 }
 
-static int osc_io_read_start(const struct lu_env *env,
-			     const struct cl_io_slice *slice)
+int osc_io_read_start(const struct lu_env *env,
+		      const struct cl_io_slice *slice)
 {
-	struct cl_object *obj = slice->cis_obj;
+	struct cl_object *obj  = slice->cis_obj;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int rc = 0;
 
@@ -725,11 +729,12 @@ static int osc_io_read_start(const struct lu_env *env,
 	}
 	return rc;
 }
+EXPORT_SYMBOL(osc_io_read_start);
 
-static int osc_io_write_start(const struct lu_env *env,
-			      const struct cl_io_slice *slice)
+int osc_io_write_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice)
 {
-	struct cl_object *obj = slice->cis_obj;
+	struct cl_object *obj   = slice->cis_obj;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int rc = 0;
 
@@ -742,6 +747,7 @@ static int osc_io_write_start(const struct lu_env *env,
 
 	return rc;
 }
+EXPORT_SYMBOL(osc_io_write_start);
 
 static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 			 struct cl_fsync_io *fio)
@@ -769,8 +775,8 @@ static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 	return rc;
 }
 
-static int osc_io_fsync_start(const struct lu_env *env,
-			      const struct cl_io_slice *slice)
+int osc_io_fsync_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice)
 {
 	struct cl_io *io = slice->cis_io;
 	struct cl_fsync_io *fio = &io->u.ci_fsync;
@@ -808,9 +814,10 @@ static int osc_io_fsync_start(const struct lu_env *env,
 
 	return result;
 }
+EXPORT_SYMBOL(osc_io_fsync_start);
 
-static void osc_io_fsync_end(const struct lu_env *env,
-			     const struct cl_io_slice *slice)
+void osc_io_fsync_end(const struct lu_env *env,
+		      const struct cl_io_slice *slice)
 {
 	struct cl_fsync_io *fio = &slice->cis_io->u.ci_fsync;
 	struct cl_object *obj = slice->cis_obj;
@@ -830,6 +837,7 @@ static void osc_io_fsync_end(const struct lu_env *env,
 	}
 	slice->cis_io->ci_result = result;
 }
+EXPORT_SYMBOL(osc_io_fsync_end);
 
 static int osc_io_ladvise_start(const struct lu_env *env,
 				const struct cl_io_slice *slice)
@@ -905,8 +913,7 @@ static void osc_io_ladvise_end(const struct lu_env *env,
 	slice->cis_io->ci_result = result;
 }
 
-static void osc_io_end(const struct lu_env *env,
-		       const struct cl_io_slice *slice)
+void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice)
 {
 	struct osc_io *oio = cl2osc_io(env, slice);
 
@@ -915,6 +922,7 @@ static void osc_io_end(const struct lu_env *env,
 		oio->oi_active = NULL;
 	}
 }
+EXPORT_SYMBOL(osc_io_end);
 
 static const struct cl_io_operations osc_io_ops = {
 	.op = {
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 3576b34..45b18f1 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -276,6 +276,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	return result;
 }
+EXPORT_SYMBOL(osc_page_init);
 
 /**
  * Helper function called by osc_io_submit() for every page in an immediate
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e804554..275bd12 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -410,30 +410,32 @@ static int osc_create(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-int osc_punch_base(struct obd_export *exp, struct obdo *oa,
-		   obd_enqueue_update_f upcall, void *cookie,
-		   struct ptlrpc_request_set *rqset)
+int osc_punch_send(struct obd_export *exp, struct obdo *oa,
+		   obd_enqueue_update_f upcall, void *cookie)
 {
 	struct ptlrpc_request *req;
 	struct osc_setattr_args *sa;
+	struct obd_import *imp = class_exp2cliimp(exp);
 	struct ost_body *body;
 	int rc;
 
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_PUNCH);
+	req = ptlrpc_request_alloc(imp, &RQF_OST_PUNCH);
 	if (!req)
 		return -ENOMEM;
 
 	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_PUNCH);
-	if (rc) {
+	if (rc < 0) {
 		ptlrpc_request_free(req);
 		return rc;
 	}
-	req->rq_request_portal = OST_IO_PORTAL; /* bug 7198 */
+
+	osc_set_io_portal(req);
+
 	ptlrpc_at_set_req_timeout(req);
 
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
-	LASSERT(body);
-	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa,
+
+	lustre_set_wire_obdo(&imp->imp_connect_data, &body->oa,
 			     oa);
 
 	ptlrpc_request_set_replen(req);
@@ -444,10 +446,12 @@ int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
 	sa->sa_cookie = cookie;
-	ptlrpc_set_add_req(rqset, req);
+
+	ptlrpcd_add_req(req);
 
 	return 0;
 }
+EXPORT_SYMBOL(osc_punch_send);
 
 static int osc_sync_interpret(const struct lu_env *env,
 			      struct ptlrpc_request *req,
@@ -1157,7 +1161,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		ptlrpc_request_free(req);
 		return rc;
 	}
-	req->rq_request_portal = OST_IO_PORTAL; /* bug 7198 */
+	osc_set_io_portal(req);
+
 	ptlrpc_at_set_req_timeout(req);
 	/* ask ptlrpc not to resend on EINPROGRESS since BRWs have their own
 	 * retry logic
-- 
1.8.3.1
