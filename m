From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:36 -0400
Subject: [lustre-devel] [PATCH 08/64] staging: lustre: uapi: remove
	obd_ioctl_freedata() wrapper
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Replace obd_ioctl_freedata() with direct kvfree() call.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h | 5 -----
 drivers/staging/lustre/lustre/llite/dir.c                   | 6 +++---
 drivers/staging/lustre/lustre/llite/llite_lib.c             | 3 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c                 | 8 ++++----
 drivers/staging/lustre/lustre/obdclass/class_obd.c          | 3 +--
 5 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
index 84654af..7a61a00 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -211,11 +211,6 @@ static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
 int obd_ioctl_popdata(void __user *arg, void *data, int len);
 
-static inline void obd_ioctl_freedata(char *buf, size_t len)
-{
-	kvfree(buf);
-}
-
 /*
  * OBD_IOC_DATA_TYPE is only for compatibility reasons with older
  * Linux Lustre user tools. New ioctls should NOT use this macro as
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 03a72c0..dd592d9 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1097,7 +1097,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_free;
 		}
 out_free:
-		obd_ioctl_freedata(buf, len);
+		kvfree(buf);
 		return rc;
 	}
 	case LL_IOC_LMV_SETSTRIPE: {
@@ -1147,7 +1147,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 #endif
 		rc = ll_dir_setdirstripe(inode, lum, filename, mode);
 lmv_out_free:
-		obd_ioctl_freedata(buf, len);
+		kvfree(buf);
 		return rc;
 	}
 	case LL_IOC_LMV_SET_DEFAULT_STRIPE: {
@@ -1626,7 +1626,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		rc = ll_migrate(inode, file, mdtidx, filename, namelen - 1);
 migrate_free:
-		obd_ioctl_freedata(buf, len);
+		kvfree(buf);
 
 		return rc;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5c8405c..451e4fa 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2231,8 +2231,7 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 	if (rc)
 		goto out_statfs;
 out_statfs:
-	if (buf)
-		obd_ioctl_freedata(buf, len);
+	kvfree(buf);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index f27b11f..8871624 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1087,17 +1087,17 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		data = (struct obd_ioctl_data *)buf;
 
 		if (sizeof(*desc) > data->ioc_inllen1) {
-			obd_ioctl_freedata(buf, len);
+			kvfree(buf);
 			return -EINVAL;
 		}
 
 		if (sizeof(uuidp->uuid) * count > data->ioc_inllen2) {
-			obd_ioctl_freedata(buf, len);
+			kvfree(buf);
 			return -EINVAL;
 		}
 
 		if (sizeof(__u32) * count > data->ioc_inllen3) {
-			obd_ioctl_freedata(buf, len);
+			kvfree(buf);
 			return -EINVAL;
 		}
 
@@ -1116,7 +1116,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		if (copy_to_user(uarg, buf, len))
 			rc = -EFAULT;
-		obd_ioctl_freedata(buf, len);
+		kvfree(buf);
 		break;
 	}
 	case OBD_IOC_QUOTACTL: {
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 76e1ee8..8cc1fdc 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -369,8 +369,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	}
 
  out:
-	if (buf)
-		obd_ioctl_freedata(buf, len);
+	kvfree(buf);
 	return err;
 } /* class_handle_ioctl */
 
-- 
1.8.3.1
