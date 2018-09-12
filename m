From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:47:03 +0000
Subject: [lustre-devel] [PATCH 29/34] lnet: track tunables in
 lnet_startup_lndnet()
In-Reply-To: <153628137241.8267.17639366442733480713.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137241.8267.17639366442733480713.stgit@noble>
Message-ID: <7B17D070-1A0A-4609-A58E-8D0785879D3F@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Amir: You need to comment on this one.

It looks to me that it starts off by making a copy of three tunables to see if the user has set them specific to the NET.  Then, if the LND changes them, it changes them back to what the user set.  What I don't get: why would the LND change the values if they are not -1?  

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    Not really sure what this is yet.
    
    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lnet/lnet/api-ni.c |   24 ++++++++++++++++++++++++
     1 file changed, 24 insertions(+)
    
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 3f6f5ead8a03..f4efb48c4cf3 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1361,6 +1361,12 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     	int			ni_count = 0;
     	__u32			lnd_type;
     	struct lnet_lnd		*lnd;
    +	int			peer_timeout =
    +		net->net_tunables.lct_peer_timeout;
    +	int			maxtxcredits =
    +		net->net_tunables.lct_max_tx_credits;
    +	int			peerrtrcredits =
    +		net->net_tunables.lct_peer_rtr_credits;
     
     	INIT_LIST_HEAD(&local_ni_list);
     
    @@ -1447,6 +1453,9 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     
     		rc = lnet_startup_lndni(ni, tun);
     
    +		LASSERT(ni->ni_net->net_tunables.lct_peer_timeout <= 0 ||
    +			ni->ni_net->net_lnd->lnd_query != NULL);
    +
     		if (rc < 0)
     			goto failed1;
     
    @@ -1464,8 +1473,23 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     	 * it around after we're done. Free it. Otherwise add that
     	 * net to the global the_lnet.ln_nets */
     	if (net_l != net && net_l != NULL) {
    +		/*
    +		 * TODO - note. currently the tunables can not be updated
    +		 * once added
    +		 */
     		lnet_net_free(net);
     	} else {
    +		/*
    +		 * restore tunables after it has been overwitten by the
    +		 * lnd
    +		 */
    +		if (peer_timeout != -1)
    +			net->net_tunables.lct_peer_timeout = peer_timeout;
    +		if (maxtxcredits != -1)
    +			net->net_tunables.lct_max_tx_credits = maxtxcredits;
    +		if (peerrtrcredits != -1)
    +			net->net_tunables.lct_peer_rtr_credits = peerrtrcredits;
    +
     		lnet_net_lock(LNET_LOCK_EX);
     		list_add_tail(&net->net_list, &the_lnet.ln_nets);
     		lnet_net_unlock(LNET_LOCK_EX);
    
    
    
