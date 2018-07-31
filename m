From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:13 -0400
Subject: [lustre-devel] [PATCH 21/31] lustre: osc: hung in osc_destroy()
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

cl_destroy_in_flight becomes < 0 because the
osc_can_send_destroy() won't increment
cl_destroy_in_flight if l_wait_event() gets
interrupted by a signal, but the request will
still be sent and the request's interpret
function will decrease the counter.

Don't send OST_DESTROY request on signal
and return -EINTR.

Signed-off-by: Andriy Skulysh <c17819@cray.com>
Seagate-bug-id: MRP-3834
WC-id: https://jira.whamcloud.com/browse/LU-8624
Reviewed-on: https://review.whamcloud.com/22588
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_request.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 21497ea..b7f8e07 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -652,8 +652,12 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 		 * Wait until the number of on-going destroy RPCs drops
 		 * under max_rpc_in_flight
 		 */
-		l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
-					       osc_can_send_destroy(cli));
+		rc = l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
+						      osc_can_send_destroy(cli));
+		if (rc) {
+			ptlrpc_request_free(req);
+			return rc;
+		}
 	}
 
 	/* Do not wait for response */
-- 
1.8.3.1
