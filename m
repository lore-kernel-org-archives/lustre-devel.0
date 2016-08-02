From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 20:00:26 +0800
Subject: [lustre-devel] [PATCH 0939/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802120026.12621-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, fzago@cray.com, john.hammond@intel.com, jsimmons@infradead.org, mike.rapoport@gmail.com, axboe@fb.com, kirill.shutemov@linux.intel.com, viro@zeniv.linux.org.uk, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lustre/llite/lloop.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 813a9a3..5f751e4 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -872,7 +872,7 @@ static void lloop_exit(void)
 	kfree(loop_dev);
 }
 
-module_param(max_loop, int, 0444);
+module_param(max_loop, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_loop, "maximum of lloop_device");
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
 MODULE_DESCRIPTION("Lustre virtual block device");
-- 
2.9.2
