From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:44 -0400
Subject: [lustre-devel] [PATCH 5/7] lustre: quota: add project inherit
 attributes
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Add @LUSTRE_PROJINHERIT_FL inode flag which means
creating new objects parents projid, it is disabled
in default, unless setting explicitly.

It is kept same interface as Ext4/XFS, you could use
following ioctl directly:

chattr +P <directory>

Signed-off-by: Wang Shilong <wshilong@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4017
Reviewed-on: https://review.whamcloud.com/26463
WC-bug-id: https://jira.whamcloud.com/browse/LU-11154
Reviewed-on: https://review.whamcloud.com/32828
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h       | 17 +++++++++++++++++
 drivers/staging/lustre/lustre/llite/file.c              | 12 ++++++++++++
 drivers/staging/lustre/lustre/llite/llite_internal.h    |  3 +++
 drivers/staging/lustre/lustre/llite/llite_lib.c         | 15 +++++++++++++--
 4 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index a7b3168..26646f9 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1454,6 +1454,7 @@ enum {
 #define LUSTRE_TOPDIR_FL	0x00020000 /* Top of directory hierarchies*/
 #define LUSTRE_DIRECTIO_FL	0x00100000 /* Use direct i/o */
 #define LUSTRE_INLINE_DATA_FL	0x10000000 /* Inode has inline data. */
+#define LUSTRE_PROJINHERIT_FL	0x20000000 /* Create with parents projid */
 
 /* Convert wire LUSTRE_*_FL to corresponding client local VFS S_* values
  * for the client inode i_flags.  The LUSTRE_*_FL are the Lustre wire
@@ -1480,6 +1481,22 @@ static inline int ll_inode_to_ext_flags(int iflags)
 		((iflags & S_IMMUTABLE) ? LUSTRE_IMMUTABLE_FL : 0));
 }
 
+static inline int ll_xflags_to_inode_flags(int xflags)
+{
+	return ((xflags & FS_XFLAG_SYNC) ? S_SYNC : 0) |
+	       ((xflags & FS_XFLAG_NOATIME) ? S_NOATIME : 0) |
+	       ((xflags & FS_XFLAG_APPEND) ? S_APPEND : 0) |
+	       ((xflags & FS_XFLAG_IMMUTABLE) ? S_IMMUTABLE : 0);
+}
+
+static inline int ll_inode_flags_to_xflags(int flags)
+{
+	return ((flags & S_SYNC) ? FS_XFLAG_SYNC : 0) |
+	       ((flags & S_NOATIME) ? FS_XFLAG_NOATIME : 0) |
+	       ((flags & S_APPEND) ? FS_XFLAG_APPEND : 0) |
+	       ((flags & S_IMMUTABLE) ? FS_XFLAG_IMMUTABLE : 0);
+}
+
 /* 64 possible states */
 enum md_transient_state {
 	MS_RESTORE	= (1 << 0),	/* restore is running */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 30a731f..72101bd 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -99,6 +99,8 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
 	op_data->op_xvalid |= OP_XVALID_CTIME_SET;
 	op_data->op_attr_blocks = inode->i_blocks;
 	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
+	if (test_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags))
+		op_data->op_attr_flags |= LUSTRE_PROJINHERIT_FL;
 	op_data->op_handle = och->och_fh;
 
 	/*
@@ -2151,6 +2153,7 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 			unsigned long arg)
 {
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct fsxattr fsxattr;
 
 	if (copy_from_user(&fsxattr,
@@ -2158,6 +2161,9 @@ int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
 			   sizeof(fsxattr)))
 		return -EFAULT;
 
+	fsxattr.fsx_xflags = ll_inode_flags_to_xflags(inode->i_flags);
+	if (test_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags))
+		fsxattr.fsx_xflags |= FS_XFLAG_PROJINHERIT;
 	fsxattr.fsx_projid = ll_i2info(inode)->lli_projid;
 	if (copy_to_user((struct fsxattr __user *)arg,
 			  &fsxattr, sizeof(fsxattr)))
@@ -2173,6 +2179,7 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	struct md_op_data *op_data;
 	struct fsxattr fsxattr;
 	int rc = 0;
+	int flags;
 
 	/* only root could change project ID */
 	if (!capable(CAP_SYS_ADMIN))
@@ -2190,11 +2197,16 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		goto out_fsxattr;
 	}
 
+	flags = ll_xflags_to_inode_flags(fsxattr.fsx_xflags);
+	op_data->op_attr_flags = ll_inode_to_ext_flags(flags);
+	if (fsxattr.fsx_xflags & FS_XFLAG_PROJINHERIT)
+		op_data->op_attr_flags |= LUSTRE_PROJINHERIT_FL;
 	op_data->op_projid = fsxattr.fsx_projid;
 	op_data->op_xvalid |= OP_XVALID_PROJID;
 	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data, NULL,
 			0, &req);
 	ptlrpc_req_finished(req);
+	ll_update_inode_flags(inode, op_data->op_attr_flags);
 
 out_fsxattr:
 	ll_finish_md_op_data(op_data);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 34bcb4b..aaddebf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -108,6 +108,8 @@ enum ll_file_flags {
 	 * local inode atime.
 	 */
 	LLIF_UPDATE_ATIME,
+	/* Project inherit */
+	LLIF_PROJECT_INHERIT	= 3,
 };
 
 struct ll_inode_info {
@@ -857,6 +859,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 		       u64 max_age, u32 flags);
 int ll_update_inode(struct inode *inode, struct lustre_md *md);
+void ll_update_inode_flags(struct inode *inode, int ext_flags);
 int ll_read_inode2(struct inode *inode, void *opaque);
 void ll_delete_inode(struct inode *inode);
 int ll_iocontrol(struct inode *inode, struct file *file,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 7320dc8..fac6584 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1791,6 +1791,17 @@ void ll_inode_size_unlock(struct inode *inode)
 	mutex_unlock(&lli->lli_size_mutex);
 }
 
+void ll_update_inode_flags(struct inode *inode, int ext_flags)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+
+	inode->i_flags = ll_ext_to_inode_flags(ext_flags);
+	if (ext_flags & LUSTRE_PROJINHERIT_FL)
+		set_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags);
+	else
+		clear_bit(LLIF_PROJECT_INHERIT, &lli->lli_flags);
+}
+
 int ll_update_inode(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1862,7 +1873,7 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	if (body->mbo_valid & OBD_MD_FLPROJID)
 		lli->lli_projid = body->mbo_projid;
 	if (body->mbo_valid & OBD_MD_FLFLAGS)
-		inode->i_flags = ll_ext_to_inode_flags(body->mbo_flags);
+		ll_update_inode_flags(inode, body->mbo_flags);
 	if (body->mbo_valid & OBD_MD_FLNLINK)
 		set_nlink(inode, body->mbo_nlink);
 	if (body->mbo_valid & OBD_MD_FLRDEV)
@@ -2024,7 +2035,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		if (rc)
 			return rc;
 
-		inode->i_flags = ll_ext_to_inode_flags(flags);
+		ll_update_inode_flags(inode, flags);
 
 		obj = ll_i2info(inode)->lli_clob;
 		if (!obj)
-- 
1.8.3.1
