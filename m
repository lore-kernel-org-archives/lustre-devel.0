Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1BA7BC25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:14:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15L50Yblz21HK;
	Mon, 23 Jan 2023 15:05:33 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15HZ2GKZz1yGC
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:03:22 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 437016D3;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3FCAA58991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:24 -0500
Message-Id: <1674514855-15399-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/42] lustre: pools: force creation of a
 component without a pool
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <eaujames@ddn.com>

This patch add the pool type "ignore" to force the creation of
component without a pool set by inheritance (from parent or root).

The poorly-named "none" keyword, which indicates the pool name
should be inherited from the root or parent dir layout, will be
eventually replaced by the new "inherit" keyword.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15707
Lustre-commit: 6b69d22e4cb738f4f ("LU-15707 lod: force creation of a component without a pool")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46955
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h           |  4 +++
 include/uapi/linux/lustre/lustre_user.h | 39 ++++++++++++++++++++-----
 2 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 80ff4e8aa267..9edd93cbacc5 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -817,6 +817,10 @@ static inline int obd_pool_new(struct obd_device *obd, char *poolname)
 		return -EOPNOTSUPP;
 	}
 
+	/* Check poolname validity */
+	if (!poolname || poolname[0] == '\0' || lov_pool_is_reserved(poolname))
+		return -EINVAL;
+
 	rc = OBP(obd, pool_new)(obd, poolname);
 	return rc;
 }
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index c2096ba1cdbe..a2f46e7f4257 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -435,6 +435,17 @@ struct ll_ioc_lease_id {
 #define LOV_PATTERN_F_HOLE	0x40000000 /* there is hole in LOV EA */
 #define LOV_PATTERN_F_RELEASED	0x80000000 /* HSM released file */
 
+#define LOV_OFFSET_DEFAULT      ((__u16)-1)
+#define LMV_OFFSET_DEFAULT      ((__u32)-1)
+
+static inline bool lov_pattern_supported(__u32 pattern)
+{
+	return (pattern & ~LOV_PATTERN_F_RELEASED) == LOV_PATTERN_RAID0 ||
+	       (pattern & ~LOV_PATTERN_F_RELEASED) ==
+			(LOV_PATTERN_RAID0 | LOV_PATTERN_OVERSTRIPING) ||
+	       (pattern & ~LOV_PATTERN_F_RELEASED) == LOV_PATTERN_MDT;
+}
+
 /* RELEASED and MDT patterns are not valid in many places, so rather than
  * having many extra checks on lov_pattern_supported, we have this separate
  * check for non-released, non-DOM components
@@ -448,15 +459,29 @@ static inline bool lov_pattern_supported_normal_comp(__u32 pattern)
 
 #define LOV_MAXPOOLNAME 15
 #define LOV_POOLNAMEF "%.15s"
-#define LOV_OFFSET_DEFAULT      ((__u16)-1)
-#define LMV_OFFSET_DEFAULT      ((__u32)-1)
+/* The poolname "ignore" is used to force a component creation without pool */
+#define LOV_POOL_IGNORE "ignore"
+/* The poolname "inherit" is used to force a component to inherit the pool from
+ * parent or root directory
+ */
+#define LOV_POOL_INHERIT "inherit"
+/* The poolname "none" is deprecated in 2.15 (same behavior as "inherit") */
+#define LOV_POOL_NONE "none"
 
-static inline bool lov_pattern_supported(__u32 pattern)
+static inline bool lov_pool_is_ignored(const char *pool)
 {
-	return (pattern & ~LOV_PATTERN_F_RELEASED) == LOV_PATTERN_RAID0 ||
-	       (pattern & ~LOV_PATTERN_F_RELEASED) ==
-			(LOV_PATTERN_RAID0 | LOV_PATTERN_OVERSTRIPING) ||
-	       (pattern & ~LOV_PATTERN_F_RELEASED) == LOV_PATTERN_MDT;
+	return pool && strncmp(pool, LOV_POOL_IGNORE, LOV_MAXPOOLNAME) == 0;
+}
+
+static inline bool lov_pool_is_inherited(const char *pool)
+{
+	return pool && (strncmp(pool, LOV_POOL_INHERIT, LOV_MAXPOOLNAME) == 0 ||
+			strncmp(pool, LOV_POOL_NONE, LOV_MAXPOOLNAME) == 0);
+}
+
+static inline bool lov_pool_is_reserved(const char *pool)
+{
+	return lov_pool_is_ignored(pool) || lov_pool_is_inherited(pool);
 }
 
 #define LOV_MIN_STRIPE_BITS	16	/* maximum PAGE_SIZE (ia64), power of 2 */
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
