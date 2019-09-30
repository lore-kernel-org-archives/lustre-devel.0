From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:46 -0400
Subject: [lustre-devel] [PATCH 027/151] lustre: ptlrpc: Use C99 initializer
 in ptlrpc_register_rqbd()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

This patch makes no functional changes. The struct initializer in
ptlrpc_register_rqbd() is updated to C99 syntax.

C89 positional initializers require values to be placed in the
correct order. This will cause errors if the fields of the struct
definition are reordered or fields are added or removed. C99 named
initializers avoid this problem, and also automatically clear any
values that are not explicitly set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6210
Lustre-commit: 3af10d510078 ("LU-6210 ptlrpc: Use C99 initializer in ptlrpc_register_rqbd()")
Reviewed-on: https://review.whamcloud.com/28479
Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index e7aff51..f2b7902 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -747,7 +747,10 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 {
 	struct ptlrpc_service *service = rqbd->rqbd_svcpt->scp_service;
-	static struct lnet_process_id match_id = {LNET_NID_ANY, LNET_PID_ANY};
+	static struct lnet_process_id match_id = {
+		.nid = LNET_NID_ANY,
+		.pid = LNET_PID_ANY
+	};
 	int rc;
 	struct lnet_md md;
 	struct lnet_handle_me me_h;
-- 
1.8.3.1
