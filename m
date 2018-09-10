From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Sep 2018 00:29:31 +0100 (BST)
Subject: [lustre-devel] [PATCH 06/34] lnet: store separate xmit/recv
 net-interface in each message.
In-Reply-To: <153628137147.8267.3706504130592682241.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137147.8267.3706504130592682241.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809110027540.29662@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Currently we store the net-interface in the peer, but the
> peer should identify just the network, not the particular interface.
> To help track which actual interface is used for each
> message, store them explicitly.

Reviewed-by: James Simmons <jsimmons@infradead.org>

The below needs fixing based on response to cover letter. With a combo
patch the following works well.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18274
Reviewed-on: http://review.whamcloud.com/20729
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: NeilBrown <neilb@suse.com>
 
> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
> 
> and includes commit 63c3e5129873 ("LU-7734 lnet: Fix lnet_msg_free()")
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    3 +++
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |   21 ++++++++++++++++++--
>  2 files changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 5f0d4703bf86..16a493529a46 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -98,6 +98,9 @@ struct lnet_msg {
>  
>  	void			*msg_private;
>  	struct lnet_libmd	*msg_md;
> +	/* the NI the message was sent or received over */
> +	struct lnet_ni       *msg_txni;
> +	struct lnet_ni       *msg_rxni;
>  
>  	unsigned int		 msg_len;
>  	unsigned int		 msg_wanted;
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 1c874025fa74..b2a52ddcefcb 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -782,6 +782,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  {
>  	struct lnet_peer *txpeer = msg->msg_txpeer;
>  	struct lnet_msg *msg2;
> +	struct lnet_ni	*txni = msg->msg_txni;
>  
>  	if (msg->msg_txcredit) {
>  		struct lnet_ni *ni = txpeer->lp_ni;
> @@ -829,6 +830,11 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  		}
>  	}
>  
> +	if (txni != NULL) {
> +		msg->msg_txni = NULL;
> +		lnet_ni_decref_locked(txni, msg->msg_tx_cpt);
> +	}
> +
>  	if (txpeer) {
>  		msg->msg_txpeer = NULL;
>  		lnet_peer_decref_locked(txpeer);
> @@ -876,6 +882,7 @@ void
>  lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  {
>  	struct lnet_peer *rxpeer = msg->msg_rxpeer;
> +	struct lnet_ni	*rxni = msg->msg_rxni;
>  	struct lnet_msg *msg2;
>  
>  	if (msg->msg_rtrcredit) {
> @@ -951,6 +958,10 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  			(void)lnet_post_routed_recv_locked(msg2, 1);
>  		}
>  	}
> +	if (rxni != NULL) {
> +		msg->msg_rxni = NULL;
> +		lnet_ni_decref_locked(rxni, msg->msg_rx_cpt);
> +	}
>  	if (rxpeer) {
>  		msg->msg_rxpeer = NULL;
>  		lnet_peer_decref_locked(rxpeer);
> @@ -1218,9 +1229,12 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  
>  	LASSERT(!msg->msg_peertxcredit);
>  	LASSERT(!msg->msg_txcredit);
> -	LASSERT(!msg->msg_txpeer);
> +	LASSERT(msg->msg_txpeer == NULL);
>  
> -	msg->msg_txpeer = lp;		   /* msg takes my ref on lp */
> +	msg->msg_txpeer = lp;                   /* msg takes my ref on lp */
> +	/* set the NI for this message */
> +	msg->msg_txni = src_ni;
> +	lnet_ni_addref_locked(msg->msg_txni, cpt);
>  
>  	rc = lnet_post_send_locked(msg, 0);
>  	lnet_net_unlock(cpt);
> @@ -1818,6 +1832,8 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
>  			return 0;
>  		goto drop;
>  	}
> +	msg->msg_rxni = ni;
> +	lnet_ni_addref_locked(ni, cpt);
>  
>  	if (lnet_isrouter(msg->msg_rxpeer)) {
>  		lnet_peer_set_alive(msg->msg_rxpeer);
> @@ -1934,6 +1950,7 @@ lnet_recv_delayed_msg_list(struct list_head *head)
>  		LASSERT(msg->msg_rx_delayed);
>  		LASSERT(msg->msg_md);
>  		LASSERT(msg->msg_rxpeer);
> +		LASSERT(msg->msg_rxni);
>  		LASSERT(msg->msg_hdr.type == LNET_MSG_PUT);
>  
>  		CDEBUG(D_NET, "Resuming delayed PUT from %s portal %d match %llu offset %d length %d.\n",
> 
> 
> 
