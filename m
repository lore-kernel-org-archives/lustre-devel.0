From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:05 -0400
Subject: [lustre-devel] [PATCH 37/64] staging: lustre: libcfs: sort headers
	in libcfs.h
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move all the included headers in libcfs.h to the top of the
file.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/28089
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   | 26 ++++++++++------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 71bb55e..3a5ebc2 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -33,9 +33,20 @@
 #ifndef __LIBCFS_LIBCFS_H__
 #define __LIBCFS_LIBCFS_H__
 
-#include "linux/libcfs.h"
 #include <linux/gfp.h>
+#include <linux/list.h>
 
+#include "../../uapi/linux/lnet/libcfs_ioctl.h"
+#include "linux/libcfs.h"
+#include "libcfs_debug.h"
+#include "libcfs_private.h"
+#include "libcfs_cpu.h"
+#include "libcfs_prim.h"
+#include "libcfs_time.h"
+#include "libcfs_string.h"
+#include "libcfs_workitem.h"
+#include "libcfs_hash.h"
+#include "libcfs_fail.h"
 #include "curproc.h"
 
 #define LIBCFS_VERSION "0.7.0"
@@ -49,8 +60,6 @@
 #define LERRCHKSUM(hexnum) (((hexnum) & 0xf) ^ ((hexnum) >> 4 & 0xf) ^ \
 			   ((hexnum) >> 8 & 0xf))
 
-#include <linux/list.h>
-
 /* need both kernel and user-land acceptor */
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
@@ -74,17 +83,6 @@
 void cfs_srand(unsigned int seed1, unsigned int seed2);
 void cfs_get_random_bytes(void *buf, int size);
 
-#include "libcfs_debug.h"
-#include "libcfs_cpu.h"
-#include "libcfs_private.h"
-#include "../../uapi/linux/lnet/libcfs_ioctl.h"
-#include "libcfs_prim.h"
-#include "libcfs_time.h"
-#include "libcfs_string.h"
-#include "libcfs_workitem.h"
-#include "libcfs_hash.h"
-#include "libcfs_fail.h"
-
 struct libcfs_ioctl_handler {
 	struct list_head item;
 	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
-- 
1.8.3.1
