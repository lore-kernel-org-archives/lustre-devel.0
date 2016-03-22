From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:51 -0400
Subject: [lustre-devel] [PATCH 04/29] staging: lustre: libcfs: merge
	libcfs_ioctl_handle into libcfs_ioctl
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

This is apart of the cleanup of libcfs_ioctl* code. In this
part we turn libcfs_ioctl_handle into libcfs_ioctl since
libcfs_ioctl is now a skeleton function.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |   37 +++++++++++----------------
 1 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 5a20e53..8beb954 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -112,11 +112,17 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
-static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
-			       void __user *arg, struct libcfs_ioctl_hdr *hdr)
+static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
+			void __user *arg)
 {
 	struct libcfs_ioctl_data *data = NULL;
-	int err = 0;
+	struct libcfs_ioctl_hdr *hdr;
+	int err;
+
+	/* 'cmd' and permissions get checked in our arch-specific caller */
+	err = libcfs_ioctl_getdata(&hdr, arg);
+	if (err)
+		return err;
 
 	/*
 	 * The libcfs_ioctl_data_adjust() function performs adjustment
@@ -128,7 +134,7 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
 		err = libcfs_ioctl_data_adjust(data);
 		if (err)
-			return err;
+			goto out;
 	}
 
 	switch (cmd) {
@@ -141,8 +147,10 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 	 */
 	case IOC_LIBCFS_MARK_DEBUG:
 		if (!data->ioc_inlbuf1 ||
-		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0')
-			return -EINVAL;
+		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0') {
+			err = -EINVAL;
+			goto out;
+		}
 		libcfs_debug_mark_buffer(data->ioc_inlbuf1);
 		break;
 
@@ -163,22 +171,7 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 		up_read(&ioctl_list_sem);
 		break; }
 	}
-
-	return err;
-}
-
-static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
-			void __user *arg)
-{
-	struct libcfs_ioctl_hdr *hdr;
-	int err = 0;
-
-	/* 'cmd' and permissions get checked in our arch-specific caller */
-	err = libcfs_ioctl_getdata(&hdr, arg);
-	if (err)
-		return err;
-
-	err = libcfs_ioctl_handle(pfile, cmd, arg, hdr);
+out:
 	LIBCFS_FREE(hdr, hdr->ioc_len);
 	return err;
 }
-- 
1.7.1
