From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Oct 2018 00:43:03 +0100 (BST)
Subject: [lustre-devel] [PATCH 20/24] lustre: lnet: add "lnetctl ping"
 command
In-Reply-To: <153895437832.16383.822062330627071137.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437832.16383.822062330627071137.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810150042110.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Adds function jt_ping() in lnetctl.c and
> lustre_lnet_ping_nid() in liblnetconfig.c file.
> The output of "lnetctl ping" is similar to
> "lnetctl peer show".
> 
> Function jt_ping() in lnetctl.c calls lustre_lnet_ping_nid()
> to implement "lnetctl ping". Adds a function infra_ping_nid()
> to be later reused for the ping similar lnetctl commands.
> Uses a new ioctl call, IOC_LIBCFS_PING_PEER for "lnetctl ping".
> With "lnetctl ping", multiple nids can be pinged. Uses a new
> struct(lnet_ioctl_ping_data in lib-dlc.h) to pass the data
> from kernel to user space for ping. Also changes lnet_ping()
> function and its input parameters in drivers/staging/lustre/lnet/lnet/api-ni.c

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Sonia Sharma <sonia.sharma@intel.com>
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25791
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    5 +-
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    2 -
>  .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    2 -
>  .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |    2 -
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   55 +++++++++++++++-----
>  drivers/staging/lustre/lnet/lnet/peer.c            |    2 -
>  6 files changed, 47 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 58e3a9c4e39f..adb4d0551ef5 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -76,8 +76,8 @@ extern struct lnet the_lnet;	/* THE network */
>  #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
>  #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
>  
> -/* Discovery timeout - same as default peer_timeout */
> -#define DISCOVERY_TIMEOUT	180
> +/* default timeout */
> +#define DEFAULT_PEER_TIMEOUT    180
>  
>  static inline int lnet_is_route_alive(struct lnet_route *route)
>  {
> @@ -716,6 +716,7 @@ struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
>  					    int cpt);
>  struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
>  struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
> +struct lnet_peer *lnet_find_peer(lnet_nid_t nid);
>  void lnet_peer_net_added(struct lnet_net *net);
>  lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
>  int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block);
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> index 2607620e8ef8..3d89202bd396 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> @@ -102,7 +102,7 @@ struct libcfs_debug_ioctl_data {
>  #define IOC_LIBCFS_CONFIGURE		   _IOWR('e', 59, IOCTL_LIBCFS_TYPE)
>  #define IOC_LIBCFS_TESTPROTOCOMPAT	   _IOWR('e', 60, IOCTL_LIBCFS_TYPE)
>  #define IOC_LIBCFS_PING			   _IOWR('e', 61, IOCTL_LIBCFS_TYPE)
> -/*	IOC_LIBCFS_DEBUG_PEER		   _IOWR('e', 62, IOCTL_LIBCFS_TYPE) */
> +#define IOC_LIBCFS_PING_PEER               _IOWR('e', 62, IOCTL_LIBCFS_TYPE)
>  #define IOC_LIBCFS_LNETST		   _IOWR('e', 63, IOCTL_LIBCFS_TYPE)
>  #define IOC_LIBCFS_LNET_FAULT		   _IOWR('e', 64, IOCTL_LIBCFS_TYPE)
>  /* lnd ioctls */
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
> index 0f2ad9110dc9..13b19f3eabf0 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
> @@ -83,7 +83,7 @@ static int peer_buffer_credits;
>  module_param(peer_buffer_credits, int, 0444);
>  MODULE_PARM_DESC(peer_buffer_credits, "# per-peer router buffer credits");
>  
> -static int peer_timeout = 180;
> +static int peer_timeout = DEFAULT_PEER_TIMEOUT;
>  module_param(peer_timeout, int, 0444);
>  MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer dead (<=0 to disable)");
>  
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> index 5663a4ca94d4..da5910049fc1 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> @@ -35,7 +35,7 @@ static int peer_buffer_credits;
>  module_param(peer_buffer_credits, int, 0444);
>  MODULE_PARM_DESC(peer_buffer_credits, "# per-peer router buffer credits");
>  
> -static int peer_timeout = 180;
> +static int peer_timeout = DEFAULT_PEER_TIMEOUT;
>  module_param(peer_timeout, int, 0444);
>  MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer dead (<=0 to disable)");
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index f624abe7db80..37f47bd1511f 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -3181,24 +3181,50 @@ LNetCtl(unsigned int cmd, void *arg)
>  		id.nid = data->ioc_nid;
>  		id.pid = data->ioc_u32[0];
>  
> -		/* Don't block longer than 2 minutes */
> -		if (data->ioc_u32[1] > 120 * MSEC_PER_SEC)
> -			return -EINVAL;
> -
> -		/* If timestamp is negative then disable timeout */
> -		if ((s32)data->ioc_u32[1] < 0)
> -			timeout = MAX_SCHEDULE_TIMEOUT;
> +		/* If timeout is negative then set default of 3 minutes */
> +		if (((s32)data->ioc_u32[1] <= 0) ||
> +		    data->ioc_u32[1] > (DEFAULT_PEER_TIMEOUT * MSEC_PER_SEC))
> +			timeout = DEFAULT_PEER_TIMEOUT * HZ;
>  		else
>  			timeout = msecs_to_jiffies(data->ioc_u32[1]);
>  
>  		rc = lnet_ping(id, timeout, data->ioc_pbuf1,
>  			       data->ioc_plen1 / sizeof(struct lnet_process_id));
> +
>  		if (rc < 0)
>  			return rc;
> +
>  		data->ioc_count = rc;
>  		return 0;
>  	}
>  
> +	case IOC_LIBCFS_PING_PEER: {
> +		struct lnet_ioctl_ping_data *ping = arg;
> +		struct lnet_peer *lp;
> +		signed long timeout;
> +
> +		/* If timeout is negative then set default of 3 minutes */
> +		if (((s32)ping->op_param) <= 0 ||
> +		    ping->op_param > (DEFAULT_PEER_TIMEOUT * MSEC_PER_SEC))
> +			timeout = DEFAULT_PEER_TIMEOUT * HZ;
> +		else
> +			timeout = msecs_to_jiffies(ping->op_param);
> +
> +		rc = lnet_ping(ping->ping_id, timeout,
> +			       ping->ping_buf,
> +			       ping->ping_count);
> +		if (rc < 0)
> +			return rc;
> +
> +		lp = lnet_find_peer(ping->ping_id.nid);
> +		if (lp) {
> +			ping->ping_id.nid = lp->lp_primary_nid;
> +			ping->mr_info = lnet_peer_is_multi_rail(lp);
> +		}
> +		ping->ping_count = rc;
> +		return 0;
> +	}
> +
>  	default:
>  		ni = lnet_net2ni_addref(data->ioc_net);
>  		if (!ni)
> @@ -3301,7 +3327,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	/* initialize md content */
>  	md.start     = &pbuf->pb_info;
>  	md.length    = LNET_PING_INFO_SIZE(n_ids);
> -	md.threshold = 2; /*GET/REPLY*/
> +	md.threshold = 2; /* GET/REPLY */
>  	md.max_size  = 0;
>  	md.options   = LNET_MD_TRUNCATE;
>  	md.user_ptr  = NULL;
> @@ -3319,7 +3345,6 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  
>  	if (rc) {
>  		/* Don't CERROR; this could be deliberate! */
> -
>  		rc2 = LNetMDUnlink(mdh);
>  		LASSERT(!rc2);
>  
> @@ -3363,7 +3388,6 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  			replied = 1;
>  			rc = event.mlength;
>  		}
> -
>  	} while (rc2 <= 0 || !event.unlinked);
>  
>  	if (!replied) {
> @@ -3377,10 +3401,9 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	nob = rc;
>  	LASSERT(nob >= 0 && nob <= LNET_PING_INFO_SIZE(n_ids));
>  
> -	rc = -EPROTO;			   /* if I can't parse... */
> +	rc = -EPROTO;		/* if I can't parse... */
>  
>  	if (nob < 8) {
> -		/* can't check magic/version */
>  		CERROR("%s: ping info too short %d\n",
>  		       libcfs_id2str(id), nob);
>  		goto fail_free_eq;
> @@ -3401,7 +3424,8 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	}
>  
>  	if (nob < LNET_PING_INFO_SIZE(0)) {
> -		CERROR("%s: Short reply %d(%d min)\n", libcfs_id2str(id),
> +		CERROR("%s: Short reply %d(%d min)\n",
> +		       libcfs_id2str(id),
>  		       nob, (int)LNET_PING_INFO_SIZE(0));
>  		goto fail_free_eq;
>  	}
> @@ -3410,12 +3434,13 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  		n_ids = pbuf->pb_info.pi_nnis;
>  
>  	if (nob < LNET_PING_INFO_SIZE(n_ids)) {
> -		CERROR("%s: Short reply %d(%d expected)\n", libcfs_id2str(id),
> +		CERROR("%s: Short reply %d(%d expected)\n",
> +		       libcfs_id2str(id),
>  		       nob, (int)LNET_PING_INFO_SIZE(n_ids));
>  		goto fail_free_eq;
>  	}
>  
> -	rc = -EFAULT;			   /* If I SEGV... */
> +	rc = -EFAULT;		/* if I segv in copy_to_user()... */
>  
>  	memset(&tmpid, 0, sizeof(tmpid));
>  	for (i = 0; i < n_ids; i++) {
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 8dff3b767577..95f72ae39a89 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -2905,7 +2905,7 @@ static struct lnet_peer *lnet_peer_dc_timed_out(time64_t now)
>  		return NULL;
>  	lp = list_first_entry(&the_lnet.ln_dc_working,
>  			      struct lnet_peer, lp_dc_list);
> -	if (now < lp->lp_last_queued + DISCOVERY_TIMEOUT)
> +	if (now < lp->lp_last_queued + DEFAULT_PEER_TIMEOUT)
>  		return NULL;
>  	return lp;
>  }
> 
> 
> 
