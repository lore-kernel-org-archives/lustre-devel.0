From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:18 -0500
Subject: [lustre-devel] [PATCH 330/622] lnet: Discover routers on first use
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-331-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Discover routers on first use. This brings the behavior when
interacting with routers in line with when dealing with normal
peers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11292
Lustre-commit: c7f8215d74a2 ("LU-11292 lnet: Discover routers on first use")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33182
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 101 +++++++++++++++++++++++++++++++----------------
 1 file changed, 67 insertions(+), 34 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 75049ec..e080580 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1224,7 +1224,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 static struct lnet_peer_ni *
 lnet_find_route_locked(struct lnet_net *net, u32 remote_net,
-		       lnet_nid_t rtr_nid)
+		       lnet_nid_t rtr_nid, struct lnet_route **use_route,
+		       struct lnet_route **prev_route)
 {
 	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
@@ -1276,13 +1277,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		lpni_best = lp;
 	}
 
-	/*
-	 * set sequence number on the best router to the latest sequence + 1
-	 * so we can round-robin all routers, it's race and inaccurate but
-	 * harmless and functional
-	 */
-	if (best_route)
-		best_route->lr_seq = last_route->lr_seq + 1;
+	if (best_route) {
+		*use_route = best_route;
+		*prev_route = last_route;
+	}
 	return lpni_best;
 }
 
@@ -1798,16 +1796,52 @@ struct lnet_ni *
 }
 
 static int
+lnet_initiate_peer_discovery(struct lnet_peer_ni *lpni,
+			     struct lnet_msg *msg, lnet_nid_t rtr_nid,
+			     int cpt)
+{
+	struct lnet_peer *peer;
+	lnet_nid_t primary_nid;
+	int rc;
+
+	lnet_peer_ni_addref_locked(lpni);
+
+	rc = lnet_discover_peer_locked(lpni, cpt, false);
+	if (rc) {
+		lnet_peer_ni_decref_locked(lpni);
+		return rc;
+	}
+	/* The peer may have changed. */
+	peer = lpni->lpni_peer_net->lpn_peer;
+	/* queue message and return */
+	msg->msg_rtr_nid_param = rtr_nid;
+	msg->msg_sending = 0;
+	msg->msg_txpeer = NULL;
+	spin_lock(&peer->lp_lock);
+	list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
+	spin_unlock(&peer->lp_lock);
+	lnet_peer_ni_decref_locked(lpni);
+	primary_nid = peer->lp_primary_nid;
+
+	CDEBUG(D_NET, "msg %p delayed. %s pending discovery\n",
+	       msg, libcfs_nid2str(primary_nid));
+
+	return LNET_DC_WAIT;
+}
+
+static int
 lnet_handle_find_routed_path(struct lnet_send_data *sd,
 			     lnet_nid_t dst_nid,
 			     struct lnet_peer_ni **gw_lpni,
 			     struct lnet_peer **gw_peer)
 {
+	struct lnet_route *best_route = NULL;
+	struct lnet_route *last_route = NULL;
 	struct lnet_peer_ni *gw;
 	lnet_nid_t src_nid = sd->sd_src_nid;
 
 	gw = lnet_find_route_locked(NULL, LNET_NIDNET(dst_nid),
-				    sd->sd_rtr_nid);
+				    sd->sd_rtr_nid, &best_route, &last_route);
 	if (!gw) {
 		CERROR("no route to %s from %s\n",
 		       libcfs_nid2str(dst_nid), libcfs_nid2str(src_nid));
@@ -1820,6 +1854,17 @@ struct lnet_ni *
 
 	*gw_peer = gw->lpni_peer_net->lpn_peer;
 
+	/* Discover this gateway if it hasn't already been discovered.
+	 * This means we might delay the message until discovery has
+	 * completed
+	 */
+	if (lnet_msg_discovery(sd->sd_msg) &&
+	    !lnet_peer_is_uptodate(*gw_peer)) {
+		sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
+		return lnet_initiate_peer_discovery(gw, sd->sd_msg,
+						    sd->sd_rtr_nid, sd->sd_cpt);
+	}
+
 	if (!sd->sd_best_ni)
 		sd->sd_best_ni =
 			lnet_find_best_ni_on_spec_net(NULL, *gw_peer,
@@ -1853,6 +1898,12 @@ struct lnet_ni *
 
 	*gw_lpni = gw;
 
+	/* increment the route sequence number since now we're sure we're
+	 * going to use it
+	 */
+	LASSERT(best_route && last_route);
+	best_route->lr_seq = last_route->lr_seq + 1;
+
 	return 0;
 }
 
@@ -1889,7 +1940,7 @@ struct lnet_ni *
 
 	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
 					  &gw_peer);
-	if (rc < 0)
+	if (rc)
 		return rc;
 
 	if (sd->sd_send_case & NMR_DST)
@@ -2165,6 +2216,8 @@ struct lnet_ni *
 			CERROR("Can't send response to %s. No route available\n",
 			       libcfs_nid2str(sd->sd_dst_nid));
 			return -EHOSTUNREACH;
+		} else if (rc > 0) {
+			return rc;
 		}
 
 		sd->sd_best_lpni = gw;
@@ -2192,7 +2245,7 @@ struct lnet_ni *
 	 */
 	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
 					  &gw_peer);
-	if (rc < 0)
+	if (rc)
 		return rc;
 
 	sd->sd_send_case &= ~LOCAL_DST;
@@ -2228,7 +2281,7 @@ struct lnet_ni *
 	 */
 	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
 					  &gw_peer);
-	if (rc < 0)
+	if (rc)
 		return rc;
 
 	/* set the best_ni we've chosen as the preferred one for
@@ -2348,30 +2401,10 @@ struct lnet_ni *
 	 */
 	peer = lpni->lpni_peer_net->lpn_peer;
 	if (lnet_msg_discovery(msg) && !lnet_peer_is_uptodate(peer)) {
-		lnet_nid_t primary_nid;
-
-		rc = lnet_discover_peer_locked(lpni, cpt, false);
-		if (rc) {
-			lnet_peer_ni_decref_locked(lpni);
-			lnet_net_unlock(cpt);
-			return rc;
-		}
-		/* The peer may have changed. */
-		peer = lpni->lpni_peer_net->lpn_peer;
-		/* queue message and return */
-		msg->msg_rtr_nid_param = rtr_nid;
-		msg->msg_sending = 0;
-		spin_lock(&peer->lp_lock);
-		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
-		spin_unlock(&peer->lp_lock);
+		rc = lnet_initiate_peer_discovery(lpni, msg, rtr_nid, cpt);
 		lnet_peer_ni_decref_locked(lpni);
-		primary_nid = peer->lp_primary_nid;
 		lnet_net_unlock(cpt);
-
-		CDEBUG(D_NET, "%s pending discovery\n",
-		       libcfs_nid2str(primary_nid));
-
-		return LNET_DC_WAIT;
+		return rc;
 	}
 	lnet_peer_ni_decref_locked(lpni);
 
-- 
1.8.3.1
