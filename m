From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:47 -0500
Subject: [lustre-devel] [PATCH 059/622] lustre: ptlrpc: don't zero request
 handle
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-60-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

LNet can retransmit a request at any time if it isn't replied.
The ptlrpc_resend_req zero the request handle and ptlrpc_send_rpc
set it. If retransmission happen with zeroed handle, the client
can't find a valid export by handle and set rq_export to NULL and
reply with ENOTCONN. A server evict client with this error.

client (nid x.x.x.x at tcp) returned error from blocking AST
(req status -107 rc -107), evict it

WC-bug-id: https://jira.whamcloud.com/browse/LU-11117
Lustre-commit: 00c72ab6bb43 ("LU-11117 ptlrpc: don't zero request handle")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-6037
Reviewed-on: https://review.whamcloud.com/32781
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 9b41c12..d28a9cd 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2728,7 +2728,6 @@ void ptlrpc_resend_req(struct ptlrpc_request *req)
 		return;
 	}
 
-	lustre_msg_set_handle(req->rq_reqmsg, &(struct lustre_handle){ 0 });
 	req->rq_status = -EAGAIN;
 
 	req->rq_resend = 1;
-- 
1.8.3.1
