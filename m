From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:19 +1000
Subject: [lustre-devel] [PATCH 05/11] staging: lustre: convert ldlm extent
 locks to linux extent-tree
In-Reply-To: <152826510267.16761.14361003167157833896.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
Message-ID: <152826511905.16761.134377818890309985.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

As linux has a fully customizable extent tree implementation,
use that instead of the one in lustre.
This has a small benefit in that the start/end only need to
be stored in the ldlm_lock once instead of twice - in both
l_policy_data.l_exent and l_tree_node.
It also makes the code simpler.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    9 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   61 ++++++++------------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    4 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   11 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 -
 5 files changed, 36 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index baeb8c63352b..4f196c27b76b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -49,7 +49,6 @@
 #include <lustre_net.h>
 #include <lustre_import.h>
 #include <lustre_handles.h>
-#include <interval_tree.h>	/* for interval_node{}, ldlm_extent */
 #include <lu_ref.h>
 
 #include "lustre_dlm_flags.h"
@@ -523,7 +522,7 @@ struct ldlm_interval_tree {
 	/** Tree size. */
 	int			lit_size;
 	enum ldlm_mode		lit_mode;  /* lock mode */
-	struct interval_node	*lit_root; /* actual ldlm_interval */
+	struct rb_root_cached	lit_root; /* actual interval tree */
 };
 
 /** Whether to track references to exports by LDLM locks. */
@@ -619,9 +618,11 @@ struct ldlm_lock {
 	 */
 	struct list_head		l_res_link;
 	/**
-	 * Tree node for ldlm_extent.
+	 * Interval-tree node for ldlm_extent.
 	 */
-	struct interval_node	l_tree_node;
+	struct rb_node		l_rb;
+	__u64			__subtree_last;
+
 	/**
 	 * Requested mode.
 	 * Protected by lr_lock.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index eb1a9077a514..225c023b0bba 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -53,6 +53,12 @@
 #include <obd_class.h>
 #include <lustre_lib.h>
 #include "ldlm_internal.h"
+#include <linux/interval_tree_generic.h>
+
+#define START(node) ((node)->l_policy_data.l_extent.start)
+#define LAST(node) ((node)->l_policy_data.l_extent.end)
+INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, __u64, __subtree_last,
+		     START, LAST, static, extent);
 
 /* When a lock is cancelled by a client, the KMS may undergo change if this
  * is the "highest lock".  This function returns the new KMS value.
@@ -108,26 +114,20 @@ static inline int lock_mode_to_index(enum ldlm_mode mode)
 void ldlm_extent_add_lock(struct ldlm_resource *res,
 			  struct ldlm_lock *lock)
 {
-	struct interval_node **root;
-	struct ldlm_extent *extent;
-	int idx, rc;
+	struct ldlm_interval_tree *tree;
+	int idx;
 
 	LASSERT(lock->l_granted_mode == lock->l_req_mode);
 
-	LASSERT(!interval_is_intree(&lock->l_tree_node));
+	LASSERT(RB_EMPTY_NODE(&lock->l_rb));
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
 	LASSERT(lock->l_granted_mode == 1 << idx);
 	LASSERT(lock->l_granted_mode == res->lr_itree[idx].lit_mode);
 
-	/* node extent initialize */
-	extent = &lock->l_policy_data.l_extent;
-	rc = interval_set(&lock->l_tree_node, extent->start, extent->end);
-	LASSERT(!rc);
-
-	root = &res->lr_itree[idx].lit_root;
-	interval_insert(&lock->l_tree_node, root);
-	res->lr_itree[idx].lit_size++;
+	tree = &res->lr_itree[idx];
+	extent_insert(lock, &tree->lit_root);
+	tree->lit_size++;
 
 	/* even though we use interval tree to manage the extent lock, we also
 	 * add the locks into grant list, for debug purpose, ..
@@ -163,17 +163,15 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 	struct ldlm_interval_tree *tree;
 	int idx;
 
-	if (!interval_is_intree(&lock->l_tree_node)) /* duplicate unlink */
+	if (RB_EMPTY_NODE(&lock->l_rb)) /* duplicate unlink */
 		return;
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
 	LASSERT(lock->l_granted_mode == 1 << idx);
 	tree = &res->lr_itree[idx];
 
-	LASSERT(tree->lit_root); /* assure the tree is not null */
-
 	tree->lit_size--;
-	interval_erase(&lock->l_tree_node, &tree->lit_root);
+	extent_remove(lock, &tree->lit_root);
 }
 
 void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
@@ -193,29 +191,16 @@ void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 	wpolicy->l_extent.gid = lpolicy->l_extent.gid;
 }
 
-struct cb {
-	void *arg;
-	bool (*found)(struct ldlm_lock *lock, void *arg);
-};
-
-static enum interval_iter itree_overlap_cb(struct interval_node *in, void *arg)
-{
-	struct cb *cb = arg;
-	struct ldlm_lock *lock = container_of(in, struct ldlm_lock,
-					      l_tree_node);
-
-	return cb->found(lock, cb->arg) ?
-		INTERVAL_ITER_STOP : INTERVAL_ITER_CONT;
-}
-
-void ldlm_extent_search(struct interval_node *root,
-			struct interval_node_extent *ext,
+void ldlm_extent_search(struct rb_root_cached *root,
+			__u64 start, __u64 end,
 			bool (*matches)(struct ldlm_lock *lock, void *data),
 			void *data)
 {
-	struct cb cb = {
-		.arg = data,
-		.found = matches,
-	};
-	interval_search(root, ext, itree_overlap_cb, &cb);
+	struct ldlm_lock *lock;
+
+	for (lock = extent_iter_first(root, start, end);
+	     lock;
+	     lock = extent_iter_next(lock, start, end))
+		if (matches(lock, data))
+			break;
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 756fa3d9db3c..60a15b963c8a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -169,8 +169,8 @@ extern struct kmem_cache *ldlm_lock_slab;
 /* ldlm_extent.c */
 void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
 void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
-void ldlm_extent_search(struct interval_node *root,
-			struct interval_node_extent *ext,
+void ldlm_extent_search(struct rb_root_cached *root,
+			__u64 start, __u64 end,
 			bool (*matches)(struct ldlm_lock *lock, void *data),
 			void *data);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 4213fe047073..2fb2e088dc87 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -405,6 +405,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lock->l_blocking_lock = NULL;
 	INIT_LIST_HEAD(&lock->l_sl_mode);
 	INIT_LIST_HEAD(&lock->l_sl_policy);
+	RB_CLEAR_NODE(&lock->l_rb);
 
 	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
 			     LDLM_NSS_LOCKS);
@@ -1147,22 +1148,20 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 				      struct lock_match_data *data)
 {
-	struct interval_node_extent ext = {
-		.start	= data->lmd_policy->l_extent.start,
-		.end	= data->lmd_policy->l_extent.end
-	};
 	int idx;
 
 	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
 
-		if (!tree->lit_root)
+		if (RB_EMPTY_ROOT(&tree->lit_root.rb_root))
 			continue;
 
 		if (!(tree->lit_mode & *data->lmd_mode))
 			continue;
 
-		ldlm_extent_search(tree->lit_root, &ext,
+		ldlm_extent_search(&tree->lit_root,
+				   data->lmd_policy->l_extent.start,
+				   data->lmd_policy->l_extent.end,
 				   lock_matches, data);
 	}
 	return data->lmd_lock;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index c93b019b8e37..3946d62ff009 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1017,7 +1017,7 @@ static struct ldlm_resource *ldlm_resource_new(void)
 	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 		res->lr_itree[idx].lit_size = 0;
 		res->lr_itree[idx].lit_mode = 1 << idx;
-		res->lr_itree[idx].lit_root = NULL;
+		res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
 	}
 
 	atomic_set(&res->lr_refcount, 1);
