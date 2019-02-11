From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 01:47:00 +0000 (GMT)
Subject: [lustre-devel] [PATCH 07/21] lustre: use list_first_entry() in
 lnet/klnds subdirectory.
In-Reply-To: <154949781297.10620.13452862524706335326.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781297.10620.13452862524706335326.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110146420.24975@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Convert
>   list_entry(foo->next .....)
> to
>   list_first_entry(foo, ....)
> 
> in 'lnet/klnds
> 
> In several cases the call is combined with a list_empty() test and
> list_first_entry_or_null() is used

tested on IB with no problems.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   19 +++--
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   61 ++++++++-------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    9 +-
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   79 ++++++++++----------
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    4 +
>  5 files changed, 88 insertions(+), 84 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index 74b21fe2c091..df6b1b134709 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1386,8 +1386,8 @@ static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
>  {
>  	struct kib_fmr_pool *fpo;
>  
> -	while (!list_empty(head)) {
> -		fpo = list_entry(head->next, struct kib_fmr_pool, fpo_list);
> +	while ((fpo = list_first_entry_or_null(head, struct kib_fmr_pool,
> +					       fpo_list)) != NULL) {
>  		list_del(&fpo->fpo_list);
>  		kiblnd_destroy_fmr_pool(fpo);
>  	}
> @@ -1544,14 +1544,16 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
>  static void kiblnd_fail_fmr_poolset(struct kib_fmr_poolset *fps,
>  				    struct list_head *zombies)
>  {
> +	struct kib_fmr_pool *fpo;
> +
>  	if (!fps->fps_net) /* initialized? */
>  		return;
>  
>  	spin_lock(&fps->fps_lock);
>  
> -	while (!list_empty(&fps->fps_pool_list)) {
> -		struct kib_fmr_pool *fpo = list_entry(fps->fps_pool_list.next,
> -						 struct kib_fmr_pool, fpo_list);
> +	while ((fpo = list_first_entry_or_null(&fps->fps_pool_list,
> +					       struct kib_fmr_pool,
> +					       fpo_list)) != NULL) {
>  		fpo->fpo_failed = 1;
>  		list_del(&fpo->fpo_list);
>  		if (!fpo->fpo_map_count)
> @@ -1853,8 +1855,9 @@ static void kiblnd_destroy_pool_list(struct list_head *head)
>  {
>  	struct kib_pool *pool;
>  
> -	while (!list_empty(head)) {
> -		pool = list_entry(head->next, struct kib_pool, po_list);
> +	while ((pool = list_first_entry_or_null(head,
> +						struct kib_pool,
> +						po_list)) != NULL) {
>  		list_del(&pool->po_list);
>  
>  		LASSERT(pool->po_owner);
> @@ -1869,7 +1872,7 @@ static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombie
>  
>  	spin_lock(&ps->ps_lock);
>  	while (!list_empty(&ps->ps_pool_list)) {
> -		struct kib_pool *po = list_entry(ps->ps_pool_list.next,
> +		struct kib_pool *po = list_first_entry(&ps->ps_pool_list,
>  					    struct kib_pool, po_list);
>  		po->po_failed = 1;
>  		list_del(&po->po_list);
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index ad1726098ea3..b9585f607463 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -98,9 +98,9 @@ kiblnd_txlist_done(struct list_head *txlist, int status)
>  {
>  	struct kib_tx *tx;
>  
> -	while (!list_empty(txlist)) {
> -		tx = list_entry(txlist->next, struct kib_tx, tx_list);
> -
> +	while ((tx = list_first_entry_or_null(txlist,
> +					      struct kib_tx,
> +					      tx_list)) != NULL) {
>  		list_del(&tx->tx_list);
>  		/* complete now */
>  		tx->tx_waiting = 0;
> @@ -958,9 +958,9 @@ kiblnd_check_sends_locked(struct kib_conn *conn)
>  	LASSERT(conn->ibc_reserved_credits >= 0);
>  
>  	while (conn->ibc_reserved_credits > 0 &&
> -	       !list_empty(&conn->ibc_tx_queue_rsrvd)) {
> -		tx = list_entry(conn->ibc_tx_queue_rsrvd.next,
> -				struct kib_tx, tx_list);
> +	       (tx = list_first_entry_or_null(
> +		       &conn->ibc_tx_queue_rsrvd,
> +		       struct kib_tx, tx_list)) != NULL) {
>  		list_del(&tx->tx_list);
>  		list_add_tail(&tx->tx_list, &conn->ibc_tx_queue);
>  		conn->ibc_reserved_credits--;
> @@ -983,17 +983,17 @@ kiblnd_check_sends_locked(struct kib_conn *conn)
>  
>  		if (!list_empty(&conn->ibc_tx_queue_nocred)) {
>  			credit = 0;
> -			tx = list_entry(conn->ibc_tx_queue_nocred.next,
> -					struct kib_tx, tx_list);
> +			tx = list_first_entry(&conn->ibc_tx_queue_nocred,
> +					      struct kib_tx, tx_list);
>  		} else if (!list_empty(&conn->ibc_tx_noops)) {
>  			LASSERT(!IBLND_OOB_CAPABLE(ver));
>  			credit = 1;
> -			tx = list_entry(conn->ibc_tx_noops.next,
> -					struct kib_tx, tx_list);
> +			tx = list_first_entry(&conn->ibc_tx_noops,
> +					      struct kib_tx, tx_list);
>  		} else if (!list_empty(&conn->ibc_tx_queue)) {
>  			credit = 1;
> -			tx = list_entry(conn->ibc_tx_queue.next,
> -					struct kib_tx, tx_list);
> +			tx = list_first_entry(&conn->ibc_tx_queue,
> +					      struct kib_tx, tx_list);
>  		} else {
>  			break;
>  		}
> @@ -2013,9 +2013,9 @@ kiblnd_handle_early_rxs(struct kib_conn *conn)
>  	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
>  
>  	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
> -	while (!list_empty(&conn->ibc_early_rxs)) {
> -		rx = list_entry(conn->ibc_early_rxs.next,
> -				struct kib_rx, rx_list);
> +	while ((rx = list_first_entry_or_null(&conn->ibc_early_rxs,
> +					      struct kib_rx,
> +					      rx_list)) != NULL) {
>  		list_del(&rx->rx_list);
>  		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
>  
> @@ -3311,8 +3311,9 @@ kiblnd_check_conns(int idx)
>  	 * NOOP, but there were no non-blocking tx descs
>  	 * free to do it last time...
>  	 */
> -	while (!list_empty(&checksends)) {
> -		conn = list_entry(checksends.next, struct kib_conn, ibc_connd_list);
> +	while ((conn = list_first_entry_or_null(&checksends,
> +						struct kib_conn,
> +						ibc_connd_list)) != NULL) {
>  		list_del(&conn->ibc_connd_list);
>  
>  		spin_lock(&conn->ibc_lock);
> @@ -3370,11 +3371,12 @@ kiblnd_connd(void *arg)
>  
>  		dropped_lock = 0;
>  
> -		if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
> +		conn = list_first_entry_or_null(
> +			&kiblnd_data.kib_connd_zombies,
> +			struct kib_conn, ibc_list);
> +		if (conn) {
>  			struct kib_peer_ni *peer_ni = NULL;
>  
> -			conn = list_entry(kiblnd_data.kib_connd_zombies.next,
> -					  struct kib_conn, ibc_list);
>  			list_del(&conn->ibc_list);
>  			if (conn->ibc_reconnect) {
>  				peer_ni = conn->ibc_peer;
> @@ -3401,9 +3403,9 @@ kiblnd_connd(void *arg)
>  					      &kiblnd_data.kib_reconn_wait);
>  		}
>  
> -		if (!list_empty(&kiblnd_data.kib_connd_conns)) {
> -			conn = list_entry(kiblnd_data.kib_connd_conns.next,
> -					  struct kib_conn, ibc_list);
> +		conn = list_first_entry_or_null(&kiblnd_data.kib_connd_conns,
> +						struct kib_conn, ibc_list);
> +		if (conn) {
>  			list_del(&conn->ibc_list);
>  
>  			spin_unlock_irqrestore(lock, flags);
> @@ -3423,11 +3425,11 @@ kiblnd_connd(void *arg)
>  						 &kiblnd_data.kib_reconn_list);
>  			}
>  
> -			if (list_empty(&kiblnd_data.kib_reconn_list))
> +			conn = list_first_entry_or_null(&kiblnd_data.kib_reconn_list,
> +							struct kib_conn, ibc_list);
> +			if (!conn)
>  				break;
>  
> -			conn = list_entry(kiblnd_data.kib_reconn_list.next,
> -					  struct kib_conn, ibc_list);
>  			list_del(&conn->ibc_list);
>  
>  			spin_unlock_irqrestore(lock, flags);
> @@ -3636,9 +3638,10 @@ kiblnd_scheduler(void *arg)
>  
>  		did_something = 0;
>  
> -		if (!list_empty(&sched->ibs_conns)) {
> -			conn = list_entry(sched->ibs_conns.next, struct kib_conn,
> -					  ibc_sched_list);
> +		conn = list_first_entry_or_null(&sched->ibs_conns,
> +						struct kib_conn,
> +						ibc_sched_list);
> +		if (conn) {
>  			/* take over kib_sched_conns' ref on conn... */
>  			LASSERT(conn->ibc_scheduled);
>  			list_del(&conn->ibc_sched_list);
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 785f76cf9067..08feaf7ce33a 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -1566,9 +1566,8 @@ ksocknal_finalize_zcreq(struct ksock_conn *conn)
>  
>  	spin_unlock(&peer_ni->ksnp_lock);
>  
> -	while (!list_empty(&zlist)) {
> -		tx = list_entry(zlist.next, struct ksock_tx, tx_zc_list);
> -
> +	while ((tx = list_first_entry_or_null(&zlist, struct ksock_tx,
> +					      tx_zc_list)) != NULL) {
>  		list_del(&tx->tx_zc_list);
>  		ksocknal_tx_decref(tx);
>  	}
> @@ -2267,8 +2266,8 @@ ksocknal_free_buffers(void)
>  		list_del_init(&ksocknal_data.ksnd_idle_noop_txs);
>  		spin_unlock(&ksocknal_data.ksnd_tx_lock);
>  
> -		while (!list_empty(&zlist)) {
> -			tx = list_entry(zlist.next, struct ksock_tx, tx_list);
> +		while ((tx = list_first_entry_or_null(&zlist, struct ksock_tx,
> +						      tx_list)) != NULL) {
>  			list_del(&tx->tx_list);
>  			kfree(tx);
>  		}
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index 8e20f430a3f3..208b8d360d5c 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -36,9 +36,9 @@ ksocknal_alloc_tx(int type, int size)
>  		/* searching for a noop tx in free list */
>  		spin_lock(&ksocknal_data.ksnd_tx_lock);
>  
> -		if (!list_empty(&ksocknal_data.ksnd_idle_noop_txs)) {
> -			tx = list_entry(ksocknal_data.ksnd_idle_noop_txs.next,
> -					struct ksock_tx, tx_list);
> +		tx = list_first_entry_or_null(&ksocknal_data.ksnd_idle_noop_txs,
> +					      struct ksock_tx, tx_list);
> +		if (tx) {
>  			LASSERT(tx->tx_desc_size == size);
>  			list_del(&tx->tx_list);
>  		}
> @@ -347,8 +347,8 @@ ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error)
>  {
>  	struct ksock_tx *tx;
>  
> -	while (!list_empty(txlist)) {
> -		tx = list_entry(txlist->next, struct ksock_tx, tx_list);
> +	while ((tx = list_first_entry_or_null(txlist, struct ksock_tx,
> +					      tx_list)) != NULL) {
>  
>  		if (error && tx->tx_lnetmsg) {
>  			CNETERR("Deleting packet type %d len %d %s->%s\n",
> @@ -1322,9 +1322,10 @@ int ksocknal_scheduler(void *arg)
>  
>  		/* Ensure I progress everything semi-fairly */
>  
> -		if (!list_empty(&sched->kss_rx_conns)) {
> -			conn = list_entry(sched->kss_rx_conns.next,
> -					  struct ksock_conn, ksnc_rx_list);
> +		conn = list_first_entry_or_null(&sched->kss_rx_conns,
> +						struct ksock_conn,
> +						ksnc_rx_list);
> +		if (conn) {
>  			list_del(&conn->ksnc_rx_list);
>  
>  			LASSERT(conn->ksnc_rx_scheduled);
> @@ -1378,16 +1379,17 @@ int ksocknal_scheduler(void *arg)
>  				list_del_init(&sched->kss_zombie_noop_txs);
>  			}
>  
> -			conn = list_entry(sched->kss_tx_conns.next,
> -					  struct ksock_conn, ksnc_tx_list);
> +			conn = list_first_entry(&sched->kss_tx_conns,
> +						struct ksock_conn,
> +						ksnc_tx_list);
>  			list_del(&conn->ksnc_tx_list);
>  
>  			LASSERT(conn->ksnc_tx_scheduled);
>  			LASSERT(conn->ksnc_tx_ready);
>  			LASSERT(!list_empty(&conn->ksnc_tx_queue));
>  
> -			tx = list_entry(conn->ksnc_tx_queue.next,
> -					struct ksock_tx, tx_list);
> +			tx = list_first_entry(&conn->ksnc_tx_queue,
> +					      struct ksock_tx, tx_list);
>  
>  			if (conn->ksnc_tx_carrier == tx)
>  				ksocknal_next_tx_carrier(conn);
> @@ -1900,8 +1902,8 @@ ksocknal_connect(struct ksock_route *route)
>  		 * connection for V1.x and V2.x
>  		 */
>  		if (!list_empty(&peer_ni->ksnp_conns)) {
> -			conn = list_entry(peer_ni->ksnp_conns.next,
> -					  struct ksock_conn, ksnc_list);
> +			conn = list_first_entry(&peer_ni->ksnp_conns,
> +						struct ksock_conn, ksnc_list);
>  			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
>  		}
>  
> @@ -2082,10 +2084,10 @@ ksocknal_connd(void *arg)
>  			dropped_lock = 1;
>  		}
>  
> -		if (!list_empty(&ksocknal_data.ksnd_connd_connreqs)) {
> +		cr = list_first_entry_or_null(&ksocknal_data.ksnd_connd_connreqs,
> +					      struct ksock_connreq, ksncr_list);
> +		if (cr) {
>  			/* Connection accepted by the listener */
> -			cr = list_entry(ksocknal_data.ksnd_connd_connreqs.next,
> -					struct ksock_connreq, ksncr_list);
>  
>  			list_del(&cr->ksncr_list);
>  			spin_unlock_bh(connd_lock);
> @@ -2246,9 +2248,9 @@ ksocknal_flush_stale_txs(struct ksock_peer *peer_ni)
>  
>  	write_lock_bh(&ksocknal_data.ksnd_global_lock);
>  
> -	while (!list_empty(&peer_ni->ksnp_tx_queue)) {
> -		tx = list_entry(peer_ni->ksnp_tx_queue.next, struct ksock_tx,
> -				tx_list);
> +	while ((tx = list_first_entry_or_null(&peer_ni->ksnp_tx_queue,
> +					      struct ksock_tx,
> +					      tx_list)) != NULL) {
>  
>  		if (ktime_get_seconds() < tx->tx_deadline)
>  			break;
> @@ -2372,19 +2374,16 @@ ksocknal_check_peer_timeouts(int idx)
>  		 * we can't process stale txs right here because we're
>  		 * holding only shared lock
>  		 */
> -		if (!list_empty(&peer_ni->ksnp_tx_queue)) {
> -			tx = list_entry(peer_ni->ksnp_tx_queue.next,
> -					struct ksock_tx, tx_list);
> -
> -			if (ktime_get_seconds() >= tx->tx_deadline) {
> -				ksocknal_peer_addref(peer_ni);
> -				read_unlock(&ksocknal_data.ksnd_global_lock);
> +		tx = list_first_entry_or_null(&peer_ni->ksnp_tx_queue,
> +					      struct ksock_tx, tx_list);
> +		if (tx && ktime_get_seconds() >= tx->tx_deadline) {
> +			ksocknal_peer_addref(peer_ni);
> +			read_unlock(&ksocknal_data.ksnd_global_lock);
>  
> -				ksocknal_flush_stale_txs(peer_ni);
> +			ksocknal_flush_stale_txs(peer_ni);
>  
> -				ksocknal_peer_decref(peer_ni);
> -				goto again;
> -			}
> +			ksocknal_peer_decref(peer_ni);
> +			goto again;
>  		}
>  
>  		if (list_empty(&peer_ni->ksnp_zc_req_list))
> @@ -2449,9 +2448,9 @@ ksocknal_reaper(void *arg)
>  	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
>  
>  	while (!ksocknal_data.ksnd_shuttingdown) {
> -		if (!list_empty(&ksocknal_data.ksnd_deathrow_conns)) {
> -			conn = list_entry(ksocknal_data.ksnd_deathrow_conns.next,
> -					  struct ksock_conn, ksnc_list);
> +		conn = list_first_entry_or_null(&ksocknal_data.ksnd_deathrow_conns,
> +						struct ksock_conn, ksnc_list);
> +		if (conn) {
>  			list_del(&conn->ksnc_list);
>  
>  			spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
> @@ -2463,9 +2462,9 @@ ksocknal_reaper(void *arg)
>  			continue;
>  		}
>  
> -		if (!list_empty(&ksocknal_data.ksnd_zombie_conns)) {
> -			conn = list_entry(ksocknal_data.ksnd_zombie_conns.next,
> -					  struct ksock_conn, ksnc_list);
> +		conn = list_first_entry_or_null(&ksocknal_data.ksnd_zombie_conns,
> +						struct ksock_conn, ksnc_list);
> +		if (conn) {
>  			list_del(&conn->ksnc_list);
>  
>  			spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
> @@ -2486,9 +2485,9 @@ ksocknal_reaper(void *arg)
>  
>  		/* reschedule all the connections that stalled with ENOMEM... */
>  		nenomem_conns = 0;
> -		while (!list_empty(&enomem_conns)) {
> -			conn = list_entry(enomem_conns.next, struct ksock_conn,
> -					  ksnc_tx_list);
> +		while ((conn = list_first_entry_or_null(&enomem_conns,
> +							struct ksock_conn,
> +							ksnc_tx_list)) != NULL) {
>  			list_del(&conn->ksnc_tx_list);
>  
>  			sched = conn->ksnc_scheduler;
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> index c694feceaaf2..e8b95affee96 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> @@ -447,8 +447,8 @@ ksocknal_handle_zcack(struct ksock_conn *conn, u64 cookie1, u64 cookie2)
>  
>  	spin_unlock(&peer_ni->ksnp_lock);
>  
> -	while (!list_empty(&zlist)) {
> -		tx = list_entry(zlist.next, struct ksock_tx, tx_zc_list);
> +	while ((tx = list_first_entry_or_null(&zlist, struct ksock_tx,
> +					      tx_zc_list)) != NULL) {
>  		list_del(&tx->tx_zc_list);
>  		ksocknal_tx_decref(tx);
>  	}
> 
> 
> 
