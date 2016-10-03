From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:01 -0400
Subject: [lustre-devel] [PATCH 05/41] staging: lustre: clio: Revise read
	ahead implementation
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In this implementation, read ahead will hold the underlying DLM lock
to add read ahead pages. A new cl_io operation cio_read_ahead() is
added for this purpose. It takes parameter cl_read_ahead{} so that
each layer can adjust it by their own requirements. For example, at
OSC layer, it will make sure the read ahead region is covered by a
LDLM lock; at the LOV layer, it will make sure that the region won't
cross stripe boundary.

Legacy callback cpo_is_under_lock() is removed.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3259
Reviewed-on: http://review.whamcloud.com/10859
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   63 +++---
 .../staging/lustre/lustre/llite/llite_internal.h   |    7 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  218 ++++++++++++--------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   47 ++---
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   16 --
 drivers/staging/lustre/lustre/lov/lov_io.c         |   58 +++++
 drivers/staging/lustre/lustre/lov/lov_page.c       |   46 ----
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   57 +----
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   47 -----
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    3 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   17 ++-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   41 ++++-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   12 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   20 --
 14 files changed, 312 insertions(+), 340 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 89292c9..bf93c1e 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -884,26 +884,6 @@ struct cl_page_operations {
 	/** Destructor. Frees resources and slice itself. */
 	void (*cpo_fini)(const struct lu_env *env,
 			 struct cl_page_slice *slice);
-
-	/**
-	 * Checks whether the page is protected by a cl_lock. This is a
-	 * per-layer method, because certain layers have ways to check for the
-	 * lock much more efficiently than through the generic locks scan, or
-	 * implement locking mechanisms separate from cl_lock, e.g.,
-	 * LL_FILE_GROUP_LOCKED in vvp. If \a pending is true, check for locks
-	 * being canceled, or scheduled for cancellation as soon as the last
-	 * user goes away, too.
-	 *
-	 * \retval    -EBUSY: page is protected by a lock of a given mode;
-	 * \retval  -ENODATA: page is not protected by a lock;
-	 * \retval	 0: this layer cannot decide.
-	 *
-	 * \see cl_page_is_under_lock()
-	 */
-	int (*cpo_is_under_lock)(const struct lu_env *env,
-				 const struct cl_page_slice *slice,
-				 struct cl_io *io, pgoff_t *max);
-
 	/**
 	 * Optional debugging helper. Prints given page slice.
 	 *
@@ -1365,7 +1345,6 @@ struct cl_2queue {
  *     (3) sort all locks to avoid dead-locks, and acquire them
  *
  *     (4) process the chunk: call per-page methods
- *	 (cl_io_operations::cio_read_page() for read,
  *	 cl_io_operations::cio_prepare_write(),
  *	 cl_io_operations::cio_commit_write() for write)
  *
@@ -1467,6 +1446,31 @@ struct cl_io_slice {
 
 typedef void (*cl_commit_cbt)(const struct lu_env *, struct cl_io *,
 			      struct cl_page *);
+
+struct cl_read_ahead {
+	/*
+	 * Maximum page index the readahead window will end.
+	 * This is determined DLM lock coverage, RPC and stripe boundary.
+	 * cra_end is included.
+	 */
+	pgoff_t cra_end;
+	/*
+	 * Release routine. If readahead holds resources underneath, this
+	 * function should be called to release it.
+	 */
+	void (*cra_release)(const struct lu_env *env, void *cbdata);
+	/* Callback data for cra_release routine */
+	void *cra_cbdata;
+};
+
+static inline void cl_read_ahead_release(const struct lu_env *env,
+					 struct cl_read_ahead *ra)
+{
+	if (ra->cra_release)
+		ra->cra_release(env, ra->cra_cbdata);
+	memset(ra, 0, sizeof(*ra));
+}
+
 /**
  * Per-layer io operations.
  * \see vvp_io_ops, lov_io_ops, lovsub_io_ops, osc_io_ops
@@ -1573,16 +1577,13 @@ struct cl_io_operations {
 				 struct cl_page_list *queue, int from, int to,
 				 cl_commit_cbt cb);
 	/**
-	 * Read missing page.
-	 *
-	 * Called by a top-level cl_io_operations::op[CIT_READ]::cio_start()
-	 * method, when it hits not-up-to-date page in the range. Optional.
+	 * Decide maximum read ahead extent
 	 *
 	 * \pre io->ci_type == CIT_READ
 	 */
-	int (*cio_read_page)(const struct lu_env *env,
-			     const struct cl_io_slice *slice,
-			     const struct cl_page_slice *page);
+	int (*cio_read_ahead)(const struct lu_env *env,
+			      const struct cl_io_slice *slice,
+			      pgoff_t start, struct cl_read_ahead *ra);
 	/**
 	 * Optional debugging helper. Print given io slice.
 	 */
@@ -2302,8 +2303,6 @@ void cl_page_discard(const struct lu_env *env, struct cl_io *io,
 void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
 int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg);
 void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate);
-int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page, pgoff_t *max_index);
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
 size_t cl_page_size(const struct cl_object *obj);
@@ -2414,8 +2413,6 @@ int cl_io_lock_add(const struct lu_env *env, struct cl_io *io,
 		   struct cl_io_lock_link *link);
 int cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
 			 struct cl_lock_descr *descr);
-int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
-		    struct cl_page *page);
 int cl_io_submit_rw(const struct lu_env *env, struct cl_io *io,
 		    enum cl_req_type iot, struct cl_2queue *queue);
 int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
@@ -2424,6 +2421,8 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
 		       struct cl_page_list *queue, int from, int to,
 		       cl_commit_cbt cb);
+int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
+		     pgoff_t start, struct cl_read_ahead *ra);
 int cl_io_is_going(const struct lu_env *env);
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd89926..b06cd3c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -722,9 +722,7 @@ int ll_writepage(struct page *page, struct writeback_control *wbc);
 int ll_writepages(struct address_space *, struct writeback_control *wbc);
 int ll_readpage(struct file *file, struct page *page);
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
-int ll_readahead(const struct lu_env *env, struct cl_io *io,
-		 struct cl_page_list *queue, struct ll_readahead_state *ras,
-		 bool hit);
+int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
 struct ll_cl_context *ll_cl_find(struct file *file);
 void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io);
 void ll_cl_remove(struct file *file, const struct lu_env *env);
@@ -1020,9 +1018,6 @@ int cl_sb_init(struct super_block *sb);
 int cl_sb_fini(struct super_block *sb);
 void ll_io_init(struct cl_io *io, const struct file *file, int write);
 
-void ras_update(struct ll_sb_info *sbi, struct inode *inode,
-		struct ll_readahead_state *ras, unsigned long index,
-		unsigned hit);
 void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len);
 void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 50c0152..80cb8e0 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -180,90 +180,73 @@ void ll_ras_enter(struct file *f)
 	spin_unlock(&ras->ras_lock);
 }
 
-static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
-			      struct cl_page_list *queue, struct cl_page *page,
-			      struct cl_object *clob, pgoff_t *max_index)
+/**
+ * Initiates read-ahead of a page with given index.
+ *
+ * \retval +ve:	page was already uptodate so it will be skipped
+ *		from being added;
+ * \retval -ve:	page wasn't added to \a queue for error;
+ * \retval   0:	page was added into \a queue for read ahead.
+ */
+static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
+			      struct cl_page_list *queue, pgoff_t index)
 {
-	struct page *vmpage = page->cp_vmpage;
+	enum ra_stat which = _NR_RA_STAT; /* keep gcc happy */
+	struct cl_object *clob = io->ci_obj;
+	struct inode *inode = vvp_object_inode(clob);
+	const char *msg = NULL;
+	struct cl_page *page;
 	struct vvp_page *vpg;
-	int	      rc;
+	struct page *vmpage;
+	int rc = 0;
+
+	vmpage = grab_cache_page_nowait(inode->i_mapping, index);
+	if (!vmpage) {
+		which = RA_STAT_FAILED_GRAB_PAGE;
+		msg = "g_c_p_n failed";
+		rc = -EBUSY;
+		goto out;
+	}
+
+	/* Check if vmpage was truncated or reclaimed */
+	if (vmpage->mapping != inode->i_mapping) {
+		which = RA_STAT_WRONG_GRAB_PAGE;
+		msg = "g_c_p_n returned invalid page";
+		rc = -EBUSY;
+		goto out;
+	}
+
+	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
+	if (IS_ERR(page)) {
+		which = RA_STAT_FAILED_GRAB_PAGE;
+		msg = "cl_page_find failed";
+		rc = PTR_ERR(page);
+		goto out;
+	}
 
-	rc = 0;
-	cl_page_assume(env, io, page);
 	lu_ref_add(&page->cp_reference, "ra", current);
+	cl_page_assume(env, io, page);
 	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
 	if (!vpg->vpg_defer_uptodate && !PageUptodate(vmpage)) {
-		CDEBUG(D_READA, "page index %lu, max_index: %lu\n",
-		       vvp_index(vpg), *max_index);
-		if (*max_index == 0 || vvp_index(vpg) > *max_index)
-			rc = cl_page_is_under_lock(env, io, page, max_index);
-		if (rc == 0) {
-			vpg->vpg_defer_uptodate = 1;
-			vpg->vpg_ra_used = 0;
-			cl_page_list_add(queue, page);
-			rc = 1;
-		} else {
-			cl_page_discard(env, io, page);
-			rc = -ENOLCK;
-		}
+		vpg->vpg_defer_uptodate = 1;
+		vpg->vpg_ra_used = 0;
+		cl_page_list_add(queue, page);
 	} else {
 		/* skip completed pages */
 		cl_page_unassume(env, io, page);
+		/* This page is already uptodate, returning a positive number
+		 * to tell the callers about this
+		 */
+		rc = 1;
 	}
+
 	lu_ref_del(&page->cp_reference, "ra", current);
 	cl_page_put(env, page);
-	return rc;
-}
-
-/**
- * Initiates read-ahead of a page with given index.
- *
- * \retval     +ve: page was added to \a queue.
- *
- * \retval -ENOLCK: there is no extent lock for this part of a file, stop
- *		  read-ahead.
- *
- * \retval  -ve, 0: page wasn't added to \a queue for other reason.
- */
-static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
-			      struct cl_page_list *queue,
-			      pgoff_t index, pgoff_t *max_index)
-{
-	struct cl_object *clob  = io->ci_obj;
-	struct inode     *inode = vvp_object_inode(clob);
-	struct page      *vmpage;
-	struct cl_page   *page;
-	enum ra_stat      which = _NR_RA_STAT; /* keep gcc happy */
-	int	       rc    = 0;
-	const char       *msg   = NULL;
-
-	vmpage = grab_cache_page_nowait(inode->i_mapping, index);
+out:
 	if (vmpage) {
-		/* Check if vmpage was truncated or reclaimed */
-		if (vmpage->mapping == inode->i_mapping) {
-			page = cl_page_find(env, clob, vmpage->index,
-					    vmpage, CPT_CACHEABLE);
-			if (!IS_ERR(page)) {
-				rc = cl_read_ahead_page(env, io, queue,
-							page, clob, max_index);
-				if (rc == -ENOLCK) {
-					which = RA_STAT_FAILED_MATCH;
-					msg   = "lock match failed";
-				}
-			} else {
-				which = RA_STAT_FAILED_GRAB_PAGE;
-				msg   = "cl_page_find failed";
-			}
-		} else {
-			which = RA_STAT_WRONG_GRAB_PAGE;
-			msg   = "g_c_p_n returned invalid page";
-		}
-		if (rc != 1)
+		if (rc)
 			unlock_page(vmpage);
 		put_page(vmpage);
-	} else {
-		which = RA_STAT_FAILED_GRAB_PAGE;
-		msg   = "g_c_p_n failed";
 	}
 	if (msg) {
 		ll_ra_stats_inc(inode, which);
@@ -378,12 +361,12 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 			       struct cl_io *io, struct cl_page_list *queue,
 			       struct ra_io_arg *ria,
 			       unsigned long *reserved_pages,
-			       unsigned long *ra_end)
+			       pgoff_t *ra_end)
 {
+	struct cl_read_ahead ra = { 0 };
 	int rc, count = 0;
 	bool stride_ria;
 	pgoff_t page_idx;
-	pgoff_t max_index = 0;
 
 	LASSERT(ria);
 	RIA_DEBUG(ria);
@@ -392,14 +375,23 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 	for (page_idx = ria->ria_start;
 	     page_idx <= ria->ria_end && *reserved_pages > 0; page_idx++) {
 		if (ras_inside_ra_window(page_idx, ria)) {
+			if (!ra.cra_end || ra.cra_end < page_idx) {
+				cl_read_ahead_release(env, &ra);
+
+				rc = cl_io_read_ahead(env, io, page_idx, &ra);
+				if (rc < 0)
+					break;
+
+				LASSERTF(ra.cra_end >= page_idx,
+					 "object: %p, indcies %lu / %lu\n",
+					 io->ci_obj, ra.cra_end, page_idx);
+			}
+
 			/* If the page is inside the read-ahead window*/
-			rc = ll_read_ahead_page(env, io, queue,
-						page_idx, &max_index);
-			if (rc == 1) {
+			rc = ll_read_ahead_page(env, io, queue, page_idx);
+			if (!rc) {
 				(*reserved_pages)--;
 				count++;
-			} else if (rc == -ENOLCK) {
-				break;
 			}
 		} else if (stride_ria) {
 			/* If it is not in the read-ahead window, and it is
@@ -425,19 +417,21 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 			}
 		}
 	}
+	cl_read_ahead_release(env, &ra);
+
 	*ra_end = page_idx;
 	return count;
 }
 
-int ll_readahead(const struct lu_env *env, struct cl_io *io,
-		 struct cl_page_list *queue, struct ll_readahead_state *ras,
-		 bool hit)
+static int ll_readahead(const struct lu_env *env, struct cl_io *io,
+			struct cl_page_list *queue,
+			struct ll_readahead_state *ras, bool hit)
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
 	struct cl_attr *attr = vvp_env_thread_attr(env);
-	unsigned long start = 0, end = 0, reserved;
-	unsigned long ra_end, len, mlen = 0;
+	unsigned long len, mlen = 0, reserved;
+	pgoff_t ra_end, start = 0, end = 0;
 	struct inode *inode;
 	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
@@ -575,8 +569,8 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	 * if the region we failed to issue read-ahead on is still ahead
 	 * of the app and behind the next index to start read-ahead from
 	 */
-	CDEBUG(D_READA, "ra_end %lu end %lu stride end %lu\n",
-	       ra_end, end, ria->ria_end);
+	CDEBUG(D_READA, "ra_end = %lu end = %lu stride end = %lu pages = %d\n",
+	       ra_end, end, ria->ria_end, ret);
 
 	if (ra_end != end + 1) {
 		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
@@ -737,9 +731,9 @@ static void ras_increase_window(struct inode *inode,
 					  ra->ra_max_pages_per_file);
 }
 
-void ras_update(struct ll_sb_info *sbi, struct inode *inode,
-		struct ll_readahead_state *ras, unsigned long index,
-		unsigned hit)
+static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
+		       struct ll_readahead_state *ras, unsigned long index,
+		       unsigned int hit)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	int zero = 0, stride_detect = 0, ra_miss = 0;
@@ -1087,6 +1081,56 @@ void ll_cl_remove(struct file *file, const struct lu_env *env)
 	write_unlock(&fd->fd_lock);
 }
 
+static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
+			   struct cl_page *page)
+{
+	struct inode *inode = vvp_object_inode(page->cp_obj);
+	struct ll_file_data *fd = vvp_env_io(env)->vui_fd;
+	struct ll_readahead_state *ras = &fd->fd_ras;
+	struct cl_2queue *queue  = &io->ci_queue;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct vvp_page *vpg;
+	int rc = 0;
+
+	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
+	if (sbi->ll_ra_info.ra_max_pages_per_file > 0 &&
+	    sbi->ll_ra_info.ra_max_pages > 0)
+		ras_update(sbi, inode, ras, vvp_index(vpg),
+			   vpg->vpg_defer_uptodate);
+
+	if (vpg->vpg_defer_uptodate) {
+		vpg->vpg_ra_used = 1;
+		cl_page_export(env, page, 1);
+	}
+
+	cl_2queue_init(queue);
+	/*
+	 * Add page into the queue even when it is marked uptodate above.
+	 * this will unlock it automatically as part of cl_page_list_disown().
+	 */
+	cl_page_list_add(&queue->c2_qin, page);
+	if (sbi->ll_ra_info.ra_max_pages_per_file > 0 &&
+	    sbi->ll_ra_info.ra_max_pages > 0) {
+		int rc2;
+
+		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
+				   vpg->vpg_defer_uptodate);
+		CDEBUG(D_READA, DFID "%d pages read ahead at %lu\n",
+		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
+	}
+
+	if (queue->c2_qin.pl_nr > 0)
+		rc = cl_io_submit_rw(env, io, CRT_READ, queue);
+
+	/*
+	 * Unlock unsent pages in case of error.
+	 */
+	cl_page_list_disown(env, io, &queue->c2_qin);
+	cl_2queue_fini(env, queue);
+
+	return rc;
+}
+
 int ll_readpage(struct file *file, struct page *vmpage)
 {
 	struct cl_object *clob = ll_i2info(file_inode(file))->lli_clob;
@@ -1110,7 +1154,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		LASSERT(page->cp_type == CPT_CACHEABLE);
 		if (likely(!PageUptodate(vmpage))) {
 			cl_page_assume(env, io, page);
-			result = cl_io_read_page(env, io, page);
+			result = ll_io_read_page(env, io, page);
 		} else {
 			/* Page from a non-object file. */
 			unlock_page(vmpage);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index dbc4c26..8187fa3 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1228,40 +1228,23 @@ static int vvp_io_fsync_start(const struct lu_env *env,
 	return 0;
 }
 
-static int vvp_io_read_page(const struct lu_env *env,
-			    const struct cl_io_slice *ios,
-			    const struct cl_page_slice *slice)
+static int vvp_io_read_ahead(const struct lu_env *env,
+			     const struct cl_io_slice *ios,
+			     pgoff_t start, struct cl_read_ahead *ra)
 {
-	struct cl_io	      *io     = ios->cis_io;
-	struct vvp_page           *vpg    = cl2vvp_page(slice);
-	struct cl_page	    *page   = slice->cpl_page;
-	struct inode              *inode  = vvp_object_inode(slice->cpl_obj);
-	struct ll_sb_info	 *sbi    = ll_i2sbi(inode);
-	struct ll_file_data       *fd     = cl2vvp_io(env, ios)->vui_fd;
-	struct ll_readahead_state *ras    = &fd->fd_ras;
-	struct cl_2queue	  *queue  = &io->ci_queue;
-
-	if (sbi->ll_ra_info.ra_max_pages_per_file &&
-	    sbi->ll_ra_info.ra_max_pages)
-		ras_update(sbi, inode, ras, vvp_index(vpg),
-			   vpg->vpg_defer_uptodate);
-
-	if (vpg->vpg_defer_uptodate) {
-		vpg->vpg_ra_used = 1;
-		cl_page_export(env, page, 1);
-	}
-	/*
-	 * Add page into the queue even when it is marked uptodate above.
-	 * this will unlock it automatically as part of cl_page_list_disown().
-	 */
+	int result = 0;
 
-	cl_page_list_add(&queue->c2_qin, page);
-	if (sbi->ll_ra_info.ra_max_pages_per_file &&
-	    sbi->ll_ra_info.ra_max_pages)
-		ll_readahead(env, io, &queue->c2_qin, ras,
-			     vpg->vpg_defer_uptodate);
+	if (ios->cis_io->ci_type == CIT_READ ||
+	    ios->cis_io->ci_type == CIT_FAULT) {
+		struct vvp_io *vio = cl2vvp_io(env, ios);
 
-	return 0;
+		if (unlikely(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
+			ra->cra_end = CL_PAGE_EOF;
+			result = 1; /* no need to call down */
+		}
+	}
+
+	return result;
 }
 
 static void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
@@ -1308,7 +1291,7 @@ static const struct cl_io_operations vvp_io_ops = {
 			.cio_fini   = vvp_io_fini
 		}
 	},
-	.cio_read_page     = vvp_io_read_page,
+	.cio_read_ahead	= vvp_io_read_ahead,
 };
 
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 68f8990..75cec23 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -342,20 +342,6 @@ static int vvp_page_make_ready(const struct lu_env *env,
 	return result;
 }
 
-static int vvp_page_is_under_lock(const struct lu_env *env,
-				  const struct cl_page_slice *slice,
-				  struct cl_io *io, pgoff_t *max_index)
-{
-	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE ||
-	    io->ci_type == CIT_FAULT) {
-		struct vvp_io *vio = vvp_env_io(env);
-
-		if (unlikely(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED))
-			*max_index = CL_PAGE_EOF;
-	}
-	return 0;
-}
-
 static int vvp_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
@@ -400,7 +386,6 @@ static const struct cl_page_operations vvp_page_ops = {
 	.cpo_is_vmlocked   = vvp_page_is_vmlocked,
 	.cpo_fini	  = vvp_page_fini,
 	.cpo_print	 = vvp_page_print,
-	.cpo_is_under_lock = vvp_page_is_under_lock,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_page_prep_read,
@@ -499,7 +484,6 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 	.cpo_fini	  = vvp_transient_page_fini,
 	.cpo_is_vmlocked   = vvp_transient_page_is_vmlocked,
 	.cpo_print	 = vvp_page_print,
-	.cpo_is_under_lock	= vvp_page_is_under_lock,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_transient_page_prep,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index d101579..e75e5d2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -555,6 +555,63 @@ static void lov_io_unlock(const struct lu_env *env,
 	LASSERT(rc == 0);
 }
 
+static int lov_io_read_ahead(const struct lu_env *env,
+			     const struct cl_io_slice *ios,
+			     pgoff_t start, struct cl_read_ahead *ra)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct lov_object *loo = lio->lis_object;
+	struct cl_object *obj = lov2cl(loo);
+	struct lov_layout_raid0 *r0 = lov_r0(loo);
+	unsigned int pps; /* pages per stripe */
+	struct lov_io_sub *sub;
+	pgoff_t ra_end;
+	loff_t suboff;
+	int stripe;
+	int rc;
+
+	stripe = lov_stripe_number(loo->lo_lsm, cl_offset(obj, start));
+	if (unlikely(!r0->lo_sub[stripe]))
+		return -EIO;
+
+	sub = lov_sub_get(env, lio, stripe);
+
+	lov_stripe_offset(loo->lo_lsm, cl_offset(obj, start), stripe, &suboff);
+	rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,
+			      cl_index(lovsub2cl(r0->lo_sub[stripe]), suboff),
+			      ra);
+	lov_sub_put(sub);
+
+	CDEBUG(D_READA, DFID " cra_end = %lu, stripes = %d, rc = %d\n",
+	       PFID(lu_object_fid(lov2lu(loo))), ra->cra_end, r0->lo_nr, rc);
+	if (rc)
+		return rc;
+
+	/**
+	 * Adjust the stripe index by layout of raid0. ra->cra_end is
+	 * the maximum page index covered by an underlying DLM lock.
+	 * This function converts cra_end from stripe level to file
+	 * level, and make sure it's not beyond stripe boundary.
+	 */
+	if (r0->lo_nr == 1)	/* single stripe file */
+		return 0;
+
+	/* cra_end is stripe level, convert it into file level */
+	ra_end = ra->cra_end;
+	if (ra_end != CL_PAGE_EOF)
+		ra_end = lov_stripe_pgoff(loo->lo_lsm, ra_end, stripe);
+
+	pps = loo->lo_lsm->lsm_stripe_size >> PAGE_SHIFT;
+
+	CDEBUG(D_READA, DFID " max_index = %lu, pps = %u, stripe_size = %u, stripe no = %u, start index = %lu\n",
+	       PFID(lu_object_fid(lov2lu(loo))), ra_end, pps,
+	       loo->lo_lsm->lsm_stripe_size, stripe, start);
+
+	/* never exceed the end of the stripe */
+	ra->cra_end = min_t(pgoff_t, ra_end, start + pps - start % pps - 1);
+	return 0;
+}
+
 /**
  * lov implementation of cl_operations::cio_submit() method. It takes a list
  * of pages in \a queue, splits it into per-stripe sub-lists, invokes
@@ -801,6 +858,7 @@ static const struct cl_io_operations lov_io_ops = {
 			.cio_fini   = lov_io_fini
 		}
 	},
+	.cio_read_ahead			= lov_io_read_ahead,
 	.cio_submit                    = lov_io_submit,
 	.cio_commit_async              = lov_io_commit_async,
 };
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 00bfaba..62ceb6d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -49,51 +49,6 @@
  *
  */
 
-/**
- * Adjust the stripe index by layout of raid0. @max_index is the maximum
- * page index covered by an underlying DLM lock.
- * This function converts max_index from stripe level to file level, and make
- * sure it's not beyond one stripe.
- */
-static int lov_raid0_page_is_under_lock(const struct lu_env *env,
-					const struct cl_page_slice *slice,
-					struct cl_io *unused,
-					pgoff_t *max_index)
-{
-	struct lov_object *loo = cl2lov(slice->cpl_obj);
-	struct lov_layout_raid0 *r0 = lov_r0(loo);
-	pgoff_t index = *max_index;
-	unsigned int pps; /* pages per stripe */
-
-	CDEBUG(D_READA, DFID "*max_index = %lu, nr = %d\n",
-	       PFID(lu_object_fid(lov2lu(loo))), index, r0->lo_nr);
-
-	if (index == 0) /* the page is not covered by any lock */
-		return 0;
-
-	if (r0->lo_nr == 1) /* single stripe file */
-		return 0;
-
-	/* max_index is stripe level, convert it into file level */
-	if (index != CL_PAGE_EOF) {
-		int stripeno = lov_page_stripe(slice->cpl_page);
-		*max_index = lov_stripe_pgoff(loo->lo_lsm, index, stripeno);
-	}
-
-	/* calculate the end of current stripe */
-	pps = loo->lo_lsm->lsm_stripe_size >> PAGE_SHIFT;
-	index = slice->cpl_index + pps - slice->cpl_index % pps - 1;
-
-	CDEBUG(D_READA, DFID "*max_index = %lu, index = %lu, pps = %u, stripe_size = %u, stripe no = %u, page index = %lu\n",
-	       PFID(lu_object_fid(lov2lu(loo))), *max_index, index, pps,
-	       loo->lo_lsm->lsm_stripe_size, lov_page_stripe(slice->cpl_page),
-	       slice->cpl_index);
-
-	/* never exceed the end of the stripe */
-	*max_index = min_t(pgoff_t, *max_index, index);
-	return 0;
-}
-
 static int lov_raid0_page_print(const struct lu_env *env,
 				const struct cl_page_slice *slice,
 				void *cookie, lu_printer_t printer)
@@ -104,7 +59,6 @@ static int lov_raid0_page_print(const struct lu_env *env,
 }
 
 static const struct cl_page_operations lov_raid0_page_ops = {
-	.cpo_is_under_lock = lov_raid0_page_is_under_lock,
 	.cpo_print  = lov_raid0_page_print
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index bc4b7b6..577f76e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -586,67 +586,32 @@ void cl_io_end(const struct lu_env *env, struct cl_io *io)
 }
 EXPORT_SYMBOL(cl_io_end);
 
-static const struct cl_page_slice *
-cl_io_slice_page(const struct cl_io_slice *ios, struct cl_page *page)
-{
-	const struct cl_page_slice *slice;
-
-	slice = cl_page_at(page, ios->cis_obj->co_lu.lo_dev->ld_type);
-	LINVRNT(slice);
-	return slice;
-}
-
 /**
- * Called by read io, when page has to be read from the server.
+ * Called by read io, to decide the readahead extent
  *
- * \see cl_io_operations::cio_read_page()
+ * \see cl_io_operations::cio_read_ahead()
  */
-int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
-		    struct cl_page *page)
+int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
+		     pgoff_t start, struct cl_read_ahead *ra)
 {
 	const struct cl_io_slice *scan;
-	struct cl_2queue	 *queue;
 	int		       result = 0;
 
 	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_FAULT);
-	LINVRNT(cl_page_is_owned(page, io));
 	LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
 	LINVRNT(cl_io_invariant(io));
 
-	queue = &io->ci_queue;
-
-	cl_2queue_init(queue);
-	/*
-	 * ->cio_read_page() methods called in the loop below are supposed to
-	 * never block waiting for network (the only subtle point is the
-	 * creation of new pages for read-ahead that might result in cache
-	 * shrinking, but currently only clean pages are shrunk and this
-	 * requires no network io).
-	 *
-	 * Should this ever starts blocking, retry loop would be needed for
-	 * "parallel io" (see CLO_REPEAT loops in cl_lock.c).
-	 */
 	cl_io_for_each(scan, io) {
-		if (scan->cis_iop->cio_read_page) {
-			const struct cl_page_slice *slice;
+		if (!scan->cis_iop->cio_read_ahead)
+			continue;
 
-			slice = cl_io_slice_page(scan, page);
-			LINVRNT(slice);
-			result = scan->cis_iop->cio_read_page(env, scan, slice);
-			if (result != 0)
-				break;
-		}
+		result = scan->cis_iop->cio_read_ahead(env, scan, start, ra);
+		if (result)
+			break;
 	}
-	if (result == 0 && queue->c2_qin.pl_nr > 0)
-		result = cl_io_submit_rw(env, io, CRT_READ, queue);
-	/*
-	 * Unlock unsent pages in case of error.
-	 */
-	cl_page_list_disown(env, io, &queue->c2_qin);
-	cl_2queue_fini(env, queue);
-	return result;
+	return result > 0 ? 0 : result;
 }
-EXPORT_SYMBOL(cl_io_read_page);
+EXPORT_SYMBOL(cl_io_read_ahead);
 
 /**
  * Commit a list of contiguous pages into writeback cache.
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 63973ba..40b7bee 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -390,30 +390,6 @@ EXPORT_SYMBOL(cl_page_at);
 	__result;						       \
 })
 
-#define CL_PAGE_INVOKE_REVERSE(_env, _page, _op, _proto, ...)		\
-({									\
-	const struct lu_env        *__env  = (_env);			\
-	struct cl_page             *__page = (_page);			\
-	const struct cl_page_slice *__scan;				\
-	int                         __result;				\
-	ptrdiff_t                   __op   = (_op);			\
-	int                       (*__method)_proto;			\
-									\
-	__result = 0;							\
-	list_for_each_entry_reverse(__scan, &__page->cp_layers,		\
-					cpl_linkage) {			\
-		__method = *(void **)((char *)__scan->cpl_ops +  __op);	\
-		if (__method) {						\
-			__result = (*__method)(__env, __scan, ## __VA_ARGS__); \
-			if (__result != 0)				\
-				break;					\
-		}							\
-	}								\
-	if (__result > 0)						\
-		__result = 0;						\
-	__result;							\
-})
-
 #define CL_PAGE_INVOID(_env, _page, _op, _proto, ...)		   \
 do {								    \
 	const struct lu_env	*__env  = (_env);		    \
@@ -927,29 +903,6 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 EXPORT_SYMBOL(cl_page_flush);
 
 /**
- * Checks whether page is protected by any extent lock is at least required
- * mode.
- *
- * \return the same as in cl_page_operations::cpo_is_under_lock() method.
- * \see cl_page_operations::cpo_is_under_lock()
- */
-int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page, pgoff_t *max_index)
-{
-	int rc;
-
-	PINVRNT(env, page, cl_page_invariant(page));
-
-	rc = CL_PAGE_INVOKE_REVERSE(env, page, CL_PAGE_OP(cpo_is_under_lock),
-				    (const struct lu_env *,
-				     const struct cl_page_slice *,
-				      struct cl_io *, pgoff_t *),
-				    io, max_index);
-	return rc;
-}
-EXPORT_SYMBOL(cl_page_is_under_lock);
-
-/**
  * Tells transfer engine that only part of a page is to be transmitted.
  *
  * \see cl_page_operations::cpo_clip()
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 4bbe219..b645957 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -3158,7 +3158,8 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 		struct cl_page *page = ops->ops_cl.cpl_page;
 
 		/* refresh non-overlapped index */
-		tmp = osc_dlmlock_at_pgoff(env, osc, index, 0, 0);
+		tmp = osc_dlmlock_at_pgoff(env, osc, index,
+					   OSC_DAP_FL_TEST_LOCK);
 		if (tmp) {
 			__u64 end = tmp->l_policy_data.l_extent.end;
 			/* Cache the first-non-overlapped index so as to skip
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 67fe0a2..9a61c9b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -199,8 +199,23 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req);
 void osc_dec_unstable_pages(struct ptlrpc_request *req);
 bool osc_over_unstable_soft_limit(struct client_obd *cli);
 
+/**
+ * Bit flags for osc_dlm_lock_at_pageoff().
+ */
+enum osc_dap_flags {
+	/**
+	 * Just check if the desired lock exists, it won't hold reference
+	 * count on lock.
+	 */
+	OSC_DAP_FL_TEST_LOCK	= BIT(0),
+	/**
+	 * Return the lock even if it is being canceled.
+	 */
+	OSC_DAP_FL_CANCELING	= BIT(1),
+};
+
 struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 				       struct osc_object *obj, pgoff_t index,
-				       int pending, int canceling);
+				       enum osc_dap_flags flags);
 
 #endif /* OSC_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 8a559cb..47c6371 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -88,6 +88,44 @@ static void osc_io_fini(const struct lu_env *env, const struct cl_io_slice *io)
 {
 }
 
+static void osc_read_ahead_release(const struct lu_env *env, void *cbdata)
+{
+	struct ldlm_lock *dlmlock = cbdata;
+	struct lustre_handle lockh;
+
+	ldlm_lock2handle(dlmlock, &lockh);
+	ldlm_lock_decref(&lockh, LCK_PR);
+	LDLM_LOCK_PUT(dlmlock);
+}
+
+static int osc_io_read_ahead(const struct lu_env *env,
+			     const struct cl_io_slice *ios,
+			     pgoff_t start, struct cl_read_ahead *ra)
+{
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct ldlm_lock *dlmlock;
+	int result = -ENODATA;
+
+	dlmlock = osc_dlmlock_at_pgoff(env, osc, start, 0);
+	if (dlmlock) {
+		if (dlmlock->l_req_mode != LCK_PR) {
+			struct lustre_handle lockh;
+
+			ldlm_lock2handle(dlmlock, &lockh);
+			ldlm_lock_addref(&lockh, LCK_PR);
+			ldlm_lock_decref(&lockh, dlmlock->l_req_mode);
+		}
+
+		ra->cra_end = cl_index(osc2cl(osc),
+				       dlmlock->l_policy_data.l_extent.end);
+		ra->cra_release = osc_read_ahead_release;
+		ra->cra_cbdata = dlmlock;
+		result = 0;
+	}
+
+	return result;
+}
+
 /**
  * An implementation of cl_io_operations::cio_io_submit() method for osc
  * layer. Iterates over pages in the in-queue, prepares each for io by calling
@@ -724,6 +762,7 @@ static const struct cl_io_operations osc_io_ops = {
 			.cio_fini   = osc_io_fini
 		}
 	},
+	.cio_read_ahead			= osc_io_read_ahead,
 	.cio_submit                 = osc_io_submit,
 	.cio_commit_async           = osc_io_commit_async
 };
@@ -798,7 +837,7 @@ static void osc_req_attr_set(const struct lu_env *env,
 				     struct cl_page, cp_flight);
 		opg = osc_cl_page_osc(apage, NULL);
 		lock = osc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
-					    1, 1);
+					    OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
 		if (!lock && !opg->ops_srvlock) {
 			struct ldlm_resource *res;
 			struct ldlm_res_id *resname;
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 39a8a58..a42cb98 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1180,7 +1180,7 @@ int osc_lock_init(const struct lu_env *env,
  */
 struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 				       struct osc_object *obj, pgoff_t index,
-				       int pending, int canceling)
+				       enum osc_dap_flags dap_flags)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct ldlm_res_id *resname = &info->oti_resname;
@@ -1194,9 +1194,10 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 	osc_index2policy(policy, osc2cl(obj), index, index);
 	policy->l_extent.gid = LDLM_GID_ANY;
 
-	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_TEST_LOCK;
-	if (pending)
-		flags |= LDLM_FL_CBPENDING;
+	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_CBPENDING;
+	if (dap_flags & OSC_DAP_FL_TEST_LOCK)
+		flags |= LDLM_FL_TEST_LOCK;
+
 	/*
 	 * It is fine to match any group lock since there could be only one
 	 * with a uniq gid and it conflicts with all other lock modes too
@@ -1204,7 +1205,8 @@ struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 again:
 	mode = ldlm_lock_match(osc_export(obj)->exp_obd->obd_namespace,
 			       flags, resname, LDLM_EXTENT, policy,
-			       LCK_PR | LCK_PW | LCK_GROUP, &lockh, canceling);
+			       LCK_PR | LCK_PW | LCK_GROUP, &lockh,
+			       dap_flags & OSC_DAP_FL_CANCELING);
 	if (mode != 0) {
 		lock = ldlm_handle2lock(&lockh);
 		/* RACE: the lock is cancelled so let's try again */
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 2a7a70a..399d36b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -117,25 +117,6 @@ void osc_index2policy(ldlm_policy_data_t *policy, const struct cl_object *obj,
 	policy->l_extent.end = cl_offset(obj, end + 1) - 1;
 }
 
-static int osc_page_is_under_lock(const struct lu_env *env,
-				  const struct cl_page_slice *slice,
-				  struct cl_io *unused, pgoff_t *max_index)
-{
-	struct osc_page *opg = cl2osc_page(slice);
-	struct ldlm_lock *dlmlock;
-	int result = -ENODATA;
-
-	dlmlock = osc_dlmlock_at_pgoff(env, cl2osc(slice->cpl_obj),
-				       osc_index(opg), 1, 0);
-	if (dlmlock) {
-		*max_index = cl_index(slice->cpl_obj,
-				      dlmlock->l_policy_data.l_extent.end);
-		LDLM_LOCK_PUT(dlmlock);
-		result = 0;
-	}
-	return result;
-}
-
 static const char *osc_list(struct list_head *head)
 {
 	return list_empty(head) ? "-" : "+";
@@ -276,7 +257,6 @@ static int osc_page_flush(const struct lu_env *env,
 static const struct cl_page_operations osc_page_ops = {
 	.cpo_print	 = osc_page_print,
 	.cpo_delete	= osc_page_delete,
-	.cpo_is_under_lock = osc_page_is_under_lock,
 	.cpo_clip	   = osc_page_clip,
 	.cpo_cancel	 = osc_page_cancel,
 	.cpo_flush	  = osc_page_flush
-- 
1.7.1
