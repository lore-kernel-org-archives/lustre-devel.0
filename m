From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:05 -0400
Subject: [lustre-devel] [PATCH 09/20] lustre: ptlrpc: Clear bd_registered in
 ptlrpc_unregister_bulk
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The patch for LU-12816 https://review.whamcloud.com/36309 has us
clearing the bd_registered flag in ptl_send_rpc(). This flag is set
in ptlrpc_register_bulk(), so it makes sense for us to clear it in
ptlrpc_unregister_bulk(). When we're cleaning up in ptl_send_rpc()
we can be sure the flag is cleared with the call to
ptlrpc_unregister_bulk().

This commit also adds a test case for the LU-12816 bug.

Fixes: 1010595a9bb6 ("lustre: ptlrpc: ptlrpc_register_bulk LBUG on ENOMEM")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13509
Lustre-commit: 15057a17ca1e2 ("LU-13509 ptlrpc: Clear bd_registered in ptlrpc_unregister_bulk")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38457
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ptlrpc/niobuf.c       | 18 +++++++++++++-----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index b706a20..d1d21e0 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -362,6 +362,7 @@
 #define OBD_FAIL_PTLRPC_LONG_REQ_UNLINK			0x51b
 #define OBD_FAIL_PTLRPC_LONG_BOTH_UNLINK		0x51c
 #define OBD_FAIL_PTLRPC_BULK_ATTACH			0x521
+#define OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH		0x522
 #define OBD_FAIL_PTLRPC_ROUND_XID			0x530
 #define OBD_FAIL_PTLRPC_CONNECT_RACE			0x531
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index d62629a..331a0c8 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -250,6 +250,9 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 
 	LASSERT(!in_interrupt());     /* might sleep */
 
+	if (desc)
+		desc->bd_registered = 0;
+
 	/* Let's setup deadline for reply unlink. */
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_LONG_BULK_UNLINK) &&
 	    async && req->rq_bulk_deadline == 0 && cfs_fail_val == 0)
@@ -614,9 +617,16 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			request->rq_repmsg = NULL;
 		}
 
-		reply_me = LNetMEAttach(request->rq_reply_portal,
-					connection->c_peer, request->rq_xid, 0,
-					LNET_UNLINK, LNET_INS_AFTER);
+		if (request->rq_bulk &&
+		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH)) {
+			reply_me = ERR_PTR(-ENOMEM);
+		} else {
+			reply_me = LNetMEAttach(request->rq_reply_portal,
+						connection->c_peer,
+						request->rq_xid, 0,
+						LNET_UNLINK, LNET_INS_AFTER);
+		}
+
 		if (IS_ERR(reply_me)) {
 			rc = PTR_ERR(reply_me);
 			CERROR("LNetMEAttach failed: %d\n", rc);
@@ -724,8 +734,6 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 * the chance to have long unlink to sluggish net is smaller here.
 	 */
 	ptlrpc_unregister_bulk(request, 0);
-	if (request->rq_bulk)
-		request->rq_bulk->bd_registered = 0;
 out:
 	if (rc == -ENOMEM) {
 		/*
-- 
1.8.3.1
