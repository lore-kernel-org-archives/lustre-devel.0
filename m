From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:53 -0500
Subject: [lustre-devel] [PATCH 545/622] lnet: Wait for single discovery
 attempt of routers
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-546-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Historically, check_routers_before_use would cause LNet
initialization to pause until all routers had been ping'd once.

This behavior was changed in commit
fe17e9b8370affe063769b880f02b9190584baaa from LU-11298. Now, LNet
will wait indefinitely until discovery completes on all routers.
This is problematic, because if even one router is down then LNet
will stall forever.

Introduce a new lnet_peer state to indicate whether a router has
been discovered (either successfully or not) to restore the historic
behavior.

Fixes fe17e9b8370a ("LU-11298 lnet: use peer for gateway")

Cray-bug-id: LUS-8184
WC-bug-id: https://jira.whamcloud.com/browse/LU-13001
Lustre-commit: d45a032d9a5c ("LU-13001 lnet: Wait for single discovery attempt of routers")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36820
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 2 ++
 net/lnet/lnet/router.c         | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 51cc9ce..4b110eb 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -732,6 +732,8 @@ struct lnet_peer {
 
 /* gw undergoing alive discovery */
 #define LNET_PEER_RTR_DISCOVERY	BIT(16)
+/* gw has undergone discovery (does not indicate success or failure) */
+#define LNET_PEER_RTR_DISCOVERED BIT(17)
 
 struct lnet_peer_net {
 	/* chain on lp_peer_nets */
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 41d0eb0..71ba951 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -408,6 +408,7 @@ bool lnet_is_route_alive(struct lnet_route *route)
 
 	spin_lock(&lp->lp_lock);
 	lp->lp_state &= ~LNET_PEER_RTR_DISCOVERY;
+	lp->lp_state |= LNET_PEER_RTR_DISCOVERED;
 	spin_unlock(&lp->lp_lock);
 
 	/* Router discovery successful? All peer information would've been
@@ -882,7 +883,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 		list_for_each_entry(rtr, &the_lnet.ln_routers, lp_rtr_list) {
 			spin_lock(&rtr->lp_lock);
 
-			if (!(rtr->lp_state & LNET_PEER_DISCOVERED)) {
+			if (!(rtr->lp_state & LNET_PEER_RTR_DISCOVERED)) {
 				all_known = 0;
 				spin_unlock(&rtr->lp_lock);
 				break;
-- 
1.8.3.1
