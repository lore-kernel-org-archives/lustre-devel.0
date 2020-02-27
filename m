From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:15 -0500
Subject: [lustre-devel] [PATCH 567/622] lnet: Add peer level aliveness
 information
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-568-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Keep track of the aliveness of a peer so that we can optimize for
situations where an LNet router hasn't responded to a ping. In
this situation we consider all routes down, and we needn't spend time
inspecting each route, or inspecting all of the router's local and
remote interfaces in order to determine the router's aliveness.

Cray-bug-id: LUS-7860
WC-bug-id: https://jira.whamcloud.com/browse/LU-12941
Lustre-commit: ebc9835a971f ("LU-12941 lnet: Add peer level aliveness information")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36678
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  3 +++
 net/lnet/lnet/peer.c           |  4 ++++
 net/lnet/lnet/router.c         | 52 ++++++++++++++++++++++++------------------
 3 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index e105308..02ac5df 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -672,6 +672,9 @@ struct lnet_peer {
 
 	/* tasks waiting on discovery of this peer */
 	wait_queue_head_t	lp_dc_waitq;
+
+	/* cached peer aliveness */
+	bool			lp_alive;
 };
 
 /*
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 4f0da4b..b168c97 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -216,6 +216,10 @@
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
+	if (lnet_peers_start_down())
+		lp->lp_alive = false;
+	else
+		lp->lp_alive = true;
 
 	/* all peers created on a router should have health on
 	 * if it's not already on.
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index b8f7aba0..7ba406a 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -179,7 +179,9 @@ static int rtr_sensitivity_set(const char *val,
 	return check_routers_before_use;
 }
 
-/* A net is alive if at least one gateway NI on the network is alive. */
+/* The peer_net of a gateway is alive if at least one of the peer_ni's on
+ * that peer_net is alive.
+ */
 static bool
 lnet_is_gateway_net_alive(struct lnet_peer_net *lpn)
 {
@@ -200,6 +202,9 @@ bool lnet_is_gateway_alive(struct lnet_peer *gw)
 {
 	struct lnet_peer_net *lpn;
 
+	if (!gw->lp_alive)
+		return false;
+
 	list_for_each_entry(lpn, &gw->lp_peer_nets, lpn_peer_nets) {
 		if (!lnet_is_gateway_net_alive(lpn))
 			return false;
@@ -219,7 +224,10 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	struct lnet_peer *gw = route->lr_gateway;
 	struct lnet_peer_net *llpn;
 	struct lnet_peer_net *rlpn;
-	bool route_alive;
+
+	/* If the gateway is down then all routes are considered down */
+	if (!gw->lp_alive)
+		return false;
 
 	/* if discovery is disabled then rely on the cached aliveness
 	 * information. This is handicapped information which we log when
@@ -230,36 +238,34 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	if (lnet_is_discovery_disabled(gw))
 		return route->lr_alive;
 
-	/* check the gateway's interfaces on the route rnet to make sure
-	 * that the gateway is viable.
-	 */
+	/* check the gateway's interfaces on the local network */
 	llpn = lnet_peer_get_net_locked(gw, route->lr_lnet);
 	if (!llpn)
 		return false;
 
-	route_alive = lnet_is_gateway_net_alive(llpn);
+	if (!lnet_is_gateway_net_alive(llpn))
+		return false;
 
 	if (avoid_asym_router_failure) {
+		/* Check the gateway's interfaces on the remote network */
 		rlpn = lnet_peer_get_net_locked(gw, route->lr_net);
 		if (!rlpn)
 			return false;
-		route_alive = route_alive &&
-			      lnet_is_gateway_net_alive(rlpn);
+		if (!lnet_is_gateway_net_alive(rlpn))
+			return false;
 	}
 
-	if (!route_alive)
-		return route_alive;
-
 	spin_lock(&gw->lp_lock);
 	if (!(gw->lp_state & LNET_PEER_ROUTER_ENABLED)) {
+		spin_unlock(&gw->lp_lock);
 		if (gw->lp_rtr_refcount > 0)
 			CERROR("peer %s is being used as a gateway but routing feature is not turned on\n",
 			       libcfs_nid2str(gw->lp_primary_nid));
-		route_alive = false;
+		return false;
 	}
 	spin_unlock(&gw->lp_lock);
 
-	return route_alive;
+	return true;
 }
 
 void
@@ -409,21 +415,22 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	spin_lock(&lp->lp_lock);
 	lp->lp_state &= ~LNET_PEER_RTR_DISCOVERY;
 	lp->lp_state |= LNET_PEER_RTR_DISCOVERED;
+	lp->lp_alive = lp->lp_dc_error == 0;
 	spin_unlock(&lp->lp_lock);
 
 	/* Router discovery successful? All peer information would've been
 	 * updated already. No need to do any more processing
 	 */
-	if (!lp->lp_dc_error)
+	if (lp->lp_alive)
 		return;
-	/* discovery failed? then we need to set the status of each lpni
-	 * to DOWN. It will be updated the next time we discover the
-	 * router. For router peer NIs not on local networks, we never send
-	 * messages directly to them, so their health will always remain
-	 * at maximum. We can only tell if they are up or down from the
-	 * status returned in the PING response. If we fail to get that
-	 * status in our scheduled router discovery, then we'll assume
-	 * it's down until we're told otherwise.
+
+	/* We do not send messages directly to the remote interfaces
+	 * of an LNet router. As such, we rely on the PING response
+	 * to determine the up/down status of these interfaces. If
+	 * a PING response is not receieved, or some other problem with
+	 * discovery occurs that prevents us from getting this status,
+	 * we assume all interfaces are down until we're able to
+	 * determine otherwise.
 	 */
 	CDEBUG(D_NET, "%s: Router discovery failed %d\n",
 	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_dc_error);
@@ -1629,6 +1636,7 @@ bool lnet_router_checker_active(void)
 	lnet_peer_ni_decref_locked(lpni);
 	if (lpni && lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer) {
 		lp = lpni->lpni_peer_net->lpn_peer;
+		lp->lp_alive = alive;
 		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
 			lnet_set_route_aliveness(route, alive);
 	}
-- 
1.8.3.1
