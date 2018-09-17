From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:36 -0400
Subject: [lustre-devel] [PATCH 26/30] lustre: ptlrpc: add replay request
 into unreplied list
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

ptlrpc_prepare_replay() may fail to add replay request into unreplied
list if the request hasn't been on replay list yet, so in
ptlrpc_replay_next() before sending replay, we'd always make sure the
replay request is on unreplied list.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9274
Reviewed-on: https://review.whamcloud.com/27920
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/recover.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 2ea0a7f..9d369f8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -136,11 +136,14 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	if (req && imp->imp_resend_replay)
 		lustre_msg_add_flags(req->rq_reqmsg, MSG_RESENT);
 
-	/* The resend replay request may have been removed from the
+	/* ptlrpc_prepare_replay() may fail to add the request into unreplied
+	 * list if the request hasn't been added to replay list then. Another
+	 * exception is that resend replay could have been removed from the
 	 * unreplied list.
 	 */
-	if (req && imp->imp_resend_replay &&
-	    list_empty(&req->rq_unreplied_list)) {
+	if (req && list_empty(&req->rq_unreplied_list)) {
+		DEBUG_REQ(D_HA, req, "resend_replay: %d, last_transno: %llu\n",
+			  imp->imp_resend_replay, last_transno);
 		ptlrpc_add_unreplied(req);
 		imp->imp_known_replied_xid = ptlrpc_known_replied_xid(imp);
 	}
@@ -149,9 +152,6 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	spin_unlock(&imp->imp_lock);
 
 	if (req) {
-		/* The request should have been added back in unreplied list
-		 * by ptlrpc_prepare_replay().
-		 */
 		LASSERT(!list_empty(&req->rq_unreplied_list));
 
 		rc = ptlrpc_replay_req(req);
-- 
1.8.3.1
