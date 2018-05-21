From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 21/30] staging: lustre: don't include
 libcfs.h in lnet/lib-lnet.h
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731316.24196.12791593255031892674.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

We want to be more focused in what is included where.
So we remove libcfs.h from where it isn't needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |    1 +
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    3 +++
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    6 +++++-
 drivers/staging/lustre/lnet/lnet/config.c          |    1 +
 4 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 07f7d306ba9a..17534a76362a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -39,6 +39,7 @@
 #ifndef __LIBCFS_DEBUG_H__
 #define __LIBCFS_DEBUG_H__
 
+#include <linux/limits.h>
 #include <uapi/linux/lnet/libcfs_debug.h>
 
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index d6fc3164e7e7..a0c3413f4e6e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -33,6 +33,9 @@
 #ifndef _LIBCFS_FAIL_H
 #define _LIBCFS_FAIL_H
 
+#include <linux/sched.h>
+#include <linux/wait.h>
+
 extern unsigned long cfs_fail_loc;
 extern unsigned int cfs_fail_val;
 extern int cfs_fail_err;
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index cc0150ef84fe..973c17a1c4a1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -36,7 +36,11 @@
 #ifndef __LNET_LIB_LNET_H__
 #define __LNET_LIB_LNET_H__
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/libcfs/libcfs_string.h>
+#include <net/sock.h>
+
 #include <linux/lnet/api.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 0aea268a4f1c..55ecc1998b7e 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -34,6 +34,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #include <linux/nsproxy.h>
 #include <net/net_namespace.h>
+#include <linux/ctype.h>
 #include <linux/lnet/lib-lnet.h>
 
 struct lnet_text_buf {	    /* tmp struct for parsing routes */
