From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 20:32:51 +0100 (BST)
Subject: [lustre-devel] [PATCH 04/24] lustre: lnet: automatic sizing of
 router pinger buffers
In-Reply-To: <153895437770.16383.3391026679795909640.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437770.16383.3391026679795909640.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142032320.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> The router pinger uses fixed-size buffers to receive the data
> returned by a ping. When a router has more than 16 interfaces
> (including loopback) this means the data for some interfaces
> is dropped.
> 
> Detect this situation, and track the number of remote NIs in
> the lnet_rc_data_t structure.  lnet_create_rc_data_locked()
> becomes lnet_update_rc_data_locked(), and modified to replace
> an existing ping buffer if one is present. It is now also
> called by lnet_ping_router_locked() when the existing ping
> buffer is too small.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25774
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    4 -
>  drivers/staging/lustre/lnet/lnet/router.c          |   90 +++++++++++++-------
>  2 files changed, 60 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index ab8c6d66cdbf..d1d17ededd06 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -411,8 +411,6 @@ struct lnet_ping_buffer {
>  
>  
>  /* router checker data, per router */
> -#define LNET_MAX_RTR_NIS   LNET_INTERFACES_MIN
> -#define LNET_RTR_PINGINFO_SIZE	LNET_PING_INFO_SIZE(LNET_MAX_RTR_NIS)
>  struct lnet_rc_data {
>  	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
>  	struct list_head	rcd_list;
> @@ -422,6 +420,8 @@ struct lnet_rc_data {
>  	struct lnet_peer_ni	*rcd_gateway;
>  	/* ping buffer */
>  	struct lnet_ping_buffer	*rcd_pingbuffer;
> +	/* desired size of buffer */
> +	int			rcd_nnis;
>  };
>  
>  struct lnet_peer_ni {
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index e97957ce9252..86cce27e10d8 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -678,8 +678,11 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
>  
>  	/* Determine the number of NIs for which there is data. */
>  	nnis = pbuf->pb_info.pi_nnis;
> -	if (pbuf->pb_nnis < nnis)
> +	if (pbuf->pb_nnis < nnis) {
> +		if (rcd->rcd_nnis < nnis)
> +			rcd->rcd_nnis = nnis;
>  		nnis = pbuf->pb_nnis;
> +	}
>  
>  	list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
>  		int down = 0;
> @@ -911,28 +914,47 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
>  }
>  
>  static struct lnet_rc_data *
> -lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
> +lnet_update_rc_data_locked(struct lnet_peer_ni *gateway)
>  {
> -	struct lnet_rc_data *rcd = NULL;
> -	struct lnet_ping_buffer *pbuf;
> +	struct lnet_handle_md mdh;
> +	struct lnet_rc_data *rcd;
> +	struct lnet_ping_buffer *pbuf = NULL;
>  	struct lnet_md md;
> +	int nnis = LNET_INTERFACES_MIN;
>  	int rc;
>  	int i;
>  
> +	rcd = gateway->lpni_rcd;
> +	if (rcd) {
> +		nnis = rcd->rcd_nnis;
> +		mdh = rcd->rcd_mdh;
> +		LNetInvalidateMDHandle(&rcd->rcd_mdh);
> +		pbuf = rcd->rcd_pingbuffer;
> +		rcd->rcd_pingbuffer = NULL;
> +	} else {
> +		LNetInvalidateMDHandle(&mdh);
> +	}
> +
>  	lnet_net_unlock(gateway->lpni_cpt);
>  
> -	rcd = kzalloc(sizeof(*rcd), GFP_NOFS);
> -	if (!rcd)
> -		goto out;
> +	if (rcd) {
> +		LNetMDUnlink(mdh);
> +		lnet_ping_buffer_decref(pbuf);
> +	} else {
> +		rcd = kzalloc(sizeof(*rcd), GFP_NOFS);
> +		if (!rcd)
> +			goto out;
>  
> -	LNetInvalidateMDHandle(&rcd->rcd_mdh);
> -	INIT_LIST_HEAD(&rcd->rcd_list);
> +		LNetInvalidateMDHandle(&rcd->rcd_mdh);
> +		INIT_LIST_HEAD(&rcd->rcd_list);
> +		rcd->rcd_nnis = nnis;
> +	}
>  
> -	pbuf = lnet_ping_buffer_alloc(LNET_MAX_RTR_NIS, GFP_NOFS);
> +	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
>  	if (!pbuf)
>  		goto out;
>  
> -	for (i = 0; i < LNET_MAX_RTR_NIS; i++) {
> +	for (i = 0; i < nnis; i++) {
>  		pbuf->pb_info.pi_ni[i].ns_nid = LNET_NID_ANY;
>  		pbuf->pb_info.pi_ni[i].ns_status = LNET_NI_STATUS_INVALID;
>  	}
> @@ -940,7 +962,7 @@ lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
>  
>  	md.start = &pbuf->pb_info;
>  	md.user_ptr = rcd;
> -	md.length = LNET_RTR_PINGINFO_SIZE;
> +	md.length = LNET_PING_INFO_SIZE(nnis);
>  	md.threshold = LNET_MD_THRESH_INF;
>  	md.options = LNET_MD_TRUNCATE;
>  	md.eq_handle = the_lnet.ln_rc_eqh;
> @@ -949,33 +971,37 @@ lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
>  	rc = LNetMDBind(md, LNET_UNLINK, &rcd->rcd_mdh);
>  	if (rc < 0) {
>  		CERROR("Can't bind MD: %d\n", rc);
> -		goto out;
> +		goto out_ping_buffer_decref;
>  	}
>  	LASSERT(!rc);
>  
>  	lnet_net_lock(gateway->lpni_cpt);
> -	/* router table changed or someone has created rcd for this gateway */
> -	if (!lnet_isrouter(gateway) || gateway->lpni_rcd) {
> -		lnet_net_unlock(gateway->lpni_cpt);
> -		goto out;
> +	/* Check if this is still a router. */
> +	if (!lnet_isrouter(gateway))
> +		goto out_unlock;
> +	/* Check if someone else installed router data. */
> +	if (gateway->lpni_rcd && gateway->lpni_rcd != rcd)
> +		goto out_unlock;
> +
> +	/* Install and/or update the router data. */
> +	if (!gateway->lpni_rcd) {
> +		lnet_peer_ni_addref_locked(gateway);
> +		rcd->rcd_gateway = gateway;
> +		gateway->lpni_rcd = rcd;
>  	}
> -
> -	lnet_peer_ni_addref_locked(gateway);
> -	rcd->rcd_gateway = gateway;
> -	gateway->lpni_rcd = rcd;
>  	gateway->lpni_ping_notsent = 0;
>  
>  	return rcd;
>  
> - out:
> -	if (rcd) {
> -		if (!LNetMDHandleIsInvalid(rcd->rcd_mdh)) {
> -			rc = LNetMDUnlink(rcd->rcd_mdh);
> -			LASSERT(!rc);
> -		}
> +out_unlock:
> +	lnet_net_unlock(gateway->lpni_cpt);
> +	rc = LNetMDUnlink(mdh);
> +	LASSERT(!rc);
> +out_ping_buffer_decref:
> +	lnet_ping_buffer_decref(pbuf);
> +out:
> +	if (rcd && rcd != gateway->lpni_rcd)
>  		lnet_destroy_rc_data(rcd);
> -	}
> -
>  	lnet_net_lock(gateway->lpni_cpt);
>  	return gateway->lpni_rcd;
>  }
> @@ -1018,9 +1044,9 @@ lnet_ping_router_locked(struct lnet_peer_ni *rtr)
>  		return;
>  	}
>  
> -	rcd = rtr->lpni_rcd ?
> -	      rtr->lpni_rcd : lnet_create_rc_data_locked(rtr);
> -
> +	rcd = rtr->lpni_rcd;
> +	if (!rcd || rcd->rcd_nnis > rcd->rcd_pingbuffer->pb_nnis)
> +		rcd = lnet_update_rc_data_locked(rtr);
>  	if (!rcd)
>  		return;
>  
> 
> 
> 
