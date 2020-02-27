From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:38 -0500
Subject: [lustre-devel] [PATCH 350/622] lnet: handle discovery off
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-351-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When discovery is turned off locally or when the peer either has
discovery off or doesn't support MR at all then degrade discovery
behavior to a standard ping. This will allow routers to continue
using discovery mechanism even if it's turned off.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11641
Lustre-commit: f9ad0d13b092 ("LU-11641 lnet: handle discovery off")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33620
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |   4 +
 net/lnet/lnet/lib-move.c      |  21 +++--
 net/lnet/lnet/peer.c          | 176 ++++++++++++++++++++++++++++++------------
 3 files changed, 144 insertions(+), 57 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 4dee7a9..09adfc3 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -863,6 +863,7 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 }
 
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
+bool lnet_is_discovery_disabled(struct lnet_peer *lp);
 bool lnet_peer_gw_discovery(struct lnet_peer *lp);
 
 static inline bool
@@ -874,6 +875,9 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 		return true;
 	if (lp->lp_state & LNET_PEER_NO_DISCOVERY)
 		return false;
+	/* if discovery is not enabled then no need to push */
+	if (lnet_peer_discovery_disabled)
+		return false;
 	if (lp->lp_node_seqno < atomic_read(&the_lnet.ln_ping_target_seqno))
 		return true;
 	return false;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index fff9fea..0ff1d38 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1773,6 +1773,11 @@ struct lnet_ni *
 		return 0;
 	}
 
+	if (!lnet_msg_discovery(msg) || lnet_peer_is_uptodate(peer)) {
+		lnet_peer_ni_decref_locked(lpni);
+		return 0;
+	}
+
 	rc = lnet_discover_peer_locked(lpni, cpt, false);
 	if (rc) {
 		lnet_peer_ni_decref_locked(lpni);
@@ -1802,6 +1807,7 @@ struct lnet_ni *
 			     struct lnet_peer_ni **gw_lpni,
 			     struct lnet_peer **gw_peer)
 {
+	int rc;
 	struct lnet_peer *gw;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
@@ -1831,12 +1837,11 @@ struct lnet_ni *
 	 * This means we might delay the message until discovery has
 	 * completed
 	 */
-	if (lnet_msg_discovery(sd->sd_msg) &&
-	    !lnet_peer_is_uptodate(gw)) {
-		sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
-		return lnet_initiate_peer_discovery(lpni, sd->sd_msg,
-						    sd->sd_rtr_nid, sd->sd_cpt);
-	}
+	sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
+	rc = lnet_initiate_peer_discovery(lpni, sd->sd_msg, sd->sd_rtr_nid,
+					  sd->sd_cpt);
+	if (rc)
+		return rc;
 
 	if (!sd->sd_best_ni) {
 		struct lnet_peer_net *lpeer;
@@ -2358,8 +2363,8 @@ struct lnet_ni *
 	 * trigger discovery.
 	 */
 	peer = lpni->lpni_peer_net->lpn_peer;
-	if (lnet_msg_discovery(msg) && !lnet_peer_is_uptodate(peer)) {
-		rc = lnet_initiate_peer_discovery(lpni, msg, rtr_nid, cpt);
+	rc = lnet_initiate_peer_discovery(lpni, msg, rtr_nid, cpt);
+	if (rc) {
 		lnet_peer_ni_decref_locked(lpni);
 		lnet_net_unlock(cpt);
 		return rc;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 2097a97..41a6180 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1444,7 +1444,10 @@ struct lnet_peer_net *
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
-	unsigned int flags = 0;
+	/* Assume peer is Multi-Rail capable and let discovery find out
+	 * otherwise.
+	 */
+	unsigned int flags = LNET_PEER_MULTI_RAIL;
 	int rc = 0;
 
 	if (nid == LNET_NID_ANY) {
@@ -1742,9 +1745,34 @@ struct lnet_peer_ni *
 	return lpni;
 }
 
+bool
+lnet_is_discovery_disabled_locked(struct lnet_peer *lp)
+{
+	if (lnet_peer_discovery_disabled)
+		return true;
+
+	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL) ||
+	    (lp->lp_state & LNET_PEER_NO_DISCOVERY)) {
+		return true;
+	}
+
+	return false;
+}
+
 /*
  * Peer Discovery
  */
+bool
+lnet_is_discovery_disabled(struct lnet_peer *lp)
+{
+	bool rc = false;
+
+	spin_lock(&lp->lp_lock);
+	rc = lnet_is_discovery_disabled_locked(lp);
+	spin_unlock(&lp->lp_lock);
+
+	return rc;
+}
 
 bool
 lnet_peer_gw_discovery(struct lnet_peer *lp)
@@ -1777,13 +1805,8 @@ struct lnet_peer_ni *
 			    LNET_PEER_FORCE_PING |
 			    LNET_PEER_FORCE_PUSH)) {
 		rc = false;
-	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
-		rc = true;
 	} else if (lp->lp_state & LNET_PEER_REDISCOVER) {
-		if (lnet_peer_discovery_disabled)
-			rc = true;
-		else
-			rc = false;
+		rc = false;
 	} else if (lnet_peer_needs_push(lp)) {
 		rc = false;
 	} else if (lp->lp_state & LNET_PEER_DISCOVERED) {
@@ -2095,6 +2118,9 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		if (lnet_peer_is_uptodate(lp))
 			break;
 		lnet_peer_queue_for_discovery(lp);
+
+		if (lnet_is_discovery_disabled(lp))
+			break;
 		/*
 		 * if caller requested a non-blocking operation then
 		 * return immediately. Once discovery is complete then the
@@ -2133,7 +2159,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		rc = lp->lp_dc_error;
 	else if (!block)
 		CDEBUG(D_NET, "non-blocking discovery\n");
-	else if (!lnet_peer_is_uptodate(lp))
+	else if (!lnet_peer_is_uptodate(lp) && !lnet_is_discovery_disabled(lp))
 		goto again;
 
 	CDEBUG(D_NET, "peer %s NID %s: %d. %s\n",
@@ -2205,6 +2231,34 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	}
 
 	/*
+	 * Only enable the multi-rail feature on the peer if both sides of
+	 * the connection have discovery on
+	 */
+	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL) {
+		CDEBUG(D_NET, "Peer %s has Multi-Rail feature enabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state |= LNET_PEER_MULTI_RAIL;
+	} else {
+		CDEBUG(D_NET, "Peer %s has Multi-Rail feature disabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state &= ~LNET_PEER_MULTI_RAIL;
+	}
+
+	/* The peer may have discovery disabled at its end. Set
+	 * NO_DISCOVERY as appropriate.
+	 */
+	if ((pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) &&
+	    !lnet_peer_discovery_disabled) {
+		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
+	} else {
+		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
+		       libcfs_nid2str(lp->lp_primary_nid));
+		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
+	}
+
+	/*
 	 * Update the MULTI_RAIL flag based on the reply. If the peer
 	 * was configured with DLC then the setting should match what
 	 * DLC put in.
@@ -2216,8 +2270,16 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 			CWARN("Reply says %s is Multi-Rail, DLC says not\n",
 			      libcfs_nid2str(lp->lp_primary_nid));
 		} else {
-			lp->lp_state |= LNET_PEER_MULTI_RAIL;
-			lnet_peer_clr_non_mr_pref_nids(lp);
+			/* if discovery is disabled then we don't want to
+			 * update the state of the peer. All we'll do is
+			 * update the peer_nis which were reported back in
+			 * the initial ping
+			 */
+
+			if (!lnet_is_discovery_disabled_locked(lp)) {
+				lp->lp_state |= LNET_PEER_MULTI_RAIL;
+				lnet_peer_clr_non_mr_pref_nids(lp);
+			}
 		}
 	} else if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
@@ -2238,20 +2300,6 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lp->lp_data_nnis = pbuf->pb_info.pi_nnis;
 
 	/*
-	 * The peer may have discovery disabled at its end. Set
-	 * NO_DISCOVERY as appropriate.
-	 */
-	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY)) {
-		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
-		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
-	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
-		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
-		lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
-	}
-
-	/*
 	 * Check for truncation of the Reply. Clear PING_SENT and set
 	 * PING_FAILED to trigger a retry.
 	 */
@@ -2284,8 +2332,9 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	}
 
 	/* We're happy with the state of the data in the buffer. */
-	CDEBUG(D_NET, "peer %s data present %u\n",
-	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_peer_seqno);
+	CDEBUG(D_NET, "peer %s data present %u. state = 0x%x\n",
+	       libcfs_nid2str(lp->lp_primary_nid), lp->lp_peer_seqno,
+	       lp->lp_state);
 	if (lp->lp_state & LNET_PEER_DATA_PRESENT)
 		lnet_ping_buffer_decref(lp->lp_data);
 	else
@@ -2517,6 +2566,14 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 			delnis[ndelnis++] = curnis[i];
 	}
 
+	/* If we get here and the discovery is disabled then we don't want
+	 * to add or delete any NIs. We just updated the ones we have some
+	 * information on, and call it a day
+	 */
+	rc = 0;
+	if (lnet_is_discovery_disabled(lp))
+		goto out;
+
 	for (i = 0; i < naddnis; i++) {
 		rc = lnet_peer_add_nid(lp, addnis[i].ns_nid, flags);
 		if (rc) {
@@ -2561,7 +2618,8 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	kfree(addnis);
 	kfree(delnis);
 	lnet_ping_buffer_decref(pbuf);
-	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	CDEBUG(D_NET, "peer %s (%p): %d\n", libcfs_nid2str(lp->lp_primary_nid),
+	       lp, rc);
 
 	if (rc) {
 		spin_lock(&lp->lp_lock);
@@ -2634,6 +2692,19 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	return 0;
 }
 
+static bool lnet_is_nid_in_ping_info(lnet_nid_t nid,
+				     struct lnet_ping_info *pinfo)
+{
+	int i;
+
+	for (i = 0; i < pinfo->pi_nnis; i++) {
+		if (pinfo->pi_ni[i].ns_nid == nid)
+			return true;
+	}
+
+	return false;
+}
+
 /*
  * Update a peer using the data received.
  */
@@ -2701,7 +2772,17 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 		rc = lnet_peer_set_primary_nid(lp, nid, flags);
 		if (!rc)
 			rc = lnet_peer_merge_data(lp, pbuf);
-	} else if (lp->lp_primary_nid == nid) {
+	/* if the primary nid of the peer is present in the ping info returned
+	 * from the peer, but it's not the local primary peer we have
+	 * cached and discovery is disabled, then we don't want to update
+	 * our local peer info, by adding or removing NIDs, we just want
+	 * to update the status of the nids that we currently have
+	 * recorded in that peer.
+	 */
+	} else if (lp->lp_primary_nid == nid ||
+		   (lnet_is_nid_in_ping_info(lp->lp_primary_nid,
+					     &pbuf->pb_info) &&
+		    lnet_is_discovery_disabled(lp))) {
 		rc = lnet_peer_merge_data(lp, pbuf);
 	} else {
 		lpni = lnet_find_peer_ni_locked(nid);
@@ -2718,13 +2799,24 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 			struct lnet_peer *new_lp;
 
 			new_lp = lpni->lpni_peer_net->lpn_peer;
+			/* if lp has discovery/MR enabled that means new_lp
+			 * should have discovery/MR enabled as well, since
+			 * it's the same peer, which we're about to merge
+			 */
+			if (!(lp->lp_state & LNET_PEER_NO_DISCOVERY))
+				new_lp->lp_state &= ~LNET_PEER_NO_DISCOVERY;
+			if (lp->lp_state & LNET_PEER_MULTI_RAIL)
+				new_lp->lp_state |= LNET_PEER_MULTI_RAIL;
+
 			rc = lnet_peer_set_primary_data(new_lp, pbuf);
 			lnet_consolidate_routes_locked(lp, new_lp);
 			lnet_peer_ni_decref_locked(lpni);
 		}
 	}
 out:
-	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	CDEBUG(D_NET, "peer %s(%p): %d. state = 0x%x\n",
+	       libcfs_nid2str(lp->lp_primary_nid), lp, rc,
+	       lp->lp_state);
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
 	spin_lock(&lp->lp_lock);
@@ -2941,7 +3033,8 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	LNetMDUnlink(lp->lp_push_mdh);
 	LNetInvalidateMDHandle(&lp->lp_push_mdh);
 fail_error:
-	CDEBUG(D_NET, "peer %s: %d\n", libcfs_nid2str(lp->lp_primary_nid), rc);
+	CDEBUG(D_NET, "peer %s(%p): %d\n",
+	       libcfs_nid2str(lp->lp_primary_nid), lp, rc);
 	/*
 	 * The errors that get us here are considered hard errors and
 	 * cause Discovery to terminate. So we clear PUSH_SENT, but do
@@ -2985,19 +3078,6 @@ static int lnet_peer_discovered(struct lnet_peer *lp)
 	return 0;
 }
 
-/*
- * Mark the peer as to be rediscovered.
- */
-static int lnet_peer_rediscover(struct lnet_peer *lp)
-__must_hold(&lp->lp_lock)
-{
-	lp->lp_state |= LNET_PEER_REDISCOVER;
-	lp->lp_state &= ~LNET_PEER_DISCOVERING;
-
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
-
-	return 0;
-}
 
 /*
  * Discovering this peer is taking too long. Cancel any Ping or Push
@@ -3170,8 +3250,8 @@ static int lnet_peer_discovery(void *arg)
 			 * forcing a Ping or Push.
 			 */
 			spin_lock(&lp->lp_lock);
-			CDEBUG(D_NET, "peer %s state %#x\n",
-			       libcfs_nid2str(lp->lp_primary_nid),
+			CDEBUG(D_NET, "peer %s(%p) state %#x\n",
+			       libcfs_nid2str(lp->lp_primary_nid), lp,
 			       lp->lp_state);
 			if (lp->lp_state & LNET_PEER_DATA_PRESENT)
 				rc = lnet_peer_data_present(lp);
@@ -3183,16 +3263,14 @@ static int lnet_peer_discovery(void *arg)
 				rc = lnet_peer_send_ping(lp);
 			else if (lp->lp_state & LNET_PEER_FORCE_PUSH)
 				rc = lnet_peer_send_push(lp);
-			else if (lnet_peer_discovery_disabled)
-				rc = lnet_peer_rediscover(lp);
 			else if (!(lp->lp_state & LNET_PEER_NIDS_UPTODATE))
 				rc = lnet_peer_send_ping(lp);
 			else if (lnet_peer_needs_push(lp))
 				rc = lnet_peer_send_push(lp);
 			else
 				rc = lnet_peer_discovered(lp);
-			CDEBUG(D_NET, "peer %s state %#x rc %d\n",
-			       libcfs_nid2str(lp->lp_primary_nid),
+			CDEBUG(D_NET, "peer %s(%p) state %#x rc %d\n",
+			       libcfs_nid2str(lp->lp_primary_nid), lp,
 			       lp->lp_state, rc);
 			spin_unlock(&lp->lp_lock);
 
-- 
1.8.3.1
