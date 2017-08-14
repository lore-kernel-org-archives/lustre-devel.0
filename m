From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:18 -0400
Subject: [lustre-devel] [PATCH 50/64] staging: lustre: lov: add include path
	to Makefile
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths in the lov source code files.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/Makefile         |  3 ++
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  6 ++--
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  6 ++--
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  4 +--
 drivers/staging/lustre/lustre/lov/lov_merge.c      |  4 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 32 +++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  4 +--
 drivers/staging/lustre/lustre/lov/lov_pack.c       | 10 +++----
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  4 +--
 drivers/staging/lustre/lustre/lov/lov_request.c    |  6 ++--
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  4 +--
 12 files changed, 44 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/Makefile b/drivers/staging/lustre/lustre/lov/Makefile
index ea93add..3abfb4e 100644
--- a/drivers/staging/lustre/lustre/lov/Makefile
+++ b/drivers/staging/lustre/lustre/lov/Makefile
@@ -1,3 +1,6 @@
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
 obj-$(CONFIG_LUSTRE_FS) += lov.o
 lov-y := lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
 	 lov_request.o lov_ea.o lov_dev.o lov_object.o lov_page.o  \
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 38281b2..89d92b0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -42,10 +42,10 @@
 #ifndef LOV_CL_INTERNAL_H
 #define LOV_CL_INTERNAL_H
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd.h"
-#include "../include/cl_object.h"
+#include <obd.h>
+#include <cl_object.h>
 #include "lov_internal.h"
 
 /** \defgroup lov lov
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 531b4fe..cea5f9d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 /* class_name2obd() */
-#include "../include/obd_class.h"
+#include <obd_class.h>
 
 #include "lov_cl_internal.h"
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 530a4e9..1124fd5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -37,10 +37,10 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include <asm/div64.h>
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 4d9437e..a21f074 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -33,8 +33,8 @@
 #ifndef LOV_INTERNAL_H
 #define LOV_INTERNAL_H
 
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 
 /*
  * If we are unable to get the maximum object size from the OST in
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 034b4fc..9163361 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -32,9 +32,9 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_class.h"
+#include <obd_class.h>
 #include "lov_internal.h"
 
 /** Merge the lock value block(&lvb) attributes and KMS from each of the
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 953ed71..fefd3c5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -38,22 +38,22 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
-#include "../../include/linux/libcfs/libcfs.h"
-
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../../include/uapi/linux/lustre/lustre_ioctl.h"
-
-#include "../include/cl_object.h"
-#include "../include/lustre_dlm.h"
-#include "../include/lustre_fid.h"
-#include "../include/lustre_lib.h"
-#include "../include/lustre_mds.h"
-#include "../include/lustre_net.h"
-#include "../../include/uapi/linux/lustre/lustre_param.h"
-#include "../include/lustre_swab.h"
-#include "../include/lprocfs_status.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
+#include <linux/libcfs/libcfs.h>
+
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <uapi/linux/lustre/lustre_ioctl.h>
+
+#include <cl_object.h>
+#include <lustre_dlm.h>
+#include <lustre_fid.h>
+#include <lustre_lib.h>
+#include <lustre_mds.h>
+#include <lustre_net.h>
+#include <uapi/linux/lustre/lustre_param.h>
+#include <lustre_swab.h>
+#include <lprocfs_status.h>
+#include <obd_class.h>
+#include <obd_support.h>
 
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index ecca74f..899d12c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -32,9 +32,9 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_class.h"
+#include <obd_class.h>
 
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index fd346c5..24fb2a9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -38,11 +38,11 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../include/lustre_net.h"
-#include "../include/lustre_swab.h"
-#include "../include/obd.h"
-#include "../include/obd_class.h"
-#include "../include/obd_support.h"
+#include <lustre_net.h>
+#include <lustre_swab.h>
+#include <obd.h>
+#include <obd_class.h>
+#include <obd_support.h>
 
 #include "lov_cl_internal.h"
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 39daa17..d774ee2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -40,9 +40,9 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd.h"
+#include <obd.h>
 #include "lov_internal.h"
 
 #define pool_tgt(_p, _i) \
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 74aeb94..9d3b3f3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -32,10 +32,10 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
-#include "../include/obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 #include "lov_internal.h"
 
 static void lov_init_set(struct lov_request_set *set)
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index ce46821..9bb7e9e 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -32,8 +32,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/statfs.h>
-#include "../include/lprocfs_status.h"
-#include "../include/obd_class.h"
+#include <lprocfs_status.h>
+#include <obd_class.h>
 #include <linux/seq_file.h>
 #include "lov_internal.h"
 
-- 
1.8.3.1
