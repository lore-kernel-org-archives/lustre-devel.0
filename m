From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:08 -0400
Subject: [lustre-devel] [PATCH 21/29] staging:lustre: remove libcfs pseudo
	device abstraction
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>

From: Parinay Kondekar <parinay.kondekar@seagate.com>

With the libcfs ioctl cleanup we no longer need the libcfs
pseudo device abstraction.

Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
Reviewed-on: http://review.whamcloud.com/17492
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   22 +-------------------
 .../lustre/lnet/libcfs/linux/linux-module.c        |    4 +--
 drivers/staging/lustre/lnet/libcfs/module.c        |    8 +------
 3 files changed, 3 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 592ad31..1cd1879 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -60,24 +60,6 @@
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
 /*
- * libcfs pseudo device operations
- *
- * It's just draft now.
- */
-
-struct cfs_psdev_file {
-	unsigned long   off;
-	void	    *private_data;
-	unsigned long   reserved1;
-	unsigned long   reserved2;
-};
-
-struct cfs_psdev_ops {
-	int (*p_read)(struct cfs_psdev_file *, char *, unsigned long);
-	int (*p_write)(struct cfs_psdev_file *, char *, unsigned long);
-};
-
-/*
  * Drop into debugger, if possible. Implementation is provided by platform.
  */
 
@@ -130,7 +112,7 @@ struct libcfs_ioctl_handler {
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 
-int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd, void *arg);
+int libcfs_ioctl(unsigned long cmd, void *arg);
 
 /* container_of depends on "likely" which is defined in libcfs_private.h */
 static inline void *__container_of(void *ptr, unsigned long shift)
@@ -156,8 +138,6 @@ extern struct miscdevice libcfs_dev;
 extern char lnet_upcall[1024];
 extern char lnet_debug_log_upcall[1024];
 
-extern struct cfs_psdev_ops libcfs_psdev_ops;
-
 extern struct cfs_wi_sched *cfs_sched_rehash;
 
 struct lnet_debugfs_symlink_def {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 6f35a80..7634551 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -98,8 +98,6 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 static long
 libcfs_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
-	struct cfs_psdev_file	 pfile;
-
 	if (!capable(CAP_SYS_ADMIN))
 		return -EACCES;
 
@@ -111,7 +109,7 @@ libcfs_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return -EINVAL;
 	}
 
-	return libcfs_ioctl(&pfile, cmd, (void __user *)arg);
+	return libcfs_ioctl(cmd, (void __user *)arg);
 }
 
 static const struct file_operations libcfs_fops = {
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 4af4557..49c2d03 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -98,8 +98,7 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
-int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
-		 void __user *uparam)
+int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 {
 	struct libcfs_ioctl_data *data = NULL;
 	struct libcfs_ioctl_hdr *hdr;
@@ -165,11 +164,6 @@ out:
 	return err;
 }
 
-struct cfs_psdev_ops libcfs_psdev_ops = {
-	NULL,
-	NULL,
-};
-
 int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			 void __user *buffer, size_t *lenp,
 			 int (*handler)(void *data, int write, loff_t pos,
-- 
1.7.1
