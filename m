From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:06 -0400
Subject: [lustre-devel] [PATCH 12/64 v2] staging: lustre: uapi: move
	lustre_ioctl.h to uapi directory
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move the header lustre_ioctl.h to proper uapi directory.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24568
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../{lustre/include => include/uapi/linux}/lustre/lustre_ioctl.h     | 5 ++---
 drivers/staging/lustre/lustre/llite/dir.c                            | 2 +-
 drivers/staging/lustre/lustre/llite/file.c                           | 2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c                      | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c                          | 2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c                          | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c                      | 2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c                   | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c          | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_config.c                  | 2 +-
 drivers/staging/lustre/lustre/obdecho/echo_client.c                  | 2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c                      | 2 +-
 12 files changed, 13 insertions(+), 14 deletions(-)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux}/lustre/lustre_ioctl.h (98%)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
similarity index 98%
rename from drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index 8585302..880dd92 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -29,13 +29,12 @@
 #define LUSTRE_IOCTL_H_
 
 #include <linux/types.h>
-#include "../../../include/linux/libcfs/libcfs.h"
-#include "lustre_idl.h"
+#include "../../../linux/libcfs/libcfs.h"
+#include "../../../../lustre/include/lustre/lustre_idl.h"
 
 #ifdef __KERNEL__
 # include <linux/ioctl.h>
 # include <linux/string.h>
-# include "../obd_support.h"
 #else /* __KERNEL__ */
 # include <malloc.h>
 # include <string.h>
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index dd592d9..4b46271 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -46,7 +46,7 @@
 
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_lib.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_fid.h"
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 215479a..71d1878 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -43,7 +43,7 @@
 #include <linux/sched.h>
 #include <linux/mount.h>
 #include "../include/lustre/ll_fiemap.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_swab.h"
 
 #include "../include/cl_object.h"
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 451e4fa..e7d5228 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -41,7 +41,7 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_ha.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lprocfs_status.h"
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 1c9ff24..ab77dbe 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -49,7 +49,7 @@
 #include "../include/lprocfs_status.h"
 #include "../include/cl_object.h"
 #include "../include/lustre_fid.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_kernelcomm.h"
 #include "lmv_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 8871624..8777d4b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -41,7 +41,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 
 #include "../include/lustre/lustre_idl.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 
 #include "../include/cl_object.h"
 #include "../include/lustre_dlm.h"
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index dc775bb..93fb195 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -45,7 +45,7 @@
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_acl.h"
 #include "../include/lustre_fid.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_kernelcomm.h"
 #include "../include/lustre_lmv.h"
 #include "../include/lustre_log.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 477d611..ed30333 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -40,7 +40,7 @@
 #include "../include/lprocfs_status.h"
 #include <linux/list.h>
 #include "../include/cl_object.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "llog_internal.h"
 
 struct obd_device *obd_devs[MAX_OBD_DEVICES];
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 092e68a..9f83345 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -65,7 +65,7 @@
 #include "../../include/obd_support.h"
 #include "../../include/obd_class.h"
 #include "../../include/lprocfs_status.h"
-#include "../../include/lustre/lustre_ioctl.h"
+#include "../../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../../include/lustre_ver.h"
 
 static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 6a7e7a7..2a93d67 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -38,7 +38,7 @@
 
 #include <linux/string.h>
 
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/llog_swab.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_log.h"
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 363d205..3f28db3 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -41,7 +41,7 @@
 #include "../include/cl_object.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_acl.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_net.h"
 
 #include "echo_internal.h"
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 922d0cb..e103d5a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -41,7 +41,7 @@
 
 #include "../include/lustre_ha.h"
 #include "../include/lprocfs_status.h"
-#include "../include/lustre/lustre_ioctl.h"
+#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_debug.h"
 #include "../include/lustre_obdo.h"
 #include "../include/lustre_param.h"
-- 
1.8.3.1
