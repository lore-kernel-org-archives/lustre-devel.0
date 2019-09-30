From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:45 -0400
Subject: [lustre-devel] [PATCH 026/151] lustre: ptlrpc: change cr_sent_tv
 from timespec to ktime
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of calculating timediff by manually subtracting the current
timespec64 from cr_sent_tv we can convert cr_sent_tv to ktime_t
and simplify the code.

WC-id: https://jira.hpdd.intel.com/browse/LU-4423
Lustre-commit: de7a14b54637 ("LU-4423 ptlrpc: use 64-bit times for request times")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/24977
WC-id: https://jira.hpdd.intel.com/browse/LU-9683
Lustre-commit: 61c48e79fdfb ("LU-9683 ptlrpc: fix argument misorder")
Reviewed-on: https://review.whamcloud.com/28027
Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  6 +++---
 fs/lustre/ptlrpc/client.c      | 11 +++++------
 fs/lustre/ptlrpc/niobuf.c      |  2 +-
 fs/lustre/ptlrpc/service.c     | 33 +++++++++++++--------------------
 4 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index fde59df..20ce196 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -537,8 +537,8 @@ struct ptlrpc_cli_req {
 	long				 cr_delay_limit;
 	/** time request was first queued */
 	unsigned long			 cr_queued_time;
-	/** request sent timeval */
-	struct timespec64		 cr_sent_tv;
+	/** request sent in nanosseconds */
+	ktime_t				 cr_sent_ns;
 	/** time for request really sent out */
 	time64_t			 cr_sent_out;
 	/** when req reply unlink must finish. */
@@ -600,7 +600,7 @@ struct ptlrpc_cli_req {
 #define rq_bulk			rq_cli.cr_bulk
 #define rq_delay_limit		rq_cli.cr_delay_limit
 #define rq_queued_time		rq_cli.cr_queued_time
-#define rq_sent_tv		rq_cli.cr_sent_tv
+#define rq_sent_ns		rq_cli.cr_sent_ns
 #define rq_real_sent		rq_cli.cr_sent_out
 #define rq_reply_deadline	rq_cli.cr_reply_deadline
 #define rq_bulk_deadline	rq_cli.cr_bulk_deadline
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index ba894c0..4888578 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1325,8 +1325,8 @@ static int after_reply(struct ptlrpc_request *req)
 	struct obd_import *imp = req->rq_import;
 	struct obd_device *obd = req->rq_import->imp_obd;
 	int rc;
-	struct timespec64 work_start;
-	long timediff;
+	ktime_t work_start;
+	s64 timediff;
 	u64 committed;
 
 	LASSERT(obd);
@@ -1355,10 +1355,9 @@ static int after_reply(struct ptlrpc_request *req)
 		return 0;
 	}
 
-	ktime_get_real_ts64(&work_start);
-	timediff = (work_start.tv_sec - req->rq_sent_tv.tv_sec) * USEC_PER_SEC +
-		   (work_start.tv_nsec - req->rq_sent_tv.tv_nsec) /
-								 NSEC_PER_USEC;
+	work_start = ktime_get_real();
+	timediff = ktime_us_delta(work_start, req->rq_sent_ns);
+
 	/*
 	 * NB Until this point, the whole of the incoming message,
 	 * including buflens, status etc is in the sender's byte order.
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 033d628..e7aff51 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -684,7 +684,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND, request->rq_timeout + 5);
 
-	ktime_get_real_ts64(&request->rq_sent_tv);
+	request->rq_sent_ns = ktime_get_real();
 	request->rq_sent = ktime_get_real_seconds();
 	/* We give the server rq_timeout secs to process the req, and
 	 * add the network latency for our local timeout.
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index c9ab9c3..b2a1b4a 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1649,12 +1649,11 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 {
 	struct ptlrpc_service *svc = svcpt->scp_service;
 	struct ptlrpc_request *request;
-	struct timespec64 work_start;
-	struct timespec64 work_end;
-	struct timespec64 timediff;
-	struct timespec64 arrived;
-	unsigned long timediff_usecs;
-	unsigned long arrived_usecs;
+	ktime_t work_start;
+	ktime_t work_end;
+	ktime_t arrived;
+	s64 timediff_usecs;
+	s64 arrived_usecs;
 	int fail_opc = 0;
 
 	request = ptlrpc_server_request_get(svcpt, false);
@@ -1676,10 +1675,9 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DUMP_LOG))
 		libcfs_debug_dumplog();
 
-	ktime_get_real_ts64(&work_start);
-	timediff = timespec64_sub(work_start, request->rq_arrival_time);
-	timediff_usecs = timediff.tv_sec * USEC_PER_SEC +
-			 timediff.tv_nsec / NSEC_PER_USEC;
+	work_start = ktime_get_real();
+	arrived = timespec64_to_ktime(request->rq_arrival_time);
+	timediff_usecs = ktime_us_delta(work_start, arrived);
 	if (likely(svc->srv_stats)) {
 		lprocfs_counter_add(svc->srv_stats, PTLRPC_REQWAIT_CNTR,
 				    timediff_usecs);
@@ -1746,15 +1744,11 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 			  (s64)ktime_get_real_seconds() - request->rq_deadline);
 	}
 
-	ktime_get_real_ts64(&work_end);
-	timediff = timespec64_sub(work_end, work_start);
-	timediff_usecs = timediff.tv_sec * USEC_PER_SEC +
-			 timediff.tv_nsec / NSEC_PER_USEC;
-	arrived = timespec64_sub(work_end, request->rq_arrival_time);
-	arrived_usecs = arrived.tv_sec * USEC_PER_SEC +
-			 arrived.tv_nsec / NSEC_PER_USEC;
+	work_end = ktime_get_real();
+	timediff_usecs = ktime_us_delta(work_end, work_start);
+	arrived_usecs = ktime_us_delta(work_end, arrived);
 	CDEBUG(D_RPCTRACE,
-	       "Handled RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d Request processed in %ldus (%ldus total) trans %llu rc %d/%d\n",
+	       "Handled RPC pname:cluuid+ref:pid:xid:nid:opc %s:%s+%d:%d:x%llu:%s:%d Request processed in %lldus (%lldus total) trans %llu rc %d/%d\n",
 	       current->comm,
 	       (request->rq_export ?
 		(char *)request->rq_export->exp_client_uuid.uuid : "0"),
@@ -1787,8 +1781,7 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 		DEBUG_REQ(D_ADAPTTO, request,
 			  "sent %d early replies before finishing in %llds",
 			  request->rq_early_count,
-			  (s64)work_end.tv_sec -
-			  request->rq_arrival_time.tv_sec);
+			  arrived_usecs / USEC_PER_SEC);
 	}
 
 	ptlrpc_server_finish_active_request(svcpt, request);
-- 
1.8.3.1
