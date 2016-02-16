From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:46 -0500
Subject: [lustre-devel] [PATCH 14/45] staging/lustre/llite: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-15-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

The only exception is ll_update_inode where dropping != NULL
in the construction below would break the logic.
I guess we could change lsm != NULL to !!lsm, but that's uglier.
(lsm != NULL) == ((body->valid & OBD_MD_FLEASIZE) != 0)

Also removed some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dcache.c       |  10 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  23 ++---
 drivers/staging/lustre/lustre/llite/file.c         | 115 ++++++++++-----------
 drivers/staging/lustre/lustre/llite/llite_close.c  |  14 +--
 .../staging/lustre/lustre/llite/llite_internal.h   |  25 +++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  61 ++++++-----
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  14 ++-
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c |  10 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |  17 ++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  12 +--
 drivers/staging/lustre/lustre/llite/namei.c        |  53 +++-------
 drivers/staging/lustre/lustre/llite/rw.c           |  23 ++---
 drivers/staging/lustre/lustre/llite/rw26.c         |  16 +--
 drivers/staging/lustre/lustre/llite/statahead.c    |  40 ++++---
 drivers/staging/lustre/lustre/llite/super25.c      |  10 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  16 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  12 +--
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   5 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  22 ++--
 drivers/staging/lustre/lustre/llite/xattr.c        |  21 ++--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  16 ++-
 22 files changed, 241 insertions(+), 297 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index bc179e5..34eb17c 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -60,7 +60,7 @@ static void ll_release(struct dentry *de)
 {
 	struct ll_dentry_data *lld;
 
-	LASSERT(de != NULL);
+	LASSERT(de);
 	lld = ll_d2d(de);
 	if (!lld) /* NFS copies the de->d_op methods (bug 4655) */
 		return;
@@ -178,8 +178,6 @@ static int ll_ddelete(const struct dentry *de)
 
 int ll_d_init(struct dentry *de)
 {
-	LASSERT(de != NULL);
-
 	CDEBUG(D_DENTRY, "ldd on dentry %pd (%p) parent %p inode %p refc %d\n",
 		de, de, de->d_parent, d_inode(de),
 		d_count(de));
@@ -251,8 +249,6 @@ void ll_invalidate_aliases(struct inode *inode)
 {
 	struct dentry *dentry;
 
-	LASSERT(inode != NULL);
-
 	CDEBUG(D_INODE, "marking dentries for ino %lu/%u(%p) invalid\n",
 	       inode->i_ino, inode->i_generation, inode);
 
@@ -286,9 +282,7 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
 {
-	LASSERT(it != NULL);
-
-	if (it->d.lustre.it_lock_mode && inode != NULL) {
+	if (it->d.lustre.it_lock_mode && inode) {
 		struct ll_sb_info *sbi = ll_i2sbi(inode);
 
 		CDEBUG(D_DLMTRACE, "setting l_data to inode %p (%lu/%u)\n",
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 36b1055..d7dc264 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -190,8 +190,6 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	} else if (rc == 0) {
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
 		/* Checked by mdc_readpage() */
-		LASSERT(body != NULL);
-
 		if (body->valid & OBD_MD_FLSIZE)
 			cl_isize_write(inode, body->size);
 
@@ -245,7 +243,7 @@ void ll_release_page(struct page *page, int remove)
 	kunmap(page);
 	if (remove) {
 		lock_page(page);
-		if (likely(page->mapping != NULL))
+		if (likely(page->mapping))
 			truncate_complete_page(page->mapping, page);
 		unlock_page(page);
 	}
@@ -393,7 +391,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 		CERROR("dir page locate: "DFID" at %llu: rc %ld\n",
 		       PFID(ll_inode2fid(dir)), lhash, PTR_ERR(page));
 		goto out_unlock;
-	} else if (page != NULL) {
+	} else if (page) {
 		/*
 		 * XXX nikita: not entirely correct handling of a corner case:
 		 * suppose hash chain of entries with hash value HASH crosses
@@ -499,7 +497,7 @@ int ll_dir_read(struct inode *inode, struct dir_context *ctx)
 			__u64 next;
 
 			dp = page_address(page);
-			for (ent = lu_dirent_start(dp); ent != NULL && !done;
+			for (ent = lu_dirent_start(dp); ent && !done;
 			     ent = lu_dirent_next(ent)) {
 				__u16	  type;
 				int	    namelen;
@@ -689,7 +687,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	struct obd_device *mgc = lsi->lsi_mgc;
 	int lum_size;
 
-	if (lump != NULL) {
+	if (lump) {
 		/*
 		 * This is coming from userspace, so should be in
 		 * local endian.  But the MDS would like it in little
@@ -725,7 +723,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (lump != NULL && lump->lmm_magic == cpu_to_le32(LMV_USER_MAGIC))
+	if (lump && lump->lmm_magic == cpu_to_le32(LMV_USER_MAGIC))
 		op_data->op_cli_flags |= CLI_SET_MEA;
 
 	/* swabbing is done in lov_setstripe() on server side */
@@ -812,7 +810,6 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	LASSERT(body != NULL);
 
 	lmmsize = body->eadatasize;
 
@@ -824,7 +821,6 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill,
 					   &RMF_MDT_MD, lmmsize);
-	LASSERT(lmm != NULL);
 
 	/*
 	 * This is coming from the MDS, so is probably in
@@ -1326,7 +1322,7 @@ out_free:
 			return rc;
 
 		data = (void *)buf;
-		if (data->ioc_inlbuf1 == NULL || data->ioc_inlbuf2 == NULL ||
+		if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
 		    data->ioc_inllen1 == 0 || data->ioc_inllen2 == 0) {
 			rc = -EINVAL;
 			goto lmv_out_free;
@@ -1461,7 +1457,7 @@ free_lmv:
 		if (request) {
 			body = req_capsule_server_get(&request->rq_pill,
 						      &RMF_MDT_BODY);
-			LASSERT(body != NULL);
+			LASSERT(body);
 		} else {
 			goto out_req;
 		}
@@ -1539,7 +1535,7 @@ out_req:
 			return rc;
 
 		lmm = libcfs_kvzalloc(lmmsize, GFP_NOFS);
-		if (lmm == NULL)
+		if (!lmm)
 			return -ENOMEM;
 		if (copy_from_user(lmm, lum, lmmsize)) {
 			rc = -EFAULT;
@@ -1688,7 +1684,6 @@ out_quotactl:
 	    if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 
-		LASSERT(fd != NULL);
 		rc = rct_add(&sbi->ll_rct, current_pid(), arg);
 		if (!rc)
 			fd->fd_flags |= LL_FILE_RMTACL;
@@ -1757,7 +1752,7 @@ out_quotactl:
 			return -E2BIG;
 
 		hur = libcfs_kvzalloc(totalsize, GFP_NOFS);
-		if (hur == NULL)
+		if (!hur)
 			return -ENOMEM;
 
 		/* Copy the whole struct */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 132d19b..8e854c8 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -65,7 +65,7 @@ static struct ll_file_data *ll_file_data_get(void)
 	struct ll_file_data *fd;
 
 	fd = kmem_cache_alloc(ll_file_data_slab, GFP_NOFS | __GFP_ZERO);
-	if (fd == NULL)
+	if (!fd)
 		return NULL;
 	fd->fd_write_failed = false;
 	return fd;
@@ -73,7 +73,7 @@ static struct ll_file_data *ll_file_data_get(void)
 
 static void ll_file_data_put(struct ll_file_data *fd)
 {
-	if (fd != NULL)
+	if (fd)
 		kmem_cache_free(ll_file_data_slab, fd);
 }
 
@@ -134,7 +134,7 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 	int epoch_close = 1;
 	int rc;
 
-	if (obd == NULL) {
+	if (!obd) {
 		/*
 		 * XXX: in case of LMV, is this correct to access
 		 * ->exp_handle?
@@ -153,7 +153,7 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 	}
 
 	ll_prepare_close(inode, op_data, och);
-	if (data_version != NULL) {
+	if (data_version) {
 		/* Pass in data_version implies release. */
 		op_data->op_bias |= MDS_HSM_RELEASE;
 		op_data->op_data_version = *data_version;
@@ -251,7 +251,7 @@ int ll_md_real_close(struct inode *inode, fmode_t fmode)
 	*och_p = NULL;
 	mutex_unlock(&lli->lli_och_mutex);
 
-	if (och != NULL) {
+	if (och) {
 		/* There might be a race and this handle may already
 		   be closed. */
 		rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp,
@@ -276,7 +276,7 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 	if (unlikely(fd->fd_flags & LL_FILE_GROUP_LOCKED))
 		ll_put_grouplock(inode, file, fd->fd_grouplock.cg_gid);
 
-	if (fd->fd_lease_och != NULL) {
+	if (fd->fd_lease_och) {
 		bool lease_broken;
 
 		/* Usually the lease is not released when the
@@ -288,7 +288,7 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 		fd->fd_lease_och = NULL;
 	}
 
-	if (fd->fd_och != NULL) {
+	if (fd->fd_och) {
 		rc = ll_close_inode_openhandle(md_exp, inode, fd->fd_och, NULL);
 		fd->fd_och = NULL;
 		goto out;
@@ -343,7 +343,6 @@ int ll_file_release(struct inode *inode, struct file *file)
 	if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 
-		LASSERT(fd != NULL);
 		if (unlikely(fd->fd_flags & LL_FILE_RMTACL)) {
 			fd->fd_flags &= ~LL_FILE_RMTACL;
 			rct_del(&sbi->ll_rct, current_pid());
@@ -355,7 +354,7 @@ int ll_file_release(struct inode *inode, struct file *file)
 	if (!is_root_inode(inode))
 		ll_stats_ops_tally(sbi, LPROC_LL_RELEASE, 1);
 	fd = LUSTRE_FPRIVATE(file);
-	LASSERT(fd != NULL);
+	LASSERT(fd);
 
 	/* The last ref on @file, maybe not the owner pid of statahead.
 	 * Different processes can open the same dir, "ll_opendir_key" means:
@@ -405,7 +404,7 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 	 * makes a good candidate for using OPEN lock */
 	/* If lmmsize & lmm are not 0, we are just setting stripe info
 	 * parameters. No need for the open lock */
-	if (lmm == NULL && lmmsize == 0) {
+	if (!lmm && lmmsize == 0) {
 		itp->it_flags |= MDS_OPEN_LOCK;
 		if (itp->it_flags & FMODE_WRITE)
 			opc = LUSTRE_OPC_CREATE;
@@ -492,7 +491,7 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 
 	LASSERT(!LUSTRE_FPRIVATE(file));
 
-	LASSERT(fd != NULL);
+	LASSERT(fd);
 
 	if (och) {
 		struct ptlrpc_request *req = it->d.lustre.it_data;
@@ -543,7 +542,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	file->private_data = NULL; /* prevent ll_local_open assertion */
 
 	fd = ll_file_data_get();
-	if (fd == NULL) {
+	if (!fd) {
 		rc = -ENOMEM;
 		goto out_openerr;
 	}
@@ -551,7 +550,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	fd->fd_file = file;
 	if (S_ISDIR(inode->i_mode)) {
 		spin_lock(&lli->lli_sa_lock);
-		if (lli->lli_opendir_key == NULL && lli->lli_sai == NULL &&
+		if (!lli->lli_opendir_key && !lli->lli_sai &&
 		    lli->lli_opendir_pid == 0) {
 			lli->lli_opendir_key = fd;
 			lli->lli_opendir_pid = current_pid();
@@ -752,7 +751,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	if (fmode != FMODE_WRITE && fmode != FMODE_READ)
 		return ERR_PTR(-EINVAL);
 
-	if (file != NULL) {
+	if (file) {
 		struct ll_inode_info *lli = ll_i2info(inode);
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 		struct obd_client_handle **och_p;
@@ -764,18 +763,18 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 		/* Get the openhandle of the file */
 		rc = -EBUSY;
 		mutex_lock(&lli->lli_och_mutex);
-		if (fd->fd_lease_och != NULL) {
+		if (fd->fd_lease_och) {
 			mutex_unlock(&lli->lli_och_mutex);
 			return ERR_PTR(rc);
 		}
 
-		if (fd->fd_och == NULL) {
+		if (!fd->fd_och) {
 			if (file->f_mode & FMODE_WRITE) {
-				LASSERT(lli->lli_mds_write_och != NULL);
+				LASSERT(lli->lli_mds_write_och);
 				och_p = &lli->lli_mds_write_och;
 				och_usecount = &lli->lli_open_fd_write_count;
 			} else {
-				LASSERT(lli->lli_mds_read_och != NULL);
+				LASSERT(lli->lli_mds_read_och);
 				och_p = &lli->lli_mds_read_och;
 				och_usecount = &lli->lli_open_fd_read_count;
 			}
@@ -790,7 +789,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 		if (rc < 0) /* more than 1 opener */
 			return ERR_PTR(rc);
 
-		LASSERT(fd->fd_och != NULL);
+		LASSERT(fd->fd_och);
 		old_handle = fd->fd_och->och_fh;
 	}
 
@@ -886,7 +885,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 	int rc;
 
 	lock = ldlm_handle2lock(&och->och_lease_handle);
-	if (lock != NULL) {
+	if (lock) {
 		lock_res_and_lock(lock);
 		cancelled = ldlm_is_cancel(lock);
 		unlock_res_and_lock(lock);
@@ -898,7 +897,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 
 	if (!cancelled)
 		ldlm_cli_cancel(&och->och_lease_handle, 0);
-	if (lease_broken != NULL)
+	if (lease_broken)
 		*lease_broken = cancelled;
 
 	rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp, inode, och,
@@ -914,7 +913,7 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 	struct obd_info	    oinfo = { };
 	int			rc;
 
-	LASSERT(lsm != NULL);
+	LASSERT(lsm);
 
 	oinfo.oi_md = lsm;
 	oinfo.oi_oa = obdo;
@@ -933,7 +932,7 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 	}
 
 	set = ptlrpc_prep_set();
-	if (set == NULL) {
+	if (!set) {
 		CERROR("can't allocate ptlrpc set\n");
 		rc = -ENOMEM;
 	} else {
@@ -1261,7 +1260,7 @@ static int ll_lov_recreate(struct inode *inode, struct ost_id *oi, u32 ost_idx)
 	struct lov_stripe_md *lsm = NULL, *lsm2;
 
 	oa = kmem_cache_alloc(obdo_cachep, GFP_NOFS | __GFP_ZERO);
-	if (oa == NULL)
+	if (!oa)
 		return -ENOMEM;
 
 	lsm = ccc_inode_lsm_get(inode);
@@ -1274,7 +1273,7 @@ static int ll_lov_recreate(struct inode *inode, struct ost_id *oi, u32 ost_idx)
 		   (lsm->lsm_stripe_count));
 
 	lsm2 = libcfs_kvzalloc(lsm_size, GFP_NOFS);
-	if (lsm2 == NULL) {
+	if (!lsm2) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1341,7 +1340,7 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	int rc = 0;
 
 	lsm = ccc_inode_lsm_get(inode);
-	if (lsm != NULL) {
+	if (lsm) {
 		ccc_inode_lsm_put(inode, lsm);
 		CDEBUG(D_IOCTL, "stripe already exists for ino %lu\n",
 		       inode->i_ino);
@@ -1401,7 +1400,6 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	LASSERT(body != NULL); /* checked by mdc_getattr_name */
 
 	lmmsize = body->eadatasize;
 
@@ -1412,7 +1410,6 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	}
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill, &RMF_MDT_MD, lmmsize);
-	LASSERT(lmm != NULL);
 
 	if ((lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V1)) &&
 	    (lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V3))) {
@@ -1469,7 +1466,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 		return -EPERM;
 
 	lump = libcfs_kvzalloc(lum_size, GFP_NOFS);
-	if (lump == NULL)
+	if (!lump)
 		return -ENOMEM;
 
 	if (copy_from_user(lump, (struct lov_user_md __user *)arg, lum_size)) {
@@ -1530,7 +1527,7 @@ static int ll_lov_getstripe(struct inode *inode, unsigned long arg)
 	int rc = -ENODATA;
 
 	lsm = ccc_inode_lsm_get(inode);
-	if (lsm != NULL)
+	if (lsm)
 		rc = obd_iocontrol(LL_IOC_LOV_GETSTRIPE, ll_i2dtexp(inode), 0,
 				   lsm, (void __user *)arg);
 	ccc_inode_lsm_put(inode, lsm);
@@ -1560,7 +1557,7 @@ ll_get_grouplock(struct inode *inode, struct file *file, unsigned long arg)
 		spin_unlock(&lli->lli_lock);
 		return -EINVAL;
 	}
-	LASSERT(fd->fd_grouplock.cg_lock == NULL);
+	LASSERT(!fd->fd_grouplock.cg_lock);
 	spin_unlock(&lli->lli_lock);
 
 	rc = cl_get_grouplock(cl_i2info(inode)->lli_clob,
@@ -1597,7 +1594,7 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 		CWARN("no group lock held\n");
 		return -EINVAL;
 	}
-	LASSERT(fd->fd_grouplock.cg_lock != NULL);
+	LASSERT(fd->fd_grouplock.cg_lock);
 
 	if (fd->fd_grouplock.cg_gid != arg) {
 		CWARN("group lock %lu doesn't match current id %lu\n",
@@ -1688,7 +1685,7 @@ static int ll_do_fiemap(struct inode *inode, struct ll_user_fiemap *fiemap,
 	}
 
 	lsm = ccc_inode_lsm_get(inode);
-	if (lsm == NULL)
+	if (!lsm)
 		return -ENOENT;
 
 	/* If the stripe_count > 1 and the application does not understand
@@ -1794,7 +1791,7 @@ static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
 					 sizeof(struct ll_fiemap_extent));
 
 	fiemap_s = libcfs_kvzalloc(num_bytes, GFP_NOFS);
-	if (fiemap_s == NULL)
+	if (!fiemap_s)
 		return -ENOMEM;
 
 	/* get the fiemap value */
@@ -1923,7 +1920,7 @@ int ll_hsm_release(struct inode *inode)
 	och = NULL;
 
 out:
-	if (och != NULL && !IS_ERR(och)) /* close the file */
+	if (och && !IS_ERR(och)) /* close the file */
 		ll_lease_close(och, inode, NULL);
 
 	return rc;
@@ -2250,7 +2247,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return -EPERM;
 
 		file2 = fget(lsl.sl_fd);
-		if (file2 == NULL)
+		if (!file2)
 			return -EBADF;
 
 		rc = -EPERM;
@@ -2413,13 +2410,13 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			break;
 		case F_UNLCK:
 			mutex_lock(&lli->lli_och_mutex);
-			if (fd->fd_lease_och != NULL) {
+			if (fd->fd_lease_och) {
 				och = fd->fd_lease_och;
 				fd->fd_lease_och = NULL;
 			}
 			mutex_unlock(&lli->lli_och_mutex);
 
-			if (och != NULL) {
+			if (och) {
 				mode = och->och_flags &
 				       (FMODE_READ|FMODE_WRITE);
 				rc = ll_lease_close(och, inode, &lease_broken);
@@ -2444,12 +2441,12 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		rc = 0;
 		mutex_lock(&lli->lli_och_mutex);
-		if (fd->fd_lease_och == NULL) {
+		if (!fd->fd_lease_och) {
 			fd->fd_lease_och = och;
 			och = NULL;
 		}
 		mutex_unlock(&lli->lli_och_mutex);
-		if (och != NULL) {
+		if (och) {
 			/* impossible now that only excl is supported for now */
 			ll_lease_close(och, inode, &lease_broken);
 			rc = -EBUSY;
@@ -2462,11 +2459,11 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		rc = 0;
 		mutex_lock(&lli->lli_och_mutex);
-		if (fd->fd_lease_och != NULL) {
+		if (fd->fd_lease_och) {
 			struct obd_client_handle *och = fd->fd_lease_och;
 
 			lock = ldlm_handle2lock(&och->och_lease_handle);
-			if (lock != NULL) {
+			if (lock) {
 				lock_res_and_lock(lock);
 				if (!ldlm_is_cancel(lock))
 					rc = och->och_flags &
@@ -2867,8 +2864,6 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 	struct obd_export *exp;
 	int rc = 0;
 
-	LASSERT(inode != NULL);
-
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p),name=%pd\n",
 	       inode->i_ino, inode->i_generation, inode, dentry);
 
@@ -3027,7 +3022,7 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 				       sizeof(struct ll_fiemap_extent));
 	fiemap = libcfs_kvzalloc(num_bytes, GFP_NOFS);
 
-	if (fiemap == NULL)
+	if (!fiemap)
 		return -ENOMEM;
 
 	fiemap->fm_flags = fieinfo->fi_flags;
@@ -3181,8 +3176,7 @@ void *ll_iocontrol_register(llioc_callback_t cb, int count, unsigned int *cmd)
 	unsigned int size;
 	struct llioc_data *in_data = NULL;
 
-	if (cb == NULL || cmd == NULL ||
-	    count > LLIOC_MAX_CMD || count < 0)
+	if (!cb || !cmd || count > LLIOC_MAX_CMD || count < 0)
 		return NULL;
 
 	size = sizeof(*in_data) + count * sizeof(unsigned int);
@@ -3208,7 +3202,7 @@ void ll_iocontrol_unregister(void *magic)
 {
 	struct llioc_data *tmp;
 
-	if (magic == NULL)
+	if (!magic)
 		return;
 
 	down_write(&llioc.ioc_sem);
@@ -3262,7 +3256,7 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 	struct lu_env *env;
 	int result;
 
-	if (lli->lli_clob == NULL)
+	if (!lli->lli_clob)
 		return 0;
 
 	env = cl_env_nested_get(&nest);
@@ -3275,7 +3269,7 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 	if (conf->coc_opc == OBJECT_CONF_SET) {
 		struct ldlm_lock *lock = conf->coc_lock;
 
-		LASSERT(lock != NULL);
+		LASSERT(lock);
 		LASSERT(ldlm_has_layout(lock));
 		if (result == 0) {
 			/* it can only be allowed to match after layout is
@@ -3304,7 +3298,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	       PFID(ll_inode2fid(inode)), !!(lock->l_flags & LDLM_FL_LVB_READY),
 	       lock->l_lvb_data, lock->l_lvb_len);
 
-	if ((lock->l_lvb_data != NULL) && (lock->l_flags & LDLM_FL_LVB_READY))
+	if (lock->l_lvb_data && (lock->l_flags & LDLM_FL_LVB_READY))
 		return 0;
 
 	/* if layout lock was granted right away, the layout is returned
@@ -3321,7 +3315,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 		return rc;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -3333,20 +3327,20 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	}
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA, lmmsize);
-	if (lmm == NULL) {
+	if (!lmm) {
 		rc = -EFAULT;
 		goto out;
 	}
 
 	lvbdata = libcfs_kvzalloc(lmmsize, GFP_NOFS);
-	if (lvbdata == NULL) {
+	if (!lvbdata) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	memcpy(lvbdata, lmm, lmmsize);
 	lock_res_and_lock(lock);
-	if (lock->l_lvb_data != NULL)
+	if (lock->l_lvb_data)
 		kvfree(lock->l_lvb_data);
 
 	lock->l_lvb_data = lvbdata;
@@ -3377,7 +3371,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, ldlm_mode_t mode,
 	LASSERT(lustre_handle_is_used(lockh));
 
 	lock = ldlm_handle2lock(lockh);
-	LASSERT(lock != NULL);
+	LASSERT(lock);
 	LASSERT(ldlm_has_layout(lock));
 
 	LDLM_DEBUG(lock, "File %p/"DFID" being reconfigured: %d.\n",
@@ -3410,12 +3404,12 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, ldlm_mode_t mode,
 	 * lvb_data is immutable if the lock is held so it's safe to access it
 	 * without res lock. See the description in ldlm_lock_decref_internal()
 	 * for the condition to free lvb_data of layout lock */
-	if (lock->l_lvb_data != NULL) {
+	if (lock->l_lvb_data) {
 		rc = obd_unpackmd(sbi->ll_dt_exp, &md.lsm,
 				  lock->l_lvb_data, lock->l_lvb_len);
 		if (rc >= 0) {
 			*gen = LL_LAYOUT_GEN_EMPTY;
-			if (md.lsm != NULL)
+			if (md.lsm)
 				*gen = md.lsm->lsm_layout_gen;
 			rc = 0;
 		} else {
@@ -3436,7 +3430,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, ldlm_mode_t mode,
 	conf.u.coc_md = &md;
 	rc = ll_layout_conf(inode, &conf);
 
-	if (md.lsm != NULL)
+	if (md.lsm)
 		obd_free_memmd(sbi->ll_dt_exp, &md.lsm);
 
 	/* refresh layout failed, need to wait */
@@ -3537,8 +3531,7 @@ again:
 
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, &it, op_data, &lockh,
 			NULL, 0, NULL, 0);
-	if (it.d.lustre.it_data != NULL)
-		ptlrpc_req_finished(it.d.lustre.it_data);
+	ptlrpc_req_finished(it.d.lustre.it_data);
 	it.d.lustre.it_data = NULL;
 
 	ll_finish_md_op_data(op_data);
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 3f348a3..626846e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -52,7 +52,7 @@ void vvp_write_pending(struct ccc_object *club, struct ccc_page *page)
 
 	spin_lock(&lli->lli_lock);
 	lli->lli_flags |= LLIF_SOM_DIRTY;
-	if (page != NULL && list_empty(&page->cpg_pending_linkage))
+	if (page && list_empty(&page->cpg_pending_linkage))
 		list_add(&page->cpg_pending_linkage,
 			     &club->cob_pending_list);
 	spin_unlock(&lli->lli_lock);
@@ -65,7 +65,7 @@ void vvp_write_complete(struct ccc_object *club, struct ccc_page *page)
 	int rc = 0;
 
 	spin_lock(&lli->lli_lock);
-	if (page != NULL && !list_empty(&page->cpg_pending_linkage)) {
+	if (page && !list_empty(&page->cpg_pending_linkage)) {
 		list_del_init(&page->cpg_pending_linkage);
 		rc = 1;
 	}
@@ -144,8 +144,8 @@ void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
 	spin_lock(&lli->lli_lock);
 	if (!(list_empty(&club->cob_pending_list))) {
 		if (!(lli->lli_flags & LLIF_EPOCH_PENDING)) {
-			LASSERT(*och != NULL);
-			LASSERT(lli->lli_pending_och == NULL);
+			LASSERT(*och);
+			LASSERT(!lli->lli_pending_och);
 			/* Inode is dirty and there is no pending write done
 			 * request yet, DONE_WRITE is to be sent later. */
 			lli->lli_flags |= LLIF_EPOCH_PENDING;
@@ -215,7 +215,7 @@ int ll_som_update(struct inode *inode, struct md_op_data *op_data)
 	struct obdo *oa;
 	int rc;
 
-	LASSERT(op_data != NULL);
+	LASSERT(op_data);
 	if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
 		CERROR("ino %lu/%u(flags %u) som valid it just after recovery\n",
 		       inode->i_ino, inode->i_generation,
@@ -266,7 +266,7 @@ static void ll_prepare_done_writing(struct inode *inode,
 {
 	ll_ioepoch_close(inode, op_data, och, LLIF_DONE_WRITING);
 	/* If there is no @och, we do not do D_W yet. */
-	if (*och == NULL)
+	if (!*och)
 		return;
 
 	ll_pack_inode2opdata(inode, op_data, &(*och)->och_fh);
@@ -289,7 +289,7 @@ static void ll_done_writing(struct inode *inode)
 
 	ll_prepare_done_writing(inode, op_data, &och);
 	/* If there is no @och, we do not do D_W yet. */
-	if (och == NULL)
+	if (!och)
 		goto out;
 
 	rc = md_done_writing(ll_i2sbi(inode)->ll_md_exp, op_data, NULL);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 29c325d..7dbe86a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -913,7 +913,7 @@ static inline struct vvp_thread_info *vvp_env_info(const struct lu_env *env)
 	struct vvp_thread_info      *info;
 
 	info = lu_context_key_get(&env->le_ctx, &vvp_key);
-	LASSERT(info != NULL);
+	LASSERT(info);
 	return info;
 }
 
@@ -937,7 +937,7 @@ static inline struct vvp_session *vvp_env_session(const struct lu_env *env)
 	struct vvp_session *ses;
 
 	ses = lu_context_key_get(env->le_ses, &vvp_session_key);
-	LASSERT(ses != NULL);
+	LASSERT(ses);
 	return ses;
 }
 
@@ -968,7 +968,7 @@ static inline void ll_invalidate_page(struct page *vmpage)
 	loff_t offset = vmpage->index << PAGE_CACHE_SHIFT;
 
 	LASSERT(PageLocked(vmpage));
-	if (mapping == NULL)
+	if (!mapping)
 		return;
 
 	ll_teardown_mmaps(mapping, offset, offset + PAGE_CACHE_SIZE);
@@ -993,7 +993,7 @@ static inline struct client_obd *sbi2mdc(struct ll_sb_info *sbi)
 {
 	struct obd_device *obd = sbi->ll_md_exp->exp_obd;
 
-	if (obd == NULL)
+	if (!obd)
 		LBUG();
 	return &obd->u.cli;
 }
@@ -1018,7 +1018,7 @@ static inline struct lu_fid *ll_inode2fid(struct inode *inode)
 {
 	struct lu_fid *fid;
 
-	LASSERT(inode != NULL);
+	LASSERT(inode);
 	fid = &ll_i2info(inode)->lli_fid;
 
 	return fid;
@@ -1171,8 +1171,8 @@ ll_statahead_mark(struct inode *dir, struct dentry *dentry)
 	if (lli->lli_opendir_pid != current_pid())
 		return;
 
-	LASSERT(ldd != NULL);
-	if (sai != NULL)
+	LASSERT(ldd);
+	if (sai)
 		ldd->lld_sa_generation = sai->sai_generation;
 }
 
@@ -1191,7 +1191,7 @@ d_need_statahead(struct inode *dir, struct dentry *dentryp)
 		return -EAGAIN;
 
 	/* statahead has been stopped */
-	if (lli->lli_opendir_key == NULL)
+	if (!lli->lli_opendir_key)
 		return -EAGAIN;
 
 	ldd = ll_d2d(dentryp);
@@ -1345,7 +1345,6 @@ static inline int ll_file_nolock(const struct file *file)
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct inode *inode = file_inode(file);
 
-	LASSERT(fd != NULL);
 	return ((fd->fd_flags & LL_FILE_IGNORE_LOCK) ||
 		(ll_i2sbi(inode)->ll_flags & LL_SBI_NOLCK));
 }
@@ -1383,7 +1382,7 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		it->d.lustre.it_lock_set = 1;
 	}
 
-	if (bits != NULL)
+	if (bits)
 		*bits = it->d.lustre.it_lock_bits;
 }
 
@@ -1401,14 +1400,14 @@ static inline int d_lustre_invalid(const struct dentry *dentry)
 {
 	struct ll_dentry_data *lld = ll_d2d(dentry);
 
-	return (lld == NULL) || lld->lld_invalid;
+	return !lld || lld->lld_invalid;
 }
 
 static inline void __d_lustre_invalidate(struct dentry *dentry)
 {
 	struct ll_dentry_data *lld = ll_d2d(dentry);
 
-	if (lld != NULL)
+	if (lld)
 		lld->lld_invalid = 1;
 }
 
@@ -1442,7 +1441,7 @@ static inline void d_lustre_invalidate(struct dentry *dentry, int nested)
 static inline void d_lustre_revalidate(struct dentry *dentry)
 {
 	spin_lock(&dentry->d_lock);
-	LASSERT(ll_d2d(dentry) != NULL);
+	LASSERT(ll_d2d(dentry));
 	ll_d2d(dentry)->lld_invalid = 0;
 	spin_unlock(&dentry->d_lock);
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 446e4b8..4de085d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -171,7 +171,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 		return -ENOMEM;
 	}
 
-	if (llite_root != NULL) {
+	if (llite_root) {
 		err = ldebugfs_register_mountpoint(llite_root, sb, dt, md);
 		if (err < 0)
 			CERROR("could not register mount in <debugfs>/lustre/llite\n");
@@ -493,7 +493,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	md_free_lustre_md(sbi->ll_md_exp, &lmd);
 	ptlrpc_req_finished(request);
 
-	if (root == NULL || IS_ERR(root)) {
+	if (IS_ERR_OR_NULL(root)) {
 		if (lmd.lsm)
 			obd_free_memmd(sbi->ll_dt_exp, &lmd.lsm);
 #ifdef CONFIG_FS_POSIX_ACL
@@ -532,7 +532,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				 &sbi->ll_cache, NULL);
 
 	sb->s_root = d_make_root(root);
-	if (sb->s_root == NULL) {
+	if (!sb->s_root) {
 		CERROR("%s: can't make root dentry\n",
 			ll_get_fsname(sb, NULL, 0));
 		err = -ENOMEM;
@@ -547,7 +547,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	/* s_dev is also used in lt_compare() to compare two fs, but that is
 	 * only a node-local comparison. */
 	uuid = obd_get_uuid(sbi->ll_md_exp);
-	if (uuid != NULL) {
+	if (uuid) {
 		sb->s_dev = get_uuid2int(uuid->uuid, strlen(uuid->uuid));
 		get_uuid2fsid(uuid->uuid, strlen(uuid->uuid), &sbi->ll_fsid);
 	}
@@ -777,7 +777,7 @@ static int ll_options(char *options, int *flags)
 next:
 		/* Find next opt */
 		s2 = strchr(s1, ',');
-		if (s2 == NULL)
+		if (!s2)
 			break;
 		s1 = s2 + 1;
 	}
@@ -904,7 +904,7 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 
 	/* Profile set with LCFG_MOUNTOPT so we can find our mdc and osc obds */
 	lprof = class_get_profile(profilenm);
-	if (lprof == NULL) {
+	if (!lprof) {
 		LCONSOLE_ERROR_MSG(0x156, "The client profile '%s' could not be read from the MGS.  Does that filesystem exist?\n",
 				   profilenm);
 		err = -EINVAL;
@@ -1036,8 +1036,8 @@ void ll_clear_inode(struct inode *inode)
 
 	if (S_ISDIR(inode->i_mode)) {
 		/* these should have been cleared in ll_file_release */
-		LASSERT(lli->lli_opendir_key == NULL);
-		LASSERT(lli->lli_sai == NULL);
+		LASSERT(!lli->lli_opendir_key);
+		LASSERT(!lli->lli_sai);
 		LASSERT(lli->lli_opendir_pid == 0);
 	}
 
@@ -1065,7 +1065,7 @@ void ll_clear_inode(struct inode *inode)
 	ll_xattr_cache_destroy(inode);
 
 	if (sbi->ll_flags & LL_SBI_RMT_CLIENT) {
-		LASSERT(lli->lli_posix_acl == NULL);
+		LASSERT(!lli->lli_posix_acl);
 		if (lli->lli_remote_perms) {
 			free_rmtperm_hash(lli->lli_remote_perms);
 			lli->lli_remote_perms = NULL;
@@ -1074,7 +1074,7 @@ void ll_clear_inode(struct inode *inode)
 #ifdef CONFIG_FS_POSIX_ACL
 	else if (lli->lli_posix_acl) {
 		LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) == 1);
-		LASSERT(lli->lli_remote_perms == NULL);
+		LASSERT(!lli->lli_remote_perms);
 		posix_acl_release(lli->lli_posix_acl);
 		lli->lli_posix_acl = NULL;
 	}
@@ -1161,7 +1161,6 @@ static int ll_setattr_done_writing(struct inode *inode,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc = 0;
 
-	LASSERT(op_data != NULL);
 	if (!S_ISREG(inode->i_mode))
 		return 0;
 
@@ -1514,7 +1513,7 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
 	LASSERT((lsm != NULL) == ((body->valid & OBD_MD_FLEASIZE) != 0));
-	if (lsm != NULL) {
+	if (lsm) {
 		if (!lli->lli_has_smd &&
 		    !(sbi->ll_flags & LL_SBI_LAYOUT_LOCK))
 			cl_file_inode_init(inode, md);
@@ -1689,7 +1688,7 @@ void ll_delete_inode(struct inode *inode)
 {
 	struct cl_inode_info *lli = cl_i2info(inode);
 
-	if (S_ISREG(inode->i_mode) && lli->lli_clob != NULL)
+	if (S_ISREG(inode->i_mode) && lli->lli_clob)
 		/* discard all dirty pages before truncating them, required by
 		 * osc_extent implementation at LU-1030. */
 		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF,
@@ -1831,7 +1830,7 @@ void ll_umount_begin(struct super_block *sb)
 	       sb->s_count, atomic_read(&sb->s_active));
 
 	obd = class_exp2obd(sbi->ll_md_exp);
-	if (obd == NULL) {
+	if (!obd) {
 		CERROR("Invalid MDC connection handle %#llx\n",
 		       sbi->ll_md_exp->exp_handle.h_cookie);
 		return;
@@ -1839,7 +1838,7 @@ void ll_umount_begin(struct super_block *sb)
 	obd->obd_force = 1;
 
 	obd = class_exp2obd(sbi->ll_dt_exp);
-	if (obd == NULL) {
+	if (!obd) {
 		CERROR("Invalid LOV connection handle %#llx\n",
 		       sbi->ll_dt_exp->exp_handle.h_cookie);
 		return;
@@ -1954,7 +1953,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	if (*inode) {
 		ll_update_inode(*inode, &md);
 	} else {
-		LASSERT(sb != NULL);
+		LASSERT(sb);
 
 		/*
 		 * At this point server returns to client's same fid as client
@@ -1965,7 +1964,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->fid1,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
 				 &md);
-		if (*inode == NULL || IS_ERR(*inode)) {
+		if (IS_ERR_OR_NULL(*inode)) {
 #ifdef CONFIG_FS_POSIX_ACL
 			if (md.posix_acl) {
 				posix_acl_release(md.posix_acl);
@@ -1987,13 +1986,13 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	 * 2. layout was changed by another client
 	 * 3. proc2: refresh layout and layout lock granted
 	 * 4. proc1: to apply a stale layout */
-	if (it != NULL && it->d.lustre.it_lock_mode != 0) {
+	if (it && it->d.lustre.it_lock_mode != 0) {
 		struct lustre_handle lockh;
 		struct ldlm_lock *lock;
 
 		lockh.cookie = it->d.lustre.it_lock_handle;
 		lock = ldlm_handle2lock(&lockh);
-		LASSERT(lock != NULL);
+		LASSERT(lock);
 		if (ldlm_has_layout(lock)) {
 			struct cl_object_conf conf;
 
@@ -2008,7 +2007,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	}
 
 out:
-	if (md.lsm != NULL)
+	if (md.lsm)
 		obd_free_memmd(sbi->ll_dt_exp, &md.lsm);
 	md_free_lustre_md(sbi->ll_md_exp, &md);
 
@@ -2113,15 +2112,13 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				       const char *name, int namelen,
 				       int mode, __u32 opc, void *data)
 {
-	LASSERT(i1 != NULL);
-
 	if (namelen > ll_i2sbi(i1)->ll_namelen)
 		return ERR_PTR(-ENAMETOOLONG);
 
-	if (op_data == NULL)
+	if (!op_data)
 		op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
 
-	if (op_data == NULL)
+	if (!op_data)
 		return ERR_PTR(-ENOMEM);
 
 	ll_i2gids(op_data->op_suppgids, i1, i2);
@@ -2141,8 +2138,8 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_cap = cfs_curproc_cap_pack();
 	op_data->op_bias = 0;
 	op_data->op_cli_flags = 0;
-	if ((opc == LUSTRE_OPC_CREATE) && (name != NULL) &&
-	     filename_is_volatile(name, namelen, NULL))
+	if ((opc == LUSTRE_OPC_CREATE) && name &&
+	    filename_is_volatile(name, namelen, NULL))
 		op_data->op_bias |= MDS_CREATE_VOLATILE;
 	op_data->op_opc = opc;
 	op_data->op_mds = 0;
@@ -2177,7 +2174,7 @@ int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 {
 	struct ll_sb_info *sbi;
 
-	LASSERT((seq != NULL) && (dentry != NULL));
+	LASSERT(seq && dentry);
 	sbi = ll_s2sbi(dentry->d_sb);
 
 	if (sbi->ll_flags & LL_SBI_NOLCK)
@@ -2238,7 +2235,7 @@ char *ll_get_fsname(struct super_block *sb, char *buf, int buflen)
 	char *ptr;
 	int len;
 
-	if (buf == NULL) {
+	if (!buf) {
 		/* this means the caller wants to use static buffer
 		 * and it doesn't care about race. Usually this is
 		 * in error reporting path */
@@ -2267,9 +2264,9 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 
 	/* this can be called inside spin lock so use GFP_ATOMIC. */
 	buf = (char *)__get_free_page(GFP_ATOMIC);
-	if (buf != NULL) {
+	if (buf) {
 		dentry = d_find_alias(page->mapping->host);
-		if (dentry != NULL)
+		if (dentry)
 			path = dentry_path_raw(dentry, buf, PAGE_SIZE);
 	}
 
@@ -2280,9 +2277,9 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	       PFID(&obj->cob_header.coh_lu.loh_fid),
 	       (path && !IS_ERR(path)) ? path : "", ioret);
 
-	if (dentry != NULL)
+	if (dentry)
 		dput(dentry);
 
-	if (buf != NULL)
+	if (buf)
 		free_page((unsigned long)buf);
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index bbae95c..a0a58fd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -72,7 +72,7 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 	LASSERT(!down_write_trylock(&mm->mmap_sem));
 
 	for (vma = find_vma(mm, addr);
-	    vma != NULL && vma->vm_start < (addr + count); vma = vma->vm_next) {
+	    vma && vma->vm_start < (addr + count); vma = vma->vm_next) {
 		if (vma->vm_ops && vma->vm_ops == &ll_file_vm_ops &&
 		    vma->vm_flags & VM_SHARED) {
 			ret = vma;
@@ -125,7 +125,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 
 	io = ccc_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
-	LASSERT(io->ci_obj != NULL);
+	LASSERT(io->ci_obj);
 
 	fio = &io->u.ci_fault;
 	fio->ft_index      = index;
@@ -136,7 +136,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 	 * the kernel will not read other pages not covered by ldlm in
 	 * filemap_nopage. we do our readahead in ll_readpage.
 	 */
-	if (ra_flags != NULL)
+	if (ra_flags)
 		*ra_flags = vma->vm_flags & (VM_RAND_READ|VM_SEQ_READ);
 	vma->vm_flags &= ~VM_SEQ_READ;
 	vma->vm_flags |= VM_RAND_READ;
@@ -178,8 +178,6 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	struct inode	     *inode;
 	struct ll_inode_info     *lli;
 
-	LASSERT(vmpage != NULL);
-
 	io = ll_fault_io_init(vma, &env,  &nest, vmpage->index, NULL);
 	if (IS_ERR(io)) {
 		result = PTR_ERR(io);
@@ -217,7 +215,7 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 		struct ll_inode_info *lli = ll_i2info(inode);
 
 		lock_page(vmpage);
-		if (vmpage->mapping == NULL) {
+		if (!vmpage->mapping) {
 			unlock_page(vmpage);
 
 			/* page was truncated and lock was cancelled, return
@@ -320,7 +318,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 			fault_ret = vio->u.fault.fault.ft_flags;
 
 		vmpage = vio->u.fault.ft_vmpage;
-		if (result != 0 && vmpage != NULL) {
+		if (result != 0 && vmpage) {
 			page_cache_release(vmpage);
 			vmf->page = NULL;
 		}
@@ -357,7 +355,7 @@ restart:
 
 		/* check if this page has been truncated */
 		lock_page(vmpage);
-		if (unlikely(vmpage->mapping == NULL)) { /* unlucky */
+		if (unlikely(!vmpage->mapping)) { /* unlucky */
 			unlock_page(vmpage);
 			page_cache_release(vmpage);
 			vmf->page = NULL;
diff --git a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
index b27c3f2..63e4847 100644
--- a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
+++ b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
@@ -125,12 +125,12 @@ int rct_add(struct rmtacl_ctl_table *rct, pid_t key, int ops)
 	struct rmtacl_ctl_entry *rce, *e;
 
 	rce = rce_alloc(key, ops);
-	if (rce == NULL)
+	if (!rce)
 		return -ENOMEM;
 
 	spin_lock(&rct->rct_lock);
 	e = __rct_search(rct, key);
-	if (unlikely(e != NULL)) {
+	if (unlikely(e)) {
 		CWARN("Unexpected stale rmtacl_entry found: [key: %d] [ops: %d]\n",
 		      (int)key, ops);
 		rce_free(e);
@@ -213,7 +213,7 @@ static struct eacl_entry *__et_search_del(struct eacl_table *et, pid_t key,
 	struct eacl_entry *ee;
 	struct list_head *head = &et->et_entries[ee_hashfunc(key)];
 
-	LASSERT(fid != NULL);
+	LASSERT(fid);
 	list_for_each_entry(ee, head, ee_list)
 		if (ee->ee_key == key) {
 			if (lu_fid_eq(&ee->ee_fid, fid) &&
@@ -256,12 +256,12 @@ int ee_add(struct eacl_table *et, pid_t key, struct lu_fid *fid, int type,
 	struct eacl_entry *ee, *e;
 
 	ee = ee_alloc(key, fid, type, header);
-	if (ee == NULL)
+	if (!ee)
 		return -ENOMEM;
 
 	spin_lock(&et->et_lock);
 	e = __et_search_del(et, key, fid, type);
-	if (unlikely(e != NULL)) {
+	if (unlikely(e)) {
 		CWARN("Unexpected stale eacl_entry found: [key: %d] [fid: " DFID "] [type: %d]\n",
 		      (int)key, PFID(fid), type);
 		ee_free(e);
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 69c41af..20fecaf 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -211,9 +211,8 @@ static int do_bio_lustrebacked(struct lloop_device *lo, struct bio *head)
 		return io->ci_result;
 	io->ci_lockreq = CILR_NEVER;
 
-	LASSERT(head != NULL);
 	rw = head->bi_rw;
-	for (bio = head; bio != NULL; bio = bio->bi_next) {
+	for (bio = head; bio ; bio = bio->bi_next) {
 		LASSERT(rw == bio->bi_rw);
 
 		offset = (pgoff_t)(bio->bi_iter.bi_sector << 9) + lo->lo_offset;
@@ -297,7 +296,7 @@ static unsigned int loop_get_bio(struct lloop_device *lo, struct bio **req)
 
 	spin_lock_irq(&lo->lo_lock);
 	first = lo->lo_bio;
-	if (unlikely(first == NULL)) {
+	if (unlikely(!first)) {
 		spin_unlock_irq(&lo->lo_lock);
 		return 0;
 	}
@@ -458,7 +457,7 @@ static int loop_thread(void *data)
 			       total_count, times, total_count / times);
 		}
 
-		LASSERT(bio != NULL);
+		LASSERT(bio);
 		LASSERT(count <= atomic_read(&lo->lo_pending));
 		loop_handle_bio(lo, bio);
 		atomic_sub(count, &lo->lo_pending);
@@ -560,7 +559,7 @@ static int loop_clr_fd(struct lloop_device *lo, struct block_device *bdev,
 	if (lo->lo_refcnt > count)	/* we needed one fd for the ioctl */
 		return -EBUSY;
 
-	if (filp == NULL)
+	if (!filp)
 		return -EINVAL;
 
 	spin_lock_irq(&lo->lo_lock);
@@ -625,11 +624,11 @@ static int lo_ioctl(struct block_device *bdev, fmode_t mode,
 	case LL_IOC_LLOOP_INFO: {
 		struct lu_fid fid;
 
-		if (lo->lo_backing_file == NULL) {
+		if (!lo->lo_backing_file) {
 			err = -ENOENT;
 			break;
 		}
-		if (inode == NULL)
+		if (!inode)
 			inode = file_inode(lo->lo_backing_file);
 		if (lo->lo_state == LLOOP_BOUND)
 			fid = ll_i2info(inode)->lli_fid;
@@ -676,7 +675,7 @@ static enum llioc_iter lloop_ioctl(struct inode *unused, struct file *file,
 	if (magic != ll_iocontrol_magic)
 		return LLIOC_CONT;
 
-	if (disks == NULL) {
+	if (!disks) {
 		err = -ENODEV;
 		goto out1;
 	}
@@ -793,7 +792,7 @@ static int __init lloop_init(void)
 	       lloop_major, max_loop);
 
 	ll_iocontrol_magic = ll_iocontrol_register(lloop_ioctl, 2, cmdlist);
-	if (ll_iocontrol_magic == NULL)
+	if (!ll_iocontrol_magic)
 		goto out_mem1;
 
 	loop_dev = kcalloc(max_loop, sizeof(*loop_dev), GFP_KERNEL);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 8d3c788..4d2e4b2 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -453,7 +453,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 		if (diff <= 0)
 			break;
 
-		if (sbi->ll_dt_exp == NULL) { /* being initialized */
+		if (!sbi->ll_dt_exp) { /* being initialized */
 			rc = -ENODEV;
 			break;
 		}
@@ -966,9 +966,9 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 
 	name[MAX_STRING_SIZE] = '\0';
 
-	LASSERT(sbi != NULL);
-	LASSERT(mdc != NULL);
-	LASSERT(osc != NULL);
+	LASSERT(sbi);
+	LASSERT(mdc);
+	LASSERT(osc);
 
 	/* Get fsname */
 	len = strlen(lsi->lsi_lmd->lmd_profile);
@@ -1012,7 +1012,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 	/* File operations stats */
 	sbi->ll_stats = lprocfs_alloc_stats(LPROC_LL_FILE_OPCODES,
 					    LPROCFS_STATS_FLAG_NONE);
-	if (sbi->ll_stats == NULL) {
+	if (!sbi->ll_stats) {
 		err = -ENOMEM;
 		goto out;
 	}
@@ -1039,7 +1039,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 
 	sbi->ll_ra_stats = lprocfs_alloc_stats(ARRAY_SIZE(ra_stat_string),
 					       LPROCFS_STATS_FLAG_NONE);
-	if (sbi->ll_ra_stats == NULL) {
+	if (!sbi->ll_ra_stats) {
 		err = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index da5f443..dc16d43 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -118,7 +118,7 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 
 			ll_read_inode2(inode, md);
 			if (S_ISREG(inode->i_mode) &&
-			    ll_i2info(inode)->lli_clob == NULL) {
+			    !ll_i2info(inode)->lli_clob) {
 				CDEBUG(D_INODE,
 					"%s: apply lsm %p to inode "DFID".\n",
 					ll_get_fsname(sb, NULL, 0), md->lsm,
@@ -181,9 +181,9 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 
 		/* Inode is set to lock->l_resource->lr_lvb_inode
 		 * for mdc - bug 24555 */
-		LASSERT(lock->l_ast_data == NULL);
+		LASSERT(!lock->l_ast_data);
 
-		if (inode == NULL)
+		if (!inode)
 			break;
 
 		/* Invalidate all dentries associated with this inode */
@@ -260,7 +260,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		}
 
 		if ((bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM)) &&
-		    inode->i_sb->s_root != NULL &&
+		    inode->i_sb->s_root &&
 		    !is_root_inode(inode))
 			ll_invalidate_aliases(inode);
 
@@ -288,12 +288,7 @@ __u32 ll_i2suppgid(struct inode *i)
  * array in case it might be useful.  Not needed if doing an MDS-side upcall. */
 void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
 {
-#if 0
-	int i;
-#endif
-
-	LASSERT(i1 != NULL);
-	LASSERT(suppgids != NULL);
+	LASSERT(i1);
 
 	suppgids[0] = ll_i2suppgid(i1);
 
@@ -301,22 +296,6 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
 		suppgids[1] = ll_i2suppgid(i2);
 		else
 			suppgids[1] = -1;
-
-#if 0
-	for (i = 0; i < current_ngroups; i++) {
-		if (suppgids[0] == -1) {
-			if (current_groups[i] != suppgids[1])
-				suppgids[0] = current_groups[i];
-			continue;
-		}
-		if (suppgids[1] == -1) {
-			if (current_groups[i] != suppgids[0])
-				suppgids[1] = current_groups[i];
-			continue;
-		}
-		break;
-	}
-#endif
 }
 
 /*
@@ -445,7 +424,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		   !it_disposition(it, DISP_OPEN_CREATE)) {
 		/* With DISP_OPEN_CREATE dentry will
 		   instantiated in ll_create_it. */
-		LASSERT(d_inode(*de) == NULL);
+		LASSERT(!d_inode(*de));
 		d_instantiate(*de, inode);
 	}
 
@@ -498,7 +477,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (d_mountpoint(dentry))
 		CERROR("Tell Peter, lookup on mtpt, it %s\n", LL_IT2STR(it));
 
-	if (it == NULL || it->it_op == IT_GETXATTR)
+	if (!it || it->it_op == IT_GETXATTR)
 		it = &lookup_it;
 
 	if (it->it_op == IT_GETATTR) {
@@ -557,7 +536,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
  out:
 	if (req)
 		ptlrpc_req_finished(req);
-	if (it->it_op == IT_GETATTR && (retval == NULL || retval == dentry))
+	if (it->it_op == IT_GETATTR && (!retval || retval == dentry))
 		ll_statahead_mark(parent, dentry);
 	return retval;
 }
@@ -582,7 +561,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 		itp = &it;
 	de = ll_lookup_it(parent, dentry, itp, 0);
 
-	if (itp != NULL)
+	if (itp)
 		ll_intent_release(itp);
 
 	return de;
@@ -622,7 +601,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	de = ll_lookup_it(dir, dentry, it, lookup_flags);
 	if (IS_ERR(de))
 		rc = PTR_ERR(de);
-	else if (de != NULL)
+	else if (de)
 		dentry = de;
 
 	if (!rc) {
@@ -631,7 +610,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 			rc = ll_create_it(dir, dentry, mode, it);
 			if (rc) {
 				/* We dget in ll_splice_alias. */
-				if (de != NULL)
+				if (de)
 					dput(de);
 				goto out_release;
 			}
@@ -655,7 +634,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 				/* We dget in ll_splice_alias. finish_open takes
 				 * care of dget for fd open.
 				 */
-				if (de != NULL)
+				if (de)
 					dput(de);
 			}
 		} else {
@@ -767,7 +746,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 	int tgt_len = 0;
 	int err;
 
-	if (unlikely(tgt != NULL))
+	if (unlikely(tgt))
 		tgt_len = strlen(tgt) + 1;
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
@@ -891,7 +870,7 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 	 * check it is complete and sensible. */
 	eadata = req_capsule_server_sized_get(&request->rq_pill, &RMF_MDT_MD,
 					      body->eadatasize);
-	LASSERT(eadata != NULL);
+	LASSERT(eadata);
 
 	rc = obd_unpackmd(ll_i2dtexp(dir), &lsm, eadata, body->eadatasize);
 	if (rc < 0) {
@@ -901,7 +880,7 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 	LASSERT(rc >= sizeof(*lsm));
 
 	oa = kmem_cache_alloc(obdo_cachep, GFP_NOFS | __GFP_ZERO);
-	if (oa == NULL) {
+	if (!oa) {
 		rc = -ENOMEM;
 		goto out_free_memmd;
 	}
@@ -917,7 +896,7 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 						     &RMF_LOGCOOKIES,
 						   sizeof(struct llog_cookie) *
 						     lsm->lsm_stripe_count);
-		if (oti.oti_logcookies == NULL) {
+		if (!oti.oti_logcookies) {
 			oa->o_valid &= ~OBD_MD_FLCOOKIE;
 			body->valid &= ~OBD_MD_FLCOOKIE;
 		}
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 6b587d6..da71937 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -70,9 +70,9 @@ static void ll_cl_fini(struct ll_cl_context *lcc)
 	struct cl_page *page = lcc->lcc_page;
 
 	LASSERT(lcc->lcc_cookie == current);
-	LASSERT(env != NULL);
+	LASSERT(env);
 
-	if (page != NULL) {
+	if (page) {
 		lu_ref_del(&page->cp_reference, "cl_io", io);
 		cl_page_put(env, page);
 	}
@@ -97,7 +97,7 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 	int result = 0;
 
 	clob = ll_i2info(vmpage->mapping->host)->lli_clob;
-	LASSERT(clob != NULL);
+	LASSERT(clob);
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
@@ -111,7 +111,7 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 
 	cio = ccc_env_io(env);
 	io = cio->cui_cl.cis_io;
-	if (io == NULL && create) {
+	if (!io && create) {
 		struct inode *inode = vmpage->mapping->host;
 		loff_t pos;
 
@@ -163,12 +163,11 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 	}
 
 	lcc->lcc_io = io;
-	if (io == NULL)
+	if (!io)
 		result = -EIO;
 	if (result == 0) {
 		struct cl_page   *page;
 
-		LASSERT(io != NULL);
 		LASSERT(io->ci_state == CIS_IO_GOING);
 		LASSERT(cio->cui_fd == LUSTRE_FPRIVATE(file));
 		page = cl_page_find(env, clob, vmpage->index, vmpage,
@@ -473,7 +472,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 	const char       *msg   = NULL;
 
 	vmpage = grab_cache_page_nowait(mapping, index);
-	if (vmpage != NULL) {
+	if (vmpage) {
 		/* Check if vmpage was truncated or reclaimed */
 		if (vmpage->mapping == mapping) {
 			page = cl_page_find(env, clob, vmpage->index,
@@ -500,7 +499,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		which = RA_STAT_FAILED_GRAB_PAGE;
 		msg   = "g_c_p_n failed";
 	}
-	if (msg != NULL) {
+	if (msg) {
 		ll_ra_stats_inc(mapping, which);
 		CDEBUG(D_READA, "%s\n", msg);
 	}
@@ -616,7 +615,7 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 	int rc, count = 0, stride_ria;
 	unsigned long page_idx;
 
-	LASSERT(ria != NULL);
+	LASSERT(ria);
 	RIA_DEBUG(ria);
 
 	stride_ria = ria->ria_length > ria->ria_pages && ria->ria_pages > 0;
@@ -699,7 +698,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		bead = NULL;
 
 	/* Enlarge the RA window to encompass the full read */
-	if (bead != NULL && ras->ras_window_start + ras->ras_window_len <
+	if (bead && ras->ras_window_start + ras->ras_window_len <
 	    bead->lrr_start + bead->lrr_count) {
 		ras->ras_window_len = bead->lrr_start + bead->lrr_count -
 				      ras->ras_window_start;
@@ -1100,7 +1099,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 	LASSERT(PageLocked(vmpage));
 	LASSERT(!PageWriteback(vmpage));
 
-	LASSERT(ll_i2dtexp(inode) != NULL);
+	LASSERT(ll_i2dtexp(inode));
 
 	env = cl_env_nested_get(&nest);
 	if (IS_ERR(env)) {
@@ -1109,7 +1108,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 	}
 
 	clob  = ll_i2info(inode)->lli_clob;
-	LASSERT(clob != NULL);
+	LASSERT(clob);
 
 	io = ccc_env_thread_io(env);
 	io->ci_obj = clob;
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 711fda9..6167c9d 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -92,9 +92,9 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 		if (!IS_ERR(env)) {
 			inode = vmpage->mapping->host;
 			obj = ll_i2info(inode)->lli_clob;
-			if (obj != NULL) {
+			if (obj) {
 				page = cl_vmpage_page(vmpage, obj);
-				if (page != NULL) {
+				if (page) {
 					lu_ref_add(&page->cp_reference,
 						   "delete", vmpage);
 					cl_page_delete(env, page);
@@ -128,11 +128,11 @@ static int ll_releasepage(struct page *vmpage, RELEASEPAGE_ARG_TYPE gfp_mask)
 		return 0;
 
 	mapping = vmpage->mapping;
-	if (mapping == NULL)
+	if (!mapping)
 		return 1;
 
 	obj = ll_i2info(mapping->host)->lli_clob;
-	if (obj == NULL)
+	if (!obj)
 		return 1;
 
 	/* 1 for page allocator, 1 for cl_page and 1 for page cache */
@@ -149,8 +149,8 @@ static int ll_releasepage(struct page *vmpage, RELEASEPAGE_ARG_TYPE gfp_mask)
 		return 0;
 
 	page = cl_vmpage_page(vmpage, obj);
-	result = page == NULL;
-	if (page != NULL) {
+	result = !page;
+	if (page) {
 		if (!cl_page_in_use(page)) {
 			result = 1;
 			cl_page_delete(env, page);
@@ -396,7 +396,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	env = cl_env_get(&refcheck);
 	LASSERT(!IS_ERR(env));
 	io = ccc_env_io(env)->cui_cl.cis_io;
-	LASSERT(io != NULL);
+	LASSERT(io);
 
 	/* 0. Need locking between buffered and direct access. and race with
 	 *    size changing by concurrent truncates and writes.
@@ -461,7 +461,7 @@ out:
 			struct lov_stripe_md *lsm;
 
 			lsm = ccc_inode_lsm_get(inode);
-			LASSERT(lsm != NULL);
+			LASSERT(lsm);
 			lov_stripe_lock(lsm);
 			obd_adjust_kms(ll_i2dtexp(inode), lsm, file_offset, 0);
 			lov_stripe_unlock(lsm);
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 88ffd8e..bd6a6b7 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -130,7 +130,7 @@ ll_sa_entry_unhash(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
 static inline int agl_should_run(struct ll_statahead_info *sai,
 				 struct inode *inode)
 {
-	return (inode != NULL && S_ISREG(inode->i_mode) && sai->sai_agl_valid);
+	return (inode && S_ISREG(inode->i_mode) && sai->sai_agl_valid);
 }
 
 static inline int sa_sent_full(struct ll_statahead_info *sai)
@@ -499,7 +499,7 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 			return;
 		}
 
-		LASSERT(lli->lli_opendir_key == NULL);
+		LASSERT(!lli->lli_opendir_key);
 		LASSERT(thread_is_stopped(&sai->sai_thread));
 		LASSERT(thread_is_stopped(&sai->sai_agl_thread));
 
@@ -618,13 +618,13 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 	it = &minfo->mi_it;
 	req = entry->se_req;
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL) {
+	if (!body) {
 		rc = -EFAULT;
 		goto out;
 	}
 
 	child = entry->se_inode;
-	if (child == NULL) {
+	if (!child) {
 		/*
 		 * lookup.
 		 */
@@ -705,7 +705,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 
 	spin_lock(&lli->lli_sa_lock);
 	/* stale entry */
-	if (unlikely(lli->lli_sai == NULL ||
+	if (unlikely(!lli->lli_sai ||
 		     lli->lli_sai->sai_generation != minfo->mi_generation)) {
 		spin_unlock(&lli->lli_sa_lock);
 		rc = -ESTALE;
@@ -720,7 +720,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		}
 
 		entry = ll_sa_entry_get_byindex(sai, minfo->mi_cbdata);
-		if (entry == NULL) {
+		if (!entry) {
 			sai->sai_replied++;
 			spin_unlock(&lli->lli_sa_lock);
 			rc = -EIDRM;
@@ -756,7 +756,7 @@ out:
 		iput(dir);
 		kfree(minfo);
 	}
-	if (sai != NULL)
+	if (sai)
 		ll_sai_put(sai);
 	return rc;
 }
@@ -853,7 +853,7 @@ static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
 	struct ldlm_enqueue_info *einfo;
 	int rc;
 
-	if (unlikely(inode == NULL))
+	if (unlikely(!inode))
 		return 1;
 
 	if (d_mountpoint(dentry))
@@ -908,10 +908,9 @@ static void ll_statahead_one(struct dentry *parent, const char *entry_name,
 		rc = do_sa_revalidate(dir, entry, dentry);
 		if (rc == 1 && agl_should_run(sai, d_inode(dentry)))
 			ll_agl_add(sai, d_inode(dentry), entry->se_index);
-	}
 
-	if (dentry != NULL)
 		dput(dentry);
+	}
 
 	if (rc) {
 		rc1 = ll_sa_entry_to_stated(sai, entry,
@@ -1070,7 +1069,7 @@ static int ll_statahead_thread(void *arg)
 		}
 
 		dp = page_address(page);
-		for (ent = lu_dirent_start(dp); ent != NULL;
+		for (ent = lu_dirent_start(dp); ent;
 		     ent = lu_dirent_next(ent)) {
 			__u64 hash;
 			int namelen;
@@ -1274,7 +1273,7 @@ void ll_stop_statahead(struct inode *dir, void *key)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
 
-	if (unlikely(key == NULL))
+	if (unlikely(!key))
 		return;
 
 	spin_lock(&lli->lli_sa_lock);
@@ -1357,7 +1356,7 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 		}
 
 		dp = page_address(page);
-		for (ent = lu_dirent_start(dp); ent != NULL;
+		for (ent = lu_dirent_start(dp); ent;
 		     ent = lu_dirent_next(ent)) {
 			__u64 hash;
 			int namelen;
@@ -1448,7 +1447,7 @@ ll_sai_unplug(struct ll_statahead_info *sai, struct ll_sa_entry *entry)
 	struct ll_sb_info    *sbi    = ll_i2sbi(sai->sai_inode);
 	int		   hit;
 
-	if (entry != NULL && entry->se_stat == SA_ENTRY_SUCC)
+	if (entry && entry->se_stat == SA_ENTRY_SUCC)
 		hit = 1;
 	else
 		hit = 0;
@@ -1540,7 +1539,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 		}
 
 		entry = ll_sa_entry_get_byname(sai, &(*dentryp)->d_name);
-		if (entry == NULL || only_unplug) {
+		if (!entry || only_unplug) {
 			ll_sai_unplug(sai, entry);
 			return entry ? 1 : -EAGAIN;
 		}
@@ -1559,8 +1558,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 			}
 		}
 
-		if (entry->se_stat == SA_ENTRY_SUCC &&
-		    entry->se_inode != NULL) {
+		if (entry->se_stat == SA_ENTRY_SUCC && entry->se_inode) {
 			struct inode *inode = entry->se_inode;
 			struct lookup_intent it = { .it_op = IT_GETATTR,
 						    .d.lustre.it_lock_handle =
@@ -1570,7 +1568,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 			rc = md_revalidate_lock(ll_i2mdexp(dir), &it,
 						ll_inode2fid(inode), &bits);
 			if (rc == 1) {
-				if (d_inode(*dentryp) == NULL) {
+				if (!d_inode(*dentryp)) {
 					struct dentry *alias;
 
 					alias = ll_splice_alias(inode,
@@ -1616,14 +1614,14 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	}
 
 	sai = ll_sai_alloc();
-	if (sai == NULL) {
+	if (!sai) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	sai->sai_ls_all = (rc == LS_FIRST_DOT_DE);
 	sai->sai_inode = igrab(dir);
-	if (unlikely(sai->sai_inode == NULL)) {
+	if (unlikely(!sai->sai_inode)) {
 		CWARN("Do not start stat ahead on dying inode "DFID"\n",
 		      PFID(&lli->lli_fid));
 		rc = -ESTALE;
@@ -1669,7 +1667,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 		 * reference from allocation time. */
 		ll_sai_put(sai);
 		ll_sai_put(sai);
-		LASSERT(lli->lli_sai == NULL);
+		LASSERT(!lli->lli_sai);
 		return -EAGAIN;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 86c371e..cd996f6 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -54,7 +54,7 @@ static struct inode *ll_alloc_inode(struct super_block *sb)
 
 	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_ALLOC_INODE, 1);
 	lli = kmem_cache_alloc(ll_inode_cachep, GFP_NOFS | __GFP_ZERO);
-	if (lli == NULL)
+	if (!lli)
 		return NULL;
 
 	inode_init_once(&lli->lli_vfs_inode);
@@ -108,26 +108,26 @@ static int __init init_lustre_lite(void)
 					    sizeof(struct ll_inode_info),
 					    0, SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
 					    NULL);
-	if (ll_inode_cachep == NULL)
+	if (!ll_inode_cachep)
 		goto out_cache;
 
 	ll_file_data_slab = kmem_cache_create("ll_file_data",
 						 sizeof(struct ll_file_data), 0,
 						 SLAB_HWCACHE_ALIGN, NULL);
-	if (ll_file_data_slab == NULL)
+	if (!ll_file_data_slab)
 		goto out_cache;
 
 	ll_remote_perm_cachep = kmem_cache_create("ll_remote_perm_cache",
 						  sizeof(struct ll_remote_perm),
 						      0, 0, NULL);
-	if (ll_remote_perm_cachep == NULL)
+	if (!ll_remote_perm_cachep)
 		goto out_cache;
 
 	ll_rmtperm_hash_cachep = kmem_cache_create("ll_rmtperm_hash_cache",
 						   REMOTE_PERM_HASHSIZE *
 						   sizeof(struct list_head),
 						   0, 0, NULL);
-	if (ll_rmtperm_hash_cachep == NULL)
+	if (!ll_rmtperm_hash_cachep)
 		goto out_cache;
 
 	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 2610348..c2775b6 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -81,7 +81,6 @@ static int ll_readlink_internal(struct inode *inode,
 	}
 
 	body = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_BODY);
-	LASSERT(body != NULL);
 	if ((body->valid & OBD_MD_LINKNAME) == 0) {
 		CERROR("OBD_MD_LINKNAME not set on reply\n");
 		rc = -EPROTO;
@@ -97,7 +96,7 @@ static int ll_readlink_internal(struct inode *inode,
 	}
 
 	*symname = req_capsule_server_get(&(*request)->rq_pill, &RMF_MDT_MD);
-	if (*symname == NULL ||
+	if (!*symname ||
 	    strnlen(*symname, symlen) != symlen - 1) {
 		/* not full/NULL terminated */
 		CERROR("inode %lu: symlink not NULL terminated string of length %d\n",
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index fdca4ec..6075ccf 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -80,7 +80,7 @@ static void *vvp_key_init(const struct lu_context *ctx,
 	struct vvp_thread_info *info;
 
 	info = kmem_cache_alloc(vvp_thread_kmem, GFP_NOFS | __GFP_ZERO);
-	if (info == NULL)
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -99,7 +99,7 @@ static void *vvp_session_key_init(const struct lu_context *ctx,
 	struct vvp_session *session;
 
 	session = kmem_cache_alloc(vvp_session_kmem, GFP_NOFS | __GFP_ZERO);
-	if (session == NULL)
+	if (!session)
 		session = ERR_PTR(-ENOMEM);
 	return session;
 }
@@ -228,7 +228,7 @@ int cl_sb_fini(struct super_block *sb)
 	if (!IS_ERR(env)) {
 		cld = sbi->ll_cl;
 
-		if (cld != NULL) {
+		if (cld) {
 			cl_stack_fini(env, cld);
 			sbi->ll_cl = NULL;
 			sbi->ll_site = NULL;
@@ -325,11 +325,11 @@ static struct cl_object *vvp_pgcache_obj(const struct lu_env *env,
 
 	cfs_hash_hlist_for_each(dev->ld_site->ls_obj_hash, id->vpi_bucket,
 				vvp_pgcache_obj_get, id);
-	if (id->vpi_obj != NULL) {
+	if (id->vpi_obj) {
 		struct lu_object *lu_obj;
 
 		lu_obj = lu_object_locate(id->vpi_obj, dev->ld_type);
-		if (lu_obj != NULL) {
+		if (lu_obj) {
 			lu_object_ref_add(lu_obj, "dump", current);
 			return lu2cl(lu_obj);
 		}
@@ -355,7 +355,7 @@ static loff_t vvp_pgcache_find(const struct lu_env *env,
 		if (id.vpi_bucket >= CFS_HASH_NHLIST(site->ls_obj_hash))
 			return ~0ULL;
 		clob = vvp_pgcache_obj(env, dev, &id);
-		if (clob != NULL) {
+		if (clob) {
 			struct cl_object_header *hdr;
 			int		      nr;
 			struct cl_page	  *pg;
@@ -443,7 +443,7 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 		vvp_pgcache_id_unpack(pos, &id);
 		sbi = f->private;
 		clob = vvp_pgcache_obj(env, &sbi->ll_cl->cd_lu_dev, &id);
-		if (clob != NULL) {
+		if (clob) {
 			hdr = cl_object_header(clob);
 
 			spin_lock(&hdr->coh_page_guard);
@@ -452,7 +452,7 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 
 			seq_printf(f, "%8x@"DFID": ",
 				   id.vpi_index, PFID(&hdr->coh_lu.loh_fid));
-			if (page != NULL) {
+			if (page) {
 				vvp_pgcache_page_show(env, f, page);
 				cl_page_put(env, page);
 			} else
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 573ab15..f856899 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -181,7 +181,7 @@ static void vvp_io_fault_fini(const struct lu_env *env,
 
 	CLOBINVRNT(env, io->ci_obj, ccc_object_invariant(io->ci_obj));
 
-	if (page != NULL) {
+	if (page) {
 		lu_ref_del(&page->cp_reference, "fault", io);
 		cl_page_put(env, page);
 		io->u.ci_fault.ft_page = NULL;
@@ -220,11 +220,11 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	if (!cl_is_normalio(env, io))
 		return 0;
 
-	if (vio->cui_iter == NULL) /* nfs or loop back device write */
+	if (!vio->cui_iter) /* nfs or loop back device write */
 		return 0;
 
 	/* No MM (e.g. NFS)? No vmas too. */
-	if (mm == NULL)
+	if (!mm)
 		return 0;
 
 	iov_for_each(iov, i, *(vio->cui_iter)) {
@@ -587,7 +587,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 
 	CDEBUG(D_VFSTRACE, "write: [%lli, %lli)\n", pos, pos + (long long)cnt);
 
-	if (cio->cui_iter == NULL) /* from a temp io in ll_cl_init(). */
+	if (!cio->cui_iter) /* from a temp io in ll_cl_init(). */
 		result = 0;
 	else
 		result = generic_file_write_iter(cio->cui_iocb, cio->cui_iter);
@@ -673,7 +673,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 
 	/* must return locked page */
 	if (fio->ft_mkwrite) {
-		LASSERT(cfio->ft_vmpage != NULL);
+		LASSERT(cfio->ft_vmpage);
 		lock_page(cfio->ft_vmpage);
 	} else {
 		result = vvp_io_kernel_fault(cfio);
@@ -792,7 +792,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 
 out:
 	/* return unlocked vmpage to avoid deadlocking */
-	if (vmpage != NULL)
+	if (vmpage)
 		unlock_page(vmpage);
 	cfio->fault.ft_flags &= ~VM_FAULT_LOCKED;
 	return result;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index c82714e..8d7aa74 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -147,7 +147,7 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 	if (conf->coc_opc != OBJECT_CONF_SET)
 		return 0;
 
-	if (conf->u.coc_md != NULL && conf->u.coc_md->lsm != NULL) {
+	if (conf->u.coc_md && conf->u.coc_md->lsm) {
 		CDEBUG(D_VFSTRACE, DFID ": layout version change: %u -> %u\n",
 		       PFID(&lli->lli_fid), lli->lli_layout_gen,
 		       conf->u.coc_md->lsm->lsm_layout_gen);
@@ -186,9 +186,8 @@ struct ccc_object *cl_inode2ccc(struct inode *inode)
 	struct cl_object     *obj = lli->lli_clob;
 	struct lu_object     *lu;
 
-	LASSERT(obj != NULL);
 	lu = lu_object_locate(obj->co_lu.lo_header, &vvp_device_type);
-	LASSERT(lu != NULL);
+	LASSERT(lu);
 	return lu2ccc(lu);
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index a133475..f254ad5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -56,7 +56,7 @@ static void vvp_page_fini_common(struct ccc_page *cp)
 {
 	struct page *vmpage = cp->cpg_page;
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	page_cache_release(vmpage);
 }
 
@@ -81,7 +81,7 @@ static int vvp_page_own(const struct lu_env *env,
 	struct ccc_page *vpg    = cl2ccc_page(slice);
 	struct page      *vmpage = vpg->cpg_page;
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	if (nonblock) {
 		if (!trylock_page(vmpage))
 			return -EAGAIN;
@@ -105,7 +105,7 @@ static void vvp_page_assume(const struct lu_env *env,
 {
 	struct page *vmpage = cl2vm_page(slice);
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 	wait_on_page_writeback(vmpage);
 }
@@ -116,7 +116,7 @@ static void vvp_page_unassume(const struct lu_env *env,
 {
 	struct page *vmpage = cl2vm_page(slice);
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 }
 
@@ -125,7 +125,7 @@ static void vvp_page_disown(const struct lu_env *env,
 {
 	struct page *vmpage = cl2vm_page(slice);
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
 	unlock_page(cl2vm_page(slice));
@@ -139,7 +139,7 @@ static void vvp_page_discard(const struct lu_env *env,
 	struct address_space *mapping;
 	struct ccc_page      *cpg     = cl2ccc_page(slice);
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
 	mapping = vmpage->mapping;
@@ -161,7 +161,7 @@ static int vvp_page_unmap(const struct lu_env *env,
 	struct page *vmpage = cl2vm_page(slice);
 	__u64       offset;
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
 	offset = vmpage->index << PAGE_CACHE_SHIFT;
@@ -199,7 +199,7 @@ static void vvp_page_export(const struct lu_env *env,
 {
 	struct page *vmpage = cl2vm_page(slice);
 
-	LASSERT(vmpage != NULL);
+	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 	if (uptodate)
 		SetPageUptodate(vmpage);
@@ -290,7 +290,7 @@ static void vvp_page_completion_read(const struct lu_env *env,
 	} else
 		cp->cpg_defer_uptodate = 0;
 
-	if (page->cp_sync_io == NULL)
+	if (!page->cp_sync_io)
 		unlock_page(vmpage);
 }
 
@@ -317,7 +317,7 @@ static void vvp_page_completion_write(const struct lu_env *env,
 	cp->cpg_write_queued = 0;
 	vvp_write_complete(cl2ccc(slice->cpl_obj), cp);
 
-	if (pg->cp_sync_io != NULL) {
+	if (pg->cp_sync_io) {
 		LASSERT(PageLocked(vmpage));
 		LASSERT(!PageWriteback(vmpage));
 	} else {
@@ -385,7 +385,7 @@ static int vvp_page_print(const struct lu_env *env,
 	(*printer)(env, cookie, LUSTRE_VVP_NAME "-page@%p(%d:%d:%d) vm@%p ",
 		   vp, vp->cpg_defer_uptodate, vp->cpg_ra_used,
 		   vp->cpg_write_queued, vmpage);
-	if (vmpage != NULL) {
+	if (vmpage) {
 		(*printer)(env, cookie, "%lx %d:%d %lx %lu %slru",
 			   (long)vmpage->flags, page_count(vmpage),
 			   page_mapcount(vmpage), vmpage->private,
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index fa477e7..8ccbf26 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -148,7 +148,7 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 	    (xattr_type == XATTR_ACL_ACCESS_T ||
 	    xattr_type == XATTR_ACL_DEFAULT_T)) {
 		rce = rct_search(&sbi->ll_rct, current_pid());
-		if (rce == NULL ||
+		if (!rce ||
 		    (rce->rce_ops != RMT_LSETFACL &&
 		    rce->rce_ops != RMT_RSETFACL))
 			return -EOPNOTSUPP;
@@ -158,7 +158,6 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 
 			ee = et_search_del(&sbi->ll_et, current_pid(),
 					   ll_inode2fid(inode), xattr_type);
-			LASSERT(ee != NULL);
 			if (valid & OBD_MD_FLXATTR) {
 				acl = lustre_acl_xattr_merge2ext(
 						(posix_acl_xattr_header *)value,
@@ -196,7 +195,7 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 	 * Release the posix ACL space.
 	 */
 	kfree(new_value);
-	if (acl != NULL)
+	if (acl)
 		lustre_ext_acl_xattr_free(acl);
 #endif
 	if (rc) {
@@ -239,10 +238,10 @@ int ll_setxattr(struct dentry *dentry, const char *name,
 		/* Attributes that are saved via getxattr will always have
 		 * the stripe_offset as 0.  Instead, the MDS should be
 		 * allowed to pick the starting OST index.   b=17846 */
-		if (lump != NULL && lump->lmm_stripe_offset == 0)
+		if (lump && lump->lmm_stripe_offset == 0)
 			lump->lmm_stripe_offset = -1;
 
-		if (lump != NULL && S_ISREG(inode->i_mode)) {
+		if (lump && S_ISREG(inode->i_mode)) {
 			int flags = FMODE_WRITE;
 			int lum_size = (lump->lmm_magic == LOV_USER_MAGIC_V1) ?
 				sizeof(*lump) : sizeof(struct lov_user_md_v3);
@@ -324,7 +323,7 @@ int ll_getxattr_common(struct inode *inode, const char *name,
 	    (xattr_type == XATTR_ACL_ACCESS_T ||
 	    xattr_type == XATTR_ACL_DEFAULT_T)) {
 		rce = rct_search(&sbi->ll_rct, current_pid());
-		if (rce == NULL ||
+		if (!rce ||
 		    (rce->rce_ops != RMT_LSETFACL &&
 		    rce->rce_ops != RMT_LGETFACL &&
 		    rce->rce_ops != RMT_RSETFACL &&
@@ -365,7 +364,7 @@ do_getxattr:
 			goto out_xattr;
 
 		/* Add "system.posix_acl_access" to the list */
-		if (lli->lli_posix_acl != NULL && valid & OBD_MD_FLXATTRLS) {
+		if (lli->lli_posix_acl && valid & OBD_MD_FLXATTRLS) {
 			if (size == 0) {
 				rc += sizeof(XATTR_NAME_ACL_ACCESS);
 			} else if (size - rc >= sizeof(XATTR_NAME_ACL_ACCESS)) {
@@ -487,7 +486,7 @@ ssize_t ll_getxattr(struct dentry *dentry, const char *name,
 		}
 
 		lsm = ccc_inode_lsm_get(inode);
-		if (lsm == NULL) {
+		if (!lsm) {
 			if (S_ISDIR(inode->i_mode)) {
 				rc = ll_dir_getstripe(inode, &lmm,
 						      &lmmsize, &request);
@@ -559,7 +558,7 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	if (rc < 0)
 		goto out;
 
-	if (buffer != NULL) {
+	if (buffer) {
 		struct ll_sb_info *sbi = ll_i2sbi(inode);
 		char *xattr_name = buffer;
 		int xlen, rem = rc;
@@ -597,12 +596,12 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 		const size_t name_len   = sizeof("lov") - 1;
 		const size_t total_len  = prefix_len + name_len + 1;
 
-		if (((rc + total_len) > size) && (buffer != NULL)) {
+		if (((rc + total_len) > size) && buffer) {
 			ptlrpc_req_finished(request);
 			return -ERANGE;
 		}
 
-		if (buffer != NULL) {
+		if (buffer) {
 			buffer += rc;
 			memcpy(buffer, XATTR_LUSTRE_PREFIX, prefix_len);
 			memcpy(buffer + prefix_len, "lov", name_len);
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index d140276..ed6e073 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -59,9 +59,6 @@ void ll_xattr_fini(void)
  */
 static void ll_xattr_cache_init(struct ll_inode_info *lli)
 {
-
-	LASSERT(lli != NULL);
-
 	INIT_LIST_HEAD(&lli->lli_xattrs);
 	lli->lli_flags |= LLIF_XATTR_CACHE;
 }
@@ -83,8 +80,7 @@ static int ll_xattr_cache_find(struct list_head *cache,
 
 	list_for_each_entry(entry, cache, xe_list) {
 		/* xattr_name == NULL means look for any entry */
-		if (xattr_name == NULL ||
-		    strcmp(xattr_name, entry->xe_name) == 0) {
+		if (!xattr_name || strcmp(xattr_name, entry->xe_name) == 0) {
 			*xattr = entry;
 			CDEBUG(D_CACHE, "find: [%s]=%.*s\n",
 			       entry->xe_name, entry->xe_vallen,
@@ -118,7 +114,7 @@ static int ll_xattr_cache_add(struct list_head *cache,
 	}
 
 	xattr = kmem_cache_alloc(xattr_kmem, GFP_NOFS | __GFP_ZERO);
-	if (xattr == NULL) {
+	if (!xattr) {
 		CDEBUG(D_CACHE, "failed to allocate xattr\n");
 		return -ENOMEM;
 	}
@@ -359,7 +355,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	}
 
 	/* Matched but no cache? Cancelled on error by a parallel refill. */
-	if (unlikely(req == NULL)) {
+	if (unlikely(!req)) {
 		CDEBUG(D_CACHE, "cancelled by a parallel getxattr\n");
 		rc = -EIO;
 		goto out_maybe_drop;
@@ -376,7 +372,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (body == NULL) {
+	if (!body) {
 		CERROR("no MDT BODY in the refill xattr reply\n");
 		rc = -EPROTO;
 		goto out_destroy;
@@ -388,7 +384,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 						body->aclsize);
 	xsizes = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS_LENS,
 					      body->max_mdsize * sizeof(__u32));
-	if (xdata == NULL || xval == NULL || xsizes == NULL) {
+	if (!xdata || !xval || !xsizes) {
 		CERROR("wrong setxattr reply\n");
 		rc = -EPROTO;
 		goto out_destroy;
@@ -404,7 +400,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	for (i = 0; i < body->max_mdsize; i++) {
 		CDEBUG(D_CACHE, "caching [%s]=%.*s\n", xdata, *xsizes, xval);
 		/* Perform consistency checks: attr names and vals in pill */
-		if (memchr(xdata, 0, xtail - xdata) == NULL) {
+		if (!memchr(xdata, 0, xtail - xdata)) {
 			CERROR("xattr protocol violation (names are broken)\n");
 			rc = -EPROTO;
 		} else if (xval + *xsizes > xvtail) {
-- 
2.1.0
