From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 19/34] LU-7734 lnet: proper cpt locking
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763561.32103.4423090846180857161.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

1. add a per NI credits, which is just the total credits
   assigned on NI creation
2. Whenever percpt credits are added or decremented, we
   mirror that in the NI credits
3. We use the NI credits to determine best NI
4. After we have completed the peer_ni/ni selection we
   determine the cpt to use for locking:
	cpt_of_nid(lpni->nid, ni)

The lpni_cpt is not enough to protect all the fields in the
lnet_peer_ni structure. This is due to the fact that multiple
NIs can talk to the same peer, and functions can be called with
different cpts locked. To properly protect the fields in the
lnet_peer_ni structure, a spin lock is introduced for the
purpose.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ief7868c3c8ff7e00ea9e908dd50d8cef77d9f9a4
Reviewed-on: http://review.whamcloud.com/20701
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |   15 +++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    3 +
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   58 ++++++++++++------
 drivers/staging/lustre/lnet/lnet/peer.c            |    2 +
 drivers/staging/lustre/lnet/lnet/router.c          |   63 +++++++++++++++++++-
 5 files changed, 113 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 71ec0eaf8200..90a5c6e40dea 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -330,6 +330,9 @@ struct lnet_ni {
 	/* instance-specific data */
 	void			*ni_data;
 
+	/* per ni credits */
+	atomic_t		ni_tx_credits;
+
 	/* percpt TX queues */
 	struct lnet_tx_queue	**ni_tx_queues;
 
@@ -414,6 +417,8 @@ struct lnet_peer_ni {
 	struct list_head	 lpni_rtr_list;
 	/* statistics kept on each peer NI */
 	struct lnet_element_stats lpni_stats;
+	/* spin lock protecting credits and lpni_txq / lpni_rtrq */
+	spinlock_t		lpni_lock;
 	/* # tx credits available */
 	int			 lpni_txcredits;
 	struct lnet_peer_net	*lpni_peer_net;
@@ -424,13 +429,13 @@ struct lnet_peer_ni {
 	/* low water mark */
 	int			 lpni_minrtrcredits;
 	/* alive/dead? */
-	unsigned int		 lpni_alive:1;
+	bool			 lpni_alive;
 	/* notification outstanding? */
-	unsigned int		 lpni_notify:1;
+	bool			 lpni_notify;
 	/* outstanding notification for LND? */
-	unsigned int		 lpni_notifylnd:1;
+	bool			 lpni_notifylnd;
 	/* some thread is handling notification */
-	unsigned int		 lpni_notifying:1;
+	bool			 lpni_notifying;
 	/* SEND event outstanding from ping */
 	unsigned int		 lpni_ping_notsent;
 	/* # times router went dead<->alive */
@@ -461,7 +466,7 @@ struct lnet_peer_ni {
 	u32			lpni_seq;
 	/* health flag */
 	bool			lpni_healthy;
-	/* returned RC ping features */
+	/* returned RC ping features. Protected with lpni_lock */
 	unsigned int		 lpni_ping_feats;
 	/* routers on this peer */
 	struct list_head	 lpni_routes;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index d3db4853c690..9807cfb3a0fc 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1382,6 +1382,9 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
 	seed = LNET_NIDADDR(ni->ni_nid);
 	add_device_randomness(&seed, sizeof(seed));
 
+	atomic_set(&ni->ni_tx_credits,
+		   lnet_ni_tq_credits(ni) * ni->ni_ncpts);
+
 	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
 	       libcfs_nid2str(ni->ni_nid),
 		ni->ni_net->net_tunables.lct_peer_tx_credits,
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5d9acce26287..51224a4cb218 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -488,18 +488,26 @@ lnet_ni_eager_recv(struct lnet_ni *ni, struct lnet_msg *msg)
 	return rc;
 }
 
-/* NB: caller shall hold a ref on 'lp' as I'd drop lnet_net_lock */
+/*
+ * This function can be called from two paths:
+ *	1. when sending a message
+ *	2. when decommiting a message (lnet_msg_decommit_tx())
+ * In both these cases the peer_ni should have it's reference count
+ * acquired by the caller and therefore it is safe to drop the spin
+ * lock before calling lnd_query()
+ */
 static void
 lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
 {
 	time64_t last_alive = 0;
+	int cpt = lnet_cpt_of_nid_locked(lp->lpni_nid, ni);
 
 	LASSERT(lnet_peer_aliveness_enabled(lp));
 	LASSERT(ni->ni_net->net_lnd->lnd_query);
 
-	lnet_net_unlock(lp->lpni_cpt);
+	lnet_net_unlock(cpt);
 	ni->ni_net->net_lnd->lnd_query(ni, lp->lpni_nid, &last_alive);
-	lnet_net_lock(lp->lpni_cpt);
+	lnet_net_lock(cpt);
 
 	lp->lpni_last_query = ktime_get_seconds();
 
@@ -519,9 +527,12 @@ lnet_peer_is_alive(struct lnet_peer_ni *lp, unsigned long now)
 	/* Trust lnet_notify() if it has more recent aliveness news, but
 	 * ignore the initial assumed death (see lnet_peers_start_down()).
 	 */
+	spin_lock(&lp->lpni_lock);
 	if (!lp->lpni_alive && lp->lpni_alive_count > 0 &&
-	    lp->lpni_timestamp >= lp->lpni_last_alive)
+	    lp->lpni_timestamp >= lp->lpni_last_alive) {
+		spin_unlock(&lp->lpni_lock);
 		return 0;
+	}
 
 	deadline = lp->lpni_last_alive +
 		lp->lpni_net->net_tunables.lct_peer_timeout;
@@ -532,8 +543,12 @@ lnet_peer_is_alive(struct lnet_peer_ni *lp, unsigned long now)
 	 * case, and moreover lpni_last_alive at peer creation is assumed.
 	 */
 	if (alive && !lp->lpni_alive &&
-	    !(lnet_isrouter(lp) && !lp->lpni_alive_count))
+	    !(lnet_isrouter(lp) && !lp->lpni_alive_count)) {
+		spin_unlock(&lp->lpni_lock);
 		lnet_notify_locked(lp, 0, 1, lp->lpni_last_alive);
+	} else {
+		spin_unlock(&lp->lpni_lock);
+	}
 
 	return alive;
 }
@@ -665,6 +680,7 @@ lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 
 		msg->msg_txcredit = 1;
 		tq->tq_credits--;
+		atomic_dec(&ni->ni_tx_credits);
 
 		if (tq->tq_credits < tq->tq_credits_min)
 			tq->tq_credits_min = tq->tq_credits;
@@ -798,6 +814,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
 			!list_empty(&tq->tq_delayed));
 
 		tq->tq_credits++;
+		atomic_inc(&ni->ni_tx_credits);
 		if (tq->tq_credits <= 0) {
 			msg2 = list_entry(tq->tq_delayed.next,
 					  struct lnet_msg, msg_list);
@@ -1271,9 +1288,13 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 *	3. Round Robin
 		 */
 		while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
+			int ni_credits;
+
 			if (!lnet_is_ni_healthy_locked(ni))
 				continue;
 
+			ni_credits = atomic_read(&ni->ni_tx_credits);
+
 			/*
 			 * calculate the distance from the cpt on which
 			 * the message memory is allocated to the CPT of
@@ -1349,11 +1370,9 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 				 * select using credits followed by Round
 				 * Robin.
 				 */
-				if (ni->ni_tx_queues[cpt]->tq_credits <
-				    best_credits) {
+				if (ni_credits < best_credits) {
 					continue;
-				} else if (ni->ni_tx_queues[cpt]->tq_credits ==
-					   best_credits) {
+				} else if (ni_credits == best_credits) {
 					if (best_ni &&
 					    best_ni->ni_seq <= ni->ni_seq)
 						continue;
@@ -1361,7 +1380,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			}
 set_ni:
 			best_ni = ni;
-			best_credits = ni->ni_tx_queues[cpt]->tq_credits;
+			best_credits = ni_credits;
 		}
 	}
 	/*
@@ -1539,13 +1558,15 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 
 send:
 	/*
-	 * determine the cpt to use and if it has changed then
-	 * lock the new cpt and check if the config has changed.
-	 * If it has changed then repeat the algorithm since the
-	 * ni or peer list could have changed and the algorithm
-	 * would endup picking a different ni/peer_ni pair.
+	 * Use lnet_cpt_of_nid() to determine the CPT used to commit the
+	 * message. This ensures that we get a CPT that is correct for
+	 * the NI when the NI has been restricted to a subset of all CPTs.
+	 * If the selected CPT differs from the one currently locked, we
+	 * must unlock and relock the lnet_net_lock(), and then check whether
+	 * the configuration has changed. We don't have a hold on the best_ni
+	 * or best_peer_ni yet, and they may have vanished.
 	 */
-	cpt2 = best_lpni->lpni_cpt;
+	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
 	if (cpt != cpt2) {
 		lnet_net_unlock(cpt);
 		cpt = cpt2;
@@ -1699,7 +1720,7 @@ lnet_parse_put(struct lnet_ni *ni, struct lnet_msg *msg)
 	info.mi_rlength	= hdr->payload_length;
 	info.mi_roffset	= hdr->msg.put.offset;
 	info.mi_mbits	= hdr->msg.put.match_bits;
-	info.mi_cpt	= msg->msg_rxpeer->lpni_cpt;
+	info.mi_cpt	= lnet_cpt_of_nid(msg->msg_rxpeer->lpni_nid, ni);
 
 	msg->msg_rx_ready_delay = !ni->ni_net->net_lnd->lnd_eager_recv;
 	ready_delay = msg->msg_rx_ready_delay;
@@ -2326,8 +2347,7 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 		 * called lnet_drop_message(), so I just hang onto msg as well
 		 * until that's done
 		 */
-		lnet_drop_message(msg->msg_rxni,
-				  msg->msg_rxpeer->lpni_cpt,
+		lnet_drop_message(msg->msg_rxni, msg->msg_rx_cpt,
 				  msg->msg_private, msg->msg_len);
 		/*
 		 * NB: message will not generate event because w/o attached MD,
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index c2a04526a59a..dc4527f86113 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -117,6 +117,8 @@ lnet_peer_ni_alloc(lnet_nid_t nid)
 	INIT_LIST_HEAD(&lpni->lpni_on_peer_net_list);
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 
+	spin_lock_init(&lpni->lpni_lock);
+
 	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
 	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
 	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 1c79a19f5a25..d3c41f5664a4 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -108,11 +108,20 @@ lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 		return;
 	}
 
+	/*
+	 * This function can be called with different cpt locks being
+	 * held. lpni_alive_count modification needs to be properly protected.
+	 * Significant reads to lpni_alive_count are also protected with
+	 * the same lock
+	 */
+	spin_lock(&lp->lpni_lock);
+
 	lp->lpni_timestamp = when;		/* update timestamp */
 	lp->lpni_ping_deadline = 0;	       /* disable ping timeout */
 
 	if (lp->lpni_alive_count &&	  /* got old news */
 	    (!lp->lpni_alive) == (!alive)) {      /* new date for old news */
+		spin_unlock(&lp->lpni_lock);
 		CDEBUG(D_NET, "Old news\n");
 		return;
 	}
@@ -120,15 +129,20 @@ lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 	/* Flag that notification is outstanding */
 
 	lp->lpni_alive_count++;
-	lp->lpni_alive = !(!alive);	       /* 1 bit! */
+	lp->lpni_alive = !!alive;	/* 1 bit! */
 	lp->lpni_notify = 1;
-	lp->lpni_notifylnd |= notifylnd;
+	lp->lpni_notifylnd = notifylnd;
 	if (lp->lpni_alive)
 		lp->lpni_ping_feats = LNET_PING_FEAT_INVAL; /* reset */
 
+	spin_unlock(&lp->lpni_lock);
+
 	CDEBUG(D_NET, "set %s %d\n", libcfs_nid2str(lp->lpni_nid), alive);
 }
 
+/*
+ * This function will always be called with lp->lpni_cpt lock held.
+ */
 static void
 lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
 {
@@ -140,11 +154,19 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
 	 * NB individual events can be missed; the only guarantee is that you
 	 * always get the most recent news
 	 */
-	if (lp->lpni_notifying || !ni)
+	spin_lock(&lp->lpni_lock);
+
+	if (lp->lpni_notifying || !ni) {
+		spin_unlock(&lp->lpni_lock);
 		return;
+	}
 
 	lp->lpni_notifying = 1;
 
+	/*
+	 * lp->lpni_notify needs to be protected because it can be set in
+	 * lnet_notify_locked().
+	 */
 	while (lp->lpni_notify) {
 		alive = lp->lpni_alive;
 		notifylnd = lp->lpni_notifylnd;
@@ -153,6 +175,7 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
 		lp->lpni_notify    = 0;
 
 		if (notifylnd && ni->ni_net->net_lnd->lnd_notify) {
+			spin_unlock(&lp->lpni_lock);
 			lnet_net_unlock(lp->lpni_cpt);
 
 			/*
@@ -163,10 +186,12 @@ lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer_ni *lp)
 							alive);
 
 			lnet_net_lock(lp->lpni_cpt);
+			spin_lock(&lp->lpni_lock);
 		}
 	}
 
 	lp->lpni_notifying = 0;
+	spin_unlock(&lp->lpni_lock);
 }
 
 static void
@@ -623,6 +648,12 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 	if (!gw->lpni_alive)
 		return;
 
+	/*
+	 * Protect gw->lpni_ping_feats. This can be set from
+	 * lnet_notify_locked with different locks being held
+	 */
+	spin_lock(&gw->lpni_lock);
+
 	if (info->pi_magic == __swab32(LNET_PROTO_PING_MAGIC))
 		lnet_swap_pinginfo(info);
 
@@ -631,6 +662,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 		CDEBUG(D_NET, "%s: Unexpected magic %08x\n",
 		       libcfs_nid2str(gw->lpni_nid), info->pi_magic);
 		gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
+		spin_unlock(&gw->lpni_lock);
 		return;
 	}
 
@@ -638,11 +670,14 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_MASK)) {
 		CDEBUG(D_NET, "%s: Unexpected features 0x%x\n",
 		       libcfs_nid2str(gw->lpni_nid), gw->lpni_ping_feats);
+		spin_unlock(&gw->lpni_lock);
 		return; /* nothing I can understand */
 	}
 
-	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS))
+	if (!(gw->lpni_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
+		spin_unlock(&gw->lpni_lock);
 		return; /* can't carry NI status info */
+	}
 
 	list_for_each_entry(rte, &gw->lpni_routes, lr_gwlist) {
 		int down = 0;
@@ -662,6 +697,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 				CDEBUG(D_NET, "%s: unexpected LNET_NID_ANY\n",
 				       libcfs_nid2str(gw->lpni_nid));
 				gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
+				spin_unlock(&gw->lpni_lock);
 				return;
 			}
 
@@ -684,6 +720,7 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 			CDEBUG(D_NET, "%s: Unexpected status 0x%x\n",
 			       libcfs_nid2str(gw->lpni_nid), stat->ns_status);
 			gw->lpni_ping_feats = LNET_PING_FEAT_INVAL;
+			spin_unlock(&gw->lpni_lock);
 			return;
 		}
 
@@ -700,6 +737,8 @@ lnet_parse_rc_info(struct lnet_rc_data *rcd)
 
 		rte->lr_downis = down;
 	}
+
+	spin_unlock(&gw->lpni_lock);
 }
 
 static void
@@ -773,10 +812,14 @@ lnet_wait_known_routerstate(void)
 
 		all_known = 1;
 		list_for_each_entry(rtr, &the_lnet.ln_routers, lpni_rtr_list) {
+			spin_lock(&rtr->lpni_lock);
+
 			if (!rtr->lpni_alive_count) {
 				all_known = 0;
+				spin_unlock(&rtr->lpni_lock);
 				break;
 			}
+			spin_unlock(&rtr->lpni_lock);
 		}
 
 		lnet_net_unlock(cpt);
@@ -1744,6 +1787,18 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
 		return 0;
 	}
 
+	/*
+	 * It is possible for this function to be called for the same peer
+	 * but with different NIs. We want to synchronize the notification
+	 * between the different calls. So we will use the lpni_cpt to
+	 * grab the net lock.
+	 */
+	if (lp->lpni_cpt != cpt) {
+		lnet_net_unlock(cpt);
+		cpt = lp->lpni_cpt;
+		lnet_net_lock(cpt);
+	}
+
 	/*
 	 * We can't fully trust LND on reporting exact peer last_alive
 	 * if he notifies us about dead peer. For example ksocklnd can
