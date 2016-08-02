From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:51 +0800
Subject: [lustre-devel] [PATCH 0942/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120051.12826-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jinshan.xiong@intel.com, jsimmons@infradead.org, mike.rapoport@gmail.com, shraddha.6596@gmail.com, amitoj1606@gmail.com, lixi@ddn.com, dan.carpenter@oracle.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/osc/osc_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 47417f8..ac9e12d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -59,7 +59,7 @@ struct ptlrpc_request_pool *osc_rq_pool;
 
 /* max memory used for request pool, unit is MB */
 static unsigned int osc_reqpool_mem_max = 5;
-module_param(osc_reqpool_mem_max, uint, 0444);
+module_param(osc_reqpool_mem_max, uint, S_IRUSR | S_IRGRP | S_IROTH);
 
 struct osc_brw_async_args {
 	struct obdo       *aa_oa;
-- 
2.9.2
