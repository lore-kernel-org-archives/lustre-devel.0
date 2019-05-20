From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:01 -0400
Subject: [lustre-devel] [PATCH v2 19/29] lustre: portals_handle: rename ops
 to owner
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Now that portals_handle_ops contains only a char*,
it is functioning primarily to identify the owner of each handle.
So change the name to h_owner, and the type to const char*.

Note: this h_owner is now quiet different from the similar h_owner
in the server code.  When server code it merged the
"med" pointer should be stored in the "mfd" and validated separately.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/lustre_handles.h  | 12 +++---------
 fs/lustre/ldlm/ldlm_lock.c          |  8 +++-----
 fs/lustre/obdclass/genops.c         | 17 ++++++-----------
 fs/lustre/obdclass/lustre_handles.c | 15 +++++++--------
 4 files changed, 19 insertions(+), 33 deletions(-)

diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index 8fb4285..4bae4d6 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -45,11 +45,6 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-struct portals_handle_ops {
-	/* hop_type is used for some debugging messages */
-	char *hop_type;
-};
-
 /* These handles are most easily used by having them appear at the very top of
  * whatever object that you want to make handles for.  ie:
  *
@@ -65,7 +60,7 @@ struct portals_handle_ops {
 struct portals_handle {
 	struct list_head		h_link;
 	u64				h_cookie;
-	const struct portals_handle_ops	*h_ops;
+	const char			*h_owner;
 	refcount_t			h_ref;
 
 	/* newly added fields to handle the RCU issue. -jxiong */
@@ -77,10 +72,9 @@ struct portals_handle {
 /* handles.c */
 
 /* Add a handle to the hash table */
-void class_handle_hash(struct portals_handle *,
-		       const struct portals_handle_ops *ops);
+void class_handle_hash(struct portals_handle *, const char *owner);
 void class_handle_unhash(struct portals_handle *);
-void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops);
+void *class_handle2object(u64 cookie, const char *owner);
 int class_handle_init(void);
 void class_handle_cleanup(void);
 
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 18f018d..56a2d1d 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -363,9 +363,7 @@ void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
 	}
 }
 
-static struct portals_handle_ops lock_handle_ops = {
-	.hop_type   = "ldlm",
-};
+static const char lock_handle_owner[] = "ldlm";
 
 /**
  *
@@ -405,7 +403,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lprocfs_counter_incr(ldlm_res_to_ns(resource)->ns_stats,
 			     LDLM_NSS_LOCKS);
 	INIT_LIST_HEAD(&lock->l_handle.h_link);
-	class_handle_hash(&lock->l_handle, &lock_handle_ops);
+	class_handle_hash(&lock->l_handle, lock_handle_owner);
 
 	lu_ref_init(&lock->l_reference);
 	lu_ref_add(&lock->l_reference, "hash", lock);
@@ -509,7 +507,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	LASSERT(handle);
 
-	lock = class_handle2object(handle->cookie, &lock_handle_ops);
+	lock = class_handle2object(handle->cookie, lock_handle_owner);
 	if (!lock)
 		return NULL;
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 1d1d457..257609b 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -677,7 +677,8 @@ int obd_init_caches(void)
 	return -ENOMEM;
 }
 
-static struct portals_handle_ops export_handle_ops;
+static const char export_handle_owner[] = "export";
+
 /* map connection to client */
 struct obd_export *class_conn2export(struct lustre_handle *conn)
 {
@@ -694,7 +695,7 @@ struct obd_export *class_conn2export(struct lustre_handle *conn)
 	}
 
 	CDEBUG(D_INFO, "looking for export cookie %#llx\n", conn->cookie);
-	export = class_handle2object(conn->cookie, &export_handle_ops);
+	export = class_handle2object(conn->cookie, export_handle_owner);
 	return export;
 }
 EXPORT_SYMBOL(class_conn2export);
@@ -746,10 +747,6 @@ static void class_export_destroy(struct obd_export *exp)
 	kfree_rcu(exp, exp_handle.h_rcu);
 }
 
-static struct portals_handle_ops export_handle_ops = {
-	.hop_type	= "export",
-};
-
 struct obd_export *class_export_get(struct obd_export *exp)
 {
 	refcount_inc(&exp->exp_handle.h_ref);
@@ -832,7 +829,7 @@ static struct obd_export *__class_new_export(struct obd_device *obd,
 	INIT_LIST_HEAD(&export->exp_req_replay_queue);
 	INIT_LIST_HEAD(&export->exp_handle.h_link);
 	INIT_LIST_HEAD(&export->exp_hp_rpcs);
-	class_handle_hash(&export->exp_handle, &export_handle_ops);
+	class_handle_hash(&export->exp_handle, export_handle_owner);
 	spin_lock_init(&export->exp_lock);
 	spin_lock_init(&export->exp_rpc_lock);
 	spin_lock_init(&export->exp_bl_list_lock);
@@ -936,9 +933,7 @@ static void class_import_destroy(struct obd_import *imp)
 	kfree_rcu(imp, imp_handle.h_rcu);
 }
 
-static struct portals_handle_ops import_handle_ops = {
-	.hop_type	= "import",
-};
+static const char import_handle_owner[] = "import";
 
 struct obd_import *class_import_get(struct obd_import *import)
 {
@@ -1021,7 +1016,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	atomic_set(&imp->imp_inval_count, 0);
 	INIT_LIST_HEAD(&imp->imp_conn_list);
 	INIT_LIST_HEAD(&imp->imp_handle.h_link);
-	class_handle_hash(&imp->imp_handle, &import_handle_ops);
+	class_handle_hash(&imp->imp_handle, import_handle_owner);
 	init_imp_at(&imp->imp_at);
 
 	/* the default magic is V2, will be used in connect RPC, and
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 8aece57..00d8a89 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -58,8 +58,7 @@
  * Generate a unique 64bit cookie (hash) for a handle and insert it into
  * global (per-node) hash-table.
  */
-void class_handle_hash(struct portals_handle *h,
-		       const struct portals_handle_ops *ops)
+void class_handle_hash(struct portals_handle *h, const char *owner)
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
+void *class_handle2object(u64 cookie, const char *owner)
 {
 	struct handle_bucket *bucket;
 	struct portals_handle *h;
@@ -147,14 +146,14 @@ void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(h, &bucket->head, h_link) {
-		if (h->h_cookie != cookie || h->h_ops != ops)
+		if (h->h_cookie != cookie || h->h_owner != owner)
 			continue;
 
 		spin_lock(&h->h_lock);
 		if (likely(h->h_in != 0)) {
 			refcount_inc(&h->h_ref);
 			CDEBUG(D_INFO, "GET %s %p refcount=%d\n",
-			       h->h_ops->hop_type, h,
+			       h->h_owner, h,
 			       refcount_read(&h->h_ref));
 			retval = h;
 		}
@@ -201,8 +200,8 @@ static int cleanup_all_handles(void)
 
 		spin_lock(&handle_hash[i].lock);
 		list_for_each_entry_rcu(h, &handle_hash[i].head, h_link) {
-			CERROR("force clean handle %#llx addr %p ops %p\n",
-			       h->h_cookie, h, h->h_ops);
+			CERROR("force clean handle %#llx addr %p owner %p\n",
+			       h->h_cookie, h, h->h_owner);
 
 			class_handle_unhash_nolock(h);
 			rc++;
-- 
1.8.3.1
