From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:04 -0500
Subject: [lustre-devel] [PATCH 616/622] lustre: ptlrpc: simplify wait_event
 handling in unregister functions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-617-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

We can simplify the wait_event_idle_timeout() handling in both
ptlrpc_unregister_bulk() and ptlrpc_unregister_reply() by changing the
timeout to a countdown. Less variables are needed on the stack.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: 5e30a2c06176f50f ("LU-10467 lustre: convert most users of LWI_TIMEOUT_INTERVAL()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/35973
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 31 ++++++++++---------------------
 fs/lustre/ptlrpc/niobuf.c | 30 ++++++++++++++----------------
 2 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 632ddf1..1714e66 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2570,9 +2570,6 @@ u64 ptlrpc_req_xid(struct ptlrpc_request *request)
  */
 static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 {
-	int rc;
-	wait_queue_head_t *wq;
-
 	/* Might sleep. */
 	LASSERT(!in_interrupt());
 
@@ -2599,29 +2596,21 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 	if (async)
 		return 0;
 
-	/*
-	 * We have to wait_event_idle_timeout() whatever the result, to get
-	 * a chance to run reply_in_callback(), and to make sure we've
-	 * unlinked before returning a req to the pool.
-	 */
-	if (request->rq_set)
-		wq = &request->rq_set->set_waitq;
-	else
-		wq = &request->rq_reply_waitq;
-
 	for (;;) {
+		wait_queue_head_t *wq = (request->rq_set) ?
+					&request->rq_set->set_waitq :
+					&request->rq_reply_waitq;
+		int seconds = LONG_UNLINK;
 		/*
 		 * Network access will complete in finite time but the HUGE
 		 * timeout lets us CWARN for visibility of sluggish NALs
 		 */
-		int cnt = 0;
-
-		while (cnt < LONG_UNLINK &&
-		       (rc = wait_event_idle_timeout(*wq,
-						     !ptlrpc_client_recv_or_unlink(request),
-						     HZ)) == 0)
-			cnt += 1;
-		if (rc > 0) {
+		while (seconds > LONG_UNLINK &&
+		       (wait_event_idle_timeout(*wq,
+						!ptlrpc_client_recv_or_unlink(request),
+						HZ)) == 0)
+			seconds -= 1;
+		if (seconds > 0) {
 			ptlrpc_rqphase_move(request, request->rq_next_phase);
 			return 1;
 		}
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 26a1f97..ab2753a 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -244,8 +244,6 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 {
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	wait_queue_head_t *wq;
-	int rc;
 
 	LASSERT(!in_interrupt());     /* might sleep */
 
@@ -276,23 +274,23 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 	if (async)
 		return 0;
 
-	if (req->rq_set)
-		wq = &req->rq_set->set_waitq;
-	else
-		wq = &req->rq_reply_waitq;
-
 	for (;;) {
-		/* Network access will complete in finite time but the HUGE
+		/* The wq argument is ignored by user-space wait_event macros */
+		wait_queue_head_t *wq = (req->rq_set != NULL) ?
+					&req->rq_set->set_waitq :
+					&req->rq_reply_waitq;
+		/*
+		 * Network access will complete in finite time but the HUGE
 		 * timeout lets us CWARN for visibility of sluggish LNDs
 		 */
-		int cnt = 0;
-
-		while (cnt < LONG_UNLINK &&
-		       (rc = wait_event_idle_timeout(*wq,
-						     !ptlrpc_client_bulk_active(req),
-						     HZ)) == 0)
-			cnt += 1;
-		if (rc > 0) {
+		int seconds = LONG_UNLINK;
+
+		while (seconds > LONG_UNLINK &&
+		       wait_event_idle_timeout(*wq,
+					       !ptlrpc_client_bulk_active(req),
+					       HZ) == 0)
+			seconds -= 1;
+		if (seconds > 0) {
 			ptlrpc_rqphase_move(req, req->rq_next_phase);
 			return 1;
 		}
-- 
1.8.3.1
