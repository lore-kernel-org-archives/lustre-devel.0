From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:27 -0500
Subject: [lustre-devel] [PATCH 279/622] lustre: lmv: new foreign LMV format
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-280-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

This patch introduces a new striping/LMV format in order to
allow to specify an arbitrary external reference for a dir
in Lustre namespace.
The new LMV format is made of {newmagic, length, type, flags,
string[length]} to be as flexible as possible.
Foreign dir can be created by using the ioctl(LL_IOC_LMV_SETDIRSTRIPE)
operation and it can only be and remain an empty dir until removed.

The idea behind this is to provide Lustre namespace support and
striping prefetch/caching under lock protection, for user/external
usage.

This patch is the LMV/dirs complement of LOV/files previous change
(lustre: lov: new foreign LOV format) has been rebased on top of
the latter along with some with obvious mutualizations and
simplifications.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11376
Lustre-commit: fdad38781ccc ("LU-11376 lmv: new foreign LMV format")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/34087
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h          |  7 +++
 fs/lustre/include/obd.h                 |  5 +-
 fs/lustre/llite/dir.c                   | 94 +++++++++++++++++++++++++++++----
 fs/lustre/llite/file.c                  |  5 ++
 fs/lustre/llite/llite_lib.c             | 20 +++++--
 fs/lustre/lmv/lmv_intent.c              | 14 +++++
 fs/lustre/lmv/lmv_obd.c                 | 50 +++++++++++++++++-
 fs/lustre/mdc/mdc_request.c             | 17 ++++--
 fs/lustre/ptlrpc/pack_generic.c         |  9 +++-
 include/uapi/linux/lustre/lustre_idl.h  | 11 ++++
 include/uapi/linux/lustre/lustre_user.h | 31 +++++++----
 11 files changed, 232 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 1246c25..cef315d 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -189,4 +189,11 @@ static inline bool lmv_is_known_hash_type(u32 type)
 	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
 }
 
+static inline bool lmv_magic_supported(u32 lum_magic)
+{
+	return lum_magic == LMV_USER_MAGIC ||
+	       lum_magic == LMV_USER_MAGIC_SPECIFIC ||
+	       lum_magic == LMV_MAGIC_FOREIGN;
+}
+
 #endif
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 687b54b..996211a 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -929,7 +929,10 @@ struct obd_ops {
 struct lustre_md {
 	struct mdt_body			*body;
 	struct lu_buf			 layout;
-	struct lmv_stripe_md		*lmv;
+	union {
+		struct lmv_stripe_md	*lmv;
+		struct lmv_foreign_md   *lfm;
+	};
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	struct posix_acl		*posix_acl;
 #endif
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 8293a01..fd7cd2d 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -346,6 +346,14 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 		rc = PTR_ERR(op_data);
 		goto out;
 	}
+
+	/* foreign dirs are browsed out of Lustre */
+	if (unlikely(op_data->op_mea1 &&
+		     op_data->op_mea1->lsm_md_magic == LMV_MAGIC_FOREIGN)) {
+		ll_finish_md_op_data(op_data);
+		return -ENODATA;
+	}
+
 	op_data->op_fid3 = pfid;
 
 	ctx->pos = pos;
@@ -421,14 +429,22 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	};
 	int err;
 
-	if (unlikely(lump->lum_magic != LMV_USER_MAGIC &&
-		     lump->lum_magic != LMV_USER_MAGIC_SPECIFIC))
+	if (unlikely(!lmv_magic_supported(lump->lum_magic)))
 		return -EINVAL;
 
-	CDEBUG(D_VFSTRACE,
-	       "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d, stripe_count: %u\n",
-	       PFID(ll_inode2fid(parent)), parent, dirname,
-	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
+	if (lump->lum_magic != LMV_MAGIC_FOREIGN) {
+		CDEBUG(D_VFSTRACE,
+		       "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d, stripe_count: %u\n",
+		       PFID(ll_inode2fid(parent)), parent, dirname,
+		       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
+	} else {
+		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lump;
+
+		CDEBUG(D_VFSTRACE,
+		       "VFS Op:inode=" DFID "(%p) name %s foreign, length %u, value '%.*s'\n",
+		       PFID(ll_inode2fid(parent)), parent, dirname,
+		       lfm->lfm_length, lfm->lfm_length, lfm->lfm_value);
+	}
 
 	if (lump->lum_stripe_count > 1 &&
 	    !(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_DIR_STRIPE))
@@ -438,8 +454,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	    !OBD_FAIL_CHECK(OBD_FAIL_LLITE_NO_CHECK_DEAD))
 		return -ENOENT;
 
-	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC) &&
-	    lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC_SPECIFIC))
+	if (unlikely(!lmv_magic_supported(cpu_to_le32(lump->lum_magic))))
 		lustre_swab_lmv_user_md(lump);
 
 	if (!IS_POSIXACL(parent) || !exp_connect_umask(ll_i2mdexp(parent)))
@@ -721,6 +736,17 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 			}
 		}
 		break;
+	case LMV_MAGIC_FOREIGN: {
+		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lmm;
+
+		if (cpu_to_le32(LMV_MAGIC_FOREIGN) != LMV_MAGIC_FOREIGN) {
+			__swab32s(&lfm->lfm_magic);
+			__swab32s(&lfm->lfm_length);
+			__swab32s(&lfm->lfm_type);
+			__swab32s(&lfm->lfm_flags);
+		}
+		break;
+	}
 	default:
 		CERROR("unknown magic: %lX\n", (unsigned long)lmm->lmm_magic);
 		rc = -EPROTO;
@@ -1313,9 +1339,24 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		lum = (struct lmv_user_md *)data->ioc_inlbuf2;
 		lumlen = data->ioc_inllen2;
 
-		if ((lum->lum_magic != LMV_USER_MAGIC &&
-		     lum->lum_magic != LMV_USER_MAGIC_SPECIFIC) ||
+		if (!lmv_magic_supported(lum->lum_magic)) {
+			CERROR("%s: wrong lum magic %x : rc = %d\n", filename,
+			       lum->lum_magic, -EINVAL);
+			rc = -EINVAL;
+			goto lmv_out_free;
+		}
+
+		if ((lum->lum_magic == LMV_USER_MAGIC ||
+		     lum->lum_magic == LMV_USER_MAGIC_SPECIFIC) &&
 		    lumlen < sizeof(*lum)) {
+			CERROR("%s: wrong lum size %d for magic %x : rc = %d\n",
+			       filename, lumlen, lum->lum_magic, -EINVAL);
+			rc = -EINVAL;
+			goto lmv_out_free;
+		}
+
+		if (lum->lum_magic == LMV_MAGIC_FOREIGN &&
+		    lumlen < sizeof(struct lmv_foreign_md)) {
 			CERROR("%s: wrong lum magic %x or size %d: rc = %d\n",
 			       filename, lum->lum_magic, lumlen, -EFAULT);
 			rc = -EINVAL;
@@ -1447,7 +1488,25 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto finish_req;
 		}
 
-		stripe_count = lmv_mds_md_stripe_count_get(lmm);
+		/* if foreign LMV case, fake stripes number */
+		if (lmm->lmv_magic == LMV_MAGIC_FOREIGN) {
+			struct lmv_foreign_md *lfm;
+
+			lfm = (struct lmv_foreign_md *)lmm;
+			if (lfm->lfm_length < XATTR_SIZE_MAX -
+			    offsetof(typeof(*lfm), lfm_value)) {
+				u32 size = lfm->lfm_length +
+					   offsetof(typeof(*lfm), lfm_value);
+
+				stripe_count = lmv_foreign_to_md_stripes(size);
+			} else {
+				CERROR("invalid %d foreign size returned\n",
+					    lfm->lfm_length);
+				return -EINVAL;
+			}
+		} else {
+			stripe_count = lmv_mds_md_stripe_count_get(lmm);
+		}
 		if (max_stripe_count < stripe_count) {
 			lum.lum_stripe_count = stripe_count;
 			if (copy_to_user(ulmv, &lum, sizeof(lum))) {
@@ -1458,6 +1517,19 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto finish_req;
 		}
 
+		/* enough room on user side and foreign case */
+		if (lmm->lmv_magic == LMV_MAGIC_FOREIGN) {
+			struct lmv_foreign_md *lfm;
+			u32 size;
+
+			lfm = (struct lmv_foreign_md *)lmm;
+			size = lfm->lfm_length +
+			       offsetof(struct lmv_foreign_md, lfm_value);
+			if (copy_to_user(ulmv, lfm, size))
+				rc = -EFAULT;
+			goto finish_req;
+		}
+
 		lum_size = lmv_user_md_size(stripe_count,
 					    LMV_USER_MAGIC_SPECIFIC);
 		tmp = kzalloc(lum_size, GFP_NOFS);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0d7d566..76d3b4c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4249,6 +4249,11 @@ static int ll_merge_md_attr(struct inode *inode)
 	int rc;
 
 	LASSERT(lli->lli_lsm_md);
+
+	/* foreign dir is not striped dir */
+	if (lli->lli_lsm_md->lsm_md_magic == LMV_MAGIC_FOREIGN)
+		return 0;
+
 	down_read(&lli->lli_lsm_sem);
 	rc = md_merge_attr(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
 			   &attr, ll_md_blocking_ast);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index fd19035..21825251 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1329,8 +1329,12 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	/*
 	 * if dir layout mismatch, check whether version is increased, which
 	 * means layout is changed, this happens in dir migration and lfsck.
+	 *
+	 * foreign LMV should not change.
 	 */
-	if (lli->lli_lsm_md && !lsm_md_eq(lli->lli_lsm_md, lsm)) {
+	if (lli->lli_lsm_md &&
+	    lli->lli_lsm_md->lsm_md_magic != LMV_MAGIC_FOREIGN &&
+	   !lsm_md_eq(lli->lli_lsm_md, lsm)) {
 		if (lsm->lsm_md_layout_version <=
 		    lli->lli_lsm_md->lsm_md_layout_version) {
 			CERROR("%s: " DFID " dir layout mismatch:\n",
@@ -1352,6 +1356,16 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	if (!lli->lli_lsm_md) {
 		struct cl_attr *attr;
 
+		if (lsm->lsm_md_magic == LMV_MAGIC_FOREIGN) {
+			/* set md->lmv to NULL, so the following free lustre_md
+			 * will not free this lsm
+			 */
+			md->lmv = NULL;
+			lli->lli_lsm_md = lsm;
+			up_write(&lli->lli_lsm_sem);
+			return 0;
+		}
+
 		rc = ll_init_lsm_md(inode, md);
 		up_write(&lli->lli_lsm_sem);
 		if (rc)
@@ -2297,7 +2311,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	rc = md_get_lustre_md(sbi->ll_md_exp, req, sbi->ll_dt_exp,
 			      sbi->ll_md_exp, &md);
 	if (rc)
-		goto cleanup;
+		goto out;
 
 	if (*inode) {
 		rc = ll_update_inode(*inode, &md);
@@ -2365,8 +2379,8 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	}
 
 out:
+	/* cleanup will be done if necessary */
 	md_free_lustre_md(sbi->ll_md_exp, &md);
-cleanup:
 	if (rc != 0 && it && it->it_op & IT_OPEN)
 		ll_open_cleanup(sb ? sb : (*inode)->i_sb, req);
 
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 45f1ac5..84a21a0 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -276,6 +276,11 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	u64 flags = it->it_flags;
 	int rc;
 
+	/* do not allow file creation in foreign dir */
+	if ((it->it_op & IT_CREAT) && op_data->op_mea1 &&
+	    op_data->op_mea1->lsm_md_magic == LMV_MAGIC_FOREIGN)
+		return -ENODATA;
+
 	if ((it->it_op & IT_CREAT) && !(flags & MDS_OPEN_BY_FID)) {
 		/* don't allow create under dir with bad hash */
 		if (lmv_is_dir_bad_hash(op_data->op_mea1))
@@ -426,6 +431,15 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	struct mdt_body	*body;
 	int rc;
 
+	/* foreign dir is not striped */
+	if (op_data->op_mea1 &&
+	    op_data->op_mea1->lsm_md_magic == LMV_MAGIC_FOREIGN) {
+		/* only allow getattr/lookup for itself */
+		if (op_data->op_name)
+			return -ENODATA;
+		return 0;
+	}
+
 retry:
 	tgt = lmv_locate_tgt(lmv, op_data, &op_data->op_fid1);
 	if (IS_ERR(tgt))
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 9f3d6de..dc4bd1e 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1166,15 +1166,22 @@ static int lmv_placement_policy(struct obd_device *obd,
 	 * 2. Then check if there is default stripe offset.
 	 * 3. Finally choose MDS by name hash if the parent
 	 *    is striped directory. (see lmv_locate_tgt()).
+	 *
+	 * presently explicit MDT location is not supported
+	 * for foreign dirs (as it can't be embedded into free
+	 * format LMV, like with lum_stripe_offset), so we only
+	 * rely on default stripe offset or then name hashing.
 	 */
 	if (op_data->op_cli_flags & CLI_SET_MEA && lum &&
+	    le32_to_cpu(lum->lum_magic != LMV_MAGIC_FOREIGN) &&
 	    le32_to_cpu(lum->lum_stripe_offset) != (u32)-1) {
 		*mds = le32_to_cpu(lum->lum_stripe_offset);
 	} else if (op_data->op_default_stripe_offset != (u32)-1) {
 		*mds = op_data->op_default_stripe_offset;
 		op_data->op_mds = *mds;
 		/* Correct the stripe offset in lum */
-		if (lum)
+		if (lum &&
+		    le32_to_cpu(lum->lum_magic != LMV_MAGIC_FOREIGN))
 			lum->lum_stripe_offset = cpu_to_le32(*mds);
 	} else {
 		*mds = op_data->op_mds;
@@ -1606,6 +1613,10 @@ struct lmv_tgt_desc*
 	struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
+	/* foreign dir is not striped dir */
+	if (lsm && lsm->lsm_md_magic == LMV_MAGIC_FOREIGN)
+		return ERR_PTR(-ENODATA);
+
 	/*
 	 * During creating VOLATILE file, it should honor the mdt
 	 * index if the file under striped dir is being restored, see
@@ -2657,6 +2668,10 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_tgt_desc *tgt;
 
 	if (unlikely(lsm)) {
+		/* foreign dir is not striped dir */
+		if (lsm->lsm_md_magic == LMV_MAGIC_FOREIGN)
+			return -ENODATA;
+
 		return lmv_striped_read_page(exp, op_data, cb_op,
 					     offset, ppage);
 	}
@@ -2962,6 +2977,16 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	/* Free memmd */
 	if (lsm && !lmm) {
 		int i;
+		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lsm;
+
+		if (lfm->lfm_magic == LMV_MAGIC_FOREIGN) {
+			size_t lfm_size;
+
+			lfm_size = lfm->lfm_length + offsetof(typeof(*lfm),
+							      lfm_value[0]);
+			kvfree(lfm);
+			return 0;
+		}
 
 		for (i = 0; i < lsm->lsm_md_stripe_count; i++)
 			iput(lsm->lsm_md_oinfo[i].lmo_root);
@@ -2971,6 +2996,25 @@ static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		return 0;
 	}
 
+	/* foreign lmv case */
+	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_FOREIGN) {
+		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lsm;
+
+		if (!lfm) {
+			lfm = kvzalloc(lmm_size, GFP_NOFS);
+			if (!lfm)
+				return -ENOMEM;
+			*lsmp = (struct lmv_stripe_md *)lfm;
+		}
+		lfm->lfm_magic = le32_to_cpu(lmm->lmv_foreign_md.lfm_magic);
+		lfm->lfm_length = le32_to_cpu(lmm->lmv_foreign_md.lfm_length);
+		lfm->lfm_type = le32_to_cpu(lmm->lmv_foreign_md.lfm_type);
+		lfm->lfm_flags = le32_to_cpu(lmm->lmv_foreign_md.lfm_flags);
+		memcpy(&lfm->lfm_value, &lmm->lmv_foreign_md.lfm_value,
+		       lfm->lfm_length);
+		return lmm_size;
+	}
+
 	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_STRIPE)
 		return -EPERM;
 
@@ -3279,6 +3323,10 @@ static int lmv_merge_attr(struct obd_export *exp,
 {
 	int rc, i;
 
+	/* foreign dir is not striped dir */
+	if (lsm->lsm_md_magic == LMV_MAGIC_FOREIGN)
+		return 0;
+
 	rc = lmv_revalidate_slaves(exp, lsm, cb_blocking, 0);
 	if (rc < 0)
 		return rc;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 5931bc1..57da3c3 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -613,11 +613,18 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 				goto out;
 
 			if (rc < (typeof(rc))sizeof(*md->lmv)) {
-				CDEBUG(D_INFO,
-				       "size too small: rc < sizeof(*md->lmv) (%d < %d)\n",
-					rc, (int)sizeof(*md->lmv));
-				rc = -EPROTO;
-				goto out;
+				struct lmv_foreign_md *lfm = md->lfm;
+
+				/* short (< sizeof(struct lmv_stripe_md))
+				 * foreign LMV case
+				 */
+				if (lfm->lfm_magic != LMV_MAGIC_FOREIGN) {
+					CDEBUG(D_INFO,
+					       "size too small: rc < sizeof(*md->lmv) (%d < %d)\n",
+					       rc, (int)sizeof(*md->lmv));
+					rc = -EPROTO;
+					goto out;
+				}
 			}
 		}
 	}
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 231cb26..a4f28f3 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1974,8 +1974,15 @@ void lustre_swab_lmv_user_md_objects(struct lmv_user_mds_data *lmd,
 
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 {
-	u32 count = lum->lum_stripe_count;
+	u32 count;
 
+	if (lum->lum_magic == LMV_MAGIC_FOREIGN) {
+		__swab32s(&lum->lum_magic);
+		__swab32s(&((struct lmv_foreign_md *)lum)->lfm_length);
+		return;
+	}
+
+	count = lum->lum_stripe_count;
 	__swab32s(&lum->lum_magic);
 	__swab32s(&lum->lum_stripe_count);
 	__swab32s(&lum->lum_stripe_offset);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index fd35023..f7ea744 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1976,11 +1976,21 @@ struct lmv_mds_md_v1 {
 	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
 };
 
+/* foreign LMV EA */
+struct lmv_foreign_md {
+	__u32 lfm_magic;	/* magic number = LMV_MAGIC_FOREIGN */
+	__u32 lfm_length;	/* length of lfm_value */
+	__u32 lfm_type;		/* type, see LU_FOREIGN_TYPE_ */
+	__u32 lfm_flags;	/* flags, type specific */
+	char lfm_value[];	/* free format value */
+};
+
 #define LMV_MAGIC_V1	 0x0CD20CD0	/* normal stripe lmv magic */
 #define LMV_MAGIC	 LMV_MAGIC_V1
 
 /* #define LMV_USER_MAGIC 0x0CD30CD0 */
 #define LMV_MAGIC_STRIPE 0x0CD40CD0	/* magic for dir sub_stripe */
+#define LMV_MAGIC_FOREIGN 0x0CD50CD0	/* magic for lmv foreign */
 
 /*
  *Right now only the lower part(0-16bits) of lmv_hash_type is being used,
@@ -2025,6 +2035,7 @@ static inline __u64 lustre_hash_fnv_1a_64(const void *buf, size_t size)
 	__u32			lmv_magic;
 	struct lmv_mds_md_v1	lmv_md_v1;
 	struct lmv_user_md	lmv_user_md;
+	struct lmv_foreign_md	lmv_foreign_md;
 };
 
 static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index ad5d446..03ec680 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -474,7 +474,7 @@ struct lov_user_md_v3 {		/* LOV EA user data (host-endian) */
 struct lov_foreign_md {
 	__u32 lfm_magic;	/* magic number = LOV_MAGIC_FOREIGN */
 	__u32 lfm_length;	/* length of lfm_value */
-	__u32 lfm_type;		/* type, see LOV_FOREIGN_TYPE_ */
+	__u32 lfm_type;		/* type, see LU_FOREIGN_TYPE_ */
 	__u32 lfm_flags;	/* flags, type specific */
 	char lfm_value[];
 };
@@ -645,19 +645,22 @@ enum lmv_hash_type {
 #define LMV_HASH_NAME_ALL_CHARS		"all_char"
 #define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
 
-/**
- * LOV foreign types
- **/
-#define LOV_FOREIGN_TYPE_NONE 0
-#define LOV_FOREIGN_TYPE_DAOS 0xda05
-#define LOV_FOREIGN_TYPE_UNKNOWN UINT32_MAX
-
 struct lustre_foreign_type {
 	uint32_t lft_type;
 	const char *lft_name;
 };
 
-extern struct lustre_foreign_type lov_foreign_type[];
+/**
+ * LOV/LMV foreign types
+ **/
+enum lustre_foreign_types {
+	LU_FOREIGN_TYPE_NONE = 0,
+	LU_FOREIGN_TYPE_DAOS = 0xda05,
+	/* must be the max/last one */
+	LU_FOREIGN_TYPE_UNKNOWN = 0xffffffff,
+};
+
+extern struct lustre_foreign_type lu_foreign_types[];
 
 /*
  * Got this according to how get LOV_MAX_STRIPE_COUNT, see above,
@@ -678,6 +681,16 @@ struct lmv_user_md_v1 {
 	struct lmv_user_mds_data  lum_objects[0];
 } __packed;
 
+static inline __u32 lmv_foreign_to_md_stripes(__u32 size)
+{
+	if (size <= sizeof(struct lmv_user_md))
+		return 0;
+
+	size -= sizeof(struct lmv_user_md);
+	return (size + sizeof(struct lmv_user_mds_data) - 1) /
+	       sizeof(struct lmv_user_mds_data);
+}
+
 static inline int lmv_user_md_size(int stripes, int lmm_magic)
 {
 	int size = sizeof(struct lmv_user_md);
-- 
1.8.3.1
