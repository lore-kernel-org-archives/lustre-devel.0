From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 23:47:01 +0100 (BST)
Subject: [lustre-devel] [PATCH 02/34] lnet: change struct lnet_peer to
 struct lnet_peer_ni
In-Reply-To: <153783763493.32103.9862696546795848039.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763493.32103.9862696546795848039.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809292346160.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Also remove the typedef
> 
> sed -i -e 's/struct lnet_peer\b/struct lnet_peer_ni/g' -e 's/lnet_peer_t\b/struct lnet_peer_ni/g' `git ls-files lnet`
> 
> Then edit lib-types.h to remove the typedef, and clean up some long lines.
> 
> This is part of
>     Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
> from upstream lustre, where it is marked:
>     Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>     WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
>     Reviewed-on: http://review.whamcloud.com/18293
>     Reviewed-by: Olaf Weber <olaf@sgi.com>
>     Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>

Sigh, I missed some typedef. Thanks for finding them.

Reviewed-by: James Simmons <jsimmons@infradead.org>

 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   20 ++++++-----
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   10 +++---
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |   26 +++++++--------
>  drivers/staging/lustre/lnet/lnet/peer.c            |   31 +++++++++---------
>  drivers/staging/lustre/lnet/lnet/router.c          |   35 ++++++++++----------
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |   12 +++----
>  6 files changed, 68 insertions(+), 66 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 9b54a3d72290..ef53638e20f6 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -311,16 +311,16 @@ lnet_handle2me(struct lnet_handle_me *handle)
>  }
>  
>  static inline void
> -lnet_peer_addref_locked(struct lnet_peer *lp)
> +lnet_peer_addref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(lp->lpni_refcount > 0);
>  	lp->lpni_refcount++;
>  }
>  
> -void lnet_destroy_peer_locked(struct lnet_peer *lp);
> +void lnet_destroy_peer_locked(struct lnet_peer_ni *lp);
>  
>  static inline void
> -lnet_peer_decref_locked(struct lnet_peer *lp)
> +lnet_peer_decref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(lp->lpni_refcount > 0);
>  	lp->lpni_refcount--;
> @@ -329,7 +329,7 @@ lnet_peer_decref_locked(struct lnet_peer *lp)
>  }
>  
>  static inline int
> -lnet_isrouter(struct lnet_peer *lp)
> +lnet_isrouter(struct lnet_peer_ni *lp)
>  {
>  	return lp->lpni_rtr_refcount ? 1 : 0;
>  }
> @@ -410,7 +410,7 @@ void lnet_lib_exit(void);
>  
>  int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive,
>  		time64_t when);
> -void lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
> +void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
>  			time64_t when);
>  int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
>  		   unsigned int priority);
> @@ -624,7 +624,7 @@ int lnet_peer_buffer_credits(struct lnet_net *net);
>  
>  int lnet_router_checker_start(void);
>  void lnet_router_checker_stop(void);
> -void lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net);
> +void lnet_router_ni_update_locked(struct lnet_peer_ni *gw, __u32 net);
>  void lnet_swap_pinginfo(struct lnet_ping_info *info);
>  
>  int lnet_parse_ip2nets(char **networksp, char *ip2nets);
> @@ -635,9 +635,9 @@ bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
>  		     struct lnet_net **net);
>  bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
>  
> -int lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt);
> -struct lnet_peer *lnet_find_peer_locked(struct lnet_peer_table *ptable,
> -					lnet_nid_t nid);
> +int lnet_nid2peer_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
> +struct lnet_peer_ni *lnet_find_peer_locked(struct lnet_peer_table *ptable,
> +					   lnet_nid_t nid);
>  void lnet_peer_tables_cleanup(struct lnet_ni *ni);
>  void lnet_peer_tables_destroy(void);
>  int lnet_peer_tables_create(void);
> @@ -650,7 +650,7 @@ int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
>  		       __u32 *peer_tx_qnob);
>  
>  static inline void
> -lnet_peer_set_alive(struct lnet_peer *lp)
> +lnet_peer_set_alive(struct lnet_peer_ni *lp)
>  {
>  	lp->lpni_last_query = ktime_get_seconds();
>  	lp->lpni_last_alive = lp->lpni_last_query;
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 59a1a2620675..4b26801d7d29 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -93,8 +93,8 @@ struct lnet_msg {
>  	unsigned int	msg_onactivelist:1;	/* on the activelist */
>  	unsigned int	msg_rdma_get:1;
>  
> -	struct lnet_peer	*msg_txpeer;	 /* peer I'm sending to */
> -	struct lnet_peer	*msg_rxpeer;	 /* peer I received from */
> +	struct lnet_peer_ni	*msg_txpeer;	 /* peer I'm sending to */
> +	struct lnet_peer_ni	*msg_rxpeer;	 /* peer I received from */
>  
>  	void			*msg_private;
>  	struct lnet_libmd	*msg_md;
> @@ -378,12 +378,12 @@ struct lnet_rc_data {
>  	/* ping buffer MD */
>  	struct lnet_handle_md	rcd_mdh;
>  	/* reference to gateway */
> -	struct lnet_peer	*rcd_gateway;
> +	struct lnet_peer_ni	*rcd_gateway;
>  	/* ping buffer */
>  	struct lnet_ping_info	*rcd_pinginfo;
>  };
>  
> -struct lnet_peer {
> +struct lnet_peer_ni {
>  	/* chain on peer hash */
>  	struct list_head	 lpni_hashlist;
>  	/* messages blocking for tx credits */
> @@ -474,7 +474,7 @@ struct lnet_route {
>  	/* chain on gateway */
>  	struct list_head	lr_gwlist;
>  	/* router node */
> -	struct lnet_peer	*lr_gateway;
> +	struct lnet_peer_ni	*lr_gateway;
>  	/* remote network number */
>  	__u32			lr_net;
>  	/* sequence for round-robin */
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 5879a109d46a..4425406e441b 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -491,7 +491,7 @@ lnet_ni_eager_recv(struct lnet_ni *ni, struct lnet_msg *msg)
>  
>  /* NB: caller shall hold a ref on 'lp' as I'd drop lnet_net_lock */
>  static void
> -lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
> +lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
>  {
>  	time64_t last_alive = 0;
>  
> @@ -510,7 +510,7 @@ lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
>  
>  /* NB: always called with lnet_net_lock held */
>  static inline int
> -lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
> +lnet_peer_is_alive(struct lnet_peer_ni *lp, unsigned long now)
>  {
>  	int alive;
>  	time64_t deadline;
> @@ -544,7 +544,7 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
>   *     may drop the lnet_net_lock
>   */
>  static int
> -lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer *lp)
> +lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
>  {
>  	time64_t now = ktime_get_seconds();
>  
> @@ -599,7 +599,7 @@ lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer *lp)
>  static int
>  lnet_post_send_locked(struct lnet_msg *msg, int do_send)
>  {
> -	struct lnet_peer *lp = msg->msg_txpeer;
> +	struct lnet_peer_ni *lp = msg->msg_txpeer;
>  	struct lnet_ni *ni = msg->msg_txni;
>  	int cpt = msg->msg_tx_cpt;
>  	struct lnet_tx_queue *tq = ni->ni_tx_queues[cpt];
> @@ -710,7 +710,7 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
>  	 * I return LNET_CREDIT_WAIT if msg blocked and LNET_CREDIT_OK if
>  	 * received or OK to receive
>  	 */
> -	struct lnet_peer *lp = msg->msg_rxpeer;
> +	struct lnet_peer_ni *lp = msg->msg_rxpeer;
>  	struct lnet_rtrbufpool *rbp;
>  	struct lnet_rtrbuf *rb;
>  
> @@ -780,7 +780,7 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
>  void
>  lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  {
> -	struct lnet_peer *txpeer = msg->msg_txpeer;
> +	struct lnet_peer_ni *txpeer = msg->msg_txpeer;
>  	struct lnet_msg *msg2;
>  	struct lnet_ni	*txni = msg->msg_txni;
>  
> @@ -881,7 +881,7 @@ lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
>  void
>  lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  {
> -	struct lnet_peer *rxpeer = msg->msg_rxpeer;
> +	struct lnet_peer_ni *rxpeer = msg->msg_rxpeer;
>  	struct lnet_ni	*rxni = msg->msg_rxni;
>  	struct lnet_msg *msg2;
>  
> @@ -971,8 +971,8 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  static int
>  lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
>  {
> -	struct lnet_peer *p1 = r1->lr_gateway;
> -	struct lnet_peer *p2 = r2->lr_gateway;
> +	struct lnet_peer_ni *p1 = r1->lr_gateway;
> +	struct lnet_peer_ni *p2 = r2->lr_gateway;
>  	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
>  	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
>  
> @@ -1006,7 +1006,7 @@ lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
>  	return -ERANGE;
>  }
>  
> -static struct lnet_peer *
> +static struct lnet_peer_ni *
>  lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
>  		       lnet_nid_t rtr_nid)
>  {
> @@ -1014,8 +1014,8 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
>  	struct lnet_route *route;
>  	struct lnet_route *best_route;
>  	struct lnet_route *last_route;
> -	struct lnet_peer *lpni_best;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lpni_best;
> +	struct lnet_peer_ni *lp;
>  	int rc;
>  
>  	/*
> @@ -1076,7 +1076,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  	lnet_nid_t dst_nid = msg->msg_target.nid;
>  	struct lnet_ni *src_ni;
>  	struct lnet_ni *local_ni;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  	int cpt;
>  	int cpt2;
>  	int rc;
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 619d016b1d89..67614309f242 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -106,8 +106,8 @@ lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
>  			       struct lnet_peer_table *ptable)
>  {
>  	int i;
> -	struct lnet_peer *lp;
> -	struct lnet_peer *tmp;
> +	struct lnet_peer_ni *lp;
> +	struct lnet_peer_ni *tmp;
>  
>  	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
>  		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
> @@ -146,8 +146,8 @@ lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
>  				struct lnet_peer_table *ptable,
>  				int cpt_locked)
>  {
> -	struct lnet_peer *lp;
> -	struct lnet_peer *tmp;
> +	struct lnet_peer_ni *lp;
> +	struct lnet_peer_ni *tmp;
>  	lnet_nid_t lpni_nid;
>  	int i;
>  
> @@ -174,7 +174,7 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>  {
>  	struct lnet_peer_table *ptable;
>  	struct list_head deathrow;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  	int i;
>  
>  	INIT_LIST_HEAD(&deathrow);
> @@ -209,14 +209,15 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>  	}
>  
>  	while (!list_empty(&deathrow)) {
> -		lp = list_entry(deathrow.next, struct lnet_peer, lpni_hashlist);
> +		lp = list_entry(deathrow.next, struct lnet_peer_ni,
> +				lpni_hashlist);
>  		list_del(&lp->lpni_hashlist);
>  		kfree(lp);
>  	}
>  }
>  
>  void
> -lnet_destroy_peer_locked(struct lnet_peer *lp)
> +lnet_destroy_peer_locked(struct lnet_peer_ni *lp)
>  {
>  	struct lnet_peer_table *ptable;
>  
> @@ -237,11 +238,11 @@ lnet_destroy_peer_locked(struct lnet_peer *lp)
>  	ptable->pt_zombies--;
>  }
>  
> -struct lnet_peer *
> +struct lnet_peer_ni *
>  lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
>  {
>  	struct list_head *peers;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  
>  	LASSERT(!the_lnet.ln_shutdown);
>  
> @@ -257,11 +258,11 @@ lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
>  }
>  
>  int
> -lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
> +lnet_nid2peer_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt)
>  {
>  	struct lnet_peer_table *ptable;
> -	struct lnet_peer *lp = NULL;
> -	struct lnet_peer *lp2;
> +	struct lnet_peer_ni *lp = NULL;
> +	struct lnet_peer_ni *lp2;
>  	int cpt2;
>  	int rc = 0;
>  
> @@ -281,7 +282,7 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
>  
>  	if (!list_empty(&ptable->pt_deathrow)) {
>  		lp = list_entry(ptable->pt_deathrow.next,
> -				struct lnet_peer, lpni_hashlist);
> +				struct lnet_peer_ni, lpni_hashlist);
>  		list_del(&lp->lpni_hashlist);
>  	}
>  
> @@ -359,7 +360,7 @@ void
>  lnet_debug_peer(lnet_nid_t nid)
>  {
>  	char *aliveness = "NA";
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  	int rc;
>  	int cpt;
>  
> @@ -396,7 +397,7 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
>  		   __u32 *peer_tx_qnob)
>  {
>  	struct lnet_peer_table *peer_table;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  	bool found = false;
>  	int lncpt, j;
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 2be1ffb6b720..31685406dcc3 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -100,7 +100,7 @@ lnet_peers_start_down(void)
>  }
>  
>  void
> -lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
> +lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
>  		   time64_t when)
>  {
>  	if (lp->lpni_timestamp > when) { /* out of date information */
> @@ -130,7 +130,7 @@ lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
>  }
>  
>  static void
> -lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer *lp)
> +lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
>  {
>  	int alive;
>  	int notifylnd;
> @@ -170,7 +170,7 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer *lp)
>  }
>  
>  static void
> -lnet_rtr_addref_locked(struct lnet_peer *lp)
> +lnet_rtr_addref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(lp->lpni_refcount > 0);
>  	LASSERT(lp->lpni_rtr_refcount >= 0);
> @@ -182,9 +182,10 @@ lnet_rtr_addref_locked(struct lnet_peer *lp)
>  
>  		/* a simple insertion sort */
>  		list_for_each_prev(pos, &the_lnet.ln_routers) {
> -			struct lnet_peer *rtr;
> +			struct lnet_peer_ni *rtr;
>  
> -			rtr = list_entry(pos, struct lnet_peer, lpni_rtr_list);
> +			rtr = list_entry(pos, struct lnet_peer_ni,
> +					 lpni_rtr_list);
>  			if (rtr->lpni_nid < lp->lpni_nid)
>  				break;
>  		}
> @@ -197,7 +198,7 @@ lnet_rtr_addref_locked(struct lnet_peer *lp)
>  }
>  
>  static void
> -lnet_rtr_decref_locked(struct lnet_peer *lp)
> +lnet_rtr_decref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(lp->lpni_refcount > 0);
>  	LASSERT(lp->lpni_rtr_refcount > 0);
> @@ -453,7 +454,7 @@ lnet_check_routes(void)
>  int
>  lnet_del_route(__u32 net, lnet_nid_t gw_nid)
>  {
> -	struct lnet_peer *gateway;
> +	struct lnet_peer_ni *gateway;
>  	struct lnet_remotenet *rnet;
>  	struct lnet_route *route;
>  	int rc = -ENOENT;
> @@ -614,7 +615,7 @@ static void
>  lnet_parse_rc_info(struct lnet_rc_data *rcd)
>  {
>  	struct lnet_ping_info *info = rcd->rcd_pinginfo;
> -	struct lnet_peer *gw = rcd->rcd_gateway;
> +	struct lnet_peer_ni *gw = rcd->rcd_gateway;
>  	struct lnet_route *rte;
>  
>  	if (!gw->lpni_alive)
> @@ -703,7 +704,7 @@ static void
>  lnet_router_checker_event(struct lnet_event *event)
>  {
>  	struct lnet_rc_data *rcd = event->md.user_ptr;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  
>  	LASSERT(rcd);
>  
> @@ -760,7 +761,7 @@ lnet_router_checker_event(struct lnet_event *event)
>  static void
>  lnet_wait_known_routerstate(void)
>  {
> -	struct lnet_peer *rtr;
> +	struct lnet_peer_ni *rtr;
>  	int all_known;
>  
>  	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING);
> @@ -786,7 +787,7 @@ lnet_wait_known_routerstate(void)
>  }
>  
>  void
> -lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net)
> +lnet_router_ni_update_locked(struct lnet_peer_ni *gw, __u32 net)
>  {
>  	struct lnet_route *rte;
>  
> @@ -863,7 +864,7 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
>  }
>  
>  static struct lnet_rc_data *
> -lnet_create_rc_data_locked(struct lnet_peer *gateway)
> +lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
>  {
>  	struct lnet_rc_data *rcd = NULL;
>  	struct lnet_ping_info *pi;
> @@ -933,7 +934,7 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
>  }
>  
>  static int
> -lnet_router_check_interval(struct lnet_peer *rtr)
> +lnet_router_check_interval(struct lnet_peer_ni *rtr)
>  {
>  	int secs;
>  
> @@ -946,7 +947,7 @@ lnet_router_check_interval(struct lnet_peer *rtr)
>  }
>  
>  static void
> -lnet_ping_router_locked(struct lnet_peer *rtr)
> +lnet_ping_router_locked(struct lnet_peer_ni *rtr)
>  {
>  	struct lnet_rc_data *rcd = NULL;
>  	time64_t now = ktime_get_seconds();
> @@ -1092,7 +1093,7 @@ lnet_prune_rc_data(int wait_unlink)
>  {
>  	struct lnet_rc_data *rcd;
>  	struct lnet_rc_data *tmp;
> -	struct lnet_peer *lp;
> +	struct lnet_peer_ni *lp;
>  	struct list_head head;
>  	int i = 2;
>  
> @@ -1197,7 +1198,7 @@ lnet_router_checker_active(void)
>  static int
>  lnet_router_checker(void *arg)
>  {
> -	struct lnet_peer *rtr;
> +	struct lnet_peer_ni *rtr;
>  
>  	while (the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING) {
>  		__u64 version;
> @@ -1693,7 +1694,7 @@ lnet_rtrpools_disable(void)
>  int
>  lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
>  {
> -	struct lnet_peer *lp = NULL;
> +	struct lnet_peer_ni *lp = NULL;
>  	time64_t now = ktime_get_seconds();
>  	int cpt = lnet_cpt_of_nid(nid, ni);
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 01c9ad44266f..d0340707feaa 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -289,7 +289,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
>  		*ppos = LNET_PROC_POS_MAKE(0, ver, 0, off);
>  	} else {
>  		struct list_head *r;
> -		struct lnet_peer *peer = NULL;
> +		struct lnet_peer_ni *peer = NULL;
>  		int skip = off - 1;
>  
>  		lnet_net_lock(0);
> @@ -304,9 +304,9 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
>  		r = the_lnet.ln_routers.next;
>  
>  		while (r != &the_lnet.ln_routers) {
> -			struct lnet_peer *lp;
> +			struct lnet_peer_ni *lp;
>  
> -			lp = list_entry(r, struct lnet_peer, lpni_rtr_list);
> +			lp = list_entry(r, struct lnet_peer_ni, lpni_rtr_list);
>  			if (!skip) {
>  				peer = lp;
>  				break;
> @@ -425,7 +425,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  
>  		hoff++;
>  	} else {
> -		struct lnet_peer *peer;
> +		struct lnet_peer_ni *peer;
>  		struct list_head *p;
>  		int skip;
>   again:
> @@ -449,9 +449,9 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  				p = ptable->pt_hash[hash].next;
>  
>  			while (p != &ptable->pt_hash[hash]) {
> -				struct lnet_peer *lp;
> +				struct lnet_peer_ni *lp;
>  
> -				lp = list_entry(p, struct lnet_peer,
> +				lp = list_entry(p, struct lnet_peer_ni,
>  						lpni_hashlist);
>  				if (!skip) {
>  					peer = lp;
> 
> 
> 
