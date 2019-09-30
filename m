From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:31 -0400
Subject: [lustre-devel] [PATCH 012/151] lustre: fld: retry fld rpc until the
 import is closed
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Di <di.wang@intel.com>

Since LWP is not replayable, it should retry RPC until
the import is closed, otherwise it would cause unnecessary
failure of the application.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5312
Lustre-commit: 07d481957c16 ("LU-5312 fld: retry fld rpc until the import is closed")
Signed-off-by: Wang Di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/11039
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index b5b905f..062f19f 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -367,12 +367,10 @@ int fld_client_rpc(struct obd_export *exp,
 	rc = ptlrpc_queue_wait(req);
 	obd_put_request_slot(&exp->exp_obd->u.cli);
 	if (rc != 0) {
-		if (rc == -EWOULDBLOCK || rc == -ESHUTDOWN) {
-			/* For no_delay req(see above), EWOULDBLOCK and
-			 * ESHUTDOWN means the connection is being evicted,
-			 * but this seq lookup should not return error,
-			 * since it would cause unnecessary failure of the
-			 * application, instead it should retry here
+		if (imp->imp_state != LUSTRE_IMP_CLOSED) {
+			/* Since LWP is not replayable, so it will keep
+			 * trying unless umount happens, otherwise it would
+			 * cause unnecessary failure of the application.
 			 */
 			ptlrpc_req_finished(req);
 			goto again;
-- 
1.8.3.1
