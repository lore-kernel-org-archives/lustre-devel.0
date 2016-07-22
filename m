From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:20 -0400
Subject: [lustre-devel] [PATCH 27/58] staging: lustre: lmv: change handling
	of lmv striping information
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The lmv_[un]pack_md function are used to calculate the
size of the data used to represent the LMV striping data.
The original code was straight forward in its calculate
with lmv_get_easize since only one type of data format
could exist. We want to be able to support different
version of this data in the future so this patch moves
to generating the size of the data using the stripe count
and which LMV_MAGIC_* version.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    4 -
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   15 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    7 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  245 +++++++++++++++-----
 4 files changed, 198 insertions(+), 73 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 5f31724..0ad6605 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2482,10 +2482,6 @@ struct lmv_desc {
 	struct obd_uuid ld_uuid;
 };
 
-#define MEA_MAGIC_LAST_CHAR      0xb2221ca1
-#define MEA_MAGIC_ALL_CHARS      0xb222a11c
-#define MEA_MAGIC_HASH_SEGMENT   0xb222a11b
-
 /* lmv structures */
 #define LMV_MAGIC_V1	0x0CD10CD0	/* normal stripe lmv magic */
 #define LMV_USER_MAGIC	0x0CD20CD0	/* default lmv magic*/
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 0620c8c..784d67b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -41,12 +41,15 @@ struct lmv_oinfo {
 };
 
 struct lmv_stripe_md {
-	__u32	mea_magic;
-	__u32	mea_count;
-	__u32	mea_master;
-	__u32	mea_padding;
-	char	mea_pool_name[LOV_MAXPOOLNAME];
-	struct lu_fid mea_ids[0];
+	__u32	lsm_md_magic;
+	__u32	lsm_md_stripe_count;
+	__u32	lsm_md_master_mdt_index;
+	__u32	lsm_md_hash_type;
+	__u32	lsm_md_layout_version;
+	__u32	lsm_md_default_count;
+	__u32	lsm_md_default_index;
+	char	lsm_md_pool_name[LOV_MAXPOOLNAME];
+	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
 union lmv_mds_md;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index ab01560..90a9786 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -94,6 +94,13 @@ lmv_find_target(struct lmv_obd *lmv, const struct lu_fid *fid)
 	return lmv_get_target(lmv, mds);
 }
 
+static inline int lmv_stripe_md_size(int stripe_count)
+{
+	struct lmv_stripe_md *lsm;
+
+	return sizeof(*lsm) + stripe_count * sizeof(lsm->lsm_md_oinfo[0]);
+}
+
 struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 8e83263..1ba5900 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2376,105 +2376,224 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	return -EINVAL;
 }
 
-static int lmv_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
-		      struct lov_stripe_md *lsm)
+static int lmv_pack_md_v1(const struct lmv_stripe_md *lsm,
+			  struct lmv_mds_md_v1 *lmm1)
 {
-	struct obd_device	 *obd = class_exp2obd(exp);
-	struct lmv_obd	    *lmv = &obd->u.lmv;
-	struct lmv_stripe_md      *meap;
-	struct lmv_stripe_md      *lsmp;
-	int			mea_size;
-	int			i;
+	int cplen;
+	int i;
+
+	lmm1->lmv_magic = cpu_to_le32(lsm->lsm_md_magic);
+	lmm1->lmv_stripe_count = cpu_to_le32(lsm->lsm_md_stripe_count);
+	lmm1->lmv_master_mdt_index = cpu_to_le32(lsm->lsm_md_master_mdt_index);
+	lmm1->lmv_hash_type = cpu_to_le32(lsm->lsm_md_hash_type);
+	cplen = strlcpy(lmm1->lmv_pool_name, lsm->lsm_md_pool_name,
+			sizeof(lmm1->lmv_pool_name));
+	if (cplen >= sizeof(lmm1->lmv_pool_name))
+		return -E2BIG;
+
+	for (i = 0; i < lsm->lsm_md_stripe_count; i++)
+		fid_cpu_to_le(&lmm1->lmv_stripe_fids[i],
+			      &lsm->lsm_md_oinfo[i].lmo_fid);
+	return 0;
+}
+
+int lmv_pack_md(union lmv_mds_md **lmmp, const struct lmv_stripe_md *lsm,
+		int stripe_count)
+{
+	int lmm_size = 0, rc = 0;
+	bool allocated = false;
 
-	mea_size = lmv_get_easize(lmv);
-	if (!lmmp)
-		return mea_size;
+	LASSERT(lmmp);
 
+	/* Free lmm */
 	if (*lmmp && !lsm) {
+		int stripe_cnt;
+
+		stripe_cnt = lmv_mds_md_stripe_count_get(*lmmp);
+		lmm_size = lmv_mds_md_size(stripe_cnt,
+					   le32_to_cpu((*lmmp)->lmv_magic));
+		if (!lmm_size)
+			return -EINVAL;
 		kvfree(*lmmp);
 		*lmmp = NULL;
 		return 0;
 	}
 
+	/* Alloc lmm */
+	if (!*lmmp && !lsm) {
+		lmm_size = lmv_mds_md_size(stripe_count, LMV_MAGIC);
+		LASSERT(lmm_size > 0);
+		*lmmp = libcfs_kvzalloc(lmm_size, GFP_NOFS);
+		if (!*lmmp)
+			return -ENOMEM;
+		lmv_mds_md_stripe_count_set(*lmmp, stripe_count);
+		(*lmmp)->lmv_magic = cpu_to_le32(LMV_MAGIC);
+		return lmm_size;
+	}
+
+	/* pack lmm */
+	LASSERT(lsm);
+	lmm_size = lmv_mds_md_size(lsm->lsm_md_stripe_count,
+				   lsm->lsm_md_magic);
 	if (!*lmmp) {
-		*lmmp = libcfs_kvzalloc(mea_size, GFP_NOFS);
+		*lmmp = libcfs_kvzalloc(lmm_size, GFP_NOFS);
 		if (!*lmmp)
 			return -ENOMEM;
+		allocated = true;
 	}
 
-	if (!lsm)
-		return mea_size;
+	switch (lsm->lsm_md_magic) {
+	case LMV_MAGIC_V1:
+		rc = lmv_pack_md_v1(lsm, &(*lmmp)->lmv_md_v1);
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
 
-	lsmp = (struct lmv_stripe_md *)lsm;
-	meap = (struct lmv_stripe_md *)*lmmp;
+	if (rc && allocated) {
+		kvfree(*lmmp);
+		*lmmp = NULL;
+	}
 
-	if (lsmp->mea_magic != MEA_MAGIC_LAST_CHAR &&
-	    lsmp->mea_magic != MEA_MAGIC_ALL_CHARS)
-		return -EINVAL;
+	return lmm_size;
+}
+EXPORT_SYMBOL(lmv_pack_md);
 
-	meap->mea_magic = cpu_to_le32(lsmp->mea_magic);
-	meap->mea_count = cpu_to_le32(lsmp->mea_count);
-	meap->mea_master = cpu_to_le32(lsmp->mea_master);
+static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
+			    const struct lmv_mds_md_v1 *lmm1)
+{
+	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
+	int stripe_count;
+	int rc = 0;
+	int cplen;
+	int i;
 
-	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		meap->mea_ids[i] = lsmp->mea_ids[i];
-		fid_cpu_to_le(&meap->mea_ids[i], &lsmp->mea_ids[i]);
+	lsm->lsm_md_magic = le32_to_cpu(lmm1->lmv_magic);
+	lsm->lsm_md_stripe_count = le32_to_cpu(lmm1->lmv_stripe_count);
+	lsm->lsm_md_master_mdt_index = le32_to_cpu(lmm1->lmv_master_mdt_index);
+	lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
+	lsm->lsm_md_layout_version = le32_to_cpu(lmm1->lmv_layout_version);
+	cplen = strlcpy(lsm->lsm_md_pool_name, lmm1->lmv_pool_name,
+			sizeof(lsm->lsm_md_pool_name));
+
+	if (cplen >= sizeof(lsm->lsm_md_pool_name))
+		return -E2BIG;
+
+	CDEBUG(D_INFO, "unpack lsm count %d, master %d hash_type %d layout_version %d\n",
+	       lsm->lsm_md_stripe_count, lsm->lsm_md_master_mdt_index,
+	       lsm->lsm_md_hash_type, lsm->lsm_md_layout_version);
+
+	stripe_count = le32_to_cpu(lmm1->lmv_stripe_count);
+	for (i = 0; i < le32_to_cpu(stripe_count); i++) {
+		fid_le_to_cpu(&lsm->lsm_md_oinfo[i].lmo_fid,
+			      &lmm1->lmv_stripe_fids[i]);
+		rc = lmv_fld_lookup(lmv, &lsm->lsm_md_oinfo[i].lmo_fid,
+				    &lsm->lsm_md_oinfo[i].lmo_mds);
+		if (rc)
+			return rc;
+		CDEBUG(D_INFO, "unpack fid #%d "DFID"\n", i,
+		       PFID(&lsm->lsm_md_oinfo[i].lmo_fid));
 	}
 
-	return mea_size;
+	return rc;
 }
 
-static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
-			struct lov_mds_md *lmm, int lmm_size)
+int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
+		  const union lmv_mds_md *lmm, int stripe_count)
 {
-	struct obd_device	  *obd = class_exp2obd(exp);
-	struct lmv_stripe_md      **tmea = (struct lmv_stripe_md **)lsmp;
-	struct lmv_stripe_md       *mea = (struct lmv_stripe_md *)lmm;
-	struct lmv_obd	     *lmv = &obd->u.lmv;
-	int			 mea_size;
-	int			 i;
-	__u32		       magic;
+	struct lmv_stripe_md *lsm;
+	bool allocated = false;
+	int lsm_size, rc;
+
+	LASSERT(lsmp);
+
+	lsm = *lsmp;
+	/* Free memmd */
+	if (lsm && !lmm) {
+		int i;
 
-	mea_size = lmv_get_easize(lmv);
-	if (!lsmp)
-		return mea_size;
+		for (i = 1; i < lsm->lsm_md_stripe_count; i++) {
+			if (lsm->lsm_md_oinfo[i].lmo_root)
+				iput(lsm->lsm_md_oinfo[i].lmo_root);
+		}
 
-	if (*lsmp && !lmm) {
-		kvfree(*tmea);
+		kvfree(lsm);
 		*lsmp = NULL;
 		return 0;
 	}
 
-	LASSERT(mea_size == lmm_size);
+	/* Alloc memmd */
+	if (!lsm && !lmm) {
+		lsm_size = lmv_stripe_md_size(stripe_count);
+		lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
+		if (!lsm)
+			return -ENOMEM;
+		lsm->lsm_md_stripe_count = stripe_count;
+		*lsmp = lsm;
+		return 0;
+	}
 
-	*tmea = libcfs_kvzalloc(mea_size, GFP_NOFS);
-	if (!*tmea)
-		return -ENOMEM;
+	/* Unpack memmd */
+	if (le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_V1) {
+		CERROR("%s: invalid magic %x.\n", exp->exp_obd->obd_name,
+		       le32_to_cpu(lmm->lmv_magic));
+		return -EINVAL;
+	}
 
-	if (!lmm)
-		return mea_size;
+	lsm_size = lmv_stripe_md_size(lmv_mds_md_stripe_count_get(lmm));
+	if (!lsm) {
+		lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
+		if (!lsm)
+			return -ENOMEM;
+		allocated = true;
+		*lsmp = lsm;
+	}
 
-	if (mea->mea_magic == MEA_MAGIC_LAST_CHAR ||
-	    mea->mea_magic == MEA_MAGIC_ALL_CHARS ||
-	    mea->mea_magic == MEA_MAGIC_HASH_SEGMENT) {
-		magic = le32_to_cpu(mea->mea_magic);
-	} else {
-		/*
-		 * Old mea is not handled here.
-		 */
-		CERROR("Old not supportable EA is found\n");
-		LBUG();
+	switch (le32_to_cpu(lmm->lmv_magic)) {
+	case LMV_MAGIC_V1:
+		rc = lmv_unpack_md_v1(exp, lsm, &lmm->lmv_md_v1);
+		break;
+	default:
+		CERROR("%s: unrecognized magic %x\n", exp->exp_obd->obd_name,
+		       le32_to_cpu(lmm->lmv_magic));
+		rc = -EINVAL;
+		break;
 	}
 
-	(*tmea)->mea_magic = magic;
-	(*tmea)->mea_count = le32_to_cpu(mea->mea_count);
-	(*tmea)->mea_master = le32_to_cpu(mea->mea_master);
+	if (rc && allocated) {
+		kvfree(lsm);
+		*lsmp = NULL;
+		lsm_size = rc;
+	}
+	return lsm_size;
+}
 
-	for (i = 0; i < (*tmea)->mea_count; i++) {
-		(*tmea)->mea_ids[i] = mea->mea_ids[i];
-		fid_le_to_cpu(&(*tmea)->mea_ids[i], &(*tmea)->mea_ids[i]);
+int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
+		 struct lov_mds_md *lmm, int disk_len)
+{
+	return lmv_unpack_md(exp, (struct lmv_stripe_md **)lsmp,
+			     (union lmv_mds_md *)lmm, disk_len);
+}
+
+int lmv_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
+	       struct lov_stripe_md *lsm)
+{
+	const struct lmv_stripe_md *lmv = (struct lmv_stripe_md *)lsm;
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv_obd = &obd->u.lmv;
+	int stripe_count;
+
+	if (!lmmp) {
+		if (lsm)
+			stripe_count = lmv->lsm_md_stripe_count;
+		else
+			stripe_count = lmv_obd->desc.ld_tgt_count;
+
+		return lmv_mds_md_size(stripe_count, LMV_MAGIC_V1);
 	}
-	return mea_size;
+
+	return lmv_pack_md((union lmv_mds_md **)lmmp, lmv, 0);
 }
 
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
-- 
1.7.1
