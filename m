From: Guru Das Srinagesh <gurooodas@gmail.com>
Date: Sun,  7 May 2017 02:33:32 -0700
Subject: [lustre-devel] [PATCH v3] staging: lustre: llite: Fix variable
	length array warning
Message-ID: <1494149612-2631-1-git-send-email-gurooodas@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, joe@perches.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Fix sparse warning "warning: Variable length array is used." by using
kmalloc_array to allocate the required amount of memory instead and
kfree to deallocate memory after use.

Signed-off-by: Guru Das Srinagesh <gurooodas@gmail.com>
---
 v3:
   - Fixed checkpatch warning: Comparison to NULL could be written "!fullname"

 v2:
   - Added missing check for NULL return value of kmalloc_array()

 drivers/staging/lustre/lustre/llite/xattr.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 6187bff..35f38eb 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -86,13 +86,17 @@ ll_xattr_set_common(const struct xattr_handler *handler,
 		    const char *name, const void *value, size_t size,
 		    int flags)
 {
-	char fullname[strlen(handler->prefix) + strlen(name) + 1];
+	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
+	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_KERNEL);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
 	const char *pv = value;
 	__u64 valid;
 	int rc;
 
+	if (!fullname)
+		return -ENOMEM;
+
 	if (flags == XATTR_REPLACE) {
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_REMOVEXATTR, 1);
 		valid = OBD_MD_FLXATTRRM;
@@ -153,6 +157,9 @@ ll_xattr_set_common(const struct xattr_handler *handler,
 	}
 
 	ptlrpc_req_finished(req);
+
+	kfree(fullname);
+
 	return 0;
 }
 
@@ -363,13 +370,17 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 			       struct dentry *dentry, struct inode *inode,
 			       const char *name, void *buffer, size_t size)
 {
-	char fullname[strlen(handler->prefix) + strlen(name) + 1];
+	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
+	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_KERNEL);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 #ifdef CONFIG_FS_POSIX_ACL
 	struct ll_inode_info *lli = ll_i2info(inode);
 #endif
 	int rc;
 
+	if (!fullname)
+		return -ENOMEM;
+
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
@@ -411,8 +422,12 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 		return -ENODATA;
 #endif
 	sprintf(fullname, "%s%s\n", handler->prefix, name);
-	return ll_xattr_list(inode, fullname, handler->flags, buffer, size,
-			     OBD_MD_FLXATTR);
+
+	rc = ll_xattr_list(inode, fullname, handler->flags, buffer, size,
+			   OBD_MD_FLXATTR);
+	kfree(fullname);
+
+	return rc;
 }
 
 static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
-- 
2.7.4
