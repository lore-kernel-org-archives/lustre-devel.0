From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:14 -0400
Subject: [lustre-devel] [PATCH 33/37] lnet: Set remote NI status in
 lnet_notify
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

The gnilnd receives node health information asynchronous from any tx
failure, so aliveness of lpni as reported by lnet_is_peer_ni_alive()
may not match what LND is telling us. Use existing reset flag to
set cached NI status down so we can be sure that remote NIs are
correctly set down.

HPE-bug-id: LUS-8897
WC-bug-id: https://jira.whamcloud.com/browse/LU-13648
Lustre-commit: 8010dbb660766 ("LU-13648 lnet: Set remote NI status in lnet_notify")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/38862
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index c0578d9..e3b3e71 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1671,8 +1671,7 @@ bool lnet_router_checker_active(void)
 
 	CDEBUG(D_NET, "%s notifying %s: %s\n",
 	       !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
-	       libcfs_nid2str(nid),
-	       alive ? "up" : "down");
+	       libcfs_nid2str(nid), alive ? "up" : "down");
 
 	if (ni &&
 	    LNET_NIDNET(ni->ni_nid) != LNET_NIDNET(nid)) {
@@ -1714,6 +1713,7 @@ bool lnet_router_checker_active(void)
 
 	if (alive) {
 		if (reset) {
+			lpni->lpni_ns_status = LNET_NI_STATUS_UP;
 			lnet_set_lpni_healthv_locked(lpni,
 						     LNET_MAX_HEALTH_VALUE);
 		} else {
@@ -1726,6 +1726,8 @@ bool lnet_router_checker_active(void)
 						     (sensitivity) ? sensitivity :
 						     lnet_health_sensitivity);
 		}
+	} else if (reset) {
+		lpni->lpni_ns_status = LNET_NI_STATUS_DOWN;
 	}
 
 	/* recalculate aliveness */
-- 
1.8.3.1
