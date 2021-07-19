Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61756C07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 28E026112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28E026112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ECDF434FA0E;
	Mon, 19 Jul 2021 05:32:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EFD8734F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A26ED6C0;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9CD6EBD; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:04 -0400
Message-Id: <1626697933-6971-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/18] lustre: quota: add get/set project
 support for non-dir/file
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

Add ablity to get/set non-dir/file's project ID and state.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11872
Lustre-commit: b31792b0e72425c8 ("LU-11872 quota: add get/set project support for non-dir/file")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/44006
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   |   2 +
 fs/lustre/llite/file.c                  | 111 ++++++++++++++++++++++++++------
 fs/lustre/llite/llite_internal.h        |   5 +-
 fs/lustre/llite/llite_lib.c             |   3 +-
 include/uapi/linux/lustre/lustre_user.h |  16 +++++
 5 files changed, 115 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index fa8e697..9666534 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -2098,6 +2098,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return ll_ioctl_fsgetxattr(inode, cmd, arg);
 	case FS_IOC_FSSETXATTR:
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
+	case LL_IOC_PROJECT:
+		return ll_ioctl_project(file, cmd, arg);
 	case LL_IOC_PCC_DETACH_BY_FID: {
 		struct lu_pcc_detach_fid *detach;
 		struct lu_fid *fid;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 54e343f..1ef5fd8 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3314,7 +3314,8 @@ int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 	return 0;
 }
 
-int ll_ioctl_check_project(struct inode *inode, struct fsxattr *fa)
+int ll_ioctl_check_project(struct inode *inode, u32 xflags,
+			   u32 projid)
 {
 	/*
 	 * Project Quota ID state is only allowed to change from within the init
@@ -3324,36 +3325,29 @@ int ll_ioctl_check_project(struct inode *inode, struct fsxattr *fa)
 	if (current_user_ns() == &init_user_ns)
 		return 0;
 
-	if (ll_i2info(inode)->lli_projid != fa->fsx_projid)
+	if (ll_i2info(inode)->lli_projid != projid)
 		return -EINVAL;
 
 	if (test_bit(LLIF_PROJECT_INHERIT, &ll_i2info(inode)->lli_flags)) {
-		if (!(fa->fsx_xflags & FS_XFLAG_PROJINHERIT))
+		if (!(xflags & FS_XFLAG_PROJINHERIT))
 			return -EINVAL;
 	} else {
-		if (fa->fsx_xflags & FS_XFLAG_PROJINHERIT)
+		if (xflags & FS_XFLAG_PROJINHERIT)
 			return -EINVAL;
 	}
 
 	return 0;
 }
 
-int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
-			unsigned long arg)
+static int ll_set_project(struct inode *inode, u32 xflags, u32 projid)
 {
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
-	struct fsxattr fsxattr;
 	struct cl_object *obj;
 	unsigned int inode_flags;
 	int rc = 0;
 
-	if (copy_from_user(&fsxattr,
-			   (const struct fsxattr __user *)arg,
-			   sizeof(fsxattr)))
-		return -EFAULT;
-
-	rc = ll_ioctl_check_project(inode, &fsxattr);
+	rc = ll_ioctl_check_project(inode, xflags, projid);
 	if (rc)
 		return rc;
 
@@ -3362,11 +3356,11 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	inode_flags = ll_xflags_to_inode_flags(fsxattr.fsx_xflags);
+	inode_flags = ll_xflags_to_inode_flags(xflags);
 	op_data->op_attr_flags = ll_inode_to_ext_flags(inode_flags);
-	if (fsxattr.fsx_xflags & FS_XFLAG_PROJINHERIT)
+	if (xflags & FS_XFLAG_PROJINHERIT)
 		op_data->op_attr_flags |= LUSTRE_PROJINHERIT_FL;
-	op_data->op_projid = fsxattr.fsx_projid;
+	op_data->op_projid = projid;
 	op_data->op_xvalid |= OP_XVALID_PROJID;
 	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data, NULL,
 			0, &req);
@@ -3377,16 +3371,14 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	ll_update_inode_flags(inode, op_data->op_attr_flags);
 
 	/* Avoid OST RPC if this is only ioctl setting project inherit flag */
-	if (fsxattr.fsx_xflags == 0 ||
-	    fsxattr.fsx_xflags == FS_XFLAG_PROJINHERIT)
+	if (xflags == 0 || xflags == FS_XFLAG_PROJINHERIT)
 		goto out_fsxattr;
 
 	obj = ll_i2info(inode)->lli_clob;
 	if (obj) {
 		struct iattr attr = { 0 };
 
-		rc = cl_setattr_ost(obj, &attr, OP_XVALID_FLAGS,
-				    fsxattr.fsx_xflags);
+		rc = cl_setattr_ost(obj, &attr, OP_XVALID_FLAGS, xflags);
 	}
 
 out_fsxattr:
@@ -3395,6 +3387,83 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	return rc;
 }
 
+int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
+			unsigned long arg)
+{
+	struct fsxattr fsxattr;
+
+	if (copy_from_user(&fsxattr,
+			   (const struct fsxattr __user *)arg,
+			   sizeof(fsxattr)))
+		return -EFAULT;
+
+	return ll_set_project(inode, fsxattr.fsx_xflags,
+			      fsxattr.fsx_projid);
+}
+
+int ll_ioctl_project(struct file *file, unsigned int cmd,
+		     unsigned long arg)
+{
+	struct lu_project lu_project;
+	struct dentry *dentry = file_dentry(file);
+	struct inode *inode = file_inode(file);
+	struct dentry *child_dentry = NULL;
+	int rc = 0, name_len;
+
+	if (copy_from_user(&lu_project,
+			   (const struct lu_project __user *)arg,
+			   sizeof(lu_project)))
+		return -EFAULT;
+
+	/* apply child dentry if name is valid */
+	name_len = strnlen(lu_project.project_name, NAME_MAX);
+	if (name_len > 0 && name_len <= NAME_MAX) {
+		inode_lock(inode);
+		child_dentry = lookup_one_len(lu_project.project_name,
+					      dentry, name_len);
+		inode_unlock(inode);
+		if (IS_ERR(child_dentry)) {
+			rc = PTR_ERR(child_dentry);
+			goto out;
+		}
+		inode = child_dentry->d_inode;
+		if (!inode) {
+			rc = -ENOENT;
+			goto out;
+		}
+	} else if (name_len > NAME_MAX) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	switch (lu_project.project_type) {
+	case LU_PROJECT_SET:
+		rc = ll_set_project(inode, lu_project.project_xflags,
+				    lu_project.project_id);
+		break;
+	case LU_PROJECT_GET:
+		lu_project.project_xflags =
+				ll_inode_flags_to_xflags(inode->i_flags);
+		if (test_bit(LLIF_PROJECT_INHERIT,
+			     &ll_i2info(inode)->lli_flags))
+			lu_project.project_xflags |= FS_XFLAG_PROJINHERIT;
+		lu_project.project_id = ll_i2info(inode)->lli_projid;
+		if (copy_to_user((struct lu_project __user *)arg,
+				 &lu_project, sizeof(lu_project))) {
+			rc = -EFAULT;
+			goto out;
+		}
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+out:
+	if (!IS_ERR_OR_NULL(child_dentry))
+		dput(child_dentry);
+	return rc;
+}
+
 static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 				 unsigned long arg)
 {
@@ -4063,6 +4132,8 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		return ll_ioctl_fsgetxattr(inode, cmd, arg);
 	case FS_IOC_FSSETXATTR:
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
+	case LL_IOC_PROJECT:
+		return ll_ioctl_project(file, cmd, arg);
 	case BLKSSZGET:
 		return put_user(PAGE_SIZE, (int __user *)arg);
 	case LL_IOC_HEAT_GET: {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 1d5255e..6cae741 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1157,11 +1157,14 @@ int ll_migrate(struct inode *parent, struct file *file,
 int ll_get_fid_by_name(struct inode *parent, const char *name,
 		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
-int ll_ioctl_check_project(struct inode *inode, struct fsxattr *fa);
+int ll_ioctl_check_project(struct inode *inode, u32 xflags, u32 projid);
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg);
 int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg);
+int ll_ioctl_project(struct file *file, unsigned int cmd,
+		     unsigned long arg);
+
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 			     u64 flags, struct lov_user_md *lum,
 			     int lum_size);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 153d34e..10a9a95 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2615,7 +2615,8 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		if (flags & LUSTRE_PROJINHERIT_FL)
 			fa.fsx_xflags = FS_XFLAG_PROJINHERIT;
 
-		rc = ll_ioctl_check_project(inode, &fa);
+		rc = ll_ioctl_check_project(inode, fa.fsx_xflags,
+					    fa.fsx_projid);
 		if (rc)
 			return rc;
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 0cd3500..da15ca8 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -375,6 +375,7 @@ struct ll_ioc_lease_id {
 #define LL_IOC_PCC_DETACH		_IOW('f', 252, struct lu_pcc_detach)
 #define LL_IOC_PCC_DETACH_BY_FID	_IOW('f', 252, struct lu_pcc_detach_fid)
 #define LL_IOC_PCC_STATE		_IOR('f', 252, struct lu_pcc_state)
+#define LL_IOC_PROJECT			_IOW('f', 253, struct lu_project)
 
 #define LL_STATFS_LMV		1
 #define LL_STATFS_LOV		2
@@ -2311,6 +2312,21 @@ struct lu_pcc_state {
 	char	pccs_path[PATH_MAX];
 };
 
+enum lu_project_type {
+	LU_PROJECT_NONE = 0,
+	LU_PROJECT_SET,
+	LU_PROJECT_GET,
+	LU_PROJECT_MAX
+};
+
+struct lu_project {
+	__u32	project_type; /* enum lu_project_type */
+	__u32	project_id;
+	__u32	project_xflags;
+	__u32	project_reserved;
+	char	project_name[NAME_MAX + 1];
+};
+
 struct fid_array {
 	__u32 fa_nr;
 	/* make header's size equal lu_fid */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
