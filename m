From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 Jun 2016 18:47:50 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: llite: break
	ll_getxattr_common into 2 functions
Message-ID: <1466462870-20745-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Split the function ll_getxattr_common into two functions.
The code used for listing xattrs and ll_getxattr_common is
placed into a new function ll_getxattr_list. This allows
ll_listxattr to call directly ll_getxattr_list instead of
going through ll_getxattr_common. This change is needed
for the upcoming VFS move xattr_handler from [s|g]etxattr.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c |  122 ++++++++++++++-------------
 1 files changed, 62 insertions(+), 60 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 98303cf..a034a5f 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -217,69 +217,18 @@ int ll_removexattr(struct dentry *dentry, const char *name)
 				  OBD_MD_FLXATTRRM);
 }
 
-static
-int ll_getxattr_common(struct inode *inode, const char *name,
-		       void *buffer, size_t size, __u64 valid)
+static int
+ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
+	      size_t size, __u64 valid)
 {
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
 	struct mdt_body *body;
-	int xattr_type, rc;
 	void *xdata;
-	struct ll_inode_info *lli = ll_i2info(inode);
-
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
-	       PFID(ll_inode2fid(inode)), inode);
-
-	/* listxattr have slightly different behavior from of ext3:
-	 * without 'user_xattr' ext3 will list all xattr names but
-	 * filtered out "^user..*"; we list them all for simplicity.
-	 */
-	if (!name) {
-		xattr_type = XATTR_OTHER_T;
-		goto do_getxattr;
-	}
-
-	xattr_type = get_xattr_type(name);
-	rc = xattr_type_filter(sbi, xattr_type);
-	if (rc)
-		return rc;
-
-	/* b15587: ignore security.capability xattr for now */
-	if ((xattr_type == XATTR_SECURITY_T &&
-	     strcmp(name, "security.capability") == 0))
-		return -ENODATA;
-
-	/* LU-549:  Disable security.selinux when selinux is disabled */
-	if (xattr_type == XATTR_SECURITY_T && !selinux_is_enabled() &&
-	    strcmp(name, "security.selinux") == 0)
-		return -EOPNOTSUPP;
-
-#ifdef CONFIG_FS_POSIX_ACL
-	/* posix acl is under protection of LOOKUP lock. when calling to this,
-	 * we just have path resolution to the target inode, so we have great
-	 * chance that cached ACL is uptodate.
-	 */
-	if (xattr_type == XATTR_ACL_ACCESS_T) {
-		struct posix_acl *acl;
-
-		spin_lock(&lli->lli_lock);
-		acl = posix_acl_dup(lli->lli_posix_acl);
-		spin_unlock(&lli->lli_lock);
-
-		if (!acl)
-			return -ENODATA;
-
-		rc = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
-		posix_acl_release(acl);
-		return rc;
-	}
-	if (xattr_type == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
-		return -ENODATA;
-#endif
+	int rc;
 
-do_getxattr:
-	if (sbi->ll_xattr_cache_enabled && xattr_type != XATTR_ACL_ACCESS_T) {
+	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T) {
 		rc = ll_xattr_cache_get(inode, name, buffer, size, valid);
 		if (rc == -EAGAIN)
 			goto getxattr_nocache;
@@ -340,7 +289,7 @@ getxattr_nocache:
 	}
 
 out_xattr:
-	if (rc == -EOPNOTSUPP && xattr_type == XATTR_USER_T) {
+	if (rc == -EOPNOTSUPP && type == XATTR_USER_T) {
 		LCONSOLE_INFO(
 			"%s: disabling user_xattr feature because it is not supported on the server: rc = %d\n",
 			ll_get_fsname(inode->i_sb, NULL, 0), rc);
@@ -351,6 +300,58 @@ out:
 	return rc;
 }
 
+static
+int ll_getxattr_common(struct inode *inode, const char *name,
+		       void *buffer, size_t size)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	int xattr_type, rc;
+	struct ll_inode_info *lli = ll_i2info(inode);
+
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	       PFID(ll_inode2fid(inode)), inode);
+
+	xattr_type = get_xattr_type(name);
+	rc = xattr_type_filter(sbi, xattr_type);
+	if (rc)
+		return rc;
+
+	/* b15587: ignore security.capability xattr for now */
+	if ((xattr_type == XATTR_SECURITY_T &&
+	     strcmp(name, "security.capability") == 0))
+		return -ENODATA;
+
+	/* LU-549:  Disable security.selinux when selinux is disabled */
+	if (xattr_type == XATTR_SECURITY_T && !selinux_is_enabled() &&
+	    strcmp(name, "security.selinux") == 0)
+		return -EOPNOTSUPP;
+
+#ifdef CONFIG_FS_POSIX_ACL
+	/* posix acl is under protection of LOOKUP lock. when calling to this,
+	 * we just have path resolution to the target inode, so we have great
+	 * chance that cached ACL is uptodate.
+	 */
+	if (xattr_type == XATTR_ACL_ACCESS_T) {
+		struct posix_acl *acl;
+
+		spin_lock(&lli->lli_lock);
+		acl = posix_acl_dup(lli->lli_posix_acl);
+		spin_unlock(&lli->lli_lock);
+
+		if (!acl)
+			return -ENODATA;
+
+		rc = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
+		posix_acl_release(acl);
+		return rc;
+	}
+	if (xattr_type == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
+		return -ENODATA;
+#endif
+	return ll_xattr_list(inode, name, xattr_type, buffer, size,
+			     OBD_MD_FLXATTR);
+}
+
 ssize_t ll_getxattr(struct dentry *dentry, struct inode *inode,
 		    const char *name, void *buffer, size_t size)
 {
@@ -439,7 +440,7 @@ out:
 		return rc;
 	}
 
-	return ll_getxattr_common(inode, name, buffer, size, OBD_MD_FLXATTR);
+	return ll_getxattr_common(inode, name, buffer, size);
 }
 
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
@@ -457,7 +458,8 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LISTXATTR, 1);
 
-	rc = ll_getxattr_common(inode, NULL, buffer, size, OBD_MD_FLXATTRLS);
+	rc = ll_xattr_list(inode, NULL, XATTR_OTHER_T, buffer, size,
+			   OBD_MD_FLXATTRLS);
 	if (rc < 0)
 		goto out;
 
-- 
1.7.1
