From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:53:04 -0400
Subject: [lustre-devel] [PATCH 28/31] staging: lustre: lmv: build master LMV
	EA dynamically build via readdir
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

When creating a striped directory, the master object saves the slave
objects (or shards) as internal sub-directories. The sub-directory's
name is composed of ${shard_FID}:${shard_idx}. With the name, we can
easily to know what the shard is and where it should be.

On the other hand, we need to store some information related with the
striped directory, such as magic, hash type, shards count, and so on.
That is the LMV EA (header). We do NOT store the FID of each shard in
the LMV EA. Instead, when we need the shards' FIDs (such as readdir()
on client-side), we can build the entrie LMV EA on the MDT (in RAM) by
iterating the sub-directory entries that are contained in the master
object of the striped directroy.

Above mechanism can simplify the striped directory create operation.
For very large striped directory, logging the FIDs array in the LMV
EA will be trouble. It also simplify the LFSCK for verifying striped
directory, because it reduces the inconsistency sources.

Another fixing is about the lmv_master_fid in master LMV EA header,
it is redundant information, and may become one of the inconsistency
sources. So replace it with two __u64 padding fields.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5223
Reviewed-on: http://review.whamcloud.com/10751
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    7 +--
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   30 ------------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    4 --
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   49 ++++++++++++++++++++
 4 files changed, 52 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 05fe359..17581ba 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2494,10 +2494,9 @@ struct lmv_mds_md_v1 {
 					 * for example migrating or dead.
 					 */
 	__u32 lmv_layout_version;	/* Used for directory restriping */
-	__u32 lmv_padding;
-	struct lu_fid lmv_master_fid;	/* The FID of the master object, which
-					 * is the namespace-visible dir FID
-					 */
+	__u32 lmv_padding1;
+	__u64 lmv_padding2;
+	__u64 lmv_padding3;
 	char lmv_pool_name[LOV_MAXPOOLNAME];	/* pool name */
 	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
 };
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 1dd3e92..085e596 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -48,7 +48,6 @@ struct lmv_stripe_md {
 	__u32	lsm_md_layout_version;
 	__u32	lsm_md_default_count;
 	__u32	lsm_md_default_index;
-	struct lu_fid lsm_md_master_fid;
 	char	lsm_md_pool_name[LOV_MAXPOOLNAME];
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
@@ -90,23 +89,6 @@ static inline void lmv_free_memmd(struct lmv_stripe_md *lsm)
 	lmv_unpack_md(NULL, &lsm, NULL, 0);
 }
 
-static inline void lmv1_cpu_to_le(struct lmv_mds_md_v1 *lmv_dst,
-				  const struct lmv_mds_md_v1 *lmv_src)
-{
-	int i;
-
-	lmv_dst->lmv_magic = cpu_to_le32(lmv_src->lmv_magic);
-	lmv_dst->lmv_stripe_count = cpu_to_le32(lmv_src->lmv_stripe_count);
-	lmv_dst->lmv_master_mdt_index =
-		cpu_to_le32(lmv_src->lmv_master_mdt_index);
-	lmv_dst->lmv_hash_type = cpu_to_le32(lmv_src->lmv_hash_type);
-	lmv_dst->lmv_layout_version = cpu_to_le32(lmv_src->lmv_layout_version);
-
-	for (i = 0; i < lmv_src->lmv_stripe_count; i++)
-		fid_cpu_to_le(&lmv_dst->lmv_stripe_fids[i],
-			      &lmv_src->lmv_stripe_fids[i]);
-}
-
 static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
 				  const struct lmv_mds_md_v1 *lmv_src)
 {
@@ -124,18 +106,6 @@ static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
 			      &lmv_src->lmv_stripe_fids[i]);
 }
 
-static inline void lmv_cpu_to_le(union lmv_mds_md *lmv_dst,
-				 const union lmv_mds_md *lmv_src)
-{
-	switch (lmv_src->lmv_magic) {
-	case LMV_MAGIC_V1:
-		lmv1_cpu_to_le(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
-		break;
-	default:
-		break;
-	}
-}
-
 static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
 				 const union lmv_mds_md *lmv_src)
 {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e9f4e9a..b8275e1 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2773,13 +2773,9 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	else
 		lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
 	lsm->lsm_md_layout_version = le32_to_cpu(lmm1->lmv_layout_version);
-	fid_le_to_cpu(&lsm->lsm_md_master_fid, &lmm1->lmv_master_fid);
 	cplen = strlcpy(lsm->lsm_md_pool_name, lmm1->lmv_pool_name,
 			sizeof(lsm->lsm_md_pool_name));
 
-	if (!fid_is_sane(&lsm->lsm_md_master_fid))
-		return -EPROTO;
-
 	if (cplen >= sizeof(lsm->lsm_md_pool_name))
 		return -E2BIG;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 31d3326..b428528 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1400,6 +1400,55 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(LOV_PATTERN_CMOBD == 0x00000200UL, "found 0x%.8xUL\n",
 		(unsigned)LOV_PATTERN_CMOBD);
 
+	/* Checks for struct lmv_mds_md_v1 */
+	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
+		 (long long)(int)sizeof(struct lmv_mds_md_v1));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_magic) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_magic));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_magic) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_magic));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_stripe_count) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_stripe_count));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_count) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_count));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_master_mdt_index) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_master_mdt_index));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_master_mdt_index) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_master_mdt_index));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_hash_type) == 12, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_hash_type));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_hash_type) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_hash_type));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_layout_version) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_layout_version));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_layout_version) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_layout_version));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding1) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding1));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding1) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding1));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding2) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding2));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding2));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_padding3) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding3));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding3) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding3));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_pool_name[16]) == 56, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_pool_name[16]));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_pool_name[16]) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_pool_name[16]));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_stripe_fids[0]) == 56, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_stripe_fids[0]));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_fids[0]) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_fids[0]));
+	CLASSERT(LMV_MAGIC_V1 == 0x0CD20CD0);
+	CLASSERT(LMV_MAGIC_STRIPE == 0x0CD40CD0);
+	CLASSERT(LMV_HASH_TYPE_MASK == 0x0000ffff);
+	CLASSERT(LMV_HASH_FLAG_MIGRATION == 0x80000000);
+	CLASSERT(LMV_HASH_FLAG_DEAD == 0x40000000);
+
 	/* Checks for struct obd_statfs */
 	LASSERTF((int)sizeof(struct obd_statfs) == 144, "found %lld\n",
 		 (long long)(int)sizeof(struct obd_statfs));
-- 
1.7.1
