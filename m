Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A9A4FC19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrxx2fcHz23L5;
	Wed,  3 Aug 2022 18:39:49 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwb6X3tz23JL
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:39 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D946F100B009;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D7BD582CCE; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:04 -0400
Message-Id: <1659577097-19253-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/32] lnet: asym route inconsistency warning
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Gian-Carlo DeFazio <defazio1@llnl.gov>

lnet_check_route_inconsistency() checks for inconsistency between
the lr_hops and lr_single_hop values of a route.

A warning is currently emitted if the route is not single hop
and the hop count is either 1 or LNET_UNDEFINED_HOPS.

To emit the warning, add the requirement that
avoid_asym_router_failure is enabled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14555
Lustre-commit: 6ab060e58e6b3f38b ("LU-14555 lnet: asym route inconsistency warning")
Signed-off-by: Gian-Carlo DeFazio <defazio1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/46918
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index bbef2b3..b684243 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -369,7 +369,8 @@ bool lnet_is_route_alive(struct lnet_route *route)
 lnet_check_route_inconsistency(struct lnet_route *route)
 {
 	if (!route->lr_single_hop &&
-	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS)) {
+	    (route->lr_hops == 1 || route->lr_hops == LNET_UNDEFINED_HOPS) &&
+	    avoid_asym_router_failure) {
 		CWARN("route %s->%s is detected to be multi-hop but hop count is set to %d\n",
 		      libcfs_net2str(route->lr_net),
 		      libcfs_nidstr(&route->lr_gateway->lp_primary_nid),
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
