From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:41 -0400
Subject: [lustre-devel] [PATCH 102/124] staging: lustre: remove
	lustre/include/linux/
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-103-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Merge the contents of lustre/include/linux/lvfs.h into
lustre/include/lvfs.h. Merge lustre/include/linux/lustre_user.h into
lustre/include/lustre/lustre_user.h. Move lustre_compat25.h and
lustre_patchless_compat.h from lustre/include/linux/ to
lustre/include/ and rename lustre_compat25.h to lustre_compat.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/13271
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    2 +-
 .../lustre/lustre/include/linux/lustre_user.h      |   66 --------------------
 .../lustre/lustre/include/lustre/lustre_user.h     |   27 ++++++++-
 .../{linux/lustre_compat25.h => lustre_compat.h}   |    6 +-
 .../include/{linux => }/lustre_patchless_compat.h  |    0
 .../staging/lustre/lustre/include/obd_support.h    |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 +
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    1 -
 drivers/staging/lustre/lustre/llite/rw.c           |    1 -
 drivers/staging/lustre/lustre/llite/rw26.c         |    1 -
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 12 files changed, 36 insertions(+), 77 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/linux/lustre_user.h
 rename drivers/staging/lustre/lustre/include/{linux/lustre_compat25.h => lustre_compat.h} (96%)
 rename drivers/staging/lustre/lustre/include/{linux => }/lustre_patchless_compat.h (100%)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index c1bcff8..409a324 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -93,8 +93,8 @@
  * super-class definitions.
  */
 #include "lu_object.h"
+#include "lustre_compat.h"
 #include <linux/atomic.h>
-#include "linux/lustre_compat25.h"
 #include <linux/mutex.h>
 #include <linux/radix-tree.h>
 #include <linux/spinlock.h>
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_user.h b/drivers/staging/lustre/lustre/include/linux/lustre_user.h
deleted file mode 100644
index e967950..0000000
--- a/drivers/staging/lustre/lustre/include/linux/lustre_user.h
+++ /dev/null
@@ -1,66 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/include/linux/lustre_user.h
- *
- * Lustre public user-space interface definitions.
- */
-
-#ifndef _LINUX_LUSTRE_USER_H
-#define _LINUX_LUSTRE_USER_H
-
-# include <linux/quota.h>
-
-/*
- * asm-x86_64/processor.h on some SLES 9 distros seems to use
- * kernel-only typedefs.  fortunately skipping it altogether is ok
- * (for now).
- */
-#define __ASM_X86_64_PROCESSOR_H
-
-#include <linux/string.h>
-
-/*
- * We need to always use 64bit version because the structure
- * is shared across entire cluster where 32bit and 64bit machines
- * are co-existing.
- */
-#if __BITS_PER_LONG != 64 || defined(__ARCH_WANT_STAT64)
-typedef struct stat64   lstat_t;
-#define lstat_f	 lstat64
-#else
-typedef struct stat     lstat_t;
-#define lstat_f	 lstat
-#endif
-
-#define HAVE_LOV_USER_MDS_DATA
-
-#endif /* _LUSTRE_USER_H */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index ba679ad..6fc9855 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -42,8 +42,33 @@
  * @{
  */
 
+#ifdef __KERNEL__
+# include <linux/quota.h>
+# include <linux/string.h> /* snprintf() */
+# include <linux/version.h>
+#else /* !__KERNEL__ */
+# define NEED_QUOTA_DEFS
+# include <stdio.h> /* snprintf() */
+# include <string.h>
+# include <sys/quota.h>
+# include <sys/stat.h>
+#endif /* __KERNEL__ */
 #include "ll_fiemap.h"
-#include "../linux/lustre_user.h"
+
+/*
+ * We need to always use 64bit version because the structure
+ * is shared across entire cluster where 32bit and 64bit machines
+ * are co-existing.
+ */
+#if __BITS_PER_LONG != 64 || defined(__ARCH_WANT_STAT64)
+typedef struct stat64   lstat_t;
+#define lstat_f  lstat64
+#else
+typedef struct stat     lstat_t;
+#define lstat_f  lstat
+#endif
+
+#define HAVE_LOV_USER_MDS_DATA
 
 #define LUSTRE_EOF 0xffffffffffffffffULL
 
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
similarity index 96%
rename from drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
rename to drivers/staging/lustre/lustre/include/lustre_compat.h
index 1eb64ec..567c438 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -30,8 +30,8 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
-#ifndef _LINUX_COMPAT25_H
-#define _LINUX_COMPAT25_H
+#ifndef _LUSTRE_COMPAT_H
+#define _LUSTRE_COMPAT_H
 
 #include <linux/fs_struct.h>
 #include <linux/namei.h>
@@ -74,4 +74,4 @@
 # define ext2_find_next_zero_bit  find_next_zero_bit_le
 #endif
 
-#endif /* _COMPAT25_H */
+#endif /* _LUSTRE_COMPAT_H */
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
similarity index 100%
rename from drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
rename to drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 3144cca..b346a7f 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -35,7 +35,7 @@
 
 #include <linux/slab.h>
 #include "../../include/linux/libcfs/libcfs.h"
-#include "linux/lustre_compat25.h"
+#include "lustre_compat.h"
 #include "lprocfs_status.h"
 
 /* global variables */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ce96c9f..e8963fe 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -42,11 +42,11 @@
 #include <linux/file.h>
 #include <linux/sched.h>
 #include <linux/mount.h>
-#include "llite_internal.h"
 #include "../include/lustre/ll_fiemap.h"
 #include "../include/lustre/lustre_ioctl.h"
 
 #include "../include/cl_object.h"
+#include "llite_internal.h"
 
 static int
 ll_put_grouplock(struct inode *inode, struct file *file, unsigned long arg);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 05f2aa3..e5f1967 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -39,11 +39,14 @@
 #include "../include/lustre_linkea.h"
 
 /* for struct cl_lock_descr and struct cl_io */
+#include "../include/lustre_patchless_compat.h"
+#include "../include/lustre_compat.h"
 #include "../include/cl_object.h"
 #include "../include/lustre_lmv.h"
 #include "../include/lustre_mdc.h"
 #include "../include/lustre_intent.h"
 #include <linux/compat.h>
+#include <linux/namei.h>
 #include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 0cd25bf..4366918 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -44,7 +44,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "llite_internal.h"
-#include "../include/linux/lustre_compat25.h"
 
 static const struct vm_operations_struct ll_file_vm_ops;
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 508cb46..50c0152 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -52,7 +52,6 @@
 
 #include "../include/obd_cksum.h"
 #include "llite_internal.h"
-#include "../include/linux/lustre_compat25.h"
 
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
 
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index df0318e..26f3a37 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -52,7 +52,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "llite_internal.h"
-#include "../include/linux/lustre_compat25.h"
 
 /**
  * Implements Linux VM address_space::invalidatepage() method. This method is
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 0df1aa6..0d3a3b0 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -41,7 +41,7 @@
 #define PRINT_CMD CDEBUG
 
 #include "../include/obd.h"
-#include "../include/linux/lustre_compat25.h"
+#include "../include/lustre_compat.h"
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_user.h"
 #include "../include/lustre_log.h"
-- 
1.7.1
