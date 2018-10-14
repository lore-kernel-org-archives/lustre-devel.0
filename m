From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:53 -0400
Subject: [lustre-devel] [PATCH 03/28] lustre: ptlrpc: missing barrier before
 wake_up
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

ptlrpc_client_wake_req() misses a memory barrier, which may cause
strange errors.

Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8935
Reviewed-on: https://review.whamcloud.com/26583
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index ce7e98c..468a03e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2211,6 +2211,8 @@ static inline int ptlrpc_status_ntoh(int n)
 static inline void
 ptlrpc_client_wake_req(struct ptlrpc_request *req)
 {
+	/* ensure ptlrpc_register_bulk see rq_resend as set. */
+	smp_mb();
 	if (!req->rq_set)
 		wake_up(&req->rq_reply_waitq);
 	else
-- 
1.8.3.1
