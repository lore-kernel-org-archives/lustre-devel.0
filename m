From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:19 -0500
Subject: [lustre-devel] [PATCH 51/60] staging: lustre: ptlrpc: update
	MODULE_PARAM_DESC in ptlrpcd.c
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-52-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Update max_ptlrpcds module parameter descriptions to let
users know its obsolete. Change cpt to CPT for the module
parameter description ptlrpcd_per_cpt_max so it matches
documentation.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8890
Reviewed-on: https://review.whamcloud.com/24065
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 84c5551..59b5813 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -82,7 +82,8 @@ struct ptlrpcd {
  */
 static int max_ptlrpcds;
 module_param(max_ptlrpcds, int, 0644);
-MODULE_PARM_DESC(max_ptlrpcds, "Max ptlrpcd thread count to be started.");
+MODULE_PARM_DESC(max_ptlrpcds,
+		 "Max ptlrpcd thread count to be started (obsolete).");
 
 /*
  * ptlrpcd_bind_policy is obsolete, but retained to ensure that
@@ -102,7 +103,7 @@ struct ptlrpcd {
 static int ptlrpcd_per_cpt_max;
 module_param(ptlrpcd_per_cpt_max, int, 0644);
 MODULE_PARM_DESC(ptlrpcd_per_cpt_max,
-		 "Max ptlrpcd thread count to be started per cpt.");
+		 "Max ptlrpcd thread count to be started per CPT.");
 
 /*
  * ptlrpcd_partner_group_size: The desired number of threads in each
-- 
1.8.3.1
