From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:16 -0500
Subject: [lustre-devel] [PATCH 40/40] staging: lustre: Remove LASSERTS from
	router checker
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <doug.s.oucharek@intel.com>

In lnet_router_checker(), there are two LASSERTS.  Neither protects
us from anything and one of them triggered for a customer crashing
the system unecessarily.  This patch removes them.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7362
Reviewed-on: http://review.whamcloud.com/17003
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Matt Ezell <ezellma@ornl.gov>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 83d233b..476b4dd 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1223,8 +1223,6 @@ lnet_router_checker(void *arg)
 
 	cfs_block_allsigs();
 
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
-
 	while (the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING) {
 		__u64 version;
 		int cpt;
@@ -1280,8 +1278,6 @@ rescan:
 							 cfs_time_seconds(1));
 	}
 
-	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_STOPPING);
-
 	lnet_prune_rc_data(1); /* wait for UNLINK */
 
 	the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
-- 
1.7.1
