From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:52 -0400
Subject: [lustre-devel] [PATCH 12/18] lnet: Skip health and resends for
 single rail configs
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

If the sender of a message only has a single interface it doesn't
make sense to have LNet track the health of that interface, nor
should it attempt to resend a message when it encounters a local
error. There aren't any alternative interfaces to use for a resend.

Similarly, we needn't track health values of a peer's NIs if the peer
only has a single interface. Nor do we need to attempt to resend
a message to a peer with a single interface. There's an exception for
routers. We rely on NI health to determine route aliveness, so even
if a router only has a single interface we still need to track its
health.

We can use the ln_ping_target to get the count of local NIs, and the
lnet_peer struct already contains a count of the number of peer NIs.

HPE-bug-id: LUS-8826
WC-bug-id: https://jira.whamcloud.com/browse/LU-13501
Lustre-commit: c5381d73b1d83 ("LU-13501 lnet: Skip health and resends for single rail configs")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38448
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-msg.c | 65 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 46 insertions(+), 19 deletions(-)

diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 7ce9c47..f759b2d 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -774,6 +774,10 @@
 	struct lnet_peer_ni *lpni;
 	struct lnet_ni *ni;
 	bool lo = false;
+	bool attempt_local_resend;
+	bool attempt_remote_resend;
+	bool handle_local_health;
+	bool handle_remote_health;
 
 	/* if we're shutting down no point in handling health. */
 	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
@@ -800,9 +804,45 @@
 	if (msg->msg_tx_committed) {
 		ni = msg->msg_txni;
 		lpni = msg->msg_txpeer;
+		attempt_local_resend = true;
+		attempt_remote_resend = true;
 	} else {
 		ni = msg->msg_rxni;
 		lpni = msg->msg_rxpeer;
+		attempt_local_resend = false;
+		attempt_remote_resend = false;
+	}
+
+	/* Don't further decrement the health value if a recovery message
+	 * failed.
+	 */
+	if (msg->msg_recovery) {
+		handle_local_health = false;
+		handle_remote_health = false;
+	} else {
+		handle_local_health = false;
+		handle_remote_health = true;
+	}
+
+	/* For local failures, health/recovery/resends are not needed if I only
+	 * have a single (non-lolnd) interface. NB: pb_nnis includes the lolnd
+	 * interface, so a single-rail node would have pb_nnis == 2.
+	 */
+	if (the_lnet.ln_ping_target->pb_nnis <= 2) {
+		handle_local_health = false;
+		attempt_local_resend = false;
+	}
+
+	/* For remote failures, health/recovery/resends are not needed if the
+	 * peer only has a single interface. Special case for routers where we
+	 * rely on health feature to manage route aliveness. NB: unlike pb_nnis
+	 * above, lp_nnis does _not_ include the lolnd, so a single-rail node
+	 * would have lp_nnis == 1.
+	 */
+	if (lpni && lpni->lpni_peer_net->lpn_peer->lp_nnis <= 1) {
+		attempt_remote_resend = false;
+		if (!lnet_isrouter(lpni))
+			handle_remote_health = false;
 	}
 
 	if (!lo)
@@ -865,41 +905,28 @@
 	case LNET_MSG_STATUS_LOCAL_ABORTED:
 	case LNET_MSG_STATUS_LOCAL_NO_ROUTE:
 	case LNET_MSG_STATUS_LOCAL_TIMEOUT:
-		/* don't further decrement the health value if the
-		 * recovery message failed.
-		 */
-		if (!msg->msg_recovery)
+		if (handle_local_health)
 			lnet_handle_local_failure(ni);
-		if (msg->msg_tx_committed)
-			/* add to the re-send queue */
+		if (attempt_local_resend)
 			return lnet_attempt_msg_resend(msg);
 		break;
 
-	/* These errors will not trigger a resend so simply
-	 * finalize the message
-	 */
 	case LNET_MSG_STATUS_LOCAL_ERROR:
-		/* don't further decrement the health value if the
-		 * recovery message failed.
-		 */
-		if (!msg->msg_recovery)
+		if (handle_local_health)
 			lnet_handle_local_failure(ni);
 		return -1;
 
-	/* TODO: since the remote dropped the message we can
-	 * attempt a resend safely.
-	 */
 	case LNET_MSG_STATUS_REMOTE_DROPPED:
-		if (!msg->msg_recovery)
+		if (handle_remote_health)
 			lnet_handle_remote_failure(lpni);
-		if (msg->msg_tx_committed)
+		if (attempt_remote_resend)
 			return lnet_attempt_msg_resend(msg);
 		break;
 
 	case LNET_MSG_STATUS_REMOTE_ERROR:
 	case LNET_MSG_STATUS_REMOTE_TIMEOUT:
 	case LNET_MSG_STATUS_NETWORK_TIMEOUT:
-		if (!msg->msg_recovery)
+		if (handle_remote_health)
 			lnet_handle_remote_failure(lpni);
 		return -1;
 	default:
-- 
1.8.3.1
