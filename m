From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:42 -0400
Subject: [lustre-devel] [PATCH 023/151] lustre: ptlrpc: remove incorrect pid
 printing
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Remove incorrect pid printing in ptlrpc_send_new_req().
It was always printing 0, and current pid is part of the message
header anyway.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7760
Lustre-commit: 3283170eeb05 ("LU-7760 ptlrpc: remove incorrect pid printing")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/27336
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index f7f3678..ba894c0 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1551,8 +1551,7 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 		spin_unlock(&req->rq_lock);
 
 		DEBUG_REQ(D_HA, req,
-			  "req from PID %d waiting for recovery: (%s != %s)",
-			  lustre_msg_get_status(req->rq_reqmsg),
+			  "req waiting for recovery: (%s != %s)",
 			  ptlrpc_import_state_name(req->rq_send_state),
 			  ptlrpc_import_state_name(imp->imp_state));
 		LASSERT(list_empty(&req->rq_list));
-- 
1.8.3.1
