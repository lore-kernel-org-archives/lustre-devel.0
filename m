From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 18:53:24 -0500
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: Support different
	ko2iblnd configs between systems
In-Reply-To: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
References: <1456962810-21806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456962810-21806-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jeremy Filizetti <jeremy.filizetti@gmail.com>

From: Jeremy Filizetti <jeremy.filizetti@gmail.com>

This patch adds suppoort for ko2iblnd to have different values for
peer_credits and map_on_demand between systems.

Signed-off-by: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3322
Reviewed-on: http://review.whamcloud.com/11794
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   51 ++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   36 +++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  156 ++++++++++++--------
 3 files changed, 146 insertions(+), 97 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 1dc18d7..0b1ffbe 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -631,7 +631,7 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 }
 
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-			       int state, int version)
+			       int state, int version, kib_connparams_t *cp)
 {
 	/*
 	 * CAVEAT EMPTOR:
@@ -686,6 +686,14 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	cmid->context = conn;		   /* for future CM callbacks */
 	conn->ibc_cmid = cmid;
 
+	if (!cp) {
+		conn->ibc_max_frags = IBLND_CFG_RDMA_FRAGS;
+		conn->ibc_queue_depth = *kiblnd_tunables.kib_peertxcredits;
+	} else {
+		conn->ibc_max_frags = cp->ibcp_max_frags;
+		conn->ibc_queue_depth = cp->ibcp_queue_depth;
+	}
+
 	INIT_LIST_HEAD(&conn->ibc_early_rxs);
 	INIT_LIST_HEAD(&conn->ibc_tx_noops);
 	INIT_LIST_HEAD(&conn->ibc_tx_queue);
@@ -730,27 +738,27 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	write_unlock_irqrestore(glock, flags);
 
 	LIBCFS_CPT_ALLOC(conn->ibc_rxs, lnet_cpt_table(), cpt,
-			 IBLND_RX_MSGS(version) * sizeof(kib_rx_t));
+			 IBLND_RX_MSGS(conn) * sizeof(kib_rx_t));
 	if (!conn->ibc_rxs) {
 		CERROR("Cannot allocate RX buffers\n");
 		goto failed_2;
 	}
 
 	rc = kiblnd_alloc_pages(&conn->ibc_rx_pages, cpt,
-				IBLND_RX_MSG_PAGES(version));
+				IBLND_RX_MSG_PAGES(conn));
 	if (rc)
 		goto failed_2;
 
 	kiblnd_map_rx_descs(conn);
 
-	cq_attr.cqe = IBLND_CQ_ENTRIES(version);
+	cq_attr.cqe = IBLND_CQ_ENTRIES(conn);
 	cq_attr.comp_vector = kiblnd_get_completion_vector(conn, cpt);
 	cq = ib_create_cq(cmid->device,
 			  kiblnd_cq_completion, kiblnd_cq_event, conn,
 			  &cq_attr);
 	if (IS_ERR(cq)) {
-		CERROR("Can't create CQ: %ld, cqe: %d\n",
-		       PTR_ERR(cq), IBLND_CQ_ENTRIES(version));
+		CERROR("Failed to create CQ with %d CQEs: %ld\n",
+		       IBLND_CQ_ENTRIES(conn), PTR_ERR(cq));
 		goto failed_2;
 	}
 
@@ -764,8 +772,8 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	init_qp_attr->event_handler = kiblnd_qp_event;
 	init_qp_attr->qp_context = conn;
-	init_qp_attr->cap.max_send_wr = IBLND_SEND_WRS(version);
-	init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(version);
+	init_qp_attr->cap.max_send_wr = IBLND_SEND_WRS(conn);
+	init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
 	init_qp_attr->cap.max_send_sge = 1;
 	init_qp_attr->cap.max_recv_sge = 1;
 	init_qp_attr->sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -786,11 +794,11 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	LIBCFS_FREE(init_qp_attr, sizeof(*init_qp_attr));
 
 	/* 1 ref for caller and each rxmsg */
-	atomic_set(&conn->ibc_refcount, 1 + IBLND_RX_MSGS(version));
-	conn->ibc_nrx = IBLND_RX_MSGS(version);
+	atomic_set(&conn->ibc_refcount, 1 + IBLND_RX_MSGS(conn));
+	conn->ibc_nrx = IBLND_RX_MSGS(conn);
 
 	/* post receives */
-	for (i = 0; i < IBLND_RX_MSGS(version); i++) {
+	for (i = 0; i < IBLND_RX_MSGS(conn); i++) {
 		rc = kiblnd_post_rx(&conn->ibc_rxs[i],
 				    IBLND_POSTRX_NO_CREDIT);
 		if (rc) {
@@ -804,7 +812,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 			 * NB locking needed now I'm racing with completion
 			 */
 			spin_lock_irqsave(&sched->ibs_lock, flags);
-			conn->ibc_nrx -= IBLND_RX_MSGS(version) - i;
+			conn->ibc_nrx -= IBLND_RX_MSGS(conn) - i;
 			spin_unlock_irqrestore(&sched->ibs_lock, flags);
 
 			/*
@@ -816,7 +824,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 			conn->ibc_cmid = NULL;
 
 			/* Drop my own and unused rxbuffer refcounts */
-			while (i++ <= IBLND_RX_MSGS(version))
+			while (i++ <= IBLND_RX_MSGS(conn))
 				kiblnd_conn_decref(conn);
 
 			return NULL;
@@ -886,8 +894,7 @@ void kiblnd_destroy_conn(kib_conn_t *conn)
 
 	if (conn->ibc_rxs) {
 		LIBCFS_FREE(conn->ibc_rxs,
-			    IBLND_RX_MSGS(conn->ibc_version)
-			      * sizeof(kib_rx_t));
+			    IBLND_RX_MSGS(conn) * sizeof(kib_rx_t));
 	}
 
 	if (conn->ibc_connvars)
@@ -1143,7 +1150,7 @@ void kiblnd_unmap_rx_descs(kib_conn_t *conn)
 	LASSERT(conn->ibc_rxs);
 	LASSERT(conn->ibc_hdev);
 
-	for (i = 0; i < IBLND_RX_MSGS(conn->ibc_version); i++) {
+	for (i = 0; i < IBLND_RX_MSGS(conn); i++) {
 		rx = &conn->ibc_rxs[i];
 
 		LASSERT(rx->rx_nob >= 0); /* not posted */
@@ -1167,7 +1174,7 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 	int ipg;
 	int i;
 
-	for (pg_off = ipg = i = 0; i < IBLND_RX_MSGS(conn->ibc_version); i++) {
+	for (pg_off = ipg = i = 0; i < IBLND_RX_MSGS(conn); i++) {
 		pg = conn->ibc_rx_pages->ibp_pages[ipg];
 		rx = &conn->ibc_rxs[i];
 
@@ -1192,7 +1199,7 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 		if (pg_off == PAGE_SIZE) {
 			pg_off = 0;
 			ipg++;
-			LASSERT(ipg <= IBLND_RX_MSG_PAGES(conn->ibc_version));
+			LASSERT(ipg <= IBLND_RX_MSG_PAGES(conn));
 		}
 	}
 }
@@ -1296,12 +1303,16 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 	}
 }
 
-struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd)
+struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd,
+				    int negotiated_nfrags)
 {
+	__u16 nfrags = (negotiated_nfrags != -1) ?
+			negotiated_nfrags : *kiblnd_tunables.kib_map_on_demand;
+
 	LASSERT(hdev->ibh_mrs);
 
 	if (*kiblnd_tunables.kib_map_on_demand > 0 &&
-	    *kiblnd_tunables.kib_map_on_demand <= rd->rd_nfrags)
+	    nfrags <= rd->rd_nfrags)
 		return NULL;
 
 	return hdev->ibh_mrs;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 0c88e8b..59a26c4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -162,18 +162,17 @@ kiblnd_concurrent_sends_v1(void)
 #define IBLND_FMR_POOL			256
 #define IBLND_FMR_POOL_FLUSH		192
 
-/* TX messages (shared by all connections) */
-#define IBLND_TX_MSGS()	    (*kiblnd_tunables.kib_ntx)
-
-/* RX messages (per connection) */
-#define IBLND_RX_MSGS(v)	    (IBLND_MSG_QUEUE_SIZE(v) * 2 + IBLND_OOB_MSGS(v))
-#define IBLND_RX_MSG_BYTES(v)       (IBLND_RX_MSGS(v) * IBLND_MSG_SIZE)
-#define IBLND_RX_MSG_PAGES(v)      ((IBLND_RX_MSG_BYTES(v) + PAGE_SIZE - 1) / PAGE_SIZE)
+#define IBLND_RX_MSGS(c)	\
+	((c->ibc_queue_depth) * 2 + IBLND_OOB_MSGS(c->ibc_version))
+#define IBLND_RX_MSG_BYTES(c)	(IBLND_RX_MSGS(c) * IBLND_MSG_SIZE)
+#define IBLND_RX_MSG_PAGES(c)	\
+	((IBLND_RX_MSG_BYTES(c) + PAGE_SIZE - 1) / PAGE_SIZE)
 
 /* WRs and CQEs (per connection) */
-#define IBLND_RECV_WRS(v)	    IBLND_RX_MSGS(v)
-#define IBLND_SEND_WRS(v)	  ((IBLND_RDMA_FRAGS(v) + 1) * IBLND_CONCURRENT_SENDS(v))
-#define IBLND_CQ_ENTRIES(v)	 (IBLND_RECV_WRS(v) + IBLND_SEND_WRS(v))
+#define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
+#define IBLND_SEND_WRS(c)	\
+	((c->ibc_max_frags + 1) * IBLND_CONCURRENT_SENDS(c->ibc_version))
+#define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + IBLND_SEND_WRS(c))
 
 struct kib_hca_dev;
 
@@ -464,10 +463,10 @@ typedef struct {
 #define IBLND_REJECT_FATAL          3 /* Anything else */
 #define IBLND_REJECT_CONN_UNCOMPAT  4 /* incompatible version peer */
 #define IBLND_REJECT_CONN_STALE     5 /* stale peer */
-#define IBLND_REJECT_RDMA_FRAGS     6 /* Fatal: peer's rdma frags can't match */
-				      /* mine */
-#define IBLND_REJECT_MSG_QUEUE_SIZE 7 /* Fatal: peer's msg queue size can't */
-				      /* match mine */
+/* peer's rdma frags doesn't match mine */
+#define IBLND_REJECT_RDMA_FRAGS	    6
+/* peer's msg queue size doesn't match mine */
+#define IBLND_REJECT_MSG_QUEUE_SIZE 7
 
 /***********************************************************************/
 
@@ -535,6 +534,10 @@ typedef struct kib_conn {
 	int                   ibc_outstanding_credits; /* # credits to return */
 	int                   ibc_reserved_credits; /* # ACK/DONE msg credits */
 	int                   ibc_comms_error; /* set on comms error */
+	/* connections queue depth */
+	__u16		      ibc_queue_depth;
+	/* connections max frags */
+	__u16		      ibc_max_frags;
 	unsigned int          ibc_nrx:16;      /* receive buffers owned */
 	unsigned int          ibc_scheduled:1; /* scheduled for attention */
 	unsigned int          ibc_ready:1;     /* CQ callback fired */
@@ -907,7 +910,8 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 #define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
 
 struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev,
-				    kib_rdma_desc_t *rd);
+				    kib_rdma_desc_t *rd,
+				    int negotiated_nfrags);
 void kiblnd_map_rx_descs(kib_conn_t *conn);
 void kiblnd_unmap_rx_descs(kib_conn_t *conn);
 void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node);
@@ -942,7 +946,7 @@ int  kiblnd_close_stale_conns_locked(kib_peer_t *peer,
 int  kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why);
 
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-			       int state, int version);
+			       int state, int version, kib_connparams_t *cp);
 void kiblnd_destroy_conn(kib_conn_t *conn);
 void kiblnd_close_conn(kib_conn_t *conn, int error);
 void kiblnd_close_conn_locked(kib_conn_t *conn, int error);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 0bd6120..3937735 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -328,14 +328,13 @@ kiblnd_handle_rx(kib_rx_t *rx)
 		spin_lock(&conn->ibc_lock);
 
 		if (conn->ibc_credits + credits >
-		    IBLND_MSG_QUEUE_SIZE(conn->ibc_version)) {
+		    conn->ibc_queue_depth) {
 			rc2 = conn->ibc_credits;
 			spin_unlock(&conn->ibc_lock);
 
 			CERROR("Bad credits from %s: %d + %d > %d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
-			       rc2, credits,
-			       IBLND_MSG_QUEUE_SIZE(conn->ibc_version));
+			       rc2, credits, conn->ibc_queue_depth);
 
 			kiblnd_close_conn(conn, -EPROTO);
 			kiblnd_post_rx(rx, IBLND_POSTRX_NO_CREDIT);
@@ -653,8 +652,8 @@ static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 		nob += rd->rd_frags[i].rf_nob;
 	}
 
-	/* looking for pre-mapping MR */
-	mr = kiblnd_find_rd_dma_mr(hdev, rd);
+	mr = kiblnd_find_rd_dma_mr(hdev, rd, tx->tx_conn ?
+				   tx->tx_conn->ibc_max_frags : -1);
 	if (mr) {
 		/* found pre-mapping MR */
 		rd->rd_key = (rd != tx->tx_rd) ? mr->rkey : mr->lkey;
@@ -774,13 +773,13 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	LASSERT(tx->tx_queued);
 	/* We rely on this for QP sizing */
 	LASSERT(tx->tx_nwrq > 0);
-	LASSERT(tx->tx_nwrq <= 1 + IBLND_RDMA_FRAGS(ver));
+	LASSERT(tx->tx_nwrq <= 1 + conn->ibc_max_frags);
 
 	LASSERT(!credit || credit == 1);
 	LASSERT(conn->ibc_outstanding_credits >= 0);
-	LASSERT(conn->ibc_outstanding_credits <= IBLND_MSG_QUEUE_SIZE(ver));
+	LASSERT(conn->ibc_outstanding_credits <= conn->ibc_queue_depth);
 	LASSERT(conn->ibc_credits >= 0);
-	LASSERT(conn->ibc_credits <= IBLND_MSG_QUEUE_SIZE(ver));
+	LASSERT(conn->ibc_credits <= conn->ibc_queue_depth);
 
 	if (conn->ibc_nsends_posted == IBLND_CONCURRENT_SENDS(ver)) {
 		/* tx completions outstanding... */
@@ -1089,10 +1088,10 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 			break;
 		}
 
-		if (tx->tx_nwrq == IBLND_RDMA_FRAGS(conn->ibc_version)) {
-			CERROR("RDMA too fragmented for %s (%d): %d/%d src %d/%d dst frags\n",
+		if (tx->tx_nwrq >= conn->ibc_max_frags) {
+			CERROR("RDMA has too many fragments for peer %s (%d), src idx/frags: %d/%d dst idx/frags: %d/%d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
-			       IBLND_RDMA_FRAGS(conn->ibc_version),
+			       conn->ibc_max_frags,
 			       srcidx, srcrd->rd_nfrags,
 			       dstidx, dstrd->rd_nfrags);
 			rc = -EMSGSIZE;
@@ -2243,7 +2242,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	if (!ni ||			 /* no matching net */
 	    ni->ni_nid != reqmsg->ibm_dstnid ||   /* right NET, wrong NID! */
 	    net->ibn_dev != ibdev) {	      /* wrong device */
-		CERROR("Can't accept %s on %s (%s:%d:%pI4h): bad dst nid %s\n",
+		CERROR("Can't accept conn from %s on %s (%s:%d:%pI4h): bad dst nid %s\n",
 		       libcfs_nid2str(nid),
 		       !ni ? "NA" : libcfs_nid2str(ni->ni_nid),
 		       ibdev->ibd_ifname, ibdev->ibd_nnets,
@@ -2270,10 +2269,11 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	if (reqmsg->ibm_u.connparams.ibcp_queue_depth !=
+	if (reqmsg->ibm_u.connparams.ibcp_queue_depth >
 	    IBLND_MSG_QUEUE_SIZE(version)) {
-		CERROR("Can't accept %s: incompatible queue depth %d (%d wanted)\n",
-		       libcfs_nid2str(nid), reqmsg->ibm_u.connparams.ibcp_queue_depth,
+		CERROR("Can't accept conn from %s, queue depth too large: %d (<=%d wanted)\n",
+		       libcfs_nid2str(nid),
+		       reqmsg->ibm_u.connparams.ibcp_queue_depth,
 		       IBLND_MSG_QUEUE_SIZE(version));
 
 		if (version == IBLND_MSG_VERSION)
@@ -2282,14 +2282,25 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	if (reqmsg->ibm_u.connparams.ibcp_max_frags !=
+	if (reqmsg->ibm_u.connparams.ibcp_max_frags >
 	    IBLND_RDMA_FRAGS(version)) {
-		CERROR("Can't accept %s(version %x): incompatible max_frags %d (%d wanted)\n",
-		       libcfs_nid2str(nid), version,
-		       reqmsg->ibm_u.connparams.ibcp_max_frags,
-		       IBLND_RDMA_FRAGS(version));
+		CWARN("Can't accept conn from %s (version %x): max_frags %d too large (%d wanted)\n",
+		      libcfs_nid2str(nid), version,
+		      reqmsg->ibm_u.connparams.ibcp_max_frags,
+		      IBLND_RDMA_FRAGS(version));
 
-		if (version == IBLND_MSG_VERSION)
+		if (version >= IBLND_MSG_VERSION)
+			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
+
+		goto failed;
+	} else if (reqmsg->ibm_u.connparams.ibcp_max_frags <
+		   IBLND_RDMA_FRAGS(version) && !net->ibn_fmr_ps) {
+		CWARN("Can't accept conn from %s (version %x): max_frags %d incompatible without FMR pool (%d wanted)\n",
+		      libcfs_nid2str(nid), version,
+		      reqmsg->ibm_u.connparams.ibcp_max_frags,
+		      IBLND_RDMA_FRAGS(version));
+
+		if (version >= IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
 
 		goto failed;
@@ -2371,7 +2382,8 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		write_unlock_irqrestore(g_lock, flags);
 	}
 
-	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_PASSIVE_WAIT, version);
+	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_PASSIVE_WAIT, version,
+				  &reqmsg->ibm_u.connparams);
 	if (!conn) {
 		kiblnd_peer_connect_failed(peer, 0, -ENOMEM);
 		kiblnd_peer_decref(peer);
@@ -2384,19 +2396,21 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	 * CM callback doesn't destroy cmid.
 	 */
 	conn->ibc_incarnation      = reqmsg->ibm_srcstamp;
-	conn->ibc_credits          = IBLND_MSG_QUEUE_SIZE(version);
-	conn->ibc_reserved_credits = IBLND_MSG_QUEUE_SIZE(version);
-	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits + IBLND_OOB_MSGS(version)
-		 <= IBLND_RX_MSGS(version));
+	conn->ibc_credits          = reqmsg->ibm_u.connparams.ibcp_queue_depth;
+	conn->ibc_reserved_credits = reqmsg->ibm_u.connparams.ibcp_queue_depth;
+	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits +
+		IBLND_OOB_MSGS(version) <= IBLND_RX_MSGS(conn));
 
 	ackmsg = &conn->ibc_connvars->cv_msg;
 	memset(ackmsg, 0, sizeof(*ackmsg));
 
 	kiblnd_init_msg(ackmsg, IBLND_MSG_CONNACK,
 			sizeof(ackmsg->ibm_u.connparams));
-	ackmsg->ibm_u.connparams.ibcp_queue_depth  = IBLND_MSG_QUEUE_SIZE(version);
+	ackmsg->ibm_u.connparams.ibcp_queue_depth =
+		reqmsg->ibm_u.connparams.ibcp_queue_depth;
+	ackmsg->ibm_u.connparams.ibcp_max_frags =
+		reqmsg->ibm_u.connparams.ibcp_max_frags;
 	ackmsg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
-	ackmsg->ibm_u.connparams.ibcp_max_frags    = IBLND_RDMA_FRAGS(version);
 
 	kiblnd_pack_msg(ni, ackmsg, version, 0, nid, reqmsg->ibm_srcstamp);
 
@@ -2479,6 +2493,31 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 		reason = "Unknown";
 		break;
 
+	case IBLND_REJECT_RDMA_FRAGS:
+		if (conn->ibc_max_frags <= cp->ibcp_max_frags) {
+			CNETERR("Unsupported max frags, peer supports %d\n",
+				cp->ibcp_max_frags);
+			goto failed;
+		} else if (!*kiblnd_tunables.kib_map_on_demand) {
+			CNETERR("map_on_demand must be enabled to support map_on_demand peers\n");
+			goto failed;
+		}
+
+		conn->ibc_max_frags = cp->ibcp_max_frags;
+		reason = "rdma fragments";
+		break;
+
+	case IBLND_REJECT_MSG_QUEUE_SIZE:
+		if (conn->ibc_queue_depth <= cp->ibcp_queue_depth) {
+			CNETERR("Unsupported queue depth, peer supports %d\n",
+				cp->ibcp_queue_depth);
+			goto failed;
+		}
+
+		conn->ibc_queue_depth = cp->ibcp_queue_depth;
+		reason = "queue depth";
+		break;
+
 	case IBLND_REJECT_CONN_STALE:
 		reason = "stale";
 		break;
@@ -2495,11 +2534,17 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 	CNETERR("%s: retrying (%s), %x, %x, queue_dep: %d, max_frag: %d, msg_size: %d\n",
 		libcfs_nid2str(peer->ibp_nid),
 		reason, IBLND_MSG_VERSION, version,
-		cp ? cp->ibcp_queue_depth  : IBLND_MSG_QUEUE_SIZE(version),
-		cp ? cp->ibcp_max_frags    : IBLND_RDMA_FRAGS(version),
+		conn->ibc_queue_depth, conn->ibc_max_frags,
 		cp ? cp->ibcp_max_msg_size : IBLND_MSG_SIZE);
 
 	kiblnd_connect_peer(peer);
+	return;
+failed:
+	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
+	peer->ibp_connecting--;
+	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
+
+	return;
 }
 
 static void
@@ -2595,24 +2640,10 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 			case IBLND_REJECT_CONN_RACE:
 			case IBLND_REJECT_CONN_STALE:
 			case IBLND_REJECT_CONN_UNCOMPAT:
-				kiblnd_reconnect(conn, rej->ibr_version,
-						 incarnation, rej->ibr_why, cp);
-				break;
-
 			case IBLND_REJECT_MSG_QUEUE_SIZE:
-				CERROR("%s rejected: incompatible message queue depth %d, %d\n",
-				       libcfs_nid2str(peer->ibp_nid),
-				       cp ? cp->ibcp_queue_depth :
-				       IBLND_MSG_QUEUE_SIZE(rej->ibr_version),
-				       IBLND_MSG_QUEUE_SIZE(conn->ibc_version));
-				break;
-
 			case IBLND_REJECT_RDMA_FRAGS:
-				CERROR("%s rejected: incompatible # of RDMA fragments %d, %d\n",
-				       libcfs_nid2str(peer->ibp_nid),
-				       cp ? cp->ibcp_max_frags :
-				       IBLND_RDMA_FRAGS(rej->ibr_version),
-				       IBLND_RDMA_FRAGS(conn->ibc_version));
+				kiblnd_reconnect(conn, rej->ibr_version,
+						 incarnation, rej->ibr_why, cp);
 				break;
 
 			case IBLND_REJECT_NO_RESOURCES:
@@ -2676,22 +2707,22 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	if (msg->ibm_u.connparams.ibcp_queue_depth !=
-	    IBLND_MSG_QUEUE_SIZE(ver)) {
-		CERROR("%s has incompatible queue depth %d(%d wanted)\n",
+	if (msg->ibm_u.connparams.ibcp_queue_depth >
+	    conn->ibc_queue_depth) {
+		CERROR("%s has incompatible queue depth %d (<=%d wanted)\n",
 		       libcfs_nid2str(peer->ibp_nid),
 		       msg->ibm_u.connparams.ibcp_queue_depth,
-		       IBLND_MSG_QUEUE_SIZE(ver));
+		       conn->ibc_queue_depth);
 		rc = -EPROTO;
 		goto failed;
 	}
 
-	if (msg->ibm_u.connparams.ibcp_max_frags !=
-	    IBLND_RDMA_FRAGS(ver)) {
-		CERROR("%s has incompatible max_frags %d (%d wanted)\n",
+	if (msg->ibm_u.connparams.ibcp_max_frags >
+	    conn->ibc_max_frags) {
+		CERROR("%s has incompatible max_frags %d (<=%d wanted)\n",
 		       libcfs_nid2str(peer->ibp_nid),
 		       msg->ibm_u.connparams.ibcp_max_frags,
-		       IBLND_RDMA_FRAGS(ver));
+		       conn->ibc_max_frags);
 		rc = -EPROTO;
 		goto failed;
 	}
@@ -2721,10 +2752,12 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 	}
 
 	conn->ibc_incarnation = msg->ibm_srcstamp;
-	conn->ibc_credits =
-	conn->ibc_reserved_credits = IBLND_MSG_QUEUE_SIZE(ver);
-	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits + IBLND_OOB_MSGS(ver)
-		 <= IBLND_RX_MSGS(ver));
+	conn->ibc_credits = msg->ibm_u.connparams.ibcp_queue_depth;
+	conn->ibc_reserved_credits = msg->ibm_u.connparams.ibcp_queue_depth;
+	conn->ibc_queue_depth = msg->ibm_u.connparams.ibcp_queue_depth;
+	conn->ibc_max_frags = msg->ibm_u.connparams.ibcp_max_frags;
+	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits +
+		IBLND_OOB_MSGS(ver) <= IBLND_RX_MSGS(conn));
 
 	kiblnd_connreq_done(conn, 0);
 	return;
@@ -2761,7 +2794,8 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_ACTIVE_CONNECT, version);
+	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_ACTIVE_CONNECT,
+				  version, NULL);
 	if (!conn) {
 		kiblnd_peer_connect_failed(peer, 1, -ENOMEM);
 		kiblnd_peer_decref(peer); /* lose cmid's ref */
@@ -2777,8 +2811,8 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 
 	memset(msg, 0, sizeof(*msg));
 	kiblnd_init_msg(msg, IBLND_MSG_CONNREQ, sizeof(msg->ibm_u.connparams));
-	msg->ibm_u.connparams.ibcp_queue_depth  = IBLND_MSG_QUEUE_SIZE(version);
-	msg->ibm_u.connparams.ibcp_max_frags    = IBLND_RDMA_FRAGS(version);
+	msg->ibm_u.connparams.ibcp_queue_depth = conn->ibc_queue_depth;
+	msg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags;
 	msg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
 	kiblnd_pack_msg(peer->ibp_ni, msg, version,
-- 
1.7.1
