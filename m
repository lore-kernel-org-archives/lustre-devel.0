From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:25 -0400
Subject: [lustre-devel] [PATCH 10/28] staging/lustre/ptlrpc: Remove
	__ptlrpc_request_bufs_pack
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, Oleg Drokin <green@linuxhacker.ru>

From: Ben Evans <bevans@cray.com>

Combine __ptlrpc_request_bufs_pack into ptlrpc_request_bufs_pack
because it was an unnecessary wrapper otherwise.

Signed-off-by: Ben Evans <bevans@cray.com>
Reviewed-on: http://review.whamcloud.com/16765
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7269
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c | 34 ++++++++++-----------------
 1 file changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index ae1cef3..5d832eb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -583,14 +583,19 @@ static void __ptlrpc_free_req_to_pool(struct ptlrpc_request *request)
 	spin_unlock(&pool->prp_lock);
 }
 
-static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
-				      __u32 version, int opcode,
-				      int count, __u32 *lengths, char **bufs,
-				      struct ptlrpc_cli_ctx *ctx)
+int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
+			     __u32 version, int opcode, char **bufs,
+			     struct ptlrpc_cli_ctx *ctx)
 {
-	struct obd_import *imp = request->rq_import;
+	int count;
+	struct obd_import *imp;
+	__u32 *lengths;
 	int rc;
 
+	count = req_capsule_filled_sizes(&request->rq_pill, RCL_CLIENT);
+	imp = request->rq_import;
+	lengths = request->rq_pill.rc_area[RCL_CLIENT];
+
 	if (unlikely(ctx)) {
 		request->rq_cli_ctx = sptlrpc_cli_ctx_get(ctx);
 	} else {
@@ -598,15 +603,12 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 		if (rc)
 			goto out_free;
 	}
-
 	sptlrpc_req_set_flavor(request, opcode);
 
 	rc = lustre_pack_request(request, imp->imp_msg_magic, count,
 				 lengths, bufs);
-	if (rc) {
-		LASSERT(!request->rq_pool);
+	if (rc)
 		goto out_ctx;
-	}
 
 	lustre_msg_add_version(request->rq_reqmsg, version);
 	request->rq_send_state = LUSTRE_IMP_FULL;
@@ -631,24 +633,14 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 	lustre_msg_set_opc(request->rq_reqmsg, opcode);
 
 	return 0;
+
 out_ctx:
+	LASSERT(!request->rq_pool);
 	sptlrpc_cli_ctx_put(request->rq_cli_ctx, 1);
 out_free:
 	class_import_put(imp);
 	return rc;
 }
-
-int ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
-			     __u32 version, int opcode, char **bufs,
-			     struct ptlrpc_cli_ctx *ctx)
-{
-	int count;
-
-	count = req_capsule_filled_sizes(&request->rq_pill, RCL_CLIENT);
-	return __ptlrpc_request_bufs_pack(request, version, opcode, count,
-					  request->rq_pill.rc_area[RCL_CLIENT],
-					  bufs, ctx);
-}
 EXPORT_SYMBOL(ptlrpc_request_bufs_pack);
 
 /**
-- 
2.7.4
