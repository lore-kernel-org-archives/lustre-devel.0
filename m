From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:47 -0400
Subject: [lustre-devel] [PATCH 34/80] staging: lustre: lmv: rename request
	to preq in lmv_getattr_name()
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Rename request to preq.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4826
Reviewed-on: http://review.whamcloud.com/9863
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index f1b8ae9..d07fd17 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1883,7 +1883,7 @@ lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 
 static int
 lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
-		 struct ptlrpc_request **request)
+		 struct ptlrpc_request **preq)
 {
 	struct ptlrpc_request   *req = NULL;
 	struct obd_device       *obd = exp->exp_obd;
@@ -1904,13 +1904,11 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
 	       tgt->ltd_idx);
 
-	rc = md_getattr_name(tgt->ltd_exp, op_data, request);
+	rc = md_getattr_name(tgt->ltd_exp, op_data, preq);
 	if (rc != 0)
 		return rc;
 
-	body = req_capsule_server_get(&(*request)->rq_pill,
-				      &RMF_MDT_BODY);
-
+	body = req_capsule_server_get(&(*preq)->rq_pill, &RMF_MDT_BODY);
 	if (body->valid & OBD_MD_MDS) {
 		struct lu_fid rid = body->fid1;
 
@@ -1919,8 +1917,8 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 
 		tgt = lmv_find_target(lmv, &rid);
 		if (IS_ERR(tgt)) {
-			ptlrpc_req_finished(*request);
-			*request = NULL;
+			ptlrpc_req_finished(*preq);
+			*preq = NULL;
 			return PTR_ERR(tgt);
 		}
 
@@ -1929,8 +1927,8 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_namelen = 0;
 		op_data->op_name = NULL;
 		rc = md_getattr_name(tgt->ltd_exp, op_data, &req);
-		ptlrpc_req_finished(*request);
-		*request = req;
+		ptlrpc_req_finished(*preq);
+		*preq = req;
 	}
 
 	return rc;
-- 
1.7.1
