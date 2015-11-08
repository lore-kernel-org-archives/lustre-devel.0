From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:10 -0500
Subject: [lustre-devel] [PATCH 05/13] staging: lustre: split kernel comm
	between user and kernel
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

Split the kernel comm header in libcfs into two new headers
to handle both kernel space and user space for the lustre layer.
This is broken out of the original patch 14270. The part covered
by this change is as follows:

The original libcfs_kernelcomm.h header is split into three parts:
  * lustre_kernelcomm.h, a new header for the kernel parts;
  * uapi_kernelcomm.h, a new header for the data structures shared
    between userspace and kernelspace;
  * lustreapi_internal.h receives the private liblustreapi prototypes.

Various names and filenames have been harmonized to *kernelcomm*.

The unused symbol KUC_FL_BLOCK has been removed.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14270
Reviewed-by: Nathan Rutman <nathan.rutman@seagate.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../lustre/lustre/include/lustre_kernelcomm.h      |   56 ++++++++++++++++++++
 .../include/uapi_kernelcomm.h}                     |   50 ++++-------------
 drivers/staging/lustre/lustre/llite/dir.c          |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    1 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/genops.c    |    1 +
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    5 +-
 8 files changed, 74 insertions(+), 42 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
 rename drivers/staging/lustre/{include/linux/libcfs/libcfs_kernelcomm.h => lustre/include/uapi_kernelcomm.h} (62%)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4d74e8a..e35f59f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -122,7 +122,6 @@ void cfs_get_random_bytes(void *buf, int size);
 #include "libcfs_prim.h"
 #include "libcfs_time.h"
 #include "libcfs_string.h"
-#include "libcfs_kernelcomm.h"
 #include "libcfs_workitem.h"
 #include "libcfs_hash.h"
 #include "libcfs_fail.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
new file mode 100644
index 0000000..bb305f4
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -0,0 +1,56 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2013, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ *
+ * Author: Nathan Rutman <nathan.rutman@sun.com>
+ *
+ * Kernel <-> userspace communication routines.
+ * The definitions below are used in the kernel and userspace.
+ */
+
+#ifndef __LUSTRE_KERNELCOMM_H__
+#define __LUSTRE_KERNELCOMM_H__
+
+/* For declarations shared with userspace */
+#include "uapi_kernelcomm.h"
+
+/* prototype for callback function on kuc groups */
+typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
+
+/* Kernel methods */
+int libcfs_kkuc_msg_put(struct file *fp, void *payload);
+int libcfs_kkuc_group_put(int group, void *payload);
+int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
+			  void *data);
+int libcfs_kkuc_group_rem(int uid, int group, void **pdata);
+int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
+			      void *cb_arg);
+
+#endif /* __LUSTRE_KERNELCOMM_H__ */
+
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
similarity index 62%
rename from drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
rename to drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
index 3a89a3b..5e0b8de 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
@@ -15,37 +15,29 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
+ * http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2013, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Author: Nathan Rutman <nathan.rutman@sun.com>
  *
- * libcfs/include/libcfs/libcfs_kernelcomm.h
- *
  * Kernel <-> userspace communication routines.
  * The definitions below are used in the kernel and userspace.
- *
  */
 
-#ifndef __LIBCFS_KERNELCOMM_H__
-#define __LIBCFS_KERNELCOMM_H__
+#ifndef __UAPI_KERNELCOMM_H__
+#define __UAPI_KERNELCOMM_H__
 
-#ifndef __LIBCFS_LIBCFS_H__
-#error Do not #include this file directly. #include <linux/libcfs/libcfs.h> instead
-#endif
+#include <linux/types.h>
 
 /* KUC message header.
  * All current and future KUC messages should use this header.
@@ -63,7 +55,6 @@ struct kuc_hdr {
 #define KUC_CHANGELOG_MSG_MAXSIZE (sizeof(struct kuc_hdr)+CR_MAXSIZE)
 
 #define KUC_MAGIC  0x191C /*Lustre9etLinC */
-#define KUC_FL_BLOCK 0x01   /* Wait for send */
 
 /* kuc_msgtype values are defined in each transport */
 enum kuc_transport_type {
@@ -76,43 +67,26 @@ enum kuc_generic_message_type {
 	KUC_MSG_SHUTDOWN = 1,
 };
 
-/* prototype for callback function on kuc groups */
-typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
-
 /* KUC Broadcast Groups. This determines which userspace process hears which
  * messages.  Mutliple transports may be used within a group, or multiple
  * groups may use the same transport.  Broadcast
  * groups need not be used if e.g. a UID is specified instead;
  * use group 0 to signify unicast.
  */
-#define KUC_GRP_HSM	   0x02
-#define KUC_GRP_MAX	   KUC_GRP_HSM
-
-/* Kernel methods */
-int libcfs_kkuc_msg_put(struct file *fp, void *payload);
-int libcfs_kkuc_group_put(int group, void *payload);
-int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
-			  void *data);
-int libcfs_kkuc_group_rem(int uid, int group, void **pdata);
-int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
-				     void *cb_arg);
+#define KUC_GRP_HSM	0x02
+#define KUC_GRP_MAX	KUC_GRP_HSM
 
 #define LK_FLG_STOP 0x01
+#define LK_NOFD -1U
 
 /* kernelcomm control structure, passed from userspace to kernel */
-typedef struct lustre_kernelcomm {
+struct lustre_kernelcomm {
 	__u32 lk_wfd;
 	__u32 lk_rfd;
 	__u32 lk_uid;
 	__u32 lk_group;
 	__u32 lk_data;
 	__u32 lk_flags;
-} __packed lustre_kernelcomm;
-
-/* Userspace methods */
-int libcfs_ukuc_start(lustre_kernelcomm *l, int groups);
-int libcfs_ukuc_stop(lustre_kernelcomm *l);
-int libcfs_ukuc_msg_get(lustre_kernelcomm *l, char *buf, int maxsize,
-			       int transport);
+} __packed;
 
-#endif /* __LIBCFS_KERNELCOMM_H__ */
+#endif	/* __UAPI_KERNELCOMM_H__ */
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5c2ef92..70c4fe8 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -55,6 +55,7 @@
 #include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_fid.h"
+#include "../include/lustre_kernelcomm.h"
 #include "llite_internal.h"
 
 /*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 8b2ae38..2ad2904 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -53,6 +53,7 @@
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_lite.h"
 #include "../include/lustre_fid.h"
+#include "../include/lustre_kernelcomm.h"
 #include "lmv_internal.h"
 
 static void lmv_activate_target(struct lmv_obd *lmv,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index b3a237e..a4c543a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -48,6 +48,7 @@
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_param.h"
 #include "../include/lustre_log.h"
+#include "../include/lustre_kernelcomm.h"
 
 #include "mdc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 26f54f9..6c0e3c1 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -42,6 +42,7 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 #include "../include/obd_class.h"
 #include "../include/lprocfs_status.h"
+#include "../include/lustre_kernelcomm.h"
 
 spinlock_t obd_types_lock;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 3b4731a..e3f5a3c 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -42,9 +42,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 #define D_KUC D_OTHER
 
-#include "../../include/linux/libcfs/libcfs.h"
-
-/* This is the kernel side (liblustre as well). */
+#include "../include/obd_support.h"
+#include "../include/lustre_kernelcomm.h"
 
 /**
  * libcfs_kkuc_msg_put - send an message from kernel to userspace
-- 
1.7.1
