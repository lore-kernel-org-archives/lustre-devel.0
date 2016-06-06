From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sun,  5 Jun 2016 23:28:51 -0400
Subject: [lustre-devel] [PATCH 2/4] staging/lustre/llite: define per open
	file cache for ll_cl_context
In-Reply-To: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
References: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465183733-3147667-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <oleg.drokin@intel.com>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In ll_readpage and ll_write_begin, it needs to find out the cl_env
and cl_io, a.k.a ll_cl_context, when the IO is initialized. It used
to call cl_env_get() to figure it out but turned out to be contended
if multiple threads are doing IO.

In this patch, a per open file ll_cl_context cache is created. When
IO type of CIT_READ, CIT_WRITE and CIR_FAULT is initialized, it will
add a ll_cl_context into the cache maintained in ll_file_data. In this
case, the ll_cl_context can be found in ll_readpage and ll_write_begin
later.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/10503
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5108
Reviewed-on: http://review.whamcloud.com/10955
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5260
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/llite/file.c         |   7 +
 .../staging/lustre/lustre/llite/llite_internal.h   |  11 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   5 +
 drivers/staging/lustre/lustre/llite/rw.c           | 145 +++++++++------------
 drivers/staging/lustre/lustre/llite/rw26.c         |  17 +--
 5 files changed, 88 insertions(+), 97 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index f47f2ac..198ee3b 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -519,6 +519,11 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	LUSTRE_FPRIVATE(file) = fd;
 	ll_readahead_init(inode, &fd->fd_ras);
 	fd->fd_omode = it->it_flags & (FMODE_READ | FMODE_WRITE | FMODE_EXEC);
+
+	/* ll_cl_context initialize */
+	rwlock_init(&fd->fd_lock);
+	INIT_LIST_HEAD(&fd->fd_lccs);
+
 	return 0;
 }
 
@@ -1178,7 +1183,9 @@ restart:
 			CERROR("Unknown IO type - %u\n", vio->vui_io_subtype);
 			LBUG();
 		}
+		ll_cl_add(file, env, io);
 		result = cl_io_loop(env, io);
+		ll_cl_remove(file, env);
 		if (args->via_io_subtype == IO_NORMAL)
 			up_read(&lli->lli_trunc_sem);
 		if (write_mutex_locked)
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 3f2f30b..7fb949a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -640,6 +640,8 @@ struct ll_file_data {
 	 * false: unknown failure, should report.
 	 */
 	bool fd_write_failed;
+	rwlock_t fd_lock; /* protect lcc list */
+	struct list_head fd_lccs; /* list of ll_cl_context */
 };
 
 struct lov_stripe_md;
@@ -715,8 +717,9 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		 struct cl_page_list *queue, struct ll_readahead_state *ras,
 		 bool hit);
-struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage);
-void ll_cl_fini(struct ll_cl_context *lcc);
+struct ll_cl_context *ll_cl_find(struct file *file);
+void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io);
+void ll_cl_remove(struct file *file, const struct lu_env *env);
 
 extern const struct address_space_operations ll_aops;
 
@@ -858,11 +861,11 @@ struct vvp_io_args {
 };
 
 struct ll_cl_context {
+	struct list_head	 lcc_list;
 	void	   *lcc_cookie;
+	const struct lu_env	*lcc_env;
 	struct cl_io   *lcc_io;
 	struct cl_page *lcc_page;
-	struct lu_env  *lcc_env;
-	int	     lcc_refcheck;
 };
 
 struct ll_thread_info {
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 88ef1ca..7610799 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -315,8 +315,13 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 		vio->u.fault.ft_flags = 0;
 		vio->u.fault.ft_flags_valid = false;
 
+		/* May call ll_readpage() */
+		ll_cl_add(vma->vm_file, env, io);
+
 		result = cl_io_loop(env, io);
 
+		ll_cl_remove(vma->vm_file, env);
+
 		/* ft_flags are only valid if we reached
 		 * the call to filemap_fault
 		 */
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 3363977..fa42869 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -59,84 +59,6 @@
 #include "llite_internal.h"
 #include "../include/linux/lustre_compat25.h"
 
-/**
- * Finalizes cl-data before exiting typical address_space operation. Dual to
- * ll_cl_init().
- */
-void ll_cl_fini(struct ll_cl_context *lcc)
-{
-	struct lu_env  *env  = lcc->lcc_env;
-	struct cl_io   *io   = lcc->lcc_io;
-	struct cl_page *page = lcc->lcc_page;
-
-	LASSERT(lcc->lcc_cookie == current);
-	LASSERT(env);
-
-	if (page) {
-		lu_ref_del(&page->cp_reference, "cl_io", io);
-		cl_page_put(env, page);
-	}
-
-	cl_env_put(env, &lcc->lcc_refcheck);
-}
-
-/**
- * Initializes common cl-data at the typical address_space operation entry
- * point.
- */
-struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
-{
-	struct ll_cl_context *lcc;
-	struct lu_env    *env;
-	struct cl_io     *io;
-	struct cl_object *clob;
-	struct vvp_io    *vio;
-
-	int refcheck;
-	int result = 0;
-
-	clob = ll_i2info(file_inode(file))->lli_clob;
-	LASSERT(clob);
-
-	env = cl_env_get(&refcheck);
-	if (IS_ERR(env))
-		return ERR_CAST(env);
-
-	lcc = &ll_env_info(env)->lti_io_ctx;
-	memset(lcc, 0, sizeof(*lcc));
-	lcc->lcc_env = env;
-	lcc->lcc_refcheck = refcheck;
-	lcc->lcc_cookie = current;
-
-	vio = vvp_env_io(env);
-	io = vio->vui_cl.cis_io;
-	lcc->lcc_io = io;
-	if (!io)
-		result = -EIO;
-
-	if (result == 0 && vmpage) {
-		struct cl_page   *page;
-
-		LASSERT(io->ci_state == CIS_IO_GOING);
-		LASSERT(vio->vui_fd == LUSTRE_FPRIVATE(file));
-		page = cl_page_find(env, clob, vmpage->index, vmpage,
-				    CPT_CACHEABLE);
-		if (!IS_ERR(page)) {
-			lcc->lcc_page = page;
-			lu_ref_add(&page->cp_reference, "cl_io", io);
-			result = 0;
-		} else {
-			result = PTR_ERR(page);
-		}
-	}
-	if (result) {
-		ll_cl_fini(lcc);
-		lcc = ERR_PTR(result);
-	}
-
-	return lcc;
-}
-
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
 
 /**
@@ -1112,17 +1034,70 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 	return result;
 }
 
+struct ll_cl_context *ll_cl_find(struct file *file)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_cl_context *lcc;
+	struct ll_cl_context *found = NULL;
+
+	read_lock(&fd->fd_lock);
+	list_for_each_entry(lcc, &fd->fd_lccs, lcc_list) {
+		if (lcc->lcc_cookie == current) {
+			found = lcc;
+			break;
+		}
+	}
+	read_unlock(&fd->fd_lock);
+
+	return found;
+}
+
+void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_cl_context *lcc = &ll_env_info(env)->lti_io_ctx;
+
+	memset(lcc, 0, sizeof(*lcc));
+	INIT_LIST_HEAD(&lcc->lcc_list);
+	lcc->lcc_cookie = current;
+	lcc->lcc_env = env;
+	lcc->lcc_io = io;
+
+	write_lock(&fd->fd_lock);
+	list_add(&lcc->lcc_list, &fd->fd_lccs);
+	write_unlock(&fd->fd_lock);
+}
+
+void ll_cl_remove(struct file *file, const struct lu_env *env)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+	struct ll_cl_context *lcc = &ll_env_info(env)->lti_io_ctx;
+
+	write_lock(&fd->fd_lock);
+	list_del_init(&lcc->lcc_list);
+	write_unlock(&fd->fd_lock);
+}
+
 int ll_readpage(struct file *file, struct page *vmpage)
 {
+	struct cl_object *clob = ll_i2info(file_inode(file))->lli_clob;
 	struct ll_cl_context *lcc;
+	const struct lu_env  *env;
+	struct cl_io   *io;
+	struct cl_page *page;
 	int result;
 
-	lcc = ll_cl_init(file, vmpage);
-	if (!IS_ERR(lcc)) {
-		struct lu_env  *env  = lcc->lcc_env;
-		struct cl_io   *io   = lcc->lcc_io;
-		struct cl_page *page = lcc->lcc_page;
+	lcc = ll_cl_find(file);
+	if (!lcc) {
+		unlock_page(vmpage);
+		return -EIO;
+	}
 
+	env = lcc->lcc_env;
+	io = lcc->lcc_io;
+	LASSERT(io->ci_state == CIS_IO_GOING);
+	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
+	if (!IS_ERR(page)) {
 		LASSERT(page->cp_type == CPT_CACHEABLE);
 		if (likely(!PageUptodate(vmpage))) {
 			cl_page_assume(env, io, page);
@@ -1132,10 +1107,10 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			unlock_page(vmpage);
 			result = 0;
 		}
-		ll_cl_fini(lcc);
+		cl_page_put(env, page);
 	} else {
 		unlock_page(vmpage);
-		result = PTR_ERR(lcc);
+		result = PTR_ERR(page);
 	}
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index c12a048..947a4f5 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -489,7 +489,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			  struct page **pagep, void **fsdata)
 {
 	struct ll_cl_context *lcc;
-	struct lu_env  *env;
+	const struct lu_env  *env;
 	struct cl_io   *io;
 	struct cl_page *page;
 	struct cl_object *clob = ll_i2info(mapping->host)->lli_clob;
@@ -501,9 +501,9 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 
 	CDEBUG(D_VFSTRACE, "Writing %lu of %d to %d bytes\n", index, from, len);
 
-	lcc = ll_cl_init(file, NULL);
-	if (IS_ERR(lcc)) {
-		result = PTR_ERR(lcc);
+	lcc = ll_cl_find(file);
+	if (!lcc) {
+		result = -EIO;
 		goto out;
 	}
 
@@ -579,8 +579,6 @@ out:
 			unlock_page(vmpage);
 			put_page(vmpage);
 		}
-		if (!IS_ERR(lcc))
-			ll_cl_fini(lcc);
 	} else {
 		*pagep = vmpage;
 		*fsdata = lcc;
@@ -593,7 +591,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 			struct page *vmpage, void *fsdata)
 {
 	struct ll_cl_context *lcc = fsdata;
-	struct lu_env *env;
+	const struct lu_env *env;
 	struct cl_io *io;
 	struct vvp_io *vio;
 	struct cl_page *page;
@@ -631,6 +629,10 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	} else {
 		cl_page_disown(env, io, page);
 
+		lcc->lcc_page = NULL;
+		lu_ref_del(&page->cp_reference, "cl_io", io);
+		cl_page_put(env, page);
+
 		/* page list is not contiguous now, commit it now */
 		unplug = true;
 	}
@@ -639,7 +641,6 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	    file->f_flags & O_SYNC || IS_SYNC(file_inode(file)))
 		result = vvp_io_write_commit(env, io);
 
-	ll_cl_fini(lcc);
 	return result >= 0 ? copied : result;
 }
 
-- 
2.7.4
