From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:49 -0500
Subject: [lustre-devel] [PATCH 121/622] lustre: ptlrpc: new request vs
 disconnect race
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-122-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

new request can race with disconnect-by-idle process.
disconnect code detect this state and initiate a new connection.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11128
Lustre-commit: 93d20d171c20 ("LU-11128 ptlrpc: new request vs disconnect race")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32980
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 15 ++++++++++-----
 fs/lustre/ptlrpc/import.c | 32 +++++++++++++++++++++++++++++---
 2 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 691df1a..7be597c 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -887,6 +887,13 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 	struct ptlrpc_request *request;
 	int connect = 0;
 
+	request = __ptlrpc_request_alloc(imp, pool);
+	if (!request)
+		return NULL;
+
+	/* initiate connection if needed when the import has been
+	 * referenced by the new request to avoid races with disconnect
+	 */
 	if (unlikely(imp->imp_state == LUSTRE_IMP_IDLE)) {
 		int rc;
 
@@ -904,16 +911,14 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 		spin_unlock(&imp->imp_lock);
 		if (connect) {
 			rc = ptlrpc_connect_import(imp);
-			if (rc < 0)
+			if (rc < 0) {
+				ptlrpc_request_free(request);
 				return NULL;
+			}
 			ptlrpc_pinger_add_import(imp);
 		}
 	}
 
-	request = __ptlrpc_request_alloc(imp, pool);
-	if (!request)
-		return NULL;
-
 	req_capsule_init(&request->rq_pill, request, RCL_CLIENT);
 	req_capsule_set(&request->rq_pill, format);
 	return request;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 73a345f..f59af80 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1593,13 +1593,39 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 					    void *data, int rc)
 {
 	struct obd_import *imp = req->rq_import;
+	int connect = 0;
+
+	DEBUG_REQ(D_HA, req, "inflight=%d, refcount=%d: rc = %d\n",
+		  atomic_read(&imp->imp_inflight),
+		  atomic_read(&imp->imp_refcount), rc);
 
-	LASSERT(imp->imp_state == LUSTRE_IMP_CONNECTING);
 	spin_lock(&imp->imp_lock);
-	IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_IDLE);
-	memset(&imp->imp_remote_handle, 0, sizeof(imp->imp_remote_handle));
+	/* DISCONNECT reply can be late and another connection can just
+	 * be initiated. so we have to abort disconnection.
+	 */
+	if (req->rq_import_generation == imp->imp_generation &&
+	    imp->imp_state != LUSTRE_IMP_CLOSED) {
+		LASSERTF(imp->imp_state == LUSTRE_IMP_CONNECTING,
+			 "%s\n", ptlrpc_import_state_name(imp->imp_state));
+		imp->imp_state = LUSTRE_IMP_IDLE;
+		memset(&imp->imp_remote_handle, 0,
+		       sizeof(imp->imp_remote_handle));
+		/* take our DISCONNECT into account */
+		if (atomic_read(&imp->imp_inflight) > 1) {
+			imp->imp_generation++;
+			imp->imp_initiated_at = imp->imp_generation;
+			IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_NEW);
+			connect = 1;
+		}
+	}
 	spin_unlock(&imp->imp_lock);
 
+	if (connect) {
+		rc = ptlrpc_connect_import(imp);
+		if (rc >= 0)
+			ptlrpc_pinger_add_import(imp);
+	}
+
 	return 0;
 }
 
-- 
1.8.3.1
