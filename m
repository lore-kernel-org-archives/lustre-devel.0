From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:25 -0500
Subject: [lustre-devel] [PATCH 577/622] lnet: Avoid extra lnet_remotenet
 lookup
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-578-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

We can keep track of the lnet_remotenet object associated with the
"best" lnet_peer_net, and pass that lnet_remotenet directly to
lnet_find_route_locked().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12756
Lustre-commit: 3812c54b9ca3 ("LU-12756 lnet: Avoid extra lnet_remotenet lookup")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36536
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 45975d6..03d629d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1324,23 +1324,18 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static struct lnet_route *
-lnet_find_route_locked(struct lnet_net *net, u32 remote_net,
+lnet_find_route_locked(struct lnet_remotenet *rnet,
 		       struct lnet_route **prev_route,
 		       struct lnet_peer_ni **gwni)
 {
 	struct lnet_peer_ni *best_gw_ni = NULL;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
-	struct lnet_remotenet *rnet;
 	struct lnet_peer *lp_best;
 	struct lnet_route *route;
 	struct lnet_peer *lp;
 	int rc;
 
-	rnet = lnet_find_rnet_locked(remote_net);
-	if (!rnet)
-		return NULL;
-
 	lp_best = NULL;
 	best_route = NULL;
 	last_route = NULL;
@@ -1832,7 +1827,7 @@ struct lnet_ni *
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_net *best_lpn = NULL;
-	struct lnet_remotenet *rnet;
+	struct lnet_remotenet *rnet, *best_rnet = NULL;
 	struct lnet_route *best_route = NULL;
 	struct lnet_route *last_route = NULL;
 	struct lnet_peer_ni *lpni = NULL;
@@ -1867,13 +1862,16 @@ struct lnet_ni *
 			if (!rnet)
 				continue;
 
-			if (!best_lpn)
+			if (!best_lpn) {
 				best_lpn = lpn;
+				best_rnet = rnet;
+			}
 
 			if (best_lpn->lpn_seq <= lpn->lpn_seq)
 				continue;
 
 			best_lpn = lpn;
+			best_rnet = rnet;
 		}
 
 		if (!best_lpn) {
@@ -1892,8 +1890,8 @@ struct lnet_ni *
 			return -EHOSTUNREACH;
 		}
 
-		best_route = lnet_find_route_locked(NULL, best_lpn->lpn_net_id,
-						    &last_route, &gwni);
+		best_route = lnet_find_route_locked(best_rnet, &last_route,
+						    &gwni);
 		if (!best_route) {
 			CERROR("no route to %s from %s\n",
 			       libcfs_nid2str(dst_nid),
-- 
1.8.3.1
