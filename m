From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Sep 2018 00:17:06 +0100 (BST)
Subject: [lustre-devel] [PATCH 07/34] lnet: change lnet_peer to
 reference the net, rather than ni.
In-Reply-To: <153628137151.8267.3943711043829439593.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137151.8267.3943711043829439593.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809110010510.29662@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> As a net will soon have multiple ni, a peer should identify
> just the net.
> Various places that we need the ni, we now use rxni or txni from
> the message
> 
> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 +
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    5 +-
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   13 +++++
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |   49 +++++++++++---------
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    2 -
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |    3 +
>  drivers/staging/lustre/lnet/lnet/peer.c            |   26 ++++-------
>  drivers/staging/lustre/lnet/lnet/router.c          |   14 +++---
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 -
>  9 files changed, 67 insertions(+), 50 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 4440b87299c4..34509e52bac7 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -435,6 +435,7 @@ int lnet_dyn_add_ni(lnet_pid_t requested_pid,
>  		    struct lnet_ioctl_config_data *conf);
>  int lnet_dyn_del_ni(__u32 net);
>  int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
> +struct lnet_net *lnet_get_net_locked(__u32 net_id);

Using __u32 and friends for internal lustre kernel code was disliked by 
Greg. I recommend any new code pushed in which __uXX is used is changed
to the proper kernel uXX versions. 
  
>  int lnet_islocalnid(lnet_nid_t nid);
>  int lnet_islocalnet(__u32 net);
> @@ -617,7 +618,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
>  void libcfs_sock_release(struct socket *sock);
>  
>  int lnet_peers_start_down(void);
> -int lnet_peer_buffer_credits(struct lnet_ni *ni);
> +int lnet_peer_buffer_credits(struct lnet_net *net);
>  
>  int lnet_router_checker_start(void);
>  void lnet_router_checker_stop(void);
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 16a493529a46..255c6c4bbb89 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -396,7 +396,8 @@ struct lnet_peer {
>  	time64_t		 lp_last_query;	/* when lp_ni was queried
>  						 * last time
>  						 */
> -	struct lnet_ni		*lp_ni;		/* interface peer is on */
> +	/* network peer is on */
> +	struct lnet_net		*lp_net;
>  	lnet_nid_t		 lp_nid;	/* peer's NID */
>  	int			 lp_refcount;	/* # refs */
>  	int			 lp_cpt;	/* CPT this peer attached on */
> @@ -427,7 +428,7 @@ struct lnet_peer_table {
>   * lnet_ni::ni_peertimeout has been set to a positive value
>   */
>  #define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing && \
> -					 (lp)->lp_ni->ni_net->net_tunables.lct_peer_timeout > 0)
> +					 (lp)->lp_net->net_tunables.lct_peer_timeout > 0)
>  
>  struct lnet_route {
>  	struct list_head	 lr_list;	/* chain on net */
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 05687278334a..c21aef32cdde 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -680,6 +680,19 @@ lnet_net2ni(__u32 net)
>  }
>  EXPORT_SYMBOL(lnet_net2ni);
>  
> +struct lnet_net *
> +lnet_get_net_locked(__u32 net_id)
> +{
> +	struct lnet_net	 *net;
> +
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		if (net->net_id == net_id)
> +			return net;
> +	}
> +
> +	return NULL;
> +}
> +
>  static unsigned int
>  lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number)
>  {
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index b2a52ddcefcb..b8b15f56a275 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -525,7 +525,7 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
>  		return 0;
>  
>  	deadline = lp->lp_last_alive +
> -		lp->lp_ni->ni_net->net_tunables.lct_peer_timeout;
> +		lp->lp_net->net_tunables.lct_peer_timeout;
>  	alive = deadline > now;
>  
>  	/* Update obsolete lp_alive except for routers assumed to be dead
> @@ -544,7 +544,7 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
>   *     may drop the lnet_net_lock
>   */
>  static int
> -lnet_peer_alive_locked(struct lnet_peer *lp)
> +lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer *lp)
>  {
>  	time64_t now = ktime_get_seconds();
>  
> @@ -570,13 +570,13 @@ lnet_peer_alive_locked(struct lnet_peer *lp)
>  				      libcfs_nid2str(lp->lp_nid),
>  				      now, next_query,
>  				      lnet_queryinterval,
> -				      lp->lp_ni->ni_net->net_tunables.lct_peer_timeout);
> +				      lp->lp_net->net_tunables.lct_peer_timeout);
>  			return 0;
>  		}
>  	}
>  
>  	/* query NI for latest aliveness news */
> -	lnet_ni_query_locked(lp->lp_ni, lp);
> +	lnet_ni_query_locked(ni, lp);
>  
>  	if (lnet_peer_is_alive(lp, now))
>  		return 1;
> @@ -600,7 +600,7 @@ static int
>  lnet_post_send_locked(struct lnet_msg *msg, int do_send)
>  {
>  	struct lnet_peer *lp = msg->msg_txpeer;
> -	struct lnet_ni *ni = lp->lp_ni;
> +	struct lnet_ni *ni = msg->msg_txni;
>  	int cpt = msg->msg_tx_cpt;
>  	struct lnet_tx_queue *tq = ni->ni_tx_queues[cpt];
>  
> @@ -611,7 +611,7 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
>  
>  	/* NB 'lp' is always the next hop */
>  	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
> -	    !lnet_peer_alive_locked(lp)) {
> +	    !lnet_peer_alive_locked(ni, lp)) {
>  		the_lnet.ln_counters[cpt]->drop_count++;
>  		the_lnet.ln_counters[cpt]->drop_length += msg->msg_len;
>  		lnet_net_unlock(cpt);
> @@ -770,7 +770,7 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
>  		int cpt = msg->msg_rx_cpt;
>  
>  		lnet_net_unlock(cpt);
> -		lnet_ni_recv(lp->lp_ni, msg->msg_private, msg, 1,
> +		lnet_ni_recv(msg->msg_rxni, msg->msg_private, msg, 1,
>  			     0, msg->msg_len, msg->msg_len);
>  		lnet_net_lock(cpt);
>  	}
> @@ -785,7 +785,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  	struct lnet_ni	*txni = msg->msg_txni;
>  
>  	if (msg->msg_txcredit) {
> -		struct lnet_ni *ni = txpeer->lp_ni;
> +		struct lnet_ni *ni = msg->msg_txni;
>  		struct lnet_tx_queue *tq = ni->ni_tx_queues[msg->msg_tx_cpt];
>  
>  		/* give back NI txcredits */
> @@ -800,7 +800,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  					  struct lnet_msg, msg_list);
>  			list_del(&msg2->msg_list);
>  
> -			LASSERT(msg2->msg_txpeer->lp_ni == ni);
> +			LASSERT(msg2->msg_txni == ni);
>  			LASSERT(msg2->msg_tx_delayed);
>  
>  			(void)lnet_post_send_locked(msg2, 1);
> @@ -869,7 +869,7 @@ lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
>  
>  	while(!list_empty(&drop)) {
>  		msg = list_first_entry(&drop, struct lnet_msg, msg_list);
> -		lnet_ni_recv(msg->msg_rxpeer->lp_ni, msg->msg_private, NULL,
> +		lnet_ni_recv(msg->msg_rxni, msg->msg_private, NULL,
>  			     0, 0, 0, msg->msg_hdr.payload_length);
>  		list_del_init(&msg->msg_list);
>  		lnet_finalize(NULL, msg, -ECANCELED);
> @@ -1007,7 +1007,7 @@ lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
>  }
>  
>  static struct lnet_peer *
> -lnet_find_route_locked(struct lnet_ni *ni, lnet_nid_t target,
> +lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
>  		       lnet_nid_t rtr_nid)
>  {
>  	struct lnet_remotenet *rnet;
> @@ -1035,7 +1035,7 @@ lnet_find_route_locked(struct lnet_ni *ni, lnet_nid_t target,
>  		if (!lnet_is_route_alive(route))
>  			continue;
>  
> -		if (ni && lp->lp_ni != ni)
> +		if (net && lp->lp_net != net)
>  			continue;
>  
>  		if (lp->lp_nid == rtr_nid) /* it's pre-determined router */
> @@ -1164,10 +1164,12 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  			/* ENOMEM or shutting down */
>  			return rc;
>  		}
> -		LASSERT(lp->lp_ni == src_ni);
> +		LASSERT(lp->lp_net == src_ni->ni_net);
>  	} else {
>  		/* sending to a remote network */
> -		lp = lnet_find_route_locked(src_ni, dst_nid, rtr_nid);
> +		lp = lnet_find_route_locked(src_ni != NULL ?
> +					    src_ni->ni_net : NULL,
> +					    dst_nid, rtr_nid);
>  		if (!lp) {
>  			if (src_ni)
>  				lnet_ni_decref_locked(src_ni, cpt);
> @@ -1203,10 +1205,11 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  		       lnet_msgtyp2str(msg->msg_type), msg->msg_len);
>  
>  		if (!src_ni) {
> -			src_ni = lp->lp_ni;
> +			src_ni = lnet_get_next_ni_locked(lp->lp_net, NULL);
> +			LASSERT(src_ni != NULL);

Checkpatch will not like the above.

>  			src_nid = src_ni->ni_nid;
>  		} else {
> -			LASSERT(src_ni == lp->lp_ni);
> +			LASSERT(src_ni->ni_net == lp->lp_net);
>  			lnet_ni_decref_locked(src_ni, cpt);
>  		}
>  
> @@ -1918,7 +1921,7 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
>  		 * called lnet_drop_message(), so I just hang onto msg as well
>  		 * until that's done
>  		 */
> -		lnet_drop_message(msg->msg_rxpeer->lp_ni,
> +		lnet_drop_message(msg->msg_rxni,
>  				  msg->msg_rxpeer->lp_cpt,
>  				  msg->msg_private, msg->msg_len);
>  		/*
> @@ -1926,7 +1929,7 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
>  		 * but we still should give error code so lnet_msg_decommit()
>  		 * can skip counters operations and other checks.
>  		 */
> -		lnet_finalize(msg->msg_rxpeer->lp_ni, msg, -ENOENT);
> +		lnet_finalize(msg->msg_rxni, msg, -ENOENT);
>  	}
>  }
>  
> @@ -1959,7 +1962,7 @@ lnet_recv_delayed_msg_list(struct list_head *head)
>  		       msg->msg_hdr.msg.put.offset,
>  		       msg->msg_hdr.payload_length);
>  
> -		lnet_recv_put(msg->msg_rxpeer->lp_ni, msg);
> +		lnet_recv_put(msg->msg_rxni, msg);
>  	}
>  }
>  
> @@ -2384,8 +2387,12 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
>  
>  			LASSERT(shortest);
>  			hops = shortest_hops;
> -			if (srcnidp)
> -				*srcnidp = shortest->lr_gateway->lp_ni->ni_nid;
> +			if (srcnidp) {
> +				ni = lnet_get_next_ni_locked(
> +					shortest->lr_gateway->lp_net,
> +					NULL);
> +				*srcnidp = ni->ni_nid;
> +			}
>  			if (orderp)
>  				*orderp = order;
>  			lnet_net_unlock(cpt);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index fc47379c5938..4c5737083422 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -946,7 +946,7 @@ lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason)
>  		/* grab all messages which are on the NI passed in */
>  		list_for_each_entry_safe(msg, tmp, &ptl->ptl_msg_delayed,
>  					 msg_list) {
> -			if (msg->msg_rxpeer->lp_ni == ni)
> +			if (msg->msg_txni == ni || msg->msg_rxni == ni)
>  				list_move(&msg->msg_list, &zombies);
>  		}
>  	} else {
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index 41d6131ee15a..6c53ae1811e5 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -601,8 +601,9 @@ delayed_msg_process(struct list_head *msg_list, bool drop)
>  
>  		msg = list_entry(msg_list->next, struct lnet_msg, msg_list);
>  		LASSERT(msg->msg_rxpeer);
> +		LASSERT(msg->msg_rxni != NULL);
>  
> -		ni = msg->msg_rxpeer->lp_ni;
> +		ni = msg->msg_rxni;
>  		cpt = msg->msg_rx_cpt;
>  
>  		list_del_init(&msg->msg_list);
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index b76ac3e051d9..ed29124ebded 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -112,7 +112,7 @@ lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
>  	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
>  		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
>  					 lp_hashlist) {
> -			if (ni && ni != lp->lp_ni)
> +			if (ni && ni->ni_net != lp->lp_net)
>  				continue;
>  			list_del_init(&lp->lp_hashlist);
>  			/* Lose hash table's ref */
> @@ -154,7 +154,7 @@ lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
>  	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
>  		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
>  					 lp_hashlist) {
> -			if (ni != lp->lp_ni)
> +			if (ni->ni_net != lp->lp_net)
>  				continue;
>  
>  			if (!lp->lp_rtr_refcount)
> @@ -230,8 +230,7 @@ lnet_destroy_peer_locked(struct lnet_peer *lp)
>  	LASSERT(ptable->pt_number > 0);
>  	ptable->pt_number--;
>  
> -	lnet_ni_decref_locked(lp->lp_ni, lp->lp_cpt);
> -	lp->lp_ni = NULL;
> +	lp->lp_net = NULL;
>  
>  	list_add(&lp->lp_hashlist, &ptable->pt_deathrow);
>  	LASSERT(ptable->pt_zombies > 0);
> @@ -336,16 +335,11 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
>  		goto out;
>  	}
>  
> -	lp->lp_ni = lnet_net2ni_locked(LNET_NIDNET(nid), cpt2);
> -	if (!lp->lp_ni) {
> -		rc = -EHOSTUNREACH;
> -		goto out;
> -	}
> -
> -	lp->lp_txcredits = lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
> -	lp->lp_mintxcredits = lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
> -	lp->lp_rtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
> -	lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
> +	lp->lp_net = lnet_get_net_locked(LNET_NIDNET(!lp->lp_nid));

This is the single error in your port that broke stuff. The correct code 
is:

lp->lp_net = lnet_get_net_locked(LNET_NIDNET(lp->lp_nid));


> +	lp->lp_txcredits =
> +		lp->lp_mintxcredits = lp->lp_net->net_tunables.lct_peer_tx_credits;
> +	lp->lp_rtrcredits =
> +		lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_net);
>  
>  	list_add_tail(&lp->lp_hashlist,
>  		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
> @@ -383,7 +377,7 @@ lnet_debug_peer(lnet_nid_t nid)
>  
>  	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
>  	       libcfs_nid2str(lp->lp_nid), lp->lp_refcount,
> -	       aliveness, lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits,
> +	       aliveness, lp->lp_net->net_tunables.lct_peer_tx_credits,
>  	       lp->lp_rtrcredits, lp->lp_minrtrcredits,
>  	       lp->lp_txcredits, lp->lp_mintxcredits, lp->lp_txqnob);
>  
> @@ -439,7 +433,7 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
>  			*nid = lp->lp_nid;
>  			*refcount = lp->lp_refcount;
>  			*ni_peer_tx_credits =
> -				lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
> +				lp->lp_net->net_tunables.lct_peer_tx_credits;
>  			*peer_tx_credits = lp->lp_txcredits;
>  			*peer_rtr_credits = lp->lp_rtrcredits;
>  			*peer_min_rtr_credits = lp->lp_mintxcredits;
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 135dfe793b0b..72b8ca2b0fc6 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -55,10 +55,8 @@ module_param(auto_down, int, 0444);
>  MODULE_PARM_DESC(auto_down, "Automatically mark peers down on comms error");
>  
>  int
> -lnet_peer_buffer_credits(struct lnet_ni *ni)
> +lnet_peer_buffer_credits(struct lnet_net *net)
>  {
> -	struct lnet_net *net = ni->ni_net;
> -
>  	/* NI option overrides LNet default */
>  	if (net->net_tunables.lct_peer_rtr_credits > 0)
>  		return net->net_tunables.lct_peer_rtr_credits;
> @@ -373,7 +371,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
>  		lnet_peer_addref_locked(route->lr_gateway); /* +1 for notify */
>  		lnet_add_route_to_rnet(rnet2, route);
>  
> -		ni = route->lr_gateway->lp_ni;
> +		ni = lnet_get_next_ni_locked(route->lr_gateway->lp_net, NULL);
>  		lnet_net_unlock(LNET_LOCK_EX);
>  
>  		/* XXX Assume alive */
> @@ -428,8 +426,8 @@ lnet_check_routes(void)
>  					continue;
>  				}
>  
> -				if (route->lr_gateway->lp_ni ==
> -				    route2->lr_gateway->lp_ni)
> +				if (route->lr_gateway->lp_net ==
> +				    route2->lr_gateway->lp_net)
>  					continue;
>  
>  				nid1 = route->lr_gateway->lp_nid;
> @@ -952,6 +950,7 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
>  	struct lnet_rc_data *rcd = NULL;
>  	time64_t now = ktime_get_seconds();
>  	time64_t secs;
> +	struct lnet_ni  *ni;

Another grep from Greg was the spacing in declared variables. As I port
patches new code removes the spacing. Newer lustre code no long does
this kind of spacing. Well most of it :-)

>  
>  	lnet_peer_addref_locked(rtr);
>  
> @@ -960,7 +959,8 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
>  		lnet_notify_locked(rtr, 1, 0, now);
>  
>  	/* Run any outstanding notifications */
> -	lnet_ni_notify_locked(rtr->lp_ni, rtr);
> +	ni = lnet_get_next_ni_locked(rtr->lp_net, NULL);
> +	lnet_ni_notify_locked(ni, rtr);
>  
>  	if (!lnet_isrouter(rtr) ||
>  	    the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING) {
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 2a366e9a8627..52714b898aac 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -489,7 +489,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  			int nrefs = peer->lp_refcount;
>  			time64_t lastalive = -1;
>  			char *aliveness = "NA";
> -			int maxcr = peer->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
> +			int maxcr = peer->lp_net->net_tunables.lct_peer_tx_credits;
>  			int txcr = peer->lp_txcredits;
>  			int mintxcr = peer->lp_mintxcredits;
>  			int rtrcr = peer->lp_rtrcredits;
> 
> 
> 
