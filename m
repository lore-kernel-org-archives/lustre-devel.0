From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:39:56 +0000
Subject: [lustre-devel] [PATCH 28/34] lnet: add checks to ensure network
 interface names are unique.
In-Reply-To: <153628137237.8267.13304938702171788855.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137237.8267.13304938702171788855.stgit@noble>
Message-ID: <3831B6C9-AC8F-433F-82FB-B79BCBAC616F@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:55 PM, "NeilBrown" <neilb@suse.com> wrote:

    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
     drivers/staging/lustre/lnet/lnet/api-ni.c          |    8 ++++++
     drivers/staging/lustre/lnet/lnet/config.c          |   25 ++++++++++++++++++++
     3 files changed, 34 insertions(+)
    
    diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    index 905213fc16c7..ef551b571935 100644
    --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    @@ -632,6 +632,7 @@ int lnet_parse_routes(char *route_str, int *im_a_router);
     int lnet_parse_networks(struct list_head *nilist, char *networks);
     bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
     		     struct lnet_net **net);
    +bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
     
     int lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt);
     struct lnet_peer *lnet_find_peer_locked(struct lnet_peer_table *ptable,
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index 042ab0d9e318..3f6f5ead8a03 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -1433,6 +1433,14 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     				ni_netlist);
     		list_del_init(&ni->ni_netlist);
     
    +		/* make sure that the the NI we're about to start
    +		 * up is actually unique. if it's not fail. */
    +		if (!lnet_ni_unique_net(&net_l->net_ni_list,
    +					ni->ni_interfaces[0])) {
    +			rc = -EINVAL;
    +			goto failed1;
    +		}
    +
     		/* adjust the pointer the parent network, just in case it
     		 * the net is a duplicate */
     		ni->ni_net = net_l;
    diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
    index fcae50676422..11d6dbc80507 100644
    --- a/drivers/staging/lustre/lnet/lnet/config.c
    +++ b/drivers/staging/lustre/lnet/lnet/config.c
    @@ -95,6 +95,25 @@ lnet_net_unique(__u32 net_id, struct list_head *netlist,
     	return true;
     }
     
    +/* check that the NI is unique within the list of NIs already added to
    + * a network */
    +bool
    +lnet_ni_unique_net(struct list_head *nilist, char *iface)
    +{
    +	struct list_head *tmp;
    +	struct lnet_ni *ni;
    +
    +	list_for_each(tmp, nilist) {
    +		ni = list_entry(tmp, struct lnet_ni, ni_netlist);
    +
    +		if (ni->ni_interfaces[0] != NULL &&
    +		    strncmp(ni->ni_interfaces[0], iface, strlen(iface)) == 0)
    +			return false;
    +	}
    +
    +	return true;
    +}
    +
     static bool
     in_array(__u32 *array, __u32 size, __u32 value)
     {
    @@ -352,6 +371,12 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
     	int			rc;
     	int			i;
     
    +	if (iface != NULL)
    +		/* make sure that this NI is unique in the net it's
    +		 * being added to */
    +		if (!lnet_ni_unique_net(&net->net_ni_added, iface))
    +			return NULL;
    +
     	ni = kzalloc(sizeof(*ni), GFP_KERNEL);
     	if (ni == NULL) {
     		CERROR("Out of memory creating network interface %s%s\n",
    
    
    
