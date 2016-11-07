From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 02:01:11 +0000 (GMT)
Subject: [lustre-devel] [PATCH v2] staging: lustre: fixed shadowed
 variable in socklnd_cb.c
In-Reply-To: <1478213386-13853-1-git-send-email-andrew.kanner@gmail.com>
References: <1478213386-13853-1-git-send-email-andrew.kanner@gmail.com>
Message-ID: <alpine.LFD.2.20.1611070200570.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Kanner <andrew.kanner@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, bevans@cray.com, bhaktipriya96@gmail.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


> Removed redundant declaration of variable 'tx' in local scope
> Fixed: sparse warning:
> socklnd_cb.c:2476:41: warning: symbol 'tx' shadows an earlier one
> socklnd_cb.c:2435:25: originally declared here

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Andrew Kanner <andrew.kanner@gmail.com>
> ---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index c1c6f60..f31f4a1 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -2473,8 +2473,8 @@ ksocknal_check_peer_timeouts(int idx)
>  		 * holding only shared lock
>  		 */
>  		if (!list_empty(&peer->ksnp_tx_queue)) {
> -			struct ksock_tx *tx = list_entry(peer->ksnp_tx_queue.next,
> -						    struct ksock_tx, tx_list);
> +			tx = list_entry(peer->ksnp_tx_queue.next,
> +					struct ksock_tx, tx_list);
>  
>  			if (cfs_time_aftereq(cfs_time_current(),
>  					     tx->tx_deadline)) {
> -- 
> 2.1.4
> 
> 
