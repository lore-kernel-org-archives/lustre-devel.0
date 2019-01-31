From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:10 -0500
Subject: [lustre-devel] [PATCH 06/26] ldlm: use kernel types for kernel code
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre ldlm code was originally both a user land and kernel
implementation. The source contains many types of the form __u32
but since this is mostly kernel code change the types to kernel
internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  8 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 12 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 14 +++++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 22 +++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 32 +++++++++++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 22 +++++++--------
 7 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 225c023..99aef0b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -57,7 +57,7 @@
 
 #define START(node) ((node)->l_policy_data.l_extent.start)
 #define LAST(node) ((node)->l_policy_data.l_extent.end)
-INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, __u64, __subtree_last,
+INTERVAL_TREE_DEFINE(struct ldlm_lock, l_rb, u64, __subtree_last,
 		     START, LAST, static, extent);
 
 /* When a lock is cancelled by a client, the KMS may undergo change if this
@@ -66,11 +66,11 @@
  *
  * NB: A lock on [x,y] protects a KMS of up to y + 1 bytes!
  */
-__u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
+u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 {
 	struct ldlm_resource *res = lock->l_resource;
 	struct ldlm_lock *lck;
-	__u64 kms = 0;
+	u64 kms = 0;
 
 	/* don't let another thread in ldlm_extent_shift_kms race in
 	 * just after we finish and take our lock into account in its
@@ -192,7 +192,7 @@ void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 }
 
 void ldlm_extent_search(struct rb_root_cached *root,
-			__u64 start, __u64 end,
+			u64 start, u64 end,
 			bool (*matches)(struct ldlm_lock *lock, void *data),
 			void *data)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 94f3b1e..baa5b3a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -312,7 +312,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
  * \retval <0   : failure
  */
 int
-ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
+ldlm_flock_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 {
 	struct file_lock		*getlk = lock->l_ast_data;
 	int				rc = 0;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index b64e2be0..d8dcf8a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -136,10 +136,10 @@ struct ldlm_lock *
 ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *id,
 		 enum ldlm_type type, enum ldlm_mode mode,
 		 const struct ldlm_callback_suite *cbs,
-		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
+		 void *data, u32 lvb_len, enum lvb_type lvb_type);
 enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 				  struct ldlm_lock **lock, void *cookie,
-				  __u64 *flags);
+				  u64 *flags);
 void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
 void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
 				      enum ldlm_mode mode);
@@ -176,7 +176,7 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 void ldlm_extent_add_lock(struct ldlm_resource *res, struct ldlm_lock *lock);
 void ldlm_extent_unlink_lock(struct ldlm_lock *lock);
 void ldlm_extent_search(struct rb_root_cached *root,
-			__u64 start, __u64 end,
+			u64 start, u64 end,
 			bool (*matches)(struct ldlm_lock *lock, void *data),
 			void *data);
 
@@ -195,9 +195,9 @@ struct ldlm_state {
 };
 
 /* ldlm_pool.c */
-__u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
-void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv);
-__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
+u64 ldlm_pool_get_slv(struct ldlm_pool *pl);
+void ldlm_pool_set_clv(struct ldlm_pool *pl, u64 clv);
+u32 ldlm_pool_get_lvf(struct ldlm_pool *pl);
 
 int ldlm_init(void);
 void ldlm_exit(void);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index ebdfc11..e726e76 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -508,7 +508,7 @@ void ldlm_lock2handle(const struct ldlm_lock *lock, struct lustre_handle *lockh)
  *	      Return NULL if flag already set
  */
 struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
-				     __u64 flags)
+				     u64 flags)
 {
 	struct ldlm_lock *lock;
 
@@ -1043,7 +1043,7 @@ struct lock_match_data {
 	struct ldlm_lock	*lmd_lock;
 	enum ldlm_mode		*lmd_mode;
 	union ldlm_policy_data	*lmd_policy;
-	__u64			 lmd_flags;
+	u64			 lmd_flags;
 	int			 lmd_unref;
 };
 
@@ -1250,7 +1250,7 @@ void ldlm_lock_allow_match(struct ldlm_lock *lock)
  * keep caller code unchanged), the context failure will be discovered by
  * caller sometime later.
  */
-enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
+enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 			       const struct ldlm_res_id *res_id,
 			       enum ldlm_type type,
 			       union ldlm_policy_data *policy,
@@ -1313,7 +1313,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 	if (lock) {
 		ldlm_lock2handle(lock, lockh);
 		if ((flags & LDLM_FL_LVB_READY) && !ldlm_is_lvb_ready(lock)) {
-			__u64 wait_flags = LDLM_FL_LVB_READY |
+			u64 wait_flags = LDLM_FL_LVB_READY |
 				LDLM_FL_DESTROYED | LDLM_FL_FAIL_NOTIFIED;
 
 			if (lock->l_completion_ast) {
@@ -1381,7 +1381,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 EXPORT_SYMBOL(ldlm_lock_match);
 
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
-					   __u64 *bits)
+					   u64 *bits)
 {
 	struct ldlm_lock *lock;
 	enum ldlm_mode mode = 0;
@@ -1519,7 +1519,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 				   enum ldlm_type type,
 				   enum ldlm_mode mode,
 				   const struct ldlm_callback_suite *cbs,
-				   void *data, __u32 lvb_len,
+				   void *data, u32 lvb_len,
 				   enum lvb_type lvb_type)
 {
 	struct ldlm_lock *lock;
@@ -1580,7 +1580,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
  */
 enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 				  struct ldlm_lock **lockp,
-				  void *cookie, __u64 *flags)
+				  void *cookie, u64 *flags)
 {
 	struct ldlm_lock *lock = *lockp;
 	struct ldlm_resource *res = lock->l_resource;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 36d14ee..e94d8a3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -137,22 +137,22 @@
  */
 #define LDLM_POOL_SLV_SHIFT (10)
 
-static inline __u64 dru(__u64 val, __u32 shift, int round_up)
+static inline u64 dru(u64 val, u32 shift, int round_up)
 {
 	return (val + (round_up ? (1 << shift) - 1 : 0)) >> shift;
 }
 
-static inline __u64 ldlm_pool_slv_max(__u32 L)
+static inline u64 ldlm_pool_slv_max(u32 L)
 {
 	/*
 	 * Allow to have all locks for 1 client for 10 hrs.
 	 * Formula is the following: limit * 10h / 1 client.
 	 */
-	__u64 lim = (__u64)L *  LDLM_POOL_MAX_AGE / 1;
+	u64 lim = (u64)L *  LDLM_POOL_MAX_AGE / 1;
 	return lim;
 }
 
-static inline __u64 ldlm_pool_slv_min(__u32 L)
+static inline u64 ldlm_pool_slv_min(u32 L)
 {
 	return 1;
 }
@@ -212,7 +212,7 @@ static inline int ldlm_pool_t2gsp(unsigned int t)
 static void ldlm_pool_recalc_stats(struct ldlm_pool *pl)
 {
 	int grant_plan = pl->pl_grant_plan;
-	__u64 slv = pl->pl_server_lock_volume;
+	u64 slv = pl->pl_server_lock_volume;
 	int granted = atomic_read(&pl->pl_granted);
 	int grant_rate = atomic_read(&pl->pl_grant_rate);
 	int cancel_rate = atomic_read(&pl->pl_cancel_rate);
@@ -430,8 +430,8 @@ static int lprocfs_pool_state_seq_show(struct seq_file *m, void *unused)
 	int granted, grant_rate, cancel_rate;
 	int grant_speed, lvf;
 	struct ldlm_pool *pl = m->private;
-	__u64 slv, clv;
-	__u32 limit;
+	u64 slv, clv;
+	u32 limit;
 
 	spin_lock(&pl->pl_lock);
 	slv = pl->pl_server_lock_volume;
@@ -739,9 +739,9 @@ void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock)
  *
  * \pre ->pl_lock is not locked.
  */
-__u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
+u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
 {
-	__u64 slv;
+	u64 slv;
 
 	spin_lock(&pl->pl_lock);
 	slv = pl->pl_server_lock_volume;
@@ -754,7 +754,7 @@ __u64 ldlm_pool_get_slv(struct ldlm_pool *pl)
  *
  * \pre ->pl_lock is not locked.
  */
-void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv)
+void ldlm_pool_set_clv(struct ldlm_pool *pl, u64 clv)
 {
 	spin_lock(&pl->pl_lock);
 	pl->pl_client_lock_volume = clv;
@@ -764,7 +764,7 @@ void ldlm_pool_set_clv(struct ldlm_pool *pl, __u64 clv)
 /**
  * Returns current LVF from \a pl.
  */
-__u32 ldlm_pool_get_lvf(struct ldlm_pool *pl)
+u32 ldlm_pool_get_lvf(struct ldlm_pool *pl)
 {
 	return atomic_read(&pl->pl_lock_volume_factor);
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c09359a..a7fe8c6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -104,7 +104,7 @@ static int ldlm_request_bufsize(int count, int type)
 	return sizeof(struct ldlm_request) + avail;
 }
 
-static void ldlm_expired_completion_wait(struct ldlm_lock *lock, __u32 conn_cnt)
+static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
 {
 	struct obd_import *imp;
 	struct obd_device *obd;
@@ -213,13 +213,13 @@ static int ldlm_completion_tail(struct ldlm_lock *lock, void *data)
  * or penultimate cases happen in some other thread.
  *
  */
-int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
+int ldlm_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 {
 	/* XXX ALLOCATE - 160 bytes */
 	struct obd_device *obd;
 	struct obd_import *imp = NULL;
-	__u32 timeout;
-	__u32 conn_cnt = 0;
+	u32 timeout;
+	u32 conn_cnt = 0;
 	int rc = 0;
 
 	if (flags == LDLM_FL_WAIT_NOREPROC) {
@@ -337,9 +337,9 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
  * Called after receiving reply from server.
  */
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-			  enum ldlm_type type, __u8 with_policy,
+			  enum ldlm_type type, u8 with_policy,
 			  enum ldlm_mode mode,
-			  __u64 *flags, void *lvb, __u32 lvb_len,
+			  u64 *flags, void *lvb, u32 lvb_len,
 			  const struct lustre_handle *lockh, int rc)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
@@ -670,8 +670,8 @@ static struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp,
 int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct ldlm_enqueue_info *einfo,
 		     const struct ldlm_res_id *res_id,
-		     union ldlm_policy_data const *policy, __u64 *flags,
-		     void *lvb, __u32 lvb_len, enum lvb_type lvb_type,
+		     union ldlm_policy_data const *policy, u64 *flags,
+		     void *lvb, u32 lvb_len, enum lvb_type lvb_type,
 		     struct lustre_handle *lockh, int async)
 {
 	struct ldlm_namespace *ns;
@@ -792,9 +792,9 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
  * \retval LDLM_FL_CANCELING otherwise;
  * \retval LDLM_FL_BL_AST if there is a need for a separate CANCEL RPC.
  */
-static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
+static u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 {
-	__u64 rc = LDLM_FL_LOCAL_ONLY;
+	u64 rc = LDLM_FL_LOCAL_ONLY;
 
 	if (lock->l_conn_export) {
 		bool local_only;
@@ -960,8 +960,8 @@ static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
 int ldlm_cli_update_pool(struct ptlrpc_request *req)
 {
 	struct obd_device *obd;
-	__u64 new_slv;
-	__u32 new_limit;
+	u64 new_slv;
+	u32 new_limit;
 
 	if (unlikely(!req->rq_import || !req->rq_import->imp_obd ||
 		     !imp_connect_lru_resize(req->rq_import))) {
@@ -1014,7 +1014,7 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 {
 	struct obd_export *exp;
 	int avail, flags, count = 1;
-	__u64 rc = 0;
+	u64 rc = 0;
 	struct ldlm_namespace *ns;
 	struct ldlm_lock *lock;
 	LIST_HEAD(cancels);
@@ -1080,7 +1080,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 	LIST_HEAD(head);
 	struct ldlm_lock *lock, *next;
 	int left = 0, bl_ast = 0;
-	__u64 rc;
+	u64 rc;
 
 	left = count;
 	list_for_each_entry_safe(lock, next, cancels, l_bl_ast) {
@@ -1169,7 +1169,7 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 {
 	unsigned long cur = jiffies;
 	struct ldlm_pool *pl = &ns->ns_pool;
-	__u64 slv, lvf, lv;
+	u64 slv, lvf, lv;
 	unsigned long la;
 
 	/* Stop LRU processing when we reach past @count or have checked all
@@ -1562,7 +1562,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			       struct list_head *cancels,
 			       union ldlm_policy_data *policy,
-			       enum ldlm_mode mode, __u64 lock_flags,
+			       enum ldlm_mode mode, u64 lock_flags,
 			       enum ldlm_cancel_flags cancel_flags,
 			       void *opaque)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 11c0b88..e0b9918 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -132,7 +132,7 @@ static ssize_t resource_count_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
-	__u64		  res = 0;
+	u64		  res = 0;
 	struct cfs_hash_bd	  bd;
 	int		    i;
 
@@ -148,7 +148,7 @@ static ssize_t lock_count_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
-	__u64		  locks;
+	u64		  locks;
 
 	locks = lprocfs_stats_collector(ns->ns_stats, LDLM_NSS_LOCKS,
 					LPROCFS_FIELDS_FLAGS_SUM);
@@ -172,7 +172,7 @@ static ssize_t lru_size_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
-	__u32 *nr = &ns->ns_max_unused;
+	u32 *nr = &ns->ns_max_unused;
 
 	if (ns_connect_lru_resize(ns))
 		nr = &ns->ns_nr_unused;
@@ -421,12 +421,12 @@ static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
 {
 	const struct ldlm_res_id *id = key;
 	struct lu_fid       fid;
-	__u32	       hash;
-	__u32	       val;
+	u32	       hash;
+	u32	       val;
 
 	fid.f_seq = id->name[LUSTRE_RES_ID_SEQ_OFF];
-	fid.f_oid = (__u32)id->name[LUSTRE_RES_ID_VER_OID_OFF];
-	fid.f_ver = (__u32)(id->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
+	fid.f_oid = (u32)id->name[LUSTRE_RES_ID_VER_OID_OFF];
+	fid.f_ver = (u32)(id->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
 
 	hash = fid_flatten32(&fid);
 	hash += (hash >> 4) + (hash << 12); /* mixing oid and seq */
@@ -694,7 +694,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
  * locks with refs.
  */
 static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
-			     __u64 flags)
+			     u64 flags)
 {
 	int rc = 0;
 	bool local_only = !!(flags & LDLM_FL_LOCAL_ONLY);
@@ -764,7 +764,7 @@ static int ldlm_resource_clean(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			       struct hlist_node *hnode, void *arg)
 {
 	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	__u64 flags = *(__u64 *)arg;
+	u64 flags = *(u64 *)arg;
 
 	cleanup_resource(res, &res->lr_granted, flags);
 	cleanup_resource(res, &res->lr_waiting, flags);
@@ -795,7 +795,7 @@ static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  * evicted and all of its state needs to be destroyed.
  * Also used during shutdown.
  */
-int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags)
+int ldlm_namespace_cleanup(struct ldlm_namespace *ns, u64 flags)
 {
 	if (!ns) {
 		CDEBUG(D_INFO, "NULL ns, skipping cleanup\n");
@@ -1048,7 +1048,7 @@ struct ldlm_resource *
 	struct hlist_node     *hnode;
 	struct ldlm_resource *res = NULL;
 	struct cfs_hash_bd	 bd;
-	__u64		 version;
+	u64		 version;
 	int		      ns_refcount = 0;
 	int rc;
 
-- 
1.8.3.1
