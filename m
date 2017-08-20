From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:09 -0400
Subject: [lustre-devel] [PATCH 15/64 v2] staging: lustre: uapi: label
	lustre_ioctl.h as a UAPI header
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change LUSTRE_IOCTL_H_ to _UAPI_LUSTRE_IOCTL_H_ now that is
a proper UAPI header

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index fb87a8b..c2c0b27 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -25,8 +25,8 @@
  *
  * Copyright (c) 2011, 2015, Intel Corporation.
  */
-#ifndef LUSTRE_IOCTL_H_
-#define LUSTRE_IOCTL_H_
+#ifndef _UAPI_LUSTRE_IOCTL_H_
+#define _UAPI_LUSTRE_IOCTL_H_
 
 #include <linux/ioctl.h>
 #include <linux/kernel.h>
@@ -229,4 +229,4 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 
 #define IOC_OSC_SET_ACTIVE	_IOWR('h', 21, void *)
 
-#endif /* LUSTRE_IOCTL_H_ */
+#endif /* _UAPI_LUSTRE_IOCTL_H_ */
-- 
1.8.3.1
