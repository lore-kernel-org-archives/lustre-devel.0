From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 21:11:20 +0100 (BST)
Subject: [lustre-devel] [PATCH 11/24] lustre: lnet: introduce
 LNET_PEER_MULTI_RAIL flag bit
In-Reply-To: <153895437796.16383.5518559009775786439.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437796.16383.5518559009775786439.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142109440.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Add lp_state as a flag word to lnet_peer, and add lp_lock
> to protect it. This lock needs to be taken whenever the
> field is updated, because setting or clearing a bit is
> a read-modify-write cycle.
> 
> The lp_multi_rail is removed, its function is replaced by
> the new LNET_PEER_MULTI_RAIL flag bit.
> 
> The helper lnet_peer_is_multi_rail() tests the bit.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25781
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    6 +++++
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   11 ++++++++--
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    9 +++++---
>  drivers/staging/lustre/lnet/lnet/peer.c            |   22 +++++++++++++-------
>  4 files changed, 34 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index fc748ffa251d..75b47628c70e 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -757,4 +757,10 @@ lnet_peer_set_alive(struct lnet_peer_ni *lp)
>  		lnet_notify_locked(lp, 0, 1, lp->lpni_last_alive);
>  }
>  
> +static inline bool
> +lnet_peer_is_multi_rail(struct lnet_peer *lp)
> +{
> +	return lp->lp_state & LNET_PEER_MULTI_RAIL;
> +}
> +
>  #endif
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index f28fa5342914..602978a1c86e 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -467,6 +467,8 @@ struct lnet_peer_ni {
>  	atomic_t		 lpni_refcount;
>  	/* CPT this peer attached on */
>  	int			 lpni_cpt;
> +	/* state flags -- protected by lpni_lock */
> +	unsigned int		lpni_state;
>  	/* # refs from lnet_route::lr_gateway */
>  	int			 lpni_rtr_refcount;
>  	/* sequence number used to round robin over peer nis within a net */
> @@ -497,10 +499,15 @@ struct lnet_peer {
>  	/* primary NID of the peer */
>  	lnet_nid_t		lp_primary_nid;
>  
> -	/* peer is Multi-Rail enabled peer */
> -	bool			lp_multi_rail;
> +	/* lock protecting peer state flags */
> +	spinlock_t		lp_lock;
> +
> +	/* peer state flags */
> +	unsigned int		lp_state;
>  };
>  
> +#define LNET_PEER_MULTI_RAIL	BIT(0)
> +
>  struct lnet_peer_net {
>  	/* chain on peer block */
>  	struct list_head	lpn_on_peer_list;
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 59ae8d0649e5..0d0ad30bb164 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1281,7 +1281,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  		return -EHOSTUNREACH;
>  	}
>  
> -	if (!peer->lp_multi_rail && lnet_get_num_peer_nis(peer) > 1) {
> +	if (!lnet_peer_is_multi_rail(peer) &&
> +	    lnet_get_num_peer_nis(peer) > 1) {
>  		lnet_net_unlock(cpt);
>  		CERROR("peer %s is declared to be non MR capable, yet configured with more than one NID\n",
>  		       libcfs_nid2str(dst_nid));
> @@ -1307,7 +1308,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  
>  	if (msg->msg_type == LNET_MSG_REPLY ||
>  	    msg->msg_type == LNET_MSG_ACK ||
> -	    !peer->lp_multi_rail ||
> +	    !lnet_peer_is_multi_rail(peer) ||
>  	    best_ni) {
>  		/*
>  		 * for replies we want to respond on the same peer_ni we
> @@ -1354,7 +1355,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  				 * then use the best_gw found to send
>  				 * the message to
>  				 */
> -				if (!peer->lp_multi_rail)
> +				if (!lnet_peer_is_multi_rail(peer))
>  					best_lpni = best_gw;
>  				else
>  					best_lpni = NULL;
> @@ -1375,7 +1376,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	 * if the peer is not MR capable, then we should always send to it
>  	 * using the first NI in the NET we determined.
>  	 */
> -	if (!peer->lp_multi_rail) {
> +	if (!lnet_peer_is_multi_rail(peer)) {
>  		if (!best_lpni) {
>  			lnet_net_unlock(cpt);
>  			CERROR("no route to %s\n",
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 6b7ca5c361b8..cc2b926b76e4 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -182,6 +182,7 @@ lnet_peer_alloc(lnet_nid_t nid)
>  
>  	INIT_LIST_HEAD(&lp->lp_on_lnet_peer_list);
>  	INIT_LIST_HEAD(&lp->lp_peer_nets);
> +	spin_lock_init(&lp->lp_lock);
>  	lp->lp_primary_nid = nid;
>  
>  	/* TODO: update flags */
> @@ -798,13 +799,15 @@ lnet_peer_add(lnet_nid_t nid, bool mr)
>  	 *
>  	 * TODO: update flags if necessary
>  	 */
> -	if (mr && !lp->lp_multi_rail) {
> -		lp->lp_multi_rail = true;
> -	} else if (!mr && lp->lp_multi_rail) {
> +	spin_lock(&lp->lp_lock);
> +	if (mr && !(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
> +		lp->lp_state |= LNET_PEER_MULTI_RAIL;
> +	} else if (!mr && (lp->lp_state & LNET_PEER_MULTI_RAIL)) {
>  		/* The mr state is sticky. */
> -		CDEBUG(D_NET, "Cannot clear multi-flag from peer %s\n",
> +		CDEBUG(D_NET, "Cannot clear multi-rail flag from peer %s\n",
>  		       libcfs_nid2str(nid));
>  	}
> +	spin_unlock(&lp->lp_lock);
>  
>  	return 0;
>  }
> @@ -817,15 +820,18 @@ lnet_peer_add_nid(struct lnet_peer *lp, lnet_nid_t nid, bool mr)
>  	LASSERT(lp);
>  	LASSERT(nid != LNET_NID_ANY);
>  
> -	if (!mr && !lp->lp_multi_rail) {
> +	spin_lock(&lp->lp_lock);
> +	if (!mr && !(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
> +		spin_unlock(&lp->lp_lock);
>  		CERROR("Cannot add nid %s to non-multi-rail peer %s\n",
>  		       libcfs_nid2str(nid),
>  		       libcfs_nid2str(lp->lp_primary_nid));
>  		return -EPERM;
>  	}
>  
> -	if (!lp->lp_multi_rail)
> -		lp->lp_multi_rail = true;
> +	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL))
> +		lp->lp_state |= LNET_PEER_MULTI_RAIL;
> +	spin_unlock(&lp->lp_lock);
>  
>  	lpni = lnet_find_peer_ni_locked(nid);
>  	if (!lpni)
> @@ -1183,7 +1189,7 @@ int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
>  		return -ENOENT;
>  
>  	*primary_nid = lp->lp_primary_nid;
> -	*mr = lp->lp_multi_rail;
> +	*mr = lnet_peer_is_multi_rail(lp);
>  	*nid = lpni->lpni_nid;
>  	snprintf(ni_info.cr_aliveness, LNET_MAX_STR_LEN, "NA");
>  	if (lnet_isrouter(lpni) ||
> 
> 
> 
