From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:07:23 +0000
Subject: [lustre-devel] [PATCH 09/29] lustre: osc: remove test on
 'found' being an error.
In-Reply-To: <154701504152.26726.5389367058165286948.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504152.26726.5389367058165286948.stgit@noble>
Message-ID: <837BC658-D143-4706-91E4-93F45DAFDA6B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> Found cannot be IS_ERR() at this point in the code, as it is only ever
> assigned a value from osc_extent_hold() (or NULL).
> 
> So discard the test.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c |    8 +++-----
> 1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 848e440ae2a9..e65d917336b9 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -821,11 +821,9 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
> 	osc_extent_tree_dump(D_CACHE, obj);
> 	if (found) {
> 		LASSERT(!conflict);
> -		if (!IS_ERR(found)) {
> -			LASSERT(found->oe_dlmlock == cur->oe_dlmlock);
> -			OSC_EXTENT_DUMP(D_CACHE, found,
> -					"found caching ext for %lu.\n", index);
> -		}
> +		LASSERT(found->oe_dlmlock == cur->oe_dlmlock);
> +		OSC_EXTENT_DUMP(D_CACHE, found,
> +				"found caching ext for %lu.\n", index);
> 	} else if (!conflict) {
> 		/* create a new extent */
> 		EASSERT(osc_extent_is_overlapped(obj, cur) == 0, cur);
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
