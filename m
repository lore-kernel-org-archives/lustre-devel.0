From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:00 -0400
Subject: [lustre-devel] [PATCH 13/29] staging: lustre: libcfs: change
	variable name
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, Liang Zhen <liang.zhen@intel.com>

Change arg to uparam name for libcfs_ioctl().

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 97fc905..839145e 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -113,14 +113,14 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
 static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
-			void __user *arg)
+			void __user *uparam)
 {
 	struct libcfs_ioctl_data *data = NULL;
 	struct libcfs_ioctl_hdr *hdr;
 	int err;
 
 	/* 'cmd' and permissions get checked in our arch-specific caller */
-	err = libcfs_ioctl_getdata(&hdr, arg);
+	err = libcfs_ioctl_getdata(&hdr, uparam);
 	if (err) {
 		CDEBUG_LIMIT(D_ERROR,
 			     "libcfs ioctl: data header error %d\n", err);
@@ -169,7 +169,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 				continue;
 
 			if (!err)
-				err = libcfs_ioctl_popdata(arg, hdr,
+				err = libcfs_ioctl_popdata(uparam, hdr,
 							   hdr->ioc_len);
 			break;
 		}
-- 
1.7.1
