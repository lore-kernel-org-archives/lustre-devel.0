From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:21 -0400
Subject: [lustre-devel] [PATCH 18/38] lustre: obd: embedded struct
 lprocfs_vars in obd device
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently struct lprocfs_vars is initialized by the function
lprocfs_xxx_init_var() in many places. By initializing and
caching the obd_vars inside of the obd device we can simplify
the code greatly.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-3319
Reviewed-on: https://review.whamcloud.com/7135
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h  |  2 +-
 drivers/staging/lustre/lustre/include/obd.h             |  1 +
 drivers/staging/lustre/lustre/lmv/lmv_internal.h        |  3 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c             |  7 ++-----
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c           |  5 +++--
 drivers/staging/lustre/lustre/lov/lov_internal.h        |  3 ++-
 drivers/staging/lustre/lustre/lov/lov_obd.c             | 11 +++--------
 drivers/staging/lustre/lustre/lov/lproc_lov.c           |  5 +++--
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c           |  5 +++--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h        |  4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c         | 11 +++--------
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c           |  5 +++--
 drivers/staging/lustre/lustre/mgc/mgc_internal.h        |  3 ++-
 drivers/staging/lustre/lustre/mgc/mgc_request.c         |  4 ++--
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c |  4 ++--
 drivers/staging/lustre/lustre/osc/lproc_osc.c           |  5 +++--
 drivers/staging/lustre/lustre/osc/osc_internal.h        |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_request.c         | 13 ++++---------
 18 files changed, 43 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 495e6f5..ca4cd9a 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -453,7 +453,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
 		       void *data);
 
-int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
+int lprocfs_obd_setup(struct obd_device *obd,
 		      const struct attribute_group *attrs);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 3c0dbb6..0b071e3 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -602,6 +602,7 @@ struct obd_device {
 	struct dentry		*obd_debugfs_entry;
 	struct dentry		*obd_svc_debugfs_entry;
 	struct lprocfs_stats  *obd_svc_stats;
+	struct lprocfs_vars		*obd_vars;
 	atomic_t	   obd_evict_inprogress;
 	wait_queue_head_t	    obd_evict_inprogress_waitq;
 	struct list_head	obd_evict_list; /* protected with pet_lock */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 68a9917..3157ab9 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -157,7 +157,8 @@ struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid);
 /* lproc_lmv.c */
-void lprocfs_lmv_init_vars(struct lprocfs_static_vars *lvars);
+void lprocfs_lmv_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars);
 
 extern const struct file_operations lmv_proc_target_fops;
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 55db904..1867f6a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1254,9 +1254,9 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	spin_lock_init(&lmv->lmv_lock);
 	mutex_init(&lmv->lmv_init_mutex);
 
-	lprocfs_lmv_init_vars(&lvars);
+	lprocfs_lmv_init_vars(obd, &lvars);
 
-	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
+	lprocfs_obd_setup(obd, lvars.sysfs_vars);
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lmv_proc_target_fops);
 	rc = fld_client_init(&lmv->lmv_fld, obd->obd_name,
@@ -3098,11 +3098,8 @@ static int lmv_merge_attr(struct obd_export *exp,
 
 static int __init lmv_init(void)
 {
-	struct lprocfs_static_vars lvars;
 	int rc;
 
-	lprocfs_lmv_init_vars(&lvars);
-
 	rc = libcfs_setup();
 	if (rc)
 		return rc;
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 30727b7..bc6e13c 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -166,8 +166,9 @@ static int lmv_target_seq_open(struct inode *inode, struct file *file)
 	.attrs = lmv_attrs,
 };
 
-void lprocfs_lmv_init_vars(struct lprocfs_static_vars *lvars)
+void lprocfs_lmv_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars)
 {
+	obd->obd_vars = lprocfs_lmv_obd_vars;
 	lvars->sysfs_vars     = &lmv_attr_group;
-	lvars->obd_vars       = lprocfs_lmv_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 47042f2..e93dfd4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -241,7 +241,8 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
 
 /* lproc_lov.c */
 extern const struct file_operations lov_proc_target_fops;
-void lprocfs_lov_init_vars(struct lprocfs_static_vars *lvars);
+void lprocfs_lov_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars);
 
 /* lov_cl.c */
 extern struct lu_device_type lov_device_type;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 07f6b1b..05d097e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -769,8 +769,8 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (rc)
 		goto out;
 
-	lprocfs_lov_init_vars(&lvars);
-	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
+	lprocfs_lov_init_vars(obd, &lvars);
+	lprocfs_obd_setup(obd, lvars.sysfs_vars);
 
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lov_proc_target_fops);
@@ -872,7 +872,6 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 		goto out;
 	}
 	case LCFG_PARAM: {
-		struct lprocfs_static_vars lvars = { NULL };
 		struct lov_desc *desc = &obd->u.lov.desc;
 
 		if (!desc) {
@@ -880,9 +879,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 			goto out;
 		}
 
-		lprocfs_lov_init_vars(&lvars);
-
-		rc = class_process_proc_param(PARAM_LOV, lvars.obd_vars,
+		rc = class_process_proc_param(PARAM_LOV, obd->obd_vars,
 					      lcfg, obd);
 		if (rc > 0)
 			rc = 0;
@@ -1356,7 +1353,6 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 
 static int __init lov_init(void)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	int rc;
 
 	/* print an address of _any_ initialized kernel symbol from this
@@ -1380,7 +1376,6 @@ static int __init lov_init(void)
 		lu_kmem_fini(lov_caches);
 		return -ENOMEM;
 	}
-	lprocfs_lov_init_vars(&lvars);
 
 	rc = class_register_type(&lov_obd_ops, NULL,
 				 LUSTRE_LOV_NAME, &lov_device_type);
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index 721440f..317c154 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -284,10 +284,11 @@ static int lov_target_seq_open(struct inode *inode, struct file *file)
 	.attrs = lov_attrs,
 };
 
-void lprocfs_lov_init_vars(struct lprocfs_static_vars *lvars)
+void lprocfs_lov_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars)
 {
+	obd->obd_vars = lprocfs_lov_obd_vars;
 	lvars->sysfs_vars = &lov_attr_group;
-	lvars->obd_vars = lprocfs_lov_obd_vars;
 }
 
 const struct file_operations lov_proc_target_fops = {
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 6cce324..bf92893 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -224,8 +224,9 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 	.attrs = mdc_attrs,
 };
 
-void lprocfs_mdc_init_vars(struct lprocfs_static_vars *lvars)
+void lprocfs_mdc_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars)
 {
+	obd->obd_vars = lprocfs_mdc_obd_vars;
 	lvars->sysfs_vars   = &mdc_attr_group;
-	lvars->obd_vars     = lprocfs_mdc_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index f19b0ce..20be240 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -36,8 +36,8 @@
 
 #include <lustre_mdc.h>
 
-void lprocfs_mdc_init_vars(struct lprocfs_static_vars *lvars);
-
+void lprocfs_mdc_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars);
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags);
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index a759da2..8a90dab 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2648,8 +2648,8 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	if (rc)
 		goto err_ptlrpcd_decref;
 
-	lprocfs_mdc_init_vars(&lvars);
-	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
+	lprocfs_mdc_init_vars(obd, &lvars);
+	lprocfs_obd_setup(obd, lvars.sysfs_vars);
 	sptlrpc_lprocfs_cliobd_attach(obd);
 	ptlrpc_lprocfs_register_obd(obd);
 
@@ -2716,13 +2716,11 @@ static int mdc_cleanup(struct obd_device *obd)
 static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 {
 	struct lustre_cfg *lcfg = buf;
-	struct lprocfs_static_vars lvars = { NULL };
 	int rc = 0;
 
-	lprocfs_mdc_init_vars(&lvars);
 	switch (lcfg->lcfg_command) {
 	default:
-		rc = class_process_proc_param(PARAM_MDC, lvars.obd_vars,
+		rc = class_process_proc_param(PARAM_MDC, obd->obd_vars,
 					      lcfg, obd);
 		if (rc > 0)
 			rc = 0;
@@ -2784,15 +2782,12 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 
 static int __init mdc_init(void)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	int rc;
 
 	rc = libcfs_setup();
 	if (rc)
 		return rc;
 
-	lprocfs_mdc_init_vars(&lvars);
-
 	return class_register_type(&mdc_obd_ops, &mdc_md_ops,
 				 LUSTRE_MDC_NAME, NULL);
 }
diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
index 6367706..e92787d 100644
--- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
+++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
@@ -63,7 +63,8 @@ static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
 	{ NULL }
 };
 
-void lprocfs_mgc_init_vars(struct lprocfs_static_vars *lvars)
+void lprocfs_mgc_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars)
 {
-	lvars->obd_vars    = lprocfs_mgc_obd_vars;
+	obd->obd_vars    = lprocfs_mgc_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 9541892..400d52c 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -39,7 +39,8 @@
 #include <lustre_log.h>
 #include <lustre_export.h>
 
-void lprocfs_mgc_init_vars(struct lprocfs_static_vars *lvars);
+void lprocfs_mgc_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars);
 int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data);
 
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld);
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 833e6a0..6c769c6 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -748,8 +748,8 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto err_cleanup;
 	}
 
-	lprocfs_mgc_init_vars(&lvars);
-	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
+	lprocfs_mgc_init_vars(obd, &lvars);
+	lprocfs_obd_setup(obd, lvars.sysfs_vars);
 	sptlrpc_lprocfs_cliobd_attach(obd);
 
 	if (atomic_inc_return(&mgc_count) == 1) {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 3776447..c032458 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1014,7 +1014,7 @@ static void obd_sysfs_release(struct kobject *kobj)
 	.release	= obd_sysfs_release,
 };
 
-int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
+int lprocfs_obd_setup(struct obd_device *obd,
 		      const struct attribute_group *attrs)
 {
 	int rc = 0;
@@ -1036,7 +1036,7 @@ int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
 
 	obd->obd_debugfs_entry = debugfs_create_dir(obd->obd_name,
 					obd->obd_type->typ_debugfs_entry);
-	ldebugfs_add_vars(obd->obd_debugfs_entry, list, obd);
+	ldebugfs_add_vars(obd->obd_debugfs_entry, obd->obd_vars, obd);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 54a303e..1492ad9 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -824,8 +824,9 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	.attrs = osc_attrs,
 };
 
-void lprocfs_osc_init_vars(struct lprocfs_static_vars *lvars)
+void lprocfs_osc_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars)
 {
 	lvars->sysfs_vars  = &osc_attr_group;
-	lvars->obd_vars    = lprocfs_osc_obd_vars;
+	obd->obd_vars = lprocfs_osc_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 02e8318..a762d31 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -146,7 +146,8 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
 
 void lproc_osc_attach_seqstat(struct obd_device *dev);
-void lprocfs_osc_init_vars(struct lprocfs_static_vars *lvars);
+void lprocfs_osc_init_vars(struct obd_device *obd,
+			   struct lprocfs_static_vars *lvars);
 
 extern struct lu_device_type osc_device_type;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index b2b55a7..9c226f0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2803,8 +2803,9 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto out_ptlrpcd_work;
 
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
-	lprocfs_osc_init_vars(&lvars);
-	if (lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars) == 0) {
+
+	lprocfs_osc_init_vars(obd, &lvars);
+	if (lprocfs_obd_setup(obd, lvars.sysfs_vars) == 0) {
 		lproc_osc_attach_seqstat(obd);
 		sptlrpc_lprocfs_cliobd_attach(obd);
 		ptlrpc_lprocfs_register_obd(obd);
@@ -2911,14 +2912,11 @@ static int osc_cleanup(struct obd_device *obd)
 
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	int rc = 0;
 
-	lprocfs_osc_init_vars(&lvars);
-
 	switch (lcfg->lcfg_command) {
 	default:
-		rc = class_process_proc_param(PARAM_OSC, lvars.obd_vars,
+		rc = class_process_proc_param(PARAM_OSC, obd->obd_vars,
 					      lcfg, obd);
 		if (rc > 0)
 			rc = 0;
@@ -2967,7 +2965,6 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 
 static int __init osc_init(void)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	unsigned int reqpool_size;
 	unsigned int reqsize;
 	int rc;
@@ -2986,8 +2983,6 @@ static int __init osc_init(void)
 	if (rc)
 		return rc;
 
-	lprocfs_osc_init_vars(&lvars);
-
 	rc = register_shrinker(&osc_cache_shrinker);
 	if (rc)
 		goto err;
-- 
1.8.3.1
