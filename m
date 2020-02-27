From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:42 -0500
Subject: [lustre-devel] [PATCH 114/622] lustre: migrate: migrate striped
 directory
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-115-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Migrate striped directory in below steps:
1. create target object if needed: if source is directory, a
   target object is always created, otherwise if source is
   already located on the target MDT, or source still has
   link on source MDT, then skip creating.
        a) if source is directory, detach source stripes and
           attach them to target.
        b) migrate source xattrs to target.
        c) if source is regular file, update PFID to target
           fid.
        d) update fid to target for all links of source
2. update namespace
        a) migrate dirent from source parent to target parent.
        b) update linkea parent fid to target parent.
        c) destroy source object.

This implementation improves following fields:
1. all involved objects are locked to avoid race.
2. directory migration doesn't migrate its dir entries, instead
   it's done in each sub file migration, this avoids timeout in
   migrating dir entries for large directory, and also avoids
   touching dir entries without lock.
3. file/dir is migrated in one transaction, so migrate recovery
   is the same as others.
4. migrating directory can be accessed (modifiable) like normal
   directory.
5. if migration of sub files under a directory fails, user can
   redo migrate to finish migration of this directory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4684
Lustre-commit: 169738e30a7e ("LU-4684 migrate: migrate striped directory")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31427
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h          |  24 ++-
 fs/lustre/include/lustre_lmv.h         |  18 +-
 fs/lustre/llite/file.c                 |  11 +
 fs/lustre/llite/llite_lib.c            |  90 +++++----
 fs/lustre/lmv/lmv_internal.h           |  15 +-
 fs/lustre/lmv/lmv_obd.c                | 357 ++++++++++++++++++++++-----------
 fs/lustre/mdc/mdc_internal.h           |   2 +
 fs/lustre/mdc/mdc_lib.c                |  45 +++--
 fs/lustre/mdc/mdc_reint.c              |   5 +-
 fs/lustre/ptlrpc/wiretest.c            |  16 +-
 include/uapi/linux/lustre/lustre_idl.h |  16 +-
 11 files changed, 403 insertions(+), 196 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index e49954c..a709ad7 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1229,6 +1229,26 @@ struct lu_name {
 	int		ln_namelen;
 };
 
+static inline bool name_is_dot_or_dotdot(const char *name, int namelen)
+{
+	return name[0] == '.' &&
+	       (namelen == 1 || (namelen == 2 && name[1] == '.'));
+}
+
+static inline bool lu_name_is_dot_or_dotdot(const struct lu_name *lname)
+{
+	return name_is_dot_or_dotdot(lname->ln_name, lname->ln_namelen);
+}
+
+static inline bool lu_name_is_valid_len(const char *name, size_t name_len)
+{
+	return name &&
+	       name_len > 0 &&
+	       name_len < INT_MAX &&
+	       strlen(name) == name_len &&
+	       memchr(name, '/', name_len) == NULL;
+}
+
 /**
  * Validate names (path components)
  *
@@ -1240,9 +1260,7 @@ struct lu_name {
  */
 static inline bool lu_name_is_valid_2(const char *name, size_t name_len)
 {
-	return name && name_len > 0 && name_len < INT_MAX &&
-	       name[name_len] == '\0' && strlen(name) == name_len &&
-	       !memchr(name, '/', name_len);
+	return lu_name_is_valid_len(name, name_len) && name[name_len] == '\0';
 }
 
 /**
diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 5e15c62..ff279e1 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -47,6 +47,8 @@ struct lmv_stripe_md {
 	u32	lsm_md_master_mdt_index;
 	u32	lsm_md_hash_type;
 	u32	lsm_md_layout_version;
+	u32	lsm_md_migrate_offset;
+	u32	lsm_md_migrate_hash;
 	u32	lsm_md_default_count;
 	u32	lsm_md_default_index;
 	char	lsm_md_pool_name[LOV_MAXPOOLNAME + 1];
@@ -63,6 +65,10 @@ struct lmv_stripe_md {
 	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
 	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
 	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
+	    lsm1->lsm_md_migrate_offset !=
+				lsm2->lsm_md_migrate_offset ||
+	    lsm1->lsm_md_migrate_hash !=
+				lsm2->lsm_md_migrate_hash ||
 	    strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name) != 0)
 		return false;
 
@@ -137,18 +143,14 @@ static inline int lmv_name_to_stripe_index(u32 lmv_hash_type,
 					   unsigned int stripe_count,
 					   const char *name, int namelen)
 {
-	u32 hash_type = lmv_hash_type & LMV_HASH_TYPE_MASK;
 	int idx;
 
 	LASSERT(namelen > 0);
-	if (stripe_count <= 1)
-		return 0;
 
-	/* for migrating object, always start from 0 stripe */
-	if (lmv_hash_type & LMV_HASH_FLAG_MIGRATION)
+	if (stripe_count <= 1)
 		return 0;
 
-	switch (hash_type) {
+	switch (lmv_hash_type & LMV_HASH_TYPE_MASK) {
 	case LMV_HASH_TYPE_ALL_CHARS:
 		idx = lmv_hash_all_chars(stripe_count, name, namelen);
 		break;
@@ -159,8 +161,8 @@ static inline int lmv_name_to_stripe_index(u32 lmv_hash_type,
 		idx = -EBADFD;
 		break;
 	}
-	CDEBUG(D_INFO, "name %.*s hash_type %d idx %d\n", namelen, name,
-	       hash_type, idx);
+	CDEBUG(D_INFO, "name %.*s hash_type %#x idx %d/%u\n", namelen, name,
+	       lmv_hash_type, idx, stripe_count);
 
 	return idx;
 }
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ae39b2c..fd39948 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3836,6 +3836,17 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	if (!child_inode)
 		return -ENOENT;
 
+	if (!(exp_connect_flags2(ll_i2sbi(parent)->ll_md_exp) &
+	      OBD_CONNECT2_DIR_MIGRATE)) {
+		if (le32_to_cpu(lum->lum_stripe_count) > 1 ||
+		    ll_i2info(child_inode)->lli_lsm_md) {
+			CERROR("%s: MDT doesn't support stripe directory migration!\n",
+			       ll_get_fsname(parent->i_sb, NULL, 0));
+			rc = -EOPNOTSUPP;
+			goto out_iput;
+		}
+	}
+
 	/*
 	 * lfs migrate command needs to be blocked on the client
 	 * by checking the migrate FID against the FID of the
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 37558a8..636ddf8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1254,14 +1254,8 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 		 * different, so it reset lsm_md to NULL to avoid
 		 * initializing lsm for slave inode.
 		 */
-		/* For migrating inode, master stripe and master object will
-		 * be same, so we only need assign this inode
-		 */
-		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION && !i)
-			lsm->lsm_md_oinfo[i].lmo_root = inode;
-		else
-			lsm->lsm_md_oinfo[i].lmo_root =
-				ll_iget_anon_dir(inode->i_sb, fid, md);
+		lsm->lsm_md_oinfo[i].lmo_root =
+			ll_iget_anon_dir(inode->i_sb, fid, md);
 		if (IS_ERR(lsm->lsm_md_oinfo[i].lmo_root)) {
 			int rc = PTR_ERR(lsm->lsm_md_oinfo[i].lmo_root);
 
@@ -1273,20 +1267,6 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 	return 0;
 }
 
-static inline int lli_lsm_md_eq(const struct lmv_stripe_md *lsm_md1,
-				const struct lmv_stripe_md *lsm_md2)
-{
-	return lsm_md1->lsm_md_magic == lsm_md2->lsm_md_magic &&
-	       lsm_md1->lsm_md_stripe_count == lsm_md2->lsm_md_stripe_count &&
-	       lsm_md1->lsm_md_master_mdt_index ==
-			lsm_md2->lsm_md_master_mdt_index &&
-	       lsm_md1->lsm_md_hash_type == lsm_md2->lsm_md_hash_type &&
-	       lsm_md1->lsm_md_layout_version ==
-			lsm_md2->lsm_md_layout_version &&
-	       !strcmp(lsm_md1->lsm_md_pool_name,
-		       lsm_md2->lsm_md_pool_name);
-}
-
 static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1297,27 +1277,53 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	CDEBUG(D_INODE, "update lsm %p of " DFID "\n", lli->lli_lsm_md,
 	       PFID(ll_inode2fid(inode)));
 
-	/* no striped information from request. */
-	if (!lsm) {
-		if (!lli->lli_lsm_md) {
-			return 0;
-		} else if (lli->lli_lsm_md->lsm_md_hash_type &
-			   LMV_HASH_FLAG_MIGRATION) {
-			/*
-			 * migration is done, the temporay MIGRATE layout has
-			 * been removed
-			 */
-			CDEBUG(D_INODE, DFID " finish migration.\n",
-			       PFID(ll_inode2fid(inode)));
-			lmv_free_memmd(lli->lli_lsm_md);
-			lli->lli_lsm_md = NULL;
-			return 0;
-		}
-		/*
-		 * The lustre_md from req does not include stripeEA,
-		 * see ll_md_setattr
-		 */
+	/*
+	 * no striped information from request, lustre_md from req does not
+	 * include stripeEA, see ll_md_setattr()
+	 */
+	if (!lsm)
 		return 0;
+
+	/* Compare the old and new stripe information */
+	if (lli->lli_lsm_md && !lsm_md_eq(lli->lli_lsm_md, lsm)) {
+		struct lmv_stripe_md *old_lsm = lli->lli_lsm_md;
+		bool layout_changed = lsm->lsm_md_layout_version >
+				      old_lsm->lsm_md_layout_version;
+		int mask = layout_changed ? D_INODE : D_ERROR;
+		int idx;
+
+		CDEBUG(mask,
+		       "%s: inode@%p "DFID" lmv layout %s magic %#x/%#x stripe count %d/%d master_mdt %d/%d hash_type %#x/%#x version %d/%d migrate offset %d/%d  migrate hash %#x/%#x pool %s/%s\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0), inode,
+		       PFID(&lli->lli_fid),
+		       layout_changed ? "changed" : "mismatch",
+		       lsm->lsm_md_magic, old_lsm->lsm_md_magic,
+		       lsm->lsm_md_stripe_count,
+		       old_lsm->lsm_md_stripe_count,
+		       lsm->lsm_md_master_mdt_index,
+		       old_lsm->lsm_md_master_mdt_index,
+		       lsm->lsm_md_hash_type, old_lsm->lsm_md_hash_type,
+		       lsm->lsm_md_layout_version,
+		       old_lsm->lsm_md_layout_version,
+		       lsm->lsm_md_migrate_offset,
+		       old_lsm->lsm_md_migrate_offset,
+		       lsm->lsm_md_migrate_hash,
+		       old_lsm->lsm_md_migrate_hash,
+		       lsm->lsm_md_pool_name,
+		       old_lsm->lsm_md_pool_name);
+
+		for (idx = 0; idx < old_lsm->lsm_md_stripe_count; idx++)
+			CDEBUG(mask, "old stripe[%d] "DFID"\n",
+			       idx, PFID(&old_lsm->lsm_md_oinfo[idx].lmo_fid));
+
+		for (idx = 0; idx < lsm->lsm_md_stripe_count; idx++)
+			CDEBUG(mask, "new stripe[%d] "DFID"\n",
+			       idx, PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
+
+		if (!layout_changed)
+			return -EINVAL;
+
+		ll_dir_clear_lsm_md(inode);
 	}
 
 	/* set the directory layout */
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index 6794f11..c4a2fb8 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -123,18 +123,21 @@ static inline int lmv_stripe_md_size(int stripe_count)
 	return sizeof(*lsm) + stripe_count * sizeof(lsm->lsm_md_oinfo[0]);
 }
 
-int lmv_name_to_stripe_index(enum lmv_hash_type hashtype,
-			     unsigned int max_mdt_index,
-			     const char *name, int namelen);
-
+/* for file under migrating directory, return the target stripe info */
 static inline const struct lmv_oinfo *
 lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
 			int namelen)
 {
+	u32 hash_type = lsm->lsm_md_hash_type;
+	u32 stripe_count = lsm->lsm_md_stripe_count;
 	int stripe_index;
 
-	stripe_index = lmv_name_to_stripe_index(lsm->lsm_md_hash_type,
-						lsm->lsm_md_stripe_count,
+	if (hash_type & LMV_HASH_FLAG_MIGRATION) {
+		hash_type &= ~LMV_HASH_FLAG_MIGRATION;
+		stripe_count = lsm->lsm_md_migrate_offset;
+	}
+
+	stripe_index = lmv_name_to_stripe_index(hash_type, stripe_count,
 						name, namelen);
 	if (stripe_index < 0)
 		return ERR_PTR(stripe_index);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 90a46c4..3ddffd8 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1836,154 +1836,284 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	return md_link(tgt->ltd_exp, op_data, request);
 }
 
-static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
-		      const char *old, size_t oldlen,
-		      const char *new, size_t newlen,
-		      struct ptlrpc_request **request)
+static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
+			const char *name, size_t namelen,
+			struct ptlrpc_request **request)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct obd_export *target_exp;
-	struct lmv_tgt_desc *src_tgt;
-	struct lmv_tgt_desc *tgt_tgt;
-	struct mdt_body *body;
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct lmv_tgt_desc *parent_tgt;
+	struct lmv_tgt_desc *sp_tgt;
+	struct lmv_tgt_desc *tp_tgt = NULL;
+	struct lmv_tgt_desc *child_tgt;
+	struct lmv_tgt_desc *tgt;
+	struct lu_fid target_fid;
 	int rc;
 
-	LASSERT(oldlen != 0);
+	LASSERT(op_data->op_cli_flags & CLI_MIGRATE);
+	LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID "DFID"\n",
+		 PFID(&op_data->op_fid3));
 
-	CDEBUG(D_INODE, "RENAME %.*s in " DFID ":%d to %.*s in " DFID ":%d\n",
-	       (int)oldlen, old, PFID(&op_data->op_fid1),
-	       op_data->op_mea1 ? op_data->op_mea1->lsm_md_stripe_count : 0,
-	       (int)newlen, new, PFID(&op_data->op_fid2),
-	       op_data->op_mea2 ? op_data->op_mea2->lsm_md_stripe_count : 0);
+	CDEBUG(D_INODE, "MIGRATE "DFID"/%.*s\n",
+	       PFID(&op_data->op_fid1), (int)namelen, name);
 
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
 
-	if (op_data->op_cli_flags & CLI_MIGRATE) {
-		LASSERTF(fid_is_sane(&op_data->op_fid3),
-			 "invalid FID " DFID "\n",
-			 PFID(&op_data->op_fid3));
-
-		if (op_data->op_mea1) {
-			struct lmv_stripe_md *lsm = op_data->op_mea1;
-			struct lmv_tgt_desc *tmp;
-
-			/* Fix the parent fid for striped dir */
-			tmp = lmv_locate_target_for_name(lmv, lsm, old,
-							 oldlen,
-							 &op_data->op_fid1,
-							 NULL);
-			if (IS_ERR(tmp))
-				return PTR_ERR(tmp);
+	parent_tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	if (IS_ERR(parent_tgt))
+		return PTR_ERR(parent_tgt);
+
+	if (lsm) {
+		u32 hash_type = lsm->lsm_md_hash_type;
+		u32 stripe_count = lsm->lsm_md_stripe_count;
+
+		/*
+		 * old stripes are appended after new stripes for migrating
+		 * directory.
+		 */
+		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION) {
+			hash_type = lsm->lsm_md_migrate_hash;
+			stripe_count -= lsm->lsm_md_migrate_offset;
 		}
 
-		rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
-		if (rc)
+		rc = lmv_name_to_stripe_index(hash_type, stripe_count, name,
+					      namelen);
+		if (rc < 0)
 			return rc;
-		src_tgt = lmv_find_target(lmv, &op_data->op_fid3);
-		if (IS_ERR(src_tgt))
-			return PTR_ERR(src_tgt);
 
-		target_exp = src_tgt->ltd_exp;
-	} else {
-		if (op_data->op_mea1) {
-			struct lmv_stripe_md *lsm = op_data->op_mea1;
+		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION)
+			rc += lsm->lsm_md_migrate_offset;
 
-			src_tgt = lmv_locate_target_for_name(lmv, lsm, old,
-							     oldlen,
-							     &op_data->op_fid1,
-							     &op_data->op_mds);
-		} else {
-			src_tgt = lmv_find_target(lmv, &op_data->op_fid1);
-		}
-		if (IS_ERR(src_tgt))
-			return PTR_ERR(src_tgt);
+		/* save it in fid4 temporarily for early cancel */
+		op_data->op_fid4 = lsm->lsm_md_oinfo[rc].lmo_fid;
+		sp_tgt = lmv_get_target(lmv, lsm->lsm_md_oinfo[rc].lmo_mds,
+					NULL);
+		if (IS_ERR(sp_tgt))
+			return PTR_ERR(sp_tgt);
 
-		if (op_data->op_mea2) {
-			struct lmv_stripe_md *lsm = op_data->op_mea2;
-
-			tgt_tgt = lmv_locate_target_for_name(lmv, lsm, new,
-							     newlen,
-							     &op_data->op_fid2,
-							     &op_data->op_mds);
-		} else {
-			tgt_tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		/*
+		 * if parent is being migrated too, fill op_fid2 with target
+		 * stripe fid, otherwise the target stripe is not created yet.
+		 */
+		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION) {
+			hash_type = lsm->lsm_md_hash_type &
+				    ~LMV_HASH_FLAG_MIGRATION;
+			stripe_count = lsm->lsm_md_migrate_offset;
+
+			rc = lmv_name_to_stripe_index(hash_type, stripe_count,
+						      name, namelen);
+			if (rc < 0)
+				return rc;
+
+			op_data->op_fid2 = lsm->lsm_md_oinfo[rc].lmo_fid;
+			tp_tgt = lmv_get_target(lmv,
+						lsm->lsm_md_oinfo[rc].lmo_mds,
+						NULL);
+			if (IS_ERR(tp_tgt))
+				return PTR_ERR(tp_tgt);
 		}
-		if (IS_ERR(tgt_tgt))
-			return PTR_ERR(tgt_tgt);
-
-		target_exp = tgt_tgt->ltd_exp;
+	} else {
+		sp_tgt = parent_tgt;
 	}
 
-	/*
-	 * LOOKUP lock on src child (fid3) should also be cancelled for
-	 * src_tgt in mdc_rename.
-	 */
-	op_data->op_flags |= MF_MDC_CANCEL_FID1 | MF_MDC_CANCEL_FID3;
+	child_tgt = lmv_find_target(lmv, &op_data->op_fid3);
+	if (IS_ERR(child_tgt))
+		return PTR_ERR(child_tgt);
 
-	/*
-	 * Cancel UPDATE locks on tgt parent (fid2), tgt_tgt is its
-	 * own target.
-	 */
-	rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
-			      LCK_EX, MDS_INODELOCK_UPDATE,
-			      MF_MDC_CANCEL_FID2);
+	rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
 	if (rc)
 		return rc;
+
 	/*
-	 * Cancel LOOKUP locks on source child (fid3) for parent tgt_tgt.
+	 * for directory, send migrate request to the MDT where the object will
+	 * be migrated to, because we can't create a striped directory remotely.
+	 *
+	 * otherwise, send to the MDT where source is located because regular
+	 * file may open lease.
+	 *
+	 * NB. if MDT doesn't support DIR_MIGRATE, send to source MDT too for
+	 * backward compatibility.
 	 */
-	if (fid_is_sane(&op_data->op_fid3)) {
-		struct lmv_tgt_desc *tgt;
-
-		tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	if (S_ISDIR(op_data->op_mode) &&
+	    (exp_connect_flags2(exp) & OBD_CONNECT2_DIR_MIGRATE)) {
+		tgt = lmv_find_target(lmv, &target_fid);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
+	} else {
+		tgt = child_tgt;
+	}
 
-		/* Cancel LOOKUP lock on its parent */
-		rc = lmv_early_cancel(exp, tgt, op_data, src_tgt->ltd_idx,
-				      LCK_EX, MDS_INODELOCK_LOOKUP,
-				      MF_MDC_CANCEL_FID3);
+	/* cancel UPDATE lock of parent master object */
+	rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
+	if (rc)
+		return rc;
+
+	/* cancel UPDATE lock of source parent */
+	if (sp_tgt != parent_tgt) {
+		/*
+		 * migrate RPC packs master object FID, because we can only pack
+		 * two FIDs in reint RPC, but MDS needs to know both source
+		 * parent and target parent, and it will obtain them from master
+		 * FID and LMV, the other FID in RPC is kept for target.
+		 *
+		 * since this FID is not passed to MDC, cancel it anyway.
+		 */
+		rc = lmv_early_cancel(exp, sp_tgt, op_data, -1, LCK_EX,
+				      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID4);
 		if (rc)
 			return rc;
 
-		rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
-				      LCK_EX, MDS_INODELOCK_ELC,
+		op_data->op_flags &= ~MF_MDC_CANCEL_FID4;
+	}
+	op_data->op_fid4 = target_fid;
+
+	/* cancel UPDATE locks of target parent */
+	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID2);
+	if (rc)
+		return rc;
+
+	/* cancel LOOKUP lock of source if source is remote object */
+	if (child_tgt != sp_tgt) {
+		rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_idx,
+				      LCK_EX, MDS_INODELOCK_LOOKUP,
 				      MF_MDC_CANCEL_FID3);
 		if (rc)
 			return rc;
 	}
 
-retry_rename:
+	/* cancel ELC locks of source */
+	rc = lmv_early_cancel(exp, child_tgt, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_ELC, MF_MDC_CANCEL_FID3);
+	if (rc)
+		return rc;
+
+	rc = md_rename(tgt->ltd_exp, op_data, name, namelen, NULL, 0, request);
+
+	return rc;
+}
+
+static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
+		      const char *old, size_t oldlen,
+		      const char *new, size_t newlen,
+		      struct ptlrpc_request **request)
+{
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct lmv_tgt_desc *sp_tgt;
+	struct lmv_tgt_desc *tp_tgt = NULL;
+	struct lmv_tgt_desc *tgt;
+	struct mdt_body *body;
+	int rc;
+
+	LASSERT(oldlen != 0);
+
+	if (op_data->op_cli_flags & CLI_MIGRATE) {
+		rc = lmv_migrate(exp, op_data, old, oldlen, request);
+		return rc;
+	}
+
+	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
+	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
+	op_data->op_cap = current_cap();
+
+	CDEBUG(D_INODE, "RENAME "DFID"/%.*s to "DFID"/%.*s\n",
+		PFID(&op_data->op_fid1), (int)oldlen, old,
+		PFID(&op_data->op_fid2), (int)newlen, new);
+
+	if (lsm)
+		sp_tgt = lmv_locate_target_for_name(lmv, lsm, old, oldlen,
+						    &op_data->op_fid1,
+						    &op_data->op_mds);
+	else
+		sp_tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	if (IS_ERR(sp_tgt))
+		return PTR_ERR(sp_tgt);
+
+	lsm = op_data->op_mea2;
+	if (lsm)
+		tp_tgt = lmv_locate_target_for_name(lmv, lsm, new, newlen,
+						    &op_data->op_fid2,
+						    &op_data->op_mds);
+	else
+		tp_tgt = lmv_find_target(lmv, &op_data->op_fid2);
+	if (IS_ERR(tp_tgt))
+		return PTR_ERR(tp_tgt);
+
 	/*
-	 * Cancel all the locks on tgt child (fid4).
+	 * Since the target child might be destroyed, and it might
+	 * become orphan, and we can only check orphan on the local
+	 * MDT right now, so we send rename request to the MDT where
+	 * target child is located. If target child does not exist,
+	 * then it will send the request to the target parent
 	 */
 	if (fid_is_sane(&op_data->op_fid4)) {
-		struct lmv_tgt_desc *tgt;
-
-		rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
-				      LCK_EX, MDS_INODELOCK_ELC,
-				      MF_MDC_CANCEL_FID4);
-		if (rc)
-			return rc;
-
 		tgt = lmv_find_target(lmv, &op_data->op_fid4);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
+	} else {
+		tgt = tp_tgt;
+	}
 
-		/*
-		 * Since the target child might be destroyed, and it might
-		 * become orphan, and we can only check orphan on the local
-		 * MDT right now, so we send rename request to the MDT where
-		 * target child is located. If target child does not exist,
-		 * then it will send the request to the target parent
-		 */
-		target_exp = tgt->ltd_exp;
+	op_data->op_flags |= MF_MDC_CANCEL_FID4;
+
+	/* cancel UPDATE locks of source parent */
+	rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
+	if (rc != 0)
+		return rc;
+
+	/* cancel UPDATE locks of target parent */
+	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID2);
+	if (rc != 0)
+		return rc;
+
+	if (fid_is_sane(&op_data->op_fid3)) {
+		struct lmv_tgt_desc *src_tgt;
+
+		src_tgt = lmv_find_target(lmv, &op_data->op_fid3);
+		if (IS_ERR(src_tgt))
+			return PTR_ERR(src_tgt);
+
+		/* cancel LOOKUP lock of source on source parent */
+		if (src_tgt != sp_tgt) {
+			rc = lmv_early_cancel(exp, sp_tgt, op_data,
+					      tgt->ltd_idx, LCK_EX,
+					      MDS_INODELOCK_LOOKUP,
+					      MF_MDC_CANCEL_FID3);
+			if (rc != 0)
+				return rc;
+		}
+
+		/* cancel ELC locks of source */
+		rc = lmv_early_cancel(exp, src_tgt, op_data, tgt->ltd_idx,
+				      LCK_EX, MDS_INODELOCK_ELC,
+				      MF_MDC_CANCEL_FID3);
+		if (rc != 0)
+			return rc;
+	}
+
+retry_rename:
+	if (fid_is_sane(&op_data->op_fid4)) {
+		/* cancel LOOKUP lock of target on target parent */
+		if (tgt != tp_tgt) {
+			rc = lmv_early_cancel(exp, tp_tgt, op_data,
+					      tgt->ltd_idx, LCK_EX,
+					      MDS_INODELOCK_LOOKUP,
+					      MF_MDC_CANCEL_FID4);
+			if (rc != 0)
+				return rc;
+		}
 	}
 
-	rc = md_rename(target_exp, op_data, old, oldlen, new, newlen, request);
+	rc = md_rename(tgt->ltd_exp, op_data, old, oldlen, new, newlen,
+		       request);
 	if (rc && rc != -EXDEV)
 		return rc;
 
@@ -2001,6 +2131,11 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fid4 = body->mbo_fid1;
 	ptlrpc_req_finished(*request);
 	*request = NULL;
+
+	tgt = lmv_find_target(lmv, &op_data->op_fid4);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
 	goto retry_rename;
 }
 
@@ -2743,6 +2878,8 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	else
 		lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
 	lsm->lsm_md_layout_version = le32_to_cpu(lmm1->lmv_layout_version);
+	lsm->lsm_md_migrate_offset = le32_to_cpu(lmm1->lmv_migrate_offset);
+	lsm->lsm_md_migrate_hash = le32_to_cpu(lmm1->lmv_migrate_hash);
 	cplen = strlcpy(lsm->lsm_md_pool_name, lmm1->lmv_pool_name,
 			sizeof(lsm->lsm_md_pool_name));
 
@@ -2750,7 +2887,7 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 		return -E2BIG;
 
 	CDEBUG(D_INFO,
-	       "unpack lsm count %d, master %d hash_type %d layout_version %d\n",
+	       "unpack lsm count %d, master %d hash_type %#x  layout_version %d\n",
 	       lsm->lsm_md_stripe_count, lsm->lsm_md_master_mdt_index,
 	       lsm->lsm_md_hash_type, lsm->lsm_md_layout_version);
 
@@ -2783,16 +2920,8 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	if (lsm && !lmm) {
 		int i;
 
-		for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
-			/*
-			 * For migrating inode, the master stripe and master
-			 * object will be the same, so do not need iput, see
-			 * ll_update_lsm_md
-			 */
-			if (!(lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION &&
-			      !i))
-				iput(lsm->lsm_md_oinfo[i].lmo_root);
-		}
+		for (i = 0; i < lsm->lsm_md_stripe_count; i++)
+			iput(lsm->lsm_md_oinfo[i].lmo_root);
 
 		kvfree(lsm);
 		*lsmp = NULL;
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 6cfa79c..b4af9778 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -63,6 +63,8 @@ void mdc_file_secctx_pack(struct ptlrpc_request *req,
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const char *old, size_t oldlen,
 		     const char *new, size_t newlen);
+void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+			const char *name, size_t namelen);
 void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 
 /* mdc/mdc_locks.c */
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 1d38574..5b1691e 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -489,8 +489,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
-	rec->rn_opcode = op_data->op_cli_flags & CLI_MIGRATE ?
-			 REINT_MIGRATE : REINT_RENAME;
+	rec->rn_opcode = REINT_RENAME;
 	rec->rn_fsuid = op_data->op_fsuid;
 	rec->rn_fsgid = op_data->op_fsgid;
 	rec->rn_cap = op_data->op_cap.cap[0];
@@ -506,22 +505,42 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	if (new)
 		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
+}
 
-	if (op_data->op_cli_flags & CLI_MIGRATE) {
-		char *tmp;
+void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
+		      const char *name, size_t namelen)
+{
+	struct mdt_rec_rename *rec;
+	char *ea;
 
-		if (op_data->op_bias & MDS_CLOSE_MIGRATE) {
-			struct mdt_ioepoch *epoch;
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_rename));
+	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
-			mdc_close_intent_pack(req, op_data);
-			epoch = req_capsule_client_get(&req->rq_pill,
-							&RMF_MDT_EPOCH);
-			mdc_ioepoch_pack(epoch, op_data);
-		}
+	rec->rn_opcode	 = REINT_MIGRATE;
+	rec->rn_fsuid	 = op_data->op_fsuid;
+	rec->rn_fsgid	 = op_data->op_fsgid;
+	rec->rn_cap	 = op_data->op_cap.cap[0];
+	rec->rn_suppgid1 = op_data->op_suppgids[0];
+	rec->rn_suppgid2 = op_data->op_suppgids[1];
+	rec->rn_fid1	 = op_data->op_fid1;
+	rec->rn_fid2	 = op_data->op_fid4;
+	rec->rn_time	 = op_data->op_mod_time;
+	rec->rn_mode	 = op_data->op_mode;
+	rec->rn_bias	 = op_data->op_bias;
 
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
-		memcpy(tmp, op_data->op_data, op_data->op_data_size);
+	mdc_pack_name(req, &RMF_NAME, name, namelen);
+
+	if (op_data->op_bias & MDS_CLOSE_MIGRATE) {
+		struct mdt_ioepoch *epoch;
+
+		mdc_close_intent_pack(req, op_data);
+		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
+		mdc_ioepoch_pack(epoch, op_data);
 	}
+
+	ea = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
+	memcpy(ea, op_data->op_data, op_data->op_data_size);
 }
 
 void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 030c247..355cee1 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -403,7 +403,10 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 	if (exp_connect_cancelset(exp) && req)
 		ldlm_cli_cancel_list(&cancels, count, req, 0);
 
-	mdc_rename_pack(req, op_data, old, oldlen, new, newlen);
+	if (op_data->op_cli_flags & CLI_MIGRATE)
+		mdc_migrate_pack(req, op_data, old, oldlen);
+	else
+		mdc_rename_pack(req, op_data, old, oldlen, new, newlen);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obd->u.cli.cl_default_mds_easize);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 30083c2..4095767 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1627,13 +1627,17 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_layout_version));
 	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_layout_version) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_layout_version));
-	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding1) == 20, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding1));
-	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding1) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding1));
-	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding2) == 24, "found %lld\n",
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_migrate_offset) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_migrate_offset));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_migrate_offset) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_migrate_offset));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_migrate_hash) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_migrate_hash));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_migrate_hash) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_migrate_hash));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding2) == 28, "found %lld\n",
 		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding2));
-	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding2) == 8, "found %lld\n",
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding2) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding2));
 	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding3) == 32, "found %lld\n",
 		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding3));
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 7f857be..522bd52 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1941,9 +1941,19 @@ struct lmv_mds_md_v1 {
 					 * be used to mark the object status,
 					 * for example migrating or dead.
 					 */
-	__u32 lmv_layout_version;	/* Used for directory restriping */
-	__u32 lmv_padding1;
-	__u64 lmv_padding2;
+	__u32 lmv_layout_version;	/* increased each time layout changed,
+					 * by directory migration, restripe
+					 * and LFSCK.
+					 */
+	__u32 lmv_migrate_offset;	/* once this is set, it means this
+					 * directory is been migrated, stripes
+					 * before this offset belong to target,
+					 * from this to source.
+					 */
+	__u32 lmv_migrate_hash;		/* hash type of source stripes of
+					 * migrating directory
+					 */
+	__u32 lmv_padding2;
 	__u64 lmv_padding3;
 	char lmv_pool_name[LOV_MAXPOOLNAME + 1];/* pool name */
 	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
-- 
1.8.3.1
