From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:34 -0400
Subject: [lustre-devel] [PATCH 17/18] lustre: ldlm: reduce mem footprint of
 ldlm_resource
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

 - Allocating lr_itree only for LDLM_EXTENT resource, reduced
   120 bytes;
 - Moving fields around to eliminate holes, eliminated 3 holes,
   reduced 4 bytes;
 - Remove unused lr_contention_time, reduced 8 bytes;

   Reduced 132 bytes in total.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-6775
Reviewed-on: http://review.whamcloud.com/15485
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 24 ++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 20 +++++++++++---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 32 ++++++++++++++++------
 4 files changed, 54 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 4f196c2..2a05ab8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -819,6 +819,9 @@ struct ldlm_resource {
 	 */
 	struct hlist_node	lr_hash;
 
+	/** Reference count for this resource */
+	atomic_t		lr_refcount;
+
 	/** Spinlock to protect locks under this resource. */
 	spinlock_t		lr_lock;
 
@@ -835,32 +838,31 @@ struct ldlm_resource {
 	struct list_head		lr_waiting;
 	/** @} */
 
-	/** Type of locks this resource can hold. Only one type per resource. */
-	enum ldlm_type		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
-
 	/** Resource name */
 	struct ldlm_res_id	lr_name;
-	/** Reference count for this resource */
-	atomic_t		lr_refcount;
 
 	/**
 	 * Interval trees (only for extent locks) for all modes of this resource
 	 */
-	struct ldlm_interval_tree lr_itree[LCK_MODE_NUM];
+	struct ldlm_interval_tree *lr_itree;
+
+	/** Type of locks this resource can hold. Only one type per resource. */
+	enum ldlm_type		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
 
 	/**
 	 * Server-side-only lock value block elements.
 	 * To serialize lvbo_init.
 	 */
-	struct mutex		lr_lvb_mutex;
 	int			lr_lvb_len;
+	struct mutex		lr_lvb_mutex;
+
+	/**
+	 * Associated inode, used only on client side.
+	 */
+	struct inode		*lr_lvb_inode;
 
-	/** When the resource was considered as contended. */
-	unsigned long		lr_contention_time;
 	/** List of references to this resource. For debugging. */
 	struct lu_ref		lr_reference;
-
-	struct inode		*lr_lvb_inode;
 };
 
 static inline bool ldlm_has_layout(struct ldlm_lock *lock)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 60a15b9..1d7c727 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -165,6 +165,7 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 
 /* ldlm_lockd.c & ldlm_lock.c */
 extern struct kmem_cache *ldlm_lock_slab;
+extern struct kmem_cache *ldlm_interval_tree_slab;
 
 /* ldlm_extent.c */
 void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index f410ef6..5b125fdc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -1129,15 +1129,26 @@ int ldlm_init(void)
 					   sizeof(struct ldlm_lock), 0,
 					   SLAB_HWCACHE_ALIGN |
 					   SLAB_TYPESAFE_BY_RCU, NULL);
-	if (!ldlm_lock_slab) {
-		kmem_cache_destroy(ldlm_resource_slab);
-		return -ENOMEM;
-	}
+	if (!ldlm_lock_slab)
+		goto out_resource;
+
+	ldlm_interval_tree_slab = kmem_cache_create("interval_tree",
+						    sizeof(struct ldlm_interval_tree) * LCK_MODE_NUM,
+						    0, SLAB_HWCACHE_ALIGN,
+						    NULL);
+	if (!ldlm_interval_tree_slab)
+		goto out_lock;
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	class_export_dump_hook = ldlm_dump_export_locks;
 #endif
 	return 0;
+
+out_lock:
+	kmem_cache_destroy(ldlm_lock_slab);
+out_resource:
+	kmem_cache_destroy(ldlm_resource_slab);
+	return -ENOMEM;
 }
 
 void ldlm_exit(void)
@@ -1151,4 +1162,5 @@ void ldlm_exit(void)
 	 */
 	synchronize_rcu();
 	kmem_cache_destroy(ldlm_lock_slab);
+	kmem_cache_destroy(ldlm_interval_tree_slab);
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 3946d62..f06cbd8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -44,6 +44,7 @@
 #include <linux/libcfs/libcfs_hash.h>
 
 struct kmem_cache *ldlm_resource_slab, *ldlm_lock_slab;
+struct kmem_cache *ldlm_interval_tree_slab;
 
 int ldlm_srv_namespace_nr;
 int ldlm_cli_namespace_nr;
@@ -1001,10 +1002,9 @@ struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client)
 }
 
 /** Create and initialize new resource. */
-static struct ldlm_resource *ldlm_resource_new(void)
+static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 {
 	struct ldlm_resource *res;
-	int idx;
 
 	res = kmem_cache_zalloc(ldlm_resource_slab, GFP_NOFS);
 	if (!res)
@@ -1013,11 +1013,22 @@ static struct ldlm_resource *ldlm_resource_new(void)
 	INIT_LIST_HEAD(&res->lr_granted);
 	INIT_LIST_HEAD(&res->lr_waiting);
 
-	/* Initialize interval trees for each lock mode. */
-	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
-		res->lr_itree[idx].lit_size = 0;
-		res->lr_itree[idx].lit_mode = 1 << idx;
-		res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
+	if (ldlm_type == LDLM_EXTENT) {
+		int idx;
+
+		res->lr_itree = kmem_cache_zalloc(ldlm_interval_tree_slab,
+						  GFP_NOFS);
+		if (!res->lr_itree) {
+			kmem_cache_free(ldlm_resource_slab, res);
+			return NULL;
+		}
+
+		/* Initialize interval trees for each lock mode. */
+		for (idx = 0; idx < LCK_MODE_NUM; idx++) {
+			res->lr_itree[idx].lit_size = 0;
+			res->lr_itree[idx].lit_mode = 1 << idx;
+			res->lr_itree[idx].lit_root = RB_ROOT_CACHED;
+		}
 	}
 
 	atomic_set(&res->lr_refcount, 1);
@@ -1070,7 +1081,7 @@ struct ldlm_resource *
 
 	LASSERTF(type >= LDLM_MIN_TYPE && type < LDLM_MAX_TYPE,
 		 "type: %d\n", type);
-	res = ldlm_resource_new();
+	res = ldlm_resource_new(type);
 	if (!res)
 		return ERR_PTR(-ENOMEM);
 
@@ -1089,6 +1100,9 @@ struct ldlm_resource *
 		lu_ref_fini(&res->lr_reference);
 		/* We have taken lr_lvb_mutex. Drop it. */
 		mutex_unlock(&res->lr_lvb_mutex);
+		if (res->lr_itree)
+			kmem_cache_free(ldlm_interval_tree_slab,
+					res->lr_itree);
 		kmem_cache_free(ldlm_resource_slab, res);
 lvbo_init:
 		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
@@ -1167,6 +1181,8 @@ static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 		ns->ns_lvbo->lvbo_free(res);
 	if (cfs_hash_bd_count_get(bd) == 0)
 		ldlm_namespace_put(ns);
+	if (res->lr_itree)
+		kmem_cache_free(ldlm_interval_tree_slab, res->lr_itree);
 	kmem_cache_free(ldlm_resource_slab, res);
 }
 
-- 
1.8.3.1
