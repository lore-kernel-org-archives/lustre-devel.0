From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:20 -0500
Subject: [lustre-devel] [PATCH 512/622] lustre: pcc: Auto attach for PCC
 during IO
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-513-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

PCC uses the layout lock to protect the cache validity. Currently
PCC only supports auto attach at the next open. However, the
layout lock can be revoked at any time by LRU/manual lock
shrinking or lock conflict callback.

For example, the layout lock can be revoked when performing I/Os
after opened the file. At this time, the cached file will be
detached involuntary. The I/O originally directed into PCC will
redirect to OSTs after the data restore into OSTs' objects. The
cost of this unwilling behavior may be expensive.

To avoid this problem, this patch implements auto attach for PCC
even during IOs (not only at the open time).

For debug purpose, now we have three auto attach options:
- open_attach: auto attach at the next open;
- io_attach: auto attach during IO
- stat_attach: auto attach at stat() call.

The reason to add the stat_attach option is that: when check
PCC state via "lfs pcc state", it will not only open the file but
also stat() on the file, to verify the feature of auto attach
during IO, we need to both disable open_attach and stat_attach.

And all these auto attach options are enabled by default.

This patch also fixed the bug for auto cache at create time:
In the current Lustre, the truncate operation will revoke the
LOOKUP ibits lock, and the file dentry cache will be invalidated.
The following open with O_CREAT flag will call into ->atomic_open,
the file was wrongly though as newly created file and try to
auto cache the file. So after client known it is not a
DISP_OPEN_CREATE, it should cleanup the already created PCC copy.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12526
Lustre-commit: a120bb135257 ("LU-12526 pcc: Auto attach for PCC during IO")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/36005
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c                 |  43 +++++----
 fs/lustre/llite/pcc.c                   | 157 ++++++++++++++++++++++++++------
 fs/lustre/llite/pcc.h                   |  45 +++++++--
 include/uapi/linux/lustre/lustre_idl.h  |   1 +
 include/uapi/linux/lustre/lustre_user.h |   8 ++
 5 files changed, 199 insertions(+), 55 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index ce72910..f4ca16e 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -696,11 +696,6 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	return rc;
 }
 
-struct pcc_create_attach {
-	struct pcc_dataset *pca_dataset;
-	struct dentry *pca_dentry;
-};
-
 static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 				   struct lookup_intent *it, void **secctx,
 				   u32 *secctxlen,
@@ -950,8 +945,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	u32 secctxlen = 0;
 	struct dentry *de;
 	struct ll_sb_info *sbi;
-	struct pcc_create_attach pca = {NULL, NULL};
-	struct pcc_dataset *dataset = NULL;
+	struct pcc_create_attach pca = { NULL, NULL };
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE,
@@ -988,6 +982,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		if (!filename_is_volatile(dentry->d_name.name,
 					  dentry->d_name.len, NULL)) {
 			struct pcc_matcher item;
+			struct pcc_dataset *dataset;
 
 			item.pm_uid = from_kuid(&init_user_ns, current_uid());
 			item.pm_gid = from_kgid(&init_user_ns, current_gid());
@@ -1020,18 +1015,30 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 					dput(de);
 				goto out_release;
 			}
-			if (dataset && dentry->d_inode) {
-				rc = pcc_inode_create_fini(dataset,
-							   dentry->d_inode,
-							   pca.pca_dentry);
-				if (rc) {
-					if (de)
-						dput(de);
-					goto out_release;
-				}
+
+			rc = pcc_inode_create_fini(dentry->d_inode, &pca);
+			if (rc) {
+				if (de)
+					dput(de);
+				goto out_release;
 			}
 
 			file->f_mode |= FMODE_CREATED;
+		} else {
+			/* Open the file with O_CREAT, but the file already
+			 * existed on MDT. This may happened in the case that
+			 * the LOOKUP ibits lock is revoked and the
+			 * corresponding dentry cache is deleted.
+			 * i.e. In the current Lustre, the truncate operation
+			 * will revoke the LOOKUP ibits lock, and the file
+			 * dentry cache will be invalidated. The following open
+			 * with O_CREAT flag will call into ->atomic_open, the
+			 * file was wrongly though as newly created file and
+			 * try to auto cache the file. So after client knows it
+			 * is not a DISP_OPEN_CREATE, it should cleanup the
+			 * already created PCC copy.
+			 */
+			pcc_create_attach_cleanup(dir->i_sb, &pca);
 		}
 
 		if (d_really_is_positive(dentry) &&
@@ -1055,11 +1062,11 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		} else {
 			rc = finish_no_open(file, de);
 		}
+	} else {
+		pcc_create_attach_cleanup(dir->i_sb, &pca);
 	}
 
 out_release:
-	if (dataset)
-		pcc_dataset_put(dataset);
 	ll_intent_release(it);
 	kfree(it);
 
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index c8c2442..b926f87 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -472,12 +472,30 @@ static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
 		if (id <= 0)
 			return -EINVAL;
 		cmd->u.pccc_add.pccc_roid = id;
+	} else if (strcmp(key, "auto_attach") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id == 0)
+			cmd->u.pccc_add.pccc_flags &= ~PCC_DATASET_AUTO_ATTACH;
 	} else if (strcmp(key, "open_attach") == 0) {
 		rc = kstrtoul(val, 10, &id);
 		if (rc)
 			return rc;
-		if (id > 0)
-			cmd->u.pccc_add.pccc_flags |= PCC_DATASET_OPEN_ATTACH;
+		if (id == 0)
+			cmd->u.pccc_add.pccc_flags &= ~PCC_DATASET_OPEN_ATTACH;
+	} else if (strcmp(key, "io_attach") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id == 0)
+			cmd->u.pccc_add.pccc_flags &= ~PCC_DATASET_IO_ATTACH;
+	} else if (strcmp(key, "stat_attach") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id == 0)
+			cmd->u.pccc_add.pccc_flags &= ~PCC_DATASET_STAT_ATTACH;
 	} else if (strcmp(key, "rwpcc") == 0) {
 		rc = kstrtoul(val, 10, &id);
 		if (rc)
@@ -504,6 +522,18 @@ static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
 	char *token;
 	int rc;
 
+	switch (cmd->pccc_cmd) {
+	case PCC_ADD_DATASET:
+		/* Enable auto attach by default */
+		cmd->u.pccc_add.pccc_flags |= PCC_DATASET_AUTO_ATTACH;
+		break;
+	case PCC_DEL_DATASET:
+	case PCC_CLEAR_ALL:
+		break;
+	default:
+		return -EINVAL;
+	}
+
 	val = buffer;
 	while (val && strlen(val) != 0) {
 		token = strsep(&val, " ");
@@ -1002,7 +1032,6 @@ static void pcc_inode_init(struct pcc_inode *pcci, struct ll_inode_info *lli)
 {
 	pcci->pcci_lli = lli;
 	lli->lli_pcc_inode = pcci;
-	lli->lli_pcc_state = PCC_STATE_FL_NONE;
 	atomic_set(&pcci->pcci_refcount, 0);
 	pcci->pcci_type = LU_PCC_NONE;
 	pcci->pcci_layout_gen = CL_LAYOUT_GEN_NONE;
@@ -1072,9 +1101,9 @@ void pcc_file_init(struct pcc_file *pccf)
 	pccf->pccf_type = LU_PCC_NONE;
 }
 
-static inline bool pcc_open_attach_enabled(struct pcc_dataset *dataset)
+static inline bool pcc_auto_attach_enabled(struct pcc_dataset *dataset)
 {
-	return dataset->pccd_flags & PCC_DATASET_OPEN_ATTACH;
+	return dataset->pccd_flags & PCC_DATASET_AUTO_ATTACH;
 }
 
 static const char pcc_xattr_layout[] = XATTR_USER_PREFIX "PCC.layout";
@@ -1085,7 +1114,7 @@ static int pcc_layout_xattr_set(struct pcc_inode *pcci, u32 gen)
 	struct ll_inode_info *lli = pcci->pcci_lli;
 	int rc;
 
-	if (!(lli->lli_pcc_state & PCC_STATE_FL_OPEN_ATTACH))
+	if (!(lli->lli_pcc_state & PCC_STATE_FL_AUTO_ATTACH))
 		return 0;
 
 	rc = __vfs_setxattr(pcc_dentry, pcc_dentry->d_inode, pcc_xattr_layout,
@@ -1137,6 +1166,8 @@ static void pcc_inode_attach_init(struct pcc_dataset *dataset,
 				  struct dentry *dentry,
 				  enum lu_pcc_type type)
 {
+	struct ll_inode_info *lli = pcci->pcci_lli;
+
 	pcci->pcci_path.mnt = mntget(dataset->pccd_path.mnt);
 	pcci->pcci_path.dentry = dentry;
 	LASSERT(atomic_read(&pcci->pcci_refcount) == 0);
@@ -1144,11 +1175,12 @@ static void pcc_inode_attach_init(struct pcc_dataset *dataset,
 	pcci->pcci_type = type;
 	pcci->pcci_attr_valid = false;
 
-	if (pcc_open_attach_enabled(dataset)) {
-		struct ll_inode_info *lli = pcci->pcci_lli;
-
+	if (dataset->pccd_flags & PCC_DATASET_OPEN_ATTACH)
 		lli->lli_pcc_state |= PCC_STATE_FL_OPEN_ATTACH;
-	}
+	if (dataset->pccd_flags & PCC_DATASET_IO_ATTACH)
+		lli->lli_pcc_state |= PCC_STATE_FL_IO_ATTACH;
+	if (dataset->pccd_flags & PCC_DATASET_STAT_ATTACH)
+		lli->lli_pcc_state |= PCC_STATE_FL_STAT_ATTACH;
 }
 
 static inline void pcc_layout_gen_set(struct pcc_inode *pcci,
@@ -1252,7 +1284,7 @@ static int pcc_try_datasets_attach(struct inode *inode, u32 gen,
 	down_read(&super->pccs_rw_sem);
 	list_for_each_entry_safe(dataset, tmp,
 				 &super->pccs_datasets, pccd_linkage) {
-		if (!pcc_open_attach_enabled(dataset))
+		if (!pcc_auto_attach_enabled(dataset))
 			continue;
 		rc = pcc_try_dataset_attach(inode, gen, type, dataset, cached);
 		if (rc < 0 || (!rc && *cached))
@@ -1263,13 +1295,15 @@ static int pcc_try_datasets_attach(struct inode *inode, u32 gen,
 	return rc;
 }
 
-static int pcc_try_open_attach(struct inode *inode, bool *cached)
+static int pcc_try_auto_attach(struct inode *inode, bool *cached, bool is_open)
 {
 	struct pcc_super *super = &ll_i2sbi(inode)->ll_pcc_super;
 	struct cl_layout clt = {
 		.cl_layout_gen = 0,
 		.cl_is_released = false,
 	};
+	struct ll_inode_info *lli = ll_i2info(inode);
+	u32 gen;
 	int rc;
 
 	/*
@@ -1283,13 +1317,25 @@ static int pcc_try_open_attach(struct inode *inode, bool *cached)
 	 * obtain valid layout lock from MDT (i.e. the file is being
 	 * HSM restoring).
 	 */
-	if (ll_layout_version_get(ll_i2info(inode)) == CL_LAYOUT_GEN_NONE)
-		return 0;
+	if (is_open) {
+		if (ll_layout_version_get(lli) == CL_LAYOUT_GEN_NONE)
+			return 0;
+	} else {
+		rc = ll_layout_refresh(inode, &gen);
+		if (rc)
+			return rc;
+	}
 
 	rc = pcc_get_layout_info(inode, &clt);
 	if (rc)
 		return rc;
 
+	if (!is_open && gen != clt.cl_layout_gen) {
+		CDEBUG(D_CACHE, DFID" layout changed from %d to %d.\n",
+		       PFID(ll_inode2fid(inode)), gen, clt.cl_layout_gen);
+		return -EINVAL;
+	}
+
 	if (clt.cl_is_released)
 		rc = pcc_try_datasets_attach(inode, clt.cl_layout_gen,
 					     LU_PCC_READWRITE, cached);
@@ -1319,7 +1365,9 @@ int pcc_file_open(struct inode *inode, struct file *file)
 		goto out_unlock;
 
 	if (!pcci || !pcc_inode_has_layout(pcci)) {
-		rc = pcc_try_open_attach(inode, &cached);
+		if (lli->lli_pcc_state & PCC_STATE_FL_OPEN_ATTACH)
+			rc = pcc_try_auto_attach(inode, &cached, true);
+
 		if (rc < 0 || !cached)
 			goto out_unlock;
 
@@ -1379,8 +1427,9 @@ void pcc_file_release(struct inode *inode, struct file *file)
 	pcc_inode_unlock(inode);
 }
 
-static void pcc_io_init(struct inode *inode, bool *cached)
+static void pcc_io_init(struct inode *inode, enum pcc_io_type iot, bool *cached)
 {
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct pcc_inode *pcci;
 
 	pcc_inode_lock(inode);
@@ -1391,6 +1440,17 @@ static void pcc_io_init(struct inode *inode, bool *cached)
 		*cached = true;
 	} else {
 		*cached = false;
+		if ((lli->lli_pcc_state & PCC_STATE_FL_IO_ATTACH &&
+		     iot != PIT_GETATTR) ||
+		    (iot == PIT_GETATTR &&
+		     lli->lli_pcc_state & PCC_STATE_FL_STAT_ATTACH)) {
+			(void) pcc_try_auto_attach(inode, cached, false);
+			if (*cached) {
+				pcci = ll_i2pcci(inode);
+				LASSERT(atomic_read(&pcci->pcci_refcount) > 0);
+				atomic_inc(&pcci->pcci_active_ios);
+			}
+		}
 	}
 	pcc_inode_unlock(inode);
 }
@@ -1418,7 +1478,7 @@ ssize_t pcc_file_read_iter(struct kiocb *iocb,
 		return 0;
 	}
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_READ, cached);
 	if (!*cached)
 		return 0;
 
@@ -1453,7 +1513,7 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb,
 		return -EAGAIN;
 	}
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_WRITE, cached);
 	if (!*cached)
 		return 0;
 
@@ -1489,7 +1549,7 @@ int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
 		return 0;
 	}
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_GETATTR, cached);
 	if (!*cached)
 		return 0;
 
@@ -1523,7 +1583,7 @@ int pcc_inode_getattr(struct inode *inode, bool *cached)
 		return 0;
 	}
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_SETATTR, cached);
 	if (!*cached)
 		return 0;
 
@@ -1585,7 +1645,7 @@ ssize_t pcc_file_splice_read(struct file *in_file, loff_t *ppos,
 	if (!file_inode(pcc_file)->i_fop->splice_read)
 		return -ENOTSUPP;
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_SPLICE_READ, cached);
 	if (!*cached)
 		return 0;
 
@@ -1610,7 +1670,7 @@ int pcc_fsync(struct file *file, loff_t start, loff_t end,
 		return 0;
 	}
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_FSYNC, cached);
 	if (!*cached)
 		return 0;
 
@@ -1716,7 +1776,7 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		CDEBUG(D_MMAP,
 		       "%s: PCC backend fs not support ->page_mkwrite()\n",
 		       ll_i2sbi(inode)->ll_fsname);
-		pcc_ioctl_detach(inode, PCC_DETACH_OPT_NONE);
+		pcc_ioctl_detach(inode, PCC_DETACH_OPT_UNCACHE);
 		up_read(&mm->mmap_sem);
 		*cached = true;
 		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
@@ -1724,7 +1784,7 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	/* Pause to allow for a race with concurrent detach */
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE, cfs_fail_val);
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_PAGE_MKWRITE, cached);
 	if (!*cached) {
 		/* This happens when the file is detached from PCC after got
 		 * the fault page via ->fault() on the inode of the PCC copy.
@@ -1757,7 +1817,7 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 */
 	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PCC_DETACH_MKWRITE)) {
 		pcc_io_fini(inode);
-		pcc_ioctl_detach(inode, PCC_DETACH_OPT_NONE);
+		pcc_ioctl_detach(inode, PCC_DETACH_OPT_UNCACHE);
 		up_read(&mm->mmap_sem);
 		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
 	}
@@ -1785,7 +1845,7 @@ int pcc_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return 0;
 	}
 
-	pcc_io_init(inode, cached);
+	pcc_io_init(inode, PIT_FAULT, cached);
 	if (!*cached)
 		return 0;
 
@@ -1993,13 +2053,21 @@ int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
 	return rc;
 }
 
-int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
-			  struct dentry *pcc_dentry)
+int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca)
 {
+	struct dentry *pcc_dentry = pca->pca_dentry;
 	const struct cred *old_cred;
 	struct pcc_inode *pcci;
 	int rc = 0;
 
+	if (!pca->pca_dataset)
+		return 0;
+
+	if (!inode)
+		goto out_dataset_put;
+
+	LASSERT(pcc_dentry);
+
 	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	pcc_inode_lock(inode);
 	LASSERT(!ll_i2pcci(inode));
@@ -2015,7 +2083,8 @@ int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 		goto out_put;
 
 	pcc_inode_init(pcci, ll_i2info(inode));
-	pcc_inode_attach_init(dataset, pcci, pcc_dentry, LU_PCC_READWRITE);
+	pcc_inode_attach_init(pca->pca_dataset, pcci, pcc_dentry,
+			      LU_PCC_READWRITE);
 
 	rc = pcc_layout_xattr_set(pcci, 0);
 	if (rc) {
@@ -2038,9 +2107,36 @@ int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 	pcc_inode_unlock(inode);
 	revert_creds(old_cred);
 
+out_dataset_put:
+	pcc_dataset_put(pca->pca_dataset);
 	return rc;
 }
 
+void pcc_create_attach_cleanup(struct super_block *sb,
+			       struct pcc_create_attach *pca)
+{
+	if (!pca->pca_dataset)
+		return;
+
+	if (pca->pca_dentry) {
+		const struct cred *old_cred;
+		int rc;
+
+		old_cred = override_creds(pcc_super_cred(sb));
+		rc = vfs_unlink(pca->pca_dentry->d_parent->d_inode,
+				pca->pca_dentry, NULL);
+		if (rc)
+			CWARN("failed to unlink PCC file %.*s, rc = %d\n",
+			      pca->pca_dentry->d_name.len,
+			      pca->pca_dentry->d_name.name, rc);
+		/* ignore the unlink failure */
+		revert_creds(old_cred);
+		dput(pca->pca_dentry);
+	}
+
+	pcc_dataset_put(pca->pca_dataset);
+}
+
 static int pcc_filp_write(struct file *filp, const void *buf, ssize_t count,
 			  loff_t *offset)
 {
@@ -2202,7 +2298,6 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	pcc_inode_lock(inode);
 	pcci = ll_i2pcci(inode);
-	lli->lli_pcc_state &= ~PCC_STATE_FL_ATTACHING;
 	if (rc || lease_broken) {
 		if (attached && pcci)
 			pcc_inode_put(pcci);
@@ -2221,6 +2316,7 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 	if (rc)
 		goto out_put;
 
+	LASSERT(lli->lli_pcc_state & PCC_STATE_FL_ATTACHING);
 	rc = ll_layout_refresh(inode, &gen2);
 	if (!rc) {
 		if (gen2 == gen) {
@@ -2240,6 +2336,7 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 		pcc_inode_put(pcci);
 	}
 out_unlock:
+	lli->lli_pcc_state &= ~PCC_STATE_FL_ATTACHING;
 	pcc_inode_unlock(inode);
 	revert_creds(old_cred);
 	return rc;
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index c00cb0b..a221ef6 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -93,12 +93,19 @@ struct pcc_matcher {
 
 enum pcc_dataset_flags {
 	PCC_DATASET_NONE	= 0x0,
-	/* Try auto attach at open, disabled by default */
-	PCC_DATASET_OPEN_ATTACH	= 0x1,
+	/* Try auto attach at open, enabled by default */
+	PCC_DATASET_OPEN_ATTACH	= 0x01,
+	/* Try auto attach during IO when layout refresh, enabled by default */
+	PCC_DATASET_IO_ATTACH	= 0x02,
+	/* Try auto attach at stat */
+	PCC_DATASET_STAT_ATTACH	= 0x04,
+	PCC_DATASET_AUTO_ATTACH	= PCC_DATASET_OPEN_ATTACH |
+				  PCC_DATASET_IO_ATTACH |
+				  PCC_DATASET_STAT_ATTACH,
 	/* PCC backend is only used for RW-PCC */
-	PCC_DATASET_RWPCC	= 0x2,
+	PCC_DATASET_RWPCC	= 0x08,
 	/* PCC backend is only used for RO-PCC */
-	PCC_DATASET_ROPCC	= 0x4,
+	PCC_DATASET_ROPCC	= 0x10,
 	/* PCC backend provides caching services for both RW-PCC and RO-PCC */
 	PCC_DATASET_PCC_ALL	= PCC_DATASET_RWPCC | PCC_DATASET_ROPCC,
 };
@@ -154,6 +161,25 @@ struct pcc_file {
 	enum lu_pcc_type	 pccf_type;
 };
 
+enum pcc_io_type {
+	/* read system call */
+	PIT_READ = 1,
+	/* write system call */
+	PIT_WRITE,
+	/* truncate, utime system calls */
+	PIT_SETATTR,
+	/* stat system call */
+	PIT_GETATTR,
+	/* mmap write handling */
+	PIT_PAGE_MKWRITE,
+	/* page fault handling */
+	PIT_FAULT,
+	/* fsync system call handling */
+	PIT_FSYNC,
+	/* splice_read system call */
+	PIT_SPLICE_READ
+};
+
 enum pcc_cmd_type {
 	PCC_ADD_DATASET = 0,
 	PCC_DEL_DATASET,
@@ -177,6 +203,11 @@ struct pcc_cmd {
 	} u;
 };
 
+struct pcc_create_attach {
+	struct pcc_dataset *pca_dataset;
+	struct dentry *pca_dentry;
+};
+
 int pcc_super_init(struct pcc_super *super);
 void pcc_super_fini(struct pcc_super *super);
 int pcc_cmd_handle(char *buffer, unsigned long count,
@@ -212,12 +243,12 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		     bool *cached);
 int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
 		     struct lu_fid *fid, struct dentry **pcc_dentry);
-int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
-			   struct dentry *pcc_dentry);
+int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca);
+void pcc_create_attach_cleanup(struct super_block *sb,
+			       struct pcc_create_attach *pca);
 struct pcc_dataset *pcc_dataset_match_get(struct pcc_super *super,
 					  struct pcc_matcher *matcher);
 void pcc_dataset_put(struct pcc_dataset *dataset);
 void pcc_inode_free(struct inode *inode);
 void pcc_layout_invalidate(struct inode *inode);
-
 #endif /* LLITE_PCC_H */
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 4277ac6..a74d979 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1723,6 +1723,7 @@ enum mds_op_bias {
 	MDS_CLOSE_LAYOUT_SPLIT	= 1 << 17,
 	MDS_TRUNC_KEEP_LEASE	= 1 << 18,
 	MDS_PCC_ATTACH		= 1 << 19,
+	MDS_CLOSE_UPDATE_TIMES	= 1 << 20,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 06a691b..2178666 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -2180,6 +2180,14 @@ enum lu_pcc_state_flags {
 	PCC_STATE_FL_ATTACHING		= 0x02,
 	/* Allow to auto attach at open */
 	PCC_STATE_FL_OPEN_ATTACH	= 0x04,
+	/* Allow to auto attach during I/O after layout lock revocation */
+	PCC_STATE_FL_IO_ATTACH		= 0x08,
+	/* Allow to auto attach at stat */
+	PCC_STATE_FL_STAT_ATTACH	= 0x10,
+	/* Allow to auto attach@the next open or layout refresh */
+	PCC_STATE_FL_AUTO_ATTACH	= PCC_STATE_FL_OPEN_ATTACH |
+					  PCC_STATE_FL_IO_ATTACH |
+					  PCC_STATE_FL_STAT_ATTACH,
 };
 
 struct lu_pcc_state {
-- 
1.8.3.1
