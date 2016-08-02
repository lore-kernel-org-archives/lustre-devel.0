From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:58:45 +0800
Subject: [lustre-devel] [PATCH 0926/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115845.11735-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, amitoj1606@gmail.com, shraddha.6596@gmail.com, chuansheng.liu@intel.com, baolex.ni@intel.com, jinshan.xiong@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/hash.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index cc45ed8..f4454d0 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -113,7 +113,7 @@
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
-module_param(warn_on_depth, uint, 0644);
+module_param(warn_on_depth, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(warn_on_depth, "warning when hash depth is high.");
 #endif
 
-- 
2.9.2
