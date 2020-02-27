From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:42 -0500
Subject: [lustre-devel] [PATCH 354/622] lnet: discover each gateway Net
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-355-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Wakeup every gateway aliveness interval / number of local networks.
Discover each local gateway network in round robin.

This is done to make sure the gateway keeps its networks up.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11299
Lustre-commit: 526679c681c3 ("LU-11299 lnet: discover each gateway Net")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34511
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  5 ++++
 include/linux/lnet/lib-types.h |  9 ++++---
 net/lnet/lnet/api-ni.c         | 39 +++++++++++++++++++++++++++---
 net/lnet/lnet/lib-move.c       | 19 ++++++++++++---
 net/lnet/lnet/peer.c           | 32 ++++++++++++++++++++++++
 net/lnet/lnet/router.c         | 55 ++++++++++++++++++++++++++++++++++++++----
 6 files changed, 145 insertions(+), 14 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 36aaaa5..3dd56a2 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -53,6 +53,7 @@
 #define CFS_FAIL_PTLRPC_OST_BULK_CB2	0xe000
 
 extern struct lnet the_lnet;	/* THE network */
+extern unsigned int lnet_current_net_count;
 
 #if (BITS_PER_LONG == 32)
 /* 2 CPTs, allowing more CPTs might make us under memory pressure */
@@ -547,6 +548,7 @@ void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
 
 int lnet_islocalnid(lnet_nid_t nid);
 int lnet_islocalnet(u32 net);
+int lnet_islocalnet_locked(u32 net);
 
 void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 			unsigned int offset, unsigned int mlen);
@@ -796,7 +798,10 @@ bool lnet_net_unique(u32 net_id, struct list_head *nilist,
 bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
 void lnet_incr_dlc_seq(void);
 u32 lnet_get_dlc_seq_locked(void);
+int lnet_get_net_count(void);
 
+struct lnet_peer_net *lnet_get_next_peer_net_locked(struct lnet_peer *lp,
+						    u32 prev_lpn_id);
 struct lnet_peer_ni *lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 						  struct lnet_peer_net *peer_net,
 						  struct lnet_peer_ni *prev);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 7b43236..8c9ae9e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -600,6 +600,9 @@ struct lnet_peer {
 	/* primary NID of the peer */
 	lnet_nid_t		lp_primary_nid;
 
+	/* net to perform discovery on */
+	u32			lp_disc_net_id;
+
 	/* CPT of peer_table */
 	int			lp_cpt;
 
@@ -621,9 +624,6 @@ struct lnet_peer {
 	/* routes on this peer */
 	struct list_head	lp_routes;
 
-	/* time of last router check attempt */
-	time64_t		lp_rtrcheck_timestamp;
-
 	/* reference count */
 	atomic_t		lp_refcount;
 
@@ -744,6 +744,9 @@ struct lnet_peer_net {
 	/* Net ID */
 	u32			lpn_net_id;
 
+	/* time of last router net check attempt */
+	time64_t		lpn_rtrcheck_timestamp;
+
 	/* reference count */
 	atomic_t		lpn_refcount;
 };
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 702e4b9..65f1f17 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -171,6 +171,7 @@ static int recovery_interval_set(const char *val,
 		 "Maximum number of times to retry transmitting a message");
 
 unsigned int lnet_lnd_timeout = LNET_LND_DEFAULT_TIMEOUT;
+unsigned int lnet_current_net_count;
 
 /*
  * This sequence number keeps track of how many times DLC was used to
@@ -1294,16 +1295,28 @@ struct lnet_net *
 EXPORT_SYMBOL(lnet_cpt_of_nid);
 
 int
-lnet_islocalnet(u32 net_id)
+lnet_islocalnet_locked(u32 net_id)
 {
 	struct lnet_net *net;
+
+	net = lnet_get_net_locked(net_id);
+
+	return !!net;
+}
+
+int
+lnet_islocalnet(u32 net_id)
+{
 	int cpt;
+	bool local;
 
 	cpt = lnet_net_lock_current();
-	net = lnet_get_net_locked(net_id);
+
+	local = lnet_islocalnet_locked(net_id);
+
 	lnet_net_unlock(cpt);
 
-	return !!net;
+	return local;
 }
 
 struct lnet_ni *
@@ -1457,6 +1470,23 @@ struct lnet_ping_buffer *
 	return count;
 }
 
+int
+lnet_get_net_count(void)
+{
+	struct lnet_net *net;
+	int count = 0;
+
+	lnet_net_lock(0);
+
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		count++;
+	}
+
+	lnet_net_unlock(0);
+
+	return count;
+}
+
 void
 lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
 {
@@ -2292,6 +2322,9 @@ static void lnet_push_target_fini(void)
 		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
+	/* update net count */
+	lnet_current_net_count = lnet_get_net_count();
+
 	return ni_count;
 
 failed1:
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index ec32d22..e93284b 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1922,7 +1922,8 @@ struct lnet_ni *
 }
 
 struct lnet_ni *
-lnet_find_best_ni_on_local_net(struct lnet_peer *peer, int md_cpt)
+lnet_find_best_ni_on_local_net(struct lnet_peer *peer, int md_cpt,
+			       bool discovery)
 {
 	struct lnet_peer_net *peer_net = NULL;
 	struct lnet_ni *best_ni = NULL;
@@ -1943,6 +1944,12 @@ struct lnet_ni *
 		best_ni = lnet_find_best_ni_on_spec_net(best_ni, peer,
 							peer_net, md_cpt,
 							false);
+		/* if this is a discovery message and lp_disc_net_id is
+		 * specified then use that net to send the discovery on.
+		 */
+		if (peer->lp_disc_net_id == peer_net->lpn_net_id &&
+		    discovery)
+			break;
 	}
 
 	if (best_ni)
@@ -2101,7 +2108,8 @@ struct lnet_ni *
 	 * networks.
 	 */
 	sd->sd_best_ni = lnet_find_best_ni_on_local_net(sd->sd_peer,
-							sd->sd_md_cpt);
+					sd->sd_md_cpt,
+					lnet_msg_discovery(sd->sd_msg));
 	if (sd->sd_best_ni) {
 		sd->sd_best_lpni =
 		  lnet_find_best_lpni_on_net(sd, sd->sd_peer,
@@ -3145,9 +3153,14 @@ struct lnet_mt_event_info {
 		 * if we wake up every 1 second? Although, we've seen
 		 * cases where we get a complaint that an idle thread
 		 * is waking up unnecessarily.
+		 *
+		 * Take into account the current net_count when you wake
+		 * up for alive router checking, since we need to check
+		 * possibly as many networks as we have configured.
 		 */
 		interval = min(lnet_recovery_interval,
-			       min((unsigned int)alive_router_check_interval,
+			       min((unsigned int)alive_router_check_interval /
+					lnet_current_net_count,
 				   lnet_transaction_timeout / 2));
 		wait_event_interruptible_timeout(the_lnet.ln_mt_waitq,
 						 false, HZ * interval);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 294f968..55ff01d 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -710,6 +710,38 @@ struct lnet_peer *
 	return lp;
 }
 
+struct lnet_peer_net *
+lnet_get_next_peer_net_locked(struct lnet_peer *lp, u32 prev_lpn_id)
+{
+	struct lnet_peer_net *net;
+
+	if (!prev_lpn_id) {
+		/* no net id provided return the first net */
+		net = list_first_entry_or_null(&lp->lp_peer_nets,
+					       struct lnet_peer_net,
+					       lpn_peer_nets);
+
+		return net;
+	}
+
+	/* find the net after the one provided */
+	list_for_each_entry(net, &lp->lp_peer_nets, lpn_peer_nets) {
+		if (net->lpn_net_id == prev_lpn_id) {
+			/* if we reached the end of the list loop to the
+			 * beginning.
+			 */
+			if (net->lpn_peer_nets.next == &lp->lp_peer_nets)
+				return list_first_entry_or_null(&lp->lp_peer_nets,
+								struct lnet_peer_net,
+								lpn_peer_nets);
+			else
+				return list_next_entry(net, lpn_peer_nets);
+		}
+	}
+
+	return NULL;
+}
+
 struct lnet_peer_ni *
 lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
 			     struct lnet_peer_net *peer_net,
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 4ca3c5c..81f7a94 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -370,8 +370,9 @@ static void lnet_shuffle_seed(void)
 static void
 lnet_add_route_to_rnet(struct lnet_remotenet *rnet, struct lnet_route *route)
 {
-	unsigned int len = 0;
+	struct lnet_peer_net *lpn;
 	unsigned int offset = 0;
+	unsigned int len = 0;
 	struct list_head *e;
 
 	lnet_shuffle_seed();
@@ -393,7 +394,10 @@ static void lnet_shuffle_seed(void)
 	/* force a router check on the gateway to make sure the route is
 	 * alive
 	 */
-	route->lr_gateway->lp_rtrcheck_timestamp = 0;
+	list_for_each_entry(lpn, &route->lr_gateway->lp_peer_nets,
+			    lpn_peer_nets) {
+		lpn->lpn_rtrcheck_timestamp = 0;
+	}
 
 	the_lnet.ln_remote_nets_version++;
 
@@ -618,6 +622,17 @@ static void lnet_shuffle_seed(void)
 	}
 
 delete_zombies:
+	/* check if there are any routes remaining on the gateway
+	 * If there are no more routes make sure to set the peer's
+	 * lp_disc_net_id to 0 (invalid), in case we add more routes in
+	 * the future on that gateway, then we start our discovery process
+	 * from scratch
+	 */
+	if (lpni) {
+		if (list_empty(&lp->lp_routes))
+			lp->lp_disc_net_id = 0;
+	}
+
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	while (!list_empty(&zombies)) {
@@ -831,10 +846,14 @@ bool lnet_router_checker_active(void)
 void
 lnet_check_routers(void)
 {
+	struct lnet_peer_net *first_lpn = NULL;
+	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *rtr;
 	bool push = false;
+	bool found_lpn;
 	u64 version;
+	u32 net_id;
 	time64_t now;
 	int cpt;
 	int rc;
@@ -851,8 +870,31 @@ bool lnet_router_checker_active(void)
 		 * interfaces could be down and in that case they would be
 		 * undergoing recovery separately from this discovery.
 		 */
-		if (now - rtr->lp_rtrcheck_timestamp <
-		    alive_router_check_interval)
+		/* find next peer net which is also local */
+		net_id = rtr->lp_disc_net_id;
+		do {
+			lpn = lnet_get_next_peer_net_locked(rtr, net_id);
+			if (!lpn) {
+				CERROR("gateway %s has no networks\n",
+				       libcfs_nid2str(rtr->lp_primary_nid));
+				break;
+			}
+			if (first_lpn == lpn)
+				break;
+			if (!first_lpn)
+				first_lpn = lpn;
+			found_lpn = lnet_islocalnet_locked(lpn->lpn_net_id);
+			net_id = lpn->lpn_net_id;
+		} while (!found_lpn);
+
+		if (!found_lpn || !lpn) {
+			CERROR("no local network found for gateway %s\n",
+			       libcfs_nid2str(rtr->lp_primary_nid));
+			continue;
+		}
+
+		if (now - lpn->lpn_rtrcheck_timestamp <
+		    alive_router_check_interval / lnet_current_net_count)
 			continue;
 
 		/* If we're currently discovering the peer then don't
@@ -878,6 +920,9 @@ bool lnet_router_checker_active(void)
 		}
 		lnet_peer_ni_addref_locked(lpni);
 
+		/* specify the net to use */
+		rtr->lp_disc_net_id = lpn->lpn_net_id;
+
 		/* discover the router */
 		CDEBUG(D_NET, "discover %s, cpt = %d\n",
 		       libcfs_nid2str(lpni->lpni_nid), cpt);
@@ -887,7 +932,7 @@ bool lnet_router_checker_active(void)
 		lnet_peer_ni_decref_locked(lpni);
 
 		if (!rc)
-			rtr->lp_rtrcheck_timestamp = now;
+			lpn->lpn_rtrcheck_timestamp = now;
 		else
 			CERROR("Failed to discover router %s\n",
 			       libcfs_nid2str(rtr->lp_primary_nid));
-- 
1.8.3.1
