From: James Simmons <jsimmons@infradead.org>
Date: Mon,  8 Jun 2015 22:27:07 -0400
Subject: [lustre-devel] [PATCH v5 1/7] staging:lustre: move tcpip abstraction
In-Reply-To: <1433816833-3244-1-git-send-email-jsimmons@infradead.org>
References: <1433816833-3244-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433816833-3244-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Rename libcfs/linux/linux-tcpip.c to lnet/lnet/lib-socket.c

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/Makefile          |    7 ++++---
 .../linux/linux-tcpip.c => lnet/lnet/lib-socket.c} |    3 ++-
 drivers/staging/lustre/lustre/libcfs/Makefile      |    1 -
 3 files changed, 6 insertions(+), 5 deletions(-)
 rename drivers/staging/lustre/{lustre/libcfs/linux/linux-tcpip.c => lnet/lnet/lib-socket.c} (99%)

diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index 336b8ea..52492fb 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_LNET) += lnet.o
 
-lnet-y := api-ni.o config.o lib-me.o lib-msg.o lib-eq.o	\
-	  lib-md.o lib-ptl.o lib-move.o module.o lo.o router.o		\
-	  router_proc.o acceptor.o peer.o
+lnet-y := api-ni.o config.o					\
+	  lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o	\
+	  lib-socket.o lib-move.o module.o lo.o			\
+	  router.o router_proc.o acceptor.o peer.o
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
similarity index 99%
rename from drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c
rename to drivers/staging/lustre/lnet/lnet/lib-socket.c
index f2462e7..7f80612 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -35,7 +35,8 @@
  */
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/lnet/lib-lnet.h"
 
 #include <linux/if.h>
 #include <linux/in.h>
diff --git a/drivers/staging/lustre/lustre/libcfs/Makefile b/drivers/staging/lustre/lustre/libcfs/Makefile
index fabdd3e..ec98f44 100644
--- a/drivers/staging/lustre/lustre/libcfs/Makefile
+++ b/drivers/staging/lustre/lustre/libcfs/Makefile
@@ -2,7 +2,6 @@ obj-$(CONFIG_LUSTRE_FS) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
 libcfs-linux-objs += linux-prim.o linux-cpu.o
-libcfs-linux-objs += linux-tcpip.o
 libcfs-linux-objs += linux-curproc.o
 libcfs-linux-objs += linux-module.o
 libcfs-linux-objs += linux-crypto.o
-- 
1.7.1
