From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:51 +1100
Subject: [lustre-devel] [PATCH 22/32] lustre: ptlrpc: simplify locking in
 ptlrpc_add_rqs_to_pool()
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231097.26912.7723694099024488897.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This spinlock is only needed in this function to
protect the list_add_tail(), so make that more
obvious.

This change means that prp_rq_size is set outside of the spinlock, but
as it is only ever read outside of the spinlock, that cannot matter.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index baf2b05e2f5c..2514a142e799 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -521,13 +521,11 @@ int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
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
@@ -541,8 +539,8 @@ int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq)
 		req->rq_pool = pool;
 		spin_lock(&pool->prp_lock);
 		list_add_tail(&req->rq_list, &pool->prp_req_list);
+		spin_unlock(&pool->prp_lock);
 	}
-	spin_unlock(&pool->prp_lock);
 	return num_rq;
 }
 EXPORT_SYMBOL(ptlrpc_add_rqs_to_pool);
