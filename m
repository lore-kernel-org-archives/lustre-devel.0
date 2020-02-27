From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:27 -0500
Subject: [lustre-devel] [PATCH 579/622] lnet: Refactor lnet_compare_routes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-580-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Restrict lnet_compare_routes() to only comparing the lnet_route
objects passed as arguments. This saves us from doing unnecessary
calls to lnet_find_best_lpni_on_net().

Rename lnet_compare_peers to lnet_compare_gw_lpnis to better
reflect what is done by this routine.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12756
Lustre-commit: e02287b4ef6a ("LU-12756 lnet: Refactor lnet_compare_routes")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36621
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 77 +++++++++++++++++++-----------------------------
 1 file changed, 31 insertions(+), 46 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index b7990c9..269b2d5 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1137,7 +1137,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static int
-lnet_compare_peers(struct lnet_peer_ni *p1, struct lnet_peer_ni *p2)
+lnet_compare_gw_lpnis(struct lnet_peer_ni *p1, struct lnet_peer_ni *p2)
 {
 	if (p1->lpni_txqnob < p2->lpni_txqnob)
 		return 1;
@@ -1267,60 +1267,26 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return lnet_select_peer_ni(lni, dst_nid, peer, peer_net);
 }
 
+/* Compare route priorities and hop counts */
 static int
-lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2,
-		    struct lnet_peer_ni **best_lpni)
+lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
 {
 	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
 	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
-	struct lnet_peer *lp1 = r1->lr_gateway;
-	struct lnet_peer *lp2 = r2->lr_gateway;
-	struct lnet_peer_ni *lpni1;
-	struct lnet_peer_ni *lpni2;
-	int rc;
-
-	lpni1 = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY, lp1,
-					   r1->lr_lnet);
-	lpni2 = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY, lp2,
-					   r2->lr_lnet);
-	LASSERT(lpni1 && lpni2);
 
-	if (r1->lr_priority < r2->lr_priority) {
-		*best_lpni = lpni1;
+	if (r1->lr_priority < r2->lr_priority)
 		return 1;
-	}
 
-	if (r1->lr_priority > r2->lr_priority) {
-		*best_lpni = lpni2;
+	if (r1->lr_priority > r2->lr_priority)
 		return -1;
-	}
 
-	if (r1_hops < r2_hops) {
-		*best_lpni = lpni1;
+	if (r1_hops < r2_hops)
 		return 1;
-	}
 
-	if (r1_hops > r2_hops) {
-		*best_lpni = lpni2;
+	if (r1_hops > r2_hops)
 		return -1;
-	}
-
-	rc = lnet_compare_peers(lpni1, lpni2);
-	if (rc == 1) {
-		*best_lpni = lpni1;
-		return rc;
-	} else if (rc == -1) {
-		*best_lpni = lpni2;
-		return rc;
-	}
-
-	if (r1->lr_seq - r2->lr_seq <= 0) {
-		*best_lpni = lpni1;
-		return 1;
-	}
 
-	*best_lpni = lpni2;
-	return -1;
+	return 0;
 }
 
 static struct lnet_route *
@@ -1328,7 +1294,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		       struct lnet_route **prev_route,
 		       struct lnet_peer_ni **gwni)
 {
-	struct lnet_peer_ni *best_gw_ni = NULL;
+	struct lnet_peer_ni *lpni, *best_gw_ni = NULL;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
 	struct lnet_route *route;
@@ -1355,11 +1321,30 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (last_route->lr_seq - route->lr_seq < 0)
 			last_route = route;
 
-		rc = lnet_compare_routes(route, best_route, &best_gw_ni);
-		if (rc < 0)
+		rc = lnet_compare_routes(route, best_route);
+		if (rc == -1)
+			continue;
+
+		lpni = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY,
+						  route->lr_gateway,
+						  route->lr_lnet);
+		LASSERT(lpni);
+
+		if (rc == 1) {
+			best_route = route;
+			best_gw_ni = lpni;
+			continue;
+		}
+
+		rc = lnet_compare_gw_lpnis(lpni, best_gw_ni);
+		if (rc == -1)
 			continue;
 
-		best_route = route;
+		if (rc == 1 || route->lr_seq <= best_route->lr_seq) {
+			best_route = route;
+			best_gw_ni = lpni;
+			continue;
+		}
 	}
 
 	*prev_route = last_route;
-- 
1.8.3.1
