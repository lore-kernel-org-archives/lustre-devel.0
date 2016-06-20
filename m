From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:23 -0400
Subject: [lustre-devel] [PATCH 08/28] staging/lustre/ptlrpc: missing wakeup
	for ptlrpc_check_set
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Liang Zhen <liang.zhen@intel.com>

This patch changes a few things:

- There is no guarantee that request_out_callback will happen
  before reply_in_callback, if a request got reply and unlinked
  reply buffer before request_out_callback is called, then the
  thread waiting on ptlrpc_request_set will miss wakeup event.

  This may seriously impact performance of some IO workloads or
  result in RPC timeout

- To make code more easier to understand, this patch changes
  action-bits "rq_req_unlink" and "rq_reply_unlink" to
  status-bits "rq_req_unlinked" and "rq_reply_unlinked"

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-on: http://review.whamcloud.com/12158
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5696
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Li Wei <wei.g.li@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 27 +++++++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 12 ++++------
 drivers/staging/lustre/lustre/ptlrpc/events.c      | 22 +++++++++++-------
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      | 14 +++++------
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  9 ++++++++
 5 files changed, 51 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 5968c3c..523d082 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1428,7 +1428,7 @@ struct ptlrpc_request {
 	 * rq_list
 	 */
 	spinlock_t rq_lock;
-	/** client-side flags are serialized by rq_lock */
+	/** client-side flags are serialized by rq_lock @{ */
 	unsigned int rq_intr:1, rq_replied:1, rq_err:1,
 		rq_timedout:1, rq_resend:1, rq_restart:1,
 		/**
@@ -1444,18 +1444,15 @@ struct ptlrpc_request {
 		rq_no_resend:1, rq_waiting:1, rq_receiving_reply:1,
 		rq_no_delay:1, rq_net_err:1, rq_wait_ctx:1,
 		rq_early:1,
-		rq_req_unlink:1, rq_reply_unlink:1,
+		rq_req_unlinked:1,	/* unlinked request buffer from lnet */
+		rq_reply_unlinked:1,	/* unlinked reply buffer from lnet */
 		rq_memalloc:1,      /* req originated from "kswapd" */
-		/* server-side flags */
-		rq_packed_final:1,  /* packed final reply */
-		rq_hp:1,	    /* high priority RPC */
-		rq_at_linked:1,     /* link into service's srv_at_array */
-		rq_reply_truncate:1,
 		rq_committed:1,
-		/* whether the "rq_set" is a valid one */
+		rq_reply_truncated:1,
+		/** whether the "rq_set" is a valid one */
 		rq_invalid_rqset:1,
 		rq_generation_set:1,
-		/* do not resend request on -EINPROGRESS */
+		/** do not resend request on -EINPROGRESS */
 		rq_no_retry_einprogress:1,
 		/* allow the req to be sent if the import is in recovery
 		 * status
@@ -1463,6 +1460,14 @@ struct ptlrpc_request {
 		rq_allow_replay:1,
 		/* bulk request, sent to server, but uncommitted */
 		rq_unstable:1;
+	/** @} */
+
+	/** server-side flags @{ */
+	unsigned int
+		rq_hp:1,		/**< high priority RPC */
+		rq_at_linked:1,		/**< link into service's srv_at_array */
+		rq_packed_final:1;	/**< packed final reply */
+	/** @} */
 
 	/** one of RQ_PHASE_* */
 	enum rq_phase			rq_phase;
@@ -2785,8 +2790,8 @@ ptlrpc_client_recv_or_unlink(struct ptlrpc_request *req)
 		spin_unlock(&req->rq_lock);
 		return 1;
 	}
-	rc = req->rq_receiving_reply;
-	rc = rc || req->rq_req_unlink || req->rq_reply_unlink;
+	rc = !req->rq_req_unlinked || !req->rq_reply_unlinked ||
+	     req->rq_receiving_reply;
 	spin_unlock(&req->rq_lock);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 9abd469..ae1cef3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1148,9 +1148,9 @@ static int after_reply(struct ptlrpc_request *req)
 
 	LASSERT(obd);
 	/* repbuf must be unlinked */
-	LASSERT(!req->rq_receiving_reply && !req->rq_reply_unlink);
+	LASSERT(!req->rq_receiving_reply && req->rq_reply_unlinked);
 
-	if (req->rq_reply_truncate) {
+	if (req->rq_reply_truncated) {
 		if (ptlrpc_no_resend(req)) {
 			DEBUG_REQ(D_ERROR, req, "reply buffer overflow, expected: %d, actual size: %d",
 				  req->rq_nob_received, req->rq_repbuf_len);
@@ -2342,9 +2342,10 @@ int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 
 		LASSERT(rc == -ETIMEDOUT);
 		DEBUG_REQ(D_WARNING, request,
-			  "Unexpectedly long timeout rvcng=%d unlnk=%d/%d",
+			  "Unexpectedly long timeout receiving_reply=%d req_ulinked=%d reply_unlinked=%d",
 			  request->rq_receiving_reply,
-			  request->rq_req_unlink, request->rq_reply_unlink);
+			  request->rq_req_unlinked,
+			  request->rq_reply_unlinked);
 	}
 	return 0;
 }
@@ -3002,9 +3003,6 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 	req->rq_import = class_import_get(imp);
 	req->rq_interpret_reply = work_interpreter;
 	/* don't want reply */
-	req->rq_receiving_reply = 0;
-	req->rq_req_unlink = 0;
-	req->rq_reply_unlink = 0;
 	req->rq_no_delay = 1;
 	req->rq_no_resend = 1;
 	req->rq_pill.rc_fmt = (void *)&worker_format;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 95be4aa..a243342 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -51,27 +51,33 @@ void request_out_callback(lnet_event_t *ev)
 {
 	struct ptlrpc_cb_id *cbid = ev->md.user_ptr;
 	struct ptlrpc_request *req = cbid->cbid_arg;
+	bool wakeup = false;
 
-	LASSERT(ev->type == LNET_EVENT_SEND ||
-		ev->type == LNET_EVENT_UNLINK);
+	LASSERT(ev->type == LNET_EVENT_SEND || ev->type == LNET_EVENT_UNLINK);
 	LASSERT(ev->unlinked);
 
 	DEBUG_REQ(D_NET, req, "type %d, status %d", ev->type, ev->status);
 
 	sptlrpc_request_out_callback(req);
+
 	spin_lock(&req->rq_lock);
 	req->rq_real_sent = ktime_get_real_seconds();
-	if (ev->unlinked)
-		req->rq_req_unlink = 0;
+	req->rq_req_unlinked = 1;
+	/* reply_in_callback happened before request_out_callback? */
+	if (req->rq_reply_unlinked)
+		wakeup = true;
 
 	if (ev->type == LNET_EVENT_UNLINK || ev->status != 0) {
 		/* Failed send: make it seem like the reply timed out, just
 		 * like failing sends in client.c does currently...
 		 */
-
 		req->rq_net_err = 1;
-		ptlrpc_client_wake_req(req);
+		wakeup = true;
 	}
+
+	if (wakeup)
+		ptlrpc_client_wake_req(req);
+
 	spin_unlock(&req->rq_lock);
 
 	ptlrpc_req_finished(req);
@@ -100,7 +106,7 @@ void reply_in_callback(lnet_event_t *ev)
 	req->rq_receiving_reply = 0;
 	req->rq_early = 0;
 	if (ev->unlinked)
-		req->rq_reply_unlink = 0;
+		req->rq_reply_unlinked = 1;
 
 	if (ev->status)
 		goto out_wake;
@@ -114,7 +120,7 @@ void reply_in_callback(lnet_event_t *ev)
 	if (ev->mlength < ev->rlength) {
 		CDEBUG(D_RPCTRACE, "truncate req %p rpc %d - %d+%d\n", req,
 		       req->rq_replen, ev->rlength, ev->offset);
-		req->rq_reply_truncate = 1;
+		req->rq_reply_truncated = 1;
 		req->rq_replied = 1;
 		req->rq_status = -EOVERFLOW;
 		req->rq_nob_received = ev->rlength + ev->offset;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 4e7d68f..8c49f5e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -577,19 +577,18 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	}
 
 	spin_lock(&request->rq_lock);
-	/* If the MD attach succeeds, there _will_ be a reply_in callback */
-	request->rq_receiving_reply = !noreply;
-	request->rq_req_unlink = 1;
 	/* We are responsible for unlinking the reply buffer */
-	request->rq_reply_unlink = !noreply;
+	request->rq_reply_unlinked = noreply;
+	request->rq_receiving_reply = !noreply;
 	/* Clear any flags that may be present from previous sends. */
+	request->rq_req_unlinked = 0;
 	request->rq_replied = 0;
 	request->rq_err = 0;
 	request->rq_timedout = 0;
 	request->rq_net_err = 0;
 	request->rq_resend = 0;
 	request->rq_restart = 0;
-	request->rq_reply_truncate = 0;
+	request->rq_reply_truncated = 0;
 	spin_unlock(&request->rq_lock);
 
 	if (!noreply) {
@@ -604,7 +603,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		reply_md.user_ptr = &request->rq_reply_cbid;
 		reply_md.eq_handle = ptlrpc_eq_h;
 
-		/* We must see the unlink callback to unset rq_reply_unlink,
+		/* We must see the unlink callback to set rq_reply_unlinked,
 		 * so we can't auto-unlink
 		 */
 		rc = LNetMDAttach(reply_me_h, reply_md, LNET_RETAIN,
@@ -651,9 +650,10 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			  connection,
 			  request->rq_request_portal,
 			  request->rq_xid, 0);
-	if (rc == 0)
+	if (likely(rc == 0))
 		goto out;
 
+	request->rq_req_unlinked = 1;
 	ptlrpc_req_finished(request);
 	if (noreply)
 		goto out;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index d3674cb..a9831fa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -304,6 +304,15 @@ static inline void ptlrpc_cli_req_init(struct ptlrpc_request *req)
 	struct ptlrpc_cli_req *cr = &req->rq_cli;
 
 	ptlrpc_req_comm_init(req);
+
+	req->rq_receiving_reply = 0;
+	req->rq_req_unlinked = 1;
+	req->rq_reply_unlinked = 1;
+
+	req->rq_receiving_reply = 0;
+	req->rq_req_unlinked = 1;
+	req->rq_reply_unlinked = 1;
+
 	INIT_LIST_HEAD(&cr->cr_set_chain);
 	INIT_LIST_HEAD(&cr->cr_ctx_chain);
 	init_waitqueue_head(&cr->cr_reply_waitq);
-- 
2.7.4
