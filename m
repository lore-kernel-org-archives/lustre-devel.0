From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 23/30] staging: lustre: remove libcfs_all.h
 from includes lustre/lnet
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731324.24196.4431500908715902376.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Some of these include files didn't need to
include libcfs_all.h.  A couple did so replace with just the
base include files needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.h  |    8 +++++++-
 drivers/staging/lustre/lnet/selftest/conrpc.h   |    1 -
 drivers/staging/lustre/lnet/selftest/console.h  |    1 -
 drivers/staging/lustre/lnet/selftest/selftest.h |    1 -
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index bbad0746f221..0608240d897f 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -34,7 +34,13 @@
 #ifndef __LIBCFS_TRACEFILE_H__
 #define __LIBCFS_TRACEFILE_H__
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/spinlock.h>
+#include <linux/list.h>
+#include <linux/cache.h>
+#include <linux/threads.h>
+#include <linux/limits.h>
+#include <linux/smp.h>
+#include <linux/libcfs/libcfs.h>
 
 enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 29e743716bd6..ce2f92d04838 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -40,7 +40,6 @@
 #ifndef __LST_CONRPC_H__
 #define __LST_CONRPC_H__
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnetst.h>
 #include "rpc.h"
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 59e5ff9f6979..2826205e36a1 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -40,7 +40,6 @@
 #ifndef __LST_CONSOLE_H__
 #define __LST_CONSOLE_H__
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnetst.h>
 #include "selftest.h"
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index adf18515cb73..8737fa96b192 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -39,7 +39,6 @@
 
 #define LNET_ONLY
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnetst.h>
