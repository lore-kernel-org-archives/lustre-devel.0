From: Andreas Dilger <adilger@whamcloud.com>
Date: Sun, 13 Jan 2019 20:42:04 +0000
Subject: [lustre-devel] [PATCH 3/4] lustre: obdclass: change some foo0()
 to __foo()
In-Reply-To: <154716484605.28978.3593304564414994720.stgit@noble>
References: <154716475327.28978.3817067697027604609.stgit@noble>
 <154716484605.28978.3593304564414994720.stgit@noble>
Message-ID: <BC6C348F-CF2C-4465-8709-6F4AEA6E0438@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 10, 2019, at 16:00, NeilBrown <neilb@suse.com> wrote:
> 
> Change:
>  cl_io_init0 -> __cl_io_init
>  cl_lock_trace0 -> __cl_lock_trace
>  cl_page_delete0 -> __cl_page_delete
>  cl_page_state_set0 -> __cl_page_state_set
>  cl_page_own0 -> __cl_page_own
>  cl_page_disown0 -> __cl_page_disown
>  cl_page_delete0 -> __cl_page_delete
>  cl_echo_enqueue0 -> __cl_echo_enqueue
>  cl_echo_cancel0 -> __cl_echo_cancel
> 
> This is more consistent with Linux naming style.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@dilger.ca>

> ---
> drivers/staging/lustre/lustre/include/cl_object.h  |    6 ++-
> drivers/staging/lustre/lustre/obdclass/cl_io.c     |   14 ++++----
> drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    8 ++--
> drivers/staging/lustre/lustre/obdclass/cl_page.c   |   36 ++++++++++----------
> .../staging/lustre/lustre/obdecho/echo_client.c    |   20 ++++++-----
> 5 files changed, 42 insertions(+), 42 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> index 4f0e8e271452..d0e61e503f9d 100644
> --- a/drivers/staging/lustre/lustre/include/cl_object.h
> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
> @@ -803,7 +803,7 @@ struct cl_page_operations {
> 	/**
> 	 * cl_page<->struct page methods. Only one layer in the stack has to
> 	 * implement these. Current code assumes that this functionality is
> -	 * provided by the topmost layer, see cl_page_disown0() as an example.
> +	 * provided by the topmost layer, see __cl_page_disown() as an example.
> 	 */
> 
> 	/**
> @@ -2144,8 +2144,8 @@ void cl_page_unassume(const struct lu_env *env,
> 		      struct cl_io *io, struct cl_page *pg);
> void cl_page_disown(const struct lu_env *env,
> 		    struct cl_io *io, struct cl_page *page);
> -void cl_page_disown0(const struct lu_env *env,
> -		     struct cl_io *io, struct cl_page *pg);
> +void __cl_page_disown(const struct lu_env *env,
> +		      struct cl_io *io, struct cl_page *pg);
> int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io);
> 
> /** @} ownership */
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index 0da731cfeb30..84c7710f80d7 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -131,8 +131,8 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
> }
> EXPORT_SYMBOL(cl_io_fini);
> 
> -static int cl_io_init0(const struct lu_env *env, struct cl_io *io,
> -		       enum cl_io_type iot, struct cl_object *obj)
> +static int __cl_io_init(const struct lu_env *env, struct cl_io *io,
> +			enum cl_io_type iot, struct cl_object *obj)
> {
> 	struct cl_object *scan;
> 	int result;
> @@ -169,7 +169,7 @@ int cl_io_sub_init(const struct lu_env *env, struct cl_io *io,
> {
> 	LASSERT(obj != cl_object_top(obj));
> 
> -	return cl_io_init0(env, io, iot, obj);
> +	return __cl_io_init(env, io, iot, obj);
> }
> EXPORT_SYMBOL(cl_io_sub_init);
> 
> @@ -188,7 +188,7 @@ int cl_io_init(const struct lu_env *env, struct cl_io *io,
> {
> 	LASSERT(obj == cl_object_top(obj));
> 
> -	return cl_io_init0(env, io, iot, obj);
> +	return __cl_io_init(env, io, iot, obj);
> }
> EXPORT_SYMBOL(cl_io_init);
> 
> @@ -897,14 +897,14 @@ void cl_page_list_disown(const struct lu_env *env,
> 		list_del_init(&page->cp_batch);
> 		--plist->pl_nr;
> 		/*
> -		 * cl_page_disown0 rather than usual cl_page_disown() is used,
> +		 * __cl_page_disown rather than usual cl_page_disown() is used,
> 		 * because pages are possibly in CPS_FREEING state already due
> 		 * to the call to cl_page_list_discard().
> 		 */
> 		/*
> -		 * XXX cl_page_disown0() will fail if page is not locked.
> +		 * XXX __cl_page_disown() will fail if page is not locked.
> 		 */
> -		cl_page_disown0(env, io, page);
> +		__cl_page_disown(env, io, page);
> 		lu_ref_del_at(&page->cp_reference, &page->cp_queue_ref, "queue",
> 			      plist);
> 		cl_page_put(env, page);
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> index 9ca29a26a38b..23c1609415a3 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> @@ -45,9 +45,9 @@
> #include <cl_object.h>
> #include "cl_internal.h"
> 
> -static void cl_lock_trace0(int level, const struct lu_env *env,
> -			   const char *prefix, const struct cl_lock *lock,
> -			   const char *func, const int line)
> +static void __cl_lock_trace(int level, const struct lu_env *env,
> +			    const char *prefix, const struct cl_lock *lock,
> +			    const char *func, const int line)
> {
> 	struct cl_object_header *h = cl_object_header(lock->cll_descr.cld_obj);
> 
> @@ -55,7 +55,7 @@ static void cl_lock_trace0(int level, const struct lu_env *env,
> 	       prefix, lock, env, h->coh_nesting, func, line);
> }
> #define cl_lock_trace(level, env, prefix, lock)				\
> -	cl_lock_trace0(level, env, prefix, lock, __func__, __LINE__)
> +	__cl_lock_trace(level, env, prefix, lock, __func__, __LINE__)
> 
> /**
>  * Adds lock slice to the compound lock.
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> index 00df94b87606..5794b1cbfb54 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> @@ -45,7 +45,7 @@
> #include <cl_object.h>
> #include "cl_internal.h"
> 
> -static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg);
> +static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg);
> 
> # define PASSERT(env, page, expr)					   \
> 	do {								   \
> @@ -156,7 +156,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
> 				result = o->co_ops->coo_page_init(env, o, page,
> 								  ind);
> 				if (result != 0) {
> -					cl_page_delete0(env, page);
> +					__cl_page_delete(env, page);
> 					cl_page_free(env, page);
> 					page = ERR_PTR(result);
> 					break;
> @@ -228,8 +228,8 @@ static inline int cl_page_invariant(const struct cl_page *pg)
> 	return cl_page_in_use_noref(pg);
> }
> 
> -static void cl_page_state_set0(const struct lu_env *env,
> -			       struct cl_page *page, enum cl_page_state state)
> +static void __cl_page_state_set(const struct lu_env *env,
> +				struct cl_page *page, enum cl_page_state state)
> {
> 	enum cl_page_state old;
> 
> @@ -286,7 +286,7 @@ static void cl_page_state_set0(const struct lu_env *env,
> static void cl_page_state_set(const struct lu_env *env,
> 			      struct cl_page *page, enum cl_page_state state)
> {
> -	cl_page_state_set0(env, page, state);
> +	__cl_page_state_set(env, page, state);
> }
> 
> /**
> @@ -377,7 +377,7 @@ static void cl_page_owner_set(struct cl_page *page)
> 	page->cp_owner->ci_owned_nr++;
> }
> 
> -void cl_page_disown0(const struct lu_env *env,
> +void __cl_page_disown(const struct lu_env *env,
> 		     struct cl_io *io, struct cl_page *pg)
> {
> 	const struct cl_page_slice *slice;
> @@ -433,8 +433,8 @@ EXPORT_SYMBOL(cl_page_is_owned);
>  * \see cl_page_own_try()
>  * \see cl_page_own
>  */
> -static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
> -			struct cl_page *pg, int nonblock)
> +static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
> +			 struct cl_page *pg, int nonblock)
> {
> 	const struct cl_page_slice *slice;
> 	int result = 0;
> @@ -465,7 +465,7 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
> 		if (pg->cp_state != CPS_FREEING) {
> 			cl_page_state_set(env, pg, CPS_OWNED);
> 		} else {
> -			cl_page_disown0(env, io, pg);
> +			__cl_page_disown(env, io, pg);
> 			result = -ENOENT;
> 		}
> 	}
> @@ -477,23 +477,23 @@ static int cl_page_own0(const struct lu_env *env, struct cl_io *io,
> /**
>  * Own a page, might be blocked.
>  *
> - * \see cl_page_own0()
> + * \see __cl_page_own()
>  */
> int cl_page_own(const struct lu_env *env, struct cl_io *io, struct cl_page *pg)
> {
> -	return cl_page_own0(env, io, pg, 0);
> +	return __cl_page_own(env, io, pg, 0);
> }
> EXPORT_SYMBOL(cl_page_own);
> 
> /**
>  * Nonblock version of cl_page_own().
>  *
> - * \see cl_page_own0()
> + * \see __cl_page_own()
>  */
> int cl_page_own_try(const struct lu_env *env, struct cl_io *io,
> 		    struct cl_page *pg)
> {
> -	return cl_page_own0(env, io, pg, 1);
> +	return __cl_page_own(env, io, pg, 1);
> }
> EXPORT_SYMBOL(cl_page_own_try);
> 
> @@ -576,7 +576,7 @@ void cl_page_disown(const struct lu_env *env,
> 		pg->cp_state == CPS_FREEING);
> 
> 	io = cl_io_top(io);
> -	cl_page_disown0(env, io, pg);
> +	__cl_page_disown(env, io, pg);
> }
> EXPORT_SYMBOL(cl_page_disown);
> 
> @@ -607,10 +607,10 @@ EXPORT_SYMBOL(cl_page_discard);
> 
> /**
>  * Version of cl_page_delete() that can be called for not fully constructed
> - * pages, e.g,. in a error handling cl_page_find()->cl_page_delete0()
> + * pages, e.g,. in a error handling cl_page_find()->__cl_page_delete()
>  * path. Doesn't check page invariant.
>  */
> -static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
> +static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg)
> {
> 	const struct cl_page_slice *slice;
> 
> @@ -620,7 +620,7 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
> 	 * Sever all ways to obtain new pointers to @pg.
> 	 */
> 	cl_page_owner_clear(pg);
> -	cl_page_state_set0(env, pg, CPS_FREEING);
> +	__cl_page_state_set(env, pg, CPS_FREEING);
> 
> 	list_for_each_entry_reverse(slice, &pg->cp_layers, cpl_linkage) {
> 		if (slice->cpl_ops->cpo_delete)
> @@ -655,7 +655,7 @@ static void cl_page_delete0(const struct lu_env *env, struct cl_page *pg)
> void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
> {
> 	PINVRNT(env, pg, cl_page_invariant(pg));
> -	cl_page_delete0(env, pg);
> +	__cl_page_delete(env, pg);
> }
> EXPORT_SYMBOL(cl_page_delete);
> 
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> index 887df7ce6b5c..39b7ab1447a4 100644
> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> @@ -910,9 +910,9 @@ static int cl_echo_object_put(struct echo_object *eco)
> 	return 0;
> }
> 
> -static int cl_echo_enqueue0(struct lu_env *env, struct echo_object *eco,
> -			    u64 start, u64 end, int mode,
> -			    __u64 *cookie, __u32 enqflags)
> +static int __cl_echo_enqueue(struct lu_env *env, struct echo_object *eco,
> +			     u64 start, u64 end, int mode,
> +			     __u64 *cookie, __u32 enqflags)
> {
> 	struct cl_io *io;
> 	struct cl_lock *lck;
> @@ -953,8 +953,8 @@ static int cl_echo_enqueue0(struct lu_env *env, struct echo_object *eco,
> 	return rc;
> }
> 
> -static int cl_echo_cancel0(struct lu_env *env, struct echo_device *ed,
> -			   __u64 cookie)
> +static int __cl_echo_cancel(struct lu_env *env, struct echo_device *ed,
> +			    __u64 cookie)
> {
> 	struct echo_client_obd *ec = ed->ed_ec;
> 	struct echo_lock       *ecl = NULL;
> @@ -1028,10 +1028,10 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
> 		goto out;
> 	LASSERT(rc == 0);
> 
> -	rc = cl_echo_enqueue0(env, eco, offset,
> -			      offset + npages * PAGE_SIZE - 1,
> -			      rw == READ ? LCK_PR : LCK_PW, &lh.cookie,
> -			      CEF_NEVER);
> +	rc = __cl_echo_enqueue(env, eco, offset,
> +			       offset + npages * PAGE_SIZE - 1,
> +			       rw == READ ? LCK_PR : LCK_PW, &lh.cookie,
> +			       CEF_NEVER);
> 	if (rc < 0)
> 		goto error_lock;
> 
> @@ -1079,7 +1079,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
> 		       async ? "async" : "sync", rc);
> 	}
> 
> -	cl_echo_cancel0(env, ed, lh.cookie);
> +	__cl_echo_cancel(env, ed, lh.cookie);
> error_lock:
> 	cl_2queue_discard(env, io, queue);
> 	cl_2queue_disown(env, io, queue);
> 
> 

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
