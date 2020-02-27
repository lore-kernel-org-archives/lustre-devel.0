From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:45 -0500
Subject: [lustre-devel] [PATCH 537/622] lnet: Optimize check for routing
 feature flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-538-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Check the routing feature flag outside of the loop.

Cray-bug-id: LUS-7862
WC-bug-id: https://jira.whamcloud.com/browse/LU-12942
Lustre-commit: 7a99dc0b2f27 ("LU-12942 lnet: Optimize check for routing feature flag")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36679
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 447706d..41d0eb0 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -325,12 +325,14 @@ bool lnet_is_route_alive(struct lnet_route *route)
 
 	spin_unlock(&lp->lp_lock);
 
-	if (lp_state & LNET_PEER_PING_FAILED) {
-		CDEBUG(D_NET,
-		       "Ping failed with %d. Set routes down for gw %s\n",
-		       lp->lp_ping_error, libcfs_nid2str(lp->lp_primary_nid));
-		/* If the ping failed then mark the routes served by this
-		 * peer down
+	if (lp_state & LNET_PEER_PING_FAILED ||
+	    pbuf->pb_info.pi_features & LNET_PING_FEAT_RTE_DISABLED) {
+		CDEBUG(D_NET, "Set routes down for gw %s because %s %d\n",
+		       libcfs_nid2str(lp->lp_primary_nid),
+		       lp_state & LNET_PEER_PING_FAILED ? "ping failed" :
+		       "route feature is disabled", lp->lp_ping_error);
+		/* If the ping failed or the peer has routing disabled then
+		 * mark the routes served by this peer down
 		 */
 		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
 			lnet_set_route_aliveness(route, false);
@@ -359,13 +361,6 @@ bool lnet_is_route_alive(struct lnet_route *route)
 			    route->lr_gateway->lp_primary_nid)
 				continue;
 
-			/* gateway has the routing feature disabled */
-			if (pbuf->pb_info.pi_features &
-			      LNET_PING_FEAT_RTE_DISABLED) {
-				lnet_set_route_aliveness(route, false);
-				continue;
-			}
-
 			llpn = lnet_peer_get_net_locked(lp, route->lr_lnet);
 			if (!llpn) {
 				lnet_set_route_aliveness(route, false);
-- 
1.8.3.1
