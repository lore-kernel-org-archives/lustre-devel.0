From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 22 Mar 2016 21:49:16 -0400
Subject: [lustre-devel] [PATCH] Revert "Staging: lustre: o2iblnd: Use
 sizeof type *pointer instead of sizeof type."
In-Reply-To: <1458685264-22755-1-git-send-email-jsimmons@infradead.org>
References: <1458685264-22755-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160323014916.GF3190@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Mar 22, 2016 at 06:21:04PM -0400, James Simmons wrote:
> Latest testing fails when using ko2iblnd. It was tracked down
> to commit 4671a026616df26000f7d8ad2f2ea4b6de79263c.
> 
> This reverts commit 4671a026616df26000f7d8ad2f2ea4b6de79263c.
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 89f9390..0d32e65 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1968,7 +1968,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
>  	 */
>  
>  	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
> -					   sizeof(*net->ibn_fmr_ps));
> +					   sizeof(kib_fmr_poolset_t));

Ok, why is this revert needed?  Please give me a big huge comment about
why this is not the same size of the variable being assigned to it,
otherwise someone else is going to come along and make the exact same
change again.

>  	if (!net->ibn_fmr_ps) {
>  		CERROR("Failed to allocate FMR pool array\n");
>  		rc = -ENOMEM;
> @@ -1992,7 +1992,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
>  
>   create_tx_pool:
>  	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
> -					  sizeof(*net->ibn_tx_ps));
> +					  sizeof(kib_tx_poolset_t));

Same here, why is this code wrong?

thanks,

greg k-h
