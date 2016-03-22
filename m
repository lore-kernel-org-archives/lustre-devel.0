From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:04 -0400
Subject: [lustre-devel] [PATCH 17/29] staging:lustre: remove last bits of
	the IOC_LIBCFS_PANIC ioctl
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>

From: Parinay Kondekar <parinay.kondekar@seagate.com>

A few pieces still exist for the IOC_LIBCFS_PANIC ioctl. Remove
these last bits to prevent old tools from using them. The latest
lustre utilities no longer use this ioctl.

Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
Reviewed-on: http://review.whamcloud.com/17492
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    2 +-
 .../lustre/lnet/libcfs/linux/linux-module.c        |    9 ---------
 drivers/staging/lustre/lnet/libcfs/module.c        |    5 +----
 3 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 45d1165..d158cd1 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -97,7 +97,7 @@ do {						    \
 #define IOC_LIBCFS_TYPE		   'e'
 #define IOC_LIBCFS_MIN_NR		 30
 /* libcfs ioctls */
-#define IOC_LIBCFS_PANIC		   _IOWR('e', 30, long)
+/* IOC_LIBCFS_PANIC obsolete in 2.8.0, was _IOWR('e', 30, IOCTL_LIBCFS_TYPE) */
 #define IOC_LIBCFS_CLEAR_DEBUG	     _IOWR('e', 31, long)
 #define IOC_LIBCFS_MARK_DEBUG	      _IOWR('e', 32, long)
 #define IOC_LIBCFS_MEMHOG		  _IOWR('e', 36, long)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 890a458..d801d87 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -141,15 +141,6 @@ static long libcfs_ioctl(struct file *file,
 		return -EINVAL;
 	}
 
-	/* Handle platform-dependent IOC requests */
-	switch (cmd) {
-	case IOC_LIBCFS_PANIC:
-		if (!capable(CFS_CAP_SYS_BOOT))
-			return -EPERM;
-		panic("debugctl-invoked panic");
-		return 0;
-	}
-
 	if (libcfs_psdev_ops.p_ioctl)
 		rc = libcfs_psdev_ops.p_ioctl(&pfile, cmd, (void __user *)arg);
 	else
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 74b9236..3a88e64 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -145,10 +145,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 	case IOC_LIBCFS_CLEAR_DEBUG:
 		libcfs_debug_clear_buffer();
 		break;
-	/*
-	 * case IOC_LIBCFS_PANIC:
-	 * Handled in arch/cfs_module.c
-	 */
+
 	case IOC_LIBCFS_MARK_DEBUG:
 		if (!data || !data->ioc_inlbuf1 ||
 		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0') {
-- 
1.7.1
