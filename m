From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:39:00 -0400
Subject: [lustre-devel] [PATCH 121/124] staging: lustre: lnet: Ensure
	routing is turned on first time
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-122-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>, James Simmons <jsimmons@infradead.org>

From: Doug Oucharek <doug.s.oucharek@intel.com>

In lnet_rtrpools_enable(), a mistake was made and routing
was not being turned on when the rtrpools are being allocated
for the first time.

This patch fixes that routine so we remember to turn on
routing after allocating the rtrpools.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8501
Reviewed-on: http://review.whamcloud.com/21934
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/router.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 69819c9..063ad55 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1693,7 +1693,7 @@ lnet_rtrpools_adjust(int tiny, int small, int large)
 int
 lnet_rtrpools_enable(void)
 {
-	int rc;
+	int rc = 0;
 
 	if (the_lnet.ln_routing)
 		return 0;
@@ -1706,9 +1706,9 @@ lnet_rtrpools_enable(void)
 		 * if we are just configuring this for the first
 		 * time.
 		 */
-		return lnet_rtrpools_alloc(1);
-
-	rc = lnet_rtrpools_adjust_helper(0, 0, 0);
+		rc = lnet_rtrpools_alloc(1);
+	else
+		rc = lnet_rtrpools_adjust_helper(0, 0, 0);
 	if (rc)
 		return rc;
 
@@ -1718,7 +1718,7 @@ lnet_rtrpools_enable(void)
 	the_lnet.ln_ping_info->pi_features &= ~LNET_PING_FEAT_RTE_DISABLED;
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	return 0;
+	return rc;
 }
 
 void
-- 
1.7.1
