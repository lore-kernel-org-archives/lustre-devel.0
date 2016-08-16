From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:26 -0400
Subject: [lustre-devel] [PATCH 13/80] staging: lustre: llite: fix
	"getdirstripe" to show stripe info
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Fix "lfs getdirstripe", so it can show layout information
of striped directory

[root at testnode tests]# ../utils/lfs getdirstripe /mnt/lustre/test1
/mnt/lustre/test1
lmv_stripe_count: 2
lmv_stripe_offset: 0
mdtidx               FID[seq:oid:ver]
     0               [0x280000400:0x1:0x0]
     1               [0x2c0000400:0x1:0x0]

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-on: http://review.whamcloud.com/7228
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    4 +
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
 drivers/staging/lustre/lustre/llite/dir.c          |  184 +++++++++++++++-----
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |    7 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   26 +++
 6 files changed, 180 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index a612080..0ff30c6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1728,6 +1728,8 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 #define OBD_MD_FLDATAVERSION (0x0010000000000000ULL) /* iversion sum */
 #define OBD_MD_FLRELEASED    (0x0020000000000000ULL) /* file released */
 
+#define OBD_MD_DEFAULT_MEA   (0x0040000000000000ULL) /* default MEA */
+
 #define OBD_MD_FLGETATTR (OBD_MD_FLID    | OBD_MD_FLATIME | OBD_MD_FLMTIME | \
 			  OBD_MD_FLCTIME | OBD_MD_FLSIZE  | OBD_MD_FLBLKSZ | \
 			  OBD_MD_FLMODE  | OBD_MD_FLTYPE  | OBD_MD_FLUID   | \
@@ -2543,6 +2545,8 @@ union lmv_mds_md {
 	struct lmv_user_md	lmv_user_md;
 };
 
+void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm);
+
 static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
 {
 	ssize_t len = -EINVAL;
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index d496d0e..26dbda0 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -242,6 +242,7 @@ struct ost_id {
 #define LL_IOC_SET_LEASE		_IOWR('f', 243, long)
 #define LL_IOC_GET_LEASE		_IO('f', 244)
 #define LL_IOC_HSM_IMPORT		_IOWR('f', 245, struct hsm_user_import)
+#define LL_IOC_LMV_SET_DEFAULT_STRIPE	_IOWR('f', 246, struct lmv_user_md)
 
 #define LL_STATFS_LMV	   1
 #define LL_STATFS_LOV	   2
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index a0560b6..5288750 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -749,6 +749,13 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 			lum_size = sizeof(struct lov_user_md_v3);
 			break;
 		}
+		case LMV_USER_MAGIC: {
+			if (lump->lmm_magic != cpu_to_le32(LMV_USER_MAGIC))
+				lustre_swab_lmv_user_md(
+					(struct lmv_user_md *)lump);
+			lum_size = sizeof(struct lmv_user_md);
+			break;
+		}
 		default: {
 			CDEBUG(D_IOCTL, "bad userland LOV MAGIC: %#08x != %#08x nor %#08x\n",
 			       lump->lmm_magic, LOV_USER_MAGIC_V1,
@@ -819,8 +826,16 @@ end:
 	return rc;
 }
 
-int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
-		     int *lmm_size, struct ptlrpc_request **request)
+/**
+ * This function will be used to get default LOV/LMV/Default LMV
+ * @valid will be used to indicate which stripe it will retrieve
+ *	OBD_MD_MEA		LMV stripe EA
+ *	OBD_MD_DEFAULT_MEA	Default LMV stripe EA
+ *	otherwise		Default LOV EA.
+ * Each time, it can only retrieve 1 stripe EA
+ **/
+int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
+		     struct ptlrpc_request **request, u64 valid)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct mdt_body   *body;
@@ -829,7 +844,7 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 	int rc, lmmsize;
 	struct md_op_data *op_data;
 
-	rc = ll_get_default_mdsize(sbi, &lmmsize);
+	rc = ll_get_max_mdsize(sbi, &lmmsize);
 	if (rc)
 		return rc;
 
@@ -860,6 +875,7 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill,
 					   &RMF_MDT_MD, lmmsize);
+	LASSERT(lmm);
 
 	/*
 	 * This is coming from the MDS, so is probably in
@@ -876,40 +892,48 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
 		break;
+	case LMV_USER_MAGIC:
+		if (cpu_to_le32(LMV_USER_MAGIC) != LMV_USER_MAGIC)
+			lustre_swab_lmv_user_md((struct lmv_user_md *)lmm);
+		break;
 	default:
 		CERROR("unknown magic: %lX\n", (unsigned long)lmm->lmm_magic);
 		rc = -EPROTO;
 	}
 out:
-	*lmmp = lmm;
-	*lmm_size = lmmsize;
+	*plmm = lmm;
+	*plmm_size = lmmsize;
 	*request = req;
 	return rc;
 }
 
-/*
- *  Get MDT index for the inode.
- */
-int ll_get_mdt_idx(struct inode *inode)
+static int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi,
+				 const struct lu_fid *fid)
 {
-	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct md_op_data *op_data;
-	int rc, mdtidx;
+	int mdt_index, rc;
 
-	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0,
-				     0, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
+	if (!op_data)
+		return -ENOMEM;
 
 	op_data->op_flags |= MF_GET_MDT_IDX;
+	op_data->op_fid1 = *fid;
 	rc = md_getattr(sbi->ll_md_exp, op_data, NULL);
-	mdtidx = op_data->op_mds;
-	ll_finish_md_op_data(op_data);
-	if (rc < 0) {
-		CDEBUG(D_INFO, "md_getattr_name: %d\n", rc);
+	mdt_index = op_data->op_mds;
+	kvfree(op_data);
+	if (rc < 0)
 		return rc;
-	}
-	return mdtidx;
+
+	return mdt_index;
+}
+
+/*
+ *  Get MDT index for the inode.
+ */
+int ll_get_mdt_idx(struct inode *inode)
+{
+	return ll_get_mdt_idx_by_fid(ll_i2sbi(inode), ll_inode2fid(inode));
 }
 
 /**
@@ -1391,6 +1415,22 @@ lmv_out_free:
 		obd_ioctl_freedata(buf, len);
 		return rc;
 	}
+	case LL_IOC_LMV_SET_DEFAULT_STRIPE: {
+		struct lmv_user_md __user *ulump;
+		struct lmv_user_md lum;
+		int rc;
+
+		ulump = (struct lmv_user_md __user *)arg;
+		if (copy_from_user(&lum, ulump, sizeof(lum)))
+			return -EFAULT;
+
+		if (lum.lum_magic != LMV_USER_MAGIC)
+			return -EINVAL;
+
+		rc = ll_dir_setstripe(inode, (struct lov_user_md *)&lum, 0);
+
+		return rc;
+	}
 	case LL_IOC_LOV_SETSTRIPE: {
 		struct lov_user_md_v3 lumv3;
 		struct lov_user_md_v1 *lumv1 = (struct lov_user_md_v1 *)&lumv3;
@@ -1420,46 +1460,107 @@ lmv_out_free:
 		return rc;
 	}
 	case LL_IOC_LMV_GETSTRIPE: {
-		struct lmv_user_md __user *lump = (void __user *)arg;
+		struct lmv_user_md __user *ulmv;
 		struct lmv_user_md lum;
-		struct lmv_user_md *tmp;
+		struct ptlrpc_request *request = NULL;
+		struct lmv_user_md *tmp = NULL;
+		union lmv_mds_md *lmm = NULL;
+		u64 valid = 0;
+		int stripe_count;
+		int mdt_index;
 		int lum_size;
-		int rc = 0;
-		int mdtindex;
+		int lmmsize;
+		int rc;
+		int i;
 
-		if (copy_from_user(&lum, lump, sizeof(struct lmv_user_md)))
+		ulmv = (struct lmv_user_md __user *)arg;
+		if (copy_from_user(&lum, ulmv, sizeof(*ulmv)))
 			return -EFAULT;
 
-		if (lum.lum_magic != LMV_MAGIC_V1)
+		/*
+		 * lum_magic will indicate which stripe the ioctl will like
+		 * to get, LMV_MAGIC_V1 is for normal LMV stripe, LMV_USER_MAGIC
+		 * is for default LMV stripe
+		 */
+		if (lum.lum_magic == LMV_MAGIC_V1)
+			valid |= OBD_MD_MEA;
+		else if (lum.lum_magic == LMV_USER_MAGIC)
+			valid |= OBD_MD_DEFAULT_MEA;
+		else
 			return -EINVAL;
 
-		lum_size = lmv_user_md_size(1, LMV_MAGIC_V1);
+		rc = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize, &request,
+				      valid);
+		if (rc && rc != -ENODATA)
+			goto finish_req;
+
+		/* Get default LMV EA */
+		if (lum.lum_magic == LMV_USER_MAGIC) {
+			if (rc)
+				goto finish_req;
+
+			if (lmmsize > sizeof(*ulmv)) {
+				rc = -EINVAL;
+				goto finish_req;
+			}
+
+			if (copy_to_user(ulmv, lmm, lmmsize))
+				rc = -EFAULT;
+
+			goto finish_req;
+		}
+
+		/* Get normal LMV EA */
+		if (rc == -ENODATA) {
+			stripe_count = 1;
+		} else {
+			LASSERT(lmm);
+			stripe_count = lmv_mds_md_stripe_count_get(lmm);
+		}
+
+		lum_size = lmv_user_md_size(stripe_count, LMV_MAGIC_V1);
 		tmp = kzalloc(lum_size, GFP_NOFS);
 		if (!tmp) {
 			rc = -ENOMEM;
-			goto free_lmv;
+			goto finish_req;
 		}
 
-		*tmp = lum;
+		tmp->lum_magic = LMV_MAGIC_V1;
 		tmp->lum_stripe_count = 1;
-		mdtindex = ll_get_mdt_idx(inode);
-		if (mdtindex < 0) {
+		mdt_index = ll_get_mdt_idx(inode);
+		if (mdt_index < 0) {
 			rc = -ENOMEM;
-			goto free_lmv;
+			goto out_tmp;
+		}
+		tmp->lum_stripe_offset = mdt_index;
+		tmp->lum_objects[0].lum_mds = mdt_index;
+		tmp->lum_objects[0].lum_fid = *ll_inode2fid(inode);
+		for (i = 1; i < stripe_count; i++) {
+			struct lmv_mds_md_v1 *lmm1;
+
+			lmm1 = &lmm->lmv_md_v1;
+			mdt_index = ll_get_mdt_idx_by_fid(sbi,
+							  &lmm1->lmv_stripe_fids[i]);
+			if (mdt_index < 0) {
+				rc = mdt_index;
+				goto out_tmp;
+			}
+			tmp->lum_objects[i].lum_mds = mdt_index;
+			tmp->lum_objects[i].lum_fid = lmm1->lmv_stripe_fids[i];
+			tmp->lum_stripe_count++;
 		}
 
-		tmp->lum_stripe_offset = mdtindex;
-		tmp->lum_objects[0].lum_mds = mdtindex;
-		memcpy(&tmp->lum_objects[0].lum_fid, ll_inode2fid(inode),
-		       sizeof(struct lu_fid));
-		if (copy_to_user((void __user *)arg, tmp, lum_size)) {
+		if (copy_to_user(ulmv, tmp, lum_size)) {
 			rc = -EFAULT;
-			goto free_lmv;
+			goto out_tmp;
 		}
-free_lmv:
+out_tmp:
 		kfree(tmp);
+finish_req:
+		ptlrpc_req_finished(request);
 		return rc;
 	}
+
 	case LL_IOC_LOV_SWAP_LAYOUTS:
 		return -EPERM;
 	case LL_IOC_OBD_STATFS:
@@ -1484,7 +1585,8 @@ free_lmv:
 			rc = ll_lov_getstripe_ea_info(inode, filename, &lmm,
 						      &lmmsize, &request);
 		} else {
-			rc = ll_dir_getstripe(inode, &lmm, &lmmsize, &request);
+			rc = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize,
+					      &request, 0);
 		}
 
 		if (request) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f3b8504..82c3a88 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -728,8 +728,8 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct ptlrpc_request **request);
 int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		     int set_default);
-int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
-		     int *lmm_size, struct ptlrpc_request **request);
+int ll_dir_getstripe(struct inode *inode, void **lmmp, int *lmm_size,
+		     struct ptlrpc_request **request, u64 valid);
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
 int ll_merge_attr(const struct lu_env *env, struct inode *inode);
 int ll_fid2path(struct inode *inode, void __user *arg);
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index a02b802..aa0738b 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -390,8 +390,8 @@ static int ll_xattr_get(const struct xattr_handler *handler,
 		lsm = ccc_inode_lsm_get(inode);
 		if (!lsm) {
 			if (S_ISDIR(inode->i_mode)) {
-				rc = ll_dir_getstripe(inode, &lmm,
-						      &lmmsize, &request);
+				rc = ll_dir_getstripe(inode, (void **)&lmm,
+						      &lmmsize, &request, 0);
 			} else {
 				rc = -ENODATA;
 			}
@@ -491,7 +491,8 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 		if (!ll_i2info(inode)->lli_has_smd)
 			rc2 = -1;
 	} else if (S_ISDIR(inode->i_mode)) {
-		rc2 = ll_dir_getstripe(inode, &lmm, &lmmsize, &request);
+		rc2 = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize,
+				       &request, 0);
 	}
 
 	if (rc2 < 0) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 07e23d1..6ddc9c7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1878,6 +1878,32 @@ void lustre_swab_lov_desc(struct lov_desc *ld)
 }
 EXPORT_SYMBOL(lustre_swab_lov_desc);
 
+/* This structure is always in little-endian */
+static void lustre_swab_lmv_mds_md_v1(struct lmv_mds_md_v1 *lmm1)
+{
+	int i;
+
+	__swab32s(&lmm1->lmv_magic);
+	__swab32s(&lmm1->lmv_stripe_count);
+	__swab32s(&lmm1->lmv_master_mdt_index);
+	__swab32s(&lmm1->lmv_hash_type);
+	__swab32s(&lmm1->lmv_layout_version);
+	for (i = 0; i < lmm1->lmv_stripe_count; i++)
+		lustre_swab_lu_fid(&lmm1->lmv_stripe_fids[i]);
+}
+
+void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm)
+{
+	switch (lmm->lmv_magic) {
+	case LMV_MAGIC_V1:
+		lustre_swab_lmv_mds_md_v1(&lmm->lmv_md_v1);
+		break;
+	default:
+		break;
+	}
+}
+EXPORT_SYMBOL(lustre_swab_lmv_mds_md);
+
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 {
 	__swab32s(&lum->lum_magic);
-- 
1.7.1
