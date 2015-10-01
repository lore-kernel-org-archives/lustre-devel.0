From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:17 -0400
Subject: [lustre-devel] [PATCH 07/32] staging/lustre/ldlm: Remove unused
	interval tree bits
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

On client side interval-tree code operations are pretty basic,
so get rid of the code that is only used on the server to figure
out how much to extend the locks and such.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/interval_tree.h  |  36 ---
 drivers/staging/lustre/lustre/ldlm/interval_tree.c | 271 ---------------------
 2 files changed, 307 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index bf9027d..f6df3f3 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -67,11 +67,6 @@ static inline int interval_is_intree(struct interval_node *node)
 	return node->in_intree == 1;
 }
 
-static inline __u64 interval_low(struct interval_node *node)
-{
-	return node->in_extent.start;
-}
-
 static inline __u64 interval_high(struct interval_node *node)
 {
 	return node->in_extent.end;
@@ -86,39 +81,8 @@ static inline void interval_set(struct interval_node *node,
 	node->in_max_high = end;
 }
 
-/* Rules to write an interval callback.
- *  - the callback returns INTERVAL_ITER_STOP when it thinks the iteration
- *    should be stopped. It will then cause the iteration function to return
- *    immediately with return value INTERVAL_ITER_STOP.
- *  - callbacks for interval_iterate and interval_iterate_reverse: Every
- *    nodes in the tree will be set to @node before the callback being called
- *  - callback for interval_search: Only overlapped node will be set to @node
- *    before the callback being called.
- */
-typedef enum interval_iter (*interval_callback_t)(struct interval_node *node,
-						  void *args);
-
 struct interval_node *interval_insert(struct interval_node *node,
 				      struct interval_node **root);
 void interval_erase(struct interval_node *node, struct interval_node **root);
 
-/* Search the extents in the tree and call @func for each overlapped
- * extents. */
-enum interval_iter interval_search(struct interval_node *root,
-				   struct interval_node_extent *ex,
-				   interval_callback_t func, void *data);
-
-/* Iterate every node in the tree - by reverse order or regular order. */
-enum interval_iter interval_iterate(struct interval_node *root,
-				    interval_callback_t func, void *data);
-enum interval_iter interval_iterate_reverse(struct interval_node *root,
-				    interval_callback_t func, void *data);
-
-void interval_expand(struct interval_node *root,
-		     struct interval_node_extent *ext,
-		     struct interval_node_extent *limiter);
-int interval_is_overlapped(struct interval_node *root,
-			   struct interval_node_extent *ex);
-struct interval_node *interval_find(struct interval_node *root,
-				    struct interval_node_extent *ex);
 #endif
diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index eab2bd6..3d2d85b 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -96,12 +96,6 @@ static inline int extent_equal(struct interval_node_extent *e1,
 	return (e1->start == e2->start) && (e1->end == e2->end);
 }
 
-static inline int extent_overlapped(struct interval_node_extent *e1,
-				    struct interval_node_extent *e2)
-{
-	return (e1->start <= e2->end) && (e2->start <= e1->end);
-}
-
 static inline int node_compare(struct interval_node *n1,
 			       struct interval_node *n2)
 {
@@ -119,19 +113,6 @@ static inline __u64 max_u64(__u64 x, __u64 y)
 	return x > y ? x : y;
 }
 
-static inline __u64 min_u64(__u64 x, __u64 y)
-{
-	return x < y ? x : y;
-}
-
-#define interval_for_each(node, root)		   \
-for (node = interval_first(root); node != NULL;	 \
-	node = interval_next(node))
-
-#define interval_for_each_reverse(node, root)	   \
-for (node = interval_last(root); node != NULL;	  \
-	node = interval_prev(node))
-
 static struct interval_node *interval_first(struct interval_node *node)
 {
 	if (!node)
@@ -141,15 +122,6 @@ static struct interval_node *interval_first(struct interval_node *node)
 	return node;
 }
 
-static struct interval_node *interval_last(struct interval_node *node)
-{
-	if (!node)
-		return NULL;
-	while (node->in_right)
-		node = node->in_right;
-	return node;
-}
-
 static struct interval_node *interval_next(struct interval_node *node)
 {
 	if (!node)
@@ -161,76 +133,6 @@ static struct interval_node *interval_next(struct interval_node *node)
 	return node->in_parent;
 }
 
-static struct interval_node *interval_prev(struct interval_node *node)
-{
-	if (!node)
-		return NULL;
-
-	if (node->in_left)
-		return interval_last(node->in_left);
-
-	while (node->in_parent && node_is_left_child(node))
-		node = node->in_parent;
-
-	return node->in_parent;
-}
-
-enum interval_iter interval_iterate(struct interval_node *root,
-				    interval_callback_t func,
-				    void *data)
-{
-	struct interval_node *node;
-	enum interval_iter rc = INTERVAL_ITER_CONT;
-
-	interval_for_each(node, root) {
-		rc = func(node, data);
-		if (rc == INTERVAL_ITER_STOP)
-			break;
-	}
-
-	return rc;
-}
-EXPORT_SYMBOL(interval_iterate);
-
-enum interval_iter interval_iterate_reverse(struct interval_node *root,
-					    interval_callback_t func,
-					    void *data)
-{
-	struct interval_node *node;
-	enum interval_iter rc = INTERVAL_ITER_CONT;
-
-	interval_for_each_reverse(node, root) {
-		rc = func(node, data);
-		if (rc == INTERVAL_ITER_STOP)
-			break;
-	}
-
-	return rc;
-}
-EXPORT_SYMBOL(interval_iterate_reverse);
-
-/* try to find a node with same interval in the tree,
- * if found, return the pointer to the node, otherwise return NULL*/
-struct interval_node *interval_find(struct interval_node *root,
-				    struct interval_node_extent *ex)
-{
-	struct interval_node *walk = root;
-	int rc;
-
-	while (walk) {
-		rc = extent_compare(ex, &walk->in_extent);
-		if (rc == 0)
-			break;
-		else if (rc < 0)
-			walk = walk->in_left;
-		else
-			walk = walk->in_right;
-	}
-
-	return walk;
-}
-EXPORT_SYMBOL(interval_find);
-
 static void __rotate_change_maxhigh(struct interval_node *node,
 				    struct interval_node *rotate)
 {
@@ -576,176 +478,3 @@ color:
 		interval_erase_color(child, parent, root);
 }
 EXPORT_SYMBOL(interval_erase);
-
-static inline int interval_may_overlap(struct interval_node *node,
-					  struct interval_node_extent *ext)
-{
-	return (ext->start <= node->in_max_high &&
-		ext->end >= interval_low(node));
-}
-
-/*
- * This function finds all intervals that overlap interval ext,
- * and calls func to handle resulted intervals one by one.
- * in lustre, this function will find all conflicting locks in
- * the granted queue and add these locks to the ast work list.
- *
- * {
- *       if (node == NULL)
- *	       return 0;
- *       if (ext->end < interval_low(node)) {
- *	       interval_search(node->in_left, ext, func, data);
- *       } else if (interval_may_overlap(node, ext)) {
- *	       if (extent_overlapped(ext, &node->in_extent))
- *		       func(node, data);
- *	       interval_search(node->in_left, ext, func, data);
- *	       interval_search(node->in_right, ext, func, data);
- *       }
- *       return 0;
- * }
- *
- */
-enum interval_iter interval_search(struct interval_node *node,
-				   struct interval_node_extent *ext,
-				   interval_callback_t func,
-				   void *data)
-{
-	struct interval_node *parent;
-	enum interval_iter rc = INTERVAL_ITER_CONT;
-
-	LASSERT(ext != NULL);
-	LASSERT(func != NULL);
-
-	while (node) {
-		if (ext->end < interval_low(node)) {
-			if (node->in_left) {
-				node = node->in_left;
-				continue;
-			}
-		} else if (interval_may_overlap(node, ext)) {
-			if (extent_overlapped(ext, &node->in_extent)) {
-				rc = func(node, data);
-				if (rc == INTERVAL_ITER_STOP)
-					break;
-			}
-
-			if (node->in_left) {
-				node = node->in_left;
-				continue;
-			}
-			if (node->in_right) {
-				node = node->in_right;
-				continue;
-			}
-		}
-
-		parent = node->in_parent;
-		while (parent) {
-			if (node_is_left_child(node) &&
-			    parent->in_right) {
-				/* If we ever got the left, it means that the
-				 * parent met ext->end<interval_low(parent), or
-				 * may_overlap(parent). If the former is true,
-				 * we needn't go back. So stop early and check
-				 * may_overlap(parent) after this loop.  */
-				node = parent->in_right;
-				break;
-			}
-			node = parent;
-			parent = parent->in_parent;
-		}
-		if (parent == NULL || !interval_may_overlap(parent, ext))
-			break;
-	}
-
-	return rc;
-}
-EXPORT_SYMBOL(interval_search);
-
-static enum interval_iter interval_overlap_cb(struct interval_node *n,
-					      void *args)
-{
-	*(int *)args = 1;
-	return INTERVAL_ITER_STOP;
-}
-
-int interval_is_overlapped(struct interval_node *root,
-			   struct interval_node_extent *ext)
-{
-	int has = 0;
-	(void)interval_search(root, ext, interval_overlap_cb, &has);
-	return has;
-}
-EXPORT_SYMBOL(interval_is_overlapped);
-
-/* Don't expand to low. Expanding downwards is expensive, and meaningless to
- * some extents, because programs seldom do IO backward.
- *
- * The recursive algorithm of expanding low:
- * expand_low {
- *	struct interval_node *tmp;
- *	static __u64 res = 0;
- *
- *	if (root == NULL)
- *		return res;
- *	if (root->in_max_high < low) {
- *		res = max_u64(root->in_max_high + 1, res);
- *		return res;
- *	} else if (low < interval_low(root)) {
- *		interval_expand_low(root->in_left, low);
- *		return res;
- *	}
- *
- *	if (interval_high(root) < low)
- *		res = max_u64(interval_high(root) + 1, res);
- *	interval_expand_low(root->in_left, low);
- *	interval_expand_low(root->in_right, low);
- *
- *	return res;
- * }
- *
- * It's much easy to eliminate the recursion, see interval_search for
- * an example. -jay
- */
-static inline __u64 interval_expand_low(struct interval_node *root, __u64 low)
-{
-	/* we only concern the empty tree right now. */
-	if (root == NULL)
-		return 0;
-	return low;
-}
-
-static inline __u64 interval_expand_high(struct interval_node *node, __u64 high)
-{
-	__u64 result = ~0;
-
-	while (node != NULL) {
-		if (node->in_max_high < high)
-			break;
-
-		if (interval_low(node) > high) {
-			result = interval_low(node) - 1;
-			node = node->in_left;
-		} else {
-			node = node->in_right;
-		}
-	}
-
-	return result;
-}
-
-/* expanding the extent based on @ext. */
-void interval_expand(struct interval_node *root,
-		     struct interval_node_extent *ext,
-		     struct interval_node_extent *limiter)
-{
-	/* The assertion of interval_is_overlapped is expensive because we may
-	 * travel many nodes to find the overlapped node. */
-	LASSERT(interval_is_overlapped(root, ext) == 0);
-	if (!limiter || limiter->start < ext->start)
-		ext->start = interval_expand_low(root, ext->start);
-	if (!limiter || limiter->end > ext->end)
-		ext->end = interval_expand_high(root, ext->end);
-	LASSERT(interval_is_overlapped(root, ext) == 0);
-}
-EXPORT_SYMBOL(interval_expand);
-- 
2.1.0
