From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:04 -0500
Subject: [lustre-devel] [PATCH 016/622] lustre: ldlm: don't disable softirq
 for exp_rpc_lock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

it is not necessary to call ldlm_lock_busy() in the context of timer
callback, we can call it in thread context of expired_lock_main.
With this change, we don't need to disable softirq for exp_rpc_lock.

Instead of moving busy locks to the end of the waiting list one
at a time in the context of the timer callback, move any locks
that may be expired onto the expired list.  If these locks are
still being used by RPCs being processed, then put them back
onto the end of the waiting list instead of evicting the client.

For the linux client the impact of this change is change of
spin_lock_bh() to spin_lock() for the exp_rpc_lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6032
Lustre-commit: 292aa42e0897 ("LU-6032 ldlm: don't disable softirq for exp_rpc_lock")
Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-on: https://review.whamcloud.com/12957
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index d57df36..3c61e83 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1307,9 +1307,9 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 			LASSERT(rc <= 1);
 		}
 
-		spin_lock_bh(&req->rq_export->exp_rpc_lock);
+		spin_lock(&req->rq_export->exp_rpc_lock);
 		list_add(&req->rq_exp_list, &req->rq_export->exp_hp_rpcs);
-		spin_unlock_bh(&req->rq_export->exp_rpc_lock);
+		spin_unlock(&req->rq_export->exp_rpc_lock);
 	}
 
 	ptlrpc_nrs_req_initialize(svcpt, req, rc);
@@ -1327,9 +1327,9 @@ static void ptlrpc_server_hpreq_fini(struct ptlrpc_request *req)
 		if (req->rq_ops->hpreq_fini)
 			req->rq_ops->hpreq_fini(req);
 
-		spin_lock_bh(&req->rq_export->exp_rpc_lock);
+		spin_lock(&req->rq_export->exp_rpc_lock);
 		list_del_init(&req->rq_exp_list);
-		spin_unlock_bh(&req->rq_export->exp_rpc_lock);
+		spin_unlock(&req->rq_export->exp_rpc_lock);
 	}
 }
 
-- 
1.8.3.1
