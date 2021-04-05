Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 086D8C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5C7576138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C7576138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DBBA021FAF1;
	Mon,  5 Apr 2021 00:51:24 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 896E821F543
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:20 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A7DE86C8;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A4C5190AAC; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:38 -0400
Message-Id: <1617583870-32029-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/41] lnet: Preferred gateway selection
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

Add mechanism for managing preferred gateway lists.
When selecting a route through a gateway, if there exists
a preferred gateway list for the destination peer, then choose
the preferred gateway. If there are multiple preferred
gateways, to make the selection, use in order of decreasing
importance: route priority, number of hops, number of available
tx credits on the associated lpni and route sequence counters.
If there are no preferred routes, select the best route
available using the same criteria.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 66acff74d0da31e ("LU-9121 lnet: Preferred gateway selection")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34353
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |   5 ++
 net/lnet/lnet/lib-move.c      | 119 ++++++++++++++++++++++++++++++------------
 net/lnet/lnet/peer.c          | 111 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 201 insertions(+), 34 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 927ca44..90f18a0 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -806,6 +806,11 @@ struct lnet_peer_ni *lnet_peer_get_ni_locked(struct lnet_peer *lp,
 struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 					       u32 net_id);
 bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+int lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
+void lnet_peer_clr_pref_nids(struct lnet_peer_ni *lpni);
+bool lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni, lnet_nid_t gw_nid);
+void lnet_peer_clr_pref_rtrs(struct lnet_peer_ni *lpni);
+int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 4687acd..8763c3f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1097,24 +1097,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 }
 
-static int
-lnet_compare_gw_lpnis(struct lnet_peer_ni *p1, struct lnet_peer_ni *p2)
-{
-	if (p1->lpni_txqnob < p2->lpni_txqnob)
-		return 1;
-
-	if (p1->lpni_txqnob > p2->lpni_txqnob)
-		return -1;
-
-	if (p1->lpni_txcredits > p2->lpni_txcredits)
-		return 1;
-
-	if (p1->lpni_txcredits < p2->lpni_txcredits)
-		return -1;
-
-	return 0;
-}
-
 static struct lnet_peer_ni *
 lnet_select_peer_ni(struct lnet_ni *best_ni, lnet_nid_t dst_nid,
 		    struct lnet_peer *peer,
@@ -1246,6 +1228,24 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	return NULL;
 }
 
+static int
+lnet_compare_gw_lpnis(struct lnet_peer_ni *lpni1, struct lnet_peer_ni *lpni2)
+{
+	if (lpni1->lpni_txqnob < lpni2->lpni_txqnob)
+		return 1;
+
+	if (lpni1->lpni_txqnob > lpni2->lpni_txqnob)
+		return -1;
+
+	if (lpni1->lpni_txcredits > lpni2->lpni_txcredits)
+		return 1;
+
+	if (lpni1->lpni_txcredits < lpni2->lpni_txcredits)
+		return -1;
+
+	return 0;
+}
+
 /* Compare route priorities and hop counts */
 static int
 lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
@@ -1270,6 +1270,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 static struct lnet_route *
 lnet_find_route_locked(struct lnet_remotenet *rnet, u32 src_net,
+		       struct lnet_peer_ni *remote_lpni,
 		       struct lnet_route **prev_route,
 		       struct lnet_peer_ni **gwni)
 {
@@ -1278,6 +1279,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_route *last_route;
 	struct lnet_route *route;
 	int rc;
+	bool best_rte_is_preferred = false;
+	lnet_nid_t gw_pnid;
 
 	CDEBUG(D_NET, "Looking up a route to %s, from %s\n",
 	       libcfs_net2str(rnet->lrn_net), libcfs_net2str(src_net));
@@ -1287,44 +1290,76 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 		if (!lnet_is_route_alive(route))
 			continue;
+		gw_pnid = route->lr_gateway->lp_primary_nid;
+
+		/* no protection on below fields, but it's harmless */
+		if (last_route && (last_route->lr_seq - route->lr_seq < 0))
+			last_route = route;
 
-		/* Restrict the selection of the router NI on the src_net
-		 * provided. If the src_net is LNET_NID_ANY, then select
-		 * the best interface available.
+		/* if the best route found is in the preferred list then
+		 * tag it as preferred and use it later on. But if we
+		 * didn't find any routes which are on the preferred list
+		 * then just use the best route possible.
 		 */
-		if (!best_route) {
+		rc = lnet_peer_is_pref_rtr_locked(remote_lpni, gw_pnid);
+
+		if (!best_route || (rc && !best_rte_is_preferred)) {
+			/* Restrict the selection of the router NI on the
+			 * src_net provided. If the src_net is LNET_NID_ANY,
+			 * then select the best interface available.
+			 */
 			lpni = lnet_find_best_lpni(NULL, LNET_NID_ANY,
 						   route->lr_gateway,
 						   src_net);
-			if (lpni) {
-				best_route = route;
-				last_route = route;
-				best_gw_ni = lpni;
-			} else {
+			if (!lpni) {
 				CDEBUG(D_NET,
 				       "Gateway %s does not have a peer NI on net %s\n",
-				       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+				       libcfs_nid2str(gw_pnid),
 				       libcfs_net2str(src_net));
+				continue;
 			}
-			continue;
 		}
 
-		/* no protection on below fields, but it's harmless */
-		if (last_route->lr_seq - route->lr_seq < 0)
+		if (rc && !best_rte_is_preferred) {
+			/* This is the first preferred route we found,
+			 * so it beats any route found previously
+			 */
+			best_route = route;
+			if (!last_route)
+				last_route = route;
+			best_gw_ni = lpni;
+			best_rte_is_preferred = true;
+			CDEBUG(D_NET, "preferred gw = %s\n",
+			       libcfs_nid2str(gw_pnid));
+			continue;
+		} else if ((!rc) && best_rte_is_preferred)
+			/* The best route we found so far is in the preferred
+			 * list, so it beats any non-preferred route
+			 */
+			continue;
+
+		if (!best_route) {
+			best_route = route;
 			last_route = route;
+			best_gw_ni = lpni;
+			continue;
+		}
 
 		rc = lnet_compare_routes(route, best_route);
 		if (rc == -1)
 			continue;
 
+		/* Restrict the selection of the router NI on the
+		 * src_net provided. If the src_net is LNET_NID_ANY,
+		 * then select the best interface available.
+		 */
 		lpni = lnet_find_best_lpni(NULL, LNET_NID_ANY,
 					   route->lr_gateway,
 					   src_net);
-		/* restrict the lpni on the src_net if specified */
 		if (!lpni) {
 			CDEBUG(D_NET,
 			       "Gateway %s does not have a peer NI on net %s\n",
-			       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+			       libcfs_nid2str(gw_pnid),
 			       libcfs_net2str(src_net));
 			continue;
 		}
@@ -1805,6 +1840,8 @@ struct lnet_ni *
 	lnet_nid_t src_nid = (sd->sd_src_nid != LNET_NID_ANY) ? sd->sd_src_nid :
 			      sd->sd_best_ni ? sd->sd_best_ni->ni_nid :
 			      LNET_NID_ANY;
+	int best_lpn_healthv = 0;
+	u32 best_lpn_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 
 	CDEBUG(D_NET, "using src nid %s for route restriction\n",
 	       libcfs_nid2str(src_nid));
@@ -1861,9 +1898,22 @@ struct lnet_ni *
 					best_rnet = rnet;
 				}
 
-				if (best_lpn->lpn_seq <= lpn->lpn_seq)
+				/* select the preferred peer net */
+				if (best_lpn_healthv > lpn->lpn_healthv)
 					continue;
+				else if (best_lpn_healthv < lpn->lpn_healthv)
+					goto use_lpn;
 
+				if (best_lpn_sel_prio < lpn->lpn_sel_priority)
+					continue;
+				else if (best_lpn_sel_prio > lpn->lpn_sel_priority)
+					goto use_lpn;
+
+				if (best_lpn->lpn_seq <= lpn->lpn_seq)
+					continue;
+use_lpn:
+				best_lpn_healthv = lpn->lpn_healthv;
+				best_lpn_sel_prio = lpn->lpn_sel_priority;
 				best_lpn = lpn;
 				best_rnet = rnet;
 			}
@@ -1905,6 +1955,7 @@ struct lnet_ni *
 		 */
 		best_route = lnet_find_route_locked(best_rnet,
 						    LNET_NIDNET(src_nid),
+						    sd->sd_best_lpni,
 						    &last_route, &gwni);
 		if (!best_route) {
 			CERROR("no route to %s from %s\n",
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 60e6b51..bbd43c8 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -894,6 +894,94 @@ struct lnet_peer_ni *
 	wake_up(&the_lnet.ln_dc_waitq);
 }
 
+/* find the NID in the preferred gateways for the remote peer
+ * return:
+ *	false: list is not empty and NID is not preferred
+ *	false: list is empty
+ *	true: nid is found in the list
+ */
+bool
+lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni,
+			     lnet_nid_t gw_nid)
+{
+	struct lnet_nid_list *ne;
+
+	CDEBUG(D_NET, "%s: rtr pref emtpy: %d\n",
+	       libcfs_nid2str(lpni->lpni_nid),
+	       list_empty(&lpni->lpni_rtr_pref_nids));
+
+	if (list_empty(&lpni->lpni_rtr_pref_nids))
+		return false;
+
+	/* iterate through all the preferred NIDs and see if any of them
+	 * matches the provided gw_nid
+	 */
+	list_for_each_entry(ne, &lpni->lpni_rtr_pref_nids, nl_list) {
+		CDEBUG(D_NET, "Comparing pref %s with gw %s\n",
+		       libcfs_nid2str(ne->nl_nid),
+		       libcfs_nid2str(gw_nid));
+		if (ne->nl_nid == gw_nid)
+			return true;
+	}
+
+	return false;
+}
+
+void
+lnet_peer_clr_pref_rtrs(struct lnet_peer_ni *lpni)
+{
+	struct list_head zombies;
+	struct lnet_nid_list *ne;
+	struct lnet_nid_list *tmp;
+	int cpt = lpni->lpni_cpt;
+
+	INIT_LIST_HEAD(&zombies);
+
+	lnet_net_lock(cpt);
+	list_splice_init(&lpni->lpni_rtr_pref_nids, &zombies);
+	lnet_net_unlock(cpt);
+
+	list_for_each_entry_safe(ne, tmp, &zombies, nl_list) {
+		list_del(&ne->nl_list);
+		kfree(ne);
+	}
+}
+
+int
+lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni,
+		       lnet_nid_t gw_nid)
+{
+	int cpt = lpni->lpni_cpt;
+	struct lnet_nid_list *ne = NULL;
+
+	/* This function is called with api_mutex held. When the api_mutex
+	 * is held the list can not be modified, as it is only modified as
+	 * a result of applying a UDSP and that happens under api_mutex
+	 * lock.
+	 */
+	__must_hold(&the_lnet.ln_api_mutex);
+
+	list_for_each_entry(ne, &lpni->lpni_rtr_pref_nids, nl_list) {
+		if (ne->nl_nid == gw_nid)
+			return -EEXIST;
+	}
+
+	ne = kzalloc_cpt(sizeof(*ne), GFP_KERNEL, cpt);
+	if (!ne)
+		return -ENOMEM;
+
+	ne->nl_nid = gw_nid;
+
+	/* Lock the cpt to protect against addition and checks in the
+	 * selection algorithm
+	 */
+	lnet_net_lock(cpt);
+	list_add(&ne->nl_list, &lpni->lpni_rtr_pref_nids);
+	lnet_net_unlock(cpt);
+
+	return 0;
+}
+
 /*
  * Test whether a ni is a preferred ni for this peer_ni, e.g, whether
  * this is a preferred point-to-point path. Call with lnet_net_lock in
@@ -1123,6 +1211,29 @@ struct lnet_peer_ni *
 	return rc;
 }
 
+void
+lnet_peer_clr_pref_nids(struct lnet_peer_ni *lpni)
+{
+	struct list_head zombies;
+	struct lnet_nid_list *ne;
+	struct lnet_nid_list *tmp;
+
+	INIT_LIST_HEAD(&zombies);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	if (lpni->lpni_pref_nnids == 1)
+		lpni->lpni_pref.nid = LNET_NID_ANY;
+	else if (lpni->lpni_pref_nnids > 1)
+		list_splice_init(&lpni->lpni_pref.nids, &zombies);
+	lpni->lpni_pref_nnids = 0;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	list_for_each_entry_safe(ne, tmp, &zombies, nl_list) {
+		list_del_init(&ne->nl_list);
+		kfree(ne);
+	}
+}
+
 lnet_nid_t
 lnet_peer_primary_nid_locked(lnet_nid_t nid)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
