From: NeilBrown <neilb@suse.com>
Date: Thu, 27 Sep 2018 10:03:10 +1000
Subject: [lustre-devel] [PATCH 05/25] lustre: lnet: fix race in lnet
 shutdown path
In-Reply-To: <1537930097-11624-6-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
 <1537930097-11624-6-git-send-email-jsimmons@infradead.org>
Message-ID: <87zhw3hkn5.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 25 2018, James Simmons wrote:

> From: Olaf Weber <olaf.weber@hpe.com>
>
> The locking changes for the lnet_net_lock made for Multi-Rail
> introduce a race in the LNet shutdown path. The code keeps two
> states in the_lnet.ln_shutdown: 0 means LNet is either up and
> running or shut down, while 1 means lnet is shutting down. In
> lnet_select_pathway() if we need to restart and drop and relock
> the lnet_net_lock we can find that LNet went from running to
> stopped, and not be able to tell the difference.
>
> Replace ln_shutdown with a three-state ln_state patterned on
> ln_rc_state: states are LNET_STATE_SHUTDOWN, LNET_STATE_RUNNING,
> and LNET_STATE_STOPPING. Most checks against ln_shutdown now test
> ln_state against LNET_STATE_RUNNING. LNet moves to RUNNING state
> in lnet_startup_lndnets().
>
> Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
> Reviewed-on: https://review.whamcloud.com/26690
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/include/linux/lnet/lib-types.h |  9 +++++++--
>  drivers/staging/lustre/lnet/lnet/api-ni.c             | 15 ++++++++++++---
>  drivers/staging/lustre/lnet/lnet/lib-move.c           |  2 +-
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c            |  4 ++--
>  drivers/staging/lustre/lnet/lnet/peer.c               | 10 +++++-----
>  drivers/staging/lustre/lnet/lnet/router.c             |  6 +++---
>  6 files changed, 30 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 18e2665..6abac19 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -726,6 +726,11 @@ struct lnet_msg_container {
>  #define LNET_RC_STATE_RUNNING		1	/* started up OK */
>  #define LNET_RC_STATE_STOPPING		2	/* telling thread to stop */
>  
> +/* LNet states */
> +#define LNET_STATE_SHUTDOWN		0	/* not started */
> +#define LNET_STATE_RUNNING		1	/* started up OK */
> +#define LNET_STATE_STOPPING		2	/* telling thread to stop */

This would be nicer as an enum ...

NeilBrown


> +
>  struct lnet {
>  	/* CPU partition table of LNet */
>  	struct cfs_cpt_table		 *ln_cpt_table;
> @@ -805,8 +810,8 @@ struct lnet {
>  	int				  ln_niinit_self;
>  	/* LNetNIInit/LNetNIFini counter */
>  	int				  ln_refcount;
> -	/* shutdown in progress */
> -	int				  ln_shutdown;
> +	/* SHUTDOWN/RUNNING/STOPPING */
> +	int				  ln_state;
>  
>  	int				  ln_routing;	/* am I a router? */
>  	lnet_pid_t			  ln_pid;	/* requested pid */
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 2d430d0..7c907a3 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -1277,11 +1277,11 @@ struct lnet_ni *
>  	/* NB called holding the global mutex */
>  
>  	/* All quiet on the API front */
> -	LASSERT(!the_lnet.ln_shutdown);
> +	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
>  	LASSERT(!the_lnet.ln_refcount);
>  
>  	lnet_net_lock(LNET_LOCK_EX);
> -	the_lnet.ln_shutdown = 1;	/* flag shutdown */
> +	the_lnet.ln_state = LNET_STATE_STOPPING;
>  
>  	while (!list_empty(&the_lnet.ln_nets)) {
>  		/*
> @@ -1309,7 +1309,7 @@ struct lnet_ni *
>  	}
>  
>  	lnet_net_lock(LNET_LOCK_EX);
> -	the_lnet.ln_shutdown = 0;
> +	the_lnet.ln_state = LNET_STATE_SHUTDOWN;
>  	lnet_net_unlock(LNET_LOCK_EX);
>  }
>  
> @@ -1583,6 +1583,15 @@ struct lnet_ni *
>  	int rc;
>  	int ni_count = 0;
>  
> +	/*
> +	 * Change to running state before bringing up the LNDs. This
> +	 * allows lnet_shutdown_lndnets() to assert that we've passed
> +	 * through here.
> +	 */
> +	lnet_net_lock(LNET_LOCK_EX);
> +	the_lnet.ln_state = LNET_STATE_RUNNING;
> +	lnet_net_unlock(LNET_LOCK_EX);
> +
>  	while (!list_empty(netlist)) {
>  		net = list_entry(netlist->next, struct lnet_net, net_list);
>  		list_del_init(&net->net_list);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index a213387..ea7e2c3 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1242,7 +1242,7 @@
>  
>  	seq = lnet_get_dlc_seq_locked();
>  
> -	if (the_lnet.ln_shutdown) {
> +	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
>  		lnet_net_unlock(cpt);
>  		return -ESHUTDOWN;
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index d403353..6fa5bbf 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -589,7 +589,7 @@ struct list_head *
>  	mtable = lnet_mt_of_match(info, msg);
>  	lnet_res_lock(mtable->mt_cpt);
>  
> -	if (the_lnet.ln_shutdown) {
> +	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
>  		rc = LNET_MATCHMD_DROP;
>  		goto out1;
>  	}
> @@ -951,7 +951,7 @@ struct list_head *
>  				list_move(&msg->msg_list, &zombies);
>  		}
>  	} else {
> -		if (the_lnet.ln_shutdown)
> +		if (the_lnet.ln_state != LNET_STATE_RUNNING)
>  			CWARN("Active lazy portal %d on exit\n", portal);
>  		else
>  			CDEBUG(D_NET, "clearing portal %d lazy\n", portal);
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index ae3ffca..2fbf93a 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -428,7 +428,7 @@ void lnet_peer_uninit(void)
>  	struct lnet_peer_table *ptable;
>  	int i;
>  
> -	LASSERT(the_lnet.ln_shutdown || net);
> +	LASSERT(the_lnet.ln_state != LNET_STATE_SHUTDOWN || net);
>  	/*
>  	 * If just deleting the peers for a NI, get rid of any routes these
>  	 * peers are gateways for.
> @@ -458,7 +458,7 @@ void lnet_peer_uninit(void)
>  	struct list_head	*peers;
>  	struct lnet_peer_ni	*lp;
>  
> -	LASSERT(!the_lnet.ln_shutdown);
> +	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
>  
>  	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
>  	list_for_each_entry(lp, peers, lpni_hashlist) {
> @@ -1000,7 +1000,7 @@ struct lnet_peer_ni *
>  	struct lnet_peer_ni *lpni = NULL;
>  	int rc;
>  
> -	if (the_lnet.ln_shutdown) /* it's shutting down */
> +	if (the_lnet.ln_state != LNET_STATE_RUNNING)
>  		return ERR_PTR(-ESHUTDOWN);
>  
>  	/*
> @@ -1034,7 +1034,7 @@ struct lnet_peer_ni *
>  	struct lnet_peer_ni *lpni = NULL;
>  	int rc;
>  
> -	if (the_lnet.ln_shutdown) /* it's shutting down */
> +	if (the_lnet.ln_state != LNET_STATE_RUNNING)
>  		return ERR_PTR(-ESHUTDOWN);
>  
>  	/*
> @@ -1063,7 +1063,7 @@ struct lnet_peer_ni *
>  	 * Shutdown is only set under the ln_api_lock, so a single
>  	 * check here is sufficent.
>  	 */
> -	if (the_lnet.ln_shutdown) {
> +	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
>  		lpni = ERR_PTR(-ESHUTDOWN);
>  		goto out_mutex_unlock;
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index a0483f9..d3aef8b 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -252,7 +252,7 @@ struct lnet_remotenet *
>  	struct lnet_remotenet *rnet;
>  	struct list_head *rn_list;
>  
> -	LASSERT(!the_lnet.ln_shutdown);
> +	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
>  
>  	rn_list = lnet_net2rnethash(net);
>  	list_for_each_entry(rnet, rn_list, lrn_list) {
> @@ -374,7 +374,7 @@ static void lnet_shuffle_seed(void)
>  		return rc;
>  	}
>  	route->lr_gateway = lpni;
> -	LASSERT(!the_lnet.ln_shutdown);
> +	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
>  
>  	rnet2 = lnet_find_rnet_locked(net);
>  	if (!rnet2) {
> @@ -1775,7 +1775,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  
>  	lnet_net_lock(cpt);
>  
> -	if (the_lnet.ln_shutdown) {
> +	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
>  		lnet_net_unlock(cpt);
>  		return -ESHUTDOWN;
>  	}
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180927/f8acef4a/attachment-0001.sig>
