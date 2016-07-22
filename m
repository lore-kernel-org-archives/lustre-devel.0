From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:28 -0400
Subject: [lustre-devel] [PATCH 35/58] staging: lustre: add ability to
	migrate inodes.
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-36-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Add client support to migrate the individual inodes
from one MDT to another MDT, and this functionality
will only migrate inode layout on MDT but not touch
data object on OST.

The directory will be migrated from top to the bottom,
i.e. migrating parent first, then migrating the child.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2430
Reviewed-on: http://review.whamcloud.com/6662
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   11 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 +
 drivers/staging/lustre/lustre/include/lustre_lmv.h |    2 +
 drivers/staging/lustre/lustre/include/obd.h        |   12 +--
 drivers/staging/lustre/lustre/llite/dir.c          |   43 +++++-
 drivers/staging/lustre/lustre/llite/file.c         |  113 ++++++++++++-
 .../staging/lustre/lustre/llite/llite_internal.h   |   14 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   33 ++++-
 drivers/staging/lustre/lustre/llite/namei.c        |    3 +-
 drivers/staging/lustre/lustre/llite/rw.c           |    4 +
 drivers/staging/lustre/lustre/llite/statahead.c    |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   32 +++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  176 ++++++++++++++------
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    2 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    4 +-
 15 files changed, 368 insertions(+), 83 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0ff30c6..6853f62 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1482,6 +1482,7 @@ enum obdo_flags {
 #define LOV_MAGIC	 LOV_MAGIC_V1
 #define LOV_MAGIC_JOIN_V1 0x0BD20BD0
 #define LOV_MAGIC_V3      0x0BD30BD0
+#define LOV_MAGIC_MIGRATE 0x0BD40BD0
 
 /*
  * magic for fully defined striping
@@ -1987,7 +1988,7 @@ enum mdt_reint_cmd {
 	REINT_OPEN     = 6,
 	REINT_SETXATTR = 7,
 	REINT_RMENTRY  = 8,
-/*      REINT_WRITE    = 9, */
+	REINT_MIGRATE  = 9,
 	REINT_MAX
 };
 
@@ -2280,6 +2281,7 @@ enum mds_op_bias {
 	MDS_CREATE_VOLATILE	= 1 << 10,
 	MDS_OWNEROVERRIDE	= 1 << 11,
 	MDS_HSM_RELEASE		= 1 << 12,
+	MDS_RENAME_MIGRATE	= BIT(13),
 };
 
 /* instance of mdt_reint_rec */
@@ -2488,11 +2490,13 @@ struct lmv_desc {
 /* lmv structures */
 #define LMV_MAGIC_V1	0x0CD10CD0	/* normal stripe lmv magic */
 #define LMV_USER_MAGIC	0x0CD20CD0	/* default lmv magic*/
+#define LMV_MAGIC_MIGRATE	0x0CD30CD0	/* migrate stripe lmv magic */
 #define LMV_MAGIC	LMV_MAGIC_V1
 
 enum lmv_hash_type {
 	LMV_HASH_TYPE_ALL_CHARS = 1,
 	LMV_HASH_TYPE_FNV_1A_64 = 2,
+	LMV_HASH_TYPE_MIGRATION = 3,
 };
 
 #define LMV_HASH_NAME_ALL_CHARS		"all_char"
@@ -2552,7 +2556,8 @@ static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
 	ssize_t len = -EINVAL;
 
 	switch (lmm_magic) {
-	case LMV_MAGIC_V1: {
+	case LMV_MAGIC_V1:
+	case LMV_MAGIC_MIGRATE: {
 		struct lmv_mds_md_v1 *lmm1;
 
 		len = sizeof(*lmm1);
@@ -2568,6 +2573,7 @@ static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
 {
 	switch (le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
+	case LMV_MAGIC_MIGRATE:
 		return le32_to_cpu(lmm->lmv_md_v1.lmv_stripe_count);
 	case LMV_USER_MAGIC:
 		return le32_to_cpu(lmm->lmv_user_md.lum_stripe_count);
@@ -2583,6 +2589,7 @@ static inline int lmv_mds_md_stripe_count_set(union lmv_mds_md *lmm,
 
 	switch (le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
+	case LMV_MAGIC_MIGRATE:
 		lmm->lmv_md_v1.lmv_stripe_count = cpu_to_le32(stripe_count);
 		break;
 	case LMV_USER_MAGIC:
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 26dbda0..4746320 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -243,6 +243,7 @@ struct ost_id {
 #define LL_IOC_GET_LEASE		_IO('f', 244)
 #define LL_IOC_HSM_IMPORT		_IOWR('f', 245, struct hsm_user_import)
 #define LL_IOC_LMV_SET_DEFAULT_STRIPE	_IOWR('f', 246, struct lmv_user_md)
+#define LL_IOC_MIGRATE			_IOR('f', 247, int)
 
 #define LL_STATFS_LMV	   1
 #define LL_STATFS_LOV	   2
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 4036fce..feee981 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -106,6 +106,7 @@ static inline void lmv_cpu_to_le(union lmv_mds_md *lmv_dst,
 {
 	switch (lmv_src->lmv_magic) {
 	case LMV_MAGIC_V1:
+	case LMV_MAGIC_MIGRATE:
 		lmv1_cpu_to_le(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
 		break;
 	default:
@@ -118,6 +119,7 @@ static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
 {
 	switch (le32_to_cpu(lmv_src->lmv_magic)) {
 	case LMV_MAGIC_V1:
+	case LMV_MAGIC_MIGRATE:
 		lmv1_le_to_cpu(&lmv_dst->lmv_md_v1, &lmv_src->lmv_md_v1);
 		break;
 	default:
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index a9f4e13..f5eeb05 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -847,9 +847,6 @@ struct md_op_data {
 	/* Various operation flags. */
 	enum mds_op_bias        op_bias;
 
-	/* Operation type */
-	__u32		   op_opc;
-
 	/* Used by readdir */
 	__u64		   op_offset;
 
@@ -871,6 +868,7 @@ enum op_cli_flags {
 	CLI_RM_ENTRY	= 1 << 1,
 	CLI_HASH64	= BIT(2),
 	CLI_API32	= BIT(3),
+	CLI_MIGRATE	= BIT(4),
 };
 
 struct md_enqueue_info;
@@ -1013,14 +1011,6 @@ struct obd_ops {
 	 */
 };
 
-enum {
-	LUSTRE_OPC_MKDIR    = (1 << 0),
-	LUSTRE_OPC_SYMLINK  = (1 << 1),
-	LUSTRE_OPC_MKNOD    = (1 << 2),
-	LUSTRE_OPC_CREATE   = (1 << 3),
-	LUSTRE_OPC_ANY      = (1 << 4)
-};
-
 /* lmv structures */
 struct lustre_md {
 	struct mdt_body	 *body;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 96ae7d5..ef7322e 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -883,6 +883,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
 		break;
 	case LMV_USER_MAGIC:
+	case LMV_MAGIC_MIGRATE:
 		if (cpu_to_le32(LMV_USER_MAGIC) != LMV_USER_MAGIC)
 			lustre_swab_lmv_user_md((struct lmv_user_md *)lmm);
 		break;
@@ -897,8 +898,7 @@ out:
 	return rc;
 }
 
-static int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi,
-				 const struct lu_fid *fid)
+int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid)
 {
 	struct md_op_data *op_data;
 	int mdt_index, rc;
@@ -1960,6 +1960,45 @@ out_quotactl:
 		kfree(copy);
 		return rc;
 	}
+	case LL_IOC_MIGRATE: {
+		char *buf = NULL;
+		const char *filename;
+		int namelen = 0;
+		int len;
+		int rc;
+		int mdtidx;
+
+		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
+		if (rc < 0)
+			return rc;
+
+		data = (struct obd_ioctl_data *)buf;
+		if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
+		    !data->ioc_inllen1 || !data->ioc_inllen2) {
+			rc = -EINVAL;
+			goto migrate_free;
+		}
+
+		filename = data->ioc_inlbuf1;
+		namelen = data->ioc_inllen1;
+		if (namelen < 1) {
+			rc = -EINVAL;
+			goto migrate_free;
+		}
+
+		if (data->ioc_inllen2 != sizeof(mdtidx)) {
+			rc = -EINVAL;
+			goto migrate_free;
+		}
+		mdtidx = *(int *)data->ioc_inlbuf2;
+
+		rc = ll_migrate(inode, file, mdtidx, filename, namelen);
+migrate_free:
+		obd_ioctl_freedata(buf, len);
+
+		return rc;
+	}
+
 	default:
 		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL,
 				     (void __user *)arg);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 18fb713..391748c 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -364,7 +364,8 @@ int ll_file_release(struct inode *inode, struct file *file)
 	}
 
 	if (!S_ISDIR(inode->i_mode)) {
-		lov_read_and_clear_async_rc(lli->lli_clob);
+		if (lli->lli_clob)
+			lov_read_and_clear_async_rc(lli->lli_clob);
 		lli->lli_async_rc = 0;
 	}
 
@@ -2593,9 +2594,11 @@ static int ll_flush(struct file *file, fl_owner_t id)
 	 */
 	rc = lli->lli_async_rc;
 	lli->lli_async_rc = 0;
-	err = lov_read_and_clear_async_rc(lli->lli_clob);
-	if (rc == 0)
-		rc = err;
+	if (lli->lli_clob) {
+		err = lov_read_and_clear_async_rc(lli->lli_clob);
+		if (!rc)
+			rc = err;
+	}
 
 	/* The application has been told about write failure already.
 	 * Do not report failure again.
@@ -2825,6 +2828,108 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	return rc;
 }
 
+static int ll_get_fid_by_name(struct inode *parent, const char *name,
+			      int namelen, struct lu_fid *fid)
+{
+	struct md_op_data *op_data = NULL;
+	struct ptlrpc_request *req;
+	struct mdt_body *body;
+	int rc;
+
+	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	op_data->op_valid = OBD_MD_FLID;
+	rc = md_getattr_name(ll_i2sbi(parent)->ll_md_exp, op_data, &req);
+	if (rc < 0)
+		goto out_free;
+
+	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	if (!body) {
+		rc = -EFAULT;
+		goto out_req;
+	}
+	*fid = body->fid1;
+out_req:
+	ptlrpc_req_finished(req);
+out_free:
+	if (op_data)
+		ll_finish_md_op_data(op_data);
+	return rc;
+}
+
+int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
+	       const char *name, int namelen)
+{
+	struct ptlrpc_request *request = NULL;
+	struct dentry *dchild = NULL;
+	struct md_op_data *op_data;
+	struct qstr qstr;
+	int rc;
+
+	CDEBUG(D_VFSTRACE, "migrate %s under"DFID" to MDT%d\n",
+	       name, PFID(ll_inode2fid(parent)), mdtidx);
+
+	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
+				     0, LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	/* Get child FID first */
+	qstr.hash = full_name_hash(name, namelen);
+	qstr.name = name;
+	qstr.len = namelen;
+	dchild = d_lookup(file_dentry(file), &qstr);
+	if (dchild && dchild->d_inode) {
+		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
+	} else {
+		rc = ll_get_fid_by_name(parent, name, strnlen(name, namelen),
+					&op_data->op_fid3);
+		if (rc)
+			goto out_free;
+	}
+
+	if (!fid_is_sane(&op_data->op_fid3)) {
+		CERROR("%s: migrate %s, but fid "DFID" is insane\n",
+		       ll_get_fsname(parent->i_sb, NULL, 0), name,
+		       PFID(&op_data->op_fid3));
+		goto out_free;
+	}
+
+	rc = ll_get_mdt_idx_by_fid(ll_i2sbi(parent), &op_data->op_fid3);
+	if (rc < 0)
+		goto out_free;
+
+	if (rc == mdtidx) {
+		CDEBUG(D_INFO, "%s:"DFID" is already on MDT%d.\n", name,
+		       PFID(&op_data->op_fid3), mdtidx);
+		rc = 0;
+		goto out_free;
+	}
+
+	op_data->op_mds = mdtidx;
+	op_data->op_cli_flags = CLI_MIGRATE;
+	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data, name,
+		       strnlen(name, namelen), name, strnlen(name, namelen),
+		       &request);
+	if (!rc)
+		ll_update_times(request, parent);
+
+	ptlrpc_req_finished(request);
+
+out_free:
+	if (dchild) {
+		if (dchild->d_inode)
+			ll_delete_inode(dchild->d_inode);
+		dput(dchild);
+	}
+
+	ll_finish_md_op_data(op_data);
+	return rc;
+}
+
 static int
 ll_file_noflock(struct file *file, int cmd, struct file_lock *file_lock)
 {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 82c3a88..69492f0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -660,6 +660,7 @@ extern const struct inode_operations ll_dir_inode_operations;
 int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx);
 int ll_get_mdt_idx(struct inode *inode);
+int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid);
 struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 			     __u64 hash, struct ll_dir_chain *chain);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
@@ -675,6 +676,7 @@ int ll_test_inode_by_fid(struct inode *inode, void *opaque);
 int ll_md_blocking_ast(struct ldlm_lock *, struct ldlm_lock_desc *,
 		       void *data, int flag);
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de);
+void ll_update_times(struct ptlrpc_request *request, struct inode *inode);
 
 /* llite/rw.c */
 int ll_writepage(struct page *page, struct writeback_control *wbc);
@@ -717,7 +719,8 @@ void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
 			  struct lustre_handle *fh);
 int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat);
 struct posix_acl *ll_get_acl(struct inode *inode, int type);
-
+int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
+	       const char *name, int namelen);
 int ll_inode_permission(struct inode *inode, int mask);
 
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
@@ -777,6 +780,15 @@ int ll_obd_statfs(struct inode *inode, void __user *arg);
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
 int ll_process_config(struct lustre_cfg *lcfg);
+
+enum {
+	LUSTRE_OPC_MKDIR	= 0,
+	LUSTRE_OPC_SYMLINK	= 1,
+	LUSTRE_OPC_MKNOD	= 2,
+	LUSTRE_OPC_CREATE	= 3,
+	LUSTRE_OPC_ANY		= 5,
+};
+
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, int namelen,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ef8d87a..e320400 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1114,8 +1114,34 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	struct lmv_stripe_md *lsm = md->lmv;
 	int idx;
 
-	LASSERT(lsm);
 	LASSERT(S_ISDIR(inode->i_mode));
+	CDEBUG(D_INODE, "update lsm %p of "DFID"\n", lli->lli_lsm_md,
+	       PFID(ll_inode2fid(inode)));
+
+	/* no striped information from request. */
+	if (!lsm) {
+		if (!lli->lli_lsm_md) {
+			return;
+		} else if (lli->lli_lsm_md->lsm_md_magic == LMV_MAGIC_MIGRATE) {
+			/*
+			 * migration is done, the temporay MIGRATE layout has
+			 * been removed
+			 */
+			CDEBUG(D_INODE, DFID" finish migration.\n",
+			       PFID(ll_inode2fid(inode)));
+			lmv_free_memmd(lli->lli_lsm_md);
+			lli->lli_lsm_md = NULL;
+			return;
+		} else {
+			/*
+			 * The lustre_md from req does not include stripeEA,
+			 * see ll_md_setattr
+			 */
+			return;
+		}
+	}
+
+	/* set the directory layout */
 	if (!lli->lli_lsm_md) {
 		int rc;
 
@@ -1132,6 +1158,8 @@ static void ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 		 * will not free this lsm
 		 */
 		md->lmv = NULL;
+		CDEBUG(D_INODE, "Set lsm %p magic %x to "DFID"\n", lsm,
+		       lsm->lsm_md_magic, PFID(ll_inode2fid(inode)));
 		return;
 	}
 
@@ -1668,7 +1696,7 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 			lli->lli_maxbytes = MAX_LFS_FILESIZE;
 	}
 
-	if (S_ISDIR(inode->i_mode) && md->lmv)
+	if (S_ISDIR(inode->i_mode))
 		ll_update_lsm_md(inode, md);
 
 #ifdef CONFIG_FS_POSIX_ACL
@@ -2306,7 +2334,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	if ((opc == LUSTRE_OPC_CREATE) && name &&
 	    filename_is_volatile(name, namelen, NULL))
 		op_data->op_bias |= MDS_CREATE_VOLATILE;
-	op_data->op_opc = opc;
 	op_data->op_mds = 0;
 	op_data->op_data = data;
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 1d28714..41591dd 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -757,8 +757,7 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry, int mode,
 	return 0;
 }
 
-static void ll_update_times(struct ptlrpc_request *request,
-			    struct inode *inode)
+void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
 {
 	struct mdt_body *body = req_capsule_server_get(&request->rq_pill,
 						       &RMF_MDT_BODY);
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 87393c4..01aee84 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -1015,6 +1015,10 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 		 * is called later on.
 		 */
 		ignore_layout = 1;
+
+	if (!ll_i2info(inode)->lli_clob)
+		return 0;
+
 	result = cl_sync_file_range(inode, start, end, mode, ignore_layout);
 	if (result > 0) {
 		wbc->nr_to_write -= result;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 7b23497..0a28599 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1605,6 +1605,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 					       *dentryp,
 					       PFID(ll_inode2fid(d_inode(*dentryp))),
 					       PFID(ll_inode2fid(inode)));
+					ll_intent_release(&it);
 					ll_sai_unplug(sai, entry);
 					return -ESTALE;
 				} else {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 5313dfc..2bc1098 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -43,6 +43,7 @@
 #include "../include/lustre_lib.h"
 #include "../include/lustre_net.h"
 #include "../include/lustre_dlm.h"
+#include "../include/lustre_mdc.h"
 #include "../include/obd_class.h"
 #include "../include/lprocfs_status.h"
 #include "lmv_internal.h"
@@ -332,6 +333,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 
 			oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
 							op_data->op_namelen);
+			if (IS_ERR(oinfo))
+				return PTR_ERR(oinfo);
 			op_data->op_fid1 = oinfo->lmo_fid;
 		}
 
@@ -408,6 +411,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 			     ldlm_blocking_callback cb_blocking,
 			     __u64 extra_lock_flags)
 {
+	struct lmv_stripe_md *lsm = op_data->op_mea1;
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc    *tgt = NULL;
@@ -421,17 +425,15 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	if (!fid_is_sane(&op_data->op_fid2))
 		fid_zero(&op_data->op_fid2);
 
-	CDEBUG(D_INODE, "LOOKUP_INTENT with fid1="DFID", fid2="DFID
-	       ", name='%s' -> mds #%d\n", PFID(&op_data->op_fid1),
-	       PFID(&op_data->op_fid2),
+	CDEBUG(D_INODE, "LOOKUP_INTENT with fid1="DFID", fid2="DFID", name='%s' -> mds #%d lsm=%p lsm_magic=%x\n",
+	       PFID(&op_data->op_fid1), PFID(&op_data->op_fid2),
 	       op_data->op_name ? op_data->op_name : "<NULL>",
-	       tgt->ltd_idx);
+	       tgt->ltd_idx, lsm, !lsm ? -1 : lsm->lsm_md_magic);
 
 	op_data->op_bias &= ~MDS_CROSS_REF;
 
 	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
 			    flags, reqp, cb_blocking, extra_lock_flags);
-
 	if (rc < 0)
 		return rc;
 
@@ -448,6 +450,26 @@ static int lmv_intent_lookup(struct obd_export *exp,
 				return rc;
 		}
 		return rc;
+	} else if (it_disposition(it, DISP_LOOKUP_NEG) && lsm &&
+		   lsm->lsm_md_magic == LMV_MAGIC_MIGRATE) {
+		/*
+		 * For migrating directory, if it can not find the child in
+		 * the source directory(master stripe), try the targeting
+		 * directory(stripe 1)
+		 */
+		tgt = lmv_find_target(lmv, &lsm->lsm_md_oinfo[1].lmo_fid);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		ptlrpc_req_finished(*reqp);
+		CDEBUG(D_INODE, "For migrating dir, try target dir "DFID"\n",
+		       PFID(&lsm->lsm_md_oinfo[1].lmo_fid));
+
+		op_data->op_fid1 = lsm->lsm_md_oinfo[1].lmo_fid;
+		it->it_disposition &= ~DISP_ENQ_COMPLETE;
+		rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
+				    flags, reqp, cb_blocking, extra_lock_flags);
+		return rc;
 	}
 
 	/*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 4995735..e51ea1f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -98,6 +98,15 @@ int lmv_name_to_stripe_index(enum lmv_hash_type hashtype,
 	case LMV_HASH_TYPE_FNV_1A_64:
 		idx = lmv_hash_fnv1a(max_mdt_index, name, namelen);
 		break;
+	/*
+	 * LMV_HASH_TYPE_MIGRATION means the file is being migrated,
+	 * and the file should be accessed by client, except for
+	 * lookup(see lmv_intent_lookup), return -EACCES here
+	 */
+	case LMV_HASH_TYPE_MIGRATION:
+		CERROR("%.*s is being migrated: rc = %d\n", namelen,
+		       name, -EACCES);
+		return -EACCES;
 	default:
 		CERROR("Unknown hash type 0x%x\n", hashtype);
 		return -EINVAL;
@@ -1669,6 +1678,9 @@ lmv_locate_target_for_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 	struct lmv_tgt_desc *tgt;
 
 	oinfo = lsm_name_to_stripe_info(lsm, name, namelen);
+	if (IS_ERR(oinfo))
+		return ERR_CAST(oinfo);
+
 	*fid = oinfo->lmo_fid;
 	*mds = oinfo->lmo_mds;
 	tgt = lmv_get_target(lmv, *mds);
@@ -1685,7 +1697,8 @@ struct lmv_tgt_desc
 	struct lmv_tgt_desc *tgt;
 
 	if (!lsm || lsm->lsm_md_stripe_count <= 1 ||
-	    !op_data->op_namelen) {
+	    !op_data->op_namelen ||
+	    lsm->lsm_md_magic == LMV_MAGIC_MIGRATE) {
 		tgt = lmv_find_target(lmv, fid);
 		if (IS_ERR(tgt))
 			return tgt;
@@ -1931,23 +1944,24 @@ lmv_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 	 fl == MF_MDC_CANCEL_FID4 ? &op_data->op_fid4 : \
 	 NULL)
 
-static int lmv_early_cancel(struct obd_export *exp, struct md_op_data *op_data,
-			    int op_tgt, enum ldlm_mode mode, int bits,
-			    int flag)
+static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
+			    struct md_op_data *op_data, int op_tgt,
+			    enum ldlm_mode mode, int bits, int flag)
 {
 	struct lu_fid	  *fid = md_op_data_fid(op_data, flag);
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc    *tgt;
 	ldlm_policy_data_t      policy = { {0} };
 	int		     rc = 0;
 
 	if (!fid_is_sane(fid))
 		return 0;
 
-	tgt = lmv_find_target(lmv, fid);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+	if (!tgt) {
+		tgt = lmv_find_target(lmv, fid);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+	}
 
 	if (tgt->ltd_idx != op_tgt) {
 		CDEBUG(D_INODE, "EARLY_CANCEL on "DFID"\n", PFID(fid));
@@ -1996,6 +2010,9 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 
 		oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
 						op_data->op_namelen);
+		if (IS_ERR(oinfo))
+			return PTR_ERR(oinfo);
+
 		op_data->op_fid2 = oinfo->lmo_fid;
 	}
 
@@ -2007,7 +2024,7 @@ static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 	 * Cancel UPDATE lock on child (fid1).
 	 */
 	op_data->op_flags |= MF_MDC_CANCEL_FID2;
-	rc = lmv_early_cancel(exp, op_data, tgt->ltd_idx, LCK_EX,
+	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_idx, LCK_EX,
 			      MDS_INODELOCK_UPDATE, MF_MDC_CANCEL_FID1);
 	if (rc != 0)
 		return rc;
@@ -2042,31 +2059,44 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_fsgid = from_kgid(&init_user_ns, current_fsgid());
 	op_data->op_cap = cfs_curproc_cap_pack();
 
-	if (op_data->op_mea1) {
-		struct lmv_stripe_md *lsm = op_data->op_mea1;
-		const struct lmv_oinfo *oinfo;
-
-		oinfo = lsm_name_to_stripe_info(lsm, old, oldlen);
-		op_data->op_fid1 = oinfo->lmo_fid;
-		op_data->op_mds = oinfo->lmo_mds;
-		src_tgt = lmv_get_target(lmv, op_data->op_mds);
-		if (IS_ERR(src_tgt))
-			return PTR_ERR(src_tgt);
+	if (op_data->op_cli_flags & CLI_MIGRATE) {
+		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID "DFID"\n",
+			 PFID(&op_data->op_fid3));
+		rc = lmv_fid_alloc(exp, &op_data->op_fid2, op_data);
+		if (rc)
+			return rc;
+		src_tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid3);
 	} else {
-		src_tgt = lmv_find_target(lmv, &op_data->op_fid1);
-		if (IS_ERR(src_tgt))
-			return PTR_ERR(src_tgt);
+		if (op_data->op_mea1) {
+			struct lmv_stripe_md *lsm = op_data->op_mea1;
+
+			src_tgt = lmv_locate_target_for_name(lmv, lsm, old,
+							     oldlen,
+							     &op_data->op_fid1,
+							     &op_data->op_mds);
+			if (IS_ERR(src_tgt))
+				return PTR_ERR(src_tgt);
+		} else {
+			src_tgt = lmv_find_target(lmv, &op_data->op_fid1);
+			if (IS_ERR(src_tgt))
+				return PTR_ERR(src_tgt);
 
-		op_data->op_mds = src_tgt->ltd_idx;
-	}
+			op_data->op_mds = src_tgt->ltd_idx;
+		}
 
-	if (op_data->op_mea2) {
-		struct lmv_stripe_md *lsm = op_data->op_mea2;
-		const struct lmv_oinfo *oinfo;
+		if (op_data->op_mea2) {
+			struct lmv_stripe_md *lsm = op_data->op_mea2;
+			const struct lmv_oinfo *oinfo;
 
-		oinfo = lsm_name_to_stripe_info(lsm, new, newlen);
-		op_data->op_fid2 = oinfo->lmo_fid;
+			oinfo = lsm_name_to_stripe_info(lsm, new, newlen);
+			if (IS_ERR(oinfo))
+				return PTR_ERR(oinfo);
+
+			op_data->op_fid2 = oinfo->lmo_fid;
+		}
 	}
+	if (IS_ERR(src_tgt))
+		return PTR_ERR(src_tgt);
 
 	/*
 	 * LOOKUP lock on src child (fid3) should also be cancelled for
@@ -2078,33 +2108,48 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	 * Cancel UPDATE locks on tgt parent (fid2), tgt_tgt is its
 	 * own target.
 	 */
-	rc = lmv_early_cancel(exp, op_data, src_tgt->ltd_idx,
+	rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
 			      LCK_EX, MDS_INODELOCK_UPDATE,
 			      MF_MDC_CANCEL_FID2);
-
+	if (rc)
+		return rc;
 	/*
-	 * Cancel LOOKUP locks on tgt child (fid4) for parent tgt_tgt.
+	 * Cancel LOOKUP locks on source child (fid3) for parent tgt_tgt.
 	 */
-	if (rc == 0) {
-		rc = lmv_early_cancel(exp, op_data, src_tgt->ltd_idx,
+	if (fid_is_sane(&op_data->op_fid3)) {
+		struct lmv_tgt_desc *tgt;
+
+		tgt = lmv_find_target(lmv, &op_data->op_fid1);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		/* Cancel LOOKUP lock on its parent */
+		rc = lmv_early_cancel(exp, tgt, op_data, src_tgt->ltd_idx,
 				      LCK_EX, MDS_INODELOCK_LOOKUP,
-				      MF_MDC_CANCEL_FID4);
+				      MF_MDC_CANCEL_FID3);
+		if (rc)
+			return rc;
+
+		rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
+				      LCK_EX, MDS_INODELOCK_FULL,
+				      MF_MDC_CANCEL_FID3);
+		if (rc)
+			return rc;
 	}
 
 	/*
 	 * Cancel all the locks on tgt child (fid4).
 	 */
-	if (rc == 0)
-		rc = lmv_early_cancel(exp, op_data, src_tgt->ltd_idx,
+	if (fid_is_sane(&op_data->op_fid4))
+		rc = lmv_early_cancel(exp, NULL, op_data, src_tgt->ltd_idx,
 				      LCK_EX, MDS_INODELOCK_FULL,
 				      MF_MDC_CANCEL_FID4);
 
 	CDEBUG(D_INODE, DFID":m%d to "DFID"\n", PFID(&op_data->op_fid1),
 	       op_data->op_mds, PFID(&op_data->op_fid2));
 
-	if (rc == 0)
-		rc = md_rename(src_tgt->ltd_exp, op_data, old, oldlen,
-			       new, newlen, request);
+	rc = md_rename(src_tgt->ltd_exp, op_data, old, oldlen,
+		       new, newlen, request);
 	return rc;
 }
 
@@ -2306,6 +2351,7 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *parent_tgt = NULL;
 	struct lmv_tgt_desc     *tgt = NULL;
 	struct mdt_body		*body;
 	int		     rc;
@@ -2323,12 +2369,16 @@ retry:
 		/* For striped dir, we need to locate the parent as well */
 		if (op_data->op_mea1 &&
 		    op_data->op_mea1->lsm_md_stripe_count > 1) {
+			struct lmv_tgt_desc *tmp;
+
 			LASSERT(op_data->op_name && op_data->op_namelen);
-			lmv_locate_target_for_name(lmv, op_data->op_mea1,
-						   op_data->op_name,
-						   op_data->op_namelen,
-						   &op_data->op_fid1,
-						   &op_data->op_mds);
+			tmp = lmv_locate_target_for_name(lmv, op_data->op_mea1,
+							 op_data->op_name,
+							 op_data->op_namelen,
+							 &op_data->op_fid1,
+							 &op_data->op_mds);
+			if (IS_ERR(tmp))
+				return PTR_ERR(tmp);
 		}
 	} else {
 		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
@@ -2352,9 +2402,18 @@ retry:
 	/*
 	 * Cancel FULL locks on child (fid3).
 	 */
-	rc = lmv_early_cancel(exp, op_data, tgt->ltd_idx, LCK_EX,
-			      MDS_INODELOCK_FULL, MF_MDC_CANCEL_FID3);
+	parent_tgt = lmv_find_target(lmv, &op_data->op_fid1);
+	if (IS_ERR(parent_tgt))
+		return PTR_ERR(parent_tgt);
+
+	if (parent_tgt != tgt) {
+		rc = lmv_early_cancel(exp, parent_tgt, op_data, tgt->ltd_idx,
+				      LCK_EX, MDS_INODELOCK_LOOKUP,
+				      MF_MDC_CANCEL_FID3);
+	}
 
+	rc = lmv_early_cancel(exp, NULL, op_data, tgt->ltd_idx, LCK_EX,
+			      MDS_INODELOCK_FULL, MF_MDC_CANCEL_FID3);
 	if (rc != 0)
 		return rc;
 
@@ -2683,13 +2742,25 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 	}
 
 	/* Unpack memmd */
-	if (le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_V1) {
-		CERROR("%s: invalid magic %x.\n", exp->exp_obd->obd_name,
-		       le32_to_cpu(lmm->lmv_magic));
-		return -EINVAL;
+	if (le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_V1 &&
+	    le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_MIGRATE &&
+	    le32_to_cpu(lmm->lmv_magic) != LMV_USER_MAGIC) {
+		CERROR("%s: invalid lmv magic %x: rc = %d\n",
+		       exp->exp_obd->obd_name, le32_to_cpu(lmm->lmv_magic),
+		       -EIO);
+		return -EIO;
 	}
 
-	lsm_size = lmv_stripe_md_size(lmv_mds_md_stripe_count_get(lmm));
+	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_V1 ||
+	    le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_MIGRATE)
+		lsm_size = lmv_stripe_md_size(lmv_mds_md_stripe_count_get(lmm));
+	else
+		/**
+		 * Unpack default dirstripe(lmv_user_md) to lmv_stripe_md,
+		 * stripecount should be 0 then.
+		 */
+		lsm_size = lmv_stripe_md_size(0);
+
 	if (!lsm) {
 		lsm = libcfs_kvzalloc(lsm_size, GFP_NOFS);
 		if (!lsm)
@@ -2700,6 +2771,7 @@ int lmv_unpack_md(struct obd_export *exp, struct lmv_stripe_md **lsmp,
 
 	switch (le32_to_cpu(lmm->lmv_magic)) {
 	case LMV_MAGIC_V1:
+	case LMV_MAGIC_MIGRATE:
 		rc = lmv_unpack_md_v1(exp, lsm, &lmm->lmv_md_v1);
 		break;
 	default:
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 143bd76..95c4550 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -390,6 +390,8 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
+	rec->rn_opcode	 = op_data->op_cli_flags & CLI_MIGRATE ?
+				REINT_MIGRATE : REINT_RENAME;
 	rec->rn_opcode   = REINT_RENAME;
 	rec->rn_fsuid    = op_data->op_fsuid;
 	rec->rn_fsgid    = op_data->op_fsgid;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 4c500a9..bc27f8d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -190,7 +190,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)REINT_SETXATTR);
 	LASSERTF(REINT_RMENTRY == 8, "found %lld\n",
 		 (long long)REINT_RMENTRY);
-	LASSERTF(REINT_MAX == 9, "found %lld\n",
+	LASSERTF(REINT_MIGRATE == 9, "found %lld\n",
+		 (long long)REINT_MIGRATE);
+	LASSERTF(REINT_MAX == 10, "found %lld\n",
 		 (long long)REINT_MAX);
 	LASSERTF(DISP_IT_EXECD == 0x00000001UL, "found 0x%.8xUL\n",
 		(unsigned)DISP_IT_EXECD);
-- 
1.7.1
