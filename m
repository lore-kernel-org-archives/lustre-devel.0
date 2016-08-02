From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:30 +0800
Subject: [lustre-devel] [PATCH 0932/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115930.12143-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, john.hammond@intel.com, amir.shehata@intel.com, chuansheng.liu@intel.com, baolex.ni@intel.com, alyona.romanenko@seagate.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/lnet/module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 246b5c1..8ed58fc 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -39,7 +39,7 @@
 #include "../../include/linux/lnet/lib-dlc.h"
 
 static int config_on_load;
-module_param(config_on_load, int, 0444);
+module_param(config_on_load, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(config_on_load, "configure network at module load");
 
 static struct mutex lnet_config_mutex;
-- 
2.9.2
