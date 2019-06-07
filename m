From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Jun 2019 10:56:55 +1000
Subject: [lustre-devel] [PATCH] Place a memory barrier around cp_state
 changes
In-Reply-To: <20190606223110.15725-1-stancheff@cray.com>
References: <20190606223110.15725-1-stancheff@cray.com>
Message-ID: <87wohyw6ug.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 06 2019, Shaun Tancheff wrote:

> Ensure all uses of cl_page->cp_state are smp-safe.
>
> LBUG Output:
> In __cl_page_state_set()
> ..
>   old = page->cp_state;
>   PASSERT(env, page, allowed_transitions[old][state]);
> ..
> Asserted with the following:
>   page at ffff80be1fcd6600[3 ffff80be1fca5cc0 0 1 ffff809e60e2 8cc0]

What do all these fields mean?  Or where is this printed?
The closest I can find is in cl_page_header_print() which uses the
format string:

		   "page@%p[%d %p %d %d %p]\n",

But that only has 5 fields in the [], while the output you provided has
6.

>
> However cp_state 0 (CPS_CACHED) to 1 (CPS_OWNED) is a valid transition
> leading to the conclusion that cp_state became 0 during the
> assertion.

Where is the evidence that this was the transition that was happening?
If it was in some part of the LBUG output that wasn't quoted - then
please fix that by quoting the entire LBUG output.

We need to understand which change happened at this time to cause the
race.
Then we need to explain why the added barriers actually close the race
window.

If these barrier do actually fix a race, then there is something *very*
wrong.
The comments say that changes to cp_state are protected by the page lock
on the corresponding VM page.
Locking and unlocking a VM page entails sufficient barriers that changes
made while one thread holds the lock will be visible to another
thread once it also gets the lock.

So the only possible explanation for a race as you suspect, is if the
vmpage *isn't* locked when something changes cp_state, and that would be
bad.

Thanks,
NeilBrown


>
> Signed-off-by: Shaun Tancheff <stancheff@cray.com>
> ---
>  fs/lustre/include/cl_object.h   | 11 +++++++++++
>  fs/lustre/llite/rw26.c          |  2 +-
>  fs/lustre/llite/vvp_page.c      |  6 +++---
>  fs/lustre/obdclass/cl_page.c    | 34 +++++++++++++++++++--------------
>  fs/lustre/obdecho/echo_client.c |  2 +-
>  fs/lustre/osc/osc_cache.c       | 18 +++++++++--------
>  6 files changed, 46 insertions(+), 27 deletions(-)
>
> diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
> index 691c2f5da53a..d6e1f6f05f50 100644
> --- a/fs/lustre/include/cl_object.h
> +++ b/fs/lustre/include/cl_object.h
> @@ -752,6 +752,17 @@ struct cl_page {
>  	struct cl_sync_io		*cp_sync_io;
>  };
>  
> +static inline enum cl_page_state cl_page_state_get(const struct cl_page *pg)
> +{
> +	/*
> +	 * Paired with smp_store_release in cl_page_state_set_trust
> +	 * and ensures that we see the most recent value of cp_state
> +	 * even when the last modification was not performed on the
> +	 * current processor
> +	 */
> +	return smp_load_acquire(&pg->cp_state);
> +}
> +
>  /**
>   * Per-layer part of cl_page.
>   *
> diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
> index e4ce3b6f5772..364dec208ccd 100644
> --- a/fs/lustre/llite/rw26.c
> +++ b/fs/lustre/llite/rw26.c
> @@ -200,7 +200,7 @@ static ssize_t ll_direct_IO_seg(const struct lu_env *env, struct cl_io *io,
>  
>  		rc = cl_page_own(env, io, clp);
>  		if (rc) {
> -			LASSERT(clp->cp_state == CPS_FREEING);
> +			LASSERT(cl_page_state_get(clp) == CPS_FREEING);
>  			cl_page_put(env, clp);
>  			break;
>  		}
> diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
> index 590e5f5e43c9..38b8c488d765 100644
> --- a/fs/lustre/llite/vvp_page.c
> +++ b/fs/lustre/llite/vvp_page.c
> @@ -323,18 +323,18 @@ static int vvp_page_make_ready(const struct lu_env *env,
>  
>  	lock_page(vmpage);
>  	if (clear_page_dirty_for_io(vmpage)) {
> -		LASSERT(pg->cp_state == CPS_CACHED);
> +		LASSERT(cl_page_state_get(pg) == CPS_CACHED);
>  		/* This actually clears the dirty bit in the radix tree. */
>  		set_page_writeback(vmpage);
>  		CL_PAGE_HEADER(D_PAGE, env, pg, "readied\n");
> -	} else if (pg->cp_state == CPS_PAGEOUT) {
> +	} else if (cl_page_state_get(pg) == CPS_PAGEOUT) {
>  		/* is it possible for osc_flush_async_page() to already
>  		 * make it ready?
>  		 */
>  		result = -EALREADY;
>  	} else {
>  		CL_PAGE_DEBUG(D_ERROR, env, pg, "Unexpecting page state %d.\n",
> -			      pg->cp_state);
> +			      cl_page_state_get(pg));
>  		LBUG();
>  	}
>  	unlock_page(vmpage);
> diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
> index 349f19e014e0..da4429b82932 100644
> --- a/fs/lustre/obdclass/cl_page.c
> +++ b/fs/lustre/obdclass/cl_page.c
> @@ -97,7 +97,7 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
>  
>  	PASSERT(env, page, list_empty(&page->cp_batch));
>  	PASSERT(env, page, !page->cp_owner);
> -	PASSERT(env, page, page->cp_state == CPS_FREEING);
> +	PASSERT(env, page, cl_page_state_get(page) == CPS_FREEING);
>  
>  	while ((slice = list_first_entry_or_null(&page->cp_layers,
>  						 struct cl_page_slice,
> @@ -119,8 +119,14 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
>  static inline void cl_page_state_set_trust(struct cl_page *page,
>  					   enum cl_page_state state)
>  {
> -	/* bypass const. */
> -	*(enum cl_page_state *)&page->cp_state = state;
> +	/*
> +	 * Paired with smp_load_acquire in cl_page_state_get
> +	 * and ensures that we see the most recent value of cp_state
> +	 * is available even when the next access is not performed on the
> +	 * current processor.
> +	 * Note we also cast away const as the only modifier of cp_state.
> +	 */
> +	smp_store_release((enum cl_page_state *)&page->cp_state, state);
>  }
>  
>  struct cl_page *cl_page_alloc(const struct lu_env *env,
> @@ -270,10 +276,10 @@ static void __cl_page_state_set(const struct lu_env *env,
>  		}
>  	};
>  
> -	old = page->cp_state;
> +	old = cl_page_state_get(page);
>  	PASSERT(env, page, allowed_transitions[old][state]);
>  	CL_PAGE_HEADER(D_TRACE, env, page, "%d -> %d\n", old, state);
> -	PASSERT(env, page, page->cp_state == old);
> +	PASSERT(env, page, cl_page_state_get(page) == old);
>  	PASSERT(env, page, equi(state == CPS_OWNED, page->cp_owner));
>  	cl_page_state_set_trust(page, state);
>  }
> @@ -313,7 +319,7 @@ void cl_page_put(const struct lu_env *env, struct cl_page *page)
>  		       refcount_read(&page->cp_ref));
>  
>  	if (refcount_dec_and_test(&page->cp_ref)) {
> -		LASSERT(page->cp_state == CPS_FREEING);
> +		LASSERT(cl_page_state_get(page) == CPS_FREEING);
>  
>  		LASSERT(refcount_read(&page->cp_ref) == 0);
>  		PASSERT(env, page, !page->cp_owner);
> @@ -378,7 +384,7 @@ void __cl_page_disown(const struct lu_env *env,
>  	const struct cl_page_slice *slice;
>  	enum cl_page_state state;
>  
> -	state = pg->cp_state;
> +	state = cl_page_state_get(pg);
>  	cl_page_owner_clear(pg);
>  
>  	if (state == CPS_OWNED)
> @@ -402,7 +408,7 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
>  	struct cl_io *top = cl_io_top((struct cl_io *)io);
>  
>  	LINVRNT(cl_object_same(pg->cp_obj, io->ci_obj));
> -	return pg->cp_state == CPS_OWNED && pg->cp_owner == top;
> +	return cl_page_state_get(pg) == CPS_OWNED && pg->cp_owner == top;
>  }
>  EXPORT_SYMBOL(cl_page_is_owned);
>  
> @@ -434,7 +440,7 @@ static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
>  
>  	io = cl_io_top(io);
>  
> -	if (pg->cp_state == CPS_FREEING) {
> +	if (cl_page_state_get(pg) == CPS_FREEING) {
>  		result = -ENOENT;
>  		goto out;
>  	}
> @@ -453,7 +459,7 @@ static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
>  		PASSERT(env, pg, !pg->cp_owner);
>  		pg->cp_owner = cl_io_top(io);
>  		cl_page_owner_set(pg);
> -		if (pg->cp_state != CPS_FREEING) {
> +		if (cl_page_state_get(pg) != CPS_FREEING) {
>  			cl_page_state_set(env, pg, CPS_OWNED);
>  		} else {
>  			__cl_page_disown(env, io, pg);
> @@ -593,7 +599,7 @@ static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg)
>  {
>  	const struct cl_page_slice *slice;
>  
> -	PASSERT(env, pg, pg->cp_state != CPS_FREEING);
> +	PASSERT(env, pg, cl_page_state_get(pg) != CPS_FREEING);
>  
>  	/*
>  	 * Sever all ways to obtain new pointers to @pg.
> @@ -756,7 +762,7 @@ void cl_page_completion(const struct lu_env *env,
>  	const struct cl_page_slice *slice;
>  
>  	PASSERT(env, pg, crt < CRT_NR);
> -	PASSERT(env, pg, pg->cp_state == cl_req_type_state(crt));
> +	PASSERT(env, pg, cl_page_state_get(pg) == cl_req_type_state(crt));
>  
>  	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", crt, ioret);
>  
> @@ -805,7 +811,7 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
>  	}
>  
>  	if (result >= 0) {
> -		PASSERT(env, pg, pg->cp_state == CPS_CACHED);
> +		PASSERT(env, pg, cl_page_state_get(pg) == CPS_CACHED);
>  		cl_page_io_start(env, pg, crt);
>  		result = 0;
>  	}
> @@ -870,7 +876,7 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
>  	(*printer)(env, cookie,
>  		   "page@%p[%d %p %d %d %p]\n",
>  		   pg, refcount_read(&pg->cp_ref), pg->cp_obj,
> -		   pg->cp_state, pg->cp_type,
> +		   cl_page_state_get(pg), pg->cp_type,
>  		   pg->cp_owner);
>  }
>  EXPORT_SYMBOL(cl_page_header_print);
> diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
> index 317123fd27cb..d879f109e641 100644
> --- a/fs/lustre/obdecho/echo_client.c
> +++ b/fs/lustre/obdecho/echo_client.c
> @@ -1046,7 +1046,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
>  
>  		rc = cl_page_own(env, io, clp);
>  		if (rc) {
> -			LASSERT(clp->cp_state == CPS_FREEING);
> +			LASSERT(cl_page_state_get(clp) == CPS_FREEING);
>  			cl_page_put(env, clp);
>  			break;
>  		}
> diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
> index f8fddbfe6a7e..75984b98b229 100644
> --- a/fs/lustre/osc/osc_cache.c
> +++ b/fs/lustre/osc/osc_cache.c
> @@ -1045,7 +1045,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
>  			cl_page_discard(env, io, page);
>  			cl_page_disown(env, io, page);
>  		} else {
> -			LASSERT(page->cp_state == CPS_FREEING);
> +			LASSERT(cl_page_state_get(page) == CPS_FREEING);
>  			LASSERT(0);
>  		}
>  
> @@ -1356,10 +1356,12 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
>  	int srvlock;
>  
>  	cmd &= ~OBD_BRW_NOQUOTA;
> -	LASSERTF(equi(page->cp_state == CPS_PAGEIN, cmd == OBD_BRW_READ),
> -		 "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
> -	LASSERTF(equi(page->cp_state == CPS_PAGEOUT, cmd == OBD_BRW_WRITE),
> -		 "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
> +	LASSERTF(equi(cl_page_state_get(page) == CPS_PAGEIN,
> +		      cmd == OBD_BRW_READ),
> +		 "cp_state:%u, cmd:%d\n", cl_page_state_get(page), cmd);
> +	LASSERTF(equi(cl_page_state_get(page) == CPS_PAGEOUT,
> +		      cmd == OBD_BRW_WRITE),
> +		 "cp_state:%u, cmd:%d\n", cl_page_state_get(page), cmd);
>  	LASSERT(opg->ops_transfer_pinned);
>  
>  	crt = cmd == OBD_BRW_READ ? CRT_READ : CRT_WRITE;
> @@ -3061,7 +3063,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
>  
>  			page = ops->ops_cl.cpl_page;
>  			LASSERT(page->cp_type == CPT_CACHEABLE);
> -			if (page->cp_state == CPS_FREEING)
> +			if (cl_page_state_get(page) == CPS_FREEING)
>  				continue;
>  
>  			cl_page_get(page);
> @@ -3142,7 +3144,7 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
>  			cl_page_discard(env, io, page);
>  			cl_page_disown(env, io, page);
>  		} else {
> -			LASSERT(page->cp_state == CPS_FREEING);
> +			LASSERT(cl_page_state_get(page) == CPS_FREEING);
>  		}
>  	}
>  
> @@ -3169,7 +3171,7 @@ static bool discard_cb(const struct lu_env *env, struct cl_io *io,
>  		cl_page_discard(env, io, page);
>  		cl_page_disown(env, io, page);
>  	} else {
> -		LASSERT(page->cp_state == CPS_FREEING);
> +		LASSERT(cl_page_state_get(page) == CPS_FREEING);
>  	}
>  
>  	return true;
> -- 
> 2.17.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190607/c70353a9/attachment.sig>
