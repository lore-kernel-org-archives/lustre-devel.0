From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:34 -0500
Subject: [lustre-devel] [PATCH 526/622] lustre: pcc: auto attach not work
 after client cache clear
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-527-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

When the inode of a PCC cached file in unused state was evicted
from icache due to memory pressure or manual icache cleanup (i.e.
"echo 3 > /proc/sys/vm/drop_caches"), this file will be detached
from PCC also, and all PCC state for this file is cleared.
In the current design, PCC only tries to auto attache the file
once attached into PCC according to the in-memery PCC state. Thus
later IO for the file is not directed to PCC and will trigger the
data restore.

If this is a not desired result for the user, then we need to try
to auto attach file that was never attached into PCC or once
attached but detached as a result of shrinking its inode from
icache.

Although the candidates to try auto attach are increased, but only
the file in HSM released state (which can directly get from file
layout) will be checked.

This bug is easy reproduced on rhel8. It seems that the command
"echo 3 > /proc/sys/vm/drop_caches" will drop all unused inodes
from icache, but it is not true for rhel7.

This patch also adds the check for the input parameter @rwid,
which should be non zero value and same as the archive ID.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13030
Lustre-commit: a5ef2d6e068e ("LU-13030 pcc: auto attach not work after client cache clear")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/36892
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h        |  27 ++++-
 fs/lustre/llite/llite_lib.c             |   2 +
 fs/lustre/llite/pcc.c                   | 194 ++++++++++++++++++++++++++------
 fs/lustre/llite/pcc.h                   |  26 +++--
 include/uapi/linux/lustre/lustre_user.h |  10 --
 5 files changed, 204 insertions(+), 55 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 205ea50..8e7b949 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -206,7 +206,22 @@ struct ll_inode_info {
 
 			struct mutex		 lli_pcc_lock;
 			enum lu_pcc_state_flags	 lli_pcc_state;
-			struct pcc_inode	*lli_pcc_inode;
+			/*
+			 * @lli_pcc_generation saves the gobal PCC generation
+			 * when the file was successfully attached into PCC.
+			 * The flags of the PCC dataset are saved in
+			 * @lli_pcc_dsflags.
+			 * The gobal PCC generation will be increased when add
+			 * or delete a PCC backend, or change the configuration
+			 * parameters for PCC.
+			 * If @lli_pcc_generation is same as the gobal PCC
+			 * generation, we can use the saved flags of the PCC
+			 * dataset to determine whether need to try auto attach
+			 * safely.
+			 */
+			u64				lli_pcc_generation;
+			enum pcc_dataset_flags		lli_pcc_dsflags;
+			struct pcc_inode		*lli_pcc_inode;
 			struct mutex			lli_group_mutex;
 			u64				lli_group_users;
 			unsigned long			lli_group_gid;
@@ -1432,4 +1447,14 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 u64 cl_fid_build_ino(const struct lu_fid *fid, bool api32);
 u32 cl_fid_build_gen(const struct lu_fid *fid);
 
+static inline struct pcc_super *ll_i2pccs(struct inode *inode)
+{
+	return &ll_i2sbi(inode)->ll_pcc_super;
+}
+
+static inline struct pcc_super *ll_info2pccs(struct ll_inode_info *lli)
+{
+	return ll_i2pccs(ll_info2i(lli));
+}
+
 #endif /* LLITE_INTERNAL_H */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 1245336..c2baf6a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -983,6 +983,8 @@ void ll_lli_init(struct ll_inode_info *lli)
 		mutex_init(&lli->lli_pcc_lock);
 		lli->lli_pcc_state = PCC_STATE_FL_NONE;
 		lli->lli_pcc_inode = NULL;
+		lli->lli_pcc_dsflags = PCC_DATASET_NONE;
+		lli->lli_pcc_generation = 0;
 		mutex_init(&lli->lli_group_mutex);
 		lli->lli_group_users = 0;
 		lli->lli_group_gid = 0;
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 550045b..a0e31c8 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -126,6 +126,7 @@ int pcc_super_init(struct pcc_super *super)
 	cap_lower(cred->cap_effective, CAP_SYS_RESOURCE);
 	init_rwsem(&super->pccs_rw_sem);
 	INIT_LIST_HEAD(&super->pccs_datasets);
+	super->pccs_generation = 1;
 
 	return 0;
 }
@@ -553,6 +554,12 @@ static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
 		 */
 		if ((cmd->u.pccc_add.pccc_flags & PCC_DATASET_PCC_ALL) == 0)
 			cmd->u.pccc_add.pccc_flags |= PCC_DATASET_PCC_ALL;
+
+		/* For RW-PCC, the value of @rwid must be non zero. */
+		if (cmd->u.pccc_add.pccc_flags & PCC_DATASET_RWPCC &&
+		    cmd->u.pccc_add.pccc_rwid == 0)
+			return -EINVAL;
+
 		break;
 	case PCC_DEL_DATASET:
 	case PCC_CLEAR_ALL:
@@ -840,6 +847,7 @@ struct pcc_dataset *
 		if (strcmp(dataset->pccd_pathname, pathname) == 0) {
 			list_del_init(&dataset->pccd_linkage);
 			pcc_dataset_put(dataset);
+			super->pccs_generation++;
 			rc = 0;
 			break;
 		}
@@ -880,6 +888,7 @@ static void pcc_remove_datasets(struct pcc_super *super)
 		list_del(&dataset->pccd_linkage);
 		pcc_dataset_put(dataset);
 	}
+	super->pccs_generation++;
 	up_write(&super->pccs_rw_sem);
 }
 
@@ -1101,9 +1110,15 @@ void pcc_file_init(struct pcc_file *pccf)
 	pccf->pccf_type = LU_PCC_NONE;
 }
 
-static inline bool pcc_auto_attach_enabled(struct pcc_dataset *dataset)
+static inline bool pcc_auto_attach_enabled(enum pcc_dataset_flags flags,
+					   enum pcc_io_type iot)
 {
-	return dataset->pccd_flags & PCC_DATASET_AUTO_ATTACH;
+	if (iot == PIT_OPEN)
+		return flags & PCC_DATASET_OPEN_ATTACH;
+	if (iot == PIT_GETATTR)
+		return flags & PCC_DATASET_STAT_ATTACH;
+	else
+		return flags & PCC_DATASET_AUTO_ATTACH;
 }
 
 static const char pcc_xattr_layout[] = XATTR_USER_PREFIX "PCC.layout";
@@ -1114,7 +1129,7 @@ static int pcc_layout_xattr_set(struct pcc_inode *pcci, u32 gen)
 	struct ll_inode_info *lli = pcci->pcci_lli;
 	int rc;
 
-	if (!(lli->lli_pcc_state & PCC_STATE_FL_AUTO_ATTACH))
+	if (!(lli->lli_pcc_dsflags & PCC_DATASET_AUTO_ATTACH))
 		return 0;
 
 	rc = __vfs_setxattr(pcc_dentry, pcc_dentry->d_inode, pcc_xattr_layout,
@@ -1166,21 +1181,33 @@ static void pcc_inode_attach_init(struct pcc_dataset *dataset,
 				  struct dentry *dentry,
 				  enum lu_pcc_type type)
 {
-	struct ll_inode_info *lli = pcci->pcci_lli;
-
 	pcci->pcci_path.mnt = mntget(dataset->pccd_path.mnt);
 	pcci->pcci_path.dentry = dentry;
 	LASSERT(atomic_read(&pcci->pcci_refcount) == 0);
 	atomic_set(&pcci->pcci_refcount, 1);
 	pcci->pcci_type = type;
 	pcci->pcci_attr_valid = false;
+}
 
-	if (dataset->pccd_flags & PCC_DATASET_OPEN_ATTACH)
-		lli->lli_pcc_state |= PCC_STATE_FL_OPEN_ATTACH;
-	if (dataset->pccd_flags & PCC_DATASET_IO_ATTACH)
-		lli->lli_pcc_state |= PCC_STATE_FL_IO_ATTACH;
-	if (dataset->pccd_flags & PCC_DATASET_STAT_ATTACH)
-		lli->lli_pcc_state |= PCC_STATE_FL_STAT_ATTACH;
+static inline void pcc_inode_dsflags_set(struct ll_inode_info *lli,
+					 struct pcc_dataset *dataset)
+{
+	lli->lli_pcc_generation = ll_info2pccs(lli)->pccs_generation;
+	lli->lli_pcc_dsflags = dataset->pccd_flags;
+}
+
+static void pcc_inode_attach_set(struct pcc_super *super,
+				 struct pcc_dataset *dataset,
+				 struct ll_inode_info *lli,
+				 struct pcc_inode *pcci,
+				 struct dentry *dentry,
+				 enum lu_pcc_type type)
+{
+	pcc_inode_init(pcci, lli);
+	pcc_inode_attach_init(dataset, pcci, dentry, type);
+	down_read(&super->pccs_rw_sem);
+	pcc_inode_dsflags_set(lli, dataset);
+	up_read(&super->pccs_rw_sem);
 }
 
 static inline void pcc_layout_gen_set(struct pcc_inode *pcci,
@@ -1263,6 +1290,7 @@ static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 			pcc_inode_get(pcci);
 			pcci->pcci_type = type;
 		}
+		pcc_inode_dsflags_set(lli, dataset);
 		pcc_layout_gen_set(pcci, gen);
 		*cached = true;
 	}
@@ -1274,28 +1302,83 @@ static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 	return rc;
 }
 
-static int pcc_try_datasets_attach(struct inode *inode, u32 gen,
-				   enum lu_pcc_type type, bool *cached)
+static int pcc_try_datasets_attach(struct inode *inode, enum pcc_io_type iot,
+				   u32 gen, enum lu_pcc_type type,
+				   bool *cached)
 {
-	struct pcc_dataset *dataset, *tmp;
 	struct pcc_super *super = &ll_i2sbi(inode)->ll_pcc_super;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_dataset *dataset = NULL, *tmp;
 	int rc = 0;
 
 	down_read(&super->pccs_rw_sem);
 	list_for_each_entry_safe(dataset, tmp,
 				 &super->pccs_datasets, pccd_linkage) {
-		if (!pcc_auto_attach_enabled(dataset))
-			continue;
+		if (!pcc_auto_attach_enabled(dataset->pccd_flags, iot))
+			break;
+
 		rc = pcc_try_dataset_attach(inode, gen, type, dataset, cached);
 		if (rc < 0 || (!rc && *cached))
 			break;
 	}
+
+	/*
+	 * Update the saved dataset flags for the inode accordingly if failed.
+	 */
+	if (!rc && !*cached) {
+		/*
+		 * Currently auto attach strategy for a PCC backend is
+		 * unchangeable once once it was added into the PCC datasets on
+		 * a client as the support to change auto attach strategy is
+		 * not implemented yet.
+		 */
+		/*
+		 * If tried to attach from one PCC backend:
+		 * @lli_pcc_generation > 0:
+		 * 1) The file was once attached into PCC, but now the
+		 * corresponding PCC backend should be removed from the client;
+		 * 2) The layout generation was changed, the data has been
+		 * restored;
+		 * 3) The corresponding PCC copy is not existed on PCC
+		 * @lli_pcc_generation == 0:
+		 * The file is never attached into PCC but in a HSM released
+		 * state, or once attached into PCC but the inode was evicted
+		 * from icache later.
+		 * Set the saved dataset flags with PCC_DATASET_NONE. Then this
+		 * file will skip from the candidates to try auto attach until
+		 * the file is attached ninto PCC again.
+		 *
+		 * If the file was never attached into PCC, or once attached but
+		 * its inode was evicted from icache (lli_pcc_generation == 0),
+		 * set the saved dataset flags with PCC_DATASET_NONE.
+		 *
+		 * If the file was once attached into PCC but the corresponding
+		 * dataset was removed from the client, set the saved dataset
+		 * flags with PCC_DATASET_NONE.
+		 *
+		 * TODO: If the file was once attached into PCC but not try to
+		 * auto attach due to the change of the configuration parameters
+		 * for this dataset (i.e. change from auto attach enabled to
+		 * auto attach disabled for this dataset), update the saved
+		 * dataset flags witha the found one.
+		 */
+		lli->lli_pcc_dsflags = PCC_DATASET_NONE;
+	}
 	up_read(&super->pccs_rw_sem);
 
 	return rc;
 }
 
-static int pcc_try_auto_attach(struct inode *inode, bool *cached, bool is_open)
+/*
+ * TODO: For RW-PCC, it is desirable to store HSM info as a layout (LU-10606).
+ * Thus the client can get archive ID from the layout directly. When try to
+ * attach the file automatically which is in HSM released state (according to
+ * LOV_PATTERN_F_RELEASED in the layout), it can determine whether the file is
+ * valid cached on PCC more precisely according to the @rwid (archive ID) in
+ * the PCC dataset and the archive ID in HSM attrs.
+ */
+static int pcc_try_auto_attach(struct inode *inode, bool *cached,
+			       enum pcc_io_type iot)
 {
 	struct pcc_super *super = &ll_i2sbi(inode)->ll_pcc_super;
 	struct cl_layout clt = {
@@ -1317,7 +1400,7 @@ static int pcc_try_auto_attach(struct inode *inode, bool *cached, bool is_open)
 	 * obtain valid layout lock from MDT (i.e. the file is being
 	 * HSM restoring).
 	 */
-	if (is_open) {
+	if (iot == PIT_OPEN) {
 		if (ll_layout_version_get(lli) == CL_LAYOUT_GEN_NONE)
 			return 0;
 	} else {
@@ -1330,19 +1413,54 @@ static int pcc_try_auto_attach(struct inode *inode, bool *cached, bool is_open)
 	if (rc)
 		return rc;
 
-	if (!is_open && gen != clt.cl_layout_gen) {
+	if (iot != PIT_OPEN && gen != clt.cl_layout_gen) {
 		CDEBUG(D_CACHE, DFID" layout changed from %d to %d.\n",
 		       PFID(ll_inode2fid(inode)), gen, clt.cl_layout_gen);
 		return -EINVAL;
 	}
 
 	if (clt.cl_is_released)
-		rc = pcc_try_datasets_attach(inode, clt.cl_layout_gen,
+		rc = pcc_try_datasets_attach(inode, iot, clt.cl_layout_gen,
 					     LU_PCC_READWRITE, cached);
 
 	return rc;
 }
 
+static inline bool pcc_may_auto_attach(struct inode *inode,
+				       enum pcc_io_type iot)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_super *super = ll_i2pccs(inode);
+
+	/* Known the file was not in any PCC backend. */
+	if (lli->lli_pcc_dsflags & PCC_DATASET_NONE)
+		return false;
+
+	/*
+	 * lli_pcc_generation = 0 means that the file was never attached into
+	 * PCC, or may be once attached into PCC but detached as the inode is
+	 * evicted from icache (i.e. "echo 3 > /proc/sys/vm/drop_caches" or
+	 * icache shrinking due to the memory pressure), which will cause the
+	 * file detach from PCC when releasing the inode from icache.
+	 * In either case, we still try to attach.
+	 */
+	/* lli_pcc_generation == 0, or the PCC setting was changed,
+	 * or there is no PCC setup on the client and the try will return
+	 * immediately in pcc_try_auto_attch().
+	 */
+	if (super->pccs_generation != lli->lli_pcc_generation)
+		return true;
+
+	/* The cached setting @lli_pcc_dsflags is valid */
+	if (iot == PIT_OPEN)
+		return lli->lli_pcc_dsflags & PCC_DATASET_OPEN_ATTACH;
+
+	if (iot == PIT_GETATTR)
+		return lli->lli_pcc_dsflags & PCC_DATASET_STAT_ATTACH;
+
+	return lli->lli_pcc_dsflags & PCC_DATASET_IO_ATTACH;
+}
+
 int pcc_file_open(struct inode *inode, struct file *file)
 {
 	struct pcc_inode *pcci;
@@ -1365,8 +1483,8 @@ int pcc_file_open(struct inode *inode, struct file *file)
 		goto out_unlock;
 
 	if (!pcci || !pcc_inode_has_layout(pcci)) {
-		if (lli->lli_pcc_state & PCC_STATE_FL_OPEN_ATTACH)
-			rc = pcc_try_auto_attach(inode, &cached, true);
+		if (pcc_may_auto_attach(inode, PIT_OPEN))
+			rc = pcc_try_auto_attach(inode, &cached, PIT_OPEN);
 
 		if (rc < 0 || !cached)
 			goto out_unlock;
@@ -1429,7 +1547,6 @@ void pcc_file_release(struct inode *inode, struct file *file)
 
 static void pcc_io_init(struct inode *inode, enum pcc_io_type iot, bool *cached)
 {
-	struct ll_inode_info *lli = ll_i2info(inode);
 	struct pcc_inode *pcci;
 
 	pcc_inode_lock(inode);
@@ -1440,11 +1557,8 @@ static void pcc_io_init(struct inode *inode, enum pcc_io_type iot, bool *cached)
 		*cached = true;
 	} else {
 		*cached = false;
-		if ((lli->lli_pcc_state & PCC_STATE_FL_IO_ATTACH &&
-		     iot != PIT_GETATTR) ||
-		    (iot == PIT_GETATTR &&
-		     lli->lli_pcc_state & PCC_STATE_FL_STAT_ATTACH)) {
-			(void) pcc_try_auto_attach(inode, cached, false);
+		if (pcc_may_auto_attach(inode, iot)) {
+			(void) pcc_try_auto_attach(inode, cached, iot);
 			if (*cached) {
 				pcci = ll_i2pcci(inode);
 				LASSERT(atomic_read(&pcci->pcci_refcount) > 0);
@@ -2061,6 +2175,7 @@ int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
 int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca)
 {
 	struct dentry *pcc_dentry = pca->pca_dentry;
+	struct pcc_super *super = ll_i2pccs(inode);
 	const struct cred *old_cred;
 	struct pcc_inode *pcci;
 	int rc = 0;
@@ -2073,7 +2188,7 @@ int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca)
 
 	LASSERT(pcc_dentry);
 
-	old_cred = override_creds(pcc_super_cred(inode->i_sb));
+	old_cred = override_creds(super->pccs_cred);
 	pcc_inode_lock(inode);
 	LASSERT(!ll_i2pcci(inode));
 	pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
@@ -2087,9 +2202,8 @@ int pcc_inode_create_fini(struct inode *inode, struct pcc_create_attach *pca)
 	if (rc)
 		goto out_put;
 
-	pcc_inode_init(pcci, ll_i2info(inode));
-	pcc_inode_attach_init(pca->pca_dataset, pcci, pcc_dentry,
-			      LU_PCC_READWRITE);
+	pcc_inode_attach_set(super, pca->pca_dataset, ll_i2info(inode),
+			     pcci, pcc_dentry, LU_PCC_READWRITE);
 
 	rc = pcc_layout_xattr_set(pcci, 0);
 	if (rc) {
@@ -2224,6 +2338,7 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 {
 	struct pcc_dataset *dataset;
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_super *super = ll_i2pccs(inode);
 	struct pcc_inode *pcci;
 	const struct cred *old_cred;
 	struct dentry *dentry;
@@ -2241,7 +2356,7 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	if (!dataset)
 		return -ENOENT;
 
-	old_cred = override_creds(pcc_super_cred(inode->i_sb));
+	old_cred = override_creds(super->pccs_cred);
 	rc = __pcc_inode_create(dataset, &lli->lli_fid, &dentry);
 	if (rc)
 		goto out_dataset_put;
@@ -2287,8 +2402,8 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 		goto out_unlock;
 	}
 
-	pcc_inode_init(pcci, lli);
-	pcc_inode_attach_init(dataset, pcci, dentry, LU_PCC_READWRITE);
+	pcc_inode_attach_set(super, dataset, lli, pcci,
+			     dentry, LU_PCC_READWRITE);
 out_unlock:
 	pcc_inode_unlock(inode);
 out_fput:
@@ -2417,8 +2532,15 @@ int pcc_ioctl_detach(struct inode *inode, u32 opt)
 	LASSERT(atomic_read(&pcci->pcci_refcount) > 0);
 
 	if (pcci->pcci_type == LU_PCC_READWRITE) {
-		if (opt == PCC_DETACH_OPT_UNCACHE)
+		if (opt == PCC_DETACH_OPT_UNCACHE) {
 			hsm_remove = true;
+			/*
+			 * The file will be removed from PCC, set the flags
+			 * with PCC_DATASET_NONE even the later removal of the
+			 * PCC copy fails.
+			 */
+			lli->lli_pcc_dsflags = PCC_DATASET_NONE;
+		}
 
 		__pcc_layout_invalidate(pcci);
 		pcc_inode_put(pcci);
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index ec2e421..60f9bea 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -92,20 +92,22 @@ struct pcc_matcher {
 };
 
 enum pcc_dataset_flags {
-	PCC_DATASET_NONE	= 0x0,
+	PCC_DATASET_INVALID	= 0x0,
+	/* Indicate that known the file is not in PCC. */
+	PCC_DATASET_NONE	= 0x1,
 	/* Try auto attach at open, enabled by default */
-	PCC_DATASET_OPEN_ATTACH	= 0x01,
+	PCC_DATASET_OPEN_ATTACH	= 0x02,
 	/* Try auto attach during IO when layout refresh, enabled by default */
-	PCC_DATASET_IO_ATTACH	= 0x02,
+	PCC_DATASET_IO_ATTACH	= 0x04,
 	/* Try auto attach at stat */
-	PCC_DATASET_STAT_ATTACH	= 0x04,
+	PCC_DATASET_STAT_ATTACH	= 0x08,
 	PCC_DATASET_AUTO_ATTACH	= PCC_DATASET_OPEN_ATTACH |
 				  PCC_DATASET_IO_ATTACH |
 				  PCC_DATASET_STAT_ATTACH,
 	/* PCC backend is only used for RW-PCC */
-	PCC_DATASET_RWPCC	= 0x08,
+	PCC_DATASET_RWPCC	= 0x10,
 	/* PCC backend is only used for RO-PCC */
-	PCC_DATASET_ROPCC	= 0x10,
+	PCC_DATASET_ROPCC	= 0x20,
 	/* PCC backend provides caching services for both RW-PCC and RO-PCC */
 	PCC_DATASET_PCC_ALL	= PCC_DATASET_RWPCC | PCC_DATASET_ROPCC,
 };
@@ -114,7 +116,7 @@ struct pcc_dataset {
 	u32			pccd_rwid;	 /* Archive ID */
 	u32			pccd_roid;	 /* Readonly ID */
 	struct pcc_match_rule	pccd_rule;	 /* Match rule */
-	enum pcc_dataset_flags	pccd_flags;	 /* flags of PCC backend */
+	enum pcc_dataset_flags	pccd_flags;	 /* Flags of PCC backend */
 	char			pccd_pathname[PATH_MAX]; /* full path */
 	struct path		pccd_path;	 /* Root path */
 	struct list_head	pccd_linkage;  /* Linked to pccs_datasets */
@@ -128,6 +130,12 @@ struct pcc_super {
 	struct list_head	 pccs_datasets;
 	/* creds of process who forced instantiation of super block */
 	const struct cred	*pccs_cred;
+	/*
+	 * Gobal PCC Generation: it will be increased once the configuration
+	 * for PCC is changed, i.e. add or delete a PCC backend, modify the
+	 * parameters for PCC.
+	 */
+	u64			pccs_generation;
 };
 
 struct pcc_inode {
@@ -177,7 +185,9 @@ enum pcc_io_type {
 	/* fsync system call handling */
 	PIT_FSYNC,
 	/* splice_read system call */
-	PIT_SPLICE_READ
+	PIT_SPLICE_READ,
+	/* open system call */
+	PIT_OPEN,
 };
 
 enum pcc_cmd_type {
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index b46f52b..12b1f78 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -2180,16 +2180,6 @@ enum lu_pcc_state_flags {
 	PCC_STATE_FL_ATTR_VALID		= 0x01,
 	/* The file is being attached into PCC */
 	PCC_STATE_FL_ATTACHING		= 0x02,
-	/* Allow to auto attach at open */
-	PCC_STATE_FL_OPEN_ATTACH	= 0x04,
-	/* Allow to auto attach during I/O after layout lock revocation */
-	PCC_STATE_FL_IO_ATTACH		= 0x08,
-	/* Allow to auto attach at stat */
-	PCC_STATE_FL_STAT_ATTACH	= 0x10,
-	/* Allow to auto attach at the next open or layout refresh */
-	PCC_STATE_FL_AUTO_ATTACH	= PCC_STATE_FL_OPEN_ATTACH |
-					  PCC_STATE_FL_IO_ATTACH |
-					  PCC_STATE_FL_STAT_ATTACH,
 };
 
 struct lu_pcc_state {
-- 
1.8.3.1
