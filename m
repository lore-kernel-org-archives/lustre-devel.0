From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:49 -0400
Subject: [lustre-devel] [PATCH 02/29] staging: lustre: libcfs: use break in
	switch options for libcfs_ioctl_handle
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Instead of just returning for each switch condition use a break.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index f9f9d59..3fe2810 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -116,7 +116,7 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 			       void __user *arg, struct libcfs_ioctl_hdr *hdr)
 {
 	struct libcfs_ioctl_data *data = NULL;
-	int err = -EINVAL;
+	int err = 0;
 
 	/*
 	 * The libcfs_ioctl_data_adjust() function performs adjustment
@@ -134,7 +134,7 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 	switch (cmd) {
 	case IOC_LIBCFS_CLEAR_DEBUG:
 		libcfs_debug_clear_buffer();
-		return 0;
+		break;
 	/*
 	 * case IOC_LIBCFS_PANIC:
 	 * Handled in arch/cfs_module.c
@@ -144,7 +144,7 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0')
 			return -EINVAL;
 		libcfs_debug_mark_buffer(data->ioc_inlbuf1);
-		return 0;
+		break;
 
 	default: {
 		struct libcfs_ioctl_handler *hand;
@@ -161,8 +161,7 @@ static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
 			}
 		}
 		up_read(&ioctl_list_sem);
-		break;
-	}
+		break; }
 	}
 
 	return err;
-- 
1.7.1
