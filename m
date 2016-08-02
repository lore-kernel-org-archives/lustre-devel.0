From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:00 +0800
Subject: [lustre-devel] [PATCH 0928/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115900.11871-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, amir.shehata@intel.com, john.hammond@intel.com, bruno.faccini@intel.com, mike.rapoport@gmail.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/lnet/acceptor.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 1452bb3..a7c3a58 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -67,13 +67,13 @@ lnet_accept_magic(__u32 magic, __u32 constant)
 
 static char *accept = "secure";
 
-module_param(accept, charp, 0444);
+module_param(accept, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(accept, "Accept connections (secure|all|none)");
-module_param(accept_port, int, 0444);
+module_param(accept_port, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(accept_port, "Acceptor's port (same on all nodes)");
-module_param(accept_backlog, int, 0444);
+module_param(accept_backlog, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(accept_backlog, "Acceptor's listen backlog");
-module_param(accept_timeout, int, 0644);
+module_param(accept_timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(accept_timeout, "Acceptor's timeout (seconds)");
 
 static char *accept_type;
-- 
2.9.2
