From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:19 -0400
Subject: [lustre-devel] [PATCH 020/124] staging: lustre: lmv: release
	request in lmv_revalidate_slaves()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In lmv_revalidate_slaves() ensure that the request returned by
md_intent_lock() is properly released on all paths.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5452
Reviewed-on: http://review.whamcloud.com/11326
Reviewed-by: wang di <di.wang@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index fd3dc7c..f24848f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -155,6 +155,7 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
+	struct ptlrpc_request *req = NULL;
 	struct mdt_body *body;
 	struct md_op_data *op_data;
 	unsigned long size = 0;
@@ -178,7 +179,6 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 	 */
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		struct lookup_intent it = { .it_op = IT_GETATTR };
-		struct ptlrpc_request *req = NULL;
 		struct lustre_handle *lockh = NULL;
 		struct lmv_tgt_desc *tgt = NULL;
 		struct inode *inode;
@@ -205,6 +205,11 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 		CDEBUG(D_INODE, "Revalidate slave "DFID" -> mds #%d\n",
 		       PFID(&fid), tgt->ltd_idx);
 
+		if (req) {
+			ptlrpc_req_finished(req);
+			req = NULL;
+		}
+
 		rc = md_intent_lock(tgt->ltd_exp, op_data, &it, &req,
 				    cb_blocking, extra_lock_flags);
 		if (rc < 0)
@@ -228,9 +233,6 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 				       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
 				       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
 
-				if (req)
-					ptlrpc_req_finished(req);
-
 				if (it.it_lock_mode && lockh) {
 					ldlm_lock_decref(lockh, it.it_lock_mode);
 					it.it_lock_mode = 0;
@@ -245,9 +247,6 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 			LTIME_S(inode->i_atime) = body->mbo_atime;
 			LTIME_S(inode->i_ctime) = body->mbo_ctime;
 			LTIME_S(inode->i_mtime) = body->mbo_mtime;
-
-			if (req)
-				ptlrpc_req_finished(req);
 		}
 
 		md_set_lock_data(tgt->ltd_exp, lockh, inode, NULL);
@@ -288,6 +287,9 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 		mbody->mbo_mtime = mtime;
 	}
 cleanup:
+	if (req)
+		ptlrpc_req_finished(req);
+
 	kfree(op_data);
 	return rc;
 }
-- 
1.7.1
