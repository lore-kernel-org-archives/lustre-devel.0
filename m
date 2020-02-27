From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:07 -0500
Subject: [lustre-devel] [PATCH 559/622] lnet: Prefer route specified by
 rtr_nid
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-560-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Restore an optimization that was initially added under LU-11413. For
routed REPLY and ACK we should preferably use the same router from
which the GET/PUT was receieved.

Cray-bug-id: LUS-8008
WC-bug-id: https://jira.whamcloud.com/browse/LU-12646
Lustre-commit: ca8958189198 ("LU-12646 lnet: Prefer route specified by rtr_nid")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35737
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 131 +++++++++++++++++++++++++++--------------------
 net/lnet/lnet/lib-msg.c  |   4 --
 2 files changed, 76 insertions(+), 59 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index ca0009c..6a2833c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1330,7 +1330,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 static struct lnet_route *
 lnet_find_route_locked(struct lnet_net *net, u32 remote_net,
-		       lnet_nid_t rtr_nid, struct lnet_route **prev_route,
+		       struct lnet_route **prev_route,
 		       struct lnet_peer_ni **gwni)
 {
 	struct lnet_peer_ni *best_gw_ni = NULL;
@@ -1342,10 +1342,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_peer *lp;
 	int rc;
 
-	/*
-	 * If @rtr_nid is not LNET_NID_ANY, return the gateway with
-	 * rtr_nid nid, otherwise find the best gateway I can use
-	 */
 	rnet = lnet_find_rnet_locked(remote_net);
 	if (!rnet)
 		return NULL;
@@ -1652,13 +1648,14 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	rc = lnet_post_send_locked(msg, 0);
 	if (!rc)
-		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s try# %d\n",
+		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) %s : %s try# %d\n",
 		       libcfs_nid2str(msg->msg_hdr.src_nid),
 		       libcfs_nid2str(msg->msg_txni->ni_nid),
 		       libcfs_nid2str(sd->sd_src_nid),
 		       libcfs_nid2str(msg->msg_hdr.dest_nid),
 		       libcfs_nid2str(sd->sd_dst_nid),
 		       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+		       libcfs_nid2str(sd->sd_rtr_nid),
 		       lnet_msgtyp2str(msg->msg_type), msg->msg_retry_count);
 
 	return rc;
@@ -1829,70 +1826,91 @@ struct lnet_ni *
 			     struct lnet_peer **gw_peer)
 {
 	int rc;
+	u32 local_lnet;
 	struct lnet_peer *gw;
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_net *best_lpn = NULL;
 	struct lnet_remotenet *rnet;
-	struct lnet_route *best_route;
-	struct lnet_route *last_route;
+	struct lnet_route *best_route = NULL;
+	struct lnet_route *last_route = NULL;
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_peer_ni *gwni = NULL;
 	lnet_nid_t src_nid = sd->sd_src_nid;
 
-	/* we've already looked up the initial lpni using dst_nid */
-	lpni = sd->sd_best_lpni;
-	/* the peer tree must be in existence */
-	LASSERT(lpni && lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer);
-	lp = lpni->lpni_peer_net->lpn_peer;
+	/* If a router nid was specified then we are replying to a GET or
+	 * sending an ACK. In this case we use the gateway associated with the
+	 * specified router nid.
+	 */
+	if (sd->sd_rtr_nid != LNET_NID_ANY) {
+		gwni = lnet_find_peer_ni_locked(sd->sd_rtr_nid);
+		if (!gwni) {
+			CERROR("No peer NI for gateway %s\n",
+			       libcfs_nid2str(sd->sd_rtr_nid));
+			return -EHOSTUNREACH;
+		}
+		gw = gwni->lpni_peer_net->lpn_peer;
+		lnet_peer_ni_decref_locked(gwni);
+		local_lnet = LNET_NIDNET(sd->sd_rtr_nid);
+	} else {
+		/* we've already looked up the initial lpni using dst_nid */
+		lpni = sd->sd_best_lpni;
+		/* the peer tree must be in existence */
+		LASSERT(lpni && lpni->lpni_peer_net &&
+			lpni->lpni_peer_net->lpn_peer);
+		lp = lpni->lpni_peer_net->lpn_peer;
+
+		list_for_each_entry(lpn, &lp->lp_peer_nets, lpn_peer_nets) {
+			/* is this remote network reachable?  */
+			rnet = lnet_find_rnet_locked(lpn->lpn_net_id);
+			if (!rnet)
+				continue;
 
-	list_for_each_entry(lpn, &lp->lp_peer_nets, lpn_peer_nets) {
-		/* is this remote network reachable?  */
-		rnet = lnet_find_rnet_locked(lpn->lpn_net_id);
-		if (!rnet)
-			continue;
+			if (!best_lpn)
+				best_lpn = lpn;
+
+			if (best_lpn->lpn_seq <= lpn->lpn_seq)
+				continue;
 
-		if (!best_lpn)
 			best_lpn = lpn;
+		}
 
-		if (best_lpn->lpn_seq <= lpn->lpn_seq)
-			continue;
+		if (!best_lpn) {
+			CERROR("peer %s has no available nets\n",
+			       libcfs_nid2str(sd->sd_dst_nid));
+			return -EHOSTUNREACH;
+		}
 
-		best_lpn = lpn;
-	}
+		sd->sd_best_lpni = lnet_find_best_lpni_on_net(sd, lp,
+							      best_lpn->lpn_net_id);
+		if (!sd->sd_best_lpni) {
+			CERROR("peer %s down\n",
+			       libcfs_nid2str(sd->sd_dst_nid));
+			return -EHOSTUNREACH;
+		}
 
-	if (!best_lpn) {
-		CERROR("peer %s has no available nets\n",
-		       libcfs_nid2str(sd->sd_dst_nid));
-		return -EHOSTUNREACH;
-	}
+		best_route = lnet_find_route_locked(NULL, best_lpn->lpn_net_id,
+						    &last_route, &gwni);
+		if (!best_route) {
+			CERROR("no route to %s from %s\n",
+			       libcfs_nid2str(dst_nid),
+			       libcfs_nid2str(src_nid));
+			return -EHOSTUNREACH;
+		}
 
-	sd->sd_best_lpni = lnet_find_best_lpni_on_net(sd, lp,
-						      best_lpn->lpn_net_id);
-	if (!sd->sd_best_lpni) {
-		CERROR("peer %s down\n", libcfs_nid2str(sd->sd_dst_nid));
-		return -EHOSTUNREACH;
-	}
+		if (!gwni) {
+			CERROR("Internal Error. Route expected to %s from %s\n",
+			       libcfs_nid2str(dst_nid),
+			       libcfs_nid2str(src_nid));
+			return -EFAULT;
+		}
 
-	best_route = lnet_find_route_locked(NULL, best_lpn->lpn_net_id,
-					    sd->sd_rtr_nid, &last_route,
-					    &gwni);
-	if (!best_route) {
-		CERROR("no route to %s from %s\n",
-		       libcfs_nid2str(dst_nid), libcfs_nid2str(src_nid));
-		return -EHOSTUNREACH;
-	}
+		gw = best_route->lr_gateway;
+		LASSERT(gw == gwni->lpni_peer_net->lpn_peer);
+		local_lnet = best_route->lr_lnet;
 
-	if (!gwni) {
-		CERROR("Internal Error. Route expected to %s from %s\n",
-		       libcfs_nid2str(dst_nid),
-		       libcfs_nid2str(src_nid));
-		return -EFAULT;
 	}
 
-	gw = best_route->lr_gateway;
-	LASSERT(gw == gwni->lpni_peer_net->lpn_peer);
-
 	/* Discover this gateway if it hasn't already been discovered.
 	 * This means we might delay the message until discovery has
 	 * completed
@@ -1906,14 +1924,15 @@ struct lnet_ni *
 	if (!sd->sd_best_ni) {
 		struct lnet_peer_net *lpeer;
 
-		lpeer = lnet_peer_get_net_locked(gw, best_route->lr_lnet);
+		lpeer = lnet_peer_get_net_locked(gw, local_lnet);
 		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL, gw, lpeer,
 							       sd->sd_md_cpt,
 							       true);
 	}
+
 	if (!sd->sd_best_ni) {
 		CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
-		       libcfs_net2str(best_route->lr_lnet),
+		       libcfs_net2str(local_lnet),
 		       libcfs_nid2str(sd->sd_src_nid));
 		return -EFAULT;
 	}
@@ -1924,9 +1943,11 @@ struct lnet_ni *
 	/* increment the sequence numbers since now we're sure we're
 	 * going to use this path
 	 */
-	LASSERT(best_route && last_route);
-	best_route->lr_seq = last_route->lr_seq + 1;
-	best_lpn->lpn_seq++;
+	if (sd->sd_rtr_nid == LNET_NID_ANY) {
+		LASSERT(best_route && last_route);
+		best_route->lr_seq = last_route->lr_seq + 1;
+		best_lpn->lpn_seq++;
+	}
 
 	return 0;
 }
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index d74ff53..86ac692 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -397,10 +397,6 @@
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
 		msg->msg_hdr.msg.ack.mlength = cpu_to_le32(msg->msg_ev.mlength);
 
-		/*
-		 * NB: we probably want to use NID of msg::msg_from as 3rd
-		 * parameter (router NID) if it's routed message
-		 */
 		rc = lnet_send(msg->msg_ev.target.nid, msg, msg->msg_from);
 
 		lnet_net_lock(cpt);
-- 
1.8.3.1
