From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:38:18 +0000
Subject: [lustre-devel] [PATCH 27/34] lnet: make it possible to add a
 new interface to a network
In-Reply-To: <153628137234.8267.14872362382875902424.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137234.8267.14872362382875902424.stgit@noble>
Message-ID: <E6466657-A36A-4BBF-8515-5B199D73204D@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    lnet_startup_lndnet() is enhanced to cope if the net already
    exists.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 +
     drivers/staging/lustre/lnet/lnet/api-ni.c          |   69 +++++++++++++++-----
     drivers/staging/lustre/lnet/lnet/config.c          |   12 ++-
     3 files changed, 61 insertions(+), 23 deletions(-)
    
    diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    index 6401d9a37b23..905213fc16c7 100644
    --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    @@ -630,7 +630,8 @@ void lnet_swap_pinginfo(struct lnet_ping_info *info);
     int lnet_parse_ip2nets(char **networksp, char *ip2nets);
     int lnet_parse_routes(char *route_str, int *im_a_router);
     int lnet_parse_networks(struct list_head *nilist, char *networks);
    -bool lnet_net_unique(__u32 net, struct list_head *nilist);
    +bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
    +		     struct lnet_net **net);
     
     int lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt);
     struct lnet_peer *lnet_find_peer_locked(struct lnet_peer_table *ptable,
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 0dfd3004f735..042ab0d9e318 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1298,14 +1298,9 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     		goto failed0;
     	}
     
    -	lnet_net_lock(LNET_LOCK_EX);
    -	/* refcount for ln_nis */
    -	lnet_ni_addref_locked(ni, 0);
    -	list_add_tail(&ni->ni_net->net_list, &the_lnet.ln_nets);
    -	lnet_net_unlock(LNET_LOCK_EX);
    -
     	ni->ni_state = LNET_NI_STATE_ACTIVE;
     
    +	/* We keep a reference on the loopback net through the loopback NI */
     	if (net->net_lnd->lnd_type == LOLND) {
     		lnet_ni_addref(ni);
     		LASSERT(!the_lnet.ln_loni);
    @@ -1360,6 +1355,7 @@ static int
     lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     {
     	struct lnet_ni		*ni;
    +	struct lnet_net		*net_l = NULL;
     	struct list_head	local_ni_list;
     	int			rc;
     	int			ni_count = 0;
    @@ -1368,8 +1364,14 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     
     	INIT_LIST_HEAD(&local_ni_list);
     
    -	/* Make sure this new NI is unique. */
    -	if (lnet_net_unique(net->net_id, &the_lnet.ln_nets)) {
    +	/*
    +	 * make sure that this net is unique. If it isn't then
    +	 * we are adding interfaces to an already existing network, and
    +	 * 'net' is just a convenient way to pass in the list.
    +	 * if it is unique we need to find the LND and load it if
    +	 * necessary.
    +	 */
    +	if (lnet_net_unique(net->net_id, &the_lnet.ln_nets, &net_l)) {
     		lnd_type = LNET_NETTYP(net->net_id);
     
     		LASSERT(libcfs_isknown_lnd(lnd_type));
    @@ -1400,23 +1402,41 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     		net->net_lnd = lnd;
     
     		mutex_unlock(&the_lnet.ln_lnd_mutex);
    -	} else {
    -		if (lnd_type == LOLND) {
    -			lnet_net_free(net);
    -			return 0;
    -		}
     
    -		CERROR("Net %s is not unique\n",
    -		       libcfs_net2str(net->net_id));
    -		rc = -EEXIST;
    -		goto failed0;
    +		net_l = net;
     	}
     
    +	/*
    +	 * net_l: if the network being added is unique then net_l
    +	 *        will point to that network
    +	 *        if the network being added is not unique then
    +	 *        net_l points to the existing network.
    +	 *
    +	 * When we enter the loop below, we'll pick NIs off he
    +	 * network beign added and start them up, then add them to
    +	 * a local ni list. Once we've successfully started all
    +	 * the NIs then we join the local NI list (of started up
    +	 * networks) with the net_l->net_ni_list, which should
    +	 * point to the correct network to add the new ni list to
    +	 *
    +	 * If any of the new NIs fail to start up, then we want to
    +	 * iterate through the local ni list, which should include
    +	 * any NIs which were successfully started up, and shut
    +	 * them down.
    +	 *
    +	 * After than we want to delete the network being added,
    +	 * to avoid a memory leak.
    +	 */
    +
     	while (!list_empty(&net->net_ni_added)) {
     		ni = list_entry(net->net_ni_added.next, struct lnet_ni,
     				ni_netlist);
     		list_del_init(&ni->ni_netlist);
     
    +		/* adjust the pointer the parent network, just in case it
    +		 * the net is a duplicate */
    +		ni->ni_net = net_l;
    +
     		rc = lnet_startup_lndni(ni, tun);
     
     		if (rc < 0)
    @@ -1427,9 +1447,22 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     
     		ni_count++;
     	}
    +
     	lnet_net_lock(LNET_LOCK_EX);
    -	list_splice_tail(&local_ni_list, &net->net_ni_list);
    +	list_splice_tail(&local_ni_list, &net_l->net_ni_list);
     	lnet_net_unlock(LNET_LOCK_EX);
    +
    +	/* if the network is not unique then we don't want to keep
    +	 * it around after we're done. Free it. Otherwise add that
    +	 * net to the global the_lnet.ln_nets */
    +	if (net_l != net && net_l != NULL) {
    +		lnet_net_free(net);
    +	} else {
    +		lnet_net_lock(LNET_LOCK_EX);
    +		list_add_tail(&net->net_list, &the_lnet.ln_nets);
    +		lnet_net_unlock(LNET_LOCK_EX);
    +	}
    +
     	return ni_count;
     
     failed1:
    diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
    index f886dcfc6d6e..fcae50676422 100644
    --- a/drivers/staging/lustre/lnet/lnet/config.c
    +++ b/drivers/staging/lustre/lnet/lnet/config.c
    @@ -79,13 +79,17 @@ lnet_issep(char c)
     }
     
     bool
    -lnet_net_unique(__u32 net, struct list_head *netlist)
    +lnet_net_unique(__u32 net_id, struct list_head *netlist,
    +		struct lnet_net **net)
     {
    -	struct lnet_net	 *net_l;
    +	struct lnet_net  *net_l;
     
     	list_for_each_entry(net_l, netlist, net_list) {
    -		if (net_l->net_id == net)
    +		if (net_l->net_id == net_id) {
    +			if (net != NULL)
    +				*net = net_l;
     			return false;
    +		}
     	}
     
     	return true;
    @@ -309,7 +313,7 @@ lnet_net_alloc(__u32 net_id, struct list_head *net_list)
     {
     	struct lnet_net		*net;
     
    -	if (!lnet_net_unique(net_id, net_list)) {
    +	if (!lnet_net_unique(net_id, net_list, NULL)) {
     		CERROR("Duplicate net %s. Ignore\n",
     		       libcfs_net2str(net_id));
     		return NULL;
    
    
    
