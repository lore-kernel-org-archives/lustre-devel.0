From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 26/29] lustre: osc_cache: simplify
 osc_page_gang_lookup()
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504269.26726.8061168646539306509.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

osc_page_gang_lookup() has 4 values that it can receive from a
callback, and that it can return to the caller:
	CLP_GANG_OKAY,
	CLP_GANG_RESCHED,
	CLP_GANG_AGAIN,
	CLP_GANG_ABORT

"AGAIN" is never used.
"RESCHED" is not needed as a cond_resched() can safely be called at
the point this is returned, rather than returning it.
That leaves "OKAY" and "ABORT" which can simply by "true" and "false"
boolean values.

Internalizing the RESCHED case means the callers don't need to loop
themselves.  This simplify calling patterns.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    7 ----
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   40 ++++++++------------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   10 +++--
 drivers/staging/lustre/lustre/osc/osc_io.c         |    4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   27 ++++++--------
 5 files changed, 33 insertions(+), 55 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index de5d68879740..57d8fe676995 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2076,14 +2076,7 @@ static inline int cl_object_refc(struct cl_object *clob)
 /** \defgroup cl_page cl_page
  * @{
  */
-enum {
-	CLP_GANG_OKAY = 0,
-	CLP_GANG_RESCHED,
-	CLP_GANG_AGAIN,
-	CLP_GANG_ABORT
-};
 
-/* callback of cl_page_gang_lookup() */
 struct cl_page *cl_page_find(const struct lu_env *env, struct cl_object *obj,
 			     pgoff_t idx, struct page *vmpage,
 			     enum cl_page_type type);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 79bcaa212339..e01f3815978c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2994,18 +2994,14 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 /**
  * Returns a list of pages by a given [start, end] of \a obj.
  *
- * \param resched If not NULL, then we give up before hogging CPU for too
- * long and set *resched = 1, in that case caller should implement a retry
- * logic.
- *
  * Gang tree lookup (radix_tree_gang_lookup()) optimization is absolutely
  * crucial in the face of [offset, EOF] locks.
  *
  * Return at least one page in @queue unless there is no covered page.
  */
-int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
-			 struct osc_object *osc, pgoff_t start, pgoff_t end,
-			 osc_page_gang_cbt cb, void *cbdata)
+bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			  struct osc_object *osc, pgoff_t start, pgoff_t end,
+			  osc_page_gang_cbt cb, void *cbdata)
 {
 	struct osc_page *ops;
 	void            **pvec;
@@ -3013,7 +3009,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 	unsigned int    nr;
 	unsigned int    i;
 	unsigned int    j;
-	int             res = CLP_GANG_OKAY;
+	bool            res = true;
 	bool            tree_lock = true;
 
 	idx = start;
@@ -3059,7 +3055,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 
 		for (i = 0; i < j; ++i) {
 			ops = pvec[i];
-			if (res == CLP_GANG_OKAY)
+			if (res)
 				res = (*cb)(env, io, ops, cbdata);
 
 			page = ops->ops_cl.cpl_page;
@@ -3069,10 +3065,10 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 		if (nr < OTI_PVEC_SIZE || end_of_region)
 			break;
 
-		if (res == CLP_GANG_OKAY && need_resched())
-			res = CLP_GANG_RESCHED;
-		if (res != CLP_GANG_OKAY)
+		if (!res)
 			break;
+		if (need_resched())
+			cond_resched();
 
 		spin_lock(&osc->oo_tree_lock);
 		tree_lock = true;
@@ -3085,7 +3081,7 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 /**
  * Check if page @page is covered by an extra lock or discard it.
  */
-static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
+static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 				struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
@@ -3121,10 +3117,10 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 	}
 
 	info->oti_next_index = index + 1;
-	return CLP_GANG_OKAY;
+	return true;
 }
 
-static int discard_cb(const struct lu_env *env, struct cl_io *io,
+static bool discard_cb(const struct lu_env *env, struct cl_io *io,
 		      struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
@@ -3145,7 +3141,7 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 		LASSERT(page->cp_state == CPS_FREEING);
 	}
 
-	return CLP_GANG_OKAY;
+	return true;
 }
 
 /**
@@ -3162,7 +3158,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_io *io = &info->oti_io;
 	osc_page_gang_cbt cb;
-	int res;
+	bool res;
 	int result;
 
 	io->ci_obj = cl_object_top(osc2cl(osc));
@@ -3174,15 +3170,9 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	cb = discard ? discard_cb : check_and_discard_cb;
 	info->oti_fn_index = start;
 	info->oti_next_index = start;
-	do {
-		res = osc_page_gang_lookup(env, io, osc,
-					   info->oti_next_index, end, cb, osc);
-		if (info->oti_next_index > end)
-			break;
 
-		if (res == CLP_GANG_RESCHED)
-			cond_resched();
-	} while (res != CLP_GANG_OKAY);
+	res = osc_page_gang_lookup(env, io, osc,
+				   info->oti_next_index, end, cb, osc);
 out:
 	cl_io_fini(env, io);
 	return result;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 3af096e0dbdd..c0f58f41513f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -660,11 +660,11 @@ void osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
 int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 			   pgoff_t start, pgoff_t end, bool discard_pages);
 
-typedef int (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
-				 struct osc_page *, void *);
-int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
-			 struct osc_object *osc, pgoff_t start, pgoff_t end,
-			 osc_page_gang_cbt cb, void *cbdata);
+typedef bool (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
+				  struct osc_page *, void *);
+bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
+			  struct osc_object *osc, pgoff_t start, pgoff_t end,
+			  osc_page_gang_cbt cb, void *cbdata);
 /* @} osc */
 
 #endif /* OSC_CL_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index dabdf6da8b38..b95e0358d7ff 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -449,7 +449,7 @@ static int osc_async_upcall(void *a, int rc)
 /**
  * Checks that there are no pages being written in the extent being truncated.
  */
-static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
+static bool trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 			  struct osc_page *ops, void *cbdata)
 {
 	struct cl_page *page = ops->ops_cl.cpl_page;
@@ -466,7 +466,7 @@ static int trunc_check_cb(const struct lu_env *env, struct cl_io *io,
 		CDEBUG(D_CACHE, "page %p index %lu locked for %d.\n",
 		       ops, osc_index(ops), oap->oap_cmd & OBD_BRW_RWMASK);
 
-	return CLP_GANG_OKAY;
+	return true;
 }
 
 static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 4cc813d192d9..1eab61d720e2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -630,18 +630,18 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	return result;
 }
 
-static int weigh_cb(const struct lu_env *env, struct cl_io *io,
-		    struct osc_page *ops, void *cbdata)
+static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
+		     struct osc_page *ops, void *cbdata)
 {
 	struct cl_page *page = ops->ops_cl.cpl_page;
 
 	if (cl_page_is_vmlocked(env, page) ||
 	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
 	   )
-		return CLP_GANG_ABORT;
+		return false;
 
 	*(pgoff_t *)cbdata = osc_index(ops) + 1;
-	return CLP_GANG_OKAY;
+	return true;
 }
 
 static unsigned long osc_lock_weight(const struct lu_env *env,
@@ -651,7 +651,7 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 	struct cl_io *io = &osc_env_info(env)->oti_io;
 	struct cl_object *obj = cl_object_top(&oscobj->oo_cl);
 	pgoff_t page_index;
-	int result;
+	bool result;
 
 	io->ci_obj = obj;
 	io->ci_ignore_layout = 1;
@@ -660,19 +660,14 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 		return result;
 
 	page_index = cl_index(obj, extent->start);
-	do {
-		result = osc_page_gang_lookup(env, io, oscobj,
-					      page_index,
-					      cl_index(obj, extent->end),
-					      weigh_cb, (void *)&page_index);
-		if (result == CLP_GANG_ABORT)
-			break;
-		if (result == CLP_GANG_RESCHED)
-			cond_resched();
-	} while (result != CLP_GANG_OKAY);
+
+	result = osc_page_gang_lookup(env, io, oscobj,
+				      page_index,
+				      cl_index(obj, extent->end),
+				      weigh_cb, (void *)&page_index);
 	cl_io_fini(env, io);
 
-	return result == CLP_GANG_ABORT ? 1 : 0;
+	return result ? 1 : 0;
 }
 
 /**
