From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:14 +1000
Subject: [lustre-devel] [PATCH 01/34] lnet: replace all lp_ fields with lpni_
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763488.32103.14222362329822520874.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

sed -i 's/\blp_/lpni_/g' `git grep -l '\blp_' drivers/staging/lustre/lnet | grep '\.[ch]$'`
followed by some long-line cleanups.

This is part of
    Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
from upstream lustre, where it is marked:
    Signed-off-by: Amir Shehata <amir.shehata@intel.com>
    WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
    Reviewed-on: http://review.whamcloud.com/18293
    Reviewed-by: Olaf Weber <olaf@sgi.com>
    Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   24 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   63 +++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  146 +++++++------
 drivers/staging/lustre/lnet/lnet/peer.c            |  125 ++++++-----
 drivers/staging/lustre/lnet/lnet/router.c          |  218 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   52 ++---
 6 files changed, 316 insertions(+), 312 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 5ee770cd7a5f..9b54a3d72290 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -79,10 +79,10 @@ extern struct lnet the_lnet;	/* THE network */
 static inline int lnet_is_route_alive(struct lnet_route *route)
 {
 	/* gateway is down */
-	if (!route->lr_gateway->lp_alive)
+	if (!route->lr_gateway->lpni_alive)
 		return 0;
 	/* no NI status, assume it's alive */
-	if ((route->lr_gateway->lp_ping_feats &
+	if ((route->lr_gateway->lpni_ping_feats &
 	     LNET_PING_FEAT_NI_STATUS) == 0)
 		return 1;
 	/* has NI status, check # down NIs */
@@ -313,8 +313,8 @@ lnet_handle2me(struct lnet_handle_me *handle)
 static inline void
 lnet_peer_addref_locked(struct lnet_peer *lp)
 {
-	LASSERT(lp->lp_refcount > 0);
-	lp->lp_refcount++;
+	LASSERT(lp->lpni_refcount > 0);
+	lp->lpni_refcount++;
 }
 
 void lnet_destroy_peer_locked(struct lnet_peer *lp);
@@ -322,16 +322,16 @@ void lnet_destroy_peer_locked(struct lnet_peer *lp);
 static inline void
 lnet_peer_decref_locked(struct lnet_peer *lp)
 {
-	LASSERT(lp->lp_refcount > 0);
-	lp->lp_refcount--;
-	if (!lp->lp_refcount)
+	LASSERT(lp->lpni_refcount > 0);
+	lp->lpni_refcount--;
+	if (!lp->lpni_refcount)
 		lnet_destroy_peer_locked(lp);
 }
 
 static inline int
 lnet_isrouter(struct lnet_peer *lp)
 {
-	return lp->lp_rtr_refcount ? 1 : 0;
+	return lp->lpni_rtr_refcount ? 1 : 0;
 }
 
 static inline void
@@ -652,10 +652,10 @@ int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 static inline void
 lnet_peer_set_alive(struct lnet_peer *lp)
 {
-	lp->lp_last_query = ktime_get_seconds();
-	lp->lp_last_alive = lp->lp_last_query;
-	if (!lp->lp_alive)
-		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
+	lp->lpni_last_query = ktime_get_seconds();
+	lp->lpni_last_alive = lp->lpni_last_query;
+	if (!lp->lpni_alive)
+		lnet_notify_locked(lp, 0, 1, lp->lpni_last_alive);
 }
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 8bc72f25a897..59a1a2620675 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -385,61 +385,61 @@ struct lnet_rc_data {
 
 struct lnet_peer {
 	/* chain on peer hash */
-	struct list_head	 lp_hashlist;
+	struct list_head	 lpni_hashlist;
 	/* messages blocking for tx credits */
-	struct list_head	 lp_txq;
+	struct list_head	 lpni_txq;
 	/* messages blocking for router credits */
-	struct list_head	 lp_rtrq;
+	struct list_head	 lpni_rtrq;
 	/* chain on router list */
-	struct list_head	 lp_rtr_list;
+	struct list_head	 lpni_rtr_list;
 	/* # tx credits available */
-	int			 lp_txcredits;
+	int			 lpni_txcredits;
 	/* low water mark */
-	int			 lp_mintxcredits;
+	int			 lpni_mintxcredits;
 	/* # router credits */
-	int			 lp_rtrcredits;
+	int			 lpni_rtrcredits;
 	/* low water mark */
-	int			 lp_minrtrcredits;
+	int			 lpni_minrtrcredits;
 	/* alive/dead? */
-	unsigned int		 lp_alive:1;
+	unsigned int		 lpni_alive:1;
 	/* notification outstanding? */
-	unsigned int		 lp_notify:1;
+	unsigned int		 lpni_notify:1;
 	/* outstanding notification for LND? */
-	unsigned int		 lp_notifylnd:1;
+	unsigned int		 lpni_notifylnd:1;
 	/* some thread is handling notification */
-	unsigned int		 lp_notifying:1;
+	unsigned int		 lpni_notifying:1;
 	/* SEND event outstanding from ping */
-	unsigned int		 lp_ping_notsent;
+	unsigned int		 lpni_ping_notsent;
 	/* # times router went dead<->alive */
-	int			 lp_alive_count;
+	int			 lpni_alive_count;
 	 /* ytes queued for sending */
-	long			 lp_txqnob;
+	long			 lpni_txqnob;
 	/* time of last aliveness news */
-	time64_t		 lp_timestamp;
+	time64_t		 lpni_timestamp;
 	/* time of last ping attempt */
-	time64_t		 lp_ping_timestamp;
+	time64_t		 lpni_ping_timestamp;
 	/* != 0 if ping reply expected */
-	time64_t		 lp_ping_deadline;
+	time64_t		 lpni_ping_deadline;
 	/* when I was last alive */
-	time64_t		 lp_last_alive;
-	/* when lp_ni was queried last time */
-	time64_t		 lp_last_query;
+	time64_t		 lpni_last_alive;
+	/* when lpni_ni was queried last time */
+	time64_t		 lpni_last_query;
 	/* network peer is on */
-	struct lnet_net		*lp_net;
+	struct lnet_net		*lpni_net;
 	/* peer's NID */
-	lnet_nid_t		 lp_nid;
+	lnet_nid_t		 lpni_nid;
 	/* # refs */
-	int			 lp_refcount;
+	int			 lpni_refcount;
 	/* CPT this peer attached on */
-	int			 lp_cpt;
+	int			 lpni_cpt;
 	/* # refs from lnet_route::lr_gateway */
-	int			 lp_rtr_refcount;
+	int			 lpni_rtr_refcount;
 	/* returned RC ping features */
-	unsigned int		 lp_ping_feats;
+	unsigned int		 lpni_ping_feats;
 	/* routers on this peer */
-	struct list_head	 lp_routes;
+	struct list_head	 lpni_routes;
 	/* router checker state */
-	struct lnet_rc_data	*lp_rcd;
+	struct lnet_rc_data	*lpni_rcd;
 };
 
 /* peer hash size */
@@ -464,8 +464,9 @@ struct lnet_peer_table {
  * peer aliveness is enabled only on routers for peers in a network where the
  * lnet_ni::ni_peertimeout has been set to a positive value
  */
-#define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing && \
-					 (lp)->lp_net->net_tunables.lct_peer_timeout > 0)
+#define lnet_peer_aliveness_enabled(lp)				\
+	(the_lnet.ln_routing &&					\
+	 (lp)->lpni_net->net_tunables.lct_peer_timeout > 0)
 
 struct lnet_route {
 	/* chain on net */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index b75ebc236f3a..5879a109d46a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -481,7 +481,7 @@ lnet_ni_eager_recv(struct lnet_ni *ni, struct lnet_msg *msg)
 					&msg->msg_private);
 	if (rc) {
 		CERROR("recv from %s / send to %s aborted: eager_recv failed %d\n",
-		       libcfs_nid2str(msg->msg_rxpeer->lp_nid),
+		       libcfs_nid2str(msg->msg_rxpeer->lpni_nid),
 		       libcfs_id2str(msg->msg_target), rc);
 		LASSERT(rc < 0); /* required by my callers */
 	}
@@ -498,14 +498,14 @@ lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 	LASSERT(lnet_peer_aliveness_enabled(lp));
 	LASSERT(ni->ni_net->net_lnd->lnd_query);
 
-	lnet_net_unlock(lp->lp_cpt);
-	ni->ni_net->net_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
-	lnet_net_lock(lp->lp_cpt);
+	lnet_net_unlock(lp->lpni_cpt);
+	ni->ni_net->net_lnd->lnd_query(ni, lp->lpni_nid, &last_alive);
+	lnet_net_lock(lp->lpni_cpt);
 
-	lp->lp_last_query = ktime_get_seconds();
+	lp->lpni_last_query = ktime_get_seconds();
 
 	if (last_alive) /* NI has updated timestamp */
-		lp->lp_last_alive = last_alive;
+		lp->lpni_last_alive = last_alive;
 }
 
 /* NB: always called with lnet_net_lock held */
@@ -520,21 +520,21 @@ lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 	/* Trust lnet_notify() if it has more recent aliveness news, but
 	 * ignore the initial assumed death (see lnet_peers_start_down()).
 	 */
-	if (!lp->lp_alive && lp->lp_alive_count > 0 &&
-	    lp->lp_timestamp >= lp->lp_last_alive)
+	if (!lp->lpni_alive && lp->lpni_alive_count > 0 &&
+	    lp->lpni_timestamp >= lp->lpni_last_alive)
 		return 0;
 
-	deadline = lp->lp_last_alive +
-		lp->lp_net->net_tunables.lct_peer_timeout;
+	deadline = lp->lpni_last_alive +
+		lp->lpni_net->net_tunables.lct_peer_timeout;
 	alive = deadline > now;
 
-	/* Update obsolete lp_alive except for routers assumed to be dead
+	/* Update obsolete lpni_alive except for routers assumed to be dead
 	 * initially, because router checker would update aliveness in this
-	 * case, and moreover lp_last_alive at peer creation is assumed.
+	 * case, and moreover lpni_last_alive at peer creation is assumed.
 	 */
-	if (alive && !lp->lp_alive &&
-	    !(lnet_isrouter(lp) && !lp->lp_alive_count))
-		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
+	if (alive && !lp->lpni_alive &&
+	    !(lnet_isrouter(lp) && !lp->lpni_alive_count))
+		lnet_notify_locked(lp, 0, 1, lp->lpni_last_alive);
 
 	return alive;
 }
@@ -558,19 +558,19 @@ lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 	 * Peer appears dead, but we should avoid frequent NI queries (at
 	 * most once per lnet_queryinterval seconds).
 	 */
-	if (lp->lp_last_query) {
+	if (lp->lpni_last_query) {
 		static const int lnet_queryinterval = 1;
 		time64_t next_query;
 
-		next_query = lp->lp_last_query + lnet_queryinterval;
+		next_query = lp->lpni_last_query + lnet_queryinterval;
 
 		if (now < next_query) {
-			if (lp->lp_alive)
+			if (lp->lpni_alive)
 				CWARN("Unexpected aliveness of peer %s: %lld < %lld (%d/%d)\n",
-				      libcfs_nid2str(lp->lp_nid),
+				      libcfs_nid2str(lp->lpni_nid),
 				      now, next_query,
 				      lnet_queryinterval,
-				      lp->lp_net->net_tunables.lct_peer_timeout);
+				      lp->lpni_net->net_tunables.lct_peer_timeout);
 			return 0;
 		}
 	}
@@ -581,7 +581,7 @@ lnet_peer_alive_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 	if (lnet_peer_is_alive(lp, now))
 		return 1;
 
-	lnet_notify_locked(lp, 0, 0, lp->lp_last_alive);
+	lnet_notify_locked(lp, 0, 0, lp->lpni_last_alive);
 	return 0;
 }
 
@@ -639,19 +639,19 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 	}
 
 	if (!msg->msg_peertxcredit) {
-		LASSERT((lp->lp_txcredits < 0) ==
-			!list_empty(&lp->lp_txq));
+		LASSERT((lp->lpni_txcredits < 0) ==
+			!list_empty(&lp->lpni_txq));
 
 		msg->msg_peertxcredit = 1;
-		lp->lp_txqnob += msg->msg_len + sizeof(struct lnet_hdr);
-		lp->lp_txcredits--;
+		lp->lpni_txqnob += msg->msg_len + sizeof(struct lnet_hdr);
+		lp->lpni_txcredits--;
 
-		if (lp->lp_txcredits < lp->lp_mintxcredits)
-			lp->lp_mintxcredits = lp->lp_txcredits;
+		if (lp->lpni_txcredits < lp->lpni_mintxcredits)
+			lp->lpni_mintxcredits = lp->lpni_txcredits;
 
-		if (lp->lp_txcredits < 0) {
+		if (lp->lpni_txcredits < 0) {
 			msg->msg_tx_delayed = 1;
-			list_add_tail(&msg->msg_list, &lp->lp_txq);
+			list_add_tail(&msg->msg_list, &lp->lpni_txq);
 			return LNET_CREDIT_WAIT;
 		}
 	}
@@ -725,19 +725,19 @@ lnet_post_routed_recv_locked(struct lnet_msg *msg, int do_recv)
 	LASSERT(!do_recv || msg->msg_rx_delayed);
 
 	if (!msg->msg_peerrtrcredit) {
-		LASSERT((lp->lp_rtrcredits < 0) ==
-			!list_empty(&lp->lp_rtrq));
+		LASSERT((lp->lpni_rtrcredits < 0) ==
+			!list_empty(&lp->lpni_rtrq));
 
 		msg->msg_peerrtrcredit = 1;
-		lp->lp_rtrcredits--;
-		if (lp->lp_rtrcredits < lp->lp_minrtrcredits)
-			lp->lp_minrtrcredits = lp->lp_rtrcredits;
+		lp->lpni_rtrcredits--;
+		if (lp->lpni_rtrcredits < lp->lpni_minrtrcredits)
+			lp->lpni_minrtrcredits = lp->lpni_rtrcredits;
 
-		if (lp->lp_rtrcredits < 0) {
+		if (lp->lpni_rtrcredits < 0) {
 			/* must have checked eager_recv before here */
 			LASSERT(msg->msg_rx_ready_delay);
 			msg->msg_rx_delayed = 1;
-			list_add_tail(&msg->msg_list, &lp->lp_rtrq);
+			list_add_tail(&msg->msg_list, &lp->lpni_rtrq);
 			return LNET_CREDIT_WAIT;
 		}
 	}
@@ -811,15 +811,15 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
 		/* give back peer txcredits */
 		msg->msg_peertxcredit = 0;
 
-		LASSERT((txpeer->lp_txcredits < 0) ==
-			!list_empty(&txpeer->lp_txq));
+		LASSERT((txpeer->lpni_txcredits < 0) ==
+			!list_empty(&txpeer->lpni_txq));
 
-		txpeer->lp_txqnob -= msg->msg_len + sizeof(struct lnet_hdr);
-		LASSERT(txpeer->lp_txqnob >= 0);
+		txpeer->lpni_txqnob -= msg->msg_len + sizeof(struct lnet_hdr);
+		LASSERT(txpeer->lpni_txqnob >= 0);
 
-		txpeer->lp_txcredits++;
-		if (txpeer->lp_txcredits <= 0) {
-			msg2 = list_entry(txpeer->lp_txq.next,
+		txpeer->lpni_txcredits++;
+		if (txpeer->lpni_txcredits <= 0) {
+			msg2 = list_entry(txpeer->lpni_txq.next,
 					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
@@ -939,19 +939,19 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
 		/* give back peer router credits */
 		msg->msg_peerrtrcredit = 0;
 
-		LASSERT((rxpeer->lp_rtrcredits < 0) ==
-			!list_empty(&rxpeer->lp_rtrq));
+		LASSERT((rxpeer->lpni_rtrcredits < 0) ==
+			!list_empty(&rxpeer->lpni_rtrq));
 
-		rxpeer->lp_rtrcredits++;
+		rxpeer->lpni_rtrcredits++;
 		/*
 		 * drop all messages which are queued to be routed on that
 		 * peer.
 		 */
 		if (!the_lnet.ln_routing) {
-			lnet_drop_routed_msgs_locked(&rxpeer->lp_rtrq,
+			lnet_drop_routed_msgs_locked(&rxpeer->lpni_rtrq,
 						     msg->msg_rx_cpt);
-		} else if (rxpeer->lp_rtrcredits <= 0) {
-			msg2 = list_entry(rxpeer->lp_rtrq.next,
+		} else if (rxpeer->lpni_rtrcredits <= 0) {
+			msg2 = list_entry(rxpeer->lpni_rtrq.next,
 					  struct lnet_msg, msg_list);
 			list_del(&msg2->msg_list);
 
@@ -988,16 +988,16 @@ lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
 	if (r1_hops > r2_hops)
 		return -ERANGE;
 
-	if (p1->lp_txqnob < p2->lp_txqnob)
+	if (p1->lpni_txqnob < p2->lpni_txqnob)
 		return 1;
 
-	if (p1->lp_txqnob > p2->lp_txqnob)
+	if (p1->lpni_txqnob > p2->lpni_txqnob)
 		return -ERANGE;
 
-	if (p1->lp_txcredits > p2->lp_txcredits)
+	if (p1->lpni_txcredits > p2->lpni_txcredits)
 		return 1;
 
-	if (p1->lp_txcredits < p2->lp_txcredits)
+	if (p1->lpni_txcredits < p2->lpni_txcredits)
 		return -ERANGE;
 
 	if (r1->lr_seq - r2->lr_seq <= 0)
@@ -1014,7 +1014,7 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 	struct lnet_route *route;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
-	struct lnet_peer *lp_best;
+	struct lnet_peer *lpni_best;
 	struct lnet_peer *lp;
 	int rc;
 
@@ -1026,7 +1026,7 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 	if (!rnet)
 		return NULL;
 
-	lp_best = NULL;
+	lpni_best = NULL;
 	best_route = NULL;
 	last_route = NULL;
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
@@ -1035,16 +1035,16 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 		if (!lnet_is_route_alive(route))
 			continue;
 
-		if (net && lp->lp_net != net)
+		if (net && lp->lpni_net != net)
 			continue;
 
-		if (lp->lp_nid == rtr_nid) /* it's pre-determined router */
+		if (lp->lpni_nid == rtr_nid) /* it's pre-determined router */
 			return lp;
 
-		if (!lp_best) {
+		if (!lpni_best) {
 			best_route = route;
 			last_route = route;
-			lp_best = lp;
+			lpni_best = lp;
 			continue;
 		}
 
@@ -1057,7 +1057,7 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 			continue;
 
 		best_route = route;
-		lp_best = lp;
+		lpni_best = lp;
 	}
 
 	/*
@@ -1067,7 +1067,7 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 	 */
 	if (best_route)
 		best_route->lr_seq = last_route->lr_seq + 1;
-	return lp_best;
+	return lpni_best;
 }
 
 int
@@ -1156,7 +1156,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 			/* ENOMEM or shutting down */
 			return rc;
 		}
-		LASSERT(lp->lp_net == src_ni->ni_net);
+		LASSERT(lp->lpni_net == src_ni->ni_net);
 	} else {
 		/* sending to a remote network */
 		lp = lnet_find_route_locked(src_ni ? src_ni->ni_net : NULL,
@@ -1176,27 +1176,27 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 		 * pre-determined router, this can happen if router table
 		 * was changed when we release the lock
 		 */
-		if (rtr_nid != lp->lp_nid) {
-			cpt2 = lp->lp_cpt;
+		if (rtr_nid != lp->lpni_nid) {
+			cpt2 = lp->lpni_cpt;
 			if (cpt2 != cpt) {
 				lnet_net_unlock(cpt);
 
-				rtr_nid = lp->lp_nid;
+				rtr_nid = lp->lpni_nid;
 				cpt = cpt2;
 				goto again;
 			}
 		}
 
 		CDEBUG(D_NET, "Best route to %s via %s for %s %d\n",
-		       libcfs_nid2str(dst_nid), libcfs_nid2str(lp->lp_nid),
+		       libcfs_nid2str(dst_nid), libcfs_nid2str(lp->lpni_nid),
 		       lnet_msgtyp2str(msg->msg_type), msg->msg_len);
 
 		if (!src_ni) {
-			src_ni = lnet_get_next_ni_locked(lp->lp_net, NULL);
+			src_ni = lnet_get_next_ni_locked(lp->lpni_net, NULL);
 			LASSERT(src_ni);
 			src_nid = src_ni->ni_nid;
 		} else {
-			LASSERT(src_ni->ni_net == lp->lp_net);
+			LASSERT(src_ni->ni_net == lp->lpni_net);
 		}
 
 		lnet_peer_addref_locked(lp);
@@ -1210,7 +1210,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 		}
 
 		msg->msg_target_is_router = 1;
-		msg->msg_target.nid = lp->lp_nid;
+		msg->msg_target.nid = lp->lpni_nid;
 		msg->msg_target.pid = LNET_PID_LUSTRE;
 	}
 
@@ -1289,7 +1289,7 @@ lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
 	info.mi_rlength	= hdr->payload_length;
 	info.mi_roffset	= hdr->msg.put.offset;
 	info.mi_mbits	= hdr->msg.put.match_bits;
-	info.mi_cpt	= msg->msg_rxpeer->lp_cpt;
+	info.mi_cpt	= msg->msg_rxpeer->lpni_cpt;
 
 	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
 	ready_delay = msg->msg_rx_ready_delay;
@@ -1520,7 +1520,7 @@ lnet_parse_forward_locked(struct lnet_ni *ni, struct lnet_msg *msg)
 	if (!the_lnet.ln_routing)
 		return -ECANCELED;
 
-	if (msg->msg_rxpeer->lp_rtrcredits <= 0 ||
+	if (msg->msg_rxpeer->lpni_rtrcredits <= 0 ||
 	    lnet_msg2bufpool(msg)->rbp_credits <= 0) {
 		if (!ni->ni_net->net_lnd->lnd_eager_recv) {
 			msg->msg_rx_ready_delay = 1;
@@ -1909,7 +1909,7 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 		 * until that's done
 		 */
 		lnet_drop_message(msg->msg_rxni,
-				  msg->msg_rxpeer->lp_cpt,
+				  msg->msg_rxpeer->lpni_cpt,
 				  msg->msg_private, msg->msg_len);
 		/*
 		 * NB: message will not generate event because w/o attached MD,
@@ -2376,7 +2376,7 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 			hops = shortest_hops;
 			if (srcnidp) {
 				ni = lnet_get_next_ni_locked(
-					shortest->lr_gateway->lp_net,
+					shortest->lr_gateway->lpni_net,
 					NULL);
 				*srcnidp = ni->ni_nid;
 			}
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 42bc35010f64..619d016b1d89 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -111,10 +111,10 @@ lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
 		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
-					 lp_hashlist) {
-			if (ni && ni->ni_net != lp->lp_net)
+					 lpni_hashlist) {
+			if (ni && ni->ni_net != lp->lpni_net)
 				continue;
-			list_del_init(&lp->lp_hashlist);
+			list_del_init(&lp->lpni_hashlist);
 			/* Lose hash table's ref */
 			ptable->pt_zombies++;
 			lnet_peer_decref_locked(lp);
@@ -148,22 +148,22 @@ lnet_peer_table_del_rtrs_locked(struct lnet_ni *ni,
 {
 	struct lnet_peer *lp;
 	struct lnet_peer *tmp;
-	lnet_nid_t lp_nid;
+	lnet_nid_t lpni_nid;
 	int i;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
 		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
-					 lp_hashlist) {
-			if (ni->ni_net != lp->lp_net)
+					 lpni_hashlist) {
+			if (ni->ni_net != lp->lpni_net)
 				continue;
 
-			if (!lp->lp_rtr_refcount)
+			if (!lp->lpni_rtr_refcount)
 				continue;
 
-			lp_nid = lp->lp_nid;
+			lpni_nid = lp->lpni_nid;
 
 			lnet_net_unlock(cpt_locked);
-			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), lp_nid);
+			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), lpni_nid);
 			lnet_net_lock(cpt_locked);
 		}
 	}
@@ -209,8 +209,8 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
 	}
 
 	while (!list_empty(&deathrow)) {
-		lp = list_entry(deathrow.next, struct lnet_peer, lp_hashlist);
-		list_del(&lp->lp_hashlist);
+		lp = list_entry(deathrow.next, struct lnet_peer, lpni_hashlist);
+		list_del(&lp->lpni_hashlist);
 		kfree(lp);
 	}
 }
@@ -220,19 +220,19 @@ lnet_destroy_peer_locked(struct lnet_peer *lp)
 {
 	struct lnet_peer_table *ptable;
 
-	LASSERT(!lp->lp_refcount);
-	LASSERT(!lp->lp_rtr_refcount);
-	LASSERT(list_empty(&lp->lp_txq));
-	LASSERT(list_empty(&lp->lp_hashlist));
-	LASSERT(!lp->lp_txqnob);
+	LASSERT(!lp->lpni_refcount);
+	LASSERT(!lp->lpni_rtr_refcount);
+	LASSERT(list_empty(&lp->lpni_txq));
+	LASSERT(list_empty(&lp->lpni_hashlist));
+	LASSERT(!lp->lpni_txqnob);
 
-	ptable = the_lnet.ln_peer_tables[lp->lp_cpt];
+	ptable = the_lnet.ln_peer_tables[lp->lpni_cpt];
 	LASSERT(ptable->pt_number > 0);
 	ptable->pt_number--;
 
-	lp->lp_net = NULL;
+	lp->lpni_net = NULL;
 
-	list_add(&lp->lp_hashlist, &ptable->pt_deathrow);
+	list_add(&lp->lpni_hashlist, &ptable->pt_deathrow);
 	LASSERT(ptable->pt_zombies > 0);
 	ptable->pt_zombies--;
 }
@@ -246,8 +246,8 @@ lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
 	LASSERT(!the_lnet.ln_shutdown);
 
 	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
-	list_for_each_entry(lp, peers, lp_hashlist) {
-		if (lp->lp_nid == nid) {
+	list_for_each_entry(lp, peers, lpni_hashlist) {
+		if (lp->lpni_nid == nid) {
 			lnet_peer_addref_locked(lp);
 			return lp;
 		}
@@ -281,8 +281,8 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 
 	if (!list_empty(&ptable->pt_deathrow)) {
 		lp = list_entry(ptable->pt_deathrow.next,
-				struct lnet_peer, lp_hashlist);
-		list_del(&lp->lp_hashlist);
+				struct lnet_peer, lpni_hashlist);
+		list_del(&lp->lpni_hashlist);
 	}
 
 	/*
@@ -303,24 +303,24 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 		goto out;
 	}
 
-	INIT_LIST_HEAD(&lp->lp_txq);
-	INIT_LIST_HEAD(&lp->lp_rtrq);
-	INIT_LIST_HEAD(&lp->lp_routes);
-
-	lp->lp_notify = 0;
-	lp->lp_notifylnd = 0;
-	lp->lp_notifying = 0;
-	lp->lp_alive_count = 0;
-	lp->lp_timestamp = 0;
-	lp->lp_alive = !lnet_peers_start_down(); /* 1 bit!! */
-	lp->lp_last_alive = ktime_get_seconds(); /* assumes alive */
-	lp->lp_last_query = 0; /* haven't asked NI yet */
-	lp->lp_ping_timestamp = 0;
-	lp->lp_ping_feats = LNET_PING_FEAT_INVAL;
-	lp->lp_nid = nid;
-	lp->lp_cpt = cpt2;
-	lp->lp_refcount = 2;	/* 1 for caller; 1 for hash */
-	lp->lp_rtr_refcount = 0;
+	INIT_LIST_HEAD(&lp->lpni_txq);
+	INIT_LIST_HEAD(&lp->lpni_rtrq);
+	INIT_LIST_HEAD(&lp->lpni_routes);
+
+	lp->lpni_notify = 0;
+	lp->lpni_notifylnd = 0;
+	lp->lpni_notifying = 0;
+	lp->lpni_alive_count = 0;
+	lp->lpni_timestamp = 0;
+	lp->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
+	lp->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
+	lp->lpni_last_query = 0; /* haven't asked NI yet */
+	lp->lpni_ping_timestamp = 0;
+	lp->lpni_ping_feats = LNET_PING_FEAT_INVAL;
+	lp->lpni_nid = nid;
+	lp->lpni_cpt = cpt2;
+	lp->lpni_refcount = 2;	/* 1 for caller; 1 for hash */
+	lp->lpni_rtr_refcount = 0;
 
 	lnet_net_lock(cpt);
 
@@ -335,13 +335,14 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 		goto out;
 	}
 
-	lp->lp_net = lnet_get_net_locked(LNET_NIDNET(lp->lp_nid));
-	lp->lp_txcredits =
-		lp->lp_mintxcredits = lp->lp_net->net_tunables.lct_peer_tx_credits;
-	lp->lp_rtrcredits =
-		lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_net);
+	lp->lpni_net = lnet_get_net_locked(LNET_NIDNET(lp->lpni_nid));
+	lp->lpni_txcredits =
+		lp->lpni_mintxcredits =
+		lp->lpni_net->net_tunables.lct_peer_tx_credits;
+	lp->lpni_rtrcredits =
+		lp->lpni_minrtrcredits = lnet_peer_buffer_credits(lp->lpni_net);
 
-	list_add_tail(&lp->lp_hashlist,
+	list_add_tail(&lp->lpni_hashlist,
 		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
 	ptable->pt_version++;
 	*lpp = lp;
@@ -349,7 +350,7 @@ lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 	return 0;
 out:
 	if (lp)
-		list_add(&lp->lp_hashlist, &ptable->pt_deathrow);
+		list_add(&lp->lpni_hashlist, &ptable->pt_deathrow);
 	ptable->pt_number--;
 	return rc;
 }
@@ -373,13 +374,13 @@ lnet_debug_peer(lnet_nid_t nid)
 	}
 
 	if (lnet_isrouter(lp) || lnet_peer_aliveness_enabled(lp))
-		aliveness = lp->lp_alive ? "up" : "down";
+		aliveness = lp->lpni_alive ? "up" : "down";
 
 	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
-	       libcfs_nid2str(lp->lp_nid), lp->lp_refcount,
-	       aliveness, lp->lp_net->net_tunables.lct_peer_tx_credits,
-	       lp->lp_rtrcredits, lp->lp_minrtrcredits,
-	       lp->lp_txcredits, lp->lp_mintxcredits, lp->lp_txqnob);
+	       libcfs_nid2str(lp->lpni_nid), lp->lpni_refcount,
+	       aliveness, lp->lpni_net->net_tunables.lct_peer_tx_credits,
+	       lp->lpni_rtrcredits, lp->lpni_minrtrcredits,
+	       lp->lpni_txcredits, lp->lpni_mintxcredits, lp->lpni_txqnob);
 
 	lnet_peer_decref_locked(lp);
 
@@ -420,7 +421,7 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 	for (j = 0; j < LNET_PEER_HASH_SIZE && !found; j++) {
 		struct list_head *peers = &peer_table->pt_hash[j];
 
-		list_for_each_entry(lp, peers, lp_hashlist) {
+		list_for_each_entry(lp, peers, lpni_hashlist) {
 			if (peer_index-- > 0)
 				continue;
 
@@ -428,16 +429,16 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 			if (lnet_isrouter(lp) ||
 			    lnet_peer_aliveness_enabled(lp))
 				snprintf(aliveness, LNET_MAX_STR_LEN,
-					 lp->lp_alive ? "up" : "down");
+					 lp->lpni_alive ? "up" : "down");
 
-			*nid = lp->lp_nid;
-			*refcount = lp->lp_refcount;
+			*nid = lp->lpni_nid;
+			*refcount = lp->lpni_refcount;
 			*ni_peer_tx_credits =
-				lp->lp_net->net_tunables.lct_peer_tx_credits;
-			*peer_tx_credits = lp->lp_txcredits;
-			*peer_rtr_credits = lp->lp_rtrcredits;
-			*peer_min_rtr_credits = lp->lp_mintxcredits;
-			*peer_tx_qnob = lp->lp_txqnob;
+				lp->lpni_net->net_tunables.lct_peer_tx_credits;
+			*peer_tx_credits = lp->lpni_txcredits;
+			*peer_rtr_credits = lp->lpni_rtrcredits;
+			*peer_min_rtr_credits = lp->lpni_mintxcredits;
+			*peer_tx_qnob = lp->lpni_txqnob;
 
 			found = true;
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 2bbd1cf86a8c..2be1ffb6b720 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -103,30 +103,30 @@ void
 lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
 		   time64_t when)
 {
-	if (lp->lp_timestamp > when) { /* out of date information */
+	if (lp->lpni_timestamp > when) { /* out of date information */
 		CDEBUG(D_NET, "Out of date\n");
 		return;
 	}
 
-	lp->lp_timestamp = when;		/* update timestamp */
-	lp->lp_ping_deadline = 0;	       /* disable ping timeout */
+	lp->lpni_timestamp = when;		/* update timestamp */
+	lp->lpni_ping_deadline = 0;	       /* disable ping timeout */
 
-	if (lp->lp_alive_count &&	  /* got old news */
-	    (!lp->lp_alive) == (!alive)) {      /* new date for old news */
+	if (lp->lpni_alive_count &&	  /* got old news */
+	    (!lp->lpni_alive) == (!alive)) {      /* new date for old news */
 		CDEBUG(D_NET, "Old news\n");
 		return;
 	}
 
 	/* Flag that notification is outstanding */
 
-	lp->lp_alive_count++;
-	lp->lp_alive = !(!alive);	       /* 1 bit! */
-	lp->lp_notify = 1;
-	lp->lp_notifylnd |= notifylnd;
-	if (lp->lp_alive)
-		lp->lp_ping_feats = LNET_PING_FEAT_INVAL; /* reset */
+	lp->lpni_alive_count++;
+	lp->lpni_alive = !(!alive);	       /* 1 bit! */
+	lp->lpni_notify = 1;
+	lp->lpni_notifylnd |= notifylnd;
+	if (lp->lpni_alive)
+		lp->lpni_ping_feats = LNET_PING_FEAT_INVAL; /* reset */
 
-	CDEBUG(D_NET, "set %s %d\n", libcfs_nid2str(lp->lp_nid), alive);
+	CDEBUG(D_NET, "set %s %d\n", libcfs_nid2str(lp->lpni_nid), alive);
 }
 
 static void
@@ -140,55 +140,56 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 	 * NB individual events can be missed; the only guarantee is that you
 	 * always get the most recent news
 	 */
-	if (lp->lp_notifying || !ni)
+	if (lp->lpni_notifying || !ni)
 		return;
 
-	lp->lp_notifying = 1;
+	lp->lpni_notifying = 1;
 
-	while (lp->lp_notify) {
-		alive = lp->lp_alive;
-		notifylnd = lp->lp_notifylnd;
+	while (lp->lpni_notify) {
+		alive = lp->lpni_alive;
+		notifylnd = lp->lpni_notifylnd;
 
-		lp->lp_notifylnd = 0;
-		lp->lp_notify    = 0;
+		lp->lpni_notifylnd = 0;
+		lp->lpni_notify    = 0;
 
 		if (notifylnd && ni->ni_net->net_lnd->lnd_notify) {
-			lnet_net_unlock(lp->lp_cpt);
+			lnet_net_unlock(lp->lpni_cpt);
 
 			/*
 			 * A new notification could happen now; I'll handle it
 			 * when control returns to me
 			 */
-			ni->ni_net->net_lnd->lnd_notify(ni, lp->lp_nid, alive);
+			ni->ni_net->net_lnd->lnd_notify(ni, lp->lpni_nid,
+							alive);
 
-			lnet_net_lock(lp->lp_cpt);
+			lnet_net_lock(lp->lpni_cpt);
 		}
 	}
 
-	lp->lp_notifying = 0;
+	lp->lpni_notifying = 0;
 }
 
 static void
 lnet_rtr_addref_locked(struct lnet_peer *lp)
 {
-	LASSERT(lp->lp_refcount > 0);
-	LASSERT(lp->lp_rtr_refcount >= 0);
+	LASSERT(lp->lpni_refcount > 0);
+	LASSERT(lp->lpni_rtr_refcount >= 0);
 
 	/* lnet_net_lock must be exclusively locked */
-	lp->lp_rtr_refcount++;
-	if (lp->lp_rtr_refcount == 1) {
+	lp->lpni_rtr_refcount++;
+	if (lp->lpni_rtr_refcount == 1) {
 		struct list_head *pos;
 
 		/* a simple insertion sort */
 		list_for_each_prev(pos, &the_lnet.ln_routers) {
 			struct lnet_peer *rtr;
 
-			rtr = list_entry(pos, struct lnet_peer, lp_rtr_list);
-			if (rtr->lp_nid < lp->lp_nid)
+			rtr = list_entry(pos, struct lnet_peer, lpni_rtr_list);
+			if (rtr->lpni_nid < lp->lpni_nid)
 				break;
 		}
 
-		list_add(&lp->lp_rtr_list, pos);
+		list_add(&lp->lpni_rtr_list, pos);
 		/* addref for the_lnet.ln_routers */
 		lnet_peer_addref_locked(lp);
 		the_lnet.ln_routers_version++;
@@ -198,21 +199,21 @@ lnet_rtr_addref_locked(struct lnet_peer *lp)
 static void
 lnet_rtr_decref_locked(struct lnet_peer *lp)
 {
-	LASSERT(lp->lp_refcount > 0);
-	LASSERT(lp->lp_rtr_refcount > 0);
+	LASSERT(lp->lpni_refcount > 0);
+	LASSERT(lp->lpni_rtr_refcount > 0);
 
 	/* lnet_net_lock must be exclusively locked */
-	lp->lp_rtr_refcount--;
-	if (!lp->lp_rtr_refcount) {
-		LASSERT(list_empty(&lp->lp_routes));
+	lp->lpni_rtr_refcount--;
+	if (!lp->lpni_rtr_refcount) {
+		LASSERT(list_empty(&lp->lpni_routes));
 
-		if (lp->lp_rcd) {
-			list_add(&lp->lp_rcd->rcd_list,
+		if (lp->lpni_rcd) {
+			list_add(&lp->lpni_rcd->rcd_list,
 				 &the_lnet.ln_rcd_deathrow);
-			lp->lp_rcd = NULL;
+			lp->lpni_rcd = NULL;
 		}
 
-		list_del(&lp->lp_rtr_list);
+		list_del(&lp->lpni_rtr_list);
 		/* decref for the_lnet.ln_routers */
 		lnet_peer_decref_locked(lp);
 		the_lnet.ln_routers_version++;
@@ -279,7 +280,7 @@ lnet_add_route_to_rnet(struct lnet_remotenet *rnet, struct lnet_route *route)
 		offset--;
 	}
 	list_add(&route->lr_list, e);
-	list_add(&route->lr_gwlist, &route->lr_gateway->lp_routes);
+	list_add(&route->lr_gwlist, &route->lr_gateway->lpni_routes);
 
 	the_lnet.ln_remote_nets_version++;
 	lnet_rtr_addref_locked(route->lr_gateway);
@@ -364,14 +365,14 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 		}
 
 		/* our lookups must be true */
-		LASSERT(route2->lr_gateway->lp_nid != gateway);
+		LASSERT(route2->lr_gateway->lpni_nid != gateway);
 	}
 
 	if (add_route) {
 		lnet_peer_addref_locked(route->lr_gateway); /* +1 for notify */
 		lnet_add_route_to_rnet(rnet2, route);
 
-		ni = lnet_get_next_ni_locked(route->lr_gateway->lp_net, NULL);
+		ni = lnet_get_next_ni_locked(route->lr_gateway->lpni_net, NULL);
 		lnet_net_unlock(LNET_LOCK_EX);
 
 		/* XXX Assume alive */
@@ -426,12 +427,12 @@ lnet_check_routes(void)
 					continue;
 				}
 
-				if (route->lr_gateway->lp_net ==
-				    route2->lr_gateway->lp_net)
+				if (route->lr_gateway->lpni_net ==
+				    route2->lr_gateway->lpni_net)
 					continue;
 
-				nid1 = route->lr_gateway->lp_nid;
-				nid2 = route2->lr_gateway->lp_nid;
+				nid1 = route->lr_gateway->lpni_nid;
+				nid2 = route2->lr_gateway->lpni_nid;
 				net = rnet->lrn_net;
 
 				lnet_net_unlock(cpt);
@@ -481,7 +482,7 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
 		list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 			gateway = route->lr_gateway;
 			if (!(gw_nid == LNET_NID_ANY ||
-			      gw_nid == gateway->lp_nid))
+			      gw_nid == gateway->lpni_nid))
 				continue;
 
 			list_del(&route->lr_list);
@@ -575,7 +576,7 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
 					*net      = rnet->lrn_net;
 					*hops     = route->lr_hops;
 					*priority = route->lr_priority;
-					*gateway  = route->lr_gateway->lp_nid;
+					*gateway  = route->lr_gateway->lpni_nid;
 					*alive = lnet_is_route_alive(route);
 					lnet_net_unlock(cpt);
 					return 0;
@@ -616,7 +617,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 	struct lnet_peer *gw = rcd->rcd_gateway;
 	struct lnet_route *rte;
 
-	if (!gw->lp_alive)
+	if (!gw->lpni_alive)
 		return;
 
 	if (info->pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
@@ -625,27 +626,27 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 	/* NB always racing with network! */
 	if (info->pi_magic != LNET_PROTO_PING_MAGIC) {
 		CDEBUG(D_NET, "%s: Unexpected magic %08x\n",
-		       libcfs_nid2str(gw->lp_nid), info->pi_magic);
-		gw->lp_ping_feats = LNET_PING_FEAT_INVAL;
+		       libcfs_nid2str(gw->lpni_nid), info->pi_magic);
+		gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
 		return;
 	}
 
-	gw->lp_ping_feats = info->pi_features;
-	if (!(gw->lp_ping_feats & LNET_PING_FEAT_MASK)) {
+	gw->lpni_ping_feats = info->pi_features;
+	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_MASK)) {
 		CDEBUG(D_NET, "%s: Unexpected features 0x%x\n",
-		       libcfs_nid2str(gw->lp_nid), gw->lp_ping_feats);
+		       libcfs_nid2str(gw->lpni_nid), gw->lpni_ping_feats);
 		return; /* nothing I can understand */
 	}
 
-	if (!(gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS))
+	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS))
 		return; /* can't carry NI status info */
 
-	list_for_each_entry(rte, &gw->lp_routes, lr_gwlist) {
+	list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
 		int down = 0;
 		int up = 0;
 		int i;
 
-		if (gw->lp_ping_feats & LNET_PING_FEAT_RTE_DISABLED) {
+		if (gw->lpni_ping_feats & LNET_PING_FEAT_RTE_DISABLED) {
 			rte->lr_downis = 1;
 			continue;
 		}
@@ -656,8 +657,8 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 
 			if (nid == LNET_NID_ANY) {
 				CDEBUG(D_NET, "%s: unexpected LNET_NID_ANY\n",
-				       libcfs_nid2str(gw->lp_nid));
-				gw->lp_ping_feats = LNET_PING_FEAT_INVAL;
+				       libcfs_nid2str(gw->lpni_nid));
+				gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
 				return;
 			}
 
@@ -678,8 +679,8 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 			}
 
 			CDEBUG(D_NET, "%s: Unexpected status 0x%x\n",
-			       libcfs_nid2str(gw->lp_nid), stat->ns_status);
-			gw->lp_ping_feats = LNET_PING_FEAT_INVAL;
+			       libcfs_nid2str(gw->lpni_nid), stat->ns_status);
+			gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
 			return;
 		}
 
@@ -722,14 +723,14 @@ lnet_router_checker_event(struct lnet_event *event)
 	 * places need to hold both locks at the same time, please take
 	 * care of lock ordering
 	 */
-	lnet_net_lock(lp->lp_cpt);
-	if (!lnet_isrouter(lp) || lp->lp_rcd != rcd) {
+	lnet_net_lock(lp->lpni_cpt);
+	if (!lnet_isrouter(lp) || lp->lpni_rcd != rcd) {
 		/* ignore if no longer a router or rcd is replaced */
 		goto out;
 	}
 
 	if (event->type == LNET_EVENT_SEND) {
-		lp->lp_ping_notsent = 0;
+		lp->lpni_ping_notsent = 0;
 		if (!event->status)
 			goto out;
 	}
@@ -753,7 +754,7 @@ lnet_router_checker_event(struct lnet_event *event)
 		lnet_parse_rc_info(rcd);
 
  out:
-	lnet_net_unlock(lp->lp_cpt);
+	lnet_net_unlock(lp->lpni_cpt);
 }
 
 static void
@@ -768,8 +769,8 @@ lnet_wait_known_routerstate(void)
 		int cpt = lnet_net_lock_current();
 
 		all_known = 1;
-		list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
-			if (!rtr->lp_alive_count) {
+		list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
+			if (!rtr->lpni_alive_count) {
 				all_known = 0;
 				break;
 			}
@@ -789,8 +790,8 @@ lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net)
 {
 	struct lnet_route *rte;
 
-	if ((gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
-		list_for_each_entry(rte, &gw->lp_routes, lr_gwlist) {
+	if ((gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
+		list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
 			if (rte->lr_net == net) {
 				rte->lr_downis = 0;
 				break;
@@ -849,7 +850,7 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
 	LASSERT(LNetMDHandleIsInvalid(rcd->rcd_mdh));
 
 	if (rcd->rcd_gateway) {
-		int cpt = rcd->rcd_gateway->lp_cpt;
+		int cpt = rcd->rcd_gateway->lpni_cpt;
 
 		lnet_net_lock(cpt);
 		lnet_peer_decref_locked(rcd->rcd_gateway);
@@ -870,7 +871,7 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
 	int rc;
 	int i;
 
-	lnet_net_unlock(gateway->lp_cpt);
+	lnet_net_unlock(gateway->lpni_cpt);
 
 	rcd = kzalloc(sizeof(*rcd), GFP_NOFS);
 	if (!rcd)
@@ -904,17 +905,17 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
 	}
 	LASSERT(!rc);
 
-	lnet_net_lock(gateway->lp_cpt);
+	lnet_net_lock(gateway->lpni_cpt);
 	/* router table changed or someone has created rcd for this gateway */
-	if (!lnet_isrouter(gateway) || gateway->lp_rcd) {
-		lnet_net_unlock(gateway->lp_cpt);
+	if (!lnet_isrouter(gateway) || gateway->lpni_rcd) {
+		lnet_net_unlock(gateway->lpni_cpt);
 		goto out;
 	}
 
 	lnet_peer_addref_locked(gateway);
 	rcd->rcd_gateway = gateway;
-	gateway->lp_rcd = rcd;
-	gateway->lp_ping_notsent = 0;
+	gateway->lpni_rcd = rcd;
+	gateway->lpni_ping_notsent = 0;
 
 	return rcd;
 
@@ -927,8 +928,8 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
 		lnet_destroy_rc_data(rcd);
 	}
 
-	lnet_net_lock(gateway->lp_cpt);
-	return gateway->lp_rcd;
+	lnet_net_lock(gateway->lpni_cpt);
+	return gateway->lpni_rcd;
 }
 
 static int
@@ -936,7 +937,7 @@ lnet_router_check_interval(struct lnet_peer *rtr)
 {
 	int secs;
 
-	secs = rtr->lp_alive ? live_router_check_interval :
+	secs = rtr->lpni_alive ? live_router_check_interval :
 			       dead_router_check_interval;
 	if (secs < 0)
 		secs = 0;
@@ -954,12 +955,12 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
 
 	lnet_peer_addref_locked(rtr);
 
-	if (rtr->lp_ping_deadline && /* ping timed out? */
-	    now > rtr->lp_ping_deadline)
+	if (rtr->lpni_ping_deadline && /* ping timed out? */
+	    now > rtr->lpni_ping_deadline)
 		lnet_notify_locked(rtr, 1, 0, now);
 
 	/* Run any outstanding notifications */
-	ni = lnet_get_next_ni_locked(rtr->lp_net, NULL);
+	ni = lnet_get_next_ni_locked(rtr->lpni_net, NULL);
 	lnet_ni_notify_locked(ni, rtr);
 
 	if (!lnet_isrouter(rtr) ||
@@ -969,8 +970,8 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
 		return;
 	}
 
-	rcd = rtr->lp_rcd ?
-	      rtr->lp_rcd : lnet_create_rc_data_locked(rtr);
+	rcd = rtr->lpni_rcd ?
+	      rtr->lpni_rcd : lnet_create_rc_data_locked(rtr);
 
 	if (!rcd)
 		return;
@@ -978,39 +979,40 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
 	secs = lnet_router_check_interval(rtr);
 
 	CDEBUG(D_NET,
-	       "rtr %s %lldd: deadline %lld ping_notsent %d alive %d alive_count %d lp_ping_timestamp %lld\n",
-	       libcfs_nid2str(rtr->lp_nid), secs,
-	       rtr->lp_ping_deadline, rtr->lp_ping_notsent,
-	       rtr->lp_alive, rtr->lp_alive_count, rtr->lp_ping_timestamp);
-
-	if (secs && !rtr->lp_ping_notsent &&
-	    now > rtr->lp_ping_timestamp + secs) {
+	       "rtr %s %lldd: deadline %lld ping_notsent %d alive %d alive_count %d lpni_ping_timestamp %lld\n",
+	       libcfs_nid2str(rtr->lpni_nid), secs,
+	       rtr->lpni_ping_deadline, rtr->lpni_ping_notsent,
+	       rtr->lpni_alive, rtr->lpni_alive_count,
+	       rtr->lpni_ping_timestamp);
+
+	if (secs && !rtr->lpni_ping_notsent &&
+	    now > rtr->lpni_ping_timestamp + secs) {
 		int rc;
 		struct lnet_process_id id;
 		struct lnet_handle_md mdh;
 
-		id.nid = rtr->lp_nid;
+		id.nid = rtr->lpni_nid;
 		id.pid = LNET_PID_LUSTRE;
 		CDEBUG(D_NET, "Check: %s\n", libcfs_id2str(id));
 
-		rtr->lp_ping_notsent   = 1;
-		rtr->lp_ping_timestamp = now;
+		rtr->lpni_ping_notsent   = 1;
+		rtr->lpni_ping_timestamp = now;
 
 		mdh = rcd->rcd_mdh;
 
-		if (!rtr->lp_ping_deadline) {
-			rtr->lp_ping_deadline = ktime_get_seconds() +
+		if (!rtr->lpni_ping_deadline) {
+			rtr->lpni_ping_deadline = ktime_get_seconds() +
 						router_ping_timeout;
 		}
 
-		lnet_net_unlock(rtr->lp_cpt);
+		lnet_net_unlock(rtr->lpni_cpt);
 
 		rc = LNetGet(LNET_NID_ANY, mdh, id, LNET_RESERVED_PORTAL,
 			     LNET_PROTO_PING_MATCHBITS, 0);
 
-		lnet_net_lock(rtr->lp_cpt);
+		lnet_net_lock(rtr->lpni_cpt);
 		if (rc)
-			rtr->lp_ping_notsent = 0; /* no event pending */
+			rtr->lpni_ping_notsent = 0; /* no event pending */
 	}
 
 	lnet_peer_decref_locked(rtr);
@@ -1106,14 +1108,14 @@ lnet_prune_rc_data(int wait_unlink)
 	if (the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING) {
 		/* router checker is stopping, prune all */
 		list_for_each_entry(lp, &the_lnet.ln_routers,
-				    lp_rtr_list) {
-			if (!lp->lp_rcd)
+				    lpni_rtr_list) {
+			if (!lp->lpni_rcd)
 				continue;
 
-			LASSERT(list_empty(&lp->lp_rcd->rcd_list));
-			list_add(&lp->lp_rcd->rcd_list,
+			LASSERT(list_empty(&lp->lpni_rcd->rcd_list));
+			list_add(&lp->lpni_rcd->rcd_list,
 				 &the_lnet.ln_rcd_deathrow);
-			lp->lp_rcd = NULL;
+			lp->lpni_rcd = NULL;
 		}
 	}
 
@@ -1206,8 +1208,8 @@ lnet_router_checker(void *arg)
 rescan:
 		version = the_lnet.ln_routers_version;
 
-		list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
-			cpt2 = rtr->lp_cpt;
+		list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
+			cpt2 = rtr->lpni_cpt;
 			if (cpt != cpt2) {
 				lnet_net_unlock(cpt);
 				cpt = cpt2;
@@ -1745,8 +1747,8 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
 	 * call us with when == _time_when_the_node_was_booted_ if
 	 * no connections were successfully established
 	 */
-	if (ni && !alive && when < lp->lp_last_alive)
-		when = lp->lp_last_alive;
+	if (ni && !alive && when < lp->lpni_last_alive)
+		when = lp->lpni_last_alive;
 
 	lnet_notify_locked(lp, !ni, alive, when);
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 52714b898aac..01c9ad44266f 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -214,7 +214,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			__u32 net = rnet->lrn_net;
 			__u32 hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
-			lnet_nid_t nid = route->lr_gateway->lp_nid;
+			lnet_nid_t nid = route->lr_gateway->lpni_nid;
 			int alive = lnet_is_route_alive(route);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
@@ -306,7 +306,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		while (r != &the_lnet.ln_routers) {
 			struct lnet_peer *lp;
 
-			lp = list_entry(r, struct lnet_peer, lp_rtr_list);
+			lp = list_entry(r, struct lnet_peer, lpni_rtr_list);
 			if (!skip) {
 				peer = lp;
 				break;
@@ -317,21 +317,21 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		}
 
 		if (peer) {
-			lnet_nid_t nid = peer->lp_nid;
+			lnet_nid_t nid = peer->lpni_nid;
 			time64_t now = ktime_get_seconds();
-			time64_t deadline = peer->lp_ping_deadline;
-			int nrefs = peer->lp_refcount;
-			int nrtrrefs = peer->lp_rtr_refcount;
-			int alive_cnt = peer->lp_alive_count;
-			int alive = peer->lp_alive;
-			int pingsent = !peer->lp_ping_notsent;
-			time64_t last_ping = now - peer->lp_ping_timestamp;
+			time64_t deadline = peer->lpni_ping_deadline;
+			int nrefs = peer->lpni_refcount;
+			int nrtrrefs = peer->lpni_rtr_refcount;
+			int alive_cnt = peer->lpni_alive_count;
+			int alive = peer->lpni_alive;
+			int pingsent = !peer->lpni_ping_notsent;
+			time64_t last_ping = now - peer->lpni_ping_timestamp;
 			int down_ni = 0;
 			struct lnet_route *rtr;
 
-			if ((peer->lp_ping_feats &
+			if ((peer->lpni_ping_feats &
 			     LNET_PING_FEAT_NI_STATUS)) {
-				list_for_each_entry(rtr, &peer->lp_routes,
+				list_for_each_entry(rtr, &peer->lpni_routes,
 						    lr_gwlist) {
 					/*
 					 * downis on any route should be the
@@ -452,16 +452,16 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				struct lnet_peer *lp;
 
 				lp = list_entry(p, struct lnet_peer,
-						lp_hashlist);
+						lpni_hashlist);
 				if (!skip) {
 					peer = lp;
 
 					/*
 					 * minor optimization: start from idx+1
 					 * on next iteration if we've just
-					 * drained lp_hashlist
+					 * drained lpni_hashlist
 					 */
-					if (lp->lp_hashlist.next ==
+					if (lp->lpni_hashlist.next ==
 					    &ptable->pt_hash[hash]) {
 						hoff = 1;
 						hash++;
@@ -473,7 +473,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				}
 
 				skip--;
-				p = lp->lp_hashlist.next;
+				p = lp->lpni_hashlist.next;
 			}
 
 			if (peer)
@@ -485,25 +485,25 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 		}
 
 		if (peer) {
-			lnet_nid_t nid = peer->lp_nid;
-			int nrefs = peer->lp_refcount;
+			lnet_nid_t nid = peer->lpni_nid;
+			int nrefs = peer->lpni_refcount;
 			time64_t lastalive = -1;
 			char *aliveness = "NA";
-			int maxcr = peer->lp_net->net_tunables.lct_peer_tx_credits;
-			int txcr = peer->lp_txcredits;
-			int mintxcr = peer->lp_mintxcredits;
-			int rtrcr = peer->lp_rtrcredits;
-			int minrtrcr = peer->lp_minrtrcredits;
-			int txqnob = peer->lp_txqnob;
+			int maxcr = peer->lpni_net->net_tunables.lct_peer_tx_credits;
+			int txcr = peer->lpni_txcredits;
+			int mintxcr = peer->lpni_mintxcredits;
+			int rtrcr = peer->lpni_rtrcredits;
+			int minrtrcr = peer->lpni_minrtrcredits;
+			int txqnob = peer->lpni_txqnob;
 
 			if (lnet_isrouter(peer) ||
 			    lnet_peer_aliveness_enabled(peer))
-				aliveness = peer->lp_alive ? "up" : "down";
+				aliveness = peer->lpni_alive ? "up" : "down";
 
 			if (lnet_peer_aliveness_enabled(peer)) {
 				time64_t now = ktime_get_seconds();
 
-				lastalive = now - peer->lp_last_alive;
+				lastalive = now - peer->lpni_last_alive;
 
 				/* No need to mess up peers contents with
 				 * arbitrarily long integers - it suffices to
