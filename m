From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 12 Sep 2018 04:54:49 +0000
Subject: [lustre-devel] [PATCH 34/34] lnet: introduce use_tcp_bonding
 mod param
In-Reply-To: <153628137259.8267.2306617574801795911.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137259.8267.2306617574801795911.stgit@noble>
Message-ID: <4DA7E7FA-7658-40E5-986D-313DF02B21DC@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso@me.com>

Doug

?On 9/6/18, 5:56 PM, "NeilBrown" <neilb@suse.com> wrote:

    This is part of
        8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
           LU-7734 lnet: Multi-Rail local NI split
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 +
     drivers/staging/lustre/lnet/lnet/api-ni.c          |   22 ++++++++-
     drivers/staging/lustre/lnet/lnet/config.c          |   50 ++++++++++++++++----
     3 files changed, 61 insertions(+), 14 deletions(-)
    
    diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    index ef551b571935..5ee770cd7a5f 100644
    --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
    @@ -629,7 +629,8 @@ void lnet_swap_pinginfo(struct lnet_ping_info *info);
     
     int lnet_parse_ip2nets(char **networksp, char *ip2nets);
     int lnet_parse_routes(char *route_str, int *im_a_router);
    -int lnet_parse_networks(struct list_head *nilist, char *networks);
    +int lnet_parse_networks(struct list_head *nilist, char *networks,
    +			bool use_tcp_bonding);
     bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
     		     struct lnet_net **net);
     bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
    diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
    index ff5149da2d79..8ff386992c99 100644
    --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
    +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
    @@ -59,6 +59,11 @@ static int rnet_htable_size = LNET_REMOTE_NETS_HASH_DEFAULT;
     module_param(rnet_htable_size, int, 0444);
     MODULE_PARM_DESC(rnet_htable_size, "size of remote network hash table");
     
    +static int use_tcp_bonding = false;
    +module_param(use_tcp_bonding, int, 0444);
    +MODULE_PARM_DESC(use_tcp_bonding,
    +		 "Set to 1 to use socklnd bonding. 0 to use Multi-Rail");
    +
     static int lnet_ping(struct lnet_process_id id, signed long timeout,
     		     struct lnet_process_id __user *ids, int n_ids);
     
    @@ -1446,6 +1451,18 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
     	 * to avoid a memory leak.
     	 */
     
    +	/*
    +	 * When a network uses TCP bonding then all its interfaces
    +	 * must be specified when the network is first defined: the
    +	 * TCP bonding code doesn't allow for interfaces to be added
    +	 * or removed.
    +	 */
    +	if (net_l != net && net_l != NULL && use_tcp_bonding &&
    +	    LNET_NETTYP(net_l->net_id) == SOCKLND) {
    +		rc = -EINVAL;
    +		goto failed0;
    +	}
    +
     	while (!list_empty(&net->net_ni_added)) {
     		ni = list_entry(net->net_ni_added.next, struct lnet_ni,
     				ni_netlist);
    @@ -1702,7 +1719,8 @@ LNetNIInit(lnet_pid_t requested_pid)
     	 * routes if it has been loaded
     	 */
     	if (!the_lnet.ln_nis_from_mod_params) {
    -		rc = lnet_parse_networks(&net_head, lnet_get_networks());
    +		rc = lnet_parse_networks(&net_head, lnet_get_networks(),
    +					 use_tcp_bonding);
     		if (rc < 0)
     			goto err_empty_list;
     	}
    @@ -2000,7 +2018,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
     		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
     
     	/* Create a net/ni structures for the network string */
    -	rc = lnet_parse_networks(&net_head, nets);
    +	rc = lnet_parse_networks(&net_head, nets, use_tcp_bonding);
     	if (rc <= 0)
     		return !rc ? -EINVAL : rc;
     
    diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
    index 0571fa6a7249..abfc5d8dc219 100644
    --- a/drivers/staging/lustre/lnet/lnet/config.c
    +++ b/drivers/staging/lustre/lnet/lnet/config.c
    @@ -117,6 +117,21 @@ lnet_ni_unique_net(struct list_head *nilist, char *iface)
     	return true;
     }
     
    +/* check that the NI is unique to the interfaces with in the same NI.
    + * This is only a consideration if use_tcp_bonding is set */
    +static bool
    +lnet_ni_unique_ni(char *iface_list[LNET_MAX_INTERFACES], char *iface)
    +{
    +	int i;
    +	for (i = 0; i < LNET_MAX_INTERFACES; i++) {
    +		if (iface_list[i] != NULL &&
    +		    strncmp(iface_list[i], iface, strlen(iface)) == 0)
    +			return false;
    +	}
    +
    +	return true;
    +}
    +
     static bool
     in_array(__u32 *array, __u32 size, __u32 value)
     {
    @@ -374,6 +389,9 @@ lnet_ni_add_interface(struct lnet_ni *ni, char *iface)
     	if (ni == NULL)
     		return -ENOMEM;
     
    +	if (!lnet_ni_unique_ni(ni->ni_interfaces, iface))
    +		return -EINVAL;
    +
     	/* Allocate a separate piece of memory and copy
     	 * into it the string, so we don't have
     	 * a depencency on the tokens string.  This way we
    @@ -495,7 +513,8 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
      * nilist.
      */
     int
    -lnet_parse_networks(struct list_head *netlist, char *networks)
    +lnet_parse_networks(struct list_head *netlist, char *networks,
    +		    bool use_tcp_bonding)
     {
     	struct cfs_expr_list *net_el = NULL;
     	struct cfs_expr_list *ni_el = NULL;
    @@ -634,7 +653,8 @@ lnet_parse_networks(struct list_head *netlist, char *networks)
     		if (IS_ERR_OR_NULL(net))
     			goto failed;
     
    -		if (!nistr) {
    +		if (!nistr ||
    +		    (use_tcp_bonding && LNET_NETTYP(net_id) == SOCKLND)) {
     			/*
     			 * No interface list was specified, allocate a
     			 * ni using the defaults.
    @@ -643,11 +663,13 @@ lnet_parse_networks(struct list_head *netlist, char *networks)
     			if (IS_ERR_OR_NULL(ni))
     				goto failed;
     
    -			if (net_el) {
    -				cfs_expr_list_free(net_el);
    -				net_el = NULL;
    +			if (!nistr) {
    +				if (net_el) {
    +					cfs_expr_list_free(net_el);
    +					net_el = NULL;
    +				}
    +				continue;
     			}
    -			continue;
     		}
     
     		do {
    @@ -704,17 +726,23 @@ lnet_parse_networks(struct list_head *netlist, char *networks)
     			}
     
     			/*
    -			 * At this point the name
    -			 is properly terminated.
    +			 * At this point the name is properly terminated.
     			 */
     			if (!*name) {
     				str = name;
     				goto failed_syntax;
     			}
     
    -			ni = lnet_ni_alloc(net, ni_el, name);
    -			if (IS_ERR_OR_NULL(ni))
    -				goto failed;
    +			if (use_tcp_bonding &&
    +			    LNET_NETTYP(net->net_id) == SOCKLND) {
    +				rc = lnet_ni_add_interface(ni, name);
    +				if (rc != 0)
    +					goto failed;
    +			} else {
    +				ni = lnet_ni_alloc(net, ni_el, name);
    +				if (IS_ERR_OR_NULL(ni))
    +					goto failed;
    +			}
     
     			if (ni_el) {
     				if (ni_el != net_el) {
    
    
    
