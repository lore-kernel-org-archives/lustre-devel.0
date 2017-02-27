From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:42 -0500
Subject: [lustre-devel] [PATCH 17/34] staging: lustre: lnet: change
	lnet_remotenet_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_remotenet_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  4 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  6 +++---
 drivers/staging/lustre/lnet/lnet/router.c          | 24 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  4 ++--
 6 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 93e6830..8483a4a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -473,7 +473,7 @@ int lnet_get_route(int idx, __u32 *net, __u32 *hops,
 int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
 void lnet_rtrpools_free(int keep_pools);
-lnet_remotenet_t *lnet_find_net_locked(__u32 net);
+struct lnet_remotenet *lnet_find_net_locked(__u32 net);
 int lnet_dyn_add_ni(lnet_pid_t requested_pid,
 		    struct lnet_ioctl_config_data *conf);
 int lnet_dyn_del_ni(__u32 net);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index a0d9cad..04ad728 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -384,12 +384,12 @@ struct lnet_route {
 #define LNET_REMOTE_NETS_HASH_MAX	(1U << 16)
 #define LNET_REMOTE_NETS_HASH_SIZE	(1 << the_lnet.ln_remote_nets_hbits)
 
-typedef struct {
+struct lnet_remotenet {
 	struct list_head	lrn_list;	/* chain on
 						   ln_remote_nets_hash */
 	struct list_head	lrn_routes;	/* routes to me */
 	__u32			lrn_net;	/* my net number */
-} lnet_remotenet_t;
+};
 
 /** lnet message has credit and can be submitted to lnd for send/receive */
 #define LNET_CREDIT_OK		0
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 88279ed..c03e701 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1762,7 +1762,7 @@ void lnet_lib_exit(void)
 	struct lnet_handle_md md_handle;
 	struct lnet_ni *ni;
 	struct list_head net_head;
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	int rc;
 
 	INIT_LIST_HEAD(&net_head);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 9d1ab1f..3581100 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -998,7 +998,7 @@
 lnet_find_route_locked(struct lnet_ni *ni, lnet_nid_t target,
 		       lnet_nid_t rtr_nid)
 {
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
 	struct lnet_route *best_route;
 	struct lnet_route *last_route;
@@ -2291,7 +2291,7 @@ struct lnet_msg *
 {
 	struct list_head *e;
 	struct lnet_ni *ni;
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	__u32 dstnet = LNET_NIDNET(dstnid);
 	int hops;
 	int cpt;
@@ -2348,7 +2348,7 @@ struct lnet_msg *
 
 	rn_list = lnet_net2rnethash(dstnet);
 	list_for_each(e, rn_list) {
-		rnet = list_entry(e, lnet_remotenet_t, lrn_list);
+		rnet = list_entry(e, struct lnet_remotenet, lrn_list);
 
 		if (rnet->lrn_net == dstnet) {
 			struct lnet_route *route;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 8e5af05..9a5faba 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -217,10 +217,10 @@
 	}
 }
 
-lnet_remotenet_t *
+struct lnet_remotenet *
 lnet_find_net_locked(__u32 net)
 {
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	struct list_head *tmp;
 	struct list_head *rn_list;
 
@@ -228,7 +228,7 @@
 
 	rn_list = lnet_net2rnethash(net);
 	list_for_each(tmp, rn_list) {
-		rnet = list_entry(tmp, lnet_remotenet_t, lrn_list);
+		rnet = list_entry(tmp, struct lnet_remotenet, lrn_list);
 
 		if (rnet->lrn_net == net)
 			return rnet;
@@ -268,7 +268,7 @@ static void lnet_shuffle_seed(void)
 
 /* NB expects LNET_LOCK held */
 static void
-lnet_add_route_to_rnet(lnet_remotenet_t *rnet, struct lnet_route *route)
+lnet_add_route_to_rnet(struct lnet_remotenet *rnet, struct lnet_route *route)
 {
 	unsigned int len = 0;
 	unsigned int offset = 0;
@@ -299,8 +299,8 @@ static void lnet_shuffle_seed(void)
 	       unsigned int priority)
 {
 	struct list_head *e;
-	lnet_remotenet_t *rnet;
-	lnet_remotenet_t *rnet2;
+	struct lnet_remotenet *rnet;
+	struct lnet_remotenet *rnet2;
 	struct lnet_route *route;
 	struct lnet_ni *ni;
 	int add_route;
@@ -416,7 +416,7 @@ static void lnet_shuffle_seed(void)
 int
 lnet_check_routes(void)
 {
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
 	struct lnet_route *route2;
 	struct list_head *e1;
@@ -430,7 +430,7 @@ static void lnet_shuffle_seed(void)
 	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
 		rn_list = &the_lnet.ln_remote_nets_hash[i];
 		list_for_each(e1, rn_list) {
-			rnet = list_entry(e1, lnet_remotenet_t, lrn_list);
+			rnet = list_entry(e1, struct lnet_remotenet, lrn_list);
 
 			route2 = NULL;
 			list_for_each(e2, &rnet->lrn_routes) {
@@ -472,7 +472,7 @@ static void lnet_shuffle_seed(void)
 lnet_del_route(__u32 net, lnet_nid_t gw_nid)
 {
 	struct lnet_peer *gateway;
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
 	struct list_head *e1;
 	struct list_head *e2;
@@ -495,7 +495,7 @@ static void lnet_shuffle_seed(void)
 
  again:
 	list_for_each(e1, rn_list) {
-		rnet = list_entry(e1, lnet_remotenet_t, lrn_list);
+		rnet = list_entry(e1, struct lnet_remotenet, lrn_list);
 
 		if (!(net == LNET_NIDNET(LNET_NID_ANY) ||
 		      net == rnet->lrn_net))
@@ -588,7 +588,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	struct list_head *e1;
 	struct list_head *e2;
-	lnet_remotenet_t *rnet;
+	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
 	int cpt;
 	int i;
@@ -599,7 +599,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++) {
 		rn_list = &the_lnet.ln_remote_nets_hash[i];
 		list_for_each(e1, rn_list) {
-			rnet = list_entry(e1, lnet_remotenet_t, lrn_list);
+			rnet = list_entry(e1, struct lnet_remotenet, lrn_list);
 
 			list_for_each(e2, &rnet->lrn_routes) {
 				route = list_entry(e2, struct lnet_route,
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 1b2817c..779ec69 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -172,7 +172,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 		struct list_head *n;
 		struct list_head *r;
 		struct lnet_route *route = NULL;
-		lnet_remotenet_t *rnet  = NULL;
+		struct lnet_remotenet *rnet  = NULL;
 		int skip  = off - 1;
 		struct list_head *rn_list;
 		int i;
@@ -191,7 +191,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			n = rn_list->next;
 
 			while (n != rn_list && !route) {
-				rnet = list_entry(n, lnet_remotenet_t,
+				rnet = list_entry(n, struct lnet_remotenet,
 						  lrn_list);
 
 				r = rnet->lrn_routes.next;
-- 
1.8.3.1
