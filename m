From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:56 -0400
Subject: [lustre-devel] [PATCH 097/151] lustre: mdc: interruptable during
 RPC retry for EINPROGRESS
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-98-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Sometimes, some system resource may be inaccessible temporarily,
for example, related OI mapping is crashed and has yet not been
rebuilt. Under such case, the server will reply the client with
"-EINPROGRESS", then client will retry the RPC some time later.

Currently, the client will retry infinitely until related RPC
succeed or get other failure. But we do not know how long it
will be before related resource becoming available. It may be
very long time as to the RPC sponsor - the application or the
user does not want to retry any more, then we need to make the
logic to be interruptable. This patch is for such purpose.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10237
Lustre-commit: 9c596a4996ee ("LU-10237 mdc: interruptable during RPC retry for EINPROGRESS")
Signed-off-by: Fan Yong <fan.yong@intel.com>
Reviewed-on: https://review.whamcloud.com/30166
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c | 14 ++++++++------
 fs/lustre/mdc/mdc_reint.c | 19 +++++++++++--------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index f297a98..0b358b6 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -904,13 +904,15 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	if (it->it_op && (int)lockrep->lock_policy_res2 == -EINPROGRESS) {
 		mdc_clear_replay_flag(req, rc);
 		ptlrpc_req_finished(req);
-		resends++;
-
-		CDEBUG(D_HA, "%s: resend:%d op:%d " DFID "/" DFID "\n",
-		       obddev->obd_name, resends, it->it_op,
-		       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2));
-
 		if (generation == obddev->u.cli.cl_import->imp_generation) {
+			if (signal_pending(current))
+				return -EINTR;
+
+			resends++;
+			CDEBUG(D_HA, "%s: resend:%d op:%d "DFID"/"DFID"\n",
+			       obddev->obd_name, resends, it->it_op,
+			       PFID(&op_data->op_fid1),
+			       PFID(&op_data->op_fid2));
 			goto resend;
 		} else {
 			CDEBUG(D_HA, "resend cross eviction\n");
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index d6216d6..d326962 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -231,17 +231,20 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 		level = LUSTRE_IMP_RECOVER;
 		goto resend;
 	} else if (rc == -EINPROGRESS) {
-		/* Retry create infinitely until succeed or get other
-		 * error code.
+		/*
+		 * Retry create infinitely until succeed or get other
+		 * error code or interrupted.
 		 */
 		ptlrpc_req_finished(req);
-		resends++;
-
-		CDEBUG(D_HA, "%s: resend:%d create on " DFID "/" DFID "\n",
-		       exp->exp_obd->obd_name, resends,
-		       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2));
-
 		if (generation == import->imp_generation) {
+			if (signal_pending(current))
+				return -EINTR;
+
+			resends++;
+			CDEBUG(D_HA, "%s: resend:%d create on "DFID"/"DFID"\n",
+			       exp->exp_obd->obd_name, resends,
+			       PFID(&op_data->op_fid1),
+			       PFID(&op_data->op_fid2));
 			goto rebuild;
 		} else {
 			CDEBUG(D_HA, "resend cross eviction\n");
-- 
1.8.3.1
