From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:54 -0500
Subject: [lustre-devel] [PATCH 066/622] lustre: ptlrpc:
 ASSERTION(!list_empty(imp->imp_replay_cursor))
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-67-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

It's ptlrpc_replay_next() vs close race.
ll_close_inode_openhandle() calls
mdc_free_open()->ptlrpc_request_committed->ptlrpc_free_request

Need to reset imp_replay_cursor while dropping a request from
replay list.

Cray-bug-id: LUS-2455
WC-bug-id: https://jira.whamcloud.com/browse/LU-11098
Lustre-commit: d69d488e1778 ("LU-11098 ptlrpc: ASSERTION(!list_empty(imp->imp_replay_cursor))")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/32727
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index d28a9cd..57b08de 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2613,8 +2613,11 @@ void ptlrpc_request_committed(struct ptlrpc_request *req, int force)
 		return;
 	}
 
-	if (force || req->rq_transno <= imp->imp_peer_committed_transno)
+	if (force || req->rq_transno <= imp->imp_peer_committed_transno) {
+		if (imp->imp_replay_cursor == &req->rq_replay_list)
+			imp->imp_replay_cursor = req->rq_replay_list.next;
 		ptlrpc_free_request(req);
+	}
 
 	spin_unlock(&imp->imp_lock);
 }
-- 
1.8.3.1
