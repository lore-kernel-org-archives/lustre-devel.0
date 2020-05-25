From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:05 -0400
Subject: [lustre-devel] [PATCH 28/45] lnet: restrict gateway selection
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

This patch fixes a conflict between
LU-13026 lnet: MR selection of gateway ni
and
LU-12919 lnet: Fix source specified route selection

LU-12919 patch relied on lnet_find_best_lpni_on_net() to restrict
lpni selection on a specific network. However, it is necessary
to allow lpni selection on any network if the src net is not
specified. LU-13026 removed the restriction imposed by
lnet_find_best_lpni_on_net(), which broke the restriction
on the source net selection in some configuration setups.

This patch renames lnet_find_best_lpni_on_net() to
lnet_find_best_lpni(). If passed a peer_net it will find the
best lpni on the peer_net or return NULL if none is available.
If passed 'any' net, then it'll find the best reachable lpni
on any available net.

Fixes: 66aa587df71 ("lnet: MR selection of gateway ni")
Fixes: c3efd008790 ("lnet: Fix source specified route selection")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13461
Lustre-commit: ceb92c5512bad ("LU-13461 lnet: restrict gateway selection")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38298
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 91 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 64 insertions(+), 27 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 4eaaa5f..cf134b5 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1143,6 +1143,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 static struct lnet_peer_ni *
 lnet_select_peer_ni(struct lnet_ni *best_ni, lnet_nid_t dst_nid,
 		    struct lnet_peer *peer,
+		    struct lnet_peer_ni *best_lpni,
 		    struct lnet_peer_net *peer_net)
 {
 	/* Look at the peer NIs for the destination peer that connect
@@ -1153,11 +1154,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * credits are equal, we round-robin over the peer_ni.
 	 */
 	struct lnet_peer_ni *lpni = NULL;
-	struct lnet_peer_ni *best_lpni = NULL;
-	int best_lpni_credits = INT_MIN;
+	int best_lpni_credits =  (best_lpni) ? best_lpni->lpni_txcredits :
+					       INT_MIN;
+	int best_lpni_healthv = (best_lpni) ?
+				atomic_read(&best_lpni->lpni_healthv) : 0;
 	bool preferred = false;
 	bool ni_is_pref;
-	int best_lpni_healthv = 0;
 	int lpni_healthv;
 
 	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
@@ -1231,19 +1233,43 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return best_lpni;
 }
 
-/* Prerequisite: the best_ni should already be set in the sd */
+/* Prerequisite: the best_ni should already be set in the sd
+ * Find the best lpni.
+ * If the net id is provided then restrict lpni selection on
+ * that particular net.
+ * Otherwise find any reachable lpni. When dealing with an MR
+ * gateway and it has multiple lpnis which we can use
+ * we want to select the best one from the list of reachable
+ * ones.
+ */
 static inline struct lnet_peer_ni *
-lnet_find_best_lpni_on_net(struct lnet_ni *lni, lnet_nid_t dst_nid,
-			   struct lnet_peer *peer, u32 net_id)
+lnet_find_best_lpni(struct lnet_ni *lni, lnet_nid_t dst_nid,
+		    struct lnet_peer *peer, u32 net_id)
 {
 	struct lnet_peer_net *peer_net;
+	u32 any_net = LNET_NIDNET(LNET_NID_ANY);
 
-	/* The gateway is Multi-Rail capable so now we must select the
-	 * proper peer_ni
-	 */
+	/* find the best_lpni on any local network */
+	if (net_id == any_net) {
+		struct lnet_peer_ni *best_lpni = NULL;
+		struct lnet_peer_net *lpn;
+
+		list_for_each_entry(lpn, &peer->lp_peer_nets, lpn_peer_nets) {
+			/* no net specified find any reachable peer ni */
+			if (!lnet_islocalnet_locked(lpn->lpn_net_id))
+				continue;
+			best_lpni = lnet_select_peer_ni(lni, dst_nid, peer,
+							best_lpni, lpn);
+		}
+
+		return best_lpni;
+	}
+	/* restrict on the specified net */
 	peer_net = lnet_peer_get_net_locked(peer, net_id);
+	if (peer_net)
+		return lnet_select_peer_ni(lni, dst_nid, peer, NULL, peer_net);
 
-	return lnet_select_peer_ni(lni, dst_nid, peer, peer_net);
+	return NULL;
 }
 
 /* Compare route priorities and hop counts */
@@ -1279,6 +1305,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_route *route;
 	int rc;
 
+	CDEBUG(D_NET, "Looking up a route to %s, from %s\n",
+	       libcfs_net2str(rnet->lrn_net), libcfs_net2str(src_net));
+
 	best_route = NULL;
 	last_route = NULL;
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
@@ -1290,15 +1319,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * the best interface available.
 		 */
 		if (!best_route) {
-			lpni = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY,
-							  route->lr_gateway,
-							  src_net);
+			lpni = lnet_find_best_lpni(NULL, LNET_NID_ANY,
+						   route->lr_gateway,
+						   src_net);
 			if (lpni) {
 				best_route = route;
 				last_route = route;
 				best_gw_ni = lpni;
 			} else {
-				CERROR("Gateway %s does not have a peer NI on net %s\n",
+				CDEBUG(D_NET,
+				       "Gateway %s does not have a peer NI on net %s\n",
 				       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
 				       libcfs_net2str(src_net));
 			}
@@ -1313,11 +1343,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (rc == -1)
 			continue;
 
-		lpni = lnet_find_best_lpni_on_net(NULL, LNET_NID_ANY,
-						  route->lr_gateway,
-						  src_net);
+		lpni = lnet_find_best_lpni(NULL, LNET_NID_ANY,
+					   route->lr_gateway,
+					   src_net);
+		/* restrict the lpni on the src_net if specified */
 		if (!lpni) {
-			CERROR("Gateway %s does not have a peer NI on net %s\n",
+			CDEBUG(D_NET,
+			       "Gateway %s does not have a peer NI on net %s\n",
 			       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
 			       libcfs_net2str(src_net));
 			continue;
@@ -1794,7 +1826,12 @@ struct lnet_ni *
 	struct lnet_route *last_route = NULL;
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_peer_ni *gwni = NULL;
-	lnet_nid_t src_nid = sd->sd_src_nid;
+	lnet_nid_t src_nid = (sd->sd_src_nid != LNET_NID_ANY) ? sd->sd_src_nid :
+			      sd->sd_best_ni ? sd->sd_best_ni->ni_nid :
+			      LNET_NID_ANY;
+
+	CDEBUG(D_NET, "using src nid %s for route restriction\n",
+	       libcfs_nid2str(src_nid));
 
 	/* If a router nid was specified then we are replying to a GET or
 	 * sending an ACK. In this case we use the gateway associated with the
@@ -1842,12 +1879,12 @@ struct lnet_ni *
 			return -EHOSTUNREACH;
 		}
 
-		sd->sd_best_lpni = lnet_find_best_lpni_on_net(sd->sd_best_ni,
-							      sd->sd_dst_nid,
-							      lp,
-							      best_lpn->lpn_net_id);
+		sd->sd_best_lpni = lnet_find_best_lpni(sd->sd_best_ni,
+						       sd->sd_dst_nid,
+						       lp,
+						       best_lpn->lpn_net_id);
 		if (!sd->sd_best_lpni) {
-			CERROR("peer %s down\n",
+			CERROR("peer %s is unreachable\n",
 			       libcfs_nid2str(sd->sd_dst_nid));
 			return -EHOSTUNREACH;
 		}
@@ -2176,9 +2213,9 @@ struct lnet_ni *
 					lnet_msg_discovery(sd->sd_msg));
 	if (sd->sd_best_ni) {
 		sd->sd_best_lpni =
-		  lnet_find_best_lpni_on_net(sd->sd_best_ni, sd->sd_dst_nid,
-					     sd->sd_peer,
-					     sd->sd_best_ni->ni_net->net_id);
+		  lnet_find_best_lpni(sd->sd_best_ni, sd->sd_dst_nid,
+				      sd->sd_peer,
+				      sd->sd_best_ni->ni_net->net_id);
 
 		/* if we're successful in selecting a peer_ni on the local
 		 * network, then send to it. Otherwise fall through and
-- 
1.8.3.1
