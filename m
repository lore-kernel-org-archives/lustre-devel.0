From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:58:21 +0800
Subject: [lustre-devel] [PATCH 0923/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115821.11528-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, amir.shehata@intel.com, olaf@sgi.com, mike.rapoport@gmail.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  | 46 +++++++++++-----------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index f8fdd4a..044d468 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -41,15 +41,15 @@
 #include "o2iblnd.h"
 
 static int service = 987;
-module_param(service, int, 0444);
+module_param(service, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(service, "service number (within RDMA_PS_TCP)");
 
 static int cksum;
-module_param(cksum, int, 0644);
+module_param(cksum, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cksum, "set non-zero to enable message (not RDMA) checksums");
 
 static int timeout = 50;
-module_param(timeout, int, 0644);
+module_param(timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(timeout, "timeout (seconds)");
 
 /*
@@ -57,75 +57,75 @@ MODULE_PARM_DESC(timeout, "timeout (seconds)");
  * we will estimate reasonable value based on CPUs if it's set to zero.
  */
 static int nscheds;
-module_param(nscheds, int, 0444);
+module_param(nscheds, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nscheds, "number of threads in each scheduler pool");
 
 /* NB: this value is shared by all CPTs, it can grow at runtime */
 static int ntx = 512;
-module_param(ntx, int, 0444);
+module_param(ntx, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ntx, "# of message descriptors allocated for each pool");
 
 /* NB: this value is shared by all CPTs */
 static int credits = 256;
-module_param(credits, int, 0444);
+module_param(credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(credits, "# concurrent sends");
 
 static int peer_credits = 8;
-module_param(peer_credits, int, 0444);
+module_param(peer_credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_credits, "# concurrent sends to 1 peer");
 
 static int peer_credits_hiw;
-module_param(peer_credits_hiw, int, 0444);
+module_param(peer_credits_hiw, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_credits_hiw, "when eagerly to return credits");
 
 static int peer_buffer_credits;
-module_param(peer_buffer_credits, int, 0444);
+module_param(peer_buffer_credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_buffer_credits, "# per-peer router buffer credits");
 
 static int peer_timeout = 180;
-module_param(peer_timeout, int, 0444);
+module_param(peer_timeout, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer dead (<=0 to disable)");
 
 static char *ipif_name = "ib0";
-module_param(ipif_name, charp, 0444);
+module_param(ipif_name, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ipif_name, "IPoIB interface name");
 
 static int retry_count = 5;
-module_param(retry_count, int, 0644);
+module_param(retry_count, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(retry_count, "Retransmissions when no ACK received");
 
 static int rnr_retry_count = 6;
-module_param(rnr_retry_count, int, 0644);
+module_param(rnr_retry_count, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rnr_retry_count, "RNR retransmissions");
 
 static int keepalive = 100;
-module_param(keepalive, int, 0644);
+module_param(keepalive, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(keepalive, "Idle time in seconds before sending a keepalive");
 
 static int ib_mtu;
-module_param(ib_mtu, int, 0444);
+module_param(ib_mtu, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ib_mtu, "IB MTU 256/512/1024/2048/4096");
 
 static int concurrent_sends;
-module_param(concurrent_sends, int, 0444);
+module_param(concurrent_sends, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing");
 
 static int map_on_demand;
-module_param(map_on_demand, int, 0444);
+module_param(map_on_demand, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(map_on_demand, "map on demand");
 
 /* NB: this value is shared by all CPTs, it can grow@runtime */
 static int fmr_pool_size = 512;
-module_param(fmr_pool_size, int, 0444);
+module_param(fmr_pool_size, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fmr_pool_size, "size of fmr pool on each CPT (>= ntx / 4)");
 
 /* NB: this value is shared by all CPTs, it can grow at runtime */
 static int fmr_flush_trigger = 384;
-module_param(fmr_flush_trigger, int, 0444);
+module_param(fmr_flush_trigger, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fmr_flush_trigger, "# dirty FMRs that triggers pool flush");
 
 static int fmr_cache = 1;
-module_param(fmr_cache, int, 0444);
+module_param(fmr_cache, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fmr_cache, "non-zero to enable FMR caching");
 
 /*
@@ -134,15 +134,15 @@ MODULE_PARM_DESC(fmr_cache, "non-zero to enable FMR caching");
  * 2: force to failover (for debug)
  */
 static int dev_failover;
-module_param(dev_failover, int, 0444);
+module_param(dev_failover, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dev_failover, "HCA failover for bonding (0 off, 1 on, other values reserved)");
 
 static int require_privileged_port;
-module_param(require_privileged_port, int, 0644);
+module_param(require_privileged_port, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(require_privileged_port, "require privileged port when accepting connection");
 
 static int use_privileged_port = 1;
-module_param(use_privileged_port, int, 0644);
+module_param(use_privileged_port, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_privileged_port, "use privileged port when initiating connection");
 
 kib_tunables_t kiblnd_tunables = {
-- 
2.9.2
