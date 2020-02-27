From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:30 -0500
Subject: [lustre-devel] [PATCH 582/622] lnet: Fix source specified route
 selection
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-583-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

If lnet_send() is called with a specific src_nid, but
rtr_nid == LNET_NID_ANY and the message needs to be routed, then we
need to ensure that the lnet_peer_ni of our next hop is on the same
network as the lnet_ni associated with the src_nid. Otherwise we
may end up choosing an lnet_peer_ni that cannot be reached from
the specified source.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12919
Lustre-commit: f0aa632d4255 ("LU-12919 lnet: Fix source specified route selection")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36622
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 41 +++++++++++++++++++++++++++++------------
 1 file changed, 29 insertions(+), 12 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 269b2d5..ca292a6 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1290,7 +1290,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static struct lnet_route *
-lnet_find_route_locked(struct lnet_remotenet *rnet,
+lnet_find_route_locked(struct lnet_remotenet *rnet, u32 src_net,
 		       struct lnet_route **prev_route,
 		       struct lnet_peer_ni **gwni)
 {
@@ -1299,6 +1299,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_route *last_route;
 	struct lnet_route *route;
 	int rc;
+	u32 restrict_net;
+	u32 any_net = LNET_NIDNET(LNET_NID_ANY);
 
 	best_route = NULL;
 	last_route = NULL;
@@ -1306,14 +1308,23 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (!lnet_is_route_alive(route))
 			continue;
 
+		/* If the src_net is specified then we need to find an lpni
+		 * on that network
+		 */
+		restrict_net = src_net == any_net ? route->lr_lnet : src_net;
 		if (!best_route) {
-			best_route = route;
-			last_route = route;
-			best_gw_ni = lnet_find_best_lpni_on_net(NULL,
-								LNET_NID_ANY,
-								route->lr_gateway,
-								route->lr_lnet);
-			LASSERT(best_gw_ni);
+			lpni = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY,
+							  route->lr_gateway,
+							  restrict_net);
+			if (lpni) {
+				best_route = route;
+				last_route = route;
+				best_gw_ni = lpni;
+			} else {
+				CERROR("Gateway %s does not have a peer NI on net %s\n",
+				       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+				       libcfs_net2str(restrict_net));
+			}
 			continue;
 		}
 
@@ -1327,8 +1338,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		lpni = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY,
 						  route->lr_gateway,
-						  route->lr_lnet);
-		LASSERT(lpni);
+						  restrict_net);
+		if (!lpni) {
+			CERROR("Gateway %s does not have a peer NI on net %s\n",
+			       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+			       libcfs_net2str(restrict_net));
+			continue;
+		}
 
 		if (rc == 1) {
 			best_route = route;
@@ -1868,8 +1884,9 @@ struct lnet_ni *
 			return -EHOSTUNREACH;
 		}
 
-		best_route = lnet_find_route_locked(best_rnet, &last_route,
-						    &gwni);
+		best_route = lnet_find_route_locked(best_rnet,
+						    LNET_NIDNET(src_nid),
+						    &last_route, &gwni);
 		if (!best_route) {
 			CERROR("no route to %s from %s\n",
 			       libcfs_nid2str(dst_nid),
-- 
1.8.3.1
