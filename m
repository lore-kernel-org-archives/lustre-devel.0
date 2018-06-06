From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:18 +1000
Subject: [lustre-devel] [PATCH 01/11] staging: lustre: simplify use of
 interval-tree.
In-Reply-To: <152826510267.16761.14361003167157833896.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
Message-ID: <152826511890.16761.16115276596203531205.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Lustre has a private interval-tree implementation.  This
implementation (inexplicably) refuses to insert an interval if an
identical interval already exists.  It is OK with all sorts of
overlapping intervals, but identical intervals are rejected.

Both users of interval-tree in lustre would be simpler if this was not
the case.  They need to store all intervals, even if some are
identical.

llite/range_lock.c add a rl_next_lock list_head to each lock.
If it cannot insert a new lock because the range is in use, it
attached the new lock to the existing lock using rl_next_lock.
This requires extra code to iterate over the rl_next_lock lists when
iterating over locks, and to update the list when deleting a lock from
the tree.

ldlm_extend allocates a separate ldlm_interval which as a list of
ldlm_locks which share the same interval.  This is linked together
by over-loading the l_sl_policy which, for non-extent locks, is used
for linking together locks with the same policy.
This doesn't only require extra code, but also an extra memory
allocation.

This patch removes all that complexity.
- interval_insert() now never fails.
- consequently rl_next_lock is always empty and
  rl_lock_count is always zero. so they are removed
- every ldlm_lock has linked directly into the
  interval tree, so each has an embedded interval_node
  rather than a pointer to a 'struct ldlm_interval'
- ldlm_interval is now unused, so it is gone as it
  the kmemcache from which they were allocated.
- the various functions for allocating an ldlm_interval
  and attaching to a lock or detaching from a lock
  are also gone.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/interval_tree.h  |    4 +
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   12 ---
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |   13 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   76 ++------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   17 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   25 +------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    9 --
 drivers/staging/lustre/lustre/llite/range_lock.c   |   59 +---------------
 drivers/staging/lustre/lustre/llite/range_lock.h   |    8 --
 9 files changed, 17 insertions(+), 206 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index 7d119c1a0469..bcda74fc7875 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -100,8 +100,8 @@ static inline int interval_set(struct interval_node *node,
 typedef enum interval_iter (*interval_callback_t)(struct interval_node *node,
 						  void *args);
 
-struct interval_node *interval_insert(struct interval_node *node,
-				      struct interval_node **root);
+void interval_insert(struct interval_node *node,
+		     struct interval_node **root);
 void interval_erase(struct interval_node *node, struct interval_node **root);
 
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 2c55241258cc..baeb8c63352b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -513,16 +513,6 @@ struct ldlm_glimpse_work {
 /** The ldlm_glimpse_work is allocated on the stack and should not be freed. */
 #define LDLM_GL_WORK_NOFREE 0x1
 
-/** Interval node data for each LDLM_EXTENT lock. */
-struct ldlm_interval {
-	struct interval_node	li_node;  /* node for tree management */
-	struct list_head	li_group; /* the locks which have the same
-					   * policy - group of the policy
-					   */
-};
-
-#define to_ldlm_interval(n) container_of(n, struct ldlm_interval, li_node)
-
 /**
  * Interval tree for extent locks.
  * The interval tree must be accessed under the resource lock.
@@ -631,7 +621,7 @@ struct ldlm_lock {
 	/**
 	 * Tree node for ldlm_extent.
 	 */
-	struct ldlm_interval	*l_tree_node;
+	struct interval_node	l_tree_node;
 	/**
 	 * Requested mode.
 	 * Protected by lr_lock.
diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index 8df7a4463c21..f5232059d1b1 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -97,11 +97,6 @@ static inline int extent_overlapped(struct interval_node_extent *e1,
 	return (e1->start <= e2->end) && (e2->start <= e1->end);
 }
 
-static inline int node_equal(struct interval_node *n1, struct interval_node *n2)
-{
-	return extent_equal(&n1->in_extent, &n2->in_extent);
-}
-
 static struct interval_node *interval_first(struct interval_node *node)
 {
 	if (!node)
@@ -299,8 +294,8 @@ static void interval_insert_color(struct interval_node *node,
 	(*root)->in_color = INTERVAL_BLACK;
 }
 
-struct interval_node *interval_insert(struct interval_node *node,
-				      struct interval_node **root)
+void interval_insert(struct interval_node *node,
+		     struct interval_node **root)
 
 {
 	struct interval_node **p, *parent = NULL;
@@ -309,8 +304,6 @@ struct interval_node *interval_insert(struct interval_node *node,
 	p = root;
 	while (*p) {
 		parent = *p;
-		if (node_equal(parent, node))
-			return parent;
 
 		/* max_high field must be updated after each iteration */
 		if (parent->in_max_high < interval_high(node))
@@ -331,8 +324,6 @@ struct interval_node *interval_insert(struct interval_node *node,
 
 	interval_insert_color(node, root);
 	node->in_intree = 1;
-
-	return NULL;
 }
 EXPORT_SYMBOL(interval_insert);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 4da23ade2bb3..2f4c305bb340 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -92,55 +92,6 @@ __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 }
 EXPORT_SYMBOL(ldlm_extent_shift_kms);
 
-struct kmem_cache *ldlm_interval_slab;
-
-/* interval tree, for LDLM_EXTENT. */
-static void ldlm_interval_attach(struct ldlm_interval *n, struct ldlm_lock *l)
-{
-	LASSERT(!l->l_tree_node);
-	LASSERT(l->l_resource->lr_type == LDLM_EXTENT);
-
-	list_add_tail(&l->l_sl_policy, &n->li_group);
-	l->l_tree_node = n;
-}
-
-struct ldlm_interval *ldlm_interval_alloc(struct ldlm_lock *lock)
-{
-	struct ldlm_interval *node;
-
-	LASSERT(lock->l_resource->lr_type == LDLM_EXTENT);
-	node = kmem_cache_zalloc(ldlm_interval_slab, GFP_NOFS);
-	if (!node)
-		return NULL;
-
-	INIT_LIST_HEAD(&node->li_group);
-	ldlm_interval_attach(node, lock);
-	return node;
-}
-
-void ldlm_interval_free(struct ldlm_interval *node)
-{
-	if (node) {
-		LASSERT(list_empty(&node->li_group));
-		LASSERT(!interval_is_intree(&node->li_node));
-		kmem_cache_free(ldlm_interval_slab, node);
-	}
-}
-
-struct ldlm_interval *ldlm_interval_detach(struct ldlm_lock *l)
-{
-	struct ldlm_interval *n = l->l_tree_node;
-
-	if (!n)
-		return NULL;
-
-	LASSERT(!list_empty(&n->li_group));
-	l->l_tree_node = NULL;
-	list_del_init(&l->l_sl_policy);
-
-	return list_empty(&n->li_group) ? n : NULL;
-}
-
 static inline int lock_mode_to_index(enum ldlm_mode mode)
 {
 	int index;
@@ -157,16 +108,13 @@ static inline int lock_mode_to_index(enum ldlm_mode mode)
 void ldlm_extent_add_lock(struct ldlm_resource *res,
 			  struct ldlm_lock *lock)
 {
-	struct interval_node *found, **root;
-	struct ldlm_interval *node;
+	struct interval_node **root;
 	struct ldlm_extent *extent;
 	int idx, rc;
 
 	LASSERT(lock->l_granted_mode == lock->l_req_mode);
 
-	node = lock->l_tree_node;
-	LASSERT(node);
-	LASSERT(!interval_is_intree(&node->li_node));
+	LASSERT(!interval_is_intree(&lock->l_tree_node));
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
 	LASSERT(lock->l_granted_mode == 1 << idx);
@@ -174,18 +122,11 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 
 	/* node extent initialize */
 	extent = &lock->l_policy_data.l_extent;
-	rc = interval_set(&node->li_node, extent->start, extent->end);
+	rc = interval_set(&lock->l_tree_node, extent->start, extent->end);
 	LASSERT(!rc);
 
 	root = &res->lr_itree[idx].lit_root;
-	found = interval_insert(&node->li_node, root);
-	if (found) { /* The policy group found. */
-		struct ldlm_interval *tmp;
-
-		tmp = ldlm_interval_detach(lock);
-		ldlm_interval_free(tmp);
-		ldlm_interval_attach(to_ldlm_interval(found), lock);
-	}
+	interval_insert(&lock->l_tree_node, root);
 	res->lr_itree[idx].lit_size++;
 
 	/* even though we use interval tree to manage the extent lock, we also
@@ -219,11 +160,10 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 {
 	struct ldlm_resource *res = lock->l_resource;
-	struct ldlm_interval *node = lock->l_tree_node;
 	struct ldlm_interval_tree *tree;
 	int idx;
 
-	if (!node || !interval_is_intree(&node->li_node)) /* duplicate unlink */
+	if (!interval_is_intree(&lock->l_tree_node)) /* duplicate unlink */
 		return;
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
@@ -233,11 +173,7 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 	LASSERT(tree->lit_root); /* assure the tree is not null */
 
 	tree->lit_size--;
-	node = ldlm_interval_detach(lock);
-	if (node) {
-		interval_erase(&node->li_node, &tree->lit_root);
-		ldlm_interval_free(node);
-	}
+	interval_erase(&lock->l_tree_node, &tree->lit_root);
 }
 
 void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index bc33ca100620..159de8a59cbb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -189,23 +189,6 @@ __u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
 void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
 __u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
 
-/* interval tree, for LDLM_EXTENT. */
-extern struct kmem_cache *ldlm_interval_slab; /* slab cache for ldlm_interval */
-struct ldlm_interval *ldlm_interval_detach(struct ldlm_lock *l);
-struct ldlm_interval *ldlm_interval_alloc(struct ldlm_lock *lock);
-void ldlm_interval_free(struct ldlm_interval *node);
-/* this function must be called with res lock held */
-static inline struct ldlm_extent *
-ldlm_interval_extent(struct ldlm_interval *node)
-{
-	struct ldlm_lock *lock;
-
-	LASSERT(!list_empty(&node->li_group));
-
-	lock = list_entry(node->li_group.next, struct ldlm_lock, l_sl_policy);
-	return &lock->l_policy_data.l_extent;
-}
-
 int ldlm_init(void);
 void ldlm_exit(void);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index a644d133063b..13b1b5fdada9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -185,7 +185,6 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 
 		kfree(lock->l_lvb_data);
 
-		ldlm_interval_free(ldlm_interval_detach(lock));
 		lu_ref_fini(&lock->l_reference);
 		OBD_FREE_RCU(lock, sizeof(*lock), &lock->l_handle);
 	}
@@ -1138,17 +1137,10 @@ static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
 
 static enum interval_iter itree_overlap_cb(struct interval_node *in, void *args)
 {
-	struct ldlm_interval *node = to_ldlm_interval(in);
 	struct lock_match_data *data = args;
-	struct ldlm_lock *lock;
-	int rc;
+	struct ldlm_lock *lock = container_of(in, struct ldlm_lock, l_tree_node);
 
-	list_for_each_entry(lock, &node->li_group, l_sl_policy) {
-		rc = lock_matches(lock, data);
-		if (rc == INTERVAL_ITER_STOP)
-			return INTERVAL_ITER_STOP;
-	}
-	return INTERVAL_ITER_CONT;
+	return lock_matches(lock, data);
 }
 
 /**
@@ -1564,15 +1556,6 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 		lock->l_glimpse_ast = cbs->lcs_glimpse;
 	}
 
-	lock->l_tree_node = NULL;
-	/* if this is the extent lock, allocate the interval tree node */
-	if (type == LDLM_EXTENT) {
-		if (!ldlm_interval_alloc(lock)) {
-			rc = -ENOMEM;
-			goto out;
-		}
-	}
-
 	if (lvb_len) {
 		lock->l_lvb_len = lvb_len;
 		lock->l_lvb_data = kzalloc(lvb_len, GFP_NOFS);
@@ -1625,10 +1608,6 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 
 	ldlm_resource_unlink_lock(lock);
 
-	/* Cannot happen unless on the server */
-	if (res->lr_type == LDLM_EXTENT && !lock->l_tree_node)
-		LBUG();
-
 	/* Some flags from the enqueue want to make it into the AST, via the
 	 * lock's l_flags.
 	 */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 5963e90d0938..f410ef6c02ef 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1134,14 +1134,6 @@ int ldlm_init(void)
 		return -ENOMEM;
 	}
 
-	ldlm_interval_slab = kmem_cache_create("interval_node",
-					       sizeof(struct ldlm_interval),
-					       0, SLAB_HWCACHE_ALIGN, NULL);
-	if (!ldlm_interval_slab) {
-		kmem_cache_destroy(ldlm_resource_slab);
-		kmem_cache_destroy(ldlm_lock_slab);
-		return -ENOMEM;
-	}
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	class_export_dump_hook = ldlm_dump_export_locks;
 #endif
@@ -1159,5 +1151,4 @@ void ldlm_exit(void)
 	 */
 	synchronize_rcu();
 	kmem_cache_destroy(ldlm_lock_slab);
-	kmem_cache_destroy(ldlm_interval_slab);
 }
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index 008a8874118d..eaa23f4c414e 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -74,19 +74,12 @@ int range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
 	if (rc)
 		return rc;
 
-	INIT_LIST_HEAD(&lock->rl_next_lock);
 	lock->rl_task = NULL;
-	lock->rl_lock_count = 0;
 	lock->rl_blocking_ranges = 0;
 	lock->rl_sequence = 0;
 	return rc;
 }
 
-static inline struct range_lock *next_lock(struct range_lock *lock)
-{
-	return list_entry(lock->rl_next_lock.next, typeof(*lock), rl_next_lock);
-}
-
 /**
  * Helper function of range_unlock()
  *
@@ -102,14 +95,7 @@ static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
 {
 	struct range_lock *lock = arg;
 	struct range_lock *overlap = node2rangelock(node);
-	struct range_lock *iter;
 
-	list_for_each_entry(iter, &overlap->rl_next_lock, rl_next_lock) {
-		if (iter->rl_sequence > lock->rl_sequence) {
-			--iter->rl_blocking_ranges;
-			LASSERT(iter->rl_blocking_ranges > 0);
-		}
-	}
 	if (overlap->rl_sequence > lock->rl_sequence) {
 		--overlap->rl_blocking_ranges;
 		if (overlap->rl_blocking_ranges == 0)
@@ -131,32 +117,8 @@ static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
 void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
 {
 	spin_lock(&tree->rlt_lock);
-	if (!list_empty(&lock->rl_next_lock)) {
-		struct range_lock *next;
-
-		if (interval_is_intree(&lock->rl_node)) { /* first lock */
-			/* Insert the next same range lock into the tree */
-			next = next_lock(lock);
-			next->rl_lock_count = lock->rl_lock_count - 1;
-			interval_erase(&lock->rl_node, &tree->rlt_root);
-			interval_insert(&next->rl_node, &tree->rlt_root);
-		} else {
-			/* find the first lock in tree */
-			list_for_each_entry(next, &lock->rl_next_lock,
-					    rl_next_lock) {
-				if (!interval_is_intree(&next->rl_node))
-					continue;
-
-				LASSERT(next->rl_lock_count > 0);
-				next->rl_lock_count--;
-				break;
-			}
-		}
-		list_del_init(&lock->rl_next_lock);
-	} else {
-		LASSERT(interval_is_intree(&lock->rl_node));
-		interval_erase(&lock->rl_node, &tree->rlt_root);
-	}
+	LASSERT(interval_is_intree(&lock->rl_node));
+	interval_erase(&lock->rl_node, &tree->rlt_root);
 
 	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
 			range_unlock_cb, lock);
@@ -177,9 +139,8 @@ void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
 static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
 {
 	struct range_lock *lock = arg;
-	struct range_lock *overlap = node2rangelock(node);
 
-	lock->rl_blocking_ranges += overlap->rl_lock_count + 1;
+	lock->rl_blocking_ranges++;
 	return INTERVAL_ITER_CONT;
 }
 
@@ -198,7 +159,6 @@ static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
  */
 int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
 {
-	struct interval_node *node;
 	int rc = 0;
 
 	spin_lock(&tree->rlt_lock);
@@ -208,18 +168,7 @@ int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
 	 */
 	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
 			range_lock_cb, lock);
-	/*
-	 * Insert to the tree if I am unique, otherwise I've been linked to
-	 * the rl_next_lock of another lock which has the same range as mine
-	 * in range_lock_cb().
-	 */
-	node = interval_insert(&lock->rl_node, &tree->rlt_root);
-	if (node) {
-		struct range_lock *tmp = node2rangelock(node);
-
-		list_add_tail(&lock->rl_next_lock, &tmp->rl_next_lock);
-		tmp->rl_lock_count++;
-	}
+	interval_insert(&lock->rl_node, &tree->rlt_root);
 	lock->rl_sequence = ++tree->rlt_sequence;
 
 	while (lock->rl_blocking_ranges > 0) {
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index 9ebac09160f2..10ef1a995d26 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -46,14 +46,6 @@ struct range_lock {
 	 * Process to enqueue this lock.
 	 */
 	struct task_struct	*rl_task;
-	/**
-	 * List of locks with the same range.
-	 */
-	struct list_head	rl_next_lock;
-	/**
-	 * Number of locks in the list rl_next_lock
-	 */
-	unsigned int		rl_lock_count;
 	/**
 	 * Number of ranges which are blocking acquisition of the lock
 	 */
