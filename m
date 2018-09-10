From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Sep 2018 00:27:40 +0100 (BST)
Subject: [lustre-devel] [PATCH 05/34] lnet: begin separating "networks"
 from "network interfaces".
In-Reply-To: <153628137142.8267.15402125903541546660.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137142.8267.15402125903541546660.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809110027250.29662@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Fri, 7 Sep 2018, NeilBrown wrote:

> We already have "struct lnet_net" separate from "struct lnet_ni",
> but they are currently allocated together and freed together and
> it is assumed that they are 1-to-1.
> 
> This patch starts breaking that assumption.  We have separate
> lnet_net_alloc() and lnet_net_free() to alloc/free the new lnet_net,
> though they is currently called only when lnet_ni_alloc/free are
> called.
> 
> The netid is now stored in the lnet_net and fetched directly from
> there, rather than extracting it from the net-interface-id ni_nid.
> 
> The linkage between these two structures is now richer, lnet_net
> can link to a list of lnet_ni.  lnet_net now has a list of lnet_net,
> so to find all the lnet_ni, we need to walk a list of lists.
> This need to walk a list-of-lists occurs in several places, and new
> helpers like lnet_get_ni_idx_locked() and lnet_get_next_ni_locked are
> introduced.
> 
> Previously a list_head was passed to lnet_ni_alloc() for the new
> lnet_ni to be attached to.
> Now a list is passed to lnet_net_alloc() for the net to be attached
> to, and a lnet_net is passed to lnet_ni_alloc() for the ni to attach
> to.
> lnet_ni_alloc() also receives an interface name, but this is currently
> unused.

Reviewed-by: James Simmons <jsimmons@infradead.org>

The below needs fixing based on response to cover letter.
 
> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   15 +
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   23 +-
>  drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  255 ++++++++++++++------
>  drivers/staging/lustre/lnet/lnet/config.c          |  135 +++++++----
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    6 
>  drivers/staging/lustre/lnet/lnet/router.c          |   15 -
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |   16 -
>  8 files changed, 308 insertions(+), 159 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 0fecf0d32c58..4440b87299c4 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -369,8 +369,14 @@ lnet_ni_decref(struct lnet_ni *ni)
>  }
>  
>  void lnet_ni_free(struct lnet_ni *ni);
> +void lnet_net_free(struct lnet_net *net);
> +
> +struct lnet_net *
> +lnet_net_alloc(__u32 net_type, struct list_head *netlist);
> +
>  struct lnet_ni *
> -lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist);
> +lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el,
> +	      char *iface);
>  
>  static inline int
>  lnet_nid2peerhash(lnet_nid_t nid)
> @@ -412,6 +418,9 @@ void lnet_destroy_routes(void);
>  int lnet_get_route(int idx, __u32 *net, __u32 *hops,
>  		   lnet_nid_t *gateway, __u32 *alive, __u32 *priority);
>  int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg);
> +struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
> +					struct lnet_ni *prev);
> +struct lnet_ni *lnet_get_ni_idx_locked(int idx);
>  
>  void lnet_router_debugfs_init(void);
>  void lnet_router_debugfs_fini(void);
> @@ -584,7 +593,7 @@ int lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
>  		 __u32 local_ip, __u32 peer_ip, int peer_port);
>  void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
>  				__u32 peer_ip, int port);
> -int lnet_count_acceptor_nis(void);
> +int lnet_count_acceptor_nets(void);
>  int lnet_acceptor_timeout(void);
>  int lnet_acceptor_port(void);
>  
> @@ -618,7 +627,7 @@ void lnet_swap_pinginfo(struct lnet_ping_info *info);
>  int lnet_parse_ip2nets(char **networksp, char *ip2nets);
>  int lnet_parse_routes(char *route_str, int *im_a_router);
>  int lnet_parse_networks(struct list_head *nilist, char *networks);
> -int lnet_net_unique(__u32 net, struct list_head *nilist);
> +bool lnet_net_unique(__u32 net, struct list_head *nilist);
>  
>  int lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt);
>  struct lnet_peer *lnet_find_peer_locked(struct lnet_peer_table *ptable,
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index c5e3363de727..5f0d4703bf86 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -254,6 +254,15 @@ struct lnet_tx_queue {
>  };
>  
>  struct lnet_net {
> +	/* chain on the ln_nets */
> +	struct list_head	net_list;
> +
> +	/* net ID, which is compoed of
> +	 * (net_type << 16) | net_num.
> +	 * net_type can be one of the enumarated types defined in
> +	 * lnet/include/lnet/nidstr.h */
> +	__u32			net_id;
> +
>  	/* network tunables */
>  	struct lnet_ioctl_config_lnd_cmn_tunables net_tunables;
>  
> @@ -264,11 +273,13 @@ struct lnet_net {
>  	bool			  net_tunables_set;
>  	/* procedural interface */
>  	struct lnet_lnd		*net_lnd;
> +	/* list of NIs on this net */
> +	struct list_head	net_ni_list;
>  };
>  
>  struct lnet_ni {
> -	/* chain on ln_nis */
> -	struct list_head	  ni_list;
> +	/* chain on the lnet_net structure */
> +	struct list_head	  ni_netlist;
>  	/* chain on ln_nis_cpt */
>  	struct list_head	ni_cptlist;
>  
> @@ -626,14 +637,16 @@ struct lnet {
>  	/* failure simulation */
>  	struct list_head		  ln_test_peers;
>  	struct list_head		  ln_drop_rules;
> -	struct list_head		  ln_delay_rules;
> +	struct list_head		ln_delay_rules;
>  
> -	struct list_head		  ln_nis;	/* LND instances */
> +	/* LND instances */
> +	struct list_head		ln_nets;
>  	/* NIs bond on specific CPT(s) */
>  	struct list_head		  ln_nis_cpt;
>  	/* dying LND instances */
>  	struct list_head		  ln_nis_zombie;
> -	struct lnet_ni			 *ln_loni;	/* the loopback NI */
> +	/* the loopback NI */
> +	struct lnet_ni			*ln_loni;
>  
>  	/* remote networks with routes to them */
>  	struct list_head		 *ln_remote_nets_hash;
> diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
> index f8c921f0221c..88b90c1fdbaf 100644
> --- a/drivers/staging/lustre/lnet/lnet/acceptor.c
> +++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
> @@ -454,7 +454,7 @@ lnet_acceptor_start(void)
>  	if (rc <= 0)
>  		return rc;
>  
> -	if (!lnet_count_acceptor_nis())  /* not required */
> +	if (lnet_count_acceptor_nets() == 0)  /* not required */
>  		return 0;
>  
>  	task = kthread_run(lnet_acceptor, (void *)(uintptr_t)secure,
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index c944fbb155c8..05687278334a 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -537,7 +537,7 @@ lnet_prepare(lnet_pid_t requested_pid)
>  	the_lnet.ln_pid = requested_pid;
>  
>  	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
> -	INIT_LIST_HEAD(&the_lnet.ln_nis);
> +	INIT_LIST_HEAD(&the_lnet.ln_nets);
>  	INIT_LIST_HEAD(&the_lnet.ln_nis_cpt);
>  	INIT_LIST_HEAD(&the_lnet.ln_nis_zombie);
>  	INIT_LIST_HEAD(&the_lnet.ln_routers);
> @@ -616,7 +616,7 @@ lnet_unprepare(void)
>  
>  	LASSERT(!the_lnet.ln_refcount);
>  	LASSERT(list_empty(&the_lnet.ln_test_peers));
> -	LASSERT(list_empty(&the_lnet.ln_nis));
> +	LASSERT(list_empty(&the_lnet.ln_nets));
>  	LASSERT(list_empty(&the_lnet.ln_nis_cpt));
>  	LASSERT(list_empty(&the_lnet.ln_nis_zombie));
>  
> @@ -648,14 +648,17 @@ lnet_unprepare(void)
>  }
>  
>  struct lnet_ni  *
> -lnet_net2ni_locked(__u32 net, int cpt)
> +lnet_net2ni_locked(__u32 net_id, int cpt)
>  {
> -	struct lnet_ni *ni;
> +	struct lnet_ni   *ni;
> +	struct lnet_net  *net;
>  
>  	LASSERT(cpt != LNET_LOCK_EX);
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		if (LNET_NIDNET(ni->ni_nid) == net) {
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		if (net->net_id == net_id) {
> +			ni = list_entry(net->net_ni_list.next, struct lnet_ni,
> +					ni_netlist);
>  			lnet_ni_addref_locked(ni, cpt);
>  			return ni;
>  		}
> @@ -760,14 +763,17 @@ lnet_islocalnet(__u32 net)
>  struct lnet_ni  *
>  lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
>  {
> -	struct lnet_ni *ni;
> +	struct lnet_net  *net;
> +	struct lnet_ni	 *ni;
>  
>  	LASSERT(cpt != LNET_LOCK_EX);
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		if (ni->ni_nid == nid) {
> -			lnet_ni_addref_locked(ni, cpt);
> -			return ni;
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +			if (ni->ni_nid == nid) {
> +				lnet_ni_addref_locked(ni, cpt);
> +				return ni;
> +			}
>  		}
>  	}
>  
> @@ -790,16 +796,18 @@ lnet_islocalnid(lnet_nid_t nid)
>  }
>  
>  int
> -lnet_count_acceptor_nis(void)
> +lnet_count_acceptor_nets(void)
>  {
>  	/* Return the # of NIs that need the acceptor. */
> -	int count = 0;
> -	struct lnet_ni *ni;
> -	int cpt;
> +	int		 count = 0;
> +	struct lnet_net  *net;
> +	int		 cpt;
>  
>  	cpt = lnet_net_lock_current();
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		if (ni->ni_net->net_lnd->lnd_accept)
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		/* all socklnd type networks should have the acceptor
> +		 * thread started */
> +		if (net->net_lnd->lnd_accept)
>  			count++;
>  	}
>  
> @@ -832,13 +840,16 @@ lnet_ping_info_create(int num_ni)
>  static inline int
>  lnet_get_ni_count(void)
>  {
> -	struct lnet_ni *ni;
> -	int count = 0;
> +	struct lnet_ni	*ni;
> +	struct lnet_net *net;
> +	int		count = 0;
>  
>  	lnet_net_lock(0);
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list)
> -		count++;
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
> +			count++;
> +	}
>  
>  	lnet_net_unlock(0);
>  
> @@ -854,14 +865,17 @@ lnet_ping_info_free(struct lnet_ping_info *pinfo)
>  static void
>  lnet_ping_info_destroy(void)
>  {
> +	struct lnet_net *net;
>  	struct lnet_ni *ni;
>  
>  	lnet_net_lock(LNET_LOCK_EX);
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		lnet_ni_lock(ni);
> -		ni->ni_status = NULL;
> -		lnet_ni_unlock(ni);
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +			lnet_ni_lock(ni);
> +			ni->ni_status = NULL;
> +			lnet_ni_unlock(ni);
> +		}
>  	}
>  
>  	lnet_ping_info_free(the_lnet.ln_ping_info);
> @@ -963,24 +977,28 @@ lnet_ping_md_unlink(struct lnet_ping_info *pinfo,
>  static void
>  lnet_ping_info_install_locked(struct lnet_ping_info *ping_info)
>  {
> +	int i = 0;
>  	struct lnet_ni_status *ns;
>  	struct lnet_ni *ni;
> -	int i = 0;
> +	struct lnet_net *net;
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		LASSERT(i < ping_info->pi_nnis);
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +			LASSERT(i < ping_info->pi_nnis);
>  
> -		ns = &ping_info->pi_ni[i];
> +			ns = &ping_info->pi_ni[i];
>  
> -		ns->ns_nid = ni->ni_nid;
> +			ns->ns_nid = ni->ni_nid;
>  
> -		lnet_ni_lock(ni);
> -		ns->ns_status = (ni->ni_status) ?
> -				 ni->ni_status->ns_status : LNET_NI_STATUS_UP;
> -		ni->ni_status = ns;
> -		lnet_ni_unlock(ni);
> +			lnet_ni_lock(ni);
> +			ns->ns_status = ni->ni_status ?
> +					ni->ni_status->ns_status :
> +						LNET_NI_STATUS_UP;
> +			ni->ni_status = ns;
> +			lnet_ni_unlock(ni);
>  
> -		i++;
> +			i++;
> +		}
>  	}
>  }
>  
> @@ -1054,9 +1072,9 @@ lnet_ni_unlink_locked(struct lnet_ni *ni)
>  	}
>  
>  	/* move it to zombie list and nobody can find it anymore */
> -	LASSERT(!list_empty(&ni->ni_list));
> -	list_move(&ni->ni_list, &the_lnet.ln_nis_zombie);
> -	lnet_ni_decref_locked(ni, 0);	/* drop ln_nis' ref */
> +	LASSERT(!list_empty(&ni->ni_netlist));
> +	list_move(&ni->ni_netlist, &the_lnet.ln_nis_zombie);
> +	lnet_ni_decref_locked(ni, 0);
>  }
>  
>  static void
> @@ -1076,17 +1094,17 @@ lnet_clear_zombies_nis_locked(void)
>  		int j;
>  
>  		ni = list_entry(the_lnet.ln_nis_zombie.next,
> -				struct lnet_ni, ni_list);
> -		list_del_init(&ni->ni_list);
> +				struct lnet_ni, ni_netlist);
> +		list_del_init(&ni->ni_netlist);
>  		cfs_percpt_for_each(ref, j, ni->ni_refs) {
>  			if (!*ref)
>  				continue;
>  			/* still busy, add it back to zombie list */
> -			list_add(&ni->ni_list, &the_lnet.ln_nis_zombie);
> +			list_add(&ni->ni_netlist, &the_lnet.ln_nis_zombie);
>  			break;
>  		}
>  
> -		if (!list_empty(&ni->ni_list)) {
> +		if (!list_empty(&ni->ni_netlist)) {
>  			lnet_net_unlock(LNET_LOCK_EX);
>  			++i;
>  			if ((i & (-i)) == i) {
> @@ -1126,6 +1144,7 @@ lnet_shutdown_lndnis(void)
>  {
>  	struct lnet_ni *ni;
>  	int i;
> +	struct lnet_net *net;
>  
>  	/* NB called holding the global mutex */
>  
> @@ -1138,10 +1157,14 @@ lnet_shutdown_lndnis(void)
>  	the_lnet.ln_shutdown = 1;	/* flag shutdown */
>  
>  	/* Unlink NIs from the global table */
> -	while (!list_empty(&the_lnet.ln_nis)) {
> -		ni = list_entry(the_lnet.ln_nis.next,
> -				struct lnet_ni, ni_list);
> -		lnet_ni_unlink_locked(ni);
> +	while (!list_empty(&the_lnet.ln_nets)) {
> +		net = list_entry(the_lnet.ln_nets.next,
> +				 struct lnet_net, net_list);
> +		while (!list_empty(&net->net_ni_list)) {
> +			ni = list_entry(net->net_ni_list.next,
> +					struct lnet_ni, ni_netlist);
> +			lnet_ni_unlink_locked(ni);
> +		}
>  	}
>  
>  	/* Drop the cached loopback NI. */
> @@ -1212,7 +1235,7 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
>  
>  	/* Make sure this new NI is unique. */
>  	lnet_net_lock(LNET_LOCK_EX);
> -	rc = lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nis);
> +	rc = lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nets);
>  	lnet_net_unlock(LNET_LOCK_EX);
>  	if (!rc) {
>  		if (lnd_type == LOLND) {
> @@ -1297,7 +1320,7 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
>  	lnet_net_lock(LNET_LOCK_EX);
>  	/* refcount for ln_nis */
>  	lnet_ni_addref_locked(ni, 0);
> -	list_add_tail(&ni->ni_list, &the_lnet.ln_nis);
> +	list_add_tail(&ni->ni_net->net_list, &the_lnet.ln_nets);
>  	if (ni->ni_cpts) {
>  		lnet_ni_addref_locked(ni, 0);
>  		list_add_tail(&ni->ni_cptlist, &the_lnet.ln_nis_cpt);
> @@ -1363,8 +1386,8 @@ lnet_startup_lndnis(struct list_head *nilist)
>  	int ni_count = 0;
>  
>  	while (!list_empty(nilist)) {
> -		ni = list_entry(nilist->next, struct lnet_ni, ni_list);
> -		list_del(&ni->ni_list);
> +		ni = list_entry(nilist->next, struct lnet_ni, ni_netlist);
> +		list_del(&ni->ni_netlist);
>  		rc = lnet_startup_lndni(ni, NULL);
>  
>  		if (rc < 0)
> @@ -1486,6 +1509,7 @@ LNetNIInit(lnet_pid_t requested_pid)
>  	struct lnet_ping_info *pinfo;
>  	struct lnet_handle_md md_handle;
>  	struct list_head net_head;
> +	struct lnet_net		*net;
>  
>  	INIT_LIST_HEAD(&net_head);
>  
> @@ -1505,8 +1529,15 @@ LNetNIInit(lnet_pid_t requested_pid)
>  		return rc;
>  	}
>  
> -	/* Add in the loopback network */
> -	if (!lnet_ni_alloc(LNET_MKNET(LOLND, 0), NULL, &net_head)) {
> +	/* create a network for Loopback network */
> +	net = lnet_net_alloc(LNET_MKNET(LOLND, 0), &net_head);
> +	if (net == NULL) {
> +		rc = -ENOMEM;
> +		goto err_empty_list;
> +	}
> +
> +	/* Add in the loopback NI */
> +	if (lnet_ni_alloc(net, NULL, NULL) == NULL) {
>  		rc = -ENOMEM;
>  		goto err_empty_list;
>  	}
> @@ -1584,11 +1615,11 @@ LNetNIInit(lnet_pid_t requested_pid)
>  	LASSERT(rc < 0);
>  	mutex_unlock(&the_lnet.ln_api_mutex);
>  	while (!list_empty(&net_head)) {
> -		struct lnet_ni *ni;
> +		struct lnet_net *net;
>  
> -		ni = list_entry(net_head.next, struct lnet_ni, ni_list);
> -		list_del_init(&ni->ni_list);
> -		lnet_ni_free(ni);
> +		net = list_entry(net_head.next, struct lnet_net, net_list);
> +		list_del_init(&net->net_list);
> +		lnet_net_free(net);
>  	}
>  	return rc;
>  }
> @@ -1714,25 +1745,83 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
>  	}
>  }
>  
> +struct lnet_ni *
> +lnet_get_ni_idx_locked(int idx)
> +{
> +	struct lnet_ni		*ni;
> +	struct lnet_net		*net;
> +
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +			if (idx-- == 0)
> +				return ni;
> +		}
> +	}
> +
> +	return NULL;
> +}
> +
> +struct lnet_ni *
> +lnet_get_next_ni_locked(struct lnet_net *mynet, struct lnet_ni *prev)
> +{
> +	struct lnet_ni		*ni;
> +	struct lnet_net		*net = mynet;
> +
> +	if (prev == NULL) {
> +		if (net == NULL)
> +			net = list_entry(the_lnet.ln_nets.next, struct lnet_net,
> +					net_list);
> +		ni = list_entry(net->net_ni_list.next, struct lnet_ni,
> +				ni_netlist);
> +
> +		return ni;
> +	}
> +
> +	if (prev->ni_netlist.next == &prev->ni_net->net_ni_list) {
> +		/* if you reached the end of the ni list and the net is
> +		 * specified, then there are no more nis in that net */
> +		if (net != NULL)
> +			return NULL;
> +
> +		/* we reached the end of this net ni list. move to the
> +		 * next net */
> +		if (prev->ni_net->net_list.next == &the_lnet.ln_nets)
> +			/* no more nets and no more NIs. */
> +			return NULL;
> +
> +		/* get the next net */
> +		net = list_entry(prev->ni_net->net_list.next, struct lnet_net,
> +				 net_list);
> +		/* get the ni on it */
> +		ni = list_entry(net->net_ni_list.next, struct lnet_ni,
> +				ni_netlist);
> +
> +		return ni;
> +	}
> +
> +	/* there are more nis left */
> +	ni = list_entry(prev->ni_netlist.next, struct lnet_ni, ni_netlist);
> +
> +	return ni;
> +}
> +
>  static int
>  lnet_get_net_config(struct lnet_ioctl_config_data *config)
>  {
>  	struct lnet_ni *ni;
> +	int cpt;
>  	int idx = config->cfg_count;
> -	int cpt, i = 0;
>  	int rc = -ENOENT;
>  
>  	cpt = lnet_net_lock_current();
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		if (i++ != idx)
> -			continue;
> +	ni = lnet_get_ni_idx_locked(idx);
>  
> +	if (ni != NULL) {
> +		rc = 0;
>  		lnet_ni_lock(ni);
>  		lnet_fill_ni_info(ni, config);
>  		lnet_ni_unlock(ni);
> -		rc = 0;
> -		break;
>  	}
>  
>  	lnet_net_unlock(cpt);
> @@ -1745,6 +1834,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
>  	char *nets = conf->cfg_config_u.cfg_net.net_intf;
>  	struct lnet_ping_info *pinfo;
>  	struct lnet_handle_md md_handle;
> +	struct lnet_net		*net;
>  	struct lnet_ni *ni;
>  	struct list_head net_head;
>  	struct lnet_remotenet *rnet;
> @@ -1752,7 +1842,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
>  
>  	INIT_LIST_HEAD(&net_head);
>  
> -	/* Create a ni structure for the network string */
> +	/* Create a net/ni structures for the network string */
>  	rc = lnet_parse_networks(&net_head, nets);
>  	if (rc <= 0)
>  		return !rc ? -EINVAL : rc;
> @@ -1760,14 +1850,14 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
>  	mutex_lock(&the_lnet.ln_api_mutex);
>  
>  	if (rc > 1) {
> -		rc = -EINVAL; /* only add one interface per call */
> +		rc = -EINVAL; /* only add one network per call */
>  		goto failed0;
>  	}
>  
> -	ni = list_entry(net_head.next, struct lnet_ni, ni_list);
> +	net = list_entry(net_head.next, struct lnet_net, net_list);
>  
>  	lnet_net_lock(LNET_LOCK_EX);
> -	rnet = lnet_find_net_locked(LNET_NIDNET(ni->ni_nid));
> +	rnet = lnet_find_net_locked(net->net_id);
>  	lnet_net_unlock(LNET_LOCK_EX);
>  	/*
>  	 * make sure that the net added doesn't invalidate the current
> @@ -1785,8 +1875,8 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
>  	if (rc)
>  		goto failed0;
>  
> -	list_del_init(&ni->ni_list);
> -
> +	list_del_init(&net->net_list);
> +	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
>  	rc = lnet_startup_lndni(ni, conf);
>  	if (rc)
>  		goto failed1;
> @@ -1812,9 +1902,9 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
>  failed0:
>  	mutex_unlock(&the_lnet.ln_api_mutex);
>  	while (!list_empty(&net_head)) {
> -		ni = list_entry(net_head.next, struct lnet_ni, ni_list);
> -		list_del_init(&ni->ni_list);
> -		lnet_ni_free(ni);
> +		net = list_entry(net_head.next, struct lnet_net, net_list);
> +		list_del_init(&net->net_list);
> +		lnet_net_free(net);
>  	}
>  	return rc;
>  }
> @@ -1849,7 +1939,7 @@ lnet_dyn_del_ni(__u32 net)
>  
>  	lnet_shutdown_lndni(ni);
>  
> -	if (!lnet_count_acceptor_nis())
> +	if (!lnet_count_acceptor_nets())
>  		lnet_acceptor_stop();
>  
>  	lnet_ping_target_update(pinfo, md_handle);
> @@ -2103,7 +2193,8 @@ EXPORT_SYMBOL(LNetDebugPeer);
>  int
>  LNetGetId(unsigned int index, struct lnet_process_id *id)
>  {
> -	struct lnet_ni *ni;
> +	struct lnet_ni	 *ni;
> +	struct lnet_net  *net;
>  	int cpt;
>  	int rc = -ENOENT;
>  
> @@ -2111,14 +2202,16 @@ LNetGetId(unsigned int index, struct lnet_process_id *id)
>  
>  	cpt = lnet_net_lock_current();
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> -		if (index--)
> -			continue;
> +	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +			if (index-- != 0)
> +				continue;
>  
> -		id->nid = ni->ni_nid;
> -		id->pid = the_lnet.ln_pid;
> -		rc = 0;
> -		break;
> +			id->nid = ni->ni_nid;
> +			id->pid = the_lnet.ln_pid;
> +			rc = 0;
> +			break;
> +		}
>  	}
>  
>  	lnet_net_unlock(cpt);
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 5646feeb433e..e83bdbec11e3 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -78,17 +78,17 @@ lnet_issep(char c)
>  	}
>  }
>  
> -int
> -lnet_net_unique(__u32 net, struct list_head *nilist)
> +bool
> +lnet_net_unique(__u32 net, struct list_head *netlist)
>  {
> -	struct lnet_ni *ni;
> +	struct lnet_net	 *net_l;
>  
> -	list_for_each_entry(ni, nilist, ni_list) {
> -		if (LNET_NIDNET(ni->ni_nid) == net)
> -			return 0;
> +	list_for_each_entry(net_l, netlist, net_list) {
> +		if (net_l->net_id == net)
> +			return false;
>  	}
>  
> -	return 1;
> +	return true;
>  }
>  
>  void
> @@ -112,41 +112,78 @@ lnet_ni_free(struct lnet_ni *ni)
>  	if (ni->ni_net_ns)
>  		put_net(ni->ni_net_ns);
>  
> -	kvfree(ni->ni_net);
>  	kfree(ni);
>  }
>  
> -struct lnet_ni *
> -lnet_ni_alloc(__u32 net_id, struct cfs_expr_list *el, struct list_head *nilist)
> +void
> +lnet_net_free(struct lnet_net *net)
>  {
> -	struct lnet_tx_queue *tq;
> +	struct list_head *tmp, *tmp2;
>  	struct lnet_ni *ni;
> -	int rc;
> -	int i;
> +
> +	/* delete any nis which have been started. */
> +	list_for_each_safe(tmp, tmp2, &net->net_ni_list) {
> +		ni = list_entry(tmp, struct lnet_ni, ni_netlist);
> +		list_del_init(&ni->ni_netlist);
> +		lnet_ni_free(ni);
> +	}
> +
> +	kfree(net);
> +}
> +
> +struct lnet_net *
> +lnet_net_alloc(__u32 net_id, struct list_head *net_list)
> +{
>  	struct lnet_net		*net;
>  
> -	if (!lnet_net_unique(net_id, nilist)) {
> -		LCONSOLE_ERROR_MSG(0x111, "Duplicate network specified: %s\n",
> -				   libcfs_net2str(net_id));
> +	if (!lnet_net_unique(net_id, net_list)) {
> +		CERROR("Duplicate net %s. Ignore\n",
> +		       libcfs_net2str(net_id));
>  		return NULL;
>  	}
>  
> -	ni = kzalloc(sizeof(*ni), GFP_NOFS);
>  	net = kzalloc(sizeof(*net), GFP_NOFS);
> -	if (!ni || !net) {
> -		kfree(ni); kfree(net);
> +	if (!net) {
>  		CERROR("Out of memory creating network %s\n",
>  		       libcfs_net2str(net_id));
>  		return NULL;
>  	}
> +
> +	INIT_LIST_HEAD(&net->net_list);
> +	INIT_LIST_HEAD(&net->net_ni_list);
> +
> +	net->net_id = net_id;
> +
>  	/* initialize global paramters to undefiend */
>  	net->net_tunables.lct_peer_timeout = -1;
>  	net->net_tunables.lct_max_tx_credits = -1;
>  	net->net_tunables.lct_peer_tx_credits = -1;
>  	net->net_tunables.lct_peer_rtr_credits = -1;
>  
> +	list_add_tail(&net->net_list, net_list);
> +
> +	return net;
> +}
> +
> +struct lnet_ni *
> +lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
> +{
> +	struct lnet_tx_queue	*tq;
> +	struct lnet_ni		*ni;
> +	int			rc;
> +	int			i;
> +
> +	ni = kzalloc(sizeof(*ni), GFP_KERNEL);
> +	if (ni == NULL) {
> +		CERROR("Out of memory creating network interface %s%s\n",
> +		       libcfs_net2str(net->net_id),
> +		       (iface != NULL) ? iface : "");
> +		return NULL;
> +	}
> +
>  	spin_lock_init(&ni->ni_lock);
>  	INIT_LIST_HEAD(&ni->ni_cptlist);
> +	INIT_LIST_HEAD(&ni->ni_netlist);
>  	ni->ni_refs = cfs_percpt_alloc(lnet_cpt_table(),
>  				       sizeof(*ni->ni_refs[0]));
>  	if (!ni->ni_refs)
> @@ -166,8 +203,9 @@ lnet_ni_alloc(__u32 net_id, struct cfs_expr_list *el, struct list_head *nilist)
>  	} else {
>  		rc = cfs_expr_list_values(el, LNET_CPT_NUMBER, &ni->ni_cpts);
>  		if (rc <= 0) {
> -			CERROR("Failed to set CPTs for NI %s: %d\n",
> -			       libcfs_net2str(net_id), rc);
> +			CERROR("Failed to set CPTs for NI %s(%s): %d\n",
> +			       libcfs_net2str(net->net_id),
> +			       (iface != NULL) ? iface : "", rc);
>  			goto failed;
>  		}
>  
> @@ -182,7 +220,7 @@ lnet_ni_alloc(__u32 net_id, struct cfs_expr_list *el, struct list_head *nilist)
>  
>  	ni->ni_net = net;
>  	/* LND will fill in the address part of the NID */
> -	ni->ni_nid = LNET_MKNID(net_id, 0);
> +	ni->ni_nid = LNET_MKNID(net->net_id, 0);
>  
>  	/* Store net namespace in which current ni is being created */
>  	if (current->nsproxy->net_ns)
> @@ -191,22 +229,24 @@ lnet_ni_alloc(__u32 net_id, struct cfs_expr_list *el, struct list_head *nilist)
>  		ni->ni_net_ns = NULL;
>  
>  	ni->ni_last_alive = ktime_get_real_seconds();
> -	list_add_tail(&ni->ni_list, nilist);
> +	list_add_tail(&ni->ni_netlist, &net->net_ni_list);
> +
>  	return ni;
> - failed:
> +failed:
>  	lnet_ni_free(ni);
>  	return NULL;
>  }
>  
>  int
> -lnet_parse_networks(struct list_head *nilist, char *networks)
> +lnet_parse_networks(struct list_head *netlist, char *networks)
>  {
>  	struct cfs_expr_list *el = NULL;
>  	char *tokens;
>  	char *str;
>  	char *tmp;
> -	struct lnet_ni *ni;
> -	__u32 net;
> +	struct lnet_net *net;
> +	struct lnet_ni *ni = NULL;
> +	__u32 net_id;
>  	int nnets = 0;
>  	struct list_head *temp_node;
>  
> @@ -275,18 +315,21 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
>  
>  			if (comma)
>  				*comma++ = 0;
> -			net = libcfs_str2net(strim(str));
> +			net_id = libcfs_str2net(strim(str));
>  
> -			if (net == LNET_NIDNET(LNET_NID_ANY)) {
> +			if (net_id == LNET_NIDNET(LNET_NID_ANY)) {
>  				LCONSOLE_ERROR_MSG(0x113,
>  						   "Unrecognised network type\n");
>  				tmp = str;
>  				goto failed_syntax;
>  			}
>  
> -			if (LNET_NETTYP(net) != LOLND && /* LO is implicit */
> -			    !lnet_ni_alloc(net, el, nilist))
> -				goto failed;
> +			if (LNET_NETTYP(net_id) != LOLND) { /* LO is implicit */
> +				net = lnet_net_alloc(net_id, netlist);
> +				if (!net ||
> +				    !lnet_ni_alloc(net, el, NULL))
> +					goto failed;
> +			}
>  
>  			if (el) {
>  				cfs_expr_list_free(el);
> @@ -298,14 +341,21 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
>  		}
>  
>  		*bracket = 0;
> -		net = libcfs_str2net(strim(str));
> -		if (net == LNET_NIDNET(LNET_NID_ANY)) {
> +		net_id = libcfs_str2net(strim(str));
> +		if (net_id == LNET_NIDNET(LNET_NID_ANY)) {
>  			tmp = str;
>  			goto failed_syntax;
>  		}
>  
> -		ni = lnet_ni_alloc(net, el, nilist);
> -		if (!ni)
> +		/* always allocate a net, since we will eventually add an
> +		 * interface to it, or we will fail, in which case we'll
> +		 * just delete it */
> +		net = lnet_net_alloc(net_id, netlist);
> +		if (IS_ERR_OR_NULL(net))
> +			goto failed;
> +
> +		ni = lnet_ni_alloc(net, el, NULL);
> +		if (IS_ERR_OR_NULL(ni))
>  			goto failed;
>  
>  		if (el) {
> @@ -337,7 +387,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
>  			if (niface == LNET_MAX_INTERFACES) {
>  				LCONSOLE_ERROR_MSG(0x115,
>  						   "Too many interfaces for net %s\n",
> -						   libcfs_net2str(net));
> +						   libcfs_net2str(net_id));
>  				goto failed;
>  			}
>  
> @@ -378,7 +428,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
>  		}
>  	}
>  
> -	list_for_each(temp_node, nilist)
> +	list_for_each(temp_node, netlist)
>  		nnets++;
>  
>  	kfree(tokens);
> @@ -387,11 +437,12 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
>   failed_syntax:
>  	lnet_syntax("networks", networks, (int)(tmp - tokens), strlen(tmp));
>   failed:
> -	while (!list_empty(nilist)) {
> -		ni = list_entry(nilist->next, struct lnet_ni, ni_list);
> +	/* free the net list and all the nis on each net */
> +	while (!list_empty(netlist)) {
> +		net = list_entry(netlist->next, struct lnet_net, net_list);
>  
> -		list_del(&ni->ni_list);
> -		lnet_ni_free(ni);
> +		list_del_init(&net->net_list);
> +		lnet_net_free(net);
>  	}
>  
>  	if (el)
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 1bf12af87a20..1c874025fa74 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -2289,7 +2289,7 @@ EXPORT_SYMBOL(LNetGet);
>  int
>  LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
>  {
> -	struct lnet_ni *ni;
> +	struct lnet_ni *ni = NULL;
>  	struct lnet_remotenet *rnet;
>  	__u32 dstnet = LNET_NIDNET(dstnid);
>  	int hops;
> @@ -2307,9 +2307,9 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
>  
>  	cpt = lnet_net_lock_current();
>  
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> +	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
>  		if (ni->ni_nid == dstnid) {
> -			if (srcnidp)
> +			if (srcnidp != NULL)
>  				*srcnidp = dstnid;
>  			if (orderp) {
>  				if (LNET_NETTYP(LNET_NIDNET(dstnid)) == LOLND)
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 0c0ec0b27982..135dfe793b0b 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -245,13 +245,10 @@ static void lnet_shuffle_seed(void)
>  	if (seeded)
>  		return;
>  
> -	/*
> -	 * Nodes with small feet have little entropy
> -	 * the NID for this node gives the most entropy in the low bits
> -	 */
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> +	/* Nodes with small feet have little entropy
> +	 * the NID for this node gives the most entropy in the low bits */
> +	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
>  		__u32 lnd_type, seed;
> -
>  		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
>  		if (lnd_type != LOLND) {
>  			seed = (LNET_NIDADDR(ni->ni_nid) | lnd_type);
> @@ -807,8 +804,8 @@ lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net)
>  static void
>  lnet_update_ni_status_locked(void)
>  {
> -	struct lnet_ni *ni;
> -	time64_t now;
> +	struct lnet_ni *ni = NULL;
> +	time64_t	now;
>  	time64_t timeout;
>  
>  	LASSERT(the_lnet.ln_routing);
> @@ -817,7 +814,7 @@ lnet_update_ni_status_locked(void)
>  		  max(live_router_check_interval, dead_router_check_interval);
>  
>  	now = ktime_get_real_seconds();
> -	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
> +	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
>  		if (ni->ni_net->net_lnd->lnd_type == LOLND)
>  			continue;
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index f3ccd6a2b70e..2a366e9a8627 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -641,26 +641,12 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
>  			      "rtr", "max", "tx", "min");
>  		LASSERT(tmpstr + tmpsiz - s > 0);
>  	} else {
> -		struct list_head *n;
>  		struct lnet_ni *ni = NULL;
>  		int skip = *ppos - 1;
>  
>  		lnet_net_lock(0);
>  
> -		n = the_lnet.ln_nis.next;
> -
> -		while (n != &the_lnet.ln_nis) {
> -			struct lnet_ni *a_ni;
> -
> -			a_ni = list_entry(n, struct lnet_ni, ni_list);
> -			if (!skip) {
> -				ni = a_ni;
> -				break;
> -			}
> -
> -			skip--;
> -			n = n->next;
> -		}
> +		ni = lnet_get_ni_idx_locked(skip);
>  
>  		if (ni) {
>  			struct lnet_tx_queue *tq;
> 
> 
> 
