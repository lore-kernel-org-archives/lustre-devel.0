From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:46 -0500
Subject: [lustre-devel] [PATCH 03/27] staging: lustre: Ignore hops if not
	explicitly set
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

Since the # of hops is not a mandatory parameter the LU-6060
patch will cause problems to already existing systems since it
changes the behavior by which a route is determined down.

To fix this case the # of hops now defaults to LNET_UNDEFINED_HOPS
if no hop count is specified.

LNET_UNDEFINED_HOPS is defined to ((__u32)-1). When it's printed as
%d, it displays as -1.

__u32 is used through out the call stack for hop count to explicitly
define the size of the hop count and to avoid any sizing issues when
passing data to and from the kernel.

To keep existing behavior both lnet_compare_routes() and LNetDist()
will treat undefined hop count as hop count 1.

When executing the logic in lnet_parse_rc_info() there is no
longer an assumption that the default hop count is 1. If
the hop count is 1 then it must've been explicitly set by
the user.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6851
Reviewed-on: http://review.whamcloud.com/15719
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 drivers/staging/lustre/lnet/lnet/config.c          |    8 ++++++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   17 +++++++++++++----
 drivers/staging/lustre/lnet/lnet/router.c          |    6 +++---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 6 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index d78360d..84642dc 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -456,7 +456,7 @@ void lnet_lib_exit(void);
 int lnet_notify(lnet_ni_t *ni, lnet_nid_t peer, int alive, unsigned long when);
 void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
 			unsigned long when);
-int lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway_nid,
+int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
 		   unsigned int priority);
 int lnet_check_routes(void);
 int lnet_del_route(__u32 net, lnet_nid_t gw_nid);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 07b8db1..d2513db 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -371,7 +371,7 @@ typedef struct {
 	__u32			 lr_net;	/* remote network number */
 	int			 lr_seq;	/* sequence for round-robin */
 	unsigned int		 lr_downis;	/* number of down NIs */
-	unsigned int		 lr_hops;	/* how far I am */
+	__u32			 lr_hops;	/* how far I am */
 	unsigned int             lr_priority;	/* route priority */
 } lnet_route_t;
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 8c80625..4c40acb 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -664,7 +664,7 @@ lnet_parse_route(char *str, int *im_a_router)
 	char *token = str;
 	int ntokens = 0;
 	int myrc = -1;
-	unsigned int hops;
+	__u32 hops;
 	int got_hops = 0;
 	unsigned int priority = 0;
 
@@ -747,8 +747,12 @@ lnet_parse_route(char *str, int *im_a_router)
 		}
 	}
 
+	/**
+	 * if there are no hops set then we want to flag this value as
+	 * unset since hops is an optional parameter
+	 */
 	if (!got_hops)
-		hops = 1;
+		hops = LNET_UNDEFINED_HOPS;
 
 	LASSERT(!list_empty(&nets));
 	LASSERT(!list_empty(&gateways));
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index fa5b7cd..8a21198 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1160,6 +1160,8 @@ lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
 {
 	lnet_peer_t *p1 = r1->lr_gateway;
 	lnet_peer_t *p2 = r2->lr_gateway;
+	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
+	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
 
 	if (r1->lr_priority < r2->lr_priority)
 		return 1;
@@ -1167,10 +1169,10 @@ lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
 	if (r1->lr_priority > r2->lr_priority)
 		return -1;
 
-	if (r1->lr_hops < r2->lr_hops)
+	if (r1_hops < r2_hops)
 		return 1;
 
-	if (r1->lr_hops > r2->lr_hops)
+	if (r1_hops > r2_hops)
 		return -1;
 
 	if (p1->lp_txqnob < p2->lp_txqnob)
@@ -2512,18 +2514,25 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 		if (rnet->lrn_net == dstnet) {
 			lnet_route_t *route;
 			lnet_route_t *shortest = NULL;
+			__u32 shortest_hops = LNET_UNDEFINED_HOPS;
+			__u32 route_hops;
 
 			LASSERT(!list_empty(&rnet->lrn_routes));
 
 			list_for_each_entry(route, &rnet->lrn_routes,
 					    lr_list) {
+				route_hops = route->lr_hops;
+				if (route_hops == LNET_UNDEFINED_HOPS)
+					route_hops = 1;
 				if (!shortest ||
-				    route->lr_hops < shortest->lr_hops)
+				    route_hops < shortest_hops) {
 					shortest = route;
+					shortest_hops = route_hops;
+				}
 			}
 
 			LASSERT(shortest);
-			hops = shortest->lr_hops;
+			hops = shortest_hops;
 			if (srcnidp)
 				*srcnidp = shortest->lr_gateway->lp_ni->ni_nid;
 			if (orderp)
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 2eae8f6..51a831e 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -294,7 +294,7 @@ lnet_add_route_to_rnet(lnet_remotenet_t *rnet, lnet_route_t *route)
 }
 
 int
-lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
+lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 	       unsigned int priority)
 {
 	struct list_head *e;
@@ -305,7 +305,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	int add_route;
 	int rc;
 
-	CDEBUG(D_NET, "Add route: net %s hops %u priority %u gw %s\n",
+	CDEBUG(D_NET, "Add route: net %s hops %d priority %u gw %s\n",
 	       libcfs_net2str(net), hops, priority, libcfs_nid2str(gateway));
 
 	if (gateway == LNET_NID_ANY ||
@@ -313,7 +313,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	    net == LNET_NIDNET(LNET_NID_ANY) ||
 	    LNET_NETTYP(net) == LOLND ||
 	    LNET_NIDNET(gateway) == net ||
-	    hops < 1 || hops > 255)
+	    (hops != LNET_UNDEFINED_HOPS && (hops < 1 || hops > 255)))
 		return -EINVAL;
 
 	if (lnet_islocalnet(net))	       /* it's a local network */
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index fc643df..ce4331e 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -235,7 +235,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 
 		if (route) {
 			__u32 net = rnet->lrn_net;
-			unsigned int hops = route->lr_hops;
+			__u32 hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
 			lnet_nid_t nid = route->lr_gateway->lp_nid;
 			int alive = lnet_is_route_alive(route);
-- 
1.7.1
