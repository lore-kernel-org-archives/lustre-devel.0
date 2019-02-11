From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 04:01:40 +0000 (GMT)
Subject: [lustre-devel] [PATCH 12/21] lustre: cl_page.c: remove PINVRNT()
In-Reply-To: <154949781317.10620.17224594880512218856.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781317.10620.17224594880512218856.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110401270.5690@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Thu, 7 Feb 2019, NeilBrown wrote:

> This macro does nothing (it once was like 'assert'),
> so remove it.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/cl_page.c |   33 ----------------------
>  1 file changed, 33 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> index 7d00a9233a3b..31ded52e0499 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> @@ -55,9 +55,6 @@ static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg);
>  		}							   \
>  	} while (0)
>  
> -# define PINVRNT(env, page, exp) \
> -	((void)sizeof(env), (void)sizeof(page), (void)sizeof !!(exp))
> -
>  /**
>   * Internal version of cl_page_get().
>   *
> @@ -382,8 +379,6 @@ void __cl_page_disown(const struct lu_env *env,
>  	enum cl_page_state state;
>  
>  	state = pg->cp_state;
> -	PINVRNT(env, pg, state == CPS_OWNED || state == CPS_FREEING);
> -	PINVRNT(env, pg, cl_page_invariant(pg) || state == CPS_FREEING);
>  	cl_page_owner_clear(pg);
>  
>  	if (state == CPS_OWNED)
> @@ -437,8 +432,6 @@ static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
>  	const struct cl_page_slice *slice;
>  	int result = 0;
>  
> -	PINVRNT(env, pg, !cl_page_is_owned(pg, io));
> -
>  	io = cl_io_top(io);
>  
>  	if (pg->cp_state == CPS_FREEING) {
> @@ -468,7 +461,6 @@ static int __cl_page_own(const struct lu_env *env, struct cl_io *io,
>  		}
>  	}
>  out:
> -	PINVRNT(env, pg, ergo(result == 0, cl_page_invariant(pg)));
>  	return result;
>  }
>  
> @@ -510,8 +502,6 @@ void cl_page_assume(const struct lu_env *env,
>  {
>  	const struct cl_page_slice *slice;
>  
> -	PINVRNT(env, pg, cl_object_same(pg->cp_obj, io->ci_obj));
> -
>  	io = cl_io_top(io);
>  
>  	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
> @@ -542,9 +532,6 @@ void cl_page_unassume(const struct lu_env *env,
>  {
>  	const struct cl_page_slice *slice;
>  
> -	PINVRNT(env, pg, cl_page_is_owned(pg, io));
> -	PINVRNT(env, pg, cl_page_invariant(pg));
> -
>  	io = cl_io_top(io);
>  	cl_page_owner_clear(pg);
>  	cl_page_state_set(env, pg, CPS_CACHED);
> @@ -570,9 +557,6 @@ EXPORT_SYMBOL(cl_page_unassume);
>  void cl_page_disown(const struct lu_env *env,
>  		    struct cl_io *io, struct cl_page *pg)
>  {
> -	PINVRNT(env, pg, cl_page_is_owned(pg, io) ||
> -		pg->cp_state == CPS_FREEING);
> -
>  	io = cl_io_top(io);
>  	__cl_page_disown(env, io, pg);
>  }
> @@ -593,9 +577,6 @@ void cl_page_discard(const struct lu_env *env,
>  {
>  	const struct cl_page_slice *slice;
>  
> -	PINVRNT(env, pg, cl_page_is_owned(pg, io));
> -	PINVRNT(env, pg, cl_page_invariant(pg));
> -
>  	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
>  		if (slice->cpl_ops->cpo_discard)
>  			(*slice->cpl_ops->cpo_discard)(env, slice, io);
> @@ -652,7 +633,6 @@ static void __cl_page_delete(const struct lu_env *env, struct cl_page *pg)
>   */
>  void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
>  {
> -	PINVRNT(env, pg, cl_page_invariant(pg));
>  	__cl_page_delete(env, pg);
>  }
>  EXPORT_SYMBOL(cl_page_delete);
> @@ -670,8 +650,6 @@ void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate)
>  {
>  	const struct cl_page_slice *slice;
>  
> -	PINVRNT(env, pg, cl_page_invariant(pg));
> -
>  	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
>  		if (slice->cpl_ops->cpo_export)
>  			(*slice->cpl_ops->cpo_export)(env, slice, uptodate);
> @@ -730,10 +708,6 @@ int cl_page_prep(const struct lu_env *env, struct cl_io *io,
>  	const struct cl_page_slice *slice;
>  	int result = 0;
>  
> -	PINVRNT(env, pg, cl_page_is_owned(pg, io));
> -	PINVRNT(env, pg, cl_page_invariant(pg));
> -	PINVRNT(env, pg, crt < CRT_NR);
> -
>  	/*
>  	 * XXX this has to be called bottom-to-top, so that llite can set up
>  	 * PG_writeback without risking other layers deciding to skip this
> @@ -819,8 +793,6 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *pg,
>  	const struct cl_page_slice *sli;
>  	int result = 0;
>  
> -	PINVRNT(env, pg, crt < CRT_NR);
> -
>  	if (crt >= CRT_NR)
>  		return -EINVAL;
>  
> @@ -856,9 +828,6 @@ int cl_page_flush(const struct lu_env *env, struct cl_io *io,
>  	const struct cl_page_slice *slice;
>  	int result = 0;
>  
> -	PINVRNT(env, pg, cl_page_is_owned(pg, io));
> -	PINVRNT(env, pg, cl_page_invariant(pg));
> -
>  	 list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
>  		if (slice->cpl_ops->cpo_flush)
>  			result = (*slice->cpl_ops->cpo_flush)(env, slice, io);
> @@ -883,8 +852,6 @@ void cl_page_clip(const struct lu_env *env, struct cl_page *pg,
>  {
>  	const struct cl_page_slice *slice;
>  
> -	PINVRNT(env, pg, cl_page_invariant(pg));
> -
>  	CL_PAGE_HEADER(D_TRACE, env, pg, "%d %d\n", from, to);
>  
>  	list_for_each_entry(slice, &pg->cp_layers, cpl_linkage) {
> 
> 
> 
