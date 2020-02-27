From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:43 -0500
Subject: [lustre-devel] [PATCH 355/622] lnet: look up MR peers routes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-356-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

An MR peer can have multiple interfaces some of which we might
have a route to. The primary NID of the peer might not necessarily
specify a NID we have a route to. When looking up a route, we must
iterate over all the nets the peer is on and select the one which
we can route to. Taking into consideration the peer can exist on
multiple routed networks we also have a simple round robin algorithm
to iterate over all the networks we can reach the peer on.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12053
Lustre-commit: 52eef8179743 ("LU-12053 lnet: look up MR peers routes")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34625
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  3 ++
 net/lnet/lnet/lib-move.c       | 73 ++++++++++++++++++++++++++++++++++--------
 2 files changed, 62 insertions(+), 14 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 8c9ae9e..da5b860 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -747,6 +747,9 @@ struct lnet_peer_net {
 	/* time of last router net check attempt */
 	time64_t		lpn_rtrcheck_timestamp;
 
+	/* selection sequence number */
+	u32			lpn_seq;
+
 	/* reference count */
 	atomic_t		lpn_refcount;
 };
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index e93284b..f0804e1 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1809,21 +1809,60 @@ struct lnet_ni *
 {
 	int rc;
 	struct lnet_peer *gw;
+	struct lnet_peer *lp;
+	struct lnet_peer_net *lpn;
+	struct lnet_peer_net *best_lpn = NULL;
+	struct lnet_remotenet *rnet;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
 	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_peer_ni *gwni = NULL;
 	lnet_nid_t src_nid = sd->sd_src_nid;
 
-	best_route = lnet_find_route_locked(NULL, LNET_NIDNET(dst_nid),
+	/* we've already looked up the initial lpni using dst_nid */
+	lpni = sd->sd_best_lpni;
+	/* the peer tree must be in existence */
+	LASSERT(lpni && lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer);
+	lp = lpni->lpni_peer_net->lpn_peer;
+
+	list_for_each_entry(lpn, &lp->lp_peer_nets, lpn_peer_nets) {
+		/* is this remote network reachable?  */
+		rnet = lnet_find_rnet_locked(lpn->lpn_net_id);
+		if (!rnet)
+			continue;
+
+		if (!best_lpn)
+			best_lpn = lpn;
+
+		if (best_lpn->lpn_seq <= lpn->lpn_seq)
+			continue;
+
+		best_lpn = lpn;
+	}
+
+	if (!best_lpn) {
+		CERROR("peer %s has no available nets\n",
+		       libcfs_nid2str(sd->sd_dst_nid));
+		return -EHOSTUNREACH;
+	}
+
+	sd->sd_best_lpni = lnet_find_best_lpni_on_net(sd, lp,
+						      best_lpn->lpn_net_id);
+	if (!sd->sd_best_lpni) {
+		CERROR("peer %s down\n", libcfs_nid2str(sd->sd_dst_nid));
+		return -EHOSTUNREACH;
+	}
+
+	best_route = lnet_find_route_locked(NULL, best_lpn->lpn_net_id,
 					    sd->sd_rtr_nid, &last_route,
-					    &lpni);
+					    &gwni);
 	if (!best_route) {
 		CERROR("no route to %s from %s\n",
 		       libcfs_nid2str(dst_nid), libcfs_nid2str(src_nid));
 		return -EHOSTUNREACH;
 	}
 
-	if (!lpni) {
+	if (!gwni) {
 		CERROR("Internal Error. Route expected to %s from %s\n",
 		       libcfs_nid2str(dst_nid),
 		       libcfs_nid2str(src_nid));
@@ -1831,14 +1870,14 @@ struct lnet_ni *
 	}
 
 	gw = best_route->lr_gateway;
-	LASSERT(gw == lpni->lpni_peer_net->lpn_peer);
+	LASSERT(gw == gwni->lpni_peer_net->lpn_peer);
 
 	/* Discover this gateway if it hasn't already been discovered.
 	 * This means we might delay the message until discovery has
 	 * completed
 	 */
 	sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
-	rc = lnet_initiate_peer_discovery(lpni, sd->sd_msg, sd->sd_rtr_nid,
+	rc = lnet_initiate_peer_discovery(gwni, sd->sd_msg, sd->sd_rtr_nid,
 					  sd->sd_cpt);
 	if (rc)
 		return rc;
@@ -1858,14 +1897,15 @@ struct lnet_ni *
 		return -EFAULT;
 	}
 
-	*gw_lpni = lpni;
+	*gw_lpni = gwni;
 	*gw_peer = gw;
 
-	/* increment the route sequence number since now we're sure we're
-	 * going to use it
+	/* increment the sequence numbers since now we're sure we're
+	 * going to use this path
 	 */
 	LASSERT(best_route && last_route);
 	best_route->lr_seq = last_route->lr_seq + 1;
+	best_lpn->lpn_seq++;
 
 	return 0;
 }
@@ -2208,11 +2248,11 @@ struct lnet_ni *
 	if (rc != PASS_THROUGH)
 		return rc;
 
-	/* TODO; One possible enhancement is to run the selection
-	 * algorithm on the peer. However for remote peers the credits are
-	 * not decremented, so we'll be basically going over the peer NIs
-	 * in round robin. An MR router will run the selection algorithm
-	 * on the next-hop interfaces.
+	/* Now that we must route to the destination, we must consider the
+	 * MR case, where the destination has multiple interfaces, some of
+	 * which we can route to and others we do not. For this reason we
+	 * need to select the destination which we can route to and if
+	 * there are multiple, we need to round robin.
 	 */
 	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
 					  &gw_peer);
@@ -2455,8 +2495,13 @@ struct lnet_ni *
 	LASSERT(!msg->msg_tx_committed);
 
 	rc = lnet_select_pathway(src_nid, dst_nid, msg, rtr_nid);
-	if (rc < 0)
+	if (rc < 0) {
+		if (rc == -EHOSTUNREACH)
+			msg->msg_health_status = LNET_MSG_STATUS_REMOTE_ERROR;
+		else
+			msg->msg_health_status = LNET_MSG_STATUS_LOCAL_ERROR;
 		return rc;
+	}
 
 	if (rc == LNET_CREDIT_OK)
 		lnet_ni_send(msg->msg_txni, msg);
-- 
1.8.3.1
