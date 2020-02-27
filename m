From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:31 -0500
Subject: [lustre-devel] [PATCH 343/622] lnet: MR aware gateway selection
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-344-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When selecting a route use the Multi-Rail Selection algorithm to
select the best available peer_ni of the best route. The selected
peer_ni can then be used to send the message or to discover it
if the gateway peer needs discovering.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11378
Lustre-commit: 11d8380d5ad0 ("LU-11378 lnet: MR aware gateway selection")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33188
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 353 +++++++++++++++++++++++------------------------
 1 file changed, 171 insertions(+), 182 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index e214a95..054ae48 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1117,7 +1117,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 }
 
-#if 0
 static int
 lnet_compare_peers(struct lnet_peer_ni *p1, struct lnet_peer_ni *p2)
 {
@@ -1135,53 +1134,189 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	return 0;
 }
-#endif
+
+static struct lnet_peer_ni *
+lnet_select_peer_ni(struct lnet_ni *best_ni, lnet_nid_t dst_nid,
+		    struct lnet_peer *peer,
+		    struct lnet_peer_net *peer_net)
+{
+	/* Look at the peer NIs for the destination peer that connect
+	 * to the chosen net. If a peer_ni is preferred when using the
+	 * best_ni to communicate, we use that one. If there is no
+	 * preferred peer_ni, or there are multiple preferred peer_ni,
+	 * the available transmit credits are used. If the transmit
+	 * credits are equal, we round-robin over the peer_ni.
+	 */
+	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_peer_ni *best_lpni = NULL;
+	int best_lpni_credits = INT_MIN;
+	bool preferred = false;
+	bool ni_is_pref;
+	int best_lpni_healthv = 0;
+	int lpni_healthv;
+
+	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
+		/* if the best_ni we've chosen aleady has this lpni
+		 * preferred, then let's use it
+		 */
+		if (best_ni) {
+			ni_is_pref = lnet_peer_is_pref_nid_locked(lpni,
+								  best_ni->ni_nid);
+			CDEBUG(D_NET, "%s ni_is_pref = %d\n",
+			       libcfs_nid2str(best_ni->ni_nid), ni_is_pref);
+		} else {
+			ni_is_pref = false;
+		}
+
+		lpni_healthv = atomic_read(&lpni->lpni_healthv);
+
+		if (best_lpni)
+			CDEBUG(D_NET, "%s c:[%d, %d], s:[%d, %d]\n",
+			       libcfs_nid2str(lpni->lpni_nid),
+			       lpni->lpni_txcredits, best_lpni_credits,
+			       lpni->lpni_seq, best_lpni->lpni_seq);
+
+		/* pick the healthiest peer ni */
+		if (lpni_healthv < best_lpni_healthv) {
+			continue;
+		} else if (lpni_healthv > best_lpni_healthv) {
+			best_lpni_healthv = lpni_healthv;
+		/* if this is a preferred peer use it */
+		} else if (!preferred && ni_is_pref) {
+			preferred = true;
+		} else if (preferred && !ni_is_pref) {
+			/* this is not the preferred peer so let's ignore
+			 * it.
+			 */
+			continue;
+		} else if (lpni->lpni_txcredits < best_lpni_credits) {
+			/* We already have a peer that has more credits
+			 * available than this one. No need to consider
+			 * this peer further.
+			 */
+			continue;
+		} else if (lpni->lpni_txcredits == best_lpni_credits) {
+			/* The best peer found so far and the current peer
+			 * have the same number of available credits let's
+			 * make sure to select between them using Round
+			 * Robin
+			 */
+			if (best_lpni) {
+				if (best_lpni->lpni_seq <= lpni->lpni_seq)
+					continue;
+			}
+		}
+
+		best_lpni = lpni;
+		best_lpni_credits = lpni->lpni_txcredits;
+	}
+
+	/* if we still can't find a peer ni then we can't reach it */
+	if (!best_lpni) {
+		u32 net_id = (peer_net) ? peer_net->lpn_net_id :
+			LNET_NIDNET(dst_nid);
+		CDEBUG(D_NET, "no peer_ni found on peer net %s\n",
+		       libcfs_net2str(net_id));
+		return NULL;
+	}
+
+	CDEBUG(D_NET, "sd_best_lpni = %s\n",
+	       libcfs_nid2str(best_lpni->lpni_nid));
+
+	return best_lpni;
+}
+
+/* Prerequisite: the best_ni should already be set in the sd */
+static inline struct lnet_peer_ni *
+lnet_find_best_lpni_on_net(struct lnet_send_data *sd, struct lnet_peer *peer,
+			   u32 net_id)
+{
+	struct lnet_peer_net *peer_net;
+
+	/* The gateway is Multi-Rail capable so now we must select the
+	 * proper peer_ni
+	 */
+	peer_net = lnet_peer_get_net_locked(peer, net_id);
+
+	if (!peer_net) {
+		CERROR("gateway peer %s has no NI on net %s\n",
+		       libcfs_nid2str(peer->lp_primary_nid),
+		       libcfs_net2str(net_id));
+		return NULL;
+	}
+
+	return lnet_select_peer_ni(sd->sd_best_ni, sd->sd_dst_nid,
+				   peer, peer_net);
+}
 
 static int
-lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
+lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2,
+		    struct lnet_peer_ni **best_lpni)
 {
-	/* TODO re-implement gateway comparison
-	struct lnet_peer_ni *p1 = r1->lr_gateway;
-	struct lnet_peer_ni *p2 = r2->lr_gateway;
-	*/
 	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
 	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
-	/*int rc;*/
+	struct lnet_peer *lp1 = r1->lr_gateway;
+	struct lnet_peer *lp2 = r2->lr_gateway;
+	struct lnet_peer_ni *lpni1;
+	struct lnet_peer_ni *lpni2;
+	struct lnet_send_data sd;
+	int rc;
+
+	sd.sd_best_ni = NULL;
+	sd.sd_dst_nid = LNET_NID_ANY;
+	lpni1 = lnet_find_best_lpni_on_net(&sd, lp1, r1->lr_lnet);
+	lpni2 = lnet_find_best_lpni_on_net(&sd, lp2, r2->lr_lnet);
+	LASSERT(lpni1 && lpni2);
 
-	if (r1->lr_priority < r2->lr_priority)
+	if (r1->lr_priority < r2->lr_priority) {
+		*best_lpni = lpni1;
 		return 1;
+	}
 
-	if (r1->lr_priority > r2->lr_priority)
+	if (r1->lr_priority > r2->lr_priority) {
+		*best_lpni = lpni2;
 		return -1;
+	}
 
-	if (r1_hops < r2_hops)
+	if (r1_hops < r2_hops) {
+		*best_lpni = lpni1;
 		return 1;
+	}
 
-	if (r1_hops > r2_hops)
+	if (r1_hops > r2_hops) {
+		*best_lpni = lpni2;
 		return -1;
+	}
 
-	/*
-	rc = lnet_compare_peers(p1, p2);
-	if (rc)
+	rc = lnet_compare_peers(lpni1, lpni2);
+	if (rc == 1) {
+		*best_lpni = lpni1;
+		return rc;
+	} else if (rc == -1) {
+		*best_lpni = lpni2;
 		return rc;
-	*/
+	}
 
-	if (r1->lr_seq - r2->lr_seq <= 0)
+	if (r1->lr_seq - r2->lr_seq <= 0) {
+		*best_lpni = lpni1;
 		return 1;
+	}
 
+	*best_lpni = lpni2;
 	return -1;
 }
 
-/* TODO: lnet_find_route_locked() needs to be reimplemented */
 static struct lnet_route *
 lnet_find_route_locked(struct lnet_net *net, u32 remote_net,
-		       lnet_nid_t rtr_nid, struct lnet_route **prev_route)
+		       lnet_nid_t rtr_nid, struct lnet_route **prev_route,
+		       struct lnet_peer_ni **gwni)
 {
-	struct lnet_remotenet *rnet;
-	struct lnet_route *route;
+	struct lnet_peer_ni *best_gw_ni = NULL;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
+	struct lnet_remotenet *rnet;
 	struct lnet_peer *lp_best;
+	struct lnet_route *route;
 	struct lnet_peer *lp;
 	int rc;
 
@@ -1206,14 +1341,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			best_route = route;
 			last_route = route;
 			lp_best = lp;
-			continue;
 		}
 
 		/* no protection on below fields, but it's harmless */
 		if (last_route->lr_seq - route->lr_seq < 0)
 			last_route = route;
 
-		rc = lnet_compare_routes(route, best_route);
+		rc = lnet_compare_routes(route, best_route, &best_gw_ni);
 		if (rc < 0)
 			continue;
 
@@ -1222,6 +1356,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	*prev_route = last_route;
+	*gwni = best_gw_ni;
 
 	return best_route;
 }
@@ -1507,123 +1642,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return rc;
 }
 
-static struct lnet_peer_ni *
-lnet_select_peer_ni(struct lnet_send_data *sd, struct lnet_peer *peer,
-		    struct lnet_peer_net *peer_net)
-{
-	/*
-	 * Look@the peer NIs for the destination peer that connect
-	 * to the chosen net. If a peer_ni is preferred when using the
-	 * best_ni to communicate, we use that one. If there is no
-	 * preferred peer_ni, or there are multiple preferred peer_ni,
-	 * the available transmit credits are used. If the transmit
-	 * credits are equal, we round-robin over the peer_ni.
-	 */
-	struct lnet_peer_ni *lpni = NULL;
-	struct lnet_peer_ni *best_lpni = NULL;
-	struct lnet_ni *best_ni = sd->sd_best_ni;
-	lnet_nid_t dst_nid = sd->sd_dst_nid;
-	int best_lpni_credits = INT_MIN;
-	bool preferred = false;
-	bool ni_is_pref;
-	int best_lpni_healthv = 0;
-	int lpni_healthv;
-
-	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
-		/* if the best_ni we've chosen aleady has this lpni
-		 * preferred, then let's use it
-		 */
-		ni_is_pref = lnet_peer_is_pref_nid_locked(lpni,
-							  best_ni->ni_nid);
-
-		lpni_healthv = atomic_read(&lpni->lpni_healthv);
-
-		CDEBUG(D_NET, "%s ni_is_pref = %d\n",
-		       libcfs_nid2str(best_ni->ni_nid), ni_is_pref);
-
-		if (best_lpni)
-			CDEBUG(D_NET, "%s c:[%d, %d], s:[%d, %d]\n",
-			       libcfs_nid2str(lpni->lpni_nid),
-			       lpni->lpni_txcredits, best_lpni_credits,
-			       lpni->lpni_seq, best_lpni->lpni_seq);
-
-		/* pick the healthiest peer ni */
-		if (lpni_healthv < best_lpni_healthv) {
-			continue;
-		} else if (lpni_healthv > best_lpni_healthv) {
-			best_lpni_healthv = lpni_healthv;
-		/* if this is a preferred peer use it */
-		} else if (!preferred && ni_is_pref) {
-			preferred = true;
-		} else if (preferred && !ni_is_pref) {
-			/*
-			 * this is not the preferred peer so let's ignore
-			 * it.
-			 */
-			continue;
-		} else if (lpni->lpni_txcredits < best_lpni_credits) {
-			/*
-			 * We already have a peer that has more credits
-			 * available than this one. No need to consider
-			 * this peer further.
-			 */
-			continue;
-		} else if (lpni->lpni_txcredits == best_lpni_credits) {
-			/*
-			 * The best peer found so far and the current peer
-			 * have the same number of available credits let's
-			 * make sure to select between them using Round
-			 * Robin
-			 */
-			if (best_lpni) {
-				if (best_lpni->lpni_seq <= lpni->lpni_seq)
-					continue;
-			}
-		}
-
-		best_lpni = lpni;
-		best_lpni_credits = lpni->lpni_txcredits;
-	}
-
-	/* if we still can't find a peer ni then we can't reach it */
-	if (!best_lpni) {
-		u32 net_id = peer_net ? peer_net->lpn_net_id :
-					LNET_NIDNET(dst_nid);
-
-		CDEBUG(D_NET, "no peer_ni found on peer net %s\n",
-		       libcfs_net2str(net_id));
-		return NULL;
-	}
-
-	CDEBUG(D_NET, "sd_best_lpni = %s\n",
-	       libcfs_nid2str(best_lpni->lpni_nid));
-
-	return best_lpni;
-}
-
-/* Prerequisite: the best_ni should already be set in the sd
- */
-static inline struct lnet_peer_ni *
-lnet_find_best_lpni_on_net(struct lnet_send_data *sd, struct lnet_peer *peer,
-			   u32 net_id)
-{
-	struct lnet_peer_net *peer_net;
-
-	/* The gateway is Multi-Rail capable so now we must select the
-	 * proper peer_ni
-	 */
-	peer_net = lnet_peer_get_net_locked(peer, net_id);
-
-	if (!peer_net) {
-		CERROR("gateway peer %s has no NI on net %s\n",
-		       libcfs_nid2str(peer->lp_primary_nid),
-		       libcfs_net2str(net_id));
-		return NULL;
-	}
-
-	return lnet_select_peer_ni(sd, peer, peer_net);
-}
-
 static inline void
 lnet_set_non_mr_pref_nid(struct lnet_send_data *sd)
 {
@@ -1791,29 +1809,34 @@ struct lnet_ni *
 	lnet_nid_t src_nid = sd->sd_src_nid;
 
 	best_route = lnet_find_route_locked(NULL, LNET_NIDNET(dst_nid),
-					    sd->sd_rtr_nid, &last_route);
+					    sd->sd_rtr_nid, &last_route,
+					    &lpni);
 	if (!best_route) {
 		CERROR("no route to %s from %s\n",
 		       libcfs_nid2str(dst_nid), libcfs_nid2str(src_nid));
 		return -EHOSTUNREACH;
 	}
 
+	if (!lpni) {
+		CERROR("Internal Error. Route expected to %s from %s\n",
+		       libcfs_nid2str(dst_nid),
+		       libcfs_nid2str(src_nid));
+		return -EFAULT;
+	}
+
 	gw = best_route->lr_gateway;
-	*gw_peer = gw;
+	LASSERT(gw == lpni->lpni_peer_net->lpn_peer);
 
 	/* Discover this gateway if it hasn't already been discovered.
 	 * This means we might delay the message until discovery has
 	 * completed
 	 */
-#if 0
-	/* TODO: disable discovey for now */
 	if (lnet_msg_discovery(sd->sd_msg) &&
-	    !lnet_peer_is_uptodate(*gw_peer)) {
+	    !lnet_peer_is_uptodate(gw)) {
 		sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
-		return lnet_initiate_peer_discovery(gw, sd->sd_msg,
+		return lnet_initiate_peer_discovery(lpni, sd->sd_msg,
 						    sd->sd_rtr_nid, sd->sd_cpt);
 	}
-#endif
 
 	if (!sd->sd_best_ni) {
 		struct lnet_peer_net *lpeer;
@@ -1830,42 +1853,8 @@ struct lnet_ni *
 		return -EFAULT;
 	}
 
-	/* if gw is MR let's find its best peer_ni
-	 */
-	if (lnet_peer_is_multi_rail(gw)) {
-		lpni = lnet_find_best_lpni_on_net(sd, gw,
-						  sd->sd_best_ni->ni_net->net_id);
-		/* We've already verified that the gw has an NI on that
-		 * desired net, but we're not finding it. Something is
-		 * wrong.
-		 */
-		if (!lpni) {
-			CERROR("Internal Error. Route expected to %s from %s\n",
-			       libcfs_nid2str(dst_nid),
-			       libcfs_nid2str(src_nid));
-			return -EFAULT;
-		}
-	} else {
-		struct lnet_peer_net *lpn;
-
-		lpn = lnet_peer_get_net_locked(gw, best_route->lr_lnet);
-		if (!lpn) {
-			CERROR("Internal Error. Route expected to %s from %s\n",
-			       libcfs_nid2str(dst_nid),
-			       libcfs_nid2str(src_nid));
-			return -EFAULT;
-		}
-		lpni = list_entry(lpn->lpn_peer_nis.next, struct lnet_peer_ni,
-				  lpni_peer_nis);
-		if (!lpni) {
-			CERROR("Internal Error. Route expected to %s from %s\n",
-			       libcfs_nid2str(dst_nid),
-			       libcfs_nid2str(src_nid));
-			return -EFAULT;
-		}
-	}
-
 	*gw_lpni = lpni;
+	*gw_peer = gw;
 
 	/* increment the route sequence number since now we're sure we're
 	 * going to use it
-- 
1.8.3.1
