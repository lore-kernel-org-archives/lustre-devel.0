From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:51 -0400
Subject: [lustre-devel] [PATCH 032/151] lnet: rediscover peer if it changed
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If the peer has changed after we unlocked the cpt then
we'll need to discover the new peer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9917
Lustre-commit: 1fc4ed3ac40a ("LU-9917 lnet: rediscover peer if it changed")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28772
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index ade7f23..34e61f8 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2034,6 +2034,13 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 	lnet_net_unlock(LNET_LOCK_EX);
 	lnet_net_lock(cpt);
 
+	/* If the peer has changed after we've discovered the older peer,
+	 * then we need to discovery the new peer to make sure the
+	 * interface information is up to date
+	 */
+	if (lp != lpni->lpni_peer_net->lpn_peer)
+		goto again;
+
 	if (signal_pending(current))
 		rc = -EINTR;
 	else if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING)
-- 
1.8.3.1
