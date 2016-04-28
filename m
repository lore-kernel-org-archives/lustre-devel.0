From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:20 -0400
Subject: [lustre-devel] [PATCH 11/12] staging: lustre: ptlrpc: initialize
	request session early
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mikhail Pershin <mike.pershin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Mikhail Pershin <mike.pershin@intel.com>

Initialize request session early to make it available in
high-priority handlers

Signed-off-by: Mikhail Pershin <mike.pershin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3467
Reviewed-on: http://review.whamcloud.com/7350
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/service.c | 53 +++++++++++++++-----------
 1 file changed, 31 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index fc2632f..17c7b97 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -838,6 +838,11 @@ static void ptlrpc_server_finish_request(struct ptlrpc_service_part *svcpt,
 {
 	ptlrpc_server_hpreq_fini(req);
 
+	if (req->rq_session.lc_thread) {
+		lu_context_exit(&req->rq_session);
+		lu_context_fini(&req->rq_session);
+	}
+
 	ptlrpc_server_drop_request(req);
 }
 
@@ -1579,6 +1584,21 @@ ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	}
 
 	req->rq_svc_thread = thread;
+	if (thread) {
+		/* initialize request session, it is needed for request
+		 * processing by target
+		 */
+		rc = lu_context_init(&req->rq_session,
+				     LCT_SERVER_SESSION | LCT_NOREF);
+		if (rc) {
+			CERROR("%s: failure to initialize session: rc = %d\n",
+			       thread->t_name, rc);
+			goto err_req;
+		}
+		req->rq_session.lc_thread = thread;
+		lu_context_enter(&req->rq_session);
+		req->rq_svc_thread->t_env->le_ses = &req->rq_session;
+	}
 
 	ptlrpc_at_add_timed(req);
 
@@ -1612,7 +1632,6 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	struct timespec64 arrived;
 	unsigned long timediff_usecs;
 	unsigned long arrived_usecs;
-	int rc;
 	int fail_opc = 0;
 
 	request = ptlrpc_server_request_get(svcpt, false);
@@ -1649,22 +1668,6 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 				    at_get(&svcpt->scp_at_estimate));
 	}
 
-	rc = lu_context_init(&request->rq_session, LCT_SERVER_SESSION |
-						   LCT_NOREF);
-	if (rc) {
-		CERROR("Failure to initialize session: %d\n", rc);
-		goto out_req;
-	}
-	request->rq_session.lc_thread = thread;
-	request->rq_session.lc_cookie = 0x5;
-	lu_context_enter(&request->rq_session);
-
-	CDEBUG(D_NET, "got req %llu\n", request->rq_xid);
-
-	request->rq_svc_thread = thread;
-	if (thread)
-		request->rq_svc_thread->t_env->le_ses = &request->rq_session;
-
 	if (likely(request->rq_export)) {
 		if (unlikely(ptlrpc_check_req(request)))
 			goto put_conn;
@@ -1696,14 +1699,21 @@ ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	if (lustre_msg_get_opc(request->rq_reqmsg) != OBD_PING)
 		CFS_FAIL_TIMEOUT_MS(OBD_FAIL_PTLRPC_PAUSE_REQ, cfs_fail_val);
 
-	rc = svc->srv_ops.so_req_handler(request);
+	CDEBUG(D_NET, "got req %llu\n", request->rq_xid);
+
+	/* re-assign request and sesson thread to the current one */
+	request->rq_svc_thread = thread;
+	if (thread) {
+		LASSERT(request->rq_session.lc_thread);
+		request->rq_session.lc_thread = thread;
+		request->rq_session.lc_cookie = 0x55;
+		thread->t_env->le_ses = &request->rq_session;
+	}
+	svc->srv_ops.so_req_handler(request);
 
 	ptlrpc_rqphase_move(request, RQ_PHASE_COMPLETE);
 
 put_conn:
-	lu_context_exit(&request->rq_session);
-	lu_context_fini(&request->rq_session);
-
 	if (unlikely(ktime_get_real_seconds() > request->rq_deadline)) {
 		DEBUG_REQ(D_WARNING, request,
 			  "Request took longer than estimated (%lld:%llds); "
@@ -1757,7 +1767,6 @@ put_conn:
 			  request->rq_arrival_time.tv_sec);
 	}
 
-out_req:
 	ptlrpc_server_finish_active_request(svcpt, request);
 
 	return 1;
-- 
2.7.4
