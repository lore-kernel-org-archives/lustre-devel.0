From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:17 -0400
Subject: [lustre-devel] [PATCH 21/23] lnet: Clear lp_dc_error when discovery
 completes
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

If discovery completes successfully then we can clear the
lp_dc_error.

HPE-bug-id: LUS-9081
WC-bug-id: https://jira.whamcloud.com/browse/LU-13764
Lustre-commit: d3fa46705225f ("LU-13764 lnet: Clear lp_dc_error when discovery completes")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39348
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 81f908e..5ca6f68 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3058,6 +3058,8 @@ static int lnet_peer_discovered(struct lnet_peer *lp)
 	lp->lp_state &= ~(LNET_PEER_DISCOVERING |
 			  LNET_PEER_REDISCOVER);
 
+	lp->lp_dc_error = 0;
+
 	CDEBUG(D_NET, "peer %s\n", libcfs_nid2str(lp->lp_primary_nid));
 
 	return 0;
-- 
1.8.3.1
