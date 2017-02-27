From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:40 -0500
Subject: [lustre-devel] [PATCH 15/34] staging: lustre: lnet: change
	lnet_peer_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_peer_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 20 +++++++--------
 .../staging/lustre/include/linux/lnet/lib-types.h  |  6 ++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 20 +++++++--------
 drivers/staging/lustre/lnet/lnet/peer.c            | 30 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router.c          | 30 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router_proc.c     | 10 +++++---
 6 files changed, 59 insertions(+), 57 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 3d5913d..bcfbed1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -364,16 +364,16 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_peer_addref_locked(lnet_peer_t *lp)
+lnet_peer_addref_locked(struct lnet_peer *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	lp->lp_refcount++;
 }
 
-void lnet_destroy_peer_locked(lnet_peer_t *lp);
+void lnet_destroy_peer_locked(struct lnet_peer *lp);
 
 static inline void
-lnet_peer_decref_locked(lnet_peer_t *lp)
+lnet_peer_decref_locked(struct lnet_peer *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	lp->lp_refcount--;
@@ -382,7 +382,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline int
-lnet_isrouter(lnet_peer_t *lp)
+lnet_isrouter(struct lnet_peer *lp)
 {
 	return lp->lp_rtr_refcount ? 1 : 0;
 }
@@ -454,7 +454,7 @@ struct lnet_ni *
 void lnet_lib_exit(void);
 
 int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive, unsigned long when);
-void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
+void lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
 			unsigned long when);
 int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
 		   unsigned int priority);
@@ -666,7 +666,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 
 int lnet_router_checker_start(void);
 void lnet_router_checker_stop(void);
-void lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net);
+void lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net);
 void lnet_swap_pinginfo(struct lnet_ping_info *info);
 
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
@@ -674,9 +674,9 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 int lnet_parse_networks(struct list_head *nilist, char *networks);
 int lnet_net_unique(__u32 net, struct list_head *nilist);
 
-int lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt);
-lnet_peer_t *lnet_find_peer_locked(struct lnet_peer_table *ptable,
-				   lnet_nid_t nid);
+int lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt);
+struct lnet_peer *lnet_find_peer_locked(struct lnet_peer_table *ptable,
+					lnet_nid_t nid);
 void lnet_peer_tables_cleanup(struct lnet_ni *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
@@ -689,7 +689,7 @@ int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 		       __u32 *peer_tx_qnob);
 
 static inline void
-lnet_peer_set_alive(lnet_peer_t *lp)
+lnet_peer_set_alive(struct lnet_peer *lp)
 {
 	lp->lp_last_query = jiffies;
 	lp->lp_last_alive = jiffies;
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 10bf60f..2cfc1bf 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -305,7 +305,7 @@ struct lnet_rc_data {
 	struct lnet_ping_info	*rcd_pinginfo;	/* ping buffer */
 };
 
-typedef struct lnet_peer {
+struct lnet_peer {
 	struct list_head	 lp_hashlist;	/* chain on peer hash */
 	struct list_head	 lp_txq;	/* messages blocking for
 						   tx credits */
@@ -346,7 +346,7 @@ struct lnet_rc_data {
 	unsigned int		 lp_ping_feats;
 	struct list_head	 lp_routes;	/* routers on this peer */
 	struct lnet_rc_data	*lp_rcd;	/* router checker state */
-} lnet_peer_t;
+};
 
 /* peer hash size */
 #define LNET_PEER_HASH_BITS	9
@@ -372,7 +372,7 @@ struct lnet_peer_table {
 typedef struct {
 	struct list_head	 lr_list;	/* chain on net */
 	struct list_head	 lr_gwlist;	/* chain on gateway */
-	lnet_peer_t		*lr_gateway;	/* router node */
+	struct lnet_peer	*lr_gateway;	/* router node */
 	__u32			 lr_net;	/* remote network number */
 	int			 lr_seq;	/* sequence for round-robin */
 	unsigned int		 lr_downis;	/* number of down NIs */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 3aabb32..9615dcd 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -489,7 +489,7 @@
 
 /* NB: caller shall hold a ref on 'lp' as I'd drop lnet_net_lock */
 static void
-lnet_ni_query_locked(struct lnet_ni *ni, lnet_peer_t *lp)
+lnet_ni_query_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 {
 	unsigned long last_alive = 0;
 
@@ -508,7 +508,7 @@
 
 /* NB: always called with lnet_net_lock held */
 static inline int
-lnet_peer_is_alive(lnet_peer_t *lp, unsigned long now)
+lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 {
 	int alive;
 	unsigned long deadline;
@@ -542,7 +542,7 @@
  *     may drop the lnet_net_lock
  */
 static int
-lnet_peer_alive_locked(lnet_peer_t *lp)
+lnet_peer_alive_locked(struct lnet_peer *lp)
 {
 	unsigned long now = cfs_time_current();
 
@@ -598,7 +598,7 @@
 static int
 lnet_post_send_locked(struct lnet_msg *msg, int do_send)
 {
-	lnet_peer_t *lp = msg->msg_txpeer;
+	struct lnet_peer *lp = msg->msg_txpeer;
 	struct lnet_ni *ni = lp->lp_ni;
 	int cpt = msg->msg_tx_cpt;
 	struct lnet_tx_queue *tq = ni->ni_tx_queues[cpt];
@@ -709,7 +709,7 @@
 	 * I return LNET_CREDIT_WAIT if msg blocked and LNET_CREDIT_OK if
 	 * received or OK to receive
 	 */
-	lnet_peer_t *lp = msg->msg_rxpeer;
+	struct lnet_peer *lp = msg->msg_rxpeer;
 	lnet_rtrbufpool_t *rbp;
 	lnet_rtrbuf_t *rb;
 
@@ -779,7 +779,7 @@
 void
 lnet_return_tx_credits_locked(struct lnet_msg *msg)
 {
-	lnet_peer_t *txpeer = msg->msg_txpeer;
+	struct lnet_peer *txpeer = msg->msg_txpeer;
 	struct lnet_msg *msg2;
 
 	if (msg->msg_txcredit) {
@@ -874,7 +874,7 @@
 void
 lnet_return_rx_credits_locked(struct lnet_msg *msg)
 {
-	lnet_peer_t *rxpeer = msg->msg_rxpeer;
+	struct lnet_peer *rxpeer = msg->msg_rxpeer;
 	struct lnet_msg *msg2;
 
 	if (msg->msg_rtrcredit) {
@@ -959,8 +959,8 @@
 static int
 lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
 {
-	lnet_peer_t *p1 = r1->lr_gateway;
-	lnet_peer_t *p2 = r2->lr_gateway;
+	struct lnet_peer *p1 = r1->lr_gateway;
+	struct lnet_peer *p2 = r2->lr_gateway;
 	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
 	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
 
@@ -994,7 +994,7 @@
 	return -ERANGE;
 }
 
-static lnet_peer_t *
+static struct lnet_peer *
 lnet_find_route_locked(struct lnet_ni *ni, lnet_nid_t target,
 		       lnet_nid_t rtr_nid)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 4b1a632..e62b21f 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -105,8 +105,8 @@
 			       struct lnet_peer_table *ptable)
 {
 	int i;
-	lnet_peer_t *lp;
-	lnet_peer_t *tmp;
+	struct lnet_peer *lp;
+	struct lnet_peer *tmp;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
 		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
@@ -146,8 +146,8 @@
 				struct lnet_peer_table *ptable,
 				int cpt_locked)
 {
-	lnet_peer_t *lp;
-	lnet_peer_t *tmp;
+	struct lnet_peer *lp;
+	struct lnet_peer *tmp;
 	lnet_nid_t lp_nid;
 	int i;
 
@@ -174,8 +174,8 @@
 {
 	struct lnet_peer_table *ptable;
 	struct list_head deathrow;
-	lnet_peer_t *lp;
-	lnet_peer_t *temp;
+	struct lnet_peer *lp;
+	struct lnet_peer *temp;
 	int i;
 
 	INIT_LIST_HEAD(&deathrow);
@@ -216,7 +216,7 @@
 }
 
 void
-lnet_destroy_peer_locked(lnet_peer_t *lp)
+lnet_destroy_peer_locked(struct lnet_peer *lp)
 {
 	struct lnet_peer_table *ptable;
 
@@ -238,11 +238,11 @@
 	ptable->pt_zombies--;
 }
 
-lnet_peer_t *
+struct lnet_peer *
 lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
 {
 	struct list_head *peers;
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 
 	LASSERT(!the_lnet.ln_shutdown);
 
@@ -258,11 +258,11 @@
 }
 
 int
-lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
+lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt)
 {
 	struct lnet_peer_table *ptable;
-	lnet_peer_t *lp = NULL;
-	lnet_peer_t *lp2;
+	struct lnet_peer *lp = NULL;
+	struct lnet_peer *lp2;
 	int cpt2;
 	int rc = 0;
 
@@ -282,7 +282,7 @@
 
 	if (!list_empty(&ptable->pt_deathrow)) {
 		lp = list_entry(ptable->pt_deathrow.next,
-				lnet_peer_t, lp_hashlist);
+				struct lnet_peer, lp_hashlist);
 		list_del(&lp->lp_hashlist);
 	}
 
@@ -364,7 +364,7 @@
 lnet_debug_peer(lnet_nid_t nid)
 {
 	char *aliveness = "NA";
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 	int rc;
 	int cpt;
 
@@ -401,7 +401,7 @@
 		   __u32 *peer_tx_qnob)
 {
 	struct lnet_peer_table *peer_table;
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 	bool found = false;
 	int lncpt, j;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index c73d7a0..eda829a 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -98,7 +98,7 @@
 }
 
 void
-lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
+lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
 		   unsigned long when)
 {
 	if (time_before(when, lp->lp_timestamp)) { /* out of date information */
@@ -128,7 +128,7 @@
 }
 
 static void
-lnet_ni_notify_locked(struct lnet_ni *ni, lnet_peer_t *lp)
+lnet_ni_notify_locked(struct lnet_ni *ni, struct lnet_peer *lp)
 {
 	int alive;
 	int notifylnd;
@@ -167,7 +167,7 @@
 }
 
 static void
-lnet_rtr_addref_locked(lnet_peer_t *lp)
+lnet_rtr_addref_locked(struct lnet_peer *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	LASSERT(lp->lp_rtr_refcount >= 0);
@@ -179,9 +179,9 @@
 
 		/* a simple insertion sort */
 		list_for_each_prev(pos, &the_lnet.ln_routers) {
-			lnet_peer_t *rtr = list_entry(pos, lnet_peer_t,
-						      lp_rtr_list);
+			struct lnet_peer *rtr;
 
+			rtr = list_entry(pos, struct lnet_peer, lp_rtr_list);
 			if (rtr->lp_nid < lp->lp_nid)
 				break;
 		}
@@ -194,7 +194,7 @@
 }
 
 static void
-lnet_rtr_decref_locked(lnet_peer_t *lp)
+lnet_rtr_decref_locked(struct lnet_peer *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	LASSERT(lp->lp_rtr_refcount > 0);
@@ -791,7 +791,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_wait_known_routerstate(void)
 {
-	lnet_peer_t *rtr;
+	struct lnet_peer *rtr;
 	struct list_head *entry;
 	int all_known;
 
@@ -802,7 +802,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 		all_known = 1;
 		list_for_each(entry, &the_lnet.ln_routers) {
-			rtr = list_entry(entry, lnet_peer_t, lp_rtr_list);
+			rtr = list_entry(entry,struct lnet_peer, lp_rtr_list);
 
 			if (!rtr->lp_alive_count) {
 				all_known = 0;
@@ -821,7 +821,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 void
-lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net)
+lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net)
 {
 	lnet_route_t *rte;
 
@@ -899,7 +899,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static struct lnet_rc_data *
-lnet_create_rc_data_locked(lnet_peer_t *gateway)
+lnet_create_rc_data_locked(struct lnet_peer *gateway)
 {
 	struct lnet_rc_data *rcd = NULL;
 	struct lnet_ping_info *pi;
@@ -969,7 +969,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static int
-lnet_router_check_interval(lnet_peer_t *rtr)
+lnet_router_check_interval(struct lnet_peer *rtr)
 {
 	int secs;
 
@@ -982,7 +982,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static void
-lnet_ping_router_locked(lnet_peer_t *rtr)
+lnet_ping_router_locked(struct lnet_peer *rtr)
 {
 	struct lnet_rc_data *rcd = NULL;
 	unsigned long now = cfs_time_current();
@@ -1126,7 +1126,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	struct lnet_rc_data *rcd;
 	struct lnet_rc_data *tmp;
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 	struct list_head head;
 	int i = 2;
 
@@ -1232,7 +1232,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static int
 lnet_router_checker(void *arg)
 {
-	lnet_peer_t *rtr;
+	struct lnet_peer *rtr;
 	struct list_head *entry;
 
 	cfs_block_allsigs();
@@ -1247,7 +1247,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		version = the_lnet.ln_routers_version;
 
 		list_for_each(entry, &the_lnet.ln_routers) {
-			rtr = list_entry(entry, lnet_peer_t, lp_rtr_list);
+			rtr = list_entry(entry, struct lnet_peer, lp_rtr_list);
 
 			cpt2 = lnet_cpt_of_nid_locked(rtr->lp_nid);
 			if (cpt != cpt2) {
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 672d71d..e672148 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -307,9 +307,9 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		r = the_lnet.ln_routers.next;
 
 		while (r != &the_lnet.ln_routers) {
-			lnet_peer_t *lp = list_entry(r, lnet_peer_t,
-						     lp_rtr_list);
+			struct lnet_peer *lp;
 
+			lp = list_entry(r, struct lnet_peer, lp_rtr_list);
 			if (!skip) {
 				peer = lp;
 				break;
@@ -454,8 +454,10 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				p = ptable->pt_hash[hash].next;
 
 			while (p != &ptable->pt_hash[hash]) {
-				lnet_peer_t *lp = list_entry(p, lnet_peer_t,
-							     lp_hashlist);
+				struct lnet_peer *lp;
+
+				lp = list_entry(p, struct lnet_peer,
+						lp_hashlist);
 				if (!skip) {
 					peer = lp;
 
-- 
1.8.3.1
