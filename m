From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:50 -0500
Subject: [lustre-devel] [PATCH 362/622] lustre: pcc: auto attach during open
 for valid cache
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-363-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

In current PCC implementation, all PCC state information is
stored in the in-memory data structure named pcc_inode (a member
of data structure ll_inode_info). Once the file inode is reclaimed
due to the memory pressure or memory shrinking, the corresponding
in-memory pcc_inode will be released too, and the PCC-cached file
will be detached automatically. And the revocation of layout lock
will also trigger the detach of the PCC-cached file. These all lead
that the still valid PCC-cached file can not be used.

To solve this problem, we introduce an auto-attaching mechanism
during open. During PCC attach, the L.Gen will be stored as
extented attribute of the local copy file on PCC device. When the
in-memory inode is reclaimed or the layout lock is revoked, and
the file is opend again, it can check whether the stored L.Gen on
the PCC copy is same as the Lustre file current L.Gen on MDT. If
they are consistent, it means the cached copy on PCC device is still
valid, we can continue to use it after auto-attach.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10092
Lustre-commit: e29ecb659e51 ("LU-10092 pcc: auto attach during open for valid cache")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/33787
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h           |   2 +
 fs/lustre/llite/pcc.c                   | 400 ++++++++++++++++++++++++++------
 fs/lustre/llite/pcc.h                   |  18 +-
 fs/lustre/lov/lov_object.c              |   1 +
 include/uapi/linux/lustre/lustre_user.h |   2 +
 5 files changed, 348 insertions(+), 75 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 3337bbf..d1c1413 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -293,6 +293,8 @@ struct cl_layout {
 	u32			cl_layout_gen;
 	/** whether layout is a composite one */
 	bool			cl_is_composite;
+	/** Whether layout is a HSM released one */
+	bool			cl_is_released;
 };
 
 /**
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 469ff6c..fc4a2a3 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -124,7 +124,7 @@ int pcc_super_init(struct pcc_super *super)
 
 	/* Never override disk quota limits or use reserved space */
 	cap_lower(cred->cap_effective, CAP_SYS_RESOURCE);
-	spin_lock_init(&super->pccs_lock);
+	init_rwsem(&super->pccs_rw_sem);
 	INIT_LIST_HEAD(&super->pccs_datasets);
 
 	return 0;
@@ -472,6 +472,24 @@ static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
 		if (id <= 0)
 			return -EINVAL;
 		cmd->u.pccc_add.pccc_roid = id;
+	} else if (strcmp(key, "open_attach") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id > 0)
+			cmd->u.pccc_add.pccc_flags |= PCC_DATASET_OPEN_ATTACH;
+	} else if (strcmp(key, "rwpcc") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id > 0)
+			cmd->u.pccc_add.pccc_flags |= PCC_DATASET_RWPCC;
+	} else if (strcmp(key, "ropcc") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id > 0)
+			cmd->u.pccc_add.pccc_flags |= PCC_DATASET_ROPCC;
 	} else {
 		return -EINVAL;
 	}
@@ -494,6 +512,24 @@ static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
 			return rc;
 	}
 
+	switch (cmd->pccc_cmd) {
+	case PCC_ADD_DATASET:
+		if (cmd->u.pccc_add.pccc_flags & PCC_DATASET_RWPCC &&
+		    cmd->u.pccc_add.pccc_flags & PCC_DATASET_ROPCC)
+			return -EINVAL;
+		/*
+		 * By default, a PCC backend can provide caching service for
+		 * both RW-PCC and RO-PCC.
+		 */
+		if ((cmd->u.pccc_add.pccc_flags & PCC_DATASET_PCC_ALL) == 0)
+			cmd->u.pccc_add.pccc_flags |= PCC_DATASET_PCC_ALL;
+		break;
+	case PCC_DEL_DATASET:
+	case PCC_CLEAR_ALL:
+		break;
+	default:
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -641,15 +677,18 @@ struct pcc_dataset*
 	struct pcc_dataset *dataset;
 	struct pcc_dataset *selected = NULL;
 
-	spin_lock(&super->pccs_lock);
+	down_read(&super->pccs_rw_sem);
 	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
+		if (!(dataset->pccd_flags & PCC_DATASET_RWPCC))
+			continue;
+
 		if (pcc_cond_match(&dataset->pccd_rule, matcher)) {
 			atomic_inc(&dataset->pccd_refcount);
 			selected = dataset;
 			break;
 		}
 	}
-	spin_unlock(&super->pccs_lock);
+	up_read(&super->pccs_rw_sem);
 	if (selected)
 		CDEBUG(D_CACHE, "PCC create, matched %s - %d:%d:%d:%s\n",
 		       dataset->pccd_rule.pmr_conds_str,
@@ -687,6 +726,7 @@ struct pcc_dataset*
 	strncpy(dataset->pccd_pathname, pathname, PATH_MAX);
 	dataset->pccd_rwid = cmd->u.pccc_add.pccc_rwid;
 	dataset->pccd_roid = cmd->u.pccc_add.pccc_roid;
+	dataset->pccd_flags = cmd->u.pccc_add.pccc_flags;
 	atomic_set(&dataset->pccd_refcount, 1);
 
 	rc = pcc_dataset_rule_init(&dataset->pccd_rule, cmd);
@@ -695,7 +735,7 @@ struct pcc_dataset*
 		return rc;
 	}
 
-	spin_lock(&super->pccs_lock);
+	down_write(&super->pccs_rw_sem);
 	list_for_each_entry(tmp, &super->pccs_datasets, pccd_linkage) {
 		if (strcmp(tmp->pccd_pathname, pathname) == 0 ||
 		    (dataset->pccd_rwid != 0 &&
@@ -708,7 +748,7 @@ struct pcc_dataset*
 	}
 	if (!found)
 		list_add(&dataset->pccd_linkage, &super->pccs_datasets);
-	spin_unlock(&super->pccs_lock);
+	up_write(&super->pccs_rw_sem);
 
 	if (found) {
 		pcc_dataset_put(dataset);
@@ -731,15 +771,16 @@ struct pcc_dataset *
 	 * archive ID (read-write ID) or read-only ID is unique in the list,
 	 * we just return last added one as first priority.
 	 */
-	spin_lock(&super->pccs_lock);
+	down_read(&super->pccs_rw_sem);
 	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
-		if (type == LU_PCC_READWRITE && dataset->pccd_rwid != id)
+		if (type == LU_PCC_READWRITE && (dataset->pccd_rwid != id ||
+		    !(dataset->pccd_flags & PCC_DATASET_RWPCC)))
 			continue;
 		atomic_inc(&dataset->pccd_refcount);
 		selected = dataset;
 		break;
 	}
-	spin_unlock(&super->pccs_lock);
+	up_read(&super->pccs_rw_sem);
 	if (selected)
 		CDEBUG(D_CACHE, "matched id %u, PCC mode %d\n", id, type);
 
@@ -763,17 +804,17 @@ struct pcc_dataset *
 	struct pcc_dataset *dataset;
 	int rc = -ENOENT;
 
-	spin_lock(&super->pccs_lock);
+	down_write(&super->pccs_rw_sem);
 	list_for_each_safe(l, tmp, &super->pccs_datasets) {
 		dataset = list_entry(l, struct pcc_dataset, pccd_linkage);
 		if (strcmp(dataset->pccd_pathname, pathname) == 0) {
-			list_del(&dataset->pccd_linkage);
+			list_del_init(&dataset->pccd_linkage);
 			pcc_dataset_put(dataset);
 			rc = 0;
 			break;
 		}
 	}
-	spin_unlock(&super->pccs_lock);
+	up_write(&super->pccs_rw_sem);
 	return rc;
 }
 
@@ -782,6 +823,7 @@ struct pcc_dataset *
 {
 	seq_printf(m, "%s:\n", dataset->pccd_pathname);
 	seq_printf(m, "  rwid: %u\n", dataset->pccd_rwid);
+	seq_printf(m, "  flags: %x\n", dataset->pccd_flags);
 	seq_printf(m, "  autocache: %s\n", dataset->pccd_rule.pmr_conds_str);
 }
 
@@ -790,11 +832,11 @@ struct pcc_dataset *
 {
 	struct pcc_dataset *dataset;
 
-	spin_lock(&super->pccs_lock);
+	down_read(&super->pccs_rw_sem);
 	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
 		pcc_dataset_dump(dataset, m);
 	}
-	spin_unlock(&super->pccs_lock);
+	up_read(&super->pccs_rw_sem);
 	return 0;
 }
 
@@ -802,11 +844,13 @@ static void pcc_remove_datasets(struct pcc_super *super)
 {
 	struct pcc_dataset *dataset, *tmp;
 
+	down_write(&super->pccs_rw_sem);
 	list_for_each_entry_safe(dataset, tmp,
 				 &super->pccs_datasets, pccd_linkage) {
 		list_del(&dataset->pccd_linkage);
 		pcc_dataset_put(dataset);
 	}
+	up_write(&super->pccs_rw_sem);
 }
 
 void pcc_super_fini(struct pcc_super *super)
@@ -1027,19 +1071,241 @@ void pcc_file_init(struct pcc_file *pccf)
 	pccf->pccf_type = LU_PCC_NONE;
 }
 
+static inline bool pcc_open_attach_enabled(struct pcc_dataset *dataset)
+{
+	return dataset->pccd_flags & PCC_DATASET_OPEN_ATTACH;
+}
+
+static const char pcc_xattr_layout[] = XATTR_USER_PREFIX "PCC.layout";
+
+static int pcc_layout_xattr_set(struct pcc_inode *pcci, u32 gen)
+{
+	struct dentry *pcc_dentry = pcci->pcci_path.dentry;
+	struct ll_inode_info *lli = pcci->pcci_lli;
+	int rc;
+
+	if (!(lli->lli_pcc_state & PCC_STATE_FL_OPEN_ATTACH))
+		return 0;
+
+	rc = __vfs_setxattr(pcc_dentry, pcc_dentry->d_inode, pcc_xattr_layout,
+			    &gen, sizeof(gen), 0);
+	return rc;
+}
+
+static int pcc_get_layout_info(struct inode *inode, struct cl_layout *clt)
+{
+	struct lu_env *env;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	u16 refcheck;
+	int rc;
+
+	if (!lli->lli_clob)
+		return -EINVAL;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	rc = cl_object_layout_get(env, lli->lli_clob, clt);
+	if (rc)
+		CDEBUG(D_INODE, "Cannot get layout for "DFID"\n",
+		       PFID(ll_inode2fid(inode)));
+
+	cl_env_put(env, &refcheck);
+	return rc;
+}
+
+static int pcc_fid2dataset_fullpath(char *buf, int sz, struct lu_fid *fid,
+				    struct pcc_dataset *dataset)
+{
+	return snprintf(buf, sz, "%s/%04x/%04x/%04x/%04x/%04x/%04x/"
+			DFID_NOBRACE,
+			dataset->pccd_pathname,
+			(fid)->f_oid       & 0xFFFF,
+			(fid)->f_oid >> 16 & 0xFFFF,
+			(unsigned int)((fid)->f_seq       & 0xFFFF),
+			(unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
+			(unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
+			(unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
+			PFID(fid));
+}
+
+/* Must be called with pcci->pcci_lock held */
+static void pcc_inode_attach_init(struct pcc_dataset *dataset,
+				  struct pcc_inode *pcci,
+				  struct dentry *dentry,
+				  enum lu_pcc_type type)
+{
+	pcci->pcci_path.mnt = mntget(dataset->pccd_path.mnt);
+	pcci->pcci_path.dentry = dentry;
+	LASSERT(atomic_read(&pcci->pcci_refcount) == 0);
+	atomic_set(&pcci->pcci_refcount, 1);
+	pcci->pcci_type = type;
+	pcci->pcci_attr_valid = false;
+
+	if (pcc_open_attach_enabled(dataset)) {
+		struct ll_inode_info *lli = pcci->pcci_lli;
+
+		lli->lli_pcc_state |= PCC_STATE_FL_OPEN_ATTACH;
+	}
+}
+
+static inline void pcc_layout_gen_set(struct pcc_inode *pcci,
+				      u32 gen)
+{
+	pcci->pcci_layout_gen = gen;
+}
+
 static inline bool pcc_inode_has_layout(struct pcc_inode *pcci)
 {
 	return pcci->pcci_layout_gen != CL_LAYOUT_GEN_NONE;
 }
 
+static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
+				  enum lu_pcc_type type,
+				  struct pcc_dataset *dataset,
+				  bool *cached)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci = lli->lli_pcc_inode;
+	const struct cred *old_cred;
+	struct dentry *pcc_dentry;
+	struct path path;
+	char *pathname;
+	u32 pcc_gen;
+	int rc;
+
+	if (type == LU_PCC_READWRITE &&
+	    !(dataset->pccd_flags & PCC_DATASET_RWPCC))
+		return 0;
+
+	pathname = kzalloc(PATH_MAX, GFP_KERNEL);
+	if (!pathname)
+		return -ENOMEM;
+
+	pcc_fid2dataset_fullpath(pathname, PATH_MAX, &lli->lli_fid, dataset);
+
+	old_cred = override_creds(pcc_super_cred(inode->i_sb));
+	rc = kern_path(pathname, LOOKUP_FOLLOW, &path);
+	if (rc) {
+		/* ignore this error */
+		rc = 0;
+		goto out;
+	}
+
+	pcc_dentry = path.dentry;
+	rc = __vfs_getxattr(pcc_dentry, pcc_dentry->d_inode, pcc_xattr_layout,
+			    &pcc_gen, sizeof(pcc_gen));
+	if (rc < 0) {
+		/* ignore this error */
+		rc = 0;
+		goto out_put_path;
+	}
+
+	rc = 0;
+	/* The file is still valid cached in PCC, attach it immediately. */
+	if (pcc_gen == gen) {
+		CDEBUG(D_CACHE, DFID" L.Gen (%d) consistent, auto attached.\n",
+		       PFID(&lli->lli_fid), gen);
+		if (!pcci) {
+			pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
+			if (!pcci) {
+				rc = -ENOMEM;
+				goto out_put_path;
+			}
+
+			pcc_inode_init(pcci, lli);
+			dget(pcc_dentry);
+			pcc_inode_attach_init(dataset, pcci, pcc_dentry, type);
+		} else {
+			/*
+			 * This happened when a file was once attached into
+			 * PCC, and some processes keep this file opened
+			 * (pcci->refcount > 1) and corresponding PCC file
+			 * without any I/O activity, and then this file was
+			 * detached by the manual detach command or the
+			 * revocation of the layout lock (i.e. cached LRU lock
+			 * shrinking).
+			 */
+			pcc_inode_get(pcci);
+			pcci->pcci_type = type;
+		}
+		pcc_layout_gen_set(pcci, gen);
+		*cached = true;
+	}
+out_put_path:
+	path_put(&path);
+out:
+	revert_creds(old_cred);
+	kfree(pathname);
+	return rc;
+}
+
+static int pcc_try_datasets_attach(struct inode *inode, u32 gen,
+				   enum lu_pcc_type type, bool *cached)
+{
+	struct pcc_dataset *dataset, *tmp;
+	struct pcc_super *super = &ll_i2sbi(inode)->ll_pcc_super;
+	int rc = 0;
+
+	down_read(&super->pccs_rw_sem);
+	list_for_each_entry_safe(dataset, tmp,
+				 &super->pccs_datasets, pccd_linkage) {
+		if (!pcc_open_attach_enabled(dataset))
+			continue;
+		rc = pcc_try_dataset_attach(inode, gen, type, dataset, cached);
+		if (rc < 0 || (!rc && *cached))
+			break;
+	}
+	up_read(&super->pccs_rw_sem);
+
+	return rc;
+}
+
+static int pcc_try_open_attach(struct inode *inode, bool *cached)
+{
+	struct pcc_super *super = &ll_i2sbi(inode)->ll_pcc_super;
+	struct cl_layout clt = {
+		.cl_layout_gen = 0,
+		.cl_is_released = false,
+	};
+	int rc;
+
+	/*
+	 * Quick check whether there is PCC device.
+	 */
+	if (list_empty(&super->pccs_datasets))
+		return 0;
+
+	/*
+	 * The file layout lock was cancelled. And this open does not
+	 * obtain valid layout lock from MDT (i.e. the file is being
+	 * HSM restoring).
+	 */
+	if (ll_layout_version_get(ll_i2info(inode)) == CL_LAYOUT_GEN_NONE)
+		return 0;
+
+	rc = pcc_get_layout_info(inode, &clt);
+	if (rc)
+		return rc;
+
+	if (clt.cl_is_released)
+		rc = pcc_try_datasets_attach(inode, clt.cl_layout_gen,
+					     LU_PCC_READWRITE, cached);
+
+	return rc;
+}
+
 int pcc_file_open(struct inode *inode, struct file *file)
 {
 	struct pcc_inode *pcci;
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct pcc_file *pccf = &fd->fd_pcc_file;
 	struct file *pcc_file;
 	struct path *path;
 	struct qstr *dname;
+	bool cached = false;
 	int rc = 0;
 
 	if (!S_ISREG(inode->i_mode))
@@ -1047,13 +1313,19 @@ int pcc_file_open(struct inode *inode, struct file *file)
 
 	pcc_inode_lock(inode);
 	pcci = ll_i2pcci(inode);
-	if (!pcci)
-		goto out_unlock;
 
-	if (atomic_read(&pcci->pcci_refcount) == 0 ||
-	    !pcc_inode_has_layout(pcci))
+	if (lli->lli_pcc_state & PCC_STATE_FL_ATTACHING)
 		goto out_unlock;
 
+	if (!pcci || !pcc_inode_has_layout(pcci)) {
+		rc = pcc_try_open_attach(inode, &cached);
+		if (rc < 0 || !cached)
+			goto out_unlock;
+
+		if (!pcci)
+			pcci = ll_i2pcci(inode);
+	}
+
 	pcc_inode_get(pcci);
 	WARN_ON(pccf->pccf_file);
 
@@ -1106,12 +1378,6 @@ void pcc_file_release(struct inode *inode, struct file *file)
 	pcc_inode_unlock(inode);
 }
 
-static inline void pcc_layout_gen_set(struct pcc_inode *pcci,
-				      u32 gen)
-{
-	pcci->pcci_layout_gen = gen;
-}
-
 static void pcc_io_init(struct inode *inode, bool *cached)
 {
 	struct pcc_inode *pcci;
@@ -1439,11 +1705,20 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	const struct vm_operations_struct *pcc_vm_ops = vma->vm_private_data;
 	int rc;
 
-	if (!pcc_file || !pcc_vm_ops || !pcc_vm_ops->page_mkwrite) {
+	if (!pcc_file || !pcc_vm_ops) {
 		*cached = false;
 		return 0;
 	}
 
+	if (!pcc_vm_ops->page_mkwrite &&
+	    page->mapping == pcc_file->f_mapping) {
+		CDEBUG(D_MMAP,
+		       "%s: PCC backend fs not support ->page_mkwrite()\n",
+		       ll_i2sbi(inode)->ll_fsname);
+		pcc_ioctl_detach(inode);
+		up_read(&mm->mmap_sem);
+		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
+	}
 	/* Pause to allow for a race with concurrent detach */
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE, cfs_fail_val);
 
@@ -1465,7 +1740,7 @@ int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		 * VM_FAULT_NOPAGE | VM_FAULT_RETRY to the caller
 		 * __do_page_fault and retry the memory fault handling.
 		 */
-		if (page->mapping == file_inode(pcc_file)->i_mapping) {
+		if (page->mapping == pcc_file->f_mapping) {
 			*cached = true;
 			up_read(&mm->mmap_sem);
 			return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
@@ -1554,16 +1829,15 @@ void pcc_layout_invalidate(struct inode *inode)
 	pcc_inode_unlock(inode);
 }
 
-static int pcc_inode_remove(struct pcc_inode *pcci)
+static int pcc_inode_remove(struct inode *inode, struct dentry *pcc_dentry)
 {
-	struct dentry *dentry;
 	int rc;
 
-	dentry = pcci->pcci_path.dentry;
-	rc = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
+	rc = vfs_unlink(pcc_dentry->d_parent->d_inode, pcc_dentry, NULL);
 	if (rc)
-		CWARN("failed to unlink PCC file %.*s, rc = %d\n",
-		      dentry->d_name.len, dentry->d_name.name, rc);
+		CWARN("%s: failed to unlink PCC file %.*s, rc = %d\n",
+		      ll_i2sbi(inode)->ll_fsname, pcc_dentry->d_name.len,
+		      pcc_dentry->d_name.name, rc);
 
 	return rc;
 }
@@ -1651,20 +1925,6 @@ static int pcc_inode_remove(struct pcc_inode *pcci)
 	return dentry;
 }
 
-/* Must be called with pcci->pcci_lock held */
-static void pcc_inode_attach_init(struct pcc_dataset *dataset,
-				  struct pcc_inode *pcci,
-				  struct dentry *dentry,
-				  enum lu_pcc_type type)
-{
-	pcci->pcci_path.mnt = mntget(dataset->pccd_path.mnt);
-	pcci->pcci_path.dentry = dentry;
-	LASSERT(atomic_read(&pcci->pcci_refcount) == 0);
-	atomic_set(&pcci->pcci_refcount, 1);
-	pcci->pcci_type = type;
-	pcci->pcci_attr_valid = false;
-}
-
 static int __pcc_inode_create(struct pcc_dataset *dataset,
 			      struct lu_fid *fid,
 			      struct dentry **dentry)
@@ -1744,38 +2004,37 @@ int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 	pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
 	if (!pcci) {
 		rc = -ENOMEM;
-		goto out_unlock;
+		goto out_put;
 	}
 
 	rc = pcc_inode_store_ugpid(pcc_dentry, old_cred->suid,
 				   old_cred->sgid);
 	if (rc)
-		goto out_unlock;
+		goto out_put;
 
 	pcc_inode_init(pcci, ll_i2info(inode));
 	pcc_inode_attach_init(dataset, pcci, pcc_dentry, LU_PCC_READWRITE);
-	/* Set the layout generation of newly created file with 0 */
-	pcc_layout_gen_set(pcci, 0);
 
-out_unlock:
+	rc = pcc_layout_xattr_set(pcci, 0);
 	if (rc) {
-		int rc2;
+		(void) pcc_inode_remove(inode, pcci->pcci_path.dentry);
+		pcc_inode_put(pcci);
+		goto out_unlock;
+	}
 
-		rc2 = vfs_unlink(pcc_dentry->d_parent->d_inode,
-				 pcc_dentry, NULL);
-		if (rc2)
-			CWARN("%s: failed to unlink PCC file %.*s, rc = %d\n",
-			      ll_i2sbi(inode)->ll_fsname,
-			      pcc_dentry->d_name.len, pcc_dentry->d_name.name,
-			      rc2);
+	/* Set the layout generation of newly created file with 0 */
+	pcc_layout_gen_set(pcci, 0);
 
+out_put:
+	if (rc) {
+		(void) pcc_inode_remove(inode, pcc_dentry);
 		dput(pcc_dentry);
-	}
 
+		kmem_cache_free(pcc_inode_slab, pcci);
+	}
+out_unlock:
 	pcc_inode_unlock(inode);
 	revert_creds(old_cred);
-	if (rc)
-		kmem_cache_free(pcc_inode_slab, pcci);
 
 	return rc;
 }
@@ -1919,16 +2178,9 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	fput(pcc_filp);
 out_dentry:
 	if (rc) {
-		int rc2;
-
 		old_cred = override_creds(pcc_super_cred(inode->i_sb));
-		rc2 = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
+		(void) pcc_inode_remove(inode, dentry);
 		revert_creds(old_cred);
-		if (rc2)
-			CWARN("%s: failed to unlink PCC file %.*s, rc = %d\n",
-			      ll_i2sbi(inode)->ll_fsname, dentry->d_name.len,
-			      dentry->d_name.name, rc2);
-
 		dput(dentry);
 	}
 out_dataset_put:
@@ -1945,6 +2197,7 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 	struct pcc_inode *pcci;
 	u32 gen2;
 
+	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	pcc_inode_lock(inode);
 	pcci = ll_i2pcci(inode);
 	lli->lli_pcc_state &= ~PCC_STATE_FL_ATTACHING;
@@ -1962,6 +2215,10 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 	}
 
 	LASSERT(attached);
+	rc = pcc_layout_xattr_set(pcci, gen);
+	if (rc)
+		goto out_put;
+
 	rc = ll_layout_refresh(inode, &gen2);
 	if (!rc) {
 		if (gen2 == gen) {
@@ -1977,13 +2234,12 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 
 out_put:
 	if (rc) {
-		old_cred = override_creds(pcc_super_cred(inode->i_sb));
-		pcc_inode_remove(pcci);
-		revert_creds(old_cred);
+		(void) pcc_inode_remove(inode, pcci->pcci_path.dentry);
 		pcc_inode_put(pcci);
 	}
 out_unlock:
 	pcc_inode_unlock(inode);
+	revert_creds(old_cred);
 	return rc;
 }
 
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index f2b57f9..4947911 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -91,12 +91,23 @@ struct pcc_matcher {
 	struct qstr	*pm_name;
 };
 
+enum pcc_dataset_flags {
+	PCC_DATASET_NONE	= 0x0,
+	/* Try auto attach at open, disabled by default */
+	PCC_DATASET_OPEN_ATTACH	= 0x1,
+	/* PCC backend is only used for RW-PCC */
+	PCC_DATASET_RWPCC	= 0x2,
+	/* PCC backend is only used for RO-PCC */
+	PCC_DATASET_ROPCC	= 0x4,
+	/* PCC backend provides caching services for both RW-PCC and RO-PCC */
+	PCC_DATASET_PCC_ALL	= PCC_DATASET_RWPCC | PCC_DATASET_ROPCC,
+};
+
 struct pcc_dataset {
 	u32			pccd_rwid;	 /* Archive ID */
 	u32			pccd_roid;	 /* Readonly ID */
 	struct pcc_match_rule	pccd_rule;	 /* Match rule */
-	u32			pccd_rwonly:1, /* Only use as RW-PCC */
-				pccd_roonly:1; /* Only use as RO-PCC */
+	enum pcc_dataset_flags	pccd_flags;	 /* flags of PCC backend */
 	char			pccd_pathname[PATH_MAX]; /* full path */
 	struct path		pccd_path;	 /* Root path */
 	struct list_head	pccd_linkage;  /* Linked to pccs_datasets */
@@ -105,7 +116,7 @@ struct pcc_dataset {
 
 struct pcc_super {
 	/* Protect pccs_datasets */
-	spinlock_t		 pccs_lock;
+	struct rw_semaphore	 pccs_rw_sem;
 	/* List of datasets */
 	struct list_head	 pccs_datasets;
 	/* creds of process who forced instantiation of super block */
@@ -158,6 +169,7 @@ struct pcc_cmd {
 			u32			 pccc_roid;
 			struct list_head	 pccc_conds;
 			char			*pccc_conds_str;
+			enum pcc_dataset_flags	 pccc_flags;
 		} pccc_add;
 		struct pcc_cmd_del {
 			u32			 pccc_pad;
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 27e0ca5..792d946 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -2049,6 +2049,7 @@ static int lov_object_layout_get(const struct lu_env *env,
 	cl->cl_size = lov_comp_md_size(lsm);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
 	cl->cl_dom_comp_size = 0;
+	cl->cl_is_released = lsm->lsm_is_released;
 	if (lsm_is_composite(lsm->lsm_magic)) {
 		struct lov_stripe_md_entry *lsme = lsm->lsm_entries[0];
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index b024a44..2f9687e 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -2104,6 +2104,8 @@ enum lu_pcc_state_flags {
 	PCC_STATE_FL_ATTR_VALID		= 0x01,
 	/* The file is being attached into PCC */
 	PCC_STATE_FL_ATTACHING		= 0x02,
+	/* Allow to auto attach at open */
+	PCC_STATE_FL_OPEN_ATTACH	= 0x04,
 };
 
 struct lu_pcc_state {
-- 
1.8.3.1
