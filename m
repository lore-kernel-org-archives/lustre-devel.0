From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:56 -0500
Subject: [lustre-devel] [PATCH 188/622] lustre: ptlrpc: clean up
 rq_interpret_reply callbacks
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-189-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Clean up the function prototypes of several rq_interpret_reply
callback functions to match the function pointer type instead
of using typecasting to avoid the risk of bad function pointers.

Clean up related code to match code style.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11398
Lustre-commit: 4014ddbb2350 ("LU-11398 ptlrpc: clean up rq_interpret_reply callbacks")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33203
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 11 +++++----
 fs/lustre/mdc/mdc_dev.c       | 10 ++++----
 fs/lustre/osc/osc_io.c        |  4 ++--
 fs/lustre/osc/osc_request.c   | 53 +++++++++++++++++++++++--------------------
 fs/lustre/ptlrpc/client.c     | 13 ++++-------
 fs/lustre/ptlrpc/import.c     |  9 ++++----
 6 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 1afe9a5..b9e9ae9 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -826,8 +826,9 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
  */
 static int lock_convert_interpret(const struct lu_env *env,
 				  struct ptlrpc_request *req,
-				  struct ldlm_async_args *aa, int rc)
+				  void *args, int rc)
 {
+	struct ldlm_async_args *aa = args;
 	struct ldlm_lock *lock;
 	struct ldlm_reply *reply;
 
@@ -1010,7 +1011,7 @@ int ldlm_cli_convert(struct ldlm_lock *lock, u32 *flags)
 
 	aa = ptlrpc_req_async_args(aa, req);
 	ldlm_lock2handle(lock, &aa->lock_handle);
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)lock_convert_interpret;
+	req->rq_interpret_reply = lock_convert_interpret;
 
 	ptlrpcd_add_req(req);
 	return 0;
@@ -2117,9 +2118,9 @@ static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
 }
 
 static int replay_lock_interpret(const struct lu_env *env,
-				 struct ptlrpc_request *req,
-				 struct ldlm_async_args *aa, int rc)
+				 struct ptlrpc_request *req, void *args, int rc)
 {
+	struct ldlm_async_args *aa = args;
 	struct ldlm_lock *lock;
 	struct ldlm_reply *reply;
 	struct obd_export *exp;
@@ -2234,7 +2235,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	atomic_inc(&req->rq_import->imp_replay_inflight);
 	aa = ptlrpc_req_async_args(aa, req);
 	aa->lock_handle = body->lock_handle[0];
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)replay_lock_interpret;
+	req->rq_interpret_reply = replay_lock_interpret;
 	ptlrpcd_add_req(req);
 
 	return 0;
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 21dc83e..306b917 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -602,8 +602,9 @@ int mdc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
 }
 
 int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			  struct osc_enqueue_args *aa, int rc)
+			  void *args, int rc)
 {
+	struct osc_enqueue_args *aa = args;
 	struct ldlm_lock *lock;
 	struct lustre_handle *lockh = &aa->oa_lockh;
 	enum ldlm_mode mode = aa->oa_mode;
@@ -745,8 +746,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 			aa->oa_flags = flags;
 			aa->oa_lvb = lvb;
 
-			req->rq_interpret_reply =
-				(ptlrpc_interpterer_t)mdc_enqueue_interpret;
+			req->rq_interpret_reply = mdc_enqueue_interpret;
 			ptlrpcd_add_req(req);
 		} else {
 			ptlrpc_req_finished(req);
@@ -1121,9 +1121,9 @@ struct mdc_data_version_args {
 
 static int
 mdc_data_version_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			   void *arg, int rc)
+			   void *args, int rc)
 {
-	struct mdc_data_version_args *dva = arg;
+	struct mdc_data_version_args *dva = args;
 	struct osc_io *oio = dva->dva_oio;
 	const struct mdt_body *body;
 
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 56f30cb..76657f3 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -656,9 +656,9 @@ struct osc_data_version_args {
 
 static int
 osc_data_version_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			   void *arg, int rc)
+			   void *args, int rc)
 {
-	struct osc_data_version_args *dva = arg;
+	struct osc_data_version_args *dva = args;
 	struct osc_io *oio = dva->dva_oio;
 	const struct ost_body *body;
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 1fc7a57..ba84bd1 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -188,9 +188,9 @@ static int osc_setattr(const struct lu_env *env, struct obd_export *exp,
 }
 
 static int osc_setattr_interpret(const struct lu_env *env,
-				 struct ptlrpc_request *req,
-				 struct osc_setattr_args *sa, int rc)
+				 struct ptlrpc_request *req, void *args, int rc)
 {
+	struct osc_setattr_args *sa = args;
 	struct ost_body *body;
 
 	if (rc != 0)
@@ -236,8 +236,7 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		/* Do not wait for response. */
 		ptlrpcd_add_req(req);
 	} else {
-		req->rq_interpret_reply =
-			(ptlrpc_interpterer_t)osc_setattr_interpret;
+		req->rq_interpret_reply = osc_setattr_interpret;
 
 		sa = ptlrpc_req_async_args(sa, req);
 		sa->sa_oa = oa;
@@ -417,7 +416,7 @@ int osc_punch_send(struct obd_export *exp, struct obdo *oa,
 
 	ptlrpc_request_set_replen(req);
 
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
+	req->rq_interpret_reply = osc_setattr_interpret;
 	sa = ptlrpc_req_async_args(sa, req);
 	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
@@ -545,13 +544,13 @@ static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 }
 
 static int osc_destroy_interpret(const struct lu_env *env,
-				 struct ptlrpc_request *req, void *data,
-				 int rc)
+				 struct ptlrpc_request *req, void *args, int rc)
 {
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
 
 	atomic_dec(&cli->cl_destroy_in_flight);
 	wake_up(&cli->cl_destroy_waitq);
+
 	return 0;
 }
 
@@ -734,14 +733,14 @@ struct grant_thread_data {
 
 static int osc_shrink_grant_interpret(const struct lu_env *env,
 				      struct ptlrpc_request *req,
-				      void *aa, int rc)
+				      void *args, int rc)
 {
+	struct osc_brw_async_args *aa = args;
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
-	struct obdo *oa = ((struct osc_brw_async_args *)aa)->aa_oa;
 	struct ost_body *body;
 
 	if (rc != 0) {
-		__osc_update_grant(cli, oa->o_grant);
+		__osc_update_grant(cli, aa->aa_oa->o_grant);
 		goto out;
 	}
 
@@ -749,7 +748,8 @@ static int osc_shrink_grant_interpret(const struct lu_env *env,
 	LASSERT(body);
 	osc_update_grant(cli, body);
 out:
-	kmem_cache_free(osc_obdo_kmem, oa);
+	kmem_cache_free(osc_obdo_kmem, aa->aa_oa);
+
 	return rc;
 }
 
@@ -1951,7 +1951,8 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 				 request, oap->oap_request);
 		}
 	}
-	/* New request takes over pga and oaps from old request.
+	/*
+	 * New request takes over pga and oaps from old request.
 	 * Note that copying a list_head doesn't work, need to move it...
 	 */
 	aa->aa_resends++;
@@ -2034,9 +2035,9 @@ static void osc_release_ppga(struct brw_page **ppga, u32 count)
 }
 
 static int brw_interpret(const struct lu_env *env,
-			 struct ptlrpc_request *req, void *data, int rc)
+			 struct ptlrpc_request *req, void *args, int rc)
 {
-	struct osc_brw_async_args *aa = data;
+	struct osc_brw_async_args *aa = args;
 	struct osc_extent *ext;
 	struct osc_extent *tmp;
 	struct client_obd *cli = aa->aa_cli;
@@ -2044,7 +2045,8 @@ static int brw_interpret(const struct lu_env *env,
 
 	rc = osc_brw_fini_request(req, rc);
 	CDEBUG(D_INODE, "request %p aa %p rc %d\n", req, aa, rc);
-	/* When server return -EINPROGRESS, client should always retry
+	/*
+	 * When server returns -EINPROGRESS, client should always retry
 	 * regardless of the number of times the bulk was resent already.
 	 */
 	if (osc_recoverable_error(rc) && !req->rq_no_delay) {
@@ -2425,8 +2427,9 @@ int osc_enqueue_fini(struct ptlrpc_request *req, osc_enqueue_upcall_f upcall,
 }
 
 int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			  struct osc_enqueue_args *aa, int rc)
+			  void *args, int rc)
 {
+	struct osc_enqueue_args *aa = args;
 	struct ldlm_lock *lock;
 	struct lustre_handle *lockh = &aa->oa_lockh;
 	enum ldlm_mode mode = aa->oa_mode;
@@ -2627,8 +2630,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 				aa->oa_flags = NULL;
 			}
 
-			req->rq_interpret_reply =
-				(ptlrpc_interpterer_t)osc_enqueue_interpret;
+			req->rq_interpret_reply = osc_enqueue_interpret;
 			ptlrpc_set_add_req(rqset, req);
 		} else if (intent) {
 			ptlrpc_req_finished(req);
@@ -2690,16 +2692,16 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 static int osc_statfs_interpret(const struct lu_env *env,
 				struct ptlrpc_request *req,
-				struct osc_async_args *aa, int rc)
+				void *args, int rc)
 {
+	struct osc_async_args *aa = args;
 	struct obd_statfs *msfs;
 
 	if (rc == -EBADR)
-		/* The request has in fact never been sent
-		 * due to issues at a higher level (LOV).
-		 * Exit immediately since the caller is
-		 * aware of the problem and takes care
-		 * of the clean up
+		/* The request has in fact never been sent due to
+		 * issues at a higher level (LOV).  Exit immediately
+		 * since the caller is aware of the problem and takes
+		 * care of the clean up
 		 */
 		return rc;
 
@@ -2721,6 +2723,7 @@ static int osc_statfs_interpret(const struct lu_env *env,
 	*aa->aa_oi->oi_osfs = *msfs;
 out:
 	rc = aa->aa_oi->oi_cb_up(aa->aa_oi, rc);
+
 	return rc;
 }
 
@@ -2759,7 +2762,7 @@ static int osc_statfs_async(struct obd_export *exp,
 		req->rq_no_delay = 1;
 	}
 
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_statfs_interpret;
+	req->rq_interpret_reply = osc_statfs_interpret;
 	aa = ptlrpc_req_async_args(aa, req);
 	aa->aa_oi = oinfo;
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index fabe675..ff212a3 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2872,9 +2872,9 @@ int ptlrpc_queue_wait(struct ptlrpc_request *req)
  */
 static int ptlrpc_replay_interpret(const struct lu_env *env,
 				   struct ptlrpc_request *req,
-				   void *data, int rc)
+				   void *args, int rc)
 {
-	struct ptlrpc_replay_async_args *aa = data;
+	struct ptlrpc_replay_async_args *aa = args;
 	struct obd_import *imp = req->rq_import;
 
 	atomic_dec(&imp->imp_replay_inflight);
@@ -2993,10 +2993,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 	/* Re-adjust the timeout for current conditions */
 	ptlrpc_at_set_req_timeout(req);
 
-	/*
-	 * Tell server the net_latency, so the server can calculate how long
-	 * it should wait for next replay
-	 */
+	/* Tell server net_latency to calculate how long to wait for reply. */
 	lustre_msg_set_service_time(req->rq_reqmsg,
 				    ptlrpc_at_get_net_latency(req));
 	DEBUG_REQ(D_HA, req, "REPLAY");
@@ -3252,9 +3249,9 @@ static void ptlrpcd_add_work_req(struct ptlrpc_request *req)
 }
 
 static int work_interpreter(const struct lu_env *env,
-			    struct ptlrpc_request *req, void *data, int rc)
+			    struct ptlrpc_request *req, void *args, int rc)
 {
-	struct ptlrpc_work_async_args *arg = data;
+	struct ptlrpc_work_async_args *arg = args;
 
 	LASSERT(ptlrpcd_check_work(req));
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index f59af80..867aff6 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -104,7 +104,7 @@ static void __import_set_state(struct obd_import *imp,
 
 static int ptlrpc_connect_interpret(const struct lu_env *env,
 				    struct ptlrpc_request *request,
-				    void *data, int rc);
+				    void *args, int rc);
 
 /* Only this function is allowed to change the import state when it is
  * CLOSED. I would rather refcount the import and free it after
@@ -1263,11 +1263,10 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
  */
 static int completed_replay_interpret(const struct lu_env *env,
 				      struct ptlrpc_request *req,
-				      void *data, int rc)
+				      void *args, int rc)
 {
 	atomic_dec(&req->rq_import->imp_replay_inflight);
-	if (req->rq_status == 0 &&
-	    !req->rq_import->imp_vbr_failed) {
+	if (req->rq_status == 0 && !req->rq_import->imp_vbr_failed) {
 		ptlrpc_import_recovery_state_machine(req->rq_import);
 	} else {
 		if (req->rq_import->imp_vbr_failed) {
@@ -1590,7 +1589,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 
 static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 					    struct ptlrpc_request *req,
-					    void *data, int rc)
+					    void *args, int rc)
 {
 	struct obd_import *imp = req->rq_import;
 	int connect = 0;
-- 
1.8.3.1
