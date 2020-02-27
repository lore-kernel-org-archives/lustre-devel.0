From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:20 -0500
Subject: [lustre-devel] [PATCH 152/622] lustre: quota: fix setattr project
 check
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-153-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Similar patch motivated by upstream patch:
ext4: fix setattr project check in fssetxattr ioctl

Currently, project quota could be changed by fssetxattr
ioctl, and existed permission check inode_owner_or_capable()
is obviously not enough, just think that common users could
change project id of file, that could make users to
break project quota easily.

This patch try to follow same regular of xfs project
quota:

"Project Quota ID state is only allowed to change from
within the init namespace. Enforce that restriction only
if we are trying to change the quota ID state.
Everything else is allowed in user namespaces."

WC-bug-id: https://jira.whamcloud.com/browse/LU-11101
Lustre-commit: 2d3bbce0c9f3 ("LU-11101 quota: fix setattr project check")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/32730
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           | 42 ++++++++++++++++++++++++++++++----------
 fs/lustre/llite/llite_internal.h |  1 +
 fs/lustre/llite/llite_lib.c      |  9 +++++++++
 3 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 2fd906f..ed0470d 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2780,6 +2780,30 @@ int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 	return 0;
 }
 
+int ll_ioctl_check_project(struct inode *inode, struct fsxattr *fa)
+{
+	/*
+	 * Project Quota ID state is only allowed to change from within the init
+	 * namespace. Enforce that restriction only if we are trying to change
+	 * the quota ID state. Everything else is allowed in user namespaces.
+	 */
+	if (current_user_ns() == &init_user_ns)
+		return 0;
+
+	if (ll_i2info(inode)->lli_projid != fa->fsx_projid)
+		return -EINVAL;
+
+	if (test_bit(LLIF_PROJECT_INHERIT, &ll_i2info(inode)->lli_flags)) {
+		if (!(fa->fsx_xflags & FS_XFLAG_PROJINHERIT))
+			return -EINVAL;
+	} else {
+		if (fa->fsx_xflags & FS_XFLAG_PROJINHERIT)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg)
 {
@@ -2791,22 +2815,20 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	int rc = 0;
 	int flags;
 
-	/* only root could change project ID */
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
+	if (copy_from_user(&fsxattr,
+			   (const struct fsxattr __user *)arg,
+			   sizeof(fsxattr)))
+		return -EFAULT;
+
+	rc = ll_ioctl_check_project(inode, &fsxattr);
+	if (rc)
+		return rc;
 
 	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (copy_from_user(&fsxattr,
-			   (const struct fsxattr __user *)arg,
-			   sizeof(fsxattr))) {
-		rc = -EFAULT;
-		goto out_fsxattr;
-	}
-
 	flags = ll_xflags_to_inode_flags(fsxattr.fsx_xflags);
 	op_data->op_attr_flags = ll_inode_to_ext_flags(flags);
 	if (fsxattr.fsx_xflags & FS_XFLAG_PROJINHERIT)
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index edb5f2a..d6fc6a29 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -829,6 +829,7 @@ int ll_migrate(struct inode *parent, struct file *file,
 int ll_get_fid_by_name(struct inode *parent, const char *name,
 		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
+int ll_ioctl_check_project(struct inode *inode, struct fsxattr *fa);
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg);
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index be67652..859fdf4 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2094,10 +2094,19 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		struct md_op_data *op_data;
 		struct cl_object *obj;
 		struct iattr *attr;
+		struct fsxattr fa = { 0 };
 
 		if (get_user(flags, (int __user *)arg))
 			return -EFAULT;
 
+		fa.fsx_projid = ll_i2info(inode)->lli_projid;
+		if (flags & LUSTRE_PROJINHERIT_FL)
+			fa.fsx_xflags = FS_XFLAG_PROJINHERIT;
+
+		rc = ll_ioctl_check_project(inode, &fa);
+		if (rc)
+			return rc;
+
 		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 					     LUSTRE_OPC_ANY, NULL);
 		if (IS_ERR(op_data))
-- 
1.8.3.1
