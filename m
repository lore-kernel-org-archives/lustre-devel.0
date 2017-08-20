From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:56 -0400
Subject: [lustre-devel] [PATCH 62/64 v2] staging: lustre: libcfs: add
	include path to Makefile
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-63-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the libcfs source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/Makefile                | 3 +++
 drivers/staging/lustre/lnet/libcfs/debug.c                 | 2 +-
 drivers/staging/lustre/lnet/libcfs/fail.c                  | 2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c                  | 2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c            | 2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c           | 2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c            | 2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c         | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c       | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c    | 4 ++--
 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c   | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c     | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c       | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c    | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c      | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c | 2 +-
 drivers/staging/lustre/lnet/libcfs/module.c                | 8 ++++----
 drivers/staging/lustre/lnet/libcfs/prng.c                  | 2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c             | 2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h             | 2 +-
 drivers/staging/lustre/lnet/libcfs/workitem.c              | 2 +-
 21 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 8c89455..215fa23 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LNET) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 49deb44..1ab394c 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -37,7 +37,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include "tracefile.h"
 
 static char debug_file_name[1024];
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 12dd50a..24f4701 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -29,7 +29,7 @@
  * Lustre is a trademark of Oracle Corporation, Inc.
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 unsigned long cfs_fail_loc;
 EXPORT_SYMBOL(cfs_fail_loc);
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index ff54eaf..49a04a2 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -105,7 +105,7 @@
 #include <linux/seq_file.h>
 #include <linux/log2.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 55caa19..2ddd09a 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -30,7 +30,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 /** Global CPU partition table */
 struct cfs_cpt_table   *cfs_cpt_table __read_mostly;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 1967b97..77fd3d06 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -27,7 +27,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 /** destroy cpu-partition lock, see libcfs_private.h for more detail */
 void
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index ef085ba..1a0c7ca 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -28,7 +28,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 struct cfs_var_array {
 	unsigned int		va_count;	/* # of buffers */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 02de1ee..333e47f 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -36,7 +36,7 @@
  * Author: Nathan Rutman <nathan.rutman@sun.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 /* Convert a text string to a bitmask */
 int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 4d35a37..2da051c 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -31,7 +31,7 @@
 
 #include <linux/cpu.h>
 #include <linux/sched.h>
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 #ifdef CONFIG_SMP
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 68e34b4..5566339 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -29,8 +29,8 @@
 
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/linux/libcfs/libcfs_crypto.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_crypto.h>
 #include "linux-crypto.h"
 
 /**
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
index 3e22cad..528d497 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
@@ -44,7 +44,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 /*
  * Implementation of cfs_curproc API (see portals/include/libcfs/curproc.h)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 7035356..972677b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -51,7 +51,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 #include "../tracefile.h"
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
index 8f63826..3f5dec1 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
@@ -29,7 +29,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 void *libcfs_kvzalloc(size_t size, gfp_t flags)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index c6837bc..4357221 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 #define LNET_MINOR 240
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index bcf9f3d..4e331e7 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -36,7 +36,7 @@
 #include <linux/fs_struct.h>
 #include <linux/sched/signal.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 #if defined(CONFIG_KGDB)
 #include <linux/kgdb.h>
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index a5a9478..16a3ae7 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -33,7 +33,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #define LUSTRE_TRACEFILE_PRIVATE
 
-#include "../../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include "../tracefile.h"
 
 /* percents to share the total debug memory for each type */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 657c495..6aed98f 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -50,12 +50,12 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <asm/div64.h>
 
-#include "../../include/linux/libcfs/libcfs_crypto.h"
-#include "../../include/linux/lnet/lib-lnet.h"
-#include "../../include/uapi/linux/lnet/lnet-dlc.h"
+#include <linux/libcfs/libcfs_crypto.h>
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
 #include "tracefile.h"
 
 static struct dentry *lnet_debugfs_root;
diff --git a/drivers/staging/lustre/lnet/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
index 21d5a39..963ef4a 100644
--- a/drivers/staging/lustre/lnet/libcfs/prng.c
+++ b/drivers/staging/lustre/lnet/libcfs/prng.c
@@ -35,7 +35,7 @@
  * algorithm recommended by Marsaglia
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 /*
  * From: George Marsaglia <geo@stat.fsu.edu>
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index d1aa79b..68f283a 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -40,7 +40,7 @@
 #define pr_fmt(fmt) "Lustre: " fmt
 #include "tracefile.h"
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 /* XXX move things up to the top, comment */
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index f644cbc..c3547cd 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -33,7 +33,7 @@
 #ifndef __LIBCFS_TRACEFILE_H__
 #define __LIBCFS_TRACEFILE_H__
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index dbc2a9b..038ed8c 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 #define CFS_WS_NAME_LEN	 16
 
-- 
1.8.3.1
