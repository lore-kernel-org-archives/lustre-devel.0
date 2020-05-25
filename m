From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:11 -0400
Subject: [lustre-devel] [PATCH 34/45] lustre: dne: support directory restripe
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

This patch adds directory restripe support:
* 'lfs setdirstripe -m -1 -c <stripe_count>' on an existed directory
  will change this directory layout, if 'stripe_count' is larger than
  current count, new stripes are allocated after current stripes,
  otherwise merge stripes of this directory, NB, if stripe count is
  unchanged, but hash type changed, it's treated as merging, but
  rehashing actually.
* mdt_restripe() ia added to restripe directory.
* mdd_dir_declare_layout_split() is added to split directory, which
  handles both plain and striped directory split.
* lod_dir_declare_layout_split() will handle the internal of directory
  split.
* directory merge is simple compared to split, which just records
  target stripe count in LMV, and update it.

NB. this patch only restripe directory, but doesn't add the code to
migrate sub files, which will be implemented in the following patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11025
Lustre-commit: 2e2b16c28bcf4 ("LU-11025 dne: support directory restripe")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36898
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h          | 90 ++++++++++++++++++++++++++++++---
 fs/lustre/lmv/lmv_obd.c                 | 57 ++++++++++++++-------
 fs/lustre/ptlrpc/wiretest.c             |  6 +++
 include/uapi/linux/lustre/lustre_user.h | 37 +++++++++++++-
 4 files changed, 166 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 645eee3..0175816 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -68,7 +68,7 @@ static inline bool lmv_dir_foreign(const struct lmv_stripe_md *lsm)
 static inline bool lmv_dir_layout_changing(const struct lmv_stripe_md *lsm)
 {
 	return lmv_dir_striped(lsm) &&
-	       (lsm->lsm_md_hash_type & LMV_HASH_FLAG_LAYOUT_CHANGE);
+	       lmv_hash_is_layout_changing(lsm->lsm_md_hash_type);
 }
 
 static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
@@ -275,6 +275,15 @@ static inline u32 crush_hash(u32 a, u32 b)
 	return idx;
 }
 
+/* directory layout may change in three ways:
+ * 1. directory migration, in its LMV source stripes are appended after
+ *    target stripes, @migrate_hash is source hash type, @migrate_offset is
+ *    target stripe count,
+ * 2. directory split, @migrate_hash is hash type before split,
+ *    @migrate_offset is stripe count before split.
+ * 3. directory merge, @migrate_hash is hash type after merge,
+ *    @migrate_offset is stripe count after merge.
+ */
 static inline int
 __lmv_name_to_stripe_index(u32 hash_type, u32 stripe_count,
 			   u32 migrate_hash, u32 migrate_offset,
@@ -287,7 +296,17 @@ static inline u32 crush_hash(u32 a, u32 b)
 	LASSERT(namelen > 0);
 	LASSERT(stripe_count > 0);
 
-	if (hash_type & LMV_HASH_FLAG_MIGRATION) {
+	if (lmv_hash_is_splitting(hash_type)) {
+		if (!new_layout) {
+			hash_type = migrate_hash;
+			stripe_count = migrate_offset;
+		}
+	} else if (lmv_hash_is_merging(hash_type)) {
+		if (new_layout) {
+			hash_type = migrate_hash;
+			stripe_count = migrate_offset;
+		}
+	} else if (lmv_hash_is_migrating(hash_type)) {
 		if (new_layout) {
 			stripe_count = migrate_offset;
 		} else {
@@ -317,12 +336,12 @@ static inline u32 crush_hash(u32 a, u32 b)
 
 	LASSERT(stripe_index < stripe_count);
 
-	if ((saved_hash & LMV_HASH_FLAG_MIGRATION) && !new_layout)
+	if (!new_layout && lmv_hash_is_migrating(saved_hash))
 		stripe_index += migrate_offset;
 
 	LASSERT(stripe_index < saved_count);
 
-	CDEBUG(D_INFO, "name %.*s hash %#x/%#x idx %d/%u/%u under %s layout\n",
+	CDEBUG(D_INFO, "name %.*s hash=%#x/%#x idx=%d/%u/%u under %s layout\n",
 	       namelen, name, saved_hash, migrate_hash, stripe_index,
 	       saved_count, migrate_offset, new_layout ? "new" : "old");
 
@@ -382,21 +401,25 @@ static inline bool lmv_user_magic_supported(u32 lum_magic)
 
 #define LMV_DEBUG(mask, lmv, msg)					\
 	CDEBUG(mask,							\
-	       "%s LMV: magic %#x count %u index %u hash %#x version %u migrate offset %u migrate hash %u.\n",\
+	       "%s LMV: magic=%#x count=%u index=%u hash=%#x version=%u migrate offset=%u migrate hash=%u.\n",\
 	       msg, (lmv)->lmv_magic, (lmv)->lmv_stripe_count,          \
 	       (lmv)->lmv_master_mdt_index, (lmv)->lmv_hash_type,       \
 	       (lmv)->lmv_layout_version, (lmv)->lmv_migrate_offset,    \
 	       (lmv)->lmv_migrate_hash)
 
+/* master LMV is sane */
 static inline bool lmv_is_sane(const struct lmv_mds_md_v1 *lmv)
 {
+	if (!lmv)
+		return false;
+
 	if (le32_to_cpu(lmv->lmv_magic) != LMV_MAGIC_V1)
 		goto insane;
 
 	if (le32_to_cpu(lmv->lmv_stripe_count) == 0)
 		goto insane;
 
-	if (!lmv_is_known_hash_type(lmv->lmv_hash_type))
+	if (!lmv_is_known_hash_type(le32_to_cpu(lmv->lmv_hash_type)))
 		goto insane;
 
 	return true;
@@ -405,4 +428,59 @@ static inline bool lmv_is_sane(const struct lmv_mds_md_v1 *lmv)
 	return false;
 }
 
+/* LMV can be either master or stripe LMV */
+static inline bool lmv_is_sane2(const struct lmv_mds_md_v1 *lmv)
+{
+	if (!lmv)
+		return false;
+
+	if (le32_to_cpu(lmv->lmv_magic) != LMV_MAGIC_V1 &&
+	    le32_to_cpu(lmv->lmv_magic) != LMV_MAGIC_STRIPE)
+		goto insane;
+
+	if (le32_to_cpu(lmv->lmv_stripe_count) == 0)
+		goto insane;
+
+	if (!lmv_is_known_hash_type(le32_to_cpu(lmv->lmv_hash_type)))
+		goto insane;
+
+	return true;
+insane:
+	LMV_DEBUG(D_ERROR, lmv, "insane");
+	return false;
+}
+
+static inline bool lmv_is_splitting(const struct lmv_mds_md_v1 *lmv)
+{
+	LASSERT(lmv_is_sane2(lmv));
+	return lmv_hash_is_splitting(cpu_to_le32(lmv->lmv_hash_type));
+}
+
+static inline bool lmv_is_merging(const struct lmv_mds_md_v1 *lmv)
+{
+	LASSERT(lmv_is_sane2(lmv));
+	return lmv_hash_is_merging(cpu_to_le32(lmv->lmv_hash_type));
+}
+
+static inline bool lmv_is_migrating(const struct lmv_mds_md_v1 *lmv)
+{
+	LASSERT(lmv_is_sane(lmv));
+	return lmv_hash_is_migrating(cpu_to_le32(lmv->lmv_hash_type));
+}
+
+static inline bool lmv_is_restriping(const struct lmv_mds_md_v1 *lmv)
+{
+	LASSERT(lmv_is_sane2(lmv));
+	return lmv_hash_is_splitting(cpu_to_le32(lmv->lmv_hash_type)) ||
+	       lmv_hash_is_merging(cpu_to_le32(lmv->lmv_hash_type));
+}
+
+static inline bool lmv_is_layout_changing(const struct lmv_mds_md_v1 *lmv)
+{
+	LASSERT(lmv_is_sane2(lmv));
+	return lmv_hash_is_splitting(cpu_to_le32(lmv->lmv_hash_type)) ||
+	       lmv_hash_is_merging(cpu_to_le32(lmv->lmv_hash_type)) ||
+	       lmv_hash_is_migrating(cpu_to_le32(lmv->lmv_hash_type));
+}
+
 #endif
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index f241269..bb60f64 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1743,6 +1743,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
+	struct mdt_body *repbody;
 	int rc;
 
 	if (!lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count)
@@ -1767,19 +1768,7 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	if (lmv_op_qos_mkdir(op_data)) {
-		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
-		if (tgt == ERR_PTR(-EAGAIN))
-			tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
-		/*
-		 * only update statfs after QoS mkdir, this means the cached
-		 * statfs may be stale, and current mkdir may not follow QoS
-		 * accurately, but it's not serious, and avoids periodic statfs
-		 * when client doesn't mkdir by QoS.
-		 */
-		if (!IS_ERR(tgt))
-			lmv_statfs_check_update(obd, tgt);
-	} else if (lmv_op_user_specific_mkdir(op_data)) {
+	if (lmv_op_user_specific_mkdir(op_data)) {
 		struct lmv_user_md *lum = op_data->op_data;
 
 		op_data->op_mds = le32_to_cpu(lum->lum_stripe_offset);
@@ -1792,11 +1781,22 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		tgt = lmv_tgt(lmv, op_data->op_mds);
 		if (!tgt)
 			return -ENODEV;
+	} else if (lmv_op_qos_mkdir(op_data)) {
+		tgt = lmv_locate_tgt_qos(lmv, &op_data->op_mds);
+		if (tgt == ERR_PTR(-EAGAIN))
+			tgt = lmv_locate_tgt_rr(lmv, &op_data->op_mds);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+		/*
+		 * only update statfs after QoS mkdir, this means the cached
+		 * statfs may be stale, and current mkdir may not follow QoS
+		 * accurately, but it's not serious, and avoids periodic statfs
+		 * when client doesn't mkdir by QoS.
+		 */
+		lmv_statfs_check_update(obd, tgt);
 	}
 
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
-
+retry:
 	rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 	if (rc)
 		return rc;
@@ -1816,7 +1816,30 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		CDEBUG(D_INODE, "Created - " DFID "\n",
 		       PFID(&op_data->op_fid2));
 	}
-	return rc;
+
+	/* dir restripe needs to send to MDT where dir is located */
+	if (rc != -EREMOTE ||
+	    !(exp_connect_flags2(exp) & OBD_CONNECT2_CRUSH))
+		return rc;
+
+	repbody = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
+	if (!repbody)
+		return -EPROTO;
+
+	/* Not cross-ref case, just get out of here. */
+	if (likely(!(repbody->mbo_valid & OBD_MD_MDS)))
+		return rc;
+
+	op_data->op_fid2 = repbody->mbo_fid1;
+	ptlrpc_req_finished(*request);
+	*request = NULL;
+
+	tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	op_data->op_mds = tgt->ltd_index;
+	goto retry;
 }
 
 static int
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 8f824ee..dc1d0af 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1760,6 +1760,10 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LMV_MAGIC_V1 != 0x0CD20CD0);
 	BUILD_BUG_ON(LMV_MAGIC_STRIPE != 0x0CD40CD0);
 	BUILD_BUG_ON(LMV_HASH_TYPE_MASK != 0x0000ffff);
+	BUILD_BUG_ON(LMV_HASH_FLAG_MERGE != 0x04000000);
+	BUILD_BUG_ON(LMV_HASH_FLAG_SPLIT != 0x08000000);
+	BUILD_BUG_ON(LMV_HASH_FLAG_LOST_LMV != 0x10000000);
+	BUILD_BUG_ON(LMV_HASH_FLAG_BAD_TYPE != 0x20000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_MIGRATION != 0x80000000);
 	BUILD_BUG_ON(LMV_CRUSH_PG_COUNT != 4096);
 
@@ -2075,6 +2079,8 @@ void lustre_assert_wire_constants(void)
 		(unsigned int)MDS_OWNEROVERRIDE);
 	LASSERTF(MDS_HSM_RELEASE == 0x00001000UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_HSM_RELEASE);
+	LASSERTF(MDS_CLOSE_MIGRATE == 0x00002000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_CLOSE_MIGRATE);
 	LASSERTF(MDS_CLOSE_LAYOUT_SWAP == 0x00004000UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_CLOSE_LAYOUT_SWAP);
 	LASSERTF(MDS_CLOSE_LAYOUT_MERGE == 0x00008000UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 4b7c89b..b255f14 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -706,6 +706,9 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_CRUSH;
 }
 
+#define LMV_HASH_FLAG_MERGE		0x04000000
+#define LMV_HASH_FLAG_SPLIT		0x08000000
+
 /* The striped directory has ever lost its master LMV EA, then LFSCK
  * re-generated it. This flag is used to indicate such case. It is an
  * on-disk flag.
@@ -715,7 +718,39 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 #define LMV_HASH_FLAG_BAD_TYPE		0x20000000
 #define LMV_HASH_FLAG_MIGRATION		0x80000000
 
-#define LMV_HASH_FLAG_LAYOUT_CHANGE	LMV_HASH_FLAG_MIGRATION
+#define LMV_HASH_FLAG_LAYOUT_CHANGE	\
+	(LMV_HASH_FLAG_MIGRATION | LMV_HASH_FLAG_SPLIT | LMV_HASH_FLAG_MERGE)
+
+/* both SPLIT and MIGRATION are set for directory split */
+static inline bool lmv_hash_is_splitting(__u32 hash)
+{
+	return (hash & LMV_HASH_FLAG_LAYOUT_CHANGE) ==
+		(LMV_HASH_FLAG_SPLIT | LMV_HASH_FLAG_MIGRATION);
+}
+
+/* both MERGE and MIGRATION are set for directory merge */
+static inline bool lmv_hash_is_merging(__u32 hash)
+{
+	return (hash & LMV_HASH_FLAG_LAYOUT_CHANGE) ==
+		(LMV_HASH_FLAG_MERGE | LMV_HASH_FLAG_MIGRATION);
+}
+
+/* only MIGRATION is set for directory migration */
+static inline bool lmv_hash_is_migrating(__u32 hash)
+{
+	return (hash & LMV_HASH_FLAG_LAYOUT_CHANGE) == LMV_HASH_FLAG_MIGRATION;
+}
+
+static inline bool lmv_hash_is_restriping(__u32 hash)
+{
+	return lmv_hash_is_splitting(hash) || lmv_hash_is_merging(hash);
+}
+
+static inline bool lmv_hash_is_layout_changing(__u32 hash)
+{
+	return lmv_hash_is_splitting(hash) || lmv_hash_is_merging(hash) ||
+	       lmv_hash_is_migrating(hash);
+}
 
 struct lustre_foreign_type {
 	__u32		lft_type;
-- 
1.8.3.1
