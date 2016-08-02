From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:58 +0800
Subject: [lustre-devel] [PATCH 0943/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120058.12894-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, dmitry.eremin@intel.com, jinshan.xiong@intel.com, olaf@sgi.com, chuansheng.liu@intel.com, baolex.ni@intel.com, dan.carpenter@oracle.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 76a355a..6961762 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -85,7 +85,7 @@ struct ptlrpcd {
  * is used to derive a setting for ptlrpcd_per_cpt_max.
  */
 static int max_ptlrpcds;
-module_param(max_ptlrpcds, int, 0644);
+module_param(max_ptlrpcds, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_ptlrpcds, "Max ptlrpcd thread count to be started.");
 
 /*
@@ -95,7 +95,7 @@ MODULE_PARM_DESC(max_ptlrpcds, "Max ptlrpcd thread count to be started.");
  * is used to derive a setting for ptlrpcd_partner_group_size.
  */
 static int ptlrpcd_bind_policy;
-module_param(ptlrpcd_bind_policy, int, 0644);
+module_param(ptlrpcd_bind_policy, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ptlrpcd_bind_policy,
 		 "Ptlrpcd threads binding mode (obsolete).");
 
@@ -104,7 +104,7 @@ MODULE_PARM_DESC(ptlrpcd_bind_policy,
  * in a CPT.
  */
 static int ptlrpcd_per_cpt_max;
-module_param(ptlrpcd_per_cpt_max, int, 0644);
+module_param(ptlrpcd_per_cpt_max, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ptlrpcd_per_cpt_max,
 		 "Max ptlrpcd thread count to be started per cpt.");
 
@@ -115,7 +115,7 @@ MODULE_PARM_DESC(ptlrpcd_per_cpt_max,
  * a CPT partners of each other.
  */
 static int ptlrpcd_partner_group_size;
-module_param(ptlrpcd_partner_group_size, int, 0644);
+module_param(ptlrpcd_partner_group_size, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ptlrpcd_partner_group_size,
 		 "Number of ptlrpcd threads in a partner group.");
 
@@ -136,7 +136,7 @@ MODULE_PARM_DESC(ptlrpcd_partner_group_size,
  *   run ptlrpcd threads on CPTS 0, 1, 2, 3, 5, and 7.
  */
 static char *ptlrpcd_cpts;
-module_param(ptlrpcd_cpts, charp, 0644);
+module_param(ptlrpcd_cpts, charp, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ptlrpcd_cpts,
 		 "CPU partitions ptlrpcd threads should run in");
 
-- 
2.9.2
