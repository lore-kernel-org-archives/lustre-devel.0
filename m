From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:30 -0400
Subject: [lustre-devel] [PATCH 011/151] lustre: fld: retry fld rpc even for
 ESHUTDOWN
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Di <di.wang@intel.com>

when LWP is being evicted, because it is not replayable,
the request might return ESHUTDOWN or EWOULDBLOCK, instead
of failed, which might cause application failure, fld
client will retry RPC, until the connection is being setup
again or the LWP is being closed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4420
Lustre-commit: d335e310d4bf ("LU-4420 fld: retry fld rpc even for ESHUTDOWN")
Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10285
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 4cb49cb..b5b905f 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -367,12 +367,12 @@ int fld_client_rpc(struct obd_export *exp,
 	rc = ptlrpc_queue_wait(req);
 	obd_put_request_slot(&exp->exp_obd->u.cli);
 	if (rc != 0) {
-		if (rc == -EWOULDBLOCK) {
-			/* For no_delay req(see above), EWOULDBLOCK means the
-			 * connection is being evicted, but this seq lookup
-			 * should not return error, since it would cause
-			 * unnecessary failure of the application, instead
-			 * it should retry here
+		if (rc == -EWOULDBLOCK || rc == -ESHUTDOWN) {
+			/* For no_delay req(see above), EWOULDBLOCK and
+			 * ESHUTDOWN means the connection is being evicted,
+			 * but this seq lookup should not return error,
+			 * since it would cause unnecessary failure of the
+			 * application, instead it should retry here
 			 */
 			ptlrpc_req_finished(req);
 			goto again;
-- 
1.8.3.1
