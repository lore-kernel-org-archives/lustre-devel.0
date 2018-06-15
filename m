From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 10/24] lustre: remove
 lustre_patchless_compat.h
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669041.10587.15188275655299631716.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is now mostly empty.  A few #includes need
to be added to other files to compensate.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    1 
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    1 
 .../staging/lustre/lustre/include/lustre_compat.h  |    2 -
 drivers/staging/lustre/lustre/include/lustre_net.h |    1 
 .../lustre/include/lustre_patchless_compat.h       |   44 --------------------
 .../staging/lustre/lustre/llite/llite_internal.h   |    1 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    1 
 drivers/staging/lustre/lustre/lov/lov_page.c       |    1 
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    1 
 .../lustre/lustre/obdclass/lprocfs_status.c        |    1 
 .../staging/lustre/lustre/obdclass/obd_config.c    |    1 
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    1 
 drivers/staging/lustre/lustre/osc/osc_request.c    |    1 
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    1 
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    1 
 17 files changed, 15 insertions(+), 47 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_patchless_compat.h

diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 0aabf473c9bd..aa2df68d5acd 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -40,6 +40,7 @@
 #define DEBUG_SUBSYSTEM S_FID
 
 #include <linux/module.h>
+#include <linux/uaccess.h>
 
 #include <obd.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 0bcfb26ef8aa..c85ef9ec639f 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -41,6 +41,7 @@
 #define DEBUG_SUBSYSTEM S_FLD
 
 #include <linux/module.h>
+#include <linux/uaccess.h>
 
 #include <obd.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 6d1a433e32c5..bf86b0612b50 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -39,8 +39,6 @@
 #include <linux/cred.h>
 #include <linux/module.h>
 
-#include <lustre_patchless_compat.h>
-
 #define current_ngroups current_cred()->group_info->ngroups
 #define current_groups current_cred()->group_info->small_block
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 35b43a77eb18..dcad90bc97eb 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -51,6 +51,7 @@
  * @{
  */
 
+#include <linux/mm.h>
 #include <linux/uio.h>
 #include <linux/libcfs/libcfs.h>
 #include <uapi/linux/lnet/nidstr.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
deleted file mode 100644
index 1bbe1a779ae9..000000000000
--- a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
+++ /dev/null
@@ -1,44 +0,0 @@
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
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef LUSTRE_PATCHLESS_COMPAT_H
-#define LUSTRE_PATCHLESS_COMPAT_H
-
-#include <linux/fs.h>
-
-#include <linux/list.h>
-#include <linux/mm.h>
-#include <linux/hash.h>
-#include <linux/pagemap.h>
-
-#endif /* LUSTRE_PATCHLESS_COMPAT_H */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index b750a48fd0e1..0ae5185a4998 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -39,7 +39,6 @@
 #include <lustre_linkea.h>
 
 /* for struct cl_lock_descr and struct cl_io */
-#include <lustre_patchless_compat.h>
 #include <lustre_compat.h>
 #include <cl_object.h>
 #include <lustre_lmv.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 344ff4b20168..ee0898cbd9c9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -40,6 +40,8 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include <linux/uaccess.h>
+
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index b1060d02a164..98b114b8e93b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -39,6 +39,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include <linux/uaccess.h>
 #include <lustre_net.h>
 #include <lustre_swab.h>
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index cfae1294d77a..f1c99a2a466e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -38,6 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include <linux/highmem.h>
 #include "lov_cl_internal.h"
 
 /** \addtogroup lov
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index d6c46858941b..81a4c666bb69 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -36,6 +36,7 @@
 #include <linux/atomic.h>
 #include <linux/miscdevice.h>
 #include <linux/libcfs/libcfs.h>
+#include <linux/uaccess.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index bdbe6f52031a..a40ec42637e6 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/uaccess.h>
 #include <obd_class.h>
 #include <lprocfs_status.h>
 #include <uapi/linux/lustre/lustre_idl.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index ffc1814398a5..cfcd17e679dd 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/uaccess.h>
 #include <linux/string.h>
 
 #include <uapi/linux/lustre/lustre_ioctl.h>
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index b692e76e7108..484b8d6db6ef 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -33,6 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_ECHO
 
+#include <linux/highmem.h>
 #include <obd.h>
 #include <obd_support.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 6a705bc5420c..64931b97c887 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -32,6 +32,7 @@
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/uaccess.h>
 #include <linux/statfs.h>
 #include <obd_cksum.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 61ef6c8d7a12..bcb9b91aa5e0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -33,6 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
+#include <linux/highmem.h>
 #include <linux/libcfs/libcfs_hash.h>
 #include <linux/sched/mm.h>
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 0b638837f88b..a61e800cd2b5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -32,6 +32,7 @@
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/uaccess.h>
 #include <obd_support.h>
 #include <obd.h>
 #include <lprocfs_status.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index ec3d9af76b17..ead1df71a909 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
+#include <linux/highmem.h>
 #include <obd_support.h>
 #include <obd_cksum.h>
 #include <obd_class.h>
