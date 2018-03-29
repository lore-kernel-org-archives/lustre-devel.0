From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 12/17] staging: lustre: libcfs: discard
 cfs_time_after()
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760869.27689.11709556301389676244.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

cfs_time_after() behaves exactly like time_after()
similarly cfs_time_aftereq() matches time_after_eq()

so discard the cfs versions.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_time.h      |   14 ---------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   32 ++++++++++----------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |    8 +++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 +--
 drivers/staging/lustre/lnet/lnet/net_fault.c       |    8 +++--
 drivers/staging/lustre/lnet/lnet/router.c          |    6 ++--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 +--
 drivers/staging/lustre/lnet/selftest/timer.c       |    2 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    4 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    4 +--
 drivers/staging/lustre/lustre/osc/osc_object.c     |    2 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    6 ++--
 16 files changed, 47 insertions(+), 61 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
index 0ebbde4ec8e8..172a8872e3f3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
@@ -36,20 +36,6 @@
 
 #ifndef __LIBCFS_TIME_H__
 #define __LIBCFS_TIME_H__
-/*
- * generic time manipulation functions.
- */
-
-static inline int cfs_time_after(unsigned long t1, unsigned long t2)
-{
-	return time_before(t2, t1);
-}
-
-static inline int cfs_time_aftereq(unsigned long t1, unsigned long t2)
-{
-	return time_before_eq(t2, t1);
-}
-
 /*
  * return valid time-out based on user supplied one. Currently we only check
  * that time-out is not shorted than allowed.
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 276bf486f64b..d0ce37d72571 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1522,7 +1522,7 @@ static int kiblnd_fmr_pool_is_idle(struct kib_fmr_pool *fpo, unsigned long now)
 		return 0;
 	if (fpo->fpo_failed)
 		return 1;
-	return cfs_time_aftereq(now, fpo->fpo_deadline);
+	return time_after_eq(now, fpo->fpo_deadline);
 }
 
 static int
@@ -1850,7 +1850,7 @@ static int kiblnd_pool_is_idle(struct kib_pool *pool, unsigned long now)
 		return 0;
 	if (pool->po_failed)
 		return 1;
-	return cfs_time_aftereq(now, pool->po_deadline);
+	return time_after_eq(now, pool->po_deadline);
 }
 
 void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node)
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index b18911d09e9a..ca6e09de0872 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -754,9 +754,9 @@ static inline int
 kiblnd_send_keepalive(struct kib_conn *conn)
 {
 	return (*kiblnd_tunables.kib_keepalive > 0) &&
-		cfs_time_after(jiffies, conn->ibc_last_send +
-			       msecs_to_jiffies(*kiblnd_tunables.kib_keepalive *
-						MSEC_PER_SEC));
+		time_after(jiffies, conn->ibc_last_send +
+			   msecs_to_jiffies(*kiblnd_tunables.kib_keepalive *
+					    MSEC_PER_SEC));
 }
 
 static inline int
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index f9761d8f2e3e..563ff5c972bf 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3141,7 +3141,7 @@ kiblnd_check_txs_locked(struct kib_conn *conn, struct list_head *txs)
 			LASSERT(tx->tx_waiting || tx->tx_sending);
 		}
 
-		if (cfs_time_aftereq(jiffies, tx->tx_deadline)) {
+		if (time_after_eq(jiffies, tx->tx_deadline)) {
 			CERROR("Timed out tx: %s, %lu seconds\n",
 			       kiblnd_queue2str(conn, txs),
 			       cfs_duration_sec(jiffies - tx->tx_deadline));
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 1ace54c9b133..8ead1e02e854 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -481,7 +481,7 @@ ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 		LASSERT(conn->ksnc_tx_scheduled);
 		list_add_tail(&conn->ksnc_tx_list,
 			      &ksocknal_data.ksnd_enomem_conns);
-		if (!cfs_time_aftereq(jiffies + SOCKNAL_ENOMEM_RETRY,
+		if (!time_after_eq(jiffies + SOCKNAL_ENOMEM_RETRY,
 				   ksocknal_data.ksnd_reaper_waketime))
 			wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
@@ -590,7 +590,7 @@ ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
 		case SOCKNAL_MATCH_YES: /* typed connection */
 			if (!typed || tnob > nob ||
 			    (tnob == nob && *ksocknal_tunables.ksnd_round_robin &&
-			     cfs_time_after(typed->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
+			     time_after(typed->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
 				typed = c;
 				tnob  = nob;
 			}
@@ -599,7 +599,7 @@ ksocknal_find_conn_locked(struct ksock_peer *peer, struct ksock_tx *tx,
 		case SOCKNAL_MATCH_MAY: /* fallback connection */
 			if (!fallback || fnob > nob ||
 			    (fnob == nob && *ksocknal_tunables.ksnd_round_robin &&
-			     cfs_time_after(fallback->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
+			     time_after(fallback->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
 				fallback = c;
 				fnob = nob;
 			}
@@ -745,7 +745,7 @@ ksocknal_find_connectable_route_locked(struct ksock_peer *peer)
 			continue;
 
 		if (!(!route->ksnr_retry_interval || /* first attempt */
-		      cfs_time_aftereq(now, route->ksnr_timeout))) {
+		      time_after_eq(now, route->ksnr_timeout))) {
 			CDEBUG(D_NET,
 			       "Too soon to retry route %pI4h (cnted %d, interval %ld, %ld secs later)\n",
 			       &route->ksnr_ipaddr,
@@ -1823,7 +1823,7 @@ ksocknal_connect(struct ksock_route *route)
 
 		write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-		if (cfs_time_aftereq(jiffies, deadline)) {
+		if (time_after_eq(jiffies, deadline)) {
 			rc = -ETIMEDOUT;
 			lnet_connect_console_error(rc, peer->ksnp_id.nid,
 						   route->ksnr_ipaddr,
@@ -2052,7 +2052,7 @@ ksocknal_connd_get_route_locked(signed long *timeout_p)
 	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
 			    ksnr_connd_list) {
 		if (!route->ksnr_retry_interval ||
-		    cfs_time_aftereq(now, route->ksnr_timeout))
+		    time_after_eq(now, route->ksnr_timeout))
 			return route;
 
 		if (*timeout_p == MAX_SCHEDULE_TIMEOUT ||
@@ -2224,8 +2224,8 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 		}
 
 		if (conn->ksnc_rx_started &&
-		    cfs_time_aftereq(jiffies,
-				     conn->ksnc_rx_deadline)) {
+		    time_after_eq(jiffies,
+				  conn->ksnc_rx_deadline)) {
 			/* Timed out incomplete incoming message */
 			ksocknal_conn_addref(conn);
 			CNETERR("Timeout receiving from %s (%pI4h:%d), state %d wanted %zd left %d\n",
@@ -2240,8 +2240,8 @@ ksocknal_find_timed_out_conn(struct ksock_peer *peer)
 
 		if ((!list_empty(&conn->ksnc_tx_queue) ||
 		     conn->ksnc_sock->sk->sk_wmem_queued) &&
-		    cfs_time_aftereq(jiffies,
-				     conn->ksnc_tx_deadline)) {
+		    time_after_eq(jiffies,
+				  conn->ksnc_tx_deadline)) {
 			/*
 			 * Timed out messages queued for sending or
 			 * buffered in the socket's send buffer
@@ -2268,8 +2268,8 @@ ksocknal_flush_stale_txs(struct ksock_peer *peer)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	list_for_each_entry_safe(tx, tmp, &peer->ksnp_tx_queue, tx_list) {
-		if (!cfs_time_aftereq(jiffies,
-				      tx->tx_deadline))
+		if (!time_after_eq(jiffies,
+				   tx->tx_deadline))
 			break;
 
 		list_del(&tx->tx_list);
@@ -2395,8 +2395,8 @@ ksocknal_check_peer_timeouts(int idx)
 			tx = list_entry(peer->ksnp_tx_queue.next,
 					struct ksock_tx, tx_list);
 
-			if (cfs_time_aftereq(jiffies,
-					     tx->tx_deadline)) {
+			if (time_after_eq(jiffies,
+					  tx->tx_deadline)) {
 				ksocknal_peer_addref(peer);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
 
@@ -2413,8 +2413,8 @@ ksocknal_check_peer_timeouts(int idx)
 		tx_stale = NULL;
 		spin_lock(&peer->ksnp_lock);
 		list_for_each_entry(tx, &peer->ksnp_zc_req_list, tx_zc_list) {
-			if (!cfs_time_aftereq(jiffies,
-					      tx->tx_deadline))
+			if (!time_after_eq(jiffies,
+					   tx->tx_deadline))
 				break;
 			/* ignore the TX if connection is being closed */
 			if (tx->tx_conn->ksnc_closing)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 2aeae0331ee0..129430e74d00 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -431,7 +431,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	if (cdls) {
 		if (libcfs_console_ratelimit &&
 		    cdls->cdls_next &&		/* not first time ever */
-		    !cfs_time_after(jiffies, cdls->cdls_next)) {
+		    !time_after(jiffies, cdls->cdls_next)) {
 			/* skipping a console message */
 			cdls->cdls_count++;
 			if (tcd)
@@ -439,9 +439,9 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 			return 1;
 		}
 
-		if (cfs_time_after(jiffies,
-				   cdls->cdls_next + libcfs_console_max_delay +
-				   10 * HZ)) {
+		if (time_after(jiffies,
+			       cdls->cdls_next + libcfs_console_max_delay +
+			       10 * HZ)) {
 			/* last timeout was a long time ago */
 			cdls->cdls_delay /= libcfs_console_backoff * 4;
 		} else {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5574d2148c9d..60464135161b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -520,11 +520,11 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 	 * ignore the initial assumed death (see lnet_peers_start_down()).
 	 */
 	if (!lp->lp_alive && lp->lp_alive_count > 0 &&
-	    cfs_time_aftereq(lp->lp_timestamp, lp->lp_last_alive))
+	    time_after_eq(lp->lp_timestamp, lp->lp_last_alive))
 		return 0;
 
 	deadline = lp->lp_last_alive + lp->lp_ni->ni_peertimeout * HZ;
-	alive = cfs_time_after(deadline, now);
+	alive = time_after(deadline, now);
 
 	/* Update obsolete lp_alive except for routers assumed to be dead
 	 * initially, because router checker would update aliveness in this
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 05d7b754815a..0066394b0bb0 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -309,9 +309,9 @@ drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
 		unsigned long now = jiffies;
 
 		rule->dr_stat.fs_count++;
-		drop = cfs_time_aftereq(now, rule->dr_drop_time);
+		drop = time_after_eq(now, rule->dr_drop_time);
 		if (drop) {
-			if (cfs_time_after(now, rule->dr_time_base))
+			if (time_after(now, rule->dr_time_base))
 				rule->dr_time_base = now;
 
 			rule->dr_drop_time = rule->dr_time_base +
@@ -475,9 +475,9 @@ delay_rule_match(struct lnet_delay_rule *rule, lnet_nid_t src,
 		unsigned long now = jiffies;
 
 		rule->dl_stat.fs_count++;
-		delay = cfs_time_aftereq(now, rule->dl_delay_time);
+		delay = time_after_eq(now, rule->dl_delay_time);
 		if (delay) {
-			if (cfs_time_after(now, rule->dl_time_base))
+			if (time_after(now, rule->dl_time_base))
 				rule->dl_time_base = now;
 
 			rule->dl_delay_time = rule->dl_time_base +
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index c72d4f4454ec..8baf35d56ca7 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -982,7 +982,7 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
 	lnet_peer_addref_locked(rtr);
 
 	if (rtr->lp_ping_deadline && /* ping timed out? */
-	    cfs_time_after(now, rtr->lp_ping_deadline))
+	    time_after(now, rtr->lp_ping_deadline))
 		lnet_notify_locked(rtr, 1, 0, now);
 
 	/* Run any outstanding notifications */
@@ -1010,7 +1010,7 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
 	       rtr->lp_alive, rtr->lp_alive_count, rtr->lp_ping_timestamp);
 
 	if (secs && !rtr->lp_ping_notsent &&
-	    cfs_time_after(now, rtr->lp_ping_timestamp + secs * HZ)) {
+	    time_after(now, rtr->lp_ping_timestamp + secs * HZ)) {
 		int rc;
 		struct lnet_process_id id;
 		struct lnet_handle_md mdh;
@@ -1748,7 +1748,7 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, unsigned long when)
 	}
 
 	/* can't do predictions... */
-	if (cfs_time_after(when, now)) {
+	if (time_after(when, now)) {
 		CWARN("Ignoring prediction from %s of %s %s %ld seconds in the future\n",
 		      !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
 		      libcfs_nid2str(nid), alive ? "up" : "down",
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index ea4944b9108b..8c237758c3eb 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -315,7 +315,7 @@ lstcon_rpc_trans_abort(struct lstcon_rpc_trans *trans, int error)
 			continue;
 
 		nd = crpc->crp_node;
-		if (cfs_time_after(nd->nd_stamp, crpc->crp_stamp))
+		if (time_after(nd->nd_stamp, crpc->crp_stamp))
 			continue;
 
 		nd->nd_stamp = crpc->crp_stamp;
@@ -404,7 +404,7 @@ lstcon_rpc_get_reply(struct lstcon_rpc *crpc, struct srpc_msg **msgpp)
 		crpc->crp_unpacked = 1;
 	}
 
-	if (cfs_time_after(nd->nd_stamp, crpc->crp_stamp))
+	if (time_after(nd->nd_stamp, crpc->crp_stamp))
 		return 0;
 
 	nd->nd_stamp = crpc->crp_stamp;
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index 1f9d5487e2f5..582f252b3e12 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -155,7 +155,7 @@ stt_check_timers(unsigned long *last)
 
 	spin_lock(&stt_data.stt_lock);
 
-	while (cfs_time_aftereq(this_slot, *last)) {
+	while (time_after_eq(this_slot, *last)) {
 		expired += stt_expire_list(STTIMER_SLOT(this_slot), now);
 		this_slot = this_slot - STTIMER_SLOTTIME;
 	}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 150e78c9eb68..942d34f7a44c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -325,8 +325,8 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 	lock_res_and_lock(lock);
 	if (lock->l_granted_mode == LCK_PW &&
 	    !lock->l_readers && !lock->l_writers &&
-	    cfs_time_after(jiffies,
-			   lock->l_last_used + 10 * HZ)) {
+	    time_after(jiffies,
+		       lock->l_last_used + 10 * HZ)) {
 		unlock_res_and_lock(lock);
 		if (ldlm_bl_to_thread_lock(ns, NULL, lock))
 			ldlm_handle_bl_callback(ns, NULL, lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 647e85b16c02..187095022fb1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -116,7 +116,7 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, __u32 conn_cnt)
 			   (s64)lock->l_last_activity,
 			   (s64)(ktime_get_real_seconds() -
 				 lock->l_last_activity));
-		if (cfs_time_after(jiffies, next_dump)) {
+		if (time_after(jiffies, next_dump)) {
 			last_dump = next_dump;
 			next_dump = jiffies + 300 * HZ;
 			ldlm_namespace_dump(D_DLMTRACE,
@@ -1176,7 +1176,7 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	 * Despite of the LV, It doesn't make sense to keep the lock which
 	 * is unused for ns_max_age time.
 	 */
-	if (cfs_time_after(jiffies, lock->l_last_used + ns->ns_max_age))
+	if (time_after(jiffies, lock->l_last_used + ns->ns_max_age))
 		return LDLM_POLICY_CANCEL_LOCK;
 
 	slv = ldlm_pool_get_slv(pl);
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 154d1721636e..84240181c7ea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -328,7 +328,7 @@ int osc_object_is_contended(struct osc_object *obj)
 	 * ll_file_is_contended.
 	 */
 	retry_time = obj->oo_contention_time + osc_contention_time * HZ;
-	if (cfs_time_after(cur_time, retry_time)) {
+	if (time_after(cur_time, retry_time)) {
 		osc_object_clear_contended(obj);
 		return 0;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 04d801f11ace..0038e555e905 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -748,7 +748,7 @@ static int osc_should_shrink_grant(struct client_obd *client)
 	     OBD_CONNECT_GRANT_SHRINK) == 0)
 		return 0;
 
-	if (cfs_time_aftereq(time, next_shrink - 5 * CFS_TICK)) {
+	if (time_after_eq(time, next_shrink - 5 * CFS_TICK)) {
 		/* Get the current RPC size directly, instead of going via:
 		 * cli_brw_size(obd->u.cli.cl_import->imp_obd->obd_self_export)
 		 * Keep comment here so that it can be found by searching.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 7057b4447035..3f17c673d1b8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -180,7 +180,7 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 	imp->imp_force_verify = 0;
 
-	if (cfs_time_aftereq(imp->imp_next_ping - 5 * CFS_TICK, this_ping) &&
+	if (time_after_eq(imp->imp_next_ping - 5 * CFS_TICK, this_ping) &&
 	    !force) {
 		spin_unlock(&imp->imp_lock);
 		return;
@@ -236,8 +236,8 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 			ptlrpc_pinger_process_import(imp, this_ping);
 			/* obd_timeout might have changed */
 			if (imp->imp_pingable && imp->imp_next_ping &&
-			    cfs_time_after(imp->imp_next_ping,
-					   this_ping + PING_INTERVAL * HZ))
+			    time_after(imp->imp_next_ping,
+				       this_ping + PING_INTERVAL * HZ))
 				ptlrpc_update_next_ping(imp, 0);
 		}
 		mutex_unlock(&pinger_mutex);
