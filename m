From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 23:27:15 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: remove {linux,
	posix}-tracefile.h
Message-ID: <1447043236-30519-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Move the definition of the trace buffer type enum in
libcfs/libcfs/tracefile.h.  Remove the then unneeded headers
libcfs/libcfs/linux/linux-tracefile.h and
libcfs/libcfs/posix/posix-tracefile.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11983
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lustre/libcfs/linux/linux-tracefile.h   |   48 --------------------
 drivers/staging/lustre/lustre/libcfs/tracefile.h   |    7 +++-
 2 files changed, 6 insertions(+), 49 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.h

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.h b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.h
deleted file mode 100644
index ba84e4f..0000000
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.h
+++ /dev/null
@@ -1,48 +0,0 @@
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
- * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LIBCFS_LINUX_TRACEFILE_H__
-#define __LIBCFS_LINUX_TRACEFILE_H__
-
-/**
- * three types of trace_data in linux
- */
-typedef enum {
-	CFS_TCD_TYPE_PROC = 0,
-	CFS_TCD_TYPE_SOFTIRQ,
-	CFS_TCD_TYPE_IRQ,
-	CFS_TCD_TYPE_MAX
-} cfs_trace_buf_type_t;
-
-#endif
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 6b37798..b71b94f 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -39,7 +39,12 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
-#include "linux/linux-tracefile.h"
+typedef enum {
+	CFS_TCD_TYPE_PROC = 0,
+	CFS_TCD_TYPE_SOFTIRQ,
+	CFS_TCD_TYPE_IRQ,
+	CFS_TCD_TYPE_MAX
+} cfs_trace_buf_type_t;
 
 /* trace file lock routines */
 
-- 
1.7.1
