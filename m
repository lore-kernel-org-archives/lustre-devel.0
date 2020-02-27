From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:51 -0500
Subject: [lustre-devel] [PATCH 483/622] lustre: ptlrpc: Hold imp lock for
 idle reconnect
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-484-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Idle reconnect sets import state to IMP_NEW, then releases
the import lock before calling ptlrpc_connect_import.  This
creates a gap where an import in IMP_NEW state is exposed,
which can cause new requests to fail with EIO.

Hold the lock across the call so as not to expose imports
in this state.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12559
Lustre-commit: e9472c54ac82 ("LU-12559 ptlrpc: Hold imp lock for idle reconnect")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35530
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  1 +
 fs/lustre/ptlrpc/client.c      | 13 ++++++-------
 fs/lustre/ptlrpc/import.c      | 19 +++++++++++++++----
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index aaf5cb8..8dad08e 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2015,6 +2015,7 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
  * @{
  */
 int ptlrpc_connect_import(struct obd_import *imp);
+int ptlrpc_connect_import_locked(struct obd_import *imp);
 int ptlrpc_init_import(struct obd_import *imp);
 int ptlrpc_disconnect_import(struct obd_import *imp, int noclose);
 int ptlrpc_disconnect_and_idle_import(struct obd_import *imp);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 478ba85..c359ac0 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -870,7 +870,6 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 			      const struct req_format *format)
 {
 	struct ptlrpc_request *request;
-	int connect = 0;
 
 	request = __ptlrpc_request_alloc(imp, pool);
 	if (!request)
@@ -890,17 +889,17 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 		if (imp->imp_state == LUSTRE_IMP_IDLE) {
 			imp->imp_generation++;
 			imp->imp_initiated_at = imp->imp_generation;
-			imp->imp_state =  LUSTRE_IMP_NEW;
-			connect = 1;
-		}
-		spin_unlock(&imp->imp_lock);
-		if (connect) {
-			rc = ptlrpc_connect_import(imp);
+			imp->imp_state = LUSTRE_IMP_NEW;
+
+			/* connect_import_locked releases imp_lock */
+			rc = ptlrpc_connect_import_locked(imp);
 			if (rc < 0) {
 				ptlrpc_request_free(request);
 				return NULL;
 			}
 			ptlrpc_pinger_add_import(imp);
+		} else {
+			spin_unlock(&imp->imp_lock);
 		}
 	}
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index ff1b810..c4a732d 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -611,13 +611,22 @@ static int ptlrpc_first_transno(struct obd_import *imp, u64 *transno)
 	return 0;
 }
 
+int ptlrpc_connect_import(struct obd_import *imp)
+{
+	spin_lock(&imp->imp_lock);
+	return ptlrpc_connect_import_locked(imp);
+}
+
 /**
  * Attempt to (re)connect import @imp. This includes all preparations,
  * initializing CONNECT RPC request and passing it to ptlrpcd for
  * actual sending.
+ *
+ * Assumes imp->imp_lock is held, and releases it.
+ *
  * Returns 0 on success or error code.
  */
-int ptlrpc_connect_import(struct obd_import *imp)
+int ptlrpc_connect_import_locked(struct obd_import *imp)
 {
 	struct obd_device *obd = imp->imp_obd;
 	int initial_connect = 0;
@@ -634,7 +643,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	struct ptlrpc_connect_async_args *aa;
 	int rc;
 
-	spin_lock(&imp->imp_lock);
+	assert_spin_locked(&imp->imp_lock);
+
 	if (imp->imp_state == LUSTRE_IMP_CLOSED) {
 		spin_unlock(&imp->imp_lock);
 		CERROR("can't connect to a closed import\n");
@@ -1701,12 +1711,13 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 			connect = 1;
 		}
 	}
-	spin_unlock(&imp->imp_lock);
 
 	if (connect) {
-		rc = ptlrpc_connect_import(imp);
+		rc = ptlrpc_connect_import_locked(imp);
 		if (rc >= 0)
 			ptlrpc_pinger_add_import(imp);
+	} else {
+		spin_unlock(&imp->imp_lock);
 	}
 
 	return 0;
-- 
1.8.3.1
