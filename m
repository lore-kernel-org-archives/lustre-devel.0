From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:26 -0500
Subject: [lustre-devel] [PATCH 038/622] lustre: ldlm: IBITS lock convert
 instead of cancel
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

For IBITS lock it is possible to drop just conflicting
bits and keep lock itself instead of cancelling it.
Lock convert is only bits downgrade on client and then
on server.
Patch implements lock convert during blocking AST.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10175
Lustre-commit: 37932c4beb98 ("LU-10175 ldlm: IBITS lock convert instead of cancel")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30202
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h         |   6 +
 fs/lustre/include/lustre_dlm_flags.h   |  16 +-
 fs/lustre/ldlm/ldlm_inodebits.c        |  92 +++++++-
 fs/lustre/ldlm/ldlm_internal.h         |   2 +
 fs/lustre/ldlm/ldlm_lock.c             |  13 +-
 fs/lustre/ldlm/ldlm_lockd.c            |  18 ++
 fs/lustre/ldlm/ldlm_request.c          | 198 ++++++++++++++++-
 fs/lustre/llite/namei.c                | 383 ++++++++++++++++++++-------------
 fs/lustre/ptlrpc/wiretest.c            |   2 +-
 include/uapi/linux/lustre/lustre_idl.h |   1 +
 10 files changed, 569 insertions(+), 162 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 8dea9ab..66608a9 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -544,6 +544,7 @@ enum ldlm_cancel_flags {
 	LCF_BL_AST     = 0x4, /* Cancel locks marked as LDLM_FL_BL_AST
 			       * in the same RPC
 			       */
+	LCF_CONVERT    = 0x8, /* Try to convert IBITS lock before cancel */
 };
 
 struct ldlm_flock {
@@ -1306,6 +1307,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  enum ldlm_mode mode,
 			  u64 *flags, void *lvb, u32 lvb_len,
 			  const struct lustre_handle *lockh, int rc);
+int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
 int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		    enum ldlm_cancel_flags cancel_flags);
@@ -1330,6 +1332,10 @@ int ldlm_cli_cancel_list(struct list_head *head, int count,
 			 enum ldlm_cancel_flags flags);
 /** @} ldlm_cli_api */
 
+int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop);
+int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits);
+int ldlm_cli_dropbits_list(struct list_head *converts, u64 drop_bits);
+
 /* mds/handler.c */
 /* This has to be here because recursive inclusion sucks. */
 int intent_disposition(struct ldlm_reply *rep, int flag);
diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index 22fb595..c8667c8 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -26,10 +26,10 @@
  */
 #ifndef LDLM_ALL_FLAGS_MASK
 
-/** l_flags bits marked as "all_flags" bits */
-#define LDLM_FL_ALL_FLAGS_MASK		0x00FFFFFFC08F932FULL
+/* l_flags bits marked as "all_flags" bits */
+#define LDLM_FL_ALL_FLAGS_MASK		0x00FFFFFFC28F932FULL
 
-/** extent, mode, or resource changed */
+/* extent, mode, or resource changed */
 #define LDLM_FL_LOCK_CHANGED		0x0000000000000001ULL /* bit 0 */
 #define ldlm_is_lock_changed(_l)	LDLM_TEST_FLAG((_l), 1ULL <<  0)
 #define ldlm_set_lock_changed(_l)	LDLM_SET_FLAG((_l), 1ULL <<  0)
@@ -146,6 +146,16 @@
 #define ldlm_clear_cancel_on_block(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 23)
 
 /**
+ * Flag indicates that lock is being converted (downgraded) during the blocking
+ * AST instead of cancelling. Used for IBITS locks now and drops conflicting
+ * bits only keepeing other.
+ */
+#define LDLM_FL_CONVERTING		0x0000000002000000ULL /* bit 25 */
+#define ldlm_is_converting(_l)		LDLM_TEST_FLAG((_l), 1ULL << 25)
+#define ldlm_set_converting(_l)		LDLM_SET_FLAG((_l), 1ULL << 25)
+#define ldlm_clear_converting(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 25)
+
+/*
  * Part of original lockahead implementation, OBD_CONNECT_LOCKAHEAD_OLD.
  * Reserved temporarily to allow those implementations to keep working.
  * Will be removed after 2.12 release.
diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index ea63d9d..e74928e 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -68,7 +68,14 @@ void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
 }
 
-int ldlm_inodebits_drop(struct ldlm_lock *lock,  __u64 to_drop)
+/**
+ * Attempt to convert already granted IBITS lock with several bits set to
+ * a lock with less bits (downgrade).
+ *
+ * Such lock conversion is used to keep lock with non-blocking bits instead of
+ * cancelling it, introduced for better support of DoM files.
+ */
+int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop)
 {
 	check_res_locked(lock->l_resource);
 
@@ -89,3 +96,86 @@ int ldlm_inodebits_drop(struct ldlm_lock *lock,  __u64 to_drop)
 	return 0;
 }
 EXPORT_SYMBOL(ldlm_inodebits_drop);
+
+/* convert single lock */
+int ldlm_cli_dropbits(struct ldlm_lock *lock, u64 drop_bits)
+{
+	struct lustre_handle lockh;
+	u32 flags = 0;
+	int rc;
+
+	LASSERT(drop_bits);
+	LASSERT(!lock->l_readers && !lock->l_writers);
+
+	LDLM_DEBUG(lock, "client lock convert START");
+
+	ldlm_lock2handle(lock, &lockh);
+	lock_res_and_lock(lock);
+	/* check if all bits are cancelled */
+	if (!(lock->l_policy_data.l_inodebits.bits & ~drop_bits)) {
+		unlock_res_and_lock(lock);
+		/* return error to continue with cancel */
+		rc = -EINVAL;
+		goto exit;
+	}
+
+	/* check if there is race with cancel */
+	if (ldlm_is_canceling(lock) || ldlm_is_cancel(lock)) {
+		unlock_res_and_lock(lock);
+		rc = -EINVAL;
+		goto exit;
+	}
+
+	/* clear cbpending flag early, it is safe to match lock right after
+	 * client convert because it is downgrade always.
+	 */
+	ldlm_clear_cbpending(lock);
+	ldlm_clear_bl_ast(lock);
+
+	/* If lock is being converted already, check drop bits first */
+	if (ldlm_is_converting(lock)) {
+		/* raced lock convert, lock inodebits are remaining bits
+		 * so check if they are conflicting with new convert or not.
+		 */
+		if (!(lock->l_policy_data.l_inodebits.bits & drop_bits)) {
+			unlock_res_and_lock(lock);
+			rc = 0;
+			goto exit;
+		}
+		/* Otherwise drop new conflicting bits in new convert */
+	}
+	ldlm_set_converting(lock);
+	/* from all bits of blocking lock leave only conflicting */
+	drop_bits &= lock->l_policy_data.l_inodebits.bits;
+	/* save them in cancel_bits, so l_blocking_ast will know
+	 * which bits from the current lock were dropped.
+	 */
+	lock->l_policy_data.l_inodebits.cancel_bits = drop_bits;
+	/* Finally clear these bits in lock ibits */
+	ldlm_inodebits_drop(lock, drop_bits);
+	unlock_res_and_lock(lock);
+	/* Finally call cancel callback for remaining bits only.
+	 * It is important to have converting flag during that
+	 * so blocking_ast callback can distinguish convert from
+	 * cancels.
+	 */
+	if (lock->l_blocking_ast)
+		lock->l_blocking_ast(lock, NULL, lock->l_ast_data,
+				     LDLM_CB_CANCELING);
+
+	/* now notify server about convert */
+	rc = ldlm_cli_convert(lock, &flags);
+	if (rc) {
+		lock_res_and_lock(lock);
+		ldlm_clear_converting(lock);
+		ldlm_set_cbpending(lock);
+		ldlm_set_bl_ast(lock);
+		unlock_res_and_lock(lock);
+		LASSERT(list_empty(&lock->l_lru));
+		goto exit;
+	}
+
+exit:
+	LDLM_DEBUG(lock, "client lock convert END");
+	return rc;
+}
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 96dff1d..ec68713 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -153,7 +153,9 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 #define ldlm_lock_remove_from_lru(lock) \
 		ldlm_lock_remove_from_lru_check(lock, ktime_set(0, 0))
 int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock);
+void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock);
 void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
+void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock);
 
 /* ldlm_lockd.c */
 int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index aa19b89..9847c43 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -241,7 +241,7 @@ int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, ktime_t last_use)
 /**
  * Adds LDLM lock @lock to namespace LRU. Assumes LRU is already locked.
  */
-static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
+void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
@@ -791,7 +791,8 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 		    ldlm_bl_to_thread_lock(ns, NULL, lock) != 0)
 			ldlm_handle_bl_callback(ns, NULL, lock);
 	} else if (!lock->l_readers && !lock->l_writers &&
-		   !ldlm_is_no_lru(lock) && !ldlm_is_bl_ast(lock)) {
+		   !ldlm_is_no_lru(lock) && !ldlm_is_bl_ast(lock) &&
+		   !ldlm_is_converting(lock)) {
 		LDLM_DEBUG(lock, "add lock into lru list");
 
 		/* If this is a client-side namespace and this was the last
@@ -1648,6 +1649,13 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 	unlock_res_and_lock(lock);
 
 	ldlm_lock2desc(lock->l_blocking_lock, &d);
+	/* copy blocking lock ibits in cancel_bits as well,
+	 * new client may use them for lock convert and it is
+	 * important to use new field to convert locks from
+	 * new servers only
+	 */
+	d.l_policy_data.l_inodebits.cancel_bits =
+		lock->l_blocking_lock->l_policy_data.l_inodebits.bits;
 
 	rc = lock->l_blocking_ast(lock, &d, (void *)arg, LDLM_CB_BLOCKING);
 	LDLM_LOCK_RELEASE(lock->l_blocking_lock);
@@ -1896,6 +1904,7 @@ void ldlm_lock_cancel(struct ldlm_lock *lock)
 	 */
 	if (lock->l_readers || lock->l_writers) {
 		LDLM_ERROR(lock, "lock still has references");
+		unlock_res_and_lock(lock);
 		LBUG();
 	}
 
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 481719b..b50a3f7 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -118,6 +118,24 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 	LDLM_DEBUG(lock, "client blocking AST callback handler");
 
 	lock_res_and_lock(lock);
+
+	/* set bits to cancel for this lock for possible lock convert */
+	if (lock->l_resource->lr_type == LDLM_IBITS) {
+		/* Lock description contains policy of blocking lock,
+		 * and its cancel_bits is used to pass conflicting bits.
+		 * NOTE: ld can be NULL or can be not NULL but zeroed if
+		 * passed from ldlm_bl_thread_blwi(), check below used bits
+		 * in ld to make sure it is valid description.
+		 */
+		if (ld && ld->l_policy_data.l_inodebits.bits)
+			lock->l_policy_data.l_inodebits.cancel_bits =
+				ld->l_policy_data.l_inodebits.cancel_bits;
+		/* if there is no valid ld and lock is cbpending already
+		 * then cancel_bits should be kept, otherwise it is zeroed.
+		 */
+		else if (!ldlm_is_cbpending(lock))
+			lock->l_policy_data.l_inodebits.cancel_bits = 0;
+	}
 	ldlm_set_cbpending(lock);
 
 	if (ldlm_is_cancel_on_block(lock))
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 92e4f69..5ec0da5 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -818,6 +818,177 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 EXPORT_SYMBOL(ldlm_cli_enqueue);
 
 /**
+ * Client-side lock convert reply handling.
+ *
+ * Finish client lock converting, checks for concurrent converts
+ * and clear 'converting' flag so lock can be placed back into LRU.
+ */
+static int lock_convert_interpret(const struct lu_env *env,
+				  struct ptlrpc_request *req,
+				  struct ldlm_async_args *aa, int rc)
+{
+	struct ldlm_lock *lock;
+	struct ldlm_reply *reply;
+
+	lock = ldlm_handle2lock(&aa->lock_handle);
+	if (!lock) {
+		LDLM_DEBUG_NOLOCK("convert ACK for unknown local cookie %#llx",
+			aa->lock_handle.cookie);
+		return -ESTALE;
+	}
+
+	LDLM_DEBUG(lock, "CONVERTED lock:");
+
+	if (rc != ELDLM_OK)
+		goto out;
+
+	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+	if (!reply) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	if (reply->lock_handle.cookie != aa->lock_handle.cookie) {
+		LDLM_ERROR(lock,
+			   "convert ACK with wrong lock cookie %#llx but cookie %#llx from server %s id %s\n",
+			   aa->lock_handle.cookie, reply->lock_handle.cookie,
+			   req->rq_export->exp_client_uuid.uuid,
+			   libcfs_id2str(req->rq_peer));
+		rc = -ESTALE;
+		goto out;
+	}
+
+	lock_res_and_lock(lock);
+	/* Lock convert is sent for any new bits to drop, the converting flag
+	 * is dropped when ibits on server are the same as on client. Meanwhile
+	 * that can be so that more later convert will be replied first with
+	 * and clear converting flag, so in case of such race just exit here.
+	 * if lock has no converting bits then.
+	 */
+	if (!ldlm_is_converting(lock)) {
+		LDLM_DEBUG(lock,
+			   "convert ACK for lock without converting flag, reply ibits %#llx",
+			   reply->lock_desc.l_policy_data.l_inodebits.bits);
+	} else if (reply->lock_desc.l_policy_data.l_inodebits.bits !=
+		   lock->l_policy_data.l_inodebits.bits) {
+		/* Compare server returned lock ibits and local lock ibits
+		 * if they are the same we consider conversion is done,
+		 * otherwise we have more converts inflight and keep
+		 * converting flag.
+		 */
+		LDLM_DEBUG(lock, "convert ACK with ibits %#llx\n",
+			   reply->lock_desc.l_policy_data.l_inodebits.bits);
+	} else {
+		ldlm_clear_converting(lock);
+
+		/* Concurrent BL AST has arrived, it may cause another convert
+		 * or cancel so just exit here.
+		 */
+		if (!ldlm_is_bl_ast(lock)) {
+			struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
+
+			/* Drop cancel_bits since there are no more converts
+			 * and put lock into LRU if it is not there yet.
+			 */
+			lock->l_policy_data.l_inodebits.cancel_bits = 0;
+			spin_lock(&ns->ns_lock);
+			if (!list_empty(&lock->l_lru))
+				ldlm_lock_remove_from_lru_nolock(lock);
+			ldlm_lock_add_to_lru_nolock(lock);
+			spin_unlock(&ns->ns_lock);
+		}
+	}
+	unlock_res_and_lock(lock);
+out:
+	if (rc) {
+		lock_res_and_lock(lock);
+		if (ldlm_is_converting(lock)) {
+			LASSERT(list_empty(&lock->l_lru));
+			ldlm_clear_converting(lock);
+			ldlm_set_cbpending(lock);
+			ldlm_set_bl_ast(lock);
+		}
+		unlock_res_and_lock(lock);
+	}
+
+	LDLM_LOCK_PUT(lock);
+	return rc;
+}
+
+/**
+ * Client-side IBITS lock convert.
+ *
+ * Inform server that lock has been converted instead of canceling.
+ * Server finishes convert on own side and does reprocess to grant
+ * all related waiting locks.
+ *
+ * Since convert means only ibits downgrading, client doesn't need to
+ * wait for server reply to finish local converting process so this request
+ * is made asynchronous.
+ *
+ */
+int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
+{
+	struct ldlm_request *body;
+	struct ptlrpc_request *req;
+	struct ldlm_async_args *aa;
+	struct obd_export *exp = lock->l_conn_export;
+
+	if (!exp) {
+		LDLM_ERROR(lock, "convert must not be called on local locks.");
+		return -EINVAL;
+	}
+
+	if (lock->l_resource->lr_type != LDLM_IBITS) {
+		LDLM_ERROR(lock, "convert works with IBITS locks only.");
+		return -EINVAL;
+	}
+
+	LDLM_DEBUG(lock, "client-side convert");
+
+	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
+					&RQF_LDLM_CONVERT, LUSTRE_DLM_VERSION,
+					LDLM_CONVERT);
+	if (!req)
+		return -ENOMEM;
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
+	body->lock_handle[0] = lock->l_remote_handle;
+
+	body->lock_desc.l_req_mode = lock->l_req_mode;
+	body->lock_desc.l_granted_mode = lock->l_granted_mode;
+
+	body->lock_desc.l_policy_data.l_inodebits.bits =
+					lock->l_policy_data.l_inodebits.bits;
+	body->lock_desc.l_policy_data.l_inodebits.cancel_bits = 0;
+
+	body->lock_flags = ldlm_flags_to_wire(*flags);
+	body->lock_count = 1;
+
+	ptlrpc_request_set_replen(req);
+
+	/* That could be useful to use cancel portals for convert as well
+	 * as high-priority handling. This will require changes in
+	 * ldlm_cancel_handler to understand convert RPC as well.
+	 *
+	 * req->rq_request_portal = LDLM_CANCEL_REQUEST_PORTAL;
+	 * req->rq_reply_portal = LDLM_CANCEL_REPLY_PORTAL;
+	 */
+	ptlrpc_at_set_req_timeout(req);
+
+	if (exp->exp_obd->obd_svc_stats)
+		lprocfs_counter_incr(exp->exp_obd->obd_svc_stats,
+				     LDLM_CONVERT - LDLM_FIRST_OPC);
+
+	aa = ptlrpc_req_async_args(aa, req);
+	ldlm_lock2handle(lock, &aa->lock_handle);
+	req->rq_interpret_reply = (ptlrpc_interpterer_t)lock_convert_interpret;
+
+	ptlrpcd_add_req(req);
+	return 0;
+}
+
+/**
  * Cancel locks locally.
  *
  * Returns:	LDLM_FL_LOCAL_ONLY if there is no need for a CANCEL RPC
@@ -1057,6 +1228,19 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		return 0;
 	}
 
+	/* Convert lock bits instead of cancel for IBITS locks */
+	if (cancel_flags & LCF_CONVERT) {
+		LASSERT(lock->l_resource->lr_type == LDLM_IBITS);
+		LASSERT(lock->l_policy_data.l_inodebits.cancel_bits != 0);
+
+		rc = ldlm_cli_dropbits(lock,
+				lock->l_policy_data.l_inodebits.cancel_bits);
+		if (rc == 0) {
+			LDLM_LOCK_RELEASE(lock);
+			return 0;
+		}
+	}
+
 	lock_res_and_lock(lock);
 	/* Lock is being canceled and the caller doesn't want to wait */
 	if (ldlm_is_canceling(lock)) {
@@ -1069,6 +1253,15 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		return 0;
 	}
 
+	/* Lock is being converted, cancel it immediately.
+	 * When convert will end, it releases lock and it will be gone.
+	 */
+	if (ldlm_is_converting(lock)) {
+		/* set back flags removed by convert */
+		ldlm_set_cbpending(lock);
+		ldlm_set_bl_ast(lock);
+	}
+
 	ldlm_set_canceling(lock);
 	unlock_res_and_lock(lock);
 
@@ -1439,7 +1632,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			/* Somebody is already doing CANCEL. No need for this
 			 * lock in LRU, do not traverse it again.
 			 */
-			if (!ldlm_is_canceling(lock))
+			if (!ldlm_is_canceling(lock) ||
+			    !ldlm_is_converting(lock))
 				break;
 
 			ldlm_lock_remove_from_lru_nolock(lock);
@@ -1483,7 +1677,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 		lock_res_and_lock(lock);
 		/* Check flags again under the lock. */
-		if (ldlm_is_canceling(lock) ||
+		if (ldlm_is_canceling(lock) || ldlm_is_converting(lock) ||
 		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
 			/* Another thread is removing lock from LRU, or
 			 * somebody is already doing CANCEL, or there
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 1b5e270..8b1a1ca 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -213,184 +213,261 @@ int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 	return rc;
 }
 
-int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
-		       void *data, int flag)
+void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 {
-	struct lustre_handle lockh;
+	struct inode *inode = ll_inode_from_resource_lock(lock);
+	u64 bits = to_cancel;
 	int rc;
 
-	switch (flag) {
-	case LDLM_CB_BLOCKING:
-		ldlm_lock2handle(lock, &lockh);
-		rc = ldlm_cli_cancel(&lockh, LCF_ASYNC);
-		if (rc < 0) {
-			CDEBUG(D_INODE, "ldlm_cli_cancel: rc = %d\n", rc);
-			return rc;
-		}
-		break;
-	case LDLM_CB_CANCELING: {
-		struct inode *inode = ll_inode_from_resource_lock(lock);
-		u64 bits = lock->l_policy_data.l_inodebits.bits;
+	if (!inode)
+		return;
 
-		if (!inode)
-			break;
+	if (!fid_res_name_eq(ll_inode2fid(inode),
+			     &lock->l_resource->lr_name)) {
+		LDLM_ERROR(lock,
+			   "data mismatch with object " DFID "(%p)",
+			   PFID(ll_inode2fid(inode)), inode);
+		LBUG();
+	}
 
-		/* Invalidate all dentries associated with this inode */
-		LASSERT(ldlm_is_canceling(lock));
+	if (bits & MDS_INODELOCK_XATTR) {
+		if (S_ISDIR(inode->i_mode))
+			ll_i2info(inode)->lli_def_stripe_offset = -1;
+		ll_xattr_cache_destroy(inode);
+		bits &= ~MDS_INODELOCK_XATTR;
+	}
 
-		if (!fid_res_name_eq(ll_inode2fid(inode),
-				     &lock->l_resource->lr_name)) {
-			LDLM_ERROR(lock,
-				   "data mismatch with object " DFID "(%p)",
-				   PFID(ll_inode2fid(inode)), inode);
+	/* For OPEN locks we differentiate between lock modes
+	 * LCK_CR, LCK_CW, LCK_PR - bug 22891
+	 */
+	if (bits & MDS_INODELOCK_OPEN)
+		ll_have_md_lock(inode, &bits, lock->l_req_mode);
+
+	if (bits & MDS_INODELOCK_OPEN) {
+		fmode_t fmode;
+
+		switch (lock->l_req_mode) {
+		case LCK_CW:
+			fmode = FMODE_WRITE;
+			break;
+		case LCK_PR:
+			fmode = FMODE_EXEC;
+			break;
+		case LCK_CR:
+			fmode = FMODE_READ;
+			break;
+		default:
+			LDLM_ERROR(lock, "bad lock mode for OPEN lock");
 			LBUG();
 		}
 
-		if (bits & MDS_INODELOCK_XATTR) {
-			if (S_ISDIR(inode->i_mode))
-				ll_i2info(inode)->lli_def_stripe_offset = -1;
-			ll_xattr_cache_destroy(inode);
-			bits &= ~MDS_INODELOCK_XATTR;
-		}
+		ll_md_real_close(inode, fmode);
 
-		/* For OPEN locks we differentiate between lock modes
-		 * LCK_CR, LCK_CW, LCK_PR - bug 22891
-		 */
-		if (bits & MDS_INODELOCK_OPEN)
-			ll_have_md_lock(inode, &bits, lock->l_req_mode);
-
-		if (bits & MDS_INODELOCK_OPEN) {
-			fmode_t fmode;
-
-			switch (lock->l_req_mode) {
-			case LCK_CW:
-				fmode = FMODE_WRITE;
-				break;
-			case LCK_PR:
-				fmode = FMODE_EXEC;
-				break;
-			case LCK_CR:
-				fmode = FMODE_READ;
-				break;
-			default:
-				LDLM_ERROR(lock, "bad lock mode for OPEN lock");
-				LBUG();
-			}
+		bits &= ~MDS_INODELOCK_OPEN;
+	}
 
-			ll_md_real_close(inode, fmode);
-		}
+	if (bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE |
+		    MDS_INODELOCK_LAYOUT | MDS_INODELOCK_PERM |
+		    MDS_INODELOCK_DOM))
+		ll_have_md_lock(inode, &bits, LCK_MINMODE);
+
+	if (bits & MDS_INODELOCK_DOM) {
+		rc = ll_dom_lock_cancel(inode, lock);
+		if (rc < 0)
+			CDEBUG(D_INODE, "cannot flush DoM data "
+			       DFID": rc = %d\n",
+			       PFID(ll_inode2fid(inode)), rc);
+		lock_res_and_lock(lock);
+		ldlm_set_kms_ignore(lock);
+		unlock_res_and_lock(lock);
+	}
 
-		if (bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE |
-			    MDS_INODELOCK_LAYOUT | MDS_INODELOCK_PERM |
-			    MDS_INODELOCK_DOM))
-			ll_have_md_lock(inode, &bits, LCK_MINMODE);
-
-		if (bits & MDS_INODELOCK_DOM) {
-			rc =  ll_dom_lock_cancel(inode, lock);
-			if (rc < 0)
-				CDEBUG(D_INODE, "cannot flush DoM data "
-				       DFID": rc = %d\n",
-				       PFID(ll_inode2fid(inode)), rc);
-			lock_res_and_lock(lock);
-			ldlm_set_kms_ignore(lock);
-			unlock_res_and_lock(lock);
-			bits &= ~MDS_INODELOCK_DOM;
-		}
+	if (bits & MDS_INODELOCK_LAYOUT) {
+		struct cl_object_conf conf = {
+			.coc_opc = OBJECT_CONF_INVALIDATE,
+			.coc_inode = inode,
+		};
 
-		if (bits & MDS_INODELOCK_LAYOUT) {
-			struct cl_object_conf conf = {
-				.coc_opc = OBJECT_CONF_INVALIDATE,
-				.coc_inode = inode,
-			};
-
-			rc = ll_layout_conf(inode, &conf);
-			if (rc < 0)
-				CDEBUG(D_INODE, "cannot invalidate layout of "
-				       DFID ": rc = %d\n",
-				       PFID(ll_inode2fid(inode)), rc);
-		}
+		rc = ll_layout_conf(inode, &conf);
+		if (rc < 0)
+			CDEBUG(D_INODE, "cannot invalidate layout of "
+			       DFID ": rc = %d\n",
+			       PFID(ll_inode2fid(inode)), rc);
+	}
 
-		if (bits & MDS_INODELOCK_UPDATE) {
-			set_bit(LLIF_UPDATE_ATIME,
-				&ll_i2info(inode)->lli_flags);
-		}
+	if (bits & MDS_INODELOCK_UPDATE)
+		set_bit(LLIF_UPDATE_ATIME,
+			&ll_i2info(inode)->lli_flags);
 
-		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
-			struct ll_inode_info *lli = ll_i2info(inode);
+	if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
+		struct ll_inode_info *lli = ll_i2info(inode);
 
-			CDEBUG(D_INODE,
-			       "invalidating inode " DFID " lli = %p, pfid  = " DFID "\n",
-			       PFID(ll_inode2fid(inode)), lli,
-			       PFID(&lli->lli_pfid));
+		CDEBUG(D_INODE,
+		       "invalidating inode "DFID" lli = %p, pfid  = "DFID"\n",
+		       PFID(ll_inode2fid(inode)),
+		       lli, PFID(&lli->lli_pfid));
+		truncate_inode_pages(inode->i_mapping, 0);
 
-			truncate_inode_pages(inode->i_mapping, 0);
+		if (unlikely(!fid_is_zero(&lli->lli_pfid))) {
+			struct inode *master_inode = NULL;
+			unsigned long hash;
 
-			if (unlikely(!fid_is_zero(&lli->lli_pfid))) {
-				struct inode *master_inode = NULL;
-				unsigned long hash;
+			/*
+			 * This is slave inode, since all of the child dentry
+			 * is connected on the master inode, so we have to
+			 * invalidate the negative children on master inode
+			 */
+			CDEBUG(D_INODE,
+			       "Invalidate s" DFID " m" DFID "\n",
+			       PFID(ll_inode2fid(inode)), PFID(&lli->lli_pfid));
 
-				/*
-				 * This is slave inode, since all of the child
-				 * dentry is connected on the master inode, so
-				 * we have to invalidate the negative children
-				 * on master inode
-				 */
-				CDEBUG(D_INODE,
-				       "Invalidate s" DFID " m" DFID "\n",
-				       PFID(ll_inode2fid(inode)),
-				       PFID(&lli->lli_pfid));
-
-				hash = cl_fid_build_ino(&lli->lli_pfid,
-							ll_need_32bit_api(ll_i2sbi(inode)));
-				/*
-				 * Do not lookup the inode with ilookup5,
-				 * otherwise it will cause dead lock,
-				 *
-				 * 1. Client1 send chmod req to the MDT0, then
-				 * on MDT0, it enqueues master and all of its
-				 * slaves lock, (mdt_attr_set() ->
-				 * mdt_lock_slaves()), after gets master and
-				 * stripe0 lock, it will send the enqueue req
-				 * (for stripe1) to MDT1, then MDT1 finds the
-				 * lock has been granted to client2. Then MDT1
-				 * sends blocking ast to client2.
-				 *
-				 * 2. At the same time, client2 tries to unlink
-				 * the striped dir (rm -rf striped_dir), and
-				 * during lookup, it will hold the master inode
-				 * of the striped directory, whose inode state
-				 * is NEW, then tries to revalidate all of its
-				 * slaves, (ll_prep_inode()->ll_iget()->
-				 * ll_read_inode2()-> ll_update_inode().). And
-				 * it will be blocked on the server side because
-				 * of 1.
-				 *
-				 * 3. Then the client get the blocking_ast req,
-				 * cancel the lock, but being blocked if using
-				 * ->ilookup5()), because master inode state is
-				 *  NEW.
-				 */
-				master_inode = ilookup5_nowait(inode->i_sb,
-							       hash,
-							       ll_test_inode_by_fid,
-							       (void *)&lli->lli_pfid);
-				if (master_inode) {
-					ll_invalidate_negative_children(master_inode);
-					iput(master_inode);
-				}
-			} else {
-				ll_invalidate_negative_children(inode);
+			hash = cl_fid_build_ino(&lli->lli_pfid,
+						ll_need_32bit_api(
+							ll_i2sbi(inode)));
+			/*
+			 * Do not lookup the inode with ilookup5, otherwise
+			 * it will cause dead lock,
+			 * 1. Client1 send chmod req to the MDT0, then on MDT0,
+			 * it enqueues master and all of its slaves lock,
+			 * (mdt_attr_set() -> mdt_lock_slaves()), after gets
+			 * master and stripe0 lock, it will send the enqueue
+			 * req (for stripe1) to MDT1, then MDT1 finds the lock
+			 * has been granted to client2. Then MDT1 sends blocking
+			 * ast to client2.
+			 * 2. At the same time, client2 tries to unlink
+			 * the striped dir (rm -rf striped_dir), and during
+			 * lookup, it will hold the master inode of the striped
+			 * directory, whose inode state is NEW, then tries to
+			 * revalidate all of its slaves, (ll_prep_inode()->
+			 * ll_iget()->ll_read_inode2()-> ll_update_inode().).
+			 * And it will be blocked on the server side because
+			 * of 1.
+			 * 3. Then the client get the blocking_ast req, cancel
+			 * the lock, but being blocked if using ->ilookup5()),
+			 * because master inode state is NEW.
+			 */
+			master_inode = ilookup5_nowait(inode->i_sb, hash,
+							ll_test_inode_by_fid,
+							(void *)&lli->lli_pfid);
+			if (master_inode) {
+				ll_invalidate_negative_children(master_inode);
+				iput(master_inode);
 			}
+		} else {
+			ll_invalidate_negative_children(inode);
 		}
+	}
 
-		if ((bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM)) &&
-		    inode->i_sb->s_root &&
-		    !is_root_inode(inode))
-			ll_invalidate_aliases(inode);
+	if ((bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM)) &&
+	    inode->i_sb->s_root &&
+	    !is_root_inode(inode))
+		ll_invalidate_aliases(inode);
 
-		iput(inode);
+	iput(inode);
+}
+
+/* Check if the given lock may be downgraded instead of canceling and
+ * that convert is really needed.
+ */
+int ll_md_need_convert(struct ldlm_lock *lock)
+{
+	struct inode *inode;
+	u64 wanted = lock->l_policy_data.l_inodebits.cancel_bits;
+	u64 bits = lock->l_policy_data.l_inodebits.bits & ~wanted;
+	enum ldlm_mode mode = LCK_MINMODE;
+
+	if (!wanted || !bits || ldlm_is_cancel(lock))
+		return 0;
+
+	/* do not convert locks other than DOM for now */
+	if (!((bits | wanted) & MDS_INODELOCK_DOM))
+		return 0;
+
+	/* We may have already remaining bits in some other lock so
+	 * lock convert will leave us just extra lock for the same bit.
+	 * Check if client has other lock with the same bits and the same
+	 * or lower mode and don't convert if any.
+	 */
+	switch (lock->l_req_mode) {
+	case LCK_PR:
+		mode = LCK_PR;
+		/* fall-through */
+	case LCK_PW:
+		mode |= LCK_CR;
+		break;
+	case LCK_CW:
+		mode = LCK_CW;
+		/* fall-through */
+	case LCK_CR:
+		mode |= LCK_CR;
 		break;
+	default:
+		/* do not convert other modes */
+		return 0;
 	}
+
+	/* is lock is too old to be converted? */
+	lock_res_and_lock(lock);
+	if (ktime_after(ktime_get(),
+			ktime_add(lock->l_last_used,
+				  ktime_set(10, 0)))) {
+		unlock_res_and_lock(lock);
+		return 0;
+	}
+	unlock_res_and_lock(lock);
+
+	inode = ll_inode_from_resource_lock(lock);
+	ll_have_md_lock(inode, &bits, mode);
+	iput(inode);
+	return !!(bits);
+}
+
+int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
+		       void *data, int flag)
+{
+	struct lustre_handle lockh;
+	u64 bits = lock->l_policy_data.l_inodebits.bits;
+	int rc;
+
+	switch (flag) {
+	case LDLM_CB_BLOCKING:
+	{
+		u64 cancel_flags = LCF_ASYNC;
+
+		if (ll_md_need_convert(lock)) {
+			cancel_flags |= LCF_CONVERT;
+			/* For lock convert some cancel actions may require
+			 * this lock with non-dropped canceled bits, e.g. page
+			 * flush for DOM lock. So call ll_lock_cancel_bits()
+			 * here while canceled bits are still set.
+			 */
+			bits = lock->l_policy_data.l_inodebits.cancel_bits;
+			if (bits & MDS_INODELOCK_DOM)
+				ll_lock_cancel_bits(lock, MDS_INODELOCK_DOM);
+		}
+		ldlm_lock2handle(lock, &lockh);
+		rc = ldlm_cli_cancel(&lockh, cancel_flags);
+		if (rc < 0) {
+			CDEBUG(D_INODE, "ldlm_cli_cancel: rc = %d\n", rc);
+			return rc;
+		}
+		break;
+	}
+	case LDLM_CB_CANCELING:
+		if (ldlm_is_converting(lock)) {
+			/* this is called on already converted lock, so
+			 * ibits has remained bits only and cancel_bits
+			 * are bits that were dropped.
+			 * Note that DOM lock is handled prior lock convert
+			 * and is excluded here.
+			 */
+			bits = lock->l_policy_data.l_inodebits.cancel_bits &
+				~MDS_INODELOCK_DOM;
+		} else {
+			LASSERT(ldlm_is_canceling(lock));
+		}
+		ll_lock_cancel_bits(lock, bits);
+		break;
 	default:
 		LBUG();
 	}
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index c92663b..b14d301c 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -3027,7 +3027,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct ldlm_extent *)0)->gid));
 
 	/* Checks for struct ldlm_inodebits */
-	LASSERTF((int)sizeof(struct ldlm_inodebits) == 8, "found %lld\n",
+	LASSERTF((int)sizeof(struct ldlm_inodebits) == 16, "found %lld\n",
 		 (long long)(int)sizeof(struct ldlm_inodebits));
 	LASSERTF((int)offsetof(struct ldlm_inodebits, bits) == 0, "found %lld\n",
 		 (long long)(int)offsetof(struct ldlm_inodebits, bits));
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 794e6d6..2403b89 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2120,6 +2120,7 @@ static inline bool ldlm_extent_equal(const struct ldlm_extent *ex1,
 
 struct ldlm_inodebits {
 	__u64 bits;
+	__u64 cancel_bits; /* for lock convert */
 };
 
 struct ldlm_flock_wire {
-- 
1.8.3.1
