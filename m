From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:03 -0400
Subject: [lustre-devel] [PATCH 24/42] lnet: Do not overwrite destination
 when routing
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

MR path selection in a routed environment is supposed to allow the
originator of a message to set the final destination NID. On a
multi-hop route, intermediate routers execute the same code path as
the message originator (i.e. the remote send cases). This causes
them to overwrite the destination NID when forwarding the message.

Check the msg_routing flag to determine whether we should set the
final destination NID (i.e. LNet peer NI).

A somewhat related issue is that because intermediate routers are not
selecting a destination lpni, they need to pick the next-hop lpni
based on the destination NID's remote net.

Fixes: 111c56a3c7e ("lnet: fix remote peer ni selection")
HPE-bug-id: LUS-8919
WC-bug-id: https://jira.whamcloud.com/browse/LU-13605
Lustre-commit: ec94d6f77b61fe ("LU-13605 lnet: Do not overwrite destination when routing")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/38731
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 102 +++++++++++++++++++++++++++--------------------
 1 file changed, 59 insertions(+), 43 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 7474d44..1c9fb41 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1830,52 +1830,73 @@ struct lnet_ni *
 	}
 
 	if (!route_found) {
-		/* we've already looked up the initial lpni using dst_nid */
-		lpni = sd->sd_best_lpni;
-		/* the peer tree must be in existence */
-		LASSERT(lpni && lpni->lpni_peer_net &&
-			lpni->lpni_peer_net->lpn_peer);
-		lp = lpni->lpni_peer_net->lpn_peer;
-
-		list_for_each_entry(lpn, &lp->lp_peer_nets, lpn_peer_nets) {
-			/* is this remote network reachable?  */
-			rnet = lnet_find_rnet_locked(lpn->lpn_net_id);
-			if (!rnet)
-				continue;
+		if (sd->sd_msg->msg_routing) {
+			/* If I'm routing this message then I need to find the
+			 * next hop based on the destination NID
+			 */
+			best_rnet = lnet_find_rnet_locked(LNET_NIDNET(sd->sd_dst_nid));
+			if (!best_rnet) {
+				CERROR("Unable to route message to %s - Route table may be misconfigured\n",
+				       libcfs_nid2str(sd->sd_dst_nid));
+				return -EHOSTUNREACH;
+			}
+		} else {
+			/* we've already looked up the initial lpni using
+			 * dst_nid
+			 */
+			lpni = sd->sd_best_lpni;
+			/* the peer tree must be in existence */
+			LASSERT(lpni && lpni->lpni_peer_net &&
+				lpni->lpni_peer_net->lpn_peer);
+			lp = lpni->lpni_peer_net->lpn_peer;
+
+			list_for_each_entry(lpn, &lp->lp_peer_nets,
+					    lpn_peer_nets) {
+				/* is this remote network reachable?  */
+				rnet = lnet_find_rnet_locked(lpn->lpn_net_id);
+				if (!rnet)
+					continue;
+
+				if (!best_lpn) {
+					best_lpn = lpn;
+					best_rnet = rnet;
+				}
+
+				if (best_lpn->lpn_seq <= lpn->lpn_seq)
+					continue;
 
-			if (!best_lpn) {
 				best_lpn = lpn;
 				best_rnet = rnet;
 			}
 
-			if (best_lpn->lpn_seq <= lpn->lpn_seq)
-				continue;
+			if (!best_lpn) {
+				CERROR("peer %s has no available nets\n",
+				       libcfs_nid2str(sd->sd_dst_nid));
+				return -EHOSTUNREACH;
+			}
 
-			best_lpn = lpn;
-			best_rnet = rnet;
-		}
+			sd->sd_best_lpni = lnet_find_best_lpni(sd->sd_best_ni,
+							       sd->sd_dst_nid,
+							       lp,
+							       best_lpn->lpn_net_id);
+			if (!sd->sd_best_lpni) {
+				CERROR("peer %s is unreachable\n",
+				       libcfs_nid2str(sd->sd_dst_nid));
+				return -EHOSTUNREACH;
+			}
 
-		if (!best_lpn) {
-			CERROR("peer %s has no available nets\n",
-			       libcfs_nid2str(sd->sd_dst_nid));
-			return -EHOSTUNREACH;
-		}
+			/* We're attempting to round robin over the remote peer
+			 * NI's so update the final destination we selected
+			 */
+			sd->sd_final_dst_lpni = sd->sd_best_lpni;
 
-		sd->sd_best_lpni = lnet_find_best_lpni(sd->sd_best_ni,
-						       sd->sd_dst_nid,
-						       lp,
-						       best_lpn->lpn_net_id);
-		if (!sd->sd_best_lpni) {
-			CERROR("peer %s is unreachable\n",
-			       libcfs_nid2str(sd->sd_dst_nid));
-			return -EHOSTUNREACH;
+			/* Increment the sequence number of the remote lpni so
+			 * we can round robin over the different interfaces of
+			 * the remote lpni
+			 */
+			sd->sd_best_lpni->lpni_seq++;
 		}
 
-		/* We're attempting to round robin over the remote peer
-		 * NI's so update the final destination we selected
-		 */
-		sd->sd_final_dst_lpni = sd->sd_best_lpni;
-
 		/* find the best route. Restrict the selection on the net of the
 		 * local NI if we've already picked the local NI to send from.
 		 * Otherwise, let's pick any route we can find and then find
@@ -1903,12 +1924,6 @@ struct lnet_ni *
 		gw = best_route->lr_gateway;
 		LASSERT(gw == gwni->lpni_peer_net->lpn_peer);
 		local_lnet = best_route->lr_lnet;
-
-		/* Increment the sequence number of the remote lpni so we
-		 * can round robin over the different interfaces of the
-		 * remote lpni
-		 */
-		sd->sd_best_lpni->lpni_seq++;
 	}
 
 	/* Discover this gateway if it hasn't already been discovered.
@@ -1945,7 +1960,8 @@ struct lnet_ni *
 	if (sd->sd_rtr_nid == LNET_NID_ANY) {
 		LASSERT(best_route && last_route);
 		best_route->lr_seq = last_route->lr_seq + 1;
-		best_lpn->lpn_seq++;
+		if (best_lpn)
+			best_lpn->lpn_seq++;
 	}
 
 	return 0;
-- 
1.8.3.1
