From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:52 -0400
Subject: [lustre-devel] [PATCH 13/22] lnet: handle discovery off properly
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Peers need to only be updated when discovery is toggled from
on to off. This way the peers don't attempt to send to a
non-primary NID of the node. However, when discovery is
toggled from off to on, the peer will attempt rediscovery
and the peer information will eventually consolidate.

In order to properly delete the peer only when it makes sense
we have to differentiate between the case when we get the
initial message and when we get a push for an already discovered
peer. We only want to delete our local representation if the peer
is one we have already had in our records.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13478
Lustre-commit: adae4295b62b1 ("LU-13478 lnet: handle discovery off properly")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38321
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 26 +++++++-------------------
 net/lnet/lnet/peer.c   | 12 ++++++++----
 2 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 6f19e63..a966e64 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -270,7 +270,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 discovery_set(const char *val, const struct kernel_param *kp)
 {
 	int rc;
-	unsigned int *discovery = (unsigned int *)kp->arg;
+	unsigned int *discovery_off = (unsigned int *)kp->arg;
 	unsigned long value;
 	struct lnet_ping_buffer *pbuf;
 
@@ -288,7 +288,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 */
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	if (value == *discovery) {
+	if (value == *discovery_off) {
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return 0;
 	}
@@ -300,7 +300,7 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 	 * updating the peers
 	 */
 	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN) {
-		*discovery = value;
+		*discovery_off = value;
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return 0;
 	}
@@ -314,22 +314,10 @@ static int lnet_discover(struct lnet_process_id id, u32 force,
 		pbuf->pb_info.pi_features |= LNET_PING_FEAT_DISCOVERY;
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	/* Always update the peers. This will result in a push to the
-	 * peers with the updated capabilities feature mask. The peer can
-	 * then take appropriate action to update its representation of
-	 * the node.
-	 *
-	 * If discovery is already off, turn it on first before pushing
-	 * the update. The discovery flag must be on before pushing.
-	 * otherwise if the flag is on and we're turning it off then push
-	 * first before turning the flag off. In the former case the flag
-	 * is being set twice, but I find it's better to do that rather
-	 * than have duplicate code in an if/else statement.
-	 */
-	if (*discovery > 0 && value == 0)
-		*discovery = value;
-	lnet_push_update_to_peers(1);
-	*discovery = value;
+	/* only send a push when we're turning off discovery */
+	if (*discovery_off <= 0 && value > 0)
+		lnet_push_update_to_peers(1);
+	*discovery_off = value;
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b2065bd..60749da 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2018,13 +2018,17 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_DISCOVERY)) {
 		CDEBUG(D_NET, "Peer %s has discovery disabled\n",
 		       libcfs_nid2str(lp->lp_primary_nid));
-		/* If the peer is going from discovery enabled to
-		 * discovery disabled, we need to reflect that in our
-		 * representation of the peer.
+		/* Mark the peer for deletion if we already know about it
+		 * and it's going from discovery set to no discovery set
 		 */
 		if (!(lp->lp_state & (LNET_PEER_NO_DISCOVERY |
-				      LNET_PEER_DISCOVERING)))
+				      LNET_PEER_DISCOVERING)) &&
+		    lp->lp_state & LNET_PEER_DISCOVERED) {
+			CDEBUG(D_NET, "Marking %s:0x%x for deletion\n",
+			       libcfs_nid2str(lp->lp_primary_nid),
+			       lp->lp_state);
 			lp->lp_state |= LNET_PEER_MARK_DELETION;
+		}
 		lp->lp_state |= LNET_PEER_NO_DISCOVERY;
 	} else if (lp->lp_state & LNET_PEER_NO_DISCOVERY) {
 		CDEBUG(D_NET, "Peer %s has discovery enabled\n",
-- 
1.8.3.1
