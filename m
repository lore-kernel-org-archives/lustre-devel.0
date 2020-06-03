From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:53 -0400
Subject: [lustre-devel] [PATCH 14/22] lnet: Force full discovery cycle
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

There are scenarios where there could be a discrepancy between
cached peer information and reality. In these cases what could
end-up happening is incomplete interface information might be
cached because one side determined that the peer didn't require
a PUSH. This will lead to undesired MR behavior, where not all
the interfaces are used for a period of time.

Therefore, it is safer to always force a full discovery cycle:
GET/PUSH to ensure both sides are up-to-date.

In the NMR case, when discovery is turned off, make sure to flag
discovery as complete to avoid stalling the state machine.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13477
Lustre-commit: 9bafd530d7858 ("LU-13477 lnet: Force full discovery cycle")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38322
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c   | 40 ++++++++++++++++++++++++----------------
 net/lnet/lnet/router.c |  5 +++--
 2 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 60749da..5869a20 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1179,6 +1179,11 @@ struct lnet_peer_ni *
 	lp = lpni->lpni_peer_net->lpn_peer;
 
 	while (!lnet_peer_is_uptodate(lp)) {
+		spin_lock(&lp->lp_lock);
+		/* force a full discovery cycle */
+		lp->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH;
+		spin_unlock(&lp->lp_lock);
+
 		rc = lnet_discover_peer_locked(lpni, cpt, true);
 		if (rc)
 			goto out_decref;
@@ -3043,6 +3048,19 @@ static int lnet_peer_push_failed(struct lnet_peer *lp)
 	return rc ? rc : LNET_REDISCOVER_PEER;
 }
 
+/* Mark the peer as discovered. */
+static int lnet_peer_discovered(struct lnet_peer *lp)
+__must_hold(&lp->lp_lock)
+{
+	lp->lp_state |= LNET_PEER_DISCOVERED;
+	lp->lp_state &= ~(LNET_PEER_DISCOVERING |
+			  LNET_PEER_REDISCOVER);
+
+	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
+
+	return 0;
+}
+
 /* Active side of push. */
 static int lnet_peer_send_push(struct lnet_peer *lp)
 __must_hold(&lp->lp_lock)
@@ -3056,6 +3074,12 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	/* Don't push to a non-multi-rail peer. */
 	if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
 		lp->lp_state &= ~LNET_PEER_FORCE_PUSH;
+		/* if peer's NIDs are uptodate then peer is discovered */
+		if (lp->lp_state & LNET_PEER_NIDS_UPTODATE) {
+			rc = lnet_peer_discovered(lp);
+			return rc;
+		}
+
 		return 0;
 	}
 
@@ -3147,22 +3171,6 @@ static void lnet_peer_discovery_error(struct lnet_peer *lp, int error)
 }
 
 /*
- * Mark the peer as discovered.
- */
-static int lnet_peer_discovered(struct lnet_peer *lp)
-__must_hold(&lp->lp_lock)
-{
-	lp->lp_state |= LNET_PEER_DISCOVERED;
-	lp->lp_state &= ~(LNET_PEER_DISCOVERING |
-			  LNET_PEER_REDISCOVER);
-
-	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
-
-	return 0;
-}
-
-
-/*
  * Discovering this peer is taking too long. Cancel any Ping or Push
  * that discovery is waiting on by unlinking the relevant MDs. The
  * lnet_discovery_event_handler() will proceed from here and complete
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index af50e51..903d027 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1154,9 +1154,10 @@ bool lnet_router_checker_active(void)
 			spin_unlock(&rtr->lp_lock);
 			continue;
 		}
-		/* make sure we actively discover the router */
+		/* make sure we fully discover the router */
 		rtr->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
-		rtr->lp_state |= LNET_PEER_RTR_DISCOVERY;
+		rtr->lp_state |= LNET_PEER_FORCE_PING | LNET_PEER_FORCE_PUSH |
+				 LNET_PEER_RTR_DISCOVERY;
 		spin_unlock(&rtr->lp_lock);
 
 		/* find the peer_ni associated with the primary NID */
-- 
1.8.3.1
