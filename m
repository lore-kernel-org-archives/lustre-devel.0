From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:08 -0500
Subject: [lustre-devel] [PATCH 380/622] lnet: use after free in
 lnet_discover_peer_locked()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-381-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf.weber@hpe.com>

When the lnet_net_lock is unlocked, the peer attached to an
lnet_peer_ni (found via lnet_peer_ni::lpni_peer_net->lpn_peer)
can change, and the old peer deallocated. If we are really
unlucky, then all the churn could give us a new, different,
peer at the same address in memory.

Change the reference counting on the lnet_peer lp so that it
is guaranteed to be alive when we relock the lnet_net_lock for
the cpt. When the reference count is dropped lp may go away if
it was unlinked, but the new peer is guaranteed to have a
different address, so we can still correctly determine whether
the peer changed and discovery should be redone.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9971
Lustre-commit: 2b5b551b15d9 ("LU-9971 lnet: use after free in lnet_discover_peer_locked()")
Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-on: https://review.whamcloud.com/28944
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index e5cce2f..d167a37 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2150,6 +2150,8 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	 * zombie if we race with DLC, so we must check for that.
 	 */
 	for (;;) {
+		/* Keep lp alive when the lnet_net_lock is unlocked */
+		lnet_peer_addref_locked(lp);
 		prepare_to_wait(&lp->lp_dc_waitq, &wait, TASK_INTERRUPTIBLE);
 		if (signal_pending(current))
 			break;
@@ -2161,16 +2163,14 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 			break;
 		lnet_peer_queue_for_discovery(lp);
 
-		/*
-		 * if caller requested a non-blocking operation then
-		 * return immediately. Once discovery is complete then the
-		 * peer ref will be decremented and any pending messages
-		 * that were stopped due to discovery will be transmitted.
+		/* If caller requested a non-blocking operation then
+		 * return immediately. Once discovery is complete any
+		 * pending messages that were stopped due to discovery
+		 * will be transmitted.
 		 */
 		if (!block)
 			break;
 
-		lnet_peer_addref_locked(lp);
 		lnet_net_unlock(LNET_LOCK_EX);
 		schedule();
 		finish_wait(&lp->lp_dc_waitq, &wait);
@@ -2192,10 +2192,12 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 
 	lnet_net_unlock(LNET_LOCK_EX);
 	lnet_net_lock(cpt);
-
-	/* If the peer has changed after we've discovered the older peer,
-	 * then we need to discovery the new peer to make sure the
-	 * interface information is up to date
+	lnet_peer_decref_locked(lp);
+	/* The peer may have changed, so re-check and rediscover if that turns
+	 * out to have been the case. The reference count on lp ensured that
+	 * even if it was unlinked from lpni the memory could not be recycled.
+	 * Thus the check below is sufficient to determine whether the peer
+	 * changed. If the peer changed, then lp must not be dereferenced.
 	 */
 	if (lp != lpni->lpni_peer_net->lpn_peer)
 		goto again;
-- 
1.8.3.1
