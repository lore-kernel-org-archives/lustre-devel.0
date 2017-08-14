From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:21 -0400
Subject: [lustre-devel] [PATCH 53/64] staging: lustre: obdclass: add include
	path to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-54-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the obdclass source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/Makefile      |  3 +++
 drivers/staging/lustre/lustre/obdclass/cl_io.c       |  8 ++++----
 drivers/staging/lustre/lustre/obdclass/cl_lock.c     |  8 ++++----
 drivers/staging/lustre/lustre/obdclass/cl_object.c   | 14 +++++++-------
 drivers/staging/lustre/lustre/obdclass/cl_page.c     |  8 ++++----
 drivers/staging/lustre/lustre/obdclass/class_obd.c   | 14 +++++++-------
 drivers/staging/lustre/lustre/obdclass/debug.c       |  6 +++---
 drivers/staging/lustre/lustre/obdclass/genops.c      |  6 +++---
 drivers/staging/lustre/lustre/obdclass/kernelcomm.c  |  4 ++--
 drivers/staging/lustre/lustre/obdclass/linkea.c      |  6 +++---
 .../lustre/lustre/obdclass/linux/linux-module.c      | 14 +++++++-------
 .../lustre/lustre/obdclass/linux/linux-sysctl.c      |  6 +++---
 drivers/staging/lustre/lustre/obdclass/llog.c        |  6 +++---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c    |  2 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h   |  2 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c    |  4 ++--
 drivers/staging/lustre/lustre/obdclass/llog_swab.c   |  4 ++--
 .../lustre/lustre/obdclass/lprocfs_counters.c        |  4 ++--
 .../staging/lustre/lustre/obdclass/lprocfs_status.c  |  6 +++---
 drivers/staging/lustre/lustre/obdclass/lu_object.c   | 20 ++++++++++----------
 drivers/staging/lustre/lustre/obdclass/lu_ref.c      | 10 +++++-----
 .../staging/lustre/lustre/obdclass/lustre_handles.c  |  6 +++---
 drivers/staging/lustre/lustre/obdclass/lustre_peer.c | 14 +++++++-------
 drivers/staging/lustre/lustre/obdclass/obd_config.c  | 12 ++++++------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c   | 14 +++++++-------
 drivers/staging/lustre/lustre/obdclass/obdo.c        |  6 +++---
 drivers/staging/lustre/lustre/obdclass/statfs_pack.c |  8 ++++----
 drivers/staging/lustre/lustre/obdclass/uuid.c        |  6 +++---
 28 files changed, 112 insertions(+), 109 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index af570c0..fa0ad654 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
 obdclass-y := linux/linux-module.o linux/linux-sysctl.o \
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index ee7d677..2a70e21 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -37,12 +37,12 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_fid.h>
 #include <linux/list.h>
 #include <linux/sched.h>
-#include "../include/cl_object.h"
+#include <cl_object.h>
 #include "cl_internal.h"
 
 /*****************************************************************************
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index a343e3a..20e6405 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -37,11 +37,11 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_fid.h>
 #include <linux/list.h>
-#include "../include/cl_object.h"
+#include <cl_object.h>
 #include "cl_internal.h"
 
 static void cl_lock_trace0(int level, const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 08e55d4..95c7fa3 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -46,15 +46,15 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 /* class_put_type() */
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_fid.h>
 #include <linux/list.h>
-#include "../../include/linux/libcfs/libcfs_hash.h"	/* for cfs_hash stuff */
-#include "../include/cl_object.h"
-#include "../include/lu_object.h"
+#include <linux/libcfs/libcfs_hash.h>	/* for cfs_hash stuff */
+#include <cl_object.h>
+#include <lu_object.h>
 #include "cl_internal.h"
 
 static struct kmem_cache *cl_env_kmem;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 6b8c41b..3dc084c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -37,12 +37,12 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
+#include <linux/libcfs/libcfs.h>
+#include <obd_class.h>
+#include <obd_support.h>
 #include <linux/list.h>
 
-#include "../include/cl_object.h"
+#include <cl_object.h>
 #include "cl_internal.h"
 
 static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index dedad65..57c84e8 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -33,14 +33,14 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 # include <linux/atomic.h>
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lnet/lnetctl.h"
-#include "../include/lustre_debug.h"
-#include "../include/lprocfs_status.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <uapi/linux/lnet/lnetctl.h>
+#include <lustre_debug.h>
+#include <lprocfs_status.h>
 #include <linux/list.h>
-#include "../include/cl_object.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
+#include <cl_object.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
 #include "llog_internal.h"
 
 struct obd_device *obd_devs[MAX_OBD_DEVICES];
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index 0bd4ad2..7964cad 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -38,9 +38,9 @@
 
 #include <asm/unaligned.h>
 
-#include "../include/obd_support.h"
-#include "../include/lustre_debug.h"
-#include "../include/lustre_net.h"
+#include <obd_support.h>
+#include <lustre_debug.h>
+#include <lustre_net.h>
 
 #define LPDS sizeof(__u64)
 int block_debug_setup(void *addr, int len, __u64 off, __u64 id)
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index fa0d38d..739bfb9 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -36,9 +36,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
-#include "../include/lustre_kernelcomm.h"
+#include <obd_class.h>
+#include <lprocfs_status.h>
+#include <lustre_kernelcomm.h>
 
 spinlock_t obd_types_lock;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index a0f65c4..8f0707a 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -38,8 +38,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 #define D_KUC D_OTHER
 
-#include "../include/obd_support.h"
-#include "../include/lustre_kernelcomm.h"
+#include <obd_support.h>
+#include <lustre_kernelcomm.h>
 
 /**
  * libcfs_kkuc_msg_put - send an message from kernel to userspace
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index d3e754a..9af86d3 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -26,9 +26,9 @@
  * Author: Di Wang <di.wang@intel.com>
  */
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/obd.h"
-#include "../include/lustre_linkea.h"
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <obd.h>
+#include <lustre_linkea.h>
 
 int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 94af257..6df9111 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -60,13 +60,13 @@
 #include <linux/seq_file.h>
 #include <linux/kobject.h>
 
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "../../../include/uapi/linux/lnet/lnetctl.h"
-#include "../../include/obd_support.h"
-#include "../../include/obd_class.h"
-#include "../../include/lprocfs_status.h"
-#include "../../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../../../include/uapi/linux/lustre/lustre_ver.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lnet/lnetctl.h>
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lprocfs_status.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <uapi/linux/lustre/lustre_ver.h>
 
 #define OBD_MAX_IOCTL_BUFFER	8192
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 814334b..e92cccc 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -43,9 +43,9 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/obd_support.h"
-#include "../../include/lprocfs_status.h"
-#include "../../include/obd_class.h"
+#include <obd_support.h>
+#include <lprocfs_status.h>
+#include <obd_class.h>
 
 struct static_lustre_uintvalue_attr {
 	struct {
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 736ea10..98021a2 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -43,9 +43,9 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../include/llog_swab.h"
-#include "../include/lustre_log.h"
-#include "../include/obd_class.h"
+#include <llog_swab.h>
+#include <lustre_log.h>
+#include <obd_class.h>
 #include "llog_internal.h"
 
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index 8f1533c..8fa9691 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -44,7 +44,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../include/obd_class.h"
+#include <obd_class.h>
 
 #include "llog_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index 21a93c7..8de90bc 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -33,7 +33,7 @@
 #ifndef __LLOG_INTERNAL_H__
 #define __LLOG_INTERNAL_H__
 
-#include "../include/lustre_log.h"
+#include <lustre_log.h>
 
 struct llog_process_info {
 	struct llog_handle *lpi_loghandle;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 8574ad4..3c42de9 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -32,8 +32,8 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../include/obd_class.h"
-#include "../include/lustre_log.h"
+#include <obd_class.h>
+#include <lustre_log.h>
 #include "llog_internal.h"
 
 /* helper functions for calling the llog obd methods */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 016046d..d2d3114 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -38,8 +38,8 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../include/llog_swab.h"
-#include "../include/lustre_log.h"
+#include <llog_swab.h>
+#include <lustre_log.h>
 
 static void print_llogd_body(struct llogd_body *d)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
index 13aca5b..e482988 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
@@ -38,8 +38,8 @@
  */
 
 #include <linux/module.h>
-#include "../include/lprocfs_status.h"
-#include "../include/obd_support.h"
+#include <lprocfs_status.h>
+#include <obd_support.h>
 
 void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index b56a343..e79485b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -36,9 +36,9 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <obd_class.h>
+#include <lprocfs_status.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 #include <linux/seq_file.h>
 #include <linux/ctype.h>
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index bb9d514..304e987 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -40,19 +40,19 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-# include <linux/module.h>
+#include <linux/module.h>
 
 /* hash_long() */
-#include "../../include/linux/libcfs/libcfs_hash.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_disk.h"
-#include "../include/lustre_fid.h"
-#include "../include/lu_object.h"
-#include "../include/cl_object.h"
-#include "../include/lu_ref.h"
+#include <linux/libcfs/libcfs_hash.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_disk.h>
+#include <lustre_fid.h>
+#include <lu_object.h>
+#include <cl_object.h>
+#include <lu_ref.h>
 #include <linux/list.h>
 
 enum {
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index e9f6040..fa690b2 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -38,9 +38,9 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lu_ref.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lu_ref.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index c9445e5..e1273c9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -36,9 +36,9 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../include/obd_support.h"
-#include "../include/lustre_handles.h"
-#include "../include/lustre_lib.h"
+#include <obd_support.h>
+#include <lustre_handles.h>
+#include <lustre_lib.h>
 
 static __u64 handle_base;
 #define HANDLE_INCR 7
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index ffa740a..2798d35 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -32,13 +32,13 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../include/obd.h"
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_ha.h"
-#include "../include/lustre_net.h"
-#include "../include/lprocfs_status.h"
+#include <obd.h>
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
+#include <lustre_ha.h>
+#include <lustre_net.h>
+#include <lprocfs_status.h>
 
 #define NIDS_MAX	32
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 32ffa25..94a940f 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -38,12 +38,12 @@
 
 #include <linux/string.h>
 
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/llog_swab.h"
-#include "../include/lprocfs_status.h"
-#include "../include/lustre_log.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
-#include "../include/obd_class.h"
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <llog_swab.h>
+#include <lprocfs_status.h>
+#include <lustre_log.h>
+#include <uapi/linux/lustre/lustre_param.h>
+#include <obd_class.h>
 
 #include "llog_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 4e609b5..1256034 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -40,13 +40,13 @@
 #define D_MOUNT (D_SUPER | D_CONFIG/*|D_WARNING */)
 #define PRINT_CMD CDEBUG
 
-#include "../include/obd.h"
-#include "../include/lustre_compat.h"
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/lustre_log.h"
-#include "../include/lustre_disk.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
+#include <obd.h>
+#include <lustre_compat.h>
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_log.h>
+#include <lustre_disk.h>
+#include <uapi/linux/lustre/lustre_param.h>
 
 static int (*client_fill_super)(struct super_block *sb,
 				struct vfsmount *mnt);
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index be61460..7083f87 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -38,9 +38,9 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/lustre_obdo.h"
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_obdo.h>
 
 void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
index 4bad1fa..89abea2 100644
--- a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
+++ b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
@@ -37,10 +37,10 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/statfs.h>
-#include "../include/lustre_export.h"
-#include "../include/lustre_net.h"
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
+#include <lustre_export.h>
+#include <lustre_net.h>
+#include <obd_support.h>
+#include <obd_class.h>
 
 void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
index abd9b1a..9b1872b 100644
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ b/drivers/staging/lustre/lustre/obdclass/uuid.c
@@ -34,10 +34,10 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
+#include <obd_support.h>
+#include <obd_class.h>
 
 void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
 {
-- 
1.8.3.1
