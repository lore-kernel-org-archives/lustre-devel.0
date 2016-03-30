From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:32 -0400
Subject: [lustre-devel] [PATCH v2 11/46] staging/lustre/clio: remove
	stackable cl_page completely
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-12-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

From now on, cl_page becomes one to one mapping of vmpage.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7895
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  43 ++---
 drivers/staging/lustre/lustre/include/lclient.h    |   7 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  12 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +
 drivers/staging/lustre/lustre/llite/rw.c           |   7 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  35 +---
 drivers/staging/lustre/lustre/llite/vvp_internal.h |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  45 +++--
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  23 +--
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  14 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   8 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |  32 +++-
 drivers/staging/lustre/lustre/lov/lov_page.c       | 104 +++-------
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  63 +-----
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   4 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   | 213 +++++----------------
 .../staging/lustre/lustre/obdecho/echo_client.c    |  22 +--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  59 +++---
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  12 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  41 ++--
 drivers/staging/lustre/lustre/osc/osc_page.c       |  33 ++--
 22 files changed, 257 insertions(+), 528 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index c3865ec..5b65854 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -322,7 +322,7 @@ struct cl_object_operations {
 	 *	 to be used instead of newly created.
 	 */
 	int  (*coo_page_init)(const struct lu_env *env, struct cl_object *obj,
-			      struct cl_page *page, struct page *vmpage);
+				struct cl_page *page, pgoff_t index);
 	/**
 	 * Initialize lock slice for this layer. Called top-to-bottom through
 	 * every object layer when a new cl_lock is instantiated. Layer
@@ -460,10 +460,6 @@ struct cl_object_header {
 					co_lu.lo_linkage)
 /** @} cl_object */
 
-#ifndef pgoff_t
-#define pgoff_t unsigned long
-#endif
-
 #define CL_PAGE_EOF ((pgoff_t)~0ull)
 
 /** \addtogroup cl_page cl_page
@@ -727,16 +723,10 @@ struct cl_page {
 	atomic_t	     cp_ref;
 	/** An object this page is a part of. Immutable after creation. */
 	struct cl_object	*cp_obj;
-	/** Logical page index within the object. Immutable after creation. */
-	pgoff_t		  cp_index;
 	/** List of slices. Immutable after creation. */
 	struct list_head	       cp_layers;
-	/** Parent page, NULL for top-level page. Immutable after creation. */
-	struct cl_page	  *cp_parent;
-	/** Lower-layer page. NULL for bottommost page. Immutable after
-	 * creation.
-	 */
-	struct cl_page	  *cp_child;
+	/** vmpage */
+	struct page		*cp_vmpage;
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
 	 * modified only internally within cl_page.c. Protected by a VM lock.
@@ -791,6 +781,7 @@ struct cl_page {
  */
 struct cl_page_slice {
 	struct cl_page		  *cpl_page;
+	pgoff_t				 cpl_index;
 	/**
 	 * Object slice corresponding to this page slice. Immutable after
 	 * creation.
@@ -846,11 +837,6 @@ struct cl_page_operations {
 	 */
 
 	/**
-	 * \return the underlying VM page. Optional.
-	 */
-	struct page *(*cpo_vmpage)(const struct lu_env *env,
-				   const struct cl_page_slice *slice);
-	/**
 	 * Called when \a io acquires this page into the exclusive
 	 * ownership. When this method returns, it is guaranteed that the is
 	 * not owned by other io, and no transfer is going on against
@@ -1102,6 +1088,12 @@ static inline int __page_in_use(const struct cl_page *page, int refc)
 #define cl_page_in_use(pg)       __page_in_use(pg, 1)
 #define cl_page_in_use_noref(pg) __page_in_use(pg, 0)
 
+static inline struct page *cl_page_vmpage(struct cl_page *page)
+{
+	LASSERT(page->cp_vmpage);
+	return page->cp_vmpage;
+}
+
 /** @} cl_page */
 
 /** \addtogroup cl_lock cl_lock
@@ -2729,7 +2721,7 @@ static inline int cl_object_same(struct cl_object *o0, struct cl_object *o1)
 static inline void cl_object_page_init(struct cl_object *clob, int size)
 {
 	clob->co_slice_off = cl_object_header(clob)->coh_page_bufsize;
-	cl_object_header(clob)->coh_page_bufsize += ALIGN(size, 8);
+	cl_object_header(clob)->coh_page_bufsize += cfs_size_round(size);
 }
 
 static inline void *cl_object_page_slice(struct cl_object *clob,
@@ -2774,9 +2766,7 @@ void cl_page_print(const struct lu_env *env, void *cookie, lu_printer_t printer,
 		   const struct cl_page *pg);
 void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg);
-struct page *cl_page_vmpage(const struct lu_env *env, struct cl_page *page);
 struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj);
-struct cl_page *cl_page_top(struct cl_page *page);
 
 const struct cl_page_slice *cl_page_at(const struct cl_page *page,
 				       const struct lu_device_type *dtype);
@@ -2868,17 +2858,6 @@ struct cl_lock *cl_lock_at_pgoff(const struct lu_env *env,
 				 struct cl_object *obj, pgoff_t index,
 				 struct cl_lock *except, int pending,
 				 int canceld);
-static inline struct cl_lock *cl_lock_at_page(const struct lu_env *env,
-					      struct cl_object *obj,
-					      struct cl_page *page,
-					      struct cl_lock *except,
-					      int pending, int canceld)
-{
-	LASSERT(cl_object_header(obj) == cl_object_header(page->cp_obj));
-	return cl_lock_at_pgoff(env, obj, page->cp_index, except,
-				pending, canceld);
-}
-
 const struct cl_lock_slice *cl_lock_at(const struct cl_lock *lock,
 				       const struct lu_device_type *dtype);
 
diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index 6c3a30a..c91fb01 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -238,6 +238,11 @@ static inline struct ccc_page *cl2ccc_page(const struct cl_page_slice *slice)
 	return container_of(slice, struct ccc_page, cpg_cl);
 }
 
+static inline pgoff_t ccc_index(struct ccc_page *ccc)
+{
+	return ccc->cpg_cl.cpl_index;
+}
+
 struct ccc_device {
 	struct cl_device    cdv_cl;
 	struct super_block *cdv_sb;
@@ -294,8 +299,6 @@ int ccc_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  const struct cl_lock_operations *lkops);
 int ccc_object_glimpse(const struct lu_env *env,
 		       const struct cl_object *obj, struct ost_lvb *lvb);
-struct page *ccc_page_vmpage(const struct lu_env *env,
-			    const struct cl_page_slice *slice);
 int ccc_page_is_under_lock(const struct lu_env *env,
 			   const struct cl_page_slice *slice, struct cl_io *io);
 int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 065b0f2..55fa0da 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -336,6 +336,8 @@ struct lu_object *ccc_object_alloc(const struct lu_env *env,
 		obj = ccc2lu(vob);
 		hdr = &vob->cob_header;
 		cl_object_header_init(hdr);
+		hdr->coh_page_bufsize = cfs_size_round(sizeof(struct cl_page));
+
 		lu_object_init(obj, &hdr->coh_lu, dev);
 		lu_object_add_top(&hdr->coh_lu, obj);
 
@@ -450,12 +452,6 @@ static void ccc_object_size_unlock(struct cl_object *obj)
  *
  */
 
-struct page *ccc_page_vmpage(const struct lu_env *env,
-			     const struct cl_page_slice *slice)
-{
-	return cl2vm_page(slice);
-}
-
 int ccc_page_is_under_lock(const struct lu_env *env,
 			   const struct cl_page_slice *slice,
 			   struct cl_io *io)
@@ -471,8 +467,8 @@ int ccc_page_is_under_lock(const struct lu_env *env,
 		if (cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED) {
 			result = -EBUSY;
 		} else {
-			desc->cld_start = page->cp_index;
-			desc->cld_end   = page->cp_index;
+			desc->cld_start = ccc_index(cl2ccc_page(slice));
+			desc->cld_end   = ccc_index(cl2ccc_page(slice));
 			desc->cld_obj   = page->cp_obj;
 			desc->cld_mode  = CLM_READ;
 			result = cl_queue_match(&io->ci_lockset.cls_done,
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 08fe0ea..bc83147 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -982,6 +982,10 @@ static inline void ll_invalidate_page(struct page *vmpage)
 	if (!mapping)
 		return;
 
+	/*
+	 * truncate_complete_page() calls
+	 * a_ops->invalidatepage()->cl_page_delete()->vvp_page_delete().
+	 */
 	ll_teardown_mmaps(mapping, offset, offset + PAGE_CACHE_SIZE);
 	truncate_complete_page(mapping, vmpage);
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index dcccdec..b1375f1 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -290,15 +290,16 @@ void ll_ra_read_ex(struct file *f, struct ll_ra_read *rar)
 
 static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      struct cl_page_list *queue, struct cl_page *page,
-			      struct page *vmpage)
+			      struct cl_object *clob)
 {
+	struct page *vmpage = page->cp_vmpage;
 	struct ccc_page *cp;
 	int	      rc;
 
 	rc = 0;
 	cl_page_assume(env, io, page);
 	lu_ref_add(&page->cp_reference, "ra", current);
-	cp = cl2ccc_page(cl_page_at(page, &vvp_device_type));
+	cp = cl2ccc_page(cl_object_page_slice(clob, page));
 	if (!cp->cpg_defer_uptodate && !PageUptodate(vmpage)) {
 		rc = cl_page_is_under_lock(env, io, page);
 		if (rc == -EBUSY) {
@@ -348,7 +349,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 					    vmpage, CPT_CACHEABLE);
 			if (!IS_ERR(page)) {
 				rc = cl_read_ahead_page(env, io, queue,
-							page, vmpage);
+							page, clob);
 				if (rc == -ENOLCK) {
 					which = RA_STAT_FAILED_MATCH;
 					msg   = "lock match failed";
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index e8d29e1..e2fea8c 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -165,28 +165,6 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	return result;
 }
 
-static int ll_set_page_dirty(struct page *vmpage)
-{
-#if 0
-	struct cl_page    *page = vvp_vmpage_page_transient(vmpage);
-	struct vvp_object *obj  = cl_inode2vvp(vmpage->mapping->host);
-	struct vvp_page   *cpg;
-
-	/*
-	 * XXX should page method be called here?
-	 */
-	LASSERT(&obj->co_cl == page->cp_obj);
-	cpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
-	/*
-	 * XXX cannot do much here, because page is possibly not locked:
-	 * sys_munmap()->...
-	 *     ->unmap_page_range()->zap_pte_range()->set_page_dirty().
-	 */
-	vvp_write_pending(obj, cpg);
-#endif
-	return __set_page_dirty_nobuffers(vmpage);
-}
-
 #define MAX_DIRECTIO_SIZE (2*1024*1024*1024UL)
 
 static inline int ll_get_user_pages(int rw, unsigned long user_addr,
@@ -274,7 +252,7 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 		 * write directly
 		 */
 		if (clp->cp_type == CPT_CACHEABLE) {
-			struct page *vmpage = cl_page_vmpage(env, clp);
+			struct page *vmpage = cl_page_vmpage(clp);
 			struct page *src_page;
 			struct page *dst_page;
 			void       *src;
@@ -478,19 +456,16 @@ out:
 static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 				   struct cl_page *pg)
 {
-	struct cl_object *obj  = io->ci_obj;
 	struct cl_attr *attr   = ccc_env_thread_attr(env);
-	loff_t          offset = cl_offset(obj, pg->cp_index);
+	struct cl_object *obj  = io->ci_obj;
+	struct ccc_page *cp    = cl_object_page_slice(obj, pg);
+	loff_t          offset = cl_offset(obj, ccc_index(cp));
 	int             result;
 
 	cl_object_attr_lock(obj);
 	result = cl_object_attr_get(env, obj, attr);
 	cl_object_attr_unlock(obj);
 	if (result == 0) {
-		struct ccc_page *cp;
-
-		cp = cl2ccc_page(cl_page_at(pg, &vvp_device_type));
-
 		/*
 		 * If are writing to a new page, no need to read old data.
 		 * The extent locking will have updated the KMS, and for our
@@ -685,7 +660,7 @@ const struct address_space_operations ll_aops = {
 	.direct_IO      = ll_direct_IO_26,
 	.writepage      = ll_writepage,
 	.writepages     = ll_writepages,
-	.set_page_dirty = ll_set_page_dirty,
+	.set_page_dirty = __set_page_dirty_nobuffers,
 	.write_begin    = ll_write_begin,
 	.write_end      = ll_write_end,
 	.invalidatepage = ll_invalidatepage,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 9abde11..aa06f40 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -49,7 +49,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io);
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, struct page *vmpage);
+		  struct cl_page *page, pgoff_t index);
 struct lu_object *vvp_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index f4a1384..ac9d615 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -625,7 +625,7 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 
 			cl_page_clip(env, page, 0, PAGE_SIZE);
 
-			SetPageUptodate(cl_page_vmpage(env, page));
+			SetPageUptodate(cl_page_vmpage(page));
 			cl_page_disown(env, io, page);
 
 			/* held in ll_cl_init() */
@@ -640,17 +640,15 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 				  struct cl_page *page)
 {
-	const struct cl_page_slice *slice;
 	struct ccc_page *cp;
-	struct page *vmpage;
-
-	slice = cl_page_at(page, &vvp_device_type);
-	cp = cl2ccc_page(slice);
-	vmpage = cp->cpg_page;
+	struct page *vmpage = page->cp_vmpage;
+	struct cl_object *clob = cl_io_top(io)->ci_obj;
 
 	SetPageUptodate(vmpage);
 	set_page_dirty(vmpage);
-	vvp_write_pending(cl2ccc(slice->cpl_obj), cp);
+
+	cp = cl2ccc_page(cl_object_page_slice(clob, page));
+	vvp_write_pending(cl2ccc(clob), cp);
 
 	cl_page_disown(env, io, page);
 
@@ -660,19 +658,22 @@ static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 }
 
 /* make sure the page list is contiguous */
-static bool page_list_sanity_check(struct cl_page_list *plist)
+static bool page_list_sanity_check(struct cl_object *obj,
+				   struct cl_page_list *plist)
 {
 	struct cl_page *page;
 	pgoff_t index = CL_PAGE_EOF;
 
 	cl_page_list_for_each(page, plist) {
+		struct ccc_page *cp = cl_object_page_slice(obj, page);
+
 		if (index == CL_PAGE_EOF) {
-			index = page->cp_index;
+			index = ccc_index(cp);
 			continue;
 		}
 
 		++index;
-		if (index == page->cp_index)
+		if (index == ccc_index(cp))
 			continue;
 
 		return false;
@@ -698,7 +699,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 	CDEBUG(D_VFSTRACE, "commit async pages: %d, from %d, to %d\n",
 	       npages, cio->u.write.cui_from, cio->u.write.cui_to);
 
-	LASSERT(page_list_sanity_check(queue));
+	LASSERT(page_list_sanity_check(obj, queue));
 
 	/* submit IO with async write */
 	rc = cl_io_commit_async(env, io, queue,
@@ -723,7 +724,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 		/* the first page must have been written. */
 		cio->u.write.cui_from = 0;
 	}
-	LASSERT(page_list_sanity_check(queue));
+	LASSERT(page_list_sanity_check(obj, queue));
 	LASSERT(ergo(rc == 0, queue->pl_nr == 0));
 
 	/* out of quota, try sync write */
@@ -747,7 +748,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 		page = cl_page_list_first(queue);
 		cl_page_list_del(env, queue, page);
 
-		if (!PageDirty(cl_page_vmpage(env, page)))
+		if (!PageDirty(cl_page_vmpage(page)))
 			cl_page_discard(env, io, page);
 
 		cl_page_disown(env, io, page);
@@ -861,16 +862,13 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
 				    struct cl_page *page)
 {
-	const struct cl_page_slice *slice;
 	struct ccc_page *cp;
-	struct page *vmpage;
+	struct cl_object *clob = cl_io_top(io)->ci_obj;
 
-	slice = cl_page_at(page, &vvp_device_type);
-	cp = cl2ccc_page(slice);
-	vmpage = cp->cpg_page;
+	set_page_dirty(page->cp_vmpage);
 
-	set_page_dirty(vmpage);
-	vvp_write_pending(cl2ccc(slice->cpl_obj), cp);
+	cp = cl2ccc_page(cl_object_page_slice(clob, page));
+	vvp_write_pending(cl2ccc(clob), cp);
 }
 
 static int vvp_io_fault_start(const struct lu_env *env,
@@ -975,6 +973,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 		wait_on_page_writeback(vmpage);
 		if (!PageDirty(vmpage)) {
 			struct cl_page_list *plist = &io->ci_queue.c2_qin;
+			struct ccc_page *cp = cl_object_page_slice(obj, page);
 			int to = PAGE_SIZE;
 
 			/* vvp_page_assume() calls wait_on_page_writeback(). */
@@ -984,7 +983,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 			cl_page_list_add(plist, page);
 
 			/* size fixup */
-			if (last_index == page->cp_index)
+			if (last_index == ccc_index(cp))
 				to = size & ~PAGE_MASK;
 
 			/* Do not set Dirty bit here so that in case IO is
@@ -1069,7 +1068,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 
 	if (sbi->ll_ra_info.ra_max_pages_per_file &&
 	    sbi->ll_ra_info.ra_max_pages)
-		ras_update(sbi, inode, ras, page->cp_index,
+		ras_update(sbi, inode, ras, ccc_index(cp),
 			   cp->cpg_defer_uptodate);
 
 	/* Sanity check whether the page is protected by a lock. */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 11e609e..d9f13c3 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -136,26 +136,15 @@ static void vvp_page_discard(const struct lu_env *env,
 			     struct cl_io *unused)
 {
 	struct page	   *vmpage  = cl2vm_page(slice);
-	struct address_space *mapping;
 	struct ccc_page      *cpg     = cl2ccc_page(slice);
-	__u64 offset;
 
 	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
 
-	mapping = vmpage->mapping;
-
 	if (cpg->cpg_defer_uptodate && !cpg->cpg_ra_used)
-		ll_ra_stats_inc(mapping, RA_STAT_DISCARDED);
-
-	offset = vmpage->index << PAGE_SHIFT;
-	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_SIZE);
+		ll_ra_stats_inc(vmpage->mapping, RA_STAT_DISCARDED);
 
-	/*
-	 * truncate_complete_page() calls
-	 * a_ops->invalidatepage()->cl_page_delete()->vvp_page_delete().
-	 */
-	truncate_complete_page(mapping, vmpage);
+	ll_invalidate_page(vmpage);
 }
 
 static void vvp_page_delete(const struct lu_env *env,
@@ -269,7 +258,7 @@ static void vvp_page_completion_read(const struct lu_env *env,
 {
 	struct ccc_page *cp     = cl2ccc_page(slice);
 	struct page      *vmpage = cp->cpg_page;
-	struct cl_page  *page   = cl_page_top(slice->cpl_page);
+	struct cl_page  *page   = slice->cpl_page;
 	struct inode    *inode  = ccc_object_inode(page->cp_obj);
 
 	LASSERT(PageLocked(vmpage));
@@ -394,7 +383,6 @@ static const struct cl_page_operations vvp_page_ops = {
 	.cpo_assume	= vvp_page_assume,
 	.cpo_unassume      = vvp_page_unassume,
 	.cpo_disown	= vvp_page_disown,
-	.cpo_vmpage	= ccc_page_vmpage,
 	.cpo_discard       = vvp_page_discard,
 	.cpo_delete	= vvp_page_delete,
 	.cpo_export	= vvp_page_export,
@@ -504,7 +492,6 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 	.cpo_unassume      = vvp_transient_page_unassume,
 	.cpo_disown	= vvp_transient_page_disown,
 	.cpo_discard       = vvp_transient_page_discard,
-	.cpo_vmpage	= ccc_page_vmpage,
 	.cpo_fini	  = vvp_transient_page_fini,
 	.cpo_is_vmlocked   = vvp_transient_page_is_vmlocked,
 	.cpo_print	 = vvp_page_print,
@@ -522,12 +509,14 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 };
 
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, struct page *vmpage)
+		struct cl_page *page, pgoff_t index)
 {
 	struct ccc_page *cpg = cl_object_page_slice(obj, page);
+	struct page     *vmpage = page->cp_vmpage;
 
 	CLOBINVRNT(env, obj, ccc_object_invariant(obj));
 
+	cpg->cpg_cl.cpl_index = index;
 	cpg->cpg_page = vmpage;
 	page_cache_get(vmpage);
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 3d568fc..b8e2315 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -613,14 +613,13 @@ int lov_sublock_modify(const struct lu_env *env, struct lov_lock *lov,
 		       const struct cl_lock_descr *d, int idx);
 
 int lov_page_init(const struct lu_env *env, struct cl_object *ob,
-		  struct cl_page *page, struct page *vmpage);
+		  struct cl_page *page, pgoff_t index);
 int lovsub_page_init(const struct lu_env *env, struct cl_object *ob,
-		     struct cl_page *page, struct page *vmpage);
-
+		     struct cl_page *page, pgoff_t index);
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, struct page *vmpage);
+			struct cl_page *page, pgoff_t index);
 int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, struct page *vmpage);
+			struct cl_page *page, pgoff_t index);
 struct lu_object *lov_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
@@ -791,11 +790,6 @@ static inline struct lovsub_req *cl2lovsub_req(const struct cl_req_slice *slice)
 	return container_of0(slice, struct lovsub_req, lsrq_cl);
 }
 
-static inline struct cl_page *lov_sub_page(const struct cl_page_slice *slice)
-{
-	return slice->cpl_page->cp_child;
-}
-
 static inline struct lov_io *cl2lov_io(const struct lu_env *env,
 				       const struct cl_io_slice *ios)
 {
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index c606490..e5b2cfc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -248,10 +248,12 @@ void lov_sub_put(struct lov_io_sub *sub)
 static int lov_page_stripe(const struct cl_page *page)
 {
 	struct lovsub_object *subobj;
+	const struct cl_page_slice *slice;
 
-	subobj = lu2lovsub(
-		lu_object_locate(page->cp_child->cp_obj->co_lu.lo_header,
-				 &lovsub_device_type));
+	slice = cl_page_at(page, &lovsub_device_type);
+	LASSERT(slice->cpl_obj);
+
+	subobj = cl2lovsub(slice->cpl_obj);
 	return subobj->lso_index;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 5d8a2b6..0159b6f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -67,7 +67,7 @@ struct lov_layout_operations {
 	int  (*llo_print)(const struct lu_env *env, void *cookie,
 			  lu_printer_t p, const struct lu_object *o);
 	int  (*llo_page_init)(const struct lu_env *env, struct cl_object *obj,
-			      struct cl_page *page, struct page *vmpage);
+			      struct cl_page *page, pgoff_t index);
 	int  (*llo_lock_init)(const struct lu_env *env,
 			      struct cl_object *obj, struct cl_lock *lock,
 			      const struct cl_io *io);
@@ -193,6 +193,18 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	return result;
 }
 
+static int lov_page_slice_fixup(struct lov_object *lov,
+				struct cl_object *stripe)
+{
+	struct cl_object_header *hdr = cl_object_header(&lov->lo_cl);
+	struct cl_object *o;
+
+	cl_object_for_each(o, stripe)
+		o->co_slice_off += hdr->coh_page_bufsize;
+
+	return cl_object_header(stripe)->coh_page_bufsize;
+}
+
 static int lov_init_raid0(const struct lu_env *env,
 			  struct lov_device *dev, struct lov_object *lov,
 			  const struct cl_object_conf *conf,
@@ -222,6 +234,8 @@ static int lov_init_raid0(const struct lu_env *env,
 	r0->lo_sub = libcfs_kvzalloc(r0->lo_nr * sizeof(r0->lo_sub[0]),
 				     GFP_NOFS);
 	if (r0->lo_sub) {
+		int psz = 0;
+
 		result = 0;
 		subconf->coc_inode = conf->coc_inode;
 		spin_lock_init(&r0->lo_sub_lock);
@@ -254,11 +268,21 @@ static int lov_init_raid0(const struct lu_env *env,
 				if (result == -EAGAIN) { /* try again */
 					--i;
 					result = 0;
+					continue;
 				}
 			} else {
 				result = PTR_ERR(stripe);
 			}
+
+			if (result == 0) {
+				int sz = lov_page_slice_fixup(lov, stripe);
+
+				LASSERT(ergo(psz > 0, psz == sz));
+				psz = sz;
+			}
 		}
+		if (result == 0)
+			cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
 	} else
 		result = -ENOMEM;
 out:
@@ -824,10 +848,10 @@ static int lov_object_print(const struct lu_env *env, void *cookie,
 }
 
 int lov_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, struct page *vmpage)
+		  struct cl_page *page, pgoff_t index)
 {
-	return LOV_2DISPATCH_NOLOCK(cl2lov(obj),
-				    llo_page_init, env, obj, page, vmpage);
+	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_page_init, env, obj, page,
+				    index);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 5d9b355..0c508bd 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -52,59 +52,6 @@
  * Lov page operations.
  *
  */
-
-static int lov_page_invariant(const struct cl_page_slice *slice)
-{
-	const struct cl_page  *page = slice->cpl_page;
-	const struct cl_page  *sub  = lov_sub_page(slice);
-
-	return ergo(sub,
-		    page->cp_child == sub &&
-		    sub->cp_parent == page &&
-		    page->cp_state == sub->cp_state);
-}
-
-static void lov_page_fini(const struct lu_env *env,
-			  struct cl_page_slice *slice)
-{
-	struct cl_page  *sub = lov_sub_page(slice);
-
-	LINVRNT(lov_page_invariant(slice));
-
-	if (sub) {
-		LASSERT(sub->cp_state == CPS_FREEING);
-		lu_ref_del(&sub->cp_reference, "lov", sub->cp_parent);
-		sub->cp_parent = NULL;
-		slice->cpl_page->cp_child = NULL;
-		cl_page_put(env, sub);
-	}
-}
-
-static int lov_page_own(const struct lu_env *env,
-			const struct cl_page_slice *slice, struct cl_io *io,
-			int nonblock)
-{
-	struct lov_io     *lio = lov_env_io(env);
-	struct lov_io_sub *sub;
-
-	LINVRNT(lov_page_invariant(slice));
-	LINVRNT(!cl2lov_page(slice)->lps_invalid);
-
-	sub = lov_page_subio(env, lio, slice);
-	if (!IS_ERR(sub)) {
-		lov_sub_page(slice)->cp_owner = sub->sub_io;
-		lov_sub_put(sub);
-	} else
-		LBUG(); /* Arrgh */
-	return 0;
-}
-
-static void lov_page_assume(const struct lu_env *env,
-			    const struct cl_page_slice *slice, struct cl_io *io)
-{
-	lov_page_own(env, slice, io, 0);
-}
-
 static int lov_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
@@ -115,26 +62,17 @@ static int lov_page_print(const struct lu_env *env,
 }
 
 static const struct cl_page_operations lov_page_ops = {
-	.cpo_fini   = lov_page_fini,
-	.cpo_own    = lov_page_own,
-	.cpo_assume = lov_page_assume,
 	.cpo_print  = lov_page_print
 };
 
-static void lov_empty_page_fini(const struct lu_env *env,
-				struct cl_page_slice *slice)
-{
-	LASSERT(!slice->cpl_page->cp_child);
-}
-
 int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, struct page *vmpage)
+			struct cl_page *page, pgoff_t index)
 {
 	struct lov_object *loo = cl2lov(obj);
 	struct lov_layout_raid0 *r0 = lov_r0(loo);
 	struct lov_io     *lio = lov_env_io(env);
-	struct cl_page    *subpage;
 	struct cl_object  *subobj;
+	struct cl_object  *o;
 	struct lov_io_sub *sub;
 	struct lov_page   *lpg = cl_object_page_slice(obj, page);
 	loff_t	     offset;
@@ -142,13 +80,12 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	int		stripe;
 	int		rc;
 
-	offset = cl_offset(obj, page->cp_index);
+	offset = cl_offset(obj, index);
 	stripe = lov_stripe_number(loo->lo_lsm, offset);
 	LASSERT(stripe < r0->lo_nr);
 	rc = lov_stripe_offset(loo->lo_lsm, offset, stripe, &suboff);
 	LASSERT(rc == 0);
 
-	lpg->lps_invalid = 1;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, &lov_page_ops);
 
 	sub = lov_sub_get(env, lio, stripe);
@@ -156,35 +93,44 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 		return PTR_ERR(sub);
 
 	subobj = lovsub2cl(r0->lo_sub[stripe]);
-	subpage = cl_page_alloc(sub->sub_env, subobj, cl_index(subobj, suboff),
-				vmpage, page->cp_type);
-	if (!IS_ERR(subpage)) {
-		subpage->cp_parent = page;
-		page->cp_child = subpage;
-		lpg->lps_invalid = 0;
-	} else {
-		rc = PTR_ERR(subpage);
+	list_for_each_entry(o, &subobj->co_lu.lo_header->loh_layers,
+			    co_lu.lo_linkage) {
+		if (o->co_ops->coo_page_init) {
+			rc = o->co_ops->coo_page_init(sub->sub_env, o, page,
+						      cl_index(subobj, suboff));
+			if (rc != 0)
+				break;
+		}
 	}
 	lov_sub_put(sub);
 
 	return rc;
 }
 
+static int lov_page_empty_print(const struct lu_env *env,
+				const struct cl_page_slice *slice,
+				void *cookie, lu_printer_t printer)
+{
+	struct lov_page *lp = cl2lov_page(slice);
+
+	return (*printer)(env, cookie, LUSTRE_LOV_NAME "-page@%p, empty.\n",
+			  lp);
+}
+
 static const struct cl_page_operations lov_empty_page_ops = {
-	.cpo_fini   = lov_empty_page_fini,
-	.cpo_print  = lov_page_print
+	.cpo_print = lov_page_empty_print
 };
 
 int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, struct page *vmpage)
+			struct cl_page *page, pgoff_t index)
 {
 	struct lov_page *lpg = cl_object_page_slice(obj, page);
 	void *addr;
 
 	cl_page_slice_add(page, &lpg->lps_cl, obj, &lov_empty_page_ops);
-	addr = kmap(vmpage);
+	addr = kmap(page->cp_vmpage);
 	memset(addr, 0, cl_page_size(obj));
-	kunmap(vmpage);
+	kunmap(page->cp_vmpage);
 	cl_page_export(env, page, 1);
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
index 2d94553..fb4c0cc 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_page.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_page.c
@@ -60,7 +60,7 @@ static const struct cl_page_operations lovsub_page_ops = {
 };
 
 int lovsub_page_init(const struct lu_env *env, struct cl_object *obj,
-		     struct cl_page *page, struct page *unused)
+		     struct cl_page *page, pgoff_t ind)
 {
 	struct lovsub_page *lsb = cl_object_page_slice(obj, page);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 9b3c5c1..86591ce 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -693,42 +693,6 @@ cl_io_slice_page(const struct cl_io_slice *ios, struct cl_page *page)
 }
 
 /**
- * True iff \a page is within \a io range.
- */
-static int cl_page_in_io(const struct cl_page *page, const struct cl_io *io)
-{
-	int     result = 1;
-	loff_t  start;
-	loff_t  end;
-	pgoff_t idx;
-
-	idx = page->cp_index;
-	switch (io->ci_type) {
-	case CIT_READ:
-	case CIT_WRITE:
-		/*
-		 * check that [start, end) and [pos, pos + count) extents
-		 * overlap.
-		 */
-		if (!cl_io_is_append(io)) {
-			const struct cl_io_rw_common *crw = &(io->u.ci_rw);
-
-			start = cl_offset(page->cp_obj, idx);
-			end   = cl_offset(page->cp_obj, idx + 1);
-			result = crw->crw_pos < end &&
-				 start < crw->crw_pos + crw->crw_count;
-		}
-		break;
-	case CIT_FAULT:
-		result = io->u.ci_fault.ft_index == idx;
-		break;
-	default:
-		LBUG();
-	}
-	return result;
-}
-
-/**
  * Called by read io, when page has to be read from the server.
  *
  * \see cl_io_operations::cio_read_page()
@@ -743,7 +707,6 @@ int cl_io_read_page(const struct lu_env *env, struct cl_io *io,
 	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_FAULT);
 	LINVRNT(cl_page_is_owned(page, io));
 	LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
-	LINVRNT(cl_page_in_io(page, io));
 	LINVRNT(cl_io_invariant(io));
 
 	queue = &io->ci_queue;
@@ -893,7 +856,6 @@ static int cl_io_cancel(const struct lu_env *env, struct cl_io *io,
 	cl_page_list_for_each(page, queue) {
 		int rc;
 
-		LINVRNT(cl_page_in_io(page, io));
 		rc = cl_page_cancel(env, page);
 		result = result ?: rc;
 	}
@@ -1229,7 +1191,7 @@ EXPORT_SYMBOL(cl_2queue_init_page);
 /**
  * Returns top-level io.
  *
- * \see cl_object_top(), cl_page_top().
+ * \see cl_object_top()
  */
 struct cl_io *cl_io_top(struct cl_io *io)
 {
@@ -1292,19 +1254,14 @@ static int cl_req_init(const struct lu_env *env, struct cl_req *req,
 	int result;
 
 	result = 0;
-	page = cl_page_top(page);
-	do {
-		list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
-			dev = lu2cl_dev(slice->cpl_obj->co_lu.lo_dev);
-			if (dev->cd_ops->cdo_req_init) {
-				result = dev->cd_ops->cdo_req_init(env,
-								   dev, req);
-				if (result != 0)
-					break;
-			}
+	list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
+		dev = lu2cl_dev(slice->cpl_obj->co_lu.lo_dev);
+		if (dev->cd_ops->cdo_req_init) {
+			result = dev->cd_ops->cdo_req_init(env, dev, req);
+			if (result != 0)
+				break;
 		}
-		page = page->cp_child;
-	} while (page && result == 0);
+	}
 	return result;
 }
 
@@ -1375,8 +1332,6 @@ void cl_req_page_add(const struct lu_env *env,
 	struct cl_req_obj *rqo;
 	int i;
 
-	page = cl_page_top(page);
-
 	LASSERT(list_empty(&page->cp_flight));
 	LASSERT(!page->cp_req);
 
@@ -1407,8 +1362,6 @@ void cl_req_page_done(const struct lu_env *env, struct cl_page *page)
 {
 	struct cl_req *req = page->cp_req;
 
-	page = cl_page_top(page);
-
 	LASSERT(!list_empty(&page->cp_flight));
 	LASSERT(req->crq_nrpages > 0);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index fa9b083..72e6333 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -84,7 +84,7 @@ int cl_object_header_init(struct cl_object_header *h)
 		lockdep_set_class(&h->coh_lock_guard, &cl_lock_guard_class);
 		lockdep_set_class(&h->coh_attr_guard, &cl_attr_guard_class);
 		INIT_LIST_HEAD(&h->coh_locks);
-		h->coh_page_bufsize = ALIGN(sizeof(struct cl_page), 8);
+		h->coh_page_bufsize = 0;
 	}
 	return result;
 }
@@ -138,7 +138,7 @@ EXPORT_SYMBOL(cl_object_get);
 /**
  * Returns the top-object for a given \a o.
  *
- * \see cl_page_top(), cl_io_top()
+ * \see cl_io_top()
  */
 struct cl_object *cl_object_top(struct cl_object *o)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 0844a97..cb15673 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -63,18 +63,6 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg);
 	((void)sizeof(env), (void)sizeof(page), (void)sizeof !!(exp))
 
 /**
- * Internal version of cl_page_top, it should be called if the page is
- * known to be not freed, says with page referenced, or radix tree lock held,
- * or page owned.
- */
-static struct cl_page *cl_page_top_trusted(struct cl_page *page)
-{
-	while (page->cp_parent)
-		page = page->cp_parent;
-	return page;
-}
-
-/**
  * Internal version of cl_page_get().
  *
  * This function can be used to obtain initial reference to previously
@@ -102,14 +90,10 @@ cl_page_at_trusted(const struct cl_page *page,
 {
 	const struct cl_page_slice *slice;
 
-	page = cl_page_top_trusted((struct cl_page *)page);
-	do {
-		list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
-			if (slice->cpl_obj->co_lu.lo_dev->ld_type == dtype)
-				return slice;
-		}
-		page = page->cp_child;
-	} while (page);
+	list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
+		if (slice->cpl_obj->co_lu.lo_dev->ld_type == dtype)
+			return slice;
+	}
 	return NULL;
 }
 
@@ -120,7 +104,6 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 	PASSERT(env, page, list_empty(&page->cp_batch));
 	PASSERT(env, page, !page->cp_owner);
 	PASSERT(env, page, !page->cp_req);
-	PASSERT(env, page, !page->cp_parent);
 	PASSERT(env, page, page->cp_state == CPS_FREEING);
 
 	while (!list_empty(&page->cp_layers)) {
@@ -129,7 +112,8 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 		slice = list_entry(page->cp_layers.next,
 				   struct cl_page_slice, cpl_linkage);
 		list_del_init(page->cp_layers.next);
-		slice->cpl_ops->cpo_fini(env, slice);
+		if (unlikely(slice->cpl_ops->cpo_fini))
+			slice->cpl_ops->cpo_fini(env, slice);
 	}
 	lu_object_ref_del_at(&obj->co_lu, &page->cp_obj_ref, "cl_page", page);
 	cl_object_put(env, obj);
@@ -165,7 +149,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		cl_object_get(o);
 		lu_object_ref_add_at(&o->co_lu, &page->cp_obj_ref, "cl_page",
 				     page);
-		page->cp_index = ind;
+		page->cp_vmpage = vmpage;
 		cl_page_state_set_trust(page, CPS_CACHED);
 		page->cp_type = type;
 		INIT_LIST_HEAD(&page->cp_layers);
@@ -176,8 +160,8 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		head = o->co_lu.lo_header;
 		list_for_each_entry(o, &head->loh_layers, co_lu.lo_linkage) {
 			if (o->co_ops->coo_page_init) {
-				result = o->co_ops->coo_page_init(env, o,
-								  page, vmpage);
+				result = o->co_ops->coo_page_init(env, o, page,
+								  ind);
 				if (result != 0) {
 					cl_page_delete0(env, page);
 					cl_page_free(env, page);
@@ -249,27 +233,12 @@ EXPORT_SYMBOL(cl_page_find);
 
 static inline int cl_page_invariant(const struct cl_page *pg)
 {
-	struct cl_page	  *parent;
-	struct cl_page	  *child;
-	struct cl_io	    *owner;
-
 	/*
 	 * Page invariant is protected by a VM lock.
 	 */
 	LINVRNT(cl_page_is_vmlocked(NULL, pg));
 
-	parent = pg->cp_parent;
-	child  = pg->cp_child;
-	owner  = pg->cp_owner;
-
-	return cl_page_in_use(pg) &&
-		ergo(parent, parent->cp_child == pg) &&
-		ergo(child, child->cp_parent == pg) &&
-		ergo(child, pg->cp_obj != child->cp_obj) &&
-		ergo(parent, pg->cp_obj != parent->cp_obj) &&
-		ergo(owner && parent,
-		     parent->cp_owner == pg->cp_owner->ci_parent) &&
-		ergo(owner && child, child->cp_owner->ci_parent == owner);
+	return cl_page_in_use_noref(pg);
 }
 
 static void cl_page_state_set0(const struct lu_env *env,
@@ -322,13 +291,9 @@ static void cl_page_state_set0(const struct lu_env *env,
 	old = page->cp_state;
 	PASSERT(env, page, allowed_transitions[old][state]);
 	CL_PAGE_HEADER(D_TRACE, env, page, "%d -> %d\n", old, state);
-	for (; page; page = page->cp_child) {
-		PASSERT(env, page, page->cp_state == old);
-		PASSERT(env, page,
-			equi(state == CPS_OWNED, page->cp_owner));
-
-		cl_page_state_set_trust(page, state);
-	}
+	PASSERT(env, page, page->cp_state == old);
+	PASSERT(env, page, equi(state == CPS_OWNED, page->cp_owner));
+	cl_page_state_set_trust(page, state);
 }
 
 static void cl_page_state_set(const struct lu_env *env,
@@ -362,8 +327,6 @@ EXPORT_SYMBOL(cl_page_get);
  */
 void cl_page_put(const struct lu_env *env, struct cl_page *page)
 {
-	PASSERT(env, page, atomic_read(&page->cp_ref) > !!page->cp_parent);
-
 	CL_PAGE_HEADER(D_TRACE, env, page, "%d\n",
 		       atomic_read(&page->cp_ref));
 
@@ -383,34 +346,10 @@ void cl_page_put(const struct lu_env *env, struct cl_page *page)
 EXPORT_SYMBOL(cl_page_put);
 
 /**
- * Returns a VM page associated with a given cl_page.
- */
-struct page *cl_page_vmpage(const struct lu_env *env, struct cl_page *page)
-{
-	const struct cl_page_slice *slice;
-
-	/*
-	 * Find uppermost layer with ->cpo_vmpage() method, and return its
-	 * result.
-	 */
-	page = cl_page_top(page);
-	do {
-		list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
-			if (slice->cpl_ops->cpo_vmpage)
-				return slice->cpl_ops->cpo_vmpage(env, slice);
-		}
-		page = page->cp_child;
-	} while (page);
-	LBUG(); /* ->cpo_vmpage() has to be defined somewhere in the stack */
-}
-EXPORT_SYMBOL(cl_page_vmpage);
-
-/**
  * Returns a cl_page associated with a VM page, and given cl_object.
  */
 struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj)
 {
-	struct cl_page *top;
 	struct cl_page *page;
 
 	KLASSERT(PageLocked(vmpage));
@@ -421,36 +360,15 @@ struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj)
 	 *       bottom-to-top pass.
 	 */
 
-	/*
-	 * This loop assumes that ->private points to the top-most page. This
-	 * can be rectified easily.
-	 */
-	top = (struct cl_page *)vmpage->private;
-	if (!top)
-		return NULL;
-
-	for (page = top; page; page = page->cp_child) {
-		if (cl_object_same(page->cp_obj, obj)) {
-			cl_page_get_trust(page);
-			break;
-		}
+	page = (struct cl_page *)vmpage->private;
+	if (page) {
+		cl_page_get_trust(page);
+		LASSERT(page->cp_type == CPT_CACHEABLE);
 	}
-	LASSERT(ergo(page, page->cp_type == CPT_CACHEABLE));
 	return page;
 }
 EXPORT_SYMBOL(cl_vmpage_page);
 
-/**
- * Returns the top-page for a given page.
- *
- * \see cl_object_top(), cl_io_top()
- */
-struct cl_page *cl_page_top(struct cl_page *page)
-{
-	return cl_page_top_trusted(page);
-}
-EXPORT_SYMBOL(cl_page_top);
-
 const struct cl_page_slice *cl_page_at(const struct cl_page *page,
 				       const struct lu_device_type *dtype)
 {
@@ -470,21 +388,14 @@ EXPORT_SYMBOL(cl_page_at);
 	int		       (*__method)_proto;		    \
 									\
 	__result = 0;						   \
-	__page = cl_page_top(__page);				   \
-	do {							    \
-		list_for_each_entry(__scan, &__page->cp_layers,     \
-					cpl_linkage) {		  \
-			__method = *(void **)((char *)__scan->cpl_ops + \
-					      __op);		    \
-			if (__method) {					\
-				__result = (*__method)(__env, __scan,   \
-						       ## __VA_ARGS__); \
-				if (__result != 0)		      \
-					break;			  \
-			}					       \
-		}						       \
-		__page = __page->cp_child;			      \
-	} while (__page && __result == 0);			      \
+	list_for_each_entry(__scan, &__page->cp_layers, cpl_linkage) {  \
+		__method = *(void **)((char *)__scan->cpl_ops +  __op); \
+		if (__method) {						\
+			__result = (*__method)(__env, __scan, ## __VA_ARGS__); \
+			if (__result != 0)				\
+				break;					\
+		}							\
+	}								\
 	if (__result > 0)					       \
 		__result = 0;					   \
 	__result;						       \
@@ -498,18 +409,11 @@ do {								    \
 	ptrdiff_t		   __op   = (_op);		     \
 	void		      (*__method)_proto;		    \
 									\
-	__page = cl_page_top(__page);				   \
-	do {							    \
-		list_for_each_entry(__scan, &__page->cp_layers,     \
-					cpl_linkage) {		  \
-			__method = *(void **)((char *)__scan->cpl_ops + \
-					      __op);		    \
-			if (__method)				   \
-				(*__method)(__env, __scan,	      \
-					    ## __VA_ARGS__);	    \
-		}						       \
-		__page = __page->cp_child;			      \
-	} while (__page);					       \
+	list_for_each_entry(__scan, &__page->cp_layers, cpl_linkage) {	\
+		__method = *(void **)((char *)__scan->cpl_ops + __op);	\
+		if (__method)						\
+			(*__method)(__env, __scan, ## __VA_ARGS__);	\
+	}								\
 } while (0)
 
 #define CL_PAGE_INVOID_REVERSE(_env, _page, _op, _proto, ...)	       \
@@ -520,20 +424,11 @@ do {									\
 	ptrdiff_t		   __op   = (_op);			 \
 	void		      (*__method)_proto;			\
 									    \
-	/* get to the bottom page. */				       \
-	while (__page->cp_child)					    \
-		__page = __page->cp_child;				  \
-	do {								\
-		list_for_each_entry_reverse(__scan, &__page->cp_layers, \
-						cpl_linkage) {	      \
-			__method = *(void **)((char *)__scan->cpl_ops +     \
-					      __op);			\
-			if (__method)				       \
-				(*__method)(__env, __scan,		  \
-					    ## __VA_ARGS__);		\
-		}							   \
-		__page = __page->cp_parent;				 \
-	} while (__page);						   \
+	list_for_each_entry_reverse(__scan, &__page->cp_layers, cpl_linkage) { \
+		__method = *(void **)((char *)__scan->cpl_ops + __op);	\
+		if (__method)						\
+			(*__method)(__env, __scan, ## __VA_ARGS__);	\
+	}								\
 } while (0)
 
 static int cl_page_invoke(const struct lu_env *env,
@@ -559,20 +454,17 @@ static void cl_page_invoid(const struct lu_env *env,
 
 static void cl_page_owner_clear(struct cl_page *page)
 {
-	for (page = cl_page_top(page); page; page = page->cp_child) {
-		if (page->cp_owner) {
-			LASSERT(page->cp_owner->ci_owned_nr > 0);
-			page->cp_owner->ci_owned_nr--;
-			page->cp_owner = NULL;
-			page->cp_task = NULL;
-		}
+	if (page->cp_owner) {
+		LASSERT(page->cp_owner->ci_owned_nr > 0);
+		page->cp_owner->ci_owned_nr--;
+		page->cp_owner = NULL;
+		page->cp_task = NULL;
 	}
 }
 
 static void cl_page_owner_set(struct cl_page *page)
 {
-	for (page = cl_page_top(page); page; page = page->cp_child)
-		page->cp_owner->ci_owned_nr++;
+	page->cp_owner->ci_owned_nr++;
 }
 
 void cl_page_disown0(const struct lu_env *env,
@@ -603,8 +495,9 @@ void cl_page_disown0(const struct lu_env *env,
  */
 int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
 {
+	struct cl_io *top = cl_io_top((struct cl_io *)io);
 	LINVRNT(cl_object_same(pg->cp_obj, io->ci_obj));
-	return pg->cp_state == CPS_OWNED && pg->cp_owner == io;
+	return pg->cp_state == CPS_OWNED && pg->cp_owner == top;
 }
 EXPORT_SYMBOL(cl_page_is_owned);
 
@@ -635,7 +528,6 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 
 	PINVRNT(env, pg, !cl_page_is_owned(pg, io));
 
-	pg = cl_page_top(pg);
 	io = cl_io_top(io);
 
 	if (pg->cp_state == CPS_FREEING) {
@@ -649,7 +541,7 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 		if (result == 0) {
 			PASSERT(env, pg, !pg->cp_owner);
 			PASSERT(env, pg, !pg->cp_req);
-			pg->cp_owner = io;
+			pg->cp_owner = cl_io_top(io);
 			pg->cp_task  = current;
 			cl_page_owner_set(pg);
 			if (pg->cp_state != CPS_FREEING) {
@@ -702,12 +594,11 @@ void cl_page_assume(const struct lu_env *env,
 {
 	PINVRNT(env, pg, cl_object_same(pg->cp_obj, io->ci_obj));
 
-	pg = cl_page_top(pg);
 	io = cl_io_top(io);
 
 	cl_page_invoid(env, io, pg, CL_PAGE_OP(cpo_assume));
 	PASSERT(env, pg, !pg->cp_owner);
-	pg->cp_owner = io;
+	pg->cp_owner = cl_io_top(io);
 	pg->cp_task = current;
 	cl_page_owner_set(pg);
 	cl_page_state_set(env, pg, CPS_OWNED);
@@ -731,7 +622,6 @@ void cl_page_unassume(const struct lu_env *env,
 	PINVRNT(env, pg, cl_page_is_owned(pg, io));
 	PINVRNT(env, pg, cl_page_invariant(pg));
 
-	pg = cl_page_top(pg);
 	io = cl_io_top(io);
 	cl_page_owner_clear(pg);
 	cl_page_state_set(env, pg, CPS_CACHED);
@@ -758,7 +648,6 @@ void cl_page_disown(const struct lu_env *env,
 {
 	PINVRNT(env, pg, cl_page_is_owned(pg, io));
 
-	pg = cl_page_top(pg);
 	io = cl_io_top(io);
 	cl_page_disown0(env, io, pg);
 }
@@ -791,7 +680,6 @@ EXPORT_SYMBOL(cl_page_discard);
  */
 static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
 {
-	PASSERT(env, pg, pg == cl_page_top(pg));
 	PASSERT(env, pg, pg->cp_state != CPS_FREEING);
 
 	/*
@@ -825,7 +713,6 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
  * Once page reaches cl_page_state::CPS_FREEING, all remaining references will
  * drain after some time, at which point page will be recycled.
  *
- * \pre  pg == cl_page_top(pg)
  * \pre  VM page is locked
  * \post pg->cp_state == CPS_FREEING
  *
@@ -865,7 +752,6 @@ int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
 	int result;
 	const struct cl_page_slice *slice;
 
-	pg = cl_page_top_trusted((struct cl_page *)pg);
 	slice = container_of(pg->cp_layers.next,
 			     const struct cl_page_slice, cpl_linkage);
 	PASSERT(env, pg, slice->cpl_ops->cpo_is_vmlocked);
@@ -1082,9 +968,8 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg)
 {
 	(*printer)(env, cookie,
-		   "page@%p[%d %p:%lu ^%p_%p %d %d %d %p %p %#x]\n",
+		   "page@%p[%d %p %d %d %d %p %p %#x]\n",
 		   pg, atomic_read(&pg->cp_ref), pg->cp_obj,
-		   pg->cp_index, pg->cp_parent, pg->cp_child,
 		   pg->cp_state, pg->cp_error, pg->cp_type,
 		   pg->cp_owner, pg->cp_req, pg->cp_flags);
 }
@@ -1096,11 +981,7 @@ EXPORT_SYMBOL(cl_page_header_print);
 void cl_page_print(const struct lu_env *env, void *cookie,
 		   lu_printer_t printer, const struct cl_page *pg)
 {
-	struct cl_page *scan;
-
-	for (scan = cl_page_top((struct cl_page *)pg); scan;
-	     scan = scan->cp_child)
-		cl_page_header_print(env, cookie, printer, scan);
+	cl_page_header_print(env, cookie, printer, pg);
 	CL_PAGE_INVOKE(env, (struct cl_page *)pg, CL_PAGE_OP(cpo_print),
 		       (const struct lu_env *env,
 			const struct cl_page_slice *slice,
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 6c205f9..db56081 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -81,7 +81,6 @@ struct echo_object_conf {
 struct echo_page {
 	struct cl_page_slice   ep_cl;
 	struct mutex		ep_lock;
-	struct page	    *ep_vmpage;
 };
 
 struct echo_lock {
@@ -219,12 +218,6 @@ static struct lu_kmem_descr echo_caches[] = {
  *
  * @{
  */
-static struct page *echo_page_vmpage(const struct lu_env *env,
-				     const struct cl_page_slice *slice)
-{
-	return cl2echo_page(slice)->ep_vmpage;
-}
-
 static int echo_page_own(const struct lu_env *env,
 			 const struct cl_page_slice *slice,
 			 struct cl_io *io, int nonblock)
@@ -273,12 +266,10 @@ static void echo_page_completion(const struct lu_env *env,
 static void echo_page_fini(const struct lu_env *env,
 			   struct cl_page_slice *slice)
 {
-	struct echo_page *ep    = cl2echo_page(slice);
 	struct echo_object *eco = cl2echo_obj(slice->cpl_obj);
-	struct page *vmpage      = ep->ep_vmpage;
 
 	atomic_dec(&eco->eo_npages);
-	page_cache_release(vmpage);
+	page_cache_release(slice->cpl_page->cp_vmpage);
 }
 
 static int echo_page_prep(const struct lu_env *env,
@@ -295,7 +286,8 @@ static int echo_page_print(const struct lu_env *env,
 	struct echo_page *ep = cl2echo_page(slice);
 
 	(*printer)(env, cookie, LUSTRE_ECHO_CLIENT_NAME"-page@%p %d vm@%p\n",
-		   ep, mutex_is_locked(&ep->ep_lock), ep->ep_vmpage);
+		   ep, mutex_is_locked(&ep->ep_lock),
+		   slice->cpl_page->cp_vmpage);
 	return 0;
 }
 
@@ -303,7 +295,6 @@ static const struct cl_page_operations echo_page_ops = {
 	.cpo_own	   = echo_page_own,
 	.cpo_disown	= echo_page_disown,
 	.cpo_discard       = echo_page_discard,
-	.cpo_vmpage	= echo_page_vmpage,
 	.cpo_fini	  = echo_page_fini,
 	.cpo_print	 = echo_page_print,
 	.cpo_is_vmlocked   = echo_page_is_vmlocked,
@@ -367,13 +358,12 @@ static struct cl_lock_operations echo_lock_ops = {
  * @{
  */
 static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
-			  struct cl_page *page, struct page *vmpage)
+			  struct cl_page *page, pgoff_t index)
 {
 	struct echo_page *ep = cl_object_page_slice(obj, page);
 	struct echo_object *eco = cl2echo_obj(obj);
 
-	ep->ep_vmpage = vmpage;
-	page_cache_get(vmpage);
+	page_cache_get(page->cp_vmpage);
 	mutex_init(&ep->ep_lock);
 	cl_page_slice_add(page, &ep->ep_cl, obj, &echo_page_ops);
 	atomic_inc(&eco->eo_npages);
@@ -568,6 +558,8 @@ static struct lu_object *echo_object_alloc(const struct lu_env *env,
 
 		obj = &echo_obj2cl(eco)->co_lu;
 		cl_object_header_init(hdr);
+		hdr->coh_page_bufsize = cfs_size_round(sizeof(struct cl_page));
+
 		lu_object_init(obj, &hdr->coh_lu, dev);
 		lu_object_add_top(&hdr->coh_lu, obj);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 3be4b1f..74607933 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -276,7 +276,7 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 
 	page_count = 0;
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
-		pgoff_t index = oap2cl_page(oap)->cp_index;
+		pgoff_t index = osc_index(oap2osc(oap));
 		++page_count;
 		if (index > ext->oe_end || index < ext->oe_start) {
 			rc = 110;
@@ -991,19 +991,19 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 
 	/* discard all pages with index greater then trunc_index */
 	list_for_each_entry_safe(oap, tmp, &ext->oe_pages, oap_pending_item) {
-		struct cl_page *sub = oap2cl_page(oap);
-		struct cl_page *page = cl_page_top(sub);
+		pgoff_t index = osc_index(oap2osc(oap));
+		struct cl_page *page = oap2cl_page(oap);
 
 		LASSERT(list_empty(&oap->oap_rpc_item));
 
 		/* only discard the pages with their index greater than
 		 * trunc_index, and ...
 		 */
-		if (sub->cp_index < trunc_index ||
-		    (sub->cp_index == trunc_index && partial)) {
+		if (index < trunc_index ||
+		    (index == trunc_index && partial)) {
 			/* accounting how many pages remaining in the chunk
 			 * so that we can calculate grants correctly. */
-			if (sub->cp_index >> ppc_bits == trunc_chunk)
+			if (index >> ppc_bits == trunc_chunk)
 				++pages_in_chunk;
 			continue;
 		}
@@ -1256,7 +1256,7 @@ static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
 			  int cmd)
 {
 	struct osc_page *opg = oap2osc_page(oap);
-	struct cl_page *page = cl_page_top(oap2cl_page(oap));
+	struct cl_page  *page = oap2cl_page(oap);
 	int result;
 
 	LASSERT(cmd == OBD_BRW_WRITE); /* no cached reads */
@@ -1271,7 +1271,7 @@ static int osc_refresh_count(const struct lu_env *env,
 			     struct osc_async_page *oap, int cmd)
 {
 	struct osc_page *opg = oap2osc_page(oap);
-	struct cl_page *page = oap2cl_page(oap);
+	pgoff_t index = osc_index(oap2osc(oap));
 	struct cl_object *obj;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 
@@ -1288,10 +1288,10 @@ static int osc_refresh_count(const struct lu_env *env,
 	if (result < 0)
 		return result;
 	kms = attr->cat_kms;
-	if (cl_offset(obj, page->cp_index) >= kms)
+	if (cl_offset(obj, index) >= kms)
 		/* catch race with truncate */
 		return 0;
-	else if (cl_offset(obj, page->cp_index + 1) > kms)
+	else if (cl_offset(obj, index + 1) > kms)
 		/* catch sub-page write at end of file */
 		return kms % PAGE_CACHE_SIZE;
 	else
@@ -1302,7 +1302,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 			  int cmd, int rc)
 {
 	struct osc_page *opg = oap2osc_page(oap);
-	struct cl_page *page = cl_page_top(oap2cl_page(oap));
+	struct cl_page    *page = oap2cl_page(oap);
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 	enum cl_req_type crt;
 	int srvlock;
@@ -2313,7 +2313,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	OSC_IO_DEBUG(osc, "oap %p page %p added for cmd %d\n",
 		     oap, oap->oap_page, oap->oap_cmd & OBD_BRW_RWMASK);
 
-	index = oap2cl_page(oap)->cp_index;
+	index = osc_index(oap2osc(oap));
 
 	/* Add this page into extent by the following steps:
 	 * 1. if there exists an active extent for this IO, mostly this page
@@ -2425,21 +2425,21 @@ int osc_teardown_async_page(const struct lu_env *env,
 	LASSERT(oap->oap_magic == OAP_MAGIC);
 
 	CDEBUG(D_INFO, "teardown oap %p page %p at index %lu.\n",
-	       oap, ops, oap2cl_page(oap)->cp_index);
+	       oap, ops, osc_index(oap2osc(oap)));
 
 	osc_object_lock(obj);
 	if (!list_empty(&oap->oap_rpc_item)) {
 		CDEBUG(D_CACHE, "oap %p is not in cache.\n", oap);
 		rc = -EBUSY;
 	} else if (!list_empty(&oap->oap_pending_item)) {
-		ext = osc_extent_lookup(obj, oap2cl_page(oap)->cp_index);
+		ext = osc_extent_lookup(obj, osc_index(oap2osc(oap)));
 		/* only truncated pages are allowed to be taken out.
 		 * See osc_extent_truncate() and osc_cache_truncate_start()
 		 * for details.
 		 */
 		if (ext && ext->oe_state != OES_TRUNC) {
 			OSC_EXTENT_DUMP(D_ERROR, ext, "trunc at %lu.\n",
-					oap2cl_page(oap)->cp_index);
+					osc_index(oap2osc(oap)));
 			rc = -EBUSY;
 		}
 	}
@@ -2462,7 +2462,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	struct osc_extent *ext = NULL;
 	struct osc_object *obj = cl2osc(ops->ops_cl.cpl_obj);
 	struct cl_page *cp = ops->ops_cl.cpl_page;
-	pgoff_t	index = cp->cp_index;
+	pgoff_t            index = osc_index(ops);
 	struct osc_async_page *oap = &ops->ops_oap;
 	bool unplug = false;
 	int rc = 0;
@@ -2477,8 +2477,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	switch (ext->oe_state) {
 	case OES_RPC:
 	case OES_LOCK_DONE:
-		CL_PAGE_DEBUG(D_ERROR, env, cl_page_top(cp),
-			      "flush an in-rpc page?\n");
+		CL_PAGE_DEBUG(D_ERROR, env, cp, "flush an in-rpc page?\n");
 		LASSERT(0);
 		break;
 	case OES_LOCKING:
@@ -2504,7 +2503,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 		break;
 	}
 
-	rc = cl_page_prep(env, io, cl_page_top(cp), CRT_WRITE);
+	rc = cl_page_prep(env, io, cp, CRT_WRITE);
 	if (rc)
 		goto out;
 
@@ -2548,7 +2547,7 @@ int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops)
 	struct osc_extent *ext;
 	struct osc_extent *found = NULL;
 	struct list_head *plist;
-	pgoff_t index = oap2cl_page(oap)->cp_index;
+	pgoff_t index = osc_index(ops);
 	int rc = -EBUSY;
 	int cmd;
 
@@ -2611,12 +2610,12 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	pgoff_t end = 0;
 
 	list_for_each_entry(oap, list, oap_pending_item) {
-		struct cl_page *cp = oap2cl_page(oap);
+		pgoff_t index = osc_index(oap2osc(oap));
 
-		if (cp->cp_index > end)
-			end = cp->cp_index;
-		if (cp->cp_index < start)
-			start = cp->cp_index;
+		if (index > end)
+			end = index;
+		if (index < start)
+			start = index;
 		++page_count;
 		mppr <<= (page_count > mppr);
 	}
@@ -3033,7 +3032,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 				break;
 			}
 
-			page = cl_page_top(ops->ops_cl.cpl_page);
+			page = ops->ops_cl.cpl_page;
 			LASSERT(page->cp_type == CPT_CACHEABLE);
 			if (page->cp_state == CPS_FREEING)
 				continue;
@@ -3061,7 +3060,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 			if (res == CLP_GANG_OKAY)
 				res = (*cb)(env, io, ops, cbdata);
 
-			page = cl_page_top(ops->ops_cl.cpl_page);
+			page = ops->ops_cl.cpl_page;
 			lu_ref_del(&page->cp_reference, "gang_lookup", current);
 			cl_page_put(env, page);
 		}
@@ -3094,7 +3093,7 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 	index = osc_index(ops);
 	if (index >= info->oti_fn_index) {
 		struct cl_lock *tmp;
-		struct cl_page *page = cl_page_top(ops->ops_cl.cpl_page);
+		struct cl_page *page = ops->ops_cl.cpl_page;
 
 		/* refresh non-overlapped index */
 		tmp = cl_lock_at_pgoff(env, lock->cll_descr.cld_obj, index,
@@ -3127,7 +3126,7 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_lock *lock = cbdata;
-	struct cl_page *page = cl_page_top(ops->ops_cl.cpl_page);
+	struct cl_page *page = ops->ops_cl.cpl_page;
 
 	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
 
@@ -3135,7 +3134,7 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 	info->oti_next_index = osc_index(ops) + 1;
 	if (cl_page_own(env, io, page) == 0) {
 		KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
-			      !PageDirty(cl_page_vmpage(env, page))));
+			      !PageDirty(cl_page_vmpage(page))));
 
 		/* discard the page */
 		cl_page_discard(env, io, page);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index cf87043..89552d7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -416,7 +416,7 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, struct page *vmpage);
+		  struct cl_page *page, pgoff_t ind);
 
 void osc_index2policy  (ldlm_policy_data_t *policy, const struct cl_object *obj,
 			pgoff_t start, pgoff_t end);
@@ -553,6 +553,11 @@ static inline struct osc_page *oap2osc(struct osc_async_page *oap)
 	return container_of0(oap, struct osc_page, ops_oap);
 }
 
+static inline pgoff_t osc_index(struct osc_page *opg)
+{
+	return opg->ops_cl.cpl_index;
+}
+
 static inline struct cl_page *oap2cl_page(struct osc_async_page *oap)
 {
 	return oap2osc(oap)->ops_cl.cpl_page;
@@ -563,11 +568,6 @@ static inline struct osc_page *oap2osc_page(struct osc_async_page *oap)
 	return (struct osc_page *)container_of(oap, struct osc_page, ops_oap);
 }
 
-static inline pgoff_t osc_index(struct osc_page *opg)
-{
-	return opg->ops_cl.cpl_page->cp_index;
-}
-
 static inline struct osc_lock *cl2osc_lock(const struct cl_lock_slice *slice)
 {
 	LINVRNT(osc_is_object(&slice->cls_obj->co_lu));
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index e9e18a1..1ae8a22 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -68,11 +68,15 @@ static struct osc_io *cl2osc_io(const struct lu_env *env,
 	return oio;
 }
 
-static struct osc_page *osc_cl_page_osc(struct cl_page *page)
+static struct osc_page *osc_cl_page_osc(struct cl_page *page,
+					struct osc_object *osc)
 {
 	const struct cl_page_slice *slice;
 
-	slice = cl_page_at(page, &osc_device_type);
+	if (osc)
+		slice = cl_object_page_slice(&osc->oo_cl, page);
+	else
+		slice = cl_page_at(page, &osc_device_type);
 	LASSERT(slice);
 
 	return cl2osc_page(slice);
@@ -137,7 +141,7 @@ static int osc_io_submit(const struct lu_env *env,
 		io = page->cp_owner;
 		LASSERT(io);
 
-		opg = osc_cl_page_osc(page);
+		opg = osc_cl_page_osc(page, osc);
 		oap = &opg->ops_oap;
 		LASSERT(osc == oap->oap_obj);
 
@@ -258,15 +262,11 @@ static int osc_io_commit_async(const struct lu_env *env,
 		}
 	}
 
-	/*
-	 * NOTE: here @page is a top-level page. This is done to avoid
-	 * creation of sub-page-list.
-	 */
 	while (qin->pl_nr > 0) {
 		struct osc_async_page *oap;
 
 		page = cl_page_list_first(qin);
-		opg = osc_cl_page_osc(page);
+		opg = osc_cl_page_osc(page, osc);
 		oap = &opg->ops_oap;
 
 		if (!list_empty(&oap->oap_rpc_item)) {
@@ -283,8 +283,7 @@ static int osc_io_commit_async(const struct lu_env *env,
 				break;
 		}
 
-		osc_page_touch_at(env, osc2cl(osc),
-				  opg->ops_cl.cpl_page->cp_index,
+		osc_page_touch_at(env, osc2cl(osc), osc_index(opg),
 				  page == last_page ? to : PAGE_SIZE);
 
 		cl_page_list_del(env, qin, page);
@@ -403,14 +402,9 @@ static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 		CL_PAGE_DEBUG(D_ERROR, env, page, "exists %llu/%s.\n",
 			      start, current->comm);
 
-	{
-		struct page *vmpage = cl_page_vmpage(env, page);
-
-		if (PageLocked(vmpage))
-			CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
-			       ops, page->cp_index,
-			       (oap->oap_cmd & OBD_BRW_RWMASK));
-	}
+	if (PageLocked(page->cp_vmpage))
+		CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
+		       ops, osc_index(ops), oap->oap_cmd & OBD_BRW_RWMASK);
 
 	return CLP_GANG_OKAY;
 }
@@ -788,18 +782,21 @@ static void osc_req_attr_set(const struct lu_env *env,
 		oa->o_valid |= OBD_MD_FLID;
 	}
 	if (flags & OBD_MD_FLHANDLE) {
+		struct cl_object *subobj;
+
 		clerq = slice->crs_req;
 		LASSERT(!list_empty(&clerq->crq_pages));
 		apage = container_of(clerq->crq_pages.next,
 				     struct cl_page, cp_flight);
-		opg = osc_cl_page_osc(apage);
-		apage = opg->ops_cl.cpl_page; /* now apage is a sub-page */
-		lock = cl_lock_at_page(env, apage->cp_obj, apage, NULL, 1, 1);
+		opg = osc_cl_page_osc(apage, NULL);
+		subobj = opg->ops_cl.cpl_obj;
+		lock = cl_lock_at_pgoff(env, subobj, osc_index(opg),
+					NULL, 1, 1);
 		if (!lock) {
 			struct cl_object_header *head;
 			struct cl_lock *scan;
 
-			head = cl_object_header(apage->cp_obj);
+			head = cl_object_header(subobj);
 			list_for_each_entry(scan, &head->coh_locks, cll_linkage)
 				CL_LOCK_DEBUG(D_ERROR, env, scan,
 					      "no cover page!\n");
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 8dc62fa..3e0a8c3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -64,14 +64,9 @@ static int osc_page_protected(const struct lu_env *env,
  * Page operations.
  *
  */
-static void osc_page_fini(const struct lu_env *env,
-			  struct cl_page_slice *slice)
-{
-}
-
 static void osc_page_transfer_get(struct osc_page *opg, const char *label)
 {
-	struct cl_page *page = cl_page_top(opg->ops_cl.cpl_page);
+	struct cl_page *page = opg->ops_cl.cpl_page;
 
 	LASSERT(!opg->ops_transfer_pinned);
 	cl_page_get(page);
@@ -82,7 +77,7 @@ static void osc_page_transfer_get(struct osc_page *opg, const char *label)
 static void osc_page_transfer_put(const struct lu_env *env,
 				  struct osc_page *opg)
 {
-	struct cl_page *page = cl_page_top(opg->ops_cl.cpl_page);
+	struct cl_page *page = opg->ops_cl.cpl_page;
 
 	if (opg->ops_transfer_pinned) {
 		opg->ops_transfer_pinned = 0;
@@ -139,11 +134,12 @@ static int osc_page_is_under_lock(const struct lu_env *env,
 				  const struct cl_page_slice *slice,
 				  struct cl_io *unused)
 {
+	struct osc_page *opg = cl2osc_page(slice);
 	struct cl_lock *lock;
 	int result = -ENODATA;
 
-	lock = cl_lock_at_page(env, slice->cpl_obj, slice->cpl_page,
-			       NULL, 1, 0);
+	lock = cl_lock_at_pgoff(env, slice->cpl_obj, osc_index(opg),
+				NULL, 1, 0);
 	if (lock) {
 		cl_lock_put(env, lock);
 		result = -EBUSY;
@@ -173,8 +169,8 @@ static int osc_page_print(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(slice->cpl_obj);
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
-	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p: 1< %#x %d %u %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %s %p %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
-			  opg,
+	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %u %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %s %p %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
+			  opg, osc_index(opg),
 			  /* 1 */
 			  oap->oap_magic, oap->oap_cmd,
 			  oap->oap_interrupted,
@@ -222,7 +218,7 @@ static void osc_page_delete(const struct lu_env *env,
 	osc_page_transfer_put(env, opg);
 	rc = osc_teardown_async_page(env, obj, opg);
 	if (rc) {
-		CL_PAGE_DEBUG(D_ERROR, env, cl_page_top(slice->cpl_page),
+		CL_PAGE_DEBUG(D_ERROR, env, slice->cpl_page,
 			      "Trying to teardown failed: %d\n", rc);
 		LASSERT(0);
 	}
@@ -295,7 +291,6 @@ static int osc_page_flush(const struct lu_env *env,
 }
 
 static const struct cl_page_operations osc_page_ops = {
-	.cpo_fini	  = osc_page_fini,
 	.cpo_print	 = osc_page_print,
 	.cpo_delete	= osc_page_delete,
 	.cpo_is_under_lock = osc_page_is_under_lock,
@@ -305,7 +300,7 @@ static const struct cl_page_operations osc_page_ops = {
 };
 
 int osc_page_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_page *page, struct page *vmpage)
+		  struct cl_page *page, pgoff_t index)
 {
 	struct osc_object *osc = cl2osc(obj);
 	struct osc_page *opg = cl_object_page_slice(obj, page);
@@ -313,9 +308,10 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	opg->ops_from = 0;
 	opg->ops_to = PAGE_CACHE_SIZE;
+	opg->ops_cl.cpl_index = index;
 
-	result = osc_prep_async_page(osc, opg, vmpage,
-				     cl_offset(obj, page->cp_index));
+	result = osc_prep_async_page(osc, opg, page->cp_vmpage,
+				     cl_offset(obj, index));
 	if (result == 0) {
 		struct osc_io *oio = osc_env_io(env);
 
@@ -337,8 +333,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		result = osc_lru_reserve(env, osc, opg);
 		if (result == 0) {
 			spin_lock(&osc->oo_tree_lock);
-			result = radix_tree_insert(&osc->oo_tree,
-						   page->cp_index, opg);
+			result = radix_tree_insert(&osc->oo_tree, index, opg);
 			if (result == 0)
 				++osc->oo_npages;
 			spin_unlock(&osc->oo_tree_lock);
@@ -584,7 +579,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		if (--maxscan < 0)
 			break;
 
-		page = cl_page_top(opg->ops_cl.cpl_page);
+		page = opg->ops_cl.cpl_page;
 		if (cl_page_in_use_noref(page)) {
 			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
 			continue;
-- 
2.1.0
