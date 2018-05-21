From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 30/30] staging: lustre: remove libcfs_all.h
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731351.24196.8390974804707198399.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

In the remaining files that include libcfs_all.h,
replace it with other include files as necessary,
then remove libcfs_all.h

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_all.h       |   88 --------------------
 drivers/staging/lustre/lnet/libcfs/debug.c         |    5 +
 drivers/staging/lustre/lnet/libcfs/fail.c          |    6 +
 drivers/staging/lustre/lnet/libcfs/hash.c          |    5 +
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   15 ++-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |    5 +
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |    6 +
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    8 ++
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  |    4 +
 drivers/staging/lustre/lnet/libcfs/linux-debug.c   |    2 
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   |    3 -
 drivers/staging/lustre/lnet/libcfs/module.c        |    1 
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   10 ++
 13 files changed, 50 insertions(+), 108 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_all.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_all.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_all.h
deleted file mode 100644
index c4232c823ac7..000000000000
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_all.h
+++ /dev/null
@@ -1,88 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LIBCFS_LIBCFS_ALL_H__
-#define __LIBCFS_LIBCFS_ALL_H__
-
-#include <linux/gfp.h>
-#include <linux/list.h>
-
-#include <uapi/linux/lnet/libcfs_ioctl.h>
-#include <linux/bitops.h>
-#include <linux/compiler.h>
-#include <linux/ctype.h>
-#include <linux/errno.h>
-#include <linux/file.h>
-#include <linux/fs.h>
-#include <linux/highmem.h>
-#include <linux/interrupt.h>
-#include <linux/kallsyms.h>
-#include <linux/kernel.h>
-#include <linux/kmod.h>
-#include <linux/kthread.h>
-#include <linux/mm.h>
-#include <linux/mm_inline.h>
-#include <linux/module.h>
-#include <linux/moduleparam.h>
-#include <linux/mutex.h>
-#include <linux/notifier.h>
-#include <linux/pagemap.h>
-#include <linux/random.h>
-#include <linux/rbtree.h>
-#include <linux/rwsem.h>
-#include <linux/scatterlist.h>
-#include <linux/sched.h>
-#include <linux/signal.h>
-#include <linux/slab.h>
-#include <linux/smp.h>
-#include <linux/stat.h>
-#include <linux/string.h>
-#include <linux/time.h>
-#include <linux/timer.h>
-#include <linux/types.h>
-#include <linux/unistd.h>
-#include <linux/vmalloc.h>
-#include <net/sock.h>
-#include <linux/atomic.h>
-#include <asm/div64.h>
-#include <linux/timex.h>
-#include <linux/uaccess.h>
-#include <stdarg.h>
-
-#include <linux/libcfs/libcfs.h>
-
-#include <linux/libcfs/libcfs_cpu.h>
-#include <linux/libcfs/libcfs_string.h>
-#include <linux/libcfs/libcfs_hash.h>
-
-#endif /* __LIBCFS_LIBCFS_ALL_H__ */
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index d59b6243d6bd..06f694f6a28f 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -38,7 +38,10 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/module.h>
+#include <linux/ctype.h>
+#include <linux/libcfs/libcfs_string.h>
+#include <linux/kthread.h>
 #include "tracefile.h"
 
 static char debug_file_name[1024];
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 7385bdf541b6..bd86b3b5bc34 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -30,7 +30,11 @@
  * Lustre is a trademark of Oracle Corporation, Inc.
  */
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/random.h>
 
 unsigned long cfs_fail_loc;
 EXPORT_SYMBOL(cfs_fail_loc);
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 88a853f64b89..48be66f0d654 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -105,8 +105,9 @@
  */
 #include <linux/seq_file.h>
 #include <linux/log2.h>
-
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/libcfs/libcfs_hash.h>
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 0c9369e4a014..3d1cf457b286 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -31,16 +31,19 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/cpu.h>
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/cache.h>
+
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/libcfs/libcfs_string.h>
+#include <linux/libcfs/libcfs.h>
 
 /** Global CPU partition table */
 struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
 EXPORT_SYMBOL(cfs_cpt_tab);
-#define DEBUG_SUBSYSTEM S_LNET
-
-#include <linux/cpu.h>
-#include <linux/sched.h>
-#include <linux/libcfs/libcfs_all.h>
 
 /**
  * modparam for setting number of partitions
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 4758cb4bd9d8..223505c37545 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -28,7 +28,10 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_cpu.h>
 
 /** destroy cpu-partition lock, see libcfs_private.h for more detail */
 void
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index dcc418528e23..2d533be9bb30 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -29,7 +29,11 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
 
 struct cfs_var_array {
 	unsigned int		va_count;	/* # of buffers */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index bdd3b97e7f65..e1fb1263e3ae 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -37,7 +37,13 @@
  * Author: Nathan Rutman <nathan.rutman@sun.com>
  */
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/ctype.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_string.h>
 
 /* Convert a text string to a bitmask */
 int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
index c7fc388f81f5..21ff9bf6da47 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -30,8 +30,10 @@
 
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/highmem.h>
+#include <linux/module.h>
 #include <linux/libcfs/libcfs_crypto.h>
+#include <linux/libcfs/libcfs.h>
 #include "linux-crypto.h"
 
 /**
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
index cf53f5d0b5ec..15ab849374c2 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
@@ -51,8 +51,6 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include "tracefile.h"
 
 #include <linux/kallsyms.h>
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index f3ed9f6d86ca..347138409eba 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -34,7 +34,8 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #define LUSTRE_TRACEFILE_PRIVATE
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
 #include "tracefile.h"
 
 /* percents to share the total debug memory for each type */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 45c8db09bf51..5dc7de9e6478 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -52,7 +52,6 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs_all.h>
 #include <asm/div64.h>
 
 #include <linux/libcfs/libcfs_crypto.h>
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 828e4d002a16..7ca562e156f0 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -39,9 +39,15 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #define LUSTRE_TRACEFILE_PRIVATE
 #define pr_fmt(fmt) "Lustre: " fmt
-#include "tracefile.h"
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/ratelimit.h>
+#include <linux/highmem.h>
+#include <linux/ctype.h>
+#include <linux/kthread.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include "tracefile.h"
 
 /* XXX move things up to the top, comment */
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
