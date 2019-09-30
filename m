From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:36 -0400
Subject: [lustre-devel] [PATCH 017/151] lustre: ldlm: Use interval tree to
 update kms
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Currently, ldlm_extent_shift_kms does a linear search of
the list of granted locks on the resource when looking for
the lock to use to update the kms.

This can be avoided by using the interval trees which store
the extents of granted locks.
We change the interval tree to store locks in reverse order,
with lowest end first, and highest end last.
Then we can easily find the last lock-end that doesn't
ignore kms, and use that to choose a new kms.

NeilBrown: modified from original to work with linux interval-tree

WC-bug-id: https://jira.whamcloud.com/browse/LU-8272
Lustre-commit: e7cf1b060ba3 ("LU-8272 ldlm: Use interval tree to update kms")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/20779
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_extent.c | 66 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 51 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 0695f7e..66616b0 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -55,13 +55,22 @@
 #include "ldlm_internal.h"
 #include <linux/interval_tree_generic.h>
 
-#define START(node) ((node)->l_policy_data.l_extent.start)
-#define LAST(node) ((node)->l_policy_data.l_extent.end)
+/* We sort the interval tree in reverse order, because we sometimes
+ * and to find the interval with the highest end, and the first/next
+ * iteration only allows is to walk in increasing order of start.
+ */
+#define ISTART(end) (U64_MAX - (end))
+#define IEND(start) (U64_MAX - (start))
+
+#define START(node) ISTART((node)->l_policy_data.l_extent.end)
+#define LAST(node) IEND((node)->l_policy_data.l_extent.start)
 INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, u64, __subtree_last,
 		     START, LAST, static, extent);
 
 /* When a lock is cancelled by a client, the KMS may undergo change if this
- * is the "highest lock".  This function returns the new KMS value.
+ * is the "highest lock".  This function returns the new KMS value, updating
+ * it only if we were the highest lock.
+ *
  * Caller must hold lr_lock already.
  *
  * NB: A lock on [x,y] protects a KMS of up to y + 1 bytes!
@@ -69,8 +78,11 @@
 u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 {
 	struct ldlm_resource *res = lock->l_resource;
+	struct ldlm_interval_tree *tree;
 	struct ldlm_lock *lck;
 	u64 kms = 0;
+	int idx = 0;
+	bool complete;
 
 	/* don't let another thread in ldlm_extent_shift_kms race in
 	 * just after we finish and take our lock into account in its
@@ -78,20 +90,44 @@ u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 	 */
 	ldlm_set_kms_ignore(lock);
 
-	list_for_each_entry(lck, &res->lr_granted, l_res_link) {
-		if (ldlm_is_kms_ignore(lck))
-			continue;
+	/* We iterate over the lock trees, looking for the largest kms
+	 * smaller than the current one.  Note that each tree is
+	 * iterated starting a largest end, because the interval tree
+	 * is stored last-to-first order.
+	 */
+	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
+		tree = &res->lr_itree[idx];
 
-		if (lck->l_policy_data.l_extent.end >= old_kms)
-			return old_kms;
+		for (lck = extent_iter_first(&tree->lit_root, 0, U64_MAX);
+		     lck;
+		     lck = extent_iter_next(lck, 0, U64_MAX)) {
+			if (ldlm_is_kms_ignore(lck))
+				continue;
 
-		/* This extent _has_ to be smaller than old_kms (checked above)
-		 * so kms can only ever be smaller or the same as old_kms.
+			/* This is the last lock-end that doesn't ignore
+			 * kms.
+			 * If it has a greater or equal kms, we are not
+			 * the highest lock (or we share that distinction
+			 * with another lock), and don't need to update KMS.
+			 * Record old_kms and stop looking.
+			 */
+			if (lck->l_policy_data.l_extent.end >= old_kms) {
+				kms = old_kms;
+				complete = true;
+			} else
+				kms = lck->l_policy_data.l_extent.end + 1;
+			break;
+		}
+
+		/* this tells us we're not the highest lock, so we don't need
+		 * to check the remaining trees
 		 */
-		if (lck->l_policy_data.l_extent.end + 1 > kms)
-			kms = lck->l_policy_data.l_extent.end + 1;
+		if (complete)
+			break;
 	}
-	LASSERTF(kms <= old_kms, "kms %llu old_kms %llu\n", kms, old_kms);
+
+	LASSERTF(kms <= old_kms, "kms %llu old_kms %llu\n", kms,
+		 old_kms);
 
 	return kms;
 }
@@ -197,9 +233,9 @@ void ldlm_extent_search(struct rb_root_cached *root,
 {
 	struct ldlm_lock *lock;
 
-	for (lock = extent_iter_first(root, start, end);
+	for (lock = extent_iter_first(root, ISTART(end), IEND(start));
 	     lock;
-	     lock = extent_iter_next(lock, start, end))
+	     lock = extent_iter_next(lock, ISTART(end), IEND(start)))
 		if (matches(lock, data))
 			break;
 }
-- 
1.8.3.1
