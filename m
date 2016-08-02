From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:42 +0800
Subject: [lustre-devel] [PATCH 0941/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120042.12757-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, shraddha.6596@gmail.com, mike.rapoport@gmail.com, fzago@cray.com, amk@cray.com, chuansheng.liu@intel.com, baolex.ni@intel.com, emoly.liu@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index e043857..3d9bc20 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -818,7 +818,7 @@ enum {
 };
 
 static unsigned int lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
-module_param(lu_cache_percent, int, 0644);
+module_param(lu_cache_percent, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(lu_cache_percent, "Percentage of memory to be used as lu_object cache");
 
 /**
-- 
2.9.2
