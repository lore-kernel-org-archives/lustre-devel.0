From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:48 -0500
Subject: [lustre-devel] [PATCH 16/45] staging/lustre/lmv: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-17-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c   |  11 +--
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |   6 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      | 115 ++++++++++-------------
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c    |   4 +-
 4 files changed, 61 insertions(+), 75 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 66de27f..cb1ed42 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -69,7 +69,7 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	int			rc = 0;
 
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL)
+	if (!body)
 		return -EPROTO;
 
 	LASSERT((body->valid & OBD_MD_MDS));
@@ -107,7 +107,7 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 
 	op_data->op_fid1 = body->fid1;
 	/* Sent the parent FID to the remote MDT */
-	if (parent_fid != NULL) {
+	if (parent_fid) {
 		/* The parent fid is only for remote open to
 		 * check whether the open is from OBF,
 		 * see mdt_cross_open */
@@ -204,7 +204,7 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL)
+	if (!body)
 		return -EPROTO;
 	/*
 	 * Not cross-ref case, just get out of here.
@@ -270,7 +270,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
 			     flags, reqp, cb_blocking, extra_lock_flags);
 
-	if (rc < 0 || *reqp == NULL)
+	if (rc < 0 || !*reqp)
 		return rc;
 
 	/*
@@ -278,7 +278,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	 * remote inode. Let's check this.
 	 */
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL)
+	if (!body)
 		return -EPROTO;
 	/* Not cross-ref case, just get out of here. */
 	if (likely(!(body->valid & OBD_MD_MDS)))
@@ -299,7 +299,6 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device *obd = exp->exp_obd;
 	int		rc;
 
-	LASSERT(it != NULL);
 	LASSERT(fid_is_sane(&op_data->op_fid1));
 
 	CDEBUG(D_INODE, "INTENT LOCK '%s' for '%*s' on "DFID"\n",
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index eb8e673..041d30f33 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -66,7 +66,7 @@ static inline struct lmv_stripe_md *lmv_get_mea(struct ptlrpc_request *req)
 	struct mdt_body	 *body;
 	struct lmv_stripe_md    *mea;
 
-	LASSERT(req != NULL);
+	LASSERT(req);
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
@@ -75,8 +75,6 @@ static inline struct lmv_stripe_md *lmv_get_mea(struct ptlrpc_request *req)
 
 	mea = req_capsule_server_sized_get(&req->rq_pill, &RMF_MDT_MD,
 					   body->eadatasize);
-	LASSERT(mea != NULL);
-
 	if (mea->mea_count == 0)
 		return NULL;
 	if (mea->mea_magic != MEA_MAGIC_LAST_CHAR &&
@@ -101,7 +99,7 @@ lmv_get_target(struct lmv_obd *lmv, u32 mds)
 	int i;
 
 	for (i = 0; i < count; i++) {
-		if (lmv->tgts[i] == NULL)
+		if (!lmv->tgts[i])
 			continue;
 
 		if (lmv->tgts[i]->ltd_idx == mds)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 733222c..2df369a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -88,7 +88,7 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, struct obd_uuid *uuid,
 	spin_lock(&lmv->lmv_lock);
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		tgt = lmv->tgts[i];
-		if (tgt == NULL || tgt->ltd_exp == NULL)
+		if (!tgt || !tgt->ltd_exp)
 			continue;
 
 		CDEBUG(D_INFO, "Target idx %d is %s conn %#llx\n", i,
@@ -104,7 +104,7 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, struct obd_uuid *uuid,
 	}
 
 	obd = class_exp2obd(tgt->ltd_exp);
-	if (obd == NULL) {
+	if (!obd) {
 		rc = -ENOTCONN;
 		goto out_lmv_lock;
 	}
@@ -262,7 +262,7 @@ static void lmv_set_timeouts(struct obd_device *obd)
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		tgt = lmv->tgts[i];
-		if (tgt == NULL || tgt->ltd_exp == NULL || tgt->ltd_active == 0)
+		if (!tgt || !tgt->ltd_exp || tgt->ltd_active == 0)
 			continue;
 
 		obd_set_info_async(NULL, tgt->ltd_exp, sizeof(KEY_INTERMDS),
@@ -302,8 +302,7 @@ static int lmv_init_ea_size(struct obd_export *exp, int easize,
 		return 0;
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL ||
-		    lmv->tgts[i]->ltd_exp == NULL ||
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp ||
 		    lmv->tgts[i]->ltd_active == 0) {
 			CWARN("%s: NULL export for %d\n", obd->obd_name, i);
 			continue;
@@ -410,7 +409,7 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 
 static void lmv_del_target(struct lmv_obd *lmv, int index)
 {
-	if (lmv->tgts[index] == NULL)
+	if (!lmv->tgts[index])
 		return;
 
 	kfree(lmv->tgts[index]);
@@ -442,7 +441,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		}
 	}
 
-	if ((index < lmv->tgts_size) && (lmv->tgts[index] != NULL)) {
+	if ((index < lmv->tgts_size) && lmv->tgts[index]) {
 		tgt = lmv->tgts[index];
 		CERROR("%s: UUID %s already assigned at LOV target index %d: rc = %d\n",
 		       obd->obd_name,
@@ -460,7 +459,7 @@ static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		while (newsize < index + 1)
 			newsize <<= 1;
 		newtgts = kcalloc(newsize, sizeof(*newtgts), GFP_NOFS);
-		if (newtgts == NULL) {
+		if (!newtgts) {
 			lmv_init_unlock(lmv);
 			return -ENOMEM;
 		}
@@ -539,11 +538,9 @@ int lmv_check_connect(struct obd_device *obd)
 	CDEBUG(D_CONFIG, "Time to connect %s to %s\n",
 	       lmv->cluuid.uuid, obd->obd_name);
 
-	LASSERT(lmv->tgts != NULL);
-
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		tgt = lmv->tgts[i];
-		if (tgt == NULL)
+		if (!tgt)
 			continue;
 		rc = lmv_connect_mdc(obd, tgt);
 		if (rc)
@@ -563,7 +560,7 @@ int lmv_check_connect(struct obd_device *obd)
 		int rc2;
 
 		tgt = lmv->tgts[i];
-		if (tgt == NULL)
+		if (!tgt)
 			continue;
 		tgt->ltd_active = 0;
 		if (tgt->ltd_exp) {
@@ -586,9 +583,6 @@ static int lmv_disconnect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	struct obd_device      *mdc_obd;
 	int		     rc;
 
-	LASSERT(tgt != NULL);
-	LASSERT(obd != NULL);
-
 	mdc_obd = class_exp2obd(tgt->ltd_exp);
 
 	if (mdc_obd) {
@@ -641,7 +635,7 @@ static int lmv_disconnect(struct obd_export *exp)
 		goto out_local;
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL || lmv->tgts[i]->ltd_exp == NULL)
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 			continue;
 
 		lmv_disconnect_mdc(obd, lmv->tgts[i]);
@@ -686,7 +680,7 @@ repeat_fid2path:
 
 	/* If remote_gf != NULL, it means just building the
 	 * path on the remote MDT, copy this path segment to gf */
-	if (remote_gf != NULL) {
+	if (remote_gf) {
 		struct getinfo_fid2path *ori_gf;
 		char *ptr;
 
@@ -716,7 +710,7 @@ repeat_fid2path:
 		goto out_fid2path;
 
 	/* sigh, has to go to another MDT to do path building further */
-	if (remote_gf == NULL) {
+	if (!remote_gf) {
 		remote_gf_size = sizeof(*remote_gf) + PATH_MAX;
 		remote_gf = kzalloc(remote_gf_size, GFP_NOFS);
 		if (!remote_gf) {
@@ -901,8 +895,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (index >= count)
 			return -ENODEV;
 
-		if (lmv->tgts[index] == NULL ||
-		    lmv->tgts[index]->ltd_active == 0)
+		if (!lmv->tgts[index] || lmv->tgts[index]->ltd_active == 0)
 			return -ENODATA;
 
 		mdc_obd = class_exp2obd(lmv->tgts[index]->ltd_exp);
@@ -936,18 +929,18 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				return -EINVAL;
 
 			tgt = lmv->tgts[qctl->qc_idx];
-			if (tgt == NULL || tgt->ltd_exp == NULL)
+			if (!tgt || !tgt->ltd_exp)
 				return -EINVAL;
 		} else if (qctl->qc_valid == QC_UUID) {
 			for (i = 0; i < count; i++) {
 				tgt = lmv->tgts[i];
-				if (tgt == NULL)
+				if (!tgt)
 					continue;
 				if (!obd_uuid_equals(&tgt->ltd_uuid,
 						     &qctl->obd_uuid))
 					continue;
 
-				if (tgt->ltd_exp == NULL)
+				if (!tgt->ltd_exp)
 					return -EINVAL;
 
 				break;
@@ -981,8 +974,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (icc->icc_mdtindex >= count)
 			return -ENODEV;
 
-		if (lmv->tgts[icc->icc_mdtindex] == NULL ||
-		    lmv->tgts[icc->icc_mdtindex]->ltd_exp == NULL ||
+		if (!lmv->tgts[icc->icc_mdtindex] ||
+		    !lmv->tgts[icc->icc_mdtindex]->ltd_exp ||
 		    lmv->tgts[icc->icc_mdtindex]->ltd_active == 0)
 			return -ENODEV;
 		rc = obd_iocontrol(cmd, lmv->tgts[icc->icc_mdtindex]->ltd_exp,
@@ -990,7 +983,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		break;
 	}
 	case LL_IOC_GET_CONNECT_FLAGS: {
-		if (lmv->tgts[0] == NULL)
+		if (!lmv->tgts[0])
 			return -ENODATA;
 		rc = obd_iocontrol(cmd, lmv->tgts[0]->ltd_exp, len, karg, uarg);
 		break;
@@ -1007,10 +1000,10 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 
 		tgt = lmv_find_target(lmv, &op_data->op_fid1);
 		if (IS_ERR(tgt))
-				return PTR_ERR(tgt);
+			return PTR_ERR(tgt);
 
-		if (tgt->ltd_exp == NULL)
-				return -EINVAL;
+		if (!tgt->ltd_exp)
+			return -EINVAL;
 
 		rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 		break;
@@ -1058,7 +1051,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 						  hur_user_item[nr])
 					 + hur->hur_request.hr_data_len;
 				req = libcfs_kvzalloc(reqlen, GFP_NOFS);
-				if (req == NULL)
+				if (!req)
 					return -ENOMEM;
 
 				lmv_hsm_req_build(lmv, hur, lmv->tgts[i], req);
@@ -1084,7 +1077,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (IS_ERR(tgt2))
 			return PTR_ERR(tgt2);
 
-		if ((tgt1->ltd_exp == NULL) || (tgt2->ltd_exp == NULL))
+		if (!tgt1->ltd_exp || !tgt2->ltd_exp)
 			return -EINVAL;
 
 		/* only files on same MDT can have their layouts swapped */
@@ -1108,8 +1101,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			struct obd_device *mdc_obd;
 			int err;
 
-			if (lmv->tgts[i] == NULL ||
-			    lmv->tgts[i]->ltd_exp == NULL)
+			if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 				continue;
 			/* ll_umount_begin() sets force flag but for lmv, not
 			 * mdc. Let's pass it through */
@@ -1189,7 +1181,7 @@ static int lmv_placement_policy(struct obd_device *obd,
 {
 	struct lmv_obd	  *lmv = &obd->u.lmv;
 
-	LASSERT(mds != NULL);
+	LASSERT(mds);
 
 	if (lmv->desc.ld_tgt_count == 1) {
 		*mds = 0;
@@ -1239,7 +1231,7 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds)
 	 */
 	mutex_lock(&tgt->ltd_fid_mutex);
 
-	if (tgt->ltd_active == 0 || tgt->ltd_exp == NULL) {
+	if (tgt->ltd_active == 0 || !tgt->ltd_exp) {
 		rc = -ENODEV;
 		goto out;
 	}
@@ -1266,8 +1258,8 @@ int lmv_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
 	u32		       mds = 0;
 	int		    rc;
 
-	LASSERT(op_data != NULL);
-	LASSERT(fid != NULL);
+	LASSERT(op_data);
+	LASSERT(fid);
 
 	rc = lmv_placement_policy(obd, op_data, &mds);
 	if (rc) {
@@ -1305,7 +1297,7 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 
 	lmv->tgts = kcalloc(32, sizeof(*lmv->tgts), GFP_NOFS);
-	if (lmv->tgts == NULL)
+	if (!lmv->tgts)
 		return -ENOMEM;
 	lmv->tgts_size = 32;
 
@@ -1346,11 +1338,11 @@ static int lmv_cleanup(struct obd_device *obd)
 	struct lmv_obd   *lmv = &obd->u.lmv;
 
 	fld_client_fini(&lmv->lmv_fld);
-	if (lmv->tgts != NULL) {
+	if (lmv->tgts) {
 		int i;
 
 		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-			if (lmv->tgts[i] == NULL)
+			if (!lmv->tgts[i])
 				continue;
 			lmv_del_target(lmv, i);
 		}
@@ -1416,7 +1408,7 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 		return -ENOMEM;
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL || lmv->tgts[i]->ltd_exp == NULL)
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 			continue;
 
 		rc = obd_statfs(env, lmv->tgts[i]->ltd_exp, temp,
@@ -1561,7 +1553,7 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 	 * space of MDT storing inode.
 	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL || lmv->tgts[i]->ltd_exp == NULL)
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 			continue;
 		md_null_inode(lmv->tgts[i]->ltd_exp, fid);
 	}
@@ -1589,7 +1581,7 @@ static int lmv_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
 	 * space of MDT storing inode.
 	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL || lmv->tgts[i]->ltd_exp == NULL)
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
 			continue;
 		rc = md_find_cbdata(lmv->tgts[i]->ltd_exp, fid, it, data);
 		if (rc)
@@ -1669,7 +1661,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		       cap_effective, rdev, request);
 
 	if (rc == 0) {
-		if (*request == NULL)
+		if (!*request)
 			return rc;
 		CDEBUG(D_INODE, "Created - "DFID"\n", PFID(&op_data->op_fid2));
 	}
@@ -1715,7 +1707,6 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	int			 pmode;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	LASSERT(body != NULL);
 
 	if (!(body->valid & OBD_MD_MDS))
 		return 0;
@@ -1822,7 +1813,6 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 
 	body = req_capsule_server_get(&(*request)->rq_pill,
 				      &RMF_MDT_BODY);
-	LASSERT(body != NULL);
 
 	if (body->valid & OBD_MD_MDS) {
 		struct lu_fid rid = body->fid1;
@@ -2111,7 +2101,7 @@ static void lmv_adjust_dirpages(struct page **pages, int ncfspgs, int nlupgs)
 
 		while (--nlupgs > 0) {
 			ent = lu_dirent_start(dp);
-			for (end_dirent = ent; ent != NULL;
+			for (end_dirent = ent; ent;
 			     end_dirent = ent, ent = lu_dirent_next(ent))
 				;
 
@@ -2241,7 +2231,7 @@ retry:
 		return rc;
 
 	body = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL)
+	if (!body)
 		return -EPROTO;
 
 	/* Not cross-ref case, just get out of here. */
@@ -2305,7 +2295,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 	int		      rc = 0;
 
 	obd = class_exp2obd(exp);
-	if (obd == NULL) {
+	if (!obd) {
 		CDEBUG(D_IOCTL, "Invalid client cookie %#llx\n",
 		       exp->exp_handle.h_cookie);
 		return -EINVAL;
@@ -2326,7 +2316,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			/*
 			 * All tgts should be connected when this gets called.
 			 */
-			if (tgt == NULL || tgt->ltd_exp == NULL)
+			if (!tgt || !tgt->ltd_exp)
 				continue;
 
 			if (!obd_get_info(env, tgt->ltd_exp, keylen, key,
@@ -2369,7 +2359,7 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	int rc = 0;
 
 	obd = class_exp2obd(exp);
-	if (obd == NULL) {
+	if (!obd) {
 		CDEBUG(D_IOCTL, "Invalid client cookie %#llx\n",
 		       exp->exp_handle.h_cookie);
 		return -EINVAL;
@@ -2382,7 +2372,7 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 			tgt = lmv->tgts[i];
 
-			if (tgt == NULL || tgt->ltd_exp == NULL)
+			if (!tgt || !tgt->ltd_exp)
 				continue;
 
 			err = obd_set_info_async(env, tgt->ltd_exp,
@@ -2417,9 +2407,9 @@ static int lmv_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 		return 0;
 	}
 
-	if (*lmmp == NULL) {
+	if (!*lmmp) {
 		*lmmp = libcfs_kvzalloc(mea_size, GFP_NOFS);
-		if (*lmmp == NULL)
+		if (!*lmmp)
 			return -ENOMEM;
 	}
 
@@ -2457,10 +2447,10 @@ static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 	__u32		       magic;
 
 	mea_size = lmv_get_easize(lmv);
-	if (lsmp == NULL)
+	if (!lsmp)
 		return mea_size;
 
-	if (*lsmp != NULL && lmm == NULL) {
+	if (*lsmp && !lmm) {
 		kvfree(*tmea);
 		*lsmp = NULL;
 		return 0;
@@ -2469,7 +2459,7 @@ static int lmv_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 	LASSERT(mea_size == lmm_size);
 
 	*tmea = libcfs_kvzalloc(mea_size, GFP_NOFS);
-	if (*tmea == NULL)
+	if (!*tmea)
 		return -ENOMEM;
 
 	if (!lmm)
@@ -2508,10 +2498,10 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 	int		      err;
 	int		      i;
 
-	LASSERT(fid != NULL);
+	LASSERT(fid);
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL || lmv->tgts[i]->ltd_exp == NULL ||
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp ||
 		    lmv->tgts[i]->ltd_active == 0)
 			continue;
 
@@ -2552,8 +2542,7 @@ static ldlm_mode_t lmv_lock_match(struct obd_export *exp, __u64 flags,
 	 * one fid was created in.
 	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (lmv->tgts[i] == NULL ||
-		    lmv->tgts[i]->ltd_exp == NULL ||
+		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp ||
 		    lmv->tgts[i]->ltd_active == 0)
 			continue;
 
@@ -2709,7 +2698,7 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 
 		tgt = lmv->tgts[i];
 
-		if (tgt == NULL || tgt->ltd_exp == NULL || tgt->ltd_active == 0)
+		if (!tgt || !tgt->ltd_exp || tgt->ltd_active == 0)
 			continue;
 		if (!tgt->ltd_active) {
 			CDEBUG(D_HA, "mdt %d is inactive.\n", i);
@@ -2744,7 +2733,7 @@ static int lmv_quotacheck(struct obd_device *unused, struct obd_export *exp,
 		int err;
 
 		tgt = lmv->tgts[i];
-		if (tgt == NULL || tgt->ltd_exp == NULL || !tgt->ltd_active) {
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active) {
 			CERROR("lmv idx %d inactive\n", i);
 			return -EIO;
 		}
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index 40cf4d9..b39e364 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -138,7 +138,7 @@ static int lmv_desc_uuid_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = (struct obd_device *)m->private;
 	struct lmv_obd	  *lmv;
 
-	LASSERT(dev != NULL);
+	LASSERT(dev);
 	lmv = &dev->u.lmv;
 	seq_printf(m, "%s\n", lmv->desc.ld_uuid.uuid);
 	return 0;
@@ -171,7 +171,7 @@ static int lmv_tgt_seq_show(struct seq_file *p, void *v)
 {
 	struct lmv_tgt_desc     *tgt = v;
 
-	if (tgt == NULL)
+	if (!tgt)
 		return 0;
 	seq_printf(p, "%d: %s %sACTIVE\n",
 		   tgt->ltd_idx, tgt->ltd_uuid.uuid,
-- 
2.1.0
