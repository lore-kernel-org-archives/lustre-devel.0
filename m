From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:39 -0400
Subject: [lustre-devel] [PATCH 29/32] staging/lustre/ldlm: Remove unused
	exported symbols.
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-30-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This rather large patch prunes all unused EXPORT_SYMBOLS and
marks functions only used locally as static lustre ldlm module.

The only two remaining nonstatic functions that should be static
now are:
ldlm_cancel_lru_local
ldlm_resource_putref_locked

But some bigger code shuffling around is needed to achieve that, so
it's left for a future patch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 26 -------
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   | 22 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 21 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 30 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 43 +++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 28 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 82 +++++++++++-----------
 9 files changed, 111 insertions(+), 151 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 3cca07e..dfc49e1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -60,9 +60,6 @@
 struct obd_ops;
 struct obd_device;
 
-extern struct kset *ldlm_ns_kset;
-extern struct kset *ldlm_svc_kset;
-
 #define OBD_LDLM_DEVICENAME  "ldlm"
 
 #define LDLM_DEFAULT_LRU_SIZE (100 * num_online_cpus())
@@ -561,9 +558,6 @@ typedef union {
 	struct ldlm_inodebits l_inodebits;
 } ldlm_policy_data_t;
 
-void ldlm_convert_policy_to_wire(ldlm_type_t type,
-				 const ldlm_policy_data_t *lpolicy,
-				 ldlm_wire_policy_data_t *wpolicy);
 void ldlm_convert_policy_to_local(struct obd_export *exp, ldlm_type_t type,
 				  const ldlm_wire_policy_data_t *wpolicy,
 				  ldlm_policy_data_t *lpolicy);
@@ -980,7 +974,6 @@ struct ldlm_enqueue_info {
 extern struct obd_ops ldlm_obd_ops;
 
 extern char *ldlm_lockname[];
-extern char *ldlm_typename[];
 char *ldlm_it2str(int it);
 
 /**
@@ -1051,10 +1044,6 @@ typedef int (*ldlm_res_iterator_t)(struct ldlm_resource *, void *);
  * LDLM provides for a way to iterate through every lock on a resource or
  * namespace or every resource in a namespace.
  * @{ */
-int ldlm_resource_foreach(struct ldlm_resource *res, ldlm_iterator_t iter,
-			  void *closure);
-void ldlm_namespace_foreach(struct ldlm_namespace *ns, ldlm_iterator_t iter,
-			    void *closure);
 int ldlm_resource_iterate(struct ldlm_namespace *, const struct ldlm_res_id *,
 			  ldlm_iterator_t iter, void *data);
 /** @} ldlm_iterator */
@@ -1172,7 +1161,6 @@ do {					    \
 
 struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
 void ldlm_lock_put(struct ldlm_lock *lock);
-void ldlm_lock_destroy(struct ldlm_lock *lock);
 void ldlm_lock2desc(struct ldlm_lock *lock, struct ldlm_lock_desc *desc);
 void ldlm_lock_addref(struct lustre_handle *lockh, __u32 mode);
 int  ldlm_lock_addref_try(struct lustre_handle *lockh, __u32 mode);
@@ -1197,8 +1185,6 @@ ldlm_namespace_new(struct obd_device *obd, char *name,
 		   ldlm_side_t client, ldlm_appetite_t apt,
 		   ldlm_ns_type_t ns_type);
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
-void ldlm_namespace_register(struct ldlm_namespace *ns, ldlm_side_t client);
-void ldlm_namespace_unregister(struct ldlm_namespace *ns, ldlm_side_t client);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
 void ldlm_namespace_put(struct ldlm_namespace *ns);
 int ldlm_debugfs_setup(void);
@@ -1209,7 +1195,6 @@ struct ldlm_resource *ldlm_resource_get(struct ldlm_namespace *ns,
 					struct ldlm_resource *parent,
 					const struct ldlm_res_id *,
 					ldlm_type_t type, int create);
-struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res);
 int ldlm_resource_putref(struct ldlm_resource *res);
 void ldlm_resource_add_lock(struct ldlm_resource *res,
 			    struct list_head *head,
@@ -1231,7 +1216,6 @@ int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
 } while (0)
 
 /* ldlm_request.c */
-int ldlm_expired_completion_wait(void *data);
 /** \defgroup ldlm_local_ast Default AST handlers for local locks
  * These AST handlers are typically used for server-side local locks and are
  * also used by client-side lock handlers to perform minimum level base
@@ -1275,8 +1259,6 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 				    ldlm_mode_t mode,
 				    ldlm_cancel_flags_t flags,
 				    void *opaque);
-int ldlm_cli_cancel_req(struct obd_export *exp, struct list_head *head,
-			int count, ldlm_cancel_flags_t flags);
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       ldlm_policy_data_t *policy,
@@ -1351,15 +1333,7 @@ void ldlm_pools_fini(void);
 
 int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 		   int idx, ldlm_side_t client);
-int ldlm_pool_shrink(struct ldlm_pool *pl, int nr,
-		     gfp_t gfp_mask);
 void ldlm_pool_fini(struct ldlm_pool *pl);
-int ldlm_pool_recalc(struct ldlm_pool *pl);
-__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
-__u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
-__u32 ldlm_pool_get_limit(struct ldlm_pool *pl);
-void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
-void ldlm_pool_set_limit(struct ldlm_pool *pl, __u32 limit);
 void ldlm_pool_add(struct ldlm_pool *pl, struct ldlm_lock *lock);
 void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock);
 /** @} */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index fd9b059..05bc4f3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -97,6 +97,17 @@ __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 EXPORT_SYMBOL(ldlm_extent_shift_kms);
 
 struct kmem_cache *ldlm_interval_slab;
+
+/* interval tree, for LDLM_EXTENT. */
+static void ldlm_interval_attach(struct ldlm_interval *n, struct ldlm_lock *l)
+{
+	LASSERT(!l->l_tree_node);
+	LASSERT(l->l_resource->lr_type == LDLM_EXTENT);
+
+	list_add_tail(&l->l_sl_policy, &n->li_group);
+	l->l_tree_node = n;
+}
+
 struct ldlm_interval *ldlm_interval_alloc(struct ldlm_lock *lock)
 {
 	struct ldlm_interval *node;
@@ -120,17 +131,6 @@ void ldlm_interval_free(struct ldlm_interval *node)
 	}
 }
 
-/* interval tree, for LDLM_EXTENT. */
-void ldlm_interval_attach(struct ldlm_interval *n,
-			  struct ldlm_lock *l)
-{
-	LASSERT(l->l_tree_node == NULL);
-	LASSERT(l->l_resource->lr_type == LDLM_EXTENT);
-
-	list_add_tail(&l->l_sl_policy, &n->li_group);
-	l->l_tree_node = n;
-}
-
 struct ldlm_interval *ldlm_interval_detach(struct ldlm_lock *l)
 {
 	struct ldlm_interval *n = l->l_tree_node;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 7241c34..57b4edb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -239,9 +239,9 @@ static void ldlm_flock_cancel_on_deadlock(struct ldlm_lock *lock,
  *   - blocking ASTs have not been sent yet, so list of conflicting locks
  *     would be collected and ASTs sent.
  */
-int
-ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags, int first_enq,
-			ldlm_error_t *err, struct list_head *work_list)
+static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
+				   int first_enq, ldlm_error_t *err,
+				   struct list_head *work_list)
 {
 	struct ldlm_resource *res = req->l_resource;
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 56805d0..e63a1c9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -109,10 +109,9 @@ enum {
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 		    ldlm_cancel_flags_t sync, int flags);
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
-			  struct list_head *cancels, int count, int max,
-			  ldlm_cancel_flags_t cancel_flags, int flags);
+			 struct list_head *cancels, int count, int max,
+			 ldlm_cancel_flags_t cancel_flags, int flags);
 extern int ldlm_enqueue_min;
-int ldlm_get_enq_timeout(struct ldlm_lock *lock);
 
 /* ldlm_resource.c */
 int ldlm_resource_putref_locked(struct ldlm_resource *res);
@@ -154,12 +153,8 @@ void ldlm_add_ast_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
 			    struct list_head *work_list);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
-int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq);
 int ldlm_lock_remove_from_lru(struct ldlm_lock *lock);
 int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock);
-void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock);
-void ldlm_lock_add_to_lru(struct ldlm_lock *lock);
-void ldlm_lock_touch_in_lru(struct ldlm_lock *lock);
 void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
 
 /* ldlm_lockd.c */
@@ -174,6 +169,7 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
 
 extern struct kmem_cache *ldlm_resource_slab;
+extern struct kset *ldlm_ns_kset;
 
 /* ldlm_lockd.c & ldlm_lock.c */
 extern struct kmem_cache *ldlm_lock_slab;
@@ -182,11 +178,6 @@ extern struct kmem_cache *ldlm_lock_slab;
 void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
 void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
 
-/* ldlm_flock.c */
-int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
-			    int first_enq, ldlm_error_t *err,
-			    struct list_head *work_list);
-
 /* l_lock.c */
 void l_check_ns_lock(struct ldlm_namespace *ns);
 void l_check_no_ns_lock(struct ldlm_namespace *ns);
@@ -201,9 +192,13 @@ struct ldlm_state {
 	struct ldlm_bl_pool *ldlm_bl_pool;
 };
 
+/* ldlm_pool.c */
+__u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
+void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
+__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
+
 /* interval tree, for LDLM_EXTENT. */
 extern struct kmem_cache *ldlm_interval_slab; /* slab cache for ldlm_interval */
-void ldlm_interval_attach(struct ldlm_interval *n, struct ldlm_lock *l);
 struct ldlm_interval *ldlm_interval_detach(struct ldlm_lock *l);
 struct ldlm_interval *ldlm_interval_alloc(struct ldlm_lock *lock);
 void ldlm_interval_free(struct ldlm_interval *node);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 827e5df..0ba1ac3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -60,13 +60,12 @@ char *ldlm_lockname[] = {
 };
 EXPORT_SYMBOL(ldlm_lockname);
 
-char *ldlm_typename[] = {
+static char *ldlm_typename[] = {
 	[LDLM_PLAIN]	= "PLN",
 	[LDLM_EXTENT]	= "EXT",
 	[LDLM_FLOCK]	= "FLK",
 	[LDLM_IBITS]	= "IBT",
 };
-EXPORT_SYMBOL(ldlm_typename);
 
 static ldlm_policy_wire_to_local_t ldlm_policy_wire18_to_local[] = {
 	[LDLM_PLAIN - LDLM_MIN_TYPE]	= ldlm_plain_policy_wire_to_local,
@@ -92,9 +91,9 @@ static ldlm_policy_local_to_wire_t ldlm_policy_local_to_wire[] = {
 /**
  * Converts lock policy from local format to on the wire lock_desc format
  */
-void ldlm_convert_policy_to_wire(ldlm_type_t type,
-				 const ldlm_policy_data_t *lpolicy,
-				 ldlm_wire_policy_data_t *wpolicy)
+static void ldlm_convert_policy_to_wire(ldlm_type_t type,
+					const ldlm_policy_data_t *lpolicy,
+					ldlm_wire_policy_data_t *wpolicy)
 {
 	ldlm_policy_local_to_wire_t convert;
 
@@ -246,7 +245,7 @@ int ldlm_lock_remove_from_lru(struct ldlm_lock *lock)
 /**
  * Adds LDLM lock \a lock to namespace LRU. Assumes LRU is already locked.
  */
-void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
+static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
@@ -264,7 +263,7 @@ void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
  * Adds LDLM lock \a lock to namespace LRU. Obtains necessary LRU locks
  * first.
  */
-void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
+static void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
@@ -277,7 +276,7 @@ void ldlm_lock_add_to_lru(struct ldlm_lock *lock)
  * Moves LDLM lock \a lock that is already in namespace LRU to the tail of
  * the LRU. Performs necessary LRU locking
  */
-void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
+static void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
@@ -308,7 +307,7 @@ void ldlm_lock_touch_in_lru(struct ldlm_lock *lock)
  * ldlm_lock_destroy, you can never drop your final references on this lock.
  * Because it's not in the hash table anymore.  -phil
  */
-int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
+static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 {
 	if (lock->l_readers || lock->l_writers) {
 		LDLM_ERROR(lock, "lock still has references");
@@ -355,7 +354,7 @@ int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 /**
  * Destroys a LDLM lock \a lock. Performs necessary locking first.
  */
-void ldlm_lock_destroy(struct ldlm_lock *lock)
+static void ldlm_lock_destroy(struct ldlm_lock *lock)
 {
 	int first;
 
@@ -397,7 +396,7 @@ static void lock_handle_free(void *lock, int size)
 	OBD_SLAB_FREE(lock, ldlm_lock_slab, size);
 }
 
-struct portals_handle_ops lock_handle_ops = {
+static struct portals_handle_ops lock_handle_ops = {
 	.hop_addref = lock_handle_addref,
 	.hop_free   = lock_handle_free,
 };
@@ -606,8 +605,8 @@ EXPORT_SYMBOL(ldlm_lock2desc);
  *
  * Only add if we have not sent a blocking AST to the lock yet.
  */
-void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
-			   struct list_head *work_list)
+static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
+				  struct list_head *work_list)
 {
 	if ((lock->l_flags & LDLM_FL_AST_SENT) == 0) {
 		LDLM_DEBUG(lock, "lock incompatible; sending blocking AST.");
@@ -627,7 +626,8 @@ void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
 /**
  * Add a lock to list of just granted locks to send completion AST to.
  */
-void ldlm_add_cp_work_item(struct ldlm_lock *lock, struct list_head *work_list)
+static void ldlm_add_cp_work_item(struct ldlm_lock *lock,
+				  struct list_head *work_list)
 {
 	if ((lock->l_flags & LDLM_FL_CP_REQD) == 0) {
 		lock->l_flags |= LDLM_FL_CP_REQD;
@@ -1673,7 +1673,7 @@ ldlm_work_revoke_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 /**
  * Process a call to glimpse AST callback for a lock in ast_work list
  */
-int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
+static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 {
 	struct ldlm_cb_set_arg		*arg = opaq;
 	struct ldlm_glimpse_work	*gl_work;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 045e3c6..152bdaa 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -58,9 +58,9 @@ MODULE_PARM_DESC(ldlm_cpts, "CPU partitions ldlm threads should run on");
 static struct mutex	ldlm_ref_mutex;
 static int ldlm_refcount;
 
-struct kobject *ldlm_kobj;
+static struct kobject *ldlm_kobj;
 struct kset *ldlm_ns_kset;
-struct kset *ldlm_svc_kset;
+static struct kset *ldlm_svc_kset;
 
 struct ldlm_cb_async_args {
 	struct ldlm_cb_set_arg *ca_set_arg;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 78d1baf..a4ee591 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -214,6 +214,22 @@ static inline int ldlm_pool_t2gsp(unsigned int t)
 }
 
 /**
+ * Returns current \a pl limit.
+ */
+static __u32 ldlm_pool_get_limit(struct ldlm_pool *pl)
+{
+	return atomic_read(&pl->pl_limit);
+}
+
+/**
+ * Sets passed \a limit to \a pl.
+ */
+static void ldlm_pool_set_limit(struct ldlm_pool *pl, __u32 limit)
+{
+	atomic_set(&pl->pl_limit, limit);
+}
+
+/**
  * Recalculates next stats on passed \a pl.
  *
  * \pre ->pl_lock is locked.
@@ -358,7 +374,7 @@ static const struct ldlm_pool_ops ldlm_cli_pool_ops = {
  * Pool recalc wrapper. Will call either client or server pool recalc callback
  * depending what pool \a pl is used.
  */
-int ldlm_pool_recalc(struct ldlm_pool *pl)
+static int ldlm_pool_recalc(struct ldlm_pool *pl)
 {
 	u32 recalc_interval_sec;
 	int count;
@@ -407,8 +423,7 @@ int ldlm_pool_recalc(struct ldlm_pool *pl)
  * depending what pool pl is used. When nr == 0, just return the number of
  * freeable locks. Otherwise, return the number of canceled locks.
  */
-int ldlm_pool_shrink(struct ldlm_pool *pl, int nr,
-		     gfp_t gfp_mask)
+static int ldlm_pool_shrink(struct ldlm_pool *pl, int nr, gfp_t gfp_mask)
 {
 	int cancel = 0;
 
@@ -427,7 +442,6 @@ int ldlm_pool_shrink(struct ldlm_pool *pl, int nr,
 	}
 	return cancel;
 }
-EXPORT_SYMBOL(ldlm_pool_shrink);
 
 static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 {
@@ -763,7 +777,6 @@ __u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
 	spin_unlock(&pl->pl_lock);
 	return slv;
 }
-EXPORT_SYMBOL(ldlm_pool_get_slv);
 
 /**
  * Sets passed \a clv to \a pl.
@@ -776,25 +789,6 @@ void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv)
 	pl->pl_client_lock_volume = clv;
 	spin_unlock(&pl->pl_lock);
 }
-EXPORT_SYMBOL(ldlm_pool_set_clv);
-
-/**
- * Returns current \a pl limit.
- */
-__u32 ldlm_pool_get_limit(struct ldlm_pool *pl)
-{
-	return atomic_read(&pl->pl_limit);
-}
-EXPORT_SYMBOL(ldlm_pool_get_limit);
-
-/**
- * Sets passed \a limit to \a pl.
- */
-void ldlm_pool_set_limit(struct ldlm_pool *pl, __u32 limit)
-{
-	atomic_set(&pl->pl_limit, limit);
-}
-EXPORT_SYMBOL(ldlm_pool_set_limit);
 
 /**
  * Returns current LVF from \a pl.
@@ -803,7 +797,6 @@ __u32 ldlm_pool_get_lvf(struct ldlm_pool *pl)
 {
 	return atomic_read(&pl->pl_lock_volume_factor);
 }
-EXPORT_SYMBOL(ldlm_pool_get_lvf);
 
 static int ldlm_pool_granted(struct ldlm_pool *pl)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 04f4144..250cc37 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -87,7 +87,7 @@ struct ldlm_async_args {
 	struct lustre_handle lock_handle;
 };
 
-int ldlm_expired_completion_wait(void *data)
+static int ldlm_expired_completion_wait(void *data)
 {
 	struct lock_wait_data *lwd = data;
 	struct ldlm_lock *lock = lwd->lwd_lock;
@@ -126,11 +126,10 @@ int ldlm_expired_completion_wait(void *data)
 
 	return 0;
 }
-EXPORT_SYMBOL(ldlm_expired_completion_wait);
 
 /* We use the same basis for both server side and client side functions
    from a single node. */
-int ldlm_get_enq_timeout(struct ldlm_lock *lock)
+static int ldlm_get_enq_timeout(struct ldlm_lock *lock)
 {
 	int timeout = at_get(ldlm_lock_to_ns_at(lock));
 
@@ -142,7 +141,6 @@ int ldlm_get_enq_timeout(struct ldlm_lock *lock)
 	timeout = min_t(int, at_max, timeout + (timeout >> 1)); /* 150% */
 	return max(timeout, ldlm_enqueue_min);
 }
-EXPORT_SYMBOL(ldlm_get_enq_timeout);
 
 /**
  * Helper function for ldlm_completion_ast(), updating timings when lock is
@@ -861,8 +859,9 @@ static void ldlm_cancel_pack(struct ptlrpc_request *req,
 /**
  * Prepare and send a batched cancel RPC. It will include \a count lock
  * handles of locks given in \a cancels list. */
-int ldlm_cli_cancel_req(struct obd_export *exp, struct list_head *cancels,
-			int count, ldlm_cancel_flags_t flags)
+static int ldlm_cli_cancel_req(struct obd_export *exp,
+			       struct list_head *cancels,
+			       int count, ldlm_cancel_flags_t flags)
 {
 	struct ptlrpc_request *req = NULL;
 	struct obd_import *imp;
@@ -944,7 +943,6 @@ int ldlm_cli_cancel_req(struct obd_export *exp, struct list_head *cancels,
 out:
 	return sent ? sent : rc;
 }
-EXPORT_SYMBOL(ldlm_cli_cancel_req);
 
 static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
 {
@@ -1425,9 +1423,9 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	return added;
 }
 
-int ldlm_cancel_lru_local(struct ldlm_namespace *ns, struct list_head *cancels,
-			  int count, int max, ldlm_cancel_flags_t cancel_flags,
-			  int flags)
+int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
+			  struct list_head *cancels, int count, int max,
+			  ldlm_cancel_flags_t cancel_flags, int flags)
 {
 	int added;
 
@@ -1664,8 +1662,8 @@ EXPORT_SYMBOL(ldlm_cli_cancel_unused);
 
 /* Lock iterators. */
 
-int ldlm_resource_foreach(struct ldlm_resource *res, ldlm_iterator_t iter,
-			  void *closure)
+static int ldlm_resource_foreach(struct ldlm_resource *res,
+				 ldlm_iterator_t iter, void *closure)
 {
 	struct list_head *tmp, *next;
 	struct ldlm_lock *lock;
@@ -1696,7 +1694,6 @@ int ldlm_resource_foreach(struct ldlm_resource *res, ldlm_iterator_t iter,
 	unlock_res(res);
 	return rc;
 }
-EXPORT_SYMBOL(ldlm_resource_foreach);
 
 struct iter_helper_data {
 	ldlm_iterator_t iter;
@@ -1720,8 +1717,8 @@ static int ldlm_res_iter_helper(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 	       LDLM_ITER_STOP;
 }
 
-void ldlm_namespace_foreach(struct ldlm_namespace *ns,
-			    ldlm_iterator_t iter, void *closure)
+static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
+				   ldlm_iterator_t iter, void *closure)
 
 {
 	struct iter_helper_data helper = {
@@ -1733,7 +1730,6 @@ void ldlm_namespace_foreach(struct ldlm_namespace *ns,
 				 ldlm_res_iter_helper, &helper);
 
 }
-EXPORT_SYMBOL(ldlm_namespace_foreach);
 
 /* non-blocking function to manipulate a lock whose cb_data is being put away.
  * return  0:  find no resource
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 402fe60..de1b443 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -67,7 +67,7 @@ struct dentry *ldlm_svc_debugfs_dir;
 
 /* during debug dump certain amount of granted locks for one resource to avoid
  * DDOS. */
-unsigned int ldlm_dump_granted_max = 256;
+static unsigned int ldlm_dump_granted_max = 256;
 
 static ssize_t
 lprocfs_wr_dump_ns(struct file *file, const char __user *buffer,
@@ -383,13 +383,13 @@ static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
 		lprocfs_free_stats(&ns->ns_stats);
 }
 
-void ldlm_namespace_sysfs_unregister(struct ldlm_namespace *ns)
+static void ldlm_namespace_sysfs_unregister(struct ldlm_namespace *ns)
 {
 	kobject_put(&ns->ns_kobj);
 	wait_for_completion(&ns->ns_kobj_unregister);
 }
 
-int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
+static int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
 {
 	int err;
 
@@ -428,6 +428,16 @@ static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
 }
 #undef MAX_STRING_SIZE
 
+static struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
+{
+	LASSERT(res);
+	LASSERT(res != LP_POISON);
+	atomic_inc(&res->lr_refcount);
+	CDEBUG(D_INFO, "getref res: %p count: %d\n", res,
+	       atomic_read(&res->lr_refcount));
+	return res;
+}
+
 static unsigned ldlm_res_hop_hash(struct cfs_hash *hs,
 				  const void *key, unsigned mask)
 {
@@ -519,7 +529,7 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 	ldlm_resource_putref(res);
 }
 
-cfs_hash_ops_t ldlm_ns_hash_ops = {
+static cfs_hash_ops_t ldlm_ns_hash_ops = {
 	.hs_hash	= ldlm_res_hop_hash,
 	.hs_key	 = ldlm_res_hop_key,
 	.hs_keycmp      = ldlm_res_hop_keycmp,
@@ -530,7 +540,7 @@ cfs_hash_ops_t ldlm_ns_hash_ops = {
 	.hs_put	 = ldlm_res_hop_put
 };
 
-cfs_hash_ops_t ldlm_ns_fid_hash_ops = {
+static cfs_hash_ops_t ldlm_ns_fid_hash_ops = {
 	.hs_hash	= ldlm_res_hop_fid_hash,
 	.hs_key	 = ldlm_res_hop_key,
 	.hs_keycmp      = ldlm_res_hop_keycmp,
@@ -551,7 +561,7 @@ struct ldlm_ns_hash_def {
 	cfs_hash_ops_t *nsd_hops;
 };
 
-struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
+static struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
 	{
 		.nsd_type       = LDLM_NS_TYPE_MDC,
 		.nsd_bkt_bits   = 11,
@@ -593,6 +603,17 @@ struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
 	},
 };
 
+/** Register \a ns in the list of namespaces */
+static void ldlm_namespace_register(struct ldlm_namespace *ns,
+				    ldlm_side_t client)
+{
+	mutex_lock(ldlm_namespace_lock(client));
+	LASSERT(list_empty(&ns->ns_list_chain));
+	list_add(&ns->ns_list_chain, ldlm_namespace_inactive_list(client));
+	ldlm_namespace_nr_inc(client);
+	mutex_unlock(ldlm_namespace_lock(client));
+}
+
 /**
  * Create and initialize new empty namespace.
  */
@@ -912,6 +933,20 @@ void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 	}
 }
 
+/** Unregister \a ns from the list of namespaces. */
+static void ldlm_namespace_unregister(struct ldlm_namespace *ns,
+				      ldlm_side_t client)
+{
+	mutex_lock(ldlm_namespace_lock(client));
+	LASSERT(!list_empty(&ns->ns_list_chain));
+	/* Some asserts and possibly other parts of the code are still
+	 * using list_empty(&ns->ns_list_chain). This is why it is
+	 * important to use list_del_init() here. */
+	list_del_init(&ns->ns_list_chain);
+	ldlm_namespace_nr_dec(client);
+	mutex_unlock(ldlm_namespace_lock(client));
+}
+
 /**
  * Performs freeing memory structures related to \a ns. This is only done
  * when ldlm_namespce_free_prior() successfully removed all resources
@@ -947,7 +982,7 @@ void ldlm_namespace_get(struct ldlm_namespace *ns)
 EXPORT_SYMBOL(ldlm_namespace_get);
 
 /* This is only for callers that care about refcount */
-int ldlm_namespace_get_return(struct ldlm_namespace *ns)
+static int ldlm_namespace_get_return(struct ldlm_namespace *ns)
 {
 	return atomic_inc_return(&ns->ns_bref);
 }
@@ -961,29 +996,6 @@ void ldlm_namespace_put(struct ldlm_namespace *ns)
 }
 EXPORT_SYMBOL(ldlm_namespace_put);
 
-/** Register \a ns in the list of namespaces */
-void ldlm_namespace_register(struct ldlm_namespace *ns, ldlm_side_t client)
-{
-	mutex_lock(ldlm_namespace_lock(client));
-	LASSERT(list_empty(&ns->ns_list_chain));
-	list_add(&ns->ns_list_chain, ldlm_namespace_inactive_list(client));
-	ldlm_namespace_nr_inc(client);
-	mutex_unlock(ldlm_namespace_lock(client));
-}
-
-/** Unregister \a ns from the list of namespaces. */
-void ldlm_namespace_unregister(struct ldlm_namespace *ns, ldlm_side_t client)
-{
-	mutex_lock(ldlm_namespace_lock(client));
-	LASSERT(!list_empty(&ns->ns_list_chain));
-	/* Some asserts and possibly other parts of the code are still
-	 * using list_empty(&ns->ns_list_chain). This is why it is
-	 * important to use list_del_init() here. */
-	list_del_init(&ns->ns_list_chain);
-	ldlm_namespace_nr_dec(client);
-	mutex_unlock(ldlm_namespace_lock(client));
-}
-
 /** Should be called with ldlm_namespace_lock(client) taken. */
 void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
 					  ldlm_side_t client)
@@ -1167,16 +1179,6 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 }
 EXPORT_SYMBOL(ldlm_resource_get);
 
-struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
-{
-	LASSERT(res != NULL);
-	LASSERT(res != LP_POISON);
-	atomic_inc(&res->lr_refcount);
-	CDEBUG(D_INFO, "getref res: %p count: %d\n", res,
-	       atomic_read(&res->lr_refcount));
-	return res;
-}
-
 static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 					 struct ldlm_resource *res)
 {
-- 
2.1.0
