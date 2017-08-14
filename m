From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:19 -0400
Subject: [lustre-devel] [PATCH 51/64] staging: lustre: mdc: add include path
	to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-52-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the mdc source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/Makefile       |  3 +++
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c    |  4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c      |  4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c    | 22 ++++++++++----------
 drivers/staging/lustre/lustre/mdc/mdc_reint.c    |  4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c  | 26 ++++++++++++------------
 7 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/Makefile b/drivers/staging/lustre/lustre/mdc/Makefile
index 99ba9ff..c7bc335 100644
--- a/drivers/staging/lustre/lustre/mdc/Makefile
+++ b/drivers/staging/lustre/lustre/mdc/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += mdc.o
 mdc-y := mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 51a7047..f685137 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -32,8 +32,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/vfs.h>
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
+#include <obd_class.h>
+#include <lprocfs_status.h>
 #include "mdc_internal.h"
 
 static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index fecedc88..cbf0115 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -33,7 +33,7 @@
 #ifndef _MDC_INTERNAL_H
 #define _MDC_INTERNAL_H
 
-#include "../include/lustre_mdc.h"
+#include <lustre_mdc.h>
 
 void lprocfs_mdc_init_vars(struct lprocfs_static_vars *lvars);
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index bfd8fbe..ba13f089 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -31,8 +31,8 @@
  */
 
 #define DEBUG_SUBSYSTEM S_MDC
-#include "../include/lustre_net.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <lustre_net.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 #include "mdc_internal.h"
 
 static void set_mrc_cr_flags(struct mdt_rec_create *mrc, u64 flags)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 3eb66ce..b9bf440 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -32,17 +32,17 @@
 
 #define DEBUG_SUBSYSTEM S_MDC
 
-# include <linux/module.h>
-
-#include "../include/lustre_intent.h"
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_mdc.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_swab.h"
+#include <linux/module.h>
+
+#include <lustre_intent.h>
+#include <obd.h>
+#include <obd_class.h>
+#include <lustre_dlm.h>
+#include <lustre_fid.h>
+#include <lustre_mdc.h>
+#include <lustre_net.h>
+#include <lustre_req_layout.h>
+#include <lustre_swab.h>
 
 #include "mdc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 2287bd4..f45c91d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -35,9 +35,9 @@
 # include <linux/module.h>
 # include <linux/kernel.h>
 
-#include "../include/obd_class.h"
+#include <obd_class.h>
 #include "mdc_internal.h"
-#include "../include/lustre_fid.h"
+#include <lustre_fid.h>
 
 /* mdc_setattr does its own semaphore handling */
 static int mdc_reint(struct ptlrpc_request *request, int level)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 3556307..6ef8dde 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -38,19 +38,19 @@
 # include <linux/init.h>
 # include <linux/utsname.h>
 
-#include "../include/lustre_errno.h"
-#include "../include/cl_object.h"
-#include "../include/llog_swab.h"
-#include "../include/lprocfs_status.h"
-#include "../include/lustre_acl.h"
-#include "../include/lustre_fid.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_kernelcomm.h"
-#include "../include/lustre_lmv.h"
-#include "../include/lustre_log.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
-#include "../include/lustre_swab.h"
-#include "../include/obd_class.h"
+#include <lustre_errno.h>
+#include <cl_object.h>
+#include <llog_swab.h>
+#include <lprocfs_status.h>
+#include <lustre_acl.h>
+#include <lustre_fid.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_kernelcomm.h>
+#include <lustre_lmv.h>
+#include <lustre_log.h>
+#include <uapi/linux/lustre/lustre_param.h>
+#include <lustre_swab.h>
+#include <obd_class.h>
 
 #include "mdc_internal.h"
 
-- 
1.8.3.1
