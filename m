From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:17 -0500
Subject: [lustre-devel] [PATCH 329/622] lnet: remove route add restriction
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-330-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Remove restriction with adding routes to the same remote network
via two different gateways.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10153
Lustre-commit: 79ea6af86f57 ("LU-10153 lnet: remove route add restriction")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33447
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  1 -
 net/lnet/lnet/api-ni.c        | 10 ---------
 net/lnet/lnet/router.c        | 49 -------------------------------------------
 3 files changed, 60 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 10922ae..534be2a 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -521,7 +521,6 @@ void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
 int lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway_nid,
 		   unsigned int priority);
-int lnet_check_routes(void);
 int lnet_del_route(u32 net, lnet_nid_t gw_nid);
 void lnet_destroy_routes(void);
 int lnet_get_route(int idx, u32 *net, u32 *hops,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index aeb9d92..d27e9a4 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2491,10 +2491,6 @@ void lnet_lib_exit(void)
 		if (rc)
 			goto err_shutdown_lndnis;
 
-		rc = lnet_check_routes();
-		if (rc)
-			goto err_destroy_routes;
-
 		rc = lnet_rtrpools_alloc(im_a_router);
 		if (rc)
 			goto err_destroy_routes;
@@ -3449,12 +3445,6 @@ u32 lnet_get_dlc_seq_locked(void)
 				    config->cfg_config_u.cfg_route.rtr_hop,
 				    config->cfg_nid,
 				    config->cfg_config_u.cfg_route.rtr_priority);
-		if (!rc) {
-			rc = lnet_check_routes();
-			if (rc)
-				lnet_del_route(config->cfg_net,
-					       config->cfg_nid);
-		}
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 78a8659..c00b9251 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -427,55 +427,6 @@ static void lnet_shuffle_seed(void)
 }
 
 int
-lnet_check_routes(void)
-{
-	struct lnet_remotenet *rnet;
-	struct lnet_route *route;
-	struct lnet_route *route2;
-	int cpt;
-	struct list_head *rn_list;
-	int i;
-
-	cpt = lnet_net_lock_current();
-
-	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
-		rn_list = &the_lnet.ln_remote_nets_hash[i];
-		list_for_each_entry(rnet, rn_list, lrn_list) {
-			route2 = NULL;
-			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
-				lnet_nid_t nid1;
-				lnet_nid_t nid2;
-				int net;
-
-				if (!route2) {
-					route2 = route;
-					continue;
-				}
-
-				if (route->lr_gateway->lpni_net ==
-				    route2->lr_gateway->lpni_net)
-					continue;
-
-				nid1 = route->lr_gateway->lpni_nid;
-				nid2 = route2->lr_gateway->lpni_nid;
-				net = rnet->lrn_net;
-
-				lnet_net_unlock(cpt);
-
-				CERROR("Routes to %s via %s and %s not supported\n",
-				       libcfs_net2str(net),
-				       libcfs_nid2str(nid1),
-				       libcfs_nid2str(nid2));
-				return -EINVAL;
-			}
-		}
-	}
-
-	lnet_net_unlock(cpt);
-	return 0;
-}
-
-int
 lnet_del_route(u32 net, lnet_nid_t gw_nid)
 {
 	struct lnet_peer_ni *gateway;
-- 
1.8.3.1
