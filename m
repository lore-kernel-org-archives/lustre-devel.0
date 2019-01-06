From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:01 -0500
Subject: [lustre-devel] [PATCH v2 06/33] lustre: lov: create struct
 lov_stripe_md_entry
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Create a new struct lov_stripe_md_entry that will be shared with
older striping methods and the new PFL handling. Rearrange the
code to handle this new data structure.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24849
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h      |   4 -
 drivers/staging/lustre/lustre/lov/lov_ea.c       | 338 ++++++++++-------------
 drivers/staging/lustre/lustre/lov/lov_internal.h |  35 ++-
 drivers/staging/lustre/lustre/lov/lov_io.c       |  17 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c    |   4 +-
 drivers/staging/lustre/lustre/lov/lov_object.c   |  80 +++---
 drivers/staging/lustre/lustre/lov/lov_offset.c   |   8 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c     |  32 +--
 8 files changed, 245 insertions(+), 273 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d6a968c..15d9573 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -75,10 +75,6 @@ static inline void loi_kms_set(struct lov_oinfo *oinfo, __u64 kms)
 	oinfo->loi_kms_valid = 1;
 }
 
-static inline void loi_init(struct lov_oinfo *loi)
-{
-}
-
 struct lov_stripe_md;
 struct obd_info;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 5a01fbb..f794df9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -103,114 +103,106 @@ static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
 	return 0;
 }
 
-void lsm_free(struct lov_stripe_md *lsm)
+static void lsme_free(struct lov_stripe_md_entry *lsme)
 {
-	__u16 stripe_count = lsm->lsm_stripe_count;
-	int i;
+	unsigned int stripe_count = lsme->lsme_stripe_count;
+	unsigned int i;
 
 	for (i = 0; i < stripe_count; i++)
-		kmem_cache_free(lov_oinfo_slab, lsm->lsm_oinfo[i]);
-	kvfree(lsm);
-}
-
-struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
-{
-	size_t oinfo_ptrs_size, lsm_size;
-	struct lov_stripe_md *lsm;
-	struct lov_oinfo     *loi;
-	int i;
-
-	LASSERT(stripe_count <= LOV_MAX_STRIPE_COUNT);
-
-	oinfo_ptrs_size = sizeof(struct lov_oinfo *) * stripe_count;
-	lsm_size = sizeof(*lsm) + oinfo_ptrs_size;
+		kmem_cache_free(lov_oinfo_slab, lsme->lsme_oinfo[i]);
 
-	lsm = kvzalloc(lsm_size, GFP_NOFS);
-	if (!lsm)
-		return NULL;
-
-	for (i = 0; i < stripe_count; i++) {
-		loi = kmem_cache_zalloc(lov_oinfo_slab, GFP_NOFS);
-		if (!loi)
-			goto err;
-		lsm->lsm_oinfo[i] = loi;
-	}
-	lsm->lsm_stripe_count = stripe_count;
-	return lsm;
-
-err:
-	while (--i >= 0)
-		kmem_cache_free(lov_oinfo_slab, lsm->lsm_oinfo[i]);
-	kvfree(lsm);
-	return NULL;
+	kvfree(lsme);
 }
 
-static struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern,
-					   u32 magic)
+void lsm_free(struct lov_stripe_md *lsm)
 {
-	struct lov_stripe_md *lsm;
+	unsigned int entry_count = lsm->lsm_entry_count;
 	unsigned int i;
 
-	CDEBUG(D_INFO, "alloc lsm, stripe_count %u\n", stripe_count);
-
-	lsm = lsm_alloc_plain(stripe_count);
-	if (!lsm) {
-		CERROR("cannot allocate LSM stripe_count %u\n", stripe_count);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	atomic_set(&lsm->lsm_refc, 1);
-	spin_lock_init(&lsm->lsm_lock);
-	lsm->lsm_magic = magic;
-	lsm->lsm_stripe_count = stripe_count;
-	lsm->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES * stripe_count;
-	lsm->lsm_pattern = pattern;
-	lsm->lsm_pool_name[0] = '\0';
-	lsm->lsm_layout_gen = 0;
-	if (stripe_count > 0)
-		lsm->lsm_oinfo[0]->loi_ost_idx = ~0;
+	for (i = 0; i < entry_count; i++)
+		lsme_free(lsm->lsm_entries[i]);
 
-	for (i = 0; i < stripe_count; i++)
-		loi_init(lsm->lsm_oinfo[i]);
-
-	return lsm;
+	kfree(lsm);
 }
 
-static int lsm_unpackmd_v1v3(struct lov_obd *lov,
-			     struct lov_stripe_md *lsm,
-			     struct lov_mds_md *lmm,
-			     const char *pool_name,
-			     struct lov_ost_data_v1 *objects)
+/**
+ * Unpack a struct lov_mds_md into a struct lov_stripe_md_entry.
+ *
+ * The caller should set id and extent.
+ */
+static struct lov_stripe_md_entry *
+lsme_unpack(struct lov_obd *lov, struct lov_mds_md *lmm, size_t buf_size,
+	    const char *pool_name, struct lov_ost_data_v1 *objects,
+	    loff_t *maxbytes)
 {
+	struct lov_stripe_md_entry *lsme;
 	loff_t min_stripe_maxbytes = 0;
 	unsigned int stripe_count;
-	struct lov_oinfo *loi;
 	loff_t lov_bytes;
+	size_t lsme_size;
 	unsigned int i;
+	u32 pattern;
+	u32 magic;
+	int rc;
 
-	/*
-	 * This supposes lov_mds_md_v1/v3 first fields are
-	 * are the same
-	 */
-	lmm_oi_le_to_cpu(&lsm->lsm_oi, &lmm->lmm_oi);
-	lsm->lsm_stripe_size = le32_to_cpu(lmm->lmm_stripe_size);
-	lsm->lsm_pattern = le32_to_cpu(lmm->lmm_pattern);
-	lsm->lsm_layout_gen = le16_to_cpu(lmm->lmm_layout_gen);
-	lsm->lsm_pool_name[0] = '\0';
+	magic = le32_to_cpu(lmm->lmm_magic);
+	if (magic != LOV_MAGIC_V1 && magic != LOV_MAGIC_V3)
+		return ERR_PTR(-EINVAL);
+
+	pattern = le32_to_cpu(lmm->lmm_pattern);
+	if (pattern & LOV_PATTERN_F_RELEASED)
+		stripe_count = 0;
+	else
+		stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
+
+	if (buf_size < (magic == LOV_MAGIC_V1 ? sizeof(struct lov_mds_md_v1) :
+						sizeof(struct lov_mds_md_v3))) {
+		CERROR("LOV EA %s too small: %zu, need %u\n",
+		       magic == LOV_MAGIC_V1 ? "V1" : "V3", buf_size,
+		       lov_mds_md_size(stripe_count, magic == LOV_MAGIC_V1 ?
+				       LOV_MAGIC_V1 : LOV_MAGIC_V3));
+		lov_dump_lmm_common(D_WARNING, lmm);
+		return ERR_PTR(-EINVAL);
+	}
 
-	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
+	rc = lsm_lmm_verify_v1v3(lmm, buf_size, stripe_count);
+	if (rc < 0)
+		return ERR_PTR(rc);
+
+	lsme_size = offsetof(typeof(*lsme), lsme_oinfo[stripe_count]);
+	lsme = kvzalloc(lsme_size, GFP_KERNEL);
+	if (!lsme)
+		return ERR_PTR(-ENOMEM);
+
+	lsme->lsme_magic = magic;
+	lsme->lsme_pattern = pattern;
+	lsme->lsme_stripe_size = le32_to_cpu(lmm->lmm_stripe_size);
+	lsme->lsme_stripe_count = stripe_count;
+	lsme->lsme_layout_gen = le16_to_cpu(lmm->lmm_layout_gen);
 
 	if (pool_name) {
 		size_t pool_name_len;
 
-		pool_name_len = strlcpy(lsm->lsm_pool_name, pool_name,
-					sizeof(lsm->lsm_pool_name));
-		if (pool_name_len >= sizeof(lsm->lsm_pool_name))
-			return -E2BIG;
+		pool_name_len = strlcpy(lsme->lsme_pool_name, pool_name,
+					sizeof(lsme->lsme_pool_name));
+		if (pool_name_len >= sizeof(lsme->lsme_pool_name)) {
+			rc = -E2BIG;
+			goto out_lsme;
+		}
 	}
 
 	for (i = 0; i < stripe_count; i++) {
-		loi = lsm->lsm_oinfo[i];
+		struct lov_tgt_desc *ltd;
+		struct lov_oinfo *loi;
+
+		loi = kmem_cache_zalloc(lov_oinfo_slab, GFP_KERNEL);
+		if (!loi) {
+			rc = -ENOMEM;
+			goto out_lsme;
+		}
+
+		lsme->lsme_oinfo[i] = loi;
+
 		ostid_le_to_cpu(&objects[i].l_ost_oi, &loi->loi_oi);
 		loi->loi_ost_idx = le32_to_cpu(objects[i].l_ost_idx);
 		loi->loi_ost_gen = le32_to_cpu(objects[i].l_ost_gen);
@@ -223,10 +215,12 @@ static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 			       (char *)lov->desc.ld_uuid.uuid,
 			       loi->loi_ost_idx, lov->desc.ld_tgt_count);
 			lov_dump_lmm_v1(D_WARNING, lmm);
-			return -EINVAL;
+			rc = -EINVAL;
+			goto out_lsme;
 		}
 
-		if (!lov->lov_tgts[loi->loi_ost_idx]) {
+		ltd = lov->lov_tgts[loi->loi_ost_idx];
+		if (!ltd) {
 			CERROR("%s: OST index %d missing\n",
 			       (char *)lov->desc.ld_uuid.uuid,
 			       loi->loi_ost_idx);
@@ -234,7 +228,7 @@ static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 			continue;
 		}
 
-		lov_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
+		lov_bytes = lov_tgt_maxbytes(ltd);
 		if (min_stripe_maxbytes == 0 || lov_bytes < min_stripe_maxbytes)
 			min_stripe_maxbytes = lov_bytes;
 	}
@@ -242,15 +236,68 @@ static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 	if (min_stripe_maxbytes == 0)
 		min_stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
 
-	stripe_count = lsm->lsm_stripe_count ?: lov->desc.ld_tgt_count;
 	lov_bytes = min_stripe_maxbytes * stripe_count;
 
-	if (lov_bytes < min_stripe_maxbytes) /* handle overflow */
-		lsm->lsm_maxbytes = MAX_LFS_FILESIZE;
-	else
-		lsm->lsm_maxbytes = lov_bytes;
+	if (maxbytes) {
+		if (lov_bytes < min_stripe_maxbytes) /* handle overflow */
+			*maxbytes = MAX_LFS_FILESIZE;
+		else
+			*maxbytes = lov_bytes;
+	}
 
-	return 0;
+	return lsme;
+
+out_lsme:
+	for (i = 0; i < stripe_count; i++) {
+		struct lov_oinfo *loi = lsme->lsme_oinfo[i];
+
+		if (loi)
+			kmem_cache_free(lov_oinfo_slab, lsme->lsme_oinfo[i]);
+	}
+	kvfree(lsme);
+
+	return ERR_PTR(rc);
+}
+
+static inline struct lov_stripe_md *
+lsm_unpackmd_v1v3(struct lov_obd *lov,
+		  struct lov_mds_md *lmm, size_t buf_size,
+		  const char *pool_name,
+		  struct lov_ost_data_v1 *objects)
+{
+	struct lov_stripe_md_entry *lsme;
+	struct lov_stripe_md *lsm;
+	size_t lsm_size;
+	loff_t maxbytes;
+	u32 pattern;
+
+	pattern = le32_to_cpu(lmm->lmm_pattern);
+
+	lsme = lsme_unpack(lov, lmm, buf_size, pool_name, objects, &maxbytes);
+	if (IS_ERR(lsme))
+		return ERR_CAST(lsme);
+
+	lsme->lsme_extent.e_start = 0;
+	lsme->lsme_extent.e_end = LUSTRE_EOF;
+
+	lsm_size = offsetof(typeof(*lsm), lsm_entries[1]);
+	lsm = kzalloc(lsm_size, GFP_KERNEL);
+	if (!lsm) {
+		lsme_free(lsme);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	atomic_set(&lsm->lsm_refc, 1);
+	spin_lock_init(&lsm->lsm_lock);
+	lsm->lsm_maxbytes = maxbytes;
+	lmm_oi_le_to_cpu(&lsm->lsm_oi, &lmm->lmm_oi);
+	lsm->lsm_magic = le32_to_cpu(lmm->lmm_magic);
+	lsm->lsm_layout_gen = le16_to_cpu(lmm->lmm_layout_gen);
+	lsm->lsm_entry_count = 1;
+	lsm->lsm_is_released = pattern & LOV_PATTERN_F_RELEASED;
+	lsm->lsm_entries[0] = lsme;
+
+	return lsm;
 }
 
 static void
@@ -258,7 +305,8 @@ static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 			  loff_t *lov_off, loff_t *swidth)
 {
 	if (swidth)
-		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
+		*swidth = (loff_t)lsm->lsm_entries[0]->lsme_stripe_size *
+			  lsm->lsm_entries[0]->lsme_stripe_count;
 }
 
 static void
@@ -266,59 +314,16 @@ static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 			   loff_t *lov_off, loff_t *swidth)
 {
 	if (swidth)
-		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
-}
-
-static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, size_t lmm_bytes,
-			     __u16 *stripe_count)
-{
-	if (lmm_bytes < sizeof(*lmm)) {
-		CERROR("lov_mds_md_v1 too small: %zu, need@least %zu\n",
-		       lmm_bytes, sizeof(*lmm));
-		return -EINVAL;
-	}
-
-	*stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
-	if (le32_to_cpu(lmm->lmm_pattern) & LOV_PATTERN_F_RELEASED)
-		*stripe_count = 0;
-
-	if (lmm_bytes < lov_mds_md_size(*stripe_count, LOV_MAGIC_V1)) {
-		CERROR("LOV EA V1 too small: %zu, need %d\n",
-		       lmm_bytes, lov_mds_md_size(*stripe_count, LOV_MAGIC_V1));
-		lov_dump_lmm_common(D_WARNING, lmm);
-		return -EINVAL;
-	}
-
-	return lsm_lmm_verify_v1v3(lmm, lmm_bytes, *stripe_count);
+		*swidth = (loff_t)lsm->lsm_entries[0]->lsme_stripe_size *
+			  lsm->lsm_entries[0]->lsme_stripe_count;
 }
 
 static struct lov_stripe_md *
 lsm_unpackmd_v1(struct lov_obd *lov, void *buf, size_t buf_size)
 {
 	struct lov_mds_md_v1 *lmm = buf;
-	u32 magic = le32_to_cpu(lmm->lmm_magic);
-	struct lov_stripe_md *lsm;
-	u16 stripe_count;
-	u32 pattern;
-	int rc;
 
-	rc = lsm_lmm_verify_v1(lmm, buf_size, &stripe_count);
-	if (rc)
-		return ERR_PTR(rc);
-
-	pattern = le32_to_cpu(lmm->lmm_pattern);
-
-	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
-	if (IS_ERR(lsm))
-		return lsm;
-
-	rc = lsm_unpackmd_v1v3(lov, lsm, lmm, NULL, lmm->lmm_objects);
-	if (rc) {
-		lov_free_memmd(&lsm);
-		lsm = ERR_PTR(rc);
-	}
-
-	return lsm;
+	return lsm_unpackmd_v1v3(lov, buf, buf_size, NULL, lmm->lmm_objects);
 }
 
 const static struct lsm_operations lsm_v1_ops = {
@@ -327,58 +332,13 @@ static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, size_t lmm_bytes,
 	.lsm_unpackmd	   = lsm_unpackmd_v1,
 };
 
-static int lsm_lmm_verify_v3(struct lov_mds_md_v3 *lmm, size_t lmm_bytes,
-			     __u16 *stripe_count)
-{
-	if (lmm_bytes < sizeof(*lmm)) {
-		CERROR("lov_mds_md_v3 too small: %zu, need@least %zu\n",
-		       lmm_bytes, sizeof(*lmm));
-		return -EINVAL;
-	}
-
-	*stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
-	if (le32_to_cpu(lmm->lmm_pattern) & LOV_PATTERN_F_RELEASED)
-		*stripe_count = 0;
-
-	if (lmm_bytes < lov_mds_md_size(*stripe_count, LOV_MAGIC_V3)) {
-		CERROR("LOV EA V3 too small: %zu, need %d\n",
-		       lmm_bytes, lov_mds_md_size(*stripe_count, LOV_MAGIC_V3));
-		lov_dump_lmm_common(D_WARNING, lmm);
-		return -EINVAL;
-	}
-
-	return lsm_lmm_verify_v1v3((struct lov_mds_md_v1 *)lmm, lmm_bytes,
-				     *stripe_count);
-}
-
 static struct lov_stripe_md *
 lsm_unpackmd_v3(struct lov_obd *lov, void *buf, size_t buf_size)
 {
 	struct lov_mds_md_v3 *lmm = buf;
-	u32 magic = le32_to_cpu(lmm->lmm_magic);
-	struct lov_stripe_md *lsm;
-	u16 stripe_count;
-	u32 pattern;
-	int rc;
-
-	rc = lsm_lmm_verify_v3(lmm, buf_size, &stripe_count);
-	if (rc)
-		return ERR_PTR(rc);
-
-	pattern = le32_to_cpu(lmm->lmm_pattern);
-
-	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
-	if (IS_ERR(lsm))
-		return lsm;
 
-	rc = lsm_unpackmd_v1v3(lov, lsm, (struct lov_mds_md_v1 *)lmm,
-			       lmm->lmm_pool_name, lmm->lmm_objects);
-	if (rc) {
-		lov_free_memmd(&lsm);
-		lsm = ERR_PTR(rc);
-	}
-
-	return lsm;
+	return lsm_unpackmd_v1v3(lov, buf, buf_size, lmm->lmm_pool_name,
+				 lmm->lmm_objects);
 }
 
 const static struct lsm_operations lsm_v3_ops = {
@@ -403,9 +363,9 @@ const struct lsm_operations *lsm_op_find(int magic)
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 {
 	CDEBUG(level, "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, stripe_size %u, stripe_count %u, refc: %d, layout_gen %u, pool [" LOV_POOLNAMEF "]\n",
-	       lsm,
-	       POSTID(&lsm->lsm_oi), lsm->lsm_maxbytes, lsm->lsm_magic,
-	       lsm->lsm_stripe_size, lsm->lsm_stripe_count,
+	       lsm, POSTID(&lsm->lsm_oi), lsm->lsm_maxbytes, lsm->lsm_magic,
+	       lsm->lsm_entries[0]->lsme_stripe_size,
+	       lsm->lsm_entries[0]->lsme_stripe_count,
 	       atomic_read(&lsm->lsm_refc), lsm->lsm_layout_gen,
-	       lsm->lsm_pool_name);
+	       lsm->lsm_entries[0]->lsme_pool_name);
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index ae122f6..f2747c9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -44,6 +44,18 @@
  */
 #define LUSTRE_EXT3_STRIPE_MAXBYTES 0x1fffffff000ULL
 
+struct lov_stripe_md_entry {
+	struct lu_extent	lsme_extent;
+	u32			lsme_id;
+	u32			lsme_magic;
+	u32			lsme_pattern;
+	u32			lsme_stripe_size;
+	u16			lsme_stripe_count;
+	u16			lsme_layout_gen;
+	char			lsme_pool_name[LOV_MAXPOOLNAME + 1];
+	struct lov_oinfo       *lsme_oinfo[];
+};
+
 struct lov_stripe_md {
 	atomic_t	lsm_refc;
 	spinlock_t	lsm_lock;
@@ -56,28 +68,15 @@ struct lov_stripe_md {
 	loff_t		lsm_maxbytes;
 	struct ost_id	lsm_oi;
 	u32		lsm_magic;
-	u32		lsm_stripe_size;
-	u32		lsm_pattern; /* RAID0, RAID1, released, ... */
-	u16		lsm_stripe_count;
-	u16		lsm_layout_gen;
-	char		lsm_pool_name[LOV_MAXPOOLNAME + 1];
-	struct lov_oinfo	*lsm_oinfo[0];
+	u32		lsm_layout_gen;
+	u32		lsm_entry_count;
+	bool		lsm_is_released;
+	struct lov_stripe_md_entry *lsm_entries[];
 };
 
-static inline bool lsm_is_released(struct lov_stripe_md *lsm)
-{
-	return !!(lsm->lsm_pattern & LOV_PATTERN_F_RELEASED);
-}
-
 static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 {
-	if (!lsm)
-		return false;
-
-	if (lsm_is_released(lsm))
-		return false;
-
-	return true;
+	return lsm && !lsm->lsm_is_released;
 }
 
 struct lsm_operations {
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 6537ba3..2d62566 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -251,10 +251,9 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 	 * Need to be optimized, we can't afford to allocate a piece of memory
 	 * when writing a page. -jay
 	 */
-	lio->lis_subs =
-		kvzalloc(lsm->lsm_stripe_count *
+	lio->lis_subs = kcalloc(lsm->lsm_entries[0]->lsme_stripe_count,
 				sizeof(lio->lis_subs[0]),
-				GFP_NOFS);
+				GFP_KERNEL);
 	if (lio->lis_subs) {
 		lio->lis_nr_subios = lio->lis_stripe_count;
 		lio->lis_single_subio_index = -1;
@@ -272,7 +271,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	io->ci_result = 0;
 	lio->lis_object = obj;
 
-	lio->lis_stripe_count = obj->lo_lsm->lsm_stripe_count;
+	lio->lis_stripe_count = obj->lo_lsm->lsm_entries[0]->lsme_stripe_count;
 
 	switch (io->ci_type) {
 	case CIT_READ:
@@ -287,7 +286,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 			 * If there is LOV EA hole, then we may cannot locate
 			 * the current file-tail exactly.
 			 */
-			if (unlikely(obj->lo_lsm->lsm_pattern &
+			if (unlikely(obj->lo_lsm->lsm_entries[0]->lsme_pattern &
 				     LOV_PATTERN_F_HOLE))
 				return -EIO;
 
@@ -419,9 +418,9 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 	struct lov_io	*lio = cl2lov_io(env, ios);
 	struct cl_io	 *io  = ios->cis_io;
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
-	__u64 start = io->u.ci_rw.crw_pos;
+	unsigned long ssize = lsm->lsm_entries[0]->lsme_stripe_size;
+	u64 start = io->u.ci_rw.crw_pos;
 	loff_t next;
-	unsigned long ssize = lsm->lsm_stripe_size;
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
@@ -596,11 +595,11 @@ static int lov_io_read_ahead(const struct lu_env *env,
 	if (ra_end != CL_PAGE_EOF)
 		ra_end = lov_stripe_pgoff(loo->lo_lsm, ra_end, stripe);
 
-	pps = loo->lo_lsm->lsm_stripe_size >> PAGE_SHIFT;
+	pps = loo->lo_lsm->lsm_entries[0]->lsme_stripe_size >> PAGE_SHIFT;
 
 	CDEBUG(D_READA, DFID " max_index = %lu, pps = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
 	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps,
-	       loo->lo_lsm->lsm_stripe_size, stripe, start);
+	       loo->lo_lsm->lsm_entries[0]->lsme_stripe_size, stripe, start);
 
 	/* never exceed the end of the stripe */
 	ra->cra_end = min_t(pgoff_t, ra_end, start + pps - start % pps - 1);
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 006717c..10b8448 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -59,8 +59,8 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 	CDEBUG(D_INODE, "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
 	       POSTID(&lsm->lsm_oi), lvb->lvb_size, lvb->lvb_mtime,
 	       lvb->lvb_atime, lvb->lvb_ctime, lvb->lvb_blocks);
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_oinfo *loi = lsm->lsm_oinfo[i];
+	for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count; i++) {
+		struct lov_oinfo *loi = lsm->lsm_entries[0]->lsme_oinfo[i];
 		u64 lov_size, tmpsize;
 
 		if (OST_LVB_IS_ERR(loi->loi_lvb.lvb_blocks)) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index adc90f3..ad2901a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -153,7 +153,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	hdr    = cl_object_header(lov2cl(lov));
 	subhdr = cl_object_header(stripe);
 
-	oinfo = lov->lo_lsm->lsm_oinfo[idx];
+	oinfo = lov->lo_lsm->lsm_entries[0]->lsme_oinfo[idx];
 	CDEBUG(D_INODE, DFID "@%p[%d] -> " DFID "@%p: ostid: " DOSTID " idx: %d gen: %d\n",
 	       PFID(&subhdr->coh_lu.loh_fid), subhdr, idx,
 	       PFID(&hdr->coh_lu.loh_fid), hdr, POSTID(&oinfo->loi_oi),
@@ -239,7 +239,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
 	lov->lo_layout_invalid = true;
-	r0->lo_nr  = lsm->lsm_stripe_count;
+	r0->lo_nr  = lsm->lsm_entries[0]->lsme_stripe_count;
 	LASSERT(r0->lo_nr <= lov_targets_nr(dev));
 
 	r0->lo_sub = kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
@@ -255,9 +255,10 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 		 */
 		for (i = 0; i < r0->lo_nr && result == 0; ++i) {
 			struct cl_device *subdev;
-			struct lov_oinfo *oinfo = lsm->lsm_oinfo[i];
-			int ost_idx = oinfo->loi_ost_idx;
+			struct lov_oinfo *oinfo;
+			int ost_idx;
 
+			oinfo = lsm->lsm_entries[0]->lsme_oinfo[i];
 			if (lov_oinfo_is_dummy(oinfo))
 				continue;
 
@@ -266,6 +267,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			if (result != 0)
 				goto out;
 
+			ost_idx = oinfo->loi_ost_idx;
 			if (!dev->ld_target[ost_idx]) {
 				CERROR("%s: OST %04x is not initialized\n",
 				lov2obd(dev->ld_lov)->obd_name, ost_idx);
@@ -314,7 +316,7 @@ static int lov_init_released(const struct lu_env *env, struct lov_device *dev,
 			     union  lov_layout_state *state)
 {
 	LASSERT(lsm);
-	LASSERT(lsm_is_released(lsm));
+	LASSERT(lsm->lsm_is_released);
 	LASSERT(!lov->lo_lsm);
 
 	lov->lo_lsm = lsm_addref(lsm);
@@ -327,7 +329,7 @@ static struct cl_object *lov_find_subobj(const struct lu_env *env,
 					 int stripe_idx)
 {
 	struct lov_device *dev = lu2lov_dev(lov2lu(lov)->lo_dev);
-	struct lov_oinfo *oinfo = lsm->lsm_oinfo[stripe_idx];
+	struct lov_oinfo *oinfo = lsm->lsm_entries[0]->lsme_oinfo[stripe_idx];
 	struct lov_thread_info *lti = lov_env_info(env);
 	struct lu_fid *ofid = &lti->lti_fid;
 	struct cl_device *subdev;
@@ -485,7 +487,7 @@ static int lov_print_raid0(const struct lu_env *env, void *cookie,
 	(*p)(env, cookie, "stripes: %d, %s, lsm{%p 0x%08X %d %u %u}:\n",
 	     r0->lo_nr, lov->lo_layout_invalid ? "invalid" : "valid", lsm,
 	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-	     lsm->lsm_stripe_count, lsm->lsm_layout_gen);
+	     lsm->lsm_entries[0]->lsme_stripe_count, lsm->lsm_layout_gen);
 	for (i = 0; i < r0->lo_nr; ++i) {
 		struct lu_object *sub;
 
@@ -509,7 +511,7 @@ static int lov_print_released(const struct lu_env *env, void *cookie,
 	     "released: %s, lsm{%p 0x%08X %d %u %u}:\n",
 	     lov->lo_layout_invalid ? "invalid" : "valid", lsm,
 	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
-	     lsm->lsm_stripe_count, lsm->lsm_layout_gen);
+	     lsm->lsm_entries[0]->lsme_stripe_count, lsm->lsm_layout_gen);
 	return 0;
 }
 
@@ -650,8 +652,13 @@ static enum lov_layout_type lov_type(struct lov_stripe_md *lsm)
 {
 	if (!lsm)
 		return LLT_EMPTY;
-	if (lsm_is_released(lsm))
+
+	if (lsm->lsm_magic == LOV_MAGIC_COMP_V1)
+		return LLT_EMPTY;
+
+	if (lsm->lsm_is_released)
 		return LLT_RELEASED;
+
 	return LLT_RAID0;
 }
 
@@ -882,7 +889,8 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 	if ((!lsm && !lov->lo_lsm) ||
 	    ((lsm && lov->lo_lsm) &&
 	     (lov->lo_lsm->lsm_layout_gen == lsm->lsm_layout_gen) &&
-	     (lov->lo_lsm->lsm_pattern == lsm->lsm_pattern))) {
+	     (lov->lo_lsm->lsm_entries[0]->lsme_pattern ==
+	      lsm->lsm_entries[0]->lsme_pattern))) {
 		/* same version of layout */
 		lov->lo_layout_invalid = false;
 		result = 0;
@@ -1010,19 +1018,24 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm,
 	u64 obd_end;
 	int i, j;
 
-	if (fm_end - fm_start > lsm->lsm_stripe_size * lsm->lsm_stripe_count) {
-		last_stripe = (start_stripe < 1 ? lsm->lsm_stripe_count - 1 :
+	if (fm_end - fm_start > lsm->lsm_entries[0]->lsme_stripe_size *
+				lsm->lsm_entries[0]->lsme_stripe_count) {
+		last_stripe = (start_stripe < 1 ?
+			       lsm->lsm_entries[0]->lsme_stripe_count - 1 :
 			       start_stripe - 1);
-		*stripe_count = lsm->lsm_stripe_count;
+		*stripe_count = lsm->lsm_entries[0]->lsme_stripe_count;
 	} else {
-		for (j = 0, i = start_stripe; j < lsm->lsm_stripe_count;
-		     i = (i + 1) % lsm->lsm_stripe_count, j++) {
-			if (!(lov_stripe_intersects(lsm, i, fm_start, fm_end,
-						    &obd_start, &obd_end)))
+		for (j = 0, i = start_stripe;
+		     j < lsm->lsm_entries[0]->lsme_stripe_count;
+		     i = (i + 1) % lsm->lsm_entries[0]->lsme_stripe_count,
+		     j++) {
+			if (lov_stripe_intersects(lsm, i, fm_start, fm_end,
+						  &obd_start, &obd_end) == 0)
 				break;
 		}
 		*stripe_count = j;
-		last_stripe = (start_stripe + j - 1) % lsm->lsm_stripe_count;
+		last_stripe = (start_stripe + j - 1) %
+			      lsm->lsm_entries[0]->lsme_stripe_count;
 	}
 
 	return last_stripe;
@@ -1090,8 +1103,8 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 		return 0;
 
 	/* Find out stripe_no from ost_index saved in the fe_device */
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_oinfo *oinfo = lsm->lsm_oinfo[i];
+	for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count; i++) {
+		struct lov_oinfo *oinfo = lsm->lsm_entries[0]->lsme_oinfo[i];
 
 		if (lov_oinfo_is_dummy(oinfo))
 			continue;
@@ -1110,7 +1123,7 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 	 * offset to start of next device
 	 */
 	if (lov_stripe_intersects(lsm, stripe_no, fm_start, fm_end,
-				  &lun_start, &lun_end) &&
+				  &lun_start, &lun_end) != 0 &&
 	    local_end < lun_end) {
 		fm_end_offset = local_end;
 		*start_stripe = stripe_no;
@@ -1119,7 +1132,8 @@ static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 		 * calculate offset in next stripe.
 		 */
 		fm_end_offset = 0;
-		*start_stripe = (stripe_no + 1) % lsm->lsm_stripe_count;
+		*start_stripe = (stripe_no + 1) %
+				lsm->lsm_entries[0]->lsme_stripe_count;
 	}
 
 	return fm_end_offset;
@@ -1168,7 +1182,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 				   &lun_start, &obd_object_end)) == 0)
 		return 0;
 
-	if (lov_oinfo_is_dummy(lsm->lsm_oinfo[stripeno]))
+	if (lov_oinfo_is_dummy(lsm->lsm_entries[0]->lsme_oinfo[stripeno]))
 		return -EIO;
 
 	/* If this is a continuation FIEMAP call and we are on
@@ -1218,7 +1232,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 		fs->fs_fm->fm_mapped_extents = 0;
 		fs->fs_fm->fm_flags = fiemap->fm_flags;
 
-		ost_index = lsm->lsm_oinfo[stripeno]->loi_ost_idx;
+		ost_index = lsm->lsm_entries[0]->lsme_oinfo[stripeno]->loi_ost_idx;
 
 		if (ost_index < 0 || ost_index >= lov->desc.ld_tgt_count) {
 			rc = -EINVAL;
@@ -1347,13 +1361,13 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	 * If the stripe_count > 1 and the application does not understand
 	 * DEVICE_ORDER flag, it cannot interpret the extents correctly.
 	 */
-	if (lsm->lsm_stripe_count > 1 &&
+	if (lsm->lsm_entries[0]->lsme_stripe_count > 1 &&
 	    !(fiemap->fm_flags & FIEMAP_FLAG_DEVICE_ORDER)) {
 		rc = -ENOTSUPP;
 		goto out;
 	}
 
-	if (lsm_is_released(lsm)) {
+	if (lsm->lsm_is_released) {
 		if (fiemap->fm_start < fmkey->lfik_oa.o_size) {
 			/**
 			 * released file, return a minimal FIEMAP if
@@ -1431,7 +1445,8 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	/* Check each stripe */
 	for (cur_stripe = fs.fs_start_stripe; stripe_count > 0;
 	     --stripe_count,
-	     cur_stripe = (cur_stripe + 1) % lsm->lsm_stripe_count) {
+	     cur_stripe = (cur_stripe + 1) %
+			  lsm->lsm_entries[0]->lsme_stripe_count) {
 		rc = fiemap_for_stripe(env, obj, lsm, fiemap, buflen, fmkey,
 				       cur_stripe, &fs);
 		if (rc < 0)
@@ -1443,7 +1458,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	 * Indicate that we are returning device offsets unless file just has
 	 * single stripe
 	 */
-	if (lsm->lsm_stripe_count > 1)
+	if (lsm->lsm_entries[0]->lsme_stripe_count > 1)
 		fiemap->fm_flags |= FIEMAP_FLAG_DEVICE_ORDER;
 
 	if (!fiemap->fm_extent_count)
@@ -1495,7 +1510,8 @@ static int lov_object_layout_get(const struct lu_env *env,
 		return 0;
 	}
 
-	cl->cl_size = lov_mds_md_size(lsm->lsm_stripe_count, lsm->lsm_magic);
+	cl->cl_size = lov_mds_md_size(lsm->lsm_entries[0]->lsme_stripe_count,
+				      lsm->lsm_magic);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
 
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
@@ -1599,9 +1615,11 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 			int i;
 
 			lsm = lov->lo_lsm;
-			for (i = 0; i < lsm->lsm_stripe_count; i++) {
-				struct lov_oinfo *loi = lsm->lsm_oinfo[i];
+			for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count;
+			     i++) {
+				struct lov_oinfo *loi;
 
+				loi = lsm->lsm_entries[0]->lsme_oinfo[i];
 				if (lov_oinfo_is_dummy(loi))
 					continue;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index a5f00f6..19a44d3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -40,7 +40,7 @@
 /* compute object size given "stripeno" and the ost size */
 u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno)
 {
-	unsigned long ssize = lsm->lsm_stripe_size;
+	unsigned long ssize = lsm->lsm_entries[0]->lsme_stripe_size;
 	unsigned long stripe_size;
 	u64 swidth;
 	u64 lov_size;
@@ -125,7 +125,7 @@ pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
 int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
 		      int stripeno, u64 *obdoff)
 {
-	unsigned long ssize  = lsm->lsm_stripe_size;
+	unsigned long ssize  = lsm->lsm_entries[0]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
 	int magic = lsm->lsm_magic;
 	int ret = 0;
@@ -180,7 +180,7 @@ int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
 u64 lov_size_to_stripe(struct lov_stripe_md *lsm, u64 file_size,
 		       int stripeno)
 {
-	unsigned long ssize  = lsm->lsm_stripe_size;
+	unsigned long ssize  = lsm->lsm_entries[0]->lsme_stripe_size;
 	u64 stripe_off, this_stripe, swidth;
 	int magic = lsm->lsm_magic;
 
@@ -254,7 +254,7 @@ int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 /* compute which stripe number "lov_off" will be written into */
 int lov_stripe_number(struct lov_stripe_md *lsm, u64 lov_off)
 {
-	unsigned long ssize  = lsm->lsm_stripe_size;
+	unsigned long ssize  = lsm->lsm_entries[0]->lsme_stripe_size;
 	u64 stripe_off, swidth;
 	int magic = lsm->lsm_magic;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 90f9f2d..3700937 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -116,7 +116,8 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	size_t lmm_size;
 	unsigned int i;
 
-	lmm_size = lov_mds_md_size(lsm->lsm_stripe_count, lsm->lsm_magic);
+	lmm_size = lov_mds_md_size(lsm->lsm_entries[0]->lsme_stripe_count,
+				   lsm->lsm_magic);
 	if (!buf_size)
 		return lmm_size;
 
@@ -129,23 +130,24 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	 */
 	lmmv1->lmm_magic = cpu_to_le32(lsm->lsm_magic);
 	lmm_oi_cpu_to_le(&lmmv1->lmm_oi, &lsm->lsm_oi);
-	lmmv1->lmm_stripe_size = cpu_to_le32(lsm->lsm_stripe_size);
-	lmmv1->lmm_stripe_count = cpu_to_le16(lsm->lsm_stripe_count);
-	lmmv1->lmm_pattern = cpu_to_le32(lsm->lsm_pattern);
+	lmmv1->lmm_stripe_size = cpu_to_le32(lsm->lsm_entries[0]->lsme_stripe_size);
+	lmmv1->lmm_stripe_count = cpu_to_le16(lsm->lsm_entries[0]->lsme_stripe_count);
+	lmmv1->lmm_pattern = cpu_to_le32(lsm->lsm_entries[0]->lsme_pattern);
 	lmmv1->lmm_layout_gen = cpu_to_le16(lsm->lsm_layout_gen);
 
 	if (lsm->lsm_magic == LOV_MAGIC_V3) {
-		BUILD_BUG_ON(sizeof(lsm->lsm_pool_name) !=
-			 sizeof(lmmv3->lmm_pool_name));
-		strlcpy(lmmv3->lmm_pool_name, lsm->lsm_pool_name,
+		BUILD_BUG_ON(sizeof(lsm->lsm_entries[0]->lsme_pool_name) !=
+			     sizeof(lmmv3->lmm_pool_name));
+		strlcpy(lmmv3->lmm_pool_name,
+			lsm->lsm_entries[0]->lsme_pool_name,
 			sizeof(lmmv3->lmm_pool_name));
 		lmm_objects = lmmv3->lmm_objects;
 	} else {
 		lmm_objects = lmmv1->lmm_objects;
 	}
 
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_oinfo *loi = lsm->lsm_oinfo[i];
+	for (i = 0; i < lsm->lsm_entries[0]->lsme_stripe_count; i++) {
+		struct lov_oinfo *loi = lsm->lsm_entries[0]->lsme_oinfo[i];
 
 		ostid_cpu_to_le(&loi->loi_oi, &lmm_objects[i].l_ost_oi);
 		lmm_objects[i].l_ost_gen = cpu_to_le32(loi->loi_ost_gen);
@@ -240,8 +242,8 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		goto out;
 	}
 
-	if (!lsm_is_released(lsm))
-		stripe_count = lsm->lsm_stripe_count;
+	if (!lsm->lsm_is_released)
+		stripe_count = lsm->lsm_entries[0]->lsme_stripe_count;
 	else
 		stripe_count = 0;
 
@@ -260,18 +262,16 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		goto out;
 	}
 
-	if (lum.lmm_stripe_count &&
-	    (lum.lmm_stripe_count < lsm->lsm_stripe_count)) {
+	if (lum.lmm_stripe_count && lum.lmm_stripe_count < stripe_count) {
 		/* Return right size of stripe to user */
 		lum.lmm_stripe_count = stripe_count;
 		rc = copy_to_user(lump, &lum, lum_size);
 		rc = -EOVERFLOW;
 		goto out;
 	}
-	lmmk_size = lov_mds_md_size(stripe_count, lsm->lsm_magic);
-
 
-	lmmk = kvzalloc(lmmk_size, GFP_NOFS);
+	lmmk_size = lov_mds_md_size(stripe_count, lsm->lsm_magic);
+	lmmk = kvzalloc(lmmk_size, GFP_KERNEL);
 	if (!lmmk) {
 		rc = -ENOMEM;
 		goto out;
-- 
1.8.3.1
