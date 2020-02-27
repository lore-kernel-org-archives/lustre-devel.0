From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:21 -0500
Subject: [lustre-devel] [PATCH 393/622] lustre: fld: let's caller to retry
 FLD_QUERY
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-394-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In fld_client_rpc(), if the FLD_QUERY request between MDTs fails
with -EWOUDBLOCK because the connection is lost, return -EAGAIN
to notify the caller to retry.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11761
Lustre-commit: e3f6111dfd1c ("LU-11761 fld: let's caller to retry FLD_QUERY")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34962
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c     | 23 ++++++++++++++---------
 fs/lustre/include/obd_support.h |  1 +
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 75cba18..52c148a 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -314,7 +314,6 @@ int fld_client_rpc(struct obd_export *exp,
 
 	LASSERT(exp);
 
-again:
 	imp = class_exp2cliimp(exp);
 	switch (fld_op) {
 	case FLD_QUERY:
@@ -363,17 +362,23 @@ int fld_client_rpc(struct obd_export *exp,
 	req->rq_reply_portal = MDC_REPLY_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
-	obd_get_request_slot(&exp->exp_obd->u.cli);
-	rc = ptlrpc_queue_wait(req);
-	obd_put_request_slot(&exp->exp_obd->u.cli);
+	if (OBD_FAIL_CHECK(OBD_FAIL_FLD_QUERY_REQ && req->rq_no_delay)) {
+		/* the same error returned by ptlrpc_import_delay_req */
+		rc = -EWOULDBLOCK;
+		req->rq_status = rc;
+	} else {
+		obd_get_request_slot(&exp->exp_obd->u.cli);
+		rc = ptlrpc_queue_wait(req);
+		obd_put_request_slot(&exp->exp_obd->u.cli);
+	}
+
 	if (rc != 0) {
 		if (imp->imp_state != LUSTRE_IMP_CLOSED && !imp->imp_deactive) {
-			/* Since LWP is not replayable, so it will keep
-			 * trying unless umount happens, otherwise it would
-			 * cause unnecessary failure of the application.
+			/*
+			 * Since LWP is not replayable, so notify the caller
+			 * to retry if needed after a while.
 			 */
-			ptlrpc_req_finished(req);
-			goto again;
+			rc = -EAGAIN;
 		}
 		goto out_req;
 	}
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 9609dd5..23f6bae 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -424,6 +424,7 @@
 #define OBD_FAIL_FLD					0x1100
 #define OBD_FAIL_FLD_QUERY_NET				0x1101
 #define OBD_FAIL_FLD_READ_NET				0x1102
+#define OBD_FAIL_FLD_QUERY_REQ				0x1103
 
 #define OBD_FAIL_SEC_CTX				0x1200
 #define OBD_FAIL_SEC_CTX_INIT_NET			0x1201
-- 
1.8.3.1
