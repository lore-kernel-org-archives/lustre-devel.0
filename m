From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:59 -0500
Subject: [lustre-devel] [PATCH 251/622] lustre: ldlm: Fix style issues for
 ldlm_lockd.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-252-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ldlm/ldlm_lockd.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 5275c82c67d9 ("LU-6142 ldlm: Fix style issues for ldlm_lockd.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34544
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 64 +++++++++++++++++++++++++++------------------
 1 file changed, 39 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index ea146aa..f37d8ef 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -80,7 +80,7 @@ struct ldlm_bl_pool {
 	/*
 	 * blp_prio_list is used for callbacks that should be handled
 	 * as a priority. It is used for LDLM_FL_DISCARD_DATA requests.
-	 * see bug 13843
+	 * see b=13843
 	 */
 	struct list_head	blp_prio_list;
 
@@ -126,22 +126,24 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 
 	/* set bits to cancel for this lock for possible lock convert */
 	if (lock->l_resource->lr_type == LDLM_IBITS) {
-		/* Lock description contains policy of blocking lock,
-		 * and its cancel_bits is used to pass conflicting bits.
-		 * NOTE: ld can be NULL or can be not NULL but zeroed if
-		 * passed from ldlm_bl_thread_blwi(), check below used bits
-		 * in ld to make sure it is valid description.
+		/*
+		 * Lock description contains policy of blocking lock, and its
+		 * cancel_bits is used to pass conflicting bits.  NOTE: ld can
+		 * be NULL or can be not NULL but zeroed if passed from
+		 * ldlm_bl_thread_blwi(), check below used bits in ld to make
+		 * sure it is valid description.
 		 *
-		 * If server may replace lock resource keeping the same cookie,
-		 * never use cancel bits from different resource, full cancel
-		 * is to be used.
+		 * If server may replace lock resource keeping the same
+		 * cookie, never use cancel bits from different resource, full
+		 * cancel is to be used.
 		 */
 		if (ld && ld->l_policy_data.l_inodebits.bits &&
 		    ldlm_res_eq(&ld->l_resource.lr_name,
 				&lock->l_resource->lr_name))
 			lock->l_policy_data.l_inodebits.cancel_bits =
 				ld->l_policy_data.l_inodebits.cancel_bits;
-		/* if there is no valid ld and lock is cbpending already
+		/*
+		 * If there is no valid ld and lock is cbpending already
 		 * then cancel_bits should be kept, otherwise it is zeroed.
 		 */
 		else if (!ldlm_is_cbpending(lock))
@@ -169,7 +171,7 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 	LDLM_LOCK_RELEASE(lock);
 }
 
-/**
+/*
  * Callback handler for receiving incoming completion ASTs.
  *
  * This only can happen on client side.
@@ -241,8 +243,10 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 		goto out;
 	}
 
-	/* If we receive the completion AST before the actual enqueue returned,
-	 * then we might need to switch lock modes, resources, or extents.
+	/*
+	 * If we receive the completion AST before the actual enqueue
+	 * returned, then we might need to switch lock modes, resources, or
+	 * extents.
 	 */
 	if (dlm_req->lock_desc.l_granted_mode != lock->l_req_mode) {
 		lock->l_req_mode = dlm_req->lock_desc.l_granted_mode;
@@ -260,7 +264,8 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	ldlm_resource_unlink_lock(lock);
 
 	if (dlm_req->lock_flags & LDLM_FL_AST_SENT) {
-		/* BL_AST locks are not needed in LRU.
+		/*
+		 * BL_AST locks are not needed in LRU.
 		 * Let ldlm_cancel_lru() be fast.
 		 */
 		ldlm_lock_remove_from_lru(lock);
@@ -374,7 +379,8 @@ static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
 
 	wake_up(&blp->blp_waitq);
 
-	/* can not check blwi->blwi_flags as blwi could be already freed in
+	/*
+	 * Can not check blwi->blwi_flags as blwi could be already freed in
 	 * LCF_ASYNC mode
 	 */
 	if (!(cancel_flags & LCF_ASYNC))
@@ -439,7 +445,8 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
 
 		rc = __ldlm_bl_to_thread(blwi, cancel_flags);
 	} else {
-		/* if it is synchronous call do minimum mem alloc, as it could
+		/*
+		 * If it is synchronous call do minimum mem alloc, as it could
 		 * be triggered from kernel shrinker
 		 */
 		struct ldlm_bl_work_item blwi;
@@ -535,7 +542,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	struct ldlm_lock *lock;
 	int rc;
 
-	/* Requests arrive in sender's byte order.  The ptlrpc service
+	/*
+	 * Requests arrive in sender's byte order.  The ptlrpc service
 	 * handler has already checked and, if necessary, byte-swapped the
 	 * incoming request message body, but I am responsible for the
 	 * message buffers.
@@ -596,7 +604,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		return 0;
 	}
 
-	/* Force a known safe race, send a cancel to the server for a lock
+	/*
+	 * Force a known safe race, send a cancel to the server for a lock
 	 * which the server has already started a blocking callback on.
 	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE) &&
@@ -626,7 +635,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	lock->l_flags |= ldlm_flags_from_wire(dlm_req->lock_flags &
 					      LDLM_FL_AST_MASK);
 	if (lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK) {
-		/* If somebody cancels lock and cache is already dropped,
+		/*
+		 * If somebody cancels lock and cache is already dropped,
 		 * or lock is failed before cp_ast received on client,
 		 * we can tell the server we have no lock. Otherwise, we
 		 * should send cancel after dropping the cache.
@@ -643,7 +653,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 					     &dlm_req->lock_handle[0]);
 			return 0;
 		}
-		/* BL_AST locks are not needed in LRU.
+		/*
+		 * BL_AST locks are not needed in LRU.
 		 * Let ldlm_cancel_lru() be fast.
 		 */
 		ldlm_lock_remove_from_lru(lock);
@@ -651,14 +662,15 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	}
 	unlock_res_and_lock(lock);
 
-	/* We want the ost thread to get this reply so that it can respond
+	/*
+	 * We want the ost thread to get this reply so that it can respond
 	 * to ost requests (write cache writeback) that might be triggered
 	 * in the callback.
 	 *
 	 * But we'd also like to be able to indicate in the reply that we're
 	 * cancelling right now, because it's unused, or have an intent result
-	 * in the reply, so we might have to push the responsibility for sending
-	 * the reply down into the AST handlers, alas.
+	 * in the reply, so we might have to push the responsibility for
+	 * sending the reply down into the AST handlers, alas.
 	 */
 
 	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
@@ -866,7 +878,8 @@ static int ldlm_bl_thread_main(void *arg)
 		if (rc == LDLM_ITER_STOP)
 			break;
 
-		/* If there are many namespaces, we will not sleep waiting for
+		/*
+		 * If there are many namespaces, we will not sleep waiting for
 		 * work, and must do a cond_resched to avoid holding the CPU
 		 * for too long
 		 */
@@ -1171,7 +1184,8 @@ void ldlm_exit(void)
 	if (ldlm_refcount)
 		CERROR("ldlm_refcount is %d in %s!\n", ldlm_refcount, __func__);
 	kmem_cache_destroy(ldlm_resource_slab);
-	/* ldlm_lock_put() use RCU to call ldlm_lock_free, so need call
+	/*
+	 * ldlm_lock_put() use RCU to call ldlm_lock_free, so need call
 	 * synchronize_rcu() to wait a grace period elapsed, so that
 	 * ldlm_lock_free() get a chance to be called.
 	 */
-- 
1.8.3.1
