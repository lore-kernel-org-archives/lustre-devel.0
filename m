From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:50 -0500
Subject: [lustre-devel] [PATCH 542/622] lustre: ptlrpc: do lu_env_refill for
 any new request
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-543-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Perform lu_env_refill() prior any new request handling. That was
done already server side by tgt_request_handle() and is moved now
to ptlrpc_main() to work for any handler as well,
e.g. ldlm_cancel_handler()

WC-bug-id: https://jira.whamcloud.com/browse/LU-12741
Lustre-commit: 3f304b75d24a ("LU-12741 ptlrpc: do lu_env_refill for new request")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36714
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index c874487..f65d5c5 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2281,6 +2281,12 @@ static int ptlrpc_main(void *arg)
 			ptlrpc_start_thread(svcpt, 0);
 		}
 
+		/* reset le_ses to initial state */
+		env->le_ses = NULL;
+		/* Refill the context before execution to make sure
+		 * all thread keys are allocated
+		 */
+		lu_env_refill(env);
 		/* Process all incoming reqs before handling any */
 		if (ptlrpc_server_request_incoming(svcpt)) {
 			lu_context_enter(&env->le_ctx);
-- 
1.8.3.1
