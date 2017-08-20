From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:07 -0400
Subject: [lustre-devel] [PATCH 13/64 v2] staging: lustre: uapi: use
	__ALIGN_KERNEL for lustre_ioctl.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Replace cfs_size_round() standard __ALIGN_KERNEL macro. This
removes the dependency of libcfs.h which is a kernel only
header.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h  | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index 880dd92..a7e2fc4 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -28,8 +28,8 @@
 #ifndef LUSTRE_IOCTL_H_
 #define LUSTRE_IOCTL_H_
 
+#include <linux/kernel.h>
 #include <linux/types.h>
-#include "../../../linux/libcfs/libcfs.h"
 #include "../../../../lustre/include/lustre/lustre_idl.h"
 
 #ifdef __KERNEL__
@@ -121,12 +121,12 @@ struct obd_ioctl_hdr {
 
 static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 {
-	__u32 len = cfs_size_round(sizeof(*data));
+	__u32 len = __ALIGN_KERNEL(sizeof(*data), 8);
 
-	len += cfs_size_round(data->ioc_inllen1);
-	len += cfs_size_round(data->ioc_inllen2);
-	len += cfs_size_round(data->ioc_inllen3);
-	len += cfs_size_round(data->ioc_inllen4);
+	len += __ALIGN_KERNEL(data->ioc_inllen1, 8);
+	len += __ALIGN_KERNEL(data->ioc_inllen2, 8);
+	len += __ALIGN_KERNEL(data->ioc_inllen3, 8);
+	len += __ALIGN_KERNEL(data->ioc_inllen4, 8);
 
 	return len;
 }
-- 
1.8.3.1
