From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:10 -0500
Subject: [lustre-devel] [PATCH 382/622] lnet: fix peer ref counting
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-383-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Exit from the loop after peer ref count has been incremented
to avoid wrong ref count.

The code makes sure that a peer is queued for discovery at most
once if discovery is disabled. This is done to use discovery
as a standard ping for gateways which do not have discovery feature
or discovery is disabled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9971
Lustre-commit: dbcddb4824f0 ("LU-9971 lnet: fix peer ref counting")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35446
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index d167a37..e33dc0e 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2138,6 +2138,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	DEFINE_WAIT(wait);
 	struct lnet_peer *lp;
 	int rc = 0;
+	int count = 0;
 
 again:
 	lnet_net_unlock(cpt);
@@ -2157,11 +2158,20 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 			break;
 		if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
 			break;
+		/* Don't repeat discovery if discovery is disabled. This is
+		 * done to ensure we can use discovery as a standard ping as
+		 * well for backwards compatibility with routers which do not
+		 * have discovery or have discovery disabled
+		 */
+		if (lnet_is_discovery_disabled(lp) && count > 0)
+			break;
 		if (lp->lp_dc_error)
 			break;
 		if (lnet_peer_is_uptodate(lp))
 			break;
 		lnet_peer_queue_for_discovery(lp);
+		count++;
+		CDEBUG(D_NET, "Discovery attempt # %d\n", count);
 
 		/* If caller requested a non-blocking operation then
 		 * return immediately. Once discovery is complete any
@@ -2178,15 +2188,6 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		lnet_peer_decref_locked(lp);
 		/* Peer may have changed */
 		lp = lpni->lpni_peer_net->lpn_peer;
-
-		/* Wait for discovery to complete, but don't repeat if
-		 * discovery is disabled. This is done to ensure we can
-		 * use discovery as a standard ping as well for backwards
-		 * compatibility with routers which do not have discovery
-		 * or have discovery disabled
-		 */
-		if (lnet_is_discovery_disabled(lp))
-			break;
 	}
 	finish_wait(&lp->lp_dc_waitq, &wait);
 
-- 
1.8.3.1
