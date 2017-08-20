From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:20 -0400
Subject: [lustre-devel] [PATCH 26/64 v2] staging: lustre: uapi: remove need
	for libcfs.h from lustre_cfg.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Several libcfs.h macros are present in lustre_cfg.h, but libcfs.h
is not available so lets replace those macros with real code.
The header libcfs.h also provides errno.h so with libcfs.h gone
include errno.h directly.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lustre/lustre_cfg.h | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index a762aab..a45d167 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -33,6 +33,8 @@
 #ifndef _LUSTRE_CFG_H
 #define _LUSTRE_CFG_H
 
+#include <linux/errno.h>
+#include <linux/kernel.h>
 #include "../../../../lustre/include/lustre/lustre_user.h"
 
 /** \defgroup cfg cfg
@@ -48,7 +50,7 @@
 #define LUSTRE_CFG_MAX_BUFCOUNT 8
 
 #define LCFG_HDR_SIZE(count) \
-	cfs_size_round(offsetof(struct lustre_cfg, lcfg_buflens[(count)]))
+	__ALIGN_KERNEL(offsetof(struct lustre_cfg, lcfg_buflens[(count)]), 8)
 
 /** If the LCFG_REQUIRED bit is set in a configuration command,
  * then the client is required to understand this parameter
@@ -165,7 +167,7 @@ static inline void *lustre_cfg_buf(struct lustre_cfg *lcfg, __u32 index)
 
 	offset = LCFG_HDR_SIZE(lcfg->lcfg_bufcount);
 	for (i = 0; i < index; i++)
-		offset += cfs_size_round(lcfg->lcfg_buflens[i]);
+		offset += __ALIGN_KERNEL(lcfg->lcfg_buflens[i], 8);
 	return (char *)lcfg + offset;
 }
 
@@ -188,9 +190,9 @@ static inline __u32 lustre_cfg_len(__u32 bufcount, __u32 *buflens)
 
 	len = LCFG_HDR_SIZE(bufcount);
 	for (i = 0; i < bufcount; i++)
-		len += cfs_size_round(buflens[i]);
+		len += __ALIGN_KERNEL(buflens[i], 8);
 
-	return cfs_size_round(len);
+	return __ALIGN_KERNEL(len, 8);
 }
 
 static inline void lustre_cfg_init(struct lustre_cfg *lcfg, int cmd,
@@ -206,7 +208,10 @@ static inline void lustre_cfg_init(struct lustre_cfg *lcfg, int cmd,
 	ptr = (char *)lcfg + LCFG_HDR_SIZE(lcfg->lcfg_bufcount);
 	for (i = 0; i < lcfg->lcfg_bufcount; i++) {
 		lcfg->lcfg_buflens[i] = bufs->lcfg_buflen[i];
-		LOGL((char *)bufs->lcfg_buf[i], bufs->lcfg_buflen[i], ptr);
+		if (bufs->lcfg_buf[i]) {
+			memcpy(ptr, bufs->lcfg_buf[i], bufs->lcfg_buflen[i]);
+			ptr += __ALIGN_KERNEL(bufs->lcfg_buflen[i], 8);
+		}
 	}
 }
 
-- 
1.8.3.1
