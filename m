From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:31 -0400
Subject: [lustre-devel] [PATCH 28/38] lustre: obd: move ioctl handling to
 class_obd.c
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Move the ioctl handling in module.c to class_obd.c and rename
module.c to obd_sysfs.c since it only contains sysfs/debugfs code.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8837
Reviewed-on: https://review.whamcloud.com/32100
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |   1 -
 drivers/staging/lustre/lustre/obdclass/Makefile    |   2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 205 ++++++++++++++++++++
 .../lustre/obdclass/{module.c => obd_sysfs.c}      | 207 ---------------------
 4 files changed, 206 insertions(+), 209 deletions(-)
 rename drivers/staging/lustre/lustre/obdclass/{module.c => obd_sysfs.c} (67%)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 1925bda..33c0b87 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1568,7 +1568,6 @@ struct lwp_register_item {
 
 /* class_obd.c */
 extern char obd_jobid_node[];
-extern struct miscdevice obd_psdev;
 int class_procfs_init(void);
 int class_procfs_clean(void);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index 5d050f0..19c8bd9 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -4,7 +4,7 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
-obdclass-y := module.o \
+obdclass-y := obd_sysfs.o \
 	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
 	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index bbffede..eabaafe 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -153,6 +153,168 @@ static int class_resolve_dev_name(__u32 len, const char *name)
 	return rc;
 }
 
+#define OBD_MAX_IOCTL_BUFFER    8192
+
+static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
+{
+	if (data->ioc_len > BIT(30)) {
+		CERROR("OBD ioctl: ioc_len larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen1 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen1 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen2 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen2 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen3 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen3 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inllen4 > BIT(30)) {
+		CERROR("OBD ioctl: ioc_inllen4 larger than 1<<30\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf1 && data->ioc_inllen1 == 0) {
+		CERROR("OBD ioctl: inlbuf1 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf2 && data->ioc_inllen2 == 0) {
+		CERROR("OBD ioctl: inlbuf2 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf3 && data->ioc_inllen3 == 0) {
+		CERROR("OBD ioctl: inlbuf3 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_inlbuf4 && data->ioc_inllen4 == 0) {
+		CERROR("OBD ioctl: inlbuf4 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_pbuf1 && data->ioc_plen1 == 0) {
+		CERROR("OBD ioctl: pbuf1 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (data->ioc_pbuf2 && data->ioc_plen2 == 0) {
+		CERROR("OBD ioctl: pbuf2 pointer but 0 length\n");
+		return 1;
+	}
+
+	if (!data->ioc_pbuf1 && data->ioc_plen1 != 0) {
+		CERROR("OBD ioctl: plen1 set but NULL pointer\n");
+		return 1;
+	}
+
+	if (!data->ioc_pbuf2 && data->ioc_plen2 != 0) {
+		CERROR("OBD ioctl: plen2 set but NULL pointer\n");
+		return 1;
+	}
+
+	if (obd_ioctl_packlen(data) > data->ioc_len) {
+		CERROR("OBD ioctl: packlen exceeds ioc_len (%d > %d)\n",
+		       obd_ioctl_packlen(data), data->ioc_len);
+		return 1;
+	}
+
+	return 0;
+}
+
+/* buffer MUST be at least the size of obd_ioctl_hdr */
+int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
+{
+	struct obd_ioctl_data *data;
+	struct obd_ioctl_hdr hdr;
+	int offset = 0;
+	int err;
+
+	if (copy_from_user(&hdr, arg, sizeof(hdr)))
+		return -EFAULT;
+
+	if (hdr.ioc_version != OBD_IOCTL_VERSION) {
+		CERROR("Version mismatch kernel (%x) vs application (%x)\n",
+		       OBD_IOCTL_VERSION, hdr.ioc_version);
+		return -EINVAL;
+	}
+
+	if (hdr.ioc_len > OBD_MAX_IOCTL_BUFFER) {
+		CERROR("User buffer len %d exceeds %d max buffer\n",
+		       hdr.ioc_len, OBD_MAX_IOCTL_BUFFER);
+		return -EINVAL;
+	}
+
+	if (hdr.ioc_len < sizeof(struct obd_ioctl_data)) {
+		CERROR("User buffer too small for ioctl (%d)\n", hdr.ioc_len);
+		return -EINVAL;
+	}
+
+	/* When there are lots of processes calling vmalloc on multi-core
+	 * system, the high lock contention will hurt performance badly,
+	 * obdfilter-survey is an example, which relies on ioctl. So we'd
+	 * better avoid vmalloc on ioctl path. LU-66
+	 */
+	*buf = kvzalloc(hdr.ioc_len, GFP_KERNEL);
+	if (!*buf) {
+		CERROR("Cannot allocate control buffer of len %d\n",
+		       hdr.ioc_len);
+		return -EINVAL;
+	}
+	*len = hdr.ioc_len;
+	data = (struct obd_ioctl_data *)*buf;
+
+	if (copy_from_user(*buf, arg, hdr.ioc_len)) {
+		err = -EFAULT;
+		goto free_buf;
+	}
+
+	if (hdr.ioc_len != data->ioc_len) {
+		err = -EINVAL;
+		goto free_buf;
+	}
+
+	if (obd_ioctl_is_invalid(data)) {
+		CERROR("ioctl not correctly formatted\n");
+		err = -EINVAL;
+		goto free_buf;
+	}
+
+	if (data->ioc_inllen1) {
+		data->ioc_inlbuf1 = &data->ioc_bulk[0];
+		offset += cfs_size_round(data->ioc_inllen1);
+	}
+
+	if (data->ioc_inllen2) {
+		data->ioc_inlbuf2 = &data->ioc_bulk[0] + offset;
+		offset += cfs_size_round(data->ioc_inllen2);
+	}
+
+	if (data->ioc_inllen3) {
+		data->ioc_inlbuf3 = &data->ioc_bulk[0] + offset;
+		offset += cfs_size_round(data->ioc_inllen3);
+	}
+
+	if (data->ioc_inllen4)
+		data->ioc_inlbuf4 = &data->ioc_bulk[0] + offset;
+
+	return 0;
+
+free_buf:
+	kvfree(*buf);
+	return err;
+}
+EXPORT_SYMBOL(obd_ioctl_getdata);
+
 int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 {
 	char *buf = NULL;
@@ -379,6 +541,49 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	return err;
 } /* class_handle_ioctl */
 
+/*  opening /dev/obd */
+static int obd_class_open(struct inode *inode, struct file *file)
+{
+	try_module_get(THIS_MODULE);
+	return 0;
+}
+
+/*  closing /dev/obd */
+static int obd_class_release(struct inode *inode, struct file *file)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+/* to control /dev/obd */
+static long obd_class_ioctl(struct file *filp, unsigned int cmd,
+			    unsigned long arg)
+{
+	/* Allow non-root access for OBD_IOC_PING_TARGET - used by lfs check */
+	if (!capable(CAP_SYS_ADMIN) && (cmd != OBD_IOC_PING_TARGET))
+		return -EACCES;
+
+	if ((cmd & 0xffffff00) == ((int)'T') << 8) /* ignore all tty ioctls */
+		return -ENOTTY;
+
+	return class_handle_ioctl(cmd, (unsigned long)arg);
+}
+
+/* declare character device */
+static const struct file_operations obd_psdev_fops = {
+	.owner		= THIS_MODULE,
+	.unlocked_ioctl	= obd_class_ioctl,	/* unlocked_ioctl */
+	.open		= obd_class_open,	/* open */
+	.release	= obd_class_release,	/* release */
+};
+
+/* modules setup */
+static struct miscdevice obd_psdev = {
+	.minor	= MISC_DYNAMIC_MINOR,
+	.name	= OBD_DEV_NAME,
+	.fops	= &obd_psdev_fops,
+};
+
 #define OBD_INIT_CHECK
 static int obd_init_checks(void)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/module.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
similarity index 67%
rename from drivers/staging/lustre/lustre/obdclass/module.c
rename to drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
index eab9820..6669c23 100644
--- a/drivers/staging/lustre/lustre/obdclass/module.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
@@ -67,213 +67,6 @@
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 
-#define OBD_MAX_IOCTL_BUFFER	8192
-
-static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
-{
-	if (data->ioc_len > BIT(30)) {
-		CERROR("OBD ioctl: ioc_len larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen1 > BIT(30)) {
-		CERROR("OBD ioctl: ioc_inllen1 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen2 > BIT(30)) {
-		CERROR("OBD ioctl: ioc_inllen2 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen3 > BIT(30)) {
-		CERROR("OBD ioctl: ioc_inllen3 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inllen4 > BIT(30)) {
-		CERROR("OBD ioctl: ioc_inllen4 larger than 1<<30\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf1 && data->ioc_inllen1 == 0) {
-		CERROR("OBD ioctl: inlbuf1 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf2 && data->ioc_inllen2 == 0) {
-		CERROR("OBD ioctl: inlbuf2 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf3 && data->ioc_inllen3 == 0) {
-		CERROR("OBD ioctl: inlbuf3 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_inlbuf4 && data->ioc_inllen4 == 0) {
-		CERROR("OBD ioctl: inlbuf4 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_pbuf1 && data->ioc_plen1 == 0) {
-		CERROR("OBD ioctl: pbuf1 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (data->ioc_pbuf2 && data->ioc_plen2 == 0) {
-		CERROR("OBD ioctl: pbuf2 pointer but 0 length\n");
-		return 1;
-	}
-
-	if (!data->ioc_pbuf1 && data->ioc_plen1 != 0) {
-		CERROR("OBD ioctl: plen1 set but NULL pointer\n");
-		return 1;
-	}
-
-	if (!data->ioc_pbuf2 && data->ioc_plen2 != 0) {
-		CERROR("OBD ioctl: plen2 set but NULL pointer\n");
-		return 1;
-	}
-
-	if (obd_ioctl_packlen(data) > data->ioc_len) {
-		CERROR("OBD ioctl: packlen exceeds ioc_len (%d > %d)\n",
-		obd_ioctl_packlen(data), data->ioc_len);
-		return 1;
-	}
-
-	return 0;
-}
-
-/* buffer MUST be at least the size of obd_ioctl_hdr */
-int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
-{
-	struct obd_ioctl_hdr hdr;
-	struct obd_ioctl_data *data;
-	int err;
-	int offset = 0;
-
-	if (copy_from_user(&hdr, arg, sizeof(hdr)))
-		return -EFAULT;
-
-	if (hdr.ioc_version != OBD_IOCTL_VERSION) {
-		CERROR("Version mismatch kernel (%x) vs application (%x)\n",
-		       OBD_IOCTL_VERSION, hdr.ioc_version);
-		return -EINVAL;
-	}
-
-	if (hdr.ioc_len > OBD_MAX_IOCTL_BUFFER) {
-		CERROR("User buffer len %d exceeds %d max buffer\n",
-		       hdr.ioc_len, OBD_MAX_IOCTL_BUFFER);
-		return -EINVAL;
-	}
-
-	if (hdr.ioc_len < sizeof(struct obd_ioctl_data)) {
-		CERROR("User buffer too small for ioctl (%d)\n", hdr.ioc_len);
-		return -EINVAL;
-	}
-
-	/* When there are lots of processes calling vmalloc on multi-core
-	 * system, the high lock contention will hurt performance badly,
-	 * obdfilter-survey is an example, which relies on ioctl. So we'd
-	 * better avoid vmalloc on ioctl path. LU-66
-	 */
-	*buf = kvzalloc(hdr.ioc_len, GFP_KERNEL);
-	if (!*buf) {
-		CERROR("Cannot allocate control buffer of len %d\n",
-		       hdr.ioc_len);
-		return -EINVAL;
-	}
-	*len = hdr.ioc_len;
-	data = (struct obd_ioctl_data *)*buf;
-
-	if (copy_from_user(*buf, arg, hdr.ioc_len)) {
-		err = -EFAULT;
-		goto free_buf;
-	}
-	if (hdr.ioc_len != data->ioc_len) {
-		err = -EINVAL;
-		goto free_buf;
-	}
-
-	if (obd_ioctl_is_invalid(data)) {
-		CERROR("ioctl not correctly formatted\n");
-		err = -EINVAL;
-		goto free_buf;
-	}
-
-	if (data->ioc_inllen1) {
-		data->ioc_inlbuf1 = &data->ioc_bulk[0];
-		offset += cfs_size_round(data->ioc_inllen1);
-	}
-
-	if (data->ioc_inllen2) {
-		data->ioc_inlbuf2 = &data->ioc_bulk[0] + offset;
-		offset += cfs_size_round(data->ioc_inllen2);
-	}
-
-	if (data->ioc_inllen3) {
-		data->ioc_inlbuf3 = &data->ioc_bulk[0] + offset;
-		offset += cfs_size_round(data->ioc_inllen3);
-	}
-
-	if (data->ioc_inllen4)
-		data->ioc_inlbuf4 = &data->ioc_bulk[0] + offset;
-
-	return 0;
-
-free_buf:
-	kvfree(*buf);
-	return err;
-}
-EXPORT_SYMBOL(obd_ioctl_getdata);
-
-/*  opening /dev/obd */
-static int obd_class_open(struct inode *inode, struct file *file)
-{
-	try_module_get(THIS_MODULE);
-	return 0;
-}
-
-/*  closing /dev/obd */
-static int obd_class_release(struct inode *inode, struct file *file)
-{
-	module_put(THIS_MODULE);
-	return 0;
-}
-
-/* to control /dev/obd */
-static long obd_class_ioctl(struct file *filp, unsigned int cmd,
-			    unsigned long arg)
-{
-	int err = 0;
-
-	/* Allow non-root access for OBD_IOC_PING_TARGET - used by lfs check */
-	if (!capable(CAP_SYS_ADMIN) && (cmd != OBD_IOC_PING_TARGET))
-		return err = -EACCES;
-	if ((cmd & 0xffffff00) == ((int)'T') << 8) /* ignore all tty ioctls */
-		return err = -ENOTTY;
-
-	err = class_handle_ioctl(cmd, (unsigned long)arg);
-
-	return err;
-}
-
-/* declare character device */
-static const struct file_operations obd_psdev_fops = {
-	.owner	  = THIS_MODULE,
-	.unlocked_ioctl = obd_class_ioctl, /* unlocked_ioctl */
-	.open	   = obd_class_open,      /* open */
-	.release	= obd_class_release,   /* release */
-};
-
-/* modules setup */
-struct miscdevice obd_psdev = {
-	.minor = MISC_DYNAMIC_MINOR,
-	.name  = OBD_DEV_NAME,
-	.fops  = &obd_psdev_fops,
-};
-
 struct static_lustre_uintvalue_attr {
 	struct {
 		struct attribute attr;
-- 
1.8.3.1
