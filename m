From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:13 -0400
Subject: [lustre-devel] [PATCH 45/64] staging: lustre: fid: add include path
	to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Start to rationalize include paths in the fid source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/Makefile       |  3 +++
 drivers/staging/lustre/lustre/fid/fid_internal.h |  4 ++--
 drivers/staging/lustre/lustre/fid/fid_lib.c      |  4 ++--
 drivers/staging/lustre/lustre/fid/fid_request.c  | 12 ++++++------
 drivers/staging/lustre/lustre/fid/lproc_fid.c    | 12 ++++++------
 5 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/Makefile b/drivers/staging/lustre/lustre/fid/Makefile
index b7ef314..77b65b9 100644
--- a/drivers/staging/lustre/lustre/fid/Makefile
+++ b/drivers/staging/lustre/lustre/fid/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
+
 obj-$(CONFIG_LUSTRE_FS) += fid.o
 fid-y := fid_request.o fid_lib.o lproc_fid.o
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index 5f8d15b..f48ab9d 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -36,8 +36,8 @@
 #ifndef __FID_INTERNAL_H
 #define __FID_INTERNAL_H
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../../include/linux/libcfs/libcfs.h"
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <linux/libcfs/libcfs.h>
 
 /* Functions used internally in module. */
 
diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index 6ab06ef..c21a5f5 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -39,9 +39,9 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/module.h>
-#include "../include/lustre_fid.h"
+#include <lustre_fid.h>
 
 /**
  * A cluster-wide range from which fid-sequences are granted to servers and
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 19895fa..ba73623 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -38,15 +38,15 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/module.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_fid.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_fid.h>
 /* mdc RPC locks */
-#include "../include/lustre_mdc.h"
+#include <lustre_mdc.h>
 #include "fid_internal.h"
 
 static struct dentry *seq_debugfs_dir;
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 3eed838..1a269fb 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -38,14 +38,14 @@
 
 #define DEBUG_SUBSYSTEM S_FID
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/module.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_fid.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_req_layout.h>
+#include <lustre_fid.h>
 #include "fid_internal.h"
 
 /* Format: [0x64BIT_INT - 0x64BIT_INT] + 32 bytes just in case */
-- 
1.8.3.1
