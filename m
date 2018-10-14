From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Oct 2018 00:54:06 +0100 (BST)
Subject: [lustre-devel] [PATCH 24/24] lustre: lnet: balance references
 in lnet_discover_peer_locked()
In-Reply-To: <153895437848.16383.5882317080014923551.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437848.16383.5882317080014923551.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810150053530.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: John L. Hammond <john.hammond@intel.com>
> 
> In lnet_discover_peer_locked() avoid a leaked reference to the peer in
> the non-blocking discovery case.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9913
> Signed-off-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-on: https://review.whamcloud.com/28695
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/peer.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 5f61fca09f44..db36b5cf31e1 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -2010,7 +2010,6 @@ lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block)
>  		if (lnet_peer_is_uptodate(lp))
>  			break;
>  		lnet_peer_queue_for_discovery(lp);
> -		lnet_peer_addref_locked(lp);
>  		/*
>  		 * if caller requested a non-blocking operation then
>  		 * return immediately. Once discovery is complete then the
> @@ -2019,6 +2018,8 @@ lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block)
>  		 */
>  		if (!block)
>  			break;
> +
> +		lnet_peer_addref_locked(lp);
>  		lnet_net_unlock(LNET_LOCK_EX);
>  		schedule();
>  		finish_wait(&lp->lp_dc_waitq, &wait);
> 
> 
> 
