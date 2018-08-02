From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 03:57:15 +0100 (BST)
Subject: [lustre-devel] [PATCH 06/22] Revert "staging: lustre:
 osc_cache: Use list_for_each_entry_safe"
In-Reply-To: <153292186084.13840.7272276537169852360.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186084.13840.7272276537169852360.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020357040.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This reverts commit 4a81ce53a61c72afb079c096599a5d34749b9dd7.
> 
> These loops really want to remove everything, and using a
>   while(!list_empty())
> loop makes this more obvious.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/osc/osc_cache.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 15a48173e148..87d0d16d942b 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -2060,7 +2060,6 @@ static unsigned int get_write_extents(struct osc_object *obj,
>  {
>  	struct client_obd *cli = osc_cli(obj);
>  	struct osc_extent *ext;
> -	struct osc_extent *temp;
>  	struct extent_rpc_data data = {
>  		.erd_rpc_list = rpclist,
>  		.erd_page_count = 0,
> @@ -2070,7 +2069,9 @@ static unsigned int get_write_extents(struct osc_object *obj,
>  	};
>  
>  	LASSERT(osc_object_is_locked(obj));
> -	list_for_each_entry_safe(ext, temp, &obj->oo_hp_exts, oe_link) {
> +	while (!list_empty(&obj->oo_hp_exts)) {
> +		ext = list_entry(obj->oo_hp_exts.next, struct osc_extent,
> +				 oe_link);
>  		LASSERT(ext->oe_state == OES_CACHE);
>  		if (!try_to_add_extent_for_io(cli, ext, &data))
>  			return data.erd_page_count;
> @@ -2829,7 +2830,6 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
>  {
>  	struct client_obd *cli = osc_cli(obj);
>  	struct osc_extent *ext;
> -	struct osc_extent *temp;
>  	struct osc_extent *waiting = NULL;
>  	pgoff_t index;
>  	LIST_HEAD(list);
> @@ -2888,9 +2888,10 @@ int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
>  
>  	osc_list_maint(cli, obj);
>  
> -	list_for_each_entry_safe(ext, temp, &list, oe_link) {
> +	while (!list_empty(&list)) {
>  		int rc;
>  
> +		ext = list_entry(list.next, struct osc_extent, oe_link);
>  		list_del_init(&ext->oe_link);
>  
>  		/* extent may be in OES_ACTIVE state because inode mutex
> 
> 
> 
