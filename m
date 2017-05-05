From: Guru Das Srinagesh <gurooodas@gmail.com>
Date: Thu,  4 May 2017 23:41:26 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: llite: Fix variable length
	array warning
Message-ID: <1493966486-6143-1-git-send-email-gurooodas@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org
Cc: john.hammond@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Fix sparse warning "warning: Variable length array is used." by using
kmalloc_array to allocate the required amount of memory instead and
kfree to deallocate memory after use.

Signed-off-by: Guru Das Srinagesh <gurooodas@gmail.com>
---
 drivers/staging/lustre/lustre/llite/xattr.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 6187bff..832ec6e 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -86,7 +86,8 @@ ll_xattr_set_common(const struct xattr_handler *handler,
 		    const char *name, const void *value, size_t size,
 		    int flags)
 {
-	char fullname[strlen(handler->prefix) + strlen(name) + 1];
+	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
+	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_KERNEL);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
 	const char *pv = value;
@@ -153,6 +154,9 @@ ll_xattr_set_common(const struct xattr_handler *handler,
 	}
 
 	ptlrpc_req_finished(req);
+
+	kfree(fullname);
+
 	return 0;
 }
 
@@ -363,7 +367,8 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 			       struct dentry *dentry, struct inode *inode,
 			       const char *name, void *buffer, size_t size)
 {
-	char fullname[strlen(handler->prefix) + strlen(name) + 1];
+	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
+	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_KERNEL);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 #ifdef CONFIG_FS_POSIX_ACL
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -411,8 +416,12 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
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
