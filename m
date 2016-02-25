From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:30 -0500
Subject: [lustre-devel] [PATCH v2 47/84] staging/lustre/llite: Adjust
	comments to better conform to coding style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-48-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dcache.c       |  18 ++-
 drivers/staging/lustre/lustre/llite/dir.c          |  29 ++--
 drivers/staging/lustre/lustre/llite/file.c         | 161 +++++++++++++--------
 drivers/staging/lustre/lustre/llite/llite_close.c  |  18 ++-
 .../staging/lustre/lustre/llite/llite_internal.h   | 109 ++++++++------
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  86 +++++++----
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  20 ++-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   6 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   3 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  41 ++++--
 drivers/staging/lustre/lustre/llite/rw.c           |  70 ++++++---
 drivers/staging/lustre/lustre/llite/rw26.c         |  21 ++-
 drivers/staging/lustre/lustre/llite/statahead.c    |  36 +++--
 drivers/staging/lustre/lustre/llite/super25.c      |   6 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  42 ++++--
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   9 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  15 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |   6 +-
 20 files changed, 451 insertions(+), 251 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 34eb17c..0bc0fb9f 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -80,7 +80,8 @@ static void ll_release(struct dentry *de)
  * This avoids a race where ll_lookup_it() instantiates a dentry, but we get
  * an AST before calling d_revalidate_it().  The dentry still exists (marked
  * INVALID) so d_lookup() matches it, but we have no lock on it (so
- * lock_match() fails) and we spin around real_lookup(). */
+ * lock_match() fails) and we spin around real_lookup().
+ */
 static int ll_dcompare(const struct dentry *parent, const struct dentry *dentry,
 		       unsigned int len, const char *str,
 		       const struct qstr *name)
@@ -117,7 +118,8 @@ static inline int return_if_equal(struct ldlm_lock *lock, void *data)
 /* find any ldlm lock of the inode in mdc and lov
  * return 0    not find
  *	1    find one
- *      < 0    error */
+ *      < 0    error
+ */
 static int find_cbdata(struct inode *inode)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -163,10 +165,12 @@ static int ll_ddelete(const struct dentry *de)
 	/* Disable this piece of code temporarily because this is called
 	 * inside dcache_lock so it's not appropriate to do lots of work
 	 * here. ATTENTION: Before this piece of code enabling, LU-2487 must be
-	 * resolved. */
+	 * resolved.
+	 */
 #if 0
 	/* if not ldlm lock for this inode, set i_nlink to 0 so that
-	 * this inode can be recycled later b=20433 */
+	 * this inode can be recycled later b=20433
+	 */
 	if (d_really_is_positive(de) && !find_cbdata(d_inode(de)))
 		clear_nlink(d_inode(de));
 #endif
@@ -216,7 +220,8 @@ void ll_intent_drop_lock(struct lookup_intent *it)
 		ldlm_lock_decref(&handle, it->d.lustre.it_lock_mode);
 
 		/* bug 494: intent_release may be called multiple times, from
-		 * this thread and we don't want to double-decref this lock */
+		 * this thread and we don't want to double-decref this lock
+		 */
 		it->d.lustre.it_lock_mode = 0;
 		if (it->d.lustre.it_remote_lock_mode != 0) {
 			handle.cookie = it->d.lustre.it_remote_lock_handle;
@@ -294,7 +299,8 @@ void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
 	if (it->it_op == IT_LOOKUP || it->it_op == IT_GETATTR) {
 		/* on 2.6 there are situation when several lookups and
 		 * revalidations may be requested during single operation.
-		 * therefore, we don't release intent here -bzzz */
+		 * therefore, we don't release intent here -bzzz
+		 */
 		ll_intent_drop_lock(it);
 	}
 }
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index c2ee7fc..bd88a3b 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -379,7 +379,8 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 				 &it.d.lustre.it_lock_handle, dir, NULL);
 	} else {
 		/* for cross-ref object, l_ast_data of the lock may not be set,
-		 * we reset it here */
+		 * we reset it here
+		 */
 		md_set_lock_data(ll_i2sbi(dir)->ll_md_exp, &lockh.cookie,
 				 dir, NULL);
 	}
@@ -737,8 +738,9 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	}
 
 	/* In the following we use the fact that LOV_USER_MAGIC_V1 and
-	 LOV_USER_MAGIC_V3 have the same initial fields so we do not
-	 need to make the distinction between the 2 versions */
+	 * LOV_USER_MAGIC_V3 have the same initial fields so we do not
+	 * need to make the distinction between the 2 versions
+	 */
 	if (set_default && mgc->u.cli.cl_mgc_mgsexp) {
 		char *param = NULL;
 		char *buf;
@@ -929,7 +931,8 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 		}
 
 		/* Store it the hsm_copy for later copytool use.
-		 * Always modified even if no lsm. */
+		 * Always modified even if no lsm.
+		 */
 		copy->hc_data_version = data_version;
 	}
 
@@ -1006,11 +1009,13 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 		}
 
 		/* Store it the hsm_copy for later copytool use.
-		 * Always modified even if no lsm. */
+		 * Always modified even if no lsm.
+		 */
 		hpk.hpk_data_version = data_version;
 
 		/* File could have been stripped during archiving, so we need
-		 * to check anyway. */
+		 * to check anyway.
+		 */
 		if ((copy->hc_hai.hai_action == HSMA_ARCHIVE) &&
 		    (copy->hc_data_version != data_version)) {
 			CDEBUG(D_HSM, "File data version mismatched. File content was changed during archiving. "
@@ -1022,7 +1027,8 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 			 * the cdt will loop on retried archive requests.
 			 * The policy engine will ask for a new archive later
 			 * when the file will not be modified for some tunable
-			 * time */
+			 * time
+			 */
 			/* we do not notify caller */
 			hpk.hpk_flags &= ~HP_FLAG_RETRY;
 			/* hpk_errval must be >= 0 */
@@ -1150,7 +1156,8 @@ static int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 			return rc;
 		}
 		/* If QIF_SPACE is not set, client should collect the
-		 * space usage from OSSs by itself */
+		 * space usage from OSSs by itself
+		 */
 		if (cmd == Q_GETQUOTA &&
 		    !(oqctl->qc_dqblk.dqb_valid & QIF_SPACE) &&
 		    !oqctl->qc_dqblk.dqb_curspace) {
@@ -1201,7 +1208,8 @@ out:
 
 /* This function tries to get a single name component,
  * to send to the server. No actual path traversal involved,
- * so we limit to NAME_MAX */
+ * so we limit to NAME_MAX
+ */
 static char *ll_getname(const char __user *filename)
 {
 	int ret = 0, len;
@@ -1803,7 +1811,8 @@ out_quotactl:
 		hpk.hpk_data_version = 0;
 
 		/* File may not exist in Lustre; all progress
-		 * reported to Lustre root */
+		 * reported to Lustre root
+		 */
 		rc = obd_iocontrol(cmd, sbi->ll_md_exp, sizeof(hpk), &hpk,
 				   NULL);
 		return rc;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ba65fc0..4c25cf2 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -166,7 +166,8 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 		/* This close must have the epoch closed. */
 		LASSERT(epoch_close);
 		/* MDS has instructed us to obtain Size-on-MDS attribute from
-		 * OSTs and send setattr to back to MDS. */
+		 * OSTs and send setattr to back to MDS.
+		 */
 		rc = ll_som_update(inode, op_data);
 		if (rc) {
 			CERROR("inode %lu mdc Size-on-MDS update failed: rc = %d\n",
@@ -179,7 +180,8 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 	}
 
 	/* DATA_MODIFIED flag was successfully sent on close, cancel data
-	 * modification flag. */
+	 * modification flag.
+	 */
 	if (rc == 0 && (op_data->op_bias & MDS_DATA_MODIFIED)) {
 		struct ll_inode_info *lli = ll_i2info(inode);
 
@@ -242,7 +244,8 @@ int ll_md_real_close(struct inode *inode, fmode_t fmode)
 	mutex_lock(&lli->lli_och_mutex);
 	if (*och_usecount > 0) {
 		/* There are still users of this handle, so skip
-		 * freeing it. */
+		 * freeing it.
+		 */
 		mutex_unlock(&lli->lli_och_mutex);
 		return 0;
 	}
@@ -253,7 +256,8 @@ int ll_md_real_close(struct inode *inode, fmode_t fmode)
 
 	if (och) {
 		/* There might be a race and this handle may already
-		   be closed. */
+		 * be closed.
+		 */
 		rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp,
 					       inode, och, NULL);
 	}
@@ -280,7 +284,8 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 		bool lease_broken;
 
 		/* Usually the lease is not released when the
-		 * application crashed, we need to release here. */
+		 * application crashed, we need to release here.
+		 */
 		rc = ll_lease_close(fd->fd_lease_och, inode, &lease_broken);
 		CDEBUG(rc ? D_ERROR : D_INODE, "Clean up lease "DFID" %d/%d\n",
 			PFID(&lli->lli_fid), rc, lease_broken);
@@ -295,7 +300,8 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 	}
 
 	/* Let's see if we have good enough OPEN lock on the file and if
-	   we can skip talking to MDS */
+	 * we can skip talking to MDS
+	 */
 
 	mutex_lock(&lli->lli_och_mutex);
 	if (fd->fd_omode & FMODE_WRITE) {
@@ -356,9 +362,10 @@ int ll_file_release(struct inode *inode, struct file *file)
 	fd = LUSTRE_FPRIVATE(file);
 	LASSERT(fd);
 
-	/* The last ref on @file, maybe not the owner pid of statahead.
+	/* The last ref on @file, maybe not be the owner pid of statahead.
 	 * Different processes can open the same dir, "ll_opendir_key" means:
-	 * it is me that should stop the statahead thread. */
+	 * it is me that should stop the statahead thread.
+	 */
 	if (S_ISDIR(inode->i_mode) && lli->lli_opendir_key == fd &&
 	    lli->lli_opendir_pid != 0)
 		ll_stop_statahead(inode, lli->lli_opendir_key);
@@ -395,15 +402,15 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 	__u32 opc = LUSTRE_OPC_ANY;
 	int rc;
 
-	/* Usually we come here only for NFSD, and we want open lock.
-	   But we can also get here with pre 2.6.15 patchless kernels, and in
-	   that case that lock is also ok */
+	/* Usually we come here only for NFSD, and we want open lock. */
 	/* We can also get here if there was cached open handle in revalidate_it
 	 * but it disappeared while we were getting from there to ll_file_open.
 	 * But this means this file was closed and immediately opened which
-	 * makes a good candidate for using OPEN lock */
+	 * makes a good candidate for using OPEN lock
+	 */
 	/* If lmmsize & lmm are not 0, we are just setting stripe info
-	 * parameters. No need for the open lock */
+	 * parameters. No need for the open lock
+	 */
 	if (!lmm && lmmsize == 0) {
 		itp->it_flags |= MDS_OPEN_LOCK;
 		if (itp->it_flags & FMODE_WRITE)
@@ -567,7 +574,8 @@ int ll_file_open(struct inode *inode, struct file *file)
 	if (!it || !it->d.lustre.it_disposition) {
 		/* Convert f_flags into access mode. We cannot use file->f_mode,
 		 * because everything but O_ACCMODE mask was stripped from
-		 * there */
+		 * there
+		 */
 		if ((oit.it_flags + 1) & O_ACCMODE)
 			oit.it_flags++;
 		if (file->f_flags & O_TRUNC)
@@ -576,17 +584,20 @@ int ll_file_open(struct inode *inode, struct file *file)
 		/* kernel only call f_op->open in dentry_open.  filp_open calls
 		 * dentry_open after call to open_namei that checks permissions.
 		 * Only nfsd_open call dentry_open directly without checking
-		 * permissions and because of that this code below is safe. */
+		 * permissions and because of that this code below is safe.
+		 */
 		if (oit.it_flags & (FMODE_WRITE | FMODE_READ))
 			oit.it_flags |= MDS_OPEN_OWNEROVERRIDE;
 
 		/* We do not want O_EXCL here, presumably we opened the file
-		 * already? XXX - NFS implications? */
+		 * already? XXX - NFS implications?
+		 */
 		oit.it_flags &= ~O_EXCL;
 
 		/* bug20584, if "it_flags" contains O_CREAT, the file will be
 		 * created if necessary, then "IT_CREAT" should be set to keep
-		 * consistent with it */
+		 * consistent with it
+		 */
 		if (oit.it_flags & O_CREAT)
 			oit.it_op |= IT_CREAT;
 
@@ -610,7 +621,8 @@ restart:
 	if (*och_p) { /* Open handle is present */
 		if (it_disposition(it, DISP_OPEN_OPEN)) {
 			/* Well, there's extra open request that we do not need,
-			   let's close it somehow. This will decref request. */
+			 * let's close it somehow. This will decref request.
+			 */
 			rc = it_open_error(DISP_OPEN_OPEN, it);
 			if (rc) {
 				mutex_unlock(&lli->lli_och_mutex);
@@ -631,10 +643,11 @@ restart:
 		LASSERT(*och_usecount == 0);
 		if (!it->d.lustre.it_disposition) {
 			/* We cannot just request lock handle now, new ELC code
-			   means that one of other OPEN locks for this file
-			   could be cancelled, and since blocking ast handler
-			   would attempt to grab och_mutex as well, that would
-			   result in a deadlock */
+			 * means that one of other OPEN locks for this file
+			 * could be cancelled, and since blocking ast handler
+			 * would attempt to grab och_mutex as well, that would
+			 * result in a deadlock
+			 */
 			mutex_unlock(&lli->lli_och_mutex);
 			it->it_create_mode |= M_CHECK_STALE;
 			rc = ll_intent_file_open(file->f_path.dentry, NULL, 0, it);
@@ -654,9 +667,11 @@ restart:
 
 		/* md_intent_lock() didn't get a request ref if there was an
 		 * open error, so don't do cleanup on the request here
-		 * (bug 3430) */
+		 * (bug 3430)
+		 */
 		/* XXX (green): Should not we bail out on any error here, not
-		 * just open error? */
+		 * just open error?
+		 */
 		rc = it_open_error(DISP_OPEN_OPEN, it);
 		if (rc)
 			goto out_och_free;
@@ -671,8 +686,9 @@ restart:
 	fd = NULL;
 
 	/* Must do this outside lli_och_mutex lock to prevent deadlock where
-	   different kind of OPEN lock for this same inode gets cancelled
-	   by ldlm_cancel_lru */
+	 * different kind of OPEN lock for this same inode gets cancelled
+	 * by ldlm_cancel_lru
+	 */
 	if (!S_ISREG(inode->i_mode))
 		goto out_och_free;
 
@@ -816,7 +832,8 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	 * broken;
 	 * LDLM_FL_EXCL: Set this flag so that it won't be matched by normal
 	 * open in ll_md_blocking_ast(). Otherwise as ll_md_blocking_lease_ast
-	 * doesn't deal with openhandle, so normal openhandle will be leaked. */
+	 * doesn't deal with openhandle, so normal openhandle will be leaked.
+	 */
 				LDLM_FL_NO_LRU | LDLM_FL_EXCL);
 	ll_finish_md_op_data(op_data);
 	ptlrpc_req_finished(req);
@@ -985,7 +1002,8 @@ int ll_merge_lvb(const struct lu_env *env, struct inode *inode)
 
 	ll_inode_size_lock(inode);
 	/* merge timestamps the most recently obtained from mds with
-	   timestamps obtained from osts */
+	 * timestamps obtained from osts
+	 */
 	LTIME_S(inode->i_atime) = lli->lli_lvb.lvb_atime;
 	LTIME_S(inode->i_mtime) = lli->lli_lvb.lvb_mtime;
 	LTIME_S(inode->i_ctime) = lli->lli_lvb.lvb_ctime;
@@ -1154,7 +1172,8 @@ restart:
 out:
 	cl_io_fini(env, io);
 	/* If any bit been read/written (result != 0), we just return
-	 * short read/write instead of restart io. */
+	 * short read/write instead of restart io.
+	 */
 	if ((result == 0 || result == -ENODATA) && io->ci_need_restart) {
 		CDEBUG(D_VFSTRACE, "Restart %s on %pD from %lld, count:%zd\n",
 		       iot == CIT_READ ? "read" : "write",
@@ -1430,7 +1449,8 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			stripe_count = 0;
 
 		/* if function called for directory - we should
-		 * avoid swab not existent lsm objects */
+		 * avoid swab not existent lsm objects
+		 */
 		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1)) {
 			lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lmm);
 			if (S_ISREG(body->mode))
@@ -1779,7 +1799,8 @@ static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
 	int rc = 0;
 
 	/* Get the extent count so we can calculate the size of
-	 * required fiemap buffer */
+	 * required fiemap buffer
+	 */
 	if (get_user(extent_count,
 	    &((struct ll_user_fiemap __user *)arg)->fm_extent_count))
 		return -EFAULT;
@@ -1803,7 +1824,8 @@ static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
 
 	/* If fm_extent_count is non-zero, read the first extent since
 	 * it is used to calculate end_offset and device from previous
-	 * fiemap call. */
+	 * fiemap call.
+	 */
 	if (extent_count) {
 		if (copy_from_user(&fiemap_s->fm_extents[0],
 		    (char __user *)arg + sizeof(*fiemap_s),
@@ -1914,7 +1936,8 @@ int ll_hsm_release(struct inode *inode)
 
 	/* Release the file.
 	 * NB: lease lock handle is released in mdc_hsm_release_pack() because
-	 * we still need it to pack l_remote_handle to MDT. */
+	 * we still need it to pack l_remote_handle to MDT.
+	 */
 	rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp, inode, och,
 				       &data_version);
 	och = NULL;
@@ -2004,7 +2027,8 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 	}
 
 	/* to be able to restore mtime and atime after swap
-	 * we need to first save them */
+	 * we need to first save them
+	 */
 	if (lsl->sl_flags &
 	    (SWAP_LAYOUTS_KEEP_MTIME | SWAP_LAYOUTS_KEEP_ATIME)) {
 		llss->ia1.ia_mtime = llss->inode1->i_mtime;
@@ -2016,7 +2040,8 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 	}
 
 	/* ultimate check, before swapping the layouts we check if
-	 * dataversion has changed (if requested) */
+	 * dataversion has changed (if requested)
+	 */
 	if (llss->check_dv1) {
 		rc = ll_data_version(llss->inode1, &dv, 0);
 		if (rc)
@@ -2039,9 +2064,11 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 
 	/* struct md_op_data is used to send the swap args to the mdt
 	 * only flags is missing, so we use struct mdc_swap_layouts
-	 * through the md_op_data->op_data */
+	 * through the md_op_data->op_data
+	 */
 	/* flags from user space have to be converted before they are send to
-	 * server, no flag is sent today, they are only used on the client */
+	 * server, no flag is sent today, they are only used on the client
+	 */
 	msl.msl_flags = 0;
 	rc = -ENOMEM;
 	op_data = ll_prep_md_op_data(NULL, llss->inode1, llss->inode2, NULL, 0,
@@ -2110,7 +2137,8 @@ static int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 		return -EINVAL;
 
 	/* Non-root users are forbidden to set or clear flags which are
-	 * NOT defined in HSM_USER_MASK. */
+	 * NOT defined in HSM_USER_MASK.
+	 */
 	if (((hss->hss_setmask | hss->hss_clearmask) & ~HSM_USER_MASK) &&
 	    !capable(CFS_CAP_SYS_ADMIN))
 		return -EPERM;
@@ -2534,15 +2562,17 @@ static int ll_flush(struct file *file, fl_owner_t id)
 	LASSERT(!S_ISDIR(inode->i_mode));
 
 	/* catch async errors that were recorded back when async writeback
-	 * failed for pages in this mapping. */
+	 * failed for pages in this mapping.
+	 */
 	rc = lli->lli_async_rc;
 	lli->lli_async_rc = 0;
 	err = lov_read_and_clear_async_rc(lli->lli_clob);
 	if (rc == 0)
 		rc = err;
 
-	/* The application has been told write failure already.
-	 * Do not report failure again. */
+	/* The application has been told about write failure already.
+	 * Do not report failure again.
+	 */
 	if (fd->fd_write_failed)
 		return 0;
 	return rc ? -EIO : 0;
@@ -2610,7 +2640,8 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	inode_lock(inode);
 
 	/* catch async errors that were recorded back when async writeback
-	 * failed for pages in this mapping. */
+	 * failed for pages in this mapping.
+	 */
 	if (!S_ISDIR(inode->i_mode)) {
 		err = lli->lli_async_rc;
 		lli->lli_async_rc = 0;
@@ -2681,7 +2712,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	 * I guess between lockd processes) and then compares pid.
 	 * As such we assign pid to the owner field to make it all work,
 	 * conflict with normal locks is unlikely since pid space and
-	 * pointer space for current->files are not intersecting */
+	 * pointer space for current->files are not intersecting
+	 */
 	if (file_lock->fl_lmops && file_lock->fl_lmops->lm_compare_owner)
 		flock.l_flock.owner = (unsigned long)file_lock->fl_pid;
 
@@ -2697,7 +2729,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 		 * order to process an unlock request we need all of the same
 		 * information that is given with a normal read or write record
 		 * lock request. To avoid creating another ldlm unlock (cancel)
-		 * message we'll treat a LCK_NL flock request as an unlock. */
+		 * message we'll treat a LCK_NL flock request as an unlock.
+		 */
 		einfo.ei_mode = LCK_NL;
 		break;
 	case F_WRLCK:
@@ -2728,7 +2761,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 #endif
 		flags = LDLM_FL_TEST_LOCK;
 		/* Save the old mode so that if the mode in the lock changes we
-		 * can decrement the appropriate reader or writer refcount. */
+		 * can decrement the appropriate reader or writer refcount.
+		 */
 		file_lock->fl_type = einfo.ei_mode;
 		break;
 	default:
@@ -2872,7 +2906,8 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 
 	/* XXX: Enable OBD_CONNECT_ATTRFID to reduce unnecessary getattr RPC.
 	 *      But under CMD case, it caused some lock issues, should be fixed
-	 *      with new CMD ibits lock. See bug 12718 */
+	 *      with new CMD ibits lock. See bug 12718
+	 */
 	if (exp_connect_flags(exp) & OBD_CONNECT_ATTRFID) {
 		struct lookup_intent oit = { .it_op = IT_GETATTR };
 		struct md_op_data *op_data;
@@ -2890,7 +2925,8 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		oit.it_create_mode |= M_CHECK_STALE;
 		rc = md_intent_lock(exp, op_data, NULL, 0,
 				    /* we are not interested in name
-				       based lookup */
+				     * based lookup
+				     */
 				    &oit, 0, &req,
 				    ll_md_blocking_ast, 0);
 		ll_finish_md_op_data(op_data);
@@ -2907,9 +2943,10 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		}
 
 		/* Unlinked? Unhash dentry, so it is not picked up later by
-		   do_lookup() -> ll_revalidate_it(). We cannot use d_drop
-		   here to preserve get_cwd functionality on 2.6.
-		   Bug 10503 */
+		 * do_lookup() -> ll_revalidate_it(). We cannot use d_drop
+		 * here to preserve get_cwd functionality on 2.6.
+		 * Bug 10503
+		 */
 		if (!d_inode(dentry)->i_nlink)
 			d_lustre_invalidate(dentry, 0);
 
@@ -3075,7 +3112,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 		return -ECHILD;
 
        /* as root inode are NOT getting validated in lookup operation,
-	* need to do it before permission check. */
+	* need to do it before permission check.
+	*/
 
 	if (is_root_inode(inode)) {
 		rc = __ll_inode_revalidate(inode->i_sb->s_root,
@@ -3274,7 +3312,8 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 			/* it can only be allowed to match after layout is
 			 * applied to inode otherwise false layout would be
 			 * seen. Applying layout should happen before dropping
-			 * the intent lock. */
+			 * the intent lock.
+			 */
 			ldlm_lock_allow_match(lock);
 		}
 	}
@@ -3304,7 +3343,8 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	 * within DLM_LVB of dlm reply; otherwise if the lock was ever
 	 * blocked and then granted via completion ast, we have to fetch
 	 * layout here. Please note that we can't use the LVB buffer in
-	 * completion AST because it doesn't have a large enough buffer */
+	 * completion AST because it doesn't have a large enough buffer
+	 */
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
 	if (rc == 0)
 		rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode),
@@ -3383,12 +3423,14 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	lvb_ready = !!(lock->l_flags & LDLM_FL_LVB_READY);
 	unlock_res_and_lock(lock);
 	/* checking lvb_ready is racy but this is okay. The worst case is
-	 * that multi processes may configure the file on the same time. */
+	 * that multi processes may configure the file on the same time.
+	 */
 	if (lvb_ready || !reconf) {
 		rc = -ENODATA;
 		if (lvb_ready) {
 			/* layout_gen must be valid if layout lock is not
-			 * cancelled and stripe has already set */
+			 * cancelled and stripe has already set
+			 */
 			*gen = ll_layout_version_get(lli);
 			rc = 0;
 		}
@@ -3402,7 +3444,8 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	/* for layout lock, lmm is returned in lock's lvb.
 	 * lvb_data is immutable if the lock is held so it's safe to access it
 	 * without res lock. See the description in ldlm_lock_decref_internal()
-	 * for the condition to free lvb_data of layout lock */
+	 * for the condition to free lvb_data of layout lock
+	 */
 	if (lock->l_lvb_data) {
 		rc = obd_unpackmd(sbi->ll_dt_exp, &md.lsm,
 				  lock->l_lvb_data, lock->l_lvb_len);
@@ -3421,7 +3464,8 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 		goto out;
 
 	/* set layout to file. Unlikely this will fail as old layout was
-	 * surely eliminated */
+	 * surely eliminated
+	 */
 	memset(&conf, 0, sizeof(conf));
 	conf.coc_opc = OBJECT_CONF_SET;
 	conf.coc_inode = inode;
@@ -3500,7 +3544,8 @@ int ll_layout_refresh(struct inode *inode, __u32 *gen)
 
 again:
 	/* mostly layout lock is caching on the local side, so try to match
-	 * it before grabbing layout lock mutex. */
+	 * it before grabbing layout lock mutex.
+	 */
 	mode = ll_take_md_lock(inode, MDS_INODELOCK_LAYOUT, &lockh, 0,
 			       LCK_CR | LCK_CW | LCK_PR | LCK_PW);
 	if (mode != 0) { /* hit cached lock */
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 626846e..fcb6657 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -76,7 +76,8 @@ void vvp_write_complete(struct ccc_object *club, struct ccc_page *page)
 
 /** Queues DONE_WRITING if
  * - done writing is allowed;
- * - inode has no no dirty pages; */
+ * - inode has no no dirty pages;
+ */
 void ll_queue_done_writing(struct inode *inode, unsigned long flags)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -106,7 +107,8 @@ void ll_queue_done_writing(struct inode *inode, unsigned long flags)
 		 * close() happen, epoch is closed as the inode is marked as
 		 * LLIF_EPOCH_PENDING. When pages are written inode should not
 		 * be inserted into the queue again, clear this flag to avoid
-		 * it. */
+		 * it.
+		 */
 		lli->lli_flags &= ~LLIF_DONE_WRITING;
 
 		wake_up(&lcq->lcq_waitq);
@@ -147,7 +149,8 @@ void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
 			LASSERT(*och);
 			LASSERT(!lli->lli_pending_och);
 			/* Inode is dirty and there is no pending write done
-			 * request yet, DONE_WRITE is to be sent later. */
+			 * request yet, DONE_WRITE is to be sent later.
+			 */
 			lli->lli_flags |= LLIF_EPOCH_PENDING;
 			lli->lli_pending_och = *och;
 			spin_unlock(&lli->lli_lock);
@@ -159,7 +162,8 @@ void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
 		if (flags & LLIF_DONE_WRITING) {
 			/* Some pages are still dirty, it is early to send
 			 * DONE_WRITE. Wait until all pages will be flushed
-			 * and try DONE_WRITE again later. */
+			 * and try DONE_WRITE again later.
+			 */
 			LASSERT(!(lli->lli_flags & LLIF_DONE_WRITING));
 			lli->lli_flags |= LLIF_DONE_WRITING;
 			spin_unlock(&lli->lli_lock);
@@ -187,7 +191,8 @@ void ll_ioepoch_close(struct inode *inode, struct md_op_data *op_data,
 		}
 
 		/* There is a pending DONE_WRITE -- close epoch with no
-		 * attribute change. */
+		 * attribute change.
+		 */
 		if (lli->lli_flags & LLIF_EPOCH_PENDING) {
 			spin_unlock(&lli->lli_lock);
 			goto out;
@@ -295,7 +300,8 @@ static void ll_done_writing(struct inode *inode)
 	rc = md_done_writing(ll_i2sbi(inode)->ll_md_exp, op_data, NULL);
 	if (rc == -EAGAIN)
 		/* MDS has instructed us to obtain Size-on-MDS attribute from
-		 * OSTs and send setattr to back to MDS. */
+		 * OSTs and send setattr to back to MDS.
+		 */
 		rc = ll_som_update(inode, op_data);
 	else if (rc)
 		CERROR("inode %lu mdc done_writing failed: rc = %d\n",
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index bbd5ab8f..12fdca9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -93,9 +93,10 @@ struct ll_remote_perm {
 	gid_t		   lrp_gid;
 	uid_t		   lrp_fsuid;
 	gid_t		   lrp_fsgid;
-	int		     lrp_access_perm; /* MAY_READ/WRITE/EXEC, this
-						    is access permission with
-						    lrp_fsuid/lrp_fsgid. */
+	int		   lrp_access_perm; /* MAY_READ/WRITE/EXEC, this
+					     * is access permission with
+					     * lrp_fsuid/lrp_fsgid.
+					     */
 };
 
 enum lli_flags {
@@ -106,7 +107,8 @@ enum lli_flags {
 	/* DONE WRITING is allowed. */
 	LLIF_DONE_WRITING       = (1 << 2),
 	/* Sizeon-on-MDS attributes are changed. An attribute update needs to
-	 * be sent to MDS. */
+	 * be sent to MDS.
+	 */
 	LLIF_SOM_DIRTY	  = (1 << 3),
 	/* File data is modified. */
 	LLIF_DATA_MODIFIED      = (1 << 4),
@@ -130,7 +132,8 @@ struct ll_inode_info {
 	/* identifying fields for both metadata and data stacks. */
 	struct lu_fid		   lli_fid;
 	/* Parent fid for accessing default stripe data on parent directory
-	 * for allocating OST objects after a mknod() and later open-by-FID. */
+	 * for allocating OST objects after a mknod() and later open-by-FID.
+	 */
 	struct lu_fid		   lli_pfid;
 
 	struct list_head	      lli_close_list;
@@ -139,11 +142,13 @@ struct ll_inode_info {
 
 	/* handle is to be sent to MDS later on done_writing and setattr.
 	 * Open handle data are needed for the recovery to reconstruct
-	 * the inode state on the MDS. XXX: recovery is not ready yet. */
+	 * the inode state on the MDS. XXX: recovery is not ready yet.
+	 */
 	struct obd_client_handle       *lli_pending_och;
 
 	/* We need all three because every inode may be opened in different
-	 * modes */
+	 * modes
+	 */
 	struct obd_client_handle       *lli_mds_read_och;
 	struct obd_client_handle       *lli_mds_write_och;
 	struct obd_client_handle       *lli_mds_exec_och;
@@ -160,7 +165,8 @@ struct ll_inode_info {
 	spinlock_t			lli_agl_lock;
 
 	/* Try to make the d::member and f::member are aligned. Before using
-	 * these members, make clear whether it is directory or not. */
+	 * these members, make clear whether it is directory or not.
+	 */
 	union {
 		/* for directory */
 		struct {
@@ -171,13 +177,15 @@ struct ll_inode_info {
 			/* since parent-child threads can share the same @file
 			 * struct, "opendir_key" is the token when dir close for
 			 * case of parent exit before child -- it is me should
-			 * cleanup the dir readahead. */
+			 * cleanup the dir readahead.
+			 */
 			void			   *d_opendir_key;
 			struct ll_statahead_info       *d_sai;
 			/* protect statahead stuff. */
 			spinlock_t			d_sa_lock;
-			/* "opendir_pid" is the token when lookup/revalid
-			 * -- I am the owner of dir statahead. */
+			/* "opendir_pid" is the token when lookup/revalidate
+			 * -- I am the owner of dir statahead.
+			 */
 			pid_t			   d_opendir_pid;
 		} d;
 
@@ -303,7 +311,8 @@ static inline struct ll_inode_info *ll_i2info(struct inode *inode)
 }
 
 /* default to about 40meg of readahead on a given system.  That much tied
- * up in 512k readahead requests serviced at 40ms each is about 1GB/s. */
+ * up in 512k readahead requests serviced@40ms each is about 1GB/s.
+ */
 #define SBI_DEFAULT_READAHEAD_MAX (40UL << (20 - PAGE_CACHE_SHIFT))
 
 /* default to read-ahead full files smaller than 2MB on the second read */
@@ -342,11 +351,13 @@ struct ra_io_arg {
 	unsigned long ria_end;    /* end offset of read-ahead*/
 	/* If stride read pattern is detected, ria_stoff means where
 	 * stride read is started. Note: for normal read-ahead, the
-	 * value here is meaningless, and also it will not be accessed*/
+	 * value here is meaningless, and also it will not be accessed
+	 */
 	pgoff_t ria_stoff;
 	/* ria_length and ria_pages are the length and pages length in the
 	 * stride I/O mode. And they will also be used to check whether
-	 * it is stride I/O read-ahead in the read-ahead pages*/
+	 * it is stride I/O read-ahead in the read-ahead pages
+	 */
 	unsigned long ria_length;
 	unsigned long ria_pages;
 };
@@ -453,7 +464,8 @@ struct eacl_table {
 
 struct ll_sb_info {
 	/* this protects pglist and ra_info.  It isn't safe to
-	 * grab from interrupt contexts */
+	 * grab from interrupt contexts
+	 */
 	spinlock_t		  ll_lock;
 	spinlock_t		  ll_pp_extent_lock; /* pp_extent entry*/
 	spinlock_t		  ll_process_lock; /* ll_rw_process_info */
@@ -500,13 +512,16 @@ struct ll_sb_info {
 	/* metadata stat-ahead */
 	unsigned int	      ll_sa_max;     /* max statahead RPCs */
 	atomic_t		  ll_sa_total;   /* statahead thread started
-						  * count */
+						  * count
+						  */
 	atomic_t		  ll_sa_wrong;   /* statahead thread stopped for
-						  * low hit ratio */
+						  * low hit ratio
+						  */
 	atomic_t		  ll_agl_total;  /* AGL thread started count */
 
-	dev_t		     ll_sdev_orig; /* save s_dev before assign for
-						 * clustered nfs */
+	dev_t			  ll_sdev_orig; /* save s_dev before assign for
+						 * clustered nfs
+						 */
 	struct rmtacl_ctl_table   ll_rct;
 	struct eacl_table	 ll_et;
 	__kernel_fsid_t		  ll_fsid;
@@ -617,13 +632,15 @@ struct ll_file_data {
 	__u32 fd_flags;
 	fmode_t fd_omode;
 	/* openhandle if lease exists for this file.
-	 * Borrow lli->lli_och_mutex to protect assignment */
+	 * Borrow lli->lli_och_mutex to protect assignment
+	 */
 	struct obd_client_handle *fd_lease_och;
 	struct obd_client_handle *fd_och;
 	struct file *fd_file;
 	/* Indicate whether need to report failure when close.
 	 * true: failure is known, not report again.
-	 * false: unknown failure, should report. */
+	 * false: unknown failure, should report.
+	 */
 	bool fd_write_failed;
 };
 
@@ -1105,39 +1122,44 @@ static inline u64 rce_ops2valid(int ops)
 struct ll_statahead_info {
 	struct inode	   *sai_inode;
 	atomic_t	    sai_refcount;   /* when access this struct, hold
-						 * refcount */
+					     * refcount
+					     */
 	unsigned int	    sai_generation; /* generation for statahead */
 	unsigned int	    sai_max;	/* max ahead of lookup */
 	__u64		   sai_sent;       /* stat requests sent count */
 	__u64		   sai_replied;    /* stat requests which received
-						 * reply */
+					    * reply
+					    */
 	__u64		   sai_index;      /* index of statahead entry */
 	__u64		   sai_index_wait; /* index of entry which is the
-						 * caller is waiting for */
+					    * caller is waiting for
+					    */
 	__u64		   sai_hit;	/* hit count */
 	__u64		   sai_miss;       /* miss count:
-						 * for "ls -al" case, it includes
-						 * hidden dentry miss;
-						 * for "ls -l" case, it does not
-						 * include hidden dentry miss.
-						 * "sai_miss_hidden" is used for
-						 * the later case.
-						 */
+					    * for "ls -al" case, it includes
+					    * hidden dentry miss;
+					    * for "ls -l" case, it does not
+					    * include hidden dentry miss.
+					    * "sai_miss_hidden" is used for
+					    * the later case.
+					    */
 	unsigned int	    sai_consecutive_miss; /* consecutive miss */
 	unsigned int	    sai_miss_hidden;/* "ls -al", but first dentry
-						 * is not a hidden one */
+					     * is not a hidden one
+					     */
 	unsigned int	    sai_skip_hidden;/* skipped hidden dentry count */
 	unsigned int	    sai_ls_all:1,   /* "ls -al", do stat-ahead for
-						 * hidden entries */
+					     * hidden entries
+					     */
 				sai_agl_valid:1;/* AGL is valid for the dir */
-	wait_queue_head_t	     sai_waitq;      /* stat-ahead wait queue */
+	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct ptlrpc_thread    sai_thread;     /* stat-ahead thread */
 	struct ptlrpc_thread    sai_agl_thread; /* AGL thread */
-	struct list_head	      sai_entries;    /* entry list */
-	struct list_head	      sai_entries_received; /* entries returned */
-	struct list_head	      sai_entries_stated;   /* entries stated */
-	struct list_head	      sai_entries_agl; /* AGL entries to be sent */
-	struct list_head	      sai_cache[LL_SA_CACHE_SIZE];
+	struct list_head	sai_entries;    /* entry list */
+	struct list_head	sai_entries_received; /* entries returned */
+	struct list_head	sai_entries_stated;   /* entries stated */
+	struct list_head	sai_entries_agl; /* AGL entries to be sent */
+	struct list_head	sai_cache[LL_SA_CACHE_SIZE];
 	spinlock_t		sai_cache_lock[LL_SA_CACHE_SIZE];
 	atomic_t		sai_cache_count; /* entry count in cache */
 };
@@ -1311,13 +1333,15 @@ int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
 /** direct write pages */
 struct ll_dio_pages {
 	/** page array to be written. we don't support
-	 * partial pages except the last one. */
+	 * partial pages except the last one.
+	 */
 	struct page **ldp_pages;
 	/* offset of each page */
 	loff_t       *ldp_offsets;
 	/** if ldp_offsets is NULL, it means a sequential
 	 * pages to be written, then this is the file offset
-	 * of the * first page. */
+	 * of the first page.
+	 */
 	loff_t	ldp_start_offset;
 	/** how many bytes are to be written. */
 	size_t	ldp_size;
@@ -1359,7 +1383,8 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		 * remote MDT, where the object is, will grant
 		 * UPDATE|PERM lock. The inode will be attached to both
 		 * LOOKUP and PERM locks, so revoking either locks will
-		 * case the dcache being cleared */
+		 * case the dcache being cleared
+		 */
 		if (it->d.lustre.it_remote_lock_mode) {
 			handle.cookie = it->d.lustre.it_remote_lock_handle;
 			CDEBUG(D_DLMTRACE, "setting l_data to inode %p(%lu/%u) for remote lock %#llx\n",
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b652aee..d03f884 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -204,7 +204,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
 		/* flag mdc connection as lightweight, only used for test
-		 * purpose, use with care */
+		 * purpose, use with care
+		 */
 		data->ocd_connect_flags |= OBD_CONNECT_LIGHTWEIGHT;
 
 	data->ocd_ibits_known = MDS_INODELOCK_FULL;
@@ -252,7 +253,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 
 	/* For mount, we only need fs info from MDT0, and also in DNE, it
 	 * can make sure the client can be mounted as long as MDT0 is
-	 * available */
+	 * available
+	 */
 	err = obd_statfs(NULL, sbi->ll_md_exp, osfs,
 			cfs_time_shift_64(-OBD_STATFS_CACHE_SECONDS),
 			OBD_STATFS_FOR_MDT0);
@@ -265,7 +267,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	 * we can access the MDC export directly and exp_connect_flags will
 	 * be non-zero, but if accessing an upgraded 2.1 server it will
 	 * have the correct flags filled in.
-	 * XXX: fill in the LMV exp_connect_flags from MDC(s). */
+	 * XXX: fill in the LMV exp_connect_flags from MDC(s).
+	 */
 	valid = exp_connect_flags(sbi->ll_md_exp) & CLIENT_CONNECT_MDT_REQD;
 	if (exp_connect_flags(sbi->ll_md_exp) != 0 &&
 	    valid != CLIENT_CONNECT_MDT_REQD) {
@@ -382,7 +385,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 		/* OBD_CONNECT_CKSUM should always be set, even if checksums are
 		 * disabled by default, because it can still be enabled on the
 		 * fly via /sys. As a consequence, we still need to come to an
-		 * agreement on the supported algorithms at connect time */
+		 * agreement on the supported algorithms at connect time
+		 */
 		data->ocd_connect_flags |= OBD_CONNECT_CKSUM;
 
 		if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CKSUM_ADLER_ONLY))
@@ -453,7 +457,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 #endif
 
 	/* make root inode
-	 * XXX: move this to after cbd setup? */
+	 * XXX: move this to after cbd setup?
+	 */
 	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS;
 	if (sbi->ll_flags & LL_SBI_RMT_CLIENT)
 		valid |= OBD_MD_FLRMTPERM;
@@ -543,9 +548,11 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 
 	/* We set sb->s_dev equal on all lustre clients in order to support
 	 * NFS export clustering.  NFSD requires that the FSID be the same
-	 * on all clients. */
+	 * on all clients.
+	 */
 	/* s_dev is also used in lt_compare() to compare two fs, but that is
-	 * only a node-local comparison. */
+	 * only a node-local comparison.
+	 */
 	uuid = obd_get_uuid(sbi->ll_md_exp);
 	if (uuid) {
 		sb->s_dev = get_uuid2int(uuid->uuid, strlen(uuid->uuid));
@@ -625,7 +632,8 @@ static void client_common_put_super(struct super_block *sb)
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
 	/* wait till all OSCs are gone, since cl_cache is accessing sbi.
-	 * see LU-2543. */
+	 * see LU-2543.
+	 */
 	obd_zombie_barrier();
 
 	ldebugfs_unregister_mountpoint(sbi);
@@ -646,7 +654,8 @@ void ll_kill_super(struct super_block *sb)
 	sbi = ll_s2sbi(sb);
 	/* we need to restore s_dev from changed for clustered NFS before
 	 * put_super because new kernels have cached s_dev and change sb->s_dev
-	 * in put_super not affected real removing devices */
+	 * in put_super not affected real removing devices
+	 */
 	if (sbi) {
 		sb->s_dev = sbi->ll_sdev_orig;
 		sbi->ll_umounting = 1;
@@ -889,8 +898,9 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	sb->s_d_op = &ll_d_ops;
 
 	/* Generate a string unique to this super, in case some joker tries
-	   to mount the same fs at two mount points.
-	   Use the address of the super itself.*/
+	 * to mount the same fs at two mount points.
+	 * Use the address of the super itself.
+	 */
 	cfg->cfg_instance = sb;
 	cfg->cfg_uuid = lsi->lsi_llsbi->ll_sb_uuid;
 	cfg->cfg_callback = class_config_llog_handler;
@@ -963,7 +973,8 @@ void ll_put_super(struct super_block *sb)
 	}
 
 	/* We need to set force before the lov_disconnect in
-	   lustre_common_put_super, since l_d cleans up osc's as well. */
+	 * lustre_common_put_super, since l_d cleans up osc's as well.
+	 */
 	if (force) {
 		next = 0;
 		while ((obd = class_devices_in_group(&sbi->ll_sb_uuid,
@@ -1114,7 +1125,8 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
 		if (rc == -ENOENT) {
 			clear_nlink(inode);
 			/* Unlinked special device node? Or just a race?
-			 * Pretend we done everything. */
+			 * Pretend we did everything.
+			 */
 			if (!S_ISREG(inode->i_mode) &&
 			    !S_ISDIR(inode->i_mode)) {
 				ia_valid = op_data->op_attr.ia_valid;
@@ -1137,7 +1149,8 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
 
 	ia_valid = op_data->op_attr.ia_valid;
 	/* inode size will be in cl_setattr_ost, can't do it now since dirty
-	 * cache is not cleared yet. */
+	 * cache is not cleared yet.
+	 */
 	op_data->op_attr.ia_valid &= ~(TIMES_SET_FLAGS | ATTR_SIZE);
 	rc = simple_setattr(dentry, &op_data->op_attr);
 	op_data->op_attr.ia_valid = ia_valid;
@@ -1173,7 +1186,8 @@ static int ll_setattr_done_writing(struct inode *inode,
 	rc = md_done_writing(ll_i2sbi(inode)->ll_md_exp, op_data, mod);
 	if (rc == -EAGAIN)
 		/* MDS has instructed us to obtain Size-on-MDS attribute
-		 * from OSTs and send setattr to back to MDS. */
+		 * from OSTs and send setattr to back to MDS.
+		 */
 		rc = ll_som_update(inode, op_data);
 	else if (rc)
 		CERROR("inode %lu mdc truncate failed: rc = %d\n",
@@ -1220,7 +1234,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 
 		/* The maximum Lustre file size is variable, based on the
 		 * OST maximum object size and number of stripes.  This
-		 * needs another check in addition to the VFS check above. */
+		 * needs another check in addition to the VFS check above.
+		 */
 		if (attr->ia_size > ll_file_maxbytes(inode)) {
 			CDEBUG(D_INODE, "file "DFID" too large %llu > %llu\n",
 			       PFID(&lli->lli_fid), attr->ia_size,
@@ -1268,7 +1283,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	}
 
 	/* We always do an MDS RPC, even if we're only changing the size;
-	 * only the MDS knows whether truncate() should fail with -ETXTBUSY */
+	 * only the MDS knows whether truncate() should fail with -ETXTBUSY
+	 */
 
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
 	if (!op_data)
@@ -1302,7 +1318,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	/* if not in HSM import mode, clear size attr for released file
 	 * we clear the attribute send to MDT in op_data, not the original
 	 * received from caller in attr which is used later to
-	 * decide return code */
+	 * decide return code
+	 */
 	if (file_is_released && (attr->ia_valid & ATTR_SIZE) && !hsm_import)
 		op_data->op_attr.ia_valid &= ~ATTR_SIZE;
 
@@ -1340,7 +1357,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		 * extent lock (new_size:EOF for truncate).  It may seem
 		 * excessive to send mtime/atime updates to OSTs when not
 		 * setting times to past, but it is necessary due to possible
-		 * time de-synchronization between MDT inode and OST objects */
+		 * time de-synchronization between MDT inode and OST objects
+		 */
 		if (attr->ia_valid & ATTR_SIZE)
 			down_write(&lli->lli_trunc_sem);
 		rc = cl_setattr_ost(inode, attr);
@@ -1468,7 +1486,8 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	/* We need to downshift for all 32-bit kernels, because we can't
 	 * tell if the kernel is being called via sys_statfs64() or not.
 	 * Stop before overflowing f_bsize - in which case it is better
-	 * to just risk EOVERFLOW if caller is using old sys_statfs(). */
+	 * to just risk EOVERFLOW if caller is using old sys_statfs().
+	 */
 	if (sizeof(long) < 8) {
 		while (osfs.os_blocks > ~0UL && sfs->f_bsize < 0x40000000) {
 			sfs->f_bsize <<= 1;
@@ -1602,7 +1621,8 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 			/* As it is possible a blocking ast has been processed
 			 * by this time, we need to check there is an UPDATE
 			 * lock on the client and set LLIF_MDS_SIZE_LOCK holding
-			 * it. */
+			 * it.
+			 */
 			mode = ll_take_md_lock(inode, MDS_INODELOCK_UPDATE,
 					       &lockh, LDLM_FL_CBPENDING,
 					       LCK_CR | LCK_CW |
@@ -1615,7 +1635,8 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 					       inode->i_ino, lli->lli_flags);
 				} else {
 					/* Use old size assignment to avoid
-					 * deadlock bz14138 & bz14326 */
+					 * deadlock bz14138 & bz14326
+					 */
 					i_size_write(inode, body->size);
 					spin_lock(&lli->lli_lock);
 					lli->lli_flags |= LLIF_MDS_SIZE_LOCK;
@@ -1625,7 +1646,8 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 			}
 		} else {
 			/* Use old size assignment to avoid
-			 * deadlock bz14138 & bz14326 */
+			 * deadlock bz14138 & bz14326
+			 */
 			i_size_write(inode, body->size);
 
 			CDEBUG(D_VFSTRACE, "inode=%lu, updating i_size %llu\n",
@@ -1655,7 +1677,8 @@ void ll_read_inode2(struct inode *inode, void *opaque)
 	/* Core attributes from the MDS first.  This is a new inode, and
 	 * the VFS doesn't zero times in the core inode so we have to do
 	 * it ourselves.  They will be overwritten by either MDS or OST
-	 * attributes - we just need to make sure they aren't newer. */
+	 * attributes - we just need to make sure they aren't newer.
+	 */
 	LTIME_S(inode->i_mtime) = 0;
 	LTIME_S(inode->i_atime) = 0;
 	LTIME_S(inode->i_ctime) = 0;
@@ -1689,7 +1712,8 @@ void ll_delete_inode(struct inode *inode)
 
 	if (S_ISREG(inode->i_mode) && lli->lli_clob)
 		/* discard all dirty pages before truncating them, required by
-		 * osc_extent implementation at LU-1030. */
+		 * osc_extent implementation at LU-1030.
+		 */
 		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF,
 				   CL_FSYNC_DISCARD, 1);
 
@@ -1984,7 +2008,8 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	 * 1. proc1: mdt returns a lsm but not granting layout
 	 * 2. layout was changed by another client
 	 * 3. proc2: refresh layout and layout lock granted
-	 * 4. proc1: to apply a stale layout */
+	 * 4. proc1: to apply a stale layout
+	 */
 	if (it && it->d.lustre.it_lock_mode != 0) {
 		struct lustre_handle lockh;
 		struct ldlm_lock *lock;
@@ -2097,7 +2122,8 @@ int ll_process_config(struct lustre_cfg *lcfg)
 	LASSERT(s2lsi((struct super_block *)sb)->lsi_lmd->lmd_magic == LMD_MAGIC);
 
 	/* Note we have not called client_common_fill_super yet, so
-	   proc fns must be able to handle that! */
+	 * proc fns must be able to handle that!
+	 */
 	rc = class_process_proc_param(PARAM_LLITE, lvars.obd_vars,
 				      lcfg, sb);
 	if (rc > 0)
@@ -2146,7 +2172,8 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 	/* If the file is being opened after mknod() (normally due to NFS)
 	 * try to use the default stripe data from parent directory for
-	 * allocating OST objects.  Try to pass the parent FID to MDS. */
+	 * allocating OST objects.  Try to pass the parent FID to MDS.
+	 */
 	if (opc == LUSTRE_OPC_CREATE && i1 == i2 && S_ISREG(i2->i_mode) &&
 	    !ll_i2info(i2)->lli_has_smd) {
 		struct ll_inode_info *lli = ll_i2info(i2);
@@ -2237,7 +2264,8 @@ char *ll_get_fsname(struct super_block *sb, char *buf, int buflen)
 	if (!buf) {
 		/* this means the caller wants to use static buffer
 		 * and it doesn't care about race. Usually this is
-		 * in error reporting path */
+		 * in error reporting path
+		 */
 		buf = fsname_static;
 		buflen = sizeof(fsname_static);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index a0a58fd..d8c39fb 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -151,8 +151,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 
 		LASSERT(cio->cui_cl.cis_io == io);
 
-		/* mmap lock must be MANDATORY it has to cache
-		 * pages. */
+		/* mmap lock must be MANDATORY it has to cache pages. */
 		io->ci_lockreq = CILR_MANDATORY;
 		cio->cui_fd = fd;
 	} else {
@@ -199,7 +198,8 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 
 	/* we grab lli_trunc_sem to exclude truncate case.
 	 * Otherwise, we could add dirty pages into osc cache
-	 * while truncate is on-going. */
+	 * while truncate is on-going.
+	 */
 	inode = ccc_object_inode(io->ci_obj);
 	lli = ll_i2info(inode);
 	down_read(&lli->lli_trunc_sem);
@@ -220,7 +220,8 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 
 			/* page was truncated and lock was cancelled, return
 			 * ENODATA so that VM_FAULT_NOPAGE will be returned
-			 * to handle_mm_fault(). */
+			 * to handle_mm_fault().
+			 */
 			if (result == 0)
 				result = -ENODATA;
 		} else if (!PageDirty(vmpage)) {
@@ -313,7 +314,8 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 		result = cl_io_loop(env, io);
 
 		/* ft_flags are only valid if we reached
-		 * the call to filemap_fault */
+		 * the call to filemap_fault
+		 */
 		if (vio->u.fault.fault.ft_flags_valid)
 			fault_ret = vio->u.fault.fault.ft_flags;
 
@@ -342,9 +344,10 @@ static int ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	int result;
 	sigset_t set;
 
-	/* Only SIGKILL and SIGTERM is allowed for fault/nopage/mkwrite
+	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
 	 * so that it can be killed by admin but not cause segfault by
-	 * other signals. */
+	 * other signals.
+	 */
 	set = cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM));
 
 restart:
@@ -445,7 +448,8 @@ static void ll_vm_close(struct vm_area_struct *vma)
 }
 
 /* XXX put nice comment here.  talk about __free_pte -> dirty pages and
- * nopage's reference passing to the pte */
+ * nopage's reference passing to the pte
+ */
 int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last)
 {
 	int rc = -ENOENT;
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 58ee239..74a8868 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -105,7 +105,8 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 		return ERR_PTR(rc);
 
 	/* Because inode is NULL, ll_prep_md_op_data can not
-	 * be used here. So we allocate op_data ourselves */
+	 * be used here. So we allocate op_data ourselves
+	 */
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
 	if (!op_data)
 		return ERR_PTR(-ENOMEM);
@@ -213,7 +214,8 @@ static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
 				   unsigned type)
 {
 	/* It is hack to access lde_fid for comparison with lgd_fid.
-	 * So the input 'name' must be part of the 'lu_dirent'. */
+	 * So the input 'name' must be part of the 'lu_dirent'.
+	 */
 	struct lu_dirent *lde = container_of0(name, struct lu_dirent, lde_name);
 	struct ll_getname_data *lgd =
 		container_of(ctx, struct ll_getname_data, ctx);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 4d2e4b2..f5fe928 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -345,7 +345,8 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 		return rc;
 
 	/* Cap this at the current max readahead window size, the readahead
-	 * algorithm does this anyway so it's pointless to set it larger. */
+	 * algorithm does this anyway so it's pointless to set it larger.
+	 */
 	if (pages_number > sbi->ll_ra_info.ra_max_pages_per_file) {
 		CERROR("can't set max_read_ahead_whole_mb more than max_read_ahead_per_file_mb: %lu\n",
 		       sbi->ll_ra_info.ra_max_pages_per_file >> (20 - PAGE_CACHE_SHIFT));
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 7e62198..3121458 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -180,7 +180,8 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		__u64 bits = lock->l_policy_data.l_inodebits.bits;
 
 		/* Inode is set to lock->l_resource->lr_lvb_inode
-		 * for mdc - bug 24555 */
+		 * for mdc - bug 24555
+		 */
 		LASSERT(!lock->l_ast_data);
 
 		if (!inode)
@@ -202,7 +203,8 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		}
 
 		/* For OPEN locks we differentiate between lock modes
-		 * LCK_CR, LCK_CW, LCK_PR - bug 22891 */
+		 * LCK_CR, LCK_CW, LCK_PR - bug 22891
+		 */
 		if (bits & MDS_INODELOCK_OPEN)
 			ll_have_md_lock(inode, &bits, lock->l_req_mode);
 
@@ -285,7 +287,8 @@ __u32 ll_i2suppgid(struct inode *i)
 /* Pack the required supplementary groups into the supplied groups array.
  * If we don't need to use the groups from the target inode(s) then we
  * instead pack one or more groups from the user's supplementary group
- * array in case it might be useful.  Not needed if doing an MDS-side upcall. */
+ * array in case it might be useful.  Not needed if doing an MDS-side upcall.
+ */
 void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
 {
 	LASSERT(i1);
@@ -388,7 +391,8 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	int rc = 0;
 
 	/* NB 1 request reference will be taken away by ll_intent_lock()
-	 * when I return */
+	 * when I return
+	 */
 	CDEBUG(D_DENTRY, "it %p it_disposition %x\n", it,
 	       it->d.lustre.it_disposition);
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
@@ -399,13 +403,14 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		ll_set_lock_data(ll_i2sbi(parent)->ll_md_exp, inode, it, &bits);
 
 		/* We used to query real size from OSTs here, but actually
-		   this is not needed. For stat() calls size would be updated
-		   from subsequent do_revalidate()->ll_inode_revalidate_it() in
-		   2.4 and
-		   vfs_getattr_it->ll_getattr()->ll_inode_revalidate_it() in 2.6
-		   Everybody else who needs correct file size would call
-		   ll_glimpse_size or some equivalent themselves anyway.
-		   Also see bug 7198. */
+		 * this is not needed. For stat() calls size would be updated
+		 * from subsequent do_revalidate()->ll_inode_revalidate_it() in
+		 * 2.4 and
+		 * vfs_getattr_it->ll_getattr()->ll_inode_revalidate_it() in 2.6
+		 * Everybody else who needs correct file size would call
+		 * ll_glimpse_size or some equivalent themselves anyway.
+		 * Also see bug 7198.
+		 */
 	}
 
 	/* Only hash *de if it is unhashed (new dentry).
@@ -422,8 +427,9 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		*de = alias;
 	} else if (!it_disposition(it, DISP_LOOKUP_NEG)  &&
 		   !it_disposition(it, DISP_OPEN_CREATE)) {
-		/* With DISP_OPEN_CREATE dentry will
-		   instantiated in ll_create_it. */
+		/* With DISP_OPEN_CREATE dentry will be
+		 * instantiated in ll_create_it.
+		 */
 		LASSERT(!d_inode(*de));
 		d_instantiate(*de, inode);
 	}
@@ -672,7 +678,8 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 
 	/* We asked for a lock on the directory, but were granted a
 	 * lock on the inode.  Since we finally have an inode pointer,
-	 * stuff it in the lock. */
+	 * stuff it in the lock.
+	 */
 	CDEBUG(D_DLMTRACE, "setting l_ast_data to inode %p (%lu/%u)\n",
 	       inode, inode->i_ino, inode->i_generation);
 	ll_set_lock_data(sbi->ll_md_exp, inode, it, NULL);
@@ -867,7 +874,8 @@ int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 	/* The MDS sent back the EA because we unlinked the last reference
 	 * to this file. Use this EA to unlink the objects on the OST.
 	 * It's opaque so we don't swab here; we leave it to obd_unpackmd() to
-	 * check it is complete and sensible. */
+	 * check it is complete and sensible.
+	 */
 	eadata = req_capsule_server_sized_get(&request->rq_pill, &RMF_MDT_MD,
 					      body->eadatasize);
 	LASSERT(eadata);
@@ -917,7 +925,8 @@ out:
 /* ll_unlink() doesn't update the inode with the new link count.
  * Instead, ll_ddelete() and ll_d_iput() will update it based upon if there
  * is any lock existing. They will recycle dentries and inodes based upon locks
- * too. b=20433 */
+ * too. b=20433
+ */
 static int ll_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct ptlrpc_request *request = NULL;
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index da71937..d685c8f 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -120,7 +120,8 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 
 			/* this is too bad. Someone is trying to write the
 			 * page w/o holding inode mutex. This means we can
-			 * add dirty pages into cache during truncate */
+			 * add dirty pages into cache during truncate
+			 */
 			CERROR("Proc %s is dirtying page w/o inode lock, this will break truncate\n",
 			       current->comm);
 			dump_stack();
@@ -239,7 +240,8 @@ int ll_prepare_write(struct file *file, struct page *vmpage, unsigned from,
 			ll_cl_fini(lcc);
 		}
 		/* returning 0 in prepare assumes commit must be called
-		 * afterwards */
+		 * afterwards
+		 */
 	} else {
 		result = PTR_ERR(lcc);
 	}
@@ -295,8 +297,8 @@ static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
  * to get an ra budget that is larger than the remaining readahead pages
  * and reach here at exactly the same time. They will compute /a ret to
  * consume the remaining pages, but will fail at atomic_add_return() and
- * get a zero ra window, although there is still ra space remaining. - Jay */
-
+ * get a zero ra window, although there is still ra space remaining. - Jay
+ */
 static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 				     struct ra_io_arg *ria,
 				     unsigned long pages)
@@ -306,7 +308,8 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 
 	/* If read-ahead pages left are less than 1M, do not do read-ahead,
 	 * otherwise it will form small read RPC(< 1M), which hurt server
-	 * performance a lot. */
+	 * performance a lot.
+	 */
 	ret = min(ra->ra_max_pages - atomic_read(&ra->ra_cur_pages), pages);
 	if (ret < 0 || ret < min_t(long, PTLRPC_MAX_BRW_PAGES, pages)) {
 		ret = 0;
@@ -323,7 +326,8 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 	 * branch is more expensive than subtracting zero from the result.
 	 *
 	 * Strided read is left unaligned to avoid small fragments beyond
-	 * the RPC boundary from needing an extra read RPC. */
+	 * the RPC boundary from needing an extra read RPC.
+	 */
 	if (ria->ria_pages == 0) {
 		long beyond_rpc = (ria->ria_start + ret) % PTLRPC_MAX_BRW_PAGES;
 
@@ -514,13 +518,15 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 /* Limit this to the blocksize instead of PTLRPC_BRW_MAX_SIZE, since we don't
  * know what the actual RPC size is.  If this needs to change, it makes more
  * sense to tune the i_blkbits value for the file based on the OSTs it is
- * striped over, rather than having a constant value for all files here. */
+ * striped over, rather than having a constant value for all files here.
+ */
 
 /* RAS_INCREASE_STEP should be (1UL << (inode->i_blkbits - PAGE_CACHE_SHIFT)).
  * Temporarily set RAS_INCREASE_STEP to 1MB. After 4MB RPC is enabled
  * by default, this should be adjusted corresponding with max_read_ahead_mb
  * and max_read_ahead_per_file_mb otherwise the readahead budget can be used
- * up quickly which will affect read performance significantly. See LU-2816 */
+ * up quickly which will affect read performance significantly. See LU-2816
+ */
 #define RAS_INCREASE_STEP(inode) (ONE_MB_BRW_SIZE >> PAGE_CACHE_SHIFT)
 
 static inline int stride_io_mode(struct ll_readahead_state *ras)
@@ -599,7 +605,8 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 	/* If ria_length == ria_pages, it means non-stride I/O mode,
 	 * idx should always inside read-ahead window in this case
 	 * For stride I/O mode, just check whether the idx is inside
-	 * the ria_pages. */
+	 * the ria_pages.
+	 */
 	return ria->ria_length == 0 || ria->ria_length == ria->ria_pages ||
 	       (idx >= ria->ria_stoff && (idx - ria->ria_stoff) %
 		ria->ria_length < ria->ria_pages);
@@ -633,11 +640,13 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 		} else if (stride_ria) {
 			/* If it is not in the read-ahead window, and it is
 			 * read-ahead mode, then check whether it should skip
-			 * the stride gap */
+			 * the stride gap
+			 */
 			pgoff_t offset;
 			/* FIXME: This assertion only is valid when it is for
 			 * forward read-ahead, it will be fixed when backward
-			 * read-ahead is implemented */
+			 * read-ahead is implemented
+			 */
 			LASSERTF(page_idx > ria->ria_stoff, "Invalid page_idx %lu rs %lu re %lu ro %lu rl %lu rp %lu\n",
 				 page_idx,
 				 ria->ria_start, ria->ria_end, ria->ria_stoff,
@@ -720,7 +729,8 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		 */
 		/* Note: we only trim the RPC, instead of extending the RPC
 		 * to the boundary, so to avoid reading too much pages during
-		 * random reading. */
+		 * random reading.
+		 */
 		rpc_boundary = (end + 1) & (~(PTLRPC_MAX_BRW_PAGES - 1));
 		if (rpc_boundary > 0)
 			rpc_boundary--;
@@ -773,7 +783,8 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	 * the ras we need to go back and update the ras so that the
 	 * next read-ahead tries from where we left off.  we only do so
 	 * if the region we failed to issue read-ahead on is still ahead
-	 * of the app and behind the next index to start read-ahead from */
+	 * of the app and behind the next index to start read-ahead from
+	 */
 	CDEBUG(D_READA, "ra_end %lu end %lu stride end %lu \n",
 	       ra_end, end, ria->ria_end);
 
@@ -879,7 +890,8 @@ static void ras_update_stride_detector(struct ll_readahead_state *ras,
 }
 
 /* Stride Read-ahead window will be increased inc_len according to
- * stride I/O pattern */
+ * stride I/O pattern
+ */
 static void ras_stride_increase_window(struct ll_readahead_state *ras,
 				       struct ll_ra_info *ra,
 				       unsigned long inc_len)
@@ -950,7 +962,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	 * or reads to some other part of the file.  Secondly if we get a
 	 * read-ahead miss that we think we've previously issued.  This can
 	 * be a symptom of there being so many read-ahead pages that the VM is
-	 * reclaiming it before we get to it. */
+	 * reclaiming it before we get to it.
+	 */
 	if (!index_in_window(index, ras->ras_last_readpage, 8, 8)) {
 		zero = 1;
 		ll_ra_stats_inc_sbi(sbi, RA_STAT_DISTANT_READPAGE);
@@ -967,7 +980,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	 * file up to ra_max_pages_per_file.  This is simply a best effort
 	 * and only occurs once per open file.  Normal RA behavior is reverted
 	 * to for subsequent IO.  The mmap case does not increment
-	 * ras_requests and thus can never trigger this behavior. */
+	 * ras_requests and thus can never trigger this behavior.
+	 */
 	if (ras->ras_requests == 2 && !ras->ras_request_index) {
 		__u64 kms_pages;
 
@@ -1013,14 +1027,16 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 			    stride_io_mode(ras)) {
 				/*If stride-RA hit cache miss, the stride dector
 				 *will not be reset to avoid the overhead of
-				 *redetecting read-ahead mode */
+				 *redetecting read-ahead mode
+				 */
 				if (index != ras->ras_last_readpage + 1)
 					ras->ras_consecutive_pages = 0;
 				ras_reset(inode, ras, index);
 				RAS_CDEBUG(ras);
 			} else {
 				/* Reset both stride window and normal RA
-				 * window */
+				 * window
+				 */
 				ras_reset(inode, ras, index);
 				ras->ras_consecutive_pages++;
 				ras_stride_reset(ras);
@@ -1029,7 +1045,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		} else if (stride_io_mode(ras)) {
 			/* If this is contiguous read but in stride I/O mode
 			 * currently, check whether stride step still is valid,
-			 * if invalid, it will reset the stride ra window*/
+			 * if invalid, it will reset the stride ra window
+			 */
 			if (!index_in_stride_window(ras, index)) {
 				/* Shrink stride read-ahead window to be zero */
 				ras_stride_reset(ras);
@@ -1045,7 +1062,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	if (stride_io_mode(ras))
 		/* Since stride readahead is sensitive to the offset
 		 * of read-ahead, so we use original offset here,
-		 * instead of ras_window_start, which is RPC aligned */
+		 * instead of ras_window_start, which is RPC aligned
+		 */
 		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
 	else
 		ras->ras_next_readahead = max(ras->ras_window_start,
@@ -1053,7 +1071,8 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	RAS_CDEBUG(ras);
 
 	/* Trigger RA in the mmap case where ras_consecutive_requests
-	 * is not incremented and thus can't be used to trigger RA */
+	 * is not incremented and thus can't be used to trigger RA
+	 */
 	if (!ras->ras_window_len && ras->ras_consecutive_pages == 4) {
 		ras->ras_window_len = RAS_INCREASE_STEP(inode);
 		goto out_unlock;
@@ -1151,14 +1170,16 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 		/* Flush page failed because the extent is being written out.
 		 * Wait for the write of extent to be finished to avoid
 		 * breaking kernel which assumes ->writepage should mark
-		 * PageWriteback or clean the page. */
+		 * PageWriteback or clean the page.
+		 */
 		result = cl_sync_file_range(inode, offset,
 					    offset + PAGE_CACHE_SIZE - 1,
 					    CL_FSYNC_LOCAL, 1);
 		if (result > 0) {
 			/* actually we may have written more than one page.
 			 * decreasing this page because the caller will count
-			 * it. */
+			 * it.
+			 */
 			wbc->nr_to_write -= result - 1;
 			result = 0;
 		}
@@ -1208,7 +1229,8 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	if (sbi->ll_umounting)
 		/* if the mountpoint is being umounted, all pages have to be
 		 * evicted to avoid hitting LBUG when truncate_inode_pages()
-		 * is called later on. */
+		 * is called later on.
+		 */
 		ignore_layout = 1;
 	result = cl_sync_file_range(inode, start, end, mode, ignore_layout);
 	if (result > 0) {
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 6167c9d..89fd513 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -145,7 +145,8 @@ static int ll_releasepage(struct page *vmpage, RELEASEPAGE_ARG_TYPE gfp_mask)
 		/* If we can't allocate an env we won't call cl_page_put()
 		 * later on which further means it's impossible to drop
 		 * page refcount by cl_page, so ask kernel to not free
-		 * this page. */
+		 * this page.
+		 */
 		return 0;
 
 	page = cl_vmpage_page(vmpage, obj);
@@ -212,7 +213,8 @@ static inline int ll_get_user_pages(int rw, unsigned long user_addr,
 }
 
 /*  ll_free_user_pages - tear down page struct array
- *  @pages: array of page struct pointers underlying target buffer */
+ *  @pages: array of page struct pointers underlying target buffer
+ */
 static void ll_free_user_pages(struct page **pages, int npages, int do_dirty)
 {
 	int i;
@@ -266,7 +268,8 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 		do_io = true;
 
 		/* check the page type: if the page is a host page, then do
-		 * write directly */
+		 * write directly
+		 */
 		if (clp->cp_type == CPT_CACHEABLE) {
 			struct page *vmpage = cl_page_vmpage(env, clp);
 			struct page *src_page;
@@ -284,14 +287,16 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 			kunmap_atomic(src);
 
 			/* make sure page will be added to the transfer by
-			 * cl_io_submit()->...->vvp_page_prep_write(). */
+			 * cl_io_submit()->...->vvp_page_prep_write().
+			 */
 			if (rw == WRITE)
 				set_page_dirty(vmpage);
 
 			if (rw == READ) {
 				/* do not issue the page for read, since it
 				 * may reread a ra page which has NOT uptodate
-				 * bit set. */
+				 * bit set.
+				 */
 				cl_page_disown(env, io, clp);
 				do_io = false;
 			}
@@ -359,7 +364,8 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
  * kmalloc limit.  We need to fit all of the brw_page structs, each one
  * representing PAGE_SIZE worth of user data, into a single buffer, and
  * then truncate this to be a full-sized RPC.  For 4kB PAGE_SIZE this is
- * up to 22MB for 128kB kmalloc and up to 682MB for 4MB kmalloc. */
+ * up to 22MB for 128kB kmalloc and up to 682MB for 4MB kmalloc.
+ */
 #define MAX_DIO_SIZE ((MAX_MALLOC / sizeof(struct brw_page) * PAGE_CACHE_SIZE) & \
 		      ~(DT_MAX_BRW_SIZE - 1))
 static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
@@ -433,7 +439,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			 * for the request, shrink it to a smaller
 			 * PAGE_SIZE multiple and try again.
 			 * We should always be able to kmalloc for a
-			 * page worth of page pointers = 4MB on i386. */
+			 * page worth of page pointers = 4MB on i386.
+			 */
 			if (result == -ENOMEM &&
 			    size > (PAGE_CACHE_SIZE / sizeof(*pages)) *
 				   PAGE_CACHE_SIZE) {
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index db220f2..d4a3722 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -494,7 +494,8 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 
 		if (unlikely(atomic_read(&sai->sai_refcount) > 0)) {
 			/* It is race case, the interpret callback just hold
-			 * a reference count */
+			 * a reference count
+			 */
 			spin_unlock(&lli->lli_sa_lock);
 			return;
 		}
@@ -631,7 +632,8 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 		LASSERT(fid_is_zero(&minfo->mi_data.op_fid2));
 
 		/* XXX: No fid in reply, this is probably cross-ref case.
-		 * SA can't handle it yet. */
+		 * SA can't handle it yet.
+		 */
 		if (body->valid & OBD_MD_MDS) {
 			rc = -EAGAIN;
 			goto out;
@@ -672,7 +674,8 @@ out:
 	/* The "ll_sa_entry_to_stated()" will drop related ldlm ibits lock
 	 * reference count by calling "ll_intent_drop_lock()" in spite of the
 	 * above operations failed or not. Do not worry about calling
-	 * "ll_intent_drop_lock()" more than once. */
+	 * "ll_intent_drop_lock()" more than once.
+	 */
 	rc = ll_sa_entry_to_stated(sai, entry,
 				   rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
 	if (rc == 0 && entry->se_index == sai->sai_index_wait)
@@ -698,7 +701,8 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		/* release ibits lock ASAP to avoid deadlock when statahead
 		 * thread enqueues lock on parent in readdir and another
 		 * process enqueues lock on child with parent lock held, eg.
-		 * unlink. */
+		 * unlink.
+		 */
 		handle = it->d.lustre.it_lock_handle;
 		ll_intent_drop_lock(it);
 	}
@@ -736,7 +740,8 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 			/* Release the async ibits lock ASAP to avoid deadlock
 			 * when statahead thread tries to enqueue lock on parent
 			 * for readpage and other tries to enqueue lock on child
-			 * with parent's lock held, for example: unlink. */
+			 * with parent's lock held, for example: unlink.
+			 */
 			entry->se_handle = handle;
 			wakeup = list_empty(&sai->sai_entries_received);
 			list_add_tail(&entry->se_list,
@@ -947,7 +952,8 @@ static int ll_agl_thread(void *arg)
 	if (thread_is_init(thread))
 		/* If someone else has changed the thread state
 		 * (e.g. already changed to SVC_STOPPING), we can't just
-		 * blindly overwrite that setting. */
+		 * blindly overwrite that setting.
+		 */
 		thread_set_flags(thread, SVC_RUNNING);
 	spin_unlock(&plli->lli_agl_lock);
 	wake_up(&thread->t_ctl_waitq);
@@ -963,7 +969,8 @@ static int ll_agl_thread(void *arg)
 
 		spin_lock(&plli->lli_agl_lock);
 		/* The statahead thread maybe help to process AGL entries,
-		 * so check whether list empty again. */
+		 * so check whether list empty again.
+		 */
 		if (!list_empty(&sai->sai_entries_agl)) {
 			clli = list_entry(sai->sai_entries_agl.next,
 					  struct ll_inode_info, lli_agl_list);
@@ -1048,7 +1055,8 @@ static int ll_statahead_thread(void *arg)
 	if (thread_is_init(thread))
 		/* If someone else has changed the thread state
 		 * (e.g. already changed to SVC_STOPPING), we can't just
-		 * blindly overwrite that setting. */
+		 * blindly overwrite that setting.
+		 */
 		thread_set_flags(thread, SVC_RUNNING);
 	spin_unlock(&plli->lli_sa_lock);
 	wake_up(&thread->t_ctl_waitq);
@@ -1136,7 +1144,8 @@ interpret_it:
 
 			/* If no window for metadata statahead, but there are
 			 * some AGL entries to be triggered, then try to help
-			 * to process the AGL entries. */
+			 * to process the AGL entries.
+			 */
 			if (sa_sent_full(sai)) {
 				spin_lock(&plli->lli_agl_lock);
 				while (!list_empty(&sai->sai_entries_agl)) {
@@ -1364,7 +1373,8 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 
 			hash = le64_to_cpu(ent->lde_hash);
 			/* The ll_get_dir_page() can return any page containing
-			 * the given hash which may be not the start hash. */
+			 * the given hash which may be not the start hash.
+			 */
 			if (unlikely(hash < pos))
 				continue;
 
@@ -1650,7 +1660,8 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	 * but as soon as we expose the sai by attaching it to the lli that
 	 * default reference can be dropped by another thread calling
 	 * ll_stop_statahead. We need to take a local reference to protect
-	 * the sai buffer while we intend to access it. */
+	 * the sai buffer while we intend to access it.
+	 */
 	ll_sai_get(sai);
 	lli->lli_sai = sai;
 
@@ -1666,7 +1677,8 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 		thread_set_flags(thread, SVC_STOPPED);
 		thread_set_flags(&sai->sai_agl_thread, SVC_STOPPED);
 		/* Drop both our own local reference and the default
-		 * reference from allocation time. */
+		 * reference from allocation time.
+		 */
 		ll_sai_put(sai);
 		ll_sai_put(sai);
 		LASSERT(!lli->lli_sai);
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index cd996f6..63f090a 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -99,7 +99,8 @@ static int __init init_lustre_lite(void)
 
 	/* print an address of _any_ initialized kernel symbol from this
 	 * module, to allow debugging with gdb that doesn't support data
-	 * symbols from modules.*/
+	 * symbols from modules.
+	 */
 	CDEBUG(D_INFO, "Lustre client module (%p).\n",
 	       &lustre_super_operations);
 
@@ -146,7 +147,8 @@ static int __init init_lustre_lite(void)
 	cfs_get_random_bytes(seed, sizeof(seed));
 
 	/* Nodes with small feet have little entropy. The NID for this
-	 * node gives the most entropy in the low bits */
+	 * node gives the most entropy in the low bits
+	 */
 	for (i = 0;; i++) {
 		if (LNetGetId(i, &lnet_id) == -ENOENT)
 			break;
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index c2775b6..4435a63 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -59,7 +59,8 @@ static int ll_readlink_internal(struct inode *inode,
 		*symname = lli->lli_symlink_name;
 		/* If the total CDEBUG() size is larger than a page, it
 		 * will print a warning to the console, avoid this by
-		 * printing just the last part of the symlink. */
+		 * printing just the last part of the symlink.
+		 */
 		CDEBUG(D_INODE, "using cached symlink %s%.*s, len = %d\n",
 		       print_limit < symlen ? "..." : "", print_limit,
 		       (*symname) + symlen - print_limit, symlen);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index f856899..cca4b6c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -78,7 +78,8 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 	case CIT_READ:
 	case CIT_WRITE:
 		/* don't need lock here to check lli_layout_gen as we have held
-		 * extent lock and GROUP lock has to hold to swap layout */
+		 * extent lock and GROUP lock has to hold to swap layout
+		 */
 		if (ll_layout_version_get(lli) != cio->cui_layout_gen) {
 			io->ci_need_restart = 1;
 			/* this will return application a short read/write */
@@ -134,7 +135,8 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		 */
 		rc = ll_layout_restore(ccc_object_inode(obj));
 		/* if restore registration failed, no restart,
-		 * we will return -ENODATA */
+		 * we will return -ENODATA
+		 */
 		/* The layout will change after restore, so we need to
 		 * block on layout lock hold by the MDT
 		 * as MDT will not send new layout in lvb (see LU-3124)
@@ -164,8 +166,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 			       DFID" layout changed from %d to %d.\n",
 			       PFID(lu_object_fid(&obj->co_lu)),
 			       cio->cui_layout_gen, gen);
-			/* today successful restore is the only possible
-			 * case */
+			/* today successful restore is the only possible case */
 			/* restore was done, clear restoring state */
 			ll_i2info(ccc_object_inode(obj))->lli_flags &=
 				~LLIF_FILE_RESTORING;
@@ -456,7 +457,8 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 
 	if (cl_io_is_trunc(io))
 		/* Truncate in memory pages - they must be clean pages
-		 * because osc has already notified to destroy osc_extents. */
+		 * because osc has already notified to destroy osc_extents.
+		 */
 		vvp_do_vmtruncate(inode, io->u.ci_setattr.sa_attr.lvb_size);
 
 	inode_unlock(inode);
@@ -529,7 +531,8 @@ static int vvp_io_read_start(const struct lu_env *env,
 				vio->u.splice.cui_flags);
 		/* LU-1109: do splice read stripe by stripe otherwise if it
 		 * may make nfsd stuck if this read occupied all internal pipe
-		 * buffers. */
+		 * buffers.
+		 */
 		io->ci_continue = 0;
 		break;
 	default:
@@ -689,13 +692,15 @@ static int vvp_io_fault_start(const struct lu_env *env,
 
 	size = i_size_read(inode);
 	/* Though we have already held a cl_lock upon this page, but
-	 * it still can be truncated locally. */
+	 * it still can be truncated locally.
+	 */
 	if (unlikely((vmpage->mapping != inode->i_mapping) ||
 		     (page_offset(vmpage) > size))) {
 		CDEBUG(D_PAGE, "llite: fault and truncate race happened!\n");
 
 		/* return +1 to stop cl_io_loop() and ll_fault() will catch
-		 * and retry. */
+		 * and retry.
+		 */
 		result = 1;
 		goto out;
 	}
@@ -736,7 +741,8 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	}
 
 	/* if page is going to be written, we should add this page into cache
-	 * earlier. */
+	 * earlier.
+	 */
 	if (fio->ft_mkwrite) {
 		wait_on_page_writeback(vmpage);
 		if (set_page_dirty(vmpage)) {
@@ -750,7 +756,8 @@ static int vvp_io_fault_start(const struct lu_env *env,
 
 			/* Do not set Dirty bit here so that in case IO is
 			 * started before the page is really made dirty, we
-			 * still have chance to detect it. */
+			 * still have chance to detect it.
+			 */
 			result = cl_page_cache_add(env, io, page, CRT_WRITE);
 			LASSERT(cl_page_is_owned(page, io));
 
@@ -803,7 +810,8 @@ static int vvp_io_fsync_start(const struct lu_env *env,
 {
 	/* we should mark TOWRITE bit to each dirty page in radix tree to
 	 * verify pages have been written, but this is difficult because of
-	 * race. */
+	 * race.
+	 */
 	return 0;
 }
 
@@ -1153,7 +1161,8 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 
 		count = io->u.ci_rw.crw_count;
 		/* "If nbyte is 0, read() will return 0 and have no other
-		 *  results."  -- Single Unix Spec */
+		 *  results."  -- Single Unix Spec
+		 */
 		if (count == 0)
 			result = 1;
 		else
@@ -1173,20 +1182,23 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 
 	/* ignore layout change for generic CIT_MISC but not for glimpse.
 	 * io context for glimpse must set ci_verify_layout to true,
-	 * see cl_glimpse_size0() for details. */
+	 * see cl_glimpse_size0() for details.
+	 */
 	if (io->ci_type == CIT_MISC && !io->ci_verify_layout)
 		io->ci_ignore_layout = 1;
 
 	/* Enqueue layout lock and get layout version. We need to do this
 	 * even for operations requiring to open file, such as read and write,
-	 * because it might not grant layout lock in IT_OPEN. */
+	 * because it might not grant layout lock in IT_OPEN.
+	 */
 	if (result == 0 && !io->ci_ignore_layout) {
 		result = ll_layout_refresh(inode, &cio->cui_layout_gen);
 		if (result == -ENOENT)
 			/* If the inode on MDS has been removed, but the objects
 			 * on OSTs haven't been destroyed (async unlink), layout
 			 * fetch will return -ENOENT, we'd ignore this error
-			 * and continue with dirty flush. LU-3230. */
+			 * and continue with dirty flush. LU-3230.
+			 */
 			result = 0;
 		if (result < 0)
 			CERROR("%s: refresh file layout " DFID " error %d.\n",
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 8d7aa74..03c887d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -137,7 +137,8 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 		 * page may be stale due to layout change, and the process
 		 * will never be notified.
 		 * This operation is expensive but mmap processes have to pay
-		 * a price themselves. */
+		 * a price themselves.
+		 */
 		unmap_mapping_range(conf->coc_inode->i_mapping,
 				    0, OBD_OBJECT_EOF, 0);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index f254ad5..f0b26e3 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -232,7 +232,8 @@ static int vvp_page_prep_write(const struct lu_env *env,
 	LASSERT(!PageDirty(vmpage));
 
 	/* ll_writepage path is not a sync write, so need to set page writeback
-	 * flag */
+	 * flag
+	 */
 	if (!pg->cp_sync_io)
 		set_page_writeback(vmpage);
 
@@ -356,15 +357,15 @@ static int vvp_page_make_ready(const struct lu_env *env,
 	lock_page(vmpage);
 	if (clear_page_dirty_for_io(vmpage)) {
 		LASSERT(pg->cp_state == CPS_CACHED);
-		/* This actually clears the dirty bit in the radix
-		 * tree. */
+		/* This actually clears the dirty bit in the radix tree. */
 		set_page_writeback(vmpage);
 		vvp_write_pending(cl2ccc(slice->cpl_obj),
 				cl2ccc_page(slice));
 		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
 	} else if (pg->cp_state == CPS_PAGEOUT) {
 		/* is it possible for osc_flush_async_page() to already
-		 * make it ready? */
+		 * make it ready?
+		 */
 		result = -EALREADY;
 	} else {
 		CL_PAGE_DEBUG(D_ERROR, env, pg, "Unexpecting page state %d.\n",
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 8ccbf26..c34df37 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -237,7 +237,8 @@ int ll_setxattr(struct dentry *dentry, const char *name,
 
 		/* Attributes that are saved via getxattr will always have
 		 * the stripe_offset as 0.  Instead, the MDS should be
-		 * allowed to pick the starting OST index.   b=17846 */
+		 * allowed to pick the starting OST index.   b=17846
+		 */
 		if (lump && lump->lmm_stripe_offset == 0)
 			lump->lmm_stripe_offset = -1;
 
@@ -480,7 +481,8 @@ ssize_t ll_getxattr(struct dentry *dentry, const char *name,
 
 		if (size == 0 && S_ISDIR(inode->i_mode)) {
 			/* XXX directory EA is fix for now, optimize to save
-			 * RPC transfer */
+			 * RPC transfer
+			 */
 			rc = sizeof(struct lov_user_md);
 			goto out;
 		}
@@ -495,7 +497,8 @@ ssize_t ll_getxattr(struct dentry *dentry, const char *name,
 			}
 		} else {
 			/* LSM is present already after lookup/getattr call.
-			 * we need to grab layout lock once it is implemented */
+			 * we need to grab layout lock once it is implemented
+			 */
 			rc = obd_packmd(ll_i2dtexp(inode), &lmm, lsm);
 			lmmsize = rc;
 		}
@@ -508,7 +511,8 @@ ssize_t ll_getxattr(struct dentry *dentry, const char *name,
 			/* used to call ll_get_max_mdsize() forward to get
 			 * the maximum buffer size, while some apps (such as
 			 * rsync 3.0.x) care much about the exact xattr value
-			 * size */
+			 * size
+			 */
 			rc = lmmsize;
 			goto out;
 		}
@@ -524,7 +528,8 @@ ssize_t ll_getxattr(struct dentry *dentry, const char *name,
 		memcpy(lump, lmm, lmmsize);
 		/* do not return layout gen for getxattr otherwise it would
 		 * confuse tar --xattr by recognizing layout gen as stripe
-		 * offset when the file is restored. See LU-2809. */
+		 * offset when the file is restored. See LU-2809.
+		 */
 		lump->lmm_layout_gen = 0;
 
 		rc = lmmsize;
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index fe8df91..460b7c5 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -23,7 +23,8 @@
  */
 struct ll_xattr_entry {
 	struct list_head	xe_list;    /* protected with
-					     * lli_xattrs_list_rwsem */
+					     * lli_xattrs_list_rwsem
+					     */
 	char			*xe_name;   /* xattr name, \0-terminated */
 	char			*xe_value;  /* xattr value */
 	unsigned		xe_namelen; /* strlen(xe_name) + 1 */
@@ -280,7 +281,8 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 
 	mutex_lock(&lli->lli_xattrs_enq_lock);
 	/* inode may have been shrunk and recreated, so data is gone, match lock
-	 * only when data exists. */
+	 * only when data exists.
+	 */
 	if (ll_xattr_cache_valid(lli)) {
 		/* Try matching first. */
 		mode = ll_take_md_lock(inode, MDS_INODELOCK_XATTR, &lockh, 0,
-- 
2.1.0
