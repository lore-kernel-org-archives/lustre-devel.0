From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:23 +0800
Subject: [lustre-devel] [PATCH 0931/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115923.12075-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, liang.zhen@intel.com, he.huang@intel.com, amir.shehata@intel.com, olaf@sgi.com, alyona.romanenko@seagate.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-ptl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 3947e8b..c5029d1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -35,7 +35,7 @@
 
 /* NB: add /proc interfaces in upcoming patches */
 int portal_rotor = LNET_PTL_ROTOR_HASH_RT;
-module_param(portal_rotor, int, 0644);
+module_param(portal_rotor, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(portal_rotor, "redirect PUTs to different cpu-partitions");
 
 static int
-- 
2.9.2
