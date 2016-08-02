From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:38 +0800
Subject: [lustre-devel] [PATCH 0933/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115938.12211-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, doug.s.oucharek@intel.com, amir.shehata@intel.com, john.hammond@intel.com, dmitry.eremin@intel.com, arnd@arndb.de, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/lnet/router.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index b01dc42..bdb40e7 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -31,24 +31,24 @@
 				 PAGE_SHIFT)
 
 static char *forwarding = "";
-module_param(forwarding, charp, 0444);
+module_param(forwarding, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(forwarding, "Explicitly enable/disable forwarding between networks");
 
 static int tiny_router_buffers;
-module_param(tiny_router_buffers, int, 0444);
+module_param(tiny_router_buffers, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(tiny_router_buffers, "# of 0 payload messages to buffer in the router");
 static int small_router_buffers;
-module_param(small_router_buffers, int, 0444);
+module_param(small_router_buffers, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(small_router_buffers, "# of small (1 page) messages to buffer in the router");
 static int large_router_buffers;
-module_param(large_router_buffers, int, 0444);
+module_param(large_router_buffers, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(large_router_buffers, "# of large messages to buffer in the router");
 static int peer_buffer_credits;
-module_param(peer_buffer_credits, int, 0444);
+module_param(peer_buffer_credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_buffer_credits, "# router buffer credits per peer");
 
 static int auto_down = 1;
-module_param(auto_down, int, 0444);
+module_param(auto_down, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(auto_down, "Automatically mark peers down on comms error");
 
 int
@@ -71,23 +71,23 @@ lnet_peer_buffer_credits(lnet_ni_t *ni)
 static int lnet_router_checker(void *);
 
 static int check_routers_before_use;
-module_param(check_routers_before_use, int, 0444);
+module_param(check_routers_before_use, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(check_routers_before_use, "Assume routers are down and ping them before use");
 
 int avoid_asym_router_failure = 1;
-module_param(avoid_asym_router_failure, int, 0644);
+module_param(avoid_asym_router_failure, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(avoid_asym_router_failure, "Avoid asymmetrical router failures (0 to disable)");
 
 static int dead_router_check_interval = 60;
-module_param(dead_router_check_interval, int, 0644);
+module_param(dead_router_check_interval, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dead_router_check_interval, "Seconds between dead router health checks (<= 0 to disable)");
 
 static int live_router_check_interval = 60;
-module_param(live_router_check_interval, int, 0644);
+module_param(live_router_check_interval, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(live_router_check_interval, "Seconds between live router health checks (<= 0 to disable)");
 
 static int router_ping_timeout = 50;
-module_param(router_ping_timeout, int, 0644);
+module_param(router_ping_timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(router_ping_timeout, "Seconds to wait for the reply to a router health query");
 
 int
-- 
2.9.2
