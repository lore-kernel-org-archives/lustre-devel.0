From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:51 -0400
Subject: [lustre-devel] [PATCH 58/58] staging: lustre: ptlrpc: Early replies
	need to honor at_max
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-59-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Chris Horn <hornc@cray.com>, James Simmons <jsimmons@infradead.org>

From: Chris Horn <hornc@cray.com>

When determining whether an early reply can be sent the server will
calculate the new deadline based on an offset from the request
arrival time. However, when actually setting the new deadline
the server offsets the current time. This can result in deadlines
being extended more than at_max seconds past the request arrival
time. Instead, the server should offset the arrival time when updating
its request timeout.

When a client receives an early reply it doesn't know the server side
arrival time so we use the original sent time as an approximation.

Signed-off-by: Chris Horn <hornc@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4578
Reviewed-on: http://review.whamcloud.com/9100
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Christopher J. Morrone <chris.morrone.llnl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  |    8 +++++---
 drivers/staging/lustre/lustre/ptlrpc/import.c  |   11 +++++++----
 drivers/staging/lustre/lustre/ptlrpc/service.c |   18 +++++++++++++-----
 3 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index d4463d7..ddb08ea 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -385,10 +385,12 @@ static int ptlrpc_at_recv_early_reply(struct ptlrpc_request *req)
 	spin_lock(&req->rq_lock);
 	olddl = req->rq_deadline;
 	/*
-	 * server assumes it now has rq_timeout from when it sent the
-	 * early reply, so client should give it at least that long.
+	 * server assumes it now has rq_timeout from when the request
+	 * arrived, so the client should give it at least that long.
+	 * since we don't know the arrival time we'll use the original
+	 * sent time
 	 */
-	req->rq_deadline = ktime_get_real_seconds() + req->rq_timeout +
+	req->rq_deadline = req->rq_sent + req->rq_timeout +
 			   ptlrpc_at_get_net_latency(req);
 
 	DEBUG_REQ(D_ADAPTTO, req,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 3292e6e..af8ffbc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1497,10 +1497,13 @@ EXPORT_SYMBOL(ptlrpc_disconnect_import);
 /* Adaptive Timeout utils */
 extern unsigned int at_min, at_max, at_history;
 
-/* Bin into timeslices using AT_BINS bins.
- * This gives us a max of the last binlimit*AT_BINS secs without the storage,
- * but still smoothing out a return to normalcy from a slow response.
- * (E.g. remember the maximum latency in each minute of the last 4 minutes.)
+/*
+ *Update at_current with the specified value (bounded by at_min and at_max),
+ * as well as the AT history "bins".
+ *  - Bin into timeslices using AT_BINS bins.
+ *  - This gives us a max of the last at_history seconds without the storage,
+ *    but still smoothing out a return to normalcy from a slow response.
+ *  - (E.g. remember the maximum latency in each minute of the last 4 minutes.)
  */
 int at_measured(struct adaptive_timeout *at, unsigned int val)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 4788c49..30d8b72 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1005,13 +1005,16 @@ ptlrpc_at_remove_timed(struct ptlrpc_request *req)
 	array->paa_count--;
 }
 
+/*
+ * Attempt to extend the request deadline by sending an early reply to the
+ * client.
+ */
 static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 {
 	struct ptlrpc_service_part *svcpt = req->rq_rqbd->rqbd_svcpt;
 	struct ptlrpc_request *reqcopy;
 	struct lustre_msg *reqmsg;
 	long olddl = req->rq_deadline - ktime_get_real_seconds();
-	time64_t newdl;
 	int rc;
 
 	/* deadline is when the client expects us to reply, margin is the
@@ -1039,8 +1042,13 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		return -ENOSYS;
 	}
 
-	/* Fake our processing time into the future to ask the clients
-	 * for some extra amount of time
+	/*
+	 * We want to extend the request deadline by at_extra seconds,
+	 * so we set our service estimate to reflect how much time has
+	 * passed since this request arrived plus an additional
+	 * at_extra seconds. The client will calculate the new deadline
+	 * based on this service estimate (plus some additional time to
+	 * account for network latency). See ptlrpc_at_recv_early_reply
 	 */
 	at_measured(&svcpt->scp_at_estimate, at_extra +
 		    ktime_get_real_seconds() - req->rq_arrival_time.tv_sec);
@@ -1056,7 +1064,6 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 			  ktime_get_real_seconds());
 		return -ETIMEDOUT;
 	}
-	newdl = ktime_get_real_seconds() + at_get(&svcpt->scp_at_estimate);
 
 	reqcopy = ptlrpc_request_cache_alloc(GFP_NOFS);
 	if (!reqcopy)
@@ -1110,7 +1117,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 
 	if (!rc) {
 		/* Adjust our own deadline to what we told the client */
-		req->rq_deadline = newdl;
+		req->rq_deadline = req->rq_arrival_time.tv_sec +
+				   at_get(&svcpt->scp_at_estimate);
 		req->rq_early_count++; /* number sent, server side */
 	} else {
 		DEBUG_REQ(D_ERROR, req, "Early reply send failed %d", rc);
-- 
1.7.1
