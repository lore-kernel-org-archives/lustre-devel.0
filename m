From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:51 -0400
Subject: [lustre-devel] [PATCH 7/8] staging: lustre: ko2iblnd: remove
 remaining jiffy use
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Convert the remaining jiffy use in ko2iblnd to time64_t and ktime_t.
The HZ value can be configured differently for a set of nodes and
this can lead to corner case problems with node to node interactions.
This allows lustre to have consistent behavior across nodes.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Reviewed-on: https://review.whamcloud.com/31042
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 37 +++++++++++-----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 24 +++++++-------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 26 +++++++--------
 3 files changed, 45 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index edae4eb..9f3fef5 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1445,7 +1445,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 	if (rc)
 		goto out_fpo;
 
-	fpo->fpo_deadline = jiffies + IBLND_POOL_DEADLINE * HZ;
+	fpo->fpo_deadline = ktime_get_seconds() + IBLND_POOL_DEADLINE;
 	fpo->fpo_owner = fps;
 	*pp_fpo = fpo;
 
@@ -1515,13 +1515,13 @@ static void kiblnd_fini_fmr_poolset(struct kib_fmr_poolset *fps)
 	return rc;
 }
 
-static int kiblnd_fmr_pool_is_idle(struct kib_fmr_pool *fpo, unsigned long now)
+static int kiblnd_fmr_pool_is_idle(struct kib_fmr_pool *fpo, time64_t now)
 {
 	if (fpo->fpo_map_count) /* still in use */
 		return 0;
 	if (fpo->fpo_failed)
 		return 1;
-	return time_after_eq(now, fpo->fpo_deadline);
+	return now >= fpo->fpo_deadline;
 }
 
 static int
@@ -1551,7 +1551,7 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 	LIST_HEAD(zombies);
 	struct kib_fmr_pool *fpo = fmr->fmr_pool;
 	struct kib_fmr_poolset *fps;
-	unsigned long now = jiffies;
+	time64_t now = ktime_get_seconds();
 	struct kib_fmr_pool *tmp;
 	int rc;
 
@@ -1618,7 +1618,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 	spin_lock(&fps->fps_lock);
 	version = fps->fps_version;
 	list_for_each_entry(fpo, &fps->fps_pool_list, fpo_list) {
-		fpo->fpo_deadline = jiffies + IBLND_POOL_DEADLINE * HZ;
+		fpo->fpo_deadline = ktime_get_seconds() + IBLND_POOL_DEADLINE;
 		fpo->fpo_map_count++;
 
 		if (fpo->fpo_is_fmr) {
@@ -1725,7 +1725,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		goto again;
 	}
 
-	if (time_before(jiffies, fps->fps_next_retry)) {
+	if (ktime_get_seconds() < fps->fps_next_retry) {
 		/* someone failed recently */
 		spin_unlock(&fps->fps_lock);
 		return -EAGAIN;
@@ -1742,7 +1742,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		fps->fps_version++;
 		list_add_tail(&fpo->fpo_list, &fps->fps_pool_list);
 	} else {
-		fps->fps_next_retry = jiffies + IBLND_POOL_RETRY * HZ;
+		fps->fps_next_retry = ktime_get_seconds() + IBLND_POOL_RETRY;
 	}
 	spin_unlock(&fps->fps_lock);
 
@@ -1763,7 +1763,7 @@ static void kiblnd_init_pool(struct kib_poolset *ps, struct kib_pool *pool, int
 
 	memset(pool, 0, sizeof(*pool));
 	INIT_LIST_HEAD(&pool->po_free_list);
-	pool->po_deadline = jiffies + IBLND_POOL_DEADLINE * HZ;
+	pool->po_deadline = ktime_get_seconds() + IBLND_POOL_DEADLINE;
 	pool->po_owner    = ps;
 	pool->po_size     = size;
 }
@@ -1843,13 +1843,13 @@ static int kiblnd_init_poolset(struct kib_poolset *ps, int cpt,
 	return rc;
 }
 
-static int kiblnd_pool_is_idle(struct kib_pool *pool, unsigned long now)
+static int kiblnd_pool_is_idle(struct kib_pool *pool, time64_t now)
 {
 	if (pool->po_allocated) /* still in use */
 		return 0;
 	if (pool->po_failed)
 		return 1;
-	return time_after_eq(now, pool->po_deadline);
+	return now >= pool->po_deadline;
 }
 
 void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node)
@@ -1857,7 +1857,7 @@ void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node)
 	LIST_HEAD(zombies);
 	struct kib_poolset *ps = pool->po_owner;
 	struct kib_pool *tmp;
-	unsigned long now = jiffies;
+	time64_t now = ktime_get_seconds();
 
 	spin_lock(&ps->ps_lock);
 
@@ -1887,7 +1887,7 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 	struct list_head *node;
 	struct kib_pool *pool;
 	unsigned int interval = 1;
-	unsigned long time_before;
+	ktime_t time_before;
 	unsigned int trips = 0;
 	int rc;
 
@@ -1898,7 +1898,8 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 			continue;
 
 		pool->po_allocated++;
-		pool->po_deadline = jiffies + IBLND_POOL_DEADLINE * HZ;
+		pool->po_deadline = ktime_get_seconds() +
+				    IBLND_POOL_DEADLINE;
 		node = pool->po_free_list.next;
 		list_del(node);
 
@@ -1926,7 +1927,7 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 		goto again;
 	}
 
-	if (time_before(jiffies, ps->ps_next_retry)) {
+	if (ktime_get_seconds() < ps->ps_next_retry) {
 		/* someone failed recently */
 		spin_unlock(&ps->ps_lock);
 		return NULL;
@@ -1936,17 +1937,17 @@ struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 	spin_unlock(&ps->ps_lock);
 
 	CDEBUG(D_NET, "%s pool exhausted, allocate new pool\n", ps->ps_name);
-	time_before = jiffies;
+	time_before = ktime_get();
 	rc = ps->ps_pool_create(ps, ps->ps_pool_size, &pool);
-	CDEBUG(D_NET, "ps_pool_create took %lu HZ to complete",
-	       jiffies - time_before);
+	CDEBUG(D_NET, "ps_pool_create took %lld ms to complete",
+	       ktime_ms_delta(ktime_get(), time_before));
 
 	spin_lock(&ps->ps_lock);
 	ps->ps_increasing = 0;
 	if (!rc) {
 		list_add_tail(&pool->po_list, &ps->ps_pool_list);
 	} else {
-		ps->ps_next_retry = jiffies + IBLND_POOL_RETRY * HZ;
+		ps->ps_next_retry = ktime_get_seconds() + IBLND_POOL_RETRY;
 		CERROR("Can't allocate new %s pool because out of memory\n",
 		       ps->ps_name);
 	}
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 1b141cc..635d7c6 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -155,7 +155,7 @@ struct kib_dev {
 	char               ibd_ifname[KIB_IFNAME_SIZE];
 	int                ibd_nnets;           /* # nets extant */
 
-	unsigned long      ibd_next_failover;
+	time64_t	   ibd_next_failover;
 	int                ibd_failed_failover; /* # failover failures */
 	unsigned int       ibd_failover;        /* failover in progress */
 	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
@@ -205,7 +205,7 @@ struct kib_poolset {
 	char                  ps_name[IBLND_POOL_NAME_LEN]; /* pool set name */
 	struct list_head      ps_pool_list;       /* list of pools */
 	struct list_head      ps_failed_pool_list;/* failed pool list */
-	unsigned long         ps_next_retry;      /* time stamp for retry if */
+	time64_t	      ps_next_retry;	  /* time stamp for retry if */
 						  /* failed to allocate */
 	int                   ps_increasing;      /* is allocating new pool */
 	int                   ps_pool_size;       /* new pool size */
@@ -221,7 +221,7 @@ struct kib_pool {
 	struct list_head      po_list;       /* chain on pool list */
 	struct list_head      po_free_list;  /* pre-allocated node */
 	struct kib_poolset	*po_owner;	/* pool_set of this pool */
-	unsigned long         po_deadline;   /* deadline of this pool */
+	time64_t		po_deadline;	/* deadline of this pool */
 	int                   po_allocated;  /* # of elements in use */
 	int                   po_failed;     /* pool is created on failed HCA */
 	int                   po_size;       /* # of pre-allocated elements */
@@ -250,8 +250,9 @@ struct kib_fmr_poolset {
 	int                   fps_flush_trigger;
 	int		      fps_cache;
 	int                   fps_increasing;      /* is allocating new pool */
-	unsigned long         fps_next_retry;      /* time stamp for retry if*/
-						   /* failed to allocate */
+	time64_t		fps_next_retry;		/* time stamp for retry
+							 * if failed to allocate
+							 */
 };
 
 struct kib_fast_reg_descriptor { /* For fast registration */
@@ -275,7 +276,7 @@ struct kib_fmr_pool {
 			int		    fpo_pool_size;
 		} fast_reg;
 	};
-	unsigned long         fpo_deadline;        /* deadline of this pool */
+	time64_t		fpo_deadline;	/* deadline of this pool */
 	int                   fpo_failed;          /* fmr pool is failed */
 	int                   fpo_map_count;       /* # of mapped FMR */
 	int		      fpo_is_fmr;
@@ -487,7 +488,7 @@ struct kib_tx {					/* transmit message */
 	short                 tx_queued;      /* queued for sending */
 	short                 tx_waiting;     /* waiting for peer */
 	int                   tx_status;      /* LNET completion status */
-	unsigned long         tx_deadline;    /* completion deadline */
+	ktime_t			tx_deadline;	/* completion deadline */
 	__u64                 tx_cookie;      /* completion cookie */
 	struct lnet_msg		*tx_lntmsg[2];	/* lnet msgs to finalize on completion */
 	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
@@ -533,7 +534,7 @@ struct kib_conn {
 	unsigned int          ibc_nrx:16;      /* receive buffers owned */
 	unsigned int          ibc_scheduled:1; /* scheduled for attention */
 	unsigned int          ibc_ready:1;     /* CQ callback fired */
-	unsigned long         ibc_last_send;   /* time of last send */
+	ktime_t			ibc_last_send;	/* time of last send */
 	struct list_head      ibc_connd_list;  /* link chain for */
 					       /* kiblnd_check_conns only */
 	struct list_head ibc_early_rxs; /* rxs completed before ESTABLISHED */
@@ -763,10 +764,11 @@ struct kib_peer {
 static inline int
 kiblnd_send_keepalive(struct kib_conn *conn)
 {
+	s64 keepalive_ns = *kiblnd_tunables.kib_keepalive * NSEC_PER_SEC;
+
 	return (*kiblnd_tunables.kib_keepalive > 0) &&
-		time_after(jiffies, conn->ibc_last_send +
-			   msecs_to_jiffies(*kiblnd_tunables.kib_keepalive *
-					    MSEC_PER_SEC));
+		ktime_after(ktime_get(),
+			    ktime_add_ns(conn->ibc_last_send, keepalive_ns));
 }
 
 static inline int
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b046f00..e4e8c3b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -852,7 +852,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		rc = ib_post_send(conn->ibc_cmid->qp, wrq, &bad);
 	}
 
-	conn->ibc_last_send = jiffies;
+	conn->ibc_last_send = ktime_get();
 
 	if (!rc)
 		return 0;
@@ -1137,15 +1137,15 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn)
 {
 	struct list_head *q;
+	s64 timeout_ns;
 
 	LASSERT(tx->tx_nwrq > 0);	      /* work items set up */
 	LASSERT(!tx->tx_queued);	       /* not queued for sending already */
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
+	timeout_ns = *kiblnd_tunables.kib_timeout * NSEC_PER_SEC;
 	tx->tx_queued = 1;
-	tx->tx_deadline = jiffies +
-			  msecs_to_jiffies(*kiblnd_tunables.kib_timeout *
-					   MSEC_PER_SEC);
+	tx->tx_deadline = ktime_add_ns(ktime_get(), timeout_ns);
 
 	if (!tx->tx_conn) {
 		kiblnd_conn_addref(conn);
@@ -2135,7 +2135,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	/* connection established */
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	conn->ibc_last_send = jiffies;
+	conn->ibc_last_send = ktime_get();
 	kiblnd_set_conn_state(conn, IBLND_CONN_ESTABLISHED);
 	kiblnd_peer_alive(peer);
 
@@ -3153,10 +3153,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			LASSERT(tx->tx_waiting || tx->tx_sending);
 		}
 
-		if (time_after_eq(jiffies, tx->tx_deadline)) {
-			CERROR("Timed out tx: %s, %lu seconds\n",
+		if (ktime_compare(ktime_get(), tx->tx_deadline) >= 0) {
+			CERROR("Timed out tx: %s, %lld seconds\n",
 			       kiblnd_queue2str(conn, txs),
-			       (jiffies - tx->tx_deadline) / HZ);
+			       ktime_ms_delta(ktime_get(),
+					      tx->tx_deadline) / MSEC_PER_SEC);
 			return 1;
 		}
 	}
@@ -3692,8 +3693,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 		list_for_each_entry(dev, &kiblnd_data.kib_failed_devs,
 				    ibd_fail_list) {
-			if (time_before(jiffies,
-					dev->ibd_next_failover))
+			if (ktime_get_seconds() < dev->ibd_next_failover)
 				continue;
 			do_failover = 1;
 			break;
@@ -3711,13 +3711,13 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			LASSERT(dev->ibd_failover);
 			dev->ibd_failover = 0;
 			if (rc >= 0) { /* Device is OK or failover succeed */
-				dev->ibd_next_failover = jiffies + 3 * HZ;
+				dev->ibd_next_failover = ktime_get_seconds() + 3;
 				continue;
 			}
 
 			/* failed to failover, retry later */
-			dev->ibd_next_failover =
-				jiffies + min(dev->ibd_failed_failover, 10) * HZ;
+			dev->ibd_next_failover = ktime_get_seconds() +
+						 min(dev->ibd_failed_failover, 10);
 			if (kiblnd_dev_can_failover(dev)) {
 				list_add_tail(&dev->ibd_fail_list,
 					      &kiblnd_data.kib_failed_devs);
-- 
1.8.3.1
