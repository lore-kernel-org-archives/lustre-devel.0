From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:20:57 -0400
Subject: [lustre-devel] [PATCH 07/14] staging: lustre: llite: fix sparse
	variable length array warning
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Currently sparse reports "warning: Variable length array is used."
The solution is use kasprintf to allocate full xattr name.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index ca803ed..86b5df9 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -87,10 +87,10 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
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
 
@@ -136,10 +136,14 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 			return -EPERM;
 	}
 
-	sprintf(fullname, "%s%s\n", handler->prefix, name);
+	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
+	if (!fullname)
+		return -ENOMEM;
+
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
 			 valid, fullname, pv, size, 0, flags,
 			 ll_i2suppgid(inode), &req);
+	kfree(fullname);
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
@@ -389,11 +393,11 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
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
@@ -432,9 +436,15 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	if (handler->flags == XATTR_ACL_DEFAULT_T && !S_ISDIR(inode->i_mode))
 		return -ENODATA;
 #endif
-	sprintf(fullname, "%s%s\n", handler->prefix, name);
-	return ll_xattr_list(inode, fullname, handler->flags, buffer, size,
-			     OBD_MD_FLXATTR);
+
+	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
+	if (!fullname)
+		return -ENOMEM;
+
+	rc = ll_xattr_list(inode, fullname, handler->flags, buffer, size,
+			   OBD_MD_FLXATTR);
+	kfree(fullname);
+	return rc;
 }
 
 static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
-- 
1.8.3.1
