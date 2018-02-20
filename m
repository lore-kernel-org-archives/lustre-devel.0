From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 08/21] staging: lustre: make signal-blocking
 functions inline
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341780.25814.17116167688658061622.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

cfs_block_sigsinv() and cfs_restore_sigs() are now
simple enough to inline them.
This means we can discard linux-prim.c

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   20 +++++-
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 -
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   62 --------------------
 3 files changed, 16 insertions(+), 68 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 9dff050810c4..4f8c65e6d883 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -64,11 +64,21 @@
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
-/*
- * Defined by platform
- */
-void cfs_block_sigsinv(unsigned long sigs, sigset_t *sigset);
-void cfs_restore_sigs(sigset_t *sigset);
+/* Block all signals except for the @sigs */
+static inline void cfs_block_sigsinv(unsigned long sigs, sigset_t *old)
+{
+	sigset_t new;
+
+	siginitsetinv(&new, sigs);
+	sigorsets(&new, &current->blocked, &new);
+	sigprocmask(SIG_BLOCK, &new, old);
+}
+
+static inline void
+cfs_restore_sigs(sigset_t *old)
+{
+	sigprocmask(SIG_SETMASK, old, NULL);
+}
 
 struct libcfs_ioctl_handler {
 	struct list_head item;
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index fccea8684f0c..a51a8b0b9921 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -5,7 +5,7 @@ subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 obj-$(CONFIG_LNET) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
-libcfs-linux-objs += linux-prim.o linux-cpu.o
+libcfs-linux-objs += linux-cpu.o
 libcfs-linux-objs += linux-module.o
 libcfs-linux-objs += linux-crypto.o
 libcfs-linux-objs += linux-crypto-adler.o
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
deleted file mode 100644
index 0766659ddf70..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ /dev/null
@@ -1,62 +0,0 @@
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
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define DEBUG_SUBSYSTEM S_LNET
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/fs_struct.h>
-#include <linux/sched/signal.h>
-
-#include <linux/libcfs/libcfs.h>
-
-#if defined(CONFIG_KGDB)
-#include <linux/kgdb.h>
-#endif
-
-/* Block all signals except for the @sigs */
-void cfs_block_sigsinv(unsigned long sigs, sigset_t *old)
-{
-	sigset_t new;
-
-	siginitsetinv(&new, sigs);
-	sigorsets(&new, &current->blocked, &new);
-	sigprocmask(SIG_BLOCK, &new, old);
-}
-EXPORT_SYMBOL(cfs_block_sigsinv);
-
-void
-cfs_restore_sigs(sigset_t *old)
-{
-	sigprocmask(SIG_SETMASK, old, NULL);
-}
-EXPORT_SYMBOL(cfs_restore_sigs);
