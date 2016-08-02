From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:15 +0800
Subject: [lustre-devel] [PATCH 0930/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115915.12007-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, liang.zhen@intel.com, amir.shehata@intel.com, hornc@cray.com, john.hammond@intel.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index c5d5bed..80d581c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -43,7 +43,7 @@
 #include "../../include/linux/lnet/lib-lnet.h"
 
 static int local_nid_dist_zero = 1;
-module_param(local_nid_dist_zero, int, 0444);
+module_param(local_nid_dist_zero, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(local_nid_dist_zero, "Reserved");
 
 int
-- 
2.9.2
