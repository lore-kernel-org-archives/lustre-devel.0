From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:26 -0400
Subject: [lustre-devel] [PATCH 16/32] staging/lustre/ldlm: Remove
	ldlm_glimpse_ast()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-17-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Only used on the server.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 28 ----------------------
 2 files changed, 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 432222b..8b2b092 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1282,7 +1282,6 @@ int ldlm_expired_completion_wait(void *data);
 int ldlm_blocking_ast_nocheck(struct ldlm_lock *lock);
 int ldlm_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		      void *data, int flag);
-int ldlm_glimpse_ast(struct ldlm_lock *lock, void *reqp);
 int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data);
 int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
 /** @} ldlm_local_ast */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c73661c..a9159fd 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -358,34 +358,6 @@ int ldlm_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 }
 EXPORT_SYMBOL(ldlm_blocking_ast);
 
-/**
- * ->l_glimpse_ast() for DLM extent locks acquired on the server-side. See
- * comment in filter_intent_policy() on why you may need this.
- */
-int ldlm_glimpse_ast(struct ldlm_lock *lock, void *reqp)
-{
-	/*
-	 * Returning -ELDLM_NO_LOCK_DATA actually works, but the reason for
-	 * that is rather subtle: with OST-side locking, it may so happen that
-	 * _all_ extent locks are held by the OST. If client wants to obtain
-	 * current file size it calls ll{,u}_glimpse_size(), and (as locks are
-	 * on the server), dummy glimpse callback fires and does
-	 * nothing. Client still receives correct file size due to the
-	 * following fragment in filter_intent_policy():
-	 *
-	 * rc = l->l_glimpse_ast(l, NULL); // this will update the LVB
-	 * if (rc != 0 && res->lr_namespace->ns_lvbo &&
-	 *     res->lr_namespace->ns_lvbo->lvbo_update) {
-	 *	 res->lr_namespace->ns_lvbo->lvbo_update(res, NULL, 0, 1);
-	 * }
-	 *
-	 * that is, after glimpse_ast() fails, filter_lvbo_update() runs, and
-	 * returns correct file size to the client.
-	 */
-	return -ELDLM_NO_LOCK_DATA;
-}
-EXPORT_SYMBOL(ldlm_glimpse_ast);
-
 static void failed_lock_cleanup(struct ldlm_namespace *ns,
 				struct ldlm_lock *lock, int mode)
 {
-- 
2.1.0
