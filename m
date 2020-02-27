From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:54 -0500
Subject: [lustre-devel] [PATCH 246/622] lustre: misc: delete
 OBD_IOC_PING_TARGET ioctl
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-247-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The OBD_IOC_PING_TARGET ioctl was removed from tool usage in
Lustre v2_5_60_0-27-g122aadd and replaced with a sysfs interface.
It is no longer needed and can be removed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6202
Lustre-commit: d17d6ef74e52 ("LU-6202 misc: delete OBD_IOC_PING_TARGET ioctl")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33691
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c              |  4 +---
 fs/lustre/obdclass/class_obd.c           |  4 ++--
 fs/lustre/osc/osc_request.c              | 25 +++++++++++--------------
 include/uapi/linux/lustre/lustre_ioctl.h |  2 +-
 4 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 80e58c8..f197abc 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2114,9 +2114,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case IOC_OSC_SET_ACTIVE:
 		rc = ptlrpc_set_import_active(imp, data->ioc_offset);
 		goto out;
-	case OBD_IOC_PING_TARGET:
-		rc = ptlrpc_obd_ping(obd);
-		goto out;
+
 	/*
 	 * Normally IOC_OBD_STATFS, OBD_IOC_QUOTACTL iocontrol are handled by
 	 * LMV instead of MDC. But when the cluster is upgraded from 1.8,
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 0435f62..373a8d2 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -510,8 +510,8 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 			    unsigned long arg)
 {
-	/* Allow non-root access for OBD_IOC_PING_TARGET - used by lfs check */
-	if (!capable(CAP_SYS_ADMIN) && (cmd != OBD_IOC_PING_TARGET))
+	/* Allow non-root access for some limited ioctls */
+	if (!capable(CAP_SYS_ADMIN))
 		return -EACCES;
 
 	if ((cmd & 0xffffff00) == ((int)'T') << 8) /* ignore all tty ioctls */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 1fc50cc..7a99ef2 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2840,7 +2840,7 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct obd_ioctl_data *data = karg;
-	int err = 0;
+	int rc = 0;
 
 	if (!try_module_get(THIS_MODULE)) {
 		CERROR("%s: cannot get module '%s'\n", obd->obd_name,
@@ -2849,27 +2849,24 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	}
 	switch (cmd) {
 	case OBD_IOC_CLIENT_RECOVER:
-		err = ptlrpc_recover_import(obd->u.cli.cl_import,
-					    data->ioc_inlbuf1, 0);
-		if (err > 0)
-			err = 0;
+		rc = ptlrpc_recover_import(obd->u.cli.cl_import,
+					   data->ioc_inlbuf1, 0);
+		if (rc > 0)
+			rc = 0;
 		goto out;
 	case IOC_OSC_SET_ACTIVE:
-		err = ptlrpc_set_import_active(obd->u.cli.cl_import,
-					       data->ioc_offset);
-		goto out;
-	case OBD_IOC_PING_TARGET:
-		err = ptlrpc_obd_ping(obd);
+		rc = ptlrpc_set_import_active(obd->u.cli.cl_import,
+					      data->ioc_offset);
 		goto out;
 	default:
-		CDEBUG(D_INODE, "unrecognised ioctl %#x by %s\n",
-		       cmd, current->comm);
-		err = -ENOTTY;
+		CDEBUG(D_INODE, "%s: unrecognised ioctl %#x by %s\n",
+		       obd->obd_name, cmd, current->comm);
+		rc = -ENOTTY;
 		goto out;
 	}
 out:
 	module_put(THIS_MODULE);
-	return err;
+	return rc;
 }
 
 int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index 8289d43..30eb120 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -162,7 +162,7 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_GETDTNAME	OBD_IOC_GETNAME
 #define OBD_IOC_LOV_GET_CONFIG	_IOWR('f', 132, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_CLIENT_RECOVER	_IOW('f', 133, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_PING_TARGET	_IOW('f', 136, OBD_IOC_DATA_TYPE)
+/* was	OBD_IOC_PING_TARGET	_IOW('f', 136, OBD_IOC_DATA_TYPE) until 2.11 */
 
 /*	OBD_IOC_DEC_FS_USE_COUNT _IO('f', 139) */
 #define OBD_IOC_NO_TRANSNO	_IOW('f', 140, OBD_IOC_DATA_TYPE)
-- 
1.8.3.1
