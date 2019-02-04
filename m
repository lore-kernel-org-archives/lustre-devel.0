From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Feb 2019 14:13:10 +1100
Subject: [lustre-devel] [PATCH 24/26] lnet: cleanup white spaces
In-Reply-To: <1548955170-13456-25-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
 <1548955170-13456-25-git-send-email-jsimmons@infradead.org>
Message-ID: <87a7jcjlfd.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 31 2019, James Simmons wrote:

> The LNet core code is very messy and difficult to read. Remove
> excess white space and properly align data structures so they
> are easy on the eyes.
>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---

> @@ -218,7 +218,7 @@ struct lnet_lnd {
>  	 */
>  
>  	/*
> -	 * Start sending a preformatted message.  'private' is NULL for PUT and
> +	 * Start sending a preformatted message.x  'private' is NULL for PUT and
>  	 * GET messages; otherwise this is a response to an incoming message
>  	 * and 'private' is the 'private' passed to lnet_parse().  Return
>  	 * non-zero for immediate failure, otherwise complete later with

I suspect you just added that 'x' to see if anyone really read you patch
I did.  I found it.  I've removed it.

:-)

NeilBrown


> @@ -267,7 +267,7 @@ struct lnet_tx_queue {
>  
>  enum lnet_ni_state {
>  	/* set when NI block is allocated */
> -	LNET_NI_STATE_INIT = 0,
> +	LNET_NI_STATE_INIT	= 0,
>  	/* set when NI is started successfully */
>  	LNET_NI_STATE_ACTIVE,
>  	/* set when LND notifies NI failed */
> @@ -279,23 +279,23 @@ enum lnet_ni_state {
>  };
>  
>  enum lnet_stats_type {
> -	LNET_STATS_TYPE_SEND = 0,
> +	LNET_STATS_TYPE_SEND	= 0,
>  	LNET_STATS_TYPE_RECV,
>  	LNET_STATS_TYPE_DROP
>  };
>  
>  struct lnet_comm_count {
> -	atomic_t co_get_count;
> -	atomic_t co_put_count;
> -	atomic_t co_reply_count;
> -	atomic_t co_ack_count;
> -	atomic_t co_hello_count;
> +	atomic_t		co_get_count;
> +	atomic_t		co_put_count;
> +	atomic_t		co_reply_count;
> +	atomic_t		co_ack_count;
> +	atomic_t		co_hello_count;
>  };
>  
>  struct lnet_element_stats {
> -	struct lnet_comm_count el_send_stats;
> -	struct lnet_comm_count el_recv_stats;
> -	struct lnet_comm_count el_drop_stats;
> +	struct lnet_comm_count	el_send_stats;
> +	struct lnet_comm_count	el_recv_stats;
> +	struct lnet_comm_count	el_drop_stats;
>  };
>  
>  struct lnet_net {
> @@ -376,7 +376,7 @@ struct lnet_ni {
>  	struct lnet_lnd_tunables ni_lnd_tunables;
>  
>  	/* lnd tunables set explicitly */
> -	bool ni_lnd_tunables_set;
> +	bool			ni_lnd_tunables_set;
>  
>  	/* NI statistics */
>  	struct lnet_element_stats ni_stats;
> @@ -391,9 +391,9 @@ struct lnet_ni {
>  	 * equivalent interfaces to use
>  	 * This is an array because socklnd bonding can still be configured
>  	 */
> -	char			 *ni_interfaces[LNET_INTERFACES_NUM];
> +	char			*ni_interfaces[LNET_INTERFACES_NUM];
>  	/* original net namespace */
> -	struct net		 *ni_net_ns;
> +	struct net		*ni_net_ns;
>  };
>  
>  #define LNET_PROTO_PING_MATCHBITS	0x8000000000000000LL
> @@ -434,9 +434,9 @@ struct lnet_rc_data {
>  
>  struct lnet_peer_ni {
>  	/* chain on lpn_peer_nis */
> -	struct list_head	lpni_peer_nis;
> +	struct list_head	 lpni_peer_nis;
>  	/* chain on remote peer list */
> -	struct list_head	lpni_on_remote_peer_ni_list;
> +	struct list_head	 lpni_on_remote_peer_ni_list;
>  	/* chain on peer hash */
>  	struct list_head	 lpni_hashlist;
>  	/* messages blocking for tx credits */
> @@ -448,7 +448,7 @@ struct lnet_peer_ni {
>  	/* statistics kept on each peer NI */
>  	struct lnet_element_stats lpni_stats;
>  	/* spin lock protecting credits and lpni_txq / lpni_rtrq */
> -	spinlock_t		lpni_lock;
> +	spinlock_t		 lpni_lock;
>  	/* # tx credits available */
>  	int			 lpni_txcredits;
>  	struct lnet_peer_net	*lpni_peer_net;
> @@ -491,26 +491,26 @@ struct lnet_peer_ni {
>  	/* CPT this peer attached on */
>  	int			 lpni_cpt;
>  	/* state flags -- protected by lpni_lock */
> -	unsigned int		lpni_state;
> +	unsigned int		 lpni_state;
>  	/* # refs from lnet_route::lr_gateway */
>  	int			 lpni_rtr_refcount;
>  	/* sequence number used to round robin over peer nis within a net */
> -	u32			lpni_seq;
> +	u32			 lpni_seq;
>  	/* sequence number used to round robin over gateways */
> -	u32			lpni_gw_seq;
> +	u32			 lpni_gw_seq;
>  	/* health flag */
> -	bool			lpni_healthy;
> +	bool			 lpni_healthy;
>  	/* returned RC ping features. Protected with lpni_lock */
>  	unsigned int		 lpni_ping_feats;
>  	/* routers on this peer */
>  	struct list_head	 lpni_routes;
>  	/* preferred local nids: if only one, use lpni_pref.nid */
>  	union lpni_pref {
> -		lnet_nid_t	nid;
> +		lnet_nid_t	 nid;
>  		lnet_nid_t	*nids;
>  	} lpni_pref;
>  	/* number of preferred NIDs in lnpi_pref_nids */
> -	u32			lpni_pref_nnids;
> +	u32			 lpni_pref_nnids;
>  	/* router checker state */
>  	struct lnet_rc_data	*lpni_rcd;
>  };
> @@ -676,9 +676,9 @@ struct lnet_peer_table {
>  	/* # peers extant */
>  	atomic_t		 pt_number;
>  	/* peers */
> -	struct list_head	pt_peer_list;
> +	struct list_head	 pt_peer_list;
>  	/* # peers */
> -	int			pt_peers;
> +	int			 pt_peers;
>  	/* # zombies to go to deathrow (and not there yet) */
>  	int			 pt_zombies;
>  	/* zombie peers_ni */
> @@ -704,7 +704,7 @@ struct lnet_route {
>  	/* chain on gateway */
>  	struct list_head	lr_gwlist;
>  	/* router node */
> -	struct lnet_peer_ni	*lr_gateway;
> +	struct lnet_peer_ni    *lr_gateway;
>  	/* remote network number */
>  	u32			lr_net;
>  	/* sequence for round-robin */
> @@ -754,9 +754,9 @@ struct lnet_rtrbufpool {
>  };
>  
>  struct lnet_rtrbuf {
> -	struct list_head	 rb_list;	/* chain on rbp_bufs */
> -	struct lnet_rtrbufpool	*rb_pool;	/* owning pool */
> -	struct bio_vec		 rb_kiov[0];	/* the buffer space */
> +	struct list_head	rb_list;	/* chain on rbp_bufs */
> +	struct lnet_rtrbufpool *rb_pool;	/* owning pool */
> +	struct bio_vec		rb_kiov[0];	/* the buffer space */
>  };
>  
>  #define LNET_PEER_HASHSIZE	503	/* prime! */
> @@ -904,58 +904,58 @@ enum lnet_state {
>  
>  struct lnet {
>  	/* CPU partition table of LNet */
> -	struct cfs_cpt_table		 *ln_cpt_table;
> +	struct cfs_cpt_table	       *ln_cpt_table;
>  	/* number of CPTs in ln_cpt_table */
> -	unsigned int			  ln_cpt_number;
> -	unsigned int			  ln_cpt_bits;
> +	unsigned int			ln_cpt_number;
> +	unsigned int			ln_cpt_bits;
>  
>  	/* protect LNet resources (ME/MD/EQ) */
> -	struct cfs_percpt_lock		 *ln_res_lock;
> +	struct cfs_percpt_lock	       *ln_res_lock;
>  	/* # portals */
> -	int				  ln_nportals;
> +	int				ln_nportals;
>  	/* the vector of portals */
> -	struct lnet_portal		**ln_portals;
> +	struct lnet_portal	      **ln_portals;
>  	/* percpt ME containers */
> -	struct lnet_res_container	**ln_me_containers;
> +	struct lnet_res_container     **ln_me_containers;
>  	/* percpt MD container */
> -	struct lnet_res_container	**ln_md_containers;
> +	struct lnet_res_container     **ln_md_containers;
>  
>  	/* Event Queue container */
> -	struct lnet_res_container	  ln_eq_container;
> -	wait_queue_head_t		  ln_eq_waitq;
> -	spinlock_t			  ln_eq_wait_lock;
> -	unsigned int			  ln_remote_nets_hbits;
> +	struct lnet_res_container	ln_eq_container;
> +	wait_queue_head_t		ln_eq_waitq;
> +	spinlock_t			ln_eq_wait_lock;
> +	unsigned int			ln_remote_nets_hbits;
>  
>  	/* protect NI, peer table, credits, routers, rtrbuf... */
> -	struct cfs_percpt_lock		 *ln_net_lock;
> +	struct cfs_percpt_lock	       *ln_net_lock;
>  	/* percpt message containers for active/finalizing/freed message */
> -	struct lnet_msg_container	**ln_msg_containers;
> -	struct lnet_counters		**ln_counters;
> -	struct lnet_peer_table		**ln_peer_tables;
> +	struct lnet_msg_container     **ln_msg_containers;
> +	struct lnet_counters	      **ln_counters;
> +	struct lnet_peer_table	      **ln_peer_tables;
>  	/* list of peer nis not on a local network */
>  	struct list_head		ln_remote_peer_ni_list;
>  	/* failure simulation */
> -	struct list_head		  ln_test_peers;
> -	struct list_head		  ln_drop_rules;
> -	struct list_head		  ln_delay_rules;
> +	struct list_head		ln_test_peers;
> +	struct list_head		ln_drop_rules;
> +	struct list_head		ln_delay_rules;
>  
>  	/* LND instances */
>  	struct list_head		ln_nets;
>  	/* network zombie list */
>  	struct list_head		ln_net_zombie;
>  	/* the loopback NI */
> -	struct lnet_ni			*ln_loni;
> +	struct lnet_ni		       *ln_loni;
>  
>  	/* remote networks with routes to them */
> -	struct list_head		 *ln_remote_nets_hash;
> +	struct list_head	       *ln_remote_nets_hash;
>  	/* validity stamp */
> -	u64				  ln_remote_nets_version;
> +	u64				ln_remote_nets_version;
>  	/* list of all known routers */
> -	struct list_head		  ln_routers;
> +	struct list_head		ln_routers;
>  	/* validity stamp */
> -	u64				  ln_routers_version;
> +	u64				ln_routers_version;
>  	/* percpt router buffer pools */
> -	struct lnet_rtrbufpool		**ln_rtrpools;
> +	struct lnet_rtrbufpool	      **ln_rtrpools;
>  
>  	/*
>  	 * Ping target / Push source
> @@ -964,9 +964,9 @@ struct lnet {
>  	 * ln_ping_target is protected against concurrent updates by
>  	 * ln_api_mutex.
>  	 */
> -	struct lnet_handle_md		  ln_ping_target_md;
> -	struct lnet_handle_eq		  ln_ping_target_eq;
> -	struct lnet_ping_buffer		 *ln_ping_target;
> +	struct lnet_handle_md		ln_ping_target_md;
> +	struct lnet_handle_eq		ln_ping_target_eq;
> +	struct lnet_ping_buffer	       *ln_ping_target;
>  	atomic_t			ln_ping_target_seqno;
>  
>  	/*
> @@ -979,7 +979,7 @@ struct lnet {
>  	 */
>  	struct lnet_handle_eq		ln_push_target_eq;
>  	struct lnet_handle_md		ln_push_target_md;
> -	struct lnet_ping_buffer		*ln_push_target;
> +	struct lnet_ping_buffer	       *ln_push_target;
>  	int				ln_push_target_nnis;
>  
>  	/* discovery event queue handle */
> @@ -996,35 +996,35 @@ struct lnet {
>  	int				ln_dc_state;
>  
>  	/* router checker startup/shutdown state */
> -	enum lnet_rc_state		  ln_rc_state;
> +	enum lnet_rc_state		ln_rc_state;
>  	/* router checker's event queue */
> -	struct lnet_handle_eq		  ln_rc_eqh;
> +	struct lnet_handle_eq		ln_rc_eqh;
>  	/* rcd still pending on net */
> -	struct list_head		  ln_rcd_deathrow;
> +	struct list_head		ln_rcd_deathrow;
>  	/* rcd ready for free */
> -	struct list_head		  ln_rcd_zombie;
> +	struct list_head		ln_rcd_zombie;
>  	/* serialise startup/shutdown */
> -	struct completion		  ln_rc_signal;
> +	struct completion		ln_rc_signal;
>  
> -	struct mutex			  ln_api_mutex;
> -	struct mutex			  ln_lnd_mutex;
> -	struct mutex			  ln_delay_mutex;
> +	struct mutex			ln_api_mutex;
> +	struct mutex			ln_lnd_mutex;
> +	struct mutex			ln_delay_mutex;
>  	/* Have I called LNetNIInit myself? */
> -	int				  ln_niinit_self;
> +	int				ln_niinit_self;
>  	/* LNetNIInit/LNetNIFini counter */
> -	int				  ln_refcount;
> +	int				ln_refcount;
>  	/* SHUTDOWN/RUNNING/STOPPING */
> -	enum lnet_state			  ln_state;
> +	enum lnet_state			ln_state;
>  
> -	int				  ln_routing;	/* am I a router? */
> -	lnet_pid_t			  ln_pid;	/* requested pid */
> +	int				ln_routing;	/* am I a router? */
> +	lnet_pid_t			ln_pid;		/* requested pid */
>  	/* uniquely identifies this ni in this epoch */
> -	u64				  ln_interface_cookie;
> +	u64				ln_interface_cookie;
>  	/* registered LNDs */
> -	struct list_head		  ln_lnds;
> +	struct list_head		ln_lnds;
>  
>  	/* test protocol compatibility flags */
> -	int				  ln_testprotocompat;
> +	int				ln_testprotocompat;
>  
>  	/*
>  	 * 0 - load the NIs from the mod params
> @@ -1032,14 +1032,14 @@ struct lnet {
>  	 * Reverse logic to ensure that other calls to LNetNIInit
>  	 * need no change
>  	 */
> -	bool				  ln_nis_from_mod_params;
> +	bool				ln_nis_from_mod_params;
>  
>  	/*
>  	 * waitq for router checker.  As long as there are no routes in
>  	 * the list, the router checker will sleep on this queue.  when
>  	 * routes are added the thread will wake up
>  	 */
> -	wait_queue_head_t		  ln_rc_waitq;
> +	wait_queue_head_t		ln_rc_waitq;
>  
>  };
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
> index aa28a9f..83ab3b1 100644
> --- a/drivers/staging/lustre/lnet/lnet/acceptor.c
> +++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
> @@ -36,9 +36,9 @@
>  #include <net/sock.h>
>  #include <linux/lnet/lib-lnet.h>
>  
> -static int   accept_port    = 988;
> -static int   accept_backlog = 127;
> -static int   accept_timeout = 5;
> +static int accept_port = 988;
> +static int accept_backlog = 127;
> +static int accept_timeout = 5;
>  
>  static struct {
>  	int			pta_shutdown;
> @@ -167,9 +167,9 @@
>  
>  		BUILD_BUG_ON(LNET_PROTO_ACCEPTOR_VERSION != 1);
>  
> -		cr.acr_magic   = LNET_PROTO_ACCEPTOR_MAGIC;
> +		cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
>  		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
> -		cr.acr_nid     = peer_nid;
> +		cr.acr_nid = peer_nid;
>  
>  		if (the_lnet.ln_testprotocompat) {
>  			/* single-shot proto check */
> @@ -196,9 +196,9 @@
>  	rc = -EADDRINUSE;
>  	goto failed;
>  
> - failed_sock:
> +failed_sock:
>  	sock_release(sock);
> - failed:
> +failed:
>  	lnet_connect_console_error(rc, peer_nid, peer_ip, peer_port);
>  	return rc;
>  }
> @@ -297,7 +297,7 @@
>  		__swab64s(&cr.acr_nid);
>  
>  	ni = lnet_nid2ni_addref(cr.acr_nid);
> -	if (!ni ||	       /* no matching net */
> +	if (!ni ||			/* no matching net */
>  	    ni->ni_nid != cr.acr_nid) { /* right NET, wrong NID! */
>  		if (ni)
>  			lnet_ni_decref(ni);
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index be77e10..64b8bef9 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -47,7 +47,7 @@
>   * before module init completes. The mutex needs to be ready for use then.
>   */
>  struct lnet the_lnet = {
> -	.ln_api_mutex = __MUTEX_INITIALIZER(the_lnet.ln_api_mutex),
> +	.ln_api_mutex		= __MUTEX_INITIALIZER(the_lnet.ln_api_mutex),
>  };		/* THE state of the network */
>  EXPORT_SYMBOL(the_lnet);
>  
> @@ -281,7 +281,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
>  
>  	return 0;
>  
> - failed:
> +failed:
>  	lnet_destroy_locks();
>  	return -ENOMEM;
>  }
> @@ -476,17 +476,17 @@ static void lnet_assert_wire_constants(void)
>  	lnet_net_lock(LNET_LOCK_EX);
>  
>  	cfs_percpt_for_each(ctr, i, the_lnet.ln_counters) {
> -		counters->msgs_max     += ctr->msgs_max;
> -		counters->msgs_alloc   += ctr->msgs_alloc;
> -		counters->errors       += ctr->errors;
> -		counters->send_count   += ctr->send_count;
> -		counters->recv_count   += ctr->recv_count;
> -		counters->route_count  += ctr->route_count;
> -		counters->drop_count   += ctr->drop_count;
> -		counters->send_length  += ctr->send_length;
> -		counters->recv_length  += ctr->recv_length;
> +		counters->msgs_max += ctr->msgs_max;
> +		counters->msgs_alloc += ctr->msgs_alloc;
> +		counters->errors += ctr->errors;
> +		counters->send_count += ctr->send_count;
> +		counters->recv_count += ctr->recv_count;
> +		counters->route_count += ctr->route_count;
> +		counters->drop_count += ctr->drop_count;
> +		counters->send_length += ctr->send_length;
> +		counters->recv_length += ctr->recv_length;
>  		counters->route_length += ctr->route_length;
> -		counters->drop_length  += ctr->drop_length;
> +		counters->drop_length += ctr->drop_length;
>  	}
>  	lnet_net_unlock(LNET_LOCK_EX);
>  }
> @@ -755,7 +755,7 @@ struct lnet_libhandle *
>  
>  	return 0;
>  
> - failed:
> +failed:
>  	lnet_unprepare();
>  	return rc;
>  }
> @@ -942,7 +942,7 @@ struct lnet_net *
>  	return false;
>  }
>  
> -struct lnet_ni  *
> +struct lnet_ni *
>  lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
>  {
>  	struct lnet_net *net;
> @@ -1146,8 +1146,10 @@ struct lnet_ping_buffer *
>  		       struct lnet_handle_md *ping_mdh,
>  		       int ni_count, bool set_eq)
>  {
> -	struct lnet_process_id id = { .nid = LNET_NID_ANY,
> -				      .pid = LNET_PID_ANY };
> +	struct lnet_process_id id = {
> +		.nid = LNET_NID_ANY,
> +		.pid = LNET_PID_ANY
> +	};
>  	struct lnet_handle_me me_handle;
>  	struct lnet_md md = { NULL };
>  	int rc, rc2;
> @@ -1244,7 +1246,7 @@ struct lnet_ping_buffer *
>  
>  			lnet_ni_lock(ni);
>  			ns->ns_status = ni->ni_status ?
> -					 ni->ni_status->ns_status :
> +					ni->ni_status->ns_status :
>  						LNET_NI_STATUS_UP;
>  			ni->ni_status = ns;
>  			lnet_ni_unlock(ni);
> @@ -1322,7 +1324,10 @@ struct lnet_ping_buffer *
>  /* Resize the push target. */
>  int lnet_push_target_resize(void)
>  {
> -	struct lnet_process_id id = { LNET_NID_ANY, LNET_PID_ANY };
> +	struct lnet_process_id id = {
> +		.nid	= LNET_NID_ANY,
> +		.pid	= LNET_PID_ANY
> +	};
>  	struct lnet_md md = { NULL };
>  	struct lnet_handle_me meh;
>  	struct lnet_handle_md mdh;
> @@ -1353,13 +1358,13 @@ int lnet_push_target_resize(void)
>  	}
>  
>  	/* initialize md content */
> -	md.start     = &pbuf->pb_info;
> -	md.length    = LNET_PING_INFO_SIZE(nnis);
> +	md.start = &pbuf->pb_info;
> +	md.length = LNET_PING_INFO_SIZE(nnis);
>  	md.threshold = LNET_MD_THRESH_INF;
> -	md.max_size  = 0;
> -	md.options   = LNET_MD_OP_PUT | LNET_MD_TRUNCATE |
> -		       LNET_MD_MANAGE_REMOTE;
> -	md.user_ptr  = pbuf;
> +	md.max_size = 0;
> +	md.options = LNET_MD_OP_PUT | LNET_MD_TRUNCATE |
> +		     LNET_MD_MANAGE_REMOTE;
> +	md.user_ptr = pbuf;
>  	md.eq_handle = the_lnet.ln_push_target_eq;
>  
>  	rc = LNetMDAttach(meh, md, LNET_RETAIN, &mdh);
> @@ -1428,7 +1433,6 @@ static int lnet_push_target_init(void)
>  	the_lnet.ln_push_target_nnis = LNET_INTERFACES_MIN;
>  
>  	rc = lnet_push_target_resize();
> -
>  	if (rc) {
>  		LNetEQFree(the_lnet.ln_push_target_eq);
>  		LNetInvalidateEQHandle(&the_lnet.ln_push_target_eq);
> @@ -1723,10 +1727,10 @@ static void lnet_push_target_fini(void)
>  
>  	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
>  	       libcfs_nid2str(ni->ni_nid),
> -		ni->ni_net->net_tunables.lct_peer_tx_credits,
> +	       ni->ni_net->net_tunables.lct_peer_tx_credits,
>  	       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
>  	       ni->ni_net->net_tunables.lct_peer_rtr_credits,
> -		ni->ni_net->net_tunables.lct_peer_timeout);
> +	       ni->ni_net->net_tunables.lct_peer_timeout);
>  
>  	return 0;
>  failed0:
> @@ -1932,7 +1936,6 @@ static void lnet_push_target_fini(void)
>  		list_del_init(&net->net_list);
>  
>  		rc = lnet_startup_lndnet(net, NULL);
> -
>  		if (rc < 0)
>  			goto failed;
>  
> @@ -1963,8 +1966,8 @@ int lnet_lib_init(void)
>  	lnet_assert_wire_constants();
>  
>  	/* refer to global cfs_cpt_tab for now */
> -	the_lnet.ln_cpt_table	= cfs_cpt_tab;
> -	the_lnet.ln_cpt_number	= cfs_cpt_number(cfs_cpt_tab);
> +	the_lnet.ln_cpt_table = cfs_cpt_tab;
> +	the_lnet.ln_cpt_number = cfs_cpt_number(cfs_cpt_tab);
>  
>  	LASSERT(the_lnet.ln_cpt_number > 0);
>  	if (the_lnet.ln_cpt_number > LNET_CPT_MAX) {
> @@ -2409,7 +2412,7 @@ struct lnet_ni *
>  	if (!prev) {
>  		if (!net)
>  			net = list_entry(the_lnet.ln_nets.next, struct lnet_net,
> -					net_list);
> +					 net_list);
>  		ni = list_entry(net->net_ni_list.next, struct lnet_ni,
>  				ni_netlist);
>  
> @@ -2455,7 +2458,6 @@ struct lnet_ni *
>  	cpt = lnet_net_lock_current();
>  
>  	ni = lnet_get_ni_idx_locked(idx);
> -
>  	if (ni) {
>  		rc = 0;
>  		lnet_ni_lock(ni);
> @@ -2483,7 +2485,6 @@ struct lnet_ni *
>  	cpt = lnet_net_lock_current();
>  
>  	ni = lnet_get_ni_idx_locked(cfg_ni->lic_idx);
> -
>  	if (ni) {
>  		rc = 0;
>  		lnet_ni_lock(ni);
> @@ -2705,7 +2706,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
>  	struct lnet_ni *ni;
>  	u32 net_id = LNET_NIDNET(conf->lic_nid);
>  	struct lnet_ping_buffer *pbuf;
> -	struct lnet_handle_md  ping_mdh;
> +	struct lnet_handle_md ping_mdh;
>  	int rc;
>  	int net_count;
>  	u32 addr;
> @@ -2912,7 +2913,7 @@ u32 lnet_get_dlc_seq_locked(void)
>  {
>  	struct libcfs_ioctl_data *data = arg;
>  	struct lnet_ioctl_config_data *config;
> -	struct lnet_process_id id = {0};
> +	struct lnet_process_id id = { 0 };
>  	struct lnet_ni *ni;
>  	int rc;
>  
> @@ -3357,7 +3358,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	int which;
>  	int unlinked = 0;
>  	int replied = 0;
> -	const signed long a_long_time = 60*HZ;
> +	const signed long a_long_time = 60 * HZ;
>  	struct lnet_ping_buffer *pbuf;
>  	struct lnet_process_id tmpid;
>  	int i;
> @@ -3384,12 +3385,12 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	}
>  
>  	/* initialize md content */
> -	md.start     = &pbuf->pb_info;
> -	md.length    = LNET_PING_INFO_SIZE(n_ids);
> +	md.start = &pbuf->pb_info;
> +	md.length = LNET_PING_INFO_SIZE(n_ids);
>  	md.threshold = 2; /* GET/REPLY */
> -	md.max_size  = 0;
> -	md.options   = LNET_MD_TRUNCATE;
> -	md.user_ptr  = NULL;
> +	md.max_size = 0;
> +	md.options = LNET_MD_TRUNCATE;
> +	md.user_ptr = NULL;
>  	md.eq_handle = eqh;
>  
>  	rc = LNetMDBind(md, LNET_UNLINK, &mdh);
> @@ -3401,7 +3402,6 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	rc = LNetGet(LNET_NID_ANY, mdh, id,
>  		     LNET_RESERVED_PORTAL,
>  		     LNET_PROTO_PING_MATCHBITS, 0);
> -
>  	if (rc) {
>  		/* Don't CERROR; this could be deliberate! */
>  		rc2 = LNetMDUnlink(mdh);
> @@ -3414,7 +3414,6 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  
>  	do {
>  		/* MUST block for unlink to complete */
> -
>  		rc2 = LNetEQPoll(&eqh, 1, timeout, !unlinked,
>  				 &event, &which);
>  
> @@ -3510,13 +3509,13 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  	}
>  	rc = pbuf->pb_info.pi_nnis;
>  
> - fail_free_eq:
> +fail_free_eq:
>  	rc2 = LNetEQFree(eqh);
>  	if (rc2)
>  		CERROR("rc2 %d\n", rc2);
>  	LASSERT(!rc2);
>  
> - fail_ping_buffer_decref:
> +fail_ping_buffer_decref:
>  	lnet_ping_buffer_decref(pbuf);
>  	return rc;
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 16c42bf..ecf656b 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -38,15 +38,15 @@
>  #include <linux/lnet/lib-lnet.h>
>  #include <linux/inetdevice.h>
>  
> -struct lnet_text_buf {	    /* tmp struct for parsing routes */
> -	struct list_head ltb_list;	/* stash on lists */
> -	int ltb_size;	/* allocated size */
> -	char ltb_text[0];     /* text buffer */
> +struct lnet_text_buf {		/* tmp struct for parsing routes */
> +	struct list_head	ltb_list;	/* stash on lists */
> +	int			ltb_size;	/* allocated size */
> +	char			ltb_text[0];	/* text buffer */
>  };
>  
> -static int lnet_tbnob;			/* track text buf allocation */
> -#define LNET_MAX_TEXTBUF_NOB     (64 << 10)	/* bound allocation */
> -#define LNET_SINGLE_TEXTBUF_NOB  (4 << 10)
> +static int lnet_tbnob;		/* track text buf allocation */
> +#define LNET_MAX_TEXTBUF_NOB	(64 << 10)	/* bound allocation */
> +#define LNET_SINGLE_TEXTBUF_NOB	(4 << 10)
>  
>  #define SPACESTR " \t\v\r\n"
>  #define DELIMITERS ":()[]"
> @@ -126,6 +126,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
>  lnet_ni_unique_ni(char *iface_list[LNET_INTERFACES_NUM], char *iface)
>  {
>  	int i;
> +
>  	for (i = 0; i < LNET_INTERFACES_NUM; i++) {
>  		if (iface_list[i] &&
>  		    strncmp(iface_list[i], iface, strlen(iface)) == 0)
> @@ -554,7 +555,7 @@ struct lnet_ni *
>  		goto failed;
>  
>  	return ni;
> - failed:
> +failed:
>  	lnet_ni_free(ni);
>  	return NULL;
>  }
> @@ -743,9 +744,9 @@ struct lnet_ni *
>  					goto failed_syntax;
>  				}
>  				rc = cfs_expr_list_parse(elstr,
> -							nistr - elstr + 1,
> -							0, LNET_CPT_NUMBER - 1,
> -							&ni_el);
> +							 nistr - elstr + 1,
> +							 0, LNET_CPT_NUMBER - 1,
> +							 &ni_el);
>  				if (rc != 0) {
>  					str = elstr;
>  					goto failed_syntax;
> @@ -812,9 +813,9 @@ struct lnet_ni *
>  	kfree(tokens);
>  	return nnets;
>  
> - failed_syntax:
> +failed_syntax:
>  	lnet_syntax("networks", networks, (int)(str - tokens), strlen(str));
> - failed:
> +failed:
>  	/* free the net list and all the nis on each net */
>  	while (!list_empty(netlist)) {
>  		net = list_entry(netlist->next, struct lnet_net, net_list);
> @@ -1038,7 +1039,7 @@ struct lnet_ni *
>  	list_splice(&pending, tbs->prev);
>  	return 1;
>  
> - failed:
> +failed:
>  	lnet_free_text_bufs(&pending);
>  	return -EINVAL;
>  }
> @@ -1093,7 +1094,6 @@ struct lnet_ni *
>  {
>  	/* static scratch buffer OK (single threaded) */
>  	static char cmd[LNET_SINGLE_TEXTBUF_NOB];
> -
>  	struct list_head nets;
>  	struct list_head gateways;
>  	struct list_head *tmp1;
> @@ -1226,9 +1226,9 @@ struct lnet_ni *
>  	myrc = 0;
>  	goto out;
>  
> - token_error:
> +token_error:
>  	lnet_syntax("routes", cmd, (int)(token - str), strlen(token));
> - out:
> +out:
>  	lnet_free_text_bufs(&nets);
>  	lnet_free_text_bufs(&gateways);
>  	return myrc;
> @@ -1298,7 +1298,6 @@ struct lnet_ni *
>  lnet_match_network_tokens(char *net_entry, u32 *ipaddrs, int nip)
>  {
>  	static char tokens[LNET_SINGLE_TEXTBUF_NOB];
> -
>  	int matched = 0;
>  	int ntokens = 0;
>  	int len;
> @@ -1451,7 +1450,6 @@ struct lnet_ni *
>  {
>  	static char networks[LNET_SINGLE_TEXTBUF_NOB];
>  	static char source[LNET_SINGLE_TEXTBUF_NOB];
> -
>  	struct list_head raw_entries;
>  	struct list_head matched_nets;
>  	struct list_head current_nets;
> @@ -1549,7 +1547,7 @@ struct lnet_ni *
>  		count++;
>  	}
>  
> - out:
> +out:
>  	lnet_free_text_bufs(&raw_entries);
>  	lnet_free_text_bufs(&matched_nets);
>  	lnet_free_text_bufs(&current_nets);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> index f085388..f500b49 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> @@ -198,7 +198,7 @@
>  	lnet_res_lh_invalidate(&eq->eq_lh);
>  	list_del(&eq->eq_list);
>  	kfree(eq);
> - out:
> +out:
>  	lnet_eq_wait_unlock();
>  	lnet_res_unlock(LNET_LOCK_EX);
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 639f67ed..92c6a34 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -489,7 +489,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  
>  		if (mlen) {
>  			niov = msg->msg_niov;
> -			iov  = msg->msg_iov;
> +			iov = msg->msg_iov;
>  			kiov = msg->msg_kiov;
>  
>  			LASSERT(niov > 0);
> @@ -541,12 +541,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  		lnet_setpayloadbuffer(msg);
>  
>  	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
> -	msg->msg_hdr.type	   = cpu_to_le32(type);
> +	msg->msg_hdr.type = cpu_to_le32(type);
>  	/* dest_nid will be overwritten by lnet_select_pathway() */
> -	msg->msg_hdr.dest_nid       = cpu_to_le64(target.nid);
> -	msg->msg_hdr.dest_pid       = cpu_to_le32(target.pid);
> +	msg->msg_hdr.dest_nid = cpu_to_le64(target.nid);
> +	msg->msg_hdr.dest_pid = cpu_to_le32(target.pid);
>  	/* src_nid will be set later */
> -	msg->msg_hdr.src_pid	= cpu_to_le32(the_lnet.ln_pid);
> +	msg->msg_hdr.src_pid = cpu_to_le32(the_lnet.ln_pid);
>  	msg->msg_hdr.payload_length = cpu_to_le32(len);
>  }
>  
> @@ -635,7 +635,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  	}
>  
>  	deadline = lp->lpni_last_alive +
> -		lp->lpni_net->net_tunables.lct_peer_timeout;
> +		   lp->lpni_net->net_tunables.lct_peer_timeout;
>  	alive = deadline > now;
>  
>  	/* Update obsolete lpni_alive except for routers assumed to be dead
> @@ -911,7 +911,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  {
>  	struct lnet_peer_ni *txpeer = msg->msg_txpeer;
>  	struct lnet_msg *msg2;
> -	struct lnet_ni	*txni = msg->msg_txni;
> +	struct lnet_ni *txni = msg->msg_txni;
>  
>  	if (msg->msg_txcredit) {
>  		struct lnet_ni *ni = msg->msg_txni;
> @@ -1044,7 +1044,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  {
>  	struct lnet_peer_ni *rxpeer = msg->msg_rxpeer;
> -	struct lnet_ni	*rxni = msg->msg_rxni;
> +	struct lnet_ni *rxni = msg->msg_rxni;
>  	struct lnet_msg *msg2;
>  
>  	if (msg->msg_rtrcredit) {
> @@ -1796,7 +1796,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  	/* if we still can't find a peer ni then we can't reach it */
>  	if (!best_lpni) {
>  		u32 net_id = peer_net ? peer_net->lpn_net_id :
> -			LNET_NIDNET(dst_nid);
> +					LNET_NIDNET(dst_nid);
>  
>  		lnet_net_unlock(cpt);
>  		LCONSOLE_WARN("no peer_ni found on peer net %s\n",
> @@ -1912,7 +1912,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  	}
>  
>  	rc = lnet_post_send_locked(msg, 0);
> -
>  	if (!rc)
>  		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s\n",
>  		       libcfs_nid2str(msg->msg_hdr.src_nid),
> @@ -1931,8 +1930,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  int
>  lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  {
> -	lnet_nid_t		dst_nid = msg->msg_target.nid;
> -	int			rc;
> +	lnet_nid_t dst_nid = msg->msg_target.nid;
> +	int rc;
>  
>  	/*
>  	 * NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
> @@ -2008,19 +2007,19 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  	le32_to_cpus(&hdr->msg.put.offset);
>  
>  	/* Primary peer NID. */
> -	info.mi_id.nid	= msg->msg_initiator;
> -	info.mi_id.pid	= hdr->src_pid;
> -	info.mi_opc	= LNET_MD_OP_PUT;
> -	info.mi_portal	= hdr->msg.put.ptl_index;
> +	info.mi_id.nid = msg->msg_initiator;
> +	info.mi_id.pid = hdr->src_pid;
> +	info.mi_opc = LNET_MD_OP_PUT;
> +	info.mi_portal = hdr->msg.put.ptl_index;
>  	info.mi_rlength	= hdr->payload_length;
>  	info.mi_roffset	= hdr->msg.put.offset;
> -	info.mi_mbits	= hdr->msg.put.match_bits;
> -	info.mi_cpt	= lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
> +	info.mi_mbits = hdr->msg.put.match_bits;
> +	info.mi_cpt = lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
>  
>  	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
>  	ready_delay = msg->msg_rx_ready_delay;
>  
> - again:
> +again:
>  	rc = lnet_ptl_match_md(&info, msg);
>  	switch (rc) {
>  	default:
> @@ -2069,17 +2068,17 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  	le32_to_cpus(&hdr->msg.get.sink_length);
>  	le32_to_cpus(&hdr->msg.get.src_offset);
>  
> -	source_id.nid   = hdr->src_nid;
> -	source_id.pid   = hdr->src_pid;
> +	source_id.nid = hdr->src_nid;
> +	source_id.pid = hdr->src_pid;
>  	/* Primary peer NID */
> -	info.mi_id.nid  = msg->msg_initiator;
> -	info.mi_id.pid  = hdr->src_pid;
> -	info.mi_opc     = LNET_MD_OP_GET;
> -	info.mi_portal  = hdr->msg.get.ptl_index;
> +	info.mi_id.nid = msg->msg_initiator;
> +	info.mi_id.pid = hdr->src_pid;
> +	info.mi_opc = LNET_MD_OP_GET;
> +	info.mi_portal = hdr->msg.get.ptl_index;
>  	info.mi_rlength = hdr->msg.get.sink_length;
>  	info.mi_roffset = hdr->msg.get.src_offset;
> -	info.mi_mbits   = hdr->msg.get.match_bits;
> -	info.mi_cpt	= lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
> +	info.mi_mbits = hdr->msg.get.match_bits;
> +	info.mi_cpt = lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
>  
>  	rc = lnet_ptl_match_md(&info, msg);
>  	if (rc == LNET_MATCHMD_DROP) {
> @@ -2128,7 +2127,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  {
>  	void *private = msg->msg_private;
>  	struct lnet_hdr *hdr = &msg->msg_hdr;
> -	struct lnet_process_id src = {0};
> +	struct lnet_process_id src = { 0 };
>  	struct lnet_libmd *md;
>  	int rlength;
>  	int mlength;
> @@ -2192,7 +2191,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  lnet_parse_ack(struct lnet_ni *ni, struct lnet_msg *msg)
>  {
>  	struct lnet_hdr *hdr = &msg->msg_hdr;
> -	struct lnet_process_id src = {0};
> +	struct lnet_process_id src = { 0 };
>  	struct lnet_libmd *md;
>  	int cpt;
>  
> @@ -2316,8 +2315,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  void
>  lnet_print_hdr(struct lnet_hdr *hdr)
>  {
> -	struct lnet_process_id src = {0};
> -	struct lnet_process_id dst = {0};
> +	struct lnet_process_id src = { 0 };
> +	struct lnet_process_id dst = { 0 };
>  	char *type_str = lnet_msgtyp2str(hdr->type);
>  
>  	src.nid = hdr->src_nid;
> @@ -2533,17 +2532,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  	/* for building message event */
>  	msg->msg_from = from_nid;
>  	if (!for_me) {
> -		msg->msg_target.pid	= dest_pid;
> -		msg->msg_target.nid	= dest_nid;
> -		msg->msg_routing	= 1;
> -
> +		msg->msg_target.pid = dest_pid;
> +		msg->msg_target.nid = dest_nid;
> +		msg->msg_routing = 1;
>  	} else {
>  		/* convert common msg->hdr fields to host byteorder */
> -		msg->msg_hdr.type	= type;
> -		msg->msg_hdr.src_nid	= src_nid;
> +		msg->msg_hdr.type = type;
> +		msg->msg_hdr.src_nid = src_nid;
>  		le32_to_cpus(&msg->msg_hdr.src_pid);
> -		msg->msg_hdr.dest_nid	= dest_nid;
> -		msg->msg_hdr.dest_pid	= dest_pid;
> +		msg->msg_hdr.dest_nid = dest_nid;
> +		msg->msg_hdr.dest_pid = dest_pid;
>  		msg->msg_hdr.payload_length = payload_length;
>  	}
>  
> @@ -2609,11 +2607,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  		goto free_drop;
>  	return 0;
>  
> - free_drop:
> +free_drop:
>  	LASSERT(!msg->msg_md);
>  	lnet_finalize(msg, rc);
>  
> - drop:
> +drop:
>  	lnet_drop_message(ni, cpt, private, payload_length, type);
>  	return 0;
>  }
> @@ -2623,7 +2621,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
>  lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
>  {
>  	while (!list_empty(head)) {
> -		struct lnet_process_id id = {0};
> +		struct lnet_process_id id = { 0 };
>  		struct lnet_msg *msg;
>  
>  		msg = list_entry(head->next, struct lnet_msg, msg_list);
> @@ -2887,7 +2885,7 @@ struct lnet_msg *
>  
>  	return msg;
>  
> - drop:
> +drop:
>  	cpt = lnet_cpt_of_nid(peer_id.nid, ni);
>  
>  	lnet_net_lock(cpt);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> index 7f58cfe..b9e9257 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> @@ -44,9 +44,9 @@
>  {
>  	memset(ev, 0, sizeof(*ev));
>  
> -	ev->status   = 0;
> +	ev->status = 0;
>  	ev->unlinked = 1;
> -	ev->type     = LNET_EVENT_UNLINK;
> +	ev->type = LNET_EVENT_UNLINK;
>  	lnet_md_deconstruct(md, &ev->md);
>  	lnet_md2handle(&ev->md_handle, md);
>  }
> @@ -58,7 +58,7 @@
>  lnet_build_msg_event(struct lnet_msg *msg, enum lnet_event_kind ev_type)
>  {
>  	struct lnet_hdr *hdr = &msg->msg_hdr;
> -	struct lnet_event *ev  = &msg->msg_ev;
> +	struct lnet_event *ev = &msg->msg_ev;
>  
>  	LASSERT(!msg->msg_routing);
>  
> @@ -67,27 +67,27 @@
>  
>  	if (ev_type == LNET_EVENT_SEND) {
>  		/* event for active message */
> -		ev->target.nid    = le64_to_cpu(hdr->dest_nid);
> -		ev->target.pid    = le32_to_cpu(hdr->dest_pid);
> +		ev->target.nid = le64_to_cpu(hdr->dest_nid);
> +		ev->target.pid = le32_to_cpu(hdr->dest_pid);
>  		ev->initiator.nid = LNET_NID_ANY;
>  		ev->initiator.pid = the_lnet.ln_pid;
> -		ev->source.nid	  = LNET_NID_ANY;
> -		ev->source.pid    = the_lnet.ln_pid;
> -		ev->sender        = LNET_NID_ANY;
> +		ev->source.nid = LNET_NID_ANY;
> +		ev->source.pid = the_lnet.ln_pid;
> +		ev->sender = LNET_NID_ANY;
>  	} else {
>  		/* event for passive message */
> -		ev->target.pid    = hdr->dest_pid;
> -		ev->target.nid    = hdr->dest_nid;
> +		ev->target.pid = hdr->dest_pid;
> +		ev->target.nid = hdr->dest_nid;
>  		ev->initiator.pid = hdr->src_pid;
>  		/* Multi-Rail: resolve src_nid to "primary" peer NID */
>  		ev->initiator.nid = msg->msg_initiator;
>  		/* Multi-Rail: track source NID. */
> -		ev->source.pid	  = hdr->src_pid;
> -		ev->source.nid	  = hdr->src_nid;
> -		ev->rlength       = hdr->payload_length;
> -		ev->sender        = msg->msg_from;
> -		ev->mlength       = msg->msg_wanted;
> -		ev->offset        = msg->msg_offset;
> +		ev->source.pid = hdr->src_pid;
> +		ev->source.nid = hdr->src_nid;
> +		ev->rlength = hdr->payload_length;
> +		ev->sender = msg->msg_from;
> +		ev->mlength = msg->msg_wanted;
> +		ev->offset = msg->msg_offset;
>  	}
>  
>  	switch (ev_type) {
> @@ -95,20 +95,20 @@
>  		LBUG();
>  
>  	case LNET_EVENT_PUT: /* passive PUT */
> -		ev->pt_index   = hdr->msg.put.ptl_index;
> +		ev->pt_index = hdr->msg.put.ptl_index;
>  		ev->match_bits = hdr->msg.put.match_bits;
> -		ev->hdr_data   = hdr->msg.put.hdr_data;
> +		ev->hdr_data = hdr->msg.put.hdr_data;
>  		return;
>  
>  	case LNET_EVENT_GET: /* passive GET */
> -		ev->pt_index   = hdr->msg.get.ptl_index;
> +		ev->pt_index = hdr->msg.get.ptl_index;
>  		ev->match_bits = hdr->msg.get.match_bits;
> -		ev->hdr_data   = 0;
> +		ev->hdr_data = 0;
>  		return;
>  
>  	case LNET_EVENT_ACK: /* ACK */
>  		ev->match_bits = hdr->msg.ack.match_bits;
> -		ev->mlength    = hdr->msg.ack.mlength;
> +		ev->mlength = hdr->msg.ack.mlength;
>  		return;
>  
>  	case LNET_EVENT_REPLY: /* REPLY */
> @@ -116,21 +116,21 @@
>  
>  	case LNET_EVENT_SEND: /* active message */
>  		if (msg->msg_type == LNET_MSG_PUT) {
> -			ev->pt_index   = le32_to_cpu(hdr->msg.put.ptl_index);
> +			ev->pt_index = le32_to_cpu(hdr->msg.put.ptl_index);
>  			ev->match_bits = le64_to_cpu(hdr->msg.put.match_bits);
> -			ev->offset     = le32_to_cpu(hdr->msg.put.offset);
> -			ev->mlength    =
> -			ev->rlength    = le32_to_cpu(hdr->payload_length);
> -			ev->hdr_data   = le64_to_cpu(hdr->msg.put.hdr_data);
> +			ev->offset = le32_to_cpu(hdr->msg.put.offset);
> +			ev->mlength =
> +			ev->rlength = le32_to_cpu(hdr->payload_length);
> +			ev->hdr_data = le64_to_cpu(hdr->msg.put.hdr_data);
>  
>  		} else {
>  			LASSERT(msg->msg_type == LNET_MSG_GET);
> -			ev->pt_index   = le32_to_cpu(hdr->msg.get.ptl_index);
> +			ev->pt_index = le32_to_cpu(hdr->msg.get.ptl_index);
>  			ev->match_bits = le64_to_cpu(hdr->msg.get.match_bits);
> -			ev->mlength    =
> -			ev->rlength    = le32_to_cpu(hdr->msg.get.sink_length);
> -			ev->offset     = le32_to_cpu(hdr->msg.get.src_offset);
> -			ev->hdr_data   = 0;
> +			ev->mlength =
> +			ev->rlength = le32_to_cpu(hdr->msg.get.sink_length);
> +			ev->offset = le32_to_cpu(hdr->msg.get.src_offset);
> +			ev->hdr_data = 0;
>  		}
>  		return;
>  	}
> @@ -140,7 +140,7 @@
>  lnet_msg_commit(struct lnet_msg *msg, int cpt)
>  {
>  	struct lnet_msg_container *container = the_lnet.ln_msg_containers[cpt];
> -	struct lnet_counters *counters  = the_lnet.ln_counters[cpt];
> +	struct lnet_counters *counters = the_lnet.ln_counters[cpt];
>  
>  	/* routed message can be committed for both receiving and sending */
>  	LASSERT(!msg->msg_tx_committed);
> @@ -172,7 +172,7 @@
>  static void
>  lnet_msg_decommit_tx(struct lnet_msg *msg, int status)
>  {
> -	struct lnet_counters	*counters;
> +	struct lnet_counters *counters;
>  	struct lnet_event *ev = &msg->msg_ev;
>  
>  	LASSERT(msg->msg_tx_committed);
> @@ -294,7 +294,7 @@
>  	if (ev->type == LNET_EVENT_PUT || ev->type == LNET_EVENT_REPLY)
>  		counters->recv_length += msg->msg_wanted;
>  
> - out:
> +out:
>  	lnet_return_rx_credits_locked(msg);
>  	msg->msg_rx_committed = 0;
>  }
> @@ -375,7 +375,7 @@
>  
>  	unlink = lnet_md_unlinkable(md);
>  	if (md->md_eq) {
> -		msg->msg_ev.status   = status;
> +		msg->msg_ev.status = status;
>  		msg->msg_ev.unlinked = unlink;
>  		lnet_eq_enqueue_event(md->md_eq, &msg->msg_ev);
>  	}
> @@ -488,7 +488,7 @@
>  		lnet_res_unlock(cpt);
>  	}
>  
> - again:
> +again:
>  	rc = 0;
>  	if (!msg->msg_tx_committed && !msg->msg_rx_committed) {
>  		/* not committed to network yet */
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> index fa391ee..ea232c7 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> @@ -74,7 +74,7 @@
>  
>  	return 1;
>  
> - match:
> +match:
>  	if ((lnet_ptl_is_unique(ptl) && !unique) ||
>  	    (lnet_ptl_is_wildcard(ptl) && unique))
>  		return 0;
> @@ -387,7 +387,7 @@ struct list_head *
>  		head = &mtable->mt_mhash[LNET_MT_HASH_IGNORE];
>  	else
>  		head = lnet_mt_match_head(mtable, info->mi_id, info->mi_mbits);
> - again:
> +again:
>  	/* NB: only wildcard portal needs to return LNET_MATCHMD_EXHAUSTED */
>  	if (lnet_ptl_is_wildcard(the_lnet.ln_portals[mtable->mt_portal]))
>  		exhausted = LNET_MATCHMD_EXHAUSTED;
> @@ -634,9 +634,9 @@ struct list_head *
>  		       info->mi_mbits, info->mi_roffset, info->mi_rlength);
>  	}
>  	goto out0;
> - out1:
> +out1:
>  	lnet_res_unlock(mtable->mt_cpt);
> - out0:
> +out0:
>  	/* EXHAUSTED bit is only meaningful for internal functions */
>  	return rc & ~LNET_MATCHMD_EXHAUSTED;
>  }
> @@ -678,7 +678,7 @@ struct list_head *
>  
>  	lnet_ptl_lock(ptl);
>  	head = &ptl->ptl_msg_stealing;
> - again:
> +again:
>  	list_for_each_entry_safe(msg, tmp, head, msg_list) {
>  		struct lnet_match_info info;
>  		struct lnet_hdr *hdr;
> @@ -688,13 +688,13 @@ struct list_head *
>  
>  		hdr = &msg->msg_hdr;
>  		/* Multi-Rail: Primary peer NID */
> -		info.mi_id.nid  = msg->msg_initiator;
> -		info.mi_id.pid  = hdr->src_pid;
> -		info.mi_opc     = LNET_MD_OP_PUT;
> -		info.mi_portal  = hdr->msg.put.ptl_index;
> +		info.mi_id.nid = msg->msg_initiator;
> +		info.mi_id.pid = hdr->src_pid;
> +		info.mi_opc = LNET_MD_OP_PUT;
> +		info.mi_portal = hdr->msg.put.ptl_index;
>  		info.mi_rlength = hdr->payload_length;
>  		info.mi_roffset = hdr->msg.put.offset;
> -		info.mi_mbits   = hdr->msg.put.match_bits;
> +		info.mi_mbits = hdr->msg.put.match_bits;
>  
>  		rc = lnet_try_match_md(md, &info, msg);
>  
> @@ -824,7 +824,7 @@ struct list_head *
>  	}
>  
>  	return 0;
> - failed:
> +failed:
>  	lnet_ptl_cleanup(ptl);
>  	return -ENOMEM;
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> index cff3d1e..095f9f5 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> @@ -50,8 +50,11 @@
>  	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
>  	unsigned long then;
>  	struct timeval tv;
> -	struct kvec  iov = { .iov_base = buffer, .iov_len  = nob };
> -	struct msghdr msg = {NULL,};
> +	struct kvec iov = {
> +		.iov_base = buffer,
> +		.iov_len = nob
> +	};
> +	struct msghdr msg = { NULL, };
>  
>  	LASSERT(nob > 0);
>  	/*
> @@ -102,9 +105,9 @@
>  	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
>  	unsigned long then;
>  	struct timeval tv;
> -	struct kvec  iov = {
> +	struct kvec iov = {
>  		.iov_base = buffer,
> -		.iov_len  = nob
> +		.iov_len = nob
>  	};
>  	struct msghdr msg = {
>  		.msg_flags = 0
> diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
> index 4c08c74..f306569 100644
> --- a/drivers/staging/lustre/lnet/lnet/module.c
> +++ b/drivers/staging/lustre/lnet/lnet/module.c
> @@ -52,7 +52,6 @@
>  
>  	if (!the_lnet.ln_niinit_self) {
>  		rc = try_module_get(THIS_MODULE);
> -
>  		if (rc != 1)
>  			goto out;
>  
> @@ -229,7 +228,7 @@
>  }
>  
>  static struct notifier_block lnet_ioctl_handler = {
> -	.notifier_call = lnet_ioctl,
> +	.notifier_call		= lnet_ioctl,
>  };
>  
>  static int __init lnet_init(void)
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index e2c7468..4234ce1 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -614,7 +614,6 @@ struct delay_daemon_data {
>  			rc = lnet_parse_local(ni, msg);
>  			if (!rc)
>  				continue;
> -
>  		} else {
>  			lnet_net_lock(cpt);
>  			rc = lnet_parse_forward_locked(ni, msg);
> diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
> index 0f2b75e..8f3d87c 100644
> --- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
> +++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
> @@ -60,8 +60,8 @@
>   * between getting its string and using it.
>   */
>  
> -static char      libcfs_nidstrings[LNET_NIDSTR_COUNT][LNET_NIDSTR_SIZE];
> -static int       libcfs_nidstring_idx;
> +static char libcfs_nidstrings[LNET_NIDSTR_COUNT][LNET_NIDSTR_SIZE];
> +static int libcfs_nidstring_idx;
>  
>  static DEFINE_SPINLOCK(libcfs_nidstring_lock);
>  
> @@ -117,23 +117,23 @@ struct nidrange {
>  	 * Link to list of this structures which is built on nid range
>  	 * list parsing.
>  	 */
> -	struct list_head nr_link;
> +	struct list_head	nr_link;
>  	/**
>  	 * List head for addrrange::ar_link.
>  	 */
> -	struct list_head nr_addrranges;
> +	struct list_head	nr_addrranges;
>  	/**
>  	 * Flag indicating that *@<net> is found.
>  	 */
> -	int nr_all;
> +	int			nr_all;
>  	/**
>  	 * Pointer to corresponding element of libcfs_netstrfns.
>  	 */
> -	struct netstrfns *nr_netstrfns;
> +	struct netstrfns	*nr_netstrfns;
>  	/**
>  	 * Number of network. E.g. 5 if \<net\> is "elan5".
>  	 */
> -	int nr_netnum;
> +	int			nr_netnum;
>  };
>  
>  /**
> @@ -143,11 +143,11 @@ struct addrrange {
>  	/**
>  	 * Link to nidrange::nr_addrranges.
>  	 */
> -	struct list_head ar_link;
> +	struct list_head	ar_link;
>  	/**
>  	 * List head for cfs_expr_list::el_list.
>  	 */
> -	struct list_head ar_numaddr_ranges;
> +	struct list_head	ar_numaddr_ranges;
>  };
>  
>  /**
> @@ -471,8 +471,8 @@ static void cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
>  	struct cfs_expr_list *el;
>  	struct cfs_range_expr *re;
>  	u32 tmp_ip_addr = 0;
> -	unsigned int min_ip[4] = {0};
> -	unsigned int max_ip[4] = {0};
> +	unsigned int min_ip[4] = { 0 };
> +	unsigned int max_ip[4] = { 0 };
>  	int re_count = 0;
>  
>  	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
> @@ -794,11 +794,11 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
>  static int
>  libcfs_ip_str2addr(const char *str, int nob, u32 *addr)
>  {
> -	unsigned int	a;
> -	unsigned int	b;
> -	unsigned int	c;
> -	unsigned int	d;
> -	int		n = nob; /* XscanfX */
> +	unsigned int a;
> +	unsigned int b;
> +	unsigned int c;
> +	unsigned int d;
> +	int n = nob; /* XscanfX */
>  
>  	/* numeric IP? */
>  	if (sscanf(str, "%u.%u.%u.%u%n", &a, &b, &c, &d, &n) >= 4 &&
> @@ -897,7 +897,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
>  static int
>  libcfs_num_str2addr(const char *str, int nob, u32 *addr)
>  {
> -	int     n;
> +	int n;
>  
>  	n = nob;
>  	if (sscanf(str, "0x%x%n", addr, &n) >= 1 && n == nob)
> @@ -926,7 +926,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
>  libcfs_num_parse(char *str, int len, struct list_head *list)
>  {
>  	struct cfs_expr_list *el;
> -	int	rc;
> +	int rc;
>  
>  	rc = cfs_expr_list_parse(str, len, 0, MAX_NUMERIC_VALUE, &el);
>  	if (!rc)
> @@ -1049,7 +1049,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
>  static struct netstrfns *
>  libcfs_name2netstrfns(const char *name)
>  {
> -	int    i;
> +	int i;
>  
>  	for (i = 0; i < libcfs_nnetstrfns; i++)
>  		if (!strcmp(libcfs_netstrfns[i].nf_name, name))
> @@ -1194,7 +1194,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
>  u32
>  libcfs_str2net(const char *str)
>  {
> -	u32  net;
> +	u32 net;
>  
>  	if (libcfs_str2net_internal(str, &net))
>  		return net;
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index d807dd4..dfe1f3d 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -586,8 +586,8 @@ void lnet_peer_uninit(void)
>  static struct lnet_peer_ni *
>  lnet_get_peer_ni_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
>  {
> -	struct list_head	*peers;
> -	struct lnet_peer_ni	*lp;
> +	struct list_head *peers;
> +	struct lnet_peer_ni *lp;
>  
>  	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
>  
> @@ -1069,6 +1069,7 @@ struct lnet_peer_net *
>  lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
>  {
>  	struct lnet_peer_net *peer_net;
> +
>  	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
>  		if (peer_net->lpn_net_id == net_id)
>  			return peer_net;
> @@ -1088,9 +1089,9 @@ struct lnet_peer_net *
>   */
>  static int
>  lnet_peer_attach_peer_ni(struct lnet_peer *lp,
> -				struct lnet_peer_net *lpn,
> -				struct lnet_peer_ni *lpni,
> -				unsigned int flags)
> +			 struct lnet_peer_net *lpn,
> +			 struct lnet_peer_ni *lpni,
> +			 unsigned int flags)
>  {
>  	struct lnet_peer_table *ptable;
>  
> @@ -2686,12 +2687,12 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
>  	}
>  
>  	/* initialize md content */
> -	md.start     = &pbuf->pb_info;
> -	md.length    = LNET_PING_INFO_SIZE(nnis);
> +	md.start = &pbuf->pb_info;
> +	md.length = LNET_PING_INFO_SIZE(nnis);
>  	md.threshold = 2; /* GET/REPLY */
> -	md.max_size  = 0;
> -	md.options   = LNET_MD_TRUNCATE;
> -	md.user_ptr  = lp;
> +	md.max_size = 0;
> +	md.options = LNET_MD_TRUNCATE;
> +	md.user_ptr = lp;
>  	md.eq_handle = the_lnet.ln_dc_eqh;
>  
>  	rc = LNetMDBind(md, LNET_UNLINK, &lp->lp_ping_mdh);
> @@ -2715,7 +2716,6 @@ static int lnet_peer_send_ping(struct lnet_peer *lp)
>  	rc = LNetGet(LNET_NID_ANY, lp->lp_ping_mdh, id,
>  		     LNET_RESERVED_PORTAL,
>  		     LNET_PROTO_PING_MATCHBITS, 0);
> -
>  	if (rc)
>  		goto fail_unlink_md;
>  
> @@ -2792,13 +2792,13 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
>  	lnet_net_unlock(cpt);
>  
>  	/* Push source MD */
> -	md.start     = &pbuf->pb_info;
> -	md.length    = LNET_PING_INFO_SIZE(pbuf->pb_nnis);
> +	md.start = &pbuf->pb_info;
> +	md.length = LNET_PING_INFO_SIZE(pbuf->pb_nnis);
>  	md.threshold = 2; /* Put/Ack */
> -	md.max_size  = 0;
> -	md.options   = 0;
> +	md.max_size = 0;
> +	md.options = 0;
>  	md.eq_handle = the_lnet.ln_dc_eqh;
> -	md.user_ptr  = lp;
> +	md.user_ptr = lp;
>  
>  	rc = LNetMDBind(md, LNET_UNLINK, &lp->lp_push_mdh);
>  	if (rc) {
> @@ -2821,7 +2821,6 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
>  	rc = LNetPut(LNET_NID_ANY, lp->lp_push_mdh,
>  		     LNET_ACK_REQ, id, LNET_RESERVED_PORTAL,
>  		     LNET_PROTO_PING_MATCHBITS, 0, 0);
> -
>  	if (rc)
>  		goto fail_unlink;
>  
> @@ -3315,8 +3314,8 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
>  		goto out;
>  	}
>  
> -	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats)
> -		+ sizeof(*lpni_msg_stats);
> +	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats) +
> +	       sizeof(*lpni_msg_stats);
>  	size *= lp->lp_nnis;
>  	if (size > cfg->prcfg_size) {
>  		cfg->prcfg_size = size;
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 22c88ec..463b123 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -172,7 +172,7 @@
>  		notifylnd = lp->lpni_notifylnd;
>  
>  		lp->lpni_notifylnd = 0;
> -		lp->lpni_notify    = 0;
> +		lp->lpni_notify = 0;
>  
>  		if (notifylnd && ni->ni_net->net_lnd->lnd_notify) {
>  			spin_unlock(&lp->lpni_lock);
> @@ -274,6 +274,7 @@ static void lnet_shuffle_seed(void)
>  	 * the NID for this node gives the most entropy in the low bits */
>  	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
>  		u32 lnd_type, seed;
> +
>  		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
>  		if (lnd_type != LOLND) {
>  			seed = (LNET_NIDADDR(ni->ni_nid) | lnd_type);
> @@ -386,7 +387,6 @@ static void lnet_shuffle_seed(void)
>  	/* Search for a duplicate route (it's a NOOP if it is) */
>  	add_route = 1;
>  	list_for_each_entry(route2, &rnet2->lrn_routes, lr_list) {
> -
>  		if (route2->lr_gateway == route->lr_gateway) {
>  			add_route = 0;
>  			break;
> @@ -501,7 +501,7 @@ static void lnet_shuffle_seed(void)
>  	else
>  		rn_list = lnet_net2rnethash(net);
>  
> - again:
> +again:
>  	list_for_each_entry(rnet, rn_list, lrn_list) {
>  		if (!(net == LNET_NIDNET(LNET_NID_ANY) ||
>  		      net == rnet->lrn_net))
> @@ -601,10 +601,10 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  		list_for_each_entry(rnet, rn_list, lrn_list) {
>  			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
>  				if (!idx--) {
> -					*net      = rnet->lrn_net;
> -					*hops     = route->lr_hops;
> +					*net = rnet->lrn_net;
> +					*hops = route->lr_hops;
>  					*priority = route->lr_priority;
> -					*gateway  = route->lr_gateway->lpni_nid;
> +					*gateway = route->lr_gateway->lpni_nid;
>  					*alive = lnet_is_route_alive(route);
>  					lnet_net_unlock(cpt);
>  					return 0;
> @@ -648,7 +648,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  	struct lnet_ping_buffer *pbuf = rcd->rcd_pingbuffer;
>  	struct lnet_peer_ni *gw = rcd->rcd_gateway;
>  	struct lnet_route *rte;
> -	int			nnis;
> +	int nnis;
>  
>  	if (!gw->lpni_alive || !pbuf)
>  		return;
> @@ -799,7 +799,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  	if (avoid_asym_router_failure && !event->status)
>  		lnet_parse_rc_info(rcd);
>  
> - out:
> +out:
>  	lnet_net_unlock(lp->lpni_cpt);
>  }
>  
> @@ -1069,14 +1069,14 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  		id.pid = LNET_PID_LUSTRE;
>  		CDEBUG(D_NET, "Check: %s\n", libcfs_id2str(id));
>  
> -		rtr->lpni_ping_notsent   = 1;
> +		rtr->lpni_ping_notsent = 1;
>  		rtr->lpni_ping_timestamp = now;
>  
>  		mdh = rcd->rcd_mdh;
>  
>  		if (!rtr->lpni_ping_deadline) {
>  			rtr->lpni_ping_deadline = ktime_get_seconds() +
> -						router_ping_timeout;
> +						  router_ping_timeout;
>  		}
>  
>  		lnet_net_unlock(rtr->lpni_cpt);
> @@ -1652,7 +1652,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  
>  	return 0;
>  
> - failed:
> +failed:
>  	lnet_rtrpools_free(0);
>  	return rc;
>  }
> @@ -1797,8 +1797,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
>  		return -EINVAL;
>  	}
>  
> -	if (ni && !alive &&	     /* LND telling me she's down */
> -	    !auto_down) {		       /* auto-down disabled */
> +	if (ni && !alive &&	/* LND telling me she's down */
> +	    !auto_down) {	/* auto-down disabled */
>  		CDEBUG(D_NET, "Auto-down disabled\n");
>  		return 0;
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index e8cc70f..94ef441 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -66,8 +66,8 @@
>  #define LNET_PROC_HOFF_GET(pos)				\
>  	(int)((pos) & LNET_PROC_HOFF_MASK)
>  
> -#define LNET_PROC_POS_MAKE(cpt, ver, hash, off)		\
> -	(((((loff_t)(cpt)) & LNET_PROC_CPT_MASK) << LNET_PROC_VPOS_BITS) |   \
> +#define LNET_PROC_POS_MAKE(cpt, ver, hash, off)				    \
> +	(((((loff_t)(cpt)) & LNET_PROC_CPT_MASK) << LNET_PROC_VPOS_BITS) |  \
>  	((((loff_t)(ver)) & LNET_PROC_VER_MASK) << LNET_PROC_HPOS_BITS) |   \
>  	((((loff_t)(hash)) & LNET_PROC_HASH_MASK) << LNET_PROC_HOFF_BITS) | \
>  	((off) & LNET_PROC_HOFF_MASK))
> @@ -91,7 +91,6 @@ static int proc_lnet_stats(struct ctl_table *table, int write,
>  	}
>  
>  	/* read */
> -
>  	ctrs = kzalloc(sizeof(*ctrs), GFP_NOFS);
>  	if (!ctrs)
>  		return -ENOMEM;
> @@ -395,8 +394,8 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  	struct lnet_peer_table *ptable;
>  	char *tmpstr = NULL;
>  	char *s;
> -	int cpt  = LNET_PROC_CPT_GET(*ppos);
> -	int ver  = LNET_PROC_VER_GET(*ppos);
> +	int cpt = LNET_PROC_CPT_GET(*ppos);
> +	int ver = LNET_PROC_VER_GET(*ppos);
>  	int hash = LNET_PROC_HASH_GET(*ppos);
>  	int hoff = LNET_PROC_HOFF_GET(*ppos);
>  	int rc = 0;
> @@ -456,7 +455,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  		struct lnet_peer_ni *peer;
>  		struct list_head *p;
>  		int skip;
> - again:
> +again:
>  		p = NULL;
>  		peer = NULL;
>  		skip = hoff - 1;
> @@ -630,7 +629,7 @@ static int proc_lnet_buffers(struct ctl_table *table, int write,
>  		lnet_net_unlock(LNET_LOCK_EX);
>  	}
>  
> - out:
> +out:
>  	len = s - tmpstr;
>  
>  	if (pos >= min_t(int, len, strlen(tmpstr)))
> @@ -787,9 +786,9 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
>  }
>  
>  struct lnet_portal_rotors {
> -	int pr_value;
> -	const char *pr_name;
> -	const char *pr_desc;
> +	int		 pr_value;
> +	const char	*pr_name;
> +	const char	*pr_desc;
>  };
>  
>  static struct lnet_portal_rotors	portal_rotors[] = {
> @@ -890,39 +889,39 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
>  	 * to go via /proc for portability.
>  	 */
>  	{
> -		.procname     = "stats",
> -		.mode         = 0644,
> -		.proc_handler = &proc_lnet_stats,
> +		.procname	= "stats",
> +		.mode		= 0644,
> +		.proc_handler	= &proc_lnet_stats,
>  	},
>  	{
> -		.procname     = "routes",
> -		.mode         = 0444,
> -		.proc_handler = &proc_lnet_routes,
> +		.procname	= "routes",
> +		.mode		= 0444,
> +		.proc_handler	= &proc_lnet_routes,
>  	},
>  	{
> -		.procname     = "routers",
> -		.mode         = 0444,
> -		.proc_handler = &proc_lnet_routers,
> +		.procname	= "routers",
> +		.mode		= 0444,
> +		.proc_handler	= &proc_lnet_routers,
>  	},
>  	{
> -		.procname     = "peers",
> -		.mode         = 0644,
> -		.proc_handler = &proc_lnet_peers,
> +		.procname	= "peers",
> +		.mode		= 0644,
> +		.proc_handler	= &proc_lnet_peers,
>  	},
>  	{
> -		.procname     = "buffers",
> -		.mode         = 0444,
> -		.proc_handler = &proc_lnet_buffers,
> +		.procname	= "buffers",
> +		.mode		= 0444,
> +		.proc_handler	= &proc_lnet_buffers,
>  	},
>  	{
> -		.procname     = "nis",
> -		.mode         = 0644,
> -		.proc_handler = &proc_lnet_nis,
> +		.procname	= "nis",
> +		.mode		= 0644,
> +		.proc_handler	= &proc_lnet_nis,
>  	},
>  	{
> -		.procname     = "portal_rotor",
> -		.mode         = 0644,
> -		.proc_handler = &proc_lnet_portal_rotor,
> +		.procname	= "portal_rotor",
> +		.mode		= 0644,
> +		.proc_handler	= &proc_lnet_portal_rotor,
>  	},
>  	{
>  	}
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190204/a8d5ab01/attachment-0001.sig>
