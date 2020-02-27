From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:17 -0500
Subject: [lustre-devel] [PATCH 269/622] lnet: o2iblnd: kib_conn leak
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-270-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

A new tx can be queued while kiblnd_finalise_conn()
aborts txs. Thus a reference from new tx will
prevent connection from moving into kib_connd_zombies.

Insert new tx after IBLND_CONN_DISCONNECTED into
ibc_zombie_txs list and abort it during
kiblnd_destroy_conn().

Cray-bug-id: LUS-6412
WC-bug-id: https://jira.whamcloud.com/browse/LU-11756
Lustre-commit: a155c3fca38d ("LU-11756 o2iblnd: kib_conn leak")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/33828
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  4 ++++
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  5 ++++-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 21 ++++++++++++++++++---
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 0e207ef..bb7590f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -744,6 +744,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	INIT_LIST_HEAD(&conn->ibc_tx_queue_rsrvd);
 	INIT_LIST_HEAD(&conn->ibc_tx_queue_nocred);
 	INIT_LIST_HEAD(&conn->ibc_active_txs);
+	INIT_LIST_HEAD(&conn->ibc_zombie_txs);
 	spin_lock_init(&conn->ibc_lock);
 
 	conn->ibc_connvars = kzalloc_cpt(sizeof(*conn->ibc_connvars), GFP_NOFS, cpt);
@@ -951,6 +952,9 @@ void kiblnd_destroy_conn(struct kib_conn *conn)
 	if (conn->ibc_cq)
 		ib_destroy_cq(conn->ibc_cq);
 
+	kiblnd_txlist_done(&conn->ibc_zombie_txs, -ECONNABORTED,
+			   LNET_MSG_STATUS_OK);
+
 	if (conn->ibc_rx_pages)
 		kiblnd_unmap_rx_descs(conn);
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index baf1006..eb80d5e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -581,7 +581,9 @@ struct kib_conn {
 	struct list_head	ibc_tx_queue_rsrvd;   /* sends that need to */
 						      /* reserve an ACK/DONE msg */
 	struct list_head	ibc_active_txs;	/* active tx awaiting completion */
-	spinlock_t		ibc_lock;	/* serialise */
+	spinlock_t		ibc_lock;	/* zombie tx awaiting done */
+	struct list_head	ibc_zombie_txs;
+	/* serialise */
 	struct kib_rx		*ibc_rxs;	/* the rx descs */
 	struct kib_pages	*ibc_rx_pages;	/* premapped rx msg pages */
 
@@ -1005,6 +1007,7 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 #define KIBLND_CONN_PARAM(e)		((e)->param.conn.private_data)
 #define KIBLND_CONN_PARAM_LEN(e)	((e)->param.conn.private_data_len)
 
+void kiblnd_abort_txs(struct kib_conn *conn, struct list_head *txs);
 void kiblnd_map_rx_descs(struct kib_conn *conn);
 void kiblnd_unmap_rx_descs(struct kib_conn *conn);
 void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index fa5c93a..a3abbb6 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1211,6 +1211,21 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(!tx->tx_queued);	/* not queued for sending already */
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
+	if (conn->ibc_state >= IBLND_CONN_DISCONNECTED) {
+		tx->tx_status = -ECONNABORTED;
+		tx->tx_waiting = 0;
+		if (tx->tx_conn) {
+			/* PUT_DONE first attached to conn as a PUT_REQ */
+			LASSERT(tx->tx_conn == conn);
+			LASSERT(tx->tx_msg->ibm_type == IBLND_MSG_PUT_DONE);
+			tx->tx_conn = NULL;
+			kiblnd_conn_decref(conn);
+		}
+		list_add(&tx->tx_list, &conn->ibc_zombie_txs);
+
+		return;
+	}
+
 	timeout_ns = lnet_get_lnd_timeout() * NSEC_PER_SEC;
 	tx->tx_queued = 1;
 	tx->tx_deadline = ktime_add_ns(ktime_get(), timeout_ns);
@@ -2056,7 +2071,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 }
 
-static void
+void
 kiblnd_abort_txs(struct kib_conn *conn, struct list_head *txs)
 {
 	LIST_HEAD(zombies);
@@ -2123,8 +2138,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	LASSERT(!in_interrupt());
 	LASSERT(conn->ibc_state > IBLND_CONN_INIT);
 
-	kiblnd_set_conn_state(conn, IBLND_CONN_DISCONNECTED);
-
 	/*
 	 * abort_receives moves QP state to IB_QPS_ERR.  This is only required
 	 * for connections that didn't get as far as being connected, because
@@ -2132,6 +2145,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	 */
 	kiblnd_abort_receives(conn);
 
+	kiblnd_set_conn_state(conn, IBLND_CONN_DISCONNECTED);
+
 	/*
 	 * Complete all tx descs not waiting for sends to complete.
 	 * NB we should be safe from RDMA now that the QP has changed state
-- 
1.8.3.1
