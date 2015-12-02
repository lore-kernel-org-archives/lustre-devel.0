From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 10:54:10 +0300
Subject: [lustre-devel] [PATCH 03/40] staging: lustre: reflect down
 routes in /proc/sys/lnet/routes
In-Reply-To: <1448062576-23757-4-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-4-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202075410.GJ18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 20, 2015 at 06:35:39PM -0500, James Simmons wrote:
> From: Chris Horn <hornc@cray.com>
> 
> We consider routes "down" if the router is down or the router
> NI for the target network is down. This should be reflected
> in the output of /proc/sys/lnet/routes
> 
> Signed-off-by: Chris Horn <hornc@cray.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3679
> Reviewed-on: http://review.whamcloud.com/7857
> Reviewed-by: Cory Spitz <spitzcor@cray.com>
> Reviewed-by: Isaac Huang <he.huang@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   13 ++++++++
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |   32 ++++++++++----------
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
>  3 files changed, 30 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index b61d504..09c6bfe 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -64,6 +64,19 @@ extern lnet_t	the_lnet;	/* THE network */
>  /** exclusive lock */
>  #define LNET_LOCK_EX		CFS_PERCPT_LOCK_EX
>  
> +static inline int lnet_is_route_alive(lnet_route_t *route)
> +{
> +	/* gateway is down */
> +	if (!route->lr_gateway->lp_alive)
> +		return 0;
> +	/* no NI status, assume it's alive */
> +	if ((route->lr_gateway->lp_ping_feats &
> +	     LNET_PING_FEAT_NI_STATUS) == 0)
> +		return 1;
> +	/* has NI status, check # down NIs */
> +	return route->lr_downis == 0;
> +}
> +
>  static inline int lnet_is_wire_handle_none(lnet_handle_wire_t *wh)
>  {
>  	return (wh->wh_interface_cookie == LNET_WIRE_HANDLE_COOKIE_NONE &&
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 7a68382..c56de44 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1122,9 +1122,9 @@ static lnet_peer_t *
>  lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
>  {
>  	lnet_remotenet_t *rnet;
> -	lnet_route_t *rtr;
> -	lnet_route_t *rtr_best;
> -	lnet_route_t *rtr_last;
> +	lnet_route_t *route;
> +	lnet_route_t *best_route;
> +	lnet_route_t *last_route;

Unrelated variable renaming.

>  	struct lnet_peer *lp_best;
>  	struct lnet_peer *lp;
>  	int rc;
> @@ -1137,13 +1137,12 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
>  		return NULL;
>  
>  	lp_best = NULL;
> -	rtr_best = rtr_last = NULL;
> -	list_for_each_entry(rtr, &rnet->lrn_routes, lr_list) {
> -		lp = rtr->lr_gateway;
> +	best_route = NULL;
> +	last_route = NULL;

Unrelated checkpatch fixes.

> +	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
> +		lp = route->lr_gateway;
>  
> -		if (!lp->lp_alive || /* gateway is down */
> -		    ((lp->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) != 0 &&
> -		     rtr->lr_downis != 0)) /* NI to target is down */
> +		if (!lnet_is_route_alive(route))

This section is related to the patch, we moved the check out into its
own function.

>  			continue;
>  
>  		if (ni != NULL && lp->lp_ni != ni)
> @@ -1153,28 +1152,29 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
>  			return lp;
>  
>  		if (lp_best == NULL) {
> -			rtr_best = rtr_last = rtr;
> +			best_route = route;
> +			last_route = route;

More unrelated checkpatch fixes.

>  			lp_best = lp;
>  			continue;
>  		}
>  
>  		/* no protection on below fields, but it's harmless */
> -		if (rtr_last->lr_seq - rtr->lr_seq < 0)
> -			rtr_last = rtr;
> +		if (last_route->lr_seq - route->lr_seq < 0)
> +			last_route = route;
>  
> -		rc = lnet_compare_routes(rtr, rtr_best);
> +		rc = lnet_compare_routes(route, best_route);
>  		if (rc < 0)
>  			continue;
>  
> -		rtr_best = rtr;
> +		best_route = route;
>  		lp_best = lp;
>  	}
>  
>  	/* set sequence number on the best router to the latest sequence + 1
>  	 * so we can round-robin all routers, it's race and inaccurate but
>  	 * harmless and functional  */
> -	if (rtr_best != NULL)
> -		rtr_best->lr_seq = rtr_last->lr_seq + 1;
> +	if (best_route)

More checkpatch fixes.

> +		best_route->lr_seq = last_route->lr_seq + 1;
>  	return lp_best;
>  }
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 396c7c4..af7423f 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -240,7 +240,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
>  			unsigned int hops = route->lr_hops;
>  			unsigned int priority = route->lr_priority;
>  			lnet_nid_t nid = route->lr_gateway->lp_nid;
> -			int alive = route->lr_gateway->lp_alive;
> +			int alive = lnet_is_route_alive(route);

This line is the bugfix.

I know that people hate breaking patches up into reviewable patches but
this is a one line fix which is hidden behind 30 lines of unrelated
changes.  It makes it very hard to follow what is going on.

I have scripts to review checkpatch fixes basically automatically so it
really really helps me when people do one thing per patch.

regards,
dan carpenter
