From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 09/34] LU-7734 lnet: Multi-Rail
 local_ni/peer_ni selection
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763518.32103.4120463532750655807.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This patch implements the local_ni/peer_ni selection algorithm.
It adds APIs to the peer module to encapsulate
iterating through the peer_nis in a peer and creating a peer.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ifc0e5ebf84ab25753adfcfcb433b024100f35ace
Reviewed-on: http://review.whamcloud.com/18383
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Tested-by: Jenkins
Tested-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   53 ++
 .../staging/lustre/include/linux/lnet/lib-types.h  |   17 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   20 +
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  522 +++++++++++++++-----
 drivers/staging/lustre/lnet/lnet/peer.c            |  120 ++++-
 5 files changed, 603 insertions(+), 129 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index bf076298de71..6ffe5c1c9925 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -403,6 +403,7 @@ struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
 struct lnet_ni *lnet_net2ni(__u32 net);
 bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
+struct lnet_net *lnet_get_net_locked(u32 net_id);
 
 extern int portal_rotor;
 
@@ -635,13 +636,24 @@ int lnet_parse_networks(struct list_head *nilist, char *networks,
 bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
 		     struct lnet_net **net);
 bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
-
+void lnet_incr_dlc_seq(void);
+u32 lnet_get_dlc_seq_locked(void);
+
+struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
+						  struct lnet_peer_net *peer_net,
+						  struct lnet_peer_ni *prev);
+int lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
+				    struct lnet_peer **peer);
 int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt);
 void lnet_peer_tables_cleanup(struct lnet_ni *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
+struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
+					       u32 net_id);
+bool lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni,
+				 struct lnet_ni *ni);
 int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 		       char alivness[LNET_MAX_STR_LEN],
 		       __u32 *cpt_iter, __u32 *refcount,
@@ -649,6 +661,45 @@ int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 		       __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
 		       __u32 *peer_tx_qnob);
 
+static inline bool
+lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
+{
+	return lpni->lpni_healthy;
+}
+
+static inline void
+lnet_set_peer_ni_health_locked(struct lnet_peer_ni *lpni, bool health)
+{
+	lpni->lpni_healthy = health;
+}
+
+static inline bool
+lnet_is_peer_net_healthy_locked(struct lnet_peer_net *peer_net)
+{
+	struct lnet_peer_ni *lpni;
+
+	list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
+			    lpni_on_peer_net_list) {
+		if (lnet_is_peer_ni_healthy_locked(lpni))
+			return true;
+	}
+
+	return false;
+}
+
+static inline bool
+lnet_is_peer_healthy_locked(struct lnet_peer *peer)
+{
+	struct lnet_peer_net *peer_net;
+
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+		if (lnet_is_peer_net_healthy_locked(peer_net))
+			return true;
+	}
+
+	return false;
+}
+
 static inline void
 lnet_peer_set_alive(struct lnet_peer_ni *lp)
 {
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 9f70c094cc4c..d935d273716d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -346,6 +346,9 @@ struct lnet_ni {
 	/* lnd tunables set explicitly */
 	bool ni_lnd_tunables_set;
 
+	/* sequence number used to round robin over nis within a net */
+	u32			ni_seq;
+
 	/*
 	 * equivalent interfaces to use
 	 * This is an array because socklnd bonding can still be configured
@@ -436,10 +439,18 @@ struct lnet_peer_ni {
 	int			 lpni_cpt;
 	/* # refs from lnet_route::lr_gateway */
 	int			 lpni_rtr_refcount;
+	/* sequence number used to round robin over peer nis within a net */
+	u32			lpni_seq;
+	/* health flag */
+	bool			lpni_healthy;
 	/* returned RC ping features */
 	unsigned int		 lpni_ping_feats;
 	/* routers on this peer */
 	struct list_head	 lpni_routes;
+	/* array of preferred local nids */
+	lnet_nid_t		*lpni_pref_nids;
+	/* number of preferred NIDs in lnpi_pref_nids */
+	u32			lpni_pref_nnids;
 	/* router checker state */
 	struct lnet_rc_data	*lpni_rcd;
 };
@@ -453,6 +464,9 @@ struct lnet_peer {
 
 	/* primary NID of the peer */
 	lnet_nid_t		lp_primary_nid;
+
+	/* peer is Multi-Rail enabled peer */
+	bool			lp_multi_rail;
 };
 
 struct lnet_peer_net {
@@ -467,6 +481,9 @@ struct lnet_peer_net {
 
 	/* Net ID */
 	__u32			lpn_net_id;
+
+	/* health flag */
+	bool			lpn_healthy;
 };
 
 /* peer hash size */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 821b030f9621..e8e0bc45d8aa 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -64,6 +64,15 @@ module_param(use_tcp_bonding, int, 0444);
 MODULE_PARM_DESC(use_tcp_bonding,
 		 "Set to 1 to use socklnd bonding. 0 to use Multi-Rail");
 
+/*
+ * This sequence number keeps track of how many times DLC was used to
+ * update the configuration. It is incremented on any DLC update and
+ * checked when sending a message to determine if there is a need to
+ * re-run the selection algorithm to handle configuration change.
+ * Look at lnet_select_pathway() for more details on its usage.
+ */
+static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
+
 static int lnet_ping(struct lnet_process_id id, signed long timeout,
 		     struct lnet_process_id __user *ids, int n_ids);
 
@@ -1490,6 +1499,7 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 
 	lnet_net_lock(LNET_LOCK_EX);
 	list_splice_tail(&local_ni_list, &net_l->net_ni_list);
+	lnet_incr_dlc_seq();
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* if the network is not unique then we don't want to keep
@@ -2165,6 +2175,16 @@ lnet_dyn_del_ni(__u32 net_id)
 	return rc;
 }
 
+void lnet_incr_dlc_seq(void)
+{
+	atomic_inc(&lnet_dlc_seq_no);
+}
+
+u32 lnet_get_dlc_seq_locked(void)
+{
+	return atomic_read(&lnet_dlc_seq_no);
+}
+
 /**
  * LNet ioctl handler.
  *
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index edbec7e9ed7e..54e3093355c2 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -444,7 +444,6 @@ lnet_prep_send(struct lnet_msg *msg, int type, struct lnet_process_id target,
 
 	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
 	msg->msg_hdr.type	   = cpu_to_le32(type);
-	msg->msg_hdr.dest_nid       = cpu_to_le64(target.nid);
 	msg->msg_hdr.dest_pid       = cpu_to_le32(target.pid);
 	/* src_nid will be set later */
 	msg->msg_hdr.src_pid	= cpu_to_le32(the_lnet.ln_pid);
@@ -836,6 +835,15 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
 	}
 
 	if (txpeer) {
+		/*
+		 * TODO:
+		 * Once the patch for the health comes in we need to set
+		 * the health of the peer ni to bad when we fail to send
+		 * a message.
+		 * int status = msg->msg_ev.status;
+		 * if (status != 0)
+		 *	lnet_set_peer_ni_health_locked(txpeer, false)
+		 */
 		msg->msg_txpeer = NULL;
 		lnet_peer_ni_decref_locked(txpeer);
 	}
@@ -968,6 +976,24 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
 	}
 }
 
+static int
+lnet_compare_peers(struct lnet_peer_ni *p1, struct lnet_peer_ni *p2)
+{
+	if (p1->lpni_txqnob < p2->lpni_txqnob)
+		return 1;
+
+	if (p1->lpni_txqnob > p2->lpni_txqnob)
+		return -1;
+
+	if (p1->lpni_txcredits > p2->lpni_txcredits)
+		return 1;
+
+	if (p1->lpni_txcredits < p2->lpni_txcredits)
+		return -1;
+
+	return 0;
+}
+
 static int
 lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
 {
@@ -975,35 +1001,28 @@ lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
 	struct lnet_peer_ni *p2 = r2->lr_gateway;
 	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
 	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
+	int rc;
 
 	if (r1->lr_priority < r2->lr_priority)
 		return 1;
 
 	if (r1->lr_priority > r2->lr_priority)
-		return -ERANGE;
+		return -1;
 
 	if (r1_hops < r2_hops)
 		return 1;
 
 	if (r1_hops > r2_hops)
-		return -ERANGE;
-
-	if (p1->lpni_txqnob < p2->lpni_txqnob)
-		return 1;
-
-	if (p1->lpni_txqnob > p2->lpni_txqnob)
-		return -ERANGE;
-
-	if (p1->lpni_txcredits > p2->lpni_txcredits)
-		return 1;
+		return -1;
 
-	if (p1->lpni_txcredits < p2->lpni_txcredits)
-		return -ERANGE;
+	rc = lnet_compare_peers(p1, p2);
+	if (rc)
+		return rc;
 
 	if (r1->lr_seq - r2->lr_seq <= 0)
 		return 1;
 
-	return -ERANGE;
+	return -1;
 }
 
 static struct lnet_peer_ni *
@@ -1070,171 +1089,430 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 	return lpni_best;
 }
 
-int
-lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
+static int
+lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
+		    struct lnet_msg *msg, lnet_nid_t rtr_nid, bool *lo_sent)
 {
-	lnet_nid_t dst_nid = msg->msg_target.nid;
-	struct lnet_ni *src_ni;
-	struct lnet_ni *local_ni;
-	struct lnet_peer_ni *lp;
-	int cpt;
-	int cpt2;
-	int rc;
-
+	struct lnet_ni *best_ni = NULL;
+	struct lnet_peer_ni *best_lpni = NULL;
+	struct lnet_peer_ni *net_gw = NULL;
+	struct lnet_peer_ni *best_gw = NULL;
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer *peer = NULL;
+	struct lnet_peer_net *peer_net;
+	struct lnet_net *local_net;
+	struct lnet_ni *ni = NULL;
+	int cpt, cpt2, rc;
+	bool routing = false;
+	bool ni_is_pref = false;
+	bool preferred = false;
+	int best_credits = 0;
+	u32 seq, seq2;
+	int best_lpni_credits = INT_MIN;
+
+again:
 	/*
-	 * NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
-	 * but we might want to use pre-determined router for ACK/REPLY
-	 * in the future
+	 * get an initial CPT to use for locking. The idea here is not to
+	 * serialize the calls to select_pathway, so that as many
+	 * operations can run concurrently as possible. To do that we use
+	 * the CPT where this call is being executed. Later on when we
+	 * determine the CPT to use in lnet_message_commit, we switch the
+	 * lock and check if there was any configuration changes, if none,
+	 * then we proceed, if there is, then we'll need to update the cpt
+	 * and redo the operation.
 	 */
-	/* NB: ni == interface pre-determined (ACK/REPLY) */
-	LASSERT(!msg->msg_txpeer);
-	LASSERT(!msg->msg_sending);
-	LASSERT(!msg->msg_target_is_router);
-	LASSERT(!msg->msg_receiving);
+	cpt = lnet_net_lock_current();
 
-	msg->msg_sending = 1;
-
-	LASSERT(!msg->msg_tx_committed);
-	local_ni = lnet_net2ni(LNET_NIDNET(dst_nid));
-	cpt = lnet_cpt_of_nid(rtr_nid == LNET_NID_ANY ? dst_nid : rtr_nid,
-			      local_ni);
- again:
-	lnet_net_lock(cpt);
+	best_gw = NULL;
+	routing = false;
+	local_net = NULL;
+	best_ni = NULL;
 
 	if (the_lnet.ln_shutdown) {
 		lnet_net_unlock(cpt);
 		return -ESHUTDOWN;
 	}
 
-	if (src_nid == LNET_NID_ANY) {
-		src_ni = NULL;
-	} else {
-		src_ni = lnet_nid2ni_locked(src_nid, cpt);
-		if (!src_ni) {
+	/*
+	 * initialize the variables which could be reused if we go to
+	 * again
+	 */
+	lpni = NULL;
+	seq = lnet_get_dlc_seq_locked();
+
+	rc = lnet_find_or_create_peer_locked(dst_nid, cpt, &peer);
+	if (rc != 0) {
+		lnet_net_unlock(cpt);
+		return rc;
+	}
+
+	/* If peer is not healthy then can not send anything to it */
+	if (!lnet_is_peer_healthy_locked(peer)) {
+		lnet_net_unlock(cpt);
+		return -EHOSTUNREACH;
+	}
+
+	/*
+	 * STEP 1: first jab at determineing best_ni
+	 * if src_nid is explicitly specified, then best_ni is already
+	 * pre-determiend for us. Otherwise we need to select the best
+	 * one to use later on
+	 */
+	if (src_nid != LNET_NID_ANY) {
+		best_ni = lnet_nid2ni_locked(src_nid, cpt);
+		if (!best_ni) {
 			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("Can't send to %s: src %s is not a local nid\n",
 				      libcfs_nid2str(dst_nid),
 				      libcfs_nid2str(src_nid));
 			return -EINVAL;
 		}
-		LASSERT(!msg->msg_routing);
-	}
-
-	/* Is this for someone on a local network? */
-	local_ni = lnet_net2ni_locked(LNET_NIDNET(dst_nid), cpt);
 
-	if (local_ni) {
-		if (!src_ni) {
-			src_ni = local_ni;
-			src_nid = src_ni->ni_nid;
-		} else if (src_ni != local_ni) {
+		if (best_ni->ni_net->net_id != LNET_NIDNET(dst_nid)) {
 			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("No route to %s via from %s\n",
 				      libcfs_nid2str(dst_nid),
 				      libcfs_nid2str(src_nid));
 			return -EINVAL;
 		}
+	}
 
-		LASSERT(src_nid != LNET_NID_ANY);
+	if (best_ni == the_lnet.ln_loni) {
+		/* No send credit hassles with LOLND */
+		msg->msg_hdr.dest_nid = cpu_to_le64(best_ni->ni_nid);
+		if (!msg->msg_routing)
+			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
+		msg->msg_target.nid = best_ni->ni_nid;
 		lnet_msg_commit(msg, cpt);
 
-		if (!msg->msg_routing)
-			msg->msg_hdr.src_nid = cpu_to_le64(src_nid);
+		lnet_ni_addref_locked(best_ni, cpt);
+		lnet_net_unlock(cpt);
+		msg->msg_txni = best_ni;
+		lnet_ni_send(best_ni, msg);
 
-		if (src_ni == the_lnet.ln_loni) {
-			/* No send credit hassles with LOLND */
-			lnet_net_unlock(cpt);
-			lnet_ni_send(src_ni, msg);
-			return 0;
+		*lo_sent = true;
+		return 0;
+	}
+
+	if (best_ni)
+		goto pick_peer;
+
+	/*
+	 * Decide whether we need to route to peer_ni.
+	 * Get the local net that I need to be on to be able to directly
+	 * send to that peer.
+	 *
+	 * a. Find the peer which the dst_nid belongs to.
+	 * b. Iterate through each of the peer_nets/nis to decide
+	 * the best peer/local_ni pair to use
+	 */
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+		if (!lnet_is_peer_net_healthy_locked(peer_net))
+			continue;
+
+		local_net = lnet_get_net_locked(peer_net->lpn_net_id);
+		if (!local_net) {
+			/*
+			 * go through each peer_ni on that peer_net and
+			 * determine the best possible gw to go through
+			 */
+			list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
+					    lpni_on_peer_net_list) {
+				net_gw = lnet_find_route_locked(NULL,
+								lpni->lpni_nid,
+								rtr_nid);
+
+				/*
+				 * if no route is found for that network then
+				 * move onto the next peer_ni in the peer
+				 */
+				if (!net_gw)
+					continue;
+
+				if (!best_gw) {
+					best_gw = net_gw;
+					best_lpni = lpni;
+				} else  {
+					rc = lnet_compare_peers(net_gw,
+								best_gw);
+					if (rc > 0) {
+						best_gw = net_gw;
+						best_lpni = lpni;
+					}
+				}
+			}
+
+			if (!best_gw)
+				continue;
+
+			local_net = lnet_get_net_locked
+					(LNET_NIDNET(best_gw->lpni_nid));
+			routing = true;
+		} else {
+			routing = false;
+			best_gw = NULL;
 		}
 
-		rc = lnet_nid2peerni_locked(&lp, dst_nid, cpt);
-		if (rc) {
-			lnet_net_unlock(cpt);
-			LCONSOLE_WARN("Error %d finding peer %s\n", rc,
-				      libcfs_nid2str(dst_nid));
-			/* ENOMEM or shutting down */
-			return rc;
+		/* no routable net found go on to a different net */
+		if (!local_net)
+			continue;
+
+		/*
+		 * Second jab at determining best_ni
+		 * if we get here then the peer we're trying to send
+		 * to is on a directly connected network, and we'll
+		 * need to pick the local_ni on that network to send
+		 * from
+		 */
+		while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
+			if (!lnet_is_ni_healthy_locked(ni))
+				continue;
+			/* TODO: compare NUMA distance */
+			if (ni->ni_tx_queues[cpt]->tq_credits <=
+			    best_credits) {
+				/*
+				 * all we want is to read tq_credits
+				 * value as an approximation of how
+				 * busy the NI is. No need to grab a lock
+				 */
+				continue;
+			} else if (best_ni) {
+				if ((best_ni)->ni_seq - ni->ni_seq <= 0)
+					continue;
+				(best_ni)->ni_seq = ni->ni_seq + 1;
+			}
+
+			best_ni = ni;
+			best_credits = ni->ni_tx_queues[cpt]->tq_credits;
 		}
-		LASSERT(lp->lpni_net == src_ni->ni_net);
-	} else {
-		/* sending to a remote network */
-		lp = lnet_find_route_locked(src_ni ? src_ni->ni_net : NULL,
-					    dst_nid, rtr_nid);
-		if (!lp) {
-			lnet_net_unlock(cpt);
+	}
 
-			LCONSOLE_WARN("No route to %s via %s (all routers down)\n",
-				      libcfs_id2str(msg->msg_target),
-				      libcfs_nid2str(src_nid));
-			return -EHOSTUNREACH;
+	if (!best_ni) {
+		lnet_net_unlock(cpt);
+		LCONSOLE_WARN("No local ni found to send from to %s\n",
+			      libcfs_nid2str(dst_nid));
+		return -EINVAL;
+	}
+
+	if (routing)
+		goto send;
+
+pick_peer:
+	lpni = NULL;
+
+	if (msg->msg_type == LNET_MSG_REPLY ||
+	    msg->msg_type == LNET_MSG_ACK) {
+		/*
+		 * for replies we want to respond on the same peer_ni we
+		 * received the message on if possible. If not, then pick
+		 * a peer_ni to send to
+		 */
+		best_lpni = lnet_find_peer_ni_locked(dst_nid, cpt);
+		if (best_lpni) {
+			lnet_peer_ni_decref_locked(best_lpni);
+			goto send;
+		} else {
+			CDEBUG(D_NET,
+			       "unable to send msg_type %d to originating %s\n",
+			       msg->msg_type,
+			       libcfs_nid2str(dst_nid));
 		}
+	}
 
+	peer_net = lnet_peer_get_net_locked(peer,
+					    best_ni->ni_net->net_id);
+	/*
+	 * peer_net is not available or the src_nid is explicitly defined
+	 * and the peer_net for that src_nid is unhealthy. find a route to
+	 * the destination nid.
+	 */
+	if (!peer_net ||
+	    (src_nid != LNET_NID_ANY &&
+	     !lnet_is_peer_net_healthy_locked(peer_net))) {
+		best_gw = lnet_find_route_locked(best_ni->ni_net,
+						 dst_nid,
+						 rtr_nid);
 		/*
-		 * rtr_nid is LNET_NID_ANY or NID of pre-determined router,
-		 * it's possible that rtr_nid isn't LNET_NID_ANY and lp isn't
-		 * pre-determined router, this can happen if router table
-		 * was changed when we release the lock
+		 * if no route is found for that network then
+		 * move onto the next peer_ni in the peer
 		 */
-		if (rtr_nid != lp->lpni_nid) {
-			cpt2 = lp->lpni_cpt;
-			if (cpt2 != cpt) {
-				lnet_net_unlock(cpt);
-
-				rtr_nid = lp->lpni_nid;
-				cpt = cpt2;
-				goto again;
-			}
+		if (!best_gw) {
+			lnet_net_unlock(cpt);
+			LCONSOLE_WARN("No route to peer from %s\n",
+				      libcfs_nid2str(best_ni->ni_nid));
+			return -EHOSTUNREACH;
 		}
 
 		CDEBUG(D_NET, "Best route to %s via %s for %s %d\n",
-		       libcfs_nid2str(dst_nid), libcfs_nid2str(lp->lpni_nid),
-		       lnet_msgtyp2str(msg->msg_type), msg->msg_len);
+			libcfs_nid2str(lpni->lpni_nid),
+			libcfs_nid2str(best_gw->lpni_nid),
+			lnet_msgtyp2str(msg->msg_type), msg->msg_len);
 
-		if (!src_ni) {
-			src_ni = lnet_get_next_ni_locked(lp->lpni_net, NULL);
-			LASSERT(src_ni);
-			src_nid = src_ni->ni_nid;
-		} else {
-			LASSERT(src_ni->ni_net == lp->lpni_net);
+		best_lpni = lnet_find_peer_ni_locked(dst_nid, cpt);
+		LASSERT(best_lpni);
+		lnet_peer_ni_decref_locked(best_lpni);
+
+		routing = true;
+
+		goto send;
+	} else if (!lnet_is_peer_net_healthy_locked(peer_net)) {
+		/*
+		 * this peer_net is unhealthy but we still have an opportunity
+		 * to find another peer_net that we can use
+		 */
+		u32 net_id = peer_net->lpn_net_id;
+
+		lnet_net_unlock(cpt);
+		if (!best_lpni)
+			LCONSOLE_WARN("peer net %s unhealthy\n",
+				      libcfs_net2str(net_id));
+		goto again;
+	}
+
+	best_lpni = NULL;
+	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
+		/*
+		 * if this peer ni is not healty just skip it, no point in
+		 * examining it further
+		 */
+		if (!lnet_is_peer_ni_healthy_locked(lpni))
+			continue;
+		ni_is_pref = lnet_peer_is_ni_pref_locked(lpni, best_ni);
+
+		if (!preferred && ni_is_pref) {
+			preferred = true;
+		} else if (preferred && !ni_is_pref) {
+			continue;
+		} else if (lpni->lpni_txcredits <= best_lpni_credits) {
+			continue;
+		} else if (best_lpni) {
+			if (best_lpni->lpni_seq - lpni->lpni_seq <= 0)
+				continue;
+			best_lpni->lpni_seq = lpni->lpni_seq + 1;
 		}
 
-		lnet_peer_ni_addref_locked(lp);
+		best_lpni = lpni;
+		best_lpni_credits = lpni->lpni_txcredits;
+	}
 
-		LASSERT(src_nid != LNET_NID_ANY);
-		lnet_msg_commit(msg, cpt);
+	/* if we still can't find a peer ni then we can't reach it */
+	if (!best_lpni) {
+		u32 net_id = peer_net ? peer_net->lpn_net_id :
+			LNET_NIDNET(dst_nid);
+
+		lnet_net_unlock(cpt);
+		LCONSOLE_WARN("no peer_ni found on peer net %s\n",
+			      libcfs_net2str(net_id));
+		goto again;
+	}
 
-		if (!msg->msg_routing) {
-			/* I'm the source and now I know which NI to send on */
-			msg->msg_hdr.src_nid = cpu_to_le64(src_nid);
+send:
+	/*
+	 * determine the cpt to use and if it has changed then
+	 * lock the new cpt and check if the config has changed.
+	 * If it has changed then repeat the algorithm since the
+	 * ni or peer list could have changed and the algorithm
+	 * would endup picking a different ni/peer_ni pair.
+	 */
+	cpt2 = best_lpni->lpni_cpt;
+	if (cpt != cpt2) {
+		lnet_net_unlock(cpt);
+		cpt = cpt2;
+		lnet_net_lock(cpt);
+		seq2 = lnet_get_dlc_seq_locked();
+		if (seq2 != seq) {
+			lnet_net_unlock(cpt);
+			goto again;
 		}
+	}
+
+	/*
+	 * store the best_lpni in the message right away to avoid having
+	 * to do the same operation under different conditions
+	 */
+	msg->msg_txpeer = (routing) ? best_gw : best_lpni;
+	msg->msg_txni = best_ni;
+	/*
+	 * grab a reference for the best_ni since now it's in use in this
+	 * send. the reference will need to be dropped when the message is
+	 * finished in lnet_finalize()
+	 */
+	lnet_ni_addref_locked(msg->msg_txni, cpt);
+	lnet_peer_ni_addref_locked(msg->msg_txpeer);
+
+	/*
+	 * set the destination nid in the message here because it's
+	 * possible that we'd be sending to a different nid than the one
+	 * originaly given.
+	 */
+	msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
 
+	/*
+	 * Always set the target.nid to the best peer picked. Either the
+	 * nid will be one of the preconfigured NIDs, or the same NID as
+	 * what was originaly set in the target or it will be the NID of
+	 * a router if this message should be routed
+	 */
+	msg->msg_target.nid = msg->msg_txpeer->lpni_nid;
+
+	/*
+	 * lnet_msg_commit assigns the correct cpt to the message, which
+	 * is used to decrement the correct refcount on the ni when it's
+	 * time to return the credits
+	 */
+	lnet_msg_commit(msg, cpt);
+
+	/*
+	 * If we are routing the message then we don't need to overwrite
+	 * the src_nid since it would've been set at the origin. Otherwise
+	 * we are the originator so we need to set it.
+	 */
+	if (!msg->msg_routing)
+		msg->msg_hdr.src_nid = cpu_to_le64(msg->msg_txni->ni_nid);
+
+	if (routing) {
 		msg->msg_target_is_router = 1;
-		msg->msg_target.nid = lp->lpni_nid;
 		msg->msg_target.pid = LNET_PID_LUSTRE;
 	}
 
-	/* 'lp' is our best choice of peer */
+	rc = lnet_post_send_locked(msg, 0);
 
-	LASSERT(!msg->msg_peertxcredit);
-	LASSERT(!msg->msg_txcredit);
+	lnet_net_unlock(cpt);
+
+	return rc;
+}
+
+int
+lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
+{
+	lnet_nid_t		dst_nid = msg->msg_target.nid;
+	int			rc;
+	bool                    lo_sent = false;
+
+	/*
+	 * NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
+	 * but we might want to use pre-determined router for ACK/REPLY
+	 * in the future
+	 */
+	/* NB: !ni == interface pre-determined (ACK/REPLY) */
 	LASSERT(!msg->msg_txpeer);
+	LASSERT(!msg->msg_sending);
+	LASSERT(!msg->msg_target_is_router);
+	LASSERT(!msg->msg_receiving);
 
-	msg->msg_txpeer = lp;		   /* msg takes my ref on lp */
-	/* set the NI for this message */
-	msg->msg_txni = src_ni;
-	lnet_ni_addref_locked(msg->msg_txni, cpt);
+	msg->msg_sending = 1;
 
-	rc = lnet_post_send_locked(msg, 0);
-	lnet_net_unlock(cpt);
+	LASSERT(!msg->msg_tx_committed);
 
-	if (rc < 0)
+	rc = lnet_select_pathway(src_nid, dst_nid, msg, rtr_nid, &lo_sent);
+	if (rc < 0 || lo_sent)
 		return rc;
 
 	if (rc == LNET_CREDIT_OK)
-		lnet_ni_send(src_ni, msg);
+		lnet_ni_send(msg->msg_txni, msg);
 
-	return 0; /* rc == LNET_CREDIT_OK or LNET_CREDIT_WAIT */
+	/* rc == LNET_CREDIT_OK or LNET_CREDIT_WAIT */
+	return 0;
 }
 
 void
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 97ee1f5cfd2f..edba1b1d87cc 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -230,6 +230,95 @@ lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt)
 	return lpni;
 }
 
+int
+lnet_find_or_create_peer_locked(lnet_nid_t dst_nid, int cpt,
+				struct lnet_peer **peer)
+{
+	struct lnet_peer_ni *lpni;
+
+	lpni = lnet_find_peer_ni_locked(dst_nid, cpt);
+	if (!lpni) {
+		int rc;
+
+		rc = lnet_nid2peerni_locked(&lpni, dst_nid, cpt);
+		if (rc != 0)
+			return rc;
+	}
+
+	*peer = lpni->lpni_peer_net->lpn_peer;
+	lnet_peer_ni_decref_locked(lpni);
+
+	return 0;
+}
+
+struct lnet_peer_ni *
+lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
+			     struct lnet_peer_net *peer_net,
+			     struct lnet_peer_ni *prev)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer_net *net = peer_net;
+
+	if (!prev) {
+		if (!net)
+			net = list_entry(peer->lp_peer_nets.next,
+					 struct lnet_peer_net,
+					 lpn_on_peer_list);
+		lpni = list_entry(net->lpn_peer_nis.next, struct lnet_peer_ni,
+				  lpni_on_peer_net_list);
+
+		return lpni;
+	}
+
+	if (prev->lpni_on_peer_net_list.next ==
+	    &prev->lpni_peer_net->lpn_peer_nis) {
+		/*
+		 * if you reached the end of the peer ni list and the peer
+		 * net is specified then there are no more peer nis in that
+		 * net.
+		 */
+		if (net)
+			return NULL;
+
+		/*
+		 * we reached the end of this net ni list. move to the
+		 * next net
+		 */
+		if (prev->lpni_peer_net->lpn_on_peer_list.next ==
+		    &peer->lp_peer_nets)
+			/* no more nets and no more NIs. */
+			return NULL;
+
+		/* get the next net */
+		net = list_entry(prev->lpni_peer_net->lpn_on_peer_list.next,
+				 struct lnet_peer_net,
+				 lpn_on_peer_list);
+		/* get the ni on it */
+		lpni = list_entry(net->lpn_peer_nis.next, struct lnet_peer_ni,
+				  lpni_on_peer_net_list);
+
+		return lpni;
+	}
+
+	/* there are more nis left */
+	lpni = list_entry(prev->lpni_on_peer_net_list.next,
+			  struct lnet_peer_ni, lpni_on_peer_net_list);
+
+	return lpni;
+}
+
+bool
+lnet_peer_is_ni_pref_locked(struct lnet_peer_ni *lpni, struct lnet_ni *ni)
+{
+	int i;
+
+	for (i = 0; i < lpni->lpni_pref_nnids; i++) {
+		if (lpni->lpni_pref_nids[i] == ni->ni_nid)
+			return true;
+	}
+	return false;
+}
+
 static void
 lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
 {
@@ -302,6 +391,18 @@ lnet_build_peer_hierarchy(struct lnet_peer_ni *lpni)
 	return 0;
 }
 
+struct lnet_peer_net *
+lnet_peer_get_net_locked(struct lnet_peer *peer, u32 net_id)
+{
+	struct lnet_peer_net *peer_net;
+
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
+		if (peer_net->lpn_net_id == net_id)
+			return peer_net;
+	}
+	return NULL;
+}
+
 void
 lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
 {
@@ -412,12 +513,19 @@ lnet_nid2peerni_locked(struct lnet_peer_ni **lpnip, lnet_nid_t nid, int cpt)
 	}
 
 	lpni->lpni_net = lnet_get_net_locked(LNET_NIDNET(lpni->lpni_nid));
-	lpni->lpni_txcredits =
-		lpni->lpni_mintxcredits =
-		lpni->lpni_net->net_tunables.lct_peer_tx_credits;
-	lpni->lpni_rtrcredits =
-		lpni->lpni_minrtrcredits =
-		lnet_peer_buffer_credits(lpni->lpni_net);
+	if (lpni->lpni_net) {
+		lpni->lpni_txcredits =
+			lpni->lpni_mintxcredits =
+			lpni->lpni_net->net_tunables.lct_peer_tx_credits;
+		lpni->lpni_rtrcredits =
+			lpni->lpni_minrtrcredits =
+			lnet_peer_buffer_credits(lpni->lpni_net);
+	} else {
+		CDEBUG(D_NET, "peer_ni %s is not directly connected\n",
+		       libcfs_nid2str(nid));
+	}
+
+	lnet_set_peer_ni_health_locked(lpni, true);
 
 	list_add_tail(&lpni->lpni_hashlist,
 		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
