From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:21:04 -0400
Subject: [lustre-devel] [PATCH 14/14] staging: lustre: llite: add support
	set_acl method in inode operations
In-Reply-To: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502727664-29438-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Linux kernel v3.14 adds set_acl method to inode operations.
This patch adds support to Lustre for proper acl management.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/25965
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         | 58 ++++++++++++++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |  4 ++
 drivers/staging/lustre/lustre/llite/namei.c        | 10 +++-
 3 files changed, 70 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 215479a..06a474e 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3027,6 +3027,7 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 	return rc;
 }
 
+#ifdef CONFIG_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -3040,6 +3041,60 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 	return acl;
 }
 
+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
+{
+	const char *name = NULL;
+	char *value = NULL;
+	size_t size = 0;
+	int rc = 0;
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		if (acl) {
+			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
+			if (rc)
+				goto out;
+		}
+		name = XATTR_NAME_POSIX_ACL_ACCESS;
+		break;
+	case ACL_TYPE_DEFAULT:
+		if (!S_ISDIR(inode->i_mode)) {
+			rc = acl ? -EACCES : 0;
+			goto out;
+		}
+		name = XATTR_NAME_POSIX_ACL_DEFAULT;
+		break;
+	default:
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (acl) {
+		size = posix_acl_xattr_size(acl->a_count);
+		value = kmalloc(size, GFP_NOFS);
+		if (!value) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		rc = posix_acl_to_xattr(&init_user_ns, acl, value, size);
+		if (rc < 0)
+			goto out_free;
+	}
+
+	/* dentry is only used for *.lov attributes so it's safe to be NULL */
+	rc = __vfs_setxattr(NULL, inode, name, value, size, XATTR_CREATE);
+out_free:
+	kfree(value);
+out:
+	if (!rc)
+		set_cached_acl(inode, type, acl);
+	else
+		forget_cached_acl(inode, type);
+	return rc;
+}
+#endif /* CONFIG_FS_POSIX_ACL */
+
 int ll_inode_permission(struct inode *inode, int mask)
 {
 	struct ll_sb_info *sbi;
@@ -3161,7 +3216,10 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.permission	= ll_inode_permission,
 	.listxattr	= ll_listxattr,
 	.fiemap		= ll_fiemap,
+#ifdef CONFIG_FS_POSIX_ACL
 	.get_acl	= ll_get_acl,
+	.set_acl	= ll_set_acl,
+#endif
 };
 
 /* dynamic ioctl number support routines */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd3311a..18e350e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -751,7 +751,11 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
+#ifdef CONFIG_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type);
+#endif /* CONFIG_FS_POSIX_ACL */
+
 int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	       const char *name, int namelen);
 int ll_get_fid_by_name(struct inode *parent, const char *name,
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index a208a8b..3f8f2ce 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -1186,7 +1186,10 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	.getattr	    = ll_getattr,
 	.permission	 = ll_inode_permission,
 	.listxattr	  = ll_listxattr,
-	.get_acl	    = ll_get_acl,
+#ifdef CONFIG_FS_POSIX_ACL
+	.get_acl	= ll_get_acl,
+	.set_acl	= ll_set_acl,
+#endif
 };
 
 const struct inode_operations ll_special_inode_operations = {
@@ -1194,5 +1197,8 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	.getattr	= ll_getattr,
 	.permission     = ll_inode_permission,
 	.listxattr      = ll_listxattr,
-	.get_acl	    = ll_get_acl,
+#ifdef CONFIG_FS_POSIX_ACL
+	.get_acl	= ll_get_acl,
+	.set_acl	= ll_set_acl,
+#endif
 };
-- 
1.8.3.1
