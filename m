From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:08 -0400
Subject: [lustre-devel] [PATCH 14/64 v2] staging: lustre: uapi: cleanup
	headers for lustre_ioctl.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

With the cleanups we no longer need to drag in tons of
user land headers. Lets simplify the include headers.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h    | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index a7e2fc4..fb87a8b 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -28,19 +28,11 @@
 #ifndef LUSTRE_IOCTL_H_
 #define LUSTRE_IOCTL_H_
 
+#include <linux/ioctl.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include "../../../../lustre/include/lustre/lustre_idl.h"
 
-#ifdef __KERNEL__
-# include <linux/ioctl.h>
-# include <linux/string.h>
-#else /* __KERNEL__ */
-# include <malloc.h>
-# include <string.h>
-#include <libcfs/util/ioctl.h>
-#endif /* !__KERNEL__ */
-
 #if !defined(__KERNEL__) && !defined(LUSTRE_UTILS)
 # error This file is for Lustre internal use only.
 #endif
-- 
1.8.3.1
