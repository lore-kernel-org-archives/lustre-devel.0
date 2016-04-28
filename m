From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:35 -0400
Subject: [lustre-devel] [PATCH 5/8] staging: lustre: ldlm: dont always check
	max_pages_per_rpc alignement
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

If connection is not established yet, cli->cl_chunkbits is
uninitilized so we cannot use it to check max_pages_per_rpc
alignment.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4379
Reviewed-on: http://review.whamcloud.com/8558
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 00c93f3..a80569c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -356,6 +356,12 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	cli->cl_max_pages_per_rpc = min_t(int, PTLRPC_MAX_BRW_PAGES,
 					  LNET_MTU >> PAGE_SHIFT);
 
+	/*
+	 * set cl_chunkbits default value to PAGE_CACHE_SHIFT,
+	 * it will be updated at OSC connection time.
+	 */
+	cli->cl_chunkbits = PAGE_SHIFT;
+
 	if (!strcmp(name, LUSTRE_MDC_NAME)) {
 		cli->cl_max_rpcs_in_flight = MDC_MAX_RIF_DEFAULT;
 	} else if (totalram_pages >> (20 - PAGE_SHIFT) <= 128 /* MB */) {
-- 
2.7.4
