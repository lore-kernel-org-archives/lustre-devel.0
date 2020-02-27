From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:51 -0500
Subject: [lustre-devel] [PATCH 123/622] lustre: ldlm: cleanup LVB handling
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-124-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

For the client side LVB handling is barely used. In the OpenSFS
tree lvbo handling was reworked for LU-5042. Merge those
changes as well as remove all server related code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5042
Lustre-commit: 8739f13233e ("LU-5042 ldlm: delay filling resource's LVB upon replay")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: http://review.whamcloud.com/10845
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 62 ++----------------------------------------
 fs/lustre/ldlm/ldlm_resource.c | 39 ++++----------------------
 2 files changed, 8 insertions(+), 93 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 6ad12a3..1133e20 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -280,16 +280,12 @@ struct ldlm_pool {
  * Currently LVBs are used by:
  *  - OSC-OST code to maintain current object size/times
  *  - layout lock code to return the layout when the layout lock is granted
+ *
+ * To ensure delayed LVB initialization, it is highly recommended to use the set
+ * of ldlm_[res_]lvbo_[init,update,fill]() functions.
  */
 struct ldlm_valblock_ops {
-	int (*lvbo_init)(struct ldlm_resource *res);
-	int (*lvbo_update)(struct ldlm_resource *res, struct ldlm_lock *lock,
-			   struct ptlrpc_request *r,  int increase);
 	int (*lvbo_free)(struct ldlm_resource *res);
-	/* Return size of lvb data appropriate RPC size can be reserved */
-	int (*lvbo_size)(struct ldlm_lock *lock);
-	/* Called to fill in lvb data to RPC buffer @buf */
-	int (*lvbo_fill)(struct ldlm_lock *lock, void *buf, int buflen);
 };
 
 /**
@@ -922,36 +918,6 @@ static inline bool ldlm_has_dom(struct ldlm_lock *lock)
 	return &lock->l_resource->lr_ns_bucket->nsb_at_estimate;
 }
 
-static inline int ldlm_lvbo_init(struct ldlm_resource *res)
-{
-	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-
-	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init)
-		return ns->ns_lvbo->lvbo_init(res);
-
-	return 0;
-}
-
-static inline int ldlm_lvbo_size(struct ldlm_lock *lock)
-{
-	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_size)
-		return ns->ns_lvbo->lvbo_size(lock);
-
-	return 0;
-}
-
-static inline int ldlm_lvbo_fill(struct ldlm_lock *lock, void *buf, int len)
-{
-	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-	if (ns->ns_lvbo)
-		return ns->ns_lvbo->lvbo_fill(lock, buf, len);
-
-	return 0;
-}
-
 struct ldlm_ast_work {
 	struct ldlm_lock       *w_lock;
 	int			w_blocking;
@@ -1111,28 +1077,6 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
 	return lock;
 }
 
-/**
- * Update Lock Value Block Operations (LVBO) on a resource taking into account
- * data from request @r
- */
-static inline int ldlm_lvbo_update(struct ldlm_resource *res,
-				   struct ldlm_lock *lock,
-				   struct ptlrpc_request *req, int increase)
-{
-	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-
-	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_update)
-		return ns->ns_lvbo->lvbo_update(res, lock, req, increase);
-
-	return 0;
-}
-
-static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
-				       struct ptlrpc_request *req, int increase)
-{
-	return ldlm_lvbo_update(res, NULL, req, increase);
-}
-
 int ldlm_error2errno(enum ldlm_error error);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 5d73132..59b17b5 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -1062,11 +1062,10 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 	spin_lock_init(&res->lr_lock);
 	lu_ref_init(&res->lr_reference);
 
-	/* The creator of the resource must unlock the mutex after LVB
-	 * initialization.
+	/* Since LVB init can be delayed now, there is no longer need to
+	 * immediately acquire mutex here.
 	 */
 	mutex_init(&res->lr_lvb_mutex);
-	mutex_lock(&res->lr_lvb_mutex);
 
 	return res;
 }
@@ -1087,7 +1086,6 @@ struct ldlm_resource *
 	struct cfs_hash_bd bd;
 	u64 version;
 	int ns_refcount = 0;
-	int rc;
 
 	LASSERT(!parent);
 	LASSERT(ns->ns_rs_hash);
@@ -1097,7 +1095,7 @@ struct ldlm_resource *
 	hnode = cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
 	if (hnode) {
 		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
-		goto lvbo_init;
+		goto found;
 	}
 
 	version = cfs_hash_bd_version_get(&bd);
@@ -1125,25 +1123,12 @@ struct ldlm_resource *
 		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
 		/* Clean lu_ref for failed resource. */
 		lu_ref_fini(&res->lr_reference);
-		/* We have taken lr_lvb_mutex. Drop it. */
-		mutex_unlock(&res->lr_lvb_mutex);
 		if (res->lr_itree)
 			kmem_cache_free(ldlm_interval_tree_slab,
 					res->lr_itree);
 		kmem_cache_free(ldlm_resource_slab, res);
-lvbo_init:
+found:
 		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-		/* Synchronize with regard to resource creation. */
-		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
-			mutex_lock(&res->lr_lvb_mutex);
-			mutex_unlock(&res->lr_lvb_mutex);
-		}
-
-		if (unlikely(res->lr_lvb_len < 0)) {
-			rc = res->lr_lvb_len;
-			ldlm_resource_putref(res);
-			res = ERR_PTR(rc);
-		}
 		return res;
 	}
 	/* We won! Let's add the resource. */
@@ -1152,22 +1137,8 @@ struct ldlm_resource *
 		ns_refcount = ldlm_namespace_get_return(ns);
 
 	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
-	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
-		rc = ns->ns_lvbo->lvbo_init(res);
-		if (rc < 0) {
-			CERROR("%s: lvbo_init failed for resource %#llx:%#llx: rc = %d\n",
-			       ns->ns_obd->obd_name, name->name[0],
-			       name->name[1], rc);
-			res->lr_lvb_len = rc;
-			mutex_unlock(&res->lr_lvb_mutex);
-			ldlm_resource_putref(res);
-			return ERR_PTR(rc);
-		}
-	}
 
-	/* We create resource with locked lr_lvb_mutex. */
-	mutex_unlock(&res->lr_lvb_mutex);
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CREATE_RESOURCE, 2);
 
 	/* Let's see if we happened to be the very first resource in this
 	 * namespace. If so, and this is a client namespace, we need to move
-- 
1.8.3.1
