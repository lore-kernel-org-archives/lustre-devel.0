From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 23:51:53 +0100 (BST)
Subject: [lustre-devel] [PATCH 16/24] lustre: lnet: add discovery thread
In-Reply-To: <153895437816.16383.10343171262123774566.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437816.16383.10343171262123774566.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142351321.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Add the discovery thread, which will be used to handle peer
> discovery. This change adds the thread and the infrastructure
> that starts and stops it. The thread itself does trivial work.
> 
> Peer Discovery gets its own event queue (ln_dc_eqh), a queue
> for peers that are to be discovered (ln_dc_request), a queue
> for peers waiting for an event (ln_dc_working), a wait queue
> head so the thread can sleep (ln_dc_waitq), and start/stop
> state (ln_dc_state).
> 
> Peer discovery is started from lnet_select_pathway(), for
> GET and PUT messages not sent to the LNET_RESERVED_PORTAL.
> This criterion means that discovery will not be triggered by
> the messages used in discovery, and neither will an LNet ping
> trigger it.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Reviewed-on: https://review.whamcloud.com/25786
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    6 
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   71 ++++
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   31 ++
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |   45 ++-
>  drivers/staging/lustre/lnet/lnet/peer.c            |  325 ++++++++++++++++++++
>  5 files changed, 468 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index aad25eb0011b..848d622911a4 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -438,6 +438,7 @@ bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
>  struct lnet_net *lnet_get_net_locked(u32 net_id);
>  
>  extern unsigned int lnet_numa_range;
> +extern unsigned int lnet_peer_discovery_disabled;
>  extern int portal_rotor;
>  
>  int lnet_lib_init(void);
> @@ -704,6 +705,9 @@ struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
>  struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
>  void lnet_peer_net_added(struct lnet_net *net);
>  lnet_nid_t lnet_peer_primary_nid_locked(lnet_nid_t nid);
> +int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt);
> +int lnet_peer_discovery_start(void);
> +void lnet_peer_discovery_stop(void);
>  void lnet_peer_tables_cleanup(struct lnet_net *net);
>  void lnet_peer_uninit(void);
>  int lnet_peer_tables_create(void);
> @@ -791,4 +795,6 @@ lnet_peer_ni_is_primary(struct lnet_peer_ni *lpni)
>  	return lpni->lpni_nid == lpni->lpni_peer_net->lpn_peer->lp_primary_nid;
>  }
>  
> +bool lnet_peer_is_uptodate(struct lnet_peer *lp);
> +
>  #endif
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 260619e19bde..6394a3af50b7 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -520,10 +520,61 @@ struct lnet_peer {
>  
>  	/* peer state flags */
>  	unsigned int		lp_state;
> +
> +	/* link on discovery-related lists */
> +	struct list_head	lp_dc_list;
> +
> +	/* tasks waiting on discovery of this peer */
> +	wait_queue_head_t	lp_dc_waitq;
>  };
>  
> -#define LNET_PEER_MULTI_RAIL	BIT(0)
> -#define LNET_PEER_CONFIGURED	BIT(1)
> +/*
> + * The status flags in lp_state. Their semantics have chosen so that
> + * lp_state can be zero-initialized.
> + *
> + * A peer is marked MULTI_RAIL in two cases: it was configured using DLC
> + * as multi-rail aware, or the LNET_PING_FEAT_MULTI_RAIL bit was set.
> + *
> + * A peer is marked NO_DISCOVERY if the LNET_PING_FEAT_DISCOVERY bit was
> + * NOT set when the peer was pinged by discovery.
> + */
> +#define LNET_PEER_MULTI_RAIL	BIT(0)	/* Multi-rail aware */
> +#define LNET_PEER_NO_DISCOVERY	BIT(1)	/* Peer disabled discovery */
> +/*
> + * A peer is marked CONFIGURED if it was configured by DLC.
> + *
> + * In addition, a peer is marked DISCOVERED if it has fully passed
> + * through Peer Discovery.
> + *
> + * When Peer Discovery is disabled, the discovery thread will mark
> + * peers REDISCOVER to indicate that they should be re-examined if
> + * discovery is (re)enabled on the node.
> + *
> + * A peer that was created as the result of inbound traffic will not
> + * be marked at all.
> + */
> +#define LNET_PEER_CONFIGURED	BIT(2)	/* Configured via DLC */
> +#define LNET_PEER_DISCOVERED	BIT(3)	/* Peer was discovered */
> +#define LNET_PEER_REDISCOVER	BIT(4)	/* Discovery was disabled */
> +/*
> + * A peer is marked DISCOVERING when discovery is in progress.
> + * The other flags below correspond to stages of discovery.
> + */
> +#define LNET_PEER_DISCOVERING	BIT(5)	/* Discovering */
> +#define LNET_PEER_DATA_PRESENT	BIT(6)	/* Remote peer data present */
> +#define LNET_PEER_NIDS_UPTODATE	BIT(7)	/* Remote peer info uptodate */
> +#define LNET_PEER_PING_SENT	BIT(8)	/* Waiting for REPLY to Ping */
> +#define LNET_PEER_PUSH_SENT	BIT(9)	/* Waiting for ACK of Push */
> +#define LNET_PEER_PING_FAILED	BIT(10)	/* Ping send failure */
> +#define LNET_PEER_PUSH_FAILED	BIT(11)	/* Push send failure */
> +/*
> + * A ping can be forced as a way to fix up state, or as a manual
> + * intervention by an admin.
> + * A push can be forced in circumstances that would normally not
> + * allow for one to happen.
> + */
> +#define LNET_PEER_FORCE_PING	BIT(12)	/* Forced Ping */
> +#define LNET_PEER_FORCE_PUSH	BIT(13)	/* Forced Push */
>  
>  struct lnet_peer_net {
>  	/* chain on lp_peer_nets */
> @@ -775,6 +826,11 @@ struct lnet_msg_container {
>  	void			**msc_finalizers;
>  };
>  
> +/* Peer Discovery states */
> +#define LNET_DC_STATE_SHUTDOWN		0	/* not started */
> +#define LNET_DC_STATE_RUNNING		1	/* started up OK */
> +#define LNET_DC_STATE_STOPPING		2	/* telling thread to stop */
> +
>  /* Router Checker states */
>  enum lnet_rc_state {
>  	LNET_RC_STATE_SHUTDOWN,	/* not started */
> @@ -856,6 +912,17 @@ struct lnet {
>  	struct lnet_ping_buffer		 *ln_ping_target;
>  	atomic_t			ln_ping_target_seqno;
>  
> +	/* discovery event queue handle */
> +	struct lnet_handle_eq		ln_dc_eqh;
> +	/* discovery requests */
> +	struct list_head		ln_dc_request;
> +	/* discovery working list */
> +	struct list_head		ln_dc_working;
> +	/* discovery thread wait queue */
> +	wait_queue_head_t		ln_dc_waitq;
> +	/* discovery startup/shutdown state */
> +	int				ln_dc_state;
> +
>  	/* router checker startup/shutdown state */
>  	enum lnet_rc_state		  ln_rc_state;
>  	/* router checker's event queue */
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index c48bcb8722a0..dccfd5bcc459 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -78,6 +78,13 @@ module_param_call(lnet_interfaces_max, intf_max_set, param_get_int,
>  MODULE_PARM_DESC(lnet_interfaces_max,
>  		"Maximum number of interfaces in a node.");
>  
> +unsigned int lnet_peer_discovery_disabled;
> +static int discovery_set(const char *val, const struct kernel_param *kp);
> +module_param_call(lnet_peer_discovery_disabled, discovery_set, param_get_int,
> +		  &lnet_peer_discovery_disabled, 0644);
> +MODULE_PARM_DESC(lnet_peer_discovery_disabled,
> +		 "Set to 1 to disable peer discovery on this node.");
> +
>  /*
>   * This sequence number keeps track of how many times DLC was used to
>   * update the local NIs. It is incremented when a NI is added or
> @@ -90,6 +97,23 @@ static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
>  static int lnet_ping(struct lnet_process_id id, signed long timeout,
>  		     struct lnet_process_id __user *ids, int n_ids);
>  
> +static int
> +discovery_set(const char *val, const struct kernel_param *kp)
> +{
> +	int rc;
> +	unsigned long value;
> +
> +	rc = kstrtoul(val, 0, &value);
> +	if (rc) {
> +		CERROR("Invalid module parameter value for 'lnet_peer_discovery_disabled'\n");
> +		return rc;
> +	}
> +
> +	*(unsigned int *)kp->arg = !!value;
> +
> +	return 0;
> +}
> +
>  static int
>  intf_max_set(const char *val, const struct kernel_param *kp)
>  {
> @@ -1921,6 +1945,10 @@ LNetNIInit(lnet_pid_t requested_pid)
>  	if (rc)
>  		goto err_stop_ping;
>  
> +	rc = lnet_peer_discovery_start();
> +	if (rc != 0)
> +		goto err_stop_router_checker;
> +
>  	lnet_fault_init();
>  	lnet_router_debugfs_init();
>  
> @@ -1928,6 +1956,8 @@ LNetNIInit(lnet_pid_t requested_pid)
>  
>  	return 0;
>  
> +err_stop_router_checker:
> +	lnet_router_checker_stop();
>  err_stop_ping:
>  	lnet_ping_target_fini();
>  err_acceptor_stop:
> @@ -1976,6 +2006,7 @@ LNetNIFini(void)
>  
>  		lnet_fault_fini();
>  		lnet_router_debugfs_fini();
> +		lnet_peer_discovery_stop();
>  		lnet_router_checker_stop();
>  		lnet_ping_target_fini();
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 4c1eef907dc7..4773180cc7b3 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -1208,6 +1208,27 @@ lnet_get_best_ni(struct lnet_net *local_net, struct lnet_ni *cur_ni,
>  	return best_ni;
>  }
>  
> +/*
> + * Traffic to the LNET_RESERVED_PORTAL may not trigger peer discovery,
> + * because such traffic is required to perform discovery. We therefore
> + * exclude all GET and PUT on that portal. We also exclude all ACK and
> + * REPLY traffic, but that is because the portal is not tracked in the
> + * message structure for these message types. We could restrict this
> + * further by also checking for LNET_PROTO_PING_MATCHBITS.
> + */
> +static bool
> +lnet_msg_discovery(struct lnet_msg *msg)
> +{
> +	if (msg->msg_type == LNET_MSG_PUT) {
> +		if (msg->msg_hdr.msg.put.ptl_index != LNET_RESERVED_PORTAL)
> +			return true;
> +	} else if (msg->msg_type == LNET_MSG_GET) {
> +		if (msg->msg_hdr.msg.get.ptl_index != LNET_RESERVED_PORTAL)
> +			return true;
> +	}
> +	return false;
> +}
> +
>  static int
>  lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  		    struct lnet_msg *msg, lnet_nid_t rtr_nid)
> @@ -1220,7 +1241,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	struct lnet_peer *peer;
>  	struct lnet_peer_net *peer_net;
>  	struct lnet_net *local_net;
> -	__u32 seq;
>  	int cpt, cpt2, rc;
>  	bool routing;
>  	bool routing2;
> @@ -1255,13 +1275,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	routing2 = false;
>  	local_found = false;
>  
> -	seq = lnet_get_dlc_seq_locked();
> -
> -	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
> -		lnet_net_unlock(cpt);
> -		return -ESHUTDOWN;
> -	}
> -
>  	/*
>  	 * lnet_nid2peerni_locked() is the path that will find an
>  	 * existing peer_ni, or create one and mark it as having been
> @@ -1272,7 +1285,22 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  		lnet_net_unlock(cpt);
>  		return PTR_ERR(lpni);
>  	}
> +	/*
> +	 * Now that we have a peer_ni, check if we want to discover
> +	 * the peer. Traffic to the LNET_RESERVED_PORTAL should not
> +	 * trigger discovery.
> +	 */
>  	peer = lpni->lpni_peer_net->lpn_peer;
> +	if (lnet_msg_discovery(msg) && !lnet_peer_is_uptodate(peer)) {
> +		rc = lnet_discover_peer_locked(lpni, cpt);
> +		if (rc) {
> +			lnet_peer_ni_decref_locked(lpni);
> +			lnet_net_unlock(cpt);
> +			return rc;
> +		}
> +		/* The peer may have changed. */
> +		peer = lpni->lpni_peer_net->lpn_peer;
> +	}
>  	lnet_peer_ni_decref_locked(lpni);
>  
>  	/* If peer is not healthy then can not send anything to it */
> @@ -1701,6 +1729,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>  	 */
>  	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
>  	if (cpt != cpt2) {
> +		__u32 seq = lnet_get_dlc_seq_locked();
>  		lnet_net_unlock(cpt);
>  		cpt = cpt2;
>  		lnet_net_lock(cpt);
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index d7a0a2f3bdd9..038b58414ce0 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -201,6 +201,8 @@ lnet_peer_alloc(lnet_nid_t nid)
>  
>  	INIT_LIST_HEAD(&lp->lp_peer_list);
>  	INIT_LIST_HEAD(&lp->lp_peer_nets);
> +	INIT_LIST_HEAD(&lp->lp_dc_list);
> +	init_waitqueue_head(&lp->lp_dc_waitq);
>  	spin_lock_init(&lp->lp_lock);
>  	lp->lp_primary_nid = nid;
>  	lp->lp_cpt = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
> @@ -1457,6 +1459,10 @@ lnet_nid2peerni_ex(lnet_nid_t nid, int cpt)
>  	return lpni;
>  }
>  
> +/*
> + * Get a peer_ni for the given nid, create it if necessary. Takes a
> + * hold on the peer_ni.
> + */
>  struct lnet_peer_ni *
>  lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref, int cpt)
>  {
> @@ -1510,9 +1516,326 @@ lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref, int cpt)
>  	mutex_unlock(&the_lnet.ln_api_mutex);
>  	lnet_net_lock(cpt);
>  
> +	/* Lock has been dropped, check again for shutdown. */
> +	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
> +		if (!IS_ERR(lpni))
> +			lnet_peer_ni_decref_locked(lpni);
> +		lpni = ERR_PTR(-ESHUTDOWN);
> +	}
> +
>  	return lpni;
>  }
>  
> +/*
> + * Peer Discovery
> + */
> +
> +/*
> + * Is a peer uptodate from the point of view of discovery?
> + *
> + * If it is currently being processed, obviously not.
> + * A forced Ping or Push is also handled by the discovery thread.
> + *
> + * Otherwise look at whether the peer needs rediscovering.
> + */
> +bool
> +lnet_peer_is_uptodate(struct lnet_peer *lp)
> +{
> +	bool rc;
> +
> +	spin_lock(&lp->lp_lock);
> +	if (lp->lp_state & (LNET_PEER_DISCOVERING |
> +			    LNET_PEER_FORCE_PING |
> +			    LNET_PEER_FORCE_PUSH)) {
> +		rc = false;
> +	} else if (lp->lp_state & LNET_PEER_REDISCOVER) {
> +		if (lnet_peer_discovery_disabled)
> +			rc = true;
> +		else
> +			rc = false;
> +	} else if (lp->lp_state & LNET_PEER_DISCOVERED) {
> +		if (lp->lp_state & LNET_PEER_NIDS_UPTODATE)
> +			rc = true;
> +		else
> +			rc = false;
> +	} else {
> +		rc = false;
> +	}
> +	spin_unlock(&lp->lp_lock);
> +
> +	return rc;
> +}
> +
> +/*
> + * Queue a peer for the attention of the discovery thread.  Call with
> + * lnet_net_lock/EX held. Returns 0 if the peer was queued, and
> + * -EALREADY if the peer was already queued.
> + */
> +static int lnet_peer_queue_for_discovery(struct lnet_peer *lp)
> +{
> +	int rc;
> +
> +	spin_lock(&lp->lp_lock);
> +	if (!(lp->lp_state & LNET_PEER_DISCOVERING))
> +		lp->lp_state |= LNET_PEER_DISCOVERING;
> +	spin_unlock(&lp->lp_lock);
> +	if (list_empty(&lp->lp_dc_list)) {
> +		lnet_peer_addref_locked(lp);
> +		list_add_tail(&lp->lp_dc_list, &the_lnet.ln_dc_request);
> +		wake_up(&the_lnet.ln_dc_waitq);
> +		rc = 0;
> +	} else {
> +		rc = -EALREADY;
> +	}
> +
> +	return rc;
> +}
> +
> +/*
> + * Discovery of a peer is complete. Wake all waiters on the peer.
> + * Call with lnet_net_lock/EX held.
> + */
> +static void lnet_peer_discovery_complete(struct lnet_peer *lp)
> +{
> +	list_del_init(&lp->lp_dc_list);
> +	wake_up_all(&lp->lp_dc_waitq);
> +	lnet_peer_decref_locked(lp);
> +}
> +
> +/*
> + * Peer discovery slow path. The ln_api_mutex is held on entry, and
> + * dropped/retaken within this function. An lnet_peer_ni is passed in
> + * because discovery could tear down an lnet_peer.
> + */
> +int
> +lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt)
> +{
> +	DEFINE_WAIT(wait);
> +	struct lnet_peer *lp;
> +	int rc = 0;
> +
> +again:
> +	lnet_net_unlock(cpt);
> +	lnet_net_lock(LNET_LOCK_EX);
> +
> +	/* We're willing to be interrupted. */
> +	for (;;) {
> +		lp = lpni->lpni_peer_net->lpn_peer;
> +		prepare_to_wait(&lp->lp_dc_waitq, &wait, TASK_INTERRUPTIBLE);
> +		if (signal_pending(current))
> +			break;
> +		if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
> +			break;
> +		if (lnet_peer_is_uptodate(lp))
> +			break;
> +		lnet_peer_queue_for_discovery(lp);
> +		lnet_peer_addref_locked(lp);
> +		lnet_net_unlock(LNET_LOCK_EX);
> +		schedule();
> +		finish_wait(&lp->lp_dc_waitq, &wait);
> +		lnet_net_lock(LNET_LOCK_EX);
> +		lnet_peer_decref_locked(lp);
> +		/* Do not use lp beyond this point. */
> +	}
> +	finish_wait(&lp->lp_dc_waitq, &wait);
> +
> +	lnet_net_unlock(LNET_LOCK_EX);
> +	lnet_net_lock(cpt);
> +
> +	if (signal_pending(current))
> +		rc = -EINTR;
> +	else if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
> +		rc = -ESHUTDOWN;
> +	else if (!lnet_peer_is_uptodate(lp))
> +		goto again;
> +
> +	return rc;
> +}
> +
> +/*
> + * Event handler for the discovery EQ.
> + *
> + * Called with lnet_res_lock(cpt) held. The cpt is the
> + * lnet_cpt_of_cookie() of the md handle cookie.
> + */
> +static void lnet_discovery_event_handler(struct lnet_event *event)
> +{
> +	wake_up(&the_lnet.ln_dc_waitq);
> +}
> +
> +/*
> + * Wait for work to be queued or some other change that must be
> + * attended to. Returns non-zero if the discovery thread should shut
> + * down.
> + */
> +static int lnet_peer_discovery_wait_for_work(void)
> +{
> +	int cpt;
> +	int rc = 0;
> +
> +	DEFINE_WAIT(wait);
> +
> +	cpt = lnet_net_lock_current();
> +	for (;;) {
> +		prepare_to_wait(&the_lnet.ln_dc_waitq, &wait,
> +				TASK_IDLE);
> +		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
> +			break;
> +		if (!list_empty(&the_lnet.ln_dc_request))
> +			break;
> +		lnet_net_unlock(cpt);
> +		schedule();
> +		finish_wait(&the_lnet.ln_dc_waitq, &wait);
> +		cpt = lnet_net_lock_current();
> +	}
> +	finish_wait(&the_lnet.ln_dc_waitq, &wait);
> +
> +	if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
> +		rc = -ESHUTDOWN;
> +
> +	lnet_net_unlock(cpt);
> +
> +	CDEBUG(D_NET, "woken: %d\n", rc);
> +
> +	return rc;
> +}
> +
> +/* The discovery thread. */
> +static int lnet_peer_discovery(void *arg)
> +{
> +	struct lnet_peer *lp;
> +
> +	CDEBUG(D_NET, "started\n");
> +
> +	for (;;) {
> +		if (lnet_peer_discovery_wait_for_work())
> +			break;
> +
> +		lnet_net_lock(LNET_LOCK_EX);
> +		if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
> +			break;
> +		while (!list_empty(&the_lnet.ln_dc_request)) {
> +			lp = list_first_entry(&the_lnet.ln_dc_request,
> +					      struct lnet_peer, lp_dc_list);
> +			list_move(&lp->lp_dc_list, &the_lnet.ln_dc_working);
> +			lnet_net_unlock(LNET_LOCK_EX);
> +
> +			/* Just tag and release for now. */
> +			spin_lock(&lp->lp_lock);
> +			if (lnet_peer_discovery_disabled) {
> +				lp->lp_state |= LNET_PEER_REDISCOVER;
> +				lp->lp_state &= ~(LNET_PEER_DISCOVERED |
> +						  LNET_PEER_NIDS_UPTODATE |
> +						  LNET_PEER_DISCOVERING);
> +			} else {
> +				lp->lp_state |= (LNET_PEER_DISCOVERED |
> +						 LNET_PEER_NIDS_UPTODATE);
> +				lp->lp_state &= ~(LNET_PEER_REDISCOVER |
> +						  LNET_PEER_DISCOVERING);
> +			}
> +			spin_unlock(&lp->lp_lock);
> +
> +			lnet_net_lock(LNET_LOCK_EX);
> +			if (!(lp->lp_state & LNET_PEER_DISCOVERING))
> +				lnet_peer_discovery_complete(lp);
> +			if (the_lnet.ln_dc_state == LNET_DC_STATE_STOPPING)
> +				break;
> +		}
> +		lnet_net_unlock(LNET_LOCK_EX);
> +	}
> +
> +	CDEBUG(D_NET, "stopping\n");
> +	/*
> +	 * Clean up before telling lnet_peer_discovery_stop() that
> +	 * we're done. Use wake_up() below to somewhat reduce the
> +	 * size of the thundering herd if there are multiple threads
> +	 * waiting on discovery of a single peer.
> +	 */
> +	LNetEQFree(the_lnet.ln_dc_eqh);
> +	LNetInvalidateEQHandle(&the_lnet.ln_dc_eqh);
> +
> +	lnet_net_lock(LNET_LOCK_EX);
> +	list_for_each_entry(lp, &the_lnet.ln_dc_request, lp_dc_list) {
> +		spin_lock(&lp->lp_lock);
> +		lp->lp_state |= LNET_PEER_REDISCOVER;
> +		lp->lp_state &= ~(LNET_PEER_DISCOVERED |
> +				  LNET_PEER_DISCOVERING |
> +				  LNET_PEER_NIDS_UPTODATE);
> +		spin_unlock(&lp->lp_lock);
> +		lnet_peer_discovery_complete(lp);
> +	}
> +	list_for_each_entry(lp, &the_lnet.ln_dc_working, lp_dc_list) {
> +		spin_lock(&lp->lp_lock);
> +		lp->lp_state |= LNET_PEER_REDISCOVER;
> +		lp->lp_state &= ~(LNET_PEER_DISCOVERED |
> +				  LNET_PEER_DISCOVERING |
> +				  LNET_PEER_NIDS_UPTODATE);
> +		spin_unlock(&lp->lp_lock);
> +		lnet_peer_discovery_complete(lp);
> +	}
> +	lnet_net_unlock(LNET_LOCK_EX);
> +
> +	the_lnet.ln_dc_state = LNET_DC_STATE_SHUTDOWN;
> +	wake_up(&the_lnet.ln_dc_waitq);
> +
> +	CDEBUG(D_NET, "stopped\n");
> +
> +	return 0;
> +}
> +
> +/* ln_api_mutex is held on entry. */
> +int lnet_peer_discovery_start(void)
> +{
> +	struct task_struct *task;
> +	int rc;
> +
> +	if (the_lnet.ln_dc_state != LNET_DC_STATE_SHUTDOWN)
> +		return -EALREADY;
> +
> +	INIT_LIST_HEAD(&the_lnet.ln_dc_request);
> +	INIT_LIST_HEAD(&the_lnet.ln_dc_working);
> +	init_waitqueue_head(&the_lnet.ln_dc_waitq);
> +
> +	rc = LNetEQAlloc(0, lnet_discovery_event_handler, &the_lnet.ln_dc_eqh);
> +	if (rc != 0) {
> +		CERROR("Can't allocate discovery EQ: %d\n", rc);
> +		return rc;
> +	}
> +
> +	the_lnet.ln_dc_state = LNET_DC_STATE_RUNNING;
> +	task = kthread_run(lnet_peer_discovery, NULL, "lnet_discovery");
> +	if (IS_ERR(task)) {
> +		rc = PTR_ERR(task);
> +		CERROR("Can't start peer discovery thread: %d\n", rc);
> +
> +		LNetEQFree(the_lnet.ln_dc_eqh);
> +		LNetInvalidateEQHandle(&the_lnet.ln_dc_eqh);
> +
> +		the_lnet.ln_dc_state = LNET_DC_STATE_SHUTDOWN;
> +	}
> +
> +	return rc;
> +}
> +
> +/* ln_api_mutex is held on entry. */
> +void lnet_peer_discovery_stop(void)
> +{
> +	if (the_lnet.ln_dc_state == LNET_DC_STATE_SHUTDOWN)
> +		return;
> +
> +	LASSERT(the_lnet.ln_dc_state == LNET_DC_STATE_RUNNING);
> +	the_lnet.ln_dc_state = LNET_DC_STATE_STOPPING;
> +	wake_up(&the_lnet.ln_dc_waitq);
> +
> +	wait_event(the_lnet.ln_dc_waitq,
> +		   the_lnet.ln_dc_state == LNET_DC_STATE_SHUTDOWN);
> +
> +	LASSERT(list_empty(&the_lnet.ln_dc_request));
> +	LASSERT(list_empty(&the_lnet.ln_dc_working));
> +}
> +
> +/* Debugging */
> +
>  void
>  lnet_debug_peer(lnet_nid_t nid)
>  {
> @@ -1544,6 +1867,8 @@ lnet_debug_peer(lnet_nid_t nid)
>  	lnet_net_unlock(cpt);
>  }
>  
> +/* Gathering information for userspace. */
> +
>  int
>  lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
>  		      char aliveness[LNET_MAX_STR_LEN],
> 
> 
> 
