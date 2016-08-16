From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:19 -0400
Subject: [lustre-devel] [PATCH 66/80] staging: lustre: lmv: try all stripes
	for unknown hash functions
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-67-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

For unknown hash type, LMV should try all stripes to locate
the name entry. But it will only for lookup and unlink, i.e.
we can only list and unlink entries under striped dir with
unknown hash type.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4921
Reviewed-on: http://review.whamcloud.com/10041
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
 .../staging/lustre/lustre/include/obd_support.h    |    3 +
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   70 +++++++---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   12 ++
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  144 ++++++++++++++++----
 5 files changed, 182 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 9e38ed3..52cd585 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -383,6 +383,7 @@ struct lmv_user_mds_data {
 };
 
 enum lmv_hash_type {
+	LMV_HASH_TYPE_UNKNOWN	= 0,	/* 0 is reserved for testing purpose */
 	LMV_HASH_TYPE_ALL_CHARS = 1,
 	LMV_HASH_TYPE_FNV_1A_64 = 2,
 };
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index a11fff1..f747bca 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -483,6 +483,9 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_UPDATE_OBJ_NET			0x1700
 #define OBD_FAIL_UPDATE_OBJ_NET_REP		0x1701
 
+/* LMV */
+#define OBD_FAIL_UNKNOWN_LMV_STRIPE		0x1901
+
 /* Assign references to moved code to reduce code changes */
 #define OBD_FAIL_PRECHECK(id)		   CFS_FAIL_PRECHECK(id)
 #define OBD_FAIL_CHECK(id)		      CFS_FAIL_CHECK(id)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index cde1d7b..0559445 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -402,10 +402,28 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	struct mdt_body	*body;
 	int		     rc = 0;
 
+	/*
+	 * If it returns ERR_PTR(-EBADFD) then it is an unknown hash type
+	 * it will try all stripes to locate the object
+	 */
 	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(tgt))
+	if (IS_ERR(tgt) && (PTR_ERR(tgt) != -EBADFD))
 		return PTR_ERR(tgt);
 
+	/*
+	 * Both migrating dir and unknown hash dir need to try
+	 * all of sub-stripes
+	 */
+	if (lsm && !lmv_is_known_hash_type(lsm)) {
+		struct lmv_oinfo *oinfo = &lsm->lsm_md_oinfo[0];
+
+		op_data->op_fid1 = oinfo->lmo_fid;
+		op_data->op_mds = oinfo->lmo_mds;
+		tgt = lmv_get_target(lmv, oinfo->lmo_mds, NULL);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+	}
+
 	if (!fid_is_sane(&op_data->op_fid2))
 		fid_zero(&op_data->op_fid2);
 
@@ -435,27 +453,39 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		}
 		return rc;
 	} else if (it_disposition(it, DISP_LOOKUP_NEG) && lsm &&
-		   lsm->lsm_md_magic & LMV_HASH_FLAG_MIGRATION) {
+		   lmv_need_try_all_stripes(lsm)) {
 		/*
-		 * For migrating directory, if it can not find the child in
-		 * the source directory(master stripe), try the targeting
-		 * directory(stripe 1)
+		 * For migrating and unknown hash type directory, it will
+		 * try to target the entry on other stripes
 		 */
-		tgt = lmv_find_target(lmv, &lsm->lsm_md_oinfo[1].lmo_fid);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
-
-		ptlrpc_req_finished(*reqp);
-		it->it_request = NULL;
-		*reqp = NULL;
-
-		CDEBUG(D_INODE, "For migrating dir, try target dir "DFID"\n",
-		       PFID(&lsm->lsm_md_oinfo[1].lmo_fid));
-
-		op_data->op_fid1 = lsm->lsm_md_oinfo[1].lmo_fid;
-		it->it_disposition &= ~DISP_ENQ_COMPLETE;
-		rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
-				    flags, reqp, cb_blocking, extra_lock_flags);
+		int stripe_index;
+
+		for (stripe_index = 1;
+		     stripe_index < lsm->lsm_md_stripe_count &&
+		     it_disposition(it, DISP_LOOKUP_NEG); stripe_index++) {
+			struct lmv_oinfo *oinfo;
+
+			/* release the previous request */
+			ptlrpc_req_finished(*reqp);
+			it->it_request = NULL;
+			*reqp = NULL;
+
+			oinfo = &lsm->lsm_md_oinfo[stripe_index];
+			tgt = lmv_find_target(lmv, &oinfo->lmo_fid);
+			if (IS_ERR(tgt))
+				return PTR_ERR(tgt);
+
+			CDEBUG(D_INODE, "Try other stripes " DFID"\n",
+			       PFID(&oinfo->lmo_fid));
+
+			op_data->op_fid1 = oinfo->lmo_fid;
+			it->it_disposition &= ~DISP_ENQ_COMPLETE;
+			rc = md_intent_lock(tgt->ltd_exp, op_data, lmm,
+					    lmmsize, it, flags, reqp,
+					    cb_blocking, extra_lock_flags);
+			if (rc)
+				return rc;
+		}
 	}
 
 	/*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index faf6a7b..ea528ae 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -147,6 +147,18 @@ lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
 	return &lsm->lsm_md_oinfo[stripe_index];
 }
 
+static inline bool lmv_is_known_hash_type(const struct lmv_stripe_md *lsm)
+{
+	return lsm->lsm_md_hash_type == LMV_HASH_TYPE_FNV_1A_64 ||
+	       lsm->lsm_md_hash_type == LMV_HASH_TYPE_ALL_CHARS;
+}
+
+static inline bool lmv_need_try_all_stripes(const struct lmv_stripe_md *lsm)
+{
+	return !lmv_is_known_hash_type(lsm) ||
+	       lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION;
+}
+
 struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 27a6be1..e9f4e9a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -102,8 +102,8 @@ int lmv_name_to_stripe_index(__u32 lmv_hash_type, unsigned int stripe_count,
 		idx = lmv_hash_fnv1a(stripe_count, name, namelen);
 		break;
 	default:
-		CERROR("Unknown hash type 0x%x\n", hash_type);
-		return -EINVAL;
+		idx = -EBADFD;
+		break;
 	}
 
 	CDEBUG(D_INFO, "name %.*s hash_type %d idx %d\n", namelen, name,
@@ -1697,6 +1697,23 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 	return tgt;
 }
 
+/**
+ * Locate mds by fid or name
+ *
+ * For striped directory (lsm != NULL), it will locate the stripe
+ * by name hash (see lsm_name_to_stripe_info()). Note: if the hash_type
+ * is unknown, it will return -EBADFD, and lmv_intent_lookup might need
+ * walk through all of stripes to locate the entry.
+ *
+ * For normal direcotry, it will locate MDS by FID directly.
+ * \param[in] lmv	LMV device
+ * \param[in] op_data	client MD stack parameters, name, namelen
+ *			mds_num etc.
+ * \param[in] fid	object FID used to locate MDS.
+ *
+ * retval		pointer to the lmv_tgt_desc if succeed.
+ *			ERR_PTR(errno) if failed.
+ */
 struct lmv_tgt_desc
 *lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
 		struct lu_fid *fid)
@@ -2351,45 +2368,94 @@ static int lmv_readpage(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
+/**
+ * Unlink a file/directory
+ *
+ * Unlink a file or directory under the parent dir. The unlink request
+ * usually will be sent to the MDT where the child is located, but if
+ * the client does not have the child FID then request will be sent to the
+ * MDT where the parent is located.
+ *
+ * If the parent is a striped directory then it also needs to locate which
+ * stripe the name of the child is located, and replace the parent FID
+ * (@op->op_fid1) with the stripe FID. Note: if the stripe is unknown,
+ * it will walk through all of sub-stripes until the child is being
+ * unlinked finally.
+ *
+ * \param[in] exp	export refer to LMV
+ * \param[in] op_data	different parameters transferred beween client
+ *			MD stacks, name, namelen, FIDs etc.
+ *			op_fid1 is the parent FID, op_fid2 is the child
+ *			FID.
+ * \param[out] request point to the request of unlink.
+ *
+ * retval		0 if succeed
+ *			negative errno if failed.
+ */
 static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		      struct ptlrpc_request **request)
 {
-	struct obd_device       *obd = exp->exp_obd;
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct obd_device    *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *parent_tgt = NULL;
 	struct lmv_tgt_desc     *tgt = NULL;
 	struct mdt_body		*body;
+	int stripe_index = 0;
 	int		     rc;
 
 	rc = lmv_check_connect(obd);
 	if (rc)
 		return rc;
-retry:
-	/* Send unlink requests to the MDT where the child is located */
-	if (likely(!fid_is_zero(&op_data->op_fid2))) {
-		tgt = lmv_find_target(lmv, &op_data->op_fid2);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
+retry_unlink:
+	/* For striped dir, we need to locate the parent as well */
+	if (lsm) {
+		struct lmv_tgt_desc *tmp;
 
-		/* For striped dir, we need to locate the parent as well */
-		if (op_data->op_mea1) {
-			struct lmv_tgt_desc *tmp;
-
-			LASSERT(op_data->op_name && op_data->op_namelen);
-			tmp = lmv_locate_target_for_name(lmv, op_data->op_mea1,
-							 op_data->op_name,
-							 op_data->op_namelen,
-							 &op_data->op_fid1,
-							 &op_data->op_mds);
-			if (IS_ERR(tmp))
-				return PTR_ERR(tmp);
+		LASSERT(op_data->op_name && op_data->op_namelen);
+
+		tmp = lmv_locate_target_for_name(lmv, lsm,
+						 op_data->op_name,
+						 op_data->op_namelen,
+						 &op_data->op_fid1,
+						 &op_data->op_mds);
+
+		/*
+		 * return -EBADFD means unknown hash type, might
+		 * need try all sub-stripe here
+		 */
+		if (IS_ERR(tmp) && PTR_ERR(tmp) != -EBADFD)
+			return PTR_ERR(tmp);
+
+		/*
+		 * Note: both migrating dir and unknown hash dir need to
+		 * try all of sub-stripes, so we need start search the
+		 * name from stripe 0, but migrating dir is already handled
+		 * inside lmv_locate_target_for_name(), so we only check
+		 * unknown hash type directory here
+		 */
+		if (!lmv_is_known_hash_type(lsm)) {
+			struct lmv_oinfo *oinfo;
+
+			oinfo = &lsm->lsm_md_oinfo[stripe_index];
+
+			op_data->op_fid1 = oinfo->lmo_fid;
+			op_data->op_mds = oinfo->lmo_mds;
 		}
-	} else {
-		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
 	}
 
+try_next_stripe:
+	/* Send unlink requests to the MDT where the child is located */
+	if (likely(!fid_is_zero(&op_data->op_fid2)))
+		tgt = lmv_find_target(lmv, &op_data->op_fid2);
+	else if (lsm)
+		tgt = lmv_get_target(lmv, op_data->op_mds, NULL);
+	else
+		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
 	op_data->op_fsuid = from_kuid(&init_user_ns, current_fsuid());
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = cfs_curproc_cap_pack();
@@ -2425,9 +2491,28 @@ retry:
 	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2), tgt->ltd_idx);
 
 	rc = md_unlink(tgt->ltd_exp, op_data, request);
-	if (rc != 0 && rc != -EREMOTE)
+	if (rc != 0 && rc != -EREMOTE  && rc != -ENOENT)
 		return rc;
 
+	/* Try next stripe if it is needed. */
+	if (rc == -ENOENT && lsm && lmv_need_try_all_stripes(lsm)) {
+		struct lmv_oinfo *oinfo;
+
+		stripe_index++;
+		if (stripe_index >= lsm->lsm_md_stripe_count)
+			return rc;
+
+		oinfo = &lsm->lsm_md_oinfo[stripe_index];
+
+		op_data->op_fid1 = oinfo->lmo_fid;
+		op_data->op_mds = oinfo->lmo_mds;
+
+		ptlrpc_req_finished(*request);
+		*request = NULL;
+
+		goto try_next_stripe;
+	}
+
 	body = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
 	if (!body)
 		return -EPROTO;
@@ -2463,7 +2548,7 @@ retry:
 	ptlrpc_req_finished(*request);
 	*request = NULL;
 
-	goto retry;
+	goto retry_unlink;
 }
 
 static int lmv_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
@@ -2683,7 +2768,10 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	lsm->lsm_md_magic = le32_to_cpu(lmm1->lmv_magic);
 	lsm->lsm_md_stripe_count = le32_to_cpu(lmm1->lmv_stripe_count);
 	lsm->lsm_md_master_mdt_index = le32_to_cpu(lmm1->lmv_master_mdt_index);
-	lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
+	if (OBD_FAIL_CHECK(OBD_FAIL_UNKNOWN_LMV_STRIPE))
+		lsm->lsm_md_hash_type = LMV_HASH_TYPE_UNKNOWN;
+	else
+		lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
 	lsm->lsm_md_layout_version = le32_to_cpu(lmm1->lmv_layout_version);
 	fid_le_to_cpu(&lsm->lsm_md_master_fid, &lmm1->lmv_master_fid);
 	cplen = strlcpy(lsm->lsm_md_pool_name, lmm1->lmv_pool_name,
-- 
1.7.1
