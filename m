From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:28 -0500
Subject: [lustre-devel] [PATCH 400/622] lnet: warn if discovery is off
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-401-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Output a warning if discovery is off and admin is
either trying to add a route or enable routing

WC-bug-id: https://jira.whamcloud.com/browse/LU-12427
Lustre-commit: c9718be06192 ("LU-12427 lnet: warn if discovery is off")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35200
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index f7b53e0..eb76c72 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -519,6 +519,8 @@ static void lnet_shuffle_seed(void)
 	if (add_route) {
 		gw->lp_health_sensitivity = sensitivity;
 		lnet_add_route_to_rnet(rnet2, route);
+		if (lnet_peer_discovery_disabled)
+			CWARN("Consider turning discovery on to enable full Multi-Rail routing functionality\n");
 	}
 
 	/* get rid of the reference on the lpni.
@@ -1379,6 +1381,9 @@ bool lnet_router_checker_active(void)
 		~LNET_PING_FEAT_RTE_DISABLED;
 	lnet_net_unlock(LNET_LOCK_EX);
 
+	if (lnet_peer_discovery_disabled)
+		CWARN("Consider turning discovery on to enable full Multi-Rail routing functionality\n");
+
 	return rc;
 }
 
-- 
1.8.3.1
