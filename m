From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:48 -0500
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: eliminate obsolete
	Cray SeaStar support
In-Reply-To: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
References: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455549954-29532-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

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
 drivers/staging/lustre/lnet/lnet/router.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 735a8f2..9c32a01 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -635,7 +635,6 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 		return; /* can't carry NI status info */
 
 	list_for_each_entry(rtr, &gw->lp_routes, lr_gwlist) {
-		int ptl_status = LNET_NI_STATUS_INVALID;
 		int down = 0;
 		int up = 0;
 		int i;
@@ -655,10 +654,7 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 				continue;
 
 			if (stat->ns_status == LNET_NI_STATUS_DOWN) {
-				if (LNET_NETTYP(LNET_NIDNET(nid)) != PTLLND)
-					down++;
-				else if (ptl_status != LNET_NI_STATUS_UP)
-					ptl_status = LNET_NI_STATUS_DOWN;
+				down++;
 				continue;
 			}
 
@@ -667,12 +663,6 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 					up = 1;
 					break;
 				}
-				/*
-				 * ptl NIs are considered down only when
-				 * they're all down
-				 */
-				if (LNET_NETTYP(LNET_NIDNET(nid)) == PTLLND)
-					ptl_status = LNET_NI_STATUS_UP;
 				continue;
 			}
 
@@ -686,7 +676,7 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 			rtr->lr_downis = 0;
 			continue;
 		}
-		rtr->lr_downis = down + (ptl_status == LNET_NI_STATUS_DOWN);
+		rtr->lr_downis = down;
 	}
 }
 
-- 
1.7.1
