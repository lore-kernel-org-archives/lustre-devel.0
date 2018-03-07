From: Kees Cook <keescook@chromium.org>
Date: Wed, 7 Mar 2018 12:54:44 -0800
Subject: [lustre-devel] [PATCH v2] staging: lustre: Remove VLA usage
Message-ID: <20180307205444.GA11349@beast>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Rasmus Villemoes <linux@rasmusvillemoes.dk>, "Tobin C. Harding" <me@tobin.cc>, Tycho Andersen <tycho@tycho.ws>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Gargi Sharma <gs051095@gmail.com>, Lustre Development List <lustre-devel@lists.lustre.org>, devel@driverdev.osuosl.org, Kernel Hardening <kernel-hardening@lists.openwall.com>

The kernel would like to have all stack VLA usage removed[1]. This switches
to a simple kasprintf() instead, and in the process fixes an off-by-one
between the allocation and the sprintf (allocation did not include NULL
byte in calculation).

[1] https://lkml.org/lkml/2018/3/7/621

Signed-off-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 532384c91447..ff6fe81a4ddb 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -87,10 +87,10 @@ ll_xattr_set_common(const struct xattr_handler *handler,
 		    const char *name, const void *value, size_t size,
 		    int flags)
 {
-	char fullname[strlen(handler->prefix) + strlen(name) + 1];
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
 	const char *pv = value;
+	char *fullname;
 	__u64 valid;
 	int rc;
 
@@ -141,10 +141,13 @@ ll_xattr_set_common(const struct xattr_handler *handler,
 			return -EPERM;
 	}
 
-	sprintf(fullname, "%s%s\n", handler->prefix, name);
+	fullname = kasprintf(GFP_KERNEL, "%s%s\n", handler->prefix, name);
+	if (!fullname)
+		return -ENOMEM;
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
 			 valid, fullname, pv, size, 0, flags,
 			 ll_i2suppgid(inode), &req);
+	kfree(fullname);
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
@@ -364,11 +367,11 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 			       struct dentry *dentry, struct inode *inode,
 			       const char *name, void *buffer, size_t size)
 {
-	char fullname[strlen(handler->prefix) + strlen(name) + 1];
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 #ifdef CONFIG_FS_POSIX_ACL
 	struct ll_inode_info *lli = ll_i2info(inode);
 #endif
+	char *fullname;
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
@@ -411,9 +414,13 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (handler->flags == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
 		return -ENODATA;
 #endif
-	sprintf(fullname, "%s%s\n", handler->prefix, name);
-	return ll_xattr_list(inode, fullname, handler->flags, buffer, size,
-			     OBD_MD_FLXATTR);
+	fullname = kasprintf(GFP_KERNEL, "%s%s\n", handler->prefix, name);
+	if (!fullname)
+		return -ENOMEM;
+	rc = ll_xattr_list(inode, fullname, handler->flags, buffer, size,
+			   OBD_MD_FLXATTR);
+	kfree(fullname);
+	return rc;
 }
 
 static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
