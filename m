From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Nov 2015 12:22:07 -0500
Subject: [lustre-devel] [PATCH v2 1/7] staging: lustre: remove white space
	in libcfs_hash.h
In-Reply-To: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446484933-23571-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Cleanup all the unneeded white space in libcfs_hash.h.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |  135 ++++++++++----------
 1 files changed, 70 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 70b8b29..4d73f8a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -66,12 +66,12 @@
 #include <linux/hash.h>
 
 /** disable debug */
-#define CFS_HASH_DEBUG_NONE	 0
+#define CFS_HASH_DEBUG_NONE	0
 /** record hash depth and output to console when it's too deep,
  *  computing overhead is low but consume more memory */
-#define CFS_HASH_DEBUG_1	    1
+#define CFS_HASH_DEBUG_1	1
 /** expensive, check key validation */
-#define CFS_HASH_DEBUG_2	    2
+#define CFS_HASH_DEBUG_2	2
 
 #define CFS_HASH_DEBUG_LEVEL	CFS_HASH_DEBUG_NONE
 
@@ -108,16 +108,18 @@ struct cfs_hash_bucket {
  * cfs_hash bucket descriptor, it's normally in stack of caller
  */
 struct cfs_hash_bd {
-	struct cfs_hash_bucket	*bd_bucket;      /**< address of bucket */
-	unsigned int		bd_offset;      /**< offset in bucket */
+	/* address of bucket */
+	struct cfs_hash_bucket	*bd_bucket;
+	/* offset in bucket */
+	unsigned int		 bd_offset;
 };
 
-#define CFS_HASH_NAME_LEN	   16      /**< default name length */
-#define CFS_HASH_BIGNAME_LEN	64      /**< bigname for param tree */
+#define CFS_HASH_NAME_LEN	16	/**< default name length */
+#define CFS_HASH_BIGNAME_LEN	64	/**< bigname for param tree */
 
-#define CFS_HASH_BKT_BITS	   3       /**< default bits of bucket */
-#define CFS_HASH_BITS_MAX	   30      /**< max bits of bucket */
-#define CFS_HASH_BITS_MIN	   CFS_HASH_BKT_BITS
+#define CFS_HASH_BKT_BITS	3	/**< default bits of bucket */
+#define CFS_HASH_BITS_MAX	30	/**< max bits of bucket */
+#define CFS_HASH_BITS_MIN	CFS_HASH_BKT_BITS
 
 /**
  * common hash attributes.
@@ -133,41 +135,41 @@ enum cfs_hash_tag {
 	 */
 	CFS_HASH_NO_LOCK	= 1 << 0,
 	/** no bucket lock, use one spinlock to protect the whole hash */
-	CFS_HASH_NO_BKTLOCK     = 1 << 1,
+	CFS_HASH_NO_BKTLOCK	= 1 << 1,
 	/** rwlock to protect bucket */
-	CFS_HASH_RW_BKTLOCK     = 1 << 2,
+	CFS_HASH_RW_BKTLOCK	= 1 << 2,
 	/** spinlock to protect bucket */
-	CFS_HASH_SPIN_BKTLOCK   = 1 << 3,
+	CFS_HASH_SPIN_BKTLOCK	= 1 << 3,
 	/** always add new item to tail */
-	CFS_HASH_ADD_TAIL       = 1 << 4,
+	CFS_HASH_ADD_TAIL	= 1 << 4,
 	/** hash-table doesn't have refcount on item */
-	CFS_HASH_NO_ITEMREF     = 1 << 5,
+	CFS_HASH_NO_ITEMREF	= 1 << 5,
 	/** big name for param-tree */
 	CFS_HASH_BIGNAME	= 1 << 6,
 	/** track global count */
 	CFS_HASH_COUNTER	= 1 << 7,
 	/** rehash item by new key */
-	CFS_HASH_REHASH_KEY     = 1 << 8,
+	CFS_HASH_REHASH_KEY	= 1 << 8,
 	/** Enable dynamic hash resizing */
-	CFS_HASH_REHASH	 = 1 << 9,
+	CFS_HASH_REHASH		= 1 << 9,
 	/** can shrink hash-size */
-	CFS_HASH_SHRINK	 = 1 << 10,
+	CFS_HASH_SHRINK		= 1 << 10,
 	/** assert hash is empty on exit */
-	CFS_HASH_ASSERT_EMPTY   = 1 << 11,
+	CFS_HASH_ASSERT_EMPTY	= 1 << 11,
 	/** record hlist depth */
-	CFS_HASH_DEPTH	  = 1 << 12,
+	CFS_HASH_DEPTH		= 1 << 12,
 	/**
 	 * rehash is always scheduled in a different thread, so current
 	 * change on hash table is non-blocking
 	 */
-	CFS_HASH_NBLK_CHANGE    = 1 << 13,
+	CFS_HASH_NBLK_CHANGE	= 1 << 13,
 	/** NB, we typed hs_flags as  __u16, please change it
 	 * if you need to extend >=16 flags */
 };
 
 /** most used attributes */
-#define CFS_HASH_DEFAULT       (CFS_HASH_RW_BKTLOCK | \
-				CFS_HASH_COUNTER | CFS_HASH_REHASH)
+#define CFS_HASH_DEFAULT	(CFS_HASH_RW_BKTLOCK | \
+				 CFS_HASH_COUNTER | CFS_HASH_REHASH)
 
 /**
  * cfs_hash is a hash-table implementation for general purpose, it can support:
@@ -211,7 +213,7 @@ enum cfs_hash_tag {
 struct cfs_hash {
 	/** serialize with rehash, or serialize all operations if
 	 * the hash-table has CFS_HASH_NO_BKTLOCK */
-	union cfs_hash_lock		 hs_lock;
+	union cfs_hash_lock		hs_lock;
 	/** hash operations */
 	struct cfs_hash_ops		*hs_ops;
 	/** hash lock operations */
@@ -219,57 +221,57 @@ struct cfs_hash {
 	/** hash list operations */
 	struct cfs_hash_hlist_ops	*hs_hops;
 	/** hash buckets-table */
-	struct cfs_hash_bucket	 **hs_buckets;
+	struct cfs_hash_bucket		**hs_buckets;
 	/** total number of items on this hash-table */
-	atomic_t		hs_count;
+	atomic_t			hs_count;
 	/** hash flags, see cfs_hash_tag for detail */
-	__u16		       hs_flags;
+	__u16				hs_flags;
 	/** # of extra-bytes for bucket, for user saving extended attributes */
-	__u16		       hs_extra_bytes;
+	__u16				hs_extra_bytes;
 	/** wants to iterate */
-	__u8			hs_iterating;
+	__u8				hs_iterating;
 	/** hash-table is dying */
-	__u8			hs_exiting;
+	__u8				hs_exiting;
 	/** current hash bits */
-	__u8			hs_cur_bits;
+	__u8				hs_cur_bits;
 	/** min hash bits */
-	__u8			hs_min_bits;
+	__u8				hs_min_bits;
 	/** max hash bits */
-	__u8			hs_max_bits;
+	__u8				hs_max_bits;
 	/** bits for rehash */
-	__u8			hs_rehash_bits;
+	__u8				hs_rehash_bits;
 	/** bits for each bucket */
-	__u8			hs_bkt_bits;
+	__u8				hs_bkt_bits;
 	/** resize min threshold */
-	__u16		       hs_min_theta;
+	__u16				hs_min_theta;
 	/** resize max threshold */
-	__u16		       hs_max_theta;
+	__u16				hs_max_theta;
 	/** resize count */
-	__u32		       hs_rehash_count;
+	__u32				hs_rehash_count;
 	/** # of iterators (caller of cfs_hash_for_each_*) */
-	__u32		       hs_iterators;
+	__u32				hs_iterators;
 	/** rehash workitem */
-	cfs_workitem_t	      hs_rehash_wi;
+	cfs_workitem_t			hs_rehash_wi;
 	/** refcount on this hash table */
-	atomic_t		hs_refcount;
+	atomic_t			hs_refcount;
 	/** rehash buckets-table */
-	struct cfs_hash_bucket	 **hs_rehash_buckets;
+	struct cfs_hash_bucket		**hs_rehash_buckets;
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 	/** serialize debug members */
 	spinlock_t			hs_dep_lock;
 	/** max depth */
-	unsigned int		hs_dep_max;
+	unsigned int			hs_dep_max;
 	/** id of the deepest bucket */
-	unsigned int		hs_dep_bkt;
+	unsigned int			hs_dep_bkt;
 	/** offset in the deepest bucket */
-	unsigned int		hs_dep_off;
+	unsigned int			hs_dep_off;
 	/** bits when we found the max depth */
-	unsigned int		hs_dep_bits;
+	unsigned int			hs_dep_bits;
 	/** workitem to output max depth */
-	cfs_workitem_t	      hs_dep_wi;
+	cfs_workitem_t			hs_dep_wi;
 #endif
 	/** name of htable */
-	char			hs_name[0];
+	char				hs_name[0];
 };
 
 struct cfs_hash_lock_ops {
@@ -324,11 +326,11 @@ struct cfs_hash_ops {
 };
 
 /** total number of buckets in @hs */
-#define CFS_HASH_NBKT(hs)       \
+#define CFS_HASH_NBKT(hs)	\
 	(1U << ((hs)->hs_cur_bits - (hs)->hs_bkt_bits))
 
 /** total number of buckets in @hs while rehashing */
-#define CFS_HASH_RH_NBKT(hs)    \
+#define CFS_HASH_RH_NBKT(hs)	\
 	(1U << ((hs)->hs_rehash_bits - (hs)->hs_bkt_bits))
 
 /** number of hlist for in bucket */
@@ -433,19 +435,22 @@ cfs_hash_with_nblk_change(struct cfs_hash *hs)
 
 static inline int
 cfs_hash_is_exiting(struct cfs_hash *hs)
-{       /* cfs_hash_destroy is called */
+{
+	/* cfs_hash_destroy is called */
 	return hs->hs_exiting;
 }
 
 static inline int
 cfs_hash_is_rehashing(struct cfs_hash *hs)
-{       /* rehash is launched */
+{
+	/* rehash is launched */
 	return hs->hs_rehash_bits != 0;
 }
 
 static inline int
 cfs_hash_is_iterating(struct cfs_hash *hs)
-{       /* someone is calling cfs_hash_for_each_* */
+{
+	/* someone is calling cfs_hash_for_each_* */
 	return hs->hs_iterating || hs->hs_iterators != 0;
 }
 
@@ -758,7 +763,7 @@ static inline void
 cfs_hash_bucket_validate(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			 struct hlist_node *hnode)
 {
-	struct cfs_hash_bd   bds[2];
+	struct cfs_hash_bd bds[2];
 
 	cfs_hash_dual_bd_get(hs, cfs_hash_key(hs, hnode), bds);
 	LASSERT(bds[0].bd_bucket == bd->bd_bucket ||
@@ -777,9 +782,9 @@ cfs_hash_bucket_validate(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 
 #endif /* CFS_HASH_DEBUG_LEVEL */
 
-#define CFS_HASH_THETA_BITS  10
-#define CFS_HASH_MIN_THETA  (1U << (CFS_HASH_THETA_BITS - 1))
-#define CFS_HASH_MAX_THETA  (1U << (CFS_HASH_THETA_BITS + 1))
+#define CFS_HASH_THETA_BITS	10
+#define CFS_HASH_MIN_THETA	(1U << (CFS_HASH_THETA_BITS - 1))
+#define CFS_HASH_MAX_THETA	(1U << (CFS_HASH_THETA_BITS + 1))
 
 /* Return integer component of theta */
 static inline int __cfs_hash_theta_int(int theta)
@@ -848,20 +853,20 @@ cfs_hash_u64_hash(const __u64 key, unsigned mask)
 }
 
 /** iterate over all buckets in @bds (array of struct cfs_hash_bd) */
-#define cfs_hash_for_each_bd(bds, n, i) \
+#define cfs_hash_for_each_bd(bds, n, i)	\
 	for (i = 0; i < n && (bds)[i].bd_bucket != NULL; i++)
 
 /** iterate over all buckets of @hs */
-#define cfs_hash_for_each_bucket(hs, bd, pos)		   \
-	for (pos = 0;					   \
-	     pos < CFS_HASH_NBKT(hs) &&			 \
+#define cfs_hash_for_each_bucket(hs, bd, pos)			\
+	for (pos = 0;						\
+	     pos < CFS_HASH_NBKT(hs) &&				\
 	     ((bd)->bd_bucket = (hs)->hs_buckets[pos]) != NULL; pos++)
 
 /** iterate over all hlist of bucket @bd */
-#define cfs_hash_bd_for_each_hlist(hs, bd, hlist)	       \
-	for ((bd)->bd_offset = 0;			       \
-	     (bd)->bd_offset < CFS_HASH_BKT_NHLIST(hs) &&       \
-	     (hlist = cfs_hash_bd_hhead(hs, bd)) != NULL;       \
+#define cfs_hash_bd_for_each_hlist(hs, bd, hlist)		\
+	for ((bd)->bd_offset = 0;				\
+	     (bd)->bd_offset < CFS_HASH_BKT_NHLIST(hs) &&	\
+	     (hlist = cfs_hash_bd_hhead(hs, bd)) != NULL;	\
 	     (bd)->bd_offset++)
 
 /* !__LIBCFS__HASH_H__ */
-- 
1.7.1
