From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:04:00 +0000
Subject: [lustre-devel] [PATCH 07/29] lustre: osc: convert a while loop
 to for
In-Reply-To: <154701504139.26726.16752476949923033869.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504139.26726.16752476949923033869.stgit@noble>
Message-ID: <C644180F-BF38-4FEE-B545-8DBC795138E7@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> This loop uses 'continue' in several places,
> and each one is proceeded by
>   ext = next_extent(ext)
> which also appears at the end.
> This is exactly the pattern that a 'for' loop
> simplifies.  So change to a for loop.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Much nicer and less error prone,

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c |   21 +++++----------------
> 1 file changed, 5 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index dd3c87124aa5..eb8de1503386 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -737,7 +737,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
> 	ext = osc_extent_search(obj, cur->oe_start);
> 	if (!ext)
> 		ext = first_extent(obj);
> -	while (ext) {
> +	for (; ext; ext = next_extent(ext)) {
> 		pgoff_t ext_chk_start = ext->oe_start >> ppc_bits;
> 		pgoff_t ext_chk_end = ext->oe_end >> ppc_bits;
> 
> @@ -750,15 +750,12 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
> 			EASSERTF(!overlapped(ext, cur), ext,
> 				 EXTSTR "\n", EXTPARA(cur));
> 
> -			ext = next_extent(ext);
> 			continue;
> 		}
> 
> 		/* discontiguous chunks? */
> -		if (chunk + 1 < ext_chk_start) {
> -			ext = next_extent(ext);
> +		if (chunk + 1 < ext_chk_start)
> 			continue;
> -		}
> 
> 		/* ok, from now on, ext and cur have these attrs:
> 		 * 1. covered by the same lock
> @@ -786,33 +783,27 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
> 		}
> 
> 		/* non-overlapped extent */
> -		if (ext->oe_state != OES_CACHE || ext->oe_fsync_wait) {
> +		if (ext->oe_state != OES_CACHE || ext->oe_fsync_wait)
> 			/* we can't do anything for a non OES_CACHE extent, or
> 			 * if there is someone waiting for this extent to be
> 			 * flushed, try next one.
> 			 */
> -			ext = next_extent(ext);
> 			continue;
> -		}
> 
> 		/* check if they belong to the same rpc slot before trying to
> 		 * merge. the extents are not overlapped and contiguous at
> 		 * chunk level to get here.
> 		 */
> -		if (ext->oe_max_end != max_end) {
> +		if (ext->oe_max_end != max_end)
> 			/* if they don't belong to the same RPC slot or
> 			 * max_pages_per_rpc has ever changed, do not merge.
> 			 */
> -			ext = next_extent(ext);
> 			continue;
> -		}
> 
> 		/* check whether maximum extent size will be hit */
> 		if ((ext_chk_end - ext_chk_start + 1) << ppc_bits >
> -		    cli->cl_max_extent_pages) {
> -			ext = next_extent(ext);
> +		    cli->cl_max_extent_pages)
> 			continue;
> -		}
> 
> 		/* it's required that an extent must be contiguous at chunk
> 		 * level so that we know the whole extent is covered by grant
> @@ -851,8 +842,6 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
> 		}
> 		if (found)
> 			break;
> -
> -		ext = next_extent(ext);
> 	}
> 
> 	osc_extent_tree_dump(D_CACHE, obj);
> 
> 

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
