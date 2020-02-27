From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:29 -0500
Subject: [lustre-devel] [PATCH 281/622] lustre: ptlrpc: Fix style issues for
 sec_null.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-282-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ptlrpc/sec_null.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 7d00fbae100b ("LU-6142 ptlrpc: Fix style issues for sec_null.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34549
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_null.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index 3c7fb68..2eaa788 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -101,6 +101,7 @@ int null_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 	if (req->rq_early) {
 		cksums = lustre_msg_get_cksum(req->rq_repdata);
 		cksumc = lustre_msg_calc_cksum(req->rq_repmsg);
+
 		if (cksumc != cksums) {
 			CDEBUG(D_SEC,
 			       "early reply checksum mismatch: %08x != %08x\n",
@@ -119,7 +120,8 @@ struct ptlrpc_sec *null_create_sec(struct obd_import *imp,
 {
 	LASSERT(SPTLRPC_FLVR_POLICY(sf->sf_rpc) == SPTLRPC_POLICY_NULL);
 
-	/* general layer has take a module reference for us, because we never
+	/*
+	 * general layer has take a module reference for us, because we never
 	 * really destroy the sec, simply release the reference here.
 	 */
 	sptlrpc_policy_put(&null_policy);
@@ -142,9 +144,8 @@ struct ptlrpc_cli_ctx *null_lookup_ctx(struct ptlrpc_sec *sec,
 }
 
 static
-int null_flush_ctx_cache(struct ptlrpc_sec *sec,
-			 uid_t uid,
-			 int grace, int force)
+int null_flush_ctx_cache(struct ptlrpc_sec *sec, uid_t uid, int grace,
+			 int force)
 {
 	return 0;
 }
@@ -250,7 +251,8 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 		if (!newbuf)
 			return -ENOMEM;
 
-		/* Must lock this, so that otherwise unprotected change of
+		/*
+		 * Must lock this, so that otherwise unprotected change of
 		 * rq_reqmsg is not racing with parallel processing of
 		 * imp_replay_list traversing threads. See LU-3333
 		 * This is a bandaid at best, we really need to deal with this
@@ -454,6 +456,6 @@ void sptlrpc_null_fini(void)
 
 	rc = sptlrpc_unregister_policy(&null_policy);
 	if (rc)
-		CERROR("failed to unregister %s: %d\n",
-		       null_policy.sp_name, rc);
+		CERROR("failed to unregister %s: %d\n", null_policy.sp_name,
+		       rc);
 }
-- 
1.8.3.1
