From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:25 -0500
Subject: [lustre-devel] [PATCH 397/622] lustre: ptlrpc: change IMPORT_SET_*
 macros into real functions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-398-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Make the IMPORT_SET_STATE_NOLOCK and IMPORT_SET_STATE macros into
normal functions. Since import_set_state_nolock() is basically a
wrapper around __import_set_state() we can merge both functions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10756
Lustre-commit: cf78502e48d6 ("LU-10756 ptlrpc: change IMPORT_SET_* macros into real functions")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/35463
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 96 +++++++++++++++++++++++------------------------
 1 file changed, 48 insertions(+), 48 deletions(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index f8e15f2..98c09f6 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -58,10 +58,10 @@ struct ptlrpc_connect_async_args {
 
 /**
  * Updates import @imp current state to provided @state value
- * Helper function. Must be called under imp_lock.
+ * Helper function.
  */
-static void __import_set_state(struct obd_import *imp,
-			       enum lustre_imp_state state)
+static void import_set_state_nolock(struct obd_import *imp,
+				    enum lustre_imp_state state)
 {
 	switch (state) {
 	case LUSTRE_IMP_CLOSED:
@@ -74,6 +74,18 @@ static void __import_set_state(struct obd_import *imp,
 		break;
 	default:
 		imp->imp_replay_state = LUSTRE_IMP_REPLAY;
+		break;
+	}
+
+	/* A CLOSED import should remain so. */
+	if (state == LUSTRE_IMP_CLOSED)
+		return;
+
+	if (imp->imp_state != LUSTRE_IMP_NEW) {
+		CDEBUG(D_HA, "%p %s: changing import state from %s to %s\n",
+		       imp, obd2cli_tgt(imp->imp_obd),
+		       ptlrpc_import_state_name(imp->imp_state),
+		       ptlrpc_import_state_name(state));
 	}
 
 	imp->imp_state = state;
@@ -84,24 +96,13 @@ static void __import_set_state(struct obd_import *imp,
 		IMP_STATE_HIST_LEN;
 }
 
-/* A CLOSED import should remain so. */
-#define IMPORT_SET_STATE_NOLOCK(imp, state)				       \
-do {									       \
-	if (imp->imp_state != LUSTRE_IMP_CLOSED) {			       \
-		CDEBUG(D_HA, "%p %s: changing import state from %s to %s\n",   \
-		       imp, obd2cli_tgt(imp->imp_obd),			       \
-		       ptlrpc_import_state_name(imp->imp_state),	       \
-		       ptlrpc_import_state_name(state));		       \
-		__import_set_state(imp, state);				       \
-	}								       \
-} while (0)
-
-#define IMPORT_SET_STATE(imp, state)					\
-do {									\
-	spin_lock(&imp->imp_lock);					\
-	IMPORT_SET_STATE_NOLOCK(imp, state);				\
-	spin_unlock(&imp->imp_lock);					\
-} while (0)
+static void import_set_state(struct obd_import *imp,
+			     enum lustre_imp_state new_state)
+{
+	spin_lock(&imp->imp_lock);
+	import_set_state_nolock(imp, new_state);
+	spin_unlock(&imp->imp_lock);
+}
 
 static int ptlrpc_connect_interpret(const struct lu_env *env,
 				    struct ptlrpc_request *request,
@@ -180,7 +181,7 @@ int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
 					   target_len, target_start,
 					   obd_import_nid2str(imp));
 		}
-		IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_DISCON);
+		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 		spin_unlock(&imp->imp_lock);
 
 		if (obd_dump_on_timeout)
@@ -629,7 +630,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 		return -EALREADY;
 	}
 
-	IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_CONNECTING);
+	import_set_state_nolock(imp, LUSTRE_IMP_CONNECTING);
 
 	imp->imp_conn_cnt++;
 	imp->imp_resend_replay = 0;
@@ -742,7 +743,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	rc = 0;
 out:
 	if (rc != 0)
-		IMPORT_SET_STATE(imp, LUSTRE_IMP_DISCON);
+		import_set_state(imp, LUSTRE_IMP_DISCON);
 
 	return rc;
 }
@@ -1094,9 +1095,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		if (msg_flags & MSG_CONNECT_RECOVERING) {
 			CDEBUG(D_HA, "connect to %s during recovery\n",
 			       obd2cli_tgt(imp->imp_obd));
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_REPLAY_LOCKS);
+			import_set_state(imp, LUSTRE_IMP_REPLAY_LOCKS);
 		} else {
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_FULL);
+			import_set_state(imp, LUSTRE_IMP_FULL);
 			ptlrpc_activate_import(imp);
 		}
 
@@ -1149,8 +1150,8 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 			imp->imp_remote_handle =
 				     *lustre_msg_get_handle(request->rq_repmsg);
 
-			if (!(msg_flags & MSG_CONNECT_RECOVERING)) {
-				IMPORT_SET_STATE(imp, LUSTRE_IMP_EVICTED);
+			if (!(MSG_CONNECT_RECOVERING & msg_flags)) {
+				import_set_state(imp, LUSTRE_IMP_EVICTED);
 				rc = 0;
 				goto finish;
 			}
@@ -1162,11 +1163,10 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		}
 
 		if (imp->imp_invalid) {
-			CDEBUG(D_HA,
-			       "%s: reconnected but import is invalid; marking evicted\n",
-			       imp->imp_obd->obd_name);
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_EVICTED);
-		} else if (msg_flags & MSG_CONNECT_RECOVERING) {
+			CDEBUG(D_HA, "%s: reconnected but import is invalid; "
+			       "marking evicted\n", imp->imp_obd->obd_name);
+			import_set_state(imp, LUSTRE_IMP_EVICTED);
+		} else if (MSG_CONNECT_RECOVERING & msg_flags) {
 			CDEBUG(D_HA, "%s: reconnected to %s during replay\n",
 			       imp->imp_obd->obd_name,
 			       obd2cli_tgt(imp->imp_obd));
@@ -1175,9 +1175,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 			imp->imp_resend_replay = 1;
 			spin_unlock(&imp->imp_lock);
 
-			IMPORT_SET_STATE(imp, imp->imp_replay_state);
+			import_set_state(imp, imp->imp_replay_state);
 		} else {
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_RECOVER);
+			import_set_state(imp, LUSTRE_IMP_RECOVER);
 		}
 	} else if ((msg_flags & MSG_CONNECT_RECOVERING) && !imp->imp_invalid) {
 		LASSERT(imp->imp_replayable);
@@ -1185,14 +1185,14 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 				*lustre_msg_get_handle(request->rq_repmsg);
 		imp->imp_last_replay_transno = 0;
 		imp->imp_replay_cursor = &imp->imp_committed_list;
-		IMPORT_SET_STATE(imp, LUSTRE_IMP_REPLAY);
+		import_set_state(imp, LUSTRE_IMP_REPLAY);
 	} else {
 		DEBUG_REQ(D_HA, request,
 			  "%s: evicting (reconnect/recover flags not set: %x)",
 			  imp->imp_obd->obd_name, msg_flags);
 		imp->imp_remote_handle =
 				*lustre_msg_get_handle(request->rq_repmsg);
-		IMPORT_SET_STATE(imp, LUSTRE_IMP_EVICTED);
+		import_set_state(imp, LUSTRE_IMP_EVICTED);
 	}
 
 	/* Sanity checks for a reconnected import. */
@@ -1232,7 +1232,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		class_export_put(exp);
 
 	if (rc != 0) {
-		IMPORT_SET_STATE(imp, LUSTRE_IMP_DISCON);
+		import_set_state(imp, LUSTRE_IMP_DISCON);
 		if (rc == -EACCES) {
 			/*
 			 * Give up trying to reconnect
@@ -1268,7 +1268,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 						   OBD_OCD_VERSION_FIX(ocd->ocd_version),
 						   LUSTRE_VERSION_STRING);
 				ptlrpc_deactivate_import(imp);
-				IMPORT_SET_STATE(imp, LUSTRE_IMP_CLOSED);
+				import_set_state(imp, LUSTRE_IMP_CLOSED);
 			}
 			return -EPROTO;
 		}
@@ -1367,7 +1367,7 @@ static int ptlrpc_invalidate_import_thread(void *data)
 		libcfs_debug_dumplog();
 	}
 
-	IMPORT_SET_STATE(imp, LUSTRE_IMP_RECOVER);
+	import_set_state(imp, LUSTRE_IMP_RECOVER);
 	ptlrpc_import_recovery_state_machine(imp);
 
 	class_import_put(imp);
@@ -1448,7 +1448,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		rc = ptlrpc_replay_next(imp, &inflight);
 		if (inflight == 0 &&
 		    atomic_read(&imp->imp_replay_inflight) == 0) {
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_REPLAY_LOCKS);
+			import_set_state(imp, LUSTRE_IMP_REPLAY_LOCKS);
 			rc = ldlm_replay_locks(imp);
 			if (rc)
 				goto out;
@@ -1458,7 +1458,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 
 	if (imp->imp_state == LUSTRE_IMP_REPLAY_LOCKS)
 		if (atomic_read(&imp->imp_replay_inflight) == 0) {
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_REPLAY_WAIT);
+			import_set_state(imp, LUSTRE_IMP_REPLAY_WAIT);
 			rc = signal_completed_replay(imp);
 			if (rc)
 				goto out;
@@ -1466,7 +1466,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 
 	if (imp->imp_state == LUSTRE_IMP_REPLAY_WAIT)
 		if (atomic_read(&imp->imp_replay_inflight) == 0)
-			IMPORT_SET_STATE(imp, LUSTRE_IMP_RECOVER);
+			import_set_state(imp, LUSTRE_IMP_RECOVER);
 
 	if (imp->imp_state == LUSTRE_IMP_RECOVER) {
 		CDEBUG(D_HA, "reconnected to %s@%s\n",
@@ -1476,7 +1476,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		rc = ptlrpc_resend(imp);
 		if (rc)
 			goto out;
-		IMPORT_SET_STATE(imp, LUSTRE_IMP_FULL);
+		import_set_state(imp, LUSTRE_IMP_FULL);
 		ptlrpc_activate_import(imp);
 
 		deuuidify(obd2cli_tgt(imp->imp_obd), NULL,
@@ -1536,7 +1536,7 @@ static struct ptlrpc_request *ptlrpc_disconnect_prep_req(struct obd_import *imp)
 	req->rq_timeout = min_t(int, req->rq_timeout,
 				INITIAL_CONNECT_TIMEOUT);
 
-	IMPORT_SET_STATE(imp, LUSTRE_IMP_CONNECTING);
+	import_set_state(imp, LUSTRE_IMP_CONNECTING);
 	req->rq_send_state =  LUSTRE_IMP_CONNECTING;
 	ptlrpc_request_set_replen(req);
 
@@ -1601,9 +1601,9 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 	spin_lock(&imp->imp_lock);
 out:
 	if (noclose)
-		IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_DISCON);
+		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 	else
-		IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_CLOSED);
+		import_set_state_nolock(imp, LUSTRE_IMP_CLOSED);
 	memset(&imp->imp_remote_handle, 0, sizeof(imp->imp_remote_handle));
 	spin_unlock(&imp->imp_lock);
 
@@ -1657,7 +1657,7 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 		if (atomic_read(&imp->imp_inflight) > 1) {
 			imp->imp_generation++;
 			imp->imp_initiated_at = imp->imp_generation;
-			IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_NEW);
+			import_set_state_nolock(imp, LUSTRE_IMP_NEW);
 			ptlrpc_reset_reqs_generation(imp);
 			connect = 1;
 		}
-- 
1.8.3.1
