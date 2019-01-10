From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:10:41 +0000
Subject: [lustre-devel] [PATCH 10/29] lustre: osc_cache: avoid
 list_for_each_entry_safe when clearing list.
In-Reply-To: <154701504159.26726.15747465883750837429.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504159.26726.15747465883750837429.stgit@noble>
Message-ID: <6B68F66C-5503-4ADA-8313-8625BC97F035@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> When removing some items from a list, list_for_each_entry_safe() is a
> good choice.
> When removing all items, it is clearer to use a while loop
> that repeatedly removes the first element, until there are
> none left.  This makes it obvious that the list ends up
> empty.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

I've never heard of list_first_entry_or_null() before?  Looks like
it was added in 3.10, but definitely seems useful.  There are a
bunch of places that iterate lists this way while deleteing entries
that could be similarly improved.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c |   22 +++++++++++++---------
> 1 file changed, 13 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index e65d917336b9..5cd3732101e7 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -869,7 +869,6 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
> {
> 	struct client_obd *cli = osc_cli(ext->oe_obj);
> 	struct osc_async_page *oap;
> -	struct osc_async_page *tmp;
> 	int nr_pages = ext->oe_nr_pages;
> 	int lost_grant = 0;
> 	int blocksize = cli->cl_import->imp_obd->obd_osfs.os_bsize ? : 4096;
> @@ -882,7 +881,9 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
> 	EASSERT(ergo(rc == 0, ext->oe_state == OES_RPC), ext);
> 
> 	osc_lru_add_batch(cli, &ext->oe_pages);
> -	list_for_each_entry_safe(oap, tmp, &ext->oe_pages, oap_pending_item) {
> +	while ((oap = list_first_entry_or_null(&ext->oe_pages,
> +					       struct osc_async_page,
> +					       oap_pending_item))) {
> 		list_del_init(&oap->oap_rpc_item);
> 		list_del_init(&oap->oap_pending_item);
> 		if (last_off <= oap->oap_obj_off) {
> @@ -1686,11 +1687,11 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
> /* caller must hold loi_list_lock */
> void osc_wake_cache_waiters(struct client_obd *cli)
> {
> -	struct list_head *l, *tmp;
> 	struct osc_cache_waiter *ocw;
> 
> -	list_for_each_safe(l, tmp, &cli->cl_cache_waiters) {
> -		ocw = list_entry(l, struct osc_cache_waiter, ocw_entry);
> +	while ((ocw = list_first_entry_or_null(&cli->cl_cache_waiters,
> +					       struct osc_cache_waiter,
> +					       ocw_entry))) {
> 		list_del_init(&ocw->ocw_entry);
> 
> 		ocw->ocw_rc = -EDQUOT;
> @@ -2739,7 +2740,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
> {
> 	struct client_obd *cli = osc_cli(obj);
> 	struct osc_extent *ext;
> -	struct osc_async_page *oap, *tmp;
> +	struct osc_async_page *oap;
> 	int page_count = 0;
> 	int mppr = cli->cl_max_pages_per_rpc;
> 	bool can_merge = true;
> @@ -2763,7 +2764,9 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
> 
> 	ext = osc_extent_alloc(obj);
> 	if (!ext) {
> -		list_for_each_entry_safe(oap, tmp, list, oap_pending_item) {
> +		while ((oap = list_first_entry_or_null(&oap->oap_pending_item,
> +						       struct osc_async_page,
> +						       oap_pending_item))) {
> 			list_del_init(&oap->oap_pending_item);
> 			osc_ap_completion(env, cli, oap, 0, -ENOMEM);
> 		}
> @@ -3093,11 +3096,12 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
> 
> 	LASSERT(ergo(!discard, list_empty(&discard_list)));
> 	if (!list_empty(&discard_list)) {
> -		struct osc_extent *tmp;
> 		int rc;
> 
> 		osc_list_maint(osc_cli(obj), obj);
> -		list_for_each_entry_safe(ext, tmp, &discard_list, oe_link) {
> +		while ((ext = list_first_entry_or_null(&discard_list,
> +						       struct osc_extent,
> +						       oe_link))) {
> 			list_del_init(&ext->oe_link);
> 			EASSERT(ext->oe_state == OES_LOCKING, ext);
> 
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
