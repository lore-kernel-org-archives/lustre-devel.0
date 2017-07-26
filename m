From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:30 -0400
Subject: [lustre-devel] [PATCH 14/20] staging: lustre: ptlrpc: don't use
	CFS_DURATION_T for time64_t
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The libcfs CFS_DURATION_T define is really only for
jiffies and its being used with time64_t in some of
the ptlrpc code. Lets remove CFS_DURATION_T and
replaced it with normal %lld instead.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/24977
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4423
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c  |  5 ++---
 drivers/staging/lustre/lustre/ptlrpc/service.c | 15 +++++++--------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 9f4f17a..977d7a6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -367,9 +367,8 @@ void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
 		 */
 		CDEBUG((lustre_msg_get_flags(req->rq_reqmsg) & MSG_RESENT) ?
 		       D_ADAPTTO : D_WARNING,
-		       "Reported service time %u > total measured time " CFS_DURATION_T "\n",
-		       service_time,
-		       (long)(now - req->rq_sent));
+		       "Reported service time %u > total measured time %lld\n",
+		       service_time, now - req->rq_sent);
 		return;
 	}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 759aa6c..bcf5faf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1565,9 +1565,9 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 
 	/* req_in handling should/must be fast */
 	if (ktime_get_real_seconds() - req->rq_arrival_time.tv_sec > 5)
-		DEBUG_REQ(D_WARNING, req, "Slow req_in handling " CFS_DURATION_T "s",
-			  (long)(ktime_get_real_seconds() -
-				 req->rq_arrival_time.tv_sec));
+		DEBUG_REQ(D_WARNING, req, "Slow req_in handling %llds",
+			  (s64)(ktime_get_real_seconds() -
+				req->rq_arrival_time.tv_sec));
 
 	/* Set rpc server deadline and add it to the timed list */
 	deadline = (lustre_msghdr_get_flags(req->rq_reqmsg) &
@@ -1674,12 +1674,11 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	 * The deadline is increased if we send an early reply.
 	 */
 	if (ktime_get_real_seconds() > request->rq_deadline) {
-		DEBUG_REQ(D_ERROR, request, "Dropping timed-out request from %s: deadline " CFS_DURATION_T ":" CFS_DURATION_T "s ago\n",
+		DEBUG_REQ(D_ERROR, request, "Dropping timed-out request from %s: deadline %lld:%llds ago\n",
 			  libcfs_id2str(request->rq_peer),
-			  (long)(request->rq_deadline -
-				 request->rq_arrival_time.tv_sec),
-			  (long)(ktime_get_real_seconds() -
-				 request->rq_deadline));
+			  request->rq_deadline -
+			  request->rq_arrival_time.tv_sec,
+			  ktime_get_real_seconds() - request->rq_deadline);
 		goto put_conn;
 	}
 
-- 
1.8.3.1
