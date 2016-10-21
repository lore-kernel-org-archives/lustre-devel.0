From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 21 Oct 2016 22:34:53 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: Move assignments out of
	function calls.
In-Reply-To: <20161021221431.GA18524@lennorien.com>
References: <20161021221431.GA18524@lennorien.com>
Message-ID: <9F8D3E74-59D6-443A-A4A5-33C8A5D9C613@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 21, 2016, at 16:14, Elise Lennion <elise.lennion@gmail.com> wrote:
> 
> Assignments inside of function calls confuse the reader and should be
> avoided, so they were moved out before the call.

Thanks for your patch.  I agree that this kind of usage is bad and avoid
it in my own code and try to remove it when I see it.  However, in some
cases it is needed to simplify the code flow (e.g. in conditionals that
would otherwise need to duplicate logic).

More comments below.

> Found with Coccinelle, semantic patch:
> @@
> identifier f;
> expression e1, e2;
> assignment operator a;
> @@
> 
> + e1 a e2;
> f(...,
> - (e1 a e2)
> + e1
> ,...);
> 
> Signed-off-by: Elise Lennion <elise.lennion@gmail.com>
> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 5 ++---
> drivers/staging/lustre/lustre/llite/vvp_io.c    | 3 ++-
> 2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> index 12647af..ec7f2a8 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> @@ -764,9 +764,8 @@ static int ldlm_bl_thread_main(void *arg)
> 
> 		if (!blwi) {
> 			atomic_dec(&blp->blp_busy_threads);
> -			l_wait_event_exclusive(blp->blp_waitq,
> -					       (blwi = ldlm_bl_get_work(blp)),
> -					       &lwi);
> +			blwi = ldlm_bl_get_work(blp);
> +			l_wait_event_exclusive(blp->blp_waitq, blwi, &lwi);

This first change is broken, since l_wait_event_exclusive() is actually a
macro that is waiting until ldlm_bl_get_work() returns a work item.  Moving
the blwi assignment before the wait means that this will wait forever.

This can be ignored for now, as there is a patch in the pipeline to clean
up this code (http://review.whamcloud.com/5843) that James should be
getting close to pushing, and it removes this inline assignment.

> 			busy = atomic_inc_return(&blp->blp_busy_threads);
> 		} else {
> 			busy = atomic_read(&blp->blp_busy_threads);
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
> index 1a4b897..87fdab2 100644
> --- a/drivers/staging/lustre/lustre/llite/vvp_io.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
> @@ -450,7 +450,8 @@ static void vvp_io_advance(const struct lu_env *env,
> 	struct vvp_io	 *vio = cl2vvp_io(env, ios);
> 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
> 
> -	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count  -= nob);
> +	vio->vui_tot_count -= nob;
> +	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count);

This one is fine.  Please resubmit the patch with just this change.  You
can add "Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>" for that
patch.

Cheers, Andreas

> }
> 
> static void vvp_io_update_iov(const struct lu_env *env,
> -- 
> 2.7.4
> 
