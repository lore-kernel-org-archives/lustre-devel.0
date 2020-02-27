From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:37 -0500
Subject: [lustre-devel] [PATCH 589/622] lustre: ldlm: fix lock convert races
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-590-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

The blocking cb may be triggered in parallel and the convert logic
of the DOM lock must be ready that the cancel_bits could be already
zeroed by the first executor.

As there may be several blocking cb parallel executors and several
conversion callers, each requesting for different inode bits, setup
the following logic:
- the lock keeps the aggregated set of bits requested for cancelling
  by different parties, where 0 means the whole lock is to be
  cancelled, and where the CBPENDING flag means there is a canceling
  job pending;
- once completed, the cancel_bits are zeroed and the CBPENDING flag
  is dropped, meaning the next request will be a part of the next job;
- once a local lock is converted, its state is changed appropriately
  and no cleanup is left for the interpret time as the lock is ready
  for the next usage;
- as the lock is unlocked in a process of conversion and more bits
  may appear, check it and repeat appropriately;
- let just 1 conversion executor to work at a time, others are waiting
  similar to ldlm_cli_cancel();
- there are others who may want to cancel unused locks (cancel_lru,
  cancel_resource_local), consider CANCELING as a request to cancel
  the full lock independently of the cancel_bits;

Some cleanups are done:
- move the cache drop logic to the CANCELING part of the blocking cb
  from the BLOCKING one;
- remove the convert RPC interpret, as the lock cleanups are already
  done in advance; the convert RPC is re-sendable and an error means
  there is a serioes net problem;

WC-bug-id: https://jira.whamcloud.com/browse/LU-11276
Lustre-commit: 6c0b676e4124 ("LU-11276 ldlm: fix lock convert races")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36466
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h  |   9 +-
 fs/lustre/ldlm/ldlm_inodebits.c | 143 +++++++++++++++--------------
 fs/lustre/ldlm/ldlm_internal.h  |  12 +++
 fs/lustre/ldlm/ldlm_lockd.c     |  73 ++++++++++-----
 fs/lustre/ldlm/ldlm_request.c   | 198 +++++++---------------------------------
 fs/lustre/llite/namei.c         |  59 +++++++-----
 6 files changed, 210 insertions(+), 284 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 9ca79f4..42c1806 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -545,7 +545,6 @@ enum ldlm_cancel_flags {
 	LCF_BL_AST     = 0x4, /* Cancel locks marked as LDLM_FL_BL_AST
 			       * in the same RPC
 			       */
-	LCF_CONVERT    = 0x8, /* Try to convert IBITS lock before cancel */
 };
 
 struct ldlm_flock {
@@ -1291,7 +1290,9 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  enum ldlm_mode mode,
 			  u64 *flags, void *lvb, u32 lvb_len,
 			  const struct lustre_handle *lockh, int rc);
-int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags);
+int ldlm_cli_convert_req(struct ldlm_lock *lock, u32 *flags, u64 new_bits);
+int ldlm_cli_convert(struct ldlm_lock *lock,
+		     enum ldlm_cancel_flags cancel_flags);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
 int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags cancel_flags);
@@ -1317,8 +1318,8 @@ int ldlm_cli_cancel_list(struct list_head *head, int count,
 /** @} ldlm_cli_api */
 
 int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop);
-int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits);
-int ldlm_cli_dropbits_list(struct list_head *converts, u64 drop_bits);
+int ldlm_cli_inodebits_convert(struct ldlm_lock *lock,
+			       enum ldlm_cancel_flags cancel_flags);
 
 /* mds/handler.c */
 /* This has to be here because recursive inclusion sucks. */
diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index 9cf3c5f..2288eb5 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -98,92 +98,101 @@ int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop)
 EXPORT_SYMBOL(ldlm_inodebits_drop);
 
 /* convert single lock */
-int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits)
+int ldlm_cli_inodebits_convert(struct ldlm_lock *lock,
+			       enum ldlm_cancel_flags cancel_flags)
 {
-	struct lustre_handle lockh;
+	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+	struct ldlm_lock_desc ld = { { 0 } };
+	u64 drop_bits, new_bits;
 	u32 flags = 0;
 	int rc;
 
-	LASSERT(drop_bits);
-	LASSERT(!lock->l_readers && !lock->l_writers);
-
-	LDLM_DEBUG(lock, "client lock convert START");
+	check_res_locked(lock->l_resource);
 
-	ldlm_lock2handle(lock, &lockh);
-	lock_res_and_lock(lock);
-	/* check if all bits are blocked */
-	if (!(lock->l_policy_data.l_inodebits.bits & ~drop_bits)) {
-		unlock_res_and_lock(lock);
-		/* return error to continue with cancel */
-		rc = -EINVAL;
-		goto exit;
+	/* Lock is being converted already */
+	if (ldlm_is_converting(lock)) {
+		if (!(cancel_flags & LCF_ASYNC)) {
+			unlock_res_and_lock(lock);
+			wait_event_idle(lock->l_waitq,
+					is_lock_converted(lock));
+			lock_res_and_lock(lock);
+		}
+		return 0;
 	}
 
-	/* check if no common bits, consider this as successful convert */
-	if (!(lock->l_policy_data.l_inodebits.bits & drop_bits)) {
-		unlock_res_and_lock(lock);
-		rc = 0;
-		goto exit;
-	}
+	/* lru_cancel may happen in parallel and call ldlm_cli_cancel_list()
+	 * independently.
+	 */
+	if (ldlm_is_canceling(lock))
+		return -EINVAL;
 
-	/* check if there is race with cancel */
-	if (ldlm_is_canceling(lock) || ldlm_is_cancel(lock)) {
-		unlock_res_and_lock(lock);
-		rc = -EINVAL;
-		goto exit;
-	}
+	/* no need in only local convert */
+	if (lock->l_flags & (LDLM_FL_LOCAL_ONLY | LDLM_FL_CANCEL_ON_BLOCK))
+		return -EINVAL;
 
-	/* clear cbpending flag early, it is safe to match lock right after
-	 * client convert because it is downgrade always.
+	drop_bits = lock->l_policy_data.l_inodebits.cancel_bits;
+	/* no cancel bits - means that caller needs full cancel */
+	if (drop_bits == 0)
+		return -EINVAL;
+
+	new_bits = lock->l_policy_data.l_inodebits.bits & ~drop_bits;
+	/* check if all lock bits are dropped, proceed with cancel */
+	if (!new_bits)
+		return -EINVAL;
+
+	/* check if no dropped bits, consider this as successful convert
 	 */
-	ldlm_clear_cbpending(lock);
-	ldlm_clear_bl_ast(lock);
+	if (lock->l_policy_data.l_inodebits.bits == new_bits)
+		return 0;
 
-	/* If lock is being converted already, check drop bits first */
-	if (ldlm_is_converting(lock)) {
-		/* raced lock convert, lock inodebits are remaining bits
-		 * so check if they are conflicting with new convert or not.
-		 */
-		if (!(lock->l_policy_data.l_inodebits.bits & drop_bits)) {
-			unlock_res_and_lock(lock);
-			rc = 0;
-			goto exit;
-		}
-		/* Otherwise drop new conflicting bits in new convert */
-	}
 	ldlm_set_converting(lock);
-	/* from all bits of blocking lock leave only conflicting */
-	drop_bits &= lock->l_policy_data.l_inodebits.bits;
-	/* save them in cancel_bits, so l_blocking_ast will know
-	 * which bits from the current lock were dropped.
-	 */
-	lock->l_policy_data.l_inodebits.cancel_bits = drop_bits;
-	/* Finally clear these bits in lock ibits */
-	ldlm_inodebits_drop(lock, drop_bits);
-	unlock_res_and_lock(lock);
 	/* Finally call cancel callback for remaining bits only.
 	 * It is important to have converting flag during that
 	 * so blocking_ast callback can distinguish convert from
 	 * cancels.
 	 */
-	if (lock->l_blocking_ast)
-		lock->l_blocking_ast(lock, NULL, lock->l_ast_data,
-				     LDLM_CB_CANCELING);
-
+	ld.l_policy_data.l_inodebits.cancel_bits = drop_bits;
+	unlock_res_and_lock(lock);
+	lock->l_blocking_ast(lock, &ld, lock->l_ast_data, LDLM_CB_CANCELING);
 	/* now notify server about convert */
-	rc = ldlm_cli_convert(lock, &flags);
-	if (rc) {
-		lock_res_and_lock(lock);
-		if (ldlm_is_converting(lock)) {
-			ldlm_clear_converting(lock);
-			ldlm_set_cbpending(lock);
-			ldlm_set_bl_ast(lock);
-		}
-		unlock_res_and_lock(lock);
-		goto exit;
+	rc = ldlm_cli_convert_req(lock, &flags, new_bits);
+	lock_res_and_lock(lock);
+	if (rc)
+		goto full_cancel;
+
+	/* Finally clear these bits in lock ibits */
+	ldlm_inodebits_drop(lock, drop_bits);
+
+	/* Being locked again check if lock was canceled, it is important
+	 * to do and don't drop cbpending below
+	 */
+	if (ldlm_is_canceling(lock)) {
+		rc = -EINVAL;
+		goto full_cancel;
+	}
+
+	/* also check again if more bits to be cancelled appeared */
+	if (drop_bits != lock->l_policy_data.l_inodebits.cancel_bits) {
+		rc = -EAGAIN;
+		goto clear_converting;
 	}
 
-exit:
-	LDLM_DEBUG(lock, "client lock convert END");
+	/* clear cbpending flag early, it is safe to match lock right after
+	 * client convert because it is downgrade always.
+	 */
+	ldlm_clear_cbpending(lock);
+	ldlm_clear_bl_ast(lock);
+	spin_lock(&ns->ns_lock);
+	if (list_empty(&lock->l_lru))
+		ldlm_lock_add_to_lru_nolock(lock);
+	spin_unlock(&ns->ns_lock);
+
+	/* the job is done, zero the cancel_bits. If more conflicts appear,
+	 * it will result in another cycle of ldlm_cli_inodebits_convert().
+	 */
+full_cancel:
+	lock->l_policy_data.l_inodebits.cancel_bits = 0;
+clear_converting:
+	ldlm_clear_converting(lock);
 	return rc;
 }
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 336d9b7..996c0fb 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -171,6 +171,7 @@ int ldlm_bl_to_thread_list(struct ldlm_namespace *ns,
 
 void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
+void ldlm_bl_desc2lock(const struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
 
 extern struct kmem_cache *ldlm_resource_slab;
 extern struct kset *ldlm_ns_kset;
@@ -330,6 +331,17 @@ static inline bool is_bl_done(struct ldlm_lock *lock)
 	return bl_done;
 }
 
+static inline bool is_lock_converted(struct ldlm_lock *lock)
+{
+	bool ret = 0;
+
+	lock_res_and_lock(lock);
+	ret = (lock->l_policy_data.l_inodebits.cancel_bits == 0);
+	unlock_res_and_lock(lock);
+
+	return ret;
+}
+
 typedef void (*ldlm_policy_wire_to_local_t)(const union ldlm_wire_policy_data *,
 					    union ldlm_policy_data *);
 
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 79dab6e..32b7be1 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -73,7 +73,6 @@ struct ldlm_cb_async_args {
 /* LDLM state */
 
 static struct ldlm_state *ldlm_state;
-
 struct ldlm_bl_pool {
 	spinlock_t		blp_lock;
 
@@ -111,21 +110,15 @@ struct ldlm_bl_work_item {
 };
 
 /**
- * Callback handler for receiving incoming blocking ASTs.
- *
- * This can only happen on client side.
+ * Server may pass additional information about blocking lock.
+ * For IBITS locks it is conflicting bits which can be used for
+ * lock convert instead of cancel.
  */
-void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
-			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock)
+void ldlm_bl_desc2lock(const struct ldlm_lock_desc *ld, struct ldlm_lock *lock)
 {
-	int do_ast;
-
-	LDLM_DEBUG(lock, "client blocking AST callback handler");
-
-	lock_res_and_lock(lock);
-
-	/* set bits to cancel for this lock for possible lock convert */
-	if (lock->l_resource->lr_type == LDLM_IBITS) {
+	check_res_locked(lock->l_resource);
+	if (ld &&
+	    (lock->l_resource->lr_type == LDLM_IBITS)) {
 		/*
 		 * Lock description contains policy of blocking lock, and its
 		 * cancel_bits is used to pass conflicting bits.  NOTE: ld can
@@ -137,18 +130,41 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 		 * cookie, never use cancel bits from different resource, full
 		 * cancel is to be used.
 		 */
-		if (ld && ld->l_policy_data.l_inodebits.bits &&
+		if (ld->l_policy_data.l_inodebits.cancel_bits &&
 		    ldlm_res_eq(&ld->l_resource.lr_name,
-				&lock->l_resource->lr_name))
-			lock->l_policy_data.l_inodebits.cancel_bits =
+				&lock->l_resource->lr_name) &&
+		    !(ldlm_is_cbpending(lock) &&
+		      lock->l_policy_data.l_inodebits.cancel_bits == 0)) {
+			/* always combine conflicting ibits */
+			lock->l_policy_data.l_inodebits.cancel_bits |=
 				ld->l_policy_data.l_inodebits.cancel_bits;
-		/*
-		 * If there is no valid ld and lock is cbpending already
-		 * then cancel_bits should be kept, otherwise it is zeroed.
-		 */
-		else if (!ldlm_is_cbpending(lock))
+		} else {
+			/* If cancel_bits are not obtained or
+			 * if the lock is already CBPENDING and
+			 * has no cancel_bits set
+			 * - the full lock is to be cancelled
+			 */
 			lock->l_policy_data.l_inodebits.cancel_bits = 0;
+		}
 	}
+}
+
+/**
+ * Callback handler for receiving incoming blocking ASTs.
+ *
+ * This can only happen on client side.
+ */
+void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
+			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock)
+{
+	int do_ast;
+
+	LDLM_DEBUG(lock, "client blocking AST callback handler");
+
+	lock_res_and_lock(lock);
+
+	/* get extra information from desc if any */
+	ldlm_bl_desc2lock(ld, lock);
 	ldlm_set_cbpending(lock);
 
 	do_ast = !lock->l_readers && !lock->l_writers;
@@ -269,6 +285,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 		 * Let ldlm_cancel_lru() be fast.
 		 */
 		ldlm_lock_remove_from_lru(lock);
+		ldlm_bl_desc2lock(&dlm_req->lock_desc, lock);
 		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_BL_AST;
 		LDLM_DEBUG(lock, "completion AST includes blocking AST");
 	}
@@ -318,6 +335,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 				    struct ldlm_request *dlm_req,
 				    struct ldlm_lock *lock)
 {
+	struct ldlm_lock_desc *ld = &dlm_req->lock_desc;
 	int rc = -ENXIO;
 
 	LDLM_DEBUG(lock, "client glimpse AST callback handler");
@@ -339,8 +357,15 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 			ktime_add(lock->l_last_used,
 				  ktime_set(ns->ns_dirty_age_limit, 0)))) {
 		unlock_res_and_lock(lock);
-		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
-			ldlm_handle_bl_callback(ns, NULL, lock);
+
+		/* For MDS glimpse it is always DOM lock, set corresponding
+		 * cancel_bits to perform lock convert if needed
+		 */
+		if (lock->l_resource->lr_type == LDLM_IBITS)
+			ld->l_policy_data.l_inodebits.cancel_bits =
+							MDS_INODELOCK_DOM;
+		if (ldlm_bl_to_thread_lock(ns, ld, lock))
+			ldlm_handle_bl_callback(ns, ld, lock);
 
 		return;
 	}
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 6df057d..7eba8d2 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -489,6 +489,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 	if ((*flags) & LDLM_FL_AST_SENT) {
 		lock_res_and_lock(lock);
+		ldlm_bl_desc2lock(&reply->lock_desc, lock);
 		lock->l_flags |= LDLM_FL_CBPENDING |  LDLM_FL_BL_AST;
 		unlock_res_and_lock(lock);
 		LDLM_DEBUG(lock, "enqueue reply includes blocking AST");
@@ -875,129 +876,6 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 EXPORT_SYMBOL(ldlm_cli_enqueue);
 
 /**
- * Client-side lock convert reply handling.
- *
- * Finish client lock converting, checks for concurrent converts
- * and clear 'converting' flag so lock can be placed back into LRU.
- */
-static int lock_convert_interpret(const struct lu_env *env,
-				  struct ptlrpc_request *req,
-				  void *args, int rc)
-{
-	struct ldlm_async_args *aa = args;
-	struct ldlm_lock *lock;
-	struct ldlm_reply *reply;
-
-	lock = ldlm_handle2lock(&aa->lock_handle);
-	if (!lock) {
-		LDLM_DEBUG_NOLOCK("convert ACK for unknown local cookie %#llx",
-			aa->lock_handle.cookie);
-		return -ESTALE;
-	}
-
-	LDLM_DEBUG(lock, "CONVERTED lock:");
-
-	if (rc != ELDLM_OK)
-		goto out;
-
-	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	if (!reply) {
-		rc = -EPROTO;
-		goto out;
-	}
-
-	if (reply->lock_handle.cookie != aa->lock_handle.cookie) {
-		LDLM_ERROR(lock,
-			   "convert ACK with wrong lock cookie %#llx but cookie %#llx from server %s id %s\n",
-			   aa->lock_handle.cookie, reply->lock_handle.cookie,
-			   req->rq_export->exp_client_uuid.uuid,
-			   libcfs_id2str(req->rq_peer));
-		rc = ELDLM_NO_LOCK_DATA;
-		goto out;
-	}
-
-	lock_res_and_lock(lock);
-	/*
-	 * Lock convert is sent for any new bits to drop, the converting flag
-	 * is dropped when ibits on server are the same as on client. Meanwhile
-	 * that can be so that more later convert will be replied first with
-	 * and clear converting flag, so in case of such race just exit here.
-	 * if lock has no converting bits then.
-	 */
-	if (!ldlm_is_converting(lock)) {
-		LDLM_DEBUG(lock,
-			   "convert ACK for lock without converting flag, reply ibits %#llx",
-			   reply->lock_desc.l_policy_data.l_inodebits.bits);
-	} else if (reply->lock_desc.l_policy_data.l_inodebits.bits !=
-		   lock->l_policy_data.l_inodebits.bits) {
-		/*
-		 * Compare server returned lock ibits and local lock ibits
-		 * if they are the same we consider conversion is done,
-		 * otherwise we have more converts inflight and keep
-		 * converting flag.
-		 */
-		LDLM_DEBUG(lock, "convert ACK with ibits %#llx\n",
-			   reply->lock_desc.l_policy_data.l_inodebits.bits);
-	} else {
-		ldlm_clear_converting(lock);
-
-		/*
-		 * Concurrent BL AST may arrive and cause another convert
-		 * or cancel so just do nothing here if bl_ast is set,
-		 * finish with convert otherwise.
-		 */
-		if (!ldlm_is_bl_ast(lock)) {
-			struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-
-			/*
-			 * Drop cancel_bits since there are no more converts
-			 * and put lock into LRU if it is still not used and
-			 * is not there yet.
-			 */
-			lock->l_policy_data.l_inodebits.cancel_bits = 0;
-			if (!lock->l_readers && !lock->l_writers &&
-			    !ldlm_is_canceling(lock)) {
-				spin_lock(&ns->ns_lock);
-				/* there is check for list_empty() inside */
-				ldlm_lock_remove_from_lru_nolock(lock);
-				ldlm_lock_add_to_lru_nolock(lock);
-				spin_unlock(&ns->ns_lock);
-			}
-		}
-	}
-	unlock_res_and_lock(lock);
-out:
-	if (rc) {
-		int flag;
-
-		lock_res_and_lock(lock);
-		if (ldlm_is_converting(lock)) {
-			ldlm_clear_converting(lock);
-			ldlm_set_cbpending(lock);
-			ldlm_set_bl_ast(lock);
-			lock->l_policy_data.l_inodebits.cancel_bits = 0;
-		}
-		unlock_res_and_lock(lock);
-
-		/*
-		 * fallback to normal lock cancel. If rc means there is no
-		 * valid lock on server, do only local cancel
-		 */
-		if (rc == ELDLM_NO_LOCK_DATA)
-			flag = LCF_LOCAL;
-		else
-			flag = LCF_ASYNC;
-
-		rc = ldlm_cli_cancel(&aa->lock_handle, flag);
-		if (rc < 0)
-			LDLM_DEBUG(lock, "failed to cancel lock: rc = %d\n",
-				   rc);
-	}
-	LDLM_LOCK_PUT(lock);
-	return rc;
-}
-
-/**
  * Client-side IBITS lock convert.
  *
  * Inform server that lock has been converted instead of canceling.
@@ -1009,17 +887,13 @@ static int lock_convert_interpret(const struct lu_env *env,
  * is made asynchronous.
  *
  */
-int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
+int ldlm_cli_convert_req(struct ldlm_lock *lock, u32 *flags, u64 new_bits)
 {
 	struct ldlm_request *body;
 	struct ptlrpc_request *req;
-	struct ldlm_async_args *aa;
 	struct obd_export *exp = lock->l_conn_export;
 
-	if (!exp) {
-		LDLM_ERROR(lock, "convert must not be called on local locks.");
-		return -EINVAL;
-	}
+	LASSERT(exp);
 
 	/*
 	 * this is better to check earlier and it is done so already,
@@ -1050,8 +924,7 @@ int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
 	body->lock_desc.l_req_mode = lock->l_req_mode;
 	body->lock_desc.l_granted_mode = lock->l_granted_mode;
 
-	body->lock_desc.l_policy_data.l_inodebits.bits =
-					lock->l_policy_data.l_inodebits.bits;
+	body->lock_desc.l_policy_data.l_inodebits.bits = new_bits;
 	body->lock_desc.l_policy_data.l_inodebits.cancel_bits = 0;
 
 	body->lock_flags = ldlm_flags_to_wire(*flags);
@@ -1071,10 +944,6 @@ int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
 		lprocfs_counter_incr(exp->exp_obd->obd_svc_stats,
 				     LDLM_CONVERT - LDLM_FIRST_OPC);
 
-	aa = ptlrpc_req_async_args(aa, req);
-	ldlm_lock2handle(lock, &aa->lock_handle);
-	req->rq_interpret_reply = lock_convert_interpret;
-
 	ptlrpcd_add_req(req);
 	return 0;
 }
@@ -1301,6 +1170,27 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 	return 0;
 }
 
+int ldlm_cli_convert(struct ldlm_lock *lock,
+		     enum ldlm_cancel_flags cancel_flags)
+{
+	int rc = -EINVAL;
+
+	LASSERT(!lock->l_readers && !lock->l_writers);
+	LDLM_DEBUG(lock, "client lock convert START");
+
+	if (lock->l_resource->lr_type == LDLM_IBITS) {
+		lock_res_and_lock(lock);
+		do {
+			rc = ldlm_cli_inodebits_convert(lock, cancel_flags);
+		} while (rc == -EAGAIN);
+		unlock_res_and_lock(lock);
+	}
+
+	LDLM_DEBUG(lock, "client lock convert END");
+	return rc;
+}
+EXPORT_SYMBOL(ldlm_cli_convert);
+
 /**
  * Client side lock cancel.
  *
@@ -1323,20 +1213,9 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		return 0;
 	}
 
-	/* Convert lock bits instead of cancel for IBITS locks */
-	if (cancel_flags & LCF_CONVERT) {
-		LASSERT(lock->l_resource->lr_type == LDLM_IBITS);
-		LASSERT(lock->l_policy_data.l_inodebits.cancel_bits != 0);
-
-		rc = ldlm_cli_dropbits(lock,
-				lock->l_policy_data.l_inodebits.cancel_bits);
-		if (rc == 0) {
-			LDLM_LOCK_RELEASE(lock);
-			return 0;
-		}
-	}
-
 	lock_res_and_lock(lock);
+	LASSERT(!ldlm_is_converting(lock));
+
 	/* Lock is being canceled and the caller doesn't want to wait */
 	if (ldlm_is_canceling(lock)) {
 		unlock_res_and_lock(lock);
@@ -1348,16 +1227,6 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		return 0;
 	}
 
-	/*
-	 * Lock is being converted, cancel it immediately.
-	 * When convert will end, it releases lock and it will be gone.
-	 */
-	if (ldlm_is_converting(lock)) {
-		/* set back flags removed by convert */
-		ldlm_set_cbpending(lock);
-		ldlm_set_bl_ast(lock);
-	}
-
 	ldlm_set_canceling(lock);
 	unlock_res_and_lock(lock);
 
@@ -1723,8 +1592,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			/* No locks which got blocking requests. */
 			LASSERT(!ldlm_is_bl_ast(lock));
 
-			if (!ldlm_is_canceling(lock) &&
-			    !ldlm_is_converting(lock))
+			if (!ldlm_is_canceling(lock))
 				break;
 
 			/*
@@ -1782,7 +1650,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 		lock_res_and_lock(lock);
 		/* Check flags again under the lock. */
-		if (ldlm_is_canceling(lock) || ldlm_is_converting(lock) ||
+		if (ldlm_is_canceling(lock) ||
 		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
 			/*
 			 * Another thread is removing lock from LRU, or
@@ -1908,11 +1776,10 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 			continue;
 
 		/*
-		 * If somebody is already doing CANCEL, or blocking AST came,
-		 * skip this lock.
+		 * If somebody is already doing CANCEL, or blocking AST came
+		 * then skip this lock.
 		 */
-		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock) ||
-		    ldlm_is_converting(lock))
+		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock))
 			continue;
 
 		if (lockmode_compat(lock->l_granted_mode, mode))
@@ -1938,7 +1805,6 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 		/* See CBPENDING comment in ldlm_cancel_lru */
 		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING |
 				 lock_flags;
-
 		LASSERT(list_empty(&lock->l_bl_ast));
 		list_add(&lock->l_bl_ast, cancels);
 		LDLM_LOCK_GET(lock);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index c87653d..13c1cf9 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -431,11 +431,10 @@ int ll_md_need_convert(struct ldlm_lock *lock)
 	return !!(bits);
 }
 
-int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
+int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *ld,
 		       void *data, int flag)
 {
 	struct lustre_handle lockh;
-	u64 bits = lock->l_policy_data.l_inodebits.bits;
 	int rc;
 
 	switch (flag) {
@@ -443,17 +442,21 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 	{
 		u64 cancel_flags = LCF_ASYNC;
 
-		if (ll_md_need_convert(lock)) {
-			cancel_flags |= LCF_CONVERT;
-			/* For lock convert some cancel actions may require
-			 * this lock with non-dropped canceled bits, e.g. page
-			 * flush for DOM lock. So call ll_lock_cancel_bits()
-			 * here while canceled bits are still set.
-			 */
-			bits = lock->l_policy_data.l_inodebits.cancel_bits;
-			if (bits & MDS_INODELOCK_DOM)
-				ll_lock_cancel_bits(lock, MDS_INODELOCK_DOM);
+		/* if lock convert is not needed then still have to
+		 * pass lock via ldlm_cli_convert() to keep all states
+		 * correct, set cancel_bits to full lock bits to cause
+		 * full cancel to happen.
+		 */
+		if (!ll_md_need_convert(lock)) {
+			lock_res_and_lock(lock);
+			lock->l_policy_data.l_inodebits.cancel_bits =
+					lock->l_policy_data.l_inodebits.bits;
+			unlock_res_and_lock(lock);
 		}
+		rc = ldlm_cli_convert(lock, cancel_flags);
+		if (!rc)
+			return 0;
+		/* continue with cancel otherwise */
 		ldlm_lock2handle(lock, &lockh);
 		rc = ldlm_cli_cancel(&lockh, cancel_flags);
 		if (rc < 0) {
@@ -463,24 +466,34 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		break;
 	}
 	case LDLM_CB_CANCELING:
+	{
+		u64 to_cancel = lock->l_policy_data.l_inodebits.bits;
+
 		/* Nothing to do for non-granted locks */
 		if (!ldlm_is_granted(lock))
 			break;
 
-		if (ldlm_is_converting(lock)) {
-			/* this is called on already converted lock, so
-			 * ibits has remained bits only and cancel_bits
-			 * are bits that were dropped.
-			 * Note that DOM lock is handled prior lock convert
-			 * and is excluded here.
+		/* If 'ld' is supplied then bits to be cancelled are passed
+		 * implicitly by lock converting and cancel_bits from 'ld'
+		 * should be used. Otherwise full cancel is being performed
+		 * and lock inodebits are used.
+		 *
+		 * Note: we cannot rely on cancel_bits in lock itself at this
+		 * moment because they can be changed by concurrent thread,
+		 * so ldlm_cli_inodebits_convert() pass cancel bits implicitly
+		 * in 'ld' parameter.
+		 */
+		if (ld) {
+			/* partial bits cancel allowed only during convert */
+			LASSERT(ldlm_is_converting(lock));
+			/* mask cancel bits by lock bits so only no any unused
+			 * bits are passed to ll_lock_cancel_bits()
 			 */
-			bits = lock->l_policy_data.l_inodebits.cancel_bits &
-				~MDS_INODELOCK_DOM;
-		} else {
-			LASSERT(ldlm_is_canceling(lock));
+			to_cancel &= ld->l_policy_data.l_inodebits.cancel_bits;
 		}
-		ll_lock_cancel_bits(lock, bits);
+		ll_lock_cancel_bits(lock, to_cancel);
 		break;
+	}
 	default:
 		LBUG();
 	}
-- 
1.8.3.1
