From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:26 -0400
Subject: [lustre-devel] [PATCH 58/64] staging: lustre: lnet: selftest: add
	include path to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-59-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the lnet selftest source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/Makefile   | 3 +++
 drivers/staging/lustre/lnet/selftest/conctl.c   | 6 +++---
 drivers/staging/lustre/lnet/selftest/conrpc.c   | 4 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.h   | 6 +++---
 drivers/staging/lustre/lnet/selftest/console.c  | 4 ++--
 drivers/staging/lustre/lnet/selftest/console.h  | 6 +++---
 drivers/staging/lustre/lnet/selftest/rpc.h      | 2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h | 8 ++++----
 8 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/Makefile b/drivers/staging/lustre/lnet/selftest/Makefile
index c0de6e2..3ccc896 100644
--- a/drivers/staging/lustre/lnet/selftest/Makefile
+++ b/drivers/staging/lustre/lnet/selftest/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LNET_SELFTEST) := lnet_selftest.o
 
 lnet_selftest-y := console.o conrpc.o conctl.o framework.o timer.o rpc.o \
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 106304e..9619ecb 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -36,9 +36,9 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/uapi/linux/lnet/lnetst.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnetst.h>
 #include "console.h"
 
 static int
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index ae7c277..196d23c 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -36,8 +36,8 @@
  * Author: Liang Zhen <liang@whamcloud.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
 #include "timer.h"
 #include "conrpc.h"
 #include "console.h"
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 501e1ec..2393236 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -39,9 +39,9 @@
 #ifndef __LST_CONRPC_H__
 #define __LST_CONRPC_H__
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-types.h"
-#include "../../include/uapi/linux/lnet/lnetst.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-types.h>
+#include <uapi/linux/lnet/lnetst.h>
 #include "rpc.h"
 #include "selftest.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index d62c448..289b202 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -36,8 +36,8 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
 #include "console.h"
 #include "conrpc.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index d806214..143eae9 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -39,9 +39,9 @@
 #ifndef __LST_CONSOLE_H__
 #define __LST_CONSOLE_H__
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-types.h"
-#include "../../include/uapi/linux/lnet/lnetst.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-types.h>
+#include <uapi/linux/lnet/lnetst.h>
 #include "selftest.h"
 #include "conrpc.h"
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 217ca21..7bb442a 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -33,7 +33,7 @@
 #ifndef __SELFTEST_RPC_H__
 #define __SELFTEST_RPC_H__
 
-#include "../../include/uapi/linux/lnet/lnetst.h"
+#include <uapi/linux/lnet/lnetst.h>
 
 /*
  * LST wired structures
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 3777023..7adad43 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -38,10 +38,10 @@
 
 #define LNET_ONLY
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/linux/lnet/lib-types.h"
-#include "../../include/uapi/linux/lnet/lnetst.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/lnet/lib-lnet.h>
+#include <linux/lnet/lib-types.h>
+#include <uapi/linux/lnet/lnetst.h>
 
 #include "rpc.h"
 #include "timer.h"
-- 
1.8.3.1
