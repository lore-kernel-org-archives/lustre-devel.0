From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:32 -0500
Subject: [lustre-devel] [PATCH 02/35] staging: lustre: obd: rename
	obd_unpackmd() to md_unpackmd()
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

obd_unpackmd() is only implemented by LMV so move it from OBD
operations to OBD MD operations and update the prototype to reflex
the actual usage. Remove the unused function obd_free_memmd().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/13737
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   13 +-----
 drivers/staging/lustre/lustre/include/obd.h        |    5 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |   51 +++++++-------------
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    3 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   25 ++-------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   13 ++---
 6 files changed, 33 insertions(+), 77 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index d7f7afa..5aa3645 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -76,18 +76,7 @@ struct lmv_stripe_md {
 
 union lmv_mds_md;
 
-int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
-		  const union lmv_mds_md *lmm, int stripe_count);
-
-static inline int lmv_alloc_memmd(struct lmv_stripe_md **lsmp, int stripe_count)
-{
-	return lmv_unpack_md(NULL, lsmp, NULL, stripe_count);
-}
-
-static inline void lmv_free_memmd(struct lmv_stripe_md *lsm)
-{
-	lmv_unpack_md(NULL, &lsm, NULL, 0);
-}
+void lmv_free_memmd(struct lmv_stripe_md *lsm);
 
 static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
 				  const struct lmv_mds_md_v1 *lmv_src)
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index c8a6e23..5ebcfb8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -808,9 +808,6 @@ struct obd_ops {
 		      struct obd_statfs *osfs, __u64 max_age, __u32 flags);
 	int (*statfs_async)(struct obd_export *exp, struct obd_info *oinfo,
 			    __u64 max_age, struct ptlrpc_request_set *set);
-	int (*unpackmd)(struct obd_export *exp,
-			struct lov_stripe_md **mem_tgt,
-			struct lov_mds_md *disk_src, int disk_len);
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa);
 	int (*destroy)(const struct lu_env *env, struct obd_export *exp,
@@ -978,6 +975,8 @@ struct md_ops {
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
 			       struct lu_fid *, __u64 *bits);
 
+	int (*unpackmd)(struct obd_export *exp, struct lmv_stripe_md **plsm,
+			const union lmv_mds_md *lmv, size_t lmv_size);
 	/*
 	 * NOTE: If adding ops, add another LPROCFS_MD_OP_INIT() line to
 	 * lprocfs_alloc_md_stats() in obdclass/lprocfs_status.c. Also, add a
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 70b355e..f82f37b 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -612,39 +612,6 @@ static inline void obd_cleanup_client_import(struct obd_device *obd)
 	return rc;
 }
 
-/* Unpack an MD struct from disk to in-memory format.
- * Returns +ve size of unpacked MD (0 for free), or -ve error.
- *
- * If @mem_tgt == NULL, MD size is returned (max size if @disk_src == NULL).
- * If @*mem_tgt != NULL and @disk_src == NULL, @*mem_tgt will be freed.
- * If @*mem_tgt == NULL, it will be allocated
- */
-static inline int obd_unpackmd(struct obd_export *exp,
-			       struct lov_stripe_md **mem_tgt,
-			       struct lov_mds_md *disk_src,
-			       int disk_len)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, unpackmd);
-	EXP_COUNTER_INCREMENT(exp, unpackmd);
-
-	rc = OBP(exp->exp_obd, unpackmd)(exp, mem_tgt, disk_src, disk_len);
-	return rc;
-}
-
-static inline int obd_free_memmd(struct obd_export *exp,
-				 struct lov_stripe_md **mem_tgt)
-{
-	int rc;
-
-	LASSERT(mem_tgt);
-	LASSERT(*mem_tgt);
-	rc = obd_unpackmd(exp, mem_tgt, NULL, 0);
-	*mem_tgt = NULL;
-	return rc;
-}
-
 static inline int obd_create(const struct lu_env *env, struct obd_export *exp,
 			     struct obdo *obdo)
 {
@@ -1510,6 +1477,24 @@ static inline int md_get_fid_from_lsm(struct obd_export *exp,
 	return rc;
 }
 
+/* Unpack an MD struct from disk to in-memory format.
+ * Returns +ve size of unpacked MD (0 for free), or -ve error.
+ *
+ * If *plsm != NULL and lmm == NULL then *lsm will be freed.
+ * If *plsm == NULL then it will be allocated.
+ */
+static inline int md_unpackmd(struct obd_export *exp,
+			      struct lmv_stripe_md **plsm,
+			      const union lmv_mds_md *lmm, size_t lmm_size)
+{
+	int rc;
+
+	EXP_CHECK_MD_OP(exp, unpackmd);
+	EXP_MD_COUNTER_INCREMENT(exp, unpackmd);
+	rc = MDP(exp->exp_obd, unpackmd)(exp, plsm, lmm, lmm_size);
+	return rc;
+}
+
 /* OBD Metadata Support */
 
 int obd_init_caches(void);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 52b0374..12731a1 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -54,9 +54,6 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
 
-int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
-		  const union lmv_mds_md *lmm, int stripe_count);
-
 int lmv_revalidate_slaves(struct obd_export *exp,
 			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 12e8b1e..ca78aff 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2816,8 +2816,8 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	return rc;
 }
 
-int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
-		  const union lmv_mds_md *lmm, int stripe_count)
+static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
+			const union lmv_mds_md *lmm, size_t lmm_size)
 {
 	struct lmv_stripe_md *lsm;
 	bool allocated = false;
@@ -2846,17 +2846,6 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 		return 0;
 	}
 
-	/* Alloc memmd */
-	if (!lsm && !lmm) {
-		lsm_size = lmv_stripe_md_size(stripe_count);
-		lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
-		if (!lsm)
-			return -ENOMEM;
-		lsm->lsm_md_stripe_count = stripe_count;
-		*lsmp = lsm;
-		return 0;
-	}
-
 	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_STRIPE)
 		return -EPERM;
 
@@ -2904,14 +2893,12 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	}
 	return lsm_size;
 }
-EXPORT_SYMBOL(lmv_unpack_md);
 
-static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
-			struct lov_mds_md *lmm, int disk_len)
+void lmv_free_memmd(struct lmv_stripe_md *lsm)
 {
-	return lmv_unpack_md(exp, (struct lmv_stripe_md **)lsmp,
-			     (union lmv_mds_md *)lmm, disk_len);
+	lmv_unpackmd(NULL, &lsm, NULL, 0);
 }
+EXPORT_SYMBOL(lmv_free_memmd);
 
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 			     ldlm_policy_data_t *policy, enum ldlm_mode mode,
@@ -3216,7 +3203,6 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.statfs		= lmv_statfs,
 	.get_info	= lmv_get_info,
 	.set_info_async	= lmv_set_info_async,
-	.unpackmd	= lmv_unpackmd,
 	.notify		= lmv_notify,
 	.get_uuid	= lmv_get_uuid,
 	.iocontrol	= lmv_iocontrol,
@@ -3252,6 +3238,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.intent_getattr_async	= lmv_intent_getattr_async,
 	.revalidate_lock	= lmv_revalidate_lock,
 	.get_fid_from_lsm	= lmv_get_fid_from_lsm,
+	.unpackmd		= lmv_unpackmd,
 };
 
 static int __init lmv_init(void)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 215b156..8bf0c5b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -443,8 +443,8 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			goto out;
 		}
 	} else if (md->body->mbo_valid & OBD_MD_FLDIREA) {
-		int lmvsize;
-		struct lov_mds_md *lmv;
+		const union lmv_mds_md *lmv;
+		size_t lmv_size;
 
 		if (!S_ISDIR(md->body->mbo_mode)) {
 			CDEBUG(D_INFO,
@@ -453,22 +453,21 @@ static int mdc_get_lustre_md(struct obd_export *exp,
 			goto out;
 		}
 
-		if (md->body->mbo_eadatasize == 0) {
+		lmv_size = md->body->mbo_eadatasize;
+		if (!lmv_size) {
 			CDEBUG(D_INFO,
 			       "OBD_MD_FLDIREA is set, but eadatasize 0\n");
 			return -EPROTO;
 		}
 		if (md->body->mbo_valid & OBD_MD_MEA) {
-			lmvsize = md->body->mbo_eadatasize;
 			lmv = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
-							   lmvsize);
+							   lmv_size);
 			if (!lmv) {
 				rc = -EPROTO;
 				goto out;
 			}
 
-			rc = obd_unpackmd(md_exp, (void *)&md->lmv, lmv,
-					  lmvsize);
+			rc = md_unpackmd(md_exp, &md->lmv, lmv, lmv_size);
 			if (rc < 0)
 				goto out;
 
-- 
1.7.1
