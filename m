From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:17 -0500
Subject: [lustre-devel] [PATCH 029/622] lustre: mdc: resend quotactl if
 needed
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In mdc_quotactl, it is better to resend the quotactl request
if reconnection or failover is triggered during the process.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10368
Lustre-commit: d511918e8eb7 ("LU-10368 mdc: resend quotactl if needed")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31773
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 5718db2..feac374 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1867,7 +1867,7 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 				struct lustre_kernelcomm *lk);
 
 static int mdc_quotactl(struct obd_device *unused, struct obd_export *exp,
-			struct obd_quotactl *oqctl)
+                        struct obd_quotactl *oqctl)
 {
 	struct ptlrpc_request *req;
 	struct obd_quotactl *oqc;
@@ -1884,7 +1884,6 @@ static int mdc_quotactl(struct obd_device *unused, struct obd_export *exp,
 
 	ptlrpc_request_set_replen(req);
 	ptlrpc_at_set_req_timeout(req);
-	req->rq_no_resend = 1;
 
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
-- 
1.8.3.1
