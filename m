From: NeilBrown <neilb@suse.com>
Date: Tue, 01 May 2018 13:52:39 +1000
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: move misc-device
 registration closer to related code.
In-Reply-To: <152514658325.17843.11455067361317157487.stgit@noble>
References: <152514658325.17843.11455067361317157487.stgit@noble>
Message-ID: <152514675910.17843.16005951911891583421.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The ioctl handler for the misc device is in  lnet/libcfs/module.c
but is it registered in lnet/libcfs/linux/linux-module.c.

Keeping related code together make maintenance easier, so move the
code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 -
 .../lustre/lnet/libcfs/linux/linux-module.c        |   28 ------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |   31 +++++++++++++++++++-
 3 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 6e7754b2f296..9263e151451b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -141,11 +141,9 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 			 const struct libcfs_ioctl_hdr __user *uparam);
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
-int libcfs_ioctl(unsigned long cmd, void __user *arg);
 
 #define _LIBCFS_H
 
-extern struct miscdevice libcfs_dev;
 /**
  * The path of debug log dump upcall script.
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index c8908e816c4c..954b681f9db7 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -166,31 +166,3 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 	kvfree(*hdr_pp);
 	return err;
 }
-
-static long
-libcfs_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
-{
-	if (!capable(CAP_SYS_ADMIN))
-		return -EACCES;
-
-	if (_IOC_TYPE(cmd) != IOC_LIBCFS_TYPE ||
-	    _IOC_NR(cmd) < IOC_LIBCFS_MIN_NR  ||
-	    _IOC_NR(cmd) > IOC_LIBCFS_MAX_NR) {
-		CDEBUG(D_IOCTL, "invalid ioctl ( type %d, nr %d, size %d )\n",
-		       _IOC_TYPE(cmd), _IOC_NR(cmd), _IOC_SIZE(cmd));
-		return -EINVAL;
-	}
-
-	return libcfs_ioctl(cmd, (void __user *)arg);
-}
-
-static const struct file_operations libcfs_fops = {
-	.owner		= THIS_MODULE,
-	.unlocked_ioctl	= libcfs_psdev_ioctl,
-};
-
-struct miscdevice libcfs_dev = {
-	.minor = MISC_DYNAMIC_MINOR,
-	.name = "lnet",
-	.fops = &libcfs_fops,
-};
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 4b9acd7bc5cf..3fb150a57f49 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -95,7 +95,7 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
-int libcfs_ioctl(unsigned long cmd, void __user *uparam)
+static int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 {
 	struct libcfs_ioctl_data *data = NULL;
 	struct libcfs_ioctl_hdr *hdr;
@@ -161,6 +161,35 @@ int libcfs_ioctl(unsigned long cmd, void __user *uparam)
 	return err;
 }
 
+
+static long
+libcfs_psdev_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	if (_IOC_TYPE(cmd) != IOC_LIBCFS_TYPE ||
+	    _IOC_NR(cmd) < IOC_LIBCFS_MIN_NR  ||
+	    _IOC_NR(cmd) > IOC_LIBCFS_MAX_NR) {
+		CDEBUG(D_IOCTL, "invalid ioctl ( type %d, nr %d, size %d )\n",
+		       _IOC_TYPE(cmd), _IOC_NR(cmd), _IOC_SIZE(cmd));
+		return -EINVAL;
+	}
+
+	return libcfs_ioctl(cmd, (void __user *)arg);
+}
+
+static const struct file_operations libcfs_fops = {
+	.owner		= THIS_MODULE,
+	.unlocked_ioctl	= libcfs_psdev_ioctl,
+};
+
+struct miscdevice libcfs_dev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = "lnet",
+	.fops = &libcfs_fops,
+};
+
 int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			 void __user *buffer, size_t *lenp,
 			 int (*handler)(void *data, int write, loff_t pos,
