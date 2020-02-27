From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:51 -0500
Subject: [lustre-devel] [PATCH 363/622] lustre: pcc: change detach behavior
 and add keep option
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-364-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

After introduce the feature of auto-attach at open, when the PCC
cached file is detach by "pcc detach" command, it will be attached
automatically at the next open. This may be not what the user wants.

To solve this problem, we change the default detach behavior and
add an option "--keep|-k" for the detach of RW-PCC.
The manual "lfs pcc detach" command will detach the file from PCC
permanently. And it will also remove the PCC copy by default.
When the file is detached with "keep" option, it only unmaps the
relationship between the file inode and PCC copy, but keep the
PCC copy. The file is allowed to be attached automatically at
the next open when the file is still valid in cache.

Note here that currently auto detach caused by inode reclaim or
revocation of the layout lock would not delete the PCC copy too.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10092
Lustre-commit: 2dadefb4148f ("LU-10092 pcc: change detach behavior and add keep option")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/33844
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   |  6 +--
 fs/lustre/llite/file.c                  | 33 +++++++++++++---
 fs/lustre/llite/pcc.c                   | 68 ++++++++++++++++++++++++++++++---
 fs/lustre/llite/pcc.h                   |  2 +-
 include/uapi/linux/lustre/lustre_user.h | 16 ++++++--
 5 files changed, 107 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 1f7ed32..2c39579 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1918,7 +1918,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case FS_IOC_FSSETXATTR:
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
 	case LL_IOC_PCC_DETACH_BY_FID: {
-		struct lu_pcc_detach *detach;
+		struct lu_pcc_detach_fid *detach;
 		struct lu_fid *fid;
 		struct inode *inode2;
 		unsigned long ino;
@@ -1928,7 +1928,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return -ENOMEM;
 
 		if (copy_from_user(detach,
-				   (const struct lu_pcc_detach __user *)arg,
+				   (const struct lu_pcc_detach_fid __user *)arg,
 				   sizeof(*detach))) {
 			rc = -EFAULT;
 			goto out_detach;
@@ -1955,7 +1955,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_iput;
 		}
 
-		rc = pcc_ioctl_detach(inode2);
+		rc = pcc_ioctl_detach(inode2, detach->pccd_opt);
 out_iput:
 		iput(inode2);
 out_detach:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 96311ad..a27c06c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3732,14 +3732,35 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		rc = ll_heat_set(inode, flags);
 		return rc;
 	}
-	case LL_IOC_PCC_DETACH:
-		if (!S_ISREG(inode->i_mode))
-			return -EINVAL;
+	case LL_IOC_PCC_DETACH: {
+		struct lu_pcc_detach *detach;
 
-		if (!inode_owner_or_capable(inode))
-			return -EPERM;
+		detach = kzalloc(sizeof(*detach), GFP_KERNEL);
+		if (!detach)
+			return -ENOMEM;
+
+		if (copy_from_user(detach,
+				   (const struct lu_pcc_detach __user *)arg,
+				   sizeof(*detach))) {
+			rc = -EFAULT;
+			goto out_detach_free;
+		}
+
+		if (!S_ISREG(inode->i_mode)) {
+			rc = -EINVAL;
+			goto out_detach_free;
+		}
 
-		return pcc_ioctl_detach(inode);
+		if (!inode_owner_or_capable(inode)) {
+			rc = -EPERM;
+			goto out_detach_free;
+		}
+
+		rc = pcc_ioctl_detach(inode, detach->pccd_opt);
+out_detach_free:
+		kfree(detach);
+		return rc;
+	}
 	case LL_IOC_PCC_STATE: {
 		struct lu_pcc_state __user *ustate =
 			(struct lu_pcc_state __user *)arg;
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index fc4a2a3..c8c2442 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1002,6 +1002,7 @@ static void pcc_inode_init(struct pcc_inode *pcci, struct ll_inode_info *lli)
 {
 	pcci->pcci_lli = lli;
 	lli->lli_pcc_inode = pcci;
+	lli->lli_pcc_state = PCC_STATE_FL_NONE;
 	atomic_set(&pcci->pcci_refcount, 0);
 	pcci->pcci_type = LU_PCC_NONE;
 	pcci->pcci_layout_gen = CL_LAYOUT_GEN_NONE;
@@ -1715,8 +1716,9 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		CDEBUG(D_MMAP,
 		       "%s: PCC backend fs not support ->page_mkwrite()\n",
 		       ll_i2sbi(inode)->ll_fsname);
-		pcc_ioctl_detach(inode);
+		pcc_ioctl_detach(inode, PCC_DETACH_OPT_NONE);
 		up_read(&mm->mmap_sem);
+		*cached = true;
 		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
 	}
 	/* Pause to allow for a race with concurrent detach */
@@ -1755,7 +1757,7 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PCC_DETACH_MKWRITE)) {
 		pcc_io_fini(inode);
-		pcc_ioctl_detach(inode);
+		pcc_ioctl_detach(inode, PCC_DETACH_OPT_NONE);
 		up_read(&mm->mmap_sem);
 		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
 	}
@@ -2243,10 +2245,51 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 	return rc;
 }
 
-int pcc_ioctl_detach(struct inode *inode)
+static int pcc_hsm_remove(struct inode *inode)
+{
+	struct hsm_user_request *hur;
+	u32 gen;
+	int len;
+	int rc;
+
+	rc = ll_layout_restore(inode, 0, OBD_OBJECT_EOF);
+	if (rc) {
+		CDEBUG(D_CACHE, DFID" RESTORE failure: %d\n",
+		       PFID(&ll_i2info(inode)->lli_fid), rc);
+		return rc;
+	}
+
+	ll_layout_refresh(inode, &gen);
+
+	len = sizeof(struct hsm_user_request) +
+	      sizeof(struct hsm_user_item);
+	hur = kzalloc(len, GFP_NOFS);
+	if (!hur)
+		return -ENOMEM;
+
+	hur->hur_request.hr_action = HUA_REMOVE;
+	hur->hur_request.hr_archive_id = 0;
+	hur->hur_request.hr_flags = 0;
+	memcpy(&hur->hur_user_item[0].hui_fid, &ll_i2info(inode)->lli_fid,
+	       sizeof(hur->hur_user_item[0].hui_fid));
+	hur->hur_user_item[0].hui_extent.offset = 0;
+	hur->hur_user_item[0].hui_extent.length = OBD_OBJECT_EOF;
+	hur->hur_request.hr_itemcount = 1;
+	rc = obd_iocontrol(LL_IOC_HSM_REQUEST, ll_i2sbi(inode)->ll_md_exp,
+			   len, hur, NULL);
+	if (rc)
+		CDEBUG(D_CACHE, DFID" HSM REMOVE failure: %d\n",
+		       PFID(&ll_i2info(inode)->lli_fid), rc);
+
+	kfree(hur);
+	return rc;
+}
+
+int pcc_ioctl_detach(struct inode *inode, u32 opt)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct pcc_inode *pcci;
+	bool hsm_remove = false;
 	int rc = 0;
 
 	pcc_inode_lock(inode);
@@ -2255,11 +2298,26 @@ int pcc_ioctl_detach(struct inode *inode)
 	    !pcc_inode_has_layout(pcci))
 		goto out_unlock;
 
-	__pcc_layout_invalidate(pcci);
-	pcc_inode_put(pcci);
+	LASSERT(atomic_read(&pcci->pcci_refcount) > 0);
+
+	if (pcci->pcci_type == LU_PCC_READWRITE) {
+		if (opt == PCC_DETACH_OPT_UNCACHE)
+			hsm_remove = true;
+
+		__pcc_layout_invalidate(pcci);
+		pcc_inode_put(pcci);
+	}
 
 out_unlock:
 	pcc_inode_unlock(inode);
+	if (hsm_remove) {
+		const struct cred *old_cred;
+
+		old_cred = override_creds(pcc_super_cred(inode->i_sb));
+		rc = pcc_hsm_remove(inode);
+		revert_creds(old_cred);
+	}
+
 	return rc;
 }
 
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index 4947911..c00cb0b 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -187,7 +187,7 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 			      u32 gen, bool lease_broken, int rc,
 			      bool attached);
-int pcc_ioctl_detach(struct inode *inode);
+int pcc_ioctl_detach(struct inode *inode, u32 opt);
 int pcc_ioctl_state(struct file *file, struct inode *inode,
 		    struct lu_pcc_state *state);
 void pcc_file_init(struct pcc_file *pccf);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 2f9687e..317b236 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -357,8 +357,8 @@ struct ll_ioc_lease_id {
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 #define LL_IOC_HEAT_GET			_IOWR('f', 251, struct lu_heat)
 #define LL_IOC_HEAT_SET			_IOW('f', 251, __u64)
-#define LL_IOC_PCC_DETACH		_IO('f', 252)
-#define LL_IOC_PCC_DETACH_BY_FID	_IOW('f', 252, struct lu_pcc_detach)
+#define LL_IOC_PCC_DETACH		_IOW('f', 252, struct lu_pcc_detach)
+#define LL_IOC_PCC_DETACH_BY_FID	_IOW('f', 252, struct lu_pcc_detach_fid)
 #define LL_IOC_PCC_STATE		_IOR('f', 252, struct lu_pcc_state)
 
 #define LL_STATFS_LMV		1
@@ -2093,9 +2093,19 @@ struct lu_pcc_attach {
 	__u32 pcca_id; /* archive ID for readwrite, group ID for readonly */
 };
 
-struct lu_pcc_detach {
+enum lu_pcc_detach_opts {
+	PCC_DETACH_OPT_NONE = 0, /* Detach only, keep the PCC copy */
+	PCC_DETACH_OPT_UNCACHE, /* Remove the cached file after detach */
+};
+
+struct lu_pcc_detach_fid {
 	/* fid of the file to detach */
 	struct lu_fid	pccd_fid;
+	__u32		pccd_opt;
+};
+
+struct lu_pcc_detach {
+	__u32		pccd_opt;
 };
 
 enum lu_pcc_state_flags {
-- 
1.8.3.1
