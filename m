From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:41 -0500
Subject: [lustre-devel] [PATCH 16/34] staging: lustre: lnet: change
	lnet_route_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_route_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  6 ++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 12 +++++-----
 drivers/staging/lustre/lnet/lnet/router.c          | 26 ++++++++++++----------
 drivers/staging/lustre/lnet/lnet/router_proc.c     | 11 ++++-----
 5 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index bcfbed1..93e6830 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -65,7 +65,7 @@
 /** exclusive lock */
 #define LNET_LOCK_EX		CFS_PERCPT_LOCK_EX
 
-static inline int lnet_is_route_alive(lnet_route_t *route)
+static inline int lnet_is_route_alive(struct lnet_route *route)
 {
 	/* gateway is down */
 	if (!route->lr_gateway->lp_alive)
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 2cfc1bf..a0d9cad 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -340,7 +340,7 @@ struct lnet_peer {
 	lnet_nid_t		 lp_nid;	/* peer's NID */
 	int			 lp_refcount;	/* # refs */
 	int			 lp_cpt;	/* CPT this peer attached on */
-	/* # refs from lnet_route_t::lr_gateway */
+	/* # refs from lnet_route::lr_gateway */
 	int			 lp_rtr_refcount;
 	/* returned RC ping features */
 	unsigned int		 lp_ping_feats;
@@ -369,7 +369,7 @@ struct lnet_peer_table {
 #define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing && \
 					 (lp)->lp_ni->ni_peertimeout > 0)
 
-typedef struct {
+struct lnet_route {
 	struct list_head	 lr_list;	/* chain on net */
 	struct list_head	 lr_gwlist;	/* chain on gateway */
 	struct lnet_peer	*lr_gateway;	/* router node */
@@ -378,7 +378,7 @@ struct lnet_peer_table {
 	unsigned int		 lr_downis;	/* number of down NIs */
 	__u32			 lr_hops;	/* how far I am */
 	unsigned int             lr_priority;	/* route priority */
-} lnet_route_t;
+};
 
 #define LNET_REMOTE_NETS_HASH_DEFAULT	(1U << 7)
 #define LNET_REMOTE_NETS_HASH_MAX	(1U << 16)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 9615dcd..9d1ab1f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -957,7 +957,7 @@
 }
 
 static int
-lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
+lnet_compare_routes(struct lnet_route *r1, struct lnet_route *r2)
 {
 	struct lnet_peer *p1 = r1->lr_gateway;
 	struct lnet_peer *p2 = r2->lr_gateway;
@@ -999,9 +999,9 @@
 		       lnet_nid_t rtr_nid)
 {
 	lnet_remotenet_t *rnet;
-	lnet_route_t *route;
-	lnet_route_t *best_route;
-	lnet_route_t *last_route;
+	struct lnet_route *route;
+	struct lnet_route *best_route;
+	struct lnet_route *last_route;
 	struct lnet_peer *lp_best;
 	struct lnet_peer *lp;
 	int rc;
@@ -2351,8 +2351,8 @@ struct lnet_msg *
 		rnet = list_entry(e, lnet_remotenet_t, lrn_list);
 
 		if (rnet->lrn_net == dstnet) {
-			lnet_route_t *route;
-			lnet_route_t *shortest = NULL;
+			struct lnet_route *route;
+			struct lnet_route *shortest = NULL;
 			__u32 shortest_hops = LNET_UNDEFINED_HOPS;
 			__u32 route_hops;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index eda829a..8e5af05 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -268,7 +268,7 @@ static void lnet_shuffle_seed(void)
 
 /* NB expects LNET_LOCK held */
 static void
-lnet_add_route_to_rnet(lnet_remotenet_t *rnet, lnet_route_t *route)
+lnet_add_route_to_rnet(lnet_remotenet_t *rnet, struct lnet_route *route)
 {
 	unsigned int len = 0;
 	unsigned int offset = 0;
@@ -301,7 +301,7 @@ static void lnet_shuffle_seed(void)
 	struct list_head *e;
 	lnet_remotenet_t *rnet;
 	lnet_remotenet_t *rnet2;
-	lnet_route_t *route;
+	struct lnet_route *route;
 	struct lnet_ni *ni;
 	int add_route;
 	int rc;
@@ -368,8 +368,9 @@ static void lnet_shuffle_seed(void)
 	/* Search for a duplicate route (it's a NOOP if it is) */
 	add_route = 1;
 	list_for_each(e, &rnet2->lrn_routes) {
-		lnet_route_t *route2 = list_entry(e, lnet_route_t, lr_list);
+		struct lnet_route *route2;
 
+		route2 = list_entry(e, struct lnet_route, lr_list);
 		if (route2->lr_gateway == route->lr_gateway) {
 			add_route = 0;
 			break;
@@ -416,8 +417,8 @@ static void lnet_shuffle_seed(void)
 lnet_check_routes(void)
 {
 	lnet_remotenet_t *rnet;
-	lnet_route_t *route;
-	lnet_route_t *route2;
+	struct lnet_route *route;
+	struct lnet_route *route2;
 	struct list_head *e1;
 	struct list_head *e2;
 	int cpt;
@@ -437,7 +438,7 @@ static void lnet_shuffle_seed(void)
 				lnet_nid_t nid2;
 				int net;
 
-				route = list_entry(e2, lnet_route_t, lr_list);
+				route = list_entry(e2, struct lnet_route, lr_list);
 
 				if (!route2) {
 					route2 = route;
@@ -472,7 +473,7 @@ static void lnet_shuffle_seed(void)
 {
 	struct lnet_peer *gateway;
 	lnet_remotenet_t *rnet;
-	lnet_route_t *route;
+	struct lnet_route *route;
 	struct list_head *e1;
 	struct list_head *e2;
 	int rc = -ENOENT;
@@ -501,7 +502,7 @@ static void lnet_shuffle_seed(void)
 			continue;
 
 		list_for_each(e2, &rnet->lrn_routes) {
-			route = list_entry(e2, lnet_route_t, lr_list);
+			route = list_entry(e2, struct lnet_route, lr_list);
 
 			gateway = route->lr_gateway;
 			if (!(gw_nid == LNET_NID_ANY ||
@@ -588,7 +589,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	struct list_head *e1;
 	struct list_head *e2;
 	lnet_remotenet_t *rnet;
-	lnet_route_t *route;
+	struct lnet_route *route;
 	int cpt;
 	int i;
 	struct list_head *rn_list;
@@ -601,7 +602,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 			rnet = list_entry(e1, lnet_remotenet_t, lrn_list);
 
 			list_for_each(e2, &rnet->lrn_routes) {
-				route = list_entry(e2, lnet_route_t, lr_list);
+				route = list_entry(e2, struct lnet_route,
+						   lr_list);
 
 				if (!idx--) {
 					*net      = rnet->lrn_net;
@@ -646,7 +648,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	struct lnet_ping_info *info = rcd->rcd_pinginfo;
 	struct lnet_peer *gw = rcd->rcd_gateway;
-	lnet_route_t *rte;
+	struct lnet_route *rte;
 
 	if (!gw->lp_alive)
 		return;
@@ -823,7 +825,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 void
 lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net)
 {
-	lnet_route_t *rte;
+	struct lnet_route *rte;
 
 	if ((gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
 		list_for_each_entry(rte, &gw->lp_routes, lr_gwlist) {
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index e672148..1b2817c 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -171,7 +171,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 	} else {
 		struct list_head *n;
 		struct list_head *r;
-		lnet_route_t *route = NULL;
+		struct lnet_route *route = NULL;
 		lnet_remotenet_t *rnet  = NULL;
 		int skip  = off - 1;
 		struct list_head *rn_list;
@@ -197,9 +197,10 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 				r = rnet->lrn_routes.next;
 
 				while (r != &rnet->lrn_routes) {
-					lnet_route_t *re =
-						list_entry(r, lnet_route_t,
-							   lr_list);
+					struct lnet_route *re;
+
+					re = list_entry(r, struct lnet_route,
+							lr_list);
 					if (!skip) {
 						route = re;
 						break;
@@ -331,7 +332,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			int last_ping = cfs_duration_sec(cfs_time_sub(now,
 						     peer->lp_ping_timestamp));
 			int down_ni = 0;
-			lnet_route_t *rtr;
+			struct lnet_route *rtr;
 
 			if ((peer->lp_ping_feats &
 			     LNET_PING_FEAT_NI_STATUS)) {
-- 
1.8.3.1
