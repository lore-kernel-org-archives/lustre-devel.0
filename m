From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:20 -0400
Subject: [lustre-devel] [PATCH 52/64] staging: lustre: mgc: add include path
	to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-53-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the mgc source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mgc/Makefile       |  3 +++
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c    |  4 ++--
 drivers/staging/lustre/lustre/mgc/mgc_internal.h | 10 +++++-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c  | 12 ++++++------
 4 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/Makefile b/drivers/staging/lustre/lustre/mgc/Makefile
index 8ea29a8..8abf108 100644
--- a/drivers/staging/lustre/lustre/mgc/Makefile
+++ b/drivers/staging/lustre/lustre/mgc/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += mgc.o
 mgc-y := mgc_request.o lproc_mgc.o
diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
index 0735220..2ec2d7f 100644
--- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
+++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
@@ -32,8 +32,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/vfs.h>
-#include "../include/obd_class.h"
-#include "../include/lprocfs_status.h"
+#include <obd_class.h>
+#include <lprocfs_status.h>
 #include "mgc_internal.h"
 
 LPROC_SEQ_FOPS_RO_TYPE(mgc, connect_flags);
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 8cb6758..7a2f2b7 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -33,11 +33,11 @@
 #ifndef _MGC_INTERNAL_H
 #define _MGC_INTERNAL_H
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_log.h"
-#include "../include/lustre_export.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_lib.h>
+#include <lustre_dlm.h>
+#include <lustre_log.h>
+#include <lustre_export.h>
 
 void lprocfs_mgc_init_vars(struct lprocfs_static_vars *lvars);
 int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data);
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 3bead6a..f0da546 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -39,12 +39,12 @@
 
 #include <linux/module.h>
 
-#include "../include/lprocfs_status.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_disk.h"
-#include "../include/lustre_log.h"
-#include "../include/lustre_swab.h"
-#include "../include/obd_class.h"
+#include <lprocfs_status.h>
+#include <lustre_dlm.h>
+#include <lustre_disk.h>
+#include <lustre_log.h>
+#include <lustre_swab.h>
+#include <obd_class.h>
 
 #include "mgc_internal.h"
 
-- 
1.8.3.1
