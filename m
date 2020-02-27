From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:38 -0500
Subject: [lustre-devel] [PATCH 590/622] lustre: ldlm: signal vs CP callback
 race
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-591-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

In case of interrupted wait for a CP AST
failed_lock_cleanup() sets LDLM_FL_LOCAL_ONLY, so
the client wouldn't cancel the lock on CP AST.

A lock isn't canceled on the server on reception

Cray-bug-id: LUS-2021
WC-bug-id: https://jira.whamcloud.com/browse/LU-7791
Lustre-commit: 7fff052c930d ("LU-7791 ldlm: signal vs CP callback race")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/19898
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ldlm/ldlm_lockd.c     | 51 +++++++++++++++++++++++++----------------
 fs/lustre/ldlm/ldlm_request.c   |  3 +++
 3 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index a26ac76..7dfef0f 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -302,6 +302,7 @@
 #define OBD_FAIL_LDLM_CP_CB_WAIT3			0x321
 #define OBD_FAIL_LDLM_CP_CB_WAIT4			0x322
 #define OBD_FAIL_LDLM_CP_CB_WAIT5			0x323
+#define OBD_FAIL_LDLM_PAUSE_CANCEL_LOCAL		0x329
 
 #define OBD_FAIL_LDLM_GRANT_CHECK			0x32a
 #define OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE		0x32c
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 32b7be1..b252fef 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -187,15 +187,29 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 	LDLM_LOCK_RELEASE(lock);
 }
 
+static int ldlm_callback_reply(struct ptlrpc_request *req, int rc)
+{
+	if (req->rq_no_reply)
+		return 0;
+
+	req->rq_status = rc;
+	if (!req->rq_packed_final) {
+		rc = lustre_pack_reply(req, 1, NULL, NULL);
+		if (rc)
+			return rc;
+	}
+	return ptlrpc_reply(req);
+}
+
 /*
  * Callback handler for receiving incoming completion ASTs.
  *
  * This only can happen on client side.
  */
-static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
-				    struct ldlm_namespace *ns,
-				    struct ldlm_request *dlm_req,
-				    struct ldlm_lock *lock)
+static int ldlm_handle_cp_callback(struct ptlrpc_request *req,
+				   struct ldlm_namespace *ns,
+				   struct ldlm_request *dlm_req,
+				   struct ldlm_lock *lock)
 {
 	int lvb_len;
 	LIST_HEAD(ast_list);
@@ -206,6 +220,8 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE)) {
 		long to = HZ;
 
+		ldlm_callback_reply(req, 0);
+
 		while (to > 0) {
 			schedule_timeout_interruptible(to);
 			if (ldlm_is_granted(lock) ||
@@ -250,6 +266,12 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 		lock_res_and_lock(lock);
 	}
 
+	if (ldlm_is_failed(lock)) {
+		unlock_res_and_lock(lock);
+		LDLM_LOCK_RELEASE(lock);
+		return -EINVAL;
+	}
+
 	if (ldlm_is_destroyed(lock) ||
 	    ldlm_is_granted(lock)) {
 		/* bug 11300: the lock has already been granted */
@@ -321,6 +343,8 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 		wake_up(&lock->l_waitq);
 	}
 	LDLM_LOCK_RELEASE(lock);
+
+	return 0;
 }
 
 /**
@@ -373,20 +397,6 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 	LDLM_LOCK_RELEASE(lock);
 }
 
-static int ldlm_callback_reply(struct ptlrpc_request *req, int rc)
-{
-	if (req->rq_no_reply)
-		return 0;
-
-	req->rq_status = rc;
-	if (!req->rq_packed_final) {
-		rc = lustre_pack_reply(req, 1, NULL, NULL);
-		if (rc)
-			return rc;
-	}
-	return ptlrpc_reply(req);
-}
-
 static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
 			       enum ldlm_cancel_flags cancel_flags)
 {
@@ -714,8 +724,9 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	case LDLM_CP_CALLBACK:
 		CDEBUG(D_INODE, "completion ast\n");
 		req_capsule_extend(&req->rq_pill, &RQF_LDLM_CP_CALLBACK);
-		ldlm_callback_reply(req, 0);
-		ldlm_handle_cp_callback(req, ns, dlm_req, lock);
+		rc = ldlm_handle_cp_callback(req, ns, dlm_req, lock);
+		if (!OBD_FAIL_CHECK(OBD_FAIL_LDLM_CANCEL_BL_CB_RACE))
+			ldlm_callback_reply(req, rc);
 		break;
 	case LDLM_GL_CALLBACK:
 		CDEBUG(D_INODE, "glimpse ast\n");
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 7eba8d2..fcb2af5 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -964,6 +964,9 @@ static u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 		bool local_only;
 
 		LDLM_DEBUG(lock, "client-side cancel");
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL_LOCAL,
+				 cfs_fail_val);
+
 		/* Set this flag to prevent others from getting new references*/
 		lock_res_and_lock(lock);
 		ldlm_set_cbpending(lock);
-- 
1.8.3.1
