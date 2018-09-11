From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Sep 2018 02:01:37 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/34] lnet: add cpt to lnet_match_info.
In-Reply-To: <153628137155.8267.2566576537174390617.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137155.8267.2566576537174390617.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809110155500.29662@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This seems to be a more direct way to get the cpt
> needed in lnet_mt_of_match().

Talking to Doug a better comment would be:

This allows LNet to handle a change to a different CPT if the peer
changes. The NID we are sending to can change based on multirail
behavior.
 
I CC Olaf as well for his comment. Code wise its good.

Reviewed-by: James Simmons <jsimmons@infradead.org>

The below needs fixing based on response to cover letter.

> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    1 +
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    1 +
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    2 +-
>  3 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 255c6c4bbb89..2d2c066a11ba 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -511,6 +511,7 @@ enum lnet_match_flags {
>  struct lnet_match_info {
>  	__u64			mi_mbits;
>  	struct lnet_process_id	mi_id;
> +	unsigned int		mi_cpt;
>  	unsigned int		mi_opc;
>  	unsigned int		mi_portal;
>  	unsigned int		mi_rlength;
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index b8b15f56a275..b6e81a693fc3 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1303,6 +1303,7 @@ lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
>  	info.mi_rlength	= hdr->payload_length;
>  	info.mi_roffset	= hdr->msg.put.offset;
>  	info.mi_mbits	= hdr->msg.put.match_bits;
> +	info.mi_cpt	= msg->msg_rxpeer->lp_cpt;
>  
>  	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
>  	ready_delay = msg->msg_rx_ready_delay;
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index 4c5737083422..90ce51801726 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -292,7 +292,7 @@ lnet_mt_of_match(struct lnet_match_info *info, struct lnet_msg *msg)
>  
>  	rotor = ptl->ptl_rotor++; /* get round-robin factor */
>  	if (portal_rotor == LNET_PTL_ROTOR_HASH_RT && routed)
> -		cpt = lnet_cpt_of_nid(msg->msg_hdr.src_nid);
> +		cpt = info->mi_cpt;
>  	else
>  		cpt = rotor % LNET_CPT_NUMBER;
>  
> 
> 
> 
