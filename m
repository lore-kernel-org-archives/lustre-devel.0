From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:36 -0400
Subject: [lustre-devel] [PATCH 40/41] staging: lustre: lov: move LSM to LOV
	layer
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Move the definition of struct lov_stripe_md along with supporting
functions from obd.h to lov_internal.h. Remove the unused functions
obd_packmd() and obd_free_diskmd(). Simplify lov_obd_packmd()
according to the reduced use cases and rename it lov_packmd().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13696
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   77 +----------
 drivers/staging/lustre/lustre/include/obd_class.h  |   38 -----
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    1 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  105 --------------
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    4 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   80 +++++++++++-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    9 --
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  145 +++++---------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    8 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |   63 ---------
 11 files changed, 118 insertions(+), 414 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f63336f..ebb3012 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -73,53 +73,7 @@ static inline void loi_init(struct lov_oinfo *loi)
 {
 }
 
-/*
- * If we are unable to get the maximum object size from the OST in
- * ocd_maxbytes using OBD_CONNECT_MAXBYTES, then we fall back to using
- * the old maximum object size from ext3.
- */
-#define LUSTRE_EXT3_STRIPE_MAXBYTES 0x1fffffff000ULL
-
-struct lov_stripe_md {
-	atomic_t     lsm_refc;
-	spinlock_t	lsm_lock;
-	pid_t	    lsm_lock_owner; /* debugging */
-
-	/* maximum possible file size, might change as OSTs status changes,
-	 * e.g. disconnected, deactivated
-	 */
-	loff_t		lsm_maxbytes;
-	struct ost_id	lsm_oi;
-	__u32		lsm_magic;
-	__u32		lsm_stripe_size;
-	__u32		lsm_pattern;	/* striping pattern (RAID0, RAID1) */
-	__u16		lsm_stripe_count;
-	__u16		lsm_layout_gen;
-	char		lsm_pool_name[LOV_MAXPOOLNAME + 1];
-	struct lov_oinfo *lsm_oinfo[0];
-};
-
-static inline bool lsm_is_released(struct lov_stripe_md *lsm)
-{
-	return !!(lsm->lsm_pattern & LOV_PATTERN_F_RELEASED);
-}
-
-static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
-{
-	if (!lsm)
-		return false;
-	if (lsm_is_released(lsm))
-		return false;
-	return true;
-}
-
-static inline int lov_stripe_md_size(unsigned int stripe_count)
-{
-	struct lov_stripe_md lsm;
-
-	return sizeof(lsm) + stripe_count * sizeof(lsm.lsm_oinfo[0]);
-}
-
+struct lov_stripe_md;
 struct obd_info;
 
 typedef int (*obd_enqueue_update_f)(void *cookie, int rc);
@@ -854,8 +808,6 @@ struct obd_ops {
 		      struct obd_statfs *osfs, __u64 max_age, __u32 flags);
 	int (*statfs_async)(struct obd_export *exp, struct obd_info *oinfo,
 			    __u64 max_age, struct ptlrpc_request_set *set);
-	int (*packmd)(struct obd_export *exp, struct lov_mds_md **disk_tgt,
-		      struct lov_stripe_md *mem_src);
 	int (*unpackmd)(struct obd_export *exp,
 			struct lov_stripe_md **mem_tgt,
 			struct lov_mds_md *disk_src, int disk_len);
@@ -1033,33 +985,6 @@ struct md_ops {
 	 */
 };
 
-struct lsm_operations {
-	void (*lsm_free)(struct lov_stripe_md *);
-	void (*lsm_stripe_by_index)(struct lov_stripe_md *, int *, u64 *,
-				    u64 *);
-	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, u64 *,
-				     u64 *);
-	int (*lsm_lmm_verify)(struct lov_mds_md *lmm, int lmm_bytes,
-			      __u16 *stripe_count);
-	int (*lsm_unpackmd)(struct lov_obd *lov, struct lov_stripe_md *lsm,
-			    struct lov_mds_md *lmm);
-};
-
-extern const struct lsm_operations lsm_v1_ops;
-extern const struct lsm_operations lsm_v3_ops;
-static inline const struct lsm_operations *lsm_op_find(int magic)
-{
-	switch (magic) {
-	case LOV_MAGIC_V1:
-	       return &lsm_v1_ops;
-	case LOV_MAGIC_V3:
-	       return &lsm_v3_ops;
-	default:
-	       CERROR("Cannot recognize lsm_magic %08x\n", magic);
-	       return NULL;
-	}
-}
-
 static inline struct md_open_data *obd_mod_alloc(void)
 {
 	struct md_open_data *mod;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 0eaea54..aba96c3 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -609,44 +609,6 @@ obd_process_config(struct obd_device *obd, int datalen, void *data)
 	return rc;
 }
 
-/* Pack an in-memory MD struct for storage on disk.
- * Returns +ve size of packed MD (0 for free), or -ve error.
- *
- * If @disk_tgt == NULL, MD size is returned (max size if @mem_src == NULL).
- * If @*disk_tgt != NULL and @mem_src == NULL, @*disk_tgt will be freed.
- * If @*disk_tgt == NULL, it will be allocated
- */
-static inline int obd_packmd(struct obd_export *exp,
-			     struct lov_mds_md **disk_tgt,
-			     struct lov_stripe_md *mem_src)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, packmd);
-	EXP_COUNTER_INCREMENT(exp, packmd);
-
-	rc = OBP(exp->exp_obd, packmd)(exp, disk_tgt, mem_src);
-	return rc;
-}
-
-static inline int obd_free_diskmd(struct obd_export *exp,
-				  struct lov_mds_md **disk_tgt)
-{
-	LASSERT(disk_tgt);
-	LASSERT(*disk_tgt);
-	/*
-	 * LU-2590, for caller's convenience, *disk_tgt could be host
-	 * endianness, it needs swab to LE if necessary, while just
-	 * lov_mds_md header needs it for figuring out how much memory
-	 * needs to be freed.
-	 */
-	if ((cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) &&
-	    (((*disk_tgt)->lmm_magic == LOV_MAGIC_V1) ||
-	     ((*disk_tgt)->lmm_magic == LOV_MAGIC_V3)))
-		lustre_swab_lov_mds_md(*disk_tgt);
-	return obd_packmd(exp, disk_tgt, NULL);
-}
-
 /* Unpack an MD struct from disk to in-memory format.
  * Returns +ve size of unpacked MD (0 for free), or -ve error.
  *
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cf95a72..24ce243 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -609,8 +609,6 @@ struct ll_file_data {
 	struct list_head fd_lccs; /* list of ll_cl_context */
 };
 
-struct lov_stripe_md;
-
 extern struct dentry *llite_root;
 extern struct kset *llite_kset;
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 09fa357..43e19da 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -42,7 +42,6 @@
 
 enum obd_notify_event;
 struct inode;
-struct lov_stripe_md;
 struct lustre_md;
 struct obd_device;
 struct obd_export;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 75f5958..679cd87 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2736,90 +2736,6 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	return -EINVAL;
 }
 
-static int lmv_pack_md_v1(const struct lmv_stripe_md *lsm,
-			  struct lmv_mds_md_v1 *lmm1)
-{
-	int cplen;
-	int i;
-
-	lmm1->lmv_magic = cpu_to_le32(lsm->lsm_md_magic);
-	lmm1->lmv_stripe_count = cpu_to_le32(lsm->lsm_md_stripe_count);
-	lmm1->lmv_master_mdt_index = cpu_to_le32(lsm->lsm_md_master_mdt_index);
-	lmm1->lmv_hash_type = cpu_to_le32(lsm->lsm_md_hash_type);
-	cplen = strlcpy(lmm1->lmv_pool_name, lsm->lsm_md_pool_name,
-			sizeof(lmm1->lmv_pool_name));
-	if (cplen >= sizeof(lmm1->lmv_pool_name))
-		return -E2BIG;
-
-	for (i = 0; i < lsm->lsm_md_stripe_count; i++)
-		fid_cpu_to_le(&lmm1->lmv_stripe_fids[i],
-			      &lsm->lsm_md_oinfo[i].lmo_fid);
-	return 0;
-}
-
-static int
-lmv_pack_md(union lmv_mds_md **lmmp, const struct lmv_stripe_md *lsm,
-	    int stripe_count)
-{
-	int lmm_size = 0, rc = 0;
-	bool allocated = false;
-
-	LASSERT(lmmp);
-
-	/* Free lmm */
-	if (*lmmp && !lsm) {
-		int stripe_cnt;
-
-		stripe_cnt = lmv_mds_md_stripe_count_get(*lmmp);
-		lmm_size = lmv_mds_md_size(stripe_cnt,
-					   le32_to_cpu((*lmmp)->lmv_magic));
-		if (!lmm_size)
-			return -EINVAL;
-		kvfree(*lmmp);
-		*lmmp = NULL;
-		return 0;
-	}
-
-	/* Alloc lmm */
-	if (!*lmmp && !lsm) {
-		lmm_size = lmv_mds_md_size(stripe_count, LMV_MAGIC);
-		LASSERT(lmm_size > 0);
-		*lmmp = libcfs_kvzalloc(lmm_size, GFP_NOFS);
-		if (!*lmmp)
-			return -ENOMEM;
-		lmv_mds_md_stripe_count_set(*lmmp, stripe_count);
-		(*lmmp)->lmv_magic = cpu_to_le32(LMV_MAGIC);
-		return lmm_size;
-	}
-
-	/* pack lmm */
-	LASSERT(lsm);
-	lmm_size = lmv_mds_md_size(lsm->lsm_md_stripe_count,
-				   lsm->lsm_md_magic);
-	if (!*lmmp) {
-		*lmmp = libcfs_kvzalloc(lmm_size, GFP_NOFS);
-		if (!*lmmp)
-			return -ENOMEM;
-		allocated = true;
-	}
-
-	switch (lsm->lsm_md_magic) {
-	case LMV_MAGIC_V1:
-		rc = lmv_pack_md_v1(lsm, &(*lmmp)->lmv_md_v1);
-		break;
-	default:
-		rc = -EINVAL;
-		break;
-	}
-
-	if (rc && allocated) {
-		kvfree(*lmmp);
-		*lmmp = NULL;
-	}
-
-	return lmm_size;
-}
-
 static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 			    const struct lmv_mds_md_v1 *lmm1)
 {
@@ -2959,26 +2875,6 @@ static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 			     (union lmv_mds_md *)lmm, disk_len);
 }
 
-static int lmv_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
-		      struct lov_stripe_md *lsm)
-{
-	const struct lmv_stripe_md *lmv = (struct lmv_stripe_md *)lsm;
-	struct obd_device *obd = exp->exp_obd;
-	struct lmv_obd *lmv_obd = &obd->u.lmv;
-	int stripe_count;
-
-	if (!lmmp) {
-		if (lsm)
-			stripe_count = lmv->lsm_md_stripe_count;
-		else
-			stripe_count = lmv_obd->desc.ld_tgt_count;
-
-		return lmv_mds_md_size(stripe_count, LMV_MAGIC_V1);
-	}
-
-	return lmv_pack_md((union lmv_mds_md **)lmmp, lmv, 0);
-}
-
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 			     ldlm_policy_data_t *policy, enum ldlm_mode mode,
 			     enum ldlm_cancel_flags flags, void *opaque)
@@ -3282,7 +3178,6 @@ static struct obd_ops lmv_obd_ops = {
 	.statfs		= lmv_statfs,
 	.get_info	= lmv_get_info,
 	.set_info_async	= lmv_set_info_async,
-	.packmd		= lmv_packmd,
 	.unpackmd	= lmv_unpackmd,
 	.notify		= lmv_notify,
 	.get_uuid	= lmv_get_uuid,
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 63dcd29..d7dc0aa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -206,7 +206,7 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
 
 static void
 lsm_stripe_by_index_plain(struct lov_stripe_md *lsm, int *stripeno,
-			  u64 *lov_off, u64 *swidth)
+			  loff_t *lov_off, loff_t *swidth)
 {
 	if (swidth)
 		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
@@ -214,7 +214,7 @@ lsm_stripe_by_index_plain(struct lov_stripe_md *lsm, int *stripeno,
 
 static void
 lsm_stripe_by_offset_plain(struct lov_stripe_md *lsm, int *stripeno,
-			   u64 *lov_off, u64 *swidth)
+			   loff_t *lov_off, loff_t *swidth)
 {
 	if (swidth)
 		*swidth = (u64)lsm->lsm_stripe_size * lsm->lsm_stripe_count;
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index bd105d9..41e7c5f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -36,6 +36,84 @@
 #include "../include/obd_class.h"
 #include "../include/lustre/lustre_user.h"
 
+/*
+ * If we are unable to get the maximum object size from the OST in
+ * ocd_maxbytes using OBD_CONNECT_MAXBYTES, then we fall back to using
+ * the old maximum object size from ext3.
+ */
+#define LUSTRE_EXT3_STRIPE_MAXBYTES 0x1fffffff000ULL
+
+struct lov_stripe_md {
+	atomic_t	lsm_refc;
+	spinlock_t	lsm_lock;
+	pid_t		lsm_lock_owner; /* debugging */
+
+	/*
+	 * maximum possible file size, might change as OSTs status changes,
+	 * e.g. disconnected, deactivated
+	 */
+	loff_t		lsm_maxbytes;
+	struct ost_id	lsm_oi;
+	u32		lsm_magic;
+	u32		lsm_stripe_size;
+	u32		lsm_pattern; /* RAID0, RAID1, released, ... */
+	u16		lsm_stripe_count;
+	u16		lsm_layout_gen;
+	char		lsm_pool_name[LOV_MAXPOOLNAME + 1];
+	struct lov_oinfo	*lsm_oinfo[0];
+};
+
+static inline bool lsm_is_released(struct lov_stripe_md *lsm)
+{
+	return !!(lsm->lsm_pattern & LOV_PATTERN_F_RELEASED);
+}
+
+static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
+{
+	if (!lsm)
+		return false;
+
+	if (lsm_is_released(lsm))
+		return false;
+
+	return true;
+}
+
+static inline int lov_stripe_md_size(unsigned int stripe_count)
+{
+	struct lov_stripe_md lsm;
+
+	return sizeof(lsm) + stripe_count * sizeof(lsm.lsm_oinfo[0]);
+}
+
+struct lsm_operations {
+	void (*lsm_free)(struct lov_stripe_md *);
+	void (*lsm_stripe_by_index)(struct lov_stripe_md *, int *, loff_t *,
+				    loff_t *);
+	void (*lsm_stripe_by_offset)(struct lov_stripe_md *, int *, loff_t *,
+				     loff_t *);
+	int (*lsm_lmm_verify)(struct lov_mds_md *lmm, int lmm_bytes,
+			      u16 *stripe_count);
+	int (*lsm_unpackmd)(struct lov_obd *lov, struct lov_stripe_md *lsm,
+			    struct lov_mds_md *lmm);
+};
+
+extern const struct lsm_operations lsm_v1_ops;
+extern const struct lsm_operations lsm_v3_ops;
+
+static inline const struct lsm_operations *lsm_op_find(int magic)
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
 /* lov_do_div64(a, b) returns a % b, and a = a / b.
  * The 32-bit code is LOV-specific due to knowing about stripe limits in
  * order to reduce the divisor to a 32-bit number.  If the divisor is
@@ -176,8 +254,6 @@ int lov_del_target(struct obd_device *obd, __u32 index,
 /* lov_pack.c */
 ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 		     size_t buf_size);
-int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmm,
-	       struct lov_stripe_md *lsm);
 int lov_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 		 struct lov_mds_md *lmm, int lmm_bytes);
 int lov_alloc_memmd(struct lov_stripe_md **lsmp, __u16 stripe_count,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 6530187..621f66e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -971,14 +971,6 @@ out:
 	return rc;
 }
 
-#define ASSERT_LSM_MAGIC(lsmp)						  \
-do {									    \
-	LASSERT((lsmp));						\
-	LASSERTF(((lsmp)->lsm_magic == LOV_MAGIC_V1 ||			  \
-		 (lsmp)->lsm_magic == LOV_MAGIC_V3),			    \
-		 "%p->lsm_magic=%x\n", (lsmp), (lsmp)->lsm_magic);	      \
-} while (0)
-
 int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
 {
 	struct lov_request_set *lovset = (struct lov_request_set *)data;
@@ -1414,7 +1406,6 @@ static struct obd_ops lov_obd_ops = {
 	.disconnect     = lov_disconnect,
 	.statfs         = lov_statfs,
 	.statfs_async   = lov_statfs_async,
-	.packmd         = lov_packmd,
 	.unpackmd       = lov_unpackmd,
 	.iocontrol      = lov_iocontrol,
 	.get_info       = lov_get_info,
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 1156ef9..17bcead 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -153,96 +153,6 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	return lmm_size;
 }
 
-/* Pack LOV object metadata for disk storage.  It is packed in LE byte
- * order and is opaque to the networking layer.
- *
- * XXX In the future, this will be enhanced to get the EA size from the
- *     underlying OSC device(s) to get their EA sizes so we can stack
- *     LOVs properly.  For now lov_mds_md_size() just assumes one u64
- *     per stripe.
- */
-int lov_obd_packmd(struct lov_obd *lov, struct lov_mds_md **lmmp,
-		   struct lov_stripe_md *lsm)
-{
-	__u16 stripe_count;
-	int lmm_size, lmm_magic;
-
-	if (lsm) {
-		lmm_magic = lsm->lsm_magic;
-	} else {
-		if (lmmp && *lmmp)
-			lmm_magic = le32_to_cpu((*lmmp)->lmm_magic);
-		else
-			/* lsm == NULL and lmmp == NULL */
-			lmm_magic = LOV_MAGIC;
-	}
-
-	if ((lmm_magic != LOV_MAGIC_V1) &&
-	    (lmm_magic != LOV_MAGIC_V3)) {
-		CERROR("bad mem LOV MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
-		       lmm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
-		return -EINVAL;
-	}
-
-	if (lsm) {
-		/* If we are just sizing the EA, limit the stripe count
-		 * to the actual number of OSTs in this filesystem.
-		 */
-		if (!lmmp) {
-			stripe_count = lov_get_stripecnt(lov, lmm_magic,
-							 lsm->lsm_stripe_count);
-			lsm->lsm_stripe_count = stripe_count;
-		} else if (!lsm_is_released(lsm)) {
-			stripe_count = lsm->lsm_stripe_count;
-		} else {
-			stripe_count = 0;
-		}
-	} else {
-		/*
-		 * To calculate maximum easize by active targets at present,
-		 * which is exactly the maximum easize to be seen by LOV
-		 */
-		stripe_count = lov->desc.ld_active_tgt_count;
-	}
-
-	/* XXX LOV STACKING call into osc for sizes */
-	lmm_size = lov_mds_md_size(stripe_count, lmm_magic);
-
-	if (!lmmp)
-		return lmm_size;
-
-	if (*lmmp && !lsm) {
-		stripe_count = le16_to_cpu((*lmmp)->lmm_stripe_count);
-		lmm_size = lov_mds_md_size(stripe_count, lmm_magic);
-		kvfree(*lmmp);
-		*lmmp = NULL;
-		return 0;
-	}
-
-	if (!*lmmp) {
-		*lmmp = libcfs_kvzalloc(lmm_size, GFP_NOFS);
-		if (!*lmmp)
-			return -ENOMEM;
-	}
-
-	CDEBUG(D_INFO, "lov_packmd: LOV_MAGIC 0x%08X, lmm_size = %d\n",
-	       lmm_magic, lmm_size);
-
-	if (!lsm)
-		return lmm_size;
-
-	return lov_lsm_pack(lsm, *lmmp, lmm_size);
-}
-
-int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
-	       struct lov_stripe_md *lsm)
-{
-	struct obd_device *obd = class_exp2obd(exp);
-	struct lov_obd *lov = &obd->u.lov;
-
-	return lov_obd_packmd(lov, lmmp, lsm);
-}
-
 /* Find the max stripecount we should use */
 __u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
 {
@@ -393,15 +303,14 @@ int lov_unpackmd(struct obd_export *exp,  struct lov_stripe_md **lsmp,
 int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		  struct lov_user_md __user *lump)
 {
-	/*
-	 * XXX huge struct allocated on stack.
-	 */
 	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
-	struct lov_obd *lov;
 	struct lov_user_md_v3 lum;
-	struct lov_mds_md *lmmk = NULL;
-	int rc, lmmk_size, lmm_size;
-	int lum_size;
+	struct lov_mds_md *lmmk;
+	u32 stripe_count;
+	ssize_t lmm_size;
+	size_t lmmk_size;
+	size_t lum_size;
+	int rc;
 	mm_segment_t seg;
 
 	if (!lsm)
@@ -414,6 +323,18 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	seg = get_fs();
 	set_fs(KERNEL_DS);
 
+	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
+		CERROR("bad LSM MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
+		       lsm->lsm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
+		rc = -EIO;
+		goto out;
+	}
+
+	if (!lsm_is_released(lsm))
+		stripe_count = lsm->lsm_stripe_count;
+	else
+		stripe_count = 0;
+
 	/* we only need the header part from user space to get lmm_magic and
 	 * lmm_stripe_count, (the header part is common to v1 and v3)
 	 */
@@ -432,32 +353,40 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	if (lum.lmm_stripe_count &&
 	    (lum.lmm_stripe_count < lsm->lsm_stripe_count)) {
 		/* Return right size of stripe to user */
-		lum.lmm_stripe_count = lsm->lsm_stripe_count;
+		lum.lmm_stripe_count = stripe_count;
 		rc = copy_to_user(lump, &lum, lum_size);
 		rc = -EOVERFLOW;
 		goto out;
 	}
-	lov = lu2lov_dev(obj->lo_cl.co_lu.lo_dev)->ld_lov;
-	rc = lov_obd_packmd(lov, &lmmk, lsm);
-	if (rc < 0)
+	lmmk_size = lov_mds_md_size(stripe_count, lsm->lsm_magic);
+
+
+	lmmk = libcfs_kvzalloc(lmmk_size, GFP_NOFS);
+	if (!lmmk) {
+		rc = -ENOMEM;
 		goto out;
-	lmmk_size = rc;
-	lmm_size = rc;
-	rc = 0;
+	}
+
+	lmm_size = lov_lsm_pack(lsm, lmmk, lmmk_size);
+	if (lmm_size < 0) {
+		rc = lmm_size;
+		goto out_free;
+	}
 
 	/* FIXME: Bug 1185 - copy fields properly when structs change */
 	/* struct lov_user_md_v3 and struct lov_mds_md_v3 must be the same */
 	CLASSERT(sizeof(lum) == sizeof(struct lov_mds_md_v3));
 	CLASSERT(sizeof(lum.lmm_objects[0]) == sizeof(lmmk->lmm_objects[0]));
 
-	if ((cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) &&
-	    ((lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V1)) ||
-	    (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)))) {
+	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC &&
+	    (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
+	     lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V3))) {
 		lustre_swab_lov_mds_md(lmmk);
 		lustre_swab_lov_user_md_objects(
 				(struct lov_user_ost_data *)lmmk->lmm_objects,
 				lmmk->lmm_stripe_count);
 	}
+
 	if (lum.lmm_magic == LOV_USER_MAGIC) {
 		/* User request for v1, we need skip lmm_pool_name */
 		if (lmmk->lmm_magic == LOV_MAGIC_V3) {
@@ -491,7 +420,7 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		rc = -EFAULT;
 
 out_free:
-	kfree(lmmk);
+	kvfree(lmmk);
 out:
 	set_fs(seg);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index af373af..10d0b9d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -447,14 +447,6 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 		if (rc < 0)
 			goto out;
 
-		if (rc < (typeof(rc))sizeof(*md->lsm)) {
-			CDEBUG(D_INFO,
-			       "lsm size too small: rc < sizeof (*md->lsm) (%d < %d)\n",
-			       rc, (int)sizeof(*md->lsm));
-			rc = -EPROTO;
-			goto out;
-		}
-
 	} else if (md->body->mbo_valid & OBD_MD_FLDIREA) {
 		int lmvsize;
 		struct lov_mds_md *lmv;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0985bda..038f00c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -103,68 +103,6 @@ static void osc_release_ppga(struct brw_page **ppga, u32 count);
 static int brw_interpret(const struct lu_env *env,
 			 struct ptlrpc_request *req, void *data, int rc);
 
-/* Unpack OSC object metadata from disk storage (LE byte order). */
-static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
-			struct lov_mds_md *lmm, int lmm_bytes)
-{
-	int lsm_size;
-	struct obd_import *imp = class_exp2cliimp(exp);
-
-	if (lmm) {
-		if (lmm_bytes < sizeof(*lmm)) {
-			CERROR("%s: lov_mds_md too small: %d, need %d\n",
-			       exp->exp_obd->obd_name, lmm_bytes,
-			       (int)sizeof(*lmm));
-			return -EINVAL;
-		}
-		/* XXX LOV_MAGIC etc check? */
-
-		if (unlikely(ostid_id(&lmm->lmm_oi) == 0)) {
-			CERROR("%s: zero lmm_object_id: rc = %d\n",
-			       exp->exp_obd->obd_name, -EINVAL);
-			return -EINVAL;
-		}
-	}
-
-	lsm_size = lov_stripe_md_size(1);
-	if (!lsmp)
-		return lsm_size;
-
-	if (*lsmp && !lmm) {
-		kfree((*lsmp)->lsm_oinfo[0]);
-		kfree(*lsmp);
-		*lsmp = NULL;
-		return 0;
-	}
-
-	if (!*lsmp) {
-		*lsmp = kzalloc(lsm_size, GFP_NOFS);
-		if (unlikely(!*lsmp))
-			return -ENOMEM;
-		(*lsmp)->lsm_oinfo[0] = kzalloc(sizeof(struct lov_oinfo),
-						GFP_NOFS);
-		if (unlikely(!(*lsmp)->lsm_oinfo[0])) {
-			kfree(*lsmp);
-			return -ENOMEM;
-		}
-		loi_init((*lsmp)->lsm_oinfo[0]);
-	} else if (unlikely(ostid_id(&(*lsmp)->lsm_oi) == 0)) {
-		return -EBADF;
-	}
-
-	if (lmm)
-		/* XXX zero *lsmp? */
-		ostid_le_to_cpu(&lmm->lmm_oi, &(*lsmp)->lsm_oi);
-
-	if (imp &&
-	    (imp->imp_connect_data.ocd_connect_flags & OBD_CONNECT_MAXBYTES))
-		(*lsmp)->lsm_maxbytes = imp->imp_connect_data.ocd_maxbytes;
-	else
-		(*lsmp)->lsm_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
-
-	return lsm_size;
-}
-
 static inline void osc_pack_req_body(struct ptlrpc_request *req,
 				     struct obdo *oa)
 {
@@ -2884,7 +2822,6 @@ static struct obd_ops osc_obd_ops = {
 	.disconnect     = osc_disconnect,
 	.statfs         = osc_statfs,
 	.statfs_async   = osc_statfs_async,
-	.unpackmd       = osc_unpackmd,
 	.create         = osc_create,
 	.destroy        = osc_destroy,
 	.getattr        = osc_getattr,
-- 
1.7.1
