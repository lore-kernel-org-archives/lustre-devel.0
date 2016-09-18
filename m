From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:03 -0400
Subject: [lustre-devel] [PATCH 004/124] staging: lustre: lmv: honor MDT
	index when creating volatile file
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

LMV should honor MDT index embedded in the name of volatile
file, then during hsm restore, the file under striped dir can
be restored to the right MDT.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4691
Reviewed-on: http://review.whamcloud.com/10866
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
 drivers/staging/lustre/lustre/llite/dir.c          |   17 ++++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    5 +-
 drivers/staging/lustre/lustre/lmv/lmv_fld.c        |   16 +++---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    5 ++
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   52 ++++++++++++++++++-
 6 files changed, 84 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 351fb4c..c69918b 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -244,6 +244,7 @@ struct ost_id {
 #define LL_IOC_HSM_IMPORT		_IOWR('f', 245, struct hsm_user_import)
 #define LL_IOC_LMV_SET_DEFAULT_STRIPE	_IOWR('f', 246, struct lmv_user_md)
 #define LL_IOC_MIGRATE			_IOR('f', 247, int)
+#define LL_IOC_FID2MDTIDX		_IOWR('f', 248, struct lu_fid)
 
 #define LL_STATFS_LMV	   1
 #define LL_STATFS_LOV	   2
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 532047b..c97a4a0 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1568,6 +1568,23 @@ out_quotactl:
 		return rc;
 	case OBD_IOC_FID2PATH:
 		return ll_fid2path(inode, (void __user *)arg);
+	case LL_IOC_FID2MDTIDX: {
+		struct obd_export *exp = ll_i2mdexp(inode);
+		struct lu_fid fid;
+		__u32 index;
+
+		if (copy_from_user(&fid, (const struct lu_fid __user *)arg,
+				   sizeof(fid)))
+			return -EFAULT;
+
+		/* Call mdc_iocontrol */
+		rc = obd_iocontrol(LL_IOC_FID2MDTIDX, exp, sizeof(fid), &fid,
+				   &index);
+		if (rc)
+			return rc;
+
+		return index;
+	}
 	case LL_IOC_HSM_REQUEST: {
 		struct hsm_user_request	*hur;
 		ssize_t			 totalsize;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 1ff788e..99aba6b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2373,9 +2373,10 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_bias = 0;
 	op_data->op_cli_flags = 0;
 	if ((opc == LUSTRE_OPC_CREATE) && name &&
-	    filename_is_volatile(name, namelen, NULL))
+	    filename_is_volatile(name, namelen, &op_data->op_mds))
 		op_data->op_bias |= MDS_CREATE_VOLATILE;
-	op_data->op_mds = 0;
+	else
+		op_data->op_mds = 0;
 	op_data->op_data = data;
 
 	/* When called by ll_setattr_raw, file is i1. */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index a3d170a..715179f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -47,18 +47,20 @@
 #include "../include/lprocfs_status.h"
 #include "lmv_internal.h"
 
-int lmv_fld_lookup(struct lmv_obd *lmv,
-		   const struct lu_fid *fid,
-		   u32 *mds)
+int lmv_fld_lookup(struct lmv_obd *lmv, const struct lu_fid *fid, u32 *mds)
 {
+	struct obd_device *obd = lmv2obd_dev(lmv);
 	int rc;
 
-	/* FIXME: Currently ZFS still use local seq for ROOT unfortunately, and
+	/*
+	 * FIXME: Currently ZFS still use local seq for ROOT unfortunately, and
 	 * this fid_is_local check should be removed once LU-2240 is fixed
 	 */
-	LASSERTF((fid_seq_in_fldb(fid_seq(fid)) ||
-		  fid_seq_is_local_file(fid_seq(fid))) &&
-		 fid_is_sane(fid), DFID" is insane!\n", PFID(fid));
+	if (!fid_is_sane(fid) || !(fid_seq_in_fldb(fid_seq(fid)) ||
+				   fid_seq_is_local_file(fid_seq(fid)))) {
+		CERROR("%s: invalid FID " DFID "\n", obd->obd_name, PFID(fid));
+		return -EINVAL;
+	}
 
 	rc = fld_client_lookup(&lmv->lmv_fld, fid_seq(fid), mds,
 			       LU_SEQ_RANGE_MDT, NULL);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index c4961d9..4a5e385 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -62,6 +62,11 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags);
 
+static inline struct obd_device *lmv2obd_dev(struct lmv_obd *lmv)
+{
+	return container_of0(lmv, struct obd_device, u.lmv);
+}
+
 static inline struct lmv_tgt_desc *
 lmv_get_target(struct lmv_obd *lmv, u32 mdt_idx, int *index)
 {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 5783359..171c260 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1075,6 +1075,21 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		rc = obd_iocontrol(cmd, tgt->ltd_exp, len, karg, uarg);
 		break;
 	}
+	case LL_IOC_FID2MDTIDX: {
+		struct lu_fid *fid = karg;
+		int mdt_index;
+
+		rc = lmv_fld_lookup(lmv, fid, &mdt_index);
+		if (rc)
+			return rc;
+
+		/*
+		 * Note: this is from llite(see ll_dir_ioctl()), @uarg does not
+		 * point to user space memory for FID2MDTIDX.
+		 */
+		*(__u32 *)uarg = mdt_index;
+		break;
+	}
 	case OBD_IOC_FID2PATH: {
 		rc = lmv_fid2path(exp, len, karg, uarg);
 		break;
@@ -1673,13 +1688,44 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
  * retval		pointer to the lmv_tgt_desc if succeed.
  *			ERR_PTR(errno) if failed.
  */
-struct lmv_tgt_desc
-*lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
-		struct lu_fid *fid)
+struct lmv_tgt_desc*
+lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
+	       struct lu_fid *fid)
 {
 	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct lmv_tgt_desc *tgt;
 
+	/*
+	 * During creating VOLATILE file, it should honor the mdt
+	 * index if the file under striped dir is being restored, see
+	 * ct_restore().
+	 */
+	if (op_data->op_bias & MDS_CREATE_VOLATILE &&
+	    (int)op_data->op_mds != -1 && lsm) {
+		int i;
+
+		tgt = lmv_get_target(lmv, op_data->op_mds, NULL);
+		if (IS_ERR(tgt))
+			return tgt;
+
+		/* refill the right parent fid */
+		for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
+			struct lmv_oinfo *oinfo;
+
+			oinfo = &lsm->lsm_md_oinfo[i];
+			if (oinfo->lmo_mds == op_data->op_mds) {
+				*fid = oinfo->lmo_fid;
+				break;
+			}
+		}
+
+		/* Hmm, can not find the stripe by mdt_index(op_mds) */
+		if (i == lsm->lsm_md_stripe_count)
+			tgt = ERR_PTR(-EINVAL);
+
+		return tgt;
+	}
+
 	if (!lsm || !op_data->op_namelen) {
 		tgt = lmv_find_target(lmv, fid);
 		if (IS_ERR(tgt))
-- 
1.7.1
