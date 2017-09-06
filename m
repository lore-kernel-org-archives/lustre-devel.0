From: Tyson Whitehead <twhitehead@gmail.com>
Date: Wed, 06 Sep 2017 12:04:39 -0400
Subject: [lustre-devel] [PATCH 1/2] LU-6808 ptlrpc: properly set "rq_xid"
	for 4MB IO
Message-ID: <7562960.y17JJjcatH@whitehead.beowulf.uwo.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

The commit d099fdd6 replaced the "rq_xid" with "rq_mbits" as
the matchbits of bulk data transferring. To be interoperable
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

Test-Parameters: alwaysuploadlogs testlist=sanity envdefinitions=ONLY=224c ossjob=lustre-b2_7_fe mdsjob=lustre-b2_7_fe ossbuildno=95 mdsbuildno=95 mdsdistro=el6.7 ossdistro=el6.7
Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6808
Reviewed-on: http://review.whamcloud.com/22373
Tested-by: Jenkins
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Tested-by: Maloo <hpdd-maloo@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: Tyson Whitehead <twhitehead@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 6466974a43e7..0f9db5526ba5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3123,8 +3123,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 	} else { /* needs to generate a new matchbits for resend */
 		u64 old_mbits = req->rq_mbits;
 
-		if ((bd->bd_import->imp_connect_data.ocd_connect_flags &
-		     OBD_CONNECT_BULK_MBITS)) {
+		if (OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS)){
 			req->rq_mbits = ptlrpc_next_xid();
 		} else {
 			/* old version transfers rq_xid to peer as matchbits */
@@ -3145,6 +3144,11 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
 	 * see LU-1431
 	 */
 	req->rq_mbits += DIV_ROUND_UP(bd->bd_iov_count, LNET_MAX_IOV) - 1;
+
+	/* Set rq_xid as rq_mbits to indicate the final bulk for the old
+	 * server which does not support OBD_CONNECT_BULK_MBITS. LU-6808 */
+	if (!OCD_HAS_FLAG(&bd->bd_import->imp_connect_data, BULK_MBITS))
+		req->rq_xid = req->rq_mbits;
 }
 
 /**
-- 
2.14.0
