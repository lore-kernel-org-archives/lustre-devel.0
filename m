From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:58 -0500
Subject: [lustre-devel] [PATCH 610/622] lnet: Do not assume peers are MR
 capable
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-611-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

If a peer has discovery disabled then it will not consolidate peer
NI information. This means we need to use a consistent source NI
when sending to it just like we do for non-MR peers.

A comment in lnet_discovery_event_reply() indicates that this was a
known issue, but the situation is not handled properly.

Do not assume peers are multi-rail capable when peer objects are
allocated and initialized.

Do not mark a peer as multi-rail capable unless all of the following
conditions are satisified:
1. The peer has the MR feature flag set
2. The peer has discovery enabled.
3. We have discovery enabled locally

Note: 1, 2, and 3 above are implemented in the code for
lnet_discovery_event_reply(), but code earlier in the function breaks
this behavior. Remove the offending code.

Update sanity-lnet tests 100 and 101 to reflect the fact that peers
added via the traffic path no longer have multi-rail by default.

Cray-bug-id: LUS-7918
WC-bug-id: https://jira.whamcloud.com/browse/LU-12889
Lustre-commit: 3c580c93b8d3 ("LU-12889 lnet: Do not assume peers are MR capable")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36512
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 45 ++++++++++++++++-----------------------------
 1 file changed, 16 insertions(+), 29 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index f987fff..0d7fbd4 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1520,10 +1520,7 @@ struct lnet_peer_net *
 	struct lnet_peer *lp;
 	struct lnet_peer_net *lpn;
 	struct lnet_peer_ni *lpni;
-	/* Assume peer is Multi-Rail capable and let discovery find out
-	 * otherwise.
-	 */
-	unsigned int flags = LNET_PEER_MULTI_RAIL;
+	unsigned int flags = 0;
 	int rc = 0;
 
 	if (nid == LNET_NID_ANY) {
@@ -2298,20 +2295,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	}
 
 	/*
-	 * Only enable the multi-rail feature on the peer if both sides of
-	 * the connection have discovery on
-	 */
-	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL) {
-		CDEBUG(D_NET, "Peer %s has Multi-Rail feature enabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
-		lp->lp_state |= LNET_PEER_MULTI_RAIL;
-	} else {
-		CDEBUG(D_NET, "Peer %s has Multi-Rail feature disabled\n",
-		       libcfs_nid2str(lp->lp_primary_nid));
-		lp->lp_state &= ~LNET_PEER_MULTI_RAIL;
-	}
-
-	/* The peer may have discovery disabled at its end. Set
+	 * The peer may have discovery disabled at its end. Set
 	 * NO_DISCOVERY as appropriate.
 	 */
 	if ((pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY) &&
@@ -2332,21 +2316,24 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	 */
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL) {
 		if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
-			/* Everything's fine */
+			CDEBUG(D_NET, "peer %s(%p) is MR\n",
+			       libcfs_nid2str(lp->lp_primary_nid), lp);
 		} else if (lp->lp_state & LNET_PEER_CONFIGURED) {
 			CWARN("Reply says %s is Multi-Rail, DLC says not\n",
 			      libcfs_nid2str(lp->lp_primary_nid));
+		} else if (lnet_peer_discovery_disabled) {
+			CDEBUG(D_NET,
+			       "peer %s(%p) not MR: DD disabled locally\n",
+			       libcfs_nid2str(lp->lp_primary_nid), lp);
+		} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
+			CDEBUG(D_NET,
+			       "peer %s(%p) not MR: DD disabled remotely\n",
+			       libcfs_nid2str(lp->lp_primary_nid), lp);
 		} else {
-			/* if discovery is disabled then we don't want to
-			 * update the state of the peer. All we'll do is
-			 * update the peer_nis which were reported back in
-			 * the initial ping
-			 */
-
-			if (!lnet_is_discovery_disabled_locked(lp)) {
-				lp->lp_state |= LNET_PEER_MULTI_RAIL;
-				lnet_peer_clr_non_mr_pref_nids(lp);
-			}
+			CDEBUG(D_NET, "peer %s(%p) is MR capable\n",
+			       libcfs_nid2str(lp->lp_primary_nid), lp);
+			lp->lp_state |= LNET_PEER_MULTI_RAIL;
+			lnet_peer_clr_non_mr_pref_nids(lp);
 		}
 	} else if (lp->lp_state & LNET_PEER_MULTI_RAIL) {
 		if (lp->lp_state & LNET_PEER_CONFIGURED) {
-- 
1.8.3.1
