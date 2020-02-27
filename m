From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:28 -0500
Subject: [lustre-devel] [PATCH 340/622] lnet: Cleanup rcd
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-341-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Cleanup all code pertaining to rcd, as routing code will use
discovery going forward and there will be no need to keep its own
pinging code.

test_215 looks at the routers file which had its format changed.
Update the test to reflect the change.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11299
Lustre-commit: 9ee453928ab8 ("LU-11299 lnet: Cleanup rcd")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33187
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   4 -
 include/linux/lnet/lib-types.h |  40 +------
 net/lnet/lnet/api-ni.c         |  24 +++-
 net/lnet/lnet/lib-move.c       |  11 --
 net/lnet/lnet/router.c         | 255 -----------------------------------------
 net/lnet/lnet/router_proc.c    |  66 ++---------
 6 files changed, 31 insertions(+), 369 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 0007adf..8730670 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -748,11 +748,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 
 bool lnet_router_checker_active(void);
 void lnet_check_routers(void);
-int lnet_router_pre_mt_start(void);
 void lnet_router_post_mt_start(void);
-void lnet_prune_rc_data(int wait_unlink);
-void lnet_router_cleanup(void);
-void lnet_router_ni_update_locked(struct lnet_peer_ni *gw, u32 net);
 void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
 
 int lnet_ping_info_validate(struct lnet_ping_info *pinfo);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 9a09fad..495e805 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -509,20 +509,6 @@ struct lnet_ping_buffer {
 #define LNET_PING_INFO_TO_BUFFER(PINFO)	\
 	container_of((PINFO), struct lnet_ping_buffer, pb_info)
 
-/* router checker data, per router */
-struct lnet_rc_data {
-	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
-	struct list_head	rcd_list;
-	/* ping buffer MD */
-	struct lnet_handle_md	rcd_mdh;
-	/* reference to gateway */
-	struct lnet_peer_ni	*rcd_gateway;
-	/* ping buffer */
-	struct lnet_ping_buffer	*rcd_pingbuffer;
-	/* desired size of buffer */
-	int			rcd_nnis;
-};
-
 struct lnet_peer_ni {
 	/* chain on lpn_peer_nis */
 	struct list_head	 lpni_peer_nis;
@@ -553,22 +539,8 @@ struct lnet_peer_ni {
 	int			 lpni_rtrcredits;
 	/* low water mark */
 	int			 lpni_minrtrcredits;
-	/* notification outstanding? */
-	bool			 lpni_notify;
-	/* outstanding notification for LND? */
-	bool			 lpni_notifylnd;
-	/* some thread is handling notification */
-	bool			 lpni_notifying;
-	/* # times router went dead<->alive */
-	int			 lpni_alive_count;
-	/* ytes queued for sending */
+	/* bytes queued for sending */
 	long			 lpni_txqnob;
-	/* time of last aliveness news */
-	time64_t		 lpni_timestamp;
-	/* when I was last alive */
-	time64_t		 lpni_last_alive;
-	/* when lpni_ni was queried last time */
-	time64_t		 lpni_last_query;
 	/* network peer is on */
 	struct lnet_net		*lpni_net;
 	/* peer's NID */
@@ -598,8 +570,6 @@ struct lnet_peer_ni {
 	} lpni_pref;
 	/* number of preferred NIDs in lnpi_pref_nids */
 	u32			 lpni_pref_nnids;
-	/* router checker state */
-	struct lnet_rc_data	*lpni_rcd;
 };
 
 /* Preferred path added due to traffic on non-MR peer_ni */
@@ -823,8 +793,6 @@ struct lnet_route {
 	u32			lr_lnet;
 	/* sequence for round-robin */
 	int			lr_seq;
-	/* number of down NIs */
-	unsigned int		lr_downis;
 	/* how far I am */
 	u32			lr_hops;
 	/* route priority */
@@ -1115,12 +1083,6 @@ struct lnet {
 
 	/* monitor thread startup/shutdown state */
 	enum lnet_rc_state		ln_mt_state;
-	/* router checker's event queue */
-	struct lnet_handle_eq		ln_rc_eqh;
-	/* rcd still pending on net */
-	struct list_head		ln_rcd_deathrow;
-	/* rcd ready for free */
-	struct list_head		ln_rcd_zombie;
 	/* serialise startup/shutdown */
 	struct completion		ln_mt_signal;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d27e9a4..32b4b4f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1457,6 +1457,27 @@ struct lnet_ping_buffer *
 	return count;
 }
 
+void
+lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
+{
+	struct lnet_ni_status *stat;
+	int nnis;
+	int i;
+
+	__swab32s(&pbuf->pb_info.pi_magic);
+	__swab32s(&pbuf->pb_info.pi_features);
+	__swab32s(&pbuf->pb_info.pi_pid);
+	__swab32s(&pbuf->pb_info.pi_nnis);
+	nnis = pbuf->pb_info.pi_nnis;
+	if (nnis > pbuf->pb_nnis)
+		nnis = pbuf->pb_nnis;
+	for (i = 0; i < nnis; i++) {
+		stat = &pbuf->pb_info.pi_ni[i];
+		__swab64s(&stat->ns_nid);
+		__swab32s(&stat->ns_status);
+	}
+}
+
 int
 lnet_ping_info_validate(struct lnet_ping_info *pinfo)
 {
@@ -2362,12 +2383,9 @@ int lnet_lib_init(void)
 	}
 
 	the_lnet.ln_refcount = 0;
-	LNetInvalidateEQHandle(&the_lnet.ln_rc_eqh);
 	INIT_LIST_HEAD(&the_lnet.ln_lnds);
 	INIT_LIST_HEAD(&the_lnet.ln_net_zombie);
-	INIT_LIST_HEAD(&the_lnet.ln_rcd_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_msg_resend);
-	INIT_LIST_HEAD(&the_lnet.ln_rcd_deathrow);
 
 	/*
 	 * The hash table size is the number of bits it takes to express the set
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index af3cd1e..2e2299d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3151,9 +3151,6 @@ struct lnet_mt_event_info {
 						 false, HZ * interval);
 	}
 
-	/* clean up the router checker */
-	lnet_prune_rc_data(1);
-
 	/* Shutting down */
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
@@ -3364,11 +3361,6 @@ int lnet_monitor_thr_start(void)
 	if (rc)
 		goto clean_queues;
 
-	/* Pre monitor thread start processing */
-	rc = lnet_router_pre_mt_start();
-	if (rc)
-		goto free_mem;
-
 	init_completion(&the_lnet.ln_mt_signal);
 
 	lnet_net_lock(LNET_LOCK_EX);
@@ -3393,8 +3385,6 @@ int lnet_monitor_thr_start(void)
 	/* block until event callback signals exit */
 	wait_for_completion(&the_lnet.ln_mt_signal);
 	/* clean up */
-	lnet_router_cleanup();
-free_mem:
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_mt_state = LNET_MT_STATE_SHUTDOWN;
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -3430,7 +3420,6 @@ void lnet_monitor_thr_stop(void)
 	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN);
 
 	/* perform cleanup tasks */
-	lnet_router_cleanup();
 	lnet_rsp_tracker_clean();
 	lnet_clean_local_ni_recoveryq();
 	lnet_clean_peer_ni_recoveryq();
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index bb92759..1399545 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -220,101 +220,6 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	return route_alive;
 }
 
-void
-lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
-		   time64_t when)
-{
-	if (lp->lpni_timestamp > when) { /* out of date information */
-		CDEBUG(D_NET, "Out of date\n");
-		return;
-	}
-
-	/*
-	 * This function can be called with different cpt locks being
-	 * held. lpni_alive_count modification needs to be properly protected.
-	 * Significant reads to lpni_alive_count are also protected with
-	 * the same lock
-	 */
-	spin_lock(&lp->lpni_lock);
-
-	lp->lpni_timestamp = when;		/* update timestamp */
-
-	/* got old news */
-	if (lp->lpni_alive_count != 0 &&
-	    /* new date for old news */
-	    (!lnet_is_peer_ni_alive(lp)) == !alive) {
-		spin_unlock(&lp->lpni_lock);
-		CDEBUG(D_NET, "Old news\n");
-		return;
-	}
-
-	/* Flag that notification is outstanding */
-
-	lp->lpni_alive_count++;
-	lp->lpni_notify = 1;
-	lp->lpni_notifylnd = notifylnd;
-	if (lnet_is_peer_ni_alive(lp))
-		lp->lpni_ping_feats = LNET_PING_FEAT_INVAL; /* reset */
-
-	spin_unlock(&lp->lpni_lock);
-
-	CDEBUG(D_NET, "set %s %d\n", libcfs_nid2str(lp->lpni_nid), alive);
-}
-
-/*
- * This function will always be called with lp->lpni_cpt lock held.
- */
-static void
-lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
-{
-	int alive;
-	int notifylnd;
-
-	/*
-	 * Notify only in 1 thread at any time to ensure ordered notification.
-	 * NB individual events can be missed; the only guarantee is that you
-	 * always get the most recent news
-	 */
-	spin_lock(&lp->lpni_lock);
-
-	if (lp->lpni_notifying || !ni) {
-		spin_unlock(&lp->lpni_lock);
-		return;
-	}
-
-	lp->lpni_notifying = 1;
-
-	/*
-	 * lp->lpni_notify needs to be protected because it can be set in
-	 * lnet_notify_locked().
-	 */
-	while (lp->lpni_notify) {
-		alive = lnet_is_peer_ni_alive(lp);
-		notifylnd = lp->lpni_notifylnd;
-
-		lp->lpni_notifylnd = 0;
-		lp->lpni_notify = 0;
-
-		if (notifylnd && ni->ni_net->net_lnd->lnd_notify) {
-			spin_unlock(&lp->lpni_lock);
-			lnet_net_unlock(lp->lpni_cpt);
-
-			/*
-			 * A new notification could happen now; I'll handle it
-			 * when control returns to me
-			 */
-			ni->ni_net->net_lnd->lnd_notify(ni, lp->lpni_nid,
-							alive);
-
-			lnet_net_lock(lp->lpni_cpt);
-			spin_lock(&lp->lpni_lock);
-		}
-	}
-
-	lp->lpni_notifying = 0;
-	spin_unlock(&lp->lpni_lock);
-}
-
 static void
 lnet_rtr_addref_locked(struct lnet_peer *lp)
 {
@@ -721,93 +626,6 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	return -ENOENT;
 }
 
-void
-lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
-{
-	struct lnet_ni_status *stat;
-	int nnis;
-	int i;
-
-	__swab32s(&pbuf->pb_info.pi_magic);
-	__swab32s(&pbuf->pb_info.pi_features);
-	__swab32s(&pbuf->pb_info.pi_pid);
-	__swab32s(&pbuf->pb_info.pi_nnis);
-	nnis = pbuf->pb_info.pi_nnis;
-	if (nnis > pbuf->pb_nnis)
-		nnis = pbuf->pb_nnis;
-	for (i = 0; i < nnis; i++) {
-		stat = &pbuf->pb_info.pi_ni[i];
-		__swab64s(&stat->ns_nid);
-		__swab32s(&stat->ns_status);
-	}
-}
-
-/**
- * TODO: re-implement
- */
-static void
-lnet_parse_rc_info(struct lnet_rc_data *rcd)
-{
-	rcd = rcd;
-}
-
-static void
-lnet_router_checker_event(struct lnet_event *event)
-{
-	struct lnet_rc_data *rcd = event->md.user_ptr;
-	struct lnet_peer_ni *lp;
-
-	LASSERT(rcd);
-
-	if (event->unlinked) {
-		LNetInvalidateMDHandle(&rcd->rcd_mdh);
-		return;
-	}
-
-	LASSERT(event->type == LNET_EVENT_SEND ||
-		event->type == LNET_EVENT_REPLY);
-
-	lp = rcd->rcd_gateway;
-	LASSERT(lp);
-
-	/*
-	 * NB: it's called with holding lnet_res_lock, we have a few
-	 * places need to hold both locks at the same time, please take
-	 * care of lock ordering
-	 */
-	lnet_net_lock(lp->lpni_cpt);
-	if (!lnet_isrouter(lp) || lp->lpni_rcd != rcd) {
-		/* ignore if no longer a router or rcd is replaced */
-		goto out;
-	}
-
-	if (event->type == LNET_EVENT_SEND) {
-		if (!event->status)
-			goto out;
-	}
-
-	/* LNET_EVENT_REPLY */
-	/*
-	 * A successful REPLY means the router is up.  If _any_ comms
-	 * to the router fail I assume it's down (this will happen if
-	 * we ping alive routers to try to detect router death before
-	 * apps get burned).
-	 */
-	lnet_notify_locked(lp, 1, !event->status, ktime_get_seconds());
-
-	/*
-	 * The router checker will wake up very shortly and do the
-	 * actual notification.
-	 * XXX If 'lp' stops being a router before then, it will still
-	 * have the notification pending!!!
-	 */
-	if (avoid_asym_router_failure && !event->status)
-		lnet_parse_rc_info(rcd);
-
-out:
-	lnet_net_unlock(lp->lpni_cpt);
-}
-
 static void
 lnet_wait_known_routerstate(void)
 {
@@ -840,26 +658,6 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
-/* TODO: reimplement */
-void
-lnet_router_ni_update_locked(struct lnet_peer_ni *gw, u32 net)
-{
-	struct lnet_route *rte;
-	struct lnet_peer *lp;
-
-	if ((gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS))
-		lp = gw->lpni_peer_net->lpn_peer;
-	else
-		return;
-
-	list_for_each_entry(rte, &lp->lp_routes, lr_gwlist) {
-		if (rte->lr_net == net) {
-			rte->lr_downis = 0;
-			break;
-		}
-	}
-}
-
 static void
 lnet_update_ni_status_locked(void)
 {
@@ -902,25 +700,6 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
-int lnet_router_pre_mt_start(void)
-{
-	int rc;
-
-	if (check_routers_before_use &&
-	    dead_router_check_interval <= 0) {
-		LCONSOLE_ERROR_MSG(0x10a, "'dead_router_check_interval' must be set if 'check_routers_before_use' is set\n");
-		return -EINVAL;
-	}
-
-	rc = LNetEQAlloc(0, lnet_router_checker_event, &the_lnet.ln_rc_eqh);
-	if (rc) {
-		CERROR("Can't allocate EQ(0): %d\n", rc);
-		return -ENOMEM;
-	}
-
-	return 0;
-}
-
 void lnet_router_post_mt_start(void)
 {
 	if (check_routers_before_use) {
@@ -933,19 +712,6 @@ void lnet_router_post_mt_start(void)
 	}
 }
 
-void lnet_router_cleanup(void)
-{
-	int rc;
-
-	rc = LNetEQFree(the_lnet.ln_rc_eqh);
-	LASSERT(rc == 0);
-}
-
-void lnet_prune_rc_data(int wait_unlink)
-{
-	wait_unlink = wait_unlink;
-}
-
 /*
  * This function is called from the monitor thread to check if there are
  * any active routers that need to be checked.
@@ -962,11 +728,6 @@ bool lnet_router_checker_active(void)
 	if (the_lnet.ln_routing)
 		return true;
 
-	/* if there are routers that need to be cleaned up then do so */
-	if (!list_empty(&the_lnet.ln_rcd_deathrow) ||
-	    !list_empty(&the_lnet.ln_rcd_zombie))
-		return true;
-
 	return !list_empty(&the_lnet.ln_routers) &&
 		(live_router_check_interval > 0 ||
 		 dead_router_check_interval > 0);
@@ -997,8 +758,6 @@ bool lnet_router_checker_active(void)
 		lnet_update_ni_status_locked();
 
 	lnet_net_unlock(cpt);
-
-	lnet_prune_rc_data(0); /* don't wait for UNLINK */
 }
 
 void
@@ -1503,20 +1262,6 @@ bool lnet_router_checker_active(void)
 		lnet_net_lock(cpt);
 	}
 
-	/*
-	 * We can't fully trust LND on reporting exact peer last_alive
-	 * if he notifies us about dead peer. For example ksocklnd can
-	 * call us with when == _time_when_the_node_was_booted_ if
-	 * no connections were successfully established
-	 */
-	if (ni && !alive && when < lp->lpni_last_alive)
-		when = lp->lpni_last_alive;
-
-	lnet_notify_locked(lp, !ni, alive, when);
-
-	if (ni)
-		lnet_ni_notify_locked(ni, lp);
-
 	lnet_peer_ni_decref_locked(lp);
 
 	lnet_net_unlock(cpt);
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 3120533..e494d19 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -215,7 +215,6 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			u32 net = rnet->lrn_net;
 			u32 hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
-			lnet_nid_t nid = route->lr_gateway->lp_primary_nid;
 			int alive = lnet_is_route_alive(route);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
@@ -223,7 +222,8 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 				      libcfs_net2str(net), hops,
 				      priority,
 				      alive ? "up" : "down",
-				      libcfs_nid2str(nid));
+				      /* TODO: replace with actual nid */
+				      libcfs_nid2str(LNET_NID_ANY));
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
 
@@ -278,10 +278,8 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 	if (!*ppos) {
 		s += snprintf(s, tmpstr + tmpsiz - s,
-			      "%-4s %7s %9s %6s %12s %9s %8s %7s %s\n",
-			      "ref", "rtr_ref", "alive_cnt", "state",
-			      "last_ping", "ping_sent", "deadline",
-			      "down_ni", "router");
+			      "%-4s %7s %5s %s\n",
+			      "ref", "rtr_ref", "alive", "router");
 		LASSERT(tmpstr + tmpsiz - s > 0);
 
 		lnet_net_lock(0);
@@ -319,48 +317,15 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 		if (peer) {
 			lnet_nid_t nid = peer->lp_primary_nid;
-			time64_t now = ktime_get_seconds();
-			/* TODO: readjust what's being printed */
-			time64_t deadline = 0;
 			int nrefs = atomic_read(&peer->lp_refcount);
 			int nrtrrefs = peer->lp_rtr_refcount;
-			int alive_cnt = 0;
 			int alive = lnet_is_gateway_alive(peer);
-			int pingsent = ((peer->lp_state & LNET_PEER_PING_SENT)
-				       != 0);
-			time64_t last_ping = now - peer->lp_rtrcheck_timestamp;
-			int down_ni = 0;
-			struct lnet_route *rtr;
-
-			if (nrtrrefs > 0) {
-				list_for_each_entry(rtr, &peer->lp_routes,
-						    lr_gwlist) {
-					/*
-					 * downis on any route should be the
-					 * number of downis on the gateway
-					 */
-					if (rtr->lr_downis) {
-						down_ni = rtr->lr_downis;
-						break;
-					}
-				}
-			}
 
-			if (!deadline)
-				s += snprintf(s, tmpstr + tmpsiz - s,
-					      "%-4d %7d %9d %6s %12llu %9d %8s %7d %s\n",
-					      nrefs, nrtrrefs, alive_cnt,
-					      alive ? "up" : "down", last_ping,
-					      pingsent, "NA", down_ni,
-					      libcfs_nid2str(nid));
-			else
-				s += snprintf(s, tmpstr + tmpsiz - s,
-					      "%-4d %7d %9d %6s %12llu %9d %8llu %7d %s\n",
-					      nrefs, nrtrrefs, alive_cnt,
-					      alive ? "up" : "down", last_ping,
-					      pingsent, deadline - now,
-					      down_ni, libcfs_nid2str(nid));
-			LASSERT(tmpstr + tmpsiz - s > 0);
+			s += snprintf(s, tmpstr + tmpsiz - s,
+				      "%-4d %7d %5s %s\n",
+				      nrefs, nrtrrefs,
+				      alive ? "up" : "down",
+				      libcfs_nid2str(nid));
 		}
 
 		lnet_net_unlock(0);
@@ -532,19 +497,6 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				aliveness = lnet_is_peer_ni_alive(peer) ?
 					"up" : "down";
 
-			if (lnet_peer_aliveness_enabled(peer)) {
-				time64_t now = ktime_get_seconds();
-
-				lastalive = now - peer->lpni_last_alive;
-
-				/* No need to mess up peers contents with
-				 * arbitrarily long integers - it suffices to
-				 * know that lastalive is more than 10000s old
-				 */
-				if (lastalive >= 10000)
-					lastalive = 9999;
-			}
-
 			lnet_net_unlock(cpt);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
-- 
1.8.3.1
