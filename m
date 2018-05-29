From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:40 -0400
Subject: [lustre-devel] [PATCH v2 1/6] staging: lustre: llite: create acl.c
 file
In-Reply-To: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603705-30450-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Move ll_get_acl() to its own file acl.c just like all the other
linux file systems do.

Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch to add acl.c file which contains acl handling
    for lustre

 drivers/staging/lustre/lustre/llite/Makefile       |  2 +
 drivers/staging/lustre/lustre/llite/acl.c          | 51 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/file.c         | 13 ------
 .../staging/lustre/lustre/llite/llite_internal.h   |  5 +++
 4 files changed, 58 insertions(+), 13 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/llite/acl.c

diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 519fd74..5200924 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -9,3 +9,5 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o \
 	    lproc_llite.o
+
+lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
diff --git a/drivers/staging/lustre/lustre/llite/acl.c b/drivers/staging/lustre/lustre/llite/acl.c
new file mode 100644
index 0000000..d7c3bf9
--- /dev/null
+++ b/drivers/staging/lustre/lustre/llite/acl.c
@@ -0,0 +1,51 @@
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
+ * Copyright (c) 2011, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lustre/llite/acl.c
+ */
+
+#define DEBUG_SUBSYSTEM S_LLITE
+
+#include "llite_internal.h"
+
+struct posix_acl *ll_get_acl(struct inode *inode, int type)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct posix_acl *acl = NULL;
+
+	spin_lock(&lli->lli_lock);
+	/* VFS' acl_permission_check->check_acl will release the refcount */
+	acl = posix_acl_dup(lli->lli_posix_acl);
+	spin_unlock(&lli->lli_lock);
+
+	return acl;
+}
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index a77cadc..ccbf91b 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3030,19 +3030,6 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 	return rc;
 }
 
-struct posix_acl *ll_get_acl(struct inode *inode, int type)
-{
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct posix_acl *acl = NULL;
-
-	spin_lock(&lli->lli_lock);
-	/* VFS' acl_permission_check->check_acl will release the refcount */
-	acl = posix_acl_dup(lli->lli_posix_acl);
-	spin_unlock(&lli->lli_lock);
-
-	return acl;
-}
-
 int ll_inode_permission(struct inode *inode, int mask)
 {
 	struct ll_sb_info *sbi;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 379d88e..bdb1564 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -754,7 +754,12 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
+#ifdef CONFIG_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
+#else
+#define ll_get_acl NULL
+#endif /* CONFIG_FS_POSIX_ACL */
+
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen);
 int ll_get_fid_by_name(struct inode *parent, const char *name,
-- 
1.8.3.1
