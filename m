From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:23 -0400
Subject: [lustre-devel] [PATCH 27/41] staging: lustre: llite: add
	cl_object_maxbytes()
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add cl_object_maxbytes() to return the maximum supported size of a
cl_object. Remove the lli_maxbytes member from struct
ll_inode_info. Change the lsm_maxbytes member of struct lov_stripe_md
from __u64 to loff_t. Correct the computation of lsm_maxbytes in the
released layout case.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13694
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    5 +
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   10 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    8 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  191 +++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_object.c     |   17 ++
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   15 ++
 7 files changed, 130 insertions(+), 118 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index b80539d..dfef4bc 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -431,6 +431,10 @@ struct cl_object_operations {
 	 */
 	int (*coo_layout_get)(const struct lu_env *env, struct cl_object *obj,
 			      struct cl_layout *layout);
+	/**
+	 * Get maximum size of the object.
+	 */
+	loff_t (*coo_maxbytes)(struct cl_object *obj);
 };
 
 /**
@@ -2227,6 +2231,7 @@ int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		     size_t *buflen);
 int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
 			 struct cl_layout *cl);
+loff_t cl_object_maxbytes(struct cl_object *obj);
 
 /**
  * Returns true, iff \a o0 and \a o1 are slices of the same object.
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f254d88..8372deb 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -88,7 +88,7 @@ struct lov_stripe_md {
 	/* maximum possible file size, might change as OSTs status changes,
 	 * e.g. disconnected, deactivated
 	 */
-	__u64		lsm_maxbytes;
+	loff_t		lsm_maxbytes;
 	struct ost_id	lsm_oi;
 	__u32		lsm_magic;
 	__u32		lsm_stripe_size;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 913e532..cf95a72 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -185,7 +185,6 @@ struct ll_inode_info {
 		struct {
 			struct mutex			lli_size_mutex;
 			char			       *lli_symlink_name;
-			__u64				lli_maxbytes;
 			/*
 			 * struct rw_semaphore {
 			 *    signed long	count;     // align d.d_def_acl
@@ -988,9 +987,14 @@ static inline struct lu_fid *ll_inode2fid(struct inode *inode)
 	return fid;
 }
 
-static inline __u64 ll_file_maxbytes(struct inode *inode)
+static inline loff_t ll_file_maxbytes(struct inode *inode)
 {
-	return ll_i2info(inode)->lli_maxbytes;
+	struct cl_object *obj = ll_i2info(inode)->lli_clob;
+
+	if (!obj)
+		return MAX_LFS_FILESIZE;
+
+	return min_t(loff_t, cl_object_maxbytes(obj), MAX_LFS_FILESIZE);
 }
 
 /* llite/xattr.c */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5400cbe..25a06f8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -785,7 +785,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 {
 	lli->lli_inode_magic = LLI_INODE_MAGIC;
 	lli->lli_flags = 0;
-	lli->lli_maxbytes = MAX_LFS_FILESIZE;
 	spin_lock_init(&lli->lli_lock);
 	lli->lli_posix_acl = NULL;
 	/* Do not set lli_fid, it has been initialized already. */
@@ -1685,14 +1684,9 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
 	LASSERT((lsm != NULL) == ((body->mbo_valid & OBD_MD_FLEASIZE) != 0));
-	if (lsm) {
+	if (lsm)
 		cl_file_inode_init(inode, md);
 
-		lli->lli_maxbytes = lsm->lsm_maxbytes;
-		if (lli->lli_maxbytes > MAX_LFS_FILESIZE)
-			lli->lli_maxbytes = MAX_LFS_FILESIZE;
-	}
-
 	if (S_ISDIR(inode->i_mode)) {
 		int rc;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 214c561..63dcd29 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -117,9 +117,43 @@ void lsm_free_plain(struct lov_stripe_md *lsm)
 	kvfree(lsm);
 }
 
-static void lsm_unpackmd_common(struct lov_stripe_md *lsm,
-				struct lov_mds_md *lmm)
+/*
+ * Find minimum stripe maxbytes value.  For inactive or
+ * reconnecting targets use LUSTRE_EXT3_STRIPE_MAXBYTES.
+ */
+static loff_t lov_tgt_maxbytes(struct lov_tgt_desc *tgt)
+{
+	loff_t maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
+	struct obd_import *imp;
+
+	if (!tgt->ltd_active)
+		return maxbytes;
+
+	imp = tgt->ltd_obd->u.cli.cl_import;
+	if (!imp)
+		return maxbytes;
+
+	spin_lock(&imp->imp_lock);
+	if (imp->imp_state == LUSTRE_IMP_FULL &&
+	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES) &&
+	     imp->imp_connect_data.ocd_maxbytes > 0)
+		maxbytes = imp->imp_connect_data.ocd_maxbytes;
+
+	spin_unlock(&imp->imp_lock);
+
+	return maxbytes;
+}
+
+static int lsm_unpackmd_common(struct lov_obd *lov,
+			       struct lov_stripe_md *lsm,
+			       struct lov_mds_md *lmm,
+			       struct lov_ost_data_v1 *objects)
 {
+	loff_t stripe_maxbytes = LLONG_MAX;
+	unsigned int stripe_count;
+	struct lov_oinfo *loi;
+	unsigned int i;
+
 	/*
 	 * This supposes lov_mds_md_v1/v3 first fields are
 	 * are the same
@@ -129,6 +163,45 @@ static void lsm_unpackmd_common(struct lov_stripe_md *lsm,
 	lsm->lsm_pattern = le32_to_cpu(lmm->lmm_pattern);
 	lsm->lsm_layout_gen = le16_to_cpu(lmm->lmm_layout_gen);
 	lsm->lsm_pool_name[0] = '\0';
+
+	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
+
+	for (i = 0; i < stripe_count; i++) {
+		loff_t tgt_bytes;
+
+		loi = lsm->lsm_oinfo[i];
+		ostid_le_to_cpu(&objects[i].l_ost_oi, &loi->loi_oi);
+		loi->loi_ost_idx = le32_to_cpu(objects[i].l_ost_idx);
+		loi->loi_ost_gen = le32_to_cpu(objects[i].l_ost_gen);
+		if (lov_oinfo_is_dummy(loi))
+			continue;
+
+		if (loi->loi_ost_idx >= lov->desc.ld_tgt_count) {
+			CERROR("OST index %d more than OST count %d\n",
+			       loi->loi_ost_idx, lov->desc.ld_tgt_count);
+			lov_dump_lmm_v1(D_WARNING, lmm);
+			return -EINVAL;
+		}
+
+		if (!lov->lov_tgts[loi->loi_ost_idx]) {
+			CERROR("OST index %d missing\n", loi->loi_ost_idx);
+			lov_dump_lmm_v1(D_WARNING, lmm);
+			return -EINVAL;
+		}
+
+		tgt_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
+		stripe_maxbytes = min_t(loff_t, stripe_maxbytes, tgt_bytes);
+	}
+
+	if (stripe_maxbytes == LLONG_MAX)
+		stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
+
+	if (!lsm->lsm_stripe_count)
+		lsm->lsm_maxbytes = stripe_maxbytes * lov->desc.ld_tgt_count;
+	else
+		lsm->lsm_maxbytes = stripe_maxbytes * lsm->lsm_stripe_count;
+
+	return 0;
 }
 
 static void
@@ -147,30 +220,6 @@ lsm_stripe_by_offset_plain(struct lov_stripe_md *lsm, int *stripeno,
 		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
 }
 
-/* Find minimum stripe maxbytes value.  For inactive or
- * reconnecting targets use LUSTRE_EXT3_STRIPE_MAXBYTES.
- */
-static void lov_tgt_maxbytes(struct lov_tgt_desc *tgt, __u64 *stripe_maxbytes)
-{
-	struct obd_import *imp = tgt->ltd_obd->u.cli.cl_import;
-
-	if (!imp || !tgt->ltd_active) {
-		*stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
-		return;
-	}
-
-	spin_lock(&imp->imp_lock);
-	if (imp->imp_state == LUSTRE_IMP_FULL &&
-	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES) &&
-	    imp->imp_connect_data.ocd_maxbytes > 0) {
-		if (*stripe_maxbytes > imp->imp_connect_data.ocd_maxbytes)
-			*stripe_maxbytes = imp->imp_connect_data.ocd_maxbytes;
-	} else {
-		*stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
-	}
-	spin_unlock(&imp->imp_lock);
-}
-
 static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, int lmm_bytes,
 			     __u16 *stripe_count)
 {
@@ -197,45 +246,7 @@ static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, int lmm_bytes,
 static int lsm_unpackmd_v1(struct lov_obd *lov, struct lov_stripe_md *lsm,
 			   struct lov_mds_md_v1 *lmm)
 {
-	struct lov_oinfo *loi;
-	int i;
-	int stripe_count;
-	__u64 stripe_maxbytes = OBD_OBJECT_EOF;
-
-	lsm_unpackmd_common(lsm, lmm);
-
-	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
-
-	for (i = 0; i < stripe_count; i++) {
-		/* XXX LOV STACKING call down to osc_unpackmd() */
-		loi = lsm->lsm_oinfo[i];
-		ostid_le_to_cpu(&lmm->lmm_objects[i].l_ost_oi, &loi->loi_oi);
-		loi->loi_ost_idx = le32_to_cpu(lmm->lmm_objects[i].l_ost_idx);
-		loi->loi_ost_gen = le32_to_cpu(lmm->lmm_objects[i].l_ost_gen);
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (loi->loi_ost_idx >= lov->desc.ld_tgt_count) {
-			CERROR("OST index %d more than OST count %d\n",
-			       loi->loi_ost_idx, lov->desc.ld_tgt_count);
-			lov_dump_lmm_v1(D_WARNING, lmm);
-			return -EINVAL;
-		}
-		if (!lov->lov_tgts[loi->loi_ost_idx]) {
-			CERROR("OST index %d missing\n", loi->loi_ost_idx);
-			lov_dump_lmm_v1(D_WARNING, lmm);
-			return -EINVAL;
-		}
-		/* calculate the minimum stripe max bytes */
-		lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx],
-				 &stripe_maxbytes);
-	}
-
-	lsm->lsm_maxbytes = stripe_maxbytes * lsm->lsm_stripe_count;
-	if (lsm->lsm_stripe_count == 0)
-		lsm->lsm_maxbytes = stripe_maxbytes * lov->desc.ld_tgt_count;
-
-	return 0;
+	return lsm_unpackmd_common(lov, lsm, lmm, lmm->lmm_objects);
 }
 
 const struct lsm_operations lsm_v1_ops = {
@@ -275,55 +286,21 @@ static int lsm_lmm_verify_v3(struct lov_mds_md *lmmv1, int lmm_bytes,
 }
 
 static int lsm_unpackmd_v3(struct lov_obd *lov, struct lov_stripe_md *lsm,
-			   struct lov_mds_md *lmmv1)
+			   struct lov_mds_md *lmm)
 {
-	struct lov_mds_md_v3 *lmm;
-	struct lov_oinfo *loi;
-	int i;
-	int stripe_count;
-	__u64 stripe_maxbytes = OBD_OBJECT_EOF;
-	int cplen = 0;
-
-	lmm = (struct lov_mds_md_v3 *)lmmv1;
+	struct lov_mds_md_v3 *lmm_v3 = (struct lov_mds_md_v3 *)lmm;
+	size_t cplen = 0;
+	int rc;
 
-	lsm_unpackmd_common(lsm, (struct lov_mds_md_v1 *)lmm);
+	rc = lsm_unpackmd_common(lov, lsm, lmm, lmm_v3->lmm_objects);
+	if (rc)
+		return rc;
 
-	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
-
-	cplen = strlcpy(lsm->lsm_pool_name, lmm->lmm_pool_name,
+	cplen = strlcpy(lsm->lsm_pool_name, lmm_v3->lmm_pool_name,
 			sizeof(lsm->lsm_pool_name));
 	if (cplen >= sizeof(lsm->lsm_pool_name))
 		return -E2BIG;
 
-	for (i = 0; i < stripe_count; i++) {
-		/* XXX LOV STACKING call down to osc_unpackmd() */
-		loi = lsm->lsm_oinfo[i];
-		ostid_le_to_cpu(&lmm->lmm_objects[i].l_ost_oi, &loi->loi_oi);
-		loi->loi_ost_idx = le32_to_cpu(lmm->lmm_objects[i].l_ost_idx);
-		loi->loi_ost_gen = le32_to_cpu(lmm->lmm_objects[i].l_ost_gen);
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (loi->loi_ost_idx >= lov->desc.ld_tgt_count) {
-			CERROR("OST index %d more than OST count %d\n",
-			       loi->loi_ost_idx, lov->desc.ld_tgt_count);
-			lov_dump_lmm_v3(D_WARNING, lmm);
-			return -EINVAL;
-		}
-		if (!lov->lov_tgts[loi->loi_ost_idx]) {
-			CERROR("OST index %d missing\n", loi->loi_ost_idx);
-			lov_dump_lmm_v3(D_WARNING, lmm);
-			return -EINVAL;
-		}
-		/* calculate the minimum stripe max bytes */
-		lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx],
-				 &stripe_maxbytes);
-	}
-
-	lsm->lsm_maxbytes = stripe_maxbytes * lsm->lsm_stripe_count;
-	if (lsm->lsm_stripe_count == 0)
-		lsm->lsm_maxbytes = stripe_maxbytes * lov->desc.ld_tgt_count;
-
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index d39724a..82b99e0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1454,6 +1454,22 @@ static int lov_object_layout_get(const struct lu_env *env,
 	return rc < 0 ? rc : 0;
 }
 
+static loff_t lov_object_maxbytes(struct cl_object *obj)
+{
+	struct lov_object *lov = cl2lov(obj);
+	struct lov_stripe_md *lsm = lov_lsm_addref(lov);
+	loff_t maxbytes;
+
+	if (!lsm)
+		return LLONG_MAX;
+
+	maxbytes = lsm->lsm_maxbytes;
+
+	lov_lsm_put(lsm);
+
+	return maxbytes;
+}
+
 static const struct cl_object_operations lov_ops = {
 	.coo_page_init = lov_page_init,
 	.coo_lock_init = lov_lock_init,
@@ -1463,6 +1479,7 @@ static const struct cl_object_operations lov_ops = {
 	.coo_conf_set  = lov_conf_set,
 	.coo_getstripe = lov_object_getstripe,
 	.coo_layout_get	 = lov_object_layout_get,
+	.coo_maxbytes	 = lov_object_maxbytes,
 	.coo_fiemap	 = lov_object_fiemap,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index dd80b83..cda01b8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -388,6 +388,21 @@ int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
 }
 EXPORT_SYMBOL(cl_object_layout_get);
 
+loff_t cl_object_maxbytes(struct cl_object *obj)
+{
+	struct lu_object_header *top = obj->co_lu.lo_header;
+	loff_t maxbytes = LLONG_MAX;
+
+	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
+		if (obj->co_ops->coo_maxbytes)
+			maxbytes = min_t(loff_t, obj->co_ops->coo_maxbytes(obj),
+					 maxbytes);
+	}
+
+	return maxbytes;
+}
+EXPORT_SYMBOL(cl_object_maxbytes);
+
 /**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
-- 
1.7.1
