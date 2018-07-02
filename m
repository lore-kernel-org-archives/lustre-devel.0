From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:22 -0400
Subject: [lustre-devel] [PATCH 05/18] lustre: llite: fast read implementation
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

For read operation, if a page is already in cache, it must be covered
by a DLM lock. We can take advantage of this by reading cached page
without interacting with Lustre. Traditional read will go on if fast
read fails.

This patch can improve small read performance significantly.
These are the performance data I collected:

+------------+----------------+-----------------+
|            | read bs=4k     | read bs=1M      |
+------------+----------------+-----------------+
| w/o patch  | 257 MB/s       | 1.1 GB/s        |
+------------+----------------+-----------------+
| w/ patch   | 1.2 GB/s       | 1.4 GB/s        |
+------------+----------------+-----------------+

Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4257
Reviewed-on: http://review.whamcloud.com/20255
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         | 104 +++++++++++++++++++--
 .../staging/lustre/lustre/llite/llite_internal.h   |  23 ++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   1 +
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  34 ++++++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  38 ++++++++
 drivers/staging/lustre/lustre/llite/rw.c           |  68 ++++++++++++--
 drivers/staging/lustre/lustre/llite/vvp_internal.h |   1 +
 7 files changed, 252 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 5f944ca..db18d1d 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -953,10 +953,21 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 
 	ll_inode_size_lock(inode);
 
-	/* merge timestamps the most recently obtained from mds with
-	 * timestamps obtained from osts
+	/*
+	 * merge timestamps the most recently obtained from MDS with
+	 * timestamps obtained from OSTSs.
+	 *
+	 * Do not overwrite atime of inode because it may be refreshed
+	 * by file_accessed() function. If the read was served by cache
+	 * data, there is no RPC to be sent so that atime may not be
+	 * transferred to OSTs at all. MDT only updates atime at close time
+	 * if it's at least 'mdd.*.atime_diff' older.
+	 * All in all, the atime in Lustre does not strictly comply with
+	 * POSIX. Solving this problem needs to send an RPC to MDT for each
+	 * read, this will hurt performance.
 	 */
-	inode->i_atime.tv_sec = lli->lli_atime;
+	if (inode->i_atime.tv_sec < lli->lli_atime)
+		inode->i_atime.tv_sec = lli->lli_atime;
 	inode->i_mtime.tv_sec = lli->lli_mtime;
 	inode->i_ctime.tv_sec = lli->lli_ctime;
 
@@ -1096,7 +1107,7 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 
 			range_locked = true;
 		}
-		ll_cl_add(file, env, io);
+		ll_cl_add(file, env, io, LCC_RW);
 		rc = cl_io_loop(env, io);
 		ll_cl_remove(file, env);
 		if (range_locked) {
@@ -1155,23 +1166,104 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	return result > 0 ? result : rc;
 }
 
+/**
+ * The purpose of fast read is to overcome per I/O overhead and improve IOPS
+ * especially for small I/O.
+ *
+ * To serve a read request, CLIO has to create and initialize a cl_io and
+ * then request DLM lock. This has turned out to have siginificant overhead
+ * and affects the performance of small I/O dramatically.
+ *
+ * It's not necessary to create a cl_io for each I/O. Under the help of read
+ * ahead, most of the pages being read are already in memory cache and we can
+ * read those pages directly because if the pages exist, the corresponding DLM
+ * lock must exist so that page content must be valid.
+ *
+ * In fast read implementation, the llite speculatively finds and reads pages
+ * in memory cache. There are three scenarios for fast read:
+ *   - If the page exists and is uptodate, kernel VM will provide the data and
+ *     CLIO won't be intervened;
+ *   - If the page was brought into memory by read ahead, it will be exported
+ *     and read ahead parameters will be updated;
+ *   - Otherwise the page is not in memory, we can't do fast read. Therefore,
+ *     it will go back and invoke normal read, i.e., a cl_io will be created
+ *     and DLM lock will be requested.
+ *
+ * POSIX compliance: posix standard states that read is intended to be atomic.
+ * Lustre read implementation is in line with Linux kernel read implementation
+ * and neither of them complies with POSIX standard in this matter. Fast read
+ * doesn't make the situation worse on single node but it may interleave write
+ * results from multiple nodes due to short read handling in ll_file_aio_read().
+ *
+ * @env   - lu_env
+ * @iocb  - kiocb from kernel
+ * @iter  - user space buffers where the data will be copied
+ *
+ * RETURN - number of bytes have been read, or error code if error occurred.
+ */
+static ssize_t
+ll_do_fast_read(const struct lu_env *env, struct kiocb *iocb,
+		struct iov_iter *iter)
+{
+	ssize_t result;
+
+	if (!ll_sbi_has_fast_read(ll_i2sbi(file_inode(iocb->ki_filp))))
+		return 0;
+
+	/*
+	 * NB: we can't do direct IO for fast read because it will need a lock
+	 * to make IO engine happy.
+	 */
+	if (iocb->ki_filp->f_flags & O_DIRECT)
+		return 0;
+
+	ll_cl_add(iocb->ki_filp, env, NULL, LCC_RW);
+	result = generic_file_read_iter(iocb, iter);
+	ll_cl_remove(iocb->ki_filp, env);
+
+	/*
+	 * If the first page is not in cache, generic_file_aio_read() will be
+	 * returned with -ENODATA.
+	 * See corresponding code in ll_readpage().
+	 */
+	if (result == -ENODATA)
+		result = 0;
+
+	if (result > 0)
+		ll_stats_ops_tally(ll_i2sbi(file_inode(iocb->ki_filp)),
+				   LPROC_LL_READ_BYTES, result);
+
+	return result;
+}
+
 static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct lu_env      *env;
 	struct vvp_io_args *args;
 	ssize_t	     result;
 	u16 refcheck;
+	ssize_t rc2;
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
+	result = ll_do_fast_read(env, iocb, to);
+	if (result < 0 || iov_iter_count(to) == 0)
+		goto out;
+
 	args = ll_env_args(env);
 	args->u.normal.via_iter = to;
 	args->u.normal.via_iocb = iocb;
 
-	result = ll_file_io_generic(env, args, iocb->ki_filp, CIT_READ,
-				    &iocb->ki_pos, iov_iter_count(to));
+	rc2 = ll_file_io_generic(env, args, iocb->ki_filp, CIT_READ,
+				 &iocb->ki_pos, iov_iter_count(to));
+	if (rc2 > 0)
+		result += rc2;
+	else if (result == 0)
+		result = rc2;
+
+out:
 	cl_env_put(env, &refcheck);
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 8770d10..86914c9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -395,6 +395,7 @@ enum stats_track_type {
 #define LL_SBI_ALWAYS_PING	0x200000 /* always ping even if server
 					  * suppress_pings
 					  */
+#define LL_SBI_FAST_READ	0x400000 /* fast read support */
 
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
@@ -419,6 +420,7 @@ enum stats_track_type {
 	"xattr_cache",	\
 	"norootsquash",	\
 	"always_ping",	\
+	"fast_read",    \
 }
 
 /*
@@ -646,6 +648,11 @@ static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
 #endif
 }
 
+static inline bool ll_sbi_has_fast_read(struct ll_sb_info *sbi)
+{
+	return !!(sbi->ll_flags & LL_SBI_FAST_READ);
+}
+
 void ll_ras_enter(struct file *f);
 
 /* llite/lcommon_misc.c */
@@ -678,6 +685,8 @@ enum {
 	LPROC_LL_OPEN,
 	LPROC_LL_RELEASE,
 	LPROC_LL_MAP,
+	LPROC_LL_FAULT,
+	LPROC_LL_MKWRITE,
 	LPROC_LL_LLSEEK,
 	LPROC_LL_FSYNC,
 	LPROC_LL_READDIR,
@@ -732,9 +741,12 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 int ll_readpage(struct file *file, struct page *page);
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
-struct ll_cl_context *ll_cl_find(struct file *file);
-void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io);
+
+enum lcc_type;
+void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
+	       enum lcc_type type);
 void ll_cl_remove(struct file *file, const struct lu_env *env);
+struct ll_cl_context *ll_cl_find(struct file *file);
 
 extern const struct address_space_operations ll_aops;
 
@@ -891,15 +903,22 @@ struct vvp_io_args {
 	} u;
 };
 
+enum lcc_type {
+	LCC_RW = 1,
+	LCC_MMAP
+};
+
 struct ll_cl_context {
 	struct list_head	 lcc_list;
 	void	   *lcc_cookie;
 	const struct lu_env	*lcc_env;
 	struct cl_io   *lcc_io;
 	struct cl_page *lcc_page;
+	enum lcc_type		 lcc_type;
 };
 
 struct ll_thread_info {
+	struct iov_iter		lti_iter;
 	struct vvp_io_args   lti_args;
 	struct ra_io_arg     lti_ria;
 	struct ll_cl_context lti_io_ctx;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 90dff0a..6e47e5b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -122,6 +122,7 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	atomic_set(&sbi->ll_sa_running, 0);
 	atomic_set(&sbi->ll_agl_total, 0);
 	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
+	sbi->ll_flags |= LL_SBI_FAST_READ;
 
 	/* root squash */
 	sbi->ll_squash.rsi_uid = 0;
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 8cb8036..023d62e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -277,6 +277,28 @@ static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 	if (IS_ERR(env))
 		return VM_FAULT_ERROR;
 
+	if (ll_sbi_has_fast_read(ll_i2sbi(file_inode(vma->vm_file)))) {
+		/* do fast fault */
+		ll_cl_add(vma->vm_file, env, NULL, LCC_MMAP);
+		fault_ret = filemap_fault(vmf);
+		ll_cl_remove(vma->vm_file, env);
+
+		/*
+		 * - If there is no error, then the page was found in cache and
+		 *   uptodate;
+		 * - If VM_FAULT_RETRY is set, the page existed but failed to
+		 *   lock. It will return to kernel and retry;
+		 * - Otherwise, it should try normal fault under DLM lock.
+		 */
+		if ((fault_ret & VM_FAULT_RETRY) ||
+		    !(fault_ret & VM_FAULT_ERROR)) {
+			result = 0;
+			goto out;
+		}
+
+		fault_ret = 0;
+	}
+
 	io = ll_fault_io_init(env, vma, vmf->pgoff, &ra_flags);
 	if (IS_ERR(io)) {
 		fault_ret = to_fault_error(PTR_ERR(io));
@@ -293,7 +315,7 @@ static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 		vio->u.fault.ft_flags_valid = false;
 
 		/* May call ll_readpage() */
-		ll_cl_add(vma->vm_file, env, io);
+		ll_cl_add(vma->vm_file, env, io, LCC_MMAP);
 
 		result = cl_io_loop(env, io);
 
@@ -326,6 +348,7 @@ static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static vm_fault_t ll_fault(struct vm_fault *vmf)
 {
+	struct vm_area_struct *vma = vmf->vma;
 	int count = 0;
 	bool printed = false;
 	vm_fault_t result;
@@ -338,10 +361,12 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	siginitsetinv(&new, sigmask(SIGKILL) | sigmask(SIGTERM));
 	sigprocmask(SIG_BLOCK, &new, &old);
 
+	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
+			   LPROC_LL_FAULT, 1);
+
 restart:
 	result = ll_fault0(vmf->vma, vmf);
-	LASSERT(!(result & VM_FAULT_LOCKED));
-	if (result == 0) {
+	if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
 		struct page *vmpage = vmf->page;
 
 		/* check if this page has been truncated */
@@ -375,6 +400,9 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 	int err;
 	vm_fault_t ret;
 
+	ll_stats_ops_tally(ll_i2sbi(file_inode(vma->vm_file)),
+			   LPROC_LL_MKWRITE, 1);
+
 	file_update_time(vma->vm_file);
 	do {
 		retry = false;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 49bf1b7..9dcbe64 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -872,6 +872,41 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(xattr_cache);
 
+static ssize_t fast_read_show(struct kobject *kobj,
+			      struct attribute *attr,
+			      char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+
+	return sprintf(buf, "%u\n", !!(sbi->ll_flags & LL_SBI_FAST_READ));
+}
+
+static ssize_t fast_read_store(struct kobject *kobj,
+			       struct attribute *attr,
+			       const char *buffer,
+			       size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	spin_lock(&sbi->ll_lock);
+	if (val)
+		sbi->ll_flags |= LL_SBI_FAST_READ;
+	else
+		sbi->ll_flags &= ~LL_SBI_FAST_READ;
+	spin_unlock(&sbi->ll_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(fast_read);
+
 static int ll_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
 	struct super_block     *sb    = m->private;
@@ -1032,6 +1067,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	&lustre_attr_max_easize.attr,
 	&lustre_attr_default_easize.attr,
 	&lustre_attr_xattr_cache.attr,
+	&lustre_attr_fast_read.attr,
 	NULL,
 };
 
@@ -1068,6 +1104,8 @@ static void llite_sb_release(struct kobject *kobj)
 	{ LPROC_LL_OPEN,	   LPROCFS_TYPE_REGS, "open" },
 	{ LPROC_LL_RELEASE,	LPROCFS_TYPE_REGS, "close" },
 	{ LPROC_LL_MAP,	    LPROCFS_TYPE_REGS, "mmap" },
+	{ LPROC_LL_FAULT,		LPROCFS_TYPE_REGS, "page_fault" },
+	{ LPROC_LL_MKWRITE,		LPROCFS_TYPE_REGS, "page_mkwrite" },
 	{ LPROC_LL_LLSEEK,	 LPROCFS_TYPE_REGS, "seek" },
 	{ LPROC_LL_FSYNC,	  LPROCFS_TYPE_REGS, "fsync" },
 	{ LPROC_LL_READDIR,	LPROCFS_TYPE_REGS, "readdir" },
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 3e008ce..59747da 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -1067,7 +1067,8 @@ struct ll_cl_context *ll_cl_find(struct file *file)
 	return found;
 }
 
-void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io)
+void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
+	       enum lcc_type type)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_cl_context *lcc = &ll_env_info(env)->lti_io_ctx;
@@ -1077,6 +1078,7 @@ void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io)
 	lcc->lcc_cookie = current;
 	lcc->lcc_env = env;
 	lcc->lcc_io = io;
+	lcc->lcc_type = type;
 
 	write_lock(&fd->fd_lock);
 	list_add(&lcc->lcc_list, &fd->fd_lccs);
@@ -1094,10 +1096,10 @@ void ll_cl_remove(struct file *file, const struct lu_env *env)
 }
 
 static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
-			   struct cl_page *page)
+			   struct cl_page *page, struct file *file)
 {
 	struct inode *inode = vvp_object_inode(page->cp_obj);
-	struct ll_file_data *fd = vvp_env_io(env)->vui_fd;
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_readahead_state *ras = &fd->fd_ras;
 	struct cl_2queue *queue  = &io->ci_queue;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
@@ -1109,7 +1111,8 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	uptodate = vpg->vpg_defer_uptodate;
 
 	if (sbi->ll_ra_info.ra_max_pages_per_file > 0 &&
-	    sbi->ll_ra_info.ra_max_pages > 0) {
+	    sbi->ll_ra_info.ra_max_pages > 0 &&
+	    !vpg->vpg_ra_updated) {
 		struct vvp_io *vio = vvp_env_io(env);
 		enum ras_update_flags flags = 0;
 
@@ -1168,13 +1171,66 @@ int ll_readpage(struct file *file, struct page *vmpage)
 
 	env = lcc->lcc_env;
 	io = lcc->lcc_io;
-	LASSERT(io->ci_state == CIS_IO_GOING);
+	if (!io) { /* fast read */
+		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+		struct ll_readahead_state *ras = &fd->fd_ras;
+		struct inode *inode = file_inode(file);
+		struct vvp_page *vpg;
+
+		result = -ENODATA;
+
+		/*
+		 * TODO: need to verify the layout version to make sure
+		 * the page is not invalid due to layout change.
+		 */
+		page = cl_vmpage_page(vmpage, clob);
+		if (!page) {
+			unlock_page(vmpage);
+			return result;
+		}
+
+		vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
+		if (vpg->vpg_defer_uptodate) {
+			enum ras_update_flags flags = LL_RAS_HIT;
+
+			if (lcc->lcc_type == LCC_MMAP)
+				flags |= LL_RAS_MMAP;
+
+			/*
+			 * For fast read, it updates read ahead state only
+			 * if the page is hit in cache because non cache page
+			 * case will be handled by slow read later.
+			 */
+			ras_update(ll_i2sbi(inode), inode, ras, vvp_index(vpg),
+				   flags);
+			/* avoid duplicate ras_update() call */
+			vpg->vpg_ra_updated = 1;
+
+			/*
+			 * Check if we can issue a readahead RPC, if that is
+			 * the case, we can't do fast IO because we will need
+			 * a cl_io to issue the RPC.
+			 */
+			if (ras->ras_window_start + ras->ras_window_len <
+			    ras->ras_next_readahead + PTLRPC_MAX_BRW_PAGES) {
+				/* export the page and skip io stack */
+				vpg->vpg_ra_used = 1;
+				cl_page_export(env, page, 1);
+				result = 0;
+			}
+		}
+
+		unlock_page(vmpage);
+		cl_page_put(env, page);
+		return result;
+	}
+
 	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
 	if (!IS_ERR(page)) {
 		LASSERT(page->cp_type == CPT_CACHEABLE);
 		if (likely(!PageUptodate(vmpage))) {
 			cl_page_assume(env, io, page);
-			result = ll_io_read_page(env, io, page);
+			result = ll_io_read_page(env, io, page, file);
 		} else {
 			/* Page from a non-object file. */
 			unlock_page(vmpage);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 7d3abb4..70d62bf 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -225,6 +225,7 @@ struct vvp_object {
 struct vvp_page {
 	struct cl_page_slice vpg_cl;
 	unsigned int	vpg_defer_uptodate:1,
+			vpg_ra_updated:1,
 			vpg_ra_used:1;
 	/** VM page */
 	struct page	  *vpg_page;
-- 
1.8.3.1
