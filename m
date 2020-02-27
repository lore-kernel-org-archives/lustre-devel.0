From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:15 -0500
Subject: [lustre-devel] [PATCH 087/622] lnet: remove duplicate timeout
 mechanism
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-88-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Remove the duplicate GET/PUT timeout mechanism currently implemented
for discovery, as it has been replaced by a more generic timeout
mechanism for all GET/PUT messages.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 0b1947d14188 ("LU-9120 lnet: remove duplicate timeout mechanism")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32992
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 39 ---------------------------------------
 1 file changed, 39 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 4a62f9a..ca9b90b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2925,25 +2925,6 @@ static int lnet_peer_rediscover(struct lnet_peer *lp)
 }
 
 /*
- * Returns the first peer on the ln_dc_working queue if its timeout
- * has expired. Takes the current time as an argument so as to not
- * obsessively re-check the clock. The oldest discovery request will
- * be at the head of the queue.
- */
-static struct lnet_peer *lnet_peer_get_dc_timed_out(time64_t now)
-{
-	struct lnet_peer *lp;
-
-	if (list_empty(&the_lnet.ln_dc_working))
-		return NULL;
-	lp = list_first_entry(&the_lnet.ln_dc_working,
-			      struct lnet_peer, lp_dc_list);
-	if (now < lp->lp_last_queued + lnet_transaction_timeout)
-		return NULL;
-	return lp;
-}
-
-/*
  * Discovering this peer is taking too long. Cancel any Ping or Push
  * that discovery is waiting on by unlinking the relevant MDs. The
  * lnet_discovery_event_handler() will proceed from here and complete
@@ -2998,8 +2979,6 @@ static int lnet_peer_discovery_wait_for_work(void)
 			break;
 		if (!list_empty(&the_lnet.ln_msg_resend))
 			break;
-		if (lnet_peer_get_dc_timed_out(ktime_get_real_seconds()))
-			break;
 		lnet_net_unlock(cpt);
 
 		/*
@@ -3068,7 +3047,6 @@ static void lnet_resend_msgs(void)
 static int lnet_peer_discovery(void *arg)
 {
 	struct lnet_peer *lp;
-	time64_t now;
 	int rc;
 
 	CDEBUG(D_NET, "started\n");
@@ -3159,23 +3137,6 @@ static int lnet_peer_discovery(void *arg)
 				break;
 		}
 
-		/*
-		 * Now that the ln_dc_request queue has been emptied
-		 * check the ln_dc_working queue for peers that are
-		 * taking too long. Move all that are found to the
-		 * ln_dc_expired queue and time out any pending
-		 * Ping or Push. We have to drop the lnet_net_lock
-		 * in the loop because lnet_peer_cancel_discovery()
-		 * calls LNetMDUnlink().
-		 */
-		now = ktime_get_real_seconds();
-		while ((lp = lnet_peer_get_dc_timed_out(now)) != NULL) {
-			list_move(&lp->lp_dc_list, &the_lnet.ln_dc_expired);
-			lnet_net_unlock(LNET_LOCK_EX);
-			lnet_peer_cancel_discovery(lp);
-			lnet_net_lock(LNET_LOCK_EX);
-		}
-
 		lnet_net_unlock(LNET_LOCK_EX);
 	}
 
-- 
1.8.3.1
