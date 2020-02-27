From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:39 -0500
Subject: [lustre-devel] [PATCH 351/622] lnet: handle router health off
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-352-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Routing infrastructure depends on health infrastructure to manage
route status. However, health can be turned off. Therefore, we need
to enable health for gateways in order to monitor them properly.
Each peer now has its own health sensitivity. When adding a route
the gateway's health sensitivity can be explicitly set from lnetctl
or if not specified then it'll default to 1, thereby turning health
on for that gateway, allowing peer NI recovery if there is a failure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11297
Lustre-commit: 00a2932b0aa7 ("LU-11297 lnet: handle router health off")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33634
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h      |  5 +++--
 include/linux/lnet/lib-types.h     |  6 ++++++
 include/uapi/linux/lnet/lnet-dlc.h |  1 +
 net/lnet/lnet/api-ni.c             | 16 +++++++++++++---
 net/lnet/lnet/config.c             |  2 +-
 net/lnet/lnet/lib-msg.c            | 20 +++++++++++++++-----
 net/lnet/lnet/peer.c               |  6 ++++++
 net/lnet/lnet/router.c             | 11 +++++++----
 8 files changed, 52 insertions(+), 15 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 09adfc3..36aaaa5 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -512,11 +512,12 @@ int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, bool alive, bool reset,
 void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
 int lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway_nid,
-		   unsigned int priority);
+		   u32 priority, u32 sensitivity);
 int lnet_del_route(u32 net, lnet_nid_t gw_nid);
 void lnet_destroy_routes(void);
 int lnet_get_route(int idx, u32 *net, u32 *hops,
-		   lnet_nid_t *gateway, u32 *alive, u32 *priority);
+		   lnet_nid_t *gateway, u32 *alive, u32 *priority,
+		   u32 *sensitivity);
 int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg);
 struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
 					struct lnet_ni *prev);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 97d35e0..56654f5 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -606,6 +606,12 @@ struct lnet_peer {
 	/* # refs from lnet_route_t::lr_gateway */
 	int			lp_rtr_refcount;
 
+	/*
+	 * peer specific health sensitivity value to decrement peer nis in
+	 * this peer with if set to something other than 0
+	 */
+	u32			lp_health_sensitivity;
+
 	/* messages blocking for router credits */
 	struct list_head	lp_rtrq;
 
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 87f7680..e0b9eae 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -129,6 +129,7 @@ struct lnet_ioctl_config_data {
 			__u32 rtr_hop;
 			__u32 rtr_priority;
 			__u32 rtr_flags;
+			__u32 rtr_sensitivity;
 		} cfg_route;
 		struct {
 			char net_intf[LNET_MAX_STR_LEN];
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index b1823cd..702e4b9 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3455,19 +3455,28 @@ u32 lnet_get_dlc_seq_locked(void)
 	case IOC_LIBCFS_FAIL_NID:
 		return lnet_fail_nid(data->ioc_nid, data->ioc_count);
 
-	case IOC_LIBCFS_ADD_ROUTE:
+	case IOC_LIBCFS_ADD_ROUTE: {
+		/* default router sensitivity to 1 */
+		unsigned int sensitivity = 1;
 		config = arg;
 
 		if (config->cfg_hdr.ioc_len < sizeof(*config))
 			return -EINVAL;
 
+		if (config->cfg_config_u.cfg_route.rtr_sensitivity) {
+			sensitivity =
+			  config->cfg_config_u.cfg_route.rtr_sensitivity;
+		}
+
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_add_route(config->cfg_net,
 				    config->cfg_config_u.cfg_route.rtr_hop,
 				    config->cfg_nid,
-				    config->cfg_config_u.cfg_route.rtr_priority);
+				    config->cfg_config_u.cfg_route.rtr_priority,
+				    sensitivity);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
+	}
 
 	case IOC_LIBCFS_DEL_ROUTE:
 		config = arg;
@@ -3492,7 +3501,8 @@ u32 lnet_get_dlc_seq_locked(void)
 				    &config->cfg_config_u.cfg_route.rtr_hop,
 				    &config->cfg_nid,
 				    &config->cfg_config_u.cfg_route.rtr_flags,
-				    &config->cfg_config_u.cfg_route.rtr_priority);
+				    &config->cfg_config_u.cfg_route.rtr_priority,
+				    &config->cfg_config_u.cfg_route.rtr_sensitivity);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 760452c..949cdd3 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1215,7 +1215,7 @@ struct lnet_ni *
 				continue;
 			}
 
-			rc = lnet_add_route(net, hops, nid, priority);
+			rc = lnet_add_route(net, hops, nid, priority, 1);
 			if (rc && rc != -EEXIST && rc != -EHOSTUNREACH) {
 				CERROR("Can't create route to %s via %s\n",
 				       libcfs_net2str(net),
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 8876866..9ffd874 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -448,14 +448,14 @@
 }
 
 static void
-lnet_dec_healthv_locked(atomic_t *healthv)
+lnet_dec_healthv_locked(atomic_t *healthv, int sensitivity)
 {
 	int h = atomic_read(healthv);
 
-	if (h < lnet_health_sensitivity) {
+	if (h < sensitivity) {
 		atomic_set(healthv, 0);
 	} else {
-		h -= lnet_health_sensitivity;
+		h -= sensitivity;
 		atomic_set(healthv, h);
 	}
 }
@@ -473,7 +473,7 @@
 		return;
 	}
 
-	lnet_dec_healthv_locked(&local_ni->ni_healthv);
+	lnet_dec_healthv_locked(&local_ni->ni_healthv, lnet_health_sensitivity);
 	/* add the NI to the recovery queue if it's not already there
 	 * and it's health value is actually below the maximum. It's
 	 * possible that the sensitivity might be set to 0, and the health
@@ -495,11 +495,21 @@
 void
 lnet_handle_remote_failure_locked(struct lnet_peer_ni *lpni)
 {
+	u32 sensitivity = lnet_health_sensitivity;
+	u32 lp_sensitivity;
+
 	/* lpni could be NULL if we're in the LOLND case */
 	if (!lpni)
 		return;
 
-	lnet_dec_healthv_locked(&lpni->lpni_healthv);
+	/* If there is a health sensitivity in the peer then use that
+	 * instead of the globally set one.
+	 */
+	lp_sensitivity = lpni->lpni_peer_net->lpn_peer->lp_health_sensitivity;
+	if (lp_sensitivity)
+		sensitivity = lp_sensitivity;
+
+	lnet_dec_healthv_locked(&lpni->lpni_healthv, sensitivity);
 	/* add the peer NI to the recovery queue if it's not already there
 	 * and it's health value is actually below the maximum. It's
 	 * possible that the sensitivity might be set to 0, and the health
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 41a6180..294f968 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -217,6 +217,12 @@
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
 
+	/* all peers created on a router should have health on
+	 * if it's not already on.
+	 */
+	if (the_lnet.ln_routing && !lnet_health_sensitivity)
+		lp->lp_health_sensitivity = 1;
+
 	/* Turn off discovery for loopback peer. If you're creating a peer
 	 * for the loopback interface then that was initiated when we
 	 * attempted to send a message over the loopback. There is no need
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index aa8ec8c..eb36df5 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -406,7 +406,7 @@ static void lnet_shuffle_seed(void)
 
 int
 lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway,
-	       unsigned int priority)
+	       u32 priority, u32 sensitivity)
 {
 	struct list_head *route_entry;
 	struct lnet_remotenet *rnet;
@@ -505,8 +505,10 @@ static void lnet_shuffle_seed(void)
 	 * to move the routes from the peer that's being deleted to the
 	 * consolidated peer lp_routes list
 	 */
-	if (add_route)
+	if (add_route) {
+		gw->lp_health_sensitivity = sensitivity;
 		lnet_add_route_to_rnet(rnet2, route);
+	}
 
 	/* get rid of the reference on the lpni.
 	 */
@@ -675,13 +677,13 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 int
 lnet_get_route(int idx, u32 *net, u32 *hops,
-	       lnet_nid_t *gateway, u32 *alive, u32 *priority)
+	       lnet_nid_t *gateway, u32 *alive, u32 *priority, u32 *sensitivity)
 {
 	struct lnet_remotenet *rnet;
+	struct list_head *rn_list;
 	struct lnet_route *route;
 	int cpt;
 	int i;
-	struct list_head *rn_list;
 
 	cpt = lnet_net_lock_current();
 
@@ -695,6 +697,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 					*hops = route->lr_hops;
 					*priority =
 					    route->lr_priority;
+					*sensitivity = route->lr_gateway->lp_health_sensitivity;
 					*alive = lnet_is_route_alive(route);
 					lnet_net_unlock(cpt);
 					return 0;
-- 
1.8.3.1
