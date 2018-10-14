From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:16 -0400
Subject: [lustre-devel] [PATCH 26/28] lustre: mdc: set correct body
 eadatasize for getxattr()
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In mdc_intent_getxattr_pack() set mbo_eadatasize to the size of the
xattr values buffer rather than the size of the xattr names buffer.
Only the xattr values buffer should be upsized for older MDTs.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10912
Reviewed-on: https://review.whamcloud.com/31990
WC-bug-id: https://jira.whamcloud.com/browse/LU-11268
Reviewed-on: https://review.whamcloud.com/33024
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 5ec5d78..2cc2378 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -331,6 +331,7 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 			 struct lookup_intent *it,
 			 struct md_op_data *op_data)
 {
+	u32 ea_vals_buf_size = GA_DEFAULT_EA_VAL_LEN * GA_DEFAULT_EA_NUM;
 	struct ptlrpc_request	*req;
 	struct ldlm_intent	*lit;
 	int rc, count = 0;
@@ -353,13 +354,13 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 
 	/* pack the intended request */
 	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
-		      GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM, -1, 0);
+		      ea_vals_buf_size, -1, 0);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER,
 			     GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS, RCL_SERVER,
-			     GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM);
+			     ea_vals_buf_size);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS_LENS, RCL_SERVER,
 			     sizeof(u32) * GA_DEFAULT_EA_NUM);
-- 
1.8.3.1
