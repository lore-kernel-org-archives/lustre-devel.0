From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:23 -0400
Subject: [lustre-devel] [PATCH 55/64] staging: lustre: osc: add include path
	to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-56-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the osc source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/Makefile         |  3 ++
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  6 ++--
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  6 ++--
 drivers/staging/lustre/lustre/osc/osc_dev.c        |  2 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  4 +--
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 32 +++++++++++-----------
 9 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/Makefile b/drivers/staging/lustre/lustre/osc/Makefile
index 37cdeea..30dec90 100644
--- a/drivers/staging/lustre/lustre/osc/Makefile
+++ b/drivers/staging/lustre/lustre/osc/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += osc.o
 osc-y := osc_request.o osc_dev.o osc_object.o \
 	 osc_page.o osc_lock.o osc_io.o osc_quota.o osc_cache.o lproc_osc.o
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 6e0fd15..ae13eb055 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -32,9 +32,9 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/statfs.h>
-#include "../include/obd_cksum.h"
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
+#include <obd_cksum.h>
+#include <obd_class.h>
+#include <lprocfs_status.h>
 #include <linux/seq_file.h>
 #include "osc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 270212f..35bdbfb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -42,11 +42,11 @@
 #ifndef OSC_CL_INTERNAL_H
 #define OSC_CL_INTERNAL_H
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd.h"
+#include <obd.h>
 /* osc_build_res_name() */
-#include "../include/cl_object.h"
+#include <cl_object.h>
 #include "osc_internal.h"
 
 /** \defgroup osc osc
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index c5d62ae..cf7b887 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_OSC
 
 /* class_name2obd() */
-#include "../include/obd_class.h"
+#include <obd_class.h>
 
 #include "osc_cl_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 13a40f6..a536908 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -99,7 +99,7 @@ struct osc_cache_waiter {
 /*
  * cl integration.
  */
-#include "../include/cl_object.h"
+#include <cl_object.h>
 
 extern struct ptlrpc_request_set *PTLRPCD_SET;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index cbab800..f7969e3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -37,7 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include "../include/lustre_obdo.h"
+#include <lustre_obdo.h>
 
 #include "osc_cl_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 940c10c..b4f1f74 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -37,9 +37,9 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 /* fid_build_reg_res_name() */
-#include "../include/lustre_fid.h"
+#include <lustre_fid.h>
 
 #include "osc_cl_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index fed4da6..a6118f8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -23,7 +23,7 @@
  * Code originally extracted from quota directory
  */
 
-#include "../include/obd_class.h"
+#include <obd_class.h>
 #include "osc_internal.h"
 
 static inline struct osc_quota_info *osc_oqi_alloc(u32 id)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index af96ac5..4c68c42 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -32,22 +32,22 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include "../../include/linux/libcfs/libcfs.h"
-
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_net.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/obd_cksum.h"
-
-#include "../include/lustre_ha.h"
-#include "../include/lprocfs_status.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_debug.h"
-#include "../include/lustre_obdo.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
-#include "../include/lustre_fid.h"
-#include "../include/obd_class.h"
-#include "../include/obd.h"
+#include <linux/libcfs/libcfs.h>
+
+#include <lustre_dlm.h>
+#include <lustre_net.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <obd_cksum.h>
+
+#include <lustre_ha.h>
+#include <lprocfs_status.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_debug.h>
+#include <lustre_obdo.h>
+#include <uapi/linux/lustre/lustre_param.h>
+#include <lustre_fid.h>
+#include <obd_class.h>
+#include <obd.h>
 #include "osc_internal.h"
 #include "osc_cl_internal.h"
 
-- 
1.8.3.1
