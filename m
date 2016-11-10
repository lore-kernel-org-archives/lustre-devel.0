From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:39 -0500
Subject: [lustre-devel] [PATCH 09/35] staging: lustre: mgc: IR log failure
	should not stop mount
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If clients or other targets can not get IR config lock
or lock, the mount should continue, instead of failing.
Because timeout mechanism will handle the recovery anyway.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6906
Reviewed-on: http://review.whamcloud.com/15728
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2d6fdd0..e248f33 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1675,8 +1675,15 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 
 	if (cld_is_recover(cld)) {
 		rc = 0; /* this is not a fatal error for recover log */
-		if (rcl == 0)
+		if (!rcl) {
 			rc = mgc_process_recover_log(mgc, cld);
+			if (rc) {
+				CERROR("%s: recover log %s failed: rc = %d not fatal.\n",
+				       mgc->obd_name, cld->cld_logname, rc);
+				rc = 0;
+				cld->cld_lostlock = 1;
+			}
+		}
 	} else {
 		rc = mgc_process_cfg_log(mgc, cld, rcl != 0);
 	}
-- 
1.7.1
