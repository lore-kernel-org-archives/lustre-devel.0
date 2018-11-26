From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:27 -0500
Subject: [lustre-devel] [PATCH 11/12] lustre: mdc: use large xattr buffers
 for old servers
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Pre 2.10.1 MDTs will crash when they receive a listxattr (MDS_GETXATTR
with OBD_MD_FLXATTRLS) RPC for an orphan or dead object. So for
clients connected to these older MDTs, try to avoid sending listxattr
RPCs by making the bulk getxattr (MDS_GETXATTR with OBD_MD_FLXATTRALL)
more likely to succeed and thereby reducing the chances of falling
ack to listxattr.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10912
Reviewed-on: https://review.whamcloud.com/31990
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 2cc2378..7d4ba9c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -352,6 +352,20 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
 	lit->opc = IT_GETXATTR;
 
+	/* If the supplied buffer is too small then the server will
+	 * return -ERANGE and llite will fallback to using non cached
+	 * xattr operations. On servers before 2.10.1 a (non-cached)
+	 * listxattr RPC for an orphan or dead file causes an oops. So
+	 * let's try to avoid sending too small a buffer to too old a
+	 * server. This is effectively undoing the memory conservation
+	 * of LU-9417 when it would be *more* likely to crash the
+	 * server. See LU-9856.
+	 */
+	BUILD_BUG_ON(OBD_OCD_VERSION(3, 0, 53, 0) <= LUSTRE_VERSION_CODE);
+	if (exp->exp_connect_data.ocd_version < OBD_OCD_VERSION(2, 10, 1, 0))
+		ea_vals_buf_size = max_t(u32, ea_vals_buf_size,
+					 exp->exp_connect_data.ocd_max_easize);
+
 	/* pack the intended request */
 	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
 		      ea_vals_buf_size, -1, 0);
-- 
1.8.3.1
