From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:04 -0400
Subject: [lustre-devel] [PATCH 36/64] staging: lustre: lnet: migrate headers
	to lnet uapi directory
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-37-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Migrate the headers used by user land and kernel space to the
libcfs/lnet uapi directory.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/28089
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs.h              | 2 +-
 drivers/staging/lustre/include/linux/lnet/api.h                   | 2 +-
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h              | 8 ++++----
 drivers/staging/lustre/include/linux/lnet/lib-types.h             | 4 ++--
 drivers/staging/lustre/include/linux/lnet/socklnd.h               | 2 +-
 .../include/{linux/libcfs => uapi/linux/lnet}/libcfs_ioctl.h      | 0
 .../include/{linux/lnet/lib-dlc.h => uapi/linux/lnet/lnet-dlc.h}  | 4 ++--
 .../include/{linux/lnet/types.h => uapi/linux/lnet/lnet-types.h}  | 0
 drivers/staging/lustre/include/{ => uapi}/linux/lnet/lnetctl.h    | 2 +-
 drivers/staging/lustre/include/{ => uapi}/linux/lnet/lnetst.h     | 0
 drivers/staging/lustre/include/{ => uapi}/linux/lnet/nidstr.h     | 2 +-
 drivers/staging/lustre/lnet/libcfs/module.c                       | 2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c                         | 2 +-
 drivers/staging/lustre/lnet/lnet/module.c                         | 2 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c                      | 2 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c                     | 2 +-
 drivers/staging/lustre/lnet/lnet/peer.c                           | 2 +-
 drivers/staging/lustre/lnet/selftest/conctl.c                     | 2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h                     | 2 +-
 drivers/staging/lustre/lnet/selftest/console.h                    | 2 +-
 drivers/staging/lustre/lnet/selftest/rpc.h                        | 2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h                   | 2 +-
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h         | 3 +--
 drivers/staging/lustre/lustre/include/lustre_disk.h               | 1 -
 drivers/staging/lustre/lustre/include/lustre_net.h                | 2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c                | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c                    | 2 +-
 28 files changed, 29 insertions(+), 31 deletions(-)
 rename drivers/staging/lustre/include/{linux/libcfs => uapi/linux/lnet}/libcfs_ioctl.h (100%)
 rename drivers/staging/lustre/include/{linux/lnet/lib-dlc.h => uapi/linux/lnet/lnet-dlc.h} (98%)
 rename drivers/staging/lustre/include/{linux/lnet/types.h => uapi/linux/lnet/lnet-types.h} (100%)
 rename drivers/staging/lustre/include/{ => uapi}/linux/lnet/lnetctl.h (99%)
 rename drivers/staging/lustre/include/{ => uapi}/linux/lnet/lnetst.h (100%)
 rename drivers/staging/lustre/include/{ => uapi}/linux/lnet/nidstr.h (99%)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index cc2c0e9..71bb55e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -77,7 +77,7 @@
 #include "libcfs_debug.h"
 #include "libcfs_cpu.h"
 #include "libcfs_private.h"
-#include "libcfs_ioctl.h"
+#include "../../uapi/linux/lnet/libcfs_ioctl.h"
 #include "libcfs_prim.h"
 #include "libcfs_time.h"
 #include "libcfs_string.h"
diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index f4b6de2..01ae62e 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -44,7 +44,7 @@
  * @{
  */
 
-#include "../lnet/types.h"
+#include "../../uapi/linux/lnet/lnet-types.h"
 
 /** \defgroup lnet_init_fini Initialization and cleanup
  * The LNet must be properly initialized before any LNet calls can be made.
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 9b923ec..bc55d57 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -38,10 +38,10 @@
 #include "../libcfs/libcfs.h"
 #include "api.h"
 #include "lib-types.h"
-#include "lib-dlc.h"
-#include "types.h"
-#include "lnetctl.h"
-#include "nidstr.h"
+#include "../../uapi/linux/lnet/lnet-dlc.h"
+#include "../../uapi/linux/lnet/lnet-types.h"
+#include "../../uapi/linux/lnet/lnetctl.h"
+#include "../../uapi/linux/lnet/nidstr.h"
 
 extern struct lnet the_lnet;	/* THE network */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index ddb808e..94d3a53 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -40,8 +40,8 @@
 #include <linux/types.h>
 #include <linux/completion.h>
 
-#include "types.h"
-#include "lnetctl.h"
+#include "../../uapi/linux/lnet/lnet-types.h"
+#include "../../uapi/linux/lnet/lnetctl.h"
 
 /* Max payload size */
 #define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 27ce6ce..c24fe45 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -34,7 +34,7 @@
 #ifndef __LNET_LNET_SOCKLND_H__
 #define __LNET_LNET_SOCKLND_H__
 
-#include "types.h"
+#include "../../uapi/linux/lnet/lnet-types.h"
 #include "../../uapi/linux/lnet/socklnd.h"
 
 struct ksock_hello_msg {
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
similarity index 100%
rename from drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
rename to drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
similarity index 98%
rename from drivers/staging/lustre/include/linux/lnet/lib-dlc.h
rename to drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index dfff170..a3821d9 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -29,8 +29,8 @@
 #ifndef LNET_DLC_H
 #define LNET_DLC_H
 
-#include "../libcfs/libcfs_ioctl.h"
-#include "types.h"
+#include "libcfs_ioctl.h"
+#include "lnet-types.h"
 
 #define MAX_NUM_SHOW_ENTRIES	32
 #define LNET_MAX_STR_LEN	128
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
similarity index 100%
rename from drivers/staging/lustre/include/linux/lnet/types.h
rename to drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
similarity index 99%
rename from drivers/staging/lustre/include/linux/lnet/lnetctl.h
rename to drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index 3957507..2ce1c50 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -15,7 +15,7 @@
 #ifndef _LNETCTL_H_
 #define _LNETCTL_H_
 
-#include "types.h"
+#include "lnet-types.h"
 
 /** \addtogroup lnet_fault_simulation
  * @{
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
similarity index 100%
rename from drivers/staging/lustre/include/linux/lnet/lnetst.h
rename to drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
similarity index 99%
rename from drivers/staging/lustre/include/linux/lnet/nidstr.h
rename to drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
index ecdd0db..d153c97 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
@@ -28,7 +28,7 @@
 #ifndef _LNET_NIDSTRINGS_H
 #define _LNET_NIDSTRINGS_H
 
-#include "types.h"
+#include "lnet-types.h"
 
 /**
  *  Lustre Network Driver types.
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 9ece869..657c495 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -55,7 +55,7 @@
 
 #include "../../include/linux/libcfs/libcfs_crypto.h"
 #include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "../../include/uapi/linux/lnet/lnet-dlc.h"
 #include "tracefile.h"
 
 static struct dentry *lnet_debugfs_root;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0b91d18..30c7ff6 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -35,7 +35,7 @@
 #include <linux/ktime.h>
 
 #include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "../../include/uapi/linux/lnet/lnet-dlc.h"
 
 #define D_LNI D_CONSOLE
 
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 4ffbd3e..06fcfd2 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 #include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "../../include/uapi/linux/lnet/lnet-dlc.h"
 
 static int config_on_load;
 module_param(config_on_load, int, 0444);
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 18183cb..166a311 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -36,7 +36,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lnetctl.h"
+#include "../../include/uapi/linux/lnet/lnetctl.h"
 
 #define LNET_MSG_MASK		(LNET_PUT_BIT | LNET_ACK_BIT | \
 				 LNET_GET_BIT | LNET_REPLY_BIT)
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index cbbd11f..a91bbc4 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/nidstr.h"
+#include "../../include/uapi/linux/lnet/nidstr.h"
 
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index e62b21f..301b275 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -35,7 +35,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 
 #include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-dlc.h"
+#include "../../include/uapi/linux/lnet/lnet-dlc.h"
 
 int
 lnet_peer_tables_create(void)
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 043eafb..106304e 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -38,7 +38,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "../../include/uapi/linux/lnet/lnetst.h"
 #include "console.h"
 
 static int
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index e2a78b6..501e1ec 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -41,7 +41,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lib-types.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "../../include/uapi/linux/lnet/lnetst.h"
 #include "rpc.h"
 #include "selftest.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 0a9ba06..d806214 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -41,7 +41,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lib-types.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "../../include/uapi/linux/lnet/lnetst.h"
 #include "selftest.h"
 #include "conrpc.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index a765537..217ca21 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -33,7 +33,7 @@
 #ifndef __SELFTEST_RPC_H__
 #define __SELFTEST_RPC_H__
 
-#include "../../include/linux/lnet/lnetst.h"
+#include "../../include/uapi/linux/lnet/lnetst.h"
 
 /*
  * LST wired structures
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index bfa4971..3777023 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -41,7 +41,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lib-lnet.h"
 #include "../../include/linux/lnet/lib-types.h"
-#include "../../include/linux/lnet/lnetst.h"
+#include "../../include/uapi/linux/lnet/lnetst.h"
 
 #include "rpc.h"
 #include "timer.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index fab624e..d26c599 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -70,8 +70,7 @@
 #define _LUSTRE_IDL_H_
 
 #include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/types.h"
-
+#include "../../../include/uapi/linux/lnet/lnet-types.h"
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
 #include "../lustre_ver.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 1a532ad..05cdc66 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -45,7 +45,6 @@
  */
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/types.h"
 #include <linux/backing-dev.h>
 
 /****************** persistent mount data *********************/
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 05f02b1..c0b5927 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -52,7 +52,7 @@
 
 #include <linux/uio.h>
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/nidstr.h"
+#include "../../include/uapi/linux/lnet/nidstr.h"
 #include "../../include/linux/lnet/api.h"
 #include "lustre/lustre_idl.h"
 #include "lustre_ha.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index ed30333..dedad65 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -35,7 +35,7 @@
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
-#include "../../include/linux/lnet/lnetctl.h"
+#include "../../include/uapi/linux/lnet/lnetctl.h"
 #include "../include/lustre_debug.h"
 #include "../include/lprocfs_status.h"
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 9f83345..1b5beea 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -61,7 +61,7 @@
 #include <linux/kobject.h>
 
 #include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/lnet/lnetctl.h"
+#include "../../../include/uapi/linux/lnet/lnetctl.h"
 #include "../../include/obd_support.h"
 #include "../../include/obd_class.h"
 #include "../../include/lprocfs_status.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index bcf5faf..ca3d69e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -35,7 +35,7 @@
 #include "../include/obd_class.h"
 #include "../include/lustre_net.h"
 #include "../include/lu_object.h"
-#include "../../include/linux/lnet/types.h"
+#include "../../include/uapi/linux/lnet/lnet-types.h"
 #include "ptlrpc_internal.h"
 
 /* The following are visible and mutable through /sys/module/ptlrpc */
-- 
1.8.3.1
