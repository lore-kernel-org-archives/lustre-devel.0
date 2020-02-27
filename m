From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:26 -0500
Subject: [lustre-devel] [PATCH 578/622] lnet: Remove unused vars in
 lnet_find_route_locked
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-579-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The lp and lp_best variables are not needed in
lnet_find_route_locked().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12756
Lustre-commit: b129f7b1f76a ("LU-12756 lnet: Remove unused vars in lnet_find_route_locked")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36620
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 03d629d..b7990c9 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1331,24 +1331,18 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_peer_ni *best_gw_ni = NULL;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
-	struct lnet_peer *lp_best;
 	struct lnet_route *route;
-	struct lnet_peer *lp;
 	int rc;
 
-	lp_best = NULL;
 	best_route = NULL;
 	last_route = NULL;
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
-		lp = route->lr_gateway;
-
 		if (!lnet_is_route_alive(route))
 			continue;
 
-		if (!lp_best) {
+		if (!best_route) {
 			best_route = route;
 			last_route = route;
-			lp_best = lp;
 			best_gw_ni = lnet_find_best_lpni_on_net(NULL,
 								LNET_NID_ANY,
 								route->lr_gateway,
@@ -1366,7 +1360,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			continue;
 
 		best_route = route;
-		lp_best = lp;
 	}
 
 	*prev_route = last_route;
-- 
1.8.3.1
