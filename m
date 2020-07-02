From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:47 -0400
Subject: [lustre-devel] [PATCH 07/18] lustre: ptlrpc: limit rate of lock
 replays
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Clients send all lock replays at once and that may overwhelm
server with huge amount of replays in recovery queue causing
OOM effects.

Patch adds rate control for lock replays on client

WC-bug-id: https://jira.whamcloud.com/browse/LU-13600
Lustre-commit: 3b613a442b869 ("LU-13600 ptlrpc: limit rate of lock replays")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38920
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  2 ++
 fs/lustre/ldlm/ldlm_request.c     | 69 +++++++++++++++++++++++++++++++++++----
 fs/lustre/obdclass/genops.c       |  1 +
 fs/lustre/ptlrpc/import.c         |  8 ++---
 4 files changed, 70 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 4e9a228..72a303e 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -226,6 +226,8 @@ struct obd_import {
 	atomic_t			imp_unregistering;
 	/** Number of replay requests inflight */
 	atomic_t			imp_replay_inflight;
+	/** In-flight replays rate control */
+	wait_queue_head_t		imp_replay_waitq;
 	/** Number of currently happening import invalidations */
 	atomic_t			imp_inval_count;
 	/** Numbner of request timeouts */
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 12ee241..e1ba596 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -2098,6 +2098,8 @@ static int replay_lock_interpret(const struct lu_env *env,
 	struct obd_export *exp;
 
 	atomic_dec(&req->rq_import->imp_replay_inflight);
+	wake_up(&req->rq_import->imp_replay_waitq);
+
 	if (rc != ELDLM_OK)
 		goto out;
 
@@ -2205,7 +2207,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 
 	LDLM_DEBUG(lock, "replaying lock:");
 
-	atomic_inc(&req->rq_import->imp_replay_inflight);
+	atomic_inc(&imp->imp_replay_inflight);
 	aa = ptlrpc_req_async_args(aa, req);
 	aa->lock_handle = body->lock_handle[0];
 	req->rq_interpret_reply = replay_lock_interpret;
@@ -2245,22 +2247,32 @@ static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
 	       canceled, ldlm_ns_name(ns));
 }
 
-int ldlm_replay_locks(struct obd_import *imp)
+static int lock_can_replay(struct obd_import *imp)
+{
+	struct client_obd *cli = &imp->imp_obd->u.cli;
+
+	CDEBUG(D_HA, "check lock replay limit, inflights = %u(%u)\n",
+	       atomic_read(&imp->imp_replay_inflight) - 1,
+	       cli->cl_max_rpcs_in_flight);
+
+	/* +1 due to ldlm_lock_replay() increment */
+	return atomic_read(&imp->imp_replay_inflight) <
+	       1 + min_t(u32, cli->cl_max_rpcs_in_flight, 8);
+}
+
+int __ldlm_replay_locks(struct obd_import *imp, bool rate_limit)
 {
 	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
 	LIST_HEAD(list);
 	struct ldlm_lock *lock;
 	int rc = 0;
 
-	LASSERT(atomic_read(&imp->imp_replay_inflight) == 0);
+	LASSERT(atomic_read(&imp->imp_replay_inflight) == 1);
 
 	/* don't replay locks if import failed recovery */
 	if (imp->imp_vbr_failed)
 		return 0;
 
-	/* ensure this doesn't fall to 0 before all have been queued */
-	atomic_inc(&imp->imp_replay_inflight);
-
 	if (ldlm_cancel_unused_locks_before_replay)
 		ldlm_cancel_unused_locks_for_replay(ns);
 
@@ -2276,9 +2288,54 @@ int ldlm_replay_locks(struct obd_import *imp)
 		}
 		rc = replay_one_lock(imp, lock);
 		LDLM_LOCK_RELEASE(lock);
+
+		if (rate_limit)
+			wait_event_idle_exclusive(imp->imp_replay_waitq,
+						  lock_can_replay(imp));
 	}
 
+	return rc;
+}
+
+/**
+ * Lock replay uses rate control and can sleep waiting so
+ * must be in separate thread from ptlrpcd itself
+ */
+static int ldlm_lock_replay_thread(void *data)
+{
+	struct obd_import *imp = data;
+
+	CDEBUG(D_HA, "lock replay thread %s to %s@%s\n",
+	       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
+	       imp->imp_connection->c_remote_uuid.uuid);
+
+	__ldlm_replay_locks(imp, true);
 	atomic_dec(&imp->imp_replay_inflight);
+	ptlrpc_import_recovery_state_machine(imp);
+	class_import_put(imp);
+
+	return 0;
+}
+
+int ldlm_replay_locks(struct obd_import *imp)
+{
+	struct task_struct *task;
+	int rc = 0;
+
+	class_import_get(imp);
+	/* ensure this doesn't fall to 0 before all have been queued */
+	atomic_inc(&imp->imp_replay_inflight);
+
+	task = kthread_run(ldlm_lock_replay_thread, imp, "ldlm_lock_replay");
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
+		CDEBUG(D_HA, "can't start lock replay thread: rc = %d\n", rc);
+
+		/* run lock replay without rate control */
+		rc = __ldlm_replay_locks(imp, false);
+		atomic_dec(&imp->imp_replay_inflight);
+		class_import_put(imp);
+	}
 
 	return rc;
 }
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 1647fe9..759d97e 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1001,6 +1001,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	atomic_set(&imp->imp_reqs, 0);
 	atomic_set(&imp->imp_inflight, 0);
 	atomic_set(&imp->imp_replay_inflight, 0);
+	init_waitqueue_head(&imp->imp_replay_waitq);
 	atomic_set(&imp->imp_inval_count, 0);
 	INIT_LIST_HEAD(&imp->imp_conn_list);
 	init_imp_at(&imp->imp_at);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 6b0b115..7ec3638 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1486,6 +1486,8 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 	int target_len;
 
 	if (imp->imp_state == LUSTRE_IMP_EVICTED) {
+		struct task_struct *task;
+
 		deuuidify(obd2cli_tgt(imp->imp_obd), NULL,
 			  &target_start, &target_len);
 		/* Don't care about MGC eviction */
@@ -1505,8 +1507,6 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		imp->imp_vbr_failed = 0;
 		spin_unlock(&imp->imp_lock);
 
-		{
-		struct task_struct *task;
 		/* bug 17802:  XXX client_disconnect_export vs connect request
 		 * race. if client is evicted at this time, we start
 		 * invalidate thread without reference to import and import can
@@ -1517,13 +1517,13 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 				   "ll_imp_inval");
 		if (IS_ERR(task)) {
 			class_import_put(imp);
-			CERROR("error starting invalidate thread: %d\n", rc);
 			rc = PTR_ERR(task);
+			CERROR("%s: can't start invalidate thread: rc = %d\n",
+			       imp->imp_obd->obd_name, rc);
 		} else {
 			rc = 0;
 		}
 		return rc;
-		}
 	}
 
 	if (imp->imp_state == LUSTRE_IMP_REPLAY) {
-- 
1.8.3.1
