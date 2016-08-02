From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:01:06 +0800
Subject: [lustre-devel] [PATCH 0944/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120106.12962-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, jsimmons@infradead.org, mike.rapoport@gmail.com, mike.pershin@intel.com, john.hammond@intel.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/ptlrpc/service.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 17c7b97..1cc3cd3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -44,18 +44,18 @@
 
 /* The following are visible and mutable through /sys/module/ptlrpc */
 int test_req_buffer_pressure;
-module_param(test_req_buffer_pressure, int, 0444);
+module_param(test_req_buffer_pressure, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(test_req_buffer_pressure, "set non-zero to put pressure on request buffer pools");
-module_param(at_min, int, 0644);
+module_param(at_min, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(at_min, "Adaptive timeout minimum (sec)");
-module_param(at_max, int, 0644);
+module_param(at_max, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(at_max, "Adaptive timeout maximum (sec)");
-module_param(at_history, int, 0644);
+module_param(at_history, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(at_history,
 		 "Adaptive timeouts remember the slowest event that took place within this period (sec)");
-module_param(at_early_margin, int, 0644);
+module_param(at_early_margin, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(at_early_margin, "How soon before an RPC deadline to send an early reply");
-module_param(at_extra, int, 0644);
+module_param(at_extra, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(at_extra, "How much extra time to give with each early reply");
 
 /* forward ref */
-- 
2.9.2
