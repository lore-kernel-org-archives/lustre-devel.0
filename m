From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:07 -0400
Subject: [lustre-devel] [PATCH 20/29] staging:lustre: call libcfs_ioctl
	directly
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>

From: Parinay Kondekar <parinay.kondekar@seagate.com>

No reason to go through the cfs_psdev_ops abstract
to call libcfs_ioctl. Just call libcfs_ioctl directly.

Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
Reviewed-on: http://review.whamcloud.com/17492
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    3 ++-
 .../lustre/lnet/libcfs/linux/linux-module.c        |   13 ++++---------
 drivers/staging/lustre/lnet/libcfs/module.c        |    5 ++---
 3 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 5d228e5..592ad31 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -75,7 +75,6 @@ struct cfs_psdev_file {
 struct cfs_psdev_ops {
 	int (*p_read)(struct cfs_psdev_file *, char *, unsigned long);
 	int (*p_write)(struct cfs_psdev_file *, char *, unsigned long);
-	int (*p_ioctl)(struct cfs_psdev_file *, unsigned long, void __user *);
 };
 
 /*
@@ -131,6 +130,8 @@ struct libcfs_ioctl_handler {
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 
+int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd, void *arg);
+
 /* container_of depends on "likely" which is defined in libcfs_private.h */
 static inline void *__container_of(void *ptr, unsigned long shift)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 633d76b..6f35a80 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -95,11 +95,10 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 	return err;
 }
 
-static long libcfs_ioctl(struct file *file,
-			 unsigned int cmd, unsigned long arg)
+static long
+libcfs_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct cfs_psdev_file	 pfile;
-	int    rc = 0;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EACCES;
@@ -112,16 +111,12 @@ static long libcfs_ioctl(struct file *file,
 		return -EINVAL;
 	}
 
-	if (libcfs_psdev_ops.p_ioctl)
-		rc = libcfs_psdev_ops.p_ioctl(&pfile, cmd, (void __user *)arg);
-	else
-		rc = -EPERM;
-	return rc;
+	return libcfs_ioctl(&pfile, cmd, (void __user *)arg);
 }
 
 static const struct file_operations libcfs_fops = {
 	.owner		= THIS_MODULE,
-	.unlocked_ioctl	= libcfs_ioctl,
+	.unlocked_ioctl	= libcfs_psdev_ioctl,
 };
 
 struct miscdevice libcfs_dev = {
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 4d38aaf..4af4557 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -98,8 +98,8 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
-static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
-			void __user *uparam)
+int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
+		 void __user *uparam)
 {
 	struct libcfs_ioctl_data *data = NULL;
 	struct libcfs_ioctl_hdr *hdr;
@@ -168,7 +168,6 @@ out:
 struct cfs_psdev_ops libcfs_psdev_ops = {
 	NULL,
 	NULL,
-	libcfs_ioctl
 };
 
 int lprocfs_call_handler(void *data, int write, loff_t *ppos,
-- 
1.7.1
