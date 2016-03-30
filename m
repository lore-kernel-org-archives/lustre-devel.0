From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:49 -0400
Subject: [lustre-devel] [PATCH 17/43] staging/lustre: Remove struct ll_iattr
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This was a compat code from the time we had ia_attr_flags.
Instead convert all the cryptic callers that did
((struct ll_iattr *)&op_data->op_attr)->ia_attr_flags into
direct access to op_data->op_attr_flags

This also makes lustre/include/linux/obd.h not needed anymore,
so remove it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/linux/obd.h | 58 -----------------------
 drivers/staging/lustre/lustre/include/obd.h       |  2 +-
 drivers/staging/lustre/lustre/llite/file.c        |  4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c   |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c       |  3 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c     |  3 +-
 6 files changed, 6 insertions(+), 66 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/linux/obd.h

diff --git a/drivers/staging/lustre/lustre/include/linux/obd.h b/drivers/staging/lustre/lustre/include/linux/obd.h
deleted file mode 100644
index e1063e8..0000000
--- a/drivers/staging/lustre/lustre/include/linux/obd.h
+++ /dev/null
@@ -1,58 +0,0 @@
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
- * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef __LINUX_OBD_H
-#define __LINUX_OBD_H
-
-#ifndef __OBD_H
-#error Do not #include this file directly. #include <obd.h> instead
-#endif
-
-#include "../obd_support.h"
-
-#include <linux/fs.h>
-#include <linux/list.h>
-#include <linux/sched.h>  /* for struct task_struct, for current.h */
-#include <linux/mount.h>
-
-#include "../lustre_intent.h"
-
-struct ll_iattr {
-	struct iattr	iattr;
-	unsigned int	ia_attr_flags;
-};
-
-#endif /* __LINUX_OBD_H */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 84cc001..ded7b10 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -38,7 +38,6 @@
 #define __OBD_H
 
 #include <linux/spinlock.h>
-#include "linux/obd.h"
 
 #define IOC_OSC_TYPE	 'h'
 #define IOC_OSC_MIN_NR       20
@@ -55,6 +54,7 @@
 #include "lustre_export.h"
 #include "lustre_fid.h"
 #include "lustre_fld.h"
+#include "lustre_intent.h"
 
 #define MAX_OBD_DEVICES 8192
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index c3c258f..bf2a5ee 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -45,6 +45,7 @@
 #include "../include/lustre_lite.h"
 #include <linux/pagemap.h>
 #include <linux/file.h>
+#include <linux/mount.h>
 #include "llite_internal.h"
 #include "../include/lustre/ll_fiemap.h"
 
@@ -87,8 +88,7 @@ void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
 	op_data->op_attr.ia_ctime = inode->i_ctime;
 	op_data->op_attr.ia_size = i_size_read(inode);
 	op_data->op_attr_blocks = inode->i_blocks;
-	((struct ll_iattr *)&op_data->op_attr)->ia_attr_flags =
-					ll_inode_to_ext_flags(inode->i_flags);
+	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
 	op_data->op_ioepoch = ll_i2info(inode)->lli_ioepoch;
 	if (fh)
 		op_data->op_handle = *fh;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 041d221..0f01cfc 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1771,7 +1771,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		if (IS_ERR(op_data))
 			return PTR_ERR(op_data);
 
-		((struct ll_iattr *)&op_data->op_attr)->ia_attr_flags = flags;
+		op_data->op_attr_flags = flags;
 		op_data->op_attr.ia_valid |= ATTR_ATTR_FLAG;
 		rc = md_setattr(sbi->ll_md_exp, op_data,
 				NULL, 0, NULL, 0, &req, NULL);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index bd29eb7..be0acf7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -279,8 +279,7 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 	rec->sa_atime  = LTIME_S(op_data->op_attr.ia_atime);
 	rec->sa_mtime  = LTIME_S(op_data->op_attr.ia_mtime);
 	rec->sa_ctime  = LTIME_S(op_data->op_attr.ia_ctime);
-	rec->sa_attr_flags =
-			((struct ll_iattr *)&op_data->op_attr)->ia_attr_flags;
+	rec->sa_attr_flags = op_data->op_attr_flags;
 	if ((op_data->op_attr.ia_valid & ATTR_GID) &&
 	    in_group_p(op_data->op_attr.ia_gid))
 		rec->sa_suppgid =
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index e6436cb..748e33f 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -185,8 +185,7 @@ void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid)
 		op_data->op_attr.ia_valid |= ATTR_BLOCKS;
 	}
 	if (valid & OBD_MD_FLFLAGS) {
-		((struct ll_iattr *)&op_data->op_attr)->ia_attr_flags =
-			oa->o_flags;
+		op_data->op_attr_flags = oa->o_flags;
 		op_data->op_attr.ia_valid |= ATTR_ATTR_FLAG;
 	}
 }
-- 
2.1.0
