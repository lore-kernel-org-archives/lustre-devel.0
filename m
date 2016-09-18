From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:53 -0400
Subject: [lustre-devel] [PATCH 114/124] staging: lustre: ptlrpc: prevent
	request timeout grow due to recovery
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-115-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mikhail Pershin <mike.pershin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Mikhail Pershin <mike.pershin@intel.com>

Patch fixes the issue seen on the client with growing request
timeout which occurred after the server side patch landed for
LU-5079. While commit itself is correct, it reveals another
issue. If request is being processed for a long time on server
then client adaptive timeouts will adapt to that after receiving
reply and new requests will have bigger timeout. Another problem
is that server AT history is corrupted by recovery request
processing time which not pure service time but includes
also waiting time for clients to recover.

Patch prevents the AT stats update from early replies on client and
from recovering requests processing time on server.
The ptlrpc_at_recv_early_reply() still updates the current request
timeout as asked by server, but don't include this into AT stats.
The real reply will bring that data from server after all.

Signed-off-by: Mikhail Pershin <mike.pershin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6084
Reviewed-on: http://review.whamcloud.com/13520
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  |   30 +++++++++++++----------
 drivers/staging/lustre/lustre/ptlrpc/service.c |   12 ++++-----
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 18c7ff7..8c51d51 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -364,23 +364,27 @@ static int ptlrpc_at_recv_early_reply(struct ptlrpc_request *req)
 	}
 
 	rc = unpack_reply(early_req);
-	if (rc == 0) {
-		/* Expecting to increase the service time estimate here */
-		ptlrpc_at_adj_service(req,
-			lustre_msg_get_timeout(early_req->rq_repmsg));
-		ptlrpc_at_adj_net_latency(req,
-			lustre_msg_get_service_time(early_req->rq_repmsg));
-	}
-
-	sptlrpc_cli_finish_early_reply(early_req);
-
-	if (rc != 0) {
+	if (rc) {
+		sptlrpc_cli_finish_early_reply(early_req);
 		spin_lock(&req->rq_lock);
 		return rc;
 	}
 
-	/* Adjust the local timeout for this req */
-	ptlrpc_at_set_req_timeout(req);
+	/*
+	 * Use new timeout value just to adjust the local value for this
+	 * request, don't include it into at_history. It is unclear yet why
+	 * service time increased and should it be counted or skipped, e.g.
+	 * that can be recovery case or some error or server, the real reply
+	 * will add all new data if it is worth to add.
+	 */
+	req->rq_timeout = lustre_msg_get_timeout(early_req->rq_repmsg);
+	lustre_msg_set_timeout(req->rq_reqmsg, req->rq_timeout);
+
+	/* Network latency can be adjusted, it is pure network delays */
+	ptlrpc_at_adj_net_latency(req,
+				  lustre_msg_get_service_time(early_req->rq_repmsg));
+
+	sptlrpc_cli_finish_early_reply(early_req);
 
 	spin_lock(&req->rq_lock);
 	olddl = req->rq_deadline;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 3edc9b1..72f3930 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1015,6 +1015,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	struct ptlrpc_request *reqcopy;
 	struct lustre_msg *reqmsg;
 	long olddl = req->rq_deadline - ktime_get_real_seconds();
+	time64_t newdl;
 	int rc;
 
 	/* deadline is when the client expects us to reply, margin is the
@@ -1052,16 +1053,14 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	 */
 	at_measured(&svcpt->scp_at_estimate, at_extra +
 		    ktime_get_real_seconds() - req->rq_arrival_time.tv_sec);
+	newdl = req->rq_arrival_time.tv_sec + at_get(&svcpt->scp_at_estimate);
 
 	/* Check to see if we've actually increased the deadline -
 	 * we may be past adaptive_max
 	 */
-	if (req->rq_deadline >= req->rq_arrival_time.tv_sec +
-	    at_get(&svcpt->scp_at_estimate)) {
+	if (req->rq_deadline >= newdl) {
 		DEBUG_REQ(D_WARNING, req, "Couldn't add any time (%ld/%lld), not sending early reply\n",
-			  olddl, req->rq_arrival_time.tv_sec +
-			  at_get(&svcpt->scp_at_estimate) -
-			  ktime_get_real_seconds());
+			  olddl, newdl - ktime_get_real_seconds());
 		return -ETIMEDOUT;
 	}
 
@@ -1117,8 +1116,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 
 	if (!rc) {
 		/* Adjust our own deadline to what we told the client */
-		req->rq_deadline = req->rq_arrival_time.tv_sec +
-				   at_get(&svcpt->scp_at_estimate);
+		req->rq_deadline = newdl;
 		req->rq_early_count++; /* number sent, server side */
 	} else {
 		DEBUG_REQ(D_ERROR, req, "Early reply send failed %d", rc);
-- 
1.7.1
