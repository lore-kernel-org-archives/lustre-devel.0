From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 26/34] LU-7734 lnet: Routing fixes part 2
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763587.32103.5037367646271689437.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Fix lnet_select_pathway() to handle the routing cases correctly.
The following general cases are handled:
. Non-MR directly connected
. Non-MR not directly connected
. MR Directly connected
. MR Not directly connected
  . No gateway
  . Gateway is non-mr
  . Gateway is mr

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: If2d16b797b94421e78a9f2a254a250a440f8b244
Reviewed-on: http://review.whamcloud.com/21167
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |  214 ++++++++++++++++++---------
 drivers/staging/lustre/lnet/lnet/peer.c     |   29 +++-
 2 files changed, 167 insertions(+), 76 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 58521b014ef3..12bc80d060e9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1145,6 +1145,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	__u32 seq;
 	int cpt, cpt2, rc;
 	bool routing;
+	bool routing2;
 	bool ni_is_pref;
 	bool preferred;
 	int best_credits;
@@ -1168,6 +1169,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	best_gw = NULL;
 	local_net = NULL;
 	routing = false;
+	routing2 = false;
 
 	seq = lnet_get_dlc_seq_locked();
 
@@ -1201,7 +1203,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	}
 
 	/*
-	 * STEP 1: first jab at determineing best_ni
+	 * STEP 1: first jab at determining best_ni
 	 * if src_nid is explicitly specified, then best_ni is already
 	 * pre-determiend for us. Otherwise we need to select the best
 	 * one to use later on
@@ -1215,17 +1217,122 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 				      libcfs_nid2str(src_nid));
 			return -EINVAL;
 		}
+	}
+
+	if (msg->msg_type == LNET_MSG_REPLY ||
+	    msg->msg_type == LNET_MSG_ACK ||
+	    !peer->lp_multi_rail) {
+		/*
+		 * for replies we want to respond on the same peer_ni we
+		 * received the message on if possible. If not, then pick
+		 * a peer_ni to send to
+		 *
+		 * if the peer is non-multi-rail then you want to send to
+		 * the dst_nid provided as well.
+		 *
+		 * It is expected to find the lpni using dst_nid, since we
+		 * created it earlier.
+		 */
+		best_lpni = lnet_find_peer_ni_locked(dst_nid);
+		if (best_lpni)
+			lnet_peer_ni_decref_locked(best_lpni);
 
-		if (best_ni->ni_net->net_id != LNET_NIDNET(dst_nid)) {
+		if (best_lpni && !lnet_get_net_locked(LNET_NIDNET(dst_nid))) {
+			/*
+			 * this lpni is not on a local network so we need
+			 * to route this reply.
+			 */
+			best_gw = lnet_find_route_locked(NULL,
+							 best_lpni->lpni_nid,
+							 rtr_nid);
+			if (best_gw) {
+				/*
+				 * RULE: Each node considers only the next-hop
+				 *
+				 * We're going to route the message,
+				 * so change the peer to the router.
+				 */
+				LASSERT(best_gw->lpni_peer_net);
+				LASSERT(best_gw->lpni_peer_net->lpn_peer);
+				peer = best_gw->lpni_peer_net->lpn_peer;
+
+				/*
+				 * if the router is not multi-rail
+				 * then use the best_gw found to send
+				 * the message to
+				 */
+				if (!peer->lp_multi_rail)
+					best_lpni = best_gw;
+				else
+					best_lpni = NULL;
+
+				routing = true;
+			} else {
+				best_lpni = NULL;
+			}
+		} else if (!best_lpni) {
 			lnet_net_unlock(cpt);
-			LCONSOLE_WARN("No route to %s via from %s\n",
-				      libcfs_nid2str(dst_nid),
-				      libcfs_nid2str(src_nid));
+			CERROR("unable to send msg_type %d to originating %s. Destination NID not in DB\n",
+			       msg->msg_type, libcfs_nid2str(dst_nid));
 			return -EINVAL;
 		}
-		goto pick_peer;
 	}
 
+	/*
+	 * if the peer is not MR capable, then we should always send to it
+	 * using the first NI in the NET we determined.
+	 */
+	if (!peer->lp_multi_rail) {
+		if (!best_lpni) {
+			lnet_net_unlock(cpt);
+			CERROR("no route to %s\n",
+			       libcfs_nid2str(dst_nid));
+			return -EHOSTUNREACH;
+		}
+
+		/* best ni could be set because src_nid was provided */
+		if (!best_ni) {
+			best_ni = lnet_net2ni_locked(
+				best_lpni->lpni_net->net_id, cpt);
+			if (!best_ni) {
+				lnet_net_unlock(cpt);
+				CERROR("no path to %s from net %s\n",
+				       libcfs_nid2str(best_lpni->lpni_nid),
+				       libcfs_net2str(best_lpni->lpni_net->net_id));
+				return -EHOSTUNREACH;
+			}
+		}
+	}
+
+	if (best_ni == the_lnet.ln_loni) {
+		/* No send credit hassles with LOLND */
+		lnet_ni_addref_locked(best_ni, cpt);
+		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
+		if (!msg->msg_routing)
+			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
+		msg->msg_target.nid = best_ni->ni_nid;
+		lnet_msg_commit(msg, cpt);
+		msg->msg_txni = best_ni;
+		lnet_net_unlock(cpt);
+
+		return LNET_CREDIT_OK;
+	}
+
+	/*
+	 * if we already found a best_ni because src_nid is specified and
+	 * best_lpni because we are replying to a message then just send
+	 * the message
+	 */
+	if (best_ni && best_lpni)
+		goto send;
+
+	/*
+	 * If we already found a best_ni because src_nid is specified then
+	 * pick the peer then send the message
+	 */
+	if (best_ni)
+		goto pick_peer;
+
 	/*
 	 * Decide whether we need to route to peer_ni.
 	 * Get the local net that I need to be on to be able to directly
@@ -1242,7 +1349,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			continue;
 
 		local_net = lnet_get_net_locked(peer_net->lpn_net_id);
-		if (!local_net) {
+		if (!local_net && !routing) {
 			struct lnet_peer_ni *net_gw;
 			/*
 			 * go through each peer_ni on that peer_net and
@@ -1263,14 +1370,11 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 
 				if (!best_gw) {
 					best_gw = net_gw;
-					best_lpni = lpni;
 				} else  {
 					rc = lnet_compare_peers(net_gw,
 								best_gw);
-					if (rc > 0) {
+					if (rc > 0)
 						best_gw = net_gw;
-						best_lpni = lpni;
-					}
 				}
 			}
 
@@ -1279,9 +1383,9 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 
 			local_net = lnet_get_net_locked
 					(LNET_NIDNET(best_gw->lpni_nid));
-			routing = true;
+			routing2 = true;
 		} else {
-			routing = false;
+			routing2 = false;
 			best_gw = NULL;
 		}
 
@@ -1342,12 +1446,17 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		}
 	}
 
-	/*
-	 * if the peer is not MR capable, then we should always send to it
-	 * using the first NI in the NET we determined.
-	 */
-	if (!peer->lp_multi_rail && local_net)
-		best_ni = lnet_net2ni_locked(local_net->net_id, cpt);
+	if (routing2) {
+		/*
+		 * RULE: Each node considers only the next-hop
+		 *
+		 * We're going to route the message, so change the peer to
+		 * the router.
+		 */
+		LASSERT(best_gw->lpni_peer_net);
+		LASSERT(best_gw->lpni_peer_net->lpn_peer);
+		peer = best_gw->lpni_peer_net->lpn_peer;
+	}
 
 	if (!best_ni) {
 		lnet_net_unlock(cpt);
@@ -1363,43 +1472,11 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 */
 	best_ni->ni_seq++;
 
-	if (routing)
-		goto send;
-
 pick_peer:
-	if (best_ni == the_lnet.ln_loni) {
-		/* No send credit hassles with LOLND */
-		lnet_ni_addref_locked(best_ni, cpt);
-		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
-		if (!msg->msg_routing)
-			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
-		msg->msg_target.nid = best_ni->ni_nid;
-		lnet_msg_commit(msg, cpt);
-		msg->msg_txni = best_ni;
-		lnet_net_unlock(cpt);
-
-		return LNET_CREDIT_OK;
-	}
-
-	if (msg->msg_type == LNET_MSG_REPLY ||
-	    msg->msg_type == LNET_MSG_ACK) {
-		/*
-		 * for replies we want to respond on the same peer_ni we
-		 * received the message on if possible. If not, then pick
-		 * a peer_ni to send to
-		 */
-		best_lpni = lnet_find_peer_ni_locked(dst_nid);
-		if (best_lpni) {
-			lnet_peer_ni_decref_locked(best_lpni);
-			goto send;
-		} else {
-			CDEBUG(D_NET,
-			       "unable to send msg_type %d to originating %s\n",
-			       msg->msg_type,
-			       libcfs_nid2str(dst_nid));
-		}
-	}
-
+	/*
+	 * At this point the best_ni is on a local network on which
+	 * the peer has a peer_ni as well
+	 */
 	peer_net = lnet_peer_get_net_locked(peer,
 					    best_ni->ni_net->net_id);
 	/*
@@ -1429,13 +1506,16 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			libcfs_nid2str(best_gw->lpni_nid),
 			lnet_msgtyp2str(msg->msg_type), msg->msg_len);
 
-		best_lpni = lnet_find_peer_ni_locked(dst_nid);
-		LASSERT(best_lpni);
-		lnet_peer_ni_decref_locked(best_lpni);
-
-		routing = true;
-
-		goto send;
+		routing2 = true;
+		/*
+		 * RULE: Each node considers only the next-hop
+		 *
+		 * We're going to route the message, so change the peer to
+		 * the router.
+		 */
+		LASSERT(best_gw->lpni_peer_net);
+		LASSERT(best_gw->lpni_peer_net->lpn_peer);
+		peer = best_gw->lpni_peer_net->lpn_peer;
 	} else if (!lnet_is_peer_net_healthy_locked(peer_net)) {
 		/*
 		 * this peer_net is unhealthy but we still have an opportunity
@@ -1459,6 +1539,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	lpni = NULL;
 	best_lpni_credits = INT_MIN;
 	preferred = false;
+	best_lpni = NULL;
 	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
 		/*
 		 * if this peer ni is not healthy just skip it, no point in
@@ -1513,19 +1594,14 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	}
 
 send:
+	routing = routing || routing2;
+
 	/*
 	 * Increment sequence number of the peer selected so that we
 	 * pick the next one in Round Robin.
 	 */
 	best_lpni->lpni_seq++;
 
-	/*
-	 * When routing the best gateway found acts as the best peer
-	 * NI to send to.
-	 */
-	if (routing)
-		best_lpni = best_gw;
-
 	/*
 	 * grab a reference on the peer_ni so it sticks around even if
 	 * we need to drop and relock the lnet_net_lock below.
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 9cecfb49db87..d757f4df1f39 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -225,11 +225,18 @@ lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
 }
 
 /* called with lnet_net_lock LNET_LOCK_EX held */
-static void
+static int
 lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
 {
 	struct lnet_peer_table *ptable = NULL;
 
+	/* don't remove a peer_ni if it's also a gateway */
+	if (lpni->lpni_rtr_refcount > 0) {
+		CERROR("Peer NI %s is a gateway. Can not delete it\n",
+		       libcfs_nid2str(lpni->lpni_nid));
+		return -EBUSY;
+	}
+
 	lnet_peer_remove_from_remote_list(lpni);
 
 	/* remove peer ni from the hash list. */
@@ -260,6 +267,8 @@ lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
 
 	/* decrement reference on peer */
 	lnet_peer_ni_decref_locked(lpni);
+
+	return 0;
 }
 
 void lnet_peer_uninit(void)
@@ -313,17 +322,22 @@ lnet_peer_tables_create(void)
 	return 0;
 }
 
-static void
+static int
 lnet_peer_del_locked(struct lnet_peer *peer)
 {
 	struct lnet_peer_ni *lpni = NULL, *lpni2;
+	int rc = 0, rc2 = 0;
 
 	lpni = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
 	while (lpni) {
 		lpni2 = lnet_get_next_peer_ni_locked(peer, NULL, lpni);
-		lnet_peer_ni_del_locked(lpni);
+		rc = lnet_peer_ni_del_locked(lpni);
+		if (rc != 0)
+			rc2 = rc;
 		lpni = lpni2;
 	}
+
+	return rc2;
 }
 
 static void
@@ -899,6 +913,7 @@ lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid)
 	lnet_nid_t local_nid;
 	struct lnet_peer *peer;
 	struct lnet_peer_ni *lpni;
+	int rc;
 
 	if (key_nid == LNET_NID_ANY)
 		return -EINVAL;
@@ -919,17 +934,17 @@ lnet_del_peer_ni_from_peer(lnet_nid_t key_nid, lnet_nid_t nid)
 		 * entire peer
 		 */
 		lnet_net_lock(LNET_LOCK_EX);
-		lnet_peer_del_locked(peer);
+		rc = lnet_peer_del_locked(peer);
 		lnet_net_unlock(LNET_LOCK_EX);
 
-		return 0;
+		return rc;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
-	lnet_peer_ni_del_locked(lpni);
+	rc = lnet_peer_ni_del_locked(lpni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	return 0;
+	return rc;
 }
 
 void
