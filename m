From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:41 -0500
Subject: [lustre-devel] [PATCH 05/40] staging: lustre: eliminate obsolete
	Cray SeaStar support
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the bulk of code for the no longer supported
SeaStar interconnect found on older Cray systems.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1422
Reviewed-on: http://review.whamcloud.com/7469
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Chuck Fossen <chuckf@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 4ea651c..fa61ec9 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -631,7 +631,6 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 		return; /* can't carry NI status info */
 
 	list_for_each_entry(rtr, &gw->lp_routes, lr_gwlist) {
-		int ptl_status = LNET_NI_STATUS_INVALID;
 		int down = 0;
 		int up = 0;
 		int i;
@@ -651,10 +650,7 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 				continue;
 
 			if (stat->ns_status == LNET_NI_STATUS_DOWN) {
-				if (LNET_NETTYP(LNET_NIDNET(nid)) != PTLLND)
-					down++;
-				else if (ptl_status != LNET_NI_STATUS_UP)
-					ptl_status = LNET_NI_STATUS_DOWN;
+				down++;
 				continue;
 			}
 
@@ -663,10 +659,6 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 					up = 1;
 					break;
 				}
-				/* ptl NIs are considered down only when
-				 * they're all down */
-				if (LNET_NETTYP(LNET_NIDNET(nid)) == PTLLND)
-					ptl_status = LNET_NI_STATUS_UP;
 				continue;
 			}
 
@@ -680,7 +672,7 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 			rtr->lr_downis = 0;
 			continue;
 		}
-		rtr->lr_downis = down + (ptl_status == LNET_NI_STATUS_DOWN);
+		rtr->lr_downis = down;
 	}
 }
 
-- 
1.7.1
