From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:41 -0400
Subject: [lustre-devel] [PATCH 09/43] staging/lustre/clio: add pages into
	writeback cache in batches
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

in ll_write_end(), instead of adding the page into writeback
cache directly, it will be held in a page list. After enough
pages have been collected, issue them all with cio_commit_async().

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7893
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  77 ++--
 drivers/staging/lustre/lustre/include/lclient.h    |   6 +
 drivers/staging/lustre/lustre/llite/file.c         |  11 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   8 +-
 drivers/staging/lustre/lustre/llite/rw.c           | 186 ++------
 drivers/staging/lustre/lustre/llite/rw26.c         | 210 +++++++--
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  10 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 490 +++++++++++----------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   2 +
 drivers/staging/lustre/lustre/lov/lov_io.c         | 219 ++++-----
 drivers/staging/lustre/lustre/lov/lov_page.c       |  28 --
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 108 ++---
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  38 --
 .../staging/lustre/lustre/obdecho/echo_client.c    |  25 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  14 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   2 +
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   6 +
 drivers/staging/lustre/lustre/osc/osc_io.c         | 160 ++++---
 drivers/staging/lustre/lustre/osc/osc_page.c       |  32 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  56 ++-
 20 files changed, 792 insertions(+), 896 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index e8455dc..c3865ec 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1019,26 +1019,6 @@ struct cl_page_operations {
 		 */
 		int  (*cpo_make_ready)(const struct lu_env *env,
 				       const struct cl_page_slice *slice);
-		/**
-		 * Announce that this page is to be written out
-		 * opportunistically, that is, page is dirty, it is not
-		 * necessary to start write-out transfer right now, but
-		 * eventually page has to be written out.
-		 *
-		 * Main caller of this is the write path (see
-		 * vvp_io_commit_write()), using this method to build a
-		 * "transfer cache" from which large transfers are then
-		 * constructed by the req-formation engine.
-		 *
-		 * \todo XXX it would make sense to add page-age tracking
-		 * semantics here, and to oblige the req-formation engine to
-		 * send the page out not later than it is too old.
-		 *
-		 * \see cl_page_cache_add()
-		 */
-		int  (*cpo_cache_add)(const struct lu_env *env,
-				      const struct cl_page_slice *slice,
-				      struct cl_io *io);
 	} io[CRT_NR];
 	/**
 	 * Tell transfer engine that only [to, from] part of a page should be
@@ -2023,6 +2003,8 @@ struct cl_io_slice {
 	struct list_head		     cis_linkage;
 };
 
+typedef void (*cl_commit_cbt)(const struct lu_env *, struct cl_io *,
+			      struct cl_page *);
 /**
  * Per-layer io operations.
  * \see vvp_io_ops, lov_io_ops, lovsub_io_ops, osc_io_ops
@@ -2106,7 +2088,7 @@ struct cl_io_operations {
 		void (*cio_fini)(const struct lu_env *env,
 				 const struct cl_io_slice *slice);
 	} op[CIT_OP_NR];
-	struct {
+
 		/**
 		 * Submit pages from \a queue->c2_qin for IO, and move
 		 * successfully submitted pages into \a queue->c2_qout. Return
@@ -2119,7 +2101,15 @@ struct cl_io_operations {
 				   const struct cl_io_slice *slice,
 				   enum cl_req_type crt,
 				   struct cl_2queue *queue);
-	} req_op[CRT_NR];
+	/**
+	 * Queue async page for write.
+	 * The difference between cio_submit and cio_queue is that
+	 * cio_submit is for urgent request.
+	 */
+	int  (*cio_commit_async)(const struct lu_env *env,
+				 const struct cl_io_slice *slice,
+				 struct cl_page_list *queue, int from, int to,
+				 cl_commit_cbt cb);
 	/**
 	 * Read missing page.
 	 *
@@ -2132,31 +2122,6 @@ struct cl_io_operations {
 			     const struct cl_io_slice *slice,
 			     const struct cl_page_slice *page);
 	/**
-	 * Prepare write of a \a page. Called bottom-to-top by a top-level
-	 * cl_io_operations::op[CIT_WRITE]::cio_start() to prepare page for
-	 * get data from user-level buffer.
-	 *
-	 * \pre io->ci_type == CIT_WRITE
-	 *
-	 * \see vvp_io_prepare_write(), lov_io_prepare_write(),
-	 * osc_io_prepare_write().
-	 */
-	int (*cio_prepare_write)(const struct lu_env *env,
-				 const struct cl_io_slice *slice,
-				 const struct cl_page_slice *page,
-				 unsigned from, unsigned to);
-	/**
-	 *
-	 * \pre io->ci_type == CIT_WRITE
-	 *
-	 * \see vvp_io_commit_write(), lov_io_commit_write(),
-	 * osc_io_commit_write().
-	 */
-	int (*cio_commit_write)(const struct lu_env *env,
-				const struct cl_io_slice *slice,
-				const struct cl_page_slice *page,
-				unsigned from, unsigned to);
-	/**
 	 * Optional debugging helper. Print given io slice.
 	 */
 	int (*cio_print)(const struct lu_env *env, void *cookie,
@@ -3044,15 +3009,14 @@ int cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
 			 struct cl_lock_descr *descr);
 int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
 		    struct cl_page *page);
-int cl_io_prepare_write(const struct lu_env *env, struct cl_io *io,
-			struct cl_page *page, unsigned from, unsigned to);
-int cl_io_commit_write(const struct lu_env *env, struct cl_io *io,
-		       struct cl_page *page, unsigned from, unsigned to);
 int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
 		    enum cl_req_type iot, struct cl_2queue *queue);
 int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 		      enum cl_req_type iot, struct cl_2queue *queue,
 		      long timeout);
+int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
+		       struct cl_page_list *queue, int from, int to,
+		       cl_commit_cbt cb);
 int cl_io_is_going(const struct lu_env *env);
 
 /**
@@ -3108,6 +3072,12 @@ static inline struct cl_page *cl_page_list_last(struct cl_page_list *plist)
 	return list_entry(plist->pl_pages.prev, struct cl_page, cp_batch);
 }
 
+static inline struct cl_page *cl_page_list_first(struct cl_page_list *plist)
+{
+	LASSERT(plist->pl_nr > 0);
+	return list_entry(plist->pl_pages.next, struct cl_page, cp_batch);
+}
+
 /**
  * Iterate over pages in a page list.
  */
@@ -3124,9 +3094,14 @@ void cl_page_list_init(struct cl_page_list *plist);
 void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page);
 void cl_page_list_move(struct cl_page_list *dst, struct cl_page_list *src,
 		       struct cl_page *page);
+void cl_page_list_move_head(struct cl_page_list *dst, struct cl_page_list *src,
+			    struct cl_page *page);
 void cl_page_list_splice(struct cl_page_list *list, struct cl_page_list *head);
+void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
+		      struct cl_page *page);
 void cl_page_list_disown(const struct lu_env *env,
 			 struct cl_io *io, struct cl_page_list *plist);
+void cl_page_list_fini(const struct lu_env *env, struct cl_page_list *plist);
 
 void cl_2queue_init(struct cl_2queue *queue);
 void cl_2queue_disown(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index 5d839a9..6c3a30a 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -91,6 +91,12 @@ struct ccc_io {
 		struct {
 			enum ccc_setattr_lock_type cui_local_lock;
 		} setattr;
+		struct {
+			struct cl_page_list cui_queue;
+			unsigned long cui_written;
+			int cui_from;
+			int cui_to;
+		} write;
 	} u;
 	/**
 	 * True iff io is processing glimpse right now.
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index cf619af..127fff6 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1120,6 +1120,9 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 	struct cl_io	 *io;
 	ssize_t	       result;
 
+	CDEBUG(D_VFSTRACE, "file: %s, type: %d ppos: %llu, count: %zd\n",
+	       file->f_path.dentry->d_name.name, iot, *ppos, count);
+
 restart:
 	io = ccc_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE);
@@ -1144,9 +1147,8 @@ restart:
 					goto out;
 				}
 				write_mutex_locked = 1;
-			} else if (iot == CIT_READ) {
-				down_read(&lli->lli_trunc_sem);
 			}
+			down_read(&lli->lli_trunc_sem);
 			break;
 		case IO_SPLICE:
 			vio->u.splice.cui_pipe = args->u.splice.via_pipe;
@@ -1157,10 +1159,10 @@ restart:
 			LBUG();
 		}
 		result = cl_io_loop(env, io);
+		if (args->via_io_subtype == IO_NORMAL)
+			up_read(&lli->lli_trunc_sem);
 		if (write_mutex_locked)
 			mutex_unlock(&lli->lli_write_mutex);
-		else if (args->via_io_subtype == IO_NORMAL && iot == CIT_READ)
-			up_read(&lli->lli_trunc_sem);
 	} else {
 		/* cl_io_rw_init() handled IO */
 		result = io->ci_result;
@@ -1197,6 +1199,7 @@ out:
 			fd->fd_write_failed = true;
 		}
 	}
+	CDEBUG(D_VFSTRACE, "iot: %d, result: %zd\n", iot, result);
 
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 3e1572c..08fe0ea 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -697,8 +697,6 @@ int ll_md_blocking_ast(struct ldlm_lock *, struct ldlm_lock_desc *,
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de);
 
 /* llite/rw.c */
-int ll_prepare_write(struct file *, struct page *, unsigned from, unsigned to);
-int ll_commit_write(struct file *, struct page *, unsigned from, unsigned to);
 int ll_writepage(struct page *page, struct writeback_control *wbc);
 int ll_writepages(struct address_space *, struct writeback_control *wbc);
 int ll_readpage(struct file *file, struct page *page);
@@ -706,6 +704,9 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		 struct ll_readahead_state *ras, struct address_space *mapping,
 		 struct cl_page_list *queue, int flags);
+int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
+struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage);
+void ll_cl_fini(struct ll_cl_context *lcc);
 
 extern const struct address_space_operations ll_aops;
 
@@ -1476,4 +1477,7 @@ int ll_layout_restore(struct inode *inode);
 int ll_xattr_init(void);
 void ll_xattr_fini(void);
 
+int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
+		    struct cl_page *page, enum cl_req_type crt);
+
 #endif /* LLITE_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 01b8365..dcccdec 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -63,7 +63,7 @@
  * Finalizes cl-data before exiting typical address_space operation. Dual to
  * ll_cl_init().
  */
-static void ll_cl_fini(struct ll_cl_context *lcc)
+void ll_cl_fini(struct ll_cl_context *lcc)
 {
 	struct lu_env  *env  = lcc->lcc_env;
 	struct cl_io   *io   = lcc->lcc_io;
@@ -84,8 +84,7 @@ static void ll_cl_fini(struct ll_cl_context *lcc)
  * Initializes common cl-data at the typical address_space operation entry
  * point.
  */
-static struct ll_cl_context *ll_cl_init(struct file *file,
-					struct page *vmpage, int create)
+struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 {
 	struct ll_cl_context *lcc;
 	struct lu_env    *env;
@@ -96,7 +95,7 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 	int refcheck;
 	int result = 0;
 
-	clob = ll_i2info(vmpage->mapping->host)->lli_clob;
+	clob = ll_i2info(file_inode(file))->lli_clob;
 	LASSERT(clob);
 
 	env = cl_env_get(&refcheck);
@@ -111,62 +110,18 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 
 	cio = ccc_env_io(env);
 	io = cio->cui_cl.cis_io;
-	if (!io && create) {
-		struct inode *inode = vmpage->mapping->host;
-		loff_t pos;
+	lcc->lcc_io = io;
+	if (!io) {
+		struct inode *inode = file_inode(file);
 
-		if (inode_trylock(inode)) {
-			inode_unlock((inode));
+		CERROR("%s: " DFID " no active IO, please file a ticket.\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)));
+		dump_stack();
 
-			/* this is too bad. Someone is trying to write the
-			 * page w/o holding inode mutex. This means we can
-			 * add dirty pages into cache during truncate
-			 */
-			CERROR("Proc %s is dirtying page w/o inode lock, this will break truncate\n",
-			       current->comm);
-			dump_stack();
-			LBUG();
-			return ERR_PTR(-EIO);
-		}
-
-		/*
-		 * Loop-back driver calls ->prepare_write().
-		 * methods directly, bypassing file system ->write() operation,
-		 * so cl_io has to be created here.
-		 */
-		io = ccc_env_thread_io(env);
-		ll_io_init(io, file, 1);
-
-		/* No lock at all for this kind of IO - we can't do it because
-		 * we have held page lock, it would cause deadlock.
-		 * XXX: This causes poor performance to loop device - One page
-		 *      per RPC.
-		 *      In order to get better performance, users should use
-		 *      lloop driver instead.
-		 */
-		io->ci_lockreq = CILR_NEVER;
-
-		pos = vmpage->index << PAGE_CACHE_SHIFT;
-
-		/* Create a temp IO to serve write. */
-		result = cl_io_rw_init(env, io, CIT_WRITE, pos, PAGE_CACHE_SIZE);
-		if (result == 0) {
-			cio->cui_fd = LUSTRE_FPRIVATE(file);
-			cio->cui_iter = NULL;
-			result = cl_io_iter_init(env, io);
-			if (result == 0) {
-				result = cl_io_lock(env, io);
-				if (result == 0)
-					result = cl_io_start(env, io);
-			}
-		} else
-			result = io->ci_result;
-	}
-
-	lcc->lcc_io = io;
-	if (!io)
 		result = -EIO;
-	if (result == 0) {
+	}
+	if (result == 0 && vmpage) {
 		struct cl_page   *page;
 
 		LASSERT(io->ci_state == CIS_IO_GOING);
@@ -185,99 +140,9 @@ static struct ll_cl_context *ll_cl_init(struct file *file,
 		lcc = ERR_PTR(result);
 	}
 
-	CDEBUG(D_VFSTRACE, "%lu@"DFID" -> %d %p %p\n",
-	       vmpage->index, PFID(lu_object_fid(&clob->co_lu)), result,
-	       env, io);
 	return lcc;
 }
 
-static struct ll_cl_context *ll_cl_get(void)
-{
-	struct ll_cl_context *lcc;
-	struct lu_env *env;
-	int refcheck;
-
-	env = cl_env_get(&refcheck);
-	LASSERT(!IS_ERR(env));
-	lcc = &vvp_env_info(env)->vti_io_ctx;
-	LASSERT(env == lcc->lcc_env);
-	LASSERT(current == lcc->lcc_cookie);
-	cl_env_put(env, &refcheck);
-
-	/* env has got in ll_cl_init, so it is still usable. */
-	return lcc;
-}
-
-/**
- * ->prepare_write() address space operation called by generic_file_write()
- * for every page during write.
- */
-int ll_prepare_write(struct file *file, struct page *vmpage, unsigned from,
-		     unsigned to)
-{
-	struct ll_cl_context *lcc;
-	int result;
-
-	lcc = ll_cl_init(file, vmpage, 1);
-	if (!IS_ERR(lcc)) {
-		struct lu_env  *env = lcc->lcc_env;
-		struct cl_io   *io  = lcc->lcc_io;
-		struct cl_page *page = lcc->lcc_page;
-
-		cl_page_assume(env, io, page);
-
-		result = cl_io_prepare_write(env, io, page, from, to);
-		if (result == 0) {
-			/*
-			 * Add a reference, so that page is not evicted from
-			 * the cache until ->commit_write() is called.
-			 */
-			cl_page_get(page);
-			lu_ref_add(&page->cp_reference, "prepare_write",
-				   current);
-		} else {
-			cl_page_unassume(env, io, page);
-			ll_cl_fini(lcc);
-		}
-		/* returning 0 in prepare assumes commit must be called
-		 * afterwards
-		 */
-	} else {
-		result = PTR_ERR(lcc);
-	}
-	return result;
-}
-
-int ll_commit_write(struct file *file, struct page *vmpage, unsigned from,
-		    unsigned to)
-{
-	struct ll_cl_context *lcc;
-	struct lu_env    *env;
-	struct cl_io     *io;
-	struct cl_page   *page;
-	int result = 0;
-
-	lcc  = ll_cl_get();
-	env  = lcc->lcc_env;
-	page = lcc->lcc_page;
-	io   = lcc->lcc_io;
-
-	LASSERT(cl_page_is_owned(page, io));
-	LASSERT(from <= to);
-	if (from != to) /* handle short write case. */
-		result = cl_io_commit_write(env, io, page, from, to);
-	if (cl_page_is_owned(page, io))
-		cl_page_unassume(env, io, page);
-
-	/*
-	 * Release reference acquired by ll_prepare_write().
-	 */
-	lu_ref_del(&page->cp_reference, "prepare_write", current);
-	cl_page_put(env, page);
-	ll_cl_fini(lcc);
-	return result;
-}
-
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
 
 /**
@@ -1251,7 +1116,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	struct ll_cl_context *lcc;
 	int result;
 
-	lcc = ll_cl_init(file, vmpage, 0);
+	lcc = ll_cl_init(file, vmpage);
 	if (!IS_ERR(lcc)) {
 		struct lu_env  *env  = lcc->lcc_env;
 		struct cl_io   *io   = lcc->lcc_io;
@@ -1273,3 +1138,28 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	}
 	return result;
 }
+
+int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
+		    struct cl_page *page, enum cl_req_type crt)
+{
+	struct cl_2queue  *queue;
+	int result;
+
+	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
+
+	queue = &io->ci_queue;
+	cl_2queue_init_page(queue, page);
+
+	result = cl_io_submit_sync(env, io, crt, queue, 0);
+	LASSERT(cl_page_is_owned(page, io));
+
+	if (crt == CRT_READ)
+		/*
+		 * in CRT_WRITE case page is left locked even in case of
+		 * error.
+		 */
+		cl_page_list_disown(env, io, &queue->c2_qin);
+	cl_2queue_fini(env, queue);
+
+	return result;
+}
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index cc49c21..e8d29e1 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -462,57 +462,211 @@ out:
 		inode_unlock(inode);
 
 	if (tot_bytes > 0) {
-		if (iov_iter_rw(iter) == WRITE) {
-			struct lov_stripe_md *lsm;
-
-			lsm = ccc_inode_lsm_get(inode);
-			LASSERT(lsm);
-			lov_stripe_lock(lsm);
-			obd_adjust_kms(ll_i2dtexp(inode), lsm, file_offset, 0);
-			lov_stripe_unlock(lsm);
-			ccc_inode_lsm_put(inode, lsm);
-		}
+		struct ccc_io *cio = ccc_env_io(env);
+
+		/* no commit async for direct IO */
+		cio->u.write.cui_written += tot_bytes;
 	}
 
 	cl_env_put(env, &refcheck);
 	return tot_bytes ? : result;
 }
 
+/**
+ * Prepare partially written-to page for a write.
+ */
+static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
+				   struct cl_page *pg)
+{
+	struct cl_object *obj  = io->ci_obj;
+	struct cl_attr *attr   = ccc_env_thread_attr(env);
+	loff_t          offset = cl_offset(obj, pg->cp_index);
+	int             result;
+
+	cl_object_attr_lock(obj);
+	result = cl_object_attr_get(env, obj, attr);
+	cl_object_attr_unlock(obj);
+	if (result == 0) {
+		struct ccc_page *cp;
+
+		cp = cl2ccc_page(cl_page_at(pg, &vvp_device_type));
+
+		/*
+		 * If are writing to a new page, no need to read old data.
+		 * The extent locking will have updated the KMS, and for our
+		 * purposes here we can treat it like i_size.
+		 */
+		if (attr->cat_kms <= offset) {
+			char *kaddr = kmap_atomic(cp->cpg_page);
+
+			memset(kaddr, 0, cl_page_size(obj));
+			kunmap_atomic(kaddr);
+		} else if (cp->cpg_defer_uptodate) {
+			cp->cpg_ra_used = 1;
+		} else {
+			result = ll_page_sync_io(env, io, pg, CRT_READ);
+		}
+	}
+	return result;
+}
+
 static int ll_write_begin(struct file *file, struct address_space *mapping,
 			  loff_t pos, unsigned len, unsigned flags,
 			  struct page **pagep, void **fsdata)
 {
+	struct ll_cl_context *lcc;
+	struct lu_env  *env;
+	struct cl_io   *io;
+	struct cl_page *page;
+	struct cl_object *clob = ll_i2info(mapping->host)->lli_clob;
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	struct page *page;
-	int rc;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	struct page *vmpage = NULL;
+	unsigned int from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned int to = from + len;
+	int result = 0;
 
-	page = grab_cache_page_write_begin(mapping, index, flags);
-	if (!page)
-		return -ENOMEM;
+	CDEBUG(D_VFSTRACE, "Writing %lu of %d to %d bytes\n", index, from, len);
+
+	lcc = ll_cl_init(file, NULL);
+	if (IS_ERR(lcc)) {
+		result = PTR_ERR(lcc);
+		goto out;
+	}
+
+	env = lcc->lcc_env;
+	io  = lcc->lcc_io;
+
+	/* To avoid deadlock, try to lock page first. */
+	vmpage = grab_cache_page_nowait(mapping, index);
+	if (unlikely(!vmpage || PageDirty(vmpage))) {
+		struct ccc_io *cio = ccc_env_io(env);
+		struct cl_page_list *plist = &cio->u.write.cui_queue;
+
+		/* if the page is already in dirty cache, we have to commit
+		 * the pages right now; otherwise, it may cause deadlock
+		 * because it holds page lock of a dirty page and request for
+		 * more grants. It's okay for the dirty page to be the first
+		 * one in commit page list, though.
+		 */
+		if (vmpage && PageDirty(vmpage) && plist->pl_nr > 0) {
+			unlock_page(vmpage);
+			page_cache_release(vmpage);
+			vmpage = NULL;
+		}
 
-	*pagep = page;
+		/* commit pages and then wait for page lock */
+		result = vvp_io_write_commit(env, io);
+		if (result < 0)
+			goto out;
 
-	rc = ll_prepare_write(file, page, from, from + len);
-	if (rc) {
-		unlock_page(page);
-		page_cache_release(page);
+		if (!vmpage) {
+			vmpage = grab_cache_page_write_begin(mapping, index,
+							     flags);
+			if (!vmpage) {
+				result = -ENOMEM;
+				goto out;
+			}
+		}
 	}
-	return rc;
+
+	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
+	if (IS_ERR(page)) {
+		result = PTR_ERR(page);
+		goto out;
+	}
+
+	lcc->lcc_page = page;
+	lu_ref_add(&page->cp_reference, "cl_io", io);
+
+	cl_page_assume(env, io, page);
+	if (!PageUptodate(vmpage)) {
+		/*
+		 * We're completely overwriting an existing page,
+		 * so _don't_ set it up to date until commit_write
+		 */
+		if (from == 0 && to == PAGE_SIZE) {
+			CL_PAGE_HEADER(D_PAGE, env, page, "full page write\n");
+			POISON_PAGE(vmpage, 0x11);
+		} else {
+			/* TODO: can be optimized at OSC layer to check if it
+			 * is a lockless IO. In that case, it's not necessary
+			 * to read the data.
+			 */
+			result = ll_prepare_partial_page(env, io, page);
+			if (result == 0)
+				SetPageUptodate(vmpage);
+		}
+	}
+	if (result < 0)
+		cl_page_unassume(env, io, page);
+out:
+	if (result < 0) {
+		if (vmpage) {
+			unlock_page(vmpage);
+			page_cache_release(vmpage);
+		}
+		if (!IS_ERR(lcc))
+			ll_cl_fini(lcc);
+	} else {
+		*pagep = vmpage;
+		*fsdata = lcc;
+	}
+	return result;
 }
 
 static int ll_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
-			struct page *page, void *fsdata)
+			struct page *vmpage, void *fsdata)
 {
+	struct ll_cl_context *lcc = fsdata;
+	struct lu_env *env;
+	struct cl_io *io;
+	struct ccc_io *cio;
+	struct cl_page *page;
 	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
-	int rc;
+	bool unplug = false;
+	int result = 0;
+
+	page_cache_release(vmpage);
+
+	env  = lcc->lcc_env;
+	page = lcc->lcc_page;
+	io   = lcc->lcc_io;
+	cio  = ccc_env_io(env);
+
+	LASSERT(cl_page_is_owned(page, io));
+	if (copied > 0) {
+		struct cl_page_list *plist = &cio->u.write.cui_queue;
+
+		lcc->lcc_page = NULL; /* page will be queued */
+
+		/* Add it into write queue */
+		cl_page_list_add(plist, page);
+		if (plist->pl_nr == 1) /* first page */
+			cio->u.write.cui_from = from;
+		else
+			LASSERT(from == 0);
+		cio->u.write.cui_to = from + copied;
+
+		/* We may have one full RPC, commit it soon */
+		if (plist->pl_nr >= PTLRPC_MAX_BRW_PAGES)
+			unplug = true;
+
+		CL_PAGE_DEBUG(D_VFSTRACE, env, page,
+			      "queued page: %d.\n", plist->pl_nr);
+	} else {
+		cl_page_disown(env, io, page);
+
+		/* page list is not contiguous now, commit it now */
+		unplug = true;
+	}
 
-	rc = ll_commit_write(file, page, from, from + copied);
-	unlock_page(page);
-	page_cache_release(page);
+	if (unplug ||
+	    file->f_flags & O_SYNC || IS_SYNC(file_inode(file)))
+		result = vvp_io_write_commit(env, io);
 
-	return rc ?: copied;
+	ll_cl_fini(lcc);
+	return result >= 0 ? copied : result;
 }
 
 #ifdef CONFIG_MIGRATION
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index bb39337..9abde11 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -44,17 +44,15 @@
 #include "../include/cl_object.h"
 #include "llite_internal.h"
 
-int vvp_io_init(const struct lu_env *env,
-		struct cl_object *obj, struct cl_io *io);
-int vvp_lock_init(const struct lu_env *env,
-		  struct cl_object *obj, struct cl_lock *lock,
-				   const struct cl_io *io);
+int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
+		struct cl_io *io);
+int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
+		  struct cl_lock *lock, const struct cl_io *io);
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_page *page, struct page *vmpage);
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
-
 struct ccc_object *cl_inode2ccc(struct inode *inode);
 
 extern const struct file_operations vvp_dump_pgcache_file_ops;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index ffe301b..f4a1384 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -101,6 +101,27 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
  *
  */
 
+static int vvp_io_write_iter_init(const struct lu_env *env,
+				  const struct cl_io_slice *ios)
+{
+	struct ccc_io *cio = cl2ccc_io(env, ios);
+
+	cl_page_list_init(&cio->u.write.cui_queue);
+	cio->u.write.cui_written = 0;
+	cio->u.write.cui_from = 0;
+	cio->u.write.cui_to = PAGE_SIZE;
+
+	return 0;
+}
+
+static void vvp_io_write_iter_fini(const struct lu_env *env,
+				   const struct cl_io_slice *ios)
+{
+	struct ccc_io *cio = cl2ccc_io(env, ios);
+
+	LASSERT(cio->u.write.cui_queue.pl_nr == 0);
+}
+
 static int vvp_io_fault_iter_init(const struct lu_env *env,
 				  const struct cl_io_slice *ios)
 {
@@ -563,6 +584,183 @@ static void vvp_io_read_fini(const struct lu_env *env, const struct cl_io_slice
 	vvp_io_fini(env, ios);
 }
 
+static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
+			      struct cl_page_list *plist, int from, int to)
+{
+	struct cl_2queue *queue = &io->ci_queue;
+	struct cl_page *page;
+	unsigned int bytes = 0;
+	int rc = 0;
+
+	if (plist->pl_nr == 0)
+		return 0;
+
+	if (from != 0) {
+		page = cl_page_list_first(plist);
+		cl_page_clip(env, page, from,
+			     plist->pl_nr == 1 ? to : PAGE_SIZE);
+	}
+	if (to != PAGE_SIZE && plist->pl_nr > 1) {
+		page = cl_page_list_last(plist);
+		cl_page_clip(env, page, 0, to);
+	}
+
+	cl_2queue_init(queue);
+	cl_page_list_splice(plist, &queue->c2_qin);
+	rc = cl_io_submit_sync(env, io, CRT_WRITE, queue, 0);
+
+	/* plist is not sorted any more */
+	cl_page_list_splice(&queue->c2_qin, plist);
+	cl_page_list_splice(&queue->c2_qout, plist);
+	cl_2queue_fini(env, queue);
+
+	if (rc == 0) {
+		/* calculate bytes */
+		bytes = plist->pl_nr << PAGE_SHIFT;
+		bytes -= from + PAGE_SIZE - to;
+
+		while (plist->pl_nr > 0) {
+			page = cl_page_list_first(plist);
+			cl_page_list_del(env, plist, page);
+
+			cl_page_clip(env, page, 0, PAGE_SIZE);
+
+			SetPageUptodate(cl_page_vmpage(env, page));
+			cl_page_disown(env, io, page);
+
+			/* held in ll_cl_init() */
+			lu_ref_del(&page->cp_reference, "cl_io", io);
+			cl_page_put(env, page);
+		}
+	}
+
+	return bytes > 0 ? bytes : rc;
+}
+
+static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
+				  struct cl_page *page)
+{
+	const struct cl_page_slice *slice;
+	struct ccc_page *cp;
+	struct page *vmpage;
+
+	slice = cl_page_at(page, &vvp_device_type);
+	cp = cl2ccc_page(slice);
+	vmpage = cp->cpg_page;
+
+	SetPageUptodate(vmpage);
+	set_page_dirty(vmpage);
+	vvp_write_pending(cl2ccc(slice->cpl_obj), cp);
+
+	cl_page_disown(env, io, page);
+
+	/* held in ll_cl_init() */
+	lu_ref_del(&page->cp_reference, "cl_io", io);
+	cl_page_put(env, page);
+}
+
+/* make sure the page list is contiguous */
+static bool page_list_sanity_check(struct cl_page_list *plist)
+{
+	struct cl_page *page;
+	pgoff_t index = CL_PAGE_EOF;
+
+	cl_page_list_for_each(page, plist) {
+		if (index == CL_PAGE_EOF) {
+			index = page->cp_index;
+			continue;
+		}
+
+		++index;
+		if (index == page->cp_index)
+			continue;
+
+		return false;
+	}
+	return true;
+}
+
+/* Return how many bytes have queued or written */
+int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
+{
+	struct cl_object *obj = io->ci_obj;
+	struct inode *inode = ccc_object_inode(obj);
+	struct ccc_io *cio = ccc_env_io(env);
+	struct cl_page_list *queue = &cio->u.write.cui_queue;
+	struct cl_page *page;
+	int rc = 0;
+	int bytes = 0;
+	unsigned int npages = cio->u.write.cui_queue.pl_nr;
+
+	if (npages == 0)
+		return 0;
+
+	CDEBUG(D_VFSTRACE, "commit async pages: %d, from %d, to %d\n",
+	       npages, cio->u.write.cui_from, cio->u.write.cui_to);
+
+	LASSERT(page_list_sanity_check(queue));
+
+	/* submit IO with async write */
+	rc = cl_io_commit_async(env, io, queue,
+				cio->u.write.cui_from, cio->u.write.cui_to,
+				write_commit_callback);
+	npages -= queue->pl_nr; /* already committed pages */
+	if (npages > 0) {
+		/* calculate how many bytes were written */
+		bytes = npages << PAGE_SHIFT;
+
+		/* first page */
+		bytes -= cio->u.write.cui_from;
+		if (queue->pl_nr == 0) /* last page */
+			bytes -= PAGE_SIZE - cio->u.write.cui_to;
+		LASSERTF(bytes > 0, "bytes = %d, pages = %d\n", bytes, npages);
+
+		cio->u.write.cui_written += bytes;
+
+		CDEBUG(D_VFSTRACE, "Committed %d pages %d bytes, tot: %ld\n",
+		       npages, bytes, cio->u.write.cui_written);
+
+		/* the first page must have been written. */
+		cio->u.write.cui_from = 0;
+	}
+	LASSERT(page_list_sanity_check(queue));
+	LASSERT(ergo(rc == 0, queue->pl_nr == 0));
+
+	/* out of quota, try sync write */
+	if (rc == -EDQUOT && !cl_io_is_mkwrite(io)) {
+		rc = vvp_io_commit_sync(env, io, queue,
+					cio->u.write.cui_from,
+					cio->u.write.cui_to);
+		if (rc > 0) {
+			cio->u.write.cui_written += rc;
+			rc = 0;
+		}
+	}
+
+	/* update inode size */
+	ll_merge_lvb(env, inode);
+
+	/* Now the pages in queue were failed to commit, discard them
+	 * unless they were dirtied before.
+	 */
+	while (queue->pl_nr > 0) {
+		page = cl_page_list_first(queue);
+		cl_page_list_del(env, queue, page);
+
+		if (!PageDirty(cl_page_vmpage(env, page)))
+			cl_page_discard(env, io, page);
+
+		cl_page_disown(env, io, page);
+
+		/* held in ll_cl_init() */
+		lu_ref_del(&page->cp_reference, "cl_io", io);
+		cl_page_put(env, page);
+	}
+	cl_page_list_fini(env, queue);
+
+	return rc;
+}
+
 static int vvp_io_write_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
@@ -596,9 +794,24 @@ static int vvp_io_write_start(const struct lu_env *env,
 		result = generic_file_write_iter(cio->cui_iocb, cio->cui_iter);
 
 	if (result > 0) {
+		result = vvp_io_write_commit(env, io);
+		if (cio->u.write.cui_written > 0) {
+			result = cio->u.write.cui_written;
+			io->ci_nob += result;
+
+			CDEBUG(D_VFSTRACE, "write: nob %zd, result: %zd\n",
+			       io->ci_nob, result);
+		}
+	}
+	if (result > 0) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+
+		spin_lock(&lli->lli_lock);
+		lli->lli_flags |= LLIF_DATA_MODIFIED;
+		spin_unlock(&lli->lli_lock);
+
 		if (result < cnt)
 			io->ci_continue = 0;
-		io->ci_nob += result;
 		ll_rw_stats_tally(ll_i2sbi(inode), current->pid,
 				  cio->cui_fd, pos, result, WRITE);
 		result = 0;
@@ -645,6 +858,21 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 	return -EINVAL;
 }
 
+static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
+				    struct cl_page *page)
+{
+	const struct cl_page_slice *slice;
+	struct ccc_page *cp;
+	struct page *vmpage;
+
+	slice = cl_page_at(page, &vvp_device_type);
+	cp = cl2ccc_page(slice);
+	vmpage = cp->cpg_page;
+
+	set_page_dirty(vmpage);
+	vvp_write_pending(cl2ccc(slice->cpl_obj), cp);
+}
+
 static int vvp_io_fault_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
@@ -659,7 +887,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	struct page	  *vmpage  = NULL;
 	struct cl_page      *page;
 	loff_t	       size;
-	pgoff_t	      last; /* last page in a file data region */
+	pgoff_t		     last_index;
 
 	if (fio->ft_executable &&
 	    inode->i_mtime.tv_sec != vio->u.fault.ft_mtime)
@@ -705,15 +933,15 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		goto out;
 	}
 
+	last_index = cl_index(obj, size - 1);
+
 	if (fio->ft_mkwrite) {
-		pgoff_t last_index;
 		/*
 		 * Capture the size while holding the lli_trunc_sem from above
 		 * we want to make sure that we complete the mkwrite action
 		 * while holding this lock. We need to make sure that we are
 		 * not past the end of the file.
 		 */
-		last_index = cl_index(obj, size - 1);
 		if (last_index < fio->ft_index) {
 			CDEBUG(D_PAGE,
 			       "llite: mkwrite and truncate race happened: %p: 0x%lx 0x%lx\n",
@@ -745,21 +973,28 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	 */
 	if (fio->ft_mkwrite) {
 		wait_on_page_writeback(vmpage);
-		if (set_page_dirty(vmpage)) {
-			struct ccc_page *cp;
+		if (!PageDirty(vmpage)) {
+			struct cl_page_list *plist = &io->ci_queue.c2_qin;
+			int to = PAGE_SIZE;
 
 			/* vvp_page_assume() calls wait_on_page_writeback(). */
 			cl_page_assume(env, io, page);
 
-			cp = cl2ccc_page(cl_page_at(page, &vvp_device_type));
-			vvp_write_pending(cl2ccc(obj), cp);
+			cl_page_list_init(plist);
+			cl_page_list_add(plist, page);
+
+			/* size fixup */
+			if (last_index == page->cp_index)
+				to = size & ~PAGE_MASK;
 
 			/* Do not set Dirty bit here so that in case IO is
 			 * started before the page is really made dirty, we
 			 * still have chance to detect it.
 			 */
-			result = cl_page_cache_add(env, io, page, CRT_WRITE);
+			result = cl_io_commit_async(env, io, plist, 0, to,
+						    mkwrite_commit_callback);
 			LASSERT(cl_page_is_owned(page, io));
+			cl_page_list_fini(env, plist);
 
 			vmpage = NULL;
 			if (result < 0) {
@@ -777,15 +1012,14 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		}
 	}
 
-	last = cl_index(obj, size - 1);
 	/*
 	 * The ft_index is only used in the case of
 	 * a mkwrite action. We need to check
 	 * our assertions are correct, since
 	 * we should have caught this above
 	 */
-	LASSERT(!fio->ft_mkwrite || fio->ft_index <= last);
-	if (fio->ft_index == last)
+	LASSERT(!fio->ft_mkwrite || fio->ft_index <= last_index);
+	if (fio->ft_index == last_index)
 		/*
 		 * Last page is mapped partially.
 		 */
@@ -865,234 +1099,6 @@ static int vvp_io_read_page(const struct lu_env *env,
 	return 0;
 }
 
-static int vvp_page_sync_io(const struct lu_env *env, struct cl_io *io,
-			    struct cl_page *page, struct ccc_page *cp,
-			    enum cl_req_type crt)
-{
-	struct cl_2queue  *queue;
-	int result;
-
-	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
-
-	queue = &io->ci_queue;
-	cl_2queue_init_page(queue, page);
-
-	result = cl_io_submit_sync(env, io, crt, queue, 0);
-	LASSERT(cl_page_is_owned(page, io));
-
-	if (crt == CRT_READ)
-		/*
-		 * in CRT_WRITE case page is left locked even in case of
-		 * error.
-		 */
-		cl_page_list_disown(env, io, &queue->c2_qin);
-	cl_2queue_fini(env, queue);
-
-	return result;
-}
-
-/**
- * Prepare partially written-to page for a write.
- */
-static int vvp_io_prepare_partial(const struct lu_env *env, struct cl_io *io,
-				  struct cl_object *obj, struct cl_page *pg,
-				  struct ccc_page *cp,
-				  unsigned from, unsigned to)
-{
-	struct cl_attr *attr   = ccc_env_thread_attr(env);
-	loff_t	  offset = cl_offset(obj, pg->cp_index);
-	int	     result;
-
-	cl_object_attr_lock(obj);
-	result = cl_object_attr_get(env, obj, attr);
-	cl_object_attr_unlock(obj);
-	if (result == 0) {
-		/*
-		 * If are writing to a new page, no need to read old data.
-		 * The extent locking will have updated the KMS, and for our
-		 * purposes here we can treat it like i_size.
-		 */
-		if (attr->cat_kms <= offset) {
-			char *kaddr = kmap_atomic(cp->cpg_page);
-
-			memset(kaddr, 0, cl_page_size(obj));
-			kunmap_atomic(kaddr);
-		} else if (cp->cpg_defer_uptodate)
-			cp->cpg_ra_used = 1;
-		else
-			result = vvp_page_sync_io(env, io, pg, cp, CRT_READ);
-		/*
-		 * In older implementations, obdo_refresh_inode is called here
-		 * to update the inode because the write might modify the
-		 * object info at OST. However, this has been proven useless,
-		 * since LVB functions will be called when user space program
-		 * tries to retrieve inode attribute.  Also, see bug 15909 for
-		 * details. -jay
-		 */
-		if (result == 0)
-			cl_page_export(env, pg, 1);
-	}
-	return result;
-}
-
-static int vvp_io_prepare_write(const struct lu_env *env,
-				const struct cl_io_slice *ios,
-				const struct cl_page_slice *slice,
-				unsigned from, unsigned to)
-{
-	struct cl_object *obj    = slice->cpl_obj;
-	struct ccc_page  *cp     = cl2ccc_page(slice);
-	struct cl_page   *pg     = slice->cpl_page;
-	struct page       *vmpage = cp->cpg_page;
-
-	int result;
-
-	LINVRNT(cl_page_is_vmlocked(env, pg));
-	LASSERT(vmpage->mapping->host == ccc_object_inode(obj));
-
-	result = 0;
-
-	CL_PAGE_HEADER(D_PAGE, env, pg, "preparing: [%d, %d]\n", from, to);
-	if (!PageUptodate(vmpage)) {
-		/*
-		 * We're completely overwriting an existing page, so _don't_
-		 * set it up to date until commit_write
-		 */
-		if (from == 0 && to == PAGE_CACHE_SIZE) {
-			CL_PAGE_HEADER(D_PAGE, env, pg, "full page write\n");
-			POISON_PAGE(page, 0x11);
-		} else
-			result = vvp_io_prepare_partial(env, ios->cis_io, obj,
-							pg, cp, from, to);
-	} else
-		CL_PAGE_HEADER(D_PAGE, env, pg, "uptodate\n");
-	return result;
-}
-
-static int vvp_io_commit_write(const struct lu_env *env,
-			       const struct cl_io_slice *ios,
-			       const struct cl_page_slice *slice,
-			       unsigned from, unsigned to)
-{
-	struct cl_object  *obj    = slice->cpl_obj;
-	struct cl_io      *io     = ios->cis_io;
-	struct ccc_page   *cp     = cl2ccc_page(slice);
-	struct cl_page    *pg     = slice->cpl_page;
-	struct inode      *inode  = ccc_object_inode(obj);
-	struct ll_sb_info *sbi    = ll_i2sbi(inode);
-	struct ll_inode_info *lli = ll_i2info(inode);
-	struct page	*vmpage = cp->cpg_page;
-
-	int    result;
-	int    tallyop;
-	loff_t size;
-
-	LINVRNT(cl_page_is_vmlocked(env, pg));
-	LASSERT(vmpage->mapping->host == inode);
-
-	LU_OBJECT_HEADER(D_INODE, env, &obj->co_lu, "committing page write\n");
-	CL_PAGE_HEADER(D_PAGE, env, pg, "committing: [%d, %d]\n", from, to);
-
-	/*
-	 * queue a write for some time in the future the first time we
-	 * dirty the page.
-	 *
-	 * This is different from what other file systems do: they usually
-	 * just mark page (and some of its buffers) dirty and rely on
-	 * balance_dirty_pages() to start a write-back. Lustre wants write-back
-	 * to be started earlier for the following reasons:
-	 *
-	 *     (1) with a large number of clients we need to limit the amount
-	 *     of cached data on the clients a lot;
-	 *
-	 *     (2) large compute jobs generally want compute-only then io-only
-	 *     and the IO should complete as quickly as possible;
-	 *
-	 *     (3) IO is batched up to the RPC size and is async until the
-	 *     client max cache is hit
-	 *     (/sys/fs/lustre/osc/OSC.../max_dirty_mb)
-	 *
-	 */
-	if (!PageDirty(vmpage)) {
-		tallyop = LPROC_LL_DIRTY_MISSES;
-		result = cl_page_cache_add(env, io, pg, CRT_WRITE);
-		if (result == 0) {
-			/* page was added into cache successfully. */
-			set_page_dirty(vmpage);
-			vvp_write_pending(cl2ccc(obj), cp);
-		} else if (result == -EDQUOT) {
-			pgoff_t last_index = i_size_read(inode) >> PAGE_CACHE_SHIFT;
-			bool need_clip = true;
-
-			/*
-			 * Client ran out of disk space grant. Possible
-			 * strategies are:
-			 *
-			 *     (a) do a sync write, renewing grant;
-			 *
-			 *     (b) stop writing on this stripe, switch to the
-			 *     next one.
-			 *
-			 * (b) is a part of "parallel io" design that is the
-			 * ultimate goal. (a) is what "old" client did, and
-			 * what the new code continues to do for the time
-			 * being.
-			 */
-			if (last_index > pg->cp_index) {
-				to = PAGE_CACHE_SIZE;
-				need_clip = false;
-			} else if (last_index == pg->cp_index) {
-				int size_to = i_size_read(inode) & ~PAGE_MASK;
-
-				if (to < size_to)
-					to = size_to;
-			}
-			if (need_clip)
-				cl_page_clip(env, pg, 0, to);
-			result = vvp_page_sync_io(env, io, pg, cp, CRT_WRITE);
-			if (result)
-				CERROR("Write page %lu of inode %p failed %d\n",
-				       pg->cp_index, inode, result);
-		}
-	} else {
-		tallyop = LPROC_LL_DIRTY_HITS;
-		result = 0;
-	}
-	ll_stats_ops_tally(sbi, tallyop, 1);
-
-	/* Inode should be marked DIRTY even if no new page was marked DIRTY
-	 * because page could have been not flushed between 2 modifications.
-	 * It is important the file is marked DIRTY as soon as the I/O is done
-	 * Indeed, when cache is flushed, file could be already closed and it
-	 * is too late to warn the MDT.
-	 * It is acceptable that file is marked DIRTY even if I/O is dropped
-	 * for some reasons before being flushed to OST.
-	 */
-	if (result == 0) {
-		spin_lock(&lli->lli_lock);
-		lli->lli_flags |= LLIF_DATA_MODIFIED;
-		spin_unlock(&lli->lli_lock);
-	}
-
-	size = cl_offset(obj, pg->cp_index) + to;
-
-	ll_inode_size_lock(inode);
-	if (result == 0) {
-		if (size > i_size_read(inode)) {
-			cl_isize_write_nolock(inode, size);
-			CDEBUG(D_VFSTRACE, DFID" updating i_size %lu\n",
-			       PFID(lu_object_fid(&obj->co_lu)),
-			       (unsigned long)size);
-		}
-		cl_page_export(env, pg, 1);
-	} else {
-		if (size > i_size_read(inode))
-			cl_page_discard(env, io, pg);
-	}
-	ll_inode_size_unlock(inode);
-	return result;
-}
-
 static const struct cl_io_operations vvp_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -1103,6 +1109,8 @@ static const struct cl_io_operations vvp_io_ops = {
 		},
 		[CIT_WRITE] = {
 			.cio_fini      = vvp_io_fini,
+			.cio_iter_init = vvp_io_write_iter_init,
+			.cio_iter_fini = vvp_io_write_iter_fini,
 			.cio_lock      = vvp_io_write_lock,
 			.cio_start     = vvp_io_write_start,
 			.cio_advance   = ccc_io_advance
@@ -1130,8 +1138,6 @@ static const struct cl_io_operations vvp_io_ops = {
 		}
 	},
 	.cio_read_page     = vvp_io_read_page,
-	.cio_prepare_write = vvp_io_prepare_write,
-	.cio_commit_write  = vvp_io_commit_write
 };
 
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 7dd3162..3d568fc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -444,8 +444,10 @@ struct lov_thread_info {
 	struct cl_lock_descr    lti_ldescr;
 	struct ost_lvb	  lti_lvb;
 	struct cl_2queue	lti_cl2q;
+	struct cl_page_list     lti_plist;
 	struct cl_lock_closure  lti_closure;
 	wait_queue_t	  lti_waiter;
+	struct cl_attr          lti_attr;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 4296aac..c606490 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -543,13 +543,6 @@ static void lov_io_unlock(const struct lu_env *env,
 	LASSERT(rc == 0);
 }
 
-static struct cl_page_list *lov_io_submit_qin(struct lov_device *ld,
-					      struct cl_page_list *qin,
-					      int idx, int alloc)
-{
-	return alloc ? &qin[idx] : &ld->ld_emrg[idx]->emrg_page_list;
-}
-
 /**
  * lov implementation of cl_operations::cio_submit() method. It takes a list
  * of pages in \a queue, splits it into per-stripe sub-lists, invokes
@@ -569,25 +562,17 @@ static int lov_io_submit(const struct lu_env *env,
 			 const struct cl_io_slice *ios,
 			 enum cl_req_type crt, struct cl_2queue *queue)
 {
-	struct lov_io	  *lio = cl2lov_io(env, ios);
-	struct lov_object      *obj = lio->lis_object;
-	struct lov_device       *ld = lu2lov_dev(lov2cl(obj)->co_lu.lo_dev);
-	struct cl_page_list    *qin = &queue->c2_qin;
-	struct cl_2queue      *cl2q = &lov_env_info(env)->lti_cl2q;
-	struct cl_page_list *stripes_qin = NULL;
+	struct cl_page_list *qin = &queue->c2_qin;
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct lov_io_sub *sub;
+	struct cl_page_list *plist = &lov_env_info(env)->lti_plist;
 	struct cl_page *page;
-	struct cl_page *tmp;
 	int stripe;
 
-#define QIN(stripe) lov_io_submit_qin(ld, stripes_qin, stripe, alloc)
-
 	int rc = 0;
-	int alloc =
-		!(current->flags & PF_MEMALLOC);
 
 	if (lio->lis_active_subios == 1) {
 		int idx = lio->lis_single_subio_index;
-		struct lov_io_sub *sub;
 
 		LASSERT(idx < lio->lis_nr_subios);
 		sub = lov_sub_get(env, lio, idx);
@@ -600,119 +585,120 @@ static int lov_io_submit(const struct lu_env *env,
 	}
 
 	LASSERT(lio->lis_subs);
-	if (alloc) {
-		stripes_qin =
-			libcfs_kvzalloc(sizeof(*stripes_qin) *
-					lio->lis_nr_subios,
-					GFP_NOFS);
-		if (!stripes_qin)
-			return -ENOMEM;
-
-		for (stripe = 0; stripe < lio->lis_nr_subios; stripe++)
-			cl_page_list_init(&stripes_qin[stripe]);
-	} else {
-		/*
-		 * If we get here, it means pageout & swap doesn't help.
-		 * In order to not make things worse, even don't try to
-		 * allocate the memory with __GFP_NOWARN. -jay
-		 */
-		mutex_lock(&ld->ld_mutex);
-		lio->lis_mem_frozen = 1;
-	}
 
-	cl_2queue_init(cl2q);
-	cl_page_list_for_each_safe(page, tmp, qin) {
-		stripe = lov_page_stripe(page);
-		cl_page_list_move(QIN(stripe), qin, page);
-	}
+	cl_page_list_init(plist);
+	while (qin->pl_nr > 0) {
+		struct cl_2queue *cl2q = &lov_env_info(env)->lti_cl2q;
 
-	for (stripe = 0; stripe < lio->lis_nr_subios; stripe++) {
-		struct lov_io_sub   *sub;
-		struct cl_page_list *sub_qin = QIN(stripe);
+		cl_2queue_init(cl2q);
 
-		if (list_empty(&sub_qin->pl_pages))
-			continue;
+		page = cl_page_list_first(qin);
+		cl_page_list_move(&cl2q->c2_qin, qin, page);
+
+		stripe = lov_page_stripe(page);
+		while (qin->pl_nr > 0) {
+			page = cl_page_list_first(qin);
+			if (stripe != lov_page_stripe(page))
+				break;
+
+			cl_page_list_move(&cl2q->c2_qin, qin, page);
+		}
 
-		cl_page_list_splice(sub_qin, &cl2q->c2_qin);
 		sub = lov_sub_get(env, lio, stripe);
 		if (!IS_ERR(sub)) {
 			rc = cl_io_submit_rw(sub->sub_env, sub->sub_io,
 					     crt, cl2q);
 			lov_sub_put(sub);
-		} else
+		} else {
 			rc = PTR_ERR(sub);
-		cl_page_list_splice(&cl2q->c2_qin,  &queue->c2_qin);
+		}
+
+		cl_page_list_splice(&cl2q->c2_qin, plist);
 		cl_page_list_splice(&cl2q->c2_qout, &queue->c2_qout);
+		cl_2queue_fini(env, cl2q);
+
 		if (rc != 0)
 			break;
 	}
 
-	for (stripe = 0; stripe < lio->lis_nr_subios; stripe++) {
-		struct cl_page_list *sub_qin = QIN(stripe);
+	cl_page_list_splice(plist, qin);
+	cl_page_list_fini(env, plist);
 
-		if (list_empty(&sub_qin->pl_pages))
-			continue;
+	return rc;
+}
+
+static int lov_io_commit_async(const struct lu_env *env,
+			       const struct cl_io_slice *ios,
+			       struct cl_page_list *queue, int from, int to,
+			       cl_commit_cbt cb)
+{
+	struct cl_page_list *plist = &lov_env_info(env)->lti_plist;
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct lov_io_sub *sub;
+	struct cl_page *page;
+	int rc = 0;
 
-		cl_page_list_splice(sub_qin, qin);
+	if (lio->lis_active_subios == 1) {
+		int idx = lio->lis_single_subio_index;
+
+		LASSERT(idx < lio->lis_nr_subios);
+		sub = lov_sub_get(env, lio, idx);
+		LASSERT(!IS_ERR(sub));
+		LASSERT(sub->sub_io == &lio->lis_single_subio);
+		rc = cl_io_commit_async(sub->sub_env, sub->sub_io, queue,
+					from, to, cb);
+		lov_sub_put(sub);
+		return rc;
 	}
 
-	if (alloc) {
-		kvfree(stripes_qin);
-	} else {
-		int i;
+	LASSERT(lio->lis_subs);
 
-		for (i = 0; i < lio->lis_nr_subios; i++) {
-			struct cl_io *cio = lio->lis_subs[i].sub_io;
+	cl_page_list_init(plist);
+	while (queue->pl_nr > 0) {
+		int stripe_to = to;
+		int stripe;
 
-			if (cio && cio == &ld->ld_emrg[i]->emrg_subio)
-				lov_io_sub_fini(env, lio, &lio->lis_subs[i]);
+		LASSERT(plist->pl_nr == 0);
+		page = cl_page_list_first(queue);
+		cl_page_list_move(plist, queue, page);
+
+		stripe = lov_page_stripe(page);
+		while (queue->pl_nr > 0) {
+			page = cl_page_list_first(queue);
+			if (stripe != lov_page_stripe(page))
+				break;
+
+			cl_page_list_move(plist, queue, page);
 		}
-		lio->lis_mem_frozen = 0;
-		mutex_unlock(&ld->ld_mutex);
-	}
 
-	return rc;
-#undef QIN
-}
+		if (queue->pl_nr > 0) /* still has more pages */
+			stripe_to = PAGE_SIZE;
 
-static int lov_io_prepare_write(const struct lu_env *env,
-				const struct cl_io_slice *ios,
-				const struct cl_page_slice *slice,
-				unsigned from, unsigned to)
-{
-	struct lov_io     *lio      = cl2lov_io(env, ios);
-	struct cl_page    *sub_page = lov_sub_page(slice);
-	struct lov_io_sub *sub;
-	int result;
+		sub = lov_sub_get(env, lio, stripe);
+		if (!IS_ERR(sub)) {
+			rc = cl_io_commit_async(sub->sub_env, sub->sub_io,
+						plist, from, stripe_to, cb);
+			lov_sub_put(sub);
+		} else {
+			rc = PTR_ERR(sub);
+			break;
+		}
 
-	sub = lov_page_subio(env, lio, slice);
-	if (!IS_ERR(sub)) {
-		result = cl_io_prepare_write(sub->sub_env, sub->sub_io,
-					     sub_page, from, to);
-		lov_sub_put(sub);
-	} else
-		result = PTR_ERR(sub);
-	return result;
-}
+		if (plist->pl_nr > 0) /* short write */
+			break;
 
-static int lov_io_commit_write(const struct lu_env *env,
-			       const struct cl_io_slice *ios,
-			       const struct cl_page_slice *slice,
-			       unsigned from, unsigned to)
-{
-	struct lov_io     *lio      = cl2lov_io(env, ios);
-	struct cl_page    *sub_page = lov_sub_page(slice);
-	struct lov_io_sub *sub;
-	int result;
+		from = 0;
+	}
 
-	sub = lov_page_subio(env, lio, slice);
-	if (!IS_ERR(sub)) {
-		result = cl_io_commit_write(sub->sub_env, sub->sub_io,
-					    sub_page, from, to);
-		lov_sub_put(sub);
-	} else
-		result = PTR_ERR(sub);
-	return result;
+	/* for error case, add the page back into the qin list */
+	LASSERT(ergo(rc == 0, plist->pl_nr == 0));
+	while (plist->pl_nr > 0) {
+		/* error occurred, add the uncommitted pages back into queue */
+		page = cl_page_list_last(plist);
+		cl_page_list_move_head(queue, plist, page);
+	}
+
+	return rc;
 }
 
 static int lov_io_fault_start(const struct lu_env *env,
@@ -803,16 +789,8 @@ static const struct cl_io_operations lov_io_ops = {
 			.cio_fini   = lov_io_fini
 		}
 	},
-	.req_op = {
-		 [CRT_READ] = {
-			 .cio_submit    = lov_io_submit
-		 },
-		 [CRT_WRITE] = {
-			 .cio_submit    = lov_io_submit
-		 }
-	 },
-	.cio_prepare_write = lov_io_prepare_write,
-	.cio_commit_write  = lov_io_commit_write
+	.cio_submit                    = lov_io_submit,
+	.cio_commit_async              = lov_io_commit_async,
 };
 
 /*****************************************************************************
@@ -880,15 +858,8 @@ static const struct cl_io_operations lov_empty_io_ops = {
 			.cio_fini   = lov_empty_io_fini
 		}
 	},
-	.req_op = {
-		 [CRT_READ] = {
-			 .cio_submit    = LOV_EMPTY_IMPOSSIBLE
-		 },
-		 [CRT_WRITE] = {
-			 .cio_submit    = LOV_EMPTY_IMPOSSIBLE
-		 }
-	 },
-	.cio_commit_write = LOV_EMPTY_IMPOSSIBLE
+	.cio_submit                    = LOV_EMPTY_IMPOSSIBLE,
+	.cio_commit_async              = LOV_EMPTY_IMPOSSIBLE
 };
 
 int lov_io_init_raid0(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 9728da2..5d9b355 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -105,29 +105,6 @@ static void lov_page_assume(const struct lu_env *env,
 	lov_page_own(env, slice, io, 0);
 }
 
-static int lov_page_cache_add(const struct lu_env *env,
-			      const struct cl_page_slice *slice,
-			      struct cl_io *io)
-{
-	struct lov_io     *lio = lov_env_io(env);
-	struct lov_io_sub *sub;
-	int rc = 0;
-
-	LINVRNT(lov_page_invariant(slice));
-	LINVRNT(!cl2lov_page(slice)->lps_invalid);
-
-	sub = lov_page_subio(env, lio, slice);
-	if (!IS_ERR(sub)) {
-		rc = cl_page_cache_add(sub->sub_env, sub->sub_io,
-				       slice->cpl_page->cp_child, CRT_WRITE);
-		lov_sub_put(sub);
-	} else {
-		rc = PTR_ERR(sub);
-		CL_PAGE_DEBUG(D_ERROR, env, slice->cpl_page, "rc = %d\n", rc);
-	}
-	return rc;
-}
-
 static int lov_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
@@ -141,11 +118,6 @@ static const struct cl_page_operations lov_page_ops = {
 	.cpo_fini   = lov_page_fini,
 	.cpo_own    = lov_page_own,
 	.cpo_assume = lov_page_assume,
-	.io = {
-		[CRT_WRITE] = {
-			.cpo_cache_add = lov_page_cache_add
-		}
-	},
 	.cpo_print  = lov_page_print
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index cf94284..9b3c5c1 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -782,77 +782,29 @@ int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
 EXPORT_SYMBOL(cl_io_read_page);
 
 /**
- * Called by write io to prepare page to receive data from user buffer.
+ * Commit a list of contiguous pages into writeback cache.
  *
- * \see cl_io_operations::cio_prepare_write()
+ * \returns 0 if all pages committed, or errcode if error occurred.
+ * \see cl_io_operations::cio_commit_async()
  */
-int cl_io_prepare_write(const struct lu_env *env, struct cl_io *io,
-			struct cl_page *page, unsigned from, unsigned to)
+int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
+		       struct cl_page_list *queue, int from, int to,
+		       cl_commit_cbt cb)
 {
 	const struct cl_io_slice *scan;
 	int result = 0;
 
-	LINVRNT(io->ci_type == CIT_WRITE);
-	LINVRNT(cl_page_is_owned(page, io));
-	LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
-	LINVRNT(cl_io_invariant(io));
-	LASSERT(cl_page_in_io(page, io));
-
-	cl_io_for_each_reverse(scan, io) {
-		if (scan->cis_iop->cio_prepare_write) {
-			const struct cl_page_slice *slice;
-
-			slice = cl_io_slice_page(scan, page);
-			result = scan->cis_iop->cio_prepare_write(env, scan,
-								  slice,
-								  from, to);
-			if (result != 0)
-				break;
-		}
-	}
-	return result;
-}
-EXPORT_SYMBOL(cl_io_prepare_write);
-
-/**
- * Called by write io after user data were copied into a page.
- *
- * \see cl_io_operations::cio_commit_write()
- */
-int cl_io_commit_write(const struct lu_env *env, struct cl_io *io,
-		       struct cl_page *page, unsigned from, unsigned to)
-{
-	const struct cl_io_slice *scan;
-	int result = 0;
-
-	LINVRNT(io->ci_type == CIT_WRITE);
-	LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
-	LINVRNT(cl_io_invariant(io));
-	/*
-	 * XXX Uh... not nice. Top level cl_io_commit_write() call (vvp->lov)
-	 * already called cl_page_cache_add(), moving page into CPS_CACHED
-	 * state. Better (and more general) way of dealing with such situation
-	 * is needed.
-	 */
-	LASSERT(cl_page_is_owned(page, io) || page->cp_parent);
-	LASSERT(cl_page_in_io(page, io));
-
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->cio_commit_write) {
-			const struct cl_page_slice *slice;
-
-			slice = cl_io_slice_page(scan, page);
-			result = scan->cis_iop->cio_commit_write(env, scan,
-								 slice,
-								 from, to);
-			if (result != 0)
-				break;
-		}
+		if (!scan->cis_iop->cio_commit_async)
+			continue;
+		result = scan->cis_iop->cio_commit_async(env, scan, queue,
+							 from, to, cb);
+		if (result != 0)
+			break;
 	}
-	LINVRNT(result <= 0);
 	return result;
 }
-EXPORT_SYMBOL(cl_io_commit_write);
+EXPORT_SYMBOL(cl_io_commit_async);
 
 /**
  * Submits a list of pages for immediate io.
@@ -870,13 +822,10 @@ int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
 	const struct cl_io_slice *scan;
 	int result = 0;
 
-	LINVRNT(crt < ARRAY_SIZE(scan->cis_iop->req_op));
-
 	cl_io_for_each(scan, io) {
-		if (!scan->cis_iop->req_op[crt].cio_submit)
+		if (!scan->cis_iop->cio_submit)
 			continue;
-		result = scan->cis_iop->req_op[crt].cio_submit(env, scan, crt,
-							       queue);
+		result = scan->cis_iop->cio_submit(env, scan, crt, queue);
 		if (result != 0)
 			break;
 	}
@@ -1073,8 +1022,8 @@ EXPORT_SYMBOL(cl_page_list_add);
 /**
  * Removes a page from a page list.
  */
-static void cl_page_list_del(const struct lu_env *env,
-			     struct cl_page_list *plist, struct cl_page *page)
+void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
+		      struct cl_page *page)
 {
 	LASSERT(plist->pl_nr > 0);
 	LINVRNT(plist->pl_owner == current);
@@ -1087,6 +1036,7 @@ static void cl_page_list_del(const struct lu_env *env,
 	lu_ref_del_at(&page->cp_reference, &page->cp_queue_ref, "queue", plist);
 	cl_page_put(env, page);
 }
+EXPORT_SYMBOL(cl_page_list_del);
 
 /**
  * Moves a page from one page list to another.
@@ -1107,6 +1057,24 @@ void cl_page_list_move(struct cl_page_list *dst, struct cl_page_list *src,
 EXPORT_SYMBOL(cl_page_list_move);
 
 /**
+ * Moves a page from one page list to the head of another list.
+ */
+void cl_page_list_move_head(struct cl_page_list *dst, struct cl_page_list *src,
+			    struct cl_page *page)
+{
+	LASSERT(src->pl_nr > 0);
+	LINVRNT(dst->pl_owner == current);
+	LINVRNT(src->pl_owner == current);
+
+	list_move(&page->cp_batch, &dst->pl_pages);
+	--src->pl_nr;
+	++dst->pl_nr;
+	lu_ref_set_at(&page->cp_reference, &page->cp_queue_ref, "queue",
+		      src, dst);
+}
+EXPORT_SYMBOL(cl_page_list_move_head);
+
+/**
  * splice the cl_page_list, just as list head does
  */
 void cl_page_list_splice(struct cl_page_list *list, struct cl_page_list *head)
@@ -1163,8 +1131,7 @@ EXPORT_SYMBOL(cl_page_list_disown);
 /**
  * Releases pages from queue.
  */
-static void cl_page_list_fini(const struct lu_env *env,
-			      struct cl_page_list *plist)
+void cl_page_list_fini(const struct lu_env *env, struct cl_page_list *plist)
 {
 	struct cl_page *page;
 	struct cl_page *temp;
@@ -1175,6 +1142,7 @@ static void cl_page_list_fini(const struct lu_env *env,
 		cl_page_list_del(env, plist, page);
 	LASSERT(plist->pl_nr == 0);
 }
+EXPORT_SYMBOL(cl_page_list_fini);
 
 /**
  * Assumes all pages in a queue.
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index bab8a74..0844a97 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1012,44 +1012,6 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
 EXPORT_SYMBOL(cl_page_make_ready);
 
 /**
- * Notify layers that high level io decided to place this page into a cache
- * for future transfer.
- *
- * The layer implementing transfer engine (osc) has to register this page in
- * its queues.
- *
- * \pre  cl_page_is_owned(pg, io)
- * \post cl_page_is_owned(pg, io)
- *
- * \see cl_page_operations::cpo_cache_add()
- */
-int cl_page_cache_add(const struct lu_env *env, struct cl_io *io,
-		      struct cl_page *pg, enum cl_req_type crt)
-{
-	const struct cl_page_slice *scan;
-	int result = 0;
-
-	PINVRNT(env, pg, crt < CRT_NR);
-	PINVRNT(env, pg, cl_page_is_owned(pg, io));
-	PINVRNT(env, pg, cl_page_invariant(pg));
-
-	if (crt >= CRT_NR)
-		return -EINVAL;
-
-	list_for_each_entry(scan, &pg->cp_layers, cpl_linkage) {
-		if (!scan->cpl_ops->io[crt].cpo_cache_add)
-			continue;
-
-		result = scan->cpl_ops->io[crt].cpo_cache_add(env, scan, io);
-		if (result != 0)
-			break;
-	}
-	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, result);
-	return result;
-}
-EXPORT_SYMBOL(cl_page_cache_add);
-
-/**
  * Called if a pge is being written back by kernel's intention.
  *
  * \pre  cl_page_is_owned(pg, io)
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 33ce0c8..6c205f9 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1085,22 +1085,17 @@ static int cl_echo_cancel0(struct lu_env *env, struct echo_device *ed,
 	return 0;
 }
 
-static int cl_echo_async_brw(const struct lu_env *env, struct cl_io *io,
-			     enum cl_req_type unused, struct cl_2queue *queue)
+static void echo_commit_callback(const struct lu_env *env, struct cl_io *io,
+				 struct cl_page *page)
 {
-	struct cl_page *clp;
-	struct cl_page *temp;
-	int result = 0;
+	struct echo_thread_info *info;
+	struct cl_2queue *queue;
 
-	cl_page_list_for_each_safe(clp, temp, &queue->c2_qin) {
-		int rc;
+	info = echo_env_info(env);
+	LASSERT(io == &info->eti_io);
 
-		rc = cl_page_cache_add(env, io, clp, CRT_WRITE);
-		if (rc == 0)
-			continue;
-		result = result ?: rc;
-	}
-	return result;
+	queue = &info->eti_queue;
+	cl_page_list_add(&queue->c2_qout, page);
 }
 
 static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
@@ -1179,7 +1174,9 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 
 		async = async && (typ == CRT_WRITE);
 		if (async)
-			rc = cl_echo_async_brw(env, io, typ, queue);
+			rc = cl_io_commit_async(env, io, &queue->c2_qin,
+						0, PAGE_SIZE,
+						echo_commit_callback);
 		else
 			rc = cl_io_submit_sync(env, io, typ, queue, 0);
 		CDEBUG(D_INFO, "echo_client %s write returns %d\n",
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index c9d4e3c..3be4b1f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -879,10 +879,9 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		 * span a whole chunk on the OST side, or our accounting goes
 		 * wrong.  Should match the code in filter_grant_check.
 		 */
-		int offset = oap->oap_page_off & ~PAGE_MASK;
-		int count = oap->oap_count + (offset & (blocksize - 1));
-		int end = (offset + oap->oap_count) & (blocksize - 1);
-
+		int offset = last_off & ~PAGE_MASK;
+		int count = last_count + (offset & (blocksize - 1));
+		int end = (offset + last_count) & (blocksize - 1);
 		if (end)
 			count += blocksize - end;
 
@@ -3131,14 +3130,13 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 	struct cl_page *page = cl_page_top(ops->ops_cl.cpl_page);
 
 	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
-	KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
-		      !PageWriteback(cl_page_vmpage(env, page))));
-	KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
-		      !PageDirty(cl_page_vmpage(env, page))));
 
 	/* page is top page. */
 	info->oti_next_index = osc_index(ops) + 1;
 	if (cl_page_own(env, io, page) == 0) {
+		KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
+			      !PageDirty(cl_page_vmpage(env, page))));
+
 		/* discard the page */
 		cl_page_discard(env, io, page);
 		cl_page_disown(env, io, page);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index e70f06c..0e06bed 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -453,6 +453,8 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 			struct page *page, loff_t offset);
 int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		       struct osc_page *ops);
+int osc_page_cache_add(const struct lu_env *env,
+		       const struct cl_page_slice *slice, struct cl_io *io);
 int osc_teardown_async_page(const struct lu_env *env, struct osc_object *obj,
 			    struct osc_page *ops);
 int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index b3b15d4..906225c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -83,6 +83,12 @@ struct osc_async_page {
 #define oap_count       oap_brw_page.count
 #define oap_brw_flags   oap_brw_page.flag
 
+static inline struct osc_async_page *brw_page2oap(struct brw_page *pga)
+{
+	return (struct osc_async_page *)container_of(pga, struct osc_async_page,
+						     oap_brw_page);
+}
+
 struct osc_cache_waiter {
 	struct list_head	      ocw_entry;
 	wait_queue_head_t	     ocw_waitq;
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 1536d31..e9e18a1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -185,6 +185,13 @@ static int osc_io_submit(const struct lu_env *env,
 	return qout->pl_nr > 0 ? 0 : result;
 }
 
+/**
+ * This is called when a page is accessed within file in a way that creates
+ * new page, if one were missing (i.e., if there were a hole at that place in
+ * the file, or accessed page is beyond the current file size).
+ *
+ * Expand stripe KMS if necessary.
+ */
 static void osc_page_touch_at(const struct lu_env *env,
 			      struct cl_object *obj, pgoff_t idx, unsigned to)
 {
@@ -208,7 +215,8 @@ static void osc_page_touch_at(const struct lu_env *env,
 	       kms > loi->loi_kms ? "" : "not ", loi->loi_kms, kms,
 	       loi->loi_lvb.lvb_size);
 
-	valid = 0;
+	attr->cat_mtime = attr->cat_ctime = LTIME_S(CURRENT_TIME);
+	valid = CAT_MTIME | CAT_CTIME;
 	if (kms > loi->loi_kms) {
 		attr->cat_kms = kms;
 		valid |= CAT_KMS;
@@ -221,91 +229,83 @@ static void osc_page_touch_at(const struct lu_env *env,
 	cl_object_attr_unlock(obj);
 }
 
-/**
- * This is called when a page is accessed within file in a way that creates
- * new page, if one were missing (i.e., if there were a hole at that place in
- * the file, or accessed page is beyond the current file size). Examples:
- * ->commit_write() and ->nopage() methods.
- *
- * Expand stripe KMS if necessary.
- */
-static void osc_page_touch(const struct lu_env *env,
-			   struct osc_page *opage, unsigned to)
-{
-	struct cl_page *page = opage->ops_cl.cpl_page;
-	struct cl_object *obj = opage->ops_cl.cpl_obj;
-
-	osc_page_touch_at(env, obj, page->cp_index, to);
-}
-
-/**
- * Implements cl_io_operations::cio_prepare_write() method for osc layer.
- *
- * \retval -EIO transfer initiated against this osc will most likely fail
- * \retval 0    transfer initiated against this osc will most likely succeed.
- *
- * The reason for this check is to immediately return an error to the caller
- * in the case of a deactivated import. Note, that import can be deactivated
- * later, while pages, dirtied by this IO, are still in the cache, but this is
- * irrelevant, because that would still return an error to the application (if
- * it does fsync), but many applications don't do fsync because of performance
- * issues, and we wanted to return an -EIO at write time to notify the
- * application.
- */
-static int osc_io_prepare_write(const struct lu_env *env,
-				const struct cl_io_slice *ios,
-				const struct cl_page_slice *slice,
-				unsigned from, unsigned to)
+static int osc_io_commit_async(const struct lu_env *env,
+			       const struct cl_io_slice *ios,
+			       struct cl_page_list *qin, int from, int to,
+			       cl_commit_cbt cb)
 {
-	struct osc_device *dev = lu2osc_dev(slice->cpl_obj->co_lu.lo_dev);
-	struct obd_import *imp = class_exp2cliimp(dev->od_exp);
+	struct cl_io *io = ios->cis_io;
 	struct osc_io *oio = cl2osc_io(env, ios);
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct cl_page *page;
+	struct cl_page *last_page;
+	struct osc_page *opg;
 	int result = 0;
 
+	LASSERT(qin->pl_nr > 0);
+
+	/* Handle partial page cases */
+	last_page = cl_page_list_last(qin);
+	if (oio->oi_lockless) {
+		page = cl_page_list_first(qin);
+		if (page == last_page) {
+			cl_page_clip(env, page, from, to);
+		} else {
+			if (from != 0)
+				cl_page_clip(env, page, from, PAGE_SIZE);
+			if (to != PAGE_SIZE)
+				cl_page_clip(env, last_page, 0, to);
+		}
+	}
+
 	/*
-	 * This implements OBD_BRW_CHECK logic from old client.
+	 * NOTE: here @page is a top-level page. This is done to avoid
+	 * creation of sub-page-list.
 	 */
+	while (qin->pl_nr > 0) {
+		struct osc_async_page *oap;
 
-	if (!imp || imp->imp_invalid)
-		result = -EIO;
-	if (result == 0 && oio->oi_lockless)
-		/* this page contains `invalid' data, but who cares?
-		 * nobody can access the invalid data.
-		 * in osc_io_commit_write(), we're going to write exact
-		 * [from, to) bytes of this page to OST. -jay
-		 */
-		cl_page_export(env, slice->cpl_page, 1);
+		page = cl_page_list_first(qin);
+		opg = osc_cl_page_osc(page);
+		oap = &opg->ops_oap;
 
-	return result;
-}
+		if (!list_empty(&oap->oap_rpc_item)) {
+			CDEBUG(D_CACHE, "Busy oap %p page %p for submit.\n",
+			       oap, opg);
+			result = -EBUSY;
+			break;
+		}
 
-static int osc_io_commit_write(const struct lu_env *env,
-			       const struct cl_io_slice *ios,
-			       const struct cl_page_slice *slice,
-			       unsigned from, unsigned to)
-{
-	struct osc_io *oio = cl2osc_io(env, ios);
-	struct osc_page *opg = cl2osc_page(slice);
-	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
-	struct osc_async_page *oap = &opg->ops_oap;
+		/* The page may be already in dirty cache. */
+		if (list_empty(&oap->oap_pending_item)) {
+			result = osc_page_cache_add(env, &opg->ops_cl, io);
+			if (result != 0)
+				break;
+		}
 
-	LASSERT(to > 0);
-	/*
-	 * XXX instead of calling osc_page_touch() here and in
-	 * osc_io_fault_start() it might be more logical to introduce
-	 * cl_page_touch() method, that generic cl_io_commit_write() and page
-	 * fault code calls.
-	 */
-	osc_page_touch(env, cl2osc_page(slice), to);
-	if (!client_is_remote(osc_export(obj)) &&
-	    capable(CFS_CAP_SYS_RESOURCE))
-		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
+		osc_page_touch_at(env, osc2cl(osc),
+				  opg->ops_cl.cpl_page->cp_index,
+				  page == last_page ? to : PAGE_SIZE);
 
-	if (oio->oi_lockless)
-		/* see osc_io_prepare_write() for lockless io handling. */
-		cl_page_clip(env, slice->cpl_page, from, to);
+		cl_page_list_del(env, qin, page);
 
-	return 0;
+		(*cb)(env, io, page);
+		/* Can't access page any more. Page can be in transfer and
+		 * complete at any time.
+		 */
+	}
+
+	/* for sync write, kernel will wait for this page to be flushed before
+	 * osc_io_end() is called, so release it earlier.
+	 * for mkwrite(), it's known there is no further pages.
+	 */
+	if (cl_io_is_sync_write(io) && oio->oi_active) {
+		osc_extent_release(env, oio->oi_active);
+		oio->oi_active = NULL;
+	}
+
+	CDEBUG(D_INFO, "%d %d\n", qin->pl_nr, result);
+	return result;
 }
 
 static int osc_io_rw_iter_init(const struct lu_env *env,
@@ -719,16 +719,8 @@ static const struct cl_io_operations osc_io_ops = {
 			.cio_fini   = osc_io_fini
 		}
 	},
-	.req_op = {
-		 [CRT_READ] = {
-			 .cio_submit    = osc_io_submit
-		 },
-		 [CRT_WRITE] = {
-			 .cio_submit    = osc_io_submit
-		 }
-	 },
-	.cio_prepare_write = osc_io_prepare_write,
-	.cio_commit_write  = osc_io_commit_write
+	.cio_submit                 = osc_io_submit,
+	.cio_commit_async           = osc_io_commit_async
 };
 
 /*****************************************************************************
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 91ff607..eff3b4b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -89,8 +89,8 @@ static void osc_page_transfer_put(const struct lu_env *env,
 	struct cl_page *page = cl_page_top(opg->ops_cl.cpl_page);
 
 	if (opg->ops_transfer_pinned) {
-		lu_ref_del(&page->cp_reference, "transfer", page);
 		opg->ops_transfer_pinned = 0;
+		lu_ref_del(&page->cp_reference, "transfer", page);
 		cl_page_put(env, page);
 	}
 }
@@ -113,11 +113,9 @@ static void osc_page_transfer_add(const struct lu_env *env,
 	spin_unlock(&obj->oo_seatbelt);
 }
 
-static int osc_page_cache_add(const struct lu_env *env,
-			      const struct cl_page_slice *slice,
-			      struct cl_io *io)
+int osc_page_cache_add(const struct lu_env *env,
+		       const struct cl_page_slice *slice, struct cl_io *io)
 {
-	struct osc_io *oio = osc_env_io(env);
 	struct osc_page *opg = cl2osc_page(slice);
 	int result;
 
@@ -130,17 +128,6 @@ static int osc_page_cache_add(const struct lu_env *env,
 	else
 		osc_page_transfer_add(env, opg, CRT_WRITE);
 
-	/* for sync write, kernel will wait for this page to be flushed before
-	 * osc_io_end() is called, so release it earlier.
-	 * for mkwrite(), it's known there is no further pages.
-	 */
-	if (cl_io_is_sync_write(io) || cl_io_is_mkwrite(io)) {
-		if (oio->oi_active) {
-			osc_extent_release(env, oio->oi_active);
-			oio->oi_active = NULL;
-		}
-	}
-
 	return result;
 }
 
@@ -231,17 +218,6 @@ static void osc_page_completion_write(const struct lu_env *env,
 {
 }
 
-static int osc_page_fail(const struct lu_env *env,
-			 const struct cl_page_slice *slice,
-			 struct cl_io *unused)
-{
-	/*
-	 * Cached read?
-	 */
-	LBUG();
-	return 0;
-}
-
 static const char *osc_list(struct list_head *head)
 {
 	return list_empty(head) ? "-" : "+";
@@ -393,11 +369,9 @@ static const struct cl_page_operations osc_page_ops = {
 	.cpo_disown	= osc_page_disown,
 	.io = {
 		[CRT_READ] = {
-			.cpo_cache_add  = osc_page_fail,
 			.cpo_completion = osc_page_completion_read
 		},
 		[CRT_WRITE] = {
-			.cpo_cache_add  = osc_page_cache_add,
 			.cpo_completion = osc_page_completion_write
 		}
 	},
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c055511b3..1ff497f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1734,7 +1734,6 @@ static int brw_interpret(const struct lu_env *env,
 	struct osc_brw_async_args *aa = data;
 	struct osc_extent *ext;
 	struct osc_extent *tmp;
-	struct cl_object *obj = NULL;
 	struct client_obd *cli = aa->aa_cli;
 
 	rc = osc_brw_fini_request(req, rc);
@@ -1763,24 +1762,17 @@ static int brw_interpret(const struct lu_env *env,
 			rc = -EIO;
 	}
 
-	list_for_each_entry_safe(ext, tmp, &aa->aa_exts, oe_link) {
-		if (!obj && rc == 0) {
-			obj = osc2cl(ext->oe_obj);
-			cl_object_get(obj);
-		}
-
-		list_del_init(&ext->oe_link);
-		osc_extent_finish(env, ext, 1, rc);
-	}
-	LASSERT(list_empty(&aa->aa_exts));
-	LASSERT(list_empty(&aa->aa_oaps));
-
-	if (obj) {
+	if (rc == 0) {
 		struct obdo *oa = aa->aa_oa;
 		struct cl_attr *attr  = &osc_env_info(env)->oti_attr;
 		unsigned long valid = 0;
+		struct cl_object *obj;
+		struct osc_async_page *last;
+
+		last = brw_page2oap(aa->aa_ppga[aa->aa_page_count - 1]);
+		obj = osc2cl(last->oap_obj);
 
-		LASSERT(rc == 0);
+		cl_object_attr_lock(obj);
 		if (oa->o_valid & OBD_MD_FLBLOCKS) {
 			attr->cat_blocks = oa->o_blocks;
 			valid |= CAT_BLOCKS;
@@ -1797,15 +1789,39 @@ static int brw_interpret(const struct lu_env *env,
 			attr->cat_ctime = oa->o_ctime;
 			valid |= CAT_CTIME;
 		}
-		if (valid != 0) {
-			cl_object_attr_lock(obj);
-			cl_object_attr_set(env, obj, attr, valid);
-			cl_object_attr_unlock(obj);
+
+		if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE) {
+			struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
+			loff_t last_off = last->oap_count + last->oap_obj_off;
+
+			/* Change file size if this is an out of quota or
+			 * direct IO write and it extends the file size
+			 */
+			if (loi->loi_lvb.lvb_size < last_off) {
+				attr->cat_size = last_off;
+				valid |= CAT_SIZE;
+			}
+			/* Extend KMS if it's not a lockless write */
+			if (loi->loi_kms < last_off &&
+			    oap2osc_page(last)->ops_srvlock == 0) {
+				attr->cat_kms = last_off;
+				valid |= CAT_KMS;
+			}
 		}
-		cl_object_put(env, obj);
+
+		if (valid != 0)
+			cl_object_attr_set(env, obj, attr, valid);
+		cl_object_attr_unlock(obj);
 	}
 	kmem_cache_free(obdo_cachep, aa->aa_oa);
 
+	list_for_each_entry_safe(ext, tmp, &aa->aa_exts, oe_link) {
+		list_del_init(&ext->oe_link);
+		osc_extent_finish(env, ext, 1, rc);
+	}
+	LASSERT(list_empty(&aa->aa_exts));
+	LASSERT(list_empty(&aa->aa_oaps));
+
 	cl_req_completion(env, aa->aa_clerq, rc < 0 ? rc :
 			  req->rq_bulk->bd_nob_transferred);
 	osc_release_ppga(aa->aa_ppga, aa->aa_page_count);
-- 
2.1.0
