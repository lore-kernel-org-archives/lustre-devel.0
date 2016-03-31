From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:40 -0400
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: libcfs: delete
	linux-mem.h
In-Reply-To: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459433920-23644-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

The header linux-mem.h is no longer needed.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13841
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/linux/libcfs.h     |    2 +-
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |    2 +-
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |   60 --------------------
 3 files changed, 2 insertions(+), 62 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index d94b266..a268ef7 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -60,6 +60,7 @@
 #include <linux/moduleparam.h>
 #include <linux/mutex.h>
 #include <linux/notifier.h>
+#include <linux/pagemap.h>
 #include <linux/random.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
@@ -83,7 +84,6 @@
 #include <stdarg.h>
 #include "linux-cpu.h"
 #include "linux-time.h"
-#include "linux-mem.h"
 
 #define LUSTRE_TRACE_SIZE (THREAD_SIZE >> 5)
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index c04979a..f63cb47 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -23,7 +23,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * libcfs/include/libcfs/linux/linux-mem.h
+ * libcfs/include/libcfs/linux/linux-cpu.h
  *
  * Basic library routines.
  *
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
deleted file mode 100644
index 9285fef..0000000
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ /dev/null
@@ -1,60 +0,0 @@
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
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/include/libcfs/linux/linux-mem.h
- *
- * Basic library routines.
- */
-
-#ifndef __LIBCFS_LINUX_CFS_MEM_H__
-#define __LIBCFS_LINUX_CFS_MEM_H__
-
-#ifndef __LIBCFS_LIBCFS_H__
-#error Do not #include this file directly. #include <linux/libcfs/libcfs.h> instead
-#endif
-
-#include <linux/mm.h>
-#include <linux/vmalloc.h>
-#include <linux/pagemap.h>
-#include <linux/slab.h>
-#include <linux/memcontrol.h>
-#include <linux/mm_inline.h>
-
-#ifndef HAVE_LIBCFS_CPT
-/* Need this for cfs_cpt_table */
-#include "../libcfs_cpu.h"
-#endif
-
-#endif /* __LINUX_CFS_MEM_H__ */
-- 
1.7.1
