From: Baole Ni <baolex.ni@intel.com>
Date: Tue,  2 Aug 2016 19:58:29 +0800
Subject: [lustre-devel] [PATCH 0924/1285] Replace numeric parameter like
	0444 with macro
Message-ID: <20160802115829.11598-1-baolex.ni@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jejb@linux.vnet.ibm.com, martin.petersen@oracle.com, m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, jsimmons@infradead.org, mike.rapoport@gmail.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  | 56 +++++++++++-----------
 1 file changed, 28 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
index 6329cbe..4136f60 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
@@ -19,23 +19,23 @@
 #include "socklnd.h"
 
 static int sock_timeout = 50;
-module_param(sock_timeout, int, 0644);
+module_param(sock_timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(sock_timeout, "dead socket timeout (seconds)");
 
 static int credits = 256;
-module_param(credits, int, 0444);
+module_param(credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(credits, "# concurrent sends");
 
 static int peer_credits = 8;
-module_param(peer_credits, int, 0444);
+module_param(peer_credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_credits, "# concurrent sends to 1 peer");
 
 static int peer_buffer_credits;
-module_param(peer_buffer_credits, int, 0444);
+module_param(peer_buffer_credits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_buffer_credits, "# per-peer router buffer credits");
 
 static int peer_timeout = 180;
-module_param(peer_timeout, int, 0444);
+module_param(peer_timeout, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer dead (<=0 to disable)");
 
 /*
@@ -43,99 +43,99 @@ MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer d
  * we will estimate reasonable value based on CPUs if it's not set.
  */
 static unsigned int nscheds;
-module_param(nscheds, int, 0444);
+module_param(nscheds, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nscheds, "# scheduler daemons in each pool while starting");
 
 static int nconnds = 4;
-module_param(nconnds, int, 0444);
+module_param(nconnds, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nconnds, "# connection daemons while starting");
 
 static int nconnds_max = 64;
-module_param(nconnds_max, int, 0444);
+module_param(nconnds_max, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nconnds_max, "max # connection daemons");
 
 static int min_reconnectms = 1000;
-module_param(min_reconnectms, int, 0644);
+module_param(min_reconnectms, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(min_reconnectms, "min connection retry interval (mS)");
 
 static int max_reconnectms = 60000;
-module_param(max_reconnectms, int, 0644);
+module_param(max_reconnectms, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_reconnectms, "max connection retry interval (mS)");
 
 # define DEFAULT_EAGER_ACK 0
 static int eager_ack = DEFAULT_EAGER_ACK;
-module_param(eager_ack, int, 0644);
+module_param(eager_ack, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(eager_ack, "send tcp ack packets eagerly");
 
 static int typed_conns = 1;
-module_param(typed_conns, int, 0444);
+module_param(typed_conns, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(typed_conns, "use different sockets for bulk");
 
 static int min_bulk = 1 << 10;
-module_param(min_bulk, int, 0644);
+module_param(min_bulk, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(min_bulk, "smallest 'large' message");
 
 # define DEFAULT_BUFFER_SIZE 0
 static int tx_buffer_size = DEFAULT_BUFFER_SIZE;
-module_param(tx_buffer_size, int, 0644);
+module_param(tx_buffer_size, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(tx_buffer_size, "socket tx buffer size (0 for system default)");
 
 static int rx_buffer_size = DEFAULT_BUFFER_SIZE;
-module_param(rx_buffer_size, int, 0644);
+module_param(rx_buffer_size, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rx_buffer_size, "socket rx buffer size (0 for system default)");
 
 static int nagle;
-module_param(nagle, int, 0644);
+module_param(nagle, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nagle, "enable NAGLE?");
 
 static int round_robin = 1;
-module_param(round_robin, int, 0644);
+module_param(round_robin, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(round_robin, "Round robin for multiple interfaces");
 
 static int keepalive = 30;
-module_param(keepalive, int, 0644);
+module_param(keepalive, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(keepalive, "# seconds before send keepalive");
 
 static int keepalive_idle = 30;
-module_param(keepalive_idle, int, 0644);
+module_param(keepalive_idle, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(keepalive_idle, "# idle seconds before probe");
 
 #define DEFAULT_KEEPALIVE_COUNT  5
 static int keepalive_count = DEFAULT_KEEPALIVE_COUNT;
-module_param(keepalive_count, int, 0644);
+module_param(keepalive_count, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(keepalive_count, "# missed probes == dead");
 
 static int keepalive_intvl = 5;
-module_param(keepalive_intvl, int, 0644);
+module_param(keepalive_intvl, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(keepalive_intvl, "seconds between probes");
 
 static int enable_csum;
-module_param(enable_csum, int, 0644);
+module_param(enable_csum, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(enable_csum, "enable check sum");
 
 static int inject_csum_error;
-module_param(inject_csum_error, int, 0644);
+module_param(inject_csum_error, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(inject_csum_error, "set non-zero to inject a checksum error");
 
 static int nonblk_zcack = 1;
-module_param(nonblk_zcack, int, 0644);
+module_param(nonblk_zcack, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nonblk_zcack, "always send ZC-ACK on non-blocking connection");
 
 static unsigned int zc_min_payload = 16 << 10;
-module_param(zc_min_payload, int, 0644);
+module_param(zc_min_payload, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(zc_min_payload, "minimum payload size to zero copy");
 
 static unsigned int zc_recv;
-module_param(zc_recv, int, 0644);
+module_param(zc_recv, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(zc_recv, "enable ZC recv for Chelsio driver");
 
 static unsigned int zc_recv_min_nfrags = 16;
-module_param(zc_recv_min_nfrags, int, 0644);
+module_param(zc_recv_min_nfrags, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(zc_recv_min_nfrags, "minimum # of fragments to enable ZC recv");
 
 #if SOCKNAL_VERSION_DEBUG
 static int protocol = 3;
-module_param(protocol, int, 0644);
+module_param(protocol, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(protocol, "protocol version");
 #endif
 
-- 
2.9.2
