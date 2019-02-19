From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 32/37] lustre: portals_handle: rename ops to
 owner
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494664.24125.9533896496992345951.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Now the portals_handle_ops is empty, it is functioning
only to identify the owner of each handle.
So change the name to h_owner, and the type to void*

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_handles.h |   10 +++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    7 +++----
 drivers/staging/lustre/lustre/obdclass/genops.c    |   15 ++++++---------
 .../lustre/lustre/obdclass/lustre_handles.c        |   13 ++++++-------
 4 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 7079982ffd31..9d0f0b61b51a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -45,9 +45,6 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-struct portals_handle_ops {
-};
-
 /* These handles are most easily used by having them appear at the very top of
  * whatever object that you want to make handles for.  ie:
  *
@@ -63,7 +60,7 @@ struct portals_handle_ops {
 struct portals_handle {
 	struct list_head		h_link;
 	u64				h_cookie;
-	const struct portals_handle_ops	*h_ops;
+	void				*h_owner;
 	refcount_t			h_ref;
 
 	/* newly added fields to handle the RCU issue. -jxiong */
@@ -75,10 +72,9 @@ struct portals_handle {
 /* handles.c */
 
 /* Add a handle to the hash table */
-void class_handle_hash(struct portals_handle *,
-		       const struct portals_handle_ops *ops);
+void class_handle_hash(struct portals_handle *, void *owner);
 void class_handle_unhash(struct portals_handle *);
-void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops);
+void *class_handle2object(u64 cookie, void *owner);
 int class_handle_init(void);
 void class_handle_cleanup(void);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 010285b226e6..b22aa640b723 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -356,8 +356,7 @@ void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
 		LDLM_LOCK_RELEASE(lock);
 }
 
-static struct portals_handle_ops lock_handle_ops = {
-};
+static int lock_handle_owner;
 
 /**
  *
@@ -396,7 +395,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
 			     LDLM_NSS_LOCKS);
 	INIT_LIST_HEAD(&lock->l_handle.h_link);
-	class_handle_hash(&lock->l_handle, &lock_handle_ops);
+	class_handle_hash(&lock->l_handle, &lock_handle_owner);
 
 	lock->l_callback_timeout = 0;
 
@@ -496,7 +495,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	LASSERT(handle);
 
-	lock = class_handle2object(handle->cookie, &lock_handle_ops);
+	lock = class_handle2object(handle->cookie, &lock_handle_owner);
 	if (!lock)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 156541ead12e..8ddee93b2a9d 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -674,7 +674,8 @@ int obd_init_caches(void)
 	return -ENOMEM;
 }
 
-static struct portals_handle_ops export_handle_ops;
+static int export_handle_owner;
+
 /* map connection to client */
 struct obd_export *class_conn2export(struct lustre_handle *conn)
 {
@@ -691,7 +692,7 @@ struct obd_export *class_conn2export(struct lustre_handle *conn)
 	}
 
 	CDEBUG(D_INFO, "looking for export cookie %#llx\n", conn->cookie);
-	export = class_handle2object(conn->cookie, &export_handle_ops);
+	export = class_handle2object(conn->cookie, &export_handle_owner);
 	return export;
 }
 EXPORT_SYMBOL(class_conn2export);
@@ -743,9 +744,6 @@ static void class_export_destroy(struct obd_export *exp)
 	kfree_rcu(exp, exp_handle.h_rcu);
 }
 
-static struct portals_handle_ops export_handle_ops = {
-};
-
 struct obd_export *class_export_get(struct obd_export *exp)
 {
 	refcount_inc(&exp->exp_handle.h_ref);
@@ -828,7 +826,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 	INIT_LIST_HEAD(&export->exp_req_replay_queue);
 	INIT_LIST_HEAD(&export->exp_handle.h_link);
 	INIT_LIST_HEAD(&export->exp_hp_rpcs);
-	class_handle_hash(&export->exp_handle, &export_handle_ops);
+	class_handle_hash(&export->exp_handle, &export_handle_owner);
 	spin_lock_init(&export->exp_lock);
 	spin_lock_init(&export->exp_rpc_lock);
 	spin_lock_init(&export->exp_bl_list_lock);
@@ -932,8 +930,7 @@ static void class_import_destroy(struct obd_import *imp)
 	kfree_rcu(imp, imp_handle.h_rcu);
 }
 
-static struct portals_handle_ops import_handle_ops = {
-};
+static int import_handle_owner;
 
 struct obd_import *class_import_get(struct obd_import *import)
 {
@@ -1016,7 +1013,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	atomic_set(&imp->imp_inval_count, 0);
 	INIT_LIST_HEAD(&imp->imp_conn_list);
 	INIT_LIST_HEAD(&imp->imp_handle.h_link);
-	class_handle_hash(&imp->imp_handle, &import_handle_ops);
+	class_handle_hash(&imp->imp_handle, &import_handle_owner);
 	init_imp_at(&imp->imp_at);
 
 	/* the default magic is V2, will be used in connect RPC, and
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index f4599ec5b0f0..30a84ff1e479 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -58,8 +58,7 @@ static struct handle_bucket {
  * Generate a unique 64bit cookie (hash) for a handle and insert it into
  * global (per-node) hash-table.
  */
-void class_handle_hash(struct portals_handle *h,
-		       const struct portals_handle_ops *ops)
+void class_handle_hash(struct portals_handle *h, void *owner)
 {
 	struct handle_bucket *bucket;
 
@@ -85,7 +84,7 @@ void class_handle_hash(struct portals_handle *h,
 	h->h_cookie = handle_base;
 	spin_unlock(&handle_base_lock);
 
-	h->h_ops = ops;
+	h->h_owner = owner;
 	spin_lock_init(&h->h_lock);
 
 	bucket = &handle_hash[h->h_cookie & HANDLE_HASH_MASK];
@@ -132,7 +131,7 @@ void class_handle_unhash(struct portals_handle *h)
 }
 EXPORT_SYMBOL(class_handle_unhash);
 
-void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
+void *class_handle2object(u64 cookie, void *owner)
 {
 	struct handle_bucket *bucket;
 	struct portals_handle *h;
@@ -147,7 +146,7 @@ void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(h, &bucket->head, h_link) {
-		if (h->h_cookie != cookie || h->h_ops != ops)
+		if (h->h_cookie != cookie || h->h_owner != owner)
 			continue;
 
 		spin_lock(&h->h_lock);
@@ -198,8 +197,8 @@ static int cleanup_all_handles(void)
 
 		spin_lock(&handle_hash[i].lock);
 		list_for_each_entry_rcu(h, &handle_hash[i].head, h_link) {
-			CERROR("force clean handle %#llx addr %p ops %p\n",
-			       h->h_cookie, h, h->h_ops);
+			CERROR("force clean handle %#llx addr %p owner %p\n",
+			       h->h_cookie, h, h->h_owner);
 
 			class_handle_unhash_nolock(h);
 			rc++;
