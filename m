From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:00 -0500
Subject: [lustre-devel] [PATCH 252/622] lustre: ldlm: Fix style issues for
 ldlm_request.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-253-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ldlm/ldlm_request.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 3a56c0e5f42f ("LU-6142 ldlm: Fix style issues for ldlm_request.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34547
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 144 +++++++++++++++++++++++++++---------------
 1 file changed, 94 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index fb564f4..45d70d4 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -147,7 +147,8 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
  *
  * Return:	timeout in seconds to wait for the server reply
  */
-/* We use the same basis for both server side and client side functions
+/*
+ * We use the same basis for both server side and client side functions
  * from a single node.
  */
 static time64_t ldlm_cp_timeout(struct ldlm_lock *lock)
@@ -289,13 +290,14 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 {
 	int need_cancel = 0;
 
-	/* Set a flag to prevent us from sending a CANCEL (bug 407) */
+	/* Set a flag to prevent us from sending a CANCEL (b=407) */
 	lock_res_and_lock(lock);
 	/* Check that lock is not granted or failed, we might race. */
 	if (!ldlm_is_granted(lock) && !ldlm_is_failed(lock)) {
-		/* Make sure that this lock will not be found by raced
+		/*
+		 * Make sure that this lock will not be found by raced
 		 * bl_ast and -EINVAL reply is sent to server anyways.
-		 * bug 17645
+		 * b=17645
 		 */
 		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_FAILED |
 				 LDLM_FL_ATOMIC_CB | LDLM_FL_CBPENDING;
@@ -309,10 +311,12 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 	else
 		LDLM_DEBUG(lock, "lock was granted or failed in race");
 
-	/* XXX - HACK because we shouldn't call ldlm_lock_destroy()
+	/*
+	 * XXX - HACK because we shouldn't call ldlm_lock_destroy()
 	 *       from llite/file.c/ll_file_flock().
 	 */
-	/* This code makes for the fact that we do not have blocking handler on
+	/*
+	 * This code makes for the fact that we do not have blocking handler on
 	 * a client for flock locks. As such this is the place where we must
 	 * completely kill failed locks. (interrupted and those that
 	 * were waiting to be granted when server evicted us.
@@ -416,7 +420,8 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	CDEBUG(D_INFO, "local: %p, remote cookie: %#llx, flags: 0x%llx\n",
 	       lock, reply->lock_handle.cookie, *flags);
 
-	/* If enqueue returned a blocked lock but the completion handler has
+	/*
+	 * If enqueue returned a blocked lock but the completion handler has
 	 * already run, then it fixed up the resource and we don't need to do it
 	 * again.
 	 */
@@ -466,11 +471,13 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		LDLM_DEBUG(lock, "enqueue reply includes blocking AST");
 	}
 
-	/* If the lock has already been granted by a completion AST, don't
+	/*
+	 * If the lock has already been granted by a completion AST, don't
 	 * clobber the LVB with an older one.
 	 */
 	if (lvb_len > 0) {
-		/* We must lock or a racing completion might update lvb without
+		/*
+		 * We must lock or a racing completion might update lvb without
 		 * letting us know and we'll clobber the correct value.
 		 * Cannot unlock after the check either, as that still leaves
 		 * a tiny window for completion to get in
@@ -499,7 +506,8 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	}
 
 	if (lvb_len > 0 && lvb) {
-		/* Copy the LVB here, and not earlier, because the completion
+		/*
+		 * Copy the LVB here, and not earlier, because the completion
 		 * AST (if any) can override what we got in the reply
 		 */
 		memcpy(lvb, lock->l_lvb_data, lvb_len);
@@ -586,7 +594,8 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		to_free = !ns_connect_lru_resize(ns) &&
 			  opc == LDLM_ENQUEUE ? 1 : 0;
 
-		/* Cancel LRU locks here _only_ if the server supports
+		/*
+		 * Cancel LRU locks here _only_ if the server supports
 		 * EARLY_CANCEL. Otherwise we have to send extra CANCEL
 		 * RPC, which will make us slower.
 		 */
@@ -611,7 +620,8 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		if (canceloff) {
 			dlm = req_capsule_client_get(pill, &RMF_DLM_REQ);
 			LASSERT(dlm);
-			/* Skip first lock handler in ldlm_request_pack(),
+			/*
+			 * Skip first lock handler in ldlm_request_pack(),
 			 * this method will increment @lock_count according
 			 * to the lock handle amount actually written to
 			 * the buffer.
@@ -685,7 +695,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 	ns = exp->exp_obd->obd_namespace;
 
-	/* If we're replaying this lock, just check some invariants.
+	/*
+	 * If we're replaying this lock, just check some invariants.
 	 * If we're creating a new lock, get everything all setup nicely.
 	 */
 	if (is_replay) {
@@ -752,7 +763,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	if (*flags & LDLM_FL_NDELAY) {
 		DEBUG_REQ(D_DLMTRACE, req, "enque lock with no delay\n");
 		req->rq_no_resend = req->rq_no_delay = 1;
-		/* probably set a shorter timeout value and handle ETIMEDOUT
+		/*
+		 * probably set a shorter timeout value and handle ETIMEDOUT
 		 * in osc_lock_upcall() correctly
 		 */
 		/* lustre_msg_set_timeout(req, req->rq_timeout / 2); */
@@ -799,7 +811,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 				    einfo->ei_mode, flags, lvb, lvb_len,
 				    lockh, rc);
 
-	/* If ldlm_cli_enqueue_fini did not find the lock, we need to free
+	/*
+	 * If ldlm_cli_enqueue_fini did not find the lock, we need to free
 	 * one reference that we took
 	 */
 	if (err == -ENOLCK)
@@ -860,7 +873,8 @@ static int lock_convert_interpret(const struct lu_env *env,
 	}
 
 	lock_res_and_lock(lock);
-	/* Lock convert is sent for any new bits to drop, the converting flag
+	/*
+	 * Lock convert is sent for any new bits to drop, the converting flag
 	 * is dropped when ibits on server are the same as on client. Meanwhile
 	 * that can be so that more later convert will be replied first with
 	 * and clear converting flag, so in case of such race just exit here.
@@ -872,7 +886,8 @@ static int lock_convert_interpret(const struct lu_env *env,
 			   reply->lock_desc.l_policy_data.l_inodebits.bits);
 	} else if (reply->lock_desc.l_policy_data.l_inodebits.bits !=
 		   lock->l_policy_data.l_inodebits.bits) {
-		/* Compare server returned lock ibits and local lock ibits
+		/*
+		 * Compare server returned lock ibits and local lock ibits
 		 * if they are the same we consider conversion is done,
 		 * otherwise we have more converts inflight and keep
 		 * converting flag.
@@ -882,14 +897,16 @@ static int lock_convert_interpret(const struct lu_env *env,
 	} else {
 		ldlm_clear_converting(lock);
 
-		/* Concurrent BL AST may arrive and cause another convert
+		/*
+		 * Concurrent BL AST may arrive and cause another convert
 		 * or cancel so just do nothing here if bl_ast is set,
 		 * finish with convert otherwise.
 		 */
 		if (!ldlm_is_bl_ast(lock)) {
 			struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 
-			/* Drop cancel_bits since there are no more converts
+			/*
+			 * Drop cancel_bits since there are no more converts
 			 * and put lock into LRU if it is still not used and
 			 * is not there yet.
 			 */
@@ -918,7 +935,8 @@ static int lock_convert_interpret(const struct lu_env *env,
 		}
 		unlock_res_and_lock(lock);
 
-		/* fallback to normal lock cancel. If rc means there is no
+		/*
+		 * fallback to normal lock cancel. If rc means there is no
 		 * valid lock on server, do only local cancel
 		 */
 		if (rc == ELDLM_NO_LOCK_DATA)
@@ -959,7 +977,8 @@ int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
 		return -EINVAL;
 	}
 
-	/* this is better to check earlier and it is done so already,
+	/*
+	 * this is better to check earlier and it is done so already,
 	 * but this check is kept too as final one to issue an error
 	 * if any new code will miss such check.
 	 */
@@ -1075,7 +1094,8 @@ static void ldlm_cancel_pack(struct ptlrpc_request *req,
 	max += LDLM_LOCKREQ_HANDLES;
 	LASSERT(max >= dlm->lock_count + count);
 
-	/* XXX: it would be better to pack lock handles grouped by resource.
+	/*
+	 * XXX: it would be better to pack lock handles grouped by resource.
 	 * so that the server cancel would call filter_lvbo_update() less
 	 * frequently.
 	 */
@@ -1202,7 +1222,8 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 		return 0;
 	}
 
-	/* In some cases RPC may contain SLV and limit zeroed out. This
+	/*
+	 * In some cases RPC may contain SLV and limit zeroed out. This
 	 * is the case when server does not support LRU resize feature.
 	 * This is also possible in some recovery cases when server-side
 	 * reqs have no reference to the OBD export and thus access to
@@ -1221,7 +1242,8 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 	new_slv = lustre_msg_get_slv(req->rq_repmsg);
 	obd = req->rq_import->imp_obd;
 
-	/* Set new SLV and limit in OBD fields to make them accessible
+	/*
+	 * Set new SLV and limit in OBD fields to make them accessible
 	 * to the pool thread. We do not access obd_namespace and pool
 	 * directly here as there is no reliable way to make sure that
 	 * they are still alive at cleanup time. Evil races are possible
@@ -1281,7 +1303,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		return 0;
 	}
 
-	/* Lock is being converted, cancel it immediately.
+	/*
+	 * Lock is being converted, cancel it immediately.
 	 * When convert will end, it releases lock and it will be gone.
 	 */
 	if (ldlm_is_converting(lock)) {
@@ -1302,7 +1325,8 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 		LDLM_LOCK_RELEASE(lock);
 		return 0;
 	}
-	/* Even if the lock is marked as LDLM_FL_BL_AST, this is a LDLM_CANCEL
+	/*
+	 * Even if the lock is marked as LDLM_FL_BL_AST, this is a LDLM_CANCEL
 	 * RPC which goes to canceld portal, so we can cancel other LRU locks
 	 * here and send them all as one LDLM_CANCEL RPC.
 	 */
@@ -1350,7 +1374,8 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 		} else {
 			rc = ldlm_cli_cancel_local(lock);
 		}
-		/* Until we have compound requests and can send LDLM_CANCEL
+		/*
+		 * Until we have compound requests and can send LDLM_CANCEL
 		 * requests batched with generic RPCs, we need to send cancels
 		 * with the LDLM_FL_BL_AST flag in a separate RPC from
 		 * the one being generated now.
@@ -1387,7 +1412,8 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 {
 	enum ldlm_policy_res result = LDLM_POLICY_CANCEL_LOCK;
 
-	/* don't check added & count since we want to process all locks
+	/*
+	 * don't check added & count since we want to process all locks
 	 * from unused list.
 	 * It's fine to not take lock to access lock->l_resource since
 	 * the lock has already been granted so it won't change.
@@ -1424,7 +1450,8 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	u64 slv, lvf, lv;
 	s64 la;
 
-	/* Stop LRU processing when we reach past @count or have checked all
+	/*
+	 * Stop LRU processing when we reach past @count or have checked all
 	 * locks in LRU.
 	 */
 	if (count && added >= count)
@@ -1447,7 +1474,8 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	/* Inform pool about current CLV to see it via debugfs. */
 	ldlm_pool_set_clv(pl, lv);
 
-	/* Stop when SLV is not yet come from server or lv is smaller than
+	/*
+	 * Stop when SLV is not yet come from server or lv is smaller than
 	 * it is.
 	 */
 	if (slv == 0 || lv < slv)
@@ -1469,7 +1497,8 @@ static enum ldlm_policy_res ldlm_cancel_passed_policy(struct ldlm_namespace *ns,
 						      int unused, int added,
 						      int count)
 {
-	/* Stop LRU processing when we reach past @count or have checked all
+	/*
+	 * Stop LRU processing when we reach past @count or have checked all
 	 * locks in LRU.
 	 */
 	return (added >= count) ?
@@ -1538,7 +1567,8 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 ldlm_cancel_default_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 			   int unused, int added, int count)
 {
-	/* Stop LRU processing when we reach past count or have checked all
+	/*
+	 * Stop LRU processing when we reach past count or have checked all
 	 * locks in LRU.
 	 */
 	return (added >= count) ?
@@ -1652,7 +1682,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			    !ldlm_is_converting(lock))
 				break;
 
-			/* Somebody is already doing CANCEL. No need for this
+			/*
+			 * Somebody is already doing CANCEL. No need for this
 			 * lock in LRU, do not traverse it again.
 			 */
 			ldlm_lock_remove_from_lru_nolock(lock);
@@ -1668,7 +1699,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		spin_unlock(&ns->ns_lock);
 		lu_ref_add(&lock->l_reference, __func__, current);
 
-		/* Pass the lock through the policy filter and see if it
+		/*
+		 * Pass the lock through the policy filter and see if it
 		 * should stay in LRU.
 		 *
 		 * Even for shrinker policy we stop scanning if
@@ -1707,7 +1739,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		/* Check flags again under the lock. */
 		if (ldlm_is_canceling(lock) || ldlm_is_converting(lock) ||
 		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
-			/* Another thread is removing lock from LRU, or
+			/*
+			 * Another thread is removing lock from LRU, or
 			 * somebody is already doing CANCEL, or there
 			 * is a blocking request which will send cancel
 			 * by itself, or the lock is no longer unused or
@@ -1722,7 +1755,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		}
 		LASSERT(!lock->l_readers && !lock->l_writers);
 
-		/* If we have chosen to cancel this lock voluntarily, we
+		/*
+		 * If we have chosen to cancel this lock voluntarily, we
 		 * better send cancel notification to server, so that it
 		 * frees appropriate state. This might lead to a race
 		 * where while we are doing cancel here, server is also
@@ -1730,7 +1764,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 */
 		ldlm_clear_cancel_on_block(lock);
 
-		/* Setting the CBPENDING flag is a little misleading,
+		/*
+		 * Setting the CBPENDING flag is a little misleading,
 		 * but prevents an important race; namely, once
 		 * CBPENDING is set, the lock can accumulate no more
 		 * readers/writers. Since readers and writers are
@@ -1744,11 +1779,12 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		     ldlm_has_dom(lock)) && lock->l_granted_mode == LCK_PR)
 			ldlm_set_discard_data(lock);
 
-		/* We can't re-add to l_lru as it confuses the
+		/*
+		 * We can't re-add to l_lru as it confuses the
 		 * refcounting in ldlm_lock_remove_from_lru() if an AST
 		 * arrives after we drop lr_lock below. We use l_bl_ast
 		 * and can't use l_pending_chain as it is used both on
-		 * server and client nevertheless bug 5666 says it is
+		 * server and client nevertheless b=5666 says it is
 		 * used only on server
 		 */
 		LASSERT(list_empty(&lock->l_bl_ast));
@@ -1787,7 +1823,8 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 	LIST_HEAD(cancels);
 	int count, rc;
 
-	/* Just prepare the list of locks, do not actually cancel them yet.
+	/*
+	 * Just prepare the list of locks, do not actually cancel them yet.
 	 * Locks are cancelled later in a separate thread.
 	 */
 	count = ldlm_prepare_lru_list(ns, &cancels, nr, 0, flags);
@@ -1824,7 +1861,8 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 		if (lock->l_readers || lock->l_writers)
 			continue;
 
-		/* If somebody is already doing CANCEL, or blocking AST came,
+		/*
+		 * If somebody is already doing CANCEL, or blocking AST came,
 		 * skip this lock.
 		 */
 		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock) ||
@@ -1834,7 +1872,8 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 		if (lockmode_compat(lock->l_granted_mode, mode))
 			continue;
 
-		/* If policy is given and this is IBITS lock, add to list only
+		/*
+		 * If policy is given and this is IBITS lock, add to list only
 		 * those locks that match by policy.
 		 * Skip locks with DoM bit always to don't flush data.
 		 */
@@ -1878,7 +1917,8 @@ int ldlm_cli_cancel_list(struct list_head *cancels, int count,
 	if (list_empty(cancels) || count == 0)
 		return 0;
 
-	/* XXX: requests (both batched and not) could be sent in parallel.
+	/*
+	 * XXX: requests (both batched and not) could be sent in parallel.
 	 * Usually it is enough to have just 1 RPC, but it is possible that
 	 * there are too many locks to be cancelled in LRU or on a resource.
 	 * It would also speed up the case when the server does not support
@@ -2071,7 +2111,8 @@ static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
 				 ldlm_res_iter_helper, &helper, 0);
 }
 
-/* non-blocking function to manipulate a lock whose cb_data is being put away.
+/*
+ * non-blocking function to manipulate a lock whose cb_data is being put away.
  * return  0:  find no resource
  *       > 0:  must be LDLM_ITER_STOP/LDLM_ITER_CONTINUE.
  *       < 0:  errors
@@ -2108,8 +2149,9 @@ static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
 		 "lock %p next %p prev %p\n",
 		 lock, &lock->l_pending_chain.next,
 		 &lock->l_pending_chain.prev);
-	/* bug 9573: don't replay locks left after eviction, or
-	 * bug 17614: locks being actively cancelled. Get a reference
+	/*
+	 * b=9573: don't replay locks left after eviction, or
+	 * b=17614: locks being actively cancelled. Get a reference
 	 * on a lock so that it does not disappear under us (e.g. due to cancel)
 	 */
 	if (!(lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_BL_DONE))) {
@@ -2169,7 +2211,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	struct ldlm_request *body;
 	int flags;
 
-	/* Bug 11974: Do not replay a lock which is actively being canceled */
+	/* B=11974: Do not replay a lock which is actively being canceled */
 	if (ldlm_is_bl_done(lock)) {
 		LDLM_DEBUG(lock, "Not replaying canceled lock:");
 		return 0;
@@ -2226,10 +2268,11 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
 			     lock->l_lvb_len);
 	ptlrpc_request_set_replen(req);
-	/* notify the server we've replayed all requests.
+	/*
+	 * notify the server we've replayed all requests.
 	 * also, we mark the request to be put on a dedicated
 	 * queue to be processed after all request replayes.
-	 * bug 6063
+	 * b=6063
 	 */
 	lustre_msg_set_flags(req->rq_reqmsg, MSG_REQ_REPLAY_DONE);
 
@@ -2263,7 +2306,8 @@ static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
 	       "Dropping as many unused locks as possible before replay for namespace %s (%d)\n",
 	       ldlm_ns_name(ns), ns->ns_nr_unused);
 
-	/* We don't need to care whether or not LRU resize is enabled
+	/*
+	 * We don't need to care whether or not LRU resize is enabled
 	 * because the LDLM_LRU_FLAG_NO_WAIT policy doesn't use the
 	 * count parameter
 	 */
-- 
1.8.3.1
