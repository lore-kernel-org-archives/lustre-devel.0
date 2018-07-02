From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:30 -0400
Subject: [lustre-devel] [PATCH 13/18] lustre: ptlrpc: properly set "rq_xid"
 for 4MB IO
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fyong@whamcloud.com>

The commit 8bcaef92664f ("staging: lustre: ptlrpc: mbits is sent
within ptlrpc_body") replaced the "rq_xid" with "rq_mbits"
as the matchbits of bulk data transferring. To be interoperable
with old servers, it introduced the new connection flag:
OBD_CONNECT_BULK_MBITS. If the server does not support such
feature, then the "rq_xid" would be set the same value as
"rq_mbits". Unfortunately, it forgot to handle multiple bulk
operations, for example 4MB IO. If the new client wants to
make 4MB IO with old server, it may send a small "rq_xid" to
the old server, as to the old server will regard it as an 1MB
IO or 2MB IO. So the data transfer will not complete because
of only part of data transferred. Then the client will timeout
failure and retry again and again.

Fixes: 8bcaef92664f ("staging: lustre: ptlrpc: mbits is sent within ptlrpc_body)
Signed-off-by: Fan Yong <fyong@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-6808
Reviewed-on: http://review.whamcloud.com/22373
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: Tyson Whitehead <twhitehead@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index c1b82bf..fee4e49 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3084,8 +3084,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 		 * 'resend for the -EINPROGRESS resend'. To make it simple,
 		 * we opt to generate mbits for all resend cases.
 		 */
-		if ((bd->bd_import->imp_connect_data.ocd_connect_flags &
-		     OBD_CONNECT_BULK_MBITS)) {
+		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS)) {
 			req->rq_mbits = ptlrpc_next_xid();
 		} else {
 			/* old version transfers rq_xid to peer as matchbits */
@@ -3115,6 +3114,12 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 	 * see LU-1431
 	 */
 	req->rq_mbits += DIV_ROUND_UP(bd->bd_iov_count, LNET_MAX_IOV) - 1;
+
+	/* Set rq_xid as rq_mbits to indicate the final bulk for the old
+	 * server which does not support OBD_CONNECT_BULK_MBITS. LU-6808
+	 */
+	if (!OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS))
+		req->rq_xid = req->rq_mbits;
 }
 
 /**
-- 
1.8.3.1
