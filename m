From: Jeff Becker <jeffrey.c.becker@nasa.gov>
Date: Thu, 20 Aug 2015 14:39:41 -0700
Subject: [lustre-devel] [PATCH] Example of better reformatting
 Signed-off-by: Ben Evans	<bevans@cray.com>
In-Reply-To: <20150820204516.GA26830@lusbld01.us.cray.com>
References: <20150820204516.GA26830@lusbld01.us.cray.com>
Message-ID: <55D6491D.5080702@nasa.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 08/20/2015 01:45 PM, Ben Evans wrote:
> I'm with James on the previous patch being ugly.  Something like this is much cleaner.  My opinion may not necessarily align with anyone elses.

I am happy to resubmit following this idea, if that is preferred. Thanks.

-jeff
> ---
>   .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   58 +++++++++-----------
>   1 files changed, 26 insertions(+), 32 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> index f5d1d9f..cc4872d 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> @@ -79,39 +79,33 @@
>   #define IBLND_N_SCHED_HIGH		4
>   
>   typedef struct {
> -	int          *kib_dev_failover;      /* HCA failover */
> +	int *kib_dev_failover;      /* HCA failover */
>   	unsigned int *kib_service;           /* IB service number */
> -	int          *kib_min_reconnect_interval; /* first failed connection
> -						   * retry... */
> -	int          *kib_max_reconnect_interval; /* ...exponentially increasing
> -						   * to this */
> -	int          *kib_cksum;             /* checksum kib_msg_t? */
> -	int          *kib_timeout;           /* comms timeout (seconds) */
> -	int          *kib_keepalive;         /* keepalive timeout (seconds) */
> -	int          *kib_ntx;               /* # tx descs */
> -	int          *kib_credits;           /* # concurrent sends */
> -	int          *kib_peertxcredits;     /* # concurrent sends to 1 peer */
> -	int          *kib_peerrtrcredits;    /* # per-peer router buffer
> -					      * credits */
> -	int          *kib_peercredits_hiw;   /* # when eagerly to return
> -					      * credits */
> -	int          *kib_peertimeout;       /* seconds to consider peer dead */
> -	char         **kib_default_ipif;     /* default IPoIB interface */
> -	int          *kib_retry_count;
> -	int          *kib_rnr_retry_count;
> -	int          *kib_concurrent_sends;  /* send work queue sizing */
> -	int          *kib_ib_mtu;            /* IB MTU */
> -	int          *kib_map_on_demand;     /* map-on-demand if RD has more
> -					      * fragments than this value, 0
> -					      * disable map-on-demand */
> -	int          *kib_pmr_pool_size;     /* # physical MR in pool */
> -	int          *kib_fmr_pool_size;     /* # FMRs in pool */
> -	int          *kib_fmr_flush_trigger; /* When to trigger FMR flush */
> -	int          *kib_fmr_cache;         /* enable FMR pool cache? */
> -	int          *kib_require_priv_port; /* accept only privileged ports */
> -	int          *kib_use_priv_port;     /* use privileged port for active
> -					      * connect */
> -	int          *kib_nscheds;           /* # threads on each CPT */
> +	int *kib_min_reconnect_interval; /* first failed connection retry */
> +	int *kib_max_reconnect_interval; /* exponentially increase to this */
> +	int *kib_cksum;             /* checksum kib_msg_t? */
> +	int *kib_timeout;           /* comms timeout (seconds) */
> +	int *kib_keepalive;         /* keepalive timeout (seconds) */
> +	int *kib_ntx;               /* # tx descs */
> +	int *kib_credits;           /* # concurrent sends */
> +	int *kib_peertxcredits;     /* # concurrent sends to 1 peer */
> +	int *kib_peerrtrcredits;    /* # per-peer router buffer credits */
> +	int *kib_peercredits_hiw;   /* # when eagerly to return credits */
> +	int *kib_peertimeout;       /* seconds to consider peer dead */
> +	char **kib_default_ipif;     /* default IPoIB interface */
> +	int *kib_retry_count;
> +	int *kib_rnr_retry_count;
> +	int *kib_concurrent_sends;  /* send work queue sizing */
> +	int *kib_ib_mtu;            /* IB MTU */
> +	int *kib_map_on_demand;     /* map-on-demand if RD has more fragments
> +				       than this value, 0=disable */
> +	int *kib_pmr_pool_size;     /* # physical MR in pool */
> +	int *kib_fmr_pool_size;     /* # FMRs in pool */
> +	int *kib_fmr_flush_trigger; /* When to trigger FMR flush */
> +	int *kib_fmr_cache;         /* enable FMR pool cache? */
> +	int *kib_require_priv_port; /* accept only privileged ports */
> +	int *kib_use_priv_port;     /* use priv. port for active connect */
> +	int *kib_nscheds;           /* # threads on each CPT */
>   } kib_tunables_t;
>   
>   extern kib_tunables_t  kiblnd_tunables;
