From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:46 +0800
Subject: [lustre-devel] [PATCH 0934/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115946.12279-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, kirill.shutemov@linux.intel.com, chuansheng.liu@intel.com, baolex.ni@intel.com, dmitry.eremin@intel.com, arnd@arndb.de

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index a63d86c..99cb974 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -41,11 +41,11 @@
 #include "selftest.h"
 
 static int brw_srv_workitems = SFW_TEST_WI_MAX;
-module_param(brw_srv_workitems, int, 0644);
+module_param(brw_srv_workitems, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(brw_srv_workitems, "# BRW server workitems");
 
 static int brw_inject_errors;
-module_param(brw_inject_errors, int, 0644);
+module_param(brw_inject_errors, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(brw_inject_errors, "# data errors to inject randomly, zero by default");
 
 static void
-- 
2.9.2
