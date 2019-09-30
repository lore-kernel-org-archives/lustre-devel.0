From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:34 -0400
Subject: [lustre-devel] [PATCH 075/151] lustre: flr: resync support and test
 tool
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-76-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

A tool to resync mirrored file after writing.
It extends the Lustre lease API to support taking file lease and then
sending the MDS_REINT_RESYNC RPC to the MDT so that it can increase
the file's layout version; then the client will start copying
the contents from valid mirror to stale mirrors. At the end of
resync, the copying client will release the lease and revalidate
stale mirrors.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 5999c0b881e8 ("LU-9771 flr: resync support and test tool")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29096
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloiud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h      |   1 +
 fs/lustre/include/lustre_req_layout.h   |   1 +
 fs/lustre/include/lustre_swab.h         |   1 +
 fs/lustre/include/obd.h                 |   2 +
 fs/lustre/include/obd_class.h           |  15 ++
 fs/lustre/llite/file.c                  | 289 ++++++++++++++++++++++++--------
 fs/lustre/llite/llite_internal.h        |   8 +-
 fs/lustre/llite/rw26.c                  |  10 ++
 fs/lustre/lmv/lmv_obd.c                 |  21 +++
 fs/lustre/lov/lov_io.c                  |  70 +++++++-
 fs/lustre/mdc/mdc_internal.h            |   1 +
 fs/lustre/mdc/mdc_lib.c                 |  16 ++
 fs/lustre/mdc/mdc_reint.c               |  52 ++++++
 fs/lustre/mdc/mdc_request.c             |  38 +++--
 fs/lustre/osc/osc_io.c                  |   3 +
 fs/lustre/ptlrpc/layout.c               |  16 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c         |   1 +
 fs/lustre/ptlrpc/pack_generic.c         |  13 ++
 fs/lustre/ptlrpc/wiretest.c             |  94 ++++++++++-
 include/uapi/linux/lustre/lustre_idl.h  |  47 +++++-
 include/uapi/linux/lustre/lustre_user.h |  35 +++-
 21 files changed, 630 insertions(+), 104 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index e923673..54e4eda 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -334,6 +334,7 @@ enum {
 	MDS_REINT_RENAME,
 	MDS_REINT_OPEN,
 	MDS_REINT_SETXATTR,
+	MDS_REINT_RESYNC,
 	BRW_READ_BYTES,
 	BRW_WRITE_BYTES,
 	EXTRA_LAST_OPC
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index c255648..3d86883 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -163,6 +163,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_MDS_QUOTACTL;
 extern struct req_format RQF_MDS_SWAP_LAYOUTS;
 extern struct req_format RQF_MDS_REINT_MIGRATE;
+extern struct req_format RQF_MDS_REINT_RESYNC;
 /* MDS hsm formats */
 extern struct req_format RQF_MDS_HSM_STATE_GET;
 extern struct req_format RQF_MDS_HSM_STATE_SET;
diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index 1758dd9..79cacf4 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -99,6 +99,7 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 void lustre_swab_hsm_request(struct hsm_request *hr);
 void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl);
 void lustre_swab_close_data(struct close_data *data);
+void lustre_swab_close_data_resync_done(struct close_data_resync_done *resync);
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
 void lustre_swab_ladvise(struct lu_ladvise *ladvise);
 void lustre_swab_ladvise_hdr(struct ladvise_hdr *ladvise_hdr);
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index c377a91..e377526 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -931,6 +931,8 @@ struct obd_client_handle {
 struct cl_attr;
 
 struct md_ops {
+	int (*file_resync)(struct obd_export *exp, struct md_op_data *data);
+
 	int (*get_root)(struct obd_export *exp, const char *fileset,
 			 struct lu_fid *fid);
 	int (*null_inode)(struct obd_export *, const struct lu_fid *);
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f26ca17..a939f17 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1349,6 +1349,21 @@ static inline int md_fsync(struct obd_export *exp, const struct lu_fid *fid,
 	return MDP(exp->exp_obd, fsync)(exp, fid, request);
 }
 
+/* FLR: resync mirrored files. */
+static inline int md_file_resync(struct obd_export *exp,
+				 struct md_op_data *data)
+{
+	int rc;
+
+	rc = exp_check_ops(exp);
+	if (rc)
+		return rc;
+
+	rc = MDP(exp->exp_obd, file_resync)(exp, data);
+
+	return rc;
+}
+
 static inline int md_read_page(struct obd_export *exp,
 			       struct md_op_data *op_data,
 			       struct md_callback *cb_op,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 335f9bf..d13c583 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -161,6 +161,23 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		op_data->op_fid2 = *ll_inode2fid(data);
 		break;
 
+	case MDS_CLOSE_RESYNC_DONE: {
+		struct ll_ioc_lease *ioc = data;
+
+		LASSERT(data);
+		op_data->op_attr_blocks +=
+			ioc->lil_count * op_data->op_attr_blocks;
+		op_data->op_attr.ia_valid |= ATTR_SIZE;
+		op_data->op_xvalid |= OP_XVALID_BLOCKS;
+		op_data->op_bias |= MDS_CLOSE_RESYNC_DONE;
+
+		op_data->op_lease_handle = och->och_lease_handle;
+		op_data->op_data = &ioc->lil_ids[0];
+		op_data->op_data_size =
+			ioc->lil_count * sizeof(ioc->lil_ids[0]);
+		break;
+	}
+
 	case MDS_HSM_RELEASE:
 		LASSERT(data);
 		op_data->op_bias |= MDS_HSM_RELEASE;
@@ -1007,8 +1024,10 @@ static int ll_swap_layouts_close(struct obd_client_handle *och,
  * Release lease and close the file.
  * It will check if the lease has ever broken.
  */
-static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
-			  bool *lease_broken)
+static int ll_lease_close_intent(struct obd_client_handle *och,
+				 struct inode *inode,
+				 bool *lease_broken, enum mds_op_bias bias,
+				 void *data)
 {
 	struct ldlm_lock *lock;
 	bool cancelled = true;
@@ -1021,15 +1040,60 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 		LDLM_LOCK_PUT(lock);
 	}
 
-	CDEBUG(D_INODE, "lease for " DFID " broken? %d\n",
-	       PFID(&ll_i2info(inode)->lli_fid), cancelled);
+	CDEBUG(D_INODE, "lease for " DFID " broken? %d, bias: %x\n",
+	       PFID(&ll_i2info(inode)->lli_fid), cancelled, bias);
 
-	if (!cancelled)
-		ldlm_cli_cancel(&och->och_lease_handle, 0);
 	if (lease_broken)
 		*lease_broken = cancelled;
 
-	return ll_close_inode_openhandle(inode, och, 0, NULL);
+	if (!cancelled && !bias)
+		ldlm_cli_cancel(&och->och_lease_handle, 0);
+	if (cancelled) { /* no need to excute intent */
+		bias = 0;
+		data = NULL;
+	}
+
+	return ll_close_inode_openhandle(inode, och, bias, data);
+}
+
+static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
+			  bool *lease_broken)
+{
+	return ll_lease_close_intent(och, inode, lease_broken, 0, NULL);
+}
+
+/**
+ * After lease is taken, send the RPC MDS_REINT_RESYNC to the MDT
+ */
+static int ll_lease_file_resync(struct obd_client_handle *och,
+				struct inode *inode)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct md_op_data *op_data;
+	u64 data_version_unused;
+	int rc;
+
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	/* before starting file resync, it's necessary to clean up page cache
+	 * in client memory, otherwise once the layout version is increased,
+	 * writing back cached data will be denied the OSTs.
+	 */
+	rc = ll_data_version(inode, &data_version_unused, LL_DV_WR_FLUSH);
+	if (rc)
+		goto out;
+
+	op_data->op_handle = och->och_lease_handle;
+	rc = md_file_resync(sbi->ll_md_exp, op_data);
+	if (rc)
+		goto out;
+
+out:
+	ll_finish_md_op_data(op_data);
+	return rc;
 }
 
 int ll_merge_attr(const struct lu_env *env, struct inode *inode)
@@ -1114,12 +1178,18 @@ void ll_io_set_mirror(struct cl_io *io, const struct file *file)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 
+	/* clear layout version for generic(non-resync) I/O in case it carries
+	 * stale layout version due to I/O restart
+	 */
+	io->ci_layout_version = 0;
+
 	/* FLR: disable non-delay for designated mirror I/O because obviously
 	 * only one mirror is available
 	 */
 	if (fd->fd_designated_mirror > 0) {
 		io->ci_ndelay = 0;
 		io->ci_designated_mirror = fd->fd_designated_mirror;
+		io->ci_layout_version = fd->fd_layout_version;
 	}
 
 	CDEBUG(D_VFSTRACE, "%s: desiginated mirror: %d\n",
@@ -2577,6 +2647,140 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	kfree(attr);
 out_fsxattr:
 	ll_finish_md_op_data(op_data);
+
+	return rc;
+}
+
+static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
+				 unsigned long arg)
+{
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct obd_client_handle *och = NULL;
+	bool lease_broken;
+	fmode_t fmode = 0;
+	enum mds_op_bias bias = 0;
+	void *data = NULL;
+	size_t data_size = 0;
+	long rc;
+
+	mutex_lock(&lli->lli_och_mutex);
+	if (fd->fd_lease_och) {
+		och = fd->fd_lease_och;
+		fd->fd_lease_och = NULL;
+	}
+	mutex_unlock(&lli->lli_och_mutex);
+
+	if (!och) {
+		rc = -ENOLCK;
+		goto out;
+	}
+
+	fmode = och->och_flags;
+
+	if (ioc->lil_flags & LL_LEASE_RESYNC_DONE) {
+		if (ioc->lil_count > IOC_IDS_MAX) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		data_size = offsetof(typeof(*ioc), lil_ids[ioc->lil_count]);
+		data = kzalloc(data_size, GFP_KERNEL);
+		if (!data) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		if (copy_from_user(data, (void __user *)arg, data_size)) {
+			rc = -EFAULT;
+			goto out;
+		}
+
+		bias = MDS_CLOSE_RESYNC_DONE;
+	}
+
+	rc = ll_lease_close_intent(och, inode, &lease_broken, bias, data);
+	if (rc < 0)
+		goto out;
+
+	rc = ll_lease_och_release(inode, file);
+	if (rc < 0)
+		goto out;
+
+	if (lease_broken)
+		fmode = 0;
+
+out:
+	kfree(data);
+	if (!rc)
+		rc = ll_lease_type_from_fmode(fmode);
+	return rc;
+}
+
+static long ll_file_set_lease(struct file *file, struct ll_ioc_lease *ioc,
+			      unsigned long arg)
+{
+	struct inode *inode = file_inode(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct obd_client_handle *och = NULL;
+	u64 open_flags = 0;
+	bool lease_broken;
+	fmode_t fmode;
+	long rc;
+
+	switch (ioc->lil_mode) {
+	case LL_LEASE_WRLCK:
+		if (!(file->f_mode & FMODE_WRITE))
+			return -EPERM;
+		fmode = FMODE_WRITE;
+		break;
+	case LL_LEASE_RDLCK:
+		if (!(file->f_mode & FMODE_READ))
+			return -EPERM;
+		fmode = FMODE_READ;
+		break;
+	case LL_LEASE_UNLCK:
+		return ll_file_unlock_lease(file, ioc, arg);
+	default:
+		return -EINVAL;
+	}
+
+	CDEBUG(D_INODE, "Set lease with mode %u\n", fmode);
+
+	/* apply for lease */
+	if (ioc->lil_flags & LL_LEASE_RESYNC)
+		open_flags = MDS_OPEN_RESYNC;
+	och = ll_lease_open(inode, file, fmode, open_flags);
+	if (IS_ERR(och))
+		return PTR_ERR(och);
+
+	if (ioc->lil_flags & LL_LEASE_RESYNC) {
+		rc = ll_lease_file_resync(och, inode);
+		if (rc) {
+			ll_lease_close(och, inode, NULL);
+			return rc;
+		}
+		rc = ll_layout_refresh(inode, &fd->fd_layout_version);
+		if (rc) {
+			ll_lease_close(och, inode, NULL);
+			return rc;
+		}
+	}
+
+	rc = 0;
+	mutex_lock(&lli->lli_och_mutex);
+	if (!fd->fd_lease_och) {
+		fd->fd_lease_och = och;
+		och = NULL;
+	}
+	mutex_unlock(&lli->lli_och_mutex);
+	if (och) {
+		/* impossible now that only excl is supported for now */
+		ll_lease_close(och, inode, &lease_broken);
+		rc = -EBUSY;
+	}
 	return rc;
 }
 
@@ -2805,71 +3009,18 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		kfree(hca);
 		return rc;
 	}
-	case LL_IOC_SET_LEASE: {
-		struct ll_inode_info *lli = ll_i2info(inode);
-		struct obd_client_handle *och = NULL;
-		bool lease_broken;
-		fmode_t fmode;
-
-		switch (arg) {
-		case LL_LEASE_WRLCK:
-			if (!(file->f_mode & FMODE_WRITE))
-				return -EPERM;
-			fmode = FMODE_WRITE;
-			break;
-		case LL_LEASE_RDLCK:
-			if (!(file->f_mode & FMODE_READ))
-				return -EPERM;
-			fmode = FMODE_READ;
-			break;
-		case LL_LEASE_UNLCK:
-			mutex_lock(&lli->lli_och_mutex);
-			if (fd->fd_lease_och) {
-				och = fd->fd_lease_och;
-				fd->fd_lease_och = NULL;
-			}
-			mutex_unlock(&lli->lli_och_mutex);
-
-			if (!och)
-				return -ENOLCK;
+	case LL_IOC_SET_LEASE_OLD: {
+		struct ll_ioc_lease ioc = { .lil_mode = (u32)arg };
 
-			fmode = och->och_flags;
-			rc = ll_lease_close(och, inode, &lease_broken);
-			if (rc < 0)
-				return rc;
-
-			rc = ll_lease_och_release(inode, file);
-			if (rc < 0)
-				return rc;
-
-			if (lease_broken)
-				fmode = 0;
-
-			return ll_lease_type_from_fmode(fmode);
-		default:
-			return -EINVAL;
-		}
-
-		CDEBUG(D_INODE, "Set lease with mode %u\n", fmode);
+		return ll_file_set_lease(file, &ioc, 0);
+	}
+	case LL_IOC_SET_LEASE: {
+		struct ll_ioc_lease ioc;
 
-		/* apply for lease */
-		och = ll_lease_open(inode, file, fmode, 0);
-		if (IS_ERR(och))
-			return PTR_ERR(och);
+		if (copy_from_user(&ioc, (void __user *)arg, sizeof(ioc)))
+			return -EFAULT;
 
-		rc = 0;
-		mutex_lock(&lli->lli_och_mutex);
-		if (!fd->fd_lease_och) {
-			fd->fd_lease_och = och;
-			och = NULL;
-		}
-		mutex_unlock(&lli->lli_och_mutex);
-		if (och) {
-			/* impossible now that only excl is supported for now */
-			ll_lease_close(och, inode, &lease_broken);
-			rc = -EBUSY;
-		}
-		return rc;
+		return ll_file_set_lease(file, &ioc, arg);
 	}
 	case LL_IOC_GET_LEASE: {
 		struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2d32c5e..dc81474 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -653,12 +653,16 @@ struct ll_file_data {
 	 */
 	bool fd_write_failed;
 	bool ll_lock_no_expand;
+	rwlock_t fd_lock; /* protect lcc list */
+	struct list_head fd_lccs; /* list of ll_cl_context */
 	/* Used by mirrored file to lead IOs to a specific mirror, usually
 	 * for mirror resync. 0 means default.
 	 */
 	u32 fd_designated_mirror;
-	rwlock_t fd_lock; /* protect lcc list */
-	struct list_head fd_lccs; /* list of ll_cl_context */
+	/* The layout version when resync starts. Resync I/O should carry this
+	 * layout version for verification to OST objects
+	 */
+	u32 fd_layout_version;
 };
 
 void llite_tunables_unregister(void);
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 805ba32..35d39fe 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -443,6 +443,16 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	env = lcc->lcc_env;
 	io  = lcc->lcc_io;
 
+	if (file->f_flags & O_DIRECT && io->ci_designated_mirror > 0) {
+		/* direct IO failed because it couldn't clean up cached pages,
+		 * this causes a problem for mirror write because the cached
+		 * page may belong to another mirror, which will result in
+		 * problem submitting the I/O.
+		 */
+		result = -EBUSY;
+		goto out;
+	}
+
 	/* To avoid deadlock, try to lock page first. */
 	vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 73ab7b6..47fc22c 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2139,6 +2139,26 @@ static struct lu_dirent *stripe_dirent_next(struct lmv_dir_ctxt *ctxt,
 	return ent;
 }
 
+static int lmv_file_resync(struct obd_export *exp, struct md_op_data *data)
+{
+	struct obd_device *obd = exp->exp_obd;
+	struct lmv_obd *lmv = &obd->u.lmv;
+	struct lmv_tgt_desc *tgt;
+	int rc;
+
+	rc = lmv_check_connect(obd);
+	if (rc != 0)
+		return rc;
+
+	tgt = lmv_find_target(lmv, &data->op_fid1);
+	if (IS_ERR(tgt))
+		return PTR_ERR(tgt);
+
+	data->op_flags |= MF_MDC_CANCEL_FID1;
+	rc = md_file_resync(tgt->ltd_exp, data);
+	return rc;
+}
+
 /**
  * Get dirent with the closest hash for striped directory
  *
@@ -3120,6 +3140,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	.setattr		= lmv_setattr,
 	.setxattr		= lmv_setxattr,
 	.fsync			= lmv_fsync,
+	.file_resync		= lmv_file_resync,
 	.read_page		= lmv_read_page,
 	.unlink			= lmv_unlink,
 	.init_ea_size		= lmv_init_ea_size,
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 628057d..9fd1b52 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -229,8 +229,17 @@ static int lov_io_mirror_write_intent(struct lov_io *lio,
 	      cl_io_is_mkwrite(io)))
 		return 0;
 
+	/* FLR: check if it needs to send a write intent RPC to server.
+	 * Writing to sync_pending file needs write intent RPC to change
+	 * the file state back to write_pending, so that the layout version
+	 * can be increased when the state changes to sync_pending at a later
+	 * time. Otherwise there exists a chance that an evicted client may
+	 * dirty the file data while resync client is working on it.
+	 * Designated I/O is allowed for resync workload.
+	 */
 	if (lov_flr_state(obj) == LCM_FL_RDONLY ||
-	    lov_flr_state(obj) == LCM_FL_SYNC_PENDING) {
+	    (lov_flr_state(obj) == LCM_FL_SYNC_PENDING &&
+	     io->ci_designated_mirror == 0)) {
 		io->ci_need_write_intent = 1;
 		return 0;
 	}
@@ -299,12 +308,31 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		return 0;
 	}
 
+	/* transfer the layout version for verification */
+	if (io->ci_layout_version == 0)
+		io->ci_layout_version = obj->lo_lsm->lsm_layout_gen;
+
 	/* find the corresponding mirror for designated mirror IO */
 	if (io->ci_designated_mirror > 0) {
 		struct lov_mirror_entry *entry;
 
 		LASSERT(!io->ci_ndelay);
 
+		CDEBUG(D_LAYOUT, "designated I/O mirror state: %d\n",
+		      lov_flr_state(obj));
+
+		if ((cl_io_is_trunc(io) || io->ci_type == CIT_WRITE) &&
+		    (io->ci_layout_version != obj->lo_lsm->lsm_layout_gen)) {
+			/* For resync I/O, the ci_layout_version was the layout
+			 * version when resync starts. If it doesn't match the
+			 * current object layout version, it means the layout
+			 * has been changed
+			 */
+			return -ESTALE;
+		}
+
+		io->ci_layout_version |= LU_LAYOUT_RESYNC;
+
 		index = 0;
 		lio->lis_mirror_index = -1;
 		lov_foreach_mirror_entry(obj, entry) {
@@ -317,7 +345,7 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 			index++;
 		}
 
-		return (lio->lis_mirror_index < 0) ? -EINVAL : 0;
+		return lio->lis_mirror_index < 0 ? -EINVAL : 0;
 	}
 
 	result = lov_io_mirror_write_intent(lio, obj, io);
@@ -333,9 +361,6 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		return 1;
 	}
 
-	/* transfer the layout version for verification */
-	io->ci_layout_version = obj->lo_lsm->lsm_layout_gen;
-
 	if (io->ci_ndelay_tried == 0 || /* first time to try */
 	    /* reset the mirror index if layout has changed */
 	    lio->lis_mirror_layout_gen != obj->lo_lsm->lsm_layout_gen) {
@@ -529,11 +554,29 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		if (!lsm_entry_inited(obj->lo_lsm, index)) {
 			io->ci_need_write_intent = 1;
 			io->ci_write_intent = ext;
-			result = 1;
-			goto out;
+			break;
 		}
 	}
 
+	if (io->ci_need_write_intent && io->ci_designated_mirror > 0) {
+		/* REINT_SYNC RPC has already tried to instantiate all of the
+		 * components involved, obviously it didn't succeed. Skip this
+		 * mirror for now. The server won't be able to figure out
+		 * which mirror it should instantiate components
+		 */
+		CERROR(DFID": trying to instantiate components for designated I/O, file state: %d\n",
+		       PFID(lu_object_fid(lov2lu(obj))), lov_flr_state(obj));
+
+		io->ci_need_write_intent = 0;
+		result = -EIO;
+		goto out;
+	}
+
+	if (io->ci_need_write_intent) {
+		result = 1;
+		goto out;
+	}
+
 out:
 	return result;
 }
@@ -661,7 +704,8 @@ static int lov_io_iter_init(const struct lu_env *env,
 	ext.e_end = lio->lis_endpos;
 
 	lov_foreach_io_layout(index, lio, &ext) {
-		struct lov_layout_raid0 *r0 = lov_r0(lio->lis_object, index);
+		struct lov_layout_entry *le = lov_entry(lio->lis_object, index);
+		struct lov_layout_raid0 *r0 = &le->lle_raid0;
 		int stripe;
 		u64 start;
 		u64 end;
@@ -675,6 +719,12 @@ static int lov_io_iter_init(const struct lu_env *env,
 			continue;
 		}
 
+		if (!le->lle_valid && !ios->cis_io->ci_designated_mirror) {
+			CERROR("I/O to invalid component: %d, mirror: %d\n",
+			       index, lio->lis_mirror_index);
+			return -EIO;
+		}
+
 		for (stripe = 0; stripe < r0->lo_nr; stripe++) {
 			if (!lov_stripe_intersects(lsm, index, stripe,
 						   &ext, &start, &end))
@@ -744,6 +794,10 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 		return -ENODATA;
 	}
 
+	if (!lov_entry(lio->lis_object, index)->lle_valid &&
+	    !io->ci_designated_mirror)
+		return io->ci_type == CIT_READ ? -EAGAIN : -EIO;
+
 	lse = lov_lse(lio->lis_object, index);
 
 	next = MAX_LFS_FILESIZE;
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 6b282b2..669cb1c 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -116,6 +116,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		void *ea, size_t ealen, struct ptlrpc_request **request);
 int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	       struct ptlrpc_request **request);
+int mdc_file_resync(struct obd_export *exp, struct md_op_data *data);
 int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 		      union ldlm_policy_data *policy, enum ldlm_mode mode,
 		      enum ldlm_cancel_flags flags, void *opaque);
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index d0ae6f2..ff14f82 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -450,6 +450,22 @@ static void mdc_intent_close_pack(struct ptlrpc_request *req,
 
 	data->cd_data_version = op_data->op_data_version;
 	data->cd_fid = op_data->op_fid2;
+
+	if (bias & MDS_CLOSE_RESYNC_DONE) {
+		struct close_data_resync_done *sync = &data->cd_resync;
+
+		BUILD_BUG_ON(sizeof(data->cd_resync) > sizeof(data->cd_reserved));
+		sync->resync_count = op_data->op_data_size / sizeof(u32);
+		if (sync->resync_count <= INLINE_RESYNC_ARRAY_SIZE) {
+			memcpy(sync->resync_ids_inline, op_data->op_data,
+			       op_data->op_data_size);
+		} else {
+			size_t count = sync->resync_count;
+
+			memcpy(req_capsule_client_get(&req->rq_pill, &RMF_U32),
+				op_data->op_data, count * sizeof(u32));
+		}
+	}
 }
 
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 87dabaf..8e0bd0a 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -427,3 +427,55 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 
 	return rc;
 }
+
+int mdc_file_resync(struct obd_export *exp, struct md_op_data *op_data)
+{
+	struct list_head cancels = LIST_HEAD_INIT(cancels);
+	struct ptlrpc_request *req;
+	struct ldlm_lock *lock;
+	struct mdt_rec_resync *rec;
+	int count = 0, rc;
+
+	if (op_data->op_flags & MF_MDC_CANCEL_FID1 &&
+	    fid_is_sane(&op_data->op_fid1))
+		count = mdc_resource_get_unused(exp, &op_data->op_fid1,
+						&cancels, LCK_EX,
+						MDS_INODELOCK_LAYOUT);
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
+				   &RQF_MDS_REINT_RESYNC);
+	if (!req) {
+		ldlm_lock_list_put(&cancels, l_bl_ast, count);
+		return -ENOMEM;
+	}
+
+	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	BUILD_BUG_ON(sizeof(*rec) != sizeof(struct mdt_rec_reint));
+	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
+	rec->rs_opcode	= REINT_RESYNC;
+	rec->rs_fsuid	= op_data->op_fsuid;
+	rec->rs_fsgid	= op_data->op_fsgid;
+	rec->rs_cap	= op_data->op_cap.cap[0];
+	rec->rs_fid	= op_data->op_fid1;
+	rec->rs_bias	= op_data->op_bias;
+
+	lock = ldlm_handle2lock(&op_data->op_handle);
+	if (lock) {
+		rec->rs_handle = lock->l_remote_handle;
+		LDLM_LOCK_PUT(lock);
+	}
+
+	ptlrpc_request_set_replen(req);
+
+	rc = mdc_reint(req, LUSTRE_IMP_FULL);
+	if (rc == -ERESTARTSYS)
+		rc = 0;
+
+	ptlrpc_req_finished(req);
+	return rc;
+}
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index a1ed9bf..9bae3a5 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -762,23 +762,34 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	struct obd_device *obd = class_exp2obd(exp);
 	struct ptlrpc_request *req;
 	struct req_format *req_fmt;
+	size_t u32_count = 0;
 	int rc;
 	int saved_rc = 0;
 
-	if (op_data->op_bias & MDS_HSM_RELEASE) {
+	CDEBUG(D_INODE, "%s: " DFID " file closed with intent: %x\n",
+	       exp->exp_obd->obd_name, PFID(&op_data->op_fid1),
+	       op_data->op_bias);
+
+	if (op_data->op_bias & MDS_CLOSE_INTENT) {
 		req_fmt = &RQF_MDS_INTENT_CLOSE;
+		if (op_data->op_bias & MDS_HSM_RELEASE) {
+			/* allocate a FID for volatile file */
+			rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2,
+					   op_data);
+			if (rc < 0) {
+				CERROR("%s: " DFID " allocating FID: rc = %d\n",
+				       obd->obd_name, PFID(&op_data->op_fid1),
+				       rc);
+				/* save the errcode and proceed to close */
+				saved_rc = rc;
+			}
+		}
+		if (op_data->op_bias & MDS_CLOSE_RESYNC_DONE) {
+			size_t count = op_data->op_data_size / sizeof(u32);
 
-		/* allocate a FID for volatile file */
-		rc = mdc_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
-		if (rc < 0) {
-			CERROR("%s: " DFID " failed to allocate FID: %d\n",
-			       obd->obd_name, PFID(&op_data->op_fid1), rc);
-			/* save the errcode and proceed to close */
-			saved_rc = rc;
+			if (count > INLINE_RESYNC_ARRAY_SIZE)
+				u32_count = count;
 		}
-	} else if (op_data->op_bias & (MDS_CLOSE_LAYOUT_SWAP |
-				       MDS_CLOSE_LAYOUT_MERGE)) {
-		req_fmt = &RQF_MDS_INTENT_CLOSE;
 	} else {
 		req_fmt = &RQF_MDS_CLOSE;
 	}
@@ -818,6 +829,10 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		goto out;
 	}
 
+	if (u32_count > 0)
+		req_capsule_set_size(&req->rq_pill, &RMF_U32, RCL_CLIENT,
+				     u32_count * sizeof(u32));
+
 	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_CLOSE);
 	if (rc) {
 		ptlrpc_request_free(req);
@@ -2627,6 +2642,7 @@ int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
 	.setxattr		= mdc_setxattr,
 	.getxattr		= mdc_getxattr,
 	.fsync			= mdc_fsync,
+	.file_resync		= mdc_file_resync,
 	.read_page		= mdc_read_page,
 	.unlink			= mdc_unlink,
 	.cancel_unused		= mdc_cancel_unused,
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index d75f725..0545e23 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -296,6 +296,9 @@ int osc_io_commit_async(const struct lu_env *env,
 		opg = osc_cl_page_osc(page, osc);
 		oap = &opg->ops_oap;
 
+		LASSERTF(osc == oap->oap_obj,
+			 "obj mismatch: %p / %p\n", osc, oap->oap_obj);
+
 		if (!list_empty(&oap->oap_rpc_item)) {
 			CDEBUG(D_CACHE, "Busy oap %p page %p for submit.\n",
 			       oap, opg);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index b6476bc..ce1de5e 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -121,7 +121,8 @@
 	&RMF_MDT_EPOCH,
 	&RMF_REC_REINT,
 	&RMF_CAPA1,
-	&RMF_CLOSE_DATA
+	&RMF_CLOSE_DATA,
+	&RMF_U32
 };
 
 static const struct req_msg_field *obd_statfs_server[] = {
@@ -298,6 +299,12 @@
 	&RMF_DLM_REQ
 };
 
+static const struct req_msg_field *mds_reint_resync[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_REC_REINT,
+	&RMF_DLM_REQ
+};
+
 static const struct req_msg_field *mdt_swap_layouts[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_MDT_BODY,
@@ -713,6 +720,7 @@
 	&RQF_MDS_REINT_MIGRATE,
 	&RQF_MDS_REINT_SETATTR,
 	&RQF_MDS_REINT_SETXATTR,
+	&RQF_MDS_REINT_RESYNC,
 	&RQF_MDS_QUOTACTL,
 	&RQF_MDS_HSM_PROGRESS,
 	&RQF_MDS_HSM_CT_REGISTER,
@@ -842,7 +850,7 @@ struct req_msg_field RMF_MGS_CONFIG_RES =
 EXPORT_SYMBOL(RMF_MGS_CONFIG_RES);
 
 struct req_msg_field RMF_U32 =
-	DEFINE_MSGF("generic u32", 0,
+	DEFINE_MSGF("generic u32", RMF_F_STRUCT_ARRAY,
 		    sizeof(u32), lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_U32);
 
@@ -1343,6 +1351,10 @@ struct req_format RQF_MDS_REINT_SETXATTR =
 			mds_reint_setxattr_client, mdt_body_only);
 EXPORT_SYMBOL(RQF_MDS_REINT_SETXATTR);
 
+struct req_format RQF_MDS_REINT_RESYNC =
+	DEFINE_REQ_FMT0("MDS_REINT_RESYNC", mds_reint_resync, mdt_body_only);
+EXPORT_SYMBOL(RQF_MDS_REINT_RESYNC);
+
 struct req_format RQF_MDS_CONNECT =
 	DEFINE_REQ_FMT0("MDS_CONNECT",
 			obd_connect_client, obd_connect_server);
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 937a413..6ce4d9e 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -149,6 +149,7 @@
 	{ MDS_REINT_RENAME,			"mds_reint_rename" },
 	{ MDS_REINT_OPEN,			"mds_reint_open" },
 	{ MDS_REINT_SETXATTR,			"mds_reint_setxattr" },
+	{ MDS_REINT_RESYNC,			"mds_reint_resync" },
 	{ BRW_READ_BYTES,			"read_bytes" },
 	{ BRW_WRITE_BYTES,			"write_bytes" },
 };
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 0c73da6..e7662be 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2418,6 +2418,19 @@ void lustre_swab_close_data(struct close_data *cd)
 	__swab64s(&cd->cd_data_version);
 }
 
+void lustre_swab_close_data_resync_done(struct close_data_resync_done *resync)
+{
+	int i;
+
+	__swab32s(&resync->resync_count);
+	/* after swab, resync_count must in CPU endian */
+	if (resync->resync_count <= INLINE_RESYNC_ARRAY_SIZE) {
+		for (i = 0; i < resync->resync_count; i++)
+			__swab32s(&resync->resync_ids_inline[i]);
+	}
+}
+EXPORT_SYMBOL(lustre_swab_close_data_resync_done);
+
 void lustre_swab_ladvise(struct lu_ladvise *ladvise)
 {
 	swab16s(&ladvise->lla_advice);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 0b3c6af..ff3c79a 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -197,7 +197,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)REINT_RMENTRY);
 	LASSERTF(REINT_MIGRATE == 9, "found %lld\n",
 		 (long long)REINT_MIGRATE);
-	LASSERTF(REINT_MAX == 10, "found %lld\n",
+	LASSERTF(REINT_MAX == 11, "found %lld\n",
 		 (long long)REINT_MAX);
 	LASSERTF(DISP_IT_EXECD == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)DISP_IT_EXECD);
@@ -2697,6 +2697,98 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct mdt_rec_setxattr *)0)->sx_padding_11) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_setxattr *)0)->sx_padding_11));
 
+	/* Checks for struct mdt_rec_resync */
+	LASSERTF((int)sizeof(struct mdt_rec_resync) == 136, "found %lld\n",
+		 (long long)(int)sizeof(struct mdt_rec_resync));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_opcode) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_opcode));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_opcode) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_opcode));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_cap) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_cap));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_cap) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_cap));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_fsuid) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_fsuid));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_fsuid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_fsuid));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_fsuid_h) == 12, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_fsuid_h));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_fsuid_h) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_fsuid_h));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_fsgid) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_fsgid));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_fsgid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_fsgid));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_fsgid_h) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_fsgid_h));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_fsgid_h) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_fsgid_h));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_suppgid1) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_suppgid1));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid1) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid1));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_suppgid1_h) == 28, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_suppgid1_h));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid1_h) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid1_h));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_suppgid2) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_suppgid2));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid2) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid2));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_suppgid2_h) == 36, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_suppgid2_h));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid2_h) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_suppgid2_h));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_fid) == 40, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_fid));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_fid) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_fid));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding0) == 56, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding0));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding0) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding0));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding1) == 80, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding1));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding1) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding1));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding2) == 88, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding2));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding2));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding3) == 96, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding3));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding3) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding3));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding4) == 104, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding4));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding4) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding4));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_bias) == 112, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_bias));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_bias) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_bias));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding5) == 116, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding5));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding5) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding5));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding6) == 120, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding6));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding6) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding6));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding7) == 124, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding7));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding7) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding7));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding8) == 128, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding8));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding8) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding8));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding9) == 132, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding9));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding9) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding9));
+
 	/* Checks for struct mdt_rec_reint */
 	LASSERTF((int)sizeof(struct mdt_rec_reint) == 136, "found %lld\n",
 		 (long long)(int)sizeof(struct mdt_rec_reint));
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 27146a6..0692c98 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1396,6 +1396,7 @@ enum mdt_reint_cmd {
 	REINT_SETXATTR	= 7,
 	REINT_RMENTRY	= 8,
 	REINT_MIGRATE	= 9,
+	REINT_RESYNC	= 10,
 	REINT_MAX
 };
 
@@ -1671,11 +1672,12 @@ struct mdt_rec_setattr {
 					      * being opened with conflict mode.
 					      */
 #define MDS_OPEN_RELEASE   02000000000000ULL /* Open the file for HSM release */
+#define MDS_OPEN_RESYNC    04000000000000ULL /* FLR: file resync */
 
 #define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
 			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
 			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
-			      MDS_OPEN_RELEASE)
+			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC)
 
 enum mds_op_bias {
 	MDS_CHECK_SPLIT		= 1 << 0,
@@ -1694,10 +1696,11 @@ enum mds_op_bias {
 	MDS_RENAME_MIGRATE	= 1 << 13,
 	MDS_CLOSE_LAYOUT_SWAP	= 1 << 14,
 	MDS_CLOSE_LAYOUT_MERGE	= 1 << 15,
+	MDS_CLOSE_RESYNC_DONE	= 1 << 16,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |	\
-			  MDS_CLOSE_LAYOUT_MERGE)
+			  MDS_CLOSE_LAYOUT_MERGE | MDS_CLOSE_RESYNC_DONE)
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_create {
@@ -1840,6 +1843,35 @@ struct mdt_rec_setxattr {
 	__u32		sx_padding_11;	/* rr_padding_4 */
 };
 
+/* instance of mdt_reint_rec
+ * FLR: for file resync MDS_REINT_RESYNC RPC.
+ */
+struct mdt_rec_resync {
+	__u32           rs_opcode;
+	__u32           rs_cap;
+	__u32           rs_fsuid;
+	__u32           rs_fsuid_h;
+	__u32           rs_fsgid;
+	__u32           rs_fsgid_h;
+	__u32           rs_suppgid1;
+	__u32           rs_suppgid1_h;
+	__u32           rs_suppgid2;
+	__u32           rs_suppgid2_h;
+	struct lu_fid   rs_fid;
+	__u8		rs_padding0[sizeof(struct lu_fid)];
+	struct lustre_handle rs_handle;	/* rr_mtime */
+	__s64		rs_padding1;	/* rr_atime */
+	__s64		rs_padding2;	/* rr_ctime */
+	__u64           rs_padding3;	/* rr_size */
+	__u64           rs_padding4;	/* rr_blocks */
+	__u32           rs_bias;
+	__u32           rs_padding5;	/* rr_mode */
+	__u32           rs_padding6;	/* rr_flags */
+	__u32           rs_padding7;	/* rr_flags_h */
+	__u32           rs_padding8;	/* rr_umask */
+	__u32           rs_padding9;	/* rr_padding_4 */
+};
+
 /*
  * mdt_rec_reint is the template for all mdt_reint_xxx structures.
  * Do NOT change the size of various members, otherwise the value
@@ -2855,11 +2887,20 @@ struct mdc_swap_layouts {
 	__u64			msl_flags;
 } __packed;
 
+#define INLINE_RESYNC_ARRAY_SIZE	15
+struct close_data_resync_done {
+	__u32	resync_count;
+	__u32	resync_ids_inline[INLINE_RESYNC_ARRAY_SIZE];
+};
+
 struct close_data {
 	struct lustre_handle	cd_handle;
 	struct lu_fid		cd_fid;
 	__u64			cd_data_version;
-	__u64			cd_reserved[8];
+	union {
+		__u64				cd_reserved[8];
+		struct close_data_resync_done	cd_resync;
+	};
 };
 
 /*
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index f5cd979..779b9af 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -238,6 +238,31 @@ struct ll_futimes_3 {
 };
 
 /*
+ * Maximum number of mirrors currently implemented.
+ */
+#define LUSTRE_MIRROR_COUNT_MAX		16
+
+/* Lease types for use as arg and return of LL_IOC_{GET,SET}_LEASE ioctl. */
+enum ll_lease_mode {
+	LL_LEASE_RDLCK	= 0x01,
+	LL_LEASE_WRLCK	= 0x02,
+	LL_LEASE_UNLCK	= 0x04,
+};
+
+enum ll_lease_flags {
+	LL_LEASE_RESYNC		= 0x1,
+	LL_LEASE_RESYNC_DONE	= 0x2,
+};
+
+#define IOC_IDS_MAX	4096
+struct ll_ioc_lease {
+	__u32		lil_mode;
+	__u32		lil_flags;
+	__u32		lil_count;
+	__u32		lil_ids[0];
+};
+
+/*
  * The ioctl naming rules:
  * LL_*     - works on the currently opened filehandle instead of parent dir
  * *_OBD_*  - gets data for both OSC or MDC (LOV, LMV indirectly)
@@ -294,7 +319,8 @@ struct ll_futimes_3 {
 
 #define LL_IOC_LMV_SETSTRIPE		_IOWR('f', 240, struct lmv_user_md)
 #define LL_IOC_LMV_GETSTRIPE		_IOWR('f', 241, struct lmv_user_md)
-#define LL_IOC_SET_LEASE		_IOWR('f', 243, long)
+#define LL_IOC_SET_LEASE		_IOWR('f', 243, struct ll_ioc_lease)
+#define LL_IOC_SET_LEASE_OLD		_IOWR('f', 243, long)
 #define LL_IOC_GET_LEASE		_IO('f', 244)
 #define LL_IOC_HSM_IMPORT		_IOWR('f', 245, struct hsm_user_import)
 #define LL_IOC_LMV_SET_DEFAULT_STRIPE	_IOWR('f', 246, struct lmv_user_md)
@@ -303,13 +329,6 @@ struct ll_futimes_3 {
 #define LL_IOC_GETPARENT		_IOWR('f', 249, struct getparent)
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 
-/* Lease types for use as arg and return of LL_IOC_{GET,SET}_LEASE ioctl. */
-enum ll_lease_type {
-	LL_LEASE_RDLCK	= 0x1,
-	LL_LEASE_WRLCK	= 0x2,
-	LL_LEASE_UNLCK	= 0x4,
-};
-
 #define LL_STATFS_LMV		1
 #define LL_STATFS_LOV		2
 #define LL_STATFS_NODELAY	4
-- 
1.8.3.1
