From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:55 -0500
Subject: [lustre-devel] [PATCH 19/40] staging: lustre: copy out libcfs ioctl
	inline buffer
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

  - libcfs_ioctl_popdata should copy out inline buffers.
  - code cleanup for libcfs ioctl handler
  - error number fix for obd_ioctl_getdata
  - add new function libcfs_ioctl_unpack for upcoming patches

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   24 +++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +
 .../lustre/lustre/libcfs/linux/linux-module.c      |   45 +++++---
 drivers/staging/lustre/lustre/libcfs/module.c      |  119 ++++++++------------
 .../lustre/lustre/obdclass/linux/linux-module.c    |   17 +--
 5 files changed, 97 insertions(+), 110 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index f24330d..3468933 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -49,6 +49,9 @@ struct libcfs_ioctl_hdr {
 	__u32 ioc_version;
 };
 
+/** max size to copy from userspace */
+#define LIBCFS_IOC_DATA_MAX	(128 * 1024)
+
 struct libcfs_ioctl_data {
 	struct libcfs_ioctl_hdr ioc_hdr;
 
@@ -240,11 +243,22 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
-int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
-			 const void __user *arg);
-int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
-			     __u32 *buf_len);
-int libcfs_ioctl_popdata(void *arg, void *buf, int size);
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			 struct libcfs_ioctl_hdr __user *uparam);
+
+static inline int libcfs_ioctl_popdata(struct libcfs_ioctl_hdr *hdr,
+				       struct libcfs_ioctl_hdr __user *uparam)
+{
+	if (copy_to_user(uparam, hdr, hdr->ioc_len))
+		return -EFAULT;
+	return 0;
+}
+
+static inline void libcfs_ioctl_freedata(struct libcfs_ioctl_hdr *hdr)
+{
+	LIBCFS_FREE(hdr, hdr->ioc_len);
+}
+
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 949fa2f..4c4e6d3 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1838,6 +1838,8 @@ LNetCtl(unsigned int cmd, void *arg)
 	int rc;
 	unsigned long secs_passed;
 
+	CLASSERT(sizeof(struct lnet_ioctl_net_config) +
+		 sizeof(struct lnet_ioctl_config_data) < LIBCFS_IOC_DATA_MAX);
 	LASSERT(the_lnet.ln_init);
 
 	switch (cmd) {
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
index 1c31e2e..50a5464 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
@@ -43,7 +43,7 @@
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 {
 	if (libcfs_ioctl_is_invalid(data)) {
-		CERROR("LNET: ioctl not correctly formatted\n");
+		CERROR("libcfs ioctl: parameter not correctly formatted\n");
 		return -EINVAL;
 	}
 
@@ -57,39 +57,46 @@ int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 	return 0;
 }
 
-int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
-			     __u32 *len)
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			 struct libcfs_ioctl_hdr __user *uhdr)
 {
 	struct libcfs_ioctl_hdr hdr;
+	int err = 0;
 
-	if (copy_from_user(&hdr, arg, sizeof(hdr)))
+	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
 		return -EFAULT;
 
 	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
 	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
-		CERROR("LNET: version mismatch expected %#x, got %#x\n",
+		CERROR("libcfs ioctl: version mismatch expected %#x, got %#x\n",
 		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
 		return -EINVAL;
 	}
 
-	*len = hdr.ioc_len;
+	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_data)) {
+		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
+		return -EINVAL;
+	}
 
-	return 0;
-}
+	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
+		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
+		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
+		return -EINVAL;
+	}
 
-int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
-			  const void __user *arg)
-{
-	if (copy_from_user(buf, arg, buf_len))
-		return -EFAULT;
-	return 0;
-}
+	LIBCFS_ALLOC(*hdr_pp, hdr.ioc_len);
+	if (!*hdr_pp)
+		return -ENOMEM;
+
+	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
+		err = -EFAULT;
+		goto failed;
+	}
 
-int libcfs_ioctl_popdata(void *arg, void *data, int size)
-{
-	if (copy_to_user((char *)arg, data, size))
-		return -EFAULT;
 	return 0;
+failed:
+	libcfs_ioctl_freedata(*hdr_pp);
+	return err;
 }
 
 static int
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 992ff3c..1be814d 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -54,9 +54,6 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#define LNET_MAX_IOCTL_BUF_LEN (sizeof(struct lnet_ioctl_net_config) + \
-				sizeof(struct lnet_ioctl_config_data))
-
 #include "../../include/linux/libcfs/libcfs.h"
 #include <asm/div64.h>
 
@@ -245,52 +242,63 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
-static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
-			       void *arg, struct libcfs_ioctl_hdr *hdr)
+static int libcfs_ioctl(struct cfs_psdev_file *pfile,
+			unsigned long cmd, void __user *uparam)
 {
 	struct libcfs_ioctl_data *data = NULL;
-	int err = -EINVAL;
+	struct libcfs_ioctl_hdr *hdr;
+	int err;
+
+	/* 'cmd' and permissions get checked in our arch-specific caller */
+	err = libcfs_ioctl_getdata(&hdr, uparam);
+	if (err != 0) {
+		CDEBUG_LIMIT(D_ERROR,
+			     "libcfs ioctl: data header error %d\n", err);
+		return err;
+	}
 
-	/*
-	 * The libcfs_ioctl_data_adjust() function performs adjustment
-	 * operations on the libcfs_ioctl_data structure to make
-	 * it usable by the code.  This doesn't need to be called
-	 * for new data structures added.
-	 */
 	if (hdr->ioc_version == LIBCFS_IOCTL_VERSION) {
+		/*
+		 * The libcfs_ioctl_data_adjust() function performs adjustment
+		 * operations on the libcfs_ioctl_data structure to make
+		 * it usable by the code.  This doesn't need to be called
+		 * for new data structures added.
+		 */
 		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
 		err = libcfs_ioctl_data_adjust(data);
-		if (err != 0) {
-			return err;
-		}
+		if (err != 0)
+			goto out;
 	}
 
+	CDEBUG(D_IOCTL, "libcfs ioctl cmd %lu\n", cmd);
 	switch (cmd) {
 	case IOC_LIBCFS_CLEAR_DEBUG:
 		libcfs_debug_clear_buffer();
-		return 0;
+		break;
 	/*
 	 * case IOC_LIBCFS_PANIC:
 	 * Handled in arch/cfs_module.c
 	 */
 	case IOC_LIBCFS_MARK_DEBUG:
-		if (data->ioc_inlbuf1 == NULL ||
-		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0')
-			return -EINVAL;
+		if (!data || !data->ioc_inlbuf1 ||
+		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0') {
+			err = -EINVAL;
+			goto out;
+		}
 		libcfs_debug_mark_buffer(data->ioc_inlbuf1);
-		return 0;
+		break;
+
 	case IOC_LIBCFS_MEMHOG:
-		if (pfile->private_data == NULL) {
+		if (!data || !pfile->private_data) {
 			err = -EINVAL;
-		} else {
-			kportal_memhog_free(pfile->private_data);
-			/* XXX The ioc_flags is not GFP flags now, need to be fixed */
-			err = kportal_memhog_alloc(pfile->private_data,
-						   data->ioc_count,
-						   data->ioc_flags);
-			if (err != 0)
-				kportal_memhog_free(pfile->private_data);
+			goto out;
 		}
+
+		kportal_memhog_free(pfile->private_data);
+		err = kportal_memhog_alloc(pfile->private_data,
+					   data->ioc_count, data->ioc_flags);
+		if (err != 0)
+			kportal_memhog_free(pfile->private_data);
 		break;
 
 	default: {
@@ -300,55 +308,18 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 		down_read(&ioctl_list_sem);
 		list_for_each_entry(hand, &ioctl_list, item) {
 			err = hand->handle_ioctl(cmd, hdr);
-			if (err != -EINVAL) {
-				if (err == 0)
-					err = libcfs_ioctl_popdata(arg,
-							hdr, hdr->ioc_len);
-				break;
-			}
+			if (err == -EINVAL)
+				continue;
+
+			if (!err)
+				err = libcfs_ioctl_popdata(hdr, uparam);
+			break;
 		}
 		up_read(&ioctl_list_sem);
-		break;
+		break; }
 	}
-	}
-
-	return err;
-}
-
-static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd, void *arg)
-{
-	struct libcfs_ioctl_hdr *hdr;
-	int err = 0;
-	__u32 buf_len;
-
-	err = libcfs_ioctl_getdata_len(arg, &buf_len);
-	if (err != 0)
-		return err;
-
-	/*
-	 * do a check here to restrict the size of the memory
-	 * to allocate to guard against DoS attacks.
-	 */
-	if (buf_len > LNET_MAX_IOCTL_BUF_LEN) {
-		CERROR("LNET: user buffer exceeds kernel buffer\n");
-		return -EINVAL;
-	}
-
-	LIBCFS_ALLOC_GFP(hdr, buf_len, GFP_KERNEL);
-	if (!hdr)
-		return -ENOMEM;
-
-	/* 'cmd' and permissions get checked in our arch-specific caller */
-	if (libcfs_ioctl_getdata(hdr, buf_len, arg)) {
-		CERROR("LNET ioctl: data error\n");
-		err = -EINVAL;
-		goto out;
-	}
-
-	err = libcfs_ioctl_handle(pfile, cmd, arg, hdr);
-
 out:
-	LIBCFS_FREE(hdr, buf_len);
+	libcfs_ioctl_freedata(hdr);
 	return err;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index a055cbb..4e9b0c4 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -74,14 +74,14 @@
 #include "../../include/lustre/lustre_build_version.h"
 
 /* buffer MUST be at least the size of obd_ioctl_hdr */
-int obd_ioctl_getdata(char **buf, int *len, void *arg)
+int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 {
 	struct obd_ioctl_hdr hdr;
 	struct obd_ioctl_data *data;
 	int err;
 	int offset = 0;
 
-	if (copy_from_user(&hdr, (void *)arg, sizeof(hdr)))
+	if (copy_from_user(&hdr, arg, sizeof(hdr)))
 		return -EFAULT;
 
 	if (hdr.ioc_version != OBD_IOCTL_VERSION) {
@@ -114,14 +114,10 @@ int obd_ioctl_getdata(char **buf, int *len, void *arg)
 	*len = hdr.ioc_len;
 	data = (struct obd_ioctl_data *)*buf;
 
-	if (copy_from_user(*buf, (void *)arg, hdr.ioc_len)) {
+	if (copy_from_user(*buf, arg, hdr.ioc_len)) {
 		err = -EFAULT;
 		goto free_buf;
 	}
-	if (hdr.ioc_len != data->ioc_len) {
-		err = -EINVAL;
-		goto free_buf;
-	}
 
 	if (obd_ioctl_is_invalid(data)) {
 		CERROR("ioctl not correctly formatted\n");
@@ -144,9 +140,8 @@ int obd_ioctl_getdata(char **buf, int *len, void *arg)
 		offset += cfs_size_round(data->ioc_inllen3);
 	}
 
-	if (data->ioc_inllen4) {
+	if (data->ioc_inllen4)
 		data->ioc_inlbuf4 = &data->ioc_bulk[0] + offset;
-	}
 
 	return 0;
 
@@ -160,9 +155,7 @@ int obd_ioctl_popdata(void *arg, void *data, int len)
 {
 	int err;
 
-	err = copy_to_user(arg, data, len);
-	if (err)
-		err = -EFAULT;
+	err = copy_to_user(arg, data, len) ? -EFAULT : 0;
 	return err;
 }
 EXPORT_SYMBOL(obd_ioctl_popdata);
-- 
1.7.1
