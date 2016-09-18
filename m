From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:49 -0400
Subject: [lustre-devel] [PATCH 050/124] staging: lustre: ldlm: per-export
	lock callback timeout
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

The lock callback timeout is calculated as an average per namespace.
This does not reflect individual client behavior.
Instead, we should calculate it on a per-export basis.

This is the client side changes for upstream client.

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4942
Reviewed-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Reviewed-by: Alexey Lyashkov <Alexey_Lyashkov@xyratex.com>
Xyratex-bug-id: MRP-417
Reviewed-on: http://review.whamcloud.com/9336
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   54 ++++++++++++--------
 3 files changed, 33 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index dc0e4af..6536832 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -102,7 +102,7 @@ int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 			  struct list_head *cancels, int count, int max,
 			  enum ldlm_cancel_flags cancel_flags, int flags);
-extern int ldlm_enqueue_min;
+extern unsigned int ldlm_enqueue_min;
 
 /* ldlm_resource.c */
 int ldlm_resource_putref_locked(struct ldlm_resource *res);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index f516106..3c48b4f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1541,8 +1541,6 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 	struct ldlm_lock *lock = *lockp;
 	struct ldlm_resource *res = lock->l_resource;
 
-	lock->l_last_activity = ktime_get_real_seconds();
-
 	lock_res_and_lock(lock);
 	if (lock->l_req_mode == lock->l_granted_mode) {
 		/* The server returned a blocked lock, but it was granted
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index cc835cb..46842dd 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -63,8 +63,8 @@
 
 #include "ldlm_internal.h"
 
-int ldlm_enqueue_min = OBD_TIMEOUT_DEFAULT;
-module_param(ldlm_enqueue_min, int, 0644);
+unsigned int ldlm_enqueue_min = OBD_TIMEOUT_DEFAULT;
+module_param(ldlm_enqueue_min, uint, 0644);
 MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
 
 /* in client side, whether the cached locks will be canceled before replay */
@@ -123,44 +123,56 @@ static int ldlm_expired_completion_wait(void *data)
 	return 0;
 }
 
+/**
+ * Calculate the Completion timeout (covering enqueue, BL AST, data flush,
+ * lock cancel, and their replies). Used for lock completion timeout on the
+ * client side.
+ *
+ * \param[in] lock	lock which is waiting the completion callback
+ *
+ * \retval		timeout in seconds to wait for the server reply
+ */
 /* We use the same basis for both server side and client side functions
  * from a single node.
  */
-static int ldlm_get_enq_timeout(struct ldlm_lock *lock)
+static unsigned int ldlm_cp_timeout(struct ldlm_lock *lock)
 {
-	int timeout = at_get(ldlm_lock_to_ns_at(lock));
+	unsigned int timeout;
 
 	if (AT_OFF)
-		return obd_timeout / 2;
-	/* Since these are non-updating timeouts, we should be conservative.
-	 * It would be nice to have some kind of "early reply" mechanism for
-	 * lock callbacks too...
+		return obd_timeout;
+
+	/*
+	 * Wait a long time for enqueue - server may have to callback a
+	 * lock from another client.  Server will evict the other client if it
+	 * doesn't respond reasonably, and then give us the lock.
 	 */
-	timeout = min_t(int, at_max, timeout + (timeout >> 1)); /* 150% */
-	return max(timeout, ldlm_enqueue_min);
+	timeout = at_get(ldlm_lock_to_ns_at(lock));
+	return max(3 * timeout, ldlm_enqueue_min);
 }
 
 /**
  * Helper function for ldlm_completion_ast(), updating timings when lock is
  * actually granted.
  */
-static int ldlm_completion_tail(struct ldlm_lock *lock)
+static int ldlm_completion_tail(struct ldlm_lock *lock, void *data)
 {
 	long delay;
-	int  result;
+	int result = 0;
 
 	if (ldlm_is_destroyed(lock) || ldlm_is_failed(lock)) {
 		LDLM_DEBUG(lock, "client-side enqueue: destroyed");
 		result = -EIO;
+	} else if (!data) {
+		LDLM_DEBUG(lock, "client-side enqueue: granted");
 	} else {
+		/* Take into AT only CP RPC, not immediately granted locks */
 		delay = ktime_get_real_seconds() - lock->l_last_activity;
 		LDLM_DEBUG(lock, "client-side enqueue: granted after %lds",
 			   delay);
 
 		/* Update our time estimate */
-		at_measured(ldlm_lock_to_ns_at(lock),
-			    delay);
-		result = 0;
+		at_measured(ldlm_lock_to_ns_at(lock), delay);
 	}
 	return result;
 }
@@ -179,7 +191,7 @@ int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data)
 
 	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
 		wake_up(&lock->l_waitq);
-		return ldlm_completion_tail(lock);
+		return ldlm_completion_tail(lock, data);
 	}
 
 	LDLM_DEBUG(lock, "client-side enqueue returned a blocked lock, going forward");
@@ -238,13 +250,10 @@ noreproc:
 	if (obd)
 		imp = obd->u.cli.cl_import;
 
-	/* Wait a long time for enqueue - server may have to callback a
-	 * lock from another client.  Server will evict the other client if it
-	 * doesn't respond reasonably, and then give us the lock.
-	 */
-	timeout = ldlm_get_enq_timeout(lock) * 2;
+	timeout = ldlm_cp_timeout(lock);
 
 	lwd.lwd_lock = lock;
+	lock->l_last_activity = ktime_get_real_seconds();
 
 	if (ldlm_is_no_timeout(lock)) {
 		LDLM_DEBUG(lock, "waiting indefinitely because of NO_TIMEOUT");
@@ -277,7 +286,7 @@ noreproc:
 		return rc;
 	}
 
-	return ldlm_completion_tail(lock);
+	return ldlm_completion_tail(lock, data);
 }
 EXPORT_SYMBOL(ldlm_completion_ast);
 
@@ -715,6 +724,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	lock->l_export = NULL;
 	lock->l_blocking_ast = einfo->ei_cb_bl;
 	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL));
+	lock->l_last_activity = ktime_get_real_seconds();
 
 	/* lock not sent to server yet */
 
-- 
1.7.1
