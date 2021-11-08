Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A522C433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:16 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0B9BE6113A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 0B9BE6113A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E1B7121F335;
	Mon,  8 Nov 2021 07:08:07 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E64A121CA3B
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:51 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 37B31222D;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 36803E07F4; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:42 -0500
Message-Id: <1636384063-13838-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/15] lnet: don't use hops to determine the
 route state
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
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

NodeA <-tcp1-> GW1 <-tcp2-> GW2 <-tcp3-> NodeB

Assuming GW1 knows how to reach tcp3 network and GW2 knows
how to reach tcp1 network, it should be possible to add routes
without specifying hop=2 on nodes A and B to reach tcp3 and tcp1
respectively and then be able to lnetctl ping between them.
Changes introduced by LU-13785 interpret default hops to be
equivalent to hop=1 set explicitly for the purpose of determining
route aliveness, which results in the routes created as described
above to be considered "down".

Fix it so that default hop setting doesn't prevent
the multi-hop scenario from working.

Fixes: 64d703ca18 ("lnet: Use lr_hops for avoid_asym_router_failure")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14945
Lustre-commit: 3f2844dc9333c8645 ("LU-14945 lnet: don't use hops to determine the route state")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44674
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 7ce33eb..97e5ab2 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -318,7 +318,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	 * routes the next-hop will not have the remote net.
 	 */
 	if (avoid_asym_router_failure &&
-	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS)) {
+	    (route->lr_hops == 1 || route->lr_single_hop)) {
 		rlpn = lnet_peer_get_net_locked(gw, route->lr_net);
 		if (!rlpn)
 			return false;
@@ -470,8 +470,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 
 		route->lr_single_hop = single_hop;
 		if (avoid_asym_router_failure &&
-		    (route->lr_hops == 1 ||
-		     route->lr_hops == LNET_UNDEFINED_HOPS))
+		    (route->lr_hops == 1 || route->lr_single_hop))
 			lnet_set_route_aliveness(route, net_up);
 		else
 			lnet_set_route_aliveness(route, true);
@@ -764,6 +763,14 @@ static void lnet_shuffle_seed(void)
 	lnet_peer_ni_decref_locked(lpni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
+	/* If avoid_asym_router_failure is enabled and hop count is not
+	 * set to 1 for a route that is actually single-hop, then the
+	 * feature will fail to prevent the router from being selected
+	 * if it is missing a NI on the remote network due to misconfiguration.
+	 */
+	if (avoid_asym_router_failure && hops == LNET_UNDEFINED_HOPS)
+		CWARN("Use hops = 1 for a single-hop route when avoid_asym_router_failure feature is enabled\n");
+
 	rc = 0;
 
 	if (!add_route) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
