From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:14 -0400
Subject: [lustre-devel] [PATCH 46/64] staging: lustre: fld: add include path
	to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-47-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the fld source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/Makefile       |  3 +++
 drivers/staging/lustre/lustre/fld/fld_cache.c    | 16 ++++++++--------
 drivers/staging/lustre/lustre/fld/fld_internal.h |  8 ++++----
 drivers/staging/lustre/lustre/fld/fld_request.c  | 18 +++++++++---------
 drivers/staging/lustre/lustre/fld/lproc_fld.c    | 14 +++++++-------
 5 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/Makefile b/drivers/staging/lustre/lustre/fld/Makefile
index 646e315..426deba 100644
--- a/drivers/staging/lustre/lustre/fld/Makefile
+++ b/drivers/staging/lustre/lustre/fld/Makefile
@@ -1,2 +1,5 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
+
 obj-$(CONFIG_LUSTRE_FS) += fld.o
 fld-y := fld_request.o fld_cache.o lproc_fld.o
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 68d009b..b723ece 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -39,18 +39,18 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_ver.h"
-#include "../include/obd_support.h"
-#include "../include/lprocfs_status.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_ver.h>
+#include <obd_support.h>
+#include <lprocfs_status.h>
 
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_fld.h"
+#include <lustre_req_layout.h>
+#include <lustre_fld.h>
 #include "fld_internal.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 3412c90..fe6f278 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -56,11 +56,11 @@
 #ifndef __FLD_INTERNAL_H
 #define __FLD_INTERNAL_H
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_fld.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_req_layout.h>
+#include <lustre_fld.h>
 
 struct fld_stats {
 	__u64   fst_count;
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 1282992..5b18083 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -38,19 +38,19 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/module.h>
 #include <asm/div64.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_ver.h"
-#include "../include/obd_support.h"
-#include "../include/lprocfs_status.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_ver.h>
+#include <obd_support.h>
+#include <lprocfs_status.h>
 
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_fld.h"
-#include "../include/lustre_mdc.h"
+#include <lustre_req_layout.h>
+#include <lustre_fld.h>
+#include <lustre_mdc.h>
 #include "fld_internal.h"
 
 static int fld_rrb_hash(struct lu_client_fld *fld, u64 seq)
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index b83d7eb..6cae803 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -39,15 +39,15 @@
 
 #define DEBUG_SUBSYSTEM S_FLD
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 #include <linux/module.h>
 
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
-#include "../include/lustre_req_layout.h"
-#include "../include/lustre_fld.h"
-#include "../include/lustre_fid.h"
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
+#include <lustre_req_layout.h>
+#include <lustre_fld.h>
+#include <lustre_fid.h>
 #include "fld_internal.h"
 
 static int
-- 
1.8.3.1
