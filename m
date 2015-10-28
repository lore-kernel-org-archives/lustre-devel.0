From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:30 -0400
Subject: [lustre-devel] [PATCH 09/10] staging: lustre: fix remaining
	checkpatch issues for libcfs_hash.h
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Final cleanup to make libcfs_hash.h completely kernel standard
compliant.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 5df8ba2..563b2b4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -62,7 +62,8 @@
 /** disable debug */
 #define CFS_HASH_DEBUG_NONE	0
 /** record hash depth and output to console when it's too deep,
- *  computing overhead is low but consume more memory */
+ *  computing overhead is low but consume more memory
+ */
 #define CFS_HASH_DEBUG_1	1
 /** expensive, check key validation */
 #define CFS_HASH_DEBUG_2	2
@@ -158,7 +159,8 @@ enum cfs_hash_tag {
 	 */
 	CFS_HASH_NBLK_CHANGE	= 1 << 13,
 	/** NB, we typed hs_flags as  __u16, please change it
-	 * if you need to extend >=16 flags */
+	 * if you need to extend >=16 flags
+	 */
 };
 
 /** most used attributes */
@@ -206,7 +208,8 @@ enum cfs_hash_tag {
 
 struct cfs_hash {
 	/** serialize with rehash, or serialize all operations if
-	 * the hash-table has CFS_HASH_NO_BKTLOCK */
+	 * the hash-table has CFS_HASH_NO_BKTLOCK
+	 */
 	union cfs_hash_lock		hs_lock;
 	/** hash operations */
 	struct cfs_hash_ops		*hs_ops;
@@ -375,7 +378,8 @@ cfs_hash_with_no_itemref(struct cfs_hash *hs)
 {
 	/* hash-table doesn't keep refcount on item,
 	 * item can't be removed from hash unless it's
-	 * ZERO refcount */
+	 * ZERO refcount.
+	 */
 	return (hs->hs_flags & CFS_HASH_NO_ITEMREF) != 0;
 }
 
@@ -820,7 +824,7 @@ cfs_hash_djb2_hash(const void *key, size_t size, unsigned mask)
 {
 	unsigned i, hash = 5381;
 
-	LASSERT(key != NULL);
+	LASSERT(key);
 
 	for (i = 0; i < size; i++)
 		hash = hash * 33 + ((char *)key)[i];
@@ -848,7 +852,7 @@ cfs_hash_u64_hash(const __u64 key, unsigned mask)
 
 /** iterate over all buckets in @bds (array of struct cfs_hash_bd) */
 #define cfs_hash_for_each_bd(bds, n, i)	\
-	for (i = 0; i < n && (bds)[i].bd_bucket != NULL; i++)
+	for (i = 0; i < n && (bds)[i].bd_bucket; i++)
 
 /** iterate over all buckets of @hs */
 #define cfs_hash_for_each_bucket(hs, bd, pos)			\
-- 
1.7.1
