From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 29 Oct 2015 12:24:40 +0300
Subject: [lustre-devel] [patch 1/2] staging: lustre: remove o_ prefix from
	function pointers
Message-ID: <20151029092440.GA8629@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We mostly refer to these function pointers using macros that use macro
magic to add the "o_" prefix to the front.  It means that you can't use
cscope to find the caller.  Heck, you can't even grep for it.

I looked at preserving the "o_" prefix by removing the macro magic and
adding "o_" to all the call sites but then I realized that, really, the
prefix doesn't add any value.  Let's just remove it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5e93afc..5aca9bb 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -963,123 +963,123 @@ struct md_enqueue_info {
 };
 
 struct obd_ops {
-	struct module *o_owner;
-	int (*o_iocontrol)(unsigned int cmd, struct obd_export *exp, int len,
-			   void *karg, void *uarg);
-	int (*o_get_info)(const struct lu_env *env, struct obd_export *,
-			  __u32 keylen, void *key, __u32 *vallen, void *val,
-			  struct lov_stripe_md *lsm);
-	int (*o_set_info_async)(const struct lu_env *, struct obd_export *,
-				__u32 keylen, void *key,
-				__u32 vallen, void *val,
-				struct ptlrpc_request_set *set);
-	int (*o_attach)(struct obd_device *dev, u32 len, void *data);
-	int (*o_detach)(struct obd_device *dev);
-	int (*o_setup)(struct obd_device *dev, struct lustre_cfg *cfg);
-	int (*o_precleanup)(struct obd_device *dev,
-			    enum obd_cleanup_stage cleanup_stage);
-	int (*o_cleanup)(struct obd_device *dev);
-	int (*o_process_config)(struct obd_device *dev, u32 len, void *data);
-	int (*o_postrecov)(struct obd_device *dev);
-	int (*o_add_conn)(struct obd_import *imp, struct obd_uuid *uuid,
-			  int priority);
-	int (*o_del_conn)(struct obd_import *imp, struct obd_uuid *uuid);
+	struct module *owner;
+	int (*iocontrol)(unsigned int cmd, struct obd_export *exp, int len,
+			 void *karg, void *uarg);
+	int (*get_info)(const struct lu_env *env, struct obd_export *,
+			__u32 keylen, void *key, __u32 *vallen, void *val,
+			struct lov_stripe_md *lsm);
+	int (*set_info_async)(const struct lu_env *, struct obd_export *,
+			      __u32 keylen, void *key,
+			      __u32 vallen, void *val,
+			      struct ptlrpc_request_set *set);
+	int (*attach)(struct obd_device *dev, u32 len, void *data);
+	int (*detach)(struct obd_device *dev);
+	int (*setup)(struct obd_device *dev, struct lustre_cfg *cfg);
+	int (*precleanup)(struct obd_device *dev,
+			  enum obd_cleanup_stage cleanup_stage);
+	int (*cleanup)(struct obd_device *dev);
+	int (*process_config)(struct obd_device *dev, u32 len, void *data);
+	int (*postrecov)(struct obd_device *dev);
+	int (*add_conn)(struct obd_import *imp, struct obd_uuid *uuid,
+			int priority);
+	int (*del_conn)(struct obd_import *imp, struct obd_uuid *uuid);
 	/* connect to the target device with given connection
 	 * data. @ocd->ocd_connect_flags is modified to reflect flags actually
 	 * granted by the target, which are guaranteed to be a subset of flags
 	 * asked for. If @ocd == NULL, use default parameters. */
-	int (*o_connect)(const struct lu_env *env,
-			 struct obd_export **exp, struct obd_device *src,
-			 struct obd_uuid *cluuid, struct obd_connect_data *ocd,
+	int (*connect)(const struct lu_env *env,
+		       struct obd_export **exp, struct obd_device *src,
+		       struct obd_uuid *cluuid, struct obd_connect_data *ocd,
+		       void *localdata);
+	int (*reconnect)(const struct lu_env *env,
+			 struct obd_export *exp, struct obd_device *src,
+			 struct obd_uuid *cluuid,
+			 struct obd_connect_data *ocd,
 			 void *localdata);
-	int (*o_reconnect)(const struct lu_env *env,
-			   struct obd_export *exp, struct obd_device *src,
-			   struct obd_uuid *cluuid,
-			   struct obd_connect_data *ocd,
-			   void *localdata);
-	int (*o_disconnect)(struct obd_export *exp);
+	int (*disconnect)(struct obd_export *exp);
 
 	/* Initialize/finalize fids infrastructure. */
-	int (*o_fid_init)(struct obd_device *obd,
-			  struct obd_export *exp, enum lu_cli_type type);
-	int (*o_fid_fini)(struct obd_device *obd);
+	int (*fid_init)(struct obd_device *obd,
+			struct obd_export *exp, enum lu_cli_type type);
+	int (*fid_fini)(struct obd_device *obd);
 
 	/* Allocate new fid according to passed @hint. */
-	int (*o_fid_alloc)(struct obd_export *exp, struct lu_fid *fid,
-			   struct md_op_data *op_data);
+	int (*fid_alloc)(struct obd_export *exp, struct lu_fid *fid,
+			 struct md_op_data *op_data);
 
 	/*
 	 * Object with @fid is getting deleted, we may want to do something
 	 * about this.
 	 */
-	int (*o_statfs)(const struct lu_env *, struct obd_export *exp,
-			struct obd_statfs *osfs, __u64 max_age, __u32 flags);
-	int (*o_statfs_async)(struct obd_export *exp, struct obd_info *oinfo,
-			      __u64 max_age, struct ptlrpc_request_set *set);
-	int (*o_packmd)(struct obd_export *exp, struct lov_mds_md **disk_tgt,
-			struct lov_stripe_md *mem_src);
-	int (*o_unpackmd)(struct obd_export *exp,
-			  struct lov_stripe_md **mem_tgt,
-			  struct lov_mds_md *disk_src, int disk_len);
-	int (*o_preallocate)(struct lustre_handle *, u32 *req, u64 *ids);
-	int (*o_create)(const struct lu_env *env, struct obd_export *exp,
-			struct obdo *oa, struct lov_stripe_md **ea,
-			struct obd_trans_info *oti);
-	int (*o_destroy)(const struct lu_env *env, struct obd_export *exp,
-			 struct obdo *oa, struct lov_stripe_md *ea,
-			 struct obd_trans_info *oti, struct obd_export *md_exp);
-	int (*o_setattr)(const struct lu_env *, struct obd_export *exp,
-			 struct obd_info *oinfo, struct obd_trans_info *oti);
-	int (*o_setattr_async)(struct obd_export *exp, struct obd_info *oinfo,
-			       struct obd_trans_info *oti,
-			       struct ptlrpc_request_set *rqset);
-	int (*o_getattr)(const struct lu_env *env, struct obd_export *exp,
-			 struct obd_info *oinfo);
-	int (*o_getattr_async)(struct obd_export *exp, struct obd_info *oinfo,
-			       struct ptlrpc_request_set *set);
-	int (*o_adjust_kms)(struct obd_export *exp, struct lov_stripe_md *lsm,
-			    u64 size, int shrink);
-	int (*o_preprw)(const struct lu_env *env, int cmd,
-			struct obd_export *exp, struct obdo *oa, int objcount,
-			struct obd_ioobj *obj, struct niobuf_remote *remote,
-			int *nr_pages, struct niobuf_local *local,
-			struct obd_trans_info *oti);
-	int (*o_commitrw)(const struct lu_env *env, int cmd,
-			  struct obd_export *exp, struct obdo *oa,
-			  int objcount, struct obd_ioobj *obj,
-			  struct niobuf_remote *remote, int pages,
-			  struct niobuf_local *local,
-			  struct obd_trans_info *oti, int rc);
-	int (*o_find_cbdata)(struct obd_export *, struct lov_stripe_md *,
-			     ldlm_iterator_t it, void *data);
-	int (*o_init_export)(struct obd_export *exp);
-	int (*o_destroy_export)(struct obd_export *exp);
+	int (*statfs)(const struct lu_env *, struct obd_export *exp,
+		      struct obd_statfs *osfs, __u64 max_age, __u32 flags);
+	int (*statfs_async)(struct obd_export *exp, struct obd_info *oinfo,
+			    __u64 max_age, struct ptlrpc_request_set *set);
+	int (*packmd)(struct obd_export *exp, struct lov_mds_md **disk_tgt,
+		      struct lov_stripe_md *mem_src);
+	int (*unpackmd)(struct obd_export *exp,
+			struct lov_stripe_md **mem_tgt,
+			struct lov_mds_md *disk_src, int disk_len);
+	int (*preallocate)(struct lustre_handle *, u32 *req, u64 *ids);
+	int (*create)(const struct lu_env *env, struct obd_export *exp,
+		      struct obdo *oa, struct lov_stripe_md **ea,
+		      struct obd_trans_info *oti);
+	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
+		       struct obdo *oa, struct lov_stripe_md *ea,
+		       struct obd_trans_info *oti, struct obd_export *md_exp);
+	int (*setattr)(const struct lu_env *, struct obd_export *exp,
+		       struct obd_info *oinfo, struct obd_trans_info *oti);
+	int (*setattr_async)(struct obd_export *exp, struct obd_info *oinfo,
+			     struct obd_trans_info *oti,
+			     struct ptlrpc_request_set *rqset);
+	int (*getattr)(const struct lu_env *env, struct obd_export *exp,
+		       struct obd_info *oinfo);
+	int (*getattr_async)(struct obd_export *exp, struct obd_info *oinfo,
+			     struct ptlrpc_request_set *set);
+	int (*adjust_kms)(struct obd_export *exp, struct lov_stripe_md *lsm,
+			  u64 size, int shrink);
+	int (*preprw)(const struct lu_env *env, int cmd,
+		      struct obd_export *exp, struct obdo *oa, int objcount,
+		      struct obd_ioobj *obj, struct niobuf_remote *remote,
+		      int *nr_pages, struct niobuf_local *local,
+		      struct obd_trans_info *oti);
+	int (*commitrw)(const struct lu_env *env, int cmd,
+			struct obd_export *exp, struct obdo *oa,
+			int objcount, struct obd_ioobj *obj,
+			struct niobuf_remote *remote, int pages,
+			struct niobuf_local *local,
+			struct obd_trans_info *oti, int rc);
+	int (*find_cbdata)(struct obd_export *, struct lov_stripe_md *,
+			   ldlm_iterator_t it, void *data);
+	int (*init_export)(struct obd_export *exp);
+	int (*destroy_export)(struct obd_export *exp);
 
 	/* metadata-only methods */
-	int (*o_import_event)(struct obd_device *, struct obd_import *,
-			      enum obd_import_event);
+	int (*import_event)(struct obd_device *, struct obd_import *,
+			    enum obd_import_event);
 
-	int (*o_notify)(struct obd_device *obd, struct obd_device *watched,
-			enum obd_notify_event ev, void *data);
+	int (*notify)(struct obd_device *obd, struct obd_device *watched,
+		      enum obd_notify_event ev, void *data);
 
-	int (*o_health_check)(const struct lu_env *env, struct obd_device *);
-	struct obd_uuid *(*o_get_uuid)(struct obd_export *exp);
+	int (*health_check)(const struct lu_env *env, struct obd_device *);
+	struct obd_uuid *(*get_uuid)(struct obd_export *exp);
 
 	/* quota methods */
-	int (*o_quotacheck)(struct obd_device *, struct obd_export *,
-			    struct obd_quotactl *);
-	int (*o_quotactl)(struct obd_device *, struct obd_export *,
+	int (*quotacheck)(struct obd_device *, struct obd_export *,
 			  struct obd_quotactl *);
+	int (*quotactl)(struct obd_device *, struct obd_export *,
+			struct obd_quotactl *);
 
 	/* pools methods */
-	int (*o_pool_new)(struct obd_device *obd, char *poolname);
-	int (*o_pool_del)(struct obd_device *obd, char *poolname);
-	int (*o_pool_add)(struct obd_device *obd, char *poolname,
-			  char *ostname);
-	int (*o_pool_rem)(struct obd_device *obd, char *poolname,
-			  char *ostname);
-	void (*o_getref)(struct obd_device *obd);
-	void (*o_putref)(struct obd_device *obd);
+	int (*pool_new)(struct obd_device *obd, char *poolname);
+	int (*pool_del)(struct obd_device *obd, char *poolname);
+	int (*pool_add)(struct obd_device *obd, char *poolname,
+			char *ostname);
+	int (*pool_rem)(struct obd_device *obd, char *poolname,
+			char *ostname);
+	void (*getref)(struct obd_device *obd);
+	void (*putref)(struct obd_device *obd);
 	/*
 	 * NOTE: If adding ops, add another LPROCFS_OBD_OP_INIT() line
 	 * to lprocfs_alloc_obd_stats() in obdclass/lprocfs_status.c.
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index bf2bde5..674be77 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -260,7 +260,7 @@ void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj);
 void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid);
 
 #define OBT(dev)	(dev)->obd_type
-#define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->o_ ## op
+#define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->op
 #define MDP(dev, op)    (dev)->obd_type->typ_md_ops->m_ ## op
 #define CTXTP(ctxt, op) (ctxt)->loc_logops->lop_##op
 
@@ -291,9 +291,9 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 }
 
 #define OBD_COUNTER_OFFSET(op)				  \
-	((offsetof(struct obd_ops, o_ ## op) -		  \
-	  offsetof(struct obd_ops, o_iocontrol))		\
-	 / sizeof(((struct obd_ops *)(0))->o_iocontrol))
+	((offsetof(struct obd_ops, op) -		  \
+	  offsetof(struct obd_ops, iocontrol))		\
+	 / sizeof(((struct obd_ops *)(0))->iocontrol))
 
 #define OBD_COUNTER_INCREMENT(obdx, op)			   \
 	if ((obdx)->obd_stats != NULL) {			  \
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 635a93c..947a127 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2744,23 +2744,23 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 }
 
 static struct obd_ops lmv_obd_ops = {
-	.o_owner		= THIS_MODULE,
-	.o_setup		= lmv_setup,
-	.o_cleanup	      = lmv_cleanup,
-	.o_precleanup	   = lmv_precleanup,
-	.o_process_config       = lmv_process_config,
-	.o_connect	      = lmv_connect,
-	.o_disconnect	   = lmv_disconnect,
-	.o_statfs	       = lmv_statfs,
-	.o_get_info	     = lmv_get_info,
-	.o_set_info_async       = lmv_set_info_async,
-	.o_packmd	       = lmv_packmd,
-	.o_unpackmd	     = lmv_unpackmd,
-	.o_notify	       = lmv_notify,
-	.o_get_uuid	     = lmv_get_uuid,
-	.o_iocontrol	    = lmv_iocontrol,
-	.o_quotacheck	   = lmv_quotacheck,
-	.o_quotactl	     = lmv_quotactl
+	.owner		= THIS_MODULE,
+	.setup		= lmv_setup,
+	.cleanup	= lmv_cleanup,
+	.precleanup	= lmv_precleanup,
+	.process_config	= lmv_process_config,
+	.connect	= lmv_connect,
+	.disconnect	= lmv_disconnect,
+	.statfs		= lmv_statfs,
+	.get_info	= lmv_get_info,
+	.set_info_async	= lmv_set_info_async,
+	.packmd		= lmv_packmd,
+	.unpackmd	= lmv_unpackmd,
+	.notify		= lmv_notify,
+	.get_uuid	= lmv_get_uuid,
+	.iocontrol	= lmv_iocontrol,
+	.quotacheck	= lmv_quotacheck,
+	.quotactl	= lmv_quotactl
 };
 
 static struct md_ops lmv_md_ops = {
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index c3be0b5..ad678d4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2280,35 +2280,35 @@ out:
 }
 
 static struct obd_ops lov_obd_ops = {
-	.o_owner	       = THIS_MODULE,
-	.o_setup	       = lov_setup,
-	.o_precleanup	  = lov_precleanup,
-	.o_cleanup	     = lov_cleanup,
-	/*.o_process_config      = lov_process_config,*/
-	.o_connect	     = lov_connect,
-	.o_disconnect	  = lov_disconnect,
-	.o_statfs	      = lov_statfs,
-	.o_statfs_async	= lov_statfs_async,
-	.o_packmd	      = lov_packmd,
-	.o_unpackmd	    = lov_unpackmd,
-	.o_create	      = lov_create,
-	.o_destroy	     = lov_destroy,
-	.o_getattr_async       = lov_getattr_async,
-	.o_setattr_async       = lov_setattr_async,
-	.o_adjust_kms	  = lov_adjust_kms,
-	.o_find_cbdata	 = lov_find_cbdata,
-	.o_iocontrol	   = lov_iocontrol,
-	.o_get_info	    = lov_get_info,
-	.o_set_info_async      = lov_set_info_async,
-	.o_notify	      = lov_notify,
-	.o_pool_new	    = lov_pool_new,
-	.o_pool_rem	    = lov_pool_remove,
-	.o_pool_add	    = lov_pool_add,
-	.o_pool_del	    = lov_pool_del,
-	.o_getref	      = lov_getref,
-	.o_putref	      = lov_putref,
-	.o_quotactl	    = lov_quotactl,
-	.o_quotacheck	  = lov_quotacheck,
+	.owner          = THIS_MODULE,
+	.setup          = lov_setup,
+	.precleanup     = lov_precleanup,
+	.cleanup        = lov_cleanup,
+	/*.process_config       = lov_process_config,*/
+	.connect        = lov_connect,
+	.disconnect     = lov_disconnect,
+	.statfs         = lov_statfs,
+	.statfs_async   = lov_statfs_async,
+	.packmd         = lov_packmd,
+	.unpackmd       = lov_unpackmd,
+	.create         = lov_create,
+	.destroy        = lov_destroy,
+	.getattr_async  = lov_getattr_async,
+	.setattr_async  = lov_setattr_async,
+	.adjust_kms     = lov_adjust_kms,
+	.find_cbdata    = lov_find_cbdata,
+	.iocontrol      = lov_iocontrol,
+	.get_info       = lov_get_info,
+	.set_info_async = lov_set_info_async,
+	.notify         = lov_notify,
+	.pool_new       = lov_pool_new,
+	.pool_rem       = lov_pool_remove,
+	.pool_add       = lov_pool_add,
+	.pool_del       = lov_pool_del,
+	.getref         = lov_getref,
+	.putref         = lov_putref,
+	.quotactl       = lov_quotactl,
+	.quotacheck     = lov_quotacheck,
 };
 
 struct kmem_cache *lov_oinfo_slab;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 16a5a10..34a8867 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2460,26 +2460,26 @@ static int mdc_get_remote_perm(struct obd_export *exp, const struct lu_fid *fid,
 }
 
 static struct obd_ops mdc_obd_ops = {
-	.o_owner	    = THIS_MODULE,
-	.o_setup	    = mdc_setup,
-	.o_precleanup       = mdc_precleanup,
-	.o_cleanup	  = mdc_cleanup,
-	.o_add_conn	 = client_import_add_conn,
-	.o_del_conn	 = client_import_del_conn,
-	.o_connect          = client_connect_import,
-	.o_disconnect       = client_disconnect_export,
-	.o_iocontrol	= mdc_iocontrol,
-	.o_set_info_async   = mdc_set_info_async,
-	.o_statfs	   = mdc_statfs,
-	.o_fid_init	    = client_fid_init,
-	.o_fid_fini	    = client_fid_fini,
-	.o_fid_alloc	= mdc_fid_alloc,
-	.o_import_event     = mdc_import_event,
-	.o_get_info	 = mdc_get_info,
-	.o_process_config   = mdc_process_config,
-	.o_get_uuid	 = mdc_get_uuid,
-	.o_quotactl	 = mdc_quotactl,
-	.o_quotacheck       = mdc_quotacheck
+	.owner          = THIS_MODULE,
+	.setup          = mdc_setup,
+	.precleanup     = mdc_precleanup,
+	.cleanup        = mdc_cleanup,
+	.add_conn       = client_import_add_conn,
+	.del_conn       = client_import_del_conn,
+	.connect        = client_connect_import,
+	.disconnect     = client_disconnect_export,
+	.iocontrol      = mdc_iocontrol,
+	.set_info_async = mdc_set_info_async,
+	.statfs         = mdc_statfs,
+	.fid_init       = client_fid_init,
+	.fid_fini       = client_fid_fini,
+	.fid_alloc      = mdc_fid_alloc,
+	.import_event   = mdc_import_event,
+	.get_info       = mdc_get_info,
+	.process_config = mdc_process_config,
+	.get_uuid       = mdc_get_uuid,
+	.quotactl       = mdc_quotactl,
+	.quotacheck     = mdc_quotacheck
 };
 
 static struct md_ops mdc_md_ops = {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 7315733..8c56cc3 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1694,20 +1694,20 @@ out:
 }
 
 static struct obd_ops mgc_obd_ops = {
-	.o_owner	= THIS_MODULE,
-	.o_setup	= mgc_setup,
-	.o_precleanup   = mgc_precleanup,
-	.o_cleanup      = mgc_cleanup,
-	.o_add_conn     = client_import_add_conn,
-	.o_del_conn     = client_import_del_conn,
-	.o_connect      = client_connect_import,
-	.o_disconnect   = client_disconnect_export,
-	/* .o_enqueue      = mgc_enqueue, */
-	/* .o_iocontrol    = mgc_iocontrol, */
-	.o_set_info_async = mgc_set_info_async,
-	.o_get_info       = mgc_get_info,
-	.o_import_event = mgc_import_event,
-	.o_process_config = mgc_process_config,
+	.owner          = THIS_MODULE,
+	.setup          = mgc_setup,
+	.precleanup     = mgc_precleanup,
+	.cleanup        = mgc_cleanup,
+	.add_conn       = client_import_add_conn,
+	.del_conn       = client_import_del_conn,
+	.connect        = client_connect_import,
+	.disconnect     = client_disconnect_export,
+	/* .enqueue     = mgc_enqueue, */
+	/* .iocontrol   = mgc_iocontrol, */
+	.set_info_async = mgc_set_info_async,
+	.get_info       = mgc_get_info,
+	.import_event   = mgc_import_event,
+	.process_config = mgc_process_config,
 };
 
 static int __init mgc_init(void)
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index ab0748b..fbbd4b5 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -132,7 +132,7 @@ static struct obd_type *class_get_type(const char *name)
 	if (type) {
 		spin_lock(&type->obd_type_lock);
 		type->typ_refcnt++;
-		try_module_get(type->typ_dt_ops->o_owner);
+		try_module_get(type->typ_dt_ops->owner);
 		spin_unlock(&type->obd_type_lock);
 	}
 	return type;
@@ -143,7 +143,7 @@ void class_put_type(struct obd_type *type)
 	LASSERT(type);
 	spin_lock(&type->obd_type_lock);
 	type->typ_refcnt--;
-	module_put(type->typ_dt_ops->o_owner);
+	module_put(type->typ_dt_ops->owner);
 	spin_unlock(&type->obd_type_lock);
 }
 EXPORT_SYMBOL(class_put_type);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index ef9cb31..5b26265 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -2128,10 +2128,10 @@ static int echo_client_disconnect(struct obd_export *exp)
 }
 
 static struct obd_ops echo_client_obd_ops = {
-	.o_owner       = THIS_MODULE,
-	.o_iocontrol   = echo_client_iocontrol,
-	.o_connect     = echo_client_connect,
-	.o_disconnect  = echo_client_disconnect
+	.owner          = THIS_MODULE,
+	.iocontrol      = echo_client_iocontrol,
+	.connect        = echo_client_connect,
+	.disconnect     = echo_client_disconnect
 };
 
 static int echo_client_init(void)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 32c9713..d2fc4fe 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -3257,33 +3257,33 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 }
 
 struct obd_ops osc_obd_ops = {
-	.o_owner		= THIS_MODULE,
-	.o_setup		= osc_setup,
-	.o_precleanup	   = osc_precleanup,
-	.o_cleanup	      = osc_cleanup,
-	.o_add_conn	     = client_import_add_conn,
-	.o_del_conn	     = client_import_del_conn,
-	.o_connect	      = client_connect_import,
-	.o_reconnect	    = osc_reconnect,
-	.o_disconnect	   = osc_disconnect,
-	.o_statfs	       = osc_statfs,
-	.o_statfs_async	 = osc_statfs_async,
-	.o_packmd	       = osc_packmd,
-	.o_unpackmd	     = osc_unpackmd,
-	.o_create	       = osc_create,
-	.o_destroy	      = osc_destroy,
-	.o_getattr	      = osc_getattr,
-	.o_getattr_async	= osc_getattr_async,
-	.o_setattr	      = osc_setattr,
-	.o_setattr_async	= osc_setattr_async,
-	.o_find_cbdata	  = osc_find_cbdata,
-	.o_iocontrol	    = osc_iocontrol,
-	.o_get_info	     = osc_get_info,
-	.o_set_info_async       = osc_set_info_async,
-	.o_import_event	 = osc_import_event,
-	.o_process_config       = osc_process_config,
-	.o_quotactl	     = osc_quotactl,
-	.o_quotacheck	   = osc_quotacheck,
+	.owner          = THIS_MODULE,
+	.setup          = osc_setup,
+	.precleanup     = osc_precleanup,
+	.cleanup        = osc_cleanup,
+	.add_conn       = client_import_add_conn,
+	.del_conn       = client_import_del_conn,
+	.connect        = client_connect_import,
+	.reconnect      = osc_reconnect,
+	.disconnect     = osc_disconnect,
+	.statfs         = osc_statfs,
+	.statfs_async   = osc_statfs_async,
+	.packmd         = osc_packmd,
+	.unpackmd       = osc_unpackmd,
+	.create         = osc_create,
+	.destroy        = osc_destroy,
+	.getattr        = osc_getattr,
+	.getattr_async  = osc_getattr_async,
+	.setattr        = osc_setattr,
+	.setattr_async  = osc_setattr_async,
+	.find_cbdata    = osc_find_cbdata,
+	.iocontrol      = osc_iocontrol,
+	.get_info       = osc_get_info,
+	.set_info_async = osc_set_info_async,
+	.import_event   = osc_import_event,
+	.process_config = osc_process_config,
+	.quotactl       = osc_quotactl,
+	.quotacheck     = osc_quotacheck,
 };
 
 extern struct lu_kmem_descr osc_caches[];
