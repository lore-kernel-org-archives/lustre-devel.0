Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32464C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D9735611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9735611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BF66621F9EE;
	Sun, 25 Apr 2021 13:09:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5851A21F78F
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2D5A110087CB;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2B99869A7D; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:24 -0400
Message-Id: <1619381316-7719-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/29] lnet: Use lr_hops for
 avoid_asym_router_failure
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

In order for the asymmetric route failure avoidance feature to work
properly it needs to know what the hop count of a route should be.
This information is defined by the lr_hops field of the lnet_route.
The lr_single_hop is what discovery was able to determine the hop
count actually is (single or multi) based on the last ping reply.
If a remote interface on a router goes missing, the route may be
classified as multi-hop by discovery, but it should be considered
single-hop for the purposes of avoiding asymmetric route failure.

HPE-bug-id: LUS-9099
WC-bug-id: https://jira.whamcloud.com/browse/LU-13785
Lustre-commit: 2e07619477684f28 ("LU-13785 lnet: Use lr_hops for avoid_asym_router_failure")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39362
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index ee3c15f..af16263 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -317,7 +317,8 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	 * that the remote net must exist on the gateway. For multi-hop
 	 * routes the next-hop will not have the remote net.
 	 */
-	if (avoid_asym_router_failure && route->lr_single_hop) {
+	if (avoid_asym_router_failure &&
+	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS)) {
 		rlpn = lnet_peer_get_net_locked(gw, route->lr_net);
 		if (!rlpn)
 			return false;
@@ -367,7 +368,8 @@ bool lnet_is_route_alive(struct lnet_route *route)
 static inline void
 lnet_check_route_inconsistency(struct lnet_route *route)
 {
-	if (!route->lr_single_hop && (int)route->lr_hops <= 1) {
+	if (!route->lr_single_hop &&
+	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS)) {
 		CWARN("route %s->%s is detected to be multi-hop but hop count is set to %d\n",
 		      libcfs_net2str(route->lr_net),
 		      libcfs_nid2str(route->lr_gateway->lp_primary_nid),
@@ -482,7 +484,9 @@ bool lnet_is_route_alive(struct lnet_route *route)
 		}
 
 		route->lr_single_hop = single_hop;
-		if (avoid_asym_router_failure && single_hop)
+		if (avoid_asym_router_failure &&
+		    (route->lr_hops == 1 ||
+		     route->lr_hops == LNET_UNDEFINED_HOPS))
 			lnet_set_route_aliveness(route, net_up);
 		else
 			lnet_set_route_aliveness(route, true);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
