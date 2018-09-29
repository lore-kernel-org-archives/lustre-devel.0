From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 23:47:33 +0100 (BST)
Subject: [lustre-devel] [PATCH 03/34] lnet: Change lpni_refcount to
 atomic_t
In-Reply-To: <153783763497.32103.13856612081166369948.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763497.32103.13856612081166369948.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809292347180.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This is part of
>     Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
> from upstream lustre, where it is marked:
>     Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>     WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
>     Reviewed-on: http://review.whamcloud.com/18293
>     Reviewed-by: Olaf Weber <olaf@sgi.com>
>     Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   10 +++++-----
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
>  drivers/staging/lustre/lnet/lnet/peer.c            |    8 ++++----
>  drivers/staging/lustre/lnet/lnet/router.c          |    4 ++--
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |    4 ++--
>  5 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index ef53638e20f6..88e010aa3f68 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -313,8 +313,8 @@ lnet_handle2me(struct lnet_handle_me *handle)
>  static inline void
>  lnet_peer_addref_locked(struct lnet_peer_ni *lp)
>  {
> -	LASSERT(lp->lpni_refcount > 0);
> -	lp->lpni_refcount++;
> +	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
> +	atomic_inc(&lp->lpni_refcount);
>  }
>  
>  void lnet_destroy_peer_locked(struct lnet_peer_ni *lp);
> @@ -322,9 +322,9 @@ void lnet_destroy_peer_locked(struct lnet_peer_ni *lp);
>  static inline void
>  lnet_peer_decref_locked(struct lnet_peer_ni *lp)
>  {
> -	LASSERT(lp->lpni_refcount > 0);
> -	lp->lpni_refcount--;
> -	if (!lp->lpni_refcount)
> +	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
> +	atomic_dec(&lp->lpni_refcount);
> +	if (atomic_read(&lp->lpni_refcount) == 0)
>  		lnet_destroy_peer_locked(lp);
>  }
>  
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 4b26801d7d29..9a2cf319dba9 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -429,7 +429,7 @@ struct lnet_peer_ni {
>  	/* peer's NID */
>  	lnet_nid_t		 lpni_nid;
>  	/* # refs */
> -	int			 lpni_refcount;
> +	atomic_t		 lpni_refcount;
>  	/* CPT this peer attached on */
>  	int			 lpni_cpt;
>  	/* # refs from lnet_route::lr_gateway */
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 67614309f242..7475678ea184 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -221,7 +221,7 @@ lnet_destroy_peer_locked(struct lnet_peer_ni *lp)
>  {
>  	struct lnet_peer_table *ptable;
>  
> -	LASSERT(!lp->lpni_refcount);
> +	LASSERT(atomic_read(&lp->lpni_refcount) == 0);
>  	LASSERT(!lp->lpni_rtr_refcount);
>  	LASSERT(list_empty(&lp->lpni_txq));
>  	LASSERT(list_empty(&lp->lpni_hashlist));
> @@ -320,7 +320,7 @@ lnet_nid2peer_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt)
>  	lp->lpni_ping_feats = LNET_PING_FEAT_INVAL;
>  	lp->lpni_nid = nid;
>  	lp->lpni_cpt = cpt2;
> -	lp->lpni_refcount = 2;	/* 1 for caller; 1 for hash */
> +	atomic_set(&lp->lpni_refcount, 2);	/* 1 for caller; 1 for hash */
>  	lp->lpni_rtr_refcount = 0;
>  
>  	lnet_net_lock(cpt);
> @@ -378,7 +378,7 @@ lnet_debug_peer(lnet_nid_t nid)
>  		aliveness = lp->lpni_alive ? "up" : "down";
>  
>  	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
> -	       libcfs_nid2str(lp->lpni_nid), lp->lpni_refcount,
> +	       libcfs_nid2str(lp->lpni_nid), atomic_read(&lp->lpni_refcount),
>  	       aliveness, lp->lpni_net->net_tunables.lct_peer_tx_credits,
>  	       lp->lpni_rtrcredits, lp->lpni_minrtrcredits,
>  	       lp->lpni_txcredits, lp->lpni_mintxcredits, lp->lpni_txqnob);
> @@ -433,7 +433,7 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
>  					 lp->lpni_alive ? "up" : "down");
>  
>  			*nid = lp->lpni_nid;
> -			*refcount = lp->lpni_refcount;
> +			*refcount = atomic_read(&lp->lpni_refcount);
>  			*ni_peer_tx_credits =
>  				lp->lpni_net->net_tunables.lct_peer_tx_credits;
>  			*peer_tx_credits = lp->lpni_txcredits;
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 31685406dcc3..bfd4b22cc28a 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -172,7 +172,7 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
>  static void
>  lnet_rtr_addref_locked(struct lnet_peer_ni *lp)
>  {
> -	LASSERT(lp->lpni_refcount > 0);
> +	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
>  	LASSERT(lp->lpni_rtr_refcount >= 0);
>  
>  	/* lnet_net_lock must be exclusively locked */
> @@ -200,7 +200,7 @@ lnet_rtr_addref_locked(struct lnet_peer_ni *lp)
>  static void
>  lnet_rtr_decref_locked(struct lnet_peer_ni *lp)
>  {
> -	LASSERT(lp->lpni_refcount > 0);
> +	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
>  	LASSERT(lp->lpni_rtr_refcount > 0);
>  
>  	/* lnet_net_lock must be exclusively locked */
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index d0340707feaa..12a4b1708d3c 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -320,7 +320,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
>  			lnet_nid_t nid = peer->lpni_nid;
>  			time64_t now = ktime_get_seconds();
>  			time64_t deadline = peer->lpni_ping_deadline;
> -			int nrefs = peer->lpni_refcount;
> +			int nrefs = atomic_read(&peer->lpni_refcount);
>  			int nrtrrefs = peer->lpni_rtr_refcount;
>  			int alive_cnt = peer->lpni_alive_count;
>  			int alive = peer->lpni_alive;
> @@ -486,7 +486,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  
>  		if (peer) {
>  			lnet_nid_t nid = peer->lpni_nid;
> -			int nrefs = peer->lpni_refcount;
> +			int nrefs = atomic_read(&peer->lpni_refcount);
>  			time64_t lastalive = -1;
>  			char *aliveness = "NA";
>  			int maxcr = peer->lpni_net->net_tunables.lct_peer_tx_credits;
> 
> 
> 
