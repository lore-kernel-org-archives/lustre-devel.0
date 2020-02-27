From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:21 -0500
Subject: [lustre-devel] [PATCH 513/622] lustre: lmv: alloc dir stripes by QoS
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-514-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Similar to file OST object allocation, introduce directory stripe
allocation by space usage, but they don't share the same code because
of the many differences between them: file has mirrors, PFL, object
precreation; while for directory, the first stripe is always on the
same MDT where its master object is on. The changes include:
* add lod_mdt_alloc_qos() to allocate stripes by space/inode usage.
* add lod_mdt_alloc_rr() to allocate stripes round-robin.
* add lod_mdt_alloc_specific() to allocate stripes in the old way.
* add sysfs support for lmv_desc field in LOD structure, and move
  those remain in procfs to sysfs.

This patch also changes LMV QoS code:
* mkdir by QoS if user mkdir by command 'lfs mkdir -i -1 ...', or the
  parent directory default LMV starting MDT index is -1.
* with the above change, 'space' hash flag is useless, remove all
  related code.
* previously 'lfs mkdir -i -1' QoS code is in lfs_setdirstripe(),
  but now it's done in LMV, remove the old code.

Update sanity 413a 413b to support QoS mkdir of both plain and
striped directories.

Update lfs-setdirstripe man to reflect the changes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12624
Lustre-commit: c1d0a355a6a6 ("LU-12624 lod: alloc dir stripes by QoS")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35825
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradaed.org>
---
 fs/lustre/include/lustre_lmv.h          |  12 --
 fs/lustre/lmv/lmv_intent.c              |  16 +-
 fs/lustre/lmv/lmv_internal.h            |   4 +-
 fs/lustre/lmv/lmv_obd.c                 | 279 ++++++++++++++++----------------
 fs/lustre/obdclass/lu_tgt_descs.c       |  17 +-
 fs/lustre/ptlrpc/wiretest.c             |   1 -
 include/uapi/linux/lustre/lustre_user.h |  10 +-
 7 files changed, 154 insertions(+), 185 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index b33a6ed..a538559 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -55,12 +55,6 @@ struct lmv_stripe_md {
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
-static inline bool lmv_is_known_hash_type(u32 type)
-{
-	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
-	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
-}
-
 static inline bool lmv_dir_striped(const struct lmv_stripe_md *lsm)
 {
 	return lsm && lsm->lsm_md_magic == LMV_MAGIC;
@@ -89,12 +83,6 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type);
 }
 
-/* NB, this is checking directory default LMV */
-static inline bool lmv_dir_qos_mkdir(const struct lmv_stripe_md *lsm)
-{
-	return lsm && (lsm->lsm_md_hash_type & LMV_HASH_FLAG_SPACE);
-}
-
 static inline bool
 lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 {
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 542b16d..ca9bbe8 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -306,22 +306,10 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 				/*
 				 * open(O_CREAT | O_EXCL) needs to check
 				 * existing name, which should be done on both
-				 * old and new layout, to avoid creating new
-				 * file under old layout, check old layout on
+				 * old and new layout, check old layout on
 				 * client side.
 				 */
-				tgt = lmv_locate_tgt(lmv, op_data);
-				if (IS_ERR(tgt))
-					return PTR_ERR(tgt);
-
-				rc = md_getattr_name(tgt->ltd_exp, op_data,
-						     reqp);
-				if (!rc) {
-					ptlrpc_req_finished(*reqp);
-					*reqp = NULL;
-					return -EEXIST;
-				}
-
+				rc = lmv_migrate_existence_check(lmv, op_data);
 				if (rc != -ENOENT)
 					return rc;
 
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index 70d86676..e23eb37 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -49,7 +49,6 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		    u64 extra_lock_flags);
 
 int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds);
-int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds);
 int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
 
@@ -217,8 +216,9 @@ static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 
 struct lmv_tgt_desc *lmv_locate_tgt(struct lmv_obd *lmv,
 				    struct md_op_data *op_data);
+int lmv_migrate_existence_check(struct lmv_obd *lmv,
+				struct md_op_data *op_data);
 
 /* lproc_lmv.c */
 int lmv_tunables_init(struct obd_device *obd);
-
 #endif
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 84be905..e92be25 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1045,106 +1045,36 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	return rc;
 }
 
-/**
- * This is _inode_ placement policy function (not name).
- */
-static u32 lmv_placement_policy(struct obd_device *obd,
-				struct md_op_data *op_data)
+int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
+		  struct lu_fid *fid, struct md_op_data *op_data)
 {
+	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_user_md *lum;
-	u32 mdt;
-
-	if (lmv->lmv_mdt_count == 1)
-		return 0;
-
-	lum = op_data->op_data;
-	/*
-	 * Choose MDT by
-	 * 1. See if the stripe offset is specified by lum.
-	 * 2. If parent has default LMV, and its hash type is "space", choose
-	 *    MDT with QoS. (see lmv_locate_tgt_qos()).
-	 * 3. Then check if default LMV stripe offset is not -1.
-	 * 4. Finally choose MDS by name hash if the parent
-	 *    is striped directory. (see lmv_locate_tgt()).
-	 *
-	 * presently explicit MDT location is not supported
-	 * for foreign dirs (as it can't be embedded into free
-	 * format LMV, like with lum_stripe_offset), so we only
-	 * rely on default stripe offset or then name hashing.
-	 */
-	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
-	    le32_to_cpu(lum->lum_magic != LMV_MAGIC_FOREIGN) &&
-	    le32_to_cpu(lum->lum_stripe_offset) != (u32)-1) {
-		mdt = le32_to_cpu(lum->lum_stripe_offset);
-	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
-		   !lmv_dir_striped(op_data->op_mea1) &&
-		   lmv_dir_qos_mkdir(op_data->op_default_mea1)) {
-		mdt = op_data->op_mds;
-	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
-		   op_data->op_default_mea1 &&
-		   op_data->op_default_mea1->lsm_md_master_mdt_index !=
-			(u32)-1) {
-		mdt = op_data->op_default_mea1->lsm_md_master_mdt_index;
-		op_data->op_mds = mdt;
-	} else {
-		mdt = op_data->op_mds;
-	}
-
-	return mdt;
-}
-
-int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
-{
 	struct lmv_tgt_desc *tgt;
 	int rc;
 
-	tgt = lmv_tgt(lmv, mds);
+	LASSERT(op_data);
+	LASSERT(fid);
+
+	tgt = lmv_tgt(lmv, op_data->op_mds);
 	if (!tgt)
 		return -ENODEV;
 
+	if (!tgt->ltd_active || !tgt->ltd_exp)
+		return -ENODEV;
+
 	/*
 	 * New seq alloc and FLD setup should be atomic. Otherwise we may find
 	 * on server that seq in new allocated fid is not yet known.
 	 */
 	mutex_lock(&tgt->ltd_fid_mutex);
-
-	if (tgt->ltd_active == 0 || !tgt->ltd_exp) {
-		rc = -ENODEV;
-		goto out;
-	}
-
-	/*
-	 * Asking underlaying tgt layer to allocate new fid.
-	 */
 	rc = obd_fid_alloc(NULL, tgt->ltd_exp, fid, NULL);
+	mutex_unlock(&tgt->ltd_fid_mutex);
 	if (rc > 0) {
 		LASSERT(fid_is_sane(fid));
 		rc = 0;
 	}
 
-out:
-	mutex_unlock(&tgt->ltd_fid_mutex);
-	return rc;
-}
-
-int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
-		  struct lu_fid *fid, struct md_op_data *op_data)
-{
-	struct obd_device *obd = class_exp2obd(exp);
-	struct lmv_obd *lmv = &obd->u.lmv;
-	u32 mds;
-	int rc;
-
-	LASSERT(op_data);
-	LASSERT(fid);
-
-	mds = lmv_placement_policy(obd, op_data);
-
-	rc = __lmv_fid_alloc(lmv, fid, mds);
-	if (rc)
-		CERROR("Can't alloc new fid, rc %d\n", rc);
-
 	return rc;
 }
 
@@ -1624,8 +1554,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
  * which is set outside, and if dir is migrating, 'op_data->op_post_migrate'
  * indicates whether old or new layout is used to locate.
  *
- * For plain direcotry, normally it will locate MDT by FID, but if this
- * directory has default LMV, and its hash type is "space", locate MDT with QoS.
+ * For plain direcotry, it just locate the MDT of op_data->op_fid1.
  *
  * @lmv:	LMV device
  * @op_data:	client MD stack parameters, name, namelen
@@ -1650,7 +1579,7 @@ struct lmv_tgt_desc *
 	 * ct_restore().
 	 */
 	if (op_data->op_bias & MDS_CREATE_VOLATILE &&
-	    (int)op_data->op_mds != -1) {
+	    op_data->op_mds != LMV_OFFSET_DEFAULT) {
 		tgt = lmv_tgt(lmv, op_data->op_mds);
 		if (!tgt)
 			return ERR_PTR(-ENODEV);
@@ -1679,30 +1608,7 @@ struct lmv_tgt_desc *
 
 		tgt = lmv_tgt(lmv, oinfo->lmo_mds);
 		if (!tgt)
-			tgt = ERR_PTR(-ENODEV);
-	} else if (op_data->op_code == LUSTRE_OPC_MKDIR &&
-		   lmv_dir_qos_mkdir(op_data->op_default_mea1) &&
-		   !lmv_dir_striped(lsm)) {
-		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
-		if (tgt == ERR_PTR(-EAGAIN))
-			tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
-		/*
-		 * only update statfs when mkdir under dir with "space" hash,
-		 * this means the cached statfs may be stale, and current mkdir
-		 * may not follow QoS accurately, but it's not serious, and it
-		 * avoids periodic statfs when client doesn't mkdir under
-		 * "space" hashed directories.
-		 *
-		 * TODO: after MDT support QoS object allocation, also update
-		 * statfs for 'lfs mkdir -i -1 ...", currently it's done in user
-		 * space.
-		 */
-		if (!IS_ERR(tgt)) {
-			struct obd_device *obd;
-
-			obd = container_of(lmv, struct obd_device, u.lmv);
-			lmv_statfs_check_update(obd, tgt);
-		}
+			return ERR_PTR(-ENODEV);
 	} else {
 		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_mea1,
 				op_data->op_name, op_data->op_namelen,
@@ -1755,6 +1661,78 @@ struct lmv_tgt_desc *
 				&op_data->op_mds, true);
 }
 
+int lmv_migrate_existence_check(struct lmv_obd *lmv, struct md_op_data *op_data)
+{
+	struct lu_tgt_desc *tgt;
+	struct ptlrpc_request *request;
+	int rc;
+
+	LASSERT(lmv_dir_migrating(op_data->op_mea1));
+
+	tgt = lmv_locate_tgt(lmv, op_data);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	rc = md_getattr_name(tgt->ltd_exp, op_data, &request);
+	if (!rc) {
+		ptlrpc_req_finished(request);
+		return -EEXIST;
+	}
+
+	return rc;
+}
+
+/* mkdir by QoS in two cases:
+ * 1. 'lfs mkdir -i -1'
+ * 2. parent default LMV master_mdt_index is -1
+ *
+ * NB, mkdir by QoS only if parent is not striped, this is to avoid remote
+ * directories under striped directory.
+ */
+static inline bool lmv_op_qos_mkdir(const struct md_op_data *op_data)
+{
+	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
+	const struct lmv_user_md *lum = op_data->op_data;
+
+	if (op_data->op_code != LUSTRE_OPC_MKDIR)
+		return false;
+
+	if (lmv_dir_striped(op_data->op_mea1))
+		return false;
+
+	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
+	    (le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC ||
+	     le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC_SPECIFIC) &&
+	    le32_to_cpu(lum->lum_stripe_offset) == LMV_OFFSET_DEFAULT)
+		return true;
+
+	if (lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT)
+		return true;
+
+	return false;
+}
+
+/* 'lfs mkdir -i <specific_MDT>' */
+static inline bool lmv_op_user_specific_mkdir(const struct md_op_data *op_data)
+{
+	const struct lmv_user_md *lum = op_data->op_data;
+
+	return op_data->op_code == LUSTRE_OPC_MKDIR &&
+	       op_data->op_cli_flags & CLI_SET_MEA && lum &&
+	       (le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC ||
+		le32_to_cpu(lum->lum_magic) == LMV_USER_MAGIC_SPECIFIC) &&
+	       le32_to_cpu(lum->lum_stripe_offset) != LMV_OFFSET_DEFAULT;
+}
+
+/* parent default LMV master_mdt_index is not -1. */
+static inline bool
+lmv_op_default_specific_mkdir(const struct md_op_data *op_data)
+{
+	return op_data->op_code == LUSTRE_OPC_MKDIR &&
+	       op_data->op_default_mea1 &&
+	       op_data->op_default_mea1->lsm_md_master_mdt_index !=
+			LMV_OFFSET_DEFAULT;
+}
 int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		const void *data, size_t datalen, umode_t mode, uid_t uid,
 		gid_t gid, kernel_cap_t cap_effective, u64 rdev,
@@ -1774,20 +1752,9 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (lmv_dir_migrating(op_data->op_mea1)) {
 		/*
 		 * if parent is migrating, create() needs to lookup existing
-		 * name, to avoid creating new file under old layout of
-		 * migrating directory, check old layout here.
+		 * name in both old and new layout, check old layout on client.
 		 */
-		tgt = lmv_locate_tgt(lmv, op_data);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
-
-		rc = md_getattr_name(tgt->ltd_exp, op_data, request);
-		if (!rc) {
-			ptlrpc_req_finished(*request);
-			*request = NULL;
-			return -EEXIST;
-		}
-
+		rc = lmv_migrate_existence_check(lmv, op_data);
 		if (rc != -ENOENT)
 			return rc;
 
@@ -1798,28 +1765,44 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	CDEBUG(D_INODE, "CREATE name '%.*s' on " DFID " -> mds #%x\n",
-	       (int)op_data->op_namelen, op_data->op_name,
-	       PFID(&op_data->op_fid1), op_data->op_mds);
-
-	rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
-	if (rc)
-		return rc;
-
-	if (exp_connect_flags(exp) & OBD_CONNECT_DIR_STRIPE) {
+	if (lmv_op_qos_mkdir(op_data)) {
+		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
+		if (tgt == ERR_PTR(-EAGAIN))
+			tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
 		/*
-		 * Send the create request to the MDT where the object
-		 * will be located
+		 * only update statfs after QoS mkdir, this means the cached
+		 * statfs may be stale, and current mkdir may not follow QoS
+		 * accurately, but it's not serious, and avoids periodic statfs
+		 * when client doesn't mkdir by QoS.
 		 */
-		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
+		if (!IS_ERR(tgt))
+			lmv_statfs_check_update(obd, tgt);
+	} else if (lmv_op_user_specific_mkdir(op_data)) {
+		struct lmv_user_md *lum = op_data->op_data;
 
-		op_data->op_mds = tgt->ltd_index;
+		op_data->op_mds = le32_to_cpu(lum->lum_stripe_offset);
+		tgt = lmv_tgt(lmv, op_data->op_mds);
+		if (!tgt)
+			return -ENODEV;
+	} else if (lmv_op_default_specific_mkdir(op_data)) {
+		op_data->op_mds =
+			op_data->op_default_mea1->lsm_md_master_mdt_index;
+		tgt = lmv_tgt(lmv, op_data->op_mds);
+		if (!tgt)
+			return -ENODEV;
 	}
 
-	CDEBUG(D_INODE, "CREATE obj " DFID " -> mds #%x\n",
-	       PFID(&op_data->op_fid1), op_data->op_mds);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
+	if (rc)
+		return rc;
+
+	CDEBUG(D_INODE, "CREATE name '%.*s' "DFID" on " DFID " -> mds #%x\n",
+		(int)op_data->op_namelen, op_data->op_name,
+		PFID(&op_data->op_fid2), PFID(&op_data->op_fid1),
+		op_data->op_mds);
 
 	op_data->op_flags |= MF_MDC_CANCEL_FID1;
 	rc = md_create(tgt->ltd_exp, op_data, data, datalen, mode, uid, gid,
@@ -2063,10 +2046,20 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(child_tgt))
 		return PTR_ERR(child_tgt);
 
-	if (!S_ISDIR(op_data->op_mode) && tp_tgt)
-		rc = __lmv_fid_alloc(lmv, &target_fid, tp_tgt->ltd_index);
-	else
-		rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
+	/* for directory, migrate to MDT specified by lum_stripe_offset;
+	 * otherwise migrate to the target stripe of parent, but parent
+	 * directory may have finished migration (normally current file too),
+	 * allocate FID on MDT lum_stripe_offset, and server will check
+	 * whether file was migrated already.
+	 */
+	if (S_ISDIR(op_data->op_mode) || !tp_tgt) {
+		struct lmv_user_md *lum = op_data->op_data;
+
+		op_data->op_mds = le32_to_cpu(lum->lum_stripe_offset);
+	} else  {
+		op_data->op_mds = tp_tgt->ltd_index;
+	}
+	rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
 	if (rc)
 		return rc;
 
@@ -3071,7 +3064,7 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 		 * set default value -1, so lmv_locate_tgt() knows this stripe
 		 * target is not initialized.
 		 */
-		lsm->lsm_md_oinfo[i].lmo_mds = (u32)-1;
+		lsm->lsm_md_oinfo[i].lmo_mds = LMV_OFFSET_DEFAULT;
 		if (!fid_is_sane(&lsm->lsm_md_oinfo[i].lmo_fid))
 			continue;
 
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 60c50a0..5a141ce 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -106,10 +106,6 @@ int lu_qos_add_tgt(struct lu_qos *qos, struct lu_tgt_desc *tgt)
 	u32 id = 0;
 	int rc = 0;
 
-	/* tgt not connected, this function will be called again later */
-	if (!exp)
-		return 0;
-
 	down_write(&qos->lq_rw_sem);
 	/*
 	 * a bit hacky approach to learn NID of corresponding connection
@@ -528,7 +524,7 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 		 * per-tgt penalty is
 		 * prio * bavail * iavail / (num_tgt - 1) / 2
 		 */
-		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia;
+		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia >> 8;
 		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active);
 		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
 
@@ -562,8 +558,9 @@ int ltd_qos_penalties_calc(struct lu_tgt_descs *ltd)
 	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
 		ba = svr->lsq_bavail;
 		ia = svr->lsq_iavail;
-		svr->lsq_penalty_per_obj = prio_wide * ba  * ia;
-		do_div(ba, svr->lsq_tgt_count * num_active);
+		svr->lsq_penalty_per_obj = prio_wide * ba  * ia >> 8;
+		do_div(svr->lsq_penalty_per_obj,
+		       svr->lsq_tgt_count * num_active);
 		svr->lsq_penalty_per_obj >>= 1;
 
 		age = (now - svr->lsq_used) >> 3;
@@ -656,6 +653,7 @@ int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
 		if (!tgt->ltd_active)
 			continue;
 
+		ltq = &tgt->ltd_qos;
 		if (ltq->ltq_penalty < ltq->ltq_penalty_per_obj)
 			ltq->ltq_penalty = 0;
 		else
@@ -668,9 +666,10 @@ int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
 			*total_wt += ltq->ltq_weight;
 
 		CDEBUG(D_OTHER,
-		       "recalc tgt %d usable=%d avail=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
+		       "recalc tgt %d usable=%d bavail=%llu ffree=%llu tgtppo=%llu tgtp=%llu svrppo=%llu svrp=%llu wt=%llu\n",
 		       tgt->ltd_index, ltq->ltq_usable,
-		       tgt_statfs_bavail(tgt) >> 10,
+		       tgt_statfs_bavail(tgt) >> 16,
+			  tgt_statfs_iavail(tgt) >> 8,
 		       ltq->ltq_penalty_per_obj >> 10,
 		       ltq->ltq_penalty >> 10,
 		       ltq->ltq_svr->lsq_penalty_per_obj >> 10,
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index da51dc1..671878d 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1663,7 +1663,6 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LMV_MAGIC_V1 != 0x0CD20CD0);
 	BUILD_BUG_ON(LMV_MAGIC_STRIPE != 0x0CD40CD0);
 	BUILD_BUG_ON(LMV_HASH_TYPE_MASK != 0x0000ffff);
-	BUILD_BUG_ON(LMV_HASH_FLAG_SPACE != 0x08000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_MIGRATION != 0x80000000);
 
 	/* Checks for struct obd_statfs */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 2178666..b46f52b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -429,6 +429,7 @@ static inline bool lov_pattern_supported_normal_comp(__u32 pattern)
 #define LOV_MAXPOOLNAME 15
 #define LOV_POOLNAMEF "%.15s"
 #define LOV_OFFSET_DEFAULT      ((__u16)-1)
+#define LMV_OFFSET_DEFAULT      ((__u32)-1)
 
 #define LOV_MIN_STRIPE_BITS	16	/* maximum PAGE_SIZE (ia64), power of 2 */
 #define LOV_MIN_STRIPE_SIZE	(1 << LOV_MIN_STRIPE_BITS)
@@ -687,10 +688,11 @@ enum lmv_hash_type {
  */
 #define LMV_HASH_TYPE_MASK		0x0000ffff
 
-/* once this is set on a plain directory default layout, newly created
- * subdirectories will be distributed on all MDTs by space usage.
- */
-#define LMV_HASH_FLAG_SPACE		0x08000000
+static inline bool lmv_is_known_hash_type(__u32 type)
+{
+	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
+	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
+}
 
 /* The striped directory has ever lost its master LMV EA, then LFSCK
  * re-generated it. This flag is used to indicate such case. It is an
-- 
1.8.3.1
