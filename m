From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:24 -0500
Subject: [lustre-devel] [PATCH 156/622] lustre: llite: add lock for dir
 layout data
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-157-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Directory layout data should be accessed with lock, because
directory migration may change it, if it's accessed without lock,
it may cause crash.

Introduce an rw_semaphore 'lli_lsm_sem', any MD operation that uses
directory layout data will take read lock, and ll_update_lsm_md()
will take write lock when setting lsm.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4684
Lustre-commit: ae828cd3b092 ("LU-4684 llite: add lock for dir layout data")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32946
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h   |  16 ++++
 fs/lustre/include/obd.h          |   2 +
 fs/lustre/llite/dir.c            |  29 +++----
 fs/lustre/llite/file.c           |   5 +-
 fs/lustre/llite/llite_internal.h |   3 +
 fs/lustre/llite/llite_lib.c      | 168 ++++++++++++++++++++-------------------
 fs/lustre/llite/namei.c          |   2 +
 fs/lustre/llite/statahead.c      | 137 ++++++++++++++++---------------
 fs/lustre/lmv/lmv_obd.c          |   2 -
 9 files changed, 199 insertions(+), 165 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index ff279e1..1246c25 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -81,6 +81,22 @@ struct lmv_stripe_md {
 	return true;
 }
 
+static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
+{
+	int i;
+
+	CDEBUG(mask,
+	       "magic %#x stripe count %d master mdt %d hash type %#x version %d migrate offset %d migrate hash %#x pool %s\n",
+	       lsm->lsm_md_magic, lsm->lsm_md_stripe_count,
+	       lsm->lsm_md_master_mdt_index, lsm->lsm_md_hash_type,
+	       lsm->lsm_md_layout_version, lsm->lsm_md_migrate_offset,
+	       lsm->lsm_md_migrate_hash, lsm->lsm_md_pool_name);
+
+	for (i = 0; i < lsm->lsm_md_stripe_count; i++)
+		CDEBUG(mask, "stripe[%d] "DFID"\n",
+		       i, PFID(&lsm->lsm_md_oinfo[i].lmo_fid));
+}
+
 union lmv_mds_md;
 
 void lmv_free_memmd(struct lmv_stripe_md *lsm);
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 2587136..4829e11 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -741,6 +741,8 @@ struct md_op_data {
 	s64			op_mod_time;
 	const char	       *op_name;
 	size_t			op_namelen;
+	struct rw_semaphore	*op_mea1_sem;
+	struct rw_semaphore	*op_mea2_sem;
 	struct lmv_stripe_md   *op_mea1;
 	struct lmv_stripe_md   *op_mea2;
 	u32			op_suppgids[2];
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 55a1efb..3da9d14 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -298,6 +298,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	int hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
 	bool api32 = ll_need_32bit_api(sbi);
 	struct md_op_data *op_data;
+	struct lu_fid pfid = { 0 };
 	int rc;
 
 	CDEBUG(D_VFSTRACE,
@@ -313,14 +314,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		goto out;
 	}
 
-	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL, 0, 0,
-				     LUSTRE_OPC_ANY, inode);
-	if (IS_ERR(op_data)) {
-		rc = PTR_ERR(op_data);
-		goto out;
-	}
-
-	if (unlikely(op_data->op_mea1)) {
+	if (unlikely(ll_i2info(inode)->lli_lsm_md)) {
 		/*
 		 * This is only needed for striped dir to fill ..,
 		 * see lmv_read_page
@@ -332,21 +326,28 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 
 			parent = file_dentry(filp)->d_parent->d_inode;
 			if (ll_have_md_lock(parent, &ibits, LCK_MINMODE))
-				op_data->op_fid3 = *ll_inode2fid(parent);
+				pfid = *ll_inode2fid(parent);
 		}
 
 		/*
 		 * If it can not find in cache, do lookup .. on the master
 		 * object
 		 */
-		if (fid_is_zero(&op_data->op_fid3)) {
-			rc = ll_dir_get_parent_fid(inode, &op_data->op_fid3);
-			if (rc) {
-				ll_finish_md_op_data(op_data);
+		if (fid_is_zero(&pfid)) {
+			rc = ll_dir_get_parent_fid(inode, &pfid);
+			if (rc)
 				return rc;
-			}
 		}
 	}
+
+	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, inode);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto out;
+	}
+	op_data->op_fid3 = pfid;
+
 	ctx->pos = pos;
 	rc = ll_dir_read(inode, &pos, op_data, ctx);
 	pos = ctx->pos;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 9de37d2..e1fba1c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4080,12 +4080,15 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 
 static int ll_merge_md_attr(struct inode *inode)
 {
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_attr attr = { 0 };
 	int rc;
 
-	LASSERT(ll_i2info(inode)->lli_lsm_md);
+	LASSERT(lli->lli_lsm_md);
+	down_read(&lli->lli_lsm_sem);
 	rc = md_merge_attr(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
 			   &attr, ll_md_blocking_ast);
+	up_read(&lli->lli_lsm_sem);
 	if (rc)
 		return rc;
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d6fc6a29..d41531b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -168,6 +168,8 @@ struct ll_inode_info {
 			unsigned int			lli_sa_enabled:1;
 			/* generation for statahead */
 			unsigned int			lli_sa_generation;
+			/* rw lock protects lli_lsm_md */
+			struct rw_semaphore		lli_lsm_sem;
 			/* directory stripe information */
 			struct lmv_stripe_md	       *lli_lsm_md;
 			/* default directory stripe offset.  This is extracted
@@ -905,6 +907,7 @@ enum {
 	LUSTRE_OPC_ANY		= 5,
 };
 
+void ll_unlock_md_op_lsm(struct md_op_data *op_data);
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, size_t namelen,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 859fdf4..ed2d1c6 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -933,6 +933,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		lli->lli_opendir_pid = 0;
 		lli->lli_sa_enabled = 0;
 		lli->lli_def_stripe_offset = -1;
+		init_rwsem(&lli->lli_lsm_sem);
 	} else {
 		mutex_init(&lli->lli_size_mutex);
 		lli->lli_symlink_name = NULL;
@@ -1237,10 +1238,17 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct lmv_stripe_md *lsm = md->lmv;
+	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lu_fid *fid;
 	int i;
 
 	LASSERT(lsm);
+
+	CDEBUG(D_INODE, "%s: "DFID" set dir layout:\n",
+		ll_get_fsname(inode->i_sb, NULL, 0),
+		PFID(&lli->lli_fid));
+	lsm_md_dump(D_INODE, lsm);
+
 	/*
 	 * XXX sigh, this lsm_root initialization should be in
 	 * LMV layer, but it needs ll_iget right now, so we
@@ -1260,10 +1268,16 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 			int rc = PTR_ERR(lsm->lsm_md_oinfo[i].lmo_root);
 
 			lsm->lsm_md_oinfo[i].lmo_root = NULL;
+			while (i-- > 0) {
+				iput(lsm->lsm_md_oinfo[i].lmo_root);
+				lsm->lsm_md_oinfo[i].lmo_root = NULL;
+			}
 			return rc;
 		}
 	}
 
+	lli->lli_lsm_md = lsm;
+
 	return 0;
 }
 
@@ -1271,7 +1285,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lmv_stripe_md *lsm = md->lmv;
-	int rc;
+	int rc = 0;
 
 	LASSERT(S_ISDIR(inode->i_mode));
 	CDEBUG(D_INODE, "update lsm %p of " DFID "\n", lli->lli_lsm_md,
@@ -1284,53 +1298,43 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	if (!lsm)
 		return 0;
 
-	/* Compare the old and new stripe information */
+	/*
+	 * normally dir layout doesn't change, only take read lock to check
+	 * that to avoid blocking other MD operations.
+	 */
+	if (lli->lli_lsm_md)
+		down_read(&lli->lli_lsm_sem);
+	else
+		down_write(&lli->lli_lsm_sem);
+
+	/*
+	 * if dir layout mismatch, check whether version is increased, which
+	 * means layout is changed, this happens in dir migration and lfsck.
+	 */
 	if (lli->lli_lsm_md && !lsm_md_eq(lli->lli_lsm_md, lsm)) {
-		struct lmv_stripe_md *old_lsm = lli->lli_lsm_md;
-		bool layout_changed = lsm->lsm_md_layout_version >
-				      old_lsm->lsm_md_layout_version;
-		int mask = layout_changed ? D_INODE : D_ERROR;
-		int idx;
-
-		CDEBUG(mask,
-		       "%s: inode@%p "DFID" lmv layout %s magic %#x/%#x stripe count %d/%d master_mdt %d/%d hash_type %#x/%#x version %d/%d migrate offset %d/%d  migrate hash %#x/%#x pool %s/%s\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0), inode,
-		       PFID(&lli->lli_fid),
-		       layout_changed ? "changed" : "mismatch",
-		       lsm->lsm_md_magic, old_lsm->lsm_md_magic,
-		       lsm->lsm_md_stripe_count,
-		       old_lsm->lsm_md_stripe_count,
-		       lsm->lsm_md_master_mdt_index,
-		       old_lsm->lsm_md_master_mdt_index,
-		       lsm->lsm_md_hash_type, old_lsm->lsm_md_hash_type,
-		       lsm->lsm_md_layout_version,
-		       old_lsm->lsm_md_layout_version,
-		       lsm->lsm_md_migrate_offset,
-		       old_lsm->lsm_md_migrate_offset,
-		       lsm->lsm_md_migrate_hash,
-		       old_lsm->lsm_md_migrate_hash,
-		       lsm->lsm_md_pool_name,
-		       old_lsm->lsm_md_pool_name);
-
-		for (idx = 0; idx < old_lsm->lsm_md_stripe_count; idx++)
-			CDEBUG(mask, "old stripe[%d] "DFID"\n",
-			       idx, PFID(&old_lsm->lsm_md_oinfo[idx].lmo_fid));
-
-		for (idx = 0; idx < lsm->lsm_md_stripe_count; idx++)
-			CDEBUG(mask, "new stripe[%d] "DFID"\n",
-			       idx, PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
-
-		if (!layout_changed)
-			return -EINVAL;
+		if (lsm->lsm_md_layout_version <=
+		    lli->lli_lsm_md->lsm_md_layout_version) {
+			CERROR("%s: " DFID " dir layout mismatch:\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       PFID(&lli->lli_fid));
+			lsm_md_dump(D_ERROR, lli->lli_lsm_md);
+			lsm_md_dump(D_ERROR, lsm);
+			rc = -EINVAL;
+			goto unlock;
+		}
 
+		/* layout changed, switch to write lock */
+		up_read(&lli->lli_lsm_sem);
+		down_write(&lli->lli_lsm_sem);
 		ll_dir_clear_lsm_md(inode);
 	}
 
-	/* set the directory layout */
+	/* set directory layout */
 	if (!lli->lli_lsm_md) {
 		struct cl_attr *attr;
 
 		rc = ll_init_lsm_md(inode, md);
+		up_write(&lli->lli_lsm_sem);
 		if (rc)
 			return rc;
 
@@ -1339,18 +1343,25 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		 * will not free this lsm
 		 */
 		md->lmv = NULL;
-		lli->lli_lsm_md = lsm;
+
+		/*
+		 * md_merge_attr() may take long, since lsm is already set,
+		 * switch to read lock.
+		 */
+		down_read(&lli->lli_lsm_sem);
 
 		attr = kzalloc(sizeof(*attr), GFP_NOFS);
-		if (!attr)
-			return -ENOMEM;
+		if (!attr) {
+			rc = -ENOMEM;
+			goto unlock;
+		}
 
 		/* validate the lsm */
 		rc = md_merge_attr(ll_i2mdexp(inode), lsm, attr,
 				   ll_md_blocking_ast);
 		if (rc) {
 			kfree(attr);
-			return rc;
+			goto unlock;
 		}
 
 		if (md->body->mbo_valid & OBD_MD_FLNLINK)
@@ -1365,47 +1376,11 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 			md->body->mbo_mtime = attr->cat_mtime;
 
 		kfree(attr);
-
-		CDEBUG(D_INODE, "Set lsm %p magic %x to " DFID "\n", lsm,
-		       lsm->lsm_md_magic, PFID(ll_inode2fid(inode)));
-		return 0;
 	}
+unlock:
+	up_read(&lli->lli_lsm_sem);
 
-	/* Compare the old and new stripe information */
-	if (!lsm_md_eq(lli->lli_lsm_md, lsm)) {
-		struct lmv_stripe_md *old_lsm = lli->lli_lsm_md;
-		int idx;
-
-		CERROR("%s: inode " DFID "(%p)'s lmv layout mismatch (%p)/(%p) magic:0x%x/0x%x stripe count: %d/%d master_mdt: %d/%d hash_type:0x%x/0x%x layout: 0x%x/0x%x pool:%s/%s\n",
-		       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid),
-		       inode, lsm, old_lsm,
-		       lsm->lsm_md_magic, old_lsm->lsm_md_magic,
-		       lsm->lsm_md_stripe_count,
-		       old_lsm->lsm_md_stripe_count,
-		       lsm->lsm_md_master_mdt_index,
-		       old_lsm->lsm_md_master_mdt_index,
-		       lsm->lsm_md_hash_type, old_lsm->lsm_md_hash_type,
-		       lsm->lsm_md_layout_version,
-		       old_lsm->lsm_md_layout_version,
-		       lsm->lsm_md_pool_name,
-		       old_lsm->lsm_md_pool_name);
-
-		for (idx = 0; idx < old_lsm->lsm_md_stripe_count; idx++) {
-			CERROR("%s: sub FIDs in old lsm idx %d, old: " DFID "\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
-			       PFID(&old_lsm->lsm_md_oinfo[idx].lmo_fid));
-		}
-
-		for (idx = 0; idx < lsm->lsm_md_stripe_count; idx++) {
-			CERROR("%s: sub FIDs in new lsm idx %d, new: " DFID "\n",
-			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
-			       PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
-		}
-
-		return -EIO;
-	}
-
-	return 0;
+	return rc;
 }
 
 void ll_clear_inode(struct inode *inode)
@@ -2417,6 +2392,23 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 	return rc;
 }
 
+/*
+ * this is normally called in ll_fini_md_op_data(), but sometimes it needs to
+ * be called early to avoid deadlock.
+ */
+void ll_unlock_md_op_lsm(struct md_op_data *op_data)
+{
+	if (op_data->op_mea2_sem) {
+		up_read(op_data->op_mea2_sem);
+		op_data->op_mea2_sem = NULL;
+	}
+
+	if (op_data->op_mea1_sem) {
+		up_read(op_data->op_mea1_sem);
+		op_data->op_mea1_sem = NULL;
+	}
+}
+
 /* this function prepares md_op_data hint for passing ot down to MD stack. */
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
@@ -2444,7 +2436,10 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	ll_i2gids(op_data->op_suppgids, i1, i2);
 	op_data->op_fid1 = *ll_inode2fid(i1);
 	op_data->op_default_stripe_offset = -1;
+
 	if (S_ISDIR(i1->i_mode)) {
+		down_read(&ll_i2info(i1)->lli_lsm_sem);
+		op_data->op_mea1_sem = &ll_i2info(i1)->lli_lsm_sem;
 		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
 		if (opc == LUSTRE_OPC_MKDIR)
 			op_data->op_default_stripe_offset =
@@ -2453,8 +2448,14 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 	if (i2) {
 		op_data->op_fid2 = *ll_inode2fid(i2);
-		if (S_ISDIR(i2->i_mode))
+		if (S_ISDIR(i2->i_mode)) {
+			if (i2 != i1) {
+				down_read(&ll_i2info(i2)->lli_lsm_sem);
+				op_data->op_mea2_sem =
+						&ll_i2info(i2)->lli_lsm_sem;
+			}
 			op_data->op_mea2 = ll_i2info(i2)->lli_lsm_md;
+		}
 	} else {
 		fid_zero(&op_data->op_fid2);
 	}
@@ -2483,6 +2484,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 void ll_finish_md_op_data(struct md_op_data *op_data)
 {
+	ll_unlock_md_op_lsm(op_data);
 	security_release_secctx(op_data->op_file_secctx,
 				op_data->op_file_secctx_size);
 	kfree(op_data);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 530c2df..3e3fbd9 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -777,6 +777,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		goto out;
 	}
 
+	/* dir layout may change */
+	ll_unlock_md_op_lsm(op_data);
 	rc = ll_lookup_it_finish(req, it, parent, &dentry);
 	if (rc != 0) {
 		ll_intent_release(it);
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 122b9d8..1de62b5 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -332,6 +332,58 @@ static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
 	return (index == sai->sai_index_wait);
 }
 
+/* finish async stat RPC arguments */
+static void sa_fini_data(struct md_enqueue_info *minfo)
+{
+	ll_unlock_md_op_lsm(&minfo->mi_data);
+	iput(minfo->mi_dir);
+	kfree(minfo);
+}
+
+static int ll_statahead_interpret(struct ptlrpc_request *req,
+				  struct md_enqueue_info *minfo, int rc);
+
+/*
+ * prepare arguments for async stat RPC.
+ */
+static struct md_enqueue_info *
+sa_prep_data(struct inode *dir, struct inode *child, struct sa_entry *entry)
+{
+	struct md_enqueue_info   *minfo;
+	struct ldlm_enqueue_info *einfo;
+	struct md_op_data        *op_data;
+
+	minfo = kzalloc(sizeof(*minfo), GFP_NOFS);
+	if (!minfo)
+		return ERR_PTR(-ENOMEM);
+
+	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child,
+				     entry->se_qstr.name, entry->se_qstr.len, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data)) {
+		kfree(minfo);
+		return (struct md_enqueue_info *)op_data;
+	}
+
+	if (!child)
+		op_data->op_fid2 = entry->se_fid;
+
+	minfo->mi_it.it_op = IT_GETATTR;
+	minfo->mi_dir = igrab(dir);
+	minfo->mi_cb = ll_statahead_interpret;
+	minfo->mi_cbdata = entry;
+
+	einfo = &minfo->mi_einfo;
+	einfo->ei_type   = LDLM_IBITS;
+	einfo->ei_mode   = it_to_lock_mode(&minfo->mi_it);
+	einfo->ei_cb_bl  = ll_md_blocking_ast;
+	einfo->ei_cb_cp  = ldlm_completion_ast;
+	einfo->ei_cb_gl  = NULL;
+	einfo->ei_cbdata = NULL;
+
+	return minfo;
+}
+
 /*
  * release resources used in async stat RPC, update entry state and wakeup if
  * scanner process it waiting on this entry.
@@ -348,8 +400,7 @@ static void sa_put(struct ll_statahead_info *sai, struct sa_entry *entry,
 	if (minfo) {
 		entry->se_minfo = NULL;
 		ll_intent_release(&minfo->mi_it);
-		iput(minfo->mi_dir);
-		kfree(minfo);
+		sa_fini_data(minfo);
 	}
 
 	if (req) {
@@ -685,17 +736,16 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 
 	if (rc) {
 		ll_intent_release(it);
-		iput(dir);
-		kfree(minfo);
+		sa_fini_data(minfo);
 	} else {
-		/*
-		 * release ibits lock ASAP to avoid deadlock when statahead
+		/* release ibits lock ASAP to avoid deadlock when statahead
 		 * thread enqueues lock on parent in readdir and another
 		 * process enqueues lock on child with parent lock held, eg.
 		 * unlink.
 		 */
 		handle = it->it_lock_handle;
 		ll_intent_drop_lock(it);
+		ll_unlock_md_op_lsm(&minfo->mi_data);
 	}
 
 	spin_lock(&lli->lli_sa_lock);
@@ -729,54 +779,6 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 	return rc;
 }
 
-/* finish async stat RPC arguments */
-static void sa_fini_data(struct md_enqueue_info *minfo)
-{
-	iput(minfo->mi_dir);
-	kfree(minfo);
-}
-
-/**
- * prepare arguments for async stat RPC.
- */
-static struct md_enqueue_info *
-sa_prep_data(struct inode *dir, struct inode *child, struct sa_entry *entry)
-{
-	struct md_enqueue_info *minfo;
-	struct ldlm_enqueue_info *einfo;
-	struct md_op_data *op_data;
-
-	minfo = kzalloc(sizeof(*minfo), GFP_NOFS);
-	if (!minfo)
-		return ERR_PTR(-ENOMEM);
-
-	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child,
-				     entry->se_qstr.name, entry->se_qstr.len, 0,
-				     LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data)) {
-		kfree(minfo);
-		return (struct md_enqueue_info *)op_data;
-	}
-
-	if (!child)
-		op_data->op_fid2 = entry->se_fid;
-
-	minfo->mi_it.it_op = IT_GETATTR;
-	minfo->mi_dir = igrab(dir);
-	minfo->mi_cb = ll_statahead_interpret;
-	minfo->mi_cbdata = entry;
-
-	einfo = &minfo->mi_einfo;
-	einfo->ei_type = LDLM_IBITS;
-	einfo->ei_mode = it_to_lock_mode(&minfo->mi_it);
-	einfo->ei_cb_bl = ll_md_blocking_ast;
-	einfo->ei_cb_cp = ldlm_completion_ast;
-	einfo->ei_cb_gl = NULL;
-	einfo->ei_cbdata = NULL;
-
-	return minfo;
-}
-
 /* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
@@ -818,22 +820,20 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	if (d_mountpoint(dentry))
 		return 1;
 
+	minfo = sa_prep_data(dir, inode, entry);
+	if (IS_ERR(minfo))
+		return PTR_ERR(minfo);
+
 	entry->se_inode = igrab(inode);
 	rc = md_revalidate_lock(ll_i2mdexp(dir), &it, ll_inode2fid(inode),
 				NULL);
 	if (rc == 1) {
 		entry->se_handle = it.it_lock_handle;
 		ll_intent_release(&it);
+		sa_fini_data(minfo);
 		return 1;
 	}
 
-	minfo = sa_prep_data(dir, inode, entry);
-	if (IS_ERR(minfo)) {
-		entry->se_inode = NULL;
-		iput(inode);
-		return PTR_ERR(minfo);
-	}
-
 	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
 	if (rc) {
 		entry->se_inode = NULL;
@@ -982,10 +982,9 @@ static int ll_statahead_thread(void *arg)
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
 
-	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
-				     LUSTRE_OPC_ANY, dir);
-	if (IS_ERR(op_data)) {
-		rc = PTR_ERR(op_data);
+	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
+	if (!op_data) {
+		rc = -ENOMEM;
 		goto out;
 	}
 
@@ -993,8 +992,16 @@ static int ll_statahead_thread(void *arg)
 		struct lu_dirpage *dp;
 		struct lu_dirent *ent;
 
+		op_data = ll_prep_md_op_data(op_data, dir, dir, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, dir);
+		if (IS_ERR(op_data)) {
+			rc = PTR_ERR(op_data);
+			break;
+		}
+
 		sai->sai_in_readpage = 1;
 		page = ll_get_dir_page(dir, op_data, pos);
+		ll_unlock_md_op_lsm(op_data);
 		sai->sai_in_readpage = 0;
 		if (IS_ERR(page)) {
 			rc = PTR_ERR(page);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 81b86a0..e98f33d 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1901,8 +1901,6 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	int rc;
 
 	LASSERT(op_data->op_cli_flags & CLI_MIGRATE);
-	LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID "DFID"\n",
-		 PFID(&op_data->op_fid3));
 
 	CDEBUG(D_INODE, "MIGRATE "DFID"/%.*s\n",
 	       PFID(&op_data->op_fid1), (int)namelen, name);
-- 
1.8.3.1
