From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:20 -0500
Subject: [lustre-devel] [PATCH 332/622] lnet: lnet_add/del_route()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-333-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Reimplemented lnet_add_route() and lnet_del_route() to use
the peer instead of the peer_ni.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11299
Lustre-commit: 680da7444a06 ("LU-11299 lnet: lnet_add/del_route()")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33184
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 317 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 307 insertions(+), 10 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 4e79c21..8374ce1 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -190,6 +190,39 @@
 	spin_unlock(&lp->lpni_lock);
 }
 
+static void
+lnet_rtr_addref_locked(struct lnet_peer *lp)
+{
+	LASSERT(lp->lp_rtr_refcount >= 0);
+
+	/* lnet_net_lock must be exclusively locked */
+	lp->lp_rtr_refcount++;
+	if (lp->lp_rtr_refcount == 1) {
+		list_add_tail(&lp->lp_rtr_list, &the_lnet.ln_routers);
+		/* addref for the_lnet.ln_routers */
+		lnet_peer_addref_locked(lp);
+		the_lnet.ln_routers_version++;
+	}
+}
+
+static void
+lnet_rtr_decref_locked(struct lnet_peer *lp)
+{
+	LASSERT(atomic_read(&lp->lp_refcount) > 0);
+	LASSERT(lp->lp_rtr_refcount > 0);
+
+	/* lnet_net_lock must be exclusively locked */
+	lp->lp_rtr_refcount--;
+	if (lp->lp_rtr_refcount == 0) {
+		LASSERT(list_empty(&lp->lp_routes));
+
+		list_del(&lp->lp_rtr_list);
+		/* decref for the_lnet.ln_routers */
+		lnet_peer_decref_locked(lp);
+		the_lnet.ln_routers_version++;
+	}
+}
+
 struct lnet_remotenet *
 lnet_find_rnet_locked(u32 net)
 {
@@ -206,24 +239,288 @@ struct lnet_remotenet *
 	return NULL;
 }
 
+static void lnet_shuffle_seed(void)
+{
+	static int seeded;
+	struct lnet_ni *ni = NULL;
+
+	if (seeded)
+		return;
+
+	/* Nodes with small feet have little entropy
+	 * the NID for this node gives the most entropy in the low bits
+	 */
+	while ((ni = lnet_get_next_ni_locked(NULL, ni)))
+		add_device_randomness(&ni->ni_nid, sizeof(ni->ni_nid));
+
+	seeded = 1;
+}
+
+/* NB expects LNET_LOCK held */
+static void
+lnet_add_route_to_rnet(struct lnet_remotenet *rnet, struct lnet_route *route)
+{
+	unsigned int len = 0;
+	unsigned int offset = 0;
+	struct list_head *e;
+
+	lnet_shuffle_seed();
+
+	list_for_each(e, &rnet->lrn_routes)
+		len++;
+
+	/* Randomly adding routes to the list is done to ensure that when
+	 * different nodes are using the same list of routers, they end up
+	 * preferring different routers.
+	 */
+	offset = prandom_u32_max(len + 1);
+	list_for_each(e, &rnet->lrn_routes) {
+		if (offset == 0)
+			break;
+		offset--;
+	}
+	list_add(&route->lr_list, e);
+	/* force a router check on the gateway to make sure the route is
+	 * alive
+	 */
+	route->lr_gateway->lp_rtrcheck_timestamp = 0;
+
+	the_lnet.ln_remote_nets_version++;
+
+	/* add the route on the gateway list */
+	list_add(&route->lr_gwlist, &route->lr_gateway->lp_routes);
+
+	/* take a router reference count on the gateway */
+	lnet_rtr_addref_locked(route->lr_gateway);
+}
+
 int
 lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway,
 	       unsigned int priority)
 {
-	net = net;
-	hops = hops;
-	gateway = gateway;
-	priority = priority;
-	return -EINVAL;
+	struct list_head *route_entry;
+	struct lnet_remotenet *rnet;
+	struct lnet_remotenet *rnet2;
+	struct lnet_route *route;
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer *gw;
+	int add_route;
+	int rc;
+
+	CDEBUG(D_NET, "Add route: remote net %s hops %d priority %u gw %s\n",
+	       libcfs_net2str(net), hops, priority, libcfs_nid2str(gateway));
+
+	if (gateway == LNET_NID_ANY ||
+	    LNET_NETTYP(LNET_NIDNET(gateway)) == LOLND ||
+	    net == LNET_NIDNET(LNET_NID_ANY) ||
+	    LNET_NETTYP(net) == LOLND ||
+	    LNET_NIDNET(gateway) == net ||
+	    (hops != LNET_UNDEFINED_HOPS && (hops < 1 || hops > 255)))
+		return -EINVAL;
+
+	/* it's a local network */
+	if (lnet_islocalnet(net))
+		return -EEXIST;
+
+	/* Assume net, route, all new */
+	route = kzalloc(sizeof(*route), GFP_NOFS);
+	rnet = kzalloc(sizeof(*rnet), GFP_NOFS);
+	if (!route || !rnet) {
+		CERROR("Out of memory creating route %s %d %s\n",
+		       libcfs_net2str(net), hops, libcfs_nid2str(gateway));
+		kfree(route);
+		kfree(rnet);
+		return -ENOMEM;
+	}
+
+	INIT_LIST_HEAD(&rnet->lrn_routes);
+	rnet->lrn_net = net;
+	/* store the local and remote net that the route represents */
+	route->lr_lnet = LNET_NIDNET(gateway);
+	route->lr_net = net;
+	route->lr_priority = priority;
+	route->lr_hops = hops;
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	/* lnet_nid2peerni_ex() grabs a ref on the lpni. We will need to
+	 * lose that once we're done
+	 */
+	lpni = lnet_nid2peerni_ex(gateway, LNET_LOCK_EX);
+	if (IS_ERR(lpni)) {
+		lnet_net_unlock(LNET_LOCK_EX);
+
+		kfree(route);
+		kfree(rnet);
+
+		rc = PTR_ERR(lpni);
+		CERROR("Error %d creating route %s %d %s\n", rc,
+		       libcfs_net2str(net), hops,
+		       libcfs_nid2str(gateway));
+		return rc;
+	}
+
+	LASSERT(lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer);
+	gw = lpni->lpni_peer_net->lpn_peer;
+
+	route->lr_gateway = gw;
+
+	rnet2 = lnet_find_rnet_locked(net);
+	if (!rnet2) {
+		/* new network */
+		list_add_tail(&rnet->lrn_list, lnet_net2rnethash(net));
+		rnet2 = rnet;
+	}
+
+	/* Search for a duplicate route (it's a NOOP if it is) */
+	add_route = 1;
+	list_for_each(route_entry, &rnet2->lrn_routes) {
+		struct lnet_route *route2;
+
+		route2 = list_entry(route_entry, struct lnet_route, lr_list);
+		if (route2->lr_gateway == route->lr_gateway) {
+			add_route = 0;
+			break;
+		}
+
+		/* our lookups must be true */
+		LASSERT(route2->lr_gateway->lp_primary_nid != gateway);
+	}
+
+	/* It is possible to add multiple routes through the same peer,
+	 * but it'll be using a different NID of that peer. When the
+	 * gateway is discovered, discovery will consolidate the different
+	 * peers into one peer. In this case the discovery code will have
+	 * to move the routes from the peer that's being deleted to the
+	 * consolidated peer lp_routes list
+	 */
+	if (add_route)
+		lnet_add_route_to_rnet(rnet2, route);
+
+	/* get rid of the reference on the lpni.
+	 */
+	lnet_peer_ni_decref_locked(lpni);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	rc = 0;
+
+	if (!add_route) {
+		rc = -EEXIST;
+		kfree(route);
+	}
+
+	if (rnet != rnet2)
+		kfree(rnet);
+
+	/* kick start the monitor thread to handle the added route */
+	wake_up(&the_lnet.ln_mt_waitq);
+
+	return rc;
+}
+
+static void
+lnet_del_route_from_rnet(lnet_nid_t gw_nid, struct list_head *route_list,
+			 struct list_head *zombies)
+{
+	struct lnet_peer *gateway;
+	struct lnet_route *route;
+	struct lnet_route *tmp;
+
+	list_for_each_entry_safe(route, tmp, route_list, lr_list) {
+		gateway = route->lr_gateway;
+		if (gw_nid != LNET_NID_ANY &&
+		    gw_nid != gateway->lp_primary_nid)
+			continue;
+
+		/* move to zombie to delete outside the lock
+		 * Note that this function is called with the
+		 * ln_api_mutex held as well as the exclusive net
+		 * lock. Adding to the remote net list happens
+		 * under the same conditions. Same goes for the
+		 * gateway router list
+		 */
+		list_move(&route->lr_list, zombies);
+		the_lnet.ln_remote_nets_version++;
+
+		list_del(&route->lr_gwlist);
+		lnet_rtr_decref_locked(gateway);
+	}
 }
 
-/* TODO: reimplement lnet_check_routes() */
 int
 lnet_del_route(u32 net, lnet_nid_t gw_nid)
 {
-	net = net;
-	gw_nid = gw_nid;
-	return -EINVAL;
+	struct list_head rnet_zombies;
+	struct lnet_remotenet *rnet;
+	struct lnet_remotenet *tmp;
+	struct list_head *rn_list;
+	struct lnet_peer_ni *lpni;
+	struct lnet_route *route;
+	struct list_head zombies;
+	struct lnet_peer *lp;
+	int i = 0;
+
+	INIT_LIST_HEAD(&rnet_zombies);
+	INIT_LIST_HEAD(&zombies);
+
+	CDEBUG(D_NET, "Del route: net %s : gw %s\n",
+	       libcfs_net2str(net), libcfs_nid2str(gw_nid));
+
+	/* NB Caller may specify either all routes via the given gateway
+	 * or a specific route entry actual NIDs)
+	 */
+
+	lnet_net_lock(LNET_LOCK_EX);
+
+	lpni = lnet_find_peer_ni_locked(gw_nid);
+	if (lpni) {
+		lp = lpni->lpni_peer_net->lpn_peer;
+		LASSERT(lp);
+		gw_nid = lp->lp_primary_nid;
+		lnet_peer_ni_decref_locked(lpni);
+	}
+
+	if (net != LNET_NIDNET(LNET_NID_ANY)) {
+		rnet = lnet_find_rnet_locked(net);
+		if (!rnet) {
+			lnet_net_unlock(LNET_LOCK_EX);
+			return -ENOENT;
+		}
+		lnet_del_route_from_rnet(gw_nid, &rnet->lrn_routes,
+					 &zombies);
+		if (list_empty(&rnet->lrn_routes))
+			list_move(&rnet->lrn_list, &rnet_zombies);
+		goto delete_zombies;
+	}
+
+	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
+		rn_list = &the_lnet.ln_remote_nets_hash[i];
+
+		list_for_each_entry_safe(rnet, tmp, rn_list, lrn_list) {
+			lnet_del_route_from_rnet(gw_nid, &rnet->lrn_routes,
+						 &zombies);
+			if (list_empty(&rnet->lrn_routes))
+				list_move(&rnet->lrn_list, &rnet_zombies);
+		}
+	}
+
+delete_zombies:
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	while (!list_empty(&zombies)) {
+		route = list_first_entry(&zombies, struct lnet_route, lr_list);
+		list_del(&route->lr_list);
+		kfree(route);
+	}
+
+	while (!list_empty(&rnet_zombies)) {
+		rnet = list_first_entry(&rnet_zombies, struct lnet_remotenet,
+					lrn_list);
+		list_del(&rnet->lrn_list);
+		kfree(rnet);
+	}
+
+	return 0;
 }
 
 void
@@ -900,7 +1197,7 @@ bool lnet_router_checker_active(void)
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_routing = 1;
 	lnet_net_unlock(LNET_LOCK_EX);
-
+	wake_up(&the_lnet.ln_mt_waitq);
 	return 0;
 
 failed:
-- 
1.8.3.1
