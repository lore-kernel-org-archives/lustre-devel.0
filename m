From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:17 -0500
Subject: [lustre-devel] [PATCH 449/622] lnet: discovery off route state
 update
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-450-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When discovery is off rely on the discovery ping response
only, rather than the internal peer database to determine
route state. With discovery off the internal peer database
is not updated with all the gateway's interfaces.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12422
Lustre-commit: e35be987da57 ("LU-12422 lnet: discovery off route state update")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35199
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   1 +
 include/linux/lnet/lib-types.h |   4 +-
 net/lnet/lnet/peer.c           |   8 +++
 net/lnet/lnet/router.c         | 134 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 146 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index b889af2..f2f5455 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -758,6 +758,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 void lnet_consolidate_routes_locked(struct lnet_peer *orig_lp,
 				    struct lnet_peer *new_lp);
 void lnet_router_discovery_complete(struct lnet_peer *lp);
+void lnet_router_discovery_ping_reply(struct lnet_peer *lp);
 
 int lnet_monitor_thr_start(void);
 void lnet_monitor_thr_stop(void);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 3f81928..22c2bc6 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -611,7 +611,7 @@ struct lnet_peer {
 	/* number of NIDs on this peer */
 	int			lp_nnis;
 
-	/* # refs from lnet_route_t::lr_gateway */
+	/* # refs from lnet_route::lr_gateway */
 	int			lp_rtr_refcount;
 
 	/*
@@ -822,6 +822,8 @@ struct lnet_route {
 	u32			lr_hops;
 	/* route priority */
 	unsigned int		lr_priority;
+	/* cached route aliveness */
+	bool			lr_alive;
 };
 
 #define LNET_REMOTE_NETS_HASH_DEFAULT	(1U << 7)
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 49da7a1..088bb62 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2398,6 +2398,14 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 out:
 	lp->lp_state &= ~LNET_PEER_PING_SENT;
 	spin_unlock(&lp->lp_lock);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	/* If this peer is a gateway, call the routing callback to
+	 * handle the ping reply
+	 */
+	if (lp->lp_rtr_refcount > 0)
+		lnet_router_discovery_ping_reply(lp);
+	lnet_net_unlock(LNET_LOCK_EX);
 }
 
 /*
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 4ab587d..bc9494d 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -221,6 +221,15 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	struct lnet_peer_net *rlpn;
 	bool route_alive;
 
+	/* if discovery is disabled then rely on the cached aliveness
+	 * information. This is handicapped information which we log when
+	 * we receive the discovery ping response. The most uptodate
+	 * aliveness information can only be obtained when discovery is
+	 * enabled.
+	 */
+	if (lnet_peer_discovery_disabled)
+		return route->lr_alive;
+
 	/* check the gateway's interfaces on the route rnet to make sure
 	 * that the gateway is viable.
 	 */
@@ -279,10 +288,125 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	}
 }
 
+static inline void
+lnet_set_route_aliveness(struct lnet_route *route, bool alive)
+{
+	/* Log when there's a state change */
+	if (route->lr_alive != alive) {
+		CERROR("route to %s through %s has gone from %s to %s\n",
+		       libcfs_net2str(route->lr_net),
+		       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+		       (route->lr_alive) ? "up" : "down",
+		       alive ? "up" : "down");
+		route->lr_alive = alive;
+	}
+}
+
+void
+lnet_router_discovery_ping_reply(struct lnet_peer *lp)
+{
+	struct lnet_ping_buffer *pbuf = lp->lp_data;
+	struct lnet_remotenet *rnet;
+	struct lnet_peer_net *llpn;
+	struct lnet_route *route;
+	bool net_up = false;
+	unsigned int lp_state;
+	u32 net, net2;
+	int i, j;
+
+	spin_lock(&lp->lp_lock);
+	lp_state = lp->lp_state;
+	spin_unlock(&lp->lp_lock);
+
+	/* only handle replies if discovery is disabled. */
+	if (!lnet_peer_discovery_disabled)
+		return;
+
+	if (lp_state & LNET_PEER_PING_FAILED) {
+		CDEBUG(D_NET,
+		       "Ping failed with %d. Set routes down for gw %s\n",
+		       lp->lp_ping_error, libcfs_nid2str(lp->lp_primary_nid));
+		/* If the ping failed then mark the routes served by this
+		 * peer down
+		 */
+		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
+			lnet_set_route_aliveness(route, false);
+		return;
+	}
+
+	CDEBUG(D_NET, "Discovery is disabled. Processing reply for gw: %s\n",
+	       libcfs_nid2str(lp->lp_primary_nid));
+
+	/* examine the ping response:
+	 * For each NID in the ping response, extract the net
+	 * if the net exists on our remote net list then
+	 * iterate over the routes on the rnet and if:
+	 *	The route's local net is healthy and
+	 *	The remote net status is UP, then mark the route up
+	 * otherwise mark the route down
+	 */
+	for (i = 1; i < pbuf->pb_info.pi_nnis; i++) {
+		net = LNET_NIDNET(pbuf->pb_info.pi_ni[i].ns_nid);
+		rnet = lnet_find_rnet_locked(net);
+		if (!rnet)
+			continue;
+		list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
+			/* check if this is the route's gateway */
+			if (lp->lp_primary_nid !=
+			    route->lr_gateway->lp_primary_nid)
+				continue;
+
+			/* gateway has the routing feature disabled */
+			if (pbuf->pb_info.pi_features &
+			      LNET_PING_FEAT_RTE_DISABLED) {
+				lnet_set_route_aliveness(route, false);
+				continue;
+			}
+
+			llpn = lnet_peer_get_net_locked(lp, route->lr_lnet);
+			if (!llpn) {
+				lnet_set_route_aliveness(route, false);
+				continue;
+			}
+
+			if (!lnet_is_gateway_net_alive(llpn)) {
+				lnet_set_route_aliveness(route, false);
+				continue;
+			}
+
+			if (avoid_asym_router_failure &&
+			    pbuf->pb_info.pi_ni[i].ns_status !=
+				LNET_NI_STATUS_UP) {
+				net_up = false;
+
+				/* revisit all previous NIDs and check if
+				 * any on the network we're examining is
+				 * up. If at least one is up then we consider
+				 * the route to be alive.
+				 */
+				for (j = 1; j < i; j++) {
+					net2 = LNET_NIDNET(pbuf->pb_info.pi_ni[j].ns_nid);
+					if (net2 == net &&
+					    pbuf->pb_info.pi_ni[j].ns_status ==
+					    LNET_NI_STATUS_UP)
+						net_up = true;
+				}
+				if (!net_up) {
+					lnet_set_route_aliveness(route, false);
+					continue;
+				}
+			}
+
+			lnet_set_route_aliveness(route, true);
+		}
+	}
+}
+
 void
 lnet_router_discovery_complete(struct lnet_peer *lp)
 {
 	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_route *route;
 
 	spin_lock(&lp->lp_lock);
 	lp->lp_state &= ~LNET_PEER_RTR_DISCOVERY;
@@ -306,6 +430,9 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_dc_error);
 	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL)
 		lpni->lpni_ns_status = LNET_NI_STATUS_DOWN;
+
+	list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
+		lnet_set_route_aliveness(route, false);
 }
 
 static void
@@ -1431,6 +1558,8 @@ bool lnet_router_checker_active(void)
 	    time64_t when)
 {
 	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_route *route;
+	struct lnet_peer *lp;
 	time64_t now = ktime_get_seconds();
 	int cpt;
 
@@ -1499,6 +1628,11 @@ bool lnet_router_checker_active(void)
 	cpt = lpni->lpni_cpt;
 	lnet_net_lock(cpt);
 	lnet_peer_ni_decref_locked(lpni);
+	if (lpni && lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer) {
+		lp = lpni->lpni_peer_net->lpn_peer;
+		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
+			lnet_set_route_aliveness(route, alive);
+	}
 	lnet_net_unlock(cpt);
 
 	return 0;
-- 
1.8.3.1
