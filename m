From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:34 -0500
Subject: [lustre-devel] [PATCH 346/622] lnet: transfer routers
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-347-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When a primary NID of a peer is about to be deleted because
it's being transferred to another peer, if that peer is a gateway
then transfer all gateway properties to the new peer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11475
Lustre-commit: cab57464e17b ("LU-11475 lnet: transfer routers")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34539
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  2 ++
 net/lnet/lnet/peer.c          | 12 ++++++++++++
 net/lnet/lnet/router.c        | 29 +++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 1d06263..5a83e3a 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -534,6 +534,8 @@ int lnet_get_peer_list(u32 *countp, u32 *sizep,
 int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
 void lnet_rtrpools_free(int keep_pools);
+void lnet_rtr_transfer_to_peer(struct lnet_peer *src,
+			       struct lnet_peer *target);
 struct lnet_remotenet *lnet_find_rnet_locked(u32 net);
 int lnet_dyn_add_net(struct lnet_ioctl_config_data *conf);
 int lnet_dyn_del_net(u32 net);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index a81fee2..5d13986 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1355,6 +1355,18 @@ struct lnet_peer_net *
 		}
 		/* If this is the primary NID, destroy the peer. */
 		if (lnet_peer_ni_is_primary(lpni)) {
+			struct lnet_peer *rtr_lp =
+			  lpni->lpni_peer_net->lpn_peer;
+			int rtr_refcount = rtr_lp->lp_rtr_refcount;
+
+			/* if we're trying to delete a router it means
+			 * we're moving this peer NI to a new peer so must
+			 * transfer router properties to the new peer
+			 */
+			if (rtr_refcount > 0) {
+				flags |= LNET_PEER_RTR_NI_FORCE_DEL;
+				lnet_rtr_transfer_to_peer(rtr_lp, lp);
+			}
 			lnet_peer_del(lpni->lpni_peer_net->lpn_peer);
 			lpni = lnet_peer_ni_alloc(nid);
 			if (!lpni) {
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 4a061f3..aa8ec8c 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -136,6 +136,35 @@ static int rtr_sensitivity_set(const char *val,
 	return 0;
 }
 
+void
+lnet_rtr_transfer_to_peer(struct lnet_peer *src, struct lnet_peer *target)
+{
+	struct lnet_route *route;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	target->lp_rtr_refcount += src->lp_rtr_refcount;
+	/* move the list of queued messages to the new peer */
+	list_splice_init(&src->lp_rtrq, &target->lp_rtrq);
+	/* move all the routes that reference the peer */
+	list_splice_init(&src->lp_routes, &target->lp_routes);
+	/* update all the routes to point to the new peer */
+	list_for_each_entry(route, &target->lp_routes, lr_gwlist)
+		route->lr_gateway = target;
+	/* remove the old peer from the ln_routers list */
+	list_del_init(&src->lp_rtr_list);
+	/* add the new peer to the ln_routers list */
+	if (list_empty(&target->lp_rtr_list)) {
+		lnet_peer_addref_locked(target);
+		list_add_tail(&target->lp_rtr_list, &the_lnet.ln_routers);
+	}
+	/* reset the ref count on the old peer and decrement its ref count */
+	src->lp_rtr_refcount = 0;
+	lnet_peer_decref_locked(src);
+	/* update the router version */
+	the_lnet.ln_routers_version++;
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
 int
 lnet_peers_start_down(void)
 {
-- 
1.8.3.1
