From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:56 -0400
Subject: [lustre-devel] [PATCH 15/37] lustre: obdclass: use offset instead
 of cp_linkage
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Since we have fixed-size cl_page allocations, we could use
offset array to store every slices pointer for cl_page.

With this patch, we will reduce cl_page size from 392 bytes
to 336 bytes which means we could allocate from 10 to 12 objects.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13134
Lustre-commit: 55967f1e5c701 ("LU-13134 obdclass: use offset instead of cp_linkage")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/37428
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |   8 +-
 fs/lustre/obdclass/cl_page.c  | 284 ++++++++++++++++++++++++------------------
 2 files changed, 168 insertions(+), 124 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index a0b9e87..47997f8 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -737,8 +737,10 @@ struct cl_page {
 	struct page			*cp_vmpage;
 	/** Linkage of pages within group. Pages must be owned */
 	struct list_head		 cp_batch;
-	/** List of slices. Immutable after creation. */
-	struct list_head		 cp_layers;
+	/** array of slices offset. Immutable after creation. */
+	unsigned char			 cp_layer_offset[3];
+	/** current slice index */
+	unsigned char			 cp_layer_count:2;
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
 	 * modified only internally within cl_page.c. Protected by a VM lock.
@@ -781,8 +783,6 @@ struct cl_page_slice {
 	 */
 	struct cl_object		*cpl_obj;
 	const struct cl_page_operations *cpl_ops;
-	/** Linkage into cl_page::cp_layers. Immutable after creation. */
-	struct list_head		 cpl_linkage;
 };
 
 /**
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index d5be0c5..cced026 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -72,22 +72,47 @@ static void cl_page_get_trust(struct cl_page *page)
 	refcount_inc(&page->cp_ref);
 }
 
+static struct cl_page_slice *
+cl_page_slice_get(const struct cl_page *cl_page, int index)
+{
+	if (index < 0 || index >= cl_page->cp_layer_count)
+		return NULL;
+
+	/* To get the cp_layer_offset values fit under 256 bytes, we
+	 * use the offset beyond the end of struct cl_page.
+	 */
+	return (struct cl_page_slice *)((char *)cl_page + sizeof(*cl_page) +
+					cl_page->cp_layer_offset[index]);
+}
+
+#define cl_page_slice_for_each(cl_page, slice, i)		\
+	for (i = 0, slice = cl_page_slice_get(cl_page, 0);	\
+	     i < (cl_page)->cp_layer_count;			\
+	     slice = cl_page_slice_get(cl_page, ++i))
+
+#define cl_page_slice_for_each_reverse(cl_page, slice, i)	\
+	for (i = (cl_page)->cp_layer_count - 1,			\
+	     slice = cl_page_slice_get(cl_page, i); i >= 0;	\
+	     slice = cl_page_slice_get(cl_page, --i))
+
 /**
- * Returns a slice within a page, corresponding to the given layer in the
+ * Returns a slice within a cl_page, corresponding to the given layer in the
  * device stack.
  *
  * \see cl_lock_at()
  */
 static const struct cl_page_slice *
-cl_page_at_trusted(const struct cl_page *page,
+cl_page_at_trusted(const struct cl_page *cl_page,
 		   const struct lu_device_type *dtype)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
-	list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_obj->co_lu.lo_dev->ld_type == dtype)
 			return slice;
 	}
+
 	return NULL;
 }
 
@@ -104,28 +129,28 @@ static void __cl_page_free(struct cl_page *cl_page, unsigned short bufsize)
 	}
 }
 
-static void cl_page_free(const struct lu_env *env, struct cl_page *page,
+static void cl_page_free(const struct lu_env *env, struct cl_page *cl_page,
 			 struct pagevec *pvec)
 {
-	struct cl_object *obj = page->cp_obj;
-	struct cl_page_slice *slice;
+	struct cl_object *obj = cl_page->cp_obj;
 	unsigned short bufsize = cl_object_header(obj)->coh_page_bufsize;
+	struct cl_page_slice *slice;
+	int i;
 
-	PASSERT(env, page, list_empty(&page->cp_batch));
-	PASSERT(env, page, !page->cp_owner);
-	PASSERT(env, page, page->cp_state == CPS_FREEING);
+	PASSERT(env, cl_page, list_empty(&cl_page->cp_batch));
+	PASSERT(env, cl_page, !cl_page->cp_owner);
+	PASSERT(env, cl_page, cl_page->cp_state == CPS_FREEING);
 
-	while ((slice = list_first_entry_or_null(&page->cp_layers,
-						 struct cl_page_slice,
-						 cpl_linkage)) != NULL) {
-		list_del_init(page->cp_layers.next);
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (unlikely(slice->cpl_ops->cpo_fini))
 			slice->cpl_ops->cpo_fini(env, slice, pvec);
 	}
-	lu_object_ref_del_at(&obj->co_lu, &page->cp_obj_ref, "cl_page", page);
+	cl_page->cp_layer_count = 0;
+	lu_object_ref_del_at(&obj->co_lu, &cl_page->cp_obj_ref,
+			     "cl_page", cl_page);
 	cl_object_put(env, obj);
-	lu_ref_fini(&page->cp_reference);
-	__cl_page_free(page, bufsize);
+	lu_ref_fini(&cl_page->cp_reference);
+	__cl_page_free(cl_page, bufsize);
 }
 
 /**
@@ -212,7 +237,6 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		page->cp_vmpage = vmpage;
 		cl_page_state_set_trust(page, CPS_CACHED);
 		page->cp_type = type;
-		INIT_LIST_HEAD(&page->cp_layers);
 		INIT_LIST_HEAD(&page->cp_batch);
 		lu_ref_init(&page->cp_reference);
 		cl_object_for_each(o2, o) {
@@ -455,22 +479,23 @@ static void cl_page_owner_set(struct cl_page *page)
 }
 
 void __cl_page_disown(const struct lu_env *env,
-		     struct cl_io *io, struct cl_page *pg)
+		      struct cl_io *io, struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
 	enum cl_page_state state;
+	int i;
 
-	state = pg->cp_state;
-	cl_page_owner_clear(pg);
+	state = cl_page->cp_state;
+	cl_page_owner_clear(cl_page);
 
 	if (state == CPS_OWNED)
-		cl_page_state_set(env, pg, CPS_CACHED);
+		cl_page_state_set(env, cl_page, CPS_CACHED);
 	/*
 	 * Completion call-backs are executed in the bottom-up order, so that
 	 * uppermost layer (llite), responsible for VFS/VM interaction runs
 	 * last and can release locks safely.
 	 */
-	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each_reverse(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_disown)
 			(*slice->cpl_ops->cpo_disown)(env, slice, io);
 	}
@@ -494,12 +519,12 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
  * Waits until page is in cl_page_state::CPS_CACHED state, and then switch it
  * into cl_page_state::CPS_OWNED state.
  *
- * \pre  !cl_page_is_owned(pg, io)
- * \post result == 0 iff cl_page_is_owned(pg, io)
+ * \pre  !cl_page_is_owned(cl_page, io)
+ * \post result == 0 iff cl_page_is_owned(cl_page, io)
  *
  * Return:	0 success
  *
- *		-ve failure, e.g., page was destroyed (and landed in
+ *		-ve failure, e.g., cl_page was destroyed (and landed in
  *		cl_page_state::CPS_FREEING instead of
  *		cl_page_state::CPS_CACHED). or, page was owned by
  *		another thread, or in IO.
@@ -510,19 +535,20 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
  * \see cl_page_own
  */
 static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
-			 struct cl_page *pg, int nonblock)
+			 struct cl_page *cl_page, int nonblock)
 {
 	const struct cl_page_slice *slice;
 	int result = 0;
+	int i;
 
 	io = cl_io_top(io);
 
-	if (pg->cp_state == CPS_FREEING) {
+	if (cl_page->cp_state == CPS_FREEING) {
 		result = -ENOENT;
 		goto out;
 	}
 
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_own)
 			result = (*slice->cpl_ops->cpo_own)(env, slice,
 							    io, nonblock);
@@ -533,13 +559,13 @@ static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
 		result = 0;
 
 	if (result == 0) {
-		PASSERT(env, pg, !pg->cp_owner);
-		pg->cp_owner = cl_io_top(io);
-		cl_page_owner_set(pg);
-		if (pg->cp_state != CPS_FREEING) {
-			cl_page_state_set(env, pg, CPS_OWNED);
+		PASSERT(env, cl_page, !cl_page->cp_owner);
+		cl_page->cp_owner = cl_io_top(io);
+		cl_page_owner_set(cl_page);
+		if (cl_page->cp_state != CPS_FREEING) {
+			cl_page_state_set(env, cl_page, CPS_OWNED);
 		} else {
-			__cl_page_disown(env, io, pg);
+			__cl_page_disown(env, io, cl_page);
 			result = -ENOENT;
 		}
 	}
@@ -575,51 +601,53 @@ int cl_page_own_try(const struct lu_env *env, struct cl_io *io,
  *
  * Called when page is already locked by the hosting VM.
  *
- * \pre !cl_page_is_owned(pg, io)
- * \post cl_page_is_owned(pg, io)
+ * \pre !cl_page_is_owned(cl_page, io)
+ * \post cl_page_is_owned(cl_page, io)
  *
  * \see cl_page_operations::cpo_assume()
  */
 void cl_page_assume(const struct lu_env *env,
-		    struct cl_io *io, struct cl_page *pg)
+		    struct cl_io *io, struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
 	io = cl_io_top(io);
 
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_assume)
 			(*slice->cpl_ops->cpo_assume)(env, slice, io);
 	}
 
-	PASSERT(env, pg, !pg->cp_owner);
-	pg->cp_owner = cl_io_top(io);
-	cl_page_owner_set(pg);
-	cl_page_state_set(env, pg, CPS_OWNED);
+	PASSERT(env, cl_page, !cl_page->cp_owner);
+	cl_page->cp_owner = cl_io_top(io);
+	cl_page_owner_set(cl_page);
+	cl_page_state_set(env, cl_page, CPS_OWNED);
 }
 EXPORT_SYMBOL(cl_page_assume);
 
 /**
  * Releases page ownership without unlocking the page.
  *
- * Moves page into cl_page_state::CPS_CACHED without releasing a lock on the
- * underlying VM page (as VM is supposed to do this itself).
+ * Moves cl_page into cl_page_state::CPS_CACHED without releasing a lock
+ * on the underlying VM page (as VM is supposed to do this itself).
  *
- * \pre   cl_page_is_owned(pg, io)
- * \post !cl_page_is_owned(pg, io)
+ * \pre   cl_page_is_owned(cl_page, io)
+ * \post !cl_page_is_owned(cl_page, io)
  *
  * \see cl_page_assume()
  */
 void cl_page_unassume(const struct lu_env *env,
-		      struct cl_io *io, struct cl_page *pg)
+		      struct cl_io *io, struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
 	io = cl_io_top(io);
-	cl_page_owner_clear(pg);
-	cl_page_state_set(env, pg, CPS_CACHED);
+	cl_page_owner_clear(cl_page);
+	cl_page_state_set(env, cl_page, CPS_CACHED);
 
-	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each_reverse(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_unassume)
 			(*slice->cpl_ops->cpo_unassume)(env, slice, io);
 	}
@@ -646,21 +674,22 @@ void cl_page_disown(const struct lu_env *env,
 EXPORT_SYMBOL(cl_page_disown);
 
 /**
- * Called when page is to be removed from the object, e.g., as a result of
- * truncate.
+ * Called when cl_page is to be removed from the object, e.g.,
+ * as a result of truncate.
  *
  * Calls cl_page_operations::cpo_discard() top-to-bottom.
  *
- * \pre cl_page_is_owned(pg, io)
+ * \pre cl_page_is_owned(cl_page, io)
  *
  * \see cl_page_operations::cpo_discard()
  */
 void cl_page_discard(const struct lu_env *env,
-		     struct cl_io *io, struct cl_page *pg)
+		     struct cl_io *io, struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_discard)
 			(*slice->cpl_ops->cpo_discard)(env, slice, io);
 	}
@@ -669,22 +698,24 @@ void cl_page_discard(const struct lu_env *env,
 
 /**
  * Version of cl_page_delete() that can be called for not fully constructed
- * pages, e.g,. in a error handling cl_page_find()->__cl_page_delete()
+ * cl_pages, e.g,. in a error handling cl_page_find()->__cl_page_delete()
  * path. Doesn't check page invariant.
  */
-static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg)
+static void __cl_page_delete(const struct lu_env *env,
+			     struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
-	PASSERT(env, pg, pg->cp_state != CPS_FREEING);
+	PASSERT(env, cl_page, cl_page->cp_state != CPS_FREEING);
 
 	/*
-	 * Sever all ways to obtain new pointers to @pg.
+	 * Sever all ways to obtain new pointers to @cl_page.
 	 */
-	cl_page_owner_clear(pg);
-	__cl_page_state_set(env, pg, CPS_FREEING);
+	cl_page_owner_clear(cl_page);
+	__cl_page_state_set(env, cl_page, CPS_FREEING);
 
-	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each_reverse(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_delete)
 			(*slice->cpl_ops->cpo_delete)(env, slice);
 	}
@@ -729,11 +760,13 @@ void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
  *
  * \see cl_page_operations::cpo_export()
  */
-void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate)
+void cl_page_export(const struct lu_env *env, struct cl_page *cl_page,
+		    int uptodate)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_export)
 			(*slice->cpl_ops->cpo_export)(env, slice, uptodate);
 	}
@@ -741,34 +774,36 @@ void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate)
 EXPORT_SYMBOL(cl_page_export);
 
 /**
- * Returns true, if @pg is VM locked in a suitable sense by the calling
+ * Returns true, if @cl_page is VM locked in a suitable sense by the calling
  * thread.
  */
-int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
+int cl_page_is_vmlocked(const struct lu_env *env,
+			const struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
 	int result;
 
-	slice = list_first_entry(&pg->cp_layers,
-				 const struct cl_page_slice, cpl_linkage);
-	PASSERT(env, pg, slice->cpl_ops->cpo_is_vmlocked);
+	slice = cl_page_slice_get(cl_page, 0);
+	PASSERT(env, cl_page, slice->cpl_ops->cpo_is_vmlocked);
 	/*
 	 * Call ->cpo_is_vmlocked() directly instead of going through
 	 * CL_PAGE_INVOKE(), because cl_page_is_vmlocked() is used by
 	 * cl_page_invariant().
 	 */
 	result = slice->cpl_ops->cpo_is_vmlocked(env, slice);
-	PASSERT(env, pg, result == -EBUSY || result == -ENODATA);
+	PASSERT(env, cl_page, result == -EBUSY || result == -ENODATA);
+
 	return result == -EBUSY;
 }
 EXPORT_SYMBOL(cl_page_is_vmlocked);
 
-void cl_page_touch(const struct lu_env *env, const struct cl_page *pg,
-		  size_t to)
+void cl_page_touch(const struct lu_env *env,
+		   const struct cl_page *cl_page, size_t to)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_page_touch)
 			(*slice->cpl_ops->cpo_page_touch)(env, slice, to);
 	}
@@ -799,20 +834,21 @@ static void cl_page_io_start(const struct lu_env *env,
  * transfer now.
  */
 int cl_page_prep(const struct lu_env *env, struct cl_io *io,
-		 struct cl_page *pg, enum cl_req_type crt)
+		 struct cl_page *cl_page, enum cl_req_type crt)
 {
 	const struct cl_page_slice *slice;
 	int result = 0;
+	int i;
 
 	/*
-	 * XXX this has to be called bottom-to-top, so that llite can set up
+	 * this has to be called bottom-to-top, so that llite can set up
 	 * PG_writeback without risking other layers deciding to skip this
 	 * page.
 	 */
 	if (crt >= CRT_NR)
 		return -EINVAL;
 
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_own)
 			result = (*slice->cpl_ops->io[crt].cpo_prep)(env, slice,
 								     io);
@@ -822,10 +858,10 @@ int cl_page_prep(const struct lu_env *env, struct cl_io *io,
 
 	if (result >= 0) {
 		result = 0;
-		cl_page_io_start(env, pg, crt);
+		cl_page_io_start(env, cl_page, crt);
 	}
 
-	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, result);
+	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d %d\n", crt, result);
 	return result;
 }
 EXPORT_SYMBOL(cl_page_prep);
@@ -840,35 +876,36 @@ int cl_page_prep(const struct lu_env *env, struct cl_io *io,
  * uppermost layer (llite), responsible for the VFS/VM interaction runs last
  * and can release locks safely.
  *
- * \pre  pg->cp_state == CPS_PAGEIN || pg->cp_state == CPS_PAGEOUT
- * \post pg->cp_state == CPS_CACHED
+ * \pre  cl_page->cp_state == CPS_PAGEIN || cl_page->cp_state == CPS_PAGEOUT
+ * \post cl_page->cp_state == CPS_CACHED
  *
  * \see cl_page_operations::cpo_completion()
  */
 void cl_page_completion(const struct lu_env *env,
-			struct cl_page *pg, enum cl_req_type crt, int ioret)
+			struct cl_page *cl_page, enum cl_req_type crt,
+			int ioret)
 {
-	struct cl_sync_io *anchor = pg->cp_sync_io;
+	struct cl_sync_io *anchor = cl_page->cp_sync_io;
 	const struct cl_page_slice *slice;
+	int i;
 
-	PASSERT(env, pg, crt < CRT_NR);
-	PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
-
-	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, ioret);
+	PASSERT(env, cl_page, crt < CRT_NR);
+	PASSERT(env, cl_page, cl_page->cp_state == cl_req_type_state(crt));
 
-	cl_page_state_set(env, pg, CPS_CACHED);
+	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d %d\n", crt, ioret);
+	cl_page_state_set(env, cl_page, CPS_CACHED);
 	if (crt >= CRT_NR)
 		return;
 
-	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each_reverse(cl_page, slice, i) {
 		if (slice->cpl_ops->io[crt].cpo_completion)
 			(*slice->cpl_ops->io[crt].cpo_completion)(env, slice,
 								  ioret);
 	}
 
 	if (anchor) {
-		LASSERT(pg->cp_sync_io == anchor);
-		pg->cp_sync_io = NULL;
+		LASSERT(cl_page->cp_sync_io == anchor);
+		cl_page->cp_sync_io = NULL;
 		cl_sync_io_note(env, anchor, ioret);
 	}
 }
@@ -878,53 +915,56 @@ void cl_page_completion(const struct lu_env *env,
  * Notify layers that transfer formation engine decided to yank this page from
  * the cache and to make it a part of a transfer.
  *
- * \pre  pg->cp_state == CPS_CACHED
- * \post pg->cp_state == CPS_PAGEIN || pg->cp_state == CPS_PAGEOUT
+ * \pre  cl_page->cp_state == CPS_CACHED
+ * \post cl_page->cp_state == CPS_PAGEIN || cl_page->cp_state == CPS_PAGEOUT
  *
  * \see cl_page_operations::cpo_make_ready()
  */
-int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
+int cl_page_make_ready(const struct lu_env *env, struct cl_page *cl_page,
 		       enum cl_req_type crt)
 {
-	const struct cl_page_slice *sli;
+	const struct cl_page_slice *slice;
 	int result = 0;
+	int i;
 
 	if (crt >= CRT_NR)
 		return -EINVAL;
 
-	list_for_each_entry(sli, &pg->cp_layers, cpl_linkage) {
-		if (sli->cpl_ops->io[crt].cpo_make_ready)
-			result = (*sli->cpl_ops->io[crt].cpo_make_ready)(env,
-									 sli);
+	cl_page_slice_for_each(cl_page, slice, i) {
+		if (slice->cpl_ops->io[crt].cpo_make_ready)
+			result = (*slice->cpl_ops->io[crt].cpo_make_ready)(env,
+									   slice);
 		if (result != 0)
 			break;
 	}
 
 	if (result >= 0) {
-		PASSERT(env, pg, pg->cp_state == CPS_CACHED);
-		cl_page_io_start(env, pg, crt);
+		PASSERT(env, cl_page, cl_page->cp_state == CPS_CACHED);
+		cl_page_io_start(env, cl_page, crt);
 		result = 0;
 	}
-	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, result);
+	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d %d\n", crt, result);
+
 	return result;
 }
 EXPORT_SYMBOL(cl_page_make_ready);
 
 /**
- * Called if a pge is being written back by kernel's intention.
+ * Called if a page is being written back by kernel's intention.
  *
- * \pre  cl_page_is_owned(pg, io)
- * \post ergo(result == 0, pg->cp_state == CPS_PAGEOUT)
+ * \pre  cl_page_is_owned(cl_page, io)
+ * \post ergo(result == 0, cl_page->cp_state == CPS_PAGEOUT)
  *
  * \see cl_page_operations::cpo_flush()
  */
 int cl_page_flush(const struct lu_env *env, struct cl_io *io,
-		  struct cl_page *pg)
+		  struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
 	int result = 0;
+	int i;
 
-	 list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_flush)
 			result = (*slice->cpl_ops->cpo_flush)(env, slice, io);
 		if (result != 0)
@@ -933,7 +973,7 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 	if (result > 0)
 		result = 0;
 
-	CL_PAGE_HEADER(D_TRACE, env, pg, "%d\n", result);
+	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d\n", result);
 	return result;
 }
 EXPORT_SYMBOL(cl_page_flush);
@@ -943,14 +983,14 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
  *
  * \see cl_page_operations::cpo_clip()
  */
-void cl_page_clip(const struct lu_env *env, struct cl_page *pg,
+void cl_page_clip(const struct lu_env *env, struct cl_page *cl_page,
 		  int from, int to)
 {
 	const struct cl_page_slice *slice;
+	int i;
 
-	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", from, to);
-
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d %d\n", from, to);
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_clip)
 			(*slice->cpl_ops->cpo_clip)(env, slice, from, to);
 	}
@@ -972,24 +1012,24 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(cl_page_header_print);
 
 /**
- * Prints human readable representation of @pg to the @f.
+ * Prints human readable representation of @cl_page to the @f.
  */
 void cl_page_print(const struct lu_env *env, void *cookie,
-		   lu_printer_t printer, const struct cl_page *pg)
+		   lu_printer_t printer, const struct cl_page *cl_page)
 {
 	const struct cl_page_slice *slice;
 	int result = 0;
+	int i;
 
-	cl_page_header_print(env, cookie, printer, pg);
-
-	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+	cl_page_header_print(env, cookie, printer, cl_page);
+	cl_page_slice_for_each(cl_page, slice, i) {
 		if (slice->cpl_ops->cpo_print)
 			result = (*slice->cpl_ops->cpo_print)(env, slice,
 							      cookie, printer);
 		if (result != 0)
 			break;
 	}
-	(*printer)(env, cookie, "end page@%p\n", pg);
+	(*printer)(env, cookie, "end page@%p\n", cl_page);
 }
 EXPORT_SYMBOL(cl_page_print);
 
@@ -1032,14 +1072,18 @@ size_t cl_page_size(const struct cl_object *obj)
  *
  * \see cl_lock_slice_add(), cl_req_slice_add(), cl_io_slice_add()
  */
-void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
+void cl_page_slice_add(struct cl_page *cl_page, struct cl_page_slice *slice,
 		       struct cl_object *obj,
 		       const struct cl_page_operations *ops)
 {
-	list_add_tail(&slice->cpl_linkage, &page->cp_layers);
+	unsigned int offset = (char *)slice -
+			      ((char *)cl_page + sizeof(*cl_page));
+
+	LASSERT(offset < (1 << sizeof(cl_page->cp_layer_offset[0]) * 8));
+	cl_page->cp_layer_offset[cl_page->cp_layer_count++] = offset;
 	slice->cpl_obj = obj;
 	slice->cpl_ops = ops;
-	slice->cpl_page = page;
+	slice->cpl_page = cl_page;
 }
 EXPORT_SYMBOL(cl_page_slice_add);
 
-- 
1.8.3.1
