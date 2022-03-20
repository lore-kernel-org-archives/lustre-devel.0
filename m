Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8526BC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:21 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B3DCD21E0B2;
	Sun, 20 Mar 2022 06:31:50 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2DC4D21F157
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 4BDB9EF3;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 49154D87DE; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:42 -0400
Message-Id: <1647783064-20688-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/50] lnet: change lnet_del_route() to take
 lnet_nid
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The gateway NID passed to lnet_del_route is now a struct lnet_nid.
Instead of passing LNET_NID_ANY as a wildcard, we pass
a NULL pointer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 58993799f29d12c1a ("U-10391 lnet: change lnet_del_route() to take lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43615
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  2 +-
 net/lnet/lnet/api-ni.c        |  3 ++-
 net/lnet/lnet/peer.c          |  7 +++----
 net/lnet/lnet/router.c        | 29 +++++++++++++++++------------
 4 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 33fee17..b6a7a54 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -576,7 +576,7 @@ void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
 int lnet_add_route(u32 net, u32 hops, struct lnet_nid *gateway,
 		   u32 priority, u32 sensitivity);
-int lnet_del_route(u32 net, lnet_nid_t gw_nid);
+int lnet_del_route(u32 net, struct lnet_nid *gw_nid);
 void lnet_move_route(struct lnet_route *route, struct lnet_peer *lp,
 		     struct list_head *rt_list);
 void lnet_destroy_routes(void);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0389a89..7a05752 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3901,8 +3901,9 @@ u32 lnet_get_dlc_seq_locked(void)
 		if (config->cfg_hdr.ioc_len < sizeof(*config))
 			return -EINVAL;
 
+		lnet_nid4_to_nid(config->cfg_nid, &nid);
 		mutex_lock(&the_lnet.ln_api_mutex);
-		rc = lnet_del_route(config->cfg_net, config->cfg_nid);
+		rc = lnet_del_route(config->cfg_net, &nid);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 8e7f44c..f70ceb5 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -627,7 +627,7 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 {
 	struct lnet_peer_ni *lp;
 	struct lnet_peer_ni *tmp;
-	lnet_nid_t gw_nid;
+	struct lnet_nid gw_nid;
 	int i;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
@@ -639,10 +639,9 @@ static void lnet_peer_cancel_discovery(struct lnet_peer *lp)
 			if (!lnet_isrouter(lp))
 				continue;
 
-			/* FIXME handle large-addr nid */
-			gw_nid = lnet_nid_to_nid4(&lp->lpni_peer_net->lpn_peer->lp_primary_nid);
+			gw_nid = lp->lpni_peer_net->lpn_peer->lp_primary_nid;
 			lnet_net_unlock(LNET_LOCK_EX);
-			lnet_del_route(LNET_NET_ANY, gw_nid);
+			lnet_del_route(LNET_NET_ANY, &gw_nid);
 			lnet_net_lock(LNET_LOCK_EX);
 		}
 	}
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 87ae1f9..beded3e 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -116,7 +116,7 @@ static int rtr_sensitivity_set(const char *val,
 
 static void lnet_add_route_to_rnet(struct lnet_remotenet *rnet,
 				   struct lnet_route *route);
-static void lnet_del_route_from_rnet(lnet_nid_t gw_nid,
+static void lnet_del_route_from_rnet(struct lnet_nid *gw_nid,
 				     struct list_head *route_list,
 				     struct list_head *zombies);
 
@@ -175,7 +175,7 @@ static void lnet_del_route_from_rnet(lnet_nid_t gw_nid,
 	/* use the gateway's lp_primary_nid to delete the route as the
 	 * lr_nid can be a constituent NID of the peer
 	 */
-	lnet_del_route_from_rnet(lnet_nid_to_nid4(&route->lr_gateway->lp_primary_nid),
+	lnet_del_route_from_rnet(&route->lr_gateway->lp_primary_nid,
 				 &rnet->lrn_routes, l);
 
 	if (lp) {
@@ -788,7 +788,8 @@ static void lnet_shuffle_seed(void)
 }
 
 void
-lnet_del_route_from_rnet(lnet_nid_t gw_nid, struct list_head *route_list,
+lnet_del_route_from_rnet(struct lnet_nid *gw_nid,
+			 struct list_head *route_list,
 			 struct list_head *zombies)
 {
 	struct lnet_peer *gateway;
@@ -797,8 +798,7 @@ static void lnet_shuffle_seed(void)
 
 	list_for_each_entry_safe(route, tmp, route_list, lr_list) {
 		gateway = route->lr_gateway;
-		if (gw_nid != LNET_NID_ANY &&
-		    gw_nid != lnet_nid_to_nid4(&gateway->lp_primary_nid))
+		if (gw_nid && !nid_same(gw_nid, &gateway->lp_primary_nid))
 			continue;
 
 		/* move to zombie to delete outside the lock
@@ -817,7 +817,7 @@ static void lnet_shuffle_seed(void)
 }
 
 int
-lnet_del_route(u32 net, lnet_nid_t gw_nid)
+lnet_del_route(u32 net, struct lnet_nid *gw)
 {
 	LIST_HEAD(rnet_zombies);
 	struct lnet_remotenet *rnet;
@@ -825,12 +825,13 @@ static void lnet_shuffle_seed(void)
 	struct list_head *rn_list;
 	struct lnet_peer_ni *lpni;
 	struct lnet_route *route;
+	struct lnet_nid gw_nid;
 	LIST_HEAD(zombies);
 	struct lnet_peer *lp = NULL;
 	int i = 0;
 
 	CDEBUG(D_NET, "Del route: net %s : gw %s\n",
-	       libcfs_net2str(net), libcfs_nid2str(gw_nid));
+	       libcfs_net2str(net), libcfs_nidstr(gw));
 
 	/* NB Caller may specify either all routes via the given gateway
 	 * or a specific route entry actual NIDs)
@@ -838,11 +839,15 @@ static void lnet_shuffle_seed(void)
 
 	lnet_net_lock(LNET_LOCK_EX);
 
-	lpni = lnet_find_peer_ni_locked(gw_nid);
+	if (gw)
+		lpni = lnet_peer_ni_find_locked(gw);
+	else
+		lpni = NULL;
 	if (lpni) {
 		lp = lpni->lpni_peer_net->lpn_peer;
 		LASSERT(lp);
-		gw_nid = lnet_nid_to_nid4(&lp->lp_primary_nid);
+		gw_nid = lp->lp_primary_nid;
+		gw = &gw_nid;
 		lnet_peer_ni_decref_locked(lpni);
 	}
 
@@ -852,7 +857,7 @@ static void lnet_shuffle_seed(void)
 			lnet_net_unlock(LNET_LOCK_EX);
 			return -ENOENT;
 		}
-		lnet_del_route_from_rnet(gw_nid, &rnet->lrn_routes,
+		lnet_del_route_from_rnet(gw, &rnet->lrn_routes,
 					 &zombies);
 		if (list_empty(&rnet->lrn_routes))
 			list_move(&rnet->lrn_list, &rnet_zombies);
@@ -863,7 +868,7 @@ static void lnet_shuffle_seed(void)
 		rn_list = &the_lnet.ln_remote_nets_hash[i];
 
 		list_for_each_entry_safe(rnet, tmp, rn_list, lrn_list) {
-			lnet_del_route_from_rnet(gw_nid, &rnet->lrn_routes,
+			lnet_del_route_from_rnet(gw, &rnet->lrn_routes,
 						 &zombies);
 			if (list_empty(&rnet->lrn_routes))
 				list_move(&rnet->lrn_list, &rnet_zombies);
@@ -903,7 +908,7 @@ static void lnet_shuffle_seed(void)
 void
 lnet_destroy_routes(void)
 {
-	lnet_del_route(LNET_NET_ANY, LNET_NID_ANY);
+	lnet_del_route(LNET_NET_ANY, NULL);
 }
 
 int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
