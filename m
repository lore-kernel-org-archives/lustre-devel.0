From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:11 +0800
Subject: [lustre-devel] [PATCH 0937/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120011.12483-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, Keith.Mannthey@intel.com, mike.rapoport@gmail.com, bruce.korb@gmail.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ab739f0..8d95385 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -48,11 +48,11 @@
 #include "ldlm_internal.h"
 
 static int ldlm_num_threads;
-module_param(ldlm_num_threads, int, 0444);
+module_param(ldlm_num_threads, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ldlm_num_threads, "number of DLM service threads to start");
 
 static char *ldlm_cpts;
-module_param(ldlm_cpts, charp, 0444);
+module_param(ldlm_cpts, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ldlm_cpts, "CPU partitions ldlm threads should run on");
 
 static struct mutex	ldlm_ref_mutex;
-- 
2.9.2
