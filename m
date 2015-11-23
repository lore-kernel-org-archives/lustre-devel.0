From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Mon, 23 Nov 2015 23:42:34 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: constify
	ptlrpc_sec_cops structs
Message-ID: <20151123214234.GA9568@waves>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Constifies ptlrpc_sec_cops structures in the lustre driver
since they are not modified after their initialization.

Detected and found using Coccinelle.

Suggested-by: Julia Lawall <Julia.Lawall@lip6.fr>
Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/sec.c       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c  | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 39f5261..f959897 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -1580,7 +1580,7 @@ int sptlrpc_cli_enlarge_reqbuf(struct ptlrpc_request *req,
 			       int segment, int newsize)
 {
 	struct ptlrpc_cli_ctx *ctx = req->rq_cli_ctx;
-	struct ptlrpc_sec_cops *cops;
+	const struct ptlrpc_sec_cops *cops;
 	struct lustre_msg *msg = req->rq_reqmsg;
 
 	LASSERT(ctx);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index ebfa609..ffdad15 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -378,7 +378,7 @@ static struct ptlrpc_ctx_ops null_ctx_ops = {
 	.verify		 = null_ctx_verify,
 };
 
-static struct ptlrpc_sec_cops null_sec_cops = {
+static const struct ptlrpc_sec_cops null_sec_cops = {
 	.create_sec	     = null_create_sec,
 	.destroy_sec	    = null_destroy_sec,
 	.lookup_ctx	     = null_lookup_ctx,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index f448b45..71351de 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -956,7 +956,7 @@ static struct ptlrpc_ctx_ops plain_ctx_ops = {
 	.unwrap_bulk	    = plain_cli_unwrap_bulk,
 };
 
-static struct ptlrpc_sec_cops plain_sec_cops = {
+static const struct ptlrpc_sec_cops plain_sec_cops = {
 	.create_sec	     = plain_create_sec,
 	.destroy_sec	    = plain_destroy_sec,
 	.kill_sec	       = plain_kill_sec,
-- 
2.4.3


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
