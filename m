Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FF10C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2209661260
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2209661260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1E7BF21F82F;
	Sun, 25 Apr 2021 13:09:17 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 91F0421F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3008F10087CC;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2E9D669A7E; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:25 -0400
Message-Id: <1619381316-7719-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/29] lnet: Leverage peer aliveness more
 efficiently
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

When an LNet router is revived after going down, remote peers may
discover it is alive before we do. Thus, remote peers may use it
as a next-hop, and we may start receiving messages from it while we
still consider it to be dead. We should mark router peers as alive
when we receive a message from them.

If an LNet router does not respond to a discovery ping, then we
currently mark all of its NIs as DOWN. This can actually slow down
the process of returning a route to service. If we receive a message
from a router, in the manner described above, then we can safely
return the router to service. We already set the status of the router
NI we received the message from to UP, but the remote NIs will still
be DOWN and thus the route will be considered down until we get a
reply to the next discovery ping.

When selecting a route, we only consider the aliveness of a gateway's
remote NIs if avoid_asym_router_failure is enabled and the route is
single-hop. In this case, as long as the gateway has at least one
alive NI on the remote network then the route is considered UP. In
the situation described above, we know the router has at least one
NI alive because it was used to forward a message from a remote peer.
Thus, when we receive a forwarded message from a router, we can
reasonably set the NI status of all of its NIs that are on the same
peer net as the message originator to UP. This does not impact the
route status of any multi-hop routes because we do not consider the
aliveness of remote NIs for multi-hop routes.

Similarly, we can set the cached lr_alive value to up for any routes
whose lr_net matches the net ID of the message originator NID. This
variable is converted to an atomic_t to get rid of the need for
global locking when updating it.

HPE-bug-id: LUS-9088
WC-bug-id: https://jira.whamcloud.com/browse/LU-13780
Lustre-commit: 886e34ce56c491e8 ("LU-13780 lnet: Leverage peer aliveness more efficiently")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39350
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 12 ++++++++++++
 include/linux/lnet/lib-types.h |  2 +-
 net/lnet/lnet/lib-move.c       | 37 ++++++++++++++++++++++++++++++++++---
 net/lnet/lnet/router.c         | 29 ++++++-----------------------
 4 files changed, 53 insertions(+), 27 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 4712e2d..fd24c10 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -1040,4 +1040,16 @@ u32 lnet_sum_stats(struct lnet_element_stats *stats,
 void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			      struct lnet_element_stats *stats);
 
+static inline void
+lnet_set_route_aliveness(struct lnet_route *route, bool alive)
+{
+	bool old = atomic_xchg(&route->lr_alive, alive);
+
+	if (old != alive)
+		CERROR("route to %s through %s has gone from %s to %s\n",
+		       libcfs_net2str(route->lr_net),
+		       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
+		       old ? "up" : "down",
+		       alive ? "up" : "down");
+}
 #endif
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f479efe..a6a7588 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -868,7 +868,7 @@ struct lnet_route {
 	/* route priority */
 	unsigned int		lr_priority;
 	/* cached route aliveness */
-	bool			lr_alive;
+	atomic_t		lr_alive;
 	/* this route is single-hop */
 	bool			lr_single_hop;
 };
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index ad1517d..a9399cc 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4360,7 +4360,12 @@ void lnet_monitor_thr_stop(void)
 		goto drop;
 	}
 
-	if (lnet_drop_asym_route && for_me &&
+	/* If this message was forwarded to us from a router then we may need
+	 * to update router aliveness or check for an asymmetrical route
+	 * (or both)
+	 */
+	if (((lnet_drop_asym_route && for_me) ||
+	     !lpni->lpni_peer_net->lpn_peer->lp_alive) &&
 	    LNET_NIDNET(src_nid) != LNET_NIDNET(from_nid)) {
 		u32 src_net_id = LNET_NIDNET(src_nid);
 		struct lnet_peer *gw = lpni->lpni_peer_net->lpn_peer;
@@ -4370,10 +4375,24 @@ void lnet_monitor_thr_stop(void)
 		list_for_each_entry(route, &gw->lp_routes, lr_gwlist) {
 			if (route->lr_net == src_net_id) {
 				found = true;
-				break;
+				/* If we're transitioning the gateway from
+				 * dead -> alive, and discovery is disabled
+				 * locally or on the gateway, then we need to
+				 * update the cached route aliveness for each
+				 * route to the src_nid's net.
+				 *
+				 * Otherwise, we're only checking for
+				 * symmetrical route, and we can break the
+				 * loop
+				 */
+				if (!gw->lp_alive &&
+				    lnet_is_discovery_disabled(gw))
+					lnet_set_route_aliveness(route, true);
+				else
+					break;
 			}
 		}
-		if (!found) {
+		if (lnet_drop_asym_route && for_me && !found) {
 			lnet_net_unlock(cpt);
 			/* we would not use from_nid to route a message to
 			 * src_nid
@@ -4385,6 +4404,18 @@ void lnet_monitor_thr_stop(void)
 			kfree(msg);
 			goto drop;
 		}
+		if (!gw->lp_alive) {
+			struct lnet_peer_net *lpn;
+			struct lnet_peer_ni *lpni2;
+
+			gw->lp_alive = true;
+			/* Mark all remote NIs on src_nid's net UP */
+			lpn = lnet_peer_get_net_locked(gw, src_net_id);
+			if (lpn)
+				list_for_each_entry(lpni2, &lpn->lpn_peer_nis,
+						    lpni_peer_nis)
+					lpni2->lpni_ns_status = LNET_NI_STATUS_UP;
+		}
 	}
 
 	lpni->lpni_last_alive = ktime_get_seconds();
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index af16263..ae7582ca 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -303,7 +303,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	 * enabled.
 	 */
 	if (lnet_is_discovery_disabled(gw))
-		return route->lr_alive;
+		return atomic_read(&route->lr_alive) == 1;
 
 	/* check the gateway's interfaces on the local network */
 	llpn = lnet_peer_get_net_locked(gw, route->lr_lnet);
@@ -394,21 +394,6 @@ bool lnet_is_route_alive(struct lnet_route *route)
 }
 
 /* Must hold net_lock/EX */
-static inline void
-lnet_set_route_aliveness(struct lnet_route *route, bool alive)
-{
-	/* Log when there's a state change */
-	if (route->lr_alive != alive) {
-		CERROR("route to %s through %s has gone from %s to %s\n",
-		       libcfs_net2str(route->lr_net),
-		       libcfs_nid2str(route->lr_gateway->lp_primary_nid),
-		       (route->lr_alive) ? "up" : "down",
-		       alive ? "up" : "down");
-		route->lr_alive = alive;
-	}
-}
-
-/* Must hold net_lock/EX */
 void
 lnet_router_discovery_ping_reply(struct lnet_peer *lp)
 {
@@ -706,6 +691,10 @@ static void lnet_shuffle_seed(void)
 	route->lr_nid = gateway;
 	route->lr_priority = priority;
 	route->lr_hops = hops;
+	if (lnet_peers_start_down())
+		atomic_set(&route->lr_alive, 0);
+	else
+		atomic_set(&route->lr_alive, 1);
 
 	lnet_net_lock(LNET_LOCK_EX);
 
@@ -1770,14 +1759,8 @@ bool lnet_router_checker_active(void)
 		 */
 		if (lnet_is_discovery_disabled(lp)) {
 			list_for_each_entry(route, &lp->lp_routes, lr_gwlist) {
-				if (route->lr_nid == lpni->lpni_nid &&
-				    route->lr_alive != alive) {
-					lnet_net_unlock(0);
-					lnet_net_lock(LNET_LOCK_EX);
+				if (route->lr_nid == lpni->lpni_nid)
 					lnet_set_route_aliveness(route, alive);
-					lnet_net_unlock(LNET_LOCK_EX);
-					lnet_net_lock(0);
-				}
 			}
 		}
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
