From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:49:06 -0400
Subject: [lustre-devel] [PATCH v2 45/46] staging/lustre/ldlm: Solve a race
	for LRU lock cancel
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-46-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly.fertman@seagate.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, Oleg Drokin <green@linuxhacker.ru>

From: Vitaly Fertman <vitaly.fertman@seagate.com>

This patch solves a race condition that the lock may be used again
after LRU cancellation policy check. In that case, the lock may have
locked or dirty pages that makes the policy check totally useless.
The problem is solved by checking l_last_used at cancellation time
therefore it can make sure that the lock has not been used.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Reviewed-on: http://review.whamcloud.com/12603
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5781
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  3 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 16 +++++++++++++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 11 +++++++++--
 3 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index e31d84a..351f8b4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -146,7 +146,8 @@ void ldlm_lock_decref_internal(struct ldlm_lock *, __u32 mode);
 void ldlm_lock_decref_internal_nolock(struct ldlm_lock *, __u32 mode);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
-int ldlm_lock_remove_from_lru(struct ldlm_lock *lock);
+int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
+#define ldlm_lock_remove_from_lru(lock) ldlm_lock_remove_from_lru_check(lock, 0)
 int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock);
 void ldlm_lock_destroy_nolock(struct ldlm_lock *lock);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 27a051b..3f9b8526 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -229,15 +229,25 @@ int ldlm_lock_remove_from_lru_nolock(struct ldlm_lock *lock)
 
 /**
  * Removes LDLM lock \a lock from LRU. Obtains the LRU lock first.
+ *
+ * If \a last_use is non-zero, it will remove the lock from LRU only if
+ * it matches lock's l_last_used.
+ *
+ * \retval 0 if \a last_use is set, the lock is not in LRU list or \a last_use
+ *           doesn't match lock's l_last_used;
+ *           otherwise, the lock hasn't been in the LRU list.
+ * \retval 1 the lock was in LRU list and removed.
  */
-int ldlm_lock_remove_from_lru(struct ldlm_lock *lock)
+int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
-	int rc;
+	int rc = 0;
 
 	spin_lock(&ns->ns_lock);
-	rc = ldlm_lock_remove_from_lru_nolock(lock);
+	if (last_use == 0 || last_use == lock->l_last_used)
+		rc = ldlm_lock_remove_from_lru_nolock(lock);
 	spin_unlock(&ns->ns_lock);
+
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 9aa4c2d..5b0e396 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1369,6 +1369,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 	while (!list_empty(&ns->ns_unused_list)) {
 		ldlm_policy_res_t result;
+		time_t last_use = 0;
 
 		/* all unused locks */
 		if (remained-- <= 0)
@@ -1387,6 +1388,10 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 				/* already processed */
 				continue;
 
+			last_use = lock->l_last_used;
+			if (last_use == cfs_time_current())
+				continue;
+
 			/* Somebody is already doing CANCEL. No need for this
 			 * lock in LRU, do not traverse it again.
 			 */
@@ -1434,11 +1439,13 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		lock_res_and_lock(lock);
 		/* Check flags again under the lock. */
 		if ((lock->l_flags & LDLM_FL_CANCELING) ||
-		    (ldlm_lock_remove_from_lru(lock) == 0)) {
+		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
 			/* Another thread is removing lock from LRU, or
 			 * somebody is already doing CANCEL, or there
 			 * is a blocking request which will send cancel
-			 * by itself, or the lock is no longer unused.
+			 * by itself, or the lock is no longer unused or
+			 * the lock has been used since the pf() call and
+			 * pages could be put under it.
 			 */
 			unlock_res_and_lock(lock);
 			lu_ref_del(&lock->l_reference,
-- 
2.1.0
