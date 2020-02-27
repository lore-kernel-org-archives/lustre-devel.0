From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:19 -0500
Subject: [lustre-devel] [PATCH 331/622] lnet: use peer for gateway
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-332-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

The routing code uses peer_ni for a gateway. However with Mulit-Rail
a gateway could have multiple interfaces on several different
networks. Instead of using a single peer_ni as the gateway we should
be using the peer and let the MR selection code select the best
peer_ni to send to.

This patch moves the gateway from peer to peer_ni. Much of the
code needs to be rewritten in the following patches to account
for that change. This patch disables the routing features by
disabling the code to add/delete routes.

The asymmetric routing detection feature is also modified to
use the MR routing

WC-bug-id: https://jira.whamcloud.com/browse/LU-11298
Lustre-commit: 53f7b8b7a228 ("LU-11298 lnet: use peer for gateway")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33183
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  19 +-
 include/linux/lnet/lib-types.h |  46 +--
 net/lnet/lnet/lib-move.c       | 215 +++++++-----
 net/lnet/lnet/peer.c           |  17 +-
 net/lnet/lnet/router.c         | 720 ++---------------------------------------
 net/lnet/lnet/router_proc.c    |  31 +-
 6 files changed, 230 insertions(+), 818 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 534be2a..80f6f8c 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -92,15 +92,12 @@
 
 static inline int lnet_is_route_alive(struct lnet_route *route)
 {
-	/* gateway is down */
-	if (!route->lr_gateway->lpni_alive)
-		return 0;
-	/* no NI status, assume it's alive */
-	if ((route->lr_gateway->lpni_ping_feats &
-	     LNET_PING_FEAT_NI_STATUS) == 0)
-		return 1;
-	/* has NI status, check # down NIs */
-	return route->lr_downis == 0;
+	/* TODO re-implement gateway alive indication */
+	CDEBUG(D_NET, "TODO: reimplement routing. gateway = %s\n",
+	       route->lr_gateway ?
+		libcfs_nid2str(route->lr_gateway->lp_primary_nid) :
+		"undefined");
+	return 1;
 }
 
 static inline int lnet_is_wire_handle_none(struct lnet_handle_wire *wh)
@@ -402,9 +399,9 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline int
-lnet_isrouter(struct lnet_peer_ni *lp)
+lnet_isrouter(struct lnet_peer_ni *lpni)
 {
-	return lp->lpni_rtr_refcount ? 1 : 0;
+	return lpni->lpni_peer_net->lpn_peer->lp_rtr_refcount ? 1 : 0;
 }
 
 static inline void
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index b1a6f6a..31fe22a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -534,20 +534,21 @@ struct lnet_peer_ni {
 	struct list_head	 lpni_hashlist;
 	/* messages blocking for tx credits */
 	struct list_head	 lpni_txq;
-	/* messages blocking for router credits */
-	struct list_head	 lpni_rtrq;
-	/* chain on router list */
-	struct list_head	 lpni_rtr_list;
+	/* pointer to peer net I'm part of */
+	struct lnet_peer_net	*lpni_peer_net;
 	/* statistics kept on each peer NI */
 	struct lnet_element_stats lpni_stats;
 	struct lnet_health_remote_stats lpni_hstats;
-	/* spin lock protecting credits and lpni_txq / lpni_rtrq */
+	/* spin lock protecting credits and lpni_txq */
 	spinlock_t		 lpni_lock;
 	/* # tx credits available */
 	int			 lpni_txcredits;
-	struct lnet_peer_net	*lpni_peer_net;
 	/* low water mark */
 	int			 lpni_mintxcredits;
+	/*
+	 * Each peer_ni in a gateway maintains its own credits. This
+	 * allows more traffic to gateways that have multiple interfaces.
+	 */
 	/* # router credits */
 	int			 lpni_rtrcredits;
 	/* low water mark */
@@ -560,18 +561,12 @@ struct lnet_peer_ni {
 	bool			 lpni_notifylnd;
 	/* some thread is handling notification */
 	bool			 lpni_notifying;
-	/* SEND event outstanding from ping */
-	unsigned int		 lpni_ping_notsent;
 	/* # times router went dead<->alive */
 	int			 lpni_alive_count;
 	/* ytes queued for sending */
 	long			 lpni_txqnob;
 	/* time of last aliveness news */
 	time64_t		 lpni_timestamp;
-	/* time of last ping attempt */
-	time64_t		 lpni_ping_timestamp;
-	/* != 0 if ping reply expected */
-	time64_t		 lpni_ping_deadline;
 	/* when I was last alive */
 	time64_t		 lpni_last_alive;
 	/* when lpni_ni was queried last time */
@@ -590,18 +585,12 @@ struct lnet_peer_ni {
 	int			 lpni_cpt;
 	/* state flags -- protected by lpni_lock */
 	unsigned int		 lpni_state;
-	/* # refs from lnet_route::lr_gateway */
-	int			 lpni_rtr_refcount;
 	/* sequence number used to round robin over peer nis within a net */
 	u32			 lpni_seq;
 	/* sequence number used to round robin over gateways */
 	u32			 lpni_gw_seq;
-	/* health flag */
-	bool			 lpni_healthy;
 	/* returned RC ping features. Protected with lpni_lock */
 	unsigned int		 lpni_ping_feats;
-	/* routers on this peer */
-	struct list_head	 lpni_routes;
 	/* preferred local nids: if only one, use lpni_pref.nid */
 	union lpni_pref {
 		lnet_nid_t	 nid;
@@ -632,6 +621,9 @@ struct lnet_peer {
 	/* list of messages pending discovery*/
 	struct list_head	lp_dc_pendq;
 
+	/* chain on router list */
+	struct list_head	lp_rtr_list;
+
 	/* primary NID of the peer */
 	lnet_nid_t		lp_primary_nid;
 
@@ -641,10 +633,22 @@ struct lnet_peer {
 	/* number of NIDs on this peer */
 	int			lp_nnis;
 
+	/* # refs from lnet_route_t::lr_gateway */
+	int			lp_rtr_refcount;
+
+	/* messages blocking for router credits */
+	struct list_head	lp_rtrq;
+
+	/* routes on this peer */
+	struct list_head	lp_routes;
+
+	/* time of last router check attempt */
+	time64_t		lp_rtrcheck_timestamp;
+
 	/* reference count */
 	atomic_t		lp_refcount;
 
-	/* lock protecting peer state flags */
+	/* lock protecting peer state flags and lpni_rtrq */
 	spinlock_t		lp_lock;
 
 	/* peer state flags */
@@ -808,9 +812,11 @@ struct lnet_route {
 	/* chain on gateway */
 	struct list_head	lr_gwlist;
 	/* router node */
-	struct lnet_peer_ni    *lr_gateway;
+	struct lnet_peer       *lr_gateway;
 	/* remote network number */
 	u32			lr_net;
+	/* local network number */
+	u32			lr_lnet;
 	/* sequence for round-robin */
 	int			lr_seq;
 	/* number of down NIs */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index e080580..99ff882 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -877,7 +877,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * I return LNET_CREDIT_WAIT if msg blocked and LNET_CREDIT_OK if
 	 * received or OK to receive
 	 */
-	struct lnet_peer_ni *lp = msg->msg_rxpeer;
+	struct lnet_peer_ni *lpni = msg->msg_rxpeer;
+	struct lnet_peer *lp;
 	struct lnet_rtrbufpool *rbp;
 	struct lnet_rtrbuf *rb;
 
@@ -887,29 +888,36 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	LASSERT(msg->msg_routing);
 	LASSERT(msg->msg_receiving);
 	LASSERT(!msg->msg_sending);
+	LASSERT(lpni->lpni_peer_net);
+	LASSERT(lpni->lpni_peer_net->lpn_peer);
+
+	lp = lpni->lpni_peer_net->lpn_peer;
 
 	/* non-lnet_parse callers only receive delayed messages */
 	LASSERT(!do_recv || msg->msg_rx_delayed);
 
 	if (!msg->msg_peerrtrcredit) {
-		spin_lock(&lp->lpni_lock);
-		LASSERT((lp->lpni_rtrcredits < 0) ==
-			!list_empty(&lp->lpni_rtrq));
+		/* lpni_lock protects the credit manipulation */
+		spin_lock(&lpni->lpni_lock);
+		/* lp_lock protects the lp_rtrq */
+		spin_lock(&lp->lp_lock);
 
 		msg->msg_peerrtrcredit = 1;
-		lp->lpni_rtrcredits--;
-		if (lp->lpni_rtrcredits < lp->lpni_minrtrcredits)
-			lp->lpni_minrtrcredits = lp->lpni_rtrcredits;
+		lpni->lpni_rtrcredits--;
+		if (lpni->lpni_rtrcredits < lpni->lpni_minrtrcredits)
+			lpni->lpni_minrtrcredits = lpni->lpni_rtrcredits;
 
-		if (lp->lpni_rtrcredits < 0) {
+		if (lpni->lpni_rtrcredits < 0) {
 			/* must have checked eager_recv before here */
 			LASSERT(msg->msg_rx_ready_delay);
 			msg->msg_rx_delayed = 1;
-			list_add_tail(&msg->msg_list, &lp->lpni_rtrq);
-			spin_unlock(&lp->lpni_lock);
+			list_add_tail(&msg->msg_list, &lp->lp_rtrq);
+			spin_unlock(&lp->lp_lock);
+			spin_unlock(&lpni->lpni_lock);
 			return LNET_CREDIT_WAIT;
 		}
-		spin_unlock(&lp->lpni_lock);
+		spin_unlock(&lp->lp_lock);
+		spin_unlock(&lpni->lpni_lock);
 	}
 
 	rbp = lnet_msg2bufpool(msg);
@@ -1080,7 +1088,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 void
 lnet_return_rx_credits_locked(struct lnet_msg *msg)
 {
-	struct lnet_peer_ni *rxpeer = msg->msg_rxpeer;
+	struct lnet_peer_ni *rxpeerni = msg->msg_rxpeer;
+	struct lnet_peer *lp;
 	struct lnet_ni *rxni = msg->msg_rxni;
 	struct lnet_msg *msg2;
 
@@ -1135,44 +1144,69 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 routing_off:
 	if (msg->msg_peerrtrcredit) {
+		LASSERT(rxpeerni);
+		LASSERT(rxpeerni->lpni_peer_net);
+		LASSERT(rxpeerni->lpni_peer_net->lpn_peer);
+
+		lp = rxpeerni->lpni_peer_net->lpn_peer;
+
 		/* give back peer router credits */
 		msg->msg_peerrtrcredit = 0;
 
-		spin_lock(&rxpeer->lpni_lock);
-		LASSERT((rxpeer->lpni_rtrcredits < 0) ==
-			!list_empty(&rxpeer->lpni_rtrq));
+		spin_lock(&rxpeerni->lpni_lock);
+		spin_lock(&lp->lp_lock);
 
-		rxpeer->lpni_rtrcredits++;
-		/*
-		 * drop all messages which are queued to be routed on that
+		rxpeerni->lpni_rtrcredits++;
+
+		/* drop all messages which are queued to be routed on that
 		 * peer.
 		 */
 		if (!the_lnet.ln_routing) {
 			LIST_HEAD(drop);
 
-			list_splice_init(&rxpeer->lpni_rtrq, &drop);
-			spin_unlock(&rxpeer->lpni_lock);
+			list_splice_init(&lp->lp_rtrq, &drop);
+			spin_unlock(&lp->lp_lock);
+			spin_unlock(&rxpeerni->lpni_lock);
 			lnet_drop_routed_msgs_locked(&drop, msg->msg_rx_cpt);
-		} else if (rxpeer->lpni_rtrcredits <= 0) {
-			msg2 = list_first_entry(&rxpeer->lpni_rtrq,
+		} else if (!list_empty(&lp->lp_rtrq)) {
+			int msg2_cpt;
+
+			msg2 = list_first_entry(&lp->lp_rtrq,
 						struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
-			spin_unlock(&rxpeer->lpni_lock);
+			msg2_cpt = msg2->msg_rx_cpt;
+			spin_unlock(&lp->lp_lock);
+			spin_unlock(&rxpeerni->lpni_lock);
+			/* messages on the lp_rtrq can be from any NID in
+			 * the peer, which means they might have different
+			 * cpts. We need to make sure we lock the right
+			 * one.
+			 */
+			if (msg2_cpt != msg->msg_rx_cpt) {
+				lnet_net_unlock(msg->msg_rx_cpt);
+				lnet_net_lock(msg2_cpt);
+			}
 			(void)lnet_post_routed_recv_locked(msg2, 1);
+			if (msg2_cpt != msg->msg_rx_cpt) {
+				lnet_net_unlock(msg2_cpt);
+				lnet_net_lock(msg->msg_rx_cpt);
+			}
 		} else {
-			spin_unlock(&rxpeer->lpni_lock);
+			spin_unlock(&lp->lp_lock);
+			spin_unlock(&rxpeerni->lpni_lock);
 		}
 	}
 	if (rxni) {
 		msg->msg_rxni = NULL;
 		lnet_ni_decref_locked(rxni, msg->msg_rx_cpt);
 	}
-	if (rxpeer) {
+	if (rxpeerni) {
 		msg->msg_rxpeer = NULL;
-		lnet_peer_ni_decref_locked(rxpeer);
+		lnet_peer_ni_decref_locked(rxpeerni);
 	}
 }
 
+#if 0
 static int
 lnet_compare_peers(struct lnet_peer_ni *p1, struct lnet_peer_ni *p2)
 {
@@ -1190,15 +1224,18 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	return 0;
 }
+#endif
 
 static int
 lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
 {
+	/* TODO re-implement gateway comparison
 	struct lnet_peer_ni *p1 = r1->lr_gateway;
 	struct lnet_peer_ni *p2 = r2->lr_gateway;
+	*/
 	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
 	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
-	int rc;
+	/*int rc;*/
 
 	if (r1->lr_priority < r2->lr_priority)
 		return 1;
@@ -1212,9 +1249,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (r1_hops > r2_hops)
 		return -1;
 
+	/*
 	rc = lnet_compare_peers(p1, p2);
 	if (rc)
 		return rc;
+	*/
 
 	if (r1->lr_seq - r2->lr_seq <= 0)
 		return 1;
@@ -1222,17 +1261,17 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return -1;
 }
 
-static struct lnet_peer_ni *
+/* TODO: lnet_find_route_locked() needs to be reimplemented */
+static struct lnet_route *
 lnet_find_route_locked(struct lnet_net *net, u32 remote_net,
-		       lnet_nid_t rtr_nid, struct lnet_route **use_route,
-		       struct lnet_route **prev_route)
+		       lnet_nid_t rtr_nid, struct lnet_route **prev_route)
 {
 	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
-	struct lnet_peer_ni *lpni_best;
-	struct lnet_peer_ni *lp;
+	struct lnet_peer *lp_best;
+	struct lnet_peer *lp;
 	int rc;
 
 	/*
@@ -1243,7 +1282,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (!rnet)
 		return NULL;
 
-	lpni_best = NULL;
+	lp_best = NULL;
 	best_route = NULL;
 	last_route = NULL;
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
@@ -1252,16 +1291,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (!lnet_is_route_alive(route))
 			continue;
 
-		if (net && lp->lpni_net != net)
-			continue;
-
-		if (lp->lpni_nid == rtr_nid) /* it's pre-determined router */
-			return lp;
-
-		if (!lpni_best) {
+		if (!lp_best) {
 			best_route = route;
 			last_route = route;
-			lpni_best = lp;
+			lp_best = lp;
 			continue;
 		}
 
@@ -1274,14 +1307,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			continue;
 
 		best_route = route;
-		lpni_best = lp;
+		lp_best = lp;
 	}
 
-	if (best_route) {
-		*use_route = best_route;
-		*prev_route = last_route;
-	}
-	return lpni_best;
+	*prev_route = last_route;
+
+	return best_route;
 }
 
 static struct lnet_ni *
@@ -1835,60 +1866,80 @@ struct lnet_ni *
 			     struct lnet_peer_ni **gw_lpni,
 			     struct lnet_peer **gw_peer)
 {
-	struct lnet_route *best_route = NULL;
-	struct lnet_route *last_route = NULL;
-	struct lnet_peer_ni *gw;
+	struct lnet_peer *gw;
+	struct lnet_route *best_route;
+	struct lnet_route *last_route;
+	struct lnet_peer_ni *lpni = NULL;
 	lnet_nid_t src_nid = sd->sd_src_nid;
 
-	gw = lnet_find_route_locked(NULL, LNET_NIDNET(dst_nid),
-				    sd->sd_rtr_nid, &best_route, &last_route);
-	if (!gw) {
+	best_route = lnet_find_route_locked(NULL, LNET_NIDNET(dst_nid),
+					    sd->sd_rtr_nid, &last_route);
+	if (!best_route) {
 		CERROR("no route to %s from %s\n",
 		       libcfs_nid2str(dst_nid), libcfs_nid2str(src_nid));
 		return -EHOSTUNREACH;
 	}
 
-	/* get the peer of the gw_ni */
-	LASSERT(gw->lpni_peer_net);
-	LASSERT(gw->lpni_peer_net->lpn_peer);
-
-	*gw_peer = gw->lpni_peer_net->lpn_peer;
+	gw = best_route->lr_gateway;
+	*gw_peer = gw;
 
 	/* Discover this gateway if it hasn't already been discovered.
 	 * This means we might delay the message until discovery has
 	 * completed
 	 */
+#if 0
+	/* TODO: disable discovey for now */
 	if (lnet_msg_discovery(sd->sd_msg) &&
 	    !lnet_peer_is_uptodate(*gw_peer)) {
 		sd->sd_msg->msg_src_nid_param = sd->sd_src_nid;
 		return lnet_initiate_peer_discovery(gw, sd->sd_msg,
 						    sd->sd_rtr_nid, sd->sd_cpt);
 	}
+#endif
 
-	if (!sd->sd_best_ni)
-		sd->sd_best_ni =
-			lnet_find_best_ni_on_spec_net(NULL, *gw_peer,
-						      gw->lpni_peer_net,
-						      sd->sd_md_cpt,
-						      true);
+	if (!sd->sd_best_ni) {
+		struct lnet_peer_net *lpeer;
 
+		lpeer = lnet_peer_get_net_locked(gw, best_route->lr_lnet);
+		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL, gw, lpeer,
+							       sd->sd_md_cpt,
+							       true);
+	}
 	if (!sd->sd_best_ni) {
 		CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
-		       libcfs_net2str(gw->lpni_peer_net->lpn_net_id),
+		       libcfs_net2str(best_route->lr_lnet),
 		       libcfs_nid2str(sd->sd_src_nid));
 		return -EFAULT;
 	}
 
 	/* if gw is MR let's find its best peer_ni
 	 */
-	if (lnet_peer_is_multi_rail(*gw_peer)) {
-		gw = lnet_find_best_lpni_on_net(sd, *gw_peer,
-						sd->sd_best_ni->ni_net->net_id);
+	if (lnet_peer_is_multi_rail(gw)) {
+		lpni = lnet_find_best_lpni_on_net(sd, gw,
+						  sd->sd_best_ni->ni_net->net_id);
 		/* We've already verified that the gw has an NI on that
 		 * desired net, but we're not finding it. Something is
 		 * wrong.
 		 */
-		if (!gw) {
+		if (!lpni) {
+			CERROR("Internal Error. Route expected to %s from %s\n",
+			       libcfs_nid2str(dst_nid),
+			       libcfs_nid2str(src_nid));
+			return -EFAULT;
+		}
+	} else {
+		struct lnet_peer_net *lpn;
+
+		lpn = lnet_peer_get_net_locked(gw, best_route->lr_lnet);
+		if (!lpn) {
+			CERROR("Internal Error. Route expected to %s from %s\n",
+			       libcfs_nid2str(dst_nid),
+			       libcfs_nid2str(src_nid));
+			return -EFAULT;
+		}
+		lpni = list_entry(lpn->lpn_peer_nis.next, struct lnet_peer_ni,
+				  lpni_peer_nis);
+		if (!lpni) {
 			CERROR("Internal Error. Route expected to %s from %s\n",
 			       libcfs_nid2str(dst_nid),
 			       libcfs_nid2str(src_nid));
@@ -1896,7 +1947,7 @@ struct lnet_ni *
 		}
 	}
 
-	*gw_lpni = gw;
+	*gw_lpni = lpni;
 
 	/* increment the route sequence number since now we're sure we're
 	 * going to use it
@@ -4046,17 +4097,23 @@ void lnet_monitor_thr_stop(void)
 
 		rnet = lnet_find_rnet_locked(LNET_NIDNET(src_nid));
 		if (rnet) {
-			struct lnet_peer_ni *gw = NULL;
+			struct lnet_peer *gw = NULL;
+			struct lnet_peer_ni *lpni = NULL;
 			struct lnet_route *route;
 
 			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 				found = false;
 				gw = route->lr_gateway;
-				if (gw->lpni_net != net)
+				if (route->lr_lnet != net->net_id)
 					continue;
-				if (gw->lpni_nid == from_nid) {
-					found = true;
-					break;
+				/* if the nid is one of the gateway's NIDs
+				 * then this is a valid gateway
+				 */
+				while ((lpni = lnet_get_next_peer_ni_locked(gw, NULL, lpni)) != NULL) {
+					if (lpni->lpni_nid == from_nid) {
+						found = true;
+						break;
+					}
 				}
 			}
 		}
@@ -4773,9 +4830,11 @@ struct lnet_msg *
 			LASSERT(shortest);
 			hops = shortest_hops;
 			if (srcnidp) {
-				ni = lnet_get_next_ni_locked(
-					shortest->lr_gateway->lpni_net,
-					NULL);
+				struct lnet_net *net;
+
+				net = lnet_get_net_locked(shortest->lr_lnet);
+				LASSERT(net);
+				ni = lnet_get_next_ni_locked(net, NULL);
 				*srcnidp = ni->ni_nid;
 			}
 			if (orderp)
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0d2d356..faaf94a 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -120,8 +120,6 @@
 		return NULL;
 
 	INIT_LIST_HEAD(&lpni->lpni_txq);
-	INIT_LIST_HEAD(&lpni->lpni_rtrq);
-	INIT_LIST_HEAD(&lpni->lpni_routes);
 	INIT_LIST_HEAD(&lpni->lpni_hashlist);
 	INIT_LIST_HEAD(&lpni->lpni_peer_nis);
 	INIT_LIST_HEAD(&lpni->lpni_recovery);
@@ -206,10 +204,13 @@
 	if (!lp)
 		return NULL;
 
+	INIT_LIST_HEAD(&lp->lp_rtrq);
+	INIT_LIST_HEAD(&lp->lp_routes);
 	INIT_LIST_HEAD(&lp->lp_peer_list);
 	INIT_LIST_HEAD(&lp->lp_peer_nets);
 	INIT_LIST_HEAD(&lp->lp_dc_list);
 	INIT_LIST_HEAD(&lp->lp_dc_pendq);
+	INIT_LIST_HEAD(&lp->lp_rtr_list);
 	init_waitqueue_head(&lp->lp_dc_waitq);
 	spin_lock_init(&lp->lp_lock);
 	lp->lp_primary_nid = nid;
@@ -235,6 +236,7 @@
 	CDEBUG(D_NET, "%p nid %s\n", lp, libcfs_nid2str(lp->lp_primary_nid));
 
 	LASSERT(atomic_read(&lp->lp_refcount) == 0);
+	LASSERT(lp->lp_rtr_refcount == 0);
 	LASSERT(list_empty(&lp->lp_peer_nets));
 	LASSERT(list_empty(&lp->lp_peer_list));
 	LASSERT(list_empty(&lp->lp_dc_list));
@@ -324,7 +326,7 @@
 	struct lnet_peer_table *ptable = NULL;
 
 	/* don't remove a peer_ni if it's also a gateway */
-	if (lpni->lpni_rtr_refcount > 0) {
+	if (lnet_isrouter(lpni)) {
 		CERROR("Peer NI %s is a gateway. Can not delete it\n",
 		       libcfs_nid2str(lpni->lpni_nid));
 		return -EBUSY;
@@ -570,7 +572,7 @@ void lnet_peer_uninit(void)
 {
 	struct lnet_peer_ni *lp;
 	struct lnet_peer_ni *tmp;
-	lnet_nid_t lpni_nid;
+	lnet_nid_t gw_nid;
 	int i;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
@@ -579,13 +581,13 @@ void lnet_peer_uninit(void)
 			if (net != lp->lpni_net)
 				continue;
 
-			if (!lp->lpni_rtr_refcount)
+			if (!lnet_isrouter(lp))
 				continue;
 
-			lpni_nid = lp->lpni_nid;
+			gw_nid = lp->lpni_peer_net->lpn_peer->lp_primary_nid;
 
 			lnet_net_unlock(LNET_LOCK_EX);
-			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), lpni_nid);
+			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), gw_nid);
 			lnet_net_lock(LNET_LOCK_EX);
 		}
 	}
@@ -1567,7 +1569,6 @@ struct lnet_peer_net *
 	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nid2str(lpni->lpni_nid));
 
 	LASSERT(atomic_read(&lpni->lpni_refcount) == 0);
-	LASSERT(lpni->lpni_rtr_refcount == 0);
 	LASSERT(list_empty(&lpni->lpni_txq));
 	LASSERT(lpni->lpni_txqnob == 0);
 	LASSERT(list_empty(&lpni->lpni_peer_nis));
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index c00b9251..4e79c21 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -114,7 +114,6 @@
 	spin_lock(&lp->lpni_lock);
 
 	lp->lpni_timestamp = when;		/* update timestamp */
-	lp->lpni_ping_deadline = 0;		/* disable ping timeout */
 
 	if (lp->lpni_alive_count &&		/* got old news */
 	    (!lp->lpni_alive) == (!alive)) {	/* new date for old news */
@@ -191,58 +190,6 @@
 	spin_unlock(&lp->lpni_lock);
 }
 
-static void
-lnet_rtr_addref_locked(struct lnet_peer_ni *lp)
-{
-	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
-	LASSERT(lp->lpni_rtr_refcount >= 0);
-
-	/* lnet_net_lock must be exclusively locked */
-	lp->lpni_rtr_refcount++;
-	if (lp->lpni_rtr_refcount == 1) {
-		struct list_head *pos;
-
-		/* a simple insertion sort */
-		list_for_each_prev(pos, &the_lnet.ln_routers) {
-			struct lnet_peer_ni *rtr;
-
-			rtr = list_entry(pos, struct lnet_peer_ni,
-					 lpni_rtr_list);
-			if (rtr->lpni_nid < lp->lpni_nid)
-				break;
-		}
-
-		list_add(&lp->lpni_rtr_list, pos);
-		/* addref for the_lnet.ln_routers */
-		lnet_peer_ni_addref_locked(lp);
-		the_lnet.ln_routers_version++;
-	}
-}
-
-static void
-lnet_rtr_decref_locked(struct lnet_peer_ni *lp)
-{
-	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
-	LASSERT(lp->lpni_rtr_refcount > 0);
-
-	/* lnet_net_lock must be exclusively locked */
-	lp->lpni_rtr_refcount--;
-	if (!lp->lpni_rtr_refcount) {
-		LASSERT(list_empty(&lp->lpni_routes));
-
-		if (lp->lpni_rcd) {
-			list_add(&lp->lpni_rcd->rcd_list,
-				 &the_lnet.ln_rcd_deathrow);
-			lp->lpni_rcd = NULL;
-		}
-
-		list_del(&lp->lpni_rtr_list);
-		/* decref for the_lnet.ln_routers */
-		lnet_peer_ni_decref_locked(lp);
-		the_lnet.ln_routers_version++;
-	}
-}
-
 struct lnet_remotenet *
 lnet_find_rnet_locked(u32 net)
 {
@@ -259,239 +206,24 @@ struct lnet_remotenet *
 	return NULL;
 }
 
-static void lnet_shuffle_seed(void)
-{
-	static int seeded;
-	struct lnet_ni *ni = NULL;
-
-	if (seeded)
-		return;
-
-	/* Nodes with small feet have little entropy
-	 * the NID for this node gives the most entropy in the low bits */
-	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
-		u32 lnd_type, seed;
-
-		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
-		if (lnd_type != LOLND) {
-			seed = (LNET_NIDADDR(ni->ni_nid) | lnd_type);
-			add_device_randomness(&seed, sizeof(seed));
-		}
-	}
-
-	seeded = 1;
-}
-
-/* NB expects LNET_LOCK held */
-static void
-lnet_add_route_to_rnet(struct lnet_remotenet *rnet, struct lnet_route *route)
-{
-	unsigned int len = 0;
-	unsigned int offset = 0;
-	struct list_head *e;
-
-	lnet_shuffle_seed();
-
-	list_for_each(e, &rnet->lrn_routes) {
-		len++;
-	}
-
-	/* len+1 positions to add a new entry */
-	offset = prandom_u32_max(len + 1);
-	list_for_each(e, &rnet->lrn_routes) {
-		if (!offset)
-			break;
-		offset--;
-	}
-	list_add(&route->lr_list, e);
-	list_add(&route->lr_gwlist, &route->lr_gateway->lpni_routes);
-
-	the_lnet.ln_remote_nets_version++;
-	lnet_rtr_addref_locked(route->lr_gateway);
-}
-
 int
 lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway,
 	       unsigned int priority)
 {
-	struct lnet_remotenet *rnet;
-	struct lnet_remotenet *rnet2;
-	struct lnet_route *route;
-	struct lnet_route *route2;
-	struct lnet_ni *ni;
-	struct lnet_peer_ni *lpni;
-	int add_route;
-	int rc;
-
-	CDEBUG(D_NET, "Add route: net %s hops %d priority %u gw %s\n",
-	       libcfs_net2str(net), hops, priority, libcfs_nid2str(gateway));
-
-	if (gateway == LNET_NID_ANY ||
-	    LNET_NETTYP(LNET_NIDNET(gateway)) == LOLND ||
-	    net == LNET_NIDNET(LNET_NID_ANY) ||
-	    LNET_NETTYP(net) == LOLND ||
-	    LNET_NIDNET(gateway) == net ||
-	    (hops != LNET_UNDEFINED_HOPS && (hops < 1 || hops > 255)))
-		return -EINVAL;
-
-	if (lnet_islocalnet(net))	/* it's a local network */
-		return -EEXIST;
-
-	/* Assume net, route, all new */
-	route = kzalloc(sizeof(*route), GFP_NOFS);
-	rnet = kzalloc(sizeof(*rnet), GFP_NOFS);
-	if (!route || !rnet) {
-		CERROR("Out of memory creating route %s %d %s\n",
-		       libcfs_net2str(net), hops, libcfs_nid2str(gateway));
-		kfree(route);
-		kfree(rnet);
-		return -ENOMEM;
-	}
-
-	INIT_LIST_HEAD(&rnet->lrn_routes);
-	rnet->lrn_net = net;
-	route->lr_hops = hops;
-	route->lr_net = net;
-	route->lr_priority = priority;
-
-	lnet_net_lock(LNET_LOCK_EX);
-
-	lpni = lnet_nid2peerni_ex(gateway, LNET_LOCK_EX);
-	if (IS_ERR(lpni)) {
-		lnet_net_unlock(LNET_LOCK_EX);
-
-		kfree(route);
-		kfree(rnet);
-
-		rc = PTR_ERR(lpni);
-		if (rc == -EHOSTUNREACH) /* gateway is not on a local net */
-			return rc;	/* ignore the route entry */
-		CERROR("Error %d creating route %s %d %s\n", rc,
-		       libcfs_net2str(net), hops,
-		       libcfs_nid2str(gateway));
-		return rc;
-	}
-	route->lr_gateway = lpni;
-	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
-
-	rnet2 = lnet_find_rnet_locked(net);
-	if (!rnet2) {
-		/* new network */
-		list_add_tail(&rnet->lrn_list, lnet_net2rnethash(net));
-		rnet2 = rnet;
-	}
-
-	/* Search for a duplicate route (it's a NOOP if it is) */
-	add_route = 1;
-	list_for_each_entry(route2, &rnet2->lrn_routes, lr_list) {
-		if (route2->lr_gateway == route->lr_gateway) {
-			add_route = 0;
-			break;
-		}
-
-		/* our lookups must be true */
-		LASSERT(route2->lr_gateway->lpni_nid != gateway);
-	}
-
-	if (add_route) {
-		lnet_peer_ni_addref_locked(route->lr_gateway); /* +1 for notify */
-		lnet_add_route_to_rnet(rnet2, route);
-
-		ni = lnet_get_next_ni_locked(route->lr_gateway->lpni_net, NULL);
-		lnet_net_unlock(LNET_LOCK_EX);
-
-		/* XXX Assume alive */
-		if (ni->ni_net->net_lnd->lnd_notify)
-			ni->ni_net->net_lnd->lnd_notify(ni, gateway, 1);
-
-		lnet_net_lock(LNET_LOCK_EX);
-	}
-
-	/* -1 for notify or !add_route */
-	lnet_peer_ni_decref_locked(route->lr_gateway);
-	lnet_net_unlock(LNET_LOCK_EX);
-	rc = 0;
-
-	if (!add_route) {
-		rc = -EEXIST;
-		kfree(route);
-	}
-
-	if (rnet != rnet2)
-		kfree(rnet);
-
-	/* kick start the monitor thread to handle the added route */
-	wake_up(&the_lnet.ln_mt_waitq);
-
-	return rc;
+	net = net;
+	hops = hops;
+	gateway = gateway;
+	priority = priority;
+	return -EINVAL;
 }
 
+/* TODO: reimplement lnet_check_routes() */
 int
 lnet_del_route(u32 net, lnet_nid_t gw_nid)
 {
-	struct lnet_peer_ni *gateway;
-	struct lnet_remotenet *rnet;
-	struct lnet_route *route;
-	int rc = -ENOENT;
-	struct list_head *rn_list;
-	int idx = 0;
-
-	CDEBUG(D_NET, "Del route: net %s : gw %s\n",
-	       libcfs_net2str(net), libcfs_nid2str(gw_nid));
-
-	/*
-	 * NB Caller may specify either all routes via the given gateway
-	 * or a specific route entry actual NIDs)
-	 */
-	lnet_net_lock(LNET_LOCK_EX);
-	if (net == LNET_NIDNET(LNET_NID_ANY))
-		rn_list = &the_lnet.ln_remote_nets_hash[0];
-	else
-		rn_list = lnet_net2rnethash(net);
-
-again:
-	list_for_each_entry(rnet, rn_list, lrn_list) {
-		if (!(net == LNET_NIDNET(LNET_NID_ANY) ||
-		      net == rnet->lrn_net))
-			continue;
-
-		list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
-			gateway = route->lr_gateway;
-			if (!(gw_nid == LNET_NID_ANY ||
-			      gw_nid == gateway->lpni_nid))
-				continue;
-
-			list_del(&route->lr_list);
-			list_del(&route->lr_gwlist);
-			the_lnet.ln_remote_nets_version++;
-
-			if (list_empty(&rnet->lrn_routes))
-				list_del(&rnet->lrn_list);
-			else
-				rnet = NULL;
-
-			lnet_rtr_decref_locked(gateway);
-			lnet_peer_ni_decref_locked(gateway);
-
-			lnet_net_unlock(LNET_LOCK_EX);
-
-			kfree(route);
-			kfree(rnet);
-
-			rc = 0;
-			lnet_net_lock(LNET_LOCK_EX);
-			goto again;
-		}
-	}
-
-	if (net == LNET_NIDNET(LNET_NID_ANY) &&
-	    ++idx < LNET_REMOTE_NETS_HASH_SIZE) {
-		rn_list = &the_lnet.ln_remote_nets_hash[idx];
-		goto again;
-	}
-	lnet_net_unlock(LNET_LOCK_EX);
-
-	return rc;
+	net = net;
+	gw_nid = gw_nid;
+	return -EINVAL;
 }
 
 void
@@ -553,7 +285,8 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 					*net = rnet->lrn_net;
 					*hops = route->lr_hops;
 					*priority = route->lr_priority;
-					*gateway = route->lr_gateway->lpni_nid;
+					*gateway =
+					    route->lr_gateway->lp_primary_nid;
 					*alive = lnet_is_route_alive(route);
 					lnet_net_unlock(cpt);
 					return 0;
@@ -588,110 +321,12 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 /**
- * parse router-checker pinginfo, record number of down NIs for remote
- * networks on that router.
+ * TODO: re-implement
  */
 static void
 lnet_parse_rc_info(struct lnet_rc_data *rcd)
 {
-	struct lnet_ping_buffer *pbuf = rcd->rcd_pingbuffer;
-	struct lnet_peer_ni *gw = rcd->rcd_gateway;
-	struct lnet_route *rte;
-	int nnis;
-
-	if (!gw->lpni_alive || !pbuf)
-		return;
-
-	/*
-	 * Protect gw->lpni_ping_feats. This can be set from
-	 * lnet_notify_locked with different locks being held
-	 */
-	spin_lock(&gw->lpni_lock);
-
-	if (pbuf->pb_info.pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
-		lnet_swap_pinginfo(pbuf);
-
-	/* NB always racing with network! */
-	if (pbuf->pb_info.pi_magic != LNET_PROTO_PING_MAGIC) {
-		CDEBUG(D_NET, "%s: Unexpected magic %08x\n",
-		       libcfs_nid2str(gw->lpni_nid), pbuf->pb_info.pi_magic);
-		gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-		goto out;
-	}
-
-	gw->lpni_ping_feats = pbuf->pb_info.pi_features;
-
-	/* Without NI status info there's nothing more to do. */
-	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS))
-		goto out;
-
-	/* Determine the number of NIs for which there is data. */
-	nnis = pbuf->pb_info.pi_nnis;
-	if (pbuf->pb_nnis < nnis) {
-		if (rcd->rcd_nnis < nnis)
-			rcd->rcd_nnis = nnis;
-		nnis = pbuf->pb_nnis;
-	}
-
-	list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
-		int down = 0;
-		int up = 0;
-		int i;
-
-		/* If routing disabled then the route is down. */
-		if (gw->lpni_ping_feats & LNET_PING_FEAT_RTE_DISABLED) {
-			rte->lr_downis = 1;
-			continue;
-		}
-
-		for (i = 0; i < nnis; i++) {
-			struct lnet_ni_status *stat = &pbuf->pb_info.pi_ni[i];
-			lnet_nid_t nid = stat->ns_nid;
-
-			if (nid == LNET_NID_ANY) {
-				CDEBUG(D_NET, "%s: unexpected LNET_NID_ANY\n",
-				       libcfs_nid2str(gw->lpni_nid));
-				gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-				goto out;
-			}
-
-			if (LNET_NETTYP(LNET_NIDNET(nid)) == LOLND)
-				continue;
-
-			if (stat->ns_status == LNET_NI_STATUS_DOWN) {
-				down++;
-				continue;
-			}
-
-			if (stat->ns_status == LNET_NI_STATUS_UP) {
-				if (LNET_NIDNET(nid) == rte->lr_net) {
-					up = 1;
-					break;
-				}
-				continue;
-			}
-
-			CDEBUG(D_NET, "%s: Unexpected status 0x%x\n",
-			       libcfs_nid2str(gw->lpni_nid), stat->ns_status);
-			gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
-			goto out;
-		}
-
-		if (up) { /* ignore downed NIs if NI for dest network is up */
-			rte->lr_downis = 0;
-			continue;
-		}
-		/**
-		 * if @down is zero and this route is single-hop, it means
-		 * we can't find NI for target network
-		 */
-		if (!down && rte->lr_hops == 1)
-			down = 1;
-
-		rte->lr_downis = down;
-	}
-out:
-	spin_unlock(&gw->lpni_lock);
+	rcd = rcd;
 }
 
 static void
@@ -725,7 +360,6 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 
 	if (event->type == LNET_EVENT_SEND) {
-		lp->lpni_ping_notsent = 0;
 		if (!event->status)
 			goto out;
 	}
@@ -755,7 +389,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_wait_known_routerstate(void)
 {
-	struct lnet_peer_ni *rtr;
+	struct lnet_peer *rtr;
 	int all_known;
 
 	LASSERT(the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING);
@@ -764,15 +398,15 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 		int cpt = lnet_net_lock_current();
 
 		all_known = 1;
-		list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
-			spin_lock(&rtr->lpni_lock);
+		list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
+			spin_lock(&rtr->lp_lock);
 
-			if (!rtr->lpni_alive_count) {
+			if (!(rtr->lp_state & LNET_PEER_DISCOVERED)) {
 				all_known = 0;
-				spin_unlock(&rtr->lpni_lock);
+				spin_unlock(&rtr->lp_lock);
 				break;
 			}
-			spin_unlock(&rtr->lpni_lock);
+			spin_unlock(&rtr->lp_lock);
 		}
 
 		lnet_net_unlock(cpt);
@@ -784,17 +418,22 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
+/* TODO: reimplement */
 void
 lnet_router_ni_update_locked(struct lnet_peer_ni *gw, u32 net)
 {
 	struct lnet_route *rte;
+	struct lnet_peer *lp;
 
-	if ((gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
-		list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
-			if (rte->lr_net == net) {
-				rte->lr_downis = 0;
-				break;
-			}
+	if ((gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS))
+		lp = gw->lpni_peer_net->lpn_peer;
+	else
+		return;
+
+	list_for_each_entry(rte, &lp->lp_routes, lr_gwlist) {
+		if (rte->lr_net == net) {
+			rte->lr_downis = 0;
+			break;
 		}
 	}
 }
@@ -841,212 +480,6 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 	}
 }
 
-static void
-lnet_destroy_rc_data(struct lnet_rc_data *rcd)
-{
-	LASSERT(list_empty(&rcd->rcd_list));
-	/* detached from network */
-	LASSERT(LNetMDHandleIsInvalid(rcd->rcd_mdh));
-
-	if (rcd->rcd_gateway) {
-		int cpt = rcd->rcd_gateway->lpni_cpt;
-
-		lnet_net_lock(cpt);
-		lnet_peer_ni_decref_locked(rcd->rcd_gateway);
-		lnet_net_unlock(cpt);
-	}
-
-	if (rcd->rcd_pingbuffer)
-		lnet_ping_buffer_decref(rcd->rcd_pingbuffer);
-
-	kfree(rcd);
-}
-
-static struct lnet_rc_data *
-lnet_update_rc_data_locked(struct lnet_peer_ni *gateway)
-{
-	struct lnet_handle_md mdh;
-	struct lnet_rc_data *rcd;
-	struct lnet_ping_buffer *pbuf = NULL;
-	struct lnet_md md;
-	int nnis = LNET_INTERFACES_MIN;
-	int rc;
-	int i;
-
-	rcd = gateway->lpni_rcd;
-	if (rcd) {
-		nnis = rcd->rcd_nnis;
-		mdh = rcd->rcd_mdh;
-		LNetInvalidateMDHandle(&rcd->rcd_mdh);
-		pbuf = rcd->rcd_pingbuffer;
-		rcd->rcd_pingbuffer = NULL;
-	} else {
-		LNetInvalidateMDHandle(&mdh);
-	}
-
-	lnet_net_unlock(gateway->lpni_cpt);
-
-	if (rcd) {
-		LNetMDUnlink(mdh);
-		lnet_ping_buffer_decref(pbuf);
-	} else {
-		rcd = kzalloc(sizeof(*rcd), GFP_NOFS);
-		if (!rcd)
-			goto out;
-
-		LNetInvalidateMDHandle(&rcd->rcd_mdh);
-		INIT_LIST_HEAD(&rcd->rcd_list);
-		rcd->rcd_nnis = nnis;
-	}
-
-	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
-	if (!pbuf)
-		goto out;
-
-	for (i = 0; i < nnis; i++) {
-		pbuf->pb_info.pi_ni[i].ns_nid = LNET_NID_ANY;
-		pbuf->pb_info.pi_ni[i].ns_status = LNET_NI_STATUS_INVALID;
-	}
-	rcd->rcd_pingbuffer = pbuf;
-
-	md.start = &pbuf->pb_info;
-	md.user_ptr = rcd;
-	md.length = LNET_PING_INFO_SIZE(nnis);
-	md.threshold = LNET_MD_THRESH_INF;
-	md.options = LNET_MD_TRUNCATE;
-	md.eq_handle = the_lnet.ln_rc_eqh;
-
-	LASSERT(!LNetEQHandleIsInvalid(the_lnet.ln_rc_eqh));
-	rc = LNetMDBind(md, LNET_UNLINK, &rcd->rcd_mdh);
-	if (rc < 0) {
-		CERROR("Can't bind MD: %d\n", rc);
-		goto out_ping_buffer_decref;
-	}
-	LASSERT(!rc);
-
-	lnet_net_lock(gateway->lpni_cpt);
-	/* Check if this is still a router. */
-	if (!lnet_isrouter(gateway))
-		goto out_unlock;
-	/* Check if someone else installed router data. */
-	if (gateway->lpni_rcd && gateway->lpni_rcd != rcd)
-		goto out_unlock;
-
-	/* Install and/or update the router data. */
-	if (!gateway->lpni_rcd) {
-		lnet_peer_ni_addref_locked(gateway);
-		rcd->rcd_gateway = gateway;
-		gateway->lpni_rcd = rcd;
-	}
-	gateway->lpni_ping_notsent = 0;
-
-	return rcd;
-
-out_unlock:
-	lnet_net_unlock(gateway->lpni_cpt);
-	rc = LNetMDUnlink(mdh);
-	LASSERT(!rc);
-out_ping_buffer_decref:
-	lnet_ping_buffer_decref(pbuf);
-out:
-	if (rcd && rcd != gateway->lpni_rcd)
-		lnet_destroy_rc_data(rcd);
-	lnet_net_lock(gateway->lpni_cpt);
-	return gateway->lpni_rcd;
-}
-
-static int
-lnet_router_check_interval(struct lnet_peer_ni *rtr)
-{
-	int secs;
-
-	secs = rtr->lpni_alive ? live_router_check_interval :
-			       dead_router_check_interval;
-	if (secs < 0)
-		secs = 0;
-
-	return secs;
-}
-
-static void
-lnet_ping_router_locked(struct lnet_peer_ni *rtr)
-{
-	struct lnet_rc_data *rcd = NULL;
-	time64_t now = ktime_get_seconds();
-	time64_t secs;
-	struct lnet_ni *ni;
-
-	lnet_peer_ni_addref_locked(rtr);
-
-	if (rtr->lpni_ping_deadline && /* ping timed out? */
-	    now > rtr->lpni_ping_deadline)
-		lnet_notify_locked(rtr, 1, 0, now);
-
-	/* Run any outstanding notifications */
-	ni = lnet_get_next_ni_locked(rtr->lpni_net, NULL);
-	lnet_ni_notify_locked(ni, rtr);
-
-	if (!lnet_isrouter(rtr) ||
-	    the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
-		/* router table changed or router checker is shutting down */
-		lnet_peer_ni_decref_locked(rtr);
-		return;
-	}
-
-	rcd = rtr->lpni_rcd;
-
-	/* The response to the router checker ping could've timed out and
-	 * the mdh might've been invalidated, so we need to update it
-	 * again.
-	 */
-	if (!rcd || rcd->rcd_nnis > rcd->rcd_pingbuffer->pb_nnis ||
-	    LNetMDHandleIsInvalid(rcd->rcd_mdh))
-		rcd = lnet_update_rc_data_locked(rtr);
-	if (!rcd)
-		return;
-
-	secs = lnet_router_check_interval(rtr);
-
-	CDEBUG(D_NET,
-	       "rtr %s %lldd: deadline %lld ping_notsent %d alive %d alive_count %d lpni_ping_timestamp %lld\n",
-	       libcfs_nid2str(rtr->lpni_nid), secs,
-	       rtr->lpni_ping_deadline, rtr->lpni_ping_notsent,
-	       rtr->lpni_alive, rtr->lpni_alive_count,
-	       rtr->lpni_ping_timestamp);
-
-	if (secs && !rtr->lpni_ping_notsent &&
-	    now > rtr->lpni_ping_timestamp + secs) {
-		int rc;
-		struct lnet_process_id id;
-		struct lnet_handle_md mdh;
-
-		id.nid = rtr->lpni_nid;
-		id.pid = LNET_PID_LUSTRE;
-		CDEBUG(D_NET, "Check: %s\n", libcfs_id2str(id));
-
-		rtr->lpni_ping_notsent = 1;
-		rtr->lpni_ping_timestamp = now;
-
-		mdh = rcd->rcd_mdh;
-
-		if (!rtr->lpni_ping_deadline) {
-			rtr->lpni_ping_deadline = ktime_get_seconds() +
-						  router_ping_timeout;
-		}
-
-		lnet_net_unlock(rtr->lpni_cpt);
-
-		rc = LNetGet(LNET_NID_ANY, mdh, id, LNET_RESERVED_PORTAL,
-			     LNET_PROTO_PING_MATCHBITS, 0, false);
-
-		lnet_net_lock(rtr->lpni_cpt);
-		if (rc)
-			rtr->lpni_ping_notsent = 0; /* no event pending */
-	}
-
-	lnet_peer_ni_decref_locked(rtr);
-}
-
 int lnet_router_pre_mt_start(void)
 {
 	int rc;
@@ -1088,81 +521,7 @@ void lnet_router_cleanup(void)
 
 void lnet_prune_rc_data(int wait_unlink)
 {
-	struct lnet_rc_data *rcd;
-	struct lnet_rc_data *tmp;
-	struct lnet_peer_ni *lp;
-	struct list_head head;
-	int i = 2;
-
-	if (likely(the_lnet.ln_mt_state == LNET_MT_STATE_RUNNING &&
-		   list_empty(&the_lnet.ln_rcd_deathrow) &&
-		   list_empty(&the_lnet.ln_rcd_zombie)))
-		return;
-
-	INIT_LIST_HEAD(&head);
-
-	lnet_net_lock(LNET_LOCK_EX);
-
-	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING) {
-		/* router checker is stopping, prune all */
-		list_for_each_entry(lp, &the_lnet.ln_routers,
-				    lpni_rtr_list) {
-			if (!lp->lpni_rcd)
-				continue;
-
-			LASSERT(list_empty(&lp->lpni_rcd->rcd_list));
-			list_add(&lp->lpni_rcd->rcd_list,
-				 &the_lnet.ln_rcd_deathrow);
-			lp->lpni_rcd = NULL;
-		}
-	}
-
-	/* unlink all RCDs on deathrow list */
-	list_splice_init(&the_lnet.ln_rcd_deathrow, &head);
-
-	if (!list_empty(&head)) {
-		lnet_net_unlock(LNET_LOCK_EX);
-
-		list_for_each_entry(rcd, &head, rcd_list)
-			LNetMDUnlink(rcd->rcd_mdh);
-
-		lnet_net_lock(LNET_LOCK_EX);
-	}
-
-	list_splice_init(&head, &the_lnet.ln_rcd_zombie);
-
-	/* release all zombie RCDs */
-	while (!list_empty(&the_lnet.ln_rcd_zombie)) {
-		list_for_each_entry_safe(rcd, tmp, &the_lnet.ln_rcd_zombie,
-					 rcd_list) {
-			if (LNetMDHandleIsInvalid(rcd->rcd_mdh))
-				list_move(&rcd->rcd_list, &head);
-		}
-
-		wait_unlink = wait_unlink &&
-			      !list_empty(&the_lnet.ln_rcd_zombie);
-
-		lnet_net_unlock(LNET_LOCK_EX);
-
-		while ((rcd = list_first_entry_or_null(&head,
-						       struct lnet_rc_data,
-						       rcd_list)) != NULL) {
-			list_del_init(&rcd->rcd_list);
-			lnet_destroy_rc_data(rcd);
-		}
-
-		if (!wait_unlink)
-			return;
-
-		i++;
-		CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET,
-		       "Waiting for rc buffers to unlink\n");
-		schedule_timeout_uninterruptible(HZ / 4);
-
-		lnet_net_lock(LNET_LOCK_EX);
-	}
-
-	lnet_net_unlock(LNET_LOCK_EX);
+	wait_unlink = wait_unlink;
 }
 
 /*
@@ -1194,27 +553,16 @@ bool lnet_router_checker_active(void)
 void
 lnet_check_routers(void)
 {
-	struct lnet_peer_ni *rtr;
+	struct lnet_peer *rtr;
 	u64 version;
 	int cpt;
-	int cpt2;
 
 	cpt = lnet_net_lock_current();
 rescan:
 	version = the_lnet.ln_routers_version;
 
-	list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
-		cpt2 = rtr->lpni_cpt;
-		if (cpt != cpt2) {
-			lnet_net_unlock(cpt);
-			cpt = cpt2;
-			lnet_net_lock(cpt);
-			/* the routers list has changed */
-			if (version != the_lnet.ln_routers_version)
-				goto rescan;
-		}
-
-		lnet_ping_router_locked(rtr);
+	list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
+		/* TODO use discovery to determine if router is alive */
 
 		/* NB dropped lock */
 		if (version != the_lnet.ln_routers_version) {
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 5341599..d41ff00 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -215,7 +215,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			u32 net = rnet->lrn_net;
 			u32 hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
-			lnet_nid_t nid = route->lr_gateway->lpni_nid;
+			lnet_nid_t nid = route->lr_gateway->lp_primary_nid;
 			int alive = lnet_is_route_alive(route);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
@@ -290,7 +290,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		*ppos = LNET_PROC_POS_MAKE(0, ver, 0, off);
 	} else {
 		struct list_head *r;
-		struct lnet_peer_ni *peer = NULL;
+		struct lnet_peer *peer = NULL;
 		int skip = off - 1;
 
 		lnet_net_lock(0);
@@ -305,9 +305,9 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		r = the_lnet.ln_routers.next;
 
 		while (r != &the_lnet.ln_routers) {
-			struct lnet_peer_ni *lp;
+			struct lnet_peer *lp;
 
-			lp = list_entry(r, struct lnet_peer_ni, lpni_rtr_list);
+			lp = list_entry(r, struct lnet_peer, lp_rtr_list);
 			if (!skip) {
 				peer = lp;
 				break;
@@ -318,21 +318,22 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		}
 
 		if (peer) {
-			lnet_nid_t nid = peer->lpni_nid;
+			lnet_nid_t nid = peer->lp_primary_nid;
 			time64_t now = ktime_get_seconds();
-			time64_t deadline = peer->lpni_ping_deadline;
-			int nrefs = atomic_read(&peer->lpni_refcount);
-			int nrtrrefs = peer->lpni_rtr_refcount;
-			int alive_cnt = peer->lpni_alive_count;
-			int alive = peer->lpni_alive;
-			int pingsent = !peer->lpni_ping_notsent;
-			time64_t last_ping = now - peer->lpni_ping_timestamp;
+			/* TODO: readjust what's being printed */
+			time64_t deadline = 0;
+			int nrefs = atomic_read(&peer->lp_refcount);
+			int nrtrrefs = peer->lp_rtr_refcount;
+			int alive_cnt = 0;
+			int alive = 0;
+			int pingsent = ((peer->lp_state & LNET_PEER_PING_SENT)
+				       != 0);
+			time64_t last_ping = now - peer->lp_rtrcheck_timestamp;
 			int down_ni = 0;
 			struct lnet_route *rtr;
 
-			if ((peer->lpni_ping_feats &
-			     LNET_PING_FEAT_NI_STATUS)) {
-				list_for_each_entry(rtr, &peer->lpni_routes,
+			if (nrtrrefs > 0) {
+				list_for_each_entry(rtr, &peer->lp_routes,
 						    lr_gwlist) {
 					/*
 					 * downis on any route should be the
-- 
1.8.3.1
