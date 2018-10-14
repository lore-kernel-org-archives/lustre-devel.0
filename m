From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:54 -0400
Subject: [lustre-devel] [PATCH 04/28] lustre: ptlrpc: Do not assert when
 bd_nob_transferred != 0
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <dougso@me.com>

There is a case in the routine ptlrpc_register_bulk() where we were
asserting if bd_nob_transferred != 0 when not resending.  There is
evidence that network errors can create a situation where
this does happen. So we should not be asserting!

This patch changes that assert to an error return code of -EIO.

Signed-off-by: Doug Oucharek <dougso@me.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9828
Reviewed-on: https://review.whamcloud.com/28491
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 27eb1c0..7e7db24 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -139,8 +139,12 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	/* cleanup the state of the bulk for it will be reused */
 	if (req->rq_resend || req->rq_send_state == LUSTRE_IMP_REPLAY)
 		desc->bd_nob_transferred = 0;
-	else
-		LASSERT(desc->bd_nob_transferred == 0);
+	else if (desc->bd_nob_transferred != 0)
+		/* If the network failed after an RPC was sent, this condition
+		 * could happen.  Rather than assert (was here before), return
+		 * an EIO error.
+		 */
+		return -EIO;
 
 	desc->bd_failure = 0;
 
-- 
1.8.3.1
