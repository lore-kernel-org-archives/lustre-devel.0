From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:13:58 -0500
Subject: [lustre-devel] [PATCH v2 03/33] lustre: lov: move code for PFL work
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Move lov_tgt_maxbytes() and lsm_free_plain() toward the top of
lov_ea.c for upcoming PFL work. Migrate inline function
lsm_op_find() out of lov_internal.h to lov_ea.c since it is
consider bad code style to add define external structures
and have an inline function in the same header. Instead
only add lsm_op_find() prototype to lov_internal.h and
make all the struct lsm_operations static in lov_ea.c.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24849
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c       | 87 ++++++++++++++----------
 drivers/staging/lustre/lustre/lov/lov_internal.h | 16 +----
 2 files changed, 51 insertions(+), 52 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index c80320a..3dfb204 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -44,6 +44,33 @@
 
 #include "lov_internal.h"
 
+/*
+ * Find minimum stripe maxbytes value. For inactive or
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
 static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
 				 __u16 stripe_count)
 {
@@ -76,6 +103,16 @@ static int lsm_lmm_verify_common(struct lov_mds_md *lmm, int lmm_bytes,
 	return 0;
 }
 
+void lsm_free_plain(struct lov_stripe_md *lsm)
+{
+	__u16 stripe_count = lsm->lsm_stripe_count;
+	int i;
+
+	for (i = 0; i < stripe_count; i++)
+		kmem_cache_free(lov_oinfo_slab, lsm->lsm_oinfo[i]);
+	kvfree(lsm);
+}
+
 struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 {
 	size_t oinfo_ptrs_size, lsm_size;
@@ -108,43 +145,6 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 	return NULL;
 }
 
-void lsm_free_plain(struct lov_stripe_md *lsm)
-{
-	__u16 stripe_count = lsm->lsm_stripe_count;
-	int i;
-
-	for (i = 0; i < stripe_count; i++)
-		kmem_cache_free(lov_oinfo_slab, lsm->lsm_oinfo[i]);
-	kvfree(lsm);
-}
-
-/*
- * Find minimum stripe maxbytes value.  For inactive or
- * reconnecting targets use LUSTRE_EXT3_STRIPE_MAXBYTES.
- */
-static loff_t lov_tgt_maxbytes(struct lov_tgt_desc *tgt)
-{
-	loff_t maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
-	struct obd_import *imp;
-
-	if (!tgt->ltd_active)
-		return maxbytes;
-
-	imp = tgt->ltd_obd->u.cli.cl_import;
-	if (!imp)
-		return maxbytes;
-
-	spin_lock(&imp->imp_lock);
-	if (imp->imp_state == LUSTRE_IMP_FULL &&
-	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES) &&
-	     imp->imp_connect_data.ocd_maxbytes > 0)
-		maxbytes = imp->imp_connect_data.ocd_maxbytes;
-
-	spin_unlock(&imp->imp_lock);
-
-	return maxbytes;
-}
-
 static int lsm_unpackmd_common(struct lov_obd *lov,
 			       struct lov_stripe_md *lsm,
 			       struct lov_mds_md *lmm,
@@ -320,6 +320,19 @@ static int lsm_unpackmd_v3(struct lov_obd *lov, struct lov_stripe_md *lsm,
 	.lsm_unpackmd	   = lsm_unpackmd_v3,
 };
 
+const struct lsm_operations *lsm_op_find(int magic)
+{
+	switch (magic) {
+	case LOV_MAGIC_V1:
+		return &lsm_v1_ops;
+	case LOV_MAGIC_V3:
+		return &lsm_v3_ops;
+	default:
+		CERROR("unrecognized lsm_magic %08x\n", magic);
+		return NULL;
+	}
+}
+
 void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 {
 	CDEBUG(level, "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, stripe_size %u, stripe_count %u, refc: %d, layout_gen %u, pool [" LOV_POOLNAMEF "]\n",
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 44a997e..51f416e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -92,21 +92,7 @@ struct lsm_operations {
 			    struct lov_mds_md *lmm);
 };
 
-extern const struct lsm_operations lsm_v1_ops;
-extern const struct lsm_operations lsm_v3_ops;
-
-static inline const struct lsm_operations *lsm_op_find(int magic)
-{
-	switch (magic) {
-	case LOV_MAGIC_V1:
-		return &lsm_v1_ops;
-	case LOV_MAGIC_V3:
-		return &lsm_v3_ops;
-	default:
-		CERROR("unrecognized lsm_magic %08x\n", magic);
-		return NULL;
-	}
-}
+const struct lsm_operations *lsm_op_find(int magic);
 
 /* lov_do_div64(a, b) returns a % b, and a = a / b.
  * The 32-bit code is LOV-specific due to knowing about stripe limits in
-- 
1.8.3.1
