From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:50 -0400
Subject: [lustre-devel] [PATCH 03/29] staging: lustre: libcfs: merge code
	from libcfs_ioctl into libcfs_ioctl_getdata
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

This is apart of the cleanup of libcfs_ioctl* code. In this
part some of the code in libcfs_ioctl is migrated into
libcfs_ioctl_getdata_len() which is renamed libcfs_ioctl_getdata()

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    4 +-
 .../lustre/lnet/libcfs/linux/linux-module.c        |   23 ++++++++++++---
 drivers/staging/lustre/lnet/libcfs/module.c        |   28 ++-----------------
 3 files changed, 23 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index c71d125..9c1deae 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -225,8 +225,8 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
-int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
-			     __u32 *buf_len);
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			 const struct libcfs_ioctl_hdr __user *uparam);
 int libcfs_ioctl_popdata(void __user *arg, void *buf, int size);
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index ebc60ac..a326ac6 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -57,12 +57,13 @@ int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 	return 0;
 }
 
-int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
-			     __u32 *len)
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
+			 const struct libcfs_ioctl_hdr __user *uhdr)
 {
 	struct libcfs_ioctl_hdr hdr;
+	int err = 0;
 
-	if (copy_from_user(&hdr, arg, sizeof(hdr)))
+	if (copy_from_user(&hdr, uhdr, sizeof(uhdr)))
 		return -EFAULT;
 
 	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
@@ -72,9 +73,21 @@ int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
 		return -EINVAL;
 	}
 
-	*len = hdr.ioc_len;
+	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
+		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
+		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
+		return -EINVAL;
+	}
 
-	return 0;
+	LIBCFS_ALLOC(*hdr_pp, hdr.ioc_len);
+	if (!*hdr_pp)
+		return -ENOMEM;
+
+	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
+		LIBCFS_FREE(*hdr_pp, hdr.ioc_len);
+		err = -EFAULT;
+	}
+	return err;
 }
 
 int libcfs_ioctl_popdata(void __user *arg, void *data, int size)
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 3fe2810..5a20e53 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -172,36 +172,14 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 {
 	struct libcfs_ioctl_hdr *hdr;
 	int err = 0;
-	__u32 buf_len;
 
-	err = libcfs_ioctl_getdata_len(arg, &buf_len);
+	/* 'cmd' and permissions get checked in our arch-specific caller */
+	err = libcfs_ioctl_getdata(&hdr, arg);
 	if (err)
 		return err;
 
-	/*
-	 * do a check here to restrict the size of the memory
-	 * to allocate to guard against DoS attacks.
-	 */
-	if (buf_len > LIBCFS_IOC_DATA_MAX) {
-		CERROR("LNET: user buffer exceeds kernel buffer\n");
-		return -EINVAL;
-	}
-
-	LIBCFS_ALLOC_GFP(hdr, buf_len, GFP_KERNEL);
-	if (!hdr)
-		return -ENOMEM;
-
-	/* 'cmd' and permissions get checked in our arch-specific caller */
-	if (copy_from_user(hdr, arg, buf_len)) {
-		CERROR("LNET ioctl: data error\n");
-		err = -EFAULT;
-		goto out;
-	}
-
 	err = libcfs_ioctl_handle(pfile, cmd, arg, hdr);
-
-out:
-	LIBCFS_FREE(hdr, buf_len);
+	LIBCFS_FREE(hdr, hdr->ioc_len);
 	return err;
 }
 
-- 
1.7.1
