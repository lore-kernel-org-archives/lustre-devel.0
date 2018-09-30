From: James Simmons <jsimmons@infradead.org>
Date: Sun, 30 Sep 2018 02:49:59 +0100 (BST)
Subject: [lustre-devel] [PATCH 12/34] LU-7734 lnet: NUMA support
In-Reply-To: <153783763531.32103.14595088461405832909.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763531.32103.14595088461405832909.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809300249350.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Amir Shehata <amir.shehata@intel.com>
> 
> This patch adds NUMA node support. NUMA node information is stored
> in the CPT table. A NUMA node mask is maintained for the entire table
> as well as for each CPT to track the NUMA nodes related to each of
> the CPTs. Following key APIs added:
> 
> cfs_cpt_of_node(): returns the CPT of particular NUMA node
> cfs_cpt_distance(): calculates the distance between two CPTs
> 
> When the LND device is started it finds the NUMA node of the physical
> device and then from there it finds the CPT, which is subsequently
> stored in the NI structure.
> 
> When selecting the NI, the MD CPT is determined and the distance
> between the MD CPT and the device CPT is calculated. The NI
> with the shortest distance is preferred.
> 
> If the device or system is not NUMA aware then the CPT for the
> device will default to CFS_CPT_ANY and the distance calculated
> when CFS_CPT_ANY is used is largest in the system. IE, none
> NUMA aware devices are least preferred.
> 
> A NUMA range value can be set. If the value is large enough
> it amounts to basically turning off NUMA criterion completely.
> 
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Change-Id: I2d7c63f8e8fc8e8a6a249b0d6bfdd08fd090a837
> Reviewed-on: http://review.whamcloud.com/18916
> Tested-by: Jenkins
> Tested-by: Maloo <hpdd-maloo@intel.com>

We can remove the Test-by: as well. 

> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    3 
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    6 +
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    6 +
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 +
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   13 ++
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   27 +++
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |  160 +++++++++++++++++---
>  8 files changed, 195 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index a7cff6426ad8..c338e31b2cdd 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -408,6 +408,7 @@ struct lnet_ni *lnet_net2ni_addref(__u32 net);
>  bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
>  struct lnet_net *lnet_get_net_locked(u32 net_id);
>  
> +extern unsigned int lnet_numa_range;
>  extern int portal_rotor;
>  
>  int lnet_lib_init(void);
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 22b141cb6cff..5083b72ca20f 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -346,6 +346,9 @@ struct lnet_ni {
>  	/* lnd tunables set explicitly */
>  	bool ni_lnd_tunables_set;
>  
> +	/* physical device CPT */
> +	int			dev_cpt;
> +
>  	/* sequence number used to round robin over nis within a net */
>  	u32			ni_seq;
>  
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> index fa58aaf6ad9d..a231f6d89e95 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> @@ -142,7 +142,9 @@ struct libcfs_debug_ioctl_data {
>  #define IOC_LIBCFS_ADD_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 95, IOCTL_CONFIG_SIZE)
>  #define IOC_LIBCFS_DEL_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 96, IOCTL_CONFIG_SIZE)
>  #define IOC_LIBCFS_GET_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 97, IOCTL_CONFIG_SIZE)
> -#define IOC_LIBCFS_DBG			_IOWR(IOC_LIBCFS_TYPE, 98, IOCTL_CONFIG_SIZE)
> -#define IOC_LIBCFS_MAX_NR		98
> +#define IOC_LIBCFS_SET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 98, IOCTL_CONFIG_SIZE)
> +#define IOC_LIBCFS_GET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 99, IOCTL_CONFIG_SIZE)
> +#define IOC_LIBCFS_DBG			_IOWR(IOC_LIBCFS_TYPE, 100, IOCTL_CONFIG_SIZE)
> +#define IOC_LIBCFS_MAX_NR		100
>  
>  #endif /* __LIBCFS_IOCTL_H__ */
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> index bfd9fc6bc4df..5eaaf0eae470 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> @@ -162,6 +162,7 @@ struct lnet_ioctl_config_ni {
>  	__u32			lic_status;
>  	__u32			lic_tcp_bonding;
>  	__u32			lic_idx;
> +	__s32			lic_dev_cpt;
>  	char			lic_bulk[0];
>  };
>  
> @@ -213,6 +214,11 @@ struct lnet_ioctl_peer_cfg {
>  	char prcfg_bulk[0];
>  };
>  
> +struct lnet_ioctl_numa_range {
> +	struct libcfs_ioctl_hdr nr_hdr;
> +	__u32 nr_range;
> +};
> +
>  struct lnet_ioctl_lnet_stats {
>  	struct libcfs_ioctl_hdr st_hdr;
>  	struct lnet_counters st_cntrs;
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 958ac9a99045..2e71abbf8a0c 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -2829,6 +2829,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
>  	unsigned long flags;
>  	int rc;
>  	int newdev;
> +	int node_id;
>  
>  	LASSERT(ni->ni_net->net_lnd == &the_o2iblnd);
>  
> @@ -2878,6 +2879,9 @@ static int kiblnd_startup(struct lnet_ni *ni)
>  	if (!ibdev)
>  		goto failed;
>  
> +	node_id = dev_to_node(ibdev->ibd_hdev->ibh_ibdev->dma_device);
> +	ni->dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
> +
>  	net->ibn_dev = ibdev;
>  	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ibdev->ibd_ifip);
>  
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 9df66c6d160f..ba1ec35a017a 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -38,6 +38,7 @@
>   * Author: Eric Barton <eric@bartonsoftware.com>
>   */
>  
> +#include <linux/pci.h>
>  #include "socklnd.h"
>  #include <linux/inetdevice.h>
>  
> @@ -2726,6 +2727,8 @@ ksocknal_startup(struct lnet_ni *ni)
>  	struct ksock_net *net;
>  	int rc;
>  	int i;
> +	struct net_device *net_dev;
> +	int node_id;
>  
>  	LASSERT(ni->ni_net->net_lnd == &the_ksocklnd);
>  
> @@ -2773,6 +2776,16 @@ ksocknal_startup(struct lnet_ni *ni)
>  		}
>  	}
>  
> +	net_dev = dev_get_by_name(&init_net,
> +				  net->ksnn_interfaces[0].ksni_name);
> +	if (net_dev) {
> +		node_id = dev_to_node(&net_dev->dev);
> +		ni->dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
> +		dev_put(net_dev);
> +	} else {
> +		ni->dev_cpt = CFS_CPT_ANY;
> +	}
> +
>  	/* call it before add it to ksocknal_data.ksnd_nets */
>  	rc = ksocknal_net_start_threads(net, ni->ni_cpts, ni->ni_ncpts);
>  	if (rc)
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 1ef9a39b517d..67a3301258d4 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -64,6 +64,12 @@ module_param(use_tcp_bonding, int, 0444);
>  MODULE_PARM_DESC(use_tcp_bonding,
>  		 "Set to 1 to use socklnd bonding. 0 to use Multi-Rail");
>  
> +unsigned int lnet_numa_range;
> +EXPORT_SYMBOL(lnet_numa_range);
> +module_param(lnet_numa_range, uint, 0444);
> +MODULE_PARM_DESC(lnet_numa_range,
> +		 "NUMA range to consider during Multi-Rail selection");
> +
>  /*
>   * This sequence number keeps track of how many times DLC was used to
>   * update the configuration. It is incremented on any DLC update and
> @@ -1896,6 +1902,7 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
>  	cfg_ni->lic_nid = ni->ni_nid;
>  	cfg_ni->lic_status = ni->ni_status->ns_status;
>  	cfg_ni->lic_tcp_bonding = use_tcp_bonding;
> +	cfg_ni->lic_dev_cpt = ni->dev_cpt;
>  
>  	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
>  
> @@ -2642,6 +2649,26 @@ LNetCtl(unsigned int cmd, void *arg)
>  		mutex_unlock(&the_lnet.ln_api_mutex);
>  		return rc;
>  
> +	case IOC_LIBCFS_SET_NUMA_RANGE: {
> +		struct lnet_ioctl_numa_range *numa;
> +
> +		numa = arg;
> +		if (numa->nr_hdr.ioc_len != sizeof(*numa))
> +			return -EINVAL;
> +		lnet_numa_range = numa->nr_range;
> +		return 0;
> +	}
> +
> +	case IOC_LIBCFS_GET_NUMA_RANGE: {
> +		struct lnet_ioctl_numa_range *numa;
> +
> +		numa = arg;
> +		if (numa->nr_hdr.ioc_len != sizeof(*numa))
> +			return -EINVAL;
> +		numa->nr_range = lnet_numa_range;
> +		return 0;
> +	}
> +
>  	case IOC_LIBCFS_GET_BUF: {
>  		struct lnet_ioctl_pool_cfg *pool_cfg;
>  		size_t total = sizeof(*config) + sizeof(*pool_cfg);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index fbf209610ff9..bf2256da6122 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1109,6 +1109,10 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	int best_credits = 0;
>  	u32 seq, seq2;
>  	int best_lpni_credits = INT_MIN;
> +	int md_cpt = 0;
> +	unsigned int shortest_distance = UINT_MAX;
> +	unsigned int distance = 0;
> +	bool found_ir = false;
>  
>  again:
>  	/*
> @@ -1127,12 +1131,20 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	routing = false;
>  	local_net = NULL;
>  	best_ni = NULL;
> +	shortest_distance = UINT_MAX;
> +	found_ir = false;
>  
>  	if (the_lnet.ln_shutdown) {
>  		lnet_net_unlock(cpt);
>  		return -ESHUTDOWN;
>  	}
>  
> +	if (msg->msg_md)
> +		/* get the cpt of the MD, used during NUMA based selection */
> +		md_cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
> +	else
> +		md_cpt = CFS_CPT_ANY;
> +
>  	/*
>  	 * initialize the variables which could be reused if we go to
>  	 * again
> @@ -1258,34 +1270,113 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  			continue;
>  
>  		/*
> -		 * Second jab at determining best_ni
> -		 * if we get here then the peer we're trying to send
> -		 * to is on a directly connected network, and we'll
> -		 * need to pick the local_ni on that network to send
> -		 * from
> +		 * Iterate through the NIs in this local Net and select
> +		 * the NI to send from. The selection is determined by
> +		 * these 3 criterion in the following priority:
> +		 *	1. NUMA
> +		 *	2. NI available credits
> +		 *	3. Round Robin
>  		 */
>  		while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
>  			if (!lnet_is_ni_healthy_locked(ni))
>  				continue;
> -			/* TODO: compare NUMA distance */
> -			if (ni->ni_tx_queues[cpt]->tq_credits <=
> -			    best_credits) {
> +
> +			/*
> +			 * calculate the distance from the cpt on which
> +			 * the message memory is allocated to the CPT of
> +			 * the NI's physical device
> +			 */
> +			distance = cfs_cpt_distance(lnet_cpt_table(),
> +						    md_cpt,
> +						    ni->dev_cpt);
> +
> +			/*
> +			 * If we already have a closer NI within the NUMA
> +			 * range provided, then there is no need to
> +			 * consider the current NI. Move on to the next
> +			 * one.
> +			 */
> +			if (distance > shortest_distance &&
> +			    distance > lnet_numa_range)
> +				continue;
> +
> +			if (distance < shortest_distance &&
> +			    distance > lnet_numa_range) {
>  				/*
> -				 * all we want is to read tq_credits
> -				 * value as an approximation of how
> -				 * busy the NI is. No need to grab a lock
> +				 * The current NI is the closest one that we
> +				 * have found, even though it's not in the
> +				 * NUMA range specified. This occurs if
> +				 * the NUMA range is less than the least
> +				 * of the distances in the system.
> +				 * In effect NUMA range consideration is
> +				 * turned off.
>  				 */
> -				continue;
> -			} else if (best_ni) {
> -				if ((best_ni)->ni_seq - ni->ni_seq <= 0)
> +				shortest_distance = distance;
> +			} else if ((distance <= shortest_distance &&
> +				    distance < lnet_numa_range) ||
> +				   distance == shortest_distance) {
> +				/*
> +				 * This NI is either within range or it's
> +				 * equidistant. In both of these cases we
> +				 * would want to select the NI based on
> +				 * its available credits first, and then
> +				 * via Round Robin.
> +				 */
> +				if (distance <= shortest_distance &&
> +				    distance < lnet_numa_range) {
> +					/*
> +					 * If this is the first NI that's
> +					 * within range, then set the
> +					 * shortest distance to the range
> +					 * specified by the user. In
> +					 * effect we're saying that all
> +					 * NIs that fall within this NUMA
> +					 * range shall be dealt with as
> +					 * having equal NUMA weight. Which
> +					 * will mean that we should select
> +					 * through that set by their
> +					 * available credits first
> +					 * followed by Round Robin.
> +					 *
> +					 * And since this is the first NI
> +					 * in the range, let's just set it
> +					 * as our best_ni for now. The
> +					 * following NIs found in the
> +					 * range will be dealt with as
> +					 * mentioned previously.
> +					 */
> +					shortest_distance = lnet_numa_range;
> +					if (!found_ir) {
> +						found_ir = true;
> +						goto set_ni;
> +					}
> +				}
> +				/*
> +				 * This NI is NUMA equidistant let's
> +				 * select using credits followed by Round
> +				 * Robin.
> +				 */
> +				if (ni->ni_tx_queues[cpt]->tq_credits <
> +				    best_credits) {
>  					continue;
> -				(best_ni)->ni_seq = ni->ni_seq + 1;
> +				} else if (ni->ni_tx_queues[cpt]->tq_credits ==
> +					   best_credits) {
> +					if (best_ni &&
> +					    best_ni->ni_seq <= ni->ni_seq)
> +						continue;
> +				}
>  			}
> -
> +set_ni:
>  			best_ni = ni;
>  			best_credits = ni->ni_tx_queues[cpt]->tq_credits;
>  		}
>  	}
> +	/*
> +	 * Now that we selected the NI to use increment its sequence
> +	 * number so the Round Robin algorithm will detect that it has
> +	 * been used and pick the next NI.
> +	 */
> +	best_ni->ni_seq++;
>  
>  	if (!best_ni) {
>  		lnet_net_unlock(cpt);
> @@ -1372,29 +1463,52 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	best_lpni = NULL;
>  	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
>  		/*
> -		 * if this peer ni is not healty just skip it, no point in
> +		 * if this peer ni is not healthy just skip it, no point in
>  		 * examining it further
>  		 */
>  		if (!lnet_is_peer_ni_healthy_locked(lpni))
>  			continue;
>  		ni_is_pref = lnet_peer_is_ni_pref_locked(lpni, best_ni);
>  
> +		/* if this is a preferred peer use it */
>  		if (!preferred && ni_is_pref) {
>  			preferred = true;
>  		} else if (preferred && !ni_is_pref) {
> +			/*
> +			 * this is not the preferred peer so let's ignore
> +			 * it.
> +			 */
>  			continue;
> -		} else if (lpni->lpni_txcredits <= best_lpni_credits) {
> +		} else if (lpni->lpni_txcredits < best_lpni_credits) {
> +			/*
> +			 * We already have a peer that has more credits
> +			 * available than this one. No need to consider
> +			 * this peer further.
> +			 */
>  			continue;
> -		} else if (best_lpni) {
> -			if (best_lpni->lpni_seq - lpni->lpni_seq <= 0)
> -				continue;
> -			best_lpni->lpni_seq = lpni->lpni_seq + 1;
> +		} else if (lpni->lpni_txcredits == best_lpni_credits) {
> +			/*
> +			 * The best peer found so far and the current peer
> +			 * have the same number of available credits let's
> +			 * make sure to select between them using Round
> +			 * Robin
> +			 */
> +			if (best_lpni) {
> +				if (best_lpni->lpni_seq <= lpni->lpni_seq)
> +					continue;
> +			}
>  		}
>  
>  		best_lpni = lpni;
>  		best_lpni_credits = lpni->lpni_txcredits;
>  	}
>  
> +	/*
> +	 * Increment sequence number of the peer selected so that we can
> +	 * pick the next one in Round Robin.
> +	 */
> +	best_lpni->lpni_seq++;
> +
>  	/* if we still can't find a peer ni then we can't reach it */
>  	if (!best_lpni) {
>  		u32 net_id = peer_net ? peer_net->lpn_net_id :
> @@ -1403,7 +1517,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  		lnet_net_unlock(cpt);
>  		LCONSOLE_WARN("no peer_ni found on peer net %s\n",
>  			      libcfs_net2str(net_id));
> -		goto again;
> +		return -EHOSTUNREACH;
>  	}
>  
>  send:
> 
> 
> 
