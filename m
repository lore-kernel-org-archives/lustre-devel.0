From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:09 -0500
Subject: [lustre-devel] [PATCH 08/24] staging: lustre: return appropriate
	errno when adding route
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

When adding route it ignored specific scenarios, namely:
1. route already exists
2. route is on a local net
3. route is unreacheable

This patch returns the appropriate return codes from the lower level
function lnet_add_route(), and then ignores the above case from the
calling function, lnet_parse_route().  This is needed so we don't
halt processing routes in the module parameters.

However, we can now add routes dynamically, and it should be returned
to the user whether adding the requested route succeeded or failed.

In userspace it is determined whether to continue adding routes or to
halt processing.  Currently "lnetctl import < config" continues
adding the rest of the configuration and reports at the end which
operations passed and which ones failed.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6045
Reviewed-on: http://review.whamcloud.com/13116
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/config.c |    2 +-
 drivers/staging/lustre/lnet/lnet/router.c |   11 +++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index c04a0ef..8c80625 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -769,7 +769,7 @@ lnet_parse_route(char *str, int *im_a_router)
 			}
 
 			rc = lnet_add_route(net, hops, nid, priority);
-			if (rc) {
+			if (rc && rc != -EEXIST && rc != -EHOSTUNREACH) {
 				CERROR("Can't create route to %s via %s\n",
 				       libcfs_net2str(net),
 				       libcfs_nid2str(nid));
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index d748931..511e446 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -317,7 +317,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 		return -EINVAL;
 
 	if (lnet_islocalnet(net))	       /* it's a local network */
-		return 0;		       /* ignore the route entry */
+		return -EEXIST;
 
 	/* Assume net, route, all new */
 	LIBCFS_ALLOC(route, sizeof(*route));
@@ -348,7 +348,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 		LIBCFS_FREE(rnet, sizeof(*rnet));
 
 		if (rc == -EHOSTUNREACH) /* gateway is not on a local net */
-			return 0;	/* ignore the route entry */
+			return rc;	/* ignore the route entry */
 		CERROR("Error %d creating route %s %d %s\n", rc,
 		       libcfs_net2str(net), hops,
 		       libcfs_nid2str(gateway));
@@ -395,14 +395,17 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	/* -1 for notify or !add_route */
 	lnet_peer_decref_locked(route->lr_gateway);
 	lnet_net_unlock(LNET_LOCK_EX);
+	rc = 0;
 
-	if (!add_route)
+	if (!add_route) {
+		rc = -EEXIST;
 		LIBCFS_FREE(route, sizeof(*route));
+	}
 
 	if (rnet != rnet2)
 		LIBCFS_FREE(rnet, sizeof(*rnet));
 
-	return 0;
+	return rc;
 }
 
 int
-- 
1.7.1
