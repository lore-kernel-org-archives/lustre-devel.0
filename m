From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:12:27 +0000
Subject: [lustre-devel] [PATCH 27/29] lustre: osc_cache: white-space and
 other checkpatch fixes.
In-Reply-To: <154701504274.26726.6932313520085605572.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504274.26726.6932313520085605572.stgit@noble>
Message-ID: <058406C4-B01E-4DD5-8EBB-3014A23CA963@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> Assorted minor checkpatch issues fixed.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c |   25 +++++++++++++------------
> 1 file changed, 13 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index e01f3815978c..019854b78277 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -962,7 +962,6 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
> 
> 		wait_event_idle(ext->oe_waitq,
> 				smp_load_acquire(&ext->oe_state) == state);
> -
> 	}
> 	return ext->oe_rc < 0 ? ext->oe_rc : 0;
> }

Typically we prefer a blank line before return.  Otherwise fine.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> @@ -1020,7 +1019,8 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
> 		if (index < trunc_index ||
> 		    (index == trunc_index && partial)) {
> 			/* accounting how many pages remaining in the chunk
> -			 * so that we can calculate grants correctly. */
> +			 * so that we can calculate grants correctly.
> +			 */
> 			if (index >> ppc_bits == trunc_chunk)
> 				++pages_in_chunk;
> 			continue;
> @@ -1141,7 +1141,8 @@ static int osc_extent_make_ready(const struct lu_env *env,
> 	 * the size of file.
> 	 */
> 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
> -		int last_oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
> +		int last_oap_count = osc_refresh_count(env, last,
> +						       OBD_BRW_WRITE);
> 
> 		LASSERT(last_oap_count > 0);
> 		LASSERT(last->oap_page_off + last_oap_count <= PAGE_SIZE);
> @@ -1337,7 +1338,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
> 			  int cmd, int rc)
> {
> 	struct osc_page *opg = oap2osc_page(oap);
> -	struct cl_page    *page = oap2cl_page(oap);
> +	struct cl_page *page = oap2cl_page(oap);
> 	enum cl_req_type crt;
> 	int srvlock;
> 
> @@ -1736,7 +1737,8 @@ static void osc_update_pending(struct osc_object *obj, int cmd, int delta)
> 	OSC_IO_DEBUG(obj, "update pending cmd %d delta %d.\n", cmd, delta);
> }
> 
> -static void on_list(struct list_head *item, struct list_head *list, int should_be_on)
> +static void on_list(struct list_head *item, struct list_head *list,
> +		    int should_be_on)
> {
> 	if (list_empty(item) && should_be_on)
> 		list_add_tail(item, list);
> @@ -1898,7 +1900,8 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
> 					oap_pending_item);
> 		EASSERT(tmp->oe_owner == current, tmp);
> 		if (oap2cl_page(oap)->cp_type != oap2cl_page(oap2)->cp_type) {
> -			CDEBUG(D_CACHE, "Do not permit different type of IO in one RPC\n");
> +			CDEBUG(D_CACHE,
> +			       "Do not permit different type of IO in one RPC\n");
> 			return 0;
> 		}
> 
> @@ -2130,10 +2133,8 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
> 
> 	osc_object_unlock(osc);
> 	if (!list_empty(&rpclist)) {
> -
> 		rc = osc_build_rpc(env, cli, &rpclist, OBD_BRW_READ);
> 		LASSERT(list_empty(&rpclist));
> -
> 	}
> 	return rc;
> }
> @@ -3082,7 +3083,7 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
>  * Check if page @page is covered by an extra lock or discard it.
>  */
> static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
> -				struct osc_page *ops, void *cbdata)
> +				 struct osc_page *ops, void *cbdata)
> {
> 	struct osc_thread_info *info = osc_env_info(env);
> 	struct osc_object *osc = cbdata;
> @@ -3121,7 +3122,7 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
> }
> 
> static bool discard_cb(const struct lu_env *env, struct cl_io *io,
> -		      struct osc_page *ops, void *cbdata)
> +		       struct osc_page *ops, void *cbdata)
> {
> 	struct osc_thread_info *info = osc_env_info(env);
> 	struct cl_page *page = ops->ops_cl.cpl_page;
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
