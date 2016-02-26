From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:49 -0500
Subject: [lustre-devel] [PATCH 01/25] staging/lustre/llite: Fix style vs
	open parenthesis alignment
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dcache.c       |  3 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  6 +-
 drivers/staging/lustre/lustre/llite/file.c         | 72 +++++++++++-----------
 drivers/staging/lustre/lustre/llite/llite_close.c  |  5 +-
 .../staging/lustre/lustre/llite/llite_internal.h   | 11 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 28 ++++-----
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  4 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    | 12 ++--
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c |  8 +--
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 14 ++---
 drivers/staging/lustre/lustre/llite/namei.c        |  8 +--
 drivers/staging/lustre/lustre/llite/rw.c           |  6 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  8 +--
 drivers/staging/lustre/lustre/llite/statahead.c    | 18 +++---
 drivers/staging/lustre/lustre/llite/super25.c      |  4 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 13 ++--
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 14 ++---
 drivers/staging/lustre/lustre/llite/vvp_page.c     | 12 ++--
 drivers/staging/lustre/lustre/llite/xattr.c        |  8 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  | 19 +++---
 21 files changed, 133 insertions(+), 142 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 0bc0fb9f..dd1c827 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -183,8 +183,7 @@ static int ll_ddelete(const struct dentry *de)
 int ll_d_init(struct dentry *de)
 {
 	CDEBUG(D_DENTRY, "ldd on dentry %pd (%p) parent %p inode %p refc %d\n",
-		de, de, de->d_parent, d_inode(de),
-		d_count(de));
+	       de, de, de->d_parent, d_inode(de), d_count(de));
 
 	if (!de->d_fsdata) {
 		struct ll_dentry_data *lld;
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index bd88a3b..394ec33 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -355,7 +355,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 		struct md_op_data *op_data;
 
 		op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
-		LUSTRE_OPC_ANY, NULL);
+					     LUSTRE_OPC_ANY, NULL);
 		if (IS_ERR(op_data))
 			return (void *)op_data;
 
@@ -368,8 +368,8 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 		if (request)
 			ptlrpc_req_finished(request);
 		if (rc < 0) {
-			CERROR("lock enqueue: "DFID" at %llu: rc %d\n",
-				PFID(ll_inode2fid(dir)), hash, rc);
+			CERROR("lock enqueue: " DFID "@%llu: rc %d\n",
+			       PFID(ll_inode2fid(dir)), hash, rc);
 			return ERR_PTR(rc);
 		}
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 4c25cf2..477dc0e 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -287,8 +287,9 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 		 * application crashed, we need to release here.
 		 */
 		rc = ll_lease_close(fd->fd_lease_och, inode, &lease_broken);
-		CDEBUG(rc ? D_ERROR : D_INODE, "Clean up lease "DFID" %d/%d\n",
-			PFID(&lli->lli_fid), rc, lease_broken);
+		CDEBUG(rc ? D_ERROR : D_INODE,
+		       "Clean up lease " DFID " %d/%d\n",
+		       PFID(&lli->lli_fid), rc, lease_broken);
 
 		fd->fd_lease_och = NULL;
 	}
@@ -432,7 +433,7 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 		* with messages with -ESTALE errors.
 		*/
 		if (!it_disposition(itp, DISP_OPEN_OPEN) ||
-		     it_open_error(DISP_OPEN_OPEN, itp))
+		    it_open_error(DISP_OPEN_OPEN, itp))
 			goto out;
 		ll_release_openhandle(inode, itp);
 		goto out;
@@ -727,7 +728,8 @@ out_openerr:
 }
 
 static int ll_md_blocking_lease_ast(struct ldlm_lock *lock,
-			struct ldlm_lock_desc *desc, void *data, int flag)
+				    struct ldlm_lock_desc *desc,
+				    void *data, int flag)
 {
 	int rc;
 	struct lustre_handle lockh;
@@ -814,7 +816,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 		return ERR_PTR(-ENOMEM);
 
 	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL, 0, 0,
-					LUSTRE_OPC_ANY, NULL);
+				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
 		rc = PTR_ERR(op_data);
 		goto out;
@@ -826,7 +828,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	it.it_flags = fmode | open_flags;
 	it.it_flags |= MDS_OPEN_LOCK | MDS_OPEN_BY_FID | MDS_OPEN_LEASE;
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, NULL, 0, &it, 0, &req,
-				ll_md_blocking_lease_ast,
+			    ll_md_blocking_lease_ast,
 	/* LDLM_FL_NO_LRU: To not put the lease lock into LRU list, otherwise
 	 * it can be cancelled which may mislead applications that the lease is
 	 * broken;
@@ -863,8 +865,8 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	    it.d.lustre.it_lock_bits != MDS_INODELOCK_OPEN) {
 		/* open lock must return for lease */
 		CERROR(DFID "lease granted but no open lock, %d/%llu.\n",
-			PFID(ll_inode2fid(inode)), it.d.lustre.it_lock_mode,
-			it.d.lustre.it_lock_bits);
+		       PFID(ll_inode2fid(inode)), it.d.lustre.it_lock_mode,
+		       it.d.lustre.it_lock_bits);
 		rc = -EPROTO;
 		goto out_close;
 	}
@@ -880,7 +882,7 @@ out_close:
 	/* cancel open lock */
 	if (it.d.lustre.it_lock_mode != 0) {
 		ldlm_lock_decref_and_cancel(&och->och_lease_handle,
-						it.d.lustre.it_lock_mode);
+					    it.d.lustre.it_lock_mode);
 		it.d.lustre.it_lock_mode = 0;
 	}
 out_release_it:
@@ -909,8 +911,8 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 		ldlm_lock_put(lock);
 	}
 
-	CDEBUG(D_INODE, "lease for "DFID" broken? %d\n",
-		PFID(&ll_i2info(inode)->lli_fid), cancelled);
+	CDEBUG(D_INODE, "lease for " DFID " broken? %d\n",
+	       PFID(&ll_i2info(inode)->lli_fid), cancelled);
 
 	if (!cancelled)
 		ldlm_cli_cancel(&och->och_lease_handle, 0);
@@ -1026,8 +1028,8 @@ int ll_merge_lvb(const struct lu_env *env, struct inode *inode)
 		if (lvb.lvb_mtime < attr->cat_mtime)
 			lvb.lvb_mtime = attr->cat_mtime;
 
-		CDEBUG(D_VFSTRACE, DFID" updating i_size %llu\n",
-				PFID(&lli->lli_fid), attr->cat_size);
+		CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
+		       PFID(&lli->lli_fid), attr->cat_size);
 		cl_isize_write_nolock(inode, attr->cat_size);
 
 		inode->i_blocks = attr->cat_blocks;
@@ -1239,7 +1241,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	args->u.normal.via_iocb = iocb;
 
 	result = ll_file_io_generic(env, args, iocb->ki_filp, CIT_WRITE,
-				  &iocb->ki_pos, iov_iter_count(from));
+				    &iocb->ki_pos, iov_iter_count(from));
 	cl_env_put(env, &refcheck);
 	return result;
 }
@@ -1423,7 +1425,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	lmmsize = body->eadatasize;
 
 	if (!(body->valid & (OBD_MD_FLEASIZE | OBD_MD_FLDIREA)) ||
-			lmmsize == 0) {
+	    lmmsize == 0) {
 		rc = -ENODATA;
 		goto out;
 	}
@@ -1474,7 +1476,7 @@ out:
 }
 
 static int ll_lov_setea(struct inode *inode, struct file *file,
-			    unsigned long arg)
+			unsigned long arg)
 {
 	int			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
 	struct lov_user_md	*lump;
@@ -1495,7 +1497,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 	}
 
 	rc = ll_lov_setstripe_ea_info(inode, file->f_path.dentry, flags, lump,
-				     lum_size);
+				      lum_size);
 	cl_lov_delay_create_clear(&file->f_flags);
 
 	kvfree(lump);
@@ -1618,7 +1620,7 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 
 	if (fd->fd_grouplock.cg_gid != arg) {
 		CWARN("group lock %lu doesn't match current id %lu\n",
-		       arg, fd->fd_grouplock.cg_gid);
+		      arg, fd->fd_grouplock.cg_gid);
 		spin_unlock(&lli->lli_lock);
 		return -EINVAL;
 	}
@@ -1802,7 +1804,7 @@ static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
 	 * required fiemap buffer
 	 */
 	if (get_user(extent_count,
-	    &((struct ll_user_fiemap __user *)arg)->fm_extent_count))
+		     &((struct ll_user_fiemap __user *)arg)->fm_extent_count))
 		return -EFAULT;
 
 	if (extent_count >=
@@ -1828,8 +1830,8 @@ static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
 	 */
 	if (extent_count) {
 		if (copy_from_user(&fiemap_s->fm_extents[0],
-		    (char __user *)arg + sizeof(*fiemap_s),
-		    sizeof(struct ll_fiemap_extent))) {
+				   (char __user *)arg + sizeof(*fiemap_s),
+				   sizeof(struct ll_fiemap_extent))) {
 			rc = -EFAULT;
 			goto error;
 		}
@@ -2330,7 +2332,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return -EFAULT;
 
 		rc = ll_data_version(inode, &idv.idv_version,
-				!(idv.idv_flags & LL_DV_NOFLUSH));
+				     !(idv.idv_flags & LL_DV_NOFLUSH));
 
 		if (rc == 0 && copy_to_user((char __user *)arg, &idv,
 					    sizeof(idv)))
@@ -2738,7 +2740,7 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 		break;
 	default:
 		CDEBUG(D_INFO, "Unknown fcntl lock type: %d\n",
-			file_lock->fl_type);
+		       file_lock->fl_type);
 		return -ENOTSUPP;
 	}
 
@@ -2789,7 +2791,7 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	if (rc2 && file_lock->fl_type != F_UNLCK) {
 		einfo.ei_mode = LCK_NL;
 		md_enqueue(sbi->ll_md_exp, &einfo, NULL,
-			op_data, &lockh, &flock, 0, NULL /* req */, flags);
+			   op_data, &lockh, &flock, 0, NULL /* req */, flags);
 		rc = rc2;
 	}
 
@@ -3455,9 +3457,9 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 				*gen = md.lsm->lsm_layout_gen;
 			rc = 0;
 		} else {
-			CERROR("%s: file "DFID" unpackmd error: %d\n",
-				ll_get_fsname(inode->i_sb, NULL, 0),
-				PFID(&lli->lli_fid), rc);
+			CERROR("%s: file " DFID " unpackmd error: %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       PFID(&lli->lli_fid), rc);
 		}
 	}
 	if (rc < 0)
@@ -3485,9 +3487,9 @@ out:
 
 	/* wait for IO to complete if it's still being used. */
 	if (wait_layout) {
-		CDEBUG(D_INODE, "%s: %p/"DFID" wait for layout reconf.\n",
-			ll_get_fsname(inode->i_sb, NULL, 0),
-			inode, PFID(&lli->lli_fid));
+		CDEBUG(D_INODE, "%s: %p/" DFID " wait for layout reconf.\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       inode, PFID(&lli->lli_fid));
 
 		memset(&conf, 0, sizeof(conf));
 		conf.coc_opc = OBJECT_CONF_WAIT;
@@ -3496,8 +3498,8 @@ out:
 		if (rc == 0)
 			rc = -EAGAIN;
 
-		CDEBUG(D_INODE, "file: "DFID" waiting layout return: %d.\n",
-			PFID(&lli->lli_fid), rc);
+		CDEBUG(D_INODE, "file: " DFID " waiting layout return: %d.\n",
+		       PFID(&lli->lli_fid), rc);
 	}
 	return rc;
 }
@@ -3558,7 +3560,7 @@ again:
 	}
 
 	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL,
-			0, 0, LUSTRE_OPC_ANY, NULL);
+				     0, 0, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
 		mutex_unlock(&lli->lli_layout_mutex);
 		return PTR_ERR(op_data);
@@ -3569,8 +3571,8 @@ again:
 	it.it_op = IT_LAYOUT;
 	lockh.cookie = 0ULL;
 
-	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file %p/"DFID".\n",
-			ll_get_fsname(inode->i_sb, NULL, 0), inode,
+	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file %p/" DFID ".\n",
+			  ll_get_fsname(inode->i_sb, NULL, 0), inode,
 			PFID(&lli->lli_fid));
 
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, &it, op_data, &lockh,
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index fcb6657..d3195c3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -53,8 +53,7 @@ void vvp_write_pending(struct ccc_object *club, struct ccc_page *page)
 	spin_lock(&lli->lli_lock);
 	lli->lli_flags |= LLIF_SOM_DIRTY;
 	if (page && list_empty(&page->cpg_pending_linkage))
-		list_add(&page->cpg_pending_linkage,
-			     &club->cob_pending_list);
+		list_add(&page->cpg_pending_linkage, &club->cob_pending_list);
 	spin_unlock(&lli->lli_lock);
 }
 
@@ -322,7 +321,7 @@ static struct ll_inode_info *ll_close_next_lli(struct ll_close_queue *lcq)
 
 	if (!list_empty(&lcq->lcq_head)) {
 		lli = list_entry(lcq->lcq_head.next, struct ll_inode_info,
-				     lli_close_list);
+				 lli_close_list);
 		list_del_init(&lli->lli_close_list);
 	} else if (atomic_read(&lcq->lcq_stop))
 		lli = ERR_PTR(-EALREADY);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f6921ff..973f5cd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -287,11 +287,8 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, __u32 gen)
 
 int ll_xattr_cache_destroy(struct inode *inode);
 
-int ll_xattr_cache_get(struct inode *inode,
-			const char *name,
-			char *buffer,
-			size_t size,
-			__u64 valid);
+int ll_xattr_cache_get(struct inode *inode, const char *name,
+		       char *buffer, size_t size, __u64 valid);
 
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
@@ -970,8 +967,8 @@ int ll_close_thread_start(struct ll_close_queue **lcq_ret);
 
 int ll_teardown_mmaps(struct address_space *mapping, __u64 first, __u64 last);
 int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
-void policy_from_vma(ldlm_policy_data_t *policy,
-		struct vm_area_struct *vma, unsigned long addr, size_t count);
+void policy_from_vma(ldlm_policy_data_t *policy, struct vm_area_struct *vma,
+		     unsigned long addr, size_t count);
 struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 			       size_t count);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 1f3e8e8..47f9ad7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -254,8 +254,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	 * available
 	 */
 	err = obd_statfs(NULL, sbi->ll_md_exp, osfs,
-			cfs_time_shift_64(-OBD_STATFS_CACHE_SECONDS),
-			OBD_STATFS_FOR_MDT0);
+			 cfs_time_shift_64(-OBD_STATFS_CACHE_SECONDS),
+			 OBD_STATFS_FOR_MDT0);
 	if (err)
 		goto out_md_fid;
 
@@ -536,7 +536,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	sb->s_root = d_make_root(root);
 	if (!sb->s_root) {
 		CERROR("%s: can't make root dentry\n",
-			ll_get_fsname(sb, NULL, 0));
+		       ll_get_fsname(sb, NULL, 0));
 		err = -ENOMEM;
 		goto out_lock_cn_cb;
 	}
@@ -601,7 +601,7 @@ int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 
 	size = sizeof(int);
 	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_DEFAULT_EASIZE),
-			 KEY_DEFAULT_EASIZE, &size, lmmsize, NULL);
+			  KEY_DEFAULT_EASIZE, &size, lmmsize, NULL);
 	if (rc)
 		CERROR("Get default mdsize error rc %d\n", rc);
 
@@ -1100,7 +1100,7 @@ void ll_clear_inode(struct inode *inode)
 #define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
 
 static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
-		  struct md_open_data **mod)
+			 struct md_open_data **mod)
 {
 	struct lustre_md md;
 	struct inode *inode = d_inode(dentry);
@@ -1215,11 +1215,11 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	int rc = 0, rc1 = 0;
 
 	CDEBUG(D_VFSTRACE,
-		"%s: setattr inode %p/fid:"DFID
-		" from %llu to %llu, valid %x, hsm_import %d\n",
-		ll_get_fsname(inode->i_sb, NULL, 0), inode,
-		PFID(&lli->lli_fid), i_size_read(inode), attr->ia_size,
-		attr->ia_valid, hsm_import);
+	       "%s: setattr inode %p/fid:" DFID
+	       " from %llu to %llu, valid %x, hsm_import %d\n",
+	       ll_get_fsname(inode->i_sb, NULL, 0), inode,
+	       PFID(&lli->lli_fid), i_size_read(inode), attr->ia_size,
+	       attr->ia_valid, hsm_import);
 
 	if (attr->ia_valid & ATTR_SIZE) {
 		/* Check new size against VFS/VM file size limit and rlimit */
@@ -1826,7 +1826,7 @@ int ll_flush_ctx(struct inode *inode)
 	struct ll_sb_info  *sbi = ll_i2sbi(inode);
 
 	CDEBUG(D_SEC, "flush context for user %d\n",
-		      from_kuid(&init_user_ns, current_uid()));
+	       from_kuid(&init_user_ns, current_uid()));
 
 	obd_set_info_async(NULL, sbi->ll_md_exp,
 			   sizeof(KEY_FLUSH_CTX), KEY_FLUSH_CTX,
@@ -2127,9 +2127,9 @@ int ll_process_config(struct lustre_cfg *lcfg)
 
 /* this function prepares md_op_data hint for passing ot down to MD stack. */
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
-				       struct inode *i1, struct inode *i2,
-				       const char *name, int namelen,
-				       int mode, __u32 opc, void *data)
+				      struct inode *i1, struct inode *i2,
+				      const char *name, int namelen,
+				      int mode, __u32 opc, void *data)
 {
 	if (namelen > ll_i2sbi(i1)->ll_namelen)
 		return ERR_PTR(-ENAMETOOLONG);
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 31abdb7f..69445a9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -54,8 +54,8 @@
 static const struct vm_operations_struct ll_file_vm_ops;
 
 void policy_from_vma(ldlm_policy_data_t *policy,
-			    struct vm_area_struct *vma, unsigned long addr,
-			    size_t count)
+		     struct vm_area_struct *vma, unsigned long addr,
+		     size_t count)
 {
 	policy->l_extent.start = ((addr - vma->vm_start) & CFS_PAGE_MASK) +
 				 (vma->vm_pgoff << PAGE_CACHE_SHIFT);
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 74a8868..69d30aa 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -191,8 +191,8 @@ static int ll_encode_fh(struct inode *inode, __u32 *fh, int *plen,
 	int fileid_len = sizeof(struct lustre_nfs_fid) / 4;
 	struct lustre_nfs_fid *nfs_fid = (void *)fh;
 
-	CDEBUG(D_INFO, "encoding for (%lu,"DFID") maxlen=%d minlen=%d\n",
-	      inode->i_ino, PFID(ll_inode2fid(inode)), *plen, fileid_len);
+	CDEBUG(D_INFO, "encoding for (%lu," DFID ") maxlen=%d minlen=%d\n",
+	       inode->i_ino, PFID(ll_inode2fid(inode)), *plen, fileid_len);
 
 	if (*plen < fileid_len) {
 		*plen = fileid_len;
@@ -298,8 +298,8 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 
 	sbi = ll_s2sbi(dir->i_sb);
 
-	CDEBUG(D_INFO, "getting parent for (%lu,"DFID")\n",
-			dir->i_ino, PFID(ll_inode2fid(dir)));
+	CDEBUG(D_INFO, "getting parent for (%lu," DFID ")\n",
+	       dir->i_ino, PFID(ll_inode2fid(dir)));
 
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
 	if (rc != 0)
@@ -320,8 +320,8 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	LASSERT(body->valid & OBD_MD_FLID);
 
-	CDEBUG(D_INFO, "parent for "DFID" is "DFID"\n",
-		PFID(ll_inode2fid(dir)), PFID(&body->fid1));
+	CDEBUG(D_INFO, "parent for " DFID " is " DFID "\n",
+	       PFID(ll_inode2fid(dir)), PFID(&body->fid1));
 
 	result = ll_iget_for_nfs(dir->i_sb, &body->fid1, NULL);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
index 63e4847..8509b07 100644
--- a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
+++ b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
@@ -98,7 +98,7 @@ static void rce_free(struct rmtacl_ctl_entry *rce)
 }
 
 static struct rmtacl_ctl_entry *__rct_search(struct rmtacl_ctl_table *rct,
-					   pid_t key)
+					     pid_t key)
 {
 	struct rmtacl_ctl_entry *rce;
 	struct list_head *head = &rct->rct_entries[rce_hashfunc(key)];
@@ -172,7 +172,7 @@ void rct_fini(struct rmtacl_ctl_table *rct)
 	for (i = 0; i < RCE_HASHES; i++)
 		while (!list_empty(&rct->rct_entries[i])) {
 			rce = list_entry(rct->rct_entries[i].next,
-					     struct rmtacl_ctl_entry, rce_list);
+					 struct rmtacl_ctl_entry, rce_list);
 			rce_free(rce);
 		}
 	spin_unlock(&rct->rct_lock);
@@ -208,7 +208,7 @@ void ee_free(struct eacl_entry *ee)
 }
 
 static struct eacl_entry *__et_search_del(struct eacl_table *et, pid_t key,
-					struct lu_fid *fid, int type)
+					  struct lu_fid *fid, int type)
 {
 	struct eacl_entry *ee;
 	struct list_head *head = &et->et_entries[ee_hashfunc(key)];
@@ -290,7 +290,7 @@ void et_fini(struct eacl_table *et)
 	for (i = 0; i < EE_HASHES; i++)
 		while (!list_empty(&et->et_entries[i])) {
 			ee = list_entry(et->et_entries[i].next,
-					    struct eacl_entry, ee_list);
+					struct eacl_entry, ee_list);
 			ee_free(ee);
 		}
 	spin_unlock(&et->et_lock);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index f5fe928..8a27f69 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -462,9 +462,9 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 		/* difficult - have to ask OSCs to drop LRU slots. */
 		tmp = diff << 1;
 		rc = obd_set_info_async(NULL, sbi->ll_dt_exp,
-				sizeof(KEY_CACHE_LRU_SHRINK),
-				KEY_CACHE_LRU_SHRINK,
-				sizeof(tmp), &tmp, NULL);
+					sizeof(KEY_CACHE_LRU_SHRINK),
+					KEY_CACHE_LRU_SHRINK,
+					sizeof(tmp), &tmp, NULL);
 		if (rc < 0)
 			break;
 	}
@@ -1000,7 +1000,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 		CWARN("Error adding the extent_stats file\n");
 
 	rc = ldebugfs_seq_create(sbi->ll_debugfs_entry,
-				  "extents_stats_per_process",
+				 "extents_stats_per_process",
 				 0644, &ll_rw_extents_stats_pp_fops, sbi);
 	if (rc)
 		CWARN("Error adding the extents_stats_per_process file\n");
@@ -1034,7 +1034,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 				     llite_opcode_table[id].opname, ptr);
 	}
 	err = ldebugfs_register_stats(sbi->ll_debugfs_entry, "stats",
-				     sbi->ll_stats);
+				      sbi->ll_stats);
 	if (err)
 		goto out;
 
@@ -1050,7 +1050,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 				     ra_stat_string[id], "pages");
 
 	err = ldebugfs_register_stats(sbi->ll_debugfs_entry, "read_ahead_stats",
-				     sbi->ll_ra_stats);
+				      sbi->ll_ra_stats);
 	if (err)
 		goto out;
 
@@ -1104,7 +1104,7 @@ void ldebugfs_unregister_mountpoint(struct ll_sb_info *sbi)
 #define pct(a, b) (b ? a * 100 / b : 0)
 
 static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
-				   struct seq_file *seq, int which)
+				    struct seq_file *seq, int which)
 {
 	unsigned long read_tot = 0, write_tot = 0, read_cum, write_cum;
 	unsigned long start, end, r, w;
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 56d2d1d..46be850 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -120,9 +120,9 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 			if (S_ISREG(inode->i_mode) &&
 			    !ll_i2info(inode)->lli_clob) {
 				CDEBUG(D_INODE,
-					"%s: apply lsm %p to inode "DFID".\n",
-					ll_get_fsname(sb, NULL, 0), md->lsm,
-					PFID(ll_inode2fid(inode)));
+				       "%s: apply lsm %p to inode " DFID ".\n",
+				       ll_get_fsname(sb, NULL, 0), md->lsm,
+				       PFID(ll_inode2fid(inode)));
 				rc = cl_file_inode_init(inode, md);
 			}
 			if (rc != 0) {
@@ -1016,7 +1016,7 @@ static int ll_symlink(struct inode *dir, struct dentry *dentry,
 	       dir, 3000, oldname);
 
 	err = ll_new_node(dir, dentry, oldname, S_IFLNK | S_IRWXUGO,
-			0, LUSTRE_OPC_SYMLINK);
+			  0, LUSTRE_OPC_SYMLINK);
 
 	if (!err)
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_SYMLINK, 1);
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 671039a..34614ac 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -626,8 +626,8 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 	RIA_DEBUG(ria);
 
 	stride_ria = ria->ria_length > ria->ria_pages && ria->ria_pages > 0;
-	for (page_idx = ria->ria_start; page_idx <= ria->ria_end &&
-			*reserved_pages > 0; page_idx++) {
+	for (page_idx = ria->ria_start;
+	     page_idx <= ria->ria_end && *reserved_pages > 0; page_idx++) {
 		if (ras_inside_ra_window(page_idx, ria)) {
 			/* If the page is inside the read-ahead window*/
 			rc = ll_read_ahead_page(env, io, queue,
@@ -869,7 +869,7 @@ static void ras_update_stride_detector(struct ll_readahead_state *ras,
 	unsigned long stride_gap = index - ras->ras_last_readpage - 1;
 
 	if (!stride_io_mode(ras) && (stride_gap != 0 ||
-	     ras->ras_consecutive_stride_requests == 0)) {
+	    ras->ras_consecutive_stride_requests == 0)) {
 		ras->ras_stride_pages = ras->ras_consecutive_pages;
 		ras->ras_stride_length = stride_gap+ras->ras_consecutive_pages;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index b0f7ffa..64110c5 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -481,8 +481,8 @@ out:
 }
 
 static int ll_write_begin(struct file *file, struct address_space *mapping,
-			 loff_t pos, unsigned len, unsigned flags,
-			 struct page **pagep, void **fsdata)
+			  loff_t pos, unsigned len, unsigned flags,
+			  struct page **pagep, void **fsdata)
 {
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
 	struct page *page;
@@ -519,8 +519,8 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 
 #ifdef CONFIG_MIGRATION
 static int ll_migratepage(struct address_space *mapping,
-			 struct page *newpage, struct page *page,
-			 enum migrate_mode mode
+			  struct page *newpage, struct page *page,
+			  enum migrate_mode mode
 		)
 {
 	/* Always fail page migration until we have a proper implementation */
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index d4a3722..99ffd15 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -284,7 +284,7 @@ ll_sa_entry_get_byindex(struct ll_statahead_info *sai, __u64 index)
 }
 
 static void ll_sa_entry_cleanup(struct ll_statahead_info *sai,
-				 struct ll_sa_entry *entry)
+				struct ll_sa_entry *entry)
 {
 	struct md_enqueue_info *minfo = entry->se_minfo;
 	struct ptlrpc_request  *req   = entry->se_req;
@@ -303,7 +303,7 @@ static void ll_sa_entry_cleanup(struct ll_statahead_info *sai,
 }
 
 static void ll_sa_entry_put(struct ll_statahead_info *sai,
-			     struct ll_sa_entry *entry)
+			    struct ll_sa_entry *entry)
 {
 	if (atomic_dec_and_test(&entry->se_refcount)) {
 		CDEBUG(D_READA, "free sa entry %.*s(%p) index %llu\n",
@@ -514,8 +514,8 @@ static void ll_sai_put(struct ll_statahead_info *sai)
 			      PFID(&lli->lli_fid),
 			      sai->sai_sent, sai->sai_replied);
 
-		list_for_each_entry_safe(entry, next,
-					     &sai->sai_entries, se_link)
+		list_for_each_entry_safe(entry, next, &sai->sai_entries,
+					 se_link)
 			do_sa_entry_fini(sai, entry);
 
 		LASSERT(list_empty(&sai->sai_entries));
@@ -745,7 +745,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 			entry->se_handle = handle;
 			wakeup = list_empty(&sai->sai_entries_received);
 			list_add_tail(&entry->se_list,
-					  &sai->sai_entries_received);
+				      &sai->sai_entries_received);
 		}
 		sai->sai_replied++;
 		spin_unlock(&lli->lli_sa_lock);
@@ -1013,8 +1013,8 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 	       sai, parent);
 
 	plli = ll_i2info(d_inode(parent));
-	task = kthread_run(ll_agl_thread, parent,
-			       "ll_agl_%u", plli->lli_opendir_pid);
+	task = kthread_run(ll_agl_thread, parent, "ll_agl_%u",
+			   plli->lli_opendir_pid);
 	if (IS_ERR(task)) {
 		CERROR("can't start ll_agl thread, rc: %ld\n", PTR_ERR(task));
 		thread_set_flags(thread, SVC_STOPPED);
@@ -1583,7 +1583,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 					struct dentry *alias;
 
 					alias = ll_splice_alias(inode,
-								   *dentryp);
+								*dentryp);
 					if (IS_ERR(alias)) {
 						ll_sai_unplug(sai, entry);
 						return PTR_ERR(alias);
@@ -1592,7 +1592,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 				} else if (d_inode(*dentryp) != inode) {
 					/* revalidate, but inode is recreated */
 					CDEBUG(D_READA,
-					      "stale dentry %pd inode %lu/%u, statahead inode %lu/%u\n",
+					       "stale dentry %pd inode %lu/%u, statahead inode %lu/%u\n",
 					      *dentryp,
 					      d_inode(*dentryp)->i_ino,
 					      d_inode(*dentryp)->i_generation,
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 63f090a..79e1322 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -113,8 +113,8 @@ static int __init init_lustre_lite(void)
 		goto out_cache;
 
 	ll_file_data_slab = kmem_cache_create("ll_file_data",
-						 sizeof(struct ll_file_data), 0,
-						 SLAB_HWCACHE_ALIGN, NULL);
+					      sizeof(struct ll_file_data), 0,
+					      SLAB_HWCACHE_ALIGN, NULL);
 	if (!ll_file_data_slab)
 		goto out_cache;
 
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 4435a63..46d03ea 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -91,7 +91,7 @@ static int ll_readlink_internal(struct inode *inode,
 	LASSERT(symlen != 0);
 	if (body->eadatasize != symlen) {
 		CERROR("inode %lu: symlink length %d not expected %d\n",
-			inode->i_ino, body->eadatasize - 1, symlen - 1);
+		       inode->i_ino, body->eadatasize - 1, symlen - 1);
 		rc = -EPROTO;
 		goto failed;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 2e39533..bb39337 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -44,14 +44,13 @@
 #include "../include/cl_object.h"
 #include "llite_internal.h"
 
-int	       vvp_io_init     (const struct lu_env *env,
-				   struct cl_object *obj, struct cl_io *io);
-int	       vvp_lock_init   (const struct lu_env *env,
-				   struct cl_object *obj, struct cl_lock *lock,
+int vvp_io_init(const struct lu_env *env,
+		struct cl_object *obj, struct cl_io *io);
+int vvp_lock_init(const struct lu_env *env,
+		  struct cl_object *obj, struct cl_lock *lock,
 				   const struct cl_io *io);
-int		  vvp_page_init   (const struct lu_env *env,
-				   struct cl_object *obj,
-				   struct cl_page *page, struct page *vmpage);
+int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
+		  struct cl_page *page, struct page *vmpage);
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index cca4b6c..fb0c26e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -68,7 +68,7 @@ int cl_is_normalio(const struct lu_env *env, const struct cl_io *io)
  * have to acquire group lock.
  */
 static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
-				struct inode *inode)
+			       struct inode *inode)
 {
 	struct ll_inode_info	*lli = ll_i2info(inode);
 	struct ccc_io		*cio = ccc_env_io(env);
@@ -501,8 +501,8 @@ static int vvp_io_read_start(const struct lu_env *env,
 		goto out;
 
 	LU_OBJECT_HEADER(D_INODE, env, &obj->co_lu,
-			"Read ino %lu, %lu bytes, offset %lld, size %llu\n",
-			inode->i_ino, cnt, pos, i_size_read(inode));
+			 "Read ino %lu, %lu bytes, offset %lld, size %llu\n",
+			 inode->i_ino, cnt, pos, i_size_read(inode));
 
 	/* turn off the kernel's read-ahead */
 	cio->cui_fd->fd_file->f_ra.ra_pages = 0;
@@ -527,8 +527,8 @@ static int vvp_io_read_start(const struct lu_env *env,
 		break;
 	case IO_SPLICE:
 		result = generic_file_splice_read(file, &pos,
-				vio->u.splice.cui_pipe, cnt,
-				vio->u.splice.cui_flags);
+						  vio->u.splice.cui_pipe, cnt,
+						  vio->u.splice.cui_flags);
 		/* LU-1109: do splice read stripe by stripe otherwise if it
 		 * may make nfsd stuck if this read occupied all internal pipe
 		 * buffers.
@@ -1202,8 +1202,8 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 			result = 0;
 		if (result < 0)
 			CERROR("%s: refresh file layout " DFID " error %d.\n",
-				ll_get_fsname(inode->i_sb, NULL, 0),
-				PFID(lu_object_fid(&obj->co_lu)), result);
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       PFID(lu_object_fid(&obj->co_lu)), result);
 	}
 
 	return result;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index f0b26e3..850bae7 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -263,7 +263,7 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage, int ioret
 			set_bit(AS_EIO, &inode->i_mapping->flags);
 
 		if ((ioret == -ESHUTDOWN || ioret == -EINTR) &&
-		     obj->cob_discard_page_warned == 0) {
+		    obj->cob_discard_page_warned == 0) {
 			obj->cob_discard_page_warned = 1;
 			ll_dirty_page_discard_warn(vmpage, ioret);
 		}
@@ -359,8 +359,7 @@ static int vvp_page_make_ready(const struct lu_env *env,
 		LASSERT(pg->cp_state == CPS_CACHED);
 		/* This actually clears the dirty bit in the radix tree. */
 		set_page_writeback(vmpage);
-		vvp_write_pending(cl2ccc(slice->cpl_obj),
-				cl2ccc_page(slice));
+		vvp_write_pending(cl2ccc(slice->cpl_obj), cl2ccc_page(slice));
 		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
 	} else if (pg->cp_state == CPS_PAGEOUT) {
 		/* is it possible for osc_flush_async_page() to already
@@ -531,7 +530,7 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 };
 
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_page *page, struct page *vmpage)
+		  struct cl_page *page, struct page *vmpage)
 {
 	struct ccc_page *cpg = cl_object_page_slice(obj, page);
 
@@ -544,14 +543,13 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	if (page->cp_type == CPT_CACHEABLE) {
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
-		cl_page_slice_add(page, &cpg->cpg_cl, obj,
-				&vvp_page_ops);
+		cl_page_slice_add(page, &cpg->cpg_cl, obj, &vvp_page_ops);
 	} else {
 		struct ccc_object *clobj = cl2ccc(obj);
 
 		LASSERT(!inode_trylock(clobj->cob_inode));
 		cl_page_slice_add(page, &cpg->cpg_cl, obj,
-				&vvp_transient_page_ops);
+				  &vvp_transient_page_ops);
 		clobj->cob_transient_pages++;
 	}
 	return 0;
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index c34df37..b68dcc9 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -135,7 +135,7 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 
 	/* b15587: ignore security.capability xattr for now */
 	if ((xattr_type == XATTR_SECURITY_T &&
-	    strcmp(name, "security.capability") == 0))
+	     strcmp(name, "security.capability") == 0))
 		return 0;
 
 	/* LU-549:  Disable security.selinux when selinux is disabled */
@@ -311,7 +311,7 @@ int ll_getxattr_common(struct inode *inode, const char *name,
 
 	/* b15587: ignore security.capability xattr for now */
 	if ((xattr_type == XATTR_SECURITY_T &&
-	    strcmp(name, "security.capability") == 0))
+	     strcmp(name, "security.capability") == 0))
 		return -ENODATA;
 
 	/* LU-549:  Disable security.selinux when selinux is disabled */
@@ -397,7 +397,7 @@ getxattr_nocache:
 
 		if (size < body->eadatasize) {
 			CERROR("server bug: replied size %u > %u\n",
-				body->eadatasize, (int)size);
+			       body->eadatasize, (int)size);
 			rc = -ERANGE;
 			goto out;
 		}
@@ -409,7 +409,7 @@ getxattr_nocache:
 
 		/* do not need swab xattr data */
 		xdata = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA,
-							body->eadatasize);
+						     body->eadatasize);
 		if (!xdata) {
 			rc = -EFAULT;
 			goto out;
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 460b7c5..c069f8b 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -133,8 +133,8 @@ static int ll_xattr_cache_add(struct list_head *cache,
 	xattr->xe_vallen = xattr_val_len;
 	list_add(&xattr->xe_list, cache);
 
-	CDEBUG(D_CACHE, "set: [%s]=%.*s\n", xattr_name,
-		xattr_val_len, xattr_val);
+	CDEBUG(D_CACHE, "set: [%s]=%.*s\n", xattr_name, xattr_val_len,
+	       xattr_val);
 
 	return 0;
 err_value:
@@ -191,7 +191,7 @@ static int ll_xattr_cache_list(struct list_head *cache,
 
 	list_for_each_entry_safe(xattr, tmp, cache, xe_list) {
 		CDEBUG(D_CACHE, "list: buffer=%p[%d] name=%s\n",
-			xld_buffer, xld_tail, xattr->xe_name);
+		       xld_buffer, xld_tail, xattr->xe_name);
 
 		if (xld_buffer) {
 			xld_size -= xattr->xe_namelen;
@@ -381,9 +381,9 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	}
 	/* do not need swab xattr data */
 	xdata = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA,
-						body->eadatasize);
+					     body->eadatasize);
 	xval = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS,
-						body->aclsize);
+					    body->aclsize);
 	xsizes = req_capsule_server_sized_get(&req->rq_pill, &RMF_EAVALS_LENS,
 					      body->max_mdsize * sizeof(__u32));
 	if (!xdata || !xval || !xsizes) {
@@ -469,11 +469,8 @@ out_destroy:
  * \retval -ERANGE  the buffer is not large enough
  * \retval -ENODATA no such attr or the list is empty
  */
-int ll_xattr_cache_get(struct inode *inode,
-			const char *name,
-			char *buffer,
-			size_t size,
-			__u64 valid)
+int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
+		       size_t size, __u64 valid)
 {
 	struct lookup_intent oit = { .it_op = IT_GETXATTR };
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -502,7 +499,7 @@ int ll_xattr_cache_get(struct inode *inode,
 			if (size != 0) {
 				if (size >= xattr->xe_vallen)
 					memcpy(buffer, xattr->xe_value,
-						xattr->xe_vallen);
+					       xattr->xe_vallen);
 				else
 					rc = -ERANGE;
 			}
-- 
2.1.0
