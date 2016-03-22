From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:04:05 -0400
Subject: [lustre-devel] [PATCH 18/29] staging:lustre: remove the
	IOC_LIBCFS_MEMHOG ioctl
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>

From: Parinay Kondekar <parinay.kondekar@seagate.com>

The IOC_LIBCFS_MEMHOG is not needed so remove the last bits.

Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
Reviewed-on: http://review.whamcloud.com/17492
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index d158cd1..2e4e31b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -100,7 +100,7 @@ do {						    \
 /* IOC_LIBCFS_PANIC obsolete in 2.8.0, was _IOWR('e', 30, IOCTL_LIBCFS_TYPE) */
 #define IOC_LIBCFS_CLEAR_DEBUG	     _IOWR('e', 31, long)
 #define IOC_LIBCFS_MARK_DEBUG	      _IOWR('e', 32, long)
-#define IOC_LIBCFS_MEMHOG		  _IOWR('e', 36, long)
+/* IOC_LIBCFS_MEMHOG obsolete in 2.8.0, was _IOWR('e', 36, IOCTL_LIBCFS_TYPE) */
 /* lnet ioctls */
 #define IOC_LIBCFS_GET_NI		  _IOWR('e', 50, long)
 #define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, long)
-- 
1.7.1
