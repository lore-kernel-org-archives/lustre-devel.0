From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Sep 2018 00:17:57 +0100 (BST)
Subject: [lustre-devel] [PATCH 01/34] struct lnet_ni - reformat comments.
In-Reply-To: <153628137125.8267.7825080417267355121.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137125.8267.7825080417267355121.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809110017220.29662@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This is part of
> 
> 8cbb8cd3e771e7f7e0f99cafc19fad32770dc015 LU-7734 lnet: Multi-Rail
> local NI split

Better commit message would be:

Rework the commonents in lib-types.h to limit the checkpatch
chatter of being over 80 characters.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18274
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: NeilBrown <neilb@suse.com>

> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   38 +++++++++++++++-----
>  1 file changed, 29 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 6d4106fd9039..078bc97a9ebf 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -263,18 +263,38 @@ struct lnet_ni {
>  	int			  ni_peerrtrcredits;
>  	/* seconds to consider peer dead */
>  	int			  ni_peertimeout;
> -	int			  ni_ncpts;	/* number of CPTs */
> -	__u32			 *ni_cpts;	/* bond NI on some CPTs */
> -	lnet_nid_t		  ni_nid;	/* interface's NID */
> -	void			 *ni_data;	/* instance-specific data */
> +	/* number of CPTs */
> +	int			ni_ncpts;
> +
> +	/* bond NI on some CPTs */
> +	__u32			*ni_cpts;
> +
> +	/* interface's NID */
> +	lnet_nid_t		ni_nid;
> +
> +	/* instance-specific data */
> +	void			*ni_data;
> +
>  	struct lnet_lnd		 *ni_lnd;	/* procedural interface */
> -	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
> -	int			**ni_refs;	/* percpt reference count */
> -	time64_t		  ni_last_alive;/* when I was last alive */
> -	struct lnet_ni_status	 *ni_status;	/* my health status */
> +
> +	/* percpt TX queues */
> +	struct lnet_tx_queue	**ni_tx_queues;
> +
> +	/* percpt reference count */
> +	int			**ni_refs;
> +
> +	/* when I was last alive */
> +	time64_t		ni_last_alive;
> +
> +	/* my health status */
> +	struct lnet_ni_status	*ni_status;
> +
>  	/* per NI LND tunables */
>  	struct lnet_ioctl_config_lnd_tunables *ni_lnd_tunables;
> -	/* equivalent interfaces to use */
> +	/*
> +	 * equivalent interfaces to use
> +	 * This is an array because socklnd bonding can still be configured
> +	 */
>  	char			 *ni_interfaces[LNET_MAX_INTERFACES];
>  	/* original net namespace */
>  	struct net		 *ni_net_ns;
> 
> 
> 
