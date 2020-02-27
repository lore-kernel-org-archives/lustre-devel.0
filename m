From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:47 -0500
Subject: [lustre-devel] [PATCH 359/622] lustre: pcc: Non-blocking PCC caching
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-360-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

Current PCC uses refcount of PCC inode to determine whether a
previous PCC-attached file can be detached. If a file is open
(refcount > 1), the detaching will return -EBUSY.

When another client accesses the PCC-cached file, it will trigger
the restore process as the file is HSM released. During restore,
the Agent needs to detach the PCC-cached file.
Thus, if a PCC-attached file is keeping opened but not closed
for a long time, the restore request will always return failure.

In this patch, we implement a non-blocking PCC caching mechanism
for Lustre. After attaching the file into PCC, the client acquires
the layout lock for the file, and the layout generation is
maintained in the PCC inode. Under the layout lock protection, the
PCC caching state is valid and all I/O will direct into PCC. When
the layout lock is revoked, in the blocking AST it will invalidate
the PCC caching state and detach the file automatically.

This patch is also helpful to handle the ENOSPC error for PCC
write by fallback to normal I/O path which will restore the file
data into OSTs (The file is in HSM released state) and redo the
write again.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10092
Lustre-commit: 58d744e3eaab ("LU-10092 pcc: Non-blocking PCC caching")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/32966
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h         |   4 +
 fs/lustre/llite/dir.c                   |  31 +-
 fs/lustre/llite/file.c                  |  63 ++--
 fs/lustre/llite/llite_internal.h        |   1 +
 fs/lustre/llite/llite_lib.c             |   1 +
 fs/lustre/llite/llite_mmap.c            |  36 +-
 fs/lustre/llite/namei.c                 |   4 -
 fs/lustre/llite/pcc.c                   | 569 +++++++++++++++++++++++++++-----
 fs/lustre/llite/pcc.h                   |  51 ++-
 fs/lustre/llite/vvp_object.c            |   3 +-
 include/uapi/linux/lustre/lustre_user.h |  10 +-
 11 files changed, 604 insertions(+), 169 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 837b68d..9609dd5 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -458,6 +458,10 @@
 #define OBD_FAIL_LLITE_IMUTEX_SEC			0x140e
 #define OBD_FAIL_LLITE_IMUTEX_NOSEC			0x140f
 #define OBD_FAIL_LLITE_OPEN_BY_NAME			0x1410
+#define OBD_FAIL_LLITE_PCC_FAKE_ERROR			0x1411
+#define OBD_FAIL_LLITE_PCC_DETACH_MKWRITE		0x1412
+#define OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE		0x1413
+#define OBD_FAIL_LLITE_PCC_ATTACH_PAUSE			0x1414
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 337582b..1f7ed32 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1917,41 +1917,12 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return ll_ioctl_fsgetxattr(inode, cmd, arg);
 	case FS_IOC_FSSETXATTR:
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
-	case LL_IOC_PCC_DETACH: {
+	case LL_IOC_PCC_DETACH_BY_FID: {
 		struct lu_pcc_detach *detach;
 		struct lu_fid *fid;
 		struct inode *inode2;
 		unsigned long ino;
 
-		/*
-		 * The reason why a dir IOCTL is used to detach a PCC-cached
-		 * file rather than making it a file IOCTL is:
-		 * When PCC caching a file, it will attach the file firstly,
-		 * and increase the refcount of PCC inode (pcci->pcci_refcount)
-		 * from 0 to 1.
-		 * When detaching a PCC-cached file, it will check whether the
-		 * refcount is 1. If so, the file can be detached successfully.
-		 * Otherwise, it means there are some users opened and using
-		 * the file currently, and it will return -EBUSY.
-		 * Each open on the PCC-cached file will increase the refcount
-		 * of the PCC inode;
-		 * Each close on the PCC-cached file will decrease the refcount
-		 * of the PCC inode;
-		 * When used a file IOCTL to detach a PCC-cached file, it needs
-		 * to open it at first, which will increase the refcount. So
-		 * during the process of the detach IOCTL, it will return
-		 * -EBUSY as the PCC inode refcount is larger than 1. Someone
-		 * might argue that here it can just decrease the refcount
-		 * of the PCC inode, return succeed and make the close of
-		 * IOCTL file handle to perform the real detach. But this
-		 * may result in inconsistent state of a PCC file. i.e. Process
-		 * A got a successful return form the detach IOCTL; Process B
-		 * opens the file before Process A finally closed the IOCTL
-		 * file handle. It makes the following I/O of Process B will
-		 * direct into PCC although the file was already detached from
-		 * the view of Process A.
-		 * Using a dir IOCTL does not exist the problem above.
-		 */
 		detach = kzalloc(sizeof(*detach), GFP_KERNEL);
 		if (!detach)
 			return -ENOMEM;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 95e7c73..5a52cad 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -59,6 +59,7 @@ struct split_param {
 struct pcc_param {
 	u64	pa_data_version;
 	u32	pa_archive_id;
+	u32	pa_layout_gen;
 };
 
 static int
@@ -241,6 +242,12 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 		if (!(body->mbo_valid & OBD_MD_CLOSE_INTENT_EXECED))
 			rc = -EBUSY;
+
+		if (bias & MDS_PCC_ATTACH) {
+			struct pcc_param *param = data;
+
+			param->pa_layout_gen = body->mbo_layout_gen;
+		}
 	}
 
 	ll_finish_md_op_data(op_data);
@@ -1657,7 +1664,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ssize_t result;
 	u16 refcheck;
 	ssize_t rc2;
-	bool cached = false;
+	bool cached;
 
 	/**
 	 * Currently when PCC read failed, we do not fall back to the
@@ -1766,20 +1773,21 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct vvp_io_args *args;
 	ssize_t rc_tiny = 0, rc_normal;
 	u16 refcheck;
-	bool cached = false;
+	bool cached;
 	int result;
 
 	/**
-	 * When PCC write failed, we do not fall back to the normal
-	 * write path, just return the error. The reason is that:
-	 * PCC is actually a HSM device, and HSM does not handle the
-	 * failure especially -ENOSPC due to space used out; Moreover,
-	 * the fallback to normal I/O path for ENOSPC failure, needs
-	 * to restore the file data to OSTs first and redo the write
-	 * again, making the logic of PCC very complex.
+	 * When PCC write failed, we usually do not fall back to the normal
+	 * write path, just return the error. But there is a special case when
+	 * returned error code is -ENOSPC due to running out of space on PCC HSM
+	 * bakcend. At this time, it will fall back to normal I/O path and
+	 * retry the I/O. As the file is in HSM released state, it will restore
+	 * the file data to OSTs first and redo the write again. And the
+	 * restore process will revoke the layout lock and detach the file
+	 * from PCC cache automatically.
 	 */
 	result = pcc_file_write_iter(iocb, from, &cached);
-	if (cached)
+	if (cached && result != -ENOSPC)
 		return result;
 
 	/* NB: we can't do direct IO for tiny writes because they use the page
@@ -3197,8 +3205,10 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 	case LL_LEASE_PCC_ATTACH:
 		if (!rc)
 			rc = rc2;
-		rc = pcc_readwrite_attach_fini(file, inode, lease_broken,
-					       rc, attached);
+		rc = pcc_readwrite_attach_fini(file, inode,
+					       param.pa_layout_gen,
+					       lease_broken, rc,
+					       attached);
 		break;
 	}
 
@@ -3721,6 +3731,14 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		rc = ll_heat_set(inode, flags);
 		return rc;
 	}
+	case LL_IOC_PCC_DETACH:
+		if (!S_ISREG(inode->i_mode))
+			return -EINVAL;
+
+		if (!inode_owner_or_capable(inode))
+			return -EPERM;
+
+		return pcc_ioctl_detach(inode);
 	case LL_IOC_PCC_STATE: {
 		struct lu_pcc_state __user *ustate =
 			(struct lu_pcc_state __user *)arg;
@@ -3735,7 +3753,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 			goto out_state;
 		}
 
-		rc = pcc_ioctl_state(inode, state);
+		rc = pcc_ioctl_state(file, inode, state);
 		if (rc)
 			goto out_state;
 
@@ -3855,19 +3873,13 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct inode *inode = file_inode(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ptlrpc_request *req;
-	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
 	int rc, err;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p)\n",
 	       PFID(ll_inode2fid(inode)), inode);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
 
-	/* pcc cache path */
-	if (pcc_file)
-		return file_inode(pcc_file)->i_fop->fsync(pcc_file,
-					start, end, datasync);
 
 	rc = file_write_and_wait_range(file, start, end);
 	inode_lock(inode);
@@ -3877,6 +3889,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	 */
 	if (!S_ISDIR(inode->i_mode)) {
 		err = lli->lli_async_rc;
+
 		lli->lli_async_rc = 0;
 		if (rc == 0)
 			rc = err;
@@ -3895,8 +3908,15 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	if (S_ISREG(inode->i_mode)) {
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+		bool cached;
 
-		err = cl_sync_file_range(inode, start, end, CL_FSYNC_ALL, 0);
+		/* Sync metadata on MDT first, and then sync the cached data
+		 * on PCC.
+		 */
+		err = pcc_fsync(file, start, end, datasync, &cached);
+		if (!cached)
+			err = cl_sync_file_range(inode, start, end,
+						 CL_FSYNC_ALL, 0);
 		if (rc == 0 && err < 0)
 			rc = err;
 		if (rc < 0)
@@ -4416,11 +4436,12 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 		return rc;
 
 	if (S_ISREG(inode->i_mode)) {
-		bool cached = false;
+		bool cached;
 
 		rc = pcc_inode_getattr(inode, &cached);
 		if (cached && rc < 0)
 			return rc;
+
 		/* In case of restore, the MDT has the right size and has
 		 * already send it back without granting the layout lock,
 		 * inode is up-to-date so glimpse is useless.
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index f2ea856..d36e01e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -208,6 +208,7 @@ struct ll_inode_info {
 			char				lli_jobid[LUSTRE_JOBID_SIZE];
 
 			struct mutex		 lli_pcc_lock;
+			enum lu_pcc_state_flags	 lli_pcc_state;
 			struct pcc_inode	*lli_pcc_inode;
 		};
 	};
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index d46bc99..1b22062 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -956,6 +956,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		obd_heat_clear(lli->lli_heat_instances, OBD_HEAT_COUNT);
 		lli->lli_heat_flags = 0;
 		mutex_init(&lli->lli_pcc_lock);
+		lli->lli_pcc_state = PCC_STATE_FL_NONE;
 		lli->lli_pcc_inode = NULL;
 	}
 	mutex_init(&lli->lli_layout_mutex);
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index fc2331b..71799cd 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -360,9 +360,17 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	int count = 0;
 	bool printed = false;
+	bool cached;
 	vm_fault_t result;
 	sigset_t old, new;
 
+	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
+			   LPROC_LL_FAULT, 1);
+
+	result = pcc_fault(vma, vmf, &cached);
+	if (cached)
+		return result;
+
 	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
 	 * so that it can be killed by admin but not cause segfault by
 	 * other signals.
@@ -370,9 +378,6 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	siginitsetinv(&new, sigmask(SIGKILL) | sigmask(SIGTERM));
 	sigprocmask(SIG_BLOCK, &new, &old);
 
-	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
-			   LPROC_LL_FAULT, 1);
-
 	/* make sure offset is not a negative number */
 	if (vmf->pgoff > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return VM_FAULT_SIGBUS;
@@ -410,12 +415,17 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 	int count = 0;
 	bool printed = false;
 	bool retry;
+	bool cached;
 	int err;
 	vm_fault_t ret;
 
 	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
 			   LPROC_LL_MKWRITE, 1);
 
+	err = pcc_page_mkwrite(vma, vmf, &cached);
+	if (cached)
+		return err;
+
 	file_update_time(vma->vm_file);
 	do {
 		retry = false;
@@ -463,6 +473,7 @@ static void ll_vm_open(struct vm_area_struct *vma)
 
 	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
 	atomic_inc(&vob->vob_mmap_cnt);
+	pcc_vm_open(vma);
 }
 
 /**
@@ -475,6 +486,7 @@ static void ll_vm_close(struct vm_area_struct *vma)
 
 	atomic_dec(&vob->vob_mmap_cnt);
 	LASSERT(atomic_read(&vob->vob_mmap_cnt) >= 0);
+	pcc_vm_close(vma);
 }
 
 /* XXX put nice comment here.  talk about __free_pte -> dirty pages and
@@ -488,7 +500,7 @@ int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last)
 	if (mapping_mapped(mapping)) {
 		rc = 0;
 		unmap_mapping_range(mapping, first + PAGE_SIZE - 1,
-				    last - first + 1, 0);
+				    last - first + 1, 1);
 	}
 
 	return rc;
@@ -504,26 +516,24 @@ int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last)
 int ll_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(file);
+	bool cached;
 	int rc;
-	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
-	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
-
-	/* pcc cache path */
-	if (pcc_file) {
-		vma->vm_file = pcc_file;
-		return file_inode(pcc_file)->i_fop->mmap(pcc_file, vma);
-	}
 
 	if (ll_file_nolock(file))
 		return -EOPNOTSUPP;
 
+	rc = pcc_file_mmap(file, vma, &cached);
+	if (cached && rc != 0)
+		return rc;
+
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_MAP, 1);
 	rc = generic_file_mmap(file, vma);
 	if (rc == 0) {
 		vma->vm_ops = &ll_file_vm_ops;
 		vma->vm_ops->open(vma);
 		/* update the inode's size and mtime */
-		rc = ll_glimpse_size(inode);
+		if (!cached)
+			rc = ll_glimpse_size(inode);
 	}
 
 	return rc;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 4f39b2c..d10decb 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -824,10 +824,6 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 		lum->lmm_magic = LOV_USER_MAGIC_V1;
 		lum->lmm_pattern = LOV_PATTERN_F_RELEASED | LOV_PATTERN_RAID0;
-		lum->lmm_stripe_size = 0;
-		lum->lmm_stripe_count = 0;
-		lum->lmm_stripe_offset = 0;
-
 		op_data->op_data = lum;
 		op_data->op_data_size = sizeof(*lum);
 		op_data->op_archive_id = dataset->pccd_id;
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 53e5cda..8440647 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -401,17 +401,25 @@ static inline void pcc_inode_unlock(struct inode *inode)
 	mutex_unlock(&ll_i2info(inode)->lli_pcc_lock);
 }
 
-static void pcc_inode_init(struct pcc_inode *pcci)
+static void pcc_inode_init(struct pcc_inode *pcci, struct ll_inode_info *lli)
 {
+	pcci->pcci_lli = lli;
+	lli->lli_pcc_inode = pcci;
 	atomic_set(&pcci->pcci_refcount, 0);
 	pcci->pcci_type = LU_PCC_NONE;
+	pcci->pcci_layout_gen = CL_LAYOUT_GEN_NONE;
+	atomic_set(&pcci->pcci_active_ios, 0);
+	init_waitqueue_head(&pcci->pcci_waitq);
 }
 
 static void pcc_inode_fini(struct pcc_inode *pcci)
 {
+	struct ll_inode_info *lli = pcci->pcci_lli;
+
 	path_put(&pcci->pcci_path);
 	pcci->pcci_type = LU_PCC_NONE;
 	kmem_cache_free(pcc_inode_slab, pcci);
+	lli->lli_pcc_inode = NULL;
 }
 
 static void pcc_inode_get(struct pcc_inode *pcci)
@@ -427,13 +435,11 @@ static void pcc_inode_put(struct pcc_inode *pcci)
 
 void pcc_inode_free(struct inode *inode)
 {
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct pcc_inode *pcci = lli->lli_pcc_inode;
+	struct pcc_inode *pcci = ll_i2pcci(inode);
 
 	if (pcci) {
 		WARN_ON(atomic_read(&pcci->pcci_refcount) > 1);
 		pcc_inode_put(pcci);
-		lli->lli_pcc_inode = NULL;
 	}
 }
 
@@ -463,6 +469,11 @@ void pcc_file_init(struct pcc_file *pccf)
 	pccf->pccf_type = LU_PCC_NONE;
 }
 
+static inline bool pcc_inode_has_layout(struct pcc_inode *pcci)
+{
+	return pcci->pcci_layout_gen != CL_LAYOUT_GEN_NONE;
+}
+
 int pcc_file_open(struct inode *inode, struct file *file)
 {
 	struct pcc_inode *pcci;
@@ -481,7 +492,8 @@ int pcc_file_open(struct inode *inode, struct file *file)
 	if (!pcci)
 		goto out_unlock;
 
-	if (atomic_read(&pcci->pcci_refcount) == 0)
+	if (atomic_read(&pcci->pcci_refcount) == 0 ||
+	    !pcc_inode_has_layout(pcci))
 		goto out_unlock;
 
 	pcc_inode_get(pcci);
@@ -534,24 +546,64 @@ void pcc_file_release(struct inode *inode, struct file *file)
 	pcc_inode_unlock(inode);
 }
 
+static inline void pcc_layout_gen_set(struct pcc_inode *pcci,
+				      u32 gen)
+{
+	pcci->pcci_layout_gen = gen;
+}
+
+static void pcc_io_init(struct inode *inode, bool *cached)
+{
+	struct pcc_inode *pcci;
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (pcci && pcc_inode_has_layout(pcci)) {
+		LASSERT(atomic_read(&pcci->pcci_refcount) > 0);
+		atomic_inc(&pcci->pcci_active_ios);
+		*cached = true;
+	} else {
+		*cached = false;
+	}
+	pcc_inode_unlock(inode);
+}
+
+static void pcc_io_fini(struct inode *inode)
+{
+	struct pcc_inode *pcci = ll_i2pcci(inode);
+
+	LASSERT(pcci && atomic_read(&pcci->pcci_active_ios) > 0);
+	if (atomic_dec_and_test(&pcci->pcci_active_ios))
+		wake_up_all(&pcci->pcci_waitq);
+}
+
 ssize_t pcc_file_read_iter(struct kiocb *iocb,
 			   struct iov_iter *iter, bool *cached)
 {
 	struct file *file = iocb->ki_filp;
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct pcc_file *pccf = &fd->fd_pcc_file;
+	struct inode *inode = file_inode(file);
 	ssize_t result;
 
 	if (!pccf->pccf_file) {
 		*cached = false;
 		return 0;
 	}
-	*cached = true;
-	iocb->ki_filp = pccf->pccf_file;
 
-	result = generic_file_read_iter(iocb, iter);
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
+
+	iocb->ki_filp = pccf->pccf_file;
+	/* generic_file_aio_read does not support ext4-dax,
+	 * filp->f_ops->read_iter uses ->aio_read hook directly
+	 * to add support for ext4-dax.
+	 */
+	result = file->f_op->read_iter(iocb, iter);
 	iocb->ki_filp = file;
 
+	pcc_io_fini(inode);
 	return result;
 }
 
@@ -561,16 +613,27 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb,
 	struct file *file = iocb->ki_filp;
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct pcc_file *pccf = &fd->fd_pcc_file;
+	struct inode *inode = file_inode(file);
 	ssize_t result;
 
 	if (!pccf->pccf_file) {
 		*cached = false;
 		return 0;
 	}
-	*cached = true;
 
-	if (pccf->pccf_type != LU_PCC_READWRITE)
-		return -EWOULDBLOCK;
+	if (pccf->pccf_type != LU_PCC_READWRITE) {
+		*cached = false;
+		return -EAGAIN;
+	}
+
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
+
+	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PCC_FAKE_ERROR)) {
+		result = -ENOSPC;
+		goto out;
+	}
 
 	iocb->ki_filp = pccf->pccf_file;
 
@@ -580,6 +643,8 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb,
 	 */
 	result = file->f_op->write_iter(iocb, iter);
 	iocb->ki_filp = file;
+out:
+	pcc_io_fini(inode);
 	return result;
 }
 
@@ -587,37 +652,35 @@ int pcc_inode_setattr(struct inode *inode, struct iattr *attr,
 		      bool *cached)
 {
 	int rc = 0;
-	struct pcc_inode *pcci;
 	struct iattr attr2 = *attr;
 	struct dentry *pcc_dentry;
+	struct pcc_inode *pcci;
 
 	if (!S_ISREG(inode->i_mode)) {
 		*cached = false;
 		return 0;
 	}
 
-	pcc_inode_lock(inode);
-	pcci = ll_i2pcci(inode);
-	if (!pcci || atomic_read(&pcci->pcci_refcount) == 0)
-		goto out_unlock;
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
 
-	*cached = true;
 	attr2.ia_valid = attr->ia_valid & (ATTR_SIZE | ATTR_ATIME |
 			 ATTR_ATIME_SET | ATTR_MTIME | ATTR_MTIME_SET |
 			 ATTR_CTIME);
+	pcci = ll_i2pcci(inode);
 	pcc_dentry = pcci->pcci_path.dentry;
 	inode_lock(pcc_dentry->d_inode);
 	rc = pcc_dentry->d_inode->i_op->setattr(pcc_dentry, &attr2);
 	inode_unlock(pcc_dentry->d_inode);
-out_unlock:
-	pcc_inode_unlock(inode);
+
+	pcc_io_fini(inode);
 	return rc;
 }
 
 int pcc_inode_getattr(struct inode *inode, bool *cached)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct pcc_inode *pcci;
 	struct kstat stat;
 	s64 atime;
 	s64 mtime;
@@ -629,16 +692,14 @@ int pcc_inode_getattr(struct inode *inode, bool *cached)
 		return 0;
 	}
 
-	pcc_inode_lock(inode);
-	pcci = ll_i2pcci(inode);
-	if (!pcci || atomic_read(&pcci->pcci_refcount) == 0)
-		goto out_unlock;
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
 
-	*cached = true;
-	rc = vfs_getattr(&pcci->pcci_path, &stat,
+	rc = vfs_getattr(&ll_i2pcci(inode)->pcci_path, &stat,
 			 STATX_BASIC_STATS, AT_STATX_SYNC_AS_STAT);
 	if (rc)
-		goto out_unlock;
+		goto out;
 
 	ll_inode_size_lock(inode);
 	if (test_and_clear_bit(LLIF_UPDATE_ATIME, &lli->lli_flags) ||
@@ -669,9 +730,274 @@ int pcc_inode_getattr(struct inode *inode, bool *cached)
 	inode->i_ctime.tv_sec = ctime;
 
 	ll_inode_size_unlock(inode);
+out:
+	pcc_io_fini(inode);
+	return rc;
+}
 
-out_unlock:
+ssize_t pcc_file_splice_read(struct file *in_file, loff_t *ppos,
+			     struct pipe_inode_info *pipe,
+			     size_t count, unsigned int flags,
+			     bool *cached)
+{
+	struct inode *inode = file_inode(in_file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(in_file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	ssize_t result;
+
+	*cached = false;
+	if (!pcc_file)
+		return 0;
+
+	if (!file_inode(pcc_file)->i_fop->splice_read)
+		return -ENOTSUPP;
+
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
+
+	result = file_inode(pcc_file)->i_fop->splice_read(pcc_file,
+							  ppos, pipe, count,
+							  flags);
+
+	pcc_io_fini(inode);
+	return result;
+}
+
+int pcc_fsync(struct file *file, loff_t start, loff_t end,
+	      int datasync, bool *cached)
+{
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	int rc;
+
+	if (!pcc_file) {
+		*cached = false;
+		return 0;
+	}
+
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
+
+	rc = file_inode(pcc_file)->i_fop->fsync(pcc_file,
+						start, end, datasync);
+
+	pcc_io_fini(inode);
+	return rc;
+}
+
+int pcc_file_mmap(struct file *file, struct vm_area_struct *vma,
+		  bool *cached)
+{
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	struct pcc_inode *pcci;
+	int rc = 0;
+
+	if (!pcc_file || !file_inode(pcc_file)->i_fop->mmap) {
+		*cached = false;
+		return 0;
+	}
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (pcci && pcc_inode_has_layout(pcci)) {
+		LASSERT(atomic_read(&pcci->pcci_refcount) > 1);
+		*cached = true;
+		vma->vm_file = pcc_file;
+		rc = file_inode(pcc_file)->i_fop->mmap(pcc_file, vma);
+		vma->vm_file = file;
+		/* Save the vm ops of backend PCC */
+		vma->vm_private_data = (void *)vma->vm_ops;
+	} else {
+		*cached = false;
+	}
 	pcc_inode_unlock(inode);
+
+	return rc;
+}
+
+void pcc_vm_open(struct vm_area_struct *vma)
+{
+	struct pcc_inode *pcci;
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	const struct vm_operations_struct *pcc_vm_ops = vma->vm_private_data;
+
+	if (!pcc_file || !pcc_vm_ops || !pcc_vm_ops->open)
+		return;
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (pcci && pcc_inode_has_layout(pcci)) {
+		vma->vm_file = pcc_file;
+		pcc_vm_ops->open(vma);
+		vma->vm_file = file;
+	}
+	pcc_inode_unlock(inode);
+}
+
+void pcc_vm_close(struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	const struct vm_operations_struct *pcc_vm_ops = vma->vm_private_data;
+
+	if (!pcc_file || !pcc_vm_ops || !pcc_vm_ops->close)
+		return;
+
+	pcc_inode_lock(inode);
+	/* Layout lock maybe revoked here */
+	vma->vm_file = pcc_file;
+	pcc_vm_ops->close(vma);
+	vma->vm_file = file;
+	pcc_inode_unlock(inode);
+}
+
+int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
+		     bool *cached)
+{
+	struct page *page = vmf->page;
+	struct mm_struct *mm = vma->vm_mm;
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	const struct vm_operations_struct *pcc_vm_ops = vma->vm_private_data;
+	int rc;
+
+	if (!pcc_file || !pcc_vm_ops || !pcc_vm_ops->page_mkwrite) {
+		*cached = false;
+		return 0;
+	}
+
+	/* Pause to allow for a race with concurrent detach */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE, cfs_fail_val);
+
+	pcc_io_init(inode, cached);
+	if (!*cached) {
+		/* This happens when the file is detached from PCC after got
+		 * the fault page via ->fault() on the inode of the PCC copy.
+		 * Here it can not simply fall back to normal Lustre I/O path.
+		 * The reason is that the address space of fault page used by
+		 * ->page_mkwrite() is still the one of PCC inode. In the
+		 * normal Lustre ->page_mkwrite() I/O path, it will be wrongly
+		 * handled as the address space of the fault page is not
+		 * consistent with the one of the Lustre inode (though the
+		 * fault page was truncated).
+		 * As the file is detached from PCC, the fault page must
+		 * be released frist, and retry the mmap write (->fault() and
+		 * ->page_mkwrite).
+		 * We use an ugly and tricky method by returning
+		 * VM_FAULT_NOPAGE | VM_FAULT_RETRY to the caller
+		 * __do_page_fault and retry the memory fault handling.
+		 */
+		if (page->mapping == file_inode(pcc_file)->i_mapping) {
+			*cached = true;
+			up_read(&mm->mmap_sem);
+			return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
+		}
+
+		return 0;
+	}
+
+	/*
+	 * This fault injection can also be used to simulate -ENOSPC and
+	 * -EDQUOT failure of underlying PCC backend fs.
+	 */
+	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PCC_DETACH_MKWRITE)) {
+		pcc_io_fini(inode);
+		pcc_ioctl_detach(inode);
+		up_read(&mm->mmap_sem);
+		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
+	}
+
+	vma->vm_file = pcc_file;
+	rc = pcc_vm_ops->page_mkwrite(vmf);
+	vma->vm_file = file;
+
+	pcc_io_fini(inode);
+	return rc;
+}
+
+int pcc_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
+	      bool *cached)
+{
+	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct file *pcc_file = fd->fd_pcc_file.pccf_file;
+	const struct vm_operations_struct *pcc_vm_ops = vma->vm_private_data;
+	int rc;
+
+	if (!pcc_file || !pcc_vm_ops || !pcc_vm_ops->fault) {
+		*cached = false;
+		return 0;
+	}
+
+	pcc_io_init(inode, cached);
+	if (!*cached)
+		return 0;
+
+	vma->vm_file = pcc_file;
+	rc = pcc_vm_ops->fault(vmf);
+	vma->vm_file = file;
+
+	pcc_io_fini(inode);
+	return rc;
+}
+
+static void pcc_layout_wait(struct pcc_inode *pcci)
+{
+	if (atomic_read(&pcci->pcci_active_ios) > 0)
+		CDEBUG(D_CACHE, "Waiting for IO completion: %d\n",
+		       atomic_read(&pcci->pcci_active_ios));
+	wait_event_idle(pcci->pcci_waitq,
+			atomic_read(&pcci->pcci_active_ios) == 0);
+}
+
+static void __pcc_layout_invalidate(struct pcc_inode *pcci)
+{
+	pcci->pcci_type = LU_PCC_NONE;
+	pcc_layout_gen_set(pcci, CL_LAYOUT_GEN_NONE);
+	pcc_layout_wait(pcci);
+}
+
+void pcc_layout_invalidate(struct inode *inode)
+{
+	struct pcc_inode *pcci;
+
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	if (pcci && pcc_inode_has_layout(pcci)) {
+		LASSERT(atomic_read(&pcci->pcci_refcount) > 0);
+		__pcc_layout_invalidate(pcci);
+
+		CDEBUG(D_CACHE, "Invalidate "DFID" layout gen %d\n",
+		       PFID(&ll_i2info(inode)->lli_fid), pcci->pcci_layout_gen);
+
+		pcc_inode_put(pcci);
+	}
+	pcc_inode_unlock(inode);
+}
+
+static int pcc_inode_remove(struct pcc_inode *pcci)
+{
+	struct dentry *dentry;
+	int rc;
+
+	dentry = pcci->pcci_path.dentry;
+	rc = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
+	if (rc)
+		CWARN("failed to unlink cached file, rc = %d\n", rc);
+
 	return rc;
 }
 
@@ -719,9 +1045,10 @@ int pcc_inode_getattr(struct inode *inode, bool *cached)
 		*ptr = '\0';
 		child = pcc_mkdir(parent, entry_name, mode);
 		*ptr = '/';
+		dput(parent);
 		if (IS_ERR(child))
 			break;
-		dput(parent);
+
 		parent = child;
 		ptr++;
 		entry_name = ptr;
@@ -816,21 +1143,36 @@ int pcc_inode_create(struct pcc_dataset *dataset, struct lu_fid *fid,
 int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 			  struct dentry *pcc_dentry)
 {
-	struct ll_inode_info *lli = ll_i2info(inode);
 	struct pcc_inode *pcci;
+	int rc = 0;
 
+	pcc_inode_lock(inode);
 	LASSERT(!ll_i2pcci(inode));
 	pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
-	if (!pcci)
-		return -ENOMEM;
+	if (!pcci) {
+		rc = -ENOMEM;
+		goto out_unlock;
+	}
 
-	pcc_inode_init(pcci);
-	pcc_inode_lock(inode);
+	pcc_inode_init(pcci, ll_i2info(inode));
 	pcc_inode_attach_init(dataset, pcci, pcc_dentry, LU_PCC_READWRITE);
-	lli->lli_pcc_inode = pcci;
-	pcc_inode_unlock(inode);
+	/* Set the layout generation of newly created file with 0 */
+	pcc_layout_gen_set(pcci, 0);
 
-	return 0;
+out_unlock:
+	if (rc) {
+		int rc2;
+
+		rc2 = vfs_unlink(pcc_dentry->d_parent->d_inode,
+				 pcc_dentry, NULL);
+		if (rc2)
+			CWARN("failed to unlink PCC file, rc = %d\n", rc2);
+
+		dput(pcc_dentry);
+	}
+
+	pcc_inode_unlock(inode);
+	return rc;
 }
 
 static int pcc_filp_write(struct file *filp, const void *buf, ssize_t count,
@@ -881,6 +1223,30 @@ static int pcc_copy_data(struct file *src, struct file *dst)
 	return rc;
 }
 
+static int pcc_attach_allowed_check(struct inode *inode)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci;
+	int rc = 0;
+
+	pcc_inode_lock(inode);
+	if (lli->lli_pcc_state & PCC_STATE_FL_ATTACHING) {
+		rc = -EBUSY;
+		goto out_unlock;
+	}
+
+	pcci = ll_i2pcci(inode);
+	if (pcci && pcc_inode_has_layout(pcci)) {
+		rc = -EEXIST;
+		goto out_unlock;
+	}
+
+	lli->lli_pcc_state |= PCC_STATE_FL_ATTACHING;
+out_unlock:
+	pcc_inode_unlock(inode);
+	return rc;
+}
+
 int pcc_readwrite_attach(struct file *file, struct inode *inode,
 			 u32 archive_id)
 {
@@ -892,28 +1258,14 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	struct path path;
 	int rc;
 
-	pcc_inode_lock(inode);
-	pcci = ll_i2pcci(inode);
-	if (!pcci) {
-		pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
-		if (!pcci) {
-			pcc_inode_unlock(inode);
-			return -ENOMEM;
-		}
-
-		pcc_inode_init(pcci);
-	} else if (atomic_read(&pcci->pcci_refcount) > 0) {
-		pcc_inode_unlock(inode);
-		return -EEXIST;
-	}
-	pcc_inode_unlock(inode);
+	rc = pcc_attach_allowed_check(inode);
+	if (rc)
+		return rc;
 
 	dataset = pcc_dataset_get(&ll_i2sbi(inode)->ll_pcc_super, 0,
 				  archive_id);
-	if (!dataset) {
-		rc = -ENOENT;
-		goto out_free_pcci;
-	}
+	if (!dataset)
+		return -ENOENT;
 
 	rc = __pcc_inode_create(dataset, &lli->lli_fid, &dentry);
 	if (rc)
@@ -932,73 +1284,117 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	if (rc)
 		goto out_fput;
 
+	/* Pause to allow for a race with concurrent HSM remove */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_ATTACH_PAUSE, cfs_fail_val);
+
 	pcc_inode_lock(inode);
-	if (lli->lli_pcc_inode) {
-		rc = -EEXIST;
+	pcci = ll_i2pcci(inode);
+	LASSERT(!pcci);
+	pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
+	if (!pcci) {
+		rc = -ENOMEM;
 		goto out_unlock;
 	}
+
+	pcc_inode_init(pcci, lli);
 	pcc_inode_attach_init(dataset, pcci, dentry, LU_PCC_READWRITE);
-	lli->lli_pcc_inode = pcci;
 out_unlock:
 	pcc_inode_unlock(inode);
 out_fput:
 	fput(pcc_filp);
 out_dentry:
-	if (rc)
+	if (rc) {
+		int rc2;
+
+		rc2 = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
+		if (rc2)
+			CWARN("failed to unlink PCC file, rc = %d\n", rc2);
+
 		dput(dentry);
+	}
 out_dataset_put:
 	pcc_dataset_put(dataset);
-out_free_pcci:
-	if (rc)
-		kmem_cache_free(pcc_inode_slab, pcci);
 	return rc;
-
 }
 
 int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
-			      bool lease_broken, int rc, bool attached)
+			      u32 gen, bool lease_broken, int rc,
+			      bool attached)
 {
-	struct pcc_inode *pcci = ll_i2pcci(inode);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct pcc_inode *pcci;
+	u32 gen2;
 
-	if ((rc || lease_broken) && attached && pcci)
-		pcc_inode_put(pcci);
+	pcc_inode_lock(inode);
+	pcci = ll_i2pcci(inode);
+	lli->lli_pcc_state &= ~PCC_STATE_FL_ATTACHING;
+	if ((rc || lease_broken)) {
+		if (attached && pcci)
+			pcc_inode_put(pcci);
+
+		goto out_unlock;
+	}
+
+	/* PCC inode may be released due to layout lock revocatioin */
+	if (!pcci) {
+		rc = -ESTALE;
+		goto out_unlock;
+	}
 
+	LASSERT(attached);
+	rc = ll_layout_refresh(inode, &gen2);
+	if (!rc) {
+		if (gen2 == gen) {
+			pcc_layout_gen_set(pcci, gen);
+		} else {
+			CDEBUG(D_CACHE,
+			       DFID" layout changed from %d to %d.\n",
+			       PFID(ll_inode2fid(inode)), gen, gen2);
+			rc = -ESTALE;
+			goto out_put;
+		}
+	}
+
+out_put:
+	if (rc) {
+		pcc_inode_remove(pcci);
+		pcc_inode_put(pcci);
+	}
+out_unlock:
+	pcc_inode_unlock(inode);
 	return rc;
 }
 
 int pcc_ioctl_detach(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct pcc_inode *pcci = lli->lli_pcc_inode;
+	struct pcc_inode *pcci;
 	int rc = 0;
-	int count;
 
 	pcc_inode_lock(inode);
-	if (!pcci)
-		goto out_unlock;
-
-	count = atomic_read(&pcci->pcci_refcount);
-	if (count > 1) {
-		rc = -EBUSY;
-		goto out_unlock;
-	} else if (count == 0)
+	pcci = lli->lli_pcc_inode;
+	if (!pcci || lli->lli_pcc_state & PCC_STATE_FL_ATTACHING ||
+	    !pcc_inode_has_layout(pcci))
 		goto out_unlock;
 
+	__pcc_layout_invalidate(pcci);
 	pcc_inode_put(pcci);
-	lli->lli_pcc_inode = NULL;
+
 out_unlock:
 	pcc_inode_unlock(inode);
-
 	return rc;
 }
 
-int pcc_ioctl_state(struct inode *inode, struct lu_pcc_state *state)
+int pcc_ioctl_state(struct file *file, struct inode *inode,
+		    struct lu_pcc_state *state)
 {
 	int rc = 0;
 	int count;
 	char *buf;
 	char *path;
 	int buf_len = sizeof(state->pccs_path);
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct pcc_file *pccf = &fd->fd_pcc_file;
 	struct pcc_inode *pcci;
 
 	if (buf_len <= 0)
@@ -1018,12 +1414,17 @@ int pcc_ioctl_state(struct inode *inode, struct lu_pcc_state *state)
 	count = atomic_read(&pcci->pcci_refcount);
 	if (count == 0) {
 		state->pccs_type = LU_PCC_NONE;
+		state->pccs_open_count = 0;
 		goto out_unlock;
 	}
+
+	if (pcc_inode_has_layout(pcci))
+		count--;
+	if (pccf->pccf_file)
+		count--;
 	state->pccs_type = pcci->pcci_type;
-	state->pccs_open_count = count - 1;
-	state->pccs_flags = pcci->pcci_attr_valid ?
-			    PCC_STATE_FLAG_ATTR_VALID : 0;
+	state->pccs_open_count = count;
+	state->pccs_flags = ll_i2info(inode)->lli_pcc_state;
 	path = dentry_path_raw(pcci->pcci_path.dentry, buf, buf_len);
 	if (IS_ERR(path)) {
 		rc = PTR_ERR(path);
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index 0f960b9..1a73dbb 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -36,6 +36,7 @@
 #include <linux/types.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/mm.h>
 #include <uapi/linux/lustre/lustre_user.h>
 
 extern struct kmem_cache *pcc_inode_slab;
@@ -57,17 +58,27 @@ struct pcc_super {
 };
 
 struct pcc_inode {
+	struct ll_inode_info	*pcci_lli;
 	/* Cache path on local file system */
-	struct path			 pcci_path;
+	struct path		 pcci_path;
 	/*
 	 * If reference count is 0, then the cache is not inited, if 1, then
 	 * no one is using it.
 	 */
-	atomic_t			 pcci_refcount;
+	atomic_t		 pcci_refcount;
 	/* Whether readonly or readwrite PCC */
-	enum lu_pcc_type		 pcci_type;
-	/* Whether the inode is cached locally */
-	bool				 pcci_attr_valid;
+	enum lu_pcc_type	 pcci_type;
+	/* Whether the inode attr is cached locally */
+	bool			 pcci_attr_valid;
+	/* Layout generation */
+	u32			 pcci_layout_gen;
+	/*
+	 * How many IOs are on going on this cached object. Layout can be
+	 * changed only if there is no active IO.
+	 */
+	atomic_t		 pcci_active_ios;
+	/* Waitq - wait for PCC I/O completion. */
+	wait_queue_head_t	 pcci_waitq;
 };
 
 struct pcc_file {
@@ -101,14 +112,15 @@ struct pcc_cmd {
 void pcc_super_fini(struct pcc_super *super);
 int pcc_cmd_handle(char *buffer, unsigned long count,
 		   struct pcc_super *super);
-int
-pcc_super_dump(struct pcc_super *super, struct seq_file *m);
-int pcc_readwrite_attach(struct file *file,
-			 struct inode *inode, u32 arch_id);
+int pcc_super_dump(struct pcc_super *super, struct seq_file *m);
+int pcc_readwrite_attach(struct file *file, struct inode *inode,
+			 u32 arch_id);
 int pcc_readwrite_attach_fini(struct file *file, struct inode *inode,
-			      bool lease_broken, int rc, bool attached);
+			      u32 gen, bool lease_broken, int rc,
+			      bool attached);
 int pcc_ioctl_detach(struct inode *inode);
-int pcc_ioctl_state(struct inode *inode, struct lu_pcc_state *state);
+int pcc_ioctl_state(struct file *file, struct inode *inode,
+		    struct lu_pcc_state *state);
 void pcc_file_init(struct pcc_file *pccf);
 int pcc_file_open(struct inode *inode, struct file *file);
 void pcc_file_release(struct inode *inode, struct file *file);
@@ -118,12 +130,25 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
 			    bool *cached);
 int pcc_inode_getattr(struct inode *inode, bool *cached);
 int pcc_inode_setattr(struct inode *inode, struct iattr *attr, bool *cached);
+ssize_t pcc_file_splice_read(struct file *in_file, loff_t *ppos,
+			     struct pipe_inode_info *pipe, size_t count,
+			     unsigned int flags, bool *cached);
+int pcc_fsync(struct file *file, loff_t start, loff_t end,
+	      int datasync, bool *cached);
+int pcc_file_mmap(struct file *file, struct vm_area_struct *vma, bool *cached);
+void pcc_vm_open(struct vm_area_struct *vma);
+void pcc_vm_close(struct vm_area_struct *vma);
+int pcc_fault(struct vm_area_struct *mva, struct vm_fault *vmf, bool *cached);
+int pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
+		     bool *cached);
 int pcc_inode_create(struct pcc_dataset *dataset, struct lu_fid *fid,
 		     struct dentry **pcc_dentry);
 int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 			  struct dentry *pcc_dentry);
-struct pcc_dataset *
-pcc_dataset_get(struct pcc_super *super, u32 projid, u32 archive_id);
+struct pcc_dataset *pcc_dataset_get(struct pcc_super *super, u32 projid,
+				    u32 archive_id);
 void pcc_dataset_put(struct pcc_dataset *dataset);
 void pcc_inode_free(struct inode *inode);
+void pcc_layout_invalidate(struct inode *inode);
+
 #endif /* LLITE_PCC_H */
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index eeb8823..b5ae7ad 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -146,7 +146,8 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 		 * a price themselves.
 		 */
 		unmap_mapping_range(conf->coc_inode->i_mapping,
-				    0, OBD_OBJECT_EOF, 0);
+				    0, OBD_OBJECT_EOF, 1);
+		pcc_layout_invalidate(conf->coc_inode);
 	}
 
 	return 0;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 2b12612..b024a44 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -357,7 +357,8 @@ struct ll_ioc_lease_id {
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 #define LL_IOC_HEAT_GET			_IOWR('f', 251, struct lu_heat)
 #define LL_IOC_HEAT_SET			_IOW('f', 251, __u64)
-#define LL_IOC_PCC_DETACH		_IOW('f', 252, struct lu_pcc_detach)
+#define LL_IOC_PCC_DETACH		_IO('f', 252)
+#define LL_IOC_PCC_DETACH_BY_FID	_IOW('f', 252, struct lu_pcc_detach)
 #define LL_IOC_PCC_STATE		_IOR('f', 252, struct lu_pcc_state)
 
 #define LL_STATFS_LMV		1
@@ -2098,8 +2099,11 @@ struct lu_pcc_detach {
 };
 
 enum lu_pcc_state_flags {
-	/* Whether the inode attr is cached locally */
-	PCC_STATE_FLAG_ATTR_VALID	= 0x1,
+	PCC_STATE_FL_NONE		= 0x0,
+	/* The inode attr is cached locally */
+	PCC_STATE_FL_ATTR_VALID		= 0x01,
+	/* The file is being attached into PCC */
+	PCC_STATE_FL_ATTACHING		= 0x02,
 };
 
 struct lu_pcc_state {
-- 
1.8.3.1
