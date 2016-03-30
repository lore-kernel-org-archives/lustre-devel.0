From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:39 -0400
Subject: [lustre-devel] [PATCH 07/43] staging/lustre/clio: collapse layer of
	cl_page
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Move radix tree to osc layer too for performance improvement.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7892
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  36 +--
 drivers/staging/lustre/lustre/llite/rw.c           |   2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |   4 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  47 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   1 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  13 +
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  36 +--
 drivers/staging/lustre/lustre/lov/lov_object.c     |   9 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |  29 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   1 +
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 131 +-------
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  47 +--
 drivers/staging/lustre/lustre/obdclass/cl_page.c   | 354 ++-------------------
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 207 +++++++++++-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  27 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  14 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  10 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |   2 +
 drivers/staging/lustre/lustre/osc/osc_page.c       |  28 +-
 19 files changed, 394 insertions(+), 604 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index e611f79..5daf688 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -388,6 +388,12 @@ struct cl_object_operations {
 	 */
 	int (*coo_glimpse)(const struct lu_env *env,
 			   const struct cl_object *obj, struct ost_lvb *lvb);
+	/**
+	 * Object prune method. Called when the layout is going to change on
+	 * this object, therefore each layer has to clean up their cache,
+	 * mainly pages and locks.
+	 */
+	int (*coo_prune)(const struct lu_env *env, struct cl_object *obj);
 };
 
 /**
@@ -403,15 +409,9 @@ struct cl_object_header {
 	 * mostly useless otherwise.
 	 */
 	/** @{ */
-	/** Lock protecting page tree. */
-	spinlock_t		 coh_page_guard;
 	/** Lock protecting lock list. */
 	spinlock_t		 coh_lock_guard;
 	/** @} locks */
-	/** Radix tree of cl_page's, cached for this object. */
-	struct radix_tree_root   coh_tree;
-	/** # of pages in radix tree. */
-	unsigned long	    coh_pages;
 	/** List of cl_lock's granted for this object. */
 	struct list_head	       coh_locks;
 
@@ -897,14 +897,6 @@ struct cl_page_operations {
 	void  (*cpo_export)(const struct lu_env *env,
 			    const struct cl_page_slice *slice, int uptodate);
 	/**
-	 * Unmaps page from the user space (if it is mapped).
-	 *
-	 * \see cl_page_unmap()
-	 * \see vvp_page_unmap()
-	 */
-	int (*cpo_unmap)(const struct lu_env *env,
-			 const struct cl_page_slice *slice, struct cl_io *io);
-	/**
 	 * Checks whether underlying VM page is locked (in the suitable
 	 * sense). Used for assertions.
 	 *
@@ -2794,19 +2786,13 @@ enum {
 };
 
 /* callback of cl_page_gang_lookup() */
-typedef int   (*cl_page_gang_cb_t)  (const struct lu_env *, struct cl_io *,
-				     struct cl_page *, void *);
-int cl_page_gang_lookup(const struct lu_env *env, struct cl_object *obj,
-			struct cl_io *io, pgoff_t start, pgoff_t end,
-			cl_page_gang_cb_t cb, void *cbdata);
-struct cl_page *cl_page_lookup(struct cl_object_header *hdr, pgoff_t index);
 struct cl_page *cl_page_find(const struct lu_env *env, struct cl_object *obj,
 			     pgoff_t idx, struct page *vmpage,
 			     enum cl_page_type type);
-struct cl_page *cl_page_find_sub(const struct lu_env *env,
-				 struct cl_object *obj,
-				 pgoff_t idx, struct page *vmpage,
-				     struct cl_page *parent);
+struct cl_page *cl_page_alloc(const struct lu_env *env,
+			      struct cl_object *o, pgoff_t ind,
+			      struct page *vmpage,
+			      enum cl_page_type type);
 void cl_page_get(struct cl_page *page);
 void cl_page_put(const struct lu_env *env, struct cl_page *page);
 void cl_page_print(const struct lu_env *env, void *cookie, lu_printer_t printer,
@@ -2872,8 +2858,6 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 void cl_page_discard(const struct lu_env *env, struct cl_io *io,
 		     struct cl_page *pg);
 void cl_page_delete(const struct lu_env *env, struct cl_page *pg);
-int cl_page_unmap(const struct lu_env *env, struct cl_io *io,
-		  struct cl_page *pg);
 int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg);
 void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate);
 int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 34614ac..01b8365 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -442,7 +442,7 @@ static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			cl_page_list_add(queue, page);
 			rc = 1;
 		} else {
-			cl_page_delete(env, page);
+			cl_page_discard(env, io, page);
 			rc = -ENOLCK;
 		}
 	} else {
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 3d7e64e..b5335de 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -95,11 +95,7 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 			if (obj) {
 				page = cl_vmpage_page(vmpage, obj);
 				if (page) {
-					lu_ref_add(&page->cp_reference,
-						   "delete", vmpage);
 					cl_page_delete(env, page);
-					lu_ref_del(&page->cp_reference,
-						   "delete", vmpage);
 					cl_page_put(env, page);
 				}
 			} else
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 282b70b..29d24c9 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -36,6 +36,7 @@
  * cl_device and cl_device_type implementation for VVP layer.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_LLITE
@@ -356,23 +357,18 @@ static loff_t vvp_pgcache_find(const struct lu_env *env,
 			return ~0ULL;
 		clob = vvp_pgcache_obj(env, dev, &id);
 		if (clob) {
-			struct cl_object_header *hdr;
-			int		      nr;
-			struct cl_page	  *pg;
+			struct inode *inode = ccc_object_inode(clob);
+			struct page *vmpage;
+			int nr;
 
-			/* got an object. Find next page. */
-			hdr = cl_object_header(clob);
-
-			spin_lock(&hdr->coh_page_guard);
-			nr = radix_tree_gang_lookup(&hdr->coh_tree,
-						    (void **)&pg,
-						    id.vpi_index, 1);
+			nr = find_get_pages_contig(inode->i_mapping,
+						   id.vpi_index, 1, &vmpage);
 			if (nr > 0) {
-				id.vpi_index = pg->cp_index;
+				id.vpi_index = vmpage->index;
 				/* Cant support over 16T file */
-				nr = !(pg->cp_index > 0xffffffff);
+				nr = !(vmpage->index > 0xffffffff);
+				page_cache_release(vmpage);
 			}
-			spin_unlock(&hdr->coh_page_guard);
 
 			lu_object_ref_del(&clob->co_lu, "dump", current);
 			cl_object_put(env, clob);
@@ -431,8 +427,6 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 	struct ll_sb_info       *sbi;
 	struct cl_object	*clob;
 	struct lu_env	   *env;
-	struct cl_page	  *page;
-	struct cl_object_header *hdr;
 	struct vvp_pgcache_id    id;
 	int		      refcheck;
 	int		      result;
@@ -444,14 +438,23 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 		sbi = f->private;
 		clob = vvp_pgcache_obj(env, &sbi->ll_cl->cd_lu_dev, &id);
 		if (clob) {
-			hdr = cl_object_header(clob);
-
-			spin_lock(&hdr->coh_page_guard);
-			page = cl_page_lookup(hdr, id.vpi_index);
-			spin_unlock(&hdr->coh_page_guard);
+			struct inode *inode = ccc_object_inode(clob);
+			struct cl_page *page = NULL;
+			struct page *vmpage;
+
+			result = find_get_pages_contig(inode->i_mapping,
+						       id.vpi_index, 1,
+						       &vmpage);
+			if (result > 0) {
+				lock_page(vmpage);
+				page = cl_vmpage_page(vmpage, clob);
+				unlock_page(vmpage);
+
+				page_cache_release(vmpage);
+			}
 
-			seq_printf(f, "%8x@"DFID": ",
-				   id.vpi_index, PFID(&hdr->coh_lu.loh_fid));
+			seq_printf(f, "%8x@" DFID ": ", id.vpi_index,
+				   PFID(lu_object_fid(&clob->co_lu)));
 			if (page) {
 				vvp_pgcache_page_show(env, f, page);
 				cl_page_put(env, page);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 984699a..ffe301b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -763,7 +763,6 @@ static int vvp_io_fault_start(const struct lu_env *env,
 
 			vmpage = NULL;
 			if (result < 0) {
-				cl_page_unmap(env, io, page);
 				cl_page_discard(env, io, page);
 				cl_page_disown(env, io, page);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 03c887d..b9a1d01 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -165,6 +165,18 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
+static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
+{
+	struct inode *inode = ccc_object_inode(obj);
+	int rc;
+
+	rc = cl_sync_file_range(inode, 0, OBD_OBJECT_EOF, CL_FSYNC_ALL, 1);
+	if (rc == 0)
+		truncate_inode_pages(inode->i_mapping, 0);
+
+	return rc;
+}
+
 static const struct cl_object_operations vvp_ops = {
 	.coo_page_init = vvp_page_init,
 	.coo_lock_init = vvp_lock_init,
@@ -172,6 +184,7 @@ static const struct cl_object_operations vvp_ops = {
 	.coo_attr_get  = vvp_attr_get,
 	.coo_attr_set  = vvp_attr_set,
 	.coo_conf_set  = vvp_conf_set,
+	.coo_prune     = vvp_prune,
 	.coo_glimpse   = ccc_object_glimpse
 };
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 850bae7..11e609e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -138,6 +138,7 @@ static void vvp_page_discard(const struct lu_env *env,
 	struct page	   *vmpage  = cl2vm_page(slice);
 	struct address_space *mapping;
 	struct ccc_page      *cpg     = cl2ccc_page(slice);
+	__u64 offset;
 
 	LASSERT(vmpage);
 	LASSERT(PageLocked(vmpage));
@@ -147,6 +148,9 @@ static void vvp_page_discard(const struct lu_env *env,
 	if (cpg->cpg_defer_uptodate && !cpg->cpg_ra_used)
 		ll_ra_stats_inc(mapping, RA_STAT_DISCARDED);
 
+	offset = vmpage->index << PAGE_SHIFT;
+	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_SIZE);
+
 	/*
 	 * truncate_complete_page() calls
 	 * a_ops->invalidatepage()->cl_page_delete()->vvp_page_delete().
@@ -154,37 +158,26 @@ static void vvp_page_discard(const struct lu_env *env,
 	truncate_complete_page(mapping, vmpage);
 }
 
-static int vvp_page_unmap(const struct lu_env *env,
-			  const struct cl_page_slice *slice,
-			  struct cl_io *unused)
-{
-	struct page *vmpage = cl2vm_page(slice);
-	__u64       offset;
-
-	LASSERT(vmpage);
-	LASSERT(PageLocked(vmpage));
-
-	offset = vmpage->index << PAGE_CACHE_SHIFT;
-
-	/*
-	 * XXX is it safe to call this with the page lock held?
-	 */
-	ll_teardown_mmaps(vmpage->mapping, offset, offset + PAGE_CACHE_SIZE);
-	return 0;
-}
-
 static void vvp_page_delete(const struct lu_env *env,
 			    const struct cl_page_slice *slice)
 {
 	struct page       *vmpage = cl2vm_page(slice);
 	struct inode     *inode  = vmpage->mapping->host;
 	struct cl_object *obj    = slice->cpl_obj;
+	struct cl_page   *page   = slice->cpl_page;
+	int refc;
 
 	LASSERT(PageLocked(vmpage));
-	LASSERT((struct cl_page *)vmpage->private == slice->cpl_page);
+	LASSERT((struct cl_page *)vmpage->private == page);
 	LASSERT(inode == ccc_object_inode(obj));
 
 	vvp_write_complete(cl2ccc(obj), cl2ccc_page(slice));
+
+	/* Drop the reference count held in vvp_page_init */
+	refc = atomic_dec_return(&page->cp_ref);
+	LASSERTF(refc >= 1, "page = %p, refc = %d\n", page, refc);
+
+	ClearPageUptodate(vmpage);
 	ClearPagePrivate(vmpage);
 	vmpage->private = 0;
 	/*
@@ -404,7 +397,6 @@ static const struct cl_page_operations vvp_page_ops = {
 	.cpo_vmpage	= ccc_page_vmpage,
 	.cpo_discard       = vvp_page_discard,
 	.cpo_delete	= vvp_page_delete,
-	.cpo_unmap	 = vvp_page_unmap,
 	.cpo_export	= vvp_page_export,
 	.cpo_is_vmlocked   = vvp_page_is_vmlocked,
 	.cpo_fini	  = vvp_page_fini,
@@ -541,6 +533,8 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	INIT_LIST_HEAD(&cpg->cpg_pending_linkage);
 	if (page->cp_type == CPT_CACHEABLE) {
+		/* in cache, decref in vvp_page_delete */
+		atomic_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
 		cl_page_slice_add(page, &cpg->cpg_cl, obj, &vvp_page_ops);
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 1f8ed95..5d8a2b6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -287,7 +287,7 @@ static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
 
 	lov_layout_wait(env, lov);
 
-	cl_object_prune(env, &lov->lo_cl);
+	cl_locks_prune(env, &lov->lo_cl, 0);
 	return 0;
 }
 
@@ -364,7 +364,7 @@ static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			}
 		}
 	}
-	cl_object_prune(env, &lov->lo_cl);
+	cl_locks_prune(env, &lov->lo_cl, 0);
 	return 0;
 }
 
@@ -666,7 +666,6 @@ static int lov_layout_change(const struct lu_env *unused,
 	const struct lov_layout_operations *old_ops;
 	const struct lov_layout_operations *new_ops;
 
-	struct cl_object_header *hdr = cl_object_header(&lov->lo_cl);
 	void *cookie;
 	struct lu_env *env;
 	int refcheck;
@@ -691,13 +690,13 @@ static int lov_layout_change(const struct lu_env *unused,
 	old_ops = &lov_dispatch[lov->lo_type];
 	new_ops = &lov_dispatch[llt];
 
+	cl_object_prune(env, &lov->lo_cl);
+
 	result = old_ops->llo_delete(env, lov, &lov->u);
 	if (result == 0) {
 		old_ops->llo_fini(env, lov, &lov->u);
 
 		LASSERT(atomic_read(&lov->lo_active_ios) == 0);
-		LASSERT(!hdr->coh_tree.rnode);
-		LASSERT(hdr->coh_pages == 0);
 
 		lov->lo_type = LLT_EMPTY;
 		result = new_ops->llo_init(env,
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index fdcaf80..9728da2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -36,6 +36,7 @@
  * Implementation of cl_page for LOV layer.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
@@ -179,31 +180,21 @@ int lov_page_init_raid0(const struct lu_env *env, struct cl_object *obj,
 	cl_page_slice_add(page, &lpg->lps_cl, obj, &lov_page_ops);
 
 	sub = lov_sub_get(env, lio, stripe);
-	if (IS_ERR(sub)) {
-		rc = PTR_ERR(sub);
-		goto out;
-	}
+	if (IS_ERR(sub))
+		return PTR_ERR(sub);
 
 	subobj = lovsub2cl(r0->lo_sub[stripe]);
-	subpage = cl_page_find_sub(sub->sub_env, subobj,
-				   cl_index(subobj, suboff), vmpage, page);
-	lov_sub_put(sub);
-	if (IS_ERR(subpage)) {
-		rc = PTR_ERR(subpage);
-		goto out;
-	}
-
-	if (likely(subpage->cp_parent == page)) {
-		lu_ref_add(&subpage->cp_reference, "lov", page);
+	subpage = cl_page_alloc(sub->sub_env, subobj, cl_index(subobj, suboff),
+				vmpage, page->cp_type);
+	if (!IS_ERR(subpage)) {
+		subpage->cp_parent = page;
+		page->cp_child = subpage;
 		lpg->lps_invalid = 0;
-		rc = 0;
 	} else {
-		CL_PAGE_DEBUG(D_ERROR, env, page, "parent page\n");
-		CL_PAGE_DEBUG(D_ERROR, env, subpage, "child page\n");
-		LASSERT(0);
+		rc = PTR_ERR(subpage);
 	}
+	lov_sub_put(sub);
 
-out:
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index f5128b4..cf94284 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -36,6 +36,7 @@
  * Client IO.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index f952c1c..32ecc5a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -36,6 +36,7 @@
  * Client Extent Lock.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
@@ -1816,128 +1817,6 @@ struct cl_lock *cl_lock_at_pgoff(const struct lu_env *env,
 EXPORT_SYMBOL(cl_lock_at_pgoff);
 
 /**
- * Calculate the page offset at the layer of @lock.
- * At the time of this writing, @page is top page and @lock is sub lock.
- */
-static pgoff_t pgoff_at_lock(struct cl_page *page, struct cl_lock *lock)
-{
-	struct lu_device_type *dtype;
-	const struct cl_page_slice *slice;
-
-	dtype = lock->cll_descr.cld_obj->co_lu.lo_dev->ld_type;
-	slice = cl_page_at(page, dtype);
-	return slice->cpl_page->cp_index;
-}
-
-/**
- * Check if page @page is covered by an extra lock or discard it.
- */
-static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
-				struct cl_page *page, void *cbdata)
-{
-	struct cl_thread_info *info = cl_env_info(env);
-	struct cl_lock *lock = cbdata;
-	pgoff_t index = pgoff_at_lock(page, lock);
-
-	if (index >= info->clt_fn_index) {
-		struct cl_lock *tmp;
-
-		/* refresh non-overlapped index */
-		tmp = cl_lock_at_pgoff(env, lock->cll_descr.cld_obj, index,
-				       lock, 1, 0);
-		if (tmp) {
-			/* Cache the first-non-overlapped index so as to skip
-			 * all pages within [index, clt_fn_index). This
-			 * is safe because if tmp lock is canceled, it will
-			 * discard these pages.
-			 */
-			info->clt_fn_index = tmp->cll_descr.cld_end + 1;
-			if (tmp->cll_descr.cld_end == CL_PAGE_EOF)
-				info->clt_fn_index = CL_PAGE_EOF;
-			cl_lock_put(env, tmp);
-		} else if (cl_page_own(env, io, page) == 0) {
-			/* discard the page */
-			cl_page_unmap(env, io, page);
-			cl_page_discard(env, io, page);
-			cl_page_disown(env, io, page);
-		} else {
-			LASSERT(page->cp_state == CPS_FREEING);
-		}
-	}
-
-	info->clt_next_index = index + 1;
-	return CLP_GANG_OKAY;
-}
-
-static int discard_cb(const struct lu_env *env, struct cl_io *io,
-		      struct cl_page *page, void *cbdata)
-{
-	struct cl_thread_info *info = cl_env_info(env);
-	struct cl_lock *lock   = cbdata;
-
-	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
-	KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
-		      !PageWriteback(cl_page_vmpage(env, page))));
-	KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
-		      !PageDirty(cl_page_vmpage(env, page))));
-
-	info->clt_next_index = pgoff_at_lock(page, lock) + 1;
-	if (cl_page_own(env, io, page) == 0) {
-		/* discard the page */
-		cl_page_unmap(env, io, page);
-		cl_page_discard(env, io, page);
-		cl_page_disown(env, io, page);
-	} else {
-		LASSERT(page->cp_state == CPS_FREEING);
-	}
-
-	return CLP_GANG_OKAY;
-}
-
-/**
- * Discard pages protected by the given lock. This function traverses radix
- * tree to find all covering pages and discard them. If a page is being covered
- * by other locks, it should remain in cache.
- *
- * If error happens on any step, the process continues anyway (the reasoning
- * behind this being that lock cancellation cannot be delayed indefinitely).
- */
-int cl_lock_discard_pages(const struct lu_env *env, struct cl_lock *lock)
-{
-	struct cl_thread_info *info  = cl_env_info(env);
-	struct cl_io	  *io    = &info->clt_io;
-	struct cl_lock_descr  *descr = &lock->cll_descr;
-	cl_page_gang_cb_t      cb;
-	int res;
-	int result;
-
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	io->ci_obj = cl_object_top(descr->cld_obj);
-	io->ci_ignore_layout = 1;
-	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
-	if (result != 0)
-		goto out;
-
-	cb = descr->cld_mode == CLM_READ ? check_and_discard_cb : discard_cb;
-	info->clt_fn_index = info->clt_next_index = descr->cld_start;
-	do {
-		res = cl_page_gang_lookup(env, descr->cld_obj, io,
-					  info->clt_next_index, descr->cld_end,
-					  cb, (void *)lock);
-		if (info->clt_next_index > descr->cld_end)
-			break;
-
-		if (res == CLP_GANG_RESCHED)
-			cond_resched();
-	} while (res != CLP_GANG_OKAY);
-out:
-	cl_io_fini(env, io);
-	return result;
-}
-EXPORT_SYMBOL(cl_lock_discard_pages);
-
-/**
  * Eliminate all locks for a given object.
  *
  * Caller has to guarantee that no lock is in active use.
@@ -1951,12 +1830,6 @@ void cl_locks_prune(const struct lu_env *env, struct cl_object *obj, int cancel)
 	struct cl_lock	  *lock;
 
 	head = cl_object_header(obj);
-	/*
-	 * If locks are destroyed without cancellation, all pages must be
-	 * already destroyed (as otherwise they will be left unprotected).
-	 */
-	LASSERT(ergo(!cancel,
-		     !head->coh_tree.rnode && head->coh_pages == 0));
 
 	spin_lock(&head->coh_lock_guard);
 	while (!list_empty(&head->coh_locks)) {
@@ -2095,8 +1968,8 @@ void cl_lock_hold_add(const struct lu_env *env, struct cl_lock *lock,
 	LINVRNT(cl_lock_invariant(env, lock));
 	LASSERT(lock->cll_state != CLS_FREEING);
 
-	cl_lock_hold_mod(env, lock, 1);
 	cl_lock_get(lock);
+	cl_lock_hold_mod(env, lock, 1);
 	lu_ref_add(&lock->cll_holders, scope, source);
 	lu_ref_add(&lock->cll_reference, scope, source);
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 0772706..65b6402 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -36,6 +36,7 @@
  * Client Lustre Object.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 /*
@@ -43,7 +44,6 @@
  *
  *  i_mutex
  *      PG_locked
- *	  ->coh_page_guard
  *	  ->coh_lock_guard
  *	  ->coh_attr_guard
  *	  ->ls_guard
@@ -63,8 +63,6 @@
 
 static struct kmem_cache *cl_env_kmem;
 
-/** Lock class of cl_object_header::coh_page_guard */
-static struct lock_class_key cl_page_guard_class;
 /** Lock class of cl_object_header::coh_lock_guard */
 static struct lock_class_key cl_lock_guard_class;
 /** Lock class of cl_object_header::coh_attr_guard */
@@ -81,15 +79,10 @@ int cl_object_header_init(struct cl_object_header *h)
 
 	result = lu_object_header_init(&h->coh_lu);
 	if (result == 0) {
-		spin_lock_init(&h->coh_page_guard);
 		spin_lock_init(&h->coh_lock_guard);
 		spin_lock_init(&h->coh_attr_guard);
-		lockdep_set_class(&h->coh_page_guard, &cl_page_guard_class);
 		lockdep_set_class(&h->coh_lock_guard, &cl_lock_guard_class);
 		lockdep_set_class(&h->coh_attr_guard, &cl_attr_guard_class);
-		h->coh_pages = 0;
-		/* XXX hard coded GFP_* mask. */
-		INIT_RADIX_TREE(&h->coh_tree, GFP_ATOMIC);
 		INIT_LIST_HEAD(&h->coh_locks);
 		h->coh_page_bufsize = ALIGN(sizeof(struct cl_page), 8);
 	}
@@ -315,6 +308,32 @@ int cl_conf_set(const struct lu_env *env, struct cl_object *obj,
 EXPORT_SYMBOL(cl_conf_set);
 
 /**
+ * Prunes caches of pages and locks for this object.
+ */
+void cl_object_prune(const struct lu_env *env, struct cl_object *obj)
+{
+	struct lu_object_header *top;
+	struct cl_object *o;
+	int result;
+
+	top = obj->co_lu.lo_header;
+	result = 0;
+	list_for_each_entry(o, &top->loh_layers, co_lu.lo_linkage) {
+		if (o->co_ops->coo_prune) {
+			result = o->co_ops->coo_prune(env, o);
+			if (result != 0)
+				break;
+		}
+	}
+
+	/* TODO: pruning locks will be moved into layers after cl_lock
+	 * simplification is done
+	 */
+	cl_locks_prune(env, obj, 1);
+}
+EXPORT_SYMBOL(cl_object_prune);
+
+/**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
  *
@@ -326,8 +345,6 @@ void cl_object_kill(const struct lu_env *env, struct cl_object *obj)
 	struct cl_object_header *hdr;
 
 	hdr = cl_object_header(obj);
-	LASSERT(!hdr->coh_tree.rnode);
-	LASSERT(hdr->coh_pages == 0);
 
 	set_bit(LU_OBJECT_HEARD_BANSHEE, &hdr->coh_lu.loh_flags);
 	/*
@@ -341,16 +358,6 @@ void cl_object_kill(const struct lu_env *env, struct cl_object *obj)
 }
 EXPORT_SYMBOL(cl_object_kill);
 
-/**
- * Prunes caches of pages and locks for this object.
- */
-void cl_object_prune(const struct lu_env *env, struct cl_object *obj)
-{
-	cl_pages_prune(env, obj);
-	cl_locks_prune(env, obj, 1);
-}
-EXPORT_SYMBOL(cl_object_prune);
-
 void cache_stats_init(struct cache_stats *cs, const char *name)
 {
 	int i;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 231a2f2..8169836 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -36,6 +36,7 @@
  * Client Lustre Page.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
@@ -48,8 +49,7 @@
 #include "../include/cl_object.h"
 #include "cl_internal.h"
 
-static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg,
-			    int radix);
+static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg);
 
 # define PASSERT(env, page, expr)					   \
 	do {								   \
@@ -79,8 +79,7 @@ static struct cl_page *cl_page_top_trusted(struct cl_page *page)
  *
  * This function can be used to obtain initial reference to previously
  * unreferenced cached object. It can be called only if concurrent page
- * reclamation is somehow prevented, e.g., by locking page radix-tree
- * (cl_object_header::hdr->coh_page_guard), or by keeping a lock on a VM page,
+ * reclamation is somehow prevented, e.g., by keeping a lock on a VM page,
  * associated with \a page.
  *
  * Use with care! Not exported.
@@ -114,132 +113,6 @@ cl_page_at_trusted(const struct cl_page *page,
 	return NULL;
 }
 
-/**
- * Returns a page with given index in the given object, or NULL if no page is
- * found. Acquires a reference on \a page.
- *
- * Locking: called under cl_object_header::coh_page_guard spin-lock.
- */
-struct cl_page *cl_page_lookup(struct cl_object_header *hdr, pgoff_t index)
-{
-	struct cl_page *page;
-
-	assert_spin_locked(&hdr->coh_page_guard);
-
-	page = radix_tree_lookup(&hdr->coh_tree, index);
-	if (page)
-		cl_page_get_trust(page);
-	return page;
-}
-EXPORT_SYMBOL(cl_page_lookup);
-
-/**
- * Returns a list of pages by a given [start, end] of \a obj.
- *
- * \param resched If not NULL, then we give up before hogging CPU for too
- * long and set *resched = 1, in that case caller should implement a retry
- * logic.
- *
- * Gang tree lookup (radix_tree_gang_lookup()) optimization is absolutely
- * crucial in the face of [offset, EOF] locks.
- *
- * Return at least one page in @queue unless there is no covered page.
- */
-int cl_page_gang_lookup(const struct lu_env *env, struct cl_object *obj,
-			struct cl_io *io, pgoff_t start, pgoff_t end,
-			cl_page_gang_cb_t cb, void *cbdata)
-{
-	struct cl_object_header *hdr;
-	struct cl_page	  *page;
-	struct cl_page	 **pvec;
-	const struct cl_page_slice  *slice;
-	const struct lu_device_type *dtype;
-	pgoff_t		  idx;
-	unsigned int	     nr;
-	unsigned int	     i;
-	unsigned int	     j;
-	int		      res = CLP_GANG_OKAY;
-	int		      tree_lock = 1;
-
-	idx = start;
-	hdr = cl_object_header(obj);
-	pvec = cl_env_info(env)->clt_pvec;
-	dtype = cl_object_top(obj)->co_lu.lo_dev->ld_type;
-	spin_lock(&hdr->coh_page_guard);
-	while ((nr = radix_tree_gang_lookup(&hdr->coh_tree, (void **)pvec,
-					    idx, CLT_PVEC_SIZE)) > 0) {
-		int end_of_region = 0;
-
-		idx = pvec[nr - 1]->cp_index + 1;
-		for (i = 0, j = 0; i < nr; ++i) {
-			page = pvec[i];
-			pvec[i] = NULL;
-
-			LASSERT(page->cp_type == CPT_CACHEABLE);
-			if (page->cp_index > end) {
-				end_of_region = 1;
-				break;
-			}
-			if (page->cp_state == CPS_FREEING)
-				continue;
-
-			slice = cl_page_at_trusted(page, dtype);
-			/*
-			 * Pages for lsm-less file has no underneath sub-page
-			 * for osc, in case of ...
-			 */
-			PASSERT(env, page, slice);
-
-			page = slice->cpl_page;
-			/*
-			 * Can safely call cl_page_get_trust() under
-			 * radix-tree spin-lock.
-			 *
-			 * XXX not true, because @page is from object another
-			 * than @hdr and protected by different tree lock.
-			 */
-			cl_page_get_trust(page);
-			lu_ref_add_atomic(&page->cp_reference,
-					  "gang_lookup", current);
-			pvec[j++] = page;
-		}
-
-		/*
-		 * Here a delicate locking dance is performed. Current thread
-		 * holds a reference to a page, but has to own it before it
-		 * can be placed into queue. Owning implies waiting, so
-		 * radix-tree lock is to be released. After a wait one has to
-		 * check that pages weren't truncated (cl_page_own() returns
-		 * error in the latter case).
-		 */
-		spin_unlock(&hdr->coh_page_guard);
-		tree_lock = 0;
-
-		for (i = 0; i < j; ++i) {
-			page = pvec[i];
-			if (res == CLP_GANG_OKAY)
-				res = (*cb)(env, io, page, cbdata);
-			lu_ref_del(&page->cp_reference,
-				   "gang_lookup", current);
-			cl_page_put(env, page);
-		}
-		if (nr < CLT_PVEC_SIZE || end_of_region)
-			break;
-
-		if (res == CLP_GANG_OKAY && need_resched())
-			res = CLP_GANG_RESCHED;
-		if (res != CLP_GANG_OKAY)
-			break;
-
-		spin_lock(&hdr->coh_page_guard);
-		tree_lock = 1;
-	}
-	if (tree_lock)
-		spin_unlock(&hdr->coh_page_guard);
-	return res;
-}
-EXPORT_SYMBOL(cl_page_gang_lookup);
-
 static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 {
 	struct cl_object *obj  = page->cp_obj;
@@ -276,10 +149,10 @@ static inline void cl_page_state_set_trust(struct cl_page *page,
 	*(enum cl_page_state *)&page->cp_state = state;
 }
 
-static struct cl_page *cl_page_alloc(const struct lu_env *env,
-				     struct cl_object *o, pgoff_t ind,
-				     struct page *vmpage,
-				     enum cl_page_type type)
+struct cl_page *cl_page_alloc(const struct lu_env *env,
+			      struct cl_object *o, pgoff_t ind,
+			      struct page *vmpage,
+			      enum cl_page_type type)
 {
 	struct cl_page	  *page;
 	struct lu_object_header *head;
@@ -289,8 +162,6 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
 		int result = 0;
 
 		atomic_set(&page->cp_ref, 1);
-		if (type == CPT_CACHEABLE) /* for radix tree */
-			atomic_inc(&page->cp_ref);
 		page->cp_obj = o;
 		cl_object_get(o);
 		lu_object_ref_add_at(&o->co_lu, &page->cp_obj_ref, "cl_page",
@@ -309,7 +180,7 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
 				result = o->co_ops->coo_page_init(env, o,
 								  page, vmpage);
 				if (result != 0) {
-					cl_page_delete0(env, page, 0);
+					cl_page_delete0(env, page);
 					cl_page_free(env, page);
 					page = ERR_PTR(result);
 					break;
@@ -321,6 +192,7 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
 	}
 	return page;
 }
+EXPORT_SYMBOL(cl_page_alloc);
 
 /**
  * Returns a cl_page with index \a idx at the object \a o, and associated with
@@ -333,16 +205,13 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
  *
  * \see cl_object_find(), cl_lock_find()
  */
-static struct cl_page *cl_page_find0(const struct lu_env *env,
-				     struct cl_object *o,
-				     pgoff_t idx, struct page *vmpage,
-				     enum cl_page_type type,
-				     struct cl_page *parent)
+struct cl_page *cl_page_find(const struct lu_env *env,
+			     struct cl_object *o,
+			     pgoff_t idx, struct page *vmpage,
+			     enum cl_page_type type)
 {
 	struct cl_page	  *page = NULL;
-	struct cl_page	  *ghost = NULL;
 	struct cl_object_header *hdr;
-	int err;
 
 	LASSERT(type == CPT_CACHEABLE || type == CPT_TRANSIENT);
 	might_sleep();
@@ -368,90 +237,19 @@ static struct cl_page *cl_page_find0(const struct lu_env *env,
 		 *       reference on it.
 		 */
 		page = cl_vmpage_page(vmpage, o);
-		PINVRNT(env, page,
-			ergo(page,
-			     cl_page_vmpage(env, page) == vmpage &&
-			     (void *)radix_tree_lookup(&hdr->coh_tree,
-						       idx) == page));
-	}
 
-	if (page)
-		return page;
+		if (page)
+			return page;
+	}
 
 	/* allocate and initialize cl_page */
 	page = cl_page_alloc(env, o, idx, vmpage, type);
-	if (IS_ERR(page))
-		return page;
-
-	if (type == CPT_TRANSIENT) {
-		if (parent) {
-			LASSERT(!page->cp_parent);
-			page->cp_parent = parent;
-			parent->cp_child = page;
-		}
-		return page;
-	}
-
-	/*
-	 * XXX optimization: use radix_tree_preload() here, and change tree
-	 * gfp mask to GFP_KERNEL in cl_object_header_init().
-	 */
-	spin_lock(&hdr->coh_page_guard);
-	err = radix_tree_insert(&hdr->coh_tree, idx, page);
-	if (err != 0) {
-		ghost = page;
-		/*
-		 * Noted by Jay: a lock on \a vmpage protects cl_page_find()
-		 * from this race, but
-		 *
-		 *     0. it's better to have cl_page interface "locally
-		 *     consistent" so that its correctness can be reasoned
-		 *     about without appealing to the (obscure world of) VM
-		 *     locking.
-		 *
-		 *     1. handling this race allows ->coh_tree to remain
-		 *     consistent even when VM locking is somehow busted,
-		 *     which is very useful during diagnosing and debugging.
-		 */
-		page = ERR_PTR(err);
-		CL_PAGE_DEBUG(D_ERROR, env, ghost,
-			      "fail to insert into radix tree: %d\n", err);
-	} else {
-		if (parent) {
-			LASSERT(!page->cp_parent);
-			page->cp_parent = parent;
-			parent->cp_child = page;
-		}
-		hdr->coh_pages++;
-	}
-	spin_unlock(&hdr->coh_page_guard);
-
-	if (unlikely(ghost)) {
-		cl_page_delete0(env, ghost, 0);
-		cl_page_free(env, ghost);
-	}
 	return page;
 }
-
-struct cl_page *cl_page_find(const struct lu_env *env, struct cl_object *o,
-			     pgoff_t idx, struct page *vmpage,
-			     enum cl_page_type type)
-{
-	return cl_page_find0(env, o, idx, vmpage, type, NULL);
-}
 EXPORT_SYMBOL(cl_page_find);
 
-struct cl_page *cl_page_find_sub(const struct lu_env *env, struct cl_object *o,
-				 pgoff_t idx, struct page *vmpage,
-				 struct cl_page *parent)
-{
-	return cl_page_find0(env, o, idx, vmpage, parent->cp_type, parent);
-}
-EXPORT_SYMBOL(cl_page_find_sub);
-
 static inline int cl_page_invariant(const struct cl_page *pg)
 {
-	struct cl_object_header *header;
 	struct cl_page	  *parent;
 	struct cl_page	  *child;
 	struct cl_io	    *owner;
@@ -461,7 +259,6 @@ static inline int cl_page_invariant(const struct cl_page *pg)
 	 */
 	LINVRNT(cl_page_is_vmlocked(NULL, pg));
 
-	header = cl_object_header(pg->cp_obj);
 	parent = pg->cp_parent;
 	child  = pg->cp_child;
 	owner  = pg->cp_owner;
@@ -473,15 +270,7 @@ static inline int cl_page_invariant(const struct cl_page *pg)
 		ergo(parent, pg->cp_obj != parent->cp_obj) &&
 		ergo(owner && parent,
 		     parent->cp_owner == pg->cp_owner->ci_parent) &&
-		ergo(owner && child, child->cp_owner->ci_parent == owner) &&
-		/*
-		 * Either page is early in initialization (has neither child
-		 * nor parent yet), or it is in the object radix tree.
-		 */
-		ergo(pg->cp_state < CPS_FREEING && pg->cp_type == CPT_CACHEABLE,
-		     (void *)radix_tree_lookup(&header->coh_tree,
-					       pg->cp_index) == pg ||
-		     (!child && !parent));
+		ergo(owner && child, child->cp_owner->ci_parent == owner);
 }
 
 static void cl_page_state_set0(const struct lu_env *env,
@@ -1001,11 +790,8 @@ EXPORT_SYMBOL(cl_page_discard);
  * pages, e.g,. in a error handling cl_page_find()->cl_page_delete0()
  * path. Doesn't check page invariant.
  */
-static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg,
-			    int radix)
+static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
 {
-	struct cl_page *tmp = pg;
-
 	PASSERT(env, pg, pg == cl_page_top(pg));
 	PASSERT(env, pg, pg->cp_state != CPS_FREEING);
 
@@ -1014,41 +800,11 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg,
 	 */
 	cl_page_owner_clear(pg);
 
-	/*
-	 * unexport the page firstly before freeing it so that
-	 * the page content is considered to be invalid.
-	 * We have to do this because a CPS_FREEING cl_page may
-	 * be NOT under the protection of a cl_lock.
-	 * Afterwards, if this page is found by other threads, then this
-	 * page will be forced to reread.
-	 */
-	cl_page_export(env, pg, 0);
 	cl_page_state_set0(env, pg, CPS_FREEING);
 
-	CL_PAGE_INVOID(env, pg, CL_PAGE_OP(cpo_delete),
-		       (const struct lu_env *, const struct cl_page_slice *));
-
-	if (tmp->cp_type == CPT_CACHEABLE) {
-		if (!radix)
-			/* !radix means that @pg is not yet in the radix tree,
-			 * skip removing it.
-			 */
-			tmp = pg->cp_child;
-		for (; tmp; tmp = tmp->cp_child) {
-			void		    *value;
-			struct cl_object_header *hdr;
-
-			hdr = cl_object_header(tmp->cp_obj);
-			spin_lock(&hdr->coh_page_guard);
-			value = radix_tree_delete(&hdr->coh_tree,
-						  tmp->cp_index);
-			PASSERT(env, tmp, value == tmp);
-			PASSERT(env, tmp, hdr->coh_pages > 0);
-			hdr->coh_pages--;
-			spin_unlock(&hdr->coh_page_guard);
-			cl_page_put(env, tmp);
-		}
-	}
+	CL_PAGE_INVOID_REVERSE(env, pg, CL_PAGE_OP(cpo_delete),
+			       (const struct lu_env *,
+				const struct cl_page_slice *));
 }
 
 /**
@@ -1079,30 +835,11 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg,
 void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
 {
 	PINVRNT(env, pg, cl_page_invariant(pg));
-	cl_page_delete0(env, pg, 1);
+	cl_page_delete0(env, pg);
 }
 EXPORT_SYMBOL(cl_page_delete);
 
 /**
- * Unmaps page from user virtual memory.
- *
- * Calls cl_page_operations::cpo_unmap() through all layers top-to-bottom. The
- * layer responsible for VM interaction has to unmap page from user space
- * virtual memory.
- *
- * \see cl_page_operations::cpo_unmap()
- */
-int cl_page_unmap(const struct lu_env *env,
-		  struct cl_io *io, struct cl_page *pg)
-{
-	PINVRNT(env, pg, cl_page_is_owned(pg, io));
-	PINVRNT(env, pg, cl_page_invariant(pg));
-
-	return cl_page_invoke(env, io, pg, CL_PAGE_OP(cpo_unmap));
-}
-EXPORT_SYMBOL(cl_page_unmap);
-
-/**
  * Marks page up-to-date.
  *
  * Call cl_page_operations::cpo_export() through all layers top-to-bottom. The
@@ -1359,53 +1096,6 @@ int cl_page_is_under_lock(const struct lu_env *env, struct cl_io *io,
 }
 EXPORT_SYMBOL(cl_page_is_under_lock);
 
-static int page_prune_cb(const struct lu_env *env, struct cl_io *io,
-			 struct cl_page *page, void *cbdata)
-{
-	cl_page_own(env, io, page);
-	cl_page_unmap(env, io, page);
-	cl_page_discard(env, io, page);
-	cl_page_disown(env, io, page);
-	return CLP_GANG_OKAY;
-}
-
-/**
- * Purges all cached pages belonging to the object \a obj.
- */
-int cl_pages_prune(const struct lu_env *env, struct cl_object *clobj)
-{
-	struct cl_thread_info   *info;
-	struct cl_object	*obj = cl_object_top(clobj);
-	struct cl_io	    *io;
-	int		      result;
-
-	info  = cl_env_info(env);
-	io    = &info->clt_io;
-
-	/*
-	 * initialize the io. This is ugly since we never do IO in this
-	 * function, we just make cl_page_list functions happy. -jay
-	 */
-	io->ci_obj = obj;
-	io->ci_ignore_layout = 1;
-	result = cl_io_init(env, io, CIT_MISC, obj);
-	if (result != 0) {
-		cl_io_fini(env, io);
-		return io->ci_result;
-	}
-
-	do {
-		result = cl_page_gang_lookup(env, obj, io, 0, CL_PAGE_EOF,
-					     page_prune_cb, NULL);
-		if (result == CLP_GANG_RESCHED)
-			cond_resched();
-	} while (result != CLP_GANG_OKAY);
-
-	cl_io_fini(env, io);
-	return result;
-}
-EXPORT_SYMBOL(cl_pages_prune);
-
 /**
  * Tells transfer engine that only part of a page is to be transmitted.
  *
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 6196c3b..c9d4e3c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1015,7 +1015,6 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		lu_ref_add(&page->cp_reference, "truncate", current);
 
 		if (cl_page_own(env, io, page) == 0) {
-			cl_page_unmap(env, io, page);
 			cl_page_discard(env, io, page);
 			cl_page_disown(env, io, page);
 		} else {
@@ -2136,8 +2135,7 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 
 		cl_object_get(obj);
 		client_obd_list_unlock(&cli->cl_loi_list_lock);
-		lu_object_ref_add_at(&obj->co_lu, &link, "check",
-				     current);
+		lu_object_ref_add_at(&obj->co_lu, &link, "check", current);
 
 		/* attempt some read/write balancing by alternating between
 		 * reads and writes in an object.  The makes_rpc checks here
@@ -2180,8 +2178,7 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 		osc_object_unlock(osc);
 
 		osc_list_maint(cli, osc);
-		lu_object_ref_del_at(&obj->co_lu, &link, "check",
-				     current);
+		lu_object_ref_del_at(&obj->co_lu, &link, "check", current);
 		cl_object_put(env, obj);
 
 		client_obd_list_lock(&cli->cl_loi_list_lock);
@@ -2994,4 +2991,204 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 	return result;
 }
 
+/**
+ * Returns a list of pages by a given [start, end] of \a obj.
+ *
+ * \param resched If not NULL, then we give up before hogging CPU for too
+ * long and set *resched = 1, in that case caller should implement a retry
+ * logic.
+ *
+ * Gang tree lookup (radix_tree_gang_lookup()) optimization is absolutely
+ * crucial in the face of [offset, EOF] locks.
+ *
+ * Return at least one page in @queue unless there is no covered page.
+ */
+int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			 struct osc_object *osc, pgoff_t start, pgoff_t end,
+			 osc_page_gang_cbt cb, void *cbdata)
+{
+	struct osc_page *ops;
+	void            **pvec;
+	pgoff_t         idx;
+	unsigned int    nr;
+	unsigned int    i;
+	unsigned int    j;
+	int             res = CLP_GANG_OKAY;
+	bool            tree_lock = true;
+
+	idx = start;
+	pvec = osc_env_info(env)->oti_pvec;
+	spin_lock(&osc->oo_tree_lock);
+	while ((nr = radix_tree_gang_lookup(&osc->oo_tree, pvec,
+					    idx, OTI_PVEC_SIZE)) > 0) {
+		struct cl_page *page;
+		bool end_of_region = false;
+
+		for (i = 0, j = 0; i < nr; ++i) {
+			ops = pvec[i];
+			pvec[i] = NULL;
+
+			idx = osc_index(ops);
+			if (idx > end) {
+				end_of_region = true;
+				break;
+			}
+
+			page = cl_page_top(ops->ops_cl.cpl_page);
+			LASSERT(page->cp_type == CPT_CACHEABLE);
+			if (page->cp_state == CPS_FREEING)
+				continue;
+
+			cl_page_get(page);
+			lu_ref_add_atomic(&page->cp_reference,
+					  "gang_lookup", current);
+			pvec[j++] = ops;
+		}
+		++idx;
+
+		/*
+		 * Here a delicate locking dance is performed. Current thread
+		 * holds a reference to a page, but has to own it before it
+		 * can be placed into queue. Owning implies waiting, so
+		 * radix-tree lock is to be released. After a wait one has to
+		 * check that pages weren't truncated (cl_page_own() returns
+		 * error in the latter case).
+		 */
+		spin_unlock(&osc->oo_tree_lock);
+		tree_lock = false;
+
+		for (i = 0; i < j; ++i) {
+			ops = pvec[i];
+			if (res == CLP_GANG_OKAY)
+				res = (*cb)(env, io, ops, cbdata);
+
+			page = cl_page_top(ops->ops_cl.cpl_page);
+			lu_ref_del(&page->cp_reference, "gang_lookup", current);
+			cl_page_put(env, page);
+		}
+		if (nr < OTI_PVEC_SIZE || end_of_region)
+			break;
+
+		if (res == CLP_GANG_OKAY && need_resched())
+			res = CLP_GANG_RESCHED;
+		if (res != CLP_GANG_OKAY)
+			break;
+
+		spin_lock(&osc->oo_tree_lock);
+		tree_lock = true;
+	}
+	if (tree_lock)
+		spin_unlock(&osc->oo_tree_lock);
+	return res;
+}
+
+/**
+ * Check if page @page is covered by an extra lock or discard it.
+ */
+static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
+				struct osc_page *ops, void *cbdata)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct cl_lock *lock = cbdata;
+	pgoff_t index;
+
+	index = osc_index(ops);
+	if (index >= info->oti_fn_index) {
+		struct cl_lock *tmp;
+		struct cl_page *page = cl_page_top(ops->ops_cl.cpl_page);
+
+		/* refresh non-overlapped index */
+		tmp = cl_lock_at_pgoff(env, lock->cll_descr.cld_obj, index,
+				       lock, 1, 0);
+		if (tmp) {
+			/* Cache the first-non-overlapped index so as to skip
+			 * all pages within [index, oti_fn_index). This
+			 * is safe because if tmp lock is canceled, it will
+			 * discard these pages.
+			 */
+			info->oti_fn_index = tmp->cll_descr.cld_end + 1;
+			if (tmp->cll_descr.cld_end == CL_PAGE_EOF)
+				info->oti_fn_index = CL_PAGE_EOF;
+			cl_lock_put(env, tmp);
+		} else if (cl_page_own(env, io, page) == 0) {
+			/* discard the page */
+			cl_page_discard(env, io, page);
+			cl_page_disown(env, io, page);
+		} else {
+			LASSERT(page->cp_state == CPS_FREEING);
+		}
+	}
+
+	info->oti_next_index = index + 1;
+	return CLP_GANG_OKAY;
+}
+
+static int discard_cb(const struct lu_env *env, struct cl_io *io,
+		      struct osc_page *ops, void *cbdata)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct cl_lock *lock = cbdata;
+	struct cl_page *page = cl_page_top(ops->ops_cl.cpl_page);
+
+	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
+	KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
+		      !PageWriteback(cl_page_vmpage(env, page))));
+	KLASSERT(ergo(page->cp_type == CPT_CACHEABLE,
+		      !PageDirty(cl_page_vmpage(env, page))));
+
+	/* page is top page. */
+	info->oti_next_index = osc_index(ops) + 1;
+	if (cl_page_own(env, io, page) == 0) {
+		/* discard the page */
+		cl_page_discard(env, io, page);
+		cl_page_disown(env, io, page);
+	} else {
+		LASSERT(page->cp_state == CPS_FREEING);
+	}
+
+	return CLP_GANG_OKAY;
+}
+
+/**
+ * Discard pages protected by the given lock. This function traverses radix
+ * tree to find all covering pages and discard them. If a page is being covered
+ * by other locks, it should remain in cache.
+ *
+ * If error happens on any step, the process continues anyway (the reasoning
+ * behind this being that lock cancellation cannot be delayed indefinitely).
+ */
+int osc_lock_discard_pages(const struct lu_env *env, struct osc_lock *ols)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct cl_io *io = &info->oti_io;
+	struct cl_object *osc = ols->ols_cl.cls_obj;
+	struct cl_lock *lock = ols->ols_cl.cls_lock;
+	struct cl_lock_descr *descr = &lock->cll_descr;
+	osc_page_gang_cbt cb;
+	int res;
+	int result;
+
+	io->ci_obj = cl_object_top(osc);
+	io->ci_ignore_layout = 1;
+	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
+	if (result != 0)
+		goto out;
+
+	cb = descr->cld_mode == CLM_READ ? check_and_discard_cb : discard_cb;
+	info->oti_fn_index = info->oti_next_index = descr->cld_start;
+	do {
+		res = osc_page_gang_lookup(env, io, cl2osc(osc),
+					   info->oti_next_index, descr->cld_end,
+					   cb, (void *)lock);
+		if (info->oti_next_index > descr->cld_end)
+			break;
+
+		if (res == CLP_GANG_RESCHED)
+			cond_resched();
+	} while (res != CLP_GANG_OKAY);
+out:
+	cl_io_fini(env, io);
+	return result;
+}
+
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index b6325f5..e70f06c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -111,7 +111,12 @@ struct osc_thread_info {
 	struct lustre_handle    oti_handle;
 	struct cl_page_list     oti_plist;
 	struct cl_io		oti_io;
-	struct cl_page	       *oti_pvec[OTI_PVEC_SIZE];
+	void			*oti_pvec[OTI_PVEC_SIZE];
+	/**
+	 * Fields used by cl_lock_discard_pages().
+	 */
+	pgoff_t			oti_next_index;
+	pgoff_t			oti_fn_index; /* first non-overlapped index */
 };
 
 struct osc_object {
@@ -161,6 +166,13 @@ struct osc_object {
 	 * oo_{read|write}_pages soon.
 	 */
 	spinlock_t	    oo_lock;
+
+	/**
+	 * Radix tree for caching pages
+	 */
+	struct radix_tree_root	oo_tree;
+	spinlock_t		oo_tree_lock;
+	unsigned long		oo_npages;
 };
 
 static inline void osc_object_lock(struct osc_object *obj)
@@ -569,6 +581,11 @@ static inline struct osc_page *oap2osc_page(struct osc_async_page *oap)
 	return (struct osc_page *)container_of(oap, struct osc_page, ops_oap);
 }
 
+static inline pgoff_t osc_index(struct osc_page *opg)
+{
+	return opg->ops_cl.cpl_page->cp_index;
+}
+
 static inline struct osc_lock *cl2osc_lock(const struct cl_lock_slice *slice)
 {
 	LINVRNT(osc_is_object(&slice->cls_obj->co_lu));
@@ -691,6 +708,14 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		      int sent, int rc);
 void osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
 
+int osc_lock_discard_pages(const struct lu_env *env, struct osc_lock *lock);
+
+typedef int (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
+				 struct osc_page *, void *);
+int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			 struct osc_object *osc, pgoff_t start, pgoff_t end,
+			 osc_page_gang_cbt cb, void *cbdata);
+
 /** @} osc */
 
 #endif /* OSC_CL_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index a0fa533..1536d31 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -391,18 +391,13 @@ static int osc_async_upcall(void *a, int rc)
  * Checks that there are no pages being written in the extent being truncated.
  */
 static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
-			  struct cl_page *page, void *cbdata)
+			  struct osc_page *ops, void *cbdata)
 {
-	const struct cl_page_slice *slice;
-	struct osc_page *ops;
+	struct cl_page *page = ops->ops_cl.cpl_page;
 	struct osc_async_page *oap;
 	__u64 start = *(__u64 *)cbdata;
 
-	slice = cl_page_at(page, &osc_device_type);
-	LASSERT(slice);
-	ops = cl2osc_page(slice);
 	oap = &ops->ops_oap;
-
 	if (oap->oap_cmd & OBD_BRW_WRITE &&
 	    !list_empty(&oap->oap_pending_item))
 		CL_PAGE_DEBUG(D_ERROR, env, page, "exists %llu/%s.\n",
@@ -434,8 +429,9 @@ static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
 	/*
 	 * Complain if there are pages in the truncated region.
 	 */
-	cl_page_gang_lookup(env, clob, io, start + partial, CL_PAGE_EOF,
-			    trunc_check_cb, (void *)&size);
+	osc_page_gang_lookup(env, io, cl2osc(clob),
+			     start + partial, CL_PAGE_EOF,
+			     trunc_check_cb, (void *)&size);
 }
 
 static int osc_io_setattr_start(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 013df97..3a8a6d1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -36,6 +36,7 @@
  * Implementation of cl_lock for OSC layer.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_OSC
@@ -897,11 +898,8 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 static unsigned long osc_lock_weigh(const struct lu_env *env,
 				    const struct cl_lock_slice *slice)
 {
-	/*
-	 * don't need to grab coh_page_guard since we don't care the exact #
-	 * of pages..
-	 */
-	return cl_object_header(slice->cls_obj)->coh_pages;
+	/* TODO: check how many pages are covered by this lock */
+	return cl2osc(slice->cls_obj)->oo_npages;
 }
 
 static void osc_lock_build_einfo(const struct lu_env *env,
@@ -1276,7 +1274,7 @@ static int osc_lock_flush(struct osc_lock *ols, int discard)
 				result = 0;
 		}
 
-		rc = cl_lock_discard_pages(env, lock);
+		rc = osc_lock_discard_pages(env, ols);
 		if (result == 0 && rc < 0)
 			result = rc;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 9d474fc..2d2d39a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -36,6 +36,7 @@
  * Implementation of cl_object for OSC layer.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_OSC
@@ -94,6 +95,7 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 	atomic_set(&osc->oo_nr_reads, 0);
 	atomic_set(&osc->oo_nr_writes, 0);
 	spin_lock_init(&osc->oo_lock);
+	spin_lock_init(&osc->oo_tree_lock);
 
 	cl_object_page_init(lu2cl(obj), sizeof(struct osc_page));
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index f0a9870..91ff607 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -36,6 +36,7 @@
  * Implementation of cl_page for OSC layer.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
+ *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_OSC
@@ -326,6 +327,18 @@ static void osc_page_delete(const struct lu_env *env,
 	spin_unlock(&obj->oo_seatbelt);
 
 	osc_lru_del(osc_cli(obj), opg);
+
+	if (slice->cpl_page->cp_type == CPT_CACHEABLE) {
+		void *value;
+
+		spin_lock(&obj->oo_tree_lock);
+		value = radix_tree_delete(&obj->oo_tree, osc_index(opg));
+		if (value)
+			--obj->oo_npages;
+		spin_unlock(&obj->oo_tree_lock);
+
+		LASSERT(ergo(value, value == opg));
+	}
 }
 
 static void osc_page_clip(const struct lu_env *env,
@@ -422,8 +435,18 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	INIT_LIST_HEAD(&opg->ops_lru);
 
 	/* reserve an LRU space for this page */
-	if (page->cp_type == CPT_CACHEABLE && result == 0)
+	if (page->cp_type == CPT_CACHEABLE && result == 0) {
 		result = osc_lru_reserve(env, osc, opg);
+		if (result == 0) {
+			spin_lock(&osc->oo_tree_lock);
+			result = radix_tree_insert(&osc->oo_tree,
+						   page->cp_index, opg);
+			if (result == 0)
+				++osc->oo_npages;
+			spin_unlock(&osc->oo_tree_lock);
+			LASSERT(result == 0);
+		}
+	}
 
 	return result;
 }
@@ -611,7 +634,6 @@ static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
 		struct cl_page *page = pvec[i];
 
 		LASSERT(cl_page_is_owned(page, io));
-		cl_page_unmap(env, io, page);
 		cl_page_discard(env, io, page);
 		cl_page_disown(env, io, page);
 		cl_page_put(env, page);
@@ -652,7 +674,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		atomic_inc(&cli->cl_lru_shrinkers);
 	}
 
-	pvec = osc_env_info(env)->oti_pvec;
+	pvec = (struct cl_page **)osc_env_info(env)->oti_pvec;
 	io = &osc_env_info(env)->oti_io;
 
 	client_obd_list_lock(&cli->cl_lru_list_lock);
-- 
2.1.0
