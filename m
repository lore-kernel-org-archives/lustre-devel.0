From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:03 -0400
Subject: [lustre-devel] [PATCH 13/28] lustre: ldlm: check lock cancellation
 in ldlm_cli_cancel()
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

In that case, the assert for 'list_empty(&lock->l_bl_ast)' will fail
because the lock is already in a cancel list.

This patch checks if the lock is already being canceled in prior.

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9997
Reviewed-on: https://review.whamcloud.com/29080
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 13 +++++++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 13 -------------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  6 +++++-
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 709c527..46b2b64 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -299,6 +299,19 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 	return ret;
 }
 
+static inline bool is_bl_done(struct ldlm_lock *lock)
+{
+	bool bl_done = true;
+
+	if (!ldlm_is_bl_done(lock)) {
+		lock_res_and_lock(lock);
+		bl_done = ldlm_is_bl_done(lock);
+		unlock_res_and_lock(lock);
+	}
+
+	return bl_done;
+}
+
 typedef void (*ldlm_policy_wire_to_local_t)(const union ldlm_wire_policy_data *,
 					    union ldlm_policy_data *);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index bc6b122..ebdfc11 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1832,19 +1832,6 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 	return rc;
 }
 
-static bool is_bl_done(struct ldlm_lock *lock)
-{
-	bool bl_done = true;
-
-	if (!ldlm_is_bl_done(lock)) {
-		lock_res_and_lock(lock);
-		bl_done = ldlm_is_bl_done(lock);
-		unlock_res_and_lock(lock);
-	}
-
-	return bl_done;
-}
-
 /**
  * Helper function to call blocking AST for LDLM lock \a lock in a
  * "cancelling" mode.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 3eb5036..a208c99 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1026,8 +1026,12 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 
 	lock_res_and_lock(lock);
 	/* Lock is being canceled and the caller doesn't want to wait */
-	if (ldlm_is_canceling(lock) && (cancel_flags & LCF_ASYNC)) {
+	if (ldlm_is_canceling(lock)) {
 		unlock_res_and_lock(lock);
+
+		if (!(cancel_flags & LCF_ASYNC))
+			wait_event_idle(lock->l_waitq, is_bl_done(lock));
+
 		LDLM_LOCK_RELEASE(lock);
 		return 0;
 	}
-- 
1.8.3.1
