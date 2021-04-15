Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E375CC433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:12 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7F0BB61154
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F0BB61154
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2CFB832F729;
	Wed, 14 Apr 2021 21:03:04 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0792C32F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:50 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 638E0100F34C;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 60F699188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:03 -0400
Message-Id: <1618459361-17909-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/49] lnet: Correct asymmetric route
 detection
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

Failure to lookup the remote net for LNET_NIDNET(src_nid) indicates an
asymmetric route, but we do not drop the message in this case. Another
problem with this code is that there is no guarantee that we'll have a
route->lr_lnet that matches the net of ni->ni_nid.

We can move the asymmetric route detection to after we have looked up
the lpni of from_nid. Then, we can look at just the routes associated
with the gateway that owns the lpni. If one of those routes has
lr_net == LNET_NIDNET(src_nid), then the route is symmetrical.

Fixes: ed7389fa9f ("lnet: check for asymmetrical route messages")
HPE-bug-id: LUS-9087
WC-bug-id: https://jira.whamcloud.com/browse/LU-13779
Lustre-commit: 955080c3ae3f33c ("LU-13779 lnet: Correct asymmetric route detection")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39349
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 80 ++++++++++++++++--------------------------------
 1 file changed, 27 insertions(+), 53 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 25e0fd2..1868506 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4308,59 +4308,6 @@ void lnet_monitor_thr_stop(void)
 		goto drop;
 	}
 
-	if (lnet_drop_asym_route && for_me &&
-	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid)) {
-		struct lnet_net *net;
-		struct lnet_remotenet *rnet;
-		bool found = true;
-
-		/* we are dealing with a routed message,
-		 * so see if route to reach src_nid goes through from_nid
-		 */
-		lnet_net_lock(cpt);
-		net = lnet_get_net_locked(LNET_NIDNET(ni->ni_nid));
-		if (!net) {
-			lnet_net_unlock(cpt);
-			CERROR("net %s not found\n",
-			       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
-			return -EPROTO;
-		}
-
-		rnet = lnet_find_rnet_locked(LNET_NIDNET(src_nid));
-		if (rnet) {
-			struct lnet_peer *gw = NULL;
-			struct lnet_peer_ni *lpni = NULL;
-			struct lnet_route *route;
-
-			list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
-				found = false;
-				gw = route->lr_gateway;
-				if (route->lr_lnet != net->net_id)
-					continue;
-				/* if the nid is one of the gateway's NIDs
-				 * then this is a valid gateway
-				 */
-				while ((lpni = lnet_get_next_peer_ni_locked(gw, NULL, lpni)) != NULL) {
-					if (lpni->lpni_nid == from_nid) {
-						found = true;
-						break;
-					}
-				}
-			}
-		}
-		lnet_net_unlock(cpt);
-		if (!found) {
-			/* we would not use from_nid to route a message to
-			 * src_nid
-			 * => asymmetric routing detected but forbidden
-			 */
-			CERROR("%s, src %s: Dropping asymmetrical route %s\n",
-			       libcfs_nid2str(from_nid),
-			       libcfs_nid2str(src_nid), lnet_msgtyp2str(type));
-			goto drop;
-		}
-	}
-
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
@@ -4410,6 +4357,33 @@ void lnet_monitor_thr_stop(void)
 		goto drop;
 	}
 
+	if (lnet_drop_asym_route && for_me &&
+	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid)) {
+		u32 src_net_id = LNET_NIDNET(src_nid);
+		struct lnet_peer *gw = lpni->lpni_peer_net->lpn_peer;
+		struct lnet_route *route;
+		bool found = false;
+
+		list_for_each_entry(route, &gw->lp_routes, lr_gwlist) {
+			if (route->lr_net == src_net_id) {
+				found = true;
+				break;
+			}
+		}
+		if (!found) {
+			lnet_net_unlock(cpt);
+			/* we would not use from_nid to route a message to
+			 * src_nid
+			 * => asymmetric routing detected but forbidden
+			 */
+			CERROR("%s, src %s: Dropping asymmetrical route %s\n",
+			       libcfs_nid2str(from_nid),
+			       libcfs_nid2str(src_nid), lnet_msgtyp2str(type));
+			kfree(msg);
+			goto drop;
+		}
+	}
+
 	if (the_lnet.ln_routing)
 		lpni->lpni_last_alive = ktime_get_seconds();
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
