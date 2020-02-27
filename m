From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:55 -0500
Subject: [lustre-devel] [PATCH 367/622] lnet: Do not allow gateways on
 remote nets
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-368-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

A gateway needs to be reachable over some local interface.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12411
Lustre-commit: 43b35351e9ca ("LU-12411 lnet: Do not allow gateways on remote nets")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/35198
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 81f7a94..f7b53e0 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -436,6 +436,13 @@ static void lnet_shuffle_seed(void)
 	if (lnet_islocalnet(net))
 		return -EEXIST;
 
+	if (!lnet_islocalnet(LNET_NIDNET(gateway))) {
+		CERROR("Cannot add route with gateway %s. There is no local interface configured on LNet %s\n",
+		       libcfs_nid2str(gateway),
+		       libcfs_net2str(LNET_NIDNET(gateway)));
+		return -EINVAL;
+	}
+
 	/* Assume net, route, all new */
 	route = kzalloc(sizeof(*route), GFP_NOFS);
 	rnet = kzalloc(sizeof(*rnet), GFP_NOFS);
-- 
1.8.3.1
