From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:59:07 +0800
Subject: [lustre-devel] [PATCH 0929/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115907.11939-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, amir.shehata@intel.com, doug.s.oucharek@intel.com, liang.zhen@intel.com, fzago@cray.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fe0dbe7..7a35c78 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -47,19 +47,19 @@ lnet_t the_lnet;			   /* THE state of the network */
 EXPORT_SYMBOL(the_lnet);
 
 static char *ip2nets = "";
-module_param(ip2nets, charp, 0444);
+module_param(ip2nets, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ip2nets, "LNET network <- IP table");
 
 static char *networks = "";
-module_param(networks, charp, 0444);
+module_param(networks, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(networks, "local networks");
 
 static char *routes = "";
-module_param(routes, charp, 0444);
+module_param(routes, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(routes, "routes to non-local networks");
 
 static int rnet_htable_size = LNET_REMOTE_NETS_HASH_DEFAULT;
-module_param(rnet_htable_size, int, 0444);
+module_param(rnet_htable_size, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rnet_htable_size, "size of remote network hash table");
 
 static int lnet_ping(lnet_process_id_t id, int timeout_ms,
-- 
2.9.2
