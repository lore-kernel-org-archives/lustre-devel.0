From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:58:52 +0800
Subject: [lustre-devel] [PATCH 0927/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115852.11803-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, shivanib134@gmail.com, Andriy_Skulysh@xyratex.com, janani.rvchndrn@gmail.com, mike.rapoport@gmail.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index b52518c5..ba42aae 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -43,7 +43,7 @@
  * >1 : specify number of partitions
  */
 static int	cpu_npartitions;
-module_param(cpu_npartitions, int, 0444);
+module_param(cpu_npartitions, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cpu_npartitions, "# of CPU partitions");
 
 /**
@@ -58,7 +58,7 @@ MODULE_PARM_DESC(cpu_npartitions, "# of CPU partitions");
  * NB: If user specified cpu_pattern, cpu_npartitions will be ignored
  */
 static char	*cpu_pattern = "";
-module_param(cpu_pattern, charp, 0444);
+module_param(cpu_pattern, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
 
 struct cfs_cpt_data {
-- 
2.9.2
