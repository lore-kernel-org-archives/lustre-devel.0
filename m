From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 29 Oct 2015 12:26:36 +0300
Subject: [lustre-devel] [patch 2/2] staging: lustre: remove m_ prefix from
	function pointers
In-Reply-To: <20151029092440.GA8629@mwanda>
Message-ID: <20151029092636.GB8629@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All the callers call these function pointers without the "m_" prefix and
use macro magic to add it later behind the scenes.  It means that you
can't grep for the call sites.  I considered modifying the call sites
but in the end I decided that the "m_" prefix doesn't add anything so we
can just get rid of it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5aca9bb..5c90b59 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1124,89 +1124,89 @@ struct md_open_data {
 struct lookup_intent;
 
 struct md_ops {
-	int (*m_getstatus)(struct obd_export *, struct lu_fid *);
-	int (*m_null_inode)(struct obd_export *, const struct lu_fid *);
-	int (*m_find_cbdata)(struct obd_export *, const struct lu_fid *,
-			     ldlm_iterator_t, void *);
-	int (*m_close)(struct obd_export *, struct md_op_data *,
-		       struct md_open_data *, struct ptlrpc_request **);
-	int (*m_create)(struct obd_export *, struct md_op_data *,
-			const void *, int, int, __u32, __u32, cfs_cap_t,
-			__u64, struct ptlrpc_request **);
-	int (*m_done_writing)(struct obd_export *, struct md_op_data  *,
-			      struct md_open_data *);
-	int (*m_enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
-			 struct lookup_intent *, struct md_op_data *,
-			 struct lustre_handle *, void *, int,
-			 struct ptlrpc_request **, __u64);
-	int (*m_getattr)(struct obd_export *, struct md_op_data *,
-			 struct ptlrpc_request **);
-	int (*m_getattr_name)(struct obd_export *, struct md_op_data *,
-			      struct ptlrpc_request **);
-	int (*m_intent_lock)(struct obd_export *, struct md_op_data *,
-			     void *, int, struct lookup_intent *, int,
-			     struct ptlrpc_request **,
-			     ldlm_blocking_callback, __u64);
-	int (*m_link)(struct obd_export *, struct md_op_data *,
+	int (*getstatus)(struct obd_export *, struct lu_fid *);
+	int (*null_inode)(struct obd_export *, const struct lu_fid *);
+	int (*find_cbdata)(struct obd_export *, const struct lu_fid *,
+			   ldlm_iterator_t, void *);
+	int (*close)(struct obd_export *, struct md_op_data *,
+		     struct md_open_data *, struct ptlrpc_request **);
+	int (*create)(struct obd_export *, struct md_op_data *,
+		      const void *, int, int, __u32, __u32, cfs_cap_t,
+		      __u64, struct ptlrpc_request **);
+	int (*done_writing)(struct obd_export *, struct md_op_data  *,
+			    struct md_open_data *);
+	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
+		       struct lookup_intent *, struct md_op_data *,
+		       struct lustre_handle *, void *, int,
+		       struct ptlrpc_request **, __u64);
+	int (*getattr)(struct obd_export *, struct md_op_data *,
+		       struct ptlrpc_request **);
+	int (*getattr_name)(struct obd_export *, struct md_op_data *,
+			    struct ptlrpc_request **);
+	int (*intent_lock)(struct obd_export *, struct md_op_data *,
+			   void *, int, struct lookup_intent *, int,
+			   struct ptlrpc_request **,
+			   ldlm_blocking_callback, __u64);
+	int (*link)(struct obd_export *, struct md_op_data *,
+		    struct ptlrpc_request **);
+	int (*rename)(struct obd_export *, struct md_op_data *,
+		      const char *, int, const char *, int,
 		      struct ptlrpc_request **);
-	int (*m_rename)(struct obd_export *, struct md_op_data *,
-			const char *, int, const char *, int,
-			struct ptlrpc_request **);
-	int (*m_is_subdir)(struct obd_export *, const struct lu_fid *,
-			   const struct lu_fid *,
+	int (*is_subdir)(struct obd_export *, const struct lu_fid *,
+			 const struct lu_fid *,
 			   struct ptlrpc_request **);
-	int (*m_setattr)(struct obd_export *, struct md_op_data *, void *,
-			 int, void *, int, struct ptlrpc_request **,
+	int (*setattr)(struct obd_export *, struct md_op_data *, void *,
+		       int, void *, int, struct ptlrpc_request **,
 			 struct md_open_data **mod);
-	int (*m_sync)(struct obd_export *, const struct lu_fid *,
+	int (*sync)(struct obd_export *, const struct lu_fid *,
+		    struct ptlrpc_request **);
+	int (*readpage)(struct obd_export *, struct md_op_data *,
+			struct page **, struct ptlrpc_request **);
+
+	int (*unlink)(struct obd_export *, struct md_op_data *,
 		      struct ptlrpc_request **);
-	int (*m_readpage)(struct obd_export *, struct md_op_data *,
-			  struct page **, struct ptlrpc_request **);
 
-	int (*m_unlink)(struct obd_export *, struct md_op_data *,
+	int (*setxattr)(struct obd_export *, const struct lu_fid *,
+			u64, const char *, const char *, int, int, int, __u32,
 			struct ptlrpc_request **);
 
-	int (*m_setxattr)(struct obd_export *, const struct lu_fid *,
-			  u64, const char *, const char *, int, int, int, __u32,
-			  struct ptlrpc_request **);
-
-	int (*m_getxattr)(struct obd_export *, const struct lu_fid *,
-			  u64, const char *, const char *, int, int, int,
-			  struct ptlrpc_request **);
+	int (*getxattr)(struct obd_export *, const struct lu_fid *,
+			u64, const char *, const char *, int, int, int,
+			struct ptlrpc_request **);
 
-	int (*m_init_ea_size)(struct obd_export *, int, int, int, int);
+	int (*init_ea_size)(struct obd_export *, int, int, int, int);
 
-	int (*m_get_lustre_md)(struct obd_export *, struct ptlrpc_request *,
-			       struct obd_export *, struct obd_export *,
-			       struct lustre_md *);
+	int (*get_lustre_md)(struct obd_export *, struct ptlrpc_request *,
+			     struct obd_export *, struct obd_export *,
+			     struct lustre_md *);
 
-	int (*m_free_lustre_md)(struct obd_export *, struct lustre_md *);
+	int (*free_lustre_md)(struct obd_export *, struct lustre_md *);
 
-	int (*m_set_open_replay_data)(struct obd_export *,
-				      struct obd_client_handle *,
-				      struct lookup_intent *);
-	int (*m_clear_open_replay_data)(struct obd_export *,
-					struct obd_client_handle *);
-	int (*m_set_lock_data)(struct obd_export *, __u64 *, void *, __u64 *);
+	int (*set_open_replay_data)(struct obd_export *,
+				    struct obd_client_handle *,
+				    struct lookup_intent *);
+	int (*clear_open_replay_data)(struct obd_export *,
+				      struct obd_client_handle *);
+	int (*set_lock_data)(struct obd_export *, __u64 *, void *, __u64 *);
 
-	ldlm_mode_t (*m_lock_match)(struct obd_export *, __u64,
-				    const struct lu_fid *, ldlm_type_t,
-				    ldlm_policy_data_t *, ldlm_mode_t,
-				    struct lustre_handle *);
+	ldlm_mode_t (*lock_match)(struct obd_export *, __u64,
+				  const struct lu_fid *, ldlm_type_t,
+				  ldlm_policy_data_t *, ldlm_mode_t,
+				  struct lustre_handle *);
 
-	int (*m_cancel_unused)(struct obd_export *, const struct lu_fid *,
-			       ldlm_policy_data_t *, ldlm_mode_t,
-			       ldlm_cancel_flags_t flags, void *opaque);
+	int (*cancel_unused)(struct obd_export *, const struct lu_fid *,
+			     ldlm_policy_data_t *, ldlm_mode_t,
+			     ldlm_cancel_flags_t flags, void *opaque);
 
-	int (*m_get_remote_perm)(struct obd_export *, const struct lu_fid *,
-				 __u32, struct ptlrpc_request **);
+	int (*get_remote_perm)(struct obd_export *, const struct lu_fid *,
+			       __u32, struct ptlrpc_request **);
 
-	int (*m_intent_getattr_async)(struct obd_export *,
-				      struct md_enqueue_info *,
-				      struct ldlm_enqueue_info *);
+	int (*intent_getattr_async)(struct obd_export *,
+				    struct md_enqueue_info *,
+				    struct ldlm_enqueue_info *);
 
-	int (*m_revalidate_lock)(struct obd_export *, struct lookup_intent *,
-				 struct lu_fid *, __u64 *bits);
+	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
+			       struct lu_fid *, __u64 *bits);
 
 	/*
 	 * NOTE: If adding ops, add another LPROCFS_MD_OP_INIT() line to
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 674be77..c323c84 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -261,7 +261,7 @@ void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid);
 
 #define OBT(dev)	(dev)->obd_type
 #define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->op
-#define MDP(dev, op)    (dev)->obd_type->typ_md_ops->m_ ## op
+#define MDP(dev, op)    (dev)->obd_type->typ_md_ops->op
 #define CTXTP(ctxt, op) (ctxt)->loc_logops->lop_##op
 
 /* Ensure obd_setup: used for cleanup which must be called
@@ -314,9 +314,9 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 	}
 
 #define MD_COUNTER_OFFSET(op)				   \
-	((offsetof(struct md_ops, m_ ## op) -		   \
-	  offsetof(struct md_ops, m_getstatus))		 \
-	 / sizeof(((struct md_ops *)(0))->m_getstatus))
+	((offsetof(struct md_ops, op) -		   \
+	  offsetof(struct md_ops, getstatus))		 \
+	 / sizeof(((struct md_ops *)(0))->getstatus))
 
 #define MD_COUNTER_INCREMENT(obdx, op)			   \
 	if ((obd)->md_stats != NULL) {			   \
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 947a127..55f801b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2764,35 +2764,35 @@ static struct obd_ops lmv_obd_ops = {
 };
 
 static struct md_ops lmv_md_ops = {
-	.m_getstatus	    = lmv_getstatus,
-	.m_null_inode		= lmv_null_inode,
-	.m_find_cbdata	  = lmv_find_cbdata,
-	.m_close		= lmv_close,
-	.m_create	       = lmv_create,
-	.m_done_writing	 = lmv_done_writing,
-	.m_enqueue	      = lmv_enqueue,
-	.m_getattr	      = lmv_getattr,
-	.m_getxattr	     = lmv_getxattr,
-	.m_getattr_name	 = lmv_getattr_name,
-	.m_intent_lock	  = lmv_intent_lock,
-	.m_link		 = lmv_link,
-	.m_rename	       = lmv_rename,
-	.m_setattr	      = lmv_setattr,
-	.m_setxattr	     = lmv_setxattr,
-	.m_sync		 = lmv_sync,
-	.m_readpage	     = lmv_readpage,
-	.m_unlink	       = lmv_unlink,
-	.m_init_ea_size	 = lmv_init_ea_size,
-	.m_cancel_unused	= lmv_cancel_unused,
-	.m_set_lock_data	= lmv_set_lock_data,
-	.m_lock_match	   = lmv_lock_match,
-	.m_get_lustre_md	= lmv_get_lustre_md,
-	.m_free_lustre_md       = lmv_free_lustre_md,
-	.m_set_open_replay_data = lmv_set_open_replay_data,
-	.m_clear_open_replay_data = lmv_clear_open_replay_data,
-	.m_get_remote_perm      = lmv_get_remote_perm,
-	.m_intent_getattr_async = lmv_intent_getattr_async,
-	.m_revalidate_lock      = lmv_revalidate_lock
+	.getstatus		= lmv_getstatus,
+	.null_inode		= lmv_null_inode,
+	.find_cbdata		= lmv_find_cbdata,
+	.close			= lmv_close,
+	.create			= lmv_create,
+	.done_writing		= lmv_done_writing,
+	.enqueue		= lmv_enqueue,
+	.getattr		= lmv_getattr,
+	.getxattr		= lmv_getxattr,
+	.getattr_name		= lmv_getattr_name,
+	.intent_lock		= lmv_intent_lock,
+	.link			= lmv_link,
+	.rename			= lmv_rename,
+	.setattr		= lmv_setattr,
+	.setxattr		= lmv_setxattr,
+	.sync			= lmv_sync,
+	.readpage		= lmv_readpage,
+	.unlink			= lmv_unlink,
+	.init_ea_size		= lmv_init_ea_size,
+	.cancel_unused		= lmv_cancel_unused,
+	.set_lock_data		= lmv_set_lock_data,
+	.lock_match		= lmv_lock_match,
+	.get_lustre_md		= lmv_get_lustre_md,
+	.free_lustre_md		= lmv_free_lustre_md,
+	.set_open_replay_data	= lmv_set_open_replay_data,
+	.clear_open_replay_data	= lmv_clear_open_replay_data,
+	.get_remote_perm	= lmv_get_remote_perm,
+	.intent_getattr_async	= lmv_intent_getattr_async,
+	.revalidate_lock	= lmv_revalidate_lock
 };
 
 static int __init lmv_init(void)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 34a8867..5b78e7a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2483,36 +2483,36 @@ static struct obd_ops mdc_obd_ops = {
 };
 
 static struct md_ops mdc_md_ops = {
-	.m_getstatus	= mdc_getstatus,
-	.m_null_inode	    = mdc_null_inode,
-	.m_find_cbdata      = mdc_find_cbdata,
-	.m_close	    = mdc_close,
-	.m_create	   = mdc_create,
-	.m_done_writing     = mdc_done_writing,
-	.m_enqueue	  = mdc_enqueue,
-	.m_getattr	  = mdc_getattr,
-	.m_getattr_name     = mdc_getattr_name,
-	.m_intent_lock      = mdc_intent_lock,
-	.m_link	     = mdc_link,
-	.m_is_subdir	= mdc_is_subdir,
-	.m_rename	   = mdc_rename,
-	.m_setattr	  = mdc_setattr,
-	.m_setxattr	 = mdc_setxattr,
-	.m_getxattr	 = mdc_getxattr,
-	.m_sync	     = mdc_sync,
-	.m_readpage	 = mdc_readpage,
-	.m_unlink	   = mdc_unlink,
-	.m_cancel_unused    = mdc_cancel_unused,
-	.m_init_ea_size     = mdc_init_ea_size,
-	.m_set_lock_data    = mdc_set_lock_data,
-	.m_lock_match       = mdc_lock_match,
-	.m_get_lustre_md    = mdc_get_lustre_md,
-	.m_free_lustre_md   = mdc_free_lustre_md,
-	.m_set_open_replay_data = mdc_set_open_replay_data,
-	.m_clear_open_replay_data = mdc_clear_open_replay_data,
-	.m_get_remote_perm  = mdc_get_remote_perm,
-	.m_intent_getattr_async = mdc_intent_getattr_async,
-	.m_revalidate_lock      = mdc_revalidate_lock
+	.getstatus		= mdc_getstatus,
+	.null_inode		= mdc_null_inode,
+	.find_cbdata		= mdc_find_cbdata,
+	.close			= mdc_close,
+	.create			= mdc_create,
+	.done_writing		= mdc_done_writing,
+	.enqueue		= mdc_enqueue,
+	.getattr		= mdc_getattr,
+	.getattr_name		= mdc_getattr_name,
+	.intent_lock		= mdc_intent_lock,
+	.link			= mdc_link,
+	.is_subdir		= mdc_is_subdir,
+	.rename			= mdc_rename,
+	.setattr		= mdc_setattr,
+	.setxattr		= mdc_setxattr,
+	.getxattr		= mdc_getxattr,
+	.sync			= mdc_sync,
+	.readpage		= mdc_readpage,
+	.unlink			= mdc_unlink,
+	.cancel_unused		= mdc_cancel_unused,
+	.init_ea_size		= mdc_init_ea_size,
+	.set_lock_data		= mdc_set_lock_data,
+	.lock_match		= mdc_lock_match,
+	.get_lustre_md		= mdc_get_lustre_md,
+	.free_lustre_md		= mdc_free_lustre_md,
+	.set_open_replay_data	= mdc_set_open_replay_data,
+	.clear_open_replay_data	= mdc_clear_open_replay_data,
+	.get_remote_perm	= mdc_get_remote_perm,
+	.intent_getattr_async	= mdc_intent_getattr_async,
+	.revalidate_lock	= mdc_revalidate_lock
 };
 
 static int __init mdc_init(void)
