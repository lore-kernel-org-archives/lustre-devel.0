From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:34 +0800
Subject: [lustre-devel] [PATCH 0940/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120034.12689-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, john.hammond@intel.com, arnd@arndb.de, dmitry.eremin@intel.com, mike.rapoport@gmail.com, shraddha.6596@gmail.com, ksenija.stanojevic@gmail.com, emoly.liu@intel.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 5a1eae1..8ede6c8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -271,7 +271,7 @@ int lprocfs_write_frac_helper(const char __user *buffer, unsigned long count,
 EXPORT_SYMBOL(lprocfs_write_frac_helper);
 
 static int lprocfs_no_percpu_stats;
-module_param(lprocfs_no_percpu_stats, int, 0644);
+module_param(lprocfs_no_percpu_stats, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(lprocfs_no_percpu_stats, "Do not alloc percpu data for lprocfs stats");
 
 #define MAX_STRING_SIZE 128
-- 
2.9.2
