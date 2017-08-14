From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:53 -0400
Subject: [lustre-devel] [PATCH 25/64] staging: lustre: uapi: move
	lustre_cfg.h to uapi directory
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move lustre_cfg.h to its proper place. Adjust additonal headers
included in lustre_cfg.h.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../{lustre/include => include/uapi/linux/lustre}/lustre_cfg.h      | 6 ++----
 drivers/staging/lustre/lustre/include/lprocfs_status.h              | 2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h                  | 2 +-
 3 files changed, 4 insertions(+), 6 deletions(-)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux/lustre}/lustre_cfg.h (99%)

diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
similarity index 99%
rename from drivers/staging/lustre/lustre/include/lustre_cfg.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index 21a48b1..a762aab 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -33,6 +33,8 @@
 #ifndef _LUSTRE_CFG_H
 #define _LUSTRE_CFG_H
 
+#include "../../../../lustre/include/lustre/lustre_user.h"
+
 /** \defgroup cfg cfg
  *
  * @{
@@ -191,8 +193,6 @@ static inline __u32 lustre_cfg_len(__u32 bufcount, __u32 *buflens)
 	return cfs_size_round(len);
 }
 
-#include "obd_support.h"
-
 static inline void lustre_cfg_init(struct lustre_cfg *lcfg, int cmd,
 				   struct lustre_cfg_bufs *bufs)
 {
@@ -238,8 +238,6 @@ static inline int lustre_cfg_sanity_check(void *buf, size_t len)
 	return 0;
 }
 
-#include "lustre/lustre_user.h"
-
 /** @} cfg */
 
 #endif /* _LUSTRE_CFG_H */
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 9054d37..694062a 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -44,7 +44,7 @@
 #include <linux/types.h>
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "lustre_cfg.h"
+#include "../../include/uapi/linux/lustre/lustre_cfg.h"
 #include "lustre/lustre_idl.h"
 
 struct lprocfs_vars {
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index f24970d..c68dd5d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -48,7 +48,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_ver.h"
-#include "lustre_cfg.h"
+#include "../../include/uapi/linux/lustre/lustre_cfg.h"
 
 /* target.c */
 struct ptlrpc_request;
-- 
1.8.3.1
