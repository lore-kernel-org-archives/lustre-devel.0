From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:44 -0400
Subject: [lustre-devel] [PATCH 145/151] lustre: ptlrpc: simplify locking in
 ptlrpc_add_rqs_to_pool()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-146-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This spinlock is only needed in this function to
protect the list_add_tail(), so make that more
obvious.

This change means that prp_rq_size is set outside of the spinlock, but
as it is only ever read outside of the spinlock, that cannot matter.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Lustre-commit: a0240c3ef723 ("LU-4423 ptlrpc: simplify locking in ptlrpc_add_rqs_to_pool()")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35511
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 6055980..8328c71 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -566,13 +566,11 @@ int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
 		 "Trying to change pool size with nonempty pool from %d to %d bytes\n",
 		 pool->prp_rq_size, size);
 
-	spin_lock(&pool->prp_lock);
 	pool->prp_rq_size = size;
 	for (i = 0; i < num_rq; i++) {
 		struct ptlrpc_request *req;
 		struct lustre_msg *msg;
 
-		spin_unlock(&pool->prp_lock);
 		req = ptlrpc_request_cache_alloc(GFP_KERNEL);
 		if (!req)
 			return i;
@@ -586,8 +584,8 @@ int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
 		req->rq_pool = pool;
 		spin_lock(&pool->prp_lock);
 		list_add_tail(&req->rq_list, &pool->prp_req_list);
+		spin_unlock(&pool->prp_lock);
 	}
-	spin_unlock(&pool->prp_lock);
 	return num_rq;
 }
 EXPORT_SYMBOL(ptlrpc_add_rqs_to_pool);
-- 
1.8.3.1
