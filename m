From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:02 -0500
Subject: [lustre-devel] [PATCH 494/622] lnet: Use alternate ping processing
 for non-mr peers
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-495-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Router peers without multi-rail capabilities (i.e. older Lustre
versions) or router peers that have discovery disabled need to use
the alternate ping processing introduced by LU-12422. Otherwise,
these peers go through the normal discovery processing, but their
remote network interfaces are never added to the peer object. This
causes routes through these peers to be considered down when
avoid_asym_router_failure is enabled.

Cray-bug-id: LUS-7866
WC-bug-id: https://jira.whamcloud.com/browse/LU-12763
Lustre-commit: 010f6b1819b9 ("LU-12763 lnet: Use alternate ping processing for non-mr peers")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36182
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 1 +
 net/lnet/lnet/peer.c          | 1 +
 net/lnet/lnet/router.c        | 9 ++++++---
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index db1b7e5..56556fd 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -878,6 +878,7 @@ int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 bool lnet_peer_is_uptodate(struct lnet_peer *lp);
 bool lnet_peer_is_uptodate_locked(struct lnet_peer *lp);
 bool lnet_is_discovery_disabled(struct lnet_peer *lp);
+bool lnet_is_discovery_disabled_locked(struct lnet_peer *lp);
 bool lnet_peer_gw_discovery(struct lnet_peer *lp);
 
 static inline bool
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0d33ade..a067136 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1141,6 +1141,7 @@ struct lnet_peer_ni *
 
 bool
 lnet_is_discovery_disabled_locked(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
 {
 	if (lnet_peer_discovery_disabled)
 		return true;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 7246eea..a5e4af0 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -227,7 +227,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	 * aliveness information can only be obtained when discovery is
 	 * enabled.
 	 */
-	if (lnet_peer_discovery_disabled)
+	if (lnet_is_discovery_disabled(gw))
 		return route->lr_alive;
 
 	/* check the gateway's interfaces on the route rnet to make sure
@@ -316,11 +316,14 @@ bool lnet_is_route_alive(struct lnet_route *route)
 
 	spin_lock(&lp->lp_lock);
 	lp_state = lp->lp_state;
-	spin_unlock(&lp->lp_lock);
 
 	/* only handle replies if discovery is disabled. */
-	if (!lnet_peer_discovery_disabled)
+	if (!lnet_is_discovery_disabled_locked(lp)) {
+		spin_unlock(&lp->lp_lock);
 		return;
+	}
+
+	spin_unlock(&lp->lp_lock);
 
 	if (lp_state & LNET_PEER_PING_FAILED) {
 		CDEBUG(D_NET,
-- 
1.8.3.1
