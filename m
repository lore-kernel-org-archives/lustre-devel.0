From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:46 -0500
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: reflect down routes
	in /proc/sys/lnet/routes
In-Reply-To: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
References: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455549954-29532-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Chris Horn <hornc@cray.com>

From: Chris Horn <hornc@cray.com>

We consider routes "down" if the router is down or the router
NI for the target network is down. This should be reflected
in the output of /proc/sys/lnet/routes

Signed-off-by: Chris Horn <hornc@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3679
Reviewed-on: http://review.whamcloud.com/7857
Reviewed-by: Cory Spitz <spitzcor@cray.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   13 +++++++++++++
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 +---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index b0f80b4..b2e5017 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -64,6 +64,19 @@ extern lnet_t	the_lnet;	/* THE network */
 /** exclusive lock */
 #define LNET_LOCK_EX		CFS_PERCPT_LOCK_EX
 
+static inline int lnet_is_route_alive(lnet_route_t *route)
+{
+	/* gateway is down */
+	if (!route->lr_gateway->lp_alive)
+		return 0;
+	/* no NI status, assume it's alive */
+	if ((route->lr_gateway->lp_ping_feats &
+	     LNET_PING_FEAT_NI_STATUS) == 0)
+		return 1;
+	/* has NI status, check # down NIs */
+	return route->lr_downis == 0;
+}
+
 static inline int lnet_is_wire_handle_none(lnet_handle_wire_t *wh)
 {
 	return (wh->wh_interface_cookie == LNET_WIRE_HANDLE_COOKIE_NONE &&
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f023b0c..ab56e7f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1156,9 +1156,7 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 	list_for_each_entry(route, &rnet->lrn_routes, lr_list) {
 		lp = route->lr_gateway;
 
-		if (!lp->lp_alive || /* gateway is down */
-		    ((lp->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) &&
-		     route->lr_downis)) /* NI to target is down */
+		if (!lnet_is_route_alive(route))
 			continue;
 
 		if (ni && lp->lp_ni != ni)
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index a7aaf0c..4148caf 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -242,7 +242,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			unsigned int hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
 			lnet_nid_t nid = route->lr_gateway->lp_nid;
-			int alive = route->lr_gateway->lp_alive;
+			int alive = lnet_is_route_alive(route);
 
 			s += snprintf(s, tmpstr + tmpsiz - s,
 				      "%-8s %4u %8u %7s %s\n",
-- 
1.7.1
