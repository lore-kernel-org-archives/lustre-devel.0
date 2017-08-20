From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:13 -0400
Subject: [lustre-devel] [PATCH 19/64 v2] staging: lustre: uapi: label
	lustre_param.h as an uapi header
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change LUSTRE_PARAM_H_ to _UAPI_LUSTRE_PARAM_H_ now that is
a proper UAPI header

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24325
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
index f6f4752..cab0056 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
@@ -29,15 +29,13 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * lustre/include/lustre_param.h
- *
  * User-settable parameter keys
  *
  * Author: Nathan Rutman <nathan@clusterfs.com>
  */
 
-#ifndef _LUSTRE_PARAM_H
-#define _LUSTRE_PARAM_H
+#ifndef _UAPI_LUSTRE_PARAM_H_
+#define _UAPI_LUSTRE_PARAM_H_
 
 /** \defgroup param param
  *
@@ -92,4 +90,4 @@
 
 /** @} param */
 
-#endif /* _LUSTRE_PARAM_H */
+#endif /* _UAPI_LUSTRE_PARAM_H_ */
-- 
1.8.3.1
