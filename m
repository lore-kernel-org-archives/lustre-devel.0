From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 21/34] LU-7734 lnet: simplify and fix
 lnet_select_pathway()
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763568.32103.16087987326485396768.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

In lnet_select_pathway() we restart selection if the DLC seq
counter changes. Provided we take a hold on the preferred
lnet_peer_ni, we only need to restart if an lnet_ni was added
or removed. Update the locations where lnet_incr_dlc_seq() is
called to take this into account.

A number of local variables must be reset whenever we goto
again. Do this immediately after the label for the global
variables, and immediately before the block that uses them
for the helper variables.

In the loop where NUMA distances are compared, use the NUMA
range for distances smaller than the NUMA range, simplifying
the subsequent comparisons between distances.

Remote the lo_sent output parameter. Instead do an early
return with LNET_CREDIT_OK.

Move the increment of the best_lpni->lpni_seq number after
the check that best_lpni isn't NULL.

When routing, the best_gw should be treated as the best_lpni
for the purpose of determining the CPT to lock.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: Olaf Weber <olaf@sgi.com>
Change-Id: Ie71eebc2301601cf1c85c6248dbed06951b89274
Reviewed-on: http://review.whamcloud.com/20720
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c   |   11 +
 drivers/staging/lustre/lnet/lnet/lib-move.c |  213 +++++++++++----------------
 2 files changed, 88 insertions(+), 136 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 9807cfb3a0fc..ac6efcd746c5 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -72,10 +72,10 @@ MODULE_PARM_DESC(lnet_numa_range,
 
 /*
  * This sequence number keeps track of how many times DLC was used to
- * update the configuration. It is incremented on any DLC update and
- * checked when sending a message to determine if there is a need to
- * re-run the selection algorithm to handle configuration change.
- * Look at lnet_select_pathway() for more details on its usage.
+ * update the local NIs. It is incremented when a NI is added or
+ * removed and checked when sending a message to determine if there is
+ * a need to re-run the selection algorithm. See lnet_select_pathway()
+ * for more details on its usage.
  */
 static atomic_t lnet_dlc_seq_no = ATOMIC_INIT(0);
 
@@ -1223,6 +1223,7 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
 	lnet_net_lock(LNET_LOCK_EX);
 	ni->ni_state = LNET_NI_STATE_DELETING;
 	lnet_ni_unlink_locked(ni);
+	lnet_incr_dlc_seq();
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* clear messages for this NI on the lazy portal */
@@ -2723,7 +2724,6 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lnet_incr_dlc_seq();
 		rc = lnet_add_peer_ni_to_peer(cfg->prcfg_key_nid,
 					      cfg->prcfg_cfg_nid,
 					      cfg->prcfg_mr);
@@ -2738,7 +2738,6 @@ LNetCtl(unsigned int cmd, void *arg)
 			return -EINVAL;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lnet_incr_dlc_seq();
 		rc = lnet_del_peer_ni_from_peer(cfg->prcfg_key_nid,
 						cfg->prcfg_cfg_nid);
 		mutex_unlock(&the_lnet.ln_api_mutex);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index b4c7c8aa33a7..8019c59cc64e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1132,48 +1132,44 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 
 static int
 lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
-		    struct lnet_msg *msg, lnet_nid_t rtr_nid, bool *lo_sent)
+		    struct lnet_msg *msg, lnet_nid_t rtr_nid)
 {
 	struct lnet_ni *best_ni = NULL;
 	struct lnet_peer_ni *best_lpni = NULL;
-	struct lnet_peer_ni *net_gw = NULL;
 	struct lnet_peer_ni *best_gw = NULL;
 	struct lnet_peer_ni *lpni;
-	struct lnet_peer *peer = NULL;
+	struct lnet_peer *peer;
 	struct lnet_peer_net *peer_net;
 	struct lnet_net *local_net;
-	struct lnet_ni *ni = NULL;
+	struct lnet_ni *ni;
+	__u32 seq;
 	int cpt, cpt2, rc;
-	bool routing = false;
-	bool ni_is_pref = false;
-	bool preferred = false;
-	int best_credits = 0;
-	u32 seq, seq2;
-	int best_lpni_credits = INT_MIN;
-	int md_cpt = 0;
-	unsigned int shortest_distance = UINT_MAX;
-	unsigned int distance = 0;
-	bool found_ir = false;
+	bool routing;
+	bool ni_is_pref;
+	bool preferred;
+	int best_credits;
+	int best_lpni_credits;
+	int md_cpt;
+	unsigned int shortest_distance;
 
-again:
 	/*
 	 * get an initial CPT to use for locking. The idea here is not to
 	 * serialize the calls to select_pathway, so that as many
 	 * operations can run concurrently as possible. To do that we use
 	 * the CPT where this call is being executed. Later on when we
 	 * determine the CPT to use in lnet_message_commit, we switch the
-	 * lock and check if there was any configuration changes, if none,
-	 * then we proceed, if there is, then we'll need to update the cpt
-	 * and redo the operation.
+	 * lock and check if there was any configuration change.  If none,
+	 * then we proceed, if there is, then we restart the operation.
 	 */
 	cpt = lnet_net_lock_current();
-
+again:
+	best_ni = NULL;
+	best_lpni = NULL;
 	best_gw = NULL;
-	routing = false;
 	local_net = NULL;
-	best_ni = NULL;
-	shortest_distance = UINT_MAX;
-	found_ir = false;
+	routing = false;
+
+	seq = lnet_get_dlc_seq_locked();
 
 	if (the_lnet.ln_shutdown) {
 		lnet_net_unlock(cpt);
@@ -1186,13 +1182,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	else
 		md_cpt = CFS_CPT_ANY;
 
-	/*
-	 * initialize the variables which could be reused if we go to
-	 * again
-	 */
-	lpni = NULL;
-	seq = lnet_get_dlc_seq_locked();
-
 	peer = lnet_find_or_create_peer_locked(dst_nid, cpt);
 	if (IS_ERR(peer)) {
 		lnet_net_unlock(cpt);
@@ -1234,10 +1223,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 				      libcfs_nid2str(src_nid));
 			return -EINVAL;
 		}
-	}
-
-	if (best_ni)
 		goto pick_peer;
+	}
 
 	/*
 	 * Decide whether we need to route to peer_ni.
@@ -1254,6 +1241,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 
 		local_net = lnet_get_net_locked(peer_net->lpn_net_id);
 		if (!local_net) {
+			struct lnet_peer_ni *net_gw;
 			/*
 			 * go through each peer_ni on that peer_net and
 			 * determine the best possible gw to go through
@@ -1307,8 +1295,12 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 *	2. NI available credits
 		 *	3. Round Robin
 		 */
+		shortest_distance = UINT_MAX;
+		best_credits = INT_MIN;
+		ni = NULL;
 		while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
 			int ni_credits;
+			unsigned int distance;
 
 			if (!lnet_is_ni_healthy_locked(ni))
 				continue;
@@ -1316,7 +1308,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			ni_credits = atomic_read(&ni->ni_tx_credits);
 
 			/*
-			 * calculate the distance from the cpt on which
+			 * calculate the distance from the CPT on which
 			 * the message memory is allocated to the CPT of
 			 * the NI's physical device
 			 */
@@ -1325,84 +1317,31 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 						    ni->dev_cpt);
 
 			/*
-			 * If we already have a closer NI within the NUMA
-			 * range provided, then there is no need to
-			 * consider the current NI. Move on to the next
-			 * one.
+			 * All distances smaller than the NUMA range
+			 * are treated equally.
 			 */
-			if (distance > shortest_distance &&
-			    distance > lnet_numa_range)
-				continue;
+			if (distance < lnet_numa_range)
+				distance = lnet_numa_range;
 
-			if (distance < shortest_distance &&
-			    distance > lnet_numa_range) {
-				/*
-				 * The current NI is the closest one that we
-				 * have found, even though it's not in the
-				 * NUMA range specified. This occurs if
-				 * the NUMA range is less than the least
-				 * of the distances in the system.
-				 * In effect NUMA range consideration is
-				 * turned off.
-				 */
+			/*
+			 * Select on shorter distance, then available
+			 * credits, then round-robin.
+			 */
+			if (distance > shortest_distance) {
+				continue;
+			} else if (distance < shortest_distance) {
 				shortest_distance = distance;
-			} else if ((distance <= shortest_distance &&
-				    distance < lnet_numa_range) ||
-				   distance == shortest_distance) {
-				/*
-				 * This NI is either within range or it's
-				 * equidistant. In both of these cases we
-				 * would want to select the NI based on
-				 * its available credits first, and then
-				 * via Round Robin.
-				 */
-				if (distance <= shortest_distance &&
-				    distance < lnet_numa_range) {
-					/*
-					 * If this is the first NI that's
-					 * within range, then set the
-					 * shortest distance to the range
-					 * specified by the user. In
-					 * effect we're saying that all
-					 * NIs that fall within this NUMA
-					 * range shall be dealt with as
-					 * having equal NUMA weight. Which
-					 * will mean that we should select
-					 * through that set by their
-					 * available credits first
-					 * followed by Round Robin.
-					 *
-					 * And since this is the first NI
-					 * in the range, let's just set it
-					 * as our best_ni for now. The
-					 * following NIs found in the
-					 * range will be dealt with as
-					 * mentioned previously.
-					 */
-					shortest_distance = lnet_numa_range;
-					if (!found_ir) {
-						found_ir = true;
-						goto set_ni;
-					}
-				}
-				/*
-				 * This NI is NUMA equidistant let's
-				 * select using credits followed by Round
-				 * Robin.
-				 */
-				if (ni_credits < best_credits) {
+			} else if (ni_credits < best_credits) {
+				continue;
+			} else if (ni_credits == best_credits) {
+				if (best_ni && best_ni->ni_seq <= ni->ni_seq)
 					continue;
-				} else if (ni_credits == best_credits) {
-					if (best_ni &&
-					    best_ni->ni_seq <= ni->ni_seq)
-						continue;
-				}
 			}
-set_ni:
 			best_ni = ni;
 			best_credits = ni_credits;
 		}
 	}
+
 	/*
 	 * if the peer is not MR capable, then we should always send to it
 	 * using the first NI in the NET we determined.
@@ -1436,17 +1375,12 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 			msg->msg_hdr.src_nid = cpu_to_le64(best_ni->ni_nid);
 		msg->msg_target.nid = best_ni->ni_nid;
 		lnet_msg_commit(msg, cpt);
-
-		lnet_net_unlock(cpt);
 		msg->msg_txni = best_ni;
-		lnet_ni_send(best_ni, msg);
+		lnet_net_unlock(cpt);
 
-		*lo_sent = true;
-		return 0;
+		return LNET_CREDIT_OK;
 	}
 
-	lpni = NULL;
-
 	if (msg->msg_type == LNET_MSG_REPLY ||
 	    msg->msg_type == LNET_MSG_ACK) {
 		/*
@@ -1509,14 +1443,22 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 */
 		u32 net_id = peer_net->lpn_net_id;
 
-		lnet_net_unlock(cpt);
-		if (!best_lpni)
-			LCONSOLE_WARN("peer net %s unhealthy\n",
-				      libcfs_net2str(net_id));
+		LCONSOLE_WARN("peer net %s unhealthy\n",
+			      libcfs_net2str(net_id));
 		goto again;
 	}
 
-	best_lpni = NULL;
+	/*
+	 * Look at the peer NIs for the destination peer that connect
+	 * to the chosen net. If a peer_ni is preferred when using the
+	 * best_ni to communicate, we use that one. If there is no
+	 * preferred peer_ni, or there are multiple preferred peer_ni,
+	 * the available transmit credits are used. If the transmit
+	 * credits are equal, we round-robin over the peer_ni.
+	 */
+	lpni = NULL;
+	best_lpni_credits = INT_MIN;
+	preferred = false;
 	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
 		/*
 		 * if this peer ni is not healthy just skip it, no point in
@@ -1559,12 +1501,6 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		best_lpni_credits = lpni->lpni_txcredits;
 	}
 
-	/*
-	 * Increment sequence number of the peer selected so that we can
-	 * pick the next one in Round Robin.
-	 */
-	best_lpni->lpni_seq++;
-
 	/* if we still can't find a peer ni then we can't reach it */
 	if (!best_lpni) {
 		u32 net_id = peer_net ? peer_net->lpn_net_id :
@@ -1577,6 +1513,25 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	}
 
 send:
+	/*
+	 * Increment sequence number of the peer selected so that we
+	 * pick the next one in Round Robin.
+	 */
+	best_lpni->lpni_seq++;
+
+	/*
+	 * When routing the best gateway found acts as the best peer
+	 * NI to send to.
+	 */
+	if (routing)
+		best_lpni = best_gw;
+
+	/*
+	 * grab a reference on the peer_ni so it sticks around even if
+	 * we need to drop and relock the lnet_net_lock below.
+	 */
+	lnet_peer_ni_addref_locked(best_lpni);
+
 	/*
 	 * Use lnet_cpt_of_nid() to determine the CPT used to commit the
 	 * message. This ensures that we get a CPT that is correct for
@@ -1584,16 +1539,15 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 * If the selected CPT differs from the one currently locked, we
 	 * must unlock and relock the lnet_net_lock(), and then check whether
 	 * the configuration has changed. We don't have a hold on the best_ni
-	 * or best_peer_ni yet, and they may have vanished.
+	 * yet, and it may have vanished.
 	 */
 	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
 	if (cpt != cpt2) {
 		lnet_net_unlock(cpt);
 		cpt = cpt2;
 		lnet_net_lock(cpt);
-		seq2 = lnet_get_dlc_seq_locked();
-		if (seq2 != seq) {
-			lnet_net_unlock(cpt);
+		if (seq != lnet_get_dlc_seq_locked()) {
+			lnet_peer_ni_decref_locked(best_lpni);
 			goto again;
 		}
 	}
@@ -1602,15 +1556,15 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	 * store the best_lpni in the message right away to avoid having
 	 * to do the same operation under different conditions
 	 */
-	msg->msg_txpeer = (routing) ? best_gw : best_lpni;
+	msg->msg_txpeer = best_lpni;
 	msg->msg_txni = best_ni;
+
 	/*
 	 * grab a reference for the best_ni since now it's in use in this
 	 * send. the reference will need to be dropped when the message is
 	 * finished in lnet_finalize()
 	 */
 	lnet_ni_addref_locked(msg->msg_txni, cpt);
-	lnet_peer_ni_addref_locked(msg->msg_txpeer);
 
 	/*
 	 * set the destination nid in the message here because it's
@@ -1659,7 +1613,6 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 {
 	lnet_nid_t		dst_nid = msg->msg_target.nid;
 	int			rc;
-	bool                    lo_sent = false;
 
 	/*
 	 * NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
@@ -1676,8 +1629,8 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 
 	LASSERT(!msg->msg_tx_committed);
 
-	rc = lnet_select_pathway(src_nid, dst_nid, msg, rtr_nid, &lo_sent);
-	if (rc < 0 || lo_sent)
+	rc = lnet_select_pathway(src_nid, dst_nid, msg, rtr_nid);
+	if (rc < 0)
 		return rc;
 
 	if (rc == LNET_CREDIT_OK)
