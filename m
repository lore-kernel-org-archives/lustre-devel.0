From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:00 -0500
Subject: [lustre-devel] [PATCH v2 05/33] lustre: lov: fold lmm_verify()
 handling into lmm_unpackmd()
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

The function lov_unpackmd() calls the format specific version of
lmm_verify() and uses the returned information to allocate the
correct amount for the lsm information. We can fold the
lmm_verify() handling into the format specific unpackmd()
function. This also enables use to intergate the lsm allocation
as well into the unpackmd() function. This also greatly simplifies
lov_unpackmd().

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24849
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       | 113 ++++++++++++++++++-----
 drivers/staging/lustre/lustre/lov/lov_internal.h |  11 +--
 drivers/staging/lustre/lustre/lov/lov_pack.c     |  59 +-----------
 3 files changed, 99 insertions(+), 84 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 2b3552a..5a01fbb 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -145,6 +145,37 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 	return NULL;
 }
 
+static struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern,
+					   u32 magic)
+{
+	struct lov_stripe_md *lsm;
+	unsigned int i;
+
+	CDEBUG(D_INFO, "alloc lsm, stripe_count %u\n", stripe_count);
+
+	lsm = lsm_alloc_plain(stripe_count);
+	if (!lsm) {
+		CERROR("cannot allocate LSM stripe_count %u\n", stripe_count);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	atomic_set(&lsm->lsm_refc, 1);
+	spin_lock_init(&lsm->lsm_lock);
+	lsm->lsm_magic = magic;
+	lsm->lsm_stripe_count = stripe_count;
+	lsm->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES * stripe_count;
+	lsm->lsm_pattern = pattern;
+	lsm->lsm_pool_name[0] = '\0';
+	lsm->lsm_layout_gen = 0;
+	if (stripe_count > 0)
+		lsm->lsm_oinfo[0]->loi_ost_idx = ~0;
+
+	for (i = 0; i < stripe_count; i++)
+		loi_init(lsm->lsm_oinfo[i]);
+
+	return lsm;
+}
+
 static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 			     struct lov_stripe_md *lsm,
 			     struct lov_mds_md *lmm,
@@ -238,12 +269,12 @@ static int lsm_unpackmd_v1v3(struct lov_obd *lov,
 		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
 }
 
-static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, int lmm_bytes,
+static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, size_t lmm_bytes,
 			     __u16 *stripe_count)
 {
 	if (lmm_bytes < sizeof(*lmm)) {
-		CERROR("lov_mds_md_v1 too small: %d, need at least %d\n",
-		       lmm_bytes, (int)sizeof(*lmm));
+		CERROR("lov_mds_md_v1 too small: %zu, need@least %zu\n",
+		       lmm_bytes, sizeof(*lmm));
 		return -EINVAL;
 	}
 
@@ -252,7 +283,7 @@ static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, int lmm_bytes,
 		*stripe_count = 0;
 
 	if (lmm_bytes < lov_mds_md_size(*stripe_count, LOV_MAGIC_V1)) {
-		CERROR("LOV EA V1 too small: %d, need %d\n",
+		CERROR("LOV EA V1 too small: %zu, need %d\n",
 		       lmm_bytes, lov_mds_md_size(*stripe_count, LOV_MAGIC_V1));
 		lov_dump_lmm_common(D_WARNING, lmm);
 		return -EINVAL;
@@ -261,29 +292,47 @@ static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, int lmm_bytes,
 	return lsm_lmm_verify_v1v3(lmm, lmm_bytes, *stripe_count);
 }
 
-static int lsm_unpackmd_v1(struct lov_obd *lov, struct lov_stripe_md *lsm,
-			   struct lov_mds_md_v1 *lmm)
+static struct lov_stripe_md *
+lsm_unpackmd_v1(struct lov_obd *lov, void *buf, size_t buf_size)
 {
-	return lsm_unpackmd_v1v3(lov, lsm, lmm, NULL, lmm->lmm_objects);
+	struct lov_mds_md_v1 *lmm = buf;
+	u32 magic = le32_to_cpu(lmm->lmm_magic);
+	struct lov_stripe_md *lsm;
+	u16 stripe_count;
+	u32 pattern;
+	int rc;
+
+	rc = lsm_lmm_verify_v1(lmm, buf_size, &stripe_count);
+	if (rc)
+		return ERR_PTR(rc);
+
+	pattern = le32_to_cpu(lmm->lmm_pattern);
+
+	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
+	if (IS_ERR(lsm))
+		return lsm;
+
+	rc = lsm_unpackmd_v1v3(lov, lsm, lmm, NULL, lmm->lmm_objects);
+	if (rc) {
+		lov_free_memmd(&lsm);
+		lsm = ERR_PTR(rc);
+	}
+
+	return lsm;
 }
 
 const static struct lsm_operations lsm_v1_ops = {
 	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
 	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
-	.lsm_lmm_verify	 = lsm_lmm_verify_v1,
 	.lsm_unpackmd	   = lsm_unpackmd_v1,
 };
 
-static int lsm_lmm_verify_v3(struct lov_mds_md *lmmv1, int lmm_bytes,
+static int lsm_lmm_verify_v3(struct lov_mds_md_v3 *lmm, size_t lmm_bytes,
 			     __u16 *stripe_count)
 {
-	struct lov_mds_md_v3 *lmm;
-
-	lmm = (struct lov_mds_md_v3 *)lmmv1;
-
 	if (lmm_bytes < sizeof(*lmm)) {
-		CERROR("lov_mds_md_v3 too small: %d, need at least %d\n",
-		       lmm_bytes, (int)sizeof(*lmm));
+		CERROR("lov_mds_md_v3 too small: %zu, need@least %zu\n",
+		       lmm_bytes, sizeof(*lmm));
 		return -EINVAL;
 	}
 
@@ -292,7 +341,7 @@ static int lsm_lmm_verify_v3(struct lov_mds_md *lmmv1, int lmm_bytes,
 		*stripe_count = 0;
 
 	if (lmm_bytes < lov_mds_md_size(*stripe_count, LOV_MAGIC_V3)) {
-		CERROR("LOV EA V3 too small: %d, need %d\n",
+		CERROR("LOV EA V3 too small: %zu, need %d\n",
 		       lmm_bytes, lov_mds_md_size(*stripe_count, LOV_MAGIC_V3));
 		lov_dump_lmm_common(D_WARNING, lmm);
 		return -EINVAL;
@@ -302,19 +351,39 @@ static int lsm_lmm_verify_v3(struct lov_mds_md *lmmv1, int lmm_bytes,
 				     *stripe_count);
 }
 
-static int lsm_unpackmd_v3(struct lov_obd *lov, struct lov_stripe_md *lsm,
-			   struct lov_mds_md *lmm)
+static struct lov_stripe_md *
+lsm_unpackmd_v3(struct lov_obd *lov, void *buf, size_t buf_size)
 {
-	struct lov_mds_md_v3 *lmm_v3 = (struct lov_mds_md_v3 *)lmm;
+	struct lov_mds_md_v3 *lmm = buf;
+	u32 magic = le32_to_cpu(lmm->lmm_magic);
+	struct lov_stripe_md *lsm;
+	u16 stripe_count;
+	u32 pattern;
+	int rc;
+
+	rc = lsm_lmm_verify_v3(lmm, buf_size, &stripe_count);
+	if (rc)
+		return ERR_PTR(rc);
+
+	pattern = le32_to_cpu(lmm->lmm_pattern);
 
-	return lsm_unpackmd_v1v3(lov, lsm, lmm, lmm_v3->lmm_pool_name,
-				 lmm_v3->lmm_objects);
+	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
+	if (IS_ERR(lsm))
+		return lsm;
+
+	rc = lsm_unpackmd_v1v3(lov, lsm, (struct lov_mds_md_v1 *)lmm,
+			       lmm->lmm_pool_name, lmm->lmm_objects);
+	if (rc) {
+		lov_free_memmd(&lsm);
+		lsm = ERR_PTR(rc);
+	}
+
+	return lsm;
 }
 
 const static struct lsm_operations lsm_v3_ops = {
 	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
 	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
-	.lsm_lmm_verify		= lsm_lmm_verify_v3,
 	.lsm_unpackmd		= lsm_unpackmd_v3,
 };
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 2c416b4..ae122f6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -85,10 +85,8 @@ struct lsm_operations {
 				    loff_t *);
 	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, loff_t *,
 				     loff_t *);
-	int (*lsm_lmm_verify)(struct lov_mds_md *lmm, int lmm_bytes,
-			      u16 *stripe_count);
-	int (*lsm_unpackmd)(struct lov_obd *lov, struct lov_stripe_md *lsm,
-			    struct lov_mds_md *lmm);
+	struct lov_stripe_md *(*lsm_unpackmd)(struct lov_obd *obd, void *buf,
+					      size_t buf_len);
 };
 
 const struct lsm_operations *lsm_op_find(int magic);
@@ -214,8 +212,8 @@ int lov_del_target(struct obd_device *obd, __u32 index,
 /* lov_pack.c */
 ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 		     size_t buf_size);
-struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
-				   size_t lmm_size);
+struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
+				   size_t buf_size);
 int lov_free_memmd(struct lov_stripe_md **lsmp);
 
 void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm);
@@ -223,7 +221,6 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
 void lov_dump_lmm_common(int level, void *lmmp);
 
 /* lov_ea.c */
-struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count);
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm);
 
 /* lproc_lov.c */
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 02936bf..90f9f2d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -181,37 +181,6 @@ __u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
 	return stripe_count;
 }
 
-static struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern,
-					   u32 magic)
-{
-	struct lov_stripe_md *lsm;
-	unsigned int i;
-
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
-
-	for (i = 0; i < stripe_count; i++)
-		loi_init(lsm->lsm_oinfo[i]);
-
-	return lsm;
-}
-
 int lov_free_memmd(struct lov_stripe_md **lsmp)
 {
 	struct lov_stripe_md *lsm = *lsmp;
@@ -229,38 +198,18 @@ int lov_free_memmd(struct lov_stripe_md **lsmp)
 /* Unpack LOV object metadata from disk storage.  It is packed in LE byte
  * order and is opaque to the networking layer.
  */
-struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
-				   size_t lmm_size)
+struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
+				   size_t buf_size)
 {
 	const struct lsm_operations *op;
-	struct lov_stripe_md *lsm;
-	u16 stripe_count;
-	u32 pattern;
 	u32 magic;
-	int rc;
 
-	magic = le32_to_cpu(lmm->lmm_magic);
+	magic = le32_to_cpu(*(u32 *)buf);
 	op = lsm_op_find(magic);
 	if (!op)
 		return ERR_PTR(-EINVAL);
 
-	rc = op->lsm_lmm_verify(lmm, lmm_size, &stripe_count);
-	if (rc)
-		return ERR_PTR(rc);
-
-	pattern = le32_to_cpu(lmm->lmm_pattern);
-
-	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
-	if (IS_ERR(lsm))
-		return lsm;
-
-	rc = op->lsm_unpackmd(lov, lsm, lmm);
-	if (rc) {
-		lov_free_memmd(&lsm);
-		return ERR_PTR(rc);
-	}
-
-	return lsm;
+	return op->lsm_unpackmd(lov, buf, buf_size);
 }
 
 /* Retrieve object striping information.
-- 
1.8.3.1
