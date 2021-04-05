Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88587C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 42E8D6138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42E8D6138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D53A7327F9F;
	Mon,  5 Apr 2021 00:51:34 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D279A21F688
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:20 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id AB0E96CA;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A8C1090AAE; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:39 -0400
Message-Id: <1617583870-32029-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/41] lnet: Select NI/peer NI with highest
 prio
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

Modify the selection algorithm to select the highest priority
local and peer NI. Health always trumps all other selection
criteria

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 374fcb2caea3ca0 ("LU-9121 lnet: Select NI/peer NI with highest prio")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34351
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 148 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 95 insertions(+), 53 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 8763c3f..166ebcc 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1112,65 +1112,91 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 */
 	struct lnet_peer_ni *lpni = NULL;
 	int best_lpni_credits =  (best_lpni) ? best_lpni->lpni_txcredits :
-					       INT_MIN;
+				 INT_MIN;
 	int best_lpni_healthv = (best_lpni) ?
 				atomic_read(&best_lpni->lpni_healthv) : 0;
-	bool preferred = false;
-	bool ni_is_pref;
+	bool best_lpni_is_preferred = false;
+	bool lpni_is_preferred;
 	int lpni_healthv;
+	u32 lpni_sel_prio;
+	u32 best_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 
 	while ((lpni = lnet_get_next_peer_ni_locked(peer, peer_net, lpni))) {
 		/* if the best_ni we've chosen aleady has this lpni
 		 * preferred, then let's use it
 		 */
 		if (best_ni) {
-			ni_is_pref = lnet_peer_is_pref_nid_locked(lpni,
-								  best_ni->ni_nid);
-			CDEBUG(D_NET, "%s ni_is_pref = %d\n",
-			       libcfs_nid2str(best_ni->ni_nid), ni_is_pref);
+			lpni_is_preferred = lnet_peer_is_pref_nid_locked(lpni,
+									 best_ni->ni_nid);
+			CDEBUG(D_NET, "%s lpni_is_preferred = %d\n",
+			       libcfs_nid2str(best_ni->ni_nid),
+			       lpni_is_preferred);
 		} else {
-			ni_is_pref = false;
+			lpni_is_preferred = false;
 		}
 
 		lpni_healthv = atomic_read(&lpni->lpni_healthv);
+		lpni_sel_prio = lpni->lpni_sel_priority;
 
 		if (best_lpni)
-			CDEBUG(D_NET, "%s c:[%d, %d], s:[%d, %d]\n",
+			CDEBUG(D_NET,
+			       "n:[%s, %s] h:[%d, %d] p:[%d, %d] c:[%d, %d] s:[%d, %d]\n",
 			       libcfs_nid2str(lpni->lpni_nid),
+			       libcfs_nid2str(best_lpni->lpni_nid),
+			       lpni_healthv, best_lpni_healthv,
+			       lpni_sel_prio, best_sel_prio,
 			       lpni->lpni_txcredits, best_lpni_credits,
 			       lpni->lpni_seq, best_lpni->lpni_seq);
+		else
+			goto select_lpni;
 
 		/* pick the healthiest peer ni */
 		if (lpni_healthv < best_lpni_healthv) {
 			continue;
 		} else if (lpni_healthv > best_lpni_healthv) {
-			best_lpni_healthv = lpni_healthv;
+			if (best_lpni_is_preferred)
+				best_lpni_is_preferred = false;
+			goto select_lpni;
+		}
+
+		if (lpni_sel_prio > best_sel_prio) {
+			continue;
+		} else if (lpni_sel_prio < best_sel_prio) {
+			if (best_lpni_is_preferred)
+				best_lpni_is_preferred = false;
+			goto select_lpni;
+		}
+
 		/* if this is a preferred peer use it */
-		} else if (!preferred && ni_is_pref) {
-			preferred = true;
-		} else if (preferred && !ni_is_pref) {
+		if (!best_lpni_is_preferred && lpni_is_preferred) {
+			best_lpni_is_preferred = true;
+			goto select_lpni;
+		} else if (best_lpni_is_preferred && !lpni_is_preferred) {
 			/* this is not the preferred peer so let's ignore
 			 * it.
 			 */
 			continue;
-		} else if (lpni->lpni_txcredits < best_lpni_credits) {
+		}
+
+		if (lpni->lpni_txcredits < best_lpni_credits)
 			/* We already have a peer that has more credits
 			 * available than this one. No need to consider
 			 * this peer further.
 			 */
 			continue;
-		} else if (lpni->lpni_txcredits == best_lpni_credits) {
-			/* The best peer found so far and the current peer
-			 * have the same number of available credits let's
-			 * make sure to select between them using Round
-			 * Robin
-			 */
-			if (best_lpni) {
-				if (best_lpni->lpni_seq <= lpni->lpni_seq)
-					continue;
-			}
-		}
+		else if (lpni->lpni_txcredits > best_lpni_credits)
+			goto select_lpni;
 
+		/* The best peer found so far and the current peer
+		 * have the same number of available credits let's
+		 * make sure to select between them using Round Robin
+		 */
+		if (best_lpni && best_lpni->lpni_seq <= lpni->lpni_seq)
+			continue;
+select_lpni:
+		best_lpni_is_preferred = lpni_is_preferred;
+		best_lpni_healthv = lpni_healthv;
+		best_sel_prio = lpni_sel_prio;
 		best_lpni = lpni;
 		best_lpni_credits = lpni->lpni_txcredits;
 	}
@@ -1178,7 +1204,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	/* if we still can't find a peer ni then we can't reach it */
 	if (!best_lpni) {
 		u32 net_id = (peer_net) ? peer_net->lpn_net_id :
-			LNET_NIDNET(dst_nid);
+			     LNET_NIDNET(dst_nid);
 		CDEBUG(D_NET, "no peer_ni found on peer net %s\n",
 		       libcfs_net2str(net_id));
 		return NULL;
@@ -1396,6 +1422,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	unsigned int shortest_distance;
 	int best_credits;
 	int best_healthv;
+	u32 best_sel_prio;
 
 	/* If there is no peer_ni that we can send to on this network,
 	 * then there is no point in looking for a new best_ni here.
@@ -1404,6 +1431,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		return best_ni;
 
 	if (!best_ni) {
+		best_sel_prio = LNET_MAX_SELECTION_PRIORITY;
 		shortest_distance = UINT_MAX;
 		best_credits = INT_MIN;
 		best_healthv = 0;
@@ -1412,6 +1440,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 						     best_ni->ni_dev_cpt);
 		best_credits = atomic_read(&best_ni->ni_tx_credits);
 		best_healthv = atomic_read(&best_ni->ni_healthv);
+		best_sel_prio = best_ni->ni_sel_priority;
 	}
 
 	while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
@@ -1419,10 +1448,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		int ni_credits;
 		int ni_healthv;
 		int ni_fatal;
+		u32 ni_sel_prio;
 
 		ni_credits = atomic_read(&ni->ni_tx_credits);
 		ni_healthv = atomic_read(&ni->ni_healthv);
 		ni_fatal = atomic_read(&ni->ni_fatal_error_on);
+		ni_sel_prio = ni->ni_sel_priority;
 
 		/*
 		 * calculate the distance from the CPT on which
@@ -1433,13 +1464,6 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 					    md_cpt,
 					    ni->ni_dev_cpt);
 
-		CDEBUG(D_NET,
-		       "compare ni %s [c:%d, d:%d, s:%d] with best_ni %s [c:%d, d:%d, s:%d]\n",
-		       libcfs_nid2str(ni->ni_nid), ni_credits, distance,
-		       ni->ni_seq, (best_ni) ? libcfs_nid2str(best_ni->ni_nid)
-			: "not seleced", best_credits, shortest_distance,
-			(best_ni) ? best_ni->ni_seq : 0);
-
 		/*
 		 * All distances smaller than the NUMA range
 		 * are treated equally.
@@ -1451,30 +1475,48 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * Select on health, shorter distance, available
 		 * credits, then round-robin.
 		 */
-		if (ni_fatal) {
+		if (ni_fatal)
 			continue;
-		} else if (ni_healthv < best_healthv) {
+
+		if (best_ni)
+			CDEBUG(D_NET,
+			       "compare ni %s [c:%d, d:%d, s:%d, p:%u] with best_ni %s [c:%d, d:%d, s:%d, p:%u]\n",
+			       libcfs_nid2str(ni->ni_nid), ni_credits, distance,
+			       ni->ni_seq, ni_sel_prio,
+			       (best_ni) ? libcfs_nid2str(best_ni->ni_nid)
+			       : "not selected", best_credits, shortest_distance,
+			       (best_ni) ? best_ni->ni_seq : 0,
+			       best_sel_prio);
+		else
+			goto select_ni;
+
+		if (ni_healthv < best_healthv)
 			continue;
-		} else if (ni_healthv > best_healthv) {
-			best_healthv = ni_healthv;
-			/* If we're going to prefer this ni because it's
-			 * the healthiest, then we should set the
-			 * shortest_distance in the algorithm in case
-			 * there are multiple NIs with the same health but
-			 * different distances.
-			 */
-			if (distance < shortest_distance)
-				shortest_distance = distance;
-		} else if (distance > shortest_distance) {
+		else if (ni_healthv > best_healthv)
+			goto select_ni;
+
+		if (ni_sel_prio > best_sel_prio)
 			continue;
-		} else if (distance < shortest_distance) {
-			shortest_distance = distance;
-		} else if (ni_credits < best_credits) {
+		else if (ni_sel_prio < best_sel_prio)
+			goto select_ni;
+
+		if (distance > shortest_distance)
 			continue;
-		} else if (ni_credits == best_credits) {
-			if (best_ni && best_ni->ni_seq <= ni->ni_seq)
-				continue;
-		}
+		else if (distance < shortest_distance)
+			goto select_ni;
+
+		if (ni_credits < best_credits)
+			continue;
+		else if (ni_credits > best_credits)
+			goto select_ni;
+
+		if (best_ni && best_ni->ni_seq <= ni->ni_seq)
+			continue;
+
+select_ni:
+		best_sel_prio = ni_sel_prio;
+		shortest_distance = distance;
+		best_healthv = ni_healthv;
 		best_ni = ni;
 		best_credits = ni_credits;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
