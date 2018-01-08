From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Jan 2018 14:28:13 +1100
Subject: [lustre-devel] [PATCH 16/19] staging: lustre: use explicit poll
 loop in ptlrpc_unregister_reply
In-Reply-To: <151538168618.23920.8261096424342988792.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
Message-ID: <151538209390.23920.11839113414532003231.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

replace l_wait_event() with wait_event_idle_timeout() and explicit
loop.  This approach is easier to understand.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index f70176c6db08..ffdd3ffd62c6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2500,7 +2500,6 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 {
 	int rc;
 	wait_queue_head_t *wq;
-	struct l_wait_info lwi;
 
 	/* Might sleep. */
 	LASSERT(!in_interrupt());
@@ -2543,16 +2542,17 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		 * Network access will complete in finite time but the HUGE
 		 * timeout lets us CWARN for visibility of sluggish NALs
 		 */
-		lwi = LWI_TIMEOUT_INTERVAL(LONG_UNLINK * HZ,
-					   HZ, NULL, NULL);
-		rc = l_wait_event(*wq, !ptlrpc_client_recv_or_unlink(request),
-				  &lwi);
-		if (rc == 0) {
+		int cnt = 0;
+		while (cnt < LONG_UNLINK &&
+		       (rc = wait_event_idle_timeout(*wq,
+						     !ptlrpc_client_recv_or_unlink(request),
+						     HZ)) == 0)
+			cnt += 1;
+		if (rc > 0) {
 			ptlrpc_rqphase_move(request, request->rq_next_phase);
 			return 1;
 		}
 
-		LASSERT(rc == -ETIMEDOUT);
 		DEBUG_REQ(D_WARNING, request,
 			  "Unexpectedly long timeout receiving_reply=%d req_ulinked=%d reply_unlinked=%d",
 			  request->rq_receiving_reply,
