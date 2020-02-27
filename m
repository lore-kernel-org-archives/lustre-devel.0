From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:07 -0500
Subject: [lustre-devel] [PATCH 199/622] lnet: add fault injection for bulk
 transfers
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-200-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Artem Blagodarenko <artem.blagodarenko@seagate.com>

An internal test was always passing due to nno fault injecytion
happening. Add CFS_FAIL_PTLRPC_OST_BULK_CB2 to simulation a bulk
transfer timeout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7159
Lustre-commit: 707820692275 ("LU-7159 tests: fix 224c fault injection")
Signed-off-by: Artem Blagodarenko <artem.blagodarenko@seagate.com>
Xyratex-bug-id: MRP-2472
Reviewed-on: https://review.whamcloud.com/16426
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h    | 1 +
 include/linux/libcfs/libcfs_fail.h | 6 ++++++
 include/linux/lnet/lib-lnet.h      | 3 +++
 net/lnet/lnet/lib-move.c           | 6 +++++-
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 5ff270a..d9a0395 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -487,6 +487,7 @@
 #define OBD_FAIL_FLR_LV_INC			0x1A02
 #define OBD_FAIL_FLR_RANDOM_PICK_MIRROR	0x1A03
 
+/* LNet is allocated failure locations 0xe000 to 0xffff */
 /* Assign references to moved code to reduce code changes */
 #define OBD_FAIL_PRECHECK(id)			CFS_FAIL_PRECHECK(id)
 #define OBD_FAIL_CHECK(id)			CFS_FAIL_CHECK(id)
diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
index f52a82a..c341567 100644
--- a/include/linux/libcfs/libcfs_fail.h
+++ b/include/linux/libcfs/libcfs_fail.h
@@ -54,6 +54,12 @@ enum {
 	CFS_FAIL_LOC_VALUE	= 3
 };
 
+/* Failure ranges
+ * "0x0100 - 0x3fff" for Lustre
+ * "0xe000 - 0xefff" for LNet
+ * "0xf000 - 0xffff" for LNDs
+ */
+
 /* Failure injection control */
 #define CFS_FAIL_MASK_SYS	0x0000FF00
 #define CFS_FAIL_MASK_LOC	(0x000000FF | CFS_FAIL_MASK_SYS)
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index bbb678f..d09fb4c 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -49,6 +49,9 @@
 #include <uapi/linux/lnet/lnetctl.h>
 #include <uapi/linux/lnet/nidstr.h>
 
+/* LNET has 0xeXXX */
+#define CFS_FAIL_PTLRPC_OST_BULK_CB2	0xe000
+
 extern struct lnet the_lnet;	/* THE network */
 
 #if (BITS_PER_LONG == 32)
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 3bcac03..f5548eb 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4323,7 +4323,11 @@ void lnet_monitor_thr_stop(void)
 	if (ack == LNET_ACK_REQ)
 		lnet_attach_rsp_tracker(rspt, cpt, md, mdh);
 
-	rc = lnet_send(self, msg, LNET_NID_ANY);
+	if (CFS_FAIL_CHECK_ORSET(CFS_FAIL_PTLRPC_OST_BULK_CB2,
+				 CFS_FAIL_ONCE))
+		rc = -EIO;
+	else
+		rc = lnet_send(self, msg, LNET_NID_ANY);
 	if (rc) {
 		CNETERR("Error sending PUT to %s: %d\n",
 			libcfs_id2str(target), rc);
-- 
1.8.3.1
