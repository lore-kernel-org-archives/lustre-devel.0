From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:45 -0400
Subject: [lustre-devel] [PATCH 11/29] staging: lustre: llite: basic support
	of SELinux in CLIO
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sebastien.buisson@bull.net>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sebastien.buisson@bull.net>

Bring the ability to properly initiate security context
on SELinux-enabled client and store it on server side via
extended attribute.

Security context initialization is not atomic, but that would
require a wire protocol change to send security label in the
creation request.

Filter out security.selinux from xattr cache as it is
already cached in system slab.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5560
Reviewed-on: http://review.whamcloud.com/11648
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/Makefile       |    6 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   11 +++
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +
 drivers/staging/lustre/lustre/llite/namei.c        |    5 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   60 ++++++--------
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    4 +
 .../staging/lustre/lustre/llite/xattr_security.c   |   88 ++++++++++++++++++++
 7 files changed, 140 insertions(+), 38 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/llite/xattr_security.c

diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 3690bee..ca9c275 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -1,7 +1,7 @@
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
-	    rw.o namei.o symlink.o llite_mmap.o range_lock.o \
-	    xattr.o xattr_cache.o rw26.o super25.o statahead.o \
-	    glimpse.o lcommon_cl.o lcommon_misc.o \
+	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
+	    xattr.o xattr_cache.o xattr_security.o \
+	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o vvp_req.o \
 	    lproc_llite.o
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 6e744a5..fb367ae 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -410,6 +410,8 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
 	struct ll_sb_info *sbi = ll_i2sbi(parent);
+	struct inode *inode = NULL;
+	struct dentry dentry;
 	int err;
 
 	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
@@ -443,8 +445,17 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 			from_kgid(&init_user_ns, current_fsgid()),
 			cfs_curproc_cap_pack(), 0, &request);
 	ll_finish_md_op_data(op_data);
+
+	err = ll_prep_inode(&inode, request, parent->i_sb, NULL);
 	if (err)
 		goto err_exit;
+
+	memset(&dentry, 0, sizeof(dentry));
+	dentry.d_inode = inode;
+
+	err = ll_init_security(&dentry, inode, parent);
+	iput(inode);
+
 err_exit:
 	ptlrpc_req_finished(request);
 	return err;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 80fb862..8bd1eb8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -261,6 +261,9 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, __u32 gen)
 int ll_xattr_cache_get(struct inode *inode, const char *name,
 		       char *buffer, size_t size, __u64 valid);
 
+int ll_init_security(struct dentry *dentry, struct inode *inode,
+		     struct inode *dir);
+
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
  * consistency between file size and KMS.
@@ -998,6 +1001,7 @@ static inline loff_t ll_file_maxbytes(struct inode *inode)
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size);
 int ll_xattr_list(struct inode *inode, const char *name, int type,
 		  void *buffer, size_t size, __u64 valid);
+const struct xattr_handler *get_xattr_type(const char *name);
 
 /**
  * Common IO arguments for various VFS I/O interfaces.
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 89fd441..74d9b73 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -790,7 +790,8 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 		return PTR_ERR(inode);
 
 	d_instantiate(dentry, inode);
-	return 0;
+
+	return ll_init_security(dentry, inode, dir);
 }
 
 void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
@@ -885,6 +886,8 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		goto err_exit;
 
 	d_instantiate(dentry, inode);
+
+	err = ll_init_security(dentry, inode, dir);
 err_exit:
 	if (request)
 		ptlrpc_req_finished(request);
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index b8b5c32..3ae1a02 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -44,48 +44,39 @@
 
 #include "llite_internal.h"
 
-static
-int get_xattr_type(const char *name)
+const struct xattr_handler *get_xattr_type(const char *name)
 {
-	if (!strcmp(name, XATTR_NAME_POSIX_ACL_ACCESS))
-		return XATTR_ACL_ACCESS_T;
+	int i = 0;
 
-	if (!strcmp(name, XATTR_NAME_POSIX_ACL_DEFAULT))
-		return XATTR_ACL_DEFAULT_T;
+	while (ll_xattr_handlers[i]) {
+		size_t len = strlen(ll_xattr_handlers[i]->prefix);
 
-	if (!strncmp(name, XATTR_USER_PREFIX,
-		     sizeof(XATTR_USER_PREFIX) - 1))
-		return XATTR_USER_T;
-
-	if (!strncmp(name, XATTR_TRUSTED_PREFIX,
-		     sizeof(XATTR_TRUSTED_PREFIX) - 1))
-		return XATTR_TRUSTED_T;
-
-	if (!strncmp(name, XATTR_SECURITY_PREFIX,
-		     sizeof(XATTR_SECURITY_PREFIX) - 1))
-		return XATTR_SECURITY_T;
-
-	if (!strncmp(name, XATTR_LUSTRE_PREFIX,
-		     sizeof(XATTR_LUSTRE_PREFIX) - 1))
-		return XATTR_LUSTRE_T;
-
-	return XATTR_OTHER_T;
+		if (!strncmp(ll_xattr_handlers[i]->prefix, name, len))
+			return ll_xattr_handlers[i];
+		i++;
+	}
+	return NULL;
 }
 
-static
-int xattr_type_filter(struct ll_sb_info *sbi, int xattr_type)
+static int xattr_type_filter(struct ll_sb_info *sbi,
+			     const struct xattr_handler *handler)
 {
-	if ((xattr_type == XATTR_ACL_ACCESS_T ||
-	     xattr_type == XATTR_ACL_DEFAULT_T) &&
+	/* No handler means XATTR_OTHER_T */
+	if (!handler)
+		return -EOPNOTSUPP;
+
+	if ((handler->flags == XATTR_ACL_ACCESS_T ||
+	     handler->flags == XATTR_ACL_DEFAULT_T) &&
 	   !(sbi->ll_flags & LL_SBI_ACL))
 		return -EOPNOTSUPP;
 
-	if (xattr_type == XATTR_USER_T && !(sbi->ll_flags & LL_SBI_USER_XATTR))
+	if (handler->flags == XATTR_USER_T &&
+	    !(sbi->ll_flags & LL_SBI_USER_XATTR))
 		return -EOPNOTSUPP;
-	if (xattr_type == XATTR_TRUSTED_T && !capable(CFS_CAP_SYS_ADMIN))
+
+	if (handler->flags == XATTR_TRUSTED_T &&
+	    !capable(CFS_CAP_SYS_ADMIN))
 		return -EPERM;
-	if (xattr_type == XATTR_OTHER_T)
-		return -EOPNOTSUPP;
 
 	return 0;
 }
@@ -111,7 +102,7 @@ int xattr_type_filter(struct ll_sb_info *sbi, int xattr_type)
 		valid = OBD_MD_FLXATTR;
 	}
 
-	rc = xattr_type_filter(sbi, handler->flags);
+	rc = xattr_type_filter(sbi, handler);
 	if (rc)
 		return rc;
 
@@ -225,7 +216,8 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 	void *xdata;
 	int rc;
 
-	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T) {
+	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T &&
+	    (type != XATTR_SECURITY_T || strcmp(name, "security.selinux"))) {
 		rc = ll_xattr_cache_get(inode, name, buffer, size, valid);
 		if (rc == -EAGAIN)
 			goto getxattr_nocache;
@@ -313,7 +305,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
 
-	rc = xattr_type_filter(sbi, handler->flags);
+	rc = xattr_type_filter(sbi, handler);
 	if (rc)
 		return rc;
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 50a19a4..47c1d11 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -415,6 +415,10 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 			CDEBUG(D_CACHE, "not caching %s\n",
 			       XATTR_NAME_ACL_ACCESS);
 			rc = 0;
+		} else if (!strcmp(xdata, "security.selinux")) {
+			/* Filter out security.selinux, it is cached in slab */
+			CDEBUG(D_CACHE, "not caching security.selinux\n");
+			rc = 0;
 		} else {
 			rc = ll_xattr_cache_add(&lli->lli_xattrs, xdata, xval,
 						*xsizes);
diff --git a/drivers/staging/lustre/lustre/llite/xattr_security.c b/drivers/staging/lustre/lustre/llite/xattr_security.c
new file mode 100644
index 0000000..d61d801
--- /dev/null
+++ b/drivers/staging/lustre/lustre/llite/xattr_security.c
@@ -0,0 +1,88 @@
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
+ * version 2 along with this program; If not, see http://www.gnu.org/licenses
+ *
+ * GPL HEADER END
+ */
+
+/*
+ * Copyright (c) 2014 Bull SAS
+ * Author: Sebastien Buisson sebastien.buisson at bull.net
+ */
+
+/*
+ * lustre/llite/xattr_security.c
+ * Handler for storing security labels as extended attributes.
+ */
+#include <linux/security.h>
+#include <linux/xattr.h>
+#include "llite_internal.h"
+
+/**
+ * A helper function for ll_security_inode_init_security()
+ * that takes care of setting xattrs
+ *
+ * Get security context of @inode from @xattr_array,
+ * and put it in 'security.xxx' xattr of dentry
+ * stored in @fs_info.
+ *
+ * \retval 0        success
+ * \retval -ENOMEM  if no memory could be allocated for xattr name
+ * \retval < 0      failure to set xattr
+ */
+static int
+ll_initxattrs(struct inode *inode, const struct xattr *xattr_array,
+	      void *fs_info)
+{
+	const struct xattr_handler *handler;
+	struct dentry *dentry = fs_info;
+	const struct xattr *xattr;
+	int err = 0;
+
+	handler = get_xattr_type(XATTR_SECURITY_PREFIX);
+	if (!handler)
+		return -ENXIO;
+
+	for (xattr = xattr_array; xattr->name; xattr++) {
+		err = handler->set(handler, dentry, inode, xattr->name,
+				   xattr->value, xattr->value_len,
+				   XATTR_CREATE);
+		if (err < 0)
+			break;
+	}
+	return err;
+}
+
+/**
+ * Initializes security context
+ *
+ * Get security context of @inode in @dir,
+ * and put it in 'security.xxx' xattr of @dentry.
+ *
+ * \retval 0        success, or SELinux is disabled
+ * \retval -ENOMEM  if no memory could be allocated for xattr name
+ * \retval < 0      failure to get security context or set xattr
+ */
+int
+ll_init_security(struct dentry *dentry, struct inode *inode, struct inode *dir)
+{
+	if (!selinux_is_enabled())
+		return 0;
+
+	return security_inode_init_security(inode, dir, NULL,
+					    &ll_initxattrs, dentry);
+}
-- 
1.7.1
