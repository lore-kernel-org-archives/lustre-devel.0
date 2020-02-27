From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:30 -0500
Subject: [lustre-devel] [PATCH 342/622] lnet: use discovery for routing
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-343-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Instead of re-inventing the wheel, routing now uses discovery.
Every router interval the router is discovered. This will
update the router information locally and will serve to let the
router know that the peer is alive.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11299
Lustre-commit: 146580754295 ("LU-11299 lnet: use discovery for routing")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33454
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   9 ++-
 include/linux/lnet/lib-types.h |   5 ++
 net/lnet/lnet/api-ni.c         |  19 +++---
 net/lnet/lnet/lib-move.c       |  10 ++-
 net/lnet/lnet/peer.c           |  41 ++++++++++++-
 net/lnet/lnet/router.c         | 134 +++++++++++++++++++++++++++++++++++------
 net/lnet/lnet/router_proc.c    |   3 +-
 7 files changed, 186 insertions(+), 35 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 94918d3..1d06263 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -499,6 +499,7 @@ struct lnet_ni *
 extern unsigned int lnet_peer_discovery_disabled;
 extern unsigned int lnet_drop_asym_route;
 extern unsigned int router_sensitivity_percentage;
+extern int alive_router_check_interval;
 extern int portal_rotor;
 
 int lnet_lib_init(void);
@@ -742,13 +743,16 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 
 int lnet_peers_start_down(void);
 int lnet_peer_buffer_credits(struct lnet_net *net);
+void lnet_consolidate_routes_locked(struct lnet_peer *orig_lp,
+				    struct lnet_peer *new_lp);
+void lnet_router_discovery_complete(struct lnet_peer *lp);
 
 int lnet_monitor_thr_start(void);
 void lnet_monitor_thr_stop(void);
 
 bool lnet_router_checker_active(void);
 void lnet_check_routers(void);
-void lnet_router_post_mt_start(void);
+void lnet_wait_router_start(void);
 void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
 
 int lnet_ping_info_validate(struct lnet_ping_info *pinfo);
@@ -795,6 +799,8 @@ struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 struct lnet_peer_ni *lnet_nid2peerni_locked(lnet_nid_t nid, lnet_nid_t pref,
 					    int cpt);
 struct lnet_peer_ni *lnet_nid2peerni_ex(lnet_nid_t nid, int cpt);
+struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
+					     lnet_nid_t nid);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 struct lnet_peer *lnet_find_peer(lnet_nid_t nid);
 void lnet_peer_net_added(struct lnet_net *net);
@@ -854,6 +860,7 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 }
 
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
+bool lnet_peer_gw_discovery(struct lnet_peer *lp);
 
 static inline bool
 lnet_peer_needs_push(struct lnet_peer *lp)
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 2d5ae21..9662c9e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -716,6 +716,9 @@ struct lnet_peer {
 #define LNET_PEER_FORCE_PING	BIT(13)	/* Forced Ping */
 #define LNET_PEER_FORCE_PUSH	BIT(14)	/* Forced Push */
 
+/* gw undergoing alive discovery */
+#define LNET_PEER_RTR_DISCOVERY	BIT(16)
+
 struct lnet_peer_net {
 	/* chain on lp_peer_nets */
 	struct list_head	lpn_peer_nets;
@@ -787,6 +790,8 @@ struct lnet_route {
 	struct list_head	lr_gwlist;
 	/* router node */
 	struct lnet_peer       *lr_gateway;
+	/* NID used to add route */
+	lnet_nid_t		lr_nid;
 	/* remote network number */
 	u32			lr_net;
 	/* local network number */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 4dc9514..b1823cd 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2533,29 +2533,32 @@ void lnet_lib_exit(void)
 		goto err_stop_ping;
 	}
 
-	rc = lnet_monitor_thr_start();
+	rc = lnet_push_target_init();
 	if (rc)
 		goto err_stop_ping;
 
-	rc = lnet_push_target_init();
-	if (rc != 0)
-		goto err_stop_monitor_thr;
-
 	rc = lnet_peer_discovery_start();
 	if (rc != 0)
 		goto err_destroy_push_target;
 
+	rc = lnet_monitor_thr_start();
+	if (rc != 0)
+		goto err_stop_discovery_thr;
+
 	lnet_fault_init();
 	lnet_router_debugfs_init();
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
+	/* wait for all routers to start */
+	lnet_wait_router_start();
+
 	return 0;
 
+err_stop_discovery_thr:
+	lnet_peer_discovery_stop();
 err_destroy_push_target:
 	lnet_push_target_fini();
-err_stop_monitor_thr:
-	lnet_monitor_thr_stop();
 err_stop_ping:
 	lnet_ping_target_fini();
 err_acceptor_stop:
@@ -2603,9 +2606,9 @@ void lnet_lib_exit(void)
 
 		lnet_fault_fini();
 		lnet_router_debugfs_fini();
+		lnet_monitor_thr_stop();
 		lnet_peer_discovery_stop();
 		lnet_push_target_fini();
-		lnet_monitor_thr_stop();
 		lnet_ping_target_fini();
 
 		/* Teardown fns that use my own API functions BEFORE here */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 2e2299d..e214a95 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1748,6 +1748,13 @@ struct lnet_ni *
 
 	lnet_peer_ni_addref_locked(lpni);
 
+	peer = lpni->lpni_peer_net->lpn_peer;
+
+	if (lnet_peer_gw_discovery(peer)) {
+		lnet_peer_ni_decref_locked(lpni);
+		return 0;
+	}
+
 	rc = lnet_discover_peer_locked(lpni, cpt, false);
 	if (rc) {
 		lnet_peer_ni_decref_locked(lpni);
@@ -3373,9 +3380,6 @@ int lnet_monitor_thr_start(void)
 		goto clean_thread;
 	}
 
-	/* post monitor thread start processing */
-	lnet_router_post_mt_start();
-
 	return 0;
 
 clean_thread:
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 8669fbb..b804d78 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -659,6 +659,24 @@ struct lnet_peer_ni *
 	return lpni;
 }
 
+struct lnet_peer_ni *
+lnet_peer_get_ni_locked(struct lnet_peer *lp, lnet_nid_t nid)
+{
+	struct lnet_peer_net *lpn;
+	struct lnet_peer_ni *lpni;
+
+	lpn = lnet_peer_get_net_locked(lp, LNET_NIDNET(nid));
+	if (!lpn)
+		return NULL;
+
+	list_for_each_entry(lpni, &lpn->lpn_peer_nis, lpni_peer_nis) {
+		if (lpni->lpni_nid == nid)
+			return lpni;
+	}
+
+	return NULL;
+}
+
 struct lnet_peer *
 lnet_find_peer(lnet_nid_t nid)
 {
@@ -1708,6 +1726,19 @@ struct lnet_peer_ni *
  * Peer Discovery
  */
 
+bool
+lnet_peer_gw_discovery(struct lnet_peer *lp)
+{
+	bool rc = false;
+
+	spin_lock(&lp->lp_lock);
+	if (lp->lp_state & LNET_PEER_RTR_DISCOVERY)
+		rc = true;
+	spin_unlock(&lp->lp_lock);
+
+	return rc;
+}
+
 /*
  * Is a peer uptodate from the point of view of discovery?
  *
@@ -1797,6 +1828,9 @@ static void lnet_peer_discovery_complete(struct lnet_peer *lp)
 	spin_unlock(&lp->lp_lock);
 	wake_up_all(&lp->lp_dc_waitq);
 
+	if (lp->lp_rtr_refcount > 0)
+		lnet_router_discovery_complete(lp);
+
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* iterate through all pending messages and send them again */
@@ -2685,8 +2719,11 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 				rc = lnet_peer_merge_data(lp, pbuf);
 			}
 		} else {
-			rc = lnet_peer_set_primary_data(
-				lpni->lpni_peer_net->lpn_peer, pbuf);
+			struct lnet_peer *new_lp;
+
+			new_lp = lpni->lpni_peer_net->lpn_peer;
+			rc = lnet_peer_set_primary_data(new_lp, pbuf);
+			lnet_consolidate_routes_locked(lp, new_lp);
 			lnet_peer_ni_decref_locked(lpni);
 		}
 	}
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 22a3018..4a061f3 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -78,13 +78,9 @@
 module_param(avoid_asym_router_failure, int, 0644);
 MODULE_PARM_DESC(avoid_asym_router_failure, "Avoid asymmetrical router failures (0 to disable)");
 
-static int dead_router_check_interval = 60;
-module_param(dead_router_check_interval, int, 0644);
-MODULE_PARM_DESC(dead_router_check_interval, "Seconds between dead router health checks (<= 0 to disable)");
-
-static int live_router_check_interval = 60;
-module_param(live_router_check_interval, int, 0644);
-MODULE_PARM_DESC(live_router_check_interval, "Seconds between live router health checks (<= 0 to disable)");
+int alive_router_check_interval = 60;
+module_param(alive_router_check_interval, int, 0644);
+MODULE_PARM_DESC(alive_router_check_interval, "Seconds between live router health checks (<= 0 to disable)");
 
 static int router_ping_timeout = 50;
 module_param(router_ping_timeout, int, 0644);
@@ -220,6 +216,61 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	return route_alive;
 }
 
+void
+lnet_consolidate_routes_locked(struct lnet_peer *orig_lp,
+			       struct lnet_peer *new_lp)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_route *route;
+
+	/* Although a route is correlated with a peer, but when it's added
+	 * a specific NID is used. That NID refers to a peer_ni within
+	 * a peer. There could be other peer_nis on the same net, which
+	 * can be used to send to that gateway. However when we are
+	 * consolidating gateways because of discovery, the nid used to
+	 * add the route might've moved between gateway peers. In this
+	 * case we want to move the route to the new gateway as well. The
+	 * intent here is not to confuse the user who added the route.
+	 */
+	list_for_each_entry(route, &orig_lp->lp_routes, lr_gwlist) {
+		lpni = lnet_peer_get_ni_locked(orig_lp, route->lr_nid);
+		if (!lpni) {
+			lnet_net_lock(LNET_LOCK_EX);
+			list_move(&route->lr_gwlist, &new_lp->lp_routes);
+			lnet_net_unlock(LNET_LOCK_EX);
+		}
+	}
+}
+
+void
+lnet_router_discovery_complete(struct lnet_peer *lp)
+{
+	struct lnet_peer_ni *lpni = NULL;
+
+	spin_lock(&lp->lp_lock);
+	lp->lp_state &= ~LNET_PEER_RTR_DISCOVERY;
+	spin_unlock(&lp->lp_lock);
+
+	/* Router discovery successful? All peer information would've been
+	 * updated already. No need to do any more processing
+	 */
+	if (!lp->lp_dc_error)
+		return;
+	/* discovery failed? then we need to set the status of each lpni
+	 * to DOWN. It will be updated the next time we discover the
+	 * router. For router peer NIs not on local networks, we never send
+	 * messages directly to them, so their health will always remain
+	 * at maximum. We can only tell if they are up or down from the
+	 * status returned in the PING response. If we fail to get that
+	 * status in our scheduled router discovery, then we'll assume
+	 * it's down until we're told otherwise.
+	 */
+	CDEBUG(D_NET, "%s: Router discovery failed %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_dc_error);
+	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
+		lpni->lpni_ns_status = LNET_NI_STATUS_DOWN;
+}
+
 static void
 lnet_rtr_addref_locked(struct lnet_peer *lp)
 {
@@ -368,6 +419,7 @@ static void lnet_shuffle_seed(void)
 	/* store the local and remote net that the route represents */
 	route->lr_lnet = LNET_NIDNET(gateway);
 	route->lr_net = net;
+	route->lr_nid = gateway;
 	route->lr_priority = priority;
 	route->lr_hops = hops;
 
@@ -610,10 +662,10 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 				if (!idx--) {
 					*net = rnet->lrn_net;
+					*gateway = route->lr_nid;
 					*hops = route->lr_hops;
-					*priority = route->lr_priority;
-					*gateway =
-					    route->lr_gateway->lp_primary_nid;
+					*priority =
+					    route->lr_priority;
 					*alive = lnet_is_route_alive(route);
 					lnet_net_unlock(cpt);
 					return 0;
@@ -667,8 +719,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 	LASSERT(the_lnet.ln_routing);
 
-	timeout = router_ping_timeout +
-		  max(live_router_check_interval, dead_router_check_interval);
+	timeout = router_ping_timeout + alive_router_check_interval;
 
 	now = ktime_get_real_seconds();
 	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
@@ -700,7 +751,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
-void lnet_router_post_mt_start(void)
+void lnet_wait_router_start(void)
 {
 	if (check_routers_before_use) {
 		/*
@@ -718,9 +769,6 @@ void lnet_router_post_mt_start(void)
  */
 bool lnet_router_checker_active(void)
 {
-	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
-		return true;
-
 	/*
 	 * Router Checker thread needs to run when routing is enabled in
 	 * order to call lnet_update_ni_status_locked()
@@ -729,23 +777,71 @@ bool lnet_router_checker_active(void)
 		return true;
 
 	return !list_empty(&the_lnet.ln_routers) &&
-		(live_router_check_interval > 0 ||
-		 dead_router_check_interval > 0);
+		alive_router_check_interval > 0;
 }
 
 void
 lnet_check_routers(void)
 {
+	struct lnet_peer_ni *lpni;
 	struct lnet_peer *rtr;
 	u64 version;
+	time64_t now;
 	int cpt;
+	int rc;
 
 	cpt = lnet_net_lock_current();
 rescan:
 	version = the_lnet.ln_routers_version;
 
 	list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
-		/* TODO use discovery to determine if router is alive */
+		now = ktime_get_real_seconds();
+
+		/* only discover the router if we've passed
+		 * alive_router_check_interval seconds. Some of the router
+		 * interfaces could be down and in that case they would be
+		 * undergoing recovery separately from this discovery.
+		 */
+		if (now - rtr->lp_rtrcheck_timestamp <
+		    alive_router_check_interval)
+			continue;
+
+		/* If we're currently discovering the peer then don't
+		 * issue another discovery
+		 */
+		spin_lock(&rtr->lp_lock);
+		if (rtr->lp_state & LNET_PEER_RTR_DISCOVERY) {
+			spin_unlock(&rtr->lp_lock);
+			continue;
+		}
+		/* make sure we actively discover the router */
+		rtr->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
+		rtr->lp_state |= LNET_PEER_RTR_DISCOVERY;
+		spin_unlock(&rtr->lp_lock);
+
+		/* find the peer_ni associated with the primary NID */
+		lpni = lnet_peer_get_ni_locked(rtr, rtr->lp_primary_nid);
+		if (!lpni) {
+			CDEBUG(D_NET,
+			       "Expected to find an lpni for %s, but non found\n",
+			       libcfs_nid2str(rtr->lp_primary_nid));
+			continue;
+		}
+		lnet_peer_ni_addref_locked(lpni);
+
+		/* discover the router */
+		CDEBUG(D_NET, "discover %s, cpt = %d\n",
+		       libcfs_nid2str(lpni->lpni_nid), cpt);
+		rc = lnet_discover_peer_locked(lpni, cpt, false);
+
+		/* decrement ref count acquired by find_peer_ni_locked() */
+		lnet_peer_ni_decref_locked(lpni);
+
+		if (!rc)
+			rtr->lp_rtrcheck_timestamp = now;
+		else
+			CERROR("Failed to discover router %s\n",
+			       libcfs_nid2str(rtr->lp_primary_nid));
 
 		/* NB dropped lock */
 		if (version != the_lnet.ln_routers_version) {
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index e494d19..9771ef0 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -222,8 +222,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 				      libcfs_net2str(net), hops,
 				      priority,
 				      alive ? "up" : "down",
-				      /* TODO: replace with actual nid */
-				      libcfs_nid2str(LNET_NID_ANY));
+				      libcfs_nid2str(route->lr_nid));
 			LASSERT(tmpstr + tmpsiz - s > 0);
 		}
 
-- 
1.8.3.1
