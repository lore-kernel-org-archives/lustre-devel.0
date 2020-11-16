From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:51 -0500
Subject: [lustre-devel] [PATCH 18/28] lustre: ptlrpc: throttle RPC resend if
 network error
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Aurelien Degremont <degremoa@amazon.com>

When sending a callback AST to a non-responding client, the server
retries endlessly until the client is eventually evicted. When using
ksocklnd, it will retry after each AST timeout, until the socket is
eventually closed, after sock_timeout sec, where the retry will fail
immediately, returning -110, as no socket could be established.

The thread will spin on retrying and failing, until eventual client
eviction. This will cause high thread CPU usage and possible resource
denial.

To workaround that, this patch avoids re-trying callback resend if:
 - the request is flagged with network error and timeout
 - last try was less than 1 sec ago

In worst case, retry will happen after a timeout based on req->rq_deadline.
If there is nothing else to handle, thread will be sleeping during that
time, removing CPU overhead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13984
Lustre-commit: 4103527c1c9b38 ("LU-13984 ptlrpc: throttle RPC resend if network error")
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/40020
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index c9d9fe9..0e01ab33 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1900,6 +1900,26 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					goto interpret;
 				}
 
+				/* don't resend too fast in case of network
+				 * errors.
+				 */
+				if (ktime_get_real_seconds() < (req->rq_sent + 1)
+				    && req->rq_net_err && req->rq_timedout) {
+					DEBUG_REQ(D_INFO, req,
+						  "throttle request");
+					/* Don't try to resend RPC right away
+					 * as it is likely it will fail again
+					 * and ptlrpc_check_set() will be
+					 * called again, keeping this thread
+					 * busy. Instead, wait for the next
+					 * timeout. Flag it as resend to
+					 * ensure we don't wait to long.
+					 */
+					req->rq_resend = 1;
+					spin_unlock(&imp->imp_lock);
+					continue;
+				}
+
 				list_move_tail(&req->rq_list,
 					       &imp->imp_sending_list);
 
-- 
1.8.3.1
