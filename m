From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:04 -0500
Subject: [lustre-devel] [PATCH 36/60] staging: lustre: header: remove assert
	from interval_set()
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

In the case of interval_tree.h only interval_set()
uses LASSERT which is removed in this patch and
interval_set() instead reports a real error. The
header libcfs.h for interval_tree.h is not needed
anymore so we can just use the standard linux
kernel headers instead.h

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/22522
Reviewed-on: https://review.whamcloud.com/24323
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/interval_tree.h | 12 ++++++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c      |  5 +++--
 drivers/staging/lustre/lustre/llite/range_lock.c      | 10 ++++++++--
 drivers/staging/lustre/lustre/llite/range_lock.h      |  2 +-
 4 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index 5d387d3..0d4f92e 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -36,7 +36,9 @@
 #ifndef _INTERVAL_H__
 #define _INTERVAL_H__
 
-#include "../../include/linux/libcfs/libcfs.h"	/* LASSERT. */
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/types.h>
 
 struct interval_node {
 	struct interval_node   *in_left;
@@ -73,13 +75,15 @@ static inline __u64 interval_high(struct interval_node *node)
 	return node->in_extent.end;
 }
 
-static inline void interval_set(struct interval_node *node,
-				__u64 start, __u64 end)
+static inline int interval_set(struct interval_node *node,
+			       __u64 start, __u64 end)
 {
-	LASSERT(start <= end);
+	if (start > end)
+		return -ERANGE;
 	node->in_extent.start = start;
 	node->in_extent.end = end;
 	node->in_max_high = end;
+	return 0;
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 5616ea4..08f97e2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -162,7 +162,7 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 	struct interval_node *found, **root;
 	struct ldlm_interval *node;
 	struct ldlm_extent *extent;
-	int idx;
+	int idx, rc;
 
 	LASSERT(lock->l_granted_mode == lock->l_req_mode);
 
@@ -176,7 +176,8 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 
 	/* node extent initialize */
 	extent = &lock->l_policy_data.l_extent;
-	interval_set(&node->li_node, extent->start, extent->end);
+	rc = interval_set(&node->li_node, extent->start, extent->end);
+	LASSERT(!rc);
 
 	root = &res->lr_itree[idx].lit_root;
 	found = interval_insert(&node->li_node, root);
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index 94c818f..14148a0 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -61,17 +61,23 @@ void range_lock_tree_init(struct range_lock_tree *tree)
  * Pre:  Caller should have allocated the range lock node.
  * Post: The range lock node is meant to cover [start, end] region
  */
-void range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
+int range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
 {
+	int rc;
+
 	memset(&lock->rl_node, 0, sizeof(lock->rl_node));
 	if (end != LUSTRE_EOF)
 		end >>= PAGE_SHIFT;
-	interval_set(&lock->rl_node, start >> PAGE_SHIFT, end);
+	rc = interval_set(&lock->rl_node, start >> PAGE_SHIFT, end);
+	if (rc)
+		return rc;
+
 	INIT_LIST_HEAD(&lock->rl_next_lock);
 	lock->rl_task = NULL;
 	lock->rl_lock_count = 0;
 	lock->rl_blocking_ranges = 0;
 	lock->rl_sequence = 0;
+	return rc;
 }
 
 static inline struct range_lock *next_lock(struct range_lock *lock)
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index c6d04a6..779091c 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -76,7 +76,7 @@ struct range_lock_tree {
 };
 
 void range_lock_tree_init(struct range_lock_tree *tree);
-void range_lock_init(struct range_lock *lock, __u64 start, __u64 end);
+int range_lock_init(struct range_lock *lock, __u64 start, __u64 end);
 int  range_lock(struct range_lock_tree *tree, struct range_lock *lock);
 void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
 #endif
-- 
1.8.3.1
