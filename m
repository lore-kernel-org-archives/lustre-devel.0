From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 01:46:24 +0000 (GMT)
Subject: [lustre-devel] [PATCH 06/21] lustre: use list_first_entry() in
 lnet/lnet subdirectory.
In-Reply-To: <154949781293.10620.13774044385661376106.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781293.10620.13774044385661376106.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110145480.24975@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Convert
>   list_entry(foo->next .....)
> to
>   list_first_entry(foo, ....)
> 
> in 'lnet/lnet'
> 
> In several cases the call is combined with
> a list_empty() test and list_first_entry_or_null() is used
> 
> In one case, list_splice_init() is used.

Reviewed-by: James Simmons <jsimmons@infradead.org>

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/api-ni.c     |  111 ++++++++++++-------------
>  drivers/staging/lustre/lnet/lnet/config.c     |   22 ++---
>  drivers/staging/lustre/lnet/lnet/lib-move.c   |   53 ++++++------
>  drivers/staging/lustre/lnet/lnet/lib-msg.c    |   16 ++--
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c    |    7 +-
>  drivers/staging/lustre/lnet/lnet/net_fault.c  |   24 +++--
>  drivers/staging/lustre/lnet/lnet/nidstrings.c |    9 +-
>  drivers/staging/lustre/lnet/lnet/peer.c       |   24 +++--
>  drivers/staging/lustre/lnet/lnet/router.c     |   13 ++-
>  9 files changed, 141 insertions(+), 138 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 64b8bef91915..671591a092ac 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -812,8 +812,8 @@ lnet_net2ni_locked(u32 net_id, int cpt)
>  
>  	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
>  		if (net->net_id == net_id) {
> -			ni = list_entry(net->net_ni_list.next, struct lnet_ni,
> -					ni_netlist);
> +			ni = list_first_entry(&net->net_ni_list, struct lnet_ni,
> +					      ni_netlist);
>  			return ni;
>  		}
>  	}
> @@ -1504,12 +1504,12 @@ lnet_clear_zombies_nis_locked(struct lnet_net *net)
>  	 * list and shut them down in guaranteed thread context
>  	 */
>  	i = 2;
> -	while (!list_empty(zombie_list)) {
> +	while ((ni = list_first_entry_or_null(zombie_list,
> +					      struct lnet_ni,
> +					      ni_netlist)) != NULL) {
>  		int *ref;
>  		int j;
>  
> -		ni = list_entry(zombie_list->next,
> -				struct lnet_ni, ni_netlist);
>  		list_del_init(&ni->ni_netlist);
>  		/* the ni should be in deleting state. If it's not it's
>  		 * a bug */
> @@ -1583,9 +1583,9 @@ lnet_shutdown_lndnet(struct lnet_net *net)
>  
>  	list_del_init(&net->net_list);
>  
> -	while (!list_empty(&net->net_ni_list)) {
> -		ni = list_entry(net->net_ni_list.next,
> -				struct lnet_ni, ni_netlist);
> +	while ((ni = list_first_entry_or_null(&net->net_ni_list,
> +					      struct lnet_ni,
> +					      ni_netlist)) != NULL) {
>  		lnet_net_unlock(LNET_LOCK_EX);
>  		lnet_shutdown_lndni(ni);
>  		lnet_net_lock(LNET_LOCK_EX);
> @@ -1622,16 +1622,12 @@ lnet_shutdown_lndnets(void)
>  	lnet_net_lock(LNET_LOCK_EX);
>  	the_lnet.ln_state = LNET_STATE_STOPPING;
>  
> -	while (!list_empty(&the_lnet.ln_nets)) {
> -		/*
> -		 * move the nets to the zombie list to avoid them being
> -		 * picked up for new work. LONET is also included in the
> -		 * Nets that will be moved to the zombie list
> -		 */
> -		net = list_entry(the_lnet.ln_nets.next,
> -				 struct lnet_net, net_list);
> -		list_move(&net->net_list, &the_lnet.ln_net_zombie);
> -	}
> +	/*
> +	 * move the nets to the zombie list to avoid them being
> +	 * picked up for new work. LONET is also included in the
> +	 * Nets that will be moved to the zombie list
> +	 */
> +	list_splice_init(&the_lnet.ln_nets, &the_lnet.ln_net_zombie);
>  
>  	/* Drop the cached loopback Net. */
>  	if (the_lnet.ln_loni) {
> @@ -1641,11 +1637,10 @@ lnet_shutdown_lndnets(void)
>  	lnet_net_unlock(LNET_LOCK_EX);
>  
>  	/* iterate through the net zombie list and delete each net */
> -	while (!list_empty(&the_lnet.ln_net_zombie)) {
> -		net = list_entry(the_lnet.ln_net_zombie.next,
> -				 struct lnet_net, net_list);
> +	while ((net = list_first_entry_or_null(&the_lnet.ln_net_zombie,
> +					       struct lnet_net,
> +					       net_list)) != NULL)
>  		lnet_shutdown_lndnet(net);
> -	}
>  
>  	lnet_net_lock(LNET_LOCK_EX);
>  	the_lnet.ln_state = LNET_STATE_SHUTDOWN;
> @@ -1833,9 +1828,9 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
>  		goto failed0;
>  	}
>  
> -	while (!list_empty(&net->net_ni_added)) {
> -		ni = list_entry(net->net_ni_added.next, struct lnet_ni,
> -				ni_netlist);
> +	while ((ni = list_first_entry_or_null(&net->net_ni_added,
> +					      struct lnet_ni,
> +					      ni_netlist)) != NULL) {
>  		list_del_init(&ni->ni_netlist);
>  
>  		/* make sure that the the NI we're about to start
> @@ -1902,12 +1897,10 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
>  	 * shutdown the new NIs that are being started up
>  	 * free the NET being started
>  	 */
> -	while (!list_empty(&local_ni_list)) {
> -		ni = list_entry(local_ni_list.next, struct lnet_ni,
> -				ni_netlist);
> -
> +	while ((ni = list_first_entry_or_null(&local_ni_list,
> +					      struct lnet_ni,
> +					      ni_netlist)) != NULL)
>  		lnet_shutdown_lndni(ni);
> -	}
>  
>  failed0:
>  	lnet_net_free(net);
> @@ -1931,8 +1924,9 @@ lnet_startup_lndnets(struct list_head *netlist)
>  	the_lnet.ln_state = LNET_STATE_RUNNING;
>  	lnet_net_unlock(LNET_LOCK_EX);
>  
> -	while (!list_empty(netlist)) {
> -		net = list_entry(netlist->next, struct lnet_net, net_list);
> +	while ((net = list_first_entry_or_null(netlist,
> +					       struct lnet_net,
> +					       net_list)) != NULL) {
>  		list_del_init(&net->net_list);
>  
>  		rc = lnet_startup_lndnet(net, NULL);
> @@ -2022,11 +2016,13 @@ int lnet_lib_init(void)
>   */
>  void lnet_lib_exit(void)
>  {
> +	struct lnet_lnd *lnd;
>  	LASSERT(!the_lnet.ln_refcount);
>  
> -	while (!list_empty(&the_lnet.ln_lnds))
> -		lnet_unregister_lnd(list_entry(the_lnet.ln_lnds.next,
> -					       struct lnet_lnd, lnd_list));
> +	while ((lnd = list_first_entry_or_null(&the_lnet.ln_lnds,
> +					       struct lnet_lnd,
> +					       lnd_list)) != NULL)
> +		lnet_unregister_lnd(lnd);
>  	lnet_destroy_locks();
>  }
>  
> @@ -2172,10 +2168,9 @@ LNetNIInit(lnet_pid_t requested_pid)
>  	lnet_unprepare();
>  	LASSERT(rc < 0);
>  	mutex_unlock(&the_lnet.ln_api_mutex);
> -	while (!list_empty(&net_head)) {
> -		struct lnet_net *net;
> -
> -		net = list_entry(net_head.next, struct lnet_net, net_list);
> +	while ((net = list_first_entry_or_null(&net_head,
> +					       struct lnet_net,
> +					       net_list)) != NULL) {
>  		list_del_init(&net->net_list);
>  		lnet_net_free(net);
>  	}
> @@ -2411,10 +2406,11 @@ lnet_get_next_ni_locked(struct lnet_net *mynet, struct lnet_ni *prev)
>  
>  	if (!prev) {
>  		if (!net)
> -			net = list_entry(the_lnet.ln_nets.next, struct lnet_net,
> -					 net_list);
> -		ni = list_entry(net->net_ni_list.next, struct lnet_ni,
> -				ni_netlist);
> +			net = list_first_entry(&the_lnet.ln_nets,
> +					       struct lnet_net,
> +					       net_list);
> +		ni = list_first_entry(&net->net_ni_list, struct lnet_ni,
> +				      ni_netlist);
>  
>  		return ni;
>  	}
> @@ -2432,17 +2428,17 @@ lnet_get_next_ni_locked(struct lnet_net *mynet, struct lnet_ni *prev)
>  			return NULL;
>  
>  		/* get the next net */
> -		net = list_entry(prev->ni_net->net_list.next, struct lnet_net,
> -				 net_list);
> +		net = list_first_entry(&prev->ni_net->net_list, struct lnet_net,
> +				       net_list);
>  		/* get the ni on it */
> -		ni = list_entry(net->net_ni_list.next, struct lnet_ni,
> -				ni_netlist);
> +		ni = list_first_entry(&net->net_ni_list, struct lnet_ni,
> +				      ni_netlist);
>  
>  		return ni;
>  	}
>  
>  	/* there are more nis left */
> -	ni = list_entry(prev->ni_netlist.next, struct lnet_ni, ni_netlist);
> +	ni = list_first_entry(&prev->ni_netlist, struct lnet_ni, ni_netlist);
>  
>  	return ni;
>  }
> @@ -2637,8 +2633,9 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
>  		return rc;
>  
>  	mutex_lock(&the_lnet.ln_api_mutex);
> -	while (!list_empty(&net_head)) {
> -		net = list_entry(net_head.next, struct lnet_net, net_list);
> +	while ((net = list_first_entry_or_null(&net_head,
> +					       struct lnet_net,
> +					       net_list)) != NULL) {
>  		list_del_init(&net->net_list);
>  		rc = lnet_add_net_common(net, tun);
>  		if (rc < 0)
> @@ -2648,8 +2645,9 @@ static int lnet_handle_legacy_ip2nets(char *ip2nets,
>  out:
>  	mutex_unlock(&the_lnet.ln_api_mutex);
>  
> -	while (!list_empty(&net_head)) {
> -		net = list_entry(net_head.next, struct lnet_net, net_list);
> +	while ((net = list_first_entry_or_null(&net_head,
> +					       struct lnet_net,
> +					       net_list)) != NULL) {
>  		list_del_init(&net->net_list);
>  		lnet_net_free(net);
>  	}
> @@ -2819,7 +2817,7 @@ lnet_dyn_add_net(struct lnet_ioctl_config_data *conf)
>  		goto out_unlock_clean;
>  	}
>  
> -	net = list_entry(net_head.next, struct lnet_net, net_list);
> +	net = list_first_entry(&net_head, struct lnet_net, net_list);
>  	list_del_init(&net->net_list);
>  
>  	LASSERT(lnet_net_unique(net->net_id, &the_lnet.ln_nets, NULL));
> @@ -2839,9 +2837,10 @@ lnet_dyn_add_net(struct lnet_ioctl_config_data *conf)
>  
>  out_unlock_clean:
>  	mutex_unlock(&the_lnet.ln_api_mutex);
> -	while (!list_empty(&net_head)) {
> -		/* net_head list is empty in success case */
> -		net = list_entry(net_head.next, struct lnet_net, net_list);
> +	/* net_head list is empty in success case */
> +	while ((net = list_first_entry_or_null(&net_head,
> +					       struct lnet_net,
> +					       net_list)) != NULL) {
>  		list_del_init(&net->net_list);
>  		lnet_net_free(net);
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index ecf656bce73f..f34844465d01 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -817,8 +817,9 @@ lnet_parse_networks(struct list_head *netlist, char *networks,
>  	lnet_syntax("networks", networks, (int)(str - tokens), strlen(str));
>  failed:
>  	/* free the net list and all the nis on each net */
> -	while (!list_empty(netlist)) {
> -		net = list_entry(netlist->next, struct lnet_net, net_list);
> +	while ((net = list_first_entry_or_null(netlist,
> +					       struct lnet_net,
> +					       net_list)) != NULL) {
>  
>  		list_del_init(&net->net_list);
>  		lnet_net_free(net);
> @@ -875,9 +876,8 @@ lnet_free_text_bufs(struct list_head *tbs)
>  {
>  	struct lnet_text_buf *ltb;
>  
> -	while (!list_empty(tbs)) {
> -		ltb = list_entry(tbs->next, struct lnet_text_buf, ltb_list);
> -
> +	while ((ltb = list_first_entry_or_null(tbs, struct lnet_text_buf,
> +					       ltb_list)) != NULL) {
>  		list_del(&ltb->ltb_list);
>  		lnet_free_text_buf(ltb);
>  	}
> @@ -1239,8 +1239,8 @@ lnet_parse_route_tbs(struct list_head *tbs, int *im_a_router)
>  {
>  	struct lnet_text_buf *ltb;
>  
> -	while (!list_empty(tbs)) {
> -		ltb = list_entry(tbs->next, struct lnet_text_buf, ltb_list);
> +	while ((ltb = list_first_entry_or_null(tbs, struct lnet_text_buf,
> +					       ltb_list)) != NULL) {
>  
>  		if (lnet_parse_route(ltb->ltb_text, im_a_router) < 0) {
>  			lnet_free_text_bufs(tbs);
> @@ -1383,7 +1383,7 @@ lnet_splitnets(char *source, struct list_head *nets)
>  	LASSERT(!list_empty(nets));
>  	LASSERT(nets->next == nets->prev);     /* single entry */
>  
> -	tb = list_entry(nets->next, struct lnet_text_buf, ltb_list);
> +	tb = list_first_entry(nets, struct lnet_text_buf, ltb_list);
>  
>  	for (;;) {
>  		sep = strchr(tb->ltb_text, ',');
> @@ -1478,9 +1478,9 @@ lnet_match_networks(char **networksp, char *ip2nets, u32 *ipaddrs, int nip)
>  	len = 0;
>  	rc = 0;
>  
> -	while (!list_empty(&raw_entries)) {
> -		tb = list_entry(raw_entries.next, struct lnet_text_buf,
> -				ltb_list);
> +	while ((tb = list_first_entry_or_null(&raw_entries,
> +					      struct lnet_text_buf,
> +					      ltb_list)) != NULL) {
>  		strncpy(source, tb->ltb_text, sizeof(source));
>  		source[sizeof(source) - 1] = '\0';
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 92c6a34b44e6..185ea51d2771 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -185,9 +185,9 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
>  
>  	lnet_net_unlock(0);
>  
> -	while (!list_empty(&cull)) {
> -		tp = list_entry(cull.next, struct lnet_test_peer, tp_list);
> -
> +	while ((tp = list_first_entry_or_null(&cull,
> +					      struct lnet_test_peer,
> +					      tp_list)) != NULL) {
>  		list_del(&tp->tp_list);
>  		kfree(tp);
>  	}
> @@ -244,8 +244,9 @@ fail_peer(lnet_nid_t nid, int outgoing)
>  
>  	lnet_net_unlock(0);
>  
> -	while (!list_empty(&cull)) {
> -		tp = list_entry(cull.next, struct lnet_test_peer, tp_list);
> +	while ((tp = list_first_entry_or_null(&cull,
> +					      struct lnet_test_peer,
> +					      tp_list)) != NULL) {
>  		list_del(&tp->tp_list);
>  
>  		kfree(tp);
> @@ -889,7 +890,7 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
>  	}
>  
>  	LASSERT(!list_empty(&rbp->rbp_bufs));
> -	rb = list_entry(rbp->rbp_bufs.next, struct lnet_rtrbuf, rb_list);
> +	rb = list_first_entry(&rbp->rbp_bufs, struct lnet_rtrbuf, rb_list);
>  	list_del(&rb->rb_list);
>  
>  	msg->msg_niov = rbp->rbp_npages;
> @@ -926,8 +927,8 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  		tq->tq_credits++;
>  		atomic_inc(&ni->ni_tx_credits);
>  		if (tq->tq_credits <= 0) {
> -			msg2 = list_entry(tq->tq_delayed.next,
> -					  struct lnet_msg, msg_list);
> +			msg2 = list_first_entry(&tq->tq_delayed,
> +						struct lnet_msg, msg_list);
>  			list_del(&msg2->msg_list);
>  
>  			LASSERT(msg2->msg_txni == ni);
> @@ -953,8 +954,8 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  		if (txpeer->lpni_txcredits <= 0) {
>  			int msg2_cpt;
>  
> -			msg2 = list_entry(txpeer->lpni_txq.next,
> -					  struct lnet_msg, msg_list);
> +			msg2 = list_first_entry(&txpeer->lpni_txq,
> +						struct lnet_msg, msg_list);
>  			list_del(&msg2->msg_list);
>  			spin_unlock(&txpeer->lpni_lock);
>  
> @@ -1015,8 +1016,8 @@ lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp)
>  
>  	if (list_empty(&rbp->rbp_msgs))
>  		return;
> -	msg = list_entry(rbp->rbp_msgs.next,
> -			 struct lnet_msg, msg_list);
> +	msg = list_first_entry(&rbp->rbp_msgs,
> +			       struct lnet_msg, msg_list);
>  	list_del(&msg->msg_list);
>  
>  	(void)lnet_post_routed_recv_locked(msg, 1);
> @@ -1117,8 +1118,8 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  			spin_unlock(&rxpeer->lpni_lock);
>  			lnet_drop_routed_msgs_locked(&drop, msg->msg_rx_cpt);
>  		} else if (rxpeer->lpni_rtrcredits <= 0) {
> -			msg2 = list_entry(rxpeer->lpni_rtrq.next,
> -					  struct lnet_msg, msg_list);
> +			msg2 = list_first_entry(&rxpeer->lpni_rtrq,
> +						struct lnet_msg, msg_list);
>  			list_del(&msg2->msg_list);
>  			spin_unlock(&rxpeer->lpni_lock);
>  			(void)lnet_post_routed_recv_locked(msg2, 1);
> @@ -1553,8 +1554,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  				       libcfs_net2str(best_lpni->lpni_net->net_id));
>  				return -EHOSTUNREACH;
>  			}
> -			lpni = list_entry(peer_net->lpn_peer_nis.next,
> -					  struct lnet_peer_ni,
> +			lpni = list_first_entry(&peer_net->lpn_peer_nis,
> +						struct lnet_peer_ni,
>  					  lpni_peer_nis);
>  		}
>  		/* Set preferred NI if necessary. */
> @@ -1595,9 +1596,9 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  		if (!local_net && !routing && !local_found) {
>  			struct lnet_peer_ni *net_gw;
>  
> -			lpni = list_entry(peer_net->lpn_peer_nis.next,
> -					  struct lnet_peer_ni,
> -					  lpni_peer_nis);
> +			lpni = list_first_entry(&peer_net->lpn_peer_nis,
> +						struct lnet_peer_ni,
> +						lpni_peer_nis);
>  
>  			net_gw = lnet_find_route_locked(NULL,
>  							lpni->lpni_nid,
> @@ -2620,11 +2621,12 @@ EXPORT_SYMBOL(lnet_parse);
>  void
>  lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
>  {
> -	while (!list_empty(head)) {
> +	struct lnet_msg *msg;
> +
> +	while ((msg = list_first_entry_or_null(head, struct lnet_msg,
> +					       msg_list)) != NULL) {
>  		struct lnet_process_id id = { 0 };
> -		struct lnet_msg *msg;
>  
> -		msg = list_entry(head->next, struct lnet_msg, msg_list);
>  		list_del(&msg->msg_list);
>  
>  		id.nid = msg->msg_hdr.src_nid;
> @@ -2662,11 +2664,12 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
>  void
>  lnet_recv_delayed_msg_list(struct list_head *head)
>  {
> -	while (!list_empty(head)) {
> -		struct lnet_msg *msg;
> +	struct lnet_msg *msg;
> +
> +	while ((msg = list_first_entry_or_null(head, struct lnet_msg,
> +					       msg_list)) != NULL) {
>  		struct lnet_process_id id;
>  
> -		msg = list_entry(head->next, struct lnet_msg, msg_list);
>  		list_del(&msg->msg_list);
>  
>  		/*
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> index b9e9257a4c5a..02620fe2a0fa 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> @@ -528,10 +528,9 @@ lnet_finalize(struct lnet_msg *msg, int status)
>  
>  	container->msc_finalizers[my_slot] = current;
>  
> -	while (!list_empty(&container->msc_finalizing)) {
> -		msg = list_entry(container->msc_finalizing.next,
> -				 struct lnet_msg, msg_list);
> -
> +	while ((msg = list_first_entry_or_null(&container->msc_finalizing,
> +					       struct lnet_msg,
> +					       msg_list)) != NULL) {
>  		list_del(&msg->msg_list);
>  
>  		/*
> @@ -561,15 +560,14 @@ void
>  lnet_msg_container_cleanup(struct lnet_msg_container *container)
>  {
>  	int count = 0;
> +	struct lnet_msg *msg;
>  
>  	if (!container->msc_init)
>  		return;
>  
> -	while (!list_empty(&container->msc_active)) {
> -		struct lnet_msg *msg;
> -
> -		msg = list_entry(container->msc_active.next,
> -				 struct lnet_msg, msg_activelist);
> +	while ((msg = list_first_entry_or_null(&container->msc_active,
> +					       struct lnet_msg,
> +					       msg_activelist)) != NULL) {
>  		LASSERT(msg->msg_onactivelist);
>  		msg->msg_onactivelist = 0;
>  		list_del(&msg->msg_activelist);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index ea232c76b64d..4a12d86e6d64 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -767,9 +767,10 @@ lnet_ptl_cleanup(struct lnet_portal *ptl)
>  		mhash = mtable->mt_mhash;
>  		/* cleanup ME */
>  		for (j = 0; j < LNET_MT_HASH_SIZE + 1; j++) {
> -			while (!list_empty(&mhash[j])) {
> -				me = list_entry(mhash[j].next,
> -						struct lnet_me, me_list);
> +			while ((me = list_first_entry_or_null(&mhash[j],
> +							      struct lnet_me,
> +							      me_list))
> +			       != NULL) {
>  				CERROR("Active ME %p on exit\n", me);
>  				list_del(&me->me_list);
>  				kfree(me);
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index 4234ce1ce539..130a7c90965d 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -581,8 +581,8 @@ delayed_msg_check(struct lnet_delay_rule *rule, bool all,
>  		 * dequeued some timedout messages, update timer for the
>  		 * next delayed message on rule
>  		 */
> -		msg = list_entry(rule->dl_msg_list.next,
> -				 struct lnet_msg, msg_list);
> +		msg = list_first_entry(&rule->dl_msg_list,
> +				       struct lnet_msg, msg_list);
>  		rule->dl_msg_send = msg->msg_delay_send;
>  		mod_timer(&rule->dl_timer, rule->dl_msg_send);
>  	}
> @@ -594,12 +594,12 @@ delayed_msg_process(struct list_head *msg_list, bool drop)
>  {
>  	struct lnet_msg	*msg;
>  
> -	while (!list_empty(msg_list)) {
> +	while ((msg = list_first_entry_or_null(msg_list, struct lnet_msg,
> +					       msg_list)) != NULL) {
>  		struct lnet_ni *ni;
>  		int cpt;
>  		int rc;
>  
> -		msg = list_entry(msg_list->next, struct lnet_msg, msg_list);
>  		LASSERT(msg->msg_rxpeer);
>  		LASSERT(msg->msg_rxni);
>  
> @@ -653,16 +653,16 @@ lnet_delay_rule_check(void)
>  			break;
>  
>  		spin_lock_bh(&delay_dd.dd_lock);
> -		if (list_empty(&delay_dd.dd_sched_rules)) {
> -			spin_unlock_bh(&delay_dd.dd_lock);
> -			break;
> -		}
> -
> -		rule = list_entry(delay_dd.dd_sched_rules.next,
> -				  struct lnet_delay_rule, dl_sched_link);
> -		list_del_init(&rule->dl_sched_link);
> +		rule = list_first_entry_or_null(&delay_dd.dd_sched_rules,
> +						struct lnet_delay_rule,
> +						dl_sched_link);
> +		if (!rule)
> +			list_del_init(&rule->dl_sched_link);
>  		spin_unlock_bh(&delay_dd.dd_lock);
>  
> +		if (!rule)
> +			break;
> +
>  		delayed_msg_check(rule, false, &msgs);
>  		delay_rule_decref(rule); /* -1 for delay_dd.dd_sched_rules */
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
> index 8f3d87c5467c..2df9ce4995f3 100644
> --- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
> +++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
> @@ -282,10 +282,11 @@ parse_nidrange(struct cfs_lstr *src, struct list_head *nidlist)
>  static void
>  free_addrranges(struct list_head *list)
>  {
> -	while (!list_empty(list)) {
> -		struct addrrange *ar;
> +	struct addrrange *ar;
>  
> -		ar = list_entry(list->next, struct addrrange, ar_link);
> +	while ((ar = list_first_entry_or_null(list,
> +					      struct addrrange,
> +					      ar_link)) != NULL) {
>  
>  		cfs_expr_list_free_list(&ar->ar_numaddr_ranges);
>  		list_del(&ar->ar_link);
> @@ -960,7 +961,7 @@ libcfs_num_match(u32 addr, struct list_head *numaddr)
>  	struct cfs_expr_list *el;
>  
>  	LASSERT(!list_empty(numaddr));
> -	el = list_entry(numaddr->next, struct cfs_expr_list, el_link);
> +	el = list_first_entry(numaddr, struct cfs_expr_list, el_link);
>  
>  	return cfs_expr_list_match(addr, el);
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index dfe1f3d09bc6..ade7f23b3bf4 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -649,12 +649,12 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
>  			if (list_empty(&peer->lp_peer_nets))
>  				return NULL;
>  
> -			net = list_entry(peer->lp_peer_nets.next,
> -					 struct lnet_peer_net,
> -					 lpn_peer_nets);
> +			net = list_first_entry(&peer->lp_peer_nets,
> +					       struct lnet_peer_net,
> +					       lpn_peer_nets);
>  		}
> -		lpni = list_entry(net->lpn_peer_nis.next, struct lnet_peer_ni,
> -				  lpni_peer_nis);
> +		lpni = list_first_entry(&net->lpn_peer_nis, struct lnet_peer_ni,
> +					lpni_peer_nis);
>  
>  		return lpni;
>  	}
> @@ -678,19 +678,19 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
>  			return NULL;
>  
>  		/* get the next net */
> -		net = list_entry(prev->lpni_peer_net->lpn_peer_nets.next,
> -				 struct lnet_peer_net,
> -				 lpn_peer_nets);
> +		net = list_first_entry(&prev->lpni_peer_net->lpn_peer_nets,
> +				       struct lnet_peer_net,
> +				       lpn_peer_nets);
>  		/* get the ni on it */
> -		lpni = list_entry(net->lpn_peer_nis.next, struct lnet_peer_ni,
> -				  lpni_peer_nis);
> +		lpni = list_first_entry(&net->lpn_peer_nis, struct lnet_peer_ni,
> +					lpni_peer_nis);
>  
>  		return lpni;
>  	}
>  
>  	/* there are more nis left */
> -	lpni = list_entry(prev->lpni_peer_nis.next,
> -			  struct lnet_peer_ni, lpni_peer_nis);
> +	lpni = list_first_entry(&prev->lpni_peer_nis,
> +				struct lnet_peer_ni, lpni_peer_nis);
>  
>  	return lpni;
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 463b123e0e5c..bcde61d2a984 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -1220,9 +1220,9 @@ lnet_prune_rc_data(int wait_unlink)
>  
>  		lnet_net_unlock(LNET_LOCK_EX);
>  
> -		while (!list_empty(&head)) {
> -			rcd = list_entry(head.next,
> -					 struct lnet_rc_data, rcd_list);
> +		while ((rcd = list_first_entry_or_null(&head,
> +						       struct lnet_rc_data,
> +						       rcd_list)) != NULL) {
>  			list_del_init(&rcd->rcd_list);
>  			lnet_destroy_rc_data(rcd);
>  		}
> @@ -1397,7 +1397,7 @@ lnet_rtrpool_free_bufs(struct lnet_rtrbufpool *rbp, int cpt)
>  
>  	/* Free buffers on the free list. */
>  	while (!list_empty(&tmp)) {
> -		rb = list_entry(tmp.next, struct lnet_rtrbuf, rb_list);
> +		rb = list_first_entry(&tmp, struct lnet_rtrbuf, rb_list);
>  		list_del(&rb->rb_list);
>  		lnet_destroy_rtrbuf(rb, npages);
>  	}
> @@ -1481,8 +1481,9 @@ lnet_rtrpool_adjust_bufs(struct lnet_rtrbufpool *rbp, int nbufs, int cpt)
>  	return 0;
>  
>  failed:
> -	while (!list_empty(&rb_list)) {
> -		rb = list_entry(rb_list.next, struct lnet_rtrbuf, rb_list);
> +	while ((rb = list_first_entry_or_null(&rb_list,
> +					      struct lnet_rtrbuf,
> +					      rb_list)) != NULL) {
>  		list_del(&rb->rb_list);
>  		lnet_destroy_rtrbuf(rb, npages);
>  	}
> 
> 
> 
