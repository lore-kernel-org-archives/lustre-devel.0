From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:02 -0500
Subject: [lustre-devel] [PATCH 314/622] lustre: lmv: mkdir with balanced
 space usage
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-315-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

If a plain directory default LMV hash type is "space", create
subdirs on all MDTs with balanced space usage:
* client mkdir allocate FID on MDT with balanced space usage
  (space QoS code is in next patch).
* MDT allows mkdir on different MDT with its parent if it has
  "space" hash type in default LMV, this is normally rejected
  because mkdir shouldn't create remote directory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: 6d296587441d ("LU-11213 lmv: mkdir with balanced space usage")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34360
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h   |  51 +++++--
 fs/lustre/llite/dir.c            |   5 +-
 fs/lustre/llite/file.c           |  10 +-
 fs/lustre/llite/llite_internal.h |   7 +
 fs/lustre/llite/llite_lib.c      |  25 ++--
 fs/lustre/llite/namei.c          |   8 +-
 fs/lustre/lmv/lmv_intent.c       |  21 ++-
 fs/lustre/lmv/lmv_internal.h     |  30 +---
 fs/lustre/lmv/lmv_obd.c          | 299 +++++++++++++++++++--------------------
 9 files changed, 229 insertions(+), 227 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index c88e4b5..bb1efb4 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -55,6 +55,47 @@ struct lmv_stripe_md {
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
+/* NB: LMV_HASH_TYPE_SPACE is set in default LMV only */
+static inline bool lmv_is_known_hash_type(u32 type)
+{
+	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
+	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
+}
+
+static inline bool lmv_dir_striped(const struct lmv_stripe_md *lsm)
+{
+	return lsm && lsm->lsm_md_magic == LMV_MAGIC;
+}
+
+static inline bool lmv_dir_foreign(const struct lmv_stripe_md *lsm)
+{
+	return lsm && lsm->lsm_md_magic == LMV_MAGIC_FOREIGN;
+}
+
+static inline bool lmv_dir_migrating(const struct lmv_stripe_md *lsm)
+{
+	return lmv_dir_striped(lsm) &&
+	       lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION;
+}
+
+static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
+{
+	if (!lmv_dir_striped(lsm))
+		return false;
+
+	if (lmv_dir_migrating(lsm) &&
+	    lsm->lsm_md_stripe_count - lsm->lsm_md_migrate_offset <= 1)
+		return false;
+
+	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type);
+}
+
+/* NB, this is checking directory default LMV */
+static inline bool lmv_dir_space_hashed(const struct lmv_stripe_md *lsm)
+{
+	return lsm && lsm->lsm_md_hash_type == LMV_HASH_TYPE_SPACE;
+}
+
 static inline bool
 lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 {
@@ -72,7 +113,7 @@ struct lmv_stripe_md {
 	    strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name) != 0)
 		return false;
 
-	if (lsm1->lsm_md_magic == LMV_MAGIC_V1) {
+	if (lmv_dir_striped(lsm1)) {
 		for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
 			if (!lu_fid_eq(&lsm1->lsm_md_oinfo[idx].lmo_fid,
 				       &lsm2->lsm_md_oinfo[idx].lmo_fid))
@@ -94,7 +135,7 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 	       lsm->lsm_md_layout_version, lsm->lsm_md_migrate_offset,
 	       lsm->lsm_md_migrate_hash, lsm->lsm_md_pool_name);
 
-	if (lsm->lsm_md_magic != LMV_MAGIC_V1)
+	if (!lmv_dir_striped(lsm))
 		return;
 
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++)
@@ -188,12 +229,6 @@ static inline int lmv_name_to_stripe_index(u32 lmv_hash_type,
 	return idx;
 }
 
-static inline bool lmv_is_known_hash_type(u32 type)
-{
-	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
-	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
-}
-
 static inline bool lmv_magic_supported(u32 lum_magic)
 {
 	return lum_magic == LMV_USER_MAGIC ||
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index f75183b..a1dce52 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -160,8 +160,7 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 	 * Always remove the page for striped dir, because the page is
 	 * built from temporarily in LMV layer
 	 */
-	if (inode && S_ISDIR(inode->i_mode) &&
-	    ll_i2info(inode)->lli_lsm_md) {
+	if (inode && ll_dir_striped(inode)) {
 		__free_page(page);
 		return;
 	}
@@ -314,7 +313,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		goto out;
 	}
 
-	if (unlikely(ll_i2info(inode)->lli_lsm_md)) {
+	if (unlikely(ll_dir_striped(inode))) {
 		/*
 		 * This is only needed for striped dir to fill ..,
 		 * see lmv_read_page
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 191b0f9..50220eb 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3987,7 +3987,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	if (!(exp_connect_flags2(ll_i2sbi(parent)->ll_md_exp) &
 	      OBD_CONNECT2_DIR_MIGRATE)) {
 		if (le32_to_cpu(lum->lum_stripe_count) > 1 ||
-		    ll_i2info(child_inode)->lli_lsm_md) {
+		    ll_dir_striped(child_inode)) {
 			CERROR("%s: MDT doesn't support stripe directory migration!\n",
 			       ll_i2sbi(parent)->ll_fsname);
 			rc = -EOPNOTSUPP;
@@ -4179,7 +4179,7 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 		 * Let's revalidate the dentry again, instead of returning
 		 * error
 		 */
-		if (S_ISDIR(inode->i_mode) && ll_i2info(inode)->lli_lsm_md)
+		if (ll_dir_striped(inode))
 			return 0;
 
 		/* This path cannot be hit for regular files unless in
@@ -4256,8 +4256,7 @@ static int ll_merge_md_attr(struct inode *inode)
 
 	LASSERT(lli->lli_lsm_md);
 
-	/* foreign dir is not striped dir */
-	if (lli->lli_lsm_md->lsm_md_magic == LMV_MAGIC_FOREIGN)
+	if (!lmv_dir_striped(lli->lli_lsm_md))
 		return 0;
 
 	down_read(&lli->lli_lsm_sem);
@@ -4307,8 +4306,7 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		}
 	} else {
 		/* If object isn't regular a file then don't validate size. */
-		if (S_ISDIR(inode->i_mode) &&
-		    lli->lli_lsm_md != NULL) {
+		if (ll_dir_striped(inode)) {
 			rc = ll_merge_md_attr(inode);
 			if (rc < 0)
 				return rc;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 687d504..9e413c2 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1071,6 +1071,13 @@ static inline struct lu_fid *ll_inode2fid(struct inode *inode)
 	return fid;
 }
 
+static inline bool ll_dir_striped(struct inode *inode)
+{
+	LASSERT(inode);
+	return S_ISDIR(inode->i_mode) &&
+	       lmv_dir_striped(ll_i2info(inode)->lli_lsm_md);
+}
+
 static inline loff_t ll_file_maxbytes(struct inode *inode)
 {
 	struct cl_object *obj = ll_i2info(inode)->lli_clob;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index bd17ba1..0633cc5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1282,6 +1282,9 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 	       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid));
 	lsm_md_dump(D_INODE, lsm);
 
+	if (!lmv_dir_striped(lsm))
+		goto out;
+
 	/*
 	 * XXX sigh, this lsm_root initialization should be in
 	 * LMV layer, but it needs ll_iget right now, so we
@@ -1312,7 +1315,7 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 			return rc;
 		}
 	}
-
+out:
 	lli->lli_lsm_md = lsm;
 
 	return 0;
@@ -1394,10 +1397,9 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	 *
 	 * foreign LMV should not change.
 	 */
-	if (lli->lli_lsm_md &&
-	    lli->lli_lsm_md->lsm_md_magic != LMV_MAGIC_FOREIGN &&
-	   !lsm_md_eq(lli->lli_lsm_md, lsm)) {
-		if (lsm->lsm_md_layout_version <=
+	if (lli->lli_lsm_md && !lsm_md_eq(lli->lli_lsm_md, lsm)) {
+		if (lmv_dir_striped(lli->lli_lsm_md) &&
+		    lsm->lsm_md_layout_version <=
 		    lli->lli_lsm_md->lsm_md_layout_version) {
 			CERROR("%s: " DFID " dir layout mismatch:\n",
 			       ll_i2sbi(inode)->ll_fsname,
@@ -1418,16 +1420,6 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	if (!lli->lli_lsm_md) {
 		struct cl_attr *attr;
 
-		if (lsm->lsm_md_magic == LMV_MAGIC_FOREIGN) {
-			/* set md->lmv to NULL, so the following free lustre_md
-			 * will not free this lsm
-			 */
-			md->lmv = NULL;
-			lli->lli_lsm_md = lsm;
-			up_write(&lli->lli_lsm_sem);
-			return 0;
-		}
-
 		rc = ll_init_lsm_md(inode, md);
 		up_write(&lli->lli_lsm_sem);
 		if (rc)
@@ -1445,6 +1437,9 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		 */
 		down_read(&lli->lli_lsm_sem);
 
+		if (!lmv_dir_striped(lli->lli_lsm_md))
+			goto unlock;
+
 		attr = kzalloc(sizeof(*attr), GFP_NOFS);
 		if (!attr) {
 			rc = -ENOMEM;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 1aaf184..fb5caaf 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -221,6 +221,7 @@ int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 {
 	struct inode *inode = ll_inode_from_resource_lock(lock);
+	struct ll_inode_info *lli;
 	u64 bits = to_cancel;
 	int rc;
 
@@ -308,13 +309,12 @@ void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 			       PFID(ll_inode2fid(inode)), rc);
 	}
 
+	lli = ll_i2info(inode);
 	if (bits & MDS_INODELOCK_UPDATE)
 		set_bit(LLIF_UPDATE_ATIME,
-			&ll_i2info(inode)->lli_flags);
+			&lli->lli_flags);
 
 	if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
-		struct ll_inode_info *lli = ll_i2info(inode);
-
 		CDEBUG(D_INODE,
 		       "invalidating inode "DFID" lli = %p, pfid  = "DFID"\n",
 		       PFID(ll_inode2fid(inode)),
@@ -688,7 +688,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		struct lu_fid fid = ll_i2info(parent)->lli_fid;
 
 		/* If it is striped directory, get the real stripe parent */
-		if (unlikely(ll_i2info(parent)->lli_lsm_md)) {
+		if (unlikely(ll_dir_striped(parent))) {
 			rc = md_get_fid_from_lsm(ll_i2mdexp(parent),
 						 ll_i2info(parent)->lli_lsm_md,
 						 (*de)->d_name.name,
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index ba14e7c..6017375 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -293,16 +293,15 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	int rc;
 
 	/* do not allow file creation in foreign dir */
-	if ((it->it_op & IT_CREAT) && op_data->op_mea1 &&
-	    op_data->op_mea1->lsm_md_magic == LMV_MAGIC_FOREIGN)
+	if ((it->it_op & IT_CREAT) && lmv_dir_foreign(op_data->op_mea1))
 		return -ENODATA;
 
 	if ((it->it_op & IT_CREAT) && !(flags & MDS_OPEN_BY_FID)) {
 		/* don't allow create under dir with bad hash */
-		if (lmv_is_dir_bad_hash(op_data->op_mea1))
+		if (lmv_dir_bad_hash(op_data->op_mea1))
 			return -EBADF;
 
-		if (lmv_is_dir_migrating(op_data->op_mea1)) {
+		if (lmv_dir_migrating(op_data->op_mea1)) {
 			if (flags & O_EXCL) {
 				/*
 				 * open(O_CREAT | O_EXCL) needs to check
@@ -311,8 +310,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 				 * file under old layout, check old layout on
 				 * client side.
 				 */
-				tgt = lmv_locate_tgt(lmv, op_data,
-						     &op_data->op_fid1);
+				tgt = lmv_locate_tgt(lmv, op_data);
 				if (IS_ERR(tgt))
 					return PTR_ERR(tgt);
 
@@ -348,7 +346,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		 * without name, but we can set it to child fid, and MDT
 		 * will obtain it from linkea in open in such case.
 		 */
-		if (op_data->op_mea1)
+		if (lmv_dir_striped(op_data->op_mea1))
 			op_data->op_fid1 = op_data->op_fid2;
 
 		tgt = lmv_find_target(lmv, &op_data->op_fid2);
@@ -361,7 +359,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		LASSERT(fid_is_zero(&op_data->op_fid2));
 		LASSERT(op_data->op_name);
 
-		tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+		tgt = lmv_locate_tgt(lmv, op_data);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	}
@@ -448,8 +446,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	int rc;
 
 	/* foreign dir is not striped */
-	if (op_data->op_mea1 &&
-	    op_data->op_mea1->lsm_md_magic == LMV_MAGIC_FOREIGN) {
+	if (lmv_dir_foreign(op_data->op_mea1)) {
 		/* only allow getattr/lookup for itself */
 		if (op_data->op_name)
 			return -ENODATA;
@@ -457,7 +454,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	}
 
 retry:
-	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+	tgt = lmv_locate_tgt(lmv, op_data);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -482,7 +479,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		 * If RPC happens, lsm information will be revalidated
 		 * during update_inode process (see ll_update_lsm_md)
 		 */
-		if (op_data->op_mea2) {
+		if (lmv_dir_striped(op_data->op_mea2)) {
 			rc = lmv_revalidate_slaves(exp, op_data->op_mea2,
 						   cb_blocking,
 						   extra_lock_flags);
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index b4c5297..9974ec5 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -137,6 +137,8 @@ static inline int lmv_stripe_md_size(int stripe_count)
 	u32 stripe_count = lsm->lsm_md_stripe_count;
 	int stripe_index;
 
+	LASSERT(lmv_dir_striped(lsm));
+
 	if (hash_type & LMV_HASH_FLAG_MIGRATION) {
 		if (post_migrate) {
 			hash_type &= ~LMV_HASH_FLAG_MIGRATION;
@@ -166,26 +168,6 @@ static inline int lmv_stripe_md_size(int stripe_count)
 	return &lsm->lsm_md_oinfo[stripe_index];
 }
 
-static inline bool lmv_is_dir_migrating(const struct lmv_stripe_md *lsm)
-{
-	return lsm ? lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION : false;
-}
-
-static inline bool lmv_is_dir_bad_hash(const struct lmv_stripe_md *lsm)
-{
-	if (!lsm)
-		return false;
-
-	if (lmv_is_dir_migrating(lsm)) {
-		if (lsm->lsm_md_stripe_count - lsm->lsm_md_migrate_offset > 1)
-			return !lmv_is_known_hash_type(
-					lsm->lsm_md_migrate_hash);
-		return false;
-	}
-
-	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type);
-}
-
 static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 {
 	const struct lmv_stripe_md *lsm = op_data->op_mea1;
@@ -193,12 +175,12 @@ static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 	if (!lsm)
 		return false;
 
-	if (lmv_is_dir_migrating(lsm) && !op_data->op_post_migrate) {
+	if (lmv_dir_migrating(lsm) && !op_data->op_post_migrate) {
 		op_data->op_post_migrate = true;
 		return true;
 	}
 
-	if (lmv_is_dir_bad_hash(lsm) &&
+	if (lmv_dir_bad_hash(lsm) &&
 	    op_data->op_stripe_index < lsm->lsm_md_stripe_count - 1) {
 		op_data->op_stripe_index++;
 		return true;
@@ -208,8 +190,8 @@ static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 }
 
 struct lmv_tgt_desc *lmv_locate_tgt(struct lmv_obd *lmv,
-				    struct md_op_data *op_data,
-				    struct lu_fid *fid);
+				    struct md_op_data *op_data);
+
 /* lproc_lmv.c */
 int lmv_tunables_init(struct obd_device *obd);
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 4365533..02dfd35 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1149,24 +1149,24 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 /**
  * This is _inode_ placement policy function (not name).
  */
-static int lmv_placement_policy(struct obd_device *obd,
-				struct md_op_data *op_data, u32 *mds)
+static u32 lmv_placement_policy(struct obd_device *obd,
+				struct md_op_data *op_data)
 {
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_user_md *lum;
+	u32 mdt;
 
-	LASSERT(mds);
-
-	if (lmv->desc.ld_tgt_count == 1) {
-		*mds = 0;
+	if (lmv->desc.ld_tgt_count == 1)
 		return 0;
-	}
 
 	lum = op_data->op_data;
-	/* Choose MDS by
+	/*
+	 * Choose MDT by
 	 * 1. See if the stripe offset is specified by lum.
-	 * 2. Then check if there is default stripe offset.
-	 * 3. Finally choose MDS by name hash if the parent
+	 * 2. If parent has default LMV, and its hash type is "space", choose
+	 *    MDT with QoS. (see lmv_locate_tgt_qos()).
+	 * 3. Then check if default LMV stripe offset is not -1.
+	 * 4. Finally choose MDS by name hash if the parent
 	 *    is striped directory. (see lmv_locate_tgt()).
 	 *
 	 * presently explicit MDT location is not supported
@@ -1177,18 +1177,22 @@ static int lmv_placement_policy(struct obd_device *obd,
 	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
 	    le32_to_cpu(lum->lum_magic != LMV_MAGIC_FOREIGN) &&
 	    le32_to_cpu(lum->lum_stripe_offset) != (u32)-1) {
-		*mds = le32_to_cpu(lum->lum_stripe_offset);
+		mdt = le32_to_cpu(lum->lum_stripe_offset);
+	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
+		   !lmv_dir_striped(op_data->op_mea1) &&
+		   lmv_dir_space_hashed(op_data->op_default_mea1)) {
+		mdt = op_data->op_mds;
 	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
 		   op_data->op_default_mea1 &&
 		   op_data->op_default_mea1->lsm_md_master_mdt_index !=
-			 (u32)-1) {
-		*mds = op_data->op_default_mea1->lsm_md_master_mdt_index;
-		op_data->op_mds = *mds;
+			(u32)-1) {
+		mdt = op_data->op_default_mea1->lsm_md_master_mdt_index;
+		op_data->op_mds = mdt;
 	} else {
-		*mds = op_data->op_mds;
+		mdt = op_data->op_mds;
 	}
 
-	return 0;
+	return mdt;
 }
 
 int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
@@ -1230,24 +1234,17 @@ int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 {
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
-	u32 mds = 0;
+	u32 mds;
 	int rc;
 
 	LASSERT(op_data);
 	LASSERT(fid);
 
-	rc = lmv_placement_policy(obd, op_data, &mds);
-	if (rc) {
-		CERROR("Can't get target for allocating fid, rc %d\n",
-		       rc);
-		return rc;
-	}
+	mds = lmv_placement_policy(obd, op_data);
 
 	rc = __lmv_fid_alloc(lmv, fid, mds);
-	if (rc) {
+	if (rc)
 		CERROR("Can't alloc new fid, rc %d\n", rc);
-		return rc;
-	}
 
 	return rc;
 }
@@ -1588,20 +1585,30 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
-struct lmv_tgt_desc*
-__lmv_locate_tgt(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
-		 const char *name, int namelen, struct lu_fid *fid, u32 *mds,
-		 bool post_migrate)
+static struct lmv_tgt_desc *lmv_locate_tgt_qos(struct lmv_obd *lmv, u32 *mdt)
+{
+	static unsigned int rr_index;
+
+	/* locate MDT round-robin is the first step */
+	*mdt = rr_index % lmv->tgts_size;
+	rr_index++;
+
+	return lmv->tgts[*mdt];
+}
+
+static struct lmv_tgt_desc *
+lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
+		       const char *name, int namelen, struct lu_fid *fid,
+		       u32 *mds, bool post_migrate)
 {
 	const struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
-	if (!lsm || namelen == 0) {
+	if (!lmv_dir_striped(lsm) || !namelen) {
 		tgt = lmv_find_target(lmv, fid);
 		if (IS_ERR(tgt))
 			return tgt;
 
-		LASSERT(mds);
 		*mds = tgt->ltd_idx;
 		return tgt;
 	}
@@ -1617,47 +1624,41 @@ struct lmv_tgt_desc*
 			return ERR_CAST(oinfo);
 	}
 
-	if (fid)
-		*fid = oinfo->lmo_fid;
-	if (mds)
-		*mds = oinfo->lmo_mds;
-
+	*fid = oinfo->lmo_fid;
+	*mds = oinfo->lmo_mds;
 	tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
 
-	CDEBUG(D_INFO, "locate on mds %u " DFID "\n", oinfo->lmo_mds,
-	       PFID(&oinfo->lmo_fid));
+	CDEBUG(D_INODE, "locate MDT %u parent " DFID "\n", *mds, PFID(fid));
 
 	return tgt;
 }
 
 /**
- * Locate mdt by fid or name
+ * Locate MDT of op_data->op_fid1
  *
  * For striped directory, it will locate the stripe by name hash, if hash_type
  * is unknown, it will return the stripe specified by 'op_data->op_stripe_index'
  * which is set outside, and if dir is migrating, 'op_data->op_post_migrate'
  * indicates whether old or new layout is used to locate.
  *
- * For normal direcotry, it will locate MDS by FID directly.
+ * For plain direcotry, normally it will locate MDT by FID, but if this
+ * directory has default LMV, and its hash type is "space", locate MDT with QoS.
  *
  * @lmv:	LMV device
  * @op_data:	client MD stack parameters, name, namelen
  *		mds_num etc.
- * @fid:	object FID used to locate MDS.
  *
  * Returns:	pointer to the lmv_tgt_desc if succeed.
  *		ERR_PTR(errno) if failed.
  */
-struct lmv_tgt_desc*
-lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data,
-	       struct lu_fid *fid)
+struct lmv_tgt_desc *
+lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
-	/* foreign dir is not striped dir */
-	if (lsm && lsm->lsm_md_magic == LMV_MAGIC_FOREIGN)
+	if (lmv_dir_foreign(lsm))
 		return ERR_PTR(-ENODATA);
 
 	/*
@@ -1671,43 +1672,101 @@ struct lmv_tgt_desc*
 		if (IS_ERR(tgt))
 			return tgt;
 
-		if (lsm) {
+		if (lmv_dir_striped(lsm)) {
 			int i;
 
 			/* refill the right parent fid */
 			for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 				oinfo = &lsm->lsm_md_oinfo[i];
 				if (oinfo->lmo_mds == op_data->op_mds) {
-					*fid = oinfo->lmo_fid;
+					op_data->op_fid1 = oinfo->lmo_fid;
 					break;
 				}
 			}
 
 			if (i == lsm->lsm_md_stripe_count)
-				*fid = lsm->lsm_md_oinfo[0].lmo_fid;
+				op_data->op_fid1 = lsm->lsm_md_oinfo[0].lmo_fid;
 		}
-	} else if (lmv_is_dir_bad_hash(lsm)) {
+	} else if (lmv_dir_bad_hash(lsm)) {
 		LASSERT(op_data->op_stripe_index < lsm->lsm_md_stripe_count);
 		oinfo = &lsm->lsm_md_oinfo[op_data->op_stripe_index];
 
-		*fid = oinfo->lmo_fid;
+		op_data->op_fid1 = oinfo->lmo_fid;
 		op_data->op_mds = oinfo->lmo_mds;
-
 		tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
+	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
+		   lmv_dir_space_hashed(op_data->op_default_mea1) &&
+		   !lmv_dir_striped(lsm)) {
+		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
+		/*
+		 * only update statfs when mkdir under dir with "space" hash,
+		 * this means the cached statfs may be stale, and current mkdir
+		 * may not follow QoS accurately, but it's not serious, and it
+		 * avoids periodic statfs when client doesn't mkdir under
+		 * "space" hashed directories.
+		 */
+		if (!IS_ERR(tgt)) {
+			struct obd_device *obd;
+
+			obd = container_of(lmv, struct obd_device, u.lmv);
+			lmv_statfs_check_update(obd, tgt);
+		}
 	} else {
-		tgt = __lmv_locate_tgt(lmv, lsm, op_data->op_name,
-				       op_data->op_namelen, fid,
-				       &op_data->op_mds,
-				       op_data->op_post_migrate);
+		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_mea1,
+				op_data->op_name, op_data->op_namelen,
+				&op_data->op_fid1, &op_data->op_mds,
+				op_data->op_post_migrate);
 	}
 
 	return tgt;
 }
 
-static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
-		      const void *data, size_t datalen, umode_t mode,
-		      uid_t uid, gid_t gid, kernel_cap_t cap_effective,
-		      u64 rdev, struct ptlrpc_request **request)
+/* Locate MDT of op_data->op_fid2 for link/rename */
+static struct lmv_tgt_desc *
+lmv_locate_tgt2(struct lmv_obd *lmv, struct md_op_data *op_data)
+{
+	struct lmv_tgt_desc *tgt;
+	int rc;
+
+	LASSERT(op_data->op_name);
+	if (lmv_dir_migrating(op_data->op_mea2)) {
+		struct lu_fid fid1 = op_data->op_fid1;
+		struct lmv_stripe_md *lsm1 = op_data->op_mea1;
+		struct ptlrpc_request *request = NULL;
+
+		/*
+		 * avoid creating new file under old layout of migrating
+		 * directory, check it here.
+		 */
+		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_mea2,
+				op_data->op_name, op_data->op_namelen,
+				&op_data->op_fid2, &op_data->op_mds, false);
+		if (IS_ERR(tgt))
+			return tgt;
+
+		op_data->op_fid1 = op_data->op_fid2;
+		op_data->op_mea1 = op_data->op_mea2;
+		rc = md_getattr_name(tgt->ltd_exp, op_data, &request);
+		op_data->op_fid1 = fid1;
+		op_data->op_mea1 = lsm1;
+		if (!rc) {
+			ptlrpc_req_finished(request);
+			return ERR_PTR(-EEXIST);
+		}
+
+		if (rc != -ENOENT)
+			return ERR_PTR(rc);
+	}
+
+	return lmv_locate_tgt_by_name(lmv, op_data->op_mea2, op_data->op_name,
+				op_data->op_namelen, &op_data->op_fid2,
+				&op_data->op_mds, true);
+}
+
+int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
+		const void *data, size_t datalen, umode_t mode, uid_t uid,
+		gid_t gid, kernel_cap_t cap_effective, u64 rdev,
+		struct ptlrpc_request **request)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
@@ -1717,16 +1776,16 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (!lmv->desc.ld_active_tgt_count)
 		return -EIO;
 
-	if (lmv_is_dir_bad_hash(op_data->op_mea1))
+	if (lmv_dir_bad_hash(op_data->op_mea1))
 		return -EBADF;
 
-	if (lmv_is_dir_migrating(op_data->op_mea1)) {
+	if (lmv_dir_migrating(op_data->op_mea1)) {
 		/*
 		 * if parent is migrating, create() needs to lookup existing
 		 * name, to avoid creating new file under old layout of
 		 * migrating directory, check old layout here.
 		 */
-		tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+		tgt = lmv_locate_tgt(lmv, op_data);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 
@@ -1743,7 +1802,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_post_migrate = true;
 	}
 
-	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+	tgt = lmv_locate_tgt(lmv, op_data);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1765,8 +1824,6 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 			return PTR_ERR(tgt);
 
 		op_data->op_mds = tgt->ltd_idx;
-	} else {
-		CDEBUG(D_CONFIG, "Server doesn't support striped dirs\n");
 	}
 
 	CDEBUG(D_INODE, "CREATE obj " DFID " -> mds #%x\n",
@@ -1818,7 +1875,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	int rc;
 
 retry:
-	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+	tgt = lmv_locate_tgt(lmv, op_data);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1916,39 +1973,7 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
 
-	if (lmv_is_dir_migrating(op_data->op_mea2)) {
-		struct lu_fid fid1 = op_data->op_fid1;
-		struct lmv_stripe_md *lsm1 = op_data->op_mea1;
-
-		/*
-		 * avoid creating new file under old layout of migrating
-		 * directory, check it here.
-		 */
-		tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, op_data->op_name,
-				       op_data->op_namelen, &op_data->op_fid2,
-				       &op_data->op_mds, false);
-		tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
-
-		op_data->op_fid1 = op_data->op_fid2;
-		op_data->op_mea1 = op_data->op_mea2;
-		rc = md_getattr_name(tgt->ltd_exp, op_data, request);
-		op_data->op_fid1 = fid1;
-		op_data->op_mea1 = lsm1;
-		if (!rc) {
-			ptlrpc_req_finished(*request);
-			*request = NULL;
-			return -EEXIST;
-		}
-
-		if (rc != -ENOENT)
-			return rc;
-	}
-
-	tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, op_data->op_name,
-			       op_data->op_namelen, &op_data->op_fid2,
-			       &op_data->op_mds, true);
+	tgt = lmv_locate_tgt2(lmv, op_data);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1992,7 +2017,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(parent_tgt))
 		return PTR_ERR(parent_tgt);
 
-	if (lsm) {
+	if (lmv_dir_striped(lsm)) {
 		u32 hash_type = lsm->lsm_md_hash_type;
 		u32 stripe_count = lsm->lsm_md_stripe_count;
 
@@ -2000,7 +2025,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 		 * old stripes are appended after new stripes for migrating
 		 * directory.
 		 */
-		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION) {
+		if (lmv_dir_migrating(lsm)) {
 			hash_type = lsm->lsm_md_migrate_hash;
 			stripe_count -= lsm->lsm_md_migrate_offset;
 		}
@@ -2010,7 +2035,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 		if (rc < 0)
 			return rc;
 
-		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION)
+		if (lmv_dir_migrating(lsm))
 			rc += lsm->lsm_md_migrate_offset;
 
 		/* save it in fid4 temporarily for early cancel */
@@ -2024,7 +2049,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 		 * if parent is being migrated too, fill op_fid2 with target
 		 * stripe fid, otherwise the target stripe is not created yet.
 		 */
-		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION) {
+		if (lmv_dir_migrating(lsm)) {
 			hash_type = lsm->lsm_md_hash_type &
 				    ~LMV_HASH_FLAG_MIGRATION;
 			stripe_count = lsm->lsm_md_migrate_offset;
@@ -2151,44 +2176,10 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
 
-	if (lmv_is_dir_migrating(op_data->op_mea2)) {
-		struct lu_fid fid1 = op_data->op_fid1;
-		struct lmv_stripe_md *lsm1 = op_data->op_mea1;
-
-		/*
-		 * we avoid creating new file under old layout of migrating
-		 * directory, if there is an existing file with new name under
-		 * old layout, we can't unlink file in old layout and rename to
-		 * new layout in one transaction, so return -EBUSY here.`
-		 */
-		tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, new, newlen,
-				       &op_data->op_fid2, &op_data->op_mds,
-				       false);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
-
-		op_data->op_fid1 = op_data->op_fid2;
-		op_data->op_mea1 = op_data->op_mea2;
-		op_data->op_name = new;
-		op_data->op_namelen = newlen;
-		rc = md_getattr_name(tgt->ltd_exp, op_data, request);
-		op_data->op_fid1 = fid1;
-		op_data->op_mea1 = lsm1;
-		op_data->op_name = NULL;
-		op_data->op_namelen = 0;
-		if (!rc) {
-			ptlrpc_req_finished(*request);
-			*request = NULL;
-			return -EBUSY;
-		}
+	op_data->op_name = new;
+	op_data->op_namelen = newlen;
 
-		if (rc != -ENOENT)
-			return rc;
-	}
-
-	/* rename to new layout for migrating directory */
-	tp_tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, new, newlen,
-				  &op_data->op_fid2, &op_data->op_mds, true);
+	tp_tgt = lmv_locate_tgt2(lmv, op_data);
 	if (IS_ERR(tp_tgt))
 		return PTR_ERR(tp_tgt);
 
@@ -2240,10 +2231,10 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 	}
 
+	op_data->op_name = old;
+	op_data->op_namelen = oldlen;
 retry:
-	sp_tgt = __lmv_locate_tgt(lmv, op_data->op_mea1, old, oldlen,
-				  &op_data->op_fid1, &op_data->op_mds,
-				  op_data->op_post_migrate);
+	sp_tgt = lmv_locate_tgt(lmv, op_data);
 	if (IS_ERR(sp_tgt))
 		return PTR_ERR(sp_tgt);
 
@@ -2710,16 +2701,14 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 			 struct md_callback *cb_op, u64 offset,
 			 struct page **ppage)
 {
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	if (unlikely(lsm)) {
-		/* foreign dir is not striped dir */
-		if (lsm->lsm_md_magic == LMV_MAGIC_FOREIGN)
-			return -ENODATA;
+	if (unlikely(lmv_dir_foreign(op_data->op_mea1)))
+		return -ENODATA;
 
+	if (unlikely(lmv_dir_striped(op_data->op_mea1))) {
 		return lmv_striped_read_page(exp, op_data, cb_op,
 					     offset, ppage);
 	}
@@ -2770,7 +2759,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_cap = current_cap();
 
 retry:
-	parent_tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+	parent_tgt = lmv_locate_tgt(lmv, op_data);
 	if (IS_ERR(parent_tgt))
 		return PTR_ERR(parent_tgt);
 
@@ -3060,7 +3049,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 			return 0;
 		}
 
-		if (lsm->lsm_md_magic == LMV_MAGIC) {
+		if (lmv_dir_striped(lsm)) {
 			for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 				if (lsm->lsm_md_oinfo[i].lmo_root)
 					iput(lsm->lsm_md_oinfo[i].lmo_root);
@@ -3343,7 +3332,8 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 {
 	const struct lmv_oinfo *oinfo;
 
-	LASSERT(lsm);
+	LASSERT(lmv_dir_striped(lsm));
+
 	oinfo = lsm_name_to_stripe_info(lsm, name, namelen, false);
 	if (IS_ERR(oinfo))
 		return PTR_ERR(oinfo);
@@ -3408,8 +3398,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 {
 	int rc, i;
 
-	/* foreign dir is not striped dir */
-	if (lsm->lsm_md_magic == LMV_MAGIC_FOREIGN)
+	if (!lmv_dir_striped(lsm))
 		return 0;
 
 	rc = lmv_revalidate_slaves(exp, lsm, cb_blocking, 0);
-- 
1.8.3.1
