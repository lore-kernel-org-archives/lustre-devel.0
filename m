From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:01 -0500
Subject: [lustre-devel] [PATCH 03/11] staging: lustre: align all code
	properly for LNet core
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

In several places in the LNet core the code doesn't align
up properly. This resolves those checkpath issues.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   49 +++++------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   10 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   91 ++++++++++----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   80 ++++++++---------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   73 +++++++---------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   46 +++++-----
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   22 +++---
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   10 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   10 +-
 drivers/staging/lustre/lnet/lnet/config.c          |    7 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   42 +++++-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    4 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    8 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    2 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |    6 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    2 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |    6 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   32 +++----
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   32 ++++---
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   28 +++---
 drivers/staging/lustre/lnet/selftest/conctl.c      |   85 ++++++++----------
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   31 +++----
 drivers/staging/lustre/lnet/selftest/console.c     |   42 +++++-----
 drivers/staging/lustre/lnet/selftest/framework.c   |   64 +++++++-------
 drivers/staging/lustre/lnet/selftest/ping_test.c   |   14 ++--
 drivers/staging/lustre/lnet/selftest/rpc.c         |   80 ++++++++---------
 26 files changed, 419 insertions(+), 457 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index c5bf059..8ad128c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -145,7 +145,7 @@ static int kiblnd_unpack_rd(kib_msg_t *msg, int flip)
 	int i;
 
 	LASSERT(msg->ibm_type == IBLND_MSG_GET_REQ ||
-		 msg->ibm_type == IBLND_MSG_PUT_ACK);
+		msg->ibm_type == IBLND_MSG_PUT_ACK);
 
 	rd = msg->ibm_type == IBLND_MSG_GET_REQ ?
 			      &msg->ibm_u.get.ibgm_rd :
@@ -444,8 +444,8 @@ static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
 
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
-				 peer->ibp_accepting > 0 ||
-				 !list_empty(&peer->ibp_conns));
+				peer->ibp_accepting > 0 ||
+				!list_empty(&peer->ibp_conns));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -513,8 +513,8 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
-				 peer->ibp_accepting > 0 ||
-				 !list_empty(&peer->ibp_conns));
+				peer->ibp_accepting > 0 ||
+				!list_empty(&peer->ibp_conns));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -526,7 +526,7 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 				LASSERT(list_empty(&peer->ibp_conns));
 
 				list_splice_init(&peer->ibp_tx_queue,
-						     &zombies);
+						 &zombies);
 			}
 
 			kiblnd_del_peer_locked(peer);
@@ -557,8 +557,8 @@ static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
-				 peer->ibp_accepting > 0 ||
-				 !list_empty(&peer->ibp_conns));
+				peer->ibp_accepting > 0 ||
+				!list_empty(&peer->ibp_conns));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -568,7 +568,7 @@ static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 					continue;
 
 				conn = list_entry(ctmp, kib_conn_t,
-						      ibc_list);
+						  ibc_list);
 				kiblnd_conn_addref(conn);
 				read_unlock_irqrestore(
 					&kiblnd_data.kib_global_lock,
@@ -644,7 +644,7 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 }
 
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-				int state, int version)
+			       int state, int version)
 {
 	/*
 	 * CAVEAT EMPTOR:
@@ -838,7 +838,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	/* Init successful! */
 	LASSERT(state == IBLND_CONN_ACTIVE_CONNECT ||
-		 state == IBLND_CONN_PASSIVE_WAIT);
+		state == IBLND_CONN_PASSIVE_WAIT);
 	conn->ibc_state = state;
 
 	/* 1 more conn */
@@ -943,7 +943,7 @@ int kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why)
 }
 
 int kiblnd_close_stale_conns_locked(kib_peer_t *peer,
-				     int version, __u64 incarnation)
+				    int version, __u64 incarnation)
 {
 	kib_conn_t *conn;
 	struct list_head *ctmp;
@@ -995,8 +995,8 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 
 			peer = list_entry(ptmp, kib_peer_t, ibp_list);
 			LASSERT(peer->ibp_connecting > 0 ||
-				 peer->ibp_accepting > 0 ||
-				 !list_empty(&peer->ibp_conns));
+				peer->ibp_accepting > 0 ||
+				!list_empty(&peer->ibp_conns));
 
 			if (peer->ibp_ni != ni)
 				continue;
@@ -1192,7 +1192,7 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 						       IBLND_MSG_SIZE,
 						       DMA_FROM_DEVICE);
 		LASSERT(!kiblnd_dma_mapping_error(conn->ibc_hdev->ibh_ibdev,
-						   rx->rx_msgaddr));
+						  rx->rx_msgaddr));
 		KIBLND_UNMAP_ADDR_SET(rx, rx_msgunmap, rx->rx_msgaddr);
 
 		CDEBUG(D_NET, "rx %d: %p %#llx(%#llx)\n",
@@ -1293,7 +1293,7 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 			tpo->tpo_hdev->ibh_ibdev, tx->tx_msg,
 			IBLND_MSG_SIZE, DMA_TO_DEVICE);
 		LASSERT(!kiblnd_dma_mapping_error(tpo->tpo_hdev->ibh_ibdev,
-						   tx->tx_msgaddr));
+						  tx->tx_msgaddr));
 		KIBLND_UNMAP_ADDR_SET(tx, tx_msgunmap, tx->tx_msgaddr);
 
 		list_add(&tx->tx_list, &pool->po_free_list);
@@ -1581,8 +1581,7 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 
 	if (fps->fps_increasing) {
 		spin_unlock(&fps->fps_lock);
-		CDEBUG(D_NET,
-			"Another thread is allocating new FMR pool, waiting for her to complete\n");
+		CDEBUG(D_NET, "Another thread is allocating new FMR pool, waiting for her to complete\n");
 		schedule();
 		goto again;
 
@@ -2252,8 +2251,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 	int i;
 
 	LASSERT(*kiblnd_tunables.kib_dev_failover > 1 ||
-		 dev->ibd_can_failover ||
-		 dev->ibd_hdev == NULL);
+		dev->ibd_can_failover || dev->ibd_hdev == NULL);
 
 	rc = kiblnd_dev_need_failover(dev);
 	if (rc <= 0)
@@ -2432,8 +2430,7 @@ static kib_dev_t *kiblnd_create_dev(char *ifname)
 		return NULL;
 	}
 
-	list_add_tail(&dev->ibd_list,
-			  &kiblnd_data.kib_devs);
+	list_add_tail(&dev->ibd_list, &kiblnd_data.kib_devs);
 	return dev;
 }
 
@@ -2861,11 +2858,11 @@ static int __init kiblnd_module_init(void)
 
 	CLASSERT(sizeof(kib_msg_t) <= IBLND_MSG_SIZE);
 	CLASSERT(offsetof(kib_msg_t,
-		ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
-		<= IBLND_MSG_SIZE);
+			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
+			  <= IBLND_MSG_SIZE);
 	CLASSERT(offsetof(kib_msg_t,
-		ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
-		<= IBLND_MSG_SIZE);
+			  ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
+			  <= IBLND_MSG_SIZE);
 
 	rc = kiblnd_tunables_init();
 	if (rc != 0)
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 025faa9..dbbbf55 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -948,25 +948,25 @@ void kiblnd_peer_alive(kib_peer_t *peer);
 kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid);
 void kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error);
 int  kiblnd_close_stale_conns_locked(kib_peer_t *peer,
-				      int version, __u64 incarnation);
+				     int version, __u64 incarnation);
 int  kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why);
 
 void kiblnd_connreq_done(kib_conn_t *conn, int status);
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-				int state, int version);
+			       int state, int version);
 void kiblnd_destroy_conn(kib_conn_t *conn);
 void kiblnd_close_conn(kib_conn_t *conn, int error);
 void kiblnd_close_conn_locked(kib_conn_t *conn, int error);
 
 int  kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
-		       int nob, kib_rdma_desc_t *dstrd, __u64 dstcookie);
+		      int nob, kib_rdma_desc_t *dstrd, __u64 dstcookie);
 
 void kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid);
 void kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn);
 void kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn);
 void kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob);
 void kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist,
-			 int status);
+			int status);
 void kiblnd_check_sends (kib_conn_t *conn);
 
 void kiblnd_qp_event(struct ib_event *event, void *arg);
@@ -974,7 +974,7 @@ void kiblnd_cq_event(struct ib_event *event, void *arg);
 void kiblnd_cq_completion(struct ib_cq *cq, void *arg);
 
 void kiblnd_pack_msg(lnet_ni_t *ni, kib_msg_t *msg, int version,
-		      int credits, lnet_nid_t dstnid, __u64 dststamp);
+		     int credits, lnet_nid_t dstnid, __u64 dststamp);
 int  kiblnd_unpack_msg(kib_msg_t *msg, int nob);
 int  kiblnd_post_rx(kib_rx_t *rx, int credit);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 5093244..fbcbb97 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -396,7 +396,7 @@ kiblnd_handle_rx(kib_rx_t *rx)
 
 		spin_lock(&conn->ibc_lock);
 		tx = kiblnd_find_waiting_tx_locked(conn, IBLND_MSG_PUT_REQ,
-					msg->ibm_u.putack.ibpam_src_cookie);
+						   msg->ibm_u.putack.ibpam_src_cookie);
 		if (tx != NULL)
 			list_del(&tx->tx_list);
 		spin_unlock(&conn->ibc_lock);
@@ -489,7 +489,7 @@ kiblnd_rx_complete(kib_rx_t *rx, int status, int nob)
 	rc = kiblnd_unpack_msg(msg, rx->rx_nob);
 	if (rc != 0) {
 		CERROR("Error %d unpacking rx from %s\n",
-			rc, libcfs_nid2str(conn->ibc_peer->ibp_nid));
+		       rc, libcfs_nid2str(conn->ibc_peer->ibp_nid));
 		goto failed;
 	}
 
@@ -498,7 +498,7 @@ kiblnd_rx_complete(kib_rx_t *rx, int status, int nob)
 	    msg->ibm_srcstamp != conn->ibc_incarnation ||
 	    msg->ibm_dststamp != net->ibn_incarnation) {
 		CERROR("Stale rx from %s\n",
-			libcfs_nid2str(conn->ibc_peer->ibp_nid));
+		       libcfs_nid2str(conn->ibc_peer->ibp_nid));
 		err = -ESTALE;
 		goto failed;
 	}
@@ -715,7 +715,7 @@ kiblnd_setup_rd_iov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 
 static int
 kiblnd_setup_rd_kiov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
-		      int nkiov, lnet_kiov_t *kiov, int offset, int nob)
+		     int nkiov, lnet_kiov_t *kiov, int offset, int nob)
 {
 	kib_net_t *net = ni->ni_data;
 	struct scatterlist *sg;
@@ -909,13 +909,13 @@ kiblnd_check_sends(kib_conn_t *conn)
 
 	LASSERT(conn->ibc_nsends_posted <= IBLND_CONCURRENT_SENDS(ver));
 	LASSERT(!IBLND_OOB_CAPABLE(ver) ||
-		 conn->ibc_noops_posted <= IBLND_OOB_MSGS(ver));
+		conn->ibc_noops_posted <= IBLND_OOB_MSGS(ver));
 	LASSERT(conn->ibc_reserved_credits >= 0);
 
 	while (conn->ibc_reserved_credits > 0 &&
 	       !list_empty(&conn->ibc_tx_queue_rsrvd)) {
 		tx = list_entry(conn->ibc_tx_queue_rsrvd.next,
-				    kib_tx_t, tx_list);
+				kib_tx_t, tx_list);
 		list_del(&tx->tx_list);
 		list_add_tail(&tx->tx_list, &conn->ibc_tx_queue);
 		conn->ibc_reserved_credits--;
@@ -941,7 +941,7 @@ kiblnd_check_sends(kib_conn_t *conn)
 		if (!list_empty(&conn->ibc_tx_queue_nocred)) {
 			credit = 0;
 			tx = list_entry(conn->ibc_tx_queue_nocred.next,
-					    kib_tx_t, tx_list);
+					kib_tx_t, tx_list);
 		} else if (!list_empty(&conn->ibc_tx_noops)) {
 			LASSERT(!IBLND_OOB_CAPABLE(ver));
 			credit = 1;
@@ -950,7 +950,7 @@ kiblnd_check_sends(kib_conn_t *conn)
 		} else if (!list_empty(&conn->ibc_tx_queue)) {
 			credit = 1;
 			tx = list_entry(conn->ibc_tx_queue.next,
-					    kib_tx_t, tx_list);
+					kib_tx_t, tx_list);
 		} else
 			break;
 
@@ -1054,7 +1054,7 @@ kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
 
 int
 kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
-		  int resid, kib_rdma_desc_t *dstrd, __u64 dstcookie)
+		 int resid, kib_rdma_desc_t *dstrd, __u64 dstcookie)
 {
 	kib_msg_t *ibmsg = tx->tx_msg;
 	kib_rdma_desc_t *srcrd = tx->tx_rd;
@@ -1068,7 +1068,7 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	LASSERT(!in_interrupt());
 	LASSERT(tx->tx_nwrq == 0);
 	LASSERT(type == IBLND_MSG_GET_DONE ||
-		 type == IBLND_MSG_PUT_DONE);
+		type == IBLND_MSG_PUT_DONE);
 
 	srcidx = dstidx = 0;
 
@@ -1349,10 +1349,10 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 		if (list_empty(&peer->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
 			LASSERT(peer->ibp_connecting != 0 ||
-				 peer->ibp_accepting != 0);
+				peer->ibp_accepting != 0);
 			if (tx != NULL)
 				list_add_tail(&tx->tx_list,
-						  &peer->ibp_tx_queue);
+					      &peer->ibp_tx_queue);
 			write_unlock_irqrestore(g_lock, flags);
 		} else {
 			conn = kiblnd_get_conn_locked(peer);
@@ -1388,10 +1388,10 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 		if (list_empty(&peer2->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
 			LASSERT(peer2->ibp_connecting != 0 ||
-				 peer2->ibp_accepting != 0);
+				peer2->ibp_accepting != 0);
 			if (tx != NULL)
 				list_add_tail(&tx->tx_list,
-						  &peer2->ibp_tx_queue);
+					      &peer2->ibp_tx_queue);
 			write_unlock_irqrestore(g_lock, flags);
 		} else {
 			conn = kiblnd_get_conn_locked(peer2);
@@ -1571,7 +1571,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	tx = kiblnd_get_idle_tx(ni, target.nid);
 	if (tx == NULL) {
 		CERROR("Can't send %d to %s: tx descs exhausted\n",
-			type, libcfs_nid2str(target.nid));
+		       type, libcfs_nid2str(target.nid));
 		return -ENOMEM;
 	}
 
@@ -1660,8 +1660,8 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 
 int
 kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
-	     unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
-	     unsigned int offset, unsigned int mlen, unsigned int rlen)
+	    unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
+	    unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
 	kib_rx_t *rx = private;
 	kib_msg_t *rxmsg = rx->rx_msg;
@@ -1684,8 +1684,8 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		nob = offsetof(kib_msg_t, ibm_u.immediate.ibim_payload[rlen]);
 		if (nob > rx->rx_nob) {
 			CERROR("Immediate message from %s too big: %d(%d)\n",
-				libcfs_nid2str(rxmsg->ibm_u.immediate.ibim_hdr.src_nid),
-				nob, rx->rx_nob);
+			       libcfs_nid2str(rxmsg->ibm_u.immediate.ibim_hdr.src_nid),
+			       nob, rx->rx_nob);
 			rc = -EPROTO;
 			break;
 		}
@@ -1858,12 +1858,12 @@ kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 		       libcfs_nid2str(peer->ibp_nid));
 	} else {
 		CNETERR("Closing conn to %s: error %d%s%s%s%s%s\n",
-		       libcfs_nid2str(peer->ibp_nid), error,
-		       list_empty(&conn->ibc_tx_queue) ? "" : "(sending)",
-		       list_empty(&conn->ibc_tx_noops) ? "" : "(sending_noops)",
-		       list_empty(&conn->ibc_tx_queue_rsrvd) ? "" : "(sending_rsrvd)",
-		       list_empty(&conn->ibc_tx_queue_nocred) ? "" : "(sending_nocred)",
-		       list_empty(&conn->ibc_active_txs) ? "" : "(waiting)");
+		        libcfs_nid2str(peer->ibp_nid), error,
+		        list_empty(&conn->ibc_tx_queue) ? "" : "(sending)",
+		        list_empty(&conn->ibc_tx_noops) ? "" : "(sending_noops)",
+		        list_empty(&conn->ibc_tx_queue_rsrvd) ? "" : "(sending_rsrvd)",
+		        list_empty(&conn->ibc_tx_queue_nocred) ? "" : "(sending_nocred)",
+		        list_empty(&conn->ibc_active_txs) ? "" : "(waiting)");
 	}
 
 	dev = ((kib_net_t *)peer->ibp_ni->ni_data)->ibn_dev;
@@ -1944,8 +1944,7 @@ kiblnd_abort_txs(kib_conn_t *conn, struct list_head *txs)
 
 		if (txs == &conn->ibc_active_txs) {
 			LASSERT(!tx->tx_queued);
-			LASSERT(tx->tx_waiting ||
-				 tx->tx_sending != 0);
+			LASSERT(tx->tx_waiting || tx->tx_sending != 0);
 		} else {
 			LASSERT(tx->tx_queued);
 		}
@@ -2016,7 +2015,7 @@ kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 	    peer->ibp_accepting != 0) {
 		/* another connection attempt under way... */
 		write_unlock_irqrestore(&kiblnd_data.kib_global_lock,
-					    flags);
+					flags);
 		return;
 	}
 
@@ -2065,9 +2064,9 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 
 	LASSERT(!in_interrupt());
 	LASSERT((conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT &&
-		  peer->ibp_connecting > 0) ||
+		 peer->ibp_connecting > 0) ||
 		 (conn->ibc_state == IBLND_CONN_PASSIVE_WAIT &&
-		  peer->ibp_accepting > 0));
+		 peer->ibp_accepting > 0));
 
 	LIBCFS_FREE(conn->ibc_connvars, sizeof(*conn->ibc_connvars));
 	conn->ibc_connvars = NULL;
@@ -2352,7 +2351,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		/* Brand new peer */
 		LASSERT(peer->ibp_accepting == 0);
 		LASSERT(peer->ibp_version == 0 &&
-			 peer->ibp_incarnation == 0);
+			peer->ibp_incarnation == 0);
 
 		peer->ibp_accepting   = 1;
 		peer->ibp_version     = version;
@@ -2435,7 +2434,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
 static void
 kiblnd_reconnect(kib_conn_t *conn, int version,
-		  __u64 incarnation, int why, kib_connparams_t *cp)
+		 __u64 incarnation, int why, kib_connparams_t *cp)
 {
 	kib_peer_t *peer = conn->ibc_peer;
 	char *reason;
@@ -2827,7 +2826,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 	case RDMA_CM_EVENT_ADDR_ERROR:
 		peer = (kib_peer_t *)cmid->context;
 		CNETERR("%s: ADDR ERROR %d\n",
-		       libcfs_nid2str(peer->ibp_nid), event->status);
+		        libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer);
 		return -EHOSTUNREACH;      /* rc != 0 destroys cmid */
@@ -2872,7 +2871,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 			return kiblnd_active_connect(cmid);
 
 		CNETERR("Can't resolve route for %s: %d\n",
-		       libcfs_nid2str(peer->ibp_nid), event->status);
+		        libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, event->status);
 		kiblnd_peer_decref(peer);
 		return event->status;	   /* rc != 0 destroys cmid */
@@ -2882,7 +2881,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
 			conn->ibc_state == IBLND_CONN_PASSIVE_WAIT);
 		CNETERR("%s: UNREACHABLE %d\n",
-		       libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status);
+		        libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status);
 		kiblnd_connreq_done(conn, -ENETDOWN);
 		kiblnd_conn_decref(conn);
 		return 0;
@@ -2905,8 +2904,8 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 
 		case IBLND_CONN_PASSIVE_WAIT:
 			CERROR("%s: REJECTED %d\n",
-				libcfs_nid2str(conn->ibc_peer->ibp_nid),
-				event->status);
+			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
+			       event->status);
 			kiblnd_connreq_done(conn, -ECONNRESET);
 			break;
 
@@ -3061,8 +3060,7 @@ kiblnd_check_conns(int idx)
 				       conn->ibc_reserved_credits);
 				list_add(&conn->ibc_connd_list, &closes);
 			} else {
-				list_add(&conn->ibc_connd_list,
-					     &checksends);
+				list_add(&conn->ibc_connd_list, &checksends);
 			}
 			/* +ref for 'closes' or 'checksends' */
 			kiblnd_conn_addref(conn);
@@ -3090,8 +3088,7 @@ kiblnd_check_conns(int idx)
 	 * free to do it last time...
 	 */
 	while (!list_empty(&checksends)) {
-		conn = list_entry(checksends.next,
-				      kib_conn_t, ibc_connd_list);
+		conn = list_entry(checksends.next, kib_conn_t, ibc_connd_list);
 		list_del(&conn->ibc_connd_list);
 		kiblnd_check_sends(conn);
 		kiblnd_conn_decref(conn);
@@ -3136,7 +3133,7 @@ kiblnd_connd(void *arg)
 
 		if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
 			conn = list_entry(kiblnd_data.kib_connd_zombies.next,
-					      kib_conn_t, ibc_list);
+					  kib_conn_t, ibc_list);
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock,
@@ -3150,7 +3147,7 @@ kiblnd_connd(void *arg)
 
 		if (!list_empty(&kiblnd_data.kib_connd_conns)) {
 			conn = list_entry(kiblnd_data.kib_connd_conns.next,
-					      kib_conn_t, ibc_list);
+					  kib_conn_t, ibc_list);
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock,
@@ -3350,8 +3347,8 @@ kiblnd_scheduler(void *arg)
 		did_something = 0;
 
 		if (!list_empty(&sched->ibs_conns)) {
-			conn = list_entry(sched->ibs_conns.next,
-					      kib_conn_t, ibc_sched_list);
+			conn = list_entry(sched->ibs_conns.next, kib_conn_t,
+					  ibc_sched_list);
 			/* take over kib_sched_conns' ref on conn... */
 			LASSERT(conn->ibc_scheduled);
 			list_del(&conn->ibc_sched_list);
@@ -3369,7 +3366,7 @@ kiblnd_scheduler(void *arg)
 					kiblnd_close_conn(conn, -EIO);
 					kiblnd_conn_decref(conn);
 					spin_lock_irqsave(&sched->ibs_lock,
-							      flags);
+							  flags);
 					continue;
 				}
 
@@ -3397,7 +3394,7 @@ kiblnd_scheduler(void *arg)
 				/* +1 ref for sched_conns */
 				kiblnd_conn_addref(conn);
 				list_add_tail(&conn->ibc_sched_list,
-						  &sched->ibs_conns);
+					      &sched->ibs_conns);
 				if (waitqueue_active(&sched->ibs_waitq))
 					wake_up(&sched->ibs_waitq);
 			} else {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index a237cde..6bf92fd 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -152,7 +152,7 @@ ksocknal_destroy_peer(ksock_peer_t *peer)
 	ksock_net_t *net = peer->ksnp_ni->ni_data;
 
 	CDEBUG(D_NET, "peer %s %p deleted\n",
-		libcfs_id2str(peer->ksnp_id), peer);
+	       libcfs_id2str(peer->ksnp_id), peer);
 
 	LASSERT(atomic_read(&peer->ksnp_refcount) == 0);
 	LASSERT(peer->ksnp_accepting == 0);
@@ -250,8 +250,8 @@ ksocknal_unlink_peer_locked(ksock_peer_t *peer)
 
 static int
 ksocknal_get_peer_info(lnet_ni_t *ni, int index,
-			lnet_process_id_t *id, __u32 *myip, __u32 *peer_ip,
-			int *port, int *conn_count, int *share_count)
+		       lnet_process_id_t *id, __u32 *myip, __u32 *peer_ip,
+		       int *port, int *conn_count, int *share_count)
 {
 	ksock_peer_t *peer;
 	struct list_head *ptmp;
@@ -305,7 +305,7 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 					continue;
 
 				route = list_entry(rtmp, ksock_route_t,
-						       ksnr_list);
+						   ksnr_list);
 
 				*id = peer->ksnp_id;
 				*myip = route->ksnr_myipaddr;
@@ -388,8 +388,8 @@ ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
 
 		if (route2->ksnr_ipaddr == route->ksnr_ipaddr) {
 			CERROR("Duplicate route %s %pI4h\n",
-				libcfs_id2str(peer->ksnp_id),
-				&route->ksnr_ipaddr);
+			       libcfs_id2str(peer->ksnp_id),
+			       &route->ksnr_ipaddr);
 			LBUG();
 		}
 	}
@@ -489,7 +489,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 	} else {
 		/* peer table takes my ref on peer */
 		list_add_tail(&peer->ksnp_list,
-				   ksocknal_nid2peerlist(id.nid));
+			      ksocknal_nid2peerlist(id.nid));
 	}
 
 	route2 = NULL;
@@ -592,8 +592,7 @@ ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_safe(ptmp, pnxt,
-					&ksocknal_data.ksnd_peers[i]) {
+		list_for_each_safe(ptmp, pnxt, &ksocknal_data.ksnd_peers[i]) {
 			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
 
 			if (peer->ksnp_ni != ni)
@@ -613,7 +612,7 @@ ksocknal_del_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ip)
 				LASSERT(list_empty(&peer->ksnp_routes));
 
 				list_splice_init(&peer->ksnp_tx_queue,
-						     &zombies);
+						 &zombies);
 			}
 
 			ksocknal_peer_decref(peer);     /* ...till here */
@@ -654,7 +653,7 @@ ksocknal_get_conn_by_idx(lnet_ni_t *ni, int index)
 					continue;
 
 				conn = list_entry(ctmp, ksock_conn_t,
-						       ksnc_list);
+						  ksnc_list);
 				ksocknal_conn_addref(conn);
 				read_unlock(&ksocknal_data.ksnd_global_lock);
 				return conn;
@@ -939,7 +938,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 			/* Using this interface already? */
 			list_for_each(rtmp, &peer->ksnp_routes) {
 				route = list_entry(rtmp, ksock_route_t,
-						       ksnr_list);
+						   ksnr_list);
 
 				if (route->ksnr_myipaddr == iface->ksni_ipaddr)
 					break;
@@ -1025,7 +1024,7 @@ ksocknal_connecting(ksock_peer_t *peer, __u32 ipaddr)
 
 int
 ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
-		      struct socket *sock, int type)
+		     struct socket *sock, int type)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	LIST_HEAD(zombies);
@@ -1157,7 +1156,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 			 * table (which takes my ref)
 			 */
 			list_add_tail(&peer->ksnp_list,
-					  ksocknal_nid2peerlist(peerid.nid));
+				      ksocknal_nid2peerlist(peerid.nid));
 		} else {
 			ksocknal_peer_decref(peer);
 			peer = peer2;
@@ -1395,7 +1394,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 			       libcfs_id2str(peerid), conn->ksnc_type, warn);
 		else
 			CDEBUG(D_NET, "Not creating conn %s type %d: %s\n",
-			      libcfs_id2str(peerid), conn->ksnc_type, warn);
+			       libcfs_id2str(peerid), conn->ksnc_type, warn);
 	}
 
 	if (!active) {
@@ -1491,12 +1490,12 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 			 * these TXs will be send to /dev/null by scheduler
 			 */
 			list_for_each_entry(tx, &peer->ksnp_tx_queue,
-						tx_list)
+					    tx_list)
 				ksocknal_tx_prep(conn, tx);
 
 			spin_lock_bh(&conn->ksnc_scheduler->kss_lock);
 			list_splice_init(&peer->ksnp_tx_queue,
-					     &conn->ksnc_tx_queue);
+					 &conn->ksnc_tx_queue);
 			spin_unlock_bh(&conn->ksnc_scheduler->kss_lock);
 		}
 
@@ -1515,7 +1514,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
 	list_add_tail(&conn->ksnc_list,
-			  &ksocknal_data.ksnd_deathrow_conns);
+		      &ksocknal_data.ksnd_deathrow_conns);
 	wake_up(&ksocknal_data.ksnd_reaper_waitq);
 
 	spin_unlock_bh(&ksocknal_data.ksnd_reaper_lock);
@@ -1546,7 +1545,7 @@ ksocknal_peer_failed(ksock_peer_t *peer)
 
 	if (notify)
 		lnet_notify(peer->ksnp_ni, peer->ksnp_id.nid, 0,
-			     last_alive);
+			    last_alive);
 }
 
 void
@@ -1611,7 +1610,7 @@ ksocknal_terminate_conn(ksock_conn_t *conn)
 	if (!conn->ksnc_tx_scheduled &&
 	    !list_empty(&conn->ksnc_tx_queue)) {
 		list_add_tail(&conn->ksnc_tx_list,
-			       &sched->kss_tx_conns);
+			      &sched->kss_tx_conns);
 		conn->ksnc_tx_scheduled = 1;
 		/* extra ref for scheduler */
 		ksocknal_conn_addref(conn);
@@ -1696,7 +1695,7 @@ ksocknal_destroy_conn(ksock_conn_t *conn)
 		       cfs_duration_sec(cfs_time_sub(cfs_time_current(),
 						     last_rcv)));
 		lnet_finalize(conn->ksnc_peer->ksnp_ni,
-			       conn->ksnc_cookie, -EIO);
+			      conn->ksnc_cookie, -EIO);
 		break;
 	case SOCKNAL_RX_LNET_HEADER:
 		if (conn->ksnc_rx_started)
@@ -1787,7 +1786,7 @@ ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt,
-					&ksocknal_data.ksnd_peers[i]) {
+				   &ksocknal_data.ksnd_peers[i]) {
 
 			peer = list_entry(ptmp, ksock_peer_t, ksnp_list);
 
@@ -1824,7 +1823,7 @@ ksocknal_notify(lnet_ni_t *ni, lnet_nid_t gw_nid, int alive)
 	id.pid = LNET_PID_ANY;
 
 	CDEBUG(D_NET, "gw %s %s\n", libcfs_nid2str(gw_nid),
-		alive ? "up" : "down");
+	       alive ? "up" : "down");
 
 	if (!alive) {
 		/* If the gateway crashed, close all open connections... */
@@ -1915,7 +1914,7 @@ ksocknal_push_peer(ksock_peer_t *peer)
 		list_for_each(tmp, &peer->ksnp_conns) {
 			if (i++ == index) {
 				conn = list_entry(tmp, ksock_conn_t,
-						       ksnc_list);
+						  ksnc_list);
 				ksocknal_conn_addref(conn);
 				break;
 			}
@@ -2015,16 +2014,15 @@ ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++) {
 			list_for_each(ptmp, &ksocknal_data.ksnd_peers[i]) {
 				peer = list_entry(ptmp, ksock_peer_t,
-						      ksnp_list);
+						  ksnp_list);
 
 				for (j = 0; j < peer->ksnp_n_passive_ips; j++)
 					if (peer->ksnp_passive_ips[j] == ipaddress)
 						iface->ksni_npeers++;
 
 				list_for_each(rtmp, &peer->ksnp_routes) {
-					route = list_entry(rtmp,
-							       ksock_route_t,
-							       ksnr_list);
+					route = list_entry(rtmp, ksock_route_t,
+							   ksnr_list);
 
 					if (route->ksnr_myipaddr == ipaddress)
 						iface->ksni_nroutes++;
@@ -2113,9 +2111,8 @@ ksocknal_del_interface(lnet_ni_t *ni, __u32 ipaddress)
 
 		for (j = 0; j < ksocknal_data.ksnd_peer_hash_size; j++) {
 			list_for_each_safe(tmp, nxt,
-					       &ksocknal_data.ksnd_peers[j]) {
-				peer = list_entry(tmp, ksock_peer_t,
-						      ksnp_list);
+					   &ksocknal_data.ksnd_peers[j]) {
+				peer = list_entry(tmp, ksock_peer_t, ksnp_list);
 
 				if (peer->ksnp_ni != ni)
 					continue;
@@ -2277,8 +2274,8 @@ ksocknal_free_buffers(void)
 	}
 
 	LIBCFS_FREE(ksocknal_data.ksnd_peers,
-		     sizeof(struct list_head) *
-		     ksocknal_data.ksnd_peer_hash_size);
+		    sizeof(struct list_head) *
+		    ksocknal_data.ksnd_peer_hash_size);
 
 	spin_lock(&ksocknal_data.ksnd_tx_lock);
 
@@ -2411,8 +2408,8 @@ ksocknal_base_startup(void)
 
 	ksocknal_data.ksnd_peer_hash_size = SOCKNAL_PEER_HASH_SIZE;
 	LIBCFS_ALLOC(ksocknal_data.ksnd_peers,
-		      sizeof(struct list_head) *
-		      ksocknal_data.ksnd_peer_hash_size);
+		     sizeof(struct list_head) *
+		     ksocknal_data.ksnd_peer_hash_size);
 	if (ksocknal_data.ksnd_peers == NULL)
 		return -ENOMEM;
 
@@ -2577,9 +2574,9 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 		list_for_each(tmp, &peer->ksnp_conns) {
 			conn = list_entry(tmp, ksock_conn_t, ksnc_list);
 			CWARN("Conn: ref %d, sref %d, t %d, c %d\n",
-			       atomic_read(&conn->ksnc_conn_refcount),
-			       atomic_read(&conn->ksnc_sock_refcount),
-			       conn->ksnc_type, conn->ksnc_closing);
+			      atomic_read(&conn->ksnc_conn_refcount),
+			      atomic_read(&conn->ksnc_sock_refcount),
+			      conn->ksnc_type, conn->ksnc_closing);
 		}
 	}
 
@@ -2712,8 +2709,7 @@ ksocknal_search_new_ipif(ksock_net_t *net)
 		if (colon != NULL) /* ignore alias device */
 			*colon = 0;
 
-		list_for_each_entry(tmp, &ksocknal_data.ksnd_nets,
-					ksnn_list) {
+		list_for_each_entry(tmp, &ksocknal_data.ksnd_nets, ksnn_list) {
 			for (j = 0; !found && j < tmp->ksnn_ninterfaces; j++) {
 				char *ifnam2 =
 					&tmp->ksnn_interfaces[j].ksni_name[0];
@@ -2852,8 +2848,8 @@ ksocknal_startup(lnet_ni_t *ni)
 				break;
 
 			rc = lnet_ipif_query(ni->ni_interfaces[i], &up,
-				&net->ksnn_interfaces[i].ksni_ipaddr,
-				&net->ksnn_interfaces[i].ksni_netmask);
+					     &net->ksnn_interfaces[i].ksni_ipaddr,
+					     &net->ksnn_interfaces[i].ksni_netmask);
 
 			if (rc != 0) {
 				CERROR("Can't get interface %s info: %d\n",
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index f53677d..1243f92 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -545,7 +545,7 @@ ksocknal_process_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 		/* enomem list takes over scheduler's ref... */
 		LASSERT (conn->ksnc_tx_scheduled);
 		list_add_tail(&conn->ksnc_tx_list,
-				  &ksocknal_data.ksnd_enomem_conns);
+			      &ksocknal_data.ksnd_enomem_conns);
 		if (!cfs_time_aftereq(cfs_time_add(cfs_time_current(),
 						   SOCKNAL_ENOMEM_RETRY),
 				   ksocknal_data.ksnd_reaper_waketime))
@@ -602,7 +602,7 @@ ksocknal_launch_connection_locked (ksock_route_t *route)
 	spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 
 	list_add_tail(&route->ksnr_connd_list,
-			  &ksocknal_data.ksnd_connd_routes);
+		      &ksocknal_data.ksnd_connd_routes);
 	wake_up(&ksocknal_data.ksnd_connd_waitq);
 
 	spin_unlock_bh(&ksocknal_data.ksnd_connd_lock);
@@ -708,9 +708,8 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 	LASSERT(!conn->ksnc_closing);
 
 	CDEBUG(D_NET, "Sending to %s ip %pI4h:%d\n",
-		libcfs_id2str(conn->ksnc_peer->ksnp_id),
-		&conn->ksnc_ipaddr,
-		conn->ksnc_port);
+	       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+	       &conn->ksnc_ipaddr, conn->ksnc_port);
 
 	ksocknal_tx_prep(conn, tx);
 
@@ -782,8 +781,7 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 	    !conn->ksnc_tx_scheduled) { /* not scheduled to send */
 		/* +1 ref for scheduler */
 		ksocknal_conn_addref(conn);
-		list_add_tail (&conn->ksnc_tx_list,
-				   &sched->kss_tx_conns);
+		list_add_tail(&conn->ksnc_tx_list, &sched->kss_tx_conns);
 		conn->ksnc_tx_scheduled = 1;
 		wake_up (&sched->kss_waitq);
 	}
@@ -1433,7 +1431,7 @@ int ksocknal_scheduler(void *arg)
 
 		if (!list_empty (&sched->kss_rx_conns)) {
 			conn = list_entry(sched->kss_rx_conns.next,
-					      ksock_conn_t, ksnc_rx_list);
+					  ksock_conn_t, ksnc_rx_list);
 			list_del(&conn->ksnc_rx_list);
 
 			LASSERT(conn->ksnc_rx_scheduled);
@@ -1468,8 +1466,8 @@ int ksocknal_scheduler(void *arg)
 				conn->ksnc_rx_state = SOCKNAL_RX_PARSE_WAIT;
 			} else if (conn->ksnc_rx_ready) {
 				/* reschedule for rx */
-				list_add_tail (&conn->ksnc_rx_list,
-						   &sched->kss_rx_conns);
+				list_add_tail(&conn->ksnc_rx_list,
+					      &sched->kss_rx_conns);
 			} else {
 				conn->ksnc_rx_scheduled = 0;
 				/* drop my ref */
@@ -1483,13 +1481,12 @@ int ksocknal_scheduler(void *arg)
 			LIST_HEAD(zlist);
 
 			if (!list_empty(&sched->kss_zombie_noop_txs)) {
-				list_add(&zlist,
-					     &sched->kss_zombie_noop_txs);
+				list_add(&zlist, &sched->kss_zombie_noop_txs);
 				list_del_init(&sched->kss_zombie_noop_txs);
 			}
 
 			conn = list_entry(sched->kss_tx_conns.next,
-					      ksock_conn_t, ksnc_tx_list);
+					  ksock_conn_t, ksnc_tx_list);
 			list_del (&conn->ksnc_tx_list);
 
 			LASSERT(conn->ksnc_tx_scheduled);
@@ -1497,7 +1494,7 @@ int ksocknal_scheduler(void *arg)
 			LASSERT(!list_empty(&conn->ksnc_tx_queue));
 
 			tx = list_entry(conn->ksnc_tx_queue.next,
-					    ksock_tx_t, tx_list);
+					ksock_tx_t, tx_list);
 
 			if (conn->ksnc_tx_carrier == tx)
 				ksocknal_next_tx_carrier(conn);
@@ -1527,8 +1524,7 @@ int ksocknal_scheduler(void *arg)
 			if (rc == -ENOMEM || rc == -EAGAIN) {
 				/* Incomplete send: replace tx on HEAD of tx_queue */
 				spin_lock_bh(&sched->kss_lock);
-				list_add(&tx->tx_list,
-					     &conn->ksnc_tx_queue);
+				list_add(&tx->tx_list, &conn->ksnc_tx_queue);
 			} else {
 				/* Complete send; tx -ref */
 				ksocknal_tx_decref(tx);
@@ -1547,7 +1543,7 @@ int ksocknal_scheduler(void *arg)
 				   !list_empty(&conn->ksnc_tx_queue)) {
 				/* reschedule for tx */
 				list_add_tail(&conn->ksnc_tx_list,
-						   &sched->kss_tx_conns);
+					      &sched->kss_tx_conns);
 			} else {
 				conn->ksnc_tx_scheduled = 0;
 				/* drop my ref */
@@ -1595,8 +1591,7 @@ void ksocknal_read_callback (ksock_conn_t *conn)
 	conn->ksnc_rx_ready = 1;
 
 	if (!conn->ksnc_rx_scheduled) {  /* not being progressed */
-		list_add_tail(&conn->ksnc_rx_list,
-				  &sched->kss_rx_conns);
+		list_add_tail(&conn->ksnc_rx_list, &sched->kss_rx_conns);
 		conn->ksnc_rx_scheduled = 1;
 		/* extra ref for scheduler */
 		ksocknal_conn_addref(conn);
@@ -1622,8 +1617,7 @@ void ksocknal_write_callback (ksock_conn_t *conn)
 
 	if (!conn->ksnc_tx_scheduled && /* not being progressed */
 	    !list_empty(&conn->ksnc_tx_queue)) { /* packets to send */
-		list_add_tail (&conn->ksnc_tx_list,
-				   &sched->kss_tx_conns);
+		list_add_tail(&conn->ksnc_tx_list, &sched->kss_tx_conns);
 		conn->ksnc_tx_scheduled = 1;
 		/* extra ref for scheduler */
 		ksocknal_conn_addref(conn);
@@ -1741,7 +1735,7 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 	rc = lnet_sock_read(sock, &hello->kshm_magic, sizeof (hello->kshm_magic), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
-			rc, &conn->ksnc_ipaddr);
+		       rc, &conn->ksnc_ipaddr);
 		LASSERT (rc < 0);
 		return rc;
 	}
@@ -1761,7 +1755,7 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 			    sizeof(hello->kshm_version), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
-			rc, &conn->ksnc_ipaddr);
+		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0);
 		return rc;
 	}
@@ -1825,8 +1819,8 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 		conn->ksnc_type = ksocknal_invert_type(hello->kshm_ctype);
 		if (conn->ksnc_type == SOCKLND_CONN_NONE) {
 			CERROR("Unexpected type %d from %s ip %pI4h\n",
-				hello->kshm_ctype, libcfs_id2str(*peerid),
-				&conn->ksnc_ipaddr);
+			       hello->kshm_ctype, libcfs_id2str(*peerid),
+			       &conn->ksnc_ipaddr);
 			return -EPROTO;
 		}
 
@@ -1849,9 +1843,8 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 
 	if (ksocknal_invert_type(hello->kshm_ctype) != conn->ksnc_type) {
 		CERROR("Mismatched types: me %d, %s ip %pI4h %d\n",
-			conn->ksnc_type, libcfs_id2str(*peerid),
-			&conn->ksnc_ipaddr,
-			hello->kshm_ctype);
+		       conn->ksnc_type, libcfs_id2str(*peerid),
+		       &conn->ksnc_ipaddr, hello->kshm_ctype);
 		return -EPROTO;
 	}
 
@@ -2009,7 +2002,7 @@ ksocknal_connect (ksock_route_t *route)
 		 */
 		if (!list_empty (&peer->ksnp_conns)) {
 			conn = list_entry(peer->ksnp_conns.next,
-					      ksock_conn_t, ksnc_list);
+					  ksock_conn_t, ksnc_list);
 			LASSERT (conn->ksnc_proto == &ksocknal_protocol_v3x);
 		}
 
@@ -2152,8 +2145,8 @@ ksocknal_connd_get_route_locked(signed long *timeout_p)
 	now = cfs_time_current();
 
 	/* connd_routes can contain both pending and ordinary routes */
-	list_for_each_entry (route, &ksocknal_data.ksnd_connd_routes,
-				 ksnr_connd_list) {
+	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
+			    ksnr_connd_list) {
 
 		if (route->ksnr_retry_interval == 0 ||
 		    cfs_time_aftereq(now, route->ksnr_timeout))
@@ -2372,8 +2365,7 @@ ksocknal_flush_stale_txs(ksock_peer_t *peer)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	while (!list_empty (&peer->ksnp_tx_queue)) {
-		tx = list_entry (peer->ksnp_tx_queue.next,
-				     ksock_tx_t, tx_list);
+		tx = list_entry(peer->ksnp_tx_queue.next, ksock_tx_t, tx_list);
 
 		if (!cfs_time_aftereq(cfs_time_current(),
 				      tx->tx_deadline))
@@ -2498,9 +2490,8 @@ ksocknal_check_peer_timeouts (int idx)
 		 * holding only shared lock
 		 */
 		if (!list_empty (&peer->ksnp_tx_queue)) {
-			ksock_tx_t *tx =
-				list_entry (peer->ksnp_tx_queue.next,
-						ksock_tx_t, tx_list);
+			ksock_tx_t *tx = list_entry(peer->ksnp_tx_queue.next,
+						    ksock_tx_t, tx_list);
 
 			if (cfs_time_aftereq(cfs_time_current(),
 					     tx->tx_deadline)) {
@@ -2535,7 +2526,7 @@ ksocknal_check_peer_timeouts (int idx)
 		}
 
 		tx = list_entry(peer->ksnp_zc_req_list.next,
-				    ksock_tx_t, tx_zc_list);
+				ksock_tx_t, tx_zc_list);
 		deadline = tx->tx_deadline;
 		resid = tx->tx_resid;
 		conn = tx->tx_conn;
@@ -2609,7 +2600,7 @@ ksocknal_reaper (void *arg)
 
 		if (!list_empty (&ksocknal_data.ksnd_enomem_conns)) {
 			list_add(&enomem_conns,
-				     &ksocknal_data.ksnd_enomem_conns);
+				 &ksocknal_data.ksnd_enomem_conns);
 			list_del_init(&ksocknal_data.ksnd_enomem_conns);
 		}
 
@@ -2618,8 +2609,8 @@ ksocknal_reaper (void *arg)
 		/* reschedule all the connections that stalled with ENOMEM... */
 		nenomem_conns = 0;
 		while (!list_empty (&enomem_conns)) {
-			conn = list_entry (enomem_conns.next,
-					       ksock_conn_t, ksnc_tx_list);
+			conn = list_entry(enomem_conns.next, ksock_conn_t,
+					  ksnc_tx_list);
 			list_del (&conn->ksnc_tx_list);
 
 			sched = conn->ksnc_scheduler;
@@ -2629,7 +2620,7 @@ ksocknal_reaper (void *arg)
 			LASSERT(conn->ksnc_tx_scheduled);
 			conn->ksnc_tx_ready = 1;
 			list_add_tail(&conn->ksnc_tx_list,
-					  &sched->kss_tx_conns);
+				      &sched->kss_tx_conns);
 			wake_up(&sched->kss_waitq);
 
 			spin_unlock_bh(&sched->kss_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index f0edf30..37df8a9 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -141,7 +141,7 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 		int msgflg = MSG_DONTWAIT;
 
 		CDEBUG(D_NET, "page %p + offset %x for %d\n",
-			       page, offset, kiov->kiov_len);
+		       page, offset, kiov->kiov_len);
 
 		if (!list_empty(&conn->ksnc_tx_queue) ||
 		    fragsize < tx->tx_resid)
@@ -198,8 +198,8 @@ ksocknal_lib_eager_ack(ksock_conn_t *conn)
 	 * on, introducing delay in completing zero-copy sends in my
 	 * peer.
 	 */
-	kernel_setsockopt(sock, SOL_TCP, TCP_QUICKACK,
-			       (char *)&opt, sizeof(opt));
+	kernel_setsockopt(sock, SOL_TCP, TCP_QUICKACK, (char *)&opt,
+			  sizeof(opt));
 }
 
 int
@@ -236,8 +236,8 @@ ksocknal_lib_recv_iov(ksock_conn_t *conn)
 	}
 	LASSERT(nob <= conn->ksnc_rx_nob_wanted);
 
-	rc = kernel_recvmsg(conn->ksnc_sock, &msg,
-		scratchiov, niov, nob, MSG_DONTWAIT);
+	rc = kernel_recvmsg(conn->ksnc_sock, &msg, scratchiov, niov, nob,
+			    MSG_DONTWAIT);
 
 	saved_csum = 0;
 	if (conn->ksnc_proto == &ksocknal_protocol_v2x) {
@@ -357,8 +357,8 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 
 	LASSERT(nob <= conn->ksnc_rx_nob_wanted);
 
-	rc = kernel_recvmsg(conn->ksnc_sock, &msg,
-			(struct kvec *)scratchiov, n, nob, MSG_DONTWAIT);
+	rc = kernel_recvmsg(conn->ksnc_sock, &msg, (struct kvec *)scratchiov,
+			    n, nob, MSG_DONTWAIT);
 
 	if (conn->ksnc_msg.ksm_csum != 0) {
 		for (i = 0, sum = rc; sum > 0; i++, sum -= fragnob) {
@@ -449,7 +449,7 @@ ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem, int *rxmem, int *
 	if (rc == 0) {
 		len = sizeof(*nagle);
 		rc = kernel_getsockopt(sock, SOL_TCP, TCP_NODELAY,
-					   (char *)nagle, &len);
+				       (char *)nagle, &len);
 	}
 
 	ksocknal_connsock_decref(conn);
@@ -482,16 +482,16 @@ ksocknal_lib_setup_sock(struct socket *sock)
 	linger.l_onoff = 0;
 	linger.l_linger = 0;
 
-	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_LINGER,
-			      (char *)&linger, sizeof(linger));
+	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_LINGER, (char *)&linger,
+			       sizeof(linger));
 	if (rc != 0) {
 		CERROR("Can't set SO_LINGER: %d\n", rc);
 		return rc;
 	}
 
 	option = -1;
-	rc = kernel_setsockopt(sock, SOL_TCP, TCP_LINGER2,
-				    (char *)&option, sizeof(option));
+	rc = kernel_setsockopt(sock, SOL_TCP, TCP_LINGER2, (char *)&option,
+			       sizeof(option));
 	if (rc != 0) {
 		CERROR("Can't set SO_LINGER2: %d\n", rc);
 		return rc;
@@ -501,7 +501,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 		option = 1;
 
 		rc = kernel_setsockopt(sock, SOL_TCP, TCP_NODELAY,
-					    (char *)&option, sizeof(option));
+				       (char *)&option, sizeof(option));
 		if (rc != 0) {
 			CERROR("Can't disable nagle: %d\n", rc);
 			return rc;
@@ -512,8 +512,8 @@ ksocknal_lib_setup_sock(struct socket *sock)
 			      *ksocknal_tunables.ksnd_rx_buffer_size);
 	if (rc != 0) {
 		CERROR("Can't set buffer tx %d, rx %d buffers: %d\n",
-			*ksocknal_tunables.ksnd_tx_buffer_size,
-			*ksocknal_tunables.ksnd_rx_buffer_size, rc);
+		       *ksocknal_tunables.ksnd_tx_buffer_size,
+		       *ksocknal_tunables.ksnd_rx_buffer_size, rc);
 		return rc;
 	}
 
@@ -527,8 +527,8 @@ ksocknal_lib_setup_sock(struct socket *sock)
 	do_keepalive = (keep_idle > 0 && keep_count > 0 && keep_intvl > 0);
 
 	option = (do_keepalive ? 1 : 0);
-	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
-			      (char *)&option, sizeof(option));
+	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, (char *)&option,
+			       sizeof(option));
 	if (rc != 0) {
 		CERROR("Can't set SO_KEEPALIVE: %d\n", rc);
 		return rc;
@@ -537,22 +537,22 @@ ksocknal_lib_setup_sock(struct socket *sock)
 	if (!do_keepalive)
 		return 0;
 
-	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPIDLE,
-				    (char *)&keep_idle, sizeof(keep_idle));
+	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPIDLE, (char *)&keep_idle,
+			       sizeof(keep_idle));
 	if (rc != 0) {
 		CERROR("Can't set TCP_KEEPIDLE: %d\n", rc);
 		return rc;
 	}
 
 	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPINTVL,
-				    (char *)&keep_intvl, sizeof(keep_intvl));
+			       (char *)&keep_intvl, sizeof(keep_intvl));
 	if (rc != 0) {
 		CERROR("Can't set TCP_KEEPINTVL: %d\n", rc);
 		return rc;
 	}
 
-	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT,
-				    (char *)&keep_count, sizeof(keep_count));
+	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT, (char *)&keep_count,
+			       sizeof(keep_count));
 	if (rc != 0) {
 		CERROR("Can't set TCP_KEEPCNT: %d\n", rc);
 		return rc;
@@ -583,7 +583,7 @@ ksocknal_lib_push_conn(ksock_conn_t *conn)
 	release_sock(sk);
 
 	rc = kernel_setsockopt(conn->ksnc_sock, SOL_TCP, TCP_NODELAY,
-				      (char *)&val, sizeof(val));
+			       (char *)&val, sizeof(val));
 	LASSERT(rc == 0);
 
 	lock_sock(sk);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 82ac02c..2fe23d4 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -76,7 +76,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 	ksock_tx_t *tx = conn->ksnc_tx_carrier;
 
 	LASSERT(tx_ack == NULL ||
-		 tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
+		tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
 	/*
 	 * Enqueue or piggyback tx_ack / cookie
@@ -88,7 +88,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 	if (tx == NULL) {
 		if (tx_ack != NULL) {
 			list_add_tail(&tx_ack->tx_list,
-					  &conn->ksnc_tx_queue);
+				      &conn->ksnc_tx_queue);
 			conn->ksnc_tx_carrier = tx_ack;
 		}
 		return 0;
@@ -98,7 +98,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 		/* tx is noop zc-ack, can't piggyback zc-ack cookie */
 		if (tx_ack != NULL)
 			list_add_tail(&tx_ack->tx_list,
-					  &conn->ksnc_tx_queue);
+				      &conn->ksnc_tx_queue);
 		return 0;
 	}
 
@@ -163,13 +163,13 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 
 	/* non-blocking ZC-ACK (to router) */
 	LASSERT(tx_ack == NULL ||
-		 tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
+		tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
 	tx = conn->ksnc_tx_carrier;
 	if (tx == NULL) {
 		if (tx_ack != NULL) {
 			list_add_tail(&tx_ack->tx_list,
-					  &conn->ksnc_tx_queue);
+				      &conn->ksnc_tx_queue);
 			conn->ksnc_tx_carrier = tx_ack;
 		}
 		return 0;
@@ -424,8 +424,8 @@ ksocknal_handle_zcack(ksock_conn_t *conn, __u64 cookie1, __u64 cookie2)
 
 	spin_lock(&peer->ksnp_lock);
 
-	list_for_each_entry_safe(tx, tmp,
-				     &peer->ksnp_zc_req_list, tx_zc_list) {
+	list_for_each_entry_safe(tx, tmp, &peer->ksnp_zc_req_list,
+				 tx_zc_list) {
 		__u64 c = tx->tx_msg.ksm_zc_cookies[0];
 
 		if (c == cookie1 || c == cookie2 || (cookie1 < c && c < cookie2)) {
@@ -587,7 +587,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 			    timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading rest of HELLO hdr from %pI4h\n",
-			rc, &conn->ksnc_ipaddr);
+		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		goto out;
 	}
@@ -622,7 +622,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 			    hello->kshm_nips * sizeof(__u32), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
-			rc, &conn->ksnc_ipaddr);
+		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		goto out;
 	}
@@ -661,7 +661,7 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 			    timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
-			rc, &conn->ksnc_ipaddr);
+		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
 	}
@@ -690,7 +690,7 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 			    hello->kshm_nips * sizeof(__u32), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
-			rc, &conn->ksnc_ipaddr);
+		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
 		return rc;
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 5260de2..b330f64 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -142,7 +142,7 @@ EXPORT_SYMBOL(lnet_connect_console_error);
 
 int
 lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
-	    __u32 local_ip, __u32 peer_ip, int peer_port)
+	     __u32 local_ip, __u32 peer_ip, int peer_port)
 {
 	lnet_acceptor_connreq_t cr;
 	struct socket *sock;
@@ -259,7 +259,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 			    accept_timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading connection request version from %pI4h\n",
-			rc, &peer_ip);
+		       rc, &peer_ip);
 		return -EIO;
 	}
 
@@ -292,7 +292,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 			    accept_timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading connection request from %pI4h\n",
-			rc, &peer_ip);
+		       rc, &peer_ip);
 		return -EIO;
 	}
 
@@ -313,7 +313,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 		/* This catches a request for the loopback LND */
 		lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x121, "Refusing connection from %pI4h for %s: NI doesn not accept IP connections\n",
-				  &peer_ip, libcfs_nid2str(cr.acr_nid));
+				   &peer_ip, libcfs_nid2str(cr.acr_nid));
 		return -EPERM;
 	}
 
@@ -396,7 +396,7 @@ lnet_acceptor(void *arg)
 				    accept_timeout);
 		if (rc != 0) {
 			CERROR("Error %d reading connection request from %pI4h\n",
-				rc, &peer_ip);
+			       rc, &peer_ip);
 			goto failed;
 		}
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 79447bf..aeef480 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -857,7 +857,7 @@ lnet_shutdown_lndnis(void)
 	/* Unlink NIs from the global table */
 	while (!list_empty(&the_lnet.ln_nis)) {
 		ni = list_entry(the_lnet.ln_nis.next,
-				    lnet_ni_t, ni_list);
+				lnet_ni_t, ni_list);
 		/* move it to zombie list and nobody can find it anymore */
 		list_move(&ni->ni_list, &the_lnet.ln_nis_zombie);
 		lnet_ni_decref_locked(ni, 0);	/* drop ln_nis' ref */
@@ -906,7 +906,7 @@ lnet_shutdown_lndnis(void)
 		int j;
 
 		ni = list_entry(the_lnet.ln_nis_zombie.next,
-				    lnet_ni_t, ni_list);
+				lnet_ni_t, ni_list);
 		list_del_init(&ni->ni_list);
 		cfs_percpt_for_each(ref, j, ni->ni_refs) {
 			if (*ref == 0)
@@ -1004,7 +1004,7 @@ lnet_startup_lndnis(void)
 		if (lnd == NULL) {
 			mutex_unlock(&the_lnet.ln_lnd_mutex);
 			rc = request_module("%s",
-						libcfs_lnd2modname(lnd_type));
+					    libcfs_lnd2modname(lnd_type));
 			mutex_lock(&the_lnet.ln_lnd_mutex);
 
 			lnd = lnet_find_lnd_by_type(lnd_type);
@@ -1046,7 +1046,7 @@ lnet_startup_lndnis(void)
 		list_add_tail(&ni->ni_list, &the_lnet.ln_nis);
 		if (ni->ni_cpts != NULL) {
 			list_add_tail(&ni->ni_cptlist,
-					  &the_lnet.ln_nis_cpt);
+				      &the_lnet.ln_nis_cpt);
 			lnet_ni_addref_locked(ni, 0);
 		}
 
@@ -1189,7 +1189,7 @@ lnet_fini(void)
 
 	while (!list_empty(&the_lnet.ln_lnds))
 		lnet_unregister_lnd(list_entry(the_lnet.ln_lnds.next,
-						   lnd_t, lnd_list));
+					       lnd_t, lnd_list));
 	lnet_destroy_locks();
 
 	the_lnet.ln_init = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 01efe61..5339dee 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -542,10 +542,9 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 			if (sscanf(parsed, "%d-%d%n", &lo, &hi, &scanned) < 2) {
 
 				/* simple string enumeration */
-				if (lnet_expand1tb(
-				     &pending, str, sep, sep2,
-				     parsed,
-				     (int)(enditem - parsed)) != 0) {
+				if (lnet_expand1tb(&pending, str, sep, sep2,
+						   parsed,
+						   (int)(enditem - parsed)) != 0) {
 					goto failed;
 				}
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 0268ce5..7e1ef18 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -173,8 +173,8 @@ EXPORT_SYMBOL(lnet_iov_nob);
 
 void
 lnet_copy_iov2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
-		   unsigned int nsiov, struct kvec *siov, unsigned int soffset,
-		   unsigned int nob)
+		  unsigned int nsiov, struct kvec *siov, unsigned int soffset,
+		  unsigned int nob)
 {
 	/* NB diov, siov are READ-ONLY */
 	unsigned int this_nob;
@@ -208,7 +208,7 @@ lnet_copy_iov2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
 		this_nob = min(this_nob, nob);
 
 		memcpy((char *)diov->iov_base + doffset,
-			(char *)siov->iov_base + soffset, this_nob);
+		       (char *)siov->iov_base + soffset, this_nob);
 		nob -= this_nob;
 
 		if (diov->iov_len > doffset + this_nob) {
@@ -232,8 +232,8 @@ EXPORT_SYMBOL(lnet_copy_iov2iov);
 
 int
 lnet_extract_iov(int dst_niov, struct kvec *dst,
-		  int src_niov, struct kvec *src,
-		  unsigned int offset, unsigned int len)
+		 int src_niov, struct kvec *src,
+		 unsigned int offset, unsigned int len)
 {
 	/*
 	 * Initialise 'dst' to the subset of 'src' starting at 'offset',
@@ -516,8 +516,8 @@ EXPORT_SYMBOL(lnet_copy_iov2kiov);
 
 int
 lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
-		   int src_niov, lnet_kiov_t *src,
-		   unsigned int offset, unsigned int len)
+		  int src_niov, lnet_kiov_t *src,
+		  unsigned int offset, unsigned int len)
 {
 	/*
 	 * Initialise 'dst' to the subset of 'src' starting at 'offset',
@@ -550,7 +550,7 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		if (len <= frag_len) {
 			dst->kiov_len = len;
 			LASSERT(dst->kiov_offset + dst->kiov_len
-					     <= PAGE_CACHE_SIZE);
+					<= PAGE_CACHE_SIZE);
 			return niov;
 		}
 
@@ -653,7 +653,7 @@ lnet_ni_send(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	LASSERT(!in_interrupt());
 	LASSERT(LNET_NETTYP(LNET_NIDNET(ni->ni_nid)) == LOLND ||
-		 (msg->msg_txcredit && msg->msg_peertxcredit));
+		(msg->msg_txcredit && msg->msg_peertxcredit));
 
 	rc = (ni->ni_lnd->lnd_send)(ni, priv, msg);
 	if (rc < 0)
@@ -835,7 +835,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 
 	if (!msg->msg_peertxcredit) {
 		LASSERT((lp->lp_txcredits < 0) ==
-			 !list_empty(&lp->lp_txq));
+			!list_empty(&lp->lp_txq));
 
 		msg->msg_peertxcredit = 1;
 		lp->lp_txqnob += msg->msg_len + sizeof(lnet_hdr_t);
@@ -920,7 +920,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 
 	if (!msg->msg_peerrtrcredit) {
 		LASSERT((lp->lp_rtrcredits < 0) ==
-			 !list_empty(&lp->lp_rtrq));
+			!list_empty(&lp->lp_rtrq));
 
 		msg->msg_peerrtrcredit = 1;
 		lp->lp_rtrcredits--;
@@ -993,7 +993,7 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 		tq->tq_credits++;
 		if (tq->tq_credits <= 0) {
 			msg2 = list_entry(tq->tq_delayed.next,
-					      lnet_msg_t, msg_list);
+					  lnet_msg_t, msg_list);
 			list_del(&msg2->msg_list);
 
 			LASSERT(msg2->msg_txpeer->lp_ni == ni);
@@ -1016,7 +1016,7 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 		txpeer->lp_txcredits++;
 		if (txpeer->lp_txcredits <= 0) {
 			msg2 = list_entry(txpeer->lp_txq.next,
-					      lnet_msg_t, msg_list);
+					  lnet_msg_t, msg_list);
 			list_del(&msg2->msg_list);
 
 			LASSERT(msg2->msg_txpeer == txpeer);
@@ -1066,7 +1066,7 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 		rbp->rbp_credits++;
 		if (rbp->rbp_credits <= 0) {
 			msg2 = list_entry(rbp->rbp_msgs.next,
-					      lnet_msg_t, msg_list);
+					  lnet_msg_t, msg_list);
 			list_del(&msg2->msg_list);
 
 			(void) lnet_post_routed_recv_locked(msg2, 1);
@@ -1083,7 +1083,7 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 		rxpeer->lp_rtrcredits++;
 		if (rxpeer->lp_rtrcredits <= 0) {
 			msg2 = list_entry(rxpeer->lp_rtrq.next,
-					      lnet_msg_t, msg_list);
+					  lnet_msg_t, msg_list);
 			list_del(&msg2->msg_list);
 
 			(void) lnet_post_routed_recv_locked(msg2, 1);
@@ -2160,7 +2160,7 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 	rc = lnet_send(self, msg, LNET_NID_ANY);
 	if (rc != 0) {
 		CNETERR("Error sending PUT to %s: %d\n",
-		       libcfs_id2str(target), rc);
+			libcfs_id2str(target), rc);
 		lnet_finalize(NULL, msg, rc);
 	}
 
@@ -2195,14 +2195,14 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 
 	if (msg == NULL) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
-			libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
+		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
 		goto drop;
 	}
 
 	if (getmd->md_threshold == 0) {
 		CERROR("%s: Dropping REPLY from %s for inactive MD %p\n",
-			libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id),
-			getmd);
+		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id),
+		       getmd);
 		lnet_res_unlock(cpt);
 		goto drop;
 	}
@@ -2358,7 +2358,7 @@ LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
 	rc = lnet_send(self, msg, LNET_NID_ANY);
 	if (rc < 0) {
 		CNETERR("Error sending GET to %s: %d\n",
-		       libcfs_id2str(target), rc);
+			libcfs_id2str(target), rc);
 		lnet_finalize(NULL, msg, rc);
 	}
 
@@ -2444,7 +2444,7 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 			LASSERT(!list_empty(&rnet->lrn_routes));
 
 			list_for_each_entry(route, &rnet->lrn_routes,
-						lr_list) {
+					    lr_list) {
 				if (shortest == NULL ||
 				    route->lr_hops < shortest->lr_hops)
 					shortest = route;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 62717ee..a680e68 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -523,7 +523,7 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 
 	while (!list_empty(&container->msc_finalizing)) {
 		msg = list_entry(container->msc_finalizing.next,
-				     lnet_msg_t, msg_list);
+				 lnet_msg_t, msg_list);
 
 		list_del(&msg->msg_list);
 
@@ -554,7 +554,7 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 
 	while (!list_empty(&container->msc_active)) {
 		lnet_msg_t *msg = list_entry(container->msc_active.next,
-						 lnet_msg_t, msg_activelist);
+					     lnet_msg_t, msg_activelist);
 
 		LASSERT(msg->msg_onactivelist);
 		msg->msg_onactivelist = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 3a82fb6..d99364f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -458,7 +458,7 @@ lnet_ptl_match_early(struct lnet_portal *ptl, struct lnet_msg *msg)
 		if (msg->msg_rx_ready_delay) {
 			msg->msg_rx_delayed = 1;
 			list_add_tail(&msg->msg_list,
-					  &ptl->ptl_msg_delayed);
+				      &ptl->ptl_msg_delayed);
 		}
 		rc = LNET_MATCHMD_NONE;
 	} else {
@@ -498,7 +498,7 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 
 		if (i == 0) { /* the first try, attach on stealing list */
 			list_add_tail(&msg->msg_list,
-					  &ptl->ptl_msg_stealing);
+				      &ptl->ptl_msg_stealing);
 		}
 
 		if (!list_empty(&msg->msg_list)) { /* on stealing list */
@@ -531,7 +531,7 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 			if (lnet_ptl_is_lazy(ptl)) {
 				msg->msg_rx_delayed = 1;
 				list_add_tail(&msg->msg_list,
-						  &ptl->ptl_msg_delayed);
+					      &ptl->ptl_msg_delayed);
 				rc = LNET_MATCHMD_NONE;
 			} else {
 				rc = LNET_MATCHMD_DROP;
@@ -751,7 +751,7 @@ lnet_ptl_cleanup(struct lnet_portal *ptl)
 		for (j = 0; j < LNET_MT_HASH_SIZE + 1; j++) {
 			while (!list_empty(&mhash[j])) {
 				me = list_entry(mhash[j].next,
-						    lnet_me_t, me_list);
+						lnet_me_t, me_list);
 				CERROR("Active ME %p on exit\n", me);
 				list_del(&me->me_list);
 				lnet_me_free(me);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index c383595..0b3ef17 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -440,7 +440,7 @@ lnet_sock_setbuf(struct socket *sock, int txbufsize, int rxbufsize)
 	if (rxbufsize != 0) {
 		option = rxbufsize;
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
-				      (char *)&option, sizeof(option));
+				       (char *)&option, sizeof(option));
 		if (rc != 0) {
 			CERROR("Can't set receive buffer %d: %d\n",
 			       option, rc);
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 2a137f4..314e164 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -46,9 +46,9 @@ lolnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 
 static int
 lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
-	    int delayed, unsigned int niov,
-	    struct kvec *iov, lnet_kiov_t *kiov,
-	    unsigned int offset, unsigned int mlen, unsigned int rlen)
+	   int delayed, unsigned int niov,
+	   struct kvec *iov, lnet_kiov_t *kiov,
+	   unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
 	lnet_msg_t *sendmsg = private;
 
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 36577fe..00de4fa 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -380,7 +380,7 @@ int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 			return 1;
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link)
 			if (nr->nr_netstrfns->nf_match_addr(LNET_NIDADDR(nid),
-						       &ar->ar_numaddr_ranges))
+							    &ar->ar_numaddr_ranges))
 				return 1;
 	}
 	return 0;
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 1fceed3..9c0f264 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -155,7 +155,7 @@ lnet_peer_tables_cleanup(void)
 
 		while (!list_empty(&deathrow)) {
 			lp = list_entry(deathrow.next,
-					    lnet_peer_t, lp_hashlist);
+					lnet_peer_t, lp_hashlist);
 			list_del(&lp->lp_hashlist);
 			LIBCFS_FREE(lp, sizeof(*lp));
 		}
@@ -227,7 +227,7 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 
 	if (!list_empty(&ptable->pt_deathrow)) {
 		lp = list_entry(ptable->pt_deathrow.next,
-				    lnet_peer_t, lp_hashlist);
+				lnet_peer_t, lp_hashlist);
 		list_del(&lp->lp_hashlist);
 	}
 
@@ -293,7 +293,7 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 	lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
 
 	list_add_tail(&lp->lp_hashlist,
-			  &ptable->pt_hash[lnet_nid2peerhash(nid)]);
+		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
 	ptable->pt_version++;
 	*lpp = lp;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index b6b2ed8..754f7f0 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -180,7 +180,7 @@ lnet_rtr_addref_locked(lnet_peer_t *lp)
 		/* a simple insertion sort */
 		list_for_each_prev(pos, &the_lnet.ln_routers) {
 			lnet_peer_t *rtr = list_entry(pos, lnet_peer_t,
-							  lp_rtr_list);
+						      lp_rtr_list);
 
 			if (rtr->lp_nid < lp->lp_nid)
 				break;
@@ -206,7 +206,7 @@ lnet_rtr_decref_locked(lnet_peer_t *lp)
 
 		if (lp->lp_rcd != NULL) {
 			list_add(&lp->lp_rcd->rcd_list,
-				     &the_lnet.ln_rcd_deathrow);
+				 &the_lnet.ln_rcd_deathrow);
 			lp->lp_rcd = NULL;
 		}
 
@@ -432,8 +432,7 @@ lnet_check_routes(void)
 				lnet_nid_t nid2;
 				int net;
 
-				route = list_entry(e2, lnet_route_t,
-						       lr_list);
+				route = list_entry(e2, lnet_route_t, lr_list);
 
 				if (route2 == NULL) {
 					route2 = route;
@@ -493,7 +492,7 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
 		rnet = list_entry(e1, lnet_remotenet_t, lrn_list);
 
 		if (!(net == LNET_NIDNET(LNET_NID_ANY) ||
-			net == rnet->lrn_net))
+		      net == rnet->lrn_net))
 			continue;
 
 		list_for_each(e2, &rnet->lrn_routes) {
@@ -565,8 +564,7 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
 			rnet = list_entry(e1, lnet_remotenet_t, lrn_list);
 
 			list_for_each(e2, &rnet->lrn_routes) {
-				route = list_entry(e2, lnet_route_t,
-						       lr_list);
+				route = list_entry(e2, lnet_route_t, lr_list);
 
 				if (idx-- == 0) {
 					*net      = rnet->lrn_net;
@@ -1111,13 +1109,13 @@ lnet_prune_rc_data(int wait_unlink)
 	if (the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING) {
 		/* router checker is stopping, prune all */
 		list_for_each_entry(lp, &the_lnet.ln_routers,
-					lp_rtr_list) {
+				    lp_rtr_list) {
 			if (lp->lp_rcd == NULL)
 				continue;
 
 			LASSERT(list_empty(&lp->lp_rcd->rcd_list));
 			list_add(&lp->lp_rcd->rcd_list,
-				     &the_lnet.ln_rcd_deathrow);
+				 &the_lnet.ln_rcd_deathrow);
 			lp->lp_rcd = NULL;
 		}
 	}
@@ -1139,7 +1137,7 @@ lnet_prune_rc_data(int wait_unlink)
 	/* release all zombie RCDs */
 	while (!list_empty(&the_lnet.ln_rcd_zombie)) {
 		list_for_each_entry_safe(rcd, tmp, &the_lnet.ln_rcd_zombie,
-					     rcd_list) {
+					 rcd_list) {
 			if (LNetHandleIsInvalid(rcd->rcd_mdh))
 				list_move(&rcd->rcd_list, &head);
 		}
@@ -1151,7 +1149,7 @@ lnet_prune_rc_data(int wait_unlink)
 
 		while (!list_empty(&head)) {
 			rcd = list_entry(head.next,
-					     lnet_rc_data_t, rcd_list);
+					 lnet_rc_data_t, rcd_list);
 			list_del_init(&rcd->rcd_list);
 			lnet_destroy_rc_data(rcd);
 		}
@@ -1301,7 +1299,7 @@ lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp)
 		LASSERT(rbp->rbp_credits > 0);
 
 		rb = list_entry(rbp->rbp_bufs.next,
-				    lnet_rtrbuf_t, rb_list);
+				lnet_rtrbuf_t, rb_list);
 		list_del(&rb->rb_list);
 		lnet_destroy_rtrbuf(rb, npages);
 		nbuffers++;
@@ -1521,15 +1519,15 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	LASSERT(!in_interrupt());
 
 	CDEBUG(D_NET, "%s notifying %s: %s\n",
-		(ni == NULL) ? "userspace" : libcfs_nid2str(ni->ni_nid),
-		libcfs_nid2str(nid),
-		alive ? "up" : "down");
+	       (ni == NULL) ? "userspace" : libcfs_nid2str(ni->ni_nid),
+	       libcfs_nid2str(nid),
+	       alive ? "up" : "down");
 
 	if (ni != NULL &&
 	    LNET_NIDNET(ni->ni_nid) != LNET_NIDNET(nid)) {
 		CWARN("Ignoring notification of %s %s by %s (different net)\n",
-			libcfs_nid2str(nid), alive ? "birth" : "death",
-			libcfs_nid2str(ni->ni_nid));
+		      libcfs_nid2str(nid), alive ? "birth" : "death",
+		      libcfs_nid2str(ni->ni_nid));
 		return -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 339c276..4a5067c 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -78,9 +78,10 @@
 #define LNET_PROC_VERSION(v)	((unsigned int)((v) & LNET_PROC_VER_MASK))
 
 static int proc_call_handler(void *data, int write, loff_t *ppos,
-		void __user *buffer, size_t *lenp,
-		int (*handler)(void *data, int write,
-		loff_t pos, void __user *buffer, int len))
+			     void __user *buffer, size_t *lenp,
+			     int (*handler)(void *data, int write,
+					    loff_t pos, void __user *buffer,
+					    int len))
 {
 	int rc = handler(data, write, *ppos, buffer, *lenp);
 
@@ -216,14 +217,14 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 
 			while (n != rn_list && route == NULL) {
 				rnet = list_entry(n, lnet_remotenet_t,
-						      lrn_list);
+						  lrn_list);
 
 				r = rnet->lrn_routes.next;
 
 				while (r != &rnet->lrn_routes) {
 					lnet_route_t *re =
 						list_entry(r, lnet_route_t,
-							       lr_list);
+							   lr_list);
 					if (skip == 0) {
 						route = re;
 						break;
@@ -332,7 +333,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 		while (r != &the_lnet.ln_routers) {
 			lnet_peer_t *lp = list_entry(r, lnet_peer_t,
-							 lp_rtr_list);
+						     lp_rtr_list);
 
 			if (skip == 0) {
 				peer = lp;
@@ -479,7 +480,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 			while (p != &ptable->pt_hash[hash]) {
 				lnet_peer_t *lp = list_entry(p, lnet_peer_t,
-								 lp_hashlist);
+							     lp_hashlist);
 				if (skip == 0) {
 					peer = lp;
 
@@ -734,13 +735,14 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 					lnet_net_lock(i);
 
 				s += snprintf(s, tmpstr + tmpsiz - s,
-				      "%-24s %6s %5d %4d %4d %4d %5d %5d %5d\n",
-				      libcfs_nid2str(ni->ni_nid), stat,
-				      last_alive, *ni->ni_refs[i],
-				      ni->ni_peertxcredits,
-				      ni->ni_peerrtrcredits,
-				      tq->tq_credits_max,
-				      tq->tq_credits, tq->tq_credits_min);
+					      "%-24s %6s %5d %4d %4d %4d %5d %5d %5d\n",
+					      libcfs_nid2str(ni->ni_nid), stat,
+					      last_alive, *ni->ni_refs[i],
+					      ni->ni_peertxcredits,
+					      ni->ni_peerrtrcredits,
+					      tq->tq_credits_max,
+					      tq->tq_credits,
+					      tq->tq_credits_min);
 				if (i != 0)
 					lnet_net_unlock(i);
 			}
@@ -839,7 +841,7 @@ static int __proc_lnet_portal_rotor(void *data, int write,
 			rc = 0;
 		} else {
 			rc = cfs_trace_copyout_string(buffer, nob,
-					buf + pos, "\n");
+						      buf + pos, "\n");
 		}
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 8b159b6..88fb54d 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -220,7 +220,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 
 bad_data:
 	CERROR("Bad data in page %p: %#llx, %#llx expected\n",
-		pg, data, magic);
+	       pg, data, magic);
 	return 1;
 }
 
@@ -246,7 +246,7 @@ brw_check_bulk(srpc_bulk_t *bk, int pattern, __u64 magic)
 		pg = bk->bk_iovs[i].kiov_page;
 		if (brw_check_page(pg, pattern, magic) != 0) {
 			CERROR("Bulk page %p (%d/%d) is corrupted!\n",
-				pg, i, bk->bk_niov);
+			       pg, i, bk->bk_niov);
 			return 1;
 		}
 	}
@@ -256,7 +256,7 @@ brw_check_bulk(srpc_bulk_t *bk, int pattern, __u64 magic)
 
 static int
 brw_client_prep_rpc(sfw_test_unit_t *tsu,
-		     lnet_process_id_t dest, srpc_client_rpc_t **rpcpp)
+		    lnet_process_id_t dest, srpc_client_rpc_t **rpcpp)
 {
 	srpc_bulk_t *bulk = tsu->tsu_private;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
@@ -328,7 +328,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 
 	if (rpc->crpc_status != 0) {
 		CERROR("BRW RPC to %s failed with %d\n",
-			libcfs_id2str(rpc->crpc_dest), rpc->crpc_status);
+		       libcfs_id2str(rpc->crpc_dest), rpc->crpc_status);
 		if (!tsi->tsi_stopping) /* rpc could have been aborted */
 			atomic_inc(&sn->sn_brw_errors);
 		goto out;
@@ -340,8 +340,8 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	}
 
 	CDEBUG(reply->brw_status ? D_WARNING : D_NET,
-		"BRW RPC to %s finished with brw_status: %d\n",
-		libcfs_id2str(rpc->crpc_dest), reply->brw_status);
+	       "BRW RPC to %s finished with brw_status: %d\n",
+	       libcfs_id2str(rpc->crpc_dest), reply->brw_status);
 
 	if (reply->brw_status != 0) {
 		atomic_inc(&sn->sn_brw_errors);
@@ -354,7 +354,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 
 	if (brw_check_bulk(&rpc->crpc_bulk, reqst->brw_flags, magic) != 0) {
 		CERROR("Bulk data from %s is corrupted!\n",
-			libcfs_id2str(rpc->crpc_dest));
+		       libcfs_id2str(rpc->crpc_dest));
 		atomic_inc(&sn->sn_brw_errors);
 		rpc->crpc_status = -EBADMSG;
 	}
@@ -373,12 +373,12 @@ brw_server_rpc_done(struct srpc_server_rpc *rpc)
 
 	if (rpc->srpc_status != 0)
 		CERROR("Bulk transfer %s %s has failed: %d\n",
-			blk->bk_sink ? "from" : "to",
-			libcfs_id2str(rpc->srpc_peer), rpc->srpc_status);
+		       blk->bk_sink ? "from" : "to",
+		       libcfs_id2str(rpc->srpc_peer), rpc->srpc_status);
 	else
 		CDEBUG(D_NET, "Transferred %d pages bulk data %s %s\n",
-			blk->bk_niov, blk->bk_sink ? "from" : "to",
-			libcfs_id2str(rpc->srpc_peer));
+		       blk->bk_niov, blk->bk_sink ? "from" : "to",
+		       libcfs_id2str(rpc->srpc_peer));
 
 	sfw_free_pages(rpc);
 }
@@ -399,8 +399,8 @@ brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 
 	if (status != 0) {
 		CERROR("BRW bulk %s failed for RPC from %s: %d\n",
-			reqst->brw_rw == LST_BRW_READ ? "READ" : "WRITE",
-			libcfs_id2str(rpc->srpc_peer), status);
+		       reqst->brw_rw == LST_BRW_READ ? "READ" : "WRITE",
+		       libcfs_id2str(rpc->srpc_peer), status);
 		return -EIO;
 	}
 
@@ -412,7 +412,7 @@ brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 
 	if (brw_check_bulk(rpc->srpc_bulk, reqst->brw_flags, magic) != 0) {
 		CERROR("Bulk data from %s is corrupted!\n",
-			libcfs_id2str(rpc->srpc_peer));
+		       libcfs_id2str(rpc->srpc_peer));
 		reply->brw_status = EBADMSG;
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index a534665..cb5c125 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -62,9 +62,8 @@ lst_session_new_ioctl(lstio_session_new_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_ses_namep,
-			       args->lstio_ses_nmlen)) {
+	if (copy_from_user(name, args->lstio_ses_namep,
+			   args->lstio_ses_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_ses_nmlen + 1);
 		return -EFAULT;
 	}
@@ -137,7 +136,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 			return -ENOMEM;
 
 		if (copy_from_user(name, args->lstio_dbg_namep,
-				       args->lstio_dbg_nmlen)) {
+				   args->lstio_dbg_nmlen)) {
 			LIBCFS_FREE(name, args->lstio_dbg_nmlen + 1);
 
 			return -EFAULT;
@@ -212,9 +211,8 @@ lst_group_add_ioctl(lstio_group_add_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_grp_namep,
-			       args->lstio_grp_nmlen)) {
+	if (copy_from_user(name, args->lstio_grp_namep,
+			   args->lstio_grp_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_grp_nmlen);
 		return -EFAULT;
 	}
@@ -246,9 +244,8 @@ lst_group_del_ioctl(lstio_group_del_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_grp_namep,
-			       args->lstio_grp_nmlen)) {
+	if (copy_from_user(name, args->lstio_grp_namep,
+			   args->lstio_grp_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
 		return -EFAULT;
 	}
@@ -344,7 +341,7 @@ lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_grp_namep,
-			       args->lstio_grp_nmlen)) {
+			   args->lstio_grp_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
 
 		return -EFAULT;
@@ -408,9 +405,9 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 			return -EINVAL;
 
 		if (copy_from_user(&ndent, args->lstio_grp_ndentp,
-				       sizeof(ndent)) ||
+				   sizeof(ndent)) ||
 		    copy_from_user(&index, args->lstio_grp_idxp,
-				       sizeof(index)))
+				   sizeof(index)))
 			return -EFAULT;
 
 		if (ndent <= 0 || index < 0)
@@ -421,9 +418,8 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_grp_namep,
-			       args->lstio_grp_nmlen)) {
+	if (copy_from_user(name, args->lstio_grp_namep,
+			   args->lstio_grp_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
 		return -EFAULT;
 	}
@@ -464,9 +460,8 @@ lst_batch_add_ioctl(lstio_batch_add_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_bat_namep,
-			       args->lstio_bat_nmlen)) {
+	if (copy_from_user(name, args->lstio_bat_namep,
+			   args->lstio_bat_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 		return -EFAULT;
 	}
@@ -498,9 +493,8 @@ lst_batch_run_ioctl(lstio_batch_run_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_bat_namep,
-			       args->lstio_bat_nmlen)) {
+	if (copy_from_user(name, args->lstio_bat_namep,
+			   args->lstio_bat_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 		return -EFAULT;
 	}
@@ -534,9 +528,8 @@ lst_batch_stop_ioctl(lstio_batch_stop_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_bat_namep,
-			       args->lstio_bat_nmlen)) {
+	if (copy_from_user(name, args->lstio_bat_namep,
+			   args->lstio_bat_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 		return -EFAULT;
 	}
@@ -573,9 +566,8 @@ lst_batch_query_ioctl(lstio_batch_query_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_bat_namep,
-			       args->lstio_bat_nmlen)) {
+	if (copy_from_user(name, args->lstio_bat_namep,
+			   args->lstio_bat_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 		return -EFAULT;
 	}
@@ -636,9 +628,9 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 			return -EINVAL;
 
 		if (copy_from_user(&index, args->lstio_bat_idxp,
-				       sizeof(index)) ||
+				   sizeof(index)) ||
 		    copy_from_user(&ndent, args->lstio_bat_ndentp,
-				       sizeof(ndent)))
+				   sizeof(ndent)))
 			return -EFAULT;
 
 		if (ndent <= 0 || index < 0)
@@ -649,18 +641,17 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 	if (name == NULL)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			       args->lstio_bat_namep, args->lstio_bat_nmlen)) {
+	if (copy_from_user(name, args->lstio_bat_namep,
+			   args->lstio_bat_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 		return -EFAULT;
 	}
 
 	name[args->lstio_bat_nmlen] = 0;
 
-	rc = lstcon_batch_info(name,
-			    args->lstio_bat_entp, args->lstio_bat_server,
-			    args->lstio_bat_testidx, &index, &ndent,
-			    args->lstio_bat_dentsp);
+	rc = lstcon_batch_info(name, args->lstio_bat_entp,
+			       args->lstio_bat_server, args->lstio_bat_testidx,
+			       &index, &ndent, args->lstio_bat_dentsp);
 
 	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 
@@ -701,7 +692,7 @@ lst_stat_query_ioctl(lstio_stat_args_t *args)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_sta_namep,
-			       args->lstio_sta_nmlen)) {
+			   args->lstio_sta_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
 		return -EFAULT;
 	}
@@ -781,21 +772,19 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	    copy_from_user(dst_name, args->lstio_tes_dgrp_name,
 			   args->lstio_tes_dgrp_nmlen) ||
 	    copy_from_user(param, args->lstio_tes_param,
-			      args->lstio_tes_param_len))
+			   args->lstio_tes_param_len))
 		goto out;
 
-	rc = lstcon_test_add(batch_name,
-			    args->lstio_tes_type,
-			    args->lstio_tes_loop,
-			    args->lstio_tes_concur,
-			    args->lstio_tes_dist, args->lstio_tes_span,
-			    src_name, dst_name, param,
-			    args->lstio_tes_param_len,
-			    &ret, args->lstio_tes_resultp);
+	rc = lstcon_test_add(batch_name, args->lstio_tes_type,
+			     args->lstio_tes_loop, args->lstio_tes_concur,
+			     args->lstio_tes_dist, args->lstio_tes_span,
+			     src_name, dst_name, param,
+			     args->lstio_tes_param_len,
+			     &ret, args->lstio_tes_resultp);
 
 	if (ret != 0)
 		rc = (copy_to_user(args->lstio_tes_retp, &ret,
-				       sizeof(ret))) ? -EFAULT : 0;
+				   sizeof(ret))) ? -EFAULT : 0;
 out:
 	if (batch_name != NULL)
 		LIBCFS_FREE(batch_name, args->lstio_tes_bat_nmlen + 1);
@@ -916,7 +905,7 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data)
 	}
 
 	if (copy_to_user(data->ioc_pbuf2, &console_session.ses_trans_stat,
-			     sizeof(lstcon_trans_stat_t)))
+			 sizeof(lstcon_trans_stat_t)))
 		rc = -EFAULT;
 out:
 	mutex_unlock(&console_session.ses_mutex);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 4f09b51..3e702e2 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -125,7 +125,7 @@ lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
 
 	if (!list_empty(&console_session.ses_rpc_freelist)) {
 		crpc = list_entry(console_session.ses_rpc_freelist.next,
-				      lstcon_rpc_t, crp_link);
+				  lstcon_rpc_t, crp_link);
 		list_del_init(&crpc->crp_link);
 	}
 
@@ -174,7 +174,7 @@ lstcon_rpc_put(lstcon_rpc_t *crpc)
 		spin_lock(&console_session.ses_rpc_lock);
 
 		list_add(&crpc->crp_link,
-			     &console_session.ses_rpc_freelist);
+			 &console_session.ses_rpc_freelist);
 
 		spin_unlock(&console_session.ses_rpc_lock);
 	}
@@ -490,7 +490,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 
 	list_for_each_entry(crpc, &trans->tas_rpcs_list, crp_link) {
 		if (copy_from_user(&tmp, next,
-				       sizeof(struct list_head)))
+				   sizeof(struct list_head)))
 			return -EFAULT;
 
 		if (tmp.next == head_up)
@@ -510,13 +510,13 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 		      (unsigned long)console_session.ses_id.ses_stamp);
 		jiffies_to_timeval(dur, &tv);
 
-		if (copy_to_user(&ent->rpe_peer,
-				     &nd->nd_id, sizeof(lnet_process_id_t)) ||
+		if (copy_to_user(&ent->rpe_peer, &nd->nd_id,
+				 sizeof(lnet_process_id_t)) ||
 		    copy_to_user(&ent->rpe_stamp, &tv, sizeof(tv)) ||
-		    copy_to_user(&ent->rpe_state,
-				     &nd->nd_state, sizeof(nd->nd_state)) ||
+		    copy_to_user(&ent->rpe_state, &nd->nd_state,
+				 sizeof(nd->nd_state)) ||
 		    copy_to_user(&ent->rpe_rpc_errno, &error,
-				     sizeof(error)))
+				 sizeof(error)))
 			return -EFAULT;
 
 		if (error != 0)
@@ -525,10 +525,9 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 		/* RPC is done */
 		rep = (srpc_generic_reply_t *)&msg->msg_body.reply;
 
-		if (copy_to_user(&ent->rpe_sid,
-				     &rep->sid, sizeof(lst_sid_t)) ||
-		    copy_to_user(&ent->rpe_fwk_errno,
-				     &rep->status, sizeof(rep->status)))
+		if (copy_to_user(&ent->rpe_sid, &rep->sid, sizeof(lst_sid_t)) ||
+		    copy_to_user(&ent->rpe_fwk_errno, &rep->status,
+				 sizeof(rep->status)))
 			return -EFAULT;
 
 		if (readent == NULL)
@@ -952,8 +951,8 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 
 	if (reply->msg_ses_feats != trans->tas_features) {
 		CNETERR("Framework features %x from %s is different with features on this transaction: %x\n",
-			 reply->msg_ses_feats, libcfs_nid2str(nd->nd_id.nid),
-			 trans->tas_features);
+			reply->msg_ses_feats, libcfs_nid2str(nd->nd_id.nid),
+			trans->tas_features);
 		status = mksn_rep->mksn_status = EPROTO;
 	}
 
@@ -1116,7 +1115,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 
 		if (rc < 0) {
 			CDEBUG(D_NET, "Condition error while creating RPC for transaction %d: %d\n",
-					transop, rc);
+			       transop, rc);
 			break;
 		}
 
@@ -1342,7 +1341,7 @@ lstcon_rpc_cleanup_wait(void)
 	while (!list_empty(&console_session.ses_trans_list)) {
 		list_for_each(pacer, &console_session.ses_trans_list) {
 			trans = list_entry(pacer, lstcon_rpc_trans_t,
-					       tas_link);
+					   tas_link);
 
 			CDEBUG(D_NET, "Session closed, wakeup transaction %s\n",
 			       lstcon_rpc_trans_name(trans->tas_opc));
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 1cc7038..64d58d1 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -329,7 +329,7 @@ lstcon_group_move(lstcon_group_t *old, lstcon_group_t *new)
 
 	while (!list_empty(&old->grp_ndl_list)) {
 		ndl = list_entry(old->grp_ndl_list.next,
-				     lstcon_ndlink_t, ndl_link);
+				 lstcon_ndlink_t, ndl_link);
 		lstcon_group_ndlink_move(old, new, ndl);
 	}
 }
@@ -378,9 +378,9 @@ lstcon_sesrpc_readent(int transop, srpc_msg_t *msg,
 		rep = &msg->msg_body.dbg_reply;
 
 		if (copy_to_user(&ent_up->rpe_priv[0],
-				     &rep->dbg_timeout, sizeof(int)) ||
+				 &rep->dbg_timeout, sizeof(int)) ||
 		    copy_to_user(&ent_up->rpe_payload[0],
-				     &rep->dbg_name, LST_NAME_SIZE))
+				 &rep->dbg_name, LST_NAME_SIZE))
 			return -EFAULT;
 
 		return 0;
@@ -757,9 +757,9 @@ lstcon_nodes_getent(struct list_head *head, int *index_p,
 
 		nd = ndl->ndl_node;
 		if (copy_to_user(&dents_up[count].nde_id,
-				     &nd->nd_id, sizeof(nd->nd_id)) ||
+				 &nd->nd_id, sizeof(nd->nd_id)) ||
 		    copy_to_user(&dents_up[count].nde_state,
-				     &nd->nd_state, sizeof(nd->nd_state)))
+				 &nd->nd_state, sizeof(nd->nd_state)))
 			return -EFAULT;
 
 		count++;
@@ -812,7 +812,7 @@ lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 		LST_NODE_STATE_COUNTER(ndl->ndl_node, gentp);
 
 	rc = copy_to_user(gents_p, gentp,
-			      sizeof(lstcon_ndlist_ent_t)) ? -EFAULT : 0;
+			  sizeof(lstcon_ndlist_ent_t)) ? -EFAULT : 0;
 
 	LIBCFS_FREE(gentp, sizeof(lstcon_ndlist_ent_t));
 
@@ -980,7 +980,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		LST_NODE_STATE_COUNTER(ndl->ndl_node, &entp->tbe_srv_nle);
 
 	rc = copy_to_user(ent_up, entp,
-			      sizeof(lstcon_test_batch_ent_t)) ? -EFAULT : 0;
+			  sizeof(lstcon_test_batch_ent_t)) ? -EFAULT : 0;
 
 	LIBCFS_FREE(entp, sizeof(lstcon_test_batch_ent_t));
 
@@ -1088,7 +1088,7 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 
 	while (!list_empty(&bat->bat_test_list)) {
 		test = list_entry(bat->bat_test_list.next,
-				      lstcon_test_t, tes_link);
+				  lstcon_test_t, tes_link);
 		LASSERT(list_empty(&test->tes_trans_list));
 
 		list_del(&test->tes_link);
@@ -1104,7 +1104,7 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 
 	while (!list_empty(&bat->bat_cli_list)) {
 		ndl = list_entry(bat->bat_cli_list.next,
-				     lstcon_ndlink_t, ndl_link);
+				 lstcon_ndlink_t, ndl_link);
 		list_del_init(&ndl->ndl_link);
 
 		lstcon_ndlink_release(ndl);
@@ -1112,7 +1112,7 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 
 	while (!list_empty(&bat->bat_srv_list)) {
 		ndl = list_entry(bat->bat_srv_list.next,
-				     lstcon_ndlink_t, ndl_link);
+				 lstcon_ndlink_t, ndl_link);
 		list_del_init(&ndl->ndl_link);
 
 		lstcon_ndlink_release(ndl);
@@ -1379,11 +1379,11 @@ lstcon_tsbrpc_readent(int transop, srpc_msg_t *msg,
 	srpc_batch_reply_t *rep = &msg->msg_body.bat_reply;
 
 	LASSERT(transop == LST_TRANS_TSBCLIQRY ||
-		 transop == LST_TRANS_TSBSRVQRY);
+		transop == LST_TRANS_TSBSRVQRY);
 
 	/* positive errno, framework error code */
-	if (copy_to_user(&ent_up->rpe_priv[0],
-			     &rep->bar_active, sizeof(rep->bar_active)))
+	if (copy_to_user(&ent_up->rpe_priv[0], &rep->bar_active,
+			 sizeof(rep->bar_active)))
 		return -EFAULT;
 
 	return 0;
@@ -1757,7 +1757,7 @@ lstcon_session_new(char *name, int key, unsigned feats,
 	}
 
 	if (copy_to_user(sid_up, &console_session.ses_id,
-			     sizeof(lst_sid_t)) == 0)
+			 sizeof(lst_sid_t)) == 0)
 		return rc;
 
 	lstcon_session_end();
@@ -1786,11 +1786,11 @@ lstcon_session_info(lst_sid_t __user *sid_up, int __user *key_up,
 		LST_NODE_STATE_COUNTER(ndl->ndl_node, entp);
 
 	if (copy_to_user(sid_up, &console_session.ses_id,
-			     sizeof(lst_sid_t)) ||
+			 sizeof(lst_sid_t)) ||
 	    copy_to_user(key_up, &console_session.ses_key,
-			     sizeof(*key_up)) ||
+			 sizeof(*key_up)) ||
 	    copy_to_user(featp, &console_session.ses_features,
-			     sizeof(*featp)) ||
+			 sizeof(*featp)) ||
 	    copy_to_user(ndinfo_up, entp, sizeof(*entp)) ||
 	    copy_to_user(name_up, console_session.ses_name, len))
 		rc = -EFAULT;
@@ -1839,7 +1839,7 @@ lstcon_session_end(void)
 	/* destroy all batches */
 	while (!list_empty(&console_session.ses_bat_list)) {
 		bat = list_entry(console_session.ses_bat_list.next,
-				     lstcon_batch_t, bat_link);
+				 lstcon_batch_t, bat_link);
 
 		lstcon_batch_destroy(bat);
 	}
@@ -1847,7 +1847,7 @@ lstcon_session_end(void)
 	/* destroy all groups */
 	while (!list_empty(&console_session.ses_grp_list)) {
 		grp = list_entry(console_session.ses_grp_list.next,
-				     lstcon_group_t, grp_link);
+				 lstcon_group_t, grp_link);
 		LASSERT(grp->grp_ref == 1);
 
 		lstcon_group_decref(grp);
@@ -1921,7 +1921,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 	}
 
 	if (jreq->join_sid.ses_nid != LNET_NID_ANY &&
-	     !lstcon_session_match(jreq->join_sid)) {
+	    !lstcon_session_match(jreq->join_sid)) {
 		jrep->join_status = EBUSY;
 		goto out;
 	}
@@ -1934,7 +1934,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 		}
 
 		list_add_tail(&grp->grp_link,
-				  &console_session.ses_grp_list);
+			      &console_session.ses_grp_list);
 		lstcon_group_addref(grp);
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 1bf707b..c61d3e7 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -141,7 +141,7 @@ sfw_register_test(srpc_service_t *service, sfw_test_client_ops_t *cliops)
 
 	if (sfw_find_test_case(service->sv_id) != NULL) {
 		CERROR("Failed to register test %s (%d)\n",
-			service->sv_name, service->sv_id);
+		       service->sv_name, service->sv_id);
 		return -EEXIST;
 	}
 
@@ -248,8 +248,8 @@ sfw_session_expired(void *data)
 	LASSERT(sn == sfw_data.fw_session);
 
 	CWARN("Session expired! sid: %s-%llu, name: %s\n",
-	       libcfs_nid2str(sn->sn_id.ses_nid),
-	       sn->sn_id.ses_stamp, &sn->sn_name[0]);
+	      libcfs_nid2str(sn->sn_id.ses_nid),
+	      sn->sn_id.ses_stamp, &sn->sn_name[0]);
 
 	sn->sn_timer_active = 0;
 	sfw_deactivate_session();
@@ -289,11 +289,10 @@ sfw_server_rpc_done(struct srpc_server_rpc *rpc)
 	struct srpc_service *sv	= rpc->srpc_scd->scd_svc;
 	int status = rpc->srpc_status;
 
-	CDEBUG(D_NET,
-		"Incoming framework RPC done: service %s, peer %s, status %s:%d\n",
-		sv->sv_name, libcfs_id2str(rpc->srpc_peer),
-		swi_state2str(rpc->srpc_wi.swi_state),
-		status);
+	CDEBUG(D_NET, "Incoming framework RPC done: service %s, peer %s, status %s:%d\n",
+	       sv->sv_name, libcfs_id2str(rpc->srpc_peer),
+	       swi_state2str(rpc->srpc_wi.swi_state),
+	       status);
 
 	if (rpc->srpc_bulk != NULL)
 		sfw_free_pages(rpc);
@@ -307,11 +306,10 @@ sfw_client_rpc_fini(srpc_client_rpc_t *rpc)
 	LASSERT(list_empty(&rpc->crpc_list));
 	LASSERT(atomic_read(&rpc->crpc_refcount) == 0);
 
-	CDEBUG(D_NET,
-		"Outgoing framework RPC done: service %d, peer %s, status %s:%d:%d\n",
-		rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
-		swi_state2str(rpc->crpc_wi.swi_state),
-		rpc->crpc_aborted, rpc->crpc_status);
+	CDEBUG(D_NET, "Outgoing framework RPC done: service %d, peer %s, status %s:%d:%d\n",
+	       rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
+	       swi_state2str(rpc->crpc_wi.swi_state),
+	       rpc->crpc_aborted, rpc->crpc_status);
 
 	spin_lock(&sfw_data.fw_lock);
 
@@ -627,14 +625,14 @@ sfw_destroy_test_instance(sfw_test_instance_t *tsi)
 
 	while (!list_empty(&tsi->tsi_units)) {
 		tsu = list_entry(tsi->tsi_units.next,
-				     sfw_test_unit_t, tsu_list);
+				 sfw_test_unit_t, tsu_list);
 		list_del(&tsu->tsu_list);
 		LIBCFS_FREE(tsu, sizeof(*tsu));
 	}
 
 	while (!list_empty(&tsi->tsi_free_rpcs)) {
 		rpc = list_entry(tsi->tsi_free_rpcs.next,
-				     srpc_client_rpc_t, crpc_list);
+				 srpc_client_rpc_t, crpc_list);
 		list_del(&rpc->crpc_list);
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
 	}
@@ -655,7 +653,7 @@ sfw_destroy_batch(sfw_batch_t *tsb)
 
 	while (!list_empty(&tsb->bat_tests)) {
 		tsi = list_entry(tsb->bat_tests.next,
-				     sfw_test_instance_t, tsi_list);
+				 sfw_test_instance_t, tsi_list);
 		list_del_init(&tsi->tsi_list);
 		sfw_destroy_test_instance(tsi);
 	}
@@ -674,7 +672,7 @@ sfw_destroy_session(sfw_session_t *sn)
 
 	while (!list_empty(&sn->sn_batches)) {
 		batch = list_entry(sn->sn_batches.next,
-				       sfw_batch_t, bat_list);
+				   sfw_batch_t, bat_list);
 		list_del_init(&batch->bat_list);
 		sfw_destroy_batch(batch);
 	}
@@ -744,7 +742,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 	LIBCFS_ALLOC(tsi, sizeof(*tsi));
 	if (tsi == NULL) {
 		CERROR("Can't allocate test instance for batch: %llu\n",
-			tsb->bat_id.bat_id);
+		       tsb->bat_id.bat_id);
 		return -ENOMEM;
 	}
 
@@ -800,7 +798,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 			if (tsu == NULL) {
 				rc = -ENOMEM;
 				CERROR("Can't allocate tsu for %d\n",
-					tsi->tsi_service);
+				       tsi->tsi_service);
 				goto error;
 			}
 
@@ -918,7 +916,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 	if (!list_empty(&tsi->tsi_free_rpcs)) {
 		/* pick request from buffer */
 		rpc = list_entry(tsi->tsi_free_rpcs.next,
-				     srpc_client_rpc_t, crpc_list);
+				 srpc_client_rpc_t, crpc_list);
 		LASSERT(nblk == rpc->crpc_bulk.bk_niov);
 		list_del_init(&rpc->crpc_list);
 	}
@@ -1152,8 +1150,8 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 	bat = sfw_bid2batch(request->tsr_bid);
 	if (bat == NULL) {
 		CERROR("Dropping RPC (%s) from %s under memory pressure.\n",
-			rpc->srpc_scd->scd_svc->sv_name,
-			libcfs_id2str(rpc->srpc_peer));
+		       rpc->srpc_scd->scd_svc->sv_name,
+		       libcfs_id2str(rpc->srpc_peer));
 		return -ENOMEM;
 	}
 
@@ -1180,10 +1178,10 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 
 	rc = sfw_add_test_instance(bat, rpc);
 	CDEBUG(rc == 0 ? D_NET : D_WARNING,
-		"%s test: sv %d %s, loop %d, concur %d, ndest %d\n",
-		rc == 0 ? "Added" : "Failed to add", request->tsr_service,
-		request->tsr_is_client ? "client" : "server",
-		request->tsr_loop, request->tsr_concur, request->tsr_ndest);
+	       "%s test: sv %d %s, loop %d, concur %d, ndest %d\n",
+	       rc == 0 ? "Added" : "Failed to add", request->tsr_service,
+	       request->tsr_is_client ? "client" : "server",
+	       request->tsr_loop, request->tsr_concur, request->tsr_ndest);
 
 	reply->tsr_status = (rc < 0) ? -rc : rc;
 	return 0;
@@ -1398,7 +1396,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 
 	if (nbulkiov == 0 && !list_empty(&sfw_data.fw_zombie_rpcs)) {
 		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
-				     srpc_client_rpc_t, crpc_list);
+				 srpc_client_rpc_t, crpc_list);
 		list_del(&rpc->crpc_list);
 
 		srpc_init_client_rpc(rpc, peer, service, 0, 0,
@@ -1653,13 +1651,13 @@ sfw_startup(void)
 
 	if (session_timeout < 0) {
 		CERROR("Session timeout must be non-negative: %d\n",
-			session_timeout);
+		       session_timeout);
 		return -EINVAL;
 	}
 
 	if (rpc_timeout < 0) {
 		CERROR("RPC timeout must be non-negative: %d\n",
-			rpc_timeout);
+		       rpc_timeout);
 		return -EINVAL;
 	}
 
@@ -1697,7 +1695,7 @@ sfw_startup(void)
 		LASSERT(rc != -EBUSY);
 		if (rc != 0) {
 			CWARN("Failed to add %s service: %d\n",
-			       sv->sv_name, rc);
+			      sv->sv_name, rc);
 			error = rc;
 		}
 	}
@@ -1717,7 +1715,7 @@ sfw_startup(void)
 		LASSERT(rc != -EBUSY);
 		if (rc != 0) {
 			CWARN("Failed to add %s service: %d\n",
-			       sv->sv_name, rc);
+			      sv->sv_name, rc);
 			error = rc;
 		}
 
@@ -1782,7 +1780,7 @@ sfw_shutdown(void)
 		srpc_client_rpc_t *rpc;
 
 		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
-				     srpc_client_rpc_t, crpc_list);
+				 srpc_client_rpc_t, crpc_list);
 		list_del(&rpc->crpc_list);
 
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
@@ -1798,7 +1796,7 @@ sfw_shutdown(void)
 
 	while (!list_empty(&sfw_data.fw_tests)) {
 		tsc = list_entry(sfw_data.fw_tests.next,
-				     sfw_test_case_t, tsc_list);
+				 sfw_test_case_t, tsc_list);
 
 		srpc_wait_service_shutdown(tsc->tsc_srv_service);
 
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index d426536..1d23a30 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -132,8 +132,8 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 		if (!tsi->tsi_stopping) /* rpc could have been aborted */
 			atomic_inc(&sn->sn_ping_errors);
 		CERROR("Unable to ping %s (%d): %d\n",
-			libcfs_id2str(rpc->crpc_dest),
-			reqst->pnr_seq, rpc->crpc_status);
+		       libcfs_id2str(rpc->crpc_dest),
+		       reqst->pnr_seq, rpc->crpc_status);
 		return;
 	}
 
@@ -147,8 +147,8 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 		rpc->crpc_status = -EBADMSG;
 		atomic_inc(&sn->sn_ping_errors);
 		CERROR("Bad magic %u from %s, %u expected.\n",
-			reply->pnr_magic, libcfs_id2str(rpc->crpc_dest),
-			LST_PING_TEST_MAGIC);
+		       reply->pnr_magic, libcfs_id2str(rpc->crpc_dest),
+		       LST_PING_TEST_MAGIC);
 		return;
 	}
 
@@ -156,8 +156,8 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 		rpc->crpc_status = -EBADMSG;
 		atomic_inc(&sn->sn_ping_errors);
 		CERROR("Bad seq %u from %s, %u expected.\n",
-			reply->pnr_seq, libcfs_id2str(rpc->crpc_dest),
-			reqst->pnr_seq);
+		       reply->pnr_seq, libcfs_id2str(rpc->crpc_dest),
+		       reqst->pnr_seq);
 		return;
 	}
 
@@ -191,7 +191,7 @@ ping_server_handle(struct srpc_server_rpc *rpc)
 
 	if (req->pnr_magic != LST_PING_TEST_MAGIC) {
 		CERROR("Unexpected magic %08x from %s\n",
-			req->pnr_magic, libcfs_id2str(rpc->srpc_peer));
+		       req->pnr_magic, libcfs_id2str(rpc->srpc_peer));
 		return -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 14f2024..6b10216 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -212,9 +212,8 @@ srpc_service_fini(struct srpc_service *svc)
 				break;
 
 			while (!list_empty(q)) {
-				buf = list_entry(q->next,
-						     struct srpc_buffer,
-						     buf_list);
+				buf = list_entry(q->next, struct srpc_buffer,
+						 buf_list);
 				list_del(&buf->buf_list);
 				LIBCFS_FREE(buf, sizeof(*buf));
 			}
@@ -224,8 +223,8 @@ srpc_service_fini(struct srpc_service *svc)
 
 		while (!list_empty(&scd->scd_rpc_free)) {
 			rpc = list_entry(scd->scd_rpc_free.next,
-					     struct srpc_server_rpc,
-					     srpc_list);
+					 struct srpc_server_rpc,
+					 srpc_list);
 			list_del(&rpc->srpc_list);
 			LIBCFS_FREE(rpc, sizeof(*rpc));
 		}
@@ -390,9 +389,8 @@ srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 		return -ENOMEM;
 	}
 
-	CDEBUG(D_NET,
-		"Posted passive RDMA: peer %s, portal %d, matchbits %#llx\n",
-		libcfs_id2str(peer), portal, matchbits);
+	CDEBUG(D_NET, "Posted passive RDMA: peer %s, portal %d, matchbits %#llx\n",
+	       libcfs_id2str(peer), portal, matchbits);
 	return 0;
 }
 
@@ -434,8 +432,8 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 
 	if (rc != 0) {
 		CERROR("LNet%s(%s, %d, %lld) failed: %d\n",
-			((options & LNET_MD_OP_PUT) != 0) ? "Put" : "Get",
-			libcfs_id2str(peer), portal, matchbits, rc);
+		       ((options & LNET_MD_OP_PUT) != 0) ? "Put" : "Get",
+		       libcfs_id2str(peer), portal, matchbits, rc);
 
 		/*
 		 * The forthcoming unlink event will complete this operation
@@ -444,9 +442,8 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 		rc = LNetMDUnlink(*mdh);
 		LASSERT(rc == 0);
 	} else {
-		CDEBUG(D_NET,
-			"Posted active RDMA: peer %s, portal %u, matchbits %#llx\n",
-			libcfs_id2str(peer), portal, matchbits);
+		CDEBUG(D_NET, "Posted active RDMA: peer %s, portal %u, matchbits %#llx\n",
+		       libcfs_id2str(peer), portal, matchbits);
 	}
 	return 0;
 }
@@ -682,7 +679,7 @@ srpc_finish_service(struct srpc_service *sv)
 		}
 
 		rpc = list_entry(scd->scd_rpc_active.next,
-				     struct srpc_server_rpc, srpc_list);
+				 struct srpc_server_rpc, srpc_list);
 		CNETERR("Active RPC %p on shutdown: sv %s, peer %s, wi %s scheduled %d running %d, ev fired %d type %d status %d lnet %d\n",
 			rpc, sv->sv_name, libcfs_id2str(rpc->srpc_peer),
 			swi_state2str(rpc->srpc_wi.swi_state),
@@ -914,9 +911,9 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	rpc->srpc_status = status;
 
 	CDEBUG_LIMIT(status == 0 ? D_NET : D_NETERROR,
-		"Server RPC %p done: service %s, peer %s, status %s:%d\n",
-		rpc, sv->sv_name, libcfs_id2str(rpc->srpc_peer),
-		swi_state2str(rpc->srpc_wi.swi_state), status);
+		     "Server RPC %p done: service %s, peer %s, status %s:%d\n",
+		     rpc, sv->sv_name, libcfs_id2str(rpc->srpc_peer),
+		     swi_state2str(rpc->srpc_wi.swi_state), status);
 
 	if (status != 0) {
 		spin_lock(&srpc_data.rpc_glock);
@@ -952,7 +949,7 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 
 	if (!sv->sv_shuttingdown && !list_empty(&scd->scd_buf_blocked)) {
 		buffer = list_entry(scd->scd_buf_blocked.next,
-					srpc_buffer_t, buf_list);
+				    srpc_buffer_t, buf_list);
 		list_del(&buffer->buf_list);
 
 		srpc_init_server_rpc(rpc, scd, buffer);
@@ -1085,8 +1082,8 @@ srpc_client_rpc_expired(void *data)
 	srpc_client_rpc_t *rpc = data;
 
 	CWARN("Client RPC expired: service %d, peer %s, timeout %d.\n",
-	       rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
-	       rpc->crpc_timeout);
+	      rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
+	      rpc->crpc_timeout);
 
 	spin_lock(&rpc->crpc_lock);
 
@@ -1159,9 +1156,9 @@ srpc_client_rpc_done(srpc_client_rpc_t *rpc, int status)
 	srpc_del_client_rpc_timer(rpc);
 
 	CDEBUG_LIMIT((status == 0) ? D_NET : D_NETERROR,
-		"Client RPC done: service %d, peer %s, status %s:%d:%d\n",
-		rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
-		swi_state2str(wi->swi_state), rpc->crpc_aborted, status);
+		     "Client RPC done: service %d, peer %s, status %s:%d:%d\n",
+		     rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
+		     swi_state2str(wi->swi_state), rpc->crpc_aborted, status);
 
 	/*
 	 * No one can schedule me now since:
@@ -1317,9 +1314,9 @@ abort:
 
 srpc_client_rpc_t *
 srpc_create_client_rpc(lnet_process_id_t peer, int service,
-			int nbulkiov, int bulklen,
-			void (*rpc_done)(srpc_client_rpc_t *),
-			void (*rpc_fini)(srpc_client_rpc_t *), void *priv)
+		       int nbulkiov, int bulklen,
+		       void (*rpc_done)(srpc_client_rpc_t *),
+		       void (*rpc_fini)(srpc_client_rpc_t *), void *priv)
 {
 	srpc_client_rpc_t *rpc;
 
@@ -1343,10 +1340,9 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 	    rpc->crpc_closed)    /* callback imminent */
 		return;
 
-	CDEBUG(D_NET,
-		"Aborting RPC: service %d, peer %s, state %s, why %d\n",
-		rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
-		swi_state2str(rpc->crpc_wi.swi_state), why);
+	CDEBUG(D_NET, "Aborting RPC: service %d, peer %s, state %s, why %d\n",
+	       rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
+	       swi_state2str(rpc->crpc_wi.swi_state), why);
 
 	rpc->crpc_aborted = 1;
 	rpc->crpc_status  = why;
@@ -1362,8 +1358,8 @@ srpc_post_rpc(srpc_client_rpc_t *rpc)
 	LASSERT(srpc_data.rpc_state == SRPC_STATE_RUNNING);
 
 	CDEBUG(D_NET, "Posting RPC: peer %s, service %d, timeout %d\n",
-		libcfs_id2str(rpc->crpc_dest), rpc->crpc_service,
-		rpc->crpc_timeout);
+	       libcfs_id2str(rpc->crpc_dest), rpc->crpc_service,
+	       rpc->crpc_timeout);
 
 	srpc_add_client_rpc_timer(rpc);
 	swi_schedule_workitem(&rpc->crpc_wi);
@@ -1485,9 +1481,9 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 
 		LASSERT(ev->unlinked);
 		LASSERT(ev->type == LNET_EVENT_PUT ||
-			 ev->type == LNET_EVENT_UNLINK);
+			ev->type == LNET_EVENT_UNLINK);
 		LASSERT(ev->type != LNET_EVENT_UNLINK ||
-			 sv->sv_shuttingdown);
+			sv->sv_shuttingdown);
 
 		buffer = container_of(ev->md.start, srpc_buffer_t, buf_msg);
 		buffer->buf_peer = ev->initiator;
@@ -1544,17 +1540,17 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 
 		if (!list_empty(&scd->scd_rpc_free)) {
 			srpc = list_entry(scd->scd_rpc_free.next,
-					      struct srpc_server_rpc,
-					      srpc_list);
+					  struct srpc_server_rpc,
+					  srpc_list);
 			list_del(&srpc->srpc_list);
 
 			srpc_init_server_rpc(srpc, scd, buffer);
 			list_add_tail(&srpc->srpc_list,
-					  &scd->scd_rpc_active);
+				      &scd->scd_rpc_active);
 			swi_schedule_workitem(&srpc->srpc_wi);
 		} else {
 			list_add_tail(&buffer->buf_list,
-					  &scd->scd_buf_blocked);
+				      &scd->scd_buf_blocked);
 		}
 
 		spin_unlock(&scd->scd_lock);
@@ -1566,8 +1562,8 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 
 	case SRPC_BULK_GET_RPLD:
 		LASSERT(ev->type == LNET_EVENT_SEND ||
-			 ev->type == LNET_EVENT_REPLY ||
-			 ev->type == LNET_EVENT_UNLINK);
+			ev->type == LNET_EVENT_REPLY ||
+			ev->type == LNET_EVENT_UNLINK);
 
 		if (!ev->unlinked)
 			break; /* wait for final event */
@@ -1669,8 +1665,8 @@ srpc_shutdown(void)
 			srpc_service_t *sv = srpc_data.rpc_services[i];
 
 			LASSERTF(sv == NULL,
-				  "service not empty: id %d, name %s\n",
-				  i, sv->sv_name);
+				 "service not empty: id %d, name %s\n",
+				 i, sv->sv_name);
 		}
 
 		spin_unlock(&srpc_data.rpc_glock);
-- 
1.7.1
