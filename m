From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:41 -0400
Subject: [lustre-devel] [PATCH 47/64 v2] staging: lustre: ptlrpc: add
	include path to Makefile
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the ptlrpc/ldlm source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/interval_tree.c   |  6 +++---
 drivers/staging/lustre/lustre/ldlm/l_lock.c          |  6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c     | 12 ++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c      |  8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c  |  6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c        | 12 ++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c       |  8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c      |  6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c      |  6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c       |  8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c    |  8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c   |  6 +++---
 drivers/staging/lustre/lustre/ptlrpc/Makefile        |  3 +++
 drivers/staging/lustre/lustre/ptlrpc/client.c        | 12 ++++++------
 drivers/staging/lustre/lustre/ptlrpc/connection.c    |  6 +++---
 drivers/staging/lustre/lustre/ptlrpc/errno.c         |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/events.c        |  8 ++++----
 drivers/staging/lustre/lustre/ptlrpc/import.c        | 16 ++++++++--------
 drivers/staging/lustre/lustre/ptlrpc/layout.c        | 18 +++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c   |  8 ++++----
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c      |  6 +++---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c  | 12 ++++++------
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c        | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/nrs.c           | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c      |  6 +++---
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c  | 16 ++++++++--------
 drivers/staging/lustre/lustre/ptlrpc/pers.c          | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/pinger.c        |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c |  8 ++++----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c       | 18 +++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/recover.c       | 18 +++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/sec.c           | 16 ++++++++--------
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c      | 20 ++++++++++----------
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c    | 14 +++++++-------
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c        | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c     | 16 ++++++++--------
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c      | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c     | 10 +++++-----
 drivers/staging/lustre/lustre/ptlrpc/service.c       | 11 ++++++-----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c      |  8 ++++----
 40 files changed, 202 insertions(+), 198 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index 5bebd9a..19e285d 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -34,9 +34,9 @@
  * Author: Huang Wei <huangwei@clusterfs.com>
  * Author: Jay Xiong <jinshan.xiong@sun.com>
  */
-#include "../include/lustre_dlm.h"
-#include "../include/obd_support.h"
-#include "../include/interval_tree.h"
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <interval_tree.h>
 
 enum {
 	INTERVAL_RED = 0,
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index 3845f38..57fd84e 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -31,10 +31,10 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_lib.h"
+#include <lustre_dlm.h>
+#include <lustre_lib.h>
 
 /**
  * Lock a lock and its resource.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 08f97e2..2cc6dc2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -46,12 +46,12 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre_dlm.h"
-#include "../include/obd_support.h"
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_lib.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <obd.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
 #include "ldlm_internal.h"
 
 /* When a lock is cancelled by a client, the KMS may undergo change if this
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index b7f28b3..39433ac 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -52,10 +52,10 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../include/lustre_dlm.h"
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_lib.h"
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
 #include <linux/list.h>
 #include "ldlm_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
index ae37c36..fcb6e44 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
@@ -49,9 +49,9 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../include/lustre_dlm.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_lib.h"
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <lustre_lib.h>
 #include "ldlm_internal.h"
 
 void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 4dc7bae..22600c2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -39,12 +39,12 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_sec.h"
+#include <linux/libcfs/libcfs.h>
+#include <obd.h>
+#include <obd_class.h>
+#include <lustre_dlm.h>
+#include <lustre_net.h>
+#include <lustre_sec.h>
 #include "ldlm_internal.h"
 
 /* @priority: If non-zero, move the selected connection to the list head.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 181025d..b5d84f3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -37,10 +37,10 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre_intent.h"
-#include "../include/lustre_swab.h"
-#include "../include/obd_class.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_intent.h>
+#include <lustre_swab.h>
+#include <obd_class.h>
 #include "ldlm_internal.h"
 
 /* lock types */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index e0c3e5d..895d07d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -37,9 +37,9 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre_dlm.h"
-#include "../include/obd_class.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_dlm.h>
+#include <obd_class.h>
 #include <linux/list.h>
 #include "ldlm_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
index 862ea0a..1ca605f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
@@ -48,9 +48,9 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../include/lustre_dlm.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_lib.h"
+#include <lustre_dlm.h>
+#include <obd_support.h>
+#include <lustre_lib.h>
 
 #include "ldlm_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index cf3fc57..d77bf0b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -94,10 +94,10 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../include/lustre_dlm.h"
-#include "../include/cl_object.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
+#include <lustre_dlm.h>
+#include <cl_object.h>
+#include <obd_class.h>
+#include <obd_support.h>
 #include "ldlm_internal.h"
 
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 5e04f05..d96a304 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -57,10 +57,10 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../include/lustre_errno.h"
-#include "../include/lustre_dlm.h"
-#include "../include/obd_class.h"
-#include "../include/obd.h"
+#include <lustre_errno.h>
+#include <lustre_dlm.h>
+#include <obd_class.h>
+#include <obd.h>
 
 #include "ldlm_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 4e805e7..c2ddf73 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -36,9 +36,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_fid.h"
-#include "../include/obd_class.h"
+#include <lustre_dlm.h>
+#include <lustre_fid.h>
+#include <obd_class.h>
 #include "ldlm_internal.h"
 
 struct kmem_cache *ldlm_resource_slab, *ldlm_lock_slab;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/Makefile b/drivers/staging/lustre/lustre/ptlrpc/Makefile
index 24bbac1..a518001 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/Makefile
+++ b/drivers/staging/lustre/lustre/ptlrpc/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += ptlrpc.o
 LDLM := ../../lustre/ldlm/
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 977d7a6..b1d379a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -34,12 +34,12 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_ha.h"
-#include "../include/lustre_import.h"
-#include "../include/lustre_req_layout.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
+#include <lustre_ha.h>
+#include <lustre_import.h>
+#include <lustre_req_layout.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index 73a2dbb..cfdcbcec 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -31,9 +31,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/errno.c b/drivers/staging/lustre/lustre/ptlrpc/errno.c
index faad8d8..cb78836 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/errno.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/errno.c
@@ -25,8 +25,8 @@
  * Copyright (c) 2013, Intel Corporation.
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre_errno.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_errno.h>
 
 /*
  * The two translation tables below must define a one-to-one mapping between
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 978bdac..62951f1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -32,14 +32,14 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 # ifdef __mips64__
 #  include <linux/kernel.h>
 # endif
 
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_sec.h"
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lustre_sec.h>
 #include "ptlrpc_internal.h"
 
 struct lnet_handle_eq ptlrpc_eq_h;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index b19dac1..21f5289 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -36,14 +36,14 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../include/obd_support.h"
-#include "../include/lustre_ha.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_import.h"
-#include "../include/lustre_export.h"
-#include "../include/obd.h"
-#include "../include/obd_cksum.h"
-#include "../include/obd_class.h"
+#include <obd_support.h>
+#include <lustre_ha.h>
+#include <lustre_net.h>
+#include <lustre_import.h>
+#include <lustre_export.h>
+#include <obd.h>
+#include <obd_cksum.h>
+#include <obd_class.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 6624c02..85854d9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -46,18 +46,18 @@
 
 #include <linux/module.h>
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
-#include "../include/llog_swab.h"
-#include "../include/lustre_debug.h"
-#include "../include/lustre_swab.h"
-#include "../../include/uapi/linux/lustre/lustre_ver.h"
-#include "../include/obd.h"
-#include "../include/obd_support.h"
+#include <llog_swab.h>
+#include <lustre_debug.h>
+#include <lustre_swab.h>
+#include <uapi/linux/lustre/lustre_ver.h>
+#include <obd.h>
+#include <obd_support.h>
 
 /* struct ptlrpc_request, lustre_msg* */
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_acl.h"
+#include <lustre_req_layout.h>
+#include <lustre_acl.h>
 
 /*
  * RQFs (see below) refer to two struct req_msg_field arrays describing the
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 110d9f5..480c20a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -38,11 +38,11 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_class.h"
-#include "../include/lustre_log.h"
-#include "../include/lustre_net.h"
+#include <obd_class.h>
+#include <lustre_log.h>
+#include <lustre_net.h>
 #include <linux/list.h>
 
 #define LLOG_CLIENT_ENTRY(ctxt, imp) do {				\
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index bccdace..bc5aa7b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -42,10 +42,10 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_class.h"
-#include "../include/lustre_log.h"
+#include <obd_class.h>
+#include <lustre_log.h>
 #include <linux/list.h>
 
 int llog_initiator_connect(struct llog_ctxt *ctxt)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index ad2703b..1392ae9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -31,12 +31,12 @@
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
-#include "../include/obd_support.h"
-#include "../include/obd.h"
-#include "../include/lprocfs_status.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/lustre_net.h"
-#include "../include/obd_class.h"
+#include <obd_support.h>
+#include <obd.h>
+#include <lprocfs_status.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_net.h>
+#include <obd_class.h>
 #include "ptlrpc_internal.h"
 
 static struct ll_rpc_opcode {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index eddc192..12149fb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -31,11 +31,11 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../include/obd_support.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_lib.h"
-#include "../include/obd.h"
-#include "../include/obd_class.h"
+#include <obd_support.h>
+#include <lustre_net.h>
+#include <lustre_lib.h>
+#include <obd.h>
+#include <obd_class.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index ef19dbe..2969d8d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -36,11 +36,11 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lprocfs_status.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lprocfs_status.h>
+#include <linux/libcfs/libcfs.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index b123a93..df330e4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -43,9 +43,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <linux/libcfs/libcfs.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 5d68fa9..aad4ff1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -40,16 +40,16 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../../include/uapi/linux/lustre/lustre_fiemap.h"
+#include <uapi/linux/lustre/lustre_fiemap.h>
 
-#include "../include/llog_swab.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_swab.h"
-#include "../include/obd_cksum.h"
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
+#include <llog_swab.h>
+#include <lustre_net.h>
+#include <lustre_swab.h>
+#include <obd_cksum.h>
+#include <obd_support.h>
+#include <obd_class.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index df4994f..643388b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -32,11 +32,11 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_ha.h"
-#include "../include/lustre_import.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
+#include <lustre_ha.h>
+#include <lustre_import.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 5504fc2..e4de50e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -36,8 +36,8 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
+#include <obd_support.h>
+#include <obd_class.h>
 #include "ptlrpc_internal.h"
 
 struct mutex pinger_mutex;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index a70d584..38e488d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -32,10 +32,10 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_req_layout.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lustre_req_layout.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 59b5813..0e47682 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -51,15 +51,15 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include "../../include/linux/libcfs/libcfs.h"
-
-#include "../include/lustre_net.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_ha.h"
-#include "../include/obd_class.h"	/* for obd_zombie */
-#include "../include/obd_support.h"	/* for OBD_FAIL_CHECK */
-#include "../include/cl_object.h"	/* cl_env_{get,put}() */
-#include "../include/lprocfs_status.h"
+#include <linux/libcfs/libcfs.h>
+
+#include <lustre_net.h>
+#include <lustre_lib.h>
+#include <lustre_ha.h>
+#include <obd_class.h>		/* for obd_zombie */
+#include <obd_support.h>	/* for OBD_FAIL_CHECK */
+#include <cl_object.h>		/* cl_env_{get,put}() */
+#include <lprocfs_status.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 7b58545..72a19a3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -35,15 +35,15 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../../include/linux/libcfs/libcfs.h"
-
-#include "../include/obd_support.h"
-#include "../include/lustre_ha.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_import.h"
-#include "../include/lustre_export.h"
-#include "../include/obd.h"
-#include "../include/obd_class.h"
+#include <linux/libcfs/libcfs.h>
+
+#include <obd_support.h>
+#include <lustre_ha.h>
+#include <lustre_net.h>
+#include <lustre_import.h>
+#include <lustre_export.h>
+#include <obd.h>
+#include <obd_class.h>
 #include <linux/list.h>
 
 #include "ptlrpc_internal.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 366f2ce..cd7a539 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -36,19 +36,19 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/crypto.h>
 #include <linux/cred.h>
 #include <linux/key.h>
 #include <linux/sched/task.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_import.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_sec.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_net.h>
+#include <lustre_import.h>
+#include <lustre_dlm.h>
+#include <lustre_sec.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 128838a..059294a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -36,16 +36,16 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
-
-#include "../include/obd.h"
-#include "../include/obd_cksum.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_import.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_sec.h"
+#include <linux/libcfs/libcfs.h>
+
+#include <obd.h>
+#include <obd_cksum.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_net.h>
+#include <lustre_import.h>
+#include <lustre_dlm.h>
+#include <lustre_sec.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 9143441..0f4af66 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -32,16 +32,16 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/crypto.h>
 #include <linux/key.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_import.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
-#include "../include/lustre_sec.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_import.h>
+#include <uapi/linux/lustre/lustre_param.h>
+#include <lustre_sec.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 026bec7..d10a805 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -36,12 +36,12 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_sec.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lustre_sec.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index 07273f5..7792132 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -34,16 +34,16 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/crypto.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_import.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_sec.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_net.h>
+#include <lustre_import.h>
+#include <lustre_dlm.h>
+#include <lustre_sec.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 70a61e1..dc39a54 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -36,11 +36,11 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../include/obd_support.h"
-#include "../include/obd_cksum.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_sec.h"
+#include <obd_support.h>
+#include <obd_cksum.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lustre_sec.h>
 
 #include "ptlrpc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index c5e7a23..6aa9b65 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -36,11 +36,11 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include "../include/obd_support.h"
-#include "../include/obd_cksum.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_sec.h"
+#include <obd_support.h>
+#include <obd_cksum.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lustre_sec.h>
 #include "ptlrpc_internal.h"
 
 struct plain_sec {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index ca3d69e..155f6a4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -31,11 +31,12 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lu_object.h"
-#include "../../include/uapi/linux/lnet/lnet-types.h"
+
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lu_object.h>
+#include <uapi/linux/lnet/lnet-types.h>
 #include "ptlrpc_internal.h"
 
 /* The following are visible and mutable through /sys/module/ptlrpc */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 311c526..07b86a1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -35,10 +35,10 @@
 #include <linux/fs.h>
 #include <linux/posix_acl_xattr.h>
 
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_disk.h"
+#include <obd_support.h>
+#include <obd_class.h>
+#include <lustre_net.h>
+#include <lustre_disk.h>
 #include "ptlrpc_internal.h"
 
 void lustre_assert_wire_constants(void)
-- 
1.8.3.1
