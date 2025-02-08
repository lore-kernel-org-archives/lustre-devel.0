Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 70F61C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:37:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwQ4MG8z1y6d;
	Fri, 07 Feb 2025 16:31:02 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw64rFFz1xdb
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:46 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1E6BF182335;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1B6DC106BE18; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:21 -0500
Message-ID: <20250208003027.180076-16-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 15/21] lnet: libcfs: add unlikely to CFS_
 macros
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Fix the (hopefully) last few OBD_ users to use
CFS_ macros instead.

Add an 'unlikely()' to CFS_ macros. Some of the
OBD_ macros included this hint. Once those macros
are removed, the hint will be lost. Add it to the
CFS_ macros instead.

The libcfs_fail.h only has a couple style issues
left. Just fix them in this patch. Also have the
cfs_race code have a timeout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: bbfe5c8d211c8285a ("LU-12610 cfs: add unlikely to CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51291
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c               |  2 +-
 fs/lustre/llite/vvp_page.c         |  2 +-
 include/linux/libcfs/libcfs_fail.h | 66 +++++++++++++++++++-----------
 3 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index d2e400182ecf..276cad2b6eb7 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -2061,7 +2061,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	 * races with the page being unlocked after readpage() but before it's
 	 * used by the caller
 	 */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_READPAGE_PAUSE2, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_READPAGE_PAUSE2, cfs_fail_val);
 
 	return result;
 }
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 9994c3d292a9..9153e2d9656f 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -116,7 +116,7 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage,
 	} else {
 		SetPageError(vmpage);
 		if (ioret != -ENOSPC &&
-		    OBD_FAIL_CHECK(OBD_FAIL_LLITE_PANIC_ON_ESTALE))
+		    CFS_FAIL_CHECK(OBD_FAIL_LLITE_PANIC_ON_ESTALE))
 			LBUG();
 
 		mapping_set_error(inode->i_mapping, ioret);
diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
index 552aad66c5a6..2da3982534af 100644
--- a/include/linux/libcfs/libcfs_fail.h
+++ b/include/linux/libcfs/libcfs_fail.h
@@ -48,16 +48,17 @@ int __cfs_fail_check_set(u32 id, u32 value, int set);
 int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set);
 
 enum {
-	CFS_FAIL_LOC_NOSET	= 0,
-	CFS_FAIL_LOC_ORSET	= 1,
-	CFS_FAIL_LOC_RESET	= 2,
-	CFS_FAIL_LOC_VALUE	= 3
+	CFS_FAIL_LOC_NOSET = 0,
+	CFS_FAIL_LOC_ORSET = 1,
+	CFS_FAIL_LOC_RESET = 2,
+	CFS_FAIL_LOC_VALUE = 3
 };
 
-/* Failure ranges
- * "0x0100 - 0x3fff" for Lustre
- * "0xe000 - 0xefff" for LNet
- * "0xf000 - 0xffff" for LNDs
+/*
+ * Failure ranges:
+ *	"0x0100 - 0x3fff" for Lustre
+ *	"0xe000 - 0xefff" for LNet
+ *	"0xf000 - 0xffff" for LNDs
  */
 
 /* Failure injection control */
@@ -78,6 +79,7 @@ enum {
 #define CFS_FAIL_RAND	0x08000000 /* fail 1/N of the times */
 #define CFS_FAIL_USR1	0x04000000 /* user flag */
 
+/* CFS_FAULT may be combined with any one of the above flags. */
 #define CFS_FAULT	0x02000000 /* match any CFS_FAULT_CHECK */
 
 static inline bool CFS_FAIL_PRECHECK(u32 id)
@@ -87,6 +89,9 @@ static inline bool CFS_FAIL_PRECHECK(u32 id)
 		 (cfs_fail_loc & id & CFS_FAULT));
 }
 
+#define UNLIKELY_CHECK_SET(id, value, set, quiet) \
+	(unlikely(cfs_fail_check_set(id, value, set, quiet)))
+
 static inline int cfs_fail_check_set(u32 id, u32 value, int set, int quiet)
 {
 	unsigned long failed_once = cfs_fail_loc & CFS_FAILED; /* ok if racy */
@@ -108,38 +113,43 @@ static inline int cfs_fail_check_set(u32 id, u32 value, int set, int quiet)
 	return ret;
 }
 
-/* If id hit cfs_fail_loc, return 1, otherwise return 0 */
+/*
+ * If id hit cfs_fail_loc, return 1, otherwise return 0
+ */
 #define CFS_FAIL_CHECK(id) \
-	cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET, 0)
+	UNLIKELY_CHECK_SET(id, 0, CFS_FAIL_LOC_NOSET, 0)
 #define CFS_FAIL_CHECK_QUIET(id) \
-	cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET, 1)
+	UNLIKELY_CHECK_SET(id, 0, CFS_FAIL_LOC_NOSET, 1)
 
 /*
  * If id hit cfs_fail_loc and cfs_fail_val == (-1 or value) return 1,
  * otherwise return 0
  */
 #define CFS_FAIL_CHECK_VALUE(id, value) \
-	cfs_fail_check_set(id, value, CFS_FAIL_LOC_VALUE, 0)
+	UNLIKELY_CHECK_SET(id, value, CFS_FAIL_LOC_VALUE, 0)
 #define CFS_FAIL_CHECK_VALUE_QUIET(id, value) \
-	cfs_fail_check_set(id, value, CFS_FAIL_LOC_VALUE, 1)
+	UNLIKELY_CHECK_SET(id, value, CFS_FAIL_LOC_VALUE, 1)
 
 /*
  * If id hit cfs_fail_loc, cfs_fail_loc |= value and return 1,
  * otherwise return 0
  */
 #define CFS_FAIL_CHECK_ORSET(id, value) \
-	cfs_fail_check_set(id, value, CFS_FAIL_LOC_ORSET, 0)
+	UNLIKELY_CHECK_SET(id, value, CFS_FAIL_LOC_ORSET, 0)
 #define CFS_FAIL_CHECK_ORSET_QUIET(id, value) \
-	cfs_fail_check_set(id, value, CFS_FAIL_LOC_ORSET, 1)
+	UNLIKELY_CHECK_SET(id, value, CFS_FAIL_LOC_ORSET, 1)
 
 /*
  * If id hit cfs_fail_loc, cfs_fail_loc = value and return 1,
  * otherwise return 0
  */
 #define CFS_FAIL_CHECK_RESET(id, value) \
-	cfs_fail_check_set(id, value, CFS_FAIL_LOC_RESET, 0)
+	UNLIKELY_CHECK_SET(id, value, CFS_FAIL_LOC_RESET, 0)
 #define CFS_FAIL_CHECK_RESET_QUIET(id, value) \
-	cfs_fail_check_set(id, value, CFS_FAIL_LOC_RESET, 1)
+	UNLIKELY_CHECK_SET(id, value, CFS_FAIL_LOC_RESET, 1)
+
+#define UNLIKELY_TIMEOUT_SET(id, value, ms, set) \
+	(unlikely(cfs_fail_timeout_set(id, value, ms, set)))
 
 static inline int cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
 {
@@ -150,23 +160,23 @@ static inline int cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
 
 /* If id hit cfs_fail_loc, sleep for seconds or milliseconds */
 #define CFS_FAIL_TIMEOUT(id, secs) \
-	cfs_fail_timeout_set(id, 0, (secs) * 1000, CFS_FAIL_LOC_NOSET)
+	UNLIKELY_TIMEOUT_SET(id, 0, (secs) * 1000, CFS_FAIL_LOC_NOSET)
 
 #define CFS_FAIL_TIMEOUT_MS(id, ms) \
-	cfs_fail_timeout_set(id, 0, ms, CFS_FAIL_LOC_NOSET)
+	UNLIKELY_TIMEOUT_SET(id, 0, ms, CFS_FAIL_LOC_NOSET)
 
 /*
  * If id hit cfs_fail_loc, cfs_fail_loc |= value and
  * sleep seconds or milliseconds
  */
 #define CFS_FAIL_TIMEOUT_ORSET(id, value, secs) \
-	cfs_fail_timeout_set(id, value, (secs) * 1000, CFS_FAIL_LOC_ORSET)
+	UNLIKELY_TIMEOUT_SET(id, value, (secs) * 1000, CFS_FAIL_LOC_ORSET)
 
 #define CFS_FAIL_TIMEOUT_RESET(id, value, secs) \
-	cfs_fail_timeout_set(id, value, (secs) * 1000, CFS_FAIL_LOC_RESET)
+	UNLIKELY_TIMEOUT_SET(id, value, (secs) * 1000, CFS_FAIL_LOC_RESET)
 
 #define CFS_FAIL_TIMEOUT_MS_ORSET(id, value, ms) \
-	cfs_fail_timeout_set(id, value, ms, CFS_FAIL_LOC_ORSET)
+	UNLIKELY_TIMEOUT_SET(id, value, ms, CFS_FAIL_LOC_ORSET)
 
 #define CFS_FAULT_CHECK(id)			\
 	CFS_FAIL_CHECK(CFS_FAULT | (id))
@@ -185,8 +195,14 @@ static inline void cfs_race(u32 id)
 
 			cfs_race_state = 0;
 			CERROR("cfs_race id %x sleeping\n", id);
-			rc = wait_event_interruptible(cfs_race_waitq,
-						      !!cfs_race_state);
+			/*
+			 * XXX: don't wait forever as there is no guarantee
+			 * that this branch is executed first. for testing
+			 * purposes this construction works good enough
+			 */
+			rc = wait_event_interruptible_timeout(cfs_race_waitq,
+							      !!cfs_race_state,
+							      5 * HZ);
 			CERROR("cfs_fail_race id %x awake: rc=%d\n", id, rc);
 		} else {
 			CERROR("cfs_fail_race id %x waking\n", id);
@@ -219,7 +235,7 @@ static inline void cfs_race_wait(u32 id)
 			 * purposes this construction works good enough
 			 */
 			rc = wait_event_interruptible_timeout(cfs_race_waitq,
-							      cfs_race_state != 0,
+							      !!cfs_race_state,
 							      5 * HZ);
 			CERROR("cfs_fail_race id %x awake: rc=%d\n", id, rc);
 		}
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
