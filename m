From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Jul 2016 09:40:10 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: llite: basic port to
	xattr_handler API
Message-ID: <1468244410-7875-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Port the xattr functionality to the new xattr_handler API.
This is smallest changes needed to move to this new API. The
function ll_removexattr can be replaced by generic_removexattr
as well since it also uses the xattr_handler set xattr backend.
To tell the difference between the two cases we test the flag
passed in for XATTR_REPLACE. The ll_getxattr function is
replaced by the generic_getxattr function.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         |    6 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    8 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    1 +
 drivers/staging/lustre/lustre/llite/namei.c        |   12 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |    6 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  195 +++++++++++++-------
 6 files changed, 141 insertions(+), 87 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 57281b9..58a7401 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3213,10 +3213,10 @@ const struct inode_operations ll_file_inode_operations = {
 	.setattr	= ll_setattr,
 	.getattr	= ll_getattr,
 	.permission	= ll_inode_permission,
-	.setxattr	= ll_setxattr,
-	.getxattr	= ll_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= ll_listxattr,
-	.removexattr	= ll_removexattr,
+	.removexattr	= generic_removexattr,
 	.fiemap		= ll_fiemap,
 	.get_acl	= ll_get_acl,
 };
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 4d6d589..27d3f77 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -42,6 +42,7 @@
 #include "../include/lustre_mdc.h"
 #include "../include/lustre_intent.h"
 #include <linux/compat.h>
+#include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
 #include "vvp_internal.h"
 
@@ -933,12 +934,9 @@ static inline __u64 ll_file_maxbytes(struct inode *inode)
 }
 
 /* llite/xattr.c */
-int ll_setxattr(struct dentry *dentry, struct inode *inode,
-		const char *name, const void *value, size_t size, int flags);
-ssize_t ll_getxattr(struct dentry *dentry, struct inode *inode,
-		    const char *name, void *buffer, size_t size);
+extern const struct xattr_handler *ll_xattr_handlers[];
+
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size);
-int ll_removexattr(struct dentry *dentry, const char *name);
 
 /**
  * Common IO arguments for various VFS I/O interfaces.
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 546063e..75d568f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -418,6 +418,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	CDEBUG(D_SUPER, "rootfid "DFID"\n", PFID(&sbi->ll_root_fid));
 
 	sb->s_op = &lustre_super_operations;
+	sb->s_xattr = ll_xattr_handlers;
 #if THREAD_SIZE >= 8192 /*b=17630*/
 	sb->s_export_op = &lustre_export_operations;
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 3664bfd..1e75f5b 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -1101,10 +1101,10 @@ const struct inode_operations ll_dir_inode_operations = {
 	.setattr	    = ll_setattr,
 	.getattr	    = ll_getattr,
 	.permission	 = ll_inode_permission,
-	.setxattr	   = ll_setxattr,
-	.getxattr	   = ll_getxattr,
+	.setxattr	   = generic_setxattr,
+	.getxattr	   = generic_getxattr,
 	.listxattr	  = ll_listxattr,
-	.removexattr	= ll_removexattr,
+	.removexattr	= generic_removexattr,
 	.get_acl	    = ll_get_acl,
 };
 
@@ -1112,9 +1112,9 @@ const struct inode_operations ll_special_inode_operations = {
 	.setattr	= ll_setattr,
 	.getattr	= ll_getattr,
 	.permission     = ll_inode_permission,
-	.setxattr       = ll_setxattr,
-	.getxattr       = ll_getxattr,
+	.setxattr       = generic_setxattr,
+	.getxattr       = generic_getxattr,
 	.listxattr      = ll_listxattr,
-	.removexattr    = ll_removexattr,
+	.removexattr    = generic_removexattr,
 	.get_acl	    = ll_get_acl,
 };
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 8c8bdfe..4601be9 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -155,8 +155,8 @@ const struct inode_operations ll_fast_symlink_inode_operations = {
 	.get_link	= ll_get_link,
 	.getattr	= ll_getattr,
 	.permission	= ll_inode_permission,
-	.setxattr	= ll_setxattr,
-	.getxattr	= ll_getxattr,
+	.setxattr	= generic_setxattr,
+	.getxattr	= generic_getxattr,
 	.listxattr	= ll_listxattr,
-	.removexattr	= ll_removexattr,
+	.removexattr	= generic_removexattr,
 };
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index a034a5f..a02b802 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -99,46 +99,57 @@ int xattr_type_filter(struct ll_sb_info *sbi, int xattr_type)
 	return 0;
 }
 
-static
-int ll_setxattr_common(struct inode *inode, const char *name,
-		       const void *value, size_t size,
-		       int flags, __u64 valid)
+static int
+ll_xattr_set_common(const struct xattr_handler *handler,
+		    struct dentry *dentry, struct inode *inode,
+		    const char *name, const void *value, size_t size,
+		    int flags)
 {
+	char fullname[strlen(handler->prefix) + strlen(name) + 1];
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
-	int xattr_type, rc;
 	const char *pv = value;
+	__u64 valid;
+	int rc;
 
-	xattr_type = get_xattr_type(name);
-	rc = xattr_type_filter(sbi, xattr_type);
+	if (flags == XATTR_REPLACE) {
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_REMOVEXATTR, 1);
+		valid = OBD_MD_FLXATTRRM;
+	} else {
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
+		valid = OBD_MD_FLXATTR;
+	}
+
+	rc = xattr_type_filter(sbi, handler->flags);
 	if (rc)
 		return rc;
 
-	if ((xattr_type == XATTR_ACL_ACCESS_T ||
-	     xattr_type == XATTR_ACL_DEFAULT_T) &&
+	if ((handler->flags == XATTR_ACL_ACCESS_T ||
+	     handler->flags == XATTR_ACL_DEFAULT_T) &&
 	    !inode_owner_or_capable(inode))
 		return -EPERM;
 
 	/* b10667: ignore lustre special xattr for now */
-	if ((xattr_type == XATTR_TRUSTED_T && strcmp(name, "trusted.lov") == 0) ||
-	    (xattr_type == XATTR_LUSTRE_T && strcmp(name, "lustre.lov") == 0))
+	if ((handler->flags == XATTR_TRUSTED_T && !strcmp(name, "lov")) ||
+	    (handler->flags == XATTR_LUSTRE_T && !strcmp(name, "lov")))
 		return 0;
 
 	/* b15587: ignore security.capability xattr for now */
-	if ((xattr_type == XATTR_SECURITY_T &&
-	     strcmp(name, "security.capability") == 0))
+	if ((handler->flags == XATTR_SECURITY_T &&
+	     !strcmp(name, "capability")))
 		return 0;
 
 	/* LU-549:  Disable security.selinux when selinux is disabled */
-	if (xattr_type == XATTR_SECURITY_T && !selinux_is_enabled() &&
-	    strcmp(name, "security.selinux") == 0)
+	if (handler->flags == XATTR_SECURITY_T && !selinux_is_enabled() &&
+	    strcmp(name, "selinux") == 0)
 		return -EOPNOTSUPP;
 
+	sprintf(fullname, "%s%s\n", handler->prefix, name);
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-			 valid, name, pv, size, 0, flags,
+			 valid, fullname, pv, size, 0, flags,
 			 ll_i2suppgid(inode), &req);
 	if (rc) {
-		if (rc == -EOPNOTSUPP && xattr_type == XATTR_USER_T) {
+		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
 			sbi->ll_flags &= ~LL_SBI_USER_XATTR;
 		}
@@ -149,8 +160,10 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 	return 0;
 }
 
-int ll_setxattr(struct dentry *dentry, struct inode *inode,
-		const char *name, const void *value, size_t size, int flags)
+static int ll_xattr_set(const struct xattr_handler *handler,
+			struct dentry *dentry, struct inode *inode,
+			const char *name, const void *value, size_t size,
+			int flags)
 {
 	LASSERT(inode);
 	LASSERT(name);
@@ -158,20 +171,24 @@ int ll_setxattr(struct dentry *dentry, struct inode *inode,
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
 	       PFID(ll_inode2fid(inode)), inode, name);
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
-
-	if ((strncmp(name, XATTR_TRUSTED_PREFIX,
-		     sizeof(XATTR_TRUSTED_PREFIX) - 1) == 0 &&
-	     strcmp(name + sizeof(XATTR_TRUSTED_PREFIX) - 1, "lov") == 0) ||
-	    (strncmp(name, XATTR_LUSTRE_PREFIX,
-		     sizeof(XATTR_LUSTRE_PREFIX) - 1) == 0 &&
-	     strcmp(name + sizeof(XATTR_LUSTRE_PREFIX) - 1, "lov") == 0)) {
+	if (!strcmp(name, "lov")) {
 		struct lov_user_md *lump = (struct lov_user_md *)value;
+		int op_type = flags == XATTR_REPLACE ? LPROC_LL_REMOVEXATTR :
+						       LPROC_LL_SETXATTR;
 		int rc = 0;
 
+		ll_stats_ops_tally(ll_i2sbi(inode), op_type, 1);
+
 		if (size != 0 && size < sizeof(struct lov_user_md))
 			return -EINVAL;
 
+		/*
+		 * It is possible to set an xattr to a "" value of zero size.
+		 * For this case we are going to treat it as a removal.
+		 */
+		if (!size && lump)
+			lump = NULL;
+
 		/* Attributes that are saved via getxattr will always have
 		 * the stripe_offset as 0.  Instead, the MDS should be
 		 * allowed to pick the starting OST index.   b=17846
@@ -194,27 +211,13 @@ int ll_setxattr(struct dentry *dentry, struct inode *inode,
 
 		return rc;
 
-	} else if (strcmp(name, XATTR_NAME_LMA) == 0 ||
-		   strcmp(name, XATTR_NAME_LINK) == 0)
+	} else if (!strcmp(name, "lma") || !strcmp(name, "link")) {
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
 		return 0;
+	}
 
-	return ll_setxattr_common(inode, name, value, size, flags,
-				  OBD_MD_FLXATTR);
-}
-
-int ll_removexattr(struct dentry *dentry, const char *name)
-{
-	struct inode *inode = d_inode(dentry);
-
-	LASSERT(inode);
-	LASSERT(name);
-
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
-	       PFID(ll_inode2fid(inode)), inode, name);
-
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_REMOVEXATTR, 1);
-	return ll_setxattr_common(inode, name, NULL, 0, 0,
-				  OBD_MD_FLXATTRRM);
+	return ll_xattr_set_common(handler, dentry, inode, name, value, size,
+				   flags);
 }
 
 static int
@@ -300,30 +303,31 @@ out:
 	return rc;
 }
 
-static
-int ll_getxattr_common(struct inode *inode, const char *name,
-		       void *buffer, size_t size)
+static int ll_xattr_get_common(const struct xattr_handler *handler,
+			       struct dentry *dentry, struct inode *inode,
+			       const char *name, void *buffer, size_t size)
 {
+	char fullname[strlen(handler->prefix) + strlen(name) + 1];
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	int xattr_type, rc;
 	struct ll_inode_info *lli = ll_i2info(inode);
+	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
-	xattr_type = get_xattr_type(name);
-	rc = xattr_type_filter(sbi, xattr_type);
+	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
+
+	rc = xattr_type_filter(sbi, handler->flags);
 	if (rc)
 		return rc;
 
 	/* b15587: ignore security.capability xattr for now */
-	if ((xattr_type == XATTR_SECURITY_T &&
-	     strcmp(name, "security.capability") == 0))
+	if ((handler->flags == XATTR_SECURITY_T && !strcmp(name, "capability")))
 		return -ENODATA;
 
 	/* LU-549:  Disable security.selinux when selinux is disabled */
-	if (xattr_type == XATTR_SECURITY_T && !selinux_is_enabled() &&
-	    strcmp(name, "security.selinux") == 0)
+	if (handler->flags == XATTR_SECURITY_T && !selinux_is_enabled() &&
+	    !strcmp(name, "selinux"))
 		return -EOPNOTSUPP;
 
 #ifdef CONFIG_FS_POSIX_ACL
@@ -331,7 +335,7 @@ int ll_getxattr_common(struct inode *inode, const char *name,
 	 * we just have path resolution to the target inode, so we have great
 	 * chance that cached ACL is uptodate.
 	 */
-	if (xattr_type == XATTR_ACL_ACCESS_T) {
+	if (handler->flags == XATTR_ACL_ACCESS_T) {
 		struct posix_acl *acl;
 
 		spin_lock(&lli->lli_lock);
@@ -345,15 +349,17 @@ int ll_getxattr_common(struct inode *inode, const char *name,
 		posix_acl_release(acl);
 		return rc;
 	}
-	if (xattr_type == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
+	if (handler->flags == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
 		return -ENODATA;
 #endif
-	return ll_xattr_list(inode, name, xattr_type, buffer, size,
+	sprintf(fullname, "%s%s\n", handler->prefix, name);
+	return ll_xattr_list(inode, fullname, handler->flags, buffer, size,
 			     OBD_MD_FLXATTR);
 }
 
-ssize_t ll_getxattr(struct dentry *dentry, struct inode *inode,
-		    const char *name, void *buffer, size_t size)
+static int ll_xattr_get(const struct xattr_handler *handler,
+			struct dentry *dentry, struct inode *inode,
+			const char *name, void *buffer, size_t size)
 {
 	LASSERT(inode);
 	LASSERT(name);
@@ -361,20 +367,15 @@ ssize_t ll_getxattr(struct dentry *dentry, struct inode *inode,
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
 	       PFID(ll_inode2fid(inode)), inode, name);
 
-	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
-
-	if ((strncmp(name, XATTR_TRUSTED_PREFIX,
-		     sizeof(XATTR_TRUSTED_PREFIX) - 1) == 0 &&
-	     strcmp(name + sizeof(XATTR_TRUSTED_PREFIX) - 1, "lov") == 0) ||
-	    (strncmp(name, XATTR_LUSTRE_PREFIX,
-		     sizeof(XATTR_LUSTRE_PREFIX) - 1) == 0 &&
-	     strcmp(name + sizeof(XATTR_LUSTRE_PREFIX) - 1, "lov") == 0)) {
+	if (!strcmp(name, "lov")) {
 		struct lov_stripe_md *lsm;
 		struct lov_user_md *lump;
 		struct lov_mds_md *lmm = NULL;
 		struct ptlrpc_request *request = NULL;
 		int rc = 0, lmmsize = 0;
 
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
+
 		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
 			return -ENODATA;
 
@@ -440,7 +441,7 @@ out:
 		return rc;
 	}
 
-	return ll_getxattr_common(inode, name, buffer, size);
+	return ll_xattr_get_common(handler, dentry, inode, name, buffer, size);
 }
 
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
@@ -520,3 +521,57 @@ out:
 
 	return rc;
 }
+
+static const struct xattr_handler ll_user_xattr_handler = {
+	.prefix = XATTR_USER_PREFIX,
+	.flags = XATTR_USER_T,
+	.get = ll_xattr_get_common,
+	.set = ll_xattr_set_common,
+};
+
+static const struct xattr_handler ll_trusted_xattr_handler = {
+	.prefix = XATTR_TRUSTED_PREFIX,
+	.flags = XATTR_TRUSTED_T,
+	.get = ll_xattr_get,
+	.set = ll_xattr_set,
+};
+
+static const struct xattr_handler ll_security_xattr_handler = {
+	.prefix = XATTR_SECURITY_PREFIX,
+	.flags = XATTR_SECURITY_T,
+	.get = ll_xattr_get_common,
+	.set = ll_xattr_set_common,
+};
+
+static const struct xattr_handler ll_acl_access_xattr_handler = {
+	.prefix = XATTR_NAME_POSIX_ACL_ACCESS,
+	.flags = XATTR_ACL_ACCESS_T,
+	.get = ll_xattr_get_common,
+	.set = ll_xattr_set_common,
+};
+
+static const struct xattr_handler ll_acl_default_xattr_handler = {
+	.prefix = XATTR_NAME_POSIX_ACL_DEFAULT,
+	.flags = XATTR_ACL_DEFAULT_T,
+	.get = ll_xattr_get_common,
+	.set = ll_xattr_set_common,
+};
+
+static const struct xattr_handler ll_lustre_xattr_handler = {
+	.prefix = XATTR_LUSTRE_PREFIX,
+	.flags = XATTR_LUSTRE_T,
+	.get = ll_xattr_get,
+	.set = ll_xattr_set,
+};
+
+const struct xattr_handler *ll_xattr_handlers[] = {
+	&ll_user_xattr_handler,
+	&ll_trusted_xattr_handler,
+	&ll_security_xattr_handler,
+#ifdef CONFIG_FS_POSIX_ACL
+	&ll_acl_access_xattr_handler,
+	&ll_acl_default_xattr_handler,
+#endif
+	&ll_lustre_xattr_handler,
+	NULL,
+};
-- 
1.7.1
