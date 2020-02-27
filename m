From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:26 -0500
Subject: [lustre-devel] [PATCH 338/622] lnet: router aliveness
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-339-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

A route is considered alive if the gateway is able to route
messages from the local to the remote net. That means that
at least one of the network interfaces on the remote net of
the gateway is viable.

Introduced the concept of sensitivity percentage. This defaults
to 100%. It holds a dual meaning:
1. A route is considered alive if at least one of the its interfaces'
health is >= LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage
100 means at least one interface has to be 100% healthy
2. On a router consider a peer_ni dead if its health is not at least
LNET_MAX_HEALTH_VALUE * router_sensitivity_percentage.
100% means the interface has to be 100% healthy.

Re-implemented lnet_notify() to decrement the health of the
peer interface if the LND reports a failure on that peer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11300
Lustre-commit: 21d2252648be ("LU-11300 lnet: router aliveness")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33185
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 11 ++-----
 net/lnet/lnet/router.c        | 74 +++++++++++++++++++++++++++++++++++++++++++
 net/lnet/lnet/router_proc.c   |  2 +-
 3 files changed, 77 insertions(+), 10 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index d5704b7..0007adf 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -90,15 +90,8 @@
 						  */
 #define LNET_LND_DEFAULT_TIMEOUT 5
 
-static inline int lnet_is_route_alive(struct lnet_route *route)
-{
-	/* TODO re-implement gateway alive indication */
-	CDEBUG(D_NET, "TODO: reimplement routing. gateway = %s\n",
-	       route->lr_gateway ?
-		libcfs_nid2str(route->lr_gateway->lp_primary_nid) :
-		"undefined");
-	return 1;
-}
+bool lnet_is_route_alive(struct lnet_route *route);
+bool lnet_is_gateway_alive(struct lnet_peer *gw);
 
 static inline int lnet_is_wire_handle_none(struct lnet_handle_wire *wh)
 {
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index d5b4914..bb92759 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -146,6 +146,80 @@ static int rtr_sensitivity_set(const char *val,
 	return check_routers_before_use;
 }
 
+/* A net is alive if at least one gateway NI on the network is alive. */
+static bool
+lnet_is_gateway_net_alive(struct lnet_peer_net *lpn)
+{
+	struct lnet_peer_ni *lpni;
+
+	list_for_each_entry(lpni, &lpn->lpn_peer_nis, lpni_peer_nis) {
+		if (lnet_is_peer_ni_alive(lpni))
+			return true;
+	}
+
+	return false;
+}
+
+/* a gateway is alive only if all its nets are alive
+ * called with cpt lock held
+ */
+bool lnet_is_gateway_alive(struct lnet_peer *gw)
+{
+	struct lnet_peer_net *lpn;
+
+	list_for_each_entry(lpn, &gw->lp_peer_nets, lpn_peer_nets) {
+		if (!lnet_is_gateway_net_alive(lpn))
+			return false;
+	}
+
+	return true;
+}
+
+/* lnet_is_route_alive() needs to be called with cpt lock held
+ * A route is alive if the gateway can route between the local network and
+ * the remote network of the route.
+ * This means at least one NI is alive on each of the local and remote
+ * networks of the gateway.
+ */
+bool lnet_is_route_alive(struct lnet_route *route)
+{
+	struct lnet_peer *gw = route->lr_gateway;
+	struct lnet_peer_net *llpn;
+	struct lnet_peer_net *rlpn;
+	bool route_alive;
+
+	/* check the gateway's interfaces on the route rnet to make sure
+	 * that the gateway is viable.
+	 */
+	llpn = lnet_peer_get_net_locked(gw, route->lr_lnet);
+	if (!llpn)
+		return false;
+
+	route_alive = lnet_is_gateway_net_alive(llpn);
+
+	if (avoid_asym_router_failure) {
+		rlpn = lnet_peer_get_net_locked(gw, route->lr_net);
+		if (!rlpn)
+			return false;
+		route_alive = route_alive &&
+			      lnet_is_gateway_net_alive(rlpn);
+	}
+
+	if (!route_alive)
+		return route_alive;
+
+	spin_lock(&gw->lp_lock);
+	if (!(gw->lp_state & LNET_PEER_ROUTER_ENABLED)) {
+		if (gw->lp_rtr_refcount > 0)
+			CERROR("peer %s is being used as a gateway but routing feature is not turned on\n",
+			       libcfs_nid2str(gw->lp_primary_nid));
+		route_alive = false;
+	}
+	spin_unlock(&gw->lp_lock);
+
+	return route_alive;
+}
+
 void
 lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 		   time64_t when)
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index e9aef1e..3120533 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -325,7 +325,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			int nrefs = atomic_read(&peer->lp_refcount);
 			int nrtrrefs = peer->lp_rtr_refcount;
 			int alive_cnt = 0;
-			int alive = 0;
+			int alive = lnet_is_gateway_alive(peer);
 			int pingsent = ((peer->lp_state & LNET_PEER_PING_SENT)
 				       != 0);
 			time64_t last_ping = now - peer->lp_rtrcheck_timestamp;
-- 
1.8.3.1
