From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:10 -0400
Subject: [lustre-devel] [PATCH 20/28] lustre: obdclass: deprecate
 OBD_GET_VERSION ioctl
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Mark OBD_GET_VERSION ioctl deprecated, disable before 3.1 release.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-5969
Reviewed-on: https://review.whamcloud.com/26440
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 2103d2a..c4d820a 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -364,7 +364,15 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		goto out;
 	}
 
-	case OBD_GET_VERSION:
+	case OBD_GET_VERSION: {
+		static bool warned;
+
+		/* This was the method to pass to user land the lustre version.
+		 * Today that information is in the sysfs tree so we can in the
+		 * future remove this.
+		 */
+		BUILD_BUG_ON(OBD_OCD_VERSION(3, 0, 53, 0) <= LUSTRE_VERSION_CODE);
+
 		if (!data->ioc_inlbuf1) {
 			CERROR("No buffer passed in ioctl\n");
 			err = -EINVAL;
@@ -377,13 +385,19 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			goto out;
 		}
 
+		if (!warned) {
+			warned = true;
+			CWARN("%s: ioctl(OBD_GET_VERSION) is deprecated, use llapi_get_version_string() and/or relink\n",
+			      current->comm);
+		}
+
 		memcpy(data->ioc_bulk, LUSTRE_VERSION_STRING,
 		       strlen(LUSTRE_VERSION_STRING) + 1);
 
 		if (copy_to_user((void __user *)arg, data, len))
 			err = -EFAULT;
 		goto out;
-
+	}
 	case OBD_IOC_NAME2DEV: {
 		/* Resolve a device name.  This does not change the
 		 * currently selected device.
-- 
1.8.3.1
