From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 17/24] lustre: remove lustre_compat.h
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669067.10587.14431331340197955105.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Only thing it provided was one include file,
so include that directly where needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    1 
 .../staging/lustre/lustre/include/lustre_compat.h  |   42 --------------------
 .../staging/lustre/lustre/include/obd_support.h    |    1 
 .../staging/lustre/lustre/llite/llite_internal.h   |    1 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    1 
 drivers/staging/lustre/lustre/obdclass/llog.c      |    1 
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    1 
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    1 
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    1 
 10 files changed, 5 insertions(+), 46 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_compat.h

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index caa66763c70d..1491beb2b9a9 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -90,7 +90,6 @@
  * super-class definitions.
  */
 #include <lu_object.h>
-#include <lustre_compat.h>
 #include <linux/atomic.h>
 #include <linux/mutex.h>
 #include <linux/radix-tree.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
deleted file mode 100644
index f555391d5ae3..000000000000
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ /dev/null
@@ -1,42 +0,0 @@
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
- * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef _LUSTRE_COMPAT_H
-#define _LUSTRE_COMPAT_H
-
-#include <linux/fs_struct.h>
-#include <linux/namei.h>
-#include <linux/cred.h>
-#include <linux/module.h>
-
-#endif /* _LUSTRE_COMPAT_H */
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 9e41633823f7..070a281ebb7d 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -37,7 +37,6 @@
 #include <linux/slab.h>
 #include <linux/sched/signal.h>
 
-#include <lustre_compat.h>
 #include <lprocfs_status.h>
 
 /* global variables */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 91212e608c0b..539ed3b6b64a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -39,7 +39,6 @@
 #include <lustre_linkea.h>
 
 /* for struct cl_lock_descr and struct cl_io */
-#include <lustre_compat.h>
 #include <cl_object.h>
 #include <lustre_lmv.h>
 #include <lustre_mdc.h>
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e6e02fe7703b..a0a143bf4989 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -42,6 +42,7 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/random.h>
+#include <linux/fs_struct.h>
 
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <lustre_ha.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 53e723d990e4..f59f89a76c91 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -45,6 +45,7 @@
 #define DEBUG_SUBSYSTEM S_LOG
 
 #include <linux/kthread.h>
+#include <linux/fs_struct.h>
 #include <llog_swab.h>
 #include <lustre_log.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 06c38fdef7ba..232bbfa9242c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -43,7 +43,6 @@
 
 #include <linux/random.h>
 #include <obd.h>
-#include <lustre_compat.h>
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lustre_log.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 1a0f35dfab97..54ceac56c524 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -38,6 +38,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
+#include <linux/fs_struct.h>
 #include <obd_support.h>
 #include <lustre_ha.h>
 #include <lustre_net.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 531005411edf..66295b4fcdab 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -53,6 +53,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
+#include <linux/fs_struct.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/libcfs/libcfs_cpu.h>
 #include <linux/libcfs/libcfs_string.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 3fd8c746f460..12442425702a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -34,6 +34,7 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
+#include <linux/fs_struct.h>
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
