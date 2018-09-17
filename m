From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:14 -0400
Subject: [lustre-devel] [PATCH 1/8] lustre: obdclass: remove CL_PAGE_INVOKE
 et. al.
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ben Evans <bevans@cray.com>

CL_PAGE_INVOKE, CL_PAGE_INVOID and CL_PAGE_INVOKE_REVERSE
merely obscure the list_for_each_entry calls to various virtual
functions specified by CL_PAGE_OP, and arguments stuck into va_args.

These defines and their equivalent functions have been removed,
and the list_for_each_entry has been put in place. CL_PAGE_OP
has also been removed.

Signed-off-by: Ben Evans <bevans@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9523
Reviewed-on: https://review.whamcloud.com/27168
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_page.c | 275 ++++++++++++-----------
 1 file changed, 140 insertions(+), 135 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 916cf81..00df94b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -363,82 +363,6 @@ const struct cl_page_slice *cl_page_at(const struct cl_page *page,
 }
 EXPORT_SYMBOL(cl_page_at);
 
-#define CL_PAGE_OP(opname) offsetof(struct cl_page_operations, opname)
-
-#define CL_PAGE_INVOKE(_env, _page, _op, _proto, ...)		   \
-({								      \
-	const struct lu_env	*__env  = (_env);		    \
-	struct cl_page	     *__page = (_page);		   \
-	const struct cl_page_slice *__scan;			     \
-	int			 __result;			   \
-	ptrdiff_t		   __op   = (_op);		     \
-	int		       (*__method)_proto;		    \
-									\
-	__result = 0;						   \
-	list_for_each_entry(__scan, &__page->cp_layers, cpl_linkage) {  \
-		__method = *(void **)((char *)__scan->cpl_ops +  __op); \
-		if (__method) {						\
-			__result = (*__method)(__env, __scan, ## __VA_ARGS__); \
-			if (__result != 0)				\
-				break;					\
-		}							\
-	}								\
-	if (__result > 0)					       \
-		__result = 0;					   \
-	__result;						       \
-})
-
-#define CL_PAGE_INVOID(_env, _page, _op, _proto, ...)		   \
-do {								    \
-	const struct lu_env	*__env  = (_env);		    \
-	struct cl_page	     *__page = (_page);		   \
-	const struct cl_page_slice *__scan;			     \
-	ptrdiff_t		   __op   = (_op);		     \
-	void		      (*__method)_proto;		    \
-									\
-	list_for_each_entry(__scan, &__page->cp_layers, cpl_linkage) {	\
-		__method = *(void **)((char *)__scan->cpl_ops + __op);	\
-		if (__method)						\
-			(*__method)(__env, __scan, ## __VA_ARGS__);	\
-	}								\
-} while (0)
-
-#define CL_PAGE_INVOID_REVERSE(_env, _page, _op, _proto, ...)	       \
-do {									\
-	const struct lu_env	*__env  = (_env);			\
-	struct cl_page	     *__page = (_page);		       \
-	const struct cl_page_slice *__scan;				 \
-	ptrdiff_t		   __op   = (_op);			 \
-	void		      (*__method)_proto;			\
-									    \
-	list_for_each_entry_reverse(__scan, &__page->cp_layers, cpl_linkage) { \
-		__method = *(void **)((char *)__scan->cpl_ops + __op);	\
-		if (__method)						\
-			(*__method)(__env, __scan, ## __VA_ARGS__);	\
-	}								\
-} while (0)
-
-static int cl_page_invoke(const struct lu_env *env,
-			  struct cl_io *io, struct cl_page *page, ptrdiff_t op)
-
-{
-	PINVRNT(env, page, cl_object_same(page->cp_obj, io->ci_obj));
-	return CL_PAGE_INVOKE(env, page, op,
-			      (const struct lu_env *,
-			       const struct cl_page_slice *, struct cl_io *),
-			      io);
-}
-
-static void cl_page_invoid(const struct lu_env *env,
-			   struct cl_io *io, struct cl_page *page, ptrdiff_t op)
-
-{
-	PINVRNT(env, page, cl_object_same(page->cp_obj, io->ci_obj));
-	CL_PAGE_INVOID(env, page, op,
-		       (const struct lu_env *,
-			const struct cl_page_slice *, struct cl_io *), io);
-}
-
 static void cl_page_owner_clear(struct cl_page *page)
 {
 	if (page->cp_owner) {
@@ -456,6 +380,7 @@ static void cl_page_owner_set(struct cl_page *page)
 void cl_page_disown0(const struct lu_env *env,
 		     struct cl_io *io, struct cl_page *pg)
 {
+	const struct cl_page_slice *slice;
 	enum cl_page_state state;
 
 	state = pg->cp_state;
@@ -470,10 +395,10 @@ void cl_page_disown0(const struct lu_env *env,
 	 * uppermost layer (llite), responsible for VFS/VM interaction runs
 	 * last and can release locks safely.
 	 */
-	CL_PAGE_INVOID_REVERSE(env, pg, CL_PAGE_OP(cpo_disown),
-			       (const struct lu_env *,
-				const struct cl_page_slice *, struct cl_io *),
-			       io);
+	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_disown)
+			(*slice->cpl_ops->cpo_disown)(env, slice, io);
+	}
 }
 
 /**
@@ -511,7 +436,8 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
 static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 			struct cl_page *pg, int nonblock)
 {
-	int result;
+	const struct cl_page_slice *slice;
+	int result = 0;
 
 	PINVRNT(env, pg, !cl_page_is_owned(pg, io));
 
@@ -519,24 +445,31 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
 
 	if (pg->cp_state == CPS_FREEING) {
 		result = -ENOENT;
-	} else {
-		result = CL_PAGE_INVOKE(env, pg, CL_PAGE_OP(cpo_own),
-					(const struct lu_env *,
-					 const struct cl_page_slice *,
-					 struct cl_io *, int),
-					io, nonblock);
-		if (result == 0) {
-			PASSERT(env, pg, !pg->cp_owner);
-			pg->cp_owner = cl_io_top(io);
-			cl_page_owner_set(pg);
-			if (pg->cp_state != CPS_FREEING) {
-				cl_page_state_set(env, pg, CPS_OWNED);
-			} else {
-				cl_page_disown0(env, io, pg);
-				result = -ENOENT;
-			}
+		goto out;
+	}
+
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_own)
+			result = (*slice->cpl_ops->cpo_own)(env, slice,
+							    io, nonblock);
+		if (result != 0)
+			break;
+	}
+	if (result > 0)
+		result = 0;
+
+	if (result == 0) {
+		PASSERT(env, pg, !pg->cp_owner);
+		pg->cp_owner = cl_io_top(io);
+		cl_page_owner_set(pg);
+		if (pg->cp_state != CPS_FREEING) {
+			cl_page_state_set(env, pg, CPS_OWNED);
+		} else {
+			cl_page_disown0(env, io, pg);
+			result = -ENOENT;
 		}
 	}
+out:
 	PINVRNT(env, pg, ergo(result == 0, cl_page_invariant(pg)));
 	return result;
 }
@@ -577,11 +510,17 @@ int cl_page_own_try(const struct lu_env *env, struct cl_io *io,
 void cl_page_assume(const struct lu_env *env,
 		    struct cl_io *io, struct cl_page *pg)
 {
+	const struct cl_page_slice *slice;
+
 	PINVRNT(env, pg, cl_object_same(pg->cp_obj, io->ci_obj));
 
 	io = cl_io_top(io);
 
-	cl_page_invoid(env, io, pg, CL_PAGE_OP(cpo_assume));
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_assume)
+			(*slice->cpl_ops->cpo_assume)(env, slice, io);
+	}
+
 	PASSERT(env, pg, !pg->cp_owner);
 	pg->cp_owner = cl_io_top(io);
 	cl_page_owner_set(pg);
@@ -603,16 +542,19 @@ void cl_page_assume(const struct lu_env *env,
 void cl_page_unassume(const struct lu_env *env,
 		      struct cl_io *io, struct cl_page *pg)
 {
+	const struct cl_page_slice *slice;
+
 	PINVRNT(env, pg, cl_page_is_owned(pg, io));
 	PINVRNT(env, pg, cl_page_invariant(pg));
 
 	io = cl_io_top(io);
 	cl_page_owner_clear(pg);
 	cl_page_state_set(env, pg, CPS_CACHED);
-	CL_PAGE_INVOID_REVERSE(env, pg, CL_PAGE_OP(cpo_unassume),
-			       (const struct lu_env *,
-				const struct cl_page_slice *, struct cl_io *),
-			       io);
+
+	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_unassume)
+			(*slice->cpl_ops->cpo_unassume)(env, slice, io);
+	}
 }
 EXPORT_SYMBOL(cl_page_unassume);
 
@@ -651,10 +593,15 @@ void cl_page_disown(const struct lu_env *env,
 void cl_page_discard(const struct lu_env *env,
 		     struct cl_io *io, struct cl_page *pg)
 {
+	const struct cl_page_slice *slice;
+
 	PINVRNT(env, pg, cl_page_is_owned(pg, io));
 	PINVRNT(env, pg, cl_page_invariant(pg));
 
-	cl_page_invoid(env, io, pg, CL_PAGE_OP(cpo_discard));
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_discard)
+			(*slice->cpl_ops->cpo_discard)(env, slice, io);
+	}
 }
 EXPORT_SYMBOL(cl_page_discard);
 
@@ -665,18 +612,20 @@ void cl_page_discard(const struct lu_env *env,
  */
 static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
 {
+	const struct cl_page_slice *slice;
+
 	PASSERT(env, pg, pg->cp_state != CPS_FREEING);
 
 	/*
 	 * Sever all ways to obtain new pointers to @pg.
 	 */
 	cl_page_owner_clear(pg);
-
 	cl_page_state_set0(env, pg, CPS_FREEING);
 
-	CL_PAGE_INVOID_REVERSE(env, pg, CL_PAGE_OP(cpo_delete),
-			       (const struct lu_env *,
-				const struct cl_page_slice *));
+	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_delete)
+			(*slice->cpl_ops->cpo_delete)(env, slice);
+	}
 }
 
 /**
@@ -721,10 +670,14 @@ void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
  */
 void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate)
 {
+	const struct cl_page_slice *slice;
+
 	PINVRNT(env, pg, cl_page_invariant(pg));
-	CL_PAGE_INVOID(env, pg, CL_PAGE_OP(cpo_export),
-		       (const struct lu_env *,
-			const struct cl_page_slice *, int), uptodate);
+
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_export)
+			(*slice->cpl_ops->cpo_export)(env, slice, uptodate);
+	}
 }
 EXPORT_SYMBOL(cl_page_export);
 
@@ -734,8 +687,8 @@ void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate)
  */
 int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
 {
-	int result;
 	const struct cl_page_slice *slice;
+	int result;
 
 	slice = container_of(pg->cp_layers.next,
 			     const struct cl_page_slice, cpl_linkage);
@@ -776,7 +729,8 @@ static void cl_page_io_start(const struct lu_env *env,
 int cl_page_prep(const struct lu_env *env, struct cl_io *io,
 		 struct cl_page *pg, enum cl_req_type crt)
 {
-	int result;
+	const struct cl_page_slice *slice;
+	int result = 0;
 
 	PINVRNT(env, pg, cl_page_is_owned(pg, io));
 	PINVRNT(env, pg, cl_page_invariant(pg));
@@ -789,9 +743,19 @@ int cl_page_prep(const struct lu_env *env, struct cl_io *io,
 	 */
 	if (crt >= CRT_NR)
 		return -EINVAL;
-	result = cl_page_invoke(env, io, pg, CL_PAGE_OP(io[crt].cpo_prep));
-	if (result == 0)
+
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_own)
+			result = (*slice->cpl_ops->io[crt].cpo_prep)(env, slice,
+								     io);
+		if (result != 0)
+			break;
+	}
+
+	if (result >= 0) {
+		result = 0;
 		cl_page_io_start(env, pg, crt);
+	}
 
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, result);
 	return result;
@@ -817,6 +781,7 @@ void cl_page_completion(const struct lu_env *env,
 			struct cl_page *pg, enum cl_req_type crt, int ioret)
 {
 	struct cl_sync_io *anchor = pg->cp_sync_io;
+	const struct cl_page_slice *slice;
 
 	PASSERT(env, pg, crt < CRT_NR);
 	PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
@@ -826,9 +791,13 @@ void cl_page_completion(const struct lu_env *env,
 	cl_page_state_set(env, pg, CPS_CACHED);
 	if (crt >= CRT_NR)
 		return;
-	CL_PAGE_INVOID_REVERSE(env, pg, CL_PAGE_OP(io[crt].cpo_completion),
-			       (const struct lu_env *,
-				const struct cl_page_slice *, int), ioret);
+
+	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->io[crt].cpo_completion)
+			(*slice->cpl_ops->io[crt].cpo_completion)(env, slice,
+								  ioret);
+	}
+
 	if (anchor) {
 		LASSERT(pg->cp_sync_io == anchor);
 		pg->cp_sync_io = NULL;
@@ -849,18 +818,26 @@ void cl_page_completion(const struct lu_env *env,
 int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
 		       enum cl_req_type crt)
 {
-	int result;
+	const struct cl_page_slice *sli;
+	int result = 0;
 
 	PINVRNT(env, pg, crt < CRT_NR);
 
 	if (crt >= CRT_NR)
 		return -EINVAL;
-	result = CL_PAGE_INVOKE(env, pg, CL_PAGE_OP(io[crt].cpo_make_ready),
-				(const struct lu_env *,
-				 const struct cl_page_slice *));
-	if (result == 0) {
+
+	list_for_each_entry(sli, &pg->cp_layers, cpl_linkage) {
+		if (sli->cpl_ops->io[crt].cpo_make_ready)
+			result = (*sli->cpl_ops->io[crt].cpo_make_ready)(env,
+									 sli);
+		if (result != 0)
+			break;
+	}
+
+	if (result >= 0) {
 		PASSERT(env, pg, pg->cp_state == CPS_CACHED);
 		cl_page_io_start(env, pg, crt);
+		result = 0;
 	}
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, result);
 	return result;
@@ -878,12 +855,20 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
 int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 		  struct cl_page *pg)
 {
-	int result;
+	const struct cl_page_slice *slice;
+	int result = 0;
 
 	PINVRNT(env, pg, cl_page_is_owned(pg, io));
 	PINVRNT(env, pg, cl_page_invariant(pg));
 
-	result = cl_page_invoke(env, io, pg, CL_PAGE_OP(cpo_flush));
+	 list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_flush)
+			result = (*slice->cpl_ops->cpo_flush)(env, slice, io);
+		if (result != 0)
+			break;
+	}
+	if (result > 0)
+		result = 0;
 
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d\n", result);
 	return result;
@@ -898,13 +883,16 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
 void cl_page_clip(const struct lu_env *env, struct cl_page *pg,
 		  int from, int to)
 {
+	const struct cl_page_slice *slice;
+
 	PINVRNT(env, pg, cl_page_invariant(pg));
 
 	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", from, to);
-	CL_PAGE_INVOID(env, pg, CL_PAGE_OP(cpo_clip),
-		       (const struct lu_env *,
-			const struct cl_page_slice *, int, int),
-		       from, to);
+
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_clip)
+			(*slice->cpl_ops->cpo_clip)(env, slice, from, to);
+	}
 }
 EXPORT_SYMBOL(cl_page_clip);
 
@@ -928,11 +916,18 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 void cl_page_print(const struct lu_env *env, void *cookie,
 		   lu_printer_t printer, const struct cl_page *pg)
 {
+	const struct cl_page_slice *slice;
+	int result = 0;
+
 	cl_page_header_print(env, cookie, printer, pg);
-	CL_PAGE_INVOKE(env, (struct cl_page *)pg, CL_PAGE_OP(cpo_print),
-		       (const struct lu_env *env,
-			const struct cl_page_slice *slice,
-			void *cookie, lu_printer_t p), cookie, printer);
+
+	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_print)
+			result = (*slice->cpl_ops->cpo_print)(env, slice,
+							      cookie, printer);
+		if (result != 0)
+			break;
+	}
 	(*printer)(env, cookie, "end page@%p\n", pg);
 }
 EXPORT_SYMBOL(cl_page_print);
@@ -942,9 +937,19 @@ void cl_page_print(const struct lu_env *env, void *cookie,
  */
 int cl_page_cancel(const struct lu_env *env, struct cl_page *page)
 {
-	return CL_PAGE_INVOKE(env, page, CL_PAGE_OP(cpo_cancel),
-			      (const struct lu_env *,
-			       const struct cl_page_slice *));
+	const struct cl_page_slice *slice;
+	int result = 0;
+
+	list_for_each_entry(slice, &page->cp_layers, cpl_linkage) {
+		if (slice->cpl_ops->cpo_cancel)
+			result = (*slice->cpl_ops->cpo_cancel)(env, slice);
+		if (result != 0)
+			break;
+	}
+	if (result > 0)
+		result = 0;
+
+	return result;
 }
 
 /**
-- 
1.8.3.1
