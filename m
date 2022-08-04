Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5BC86C19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:15 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrxG6bnxz23HT;
	Wed,  3 Aug 2022 18:39:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwW6ZcTz23JV
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:35 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CA9C7100B004;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C7CE282CCE; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:59 -0400
Message-Id: <1659577097-19253-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/32] lnet: Ensure round robin across nets
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Introduce a global net sequence number and a peer sequence number.
These sequence numbers are used to ensure round robin selection of
local NIs and peer NIs across nets.

Also consolidate the sequence number accounting under
lnet_handle_send(). Previously the sequence number increment for
the final destination peer net/peer NI on a routed send was done
in lnet_handle_find_routed_path().

Some cleanup that is also in this patch:
 - Redundant check of null src_nid is removed from
   lnet_handle_find_routed_path() (LNET_NID_IS_ANY handles null arg)
 - Avoid comparing best_lpn with itself in
   lnet_handle_find_routed_path() on the first loop iteration
 - In lnet_find_best_ni_on_local_net() check whether we have
   a specified lp_disc_net_id outside of the loop to avoid doing
   that work on each loop iteration.

Added some debug statements to print information used when selecting
peer net/local net.

HPE-bug-id: LUS-10871
WC-bug-id: https://jira.whamcloud.com/browse/LU-15713
Lustre-commit: 05413b3d84f7d1feb ("LU-15713 lnet: Ensure round robin across nets")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46976
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 11 ++++-
 net/lnet/lnet/lib-move.c       | 96 +++++++++++++++++++++++++++---------------
 2 files changed, 72 insertions(+), 35 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1827f4e..09b9d8e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -765,6 +765,11 @@ struct lnet_peer {
 
 	/* cached peer aliveness */
 	bool			lp_alive;
+
+	/* sequence number used to round robin traffic to this peer's
+	 * nets/NIs
+	 */
+	u32			lp_send_seq;
 };
 
 /*
@@ -1205,10 +1210,12 @@ struct lnet {
 
 	/* LND instances */
 	struct list_head		ln_nets;
-	/* network zombie list */
-	struct list_head		ln_net_zombie;
+	/* Sequence number used to round robin sends across all nets */
+	u32				ln_net_seq;
 	/* the loopback NI */
 	struct lnet_ni		       *ln_loni;
+	/* network zombie list */
+	struct list_head		ln_net_zombie;
 	/* resend messages list */
 	struct list_head		ln_msg_resend;
 	/* spin lock to protect the msg resend list */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index a514472..6ad0963 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1658,9 +1658,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * local ni and local net so that we pick the next ones
 	 * in Round Robin.
 	 */
-	best_lpni->lpni_peer_net->lpn_seq++;
+	best_lpni->lpni_peer_net->lpn_peer->lp_send_seq++;
+	best_lpni->lpni_peer_net->lpn_seq =
+		best_lpni->lpni_peer_net->lpn_peer->lp_send_seq;
 	best_lpni->lpni_seq = best_lpni->lpni_peer_net->lpn_seq;
-	best_ni->ni_net->net_seq++;
+	the_lnet.ln_net_seq++;
+	best_ni->ni_net->net_seq = the_lnet.ln_net_seq;
 	best_ni->ni_seq = best_ni->ni_net->net_seq;
 
 	CDEBUG(D_NET,
@@ -1743,6 +1746,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * lnet_select_pathway() function and is never changed.
 		 * It's safe to use it here.
 		 */
+		final_dst_lpni->lpni_peer_net->lpn_peer->lp_send_seq++;
+		final_dst_lpni->lpni_peer_net->lpn_seq =
+			final_dst_lpni->lpni_peer_net->lpn_peer->lp_send_seq;
+		final_dst_lpni->lpni_seq =
+			final_dst_lpni->lpni_peer_net->lpn_seq;
 		msg->msg_hdr.dest_nid = final_dst_lpni->lpni_nid;
 	} else {
 		/* if we're not routing set the dest_nid to the best peer
@@ -1968,8 +1976,10 @@ struct lnet_ni *
 	int best_lpn_healthv = 0;
 	u32 best_lpn_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 
-	CDEBUG(D_NET, "using src nid %s for route restriction\n",
-	       src_nid ? libcfs_nidstr(src_nid) : "ANY");
+	CDEBUG(D_NET, "%s route (%s) from local NI %s to destination %s\n",
+	       LNET_NID_IS_ANY(&sd->sd_rtr_nid) ? "Lookup" : "Specified",
+	       libcfs_nidstr(&sd->sd_rtr_nid), libcfs_nidstr(src_nid),
+	       libcfs_nidstr(&sd->sd_dst_nid));
 
 	/* If a router nid was specified then we are replying to a GET or
 	 * sending an ACK. In this case we use the gateway associated with the
@@ -1989,8 +1999,7 @@ struct lnet_ni *
 	}
 
 	if (!route_found) {
-		if (sd->sd_msg->msg_routing ||
-		    (src_nid && !LNET_NID_IS_ANY(src_nid))) {
+		if (sd->sd_msg->msg_routing || !LNET_NID_IS_ANY(src_nid)) {
 			/* If I'm routing this message then I need to find the
 			 * next hop based on the destination NID
 			 *
@@ -2006,6 +2015,8 @@ struct lnet_ni *
 				       libcfs_nidstr(&sd->sd_dst_nid));
 				return -EHOSTUNREACH;
 			}
+			CDEBUG(D_NET, "best_rnet %s\n",
+			       libcfs_net2str(best_rnet->lrn_net));
 		} else {
 			/* we've already looked up the initial lpni using
 			 * dst_nid
@@ -2023,10 +2034,18 @@ struct lnet_ni *
 				if (!rnet)
 					continue;
 
-				if (!best_lpn) {
-					best_lpn = lpn;
-					best_rnet = rnet;
-				}
+				if (!best_lpn)
+					goto use_lpn;
+				else
+					CDEBUG(D_NET, "n[%s, %s] h[%d, %d], p[%u, %u], s[%d, %d]\n",
+					       libcfs_net2str(lpn->lpn_net_id),
+					       libcfs_net2str(best_lpn->lpn_net_id),
+					       lpn->lpn_healthv,
+					       best_lpn->lpn_healthv,
+					       lpn->lpn_sel_priority,
+					       best_lpn->lpn_sel_priority,
+					       lpn->lpn_seq,
+					       best_lpn->lpn_seq);
 
 				/* select the preferred peer net */
 				if (best_lpn_healthv > lpn->lpn_healthv)
@@ -2054,6 +2073,9 @@ struct lnet_ni *
 				return -EHOSTUNREACH;
 			}
 
+			CDEBUG(D_NET, "selected best_lpn %s\n",
+			       libcfs_net2str(best_lpn->lpn_net_id));
+
 			sd->sd_best_lpni = lnet_find_best_lpni(sd->sd_best_ni,
 							       lnet_nid_to_nid4(&sd->sd_dst_nid),
 							       lp,
@@ -2068,12 +2090,6 @@ struct lnet_ni *
 			 * NI's so update the final destination we selected
 			 */
 			sd->sd_final_dst_lpni = sd->sd_best_lpni;
-
-			/* Increment the sequence number of the remote lpni so
-			 * we can round robin over the different interfaces of
-			 * the remote lpni
-			 */
-			sd->sd_best_lpni->lpni_seq++;
 		}
 
 		/* find the best route. Restrict the selection on the net of the
@@ -2139,14 +2155,12 @@ struct lnet_ni *
 	*gw_lpni = gwni;
 	*gw_peer = gw;
 
-	/* increment the sequence numbers since now we're sure we're
-	 * going to use this path
+	/* increment the sequence number since now we're sure we're
+	 * going to use this route
 	 */
 	if (LNET_NID_IS_ANY(&sd->sd_rtr_nid)) {
 		LASSERT(best_route && last_route);
 		best_route->lr_seq = last_route->lr_seq + 1;
-		if (best_lpn)
-			best_lpn->lpn_seq++;
 	}
 
 	return 0;
@@ -2220,7 +2234,15 @@ struct lnet_ni *
 	u32 lpn_sel_prio;
 	u32 best_net_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 	u32 net_sel_prio;
-	bool exit = false;
+
+	/* if this is a discovery message and lp_disc_net_id is
+	 * specified then use that net to send the discovery on.
+	 */
+	if (discovery && peer->lp_disc_net_id) {
+		best_lpn = lnet_peer_get_net_locked(peer, peer->lp_disc_net_id);
+		if (best_lpn && lnet_get_net_locked(best_lpn->lpn_net_id))
+			goto select_best_ni;
+	}
 
 	/* The peer can have multiple interfaces, some of them can be on
 	 * the local network and others on a routed network. We should
@@ -2241,17 +2263,25 @@ struct lnet_ni *
 		net_healthv = lnet_get_net_healthv_locked(net);
 		net_sel_prio = net->net_sel_priority;
 
-		/* if this is a discovery message and lp_disc_net_id is
-		 * specified then use that net to send the discovery on.
-		 */
-		if (peer->lp_disc_net_id == lpn->lpn_net_id &&
-		    discovery) {
-			exit = true;
-			goto select_lpn;
-		}
-
 		if (!best_lpn)
 			goto select_lpn;
+		else
+			CDEBUG(D_NET,
+			       "n[%s, %s] ph[%d, %d], pp[%u, %u], nh[%d, %d], np[%u, %u], ps[%u, %u], ns[%u, %u]\n",
+			       libcfs_net2str(lpn->lpn_net_id),
+			       libcfs_net2str(best_lpn->lpn_net_id),
+			       lpn->lpn_healthv,
+			       best_lpn_healthv,
+			       lpn_sel_prio,
+			       best_lpn_sel_prio,
+			       net_healthv,
+			       best_net_healthv,
+			       net_sel_prio,
+			       best_net_sel_prio,
+			       lpn->lpn_seq,
+			       best_lpn->lpn_seq,
+			       net->net_seq,
+			       best_net->net_seq);
 
 		/* always select the lpn with the best health */
 		if (best_lpn_healthv > lpn->lpn_healthv)
@@ -2291,15 +2321,15 @@ struct lnet_ni *
 		best_lpn_sel_prio = lpn_sel_prio;
 		best_lpn = lpn;
 		best_net = net;
-
-		if (exit)
-			break;
 	}
 
 	if (best_lpn) {
 		/* Select the best NI on the same net as best_lpn chosen
 		 * above
 		 */
+select_best_ni:
+		CDEBUG(D_NET, "selected best_lpn %s\n",
+		       libcfs_net2str(best_lpn->lpn_net_id));
 		best_ni = lnet_find_best_ni_on_spec_net(NULL, peer, best_lpn,
 							msg, md_cpt);
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
