From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:45 -0500
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: rename variables in
	lnet_find_route_locked
In-Reply-To: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
References: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455549954-29532-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Chris Horn <hornc@cray.com>

From: Chris Horn <hornc@cray.com>

Rename several variables in lnet_find_route_locked to make
the code easier to understand. Broken out of patch 7857.

Signed-off-by: Chris Horn <hornc@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3679
Reviewed-on: http://review.whamcloud.com/7857
Reviewed-by: Cory Spitz <spitzcor@cray.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |   32 +++++++++++++-------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 8f16913..f023b0c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1135,9 +1135,9 @@ static lnet_peer_t *
 lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 {
 	lnet_remotenet_t *rnet;
-	lnet_route_t *rtr;
-	lnet_route_t *rtr_best;
-	lnet_route_t *rtr_last;
+	lnet_route_t *route;
+	lnet_route_t *best_route;
+	lnet_route_t *last_route;
 	struct lnet_peer *lp_best;
 	struct lnet_peer *lp;
 	int rc;
@@ -1151,14 +1151,14 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 		return NULL;
 
 	lp_best = NULL;
-	rtr_best = NULL;
-	rtr_last = NULL;
-	list_for_each_entry(rtr, &rnet->lrn_routes, lr_list) {
-		lp = rtr->lr_gateway;
+	best_route = NULL;
+	last_route = NULL;
+	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
+		lp = route->lr_gateway;
 
 		if (!lp->lp_alive || /* gateway is down */
 		    ((lp->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) &&
-		     rtr->lr_downis)) /* NI to target is down */
+		     route->lr_downis)) /* NI to target is down */
 			continue;
 
 		if (ni && lp->lp_ni != ni)
@@ -1168,21 +1168,21 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 			return lp;
 
 		if (!lp_best) {
-			rtr_best = rtr;
-			rtr_last = rtr;
+			best_route = route;
+			last_route = route;
 			lp_best = lp;
 			continue;
 		}
 
 		/* no protection on below fields, but it's harmless */
-		if (rtr_last->lr_seq - rtr->lr_seq < 0)
-			rtr_last = rtr;
+		if (last_route->lr_seq - route->lr_seq < 0)
+			last_route = route;
 
-		rc = lnet_compare_routes(rtr, rtr_best);
+		rc = lnet_compare_routes(route, best_route);
 		if (rc < 0)
 			continue;
 
-		rtr_best = rtr;
+		best_route = route;
 		lp_best = lp;
 	}
 
@@ -1191,8 +1191,8 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 	 * so we can round-robin all routers, it's race and inaccurate but
 	 * harmless and functional
 	 */
-	if (rtr_best)
-		rtr_best->lr_seq = rtr_last->lr_seq + 1;
+	if (best_route)
+		best_route->lr_seq = last_route->lr_seq + 1;
 	return lp_best;
 }
 
-- 
1.7.1
