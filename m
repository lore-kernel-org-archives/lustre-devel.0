From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:09 -0500
Subject: [lustre-devel] [PATCH 021/622] lustre: ptlrpc:
 ptlrpc_register_bulk() LBUG on ENOMEM
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Assertion fails on !desc->bd_registered during
retry after ENOMEM.

Drop bd_registered flag and exit via cleanup_bulk
to ensure that bulk is fully unregistered.

Cray-bug-id: MRP-4733
WC-bug-id: https://jira.whamcloud.com/browse/LU-10643
Lustre-commit: 4a81be263079 ("LU-10643 ptlrpc: ptlrpc_register_bulk() LBUG on ENOMEM")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/31228
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ptlrpc/niobuf.c       | 12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 653a456..67500b5 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -349,6 +349,7 @@
 #define OBD_FAIL_PTLRPC_DROP_BULK			0x51a
 #define OBD_FAIL_PTLRPC_LONG_REQ_UNLINK			0x51b
 #define OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK		0x51c
+#define OBD_FAIL_PTLRPC_BULK_ATTACH      0x521
 
 #define OBD_FAIL_OBD_PING_NET				0x600
 #define OBD_FAIL_OBD_LOG_CANCEL_NET			0x601
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 02ed373..2e866fe 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -179,8 +179,13 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 			      LNET_MD_OP_GET : LNET_MD_OP_PUT);
 		ptlrpc_fill_bulk_md(&md, desc, posted_md);
 
-		rc = LNetMEAttach(desc->bd_portal, peer, mbits, 0,
-				  LNET_UNLINK, LNET_INS_AFTER, &me_h);
+		if (posted_md > 0 && posted_md + 1 == total_md &&
+		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_ATTACH)) {
+			rc = -ENOMEM;
+		} else {
+			rc = LNetMEAttach(desc->bd_portal, peer, mbits, 0,
+					  LNET_UNLINK, LNET_INS_AFTER, &me_h);
+		}
 		if (rc != 0) {
 			CERROR("%s: LNetMEAttach failed x%llu/%d: rc = %d\n",
 			       desc->bd_import->imp_obd->obd_name, mbits,
@@ -209,6 +214,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		LASSERT(desc->bd_md_count >= 0);
 		mdunlink_iterate_helper(desc->bd_mds, desc->bd_md_max_brw);
 		req->rq_status = -ENOMEM;
+		desc->bd_registered = 0;
 		return -ENOMEM;
 	}
 
@@ -585,7 +591,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	if (request->rq_bulk) {
 		rc = ptlrpc_register_bulk(request);
 		if (rc != 0)
-			goto out;
+			goto cleanup_bulk;
 		/*
 		 * All the mds in the request will have the same cpt
 		 * encoded in the cookie. So we can just get the first
-- 
1.8.3.1
