From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:48 -0500
Subject: [lustre-devel] [PATCH 360/622] lustre: pcc: security and permission
 for non-root user access
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-361-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

For current PCC, if a file is left on the PCC cache, it may be
accessible to other jobs/users who would not normally be able to
access it. (That is,  they access it directly on the PCC mount via
FID as the local PCC mount is basically just a normal local file
system.)

This patch solves this by restricting access on the PCC side and
just depending on the Lustre side permissions for opening a file.
So PCC files on the local mount fs are created with some minimal
(zero) set of permissions. Then, when accessing a PCC cached
file, we do the permission check on the Lustre file, then do not
do it on the PCC file. This should render the PCC files
inaccessible except to root or via Lustre.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10092
Lustre-commit: 2102c86e0d0a ("LU-10092 pcc: security and permission for non-root user access")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/34637
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      |   3 +-
 fs/lustre/llite/llite_lib.c |  23 +++++++---
 fs/lustre/llite/namei.c     |   2 +-
 fs/lustre/llite/pcc.c       | 103 ++++++++++++++++++++++++++++++++++++++------
 fs/lustre/llite/pcc.h       |  16 ++++---
 5 files changed, 120 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 5a52cad..96311ad 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -860,6 +860,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 		if (rc)
 			goto out_och_free;
 	}
+
 	rc = pcc_file_open(inode, file);
 	if (rc)
 		goto out_och_free;
@@ -1787,7 +1788,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	 * from PCC cache automatically.
 	 */
 	result = pcc_file_write_iter(iocb, from, &cached);
-	if (cached && result != -ENOSPC)
+	if (cached && result != -ENOSPC && result != -EDQUOT)
 		return result;
 
 	/* NB: we can't do direct IO for tiny writes because they use the page
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 1b22062..5ac083c 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -71,11 +71,16 @@ static struct ll_sb_info *ll_init_sbi(void)
 	unsigned long pages;
 	unsigned long lru_page_max;
 	struct sysinfo si;
+	int rc;
 	int i;
 
 	sbi = kzalloc(sizeof(*sbi), GFP_NOFS);
 	if (!sbi)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
+
+	rc = pcc_super_init(&sbi->ll_pcc_super);
+	if (rc < 0)
+		goto out_sbi;
 
 	spin_lock_init(&sbi->ll_lock);
 	mutex_init(&sbi->ll_lco.lco_lock);
@@ -89,8 +94,8 @@ static struct ll_sb_info *ll_init_sbi(void)
 
 	sbi->ll_cache = cl_cache_init(lru_page_max);
 	if (!sbi->ll_cache) {
-		kfree(sbi);
-		return NULL;
+		rc = -ENOMEM;
+		goto out_pcc;
 	}
 
 	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
@@ -128,12 +133,16 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_squash.rsi_gid = 0;
 	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
 	spin_lock_init(&sbi->ll_squash.rsi_lock);
-	pcc_super_init(&sbi->ll_pcc_super);
 
 	/* Per-filesystem file heat */
 	sbi->ll_heat_decay_weight = SBI_DEFAULT_HEAT_DECAY_WEIGHT;
 	sbi->ll_heat_period_second = SBI_DEFAULT_HEAT_PERIOD_SECOND;
 	return sbi;
+out_pcc:
+	pcc_super_fini(&sbi->ll_pcc_super);
+out_sbi:
+	kfree(sbi);
+	return ERR_PTR(rc);
 }
 
 static void ll_free_sbi(struct super_block *sb)
@@ -990,8 +999,8 @@ int ll_fill_super(struct super_block *sb)
 	/* client additional sb info */
 	sbi = ll_init_sbi();
 	lsi->lsi_llsbi = sbi;
-	if (!sbi) {
-		err = -ENOMEM;
+	if (IS_ERR(sbi)) {
+		err = PTR_ERR(sbi);
 		goto out_free;
 	}
 
@@ -1120,7 +1129,7 @@ void ll_put_super(struct super_block *sb)
 	int next, force = 1, rc = 0;
 	long ccc_count;
 
-	if (!sbi)
+	if (IS_ERR(sbi))
 		goto out_no_sbi;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p - %s\n", sb, profilenm);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index d10decb..10c0cef 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -835,7 +835,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			goto out;
 		}
 
-		rc = pcc_inode_create(dataset, &op_data->op_fid2,
+		rc = pcc_inode_create(parent->i_sb, dataset, &op_data->op_fid2,
 				      &pca->pca_dentry);
 		if (rc) {
 			retval = ERR_PTR(rc);
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 8440647..fa81b55 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -113,10 +113,20 @@
 
 struct kmem_cache *pcc_inode_slab;
 
-void pcc_super_init(struct pcc_super *super)
+int pcc_super_init(struct pcc_super *super)
 {
+	struct cred *cred;
+
+	super->pccs_cred = cred = prepare_creds();
+	if (!cred)
+		return -ENOMEM;
+
+	/* Never override disk quota limits or use reserved space */
+	cap_lower(cred->cap_effective, CAP_SYS_RESOURCE);
 	spin_lock_init(&super->pccs_lock);
 	INIT_LIST_HEAD(&super->pccs_datasets);
+
+	return 0;
 }
 
 /**
@@ -251,7 +261,7 @@ struct pcc_dataset *
 	return 0;
 }
 
-void pcc_super_fini(struct pcc_super *super)
+static void pcc_remove_datasets(struct pcc_super *super)
 {
 	struct pcc_dataset *dataset, *tmp;
 
@@ -262,6 +272,12 @@ void pcc_super_fini(struct pcc_super *super)
 	}
 }
 
+void pcc_super_fini(struct pcc_super *super)
+{
+	pcc_remove_datasets(super);
+	put_cred(super->pccs_cred);
+}
+
 static bool pathname_is_valid(const char *pathname)
 {
 	/* Needs to be absolute path */
@@ -380,7 +396,7 @@ int pcc_cmd_handle(char *buffer, unsigned long count,
 		rc = pcc_dataset_del(super, cmd->pccc_pathname);
 		break;
 	case PCC_CLEAR_ALL:
-		pcc_super_fini(super);
+		pcc_remove_datasets(super);
 		break;
 	default:
 		rc = -EINVAL;
@@ -463,6 +479,11 @@ static int pcc_fid2dataset_path(char *buf, int sz, struct lu_fid *fid)
 			PFID(fid));
 }
 
+static inline const struct cred *pcc_super_cred(struct super_block *sb)
+{
+	return ll_s2sbi(sb)->ll_pcc_super.pccs_cred;
+}
+
 void pcc_file_init(struct pcc_file *pccf)
 {
 	pccf->pccf_file = NULL;
@@ -503,7 +524,9 @@ int pcc_file_open(struct inode *inode, struct file *file)
 	dname = &path->dentry->d_name;
 	CDEBUG(D_CACHE, "opening pcc file '%.*s'\n", dname->len,
 	       dname->name);
-	pcc_file = dentry_open(path, file->f_flags, current_cred());
+
+	pcc_file = dentry_open(path, file->f_flags,
+			       pcc_super_cred(inode->i_sb));
 	if (IS_ERR_OR_NULL(pcc_file)) {
 		rc = pcc_file ? PTR_ERR(pcc_file) : -EINVAL;
 		pcc_inode_put(pcci);
@@ -652,6 +675,7 @@ int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
 		      bool *cached)
 {
 	int rc = 0;
+	const struct cred *old_cred;
 	struct iattr attr2 = *attr;
 	struct dentry *pcc_dentry;
 	struct pcc_inode *pcci;
@@ -667,11 +691,13 @@ int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
 
 	attr2.ia_valid = attr->ia_valid & (ATTR_SIZE | ATTR_ATIME |
 			 ATTR_ATIME_SET | ATTR_MTIME | ATTR_MTIME_SET |
-			 ATTR_CTIME);
+			 ATTR_CTIME | ATTR_UID | ATTR_GID);
 	pcci = ll_i2pcci(inode);
 	pcc_dentry = pcci->pcci_path.dentry;
 	inode_lock(pcc_dentry->d_inode);
+	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	rc = pcc_dentry->d_inode->i_op->setattr(pcc_dentry, &attr2);
+	revert_creds(old_cred);
 	inode_unlock(pcc_dentry->d_inode);
 
 	pcc_io_fini(inode);
@@ -681,6 +707,7 @@ int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
 int pcc_inode_getattr(struct inode *inode, bool *cached)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
+	const struct cred *old_cred;
 	struct kstat stat;
 	s64 atime;
 	s64 mtime;
@@ -696,8 +723,10 @@ int pcc_inode_getattr(struct inode *inode, bool *cached)
 	if (!*cached)
 		return 0;
 
+	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	rc = vfs_getattr(&ll_i2pcci(inode)->pcci_path, &stat,
 			 STATX_BASIC_STATS, AT_STATX_SYNC_AS_STAT);
+	revert_creds(old_cred);
 	if (rc)
 		goto out;
 
@@ -1113,14 +1142,14 @@ static int __pcc_inode_create(struct pcc_dataset *dataset,
 
 	pcc_fid2dataset_path(path, MAX_PCC_DATABASE_PATH, fid);
 
-	base = pcc_mkdir_p(dataset->pccd_path.dentry, path, 0700);
+	base = pcc_mkdir_p(dataset->pccd_path.dentry, path, 0);
 	if (IS_ERR(base)) {
 		rc = PTR_ERR(base);
 		goto out;
 	}
 
 	snprintf(path, MAX_PCC_DATABASE_PATH, DFID_NOBRACE, PFID(fid));
-	child = pcc_create(base, path, 0600);
+	child = pcc_create(base, path, 0);
 	if (IS_ERR(child)) {
 		rc = PTR_ERR(child);
 		goto out_base;
@@ -1134,18 +1163,44 @@ static int __pcc_inode_create(struct pcc_dataset *dataset,
 	return rc;
 }
 
-int pcc_inode_create(struct pcc_dataset *dataset, struct lu_fid *fid,
-		     struct dentry **pcc_dentry)
+/* TODO: Set the project ID for PCC copy */
+int pcc_inode_store_ugpid(struct dentry *dentry, kuid_t uid, kgid_t gid)
+{
+	struct inode *inode = dentry->d_inode;
+	struct iattr attr;
+	int rc;
+
+	attr.ia_valid = ATTR_UID | ATTR_GID;
+	attr.ia_uid = uid;
+	attr.ia_gid = gid;
+
+	inode_lock(inode);
+	rc = notify_change(dentry, &attr, NULL);
+	inode_unlock(inode);
+
+	return rc;
+}
+
+int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
+		     struct lu_fid *fid, struct dentry **pcc_dentry)
 {
-	return __pcc_inode_create(dataset, fid, pcc_dentry);
+	const struct cred *old_cred;
+	int rc;
+
+	old_cred = override_creds(pcc_super_cred(sb));
+	rc = __pcc_inode_create(dataset, fid, pcc_dentry);
+	revert_creds(old_cred);
+	return rc;
 }
 
 int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 			  struct dentry *pcc_dentry)
 {
+	const struct cred *old_cred;
 	struct pcc_inode *pcci;
 	int rc = 0;
 
+	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	pcc_inode_lock(inode);
 	LASSERT(!ll_i2pcci(inode));
 	pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
@@ -1154,6 +1209,11 @@ int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 		goto out_unlock;
 	}
 
+	rc = pcc_inode_store_ugpid(pcc_dentry, old_cred->suid,
+				   old_cred->sgid);
+	if (rc)
+		goto out_unlock;
+
 	pcc_inode_init(pcci, ll_i2info(inode));
 	pcc_inode_attach_init(dataset, pcci, pcc_dentry, LU_PCC_READWRITE);
 	/* Set the layout generation of newly created file with 0 */
@@ -1172,6 +1232,10 @@ int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 	}
 
 	pcc_inode_unlock(inode);
+	revert_creds(old_cred);
+	if (rc)
+		kmem_cache_free(pcc_inode_slab, pcci);
+
 	return rc;
 }
 
@@ -1253,6 +1317,7 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	struct pcc_dataset *dataset;
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct pcc_inode *pcci;
+	const struct cred *old_cred;
 	struct dentry *dentry;
 	struct file *pcc_filp;
 	struct path path;
@@ -1267,9 +1332,12 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	if (!dataset)
 		return -ENOENT;
 
+	old_cred = override_creds(pcc_super_cred(inode->i_sb));
 	rc = __pcc_inode_create(dataset, &lli->lli_fid, &dentry);
-	if (rc)
+	if (rc) {
+		revert_creds(old_cred);
 		goto out_dataset_put;
+	}
 
 	path.mnt = dataset->pccd_path.mnt;
 	path.dentry = dentry;
@@ -1277,9 +1345,15 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 			       current_cred());
 	if (IS_ERR_OR_NULL(pcc_filp)) {
 		rc = pcc_filp ? PTR_ERR(pcc_filp) : -EINVAL;
+		revert_creds(old_cred);
 		goto out_dentry;
 	}
 
+	rc = pcc_inode_store_ugpid(dentry, old_cred->uid, old_cred->gid);
+	revert_creds(old_cred);
+	if (rc)
+		goto out_fput;
+
 	rc = pcc_copy_data(file, pcc_filp);
 	if (rc)
 		goto out_fput;
@@ -1306,7 +1380,9 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	if (rc) {
 		int rc2;
 
+		old_cred = override_creds(pcc_super_cred(inode->i_sb));
 		rc2 = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
+		revert_creds(old_cred);
 		if (rc2)
 			CWARN("failed to unlink PCC file, rc = %d\n", rc2);
 
@@ -1322,13 +1398,14 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 			      bool attached)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
+	const struct cred *old_cred;
 	struct pcc_inode *pcci;
 	u32 gen2;
 
 	pcc_inode_lock(inode);
 	pcci = ll_i2pcci(inode);
 	lli->lli_pcc_state &= ~PCC_STATE_FL_ATTACHING;
-	if ((rc || lease_broken)) {
+	if (rc || lease_broken) {
 		if (attached && pcci)
 			pcc_inode_put(pcci);
 
@@ -1357,7 +1434,9 @@ int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
 
 out_put:
 	if (rc) {
+		old_cred = override_creds(pcc_super_cred(inode->i_sb));
 		pcc_inode_remove(pcci);
+		revert_creds(old_cred);
 		pcc_inode_put(pcci);
 	}
 out_unlock:
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index 1a73dbb..54492c9 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -53,8 +53,12 @@ struct pcc_dataset {
 };
 
 struct pcc_super {
-	spinlock_t		pccs_lock;	/* Protect pccs_datasets */
-	struct list_head	pccs_datasets;	/* List of datasets */
+	/* Protect pccs_datasets */
+	spinlock_t		 pccs_lock;
+	/* List of datasets */
+	struct list_head	 pccs_datasets;
+	/* creds of process who forced instantiation of super block */
+	const struct cred	*pccs_cred;
 };
 
 struct pcc_inode {
@@ -108,7 +112,7 @@ struct pcc_cmd {
 	} u;
 };
 
-void pcc_super_init(struct pcc_super *super);
+int pcc_super_init(struct pcc_super *super);
 void pcc_super_fini(struct pcc_super *super);
 int pcc_cmd_handle(char *buffer, unsigned long count,
 		   struct pcc_super *super);
@@ -141,10 +145,10 @@ int pcc_fsync(struct file *file, loff_t start, loff_t end,
 int pcc_fault(struct vm_area_struct *mva, struct vm_fault *vmf, bool *cached);
 int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		     bool *cached);
-int pcc_inode_create(struct pcc_dataset *dataset, struct lu_fid *fid,
-		     struct dentry **pcc_dentry);
+int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
+		     struct lu_fid *fid, struct dentry **pcc_dentry);
 int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
-			  struct dentry *pcc_dentry);
+			   struct dentry *pcc_dentry);
 struct pcc_dataset *pcc_dataset_get(struct pcc_super *super, u32 projid,
 				    u32 archive_id);
 void pcc_dataset_put(struct pcc_dataset *dataset);
-- 
1.8.3.1
