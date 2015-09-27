From: Jayavant Kenjalkar <jgkenjalkar@gmail.com>
Date: Sun, 27 Sep 2015 11:15:21 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: Fix warning detected by
	coccicheck
Message-ID: <20150927054521.GA6985@jay-HP-G62-Notebook-PC>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jayavant Kenjalkar <jgkenjalkar@gmail.com>

Removing redundant semicolon as detected by coccicheck.

Signed-off-by: Jayavant Kenjalkar <jgkenjalkar@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 92c746b..cb10b89 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -601,7 +601,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		/* Manage remote for early replies */
 		reply_md.options = PTLRPC_MD_OPTIONS | LNET_MD_OP_PUT |
 			LNET_MD_MANAGE_REMOTE |
-			LNET_MD_TRUNCATE; /* allow to make EOVERFLOW error */;
+			LNET_MD_TRUNCATE; /* allow to make EOVERFLOW error */
 		reply_md.user_ptr = &request->rq_reply_cbid;
 		reply_md.eq_handle = ptlrpc_eq_h;
 
-- 
1.7.9.5
