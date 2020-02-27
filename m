From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:09 -0500
Subject: [lustre-devel] [PATCH 381/622] lustre: obdclass: generate random
 u64 max correctly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-382-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Generate random u64 max number correctly, and make it an obdclass
function lu_prandom_u64_max().

Fixes: bcfa98a507 ("staging: lustre: replace cfs_rand() with prandom_u32_max()")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12495
Lustre-commit: 645b72c5c058 ("LU-12495 obdclass: generate random u64 max correctly")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35394
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h |  1 +
 fs/lustre/lmv/lmv_qos.c       | 26 +-------------------------
 fs/lustre/obdclass/lu_qos.c   | 36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 0f3e3be..6b1064a 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1390,6 +1390,7 @@ struct lu_qos {
 
 int lqos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
 int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd);
+u64 lu_prandom_u64_max(u64 ep_ro);
 
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/fs/lustre/lmv/lmv_qos.c b/fs/lustre/lmv/lmv_qos.c
index e323398..85053d2e 100644
--- a/fs/lustre/lmv/lmv_qos.c
+++ b/fs/lustre/lmv/lmv_qos.c
@@ -370,31 +370,7 @@ struct lu_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
 		total_weight += tgt->ltd_qos.ltq_weight;
 	}
 
-	if (total_weight) {
-#if BITS_PER_LONG == 32
-		/*
-		 * If total_weight > 32-bit, first generate the high
-		 * 32 bits of the random number, then add in the low
-		 * 32 bits (truncated to the upper limit, if needed)
-		 */
-		if (total_weight > 0xffffffffULL)
-			rand = (u64)(prandom_u32_max(
-				(unsigned int)(total_weight >> 32)) << 32;
-		else
-			rand = 0;
-
-		if (rand == (total_weight & 0xffffffff00000000ULL))
-			rand |= prandom_u32_max((unsigned int)total_weight);
-		else
-			rand |= prandom_u32();
-
-#else
-		rand = ((u64)prandom_u32() << 32 | prandom_u32()) %
-			total_weight;
-#endif
-	} else {
-		rand = 0;
-	}
+	rand = lu_prandom_u64_max(total_weight);
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		tgt = lmv->tgts[i];
diff --git a/fs/lustre/obdclass/lu_qos.c b/fs/lustre/obdclass/lu_qos.c
index 4ee3f59..9fdcbc2 100644
--- a/fs/lustre/obdclass/lu_qos.c
+++ b/fs/lustre/obdclass/lu_qos.c
@@ -35,6 +35,7 @@
 
 #include <linux/module.h>
 #include <linux/list.h>
+#include <linux/random.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_disk.h>
@@ -164,3 +165,38 @@ int lqos_del_tgt(struct lu_qos *qos, struct lu_tgt_desc *ltd)
 	return rc;
 }
 EXPORT_SYMBOL(lqos_del_tgt);
+
+/**
+ * lu_prandom_u64_max - returns a pseudo-random u64 number in interval
+ * [0, ep_ro)
+ *
+ * #ep_ro	right open interval endpoint
+ *
+ * Return:	a pseudo-random 64-bit number that is in interval [0, ep_ro).
+ */
+u64 lu_prandom_u64_max(u64 ep_ro)
+{
+	u64 rand = 0;
+
+	if (ep_ro) {
+#if BITS_PER_LONG == 32
+		/*
+		 * If ep_ro > 32-bit, first generate the high
+		 * 32 bits of the random number, then add in the low
+		 * 32 bits (truncated to the upper limit, if needed)
+		 */
+		if (ep_ro > 0xffffffffULL)
+			rand = prandom_u32_max((u32)(ep_ro >> 32)) << 32;
+
+		if (rand == (ep_ro & 0xffffffff00000000ULL))
+			rand |= prandom_u32_max((u32)ep_ro);
+		else
+			rand |= prandom_u32();
+#else
+		rand = ((u64)prandom_u32() << 32 | prandom_u32()) % ep_ro;
+#endif
+	}
+
+	return rand;
+}
+EXPORT_SYMBOL(lu_prandom_u64_max);
-- 
1.8.3.1
