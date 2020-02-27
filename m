From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:42 -0500
Subject: [lustre-devel] [PATCH 534/622] lustre: ptlrpc: ptlrpc_register_bulk
 LBUG on ENOMEM
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-535-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

Another path through ptl_send_rpc() can cause the assert reported
in LU-10643. The assertion in ptlrpc_register_bulk() on
!desc->bd_registered fails when an rpc is resent and the first
send attempt failed to successfully attach the reply buffer. The
bulk error cleanup in ptl_send_rpc() does not reset the
bd_registered flag.

Cray-bug-id: LUS-7946
WC-bug-id: https://jira.whamcloud.com/browse/LU-12816
Lustre-commit: e6225c07ce4c ("LU-12816 ptlrpc: ptlrpc_register_bulk LBUG on ENOMEM")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/36309
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 12a9a5e..fcf7bfa 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -720,6 +720,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 * the chance to have long unlink to sluggish net is smaller here.
 	 */
 	ptlrpc_unregister_bulk(request, 0);
+	if (request->rq_bulk)
+		request->rq_bulk->bd_registered = 0;
 out:
 	if (rc == -ENOMEM) {
 		/*
-- 
1.8.3.1
