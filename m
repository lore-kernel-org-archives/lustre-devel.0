Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 269A9C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:47 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmQ63Wqz1yDy;
	Sat, 17 Sep 2022 22:22:46 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm24grWz1yBr
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:26 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id EA5928F0B;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E6EE2F64; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:01 -0400
Message-Id: <1663478534-19917-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/24] lnet: Always use ping reply to set
 route lr_alive
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

We currently process discovery ping replies in different ways
depending on whether the gateway has discovery enabled or disabled
(or the local peer doing the processing has discovery enabled or
disabled).

When DD is disabled we process the ping reply to set the lr_alive
field of lnet_route because the peer objects for non-MR routers do
not contain all the information needed to calculate the route
aliveness when a message is being sent.

When DD is enabled then we don't do any special processing of the
ping reply. We simply let discovery update the NI status for the
GW's peer NIs and then we calculate the route aliveness on every
send.

We issue discovery pings to routers every alive_router_check_interval
seconds (default 60), but we calculate route aliveness on every send
to a remote network (1000s of times per seconds). Thus, it is better
to slightly duplicate the effort expended when we receive a discovery
reply so that we can avoid calculating route aliveness on every send.

Since both lr_alive and hop type are being set on each ping reply, for
both DD enabled and disabled cases, we can remove the code for
updating lr_alive and hop type from lnet_router_discovery_complete().

If discover encounters a fatal error, we still set the status of each
peer NI, as well as all routes, to down in
lnet_router_discovery_complete().

WC-bug-id: https://jira.whamcloud.com/browse/LU-15595
Lustre-commit: 1ea6c87d415144522 ("LU-15595 lnet: Always use ping reply to set route lr_alive")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46624
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  3 +-
 net/lnet/lnet/peer.c          | 14 ++++-----
 net/lnet/lnet/router.c        | 71 +++++++++----------------------------------
 3 files changed, 23 insertions(+), 65 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 1d9b8c7..fc086da 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -848,7 +848,8 @@ struct socket *lnet_sock_connect(int interface, int local_port,
 void lnet_consolidate_routes_locked(struct lnet_peer *orig_lp,
 				    struct lnet_peer *new_lp);
 void lnet_router_discovery_complete(struct lnet_peer *lp);
-void lnet_router_discovery_ping_reply(struct lnet_peer *lp);
+void lnet_router_discovery_ping_reply(struct lnet_peer *lp,
+				      struct lnet_ping_buffer *pbuf);
 
 int lnet_monitor_thr_start(void);
 void lnet_monitor_thr_stop(void);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 8d81a7d..e7c3c83 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2745,14 +2745,6 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 out:
 	lp->lp_state &= ~LNET_PEER_PING_SENT;
 	spin_unlock(&lp->lp_lock);
-
-	lnet_net_lock(LNET_LOCK_EX);
-	/* If this peer is a gateway, call the routing callback to
-	 * handle the ping reply
-	 */
-	if (lp->lp_rtr_refcount > 0)
-		lnet_router_discovery_ping_reply(lp);
-	lnet_net_unlock(LNET_LOCK_EX);
 }
 
 /*
@@ -3052,6 +3044,12 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	 */
 	rc = 0;
 out:
+	/* If this peer is a gateway, invoke the routing callback to update
+	 * the associated route status
+	 */
+	if (lp->lp_rtr_refcount > 0)
+		lnet_router_discovery_ping_reply(lp, pbuf);
+
 	kfree(curnis);
 	kfree(addnis);
 	kfree(delnis);
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 146647c..5d1e5a05a 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -153,6 +153,7 @@ static void lnet_del_route_from_rnet(struct lnet_nid *gw_nid,
 void
 lnet_move_route(struct lnet_route *route, struct lnet_peer *lp,
 		struct list_head *rt_list)
+__must_hold(&the_lnet.ln_api_mutex)
 {
 	struct lnet_remotenet *rnet;
 	struct list_head zombies;
@@ -378,61 +379,31 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	}
 }
 
-static void
-lnet_set_route_hop_type(struct lnet_peer *gw, struct lnet_route *route)
-{
-	struct lnet_peer_net *lpn;
-	bool single_hop = false;
-
-	list_for_each_entry(lpn, &gw->lp_peer_nets, lpn_peer_nets) {
-		if (route->lr_net == lpn->lpn_net_id) {
-			single_hop = true;
-			break;
-		}
-	}
-	route->lr_single_hop = single_hop;
-	lnet_check_route_inconsistency(route);
-}
-
-/* Must hold net_lock/EX */
+/* Routes are added and removed under both ln_api_mutex and net_lock/EX
+ * Since we are not modifying anything we simply require the ln_api_mutex be
+ * held so that things are not modified underneath us
+ */
 void
-lnet_router_discovery_ping_reply(struct lnet_peer *lp)
+lnet_router_discovery_ping_reply(struct lnet_peer *lp,
+				 struct lnet_ping_buffer *pbuf)
+__must_hold(&the_lnet.ln_api_mutex)
 {
-	struct lnet_ping_buffer *pbuf = lp->lp_data;
 	struct lnet_peer_net *llpn;
 	struct lnet_route *route;
 	bool single_hop = false;
 	bool net_up = false;
-	unsigned int lp_state;
 	u32 net;
 	int i;
 
-	spin_lock(&lp->lp_lock);
-	lp_state = lp->lp_state;
-
-	/* only handle replies if discovery is disabled. */
-	if (!lnet_is_discovery_disabled_locked(lp)) {
-		spin_unlock(&lp->lp_lock);
-		return;
-	}
-
-	spin_unlock(&lp->lp_lock);
-
-	if (lp_state & LNET_PEER_PING_FAILED ||
-	    pbuf->pb_info.pi_features & LNET_PING_FEAT_RTE_DISABLED) {
-		CDEBUG(D_NET, "Set routes down for gw %s because %s %d\n",
-		       libcfs_nidstr(&lp->lp_primary_nid),
-		       lp_state & LNET_PEER_PING_FAILED ? "ping failed" :
-		       "route feature is disabled", lp->lp_ping_error);
-		/* If the ping failed or the peer has routing disabled then
-		 * mark the routes served by this peer down
-		 */
+	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_RTE_DISABLED) {
+		CERROR("Peer %s is being used as a gateway but routing feature is not turned on\n",
+		       libcfs_nidstr(&lp->lp_primary_nid));
 		list_for_each_entry(route, &lp->lp_routes, lr_gwlist)
 			lnet_set_route_aliveness(route, false);
 		return;
 	}
 
-	CDEBUG(D_NET, "Discovery is disabled. Processing reply for gw: %s:%d\n",
+	CDEBUG(D_NET, "Processing reply for gw: %s nnis %d\n",
 	       libcfs_nidstr(&lp->lp_primary_nid), pbuf->pb_info.pi_nnis);
 
 	/* examine the ping response to determine if the routes on that
@@ -495,22 +466,8 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	lp->lp_alive = lp->lp_dc_error == 0;
 	spin_unlock(&lp->lp_lock);
 
-	if (!lp->lp_dc_error) {
-		/* ping replies are being handled when discovery is disabled */
-		if (lnet_is_discovery_disabled_locked(lp))
-			return;
-
-		/* mark single-hop routes. If the remote net is not configured
-		 * on the gateway we assume this is intentional and we mark the
-		 * gateway as multi-hop
-		 */
-		list_for_each_entry(route, &lp->lp_routes, lr_gwlist) {
-			lnet_set_route_aliveness(route, true);
-			lnet_set_route_hop_type(lp, route);
-		}
-
+	if (!lp->lp_dc_error)
 		return;
-	}
 
 	/* We do not send messages directly to the remote interfaces
 	 * of an LNet router. As such, we rely on the PING response
@@ -642,6 +599,7 @@ static void lnet_shuffle_seed(void)
 int
 lnet_add_route(u32 net, u32 hops, struct lnet_nid *gateway,
 	       u32 priority, u32 sensitivity)
+__must_hold(&the_lnet.ln_api_mutex)
 {
 	struct list_head *route_entry;
 	struct lnet_remotenet *rnet;
@@ -821,6 +779,7 @@ static void lnet_shuffle_seed(void)
 
 int
 lnet_del_route(u32 net, struct lnet_nid *gw)
+__must_hold(&the_lnet.ln_api_mutex)
 {
 	LIST_HEAD(rnet_zombies);
 	struct lnet_remotenet *rnet;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
