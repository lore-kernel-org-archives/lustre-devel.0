From: Joe Perches <joe@perches.com>
Date: Fri,  1 Apr 2016 06:02:09 -0700
Subject: [lustre-devel] [RFC PATCH 1/3] staging: lustre: Remove typedef
	lnet_peer_t
In-Reply-To: <cover.1459515208.git.joe@perches.com>
References: <cover.1459515208.git.joe@perches.com>
Message-ID: <1c948ef81164fb57e45e2467abd3fd013b2c9068.1459515208.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

Just use struct lnet_peer instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 18 ++++++-------
 .../staging/lustre/include/linux/lnet/lib-types.h  |  6 ++---
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 20 +++++++--------
 drivers/staging/lustre/lnet/lnet/peer.c            | 30 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/router.c          | 28 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  4 +--
 6 files changed, 53 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index dfc0208..ea29cb9 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -364,16 +364,16 @@ lnet_handle2me(lnet_handle_me_t *handle)
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
@@ -382,7 +382,7 @@ lnet_peer_decref_locked(lnet_peer_t *lp)
 }
 
 static inline int
-lnet_isrouter(lnet_peer_t *lp)
+lnet_isrouter(struct lnet_peer *lp)
 {
 	return lp->lp_rtr_refcount ? 1 : 0;
 }
@@ -454,7 +454,7 @@ int lnet_lib_init(void);
 void lnet_lib_exit(void);
 
 int lnet_notify(lnet_ni_t *ni, lnet_nid_t peer, int alive, unsigned long when);
-void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
+void lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
 			unsigned long when);
 int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
 		   unsigned int priority);
@@ -721,7 +721,7 @@ int lnet_peer_buffer_credits(lnet_ni_t *ni);
 
 int lnet_router_checker_start(void);
 void lnet_router_checker_stop(void);
-void lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net);
+void lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net);
 void lnet_swap_pinginfo(lnet_ping_info_t *info);
 
 int lnet_parse_ip2nets(char **networksp, char *ip2nets);
@@ -729,8 +729,8 @@ int lnet_parse_routes(char *route_str, int *im_a_router);
 int lnet_parse_networks(struct list_head *nilist, char *networks);
 int lnet_net_unique(__u32 net, struct list_head *nilist);
 
-int lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt);
-lnet_peer_t *lnet_find_peer_locked(struct lnet_peer_table *ptable,
+int lnet_nid2peer_locked(struct lnet_peer **lpp, lnet_nid_t nid, int cpt);
+struct lnet_peer *lnet_find_peer_locked(struct lnet_peer_table *ptable,
 				   lnet_nid_t nid);
 void lnet_peer_tables_cleanup(lnet_ni_t *ni);
 void lnet_peer_tables_destroy(void);
@@ -744,7 +744,7 @@ int lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 		       __u32 *peer_tx_qnob);
 
 static inline void
-lnet_peer_set_alive(lnet_peer_t *lp)
+lnet_peer_set_alive(struct lnet_peer *lp)
 {
 	lp->lp_last_query = jiffies;
 	lp->lp_last_alive = jiffies;
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 29c72f8..d223de5 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -302,7 +302,7 @@ typedef struct {
 	lnet_ping_info_t	*rcd_pinginfo;	/* ping buffer */
 } lnet_rc_data_t;
 
-typedef struct lnet_peer {
+struct lnet_peer {
 	struct list_head	 lp_hashlist;	/* chain on peer hash */
 	struct list_head	 lp_txq;	/* messages blocking for
 						   tx credits */
@@ -343,7 +343,7 @@ typedef struct lnet_peer {
 	unsigned int		 lp_ping_feats;
 	struct list_head	 lp_routes;	/* routers on this peer */
 	lnet_rc_data_t		*lp_rcd;	/* router checker state */
-} lnet_peer_t;
+};
 
 /* peer hash size */
 #define LNET_PEER_HASH_BITS	9
@@ -369,7 +369,7 @@ struct lnet_peer_table {
 typedef struct {
 	struct list_head	 lr_list;	/* chain on net */
 	struct list_head	 lr_gwlist;	/* chain on gateway */
-	lnet_peer_t		*lr_gateway;	/* router node */
+	struct lnet_peer	*lr_gateway;	/* router node */
 	__u32			 lr_net;	/* remote network number */
 	int			 lr_seq;	/* sequence for round-robin */
 	unsigned int		 lr_downis;	/* number of down NIs */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 44e2bd6..4ebf1b4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -684,7 +684,7 @@ lnet_ni_eager_recv(lnet_ni_t *ni, lnet_msg_t *msg)
 
 /* NB: caller shall hold a ref on 'lp' as I'd drop lnet_net_lock */
 static void
-lnet_ni_query_locked(lnet_ni_t *ni, lnet_peer_t *lp)
+lnet_ni_query_locked(lnet_ni_t *ni, struct lnet_peer *lp)
 {
 	unsigned long last_alive = 0;
 
@@ -703,7 +703,7 @@ lnet_ni_query_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 
 /* NB: always called with lnet_net_lock held */
 static inline int
-lnet_peer_is_alive(lnet_peer_t *lp, unsigned long now)
+lnet_peer_is_alive(struct lnet_peer *lp, unsigned long now)
 {
 	int alive;
 	unsigned long deadline;
@@ -737,7 +737,7 @@ lnet_peer_is_alive(lnet_peer_t *lp, unsigned long now)
  *     may drop the lnet_net_lock
  */
 static int
-lnet_peer_alive_locked(lnet_peer_t *lp)
+lnet_peer_alive_locked(struct lnet_peer *lp)
 {
 	unsigned long now = cfs_time_current();
 
@@ -793,7 +793,7 @@ lnet_peer_alive_locked(lnet_peer_t *lp)
 static int
 lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 {
-	lnet_peer_t *lp = msg->msg_txpeer;
+	struct lnet_peer *lp = msg->msg_txpeer;
 	lnet_ni_t *ni = lp->lp_ni;
 	int cpt = msg->msg_tx_cpt;
 	struct lnet_tx_queue *tq = ni->ni_tx_queues[cpt];
@@ -904,7 +904,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 	 * I return LNET_CREDIT_WAIT if msg blocked and LNET_CREDIT_OK if
 	 * received or OK to receive
 	 */
-	lnet_peer_t *lp = msg->msg_rxpeer;
+	struct lnet_peer *lp = msg->msg_rxpeer;
 	lnet_rtrbufpool_t *rbp;
 	lnet_rtrbuf_t *rb;
 
@@ -974,7 +974,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 void
 lnet_return_tx_credits_locked(lnet_msg_t *msg)
 {
-	lnet_peer_t *txpeer = msg->msg_txpeer;
+	struct lnet_peer *txpeer = msg->msg_txpeer;
 	lnet_msg_t *msg2;
 
 	if (msg->msg_txcredit) {
@@ -1069,7 +1069,7 @@ lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
 void
 lnet_return_rx_credits_locked(lnet_msg_t *msg)
 {
-	lnet_peer_t *rxpeer = msg->msg_rxpeer;
+	struct lnet_peer *rxpeer = msg->msg_rxpeer;
 	lnet_msg_t *msg2;
 
 	if (msg->msg_rtrcredit) {
@@ -1154,8 +1154,8 @@ routing_off:
 static int
 lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
 {
-	lnet_peer_t *p1 = r1->lr_gateway;
-	lnet_peer_t *p2 = r2->lr_gateway;
+	struct lnet_peer *p1 = r1->lr_gateway;
+	struct lnet_peer *p2 = r2->lr_gateway;
 	int r1_hops = (r1->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r1->lr_hops;
 	int r2_hops = (r2->lr_hops == LNET_UNDEFINED_HOPS) ? 1 : r2->lr_hops;
 
@@ -1189,7 +1189,7 @@ lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
 	return -ERANGE;
 }
 
-static lnet_peer_t *
+static struct lnet_peer *
 lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 {
 	lnet_remotenet_t *rnet;
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index b026fee..3bb4142 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -108,8 +108,8 @@ static void
 lnet_peer_table_cleanup_locked(lnet_ni_t *ni, struct lnet_peer_table *ptable)
 {
 	int i;
-	lnet_peer_t *lp;
-	lnet_peer_t *tmp;
+	struct lnet_peer *lp;
+	struct lnet_peer *tmp;
 
 	for (i = 0; i < LNET_PEER_HASH_SIZE; i++) {
 		list_for_each_entry_safe(lp, tmp, &ptable->pt_hash[i],
@@ -148,8 +148,8 @@ static void
 lnet_peer_table_del_rtrs_locked(lnet_ni_t *ni, struct lnet_peer_table *ptable,
 				int cpt_locked)
 {
-	lnet_peer_t *lp;
-	lnet_peer_t *tmp;
+	struct lnet_peer *lp;
+	struct lnet_peer *tmp;
 	lnet_nid_t lp_nid;
 	int i;
 
@@ -176,8 +176,8 @@ lnet_peer_tables_cleanup(lnet_ni_t *ni)
 {
 	struct lnet_peer_table *ptable;
 	struct list_head deathrow;
-	lnet_peer_t *lp;
-	lnet_peer_t *temp;
+	struct lnet_peer *lp;
+	struct lnet_peer *temp;
 	int i;
 
 	INIT_LIST_HEAD(&deathrow);
@@ -218,7 +218,7 @@ lnet_peer_tables_cleanup(lnet_ni_t *ni)
 }
 
 void
-lnet_destroy_peer_locked(lnet_peer_t *lp)
+lnet_destroy_peer_locked(struct lnet_peer *lp)
 {
 	struct lnet_peer_table *ptable;
 
@@ -240,11 +240,11 @@ lnet_destroy_peer_locked(lnet_peer_t *lp)
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
 
@@ -260,11 +260,11 @@ lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
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
 
@@ -284,7 +284,7 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 
 	if (!list_empty(&ptable->pt_deathrow)) {
 		lp = list_entry(ptable->pt_deathrow.next,
-				lnet_peer_t, lp_hashlist);
+				struct lnet_peer, lp_hashlist);
 		list_del(&lp->lp_hashlist);
 	}
 
@@ -366,7 +366,7 @@ void
 lnet_debug_peer(lnet_nid_t nid)
 {
 	char *aliveness = "NA";
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 	int rc;
 	int cpt;
 
@@ -403,7 +403,7 @@ lnet_get_peer_info(__u32 peer_index, __u64 *nid,
 		   __u32 *peer_tx_qnob)
 {
 	struct lnet_peer_table *peer_table;
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 	bool found = false;
 	int lncpt, j;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 61459cf..3506cd47 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -97,7 +97,7 @@ lnet_peers_start_down(void)
 }
 
 void
-lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
+lnet_notify_locked(struct lnet_peer *lp, int notifylnd, int alive,
 		   unsigned long when)
 {
 	if (time_before(when, lp->lp_timestamp)) { /* out of date information */
@@ -127,7 +127,7 @@ lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
 }
 
 static void
-lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
+lnet_ni_notify_locked(lnet_ni_t *ni, struct lnet_peer *lp)
 {
 	int alive;
 	int notifylnd;
@@ -166,7 +166,7 @@ lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 }
 
 static void
-lnet_rtr_addref_locked(lnet_peer_t *lp)
+lnet_rtr_addref_locked(struct lnet_peer *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	LASSERT(lp->lp_rtr_refcount >= 0);
@@ -178,7 +178,7 @@ lnet_rtr_addref_locked(lnet_peer_t *lp)
 
 		/* a simple insertion sort */
 		list_for_each_prev(pos, &the_lnet.ln_routers) {
-			lnet_peer_t *rtr = list_entry(pos, lnet_peer_t,
+			struct lnet_peer *rtr = list_entry(pos, struct lnet_peer,
 						      lp_rtr_list);
 
 			if (rtr->lp_nid < lp->lp_nid)
@@ -193,7 +193,7 @@ lnet_rtr_addref_locked(lnet_peer_t *lp)
 }
 
 static void
-lnet_rtr_decref_locked(lnet_peer_t *lp)
+lnet_rtr_decref_locked(struct lnet_peer *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	LASSERT(lp->lp_rtr_refcount > 0);
@@ -790,7 +790,7 @@ lnet_router_checker_event(lnet_event_t *event)
 static void
 lnet_wait_known_routerstate(void)
 {
-	lnet_peer_t *rtr;
+	struct lnet_peer *rtr;
 	struct list_head *entry;
 	int all_known;
 
@@ -801,7 +801,7 @@ lnet_wait_known_routerstate(void)
 
 		all_known = 1;
 		list_for_each(entry, &the_lnet.ln_routers) {
-			rtr = list_entry(entry, lnet_peer_t, lp_rtr_list);
+			rtr = list_entry(entry, struct lnet_peer, lp_rtr_list);
 
 			if (!rtr->lp_alive_count) {
 				all_known = 0;
@@ -820,7 +820,7 @@ lnet_wait_known_routerstate(void)
 }
 
 void
-lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net)
+lnet_router_ni_update_locked(struct lnet_peer *gw, __u32 net)
 {
 	lnet_route_t *rte;
 
@@ -898,7 +898,7 @@ lnet_destroy_rc_data(lnet_rc_data_t *rcd)
 }
 
 static lnet_rc_data_t *
-lnet_create_rc_data_locked(lnet_peer_t *gateway)
+lnet_create_rc_data_locked(struct lnet_peer *gateway)
 {
 	lnet_rc_data_t *rcd = NULL;
 	lnet_ping_info_t *pi;
@@ -967,7 +967,7 @@ lnet_create_rc_data_locked(lnet_peer_t *gateway)
 }
 
 static int
-lnet_router_check_interval(lnet_peer_t *rtr)
+lnet_router_check_interval(struct lnet_peer *rtr)
 {
 	int secs;
 
@@ -980,7 +980,7 @@ lnet_router_check_interval(lnet_peer_t *rtr)
 }
 
 static void
-lnet_ping_router_locked(lnet_peer_t *rtr)
+lnet_ping_router_locked(struct lnet_peer *rtr)
 {
 	lnet_rc_data_t *rcd = NULL;
 	unsigned long now = cfs_time_current();
@@ -1124,7 +1124,7 @@ lnet_prune_rc_data(int wait_unlink)
 {
 	lnet_rc_data_t *rcd;
 	lnet_rc_data_t *tmp;
-	lnet_peer_t *lp;
+	struct lnet_peer *lp;
 	struct list_head head;
 	int i = 2;
 
@@ -1230,7 +1230,7 @@ lnet_router_checker_active(void)
 static int
 lnet_router_checker(void *arg)
 {
-	lnet_peer_t *rtr;
+	struct lnet_peer *rtr;
 	struct list_head *entry;
 
 	cfs_block_allsigs();
@@ -1245,7 +1245,7 @@ rescan:
 		version = the_lnet.ln_routers_version;
 
 		list_for_each(entry, &the_lnet.ln_routers) {
-			rtr = list_entry(entry, lnet_peer_t, lp_rtr_list);
+			rtr = list_entry(entry, struct lnet_peer, lp_rtr_list);
 
 			cpt2 = lnet_cpt_of_nid_locked(rtr->lp_nid);
 			if (cpt != cpt2) {
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 65f65a3..2d10238 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -307,7 +307,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		r = the_lnet.ln_routers.next;
 
 		while (r != &the_lnet.ln_routers) {
-			lnet_peer_t *lp = list_entry(r, lnet_peer_t,
+			struct lnet_peer *lp = list_entry(r, struct lnet_peer,
 						     lp_rtr_list);
 
 			if (!skip) {
@@ -454,7 +454,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				p = ptable->pt_hash[hash].next;
 
 			while (p != &ptable->pt_hash[hash]) {
-				lnet_peer_t *lp = list_entry(p, lnet_peer_t,
+				struct lnet_peer *lp = list_entry(p, struct lnet_peer,
 							     lp_hashlist);
 				if (!skip) {
 					peer = lp;
-- 
2.8.0.rc4.16.g56331f8
