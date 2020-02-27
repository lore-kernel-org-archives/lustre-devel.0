From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:52 -0500
Subject: [lustre-devel] [PATCH 424/622] lustre: import: fix race between
 imp_state & imp_invalid
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-425-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

We set import to LUSTRE_IMP_DISCON and then deactive when
it is unreplayable. Someone may set this import up between
those two operations. So we will get a invalid import with
FULL state.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11542
Lustre-commit: 29904135df67 ("LU-11542 import: fix race between imp_state & imp_invalid")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33395
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_ha.h      |   2 +-
 fs/lustre/lov/lov_obd.c            |   2 +-
 fs/lustre/ptlrpc/client.c          |   3 +-
 fs/lustre/ptlrpc/import.c          | 104 ++++++++++++++++++++++++-------------
 fs/lustre/ptlrpc/pinger.c          |  13 ++---
 fs/lustre/ptlrpc/ptlrpc_internal.h |   3 +-
 fs/lustre/ptlrpc/recover.c         |  14 ++---
 7 files changed, 80 insertions(+), 61 deletions(-)

diff --git a/fs/lustre/include/lustre_ha.h b/fs/lustre/include/lustre_ha.h
index af92a56..c914ef6 100644
--- a/fs/lustre/include/lustre_ha.h
+++ b/fs/lustre/include/lustre_ha.h
@@ -50,7 +50,7 @@
 void ptlrpc_wake_delayed(struct obd_import *imp);
 int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async);
 int ptlrpc_set_import_active(struct obd_import *imp, int active);
-void ptlrpc_activate_import(struct obd_import *imp);
+void ptlrpc_activate_import(struct obd_import *imp, bool set_state_full);
 void ptlrpc_deactivate_import(struct obd_import *imp);
 void ptlrpc_invalidate_import(struct obd_import *imp);
 void ptlrpc_fail_import(struct obd_import *imp, u32 conn_cnt);
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 234b556..3348380 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -157,7 +157,7 @@ int lov_connect_osc(struct obd_device *obd, u32 index, int activate,
 		/* FIXME this is probably supposed to be
 		 * ptlrpc_set_import_active.  Horrible naming.
 		 */
-		ptlrpc_activate_import(imp);
+		ptlrpc_activate_import(imp, false);
 	}
 
 	rc = obd_register_observer(tgt_obd, obd);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 9920a95..dcc5e6b 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -3033,7 +3033,7 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 	 * ptlrpc_{queue,set}_wait must (and does) hold imp_lock while testing
 	 * this flag and then putting requests on sending_list or delayed_list.
 	 */
-	spin_lock(&imp->imp_lock);
+	assert_spin_locked(&imp->imp_lock);
 
 	/*
 	 * XXX locking?  Maybe we should remove each request with the list
@@ -3071,7 +3071,6 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 	if (imp->imp_replayable)
 		ptlrpc_free_committed(imp);
 
-	spin_unlock(&imp->imp_lock);
 }
 
 /**
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 98c09f6..0ade41e 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -144,6 +144,17 @@ static void deuuidify(char *uuid, const char *prefix, char **uuid_start,
 		*uuid_len -= strlen(UUID_STR);
 }
 
+/* Must be called with imp_lock held! */
+static void ptlrpc_deactivate_import_nolock(struct obd_import *imp)
+{
+	assert_spin_locked(&imp->imp_lock);
+	CDEBUG(D_HA, "setting import %s INVALID\n", obd2cli_tgt(imp->imp_obd));
+	imp->imp_invalid = 1;
+	imp->imp_generation++;
+
+	ptlrpc_abort_inflight(imp);
+}
+
 /**
  * Returns true if import was FULL, false if import was already not
  * connected.
@@ -154,8 +165,10 @@ static void deuuidify(char *uuid, const char *prefix, char **uuid_start,
  *	     bulk requests) and if one has already caused a reconnection
  *	     (increasing the import->conn_cnt) the older failure should
  *	     not also cause a reconnection.  If zero it forces a reconnect.
+ * @invalid - set import invalid flag
  */
-int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
+int ptlrpc_set_import_discon(struct obd_import *imp,
+			     u32 conn_cnt, bool invalid)
 {
 	int rc = 0;
 
@@ -165,10 +178,12 @@ int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
 	    (conn_cnt == 0 || conn_cnt == imp->imp_conn_cnt)) {
 		char *target_start;
 		int   target_len;
+		bool inact = false;
 
 		deuuidify(obd2cli_tgt(imp->imp_obd), NULL,
 			  &target_start, &target_len);
 
+		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 		if (imp->imp_replayable) {
 			LCONSOLE_WARN("%s: Connection to %.*s (at %s) was lost; in progress operations using this service will wait for recovery to complete\n",
 				      imp->imp_obd->obd_name,
@@ -180,14 +195,25 @@ int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt)
 					   imp->imp_obd->obd_name,
 					   target_len, target_start,
 					   obd_import_nid2str(imp));
+			if (invalid) {
+				CDEBUG(D_HA,
+				       "import %s@%s for %s not replayable, auto-deactivating\n",
+				       obd2cli_tgt(imp->imp_obd),
+				       imp->imp_connection->c_remote_uuid.uuid,
+				       imp->imp_obd->obd_name);
+				ptlrpc_deactivate_import_nolock(imp);
+				inact = true;
+			}
 		}
-		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 		spin_unlock(&imp->imp_lock);
 
 		if (obd_dump_on_timeout)
 			libcfs_debug_dumplog();
 
 		obd_import_event(imp->imp_obd, imp, IMP_EVENT_DISCON);
+
+		if (inact)
+			obd_import_event(imp->imp_obd, imp, IMP_EVENT_INACTIVE);
 		rc = 1;
 	} else {
 		spin_unlock(&imp->imp_lock);
@@ -211,11 +237,9 @@ void ptlrpc_deactivate_import(struct obd_import *imp)
 	CDEBUG(D_HA, "setting import %s INVALID\n", obd2cli_tgt(imp->imp_obd));
 
 	spin_lock(&imp->imp_lock);
-	imp->imp_invalid = 1;
-	imp->imp_generation++;
+	ptlrpc_deactivate_import_nolock(imp);
 	spin_unlock(&imp->imp_lock);
 
-	ptlrpc_abort_inflight(imp);
 	obd_import_event(imp->imp_obd, imp, IMP_EVENT_INACTIVE);
 }
 EXPORT_SYMBOL(ptlrpc_deactivate_import);
@@ -379,17 +403,23 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 EXPORT_SYMBOL(ptlrpc_invalidate_import);
 
 /* unset imp_invalid */
-void ptlrpc_activate_import(struct obd_import *imp)
+void ptlrpc_activate_import(struct obd_import *imp, bool set_state_full)
 {
 	struct obd_device *obd = imp->imp_obd;
 
 	spin_lock(&imp->imp_lock);
 	if (imp->imp_deactive != 0) {
+		LASSERT(imp->imp_state != LUSTRE_IMP_FULL);
+		if (imp->imp_state != LUSTRE_IMP_DISCON)
+			import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 		spin_unlock(&imp->imp_lock);
 		return;
 	}
+	if (set_state_full)
+		import_set_state_nolock(imp, LUSTRE_IMP_FULL);
 
 	imp->imp_invalid = 0;
+
 	spin_unlock(&imp->imp_lock);
 	obd_import_event(obd, imp, IMP_EVENT_ACTIVE);
 }
@@ -413,18 +443,8 @@ void ptlrpc_fail_import(struct obd_import *imp, u32 conn_cnt)
 {
 	LASSERT(!imp->imp_dlm_fake);
 
-	if (ptlrpc_set_import_discon(imp, conn_cnt)) {
-		if (!imp->imp_replayable) {
-			CDEBUG(D_HA,
-			       "import %s@%s for %s not replayable, auto-deactivating\n",
-			       obd2cli_tgt(imp->imp_obd),
-			       imp->imp_connection->c_remote_uuid.uuid,
-			       imp->imp_obd->obd_name);
-			ptlrpc_deactivate_import(imp);
-		}
-
+	if (ptlrpc_set_import_discon(imp, conn_cnt, true))
 		ptlrpc_pinger_force(imp);
-	}
 }
 
 int ptlrpc_reconnect_import(struct obd_import *imp)
@@ -1073,12 +1093,10 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		spin_lock(&imp->imp_lock);
 		if (msg_flags & MSG_CONNECT_REPLAYABLE) {
 			imp->imp_replayable = 1;
-			spin_unlock(&imp->imp_lock);
 			CDEBUG(D_HA, "connected to replayable target: %s\n",
 			       obd2cli_tgt(imp->imp_obd));
 		} else {
 			imp->imp_replayable = 0;
-			spin_unlock(&imp->imp_lock);
 		}
 
 		/* if applies, adjust the imp->imp_msg_magic here
@@ -1095,10 +1113,11 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		if (msg_flags & MSG_CONNECT_RECOVERING) {
 			CDEBUG(D_HA, "connect to %s during recovery\n",
 			       obd2cli_tgt(imp->imp_obd));
-			import_set_state(imp, LUSTRE_IMP_REPLAY_LOCKS);
+			import_set_state_nolock(imp, LUSTRE_IMP_REPLAY_LOCKS);
+			spin_unlock(&imp->imp_lock);
 		} else {
-			import_set_state(imp, LUSTRE_IMP_FULL);
-			ptlrpc_activate_import(imp);
+			spin_unlock(&imp->imp_lock);
+			ptlrpc_activate_import(imp, true);
 		}
 
 		rc = 0;
@@ -1223,31 +1242,33 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	}
 
 out:
+	if (exp)
+		class_export_put(exp);
+
 	spin_lock(&imp->imp_lock);
 	imp->imp_connected = 0;
 	imp->imp_connect_tried = 1;
-	spin_unlock(&imp->imp_lock);
 
-	if (exp)
-		class_export_put(exp);
+	if (rc) {
+		bool inact = false;
 
-	if (rc != 0) {
-		import_set_state(imp, LUSTRE_IMP_DISCON);
+		import_set_state_nolock(imp, LUSTRE_IMP_DISCON);
 		if (rc == -EACCES) {
 			/*
 			 * Give up trying to reconnect
 			 * EACCES means client has no permission for connection
 			 */
 			imp->imp_obd->obd_no_recov = 1;
-			ptlrpc_deactivate_import(imp);
-		}
-
-		if (rc == -EPROTO) {
+			ptlrpc_deactivate_import_nolock(imp);
+			inact = true;
+		} else if (rc == -EPROTO) {
 			struct obd_connect_data *ocd;
 
 			/* reply message might not be ready */
-			if (!request->rq_repmsg)
+			if (!request->rq_repmsg) {
+				spin_unlock(&imp->imp_lock);
 				return -EPROTO;
+			}
 
 			ocd = req_capsule_server_get(&request->rq_pill,
 						     &RMF_CONNECT_DATA);
@@ -1267,17 +1288,26 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 						   OBD_OCD_VERSION_PATCH(ocd->ocd_version),
 						   OBD_OCD_VERSION_FIX(ocd->ocd_version),
 						   LUSTRE_VERSION_STRING);
-				ptlrpc_deactivate_import(imp);
-				import_set_state(imp, LUSTRE_IMP_CLOSED);
+				ptlrpc_deactivate_import_nolock(imp);
+				import_set_state_nolock(imp, LUSTRE_IMP_CLOSED);
+				inact = true;
 			}
-			return -EPROTO;
 		}
+		spin_unlock(&imp->imp_lock);
+
+		if (inact)
+			obd_import_event(imp->imp_obd, imp, IMP_EVENT_INACTIVE);
+
+		if (rc == -EPROTO)
+			return rc;
 
 		ptlrpc_maybe_ping_import_soon(imp);
 
 		CDEBUG(D_HA, "recovery of %s on %s failed (%d)\n",
 		       obd2cli_tgt(imp->imp_obd),
 		       (char *)imp->imp_connection->c_remote_uuid.uuid, rc);
+	} else {
+		spin_unlock(&imp->imp_lock);
 	}
 
 	wake_up_all(&imp->imp_recovery_waitq);
@@ -1476,8 +1506,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		rc = ptlrpc_resend(imp);
 		if (rc)
 			goto out;
-		import_set_state(imp, LUSTRE_IMP_FULL);
-		ptlrpc_activate_import(imp);
+		ptlrpc_activate_import(imp, true);
 
 		deuuidify(obd2cli_tgt(imp->imp_obd), NULL,
 			  &target_start, &target_len);
@@ -1684,6 +1713,7 @@ int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
 		return 0;
 
 	spin_lock(&imp->imp_lock);
+
 	if (imp->imp_state != LUSTRE_IMP_FULL) {
 		spin_unlock(&imp->imp_lock);
 		return 0;
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index c3fbddc..a812942 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -217,8 +217,6 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 	imp->imp_force_next_verify = 0;
 
-	spin_unlock(&imp->imp_lock);
-
 	CDEBUG(level == LUSTRE_IMP_FULL ? D_INFO : D_HA,
 	       "%s->%s: level %s/%u force %u force_next %u deactive %u pingable %u suppress %u\n",
 	       imp->imp_obd->obd_uuid.uuid, obd2cli_tgt(imp->imp_obd),
@@ -228,22 +226,21 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 	if (level == LUSTRE_IMP_DISCON && !imp_is_deactive(imp)) {
 		/* wait for a while before trying recovery again */
 		imp->imp_next_ping = ptlrpc_next_reconnect(imp);
+		spin_unlock(&imp->imp_lock);
 		if (!imp->imp_no_pinger_recover ||
 		    imp->imp_connect_error == -EAGAIN)
 			ptlrpc_initiate_recovery(imp);
-	} else if (level != LUSTRE_IMP_FULL ||
-		   imp->imp_obd->obd_no_recov ||
+	} else if (level != LUSTRE_IMP_FULL || imp->imp_obd->obd_no_recov ||
 		   imp_is_deactive(imp)) {
 		CDEBUG(D_HA,
 		       "%s->%s: not pinging (in recovery or recovery disabled: %s)\n",
 		       imp->imp_obd->obd_uuid.uuid, obd2cli_tgt(imp->imp_obd),
 		       ptlrpc_import_state_name(level));
-		if (force) {
-			spin_lock(&imp->imp_lock);
+		if (force)
 			imp->imp_force_verify = 1;
-			spin_unlock(&imp->imp_lock);
-		}
+		spin_unlock(&imp->imp_lock);
 	} else if ((imp->imp_pingable && !suppress) || force_next || force) {
+		spin_unlock(&imp->imp_lock);
 		ptlrpc_ping(imp);
 	}
 }
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index f84d278..9e74d71 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -83,7 +83,8 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 void ptlrpc_request_handle_notconn(struct ptlrpc_request *req);
 void lustre_assert_wire_constants(void);
 int ptlrpc_import_in_recovery(struct obd_import *imp);
-int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt);
+int ptlrpc_set_import_discon(struct obd_import *imp, u32 conn_cnt,
+			     bool invalid);
 int ptlrpc_replay_next(struct obd_import *imp, int *inflight);
 void ptlrpc_initiate_recovery(struct obd_import *imp);
 
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index e26612d..e6e6661 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -224,21 +224,13 @@ void ptlrpc_wake_delayed(struct obd_import *imp)
 void ptlrpc_request_handle_notconn(struct ptlrpc_request *failed_req)
 {
 	struct obd_import *imp = failed_req->rq_import;
+	int conn = lustre_msg_get_conn_cnt(failed_req->rq_reqmsg);
 
 	CDEBUG(D_HA, "import %s of %s@%s abruptly disconnected: reconnecting\n",
 	       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
 	       imp->imp_connection->c_remote_uuid.uuid);
 
-	if (ptlrpc_set_import_discon(imp,
-			      lustre_msg_get_conn_cnt(failed_req->rq_reqmsg))) {
-		if (!imp->imp_replayable) {
-			CDEBUG(D_HA,
-			       "import %s@%s for %s not replayable, auto-deactivating\n",
-			       obd2cli_tgt(imp->imp_obd),
-			       imp->imp_connection->c_remote_uuid.uuid,
-			       imp->imp_obd->obd_name);
-			ptlrpc_deactivate_import(imp);
-		}
+	if (ptlrpc_set_import_discon(imp, conn, true)) {
 		/* to control recovery via lctl {disable|enable}_recovery */
 		if (imp->imp_deactive == 0)
 			ptlrpc_connect_import(imp);
@@ -317,7 +309,7 @@ int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async)
 		goto out;
 
 	/* force import to be disconnected. */
-	ptlrpc_set_import_discon(imp, 0);
+	ptlrpc_set_import_discon(imp, 0, false);
 
 	if (new_uuid) {
 		struct obd_uuid uuid;
-- 
1.8.3.1
