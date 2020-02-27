From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:35 -0500
Subject: [lustre-devel] [PATCH 587/622] lustre: ptlrpc: suppress connection
 restored message
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-588-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

if that happens on idling connection.

Fixes: 4b102da53ad ("lustre: ptlrpc: idle connections can disconnect")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13098
Lustre-commit: 7aa58847b94d ("LU-13098 ptlrpc: supress connection restored message")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37086
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  8 ++++++--
 fs/lustre/ptlrpc/import.c         | 25 ++++++++++++++++---------
 2 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 501a896..5d548a6 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -304,8 +304,12 @@ struct obd_import {
 					imp_connect_tried:1,
 					/* connected but not FULL yet */
 					imp_connected:1,
-				  /* grant shrink disabled */
-				  imp_grant_shrink_disabled:1;
+					/* grant shrink disabled */
+					imp_grant_shrink_disabled:1,
+					/* to suppress LCONSOLE() at
+					 * conn.restore
+					 */
+					imp_was_idle:1;
 
 	u32				imp_connect_op;
 	u32				imp_idle_timeout;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 028dd65..23dac39 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1519,21 +1519,22 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 			import_set_state(imp, LUSTRE_IMP_RECOVER);
 
 	if (imp->imp_state == LUSTRE_IMP_RECOVER) {
-		CDEBUG(D_HA, "reconnected to %s@%s\n",
-		       obd2cli_tgt(imp->imp_obd),
-		       imp->imp_connection->c_remote_uuid.uuid);
+		struct ptlrpc_connection *conn = imp->imp_connection;
 
 		rc = ptlrpc_resend(imp);
 		if (rc)
 			goto out;
 		ptlrpc_activate_import(imp, true);
 
-		deuuidify(obd2cli_tgt(imp->imp_obd), NULL,
-			  &target_start, &target_len);
-		LCONSOLE_INFO("%s: Connection restored to %.*s (at %s)\n",
-			      imp->imp_obd->obd_name,
-			      target_len, target_start,
-			      obd_import_nid2str(imp));
+		CDEBUG_LIMIT(imp->imp_was_idle ?
+				imp->imp_idle_debug : D_CONSOLE,
+			     "%s: Connection restored to %s (at %s)\n",
+			     imp->imp_obd->obd_name,
+			     obd_uuid2str(&conn->c_remote_uuid),
+			     obd_import_nid2str(imp));
+		spin_lock(&imp->imp_lock);
+		imp->imp_was_idle = 0;
+		spin_unlock(&imp->imp_lock);
 	}
 
 	if (imp->imp_state == LUSTRE_IMP_FULL) {
@@ -1749,6 +1750,12 @@ int ptlrpc_disconnect_and_idle_import(struct obd_import *imp)
 	CDEBUG_LIMIT(imp->imp_idle_debug, "%s: disconnect after %llus idle\n",
 		     imp->imp_obd->obd_name,
 		     ktime_get_real_seconds() - imp->imp_last_reply_time);
+
+	/* don't make noise at reconnection */
+	spin_lock(&imp->imp_lock);
+	imp->imp_was_idle = 1;
+	spin_unlock(&imp->imp_lock);
+
 	req->rq_interpret_reply = ptlrpc_disconnect_idle_interpret;
 	ptlrpcd_add_req(req);
 
-- 
1.8.3.1
