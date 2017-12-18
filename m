From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 18:18:00 +1100
Subject: [lustre-devel] [PATCH 13/16] staging: lustre: improve waiting in
 sptlrpc_req_refresh_ctx
In-Reply-To: <151358127190.5099.12792810096274074963.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
Message-ID: <151358148027.5099.4578208141131727886.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Replace l_wait_event with wait_event_timeout() and call the
handler function explicitly.  This makes it more clear
what is happening.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/sec.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 617e004d00f8..6292840f1fca 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -554,9 +554,8 @@ int ctx_check_refresh(struct ptlrpc_cli_ctx *ctx)
 }
 
 static
-int ctx_refresh_timeout(void *data)
+int ctx_refresh_timeout(struct ptlrpc_request *req)
 {
-	struct ptlrpc_request *req = data;
 	int rc;
 
 	/* conn_cnt is needed in expire_one_request */
@@ -575,10 +574,8 @@ int ctx_refresh_timeout(void *data)
 }
 
 static
-void ctx_refresh_interrupt(void *data)
+void ctx_refresh_interrupt(struct ptlrpc_request *req)
 {
-	struct ptlrpc_request *req = data;
-
 	spin_lock(&req->rq_lock);
 	req->rq_intr = 1;
 	spin_unlock(&req->rq_lock);
@@ -611,7 +608,6 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 {
 	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
 	struct ptlrpc_sec *sec;
-	struct l_wait_info lwi;
 	int rc;
 
 	LASSERT(ctx);
@@ -743,10 +739,17 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 	req->rq_restart = 0;
 	spin_unlock(&req->rq_lock);
 
-	lwi = LWI_TIMEOUT_INTR(msecs_to_jiffies(timeout * MSEC_PER_SEC),
-			       ctx_refresh_timeout, ctx_refresh_interrupt,
-			       req);
-	rc = l_wait_event(req->rq_reply_waitq, ctx_check_refresh(ctx), &lwi);
+	rc = wait_event_timeout(req->rq_reply_waitq,
+				ctx_check_refresh(ctx),
+				timeout * HZ);
+	if (rc > 0)
+		rc = 0;
+	else if (ctx_refresh_timeout(req))
+		rc = -ETIMEDOUT;
+	else if (l_fatal_signal_pending(current)) {
+		rc = -EINTR;
+		ctx_refresh_interrupt(req);
+	}
 
 	/*
 	 * following cases could lead us here:
