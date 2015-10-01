From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:15 -0400
Subject: [lustre-devel] [PATCH 05/32] staging/lustre/lov: Remove unused
	lov_dump_lmm/pool()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

These generic switch functions appear to be unused as all the
individual ones are called directly.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_internal.h |  2 --
 drivers/staging/lustre/lustre/lov/lov_pack.c     | 20 --------------------
 drivers/staging/lustre/lustre/lov/lov_pool.c     | 22 ----------------------
 3 files changed, 44 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index dde9656..0de39cc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -220,7 +220,6 @@ int lov_free_memmd(struct lov_stripe_md **lsmp);
 void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm);
 void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm);
 void lov_dump_lmm_common(int level, void *lmmp);
-void lov_dump_lmm(int level, void *lmm);
 
 /* lov_ea.c */
 struct lov_stripe_md *lsm_alloc_plain(__u16 stripe_count, int *size);
@@ -248,7 +247,6 @@ int lov_pool_new(struct obd_device *obd, char *poolname);
 int lov_pool_del(struct obd_device *obd, char *poolname);
 int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname);
 int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname);
-void lov_dump_pool(int level, struct pool_desc *pool);
 struct pool_desc *lov_find_pool(struct lov_obd *lov, char *poolname);
 int lov_check_index_in_pool(__u32 idx, struct pool_desc *pool);
 void lov_pool_putref(struct pool_desc *pool);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 6b1c135..05651ac 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -100,26 +100,6 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
 			     le16_to_cpu(lmm->lmm_stripe_count));
 }
 
-void lov_dump_lmm(int level, void *lmm)
-{
-	int magic;
-
-	magic = le32_to_cpu(((struct lov_mds_md *)lmm)->lmm_magic);
-	switch (magic) {
-	case LOV_MAGIC_V1:
-		lov_dump_lmm_v1(level, (struct lov_mds_md_v1 *)lmm);
-		break;
-	case LOV_MAGIC_V3:
-		lov_dump_lmm_v3(level, (struct lov_mds_md_v3 *)lmm);
-		break;
-	default:
-		CDEBUG(level, "unrecognized lmm_magic %x, assuming %x\n",
-		       magic, LOV_MAGIC_V1);
-		lov_dump_lmm_common(level, lmm);
-		break;
-	}
-}
-
 /* Pack LOV object metadata for disk storage.  It is packed in LE byte
  * order and is opaque to the networking layer.
  *
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index c59b140..f996348 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -294,28 +294,6 @@ static struct file_operations pool_proc_operations = {
 	.release	= seq_release,
 };
 
-void lov_dump_pool(int level, struct pool_desc *pool)
-{
-	int i;
-
-	lov_pool_getref(pool);
-
-	CDEBUG(level, "pool "LOV_POOLNAMEF" has %d members\n",
-	       pool->pool_name, pool->pool_obds.op_count);
-	down_read(&pool_tgt_rw_sem(pool));
-
-	for (i = 0; i < pool_tgt_count(pool) ; i++) {
-		if (!pool_tgt(pool, i) || !(pool_tgt(pool, i))->ltd_exp)
-			continue;
-		CDEBUG(level, "pool "LOV_POOLNAMEF"[%d] = %s\n",
-		       pool->pool_name, i,
-		       obd_uuid2str(&((pool_tgt(pool, i))->ltd_uuid)));
-	}
-
-	up_read(&pool_tgt_rw_sem(pool));
-	lov_pool_putref(pool);
-}
-
 #define LOV_POOL_INIT_COUNT 2
 int lov_ost_pool_init(struct ost_pool *op, unsigned int count)
 {
-- 
2.1.0
