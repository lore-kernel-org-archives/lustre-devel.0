From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:23 -0400
Subject: [lustre-devel] [PATCH 20/38] lustre: obdclass: embedded attributes
 in struct obd_device
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We can further simplify lprocfs_obd_setup() by embedding
the obd devices attributes in struct obd_device.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/28948
Reviewed-on: https://review.whamcloud.com/32377
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h  |  3 +--
 drivers/staging/lustre/lustre/include/obd.h             |  2 ++
 drivers/staging/lustre/lustre/lmv/lmv_internal.h        |  3 +--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c             |  5 ++---
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c           |  9 ++-------
 drivers/staging/lustre/lustre/lov/lov_internal.h        |  3 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c             |  5 ++---
 drivers/staging/lustre/lustre/lov/lproc_lov.c           |  5 ++---
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c           |  9 ++-------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h        |  3 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c         |  5 ++---
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c           |  5 ++---
 drivers/staging/lustre/lustre/mgc/mgc_internal.h        |  3 +--
 drivers/staging/lustre/lustre/mgc/mgc_request.c         |  5 ++---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 16 ++++++----------
 drivers/staging/lustre/lustre/osc/lproc_osc.c           |  9 ++-------
 drivers/staging/lustre/lustre/osc/osc_internal.h        |  3 +--
 drivers/staging/lustre/lustre/osc/osc_request.c         |  5 ++---
 18 files changed, 34 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index ca4cd9a..358ace3 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -453,8 +453,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
 		       void *data);
 
-int lprocfs_obd_setup(struct obd_device *obd,
-		      const struct attribute_group *attrs);
+int lprocfs_obd_setup(struct obd_device *obd);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 
 /* Generic callbacks */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 0b071e3..55aa035 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -602,6 +602,7 @@ struct obd_device {
 	struct dentry		*obd_debugfs_entry;
 	struct dentry		*obd_svc_debugfs_entry;
 	struct lprocfs_stats  *obd_svc_stats;
+	const struct attribute	       **obd_attrs;
 	struct lprocfs_vars		*obd_vars;
 	atomic_t	   obd_evict_inprogress;
 	wait_queue_head_t	    obd_evict_inprogress_waitq;
@@ -623,6 +624,7 @@ struct obd_device {
 	struct lu_ref	  obd_reference;
 
 	struct kobject		obd_kobj; /* sysfs object */
+	struct kobj_type		obd_ktype;
 	struct completion	obd_kobj_unregister;
 };
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 3157ab9..1b51dfb 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -157,8 +157,7 @@ struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid);
 /* lproc_lmv.c */
-void lprocfs_lmv_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars);
+void lprocfs_lmv_init_vars(struct obd_device *obd);
 
 extern const struct file_operations lmv_proc_target_fops;
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 1867f6a..212ca31 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1224,7 +1224,6 @@ int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	struct lmv_obd	     *lmv = &obd->u.lmv;
-	struct lprocfs_static_vars  lvars = { NULL };
 	struct lmv_desc	    *desc;
 	int			 rc;
 
@@ -1254,9 +1253,9 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	spin_lock_init(&lmv->lmv_lock);
 	mutex_init(&lmv->lmv_init_mutex);
 
-	lprocfs_lmv_init_vars(obd, &lvars);
+	lprocfs_lmv_init_vars(obd);
 
-	lprocfs_obd_setup(obd, lvars.sysfs_vars);
+	lprocfs_obd_setup(obd);
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lmv_proc_target_fops);
 	rc = fld_client_init(&lmv->lmv_fld, obd->obd_name,
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index bc6e13c..c54227d 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -162,13 +162,8 @@ static int lmv_target_seq_open(struct inode *inode, struct file *file)
 	NULL,
 };
 
-static const struct attribute_group lmv_attr_group = {
-	.attrs = lmv_attrs,
-};
-
-void lprocfs_lmv_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars)
+void lprocfs_lmv_init_vars(struct obd_device *obd)
 {
 	obd->obd_vars = lprocfs_lmv_obd_vars;
-	lvars->sysfs_vars     = &lmv_attr_group;
+	obd->obd_ktype.default_attrs = lmv_attrs;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index e93dfd4..7e0b9ac 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -241,8 +241,7 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
 
 /* lproc_lov.c */
 extern const struct file_operations lov_proc_target_fops;
-void lprocfs_lov_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars);
+void lprocfs_lov_init_vars(struct obd_device *obd);
 
 /* lov_cl.c */
 extern struct lu_device_type lov_device_type;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 05d097e..43ebec6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -718,7 +718,6 @@ void lov_fix_desc(struct lov_desc *desc)
 
 int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	struct lov_desc *desc;
 	struct lov_obd *lov = &obd->u.lov;
 	int rc;
@@ -769,8 +768,8 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (rc)
 		goto out;
 
-	lprocfs_lov_init_vars(obd, &lvars);
-	lprocfs_obd_setup(obd, lvars.sysfs_vars);
+	lprocfs_lov_init_vars(obd);
+	lprocfs_obd_setup(obd);
 
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lov_proc_target_fops);
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index 317c154..ca86f16 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -284,11 +284,10 @@ static int lov_target_seq_open(struct inode *inode, struct file *file)
 	.attrs = lov_attrs,
 };
 
-void lprocfs_lov_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars)
+void lprocfs_lov_init_vars(struct obd_device *obd)
 {
 	obd->obd_vars = lprocfs_lov_obd_vars;
-	lvars->sysfs_vars = &lov_attr_group;
+	obd->obd_ktype.default_attrs = lov_attrs;
 }
 
 const struct file_operations lov_proc_target_fops = {
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index bf92893..fc5f3a3 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -220,13 +220,8 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 	NULL,
 };
 
-static const struct attribute_group mdc_attr_group = {
-	.attrs = mdc_attrs,
-};
-
-void lprocfs_mdc_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars)
+void lprocfs_mdc_init_vars(struct obd_device *obd)
 {
+	obd->obd_ktype.default_attrs = mdc_attrs;
 	obd->obd_vars = lprocfs_mdc_obd_vars;
-	lvars->sysfs_vars   = &mdc_attr_group;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 20be240..d66663f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -36,8 +36,7 @@
 
 #include <lustre_mdc.h>
 
-void lprocfs_mdc_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars);
+void lprocfs_mdc_init_vars(struct obd_device *obd);
 void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 		   __u64 valid, size_t ea_size, __u32 suppgid, u32 flags);
 void mdc_swap_layouts_pack(struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 8a90dab..a3c0461f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2637,7 +2637,6 @@ static void mdc_llog_finish(struct obd_device *obd)
 
 static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	int rc;
 
 	rc = ptlrpcd_addref();
@@ -2648,8 +2647,8 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	if (rc)
 		goto err_ptlrpcd_decref;
 
-	lprocfs_mdc_init_vars(obd, &lvars);
-	lprocfs_obd_setup(obd, lvars.sysfs_vars);
+	lprocfs_mdc_init_vars(obd);
+	lprocfs_obd_setup(obd);
 	sptlrpc_lprocfs_cliobd_attach(obd);
 	ptlrpc_lprocfs_register_obd(obd);
 
diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
index e92787d..7951ec6 100644
--- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
+++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
@@ -63,8 +63,7 @@ static int mgc_ir_state_seq_show(struct seq_file *m, void *v)
 	{ NULL }
 };
 
-void lprocfs_mgc_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars)
+void lprocfs_mgc_init_vars(struct obd_device *obd)
 {
-	obd->obd_vars    = lprocfs_mgc_obd_vars;
+	obd->obd_vars = lprocfs_mgc_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 400d52c..5385d91 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -39,8 +39,7 @@
 #include <lustre_log.h>
 #include <lustre_export.h>
 
-void lprocfs_mgc_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars);
+void lprocfs_mgc_init_vars(struct obd_device *obd);
 int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data);
 
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld);
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 6c769c6..46b1e36 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -730,7 +730,6 @@ static int mgc_cleanup(struct obd_device *obd)
 
 static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	struct task_struct *task;
 	int rc;
 
@@ -748,8 +747,8 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto err_cleanup;
 	}
 
-	lprocfs_mgc_init_vars(obd, &lvars);
-	lprocfs_obd_setup(obd, lvars.sysfs_vars);
+	lprocfs_mgc_init_vars(obd);
+	lprocfs_obd_setup(obd);
 	sptlrpc_lprocfs_cliobd_attach(obd);
 
 	if (atomic_inc_return(&mgc_count) == 1) {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index d370fbb..a5676ff 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1008,19 +1008,15 @@ static void obd_sysfs_release(struct kobject *kobj)
 	complete(&obd->obd_kobj_unregister);
 }
 
-static struct kobj_type obd_ktype = {
-	.sysfs_ops	= &lustre_sysfs_ops,
-	.release	= obd_sysfs_release,
-};
-
-int lprocfs_obd_setup(struct obd_device *obd,
-		      const struct attribute_group *attrs)
+int lprocfs_obd_setup(struct obd_device *obd)
 {
-	int rc = 0;
+	int rc;
+
+	obd->obd_ktype.sysfs_ops = &lustre_sysfs_ops;
+	obd->obd_ktype.release = obd_sysfs_release;
 
-	obd_ktype.default_attrs = attrs->attrs;
 	init_completion(&obd->obd_kobj_unregister);
-	rc = kobject_init_and_add(&obd->obd_kobj, &obd_ktype,
+	rc = kobject_init_and_add(&obd->obd_kobj, &obd->obd_ktype,
 				  obd->obd_type->typ_kobj,
 				  "%s", obd->obd_name);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 1492ad9..3bcb36b 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -820,13 +820,8 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	NULL,
 };
 
-static const struct attribute_group osc_attr_group = {
-	.attrs = osc_attrs,
-};
-
-void lprocfs_osc_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars)
+void lprocfs_osc_init_vars(struct obd_device *obd)
 {
-	lvars->sysfs_vars  = &osc_attr_group;
+	obd->obd_ktype.default_attrs = osc_attrs;
 	obd->obd_vars = lprocfs_osc_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index a762d31..6caabdb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -146,8 +146,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
 
 void lproc_osc_attach_seqstat(struct obd_device *dev);
-void lprocfs_osc_init_vars(struct obd_device *obd,
-			   struct lprocfs_static_vars *lvars);
+void lprocfs_osc_init_vars(struct obd_device *obd);
 
 extern struct lu_device_type osc_device_type;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 9c226f0..0472165 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2767,7 +2767,6 @@ static int brw_queue_work(const struct lu_env *env, void *data)
 
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
-	struct lprocfs_static_vars lvars = { NULL };
 	struct client_obd *cli = &obd->u.cli;
 	void *handler;
 	int rc;
@@ -2804,8 +2803,8 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
 
-	lprocfs_osc_init_vars(obd, &lvars);
-	if (lprocfs_obd_setup(obd, lvars.sysfs_vars) == 0) {
+	lprocfs_osc_init_vars(obd);
+	if (lprocfs_obd_setup(obd) == 0) {
 		lproc_osc_attach_seqstat(obd);
 		sptlrpc_lprocfs_cliobd_attach(obd);
 		ptlrpc_lprocfs_register_obd(obd);
-- 
1.8.3.1
