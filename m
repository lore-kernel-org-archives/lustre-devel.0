From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:03 -0400
Subject: [lustre-devel] [PATCH 16/29] staging: lustre: libcfs: remove
	libcfs_ioctl_popdata wrapper
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <uja.ornl@gmail.com>

From: John L. Hammond <john.hammond@intel.com>

Lets just use copy_to_user() directly instead of having a
wrapper function.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14180
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    1 -
 .../lustre/lnet/libcfs/linux/linux-module.c        |    7 -------
 drivers/staging/lustre/lnet/libcfs/module.c        |    7 ++++---
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index d167d2e..45d1165 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -214,7 +214,6 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 
 int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 			 const struct libcfs_ioctl_hdr __user *uparam);
-int libcfs_ioctl_popdata(void __user *arg, void *buf, int size);
 int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index ae05895..890a458 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -95,13 +95,6 @@ int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
 	return err;
 }
 
-int libcfs_ioctl_popdata(void __user *arg, void *data, int size)
-{
-	if (copy_to_user(arg, data, size))
-		return -EFAULT;
-	return 0;
-}
-
 static int
 libcfs_psdev_open(struct inode *inode, struct file *file)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 839145e..74b9236 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -168,9 +168,10 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 			if (err == -EINVAL)
 				continue;
 
-			if (!err)
-				err = libcfs_ioctl_popdata(uparam, hdr,
-							   hdr->ioc_len);
+			if (!err) {
+				if (copy_to_user(uparam, hdr, hdr->ioc_len))
+					err = -EFAULT;
+			}
 			break;
 		}
 		up_read(&ioctl_list_sem);
-- 
1.7.1
