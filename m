From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:03 -0400
Subject: [lustre-devel] [PATCH 11/15] staging: lustre: mgc: fix 'error
	handling' issues
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix 'error handling' issues found by Coverity version 6.6.1:
Unchecked return value (CHECKED_RETURN)
Calling function without checking return value.
Argument cannot be negative (NEGATIVE_RETURNS)
Negative value used as argument to a function expecting a
positive value.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4055
Reviewed-on: http://review.whamcloud.com/7842
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Nunez <james.a.nunez@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 933f6f6..2311a43 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -502,8 +502,12 @@ static void do_requeue(struct config_llog_data *cld)
 	 */
 	down_read(&cld->cld_mgcexp->exp_obd->u.cli.cl_sem);
 	if (cld->cld_mgcexp->exp_obd->u.cli.cl_conn_count != 0) {
+		int rc;
+
 		CDEBUG(D_MGC, "updating log %s\n", cld->cld_logname);
-		mgc_process_log(cld->cld_mgcexp->exp_obd, cld);
+		rc = mgc_process_log(cld->cld_mgcexp->exp_obd, cld);
+		if (rc && rc != -ENOENT)
+			CERROR("failed processing log: %d\n", rc);
 	} else {
 		CDEBUG(D_MGC, "disconnecting, won't update log %s\n",
 		       cld->cld_logname);
-- 
1.7.1
