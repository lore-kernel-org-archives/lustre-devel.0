From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 26/30] staging: lustre: remove libcfs_all
 from ptlrpc
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731336.24196.7585327613618183220.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Some files didn't need it at all, others just needed
one or two includes.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/errno.c       |    1 -
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |    2 --
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c    |    2 --
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |    3 ++-
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    3 ++-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 --
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    6 ++++--
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c   |    2 +-
 14 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/errno.c b/drivers/staging/lustre/lustre/ptlrpc/errno.c
index 9985e0bf4b87..c587fc86fcda 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/errno.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/errno.c
@@ -26,7 +26,6 @@
  * Copyright (c) 2013, Intel Corporation.
  */
 
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_errno.h>
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index d9d8d96f6605..130bacc2c891 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 # ifdef __mips64__
 #  include <linux/kernel.h>
 # endif
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 3d8a2e5d2a92..946d538121de 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -39,8 +39,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd_class.h>
 #include <lustre_log.h>
 #include <lustre_net.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index 3c6f2f171e41..b871d9e40a9e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -43,8 +43,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd_class.h>
 #include <lustre_log.h>
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 74a5fcf644e5..e09b86529c5d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -37,11 +37,12 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_cpu.h>
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
 #include <lprocfs_status.h>
-#include <linux/libcfs/libcfs_all.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 4876d07aed7d..ff630d94dd26 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -44,9 +44,10 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_cpu.h>
 #include <obd_support.h>
 #include <obd_class.h>
-#include <linux/libcfs/libcfs_all.h>
 #include "ptlrpc_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index adf3b8c986e9..6ac9bb570663 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -41,8 +41,6 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <uapi/linux/lustre/lustre_fiemap.h>
 
 #include <llog_swab.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index bff14fb778d2..531005411edf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -52,8 +52,10 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#include <linux/libcfs/libcfs_all.h>
-
+#include <linux/kthread.h>
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/libcfs/libcfs_string.h>
 #include <lustre_net.h>
 #include <lustre_lib.h>
 #include <lustre_ha.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 004db1557a1a..2ea0a7ff87dd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -36,7 +36,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 
 #include <obd_support.h>
 #include <lustre_ha.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 4af08b2492da..256421465bcd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <linux/crypto.h>
 #include <linux/cred.h>
 #include <linux/key.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 1f35126124fc..625b9520d78f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 
 #include <obd.h>
 #include <obd_cksum.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 4a37f6e1ac30..2389f9a8f534 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <linux/crypto.h>
 #include <linux/key.h>
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index fa247d351625..2c8bad7b7877 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index c1c862ac0b53..fd609b63d2de 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -35,7 +35,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <linux/crypto.h>
 
 #include <obd.h>
