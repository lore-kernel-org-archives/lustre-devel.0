From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:54 -0400
Subject: [lustre-devel] [PATCH 15/22] lnet: set route aliveness properly
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

In the case when the discover is toggled from on to off, the route
aliveness might become stale due to not updating the route->lr_alive
variable correctly. It will get updated once the gateway is pinged.
However, there is a period of max alive_router_check_interval where
the route can be down.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13472
Lustre-commit: eee4358d9d467 ("LU-13472 lnet: set route aliveness properly")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38323
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 903d027..c0578d9 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -513,8 +513,10 @@ bool lnet_is_route_alive(struct lnet_route *route)
 		 * on the gateway we assume this is intentional and we mark the
 		 * gateway as multi-hop
 		 */
-		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
+		list_for_each_entry(route, &lp->lp_routes, lr_gwlist) {
+			lnet_set_route_aliveness(route, true);
 			lnet_set_route_hop_type(lp, route);
+		}
 
 		return;
 	}
-- 
1.8.3.1
