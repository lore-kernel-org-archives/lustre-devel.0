From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:10 -0400
Subject: [lustre-devel] [PATCH 071/124] staging: lustre: obd: remove unused
	obd methods
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-72-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove no longer used osc_packmd() and osc_getstripe().
Several ioctls cases that are no longer used are removed.
Remove no longer used adjust_kms() infrastructure.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2785
Reviewed-on: http://review.whamcloud.com/8547
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |    3 -
 drivers/staging/lustre/lustre/include/obd_class.h |   13 --
 drivers/staging/lustre/lustre/lov/lov_internal.h  |    2 -
 drivers/staging/lustre/lustre/lov/lov_merge.c     |   39 ------
 drivers/staging/lustre/lustre/lov/lov_obd.c       |    1 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c   |    2 -
 drivers/staging/lustre/lustre/osc/osc_request.c   |  147 ---------------------
 7 files changed, 0 insertions(+), 207 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6eac63e..04a9b97 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -866,7 +866,6 @@ struct obd_ops {
 	int (*unpackmd)(struct obd_export *exp,
 			struct lov_stripe_md **mem_tgt,
 			struct lov_mds_md *disk_src, int disk_len);
-	int (*preallocate)(struct lustre_handle *, u32 *req, u64 *ids);
 	int (*create)(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa, struct lov_stripe_md **ea,
 		      struct obd_trans_info *oti);
@@ -882,8 +881,6 @@ struct obd_ops {
 		       struct obd_info *oinfo);
 	int (*getattr_async)(struct obd_export *exp, struct obd_info *oinfo,
 			     struct ptlrpc_request_set *set);
-	int (*adjust_kms)(struct obd_export *exp, struct lov_stripe_md *lsm,
-			  u64 size, int shrink);
 	int (*preprw)(const struct lu_env *env, int cmd,
 		      struct obd_export *exp, struct obdo *oa, int objcount,
 		      struct obd_ioobj *obj, struct niobuf_remote *remote,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 3d081cf..3245952 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1152,19 +1152,6 @@ static inline int obd_commitrw(const struct lu_env *env, int cmd,
 	return rc;
 }
 
-static inline int obd_adjust_kms(struct obd_export *exp,
-				 struct lov_stripe_md *lsm, u64 size,
-				 int shrink)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, adjust_kms);
-	EXP_COUNTER_INCREMENT(exp, adjust_kms);
-
-	rc = OBP(exp->exp_obd, adjust_kms)(exp, lsm, size, shrink);
-	return rc;
-}
-
 static inline int obd_iocontrol(unsigned int cmd, struct obd_export *exp,
 				int len, void *karg, void __user *uarg)
 {
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 12bd511..5ddaeda 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -134,8 +134,6 @@ static inline void lov_put_reqset(struct lov_request_set *set)
 /* lov_merge.c */
 void lov_merge_attrs(struct obdo *tgt, struct obdo *src, u64 valid,
 		     struct lov_stripe_md *lsm, int stripeno, int *set);
-int lov_adjust_kms(struct obd_export *exp, struct lov_stripe_md *lsm,
-		   u64 size, int shrink);
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 		      struct ost_lvb *lvb, __u64 *kms_place);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index b9c9086..674af10 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -105,45 +105,6 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 	return rc;
 }
 
-/* Must be called under the lov_stripe_lock() */
-int lov_adjust_kms(struct obd_export *exp, struct lov_stripe_md *lsm,
-		   u64 size, int shrink)
-{
-	struct lov_oinfo *loi;
-	int stripe = 0;
-	__u64 kms;
-
-	assert_spin_locked(&lsm->lsm_lock);
-	LASSERT(lsm->lsm_lock_owner == current_pid());
-
-	if (shrink) {
-		for (; stripe < lsm->lsm_stripe_count; stripe++) {
-			struct lov_oinfo *loi = lsm->lsm_oinfo[stripe];
-
-			kms = lov_size_to_stripe(lsm, size, stripe);
-			CDEBUG(D_INODE,
-			       "stripe %d KMS %sing %llu->%llu\n",
-			       stripe, kms > loi->loi_kms ? "increase":"shrink",
-			       loi->loi_kms, kms);
-			loi->loi_lvb.lvb_size = kms;
-			loi_kms_set(loi, loi->loi_lvb.lvb_size);
-		}
-		return 0;
-	}
-
-	if (size > 0)
-		stripe = lov_stripe_number(lsm, size - 1);
-	kms = lov_size_to_stripe(lsm, size, stripe);
-	loi = lsm->lsm_oinfo[stripe];
-
-	CDEBUG(D_INODE, "stripe %d KMS %sincreasing %llu->%llu\n",
-	       stripe, kms > loi->loi_kms ? "" : "not ", loi->loi_kms, kms);
-	if (kms > loi->loi_kms)
-		loi_kms_set(loi, kms);
-
-	return 0;
-}
-
 void lov_merge_attrs(struct obdo *tgt, struct obdo *src, u64 valid,
 		     struct lov_stripe_md *lsm, int stripeno, int *set)
 {
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 2ee4b19..f433515 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2084,7 +2084,6 @@ static struct obd_ops lov_obd_ops = {
 	.destroy        = lov_destroy,
 	.getattr_async  = lov_getattr_async,
 	.setattr_async  = lov_setattr_async,
-	.adjust_kms     = lov_adjust_kms,
 	.iocontrol      = lov_iocontrol,
 	.get_info       = lov_get_info,
 	.set_info_async = lov_set_info_async,
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 88d4d10..2191ca1 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1739,8 +1739,6 @@ static struct obd_ops mgc_obd_ops = {
 	.del_conn       = client_import_del_conn,
 	.connect        = client_connect_import,
 	.disconnect     = client_disconnect_export,
-	/* .enqueue     = mgc_enqueue, */
-	/* .iocontrol   = mgc_iocontrol, */
 	.set_info_async = mgc_set_info_async,
 	.get_info       = mgc_get_info,
 	.import_event   = mgc_import_event,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 1b6491a..71f6abe 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -103,36 +103,6 @@ static void osc_release_ppga(struct brw_page **ppga, u32 count);
 static int brw_interpret(const struct lu_env *env,
 			 struct ptlrpc_request *req, void *data, int rc);
 
-/* Pack OSC object metadata for disk storage (LE byte order). */
-static int osc_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
-		      struct lov_stripe_md *lsm)
-{
-	int lmm_size;
-
-	lmm_size = sizeof(**lmmp);
-	if (!lmmp)
-		return lmm_size;
-
-	if (*lmmp && !lsm) {
-		kfree(*lmmp);
-		*lmmp = NULL;
-		return 0;
-	} else if (unlikely(lsm && ostid_id(&lsm->lsm_oi) == 0)) {
-		return -EBADF;
-	}
-
-	if (!*lmmp) {
-		*lmmp = kzalloc(lmm_size, GFP_NOFS);
-		if (!*lmmp)
-			return -ENOMEM;
-	}
-
-	if (lsm)
-		ostid_cpu_to_le(&lsm->lsm_oi, &(*lmmp)->lmm_oi);
-
-	return lmm_size;
-}
-
 /* Unpack OSC object metadata from disk storage (LE byte order). */
 static int osc_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 			struct lov_mds_md *lmm, int lmm_bytes)
@@ -2570,71 +2540,6 @@ static int osc_statfs(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-/* Retrieve object striping information.
- *
- * @lmmu is a pointer to an in-core struct with lmm_ost_count indicating
- * the maximum number of OST indices which will fit in the user buffer.
- * lmm_magic must be LOV_MAGIC (we only use 1 slot here).
- */
-static int osc_getstripe(struct lov_stripe_md *lsm,
-			 struct lov_user_md __user *lump)
-{
-	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
-	struct lov_user_md_v3 lum, *lumk;
-	struct lov_user_ost_data_v1 *lmm_objects;
-	int rc = 0, lum_size;
-
-	if (!lsm)
-		return -ENODATA;
-
-	/* we only need the header part from user space to get lmm_magic and
-	 * lmm_stripe_count, (the header part is common to v1 and v3)
-	 */
-	lum_size = sizeof(struct lov_user_md_v1);
-	if (copy_from_user(&lum, lump, lum_size))
-		return -EFAULT;
-
-	if ((lum.lmm_magic != LOV_USER_MAGIC_V1) &&
-	    (lum.lmm_magic != LOV_USER_MAGIC_V3))
-		return -EINVAL;
-
-	/* lov_user_md_vX and lov_mds_md_vX must have the same size */
-	LASSERT(sizeof(struct lov_user_md_v1) == sizeof(struct lov_mds_md_v1));
-	LASSERT(sizeof(struct lov_user_md_v3) == sizeof(struct lov_mds_md_v3));
-	LASSERT(sizeof(lum.lmm_objects[0]) == sizeof(lumk->lmm_objects[0]));
-
-	/* we can use lov_mds_md_size() to compute lum_size
-	 * because lov_user_md_vX and lov_mds_md_vX have the same size
-	 */
-	if (lum.lmm_stripe_count > 0) {
-		lum_size = lov_mds_md_size(lum.lmm_stripe_count, lum.lmm_magic);
-		lumk = kzalloc(lum_size, GFP_NOFS);
-		if (!lumk)
-			return -ENOMEM;
-
-		if (lum.lmm_magic == LOV_USER_MAGIC_V1)
-			lmm_objects =
-			    &(((struct lov_user_md_v1 *)lumk)->lmm_objects[0]);
-		else
-			lmm_objects = &lumk->lmm_objects[0];
-		lmm_objects->l_ost_oi = lsm->lsm_oi;
-	} else {
-		lum_size = lov_mds_md_size(0, lum.lmm_magic);
-		lumk = &lum;
-	}
-
-	lumk->lmm_oi = lsm->lsm_oi;
-	lumk->lmm_stripe_count = 1;
-
-	if (copy_to_user(lump, lumk, lum_size))
-		rc = -EFAULT;
-
-	if (lumk != &lum)
-		kfree(lumk);
-
-	return rc;
-}
-
 static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			 void *karg, void __user *uarg)
 {
@@ -2648,57 +2553,6 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		return -EINVAL;
 	}
 	switch (cmd) {
-	case OBD_IOC_LOV_GET_CONFIG: {
-		char *buf;
-		struct lov_desc *desc;
-		struct obd_uuid uuid;
-
-		buf = NULL;
-		len = 0;
-		if (obd_ioctl_getdata(&buf, &len, uarg)) {
-			err = -EINVAL;
-			goto out;
-		}
-
-		data = (struct obd_ioctl_data *)buf;
-
-		if (sizeof(*desc) > data->ioc_inllen1) {
-			obd_ioctl_freedata(buf, len);
-			err = -EINVAL;
-			goto out;
-		}
-
-		if (data->ioc_inllen2 < sizeof(uuid)) {
-			obd_ioctl_freedata(buf, len);
-			err = -EINVAL;
-			goto out;
-		}
-
-		desc = (struct lov_desc *)data->ioc_inlbuf1;
-		desc->ld_tgt_count = 1;
-		desc->ld_active_tgt_count = 1;
-		desc->ld_default_stripe_count = 1;
-		desc->ld_default_stripe_size = 0;
-		desc->ld_default_stripe_offset = 0;
-		desc->ld_pattern = 0;
-		memcpy(&desc->ld_uuid, &obd->obd_uuid, sizeof(uuid));
-
-		memcpy(data->ioc_inlbuf2, &obd->obd_uuid, sizeof(uuid));
-
-		err = copy_to_user(uarg, buf, len);
-		if (err)
-			err = -EFAULT;
-		obd_ioctl_freedata(buf, len);
-		goto out;
-	}
-	case LL_IOC_LOV_SETSTRIPE:
-		err = obd_alloc_memmd(exp, karg);
-		if (err > 0)
-			err = 0;
-		goto out;
-	case LL_IOC_LOV_GETSTRIPE:
-		err = osc_getstripe(karg, uarg);
-		goto out;
 	case OBD_IOC_CLIENT_RECOVER:
 		err = ptlrpc_recover_import(obd->u.cli.cl_import,
 					    data->ioc_inlbuf1, 0);
@@ -3287,7 +3141,6 @@ static struct obd_ops osc_obd_ops = {
 	.disconnect     = osc_disconnect,
 	.statfs         = osc_statfs,
 	.statfs_async   = osc_statfs_async,
-	.packmd         = osc_packmd,
 	.unpackmd       = osc_unpackmd,
 	.create         = osc_create,
 	.destroy        = osc_destroy,
-- 
1.7.1
