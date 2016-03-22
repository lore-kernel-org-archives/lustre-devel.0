From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:06 -0400
Subject: [lustre-devel] [PATCH 19/29] staging:lustre: remove
	libcfs_psdev_[open|release]
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>

From: Parinay Kondekar <parinay.kondekar@seagate.com>

With struct libcfs_device_userstate gone we can remove
the remaining code of libcfs_psdev_ops.p_[open|close]
as well as the libcfs_psdev_[open|release] functions.

Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
Reviewed-on: http://review.whamcloud.com/17492
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 -
 .../lustre/lnet/libcfs/linux/linux-module.c        |   32 +-------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |   16 ----------
 3 files changed, 1 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 0ce52de..5d228e5 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -73,8 +73,6 @@ struct cfs_psdev_file {
 };
 
 struct cfs_psdev_ops {
-	int (*p_open)(unsigned long, void *);
-	int (*p_close)(unsigned long, void *);
 	int (*p_read)(struct cfs_psdev_file *, char *, unsigned long);
 	int (*p_write)(struct cfs_psdev_file *, char *, unsigned long);
 	int (*p_ioctl)(struct cfs_psdev_file *, unsigned long, void __user *);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index d801d87..633d76b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -95,35 +95,6 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 	return err;
 }
 
-static int
-libcfs_psdev_open(struct inode *inode, struct file *file)
-{
-	int    rc = 0;
-
-	if (!inode)
-		return -EINVAL;
-	if (libcfs_psdev_ops.p_open)
-		rc = libcfs_psdev_ops.p_open(0, NULL);
-	else
-		return -EPERM;
-	return rc;
-}
-
-/* called when closing /dev/device */
-static int
-libcfs_psdev_release(struct inode *inode, struct file *file)
-{
-	int    rc = 0;
-
-	if (!inode)
-		return -EINVAL;
-	if (libcfs_psdev_ops.p_close)
-		rc = libcfs_psdev_ops.p_close(0, NULL);
-	else
-		rc = -EPERM;
-	return rc;
-}
-
 static long libcfs_ioctl(struct file *file,
 			 unsigned int cmd, unsigned long arg)
 {
@@ -149,9 +120,8 @@ static long libcfs_ioctl(struct file *file,
 }
 
 static const struct file_operations libcfs_fops = {
+	.owner		= THIS_MODULE,
 	.unlocked_ioctl	= libcfs_ioctl,
-	.open		= libcfs_psdev_open,
-	.release	= libcfs_psdev_release,
 };
 
 struct miscdevice libcfs_dev = {
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 3a88e64..4d38aaf 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -65,20 +65,6 @@
 
 static struct dentry *lnet_debugfs_root;
 
-/* called when opening /dev/device */
-static int libcfs_psdev_open(unsigned long flags, void *args)
-{
-	try_module_get(THIS_MODULE);
-	return 0;
-}
-
-/* called when closing /dev/device */
-static int libcfs_psdev_release(unsigned long flags, void *args)
-{
-	module_put(THIS_MODULE);
-	return 0;
-}
-
 static DECLARE_RWSEM(ioctl_list_sem);
 static LIST_HEAD(ioctl_list);
 
@@ -180,8 +166,6 @@ out:
 }
 
 struct cfs_psdev_ops libcfs_psdev_ops = {
-	libcfs_psdev_open,
-	libcfs_psdev_release,
 	NULL,
 	NULL,
 	libcfs_ioctl
-- 
1.7.1
