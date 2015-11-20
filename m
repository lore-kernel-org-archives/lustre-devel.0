From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:46 -0500
Subject: [lustre-devel] [PATCH 10/40] staging: lustre: Dynamic LNet
	Configuration (DLC) dynamic routing
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This is the second patch of a set of patches that enables DLC.

This patch adds the following features to LNET.  Currently these
features are not driven by user space.
- Enabling Routing on Demand.  The default number of router
  buffers are allocated.
- Disable Routing on demand. Unused router buffers are freed and
  used router buffers are freed when they are no longer in use.
  The following time routing is enabled the default router buffer
  values are used.  It has been decided that remembering the
  user set router buffer values should be remembered and re-set
  by user space scripts.
- Increase the number of router buffers on demand, by allocating
  new ones.
- Decrease the number of router buffers.  Exccess buffers are freed
  if they are not in use.  Otherwise they are freed once they are
  no longer in use.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2456
Change-Id: Id07d4ad424d8f5ba72475d4149380afe2ac54e77
Reviewed-on: http://review.whamcloud.com/9831
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    8 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    8 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   89 +++++--
 drivers/staging/lustre/lnet/lnet/router.c          |  276 +++++++++++++++-----
 5 files changed, 304 insertions(+), 81 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 1e0b236..60accdf 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -459,7 +459,11 @@ int lnet_get_route(int idx, __u32 *net, __u32 *hops,
 void lnet_router_debugfs_init(void);
 void lnet_router_debugfs_fini(void);
 int  lnet_rtrpools_alloc(int im_a_router);
-void lnet_rtrpools_free(void);
+void lnet_destroy_rtrbuf(lnet_rtrbuf_t *rb, int npages);
+int lnet_rtrpools_adjust(int tiny, int small, int large);
+int lnet_rtrpools_enable(void);
+void lnet_rtrpools_disable(void);
+void lnet_rtrpools_free(int keep_pools);
 lnet_remotenet_t *lnet_find_net_locked(__u32 net);
 
 int lnet_islocalnid(lnet_nid_t nid);
@@ -479,6 +483,8 @@ void lnet_prep_send(lnet_msg_t *msg, int type, lnet_process_id_t target,
 int lnet_send(lnet_nid_t nid, lnet_msg_t *msg, lnet_nid_t rtr_nid);
 void lnet_return_tx_credits_locked(lnet_msg_t *msg);
 void lnet_return_rx_credits_locked(lnet_msg_t *msg);
+void lnet_schedule_blocked_locked(lnet_rtrbufpool_t *rbp);
+void lnet_drop_routed_msgs_locked(struct list_head *list, int cpt);
 
 /* portals functions */
 /* portals attributes */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 39381d9..e7585b9 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -277,6 +277,7 @@ typedef struct lnet_ni {
 #define LNET_PING_FEAT_INVAL		(0)		/* no feature */
 #define LNET_PING_FEAT_BASE		(1 << 0)	/* just a ping */
 #define LNET_PING_FEAT_NI_STATUS	(1 << 1)	/* return NI status */
+#define LNET_PING_FEAT_RTE_DISABLED	(1 << 2)	/* Routing enabled */
 
 #define LNET_PING_FEAT_MASK		(LNET_PING_FEAT_BASE | \
 					 LNET_PING_FEAT_NI_STATUS)
@@ -400,7 +401,12 @@ typedef struct {
 
 #define LNET_PEER_HASHSIZE	503	/* prime! */
 
-#define LNET_NRBPOOLS		3	/* # different router buffer pools */
+#define LNET_TINY_BUF_IDX	0
+#define LNET_SMALL_BUF_IDX	1
+#define LNET_LARGE_BUF_IDX	2
+
+/* # different router buffer pools */
+#define LNET_NRBPOOLS		(LNET_LARGE_BUF_IDX + 1)
 
 enum {
 	/* Didn't match anything */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f3c9937..0338537 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -632,7 +632,7 @@ lnet_unprepare(void)
 
 	lnet_msg_containers_destroy();
 	lnet_peer_tables_destroy();
-	lnet_rtrpools_free();
+	lnet_rtrpools_free(0);
 
 	if (the_lnet.ln_counters != NULL) {
 		cfs_percpt_free(the_lnet.ln_counters);
@@ -1515,6 +1515,8 @@ lnet_create_ping_info(void)
 	pinfo->pi_pid     = the_lnet.ln_pid;
 	pinfo->pi_magic   = LNET_PROTO_PING_MAGIC;
 	pinfo->pi_features = LNET_PING_FEAT_NI_STATUS;
+	if (!the_lnet.ln_routing)
+		pinfo->pi_features |= LNET_PING_FEAT_RTE_DISABLED;
 
 	for (i = 0; i < n; i++) {
 		lnet_ni_status_t *ns = &pinfo->pi_ni[i];
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 021a81d..e1461af 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -935,9 +935,6 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 	rbp = lnet_msg2bufpool(msg);
 
 	if (!msg->msg_rtrcredit) {
-		LASSERT((rbp->rbp_credits < 0) ==
-			 !list_empty(&rbp->rbp_msgs));
-
 		msg->msg_rtrcredit = 1;
 		rbp->rbp_credits--;
 		if (rbp->rbp_credits < rbp->rbp_mincredits)
@@ -1029,6 +1026,43 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 }
 
 void
+lnet_schedule_blocked_locked(lnet_rtrbufpool_t *rbp)
+{
+	lnet_msg_t *msg;
+
+	if (list_empty(&rbp->rbp_msgs))
+		return;
+	msg = list_entry(rbp->rbp_msgs.next,
+			 lnet_msg_t, msg_list);
+	list_del(&msg->msg_list);
+
+	(void)lnet_post_routed_recv_locked(msg, 1);
+}
+
+void
+lnet_drop_routed_msgs_locked(struct list_head *list, int cpt)
+{
+	struct list_head drop;
+	lnet_msg_t *msg;
+	lnet_msg_t *tmp;
+
+	INIT_LIST_HEAD(&drop);
+
+	list_splice_init(list, &drop);
+
+	lnet_net_unlock(cpt);
+
+	list_for_each_entry_safe(msg, tmp, &drop, msg_list) {
+		lnet_ni_recv(msg->msg_rxpeer->lp_ni, msg->msg_private, NULL,
+			     0, 0, 0, msg->msg_hdr.payload_length);
+		list_del_init(&msg->msg_list);
+		lnet_finalize(NULL, msg, -ECANCELED);
+	}
+
+	lnet_net_lock(cpt);
+}
+
+void
 lnet_return_rx_credits_locked(lnet_msg_t *msg)
 {
 	lnet_peer_t *rxpeer = msg->msg_rxpeer;
@@ -1046,27 +1080,41 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 
 		rb = list_entry(msg->msg_kiov, lnet_rtrbuf_t, rb_kiov[0]);
 		rbp = rb->rb_pool;
-		LASSERT(rbp == lnet_msg2bufpool(msg));
 
 		msg->msg_kiov = NULL;
 		msg->msg_rtrcredit = 0;
 
-		LASSERT((rbp->rbp_credits < 0) ==
-			!list_empty(&rbp->rbp_msgs));
+		LASSERT(rbp == lnet_msg2bufpool(msg));
+
 		LASSERT((rbp->rbp_credits > 0) ==
 			!list_empty(&rbp->rbp_bufs));
 
-		list_add(&rb->rb_list, &rbp->rbp_bufs);
-		rbp->rbp_credits++;
-		if (rbp->rbp_credits <= 0) {
-			msg2 = list_entry(rbp->rbp_msgs.next,
-					      lnet_msg_t, msg_list);
-			list_del(&msg2->msg_list);
+		/*
+		 * If routing is now turned off, we just drop this buffer and
+		 * don't bother trying to return credits.
+		 */
+		if (!the_lnet.ln_routing) {
+			lnet_destroy_rtrbuf(rb, rbp->rbp_npages);
+			goto routing_off;
+		}
 
-			(void) lnet_post_routed_recv_locked(msg2, 1);
+		/*
+		 * It is possible that a user has lowered the desired number of
+		 * buffers in this pool.  Make sure we never put back
+		 * more buffers than the stated number.
+		 */
+		if (rbp->rbp_credits >= rbp->rbp_nbuffers) {
+			/* Discard this buffer so we don't have too many. */
+			lnet_destroy_rtrbuf(rb, rbp->rbp_npages);
+		} else {
+			list_add(&rb->rb_list, &rbp->rbp_bufs);
+			rbp->rbp_credits++;
+			if (rbp->rbp_credits <= 0)
+				lnet_schedule_blocked_locked(rbp);
 		}
 	}
 
+routing_off:
 	if (msg->msg_peerrtrcredit) {
 		/* give back peer router credits */
 		msg->msg_peerrtrcredit = 0;
@@ -1075,7 +1123,14 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 			!list_empty(&rxpeer->lp_rtrq));
 
 		rxpeer->lp_rtrcredits++;
-		if (rxpeer->lp_rtrcredits <= 0) {
+		/*
+		 * drop all messages which are queued to be routed on that
+		 * peer.
+		 */
+		if (!the_lnet.ln_routing) {
+			lnet_drop_routed_msgs_locked(&rxpeer->lp_rtrq,
+						     msg->msg_rx_cpt);
+		} else if (rxpeer->lp_rtrcredits <= 0) {
 			msg2 = list_entry(rxpeer->lp_rtrq.next,
 					      lnet_msg_t, msg_list);
 			list_del(&msg2->msg_list);
@@ -1625,6 +1680,9 @@ lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 {
 	int rc = 0;
 
+	if (!the_lnet.ln_routing)
+		return -ECANCELED;
+
 	if (msg->msg_rxpeer->lp_rtrcredits <= 0 ||
 	    lnet_msg2bufpool(msg)->rbp_credits <= 0) {
 		if (ni->ni_lnd->lnd_eager_recv == NULL) {
@@ -1780,9 +1838,8 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 	if (the_lnet.ln_routing &&
 	    ni->ni_last_alive != ktime_get_real_seconds()) {
-		lnet_ni_lock(ni);
-
 		/* NB: so far here is the only place to set NI status to "up */
+		lnet_ni_lock(ni);
 		ni->ni_last_alive = ktime_get_real_seconds();
 		if (ni->ni_status != NULL &&
 		    ni->ni_status->ns_status == LNET_NI_STATUS_DOWN)
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 47f80aa..749085f 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -28,8 +28,11 @@
 #define LNET_NRB_TINY		(LNET_NRB_TINY_MIN * 4)
 #define LNET_NRB_SMALL_MIN	4096	/* min value for each CPT */
 #define LNET_NRB_SMALL		(LNET_NRB_SMALL_MIN * 4)
+#define LNET_NRB_SMALL_PAGES	1
 #define LNET_NRB_LARGE_MIN	256	/* min value for each CPT */
 #define LNET_NRB_LARGE		(LNET_NRB_LARGE_MIN * 4)
+#define LNET_NRB_LARGE_PAGES   ((LNET_MTU + PAGE_CACHE_SIZE - 1) >> \
+				 PAGE_CACHE_SHIFT)
 
 static char *forwarding = "";
 module_param(forwarding, charp, 0444);
@@ -566,7 +569,8 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
 					*hops     = route->lr_hops;
 					*priority = route->lr_priority;
 					*gateway  = route->lr_gateway->lp_nid;
-					*alive    = route->lr_gateway->lp_alive;
+					*alive = route->lr_gateway->lp_alive &&
+						 !route->lr_downis;
 					lnet_net_unlock(cpt);
 					return 0;
 				}
@@ -604,7 +608,7 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 {
 	lnet_ping_info_t *info = rcd->rcd_pinginfo;
 	struct lnet_peer *gw = rcd->rcd_gateway;
-	lnet_route_t *rtr;
+	lnet_route_t *rte;
 
 	if (!gw->lp_alive)
 		return;
@@ -630,11 +634,16 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 	if ((gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) == 0)
 		return; /* can't carry NI status info */
 
-	list_for_each_entry(rtr, &gw->lp_routes, lr_gwlist) {
+	list_for_each_entry(rte, &gw->lp_routes, lr_gwlist) {
 		int down = 0;
 		int up = 0;
 		int i;
 
+		if ((gw->lp_ping_feats & LNET_PING_FEAT_RTE_DISABLED) != 0) {
+			rte->lr_downis = 1;
+			continue;
+		}
+
 		for (i = 0; i < info->pi_nnis && i < LNET_MAX_RTR_NIS; i++) {
 			lnet_ni_status_t *stat = &info->pi_ni[i];
 			lnet_nid_t nid = stat->ns_nid;
@@ -655,7 +664,7 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 			}
 
 			if (stat->ns_status == LNET_NI_STATUS_UP) {
-				if (LNET_NIDNET(nid) == rtr->lr_net) {
+				if (LNET_NIDNET(nid) == rte->lr_net) {
 					up = 1;
 					break;
 				}
@@ -669,10 +678,10 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 		}
 
 		if (up) { /* ignore downed NIs if NI for dest network is up */
-			rtr->lr_downis = 0;
+			rte->lr_downis = 0;
 			continue;
 		}
-		rtr->lr_downis = down;
+		rte->lr_downis = down;
 	}
 }
 
@@ -1209,7 +1218,7 @@ rescan:
 	return 0;
 }
 
-static void
+void
 lnet_destroy_rtrbuf(lnet_rtrbuf_t *rb, int npages)
 {
 	int sz = offsetof(lnet_rtrbuf_t, rb_kiov[npages]);
@@ -1256,66 +1265,103 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 }
 
 static void
-lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp)
+lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp, int cpt)
 {
 	int npages = rbp->rbp_npages;
-	int nbuffers = 0;
+	struct list_head tmp;
 	lnet_rtrbuf_t *rb;
 
 	if (rbp->rbp_nbuffers == 0) /* not initialized or already freed */
 		return;
 
-	LASSERT(list_empty(&rbp->rbp_msgs));
-	LASSERT(rbp->rbp_credits == rbp->rbp_nbuffers);
+	INIT_LIST_HEAD(&tmp);
 
-	while (!list_empty(&rbp->rbp_bufs)) {
-		LASSERT(rbp->rbp_credits > 0);
+	lnet_net_lock(cpt);
+	lnet_drop_routed_msgs_locked(&rbp->rbp_msgs, cpt);
+	list_splice_init(&rbp->rbp_bufs, &tmp);
+	rbp->rbp_nbuffers = 0;
+	rbp->rbp_credits = 0;
+	rbp->rbp_mincredits = 0;
+	lnet_net_unlock(cpt);
 
-		rb = list_entry(rbp->rbp_bufs.next,
-				    lnet_rtrbuf_t, rb_list);
+	/* Free buffers on the free list. */
+	while (!list_empty(&tmp)) {
+		rb = list_entry(tmp.next, lnet_rtrbuf_t, rb_list);
 		list_del(&rb->rb_list);
 		lnet_destroy_rtrbuf(rb, npages);
-		nbuffers++;
 	}
-
-	LASSERT(rbp->rbp_nbuffers == nbuffers);
-	LASSERT(rbp->rbp_credits == nbuffers);
-
-	rbp->rbp_nbuffers = rbp->rbp_credits = 0;
 }
 
 static int
-lnet_rtrpool_alloc_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
+lnet_rtrpool_adjust_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
 {
+	struct list_head rb_list;
 	lnet_rtrbuf_t *rb;
-	int i;
+	int num_rb;
+	int num_buffers = 0;
+	int npages = rbp->rbp_npages;
 
-	if (rbp->rbp_nbuffers != 0) {
-		LASSERT(rbp->rbp_nbuffers == nbufs);
+	/*
+	 * If we are called for less buffers than already in the pool, we
+	 * just lower the nbuffers number and excess buffers will be
+	 * thrown away as they are returned to the free list.  Credits
+	 * then get adjusted as well.
+	 */
+	if (nbufs <= rbp->rbp_nbuffers) {
+		lnet_net_lock(cpt);
+		rbp->rbp_nbuffers = nbufs;
+		lnet_net_unlock(cpt);
 		return 0;
 	}
 
-	for (i = 0; i < nbufs; i++) {
-		rb = lnet_new_rtrbuf(rbp, cpt);
+	INIT_LIST_HEAD(&rb_list);
 
+	/*
+	 * allocate the buffers on a local list first.  If all buffers are
+	 * allocated successfully then join this list to the rbp buffer
+	 * list. If not then free all allocated buffers.
+	 */
+	num_rb = rbp->rbp_nbuffers;
+
+	while (num_rb < nbufs) {
+		rb = lnet_new_rtrbuf(rbp, cpt);
 		if (rb == NULL) {
-			CERROR("Failed to allocate %d router bufs of %d pages\n",
-			       nbufs, rbp->rbp_npages);
-			return -ENOMEM;
+			CERROR("Failed to allocate %d route bufs of %d pages\n",
+			       nbufs, npages);
+			goto failed;
 		}
 
-		rbp->rbp_nbuffers++;
-		rbp->rbp_credits++;
-		rbp->rbp_mincredits++;
-		list_add(&rb->rb_list, &rbp->rbp_bufs);
-
-		/* No allocation "under fire" */
-		/* Otherwise we'd need code to schedule blocked msgs etc */
-		LASSERT(!the_lnet.ln_routing);
+		list_add(&rb->rb_list, &rb_list);
+		num_buffers++;
+		num_rb++;
 	}
 
-	LASSERT(rbp->rbp_credits == nbufs);
+	lnet_net_lock(cpt);
+
+	list_splice_tail(&rb_list, &rbp->rbp_bufs);
+	rbp->rbp_nbuffers += num_buffers;
+	rbp->rbp_credits += num_buffers;
+	rbp->rbp_mincredits = rbp->rbp_credits;
+	/*
+	 * We need to schedule blocked msg using the newly
+	 * added buffers.
+	 */
+	while (!list_empty(&rbp->rbp_bufs) &&
+	       !list_empty(&rbp->rbp_msgs))
+		lnet_schedule_blocked_locked(rbp);
+
+	lnet_net_unlock(cpt);
+
 	return 0;
+
+failed:
+	while (!list_empty(&rb_list)) {
+		rb = list_entry(rb_list.next, lnet_rtrbuf_t, rb_list);
+		list_del(&rb->rb_list);
+		lnet_destroy_rtrbuf(rb, npages);
+	}
+
+	return -ENOMEM;
 }
 
 static void
@@ -1330,7 +1376,7 @@ lnet_rtrpool_init(lnet_rtrbufpool_t *rbp, int npages)
 }
 
 void
-lnet_rtrpools_free(void)
+lnet_rtrpools_free(int keep_pools)
 {
 	lnet_rtrbufpool_t *rtrp;
 	int i;
@@ -1339,17 +1385,19 @@ lnet_rtrpools_free(void)
 		return;
 
 	cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
-		lnet_rtrpool_free_bufs(&rtrp[0]);
-		lnet_rtrpool_free_bufs(&rtrp[1]);
-		lnet_rtrpool_free_bufs(&rtrp[2]);
+		lnet_rtrpool_free_bufs(&rtrp[LNET_TINY_BUF_IDX], i);
+		lnet_rtrpool_free_bufs(&rtrp[LNET_SMALL_BUF_IDX], i);
+		lnet_rtrpool_free_bufs(&rtrp[LNET_LARGE_BUF_IDX], i);
 	}
 
-	cfs_percpt_free(the_lnet.ln_rtrpools);
-	the_lnet.ln_rtrpools = NULL;
+	if (!keep_pools) {
+		cfs_percpt_free(the_lnet.ln_rtrpools);
+		the_lnet.ln_rtrpools = NULL;
+	}
 }
 
 static int
-lnet_nrb_tiny_calculate(int npages)
+lnet_nrb_tiny_calculate(void)
 {
 	int nrbs = LNET_NRB_TINY;
 
@@ -1368,7 +1416,7 @@ lnet_nrb_tiny_calculate(int npages)
 }
 
 static int
-lnet_nrb_small_calculate(int npages)
+lnet_nrb_small_calculate(void)
 {
 	int nrbs = LNET_NRB_SMALL;
 
@@ -1387,7 +1435,7 @@ lnet_nrb_small_calculate(int npages)
 }
 
 static int
-lnet_nrb_large_calculate(int npages)
+lnet_nrb_large_calculate(void)
 {
 	int nrbs = LNET_NRB_LARGE;
 
@@ -1409,16 +1457,12 @@ int
 lnet_rtrpools_alloc(int im_a_router)
 {
 	lnet_rtrbufpool_t *rtrp;
-	int large_pages;
-	int small_pages = 1;
 	int nrb_tiny;
 	int nrb_small;
 	int nrb_large;
 	int rc;
 	int i;
 
-	large_pages = (LNET_MTU + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-
 	if (!strcmp(forwarding, "")) {
 		/* not set either way */
 		if (!im_a_router)
@@ -1433,15 +1477,15 @@ lnet_rtrpools_alloc(int im_a_router)
 		return -EINVAL;
 	}
 
-	nrb_tiny = lnet_nrb_tiny_calculate(0);
+	nrb_tiny = lnet_nrb_tiny_calculate();
 	if (nrb_tiny < 0)
 		return -EINVAL;
 
-	nrb_small = lnet_nrb_small_calculate(small_pages);
+	nrb_small = lnet_nrb_small_calculate();
 	if (nrb_small < 0)
 		return -EINVAL;
 
-	nrb_large = lnet_nrb_large_calculate(large_pages);
+	nrb_large = lnet_nrb_large_calculate();
 	if (nrb_large < 0)
 		return -EINVAL;
 
@@ -1455,18 +1499,23 @@ lnet_rtrpools_alloc(int im_a_router)
 	}
 
 	cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
-		lnet_rtrpool_init(&rtrp[0], 0);
-		rc = lnet_rtrpool_alloc_bufs(&rtrp[0], nrb_tiny, i);
+		lnet_rtrpool_init(&rtrp[LNET_TINY_BUF_IDX], 0);
+		rc = lnet_rtrpool_adjust_bufs(&rtrp[LNET_TINY_BUF_IDX],
+					      nrb_tiny, i);
 		if (rc != 0)
 			goto failed;
 
-		lnet_rtrpool_init(&rtrp[1], small_pages);
-		rc = lnet_rtrpool_alloc_bufs(&rtrp[1], nrb_small, i);
+		lnet_rtrpool_init(&rtrp[LNET_SMALL_BUF_IDX],
+				  LNET_NRB_SMALL_PAGES);
+		rc = lnet_rtrpool_adjust_bufs(&rtrp[LNET_SMALL_BUF_IDX],
+					      nrb_small, i);
 		if (rc != 0)
 			goto failed;
 
-		lnet_rtrpool_init(&rtrp[2], large_pages);
-		rc = lnet_rtrpool_alloc_bufs(&rtrp[2], nrb_large, i);
+		lnet_rtrpool_init(&rtrp[LNET_LARGE_BUF_IDX],
+				  LNET_NRB_LARGE_PAGES);
+		rc = lnet_rtrpool_adjust_bufs(&rtrp[LNET_LARGE_BUF_IDX],
+					      nrb_large, i);
 		if (rc != 0)
 			goto failed;
 	}
@@ -1478,11 +1527,114 @@ lnet_rtrpools_alloc(int im_a_router)
 	return 0;
 
  failed:
-	lnet_rtrpools_free();
+	lnet_rtrpools_free(0);
 	return rc;
 }
 
 int
+lnet_rtrpools_adjust(int tiny, int small, int large)
+{
+	int nrb = 0;
+	int rc = 0;
+	int i;
+	lnet_rtrbufpool_t *rtrp;
+
+	/*
+	 * this function doesn't revert the changes if adding new buffers
+	 * failed.  It's up to the user space caller to revert the
+	 * changes.
+	 */
+
+	if (!the_lnet.ln_routing)
+		return 0;
+
+	/*
+	 * If the provided values for each buffer pool are different than the
+	 * configured values, we need to take action.
+	 */
+	if (tiny >= 0 && tiny != tiny_router_buffers) {
+		tiny_router_buffers = tiny;
+		nrb = lnet_nrb_tiny_calculate();
+		cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
+			rc = lnet_rtrpool_adjust_bufs(&rtrp[LNET_TINY_BUF_IDX],
+						      nrb, i);
+			if (rc != 0)
+				return rc;
+		}
+	}
+	if (small >= 0 && small != small_router_buffers) {
+		small_router_buffers = small;
+		nrb = lnet_nrb_small_calculate();
+		cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
+			rc = lnet_rtrpool_adjust_bufs(&rtrp[LNET_SMALL_BUF_IDX],
+						      nrb, i);
+			if (rc != 0)
+				return rc;
+		}
+	}
+	if (large >= 0 && large != large_router_buffers) {
+		large_router_buffers = large;
+		nrb = lnet_nrb_large_calculate();
+		cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
+			rc = lnet_rtrpool_adjust_bufs(&rtrp[LNET_LARGE_BUF_IDX],
+						      nrb, i);
+			if (rc != 0)
+				return rc;
+		}
+	}
+
+	return 0;
+}
+
+int
+lnet_rtrpools_enable(void)
+{
+	int rc;
+
+	if (the_lnet.ln_routing)
+		return 0;
+
+	if (!the_lnet.ln_rtrpools)
+		/*
+		 * If routing is turned off, and we have never
+		 * initialized the pools before, just call the
+		 * standard buffer pool allocation routine as
+		 * if we are just configuring this for the first
+		 * time.
+		 */
+		return lnet_rtrpools_alloc(1);
+
+	rc = lnet_rtrpools_adjust(0, 0, 0);
+	if (rc != 0)
+		return rc;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	the_lnet.ln_routing = 1;
+
+	the_lnet.ln_ping_info->pi_features &= ~LNET_PING_FEAT_RTE_DISABLED;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	return 0;
+}
+
+void
+lnet_rtrpools_disable(void)
+{
+	if (!the_lnet.ln_routing)
+		return;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	the_lnet.ln_routing = 0;
+	the_lnet.ln_ping_info->pi_features |= LNET_PING_FEAT_RTE_DISABLED;
+
+	tiny_router_buffers = 0;
+	small_router_buffers = 0;
+	large_router_buffers = 0;
+	lnet_net_unlock(LNET_LOCK_EX);
+	lnet_rtrpools_free(1);
+}
+
+int
 lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 {
 	struct lnet_peer *lp = NULL;
-- 
1.7.1
