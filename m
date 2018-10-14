From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:59 -0400
Subject: [lustre-devel] [PATCH 09/28] lustre: mdc: improve mdc_enqueue()
 error message
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Include the parent/child FIDs and name in the mdc_enqueue()
debug message.

Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4705
Reviewed-on: https://review.whamcloud.com/28978
Reviewed-by: Steve Guminski <stephenx.guminski@intel.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index cfe917c..5ec5d78 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -824,8 +824,10 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	mdc_put_mod_rpc_slot(req, it);
 
 	if (rc < 0) {
-		CDEBUG(D_INFO, "%s: ldlm_cli_enqueue failed: rc = %d\n",
-		       obddev->obd_name, rc);
+		CDEBUG(D_INFO,
+		       "%s: ldlm_cli_enqueue " DFID ":" DFID "=%s failed: rc = %d\n",
+		       obddev->obd_name, PFID(&op_data->op_fid1),
+		       PFID(&op_data->op_fid2), op_data->op_name ?: "", rc);
 
 		mdc_clear_replay_flag(req, rc);
 		ptlrpc_req_finished(req);
-- 
1.8.3.1
