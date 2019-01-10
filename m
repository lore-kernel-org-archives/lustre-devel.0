From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:40:30 +0000
Subject: [lustre-devel] [PATCH 26/29] lustre: osc_cache: simplify
 osc_page_gang_lookup()
In-Reply-To: <154701504269.26726.8061168646539306509.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504269.26726.8061168646539306509.stgit@noble>
Message-ID: <AECE9036-4F2A-4330-A8AD-3105A3D4014C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> osc_page_gang_lookup() has 4 values that it can receive from a
> callback, and that it can return to the caller:
> 	CLP_GANG_OKAY,
> 	CLP_GANG_RESCHED,
> 	CLP_GANG_AGAIN,
> 	CLP_GANG_ABORT
> 
> "AGAIN" is never used.
> "RESCHED" is not needed as a cond_resched() can safely be called at
> the point this is returned, rather than returning it.
> That leaves "OKAY" and "ABORT" which can simply by "true" and "false"
> boolean values.
> 
> Internalizing the RESCHED case means the callers don't need to loop
> themselves.  This simplify calling patterns.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/include/cl_object.h  |    7 ----
> drivers/staging/lustre/lustre/osc/osc_cache.c      |   40 ++++++++------------
> .../staging/lustre/lustre/osc/osc_cl_internal.h    |   10 +++--
> drivers/staging/lustre/lustre/osc/osc_io.c         |    4 +-
> drivers/staging/lustre/lustre/osc/osc_lock.c       |   27 ++++++--------
> 5 files changed, 33 insertions(+), 55 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 79bcaa212339..e01f3815978c 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -3069,10 +3065,10 @@ int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
> 		if (nr < OTI_PVEC_SIZE || end_of_region)
> 			break;
> 
> -		if (res == CLP_GANG_OKAY && need_resched())
> -			res = CLP_GANG_RESCHED;
> -		if (res != CLP_GANG_OKAY)
> +		if (!res)
> 			break;
> +		if (need_resched())
> +			cond_resched();
> 
> 		spin_lock(&osc->oo_tree_lock);
> 		tree_lock = true;

The one thing I notice here is that if the CLP_GANG_RESCHED is not
returned to the caller, it doesn't have the chance to finish the
work before it is rescheduled:

        do {
                res = osc_page_gang_lookup(env, io, osc,
                                   info->oti_next_index, end, cb, osc);
                if (info->oti_next_index > end)
                        break;

                if (res == CLP_GANG_RESCHED)
                        cond_resched();
        } while (res != CLP_GANG_OKAY);

That means if the thread did a lot of work in osc_page_gang_lookup()
but is otherwise finished, it will block at the internal cond_resched()
rather than detecting it is finishing and returning to the caller without
any reschedule at all.

However, looking into the osc_page_gang_lookup() code more closely, I
see "end_of_region" would already be set in this case (it is just at
the start of the context in the above patch hunk) so CLP_GANG_RESCHED
should never be set in that case.  So it looks OK.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
> index 4cc813d192d9..1eab61d720e2 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_lock.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
> @@ -630,18 +630,18 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
> 	return result;
> }
> 
> -static int weigh_cb(const struct lu_env *env, struct cl_io *io,
> -		    struct osc_page *ops, void *cbdata)
> +static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
> +		     struct osc_page *ops, void *cbdata)
> {
> 	struct cl_page *page = ops->ops_cl.cpl_page;
> 
> 	if (cl_page_is_vmlocked(env, page) ||
> 	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
> 	   )

This is a bit oddly formatted.  I see in our tree it looks like:

        if (cl_page_is_vmlocked(env, page) || PageDirty(page->cp_vmpage) ||
            PageWriteback(page->cp_vmpage))

which is more normal.

> @@ -660,19 +660,14 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
> 		return result;
> 
> 	page_index = cl_index(obj, extent->start);
> +
> +	result = osc_page_gang_lookup(env, io, oscobj,
> +				      page_index,
> +				      cl_index(obj, extent->end),
> +				      weigh_cb, (void *)&page_index);
> 	cl_io_fini(env, io);
> 
> -	return result == CLP_GANG_ABORT ? 1 : 0;
> +	return result ? 1 : 0;
> }

Per your commit comment above:

> That leaves "OKAY" and "ABORT" which can simply by "true" and "false"
> boolean values.

So if "ABORT" is now "false", this should be:

	return !result;

otherwise your return code logic is backward?

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
