From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:56 -0400
Subject: [lustre-devel] [PATCH 04/15] staging: lustre: lmv: kernel crash due
	to misconfigured MDT
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

There are few places with access to lmv->tgts[] without check for NULL.
Usually it may happens when MDT configured starting from index 1
instead of 0. For example:
	mkfs.lustre --reformat --mgs --mdt --index=1 /dev/sdd1

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4098
Reviewed-on: http://review.whamcloud.com/7941
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c |  151 ++++++++++++++++----------
 1 files changed, 93 insertions(+), 58 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 2f6457f..9e31f6b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -132,8 +132,9 @@ static int lmv_set_mdc_active(struct lmv_obd *lmv, struct obd_uuid *uuid,
 static struct obd_uuid *lmv_get_uuid(struct obd_export *exp)
 {
 	struct lmv_obd *lmv = &exp->exp_obd->u.lmv;
+	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
-	return obd_get_uuid(lmv->tgts[0]->ltd_exp);
+	return tgt ? obd_get_uuid(tgt->ltd_exp) : NULL;
 }
 
 static int lmv_notify(struct obd_device *obd, struct obd_device *watched,
@@ -249,7 +250,6 @@ static int lmv_connect(const struct lu_env *env,
 
 static void lmv_set_timeouts(struct obd_device *obd)
 {
-	struct lmv_tgt_desc   *tgt;
 	struct lmv_obd	*lmv;
 	int		    i;
 
@@ -261,8 +261,10 @@ static void lmv_set_timeouts(struct obd_device *obd)
 		return;
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
 		tgt = lmv->tgts[i];
-		if (!tgt || !tgt->ltd_exp || tgt->ltd_active == 0)
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
 		obd_set_info_async(NULL, tgt->ltd_exp, sizeof(KEY_INTERMDS),
@@ -302,13 +304,14 @@ static int lmv_init_ea_size(struct obd_export *exp, int easize,
 		return 0;
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp ||
-		    lmv->tgts[i]->ltd_active == 0) {
+		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active) {
 			CWARN("%s: NULL export for %d\n", obd->obd_name, i);
 			continue;
 		}
 
-		rc = md_init_ea_size(lmv->tgts[i]->ltd_exp, easize, def_easize,
+		rc = md_init_ea_size(tgt->ltd_exp, easize, def_easize,
 				     cookiesize, def_cookiesize);
 		if (rc) {
 			CERROR("%s: obd_init_ea_size() failed on MDT target %d: rc = %d\n",
@@ -534,6 +537,15 @@ int lmv_check_connect(struct obd_device *obd)
 		return -EINVAL;
 	}
 
+	LASSERT(lmv->tgts);
+
+	if (!lmv->tgts[0]) {
+		mutex_unlock(&lmv->lmv_init_mutex);
+		CERROR("%s: no target configured for index 0.\n",
+		       obd->obd_name);
+		return -EINVAL;
+	}
+
 	CDEBUG(D_CONFIG, "Time to connect %s to %s\n",
 	       lmv->cluuid.uuid, obd->obd_name);
 
@@ -796,6 +808,11 @@ static int lmv_hsm_ct_unregister(struct lmv_obd *lmv, unsigned int cmd, int len,
 
 	/* unregister request (call from llapi_hsm_copytool_fini) */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
+		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
+		if (!tgt || !tgt->ltd_exp)
+			continue;
+
 		/* best effort: try to clean as much as possible
 		 * (continue on error)
 		 */
@@ -825,20 +842,28 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 	 * except if it because of inactive target.
 	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		err = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp, len, lk, uarg);
+		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
+		if (!tgt || !tgt->ltd_exp)
+			continue;
+
+		err = obd_iocontrol(cmd, tgt->ltd_exp, len, lk, uarg);
 		if (err) {
-			if (lmv->tgts[i]->ltd_active) {
+			if (tgt->ltd_active) {
 				/* permanent error */
 				CERROR("error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
-				       lmv->tgts[i]->ltd_uuid.uuid,
-				       i, cmd, err);
+				       tgt->ltd_uuid.uuid, i, cmd, err);
 				rc = err;
 				lk->lk_flags |= LK_FLG_STOP;
 				/* unregister from previous MDS */
-				for (j = 0; j < i; j++)
-					obd_iocontrol(cmd,
-						      lmv->tgts[j]->ltd_exp,
-						      len, lk, uarg);
+				for (j = 0; j < i; j++) {
+					tgt = lmv->tgts[j];
+
+					if (!tgt || !tgt->ltd_exp)
+						continue;
+					obd_iocontrol(cmd, tgt->ltd_exp, len,
+						      lk, uarg);
+				}
 				return rc;
 			}
 			/* else: transient error.
@@ -877,6 +902,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 {
 	struct obd_device    *obddev = class_exp2obd(exp);
 	struct lmv_obd       *lmv = &obddev->u.lmv;
+	struct lmv_tgt_desc *tgt = NULL;
 	int		   i = 0;
 	int		   rc = 0;
 	int		   set = 0;
@@ -896,10 +922,11 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (index >= count)
 			return -ENODEV;
 
-		if (!lmv->tgts[index] || lmv->tgts[index]->ltd_active == 0)
+		tgt = lmv->tgts[index];
+		if (!tgt || !tgt->ltd_active)
 			return -ENODATA;
 
-		mdc_obd = class_exp2obd(lmv->tgts[index]->ltd_exp);
+		mdc_obd = class_exp2obd(tgt->ltd_exp);
 		if (!mdc_obd)
 			return -EINVAL;
 
@@ -909,7 +936,7 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				     (int)sizeof(struct obd_uuid))))
 			return -EFAULT;
 
-		rc = obd_statfs(NULL, lmv->tgts[index]->ltd_exp, &stat_buf,
+		rc = obd_statfs(NULL, tgt->ltd_exp, &stat_buf,
 				cfs_time_shift_64(-OBD_STATFS_CACHE_SECONDS),
 				0);
 		if (rc)
@@ -922,7 +949,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	}
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl = karg;
-		struct lmv_tgt_desc *tgt = NULL;
 		struct obd_quotactl *oqctl;
 
 		if (qctl->qc_valid == QC_MDTIDX) {
@@ -975,18 +1001,18 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (icc->icc_mdtindex >= count)
 			return -ENODEV;
 
-		if (!lmv->tgts[icc->icc_mdtindex] ||
-		    !lmv->tgts[icc->icc_mdtindex]->ltd_exp ||
-		    lmv->tgts[icc->icc_mdtindex]->ltd_active == 0)
+		tgt = lmv->tgts[icc->icc_mdtindex];
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			return -ENODEV;
-		rc = obd_iocontrol(cmd, lmv->tgts[icc->icc_mdtindex]->ltd_exp,
-				   sizeof(*icc), icc, NULL);
+		rc = obd_iocontrol(cmd, tgt->ltd_exp, sizeof(*icc), icc, NULL);
 		break;
 	}
 	case LL_IOC_GET_CONNECT_FLAGS: {
-		if (!lmv->tgts[0])
+		tgt = lmv->tgts[0];
+
+		if (!tgt || !tgt->ltd_exp)
 			return -ENODATA;
-		rc = obd_iocontrol(cmd, lmv->tgts[0]->ltd_exp, len, karg, uarg);
+		rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 		break;
 	}
 	case OBD_IOC_FID2PATH: {
@@ -997,7 +1023,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	case LL_IOC_HSM_STATE_SET:
 	case LL_IOC_HSM_ACTION: {
 		struct md_op_data	*op_data = karg;
-		struct lmv_tgt_desc	*tgt;
 
 		tgt = lmv_find_target(lmv, &op_data->op_fid1);
 		if (IS_ERR(tgt))
@@ -1011,7 +1036,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	}
 	case LL_IOC_HSM_PROGRESS: {
 		const struct hsm_progress_kernel *hpk = karg;
-		struct lmv_tgt_desc	*tgt;
 
 		tgt = lmv_find_target(lmv, &hpk->hpk_fid);
 		if (IS_ERR(tgt))
@@ -1021,7 +1045,6 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 	}
 	case LL_IOC_HSM_REQUEST: {
 		struct hsm_user_request *hur = karg;
-		struct lmv_tgt_desc	*tgt;
 		unsigned int reqcount = hur->hur_request.hr_itemcount;
 
 		if (reqcount == 0)
@@ -1044,7 +1067,11 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				int			rc1;
 				struct hsm_user_request *req;
 
-				nr = lmv_hsm_req_count(lmv, hur, lmv->tgts[i]);
+				tgt = lmv->tgts[i];
+				if (!tgt || !tgt->ltd_exp)
+					continue;
+
+				nr = lmv_hsm_req_count(lmv, hur, tgt);
 				if (nr == 0) /* nothing for this MDS */
 					continue;
 
@@ -1056,10 +1083,10 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 				if (!req)
 					return -ENOMEM;
 
-				lmv_hsm_req_build(lmv, hur, lmv->tgts[i], req);
+				lmv_hsm_req_build(lmv, hur, tgt, req);
 
-				rc1 = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp,
-						    reqlen, req, uarg);
+				rc1 = obd_iocontrol(cmd, tgt->ltd_exp, reqlen,
+						    req, uarg);
 				if (rc1 != 0 && rc == 0)
 					rc = rc1;
 				kvfree(req);
@@ -1103,22 +1130,21 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			struct obd_device *mdc_obd;
 			int err;
 
-			if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp)
+			tgt = lmv->tgts[i];
+			if (!tgt || !tgt->ltd_exp)
 				continue;
 			/* ll_umount_begin() sets force flag but for lmv, not
 			 * mdc. Let's pass it through
 			 */
-			mdc_obd = class_exp2obd(lmv->tgts[i]->ltd_exp);
+			mdc_obd = class_exp2obd(tgt->ltd_exp);
 			mdc_obd->obd_force = obddev->obd_force;
-			err = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp, len,
-					    karg, uarg);
+			err = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 			if (err == -ENODATA && cmd == OBD_IOC_POLL_QUOTACHECK) {
 				return err;
 			} else if (err) {
-				if (lmv->tgts[i]->ltd_active) {
+				if (tgt->ltd_active) {
 					CERROR("error: iocontrol MDC %s on MDTidx %d cmd %x: err = %d\n",
-					       lmv->tgts[i]->ltd_uuid.uuid,
-					       i, cmd, err);
+					       tgt->ltd_uuid.uuid, i, cmd, err);
 					if (!rc)
 						rc = err;
 				}
@@ -2269,7 +2295,6 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 
 	lmv = &obd->u.lmv;
 	if (keylen >= strlen("remote_flag") && !strcmp(key, "remote_flag")) {
-		struct lmv_tgt_desc *tgt;
 		int i;
 
 		rc = lmv_check_connect(obd);
@@ -2278,7 +2303,8 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 
 		LASSERT(*vallen == sizeof(__u32));
 		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-			tgt = lmv->tgts[i];
+			struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
 			/*
 			 * All tgts should be connected when this gets called.
 			 */
@@ -2467,12 +2493,13 @@ static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 	LASSERT(fid);
 
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp ||
-		    lmv->tgts[i]->ltd_active == 0)
+		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
-		err = md_cancel_unused(lmv->tgts[i]->ltd_exp, fid,
-				       policy, mode, flags, opaque);
+		err = md_cancel_unused(tgt->ltd_exp, fid, policy, mode, flags,
+				       opaque);
 		if (!rc)
 			rc = err;
 	}
@@ -2483,9 +2510,13 @@ static int lmv_set_lock_data(struct obd_export *exp, __u64 *lockh, void *data,
 			     __u64 *bits)
 {
 	struct lmv_obd	  *lmv = &exp->exp_obd->u.lmv;
+	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 	int		      rc;
 
-	rc =  md_set_lock_data(lmv->tgts[0]->ltd_exp, lockh, data, bits);
+	if (!tgt || !tgt->ltd_exp)
+		return -EINVAL;
+
+	rc = md_set_lock_data(tgt->ltd_exp, lockh, data, bits);
 	return rc;
 }
 
@@ -2510,12 +2541,13 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, __u64 flags,
 	 * one fid was created in.
 	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		if (!lmv->tgts[i] || !lmv->tgts[i]->ltd_exp ||
-		    lmv->tgts[i]->ltd_active == 0)
+		struct lmv_tgt_desc *tgt = lmv->tgts[i];
+
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
 
-		rc = md_lock_match(lmv->tgts[i]->ltd_exp, flags, fid,
-				   type, policy, mode, lockh);
+		rc = md_lock_match(tgt->ltd_exp, flags, fid, type, policy, mode,
+				   lockh);
 		if (rc)
 			return rc;
 	}
@@ -2530,18 +2562,24 @@ static int lmv_get_lustre_md(struct obd_export *exp,
 			     struct lustre_md *md)
 {
 	struct lmv_obd	  *lmv = &exp->exp_obd->u.lmv;
+	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
-	return md_get_lustre_md(lmv->tgts[0]->ltd_exp, req, dt_exp, md_exp, md);
+	if (!tgt || !tgt->ltd_exp)
+		return -EINVAL;
+	return md_get_lustre_md(tgt->ltd_exp, req, dt_exp, md_exp, md);
 }
 
 static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt = lmv->tgts[0];
 
 	if (md->mea)
 		obd_free_memmd(exp, (void *)&md->mea);
-	return md_free_lustre_md(lmv->tgts[0]->ltd_exp, md);
+	if (!tgt || !tgt->ltd_exp)
+		return -EINVAL;
+	return md_free_lustre_md(tgt->ltd_exp, md);
 }
 
 static int lmv_set_open_replay_data(struct obd_export *exp,
@@ -2650,7 +2688,8 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 	int		  rc = 0, i;
 	__u64		curspace, curinodes;
 
-	if (!lmv->desc.ld_tgt_count || !tgt->ltd_active) {
+	if (!tgt || !tgt->ltd_exp || !tgt->ltd_active ||
+	    !lmv->desc.ld_tgt_count) {
 		CERROR("master lmv inactive\n");
 		return -EIO;
 	}
@@ -2666,12 +2705,8 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 
 		tgt = lmv->tgts[i];
 
-		if (!tgt || !tgt->ltd_exp || tgt->ltd_active == 0)
+		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
 			continue;
-		if (!tgt->ltd_active) {
-			CDEBUG(D_HA, "mdt %d is inactive.\n", i);
-			continue;
-		}
 
 		err = obd_quotactl(tgt->ltd_exp, oqctl);
 		if (err) {
-- 
1.7.1
