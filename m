From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Nov 2015 12:22:10 -0500
Subject: [lustre-devel] [PATCH v2 4/7] staging: lustre: use proper comment
	blocks for libcfs_hash.h
In-Reply-To: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446484933-23571-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The script checkpatch.pl reported problems with the style of
the comment blocks. This patch resolves those problems.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   21 +++++++++++++------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 2e0c892..87dee16 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -61,8 +61,10 @@
 
 /** disable debug */
 #define CFS_HASH_DEBUG_NONE	0
-/** record hash depth and output to console when it's too deep,
- *  computing overhead is low but consume more memory */
+/*
+ * record hash depth and output to console when it's too deep,
+ * computing overhead is low but consume more memory
+ */
 #define CFS_HASH_DEBUG_1	1
 /** expensive, check key validation */
 #define CFS_HASH_DEBUG_2	2
@@ -158,7 +160,8 @@ enum cfs_hash_tag {
 	 */
 	CFS_HASH_NBLK_CHANGE	= 1 << 13,
 	/** NB, we typed hs_flags as  __u16, please change it
-	 * if you need to extend >=16 flags */
+	 * if you need to extend >=16 flags
+	 */
 };
 
 /** most used attributes */
@@ -205,8 +208,10 @@ enum cfs_hash_tag {
  */
 
 struct cfs_hash {
-	/** serialize with rehash, or serialize all operations if
-	 * the hash-table has CFS_HASH_NO_BKTLOCK */
+	/*
+	 * serialize with rehash, or serialize all operations if
+	 * the hash-table has CFS_HASH_NO_BKTLOCK
+	 */
 	union cfs_hash_lock		hs_lock;
 	/** hash operations */
 	struct cfs_hash_ops		*hs_ops;
@@ -373,9 +378,11 @@ cfs_hash_with_add_tail(struct cfs_hash *hs)
 static inline int
 cfs_hash_with_no_itemref(struct cfs_hash *hs)
 {
-	/* hash-table doesn't keep refcount on item,
+	/*
+	 * hash-table doesn't keep refcount on item,
 	 * item can't be removed from hash unless it's
-	 * ZERO refcount */
+	 * ZERO refcount.
+	 */
 	return (hs->hs_flags & CFS_HASH_NO_ITEMREF) != 0;
 }
 
-- 
1.7.1
