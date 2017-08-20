From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:03 -0400
Subject: [lustre-devel] [PATCH 09/64 v2] staging: lustre: uapi: remove
	obd_ioctl_popdata() wrapper
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Replace obd_ioctl_popdata() with direct copy_to_user() call.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_ioctl.h        |  1 -
 drivers/staging/lustre/lustre/obdclass/class_obd.c     | 18 +++++++-----------
 .../lustre/lustre/obdclass/linux/linux-module.c        |  8 --------
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
index 7a61a00..da9a071 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
@@ -209,7 +209,6 @@ static inline int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 }
 
 int obd_ioctl_getdata(char **buf, int *len, void __user *arg);
-int obd_ioctl_popdata(void __user *arg, void *data, int len);
 
 /*
  * OBD_IOC_DATA_TYPE is only for compatibility reasons with older
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 8cc1fdc..477d611 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -206,8 +206,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		memcpy(data->ioc_bulk, LUSTRE_VERSION_STRING,
 		       strlen(LUSTRE_VERSION_STRING) + 1);
 
-		err = obd_ioctl_popdata((void __user *)arg, data, len);
-		if (err)
+		if (copy_to_user((void __user *)arg, data, len))
 			err = -EFAULT;
 		goto out;
 
@@ -225,9 +224,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			goto out;
 		}
 
-		err = obd_ioctl_popdata((void __user *)arg, data,
-					sizeof(*data));
-		if (err)
+		if (copy_to_user((void __user *)arg, data, sizeof(*data)))
 			err = -EFAULT;
 		goto out;
 	}
@@ -263,8 +260,8 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 
 		CDEBUG(D_IOCTL, "device name %s, dev %d\n", data->ioc_inlbuf1,
 		       dev);
-		err = obd_ioctl_popdata((void __user *)arg, data,
-					sizeof(*data));
+
+		if (copy_to_user((void __user *)arg, data, sizeof(*data)))
 		if (err)
 			err = -EFAULT;
 		goto out;
@@ -304,9 +301,9 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			 (int)index, status, obd->obd_type->typ_name,
 			 obd->obd_name, obd->obd_uuid.uuid,
 			 atomic_read(&obd->obd_refcount));
-		err = obd_ioctl_popdata((void __user *)arg, data, len);
 
-		err = 0;
+		if (copy_to_user((void __user *)arg, data, len))
+			err = -EFAULT;
 		goto out;
 	}
 	}
@@ -361,8 +358,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		if (err)
 			goto out;
 
-		err = obd_ioctl_popdata((void __user *)arg, data, len);
-		if (err)
+		if (copy_to_user((void __user *)arg, data, len))
 			err = -EFAULT;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index eb88bd9..3a394d2 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -151,14 +151,6 @@ int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 }
 EXPORT_SYMBOL(obd_ioctl_getdata);
 
-int obd_ioctl_popdata(void __user *arg, void *data, int len)
-{
-	int err;
-
-	err = copy_to_user(arg, data, len) ? -EFAULT : 0;
-	return err;
-}
-
 /*  opening /dev/obd */
 static int obd_class_open(struct inode *inode, struct file *file)
 {
-- 
1.8.3.1
