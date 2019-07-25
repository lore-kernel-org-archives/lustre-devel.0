From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Jul 2019 22:44:04 -0400
Subject: [lustre-devel] [PATCH 5/8] lustre: fld: retry fld rpc until the
 import is closed
In-Reply-To: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
References: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1564022647-17351-6-git-send-email-jsimmons@infradead.org>
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
Lustre-commit: 07d481957c16832c782bb7d0c1fc436bcb148ea6
Signed-off-by: Wang Di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/11039
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 fs/lustre/fld/fld_request.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index ba0ef82..60e7105 100644
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
-			 * since it would cause unecessary failure of the
-			 * application, instead it should retry here
+		if (imp->imp_state != LUSTRE_IMP_CLOSED) {
+			/* Since LWP is not replayable, so it will keep
+			 * trying unless umount happens, otherwise it would
+			 * cause unecessary failure of the application.
 			 */
 			ptlrpc_req_finished(req);
 			goto again;
-- 
1.8.3.1
