From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:53 -0500
Subject: [lustre-devel] [PATCH 20/28] lustre: ptlrpc: don't log connection
 'restored' inappropriately
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Aurelien Degremont <degremoa@amazon.com>

Reverse imports maintain a target->client connection which
does not support recovery as client don't run a recovery.
At every connection, the reverse import state goes from
NEW to RECOVER to FULL which triggers a `Connection restored`
log message, even if this is the first connection from
this client.

Suppress this log message for reverse import to avoid
this wrong logging.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14057
Lustre-commit: 2135f46b816223 ("LU-14057 ptlrpc: don't log connection 'restored' inappropriately")
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/40331
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/import.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 21ce593..35c4f83 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1590,12 +1590,16 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 			goto out;
 		ptlrpc_activate_import(imp, true);
 
-		CDEBUG_LIMIT(imp->imp_was_idle ?
-				imp->imp_idle_debug : D_CONSOLE,
-			     "%s: Connection restored to %s (at %s)\n",
-			     imp->imp_obd->obd_name,
-			     obd_uuid2str(&conn->c_remote_uuid),
-			     obd_import_nid2str(imp));
+		/* Reverse import are flagged with dlm_fake == 1.
+		 * They do not do recovery and connection are not "restored".
+		 */
+		if (!imp->imp_dlm_fake)
+			CDEBUG_LIMIT(imp->imp_was_idle ?
+				     imp->imp_idle_debug : D_CONSOLE,
+				     "%s: Connection restored to %s (at %s)\n",
+				     imp->imp_obd->obd_name,
+				     obd_uuid2str(&conn->c_remote_uuid),
+				     obd_import_nid2str(imp));
 		spin_lock(&imp->imp_lock);
 		imp->imp_was_idle = 0;
 		spin_unlock(&imp->imp_lock);
-- 
1.8.3.1
