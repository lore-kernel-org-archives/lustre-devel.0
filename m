From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:07 -0400
Subject: [lustre-devel] [PATCH 18/22] staging: lustre: llite: style changes
 in xattr.c
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Small style changes to match more the kernel code standard
and it make it more readable.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/27240
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 835d00f..d08bf1e 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -81,11 +81,10 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	return 0;
 }
 
-static int
-ll_xattr_set_common(const struct xattr_handler *handler,
-		    struct dentry *dentry, struct inode *inode,
-		    const char *name, const void *value, size_t size,
-		    int flags)
+static int ll_xattr_set_common(const struct xattr_handler *handler,
+			       struct dentry *dentry, struct inode *inode,
+			       const char *name, const void *value, size_t size,
+			       int flags)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
@@ -139,9 +138,9 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
 	if (!fullname)
 		return -ENOMEM;
-	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-			 valid, fullname, pv, size, 0, flags,
-			 ll_i2suppgid(inode), &req);
+
+	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode), valid, fullname,
+			 pv, size, 0, flags, ll_i2suppgid(inode), &req);
 	kfree(fullname);
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
@@ -307,9 +306,8 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 				   flags);
 }
 
-int
-ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
-	      size_t size, u64 valid)
+int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
+		  size_t size, u64 valid)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -439,6 +437,7 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 	fullname = kasprintf(GFP_KERNEL, "%s%s", handler->prefix, name);
 	if (!fullname)
 		return -ENOMEM;
+
 	rc = ll_xattr_list(inode, fullname, handler->flags, buffer, size,
 			   OBD_MD_FLXATTR);
 	kfree(fullname);
@@ -562,6 +561,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 			   OBD_MD_FLXATTRLS);
 	if (rc < 0)
 		return rc;
+
 	/*
 	 * If we're being called to get the size of the xattr list
 	 * (size == 0) then just assume that a lustre.lov xattr
-- 
1.8.3.1
