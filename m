From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:05 -0400
Subject: [lustre-devel] [PATCH 106/151] lnet: ensure peer put back on dc
 request queue
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-107-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Upon async PUT request received from peer already in discovery
process, lnet_peer_push_event() was not handling the case where
peer could be on working/ln_dc_working queue. This could lead
for peer not to be re-dsicovered as expected, but left on
working queue and to be finally timed-out.

Also ensure that peer will not be put back on request queue by
event handler if discovery is already completed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10123
Lustre-commit: d0185dd43394 ("LU-10123 lnet: ensure peer put back on dc request queue")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/30147
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 52d4ec0..e2f8c28 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1983,13 +1983,16 @@ void lnet_peer_push_event(struct lnet_event *ev)
 
 out:
 	/*
-	 * Queue the peer for discovery, and wake the discovery thread
-	 * if the peer was already queued, because its status changed.
+	 * Queue the peer for discovery if not done, force it on the request
+	 * queue and wake the discovery thread if the peer was already queued,
+	 * because its status changed.
 	 */
 	spin_unlock(&lp->lp_lock);
 	lnet_net_lock(LNET_LOCK_EX);
-	if (lnet_peer_queue_for_discovery(lp))
+	if (!lnet_peer_is_uptodate(lp) && lnet_peer_queue_for_discovery(lp)) {
+		list_move(&lp->lp_dc_list, &the_lnet.ln_dc_request);
 		wake_up(&the_lnet.ln_dc_waitq);
+	}
 	/* Drop refcount from lookup */
 	lnet_peer_decref_locked(lp);
 	lnet_net_unlock(LNET_LOCK_EX);
@@ -2348,7 +2351,11 @@ static void lnet_discovery_event_handler(struct lnet_event *event)
 		lnet_ping_buffer_decref(pbuf);
 		lnet_peer_decref_locked(lp);
 	}
-	if (rc == LNET_REDISCOVER_PEER) {
+
+	/* Put peer back at end of request queue, if discovery not already
+	 * done
+	 */
+	if (rc == LNET_REDISCOVER_PEER && !lnet_peer_is_uptodate(lp)) {
 		list_move_tail(&lp->lp_dc_list, &the_lnet.ln_dc_request);
 		wake_up(&the_lnet.ln_dc_waitq);
 	}
-- 
1.8.3.1
