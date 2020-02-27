From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:46 -0500
Subject: [lustre-devel] [PATCH 118/622] lustre: lmv: support accessing
 migrating directory
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-119-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Migrating directory contains stripes of both old and new layout, and
its sub files may be located on either one. To avoid race between
access and new creations, there are 4 rules to access migrating
directory:
1. always create new file under new layout.
2. any operation that tries to create new file under old layout will
   be rejected, e.g., 'mv a <migrating_dir>/b', if b exists and is
   under old layout, this rename should fail with -EBUSY.
3. operations that access file by name should try old layout first,
   if file doesn't exist, then it will retry new layout, such
   operations include: lookup, getattr_name, unlink, open-by-name,
   link, rename.
4. according to rule 1, open(O_CREAT | O_EXCL) and create() will
   create new file under new layout, but they should check existing
   file in one transaction, however this can't be done for old
   layout, so check existing file under old layout on client side,
   then issue the open/create request to new layout.

Disable sanity 230d for ZFS backend because it will trigger lots of
sync, which may cause system hung.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4684
Lustre-commit: 976b609abcdf ("LU-4684 lmv: support accessing migrating directory")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31504
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h      |  12 ++
 fs/lustre/lmv/lmv_intent.c   | 132 +++++++------
 fs/lustre/lmv/lmv_internal.h |  75 +++++--
 fs/lustre/lmv/lmv_obd.c      | 453 ++++++++++++++++++++++---------------------
 4 files changed, 381 insertions(+), 291 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 9286755..b404391 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -787,6 +787,18 @@ struct md_op_data {
 	u32			op_projid;
 
 	u16			op_mirror_id;
+
+	/*
+	 * used to access migrating dir: if it's set, assume migration is
+	 * finished, use the new layout to access dir, otherwise use old layout.
+	 * By default it's not set, because new files are created under new
+	 * layout, if we can't find file with name under both old and new
+	 * layout, we are sure file with name doesn't exist, but in reverse
+	 * order there may be a race with creation by others.
+	 */
+	bool			op_post_migrate;
+	/* used to access dir with bash hash */
+	u32			op_stripe_index;
 };
 
 struct md_callback {
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 355a2af..3f51032 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -191,7 +191,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		op_data->op_fid1 = fid;
 		op_data->op_fid2 = fid;
 
-		tgt = lmv_locate_mds(lmv, op_data, &fid);
+		tgt = lmv_get_target(lmv, lsm->lsm_md_oinfo[i].lmo_mds, NULL);
 		if (IS_ERR(tgt)) {
 			rc = PTR_ERR(tgt);
 			goto cleanup;
@@ -269,8 +269,52 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 	struct mdt_body	*body;
+	u64 flags = it->it_flags;
 	int rc;
 
+	if ((it->it_op & IT_CREAT) && !(flags & MDS_OPEN_BY_FID)) {
+		/* don't allow create under dir with bad hash */
+		if (lmv_is_dir_bad_hash(op_data->op_mea1))
+			return -EBADF;
+
+		if (lmv_is_dir_migrating(op_data->op_mea1)) {
+			if (flags & O_EXCL) {
+				/*
+				 * open(O_CREAT | O_EXCL) needs to check
+				 * existing name, which should be done on both
+				 * old and new layout, to avoid creating new
+				 * file under old layout, check old layout on
+				 * client side.
+				 */
+				tgt = lmv_locate_tgt(lmv, op_data,
+						     &op_data->op_fid1);
+				if (IS_ERR(tgt))
+					return PTR_ERR(tgt);
+
+				rc = md_getattr_name(tgt->ltd_exp, op_data,
+						     reqp);
+				if (!rc) {
+					ptlrpc_req_finished(*reqp);
+					*reqp = NULL;
+					return -EEXIST;
+				}
+
+				if (rc != -ENOENT)
+					return rc;
+
+				op_data->op_post_migrate = true;
+			} else {
+				/*
+				 * open(O_CREAT) will be sent to MDT in old
+				 * layout first, to avoid creating new file
+				 * under old layout, clear O_CREAT.
+				 */
+				it->it_flags &= ~O_CREAT;
+			}
+		}
+	}
+
+retry:
 	if (it->it_flags & MDS_OPEN_BY_FID) {
 		LASSERT(fid_is_sane(&op_data->op_fid2));
 
@@ -292,7 +336,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		LASSERT(fid_is_zero(&op_data->op_fid2));
 		LASSERT(op_data->op_name);
 
-		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+		tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	}
@@ -325,8 +369,21 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	 */
 	if ((it->it_disposition & DISP_LOOKUP_NEG) &&
 	    !(it->it_disposition & DISP_OPEN_CREATE) &&
-	    !(it->it_disposition & DISP_OPEN_OPEN))
+	    !(it->it_disposition & DISP_OPEN_OPEN)) {
+		if (!(it->it_flags & MDS_OPEN_BY_FID) &&
+		    lmv_dir_retry_check_update(op_data)) {
+			ptlrpc_req_finished(*reqp);
+			it->it_request = NULL;
+			it->it_disposition = 0;
+			*reqp = NULL;
+
+			it->it_flags = flags;
+			fid_zero(&op_data->op_fid2);
+			goto retry;
+		}
+
 		return rc;
+	}
 
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
 	if (!body)
@@ -357,43 +414,25 @@ static int lmv_intent_lookup(struct obd_export *exp,
 			     ldlm_blocking_callback cb_blocking,
 			     u64 extra_lock_flags)
 {
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = NULL;
 	struct mdt_body	*body;
-	int rc = 0;
+	int rc;
 
-	/*
-	 * If it returns ERR_PTR(-EBADFD) then it is an unknown hash type
-	 * it will try all stripes to locate the object
-	 */
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(tgt) && (PTR_ERR(tgt) != -EBADFD))
+retry:
+	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	/*
-	 * Both migrating dir and unknown hash dir need to try
-	 * all of sub-stripes
-	 */
-	if (lsm && !lmv_is_known_hash_type(lsm->lsm_md_hash_type)) {
-		struct lmv_oinfo *oinfo = &lsm->lsm_md_oinfo[0];
-
-		op_data->op_fid1 = oinfo->lmo_fid;
-		op_data->op_mds = oinfo->lmo_mds;
-		tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
-	}
-
 	if (!fid_is_sane(&op_data->op_fid2))
 		fid_zero(&op_data->op_fid2);
 
 	CDEBUG(D_INODE,
-	       "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u lsm=%p lsm_magic=%x\n",
+	       "LOOKUP_INTENT with fid1=" DFID ", fid2=" DFID ", name='%s' -> mds #%u\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
 	       op_data->op_name ? op_data->op_name : "<NULL>",
-	       tgt->ltd_idx, lsm, !lsm ? -1 : lsm->lsm_md_magic);
+	       tgt->ltd_idx);
 
 	op_data->op_bias &= ~MDS_CROSS_REF;
 
@@ -415,39 +454,14 @@ static int lmv_intent_lookup(struct obd_export *exp,
 				return rc;
 		}
 		return rc;
-	} else if (it_disposition(it, DISP_LOOKUP_NEG) && lsm &&
-		   lmv_need_try_all_stripes(lsm)) {
-		/*
-		 * For migrating and unknown hash type directory, it will
-		 * try to target the entry on other stripes
-		 */
-		int stripe_index;
-
-		for (stripe_index = 1;
-		     stripe_index < lsm->lsm_md_stripe_count &&
-		     it_disposition(it, DISP_LOOKUP_NEG); stripe_index++) {
-			struct lmv_oinfo *oinfo;
-
-			/* release the previous request */
-			ptlrpc_req_finished(*reqp);
-			it->it_request = NULL;
-			*reqp = NULL;
-
-			oinfo = &lsm->lsm_md_oinfo[stripe_index];
-			tgt = lmv_find_target(lmv, &oinfo->lmo_fid);
-			if (IS_ERR(tgt))
-				return PTR_ERR(tgt);
-
-			CDEBUG(D_INODE, "Try other stripes " DFID "\n",
-			       PFID(&oinfo->lmo_fid));
+	} else if (it_disposition(it, DISP_LOOKUP_NEG) &&
+		   lmv_dir_retry_check_update(op_data)) {
+		ptlrpc_req_finished(*reqp);
+		it->it_request = NULL;
+		it->it_disposition = 0;
+		*reqp = NULL;
 
-			op_data->op_fid1 = oinfo->lmo_fid;
-			it->it_disposition &= ~DISP_ENQ_COMPLETE;
-			rc = md_intent_lock(tgt->ltd_exp, op_data, it, reqp,
-					    cb_blocking, extra_lock_flags);
-			if (rc)
-				return rc;
-		}
+		goto retry;
 	}
 
 	if (!it_has_reply_body(it))
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index c4a2fb8..e434919 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -58,6 +58,9 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags);
 
+int lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
+		     struct ptlrpc_request **preq);
+
 static inline struct obd_device *lmv2obd_dev(struct lmv_obd *lmv)
 {
 	return container_of_safe(lmv, struct obd_device, u.lmv);
@@ -126,15 +129,20 @@ static inline int lmv_stripe_md_size(int stripe_count)
 /* for file under migrating directory, return the target stripe info */
 static inline const struct lmv_oinfo *
 lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
-			int namelen)
+			int namelen, bool post_migrate)
 {
 	u32 hash_type = lsm->lsm_md_hash_type;
 	u32 stripe_count = lsm->lsm_md_stripe_count;
 	int stripe_index;
 
 	if (hash_type & LMV_HASH_FLAG_MIGRATION) {
-		hash_type &= ~LMV_HASH_FLAG_MIGRATION;
-		stripe_count = lsm->lsm_md_migrate_offset;
+		if (post_migrate) {
+			hash_type &= ~LMV_HASH_FLAG_MIGRATION;
+			stripe_count = lsm->lsm_md_migrate_offset;
+		} else {
+			hash_type = lsm->lsm_md_migrate_hash;
+			stripe_count -= lsm->lsm_md_migrate_offset;
+		}
 	}
 
 	stripe_index = lmv_name_to_stripe_index(hash_type, stripe_count,
@@ -142,23 +150,64 @@ static inline int lmv_stripe_md_size(int stripe_count)
 	if (stripe_index < 0)
 		return ERR_PTR(stripe_index);
 
-	LASSERTF(stripe_index < lsm->lsm_md_stripe_count,
-		 "stripe_index = %d, stripe_count = %d hash_type = %x name = %.*s\n",
-		 stripe_index, lsm->lsm_md_stripe_count,
-		 lsm->lsm_md_hash_type, namelen, name);
+	if ((lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION) && !post_migrate)
+		stripe_index += lsm->lsm_md_migrate_offset;
+
+	if (stripe_index >= lsm->lsm_md_stripe_count) {
+		CERROR("stripe_index %d stripe_count %d hash_type %#x migrate_offset %d migrate_hash %#x name %.*s\n",
+		       stripe_index, lsm->lsm_md_stripe_count,
+		       lsm->lsm_md_hash_type, lsm->lsm_md_migrate_offset,
+		       lsm->lsm_md_migrate_hash, namelen, name);
+		return ERR_PTR(-EBADF);
+	}
 
 	return &lsm->lsm_md_oinfo[stripe_index];
 }
 
-static inline bool lmv_need_try_all_stripes(const struct lmv_stripe_md *lsm)
+static inline bool lmv_is_dir_migrating(const struct lmv_stripe_md *lsm)
+{
+	return lsm ? lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION : false;
+}
+
+static inline bool lmv_is_dir_bad_hash(const struct lmv_stripe_md *lsm)
+{
+	if (!lsm)
+		return false;
+
+	if (lmv_is_dir_migrating(lsm)) {
+		if (lsm->lsm_md_stripe_count - lsm->lsm_md_migrate_offset > 1)
+			return !lmv_is_known_hash_type(
+					lsm->lsm_md_migrate_hash);
+		return false;
+	}
+
+	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type);
+}
+
+static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 {
-	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type) ||
-	       lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION;
+	const struct lmv_stripe_md *lsm = op_data->op_mea1;
+
+	if (!lsm)
+		return false;
+
+	if (lmv_is_dir_migrating(lsm) && !op_data->op_post_migrate) {
+		op_data->op_post_migrate = true;
+		return true;
+	}
+
+	if (lmv_is_dir_bad_hash(lsm) &&
+	    op_data->op_stripe_index < lsm->lsm_md_stripe_count - 1) {
+		op_data->op_stripe_index++;
+		return true;
+	}
+
+	return false;
 }
 
-struct lmv_tgt_desc
-*lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
-		struct lu_fid *fid);
+struct lmv_tgt_desc *lmv_locate_tgt(struct lmv_obd *lmv,
+				    struct md_op_data *op_data,
+				    struct lu_fid *fid);
 /* lproc_lmv.c */
 int lmv_tunables_init(struct obd_device *obd);
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 3ddffd8..0da9269 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1141,7 +1141,7 @@ static int lmv_placement_policy(struct obd_device *obd,
 	 * 1. See if the stripe offset is specified by lum.
 	 * 2. Then check if there is default stripe offset.
 	 * 3. Finally choose MDS by name hash if the parent
-	 *    is striped directory. (see lmv_locate_mds()).
+	 *    is striped directory. (see lmv_locate_tgt()).
 	 */
 	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
 	    le32_to_cpu(lum->lum_stripe_offset) != (u32)-1) {
@@ -1511,26 +1511,31 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 	return md_close(tgt->ltd_exp, op_data, mod, request);
 }
 
-/**
- * Choosing the MDT by name or FID in @op_data.
- * For non-striped directory, it will locate MDT by fid.
- * For striped-directory, it will locate MDT by name. And also
- * it will reset op_fid1 with the FID of the chosen stripe.
- **/
-static struct lmv_tgt_desc *
-lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
-			   const char *name, int namelen, struct lu_fid *fid,
-			   u32 *mds)
+struct lmv_tgt_desc*
+__lmv_locate_tgt(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
+		 const char *name, int namelen, struct lu_fid *fid, u32 *mds,
+		 bool post_migrate)
 {
 	const struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
+	if (!lsm || namelen == 0) {
+		tgt = lmv_find_target(lmv, fid);
+		if (IS_ERR(tgt))
+			return tgt;
+
+		LASSERT(mds);
+		*mds = tgt->ltd_idx;
+		return tgt;
+	}
+
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_BAD_NAME_HASH)) {
 		if (cfs_fail_val >= lsm->lsm_md_stripe_count)
 			return ERR_PTR(-EBADF);
 		oinfo = &lsm->lsm_md_oinfo[cfs_fail_val];
 	} else {
-		oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
+		oinfo = lsm_name_to_stripe_info(lsm, name, namelen,
+						post_migrate);
 		if (IS_ERR(oinfo))
 			return ERR_CAST(oinfo);
 	}
@@ -1544,16 +1549,17 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 
 	CDEBUG(D_INFO, "locate on mds %u " DFID "\n", oinfo->lmo_mds,
 	       PFID(&oinfo->lmo_fid));
+
 	return tgt;
 }
 
 /**
- * Locate mds by fid or name
+ * Locate mdt by fid or name
  *
- * For striped directory (lsm != NULL), it will locate the stripe
- * by name hash (see lsm_name_to_stripe_info()). Note: if the hash_type
- * is unknown, it will return -EBADFD, and lmv_intent_lookup might need
- * walk through all of stripes to locate the entry.
+ * For striped directory, it will locate the stripe by name hash, if hash_type
+ * is unknown, it will return the stripe specified by 'op_data->op_stripe_index'
+ * which is set outside, and if dir is migrating, 'op_data->op_post_migrate'
+ * indicates whether old or new layout is used to locate.
  *
  * For normal direcotry, it will locate MDS by FID directly.
  *
@@ -1566,10 +1572,11 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
  *		ERR_PTR(errno) if failed.
  */
 struct lmv_tgt_desc*
-lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
+lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data,
 	       struct lu_fid *fid)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
 	/*
@@ -1579,17 +1586,15 @@ struct lmv_tgt_desc*
 	 */
 	if (op_data->op_bias & MDS_CREATE_VOLATILE &&
 	    (int)op_data->op_mds != -1) {
-		int i;
-
 		tgt = lmv_get_target(lmv, op_data->op_mds, NULL);
 		if (IS_ERR(tgt))
 			return tgt;
 
 		if (lsm) {
+			int i;
+
 			/* refill the right parent fid */
 			for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
-				struct lmv_oinfo *oinfo;
-
 				oinfo = &lsm->lsm_md_oinfo[i];
 				if (oinfo->lmo_mds == op_data->op_mds) {
 					*fid = oinfo->lmo_fid;
@@ -1600,23 +1605,22 @@ struct lmv_tgt_desc*
 			if (i == lsm->lsm_md_stripe_count)
 				*fid = lsm->lsm_md_oinfo[0].lmo_fid;
 		}
+	} else if (lmv_is_dir_bad_hash(lsm)) {
+		LASSERT(op_data->op_stripe_index < lsm->lsm_md_stripe_count);
+		oinfo = &lsm->lsm_md_oinfo[op_data->op_stripe_index];
 
-		return tgt;
-	}
-
-	if (!lsm || !op_data->op_namelen) {
-		tgt = lmv_find_target(lmv, fid);
-		if (IS_ERR(tgt))
-			return tgt;
-
-		op_data->op_mds = tgt->ltd_idx;
+		*fid = oinfo->lmo_fid;
+		op_data->op_mds = oinfo->lmo_mds;
 
-		return tgt;
+		tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
+	} else {
+		tgt = __lmv_locate_tgt(lmv, lsm, op_data->op_name,
+				       op_data->op_namelen, fid,
+				       &op_data->op_mds,
+				       op_data->op_post_migrate);
 	}
 
-	return lmv_locate_target_for_name(lmv, lsm, op_data->op_name,
-					  op_data->op_namelen, fid,
-					  &op_data->op_mds);
+	return tgt;
 }
 
 static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
@@ -1632,7 +1636,33 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (!lmv->desc.ld_active_tgt_count)
 		return -EIO;
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+	if (lmv_is_dir_bad_hash(op_data->op_mea1))
+		return -EBADF;
+
+	if (lmv_is_dir_migrating(op_data->op_mea1)) {
+		/*
+		 * if parent is migrating, create() needs to lookup existing
+		 * name, to avoid creating new file under old layout of
+		 * migrating directory, check old layout here.
+		 */
+		tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		rc = md_getattr_name(tgt->ltd_exp, op_data, request);
+		if (!rc) {
+			ptlrpc_req_finished(*request);
+			*request = NULL;
+			return -EEXIST;
+		}
+
+		if (rc != -ENOENT)
+			return rc;
+
+		op_data->op_post_migrate = true;
+	}
+
+	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1685,7 +1715,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 
 	CDEBUG(D_INODE, "ENQUEUE on " DFID "\n", PFID(&op_data->op_fid1));
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1696,18 +1726,18 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 			  extra_lock_flags);
 }
 
-static int
+int
 lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		 struct ptlrpc_request **preq)
 {
-	struct ptlrpc_request *req = NULL;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 	struct mdt_body	*body;
 	int rc;
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+retry:
+	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -1716,30 +1746,26 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	       PFID(&op_data->op_fid1), tgt->ltd_idx);
 
 	rc = md_getattr_name(tgt->ltd_exp, op_data, preq);
-	if (rc != 0)
+	if (rc == -ENOENT && lmv_dir_retry_check_update(op_data)) {
+		ptlrpc_req_finished(*preq);
+		*preq = NULL;
+		goto retry;
+	}
+
+	if (rc)
 		return rc;
 
 	body = req_capsule_server_get(&(*preq)->rq_pill, &RMF_MDT_BODY);
 	if (body->mbo_valid & OBD_MD_MDS) {
-		struct lu_fid rid = body->mbo_fid1;
-
-		CDEBUG(D_INODE, "Request attrs for " DFID "\n",
-		       PFID(&rid));
-
-		tgt = lmv_find_target(lmv, &rid);
-		if (IS_ERR(tgt)) {
-			ptlrpc_req_finished(*preq);
-			*preq = NULL;
-			return PTR_ERR(tgt);
-		}
-
-		op_data->op_fid1 = rid;
+		op_data->op_fid1 = body->mbo_fid1;
 		op_data->op_valid |= OBD_MD_FLCROSSREF;
 		op_data->op_namelen = 0;
 		op_data->op_name = NULL;
-		rc = md_getattr_name(tgt->ltd_exp, op_data, &req);
+
 		ptlrpc_req_finished(*preq);
-		*preq = req;
+		*preq = NULL;
+
+		goto retry;
 	}
 
 	return rc;
@@ -1808,19 +1834,40 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
-	if (op_data->op_mea2) {
-		struct lmv_stripe_md *lsm = op_data->op_mea2;
-		const struct lmv_oinfo *oinfo;
 
-		oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
-						op_data->op_namelen);
-		if (IS_ERR(oinfo))
-			return PTR_ERR(oinfo);
+	if (lmv_is_dir_migrating(op_data->op_mea2)) {
+		struct lu_fid fid1 = op_data->op_fid1;
+		struct lmv_stripe_md *lsm1 = op_data->op_mea1;
 
-		op_data->op_fid2 = oinfo->lmo_fid;
+		/*
+		 * avoid creating new file under old layout of migrating
+		 * directory, check it here.
+		 */
+		tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, op_data->op_name,
+				       op_data->op_namelen, &op_data->op_fid2,
+				       &op_data->op_mds, false);
+		tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		op_data->op_fid1 = op_data->op_fid2;
+		op_data->op_mea1 = op_data->op_mea2;
+		rc = md_getattr_name(tgt->ltd_exp, op_data, request);
+		op_data->op_fid1 = fid1;
+		op_data->op_mea1 = lsm1;
+		if (!rc) {
+			ptlrpc_req_finished(*request);
+			*request = NULL;
+			return -EEXIST;
+		}
+
+		if (rc != -ENOENT)
+			return rc;
 	}
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid2);
+	tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, op_data->op_name,
+			       op_data->op_namelen, &op_data->op_fid2,
+			       &op_data->op_mds, true);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -2004,9 +2051,9 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct lmv_tgt_desc *sp_tgt;
 	struct lmv_tgt_desc *tp_tgt = NULL;
+	struct lmv_tgt_desc *src_tgt = NULL;
 	struct lmv_tgt_desc *tgt;
 	struct mdt_body *body;
 	int rc;
@@ -2022,26 +2069,44 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
 
-	CDEBUG(D_INODE, "RENAME "DFID"/%.*s to "DFID"/%.*s\n",
-		PFID(&op_data->op_fid1), (int)oldlen, old,
-		PFID(&op_data->op_fid2), (int)newlen, new);
+	if (lmv_is_dir_migrating(op_data->op_mea2)) {
+		struct lu_fid fid1 = op_data->op_fid1;
+		struct lmv_stripe_md *lsm1 = op_data->op_mea1;
 
-	if (lsm)
-		sp_tgt = lmv_locate_target_for_name(lmv, lsm, old, oldlen,
-						    &op_data->op_fid1,
-						    &op_data->op_mds);
-	else
-		sp_tgt = lmv_find_target(lmv, &op_data->op_fid1);
-	if (IS_ERR(sp_tgt))
-		return PTR_ERR(sp_tgt);
+		/*
+		 * we avoid creating new file under old layout of migrating
+		 * directory, if there is an existing file with new name under
+		 * old layout, we can't unlink file in old layout and rename to
+		 * new layout in one transaction, so return -EBUSY here.`
+		 */
+		tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, new, newlen,
+				       &op_data->op_fid2, &op_data->op_mds,
+				       false);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
 
-	lsm = op_data->op_mea2;
-	if (lsm)
-		tp_tgt = lmv_locate_target_for_name(lmv, lsm, new, newlen,
-						    &op_data->op_fid2,
-						    &op_data->op_mds);
-	else
-		tp_tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		op_data->op_fid1 = op_data->op_fid2;
+		op_data->op_mea1 = op_data->op_mea2;
+		op_data->op_name = new;
+		op_data->op_namelen = newlen;
+		rc = md_getattr_name(tgt->ltd_exp, op_data, request);
+		op_data->op_fid1 = fid1;
+		op_data->op_mea1 = lsm1;
+		op_data->op_name = NULL;
+		op_data->op_namelen = 0;
+		if (!rc) {
+			ptlrpc_req_finished(*request);
+			*request = NULL;
+			return -EBUSY;
+		}
+
+		if (rc != -ENOENT)
+			return rc;
+	}
+
+	/* rename to new layout for migrating directory */
+	tp_tgt = __lmv_locate_tgt(lmv, op_data->op_mea2, new, newlen,
+				  &op_data->op_fid2, &op_data->op_mds, true);
 	if (IS_ERR(tp_tgt))
 		return PTR_ERR(tp_tgt);
 
@@ -2062,34 +2127,28 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 	op_data->op_flags |= MF_MDC_CANCEL_FID4;
 
-	/* cancel UPDATE locks of source parent */
-	rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_idx, LCK_EX,
-			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
-	if (rc != 0)
-		return rc;
-
 	/* cancel UPDATE locks of target parent */
 	rc = lmv_early_cancel(exp, tp_tgt, op_data, tgt->ltd_idx, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID2);
 	if (rc != 0)
 		return rc;
 
-	if (fid_is_sane(&op_data->op_fid3)) {
-		struct lmv_tgt_desc *src_tgt;
-
-		src_tgt = lmv_find_target(lmv, &op_data->op_fid3);
-		if (IS_ERR(src_tgt))
-			return PTR_ERR(src_tgt);
-
-		/* cancel LOOKUP lock of source on source parent */
-		if (src_tgt != sp_tgt) {
-			rc = lmv_early_cancel(exp, sp_tgt, op_data,
+	if (fid_is_sane(&op_data->op_fid4)) {
+		/* cancel LOOKUP lock of target on target parent */
+		if (tgt != tp_tgt) {
+			rc = lmv_early_cancel(exp, tp_tgt, op_data,
 					      tgt->ltd_idx, LCK_EX,
 					      MDS_INODELOCK_LOOKUP,
-					      MF_MDC_CANCEL_FID3);
+					      MF_MDC_CANCEL_FID4);
 			if (rc != 0)
 				return rc;
 		}
+	}
+
+	if (fid_is_sane(&op_data->op_fid3)) {
+		src_tgt = lmv_find_target(lmv, &op_data->op_fid3);
+		if (IS_ERR(src_tgt))
+			return PTR_ERR(src_tgt);
 
 		/* cancel ELC locks of source */
 		rc = lmv_early_cancel(exp, src_tgt, op_data, tgt->ltd_idx,
@@ -2099,21 +2158,44 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 	}
 
-retry_rename:
-	if (fid_is_sane(&op_data->op_fid4)) {
-		/* cancel LOOKUP lock of target on target parent */
-		if (tgt != tp_tgt) {
-			rc = lmv_early_cancel(exp, tp_tgt, op_data,
+retry:
+	sp_tgt = __lmv_locate_tgt(lmv, op_data->op_mea1, old, oldlen,
+				  &op_data->op_fid1, &op_data->op_mds,
+				  op_data->op_post_migrate);
+	if (IS_ERR(sp_tgt))
+		return PTR_ERR(sp_tgt);
+
+	/* cancel UPDATE locks of source parent */
+	rc = lmv_early_cancel(exp, sp_tgt, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
+	if (rc != 0)
+		return rc;
+
+	if (fid_is_sane(&op_data->op_fid3)) {
+		/* cancel LOOKUP lock of source on source parent */
+		if (src_tgt != sp_tgt) {
+			rc = lmv_early_cancel(exp, sp_tgt, op_data,
 					      tgt->ltd_idx, LCK_EX,
 					      MDS_INODELOCK_LOOKUP,
-					      MF_MDC_CANCEL_FID4);
+					      MF_MDC_CANCEL_FID3);
 			if (rc != 0)
 				return rc;
 		}
 	}
 
+rename:
+	CDEBUG(D_INODE, "RENAME " DFID "/%.*s to " DFID "/%.*s\n",
+	       PFID(&op_data->op_fid1), (int)oldlen, old,
+	       PFID(&op_data->op_fid2), (int)newlen, new);
+
 	rc = md_rename(tgt->ltd_exp, op_data, old, oldlen, new, newlen,
 		       request);
+	if (rc == -ENOENT && lmv_dir_retry_check_update(op_data)) {
+		ptlrpc_req_finished(*request);
+		*request = NULL;
+		goto retry;
+	}
+
 	if (rc && rc != -EXDEV)
 		return rc;
 
@@ -2125,10 +2207,8 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	if (likely(!(body->mbo_valid & OBD_MD_MDS)))
 		return rc;
 
-	CDEBUG(D_INODE, "%s: try rename to another MDT for " DFID "\n",
-	       exp->exp_obd->obd_name, PFID(&body->mbo_fid1));
-
 	op_data->op_fid4 = body->mbo_fid1;
+
 	ptlrpc_req_finished(*request);
 	*request = NULL;
 
@@ -2136,7 +2216,19 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	goto retry_rename;
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
+	}
+
+	goto rename;
 }
 
 static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
@@ -2575,68 +2667,30 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		      struct ptlrpc_request **request)
 {
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc *parent_tgt = NULL;
-	struct lmv_tgt_desc *tgt = NULL;
-	struct mdt_body	*body;
-	int stripe_index = 0;
+	struct lmv_tgt_desc *tgt;
+	struct lmv_tgt_desc *parent_tgt;
+	struct mdt_body *body;
 	int rc;
 
-retry_unlink:
-	/* For striped dir, we need to locate the parent as well */
-	if (lsm) {
-		struct lmv_tgt_desc *tmp;
-
-		LASSERT(op_data->op_name && op_data->op_namelen);
-
-		tmp = lmv_locate_target_for_name(lmv, lsm,
-						 op_data->op_name,
-						 op_data->op_namelen,
-						 &op_data->op_fid1,
-						 &op_data->op_mds);
-
-		/*
-		 * return -EBADFD means unknown hash type, might
-		 * need try all sub-stripe here
-		 */
-		if (IS_ERR(tmp) && PTR_ERR(tmp) != -EBADFD)
-			return PTR_ERR(tmp);
-
-		/*
-		 * Note: both migrating dir and unknown hash dir need to
-		 * try all of sub-stripes, so we need start search the
-		 * name from stripe 0, but migrating dir is already handled
-		 * inside lmv_locate_target_for_name(), so we only check
-		 * unknown hash type directory here
-		 */
-		if (!lmv_is_known_hash_type(lsm->lsm_md_hash_type)) {
-			struct lmv_oinfo *oinfo;
-
-			oinfo = &lsm->lsm_md_oinfo[stripe_index];
-
-			op_data->op_fid1 = oinfo->lmo_fid;
-			op_data->op_mds = oinfo->lmo_mds;
-		}
-	}
-
-try_next_stripe:
-	/* Send unlink requests to the MDT where the child is located */
-	if (likely(!fid_is_zero(&op_data->op_fid2)))
-		tgt = lmv_find_target(lmv, &op_data->op_fid2);
-	else if (lsm)
-		tgt = lmv_get_target(lmv, op_data->op_mds, NULL);
-	else
-		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
-
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = current_cap();
 
+retry:
+	parent_tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
+	if (IS_ERR(parent_tgt))
+		return PTR_ERR(parent_tgt);
+
+	if (likely(!fid_is_zero(&op_data->op_fid2))) {
+		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+	} else {
+		tgt = parent_tgt;
+	}
+
 	/*
 	 * If child's fid is given, cancel unused locks for it if it is from
 	 * another export than parent.
@@ -2646,50 +2700,29 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	 */
 	op_data->op_flags |= MF_MDC_CANCEL_FID1 | MF_MDC_CANCEL_FID3;
 
-	/*
-	 * Cancel FULL locks on child (fid3).
-	 */
-	parent_tgt = lmv_find_target(lmv, &op_data->op_fid1);
-	if (IS_ERR(parent_tgt))
-		return PTR_ERR(parent_tgt);
-
-	if (parent_tgt != tgt) {
+	if (parent_tgt != tgt)
 		rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_idx,
 				      LCK_EX, MDS_INODELOCK_LOOKUP,
 				      MF_MDC_CANCEL_FID3);
-	}
 
 	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_idx, LCK_EX,
 			      MDS_INODELOCK_ELC, MF_MDC_CANCEL_FID3);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	CDEBUG(D_INODE, "unlink with fid=" DFID "/" DFID " -> mds #%u\n",
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2), tgt->ltd_idx);
 
 	rc = md_unlink(tgt->ltd_exp, op_data, request);
-	if (rc != 0 && rc != -EREMOTE  && rc != -ENOENT)
-		return rc;
-
-	/* Try next stripe if it is needed. */
-	if (rc == -ENOENT && lsm && lmv_need_try_all_stripes(lsm)) {
-		struct lmv_oinfo *oinfo;
-
-		stripe_index++;
-		if (stripe_index >= lsm->lsm_md_stripe_count)
-			return rc;
-
-		oinfo = &lsm->lsm_md_oinfo[stripe_index];
-
-		op_data->op_fid1 = oinfo->lmo_fid;
-		op_data->op_mds = oinfo->lmo_mds;
-
+	if (rc == -ENOENT && lmv_dir_retry_check_update(op_data)) {
 		ptlrpc_req_finished(*request);
 		*request = NULL;
-
-		goto try_next_stripe;
+		goto retry;
 	}
 
+	if (rc != -EREMOTE)
+		return rc;
+
 	body = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
 	if (!body)
 		return -EPROTO;
@@ -2698,34 +2731,16 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	if (likely(!(body->mbo_valid & OBD_MD_MDS)))
 		return rc;
 
-	CDEBUG(D_INODE, "%s: try unlink to another MDT for " DFID "\n",
-	       exp->exp_obd->obd_name, PFID(&body->mbo_fid1));
-
-	/* This is a remote object, try remote MDT, Note: it may
-	 * try more than 1 time here, Considering following case
-	 * /mnt/lustre is root on MDT0, remote1 is on MDT1
-	 * 1. Initially A does not know where remote1 is, it send
-	 *    unlink RPC to MDT0, MDT0 return -EREMOTE, it will
-	 *    resend unlink RPC to MDT1 (retry 1st time).
-	 *
-	 * 2. During the unlink RPC in flight,
-	 *    client B mv /mnt/lustre/remote1 /mnt/lustre/remote2
-	 *    and create new remote1, but on MDT0
-	 *
-	 * 3. MDT1 get unlink RPC(from A), then do remote lock on
-	 *    /mnt/lustre, then lookup get fid of remote1, and find
-	 *    it is remote dir again, and replay -EREMOTE again.
-	 *
-	 * 4. Then A will resend unlink RPC to MDT0. (retry 2nd times).
-	 *
-	 * In theory, it might try unlimited time here, but it should
-	 * be very rare case.
-	 */
+	/* This is a remote object, try remote MDT. */
 	op_data->op_fid2 = body->mbo_fid1;
 	ptlrpc_req_finished(*request);
 	*request = NULL;
 
-	goto retry_unlink;
+	tgt = lmv_find_target(lmv, &op_data->op_fid2);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	goto retry;
 }
 
 static int lmv_precleanup(struct obd_device *obd)
@@ -3134,7 +3149,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	if (!fid_is_sane(&op_data->op_fid2))
 		return -EINVAL;
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
@@ -3172,7 +3187,7 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	const struct lmv_oinfo *oinfo;
 
 	LASSERT(lsm);
-	oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
+	oinfo = lsm_name_to_stripe_info(lsm, name, namelen, false);
 	if (IS_ERR(oinfo))
 		return PTR_ERR(oinfo);
 
-- 
1.8.3.1
