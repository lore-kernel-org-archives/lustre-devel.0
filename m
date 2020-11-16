From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:42 -0500
Subject: [lustre-devel] [PATCH 09/28] lustre: gss: update sequence in case
 of target disconnect
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Client to OST connections can go idle, leading to target disconnect.
In this event, maintaining correct sequence number ensures that GSS
does not erroneously consider requests as replays.
Sequence is normally updated on export destroy, but this can occur too
late, ie after a new target connect request has been processed. So
explicitly update sec context at disconnect time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13498
Lustre-commit: 1275857c178fdf ("LU-13498 gss: update sequence in case of target disconnect")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/40122
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec.c      | 4 ++--
 fs/lustre/ptlrpc/sec_null.c | 8 --------
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index ca8a646..44c15e6 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -626,8 +626,8 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 		return 0;
 
 	if (unlikely(test_bit(PTLRPC_CTX_NEW_BIT, &ctx->cc_flags))) {
-		LASSERT(ctx->cc_ops->refresh);
-		ctx->cc_ops->refresh(ctx);
+		if (ctx->cc_ops->refresh)
+			ctx->cc_ops->refresh(ctx);
 	}
 	LASSERT(test_bit(PTLRPC_CTX_NEW_BIT, &ctx->cc_flags) == 0);
 
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index 14058bf..97c4e19 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -66,13 +66,6 @@ enum lustre_sec_part null_decode_sec_part(struct lustre_msg *msg)
 	return (msg->lm_secflvr >> 24) & 0xFF;
 }
 
-static int null_ctx_refresh(struct ptlrpc_cli_ctx *ctx)
-{
-	/* should never reach here */
-	LBUG();
-	return 0;
-}
-
 static
 int null_ctx_sign(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 {
@@ -374,7 +367,6 @@ int null_authorize(struct ptlrpc_request *req)
 }
 
 static struct ptlrpc_ctx_ops null_ctx_ops = {
-	.refresh		= null_ctx_refresh,
 	.sign			= null_ctx_sign,
 	.verify			= null_ctx_verify,
 };
-- 
1.8.3.1
