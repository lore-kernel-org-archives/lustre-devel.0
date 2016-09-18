From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:05 -0400
Subject: [lustre-devel] [PATCH 066/124] staging: lustre: lov: remove
	LL_IOC_RECREATE_{FID, OBJ}
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-67-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove the obsolete ioctls LL_IOC_RECREATE_FID and LL_IOC_RECREATE_OBJ
along with their handlers in llite. Remove the then unused OBD method
lov_create(). Remove OBD_FL_RECREATE_OBJS handling from osc_create().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/12442
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    4 +-
 drivers/staging/lustre/lustre/llite/file.c         |   86 -------------------
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   87 --------------------
 drivers/staging/lustre/lustre/osc/osc_request.c    |    5 -
 4 files changed, 2 insertions(+), 180 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 3ef5db0..de52339 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -202,8 +202,8 @@ struct ost_id {
 #define LL_IOC_LOV_SETSTRIPE	    _IOW('f', 154, long)
 #define LL_IOC_LOV_GETSTRIPE	    _IOW('f', 155, long)
 #define LL_IOC_LOV_SETEA		_IOW('f', 156, long)
-#define LL_IOC_RECREATE_OBJ	     _IOW('f', 157, long)
-#define LL_IOC_RECREATE_FID	     _IOW('f', 157, struct lu_fid)
+/*	LL_IOC_RECREATE_OBJ		157 obsolete */
+/*	LL_IOC_RECREATE_FID		158 obsolete */
 #define LL_IOC_GROUP_LOCK	       _IOW('f', 158, long)
 #define LL_IOC_GROUP_UNLOCK	     _IOW('f', 159, long)
 /* #define LL_IOC_QUOTACHECK		160 OBD_IOC_QUOTACHECK */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index fc81551..4b10260 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1302,88 +1302,6 @@ static ssize_t ll_file_splice_read(struct file *in_file, loff_t *ppos,
 	return result;
 }
 
-static int ll_lov_recreate(struct inode *inode, struct ost_id *oi, u32 ost_idx)
-{
-	struct obd_export *exp = ll_i2dtexp(inode);
-	struct obd_trans_info oti = { 0 };
-	struct obdo *oa = NULL;
-	int lsm_size;
-	int rc = 0;
-	struct lov_stripe_md *lsm = NULL, *lsm2;
-
-	oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-	if (!oa)
-		return -ENOMEM;
-
-	lsm = ccc_inode_lsm_get(inode);
-	if (!lsm_has_objects(lsm)) {
-		rc = -ENOENT;
-		goto out;
-	}
-
-	lsm_size = sizeof(*lsm) + (sizeof(struct lov_oinfo) *
-		   (lsm->lsm_stripe_count));
-
-	lsm2 = libcfs_kvzalloc(lsm_size, GFP_NOFS);
-	if (!lsm2) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	oa->o_oi = *oi;
-	oa->o_nlink = ost_idx;
-	oa->o_flags |= OBD_FL_RECREATE_OBJS;
-	oa->o_valid = OBD_MD_FLID | OBD_MD_FLFLAGS | OBD_MD_FLGROUP;
-	obdo_from_inode(oa, inode, OBD_MD_FLTYPE | OBD_MD_FLATIME |
-				   OBD_MD_FLMTIME | OBD_MD_FLCTIME);
-	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
-	memcpy(lsm2, lsm, lsm_size);
-	ll_inode_size_lock(inode);
-	rc = obd_create(NULL, exp, oa, &lsm2, &oti);
-	ll_inode_size_unlock(inode);
-
-	kvfree(lsm2);
-	goto out;
-out:
-	ccc_inode_lsm_put(inode, lsm);
-	kmem_cache_free(obdo_cachep, oa);
-	return rc;
-}
-
-static int ll_lov_recreate_obj(struct inode *inode, unsigned long arg)
-{
-	struct ll_recreate_obj ucreat;
-	struct ost_id		oi;
-
-	if (!capable(CFS_CAP_SYS_ADMIN))
-		return -EPERM;
-
-	if (copy_from_user(&ucreat, (struct ll_recreate_obj __user *)arg,
-			   sizeof(ucreat)))
-		return -EFAULT;
-
-	ostid_set_seq_mdt0(&oi);
-	ostid_set_id(&oi, ucreat.lrc_id);
-	return ll_lov_recreate(inode, &oi, ucreat.lrc_ost_idx);
-}
-
-static int ll_lov_recreate_fid(struct inode *inode, unsigned long arg)
-{
-	struct lu_fid	fid;
-	struct ost_id	oi;
-	u32		ost_idx;
-
-	if (!capable(CFS_CAP_SYS_ADMIN))
-		return -EPERM;
-
-	if (copy_from_user(&fid, (struct lu_fid __user *)arg, sizeof(fid)))
-		return -EFAULT;
-
-	fid_to_ostid(&fid, &oi);
-	ost_idx = (fid_seq(&fid) >> 16) & 0xffff;
-	return ll_lov_recreate(inode, &oi, ost_idx);
-}
-
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 			     __u64 flags, struct lov_user_md *lum,
 			     int lum_size)
@@ -2322,10 +2240,6 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case LL_IOC_LOV_GETSTRIPE:
 		return ll_lov_getstripe(inode, arg);
-	case LL_IOC_RECREATE_OBJ:
-		return ll_lov_recreate_obj(inode, arg);
-	case LL_IOC_RECREATE_FID:
-		return ll_lov_recreate_fid(inode, arg);
 	case FSFILT_IOC_FIEMAP:
 		return ll_ioctl_fiemap(inode, arg);
 	case FSFILT_IOC_GETFLAGS:
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 265be08..a54cd70 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -972,92 +972,6 @@ out:
 	return rc;
 }
 
-static int lov_recreate(struct obd_export *exp, struct obdo *src_oa,
-			struct lov_stripe_md **ea, struct obd_trans_info *oti)
-{
-	struct lov_stripe_md *obj_mdp, *lsm;
-	struct lov_obd *lov = &exp->exp_obd->u.lov;
-	unsigned ost_idx;
-	int rc, i;
-
-	LASSERT(src_oa->o_valid & OBD_MD_FLFLAGS &&
-		src_oa->o_flags & OBD_FL_RECREATE_OBJS);
-
-	obj_mdp = kzalloc(sizeof(*obj_mdp), GFP_NOFS);
-	if (!obj_mdp)
-		return -ENOMEM;
-
-	ost_idx = src_oa->o_nlink;
-	lsm = *ea;
-	if (!lsm) {
-		rc = -EINVAL;
-		goto out;
-	}
-	if (ost_idx >= lov->desc.ld_tgt_count ||
-	    !lov->lov_tgts[ost_idx]) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_oinfo *loi = lsm->lsm_oinfo[i];
-
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (loi->loi_ost_idx == ost_idx) {
-			if (ostid_id(&loi->loi_oi) != ostid_id(&src_oa->o_oi)) {
-				rc = -EINVAL;
-				goto out;
-			}
-			break;
-		}
-	}
-	if (i == lsm->lsm_stripe_count) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	rc = obd_create(NULL, lov->lov_tgts[ost_idx]->ltd_exp,
-			src_oa, &obj_mdp, oti);
-out:
-	kfree(obj_mdp);
-	return rc;
-}
-
-/* the LOV expects oa->o_id to be set to the LOV object id */
-static int lov_create(const struct lu_env *env, struct obd_export *exp,
-		      struct obdo *src_oa, struct lov_stripe_md **ea,
-		      struct obd_trans_info *oti)
-{
-	struct lov_obd *lov;
-	int rc = 0;
-
-	LASSERT(ea);
-	if (!exp)
-		return -EINVAL;
-
-	if ((src_oa->o_valid & OBD_MD_FLFLAGS) &&
-	    src_oa->o_flags == OBD_FL_DELORPHAN) {
-		/* should be used with LOV anymore */
-		LBUG();
-	}
-
-	lov = &exp->exp_obd->u.lov;
-	if (!lov->desc.ld_active_tgt_count)
-		return -EIO;
-
-	obd_getref(exp->exp_obd);
-	/* Recreate a specific object id at the given OST index */
-	if ((src_oa->o_valid & OBD_MD_FLFLAGS) &&
-	    (src_oa->o_flags & OBD_FL_RECREATE_OBJS)) {
-		rc = lov_recreate(exp, src_oa, ea, oti);
-	}
-
-	obd_putref(exp->exp_obd);
-	return rc;
-}
-
 #define ASSERT_LSM_MAGIC(lsmp)						  \
 do {									    \
 	LASSERT((lsmp));						\
@@ -2281,7 +2195,6 @@ static struct obd_ops lov_obd_ops = {
 	.statfs_async   = lov_statfs_async,
 	.packmd         = lov_packmd,
 	.unpackmd       = lov_unpackmd,
-	.create         = lov_create,
 	.destroy        = lov_destroy,
 	.getattr_async  = lov_getattr_async,
 	.setattr_async  = lov_setattr_async,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7449b77..11c376e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -696,11 +696,6 @@ static int osc_create(const struct lu_env *env, struct obd_export *exp,
 	LASSERT(ea);
 	LASSERT(oa->o_valid & OBD_MD_FLGROUP);
 
-	if ((oa->o_valid & OBD_MD_FLFLAGS) &&
-	    oa->o_flags == OBD_FL_RECREATE_OBJS) {
-		return osc_real_create(exp, oa, ea, oti);
-	}
-
 	if (!fid_seq_is_mdt(ostid_seq(&oa->o_oi)))
 		return osc_real_create(exp, oa, ea, oti);
 
-- 
1.7.1
