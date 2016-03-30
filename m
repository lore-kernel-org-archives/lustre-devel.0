From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:44 -0400
Subject: [lustre-devel] [PATCH 12/43] staging/lustre/clio: optimize read
	ahead code
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

It used to check each page in the readahead window is covered by
a lock underneath, now cpo_page_is_under_lock() provides @max_index
to help decide the maximum ra window. @max_index can be modified by
OSC to extend the maximum lock region, to align stripe boundary at
LOV, and to make sure the readahead region at least covers read
region at LLITE layer.

After this is done, usually readahead code calls
cpo_page_is_under_lock() for each stripe.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/8523
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   6 +-
 drivers/staging/lustre/lustre/include/lclient.h    |   2 -
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  28 ------
 .../staging/lustre/lustre/llite/llite_internal.h   |   7 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   1 +
 drivers/staging/lustre/lustre/llite/rw.c           | 103 ++++++++++++++-------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  23 +----
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  26 ++++--
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   1 +
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   2 +
 drivers/staging/lustre/lustre/lov/lov_io.c         |   2 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  13 +++
 drivers/staging/lustre/lustre/lov/lov_page.c       |  60 ++++++++++--
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |   4 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  39 ++++++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |   2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  10 +-
 18 files changed, 208 insertions(+), 123 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 5b65854..69b40f5 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -935,7 +935,7 @@ struct cl_page_operations {
 	 */
 	int (*cpo_is_under_lock)(const struct lu_env *env,
 				 const struct cl_page_slice *slice,
-				 struct cl_io *io);
+				 struct cl_io *io, pgoff_t *max);
 
 	/**
 	 * Optional debugging helper. Prints given page slice.
@@ -2674,7 +2674,7 @@ static inline void cl_device_fini(struct cl_device *d)
 }
 
 void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
-		       struct cl_object *obj,
+		       struct cl_object *obj, pgoff_t index,
 		       const struct cl_page_operations *ops);
 void cl_lock_slice_add(struct cl_lock *lock, struct cl_lock_slice *slice,
 		       struct cl_object *obj,
@@ -2826,7 +2826,7 @@ void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
 int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg);
 void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate);
 int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page);
+			  struct cl_page *page, pgoff_t *max_index);
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx);
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset);
 int cl_page_size(const struct cl_object *obj);
diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index c91fb01..a8c8788 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -299,8 +299,6 @@ int ccc_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  const struct cl_lock_operations *lkops);
 int ccc_object_glimpse(const struct lu_env *env,
 		       const struct cl_object *obj, struct ost_lvb *lvb);
-int ccc_page_is_under_lock(const struct lu_env *env,
-			   const struct cl_page_slice *slice, struct cl_io *io);
 int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice);
 int ccc_transient_page_prep(const struct lu_env *env,
 			    const struct cl_page_slice *slice,
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 55fa0da..e34d832 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -452,34 +452,6 @@ static void ccc_object_size_unlock(struct cl_object *obj)
  *
  */
 
-int ccc_page_is_under_lock(const struct lu_env *env,
-			   const struct cl_page_slice *slice,
-			   struct cl_io *io)
-{
-	struct ccc_io	*cio  = ccc_env_io(env);
-	struct cl_lock_descr *desc = &ccc_env_info(env)->cti_descr;
-	struct cl_page       *page = slice->cpl_page;
-
-	int result;
-
-	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE ||
-	    io->ci_type == CIT_FAULT) {
-		if (cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED) {
-			result = -EBUSY;
-		} else {
-			desc->cld_start = ccc_index(cl2ccc_page(slice));
-			desc->cld_end   = ccc_index(cl2ccc_page(slice));
-			desc->cld_obj   = page->cp_obj;
-			desc->cld_mode  = CLM_READ;
-			result = cl_queue_match(&io->ci_lockset.cls_done,
-						desc) ? -EBUSY : 0;
-		}
-	} else {
-		result = 0;
-	}
-	return result;
-}
-
 int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice)
 {
 	/*
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index bc83147..cd69173 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -328,6 +328,7 @@ enum ra_stat {
 	RA_STAT_EOF,
 	RA_STAT_MAX_IN_FLIGHT,
 	RA_STAT_WRONG_GRAB_PAGE,
+	RA_STAT_FAILED_REACH_END,
 	_NR_RA_STAT,
 };
 
@@ -702,8 +703,8 @@ int ll_writepages(struct address_space *, struct writeback_control *wbc);
 int ll_readpage(struct file *file, struct page *page);
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int ll_readahead(const struct lu_env *env, struct cl_io *io,
-		 struct ll_readahead_state *ras, struct address_space *mapping,
-		 struct cl_page_list *queue, int flags);
+		 struct cl_page_list *queue, struct ll_readahead_state *ras,
+		 bool hit);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
 struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage);
 void ll_cl_fini(struct ll_cl_context *lcc);
@@ -1074,7 +1075,7 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		struct ll_readahead_state *ras, unsigned long index,
 		unsigned hit);
 void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len);
-void ll_ra_stats_inc(struct address_space *mapping, enum ra_stat which);
+void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
 
 /* llite/llite_rmtacl.c */
 #ifdef CONFIG_FS_POSIX_ACL
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 9e8e61a..091144f 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -960,6 +960,7 @@ static const char *ra_stat_string[] = {
 	[RA_STAT_EOF] = "read-ahead to EOF",
 	[RA_STAT_MAX_IN_FLIGHT] = "hit max r-a issue",
 	[RA_STAT_WRONG_GRAB_PAGE] = "wrong page from grab_cache_page",
+	[RA_STAT_FAILED_REACH_END] = "failed to reach end"
 };
 
 int ldebugfs_register_mountpoint(struct dentry *parent,
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index b1375f1..ad15058 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -166,7 +166,7 @@ static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which);
  */
 static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 				     struct ra_io_arg *ria,
-				     unsigned long pages)
+				     unsigned long pages, unsigned long min)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	long ret;
@@ -206,6 +206,11 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 	}
 
 out:
+	if (ret < min) {
+		/* override ra limit for maximum performance */
+		atomic_add(min - ret, &ra->ra_cur_pages);
+		ret = min;
+	}
 	return ret;
 }
 
@@ -222,9 +227,9 @@ static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which)
 	lprocfs_counter_incr(sbi->ll_ra_stats, which);
 }
 
-void ll_ra_stats_inc(struct address_space *mapping, enum ra_stat which)
+void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 {
-	struct ll_sb_info *sbi = ll_i2sbi(mapping->host);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
 	ll_ra_stats_inc_sbi(sbi, which);
 }
@@ -290,7 +295,7 @@ void ll_ra_read_ex(struct file *f, struct ll_ra_read *rar)
 
 static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      struct cl_page_list *queue, struct cl_page *page,
-			      struct cl_object *clob)
+			      struct cl_object *clob, pgoff_t *max_index)
 {
 	struct page *vmpage = page->cp_vmpage;
 	struct ccc_page *cp;
@@ -301,8 +306,11 @@ static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 	lu_ref_add(&page->cp_reference, "ra", current);
 	cp = cl2ccc_page(cl_object_page_slice(clob, page));
 	if (!cp->cpg_defer_uptodate && !PageUptodate(vmpage)) {
-		rc = cl_page_is_under_lock(env, io, page);
-		if (rc == -EBUSY) {
+		CDEBUG(D_READA, "page index %lu, max_index: %lu\n",
+		       ccc_index(cp), *max_index);
+		if (*max_index == 0 || ccc_index(cp) > *max_index)
+			rc = cl_page_is_under_lock(env, io, page, max_index);
+		if (rc == 0) {
 			cp->cpg_defer_uptodate = 1;
 			cp->cpg_ra_used = 0;
 			cl_page_list_add(queue, page);
@@ -332,24 +340,25 @@ static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
  */
 static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      struct cl_page_list *queue,
-			      pgoff_t index, struct address_space *mapping)
+			      pgoff_t index, pgoff_t *max_index)
 {
+	struct cl_object *clob  = io->ci_obj;
+	struct inode     *inode = ccc_object_inode(clob);
 	struct page      *vmpage;
-	struct cl_object *clob  = ll_i2info(mapping->host)->lli_clob;
 	struct cl_page   *page;
 	enum ra_stat      which = _NR_RA_STAT; /* keep gcc happy */
 	int	       rc    = 0;
 	const char       *msg   = NULL;
 
-	vmpage = grab_cache_page_nowait(mapping, index);
+	vmpage = grab_cache_page_nowait(inode->i_mapping, index);
 	if (vmpage) {
 		/* Check if vmpage was truncated or reclaimed */
-		if (vmpage->mapping == mapping) {
+		if (vmpage->mapping == inode->i_mapping) {
 			page = cl_page_find(env, clob, vmpage->index,
 					    vmpage, CPT_CACHEABLE);
 			if (!IS_ERR(page)) {
 				rc = cl_read_ahead_page(env, io, queue,
-							page, clob);
+							page, clob, max_index);
 				if (rc == -ENOLCK) {
 					which = RA_STAT_FAILED_MATCH;
 					msg   = "lock match failed";
@@ -370,7 +379,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		msg   = "g_c_p_n failed";
 	}
 	if (msg) {
-		ll_ra_stats_inc(mapping, which);
+		ll_ra_stats_inc(inode, which);
 		CDEBUG(D_READA, "%s\n", msg);
 	}
 	return rc;
@@ -482,11 +491,12 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 			       struct cl_io *io, struct cl_page_list *queue,
 			       struct ra_io_arg *ria,
 			       unsigned long *reserved_pages,
-			       struct address_space *mapping,
 			       unsigned long *ra_end)
 {
-	int rc, count = 0, stride_ria;
-	unsigned long page_idx;
+	int rc, count = 0;
+	bool stride_ria;
+	pgoff_t page_idx;
+	pgoff_t max_index = 0;
 
 	LASSERT(ria);
 	RIA_DEBUG(ria);
@@ -497,7 +507,7 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 		if (ras_inside_ra_window(page_idx, ria)) {
 			/* If the page is inside the read-ahead window*/
 			rc = ll_read_ahead_page(env, io, queue,
-						page_idx, mapping);
+						page_idx, &max_index);
 			if (rc == 1) {
 				(*reserved_pages)--;
 				count++;
@@ -532,25 +542,23 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 }
 
 int ll_readahead(const struct lu_env *env, struct cl_io *io,
-		 struct ll_readahead_state *ras, struct address_space *mapping,
-		 struct cl_page_list *queue, int flags)
+		 struct cl_page_list *queue, struct ll_readahead_state *ras,
+		 bool hit)
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct vvp_thread_info *vti = vvp_env_info(env);
 	struct cl_attr *attr = ccc_env_thread_attr(env);
 	unsigned long start = 0, end = 0, reserved;
-	unsigned long ra_end, len;
+	unsigned long ra_end, len, mlen = 0;
 	struct inode *inode;
 	struct ll_ra_read *bead;
 	struct ra_io_arg *ria = &vti->vti_ria;
-	struct ll_inode_info *lli;
 	struct cl_object *clob;
 	int ret = 0;
 	__u64 kms;
 
-	inode = mapping->host;
-	lli = ll_i2info(inode);
-	clob = lli->lli_clob;
+	clob = io->ci_obj;
+	inode = ccc_object_inode(clob);
 
 	memset(ria, 0, sizeof(*ria));
 
@@ -562,7 +570,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		return ret;
 	kms = attr->cat_kms;
 	if (kms == 0) {
-		ll_ra_stats_inc(mapping, RA_STAT_ZERO_LEN);
+		ll_ra_stats_inc(inode, RA_STAT_ZERO_LEN);
 		return 0;
 	}
 
@@ -621,29 +629,48 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	spin_unlock(&ras->ras_lock);
 
 	if (end == 0) {
-		ll_ra_stats_inc(mapping, RA_STAT_ZERO_WINDOW);
+		ll_ra_stats_inc(inode, RA_STAT_ZERO_WINDOW);
 		return 0;
 	}
 	len = ria_page_count(ria);
-	if (len == 0)
+	if (len == 0) {
+		ll_ra_stats_inc(inode, RA_STAT_ZERO_WINDOW);
 		return 0;
+	}
+
+	CDEBUG(D_READA, DFID ": ria: %lu/%lu, bead: %lu/%lu, hit: %d\n",
+	       PFID(lu_object_fid(&clob->co_lu)),
+	       ria->ria_start, ria->ria_end,
+	       !bead ? 0 : bead->lrr_start,
+	       !bead ? 0 : bead->lrr_count,
+	       hit);
+
+	/* at least to extend the readahead window to cover current read */
+	if (!hit && bead &&
+	    bead->lrr_start + bead->lrr_count > ria->ria_start) {
+		/* to the end of current read window. */
+		mlen = bead->lrr_start + bead->lrr_count - ria->ria_start;
+		/* trim to RPC boundary */
+		start = ria->ria_start & (PTLRPC_MAX_BRW_PAGES - 1);
+		mlen = min(mlen, PTLRPC_MAX_BRW_PAGES - start);
+	}
 
-	reserved = ll_ra_count_get(ll_i2sbi(inode), ria, len);
+	reserved = ll_ra_count_get(ll_i2sbi(inode), ria, len, mlen);
 	if (reserved < len)
-		ll_ra_stats_inc(mapping, RA_STAT_MAX_IN_FLIGHT);
+		ll_ra_stats_inc(inode, RA_STAT_MAX_IN_FLIGHT);
 
-	CDEBUG(D_READA, "reserved page %lu ra_cur %d ra_max %lu\n", reserved,
+	CDEBUG(D_READA, "reserved pages %lu/%lu/%lu, ra_cur %d, ra_max %lu\n",
+	       reserved, len, mlen,
 	       atomic_read(&ll_i2sbi(inode)->ll_ra_info.ra_cur_pages),
 	       ll_i2sbi(inode)->ll_ra_info.ra_max_pages);
 
-	ret = ll_read_ahead_pages(env, io, queue,
-				  ria, &reserved, mapping, &ra_end);
+	ret = ll_read_ahead_pages(env, io, queue, ria, &reserved, &ra_end);
 
 	if (reserved != 0)
 		ll_ra_count_put(ll_i2sbi(inode), reserved);
 
 	if (ra_end == end + 1 && ra_end == (kms >> PAGE_CACHE_SHIFT))
-		ll_ra_stats_inc(mapping, RA_STAT_EOF);
+		ll_ra_stats_inc(inode, RA_STAT_EOF);
 
 	/* if we didn't get to the end of the region we reserved from
 	 * the ras we need to go back and update the ras so that the
@@ -655,6 +682,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	       ra_end, end, ria->ria_end);
 
 	if (ra_end != end + 1) {
+		ll_ra_stats_inc(inode, RA_STAT_FAILED_REACH_END);
 		spin_lock(&ras->ras_lock);
 		if (ra_end < ras->ras_next_readahead &&
 		    index_in_window(ra_end, ras->ras_window_start, 0,
@@ -925,15 +953,18 @@ void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	ras->ras_last_readpage = index;
 	ras_set_start(inode, ras, index);
 
-	if (stride_io_mode(ras))
+	if (stride_io_mode(ras)) {
 		/* Since stride readahead is sensitive to the offset
 		 * of read-ahead, so we use original offset here,
 		 * instead of ras_window_start, which is RPC aligned
 		 */
 		ras->ras_next_readahead = max(index, ras->ras_next_readahead);
-	else
-		ras->ras_next_readahead = max(ras->ras_window_start,
-					      ras->ras_next_readahead);
+	} else {
+		if (ras->ras_next_readahead < ras->ras_window_start)
+			ras->ras_next_readahead = ras->ras_window_start;
+		if (!hit)
+			ras->ras_next_readahead = index + 1;
+	}
 	RAS_CDEBUG(ras);
 
 	/* Trigger RA in the mmap case where ras_consecutive_requests
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index ac9d615..18127d3 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1052,35 +1052,19 @@ static int vvp_io_read_page(const struct lu_env *env,
 			    const struct cl_page_slice *slice)
 {
 	struct cl_io	      *io     = ios->cis_io;
-	struct cl_object	  *obj    = slice->cpl_obj;
 	struct ccc_page	   *cp     = cl2ccc_page(slice);
 	struct cl_page	    *page   = slice->cpl_page;
-	struct inode	      *inode  = ccc_object_inode(obj);
+	struct inode	      *inode  = ccc_object_inode(slice->cpl_obj);
 	struct ll_sb_info	 *sbi    = ll_i2sbi(inode);
 	struct ll_file_data       *fd     = cl2ccc_io(env, ios)->cui_fd;
 	struct ll_readahead_state *ras    = &fd->fd_ras;
-	struct page		*vmpage = cp->cpg_page;
 	struct cl_2queue	  *queue  = &io->ci_queue;
-	int rc;
-
-	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
-	LASSERT(slice->cpl_obj == obj);
 
 	if (sbi->ll_ra_info.ra_max_pages_per_file &&
 	    sbi->ll_ra_info.ra_max_pages)
 		ras_update(sbi, inode, ras, ccc_index(cp),
 			   cp->cpg_defer_uptodate);
 
-	/* Sanity check whether the page is protected by a lock. */
-	rc = cl_page_is_under_lock(env, io, page);
-	if (rc != -EBUSY) {
-		CL_PAGE_HEADER(D_WARNING, env, page, "%s: %d\n",
-			       rc == -ENODATA ? "without a lock" :
-			       "match failed", rc);
-		if (rc != -ENODATA)
-			return rc;
-	}
-
 	if (cp->cpg_defer_uptodate) {
 		cp->cpg_ra_used = 1;
 		cl_page_export(env, page, 1);
@@ -1089,11 +1073,12 @@ static int vvp_io_read_page(const struct lu_env *env,
 	 * Add page into the queue even when it is marked uptodate above.
 	 * this will unlock it automatically as part of cl_page_list_disown().
 	 */
+
 	cl_page_list_add(&queue->c2_qin, page);
 	if (sbi->ll_ra_info.ra_max_pages_per_file &&
 	    sbi->ll_ra_info.ra_max_pages)
-		ll_readahead(env, io, ras,
-			     vmpage->mapping, &queue->c2_qin, fd->fd_flags);
+		ll_readahead(env, io, &queue->c2_qin, ras,
+			     cp->cpg_defer_uptodate);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index d9f13c3..3c6b723 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -142,7 +142,7 @@ static void vvp_page_discard(const struct lu_env *env,
 	LASSERT(PageLocked(vmpage));
 
 	if (cpg->cpg_defer_uptodate && !cpg->cpg_ra_used)
-		ll_ra_stats_inc(vmpage->mapping, RA_STAT_DISCARDED);
+		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
 
 	ll_invalidate_page(vmpage);
 }
@@ -357,6 +357,20 @@ static int vvp_page_make_ready(const struct lu_env *env,
 	return result;
 }
 
+static int vvp_page_is_under_lock(const struct lu_env *env,
+				  const struct cl_page_slice *slice,
+				  struct cl_io *io, pgoff_t *max_index)
+{
+	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE ||
+	    io->ci_type == CIT_FAULT) {
+		struct ccc_io *cio = ccc_env_io(env);
+
+		if (unlikely(cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED))
+			*max_index = CL_PAGE_EOF;
+	}
+	return 0;
+}
+
 static int vvp_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
@@ -389,7 +403,7 @@ static const struct cl_page_operations vvp_page_ops = {
 	.cpo_is_vmlocked   = vvp_page_is_vmlocked,
 	.cpo_fini	  = vvp_page_fini,
 	.cpo_print	 = vvp_page_print,
-	.cpo_is_under_lock = ccc_page_is_under_lock,
+	.cpo_is_under_lock = vvp_page_is_under_lock,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_page_prep_read,
@@ -495,7 +509,7 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 	.cpo_fini	  = vvp_transient_page_fini,
 	.cpo_is_vmlocked   = vvp_transient_page_is_vmlocked,
 	.cpo_print	 = vvp_page_print,
-	.cpo_is_under_lock = ccc_page_is_under_lock,
+	.cpo_is_under_lock	= vvp_page_is_under_lock,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= ccc_transient_page_prep,
@@ -516,7 +530,6 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
 
-	cpg->cpg_cl.cpl_index = index;
 	cpg->cpg_page = vmpage;
 	page_cache_get(vmpage);
 
@@ -526,12 +539,13 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		atomic_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
-		cl_page_slice_add(page, &cpg->cpg_cl, obj, &vvp_page_ops);
+		cl_page_slice_add(page, &cpg->cpg_cl, obj, index,
+				  &vvp_page_ops);
 	} else {
 		struct ccc_object *clobj = cl2ccc(obj);
 
 		LASSERT(!inode_trylock(clobj->cob_inode));
-		cl_page_slice_add(page, &cpg->cpg_cl, obj,
+		cl_page_slice_add(page, &cpg->cpg_cl, obj, index,
 				  &vvp_transient_page_ops);
 		clobj->cob_transient_pages++;
 	}
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index b8e2315..9b3d13b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -632,6 +632,7 @@ struct lov_lock_link *lov_lock_link_find(const struct lu_env *env,
 					 struct lovsub_lock *sub);
 struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
 				  const struct cl_page_slice *slice);
+int lov_page_stripe(const struct cl_page *page);
 
 #define lov_foreach_target(lov, var)		    \
 	for (var = 0; var < lov_targets_nr(lov); ++var)
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 590f932..9985855 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -146,6 +146,8 @@ int lov_stripe_intersects(struct lov_stripe_md *lsm, int stripeno,
 			  u64 start, u64 end,
 			  u64 *obd_start, u64 *obd_end);
 int lov_stripe_number(struct lov_stripe_md *lsm, u64 lov_off);
+pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
+			 int stripe);
 
 /* lov_qos.c */
 #define LOV_USES_ASSIGNED_STRIPE	0
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index e5b2cfc..ba79955 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -245,7 +245,7 @@ void lov_sub_put(struct lov_io_sub *sub)
  *
  */
 
-static int lov_page_stripe(const struct cl_page *page)
+int lov_page_stripe(const struct cl_page *page)
 {
 	struct lovsub_object *subobj;
 	const struct cl_page_slice *slice;
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index ae83eb0..cb7b516 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -66,6 +66,19 @@ u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno)
 	return lov_size;
 }
 
+/**
+ * Compute file level page index by stripe level page offset
+ */
+pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
+			 int stripe)
+{
+	loff_t offset;
+
+	offset = lov_stripe_size(lsm, stripe_index << PAGE_CACHE_SHIFT,
+				 stripe);
+	return offset >> PAGE_CACHE_SHIFT;
+}
+
 /* we have an offset in file backed by an lov and want to find out where
  * that offset lands in our given stripe of the file.  for the easy
  * case where the offset is within the stripe, we just have to scale the
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 0c508bd..9634c13 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -52,17 +52,57 @@
  * Lov page operations.
  *
  */
-static int lov_page_print(const struct lu_env *env,
-			  const struct cl_page_slice *slice,
-			  void *cookie, lu_printer_t printer)
+
+/**
+ * Adjust the stripe index by layout of raid0. @max_index is the maximum
+ * page index covered by an underlying DLM lock.
+ * This function converts max_index from stripe level to file level, and make
+ * sure it's not beyond one stripe.
+ */
+static int lov_raid0_page_is_under_lock(const struct lu_env *env,
+					const struct cl_page_slice *slice,
+					struct cl_io *unused,
+					pgoff_t *max_index)
+{
+	struct lov_object *loo = cl2lov(slice->cpl_obj);
+	struct lov_layout_raid0 *r0 = lov_r0(loo);
+	pgoff_t index = *max_index;
+	unsigned int pps; /* pages per stripe */
+
+	CDEBUG(D_READA, "*max_index = %lu, nr = %d\n", index, r0->lo_nr);
+	if (index == 0) /* the page is not covered by any lock */
+		return 0;
+
+	if (r0->lo_nr == 1) /* single stripe file */
+		return 0;
+
+	/* max_index is stripe level, convert it into file level */
+	if (index != CL_PAGE_EOF) {
+		int stripeno = lov_page_stripe(slice->cpl_page);
+		*max_index = lov_stripe_pgoff(loo->lo_lsm, index, stripeno);
+	}
+
+	/* calculate the end of current stripe */
+	pps = loo->lo_lsm->lsm_stripe_size >> PAGE_CACHE_SHIFT;
+	index = ((slice->cpl_index + pps) & ~(pps - 1)) - 1;
+
+	/* never exceed the end of the stripe */
+	*max_index = min_t(pgoff_t, *max_index, index);
+	return 0;
+}
+
+static int lov_raid0_page_print(const struct lu_env *env,
+				const struct cl_page_slice *slice,
+				void *cookie, lu_printer_t printer)
 {
 	struct lov_page *lp = cl2lov_page(slice);
 
-	return (*printer)(env, cookie, LUSTRE_LOV_NAME"-page@%p\n", lp);
+	return (*printer)(env, cookie, LUSTRE_LOV_NAME "-page@%p, raid0\n", lp);
 }
 
-static const struct cl_page_operations lov_page_ops = {
-	.cpo_print  = lov_page_print
+static const struct cl_page_operations lov_raid0_page_ops = {
+	.cpo_is_under_lock = lov_raid0_page_is_under_lock,
+	.cpo_print  = lov_raid0_page_print
 };
 
 int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
@@ -86,7 +126,7 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
-	cl_page_slice_add(page, &lpg->lps_cl, obj, &lov_page_ops);
+	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_raid0_page_ops);
 
 	sub = lov_sub_get(env, lio, stripe);
 	if (IS_ERR(sub))
@@ -107,7 +147,7 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	return rc;
 }
 
-static int lov_page_empty_print(const struct lu_env *env,
+static int lov_empty_page_print(const struct lu_env *env,
 				const struct cl_page_slice *slice,
 				void *cookie, lu_printer_t printer)
 {
@@ -118,7 +158,7 @@ static int lov_page_empty_print(const struct lu_env *env,
 }
 
 static const struct cl_page_operations lov_empty_page_ops = {
-	.cpo_print = lov_page_empty_print
+	.cpo_print = lov_empty_page_print
 };
 
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
@@ -127,7 +167,7 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	struct lov_page *lpg = cl_object_page_slice(obj, page);
 	void *addr;
 
-	cl_page_slice_add(page, &lpg->lps_cl, obj, &lov_empty_page_ops);
+	cl_page_slice_add(page, &lpg->lps_cl, obj, index, &lov_empty_page_ops);
 	addr = kmap(page->cp_vmpage);
 	memset(addr, 0, cl_page_size(obj));
 	kunmap(page->cp_vmpage);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
index fb4c0cc..9badedc 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_page.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_page.c
@@ -60,11 +60,11 @@ static const struct cl_page_operations lovsub_page_ops = {
 };
 
 int lovsub_page_init(const struct lu_env *env, struct cl_object *obj,
-		     struct cl_page *page, pgoff_t ind)
+		     struct cl_page *page, pgoff_t index)
 {
 	struct lovsub_page *lsb = cl_object_page_slice(obj, page);
 
-	cl_page_slice_add(page, &lsb->lsb_cl, obj, &lovsub_page_ops);
+	cl_page_slice_add(page, &lsb->lsb_cl, obj, index, &lovsub_page_ops);
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 86591ce..65d6cee 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -733,7 +733,7 @@ int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
 				break;
 		}
 	}
-	if (result == 0)
+	if (result == 0 && queue->c2_qin.pl_nr > 0)
 		result = cl_io_submit_rw(env, io, CRT_READ, queue);
 	/*
 	 * Unlock unsent pages in case of error.
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index cb15673..506a9f9 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -401,6 +401,30 @@ EXPORT_SYMBOL(cl_page_at);
 	__result;						       \
 })
 
+#define CL_PAGE_INVOKE_REVERSE(_env, _page, _op, _proto, ...)		\
+({									\
+	const struct lu_env        *__env  = (_env);			\
+	struct cl_page             *__page = (_page);			\
+	const struct cl_page_slice *__scan;				\
+	int                         __result;				\
+	ptrdiff_t                   __op   = (_op);			\
+	int                       (*__method)_proto;			\
+									\
+	__result = 0;							\
+	list_for_each_entry_reverse(__scan, &__page->cp_layers,		\
+					cpl_linkage) {			\
+		__method = *(void **)((char *)__scan->cpl_ops +  __op);	\
+		if (__method) {						\
+			__result = (*__method)(__env, __scan, ## __VA_ARGS__); \
+			if (__result != 0)				\
+				break;					\
+		}							\
+	}								\
+	if (__result > 0)						\
+		__result = 0;						\
+	__result;							\
+})
+
 #define CL_PAGE_INVOID(_env, _page, _op, _proto, ...)		   \
 do {								    \
 	const struct lu_env	*__env  = (_env);		    \
@@ -928,17 +952,17 @@ EXPORT_SYMBOL(cl_page_flush);
  * \see cl_page_operations::cpo_is_under_lock()
  */
 int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page)
+			  struct cl_page *page, pgoff_t *max_index)
 {
 	int rc;
 
 	PINVRNT(env, page, cl_page_invariant(page));
 
-	rc = CL_PAGE_INVOKE(env, page, CL_PAGE_OP(cpo_is_under_lock),
-			    (const struct lu_env *,
-			     const struct cl_page_slice *, struct cl_io *),
-			    io);
-	PASSERT(env, page, rc != 0);
+	rc = CL_PAGE_INVOKE_REVERSE(env, page, CL_PAGE_OP(cpo_is_under_lock),
+				    (const struct lu_env *,
+				     const struct cl_page_slice *,
+				      struct cl_io *, pgoff_t *),
+				    io, max_index);
 	return rc;
 }
 EXPORT_SYMBOL(cl_page_is_under_lock);
@@ -1041,11 +1065,12 @@ EXPORT_SYMBOL(cl_page_size);
  * \see cl_lock_slice_add(), cl_req_slice_add(), cl_io_slice_add()
  */
 void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
-		       struct cl_object *obj,
+		       struct cl_object *obj, pgoff_t index,
 		       const struct cl_page_operations *ops)
 {
 	list_add_tail(&slice->cpl_linkage, &page->cp_layers);
 	slice->cpl_obj  = obj;
+	slice->cpl_index = index;
 	slice->cpl_ops  = ops;
 	slice->cpl_page = page;
 }
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index db56081..0d84d04 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -365,7 +365,7 @@ static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	page_cache_get(page->cp_vmpage);
 	mutex_init(&ep->ep_lock);
-	cl_page_slice_add(page, &ep->ep_cl, obj, &echo_page_ops);
+	cl_page_slice_add(page, &ep->ep_cl, obj, index, &echo_page_ops);
 	atomic_inc(&eco->eo_npages);
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 3e0a8c3..e02dd33 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -132,17 +132,19 @@ void osc_index2policy(ldlm_policy_data_t *policy, const struct cl_object *obj,
 
 static int osc_page_is_under_lock(const struct lu_env *env,
 				  const struct cl_page_slice *slice,
-				  struct cl_io *unused)
+				  struct cl_io *unused, pgoff_t *max_index)
 {
 	struct osc_page *opg = cl2osc_page(slice);
 	struct cl_lock *lock;
 	int result = -ENODATA;
 
+	*max_index = 0;
 	lock = cl_lock_at_pgoff(env, slice->cpl_obj, osc_index(opg),
 				NULL, 1, 0);
 	if (lock) {
+		*max_index = lock->cll_descr.cld_end;
 		cl_lock_put(env, lock);
-		result = -EBUSY;
+		result = 0;
 	}
 	return result;
 }
@@ -308,7 +310,6 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	opg->ops_from = 0;
 	opg->ops_to = PAGE_CACHE_SIZE;
-	opg->ops_cl.cpl_index = index;
 
 	result = osc_prep_async_page(osc, opg, page->cp_vmpage,
 				     cl_offset(obj, index));
@@ -316,7 +317,8 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		struct osc_io *oio = osc_env_io(env);
 
 		opg->ops_srvlock = osc_io_srvlock(oio);
-		cl_page_slice_add(page, &opg->ops_cl, obj, &osc_page_ops);
+		cl_page_slice_add(page, &opg->ops_cl, obj, index,
+				  &osc_page_ops);
 	}
 	/*
 	 * Cannot assert osc_page_protected() here as read-ahead
-- 
2.1.0
