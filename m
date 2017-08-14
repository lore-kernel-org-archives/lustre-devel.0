From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:27 -0400
Subject: [lustre-devel] [PATCH 59/64] staging: lustre: lnet: add include
	path to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-60-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the lnet core source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/Makefile      | 3 +++
 drivers/staging/lustre/lnet/lnet/acceptor.c    | 2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c      | 4 ++--
 drivers/staging/lustre/lnet/lnet/config.c      | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c      | 3 ++-
 drivers/staging/lustre/lnet/lnet/lib-md.c      | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c      | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c    | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c     | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c     | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c  | 4 ++--
 drivers/staging/lustre/lnet/lnet/lo.c          | 3 ++-
 drivers/staging/lustre/lnet/lnet/module.c      | 5 +++--
 drivers/staging/lustre/lnet/lnet/net_fault.c   | 4 ++--
 drivers/staging/lustre/lnet/lnet/nidstrings.c  | 4 ++--
 drivers/staging/lustre/lnet/lnet/peer.c        | 4 ++--
 drivers/staging/lustre/lnet/lnet/router.c      | 3 ++-
 drivers/staging/lustre/lnet/lnet/router_proc.c | 5 +++--
 18 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index 4c81fa1..fd8585c 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LNET) += lnet.o
 
 lnet-y := api-ni.o config.o nidstrings.o net_fault.o		\
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index a6f60c3..be2823f 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -33,7 +33,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include <linux/completion.h>
 #include <net/sock.h>
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 static int   accept_port    = 988;
 static int   accept_backlog = 127;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 30c7ff6..ad83503 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -34,8 +34,8 @@
 #include <linux/log2.h>
 #include <linux/ktime.h>
 
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/uapi/linux/lnet/lnet-dlc.h"
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
 
 #define D_LNI D_CONSOLE
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 933988d..26841a7 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -33,7 +33,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include <linux/nsproxy.h>
 #include <net/net_namespace.h>
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 struct lnet_text_buf {	    /* tmp struct for parsing routes */
 	struct list_head ltb_list;	/* stash on lists */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 9ebba4e..6b446a5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -35,7 +35,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
+
+#include <linux/lnet/lib-lnet.h>
 
 /**
  * Create an event queue that has room for \a count number of events.
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index f08e944..a0aef4b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 /* must be called with lnet_res_lock held */
 void
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index e9b3eed..f52a5e8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 /**
  * Create and attach a match entry to the match list of \a portal. The new
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 20ebe24..d886504 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 #include <linux/nsproxy.h>
 #include <net/net_namespace.h>
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 008ac50..d04875e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 void
 lnet_build_unlink_event(struct lnet_libmd *md, struct lnet_event *ev)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 3333272..5946848 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -31,7 +31,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 /* NB: add /proc interfaces in upcoming patches */
 int portal_rotor = LNET_PTL_ROTOR_HASH_RT;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 800f4f6..7d0add0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -40,8 +40,8 @@
 #include <linux/syscalls.h>
 #include <net/sock.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
 
 static int
 kernel_sock_unlocked_ioctl(struct file *filp, int cmd, unsigned long arg)
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index a7504b8..80c06f4 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -29,7 +29,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
+
+#include <linux/lnet/lib-lnet.h>
 
 static int
 lolnd_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 06fcfd2..7d12a7f 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -31,8 +31,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/uapi/linux/lnet/lnet-dlc.h"
+
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
 
 static int config_on_load;
 module_param(config_on_load, int, 0444);
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 166a311..03f3d18 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -35,8 +35,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/uapi/linux/lnet/lnetctl.h"
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnetctl.h>
 
 #define LNET_MSG_MASK		(LNET_PUT_BIT | LNET_ACK_BIT | \
 				 LNET_GET_BIT | LNET_REPLY_BIT)
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index a91bbc4..7bd1e6f 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -36,8 +36,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/uapi/linux/lnet/nidstr.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lnet/nidstr.h>
 
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 301b275..4d55df8 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -34,8 +34,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/uapi/linux/lnet/lnet-dlc.h"
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
 
 int
 lnet_peer_tables_create(void)
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 12dd104..3df101b 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -18,8 +18,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
+
 #include <linux/completion.h>
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/lnet/lib-lnet.h>
 
 #define LNET_NRB_TINY_MIN	512	/* min value for each CPT */
 #define LNET_NRB_TINY		(LNET_NRB_TINY_MIN * 4)
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 72b80c5..4a994d1 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -18,8 +18,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
 
 /*
  * This is really lnet_proc.c. You might need to update sanity test 215
-- 
1.8.3.1
