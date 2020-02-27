From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:03 -0500
Subject: [lustre-devel] [PATCH 195/622] lustre: ptlrpc: always unregister
 bulk
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-196-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In ptlrpc_check_set, the bulk should be unregistered before
ptl_send_rpc in any case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11647
Lustre-commit: 21c53b18a1bc ("LU-11647 ptlrpc: always unregister bulk")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/22378
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index ff212a3..f57ec1883 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1902,9 +1902,6 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					spin_lock(&req->rq_lock);
 					req->rq_resend = 1;
 					spin_unlock(&req->rq_lock);
-					if (req->rq_bulk &&
-					    !ptlrpc_unregister_bulk(req, 1))
-						continue;
 				}
 				/*
 				 * rq_wait_ctx is only touched by ptlrpcd,
@@ -1931,6 +1928,13 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					spin_unlock(&req->rq_lock);
 				}
 
+				/* In any case, the previous bulk should be
+				 * cleaned up to prepare for the new sending
+				 */
+				if (req->rq_bulk &&
+				    !ptlrpc_unregister_bulk(req, 1))
+					continue;
+
 				rc = ptl_send_rpc(req, 0);
 				if (rc == -ENOMEM) {
 					spin_lock(&imp->imp_lock);
-- 
1.8.3.1
