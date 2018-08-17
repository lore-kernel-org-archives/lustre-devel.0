From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:24 -0400
Subject: [lustre-devel] [PATCH 21/38] lustre: obdclass: add light weight
 obd_def_uuid_attrs
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It was assumed that all obd devices supported every attribute
in obd_def_attrs but that is not true. Several obd devices only
have a uuid sysfs file. Add an option to lprocfs_obd_setup()
to select the proper obd_def_attrs.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/26020
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h    |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c           |  2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c           |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c       |  2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c       |  2 +-
 .../staging/lustre/lustre/obdclass/lprocfs_status.c   | 19 ++++++++++++++++---
 drivers/staging/lustre/lustre/osc/osc_request.c       |  2 +-
 7 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 358ace3..f428ce0 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -453,7 +453,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
 		       void *data);
 
-int lprocfs_obd_setup(struct obd_device *obd);
+int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 
 /* Generic callbacks */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 212ca31..c36ecb7 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1255,7 +1255,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	lprocfs_lmv_init_vars(obd);
 
-	lprocfs_obd_setup(obd);
+	lprocfs_obd_setup(obd, true);
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lmv_proc_target_fops);
 	rc = fld_client_init(&lmv->lmv_fld, obd->obd_name,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 43ebec6..751bf64 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -769,7 +769,7 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto out;
 
 	lprocfs_lov_init_vars(obd);
-	lprocfs_obd_setup(obd);
+	lprocfs_obd_setup(obd, false);
 
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lov_proc_target_fops);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index a3c0461f..fcba599 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2648,7 +2648,7 @@ static int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 		goto err_ptlrpcd_decref;
 
 	lprocfs_mdc_init_vars(obd);
-	lprocfs_obd_setup(obd);
+	lprocfs_obd_setup(obd, false);
 	sptlrpc_lprocfs_cliobd_attach(obd);
 	ptlrpc_lprocfs_register_obd(obd);
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 46b1e36..50da9cf 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -748,7 +748,7 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 
 	lprocfs_mgc_init_vars(obd);
-	lprocfs_obd_setup(obd);
+	lprocfs_obd_setup(obd, true);
 	sptlrpc_lprocfs_cliobd_attach(obd);
 
 	if (atomic_inc_return(&mgc_count) == 1) {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index a5676ff..91d37fc 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -989,6 +989,11 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 }
 EXPORT_SYMBOL(lprocfs_rd_connect_flags);
 
+static const struct attribute *obd_def_uuid_attrs[] = {
+	&lustre_attr_uuid.attr,
+	NULL,
+};
+
 static const struct attribute *obd_def_attrs[] = {
 	&lustre_attr_blocksize.attr,
 	&lustre_attr_kbytestotal.attr,
@@ -1008,7 +1013,7 @@ static void obd_sysfs_release(struct kobject *kobj)
 	complete(&obd->obd_kobj_unregister);
 }
 
-int lprocfs_obd_setup(struct obd_device *obd)
+int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
 {
 	int rc;
 
@@ -1022,7 +1027,12 @@ int lprocfs_obd_setup(struct obd_device *obd)
 	if (rc)
 		return rc;
 
-	rc = sysfs_create_files(&obd->obd_kobj, obd_def_attrs);
+	if (uuid_only)
+		obd->obd_attrs = obd_def_uuid_attrs;
+	else
+		obd->obd_attrs = obd_def_attrs;
+
+	rc = sysfs_create_files(&obd->obd_kobj, obd->obd_attrs);
 	if (rc) {
 		kobject_put(&obd->obd_kobj);
 		return rc;
@@ -1043,7 +1053,10 @@ int lprocfs_obd_cleanup(struct obd_device *obd)
 
 	debugfs_remove_recursive(obd->obd_debugfs_entry);
 
-	sysfs_remove_files(&obd->obd_kobj, obd_def_attrs);
+	if (obd->obd_attrs) {
+		sysfs_remove_files(&obd->obd_kobj, obd->obd_attrs);
+		obd->obd_attrs = NULL;
+	}
 
 	kobject_put(&obd->obd_kobj);
 	wait_for_completion(&obd->obd_kobj_unregister);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0472165..4f57a8e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2804,7 +2804,7 @@ int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
 
 	lprocfs_osc_init_vars(obd);
-	if (lprocfs_obd_setup(obd) == 0) {
+	if (lprocfs_obd_setup(obd, false) == 0) {
 		lproc_osc_attach_seqstat(obd);
 		sptlrpc_lprocfs_cliobd_attach(obd);
 		ptlrpc_lprocfs_register_obd(obd);
-- 
1.8.3.1
