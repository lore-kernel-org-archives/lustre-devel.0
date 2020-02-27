From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:00 -0500
Subject: [lustre-devel] [PATCH 312/622] lustre: ptlrpc: intent_getattr
 fetches default LMV
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-313-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Intent_getattr fetches default LMV, and caches it on client,
which will be used in subdir creation.

* Add RMF_DEFAULT_MDT_MD in intent_getattr reply.
* Save default LMV in ll_inode_info->lli_default_lsm_md, and
  replace lli_def_stripe_offset with it.
* take LOOKUP lock on default LMV setting to let client update
  cached default LMV.
* improve mdt_object_striped() to read from bottom device
  to avoid reading stripe FIDs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11213
Lustre-commit: 55ca00c3d1cd ("LU-11213 ptlrpc: intent_getattr fetches default LMV")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34802
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h        | 13 +++++--
 fs/lustre/include/lustre_req_layout.h |  1 +
 fs/lustre/include/obd.h               | 14 +++++--
 fs/lustre/llite/llite_internal.h      | 20 ++--------
 fs/lustre/llite/llite_lib.c           | 72 ++++++++++++++++++++++++++++++++---
 fs/lustre/llite/namei.c               | 56 +++++++++++++++++++--------
 fs/lustre/lmv/lmv_obd.c               | 41 +++++++++++++++-----
 fs/lustre/mdc/mdc_locks.c             | 10 +++--
 fs/lustre/mdc/mdc_request.c           | 41 ++++++++++++++++----
 fs/lustre/ptlrpc/layout.c             |  8 +++-
 10 files changed, 210 insertions(+), 66 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index cef315d..c88e4b5 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -72,10 +72,12 @@ struct lmv_stripe_md {
 	    strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name) != 0)
 		return false;
 
-	for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
-		if (!lu_fid_eq(&lsm1->lsm_md_oinfo[idx].lmo_fid,
-			       &lsm2->lsm_md_oinfo[idx].lmo_fid))
-			return false;
+	if (lsm1->lsm_md_magic == LMV_MAGIC_V1) {
+		for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
+			if (!lu_fid_eq(&lsm1->lsm_md_oinfo[idx].lmo_fid,
+				       &lsm2->lsm_md_oinfo[idx].lmo_fid))
+				return false;
+		}
 	}
 
 	return true;
@@ -92,6 +94,9 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 	       lsm->lsm_md_layout_version, lsm->lsm_md_migrate_offset,
 	       lsm->lsm_md_migrate_hash, lsm->lsm_md_pool_name);
 
+	if (lsm->lsm_md_magic != LMV_MAGIC_V1)
+		return;
+
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++)
 		CDEBUG(mask, "stripe[%d] "DFID"\n",
 		       i, PFID(&lsm->lsm_md_oinfo[i].lmo_fid));
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 378f0b6..dca4ef4 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -249,6 +249,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_LDLM_INTENT;
 extern struct req_msg_field RMF_LAYOUT_INTENT;
 extern struct req_msg_field RMF_MDT_MD;
+extern struct req_msg_field RMF_DEFAULT_MDT_MD;
 extern struct req_msg_field RMF_REC_REINT;
 extern struct req_msg_field RMF_EADATA;
 extern struct req_msg_field RMF_EAVALS;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 996211a..fb77df7 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -729,6 +729,14 @@ enum md_cli_flags {
 	CLI_MIGRATE		= BIT(4),
 };
 
+enum md_op_code {
+	LUSTRE_OPC_MKDIR	= 0,
+	LUSTRE_OPC_SYMLINK	= 1,
+	LUSTRE_OPC_MKNOD	= 2,
+	LUSTRE_OPC_CREATE	= 3,
+	LUSTRE_OPC_ANY		= 5,
+};
+
 /**
  * GETXATTR is not included as only a couple of fields in the reply body
  * is filled, but not FID which is needed for common intent handling in
@@ -746,6 +754,7 @@ struct md_op_data {
 	struct lu_fid		op_fid4; /* to the operation locks. */
 	u32			op_mds;  /* what mds server open will go to */
 	u32			op_mode;
+	enum md_op_code		op_code;
 	struct lustre_handle	op_open_handle;
 	s64			op_mod_time;
 	const char	       *op_name;
@@ -754,6 +763,7 @@ struct md_op_data {
 	struct rw_semaphore	*op_mea2_sem;
 	struct lmv_stripe_md   *op_mea1;
 	struct lmv_stripe_md   *op_mea2;
+	struct lmv_stripe_md	*op_default_mea1;	/* default LMV */
 	u32			op_suppgids[2];
 	u32			op_fsuid;
 	u32			op_fsgid;
@@ -791,9 +801,6 @@ struct md_op_data {
 	void		       *op_file_secctx;
 	u32			op_file_secctx_size;
 
-	/* default stripe offset */
-	u32			op_default_stripe_offset;
-
 	u32			op_projid;
 
 	u16			op_mirror_id;
@@ -933,6 +940,7 @@ struct lustre_md {
 		struct lmv_stripe_md	*lmv;
 		struct lmv_foreign_md   *lfm;
 	};
+	struct lmv_stripe_md    *default_lmv;
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	struct posix_acl		*posix_acl;
 #endif
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index eb7e0dc..687d504 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -172,13 +172,8 @@ struct ll_inode_info {
 			struct rw_semaphore		lli_lsm_sem;
 			/* directory stripe information */
 			struct lmv_stripe_md	       *lli_lsm_md;
-			/* default directory stripe offset.  This is extracted
-			 * from the "dmv" xattr in order to decide which MDT to
-			 * create a subdirectory on.  The MDS itself fetches
-			 * "dmv" and gets the rest of the default layout itself
-			 * (count, hash, etc).
-			 */
-			u32				lli_def_stripe_offset;
+			/* directory default LMV */
+			struct lmv_stripe_md		*lli_default_lsm_md;
 		};
 
 		/* for non-directory */
@@ -921,19 +916,12 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
 int ll_set_default_mdsize(struct ll_sb_info *sbi, int default_mdsize);
 
-enum {
-	LUSTRE_OPC_MKDIR	= 0,
-	LUSTRE_OPC_SYMLINK	= 1,
-	LUSTRE_OPC_MKNOD	= 2,
-	LUSTRE_OPC_CREATE	= 3,
-	LUSTRE_OPC_ANY		= 5,
-};
-
 void ll_unlock_md_op_lsm(struct md_op_data *op_data);
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, size_t namelen,
-				      u32 mode, u32 opc, void *data);
+				      u32 mode, enum md_op_code opc,
+				      void *data);
 void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e6ac16f..bd17ba1 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -939,7 +939,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 		spin_lock_init(&lli->lli_sa_lock);
 		lli->lli_opendir_pid = 0;
 		lli->lli_sa_enabled = 0;
-		lli->lli_def_stripe_offset = -1;
 		init_rwsem(&lli->lli_lsm_sem);
 	} else {
 		mutex_init(&lli->lli_size_mutex);
@@ -1216,6 +1215,11 @@ void ll_dir_clear_lsm_md(struct inode *inode)
 		lmv_free_memmd(lli->lli_lsm_md);
 		lli->lli_lsm_md = NULL;
 	}
+
+	if (lli->lli_default_lsm_md) {
+		lmv_free_memmd(lli->lli_default_lsm_md);
+		lli->lli_default_lsm_md = NULL;
+	}
 }
 
 static struct inode *ll_iget_anon_dir(struct super_block *sb,
@@ -1314,6 +1318,46 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 	return 0;
 }
 
+static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+
+	if (!md->default_lmv) {
+		/* clear default lsm */
+		if (lli->lli_default_lsm_md) {
+			down_write(&lli->lli_lsm_sem);
+			if (lli->lli_default_lsm_md) {
+				lmv_free_memmd(lli->lli_default_lsm_md);
+				lli->lli_default_lsm_md = NULL;
+			}
+			up_write(&lli->lli_lsm_sem);
+		}
+	} else if (lli->lli_default_lsm_md) {
+		/* update default lsm if it changes */
+		down_read(&lli->lli_lsm_sem);
+		if (lli->lli_default_lsm_md &&
+		    !lsm_md_eq(lli->lli_default_lsm_md, md->default_lmv)) {
+			up_read(&lli->lli_lsm_sem);
+			down_write(&lli->lli_lsm_sem);
+			if (lli->lli_default_lsm_md)
+				lmv_free_memmd(lli->lli_default_lsm_md);
+			lli->lli_default_lsm_md = md->default_lmv;
+			lsm_md_dump(D_INODE, md->default_lmv);
+			md->default_lmv = NULL;
+			up_write(&lli->lli_lsm_sem);
+		} else {
+			up_read(&lli->lli_lsm_sem);
+		}
+	} else {
+		/* init default lsm */
+		down_write(&lli->lli_lsm_sem);
+		lli->lli_default_lsm_md = md->default_lmv;
+		lsm_md_dump(D_INODE, md->default_lmv);
+		md->default_lmv = NULL;
+		up_write(&lli->lli_lsm_sem);
+	}
+}
+
 static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1324,6 +1368,10 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	CDEBUG(D_INODE, "update lsm %p of " DFID "\n", lli->lli_lsm_md,
 	       PFID(ll_inode2fid(inode)));
 
+	/* update default LMV */
+	if (md->default_lmv)
+		ll_update_default_lsm_md(inode, md);
+
 	/*
 	 * no striped information from request, lustre_md from req does not
 	 * include stripeEA, see ll_md_setattr()
@@ -2322,6 +2370,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 {
 	struct ll_sb_info *sbi = NULL;
 	struct lustre_md md = { NULL };
+	bool default_lmv_deleted = false;
 	int rc;
 
 	LASSERT(*inode || sb);
@@ -2331,6 +2380,15 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	if (rc)
 		goto out;
 
+	/*
+	 * clear default_lmv only if intent_getattr reply doesn't contain it.
+	 * but it needs to be done after iget, check this early because
+	 * ll_update_lsm_md() may change md.
+	 */
+	if (it && (it->it_op & (IT_LOOKUP | IT_GETATTR)) &&
+	    S_ISDIR(md.body->mbo_mode) && !md.default_lmv)
+		default_lmv_deleted = true;
+
 	if (*inode) {
 		rc = ll_update_inode(*inode, &md);
 		if (rc)
@@ -2396,9 +2454,12 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		LDLM_LOCK_PUT(lock);
 	}
 
+	if (default_lmv_deleted)
+		ll_update_default_lsm_md(*inode, &md);
 out:
 	/* cleanup will be done if necessary */
 	md_free_lustre_md(sbi->ll_md_exp, &md);
+
 	if (rc != 0 && it && it->it_op & IT_OPEN)
 		ll_open_cleanup(sb ? sb : (*inode)->i_sb, req);
 
@@ -2481,7 +2542,8 @@ void ll_unlock_md_op_lsm(struct md_op_data *op_data)
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, size_t namelen,
-				      u32 mode, u32 opc, void *data)
+				      u32 mode, enum md_op_code opc,
+				      void *data)
 {
 	if (!name) {
 		/* Do not reuse namelen for something else. */
@@ -2503,15 +2565,13 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 	ll_i2gids(op_data->op_suppgids, i1, i2);
 	op_data->op_fid1 = *ll_inode2fid(i1);
-	op_data->op_default_stripe_offset = -1;
+	op_data->op_code = opc;
 
 	if (S_ISDIR(i1->i_mode)) {
 		down_read(&ll_i2info(i1)->lli_lsm_sem);
 		op_data->op_mea1_sem = &ll_i2info(i1)->lli_lsm_sem;
 		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
-		if (opc == LUSTRE_OPC_MKDIR)
-			op_data->op_default_stripe_offset =
-				ll_i2info(i1)->lli_def_stripe_offset;
+		op_data->op_default_mea1 = ll_i2info(i1)->lli_default_lsm_md;
 	}
 
 	if (i2) {
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 3c796bd..1aaf184 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -246,8 +246,6 @@ void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 	}
 
 	if (bits & MDS_INODELOCK_XATTR) {
-		if (S_ISDIR(inode->i_mode))
-			ll_i2info(inode)->lli_def_stripe_offset = -1;
 		ll_xattr_cache_destroy(inode);
 		bits &= ~MDS_INODELOCK_XATTR;
 	}
@@ -1155,14 +1153,10 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
-	if (err < 0 && err != -EREMOTE)
-		goto err_exit;
-
+#if OBD_OCD_VERSION(2, 14, 58, 0) > LUSTRE_VERSION_CODE
 	/*
-	 * If the client doesn't know where to create a subdirectory (or
-	 * in case of a race that sends the RPC to the wrong MDS), the
-	 * MDS will return -EREMOTE and the client will fetch the layout
-	 * of the directory, then create the directory on the right MDT.
+	 * server < 2.12.58 doesn't pack default LMV in intent_getattr reply,
+	 * fetch default LMV here.
 	 */
 	if (unlikely(err == -EREMOTE)) {
 		struct ll_inode_info *lli = ll_i2info(dir);
@@ -1174,26 +1168,58 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 		err2 = ll_dir_getstripe(dir, (void **)&lum, &lumsize, &request,
 					OBD_MD_DEFAULT_MEA);
+		ll_finish_md_op_data(op_data);
+		op_data = NULL;
 		if (!err2) {
-			/* Update stripe_offset and retry */
-			lli->lli_def_stripe_offset = lum->lum_stripe_offset;
-		} else if (err2 == -ENODATA &&
-			   lli->lli_def_stripe_offset != -1) {
+			struct lustre_md md = { NULL };
+
+			md.body = req_capsule_server_get(&request->rq_pill,
+							 &RMF_MDT_BODY);
+			if (!md.body) {
+				err = -EPROTO;
+				goto err_exit;
+			}
+
+			md.default_lmv = kzalloc(sizeof(*md.default_lmv),
+						 GFP_NOFS);
+			if (!md.default_lmv) {
+				err = -ENOMEM;
+				goto err_exit;
+			}
+
+			md.default_lmv->lsm_md_magic = lum->lum_magic;
+			md.default_lmv->lsm_md_stripe_count =
+				lum->lum_stripe_count;
+			md.default_lmv->lsm_md_master_mdt_index =
+				lum->lum_stripe_offset;
+			md.default_lmv->lsm_md_hash_type = lum->lum_hash_type;
+
+			err = ll_update_inode(dir, &md);
+			md_free_lustre_md(sbi->ll_md_exp, &md);
+			if (err)
+				goto err_exit;
+		} else if (err2 == -ENODATA && lli->lli_default_lsm_md) {
 			/*
 			 * If there are no default stripe EA on the MDT, but the
 			 * client has default stripe, then it probably means
 			 * default stripe EA has just been deleted.
 			 */
-			lli->lli_def_stripe_offset = -1;
+			down_write(&lli->lli_lsm_sem);
+			kfree(lli->lli_default_lsm_md);
+			lli->lli_default_lsm_md = NULL;
+			up_write(&lli->lli_lsm_sem);
 		} else {
 			goto err_exit;
 		}
 
 		ptlrpc_req_finished(request);
 		request = NULL;
-		ll_finish_md_op_data(op_data);
 		goto again;
 	}
+#endif
+
+	if (err < 0)
+		goto err_exit;
 
 	ll_update_times(request, dir);
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 4b5bd36..48cd41a 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1176,13 +1176,12 @@ static int lmv_placement_policy(struct obd_device *obd,
 	    le32_to_cpu(lum->lum_magic != LMV_MAGIC_FOREIGN) &&
 	    le32_to_cpu(lum->lum_stripe_offset) != (u32)-1) {
 		*mds = le32_to_cpu(lum->lum_stripe_offset);
-	} else if (op_data->op_default_stripe_offset != (u32)-1) {
-		*mds = op_data->op_default_stripe_offset;
+	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
+		   op_data->op_default_mea1 &&
+		   op_data->op_default_mea1->lsm_md_master_mdt_index !=
+			 (u32)-1) {
+		*mds = op_data->op_default_mea1->lsm_md_master_mdt_index;
 		op_data->op_mds = *mds;
-		/* Correct the stripe offset in lum */
-		if (lum &&
-		    le32_to_cpu(lum->lum_magic != LMV_MAGIC_FOREIGN))
-			lum->lum_stripe_offset = cpu_to_le32(*mds);
 	} else {
 		*mds = op_data->op_mds;
 	}
@@ -2981,6 +2980,18 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	return rc;
 }
 
+static inline int lmv_unpack_user_md(struct obd_export *exp,
+				     struct lmv_stripe_md *lsm,
+				     const struct lmv_user_md *lmu)
+{
+	lsm->lsm_md_magic = le32_to_cpu(lmu->lum_magic);
+	lsm->lsm_md_stripe_count = le32_to_cpu(lmu->lum_stripe_count);
+	lsm->lsm_md_master_mdt_index = le32_to_cpu(lmu->lum_stripe_offset);
+	lsm->lsm_md_hash_type = le32_to_cpu(lmu->lum_hash_type);
+
+	return 0;
+}
+
 static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 			const union lmv_mds_md *lmm, size_t lmm_size)
 {
@@ -3005,9 +3016,14 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 			return 0;
 		}
 
-		for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
-			if (lsm->lsm_md_oinfo[i].lmo_root)
-				iput(lsm->lsm_md_oinfo[i].lmo_root);
+		if (lsm->lsm_md_magic == LMV_MAGIC) {
+			for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+				if (lsm->lsm_md_oinfo[i].lmo_root)
+					iput(lsm->lsm_md_oinfo[i].lmo_root);
+			}
+			lsm_size = lmv_stripe_md_size(lsm->lsm_md_stripe_count);
+		} else {
+			lsm_size = lmv_stripe_md_size(0);
 		}
 		kvfree(lsm);
 		*lsmp = NULL;
@@ -3066,6 +3082,9 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	case LMV_MAGIC_V1:
 		rc = lmv_unpack_md_v1(exp, lsm, &lmm->lmv_md_v1);
 		break;
+	case LMV_USER_MAGIC:
+		rc = lmv_unpack_user_md(exp, lsm, &lmm->lmv_user_md);
+		break;
 	default:
 		CERROR("%s: unrecognized magic %x\n", exp->exp_obd->obd_name,
 		       le32_to_cpu(lmm->lmv_magic));
@@ -3190,6 +3209,10 @@ static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
+	if (md->default_lmv) {
+		lmv_free_memmd(md->default_lmv);
+		md->default_lmv = NULL;
+	}
 	if (md->lmv) {
 		lmv_free_memmd(md->lmv);
 		md->lmv = NULL;
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index f6273ef..cf6bc9d 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -504,13 +504,13 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 {
 	struct ptlrpc_request *req;
 	struct obd_device *obddev = class_exp2obd(exp);
-	u64 valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE |
-		    OBD_MD_FLMODEASIZE | OBD_MD_FLDIREA |
-		    OBD_MD_MEA | OBD_MD_FLACL;
+	u64 valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE | OBD_MD_FLMODEASIZE |
+		    OBD_MD_FLDIREA | OBD_MD_MEA | OBD_MD_FLACL |
+		    OBD_MD_DEFAULT_MEA;
 	struct ldlm_intent *lit;
-	int rc;
 	u32 easize;
 	bool have_secctx = false;
+	int rc;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_GETATTR);
@@ -549,6 +549,8 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, easize);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
+	req_capsule_set_size(&req->rq_pill, &RMF_DEFAULT_MDT_MD, RCL_SERVER,
+			     sizeof(struct lmv_user_md));
 
 	if (have_secctx) {
 		char *secctx_name;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 57da3c3..c834891 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -594,13 +594,13 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			goto out;
 		}
 
-		lmv_size = md->body->mbo_eadatasize;
-		if (!lmv_size) {
-			CDEBUG(D_INFO,
-			       "OBD_MD_FLDIREA is set, but eadatasize 0\n");
-			return -EPROTO;
-		}
 		if (md->body->mbo_valid & OBD_MD_MEA) {
+			lmv_size = md->body->mbo_eadatasize;
+			if (!lmv_size) {
+				CDEBUG(D_INFO,
+				       "OBD_MD_FLDIREA is set, but eadatasize 0\n");
+				return -EPROTO;
+			}
 			lmv = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
 							   lmv_size);
 			if (!lmv) {
@@ -612,7 +612,7 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			if (rc < 0)
 				goto out;
 
-			if (rc < (typeof(rc))sizeof(*md->lmv)) {
+			if (rc < (int)sizeof(*md->lmv)) {
 				struct lmv_foreign_md *lfm = md->lfm;
 
 				/* short (< sizeof(struct lmv_stripe_md))
@@ -620,13 +620,38 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 				 */
 				if (lfm->lfm_magic != LMV_MAGIC_FOREIGN) {
 					CDEBUG(D_INFO,
-					       "size too small: rc < sizeof(*md->lmv) (%d < %d)\n",
+					       "lmv size too small: %d < %d\n",
 					       rc, (int)sizeof(*md->lmv));
 					rc = -EPROTO;
 					goto out;
 				}
 			}
 		}
+
+		/* since 2.12.58 intent_getattr fetches default LMV */
+		if (md->body->mbo_valid & OBD_MD_DEFAULT_MEA) {
+			lmv_size = sizeof(struct lmv_user_md);
+			lmv = req_capsule_server_sized_get(pill,
+							   &RMF_DEFAULT_MDT_MD,
+							   lmv_size);
+			if (!lmv) {
+				rc = -EPROTO;
+				goto out;
+			}
+
+			rc = md_unpackmd(md_exp, &md->default_lmv, lmv,
+					 lmv_size);
+			if (rc < 0)
+				goto out;
+
+			if (rc < (int)sizeof(*md->default_lmv)) {
+				CDEBUG(D_INFO,
+				       "default lmv size too small: %d < %d\n",
+				       rc, (int)sizeof(*md->lmv));
+				rc = -EPROTO;
+				goto out;
+			}
+		}
 	}
 	rc = 0;
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 9a676ae..c10b593 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -446,7 +446,8 @@
 	&RMF_MDT_MD,
 	&RMF_ACL,
 	&RMF_CAPA1,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_DEFAULT_MDT_MD
 };
 
 static const struct req_msg_field *ldlm_intent_create_client[] = {
@@ -1016,6 +1017,11 @@ struct req_msg_field RMF_MDT_MD =
 	DEFINE_MSGF("mdt_md", RMF_F_NO_SIZE_CHECK, MIN_MD_SIZE, NULL, NULL);
 EXPORT_SYMBOL(RMF_MDT_MD);
 
+struct req_msg_field RMF_DEFAULT_MDT_MD =
+	DEFINE_MSGF("default_mdt_md", RMF_F_NO_SIZE_CHECK, MIN_MD_SIZE, NULL,
+		    NULL);
+EXPORT_SYMBOL(RMF_DEFAULT_MDT_MD);
+
 struct req_msg_field RMF_REC_REINT =
 	DEFINE_MSGF("rec_reint", 0, sizeof(struct mdt_rec_reint),
 		    lustre_swab_mdt_rec_reint, NULL);
-- 
1.8.3.1
