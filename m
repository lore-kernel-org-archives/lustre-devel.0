From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:22 -0400
Subject: [lustre-devel] [PATCH 12/32] staging/lustre/ldlm: Remove unused
	ldlm_cli_enqueue_local()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This is only used on the server.
Also while we are at it, remove unused prototypes for
ldlm_server_ast and ldlm_handle_enqueue0() that are not
defined anywhere

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 15 -----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 68 ----------------------
 2 files changed, 83 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 40377b2..ce91ccc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1308,25 +1308,10 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 		      struct list_head *cancels, int count);
 
 struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp, int lvb_len);
-int ldlm_handle_enqueue0(struct ldlm_namespace *ns, struct ptlrpc_request *req,
-			 const struct ldlm_request *dlm_req,
-			 const struct ldlm_callback_suite *cbs);
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  ldlm_type_t type, __u8 with_policy, ldlm_mode_t mode,
 			  __u64 *flags, void *lvb, __u32 lvb_len,
 			  struct lustre_handle *lockh, int rc);
-int ldlm_cli_enqueue_local(struct ldlm_namespace *ns,
-			   const struct ldlm_res_id *res_id,
-			   ldlm_type_t type, ldlm_policy_data_t *policy,
-			   ldlm_mode_t mode, __u64 *flags,
-			   ldlm_blocking_callback blocking,
-			   ldlm_completion_callback completion,
-			   ldlm_glimpse_callback glimpse,
-			   void *data, __u32 lvb_len, enum lvb_type lvb_type,
-			   const __u64 *client_cookie,
-			   struct lustre_handle *lockh);
-int ldlm_server_ast(struct lustre_handle *lockh, struct ldlm_lock_desc *new,
-		    void *data, __u32 data_len);
 int ldlm_cli_update_pool(struct ptlrpc_request *req);
 int ldlm_cli_cancel(struct lustre_handle *lockh,
 		    ldlm_cancel_flags_t cancel_flags);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 760c745..9856133 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -386,74 +386,6 @@ int ldlm_glimpse_ast(struct ldlm_lock *lock, void *reqp)
 }
 EXPORT_SYMBOL(ldlm_glimpse_ast);
 
-/**
- * Enqueue a local lock (typically on a server).
- */
-int ldlm_cli_enqueue_local(struct ldlm_namespace *ns,
-			   const struct ldlm_res_id *res_id,
-			   ldlm_type_t type, ldlm_policy_data_t *policy,
-			   ldlm_mode_t mode, __u64 *flags,
-			   ldlm_blocking_callback blocking,
-			   ldlm_completion_callback completion,
-			   ldlm_glimpse_callback glimpse,
-			   void *data, __u32 lvb_len, enum lvb_type lvb_type,
-			   const __u64 *client_cookie,
-			   struct lustre_handle *lockh)
-{
-	struct ldlm_lock *lock;
-	int err;
-	const struct ldlm_callback_suite cbs = { .lcs_completion = completion,
-						 .lcs_blocking   = blocking,
-						 .lcs_glimpse    = glimpse,
-	};
-
-	LASSERT(!(*flags & LDLM_FL_REPLAY));
-	if (unlikely(ns_is_client(ns))) {
-		CERROR("Trying to enqueue local lock in a shadow namespace\n");
-		LBUG();
-	}
-
-	lock = ldlm_lock_create(ns, res_id, type, mode, &cbs, data, lvb_len,
-				lvb_type);
-	if (unlikely(!lock)) {
-		err = -ENOMEM;
-		goto out_nolock;
-	}
-
-	ldlm_lock2handle(lock, lockh);
-
-	/* NB: we don't have any lock now (lock_res_and_lock)
-	 * because it's a new lock */
-	ldlm_lock_addref_internal_nolock(lock, mode);
-	lock->l_flags |= LDLM_FL_LOCAL;
-	if (*flags & LDLM_FL_ATOMIC_CB)
-		lock->l_flags |= LDLM_FL_ATOMIC_CB;
-
-	if (policy != NULL)
-		lock->l_policy_data = *policy;
-	if (client_cookie != NULL)
-		lock->l_client_cookie = *client_cookie;
-	if (type == LDLM_EXTENT)
-		lock->l_req_extent = policy->l_extent;
-
-	err = ldlm_lock_enqueue(ns, &lock, policy, flags);
-	if (unlikely(err != ELDLM_OK))
-		goto out;
-
-	if (policy != NULL)
-		*policy = lock->l_policy_data;
-
-	if (lock->l_completion_ast)
-		lock->l_completion_ast(lock, *flags, NULL);
-
-	LDLM_DEBUG(lock, "client-side local enqueue handler, new lock created");
- out:
-	LDLM_LOCK_RELEASE(lock);
- out_nolock:
-	return err;
-}
-EXPORT_SYMBOL(ldlm_cli_enqueue_local);
-
 static void failed_lock_cleanup(struct ldlm_namespace *ns,
 				struct ldlm_lock *lock, int mode)
 {
-- 
2.1.0
