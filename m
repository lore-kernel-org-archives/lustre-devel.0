From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 29/30] staging: lustre: move all libcfs_all
 includes except in lustre/lnet/libcfs/
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731347.24196.12160487549201431760.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Again, most of these are not needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |    2 ++
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    1 -
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    5 ++++-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    1 -
 drivers/staging/lustre/lnet/selftest/conctl.c      |    1 -
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    1 -
 drivers/staging/lustre/lnet/selftest/console.c     |    1 -
 7 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 66463477074a..cd7c3ccb2dc0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -40,6 +40,8 @@
 #ifndef __LIBCFS_STRING_H__
 #define __LIBCFS_STRING_H__
 
+#include <linux/mm.h>
+
 /* libcfs_string.c */
 /* Convert a text string to a bitmask */
 int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index b94896efc4c6..9b61260155f2 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -41,7 +41,6 @@
 #include <linux/syscalls.h>
 #include <net/sock.h>
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 
 static int
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 4c803ea88410..0f6c3fa16c65 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -37,7 +37,10 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_string.h>
 #include <uapi/linux/lnet/nidstr.h>
 
 /* max value for numeric network address */
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 88ad787ff4ba..ae4b7f5953a0 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -20,7 +20,6 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index b4d521746541..906d82d90c0c 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -37,7 +37,6 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnetst.h>
 #include "console.h"
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index aefcf0db886e..0dabade3d091 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -37,7 +37,6 @@
  * Author: Liang Zhen <liang@whamcloud.com>
  */
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include "timer.h"
 #include "conrpc.h"
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index d11f854ea1f0..3c1c1b5997e0 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -37,7 +37,6 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include "console.h"
 #include "conrpc.h"
