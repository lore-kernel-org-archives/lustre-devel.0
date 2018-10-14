From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 20:08:15 +0100 (BST)
Subject: [lustre-devel] [PATCH 01/24] lustre: lnet: add
 lnet_interfaces_max tunable
In-Reply-To: <153895437756.16383.14536895691182127915.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437756.16383.14536895691182127915.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142007120.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Add an lnet_interfaces_max tunable value, that describes the maximum
> number of interfaces per node. This tunable is primarily useful for
> sanity checks prior to allocating memory.
> 
> Allow lnet_interfaces_max to be set and get from the sysfs interface.
> 
> Add LNET_INTERFACES_MIN, value 16, as the minimum value.
> 
> Add LNET_INTERFACES_MAX_DEFAULT, value 200, as the default value. This
> value was chosen to ensure that the size of an LNet ping message with
> any associated LND overhead would fit in 4096 bytes.
> 
> (The LNET_INTERFACES_MAX name was not reused to allow for the early
> detection of issues when merging code that uses it.)
> 
> Rename LNET_NUM_INTERFACES to LNET_INTERFACES_NUM

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Reviewed-on: https://review.whamcloud.com/25770
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |    4 +--
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |    7 ++++
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   22 +++++++-------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    4 +--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    2 +
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    4 +--
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   32 +++++++++++++++++++-
>  drivers/staging/lustre/lnet/lnet/config.c          |   10 +++---
>  10 files changed, 62 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 7219a7bacf6e..7b11c31f0029 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -371,7 +371,7 @@ struct lnet_ni {
>  	 * equivalent interfaces to use
>  	 * This is an array because socklnd bonding can still be configured
>  	 */
> -	char			 *ni_interfaces[LNET_NUM_INTERFACES];
> +	char			 *ni_interfaces[LNET_INTERFACES_NUM];
>  	/* original net namespace */
>  	struct net		 *ni_net_ns;
>  };
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> index 8f03aa3c5676..d88b30d2e76c 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> @@ -81,7 +81,7 @@ struct lnet_ioctl_config_lnd_tunables {
>  };
>  
>  struct lnet_ioctl_net_config {
> -	char ni_interfaces[LNET_NUM_INTERFACES][LNET_MAX_STR_LEN];
> +	char ni_interfaces[LNET_INTERFACES_NUM][LNET_MAX_STR_LEN];
>  	__u32 ni_status;
>  	__u32 ni_cpts[LNET_MAX_SHOW_NUM_CPT];
>  	char cfg_bulk[0];
> @@ -184,7 +184,7 @@ struct lnet_ioctl_element_msg_stats {
>  struct lnet_ioctl_config_ni {
>  	struct libcfs_ioctl_hdr lic_cfg_hdr;
>  	lnet_nid_t		lic_nid;
> -	char			lic_ni_intf[LNET_NUM_INTERFACES][LNET_MAX_STR_LEN];
> +	char			lic_ni_intf[LNET_INTERFACES_NUM][LNET_MAX_STR_LEN];
>  	char			lic_legacy_ip2nets[LNET_MAX_STR_LEN];
>  	__u32			lic_cpts[LNET_MAX_SHOW_NUM_CPT];
>  	__u32			lic_ncpts;
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> index f8a873bab135..6ee60d07ff84 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> @@ -264,7 +264,12 @@ struct lnet_counters {
>  #define LNET_NI_STATUS_DOWN    0xdeadface
>  #define LNET_NI_STATUS_INVALID 0x00000000
>  
> -#define LNET_NUM_INTERFACES    16
> +#define LNET_INTERFACES_NUM		16
> +
> +/* The minimum number of interfaces per node supported by LNet. */
> +#define LNET_INTERFACES_MIN		16
> +/* The default - arbitrary - value of the lnet_max_interfaces tunable. */
> +#define LNET_INTERFACES_MAX_DEFAULT	200
>  
>  /**
>   * Objects maintained by the LNet are accessed through handles. Handle types
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index c20766379323..bf969b3891a9 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -2915,7 +2915,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
>  	if (ni->ni_interfaces[0]) {
>  		/* Use the IPoIB interface specified in 'networks=' */
>  
> -		BUILD_BUG_ON(LNET_NUM_INTERFACES <= 1);
> +		BUILD_BUG_ON(LNET_INTERFACES_NUM <= 1);
>  		if (ni->ni_interfaces[1]) {
>  			CERROR("Multiple interfaces not supported\n");
>  			goto failed;
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index b2f0148d0087..ff8d73295fff 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -53,7 +53,7 @@ ksocknal_ip2iface(struct lnet_ni *ni, __u32 ip)
>  	struct ksock_interface *iface;
>  
>  	for (i = 0; i < net->ksnn_ninterfaces; i++) {
> -		LASSERT(i < LNET_NUM_INTERFACES);
> +		LASSERT(i < LNET_INTERFACES_NUM);
>  		iface = &net->ksnn_interfaces[i];
>  
>  		if (iface->ksni_ipaddr == ip)
> @@ -221,7 +221,7 @@ ksocknal_unlink_peer_locked(struct ksock_peer *peer_ni)
>  	struct ksock_interface *iface;
>  
>  	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++) {
> -		LASSERT(i < LNET_NUM_INTERFACES);
> +		LASSERT(i < LNET_INTERFACES_NUM);
>  		ip = peer_ni->ksnp_passive_ips[i];
>  
>  		iface = ksocknal_ip2iface(peer_ni->ksnp_ni, ip);
> @@ -689,7 +689,7 @@ ksocknal_local_ipvec(struct lnet_ni *ni, __u32 *ipaddrs)
>  	read_lock(&ksocknal_data.ksnd_global_lock);
>  
>  	nip = net->ksnn_ninterfaces;
> -	LASSERT(nip <= LNET_NUM_INTERFACES);
> +	LASSERT(nip <= LNET_INTERFACES_NUM);
>  
>  	/*
>  	 * Only offer interfaces for additional connections if I have
> @@ -770,8 +770,8 @@ ksocknal_select_ips(struct ksock_peer *peer_ni, __u32 *peerips, int n_peerips)
>  	 */
>  	write_lock_bh(global_lock);
>  
> -	LASSERT(n_peerips <= LNET_NUM_INTERFACES);
> -	LASSERT(net->ksnn_ninterfaces <= LNET_NUM_INTERFACES);
> +	LASSERT(n_peerips <= LNET_INTERFACES_NUM);
> +	LASSERT(net->ksnn_ninterfaces <= LNET_INTERFACES_NUM);
>  
>  	/*
>  	 * Only match interfaces for additional connections
> @@ -890,7 +890,7 @@ ksocknal_create_routes(struct ksock_peer *peer_ni, int port,
>  		return;
>  	}
>  
> -	LASSERT(npeer_ipaddrs <= LNET_NUM_INTERFACES);
> +	LASSERT(npeer_ipaddrs <= LNET_INTERFACES_NUM);
>  
>  	for (i = 0; i < npeer_ipaddrs; i++) {
>  		if (newroute) {
> @@ -919,7 +919,7 @@ ksocknal_create_routes(struct ksock_peer *peer_ni, int port,
>  		best_nroutes = 0;
>  		best_netmatch = 0;
>  
> -		LASSERT(net->ksnn_ninterfaces <= LNET_NUM_INTERFACES);
> +		LASSERT(net->ksnn_ninterfaces <= LNET_INTERFACES_NUM);
>  
>  		/* Select interface to connect from */
>  		for (j = 0; j < net->ksnn_ninterfaces; j++) {
> @@ -1060,7 +1060,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
>  	atomic_set(&conn->ksnc_tx_nob, 0);
>  
>  	hello = kvzalloc(offsetof(struct ksock_hello_msg,
> -				  kshm_ips[LNET_NUM_INTERFACES]),
> +				  kshm_ips[LNET_INTERFACES_NUM]),
>  			 GFP_KERNEL);
>  	if (!hello) {
>  		rc = -ENOMEM;
> @@ -1983,7 +1983,7 @@ ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
>  	if (iface) {
>  		/* silently ignore dups */
>  		rc = 0;
> -	} else if (net->ksnn_ninterfaces == LNET_NUM_INTERFACES) {
> +	} else if (net->ksnn_ninterfaces == LNET_INTERFACES_NUM) {
>  		rc = -ENOSPC;
>  	} else {
>  		iface = &net->ksnn_interfaces[net->ksnn_ninterfaces++];
> @@ -2624,7 +2624,7 @@ ksocknal_enumerate_interfaces(struct ksock_net *net, char *iname)
>  			continue;
>  		}
>  
> -		if (j == LNET_NUM_INTERFACES) {
> +		if (j == LNET_INTERFACES_NUM) {
>  			CWARN("Ignoring interface %s (too many interfaces)\n",
>  			      name);
>  			continue;
> @@ -2812,7 +2812,7 @@ ksocknal_startup(struct lnet_ni *ni)
>  
>  		net->ksnn_ninterfaces = rc;
>  	} else {
> -		for (i = 0; i < LNET_NUM_INTERFACES; i++) {
> +		for (i = 0; i < LNET_INTERFACES_NUM; i++) {
>  			if (!ni->ni_interfaces[i])
>  				break;
>  			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> index 82e3523f6463..297d1e5af1bd 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> @@ -173,7 +173,7 @@ struct ksock_net {
>  	int		  ksnn_npeers;		/* # peers */
>  	int		  ksnn_shutdown;	/* shutting down? */
>  	int		  ksnn_ninterfaces;	/* IP interfaces */
> -	struct ksock_interface ksnn_interfaces[LNET_NUM_INTERFACES];
> +	struct ksock_interface ksnn_interfaces[LNET_INTERFACES_NUM];
>  };
>  
>  /** connd timeout */
> @@ -441,7 +441,7 @@ struct ksock_peer {
>  	int                ksnp_n_passive_ips;  /* # of... */
>  
>  	/* preferred local interfaces */
> -	u32		   ksnp_passive_ips[LNET_NUM_INTERFACES];
> +	u32              ksnp_passive_ips[LNET_INTERFACES_NUM];
>  };
>  
>  struct ksock_connreq {
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index dc9a12910a8d..c401896bf649 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -1579,7 +1579,7 @@ ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
>  	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
>  	struct ksock_net *net = (struct ksock_net *)ni->ni_data;
>  
> -	LASSERT(hello->kshm_nips <= LNET_NUM_INTERFACES);
> +	LASSERT(hello->kshm_nips <= LNET_INTERFACES_NUM);
>  
>  	/* rely on caller to hold a ref on socket so it wouldn't disappear */
>  	LASSERT(conn->ksnc_proto);
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> index 10a2757895f3..54ec5d0a85c8 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> @@ -614,7 +614,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
>  	hello->kshm_nips            = le32_to_cpu(hdr->payload_length) /
>  						  sizeof(__u32);
>  
> -	if (hello->kshm_nips > LNET_NUM_INTERFACES) {
> +	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
>  		CERROR("Bad nips %d from ip %pI4h\n",
>  		       hello->kshm_nips, &conn->ksnc_ipaddr);
>  		rc = -EPROTO;
> @@ -684,7 +684,7 @@ ksocknal_recv_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello,
>  		__swab32s(&hello->kshm_nips);
>  	}
>  
> -	if (hello->kshm_nips > LNET_NUM_INTERFACES) {
> +	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
>  		CERROR("Bad nips %d from ip %pI4h\n",
>  		       hello->kshm_nips, &conn->ksnc_ipaddr);
>  		return -EPROTO;
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index b37abdedccaa..6a692d5c4608 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -34,6 +34,7 @@
>  #define DEBUG_SUBSYSTEM S_LNET
>  #include <linux/log2.h>
>  #include <linux/ktime.h>
> +#include <linux/moduleparam.h>
>  
>  #include <linux/lnet/lib-lnet.h>
>  #include <uapi/linux/lnet/lnet-dlc.h>
> @@ -70,6 +71,13 @@ module_param(lnet_numa_range, uint, 0444);
>  MODULE_PARM_DESC(lnet_numa_range,
>  		 "NUMA range to consider during Multi-Rail selection");
>  
> +static int lnet_interfaces_max = LNET_INTERFACES_MAX_DEFAULT;
> +static int intf_max_set(const char *val, const struct kernel_param *kp);
> +module_param_call(lnet_interfaces_max, intf_max_set, param_get_int,
> +		  &lnet_interfaces_max, 0644);
> +MODULE_PARM_DESC(lnet_interfaces_max,
> +		 "Maximum number of interfaces in a node.");
> +
>  /*
>   * This sequence number keeps track of how many times DLC was used to
>   * update the local NIs. It is incremented when a NI is added or
> @@ -82,6 +90,28 @@ static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
>  static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  		     struct lnet_process_id __user *ids, int n_ids);
>  
> +static int
> +intf_max_set(const char *val, const struct kernel_param *kp)
> +{
> +	int value, rc;
> +
> +	rc = kstrtoint(val, 0, &value);
> +	if (rc) {
> +		CERROR("Invalid module parameter value for 'lnet_interfaces_max'\n");
> +		return rc;
> +	}
> +
> +	if (value < LNET_INTERFACES_MIN) {
> +		CWARN("max interfaces provided are too small, setting to %d\n",
> +		      LNET_INTERFACES_MIN);
> +		value = LNET_INTERFACES_MIN;
> +	}
> +
> +	*(int *)kp->arg = value;
> +
> +	return 0;
> +}
> +
>  static char *
>  lnet_get_routes(void)
>  {
> @@ -2924,7 +2954,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	infosz = offsetof(struct lnet_ping_info, pi_ni[n_ids]);
>  
>  	/* n_ids limit is arbitrary */
> -	if (n_ids <= 0 || n_ids > 20 || id.nid == LNET_NID_ANY)
> +	if (n_ids <= 0 || n_ids > lnet_interfaces_max || id.nid == LNET_NID_ANY)
>  		return -EINVAL;
>  
>  	if (id.pid == LNET_PID_ANY)
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 3ea56c81ec0e..087d9a8a6b6a 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -123,10 +123,10 @@ lnet_ni_unique_net(struct list_head *nilist, char *iface)
>  /* check that the NI is unique to the interfaces with in the same NI.
>   * This is only a consideration if use_tcp_bonding is set */
>  static bool
> -lnet_ni_unique_ni(char *iface_list[LNET_NUM_INTERFACES], char *iface)
> +lnet_ni_unique_ni(char *iface_list[LNET_INTERFACES_NUM], char *iface)
>  {
>  	int i;
> -	for (i = 0; i < LNET_NUM_INTERFACES; i++) {
> +	for (i = 0; i < LNET_INTERFACES_NUM; i++) {
>  		if (iface_list[i] &&
>  		    strncmp(iface_list[i], iface, strlen(iface)) == 0)
>  			return false;
> @@ -304,7 +304,7 @@ lnet_ni_free(struct lnet_ni *ni)
>  
>  	kfree(ni->ni_cpts);
>  
> -	for (i = 0; i < LNET_NUM_INTERFACES && ni->ni_interfaces[i]; i++)
> +	for (i = 0; i < LNET_INTERFACES_NUM && ni->ni_interfaces[i]; i++)
>  		kfree(ni->ni_interfaces[i]);
>  
>  	/* release reference to net namespace */
> @@ -397,11 +397,11 @@ lnet_ni_add_interface(struct lnet_ni *ni, char *iface)
>  	 * can free the tokens at the end of the function.
>  	 * The newly allocated ni_interfaces[] can be
>  	 * freed when freeing the NI */
> -	while (niface < LNET_NUM_INTERFACES &&
> +	while (niface < LNET_INTERFACES_NUM &&
>  	       ni->ni_interfaces[niface])
>  		niface++;
>  
> -	if (niface >= LNET_NUM_INTERFACES) {
> +	if (niface >= LNET_INTERFACES_NUM) {
>  		LCONSOLE_ERROR_MSG(0x115, "Too many interfaces "
>  				   "for net %s\n",
>  				   libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
> 
> 
> 
