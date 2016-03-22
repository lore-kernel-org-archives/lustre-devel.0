From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:52 -0400
Subject: [lustre-devel] [PATCH 05/29] staging: lustre: libcfs: add debugging
	info for libcfs_ioctl
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Added some lustre debugging to track down potential future
bugs.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 8beb954..b7575af 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -121,8 +121,11 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 
 	/* 'cmd' and permissions get checked in our arch-specific caller */
 	err = libcfs_ioctl_getdata(&hdr, arg);
-	if (err)
+	if (err) {
+		CDEBUG_LIMIT(D_ERROR,
+			     "libcfs ioctl: data header error %d\n", err);
 		return err;
+	}
 
 	/*
 	 * The libcfs_ioctl_data_adjust() function performs adjustment
@@ -137,6 +140,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 			goto out;
 	}
 
+	CDEBUG(D_IOCTL, "libcfs ioctl cmd %lu\n", cmd);
 	switch (cmd) {
 	case IOC_LIBCFS_CLEAR_DEBUG:
 		libcfs_debug_clear_buffer();
-- 
1.7.1
