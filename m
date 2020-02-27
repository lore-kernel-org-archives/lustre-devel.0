From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:21 -0500
Subject: [lustre-devel] [PATCH 213/622] lustre: mdc: don't use ACL at setattr
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-214-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

For ldiskfs with large_ea, EA max size is equal to 1MB.
At mdc_setattr ptlrpc reply size is 1.1MB and it is rounded
to 2MB. So REINT_SETATTR request takes about 2MB of memory at
client. For a MDS failover case many request stay at reply queue
and could lead to OOM.

The patch changes acl size to zero, cause server doesn't fill
acl for setattr request.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11934
Lustre-commit: e7f6f870c356 ("LU-11934 mdc: don't use ACL at setattr")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-6938
Reviewed-on: https://review.whamcloud.com/34194
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_reint.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 2611fc4..0e5f012 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -134,10 +134,8 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		       op_data->op_attr.ia_ctime.tv_sec);
 	mdc_setattr_pack(req, op_data, ea, ealen);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     min_t(u32,
-				   req->rq_import->imp_connect_data.ocd_max_easize,
-				   XATTR_SIZE_MAX));
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
+
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_reint(req, LUSTRE_IMP_FULL);
-- 
1.8.3.1
