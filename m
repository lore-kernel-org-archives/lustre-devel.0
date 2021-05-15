Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 861D5C433ED
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3A6B461355
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A6B461355
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C86D421F245;
	Sat, 15 May 2021 06:06:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 67E6E21EBDE
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 973EF1006EA3;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 912129814B; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:09 -0400
Message-Id: <1621083970-32463-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/13] lnet: Correct the router ping interval
 calculation
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

The router ping interval is being divided by the number of local nets
which results in sending pings more frequently than defined by the
alive_router_check_interval. In addition, the current code is structured
such that we may not find a peer net in need of a ping until after
inspecting the router list multiple times. Re-work the code so that the
loop that inspects a router's peer nets will look at all of them until
it either loops back around the list or it finds one that actually
needs to be pinged.

We also move the check of LNET_PEER_RTR_DISCOVERY so that we avoid the
work of inspecting the router's peer nets if the router is already being
discovered.

HPE-bug-id: LUS-9237
WC-bug-id: https://jira.whamcloud.com/browse/LU-13912
Lustre-commit: 0131d39a622f1efc ("LU-13912 lnet: Correct the router ping interval calculation")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39694
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  4 +--
 net/lnet/lnet/router.c         | 57 ++++++++++++++++++++++++++----------------
 2 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f199b15..d898066 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -798,8 +798,8 @@ struct lnet_peer_net {
 	/* peer net health */
 	int			lpn_healthv;
 
-	/* time of last router net check attempt */
-	time64_t		lpn_rtrcheck_timestamp;
+	/* time of next router ping on this net */
+	time64_t		lpn_next_ping;
 
 	/* selection sequence number */
 	u32			lpn_seq;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index e179997..9003d47 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -603,6 +603,7 @@ static void lnet_shuffle_seed(void)
 	unsigned int offset = 0;
 	unsigned int len = 0;
 	struct list_head *e;
+	time64_t now;
 
 	lnet_shuffle_seed();
 
@@ -623,9 +624,10 @@ static void lnet_shuffle_seed(void)
 	/* force a router check on the gateway to make sure the route is
 	 * alive
 	 */
+	now = ktime_get_real_seconds();
 	list_for_each_entry(lpn, &route->lr_gateway->lp_peer_nets,
 			    lpn_peer_nets) {
-		lpn->lpn_rtrcheck_timestamp = 0;
+		lpn->lpn_next_ping = now;
 	}
 
 	the_lnet.ln_remote_nets_version++;
@@ -1105,11 +1107,12 @@ bool lnet_router_checker_active(void)
 void
 lnet_check_routers(void)
 {
-	struct lnet_peer_net *first_lpn = NULL;
+	struct lnet_peer_net *first_lpn;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *rtr;
 	bool push = false;
+	bool needs_ping;
 	bool found_lpn;
 	u64 version;
 	u32 net_id;
@@ -1122,14 +1125,18 @@ bool lnet_router_checker_active(void)
 	version = the_lnet.ln_routers_version;
 
 	list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
+		/* If we're currently discovering the peer then don't
+		 * issue another discovery
+		 */
+		if (rtr->lp_state & LNET_PEER_RTR_DISCOVERY)
+			continue;
+
 		now = ktime_get_real_seconds();
 
-		/* only discover the router if we've passed
-		 * alive_router_check_interval seconds. Some of the router
-		 * interfaces could be down and in that case they would be
-		 * undergoing recovery separately from this discovery.
-		 */
-		/* find next peer net which is also local */
+		/* find the next local peer net which needs to be ping'd */
+		needs_ping = false;
+		first_lpn = NULL;
+		found_lpn = false;
 		net_id = rtr->lp_disc_net_id;
 		do {
 			lpn = lnet_get_next_peer_net_locked(rtr, net_id);
@@ -1138,13 +1145,27 @@ bool lnet_router_checker_active(void)
 				       libcfs_nid2str(rtr->lp_primary_nid));
 				break;
 			}
+
+			/* We looped back to the first peer net */
 			if (first_lpn == lpn)
 				break;
 			if (!first_lpn)
 				first_lpn = lpn;
-			found_lpn = lnet_islocalnet_locked(lpn->lpn_net_id);
+
 			net_id = lpn->lpn_net_id;
-		} while (!found_lpn);
+			if (!lnet_islocalnet_locked(net_id))
+				continue;
+
+			found_lpn = true;
+
+			CDEBUG(D_NET, "rtr %s(%p) %s(%p) next ping %lld\n",
+			       libcfs_nid2str(rtr->lp_primary_nid), rtr,
+			       libcfs_net2str(net_id), lpn,
+			       lpn->lpn_next_ping);
+
+			needs_ping = now >= lpn->lpn_next_ping;
+
+		} while (!needs_ping);
 
 		if (!found_lpn || !lpn) {
 			CERROR("no local network found for gateway %s\n",
@@ -1152,18 +1173,10 @@ bool lnet_router_checker_active(void)
 			continue;
 		}
 
-		if (now - lpn->lpn_rtrcheck_timestamp <
-		    alive_router_check_interval / lnet_current_net_count)
+		if (!needs_ping)
 			continue;
 
-		/* If we're currently discovering the peer then don't
-		 * issue another discovery
-		 */
 		spin_lock(&rtr->lp_lock);
-		if (rtr->lp_state & LNET_PEER_RTR_DISCOVERY) {
-			spin_unlock(&rtr->lp_lock);
-			continue;
-		}
 		/* make sure we fully discover the router */
 		rtr->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
 		rtr->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH |
@@ -1188,16 +1201,16 @@ bool lnet_router_checker_active(void)
 		       libcfs_nid2str(lpni->lpni_nid), cpt);
 		rc = lnet_discover_peer_locked(lpni, cpt, false);
 
-		/* decrement ref count acquired by find_peer_ni_locked() */
+		/* drop ref taken above */
 		lnet_peer_ni_decref_locked(lpni);
 
 		if (!rc)
-			lpn->lpn_rtrcheck_timestamp = now;
+			lpn->lpn_next_ping = now + alive_router_check_interval;
 		else
 			CERROR("Failed to discover router %s\n",
 			       libcfs_nid2str(rtr->lp_primary_nid));
 
-		/* NB dropped lock */
+		/* NB cpt lock was dropped in lnet_discover_peer_locked() */
 		if (version != the_lnet.ln_routers_version) {
 			/* the routers list has changed */
 			goto rescan;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
