From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:24 -0400
Subject: [lustre-devel] [PATCH 30/64 v2] staging: lustre: uapi: label
	lustre_cfg.h as an uapi header
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change LUSTRE_CFG_H to _UAPI_LUSTRE_CFG_H_ now that it is
a proper UAPI header.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index 2d37d1b..1533dcb 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -30,8 +30,8 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
-#ifndef _LUSTRE_CFG_H
-#define _LUSTRE_CFG_H
+#ifndef _UAPI_LUSTRE_CFG_H_
+#define _UAPI_LUSTRE_CFG_H_
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -258,4 +258,4 @@ static inline int lustre_cfg_sanity_check(void *buf, size_t len)
 
 /** @} cfg */
 
-#endif /* _LUSTRE_CFG_H */
+#endif /* _UAPI_LUSTRE_CFG_H_ */
-- 
1.8.3.1
