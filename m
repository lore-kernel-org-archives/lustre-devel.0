From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:14 -0400
Subject: [lustre-devel] [PATCH 04/30] lustre: ptlrpc: fix wrong error
 handlers
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

If ptlrpc_request_pack finish with 0, we need to call
ptlrpc_req_finished for later errors.

Signed-off-by: Alexander Boyko <c17825@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9286
Seagate-bug-id: MRP-4285
Reviewed-on: https://review.whamcloud.com/26319
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index f3c0722..116e973 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -904,7 +904,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 				    MDS_BULK_PORTAL,
 				    &ptlrpc_bulk_kiov_pin_ops);
 	if (!desc) {
-		ptlrpc_request_free(req);
+		ptlrpc_req_finished(req);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7c91c4b..8024b17 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -655,7 +655,7 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 		rc = l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
 						      osc_can_send_destroy(cli));
 		if (rc) {
-			ptlrpc_request_free(req);
+			ptlrpc_req_finished(req);
 			return rc;
 		}
 	}
-- 
1.8.3.1
