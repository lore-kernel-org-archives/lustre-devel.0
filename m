From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 03:30:58 +0000
Subject: [lustre-devel] [PATCH 11/34] lnet: pass tun to
 lnet_startup_lndni, instead of full conf
In-Reply-To: <153628137168.8267.1167942220741712684.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137168.8267.1167942220741712684.stgit@noble>
Message-ID: <83C2283B-AFA7-47D6-925D-D2E4ECD95FF0@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With the suggested commit message from Amir:

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:53 PM, "NeilBrown" <neilb@suse.com> wrote:

    I don't understand parts of this change.
    Particularly the removal for
           /* If given some LND tunable parameters, parse those now to
            * override the values in the NI structure. */
    
    isn't clear to me.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |   41 ++++++++---------------------
     1 file changed, 12 insertions(+), 29 deletions(-)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 6e0b8310574d..53ecfd700db3 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1240,10 +1240,8 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
     }
     
     static int
    -lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
    +lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
     {
    -	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
    -	struct lnet_lnd_tunables *tun = NULL;
     	int rc = -EINVAL;
     	int lnd_type;
     	struct lnet_lnd *lnd;
    @@ -1296,36 +1294,12 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
     
     	ni->ni_net->net_lnd = lnd;
     
    -	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf)) {
    -		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
    -		tun = &lnd_tunables->lt_tun;
    -	}
    -
     	if (tun) {
     		memcpy(&ni->ni_lnd_tunables, tun,
     		       sizeof(*tun));
     		ni->ni_lnd_tunables_set = true;
     	}
     
    -	/*
    -	 * If given some LND tunable parameters, parse those now to
    -	 * override the values in the NI structure.
    -	 */
    -	if (conf) {
    -		if (conf->cfg_config_u.cfg_net.net_peer_rtr_credits >= 0)
    -			ni->ni_net->net_tunables.lct_peer_rtr_credits =
    -				conf->cfg_config_u.cfg_net.net_peer_rtr_credits;
    -		if (conf->cfg_config_u.cfg_net.net_peer_timeout >= 0)
    -			ni->ni_net->net_tunables.lct_peer_timeout =
    -				conf->cfg_config_u.cfg_net.net_peer_timeout;
    -		if (conf->cfg_config_u.cfg_net.net_peer_tx_credits != -1)
    -			ni->ni_net->net_tunables.lct_peer_tx_credits =
    -				conf->cfg_config_u.cfg_net.net_peer_tx_credits;
    -		if (conf->cfg_config_u.cfg_net.net_max_tx_credits >= 0)
    -			ni->ni_net->net_tunables.lct_max_tx_credits =
    -				conf->cfg_config_u.cfg_net.net_max_tx_credits;
    -	}
    -
     	rc = lnd->lnd_startup(ni);
     
     	mutex_unlock(&the_lnet.ln_lnd_mutex);
    @@ -1861,9 +1835,13 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     	struct list_head net_head;
     	struct lnet_remotenet *rnet;
     	int rc;
    +	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
     
     	INIT_LIST_HEAD(&net_head);
     
    +	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf))
    +		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
    +
     	/* Create a net/ni structures for the network string */
     	rc = lnet_parse_networks(&net_head, nets);
     	if (rc <= 0)
    @@ -1898,9 +1876,14 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     		goto failed0;
     
     	list_del_init(&net->net_list);
    +	if (lnd_tunables)
    +		memcpy(&net->net_tunables,
    +		       &lnd_tunables->lt_cmn, sizeof(lnd_tunables->lt_cmn));
    +
     	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
    -	rc = lnet_startup_lndni(ni, conf);
    -	if (rc)
    +	rc = lnet_startup_lndni(ni, (lnd_tunables ?
    +				     &lnd_tunables->lt_tun : NULL));
    +	if (rc < 0)
     		goto failed1;
     
     	if (ni->ni_net->net_lnd->lnd_accept) {
    
    
    
