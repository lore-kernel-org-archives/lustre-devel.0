From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:10 -0500
Subject: [lustre-devel] [PATCH 442/622] lustre: ptlrpc: Stop sending
 ptlrpc_body_v2
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-443-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

ptlrpc_body_v2 does not include space for jobids, that
means that when we added jobid to the RPC debug messages,
we started getting errors like this:

LustreError: 6817:0:(pack_generic.c:425:lustre_msg_buf_v2()) msg
000000005c83b7a2 buffer[0] size 152 too small (required 184, opc=-1)

This happened every time we tried to print a ptlrpc_body_v2
message.

body_v2 is still sent on some RPCs for compatibility with
very old versions of Lustre, but we no longer support
interop with those versions (latest reported is 2.3).

So, stop sending ptlrpc_body_v2 on any RPCs.

Note that we need to retain the ptlrpc_body_v2 definitions
and parsing capability for interop with servers which still
use them for some messages, which is all prior to this
patch.

One further note:
This does *not* fix the case of newer clients collecting
rpctrace with older servers.  They will still see the
error message for some RPCs.  That could be fixed with
tweaks to the debug printing code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12523
Lustre-commit: fb18c05c0f5e ("LU-12523 ptlrpc: Stop sending ptlrpc_body_v2")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35583
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c       | 27 +--------------------------
 fs/lustre/ptlrpc/niobuf.c       | 11 -----------
 fs/lustre/ptlrpc/pack_generic.c | 16 ++--------------
 3 files changed, 3 insertions(+), 51 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index dcc5e6b..c750a4e 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -817,32 +817,7 @@ int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 int ptlrpc_request_pack(struct ptlrpc_request *request,
 			u32 version, int opcode)
 {
-	int rc;
-
-	rc = ptlrpc_request_bufs_pack(request, version, opcode, NULL, NULL);
-	if (rc)
-		return rc;
-
-	/*
-	 * For some old 1.8 clients (< 1.8.7), they will LASSERT the size of
-	 * ptlrpc_body sent from server equal to local ptlrpc_body size, so we
-	 * have to send old ptlrpc_body to keep interoperability with these
-	 * clients.
-	 *
-	 * Only three kinds of server->client RPCs so far:
-	 *  - LDLM_BL_CALLBACK
-	 *  - LDLM_CP_CALLBACK
-	 *  - LDLM_GL_CALLBACK
-	 *
-	 * XXX This should be removed whenever we drop the interoperability with
-	 *     the these old clients.
-	 */
-	if (opcode == LDLM_BL_CALLBACK || opcode == LDLM_CP_CALLBACK ||
-	    opcode == LDLM_GL_CALLBACK)
-		req_capsule_shrink(&request->rq_pill, &RMF_PTLRPC_BODY,
-				   sizeof(struct ptlrpc_body_v2), RCL_CLIENT);
-
-	return rc;
+	return ptlrpc_request_bufs_pack(request, version, opcode, NULL, NULL);
 }
 EXPORT_SYMBOL(ptlrpc_request_pack);
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 2e866fe..9d9e94c 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -388,17 +388,6 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 		       req->rq_export->exp_obd->obd_minor);
 	}
 
-	/* In order to keep interoperability with the client (< 2.3) which
-	 * doesn't have pb_jobid in ptlrpc_body, We have to shrink the
-	 * ptlrpc_body in reply buffer to ptlrpc_body_v2, otherwise, the
-	 * reply buffer on client will be overflow.
-	 *
-	 * XXX Remove this whenever we drop the interoperability with
-	 * such client.
-	 */
-	req->rq_replen = lustre_shrink_msg(req->rq_repmsg, 0,
-					   sizeof(struct ptlrpc_body_v2), 1);
-
 	if (req->rq_type != PTL_RPC_MSG_ERR)
 		req->rq_type = PTL_RPC_MSG_REPLY;
 
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 6a4ea7a..e63720b 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -91,21 +91,9 @@ bool ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 /* early reply size */
 u32 lustre_msg_early_size(void)
 {
-	static u32 size;
-
-	if (!size) {
-		/* Always reply old ptlrpc_body_v2 to keep interoperability
-		 * with the old client (< 2.3) which doesn't have pb_jobid
-		 * in the ptlrpc_body.
-		 *
-		 * XXX Remove this whenever we drop interoperability with such
-		 *     client.
-		 */
-		u32 pblen = sizeof(struct ptlrpc_body_v2);
+	u32 pblen = sizeof(struct ptlrpc_body);
 
-		size = lustre_msg_size(LUSTRE_MSG_MAGIC_V2, 1, &pblen);
-	}
-	return size;
+	return lustre_msg_size(LUSTRE_MSG_MAGIC_V2, 1, &pblen);
 }
 EXPORT_SYMBOL(lustre_msg_early_size);
 
-- 
1.8.3.1
