From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 03:39:16 +0000
Subject: [lustre-devel] [PATCH 12/34] lnet: split lnet_startup_lndni
In-Reply-To: <153628137171.8267.13510813931908233567.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137171.8267.13510813931908233567.stgit@noble>
Message-ID: <9EA5BEB2-C7A3-472D-A396-A5C728E403D8@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:53 PM, "NeilBrown" <neilb@suse.com> wrote:

    Split into
      lnet_startup_lndnet
    which starts all nis in a net, and
      lnet_startup_lndni
    which starts an individual ni.
    
    lnet_startup_lndni()  returns 0 on success, or -ve error.
    lnet_startup_lndnis() returned the count of interfaces started.
    
    The new lnet_startup_lndnet() returns the count of started interfaces,
    
    This requires adding lnet_shutdown_lndnet() to handle errors
    in lnet_dyn_add_ni(), which now uses the new lnet_startup_lndnet().
    
    We now drop the ln_lnd_mutex near the end of lnet_startup_lndnet(),
    and re-claim it for each lnet_startup_lndni().
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |  142 +++++++++++++++++++++++------
     1 file changed, 111 insertions(+), 31 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 53ecfd700db3..8afddf11b5e2 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1239,32 +1239,61 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
     	lnet_net_unlock(LNET_LOCK_EX);
     }
     
    +static void
    +lnet_shutdown_lndnet(struct lnet_net *net)
    +{
    +	struct lnet_ni *ni;
    +
    +	lnet_net_lock(LNET_LOCK_EX);
    +
    +	list_del_init(&net->net_list);
    +
    +	while (!list_empty(&net->net_ni_list)) {
    +		ni = list_entry(net->net_ni_list.next,
    +				struct lnet_ni, ni_netlist);
    +		lnet_net_unlock(LNET_LOCK_EX);
    +		lnet_shutdown_lndni(ni);
    +		lnet_net_lock(LNET_LOCK_EX);
    +	}
    +
    +	/*
    +	 * decrement ref count on lnd only when the entire network goes
    +	 * away
    +	 */
    +	net->net_lnd->lnd_refcount--;
    +
    +	lnet_net_unlock(LNET_LOCK_EX);
    +
    +	lnet_net_free(net);
    +}
    +
     static int
    -lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
    +lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun);
    +
    +static int
    +lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     {
    -	int rc = -EINVAL;
    -	int lnd_type;
    -	struct lnet_lnd *lnd;
    -	struct lnet_tx_queue *tq;
    -	int i;
    -	u32 seed;
    +	struct lnet_ni		*ni;
    +	__u32			lnd_type;
    +	struct lnet_lnd		*lnd;
    +	int rc;
     
    -	lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
    +	lnd_type = LNET_NETTYP(net->net_id);
     
     	LASSERT(libcfs_isknown_lnd(lnd_type));
     
     	/* Make sure this new NI is unique. */
     	lnet_net_lock(LNET_LOCK_EX);
    -	rc = lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nets);
    +	rc = lnet_net_unique(net->net_id, &the_lnet.ln_nets);
     	lnet_net_unlock(LNET_LOCK_EX);
     	if (!rc) {
     		if (lnd_type == LOLND) {
    -			lnet_ni_free(ni);
    +			lnet_net_free(net);
     			return 0;
     		}
     
     		CERROR("Net %s is not unique\n",
    -		       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
    +		       libcfs_net2str(net->net_id));
     		rc = -EEXIST;
     		goto failed0;
     	}
    @@ -1291,8 +1320,32 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     	lnet_net_lock(LNET_LOCK_EX);
     	lnd->lnd_refcount++;
     	lnet_net_unlock(LNET_LOCK_EX);
    +	net->net_lnd = lnd;
    +	mutex_unlock(&the_lnet.ln_lnd_mutex);
     
    -	ni->ni_net->net_lnd = lnd;
    +	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
    +
    +	rc = lnet_startup_lndni(ni, tun);
    +	if (rc < 0)
    +		return rc;
    +	return 1;
    +
    +failed0:
    +	lnet_net_free(net);
    +
    +	return rc;
    +}
    +
    +static int
    +lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
    +{
    +	int			rc = -EINVAL;
    +	struct lnet_tx_queue	*tq;
    +	int			i;
    +	struct lnet_net		*net = ni->ni_net;
    +	u32			seed;
    +
    +	mutex_lock(&the_lnet.ln_lnd_mutex);
     
     	if (tun) {
     		memcpy(&ni->ni_lnd_tunables, tun,
    @@ -1300,15 +1353,15 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     		ni->ni_lnd_tunables_set = true;
     	}
     
    -	rc = lnd->lnd_startup(ni);
    +	rc = net->net_lnd->lnd_startup(ni);
     
     	mutex_unlock(&the_lnet.ln_lnd_mutex);
     
     	if (rc) {
     		LCONSOLE_ERROR_MSG(0x105, "Error %d starting up LNI %s\n",
    -				   rc, libcfs_lnd2str(lnd->lnd_type));
    +				   rc, libcfs_lnd2str(net->net_lnd->lnd_type));
     		lnet_net_lock(LNET_LOCK_EX);
    -		lnd->lnd_refcount--;
    +		net->net_lnd->lnd_refcount--;
     		lnet_net_unlock(LNET_LOCK_EX);
     		goto failed0;
     	}
    @@ -1324,7 +1377,7 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     
     	lnet_net_unlock(LNET_LOCK_EX);
     
    -	if (lnd->lnd_type == LOLND) {
    +	if (net->net_lnd->lnd_type == LOLND) {
     		lnet_ni_addref(ni);
     		LASSERT(!the_lnet.ln_loni);
     		the_lnet.ln_loni = ni;
    @@ -1338,7 +1391,7 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     	if (!ni->ni_net->net_tunables.lct_peer_tx_credits ||
     	    !ni->ni_net->net_tunables.lct_max_tx_credits) {
     		LCONSOLE_ERROR_MSG(0x107, "LNI %s has no %scredits\n",
    -				   libcfs_lnd2str(lnd->lnd_type),
    +				   libcfs_lnd2str(net->net_lnd->lnd_type),
     				   !ni->ni_net->net_tunables.lct_peer_tx_credits ?
     				   "" : "per-peer ");
     		/*
    @@ -1375,21 +1428,22 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     }
     
     static int
    -lnet_startup_lndnis(struct list_head *nilist)
    +lnet_startup_lndnets(struct list_head *netlist)
     {
    -	struct lnet_ni *ni;
    +	struct lnet_net *net;
     	int rc;
     	int ni_count = 0;
     
    -	while (!list_empty(nilist)) {
    -		ni = list_entry(nilist->next, struct lnet_ni, ni_netlist);
    -		list_del(&ni->ni_netlist);
    -		rc = lnet_startup_lndni(ni, NULL);
    +	while (!list_empty(netlist)) {
    +		net = list_entry(netlist->next, struct lnet_net, net_list);
    +		list_del_init(&net->net_list);
    +
    +		rc = lnet_startup_lndnet(net, NULL);
     
     		if (rc < 0)
     			goto failed;
     
    -		ni_count++;
    +		ni_count += rc;
     	}
     
     	return ni_count;
    @@ -1552,7 +1606,7 @@ LNetNIInit(lnet_pid_t requested_pid)
     			goto err_empty_list;
     	}
     
    -	ni_count = lnet_startup_lndnis(&net_head);
    +	ni_count = lnet_startup_lndnets(&net_head);
     	if (ni_count < 0) {
     		rc = ni_count;
     		goto err_empty_list;
    @@ -1831,10 +1885,11 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     	struct lnet_ping_info *pinfo;
     	struct lnet_handle_md md_handle;
     	struct lnet_net		*net;
    -	struct lnet_ni *ni;
     	struct list_head net_head;
     	struct lnet_remotenet *rnet;
     	int rc;
    +	int			num_acceptor_nets;
    +	__u32			net_type;
     	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
     
     	INIT_LIST_HEAD(&net_head);
    @@ -1876,22 +1931,47 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     		goto failed0;
     
     	list_del_init(&net->net_list);
    +
     	if (lnd_tunables)
     		memcpy(&net->net_tunables,
     		       &lnd_tunables->lt_cmn, sizeof(lnd_tunables->lt_cmn));
     
    -	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
    -	rc = lnet_startup_lndni(ni, (lnd_tunables ?
    +	/*
    +	 * before starting this network get a count of the current TCP
    +	 * networks which require the acceptor thread running. If that
    +	 * count is == 0 before we start up this network, then we'd want to
    +	 * start up the acceptor thread after starting up this network
    +	 */
    +	num_acceptor_nets = lnet_count_acceptor_nets();
    +
    +	/*
    +	 * lnd_startup_lndnet() can deallocate 'net' even if it it returns
    +	 * success, because we endded up adding interfaces to an existing
    +	 * network. So grab the net_type now
    +	 */
    +	net_type = LNET_NETTYP(net->net_id);
    +
    +	rc = lnet_startup_lndnet(net, (lnd_tunables ?
     				     &lnd_tunables->lt_tun : NULL));
     	if (rc < 0)
     		goto failed1;
     
    -	if (ni->ni_net->net_lnd->lnd_accept) {
    +	/*
    +	 * Start the acceptor thread if this is the first network
    +	 * being added that requires the thread.
    +	 */
    +	if (net_type == SOCKLND && num_acceptor_nets == 0) {
     		rc = lnet_acceptor_start();
     		if (rc < 0) {
    -			/* shutdown the ni that we just started */
    +			/* shutdown the net that we just started */
     			CERROR("Failed to start up acceptor thread\n");
    -			lnet_shutdown_lndni(ni);
    +			/*
    +			 * Note that if we needed to start the acceptor
    +			 * thread, then 'net' must have been the first TCP
    +			 * network, therefore was unique, and therefore
    +			 * wasn't deallocated by lnet_startup_lndnet()
    +			 */
    +			lnet_shutdown_lndnet(net);
     			goto failed1;
     		}
     	}
    
    
    
