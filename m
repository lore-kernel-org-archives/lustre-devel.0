From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:16 -0400
Subject: [lustre-devel] [PATCH 48/64] staging: lustre: llite: add include
	path to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-49-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the llite source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/Makefile       |  3 ++
 drivers/staging/lustre/lustre/llite/dcache.c       |  6 ++--
 drivers/staging/lustre/lustre/llite/dir.c          | 16 +++++-----
 drivers/staging/lustre/lustre/llite/file.c         | 10 +++----
 drivers/staging/lustre/lustre/llite/glimpse.c      | 16 +++++-----
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 34 +++++++++++-----------
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  8 ++---
 .../staging/lustre/lustre/llite/llite_internal.h   | 20 ++++++-------
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 18 ++++++------
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  4 +--
 drivers/staging/lustre/lustre/llite/namei.c        |  6 ++--
 drivers/staging/lustre/lustre/llite/range_lock.c   |  2 +-
 drivers/staging/lustre/lustre/llite/range_lock.h   |  4 +--
 drivers/staging/lustre/lustre/llite/rw.c           |  2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  4 +--
 drivers/staging/lustre/lustre/llite/super25.c      |  6 ++--
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  4 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  4 +--
 drivers/staging/lustre/lustre/llite/xattr.c        |  4 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  4 +--
 23 files changed, 92 insertions(+), 89 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 322d4fa..ef7adef 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index d38cb33..3670fca 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -36,9 +36,9 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_support.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/lustre_dlm.h"
+#include <obd_support.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_dlm.h>
 
 #include "llite_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4b46271..1db3e7f 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -44,14 +44,14 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_kernelcomm.h"
-#include "../include/lustre_swab.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_lib.h>
+#include <lustre_dlm.h>
+#include <lustre_fid.h>
+#include <lustre_kernelcomm.h>
+#include <lustre_swab.h>
 
 #include "llite_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index adffc29..2c30e42 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -37,16 +37,16 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LLITE
-#include "../include/lustre_dlm.h"
+#include <lustre_dlm.h>
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/sched.h>
 #include <linux/mount.h>
-#include "../../include/uapi/linux/lustre/lustre_fiemap.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_swab.h"
+#include <uapi/linux/lustre/lustre_fiemap.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_swab.h>
 
-#include "../include/cl_object.h"
+#include <cl_object.h>
 #include "llite_internal.h"
 
 static int
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 0143112..34c2cfe 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -36,18 +36,18 @@
  *   Author: Oleg Drokin <oleg.drokin@sun.com>
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/obd.h"
+#include <linux/libcfs/libcfs.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <obd.h>
 
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_mdc.h"
+#include <lustre_dlm.h>
+#include <lustre_mdc.h>
 #include <linux/pagemap.h>
 #include <linux/file.h>
 
-#include "../include/cl_object.h"
-#include "../llite/llite_internal.h"
+#include <cl_object.h>
+#include "llite_internal.h"
 
 static const struct cl_lock_descr whole_file = {
 	.cld_start = 0,
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 75e4b35..d2392e4 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -37,23 +37,23 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../../include/linux/libcfs/libcfs.h"
-# include <linux/fs.h>
-# include <linux/sched.h>
-# include <linux/mm.h>
-# include <linux/quotaops.h>
-# include <linux/highmem.h>
-# include <linux/pagemap.h>
-# include <linux/rbtree.h>
-
-#include "../include/obd.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_mdc.h"
-#include "../include/cl_object.h"
-
-#include "../llite/llite_internal.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/quotaops.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/rbtree.h>
+
+#include <obd.h>
+#include <obd_support.h>
+#include <lustre_fid.h>
+#include <lustre_dlm.h>
+#include <lustre_mdc.h>
+#include <cl_object.h>
+
+#include "llite_internal.h"
 
 /*
  * ccc_ prefix stands for "Common Client Code".
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 7f7f3f1..422f410 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -34,10 +34,10 @@
  *
  */
 #define DEBUG_SUBSYSTEM S_LLITE
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/obd.h"
-#include "../include/cl_object.h"
+#include <obd_class.h>
+#include <obd_support.h>
+#include <obd.h>
+#include <cl_object.h>
 
 #include "llite_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index a7f0d51..0287c75 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -32,18 +32,18 @@
 
 #ifndef LLITE_INTERNAL_H
 #define LLITE_INTERNAL_H
-#include "../include/lustre_debug.h"
-#include "../../include/uapi/linux/lustre/lustre_ver.h"
-#include "../include/lustre_disk.h"	/* for s2sbi */
-#include "../include/lustre_linkea.h"
+#include <lustre_debug.h>
+#include <uapi/linux/lustre/lustre_ver.h>
+#include <lustre_disk.h>	/* for s2sbi */
+#include <lustre_linkea.h>
 
 /* for struct cl_lock_descr and struct cl_io */
-#include "../include/lustre_patchless_compat.h"
-#include "../include/lustre_compat.h"
-#include "../include/cl_object.h"
-#include "../include/lustre_lmv.h"
-#include "../include/lustre_mdc.h"
-#include "../include/lustre_intent.h"
+#include <lustre_patchless_compat.h>
+#include <lustre_compat.h>
+#include <cl_object.h>
+#include <lustre_lmv.h>
+#include <lustre_mdc.h>
+#include <lustre_intent.h>
 #include <linux/compat.h>
 #include <linux/namei.h>
 #include <linux/xattr.h>
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 3ab3a63..d855129 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -41,15 +41,15 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_ha.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lprocfs_status.h"
-#include "../include/lustre_disk.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
-#include "../include/lustre_log.h"
-#include "../include/cl_object.h"
-#include "../include/obd_cksum.h"
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_ha.h>
+#include <lustre_dlm.h>
+#include <lprocfs_status.h>
+#include <lustre_disk.h>
+#include <uapi/linux/lustre/lustre_param.h>
+#include <lustre_log.h>
+#include <cl_object.h>
+#include <obd_cksum.h>
 #include "llite_internal.h"
 
 struct kmem_cache *ll_file_data_slab;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index aeae667..e3bd2d1 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -31,9 +31,9 @@
  */
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lprocfs_status.h"
+#include <lprocfs_status.h>
 #include <linux/seq_file.h>
-#include "../include/obd_support.h"
+#include <obd_support.h>
 
 #include "llite_internal.h"
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 8dff523..1fd31e7 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -40,9 +40,9 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_dlm.h"
+#include <obd_support.h>
+#include <lustre_fid.h>
+#include <lustre_dlm.h>
 #include "llite_internal.h"
 
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index 3f232cd..a32598b 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -34,7 +34,7 @@
  * Author: Bobi Jam <bobijam.xu@intel.com>
  */
 #include "range_lock.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 /**
  * Initialize a range lock tree
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index 779091c..1e1519b 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -36,8 +36,8 @@
 #ifndef _RANGE_LOCK_H
 #define _RANGE_LOCK_H
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/interval_tree.h"
+#include <linux/libcfs/libcfs.h>
+#include <interval_tree.h>
 
 struct range_lock {
 	struct interval_node	rl_node;
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 166455e..e720905 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -51,7 +51,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_cksum.h"
+#include <obd_cksum.h>
 #include "llite_internal.h"
 
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 9bbca01..ea9d59f 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -38,8 +38,8 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_support.h"
-#include "../include/lustre_dlm.h"
+#include <obd_support.h>
+#include <lustre_dlm.h>
 #include "llite_internal.h"
 
 #define SA_OMITTED_ENTRY_MAX 8ULL
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 56f4b10..0da4af8 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -34,11 +34,11 @@
 
 #include <linux/module.h>
 #include <linux/types.h>
-#include "../include/lustre_ha.h"
-#include "../include/lustre_dlm.h"
+#include <lustre_ha.h>
+#include <lustre_dlm.h>
 #include <linux/init.h>
 #include <linux/fs.h>
-#include "../include/lprocfs_status.h"
+#include <lprocfs_status.h>
 #include "llite_internal.h"
 
 static struct kmem_cache *ll_inode_cachep;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 2b60699..f9d9a16 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd.h"
+#include <obd.h>
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 53ff46c..adce0ff 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -37,8 +37,8 @@
 #ifndef VVP_INTERNAL_H
 #define VVP_INTERNAL_H
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/cl_object.h"
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <cl_object.h>
 
 enum obd_notify_event;
 struct inode;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index c5ba265..c83853f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd.h"
+#include <obd.h>
 
 #include "llite_internal.h"
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index 07eb26c..e522f7c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -36,7 +36,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_support.h"
+#include <obd_support.h>
 
 #include "vvp_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 9bfd72e..3953750 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -36,9 +36,9 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd.h"
+#include <obd.h>
 
 #include "llite_internal.h"
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 48bad7d..0be5562 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -38,8 +38,8 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd_support.h"
-#include "../include/lustre_dlm.h"
+#include <obd_support.h>
+#include <lustre_dlm.h>
 
 #include "llite_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index fa11dd5..80ee392 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -12,8 +12,8 @@
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
-#include "../include/obd_support.h"
-#include "../include/lustre_dlm.h"
+#include <obd_support.h>
+#include <lustre_dlm.h>
 #include "llite_internal.h"
 
 /* If we ever have hundreds of extended attributes, we might want to consider
-- 
1.8.3.1
