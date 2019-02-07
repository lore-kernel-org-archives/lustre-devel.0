From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 18/21] lustre: move debug.c from obdclass to
 obdecho
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781337.10620.11481546344215316629.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The functions defined in debug.c are only used in
obdecho, so move it there, and make the functions local
to that unit.
This allows lustre_debug.h to be removed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_debug.h   |   52 -----------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    1 
 drivers/staging/lustre/lustre/obdclass/debug.c     |   96 --------------------
 drivers/staging/lustre/lustre/obdecho/Makefile     |    2 
 drivers/staging/lustre/lustre/obdecho/debug.c      |   96 ++++++++++++++++++++
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 
 .../staging/lustre/lustre/obdecho/echo_internal.h  |    4 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |    1 
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    1 
 11 files changed, 103 insertions(+), 155 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_debug.h
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/debug.c
 create mode 100644 drivers/staging/lustre/lustre/obdecho/debug.c

diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
deleted file mode 100644
index b9414fc73f00..000000000000
--- a/drivers/staging/lustre/lustre/include/lustre_debug.h
+++ /dev/null
@@ -1,52 +0,0 @@
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
- * Copyright (c) 2011, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef _LUSTRE_DEBUG_H
-#define _LUSTRE_DEBUG_H
-
-/** \defgroup debug debug
- *
- * @{
- */
-
-#include <lustre_net.h>
-#include <obd.h>
-
-/* lib/debug.c */
-int dump_req(struct ptlrpc_request *req);
-int block_debug_setup(void *addr, int len, u64 off, u64 id);
-int block_debug_check(char *who, void *addr, int len, u64 off, u64 id);
-
-/** @} debug */
-
-#endif
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index bf7e46fe9ec6..c8860904bdd4 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -33,7 +33,7 @@
 
 #ifndef LLITE_INTERNAL_H
 #define LLITE_INTERNAL_H
-#include <lustre_debug.h>
+#include <obd.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 #include <lustre_disk.h>	/* for s2sbi */
 #include <lustre_linkea.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index b1fac48b3adc..1669c24a0b03 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -4,7 +4,7 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
-obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
+obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      genops.o obd_sysfs.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 982d47b6f50e..4a717a29e385 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -41,7 +41,6 @@
 #include <obd_support.h>
 #include <obd_class.h>
 #include <uapi/linux/lnet/lnetctl.h>
-#include <lustre_debug.h>
 #include <lustre_kernelcomm.h>
 #include <lprocfs_status.h>
 #include <linux/list.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
deleted file mode 100644
index 2e526c7389d8..000000000000
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ /dev/null
@@ -1,96 +0,0 @@
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
- * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/obdclass/debug.c
- *
- * Helper routines for dumping data structs for debugging.
- */
-
-#define DEBUG_SUBSYSTEM D_OTHER
-
-#include <asm/unaligned.h>
-
-#include <obd_support.h>
-#include <lustre_debug.h>
-#include <lustre_net.h>
-
-#define LPDS sizeof(u64)
-int block_debug_setup(void *addr, int len, u64 off, u64 id)
-{
-	LASSERT(addr);
-
-	put_unaligned_le64(off, addr);
-	put_unaligned_le64(id, addr + LPDS);
-	addr += len - LPDS - LPDS;
-	put_unaligned_le64(off, addr);
-	put_unaligned_le64(id, addr + LPDS);
-
-	return 0;
-}
-EXPORT_SYMBOL(block_debug_setup);
-
-int block_debug_check(char *who, void *addr, int end, u64 off, u64 id)
-{
-	u64 ne_off;
-	int err = 0;
-
-	LASSERT(addr);
-
-	ne_off = le64_to_cpu(off);
-	id = le64_to_cpu(id);
-	if (memcmp(addr, (char *)&ne_off, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu off: %#llx != %#llx\n",
-		       who, id, off, *(u64 *)addr, ne_off);
-		err = -EINVAL;
-	}
-	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu id: %#llx != %#llx\n",
-		       who, id, off, *(u64 *)(addr + LPDS), id);
-		err = -EINVAL;
-	}
-
-	addr += end - LPDS - LPDS;
-	if (memcmp(addr, (char *)&ne_off, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end off: %#llx != %#llx\n",
-		       who, id, off, *(u64 *)addr, ne_off);
-		err = -EINVAL;
-	}
-	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end id: %#llx != %#llx\n",
-		       who, id, off, *(u64 *)(addr + LPDS), id);
-		err = -EINVAL;
-	}
-
-	return err;
-}
-EXPORT_SYMBOL(block_debug_check);
-#undef LPDS
diff --git a/drivers/staging/lustre/lustre/obdecho/Makefile b/drivers/staging/lustre/lustre/obdecho/Makefile
index ff85ef1db70a..0a02efae036d 100644
--- a/drivers/staging/lustre/lustre/obdecho/Makefile
+++ b/drivers/staging/lustre/lustre/obdecho/Makefile
@@ -2,4 +2,4 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += obdecho.o
-obdecho-y := echo_client.o
+obdecho-y := echo_client.o debug.o
diff --git a/drivers/staging/lustre/lustre/obdecho/debug.c b/drivers/staging/lustre/lustre/obdecho/debug.c
new file mode 100644
index 000000000000..149aca54c776
--- /dev/null
+++ b/drivers/staging/lustre/lustre/obdecho/debug.c
@@ -0,0 +1,96 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2012, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/obdclass/debug.c
+ *
+ * Helper routines for dumping data structs for debugging.
+ */
+
+#define DEBUG_SUBSYSTEM D_OTHER
+
+#include <asm/unaligned.h>
+
+#include <obd_support.h>
+#include "echo_internal.h"
+#include <lustre_net.h>
+
+#define LPDS sizeof(u64)
+int block_debug_setup(void *addr, int len, u64 off, u64 id)
+{
+	LASSERT(addr);
+
+	put_unaligned_le64(off, addr);
+	put_unaligned_le64(id, addr + LPDS);
+	addr += len - LPDS - LPDS;
+	put_unaligned_le64(off, addr);
+	put_unaligned_le64(id, addr + LPDS);
+
+	return 0;
+}
+EXPORT_SYMBOL(block_debug_setup);
+
+int block_debug_check(char *who, void *addr, int end, u64 off, u64 id)
+{
+	u64 ne_off;
+	int err = 0;
+
+	LASSERT(addr);
+
+	ne_off = le64_to_cpu(off);
+	id = le64_to_cpu(id);
+	if (memcmp(addr, (char *)&ne_off, LPDS)) {
+		CDEBUG(D_ERROR, "%s: id %#llx offset %llu off: %#llx != %#llx\n",
+		       who, id, off, *(u64 *)addr, ne_off);
+		err = -EINVAL;
+	}
+	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
+		CDEBUG(D_ERROR, "%s: id %#llx offset %llu id: %#llx != %#llx\n",
+		       who, id, off, *(u64 *)(addr + LPDS), id);
+		err = -EINVAL;
+	}
+
+	addr += end - LPDS - LPDS;
+	if (memcmp(addr, (char *)&ne_off, LPDS)) {
+		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end off: %#llx != %#llx\n",
+		       who, id, off, *(u64 *)addr, ne_off);
+		err = -EINVAL;
+	}
+	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
+		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end id: %#llx != %#llx\n",
+		       who, id, off, *(u64 *)(addr + LPDS), id);
+		err = -EINVAL;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL(block_debug_check);
+#undef LPDS
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 1ebd98513239..1b7d98c649b6 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -37,7 +37,6 @@
 #include <obd.h>
 #include <obd_support.h>
 #include <obd_class.h>
-#include <lustre_debug.h>
 #include <lprocfs_status.h>
 #include <cl_object.h>
 #include <lustre_fid.h>
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
index 8094a94f605c..f9bb0b91d399 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_internal.h
+++ b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
@@ -39,4 +39,8 @@
 /* block size to use for data verification */
 #define OBD_ECHO_BLOCK_SIZE	(4 << 10)
 
+/* debug.c */
+int block_debug_setup(void *addr, int len, u64 off, u64 id);
+int block_debug_check(char *who, void *addr, int len, u64 off, u64 id);
+
 #endif
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0dfc506f6d01..3fedfaf249c4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -45,7 +45,6 @@
 #include <lustre_ha.h>
 #include <lprocfs_status.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
-#include <lustre_debug.h>
 #include <lustre_obdo.h>
 #include <uapi/linux/lustre/lustre_param.h>
 #include <lustre_fid.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index f1f7d70b9790..d9f2b3d9e526 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -50,7 +50,6 @@
 #include <uapi/linux/lustre/lustre_idl.h>
 
 #include <llog_swab.h>
-#include <lustre_debug.h>
 #include <lustre_swab.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 #include <obd.h>
