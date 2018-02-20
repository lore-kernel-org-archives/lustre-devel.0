From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 03/21] staging: lustre: remove linux-curproc.c
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341763.25814.2230821270457016452.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The only functionality remaining here is
cfs_curproc_cap_pack(),
and it can be trivially implemented as an inline
in curproc.h.
So do that and remove the file.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |    6 +-
 drivers/staging/lustre/lnet/libcfs/Makefile        |    1 
 .../lustre/lnet/libcfs/linux/linux-curproc.c       |   78 --------------------
 3 files changed, 5 insertions(+), 80 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index 51f2179b7534..4702956805a6 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -66,7 +66,11 @@ typedef u32 cfs_cap_t;
 			 BIT(CAP_SYS_BOOT) |	\
 			 BIT(CAP_SYS_RESOURCE))
 
-cfs_cap_t cfs_curproc_cap_pack(void);
+static inline cfs_cap_t cfs_curproc_cap_pack(void)
+{
+	/* cfs_cap_t is only the first word of kernel_cap_t */
+	return (cfs_cap_t)(current_cap().cap[0]);
+}
 
 /* __LIBCFS_CURPROC_H__ */
 #endif
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 730f2c675047..fccea8684f0c 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -6,7 +6,6 @@ obj-$(CONFIG_LNET) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
 libcfs-linux-objs += linux-prim.o linux-cpu.o
-libcfs-linux-objs += linux-curproc.o
 libcfs-linux-objs += linux-module.o
 libcfs-linux-objs += linux-crypto.o
 libcfs-linux-objs += linux-crypto-adler.o
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
deleted file mode 100644
index 6b75c5cdc3ec..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
+++ /dev/null
@@ -1,78 +0,0 @@
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
- *
- * Copyright (c) 2011, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/libcfs/linux/linux-curproc.c
- *
- * Lustre curproc API implementation for Linux kernel
- *
- * Author: Nikita Danilov <nikita@clusterfs.com>
- */
-
-#include <linux/sched.h>
-#include <linux/fs_struct.h>
-
-#include <linux/compat.h>
-#include <linux/thread_info.h>
-
-#define DEBUG_SUBSYSTEM S_LNET
-
-#include <linux/libcfs/libcfs.h>
-
-/*
- * Implementation of cfs_curproc API (see portals/include/libcfs/curproc.h)
- * for Linux kernel.
- */
-
-static void cfs_kernel_cap_pack(kernel_cap_t kcap, cfs_cap_t *cap)
-{
-	/* XXX lost high byte */
-	*cap = kcap.cap[0];
-}
-
-cfs_cap_t cfs_curproc_cap_pack(void)
-{
-	cfs_cap_t cap;
-
-	cfs_kernel_cap_pack(current_cap(), &cap);
-	return cap;
-}
-EXPORT_SYMBOL(cfs_curproc_cap_pack);
-
-/*
- * Local variables:
- * c-indentation-style: "K&R"
- * c-basic-offset: 8
- * tab-width: 8
- * fill-column: 80
- * scroll-step: 1
- * End:
- */
