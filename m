From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 10/30] staging: lustre: discard CFS_TICK
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731273.24196.11745089673157992836.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This undocumented macro seems to represent "a small amount of time".
Sometimes it is used as-is, some times it is multiplied by 5 for no
obvious reason.
It does not appear that there is any connection between the different
places it is used - they all just want a short period for different
purposes and of different durarions.

So discard CFS_TICK and lets each use-site just use whatever number
of jiffies seems appropriate in that case.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    5 -----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    2 +-
 5 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 084150e9d9ac..57d66aff546b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -89,11 +89,6 @@
 
 #define LIBCFS_VERSION "0.7.0"
 
-/*
- * One jiffy
- */
-#define CFS_TICK		(1UL)
-
 /*
  * Lustre Error Checksum: calculates checksum
  * of Hex number by XORing each bit.
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 570f54ed57b1..a0784167e989 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -58,7 +58,7 @@
 #define SOCKNAL_PEER_HASH_SIZE  101   /* # peer lists */
 #define SOCKNAL_RESCHED         100   /* # scheduler loops before reschedule */
 #define SOCKNAL_INSANITY_RECONN 5000  /* connd is trying on reconn infinitely */
-#define SOCKNAL_ENOMEM_RETRY    CFS_TICK /* jiffies between retries */
+#define SOCKNAL_ENOMEM_RETRY    1     /* jiffies between retries */
 
 #define SOCKNAL_SINGLE_FRAG_TX  0     /* disable multi-fragment sends */
 #define SOCKNAL_SINGLE_FRAG_RX  0     /* disable multi-fragment receives */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0155294184f1..0f355c415474 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -748,7 +748,7 @@ static int osc_should_shrink_grant(struct client_obd *client)
 	     OBD_CONNECT_GRANT_SHRINK) == 0)
 		return 0;
 
-	if (time_after_eq(time, next_shrink - 5 * CFS_TICK)) {
+	if (time_after_eq(time, next_shrink - 5)) {
 		/* Get the current RPC size directly, instead of going via:
 		 * cli_brw_size(obd->u.cli.cl_import->imp_obd->obd_self_export)
 		 * Keep comment here so that it can be found by searching.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 537a9e2ed467..f704f8746f2c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1501,7 +1501,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 
 		if (wait_event_idle_timeout(imp->imp_recovery_waitq,
 					    !ptlrpc_import_in_recovery(imp),
-					    max(timeout, CFS_TICK)) == 0)
+					    max(timeout, 1UL)) == 0)
 			l_wait_event_abortable(
 				imp->imp_recovery_waitq,
 				!ptlrpc_import_in_recovery(imp));
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 89eef8ec7df4..b3297b5ce395 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -180,7 +180,7 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 	imp->imp_force_verify = 0;
 
-	if (time_after_eq(imp->imp_next_ping - 5 * CFS_TICK, this_ping) &&
+	if (time_after_eq(imp->imp_next_ping - 5, this_ping) &&
 	    !force) {
 		spin_unlock(&imp->imp_lock);
 		return;
