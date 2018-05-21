From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 19/30] staging: lustre: discard libcfs_prim.h
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731304.24196.11999970666047933463.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This file no longer contains enough content
to justify a separate file.  So merge with
libcfs.h.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   12 ++++-
 .../lustre/include/linux/libcfs/libcfs_prim.h      |   51 --------------------
 2 files changed, 11 insertions(+), 52 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 20dfe8872d24..1880ef2b8528 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -82,7 +82,6 @@
 #include <linux/libcfs/libcfs_debug.h>
 #include <linux/libcfs/libcfs_private.h>
 #include <linux/libcfs/libcfs_cpu.h>
-#include <linux/libcfs/libcfs_prim.h>
 #include <linux/libcfs/libcfs_string.h>
 #include <linux/libcfs/libcfs_hash.h>
 #include <linux/libcfs/libcfs_fail.h>
@@ -107,4 +106,15 @@ int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			 int (*handler)(void *data, int write, loff_t pos,
 					void __user *buffer, int len));
 
+/*
+ * Memory
+ */
+#if BITS_PER_LONG == 32
+/* limit to lowmem on 32-bit systems */
+#define NUM_CACHEPAGES \
+	min(totalram_pages, 1UL << (30 - PAGE_SHIFT) * 3 / 4)
+#else
+#define NUM_CACHEPAGES totalram_pages
+#endif
+
 #endif /* __LIBCFS_LIBCFS_H__ */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
deleted file mode 100644
index 2b0dafb6155b..000000000000
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ /dev/null
@@ -1,51 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
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
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/include/libcfs/libcfs_prim.h
- *
- * General primitives.
- *
- */
-
-#ifndef __LIBCFS_PRIM_H__
-#define __LIBCFS_PRIM_H__
-
-/*
- * Memory
- */
-#if BITS_PER_LONG == 32
-/* limit to lowmem on 32-bit systems */
-#define NUM_CACHEPAGES \
-	min(totalram_pages, 1UL << (30 - PAGE_SHIFT) * 3 / 4)
-#else
-#define NUM_CACHEPAGES totalram_pages
-#endif
-
-#endif
