From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:48 -0400
Subject: [lustre-devel] [PATCH 01/29] staging: lustre: libcfs: replace
	LNET_MAX_IOCTL_BUF_LEN with something bigger
In-Reply-To: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
References: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1458687856-24959-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

The size of LNET_MAX_IOCTL_BUF_LEN restricts the size of
libcfs ioctl to the maximum needs of the LNet layer. Since
libcfs also handles things like debugging we might need
to let user land pass more data to or from the kernel than
what is possible

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11313
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    3 +++
 drivers/staging/lustre/lnet/libcfs/module.c        |    5 +----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 5ca99bd..c71d125 100644
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
 
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index cdc640b..f9f9d59 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -54,9 +54,6 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#define LNET_MAX_IOCTL_BUF_LEN (sizeof(struct lnet_ioctl_net_config) + \
-				sizeof(struct lnet_ioctl_config_data))
-
 #include "../../include/linux/libcfs/libcfs.h"
 #include <asm/div64.h>
 
@@ -186,7 +183,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 	 * do a check here to restrict the size of the memory
 	 * to allocate to guard against DoS attacks.
 	 */
-	if (buf_len > LNET_MAX_IOCTL_BUF_LEN) {
+	if (buf_len > LIBCFS_IOC_DATA_MAX) {
 		CERROR("LNET: user buffer exceeds kernel buffer\n");
 		return -EINVAL;
 	}
-- 
1.7.1
