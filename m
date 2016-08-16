From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:54 -0400
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate master
	object with master stripe
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Separate master stripe with master object, so
1. stripeEA only exists on master object.
2. sub-stripe object will be inserted into master object
as sub-directory, and it can get the master object by "..".

By this, it will remove those specilities for stripe0 in
LMV and LOD. And also simplify LFSCK, i.e. consistency check
would be easier.

When then master object becomes an orphan, we should
mark all of its sub-stripes as dead object as well,
otherwise client might still be able to create files
under these stripes.

A few fixes for striped directory layout lock:

 1. stripe 0 should be locked as EX, same as other stripes.
 2. Acquire the layout for directory, when it is being unliked.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4690
Reviewed-on: http://review.whamcloud.com/9511
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   64 +++++++++-----
 .../lustre/lustre/include/lustre/lustre_user.h     |    3 +-
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   25 +++++-
 drivers/staging/lustre/lustre/include/obd.h        |    4 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    5 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   31 ++-----
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   89 ++++++++++----------
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   25 +-----
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    4 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   70 ++++++++--------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    4 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    6 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    8 +-
 14 files changed, 174 insertions(+), 166 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 3444add..8736826 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2497,18 +2497,52 @@ struct lmv_desc {
 	struct obd_uuid ld_uuid;
 };
 
-/* lmv structures */
-#define LMV_MAGIC_V1	0x0CD10CD0	/* normal stripe lmv magic */
-#define LMV_USER_MAGIC	0x0CD20CD0	/* default lmv magic*/
-#define LMV_MAGIC_MIGRATE	0x0CD30CD0	/* migrate stripe lmv magic */
-#define LMV_MAGIC	LMV_MAGIC_V1
+/* LMV layout EA, and it will be stored both in master and slave object */
+struct lmv_mds_md_v1 {
+	__u32 lmv_magic;
+	__u32 lmv_stripe_count;
+	__u32 lmv_master_mdt_index;	/* On master object, it is master
+					 * MDT index, on slave object, it
+					 * is stripe index of the slave obj
+					 */
+	__u32 lmv_hash_type;		/* dir stripe policy, i.e. indicate
+					 * which hash function to be used,
+					 * Note: only lower 16 bits is being
+					 * used for now. Higher 16 bits will
+					 * be used to mark the object status,
+					 * for example migrating or dead.
+					 */
+	__u32 lmv_layout_version;	/* Used for directory restriping */
+	__u32 lmv_padding;
+	struct lu_fid lmv_master_fid;	/* The FID of the master object, which
+					 * is the namespace-visible dir FID
+					 */
+	char lmv_pool_name[LOV_MAXPOOLNAME];	/* pool name */
+	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
+};
 
+#define LMV_MAGIC_V1	 0x0CD20CD0	/* normal stripe lmv magic */
+#define LMV_MAGIC	 LMV_MAGIC_V1
+
+/* #define LMV_USER_MAGIC 0x0CD30CD0 */
+#define LMV_MAGIC_STRIPE 0x0CD40CD0	/* magic for dir sub_stripe */
+
+/*
+ *Right now only the lower part(0-16bits) of lmv_hash_type is being used,
+ * and the higher part will be the flag to indicate the status of object,
+ * for example the object is being migrated. And the hash function
+ * might be interpreted differently with different flags.
+ */
 enum lmv_hash_type {
 	LMV_HASH_TYPE_ALL_CHARS = 1,
 	LMV_HASH_TYPE_FNV_1A_64 = 2,
-	LMV_HASH_TYPE_MIGRATION = 3,
 };
 
+#define LMV_HASH_TYPE_MASK		0x0000ffff
+
+#define LMV_HASH_FLAG_MIGRATION		0x80000000
+#define LMV_HASH_FLAG_DEAD		0x40000000
+
 #define LMV_HASH_NAME_ALL_CHARS		"all_char"
 #define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
 
@@ -2540,19 +2574,6 @@ static inline __u64 lustre_hash_fnv_1a_64(const void *buf, size_t size)
 	return hash;
 }
 
-struct lmv_mds_md_v1 {
-	__u32 lmv_magic;
-	__u32 lmv_stripe_count;		/* stripe count */
-	__u32 lmv_master_mdt_index;	/* master MDT index */
-	__u32 lmv_hash_type;		/* dir stripe policy, i.e. indicate
-					 * which hash function to be used
-					 */
-	__u32 lmv_layout_version;	/* Used for directory restriping */
-	__u32 lmv_padding;
-	char lmv_pool_name[LOV_MAXPOOLNAME];	/* pool name */
-	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
-};
-
 union lmv_mds_md {
 	__u32			lmv_magic;
 	struct lmv_mds_md_v1	lmv_md_v1;
@@ -2566,8 +2587,7 @@ static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
 	ssize_t len = -EINVAL;
 
 	switch (lmm_magic) {
-	case LMV_MAGIC_V1:
-	case LMV_MAGIC_MIGRATE: {
+	case LMV_MAGIC_V1: {
 		struct lmv_mds_md_v1 *lmm1;
 
 		len = sizeof(*lmm1);
@@ -2583,7 +2603,6 @@ static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
 {
 	switch (le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
-	case LMV_MAGIC_MIGRATE:
 		return le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
 	case LMV_USER_MAGIC:
 		return le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
@@ -2599,7 +2618,6 @@ static inline int lmv_mds_md_stripe_count_set(union lmv_mds_md *lmm,
 
 	switch (le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
-	case LMV_MAGIC_MIGRATE:
 		lmm->lmv_md_v1.lmv_stripe_count = cpu_to_le32(stripe_count);
 		break;
 	case LMV_USER_MAGIC:
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 75a78a3..4b2553c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -269,8 +269,7 @@ struct ost_id {
 #define LOV_USER_MAGIC_JOIN_V1 0x0BD20BD0
 #define LOV_USER_MAGIC_V3 0x0BD30BD0
 
-#define LMV_MAGIC_V1      0x0CD10CD0    /*normal stripe lmv magic */
-#define LMV_USER_MAGIC    0x0CD20CD0    /*default lmv magic*/
+#define LMV_USER_MAGIC    0x0CD30CD0    /*default lmv magic*/
 
 #define LOV_PATTERN_RAID0 0x001
 #define LOV_PATTERN_RAID1 0x002
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index feee981..1dd3e92 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -48,10 +48,33 @@ struct lmv_stripe_md {
 	__u32	lsm_md_layout_version;
 	__u32	lsm_md_default_count;
 	__u32	lsm_md_default_index;
+	struct lu_fid lsm_md_master_fid;
 	char	lsm_md_pool_name[LOV_MAXPOOLNAME];
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
+static inline bool
+lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
+{
+	int idx;
+
+	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
+	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
+	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
+	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
+	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
+	    !strcmp(lsm1->lsm_md_pool_name, lsm2->lsm_md_pool_name))
+		return false;
+
+	for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
+		if (!lu_fid_eq(&lsm1->lsm_md_oinfo[idx].lmo_fid,
+			       &lsm2->lsm_md_oinfo[idx].lmo_fid))
+			return false;
+	}
+
+	return true;
+}
+
 union lmv_mds_md;
 
 int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
@@ -106,7 +129,6 @@ static inline void lmv_cpu_to_le(union lmv_mds_md *lmv_dst,
 {
 	switch (lmv_src->lmv_magic) {
 	case LMV_MAGIC_V1:
-	case LMV_MAGIC_MIGRATE:
 		lmv1_cpu_to_le(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
 		break;
 	default:
@@ -119,7 +141,6 @@ static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
 {
 	switch (le32_to_cpu(lmv_src->lmv_magic)) {
 	case LMV_MAGIC_V1:
-	case LMV_MAGIC_MIGRATE:
 		lmv1_le_to_cpu(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
 		break;
 	default:
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 0dae273..52020a9 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -917,8 +917,8 @@ struct obd_ops {
 	int (*fid_fini)(struct obd_device *obd);
 
 	/* Allocate new fid according to passed @hint. */
-	int (*fid_alloc)(struct obd_export *exp, struct lu_fid *fid,
-			 struct md_op_data *op_data);
+	int (*fid_alloc)(const struct lu_env *env, struct obd_export *exp,
+			 struct lu_fid *fid, struct md_op_data *op_data);
 
 	/*
 	 * Object with @fid is getting deleted, we may want to do something
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index de808ee..a288995 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -930,7 +930,8 @@ static inline int obd_fid_fini(struct obd_device *obd)
 	return rc;
 }
 
-static inline int obd_fid_alloc(struct obd_export *exp,
+static inline int obd_fid_alloc(const struct lu_env *env,
+				struct obd_export *exp,
 				struct lu_fid *fid,
 				struct md_op_data *op_data)
 {
@@ -939,7 +940,7 @@ static inline int obd_fid_alloc(struct obd_export *exp,
 	EXP_CHECK_DT_OP(exp, fid_alloc);
 	EXP_COUNTER_INCREMENT(exp, fid_alloc);
 
-	rc = OBP(exp->exp_obd, fid_alloc)(exp, fid, op_data);
+	rc = OBP(exp->exp_obd, fid_alloc)(env, exp, fid, op_data);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 257c9a4..47fbcd2 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -883,7 +883,6 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
 		break;
 	case LMV_USER_MAGIC:
-	case LMV_MAGIC_MIGRATE:
 		if (cpu_to_le32(LMV_USER_MAGIC) != LMV_USER_MAGIC)
 			lustre_swab_lmv_user_md((struct lmv_user_md *)lmm);
 		break;
@@ -1471,7 +1470,7 @@ lmv_out_free:
 
 		rc = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize, &request,
 				      valid);
-		if (rc && rc != -ENODATA)
+		if (rc)
 			goto finish_req;
 
 		/* Get default LMV EA */
@@ -1490,14 +1489,7 @@ lmv_out_free:
 			goto finish_req;
 		}
 
-		/* Get normal LMV EA */
-		if (rc == -ENODATA) {
-			stripe_count = 1;
-		} else {
-			LASSERT(lmm);
-			stripe_count = lmv_mds_md_stripe_count_get(lmm);
-		}
-
+		stripe_count = lmv_mds_md_stripe_count_get(lmm);
 		lum_size = lmv_user_md_size(stripe_count, LMV_MAGIC_V1);
 		tmp = kzalloc(lum_size, GFP_NOFS);
 		if (!tmp) {
@@ -1505,28 +1497,25 @@ lmv_out_free:
 			goto finish_req;
 		}
 
-		tmp->lum_magic = LMV_MAGIC_V1;
-		tmp->lum_stripe_count = 1;
 		mdt_index = ll_get_mdt_idx(inode);
 		if (mdt_index < 0) {
 			rc = -ENOMEM;
 			goto out_tmp;
 		}
+		tmp->lum_magic = LMV_MAGIC_V1;
+		tmp->lum_stripe_count = 0;
 		tmp->lum_stripe_offset = mdt_index;
-		tmp->lum_objects[0].lum_mds = mdt_index;
-		tmp->lum_objects[0].lum_fid = *ll_inode2fid(inode);
-		for (i = 1; i < stripe_count; i++) {
-			struct lmv_mds_md_v1 *lmm1;
-
-			lmm1 = &lmm->lmv_md_v1;
-			mdt_index = ll_get_mdt_idx_by_fid(sbi,
-							  &lmm1->lmv_stripe_fids[i]);
+		for (i = 0; i < stripe_count; i++) {
+			struct lu_fid   *fid;
+
+			fid = &lmm->lmv_md_v1.lmv_stripe_fids[i];
+			mdt_index = ll_get_mdt_idx_by_fid(sbi, fid);
 			if (mdt_index < 0) {
 				rc = mdt_index;
 				goto out_tmp;
 			}
 			tmp->lum_objects[i].lum_mds = mdt_index;
-			tmp->lum_objects[i].lum_fid = lmm1->lmv_stripe_fids[i];
+			tmp->lum_objects[i].lum_fid = *fid;
 			tmp->lum_stripe_count++;
 		}
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ea79ca3..2f6e770 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1042,9 +1042,9 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 		ll_lli_init(lli);
 
 		LASSERT(lsm);
-		/* master stripe FID */
-		lli->lli_pfid = lsm->lsm_md_oinfo[0].lmo_fid;
-		CDEBUG(D_INODE, "lli %p master "DFID" slave "DFID"\n",
+		/* master object FID */
+		lli->lli_pfid = body->fid1;
+		CDEBUG(D_INODE, "lli %p slave "DFID" master "DFID"\n",
 		       lli, PFID(fid), PFID(&lli->lli_pfid));
 		unlock_new_inode(inode);
 	}
@@ -1067,23 +1067,24 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 		fid = &lsm->lsm_md_oinfo[i].lmo_fid;
 		LASSERT(!lsm->lsm_md_oinfo[i].lmo_root);
-		if (!i) {
+		/* Unfortunately ll_iget will call ll_update_inode,
+		 * where the initialization of slave inode is slightly
+		 * different, so it reset lsm_md to NULL to avoid
+		 * initializing lsm for slave inode.
+		 */
+		/* For migrating inode, master stripe and master object will
+		 * be same, so we only need assign this inode
+		 */
+		if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION && !i)
 			lsm->lsm_md_oinfo[i].lmo_root = inode;
-		} else {
-			/*
-			 * Unfortunately ll_iget will call ll_update_inode,
-			 * where the initialization of slave inode is slightly
-			 * different, so it reset lsm_md to NULL to avoid
-			 * initializing lsm for slave inode.
-			 */
+		else
 			lsm->lsm_md_oinfo[i].lmo_root =
 				ll_iget_anon_dir(inode->i_sb, fid, md);
-			if (IS_ERR(lsm->lsm_md_oinfo[i].lmo_root)) {
-				int rc = PTR_ERR(lsm->lsm_md_oinfo[i].lmo_root);
+		if (IS_ERR(lsm->lsm_md_oinfo[i].lmo_root)) {
+			int rc = PTR_ERR(lsm->lsm_md_oinfo[i].lmo_root);
 
-				lsm->lsm_md_oinfo[i].lmo_root = NULL;
-				return rc;
-			}
+			lsm->lsm_md_oinfo[i].lmo_root = NULL;
+			return rc;
 		}
 	}
 
@@ -1113,7 +1114,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lmv_stripe_md *lsm = md->lmv;
-	int idx, rc;
+	int rc;
 
 	LASSERT(S_ISDIR(inode->i_mode));
 	CDEBUG(D_INODE, "update lsm %p of "DFID"\n", lli->lli_lsm_md,
@@ -1123,7 +1124,8 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	if (!lsm) {
 		if (!lli->lli_lsm_md) {
 			return 0;
-		} else if (lli->lli_lsm_md->lsm_md_magic == LMV_MAGIC_MIGRATE) {
+		} else if (lli->lli_lsm_md->lsm_md_hash_type &
+			   LMV_HASH_FLAG_MIGRATION) {
 			/*
 			 * migration is done, the temporay MIGRATE layout has
 			 * been removed
@@ -1160,43 +1162,40 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	}
 
 	/* Compare the old and new stripe information */
-	if (!lli_lsm_md_eq(lli->lli_lsm_md, lsm)) {
-		CERROR("inode %p %lu mismatch\n"
-		       "    new(%p)     vs     lli_lsm_md(%p):\n"
-		       "    magic:      %x                   %x\n"
-		       "    count:      %x                   %x\n"
-		       "    master:     %x                   %x\n"
-		       "    hash_type:  %x                   %x\n"
-		       "    layout:     %x                   %x\n"
-		       "    pool:       %s                   %s\n",
-		       inode, inode->i_ino, lsm, lli->lli_lsm_md,
-		       lsm->lsm_md_magic, lli->lli_lsm_md->lsm_md_magic,
+	if (!lsm_md_eq(lli->lli_lsm_md, lsm)) {
+		struct lmv_stripe_md *old_lsm = lli->lli_lsm_md;
+		int idx;
+
+		CERROR("%s: inode "DFID"(%p)'s lmv layout mismatch (%p)/(%p) magic:0x%x/0x%x stripe count: %d/%d master_mdt: %d/%d hash_type:0x%x/0x%x layout: 0x%x/0x%x pool:%s/%s\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid),
+		       inode, lsm, old_lsm,
+		       lsm->lsm_md_magic, old_lsm->lsm_md_magic,
 		       lsm->lsm_md_stripe_count,
-		       lli->lli_lsm_md->lsm_md_stripe_count,
+		       old_lsm->lsm_md_stripe_count,
 		       lsm->lsm_md_master_mdt_index,
-		       lli->lli_lsm_md->lsm_md_master_mdt_index,
-		       lsm->lsm_md_hash_type, lli->lli_lsm_md->lsm_md_hash_type,
+		       old_lsm->lsm_md_master_mdt_index,
+		       lsm->lsm_md_hash_type, old_lsm->lsm_md_hash_type,
 		       lsm->lsm_md_layout_version,
-		       lli->lli_lsm_md->lsm_md_layout_version,
+		       old_lsm->lsm_md_layout_version,
 		       lsm->lsm_md_pool_name,
-		       lli->lli_lsm_md->lsm_md_pool_name);
-		return -EIO;
-	}
+		       old_lsm->lsm_md_pool_name);
+
+		for (idx = 0; idx < old_lsm->lsm_md_stripe_count; idx++) {
+			CERROR("%s: sub FIDs in old lsm idx %d, old: "DFID"\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
+			       PFID(&old_lsm->lsm_md_oinfo[idx].lmo_fid));
+		}
 
-	for (idx = 0; idx < lli->lli_lsm_md->lsm_md_stripe_count; idx++) {
-		if (!lu_fid_eq(&lli->lli_lsm_md->lsm_md_oinfo[idx].lmo_fid,
-			       &lsm->lsm_md_oinfo[idx].lmo_fid)) {
-			CERROR("%s: FID in lsm mismatch idx %d, old: "DFID" new:"DFID"\n",
+		for (idx = 0; idx < lsm->lsm_md_stripe_count; idx++) {
+			CERROR("%s: sub FIDs in new lsm idx %d, new: "DFID"\n",
 			       ll_get_fsname(inode->i_sb, NULL, 0), idx,
-			       PFID(&lli->lli_lsm_md->lsm_md_oinfo[idx].lmo_fid),
 			       PFID(&lsm->lsm_md_oinfo[idx].lmo_fid));
-			return -EIO;
 		}
+
+		return -EIO;
 	}
 
-	rc = md_update_lsm_md(ll_i2mdexp(inode), ll_i2info(inode)->lli_lsm_md,
-			      md->body, ll_md_blocking_ast);
-	return rc;
+	return 0;
 }
 
 void ll_clear_inode(struct inode *inode)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index d7e165f..7f81e78 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -173,9 +173,6 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 	 * revalidate slaves has some problems, temporarily return,
 	 * we may not need that
 	 */
-	if (lsm->lsm_md_stripe_count <= 1)
-		return 0;
-
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
 	if (!op_data)
 		return -ENOMEM;
@@ -194,14 +191,6 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 
 		fid = lsm->lsm_md_oinfo[i].lmo_fid;
 		inode = lsm->lsm_md_oinfo[i].lmo_root;
-		if (!i) {
-			if (mbody) {
-				body = mbody;
-				goto update;
-			} else {
-				goto release_lock;
-			}
-		}
 
 		/*
 		 * Prepare op_data for revalidating. Note that @fid2 shluld be
@@ -237,7 +226,7 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 			body = req_capsule_server_get(&req->rq_pill,
 						      &RMF_MDT_BODY);
 			LASSERT(body);
-update:
+
 			if (unlikely(body->nlink < 2)) {
 				CERROR("%s: nlink %d < 2 corrupt stripe %d "DFID":" DFID"\n",
 				       obd->obd_name, body->nlink, i,
@@ -256,10 +245,6 @@ update:
 				goto cleanup;
 			}
 
-			if (i)
-				md_set_lock_data(tgt->ltd_exp, &lockh->cookie,
-						 inode, NULL);
-
 			i_size_write(inode, body->size);
 			set_nlink(inode, body->nlink);
 			LTIME_S(inode->i_atime) = body->atime;
@@ -269,8 +254,8 @@ update:
 			if (req)
 				ptlrpc_req_finished(req);
 		}
-release_lock:
-		size += i_size_read(inode);
+
+		md_set_lock_data(tgt->ltd_exp, &lockh->cookie, inode, NULL);
 
 		if (i != 0)
 			nlink += inode->i_nlink - 2;
@@ -361,7 +346,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		 * fid and setup FLD for it.
 		 */
 		op_data->op_fid3 = op_data->op_fid2;
-		rc = lmv_fid_alloc(exp, &op_data->op_fid2, op_data);
+		rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc != 0)
 			return rc;
 	}
@@ -453,7 +438,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		}
 		return rc;
 	} else if (it_disposition(it, DISP_LOOKUP_NEG) && lsm &&
-		   lsm->lsm_md_magic == LMV_MAGIC_MIGRATE) {
+		   lsm->lsm_md_magic & LMV_HASH_FLAG_MIGRATION) {
 		/*
 		 * For migrating directory, if it can not find the child in
 		 * the source directory(master stripe), try the targeting
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index ed02927..dbd1da6 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -52,8 +52,8 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds);
 int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds);
-int lmv_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
-		  struct md_op_data *op_data);
+int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
+		  struct lu_fid *fid, struct md_op_data *op_data);
 
 int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		  const union lmv_mds_md *lmm, int stripe_count);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e516a84..03594f0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -80,41 +80,35 @@ lmv_hash_fnv1a(unsigned int count, const char *name, int namelen)
 	return do_div(hash, count);
 }
 
-int lmv_name_to_stripe_index(enum lmv_hash_type hashtype,
-			     unsigned int max_mdt_index,
+int lmv_name_to_stripe_index(__u32 lmv_hash_type, unsigned int stripe_count,
 			     const char *name, int namelen)
 {
+	__u32 hash_type = lmv_hash_type & LMV_HASH_TYPE_MASK;
 	int idx;
 
 	LASSERT(namelen > 0);
-	if (max_mdt_index <= 1)
+	if (stripe_count <= 1)
 		return 0;
 
-	switch (hashtype) {
+	/* for migrating object, always start from 0 stripe */
+	if (lmv_hash_type & LMV_HASH_FLAG_MIGRATION)
+		return 0;
+
+	switch (hash_type) {
 	case LMV_HASH_TYPE_ALL_CHARS:
-		idx = lmv_hash_all_chars(max_mdt_index, name, namelen);
+		idx = lmv_hash_all_chars(stripe_count, name, namelen);
 		break;
 	case LMV_HASH_TYPE_FNV_1A_64:
-		idx = lmv_hash_fnv1a(max_mdt_index, name, namelen);
+		idx = lmv_hash_fnv1a(stripe_count, name, namelen);
 		break;
-	/*
-	 * LMV_HASH_TYPE_MIGRATION means the file is being migrated,
-	 * and the file should be accessed by client, except for
-	 * lookup(see lmv_intent_lookup), return -EACCES here
-	 */
-	case LMV_HASH_TYPE_MIGRATION:
-		CERROR("%.*s is being migrated: rc = %d\n", namelen,
-		       name, -EACCES);
-		return -EACCES;
 	default:
-		CERROR("Unknown hash type 0x%x\n", hashtype);
+		CERROR("Unknown hash type 0x%x\n", hash_type);
 		return -EINVAL;
 	}
 
 	CDEBUG(D_INFO, "name %.*s hash_type %d idx %d\n", namelen, name,
-	       hashtype, idx);
+	       hash_type, idx);
 
-	LASSERT(idx < max_mdt_index);
 	return idx;
 }
 
@@ -1287,7 +1281,7 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
 	/*
 	 * Asking underlaying tgt layer to allocate new fid.
 	 */
-	rc = obd_fid_alloc(tgt->ltd_exp, fid, NULL);
+	rc = obd_fid_alloc(NULL, tgt->ltd_exp, fid, NULL);
 	if (rc > 0) {
 		LASSERT(fid_is_sane(fid));
 		rc = 0;
@@ -1298,8 +1292,8 @@ out:
 	return rc;
 }
 
-int lmv_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
-		  struct md_op_data *op_data)
+int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
+		  struct lu_fid *fid, struct md_op_data *op_data)
 {
 	struct obd_device     *obd = class_exp2obd(exp);
 	struct lmv_obd	*lmv = &obd->u.lmv;
@@ -1695,9 +1689,7 @@ struct lmv_tgt_desc
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct lmv_tgt_desc *tgt;
 
-	if (!lsm || lsm->lsm_md_stripe_count <= 1 ||
-	    !op_data->op_namelen ||
-	    lsm->lsm_md_magic == LMV_MAGIC_MIGRATE) {
+	if (!lsm || !op_data->op_namelen) {
 		tgt = lmv_find_target(lmv, fid);
 		if (IS_ERR(tgt))
 			return tgt;
@@ -1737,7 +1729,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	       op_data->op_namelen, op_data->op_name, PFID(&op_data->op_fid1),
 	       op_data->op_mds);
 
-	rc = lmv_fid_alloc(exp, &op_data->op_fid2, op_data);
+	rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 	if (rc)
 		return rc;
 
@@ -2060,7 +2052,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	if (op_data->op_cli_flags & CLI_MIGRATE) {
 		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID "DFID"\n",
 			 PFID(&op_data->op_fid3));
-		rc = lmv_fid_alloc(exp, &op_data->op_fid2, op_data);
+		rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc)
 			return rc;
 		src_tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid3);
@@ -2365,8 +2357,7 @@ retry:
 			return PTR_ERR(tgt);
 
 		/* For striped dir, we need to locate the parent as well */
-		if (op_data->op_mea1 &&
-		    op_data->op_mea1->lsm_md_stripe_count > 1) {
+		if (op_data->op_mea1) {
 			struct lmv_tgt_desc *tmp;
 
 			LASSERT(op_data->op_name && op_data->op_namelen);
@@ -2679,9 +2670,13 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	lsm->lsm_md_master_mdt_index = le32_to_cpu(lmm1->lmv_master_mdt_index);
 	lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
 	lsm->lsm_md_layout_version = le32_to_cpu(lmm1->lmv_layout_version);
+	fid_le_to_cpu(&lsm->lsm_md_master_fid, &lmm1->lmv_master_fid);
 	cplen = strlcpy(lsm->lsm_md_pool_name, lmm1->lmv_pool_name,
 			sizeof(lsm->lsm_md_pool_name));
 
+	if (!fid_is_sane(&lsm->lsm_md_master_fid))
+		return -EPROTO;
+
 	if (cplen >= sizeof(lsm->lsm_md_pool_name))
 		return -E2BIG;
 
@@ -2719,7 +2714,13 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		int i;
 
 		for (i = 1; i < lsm->lsm_md_stripe_count; i++) {
-			if (lsm->lsm_md_oinfo[i].lmo_root)
+			/*
+			 * For migrating inode, the master stripe and master
+			 * object will be the same, so do not need iput, see
+			 * ll_update_lsm_md
+			 */
+			if (!(lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION &&
+			      !i) && lsm->lsm_md_oinfo[i].lmo_root)
 				iput(lsm->lsm_md_oinfo[i].lmo_root);
 		}
 
@@ -2739,9 +2740,11 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		return 0;
 	}
 
+	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_STRIPE)
+		return -EPERM;
+
 	/* Unpack memmd */
 	if (le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_V1 &&
-	    le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_MIGRATE &&
 	    le32_to_cpu(lmm->lmv_magic) != LMV_USER_MAGIC) {
 		CERROR("%s: invalid lmv magic %x: rc = %d\n",
 		       exp->exp_obd->obd_name, le32_to_cpu(lmm->lmv_magic),
@@ -2749,8 +2752,7 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		return -EIO;
 	}
 
-	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_V1 ||
-	    le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_MIGRATE)
+	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_V1)
 		lsm_size = lmv_stripe_md_size(lmv_mds_md_stripe_count_get(lmm));
 	else
 		/**
@@ -2769,7 +2771,6 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 
 	switch (le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
-	case LMV_MAGIC_MIGRATE:
 		rc = lmv_unpack_md_v1(exp, lsm, &lmm->lmv_md_v1);
 		break;
 	default:
@@ -3067,9 +3068,6 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 int lmv_update_lsm_md(struct obd_export *exp, struct lmv_stripe_md *lsm,
 		      struct mdt_body *body, ldlm_blocking_callback cb_blocking)
 {
-	if (lsm->lsm_md_stripe_count <= 1)
-		return 0;
-
 	return lmv_revalidate_slaves(exp, body, lsm, cb_blocking, 0);
 }
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 53b4063..00e8435 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -87,8 +87,8 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode  mode,
 			    __u64 bits);
 /* mdc/mdc_request.c */
-int mdc_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
-		  struct md_op_data *op_data);
+int mdc_fid_alloc(const struct lu_env *env, struct obd_export *exp,
+		  struct lu_fid *fid, struct md_op_data *op_data);
 struct obd_client_handle;
 
 int mdc_set_open_replay_data(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index d8406d5..20b15f6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -1144,7 +1144,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 	/* For case if upper layer did not alloc fid, do it now. */
 	if (!fid_is_sane(&op_data->op_fid2) && it->it_op & IT_CREAT) {
-		rc = mdc_fid_alloc(exp, &op_data->op_fid2, op_data);
+		rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc < 0) {
 			CERROR("Can't alloc new fid, rc %d\n", rc);
 			return rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 5dba2c8..c3781a6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -214,11 +214,9 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 		 * mdc_fid_alloc() may return errno 1 in case of switch to new
 		 * sequence, handle this.
 		 */
-		rc = mdc_fid_alloc(exp, &op_data->op_fid2, op_data);
-		if (rc < 0) {
-			CERROR("Can't alloc new fid, rc %d\n", rc);
+		rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
+		if (rc < 0)
 			return rc;
-		}
 	}
 
 rebuild:
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 394ef3c..e26d0d7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -765,7 +765,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		req_fmt = &RQF_MDS_RELEASE_CLOSE;
 
 		/* allocate a FID for volatile file */
-		rc = mdc_fid_alloc(exp, &op_data->op_fid2, op_data);
+		rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc < 0) {
 			CERROR("%s: "DFID" failed to allocate FID: %d\n",
 			       obd->obd_name, PFID(&op_data->op_fid1), rc);
@@ -2203,13 +2203,13 @@ static int mdc_import_event(struct obd_device *obd, struct obd_import *imp,
 	return rc;
 }
 
-int mdc_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
-		  struct md_op_data *op_data)
+int mdc_fid_alloc(const struct lu_env *env, struct obd_export *exp,
+		  struct lu_fid *fid, struct md_op_data *op_data)
 {
 	struct client_obd *cli = &exp->exp_obd->u.cli;
 	struct lu_client_seq *seq = cli->cl_seq;
 
-	return seq_client_alloc_fid(NULL, seq, fid);
+	return seq_client_alloc_fid(env, seq, fid);
 }
 
 static struct obd_uuid *mdc_get_uuid(struct obd_export *exp)
-- 
1.7.1
