From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:20 -0400
Subject: [lustre-devel] [PATCH 10/30] lustre: ptlrpc: set rq_sent when send
 fails due to -ENOMEM
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In ptl_send_rpc() set rq_sent when we fail to send the RPC due
to insufficient memory, since this is what the upper layers expect.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9296
Reviewed-on: https://review.whamcloud.com/26470
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 0e13fb9..3cfd7b8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -571,15 +571,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		mpflag = memalloc_noreclaim_save();
 
 	rc = sptlrpc_cli_wrap_request(request);
-	if (rc) {
-		/*
-		 * set rq_sent so that this request is treated
-		 * as a delayed send in the upper layers
-		 */
-		if (rc == -ENOMEM)
-			request->rq_sent = ktime_get_seconds();
+	if (rc)
 		goto out;
-	}
 
 	/* bulk register should be done after wrap_request() */
 	if (request->rq_bulk) {
@@ -724,9 +717,18 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 * the chance to have long unlink to sluggish net is smaller here.
 	 */
 	ptlrpc_unregister_bulk(request, 0);
- out:
+out:
+	if (rc == -ENOMEM) {
+		/*
+		 * set rq_sent so that this request is treated
+		 * as a delayed send in the upper layers
+		 */
+		request->rq_sent = ktime_get_seconds();
+	}
+
 	if (request->rq_memalloc)
 		memalloc_noreclaim_restore(mpflag);
+
 	return rc;
 }
 EXPORT_SYMBOL(ptl_send_rpc);
-- 
1.8.3.1
