From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:38 -0400
Subject: [lustre-devel] [PATCH 039/124] staging: lustre: remove lustre_lite.h
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Move several definition only used in lustre/llite/ to
lustre/llite/llite_internal.h.
Remove lustre/include/{,linux/}lustre_lite.h and fixup
the missing includes in other headers that this exposes.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11501
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/linux/lustre_lite.h      |   91 --------------------
 .../staging/lustre/lustre/include/lustre_eacl.h    |    1 +
 .../staging/lustre/lustre/include/lustre_lite.h    |   85 ------------------
 .../staging/lustre/lustre/include/lustre_param.h   |    3 +
 drivers/staging/lustre/lustre/llite/dcache.c       |    1 -
 drivers/staging/lustre/lustre/llite/dir.c          |   12 +--
 drivers/staging/lustre/lustre/llite/file.c         |    1 -
 drivers/staging/lustre/lustre/llite/glimpse.c      |    1 -
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    1 -
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |    1 -
 drivers/staging/lustre/lustre/llite/llite_close.c  |    1 -
 .../staging/lustre/lustre/llite/llite_internal.h   |   61 +++++++++++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    1 -
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    1 -
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    1 -
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    1 -
 drivers/staging/lustre/lustre/llite/namei.c        |    1 -
 drivers/staging/lustre/lustre/llite/rw.c           |    1 -
 drivers/staging/lustre/lustre/llite/rw26.c         |    1 -
 drivers/staging/lustre/lustre/llite/statahead.c    |   13 +--
 drivers/staging/lustre/lustre/llite/super25.c      |    1 -
 drivers/staging/lustre/lustre/llite/symlink.c      |    1 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    1 -
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    1 -
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |    1 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    1 -
 drivers/staging/lustre/lustre/llite/vvp_page.c     |    2 -
 drivers/staging/lustre/lustre/llite/vvp_req.c      |    1 -
 drivers/staging/lustre/lustre/llite/xattr.c        |    1 -
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    1 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 -
 31 files changed, 70 insertions(+), 222 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/linux/lustre_lite.h
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_lite.h

diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
deleted file mode 100644
index d18e8a7..0000000
--- a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
+++ /dev/null
@@ -1,91 +0,0 @@
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
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#ifndef _LINUX_LL_H
-#define _LINUX_LL_H
-
-#ifndef _LL_H
-#error Do not #include this file directly. #include <lustre_lite.h> instead
-#endif
-
-#include <linux/statfs.h>
-
-#include <linux/fs.h>
-#include <linux/dcache.h>
-
-#include "../obd_class.h"
-#include "../lustre_net.h"
-#include "../lustre_ha.h"
-
-#include <linux/rbtree.h>
-#include "../../include/linux/lustre_compat25.h"
-#include <linux/pagemap.h>
-
-/* lprocfs.c */
-enum {
-	 LPROC_LL_DIRTY_HITS = 0,
-	 LPROC_LL_DIRTY_MISSES,
-	 LPROC_LL_READ_BYTES,
-	 LPROC_LL_WRITE_BYTES,
-	 LPROC_LL_BRW_READ,
-	 LPROC_LL_BRW_WRITE,
-	 LPROC_LL_OSC_READ,
-	 LPROC_LL_OSC_WRITE,
-	 LPROC_LL_IOCTL,
-	 LPROC_LL_OPEN,
-	 LPROC_LL_RELEASE,
-	 LPROC_LL_MAP,
-	 LPROC_LL_LLSEEK,
-	 LPROC_LL_FSYNC,
-	 LPROC_LL_READDIR,
-	 LPROC_LL_SETATTR,
-	 LPROC_LL_TRUNC,
-	 LPROC_LL_FLOCK,
-	 LPROC_LL_GETATTR,
-	 LPROC_LL_CREATE,
-	 LPROC_LL_LINK,
-	 LPROC_LL_UNLINK,
-	 LPROC_LL_SYMLINK,
-	 LPROC_LL_MKDIR,
-	 LPROC_LL_RMDIR,
-	 LPROC_LL_MKNOD,
-	 LPROC_LL_RENAME,
-	 LPROC_LL_STAFS,
-	 LPROC_LL_ALLOC_INODE,
-	 LPROC_LL_SETXATTR,
-	 LPROC_LL_GETXATTR,
-	 LPROC_LL_GETXATTR_HITS,
-	 LPROC_LL_LISTXATTR,
-	 LPROC_LL_REMOVEXATTR,
-	 LPROC_LL_INODE_PERM,
-	 LPROC_LL_FILE_OPCODES
-};
-
-#endif
diff --git a/drivers/staging/lustre/lustre/include/lustre_eacl.h b/drivers/staging/lustre/lustre/include/lustre_eacl.h
index d1039e1..1e71a86 100644
--- a/drivers/staging/lustre/lustre/include/lustre_eacl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_eacl.h
@@ -46,6 +46,7 @@
 
 #ifdef CONFIG_FS_POSIX_ACL
 
+#include <linux/fs.h>
 #include <linux/posix_acl_xattr.h>
 
 typedef struct {
diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
deleted file mode 100644
index 8333d76..0000000
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ /dev/null
@@ -1,85 +0,0 @@
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
-#ifndef _LL_H
-#define _LL_H
-
-/** \defgroup lite lite
- *
- * @{
- */
-
-#include "linux/lustre_lite.h"
-
-#include "obd_class.h"
-#include "lustre_net.h"
-#include "lustre_ha.h"
-
-/* 4UL * 1024 * 1024 */
-#define LL_MAX_BLKSIZE_BITS     (22)
-#define LL_MAX_BLKSIZE	  (1UL << LL_MAX_BLKSIZE_BITS)
-
-/*
- * This is embedded into llite super-blocks to keep track of
- * connect flags (capabilities) supported by all imports given mount is
- * connected to.
- */
-struct lustre_client_ocd {
-	/*
-	 * This is conjunction of connect_flags across all imports (LOVs) this
-	 * mount is connected to. This field is updated by cl_ocd_update()
-	 * under ->lco_lock.
-	 */
-	__u64	      lco_flags;
-	struct mutex	   lco_lock;
-	struct obd_export *lco_md_exp;
-	struct obd_export *lco_dt_exp;
-};
-
-/*
- * Chain of hash overflow pages.
- */
-struct ll_dir_chain {
-	/* XXX something. Later */
-};
-
-static inline void ll_dir_chain_init(struct ll_dir_chain *chain)
-{
-}
-
-static inline void ll_dir_chain_fini(struct ll_dir_chain *chain)
-{
-}
-
-/** @} lite */
-
-#endif
diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index 82aadd3..8061a04 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -39,6 +39,9 @@
 #ifndef _LUSTRE_PARAM_H
 #define _LUSTRE_PARAM_H
 
+#include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/lnet/types.h"
+
 /** \defgroup param param
  *
  * @{
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 8c00cc6..8500080 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -37,7 +37,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd_support.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_dlm.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 97815cf..234095e 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -48,7 +48,6 @@
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_lib.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_kernelcomm.h"
@@ -135,7 +134,7 @@
  *
  */
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 offset, struct ll_dir_chain *chain)
+			     __u64 offset)
 {
 	struct md_callback cb_op;
 	struct page *page;
@@ -202,13 +201,10 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 	int		   is_api32 = ll_need_32bit_api(sbi);
 	int		   is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
 	struct page	  *page;
-	struct ll_dir_chain   chain;
 	bool		   done = false;
 	int		   rc = 0;
 
-	ll_dir_chain_init(&chain);
-
-	page = ll_get_dir_page(inode, op_data, pos, &chain);
+	page = ll_get_dir_page(inode, op_data, pos);
 
 	while (rc == 0 && !done) {
 		struct lu_dirpage *dp;
@@ -286,13 +282,11 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
 			next = pos;
-			page = ll_get_dir_page(inode, op_data, pos,
-					       &chain);
+			page = ll_get_dir_page(inode, op_data, pos);
 		}
 	}
 
 	ctx->pos = pos;
-	ll_dir_chain_fini(&chain);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index d9ee255..127d0e0 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -38,7 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_lite.h"
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/sched.h>
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 92004a0..22507b9 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -42,7 +42,6 @@
 #include "../include/obd.h"
 
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_mdc.h"
 #include <linux/pagemap.h>
 #include <linux/file.h>
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index eed464b..2ded6b5 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -49,7 +49,6 @@
 #include "../include/obd.h"
 #include "../include/obd_support.h"
 #include "../include/lustre_fid.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_ver.h"
 #include "../include/lustre_mdc.h"
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index f6be105..fb346c1 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -38,7 +38,6 @@
 #include "../include/obd.h"
 #include "../include/cl_object.h"
 
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 
 /* Initialize the default and maximum LOV EA and cookie sizes.  This allows
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 2326b40..8644631 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -38,7 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 
 /** records that a write is in flight */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 7f0a6c9..f972ba3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -60,6 +60,9 @@
 #define LL_DIR_END_OFF	  0x7fffffffffffffffULL
 #define LL_DIR_END_OFF_32BIT    0x7fffffffUL
 
+/* 4UL * 1024 * 1024 */
+#define LL_MAX_BLKSIZE_BITS 22
+
 #define LL_IT2STR(it) ((it) ? ldlm_it2str((it)->it_op) : "0")
 #define LUSTRE_FPRIVATE(file) ((file)->private_data)
 
@@ -445,6 +448,23 @@ enum stats_track_type {
 	"norootsquash",	\
 }
 
+/*
+ * This is embedded into llite super-blocks to keep track of connect
+ * flags (capabilities) supported by all imports given mount is
+ * connected to.
+ */
+struct lustre_client_ocd {
+	/*
+	 * This is conjunction of connect_flags across all imports
+	 * (LOVs) this mount is connected to. This field is updated by
+	 * cl_ocd_update() under ->lco_lock.
+	 */
+	__u64			 lco_flags;
+	struct mutex		 lco_lock;
+	struct obd_export	*lco_md_exp;
+	struct obd_export	*lco_dt_exp;
+};
+
 struct ll_sb_info {
 	/* this protects pglist and ra_info.  It isn't safe to
 	 * grab from interrupt contexts
@@ -669,6 +689,45 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
 		       size_t count, int rw);
 
+enum {
+	LPROC_LL_DIRTY_HITS,
+	LPROC_LL_DIRTY_MISSES,
+	LPROC_LL_READ_BYTES,
+	LPROC_LL_WRITE_BYTES,
+	LPROC_LL_BRW_READ,
+	LPROC_LL_BRW_WRITE,
+	LPROC_LL_OSC_READ,
+	LPROC_LL_OSC_WRITE,
+	LPROC_LL_IOCTL,
+	LPROC_LL_OPEN,
+	LPROC_LL_RELEASE,
+	LPROC_LL_MAP,
+	LPROC_LL_LLSEEK,
+	LPROC_LL_FSYNC,
+	LPROC_LL_READDIR,
+	LPROC_LL_SETATTR,
+	LPROC_LL_TRUNC,
+	LPROC_LL_FLOCK,
+	LPROC_LL_GETATTR,
+	LPROC_LL_CREATE,
+	LPROC_LL_LINK,
+	LPROC_LL_UNLINK,
+	LPROC_LL_SYMLINK,
+	LPROC_LL_MKDIR,
+	LPROC_LL_RMDIR,
+	LPROC_LL_MKNOD,
+	LPROC_LL_RENAME,
+	LPROC_LL_STAFS,
+	LPROC_LL_ALLOC_INODE,
+	LPROC_LL_SETXATTR,
+	LPROC_LL_GETXATTR,
+	LPROC_LL_GETXATTR_HITS,
+	LPROC_LL_LISTXATTR,
+	LPROC_LL_REMOVEXATTR,
+	LPROC_LL_INODE_PERM,
+	LPROC_LL_FILE_OPCODES
+};
+
 /* llite/dir.c */
 extern const struct file_operations ll_dir_operations;
 extern const struct inode_operations ll_dir_inode_operations;
@@ -677,7 +736,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 int ll_get_mdt_idx(struct inode *inode);
 int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
-			     __u64 offset, struct ll_dir_chain *chain);
+			     __u64 offset);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
 
 /* llite/namei.c */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9112fa8..19d18e8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -42,7 +42,6 @@
 #include <linux/mm.h>
 
 #include "../include/lustre/lustre_ioctl.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_ha.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lprocfs_status.h"
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 37f82ed..0cd25bf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -43,7 +43,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 #include "../include/linux/lustre_compat25.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 1e156dc..7092305 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -38,7 +38,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LLITE
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 #include <linux/exportfs.h>
 
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index fc2ba56..6123435 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -31,7 +31,6 @@
  */
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lustre_lite.h"
 #include "../include/lprocfs_status.h"
 #include <linux/seq_file.h>
 #include "../include/obd_support.h"
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 7a82ae4..e2dc920 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -42,7 +42,6 @@
 
 #include "../include/obd_support.h"
 #include "../include/lustre_fid.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_ver.h"
 #include "llite_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index de20b7d..508cb46 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -50,7 +50,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lustre_lite.h"
 #include "../include/obd_cksum.h"
 #include "llite_internal.h"
 #include "../include/linux/lustre_compat25.h"
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 66dba04..6df89b0 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -51,7 +51,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 #include "../include/linux/lustre_compat25.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 6577a66..5760974 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -39,7 +39,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd_support.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "llite_internal.h"
 
@@ -1019,7 +1018,6 @@ static int ll_statahead_thread(void *arg)
 	int		       first  = 0;
 	int		       rc     = 0;
 	struct md_op_data *op_data;
-	struct ll_dir_chain       chain;
 	struct l_wait_info	lwi    = { 0 };
 
 	sai = ll_sai_get(dir);
@@ -1052,13 +1050,12 @@ static int ll_statahead_thread(void *arg)
 	spin_unlock(&lli->lli_sa_lock);
 	wake_up(&thread->t_ctl_waitq);
 
-	ll_dir_chain_init(&chain);
 	while (pos != MDS_DIR_END_OFF && thread_is_running(thread)) {
 		struct lu_dirpage *dp;
 		struct lu_dirent  *ent;
 
 		sai->sai_in_readpage = 1;
-		page = ll_get_dir_page(dir, op_data, pos, &chain);
+		page = ll_get_dir_page(dir, op_data, pos);
 		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
@@ -1146,7 +1143,6 @@ static int ll_statahead_thread(void *arg)
 			break;
 		}
 	}
-	ll_dir_chain_fini(&chain);
 	ll_finish_md_op_data(op_data);
 
 	if (rc < 0) {
@@ -1280,7 +1276,6 @@ enum {
 
 static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 {
-	struct ll_dir_chain   chain;
 	const struct qstr  *target = &dentry->d_name;
 	struct md_op_data *op_data;
 	struct page	  *page;
@@ -1297,8 +1292,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 	 */
 	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
 
-	ll_dir_chain_init(&chain);
-	page = ll_get_dir_page(dir, op_data, pos, &chain);
+	page = ll_get_dir_page(dir, op_data, pos);
 
 	while (1) {
 		struct lu_dirpage *dp;
@@ -1387,11 +1381,10 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 			ll_release_page(dir, page,
 					le32_to_cpu(dp->ldp_flags) &
 					LDF_COLLIDE);
-			page = ll_get_dir_page(dir, op_data, pos, &chain);
+			page = ll_get_dir_page(dir, op_data, pos);
 		}
 	}
 out:
-	ll_dir_chain_fini(&chain);
 	ll_finish_md_op_data(op_data);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 24c79c2..106cd00 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -34,7 +34,6 @@
 
 #include <linux/module.h>
 #include <linux/types.h>
-#include "../include/lustre_lite.h"
 #include "../include/lustre_ha.h"
 #include "../include/lustre_dlm.h"
 #include <linux/init.h>
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 47fb799..f8bc7ed 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -35,7 +35,6 @@
 #include <linux/stat.h>
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 
 static int ll_readlink_internal(struct inode *inode,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 771c0bd..8aa8ecc 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -38,7 +38,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd.h"
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index f6dacee..27fc0b0 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -38,7 +38,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd.h"
-#include "../include/lustre_lite.h"
 
 #include "llite_internal.h"
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index 64be0c9..07eb26c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -37,7 +37,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd_support.h"
-#include "../include/lustre_lite.h"
 
 #include "vvp_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index e4080ba..01725fb 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -39,7 +39,6 @@
 #include "../../include/linux/libcfs/libcfs.h"
 
 #include "../include/obd.h"
-#include "../include/lustre_lite.h"
 
 #include "llite_internal.h"
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index bbbb0f1..e763e7f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -44,8 +44,6 @@
 #include <linux/page-flags.h>
 #include <linux/pagemap.h>
 
-#include "../include/lustre_lite.h"
-
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
index 0567a15..a6e2672 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_req.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_req.c
@@ -32,7 +32,6 @@
 #include "../include/cl_object.h"
 #include "../include/obd.h"
 #include "../include/obd_support.h"
-#include "../include/lustre_lite.h"
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 7b8d469..17ad04f 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -38,7 +38,6 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd_support.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_ver.h"
 #include "../include/lustre_eacl.h"
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 0330d1a..50a19a4 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -13,7 +13,6 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include "../include/obd_support.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_ver.h"
 #include "llite_internal.h"
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e1fac0b..208a44d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -43,13 +43,11 @@
 
 #include "../include/lustre/lustre_idl.h"
 #include "../include/obd_support.h"
-#include "../include/lustre_lib.h"
 #include "../include/lustre_net.h"
 #include "../include/obd_class.h"
 #include "../include/lustre_lmv.h"
 #include "../include/lprocfs_status.h"
 #include "../include/cl_object.h"
-#include "../include/lustre_lite.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre/lustre_ioctl.h"
 #include "../include/lustre_kernelcomm.h"
-- 
1.7.1
