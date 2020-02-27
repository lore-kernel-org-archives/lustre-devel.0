From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:22 -0500
Subject: [lustre-devel] [PATCH 274/622] lustre: ptlrpc: Bulk assertion fails
 on -ENOMEM
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-275-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Recalculate rq_mbits on ENOMEM resend if OBD_CONNECT_BULK_MBITS
isn't used.

Cray-bug-id: LUS-7159
WC-bug-id: https://jira.whamcloud.com/browse/LU-12218
Lustre-commit: e63a49fa6920 ("LU-12218 ptlrpc: Bulk assertion fails on -ENOMEM")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/34753
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 0f5aa92..7c243af 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -3182,7 +3182,14 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 		       old_mbits, req->rq_mbits);
 	} else if (!(lustre_msg_get_flags(req->rq_reqmsg) & MSG_REPLAY)) {
 		/* Request being sent first time, use xid as matchbits. */
-		req->rq_mbits = req->rq_xid;
+		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS)
+		    || req->rq_mbits == 0) {
+			req->rq_mbits = req->rq_xid;
+		} else {
+			int total_md = (bd->bd_iov_count + LNET_MAX_IOV - 1) /
+					LNET_MAX_IOV;
+			req->rq_mbits -= total_md - 1;
+		}
 	} else {
 		/*
 		 * Replay request, xid and matchbits have already been
-- 
1.8.3.1
