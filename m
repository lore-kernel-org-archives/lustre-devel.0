Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E8A5C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DD0F7610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD0F7610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ACDD132F613;
	Wed, 14 Apr 2021 21:02:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E36F732F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 53755100F334;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4AE0C91890; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:56 -0400
Message-Id: <1618459361-17909-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/49] lnet: lnet_notify sets route aliveness
 incorrectly
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

lnet_notify() modifies route aliveness in two ways:
1. By setting lp_alive field of the lnet_peer struct.
2. By setting lr_alive field of the lnet_route struct (via call to
   lnet_set_route_aliveness())

In both cases, the aliveness value assigned is determined by a call
to lnet_is_peer_ni_alive(), but that value only reflects the aliveness
of a particular peer NI. A gateway may have multiple peer NIs, so the
aliveness of a gateway peer (lp_alive) is not necessarily equivalent
to the aliveness of one of its NIs. Furthermore, the lr_alive field
is only used to determine route aliveness for path selection if
discovery is disabled locally or on the gateway (see
lnet_find_route_locked() and lnet_is_route_alive()).

In general, we should not set lp_alive based on an lnet_notify()
call, and we should only set lr_alive if discovery is disabled. For
lr_alive specifically, we should only set it for those routes that
have the peer NI as a next-hop.

An exception to the above exists when the reset argument to
lnet_notify() is set. The gnilnd uses this flag in its calls to
lnet_notify() because gnilnd receives out-of-band notifications of
node up and down events. Thus, when gnilnd calls lnet_notify() we
actually know whether the gateway peer is up or down and we can set
lp_alive appropriately.

net lock/EX is held by other callers of lnet_set_route_aliveness, so
we do the same in lnet_notify().

Fixes: 938a22eaf2 ("lnet: discovery off route state update")
Fixes: 1cadb960f1 ("lnet: Add peer level aliveness information")
HPE-bug-id: LUS-9034
WC-bug-id: https://jira.whamcloud.com/browse/LU-13708
Lustre-commit: e24471a722a6f23f ("LU-13708 lnet: lnet_notify sets route aliveness incorrectly")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39160
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 39 +++++++++++++++++++++++++++++++++------
 1 file changed, 33 insertions(+), 6 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index e030b16..ee3c15f 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -391,6 +391,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	lnet_check_route_inconsistency(route);
 }
 
+/* Must hold net_lock/EX */
 static inline void
 lnet_set_route_aliveness(struct lnet_route *route, bool alive)
 {
@@ -405,6 +406,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	}
 }
 
+/* Must hold net_lock/EX */
 void
 lnet_router_discovery_ping_reply(struct lnet_peer *lp)
 {
@@ -1745,6 +1747,37 @@ bool lnet_router_checker_active(void)
 
 	/* recalculate aliveness */
 	alive = lnet_is_peer_ni_alive(lpni);
+
+	lp = lpni->lpni_peer_net->lpn_peer;
+	/* If this is an LNet router then update route aliveness */
+	if (lp->lp_rtr_refcount) {
+		if (reset)
+			/* reset flag indicates gateway peer went up or down */
+			lp->lp_alive = alive;
+
+		/* If discovery is disabled, locally or on the gateway, then
+		 * any routes using lpni as next-hop need to be updated
+		 *
+		 * NB: We can get many notifications while a route is down, so
+		 * we try and avoid the expensive net_lock/EX here for the
+		 * common case of receiving duplicate lnet_notify() calls (i.e.
+		 * only grab EX lock when we actually need to update the route
+		 * aliveness).
+		 */
+		if (lnet_is_discovery_disabled(lp)) {
+			list_for_each_entry(route, &lp->lp_routes, lr_gwlist) {
+				if (route->lr_nid == lpni->lpni_nid &&
+				    route->lr_alive != alive) {
+					lnet_net_unlock(0);
+					lnet_net_lock(LNET_LOCK_EX);
+					lnet_set_route_aliveness(route, alive);
+					lnet_net_unlock(LNET_LOCK_EX);
+					lnet_net_lock(0);
+				}
+			}
+		}
+	}
+
 	lnet_net_unlock(0);
 
 	if (ni && !alive)
@@ -1753,12 +1786,6 @@ bool lnet_router_checker_active(void)
 	cpt = lpni->lpni_cpt;
 	lnet_net_lock(cpt);
 	lnet_peer_ni_decref_locked(lpni);
-	if (lpni && lpni->lpni_peer_net && lpni->lpni_peer_net->lpn_peer) {
-		lp = lpni->lpni_peer_net->lpn_peer;
-		lp->lp_alive = alive;
-		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
-			lnet_set_route_aliveness(route, alive);
-	}
 	lnet_net_unlock(cpt);
 
 	return 0;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
