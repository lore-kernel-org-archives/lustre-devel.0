From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:43 -0400
Subject: [lustre-devel] [PATCH 49/64 v2] staging: lustre: lmv: add include
	path to Makefile
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-50-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the lmv source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/Makefile       |  3 +++
 drivers/staging/lustre/lustre/lmv/lmv_fld.c      | 14 +++++++-------
 drivers/staging/lustre/lustre/lmv/lmv_intent.c   | 16 ++++++++--------
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |  6 +++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      | 18 +++++++++---------
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c    |  4 ++--
 6 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/Makefile b/drivers/staging/lustre/lustre/lmv/Makefile
index 1a24299..91c9911 100644
--- a/drivers/staging/lustre/lustre/lmv/Makefile
+++ b/drivers/staging/lustre/lustre/lmv/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += lmv.o
 lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index 1a7dd15..5937468 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -37,13 +37,13 @@
 #include <asm/div64.h>
 #include <linux/seq_file.h>
 
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_dlm.h"
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
+#include <obd_support.h>
+#include <lustre_fid.h>
+#include <lustre_lib.h>
+#include <lustre_net.h>
+#include <lustre_dlm.h>
+#include <obd_class.h>
+#include <lprocfs_status.h>
 #include "lmv_internal.h"
 
 int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 6b10bdd..22c247a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -37,14 +37,14 @@
 #include <asm/div64.h>
 #include <linux/seq_file.h>
 #include <linux/namei.h>
-#include "../include/lustre_intent.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_net.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_mdc.h"
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
+#include <lustre_intent.h>
+#include <obd_support.h>
+#include <lustre_lib.h>
+#include <lustre_net.h>
+#include <lustre_dlm.h>
+#include <lustre_mdc.h>
+#include <obd_class.h>
+#include <lprocfs_status.h>
 #include "lmv_internal.h"
 
 static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index ad109c0..a047523 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -33,9 +33,9 @@
 #ifndef _LMV_INTERNAL_H_
 #define _LMV_INTERNAL_H_
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../include/obd.h"
-#include "../include/lustre_lmv.h"
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <obd.h>
+#include <lustre_lmv.h>
 
 #define LMV_MAX_TGT_COUNT 128
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index f17221f..98537ca 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -41,15 +41,15 @@
 #include <linux/namei.h>
 #include <linux/uaccess.h>
 
-#include "../include/obd_support.h"
-#include "../include/lustre_net.h"
-#include "../include/obd_class.h"
-#include "../include/lustre_lmv.h"
-#include "../include/lprocfs_status.h"
-#include "../include/cl_object.h"
-#include "../include/lustre_fid.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../include/lustre_kernelcomm.h"
+#include <obd_support.h>
+#include <lustre_net.h>
+#include <obd_class.h>
+#include <lustre_lmv.h>
+#include <lprocfs_status.h>
+#include <cl_object.h>
+#include <lustre_fid.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+#include <lustre_kernelcomm.h>
 #include "lmv_internal.h"
 
 static int lmv_check_connect(struct obd_device *obd);
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 4c13e39..f16cfa4 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -34,8 +34,8 @@
 
 #include <linux/seq_file.h>
 #include <linux/statfs.h>
-#include "../include/lprocfs_status.h"
-#include "../include/obd_class.h"
+#include <lprocfs_status.h>
+#include <obd_class.h>
 #include "lmv_internal.h"
 
 static ssize_t numobd_show(struct kobject *kobj, struct attribute *attr,
-- 
1.8.3.1
