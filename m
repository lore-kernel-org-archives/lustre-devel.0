From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:00 -0500
Subject: [lustre-devel] [PATCH 072/622] lustre: migrate: pack lmv ea in
 migrate rpc
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-73-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

To support stripe directory migration, pack lmv_user_md in migrate
RPC. Add arguments of 'mdt-count' and 'mdt-hash' for 'lfs migrate'.

Disable directory migration related tests temprorily, and we'll
enable them later in the last patch of this set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4684
Lustre-commit: 470bdeec6ca5 ("LU-4684 migrate: pack lmv ea in migrate rpc")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31424
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 19 ++++++----
 fs/lustre/llite/file.c                  | 67 +++++++++++++++++----------------
 fs/lustre/llite/llite_internal.h        |  4 +-
 fs/lustre/llite/llite_lib.c             |  4 +-
 fs/lustre/mdc/mdc_lib.c                 | 21 +++++++----
 fs/lustre/mdc/mdc_reint.c               | 20 ++--------
 fs/lustre/ptlrpc/layout.c               |  3 +-
 include/uapi/linux/lustre/lustre_idl.h  |  2 +-
 include/uapi/linux/lustre/lustre_user.h |  8 +++-
 9 files changed, 77 insertions(+), 71 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index c0c3bf0..751d0183 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1322,7 +1322,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto finish_req;
 		}
 
-		lum_size = lmv_user_md_size(stripe_count, LMV_MAGIC_V1);
+		lum_size = lmv_user_md_size(stripe_count,
+					    LMV_USER_MAGIC_SPECIFIC);
 		tmp = kzalloc(lum_size, GFP_NOFS);
 		if (!tmp) {
 			rc = -ENOMEM;
@@ -1655,14 +1656,14 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_MIGRATE: {
-		const char *filename;
+		struct lmv_user_md *lum;
+		char *filename;
 		int namelen = 0;
 		int len;
 		int rc;
-		int mdtidx;
 
 		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
-		if (rc < 0)
+		if (rc)
 			return rc;
 
 		if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
@@ -1674,17 +1675,21 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		filename = data->ioc_inlbuf1;
 		namelen = data->ioc_inllen1;
 		if (namelen < 1 || namelen != strlen(filename) + 1) {
+			CDEBUG(D_INFO, "IOC_MDC_LOOKUP missing filename\n");
 			rc = -EINVAL;
 			goto migrate_free;
 		}
 
-		if (data->ioc_inllen2 != sizeof(mdtidx)) {
+		lum = (struct lmv_user_md *)data->ioc_inlbuf2;
+		if (lum->lum_magic != LMV_USER_MAGIC &&
+		    lum->lum_magic != LMV_USER_MAGIC_SPECIFIC) {
 			rc = -EINVAL;
+			CERROR("%s: wrong lum magic %x: rc = %d\n",
+			       filename, lum->lum_magic, rc);
 			goto migrate_free;
 		}
-		mdtidx = *(int *)data->ioc_inlbuf2;
 
-		rc = ll_migrate(inode, file, mdtidx, filename, namelen - 1);
+		rc = ll_migrate(inode, file, lum, filename);
 migrate_free:
 		kvfree(data);
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7657c79..68fb623 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3785,8 +3785,8 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 	return rc;
 }
 
-int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
-	       const char *name, int namelen)
+int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
+	       const char *name)
 {
 	struct ptlrpc_request *request = NULL;
 	struct obd_client_handle *och = NULL;
@@ -3795,16 +3795,18 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	struct md_op_data *op_data;
 	struct mdt_body *body;
 	u64 data_version = 0;
+	size_t namelen = strlen(name);
+	int lumlen = lmv_user_md_size(lum->lum_stripe_count, lum->lum_magic);
 	struct qstr qstr;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "migrate %s under " DFID " to MDT%d\n",
-	       name, PFID(ll_inode2fid(parent)), mdtidx);
+	CDEBUG(D_VFSTRACE, "migrate " DFID "/%s to MDT%d stripe count %d\n",
+	       PFID(ll_inode2fid(parent)), name,
+	       lum->lum_stripe_offset, lum->lum_stripe_count);
 
-	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
-				     0, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	if (lum->lum_magic != cpu_to_le32(LMV_USER_MAGIC) &&
+	    lum->lum_magic != cpu_to_le32(LMV_USER_MAGIC_SPECIFIC))
+		lustre_swab_lmv_user_md(lum);
 
 	/* Get child FID first */
 	qstr.hash = full_name_hash(file_dentry(file), name, namelen);
@@ -3818,16 +3820,14 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 	}
 
 	if (!child_inode) {
-		rc = ll_get_fid_by_name(parent, name, namelen,
-					&op_data->op_fid3, &child_inode);
+		rc = ll_get_fid_by_name(parent, name, namelen, NULL,
+					&child_inode);
 		if (rc)
-			goto out_free;
+			return rc;
 	}
 
-	if (!child_inode) {
-		rc = -EINVAL;
-		goto out_free;
-	}
+	if (!child_inode)
+		return -ENOENT;
 
 	/*
 	 * lfs migrate command needs to be blocked on the client
@@ -3839,6 +3839,13 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		goto out_iput;
 	}
 
+	op_data = ll_prep_md_op_data(NULL, parent, NULL, name, namelen,
+				     child_inode->i_mode, LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto out_iput;
+	}
+
 	inode_lock(child_inode);
 	op_data->op_fid3 = *ll_inode2fid(child_inode);
 	if (!fid_is_sane(&op_data->op_fid3)) {
@@ -3849,16 +3856,10 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		goto out_unlock;
 	}
 
-	rc = ll_get_mdt_idx_by_fid(ll_i2sbi(parent), &op_data->op_fid3);
-	if (rc < 0)
-		goto out_unlock;
+	op_data->op_cli_flags |= CLI_MIGRATE | CLI_SET_MEA;
+	op_data->op_data = lum;
+	op_data->op_data_size = lumlen;
 
-	if (rc == mdtidx) {
-		CDEBUG(D_INFO, "%s: " DFID " is already on MDT%d.\n", name,
-		       PFID(&op_data->op_fid3), mdtidx);
-		rc = 0;
-		goto out_unlock;
-	}
 again:
 	if (S_ISREG(child_inode->i_mode)) {
 		och = ll_lease_open(child_inode, NULL, FMODE_WRITE, 0);
@@ -3874,16 +3875,17 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 			goto out_close;
 
 		op_data->op_handle = och->och_fh;
-		op_data->op_data = och->och_mod;
 		op_data->op_data_version = data_version;
 		op_data->op_lease_handle = och->och_lease_handle;
-		op_data->op_bias |= MDS_RENAME_MIGRATE;
+		op_data->op_bias |= MDS_CLOSE_MIGRATE;
+
+		spin_lock(&och->och_mod->mod_open_req->rq_lock);
+		och->och_mod->mod_open_req->rq_replay = 0;
+		spin_unlock(&och->och_mod->mod_open_req->rq_lock);
 	}
 
-	op_data->op_mds = mdtidx;
-	op_data->op_cli_flags = CLI_MIGRATE;
-	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data, name,
-		       namelen, name, namelen, &request);
+	rc = md_rename(ll_i2sbi(parent)->ll_md_exp, op_data, name, namelen,
+		       name, namelen, &request);
 	if (!rc) {
 		LASSERT(request);
 		ll_update_times(request, parent);
@@ -3915,16 +3917,15 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 		goto again;
 
 out_close:
-	if (och) /* close the file */
+	if (och)
 		ll_lease_close(och, child_inode, NULL);
 	if (!rc)
 		clear_nlink(child_inode);
 out_unlock:
 	inode_unlock(child_inode);
+	ll_finish_md_op_data(op_data);
 out_iput:
 	iput(child_inode);
-out_free:
-	ll_finish_md_op_data(op_data);
 	return rc;
 }
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 7491397..edb5f2a 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -824,8 +824,8 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 #define ll_set_acl NULL
 #endif /* CONFIG_LUSTRE_FS_POSIX_ACL */
 
-int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
-	       const char *name, int namelen);
+int ll_migrate(struct inode *parent, struct file *file,
+	       struct lmv_user_md *lum, const char *name);
 int ll_get_fid_by_name(struct inode *parent, const char *name,
 		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 56624e8..c04146f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -209,7 +209,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_GRANT_PARAM |
 				  OBD_CONNECT_SHORTIO | OBD_CONNECT_FLAGS2;
 
-	data->ocd_connect_flags2 = OBD_CONNECT2_FLR | OBD_CONNECT2_LOCK_CONVERT;
+	data->ocd_connect_flags2 = OBD_CONNECT2_FLR |
+				   OBD_CONNECT2_LOCK_CONVERT |
+				   OBD_CONNECT2_DIR_MIGRATE;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index e2f1a49..1d38574 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -443,7 +443,7 @@ static void mdc_close_intent_pack(struct ptlrpc_request *req,
 	struct close_data *data;
 	struct ldlm_lock *lock;
 
-	if (!(bias & (MDS_CLOSE_INTENT | MDS_RENAME_MIGRATE)))
+	if (!(bias & (MDS_CLOSE_INTENT | MDS_CLOSE_MIGRATE)))
 		return;
 
 	data = req_capsule_client_get(&req->rq_pill, &RMF_CLOSE_DATA);
@@ -507,13 +507,20 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	if (new)
 		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
 
-	if (op_data->op_cli_flags & CLI_MIGRATE &&
-	    op_data->op_bias & MDS_RENAME_MIGRATE) {
-		struct mdt_ioepoch *epoch;
+	if (op_data->op_cli_flags & CLI_MIGRATE) {
+		char *tmp;
 
-		mdc_close_intent_pack(req, op_data);
-		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
-		mdc_ioepoch_pack(epoch, op_data);
+		if (op_data->op_bias & MDS_CLOSE_MIGRATE) {
+			struct mdt_ioepoch *epoch;
+
+			mdc_close_intent_pack(req, op_data);
+			epoch = req_capsule_client_get(&req->rq_pill,
+							&RMF_MDT_EPOCH);
+			mdc_ioepoch_pack(epoch, op_data);
+		}
+
+		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
+		memcpy(tmp, op_data->op_data, op_data->op_data_size);
 	}
 }
 
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index d326962..030c247 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -390,6 +390,9 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT, oldlen + 1);
 	req_capsule_set_size(&req->rq_pill, &RMF_SYMTGT, RCL_CLIENT,
 			     newlen + 1);
+	if (op_data->op_cli_flags & CLI_MIGRATE)
+		req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
+				     op_data->op_data_size);
 
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
@@ -397,23 +400,6 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
-	if (op_data->op_cli_flags & CLI_MIGRATE && op_data->op_data) {
-		struct md_open_data *mod = op_data->op_data;
-
-		LASSERTF(mod->mod_open_req &&
-			 mod->mod_open_req->rq_type != LI_POISON,
-			 "POISONED open %p!\n", mod->mod_open_req);
-
-		DEBUG_REQ(D_HA, mod->mod_open_req, "matched open");
-		/*
-		 * We no longer want to preserve this open for replay even
-		 * though the open was committed. b=3632, b=3633
-		 */
-		spin_lock(&mod->mod_open_req->rq_lock);
-		mod->mod_open_req->rq_replay = 0;
-		spin_unlock(&mod->mod_open_req->rq_lock);
-	}
-
 	if (exp_connect_cancelset(exp) && req)
 		ldlm_cli_cancel_list(&cancels, count, req, 0);
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index c11b1b0..ae573a2 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -263,7 +263,8 @@
 	&RMF_SYMTGT,
 	&RMF_DLM_REQ,
 	&RMF_MDT_EPOCH,
-	&RMF_CLOSE_DATA
+	&RMF_CLOSE_DATA,
+	&RMF_EADATA
 };
 
 static const struct req_msg_field *mds_last_unlink_server[] = {
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 9f8d65d..75326c0 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1693,7 +1693,7 @@ enum mds_op_bias {
 	MDS_CREATE_VOLATILE	= 1 << 10,
 	MDS_OWNEROVERRIDE	= 1 << 11,
 	MDS_HSM_RELEASE		= 1 << 12,
-	MDS_RENAME_MIGRATE	= 1 << 13,
+	MDS_CLOSE_MIGRATE	= 1 << 13,
 	MDS_CLOSE_LAYOUT_SWAP	= 1 << 14,
 	MDS_CLOSE_LAYOUT_MERGE	= 1 << 15,
 	MDS_CLOSE_RESYNC_DONE	= 1 << 16,
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 8fd5b26..421c977 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -632,8 +632,12 @@ struct lmv_user_md_v1 {
 
 static inline int lmv_user_md_size(int stripes, int lmm_magic)
 {
-	return sizeof(struct lmv_user_md) +
-		      stripes * sizeof(struct lmv_user_mds_data);
+	int size = sizeof(struct lmv_user_md);
+
+	if (lmm_magic == LMV_USER_MAGIC_SPECIFIC)
+		size += stripes * sizeof(struct lmv_user_mds_data);
+
+	return size;
 }
 
 struct ll_recreate_obj {
-- 
1.8.3.1
