From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:15:08 -0400
Subject: [lustre-devel] [PATCH 19/22] staging: lustre: llite: add support
 set_acl method in inode operations
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Linux kernel v3.14 adds set_acl method to inode operations.
This patch adds support to Lustre for proper acl management.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
Reviewed-on: https://review.whamcloud.com/25965
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10541
Reviewed-on: https://review.whamcloud.com/
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         | 67 ++++++++++++++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |  4 ++
 drivers/staging/lustre/lustre/llite/namei.c        | 10 +++-
 3 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 0026fde..35f5bda 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3030,6 +3030,7 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 	return rc;
 }
 
+#ifdef CONFIG_FS_POSIX_ACL
 struct posix_acl *ll_get_acl(struct inode *inode, int type)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -3043,6 +3044,69 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 	return acl;
 }
 
+int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ptlrpc_request *req = NULL;
+	const char *name = NULL;
+	size_t value_size = 0;
+	char *value = NULL;
+	int rc;
+
+	switch (type) {
+	case ACL_TYPE_ACCESS:
+		name = XATTR_NAME_POSIX_ACL_ACCESS;
+		if (acl) {
+			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
+			if (rc)
+				goto out;
+		}
+
+		break;
+
+	case ACL_TYPE_DEFAULT:
+		name = XATTR_NAME_POSIX_ACL_DEFAULT;
+		if (!S_ISDIR(inode->i_mode)) {
+			rc = acl ? -EACCES : 0;
+			goto out;
+		}
+
+		break;
+
+	default:
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (acl) {
+		value_size = posix_acl_xattr_size(acl->a_count);
+		value = kmalloc(value_size, GFP_NOFS);
+		if (!value) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		rc = posix_acl_to_xattr(&init_user_ns, acl, value, value_size);
+		if (rc < 0)
+			goto out_value;
+	}
+
+	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
+			 value ? OBD_MD_FLXATTR : OBD_MD_FLXATTRRM,
+			 name, value, value_size, 0, 0, 0, &req);
+
+	ptlrpc_req_finished(req);
+out_value:
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
@@ -3164,7 +3228,10 @@ int ll_inode_permission(struct inode *inode, int mask)
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
index 6504850..2280327 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -754,7 +754,11 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
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
index 6c9ec46..d7c4c58 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -1190,7 +1190,10 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
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
@@ -1198,5 +1201,8 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
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
