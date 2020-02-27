From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:03 -0500
Subject: [lustre-devel] [PATCH 075/622] lnet: refactor lnet_select_pathway()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-76-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

lnet_select_pathway() is a complex monolithic function which handles
many send cases. Broke down lnet_select_pathway() to multiple
functions. Each function handles a different send case. This will
make it easier to add the handling of the different health cases in
future patches.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 4e48761a5719 ("LU-9120 lnet: refactor lnet_select_pathway()")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32760
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |   13 +
 net/lnet/lnet/lib-move.c      | 1398 ++++++++++++++++++++++++++---------------
 2 files changed, 911 insertions(+), 500 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 22c6152..20b4660 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -827,6 +827,19 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 	return false;
 }
 
+static inline struct lnet_peer_net *
+lnet_find_peer_net_locked(struct lnet_peer *peer, u32 net_id)
+{
+	struct lnet_peer_net *peer_net;
+
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
+		if (peer_net->lpn_net_id == net_id)
+			return peer_net;
+	}
+
+	return NULL;
+}
+
 static inline void
 lnet_peer_set_alive(struct lnet_peer_ni *lp)
 {
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index cab830a..10aa753 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -45,6 +45,23 @@
 module_param(local_nid_dist_zero, int, 0444);
 MODULE_PARM_DESC(local_nid_dist_zero, "Reserved");
 
+struct lnet_send_data {
+	struct lnet_ni		*sd_best_ni;
+	struct lnet_peer_ni	*sd_best_lpni;
+	struct lnet_peer_ni	*sd_final_dst_lpni;
+	struct lnet_peer	*sd_peer;
+	struct lnet_peer	*sd_gw_peer;
+	struct lnet_peer_ni	*sd_gw_lpni;
+	struct lnet_peer_net	*sd_peer_net;
+	struct lnet_msg		*sd_msg;
+	lnet_nid_t		sd_dst_nid;
+	lnet_nid_t		sd_src_nid;
+	lnet_nid_t		sd_rtr_nid;
+	int			sd_cpt;
+	int			sd_md_cpt;
+	u32			sd_send_case;
+};
+
 static inline struct lnet_comm_count *
 get_stats_counts(struct lnet_element_stats *stats,
 		 enum lnet_stats_type stats_type)
@@ -1188,7 +1205,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static struct lnet_peer_ni *
-lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
+lnet_find_route_locked(struct lnet_net *net, u32 remote_net,
 		       lnet_nid_t rtr_nid)
 {
 	struct lnet_remotenet *rnet;
@@ -1203,7 +1220,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * If @rtr_nid is not LNET_NID_ANY, return the gateway with
 	 * rtr_nid nid, otherwise find the best gateway I can use
 	 */
-	rnet = lnet_find_rnet_locked(LNET_NIDNET(target));
+	rnet = lnet_find_rnet_locked(remote_net);
 	if (!rnet)
 		return NULL;
 
@@ -1252,13 +1269,20 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static struct lnet_ni *
-lnet_get_best_ni(struct lnet_net *local_net, struct lnet_ni *cur_ni,
+lnet_get_best_ni(struct lnet_net *local_net, struct lnet_ni *best_ni,
+		 struct lnet_peer *peer, struct lnet_peer_net *peer_net,
 		 int md_cpt)
 {
-	struct lnet_ni *ni = NULL, *best_ni = cur_ni;
+	struct lnet_ni *ni = NULL;
 	unsigned int shortest_distance;
 	int best_credits;
 
+	/* If there is no peer_ni that we can send to on this network,
+	 * then there is no point in looking for a new best_ni here.
+	 */
+	if (!lnet_get_next_peer_ni_locked(peer, peer_net, NULL))
+		return best_ni;
+
 	if (!best_ni) {
 		shortest_distance = UINT_MAX;
 		best_credits = INT_MIN;
@@ -1286,6 +1310,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 					    md_cpt,
 					    ni->ni_dev_cpt);
 
+		CDEBUG(D_NET,
+		       "compare ni %s [c:%d, d:%d, s:%d] with best_ni %s [c:%d, d:%d, s:%d]\n",
+		       libcfs_nid2str(ni->ni_nid), ni_credits, distance,
+		       ni->ni_seq, (best_ni) ? libcfs_nid2str(best_ni->ni_nid)
+			: "not seleced", best_credits, shortest_distance,
+			(best_ni) ? best_ni->ni_seq : 0);
+
 		/*
 		 * All distances smaller than the NUMA range
 		 * are treated equally.
@@ -1311,6 +1342,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		best_credits = ni_credits;
 	}
 
+	CDEBUG(D_NET, "selected best_ni %s\n",
+	       (best_ni) ? libcfs_nid2str(best_ni->ni_nid) : "no selection");
+
 	return best_ni;
 }
 
@@ -1335,421 +1369,140 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return false;
 }
 
+#define SRC_SPEC	0x0001
+#define SRC_ANY		0x0002
+#define LOCAL_DST	0x0004
+#define REMOTE_DST	0x0008
+#define MR_DST		0x0010
+#define NMR_DST		0x0020
+#define SND_RESP	0x0040
+
+/* The following to defines are used for return codes */
+#define REPEAT_SEND	0x1000
+#define PASS_THROUGH	0x2000
+
+/* The different cases lnet_select pathway needs to handle */
+#define SRC_SPEC_LOCAL_MR_DST	(SRC_SPEC | LOCAL_DST | MR_DST)
+#define SRC_SPEC_ROUTER_MR_DST	(SRC_SPEC | REMOTE_DST | MR_DST)
+#define SRC_SPEC_LOCAL_NMR_DST	(SRC_SPEC | LOCAL_DST | NMR_DST)
+#define SRC_SPEC_ROUTER_NMR_DST	(SRC_SPEC | REMOTE_DST | NMR_DST)
+#define SRC_ANY_LOCAL_MR_DST	(SRC_ANY | LOCAL_DST | MR_DST)
+#define SRC_ANY_ROUTER_MR_DST	(SRC_ANY | REMOTE_DST | MR_DST)
+#define SRC_ANY_LOCAL_NMR_DST	(SRC_ANY | LOCAL_DST | NMR_DST)
+#define SRC_ANY_ROUTER_NMR_DST	(SRC_ANY | REMOTE_DST | NMR_DST)
+
 static int
-lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
-		    struct lnet_msg *msg, lnet_nid_t rtr_nid)
+lnet_handle_send(struct lnet_send_data *sd)
 {
-	struct lnet_ni *best_ni = NULL;
-	struct lnet_peer_ni *best_lpni = NULL;
-	struct lnet_peer_ni *best_gw = NULL;
-	struct lnet_peer_ni *lpni;
-	struct lnet_peer_ni *final_dst;
-	struct lnet_peer *peer;
-	struct lnet_peer_net *peer_net;
-	struct lnet_net *local_net;
-	int cpt, cpt2, rc;
-	bool routing;
-	bool routing2;
-	bool ni_is_pref;
-	bool preferred;
-	bool local_found;
-	int best_lpni_credits;
-	int md_cpt;
-
-	/*
-	 * get an initial CPT to use for locking. The idea here is not to
-	 * serialize the calls to select_pathway, so that as many
-	 * operations can run concurrently as possible. To do that we use
-	 * the CPT where this call is being executed. Later on when we
-	 * determine the CPT to use in lnet_message_commit, we switch the
-	 * lock and check if there was any configuration change.  If none,
-	 * then we proceed, if there is, then we restart the operation.
-	 */
-	cpt = lnet_net_lock_current();
-
-	md_cpt = lnet_cpt_of_md(msg->msg_md, msg->msg_offset);
-	if (md_cpt == CFS_CPT_ANY)
-		md_cpt = cpt;
-
-again:
-	best_ni = NULL;
-	best_lpni = NULL;
-	best_gw = NULL;
-	final_dst = NULL;
-	local_net = NULL;
-	routing = false;
-	routing2 = false;
-	local_found = false;
-
-	/*
-	 * lnet_nid2peerni_locked() is the path that will find an
-	 * existing peer_ni, or create one and mark it as having been
-	 * created due to network traffic.
-	 */
-	lpni = lnet_nid2peerni_locked(dst_nid, LNET_NID_ANY, cpt);
-	if (IS_ERR(lpni)) {
-		lnet_net_unlock(cpt);
-		return PTR_ERR(lpni);
-	}
+	struct lnet_ni *best_ni = sd->sd_best_ni;
+	struct lnet_peer_ni *best_lpni = sd->sd_best_lpni;
+	struct lnet_peer_ni *final_dst_lpni = sd->sd_final_dst_lpni;
+	struct lnet_msg *msg = sd->sd_msg;
+	int cpt2;
+	u32 send_case = sd->sd_send_case;
+	int rc;
+	u32 routing = send_case & REMOTE_DST;
 
-	/* If we're being asked to send to the loopback interface, there
-	 * is no need to go through any selection. We can just shortcut
-	 * the entire process and send over lolnd
+	/* Increment sequence number of the selected peer so that we
+	 * pick the next one in Round Robin.
 	 */
-	if (LNET_NETTYP(LNET_NIDNET(dst_nid)) == LOLND) {
-		lnet_peer_ni_decref_locked(lpni);
-		best_ni = the_lnet.ln_loni;
-		goto send;
-	}
+	best_lpni->lpni_seq++;
 
-	/*
-	 * Now that we have a peer_ni, check if we want to discover
-	 * the peer. Traffic to the LNET_RESERVED_PORTAL should not
-	 * trigger discovery.
+	/* grab a reference on the peer_ni so it sticks around even if
+	 * we need to drop and relock the lnet_net_lock below.
 	 */
-	peer = lpni->lpni_peer_net->lpn_peer;
-	if (lnet_msg_discovery(msg) && !lnet_peer_is_uptodate(peer)) {
-		rc = lnet_discover_peer_locked(lpni, cpt, false);
-		if (rc) {
-			lnet_peer_ni_decref_locked(lpni);
-			lnet_net_unlock(cpt);
-			return rc;
-		}
-		/* The peer may have changed. */
-		peer = lpni->lpni_peer_net->lpn_peer;
-		/* queue message and return */
-		msg->msg_src_nid_param = src_nid;
-		msg->msg_rtr_nid_param = rtr_nid;
-		msg->msg_sending = 0;
-		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
-		CDEBUG(D_NET, "%s pending discovery\n",
-		       libcfs_nid2str(peer->lp_primary_nid));
-		lnet_peer_ni_decref_locked(lpni);
-		lnet_net_unlock(cpt);
-
-		return LNET_DC_WAIT;
-	}
-	lnet_peer_ni_decref_locked(lpni);
-
-	/* If peer is not healthy then can not send anything to it */
-	if (!lnet_is_peer_healthy_locked(peer)) {
-		lnet_net_unlock(cpt);
-		return -EHOSTUNREACH;
-	}
+	lnet_peer_ni_addref_locked(best_lpni);
 
-	/*
-	 * STEP 1: first jab at determining best_ni
-	 * if src_nid is explicitly specified, then best_ni is already
-	 * pre-determiend for us. Otherwise we need to select the best
-	 * one to use later on
+	/* Use lnet_cpt_of_nid() to determine the CPT used to commit the
+	 * message. This ensures that we get a CPT that is correct for
+	 * the NI when the NI has been restricted to a subset of all CPTs.
+	 * If the selected CPT differs from the one currently locked, we
+	 * must unlock and relock the lnet_net_lock(), and then check whether
+	 * the configuration has changed. We don't have a hold on the best_ni
+	 * yet, and it may have vanished.
 	 */
-	if (src_nid != LNET_NID_ANY) {
-		best_ni = lnet_nid2ni_locked(src_nid, cpt);
-		if (!best_ni) {
-			lnet_net_unlock(cpt);
-			LCONSOLE_WARN("Can't send to %s: src %s is not a local nid\n",
-				      libcfs_nid2str(dst_nid),
-				      libcfs_nid2str(src_nid));
-			return -EINVAL;
-		}
-	}
+	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
+	if (sd->sd_cpt != cpt2) {
+		u32 seq = lnet_get_dlc_seq_locked();
 
-	if (msg->msg_type == LNET_MSG_REPLY ||
-	    msg->msg_type == LNET_MSG_ACK ||
-	    !lnet_peer_is_multi_rail(peer) ||
-	    best_ni) {
-		/*
-		 * for replies we want to respond on the same peer_ni we
-		 * received the message on if possible. If not, then pick
-		 * a peer_ni to send to
-		 *
-		 * if the peer is non-multi-rail then you want to send to
-		 * the dst_nid provided as well.
-		 *
-		 * If the best_ni has already been determined, IE the
-		 * src_nid has been specified, then use the
-		 * destination_nid provided as well, since we're
-		 * continuing a series of related messages for the same
-		 * RPC.
-		 *
-		 * It is expected to find the lpni using dst_nid, since we
-		 * created it earlier.
-		 */
-		best_lpni = lnet_find_peer_ni_locked(dst_nid);
-		if (best_lpni)
+		lnet_net_unlock(sd->sd_cpt);
+		sd->sd_cpt = cpt2;
+		lnet_net_lock(sd->sd_cpt);
+		if (seq != lnet_get_dlc_seq_locked()) {
 			lnet_peer_ni_decref_locked(best_lpni);
-
-		if (best_lpni && !lnet_get_net_locked(LNET_NIDNET(dst_nid))) {
-			/*
-			 * this lpni is not on a local network so we need
-			 * to route this reply.
-			 */
-			best_gw = lnet_find_route_locked(NULL,
-							 best_lpni->lpni_nid,
-							 rtr_nid);
-			if (best_gw) {
-				/*
-				 * RULE: Each node considers only the next-hop
-				 *
-				 * We're going to route the message,
-				 * so change the peer to the router.
-				 */
-				LASSERT(best_gw->lpni_peer_net);
-				LASSERT(best_gw->lpni_peer_net->lpn_peer);
-				peer = best_gw->lpni_peer_net->lpn_peer;
-
-				/*
-				 * if the router is not multi-rail
-				 * then use the best_gw found to send
-				 * the message to
-				 */
-				if (!lnet_peer_is_multi_rail(peer))
-					best_lpni = best_gw;
-				else
-					best_lpni = NULL;
-
-				routing = true;
-			} else {
-				best_lpni = NULL;
-			}
-		} else if (!best_lpni) {
-			lnet_net_unlock(cpt);
-			CERROR("unable to send msg_type %d to originating %s. Destination NID not in DB\n",
-			       msg->msg_type, libcfs_nid2str(dst_nid));
-			return -EINVAL;
-		}
-	}
-
-	/*
-	 * We must use a consistent source address when sending to a
-	 * non-MR peer. However, a non-MR peer can have multiple NIDs
-	 * on multiple networks, and we may even need to talk to this
-	 * peer on multiple networks -- certain types of
-	 * load-balancing configuration do this.
-	 *
-	 * So we need to pick the NI the peer prefers for this
-	 * particular network.
-	 */
-	if (!lnet_peer_is_multi_rail(peer)) {
-		if (!best_lpni) {
-			lnet_net_unlock(cpt);
-			CERROR("no route to %s\n",
-			       libcfs_nid2str(dst_nid));
-			return -EHOSTUNREACH;
-		}
-
-		/* best ni is already set if src_nid was provided */
-		if (!best_ni) {
-			/* Get the target peer_ni */
-			peer_net = lnet_peer_get_net_locked(
-				peer, LNET_NIDNET(best_lpni->lpni_nid));
-			list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
-					    lpni_peer_nis) {
-				if (lpni->lpni_pref_nnids == 0)
-					continue;
-				LASSERT(lpni->lpni_pref_nnids == 1);
-				best_ni = lnet_nid2ni_locked(
-					lpni->lpni_pref.nid, cpt);
-				break;
-			}
+			return REPEAT_SEND;
 		}
-		/* if best_ni is still not set just pick one */
-		if (!best_ni) {
-			best_ni = lnet_net2ni_locked(
-				best_lpni->lpni_net->net_id, cpt);
-			/* If there is no best_ni we don't have a route */
-			if (!best_ni) {
-				CERROR("no path to %s from net %s\n",
-				       libcfs_nid2str(best_lpni->lpni_nid),
-				       libcfs_net2str(best_lpni->lpni_net->net_id));
-				lnet_net_unlock(cpt);
-				return -EHOSTUNREACH;
-			}
-			lpni = list_first_entry(&peer_net->lpn_peer_nis,
-						struct lnet_peer_ni,
-					  lpni_peer_nis);
-		}
-		/* Set preferred NI if necessary. */
-		if (lpni->lpni_pref_nnids == 0)
-			lnet_peer_ni_set_non_mr_pref_nid(lpni, best_ni->ni_nid);
 	}
 
-	/*
-	 * if we already found a best_ni because src_nid is specified and
-	 * best_lpni because we are replying to a message then just send
-	 * the message
+	/* store the best_lpni in the message right away to avoid having
+	 * to do the same operation under different conditions
 	 */
-	if (best_ni && best_lpni)
-		goto send;
+	msg->msg_txpeer = best_lpni;
+	msg->msg_txni = best_ni;
 
-	/*
-	 * If we already found a best_ni because src_nid is specified then
-	 * pick the peer then send the message
+	/* grab a reference for the best_ni since now it's in use in this
+	 * send. The reference will be dropped in lnet_finalize()
 	 */
-	if (best_ni)
-		goto pick_peer;
+	lnet_ni_addref_locked(msg->msg_txni, sd->sd_cpt);
 
-	/*
-	 * pick the best_ni by going through all the possible networks of
-	 * that peer and see which local NI is best suited to talk to that
-	 * peer.
-	 *
-	 * Locally connected networks will always be preferred over
-	 * a routed network. If there are only routed paths to the peer,
-	 * then the best route is chosen. If all routes are equal then
-	 * they are used in round robin.
+	/* Always set the target.nid to the best peer picked. Either the
+	 * NID will be one of the peer NIDs selected, or the same NID as
+	 * what was originally set in the target or it will be the NID of
+	 * a router if this message should be routed
 	 */
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
-		if (!lnet_is_peer_net_healthy_locked(peer_net))
-			continue;
-
-		local_net = lnet_get_net_locked(peer_net->lpn_net_id);
-		if (!local_net && !routing && !local_found) {
-			struct lnet_peer_ni *net_gw;
-
-			lpni = list_first_entry(&peer_net->lpn_peer_nis,
-						struct lnet_peer_ni,
-						lpni_peer_nis);
-
-			net_gw = lnet_find_route_locked(NULL,
-							lpni->lpni_nid,
-							rtr_nid);
-			if (!net_gw)
-				continue;
-
-			if (best_gw) {
-				/*
-				 * lnet_find_route_locked() call
-				 * will return the best_Gw on the
-				 * lpni->lpni_nid network.
-				 * However, best_gw and net_gw can
-				 * be on different networks.
-				 * Therefore need to compare them
-				 * to pick the better of either.
-				 */
-				if (lnet_compare_peers(best_gw, net_gw) > 0)
-					continue;
-				if (best_gw->lpni_gw_seq <= net_gw->lpni_gw_seq)
-					continue;
-			}
-			best_gw = net_gw;
-			final_dst = lpni;
-
-			routing2 = true;
-		} else {
-			best_gw = NULL;
-			final_dst = NULL;
-			routing2 = false;
-			local_found = true;
-		}
-
-		/*
-		 * a gw on this network is found, but there could be
-		 * other better gateways on other networks. So don't pick
-		 * the best_ni until we determine the best_gw.
-		 */
-		if (best_gw)
-			continue;
-
-		/* if no local_net found continue */
-		if (!local_net)
-			continue;
-
-		/*
-		 * Iterate through the NIs in this local Net and select
-		 * the NI to send from. The selection is determined by
-		 * these 3 criterion in the following priority:
-		 *	1. NUMA
-		 *	2. NI available credits
-		 *	3. Round Robin
-		 */
-		best_ni = lnet_get_best_ni(local_net, best_ni, md_cpt);
-	}
-
-	if (!best_ni && !best_gw) {
-		lnet_net_unlock(cpt);
-		LCONSOLE_WARN("No local ni found to send from to %s\n",
-			      libcfs_nid2str(dst_nid));
-		return -EINVAL;
-	}
-
-	if (!best_ni) {
-		best_ni = lnet_get_best_ni(best_gw->lpni_net, best_ni, md_cpt);
-		LASSERT(best_gw && best_ni);
-
-		/*
-		 * We're going to route the message, so change the peer to
-		 * the router.
-		 */
-		LASSERT(best_gw->lpni_peer_net);
-		LASSERT(best_gw->lpni_peer_net->lpn_peer);
-		best_gw->lpni_gw_seq++;
-		peer = best_gw->lpni_peer_net->lpn_peer;
-	}
+	msg->msg_target.nid = msg->msg_txpeer->lpni_nid;
 
-	/*
-	 * Now that we selected the NI to use increment its sequence
-	 * number so the Round Robin algorithm will detect that it has
-	 * been used and pick the next NI.
+	/* lnet_msg_commit assigns the correct cpt to the message, which
+	 * is used to decrement the correct refcount on the ni when it's
+	 * time to return the credits
 	 */
-	best_ni->ni_seq++;
+	lnet_msg_commit(msg, sd->sd_cpt);
 
-pick_peer:
-	/*
-	 * At this point the best_ni is on a local network on which
-	 * the peer has a peer_ni as well
-	 */
-	peer_net = lnet_peer_get_net_locked(peer,
-					    best_ni->ni_net->net_id);
-	/*
-	 * peer_net is not available or the src_nid is explicitly defined
-	 * and the peer_net for that src_nid is unhealthy. find a route to
-	 * the destination nid.
+	/* If we are routing the message then we keep the src_nid that was
+	 * set by the originator. If we are not routing then we are the
+	 * originator and set it here.
 	 */
-	if (!peer_net ||
-	    (src_nid != LNET_NID_ANY &&
-	     !lnet_is_peer_net_healthy_locked(peer_net))) {
-		best_gw = lnet_find_route_locked(best_ni->ni_net,
-						 dst_nid,
-						 rtr_nid);
-		/*
-		 * if no route is found for that network then
-		 * move onto the next peer_ni in the peer
-		 */
-		if (!best_gw) {
-			LCONSOLE_WARN("No route to peer from %s\n",
-				      libcfs_nid2str(best_ni->ni_nid));
-			lnet_net_unlock(cpt);
-			return -EHOSTUNREACH;
-		}
-
-		CDEBUG(D_NET, "Best route to %s via %s for %s %d\n",
-			libcfs_nid2str(dst_nid),
-			libcfs_nid2str(best_gw->lpni_nid),
-			lnet_msgtyp2str(msg->msg_type), msg->msg_len);
+	if (!msg->msg_routing)
+		msg->msg_hdr.src_nid = cpu_to_le64(msg->msg_txni->ni_nid);
 
-		routing2 = true;
-		/*
-		 * RULE: Each node considers only the next-hop
+	if (routing) {
+		msg->msg_target_is_router = 1;
+		msg->msg_target.pid = LNET_PID_LUSTRE;
+		/* since we're routing we want to ensure that the
+		 * msg_hdr.dest_nid is set to the final destination. When
+		 * the router receives this message it knows how to route
+		 * it.
 		 *
-		 * We're going to route the message, so change the peer to
-		 * the router.
+		 * final_dst_lpni is set at the beginning of the
+		 * lnet_select_pathway() function and is never changed.
+		 * It's safe to use it here.
 		 */
-		LASSERT(best_gw->lpni_peer_net);
-		LASSERT(best_gw->lpni_peer_net->lpn_peer);
-		peer = best_gw->lpni_peer_net->lpn_peer;
-	} else if (!lnet_is_peer_net_healthy_locked(peer_net)) {
-		/*
-		 * this peer_net is unhealthy but we still have an opportunity
-		 * to find another peer_net that we can use
+		msg->msg_hdr.dest_nid = cpu_to_le64(final_dst_lpni->lpni_nid);
+	} else {
+		/* if we're not routing set the dest_nid to the best peer
+		 * ni NID that we picked earlier in the algorithm.
 		 */
-		u32 net_id = peer_net->lpn_net_id;
-
-		LCONSOLE_WARN("peer net %s unhealthy\n",
-			      libcfs_net2str(net_id));
-		goto again;
+		msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
 	}
 
+	rc = lnet_post_send_locked(msg, 0);
+	if (!rc)
+		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s\n",
+		       libcfs_nid2str(msg->msg_hdr.src_nid),
+		       libcfs_nid2str(msg->msg_txni->ni_nid),
+		       libcfs_nid2str(sd->sd_src_nid),
+		       libcfs_nid2str(msg->msg_hdr.dest_nid),
+		       libcfs_nid2str(sd->sd_dst_nid),
+		       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
+		       lnet_msgtyp2str(msg->msg_type));
+
+	return rc;
+}
+
+static struct lnet_peer_ni *
+lnet_select_peer_ni(struct lnet_send_data *sd, struct lnet_peer *peer,
+		    struct lnet_peer_net *peer_net)
+{
 	/*
 	 * Look at the peer NIs for the destination peer that connect
 	 * to the chosen net. If a peer_ni is preferred when using the
@@ -1758,20 +1511,30 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * the available transmit credits are used. If the transmit
 	 * credits are equal, we round-robin over the peer_ni.
 	 */
-	lpni = NULL;
-	best_lpni_credits = INT_MIN;
-	preferred = false;
-	best_lpni = NULL;
+	struct lnet_peer_ni *lpni = NULL;
+	struct lnet_peer_ni *best_lpni = NULL;
+	struct lnet_ni *best_ni = sd->sd_best_ni;
+	lnet_nid_t dst_nid = sd->sd_dst_nid;
+	int best_lpni_credits = INT_MIN;
+	bool preferred = false;
+	bool ni_is_pref;
+
 	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
-		/*
-		 * if this peer ni is not healthy just skip it, no point in
-		 * examining it further
+		/* if the best_ni we've chosen aleady has this lpni
+		 * preferred, then let's use it
 		 */
-		if (!lnet_is_peer_ni_healthy_locked(lpni))
-			continue;
 		ni_is_pref = lnet_peer_is_pref_nid_locked(lpni,
 							  best_ni->ni_nid);
 
+		CDEBUG(D_NET, "%s ni_is_pref = %d\n",
+		       libcfs_nid2str(best_ni->ni_nid), ni_is_pref);
+
+		if (best_lpni)
+			CDEBUG(D_NET, "%s c:[%d, %d], s:[%d, %d]\n",
+			       libcfs_nid2str(lpni->lpni_nid),
+			       lpni->lpni_txcredits, best_lpni_credits,
+			       lpni->lpni_seq, best_lpni->lpni_seq);
+
 		/* if this is a preferred peer use it */
 		if (!preferred && ni_is_pref) {
 			preferred = true;
@@ -1810,131 +1573,766 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		u32 net_id = peer_net ? peer_net->lpn_net_id :
 					LNET_NIDNET(dst_nid);
 
-		lnet_net_unlock(cpt);
-		LCONSOLE_WARN("no peer_ni found on peer net %s\n",
-			      libcfs_net2str(net_id));
-		return -EHOSTUNREACH;
+		CDEBUG(D_NET, "no peer_ni found on peer net %s\n",
+		       libcfs_net2str(net_id));
+		return NULL;
 	}
 
-send:
-	/* Shortcut for loopback. */
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
+	CDEBUG(D_NET, "sd_best_lpni = %s\n",
+	       libcfs_nid2str(best_lpni->lpni_nid));
 
-	routing = routing || routing2;
+	return best_lpni;
+}
 
-	/*
-	 * Increment sequence number of the peer selected so that we
-	 * pick the next one in Round Robin.
-	 */
-	best_lpni->lpni_seq++;
+/* Prerequisite: the best_ni should already be set in the sd
+ */
+static inline struct lnet_peer_ni *
+lnet_find_best_lpni_on_net(struct lnet_send_data *sd, struct lnet_peer *peer,
+			   u32 net_id)
+{
+	struct lnet_peer_net *peer_net;
 
-	/*
-	 * grab a reference on the peer_ni so it sticks around even if
-	 * we need to drop and relock the lnet_net_lock below.
+	/* The gateway is Multi-Rail capable so now we must select the
+	 * proper peer_ni
 	 */
-	lnet_peer_ni_addref_locked(best_lpni);
+	peer_net = lnet_peer_get_net_locked(peer, net_id);
 
-	/*
-	 * Use lnet_cpt_of_nid() to determine the CPT used to commit the
-	 * message. This ensures that we get a CPT that is correct for
-	 * the NI when the NI has been restricted to a subset of all CPTs.
-	 * If the selected CPT differs from the one currently locked, we
-	 * must unlock and relock the lnet_net_lock(), and then check whether
-	 * the configuration has changed. We don't have a hold on the best_ni
-	 * yet, and it may have vanished.
+	if (!peer_net) {
+		CERROR("gateway peer %s has no NI on net %s\n",
+		       libcfs_nid2str(peer->lp_primary_nid),
+		       libcfs_net2str(net_id));
+		return NULL;
+	}
+
+	return lnet_select_peer_ni(sd, peer, peer_net);
+}
+
+static inline void
+lnet_set_non_mr_pref_nid(struct lnet_send_data *sd)
+{
+	if (sd->sd_send_case & NMR_DST &&
+	    sd->sd_msg->msg_type != LNET_MSG_REPLY &&
+	    sd->sd_msg->msg_type != LNET_MSG_ACK &&
+	    sd->sd_best_lpni->lpni_pref_nnids == 0) {
+		CDEBUG(D_NET, "Setting preferred local NID %s on NMR peer %s\n",
+		       libcfs_nid2str(sd->sd_best_ni->ni_nid),
+		       libcfs_nid2str(sd->sd_best_lpni->lpni_nid));
+		lnet_peer_ni_set_non_mr_pref_nid(sd->sd_best_lpni,
+						 sd->sd_best_ni->ni_nid);
+	}
+}
+
+/* Source Specified
+ * Local Destination
+ * non-mr peer
+ *
+ * use the source and destination NIDs as the pathway
+ */
+static int
+lnet_handle_spec_local_nmr_dst(struct lnet_send_data *sd)
+{
+	/* the destination lpni is set before we get here. */
+
+	/* find local NI */
+	sd->sd_best_ni = lnet_nid2ni_locked(sd->sd_src_nid, sd->sd_cpt);
+	if (!sd->sd_best_ni) {
+		CERROR("Can't send to %s: src %s is not a local nid\n",
+		       libcfs_nid2str(sd->sd_dst_nid),
+		       libcfs_nid2str(sd->sd_src_nid));
+		return -EINVAL;
+	}
+
+	/* the preferred NID will only be set for NMR peers
 	 */
-	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
-	if (cpt != cpt2) {
-		u32 seq = lnet_get_dlc_seq_locked();
-		lnet_net_unlock(cpt);
-		cpt = cpt2;
-		lnet_net_lock(cpt);
-		if (seq != lnet_get_dlc_seq_locked()) {
-			lnet_peer_ni_decref_locked(best_lpni);
-			goto again;
-		}
+	lnet_set_non_mr_pref_nid(sd);
+
+	return lnet_handle_send(sd);
+}
+
+/* Source Specified
+ * Local Destination
+ * MR Peer
+ *
+ * Run the selection algorithm on the peer NIs unless we're sending
+ * a response, in this case just send to the destination
+ */
+static int
+lnet_handle_spec_local_mr_dst(struct lnet_send_data *sd)
+{
+	sd->sd_best_ni = lnet_nid2ni_locked(sd->sd_src_nid, sd->sd_cpt);
+	if (!sd->sd_best_ni) {
+		CERROR("Can't send to %s: src %s is not a local nid\n",
+		       libcfs_nid2str(sd->sd_dst_nid),
+		       libcfs_nid2str(sd->sd_src_nid));
+		return -EINVAL;
 	}
 
-	/*
-	 * store the best_lpni in the message right away to avoid having
-	 * to do the same operation under different conditions
+	/* only run the selection algorithm to pick the peer_ni if we're
+	 * sending a GET or a PUT. Responses are sent to the same
+	 * destination NID provided.
 	 */
-	msg->msg_txpeer = best_lpni;
-	msg->msg_txni = best_ni;
+	if (!(sd->sd_send_case & SND_RESP)) {
+		sd->sd_best_lpni =
+		  lnet_find_best_lpni_on_net(sd, sd->sd_peer,
+					     sd->sd_best_ni->ni_net->net_id);
+	}
 
-	/*
-	 * grab a reference for the best_ni since now it's in use in this
-	 * send. the reference will need to be dropped when the message is
-	 * finished in lnet_finalize()
+	if (sd->sd_best_lpni)
+		return lnet_handle_send(sd);
+
+	CERROR("can't send to %s. no NI on %s\n",
+	       libcfs_nid2str(sd->sd_dst_nid),
+	       libcfs_net2str(sd->sd_best_ni->ni_net->net_id));
+
+	return -EHOSTUNREACH;
+}
+
+struct lnet_ni *
+lnet_find_best_ni_on_spec_net(struct lnet_ni *cur_best_ni,
+			      struct lnet_peer *peer,
+			      struct lnet_peer_net *peer_net,
+			      int cpt,
+			      bool incr_seq)
+{
+	struct lnet_net *local_net;
+	struct lnet_ni *best_ni;
+
+	local_net = lnet_get_net_locked(peer_net->lpn_net_id);
+	if (!local_net)
+		return NULL;
+
+	/* Iterate through the NIs in this local Net and select
+	 * the NI to send from. The selection is determined by
+	 * these 3 criterion in the following priority:
+	 *	1. NUMA
+	 *	2. NI available credits
+	 *	3. Round Robin
 	 */
-	lnet_ni_addref_locked(msg->msg_txni, cpt);
+	best_ni = lnet_get_best_ni(local_net, cur_best_ni,
+				   peer, peer_net, cpt);
 
-	/*
-	 * Always set the target.nid to the best peer picked. Either the
-	 * nid will be one of the preconfigured NIDs, or the same NID as
-	 * what was originally set in the target or it will be the NID of
-	 * a router if this message should be routed
+	if (incr_seq && best_ni)
+		best_ni->ni_seq++;
+
+	return best_ni;
+}
+
+static int
+lnet_handle_find_routed_path(struct lnet_send_data *sd,
+			     lnet_nid_t dst_nid,
+			     struct lnet_peer_ni **gw_lpni,
+			     struct lnet_peer **gw_peer)
+{
+	struct lnet_peer_ni *gw;
+	lnet_nid_t src_nid = sd->sd_src_nid;
+
+	gw = lnet_find_route_locked(NULL, LNET_NIDNET(dst_nid),
+				    sd->sd_rtr_nid);
+	if (!gw) {
+		CERROR("no route to %s from %s\n",
+		       libcfs_nid2str(dst_nid), libcfs_nid2str(src_nid));
+		return -EHOSTUNREACH;
+	}
+
+	/* get the peer of the gw_ni */
+	LASSERT(gw->lpni_peer_net);
+	LASSERT(gw->lpni_peer_net->lpn_peer);
+
+	*gw_peer = gw->lpni_peer_net->lpn_peer;
+
+	if (!sd->sd_best_ni)
+		sd->sd_best_ni =
+			lnet_find_best_ni_on_spec_net(NULL, *gw_peer,
+						      gw->lpni_peer_net,
+						      sd->sd_md_cpt,
+						      true);
+
+	if (!sd->sd_best_ni) {
+		CERROR("Internal Error. Expected local ni on %s but non found :%s\n",
+		       libcfs_net2str(gw->lpni_peer_net->lpn_net_id),
+		       libcfs_nid2str(sd->sd_src_nid));
+		return -EFAULT;
+	}
+
+	/* if gw is MR let's find its best peer_ni
 	 */
-	msg->msg_target.nid = msg->msg_txpeer->lpni_nid;
+	if (lnet_peer_is_multi_rail(*gw_peer)) {
+		gw = lnet_find_best_lpni_on_net(sd, *gw_peer,
+						sd->sd_best_ni->ni_net->net_id);
+		/* We've already verified that the gw has an NI on that
+		 * desired net, but we're not finding it. Something is
+		 * wrong.
+		 */
+		if (!gw) {
+			CERROR("Internal Error. Route expected to %s from %s\n",
+			       libcfs_nid2str(dst_nid),
+			       libcfs_nid2str(src_nid));
+			return -EFAULT;
+		}
+	}
 
-	/*
-	 * lnet_msg_commit assigns the correct cpt to the message, which
-	 * is used to decrement the correct refcount on the ni when it's
-	 * time to return the credits
+	*gw_lpni = gw;
+
+	return 0;
+}
+
+/* Handle two cases:
+ *
+ * Case 1:
+ *  Source specified
+ *  Remote destination
+ *  Non-MR destination
+ *
+ * Case 2:
+ *  Source specified
+ *  Remote destination
+ *  MR destination
+ *
+ * The handling of these two cases is similar. Even though the destination
+ * can be MR or non-MR, we'll deal directly with the router.
+ */
+static int
+lnet_handle_spec_router_dst(struct lnet_send_data *sd)
+{
+	int rc;
+	struct lnet_peer_ni *gw_lpni = NULL;
+	struct lnet_peer *gw_peer = NULL;
+
+	/* find local NI */
+	sd->sd_best_ni = lnet_nid2ni_locked(sd->sd_src_nid, sd->sd_cpt);
+	if (!sd->sd_best_ni) {
+		CERROR("Can't send to %s: src %s is not a local nid\n",
+		       libcfs_nid2str(sd->sd_dst_nid),
+		       libcfs_nid2str(sd->sd_src_nid));
+		return -EINVAL;
+	}
+
+	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
+					  &gw_peer);
+	if (rc < 0)
+		return rc;
+
+	if (sd->sd_send_case & NMR_DST)
+		/* since the final destination is non-MR let's set its preferred
+		 * NID before we send
+		 */
+		lnet_set_non_mr_pref_nid(sd);
+
+	/* We're going to send to the gw found so let's set its
+	 * info
 	 */
-	lnet_msg_commit(msg, cpt);
+	sd->sd_peer = gw_peer;
+	sd->sd_best_lpni = gw_lpni;
 
-	/*
-	 * If we are routing the message then we don't need to overwrite
-	 * the src_nid since it would've been set at the origin. Otherwise
-	 * we are the originator so we need to set it.
+	return lnet_handle_send(sd);
+}
+
+struct lnet_ni *
+lnet_find_best_ni_on_local_net(struct lnet_peer *peer, int md_cpt)
+{
+	struct lnet_peer_net *peer_net = NULL;
+	struct lnet_ni *best_ni = NULL;
+
+	/* The peer can have multiple interfaces, some of them can be on
+	 * the local network and others on a routed network. We should
+	 * prefer the local network. However if the local network is not
+	 * available then we need to try the routed network
 	 */
-	if (!msg->msg_routing)
-		msg->msg_hdr.src_nid = cpu_to_le64(msg->msg_txni->ni_nid);
 
-	if (routing) {
-		msg->msg_target_is_router = 1;
-		msg->msg_target.pid = LNET_PID_LUSTRE;
-		/*
-		 * since we're routing we want to ensure that the
-		 * msg_hdr.dest_nid is set to the final destination. When
-		 * the router receives this message it knows how to route
-		 * it.
-		 */
-		msg->msg_hdr.dest_nid =
-			cpu_to_le64(final_dst ? final_dst->lpni_nid : dst_nid);
-	} else {
-		/*
-		 * if we're not routing set the dest_nid to the best peer
-		 * ni that we picked earlier in the algorithm.
+	/* go through all the peer nets and find the best_ni */
+	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
+		/* The peer's list of nets can contain non-local nets. We
+		 * want to only examine the local ones.
 		 */
-		msg->msg_hdr.dest_nid = cpu_to_le64(msg->msg_txpeer->lpni_nid);
+		if (!lnet_get_net_locked(peer_net->lpn_net_id))
+			continue;
+		best_ni = lnet_find_best_ni_on_spec_net(best_ni, peer,
+							peer_net, md_cpt,
+							false);
 	}
 
-	rc = lnet_post_send_locked(msg, 0);
+	if (best_ni)
+		/* increment sequence number so we can round robin */
+		best_ni->ni_seq++;
+
+	return best_ni;
+}
+
+static struct lnet_ni *
+lnet_find_existing_preferred_best_ni(struct lnet_send_data *sd)
+{
+	struct lnet_ni *best_ni = NULL;
+	struct lnet_peer_net *peer_net;
+	struct lnet_peer *peer = sd->sd_peer;
+	struct lnet_peer_ni *best_lpni = sd->sd_best_lpni;
+	struct lnet_peer_ni *lpni;
+	int cpt = sd->sd_cpt;
+
+	/* We must use a consistent source address when sending to a
+	 * non-MR peer. However, a non-MR peer can have multiple NIDs
+	 * on multiple networks, and we may even need to talk to this
+	 * peer on multiple networks -- certain types of
+	 * load-balancing configuration do this.
+	 *
+	 * So we need to pick the NI the peer prefers for this
+	 * particular network.
+	 */
+
+	/* Get the target peer_ni */
+	peer_net = lnet_peer_get_net_locked(peer,
+					    LNET_NIDNET(best_lpni->lpni_nid));
+	LASSERT(peer_net);
+	list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
+			    lpni_peer_nis) {
+		if (lpni->lpni_pref_nnids == 0)
+			continue;
+		LASSERT(lpni->lpni_pref_nnids == 1);
+		best_ni = lnet_nid2ni_locked(lpni->lpni_pref.nid, cpt);
+		break;
+	}
+
+	return best_ni;
+}
+
+/* Prerequisite: sd->sd_peer and sd->sd_best_lpni should be set */
+static int
+lnet_select_preferred_best_ni(struct lnet_send_data *sd)
+{
+	struct lnet_ni *best_ni = NULL;
+	struct lnet_peer_ni *best_lpni = sd->sd_best_lpni;
+
+	/* We must use a consistent source address when sending to a
+	 * non-MR peer. However, a non-MR peer can have multiple NIDs
+	 * on multiple networks, and we may even need to talk to this
+	 * peer on multiple networks -- certain types of
+	 * load-balancing configuration do this.
+	 *
+	 * So we need to pick the NI the peer prefers for this
+	 * particular network.
+	 */
+
+	best_ni = lnet_find_existing_preferred_best_ni(sd);
+
+	/* if best_ni is still not set just pick one */
+	if (!best_ni) {
+		best_ni =
+			lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
+						      sd->sd_best_lpni->lpni_peer_net,
+						      sd->sd_md_cpt, true);
+		/* If there is no best_ni we don't have a route */
+		if (!best_ni) {
+			CERROR("no path to %s from net %s\n",
+			       libcfs_nid2str(best_lpni->lpni_nid),
+			       libcfs_net2str(best_lpni->lpni_net->net_id));
+			return -EHOSTUNREACH;
+		}
+	}
+
+	sd->sd_best_ni = best_ni;
+
+	/* Set preferred NI if necessary. */
+	lnet_set_non_mr_pref_nid(sd);
+
+	return 0;
+}
+
+/* Source not specified
+ * Local destination
+ * Non-MR Peer
+ *
+ * always use the same source NID for NMR peers
+ * If we've talked to that peer before then we already have a preferred
+ * source NI associated with it. Otherwise, we select a preferred local NI
+ * and store it in the peer
+ */
+static int
+lnet_handle_any_local_nmr_dst(struct lnet_send_data *sd)
+{
+	int rc;
+
+	/* sd->sd_best_lpni is already set to the final destination */
+
+	/* At this point we should've created the peer ni and peer. If we
+	 * can't find it, then something went wrong. Instead of assert
+	 * output a relevant message and fail the send
+	 */
+	if (!sd->sd_best_lpni) {
+		CERROR("Internal fault. Unable to send msg %s to %s. NID not known\n",
+		       lnet_msgtyp2str(sd->sd_msg->msg_type),
+		       libcfs_nid2str(sd->sd_dst_nid));
+		return -EFAULT;
+	}
+
+	rc = lnet_select_preferred_best_ni(sd);
 	if (!rc)
-		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) : %s\n",
-		       libcfs_nid2str(msg->msg_hdr.src_nid),
-		       libcfs_nid2str(msg->msg_txni->ni_nid),
-		       libcfs_nid2str(src_nid),
-		       libcfs_nid2str(msg->msg_hdr.dest_nid),
-		       libcfs_nid2str(dst_nid),
-		       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
-		       lnet_msgtyp2str(msg->msg_type));
+		rc = lnet_handle_send(sd);
 
-	lnet_net_unlock(cpt);
+	return rc;
+}
+
+static int
+lnet_handle_any_mr_dsta(struct lnet_send_data *sd)
+{
+	/* NOTE we've already handled the remote peer case. So we only
+	 * need to worry about the local case here.
+	 *
+	 * if we're sending a response, ACK or reply, we need to send it
+	 * to the destination NID given to us. At this point we already
+	 * have the peer_ni we're suppose to send to, so just find the
+	 * best_ni on the peer net and use that. Since we're sending to an
+	 * MR peer then we can just run the selection algorithm on our
+	 * local NIs and pick the best one.
+	 */
+	if (sd->sd_send_case & SND_RESP) {
+		sd->sd_best_ni =
+		  lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
+						sd->sd_best_lpni->lpni_peer_net,
+						sd->sd_md_cpt, true);
+
+		if (!sd->sd_best_ni) {
+			/* We're not going to deal with not able to send
+			 * a response to the provided final destination
+			 */
+			CERROR("Can't send response to %s. No local NI available\n",
+			       libcfs_nid2str(sd->sd_dst_nid));
+			return -EHOSTUNREACH;
+		}
+
+		return lnet_handle_send(sd);
+	}
+
+	/* If we get here that means we're sending a fresh request, PUT or
+	 * GET, so we need to run our standard selection algorithm.
+	 * First find the best local interface that's on any of the peer's
+	 * networks.
+	 */
+	sd->sd_best_ni = lnet_find_best_ni_on_local_net(sd->sd_peer,
+							sd->sd_md_cpt);
+	if (sd->sd_best_ni) {
+		sd->sd_best_lpni =
+		  lnet_find_best_lpni_on_net(sd, sd->sd_peer,
+					     sd->sd_best_ni->ni_net->net_id);
+
+		/* if we're successful in selecting a peer_ni on the local
+		 * network, then send to it. Otherwise fall through and
+		 * try and see if we can reach it over another routed
+		 * network
+		 */
+		if (sd->sd_best_lpni) {
+			/* in case we initially started with a routed
+			 * destination, let's reset to local
+			 */
+			sd->sd_send_case &= ~REMOTE_DST;
+			sd->sd_send_case |= LOCAL_DST;
+			return lnet_handle_send(sd);
+		}
+
+		CERROR("Internal Error. Expected to have a best_lpni: %s -> %s\n",
+		       libcfs_nid2str(sd->sd_src_nid),
+		       libcfs_nid2str(sd->sd_dst_nid));
+
+		return -EFAULT;
+	}
+
+	/* Peer doesn't have a local network. Let's see if there is
+	 * a remote network we can reach it on.
+	 */
+	return PASS_THROUGH;
+}
+
+/* Case 1:
+ *	Source NID not specified
+ *	Local destination
+ *	MR peer
+ *
+ * Case 2:
+ *	Source NID not speified
+ *	Remote destination
+ *	MR peer
+ *
+ * In both of these cases if we're sending a response, ACK or REPLY, then
+ * we need to send to the destination NID provided.
+ *
+ * In the remote case let's deal with MR routers.
+ *
+ */
+static int
+lnet_handle_any_mr_dst(struct lnet_send_data *sd)
+{
+	int rc = 0;
+	struct lnet_peer *gw_peer = NULL;
+	struct lnet_peer_ni *gw_lpni = NULL;
+
+	/* handle sending a response to a remote peer here so we don't
+	 * have to worry about it if we hit lnet_handle_any_mr_dsta()
+	 */
+	if (sd->sd_send_case & REMOTE_DST &&
+	    sd->sd_send_case & SND_RESP) {
+		struct lnet_peer_ni *gw;
+		struct lnet_peer *gw_peer;
+
+		rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw,
+						  &gw_peer);
+		if (rc < 0) {
+			CERROR("Can't send response to %s. No route available\n",
+			       libcfs_nid2str(sd->sd_dst_nid));
+			return -EHOSTUNREACH;
+		}
+
+		sd->sd_best_lpni = gw;
+		sd->sd_peer = gw_peer;
+
+		return lnet_handle_send(sd);
+	}
+
+	/* Even though the NID for the peer might not be on a local network,
+	 * since the peer is MR there could be other interfaces on the
+	 * local network. In that case we'd still like to prefer the local
+	 * network over the routed network. If we're unable to do that
+	 * then we select the best router among the different routed networks,
+	 * and if the router is MR then we can deal with it as such.
+	 */
+	rc = lnet_handle_any_mr_dsta(sd);
+	if (rc != PASS_THROUGH)
+		return rc;
+
+	/* TODO; One possible enhancement is to run the selection
+	 * algorithm on the peer. However for remote peers the credits are
+	 * not decremented, so we'll be basically going over the peer NIs
+	 * in round robin. An MR router will run the selection algorithm
+	 * on the next-hop interfaces.
+	 */
+	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
+					  &gw_peer);
+	if (rc < 0)
+		return rc;
+
+	sd->sd_send_case &= ~LOCAL_DST;
+	sd->sd_send_case |= REMOTE_DST;
+
+	sd->sd_peer = gw_peer;
+	sd->sd_best_lpni = gw_lpni;
+
+	return lnet_handle_send(sd);
+}
+
+/* Source not specified
+ * Remote destination
+ * Non-MR peer
+ *
+ * Must send to the specified peer NID using the same source NID that
+ * we've used before. If it's the first time to talk to that peer then
+ * find the source NI and assign it as preferred to that peer
+ */
+static int
+lnet_handle_any_router_nmr_dst(struct lnet_send_data *sd)
+{
+	int rc;
+	struct lnet_peer_ni *gw_lpni = NULL;
+	struct lnet_peer *gw_peer = NULL;
+
+	/* Let's set if we have a preferred NI to talk to this NMR peer
+	 */
+	sd->sd_best_ni = lnet_find_existing_preferred_best_ni(sd);
+
+	/* find the router and that'll find the best NI if we didn't find
+	 * it already.
+	 */
+	rc = lnet_handle_find_routed_path(sd, sd->sd_dst_nid, &gw_lpni,
+					  &gw_peer);
+	if (rc < 0)
+		return rc;
+
+	/* set the best_ni we've chosen as the preferred one for
+	 * this peer
+	 */
+	lnet_set_non_mr_pref_nid(sd);
+
+	/* we'll be sending to the gw */
+	sd->sd_best_lpni = gw_lpni;
+	sd->sd_peer = gw_peer;
+
+	return lnet_handle_send(sd);
+}
+
+static int
+lnet_handle_send_case_locked(struct lnet_send_data *sd)
+{
+	/* Turn off the SND_RESP bit.
+	 * It will be checked in the case handling
+	 */
+	u32 send_case = sd->sd_send_case &= ~SND_RESP;
+
+	CDEBUG(D_NET, "Source %s%s to %s %s %s destination\n",
+	       (send_case & SRC_SPEC) ? "Specified: " : "ANY",
+	       (send_case & SRC_SPEC) ? libcfs_nid2str(sd->sd_src_nid) : "",
+	       (send_case & MR_DST) ? "MR: " : "NMR: ",
+	       libcfs_nid2str(sd->sd_dst_nid),
+	       (send_case & LOCAL_DST) ? "local" : "routed");
+
+	switch (send_case) {
+	/* For all cases where the source is specified, we should always
+	 * use the destination NID, whether it's an MR destination or not,
+	 * since we're continuing a series of related messages for the
+	 * same RPC
+	 */
+	case SRC_SPEC_LOCAL_NMR_DST:
+		return lnet_handle_spec_local_nmr_dst(sd);
+	case SRC_SPEC_LOCAL_MR_DST:
+		return lnet_handle_spec_local_mr_dst(sd);
+	case SRC_SPEC_ROUTER_NMR_DST:
+	case SRC_SPEC_ROUTER_MR_DST:
+		return lnet_handle_spec_router_dst(sd);
+	case SRC_ANY_LOCAL_NMR_DST:
+		return lnet_handle_any_local_nmr_dst(sd);
+	case SRC_ANY_LOCAL_MR_DST:
+	case SRC_ANY_ROUTER_MR_DST:
+		return lnet_handle_any_mr_dst(sd);
+	case SRC_ANY_ROUTER_NMR_DST:
+		return lnet_handle_any_router_nmr_dst(sd);
+	default:
+		CERROR("Unknown send case\n");
+		return -1;
+	}
+}
+
+static int
+lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
+		    struct lnet_msg *msg, lnet_nid_t rtr_nid)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer *peer;
+	struct lnet_send_data send_data;
+	int cpt, rc;
+	int md_cpt;
+	u32 send_case = 0;
+
+	memset(&send_data, 0, sizeof(send_data));
+
+	/* get an initial CPT to use for locking. The idea here is not to
+	 * serialize the calls to select_pathway, so that as many
+	 * operations can run concurrently as possible. To do that we use
+	 * the CPT where this call is being executed. Later on when we
+	 * determine the CPT to use in lnet_message_commit, we switch the
+	 * lock and check if there was any configuration change.  If none,
+	 * then we proceed, if there is, then we restart the operation.
+	 */
+	cpt = lnet_net_lock_current();
+
+	md_cpt = lnet_cpt_of_md(msg->msg_md, msg->msg_offset);
+	if (md_cpt == CFS_CPT_ANY)
+		md_cpt = cpt;
+
+again:
+	/* If we're being asked to send to the loopback interface, there
+	 * is no need to go through any selection. We can just shortcut
+	 * the entire process and send over lolnd
+	 */
+	if (LNET_NETTYP(LNET_NIDNET(dst_nid)) == LOLND) {
+		/* No send credit hassles with LOLND */
+		lnet_ni_addref_locked(the_lnet.ln_loni, cpt);
+		msg->msg_hdr.dest_nid = cpu_to_le64(the_lnet.ln_loni->ni_nid);
+		if (!msg->msg_routing)
+			msg->msg_hdr.src_nid =
+				cpu_to_le64(the_lnet.ln_loni->ni_nid);
+		msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
+		lnet_msg_commit(msg, cpt);
+		msg->msg_txni = the_lnet.ln_loni;
+		lnet_net_unlock(cpt);
+
+		return LNET_CREDIT_OK;
+	}
+
+	/* find an existing peer_ni, or create one and mark it as having been
+	 * created due to network traffic. This call will create the
+	 * peer->peer_net->peer_ni tree.
+	 */
+	lpni = lnet_nid2peerni_locked(dst_nid, LNET_NID_ANY, cpt);
+	if (IS_ERR(lpni)) {
+		lnet_net_unlock(cpt);
+		return PTR_ERR(lpni);
+	}
+
+	/* Now that we have a peer_ni, check if we want to discover
+	 * the peer. Traffic to the LNET_RESERVED_PORTAL should not
+	 * trigger discovery.
+	 */
+	peer = lpni->lpni_peer_net->lpn_peer;
+	if (lnet_msg_discovery(msg) && !lnet_peer_is_uptodate(peer)) {
+		lnet_nid_t primary_nid;
+
+		rc = lnet_discover_peer_locked(lpni, cpt, false);
+		if (rc) {
+			lnet_peer_ni_decref_locked(lpni);
+			lnet_net_unlock(cpt);
+			return rc;
+		}
+		/* The peer may have changed. */
+		peer = lpni->lpni_peer_net->lpn_peer;
+		/* queue message and return */
+		msg->msg_src_nid_param = src_nid;
+		msg->msg_rtr_nid_param = rtr_nid;
+		msg->msg_sending = 0;
+		list_add_tail(&msg->msg_list, &peer->lp_dc_pendq);
+		lnet_peer_ni_decref_locked(lpni);
+		primary_nid = peer->lp_primary_nid;
+		lnet_net_unlock(cpt);
+
+		CDEBUG(D_NET, "%s pending discovery\n",
+		       libcfs_nid2str(primary_nid));
+
+		return LNET_DC_WAIT;
+	}
+	lnet_peer_ni_decref_locked(lpni);
+
+	/* If peer is not healthy then can not send anything to it */
+	if (!lnet_is_peer_healthy_locked(peer)) {
+		lnet_net_unlock(cpt);
+		return -EHOSTUNREACH;
+	}
+
+	/* Identify the different send cases
+	 */
+	if (src_nid == LNET_NID_ANY)
+		send_case |= SRC_ANY;
+	else
+		send_case |= SRC_SPEC;
+
+	if (lnet_get_net_locked(LNET_NIDNET(dst_nid)))
+		send_case |= LOCAL_DST;
+	else
+		send_case |= REMOTE_DST;
+
+	if (!lnet_peer_is_multi_rail(peer))
+		send_case |= NMR_DST;
+	else
+		send_case |= MR_DST;
+
+	if (msg->msg_type == LNET_MSG_REPLY ||
+	    msg->msg_type == LNET_MSG_ACK)
+		send_case |= SND_RESP;
+
+	/* assign parameters to the send_data */
+	send_data.sd_msg = msg;
+	send_data.sd_rtr_nid = rtr_nid;
+	send_data.sd_src_nid = src_nid;
+	send_data.sd_dst_nid = dst_nid;
+	send_data.sd_best_lpni = lpni;
+	/* keep a pointer to the final destination in case we're going to
+	 * route, so we'll need to access it later
+	 */
+	send_data.sd_final_dst_lpni = lpni;
+	send_data.sd_peer = peer;
+	send_data.sd_md_cpt = md_cpt;
+	send_data.sd_cpt = cpt;
+	send_data.sd_send_case = send_case;
+
+	rc = lnet_handle_send_case_locked(&send_data);
+
+	if (rc == REPEAT_SEND)
+		goto again;
+
+	lnet_net_unlock(send_data.sd_cpt);
 
 	return rc;
 }
-- 
1.8.3.1
