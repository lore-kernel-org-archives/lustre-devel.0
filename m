From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:19 +0800
Subject: [lustre-devel] [PATCH 0938/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120019.12553-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jinshan.xiong@intel.com, jsimmons@infradead.org, bruce.korb@gmail.com, vitaly.fertman@seagate.com, arnd@arndb.de, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 107314e..4812c1f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -68,7 +68,7 @@
 #include "ldlm_internal.h"
 
 int ldlm_enqueue_min = OBD_TIMEOUT_DEFAULT;
-module_param(ldlm_enqueue_min, int, 0644);
+module_param(ldlm_enqueue_min, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ldlm_enqueue_min, "lock enqueue timeout minimum");
 
 /* in client side, whether the cached locks will be canceled before replay */
-- 
2.9.2
