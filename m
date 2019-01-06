From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:13:59 -0500
Subject: [lustre-devel] [PATCH v2 04/33] lustre: lov: merge lov_mds_md_v3
 and lov_mds_md_v1 handling
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Several of the struct lsm_operations functions for both v1 and v3
are nearly identical. Let's merge them together.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24849
WC-bug-id: https://jira.whamcloud.com/browse/LU-9315
Reviewed-on: https://review.whamcloud.com/26503
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       | 58 ++++++++++++------------
 drivers/staging/lustre/lustre/lov/lov_internal.h |  3 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c     | 30 ++++--------
 3 files changed, 38 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 3dfb204..2b3552a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -71,8 +71,8 @@ static loff_t lov_tgt_maxbytes(struct lov_tgt_desc *tgt)
 	return maxbytes;
 }
 
-static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
-				 __u16 stripe_count)
+static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
+			       u16 stripe_count)
 {
 	if (stripe_count > LOV_V1_INSANE_STRIPE_COUNT) {
 		CERROR("bad stripe count %d\n", stripe_count);
@@ -103,7 +103,7 @@ static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
 	return 0;
 }
 
-void lsm_free_plain(struct lov_stripe_md *lsm)
+void lsm_free(struct lov_stripe_md *lsm)
 {
 	__u16 stripe_count = lsm->lsm_stripe_count;
 	int i;
@@ -145,10 +145,11 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 	return NULL;
 }
 
-static int lsm_unpackmd_common(struct lov_obd *lov,
-			       struct lov_stripe_md *lsm,
-			       struct lov_mds_md *lmm,
-			       struct lov_ost_data_v1 *objects)
+static int lsm_unpackmd_v1v3(struct lov_obd *lov,
+			     struct lov_stripe_md *lsm,
+			     struct lov_mds_md *lmm,
+			     const char *pool_name,
+			     struct lov_ost_data_v1 *objects)
 {
 	loff_t min_stripe_maxbytes = 0;
 	unsigned int stripe_count;
@@ -168,6 +169,15 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
 
 	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
 
+	if (pool_name) {
+		size_t pool_name_len;
+
+		pool_name_len = strlcpy(lsm->lsm_pool_name, pool_name,
+					sizeof(lsm->lsm_pool_name));
+		if (pool_name_len >= sizeof(lsm->lsm_pool_name))
+			return -E2BIG;
+	}
+
 	for (i = 0; i < stripe_count; i++) {
 		loi = lsm->lsm_oinfo[i];
 		ostid_le_to_cpu(&objects[i].l_ost_oi, &loi->loi_oi);
@@ -248,17 +258,16 @@ static int lsm_lmm_verify_v1(struct lov_mds_md_v1 *lmm, int lmm_bytes,
 		return -EINVAL;
 	}
 
-	return lsm_lmm_verify_common(lmm, lmm_bytes, *stripe_count);
+	return lsm_lmm_verify_v1v3(lmm, lmm_bytes, *stripe_count);
 }
 
 static int lsm_unpackmd_v1(struct lov_obd *lov, struct lov_stripe_md *lsm,
 			   struct lov_mds_md_v1 *lmm)
 {
-	return lsm_unpackmd_common(lov, lsm, lmm, lmm->lmm_objects);
+	return lsm_unpackmd_v1v3(lov, lsm, lmm, NULL, lmm->lmm_objects);
 }
 
-const struct lsm_operations lsm_v1_ops = {
-	.lsm_free	    = lsm_free_plain,
+const static struct lsm_operations lsm_v1_ops = {
 	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
 	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
 	.lsm_lmm_verify	 = lsm_lmm_verify_v1,
@@ -289,7 +298,7 @@ static int lsm_lmm_verify_v3(struct lov_mds_md *lmmv1, int lmm_bytes,
 		return -EINVAL;
 	}
 
-	return lsm_lmm_verify_common((struct lov_mds_md_v1 *)lmm, lmm_bytes,
+	return lsm_lmm_verify_v1v3((struct lov_mds_md_v1 *)lmm, lmm_bytes,
 				     *stripe_count);
 }
 
@@ -297,27 +306,16 @@ static int lsm_unpackmd_v3(struct lov_obd *lov, struct lov_stripe_md *lsm,
 			   struct lov_mds_md *lmm)
 {
 	struct lov_mds_md_v3 *lmm_v3 = (struct lov_mds_md_v3 *)lmm;
-	size_t cplen = 0;
-	int rc;
-
-	rc = lsm_unpackmd_common(lov, lsm, lmm, lmm_v3->lmm_objects);
-	if (rc)
-		return rc;
 
-	cplen = strlcpy(lsm->lsm_pool_name, lmm_v3->lmm_pool_name,
-			sizeof(lsm->lsm_pool_name));
-	if (cplen >= sizeof(lsm->lsm_pool_name))
-		return -E2BIG;
-
-	return 0;
+	return lsm_unpackmd_v1v3(lov, lsm, lmm, lmm_v3->lmm_pool_name,
+				 lmm_v3->lmm_objects);
 }
 
-const struct lsm_operations lsm_v3_ops = {
-	.lsm_free	    = lsm_free_plain,
-	.lsm_stripe_by_index    = lsm_stripe_by_index_plain,
-	.lsm_stripe_by_offset   = lsm_stripe_by_offset_plain,
-	.lsm_lmm_verify	 = lsm_lmm_verify_v3,
-	.lsm_unpackmd	   = lsm_unpackmd_v3,
+const static struct lsm_operations lsm_v3_ops = {
+	.lsm_stripe_by_index	= lsm_stripe_by_index_plain,
+	.lsm_stripe_by_offset	= lsm_stripe_by_offset_plain,
+	.lsm_lmm_verify		= lsm_lmm_verify_v3,
+	.lsm_unpackmd		= lsm_unpackmd_v3,
 };
 
 const struct lsm_operations *lsm_op_find(int magic)
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 51f416e..2c416b4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -81,7 +81,6 @@ static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 }
 
 struct lsm_operations {
-	void (*lsm_free)(struct lov_stripe_md *);
 	void (*lsm_stripe_by_index)(struct lov_stripe_md *, int *, loff_t *,
 				    loff_t *);
 	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, loff_t *,
@@ -93,6 +92,7 @@ struct lsm_operations {
 };
 
 const struct lsm_operations *lsm_op_find(int magic);
+void lsm_free(struct lov_stripe_md *lsm);
 
 /* lov_do_div64(a, b) returns a % b, and a = a / b.
  * The 32-bit code is LOV-specific due to knowing about stripe limits in
@@ -224,7 +224,6 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
 
 /* lov_ea.c */
 struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count);
-void lsm_free_plain(struct lov_stripe_md *lsm);
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm);
 
 /* lproc_lov.c */
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 98b114b..02936bf 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -181,22 +181,6 @@ __u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
 	return stripe_count;
 }
 
-static int lov_verify_lmm(void *lmm, int lmm_bytes, __u16 *stripe_count)
-{
-	int rc;
-
-	if (!lsm_op_find(le32_to_cpu(*(__u32 *)lmm))) {
-		CERROR("bad disk LOV MAGIC: 0x%08X; dumping LMM (size=%d):\n",
-		       le32_to_cpu(*(__u32 *)lmm), lmm_bytes);
-		CERROR("%*phN\n", lmm_bytes, lmm);
-		return -EINVAL;
-	}
-	rc = lsm_op_find(le32_to_cpu(*(__u32 *)lmm))->lsm_lmm_verify(lmm,
-								     lmm_bytes,
-								  stripe_count);
-	return rc;
-}
-
 static struct lov_stripe_md *lov_lsm_alloc(u16 stripe_count, u32 pattern,
 					   u32 magic)
 {
@@ -237,7 +221,7 @@ int lov_free_memmd(struct lov_stripe_md **lsmp)
 	LASSERT(atomic_read(&lsm->lsm_refc) > 0);
 	refc = atomic_dec_return(&lsm->lsm_refc);
 	if (refc == 0)
-		lsm_op_find(lsm->lsm_magic)->lsm_free(lsm);
+		lsm_free(lsm);
 
 	return refc;
 }
@@ -248,25 +232,29 @@ int lov_free_memmd(struct lov_stripe_md **lsmp)
 struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, struct lov_mds_md *lmm,
 				   size_t lmm_size)
 {
+	const struct lsm_operations *op;
 	struct lov_stripe_md *lsm;
 	u16 stripe_count;
 	u32 pattern;
 	u32 magic;
 	int rc;
 
-	rc = lov_verify_lmm(lmm, lmm_size, &stripe_count);
+	magic = le32_to_cpu(lmm->lmm_magic);
+	op = lsm_op_find(magic);
+	if (!op)
+		return ERR_PTR(-EINVAL);
+
+	rc = op->lsm_lmm_verify(lmm, lmm_size, &stripe_count);
 	if (rc)
 		return ERR_PTR(rc);
 
-	magic = le32_to_cpu(lmm->lmm_magic);
 	pattern = le32_to_cpu(lmm->lmm_pattern);
 
 	lsm = lov_lsm_alloc(stripe_count, pattern, magic);
 	if (IS_ERR(lsm))
 		return lsm;
 
-	LASSERT(lsm_op_find(magic));
-	rc = lsm_op_find(magic)->lsm_unpackmd(lov, lsm, lmm);
+	rc = op->lsm_unpackmd(lov, lsm, lmm);
 	if (rc) {
 		lov_free_memmd(&lsm);
 		return ERR_PTR(rc);
-- 
1.8.3.1
