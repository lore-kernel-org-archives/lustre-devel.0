From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:19 -0400
Subject: [lustre-devel] [PATCH 03/20] staging: lustre: ldlm: crash on umount
	in cleanup_resource
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <andriy.skulysh@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Andriy Skulysh <andriy.skulysh@seagate.com>

cfs_hash_for_each_relax() assumes that cfs_hash_put_locked()
doesn't release bd lock, but it isn't true for
ldlm_res_hop_put_locked().

Add recfcount on next hnode in cfs_hash_for_each_relax() and
remove ldlm_res_hop_put_locked()

Signed-off-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6304
Xyratex-bug-id: MRP-2352
Reviewed-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Reviewed-by: Alexander Boyko <alexander.boyko@seagate.com>
Tested-by: Alexander Lezhoev <alexander.lezhoev@seagate.com>
Reviewed-on: http://review.whamcloud.com/13908
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/hash.c          | 47 ++++++++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  3 --
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 43 --------------------
 3 files changed, 31 insertions(+), 62 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 5c2ce2e..ff54eaf 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1008,7 +1008,7 @@ struct cfs_hash *
 	LASSERT(ops->hs_object);
 	LASSERT(ops->hs_keycmp);
 	LASSERT(ops->hs_get);
-	LASSERT(ops->hs_put_locked);
+	LASSERT(ops->hs_put || ops->hs_put_locked);
 
 	if (flags & CFS_HASH_REHASH)
 		flags |= CFS_HASH_COUNTER; /* must have counter */
@@ -1553,19 +1553,20 @@ struct cfs_hash_cond_arg {
 cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 			void *data, int start)
 {
+	struct hlist_node *next = NULL;
 	struct hlist_node *hnode;
-	struct hlist_node *tmp;
 	struct cfs_hash_bd bd;
 	u32 version;
 	int count = 0;
 	int stop_on_change;
+	int has_put_locked;
 	int end = -1;
 	int rc = 0;
 	int i;
 
 	stop_on_change = cfs_hash_with_rehash_key(hs) ||
-			 !cfs_hash_with_no_itemref(hs) ||
-			 !hs->hs_ops->hs_put_locked;
+			 !cfs_hash_with_no_itemref(hs);
+	has_put_locked = hs->hs_ops->hs_put_locked != NULL;
 	cfs_hash_lock(hs, 0);
 again:
 	LASSERT(!cfs_hash_is_rehashing(hs));
@@ -1582,38 +1583,52 @@ struct cfs_hash_cond_arg {
 		version = cfs_hash_bd_version_get(&bd);
 
 		cfs_hash_bd_for_each_hlist(hs, &bd, hhead) {
-			for (hnode = hhead->first; hnode;) {
+			hnode = hhead->first;
+			if (!hnode)
+				continue;
+			cfs_hash_get(hs, hnode);
+
+			for (; hnode; hnode = next) {
 				cfs_hash_bucket_validate(hs, &bd, hnode);
-				cfs_hash_get(hs, hnode);
+				next = hnode->next;
+				if (next)
+					cfs_hash_get(hs, next);
 				cfs_hash_bd_unlock(hs, &bd, 0);
 				cfs_hash_unlock(hs, 0);
 
 				rc = func(hs, &bd, hnode, data);
-				if (stop_on_change)
+				if (stop_on_change || !has_put_locked)
 					cfs_hash_put(hs, hnode);
 				cond_resched();
 				count++;
 
 				cfs_hash_lock(hs, 0);
 				cfs_hash_bd_lock(hs, &bd, 0);
-				if (!stop_on_change) {
-					tmp = hnode->next;
-					cfs_hash_put_locked(hs, hnode);
-					hnode = tmp;
-				} else { /* bucket changed? */
+				if (stop_on_change) {
 					if (version !=
 					    cfs_hash_bd_version_get(&bd))
-						break;
-					/* safe to continue because no change */
-					hnode = hnode->next;
+						rc = -EINTR;
+				} else if (has_put_locked) {
+					cfs_hash_put_locked(hs, hnode);
 				}
 				if (rc) /* callback wants to break iteration */
 					break;
 			}
-			if (rc) /* callback wants to break iteration */
+			if (next) {
+				if (has_put_locked) {
+					cfs_hash_put_locked(hs, next);
+					next = NULL;
+				}
 				break;
+			} else if (rc) {
+				break;
+			}
 		}
 		cfs_hash_bd_unlock(hs, &bd, 0);
+		if (next && !has_put_locked) {
+			cfs_hash_put(hs, next);
+			next = NULL;
+		}
 		if (rc) /* callback wants to break iteration */
 			break;
 	}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index ec3b23c..2bf5c84 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -106,9 +106,6 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 extern unsigned int ldlm_enqueue_min;
 extern unsigned int ldlm_cancel_unused_locks_before_replay;
 
-/* ldlm_resource.c */
-int ldlm_resource_putref_locked(struct ldlm_resource *res);
-
 /* ldlm_lock.c */
 
 struct ldlm_cb_set_arg {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index eab44dc..4e805e7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -536,16 +536,6 @@ static void ldlm_res_hop_get_locked(struct cfs_hash *hs,
 	ldlm_resource_getref(res);
 }
 
-static void ldlm_res_hop_put_locked(struct cfs_hash *hs,
-				    struct hlist_node *hnode)
-{
-	struct ldlm_resource *res;
-
-	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-	/* cfs_hash_for_each_nolock is the only chance we call it */
-	ldlm_resource_putref_locked(res);
-}
-
 static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 {
 	struct ldlm_resource *res;
@@ -561,7 +551,6 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 	.hs_keycpy      = NULL,
 	.hs_object      = ldlm_res_hop_object,
 	.hs_get		= ldlm_res_hop_get_locked,
-	.hs_put_locked  = ldlm_res_hop_put_locked,
 	.hs_put		= ldlm_res_hop_put
 };
 
@@ -572,7 +561,6 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 	.hs_keycpy      = NULL,
 	.hs_object      = ldlm_res_hop_object,
 	.hs_get		= ldlm_res_hop_get_locked,
-	.hs_put_locked  = ldlm_res_hop_put_locked,
 	.hs_put		= ldlm_res_hop_put
 };
 
@@ -1249,37 +1237,6 @@ int ldlm_resource_putref(struct ldlm_resource *res)
 }
 EXPORT_SYMBOL(ldlm_resource_putref);
 
-/* Returns 1 if the resource was freed, 0 if it remains. */
-int ldlm_resource_putref_locked(struct ldlm_resource *res)
-{
-	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-
-	LASSERT_ATOMIC_GT_LT(&res->lr_refcount, 0, LI_POISON);
-	CDEBUG(D_INFO, "putref res: %p count: %d\n",
-	       res, atomic_read(&res->lr_refcount) - 1);
-
-	if (atomic_dec_and_test(&res->lr_refcount)) {
-		struct cfs_hash_bd bd;
-
-		cfs_hash_bd_get(ldlm_res_to_ns(res)->ns_rs_hash,
-				&res->lr_name, &bd);
-		__ldlm_resource_putref_final(&bd, res);
-		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
-		/* NB: ns_rs_hash is created with CFS_HASH_NO_ITEMREF,
-		 * so we should never be here while calling cfs_hash_del,
-		 * cfs_hash_for_each_nolock is the only case we can get
-		 * here, which is safe to release cfs_hash_bd_lock.
-		 */
-		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_free)
-			ns->ns_lvbo->lvbo_free(res);
-		kmem_cache_free(ldlm_resource_slab, res);
-
-		cfs_hash_bd_lock(ns->ns_rs_hash, &bd, 1);
-		return 1;
-	}
-	return 0;
-}
-
 /**
  * Add a lock into a given resource into specified lock list.
  */
-- 
1.8.3.1
