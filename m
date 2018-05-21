From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 20/30] staging: lustre: start moving includes
 out of libcfs.h
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731307.24196.11390884680126989650.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Lots of places include libcfs.h, and it includes lots of other include
files.  Many of these aren't needed in many places.  It is tidier and
better documentation to just include what is needed.

So remove all the includes from libcfs.h and create libcfs_all.h which
contains them.  Then change every reference to libcfs.h to instead
include libcfs_all.h

Next several patches will remove that from various files
in small batches

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   48 -----------
 .../lustre/include/linux/libcfs/libcfs_all.h       |   88 ++++++++++++++++++++
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    2 
 drivers/staging/lustre/lnet/libcfs/debug.c         |    2 
 drivers/staging/lustre/lnet/libcfs/fail.c          |    2 
 drivers/staging/lustre/lnet/libcfs/hash.c          |    2 
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    4 -
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |    2 
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |    2 
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    2 
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  |    2 
 drivers/staging/lustre/lnet/libcfs/linux-debug.c   |    2 
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   |    2 
 drivers/staging/lustre/lnet/libcfs/module.c        |    2 
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |    2 
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |    2 
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    2 
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    2 
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 
 drivers/staging/lustre/lnet/selftest/conctl.c      |    2 
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    2 
 drivers/staging/lustre/lnet/selftest/conrpc.h      |    2 
 drivers/staging/lustre/lnet/selftest/console.c     |    2 
 drivers/staging/lustre/lnet/selftest/console.h     |    2 
 drivers/staging/lustre/lnet/selftest/selftest.h    |    2 
 drivers/staging/lustre/lustre/fid/fid_internal.h   |    2 
 drivers/staging/lustre/lustre/fid/fid_lib.c        |    2 
 drivers/staging/lustre/lustre/fid/fid_request.c    |    2 
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    2 
 drivers/staging/lustre/lustre/fld/fld_cache.c      |    2 
 drivers/staging/lustre/lustre/fld/fld_internal.h   |    2 
 drivers/staging/lustre/lustre/fld/fld_request.c    |    2 
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    2 
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 
 drivers/staging/lustre/lustre/include/lu_object.h  |    2 
 .../staging/lustre/lustre/include/lustre_disk.h    |    2 
 drivers/staging/lustre/lustre/include/lustre_fid.h |    2 
 drivers/staging/lustre/lustre/include/lustre_fld.h |    2 
 .../staging/lustre/lustre/include/lustre_handles.h |    2 
 drivers/staging/lustre/lustre/include/lustre_lib.h |    2 
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 
 drivers/staging/lustre/lustre/include/lustre_mds.h |    2 
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 
 drivers/staging/lustre/lustre/include/obd_cksum.h  |    2 
 .../staging/lustre/lustre/include/obd_support.h    |    2 
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    2 
 drivers/staging/lustre/lustre/llite/glimpse.c      |    2 
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 
 drivers/staging/lustre/lustre/llite/range_lock.h   |    2 
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    2 
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    2 
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    2 
 drivers/staging/lustre/lustre/lov/lov_merge.c      |    2 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 
 drivers/staging/lustre/lustre/lov/lov_offset.c     |    2 
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    2 
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 
 drivers/staging/lustre/lustre/mgc/mgc_internal.h   |    2 
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    2 
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    2 
 .../lustre/lustre/obdclass/linux/linux-module.c    |    2 
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    |    2 
 drivers/staging/lustre/lustre/obdclass/uuid.c      |    2 
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    2 
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/errno.c       |    2 
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    2 
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |    2 
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |    2 
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    2 
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    2 
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    2 
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    2 
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    2 
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c   |    2 
 88 files changed, 177 insertions(+), 133 deletions(-)
 create mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_all.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 1880ef2b8528..edc7ed0dcb94 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -34,56 +34,12 @@
 #ifndef __LIBCFS_LIBCFS_H__
 #define __LIBCFS_LIBCFS_H__
 
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
 #include <linux/notifier.h>
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
+#include <linux/workqueue.h>
+#include <linux/sysctl.h>
 
 #include <linux/libcfs/libcfs_debug.h>
 #include <linux/libcfs/libcfs_private.h>
-#include <linux/libcfs/libcfs_cpu.h>
-#include <linux/libcfs/libcfs_string.h>
-#include <linux/libcfs/libcfs_hash.h>
 #include <linux/libcfs/libcfs_fail.h>
 
 #define LIBCFS_VERSION "0.7.0"
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_all.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_all.h
new file mode 100644
index 000000000000..c4232c823ac7
--- /dev/null
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_all.h
@@ -0,0 +1,88 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#ifndef __LIBCFS_LIBCFS_ALL_H__
+#define __LIBCFS_LIBCFS_ALL_H__
+
+#include <linux/gfp.h>
+#include <linux/list.h>
+
+#include <uapi/linux/lnet/libcfs_ioctl.h>
+#include <linux/bitops.h>
+#include <linux/compiler.h>
+#include <linux/ctype.h>
+#include <linux/errno.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/highmem.h>
+#include <linux/interrupt.h>
+#include <linux/kallsyms.h>
+#include <linux/kernel.h>
+#include <linux/kmod.h>
+#include <linux/kthread.h>
+#include <linux/mm.h>
+#include <linux/mm_inline.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/mutex.h>
+#include <linux/notifier.h>
+#include <linux/pagemap.h>
+#include <linux/random.h>
+#include <linux/rbtree.h>
+#include <linux/rwsem.h>
+#include <linux/scatterlist.h>
+#include <linux/sched.h>
+#include <linux/signal.h>
+#include <linux/slab.h>
+#include <linux/smp.h>
+#include <linux/stat.h>
+#include <linux/string.h>
+#include <linux/time.h>
+#include <linux/timer.h>
+#include <linux/types.h>
+#include <linux/unistd.h>
+#include <linux/vmalloc.h>
+#include <net/sock.h>
+#include <linux/atomic.h>
+#include <asm/div64.h>
+#include <linux/timex.h>
+#include <linux/uaccess.h>
+#include <stdarg.h>
+
+#include <linux/libcfs/libcfs.h>
+
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/libcfs/libcfs_string.h>
+#include <linux/libcfs/libcfs_hash.h>
+
+#endif /* __LIBCFS_LIBCFS_ALL_H__ */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 82561e9e44eb..cc0150ef84fe 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -36,7 +36,7 @@
 #ifndef __LNET_LIB_LNET_H__
 #define __LNET_LIB_LNET_H__
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/api.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index bb663d6d7b48..7c0e9f66b16a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -64,7 +64,7 @@
 
 #define DEBUG_SUBSYSTEM S_LND
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer lists */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a0784167e989..e080aac508ff 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -47,7 +47,7 @@
 #include <net/sock.h>
 #include <net/tcp.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include <linux/lnet/socklnd.h>
 
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 724a453a27ac..d59b6243d6bd 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -38,7 +38,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include "tracefile.h"
 
 static char debug_file_name[1024];
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index d3f1e866c6a7..7385bdf541b6 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -30,7 +30,7 @@
  * Lustre is a trademark of Oracle Corporation, Inc.
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 unsigned long cfs_fail_loc;
 EXPORT_SYMBOL(cfs_fail_loc);
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index f7b3c9306456..88a853f64b89 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -106,7 +106,7 @@
 #include <linux/seq_file.h>
 #include <linux/log2.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 40509b2acfb3..0c9369e4a014 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -31,7 +31,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /** Global CPU partition table */
 struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
@@ -40,7 +40,7 @@ EXPORT_SYMBOL(cfs_cpt_tab);
 
 #include <linux/cpu.h>
 #include <linux/sched.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /**
  * modparam for setting number of partitions
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 670ad5a34224..4758cb4bd9d8 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -28,7 +28,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /** destroy cpu-partition lock, see libcfs_private.h for more detail */
 void
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index 7faed94994ea..dcc418528e23 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -29,7 +29,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 struct cfs_var_array {
 	unsigned int		va_count;	/* # of buffers */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 442889a3d729..bdd3b97e7f65 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -37,7 +37,7 @@
  * Author: Nathan Rutman <nathan.rutman@sun.com>
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /* Convert a text string to a bitmask */
 int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
index 18113335503b..c7fc388f81f5 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -30,7 +30,7 @@
 
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/libcfs/libcfs_crypto.h>
 #include "linux-crypto.h"
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
index 2ca385cbea92..cf53f5d0b5ec 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
@@ -51,7 +51,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include "tracefile.h"
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index 3366ae6411ee..f3ed9f6d86ca 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -34,7 +34,7 @@
 #define DEBUG_SUBSYSTEM S_LNET
 #define LUSTRE_TRACEFILE_PRIVATE
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include "tracefile.h"
 
 /* percents to share the total debug memory for each type */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 3e535d82df27..45c8db09bf51 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -52,7 +52,7 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <asm/div64.h>
 
 #include <linux/libcfs/libcfs_crypto.h>
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 878fbb9745a0..828e4d002a16 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -41,7 +41,7 @@
 #define pr_fmt(fmt) "Lustre: " fmt
 #include "tracefile.h"
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /* XXX move things up to the top, comment */
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index b1c7a98ea192..bbad0746f221 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -34,7 +34,7 @@
 #ifndef __LIBCFS_TRACEFILE_H__
 #define __LIBCFS_TRACEFILE_H__
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 1bee667802b0..b94896efc4c6 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -41,7 +41,7 @@
 #include <linux/syscalls.h>
 #include <net/sock.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 
 static int
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 3aba1421c741..4c803ea88410 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lnet/nidstr.h>
 
 /* max value for numeric network address */
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 36ae5b016985..88ad787ff4ba 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -20,7 +20,7 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index f22b01e390d3..b4d521746541 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -37,7 +37,7 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include <uapi/linux/lnet/lnetst.h>
 #include "console.h"
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 8c237758c3eb..aefcf0db886e 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -37,7 +37,7 @@
  * Author: Liang Zhen <liang@whamcloud.com>
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include "timer.h"
 #include "conrpc.h"
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 374a5f31ef6f..29e743716bd6 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -40,7 +40,7 @@
 #ifndef __LST_CONRPC_H__
 #define __LST_CONRPC_H__
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnetst.h>
 #include "rpc.h"
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 9fd6013354c6..d11f854ea1f0 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -37,7 +37,7 @@
  * Author: Liang Zhen <liangzhen@clusterfs.com>
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include "console.h"
 #include "conrpc.h"
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index d65b8d942bac..59e5ff9f6979 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -40,7 +40,7 @@
 #ifndef __LST_CONSOLE_H__
 #define __LST_CONSOLE_H__
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnetst.h>
 #include "selftest.h"
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 05466b85e1c0..adf18515cb73 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -39,7 +39,7 @@
 
 #define LNET_ONLY
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/lnet/lib-lnet.h>
 #include <linux/lnet/lib-types.h>
 #include <uapi/linux/lnet/lnetst.h>
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index b7b8f900df8e..3d0003b2fb4b 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -38,7 +38,7 @@
 #define __FID_INTERNAL_H
 
 #include <uapi/linux/lustre/lustre_idl.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /* Functions used internally in module. */
 
diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index 9577da33e666..c2074beec5e9 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 #include <lustre_fid.h>
 
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index fc6582fe117f..693dc96f4175 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index a1e5bf9f36ec..528b659cd9e8 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 2d61ca4e51cf..63e6909a3edd 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index b5e3abaa508a..9485c3d31559 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -59,7 +59,7 @@
 
 #include <uapi/linux/lustre/lustre_idl.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_req_layout.h>
 #include <lustre_fld.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index b2d77c8d3dc7..05ec4afa7513 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 1a6a76110c3e..49ea18d74cb2 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/module.h>
 
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 426e8f3c9809..07b632dce2e3 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -44,7 +44,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lustre/lustre_cfg.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 4153db762518..a1a75e026053 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -36,7 +36,7 @@
 
 #include <stdarg.h>
 #include <linux/percpu_counter.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lu_ref.h>
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 100e993ab00b..c66c1b19f661 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -48,7 +48,7 @@
 #include <asm/byteorder.h>
 #include <linux/types.h>
 #include <linux/backing-dev.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 /****************** persistent mount data *********************/
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 094ad282de2c..9c4e14d88c46 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -149,7 +149,7 @@
  *  Even so, the MDT and OST resources are also in different LDLM namespaces.
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lustre/lustre_fid.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ostid.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 4055bbd24c55..e90fd323db4a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -40,7 +40,7 @@
  */
 
 #include <uapi/linux/lustre/lustre_idl.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <seq_range.h>
 
 struct lu_client_fld;
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index c48c97362cf6..79e10a1b53f2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -45,7 +45,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 struct portals_handle_ops {
 	void (*hop_addref)(void *object);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index eec10827f51f..296c7e4ee107 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -46,7 +46,7 @@
 #include <linux/sched/signal.h>
 #include <linux/signal.h>
 #include <linux/types.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 #include <uapi/linux/lustre/lustre_cfg.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index a9c9992a2502..018aaea6a1b8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -49,7 +49,7 @@
 #include <linux/dcache.h>
 #include <lustre_intent.h>
 #include <lustre_handles.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <obd_class.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 6937546f1d46..910adfd88e0a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -45,7 +45,7 @@
  */
 
 #include <lustre_handles.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
 #include <lustre_export.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 35b43a77eb18..f772d33ebbc7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -52,7 +52,7 @@
  */
 
 #include <linux/uio.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lnet/nidstr.h>
 #include <linux/lnet/api.h>
 #include <uapi/linux/lustre/lustre_idl.h>
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index e5f7bb20415d..397100f8f9a0 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -31,7 +31,7 @@
 
 #ifndef __OBD_CKSUM
 #define __OBD_CKSUM
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/libcfs/libcfs_crypto.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index a4c7a2ee9738..099b30359c26 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -37,7 +37,7 @@
 #include <linux/slab.h>
 #include <linux/sched/signal.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_compat.h>
 #include <lprocfs_status.h>
 
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index 0662cec14b81..fbeec219a75b 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -32,7 +32,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <lustre_dlm.h>
 #include <lustre_lib.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 11b11b5f3216..a6435cf8924a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -47,7 +47,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_dlm.h>
 #include <obd_support.h>
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 9efd26ec59dd..d8db751cf5a7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <obd.h>
 #include <obd_class.h>
 #include <lustre_dlm.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 763acd2311a2..66702428a914 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_intent.h>
 #include <lustre_swab.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 4e6caf748961..7a1d18176032 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/sched/mm.h>
 #include <lustre_dlm.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 3075358f3f08..eddab7d2887b 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -37,7 +37,7 @@
  *   Author: Oleg Drokin <oleg.drokin@sun.com>
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index d5b42fb1d601..de1de3b2dded 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index 38b2be4e378f..4af8781c71d7 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -37,7 +37,7 @@
 #ifndef _RANGE_LOCK_H
 #define _RANGE_LOCK_H
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <interval_tree.h>
 
 struct range_lock {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 05ad3b322a29..5aedbdbc75b7 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 2e9c75ebdda5..d5849051319b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -43,7 +43,7 @@
 #ifndef LOV_CL_INTERNAL_H
 #define LOV_CL_INTERNAL_H
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 #include <cl_object.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index c56a971745e8..223fb76c13aa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -38,7 +38,7 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include <asm/div64.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 3a0f21dc1f8a..8889ea37df18 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index a5ab0ce38e41..ad150f07ea19 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -39,7 +39,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 3e16e647b334..ba070a6ef607 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index b673b4fd305b..f00df5e24db2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -41,7 +41,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 41fc023cc381..6bc2896876db 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 2c571c180578..e402898cb28b 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -34,7 +34,7 @@
 #ifndef _MGC_INTERNAL_H
 #define _MGC_INTERNAL_H
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
 #include <lustre_log.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index f1641645acae..c42ddd50b6e3 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -47,7 +47,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 /* class_put_type() */
 #include <obd_class.h>
 #include <obd_support.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index d3b25667bc3a..0712d795788a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 3b1d0961eebe..0a21a27c1a3a 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -60,7 +60,7 @@
 #include <linux/seq_file.h>
 #include <linux/kobject.h>
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lnet/lnetctl.h>
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 688a0428262d..55efd704c9e8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -41,7 +41,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <linux/module.h>
 #include <linux/processor.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index 54fc88206534..bb90e6c0011c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
index 6cf7a03f048f..8d14a0177a3f 100644
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ b/drivers/staging/lustre/lustre/obdclass/uuid.c
@@ -35,7 +35,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 9a078358188b..c417a0cd1c16 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -32,7 +32,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_ECHO
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 #include <obd_support.h>
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index dc25dd12d7d5..29f318403328 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -43,7 +43,7 @@
 #ifndef OSC_CL_INTERNAL_H
 #define OSC_CL_INTERNAL_H
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 /* osc_build_res_name() */
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index fe8ed0d0497a..388eb97e1548 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 /* fid_build_reg_res_name() */
 #include <lustre_fid.h>
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 64a3e4a2e05b..72d27856f355 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/sched/mm.h>
 
 #include <lustre_dlm.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/errno.c b/drivers/staging/lustre/lustre/ptlrpc/errno.c
index 54f0c36dc2bd..9985e0bf4b87 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/errno.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/errno.c
@@ -26,7 +26,7 @@
  * Copyright (c) 2013, Intel Corporation.
  */
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <lustre_errno.h>
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 130bacc2c891..d9d8d96f6605 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 # ifdef __mips64__
 #  include <linux/kernel.h>
 # endif
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 254488be7093..3d8a2e5d2a92 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -39,7 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 #include <lustre_log.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index bc4398b9bd1d..3c6f2f171e41 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -43,7 +43,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 #include <lustre_log.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 4847f9a90cc9..74a5fcf644e5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -41,7 +41,7 @@
 #include <obd_class.h>
 #include <lustre_net.h>
 #include <lprocfs_status.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 8251cbf2ad68..4876d07aed7d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -46,7 +46,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 #include <obd_support.h>
 #include <obd_class.h>
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index f73463ac401f..adf3b8c986e9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -41,7 +41,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <uapi/linux/lustre/lustre_fiemap.h>
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 1f7c18d1c95e..bff14fb778d2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -52,7 +52,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <lustre_net.h>
 #include <lustre_lib.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 2ea0a7ff87dd..004db1557a1a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -36,7 +36,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_support.h>
 #include <lustre_ha.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 256421465bcd..4af08b2492da 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/crypto.h>
 #include <linux/cred.h>
 #include <linux/key.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 625b9520d78f..1f35126124fc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 #include <obd_cksum.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 2389f9a8f534..4a37f6e1ac30 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/crypto.h>
 #include <linux/key.h>
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 2c8bad7b7877..fa247d351625 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index fd609b63d2de..c1c862ac0b53 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -35,7 +35,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_all.h>
 #include <linux/crypto.h>
 
 #include <obd.h>
