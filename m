From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:01 -0400
Subject: [lustre-devel] [PATCH 33/64] staging: lustre: libcfs: create
	libcfs_debug.h UAPI header
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Break out the parts from libcfs_debug.h that is used by both user
land and kernel space into a new UAPI header.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/28089
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     | 104 +-------------
 .../lustre/include/uapi/linux/lnet/libcfs_debug.h  | 149 +++++++++++++++++++++
 2 files changed, 151 insertions(+), 102 deletions(-)
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index b7bd6e8..91d141d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -38,6 +38,8 @@
 #ifndef __LIBCFS_DEBUG_H__
 #define __LIBCFS_DEBUG_H__
 
+#include "../../uapi/linux/lnet/libcfs_debug.h"
+
 /*
  *  Debugging
  */
@@ -59,108 +61,6 @@
 extern unsigned int libcfs_catastrophe;
 extern unsigned int libcfs_panic_on_lbug;
 
-/**
- * Format for debug message headers
- */
-struct ptldebug_header {
-	__u32 ph_len;
-	__u32 ph_flags;
-	__u32 ph_subsys;
-	__u32 ph_mask;
-	__u16 ph_cpu_id;
-	__u16 ph_type;
-	/* time_t overflow in 2106 */
-	__u32 ph_sec;
-	__u64 ph_usec;
-	__u32 ph_stack;
-	__u32 ph_pid;
-	__u32 ph_extern_pid;
-	__u32 ph_line_num;
-} __packed;
-
-#define PH_FLAG_FIRST_RECORD 1
-
-/* Debugging subsystems (32 bits, non-overlapping) */
-#define S_UNDEFINED	0x00000001
-#define S_MDC		0x00000002
-#define S_MDS		0x00000004
-#define S_OSC		0x00000008
-#define S_OST		0x00000010
-#define S_CLASS		0x00000020
-#define S_LOG		0x00000040
-#define S_LLITE		0x00000080
-#define S_RPC		0x00000100
-#define S_MGMT		0x00000200
-#define S_LNET		0x00000400
-#define S_LND		0x00000800 /* ALL LNDs */
-#define S_PINGER	0x00001000
-#define S_FILTER	0x00002000
-/* unused */
-#define S_ECHO		0x00008000
-#define S_LDLM		0x00010000
-#define S_LOV		0x00020000
-#define S_LQUOTA	0x00040000
-#define S_OSD		0x00080000
-#define S_LFSCK		0x00100000
-/* unused */
-/* unused */
-#define S_LMV		0x00800000 /* b_new_cmd */
-/* unused */
-#define S_SEC		0x02000000 /* upcall cache */
-#define S_GSS		0x04000000 /* b_new_cmd */
-/* unused */
-#define S_MGC		0x10000000
-#define S_MGS		0x20000000
-#define S_FID		0x40000000 /* b_new_cmd */
-#define S_FLD		0x80000000 /* b_new_cmd */
-
-#define LIBCFS_DEBUG_SUBSYS_NAMES {					\
-	"undefined", "mdc", "mds", "osc", "ost", "class", "log",	\
-	"llite", "rpc", "mgmt", "lnet", "lnd", "pinger", "filter", "",	\
-	"echo", "ldlm", "lov", "lquota", "osd", "lfsck", "", "", "lmv",	\
-	"", "sec", "gss", "", "mgc", "mgs", "fid", "fld", NULL }
-
-/* Debugging masks (32 bits, non-overlapping) */
-#define D_TRACE		0x00000001 /* ENTRY/EXIT markers */
-#define D_INODE		0x00000002
-#define D_SUPER		0x00000004
-#define D_EXT2		0x00000008 /* anything from ext2_debug */
-#define D_MALLOC	0x00000010 /* print malloc, free information */
-#define D_CACHE		0x00000020 /* cache-related items */
-#define D_INFO		0x00000040 /* general information */
-#define D_IOCTL		0x00000080 /* ioctl related information */
-#define D_NETERROR	0x00000100 /* network errors */
-#define D_NET		0x00000200 /* network communications */
-#define D_WARNING	0x00000400 /* CWARN(...) == CDEBUG (D_WARNING, ...) */
-#define D_BUFFS		0x00000800
-#define D_OTHER		0x00001000
-#define D_DENTRY	0x00002000
-#define D_NETTRACE	0x00004000
-#define D_PAGE		0x00008000 /* bulk page handling */
-#define D_DLMTRACE	0x00010000
-#define D_ERROR		0x00020000 /* CERROR(...) == CDEBUG (D_ERROR, ...) */
-#define D_EMERG		0x00040000 /* CEMERG(...) == CDEBUG (D_EMERG, ...) */
-#define D_HA		0x00080000 /* recovery and failover */
-#define D_RPCTRACE	0x00100000 /* for distributed debugging */
-#define D_VFSTRACE	0x00200000
-#define D_READA		0x00400000 /* read-ahead */
-#define D_MMAP		0x00800000
-#define D_CONFIG	0x01000000
-#define D_CONSOLE	0x02000000
-#define D_QUOTA		0x04000000
-#define D_SEC		0x08000000
-#define D_LFSCK		0x10000000 /* For both OI scrub and LFSCK */
-#define D_HSM		0x20000000
-
-#define LIBCFS_DEBUG_MASKS_NAMES {					\
-	"trace", "inode", "super", "ext2", "malloc", "cache", "info",	\
-	"ioctl", "neterror", "net", "warning", "buffs", "other",	\
-	"dentry", "nettrace", "page", "dlmtrace", "error", "emerg",	\
-	"ha", "rpctrace", "vfstrace", "reada", "mmap", "config",	\
-	"console", "quota", "sec", "lfsck", "hsm", NULL }
-
-#define D_CANTMASK   (D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
-
 #ifndef DEBUG_SUBSYSTEM
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
new file mode 100644
index 0000000..c4d9472
--- /dev/null
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
@@ -0,0 +1,149 @@
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
+ * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, 2014, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * libcfs/include/libcfs/libcfs_debug.h
+ *
+ * Debug messages and assertions
+ *
+ */
+
+#ifndef __UAPI_LIBCFS_DEBUG_H__
+#define __UAPI_LIBCFS_DEBUG_H__
+
+/**
+ * Format for debug message headers
+ */
+struct ptldebug_header {
+	__u32 ph_len;
+	__u32 ph_flags;
+	__u32 ph_subsys;
+	__u32 ph_mask;
+	__u16 ph_cpu_id;
+	__u16 ph_type;
+	/* time_t overflow in 2106 */
+	__u32 ph_sec;
+	__u64 ph_usec;
+	__u32 ph_stack;
+	__u32 ph_pid;
+	__u32 ph_extern_pid;
+	__u32 ph_line_num;
+} __attribute__((packed));
+
+#define PH_FLAG_FIRST_RECORD	1
+
+/* Debugging subsystems (32 bits, non-overlapping) */
+#define S_UNDEFINED     0x00000001
+#define S_MDC           0x00000002
+#define S_MDS           0x00000004
+#define S_OSC           0x00000008
+#define S_OST           0x00000010
+#define S_CLASS         0x00000020
+#define S_LOG           0x00000040
+#define S_LLITE         0x00000080
+#define S_RPC           0x00000100
+#define S_MGMT          0x00000200
+#define S_LNET          0x00000400
+#define S_LND           0x00000800 /* ALL LNDs */
+#define S_PINGER        0x00001000
+#define S_FILTER        0x00002000
+#define S_LIBCFS        0x00004000
+#define S_ECHO          0x00008000
+#define S_LDLM          0x00010000
+#define S_LOV           0x00020000
+#define S_LQUOTA        0x00040000
+#define S_OSD           0x00080000
+#define S_LFSCK         0x00100000
+#define S_SNAPSHOT      0x00200000
+/* unused */
+#define S_LMV           0x00800000 /* b_new_cmd */
+/* unused */
+#define S_SEC           0x02000000 /* upcall cache */
+#define S_GSS           0x04000000 /* b_new_cmd */
+/* unused */
+#define S_MGC           0x10000000
+#define S_MGS           0x20000000
+#define S_FID           0x40000000 /* b_new_cmd */
+#define S_FLD           0x80000000 /* b_new_cmd */
+
+#define LIBCFS_DEBUG_SUBSYS_NAMES {					\
+	"undefined", "mdc", "mds", "osc", "ost", "class", "log",	\
+	"llite", "rpc", "mgmt", "lnet", "lnd", "pinger", "filter",	\
+	"libcfs", "echo", "ldlm", "lov", "lquota", "osd", "lfsck",	\
+	"snapshot", "", "lmv", "", "sec", "gss", "", "mgc", "mgs",	\
+	"fid", "fld", NULL }
+
+/* Debugging masks (32 bits, non-overlapping) */
+#define D_TRACE         0x00000001 /* ENTRY/EXIT markers */
+#define D_INODE         0x00000002
+#define D_SUPER         0x00000004
+#define D_EXT2          0x00000008 /* anything from ext2_debug */
+#define D_MALLOC        0x00000010 /* print malloc, free information */
+#define D_CACHE         0x00000020 /* cache-related items */
+#define D_INFO          0x00000040 /* general information */
+#define D_IOCTL         0x00000080 /* ioctl related information */
+#define D_NETERROR      0x00000100 /* network errors */
+#define D_NET           0x00000200 /* network communications */
+#define D_WARNING       0x00000400 /* CWARN(...) == CDEBUG (D_WARNING, ...) */
+#define D_BUFFS         0x00000800
+#define D_OTHER         0x00001000
+#define D_DENTRY        0x00002000
+#define D_NETTRACE      0x00004000
+#define D_PAGE          0x00008000 /* bulk page handling */
+#define D_DLMTRACE      0x00010000
+#define D_ERROR         0x00020000 /* CERROR(...) == CDEBUG (D_ERROR, ...) */
+#define D_EMERG         0x00040000 /* CEMERG(...) == CDEBUG (D_EMERG, ...) */
+#define D_HA            0x00080000 /* recovery and failover */
+#define D_RPCTRACE      0x00100000 /* for distributed debugging */
+#define D_VFSTRACE      0x00200000
+#define D_READA         0x00400000 /* read-ahead */
+#define D_MMAP          0x00800000
+#define D_CONFIG        0x01000000
+#define D_CONSOLE       0x02000000
+#define D_QUOTA         0x04000000
+#define D_SEC           0x08000000
+#define D_LFSCK         0x10000000 /* For both OI scrub and LFSCK */
+#define D_HSM           0x20000000
+#define D_SNAPSHOT      0x40000000 /* snapshot */
+#define D_LAYOUT        0x80000000
+
+#define LIBCFS_DEBUG_MASKS_NAMES {					\
+	"trace", "inode", "super", "ext2", "malloc", "cache", "info",	\
+	"ioctl", "neterror", "net", "warning", "buffs", "other",	\
+	"dentry", "nettrace", "page", "dlmtrace", "error", "emerg",	\
+	"ha", "rpctrace", "vfstrace", "reada", "mmap", "config",	\
+	"console", "quota", "sec", "lfsck", "hsm", "snapshot", "layout",\
+	NULL }
+
+#define D_CANTMASK   (D_ERROR | D_EMERG | D_WARNING | D_CONSOLE)
+
+#define LIBCFS_DEBUG_FILE_PATH_DEFAULT "/tmp/lustre-log"
+
+#endif	/* __UAPI_LIBCFS_DEBUG_H__ */
-- 
1.8.3.1
