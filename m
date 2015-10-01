From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:35 -0400
Subject: [lustre-devel] [PATCH 25/32] staging/lustre/ldlm: Remove unused
	ldlm_blocking_ast/_nocheck()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

All users are gone, and they were used on the server anyway.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  3 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 70 ----------------------
 2 files changed, 73 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 9608373..360c7f7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1264,9 +1264,6 @@ int ldlm_expired_completion_wait(void *data);
  * also used by client-side lock handlers to perform minimum level base
  * processing.
  * @{ */
-int ldlm_blocking_ast_nocheck(struct ldlm_lock *lock);
-int ldlm_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
-		      void *data, int flag);
 int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data);
 int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
 /** @} ldlm_local_ast */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 15e1980..2d28fc2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -287,76 +287,6 @@ noreproc:
 }
 EXPORT_SYMBOL(ldlm_completion_ast);
 
-/**
- * A helper to build a blocking AST function
- *
- * Perform a common operation for blocking ASTs:
- * deferred lock cancellation.
- *
- * \param lock the lock blocking or canceling AST was called on
- * \retval 0
- * \see mdt_blocking_ast
- * \see ldlm_blocking_ast
- */
-int ldlm_blocking_ast_nocheck(struct ldlm_lock *lock)
-{
-	int do_ast;
-
-	lock->l_flags |= LDLM_FL_CBPENDING;
-	do_ast = !lock->l_readers && !lock->l_writers;
-	unlock_res_and_lock(lock);
-
-	if (do_ast) {
-		struct lustre_handle lockh;
-		int rc;
-
-		LDLM_DEBUG(lock, "already unused, calling ldlm_cli_cancel");
-		ldlm_lock2handle(lock, &lockh);
-		rc = ldlm_cli_cancel(&lockh, LCF_ASYNC);
-		if (rc < 0)
-			CERROR("ldlm_cli_cancel: %d\n", rc);
-	} else {
-		LDLM_DEBUG(lock, "Lock still has references, will be cancelled later");
-	}
-	return 0;
-}
-EXPORT_SYMBOL(ldlm_blocking_ast_nocheck);
-
-/**
- * Server blocking AST
- *
- * ->l_blocking_ast() callback for LDLM locks acquired by server-side
- * OBDs.
- *
- * \param lock the lock which blocks a request or cancelling lock
- * \param desc unused
- * \param data unused
- * \param flag indicates whether this cancelling or blocking callback
- * \retval 0
- * \see ldlm_blocking_ast_nocheck
- */
-int ldlm_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
-		      void *data, int flag)
-{
-	if (flag == LDLM_CB_CANCELING) {
-		/* Don't need to do anything here. */
-		return 0;
-	}
-
-	lock_res_and_lock(lock);
-	/* Get this: if ldlm_blocking_ast is racing with intent_policy, such
-	 * that ldlm_blocking_ast is called just before intent_policy method
-	 * takes the lr_lock, then by the time we get the lock, we might not
-	 * be the correct blocking function anymore.  So check, and return
-	 * early, if so. */
-	if (lock->l_blocking_ast != ldlm_blocking_ast) {
-		unlock_res_and_lock(lock);
-		return 0;
-	}
-	return ldlm_blocking_ast_nocheck(lock);
-}
-EXPORT_SYMBOL(ldlm_blocking_ast);
-
 static void failed_lock_cleanup(struct ldlm_namespace *ns,
 				struct ldlm_lock *lock, int mode)
 {
-- 
2.1.0
