From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:17 -0400
Subject: [lustre-devel] [PATCH 10/11] lustre: ldlm: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the ldlm layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_extent.c   |  1 -
 fs/lustre/ldlm/ldlm_flock.c    | 15 ++++++++-------
 fs/lustre/ldlm/ldlm_internal.h |  5 +++--
 fs/lustre/ldlm/ldlm_lib.c      |  4 ++--
 fs/lustre/ldlm/ldlm_lock.c     |  8 +++-----
 fs/lustre/ldlm/ldlm_lockd.c    | 22 +++++++++++++---------
 fs/lustre/ldlm/ldlm_pool.c     |  3 ++-
 fs/lustre/ldlm/ldlm_request.c  | 18 ++++++++----------
 8 files changed, 39 insertions(+), 37 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 99aef0b..0695f7e 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -79,7 +79,6 @@ u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, u64 old_kms)
 	ldlm_set_kms_ignore(lock);
 
 	list_for_each_entry(lck, &res->lr_granted, l_res_link) {
-
 		if (ldlm_is_kms_ignore(lck))
 			continue;
 
diff --git a/fs/lustre/ldlm/ldlm_flock.c b/fs/lustre/ldlm/ldlm_flock.c
index 4316b2b..d2b4f0d 100644
--- a/fs/lustre/ldlm/ldlm_flock.c
+++ b/fs/lustre/ldlm/ldlm_flock.c
@@ -118,7 +118,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	struct ldlm_lock *new2 = NULL;
 	enum ldlm_mode mode = req->l_req_mode;
 	int added = (mode == LCK_NL);
-	int splitted = 0;
+	int split = 0;
 	const struct ldlm_callback_suite null_cbs = { };
 
 	CDEBUG(D_DLMTRACE,
@@ -146,7 +146,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	 * We may have to merge or split existing locks.
 	 */
 	list_for_each_entry_safe_from(lock, tmp, &res->lr_granted, l_res_link) {
-
 		if (!ldlm_same_flock_owner(lock, new))
 			break;
 
@@ -246,7 +245,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 			goto reprocess;
 		}
 
-		splitted = 1;
+		split = 1;
 
 		new2->l_granted_mode = lock->l_granted_mode;
 		new2->l_policy_data.l_flock.pid =
@@ -273,7 +272,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 	}
 
 	/* if new2 is created but never used, destroy it*/
-	if (splitted == 0 && new2)
+	if (split == 0 && new2)
 		ldlm_lock_destroy_nolock(new2);
 
 	/* At this point we're granting the lock request. */
@@ -345,12 +344,14 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 		   "client-side enqueue returned a blocked lock, sleeping");
 
 	/* Go to sleep until the lock is granted. */
-	rc = l_wait_event_abortable(lock->l_waitq, is_granted_or_cancelled(lock));
-
+	rc = l_wait_event_abortable(lock->l_waitq,
+				    is_granted_or_cancelled(lock));
 	if (rc) {
 		lock_res_and_lock(lock);
 
-		/* client side - set flag to prevent lock from being put on LRU list */
+		/* client side - set flag to prevent lock from being put on
+		 * LRU list
+		 */
 		ldlm_set_cbpending(lock);
 		unlock_res_and_lock(lock);
 
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index d8dcf8a..05d5b08 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -146,6 +146,7 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
 void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
 void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
 				      enum ldlm_mode mode);
+struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
 int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
@@ -212,8 +213,8 @@ enum ldlm_policy_res {
 #define LDLM_POOL_SYSFS_SET_int(a, b) { a = b; }
 #define LDLM_POOL_SYSFS_PRINT_u64(v) sprintf(buf, "%lld\n", v)
 #define LDLM_POOL_SYSFS_SET_u64(a, b) { a = b; }
-#define LDLM_POOL_SYSFS_PRINT_atomic(v) sprintf(buf, "%d\n", atomic_read(&v))
-#define LDLM_POOL_SYSFS_SET_atomic(a, b) atomic_set(&a, b)
+#define LDLM_POOL_SYSFS_PRINT_atomic(v) sprintf(buf, "%d\n", atomic_read(&(v)))
+#define LDLM_POOL_SYSFS_SET_atomic(a, b) atomic_set(&(a), b)
 
 #define LDLM_POOL_SYSFS_READER_SHOW(var, type)				    \
 	static ssize_t var##_show(struct kobject *kobj,			    \
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 9c61b33..887507d 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -832,9 +832,9 @@ int ldlm_error2errno(enum ldlm_error error)
 		result = -EBADF;
 		break;
 	default:
-		if (((int)error) < 0)  /* cast to signed type */
+		if (((int)error) < 0) {	/* cast to signed type */
 			result = error; /* as enum ldlm_error can be unsigned */
-		else {
+		} else {
 			CERROR("Invalid DLM result code: %d\n", error);
 			result = -EPROTO;
 		}
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 7ec5fc9..2f2b1ab 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -874,7 +874,6 @@ static void search_granted_lock(struct list_head *queue,
 	struct ldlm_lock *lock, *mode_end, *policy_end;
 
 	list_for_each_entry(lock, queue, l_res_link) {
-
 		mode_end = list_prev_entry(lock, l_sl_mode);
 
 		if (lock->l_req_mode != req->l_req_mode) {
@@ -1354,8 +1353,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 
 		/* check user's security context */
 		if (lock->l_conn_export &&
-		    sptlrpc_import_check_ctx(
-				class_exp2cliimp(lock->l_conn_export))) {
+		    sptlrpc_import_check_ctx(class_exp2cliimp(lock->l_conn_export))) {
 			if (!(flags & LDLM_FL_TEST_LOCK))
 				ldlm_lock_decref_internal(lock, mode);
 			rc = 0;
@@ -1443,7 +1441,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 			if (loc == RCL_CLIENT)
 				lvb = req_capsule_client_swab_get(pill,
 								  &RMF_DLM_LVB,
-							lustre_swab_ost_lvb_v1);
+								  lustre_swab_ost_lvb_v1);
 			else
 				lvb = req_capsule_server_sized_swab_get(pill,
 						&RMF_DLM_LVB, size,
@@ -1744,7 +1742,7 @@ static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 		return -ENOENT;
 
 	gl_work = list_first_entry(arg->list, struct ldlm_glimpse_work,
-			     gl_list);
+				   gl_list);
 	list_del_init(&gl_work->gl_list);
 
 	lock = gl_work->gl_lock;
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 589b89d..56f042c 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -210,9 +210,9 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 
 	if (lock->l_resource->lr_type != LDLM_PLAIN) {
 		ldlm_convert_policy_to_local(req->rq_export,
-					  dlm_req->lock_desc.l_resource.lr_type,
-					  &dlm_req->lock_desc.l_policy_data,
-					  &lock->l_policy_data);
+					     dlm_req->lock_desc.l_resource.lr_type,
+					     &dlm_req->lock_desc.l_policy_data,
+					     &lock->l_policy_data);
 		LDLM_DEBUG(lock, "completion AST, new policy data");
 	}
 
@@ -222,7 +222,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 		   sizeof(lock->l_resource->lr_name)) != 0) {
 		unlock_res_and_lock(lock);
 		rc = ldlm_lock_change_resource(ns, lock,
-				&dlm_req->lock_desc.l_resource.lr_name);
+					       &dlm_req->lock_desc.l_resource.lr_name);
 		if (rc < 0) {
 			LDLM_ERROR(lock, "Failed to allocate resource");
 			goto out;
@@ -286,7 +286,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 				    struct ldlm_request *dlm_req,
 				    struct ldlm_lock *lock)
 {
-	int rc = -ENOSYS;
+	int rc = -ENXIO;
 
 	LDLM_DEBUG(lock, "client glimpse AST callback handler");
 
@@ -396,8 +396,10 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
 			     struct list_head *cancels, int count,
 			     enum ldlm_cancel_flags cancel_flags)
 {
+	int rc = 0;
+
 	if (cancels && count == 0)
-		return 0;
+		return rc;
 
 	if (cancel_flags & LCF_ASYNC) {
 		struct ldlm_bl_work_item *blwi;
@@ -407,7 +409,7 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
 			return -ENOMEM;
 		init_blwi(blwi, ns, ld, cancels, count, lock, cancel_flags);
 
-		return __ldlm_bl_to_thread(blwi, cancel_flags);
+		rc = __ldlm_bl_to_thread(blwi, cancel_flags);
 	} else {
 		/* if it is synchronous call do minimum mem alloc, as it could
 		 * be triggered from kernel shrinker
@@ -416,8 +418,9 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
 
 		memset(&blwi, 0, sizeof(blwi));
 		init_blwi(&blwi, ns, ld, cancels, count, lock, cancel_flags);
-		return __ldlm_bl_to_thread(&blwi, cancel_flags);
+		rc = __ldlm_bl_to_thread(&blwi, cancel_flags);
 	}
+	return rc;
 }
 
 int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
@@ -446,7 +449,7 @@ static int ldlm_handle_setinfo(struct ptlrpc_request *req)
 	char *key;
 	void *val;
 	int keylen, vallen;
-	int rc = -ENOSYS;
+	int rc = -ENXIO;
 
 	DEBUG_REQ(D_HSM, req, "%s: handle setinfo\n", obd->obd_name);
 
@@ -875,6 +878,7 @@ int ldlm_get_ref(void)
 void ldlm_put_ref(void)
 {
 	int rc = 0;
+
 	mutex_lock(&ldlm_ref_mutex);
 	if (ldlm_refcount == 1) {
 		rc = ldlm_cleanup();
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 1f81795..6714c30 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -360,7 +360,8 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
 	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec > 0) {
 		spin_lock(&pl->pl_lock);
-		recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+		recalc_interval_sec = ktime_get_real_seconds() -
+				      pl->pl_recalc_time;
 
 		if (recalc_interval_sec > 0) {
 			/*
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index a614d74..b7dcfda 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -438,7 +438,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			       PLDLMRES(lock->l_resource));
 
 			rc = ldlm_lock_change_resource(ns, lock,
-					&reply->lock_desc.l_resource.lr_name);
+						       &reply->lock_desc.l_resource.lr_name);
 			if (rc || !lock->l_resource) {
 				rc = -ENOMEM;
 				goto cleanup;
@@ -450,9 +450,9 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			      !(exp_connect_flags(exp) & OBD_CONNECT_IBITS)))
 				/* We assume lock type cannot change on server*/
 				ldlm_convert_policy_to_local(exp,
-						lock->l_resource->lr_type,
-						&reply->lock_desc.l_policy_data,
-						&lock->l_policy_data);
+							     lock->l_resource->lr_type,
+							     &reply->lock_desc.l_policy_data,
+							     &lock->l_policy_data);
 		if (type != LDLM_PLAIN)
 			LDLM_DEBUG(lock,
 				   "client-side enqueue, new policy data");
@@ -927,8 +927,7 @@ static int ldlm_cli_cancel_req(struct obd_export *exp,
 		if (rc == LUSTRE_ESTALE) {
 			CDEBUG(D_DLMTRACE,
 			       "client/server (nid %s) out of sync -- not fatal\n",
-			       libcfs_nid2str(req->rq_import->
-					      imp_connection->c_peer.nid));
+			       libcfs_nid2str(req->rq_import->imp_connection->c_peer.nid));
 			rc = 0;
 		} else if (rc == -ETIMEDOUT && /* check there was no reconnect*/
 			   req->rq_import_generation == imp->imp_generation) {
@@ -1290,10 +1289,9 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
 }
 
-typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
-						      struct ldlm_namespace *,
-						      struct ldlm_lock *, int,
-						      int, int);
+typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *,
+							 struct ldlm_lock *,
+							 int, int, int);
 
 static ldlm_cancel_lru_policy_t
 ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int lru_flags)
-- 
1.8.3.1
