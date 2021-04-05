Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0926C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B629361396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B629361396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D3EEE328AE8;
	Mon,  5 Apr 2021 00:51:44 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 29E5421F6DE
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:21 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B07DD6CC;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AC80A90AB2; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:40 -0400
Message-Id: <1617583870-32029-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/41] lnet: select best peer and local net
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

Select the healthiest and highest priority peer and local net when
sending a message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 7d309d57fd843f1 ("LU-9121 lnet: select best peer and local net")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34352
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |   2 +
 include/linux/lnet/lib-types.h |   3 +
 net/lnet/lnet/api-ni.c         |  15 +++++
 net/lnet/lnet/lib-move.c       | 125 +++++++++++++++++++++++++++++++----------
 4 files changed, 116 insertions(+), 29 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 90f18a0..5152c0a70 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -507,6 +507,8 @@ int lnet_get_route(int idx, u32 *net, u32 *hops,
 struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
 					struct lnet_ni *prev);
 struct lnet_ni *lnet_get_ni_idx_locked(int idx);
+int lnet_get_net_healthv_locked(struct lnet_net *net);
+
 int lnet_get_peer_list(u32 *countp, u32 *sizep,
 		       struct lnet_process_id __user *ids);
 extern void lnet_peer_ni_set_healthv(lnet_nid_t nid, int value, bool all);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 187e1f3..f1f4eac5 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -359,6 +359,9 @@ struct lnet_net {
 	 * lnet/include/lnet/nidstr.h */
 	u32			net_id;
 
+	/* round robin selection */
+	u32			net_seq;
+
 	/* total number of CPTs in the array */
 	u32			net_ncpts;
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 3acc86e..2c31b06 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2931,6 +2931,21 @@ struct lnet_ni *
 	return NULL;
 }
 
+int lnet_get_net_healthv_locked(struct lnet_net *net)
+{
+	struct lnet_ni *ni;
+	int best_healthv = 0;
+	int healthv;
+
+	list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+		healthv = atomic_read(&ni->ni_healthv);
+		if (healthv > best_healthv)
+			best_healthv = healthv;
+	}
+
+	return best_healthv;
+}
+
 struct lnet_ni *
 lnet_get_next_ni_locked(struct lnet_net *mynet, struct lnet_ni *prev)
 {
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 166ebcc..4dcc68a 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1602,10 +1602,25 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	u32 routing = send_case & REMOTE_DST;
 	struct lnet_rsp_tracker *rspt;
 
-	/* Increment sequence number of the selected peer so that we
-	 * pick the next one in Round Robin.
+	/* Increment sequence number of the selected peer, peer net,
+	 * local ni and local net so that we pick the next ones
+	 * in Round Robin.
 	 */
 	best_lpni->lpni_seq++;
+	best_lpni->lpni_peer_net->lpn_seq++;
+	best_ni->ni_seq++;
+	best_ni->ni_net->net_seq++;
+
+	CDEBUG(D_NET,
+	       "%s NI seq info: [%d:%d:%d:%u] %s LPNI seq info [%d:%d:%d:%u]\n",
+	       libcfs_nid2str(best_ni->ni_nid),
+	       best_ni->ni_seq, best_ni->ni_net->net_seq,
+	       atomic_read(&best_ni->ni_tx_credits),
+	       best_ni->ni_sel_priority,
+	       libcfs_nid2str(best_lpni->lpni_nid),
+	       best_lpni->lpni_seq, best_lpni->lpni_peer_net->lpn_seq,
+	       best_lpni->lpni_txcredits,
+	       best_lpni->lpni_sel_priority);
 
 	/* grab a reference on the peer_ni so it sticks around even if
 	 * we need to drop and relock the lnet_net_lock below.
@@ -1787,8 +1802,7 @@ struct lnet_ni *
 lnet_find_best_ni_on_spec_net(struct lnet_ni *cur_best_ni,
 			      struct lnet_peer *peer,
 			      struct lnet_peer_net *peer_net,
-			      int cpt,
-			      bool incr_seq)
+			      int cpt)
 {
 	struct lnet_net *local_net;
 	struct lnet_ni *best_ni;
@@ -1807,9 +1821,6 @@ struct lnet_ni *
 	best_ni = lnet_get_best_ni(local_net, cur_best_ni,
 				   peer, peer_net, cpt);
 
-	if (incr_seq && best_ni)
-		best_ni->ni_seq++;
-
 	return best_ni;
 }
 
@@ -2032,8 +2043,7 @@ struct lnet_ni *
 
 		lpeer = lnet_peer_get_net_locked(gw, local_lnet);
 		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL, gw, lpeer,
-							       sd->sd_md_cpt,
-							       true);
+							       sd->sd_md_cpt);
 	}
 
 	if (!sd->sd_best_ni) {
@@ -2115,9 +2125,19 @@ struct lnet_ni *
 lnet_find_best_ni_on_local_net(struct lnet_peer *peer, int md_cpt,
 			       bool discovery)
 {
-	struct lnet_peer_net *peer_net = NULL;
+	struct lnet_peer_net *lpn = NULL;
+	struct lnet_peer_net *best_lpn = NULL;
+	struct lnet_net *net = NULL;
+	struct lnet_net *best_net = NULL;
 	struct lnet_ni *best_ni = NULL;
-	int lpn_healthv = 0;
+	int best_lpn_healthv = 0;
+	int best_net_healthv = 0;
+	int net_healthv;
+	u32 best_lpn_sel_prio = LNET_MAX_SELECTION_PRIORITY;
+	u32 lpn_sel_prio;
+	u32 best_net_sel_prio = LNET_MAX_SELECTION_PRIORITY;
+	u32 net_sel_prio;
+	bool exit = false;
 
 	/* The peer can have multiple interfaces, some of them can be on
 	 * the local network and others on a routed network. We should
@@ -2126,32 +2146,80 @@ struct lnet_ni *
 	 */
 
 	/* go through all the peer nets and find the best_ni */
-	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
+	list_for_each_entry(lpn, &peer->lp_peer_nets, lpn_peer_nets) {
 		/* The peer's list of nets can contain non-local nets. We
 		 * want to only examine the local ones.
 		 */
-		if (!lnet_get_net_locked(peer_net->lpn_net_id))
+		net = lnet_get_net_locked(lpn->lpn_net_id);
+		if (!net)
 			continue;
 
-		/* always select the lpn with the best health */
-		if (lpn_healthv <= peer_net->lpn_healthv)
-			lpn_healthv = peer_net->lpn_healthv;
-		else
-			continue;
+		lpn_sel_prio = lpn->lpn_sel_priority;
+		net_healthv = lnet_get_net_healthv_locked(net);
+		net_sel_prio = net->net_sel_priority;
 
-		best_ni = lnet_find_best_ni_on_spec_net(best_ni, peer, peer_net,
-							md_cpt, false);
 		/* if this is a discovery message and lp_disc_net_id is
 		 * specified then use that net to send the discovery on.
 		 */
-		if (peer->lp_disc_net_id == peer_net->lpn_net_id &&
-		    discovery)
+		if (peer->lp_disc_net_id == lpn->lpn_net_id &&
+		    discovery) {
+			exit = true;
+			goto select_lpn;
+		}
+
+		if (!best_lpn)
+			goto select_lpn;
+
+		/* always select the lpn with the best health */
+		if (best_lpn_healthv > lpn->lpn_healthv)
+			continue;
+		else if (best_lpn_healthv < lpn->lpn_healthv)
+			goto select_lpn;
+
+		/* select the preferred peer and local nets */
+		if (best_lpn_sel_prio < lpn_sel_prio)
+			continue;
+		else if (best_lpn_sel_prio > lpn_sel_prio)
+			goto select_lpn;
+
+		if (best_net_healthv > net_healthv)
+			continue;
+		else if (best_net_healthv < net_healthv)
+			goto select_lpn;
+
+		if (best_net_sel_prio < net_sel_prio)
+			continue;
+		else if (best_net_sel_prio > net_sel_prio)
+			goto select_lpn;
+
+		if (best_lpn->lpn_seq < lpn->lpn_seq)
+			continue;
+		else if (best_lpn->lpn_seq > lpn->lpn_seq)
+			goto select_lpn;
+
+		/* round robin over the local networks */
+		if (best_net->net_seq <= net->net_seq)
+			continue;
+
+select_lpn:
+		best_net_healthv = net_healthv;
+		best_net_sel_prio = net_sel_prio;
+		best_lpn_healthv = lpn->lpn_healthv;
+		best_lpn_sel_prio = lpn_sel_prio;
+		best_lpn = lpn;
+		best_net = net;
+
+		if (exit)
 			break;
 	}
 
-	if (best_ni)
-		/* increment sequence number so we can round robin */
-		best_ni->ni_seq++;
+	if (best_lpn) {
+		/* Select the best NI on the same net as best_lpn chosen
+		 * above
+		 */
+		best_ni = lnet_find_best_ni_on_spec_net(NULL, peer,
+							best_lpn, md_cpt);
+	}
 
 	return best_ni;
 }
@@ -2210,7 +2278,7 @@ struct lnet_ni *
 		best_ni =
 			lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
 						      sd->sd_best_lpni->lpni_peer_net,
-						      sd->sd_md_cpt, true);
+						      sd->sd_md_cpt);
 		/* If there is no best_ni we don't have a route */
 		if (!best_ni) {
 			CERROR("no path to %s from net %s\n",
@@ -2262,8 +2330,7 @@ struct lnet_ni *
 		sd->sd_best_ni = lnet_find_best_ni_on_spec_net(NULL,
 							       sd->sd_peer,
 							       sd->sd_best_lpni->lpni_peer_net,
-							       sd->sd_md_cpt,
-							       true);
+							       sd->sd_md_cpt);
 		if (!sd->sd_best_ni) {
 			CERROR("Unable to forward message to %s. No local NI available\n",
 			       libcfs_nid2str(sd->sd_dst_nid));
@@ -2295,7 +2362,7 @@ struct lnet_ni *
 		sd->sd_best_ni =
 		  lnet_find_best_ni_on_spec_net(NULL, sd->sd_peer,
 						sd->sd_best_lpni->lpni_peer_net,
-						sd->sd_md_cpt, true);
+						sd->sd_md_cpt);
 
 		if (!sd->sd_best_ni) {
 			/* We're not going to deal with not able to send
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
