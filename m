From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:20 -0400
Subject: [lustre-devel] [PATCH 10/32] staging/lustre/ldlm: Remove
	unimplemented lock conversion traces.
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Lock conversion is not really implemented, so let's stop
pretending here.
This removes ldlm_lock_convert, ldlm_cli_lock_convert
and ldlm_lock_downgrade.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   4 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 119 ---------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 101 -----------------
 3 files changed, 224 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 03eea32..bea526b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1228,9 +1228,6 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 			    struct lustre_handle *, int unref);
 ldlm_mode_t ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
 					__u64 *bits);
-struct ldlm_resource *ldlm_lock_convert(struct ldlm_lock *lock, int new_mode,
-					__u32 *flags);
-void ldlm_lock_downgrade(struct ldlm_lock *lock, int new_mode);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
 void ldlm_reprocess_all(struct ldlm_resource *res);
 void ldlm_reprocess_all_ns(struct ldlm_namespace *ns);
@@ -1332,7 +1329,6 @@ int ldlm_cli_enqueue_local(struct ldlm_namespace *ns,
 			   struct lustre_handle *lockh);
 int ldlm_server_ast(struct lustre_handle *lockh, struct ldlm_lock_desc *new,
 		    void *data, __u32 data_len);
-int ldlm_cli_convert(struct lustre_handle *, int new_mode, __u32 *flags);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
 int ldlm_cli_cancel(struct lustre_handle *lockh,
 		    ldlm_cancel_flags_t cancel_flags);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index b257b89..0597fec 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -2012,125 +2012,6 @@ struct export_cl_data {
 };
 
 /**
- * Downgrade an exclusive lock.
- *
- * A fast variant of ldlm_lock_convert for conversion of exclusive
- * locks. The conversion is always successful.
- * Used by Commit on Sharing (COS) code.
- *
- * \param lock A lock to convert
- * \param new_mode new lock mode
- */
-void ldlm_lock_downgrade(struct ldlm_lock *lock, int new_mode)
-{
-	LASSERT(lock->l_granted_mode & (LCK_PW | LCK_EX));
-	LASSERT(new_mode == LCK_COS);
-
-	lock_res_and_lock(lock);
-	ldlm_resource_unlink_lock(lock);
-	/*
-	 * Remove the lock from pool as it will be added again in
-	 * ldlm_grant_lock() called below.
-	 */
-	ldlm_pool_del(&ldlm_lock_to_ns(lock)->ns_pool, lock);
-
-	lock->l_req_mode = new_mode;
-	ldlm_grant_lock(lock, NULL);
-	unlock_res_and_lock(lock);
-	ldlm_reprocess_all(lock->l_resource);
-}
-EXPORT_SYMBOL(ldlm_lock_downgrade);
-
-/**
- * Attempt to convert already granted lock to a different mode.
- *
- * While lock conversion is not currently used, future client-side
- * optimizations could take advantage of it to avoid discarding cached
- * pages on a file.
- */
-struct ldlm_resource *ldlm_lock_convert(struct ldlm_lock *lock, int new_mode,
-					__u32 *flags)
-{
-	LIST_HEAD(rpc_list);
-	struct ldlm_resource *res;
-	struct ldlm_namespace *ns;
-	int granted = 0;
-	struct ldlm_interval *node;
-
-	/* Just return if mode is unchanged. */
-	if (new_mode == lock->l_granted_mode) {
-		*flags |= LDLM_FL_BLOCK_GRANTED;
-		return lock->l_resource;
-	}
-
-	/* I can't check the type of lock here because the bitlock of lock
-	 * is not held here, so do the allocation blindly. -jay */
-	OBD_SLAB_ALLOC_PTR_GFP(node, ldlm_interval_slab, GFP_NOFS);
-	if (node == NULL)
-		/* Actually, this causes EDEADLOCK to be returned */
-		return NULL;
-
-	LASSERTF((new_mode == LCK_PW && lock->l_granted_mode == LCK_PR),
-		 "new_mode %u, granted %u\n", new_mode, lock->l_granted_mode);
-
-	lock_res_and_lock(lock);
-
-	res = lock->l_resource;
-	ns  = ldlm_res_to_ns(res);
-
-	lock->l_req_mode = new_mode;
-	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS) {
-		ldlm_resource_unlink_lock(lock);
-	} else {
-		ldlm_resource_unlink_lock(lock);
-		if (res->lr_type == LDLM_EXTENT) {
-			/* FIXME: ugly code, I have to attach the lock to a
-			 * interval node again since perhaps it will be granted
-			 * soon */
-			INIT_LIST_HEAD(&node->li_group);
-			ldlm_interval_attach(node, lock);
-			node = NULL;
-		}
-	}
-
-	/*
-	 * Remove old lock from the pool before adding the lock with new
-	 * mode below in ->policy()
-	 */
-	ldlm_pool_del(&ns->ns_pool, lock);
-
-	/* If this is a local resource, put it on the appropriate list. */
-	if (ns_is_client(ldlm_res_to_ns(res))) {
-		if (*flags & (LDLM_FL_BLOCK_CONV | LDLM_FL_BLOCK_GRANTED)) {
-			ldlm_resource_add_lock(res, &res->lr_converting, lock);
-		} else {
-			/* This should never happen, because of the way the
-			 * server handles conversions. */
-			LDLM_ERROR(lock, "Erroneous flags %x on local lock\n",
-				   *flags);
-			LBUG();
-
-			ldlm_grant_lock(lock, &rpc_list);
-			granted = 1;
-			/* FIXME: completion handling not with lr_lock held ! */
-			if (lock->l_completion_ast)
-				lock->l_completion_ast(lock, 0, NULL);
-		}
-	} else {
-		CERROR("This is client-side-only module, cannot handle LDLM_NAMESPACE_SERVER resource type lock.\n");
-		LBUG();
-	}
-	unlock_res_and_lock(lock);
-
-	if (granted)
-		ldlm_run_ast_work(ns, &rpc_list, LDLM_WORK_CP_AST);
-	if (node)
-		OBD_SLAB_FREE(node, ldlm_interval_slab, sizeof(*node));
-	return res;
-}
-EXPORT_SYMBOL(ldlm_lock_convert);
-
-/**
  * Print lock with lock handle \a lockh description into debug log.
  *
  * Used when printing all locks on a resource for debug purposes.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f6d61e5..5bd66c3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -974,107 +974,6 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 }
 EXPORT_SYMBOL(ldlm_cli_enqueue);
 
-static int ldlm_cli_convert_local(struct ldlm_lock *lock, int new_mode,
-				  __u32 *flags)
-{
-	struct ldlm_resource *res;
-	int rc;
-
-	if (ns_is_client(ldlm_lock_to_ns(lock))) {
-		CERROR("Trying to cancel local lock\n");
-		LBUG();
-	}
-	LDLM_DEBUG(lock, "client-side local convert");
-
-	res = ldlm_lock_convert(lock, new_mode, flags);
-	if (res) {
-		ldlm_reprocess_all(res);
-		rc = 0;
-	} else {
-		rc = LUSTRE_EDEADLK;
-	}
-	LDLM_DEBUG(lock, "client-side local convert handler END");
-	LDLM_LOCK_PUT(lock);
-	return rc;
-}
-
-/* FIXME: one of ldlm_cli_convert or the server side should reject attempted
- * conversion of locks which are on the waiting or converting queue */
-/* Caller of this code is supposed to take care of lock readers/writers
-   accounting */
-int ldlm_cli_convert(struct lustre_handle *lockh, int new_mode, __u32 *flags)
-{
-	struct ldlm_request   *body;
-	struct ldlm_reply     *reply;
-	struct ldlm_lock      *lock;
-	struct ldlm_resource  *res;
-	struct ptlrpc_request *req;
-	int		    rc;
-
-	lock = ldlm_handle2lock(lockh);
-	if (!lock) {
-		LBUG();
-		return -EINVAL;
-	}
-	*flags = 0;
-
-	if (lock->l_conn_export == NULL)
-		return ldlm_cli_convert_local(lock, new_mode, flags);
-
-	LDLM_DEBUG(lock, "client-side convert");
-
-	req = ptlrpc_request_alloc_pack(class_exp2cliimp(lock->l_conn_export),
-					&RQF_LDLM_CONVERT, LUSTRE_DLM_VERSION,
-					LDLM_CONVERT);
-	if (req == NULL) {
-		LDLM_LOCK_PUT(lock);
-		return -ENOMEM;
-	}
-
-	body = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	body->lock_handle[0] = lock->l_remote_handle;
-
-	body->lock_desc.l_req_mode = new_mode;
-	body->lock_flags = ldlm_flags_to_wire(*flags);
-
-
-	ptlrpc_request_set_replen(req);
-	rc = ptlrpc_queue_wait(req);
-	if (rc != ELDLM_OK)
-		goto out;
-
-	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	if (reply == NULL) {
-		rc = -EPROTO;
-		goto out;
-	}
-
-	if (req->rq_status) {
-		rc = req->rq_status;
-		goto out;
-	}
-
-	res = ldlm_lock_convert(lock, new_mode, &reply->lock_flags);
-	if (res != NULL) {
-		ldlm_reprocess_all(res);
-		/* Go to sleep until the lock is granted. */
-		/* FIXME: or cancelled. */
-		if (lock->l_completion_ast) {
-			rc = lock->l_completion_ast(lock, LDLM_FL_WAIT_NOREPROC,
-						    NULL);
-			if (rc)
-				goto out;
-		}
-	} else {
-		rc = LUSTRE_EDEADLK;
-	}
- out:
-	LDLM_LOCK_PUT(lock);
-	ptlrpc_req_finished(req);
-	return rc;
-}
-EXPORT_SYMBOL(ldlm_cli_convert);
-
 /**
  * Cancel locks locally.
  * Returns:
-- 
2.1.0
