From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:44 -0500
Subject: [lustre-devel] [PATCH 12/45] staging/lustre/libcfs: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"
Also removed some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/debug.c       |   4 +-
 drivers/staging/lustre/lustre/libcfs/hash.c        | 104 ++++++++++-----------
 drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c  |   6 +-
 drivers/staging/lustre/lustre/libcfs/libcfs_lock.c |   2 +-
 drivers/staging/lustre/lustre/libcfs/libcfs_mem.c  |   2 +-
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |  15 ++-
 .../staging/lustre/lustre/libcfs/linux/linux-cpu.c |  58 ++++++------
 .../lustre/lustre/libcfs/linux/linux-crypto.c      |  18 ++--
 .../lustre/lustre/libcfs/linux/linux-debug.c       |   4 +-
 .../lustre/lustre/libcfs/linux/linux-module.c      |   6 +-
 .../lustre/lustre/libcfs/linux/linux-tracefile.c   |   6 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |  15 ++-
 drivers/staging/lustre/lustre/libcfs/tracefile.c   |  40 ++++----
 drivers/staging/lustre/lustre/libcfs/tracefile.h   |  12 +--
 drivers/staging/lustre/lustre/libcfs/workitem.c    |   8 +-
 15 files changed, 143 insertions(+), 157 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/debug.c b/drivers/staging/lustre/lustre/libcfs/debug.c
index 6274558..589b548 100644
--- a/drivers/staging/lustre/lustre/libcfs/debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/debug.c
@@ -378,7 +378,7 @@ libcfs_debug_mask2str(char *str, int size, int mask, int is_subsys)
 				continue;
 
 			token = fn(i);
-			if (token == NULL)	      /* unused bit */
+			if (!token)	      /* unused bit */
 				continue;
 
 			if (len > 0) {		  /* separator? */
@@ -505,7 +505,7 @@ int libcfs_debug_init(unsigned long bufsize)
 		libcfs_console_min_delay = CDEBUG_DEFAULT_MIN_DELAY;
 	}
 
-	if (libcfs_debug_file_path != NULL) {
+	if (libcfs_debug_file_path) {
 		strlcpy(libcfs_debug_file_path_arr,
 			libcfs_debug_file_path,
 			sizeof(libcfs_debug_file_path_arr));
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 4d50510..ad831fa 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -355,7 +355,7 @@ cfs_hash_dh_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 
 	dh = container_of(cfs_hash_dh_hhead(hs, bd),
 			  struct cfs_hash_dhead, dh_head);
-	if (dh->dh_tail != NULL) /* not empty */
+	if (dh->dh_tail) /* not empty */
 		hlist_add_behind(hnode, dh->dh_tail);
 	else /* empty list */
 		hlist_add_head(hnode, &dh->dh_head);
@@ -371,7 +371,7 @@ cfs_hash_dh_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 
 	dh = container_of(cfs_hash_dh_hhead(hs, bd),
 			  struct cfs_hash_dhead, dh_head);
-	if (hnd->next == NULL) { /* it's the tail */
+	if (!hnd->next) { /* it's the tail */
 		dh->dh_tail = (hnd->pprev == &dh->dh_head.first) ? NULL :
 			      container_of(hnd->pprev, struct hlist_node, next);
 	}
@@ -412,7 +412,7 @@ cfs_hash_dd_hnode_add(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 
 	dh = container_of(cfs_hash_dd_hhead(hs, bd),
 			  struct cfs_hash_dhead_dep, dd_head);
-	if (dh->dd_tail != NULL) /* not empty */
+	if (dh->dd_tail) /* not empty */
 		hlist_add_behind(hnode, dh->dd_tail);
 	else /* empty list */
 		hlist_add_head(hnode, &dh->dd_head);
@@ -428,7 +428,7 @@ cfs_hash_dd_hnode_del(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 
 	dh = container_of(cfs_hash_dd_hhead(hs, bd),
 			  struct cfs_hash_dhead_dep, dd_head);
-	if (hnd->next == NULL) { /* it's the tail */
+	if (!hnd->next) { /* it's the tail */
 		dh->dd_tail = (hnd->pprev == &dh->dd_head.first) ? NULL :
 			      container_of(hnd->pprev, struct hlist_node, next);
 	}
@@ -492,7 +492,7 @@ void
 cfs_hash_bd_get(struct cfs_hash *hs, const void *key, struct cfs_hash_bd *bd)
 {
 	/* NB: caller should hold hs->hs_rwlock if REHASH is set */
-	if (likely(hs->hs_rehash_buckets == NULL)) {
+	if (likely(!hs->hs_rehash_buckets)) {
 		cfs_hash_bd_from_key(hs, hs->hs_buckets,
 				     hs->hs_cur_bits, key, bd);
 	} else {
@@ -641,7 +641,7 @@ cfs_hash_bd_lookup_intent(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 		if (!cfs_hash_keycmp(hs, key, ehnode))
 			continue;
 
-		if (match != NULL && match != ehnode) /* can't match */
+		if (match && match != ehnode) /* can't match */
 			continue;
 
 		/* match and ... */
@@ -659,7 +659,7 @@ cfs_hash_bd_lookup_intent(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	if (!intent_add)
 		return NULL;
 
-	LASSERT(hnode != NULL);
+	LASSERT(hnode);
 	cfs_hash_bd_add_locked(hs, bd, hnode);
 	return hnode;
 }
@@ -698,8 +698,7 @@ cfs_hash_multi_bd_lock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 		if (prev == bds[i].bd_bucket)
 			continue;
 
-		LASSERT(prev == NULL ||
-			prev->hsb_index < bds[i].bd_bucket->hsb_index);
+		LASSERT(!prev || prev->hsb_index < bds[i].bd_bucket->hsb_index);
 		cfs_hash_bd_lock(hs, &bds[i], excl);
 		prev = bds[i].bd_bucket;
 	}
@@ -730,7 +729,7 @@ cfs_hash_multi_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 	cfs_hash_for_each_bd(bds, n, i) {
 		ehnode = cfs_hash_bd_lookup_intent(hs, &bds[i], key, NULL,
 						   CFS_HS_LOOKUP_IT_FIND);
-		if (ehnode != NULL)
+		if (ehnode)
 			return ehnode;
 	}
 	return NULL;
@@ -745,13 +744,13 @@ cfs_hash_multi_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 	int intent;
 	unsigned i;
 
-	LASSERT(hnode != NULL);
+	LASSERT(hnode);
 	intent = (!noref * CFS_HS_LOOKUP_MASK_REF) | CFS_HS_LOOKUP_IT_PEEK;
 
 	cfs_hash_for_each_bd(bds, n, i) {
 		ehnode = cfs_hash_bd_lookup_intent(hs, &bds[i], key,
 						   NULL, intent);
-		if (ehnode != NULL)
+		if (ehnode)
 			return ehnode;
 	}
 
@@ -778,7 +777,7 @@ cfs_hash_multi_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
 	cfs_hash_for_each_bd(bds, n, i) {
 		ehnode = cfs_hash_bd_lookup_intent(hs, &bds[i], key, hnode,
 						   CFS_HS_LOOKUP_IT_FINDDEL);
-		if (ehnode != NULL)
+		if (ehnode)
 			return ehnode;
 	}
 	return NULL;
@@ -789,10 +788,10 @@ cfs_hash_bd_order(struct cfs_hash_bd *bd1, struct cfs_hash_bd *bd2)
 {
 	int rc;
 
-	if (bd2->bd_bucket == NULL)
+	if (!bd2->bd_bucket)
 		return;
 
-	if (bd1->bd_bucket == NULL) {
+	if (!bd1->bd_bucket) {
 		*bd1 = *bd2;
 		bd2->bd_bucket = NULL;
 		return;
@@ -818,7 +817,7 @@ cfs_hash_dual_bd_get(struct cfs_hash *hs, const void *key,
 	/* NB: caller should hold hs_lock.rw if REHASH is set */
 	cfs_hash_bd_from_key(hs, hs->hs_buckets,
 			     hs->hs_cur_bits, key, &bds[0]);
-	if (likely(hs->hs_rehash_buckets == NULL)) {
+	if (likely(!hs->hs_rehash_buckets)) {
 		/* no rehash or not rehashing */
 		bds[1].bd_bucket = NULL;
 		return;
@@ -873,7 +872,7 @@ cfs_hash_buckets_free(struct cfs_hash_bucket **buckets,
 	int i;
 
 	for (i = prev_size; i < size; i++) {
-		if (buckets[i] != NULL)
+		if (buckets[i])
 			LIBCFS_FREE(buckets[i], bkt_size);
 	}
 
@@ -892,16 +891,16 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 	struct cfs_hash_bucket **new_bkts;
 	int i;
 
-	LASSERT(old_size == 0 || old_bkts != NULL);
+	LASSERT(old_size == 0 || old_bkts);
 
-	if (old_bkts != NULL && old_size == new_size)
+	if (old_bkts && old_size == new_size)
 		return old_bkts;
 
 	LIBCFS_ALLOC(new_bkts, sizeof(new_bkts[0]) * new_size);
-	if (new_bkts == NULL)
+	if (!new_bkts)
 		return NULL;
 
-	if (old_bkts != NULL) {
+	if (old_bkts) {
 		memcpy(new_bkts, old_bkts,
 		       min(old_size, new_size) * sizeof(*old_bkts));
 	}
@@ -911,7 +910,7 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
 		struct cfs_hash_bd bd;
 
 		LIBCFS_ALLOC(new_bkts[i], cfs_hash_bkt_size(hs));
-		if (new_bkts[i] == NULL) {
+		if (!new_bkts[i]) {
 			cfs_hash_buckets_free(new_bkts, cfs_hash_bkt_size(hs),
 					      old_size, new_size);
 			return NULL;
@@ -1011,14 +1010,13 @@ cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
 
 	CLASSERT(CFS_HASH_THETA_BITS < 15);
 
-	LASSERT(name != NULL);
-	LASSERT(ops != NULL);
+	LASSERT(name);
 	LASSERT(ops->hs_key);
 	LASSERT(ops->hs_hash);
 	LASSERT(ops->hs_object);
 	LASSERT(ops->hs_keycmp);
-	LASSERT(ops->hs_get != NULL);
-	LASSERT(ops->hs_put_locked != NULL);
+	LASSERT(ops->hs_get);
+	LASSERT(ops->hs_put_locked);
 
 	if ((flags & CFS_HASH_REHASH) != 0)
 		flags |= CFS_HASH_COUNTER; /* must have counter */
@@ -1029,13 +1027,12 @@ cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
 	LASSERT(ergo((flags & CFS_HASH_REHASH) == 0, cur_bits == max_bits));
 	LASSERT(ergo((flags & CFS_HASH_REHASH) != 0,
 		     (flags & CFS_HASH_NO_LOCK) == 0));
-	LASSERT(ergo((flags & CFS_HASH_REHASH_KEY) != 0,
-		      ops->hs_keycpy != NULL));
+	LASSERT(ergo((flags & CFS_HASH_REHASH_KEY) != 0, ops->hs_keycpy));
 
 	len = (flags & CFS_HASH_BIGNAME) == 0 ?
 	      CFS_HASH_NAME_LEN : CFS_HASH_BIGNAME_LEN;
 	LIBCFS_ALLOC(hs, offsetof(struct cfs_hash, hs_name[len]));
-	if (hs == NULL)
+	if (!hs)
 		return NULL;
 
 	strlcpy(hs->hs_name, name, len);
@@ -1063,7 +1060,7 @@ cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
 
 	hs->hs_buckets = cfs_hash_buckets_realloc(hs, NULL, 0,
 						  CFS_HASH_NBKT(hs));
-	if (hs->hs_buckets != NULL)
+	if (hs->hs_buckets)
 		return hs;
 
 	LIBCFS_FREE(hs, offsetof(struct cfs_hash, hs_name[len]));
@@ -1082,7 +1079,7 @@ cfs_hash_destroy(struct cfs_hash *hs)
 	struct cfs_hash_bd bd;
 	int i;
 
-	LASSERT(hs != NULL);
+	LASSERT(hs);
 	LASSERT(!cfs_hash_is_exiting(hs) &&
 		!cfs_hash_is_iterating(hs));
 
@@ -1096,13 +1093,12 @@ cfs_hash_destroy(struct cfs_hash *hs)
 
 	cfs_hash_depth_wi_cancel(hs);
 	/* rehash should be done/canceled */
-	LASSERT(hs->hs_buckets != NULL &&
-		hs->hs_rehash_buckets == NULL);
+	LASSERT(hs->hs_buckets && !hs->hs_rehash_buckets);
 
 	cfs_hash_for_each_bucket(hs, &bd, i) {
 		struct hlist_head *hhead;
 
-		LASSERT(bd.bd_bucket != NULL);
+		LASSERT(bd.bd_bucket);
 		/* no need to take this lock, just for consistent code */
 		cfs_hash_bd_lock(hs, &bd, 1);
 
@@ -1293,8 +1289,8 @@ cfs_hash_del(struct cfs_hash *hs, const void *key, struct hlist_node *hnode)
 	cfs_hash_dual_bd_get_and_lock(hs, key, bds, 1);
 
 	/* NB: do nothing if @hnode is not in hash table */
-	if (hnode == NULL || !hlist_unhashed(hnode)) {
-		if (bds[1].bd_bucket == NULL && hnode != NULL) {
+	if (!hnode || !hlist_unhashed(hnode)) {
+		if (!bds[1].bd_bucket && hnode) {
 			cfs_hash_bd_del_locked(hs, &bds[0], hnode);
 		} else {
 			hnode = cfs_hash_dual_bd_finddel_locked(hs, bds,
@@ -1302,7 +1298,7 @@ cfs_hash_del(struct cfs_hash *hs, const void *key, struct hlist_node *hnode)
 		}
 	}
 
-	if (hnode != NULL) {
+	if (hnode) {
 		obj  = cfs_hash_object(hs, hnode);
 		bits = cfs_hash_rehash_bits(hs);
 	}
@@ -1348,7 +1344,7 @@ cfs_hash_lookup(struct cfs_hash *hs, const void *key)
 	cfs_hash_dual_bd_get_and_lock(hs, key, bds, 0);
 
 	hnode = cfs_hash_dual_bd_lookup_locked(hs, bds, key);
-	if (hnode != NULL)
+	if (hnode)
 		obj = cfs_hash_object(hs, hnode);
 
 	cfs_hash_dual_bd_unlock(hs, bds, 0);
@@ -1436,7 +1432,7 @@ cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 		struct hlist_head *hhead;
 
 		cfs_hash_bd_lock(hs, &bd, excl);
-		if (func == NULL) { /* only glimpse size */
+		if (!func) { /* only glimpse size */
 			count += bd.bd_bucket->hsb_count;
 			cfs_hash_bd_unlock(hs, &bd, excl);
 			continue;
@@ -1574,7 +1570,7 @@ cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 
 	stop_on_change = cfs_hash_with_rehash_key(hs) ||
 			 !cfs_hash_with_no_itemref(hs) ||
-			 hs->hs_ops->hs_put_locked == NULL;
+			 !hs->hs_ops->hs_put_locked;
 	cfs_hash_lock(hs, 0);
 	LASSERT(!cfs_hash_is_rehashing(hs));
 
@@ -1585,7 +1581,7 @@ cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 		version = cfs_hash_bd_version_get(&bd);
 
 		cfs_hash_bd_for_each_hlist(hs, &bd, hhead) {
-			for (hnode = hhead->first; hnode != NULL;) {
+			for (hnode = hhead->first; hnode;) {
 				cfs_hash_bucket_validate(hs, &bd, hnode);
 				cfs_hash_get(hs, hnode);
 				cfs_hash_bd_unlock(hs, &bd, 0);
@@ -1634,9 +1630,8 @@ cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 	    !cfs_hash_with_no_itemref(hs))
 		return -EOPNOTSUPP;
 
-	if (hs->hs_ops->hs_get == NULL ||
-	    (hs->hs_ops->hs_put == NULL &&
-	     hs->hs_ops->hs_put_locked == NULL))
+	if (!hs->hs_ops->hs_get ||
+	    (!hs->hs_ops->hs_put && !hs->hs_ops->hs_put_locked))
 		return -EOPNOTSUPP;
 
 	cfs_hash_for_each_enter(hs);
@@ -1667,9 +1662,8 @@ cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 	if (cfs_hash_with_no_lock(hs))
 		return -EOPNOTSUPP;
 
-	if (hs->hs_ops->hs_get == NULL ||
-	    (hs->hs_ops->hs_put == NULL &&
-	     hs->hs_ops->hs_put_locked == NULL))
+	if (!hs->hs_ops->hs_get ||
+	    (!hs->hs_ops->hs_put && !hs->hs_ops->hs_put_locked))
 		return -EOPNOTSUPP;
 
 	cfs_hash_for_each_enter(hs);
@@ -1837,7 +1831,7 @@ cfs_hash_rehash_bd(struct cfs_hash *hs, struct cfs_hash_bd *old)
 	cfs_hash_bd_for_each_hlist(hs, old, hhead) {
 		hlist_for_each_safe(hnode, pos, hhead) {
 			key = cfs_hash_key(hs, hnode);
-			LASSERT(key != NULL);
+			LASSERT(key);
 			/* Validate hnode is in the correct bucket. */
 			cfs_hash_bucket_validate(hs, old, hnode);
 			/*
@@ -1867,7 +1861,7 @@ cfs_hash_rehash_worker(cfs_workitem_t *wi)
 	int rc = 0;
 	int i;
 
-	LASSERT(hs != NULL && cfs_hash_with_rehash(hs));
+	LASSERT(hs && cfs_hash_with_rehash(hs));
 
 	cfs_hash_lock(hs, 0);
 	LASSERT(cfs_hash_is_rehashing(hs));
@@ -1884,7 +1878,7 @@ cfs_hash_rehash_worker(cfs_workitem_t *wi)
 	bkts = cfs_hash_buckets_realloc(hs, hs->hs_buckets,
 					old_size, new_size);
 	cfs_hash_lock(hs, 1);
-	if (bkts == NULL) {
+	if (!bkts) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1903,7 +1897,7 @@ cfs_hash_rehash_worker(cfs_workitem_t *wi)
 		goto out;
 	}
 
-	LASSERT(hs->hs_rehash_buckets == NULL);
+	LASSERT(!hs->hs_rehash_buckets);
 	hs->hs_rehash_buckets = bkts;
 
 	rc = 0;
@@ -1946,7 +1940,7 @@ out:
 	bsize = cfs_hash_bkt_size(hs);
 	cfs_hash_unlock(hs, 1);
 	/* can't refer to @hs anymore because it could be destroyed */
-	if (bkts != NULL)
+	if (bkts)
 		cfs_hash_buckets_free(bkts, bsize, new_size, old_size);
 	if (rc != 0)
 		CDEBUG(D_INFO, "early quit of rehashing: %d\n", rc);
@@ -1987,7 +1981,7 @@ void cfs_hash_rehash_key(struct cfs_hash *hs, const void *old_key,
 	cfs_hash_bd_order(&bds[0], &bds[1]);
 
 	cfs_hash_multi_bd_lock(hs, bds, 3, 1);
-	if (likely(old_bds[1].bd_bucket == NULL)) {
+	if (likely(!old_bds[1].bd_bucket)) {
 		cfs_hash_bd_move_locked(hs, &old_bds[0], &new_bd, hnode);
 	} else {
 		cfs_hash_dual_bd_finddel_locked(hs, old_bds, old_key, hnode);
@@ -2013,7 +2007,7 @@ static struct cfs_hash_bucket **
 cfs_hash_full_bkts(struct cfs_hash *hs)
 {
 	/* NB: caller should hold hs->hs_rwlock if REHASH is set */
-	if (hs->hs_rehash_buckets == NULL)
+	if (!hs->hs_rehash_buckets)
 		return hs->hs_buckets;
 
 	LASSERT(hs->hs_rehash_bits != 0);
@@ -2025,7 +2019,7 @@ static unsigned int
 cfs_hash_full_nbkt(struct cfs_hash *hs)
 {
 	/* NB: caller should hold hs->hs_rwlock if REHASH is set */
-	if (hs->hs_rehash_buckets == NULL)
+	if (!hs->hs_rehash_buckets)
 		return CFS_HASH_NBKT(hs);
 
 	LASSERT(hs->hs_rehash_bits != 0);
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
index ba97c79..9137df9 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
@@ -56,7 +56,7 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	}
 
 	LIBCFS_ALLOC(cptab, sizeof(*cptab));
-	if (cptab != NULL) {
+	if (cptab) {
 		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
 		node_set(0, cptab->ctb_nodemask);
 		cptab->ctb_nparts  = ncpt;
@@ -215,7 +215,7 @@ EXPORT_SYMBOL(cfs_cpt_bind);
 void
 cfs_cpu_fini(void)
 {
-	if (cfs_cpt_table != NULL) {
+	if (cfs_cpt_table) {
 		cfs_cpt_table_free(cfs_cpt_table);
 		cfs_cpt_table = NULL;
 	}
@@ -226,7 +226,7 @@ cfs_cpu_init(void)
 {
 	cfs_cpt_table = cfs_cpt_table_alloc(1);
 
-	return cfs_cpt_table != NULL ? 0 : -1;
+	return cfs_cpt_table ? 0 : -1;
 }
 
 #endif /* HAVE_LIBCFS_CPT */
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
index 32db788..2d08ba6 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
@@ -38,7 +38,7 @@
 void
 cfs_percpt_lock_free(struct cfs_percpt_lock *pcl)
 {
-	LASSERT(pcl->pcl_locks != NULL);
+	LASSERT(pcl->pcl_locks);
 	LASSERT(!pcl->pcl_locked);
 
 	cfs_percpt_free(pcl->pcl_locks);
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
index 27cf861..e0a8783 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
@@ -54,7 +54,7 @@ cfs_percpt_free(void *vars)
 	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
 
 	for (i = 0; i < arr->va_count; i++) {
-		if (arr->va_ptrs[i] != NULL)
+		if (arr->va_ptrs[i])
 			LIBCFS_FREE(arr->va_ptrs[i], arr->va_size);
 	}
 
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 205a3ed..f3bcf20 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -81,8 +81,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		found = 0;
 		for (i = 0; i < 32; i++) {
 			debugstr = bit2str(i);
-			if (debugstr != NULL &&
-			    strlen(debugstr) == len &&
+			if (debugstr && strlen(debugstr) == len &&
 			    strncasecmp(str, debugstr, len) == 0) {
 				if (op == '-')
 					newmask &= ~(1 << i);
@@ -175,7 +174,7 @@ cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res)
 {
 	char *end;
 
-	if (next->ls_str == NULL)
+	if (!next->ls_str)
 		return 0;
 
 	/* skip leading white spaces */
@@ -196,7 +195,7 @@ cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res)
 
 	res->ls_str = next->ls_str;
 	end = memchr(next->ls_str, delim, next->ls_len);
-	if (end == NULL) {
+	if (!end) {
 		/* there is no the delimeter in the string */
 		end = next->ls_str + next->ls_len;
 		next->ls_str = NULL;
@@ -266,7 +265,7 @@ cfs_range_expr_parse(struct cfs_lstr *src, unsigned min, unsigned max,
 	struct cfs_lstr		tok;
 
 	LIBCFS_ALLOC(re, sizeof(*re));
-	if (re == NULL)
+	if (!re)
 		return -ENOMEM;
 
 	if (src->ls_len == 1 && src->ls_str[0] == '*') {
@@ -442,7 +441,7 @@ cfs_expr_list_values(struct cfs_expr_list *expr_list, int max, __u32 **valpp)
 	}
 
 	LIBCFS_ALLOC(val, sizeof(val[0]) * count);
-	if (val == NULL)
+	if (!val)
 		return -ENOMEM;
 
 	count = 0;
@@ -495,7 +494,7 @@ cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
 	int			rc;
 
 	LIBCFS_ALLOC(expr_list, sizeof(*expr_list));
-	if (expr_list == NULL)
+	if (!expr_list)
 		return -ENOMEM;
 
 	src.ls_str = str;
@@ -509,7 +508,7 @@ cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
 		src.ls_len -= 2;
 
 		rc = -EINVAL;
-		while (src.ls_str != NULL) {
+		while (src.ls_str) {
 			struct cfs_lstr tok;
 
 			if (!cfs_gettok(&src, ',', &tok)) {
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
index e52afe3..41b9512 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
@@ -84,32 +84,32 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
 	int	i;
 
-	if (cptab->ctb_cpu2cpt != NULL) {
+	if (cptab->ctb_cpu2cpt) {
 		LIBCFS_FREE(cptab->ctb_cpu2cpt,
 			    num_possible_cpus() *
 			    sizeof(cptab->ctb_cpu2cpt[0]));
 	}
 
-	for (i = 0; cptab->ctb_parts != NULL && i < cptab->ctb_nparts; i++) {
+	for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
 
-		if (part->cpt_nodemask != NULL) {
+		if (part->cpt_nodemask) {
 			LIBCFS_FREE(part->cpt_nodemask,
 				    sizeof(*part->cpt_nodemask));
 		}
 
-		if (part->cpt_cpumask != NULL)
+		if (part->cpt_cpumask)
 			LIBCFS_FREE(part->cpt_cpumask, cpumask_size());
 	}
 
-	if (cptab->ctb_parts != NULL) {
+	if (cptab->ctb_parts) {
 		LIBCFS_FREE(cptab->ctb_parts,
 			    cptab->ctb_nparts * sizeof(cptab->ctb_parts[0]));
 	}
 
-	if (cptab->ctb_nodemask != NULL)
+	if (cptab->ctb_nodemask)
 		LIBCFS_FREE(cptab->ctb_nodemask, sizeof(*cptab->ctb_nodemask));
-	if (cptab->ctb_cpumask != NULL)
+	if (cptab->ctb_cpumask)
 		LIBCFS_FREE(cptab->ctb_cpumask, cpumask_size());
 
 	LIBCFS_FREE(cptab, sizeof(*cptab));
@@ -123,7 +123,7 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	int	i;
 
 	LIBCFS_ALLOC(cptab, sizeof(*cptab));
-	if (cptab == NULL)
+	if (!cptab)
 		return NULL;
 
 	cptab->ctb_nparts = ncpt;
@@ -131,19 +131,19 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	LIBCFS_ALLOC(cptab->ctb_cpumask, cpumask_size());
 	LIBCFS_ALLOC(cptab->ctb_nodemask, sizeof(*cptab->ctb_nodemask));
 
-	if (cptab->ctb_cpumask == NULL || cptab->ctb_nodemask == NULL)
+	if (!cptab->ctb_cpumask || !cptab->ctb_nodemask)
 		goto failed;
 
 	LIBCFS_ALLOC(cptab->ctb_cpu2cpt,
 		     num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
-	if (cptab->ctb_cpu2cpt == NULL)
+	if (!cptab->ctb_cpu2cpt)
 		goto failed;
 
 	memset(cptab->ctb_cpu2cpt, -1,
 	       num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
 
 	LIBCFS_ALLOC(cptab->ctb_parts, ncpt * sizeof(cptab->ctb_parts[0]));
-	if (cptab->ctb_parts == NULL)
+	if (!cptab->ctb_parts)
 		goto failed;
 
 	for (i = 0; i < ncpt; i++) {
@@ -151,7 +151,7 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 
 		LIBCFS_ALLOC(part->cpt_cpumask, cpumask_size());
 		LIBCFS_ALLOC(part->cpt_nodemask, sizeof(*part->cpt_nodemask));
-		if (part->cpt_cpumask == NULL || part->cpt_nodemask == NULL)
+		if (!part->cpt_cpumask || !part->cpt_nodemask)
 			goto failed;
 	}
 
@@ -618,7 +618,7 @@ cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 	/* allocate scratch buffer */
 	LIBCFS_ALLOC(socket, cpumask_size());
 	LIBCFS_ALLOC(core, cpumask_size());
-	if (socket == NULL || core == NULL) {
+	if (!socket || !core) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -659,9 +659,9 @@ cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 	}
 
  out:
-	if (socket != NULL)
+	if (socket)
 		LIBCFS_FREE(socket, cpumask_size());
-	if (core != NULL)
+	if (core)
 		LIBCFS_FREE(core, cpumask_size());
 	return rc;
 }
@@ -735,7 +735,7 @@ cfs_cpt_table_create(int ncpt)
 	}
 
 	cptab = cfs_cpt_table_alloc(ncpt);
-	if (cptab == NULL) {
+	if (!cptab) {
 		CERROR("Failed to allocate CPU map(%d)\n", ncpt);
 		goto failed;
 	}
@@ -747,7 +747,7 @@ cfs_cpt_table_create(int ncpt)
 	}
 
 	LIBCFS_ALLOC(mask, cpumask_size());
-	if (mask == NULL) {
+	if (!mask) {
 		CERROR("Failed to allocate scratch cpumask\n");
 		goto failed;
 	}
@@ -793,10 +793,10 @@ cfs_cpt_table_create(int ncpt)
 	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
 	       ncpt, num_online_nodes(), num_online_cpus());
 
-	if (mask != NULL)
+	if (mask)
 		LIBCFS_FREE(mask, cpumask_size());
 
-	if (cptab != NULL)
+	if (cptab)
 		cfs_cpt_table_free(cptab);
 
 	return NULL;
@@ -814,7 +814,7 @@ cfs_cpt_table_create_pattern(char *pattern)
 
 	for (ncpt = 0;; ncpt++) { /* quick scan bracket */
 		str = strchr(str, '[');
-		if (str == NULL)
+		if (!str)
 			break;
 		str++;
 	}
@@ -836,7 +836,7 @@ cfs_cpt_table_create_pattern(char *pattern)
 	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
 
 	cptab = cfs_cpt_table_alloc(ncpt);
-	if (cptab == NULL) {
+	if (!cptab) {
 		CERROR("Failed to allocate cpu partition table\n");
 		return NULL;
 	}
@@ -850,7 +850,7 @@ cfs_cpt_table_create_pattern(char *pattern)
 		int			i;
 		int			n;
 
-		if (bracket == NULL) {
+		if (!bracket) {
 			if (*str != 0) {
 				CERROR("Invalid pattern %s\n", str);
 				goto failed;
@@ -885,7 +885,7 @@ cfs_cpt_table_create_pattern(char *pattern)
 		}
 
 		bracket = strchr(str, ']');
-		if (bracket == NULL) {
+		if (!bracket) {
 			CERROR("missing right bracket for cpt %d, %s\n",
 			       cpt, str);
 			goto failed;
@@ -975,25 +975,25 @@ static struct notifier_block cfs_cpu_notifier = {
 void
 cfs_cpu_fini(void)
 {
-	if (cfs_cpt_table != NULL)
+	if (cfs_cpt_table)
 		cfs_cpt_table_free(cfs_cpt_table);
 
 #ifdef CONFIG_HOTPLUG_CPU
 	unregister_hotcpu_notifier(&cfs_cpu_notifier);
 #endif
-	if (cpt_data.cpt_cpumask != NULL)
+	if (cpt_data.cpt_cpumask)
 		LIBCFS_FREE(cpt_data.cpt_cpumask, cpumask_size());
 }
 
 int
 cfs_cpu_init(void)
 {
-	LASSERT(cfs_cpt_table == NULL);
+	LASSERT(!cfs_cpt_table);
 
 	memset(&cpt_data, 0, sizeof(cpt_data));
 
 	LIBCFS_ALLOC(cpt_data.cpt_cpumask, cpumask_size());
-	if (cpt_data.cpt_cpumask == NULL) {
+	if (!cpt_data.cpt_cpumask) {
 		CERROR("Failed to allocate scratch buffer\n");
 		return -1;
 	}
@@ -1007,7 +1007,7 @@ cfs_cpu_init(void)
 
 	if (*cpu_pattern != 0) {
 		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern);
-		if (cfs_cpt_table == NULL) {
+		if (!cfs_cpt_table) {
 			CERROR("Failed to create cptab from pattern %s\n",
 			       cpu_pattern);
 			goto failed;
@@ -1015,7 +1015,7 @@ cfs_cpu_init(void)
 
 	} else {
 		cfs_cpt_table = cfs_cpt_table_create(cpu_npartitions);
-		if (cfs_cpt_table == NULL) {
+		if (!cfs_cpt_table) {
 			CERROR("Failed to create ptable with npartitions %d\n",
 			       cpu_npartitions);
 			goto failed;
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
index 079d50e..ccc25cd 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
@@ -45,14 +45,14 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
 
 	*type = cfs_crypto_hash_type(alg_id);
 
-	if (*type == NULL) {
+	if (!*type) {
 		CWARN("Unsupported hash algorithm id = %d, max id is %d\n",
 		      alg_id, CFS_HASH_ALG_MAX);
 		return -EINVAL;
 	}
 	desc->tfm = crypto_alloc_hash((*type)->cht_name, 0, 0);
 
-	if (desc->tfm == NULL)
+	if (!desc->tfm)
 		return -EINVAL;
 
 	if (IS_ERR(desc->tfm)) {
@@ -69,7 +69,7 @@ static int cfs_crypto_hash_alloc(unsigned char alg_id,
 	 * Skip this function for digest, because we use shash logic at
 	 * cfs_crypto_hash_alloc.
 	 */
-	if (key != NULL)
+	if (key)
 		err = crypto_hash_setkey(desc->tfm, key, key_len);
 	else if ((*type)->cht_key != 0)
 		err = crypto_hash_setkey(desc->tfm,
@@ -99,14 +99,14 @@ int cfs_crypto_hash_digest(unsigned char alg_id,
 	int			err;
 	const struct cfs_crypto_hash_type	*type;
 
-	if (buf == NULL || buf_len == 0 || hash_len == NULL)
+	if (!buf || buf_len == 0 || !hash_len)
 		return -EINVAL;
 
 	err = cfs_crypto_hash_alloc(alg_id, &type, &hdesc, key, key_len);
 	if (err != 0)
 		return err;
 
-	if (hash == NULL || *hash_len < type->cht_size) {
+	if (!hash || *hash_len < type->cht_size) {
 		*hash_len = type->cht_size;
 		crypto_free_hash(hdesc.tfm);
 		return -ENOSPC;
@@ -131,7 +131,7 @@ struct cfs_crypto_hash_desc *
 	const struct cfs_crypto_hash_type       *type;
 
 	hdesc = kmalloc(sizeof(*hdesc), 0);
-	if (hdesc == NULL)
+	if (!hdesc)
 		return ERR_PTR(-ENOMEM);
 
 	err = cfs_crypto_hash_alloc(alg_id, &type, hdesc, key, key_len);
@@ -175,12 +175,12 @@ int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
 	int     err;
 	int     size = crypto_hash_digestsize(((struct hash_desc *)hdesc)->tfm);
 
-	if (hash_len == NULL) {
+	if (!hash_len) {
 		crypto_free_hash(((struct hash_desc *)hdesc)->tfm);
 		kfree(hdesc);
 		return 0;
 	}
-	if (hash == NULL || *hash_len < size) {
+	if (!hash || *hash_len < size) {
 		*hash_len = size;
 		return -ENOSPC;
 	}
@@ -253,7 +253,7 @@ static int cfs_crypto_test_hashes(void)
 	unsigned int	    data_len = 1 * 128 * 1024;
 
 	data = kmalloc(data_len, 0);
-	if (data == NULL) {
+	if (!data) {
 		CERROR("Failed to allocate mem\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 3358c3b..85deec9 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -80,7 +80,7 @@ void libcfs_run_debug_log_upcall(char *file)
 
 	argv[0] = lnet_debug_log_upcall;
 
-	LASSERTF(file != NULL, "called on a null filename\n");
+	LASSERTF(file, "called on a null filename\n");
 	argv[1] = file; /* only need to pass the path of the file */
 
 	argv[2] = NULL;
@@ -106,7 +106,7 @@ void libcfs_run_upcall(char **argv)
 
 	argv[0] = lnet_upcall;
 	argc = 1;
-	while (argv[argc] != NULL)
+	while (argv[argc])
 		argc++;
 
 	LASSERT(argc >= 2);
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
index e5bc3d3..cbb44d7 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
@@ -102,7 +102,7 @@ libcfs_psdev_open(struct inode *inode, struct file *file)
 
 	if (!inode)
 		return -EINVAL;
-	if (libcfs_psdev_ops.p_open != NULL)
+	if (libcfs_psdev_ops.p_open)
 		rc = libcfs_psdev_ops.p_open(0, NULL);
 	else
 		return -EPERM;
@@ -117,7 +117,7 @@ libcfs_psdev_release(struct inode *inode, struct file *file)
 
 	if (!inode)
 		return -EINVAL;
-	if (libcfs_psdev_ops.p_close != NULL)
+	if (libcfs_psdev_ops.p_close)
 		rc = libcfs_psdev_ops.p_close(0, NULL);
 	else
 		rc = -EPERM;
@@ -150,7 +150,7 @@ static long libcfs_ioctl(struct file *file,
 		return 0;
 	}
 
-	if (libcfs_psdev_ops.p_ioctl != NULL)
+	if (libcfs_psdev_ops.p_ioctl)
 		rc = libcfs_psdev_ops.p_ioctl(&pfile, cmd, (void __user *)arg);
 	else
 		rc = -EPERM;
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index 64a136c..89944c0 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -63,7 +63,7 @@ int cfs_tracefile_init_arch(void)
 		cfs_trace_data[i] =
 			kmalloc(sizeof(union cfs_trace_data_union) *
 				num_possible_cpus(), GFP_KERNEL);
-		if (cfs_trace_data[i] == NULL)
+		if (!cfs_trace_data[i])
 			goto out;
 
 	}
@@ -82,7 +82,7 @@ int cfs_tracefile_init_arch(void)
 				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
 					GFP_KERNEL);
 
-			if (cfs_trace_console_buffers[i][j] == NULL)
+			if (!cfs_trace_console_buffers[i][j])
 				goto out;
 		}
 
@@ -105,7 +105,7 @@ void cfs_tracefile_fini_arch(void)
 			cfs_trace_console_buffers[i][j] = NULL;
 		}
 
-	for (i = 0; cfs_trace_data[i] != NULL; i++) {
+	for (i = 0; cfs_trace_data[i]; i++) {
 		kfree(cfs_trace_data[i]);
 		cfs_trace_data[i] = NULL;
 	}
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 45838b5..cf1498a 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -129,7 +129,7 @@ static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
 	 * Handled in arch/cfs_module.c
 	 */
 	case IOC_LIBCFS_MARK_DEBUG:
-		if (data->ioc_inlbuf1 == NULL ||
+		if (!data->ioc_inlbuf1 ||
 		    data->ioc_inlbuf1[data->ioc_inllen1 - 1] != '\0')
 			return -EINVAL;
 		libcfs_debug_mark_buffer(data->ioc_inlbuf1);
@@ -165,7 +165,7 @@ static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd,
 	int err = 0;
 
 	LIBCFS_ALLOC_GFP(buf, 1024, GFP_KERNEL);
-	if (buf == NULL)
+	if (!buf)
 		return -ENOMEM;
 
 	/* 'cmd' and permissions get checked in our arch-specific caller */
@@ -329,11 +329,11 @@ static int __proc_cpt_table(void *data, int write,
 	if (write)
 		return -EPERM;
 
-	LASSERT(cfs_cpt_table != NULL);
+	LASSERT(cfs_cpt_table);
 
 	while (1) {
 		LIBCFS_ALLOC(buf, len);
-		if (buf == NULL)
+		if (!buf)
 			return -ENOMEM;
 
 		rc = cfs_cpt_table_print(cfs_cpt_table, buf, len);
@@ -355,7 +355,7 @@ static int __proc_cpt_table(void *data, int write,
 
 	rc = cfs_trace_copyout_string(buffer, nob, buf + pos, NULL);
  out:
-	if (buf != NULL)
+	if (buf)
 		LIBCFS_FREE(buf, len);
 	return rc;
 }
@@ -531,7 +531,7 @@ static const struct file_operations *lnet_debugfs_fops_select(umode_t mode)
 void lustre_insert_debugfs(struct ctl_table *table,
 			   const struct lnet_debugfs_symlink_def *symlinks)
 {
-	if (lnet_debugfs_root == NULL)
+	if (!lnet_debugfs_root)
 		lnet_debugfs_root = debugfs_create_dir("lnet", NULL);
 
 	/* Even if we cannot create, just ignore it altogether) */
@@ -555,8 +555,7 @@ EXPORT_SYMBOL_GPL(lustre_insert_debugfs);
 
 static void lustre_remove_debugfs(void)
 {
-	if (lnet_debugfs_root != NULL)
-		debugfs_remove_recursive(lnet_debugfs_root);
+	debugfs_remove_recursive(lnet_debugfs_root);
 
 	lnet_debugfs_root = NULL;
 }
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index a7d9b78..c8f6a07 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -80,11 +80,11 @@ static struct cfs_trace_page *cfs_tage_alloc(gfp_t gfp)
 	 */
 	gfp |= __GFP_NOWARN;
 	page = alloc_page(gfp);
-	if (page == NULL)
+	if (!page)
 		return NULL;
 
 	tage = kmalloc(sizeof(*tage), gfp);
-	if (tage == NULL) {
+	if (!tage) {
 		__free_page(page);
 		return NULL;
 	}
@@ -96,9 +96,6 @@ static struct cfs_trace_page *cfs_tage_alloc(gfp_t gfp)
 
 static void cfs_tage_free(struct cfs_trace_page *tage)
 {
-	__LASSERT(tage != NULL);
-	__LASSERT(tage->page != NULL);
-
 	__free_page(tage->page);
 	kfree(tage);
 	atomic_dec(&cfs_tage_allocated);
@@ -107,9 +104,6 @@ static void cfs_tage_free(struct cfs_trace_page *tage)
 static void cfs_tage_to_tail(struct cfs_trace_page *tage,
 			     struct list_head *queue)
 {
-	__LASSERT(tage != NULL);
-	__LASSERT(queue != NULL);
-
 	list_move_tail(&tage->linkage, queue);
 }
 
@@ -127,7 +121,7 @@ int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
 		struct cfs_trace_page *tage;
 
 		tage = cfs_tage_alloc(gfp);
-		if (tage == NULL)
+		if (!tage)
 			break;
 		list_add_tail(&tage->linkage, stock);
 	}
@@ -154,7 +148,7 @@ cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
 			list_del_init(&tage->linkage);
 		} else {
 			tage = cfs_tage_alloc(GFP_ATOMIC);
-			if (unlikely(tage == NULL)) {
+			if (unlikely(!tage)) {
 				if ((!memory_pressure_get() ||
 				     in_interrupt()) && printk_ratelimit())
 					printk(KERN_WARNING
@@ -227,7 +221,7 @@ static struct cfs_trace_page *cfs_trace_get_tage(struct cfs_trace_cpu_data *tcd,
 	}
 
 	tage = cfs_trace_get_tage_try(tcd, len);
-	if (tage != NULL)
+	if (tage)
 		return tage;
 	if (thread_running)
 		cfs_tcd_shrink(tcd);
@@ -281,7 +275,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	 * warning on Linux when debugging is enabled. */
 	cfs_set_ptldebug_header(&header, msgdata, CDEBUG_STACK());
 
-	if (tcd == NULL)		/* arch may not log in IRQ context */
+	if (!tcd)		/* arch may not log in IRQ context */
 		goto console;
 
 	if (tcd->tcd_cur_pages == 0)
@@ -308,7 +302,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	 */
 	for (i = 0; i < 2; i++) {
 		tage = cfs_trace_get_tage(tcd, needed + known_size + 1);
-		if (tage == NULL) {
+		if (!tage) {
 			if (needed + known_size > PAGE_CACHE_SIZE)
 				mask |= D_ERROR;
 
@@ -389,18 +383,18 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 console:
 	if ((mask & libcfs_printk) == 0) {
 		/* no console output requested */
-		if (tcd != NULL)
+		if (tcd)
 			cfs_trace_put_tcd(tcd);
 		return 1;
 	}
 
-	if (cdls != NULL) {
+	if (cdls) {
 		if (libcfs_console_ratelimit &&
 		    cdls->cdls_next != 0 &&     /* not first time ever */
 		    !cfs_time_after(cfs_time_current(), cdls->cdls_next)) {
 			/* skipping a console message */
 			cdls->cdls_count++;
-			if (tcd != NULL)
+			if (tcd)
 				cfs_trace_put_tcd(tcd);
 			return 1;
 		}
@@ -423,7 +417,7 @@ console:
 		cdls->cdls_next = (cfs_time_current() + cdls->cdls_delay) | 1;
 	}
 
-	if (tcd != NULL) {
+	if (tcd) {
 		cfs_print_to_console(&header, mask, string_buf, needed, file,
 				     msgdata->msg_fn);
 		cfs_trace_put_tcd(tcd);
@@ -431,14 +425,14 @@ console:
 		string_buf = cfs_trace_get_console_buffer();
 
 		needed = 0;
-		if (format1 != NULL) {
+		if (format1) {
 			va_copy(ap, args);
 			needed = vsnprintf(string_buf,
 					   CFS_TRACE_CONSOLE_BUFFER_SIZE,
 					   format1, ap);
 			va_end(ap);
 		}
-		if (format2 != NULL) {
+		if (format2) {
 			remain = CFS_TRACE_CONSOLE_BUFFER_SIZE - needed;
 			if (remain > 0) {
 				va_start(ap, format2);
@@ -453,7 +447,7 @@ console:
 		put_cpu();
 	}
 
-	if (cdls != NULL && cdls->cdls_count != 0) {
+	if (cdls && cdls->cdls_count != 0) {
 		string_buf = cfs_trace_get_console_buffer();
 
 		needed = snprintf(string_buf, CFS_TRACE_CONSOLE_BUFFER_SIZE,
@@ -783,7 +777,7 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 	if (copy_to_user(usr_buffer, knl_buffer, nob))
 		return -EFAULT;
 
-	if (append != NULL && nob < usr_buffer_nob) {
+	if (append && nob < usr_buffer_nob) {
 		if (copy_to_user(usr_buffer + nob, append, 1))
 			return -EFAULT;
 
@@ -800,7 +794,7 @@ int cfs_trace_allocate_string_buffer(char **str, int nob)
 		return -EINVAL;
 
 	*str = kmalloc(nob, GFP_KERNEL | __GFP_ZERO);
-	if (*str == NULL)
+	if (!*str)
 		return -ENOMEM;
 
 	return 0;
@@ -978,7 +972,7 @@ static int tracefiled(void *arg)
 			}
 		}
 		cfs_tracefile_read_unlock();
-		if (filp == NULL) {
+		if (!filp) {
 			put_pages_on_daemon_list(&pc);
 			__LASSERT(list_empty(&pc.pc_pages));
 			goto end_loop;
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 7bf1471..67a701f 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -185,10 +185,10 @@ union cfs_trace_data_union {
 extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
 
 #define cfs_tcd_for_each(tcd, i, j)				       \
-    for (i = 0; cfs_trace_data[i] != NULL; i++)			   \
-	for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	       \
-	     j < num_possible_cpus();				 \
-	     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
+	for (i = 0; cfs_trace_data[i]; i++)				\
+		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
+		     j < num_possible_cpus();				 \
+		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
 
 #define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
     for (i = 0; cfs_trace_data[i] &&				      \
@@ -308,8 +308,8 @@ do {								    \
 
 #define __LASSERT_TAGE_INVARIANT(tage)				  \
 do {								    \
-	__LASSERT(tage != NULL);					\
-	__LASSERT(tage->page != NULL);				  \
+	__LASSERT(tage);					\
+	__LASSERT(tage->page);				  \
 	__LASSERT(tage->used <= PAGE_CACHE_SIZE);			 \
 	__LASSERT(page_count(tage->page) > 0);		      \
 } while (0)
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index 60bb88a..97ae5c1 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -212,7 +212,7 @@ cfs_wi_scheduler (void *arg)
 	cfs_block_allsigs();
 
 	/* CPT affinity scheduler? */
-	if (sched->ws_cptab != NULL)
+	if (sched->ws_cptab)
 		if (cfs_cpt_bind(sched->ws_cptab, sched->ws_cpt) != 0)
 			CWARN("Failed to bind %s on CPT %d\n",
 			      sched->ws_name, sched->ws_cpt);
@@ -343,11 +343,11 @@ cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab,
 
 	LASSERT(cfs_wi_data.wi_init);
 	LASSERT(!cfs_wi_data.wi_stopping);
-	LASSERT(cptab == NULL || cpt == CFS_CPT_ANY ||
+	LASSERT(!cptab || cpt == CFS_CPT_ANY ||
 		(cpt >= 0 && cpt < cfs_cpt_number(cptab)));
 
 	LIBCFS_ALLOC(sched, sizeof(*sched));
-	if (sched == NULL)
+	if (!sched)
 		return -ENOMEM;
 
 	strlcpy(sched->ws_name, name, CFS_WS_NAME_LEN);
@@ -376,7 +376,7 @@ cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab,
 		sched->ws_starting++;
 		spin_unlock(&cfs_wi_data.wi_glock);
 
-		if (sched->ws_cptab != NULL && sched->ws_cpt >= 0) {
+		if (sched->ws_cptab && sched->ws_cpt >= 0) {
 			snprintf(name, sizeof(name), "%s_%02d_%02u",
 				 sched->ws_name, sched->ws_cpt,
 				 sched->ws_nthreads);
-- 
2.1.0
