From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 14:40:46 -0500
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: headers: sort headers
	affected by swab move
In-Reply-To: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480707650-24089-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

It was found if you sort the headers alphabetically
that it reduced patch conflicts. This patch sorts
the headers alphabetically and also place linux
header first, then uapi header and finally the
lustre kernel headers.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/16339
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   17 +++++++++--------
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    6 ++++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   11 ++++++-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    7 ++++---
 drivers/staging/lustre/lustre/obdclass/llog.c      |    2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    6 ++++--
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   14 ++++++--------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    7 ++++---
 8 files changed, 38 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index b236e93..63b0645 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -40,19 +40,20 @@
 #define DEBUG_SUBSYSTEM S_LOV
 #include "../../include/linux/libcfs/libcfs.h"
 
-#include "../include/obd_support.h"
-#include "../include/lustre/lustre_ioctl.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_net.h"
 #include "../include/lustre/lustre_idl.h"
+#include "../include/lustre/lustre_ioctl.h"
+
+#include "../include/cl_object.h"
 #include "../include/lustre_dlm.h"
+#include "../include/lustre_fid.h"
+#include "../include/lustre_lib.h"
 #include "../include/lustre_mds.h"
-#include "../include/obd_class.h"
+#include "../include/lustre_net.h"
+#include "../include/lustre_param.h"
 #include "../include/lustre_swab.h"
 #include "../include/lprocfs_status.h"
-#include "../include/lustre_param.h"
-#include "../include/cl_object.h"
-#include "../include/lustre_fid.h"
+#include "../include/obd_class.h"
+#include "../include/obd_support.h"
 
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 561b246..6c93d18 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -38,15 +38,17 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include "../include/lustre/lustre_idl.h"
+#include "../include/lustre/lustre_user.h"
+
 #include "../include/lustre_net.h"
 #include "../include/lustre_swab.h"
 #include "../include/obd.h"
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
-#include "../include/lustre/lustre_user.h"
 
-#include "lov_internal.h"
 #include "lov_cl_internal.h"
+#include "lov_internal.h"
 
 void lov_dump_lmm_common(int level, void *lmmp)
 {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 087c2cf..2cfd913 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -38,17 +38,18 @@
 # include <linux/init.h>
 # include <linux/utsname.h>
 
+#include "../include/cl_object.h"
 #include "../include/llog_swab.h"
+#include "../include/lprocfs_status.h"
 #include "../include/lustre_acl.h"
+#include "../include/lustre_fid.h"
 #include "../include/lustre/lustre_ioctl.h"
-#include "../include/obd_class.h"
+#include "../include/lustre_kernelcomm.h"
 #include "../include/lustre_lmv.h"
-#include "../include/lustre_fid.h"
-#include "../include/lprocfs_status.h"
-#include "../include/lustre_param.h"
 #include "../include/lustre_log.h"
-#include "../include/lustre_kernelcomm.h"
+#include "../include/lustre_param.h"
 #include "../include/lustre_swab.h"
+#include "../include/obd_class.h"
 
 #include "mdc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index b5370f6..6894d4c 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -38,12 +38,13 @@
 #define D_MGC D_CONFIG /*|D_WARNING*/
 
 #include <linux/module.h>
-#include "../include/obd_class.h"
-#include "../include/lustre_dlm.h"
+
 #include "../include/lprocfs_status.h"
-#include "../include/lustre_log.h"
+#include "../include/lustre_dlm.h"
 #include "../include/lustre_disk.h"
+#include "../include/lustre_log.h"
 #include "../include/lustre_swab.h"
+#include "../include/obd_class.h"
 
 #include "mgc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 073abe3..1f6609e 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -44,8 +44,8 @@
 #define DEBUG_SUBSYSTEM S_LOG
 
 #include "../include/llog_swab.h"
-#include "../include/obd_class.h"
 #include "../include/lustre_log.h"
+#include "../include/obd_class.h"
 #include "llog_internal.h"
 
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index ea68b6d..0a55d79 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -35,13 +35,15 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
-#include "../include/obd_class.h"
+
 #include <linux/string.h>
+
 #include "../include/lustre/lustre_ioctl.h"
 #include "../include/llog_swab.h"
-#include "../include/lustre_log.h"
 #include "../include/lprocfs_status.h"
+#include "../include/lustre_log.h"
 #include "../include/lustre_param.h"
+#include "../include/obd_class.h"
 
 #include "llog_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index eba7098..cc95c09 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -48,23 +48,21 @@
 
 #include <linux/module.h>
 
-/* LUSTRE_VERSION_CODE */
-#include "../include/lustre_ver.h"
-
-#include "../include/obd_support.h"
-/* lustre_swab_mdt_body */
 #include "../include/lustre/lustre_idl.h"
-/* obd2cli_tgt() (required by DEBUG_REQ()) */
+
+#include "../include/llog_swab.h"
+#include "../include/lustre_debug.h"
+#include "../include/lustre_swab.h"
+#include "../include/lustre_ver.h"
 #include "../include/obd.h"
+#include "../include/obd_support.h"
 
 /* __REQ_LAYOUT_USER__ */
 #endif
-#include "../include/llog_swab.h"
 /* struct ptlrpc_request, lustre_msg* */
 #include "../include/lustre_req_layout.h"
 #include "../include/lustre_acl.h"
 #include "../include/lustre_debug.h"
-#include "../include/lustre_swab.h"
 
 /*
  * RQFs (see below) refer to two struct req_msg_field arrays describing the
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 1178caa..13f00b7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -42,13 +42,14 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
+#include "../include/lustre/ll_fiemap.h"
+
 #include "../include/llog_swab.h"
-#include "../include/obd_support.h"
-#include "../include/obd_class.h"
 #include "../include/lustre_net.h"
 #include "../include/lustre_swab.h"
 #include "../include/obd_cksum.h"
-#include "../include/lustre/ll_fiemap.h"
+#include "../include/obd_support.h"
+#include "../include/obd_class.h"
 
 #include "ptlrpc_internal.h"
 
-- 
1.7.1
