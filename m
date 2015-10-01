From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:31 -0400
Subject: [lustre-devel] [PATCH 21/32] staging/lustre/ldlm: Remove
	ldlm_refresh/del_waiting_lock()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Nothing adds locks into waiting list on the client, so no
point in retaining those.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  8 --------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 13 -------------
 3 files changed, 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index ec717eb..5a72f22 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1108,8 +1108,6 @@ struct ldlm_callback_suite {
 };
 
 /* ldlm_lockd.c */
-int ldlm_del_waiting_lock(struct ldlm_lock *lock);
-int ldlm_refresh_waiting_lock(struct ldlm_lock *lock, int timeout);
 int ldlm_get_ref(void);
 void ldlm_put_ref(void);
 struct ldlm_lock *ldlm_request_lock(struct ptlrpc_request *req);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 536f97c..133936e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1947,17 +1947,9 @@ void ldlm_lock_cancel(struct ldlm_lock *lock)
 		LBUG();
 	}
 
-	if (lock->l_flags & LDLM_FL_WAITED)
-		ldlm_del_waiting_lock(lock);
-
 	/* Releases cancel callback. */
 	ldlm_cancel_callback(lock);
 
-	/* Yes, second time, just in case it was added again while we were
-	 * running with no res lock in ldlm_cancel_callback */
-	if (lock->l_flags & LDLM_FL_WAITED)
-		ldlm_del_waiting_lock(lock);
-
 	ldlm_resource_unlink_lock(lock);
 	ldlm_lock_destroy_nolock(lock);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 57f6128..045e3c6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -111,19 +111,6 @@ struct ldlm_bl_work_item {
 	int		     blwi_mem_pressure;
 };
 
-
-int ldlm_del_waiting_lock(struct ldlm_lock *lock)
-{
-	return 0;
-}
-
-int ldlm_refresh_waiting_lock(struct ldlm_lock *lock, int timeout)
-{
-	return 0;
-}
-
-
-
 /**
  * Callback handler for receiving incoming blocking ASTs.
  *
-- 
2.1.0
