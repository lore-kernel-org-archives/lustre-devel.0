From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:30 -0500
Subject: [lustre-devel] [PATCH 222/622] lustre: obd: use ldo_process_config
 for mdc and osc layer
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-223-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Both the mdc and osc layer use the lu_device infrastructure but
we don't use ldo_process_config() which is preferred over the
currently used obd_process_config() handling. Migrate to the
lu_device ldo_process_config() for both mdc and osc layer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9855
Lustre-commit: d12959c69fd4 ("LU-9855 obd: use ldo_process_config for mdc and osc layer")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34106
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c      | 11 +++++++----
 fs/lustre/mdc/mdc_internal.h |  1 -
 fs/lustre/mdc/mdc_request.c  | 11 -----------
 fs/lustre/osc/osc_dev.c      | 11 +++++++----
 fs/lustre/osc/osc_request.c  | 14 --------------
 5 files changed, 14 insertions(+), 34 deletions(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 306b917..f23f6cf 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -35,6 +35,7 @@
 
 #include <obd_class.h>
 #include <lustre_osc.h>
+#include <uapi/linux/lustre/lustre_param.h>
 
 #include "mdc_internal.h"
 
@@ -1422,15 +1423,17 @@ struct lu_object *mdc_object_alloc(const struct lu_env *env,
 	return obj;
 }
 
-static int mdc_cl_process_config(const struct lu_env *env,
-				 struct lu_device *d, struct lustre_cfg *cfg)
+static int mdc_process_config(const struct lu_env *env, struct lu_device *d,
+			      struct lustre_cfg *cfg)
 {
-	return mdc_process_config(d->ld_obd, 0, cfg);
+	size_t count  = class_modify_config(cfg, PARAM_MDC,
+					    &d->ld_obd->obd_kset.kobj);
+	return count > 0 ? 0 : count;
 }
 
 const struct lu_device_operations mdc_lu_ops = {
 	.ldo_object_alloc	= mdc_object_alloc,
-	.ldo_process_config	= mdc_cl_process_config,
+	.ldo_process_config	= mdc_process_config,
 	.ldo_recovery_complete	= NULL,
 };
 
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 7a6ec81..a5fe164 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -93,7 +93,6 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 int mdc_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
 int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg);
-int mdc_process_config(struct obd_device *obd, u32 len, void *buf);
 
 struct obd_client_handle;
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 4711288..c08a6ee 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -51,7 +51,6 @@
 #include <lustre_kernelcomm.h>
 #include <lustre_lmv.h>
 #include <lustre_log.h>
-#include <uapi/linux/lustre/lustre_param.h>
 #include <lustre_swab.h>
 #include <obd_class.h>
 #include <lustre_osc.h>
@@ -2743,15 +2742,6 @@ static int mdc_cleanup(struct obd_device *obd)
 	return osc_cleanup_common(obd);
 }
 
-int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
-{
-	struct lustre_cfg *lcfg = buf;
-	size_t count  = class_modify_config(lcfg, PARAM_MDC,
-					    &obd->obd_kset.kobj);
-
-	return count > 0 ? 0 : count;
-}
-
 static const struct obd_ops mdc_obd_ops = {
 	.owner			= THIS_MODULE,
 	.setup			= mdc_setup,
@@ -2770,7 +2760,6 @@ int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.fid_alloc		= mdc_fid_alloc,
 	.import_event		= mdc_import_event,
 	.get_info		= mdc_get_info,
-	.process_config		= mdc_process_config,
 	.get_uuid		= mdc_get_uuid,
 	.quotactl		= mdc_quotactl,
 };
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index b8bf75a..6469973 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -40,6 +40,7 @@
 /* class_name2obd() */
 #include <obd_class.h>
 #include <lustre_osc.h>
+#include <uapi/linux/lustre/lustre_param.h>
 
 #include "osc_internal.h"
 
@@ -161,15 +162,17 @@ struct lu_context_key osc_session_key = {
 /* type constructor/destructor: osc_type_{init,fini,start,stop}(). */
 LU_TYPE_INIT_FINI(osc, &osc_key, &osc_session_key);
 
-static int osc_cl_process_config(const struct lu_env *env,
-				 struct lu_device *d, struct lustre_cfg *cfg)
+static int osc_process_config(const struct lu_env *env, struct lu_device *d,
+			      struct lustre_cfg *cfg)
 {
-	return osc_process_config_base(d->ld_obd, cfg);
+	ssize_t count  = class_modify_config(cfg, PARAM_OSC,
+					     &d->ld_obd->obd_kset.kobj);
+	return count > 0 ? 0 : count;
 }
 
 static const struct lu_device_operations osc_lu_ops = {
 	.ldo_object_alloc	= osc_object_alloc,
-	.ldo_process_config	= osc_cl_process_config,
+	.ldo_process_config	= osc_process_config,
 	.ldo_recovery_complete	= NULL
 };
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 6ce22c3..c55d5a9 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -47,7 +47,6 @@
 #include <lprocfs_status.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <lustre_obdo.h>
-#include <uapi/linux/lustre/lustre_param.h>
 #include <lustre_fid.h>
 #include <obd_class.h>
 #include <obd.h>
@@ -3348,18 +3347,6 @@ int osc_cleanup_common(struct obd_device *obd)
 }
 EXPORT_SYMBOL(osc_cleanup_common);
 
-int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg)
-{
-	ssize_t count  = class_modify_config(lcfg, PARAM_OSC,
-					     &obd->obd_kset.kobj);
-	return count > 0 ? 0 : count;
-}
-
-static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
-{
-	return osc_process_config_base(obd, buf);
-}
-
 static const struct obd_ops osc_obd_ops = {
 	.owner		= THIS_MODULE,
 	.setup		= osc_setup,
@@ -3379,7 +3366,6 @@ static int osc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.iocontrol	= osc_iocontrol,
 	.set_info_async	= osc_set_info_async,
 	.import_event	= osc_import_event,
-	.process_config	= osc_process_config,
 	.quotactl	= osc_quotactl,
 };
 
-- 
1.8.3.1
