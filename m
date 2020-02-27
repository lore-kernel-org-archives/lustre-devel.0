From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:25 -0500
Subject: [lustre-devel] [PATCH 217/622] lustre: ptlrpc: reset generation for
 old requests
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-218-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

All requests generated while the import is changing from
FULL to IDLE need to be moved to the new generation.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11951
Lustre-commit: 42d8cb04637b ("LU-11951 ptlrpc: reset generation for old requests")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34221
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ptlrpc/import.c       | 20 +++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index d9a0395..5e5cf3a 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -263,6 +263,7 @@
 #define OBD_FAIL_OST_DQACQ_NET				0x230
 #define OBD_FAIL_OST_STATFS_EINPROGRESS			0x231
 #define OBD_FAIL_OST_SET_INFO_NET			0x232
+#define OBD_FAIL_OST_DISCONNECT_DELAY	 0x245
 
 #define OBD_FAIL_LDLM					0x300
 #define OBD_FAIL_LDLM_NAMESPACE_NEW			0x301
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index df6c459..34a2cb0 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1593,6 +1593,23 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 }
 EXPORT_SYMBOL(ptlrpc_disconnect_import);
 
+static void ptlrpc_reset_reqs_generation(struct obd_import *imp)
+{
+	struct ptlrpc_request *old, *tmp;
+
+	/* tag all resendable requests generated before disconnection
+	 * notice this code is part of disconnect-at-idle path only
+	 */
+	list_for_each_entry_safe(old, tmp, &imp->imp_delayed_list,
+			rq_list) {
+		spin_lock(&old->rq_lock);
+		if (old->rq_import_generation == imp->imp_generation - 1 &&
+		    !old->rq_no_resend)
+			old->rq_import_generation = imp->imp_generation;
+		spin_unlock(&old->rq_lock);
+	}
+}
+
 static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 					    struct ptlrpc_request *req,
 					    void *args, int rc)
@@ -1600,7 +1617,7 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 	struct obd_import *imp = req->rq_import;
 	int connect = 0;
 
-	DEBUG_REQ(D_HA, req, "inflight=%d, refcount=%d: rc = %d\n",
+	DEBUG_REQ(D_HA, req, "inflight=%d, refcount=%d: rc = %d ",
 		  atomic_read(&imp->imp_inflight),
 		  atomic_read(&imp->imp_refcount), rc);
 
@@ -1620,6 +1637,7 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 			imp->imp_generation++;
 			imp->imp_initiated_at = imp->imp_generation;
 			IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_NEW);
+			ptlrpc_reset_reqs_generation(imp);
 			connect = 1;
 		}
 	}
-- 
1.8.3.1
