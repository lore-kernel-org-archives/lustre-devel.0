From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:28 -0400
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: cleanup over 80
	characters in libcfs_hash.h
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Fix up all the over 80 character line issues in libcfs_hash.h
reported by checkpatch.pl. At the same time update this header
to match what is in the OpenSFS lustre branch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |  162 +++++++++++---------
 1 files changed, 93 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index c9f550e..70b8b29 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -285,20 +285,22 @@ struct cfs_hash_lock_ops {
 
 struct cfs_hash_hlist_ops {
 	/** return hlist_head of hash-head of @bd */
-	struct hlist_head *(*hop_hhead)(struct cfs_hash *hs, struct cfs_hash_bd *bd);
+	struct hlist_head *(*hop_hhead)(struct cfs_hash *hs,
+					struct cfs_hash_bd *bd);
 	/** return hash-head size */
 	int (*hop_hhead_size)(struct cfs_hash *hs);
 	/** add @hnode to hash-head of @bd */
-	int (*hop_hnode_add)(struct cfs_hash *hs,
-			     struct cfs_hash_bd *bd, struct hlist_node *hnode);
+	int (*hop_hnode_add)(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			     struct hlist_node *hnode);
 	/** remove @hnode from hash-head of @bd */
-	int (*hop_hnode_del)(struct cfs_hash *hs,
-			     struct cfs_hash_bd *bd, struct hlist_node *hnode);
+	int (*hop_hnode_del)(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			     struct hlist_node *hnode);
 };
 
 struct cfs_hash_ops {
 	/** return hashed value from @key */
-	unsigned (*hs_hash)(struct cfs_hash *hs, const void *key, unsigned mask);
+	unsigned (*hs_hash)(struct cfs_hash *hs, const void *key,
+			    unsigned mask);
 	/** return key address of @hnode */
 	void *   (*hs_key)(struct hlist_node *hnode);
 	/** copy key from @hnode to @key */
@@ -315,7 +317,8 @@ struct cfs_hash_ops {
 	/** release refcount of item */
 	void     (*hs_put)(struct cfs_hash *hs, struct hlist_node *hnode);
 	/** release refcount of item, always called with holding bucket-lock */
-	void     (*hs_put_locked)(struct cfs_hash *hs, struct hlist_node *hnode);
+	void     (*hs_put_locked)(struct cfs_hash *hs,
+				  struct hlist_node *hnode);
 	/** it's called before removing of @hnode */
 	void     (*hs_exit)(struct cfs_hash *hs, struct hlist_node *hnode);
 };
@@ -546,22 +549,26 @@ static inline void cfs_hash_bd_unlock(struct cfs_hash *hs,
  * operations on cfs_hash bucket (bd: bucket descriptor),
  * they are normally for hash-table without rehash
  */
-void cfs_hash_bd_get(struct cfs_hash *hs, const void *key, struct cfs_hash_bd *bd);
+void cfs_hash_bd_get(struct cfs_hash *hs, const void *key,
+		     struct cfs_hash_bd *bd);
 
-static inline void cfs_hash_bd_get_and_lock(struct cfs_hash *hs, const void *key,
-					    struct cfs_hash_bd *bd, int excl)
+static inline void
+cfs_hash_bd_get_and_lock(struct cfs_hash *hs, const void *key,
+			 struct cfs_hash_bd *bd, int excl)
 {
 	cfs_hash_bd_get(hs, key, bd);
 	cfs_hash_bd_lock(hs, bd, excl);
 }
 
-static inline unsigned cfs_hash_bd_index_get(struct cfs_hash *hs, struct cfs_hash_bd *bd)
+static inline unsigned
+cfs_hash_bd_index_get(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
 	return bd->bd_offset | (bd->bd_bucket->hsb_index << hs->hs_bkt_bits);
 }
 
-static inline void cfs_hash_bd_index_set(struct cfs_hash *hs,
-					 unsigned index, struct cfs_hash_bd *bd)
+static inline void
+cfs_hash_bd_index_set(struct cfs_hash *hs, unsigned index,
+		      struct cfs_hash_bd *bd)
 {
 	bd->bd_bucket = hs->hs_buckets[index >> hs->hs_bkt_bits];
 	bd->bd_offset = index & (CFS_HASH_BKT_NHLIST(hs) - 1U);
@@ -611,68 +618,73 @@ void cfs_hash_bd_add_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 void cfs_hash_bd_del_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			    struct hlist_node *hnode);
 void cfs_hash_bd_move_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd_old,
-			     struct cfs_hash_bd *bd_new, struct hlist_node *hnode);
+			     struct cfs_hash_bd *bd_new,
+			     struct hlist_node *hnode);
 
-static inline int cfs_hash_bd_dec_and_lock(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-					   atomic_t *condition)
+static inline int
+cfs_hash_bd_dec_and_lock(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			 atomic_t *condition)
 {
 	LASSERT(cfs_hash_with_spin_bktlock(hs));
-	return atomic_dec_and_lock(condition,
-				       &bd->bd_bucket->hsb_lock.spin);
+	return atomic_dec_and_lock(condition, &bd->bd_bucket->hsb_lock.spin);
 }
 
-static inline struct hlist_head *cfs_hash_bd_hhead(struct cfs_hash *hs,
-						   struct cfs_hash_bd *bd)
+static inline struct hlist_head *
+cfs_hash_bd_hhead(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
 	return hs->hs_hops->hop_hhead(hs, bd);
 }
 
-struct hlist_node *cfs_hash_bd_lookup_locked(struct cfs_hash *hs,
-					     struct cfs_hash_bd *bd, const void *key);
-struct hlist_node *cfs_hash_bd_peek_locked(struct cfs_hash *hs,
-					   struct cfs_hash_bd *bd, const void *key);
-struct hlist_node *cfs_hash_bd_findadd_locked(struct cfs_hash *hs,
-					      struct cfs_hash_bd *bd, const void *key,
-					     struct hlist_node *hnode,
-					     int insist_add);
-struct hlist_node *cfs_hash_bd_finddel_locked(struct cfs_hash *hs,
-					      struct cfs_hash_bd *bd, const void *key,
-					     struct hlist_node *hnode);
+struct hlist_node *
+cfs_hash_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			  const void *key);
+struct hlist_node *
+cfs_hash_bd_peek_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			const void *key);
+struct hlist_node *
+cfs_hash_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			   const void *key, struct hlist_node *hnode,
+			   int insist_add);
+struct hlist_node *
+cfs_hash_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			   const void *key, struct hlist_node *hnode);
 
 /**
  * operations on cfs_hash bucket (bd: bucket descriptor),
  * they are safe for hash-table with rehash
  */
-void cfs_hash_dual_bd_get(struct cfs_hash *hs, const void *key, struct cfs_hash_bd *bds);
-void cfs_hash_dual_bd_lock(struct cfs_hash *hs, struct cfs_hash_bd *bds, int excl);
-void cfs_hash_dual_bd_unlock(struct cfs_hash *hs, struct cfs_hash_bd *bds, int excl);
+void cfs_hash_dual_bd_get(struct cfs_hash *hs, const void *key,
+			  struct cfs_hash_bd *bds);
+void cfs_hash_dual_bd_lock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
+			   int excl);
+void cfs_hash_dual_bd_unlock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
+			     int excl);
 
-static inline void cfs_hash_dual_bd_get_and_lock(struct cfs_hash *hs, const void *key,
-						 struct cfs_hash_bd *bds, int excl)
+static inline void
+cfs_hash_dual_bd_get_and_lock(struct cfs_hash *hs, const void *key,
+			      struct cfs_hash_bd *bds, int excl)
 {
 	cfs_hash_dual_bd_get(hs, key, bds);
 	cfs_hash_dual_bd_lock(hs, bds, excl);
 }
 
-struct hlist_node *cfs_hash_dual_bd_lookup_locked(struct cfs_hash *hs,
-						  struct cfs_hash_bd *bds,
-						 const void *key);
-struct hlist_node *cfs_hash_dual_bd_findadd_locked(struct cfs_hash *hs,
-						   struct cfs_hash_bd *bds,
-						  const void *key,
-						  struct hlist_node *hnode,
-						  int insist_add);
-struct hlist_node *cfs_hash_dual_bd_finddel_locked(struct cfs_hash *hs,
-						   struct cfs_hash_bd *bds,
-						  const void *key,
-						  struct hlist_node *hnode);
+struct hlist_node *
+cfs_hash_dual_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
+			       const void *key);
+struct hlist_node *
+cfs_hash_dual_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
+				const void *key, struct hlist_node *hnode,
+				int insist_add);
+struct hlist_node *
+cfs_hash_dual_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
+				const void *key, struct hlist_node *hnode);
 
 /* Hash init/cleanup functions */
-struct cfs_hash *cfs_hash_create(char *name, unsigned cur_bits,
-				 unsigned max_bits, unsigned bkt_bits,
-				 unsigned extra_bytes, unsigned min_theta,
-				 unsigned max_theta, struct cfs_hash_ops *ops,
-				 unsigned flags);
+struct cfs_hash *
+cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
+		unsigned bkt_bits, unsigned extra_bytes,
+		unsigned min_theta, unsigned max_theta,
+		struct cfs_hash_ops *ops, unsigned flags);
 
 struct cfs_hash *cfs_hash_getref(struct cfs_hash *hs);
 void cfs_hash_putref(struct cfs_hash *hs);
@@ -686,28 +698,39 @@ void *cfs_hash_findadd_unique(struct cfs_hash *hs, const void *key,
 			      struct hlist_node *hnode);
 
 /* Hash deletion functions */
-void *cfs_hash_del(struct cfs_hash *hs, const void *key, struct hlist_node *hnode);
+void *cfs_hash_del(struct cfs_hash *hs, const void *key,
+		   struct hlist_node *hnode);
 void *cfs_hash_del_key(struct cfs_hash *hs, const void *key);
 
 /* Hash lookup/for_each functions */
 #define CFS_HASH_LOOP_HOG       1024
 
-typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				      struct hlist_node *node, void *data);
-void *cfs_hash_lookup(struct cfs_hash *hs, const void *key);
-void cfs_hash_for_each(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
-void cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
-int  cfs_hash_for_each_nolock(struct cfs_hash *hs,
-			      cfs_hash_for_each_cb_t, void *data);
-int  cfs_hash_for_each_empty(struct cfs_hash *hs,
-			     cfs_hash_for_each_cb_t, void *data);
-void cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
-			   cfs_hash_for_each_cb_t, void *data);
+typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs,
+				      struct cfs_hash_bd *bd,
+				      struct hlist_node *node,
+				      void *data);
+void *
+cfs_hash_lookup(struct cfs_hash *hs, const void *key);
+void
+cfs_hash_for_each(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
+void
+cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
+int
+cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t,
+			 void *data);
+int
+cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t,
+			void *data);
+void
+cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
+		      cfs_hash_for_each_cb_t, void *data);
 typedef int (*cfs_hash_cond_opt_cb_t)(void *obj, void *data);
-void cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t, void *data);
+void
+cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t, void *data);
 
-void cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned hindex,
-			     cfs_hash_for_each_cb_t, void *data);
+void
+cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned hindex,
+			cfs_hash_for_each_cb_t, void *data);
 int  cfs_hash_is_empty(struct cfs_hash *hs);
 __u64 cfs_hash_size_get(struct cfs_hash *hs);
 
@@ -777,7 +800,8 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
 		CFS_HASH_THETA_BITS) >> hs->hs_cur_bits;
 }
 
-static inline void __cfs_hash_set_theta(struct cfs_hash *hs, int min, int max)
+static inline void
+__cfs_hash_set_theta(struct cfs_hash *hs, int min, int max)
 {
 	LASSERT(min < max);
 	hs->hs_min_theta = (__u16)min;
-- 
1.7.1
