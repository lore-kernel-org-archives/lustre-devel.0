From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:19 +1000
Subject: [lustre-devel] [PATCH 04/11] staging: lustre: convert range_lock to
 linux interval_trees.
In-Reply-To: <152826510267.16761.14361003167157833896.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
Message-ID: <152826511902.16761.12169723574817283239.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Linux has a fully-generic interval tree implementation
which can be tailored to different use cases.
Use it for range_lock rather than the lustre version.
This allows us to get rid of some call-backs and generally
simplifies the code.

We cannot use the pre-built version in lib/interval_tree.c
as we need 64bit endpoints and it only provides "unsigned long".

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/file.c       |    8 +-
 drivers/staging/lustre/lustre/llite/range_lock.c |   94 ++++++++--------------
 drivers/staging/lustre/lustre/llite/range_lock.h |   17 ++--
 3 files changed, 47 insertions(+), 72 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 02295931883b..e888ed6e74bc 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1086,8 +1086,8 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 		     (iot == CIT_READ && (file->f_flags & O_DIRECT))) &&
 		    !(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
 			CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
-			       range.rl_node.in_extent.start,
-			       range.rl_node.in_extent.end);
+			       range.rl_start,
+			       range.rl_last);
 			rc = range_lock(&lli->lli_write_tree, &range);
 			if (rc < 0)
 				goto out;
@@ -1099,8 +1099,8 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 		ll_cl_remove(file, env);
 		if (range_locked) {
 			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
-			       range.rl_node.in_extent.start,
-			       range.rl_node.in_extent.end);
+			       range.rl_start,
+			       range.rl_last);
 			range_unlock(&lli->lli_write_tree, &range);
 		}
 	} else {
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index eaa23f4c414e..acdb0dc00a89 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -37,7 +37,13 @@
 #include "range_lock.h"
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <linux/libcfs/libcfs.h>
+#include <linux/interval_tree_generic.h>
 
+#define START(node) ((node)->rl_start)
+#define LAST(node)  ((node)->rl_last)
+
+INTERVAL_TREE_DEFINE(struct range_lock, rl_rb, __u64, __subtree_last,
+		     START, LAST, static, range);
 /**
  * Initialize a range lock tree
  *
@@ -48,7 +54,7 @@
  */
 void range_lock_tree_init(struct range_lock_tree *tree)
 {
-	tree->rlt_root = NULL;
+	tree->rlt_root = RB_ROOT_CACHED;
 	tree->rlt_sequence = 0;
 	spin_lock_init(&tree->rlt_lock);
 }
@@ -65,43 +71,19 @@ void range_lock_tree_init(struct range_lock_tree *tree)
  */
 int range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
 {
-	int rc;
+	RB_CLEAR_NODE(&lock->rl_rb);
 
-	memset(&lock->rl_node, 0, sizeof(lock->rl_node));
 	if (end != LUSTRE_EOF)
 		end >>= PAGE_SHIFT;
-	rc = interval_set(&lock->rl_node, start >> PAGE_SHIFT, end);
-	if (rc)
-		return rc;
+	lock->rl_start = start >> PAGE_SHIFT;
+	lock->rl_last = end;
+	if (lock->rl_start > lock->rl_last)
+		return -ERANGE;
 
 	lock->rl_task = NULL;
 	lock->rl_blocking_ranges = 0;
 	lock->rl_sequence = 0;
-	return rc;
-}
-
-/**
- * Helper function of range_unlock()
- *
- * \param node [in]	a range lock found overlapped during interval node
- *			search
- * \param arg [in]	the range lock to be tested
- *
- * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
- *				overlapping range node
- * \retval INTERVAL_ITER_STOP	indicate to stop the search
- */
-static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
-{
-	struct range_lock *lock = arg;
-	struct range_lock *overlap = node2rangelock(node);
-
-	if (overlap->rl_sequence > lock->rl_sequence) {
-		--overlap->rl_blocking_ranges;
-		if (overlap->rl_blocking_ranges == 0)
-			wake_up_process(overlap->rl_task);
-	}
-	return INTERVAL_ITER_CONT;
+	return 0;
 }
 
 /**
@@ -112,36 +94,27 @@ static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
  *
  * If this lock has been granted, relase it; if not, just delete it from
  * the tree or the same region lock list. Wake up those locks only blocked
- * by this lock through range_unlock_cb().
+ * by this lock.
  */
 void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
 {
-	spin_lock(&tree->rlt_lock);
-	LASSERT(interval_is_intree(&lock->rl_node));
-	interval_erase(&lock->rl_node, &tree->rlt_root);
+	struct range_lock *overlap;
 
-	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
-			range_unlock_cb, lock);
-	spin_unlock(&tree->rlt_lock);
-}
+	spin_lock(&tree->rlt_lock);
+	LASSERT(!RB_EMPTY_NODE(&lock->rl_rb));
+	range_remove(lock, &tree->rlt_root);
 
-/**
- * Helper function of range_lock()
- *
- * \param node [in]	a range lock found overlapped during interval node
- *			search
- * \param arg [in]	the range lock to be tested
- *
- * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
- *				overlapping range node
- * \retval INTERVAL_ITER_STOP	indicate to stop the search
- */
-static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
-{
-	struct range_lock *lock = arg;
+	for (overlap = range_iter_first(&tree->rlt_root,
+					lock->rl_start, lock->rl_last);
+	     overlap;
+	     overlap = range_iter_next(overlap, lock->rl_start, lock->rl_last))
+		if (overlap->rl_sequence > lock->rl_sequence) {
+			--overlap->rl_blocking_ranges;
+			if (overlap->rl_blocking_ranges == 0)
+				wake_up_process(overlap->rl_task);
+		}
 
-	lock->rl_blocking_ranges++;
-	return INTERVAL_ITER_CONT;
+	spin_unlock(&tree->rlt_lock);
 }
 
 /**
@@ -160,15 +133,20 @@ static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
 int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
 {
 	int rc = 0;
+	struct range_lock *it;
 
 	spin_lock(&tree->rlt_lock);
 	/*
 	 * We need to check for all conflicting intervals
 	 * already in the tree.
 	 */
-	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
-			range_lock_cb, lock);
-	interval_insert(&lock->rl_node, &tree->rlt_root);
+	for (it = range_iter_first(&tree->rlt_root,
+				   lock->rl_start, lock->rl_last);
+	     it;
+	     it = range_iter_next(it, lock->rl_start, lock->rl_last))
+		lock->rl_blocking_ranges++;
+
+	range_insert(lock, &tree->rlt_root);
 	lock->rl_sequence = ++tree->rlt_sequence;
 
 	while (lock->rl_blocking_ranges > 0) {
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index 10ef1a995d26..2a0704d21481 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -38,10 +38,12 @@
 #define _RANGE_LOCK_H
 
 #include <linux/spinlock.h>
-#include <interval_tree.h>
+#include <linux/rbtree.h>
 
 struct range_lock {
-	struct interval_node	rl_node;
+	struct rb_node		rl_rb;
+	__u64			rl_start, rl_last;
+	__u64			__subtree_last;
 	/**
 	 * Process to enqueue this lock.
 	 */
@@ -57,15 +59,10 @@ struct range_lock {
 	__u64			rl_sequence;
 };
 
-static inline struct range_lock *node2rangelock(const struct interval_node *n)
-{
-	return container_of(n, struct range_lock, rl_node);
-}
-
 struct range_lock_tree {
-	struct interval_node	*rlt_root;
-	spinlock_t		 rlt_lock;	/* protect range lock tree */
-	__u64			 rlt_sequence;
+	struct rb_root_cached	rlt_root;
+	spinlock_t		rlt_lock;	/* protect range lock tree */
+	__u64			rlt_sequence;
 };
 
 void range_lock_tree_init(struct range_lock_tree *tree);
