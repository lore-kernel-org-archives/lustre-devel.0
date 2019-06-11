From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 11 Jun 2019 06:27:35 +0000
Subject: [lustre-devel] lnet ip2nets option broken in master?
In-Reply-To: <6FB8A669-6641-4579-B4F2-E687F7CCF116@amazon.com>
References: <EC55F7D4-BCB6-4A02-84FD-3CB4F46A487F@cray.com>
 <E4BEE47A-0CEF-40D9-B965-F232467FB03B@amazon.com>
 <alpine.LFD.2.21.1905281401090.12288@casper.infradead.org>
 <6FB8A669-6641-4579-B4F2-E687F7CCF116@amazon.com>
Message-ID: <BAE57A11-B18B-48BA-89E6-D438724AED64@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Aurelien,
I just saw your reply in my junk folder... :-(

Could you please open an LU ticket, and possibly push a patch with the fix
that is working for you, rather than me guessing what is supposed to be done.

Cheers, Andreas

On May 28, 2019, at 07:57, Degremont, Aurelien <degremoa@amazon.com> wrote:
> 
> Oh, I was thinking of a smaller change.
> This patch looks like (good) code refactoring.
> 
> It seems the fix for ip2nets in master is indeed just a "ntohl(ifa->ifa_local);" for lnet_ipaddr_enumerate()
> 
> 
> Aur?lien
> 
> ?Le 28/05/2019 15:13, ? James Simmons ? <jsimmons@infradead.org> a ?crit :
> 
> 
>    On Mon, 27 May 2019, Degremont, Aurelien wrote:
> 
>> Hi Chris,
>> 
>> Thanks for the info!
>> 
>> @James, most of the patches you were waiting for are almost landed (last 
>    ones are in master-next).
>> Do you have a draft of the fix for ip2nets you can push in gerrit 
>    fortestsonly?
> 
>    Yes I do but I need the the ko2iblnd fix to land as well. I embedded the
>    patch if you want to do an early review. This is a rough version but does
>    have light testing. I have some style changes to be sepatated out but 
>    haven't got to it yet. I made this patch some time ago. So Neil be gentle 
>    :-)
> 
>    diff --git a/lnet/include/lnet/lib-lnet.h b/lnet/include/lnet/lib-lnet.h
>    index 95c4df1..2eb161e 100644
>    --- a/lnet/include/lnet/lib-lnet.h
>    +++ b/lnet/include/lnet/lib-lnet.h
>    @@ -40,9 +40,7 @@
>     /* LNET has 0xeXXX */
>     #define CFS_FAIL_PTLRPC_OST_BULK_CB2	0xe000
> 
>    -#ifndef __KERNEL__
>    -# error This include is only for kernel use.
>    -#endif
>    +#include <linux/netdevice.h>
> 
>     #include <libcfs/libcfs.h>
>     #include <lnet/api.h>
>    @@ -841,6 +839,16 @@ int lnet_acceptor_port(void);
>     int lnet_acceptor_start(void);
>     void lnet_acceptor_stop(void);
> 
>    +struct lnet_inetdev {
>    +	unsigned int	li_interfaces;
>    +	int		li_flags;
>    +	u32		li_ipaddr[LNET_INTERFACES_NUM];
>    +	u32		li_netmask[LNET_INTERFACES_NUM];
>    +	char		li_name[LNET_INTERFACES_NUM][IFNAMSIZ];
>    +};
>    +
>    +int lnet_inet_enumerate(struct lnet_ni *ni, struct lnet_inetdev *ifaces,
>    +			char *iname, int ifaces_done);
>     int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
>     int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
>     int lnet_sock_getaddr(struct socket *socket, bool remote, __u32 *ip, int *port);
>    diff --git a/lnet/klnds/gnilnd/gnilnd_aries.h b/lnet/klnds/gnilnd/gnilnd_aries.h
>    index d9698b6..431442f 100644
>    --- a/lnet/klnds/gnilnd/gnilnd_aries.h
>    +++ b/lnet/klnds/gnilnd/gnilnd_aries.h
>    @@ -24,7 +24,6 @@
>     #ifndef _GNILND_ARIES_H
>     #define _GNILND_ARIES_H
> 
>    -/* for lnet_ipif_query */
>     #include <lnet/lib-lnet.h>
> 
>     #ifndef _GNILND_HSS_OPS_H
>    diff --git a/lnet/klnds/o2iblnd/o2iblnd.c b/lnet/klnds/o2iblnd/o2iblnd.c
>    index bf71ace..29335ed 100644
>    --- a/lnet/klnds/o2iblnd/o2iblnd.c
>    +++ b/lnet/klnds/o2iblnd/o2iblnd.c
>    @@ -2887,80 +2887,6 @@ kiblnd_destroy_dev(struct kib_dev *dev)
>             LIBCFS_FREE(dev, sizeof(*dev));
>     }
> 
>    -static struct kib_dev *
>    -kiblnd_create_dev(char *ifname)
>    -{
>    -	struct net_device *netdev;
>    -	struct kib_dev *dev = NULL;
>    -	int flags;
>    -	int rc;
>    -
>    -	rtnl_lock();
>    -	for_each_netdev(&init_net, netdev) {
>    -		struct in_device *in_dev;
>    -
>    -		if (strcmp(netdev->name, "lo") == 0) /* skip the loopback IF */
>    -			continue;
>    -
>    -		flags = dev_get_flags(netdev);
>    -		if (!(flags & IFF_UP)) {
>    -			CERROR("Can't query IPoIB interface %s: it's down\n",
>    -			       netdev->name);
>    -			goto unlock;
>    -		}
>    -
>    -		in_dev = __in_dev_get_rtnl(netdev);
>    -		if (!in_dev) {
>    -			CWARN("Interface %s has no IPv4 status.\n",
>    -			      netdev->name);
>    -			goto unlock;
>    -		}
>    -
>    -		for_ifa(in_dev)
>    -			if (strcmp(ifname, ifa->ifa_label) == 0) {
>    -				LIBCFS_ALLOC(dev, sizeof(*dev));
>    -				if (!dev)
>    -					goto unlock;
>    -
>    -				dev->ibd_can_failover = !!(flags & IFF_MASTER);
>    -				dev->ibd_ifip = ntohl(ifa->ifa_local);
>    -
>    -				INIT_LIST_HEAD(&dev->ibd_nets);
>    -				INIT_LIST_HEAD(&dev->ibd_list); /* not yet in kib_devs */
>    -				INIT_LIST_HEAD(&dev->ibd_fail_list);
>    -				break;
>    -			}
>    -		endfor_ifa(in_dev);
>    -	}
>    -	rtnl_unlock();
>    -
>    -	if (!dev) {
>    -		CERROR("Can't find any usable interfaces\n");
>    -		return NULL;
>    -	}
>    -
>    -	if (dev->ibd_ifip == 0) {
>    -		CERROR("Can't initialize device: no IP address\n");
>    -		goto free_dev;
>    -	}
>    -	strcpy(&dev->ibd_ifname[0], ifname);
>    -
>    -	/* initialize the device */
>    -	rc = kiblnd_dev_failover(dev);
>    -	if (rc != 0) {
>    -		CERROR("Can't initialize device: %d\n", rc);
>    -		goto free_dev;
>    -	}
>    -
>    -	list_add_tail(&dev->ibd_list, &kiblnd_data.kib_devs);
>    -	return dev;
>    -unlock:
>    -	rtnl_unlock();
>    -free_dev:
>    -	LIBCFS_FREE(dev, sizeof(*dev));
>    -	return NULL;
>    -}
>    -
>     static void
>     kiblnd_base_shutdown(void)
>     {
>    @@ -3241,8 +3167,7 @@ kiblnd_start_schedulers(struct kib_sched_info *sched)
>     	return rc;
>     }
> 
>    -static int
>    -kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts, int ncpts)
>    +static int kiblnd_dev_start_threads(struct kib_dev *dev, u32 *cpts, int ncpts)
>     {
>     	int	cpt;
>     	int	rc;
>    @@ -3254,7 +3179,7 @@ kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts, int ncpts)
>     		cpt = (cpts == NULL) ? i : cpts[i];
>     		sched = kiblnd_data.kib_scheds[cpt];
> 
>    -		if (!newdev && sched->ibs_nthreads > 0)
>    +		if (sched->ibs_nthreads > 0)
>     			continue;
> 
>     		rc = kiblnd_start_schedulers(kiblnd_data.kib_scheds[cpt]);
>    @@ -3267,49 +3192,15 @@ kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts, int ncpts)
>     	return 0;
>     }
> 
>    -static struct kib_dev *
>    -kiblnd_dev_search(char *ifname)
>    -{
>    -	struct kib_dev *alias = NULL;
>    -	struct kib_dev *dev;
>    -	char		*colon;
>    -	char		*colon2;
>    -
>    -	colon = strchr(ifname, ':');
>    -	list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
>    -		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
>    -			return dev;
>    -
>    -		if (alias != NULL)
>    -			continue;
>    -
>    -		colon2 = strchr(dev->ibd_ifname, ':');
>    -		if (colon != NULL)
>    -			*colon = 0;
>    -		if (colon2 != NULL)
>    -			*colon2 = 0;
>    -
>    -		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
>    -			alias = dev;
>    -
>    -		if (colon != NULL)
>    -			*colon = ':';
>    -		if (colon2 != NULL)
>    -			*colon2 = ':';
>    -	}
>    -	return alias;
>    -}
>    -
>     static int
>     kiblnd_startup(struct lnet_ni *ni)
>     {
>    -        char                     *ifname;
>     	struct kib_dev *ibdev = NULL;
>    +	struct lnet_inetdev ifaces;
>     	struct kib_net *net;
>             unsigned long             flags;
>             int                       rc;
>    -	int			  newdev;
>    -	int			  node_id;
>    +	int i;
> 
>             LASSERT (ni->ni_net->net_lnd == &the_o2iblnd);
> 
>    @@ -3333,43 +3224,65 @@ kiblnd_startup(struct lnet_ni *ni)
>     	 * tcp bonding for ksocklnd. Multi-Rail wants each secondary
>     	 * IP to be treated as an unique 'struct ni' interfaces instead.
>     	 */
>    -	if (ni->ni_interfaces[0] != NULL) {
>    -		/* Use the IPoIB interface specified in 'networks=' */
>    -
>    -		CLASSERT(LNET_INTERFACES_NUM > 1);
>    -		if (ni->ni_interfaces[1] != NULL) {
>    -			CERROR("Multiple interfaces not supported\n");
>    +	ifaces.li_interfaces = 0;
>    +	if (!ni->ni_interfaces[0]) {
>    +		rc = lnet_inet_enumerate(ni, &ifaces, NULL, 0);
>    +		if (rc < 0)
>     			goto failed;
>    -		}
>    -
>    -		ifname = ni->ni_interfaces[0];
>     	} else {
>    -		ifname = *kiblnd_tunables.kib_default_ipif;
>    +		for (i = 0; i < LNET_INTERFACES_NUM; i++) {
>    +			int j;
>    +
>    +			if (!ni->ni_interfaces[i])
>    +				break;
>    +
>    +			for (j = 0; j < LNET_INTERFACES_NUM; j++) {
>    +				if (strlen(ifaces.li_name[j]) &&
>    +				    !strcmp(ifaces.li_name[j],
>    +					    ni->ni_interfaces[i])) {
>    +					CERROR("found duplicate %s\n",
>    +					       ni->ni_interfaces[i]);
>    +					rc = -EEXIST;
>    +					goto failed;
>    +				}
>    +			}
>    +
>    +			rc = lnet_inet_enumerate(ni, &ifaces,
>    +						 ni->ni_interfaces[i], 0);
>    +			if (rc < 0)
>    +				goto failed;
>    +		}
>     	}
> 
>    -        if (strlen(ifname) >= sizeof(ibdev->ibd_ifname)) {
>    -                CERROR("IPoIB interface name too long: %s\n", ifname);
>    -                goto failed;
>    -        }
>    +	for (i = 0; i < ifaces.li_interfaces; i++) {
>    +		LIBCFS_ALLOC(ibdev, sizeof(*ibdev));
>    +		if (!ibdev)
>    +			goto failed;
> 
>    -	ibdev = kiblnd_dev_search(ifname);
>    +		ibdev->ibd_ifip = ifaces.li_ipaddr[i];
>    +		ibdev->ibd_can_failover = !!(ifaces.li_flags & IFF_MASTER);
>    +		strlcpy(ibdev->ibd_ifname, ifaces.li_name[i],
>    +			sizeof(ibdev->ibd_ifname));
> 
>    -	newdev = ibdev == NULL;
>    -	/* hmm...create kib_dev even for alias */
>    -	if (ibdev == NULL || strcmp(&ibdev->ibd_ifname[0], ifname) != 0)
>    -		ibdev = kiblnd_create_dev(ifname);
>    +		INIT_LIST_HEAD(&ibdev->ibd_nets);
>    +		INIT_LIST_HEAD(&ibdev->ibd_list); /* not yet in kib_devs */
>    +		INIT_LIST_HEAD(&ibdev->ibd_fail_list);
> 
>    -	if (ibdev == NULL)
>    -		goto failed;
>    +		/* initialize the device */
>    +		rc = kiblnd_dev_failover(ibdev);
>    +		if (rc) {
>    +			CERROR("Can't initialize device: %d\n", rc);
>    +			LIBCFS_FREE(ibdev, sizeof(*ibdev));
>    +			goto failed;
>    +		}
> 
>    -	node_id = dev_to_node(ibdev->ibd_hdev->ibh_ibdev->dma_device);
>    -	ni->ni_dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
>    +		list_add_tail(&ibdev->ibd_list, &kiblnd_data.kib_devs);
>    +	}
> 
>     	net->ibn_dev = ibdev;
>     	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ibdev->ibd_ifip);
> 
>    -	rc = kiblnd_dev_start_threads(ibdev, newdev,
>    -				      ni->ni_cpts, ni->ni_ncpts);
>    +	rc = kiblnd_dev_start_threads(ibdev, ni->ni_cpts, ni->ni_ncpts);
>     	if (rc != 0)
>     		goto failed;
> 
>    diff --git a/lnet/klnds/socklnd/socklnd.c b/lnet/klnds/socklnd/socklnd.c
>    index 9cabeec..1657413 100644
>    --- a/lnet/klnds/socklnd/socklnd.c
>    +++ b/lnet/klnds/socklnd/socklnd.c
>    @@ -2571,62 +2571,6 @@ ksocknal_shutdown(struct lnet_ni *ni)
>     }
> 
>     static int
>    -ksocknal_enumerate_interfaces(struct ksock_net *net, char *iname)
>    -{
>    -	struct net_device *dev;
>    -
>    -	rtnl_lock();
>    -	for_each_netdev(&init_net, dev) {
>    -		/* The iname specified by an user land configuration can
>    -		 * map to an ifa_label so always treat iname as an ifa_label.
>    -		 * If iname is NULL then fall back to the net device name.
>    -		 */
>    -		const char *name = iname ? iname : dev->name;
>    -		struct in_device *in_dev;
>    -
>    -		if (strcmp(dev->name, "lo") == 0) /* skip the loopback IF */
>    -			continue;
>    -
>    -		if (!(dev_get_flags(dev) & IFF_UP)) {
>    -			CWARN("Ignoring interface %s (down)\n", dev->name);
>    -			continue;
>    -		}
>    -
>    -		in_dev = __in_dev_get_rtnl(dev);
>    -		if (!in_dev) {
>    -			CWARN("Interface %s has no IPv4 status.\n", dev->name);
>    -			continue;
>    -		}
>    -
>    -		for_ifa(in_dev)
>    -			if (strcmp(name, ifa->ifa_label) == 0) {
>    -				int idx = net->ksnn_ninterfaces;
>    -				struct ksock_interface *ksi;
>    -
>    -				if (idx >= ARRAY_SIZE(net->ksnn_interfaces)) {
>    -					rtnl_unlock();
>    -					return -E2BIG;
>    -				}
>    -
>    -				ksi = &net->ksnn_interfaces[idx];
>    -				ksi->ksni_ipaddr = ntohl(ifa->ifa_local);
>    -				ksi->ksni_netmask = ifa->ifa_mask;
>    -				strlcpy(ksi->ksni_name,
>    -					name, sizeof(ksi->ksni_name));
>    -				net->ksnn_ninterfaces++;
>    -				break;
>    -			}
>    -		endfor_ifa(in_dev);
>    -        }
>    -	rtnl_unlock();
>    -
>    -	if (net->ksnn_ninterfaces == 0)
>    -                CERROR("Can't find any usable interfaces\n");
>    -
>    -	return net->ksnn_ninterfaces > 0 ? 0 : -ENOENT;
>    -}
>    -
>    -static int
>     ksocknal_search_new_ipif(struct ksock_net *net)
>     {
>     	int new_ipif = 0;
>    @@ -2743,12 +2687,11 @@ ksocknal_net_start_threads(struct ksock_net *net, __u32 *cpts, int ncpts)
>     int
>     ksocknal_startup(struct lnet_ni *ni)
>     {
>    -	struct ksock_net *net;
>     	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
>    +	struct lnet_inetdev ifaces;
>    +	struct ksock_net *net;
>     	int rc;
>     	int i;
>    -	struct net_device *net_dev;
>    -	int node_id;
> 
>             LASSERT (ni->ni_net->net_lnd == &the_ksocklnd);
> 
>    @@ -2788,8 +2731,9 @@ ksocknal_startup(struct lnet_ni *ni)
>     		net_tunables->lct_peer_rtr_credits =
>     			*ksocknal_tunables.ksnd_peerrtrcredits;
> 
>    +	ifaces.li_interfaces = 0;
>     	if (!ni->ni_interfaces[0]) {
>    -		rc = ksocknal_enumerate_interfaces(net, NULL);
>    +		rc = lnet_inet_enumerate(ni, &ifaces, NULL, 0);
>     		if (rc < 0)
>     			goto fail_1;
>     	} else {
>    @@ -2809,34 +2753,32 @@ ksocknal_startup(struct lnet_ni *ni)
>     			if (!ni->ni_interfaces[i])
>     				break;
> 
>    -			for (j = 0; j < net->ksnn_ninterfaces;  j++) {
>    -				struct ksock_interface *ksi;
>    -
>    -				ksi = &net->ksnn_interfaces[j];
>    -
>    -				if (strcmp(ni->ni_interfaces[i],
>    -					   ksi->ksni_name) == 0) {
>    +			for (j = 0; j < LNET_INTERFACES_NUM;  j++) {
>    +				if (strcmp(ifaces.li_name[j],
>    +					   ni->ni_interfaces[i]) == 0) {
>     					CERROR("found duplicate %s\n",
>    -					       ksi->ksni_name);
>    +					       ni->ni_interfaces[i]);
>     					rc = -EEXIST;
>     					goto fail_1;
>     				}
>     			}
> 
>    -			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
>    +			rc = lnet_inet_enumerate(ni, &ifaces,
>    +						 ni->ni_interfaces[i], 0);
>     			if (rc < 0)
>     				goto fail_1;
>     		}
>     	}
> 
>    -	net_dev = dev_get_by_name(&init_net,
>    -				  net->ksnn_interfaces[0].ksni_name);
>    -	if (net_dev != NULL) {
>    -		node_id = dev_to_node(&net_dev->dev);
>    -		ni->ni_dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
>    -		dev_put(net_dev);
>    -	} else {
>    -		ni->ni_dev_cpt = CFS_CPT_ANY;
>    +	net->ksnn_ninterfaces = ifaces.li_interfaces;
>    +	for (i = 0; i < net->ksnn_ninterfaces; i++) {
>    +		struct ksock_interface *ksi;
>    +
>    +		ksi = &net->ksnn_interfaces[i];
>    +		ksi->ksni_ipaddr = ifaces.li_ipaddr[i];
>    +		ksi->ksni_netmask = ifaces.li_netmask[i];
>    +		strlcpy(ksi->ksni_name, ifaces.li_name[i],
>    +			sizeof(ksi->ksni_name));
>     	}
> 
>     	/* call it before add it to ksocknal_data.ksnd_nets */
>    diff --git a/lnet/lnet/config.c b/lnet/lnet/config.c
>    index 12b2442..666f0f0 100644
>    --- a/lnet/lnet/config.c
>    +++ b/lnet/lnet/config.c
>    @@ -1611,34 +1611,28 @@ lnet_match_networks (char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
>     	return count;
>     }
> 
>    -static void
>    -lnet_ipaddr_free_enumeration(__u32 *ipaddrs, int nip)
>    -{
>    -	LIBCFS_FREE(ipaddrs, nip * sizeof(*ipaddrs));
>    -}
>    -
>    -static int
>    -lnet_ipaddr_enumerate(u32 **ipaddrsp)
>    +int lnet_inet_enumerate(struct lnet_ni *ni, struct lnet_inetdev *ifaces,
>    +			char *iname, int ifa_done)
>     {
>     	struct net_device *dev;
>    -	u32 *ipaddrs;
>    -	int nalloc = 64;
>    -	int nip = 0;
>    -
>    -	LIBCFS_ALLOC(ipaddrs, nalloc * sizeof(*ipaddrs));
>    -	if (!ipaddrs) {
>    -		CERROR("Can't allocate ipaddrs[%d]\n", nalloc);
>    -		return -ENOMEM;
>    -	}
>    +	int skip = 0;
>    +	int rc = 0;
> 
>     	rtnl_lock();
>     	for_each_netdev(&init_net, dev) {
>    +		/* The iname specified by an user land configuration can
>    +		 * map to an ifa_label so always treat iname as an ifa_label.
>    +		 * If iname is NULL then fall back to the net device name.
>    +		 */
>    +		const char *name = iname ? iname : dev->name;
>     		struct in_device *in_dev;
> 
>    -		if (strcmp(dev->name, "lo") == 0)
>    +		ifaces->li_flags = dev_get_flags(dev);
>    +
>    +		if (ifaces->li_flags & IFF_LOOPBACK) /* skip the loopback IF */
>     			continue;
> 
>    -		if (!(dev_get_flags(dev) & IFF_UP)) {
>    +		if (!(ifaces->li_flags & IFF_UP)) {
>     			CWARN("Ignoring interface %s: it's down\n", dev->name);
>     			continue;
>     		}
>    @@ -1649,65 +1643,109 @@ lnet_ipaddr_enumerate(u32 **ipaddrsp)
>     			continue;
>     		}
> 
>    -		if (nip >= nalloc) {
>    -			u32 *ipaddrs2;
>    +		if (ni && ni->ni_dev_cpt != CFS_CPT_ANY) {
>    +			int node_id = dev_to_node(&dev->dev);
>    +			int cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
> 
>    -			nalloc += nalloc;
>    -			ipaddrs2 = krealloc(ipaddrs, nalloc * sizeof(*ipaddrs2),
>    -					    GFP_KERNEL);
>    -			if (!ipaddrs2) {
>    -				kfree(ipaddrs);
>    -				CERROR("Can't allocate ipaddrs[%d]\n", nip);
>    -				return -ENOMEM;
>    +			if (ni->ni_dev_cpt != cpt &&
>    +			    ifaces->li_interfaces > 0) {
>    +				ni->ni_dev_cpt = CFS_CPT_ANY;
>    +				CWARN("Not all the network interfaces belong to the same CPT\n");
>    +			} else {
>    +				ni->ni_dev_cpt = cpt;
>     			}
>    -			ipaddrs = ipaddrs2;
>     		}
> 
>    -		for_primary_ifa(in_dev)
>    -			if (strcmp(ifa->ifa_label, dev->name) == 0) {
>    -				ipaddrs[nip++] = ifa->ifa_local;
>    -				break;
>    +		for_ifa(in_dev)
>    +			if (strcmp(name, ifa->ifa_label) == 0) {
>    +				int idx = ifaces->li_interfaces;
>    +
>    +				if (idx >= ARRAY_SIZE(ifaces->li_name))
>    +					return -E2BIG;
>    +
>    +				if (skip++ < ifa_done)
>    +					continue;
>    +
>    +				ifaces->li_ipaddr[idx] = ntohl(ifa->ifa_local);
>    +				ifaces->li_netmask[idx] = ifa->ifa_mask;
>    +				strlcpy(ifaces->li_name[idx], name,
>    +					sizeof(ifaces->li_name[idx]));
>    +				ifaces->li_interfaces++;
>    +				goto unlock_rtnl;
>     			}
>     		endfor_ifa(in_dev);
>     	}
>    +unlock_rtnl:
>     	rtnl_unlock();
> 
>    -	*ipaddrsp = ipaddrs;
>    -	return nip;
>    +	if (ifaces->li_interfaces == 0) {
>    +		CERROR("Can't find any usable interfaces\n");
>    +		rc = -ENOENT;
>    +	}
>    +
>    +	return rc;
>     }
>    +EXPORT_SYMBOL(lnet_inet_enumerate);
> 
>     int
>    -lnet_parse_ip2nets (char **networksp, char *ip2nets)
>    +lnet_parse_ip2nets(char **networksp, char *ip2nets)
>     {
>    -	__u32	  *ipaddrs = NULL;
>    -	int	   nip = lnet_ipaddr_enumerate(&ipaddrs);
>    -	int	   rc;
>    -
>    -	if (nip < 0) {
>    -		LCONSOLE_ERROR_MSG(0x117, "Error %d enumerating local IP "
>    -				   "interfaces for ip2nets to match\n", nip);
>    -		return nip;
>    -	}
>    +	struct lnet_inetdev ifaces;
>    +	u32 *ipaddrs = NULL;
>    +	int nalloc = 0;
>    +	int nip = 0;
>    +	int rc;
> 
>    -	if (nip == 0) {
>    -		LCONSOLE_ERROR_MSG(0x118, "No local IP interfaces "
>    -				   "for ip2nets to match\n");
>    -		return -ENOENT;
>    -	}
>    +realloc:
>    +	ifaces.li_interfaces = 0;
>    +	rc = lnet_inet_enumerate(NULL, &ifaces, NULL, nip);
>    +	if (rc < 0) {
>    +		/* Handle edge case where we nip is muliple of
>    +		 * LNET_INTERFACES_NUM and no more devices are
>    +		 * detected.
>    +		 */
>    +		if (rc == -ENOENT && nip > 0)
>    +			goto match_networks;
> 
>    -	rc = lnet_match_networks(networksp, ip2nets, ipaddrs, nip);
>    -	lnet_ipaddr_free_enumeration(ipaddrs, nip);
>    +		LCONSOLE_ERROR_MSG(0x117,
>    +				   "Error %d enumerating local IP interfaces for ip2nets to match\n",
>    +				   rc);
>    +		goto out_free_addrs;
>    +	} else {
>    +		u32 *ipaddrs2;
>    +		int i;
>    +
>    +		nalloc += ifaces.li_interfaces;
>    +		ipaddrs2 = krealloc(ipaddrs, nalloc * sizeof(*ipaddrs),
>    +				    GFP_KERNEL);
>    +		if (!ipaddrs2) {
>    +			CERROR("Can't allocate ipaddrs[%d]\n", nalloc);
>    +			goto out_free_addrs;
>    +		}
>    +		ipaddrs = ipaddrs2;
> 
>    +		for (i = 0; i < ifaces.li_interfaces; i++) {
>    +			memcpy(ipaddrs + nip, ifaces.li_ipaddr,
>    +			       sizeof(*ipaddrs) * LNET_INTERFACES_NUM);
>    +		}
>    +
>    +		/* Maybe more ? */
>    +		if (ifaces.li_interfaces == LNET_INTERFACES_NUM) {
>    +			nip += LNET_INTERFACES_NUM;
>    +			goto realloc;
>    +		}
>    +	}
>    +match_networks:
>    +	rc = lnet_match_networks(networksp, ip2nets, ipaddrs, nip);
>     	if (rc < 0) {
>     		LCONSOLE_ERROR_MSG(0x119, "Error %d parsing ip2nets\n", rc);
>     		return rc;
>    -	}
>    -
>    -	if (rc == 0) {
>    +	} else if (rc == 0) {
>     		LCONSOLE_ERROR_MSG(0x11a, "ip2nets does not match "
>     				   "any local IP interfaces\n");
>     		return -ENOENT;
>     	}
>    -
>    -	return 0;
>    +out_free_addrs:
>    +	LIBCFS_FREE(ipaddrs, nip * sizeof(*ipaddrs));
>    +	return rc;
>     }
>    -- 
>    1.8.3.1
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud
