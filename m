From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:27 -0500
Subject: [lustre-devel] [PATCH 59/60] staging: lustre: ptlrpc : remove
	userland usage from ptlrpc
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-60-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The reason for __REQ_LAYOUT_USER__ was to expose a
section of code in layout.c to userland for a utility
similar to wireshark. This was done before wireshark
existed but now that it does we no longer need to do
this type of hack. This also reduces lustre_acl.h to
strictly a kernel header now.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8945
Reviewed-on: https://review.whamcloud.com/24396
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_req_layout.h | 10 ++--------
 drivers/staging/lustre/lustre/ptlrpc/layout.c             |  9 ---------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index fbcd395..cd62ccd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -39,6 +39,8 @@
 #ifndef _LUSTRE_REQ_LAYOUT_H__
 #define _LUSTRE_REQ_LAYOUT_H__
 
+#include <linux/types.h>
+
 /** \defgroup req_layout req_layout
  *
  * @{
@@ -66,11 +68,6 @@ struct req_capsule {
 	__u32		    rc_area[RCL_NR][REQ_MAX_FIELD_NR];
 };
 
-#if !defined(__REQ_LAYOUT_USER__)
-
-/* struct ptlrpc_request, lustre_msg* */
-#include "lustre_net.h"
-
 void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
 		      enum req_location location);
 void req_capsule_fini(struct req_capsule *pill);
@@ -120,9 +117,6 @@ void req_capsule_shrink(struct req_capsule *pill,
 int  req_layout_init(void);
 void req_layout_fini(void);
 
-/* __REQ_LAYOUT_USER__ */
-#endif
-
 extern struct req_format RQF_OBD_PING;
 extern struct req_format RQF_OBD_SET_INFO;
 extern struct req_format RQF_SEC_CTX;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 2052848..356d735 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -42,8 +42,6 @@
  * of the format that the request conforms to.
  */
 
-#if !defined(__REQ_LAYOUT_USER__)
-
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/module.h>
@@ -57,8 +55,6 @@
 #include "../include/obd.h"
 #include "../include/obd_support.h"
 
-/* __REQ_LAYOUT_USER__ */
-#endif
 /* struct ptlrpc_request, lustre_msg* */
 #include "../include/lustre_req_layout.h"
 #include "../include/lustre_acl.h"
@@ -1558,8 +1554,6 @@ struct req_format RQF_OST_GET_INFO_FIEMAP =
 			ost_get_fiemap_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_FIEMAP);
 
-#if !defined(__REQ_LAYOUT_USER__)
-
 /* Convenience macro */
 #define FMT_FIELD(fmt, i, j) (fmt)->rf_fields[(i)].d[(j)]
 
@@ -2238,6 +2232,3 @@ void req_capsule_shrink(struct req_capsule *pill,
 							    1);
 }
 EXPORT_SYMBOL(req_capsule_shrink);
-
-/* __REQ_LAYOUT_USER__ */
-#endif
-- 
1.8.3.1
