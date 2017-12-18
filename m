From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 18:18:00 +1100
Subject: [lustre-devel] [PATCH 07/16] staging: lustre: simplify waiting in
 ldlm_completion_ast()
In-Reply-To: <151358127190.5099.12792810096274074963.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
Message-ID: <151358148005.5099.1737285068022718842.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

If a signal-callback (lwi_on_signal) is set without lwi_allow_intr, as
is the case in ldlm_completion_ast(), the behavior depends on the
timeout set.

If a timeout is set, then signals are ignored.  If the timeout is
reached, the timeout handler is called.
If no timeout is set, then "fatal" signals are not ignored.  If one
arrives the callback is run, but as the callback is empty in this
case, that is not relevant.

So treat the two cases separately. In one, use
l_wait_event_abortable().  In the other, use wait_event_timeout(),
and if the timeout happens - perform the timeout-call function
(opencoded).

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c |   51 +++++++--------------
 1 file changed, 17 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index a244fa717134..05bec9fd629b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -72,15 +72,6 @@ MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
 /* in client side, whether the cached locks will be canceled before replay */
 unsigned int ldlm_cancel_unused_locks_before_replay = 1;
 
-static void interrupted_completion_wait(void *data)
-{
-}
-
-struct lock_wait_data {
-	struct ldlm_lock *lwd_lock;
-	__u32	     lwd_conn_cnt;
-};
-
 struct ldlm_async_args {
 	struct lustre_handle lock_handle;
 };
@@ -112,10 +103,8 @@ static int ldlm_request_bufsize(int count, int type)
 	return sizeof(struct ldlm_request) + avail;
 }
 
-static int ldlm_expired_completion_wait(void *data)
+static int ldlm_expired_completion_wait(struct ldlm_lock *lock, struct obd_import *imp2)
 {
-	struct lock_wait_data *lwd = data;
-	struct ldlm_lock *lock = lwd->lwd_lock;
 	struct obd_import *imp;
 	struct obd_device *obd;
 
@@ -140,7 +129,7 @@ static int ldlm_expired_completion_wait(void *data)
 
 	obd = lock->l_conn_export->exp_obd;
 	imp = obd->u.cli.cl_import;
-	ptlrpc_fail_import(imp, lwd->lwd_conn_cnt);
+	ptlrpc_fail_import(imp, imp2 ? imp2->imp_conn_cnt : 0);
 	LDLM_ERROR(lock,
 		   "lock timed out (enqueued at %lld, %llds ago), entering recovery for %s@%s",
 		   (s64)lock->l_last_activity,
@@ -251,10 +240,8 @@ EXPORT_SYMBOL(ldlm_completion_ast_async);
 int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 {
 	/* XXX ALLOCATE - 160 bytes */
-	struct lock_wait_data lwd;
 	struct obd_device *obd;
 	struct obd_import *imp = NULL;
-	struct l_wait_info lwi;
 	__u32 timeout;
 	int rc = 0;
 
@@ -281,32 +268,28 @@ int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 
 	timeout = ldlm_cp_timeout(lock);
 
-	lwd.lwd_lock = lock;
 	lock->l_last_activity = ktime_get_real_seconds();
 
-	if (ldlm_is_no_timeout(lock)) {
-		LDLM_DEBUG(lock, "waiting indefinitely because of NO_TIMEOUT");
-		lwi = LWI_INTR(interrupted_completion_wait, &lwd);
-	} else {
-		lwi = LWI_TIMEOUT_INTR(timeout * HZ,
-				       ldlm_expired_completion_wait,
-				       interrupted_completion_wait, &lwd);
-	}
-
-	if (imp) {
-		spin_lock(&imp->imp_lock);
-		lwd.lwd_conn_cnt = imp->imp_conn_cnt;
-		spin_unlock(&imp->imp_lock);
-	}
-
 	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
 				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
 		ldlm_set_fail_loc(lock);
 		rc = -EINTR;
 	} else {
-		/* Go to sleep until the lock is granted or cancelled. */
-		rc = l_wait_event(lock->l_waitq,
-				  is_granted_or_cancelled(lock), &lwi);
+		/* Go to sleep until the lock is granted or canceled. */
+		if (ldlm_is_no_timeout(lock)) {
+			LDLM_DEBUG(lock, "waiting indefinitely because of NO_TIMEOUT");
+			rc = l_wait_event_abortable(lock->l_waitq,
+						    is_granted_or_cancelled(lock));
+		} else {
+			rc = wait_event_timeout(lock->l_waitq,
+						is_granted_or_cancelled(lock),
+						timeout * HZ);
+			if (rc == 0) {
+				ldlm_expired_completion_wait(lock, imp);
+				rc = -ETIMEDOUT;
+			} else
+				rc = 0;
+		}
 	}
 
 	if (rc) {
