From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:21:03 -0400
Subject: [lustre-devel] [PATCH 13/14] staging: lustre: llite: style changes
	in xattr.c
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

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
 drivers/staging/lustre/lustre/llite/xattr.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index adaff56..0f5271a 100644
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
@@ -140,9 +139,8 @@ static int xattr_type_filter(struct ll_sb_info *sbi,
 	if (!fullname)
 		return -ENOMEM;
 
-	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-			 valid, fullname, pv, size, 0, flags,
-			 ll_i2suppgid(inode), &req);
+	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode), valid, fullname,
+			 pv, size, 0, flags, ll_i2suppgid(inode), &req);
 	kfree(fullname);
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
@@ -308,9 +306,8 @@ static int ll_xattr_set(const struct xattr_handler *handler,
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
@@ -565,6 +562,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 			   OBD_MD_FLXATTRLS);
 	if (rc < 0)
 		return rc;
+
 	/*
 	 * If we're being called to get the size of the xattr list
 	 * (size == 0) then just assume that a lustre.lov xattr
-- 
1.8.3.1
