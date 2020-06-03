From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:43 -0400
Subject: [lustre-devel] [PATCH 04/22] lustre: ptlrpc: change LONG_UNLINK to
 PTLRPC_REQ_LONG_UNLINK
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The name "LONG_UNLINK" is vague and generic.  Change it to
  PTLRPC_REQ_LONG_UNLINK
to make it clear it is about requests taking a long time,
and of interest to PTLRPC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: 7c549da4014a7 ("LU-10467 ptlrpc: change LONG_UNLINK to PTLRPC_REQ_LONG_UNLINK")
Suggested-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38405
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  3 ++-
 fs/lustre/ptlrpc/client.c       | 13 +++++++------
 fs/lustre/ptlrpc/niobuf.c       |  7 ++++---
 fs/lustre/ptlrpc/service.c      |  2 +-
 4 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index ce0aa8c..b706a20 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -100,7 +100,8 @@
 #define OBD_IR_FACTOR_DEFAULT	(OBD_IR_FACTOR_MAX / 2)
 /* default timeout for the MGS to become IR_FULL */
 #define OBD_IR_MGS_TIMEOUT	(4 * obd_timeout)
-#define LONG_UNLINK		300 /* Unlink should happen before now */
+/* Unlink should happen within this many seconds. */
+#define PTLRPC_REQ_LONG_UNLINK	300
 
 /**
  * Time interval of shrink, if the client is "idle" more than this interval,
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 4865b04..22022ff 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -791,11 +791,12 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 		}
 
 		if (fail_t) {
-			*fail_t = ktime_get_real_seconds() + LONG_UNLINK;
+			*fail_t = ktime_get_real_seconds() +
+				  PTLRPC_REQ_LONG_UNLINK;
 
 			if (fail2_t)
 				*fail2_t = ktime_get_real_seconds() +
-						 LONG_UNLINK;
+					   PTLRPC_REQ_LONG_UNLINK;
 
 			/* The RPC is infected, let the test change the
 			 * fail_loc
@@ -2559,8 +2560,8 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 	/* Let's setup deadline for reply unlink. */
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_REPL_UNLINK) &&
 	    async && request->rq_reply_deadline == 0 && cfs_fail_val == 0)
-		request->rq_reply_deadline =
-			ktime_get_real_seconds() + LONG_UNLINK;
+		request->rq_reply_deadline = ktime_get_real_seconds() +
+					     PTLRPC_REQ_LONG_UNLINK;
 
 	/* Nothing left to do. */
 	if (!ptlrpc_client_recv_or_unlink(request))
@@ -2583,12 +2584,12 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		wait_queue_head_t *wq = (request->rq_set) ?
 					&request->rq_set->set_waitq :
 					&request->rq_reply_waitq;
-		int seconds = LONG_UNLINK;
+		int seconds = PTLRPC_REQ_LONG_UNLINK;
 		/*
 		 * Network access will complete in finite time but the HUGE
 		 * timeout lets us CWARN for visibility of sluggish NALs
 		 */
-		while (seconds > LONG_UNLINK &&
+		while (seconds > PTLRPC_REQ_LONG_UNLINK &&
 		       (wait_event_idle_timeout(*wq,
 						!ptlrpc_client_recv_or_unlink(request),
 						HZ)) == 0)
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index a15c125..c59fc7f 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -253,7 +253,8 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 	/* Let's setup deadline for reply unlink. */
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK) &&
 	    async && req->rq_bulk_deadline == 0 && cfs_fail_val == 0)
-		req->rq_bulk_deadline = ktime_get_real_seconds() + LONG_UNLINK;
+		req->rq_bulk_deadline = ktime_get_real_seconds() +
+					PTLRPC_REQ_LONG_UNLINK;
 
 	if (ptlrpc_client_bulk_active(req) == 0)	/* completed or */
 		return 1;				/* never registered */
@@ -286,9 +287,9 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 		 * Network access will complete in finite time but the HUGE
 		 * timeout lets us CWARN for visibility of sluggish LNDs
 		 */
-		int seconds = LONG_UNLINK;
+		int seconds = PTLRPC_REQ_LONG_UNLINK;
 
-		while (seconds > LONG_UNLINK &&
+		while (seconds > PTLRPC_REQ_LONG_UNLINK &&
 		       wait_event_idle_timeout(*wq,
 					       !ptlrpc_client_bulk_active(req),
 					       HZ) == 0)
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 2f1cd35..4d5e6b3 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2859,7 +2859,7 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 			 * of sluggish LNDs
 			 */
 			cnt = 0;
-			while (cnt < LONG_UNLINK &&
+			while (cnt < PTLRPC_REQ_LONG_UNLINK &&
 			       (rc = wait_event_idle_timeout(svcpt->scp_waitq,
 							     svcpt->scp_nrqbds_posted == 0,
 							     HZ)) == 0)
-- 
1.8.3.1
