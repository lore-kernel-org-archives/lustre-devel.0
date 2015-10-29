From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 17:35:21 -0400
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: remove white space in
	hash.c
In-Reply-To: <1446154522-12929-1-git-send-email-jsimmons@infradead.org>
References: <1446154522-12929-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446154522-12929-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Cleanup all the unneeded white space in hash.c.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/libcfs/hash.c |  342 ++++++++++++++-------------
 1 files changed, 177 insertions(+), 165 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 0308744..ed4e1f1 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -161,49 +161,49 @@ cfs_hash_rw_unlock(union cfs_hash_lock *lock, int exclusive)
 /** No lock hash */
 static struct cfs_hash_lock_ops cfs_hash_nl_lops = {
 	.hs_lock	= cfs_hash_nl_lock,
-	.hs_unlock      = cfs_hash_nl_unlock,
-	.hs_bkt_lock    = cfs_hash_nl_lock,
-	.hs_bkt_unlock  = cfs_hash_nl_unlock,
+	.hs_unlock	= cfs_hash_nl_unlock,
+	.hs_bkt_lock	= cfs_hash_nl_lock,
+	.hs_bkt_unlock	= cfs_hash_nl_unlock,
 };
 
 /** no bucket lock, one spinlock to protect everything */
 static struct cfs_hash_lock_ops cfs_hash_nbl_lops = {
 	.hs_lock	= cfs_hash_spin_lock,
-	.hs_unlock      = cfs_hash_spin_unlock,
-	.hs_bkt_lock    = cfs_hash_nl_lock,
-	.hs_bkt_unlock  = cfs_hash_nl_unlock,
+	.hs_unlock	= cfs_hash_spin_unlock,
+	.hs_bkt_lock	= cfs_hash_nl_lock,
+	.hs_bkt_unlock	= cfs_hash_nl_unlock,
 };
 
 /** spin bucket lock, rehash is enabled */
 static struct cfs_hash_lock_ops cfs_hash_bkt_spin_lops = {
 	.hs_lock	= cfs_hash_rw_lock,
-	.hs_unlock      = cfs_hash_rw_unlock,
-	.hs_bkt_lock    = cfs_hash_spin_lock,
-	.hs_bkt_unlock  = cfs_hash_spin_unlock,
+	.hs_unlock	= cfs_hash_rw_unlock,
+	.hs_bkt_lock	= cfs_hash_spin_lock,
+	.hs_bkt_unlock	= cfs_hash_spin_unlock,
 };
 
 /** rw bucket lock, rehash is enabled */
 static struct cfs_hash_lock_ops cfs_hash_bkt_rw_lops = {
 	.hs_lock	= cfs_hash_rw_lock,
-	.hs_unlock      = cfs_hash_rw_unlock,
-	.hs_bkt_lock    = cfs_hash_rw_lock,
-	.hs_bkt_unlock  = cfs_hash_rw_unlock,
+	.hs_unlock	= cfs_hash_rw_unlock,
+	.hs_bkt_lock	= cfs_hash_rw_lock,
+	.hs_bkt_unlock	= cfs_hash_rw_unlock,
 };
 
 /** spin bucket lock, rehash is disabled */
 static struct cfs_hash_lock_ops cfs_hash_nr_bkt_spin_lops = {
 	.hs_lock	= cfs_hash_nl_lock,
-	.hs_unlock      = cfs_hash_nl_unlock,
-	.hs_bkt_lock    = cfs_hash_spin_lock,
-	.hs_bkt_unlock  = cfs_hash_spin_unlock,
+	.hs_unlock	= cfs_hash_nl_unlock,
+	.hs_bkt_lock	= cfs_hash_spin_lock,
+	.hs_bkt_unlock	= cfs_hash_spin_unlock,
 };
 
 /** rw bucket lock, rehash is disabled */
 static struct cfs_hash_lock_ops cfs_hash_nr_bkt_rw_lops = {
 	.hs_lock	= cfs_hash_nl_lock,
-	.hs_unlock      = cfs_hash_nl_unlock,
-	.hs_bkt_lock    = cfs_hash_rw_lock,
-	.hs_bkt_unlock  = cfs_hash_rw_unlock,
+	.hs_unlock	= cfs_hash_nl_unlock,
+	.hs_bkt_lock	= cfs_hash_rw_lock,
+	.hs_bkt_unlock	= cfs_hash_rw_unlock,
 };
 
 static void
@@ -280,7 +280,7 @@ cfs_hash_hh_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  */
 struct cfs_hash_head_dep {
 	struct hlist_head	hd_head;	/**< entries list */
-	unsigned int		hd_depth;       /**< list length */
+	unsigned int		hd_depth;	/**< list length */
 };
 
 static int
@@ -328,7 +328,7 @@ cfs_hash_hd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  */
 struct cfs_hash_dhead {
 	struct hlist_head	dh_head;	/**< entries list */
-	struct hlist_node       *dh_tail;	/**< the last entry */
+	struct hlist_node	*dh_tail;	/**< the last entry */
 };
 
 static int
@@ -384,8 +384,8 @@ cfs_hash_dh_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  */
 struct cfs_hash_dhead_dep {
 	struct hlist_head	dd_head;	/**< entries list */
-	struct hlist_node       *dd_tail;	/**< the last entry */
-	unsigned int	    dd_depth;       /**< list length */
+	struct hlist_node	*dd_tail;	/**< the last entry */
+	unsigned int		dd_depth;	/**< list length */
 };
 
 static int
@@ -436,31 +436,31 @@ cfs_hash_dd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 }
 
 static struct cfs_hash_hlist_ops cfs_hash_hh_hops = {
-	.hop_hhead      = cfs_hash_hh_hhead,
-	.hop_hhead_size = cfs_hash_hh_hhead_size,
-	.hop_hnode_add  = cfs_hash_hh_hnode_add,
-	.hop_hnode_del  = cfs_hash_hh_hnode_del,
+	.hop_hhead	= cfs_hash_hh_hhead,
+	.hop_hhead_size	= cfs_hash_hh_hhead_size,
+	.hop_hnode_add	= cfs_hash_hh_hnode_add,
+	.hop_hnode_del	= cfs_hash_hh_hnode_del,
 };
 
 static struct cfs_hash_hlist_ops cfs_hash_hd_hops = {
-	.hop_hhead      = cfs_hash_hd_hhead,
-	.hop_hhead_size = cfs_hash_hd_hhead_size,
-	.hop_hnode_add  = cfs_hash_hd_hnode_add,
-	.hop_hnode_del  = cfs_hash_hd_hnode_del,
+	.hop_hhead	= cfs_hash_hd_hhead,
+	.hop_hhead_size	= cfs_hash_hd_hhead_size,
+	.hop_hnode_add	= cfs_hash_hd_hnode_add,
+	.hop_hnode_del	= cfs_hash_hd_hnode_del,
 };
 
 static struct cfs_hash_hlist_ops cfs_hash_dh_hops = {
-	.hop_hhead      = cfs_hash_dh_hhead,
-	.hop_hhead_size = cfs_hash_dh_hhead_size,
-	.hop_hnode_add  = cfs_hash_dh_hnode_add,
-	.hop_hnode_del  = cfs_hash_dh_hnode_del,
+	.hop_hhead	= cfs_hash_dh_hhead,
+	.hop_hhead_size	= cfs_hash_dh_hhead_size,
+	.hop_hnode_add	= cfs_hash_dh_hnode_add,
+	.hop_hnode_del	= cfs_hash_dh_hnode_del,
 };
 
 static struct cfs_hash_hlist_ops cfs_hash_dd_hops = {
-	.hop_hhead      = cfs_hash_dd_hhead,
-	.hop_hhead_size = cfs_hash_dd_hhead_size,
-	.hop_hnode_add  = cfs_hash_dd_hnode_add,
-	.hop_hnode_del  = cfs_hash_dd_hnode_del,
+	.hop_hhead	= cfs_hash_dd_hhead,
+	.hop_hhead_size	= cfs_hash_dd_hhead_size,
+	.hop_hnode_add	= cfs_hash_dd_hnode_add,
+	.hop_hnode_del	= cfs_hash_dd_hnode_del,
 };
 
 static void
@@ -529,7 +529,7 @@ void
 cfs_hash_bd_add_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		       struct hlist_node *hnode)
 {
-	int		rc;
+	int rc;
 
 	rc = hs->hs_hops->hop_hnode_add(hs, bd, hnode);
 	cfs_hash_bd_dep_record(hs, bd, rc);
@@ -572,7 +572,7 @@ cfs_hash_bd_move_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd_old,
 {
 	struct cfs_hash_bucket *obkt = bd_old->bd_bucket;
 	struct cfs_hash_bucket *nbkt = bd_new->bd_bucket;
-	int		rc;
+	int rc;
 
 	if (cfs_hash_bd_compare(bd_old, bd_new) == 0)
 		return;
@@ -597,30 +597,30 @@ EXPORT_SYMBOL(cfs_hash_bd_move_locked);
 
 enum {
 	/** always set, for sanity (avoid ZERO intent) */
-	CFS_HS_LOOKUP_MASK_FIND     = BIT(0),
+	CFS_HS_LOOKUP_MASK_FIND	= BIT(0),
 	/** return entry with a ref */
-	CFS_HS_LOOKUP_MASK_REF      = BIT(1),
+	CFS_HS_LOOKUP_MASK_REF	= BIT(1),
 	/** add entry if not existing */
-	CFS_HS_LOOKUP_MASK_ADD      = BIT(2),
+	CFS_HS_LOOKUP_MASK_ADD	= BIT(2),
 	/** delete entry, ignore other masks */
-	CFS_HS_LOOKUP_MASK_DEL      = BIT(3),
+	CFS_HS_LOOKUP_MASK_DEL	= BIT(3),
 };
 
 enum cfs_hash_lookup_intent {
 	/** return item w/o refcount */
-	CFS_HS_LOOKUP_IT_PEEK       = CFS_HS_LOOKUP_MASK_FIND,
+	CFS_HS_LOOKUP_IT_PEEK	 = CFS_HS_LOOKUP_MASK_FIND,
 	/** return item with refcount */
-	CFS_HS_LOOKUP_IT_FIND       = (CFS_HS_LOOKUP_MASK_FIND |
-				       CFS_HS_LOOKUP_MASK_REF),
+	CFS_HS_LOOKUP_IT_FIND	 = (CFS_HS_LOOKUP_MASK_FIND |
+				    CFS_HS_LOOKUP_MASK_REF),
 	/** return item w/o refcount if existed, otherwise add */
-	CFS_HS_LOOKUP_IT_ADD	= (CFS_HS_LOOKUP_MASK_FIND |
-				       CFS_HS_LOOKUP_MASK_ADD),
+	CFS_HS_LOOKUP_IT_ADD	 = (CFS_HS_LOOKUP_MASK_FIND |
+				    CFS_HS_LOOKUP_MASK_ADD),
 	/** return item with refcount if existed, otherwise add */
-	CFS_HS_LOOKUP_IT_FINDADD    = (CFS_HS_LOOKUP_IT_FIND |
-				       CFS_HS_LOOKUP_MASK_ADD),
+	CFS_HS_LOOKUP_IT_FINDADD = (CFS_HS_LOOKUP_IT_FIND |
+				    CFS_HS_LOOKUP_MASK_ADD),
 	/** delete if existed */
-	CFS_HS_LOOKUP_IT_FINDDEL    = (CFS_HS_LOOKUP_MASK_FIND |
-				       CFS_HS_LOOKUP_MASK_DEL)
+	CFS_HS_LOOKUP_IT_FINDDEL = (CFS_HS_LOOKUP_MASK_FIND |
+				    CFS_HS_LOOKUP_MASK_DEL)
 };
 
 static struct hlist_node *
@@ -629,10 +629,10 @@ cfs_hash_bd_lookup_intent(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			  enum cfs_hash_lookup_intent intent)
 
 {
-	struct hlist_head  *hhead = cfs_hash_bd_hhead(hs, bd);
-	struct hlist_node  *ehnode;
-	struct hlist_node  *match;
-	int  intent_add = (intent & CFS_HS_LOOKUP_MASK_ADD) != 0;
+	struct hlist_head *hhead = cfs_hash_bd_hhead(hs, bd);
+	struct hlist_node *ehnode;
+	struct hlist_node *match;
+	int intent_add = (intent & CFS_HS_LOOKUP_MASK_ADD) != 0;
 
 	/* with this function, we can avoid a lot of useless refcount ops,
 	 * which are expensive atomic operations most time. */
@@ -665,7 +665,8 @@ cfs_hash_bd_lookup_intent(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 }
 
 struct hlist_node *
-cfs_hash_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd, const void *key)
+cfs_hash_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			  const void *key)
 {
 	return cfs_hash_bd_lookup_intent(hs, bd, key, NULL,
 					 CFS_HS_LOOKUP_IT_FIND);
@@ -673,7 +674,8 @@ cfs_hash_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd, const voi
 EXPORT_SYMBOL(cfs_hash_bd_lookup_locked);
 
 struct hlist_node *
-cfs_hash_bd_peek_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd, const void *key)
+cfs_hash_bd_peek_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
+			const void *key)
 {
 	return cfs_hash_bd_lookup_intent(hs, bd, key, NULL,
 					 CFS_HS_LOOKUP_IT_PEEK);
@@ -706,7 +708,7 @@ cfs_hash_multi_bd_lock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 		       unsigned n, int excl)
 {
 	struct cfs_hash_bucket *prev = NULL;
-	int		i;
+	int i;
 
 	/**
 	 * bds must be ascendantly ordered by bd->bd_bucket->hsb_index.
@@ -729,7 +731,7 @@ cfs_hash_multi_bd_unlock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 			 unsigned n, int excl)
 {
 	struct cfs_hash_bucket *prev = NULL;
-	int		i;
+	int i;
 
 	cfs_hash_for_each_bd(bds, n, i) {
 		if (prev != bds[i].bd_bucket) {
@@ -743,8 +745,8 @@ static struct hlist_node *
 cfs_hash_multi_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 				unsigned n, const void *key)
 {
-	struct hlist_node  *ehnode;
-	unsigned	   i;
+	struct hlist_node *ehnode;
+	unsigned i;
 
 	cfs_hash_for_each_bd(bds, n, i) {
 		ehnode = cfs_hash_bd_lookup_intent(hs, &bds[i], key, NULL,
@@ -756,13 +758,13 @@ cfs_hash_multi_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 }
 
 static struct hlist_node *
-cfs_hash_multi_bd_findadd_locked(struct cfs_hash *hs,
-				 struct cfs_hash_bd *bds, unsigned n, const void *key,
+cfs_hash_multi_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
+				 unsigned n, const void *key,
 				 struct hlist_node *hnode, int noref)
 {
-	struct hlist_node  *ehnode;
-	int		intent;
-	unsigned	   i;
+	struct hlist_node *ehnode;
+	int intent;
+	unsigned i;
 
 	LASSERT(hnode != NULL);
 	intent = (!noref * CFS_HS_LOOKUP_MASK_REF) | CFS_HS_LOOKUP_IT_PEEK;
@@ -777,7 +779,7 @@ cfs_hash_multi_bd_findadd_locked(struct cfs_hash *hs,
 	if (i == 1) { /* only one bucket */
 		cfs_hash_bd_add_locked(hs, &bds[0], hnode);
 	} else {
-		struct cfs_hash_bd      mybd;
+		struct cfs_hash_bd mybd;
 
 		cfs_hash_bd_get(hs, key, &mybd);
 		cfs_hash_bd_add_locked(hs, &mybd, hnode);
@@ -791,8 +793,8 @@ cfs_hash_multi_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 				 unsigned n, const void *key,
 				 struct hlist_node *hnode)
 {
-	struct hlist_node  *ehnode;
-	unsigned	   i;
+	struct hlist_node *ehnode;
+	unsigned int i;
 
 	cfs_hash_for_each_bd(bds, n, i) {
 		ehnode = cfs_hash_bd_lookup_intent(hs, &bds[i], key, hnode,
@@ -806,7 +808,7 @@ cfs_hash_multi_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 static void
 cfs_hash_bd_order(struct cfs_hash_bd *bd1, struct cfs_hash_bd *bd2)
 {
-	int     rc;
+	int rc;
 
 	if (bd2->bd_bucket == NULL)
 		return;
@@ -831,7 +833,8 @@ cfs_hash_bd_order(struct cfs_hash_bd *bd1, struct cfs_hash_bd *bd2)
 }
 
 void
-cfs_hash_dual_bd_get(struct cfs_hash *hs, const void *key, struct cfs_hash_bd *bds)
+cfs_hash_dual_bd_get(struct cfs_hash *hs, const void *key,
+		     struct cfs_hash_bd *bds)
 {
 	/* NB: caller should hold hs_lock.rw if REHASH is set */
 	cfs_hash_bd_from_key(hs, hs->hs_buckets,
@@ -894,7 +897,7 @@ static void
 cfs_hash_buckets_free(struct cfs_hash_bucket **buckets,
 		      int bkt_size, int prev_size, int size)
 {
-	int     i;
+	int i;
 
 	for (i = prev_size; i < size; i++) {
 		if (buckets[i] != NULL)
@@ -914,7 +917,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 			 unsigned int old_size, unsigned int new_size)
 {
 	struct cfs_hash_bucket **new_bkts;
-	int		 i;
+	int i;
 
 	LASSERT(old_size == 0 || old_bkts != NULL);
 
@@ -932,7 +935,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 
 	for (i = old_size; i < new_size; i++) {
 		struct hlist_head *hhead;
-		struct cfs_hash_bd     bd;
+		struct cfs_hash_bd bd;
 
 		LIBCFS_ALLOC(new_bkts[i], cfs_hash_bkt_size(hs));
 		if (new_bkts[i] == NULL) {
@@ -969,7 +972,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
  * @max_bits - Maximum allowed hash table resize, in bits
  * @ops      - Registered hash table operations
  * @flags    - CFS_HASH_REHASH enable synamic hash resizing
- *	   - CFS_HASH_SORT enable chained hash sort
+ *	     - CFS_HASH_SORT enable chained hash sort
  */
 static int cfs_hash_rehash_worker(cfs_workitem_t *wi);
 
@@ -977,10 +980,10 @@ static int cfs_hash_rehash_worker(cfs_workitem_t *wi);
 static int cfs_hash_dep_print(cfs_workitem_t *wi)
 {
 	struct cfs_hash *hs = container_of(wi, struct cfs_hash, hs_dep_wi);
-	int	 dep;
-	int	 bkt;
-	int	 off;
-	int	 bits;
+	int dep;
+	int bkt;
+	int off;
+	int bits;
 
 	spin_lock(&hs->hs_dep_lock);
 	dep  = hs->hs_dep_max;
@@ -1031,7 +1034,7 @@ cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
 		struct cfs_hash_ops *ops, unsigned flags)
 {
 	struct cfs_hash *hs;
-	int	 len;
+	int len;
 
 	CLASSERT(CFS_HASH_THETA_BITS < 15);
 
@@ -1077,7 +1080,7 @@ cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
 	hs->hs_max_bits = (__u8)max_bits;
 	hs->hs_bkt_bits = (__u8)bkt_bits;
 
-	hs->hs_ops	 = ops;
+	hs->hs_ops	   = ops;
 	hs->hs_extra_bytes = extra_bytes;
 	hs->hs_rehash_bits = 0;
 	cfs_wi_init(&hs->hs_rehash_wi, hs, cfs_hash_rehash_worker);
@@ -1102,10 +1105,10 @@ EXPORT_SYMBOL(cfs_hash_create);
 static void
 cfs_hash_destroy(struct cfs_hash *hs)
 {
-	struct hlist_node     *hnode;
-	struct hlist_node     *pos;
-	struct cfs_hash_bd	 bd;
-	int		   i;
+	struct hlist_node *hnode;
+	struct hlist_node *pos;
+	struct cfs_hash_bd bd;
+	int i;
 
 	LASSERT(hs != NULL);
 	LASSERT(!cfs_hash_is_exiting(hs) &&
@@ -1223,8 +1226,8 @@ cfs_hash_rehash_inline(struct cfs_hash *hs)
 void
 cfs_hash_add(struct cfs_hash *hs, const void *key, struct hlist_node *hnode)
 {
-	struct cfs_hash_bd   bd;
-	int	     bits;
+	struct cfs_hash_bd bd;
+	int bits;
 
 	LASSERT(hlist_unhashed(hnode));
 
@@ -1248,8 +1251,8 @@ cfs_hash_find_or_add(struct cfs_hash *hs, const void *key,
 		     struct hlist_node *hnode, int noref)
 {
 	struct hlist_node *ehnode;
-	struct cfs_hash_bd     bds[2];
-	int	       bits = 0;
+	struct cfs_hash_bd bds[2];
+	int bits = 0;
 
 	LASSERT(hlist_unhashed(hnode));
 
@@ -1261,7 +1264,7 @@ cfs_hash_find_or_add(struct cfs_hash *hs, const void *key,
 						 hnode, noref);
 	cfs_hash_dual_bd_unlock(hs, bds, 1);
 
-	if (ehnode == hnode) /* new item added */
+	if (ehnode == hnode)	/* new item added */
 		bits = cfs_hash_rehash_bits(hs);
 	cfs_hash_unlock(hs, 0);
 	if (bits > 0)
@@ -1276,7 +1279,8 @@ cfs_hash_find_or_add(struct cfs_hash *hs, const void *key,
  * Returns 0 on success or -EALREADY on key collisions.
  */
 int
-cfs_hash_add_unique(struct cfs_hash *hs, const void *key, struct hlist_node *hnode)
+cfs_hash_add_unique(struct cfs_hash *hs, const void *key,
+		    struct hlist_node *hnode)
 {
 	return cfs_hash_find_or_add(hs, key, hnode, 1) != hnode ?
 	       -EALREADY : 0;
@@ -1309,9 +1313,9 @@ EXPORT_SYMBOL(cfs_hash_findadd_unique);
 void *
 cfs_hash_del(struct cfs_hash *hs, const void *key, struct hlist_node *hnode)
 {
-	void	   *obj  = NULL;
-	int	     bits = 0;
-	struct cfs_hash_bd   bds[2];
+	void *obj = NULL;
+	int bits = 0;
+	struct cfs_hash_bd bds[2];
 
 	cfs_hash_lock(hs, 0);
 	cfs_hash_dual_bd_get_and_lock(hs, key, bds, 1);
@@ -1364,9 +1368,9 @@ EXPORT_SYMBOL(cfs_hash_del_key);
 void *
 cfs_hash_lookup(struct cfs_hash *hs, const void *key)
 {
-	void		 *obj = NULL;
-	struct hlist_node     *hnode;
-	struct cfs_hash_bd	 bds[2];
+	void *obj = NULL;
+	struct hlist_node *hnode;
+	struct cfs_hash_bd bds[2];
 
 	cfs_hash_lock(hs, 0);
 	cfs_hash_dual_bd_get_and_lock(hs, key, bds, 0);
@@ -1383,7 +1387,8 @@ cfs_hash_lookup(struct cfs_hash *hs, const void *key)
 EXPORT_SYMBOL(cfs_hash_lookup);
 
 static void
-cfs_hash_for_each_enter(struct cfs_hash *hs) {
+cfs_hash_for_each_enter(struct cfs_hash *hs)
+{
 	LASSERT(!cfs_hash_is_exiting(hs));
 
 	if (!cfs_hash_with_rehash(hs))
@@ -1408,7 +1413,8 @@ cfs_hash_for_each_enter(struct cfs_hash *hs) {
 }
 
 static void
-cfs_hash_for_each_exit(struct cfs_hash *hs) {
+cfs_hash_for_each_exit(struct cfs_hash *hs)
+{
 	int remained;
 	int bits;
 
@@ -1439,14 +1445,15 @@ cfs_hash_for_each_exit(struct cfs_hash *hs) {
  */
 static __u64
 cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data, int remove_safe) {
-	struct hlist_node     *hnode;
-	struct hlist_node     *pos;
-	struct cfs_hash_bd	 bd;
-	__u64		 count = 0;
-	int		   excl  = !!remove_safe;
-	int		   loop  = 0;
-	int		   i;
+			void *data, int remove_safe)
+{
+	struct hlist_node *hnode;
+	struct hlist_node *pos;
+	struct cfs_hash_bd bd;
+	__u64 count = 0;
+	int excl = !!remove_safe;
+	int loop = 0;
+	int i;
 
 	cfs_hash_for_each_enter(hs);
 
@@ -1514,8 +1521,8 @@ void
 cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t func, void *data)
 {
 	struct cfs_hash_cond_arg arg = {
-		.func   = func,
-		.arg    = data,
+		.func	= func,
+		.arg	= data,
 	};
 
 	cfs_hash_for_each_tight(hs, cfs_hash_cond_del_locked, &arg, 1);
@@ -1523,16 +1530,17 @@ cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t func, void *data)
 EXPORT_SYMBOL(cfs_hash_cond_del);
 
 void
-cfs_hash_for_each(struct cfs_hash *hs,
-		  cfs_hash_for_each_cb_t func, void *data)
+cfs_hash_for_each(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+		  void *data)
 {
 	cfs_hash_for_each_tight(hs, func, data, 0);
 }
 EXPORT_SYMBOL(cfs_hash_for_each);
 
 void
-cfs_hash_for_each_safe(struct cfs_hash *hs,
-		       cfs_hash_for_each_cb_t func, void *data) {
+cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+		       void *data)
+{
 	cfs_hash_for_each_tight(hs, func, data, 1);
 }
 EXPORT_SYMBOL(cfs_hash_for_each_safe);
@@ -1581,15 +1589,16 @@ EXPORT_SYMBOL(cfs_hash_size_get);
  */
 static int
 cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data) {
+			void *data)
+{
 	struct hlist_node *hnode;
 	struct hlist_node *tmp;
-	struct cfs_hash_bd     bd;
-	__u32	     version;
-	int	       count = 0;
-	int	       stop_on_change;
-	int	       rc;
-	int	       i;
+	struct cfs_hash_bd bd;
+	__u32 version;
+	int count = 0;
+	int stop_on_change;
+	int rc;
+	int i;
 
 	stop_on_change = cfs_hash_with_rehash_key(hs) ||
 			 !cfs_hash_with_no_itemref(hs) ||
@@ -1645,8 +1654,9 @@ cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 }
 
 int
-cfs_hash_for_each_nolock(struct cfs_hash *hs,
-			 cfs_hash_for_each_cb_t func, void *data) {
+cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+			 void *data)
+{
 	if (cfs_hash_with_no_lock(hs) ||
 	    cfs_hash_with_rehash_key(hs) ||
 	    !cfs_hash_with_no_itemref(hs))
@@ -1677,9 +1687,10 @@ EXPORT_SYMBOL(cfs_hash_for_each_nolock);
  * the required locking is in place to prevent concurrent insertions.
  */
 int
-cfs_hash_for_each_empty(struct cfs_hash *hs,
-			cfs_hash_for_each_cb_t func, void *data) {
-	unsigned  i = 0;
+cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+			void *data)
+{
+	unsigned i = 0;
 
 	if (cfs_hash_with_no_lock(hs))
 		return -EOPNOTSUPP;
@@ -1703,9 +1714,9 @@ void
 cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned hindex,
 			cfs_hash_for_each_cb_t func, void *data)
 {
-	struct hlist_head   *hhead;
-	struct hlist_node   *hnode;
-	struct cfs_hash_bd       bd;
+	struct hlist_head *hhead;
+	struct hlist_node *hnode;
+	struct cfs_hash_bd bd;
 
 	cfs_hash_for_each_enter(hs);
 	cfs_hash_lock(hs, 0);
@@ -1721,7 +1732,7 @@ cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned hindex,
 			break;
 	}
 	cfs_hash_bd_unlock(hs, &bd, 0);
- out:
+out:
 	cfs_hash_unlock(hs, 0);
 	cfs_hash_for_each_exit(hs);
 }
@@ -1736,10 +1747,11 @@ EXPORT_SYMBOL(cfs_hash_hlist_for_each);
    */
 void
 cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
-		      cfs_hash_for_each_cb_t func, void *data) {
-	struct hlist_node   *hnode;
-	struct cfs_hash_bd       bds[2];
-	unsigned	    i;
+		      cfs_hash_for_each_cb_t func, void *data)
+{
+	struct hlist_node *hnode;
+	struct cfs_hash_bd bds[2];
+	unsigned int i;
 
 	cfs_hash_lock(hs, 0);
 
@@ -1777,7 +1789,7 @@ EXPORT_SYMBOL(cfs_hash_for_each_key);
 void
 cfs_hash_rehash_cancel_locked(struct cfs_hash *hs)
 {
-	int     i;
+	int i;
 
 	/* need hold cfs_hash_lock(hs, 1) */
 	LASSERT(cfs_hash_with_rehash(hs) &&
@@ -1815,7 +1827,7 @@ EXPORT_SYMBOL(cfs_hash_rehash_cancel);
 int
 cfs_hash_rehash(struct cfs_hash *hs, int do_rehash)
 {
-	int     rc;
+	int rc;
 
 	LASSERT(cfs_hash_with_rehash(hs) && !cfs_hash_with_no_lock(hs));
 
@@ -1845,12 +1857,12 @@ EXPORT_SYMBOL(cfs_hash_rehash);
 static int
 cfs_hash_rehash_bd(struct cfs_hash *hs, struct cfs_hash_bd *old)
 {
-	struct cfs_hash_bd      new;
-	struct hlist_head  *hhead;
-	struct hlist_node  *hnode;
-	struct hlist_node  *pos;
-	void	      *key;
-	int		c = 0;
+	struct cfs_hash_bd new;
+	struct hlist_head *hhead;
+	struct hlist_node *hnode;
+	struct hlist_node *pos;
+	void *key;
+	int c = 0;
 
 	/* hold cfs_hash_lock(hs, 1), so don't need any bucket lock */
 	cfs_hash_bd_for_each_hlist(hs, old, hhead) {
@@ -1876,17 +1888,17 @@ cfs_hash_rehash_bd(struct cfs_hash *hs, struct cfs_hash_bd *old)
 static int
 cfs_hash_rehash_worker(cfs_workitem_t *wi)
 {
-	struct cfs_hash	 *hs = container_of(wi, struct cfs_hash, hs_rehash_wi);
+	struct cfs_hash *hs = container_of(wi, struct cfs_hash, hs_rehash_wi);
 	struct cfs_hash_bucket **bkts;
-	struct cfs_hash_bd       bd;
-	unsigned int	old_size;
-	unsigned int	new_size;
-	int		 bsize;
-	int		 count = 0;
-	int		 rc = 0;
-	int		 i;
+	struct cfs_hash_bd bd;
+	unsigned int old_size;
+	unsigned int new_size;
+	int bsize;
+	int count = 0;
+	int rc = 0;
+	int i;
 
-	LASSERT (hs != NULL && cfs_hash_with_rehash(hs));
+	LASSERT(hs != NULL && cfs_hash_with_rehash(hs));
 
 	cfs_hash_lock(hs, 0);
 	LASSERT(cfs_hash_is_rehashing(hs));
@@ -1958,7 +1970,7 @@ cfs_hash_rehash_worker(cfs_workitem_t *wi)
 	hs->hs_rehash_buckets = NULL;
 
 	hs->hs_cur_bits = hs->hs_rehash_bits;
- out:
+out:
 	hs->hs_rehash_bits = 0;
 	if (rc == -ESRCH) /* never be scheduled again */
 		cfs_wi_exit(cfs_sched_rehash, wi);
@@ -1986,9 +1998,9 @@ cfs_hash_rehash_worker(cfs_workitem_t *wi)
 void cfs_hash_rehash_key(struct cfs_hash *hs, const void *old_key,
 			 void *new_key, struct hlist_node *hnode)
 {
-	struct cfs_hash_bd	bds[3];
-	struct cfs_hash_bd	old_bds[2];
-	struct cfs_hash_bd	new_bd;
+	struct cfs_hash_bd bds[3];
+	struct cfs_hash_bd old_bds[2];
+	struct cfs_hash_bd new_bd;
 
 	LASSERT(!hlist_unhashed(hnode));
 
@@ -2054,12 +2066,12 @@ cfs_hash_full_nbkt(struct cfs_hash *hs)
 
 void cfs_hash_debug_str(struct cfs_hash *hs, struct seq_file *m)
 {
-	int		    dist[8] = { 0, };
-	int		    maxdep  = -1;
-	int		    maxdepb = -1;
-	int		    total   = 0;
-	int		    theta;
-	int		    i;
+	int dist[8] = { 0, };
+	int maxdep = -1;
+	int maxdepb = -1;
+	int total = 0;
+	int theta;
+	int i;
 
 	cfs_hash_lock(hs, 0);
 	theta = __cfs_hash_theta(hs);
@@ -2085,11 +2097,11 @@ void cfs_hash_debug_str(struct cfs_hash *hs, struct seq_file *m)
 	 * If you hash function results in a non-uniform hash the will
 	 * be observable by outlier bucks in the distribution histogram.
 	 *
-	 * Uniform hash distribution:      128/128/0/0/0/0/0/0
-	 * Non-Uniform hash distribution:  128/125/0/0/0/0/2/1
+	 * Uniform hash distribution:		128/128/0/0/0/0/0/0
+	 * Non-Uniform hash distribution:	128/125/0/0/0/0/2/1
 	 */
 	for (i = 0; i < cfs_hash_full_nbkt(hs); i++) {
-		struct cfs_hash_bd  bd;
+		struct cfs_hash_bd bd;
 
 		bd.bd_bucket = cfs_hash_full_bkts(hs)[i];
 		cfs_hash_bd_lock(hs, &bd, 0);
-- 
1.7.1
