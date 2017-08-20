From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:12 -0400
Subject: [lustre-devel] [PATCH 18/64 v2] staging: lustre: uapi: move
	lustre_param.h to uapi directory
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move the header lustre_param.h to proper uapi directory.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24325
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/{lustre/include => include/uapi/linux/lustre}/lustre_param.h | 0
 drivers/staging/lustre/lustre/llite/llite_lib.c                         | 2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c                             | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c                         | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_config.c                     | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c                      | 2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c                       | 2 +-
 8 files changed, 7 insertions(+), 7 deletions(-)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux/lustre}/lustre_param.h (100%)

diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
similarity index 100%
rename from drivers/staging/lustre/lustre/include/lustre_param.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e7d5228..3ab3a63 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -46,7 +46,7 @@
 #include "../include/lustre_dlm.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_disk.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 #include "../include/lustre_log.h"
 #include "../include/cl_object.h"
 #include "../include/obd_cksum.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 8777d4b..475bf7e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -49,7 +49,7 @@
 #include "../include/lustre_lib.h"
 #include "../include/lustre_mds.h"
 #include "../include/lustre_net.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 #include "../include/lustre_swab.h"
 #include "../include/lprocfs_status.h"
 #include "../include/obd_class.h"
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 93fb195..4dcf3902 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -49,7 +49,7 @@
 #include "../include/lustre_kernelcomm.h"
 #include "../include/lustre_lmv.h"
 #include "../include/lustre_log.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 #include "../include/lustre_swab.h"
 #include "../include/obd_class.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 2a93d67..783f9e0 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -42,7 +42,7 @@
 #include "../include/llog_swab.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_log.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 #include "../include/obd_class.h"
 
 #include "llog_internal.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 8e0d4b1..555e67e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -46,7 +46,7 @@
 #include "../include/lustre/lustre_user.h"
 #include "../include/lustre_log.h"
 #include "../include/lustre_disk.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 
 static int (*client_fill_super)(struct super_block *sb,
 				struct vfsmount *mnt);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e103d5a..453a59a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -44,7 +44,7 @@
 #include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_debug.h"
 #include "../include/lustre_obdo.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 #include "../include/lustre_fid.h"
 #include "../include/obd_class.h"
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 2181a85..bb953d4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -39,7 +39,7 @@
 #include "../include/obd.h"
 #include "../include/obd_support.h"
 #include "../include/lustre_import.h"
-#include "../include/lustre_param.h"
+#include "../../include/uapi/linux/lustre/lustre_param.h"
 #include "../include/lustre_sec.h"
 
 #include "ptlrpc_internal.h"
-- 
1.8.3.1
