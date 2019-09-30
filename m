From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:59 -0400
Subject: [lustre-devel] [PATCH 040/151] lnet: reduce logging severity
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

On shutdown a push event can be triggered for a
non-existent peer. Reducing the severity of the log.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9904
Lustre-commit: 7fc8037d61b2 ("LU-9904 lnet: reduce logging severity")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29026
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 1266e32..68c6eb7 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1808,7 +1808,8 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	/* lnet_find_peer() adds a refcount */
 	lp = lnet_find_peer(ev->source.nid);
 	if (!lp) {
-		CERROR("Push Put from unknown %s (source %s)\n",
+		CDEBUG(D_NET,
+		       "Push Put from unknown %s (source %s). Ignoring...\n",
 		       libcfs_nid2str(ev->initiator.nid),
 		       libcfs_nid2str(ev->source.nid));
 		return;
-- 
1.8.3.1
