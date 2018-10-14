From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 20:34:36 +0100 (BST)
Subject: [lustre-devel] [PATCH 05/24] lustre: lnet: add Multi-Rail and
 Discovery ping feature bits
In-Reply-To: <153895437774.16383.2810116639916310757.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437774.16383.2810116639916310757.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142034130.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Claim ping features bit for Multi-Rail and Discovery.
> 
> Assert in lnet_ping_target_update() that no unknown bits will
> be send over the wire.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25775
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   16 ++++++++++++++++
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    5 +++++
>  2 files changed, 21 insertions(+)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index d1d17ededd06..f4467a3bbfd1 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -386,6 +386,22 @@ struct lnet_ni {
>  #define LNET_PING_FEAT_BASE		BIT(0)	/* just a ping */
>  #define LNET_PING_FEAT_NI_STATUS	BIT(1)	/* return NI status */
>  #define LNET_PING_FEAT_RTE_DISABLED	BIT(2)	/* Routing enabled */
> +#define LNET_PING_FEAT_MULTI_RAIL	BIT(3)	/* Multi-Rail aware */
> +#define LNET_PING_FEAT_DISCOVERY	BIT(4)	/* Supports Discovery */
> +
> +/*
> + * All ping feature bits fit to hit the wire.
> + * In lnet_assert_wire_constants() this is compared against its open-coded
> + * value, and in lnet_ping_target_update() it is used to verify that no
> + * unknown bits have been set.
> + * New feature bits can be added, just be aware that this does change the
> + * over-the-wire protocol.
> + */
> +#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE | \
> +					 LNET_PING_FEAT_NI_STATUS | \
> +					 LNET_PING_FEAT_RTE_DISABLED | \
> +					 LNET_PING_FEAT_MULTI_RAIL | \
> +					 LNET_PING_FEAT_DISCOVERY)
>  
>  #define LNET_PING_INFO_SIZE(NNIDS) \
>  	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index ca28ad75fe2b..68af723bc6a1 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -1170,6 +1170,11 @@ lnet_ping_target_update(struct lnet_ping_buffer *pbuf,
>  
>  	if (!the_lnet.ln_routing)
>  		pbuf->pb_info.pi_features |= LNET_PING_FEAT_RTE_DISABLED;
> +
> +	/* Ensure only known feature bits have been set. */
> +	LASSERT(pbuf->pb_info.pi_features & LNET_PING_FEAT_BITS);
> +	LASSERT(!(pbuf->pb_info.pi_features & ~LNET_PING_FEAT_BITS));
> +
>  	lnet_ping_target_install_locked(pbuf);
>  
>  	if (the_lnet.ln_ping_target) {
> 
> 
> 
