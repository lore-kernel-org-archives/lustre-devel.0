From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:29 -0400
Subject: [lustre-devel] [PATCH 5/7] staging: lustre: obd: remove dead code
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471630051-26700-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <uja.ornl@gmail.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove unused OBD functions: oti_alloc_cookies(), oti_free_cookies(),
class_observe_import(), class_unobserve_import(),
md_is_subdir(), md_readpage(), obdo2fid(), fid2obdo().

Remove several unused, get-only, and set-only structure members.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/9784
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +-
 .../staging/lustre/lustre/include/lustre_import.h  |   22 -------
 drivers/staging/lustre/lustre/include/lustre_log.h |    3 +-
 .../lustre/lustre/include/lustre_req_layout.h      |    3 -
 drivers/staging/lustre/lustre/include/obd.h        |   64 --------------------
 drivers/staging/lustre/lustre/include/obd_class.h  |   49 +--------------
 .../staging/lustre/lustre/include/obd_support.h    |    1 -
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   15 -----
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   27 --------
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   25 --------
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |    2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |   16 +-----
 drivers/staging/lustre/lustre/obdclass/obdo.c      |    7 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |   12 +---
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   17 -----
 17 files changed, 18 insertions(+), 254 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index c57231b..35af07e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1937,8 +1937,8 @@ enum mds_cmd {
 	MDS_DISCONNECT		= 39,
 	MDS_GETSTATUS		= 40,
 	MDS_STATFS		= 41,
-	MDS_PIN			= 42,
-	MDS_UNPIN		= 43,
+	MDS_PIN			= 42, /* obsolete, never used in a release */
+	MDS_UNPIN		= 43, /* obsolete, never used in a release */
 	MDS_SYNC		= 44,
 	MDS_DONE_WRITING	= 45,
 	MDS_SET_INFO		= 46,
@@ -1947,7 +1947,7 @@ enum mds_cmd {
 	MDS_GETXATTR		= 49,
 	MDS_SETXATTR		= 50, /* obsolete, now it's MDS_REINT op */
 	MDS_WRITEPAGE		= 51,
-	MDS_IS_SUBDIR		= 52,
+	MDS_IS_SUBDIR		= 52, /* obsolete, never used in a release */
 	MDS_GET_INFO		= 53,
 	MDS_HSM_STATE_GET	= 54,
 	MDS_HSM_STATE_SET	= 55,
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 4445be7..b7a7a74 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -305,28 +305,6 @@ struct obd_import {
 	time64_t	     imp_last_reply_time;    /* for health check */
 };
 
-typedef void (*obd_import_callback)(struct obd_import *imp, void *closure,
-				    int event, void *event_arg, void *cb_data);
-
-/**
- * Structure for import observer.
- * It is possible to register "observer" on an import and every time
- * something happens to an import (like connect/evict/disconnect)
- * obderver will get its callback called with event type
- */
-struct obd_import_observer {
-	struct list_head	   oio_chain;
-	obd_import_callback  oio_cb;
-	void		*oio_cb_data;
-};
-
-void class_observe_import(struct obd_import *imp, obd_import_callback cb,
-			  void *cb_data);
-void class_unobserve_import(struct obd_import *imp, obd_import_callback cb,
-			    void *cb_data);
-void class_notify_import_observers(struct obd_import *imp, int event,
-				   void *event_arg);
-
 /* import.c */
 static inline unsigned int at_est2timeout(unsigned int val)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index b96e023..995b266 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -277,12 +277,11 @@ static inline void llog_ctxt_put(struct llog_ctxt *ctxt)
 	__llog_ctxt_put(NULL, ctxt);
 }
 
-static inline void llog_group_init(struct obd_llog_group *olg, int group)
+static inline void llog_group_init(struct obd_llog_group *olg)
 {
 	init_waitqueue_head(&olg->olg_waitq);
 	spin_lock_init(&olg->olg_lock);
 	mutex_init(&olg->olg_cat_processing);
-	olg->olg_seq = group;
 }
 
 static inline int llog_group_set_ctxt(struct obd_llog_group *olg,
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 544a43c..ca0e683 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -149,14 +149,11 @@ extern struct req_format RQF_MDS_GETATTR;
 extern struct req_format RQF_MDS_GETATTR_NAME;
 extern struct req_format RQF_MDS_CLOSE;
 extern struct req_format RQF_MDS_RELEASE_CLOSE;
-extern struct req_format RQF_MDS_PIN;
-extern struct req_format RQF_MDS_UNPIN;
 extern struct req_format RQF_MDS_CONNECT;
 extern struct req_format RQF_MDS_DISCONNECT;
 extern struct req_format RQF_MDS_GET_INFO;
 extern struct req_format RQF_MDS_READPAGE;
 extern struct req_format RQF_MDS_WRITEPAGE;
-extern struct req_format RQF_MDS_IS_SUBDIR;
 extern struct req_format RQF_MDS_DONE_WRITING;
 extern struct req_format RQF_MDS_REINT;
 extern struct req_format RQF_MDS_REINT_CREATE;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 92eebff..6fc0bcc 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -243,7 +243,6 @@ struct client_obd {
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
 	int		  cl_chunkbits;
-	int		  cl_chunk;
 	int		  cl_extent_tax; /* extent overhead, by bytes */
 
 	/* keep track of objects that have lois that contain pages which
@@ -442,7 +441,6 @@ struct niobuf_local {
 	__u32		flags;
 	struct page	*page;
 	struct dentry	*dentry;
-	int		lnb_grant_used;
 	int		rc;
 };
 
@@ -485,7 +483,6 @@ struct niobuf_local {
 #define N_LOCAL_TEMP_PAGE 0x10000000
 
 struct obd_trans_info {
-	__u64		    oti_transno;
 	__u64		    oti_xid;
 	/* Only used on the server side for tracking acks. */
 	struct oti_req_ack_lock {
@@ -495,50 +492,11 @@ struct obd_trans_info {
 	void		    *oti_handle;
 	struct llog_cookie       oti_onecookie;
 	struct llog_cookie      *oti_logcookies;
-	int		      oti_numcookies;
-	/** synchronous write is needed */
-	unsigned long		 oti_sync_write:1;
 
-	/* initial thread handling transaction */
-	struct ptlrpc_thread *oti_thread;
-	__u32		    oti_conn_cnt;
 	/** VBR: versions */
 	__u64		    oti_pre_version;
-	/** JobID */
-	char		    *oti_jobid;
-
-	struct obd_uuid	 *oti_ost_uuid;
 };
 
-static inline void oti_alloc_cookies(struct obd_trans_info *oti,
-				     int num_cookies)
-{
-	if (!oti)
-		return;
-
-	if (num_cookies == 1)
-		oti->oti_logcookies = &oti->oti_onecookie;
-	else
-		oti->oti_logcookies = libcfs_kvzalloc(num_cookies * sizeof(oti->oti_onecookie),
-						      GFP_NOFS);
-
-	oti->oti_numcookies = num_cookies;
-}
-
-static inline void oti_free_cookies(struct obd_trans_info *oti)
-{
-	if (!oti || !oti->oti_logcookies)
-		return;
-
-	if (oti->oti_logcookies == &oti->oti_onecookie)
-		LASSERT(oti->oti_numcookies == 1);
-	else
-		kvfree(oti->oti_logcookies);
-
-	oti->oti_logcookies = NULL;
-	oti->oti_numcookies = 0;
-}
-
 /*
  * Events signalled through obd_notify() upcall-chain.
  */
@@ -584,7 +542,6 @@ struct target_recovery_data {
 };
 
 struct obd_llog_group {
-	int		olg_seq;
 	struct llog_ctxt  *olg_ctxts[LLOG_MAX_CTXTS];
 	wait_queue_head_t	olg_waitq;
 	spinlock_t	   olg_lock;
@@ -620,7 +577,6 @@ struct obd_device {
 		      obd_starting:1,      /* started setup */
 		      obd_force:1,	 /* cleanup with > 0 obd refcount */
 		      obd_fail:1,	 /* cleanup with failover */
-		      obd_async_recov:1, /* allow asynchronous orphan cleanup */
 		      obd_no_conn:1,       /* deny new connections */
 		      obd_inactive:1,      /* device active/inactive
 					    * (for sysfs status only!!)
@@ -695,9 +651,6 @@ struct obd_device {
 	struct completion	obd_kobj_unregister;
 };
 
-#define OBD_LLOG_FL_SENDNOW     0x0001
-#define OBD_LLOG_FL_EXIT	0x0002
-
 enum obd_cleanup_stage {
 /* Special case hack for MDS LOVs */
 	OBD_CLEANUP_EARLY,
@@ -707,8 +660,6 @@ enum obd_cleanup_stage {
 
 /* get/set_info keys */
 #define KEY_ASYNC	       "async"
-#define KEY_BLOCKSIZE_BITS      "blocksize_bits"
-#define KEY_BLOCKSIZE	   "blocksize"
 #define KEY_CHANGELOG_CLEAR     "changelog_clear"
 #define KEY_FID2PATH	    "fid2path"
 #define KEY_CHECKSUM	    "checksum"
@@ -720,13 +671,11 @@ enum obd_cleanup_stage {
 #define KEY_GRANT_SHRINK	"grant_shrink"
 #define KEY_HSM_COPYTOOL_SEND   "hsm_send"
 #define KEY_INIT_RECOV_BACKUP   "init_recov_bk"
-#define KEY_INIT_RECOV	  "initial_recov"
 #define KEY_INTERMDS	    "inter_mds"
 #define KEY_LAST_ID	     "last_id"
 #define KEY_LAST_FID		"last_fid"
 #define KEY_LOCK_TO_STRIPE      "lock_to_stripe"
 #define KEY_LOVDESC	     "lovdesc"
-#define KEY_LOV_IDX	     "lov_idx"
 #define KEY_MAX_EASIZE		"max_easize"
 #define KEY_DEFAULT_EASIZE	"default_easize"
 #define KEY_MDS_CONN	    "mds_conn"
@@ -739,11 +688,9 @@ enum obd_cleanup_stage {
 /*      KEY_SET_INFO in lustre_idl.h */
 #define KEY_SPTLRPC_CONF	"sptlrpc_conf"
 #define KEY_CONNECT_FLAG	"connect_flags"
-#define KEY_SYNC_LOCK_CANCEL    "sync_lock_cancel"
 
 #define KEY_CACHE_SET		"cache_set"
 #define KEY_CACHE_LRU_SHRINK	"cache_lru_shrink"
-#define KEY_CHANGELOG_INDEX	"changelog_index"
 
 struct lu_context;
 
@@ -872,8 +819,6 @@ struct obd_ops {
 			      __u32 keylen, void *key,
 			      __u32 vallen, void *val,
 			      struct ptlrpc_request_set *set);
-	int (*attach)(struct obd_device *dev, u32 len, void *data);
-	int (*detach)(struct obd_device *dev);
 	int (*setup)(struct obd_device *dev, struct lustre_cfg *cfg);
 	int (*precleanup)(struct obd_device *dev,
 			  enum obd_cleanup_stage cleanup_stage);
@@ -1038,16 +983,11 @@ struct md_ops {
 	int (*rename)(struct obd_export *, struct md_op_data *,
 		      const char *, int, const char *, int,
 		      struct ptlrpc_request **);
-	int (*is_subdir)(struct obd_export *, const struct lu_fid *,
-			 const struct lu_fid *,
-			   struct ptlrpc_request **);
 	int (*setattr)(struct obd_export *, struct md_op_data *, void *,
 		       int, void *, int, struct ptlrpc_request **,
 			 struct md_open_data **mod);
 	int (*sync)(struct obd_export *, const struct lu_fid *,
 		    struct ptlrpc_request **);
-	int (*readpage)(struct obd_export *, struct md_op_data *,
-			struct page **, struct ptlrpc_request **);
 	int (*read_page)(struct obd_export *, struct md_op_data *,
 			 struct md_callback *cb_op, __u64 hash_offset,
 			 struct page **ppage);
@@ -1141,10 +1081,6 @@ static inline const struct lsm_operations *lsm_op_find(int magic)
 	}
 }
 
-/* Requests for obd_extent_calc() */
-#define OBD_CALC_STRIPE_START   1
-#define OBD_CALC_STRIPE_END     2
-
 static inline struct md_open_data *obd_mod_alloc(void)
 {
 	struct md_open_data *mod;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index daca5a0..fe1af94 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -56,7 +56,6 @@
 #define OBD_STATFS_FOR_MDT0	0x0008	/* The statfs is only for retrieving
 					 * information from MDT0.
 					 */
-#define OBD_FL_PUNCH	    0x00000001  /* To indicate it is punch operation */
 
 /* OBD Device Declarations */
 extern struct obd_device *obd_devs[MAX_OBD_DEVICES];
@@ -270,10 +269,10 @@ static inline int lprocfs_climp_check(struct obd_device *obd)
 struct inode;
 struct lu_attr;
 struct obdo;
-void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid);
+void obdo_refresh_inode(struct inode *dst, const struct obdo *src, u32 valid);
 
-void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj);
-void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid);
+void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj);
+void md_from_obdo(struct md_op_data *op_data, const struct obdo *oa, u32 valid);
 
 #define OBT(dev)	(dev)->obd_type
 #define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->op
@@ -1216,12 +1215,7 @@ static inline int obd_notify(struct obd_device *obd,
 	if (rc)
 		return rc;
 
-	/* the check for async_recov is a complete hack - I'm hereby
-	 * overloading the meaning to also mean "this was called from
-	 * mds_postsetup".  I know that my mds is able to handle notifies
-	 * by this point, and it needs to get them to execute mds_postrecov.
-	 */
-	if (!obd->obd_set_up && !obd->obd_async_recov) {
+	if (!obd->obd_set_up) {
 		CDEBUG(D_HA, "obd %s not set up\n", obd->obd_name);
 		return -EINVAL;
 	}
@@ -1485,19 +1479,6 @@ static inline int md_rename(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
-static inline int md_is_subdir(struct obd_export *exp,
-			       const struct lu_fid *pfid,
-			       const struct lu_fid *cfid,
-			       struct ptlrpc_request **request)
-{
-	int rc;
-
-	EXP_CHECK_MD_OP(exp, is_subdir);
-	EXP_MD_COUNTER_INCREMENT(exp, is_subdir);
-	rc = MDP(exp->exp_obd, is_subdir)(exp, pfid, cfid, request);
-	return rc;
-}
-
 static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
 			     void *ea, int ealen, void *ea2, int ea2len,
 			     struct ptlrpc_request **request,
@@ -1523,18 +1504,6 @@ static inline int md_sync(struct obd_export *exp, const struct lu_fid *fid,
 	return rc;
 }
 
-static inline int md_readpage(struct obd_export *exp, struct md_op_data *opdata,
-			      struct page **pages,
-			      struct ptlrpc_request **request)
-{
-	int rc;
-
-	EXP_CHECK_MD_OP(exp, readpage);
-	EXP_MD_COUNTER_INCREMENT(exp, readpage);
-	rc = MDP(exp->exp_obd, readpage)(exp, opdata, pages, request);
-	return rc;
-}
-
 static inline int md_read_page(struct obd_export *exp,
 			       struct md_op_data *op_data,
 			       struct md_callback *cb_op,
@@ -1735,16 +1704,6 @@ void obd_cleanup_caches(void);
 /* support routines */
 extern struct kmem_cache *obdo_cachep;
 
-static inline void obdo2fid(struct obdo *oa, struct lu_fid *fid)
-{
-	/* something here */
-}
-
-static inline void fid2obdo(struct lu_fid *fid, struct obdo *oa)
-{
-	/* something here */
-}
-
 typedef int (*register_lwp_cb)(void *data);
 
 struct lwp_register_item {
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index f747bca..5ef798f 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -52,7 +52,6 @@ extern unsigned int at_max;
 extern unsigned int at_history;
 extern int at_early_margin;
 extern int at_extra;
-extern unsigned int obd_sync_filter;
 extern unsigned int obd_max_dirty_pages;
 extern atomic_t obd_dirty_pages;
 extern atomic_t obd_dirty_transit_pages;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 492ebbc..f4d0c36 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -39,8 +39,6 @@ void lprocfs_mdc_init_vars(struct lprocfs_static_vars *lvars);
 
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 		   __u64 valid, int ea_size, __u32 suppgid, int flags);
-void mdc_is_subdir_pack(struct ptlrpc_request *req, const struct lu_fid *pfid,
-			const struct lu_fid *cfid, int flags);
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 			   struct md_op_data *op_data);
 void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, __u32 size,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index aa496f3..ecfe13e 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -45,21 +45,6 @@ static void __mdc_pack_body(struct mdt_body *b, __u32 suppgid)
 	b->mbo_capability = cfs_curproc_cap_pack();
 }
 
-void mdc_is_subdir_pack(struct ptlrpc_request *req, const struct lu_fid *pfid,
-			const struct lu_fid *cfid, int flags)
-{
-	struct mdt_body *b = req_capsule_client_get(&req->rq_pill,
-						    &RMF_MDT_BODY);
-
-	if (pfid) {
-		b->mbo_fid1 = *pfid;
-		b->mbo_valid = OBD_MD_FLID;
-	}
-	if (cfid)
-		b->mbo_fid2 = *cfid;
-	b->mbo_flags = flags;
-}
-
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
 			   struct md_op_data *op_data)
 {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 5520819..213f31b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -232,32 +232,6 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
-static int mdc_is_subdir(struct obd_export *exp,
-			 const struct lu_fid *pfid,
-			 const struct lu_fid *cfid,
-			 struct ptlrpc_request **request)
-{
-	struct ptlrpc_request  *req;
-	int		     rc;
-
-	*request = NULL;
-	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
-					&RQF_MDS_IS_SUBDIR, LUSTRE_MDS_VERSION,
-					MDS_IS_SUBDIR);
-	if (!req)
-		return -ENOMEM;
-
-	mdc_is_subdir_pack(req, pfid, cfid, 0);
-	ptlrpc_request_set_replen(req);
-
-	rc = ptlrpc_queue_wait(req);
-	if (rc && rc != -EREMOTE)
-		ptlrpc_req_finished(req);
-	else
-		*request = req;
-	return rc;
-}
-
 static int mdc_xattr_common(struct obd_export *exp,
 			    const struct req_format *fmt,
 			    const struct lu_fid *fid,
@@ -2892,7 +2866,6 @@ static struct md_ops mdc_md_ops = {
 	.getattr_name		= mdc_getattr_name,
 	.intent_lock		= mdc_intent_lock,
 	.link			= mdc_link,
-	.is_subdir		= mdc_is_subdir,
 	.rename			= mdc_rename,
 	.setattr		= mdc_setattr,
 	.setxattr		= mdc_setxattr,
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 90a365b..6700167 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -115,19 +115,6 @@ int lustre_get_jobid(char *jobid)
 }
 EXPORT_SYMBOL(lustre_get_jobid);
 
-static inline void obd_data2conn(struct lustre_handle *conn,
-				 struct obd_ioctl_data *data)
-{
-	memset(conn, 0, sizeof(*conn));
-	conn->cookie = data->ioc_cookie;
-}
-
-static inline void obd_conn2data(struct obd_ioctl_data *data,
-				 struct lustre_handle *conn)
-{
-	data->ioc_cookie = conn->cookie;
-}
-
 static int class_resolve_dev_name(__u32 len, const char *name)
 {
 	int rc;
@@ -534,23 +521,11 @@ static int __init obdclass_init(void)
 
 static void obdclass_exit(void)
 {
-	int i;
-
 	int lustre_unregister_fs(void);
 
 	lustre_unregister_fs();
 
 	misc_deregister(&obd_psdev);
-	for (i = 0; i < class_devno_max(); i++) {
-		struct obd_device *obd = class_num2obd(i);
-
-		if (obd && obd->obd_set_up &&
-		    OBT(obd) && OBP(obd, detach)) {
-			/* XXX should this call generic detach otherwise? */
-			LASSERT(obd->obd_magic == OBD_DEVICE_MAGIC);
-			OBP(obd, detach)(obd);
-		}
-	}
 	llog_info_fini();
 	cl_global_fini();
 	lu_global_fini();
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
index c6cc6a7..41b77a3 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
@@ -44,7 +44,7 @@
 
 #include <linux/fs.h>
 
-void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid)
+void obdo_refresh_inode(struct inode *dst, const struct obdo *src, u32 valid)
 {
 	valid &= src->o_valid;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 6d0890f..01034b5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -238,7 +238,7 @@ static int class_attach(struct lustre_cfg *lcfg)
 	/* recovery data */
 	init_waitqueue_head(&obd->obd_evict_inprogress_waitq);
 
-	llog_group_init(&obd->obd_olg, FID_SEQ_LLOG);
+	llog_group_init(&obd->obd_olg);
 
 	obd->obd_conn_inprogress = 0;
 
@@ -251,15 +251,6 @@ static int class_attach(struct lustre_cfg *lcfg)
 	}
 	memcpy(obd->obd_uuid.uuid, uuid, len);
 
-	/* do the attach */
-	if (OBP(obd, attach)) {
-		rc = OBP(obd, attach)(obd, sizeof(*lcfg), lcfg);
-		if (rc) {
-			rc = -EINVAL;
-			goto out;
-		}
-	}
-
 	/* Detach drops this */
 	spin_lock(&obd->obd_dev_lock);
 	atomic_set(&obd->obd_refcount, 1);
@@ -527,11 +518,6 @@ void class_decref(struct obd_device *obd, const char *scope, const void *source)
 				CERROR("Cleanup %s returned %d\n",
 				       obd->obd_name, err);
 		}
-		if (OBP(obd, detach)) {
-			err = OBP(obd, detach)(obd);
-			if (err)
-				CERROR("Detach returned %d\n", err);
-		}
 		class_release_dev(obd);
 	}
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 8583a4a..4454764 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -112,7 +112,7 @@ void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid)
 }
 EXPORT_SYMBOL(obdo_from_inode);
 
-void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj)
+void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj)
 {
 	ioobj->ioo_oid = oa->o_oi;
 	if (unlikely(!(oa->o_valid & OBD_MD_FLGROUP)))
@@ -125,7 +125,8 @@ void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj)
 }
 EXPORT_SYMBOL(obdo_to_ioobj);
 
-static void iattr_from_obdo(struct iattr *attr, struct obdo *oa, u32 valid)
+static void iattr_from_obdo(struct iattr *attr, const struct obdo *oa,
+			    u32 valid)
 {
 	valid &= oa->o_valid;
 
@@ -173,7 +174,7 @@ static void iattr_from_obdo(struct iattr *attr, struct obdo *oa, u32 valid)
 	}
 }
 
-void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid)
+void md_from_obdo(struct md_op_data *op_data, const struct obdo *oa, u32 valid)
 {
 	iattr_from_obdo(&op_data->op_attr, oa, valid);
 	if (valid & OBD_MD_FLBLOCKS) {
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 2cb487b..7527112 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1443,7 +1443,6 @@ static int echo_client_prep_commit(const struct lu_env *env,
 		}
 
 		ioo.ioo_bufcnt = npages;
-		oti->oti_transno = 0;
 
 		lpages = npages;
 		ret = obd_preprw(env, rw, exp, oa, 1, &ioo, rnb, &lpages,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c618337..2a4056a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -498,14 +498,10 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 	lsm->lsm_oi = oa->o_oi;
 	*ea = lsm;
 
-	if (oti) {
-		oti->oti_transno = lustre_msg_get_transno(req->rq_repmsg);
-
-		if (oa->o_valid & OBD_MD_FLCOOKIE) {
-			if (!oti->oti_logcookies)
-				oti_alloc_cookies(oti, 1);
-			*oti->oti_logcookies = oa->o_lcookie;
-		}
+	if (oti && oa->o_valid & OBD_MD_FLCOOKIE) {
+		if (!oti->oti_logcookies)
+			oti->oti_logcookies = &oti->oti_onecookie;
+		*oti->oti_logcookies = oa->o_lcookie;
 	}
 
 	CDEBUG(D_HA, "transno: %lld\n",
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index ab5d851..101ac87 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -667,11 +667,8 @@ static struct req_format *req_formats[] = {
 	&RQF_MDS_SYNC,
 	&RQF_MDS_CLOSE,
 	&RQF_MDS_RELEASE_CLOSE,
-	&RQF_MDS_PIN,
-	&RQF_MDS_UNPIN,
 	&RQF_MDS_READPAGE,
 	&RQF_MDS_WRITEPAGE,
-	&RQF_MDS_IS_SUBDIR,
 	&RQF_MDS_DONE_WRITING,
 	&RQF_MDS_REINT,
 	&RQF_MDS_REINT_CREATE,
@@ -1389,15 +1386,6 @@ struct req_format RQF_MDS_RELEASE_CLOSE =
 			mdt_release_close_client, mds_last_unlink_server);
 EXPORT_SYMBOL(RQF_MDS_RELEASE_CLOSE);
 
-struct req_format RQF_MDS_PIN =
-	DEFINE_REQ_FMT0("MDS_PIN",
-			mdt_body_capa, mdt_body_only);
-EXPORT_SYMBOL(RQF_MDS_PIN);
-
-struct req_format RQF_MDS_UNPIN =
-	DEFINE_REQ_FMT0("MDS_UNPIN", mdt_body_only, empty);
-EXPORT_SYMBOL(RQF_MDS_UNPIN);
-
 struct req_format RQF_MDS_DONE_WRITING =
 	DEFINE_REQ_FMT0("MDS_DONE_WRITING",
 			mdt_close_client, mdt_body_only);
@@ -1448,11 +1436,6 @@ struct req_format RQF_MDS_WRITEPAGE =
 			mdt_body_capa, mdt_body_only);
 EXPORT_SYMBOL(RQF_MDS_WRITEPAGE);
 
-struct req_format RQF_MDS_IS_SUBDIR =
-	DEFINE_REQ_FMT0("MDS_IS_SUBDIR",
-			mdt_body_only, mdt_body_only);
-EXPORT_SYMBOL(RQF_MDS_IS_SUBDIR);
-
 struct req_format RQF_LLOG_ORIGIN_HANDLE_CREATE =
 	DEFINE_REQ_FMT0("LLOG_ORIGIN_HANDLE_CREATE",
 			llog_origin_handle_create_client, llogd_body_only);
-- 
1.7.1
