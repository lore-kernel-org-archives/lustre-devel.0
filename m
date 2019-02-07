From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 13/21] lustre: make cp_ref in cl_page a
 refcount_t
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781321.10620.15836497514344103445.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As this is used as a refcount, it should be declared
as one.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h |    4 ++--
 drivers/staging/lustre/lustre/llite/vvp_page.c    |    9 +++++----
 drivers/staging/lustre/lustre/obdclass/cl_page.c  |   14 +++++++-------
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index bf7678aed6bf..c2273c3100e8 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -717,7 +717,7 @@ enum cl_page_type {
  */
 struct cl_page {
 	/** Reference counter. */
-	atomic_t			 cp_ref;
+	refcount_t			 cp_ref;
 	/** An object this page is a part of. Immutable after creation. */
 	struct cl_object		*cp_obj;
 	/** vmpage */
@@ -1021,7 +1021,7 @@ static inline struct page *cl_page_vmpage(struct cl_page *page)
  */
 static inline bool __page_in_use(const struct cl_page *page, int refc)
 {
-	return (atomic_read(&page->cp_ref) > refc + 1);
+	return (refcount_read(&page->cp_ref) > refc + 1);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 77bf923f2578..ec0d93313f55 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -157,15 +157,16 @@ static void vvp_page_delete(const struct lu_env *env,
 	struct inode *inode = vmpage->mapping->host;
 	struct cl_object *obj = slice->cpl_obj;
 	struct cl_page *page = slice->cpl_page;
-	int refc;
 
 	LASSERT(PageLocked(vmpage));
 	LASSERT((struct cl_page *)vmpage->private == page);
 	LASSERT(inode == vvp_object_inode(obj));
 
 	/* Drop the reference count held in vvp_page_init */
-	refc = atomic_dec_return(&page->cp_ref);
-	LASSERTF(refc >= 1, "page = %p, refc = %d\n", page, refc);
+	if (refcount_dec_and_test(&page->cp_ref)) {
+		/* It mustn't reach zero here! */
+		LASSERTF(0, "page = %p, refc reached zero\n", page);
+	}
 
 	ClearPagePrivate(vmpage);
 	vmpage->private = 0;
@@ -507,7 +508,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	if (page->cp_type == CPT_CACHEABLE) {
 		/* in cache, decref in vvp_page_delete */
-		atomic_inc(&page->cp_ref);
+		refcount_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
 		cl_page_slice_add(page, &vpg->vpg_cl, obj, index,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 31ded52e0499..f0ece7e9a4ac 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -67,8 +67,8 @@ static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg);
  */
 static void cl_page_get_trust(struct cl_page *page)
 {
-	LASSERT(atomic_read(&page->cp_ref) > 0);
-	atomic_inc(&page->cp_ref);
+	LASSERT(refcount_read(&page->cp_ref) > 0);
+	refcount_inc(&page->cp_ref);
 }
 
 /**
@@ -135,7 +135,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 	if (page) {
 		int result = 0;
 
-		atomic_set(&page->cp_ref, 1);
+		refcount_set(&page->cp_ref, 1);
 		page->cp_obj = o;
 		cl_object_get(o);
 		lu_object_ref_add_at(&o->co_lu, &page->cp_obj_ref, "cl_page",
@@ -310,12 +310,12 @@ EXPORT_SYMBOL(cl_page_get);
 void cl_page_put(const struct lu_env *env, struct cl_page *page)
 {
 	CL_PAGE_HEADER(D_TRACE, env, page, "%d\n",
-		       atomic_read(&page->cp_ref));
+		       refcount_read(&page->cp_ref));
 
-	if (atomic_dec_and_test(&page->cp_ref)) {
+	if (refcount_dec_and_test(&page->cp_ref)) {
 		LASSERT(page->cp_state == CPS_FREEING);
 
-		LASSERT(atomic_read(&page->cp_ref) == 0);
+		LASSERT(refcount_read(&page->cp_ref) == 0);
 		PASSERT(env, page, !page->cp_owner);
 		PASSERT(env, page, list_empty(&page->cp_batch));
 		/*
@@ -869,7 +869,7 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 {
 	(*printer)(env, cookie,
 		   "page@%p[%d %p %d %d %p]\n",
-		   pg, atomic_read(&pg->cp_ref), pg->cp_obj,
+		   pg, refcount_read(&pg->cp_ref), pg->cp_obj,
 		   pg->cp_state, pg->cp_type,
 		   pg->cp_owner);
 }
