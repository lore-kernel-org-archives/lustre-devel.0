From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 15:10:06 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: use dynamic minors
 for /dev/{lnet, obd}
Message-ID: <1522437006-31539-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: "John L. Hammond" <john.hammond@intel.com>

Request dynamic minor allocation when registering /dev/lnet and
/dev/obd.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-100086
Reviewed-on: https://review.whamcloud.com/29741
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h    |  1 -
 drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h      | 11 -----------
 .../staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h   |  2 --
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c        |  1 -
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c       |  5 ++---
 drivers/staging/lustre/lnet/libcfs/module.c                   |  1 +
 drivers/staging/lustre/lustre/obdclass/class_obd.c            |  6 ++++--
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c   |  3 +--
 8 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index 30e333a..cf4c606 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -50,7 +50,6 @@
 #include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <linux/kthread.h>
-#include <linux/miscdevice.h>
 #include <linux/mm.h>
 #include <linux/mm_inline.h>
 #include <linux/module.h>
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index d9da625..cccb32d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -119,16 +119,5 @@ struct lnet_fault_stat {
 
 #define LNET_DEV_ID 0
 #define LNET_DEV_PATH "/dev/lnet"
-#define LNET_DEV_MAJOR 10
-#define LNET_DEV_MINOR 240
-#define OBD_DEV_ID 1
-#define OBD_DEV_NAME "obd"
-#define OBD_DEV_PATH "/dev/" OBD_DEV_NAME
-#define OBD_DEV_MAJOR 10
-#define OBD_DEV_MINOR 241
-#define SMFS_DEV_ID  2
-#define SMFS_DEV_PATH "/dev/snapdev"
-#define SMFS_DEV_MAJOR 10
-#define SMFS_DEV_MINOR 242
 
 #endif
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index 9590864..6e4e109 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -51,8 +51,6 @@ enum md_echo_cmd {
 #define OBD_DEV_ID 1
 #define OBD_DEV_NAME "obd"
 #define OBD_DEV_PATH "/dev/" OBD_DEV_NAME
-#define OBD_DEV_MAJOR 10
-#define OBD_DEV_MINOR 241
 
 #define OBD_IOCTL_VERSION	0x00010004
 #define OBD_DEV_BY_DEVNAME	0xffffd0de
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 0092166..1d728f1 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -48,7 +48,6 @@
 #include <linux/completion.h>
 #include <linux/fs.h>
 #include <linux/uaccess.h>
-#include <linux/miscdevice.h>
 
 # define DEBUG_SUBSYSTEM S_LNET
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index ddf6256..c8908e8 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -33,10 +33,9 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
+#include <linux/miscdevice.h>
 #include <linux/libcfs/libcfs.h>
 
-#define LNET_MINOR 240
-
 static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 {
 	size_t len = sizeof(*data);
@@ -191,7 +190,7 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 };
 
 struct miscdevice libcfs_dev = {
-	.minor = LNET_MINOR,
+	.minor = MISC_DYNAMIC_MINOR,
 	.name = "lnet",
 	.fops = &libcfs_fops,
 };
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index a03f924..4b9acd7 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -30,6 +30,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
+#include <linux/miscdevice.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 3e24b76..7b5be6b 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -32,7 +32,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
-# include <linux/atomic.h>
+
+#include <linux/atomic.h>
+#include <linux/miscdevice.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
@@ -462,7 +464,7 @@ static int __init obdclass_init(void)
 
 	err = misc_register(&obd_psdev);
 	if (err) {
-		CERROR("cannot register %d err %d\n", OBD_DEV_MINOR, err);
+		CERROR("cannot register OBD miscdevices: err %d\n", err);
 		return err;
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 7bceee7..3b1d096 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -42,7 +42,6 @@
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
-#include <linux/major.h>
 #include <linux/sched.h>
 #include <linux/lp.h>
 #include <linux/slab.h>
@@ -271,7 +270,7 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 
 /* modules setup */
 struct miscdevice obd_psdev = {
-	.minor = OBD_DEV_MINOR,
+	.minor = MISC_DYNAMIC_MINOR,
 	.name  = OBD_DEV_NAME,
 	.fops  = &obd_psdev_fops,
 };
-- 
1.8.3.1
