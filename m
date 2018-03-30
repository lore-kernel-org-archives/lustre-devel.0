From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 20:00:53 +0100 (BST)
Subject: [lustre-devel] [PATCH 09/17] staging: lustre:
 cfs_time_current() -> jiffies.
In-Reply-To: <152229760851.27689.14128151136322766936.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760851.27689.14128151136322766936.stgit@noble>
Message-ID: <alpine.LFD.2.21.1803302000440.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> Discard cfs_time_current() and cfs_time_current64()
> and use jiffies and get_jiffies_64() like the rest of the kernel.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/linux/libcfs/libcfs_time.h      |    2 -
>  .../lustre/include/linux/libcfs/linux/linux-time.h |    9 ----
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   14 +++---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 ++--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    9 ++--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   44 ++++++++++----------
>  drivers/staging/lustre/lnet/libcfs/tracefile.c     |    6 +--
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 +-
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |    6 +--
>  drivers/staging/lustre/lnet/lnet/peer.c            |    2 -
>  drivers/staging/lustre/lnet/lnet/router.c          |    6 +--
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |    4 +-
>  drivers/staging/lustre/lnet/selftest/conrpc.c      |    6 +--
>  drivers/staging/lustre/lnet/selftest/console.c     |    4 +-
>  drivers/staging/lustre/lnet/selftest/framework.c   |    2 -
>  drivers/staging/lustre/lustre/include/lustre_net.h |    2 -
>  drivers/staging/lustre/lustre/include/obd_class.h  |    6 +--
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    2 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   10 ++---
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 -
>  .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
>  drivers/staging/lustre/lustre/llite/statahead.c    |    2 -
>  drivers/staging/lustre/lustre/lov/lov_request.c    |    4 +-
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |    2 -
>  drivers/staging/lustre/lustre/osc/osc_object.c     |    4 +-
>  drivers/staging/lustre/lustre/osc/osc_page.c       |    4 +-
>  drivers/staging/lustre/lustre/osc/osc_request.c    |    2 -
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 +-
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 -
>  drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    4 +-
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 +-
>  32 files changed, 88 insertions(+), 96 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> index c4f25be78268..df7a3f13f3b3 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> @@ -62,7 +62,7 @@ static inline int cfs_time_aftereq(unsigned long t1, unsigned long t2)
>  
>  static inline unsigned long cfs_time_shift(int seconds)
>  {
> -	return cfs_time_add(cfs_time_current(), seconds * HZ);
> +	return cfs_time_add(jiffies, seconds * HZ);
>  }
>  
>  /*
> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> index 805cb326af86..ba115e8c820f 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> @@ -60,18 +60,11 @@
>   * Generic kernel stuff
>   */
>  
> -static inline unsigned long cfs_time_current(void)
> -{
> -	return jiffies;
> -}
> -
>  static inline long cfs_duration_sec(long d)
>  {
>  	return d / msecs_to_jiffies(MSEC_PER_SEC);
>  }
>  
> -#define cfs_time_current_64 get_jiffies_64
> -
>  static inline u64 cfs_time_add_64(u64 t, u64 d)
>  {
>  	return t + d;
> @@ -79,7 +72,7 @@ static inline u64 cfs_time_add_64(u64 t, u64 d)
>  
>  static inline u64 cfs_time_shift_64(int seconds)
>  {
> -	return cfs_time_add_64(cfs_time_current_64(),
> +	return cfs_time_add_64(get_jiffies_64(),
>  			       seconds * HZ);
>  }
>  
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 7ae2955c4db6..7df07f39b849 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1043,7 +1043,7 @@ static void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid,
>  			 unsigned long *when)
>  {
>  	unsigned long last_alive = 0;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  	rwlock_t *glock = &kiblnd_data.kib_global_lock;
>  	struct kib_peer *peer;
>  	unsigned long flags;
> @@ -1552,7 +1552,7 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
>  	LIST_HEAD(zombies);
>  	struct kib_fmr_pool *fpo = fmr->fmr_pool;
>  	struct kib_fmr_poolset *fps;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  	struct kib_fmr_pool *tmp;
>  	int rc;
>  
> @@ -1726,7 +1726,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
>  		goto again;
>  	}
>  
> -	if (time_before(cfs_time_current(), fps->fps_next_retry)) {
> +	if (time_before(jiffies, fps->fps_next_retry)) {
>  		/* someone failed recently */
>  		spin_unlock(&fps->fps_lock);
>  		return -EAGAIN;
> @@ -1858,7 +1858,7 @@ void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node)
>  	LIST_HEAD(zombies);
>  	struct kib_poolset *ps = pool->po_owner;
>  	struct kib_pool *tmp;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  
>  	spin_lock(&ps->ps_lock);
>  
> @@ -1927,7 +1927,7 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
>  		goto again;
>  	}
>  
> -	if (time_before(cfs_time_current(), ps->ps_next_retry)) {
> +	if (time_before(jiffies, ps->ps_next_retry)) {
>  		/* someone failed recently */
>  		spin_unlock(&ps->ps_lock);
>  		return NULL;
> @@ -1937,10 +1937,10 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
>  	spin_unlock(&ps->ps_lock);
>  
>  	CDEBUG(D_NET, "%s pool exhausted, allocate new pool\n", ps->ps_name);
> -	time_before = cfs_time_current();
> +	time_before = jiffies;
>  	rc = ps->ps_pool_create(ps, ps->ps_pool_size, &pool);
>  	CDEBUG(D_NET, "ps_pool_create took %lu HZ to complete",
> -	       cfs_time_current() - time_before);
> +	       jiffies - time_before);
>  
>  	spin_lock(&ps->ps_lock);
>  	ps->ps_increasing = 0;
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 6690a6cd4e34..c1c3277f4c1f 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -1853,8 +1853,8 @@ kiblnd_thread_fini(void)
>  static void
>  kiblnd_peer_alive(struct kib_peer *peer)
>  {
> -	/* This is racy, but everyone's only writing cfs_time_current() */
> -	peer->ibp_last_alive = cfs_time_current();
> +	/* This is racy, but everyone's only writing jiffies */
> +	peer->ibp_last_alive = jiffies;
>  	mb();
>  }
>  
> @@ -3206,7 +3206,7 @@ kiblnd_check_conns(int idx)
>  			if (timedout) {
>  				CERROR("Timed out RDMA with %s (%lu): c: %u, oc: %u, rc: %u\n",
>  				       libcfs_nid2str(peer->ibp_nid),
> -				       cfs_duration_sec(cfs_time_current() -
> +				       cfs_duration_sec(jiffies -
>  							peer->ibp_last_alive),
>  				       conn->ibc_credits,
>  				       conn->ibc_outstanding_credits,
> @@ -3681,7 +3681,7 @@ kiblnd_failover_thread(void *arg)
>  
>  		list_for_each_entry(dev, &kiblnd_data.kib_failed_devs,
>  				    ibd_fail_list) {
> -			if (time_before(cfs_time_current(),
> +			if (time_before(jiffies,
>  					dev->ibd_next_failover))
>  				continue;
>  			do_failover = 1;
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 7086678e1c3e..0efde0009a15 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -1276,7 +1276,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
>  	}
>  
>  	conn->ksnc_peer = peer;		 /* conn takes my ref on peer */
> -	peer->ksnp_last_alive = cfs_time_current();
> +	peer->ksnp_last_alive = jiffies;
>  	peer->ksnp_send_keepalive = 0;
>  	peer->ksnp_error = 0;
>  
> @@ -1284,7 +1284,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
>  	sched->kss_nconns++;
>  	conn->ksnc_scheduler = sched;
>  
> -	conn->ksnc_tx_last_post = cfs_time_current();
> +	conn->ksnc_tx_last_post = jiffies;
>  	/* Set the deadline for the outgoing HELLO to drain */
>  	conn->ksnc_tx_bufnob = sock->sk->sk_wmem_queued;
>  	conn->ksnc_tx_deadline = cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
> @@ -1682,8 +1682,7 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
>  		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
>  		       &conn->ksnc_ipaddr, conn->ksnc_port,
>  		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
> -		       cfs_duration_sec(cfs_time_sub(cfs_time_current(),
> -						     last_rcv)));
> +		       cfs_duration_sec(cfs_time_sub(jiffies, last_rcv)));
>  		lnet_finalize(conn->ksnc_peer->ksnp_ni,
>  			      conn->ksnc_cookie, -EIO);
>  		break;
> @@ -1832,7 +1831,7 @@ ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when)
>  {
>  	int connect = 1;
>  	unsigned long last_alive = 0;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  	struct ksock_peer *peer = NULL;
>  	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
>  	struct lnet_process_id id = {
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index 036fecbcede8..f97da4540b51 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -222,7 +222,7 @@ ksocknal_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
>  			 */
>  			conn->ksnc_tx_deadline =
>  				cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
> -			conn->ksnc_peer->ksnp_last_alive = cfs_time_current();
> +			conn->ksnc_peer->ksnp_last_alive = jiffies;
>  			conn->ksnc_tx_bufnob = bufnob;
>  			mb();
>  		}
> @@ -267,7 +267,7 @@ ksocknal_recv_iter(struct ksock_conn *conn)
>  	/* received something... */
>  	nob = rc;
>  
> -	conn->ksnc_peer->ksnp_last_alive = cfs_time_current();
> +	conn->ksnc_peer->ksnp_last_alive = jiffies;
>  	conn->ksnc_rx_deadline =
>  		cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
>  	mb();		       /* order with setting rx_started */
> @@ -481,7 +481,7 @@ ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
>  		LASSERT(conn->ksnc_tx_scheduled);
>  		list_add_tail(&conn->ksnc_tx_list,
>  			      &ksocknal_data.ksnd_enomem_conns);
> -		if (!cfs_time_aftereq(cfs_time_add(cfs_time_current(),
> +		if (!cfs_time_aftereq(cfs_time_add(jiffies,
>  						   SOCKNAL_ENOMEM_RETRY),
>  				   ksocknal_data.ksnd_reaper_waketime))
>  			wake_up(&ksocknal_data.ksnd_reaper_waitq);
> @@ -612,7 +612,7 @@ ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
>  	conn = (typed) ? typed : fallback;
>  
>  	if (conn)
> -		conn->ksnc_tx_last_post = cfs_time_current();
> +		conn->ksnc_tx_last_post = jiffies;
>  
>  	return conn;
>  }
> @@ -680,7 +680,7 @@ ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
>  		conn->ksnc_tx_deadline =
>  			cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
>  		if (conn->ksnc_tx_bufnob > 0) /* something got ACKed */
> -			conn->ksnc_peer->ksnp_last_alive = cfs_time_current();
> +			conn->ksnc_peer->ksnp_last_alive = jiffies;
>  		conn->ksnc_tx_bufnob = 0;
>  		mb(); /* order with adding to tx_queue */
>  	}
> @@ -728,7 +728,7 @@ ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn)
>  struct ksock_route *
>  ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
>  {
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  	struct list_head *tmp;
>  	struct ksock_route *route;
>  
> @@ -1777,7 +1777,7 @@ ksocknal_connect(struct ksock_route *route)
>  	int retry_later = 0;
>  	int rc = 0;
>  
> -	deadline = cfs_time_add(cfs_time_current(),
> +	deadline = cfs_time_add(jiffies,
>  				*ksocknal_tunables.ksnd_timeout * HZ);
>  
>  	write_lock_bh(&ksocknal_data.ksnd_global_lock);
> @@ -1825,7 +1825,7 @@ ksocknal_connect(struct ksock_route *route)
>  
>  		write_unlock_bh(&ksocknal_data.ksnd_global_lock);
>  
> -		if (cfs_time_aftereq(cfs_time_current(), deadline)) {
> +		if (cfs_time_aftereq(jiffies, deadline)) {
>  			rc = -ETIMEDOUT;
>  			lnet_connect_console_error(rc, peer->ksnp_id.nid,
>  						   route->ksnr_ipaddr,
> @@ -1877,7 +1877,7 @@ ksocknal_connect(struct ksock_route *route)
>  			 */
>  			route->ksnr_retry_interval =
>  				*ksocknal_tunables.ksnd_min_reconnectms * HZ / 1000;
> -			route->ksnr_timeout = cfs_time_add(cfs_time_current(),
> +			route->ksnr_timeout = cfs_time_add(jiffies,
>  							   route->ksnr_retry_interval);
>  		}
>  
> @@ -1903,7 +1903,7 @@ ksocknal_connect(struct ksock_route *route)
>  		    (long)*ksocknal_tunables.ksnd_max_reconnectms * HZ / 1000);
>  
>  	LASSERT(route->ksnr_retry_interval);
> -	route->ksnr_timeout = cfs_time_add(cfs_time_current(),
> +	route->ksnr_timeout = cfs_time_add(jiffies,
>  					   route->ksnr_retry_interval);
>  
>  	if (!list_empty(&peer->ksnp_tx_queue) &&
> @@ -2050,7 +2050,7 @@ ksocknal_connd_get_route_locked(signed long *timeout_p)
>  	struct ksock_route *route;
>  	unsigned long now;
>  
> -	now = cfs_time_current();
> +	now = jiffies;
>  
>  	/* connd_routes can contain both pending and ordinary routes */
>  	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
> @@ -2228,7 +2228,7 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
>  		}
>  
>  		if (conn->ksnc_rx_started &&
> -		    cfs_time_aftereq(cfs_time_current(),
> +		    cfs_time_aftereq(jiffies,
>  				     conn->ksnc_rx_deadline)) {
>  			/* Timed out incomplete incoming message */
>  			ksocknal_conn_addref(conn);
> @@ -2244,7 +2244,7 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
>  
>  		if ((!list_empty(&conn->ksnc_tx_queue) ||
>  		     conn->ksnc_sock->sk->sk_wmem_queued) &&
> -		    cfs_time_aftereq(cfs_time_current(),
> +		    cfs_time_aftereq(jiffies,
>  				     conn->ksnc_tx_deadline)) {
>  			/*
>  			 * Timed out messages queued for sending or
> @@ -2272,7 +2272,7 @@ ksocknal_flush_stale_txs(struct ksock_peer *peer)
>  	write_lock_bh(&ksocknal_data.ksnd_global_lock);
>  
>  	list_for_each_entry_safe(tx, tmp, &peer->ksnp_tx_queue, tx_list) {
> -		if (!cfs_time_aftereq(cfs_time_current(),
> +		if (!cfs_time_aftereq(jiffies,
>  				      tx->tx_deadline))
>  			break;
>  
> @@ -2301,12 +2301,12 @@ ksocknal_send_keepalive_locked(struct ksock_peer *peer)
>  		return 0;
>  
>  	if (*ksocknal_tunables.ksnd_keepalive <= 0 ||
> -	    time_before(cfs_time_current(),
> +	    time_before(jiffies,
>  			cfs_time_add(peer->ksnp_last_alive,
>  				     *ksocknal_tunables.ksnd_keepalive * HZ)))
>  		return 0;
>  
> -	if (time_before(cfs_time_current(), peer->ksnp_send_keepalive))
> +	if (time_before(jiffies, peer->ksnp_send_keepalive))
>  		return 0;
>  
>  	/*
> @@ -2400,7 +2400,7 @@ ksocknal_check_peer_timeouts(int idx)
>  			tx = list_entry(peer->ksnp_tx_queue.next,
>  					struct ksock_tx, tx_list);
>  
> -			if (cfs_time_aftereq(cfs_time_current(),
> +			if (cfs_time_aftereq(jiffies,
>  					     tx->tx_deadline)) {
>  				ksocknal_peer_addref(peer);
>  				read_unlock(&ksocknal_data.ksnd_global_lock);
> @@ -2418,7 +2418,7 @@ ksocknal_check_peer_timeouts(int idx)
>  		tx_stale = NULL;
>  		spin_lock(&peer->ksnp_lock);
>  		list_for_each_entry(tx, &peer->ksnp_zc_req_list, tx_zc_list) {
> -			if (!cfs_time_aftereq(cfs_time_current(),
> +			if (!cfs_time_aftereq(jiffies,
>  					      tx->tx_deadline))
>  				break;
>  			/* ignore the TX if connection is being closed */
> @@ -2444,7 +2444,7 @@ ksocknal_check_peer_timeouts(int idx)
>  
>  		CERROR("Total %d stale ZC_REQs for peer %s detected; the oldest(%p) timed out %ld secs ago, resid: %d, wmem: %d\n",
>  		       n, libcfs_nid2str(peer->ksnp_id.nid), tx_stale,
> -		       cfs_duration_sec(cfs_time_current() - deadline),
> +		       cfs_duration_sec(jiffies - deadline),
>  		       resid, conn->ksnc_sock->sk->sk_wmem_queued);
>  
>  		ksocknal_close_conn_and_siblings(conn, -ETIMEDOUT);
> @@ -2466,7 +2466,7 @@ ksocknal_reaper(void *arg)
>  	long timeout;
>  	int i;
>  	int peer_index = 0;
> -	unsigned long deadline = cfs_time_current();
> +	unsigned long deadline = jiffies;
>  
>  	INIT_LIST_HEAD(&enomem_conns);
>  	init_waitqueue_entry(&wait, current);
> @@ -2532,7 +2532,7 @@ ksocknal_reaper(void *arg)
>  
>  		/* careful with the jiffy wrap... */
>  		while ((timeout = cfs_time_sub(deadline,
> -					       cfs_time_current())) <= 0) {
> +					       jiffies)) <= 0) {
>  			const int n = 4;
>  			const int p = 1;
>  			int chunk = ksocknal_data.ksnd_peer_hash_size;
> @@ -2569,7 +2569,7 @@ ksocknal_reaper(void *arg)
>  			timeout = SOCKNAL_ENOMEM_RETRY;
>  		}
>  		ksocknal_data.ksnd_reaper_waketime =
> -			cfs_time_add(cfs_time_current(), timeout);
> +			cfs_time_add(jiffies, timeout);
>  
>  		set_current_state(TASK_INTERRUPTIBLE);
>  		add_wait_queue(&ksocknal_data.ksnd_reaper_waitq, &wait);
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index 4affca750bc5..2aeae0331ee0 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -431,7 +431,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
>  	if (cdls) {
>  		if (libcfs_console_ratelimit &&
>  		    cdls->cdls_next &&		/* not first time ever */
> -		    !cfs_time_after(cfs_time_current(), cdls->cdls_next)) {
> +		    !cfs_time_after(jiffies, cdls->cdls_next)) {
>  			/* skipping a console message */
>  			cdls->cdls_count++;
>  			if (tcd)
> @@ -439,7 +439,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
>  			return 1;
>  		}
>  
> -		if (cfs_time_after(cfs_time_current(),
> +		if (cfs_time_after(jiffies,
>  				   cdls->cdls_next + libcfs_console_max_delay +
>  				   10 * HZ)) {
>  			/* last timeout was a long time ago */
> @@ -454,7 +454,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
>  			cdls->cdls_delay = libcfs_console_max_delay;
>  
>  		/* ensure cdls_next is never zero after it's been seen */
> -		cdls->cdls_next = (cfs_time_current() + cdls->cdls_delay) | 1;
> +		cdls->cdls_next = (jiffies + cdls->cdls_delay) | 1;
>  	}
>  
>  	if (tcd) {
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index ed43b3f4b114..289ed876bd81 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -501,7 +501,7 @@ lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
>  	ni->ni_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
>  	lnet_net_lock(lp->lp_cpt);
>  
> -	lp->lp_last_query = cfs_time_current();
> +	lp->lp_last_query = jiffies;
>  
>  	if (last_alive) /* NI has updated timestamp */
>  		lp->lp_last_alive = last_alive;
> @@ -545,7 +545,7 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
>  static int
>  lnet_peer_alive_locked(struct lnet_peer *lp)
>  {
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  
>  	if (!lnet_peer_aliveness_enabled(lp))
>  		return -ENODEV;
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> index a63b7941d435..3928e9a74d6f 100644
> --- a/drivers/staging/lustre/lnet/lnet/net_fault.c
> +++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
> @@ -306,7 +306,7 @@ drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
>  	/* match this rule, check drop rate now */
>  	spin_lock(&rule->dr_lock);
>  	if (rule->dr_drop_time) { /* time based drop */
> -		unsigned long now = cfs_time_current();
> +		unsigned long now = jiffies;
>  
>  		rule->dr_stat.fs_count++;
>  		drop = cfs_time_aftereq(now, rule->dr_drop_time);
> @@ -472,7 +472,7 @@ delay_rule_match(struct lnet_delay_rule *rule, lnet_nid_t src,
>  	/* match this rule, check delay rate now */
>  	spin_lock(&rule->dl_lock);
>  	if (rule->dl_delay_time) { /* time based delay */
> -		unsigned long now = cfs_time_current();
> +		unsigned long now = jiffies;
>  
>  		rule->dl_stat.fs_count++;
>  		delay = cfs_time_aftereq(now, rule->dl_delay_time);
> @@ -562,7 +562,7 @@ delayed_msg_check(struct lnet_delay_rule *rule, bool all,
>  {
>  	struct lnet_msg *msg;
>  	struct lnet_msg *tmp;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  
>  	if (!all && rule->dl_msg_send > now)
>  		return;
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 3d4caa609c83..58294149f7b2 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -315,7 +315,7 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
>  	lp->lp_alive_count = 0;
>  	lp->lp_timestamp = 0;
>  	lp->lp_alive = !lnet_peers_start_down(); /* 1 bit!! */
> -	lp->lp_last_alive = cfs_time_current(); /* assumes alive */
> +	lp->lp_last_alive = jiffies; /* assumes alive */
>  	lp->lp_last_query = 0; /* haven't asked NI yet */
>  	lp->lp_ping_timestamp = 0;
>  	lp->lp_ping_feats = LNET_PING_FEAT_INVAL;
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index a3c3f4959f46..ac9b392a0afa 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -765,7 +765,7 @@ lnet_router_checker_event(struct lnet_event *event)
>  	 * we ping alive routers to try to detect router death before
>  	 * apps get burned).
>  	 */
> -	lnet_notify_locked(lp, 1, !event->status, cfs_time_current());
> +	lnet_notify_locked(lp, 1, !event->status, jiffies);
>  
>  	/*
>  	 * The router checker will wake up very shortly and do the
> @@ -976,7 +976,7 @@ static void
>  lnet_ping_router_locked(struct lnet_peer *rtr)
>  {
>  	struct lnet_rc_data *rcd = NULL;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  	int secs;
>  
>  	lnet_peer_addref_locked(rtr);
> @@ -1730,7 +1730,7 @@ int
>  lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, unsigned long when)
>  {
>  	struct lnet_peer *lp = NULL;
> -	unsigned long now = cfs_time_current();
> +	unsigned long now = jiffies;
>  	int cpt = lnet_cpt_of_nid(nid);
>  
>  	LASSERT(!in_interrupt());
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 1a71ffebc889..315d067540c0 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -324,7 +324,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
>  
>  		if (peer) {
>  			lnet_nid_t nid = peer->lp_nid;
> -			unsigned long now = cfs_time_current();
> +			unsigned long now = jiffies;
>  			unsigned long deadline = peer->lp_ping_deadline;
>  			int nrefs = peer->lp_refcount;
>  			int nrtrrefs = peer->lp_rtr_refcount;
> @@ -509,7 +509,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  				aliveness = peer->lp_alive ? "up" : "down";
>  
>  			if (lnet_peer_aliveness_enabled(peer)) {
> -				unsigned long now = cfs_time_current();
> +				unsigned long now = jiffies;
>  				long delta;
>  
>  				delta = cfs_time_sub(now, peer->lp_last_alive);
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> index 6dcc966b293b..68e06e06857d 100644
> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
> @@ -75,7 +75,7 @@ lstcon_rpc_done(struct srpc_client_rpc *rpc)
>  		/* not aborted */
>  		LASSERT(!crpc->crp_status);
>  
> -		crpc->crp_stamp = cfs_time_current();
> +		crpc->crp_stamp = jiffies;
>  		crpc->crp_status = rpc->crpc_status;
>  	}
>  
> @@ -297,14 +297,14 @@ lstcon_rpc_trans_abort(struct lstcon_rpc_trans *trans, int error)
>  		if (!crpc->crp_posted || /* not posted */
>  		    crpc->crp_stamp) {	 /* rpc done or aborted already */
>  			if (!crpc->crp_stamp) {
> -				crpc->crp_stamp = cfs_time_current();
> +				crpc->crp_stamp = jiffies;
>  				crpc->crp_status = -EINTR;
>  			}
>  			spin_unlock(&rpc->crpc_lock);
>  			continue;
>  		}
>  
> -		crpc->crp_stamp = cfs_time_current();
> +		crpc->crp_stamp = jiffies;
>  		crpc->crp_status = error;
>  
>  		spin_unlock(&rpc->crpc_lock);
> diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
> index 1acd5cb324b1..1889f1e86473 100644
> --- a/drivers/staging/lustre/lnet/selftest/console.c
> +++ b/drivers/staging/lustre/lnet/selftest/console.c
> @@ -98,7 +98,7 @@ lstcon_node_find(struct lnet_process_id id, struct lstcon_node **ndpp,
>  
>  	ndl->ndl_node->nd_ref = 1;
>  	ndl->ndl_node->nd_id = id;
> -	ndl->ndl_node->nd_stamp = cfs_time_current();
> +	ndl->ndl_node->nd_stamp = jiffies;
>  	ndl->ndl_node->nd_state = LST_NODE_UNKNOWN;
>  	ndl->ndl_node->nd_timeout = 0;
>  	memset(&ndl->ndl_node->nd_ping, 0, sizeof(struct lstcon_rpc));
> @@ -1701,7 +1701,7 @@ lstcon_new_session_id(struct lst_sid *sid)
>  
>  	LNetGetId(1, &id);
>  	sid->ses_nid = id.nid;
> -	sid->ses_stamp = cfs_time_current();
> +	sid->ses_stamp = jiffies;
>  }
>  
>  int
> diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
> index 0ca1e3a780ca..045eecd23e0a 100644
> --- a/drivers/staging/lustre/lnet/selftest/framework.c
> +++ b/drivers/staging/lustre/lnet/selftest/framework.c
> @@ -272,7 +272,7 @@ sfw_init_session(struct sfw_session *sn, struct lst_sid sid,
>  	sn->sn_id = sid;
>  	sn->sn_features = features;
>  	sn->sn_timeout = session_timeout;
> -	sn->sn_started = cfs_time_current();
> +	sn->sn_started = jiffies;
>  
>  	timer->stt_data = sn;
>  	timer->stt_func = sfw_session_expired;
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index d35ae0cda8d2..f4824d8ec741 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -2255,7 +2255,7 @@ static inline int ptlrpc_send_limit_expired(struct ptlrpc_request *req)
>  	if (req->rq_delay_limit != 0 &&
>  	    time_before(cfs_time_add(req->rq_queued_time,
>  				     req->rq_delay_limit * HZ),
> -			cfs_time_current())) {
> +			jiffies)) {
>  		return 1;
>  	}
>  	return 0;
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> index f24dd74ffa09..7cfc3c8d100c 100644
> --- a/drivers/staging/lustre/lustre/include/obd_class.h
> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
> @@ -913,7 +913,7 @@ static inline int obd_destroy_export(struct obd_export *exp)
>  /*
>   * @max_age is the oldest time in jiffies that we accept using a cached data.
>   * If the cache is older than @max_age we will get a new value from the
> - * target.  Use a value of "cfs_time_current() + HZ" to guarantee freshness.
> + * target.  Use a value of "jiffies + HZ" to guarantee freshness.
>   */
>  static inline int obd_statfs_async(struct obd_export *exp,
>  				   struct obd_info *oinfo,
> @@ -975,7 +975,7 @@ static inline int obd_statfs_rqset(struct obd_export *exp,
>  /*
>   * @max_age is the oldest time in jiffies that we accept using a cached data.
>   * If the cache is older than @max_age we will get a new value from the
> - * target.  Use a value of "cfs_time_current() + HZ" to guarantee freshness.
> + * target.  Use a value of "jiffies + HZ" to guarantee freshness.
>   */
>  static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
>  			     struct obd_statfs *osfs, __u64 max_age,
> @@ -997,7 +997,7 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
>  		if (rc == 0) {
>  			spin_lock(&obd->obd_osfs_lock);
>  			memcpy(&obd->obd_osfs, osfs, sizeof(obd->obd_osfs));
> -			obd->obd_osfs_age = cfs_time_current_64();
> +			obd->obd_osfs_age = get_jiffies_64();
>  			spin_unlock(&obd->obd_osfs_lock);
>  		}
>  	} else {
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index 614caa4a9b0e..22c49cc593e3 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -243,7 +243,7 @@ static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
>  {
>  	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
>  
> -	lock->l_last_used = cfs_time_current();
> +	lock->l_last_used = jiffies;
>  	LASSERT(list_empty(&lock->l_lru));
>  	LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
>  	list_add_tail(&lock->l_lru, &ns->ns_unused_list);
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> index c772c68e5a49..ab4dd15c8dd4 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> @@ -325,7 +325,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
>  	lock_res_and_lock(lock);
>  	if (lock->l_granted_mode == LCK_PW &&
>  	    !lock->l_readers && !lock->l_writers &&
> -	    cfs_time_after(cfs_time_current(),
> +	    cfs_time_after(jiffies,
>  			   cfs_time_add(lock->l_last_used,
>  					10 * HZ))) {
>  		unlock_res_and_lock(lock);
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index 8e79f5e073ff..0e1b21c1f06d 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -116,7 +116,7 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, __u32 conn_cnt)
>  			   (s64)lock->l_last_activity,
>  			   (s64)(ktime_get_real_seconds() -
>  				 lock->l_last_activity));
> -		if (cfs_time_after(cfs_time_current(), next_dump)) {
> +		if (cfs_time_after(jiffies, next_dump)) {
>  			last_dump = next_dump;
>  			next_dump = cfs_time_shift(300);
>  			ldlm_namespace_dump(D_DLMTRACE,
> @@ -1161,7 +1161,7 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
>  						    int unused, int added,
>  						    int count)
>  {
> -	unsigned long cur = cfs_time_current();
> +	unsigned long cur = jiffies;
>  	struct ldlm_pool *pl = &ns->ns_pool;
>  	__u64 slv, lvf, lv;
>  	unsigned long la;
> @@ -1176,7 +1176,7 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
>  	 * Despite of the LV, It doesn't make sense to keep the lock which
>  	 * is unused for ns_max_age time.
>  	 */
> -	if (cfs_time_after(cfs_time_current(),
> +	if (cfs_time_after(jiffies,
>  			   cfs_time_add(lock->l_last_used, ns->ns_max_age)))
>  		return LDLM_POLICY_CANCEL_LOCK;
>  
> @@ -1233,7 +1233,7 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
>  						    int count)
>  {
>  	if ((added >= count) &&
> -	    time_before(cfs_time_current(),
> +	    time_before(jiffies,
>  			cfs_time_add(lock->l_last_used, ns->ns_max_age)))
>  		return LDLM_POLICY_KEEP_LOCK;
>  
> @@ -1380,7 +1380,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
>  				continue;
>  
>  			last_use = lock->l_last_used;
> -			if (last_use == cfs_time_current())
> +			if (last_use == jiffies)
>  				continue;
>  
>  			/* Somebody is already doing CANCEL. No need for this
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> index 8841a1bb2c0a..ccd0c082e39b 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> @@ -1316,7 +1316,7 @@ void ldlm_namespace_dump(int level, struct ldlm_namespace *ns)
>  	CDEBUG(level, "--- Namespace: %s (rc: %d, side: client)\n",
>  	       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
>  
> -	if (time_before(cfs_time_current(), ns->ns_next_dump))
> +	if (time_before(jiffies, ns->ns_next_dump))
>  		return;
>  
>  	cfs_hash_for_each_nolock(ns->ns_rs_hash,
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index d46bcf71b273..6504850e3689 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -1110,7 +1110,7 @@ static inline int ll_glimpse_size(struct inode *inode)
>  
>  	down_read(&lli->lli_glimpse_sem);
>  	rc = cl_glimpse_size(inode);
> -	lli->lli_glimpse_time = cfs_time_current();
> +	lli->lli_glimpse_time = jiffies;
>  	up_read(&lli->lli_glimpse_sem);
>  	return rc;
>  }
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index 155ce3cf6f60..6f996acf6aa8 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -535,7 +535,7 @@ static void ll_agl_trigger(struct inode *inode, struct ll_statahead_info *sai)
>  
>  	cl_agl(inode);
>  	lli->lli_agl_index = 0;
> -	lli->lli_glimpse_time = cfs_time_current();
> +	lli->lli_glimpse_time = jiffies;
>  	up_write(&lli->lli_glimpse_sem);
>  
>  	CDEBUG(D_READA, "Handled (init) async glimpse: inode= "
> diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
> index 051450d67524..41fc023cc381 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_request.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_request.c
> @@ -160,7 +160,7 @@ static int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
>  
>  		spin_lock(&obd->obd_osfs_lock);
>  		memcpy(&obd->obd_osfs, osfs, sizeof(*osfs));
> -		obd->obd_osfs_age = cfs_time_current_64();
> +		obd->obd_osfs_age = get_jiffies_64();
>  		spin_unlock(&obd->obd_osfs_lock);
>  		return 0;
>  	}
> @@ -277,7 +277,7 @@ static int cb_statfs_update(void *cookie, int rc)
>  	spin_lock(&tgtobd->obd_osfs_lock);
>  	memcpy(&tgtobd->obd_osfs, lov_sfs, sizeof(*lov_sfs));
>  	if ((oinfo->oi_flags & OBD_STATFS_FROM_CACHE) == 0)
> -		tgtobd->obd_osfs_age = cfs_time_current_64();
> +		tgtobd->obd_osfs_age = get_jiffies_64();
>  	spin_unlock(&tgtobd->obd_osfs_lock);
>  
>  out_update:
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 459503727ce3..ba4a4bf3b0f1 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -1290,7 +1290,7 @@ static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
>  
>  	result = cl_page_make_ready(env, page, CRT_WRITE);
>  	if (result == 0)
> -		opg->ops_submit_time = cfs_time_current();
> +		opg->ops_submit_time = jiffies;
>  	return result;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
> index 9582d5a642e2..c5dc894a4c1b 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_object.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_object.c
> @@ -300,7 +300,7 @@ static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
>  
>  void osc_object_set_contended(struct osc_object *obj)
>  {
> -	obj->oo_contention_time = cfs_time_current();
> +	obj->oo_contention_time = jiffies;
>  	/* mb(); */
>  	obj->oo_contended = 1;
>  }
> @@ -314,7 +314,7 @@ int osc_object_is_contended(struct osc_object *obj)
>  {
>  	struct osc_device *dev = lu2osc_dev(obj->oo_cl.co_lu.lo_dev);
>  	int osc_contention_time = dev->od_contention_time;
> -	unsigned long cur_time = cfs_time_current();
> +	unsigned long cur_time = jiffies;
>  	unsigned long retry_time;
>  
>  	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_OBJECT_CONTENTION))
> diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
> index 01a930dbbf64..20c553ef3a5e 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_page.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_page.c
> @@ -125,7 +125,7 @@ static inline unsigned long osc_submit_duration(struct osc_page *opg)
>  	if (opg->ops_submit_time == 0)
>  		return 0;
>  
> -	return (cfs_time_current() - opg->ops_submit_time);
> +	return (jiffies - opg->ops_submit_time);
>  }
>  
>  static int osc_page_print(const struct lu_env *env,
> @@ -312,7 +312,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
>  		oap->oap_cmd |= OBD_BRW_NOQUOTA;
>  	}
>  
> -	opg->ops_submit_time = cfs_time_current();
> +	opg->ops_submit_time = jiffies;
>  	osc_page_transfer_get(opg, "transfer\0imm");
>  	osc_page_transfer_add(env, opg, crt);
>  }
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> index 1c2bbbf5d864..9966fc7af789 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
> @@ -741,7 +741,7 @@ int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes)
>  
>  static int osc_should_shrink_grant(struct client_obd *client)
>  {
> -	unsigned long time = cfs_time_current();
> +	unsigned long time = jiffies;
>  	unsigned long next_shrink = client->cl_next_shrink_grant;
>  
>  	if ((client->cl_import->imp_connect_data.ocd_connect_flags &
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index ca096fadb9c0..eeb281266413 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -1050,7 +1050,7 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
>  	list_add_tail(&req->rq_set_chain, &set->set_requests);
>  	req->rq_set = set;
>  	atomic_inc(&set->set_remaining);
> -	req->rq_queued_time = cfs_time_current();
> +	req->rq_queued_time = jiffies;
>  
>  	if (req->rq_reqmsg)
>  		lustre_msg_set_jobid(req->rq_reqmsg, NULL);
> @@ -1081,7 +1081,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
>  	spin_lock(&set->set_new_req_lock);
>  	/* The set takes over the caller's request reference.  */
>  	req->rq_set = set;
> -	req->rq_queued_time = cfs_time_current();
> +	req->rq_queued_time = jiffies;
>  	list_add_tail(&req->rq_set_chain, &set->set_new_requests);
>  	count = atomic_inc_return(&set->set_new_count);
>  	spin_unlock(&set->set_new_req_lock);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index a2c4fc3488b1..4a9d1f189d01 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -508,7 +508,7 @@ static int import_select_connection(struct obd_import *imp)
>  		       imp->imp_obd->obd_name, at_get(at));
>  	}
>  
> -	imp_conn->oic_last_attempt = cfs_time_current_64();
> +	imp_conn->oic_last_attempt = get_jiffies_64();
>  
>  	/* switch connection, don't mind if it's same as the current one */
>  	ptlrpc_connection_put(imp->imp_connection);
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> index 0775b7a048bb..57c7db47e249 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> @@ -142,7 +142,7 @@ static long pinger_check_timeout(unsigned long time)
>  	mutex_unlock(&pinger_mutex);
>  
>  	return cfs_time_sub(cfs_time_add(time, timeout * HZ),
> -					 cfs_time_current());
> +					 jiffies);
>  }
>  
>  static bool ir_up;
> @@ -223,7 +223,7 @@ static DECLARE_DELAYED_WORK(ping_work, ptlrpc_pinger_main);
>  
>  static void ptlrpc_pinger_main(struct work_struct *ws)
>  {
> -	unsigned long this_ping = cfs_time_current();
> +	unsigned long this_ping = jiffies;
>  	long time_to_next_wake;
>  	struct timeout_item *item;
>  	struct obd_import *imp;
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index f37364e00dfe..fc29efbd9914 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -336,7 +336,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
>  	svcpt = from_timer(svcpt, t, scp_at_timer);
>  
>  	svcpt->scp_at_check = 1;
> -	svcpt->scp_at_checktime = cfs_time_current();
> +	svcpt->scp_at_checktime = jiffies;
>  	wake_up(&svcpt->scp_waitq);
>  }
>  
> @@ -1153,7 +1153,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
>  		spin_unlock(&svcpt->scp_at_lock);
>  		return;
>  	}
> -	delay = cfs_time_sub(cfs_time_current(), svcpt->scp_at_checktime);
> +	delay = cfs_time_sub(jiffies, svcpt->scp_at_checktime);
>  	svcpt->scp_at_check = 0;
>  
>  	if (array->paa_count == 0) {
> 
> 
> 
