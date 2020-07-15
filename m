From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:57 -0400
Subject: [lustre-devel] [PATCH 16/37] lustre: obdclass: re-declare cl_page
 variables to reduce its size
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

With following changes:
1) make CPS_CACHED declare start from 1 consistent with CPT_CACHED
2) add CPT_NR to indicate max allowed CPT state value.
3) Reserve 4 bits for @cp_state which allow 15 kind of states
4) Reserve 2 bits for @cp_type which allow 3 kinds of cl_page types
5) use short int for @cp_kmem_index and We still have another 16 bits
   reserved for future extension.
6) move @cp_lov_index after @cp_ref to fill 4 bytes hole.

After this patch, cl_page size could reduce from 336 bytes to 320 bytes

WC-bug-id: https://jira.whamcloud.com/browse/LU-13134
Lustre-commit: 5fb29cd1e77ca ("LU-13134 obdclass: re-declare cl_page variables to reduce its size")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/37480
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 26 +++++++++------
 fs/lustre/obdclass/cl_page.c  | 76 +++++++++++++++++++++----------------------
 2 files changed, 53 insertions(+), 49 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 47997f8..8611285 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -621,7 +621,7 @@ enum cl_page_state {
 	 *
 	 * \invariant cl_page::cp_owner == NULL && cl_page::cp_req == NULL
 	 */
-	CPS_CACHED,
+	CPS_CACHED = 1,
 	/**
 	 * Page is exclusively owned by some cl_io. Page may end up in this
 	 * state as a result of
@@ -715,8 +715,13 @@ enum cl_page_type {
 	 *  it is used in DirectIO and lockless IO.
 	 */
 	CPT_TRANSIENT,
+	CPT_NR
 };
 
+#define	CP_STATE_BITS	4
+#define	CP_TYPE_BITS	2
+#define	CP_MAX_LAYER	3
+
 /**
  * Fields are protected by the lock on struct page, except for atomics and
  * immutables.
@@ -729,8 +734,9 @@ enum cl_page_type {
 struct cl_page {
 	/** Reference counter. */
 	refcount_t			 cp_ref;
-	/* which slab kmem index this memory allocated from */
-	int				 cp_kmem_index;
+	/** layout_entry + stripe index, composed using lov_comp_index() */
+	unsigned int			 cp_lov_index;
+	pgoff_t				 cp_osc_index;
 	/** An object this page is a part of. Immutable after creation. */
 	struct cl_object		*cp_obj;
 	/** vmpage */
@@ -738,19 +744,22 @@ struct cl_page {
 	/** Linkage of pages within group. Pages must be owned */
 	struct list_head		 cp_batch;
 	/** array of slices offset. Immutable after creation. */
-	unsigned char			 cp_layer_offset[3];
+	unsigned char			 cp_layer_offset[CP_MAX_LAYER]; /* 24 bits */
 	/** current slice index */
-	unsigned char			 cp_layer_count:2;
+	unsigned char			 cp_layer_count:2; /* 26 bits */
 	/**
 	 * Page state. This field is const to avoid accidental update, it is
 	 * modified only internally within cl_page.c. Protected by a VM lock.
 	 */
-	const enum cl_page_state	 cp_state;
+	enum cl_page_state		 cp_state:CP_STATE_BITS; /* 30 bits */
 	/**
 	 * Page type. Only CPT_TRANSIENT is used so far. Immutable after
 	 * creation.
 	 */
-	enum cl_page_type		 cp_type;
+	enum cl_page_type		 cp_type:CP_TYPE_BITS; /* 32 bits */
+	/* which slab kmem index this memory allocated from */
+	short int			 cp_kmem_index; /* 48 bits */
+	unsigned int			 cp_unused1:16; /* 64 bits */
 
 	/**
 	 * Owning IO in cl_page_state::CPS_OWNED state. Sub-page can be owned
@@ -765,9 +774,6 @@ struct cl_page {
 	struct lu_ref_link		 cp_queue_ref;
 	/** Assigned if doing a sync_io */
 	struct cl_sync_io		*cp_sync_io;
-	/** layout_entry + stripe index, composed using lov_comp_index() */
-	unsigned int			 cp_lov_index;
-	pgoff_t				 cp_osc_index;
 };
 
 /**
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index cced026..53f88a7 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -153,17 +153,6 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *cl_page,
 	__cl_page_free(cl_page, bufsize);
 }
 
-/**
- * Helper function updating page state. This is the only place in the code
- * where cl_page::cp_state field is mutated.
- */
-static inline void cl_page_state_set_trust(struct cl_page *page,
-					   enum cl_page_state state)
-{
-	/* bypass const. */
-	*(enum cl_page_state *)&page->cp_state = state;
-}
-
 static struct cl_page *__cl_page_alloc(struct cl_object *o)
 {
 	int i = 0;
@@ -217,44 +206,50 @@ static struct cl_page *__cl_page_alloc(struct cl_object *o)
 	return cl_page;
 }
 
-struct cl_page *cl_page_alloc(const struct lu_env *env,
-			      struct cl_object *o, pgoff_t ind,
-			      struct page *vmpage,
+struct cl_page *cl_page_alloc(const struct lu_env *env, struct cl_object *o,
+			      pgoff_t ind, struct page *vmpage,
 			      enum cl_page_type type)
 {
-	struct cl_page *page;
+	struct cl_page *cl_page;
 	struct cl_object *o2;
 
-	page = __cl_page_alloc(o);
-	if (page) {
+	cl_page = __cl_page_alloc(o);
+	if (cl_page) {
 		int result = 0;
 
-		refcount_set(&page->cp_ref, 1);
-		page->cp_obj = o;
+		/*
+		 * Please fix cl_page:cp_state/type declaration if
+		 * these assertions fail in the future.
+		 */
+		BUILD_BUG_ON((1 << CP_STATE_BITS) < CPS_NR); /* cp_state */
+		BUILD_BUG_ON((1 << CP_TYPE_BITS) < CPT_NR); /* cp_type */
+		refcount_set(&cl_page->cp_ref, 1);
+		cl_page->cp_obj = o;
 		cl_object_get(o);
-		lu_object_ref_add_at(&o->co_lu, &page->cp_obj_ref, "cl_page",
-				     page);
-		page->cp_vmpage = vmpage;
-		cl_page_state_set_trust(page, CPS_CACHED);
-		page->cp_type = type;
-		INIT_LIST_HEAD(&page->cp_batch);
-		lu_ref_init(&page->cp_reference);
+		lu_object_ref_add_at(&o->co_lu, &cl_page->cp_obj_ref,
+				     "cl_page", cl_page);
+		cl_page->cp_vmpage = vmpage;
+		cl_page->cp_state = CPS_CACHED;
+		cl_page->cp_type = type;
+		INIT_LIST_HEAD(&cl_page->cp_batch);
+		lu_ref_init(&cl_page->cp_reference);
 		cl_object_for_each(o2, o) {
 			if (o2->co_ops->coo_page_init) {
 				result = o2->co_ops->coo_page_init(env, o2,
-								   page, ind);
+								   cl_page,
+								   ind);
 				if (result != 0) {
-					__cl_page_delete(env, page);
-					cl_page_free(env, page, NULL);
-					page = ERR_PTR(result);
+					__cl_page_delete(env, cl_page);
+					cl_page_free(env, cl_page, NULL);
+					cl_page = ERR_PTR(result);
 					break;
 				}
 			}
 		}
 	} else {
-		page = ERR_PTR(-ENOMEM);
+		cl_page = ERR_PTR(-ENOMEM);
 	}
-	return page;
+	return cl_page;
 }
 
 /**
@@ -317,7 +312,8 @@ static inline int cl_page_invariant(const struct cl_page *pg)
 }
 
 static void __cl_page_state_set(const struct lu_env *env,
-				struct cl_page *page, enum cl_page_state state)
+				struct cl_page *cl_page,
+				enum cl_page_state state)
 {
 	enum cl_page_state old;
 
@@ -363,12 +359,13 @@ static void __cl_page_state_set(const struct lu_env *env,
 		}
 	};
 
-	old = page->cp_state;
-	PASSERT(env, page, allowed_transitions[old][state]);
-	CL_PAGE_HEADER(D_TRACE, env, page, "%d -> %d\n", old, state);
-	PASSERT(env, page, page->cp_state == old);
-	PASSERT(env, page, equi(state == CPS_OWNED, page->cp_owner));
-	cl_page_state_set_trust(page, state);
+	old = cl_page->cp_state;
+	PASSERT(env, cl_page, allowed_transitions[old][state]);
+	CL_PAGE_HEADER(D_TRACE, env, cl_page, "%d -> %d\n", old, state);
+	PASSERT(env, cl_page, cl_page->cp_state == old);
+	PASSERT(env, cl_page, equi(state == CPS_OWNED,
+				   cl_page->cp_owner));
+	cl_page->cp_state = state;
 }
 
 static void cl_page_state_set(const struct lu_env *env,
@@ -1079,6 +1076,7 @@ void cl_page_slice_add(struct cl_page *cl_page, struct cl_page_slice *slice,
 	unsigned int offset = (char *)slice -
 			      ((char *)cl_page + sizeof(*cl_page));
 
+	LASSERT(cl_page->cp_layer_count < CP_MAX_LAYER);
 	LASSERT(offset < (1 << sizeof(cl_page->cp_layer_offset[0]) * 8));
 	cl_page->cp_layer_offset[cl_page->cp_layer_count++] = offset;
 	slice->cpl_obj = obj;
-- 
1.8.3.1
