From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 27/34] LU-7734 lnet: fix routing selection
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763590.32103.13916552051734764199.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Always prefer locally connected networks over routed networks.
If there are multiple routed networks and no connected networks
pick the best gateway to use. If all gateways are equal then
round robin through them.

Renamed dev_cpt to ni_dev_cpt to maintain naming convention.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Change-Id: Ie6a3aaa7a9ec4f5474baf5e1ec0258d481418cb1
Reviewed-on: http://review.whamcloud.com/21326
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    4 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    4 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  217 +++++++++++---------
 5 files changed, 131 insertions(+), 98 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 0761fd533f8d..2d73aa1a121c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -361,7 +361,7 @@ struct lnet_ni {
 	struct lnet_element_stats ni_stats;
 
 	/* physical device CPT */
-	int			dev_cpt;
+	int			ni_dev_cpt;
 
 	/* sequence number used to round robin over nis within a net */
 	u32			ni_seq;
@@ -464,6 +464,8 @@ struct lnet_peer_ni {
 	int			 lpni_rtr_refcount;
 	/* sequence number used to round robin over peer nis within a net */
 	u32			lpni_seq;
+	/* sequence number used to round robin over gateways */
+	__u32			lpni_gw_seq;
 	/* health flag */
 	bool			lpni_healthy;
 	/* returned RC ping features. Protected with lpni_lock */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 71256500f245..0ed29177819a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2891,7 +2891,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		goto failed;
 
 	node_id = dev_to_node(ibdev->ibd_hdev->ibh_ibdev->dma_device);
-	ni->dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
+	ni->ni_dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
 
 	net->ibn_dev = ibdev;
 	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ibdev->ibd_ifip);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index c14711804d7b..2ec84a73c522 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2798,10 +2798,10 @@ ksocknal_startup(struct lnet_ni *ni)
 				  net->ksnn_interfaces[0].ksni_name);
 	if (net_dev) {
 		node_id = dev_to_node(&net_dev->dev);
-		ni->dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
+		ni->ni_dev_cpt = cfs_cpt_of_node(lnet_cpt_table(), node_id);
 		dev_put(net_dev);
 	} else {
-		ni->dev_cpt = CFS_CPT_ANY;
+		ni->ni_dev_cpt = CFS_CPT_ANY;
 	}
 
 	/* call it before add it to ksocknal_data.ksnd_nets */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 60176d05d34a..f57200eab746 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1910,7 +1910,7 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
 	cfg_ni->lic_nid = ni->ni_nid;
 	cfg_ni->lic_status = ni->ni_status->ns_status;
 	cfg_ni->lic_tcp_bonding = use_tcp_bonding;
-	cfg_ni->lic_dev_cpt = ni->dev_cpt;
+	cfg_ni->lic_dev_cpt = ni->ni_dev_cpt;
 
 	memcpy(&tun->lt_cmn, &ni->ni_net->net_tunables, sizeof(tun->lt_cmn));
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 12bc80d060e9..141983f0ef83 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1130,6 +1130,69 @@ lnet_find_route_locked(struct lnet_net *net, lnet_nid_t target,
 	return lpni_best;
 }
 
+static struct lnet_ni *
+lnet_get_best_ni(struct lnet_net *local_net, struct lnet_ni *cur_ni,
+		 int md_cpt)
+{
+	struct lnet_ni *ni = NULL, *best_ni = cur_ni;
+	unsigned int shortest_distance;
+	int best_credits;
+
+	if (!best_ni) {
+		shortest_distance = UINT_MAX;
+		best_credits = INT_MIN;
+	} else {
+		shortest_distance = cfs_cpt_distance(lnet_cpt_table(), md_cpt,
+						     best_ni->ni_dev_cpt);
+		best_credits = atomic_read(&best_ni->ni_tx_credits);
+	}
+
+	while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
+		unsigned int distance;
+		int ni_credits;
+
+		if (!lnet_is_ni_healthy_locked(ni))
+			continue;
+
+		ni_credits = atomic_read(&ni->ni_tx_credits);
+
+		/*
+		 * calculate the distance from the CPT on which
+		 * the message memory is allocated to the CPT of
+		 * the NI's physical device
+		 */
+		distance = cfs_cpt_distance(lnet_cpt_table(),
+					    md_cpt,
+					    ni->ni_dev_cpt);
+
+		/*
+		 * All distances smaller than the NUMA range
+		 * are treated equally.
+		 */
+		if (distance < lnet_numa_range)
+			distance = lnet_numa_range;
+
+		/*
+		 * Select on shorter distance, then available
+		 * credits, then round-robin.
+		 */
+		if (distance > shortest_distance) {
+			continue;
+		} else if (distance < shortest_distance) {
+			shortest_distance = distance;
+		} else if (ni_credits < best_credits) {
+			continue;
+		} else if (ni_credits == best_credits) {
+			if (best_ni && (best_ni)->ni_seq <= ni->ni_seq)
+				continue;
+		}
+		best_ni = ni;
+		best_credits = ni_credits;
+	}
+
+	return best_ni;
+}
+
 static int
 lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		    struct lnet_msg *msg, lnet_nid_t rtr_nid)
@@ -1138,20 +1201,19 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	struct lnet_peer_ni *best_lpni = NULL;
 	struct lnet_peer_ni *best_gw = NULL;
 	struct lnet_peer_ni *lpni;
+	struct lnet_peer_ni *final_dst;
 	struct lnet_peer *peer;
 	struct lnet_peer_net *peer_net;
 	struct lnet_net *local_net;
-	struct lnet_ni *ni;
 	__u32 seq;
 	int cpt, cpt2, rc;
 	bool routing;
 	bool routing2;
 	bool ni_is_pref;
 	bool preferred;
-	int best_credits;
+	bool local_found;
 	int best_lpni_credits;
 	int md_cpt;
-	unsigned int shortest_distance;
 
 	/*
 	 * get an initial CPT to use for locking. The idea here is not to
@@ -1167,9 +1229,11 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 	best_ni = NULL;
 	best_lpni = NULL;
 	best_gw = NULL;
+	final_dst = NULL;
 	local_net = NULL;
 	routing = false;
 	routing2 = false;
+	local_found = false;
 
 	seq = lnet_get_dlc_seq_locked();
 
@@ -1334,62 +1398,68 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		goto pick_peer;
 
 	/*
-	 * Decide whether we need to route to peer_ni.
-	 * Get the local net that I need to be on to be able to directly
-	 * send to that peer.
+	 * pick the best_ni by going through all the possible networks of
+	 * that peer and see which local NI is best suited to talk to that
+	 * peer.
 	 *
-	 * a. Find the peer which the dst_nid belongs to.
-	 * b. Iterate through each of the peer_nets/nis to decide
-	 * the best peer/local_ni pair to use
+	 * Locally connected networks will always be preferred over
+	 * a routed network. If there are only routed paths to the peer,
+	 * then the best route is chosen. If all routes are equal then
+	 * they are used in round robin.
 	 */
-	shortest_distance = UINT_MAX;
-	best_credits = INT_MIN;
 	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
 		if (!lnet_is_peer_net_healthy_locked(peer_net))
 			continue;
 
 		local_net = lnet_get_net_locked(peer_net->lpn_net_id);
-		if (!local_net && !routing) {
+		if (!local_net && !routing && !local_found) {
 			struct lnet_peer_ni *net_gw;
-			/*
-			 * go through each peer_ni on that peer_net and
-			 * determine the best possible gw to go through
-			 */
-			list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
-					    lpni_on_peer_net_list) {
-				net_gw = lnet_find_route_locked(NULL,
-								lpni->lpni_nid,
-								rtr_nid);
 
+			lpni = list_entry(peer_net->lpn_peer_nis.next,
+					  struct lnet_peer_ni,
+					  lpni_on_peer_net_list);
+
+			net_gw = lnet_find_route_locked(NULL,
+							lpni->lpni_nid,
+							rtr_nid);
+			if (!net_gw)
+				continue;
+
+			if (best_gw) {
 				/*
-				 * if no route is found for that network then
-				 * move onto the next peer_ni in the peer
+				 * lnet_find_route_locked() call
+				 * will return the best_Gw on the
+				 * lpni->lpni_nid network.
+				 * However, best_gw and net_gw can
+				 * be on different networks.
+				 * Therefore need to compare them
+				 * to pick the better of either.
 				 */
-				if (!net_gw)
+				if (lnet_compare_peers(best_gw, net_gw) > 0)
+					continue;
+				if (best_gw->lpni_gw_seq <= net_gw->lpni_gw_seq)
 					continue;
-
-				if (!best_gw) {
-					best_gw = net_gw;
-				} else  {
-					rc = lnet_compare_peers(net_gw,
-								best_gw);
-					if (rc > 0)
-						best_gw = net_gw;
-				}
 			}
+			best_gw = net_gw;
+			final_dst = lpni;
 
-			if (!best_gw)
-				continue;
-
-			local_net = lnet_get_net_locked
-					(LNET_NIDNET(best_gw->lpni_nid));
 			routing2 = true;
 		} else {
-			routing2 = false;
 			best_gw = NULL;
+			final_dst = NULL;
+			routing2 = false;
+			local_found = true;
 		}
 
-		/* no routable net found go on to a different net */
+		/*
+		 * a gw on this network is found, but there could be
+		 * other better gateways on other networks. So don't pick
+		 * the best_ni until we determine the best_gw.
+		 */
+		if (best_gw)
+			continue;
+
+		/* if no local_net found continue */
 		if (!local_net)
 			continue;
 
@@ -1401,70 +1471,30 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 *	2. NI available credits
 		 *	3. Round Robin
 		 */
-		ni = NULL;
-		while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
-			int ni_credits;
-			unsigned int distance;
-
-			if (!lnet_is_ni_healthy_locked(ni))
-				continue;
-
-			ni_credits = atomic_read(&ni->ni_tx_credits);
-
-			/*
-			 * calculate the distance from the CPT on which
-			 * the message memory is allocated to the CPT of
-			 * the NI's physical device
-			 */
-			distance = cfs_cpt_distance(lnet_cpt_table(),
-						    md_cpt,
-						    ni->dev_cpt);
-
-			/*
-			 * All distances smaller than the NUMA range
-			 * are treated equally.
-			 */
-			if (distance < lnet_numa_range)
-				distance = lnet_numa_range;
+		best_ni = lnet_get_best_ni(local_net, best_ni, md_cpt);
+	}
 
-			/*
-			 * Select on shorter distance, then available
-			 * credits, then round-robin.
-			 */
-			if (distance > shortest_distance) {
-				continue;
-			} else if (distance < shortest_distance) {
-				shortest_distance = distance;
-			} else if (ni_credits < best_credits) {
-				continue;
-			} else if (ni_credits == best_credits) {
-				if (best_ni && best_ni->ni_seq <= ni->ni_seq)
-					continue;
-			}
-			best_ni = ni;
-			best_credits = ni_credits;
-		}
+	if (!best_ni && !best_gw) {
+		lnet_net_unlock(cpt);
+		LCONSOLE_WARN("No local ni found to send from to %s\n",
+			      libcfs_nid2str(dst_nid));
+		return -EINVAL;
 	}
 
-	if (routing2) {
+	if (!best_ni) {
+		best_ni = lnet_get_best_ni(best_gw->lpni_net, best_ni, md_cpt);
+		LASSERT(best_gw && best_ni);
+
 		/*
-		 * RULE: Each node considers only the next-hop
-		 *
 		 * We're going to route the message, so change the peer to
 		 * the router.
 		 */
 		LASSERT(best_gw->lpni_peer_net);
 		LASSERT(best_gw->lpni_peer_net->lpn_peer);
+		best_gw->lpni_gw_seq++;
 		peer = best_gw->lpni_peer_net->lpn_peer;
 	}
 
-	if (!best_ni) {
-		lnet_net_unlock(cpt);
-		LCONSOLE_WARN("No local ni found to send from to %s\n",
-			      libcfs_nid2str(dst_nid));
-		return -EINVAL;
-	}
-
 	/*
 	 * Now that we selected the NI to use increment its sequence
 	 * number so the Round Robin algorithm will detect that it has
@@ -1674,7 +1704,8 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
 		 * the router receives this message it knows how to route
 		 * it.
 		 */
-		msg->msg_hdr.dest_nid = cpu_to_le64(dst_nid);
+		msg->msg_hdr.dest_nid =
+			cpu_to_le64(final_dst ? final_dst->lpni_nid : dst_nid);
 	} else {
 		/*
 		 * if we're not routing set the dest_nid to the best peer
