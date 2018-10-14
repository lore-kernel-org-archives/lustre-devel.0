From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 20:55:18 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/24] lustre: lnet: rename
 lnet_add/del_peer_ni_to/from_peer()
In-Reply-To: <153895437785.16383.10650578259435328953.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437785.16383.10650578259435328953.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142054550.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Rename lnet_add_peer_ni_to_peer() to lnet_add_peer_ni(), and
> lnet_del_peer_ni_from_peer() to lnet_del_peer_ni().  This brings
> the function names closer to the ioctls they implement:
> IOCTL_LIBCFS_ADD_PEER_NI and IOCTL_LIBCFS_DEL_PEER_NI. These
> names are also a more accturate description their effect: adding
> or deleting an lnet_peer_ni to LNet.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25778
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 ++--
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   10 +++++----
>  drivers/staging/lustre/lnet/lnet/peer.c            |   22 +++++++++++++++-----
>  3 files changed, 23 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index f15f5c9c9a25..69f45a76f1cc 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -682,8 +682,8 @@ struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
>  					       u32 net_id);
>  bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
>  				 struct lnet_ni *ni);
> -int lnet_add_peer_ni_to_peer(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
> -int lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid);
> +int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
> +int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
>  int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
>  		       bool *mr,
>  		       struct lnet_peer_ni_credit_info __user *peer_ni_info,
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index d81501f4c282..d64ae2939abc 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -2848,9 +2848,9 @@ LNetCtl(unsigned int cmd, void *arg)
>  			return -EINVAL;
>  
>  		mutex_lock(&the_lnet.ln_api_mutex);
> -		rc = lnet_add_peer_ni_to_peer(cfg->prcfg_prim_nid,
> -					      cfg->prcfg_cfg_nid,
> -					      cfg->prcfg_mr);
> +		rc = lnet_add_peer_ni(cfg->prcfg_prim_nid,
> +				      cfg->prcfg_cfg_nid,
> +				      cfg->prcfg_mr);
>  		mutex_unlock(&the_lnet.ln_api_mutex);
>  		return rc;
>  	}
> @@ -2862,8 +2862,8 @@ LNetCtl(unsigned int cmd, void *arg)
>  			return -EINVAL;
>  
>  		mutex_lock(&the_lnet.ln_api_mutex);
> -		rc = lnet_del_peer_ni_from_peer(cfg->prcfg_prim_nid,
> -						cfg->prcfg_cfg_nid);
> +		rc = lnet_del_peer_ni(cfg->prcfg_prim_nid,
> +				      cfg->prcfg_cfg_nid);
>  		mutex_unlock(&the_lnet.ln_api_mutex);
>  		return rc;
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index ebb84356302f..bbf07008dbb0 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -891,14 +891,16 @@ lnet_peer_ni_add_non_mr(lnet_nid_t nid)
>  }
>  
>  /*
> + * Implementation of IOC_LIBCFS_ADD_PEER_NI.
> + *
>   * This API handles the following combinations:
> - *	Create a primary NI if only the prim_nid is provided
> - *	Create or add an lpni to a primary NI. Primary NI must've already
> - *	been created
> - *	Create a non-MR peer.
> + *   Create a primary NI if only the prim_nid is provided
> + *   Create or add an lpni to a primary NI. Primary NI must've already
> + *   been created
> + *   Create a non-MR peer.
>   */
>  int
> -lnet_add_peer_ni_to_peer(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
> +lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
>  {
>  	/*
>  	 * Caller trying to setup an MR like peer hierarchy but
> @@ -929,8 +931,16 @@ lnet_add_peer_ni_to_peer(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
>  	return 0;
>  }
>  
> +/*
> + * Implementation of IOC_LIBCFS_DEL_PEER_NI.
> + *
> + * This API handles the following combinations:
> + *   Delete a NI from a peer if both prim_nid and nid are provided.
> + *   Delete a peer if only prim_nid is provided.
> + *   Delete a peer if its primary nid is provided.
> + */
>  int
> -lnet_del_peer_ni_from_peer(lnet_nid_t prim_nid, lnet_nid_t nid)
> +lnet_del_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid)
>  {
>  	lnet_nid_t local_nid;
>  	struct lnet_peer *peer;
> 
> 
> 
