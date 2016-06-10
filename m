From: James Simmons <jsimmons@infradead.org>
Date: Fri, 10 Jun 2016 16:13:39 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: remove typedefs
Message-ID: <1465589619-22362-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove all remaining typedefs in o2iblnd driver.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  339 +++++++++---------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  299 ++++++++--------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  368 ++++++++++----------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    2 +-
 4 files changed, 504 insertions(+), 504 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 4bb32f1..3f3a9c1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -44,7 +44,7 @@
 
 static lnd_t the_o2iblnd;
 
-kib_data_t kiblnd_data;
+struct kib_data kiblnd_data;
 
 static __u32 kiblnd_cksum(void *ptr, int nob)
 {
@@ -98,40 +98,40 @@ static char *kiblnd_msgtype2str(int type)
 
 static int kiblnd_msgtype2size(int type)
 {
-	const int hdr_size = offsetof(kib_msg_t, ibm_u);
+	const int hdr_size = offsetof(struct kib_msg, ibm_u);
 
 	switch (type) {
 	case IBLND_MSG_CONNREQ:
 	case IBLND_MSG_CONNACK:
-		return hdr_size + sizeof(kib_connparams_t);
+		return hdr_size + sizeof(struct kib_connparams);
 
 	case IBLND_MSG_NOOP:
 		return hdr_size;
 
 	case IBLND_MSG_IMMEDIATE:
-		return offsetof(kib_msg_t, ibm_u.immediate.ibim_payload[0]);
+		return offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[0]);
 
 	case IBLND_MSG_PUT_REQ:
-		return hdr_size + sizeof(kib_putreq_msg_t);
+		return hdr_size + sizeof(struct kib_putreq_msg);
 
 	case IBLND_MSG_PUT_ACK:
-		return hdr_size + sizeof(kib_putack_msg_t);
+		return hdr_size + sizeof(struct kib_putack_msg);
 
 	case IBLND_MSG_GET_REQ:
-		return hdr_size + sizeof(kib_get_msg_t);
+		return hdr_size + sizeof(struct kib_get_msg);
 
 	case IBLND_MSG_PUT_NAK:
 	case IBLND_MSG_PUT_DONE:
 	case IBLND_MSG_GET_DONE:
-		return hdr_size + sizeof(kib_completion_msg_t);
+		return hdr_size + sizeof(struct kib_completion_msg);
 	default:
 		return -1;
 	}
 }
 
-static int kiblnd_unpack_rd(kib_msg_t *msg, int flip)
+static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 {
-	kib_rdma_desc_t *rd;
+	struct kib_rdma_desc *rd;
 	int nob;
 	int n;
 	int i;
@@ -156,7 +156,7 @@ static int kiblnd_unpack_rd(kib_msg_t *msg, int flip)
 		return 1;
 	}
 
-	nob = offsetof(kib_msg_t, ibm_u) +
+	nob = offsetof(struct kib_msg, ibm_u) +
 	      kiblnd_rd_msg_size(rd, msg->ibm_type, n);
 
 	if (msg->ibm_nob < nob) {
@@ -176,10 +176,10 @@ static int kiblnd_unpack_rd(kib_msg_t *msg, int flip)
 	return 0;
 }
 
-void kiblnd_pack_msg(lnet_ni_t *ni, kib_msg_t *msg, int version,
+void kiblnd_pack_msg(lnet_ni_t *ni, struct kib_msg *msg, int version,
 		     int credits, lnet_nid_t dstnid, __u64 dststamp)
 {
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 
 	/*
 	 * CAVEAT EMPTOR! all message fields not set here should have been
@@ -202,9 +202,9 @@ void kiblnd_pack_msg(lnet_ni_t *ni, kib_msg_t *msg, int version,
 	}
 }
 
-int kiblnd_unpack_msg(kib_msg_t *msg, int nob)
+int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 {
-	const int hdr_size = offsetof(kib_msg_t, ibm_u);
+	const int hdr_size = offsetof(struct kib_msg, ibm_u);
 	__u32 msg_cksum;
 	__u16 version;
 	int msg_nob;
@@ -315,10 +315,10 @@ int kiblnd_unpack_msg(kib_msg_t *msg, int nob)
 	return 0;
 }
 
-int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
+int kiblnd_create_peer(lnet_ni_t *ni, struct kib_peer **peerp, lnet_nid_t nid)
 {
-	kib_peer_t *peer;
-	kib_net_t *net = ni->ni_data;
+	struct kib_peer *peer;
+	struct kib_net *net = ni->ni_data;
 	int cpt = lnet_cpt_of_nid(nid);
 	unsigned long flags;
 
@@ -357,9 +357,9 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 	return 0;
 }
 
-void kiblnd_destroy_peer(kib_peer_t *peer)
+void kiblnd_destroy_peer(struct kib_peer *peer)
 {
-	kib_net_t *net = peer->ibp_ni->ni_data;
+	struct kib_net *net = peer->ibp_ni->ni_data;
 
 	LASSERT(net);
 	LASSERT(!atomic_read(&peer->ibp_refcount));
@@ -378,7 +378,7 @@ void kiblnd_destroy_peer(kib_peer_t *peer)
 	atomic_dec(&net->ibn_npeers);
 }
 
-kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid)
+struct kib_peer *kiblnd_find_peer_locked(lnet_nid_t nid)
 {
 	/*
 	 * the caller is responsible for accounting the additional reference
@@ -386,10 +386,10 @@ kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid)
 	 */
 	struct list_head *peer_list = kiblnd_nid2peerlist(nid);
 	struct list_head *tmp;
-	kib_peer_t *peer;
+	struct kib_peer *peer;
 
 	list_for_each(tmp, peer_list) {
-		peer = list_entry(tmp, kib_peer_t, ibp_list);
+		peer = list_entry(tmp, struct kib_peer, ibp_list);
 		LASSERT(!kiblnd_peer_idle(peer));
 
 		if (peer->ibp_nid != nid)
@@ -404,7 +404,7 @@ kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid)
 	return NULL;
 }
 
-void kiblnd_unlink_peer_locked(kib_peer_t *peer)
+void kiblnd_unlink_peer_locked(struct kib_peer *peer)
 {
 	LASSERT(list_empty(&peer->ibp_conns));
 
@@ -417,7 +417,7 @@ void kiblnd_unlink_peer_locked(kib_peer_t *peer)
 static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
 				lnet_nid_t *nidp, int *count)
 {
-	kib_peer_t *peer;
+	struct kib_peer *peer;
 	struct list_head *ptmp;
 	int i;
 	unsigned long flags;
@@ -426,7 +426,7 @@ static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
 
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
 		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
-			peer = list_entry(ptmp, kib_peer_t, ibp_list);
+			peer = list_entry(ptmp, struct kib_peer, ibp_list);
 			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
@@ -448,17 +448,17 @@ static int kiblnd_get_peer_info(lnet_ni_t *ni, int index,
 	return -ENOENT;
 }
 
-static void kiblnd_del_peer_locked(kib_peer_t *peer)
+static void kiblnd_del_peer_locked(struct kib_peer *peer)
 {
 	struct list_head *ctmp;
 	struct list_head *cnxt;
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 
 	if (list_empty(&peer->ibp_conns)) {
 		kiblnd_unlink_peer_locked(peer);
 	} else {
 		list_for_each_safe(ctmp, cnxt, &peer->ibp_conns) {
-			conn = list_entry(ctmp, kib_conn_t, ibc_list);
+			conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 			kiblnd_close_conn_locked(conn, 0);
 		}
@@ -475,7 +475,7 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 	LIST_HEAD(zombies);
 	struct list_head *ptmp;
 	struct list_head *pnxt;
-	kib_peer_t *peer;
+	struct kib_peer *peer;
 	int lo;
 	int hi;
 	int i;
@@ -494,7 +494,7 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
-			peer = list_entry(ptmp, kib_peer_t, ibp_list);
+			peer = list_entry(ptmp, struct kib_peer, ibp_list);
 			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
@@ -522,11 +522,11 @@ static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
 	return rc;
 }
 
-static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
+static struct kib_conn *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 {
-	kib_peer_t *peer;
+	struct kib_peer *peer;
 	struct list_head *ptmp;
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 	struct list_head *ctmp;
 	int i;
 	unsigned long flags;
@@ -535,7 +535,7 @@ static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
 		list_for_each(ptmp, &kiblnd_data.kib_peers[i]) {
-			peer = list_entry(ptmp, kib_peer_t, ibp_list);
+			peer = list_entry(ptmp, struct kib_peer, ibp_list);
 			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
@@ -545,7 +545,7 @@ static kib_conn_t *kiblnd_get_conn_by_idx(lnet_ni_t *ni, int index)
 				if (index-- > 0)
 					continue;
 
-				conn = list_entry(ctmp, kib_conn_t,
+				conn = list_entry(ctmp, struct kib_conn,
 						  ibc_list);
 				kiblnd_conn_addref(conn);
 				read_unlock_irqrestore(
@@ -594,7 +594,7 @@ static void kiblnd_setup_mtu_locked(struct rdma_cm_id *cmid)
 		cmid->route.path_rec->mtu = mtu;
 }
 
-static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
+static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 {
 	cpumask_t *mask;
 	int vectors;
@@ -621,7 +621,7 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 	return 1;
 }
 
-kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
+struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cmid,
 			       int state, int version)
 {
 	/*
@@ -634,12 +634,12 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	 * its ref on 'cmid').
 	 */
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	kib_net_t *net = peer->ibp_ni->ni_data;
-	kib_dev_t *dev;
+	struct kib_net *net = peer->ibp_ni->ni_data;
+	struct kib_dev *dev;
 	struct ib_qp_init_attr *init_qp_attr;
 	struct kib_sched_info *sched;
 	struct ib_cq_init_attr cq_attr = {};
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 	struct ib_cq *cq;
 	unsigned long flags;
 	int cpt;
@@ -723,7 +723,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	write_unlock_irqrestore(glock, flags);
 
 	LIBCFS_CPT_ALLOC(conn->ibc_rxs, lnet_cpt_table(), cpt,
-			 IBLND_RX_MSGS(conn) * sizeof(kib_rx_t));
+			 IBLND_RX_MSGS(conn) * sizeof(struct kib_rx));
 	if (!conn->ibc_rxs) {
 		CERROR("Cannot allocate RX buffers\n");
 		goto failed_2;
@@ -833,10 +833,10 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	return NULL;
 }
 
-void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
+void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
 {
 	struct rdma_cm_id *cmid = conn->ibc_cmid;
-	kib_peer_t *peer = conn->ibc_peer;
+	struct kib_peer *peer = conn->ibc_peer;
 	int rc;
 
 	LASSERT(!in_interrupt());
@@ -879,7 +879,7 @@ void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
 
 	if (conn->ibc_rxs) {
 		LIBCFS_FREE(conn->ibc_rxs,
-			    IBLND_RX_MSGS(conn) * sizeof(kib_rx_t));
+			    IBLND_RX_MSGS(conn) * sizeof(struct kib_rx));
 	}
 
 	if (conn->ibc_connvars)
@@ -890,7 +890,7 @@ void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
 
 	/* See CAVEAT EMPTOR above in kiblnd_create_conn */
 	if (conn->ibc_state != IBLND_CONN_INIT) {
-		kib_net_t *net = peer->ibp_ni->ni_data;
+		struct kib_net *net = peer->ibp_ni->ni_data;
 
 		kiblnd_peer_decref(peer);
 		rdma_destroy_id(cmid);
@@ -900,15 +900,15 @@ void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn)
 	LIBCFS_FREE(conn, sizeof(*conn));
 }
 
-int kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why)
+int kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why)
 {
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 	int count = 0;
 
 	list_for_each_safe(ctmp, cnxt, &peer->ibp_conns) {
-		conn = list_entry(ctmp, kib_conn_t, ibc_list);
+		conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 		CDEBUG(D_NET, "Closing conn -> %s, version: %x, reason: %d\n",
 		       libcfs_nid2str(peer->ibp_nid),
@@ -921,16 +921,16 @@ int kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why)
 	return count;
 }
 
-int kiblnd_close_stale_conns_locked(kib_peer_t *peer,
+int kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 				    int version, __u64 incarnation)
 {
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 	struct list_head *ctmp;
 	struct list_head *cnxt;
 	int count = 0;
 
 	list_for_each_safe(ctmp, cnxt, &peer->ibp_conns) {
-		conn = list_entry(ctmp, kib_conn_t, ibc_list);
+		conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 		if (conn->ibc_version     == version &&
 		    conn->ibc_incarnation == incarnation)
@@ -951,7 +951,7 @@ int kiblnd_close_stale_conns_locked(kib_peer_t *peer,
 
 static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 {
-	kib_peer_t *peer;
+	struct kib_peer *peer;
 	struct list_head *ptmp;
 	struct list_head *pnxt;
 	int lo;
@@ -972,7 +972,7 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 
 	for (i = lo; i <= hi; i++) {
 		list_for_each_safe(ptmp, pnxt, &kiblnd_data.kib_peers[i]) {
-			peer = list_entry(ptmp, kib_peer_t, ibp_list);
+			peer = list_entry(ptmp, struct kib_peer, ibp_list);
 			LASSERT(!kiblnd_peer_idle(peer));
 
 			if (peer->ibp_ni != ni)
@@ -1016,7 +1016,7 @@ static int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 		break;
 	}
 	case IOC_LIBCFS_GET_CONN: {
-		kib_conn_t *conn;
+		struct kib_conn *conn;
 
 		rc = 0;
 		conn = kiblnd_get_conn_by_idx(ni, data->ioc_count);
@@ -1052,7 +1052,7 @@ static void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	unsigned long last_alive = 0;
 	unsigned long now = cfs_time_current();
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	kib_peer_t *peer;
+	struct kib_peer *peer;
 	unsigned long flags;
 
 	read_lock_irqsave(glock, flags);
@@ -1078,7 +1078,7 @@ static void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	       last_alive ? cfs_duration_sec(now - last_alive) : -1);
 }
 
-static void kiblnd_free_pages(kib_pages_t *p)
+static void kiblnd_free_pages(struct kib_pages *p)
 {
 	int npages = p->ibp_npages;
 	int i;
@@ -1088,22 +1088,22 @@ static void kiblnd_free_pages(kib_pages_t *p)
 			__free_page(p->ibp_pages[i]);
 	}
 
-	LIBCFS_FREE(p, offsetof(kib_pages_t, ibp_pages[npages]));
+	LIBCFS_FREE(p, offsetof(struct kib_pages, ibp_pages[npages]));
 }
 
-int kiblnd_alloc_pages(kib_pages_t **pp, int cpt, int npages)
+int kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages)
 {
-	kib_pages_t *p;
+	struct kib_pages *p;
 	int i;
 
 	LIBCFS_CPT_ALLOC(p, lnet_cpt_table(), cpt,
-			 offsetof(kib_pages_t, ibp_pages[npages]));
+			 offsetof(struct kib_pages, ibp_pages[npages]));
 	if (!p) {
 		CERROR("Can't allocate descriptor for %d pages\n", npages);
 		return -ENOMEM;
 	}
 
-	memset(p, 0, offsetof(kib_pages_t, ibp_pages[npages]));
+	memset(p, 0, offsetof(struct kib_pages, ibp_pages[npages]));
 	p->ibp_npages = npages;
 
 	for (i = 0; i < npages; i++) {
@@ -1121,9 +1121,9 @@ int kiblnd_alloc_pages(kib_pages_t **pp, int cpt, int npages)
 	return 0;
 }
 
-void kiblnd_unmap_rx_descs(kib_conn_t *conn)
+void kiblnd_unmap_rx_descs(struct kib_conn *conn)
 {
-	kib_rx_t *rx;
+	struct kib_rx *rx;
 	int i;
 
 	LASSERT(conn->ibc_rxs);
@@ -1145,9 +1145,9 @@ void kiblnd_unmap_rx_descs(kib_conn_t *conn)
 	conn->ibc_rx_pages = NULL;
 }
 
-void kiblnd_map_rx_descs(kib_conn_t *conn)
+void kiblnd_map_rx_descs(struct kib_conn *conn)
 {
-	kib_rx_t *rx;
+	struct kib_rx *rx;
 	struct page *pg;
 	int pg_off;
 	int ipg;
@@ -1158,7 +1158,7 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 		rx = &conn->ibc_rxs[i];
 
 		rx->rx_conn = conn;
-		rx->rx_msg = (kib_msg_t *)(((char *)page_address(pg)) + pg_off);
+		rx->rx_msg = (struct kib_msg *)(((char *)page_address(pg)) + pg_off);
 
 		rx->rx_msgaddr = kiblnd_dma_map_single(conn->ibc_hdev->ibh_ibdev,
 						       rx->rx_msg,
@@ -1183,10 +1183,10 @@ void kiblnd_map_rx_descs(kib_conn_t *conn)
 	}
 }
 
-static void kiblnd_unmap_tx_pool(kib_tx_pool_t *tpo)
+static void kiblnd_unmap_tx_pool(struct kib_tx_pool *tpo)
 {
-	kib_hca_dev_t *hdev = tpo->tpo_hdev;
-	kib_tx_t *tx;
+	struct kib_hca_dev *hdev = tpo->tpo_hdev;
+	struct kib_tx *tx;
 	int i;
 
 	LASSERT(!tpo->tpo_pool.po_allocated);
@@ -1206,9 +1206,9 @@ static void kiblnd_unmap_tx_pool(kib_tx_pool_t *tpo)
 	tpo->tpo_hdev = NULL;
 }
 
-static kib_hca_dev_t *kiblnd_current_hdev(kib_dev_t *dev)
+static struct kib_hca_dev *kiblnd_current_hdev(struct kib_dev *dev)
 {
-	kib_hca_dev_t *hdev;
+	struct kib_hca_dev *hdev;
 	unsigned long flags;
 	int i = 0;
 
@@ -1232,14 +1232,14 @@ static kib_hca_dev_t *kiblnd_current_hdev(kib_dev_t *dev)
 	return hdev;
 }
 
-static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
+static void kiblnd_map_tx_pool(struct kib_tx_pool *tpo)
 {
-	kib_pages_t *txpgs = tpo->tpo_tx_pages;
-	kib_pool_t *pool = &tpo->tpo_pool;
-	kib_net_t *net = pool->po_owner->ps_net;
-	kib_dev_t *dev;
+	struct kib_pages *txpgs = tpo->tpo_tx_pages;
+	struct kib_pool *pool = &tpo->tpo_pool;
+	struct kib_net *net = pool->po_owner->ps_net;
+	struct kib_dev *dev;
 	struct page *page;
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 	int page_offset;
 	int ipage;
 	int i;
@@ -1260,7 +1260,7 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 		page = txpgs->ibp_pages[ipage];
 		tx = &tpo->tpo_tx_descs[i];
 
-		tx->tx_msg = (kib_msg_t *)(((char *)page_address(page)) +
+		tx->tx_msg = (struct kib_msg *)(((char *)page_address(page)) +
 					   page_offset);
 
 		tx->tx_msgaddr = kiblnd_dma_map_single(
@@ -1283,11 +1283,11 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 	}
 }
 
-struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, kib_rdma_desc_t *rd,
+struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, struct kib_rdma_desc *rd,
 				    int negotiated_nfrags)
 {
-	kib_net_t *net = ni->ni_data;
-	kib_hca_dev_t *hdev = net->ibn_dev->ibd_hdev;
+	struct kib_net *net = ni->ni_data;
+	struct kib_hca_dev *hdev = net->ibn_dev->ibd_hdev;
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	__u16 nfrags;
 	int mod;
@@ -1304,7 +1304,7 @@ struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, kib_rdma_desc_t *rd,
 	return hdev->ibh_mrs;
 }
 
-static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *fpo)
+static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 {
 	LASSERT(!fpo->fpo_map_count);
 
@@ -1335,7 +1335,7 @@ static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *fpo)
 
 static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 {
-	kib_fmr_pool_t *fpo, *tmp;
+	struct kib_fmr_pool *fpo, *tmp;
 
 	list_for_each_entry_safe(fpo, tmp, head, fpo_list) {
 		list_del(&fpo->fpo_list);
@@ -1361,7 +1361,7 @@ kiblnd_fmr_flush_trigger(struct lnet_ioctl_config_o2iblnd_tunables *tunables,
 	return max(IBLND_FMR_POOL_FLUSH, size);
 }
 
-static int kiblnd_alloc_fmr_pool(kib_fmr_poolset_t *fps, kib_fmr_pool_t *fpo)
+static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
 {
 	struct ib_fmr_pool_param param = {
 		.max_pages_per_fmr = LNET_MAX_PAYLOAD / PAGE_SIZE,
@@ -1388,7 +1388,7 @@ static int kiblnd_alloc_fmr_pool(kib_fmr_poolset_t *fps, kib_fmr_pool_t *fpo)
 	return rc;
 }
 
-static int kiblnd_alloc_freg_pool(kib_fmr_poolset_t *fps, kib_fmr_pool_t *fpo)
+static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
 {
 	struct kib_fast_reg_descriptor *frd, *tmp;
 	int i, rc;
@@ -1438,12 +1438,12 @@ out:
 	return rc;
 }
 
-static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
-				  kib_fmr_pool_t **pp_fpo)
+static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
+				  struct kib_fmr_pool **pp_fpo)
 {
-	kib_dev_t *dev = fps->fps_net->ibn_dev;
+	struct kib_dev *dev = fps->fps_net->ibn_dev;
 	struct ib_device_attr *dev_attr;
-	kib_fmr_pool_t *fpo;
+	struct kib_fmr_pool *fpo;
 	int rc;
 
 	LIBCFS_CPT_ALLOC(fpo, lnet_cpt_table(), fps->fps_cpt, sizeof(*fpo));
@@ -1488,7 +1488,7 @@ out_fpo:
 	return rc;
 }
 
-static void kiblnd_fail_fmr_poolset(kib_fmr_poolset_t *fps,
+static void kiblnd_fail_fmr_poolset(struct kib_fmr_poolset *fps,
 				    struct list_head *zombies)
 {
 	if (!fps->fps_net) /* intialized? */
@@ -1497,8 +1497,8 @@ static void kiblnd_fail_fmr_poolset(kib_fmr_poolset_t *fps,
 	spin_lock(&fps->fps_lock);
 
 	while (!list_empty(&fps->fps_pool_list)) {
-		kib_fmr_pool_t *fpo = list_entry(fps->fps_pool_list.next,
-						 kib_fmr_pool_t, fpo_list);
+		struct kib_fmr_pool *fpo = list_entry(fps->fps_pool_list.next,
+						 struct kib_fmr_pool, fpo_list);
 		fpo->fpo_failed = 1;
 		list_del(&fpo->fpo_list);
 		if (!fpo->fpo_map_count)
@@ -1510,7 +1510,7 @@ static void kiblnd_fail_fmr_poolset(kib_fmr_poolset_t *fps,
 	spin_unlock(&fps->fps_lock);
 }
 
-static void kiblnd_fini_fmr_poolset(kib_fmr_poolset_t *fps)
+static void kiblnd_fini_fmr_poolset(struct kib_fmr_poolset *fps)
 {
 	if (fps->fps_net) { /* initialized? */
 		kiblnd_destroy_fmr_pool_list(&fps->fps_failed_pool_list);
@@ -1519,11 +1519,11 @@ static void kiblnd_fini_fmr_poolset(kib_fmr_poolset_t *fps)
 }
 
 static int
-kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt, int ncpts,
-			kib_net_t *net,
+kiblnd_init_fmr_poolset(struct kib_fmr_poolset *fps, int cpt, int ncpts,
+			struct kib_net *net,
 			struct lnet_ioctl_config_o2iblnd_tunables *tunables)
 {
-	kib_fmr_pool_t *fpo;
+	struct kib_fmr_pool *fpo;
 	int rc;
 
 	memset(fps, 0, sizeof(*fps));
@@ -1546,7 +1546,7 @@ kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt, int ncpts,
 	return rc;
 }
 
-static int kiblnd_fmr_pool_is_idle(kib_fmr_pool_t *fpo, unsigned long now)
+static int kiblnd_fmr_pool_is_idle(struct kib_fmr_pool *fpo, unsigned long now)
 {
 	if (fpo->fpo_map_count) /* still in use */
 		return 0;
@@ -1556,10 +1556,10 @@ static int kiblnd_fmr_pool_is_idle(kib_fmr_pool_t *fpo, unsigned long now)
 }
 
 static int
-kiblnd_map_tx_pages(kib_tx_t *tx, kib_rdma_desc_t *rd)
+kiblnd_map_tx_pages(struct kib_tx *tx, struct kib_rdma_desc *rd)
 {
 	__u64 *pages = tx->tx_pages;
-	kib_hca_dev_t *hdev;
+	struct kib_hca_dev *hdev;
 	int npages;
 	int size;
 	int i;
@@ -1577,13 +1577,13 @@ kiblnd_map_tx_pages(kib_tx_t *tx, kib_rdma_desc_t *rd)
 	return npages;
 }
 
-void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
+void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 {
 	LIST_HEAD(zombies);
-	kib_fmr_pool_t *fpo = fmr->fmr_pool;
-	kib_fmr_poolset_t *fps;
+	struct kib_fmr_pool *fpo = fmr->fmr_pool;
+	struct kib_fmr_poolset *fps;
 	unsigned long now = cfs_time_current();
-	kib_fmr_pool_t *tmp;
+	struct kib_fmr_pool *tmp;
 	int rc;
 
 	if (!fpo)
@@ -1633,14 +1633,14 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 		kiblnd_destroy_fmr_pool_list(&zombies);
 }
 
-int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
-			kib_rdma_desc_t *rd, __u32 nob, __u64 iov,
-			kib_fmr_t *fmr)
+int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
+			struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
+			struct kib_fmr *fmr)
 {
 	__u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
         bool tx_pages_mapped = 0;
-	kib_fmr_pool_t *fpo;
+	struct kib_fmr_pool *fpo;
 	int npages = 0;
 	__u64 version;
 	int rc;
@@ -1780,7 +1780,7 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
 	goto again;
 }
 
-static void kiblnd_fini_pool(kib_pool_t *pool)
+static void kiblnd_fini_pool(struct kib_pool *pool)
 {
 	LASSERT(list_empty(&pool->po_free_list));
 	LASSERT(!pool->po_allocated);
@@ -1788,7 +1788,7 @@ static void kiblnd_fini_pool(kib_pool_t *pool)
 	CDEBUG(D_NET, "Finalize %s pool\n", pool->po_owner->ps_name);
 }
 
-static void kiblnd_init_pool(kib_poolset_t *ps, kib_pool_t *pool, int size)
+static void kiblnd_init_pool(struct kib_poolset *ps, struct kib_pool *pool, int size)
 {
 	CDEBUG(D_NET, "Initialize %s pool\n", ps->ps_name);
 
@@ -1801,10 +1801,10 @@ static void kiblnd_init_pool(kib_poolset_t *ps, kib_pool_t *pool, int size)
 
 static void kiblnd_destroy_pool_list(struct list_head *head)
 {
-	kib_pool_t *pool;
+	struct kib_pool *pool;
 
 	while (!list_empty(head)) {
-		pool = list_entry(head->next, kib_pool_t, po_list);
+		pool = list_entry(head->next, struct kib_pool, po_list);
 		list_del(&pool->po_list);
 
 		LASSERT(pool->po_owner);
@@ -1812,15 +1812,15 @@ static void kiblnd_destroy_pool_list(struct list_head *head)
 	}
 }
 
-static void kiblnd_fail_poolset(kib_poolset_t *ps, struct list_head *zombies)
+static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombies)
 {
 	if (!ps->ps_net) /* intialized? */
 		return;
 
 	spin_lock(&ps->ps_lock);
 	while (!list_empty(&ps->ps_pool_list)) {
-		kib_pool_t *po = list_entry(ps->ps_pool_list.next,
-					    kib_pool_t, po_list);
+		struct kib_pool *po = list_entry(ps->ps_pool_list.next,
+					    struct kib_pool, po_list);
 		po->po_failed = 1;
 		list_del(&po->po_list);
 		if (!po->po_allocated)
@@ -1831,7 +1831,7 @@ static void kiblnd_fail_poolset(kib_poolset_t *ps, struct list_head *zombies)
 	spin_unlock(&ps->ps_lock);
 }
 
-static void kiblnd_fini_poolset(kib_poolset_t *ps)
+static void kiblnd_fini_poolset(struct kib_poolset *ps)
 {
 	if (ps->ps_net) { /* initialized? */
 		kiblnd_destroy_pool_list(&ps->ps_failed_pool_list);
@@ -1839,14 +1839,14 @@ static void kiblnd_fini_poolset(kib_poolset_t *ps)
 	}
 }
 
-static int kiblnd_init_poolset(kib_poolset_t *ps, int cpt,
-			       kib_net_t *net, char *name, int size,
+static int kiblnd_init_poolset(struct kib_poolset *ps, int cpt,
+			       struct kib_net *net, char *name, int size,
 			       kib_ps_pool_create_t po_create,
 			       kib_ps_pool_destroy_t po_destroy,
 			       kib_ps_node_init_t nd_init,
 			       kib_ps_node_fini_t nd_fini)
 {
-	kib_pool_t *pool;
+	struct kib_pool *pool;
 	int rc;
 
 	memset(ps, 0, sizeof(*ps));
@@ -1874,7 +1874,7 @@ static int kiblnd_init_poolset(kib_poolset_t *ps, int cpt,
 	return rc;
 }
 
-static int kiblnd_pool_is_idle(kib_pool_t *pool, unsigned long now)
+static int kiblnd_pool_is_idle(struct kib_pool *pool, unsigned long now)
 {
 	if (pool->po_allocated) /* still in use */
 		return 0;
@@ -1883,11 +1883,11 @@ static int kiblnd_pool_is_idle(kib_pool_t *pool, unsigned long now)
 	return cfs_time_aftereq(now, pool->po_deadline);
 }
 
-void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node)
+void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node)
 {
 	LIST_HEAD(zombies);
-	kib_poolset_t *ps = pool->po_owner;
-	kib_pool_t *tmp;
+	struct kib_poolset *ps = pool->po_owner;
+	struct kib_pool *tmp;
 	unsigned long now = cfs_time_current();
 
 	spin_lock(&ps->ps_lock);
@@ -1913,10 +1913,10 @@ void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node)
 		kiblnd_destroy_pool_list(&zombies);
 }
 
-struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
+struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps)
 {
 	struct list_head *node;
-	kib_pool_t *pool;
+	struct kib_pool *pool;
 	unsigned int interval = 1;
 	unsigned long time_before;
 	unsigned int trips = 0;
@@ -1986,9 +1986,9 @@ struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
 	goto again;
 }
 
-static void kiblnd_destroy_tx_pool(kib_pool_t *pool)
+static void kiblnd_destroy_tx_pool(struct kib_pool *pool)
 {
-	kib_tx_pool_t *tpo = container_of(pool, kib_tx_pool_t, tpo_pool);
+	struct kib_tx_pool *tpo = container_of(pool, struct kib_tx_pool, tpo_pool);
 	int i;
 
 	LASSERT(!pool->po_allocated);
@@ -2002,7 +2002,7 @@ static void kiblnd_destroy_tx_pool(kib_pool_t *pool)
 		goto out;
 
 	for (i = 0; i < pool->po_size; i++) {
-		kib_tx_t *tx = &tpo->tpo_tx_descs[i];
+		struct kib_tx *tx = &tpo->tpo_tx_descs[i];
 
 		list_del(&tx->tx_list);
 		if (tx->tx_pages)
@@ -2023,12 +2023,12 @@ static void kiblnd_destroy_tx_pool(kib_pool_t *pool)
 				    sizeof(*tx->tx_sge));
 		if (tx->tx_rd)
 			LIBCFS_FREE(tx->tx_rd,
-				    offsetof(kib_rdma_desc_t,
+				    offsetof(struct kib_rdma_desc,
 					     rd_frags[IBLND_MAX_RDMA_FRAGS]));
 	}
 
 	LIBCFS_FREE(tpo->tpo_tx_descs,
-		    pool->po_size * sizeof(kib_tx_t));
+		    pool->po_size * sizeof(struct kib_tx));
 out:
 	kiblnd_fini_pool(pool);
 	LIBCFS_FREE(tpo, sizeof(*tpo));
@@ -2041,13 +2041,13 @@ static int kiblnd_tx_pool_size(int ncpts)
 	return max(IBLND_TX_POOL, ntx);
 }
 
-static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
-				 kib_pool_t **pp_po)
+static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
+				 struct kib_pool **pp_po)
 {
 	int i;
 	int npg;
-	kib_pool_t *pool;
-	kib_tx_pool_t *tpo;
+	struct kib_pool *pool;
+	struct kib_tx_pool *tpo;
 
 	LIBCFS_CPT_ALLOC(tpo, lnet_cpt_table(), ps->ps_cpt, sizeof(*tpo));
 	if (!tpo) {
@@ -2068,17 +2068,17 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 	}
 
 	LIBCFS_CPT_ALLOC(tpo->tpo_tx_descs, lnet_cpt_table(), ps->ps_cpt,
-			 size * sizeof(kib_tx_t));
+			 size * sizeof(struct kib_tx));
 	if (!tpo->tpo_tx_descs) {
 		CERROR("Can't allocate %d tx descriptors\n", size);
 		ps->ps_pool_destroy(pool);
 		return -ENOMEM;
 	}
 
-	memset(tpo->tpo_tx_descs, 0, size * sizeof(kib_tx_t));
+	memset(tpo->tpo_tx_descs, 0, size * sizeof(struct kib_tx));
 
 	for (i = 0; i < size; i++) {
-		kib_tx_t *tx = &tpo->tpo_tx_descs[i];
+		struct kib_tx *tx = &tpo->tpo_tx_descs[i];
 
 		tx->tx_pool = tpo;
 		if (ps->ps_net->ibn_fmr_ps) {
@@ -2110,7 +2110,7 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 			break;
 
 		LIBCFS_CPT_ALLOC(tx->tx_rd, lnet_cpt_table(), ps->ps_cpt,
-				 offsetof(kib_rdma_desc_t,
+				 offsetof(struct kib_rdma_desc,
 					  rd_frags[IBLND_MAX_RDMA_FRAGS]));
 		if (!tx->tx_rd)
 			break;
@@ -2126,22 +2126,23 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 	return -ENOMEM;
 }
 
-static void kiblnd_tx_init(kib_pool_t *pool, struct list_head *node)
+static void kiblnd_tx_init(struct kib_pool *pool, struct list_head *node)
 {
-	kib_tx_poolset_t *tps = container_of(pool->po_owner, kib_tx_poolset_t,
-					     tps_poolset);
-	kib_tx_t *tx  = list_entry(node, kib_tx_t, tx_list);
+	struct kib_tx_poolset *tps = container_of(pool->po_owner,
+						  struct kib_tx_poolset,
+						  tps_poolset);
+	struct kib_tx *tx = list_entry(node, struct kib_tx, tx_list);
 
 	tx->tx_cookie = tps->tps_next_tx_cookie++;
 }
 
-static void kiblnd_net_fini_pools(kib_net_t *net)
+static void kiblnd_net_fini_pools(struct kib_net *net)
 {
 	int i;
 
 	cfs_cpt_for_each(i, lnet_cpt_table()) {
-		kib_tx_poolset_t *tps;
-		kib_fmr_poolset_t *fps;
+		struct kib_tx_poolset *tps;
+		struct kib_fmr_poolset *fps;
 
 		if (net->ibn_tx_ps) {
 			tps = net->ibn_tx_ps[i];
@@ -2165,7 +2166,7 @@ static void kiblnd_net_fini_pools(kib_net_t *net)
 	}
 }
 
-static int kiblnd_net_init_pools(kib_net_t *net, lnet_ni_t *ni, __u32 *cpts,
+static int kiblnd_net_init_pools(struct kib_net *net, lnet_ni_t *ni, __u32 *cpts,
 				 int ncpts)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
@@ -2207,7 +2208,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, lnet_ni_t *ni, __u32 *cpts,
 	 * number of CPTs that exist, i.e net->ibn_fmr_ps[cpt].
 	 */
 	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
-					   sizeof(kib_fmr_poolset_t));
+					   sizeof(struct kib_fmr_poolset));
 	if (!net->ibn_fmr_ps) {
 		CERROR("Failed to allocate FMR pool array\n");
 		rc = -ENOMEM;
@@ -2235,7 +2236,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, lnet_ni_t *ni, __u32 *cpts,
 	 * number of CPTs that exist, i.e net->ibn_tx_ps[cpt].
 	 */
 	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
-					  sizeof(kib_tx_poolset_t));
+					  sizeof(struct kib_tx_poolset));
 	if (!net->ibn_tx_ps) {
 		CERROR("Failed to allocate tx pool array\n");
 		rc = -ENOMEM;
@@ -2264,7 +2265,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, lnet_ni_t *ni, __u32 *cpts,
 	return rc;
 }
 
-static int kiblnd_hdev_get_attr(kib_hca_dev_t *hdev)
+static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 {
 	/*
 	 * It's safe to assume a HCA can handle a page size
@@ -2284,7 +2285,7 @@ static int kiblnd_hdev_get_attr(kib_hca_dev_t *hdev)
 	return -EINVAL;
 }
 
-static void kiblnd_hdev_cleanup_mrs(kib_hca_dev_t *hdev)
+static void kiblnd_hdev_cleanup_mrs(struct kib_hca_dev *hdev)
 {
 	if (!hdev->ibh_mrs)
 		return;
@@ -2294,7 +2295,7 @@ static void kiblnd_hdev_cleanup_mrs(kib_hca_dev_t *hdev)
 	hdev->ibh_mrs = NULL;
 }
 
-void kiblnd_hdev_destroy(kib_hca_dev_t *hdev)
+void kiblnd_hdev_destroy(struct kib_hca_dev *hdev)
 {
 	kiblnd_hdev_cleanup_mrs(hdev);
 
@@ -2307,7 +2308,7 @@ void kiblnd_hdev_destroy(kib_hca_dev_t *hdev)
 	LIBCFS_FREE(hdev, sizeof(*hdev));
 }
 
-static int kiblnd_hdev_setup_mrs(kib_hca_dev_t *hdev)
+static int kiblnd_hdev_setup_mrs(struct kib_hca_dev *hdev)
 {
 	struct ib_mr *mr;
 	int rc;
@@ -2336,7 +2337,7 @@ static int kiblnd_dummy_callback(struct rdma_cm_id *cmid,
 	return 0;
 }
 
-static int kiblnd_dev_need_failover(kib_dev_t *dev)
+static int kiblnd_dev_need_failover(struct kib_dev *dev)
 {
 	struct rdma_cm_id *cmid;
 	struct sockaddr_in srcaddr;
@@ -2390,15 +2391,15 @@ static int kiblnd_dev_need_failover(kib_dev_t *dev)
 	return rc;
 }
 
-int kiblnd_dev_failover(kib_dev_t *dev)
+int kiblnd_dev_failover(struct kib_dev *dev)
 {
 	LIST_HEAD(zombie_tpo);
 	LIST_HEAD(zombie_ppo);
 	LIST_HEAD(zombie_fpo);
 	struct rdma_cm_id *cmid  = NULL;
-	kib_hca_dev_t *hdev  = NULL;
+	struct kib_hca_dev *hdev  = NULL;
 	struct ib_pd *pd;
-	kib_net_t *net;
+	struct kib_net *net;
 	struct sockaddr_in addr;
 	unsigned long flags;
 	int rc = 0;
@@ -2523,7 +2524,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 	return rc;
 }
 
-void kiblnd_destroy_dev(kib_dev_t *dev)
+void kiblnd_destroy_dev(struct kib_dev *dev)
 {
 	LASSERT(!dev->ibd_nnets);
 	LASSERT(list_empty(&dev->ibd_nets));
@@ -2537,10 +2538,10 @@ void kiblnd_destroy_dev(kib_dev_t *dev)
 	LIBCFS_FREE(dev, sizeof(*dev));
 }
 
-static kib_dev_t *kiblnd_create_dev(char *ifname)
+static struct kib_dev *kiblnd_create_dev(char *ifname)
 {
 	struct net_device *netdev;
-	kib_dev_t *dev;
+	struct kib_dev *dev;
 	__u32 netmask;
 	__u32 ip;
 	int up;
@@ -2655,7 +2656,7 @@ static void kiblnd_base_shutdown(void)
 
 static void kiblnd_shutdown(lnet_ni_t *ni)
 {
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
 	int i;
 	unsigned long flags;
@@ -2852,7 +2853,7 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 	return rc;
 }
 
-static int kiblnd_dev_start_threads(kib_dev_t *dev, int newdev, __u32 *cpts,
+static int kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, __u32 *cpts,
 				    int ncpts)
 {
 	int cpt;
@@ -2878,10 +2879,10 @@ static int kiblnd_dev_start_threads(kib_dev_t *dev, int newdev, __u32 *cpts,
 	return 0;
 }
 
-static kib_dev_t *kiblnd_dev_search(char *ifname)
+static struct kib_dev *kiblnd_dev_search(char *ifname)
 {
-	kib_dev_t *alias = NULL;
-	kib_dev_t *dev;
+	struct kib_dev *alias = NULL;
+	struct kib_dev *dev;
 	char *colon;
 	char *colon2;
 
@@ -2913,8 +2914,8 @@ static kib_dev_t *kiblnd_dev_search(char *ifname)
 static int kiblnd_startup(lnet_ni_t *ni)
 {
 	char *ifname;
-	kib_dev_t *ibdev = NULL;
-	kib_net_t *net;
+	struct kib_dev *ibdev = NULL;
+	struct kib_net *net;
 	struct timespec64 tv;
 	unsigned long flags;
 	int rc;
@@ -3021,11 +3022,11 @@ static void __exit ko2iblnd_exit(void)
 
 static int __init ko2iblnd_init(void)
 {
-	CLASSERT(sizeof(kib_msg_t) <= IBLND_MSG_SIZE);
-	CLASSERT(offsetof(kib_msg_t,
+	CLASSERT(sizeof(struct kib_msg) <= IBLND_MSG_SIZE);
+	CLASSERT(offsetof(struct kib_msg,
 			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
 			  <= IBLND_MSG_SIZE);
-	CLASSERT(offsetof(kib_msg_t,
+	CLASSERT(offsetof(struct kib_msg,
 			  ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
 			  <= IBLND_MSG_SIZE);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 45bbe93..4bac2b7 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -78,12 +78,12 @@
 #define IBLND_N_SCHED			2
 #define IBLND_N_SCHED_HIGH		4
 
-typedef struct {
+struct kib_tunables {
 	int *kib_dev_failover;           /* HCA failover */
 	unsigned int *kib_service;       /* IB service number */
 	int *kib_min_reconnect_interval; /* first failed connection retry... */
 	int *kib_max_reconnect_interval; /* exponentially increasing to this */
-	int *kib_cksum;                  /* checksum kib_msg_t? */
+	int *kib_cksum;                  /* checksum struct kib_msg? */
 	int *kib_timeout;                /* comms timeout (seconds) */
 	int *kib_keepalive;              /* keepalive timeout (seconds) */
 	int *kib_ntx;                    /* # tx descs */
@@ -94,15 +94,15 @@ typedef struct {
 	int *kib_require_priv_port;      /* accept only privileged ports */
 	int *kib_use_priv_port; /* use privileged port for active connect */
 	int *kib_nscheds;                /* # threads on each CPT */
-} kib_tunables_t;
+};
 
-extern kib_tunables_t  kiblnd_tunables;
+extern struct kib_tunables  kiblnd_tunables;
 
 #define IBLND_MSG_QUEUE_SIZE_V1   8 /* V1 only : # messages/RDMAs in-flight */
 #define IBLND_CREDIT_HIGHWATER_V1 7 /* V1 only : when eagerly to return credits */
 
 #define IBLND_CREDITS_DEFAULT     8 /* default # of peer credits */
-#define IBLND_CREDITS_MAX	  ((typeof(((kib_msg_t *) 0)->ibm_credits)) - 1)  /* Max # of peer credits */
+#define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *) 0)->ibm_credits)) - 1)  /* Max # of peer credits */
 
 /* when eagerly to return credits */
 #define IBLND_CREDITS_HIGHWATER(t, v)	((v) == IBLND_MSG_VERSION_1 ? \
@@ -150,7 +150,7 @@ struct kib_hca_dev;
 #define KIB_IFNAME_SIZE	      256
 #endif
 
-typedef struct {
+struct kib_dev {
 	struct list_head   ibd_list;            /* chain on kib_devs */
 	struct list_head   ibd_fail_list;       /* chain on kib_failed_devs */
 	__u32              ibd_ifip;            /* IPoIB interface IP */
@@ -165,9 +165,9 @@ typedef struct {
 	unsigned int ibd_can_failover; /* IPoIB interface is a bonding master */
 	struct list_head   ibd_nets;
 	struct kib_hca_dev *ibd_hdev;
-} kib_dev_t;
+};
 
-typedef struct kib_hca_dev {
+struct kib_hca_dev {
 	struct rdma_cm_id  *ibh_cmid;           /* listener cmid */
 	struct ib_device   *ibh_ibdev;          /* IB device */
 	int                ibh_page_shift;      /* page shift of current HCA */
@@ -177,19 +177,19 @@ typedef struct kib_hca_dev {
 	__u64              ibh_mr_size;         /* size of MR */
 	struct ib_mr	   *ibh_mrs;		/* global MR */
 	struct ib_pd       *ibh_pd;             /* PD */
-	kib_dev_t          *ibh_dev;            /* owner */
+	struct kib_dev	   *ibh_dev;		/* owner */
 	atomic_t           ibh_ref;             /* refcount */
-} kib_hca_dev_t;
+};
 
 /** # of seconds to keep pool alive */
 #define IBLND_POOL_DEADLINE     300
 /** # of seconds to retry if allocation failed */
 #define IBLND_POOL_RETRY	1
 
-typedef struct {
+struct kib_pages {
 	int                ibp_npages;          /* # pages */
 	struct page        *ibp_pages[0];       /* page array */
-} kib_pages_t;
+};
 
 struct kib_pool;
 struct kib_poolset;
@@ -204,7 +204,7 @@ struct kib_net;
 
 #define IBLND_POOL_NAME_LEN     32
 
-typedef struct kib_poolset {
+struct kib_poolset {
 	spinlock_t            ps_lock;            /* serialize */
 	struct kib_net        *ps_net;            /* network it belongs to */
 	char                  ps_name[IBLND_POOL_NAME_LEN]; /* pool set name */
@@ -220,31 +220,31 @@ typedef struct kib_poolset {
 	kib_ps_pool_destroy_t ps_pool_destroy;    /* destroy a pool */
 	kib_ps_node_init_t    ps_node_init; /* initialize new allocated node */
 	kib_ps_node_fini_t    ps_node_fini;       /* finalize node */
-} kib_poolset_t;
+};
 
-typedef struct kib_pool {
+struct kib_pool {
 	struct list_head      po_list;       /* chain on pool list */
 	struct list_head      po_free_list;  /* pre-allocated node */
-	kib_poolset_t         *po_owner;     /* pool_set of this pool */
+	struct kib_poolset	*po_owner;	/* pool_set of this pool */
 	unsigned long         po_deadline;   /* deadline of this pool */
 	int                   po_allocated;  /* # of elements in use */
 	int                   po_failed;     /* pool is created on failed HCA */
 	int                   po_size;       /* # of pre-allocated elements */
-} kib_pool_t;
+};
 
-typedef struct {
-	kib_poolset_t         tps_poolset;        /* pool-set */
+struct kib_tx_poolset {
+	struct kib_poolset	tps_poolset;		/* pool-set */
 	__u64                 tps_next_tx_cookie; /* cookie of TX */
-} kib_tx_poolset_t;
+};
 
-typedef struct {
-	kib_pool_t            tpo_pool;           /* pool */
-	struct kib_hca_dev    *tpo_hdev;          /* device for this pool */
-	struct kib_tx         *tpo_tx_descs;      /* all the tx descriptors */
-	kib_pages_t           *tpo_tx_pages;      /* premapped tx msg pages */
-} kib_tx_pool_t;
+struct kib_tx_pool {
+	struct kib_pool		 tpo_pool;	/* pool */
+	struct kib_hca_dev	*tpo_hdev;	/* device for this pool */
+	struct kib_tx		*tpo_tx_descs;	/* all the tx descriptors */
+	struct kib_pages	*tpo_tx_pages;	/* premapped tx msg pages */
+};
 
-typedef struct {
+struct kib_fmr_poolset {
 	spinlock_t            fps_lock;            /* serialize */
 	struct kib_net        *fps_net;            /* IB network */
 	struct list_head      fps_pool_list;       /* FMR pool list */
@@ -257,7 +257,7 @@ typedef struct {
 	int                   fps_increasing;      /* is allocating new pool */
 	unsigned long         fps_next_retry;      /* time stamp for retry if*/
 						   /* failed to allocate */
-} kib_fmr_poolset_t;
+};
 
 struct kib_fast_reg_descriptor { /* For fast registration */
 	struct list_head		 frd_list;
@@ -267,10 +267,10 @@ struct kib_fast_reg_descriptor { /* For fast registration */
 	bool				 frd_valid;
 };
 
-typedef struct {
-	struct list_head      fpo_list;            /* chain on pool list */
-	struct kib_hca_dev    *fpo_hdev;           /* device for this pool */
-	kib_fmr_poolset_t     *fpo_owner;          /* owner of this pool */
+struct kib_fmr_pool {
+	struct list_head	 fpo_list;	/* chain on pool list */
+	struct kib_hca_dev	*fpo_hdev;	/* device for this pool */
+	struct kib_fmr_poolset	*fpo_owner;	/* owner of this pool */
 	union {
 		struct {
 			struct ib_fmr_pool *fpo_fmr_pool; /* IB FMR pool */
@@ -284,17 +284,17 @@ typedef struct {
 	int                   fpo_failed;          /* fmr pool is failed */
 	int                   fpo_map_count;       /* # of mapped FMR */
 	int		      fpo_is_fmr;
-} kib_fmr_pool_t;
+};
 
-typedef struct {
-	kib_fmr_pool_t			*fmr_pool;	/* pool of FMR */
+struct kib_fmr {
+	struct kib_fmr_pool		*fmr_pool;	/* pool of FMR */
 	struct ib_pool_fmr		*fmr_pfmr;	/* IB pool fmr */
 	struct kib_fast_reg_descriptor	*fmr_frd;
 	u32				 fmr_key;
-} kib_fmr_t;
+};
 
-typedef struct kib_net {
-	struct list_head      ibn_list;       /* chain on kib_dev_t::ibd_nets */
+struct kib_net {
+	struct list_head      ibn_list;       /* chain on struct kib_dev::ibd_nets */
 	__u64                 ibn_incarnation;/* my epoch */
 	int                   ibn_init;       /* initialisation state */
 	int                   ibn_shutdown;   /* shutting down? */
@@ -302,11 +302,11 @@ typedef struct kib_net {
 	atomic_t              ibn_npeers;     /* # peers extant */
 	atomic_t              ibn_nconns;     /* # connections extant */
 
-	kib_tx_poolset_t      **ibn_tx_ps;    /* tx pool-set */
-	kib_fmr_poolset_t     **ibn_fmr_ps;   /* fmr pool-set */
+	struct kib_tx_poolset	**ibn_tx_ps;	/* tx pool-set */
+	struct kib_fmr_poolset	**ibn_fmr_ps;	/* fmr pool-set */
 
-	kib_dev_t             *ibn_dev;       /* underlying IB device */
-} kib_net_t;
+	struct kib_dev		*ibn_dev;	/* underlying IB device */
+};
 
 #define KIB_THREAD_SHIFT		16
 #define KIB_THREAD_ID(cpt, tid)		((cpt) << KIB_THREAD_SHIFT | (tid))
@@ -322,7 +322,7 @@ struct kib_sched_info {
 	int                ibs_cpt;      /* CPT id */
 };
 
-typedef struct {
+struct kib_data {
 	int               kib_init;           /* initialisation state */
 	int               kib_shutdown;       /* shut down? */
 	struct list_head  kib_devs;           /* IB devices extant */
@@ -349,7 +349,7 @@ typedef struct {
 	spinlock_t kib_connd_lock;          /* serialise */
 	struct ib_qp_attr kib_error_qpa;    /* QP->ERROR */
 	struct kib_sched_info **kib_scheds; /* percpt data for schedulers */
-} kib_data_t;
+};
 
 #define IBLND_INIT_NOTHING 0
 #define IBLND_INIT_DATA    1
@@ -360,51 +360,51 @@ typedef struct {
  * These are sent in sender's byte order (i.e. receiver flips).
  */
 
-typedef struct kib_connparams {
+struct kib_connparams {
 	__u16        ibcp_queue_depth;
 	__u16        ibcp_max_frags;
 	__u32        ibcp_max_msg_size;
-} WIRE_ATTR kib_connparams_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_immediate_msg {
 	lnet_hdr_t   ibim_hdr;        /* portals header */
 	char         ibim_payload[0]; /* piggy-backed payload */
-} WIRE_ATTR kib_immediate_msg_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_rdma_frag {
 	__u32        rf_nob;          /* # bytes this frag */
 	__u64        rf_addr;         /* CAVEAT EMPTOR: misaligned!! */
-} WIRE_ATTR kib_rdma_frag_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_rdma_desc {
 	__u32           rd_key;       /* local/remote key */
 	__u32           rd_nfrags;    /* # fragments */
-	kib_rdma_frag_t rd_frags[0];  /* buffer frags */
-} WIRE_ATTR kib_rdma_desc_t;
+	struct kib_rdma_frag	rd_frags[0];	/* buffer frags */
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_putreq_msg {
 	lnet_hdr_t      ibprm_hdr;    /* portals header */
 	__u64           ibprm_cookie; /* opaque completion cookie */
-} WIRE_ATTR kib_putreq_msg_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_putack_msg {
 	__u64           ibpam_src_cookie; /* reflected completion cookie */
 	__u64           ibpam_dst_cookie; /* opaque completion cookie */
-	kib_rdma_desc_t ibpam_rd;         /* sender's sink buffer */
-} WIRE_ATTR kib_putack_msg_t;
+	struct kib_rdma_desc ibpam_rd;         /* sender's sink buffer */
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_get_msg {
 	lnet_hdr_t      ibgm_hdr;     /* portals header */
 	__u64           ibgm_cookie;  /* opaque completion cookie */
-	kib_rdma_desc_t ibgm_rd;      /* rdma descriptor */
-} WIRE_ATTR kib_get_msg_t;
+	struct kib_rdma_desc ibgm_rd;      /* rdma descriptor */
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_completion_msg {
 	__u64           ibcm_cookie;  /* opaque completion cookie */
 	__s32           ibcm_status;  /* < 0 failure: >= 0 length */
-} WIRE_ATTR kib_completion_msg_t;
+} WIRE_ATTR;
 
-typedef struct {
+struct kib_msg {
 	/* First 2 fields fixed FOR ALL TIME */
 	__u32           ibm_magic;    /* I'm an ibnal message */
 	__u16           ibm_version;  /* this is my version number */
@@ -419,14 +419,14 @@ typedef struct {
 	__u64           ibm_dststamp; /* destination's incarnation */
 
 	union {
-		kib_connparams_t     connparams;
-		kib_immediate_msg_t  immediate;
-		kib_putreq_msg_t     putreq;
-		kib_putack_msg_t     putack;
-		kib_get_msg_t        get;
-		kib_completion_msg_t completion;
+		struct kib_connparams		connparams;
+		struct kib_immediate_msg	immediate;
+		struct kib_putreq_msg		putreq;
+		struct kib_putack_msg		putack;
+		struct kib_get_msg		get;
+		struct kib_completion_msg	completion;
 	} WIRE_ATTR ibm_u;
-} WIRE_ATTR kib_msg_t;
+} WIRE_ATTR;
 
 #define IBLND_MSG_MAGIC     LNET_PROTO_IB_MAGIC /* unique magic */
 
@@ -445,14 +445,14 @@ typedef struct {
 #define IBLND_MSG_GET_REQ   0xd6	/* getreq (sink->src) */
 #define IBLND_MSG_GET_DONE  0xd7	/* completion (src->sink: all OK) */
 
-typedef struct {
+struct kib_rej {
 	__u32            ibr_magic;       /* sender's magic */
 	__u16            ibr_version;     /* sender's version */
 	__u8             ibr_why;         /* reject reason */
 	__u8             ibr_padding;     /* padding */
 	__u64            ibr_incarnation; /* incarnation of peer */
-	kib_connparams_t ibr_cp;          /* connection parameters */
-} WIRE_ATTR kib_rej_t;
+	struct kib_connparams ibr_cp;          /* connection parameters */
+} WIRE_ATTR;
 
 /* connection rejection reasons */
 #define IBLND_REJECT_CONN_RACE      1 /* You lost connection race */
@@ -467,28 +467,26 @@ typedef struct {
 
 /***********************************************************************/
 
-typedef struct kib_rx                         /* receive message */
-{
+struct kib_rx {					/* receive message */
 	struct list_head       rx_list;       /* queue for attention */
 	struct kib_conn        *rx_conn;      /* owning conn */
 	int                    rx_nob; /* # bytes received (-1 while posted) */
 	enum ib_wc_status      rx_status;     /* completion status */
-	kib_msg_t              *rx_msg;       /* message buffer (host vaddr) */
+	struct kib_msg		*rx_msg;	/* message buffer (host vaddr) */
 	__u64                  rx_msgaddr;    /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
 	struct ib_recv_wr      rx_wrq;        /* receive work item... */
 	struct ib_sge          rx_sge;        /* ...and its memory */
-} kib_rx_t;
+};
 
 #define IBLND_POSTRX_DONT_POST    0 /* don't post */
 #define IBLND_POSTRX_NO_CREDIT    1 /* post: no credits */
 #define IBLND_POSTRX_PEER_CREDIT  2 /* post: give peer back 1 credit */
 #define IBLND_POSTRX_RSRVD_CREDIT 3 /* post: give self back 1 reserved credit */
 
-typedef struct kib_tx                         /* transmit message */
-{
+struct kib_tx {					/* transmit message */
 	struct list_head      tx_list; /* queue on idle_txs ibc_tx_queue etc. */
-	kib_tx_pool_t         *tx_pool;       /* pool I'm from */
+	struct kib_tx_pool	*tx_pool;	/* pool I'm from */
 	struct kib_conn       *tx_conn;       /* owning conn */
 	short                 tx_sending;     /* # tx callbacks outstanding */
 	short                 tx_queued;      /* queued for sending */
@@ -497,28 +495,28 @@ typedef struct kib_tx                         /* transmit message */
 	unsigned long         tx_deadline;    /* completion deadline */
 	__u64                 tx_cookie;      /* completion cookie */
 	lnet_msg_t *tx_lntmsg[2]; /* lnet msgs to finalize on completion */
-	kib_msg_t             *tx_msg;        /* message buffer (host vaddr) */
+	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
 	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
 	int                   tx_nwrq;        /* # send work items */
 	struct ib_rdma_wr     *tx_wrq;        /* send work items... */
 	struct ib_sge         *tx_sge;        /* ...and their memory */
-	kib_rdma_desc_t       *tx_rd;         /* rdma descriptor */
+	struct kib_rdma_desc  *tx_rd;         /* rdma descriptor */
 	int                   tx_nfrags;      /* # entries in... */
 	struct scatterlist    *tx_frags;      /* dma_map_sg descriptor */
 	__u64                 *tx_pages;      /* rdma phys page addrs */
-	kib_fmr_t             fmr;	      /* FMR */
+	struct kib_fmr        fmr;	      /* FMR */
 	int                   tx_dmadir;      /* dma direction */
-} kib_tx_t;
+};
 
-typedef struct kib_connvars {
-	kib_msg_t cv_msg; /* connection-in-progress variables */
-} kib_connvars_t;
+struct kib_connvars {
+	struct kib_msg cv_msg; /* connection-in-progress variables */
+};
 
-typedef struct kib_conn {
+struct kib_conn {
 	struct kib_sched_info *ibc_sched;      /* scheduler information */
 	struct kib_peer       *ibc_peer;       /* owning peer */
-	kib_hca_dev_t         *ibc_hdev;       /* HCA bound on */
+	struct kib_hca_dev         *ibc_hdev;       /* HCA bound on */
 	struct list_head ibc_list;             /* stash on peer's conn list */
 	struct list_head      ibc_sched_list;  /* schedule for attention */
 	__u16                 ibc_version;     /* version of connection */
@@ -553,14 +551,14 @@ typedef struct kib_conn {
 					       /* reserve an ACK/DONE msg */
 	struct list_head ibc_active_txs; /* active tx awaiting completion */
 	spinlock_t            ibc_lock;        /* serialise */
-	kib_rx_t              *ibc_rxs;        /* the rx descs */
-	kib_pages_t           *ibc_rx_pages;   /* premapped rx msg pages */
+	struct kib_rx              *ibc_rxs;        /* the rx descs */
+	struct kib_pages           *ibc_rx_pages;   /* premapped rx msg pages */
 
 	struct rdma_cm_id     *ibc_cmid;       /* CM id */
 	struct ib_cq          *ibc_cq;         /* completion queue */
 
-	kib_connvars_t        *ibc_connvars; /* in-progress connection state */
-} kib_conn_t;
+	struct kib_connvars	*ibc_connvars;	/* in-progress connection state */
+};
 
 #define IBLND_CONN_INIT           0	 /* being initialised */
 #define IBLND_CONN_ACTIVE_CONNECT 1	 /* active sending req */
@@ -569,7 +567,7 @@ typedef struct kib_conn {
 #define IBLND_CONN_CLOSING        4	 /* being closed */
 #define IBLND_CONN_DISCONNECTED   5	 /* disconnected */
 
-typedef struct kib_peer {
+struct kib_peer {
 	struct list_head ibp_list;        /* stash on global peer list */
 	lnet_nid_t       ibp_nid;         /* who's on the other end(s) */
 	lnet_ni_t        *ibp_ni;         /* LNet interface */
@@ -596,11 +594,11 @@ typedef struct kib_peer {
 	__u16		 ibp_max_frags;
 	/* max_peer_credits */
 	__u16		 ibp_queue_depth;
-} kib_peer_t;
+};
 
-extern kib_data_t kiblnd_data;
+extern struct kib_data kiblnd_data;
 
-void kiblnd_hdev_destroy(kib_hca_dev_t *hdev);
+void kiblnd_hdev_destroy(struct kib_hca_dev *hdev);
 
 int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
 
@@ -645,14 +643,14 @@ kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
 }
 
 static inline void
-kiblnd_hdev_addref_locked(kib_hca_dev_t *hdev)
+kiblnd_hdev_addref_locked(struct kib_hca_dev *hdev)
 {
 	LASSERT(atomic_read(&hdev->ibh_ref) > 0);
 	atomic_inc(&hdev->ibh_ref);
 }
 
 static inline void
-kiblnd_hdev_decref(kib_hca_dev_t *hdev)
+kiblnd_hdev_decref(struct kib_hca_dev *hdev)
 {
 	LASSERT(atomic_read(&hdev->ibh_ref) > 0);
 	if (atomic_dec_and_test(&hdev->ibh_ref))
@@ -660,7 +658,7 @@ kiblnd_hdev_decref(kib_hca_dev_t *hdev)
 }
 
 static inline int
-kiblnd_dev_can_failover(kib_dev_t *dev)
+kiblnd_dev_can_failover(struct kib_dev *dev)
 {
 	if (!list_empty(&dev->ibd_fail_list)) /* already scheduled */
 		return 0;
@@ -716,7 +714,7 @@ do {							    \
 } while (0)
 
 static inline bool
-kiblnd_peer_connecting(kib_peer_t *peer)
+kiblnd_peer_connecting(struct kib_peer *peer)
 {
 	return peer->ibp_connecting ||
 	       peer->ibp_reconnecting ||
@@ -724,7 +722,7 @@ kiblnd_peer_connecting(kib_peer_t *peer)
 }
 
 static inline bool
-kiblnd_peer_idle(kib_peer_t *peer)
+kiblnd_peer_idle(struct kib_peer *peer)
 {
 	return !kiblnd_peer_connecting(peer) && list_empty(&peer->ibp_conns);
 }
@@ -739,23 +737,23 @@ kiblnd_nid2peerlist(lnet_nid_t nid)
 }
 
 static inline int
-kiblnd_peer_active(kib_peer_t *peer)
+kiblnd_peer_active(struct kib_peer *peer)
 {
 	/* Am I in the peer hash table? */
 	return !list_empty(&peer->ibp_list);
 }
 
-static inline kib_conn_t *
-kiblnd_get_conn_locked(kib_peer_t *peer)
+static inline struct kib_conn *
+kiblnd_get_conn_locked(struct kib_peer *peer)
 {
 	LASSERT(!list_empty(&peer->ibp_conns));
 
 	/* just return the first connection */
-	return list_entry(peer->ibp_conns.next, kib_conn_t, ibc_list);
+	return list_entry(peer->ibp_conns.next, struct kib_conn, ibc_list);
 }
 
 static inline int
-kiblnd_send_keepalive(kib_conn_t *conn)
+kiblnd_send_keepalive(struct kib_conn *conn)
 {
 	return (*kiblnd_tunables.kib_keepalive > 0) &&
 		cfs_time_after(jiffies, conn->ibc_last_send +
@@ -764,7 +762,7 @@ kiblnd_send_keepalive(kib_conn_t *conn)
 }
 
 static inline int
-kiblnd_need_noop(kib_conn_t *conn)
+kiblnd_need_noop(struct kib_conn *conn)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
@@ -800,14 +798,14 @@ kiblnd_need_noop(kib_conn_t *conn)
 }
 
 static inline void
-kiblnd_abort_receives(kib_conn_t *conn)
+kiblnd_abort_receives(struct kib_conn *conn)
 {
 	ib_modify_qp(conn->ibc_cmid->qp,
 		     &kiblnd_data.kib_error_qpa, IB_QP_STATE);
 }
 
 static inline const char *
-kiblnd_queue2str(kib_conn_t *conn, struct list_head *q)
+kiblnd_queue2str(struct kib_conn *conn, struct list_head *q)
 {
 	if (q == &conn->ibc_tx_queue)
 		return "tx_queue";
@@ -858,21 +856,21 @@ kiblnd_wreqid2type(__u64 wreqid)
 }
 
 static inline void
-kiblnd_set_conn_state(kib_conn_t *conn, int state)
+kiblnd_set_conn_state(struct kib_conn *conn, int state)
 {
 	conn->ibc_state = state;
 	mb();
 }
 
 static inline void
-kiblnd_init_msg(kib_msg_t *msg, int type, int body_nob)
+kiblnd_init_msg(struct kib_msg *msg, int type, int body_nob)
 {
 	msg->ibm_type = type;
-	msg->ibm_nob  = offsetof(kib_msg_t, ibm_u) + body_nob;
+	msg->ibm_nob  = offsetof(struct kib_msg, ibm_u) + body_nob;
 }
 
 static inline int
-kiblnd_rd_size(kib_rdma_desc_t *rd)
+kiblnd_rd_size(struct kib_rdma_desc *rd)
 {
 	int   i;
 	int   size;
@@ -884,25 +882,25 @@ kiblnd_rd_size(kib_rdma_desc_t *rd)
 }
 
 static inline __u64
-kiblnd_rd_frag_addr(kib_rdma_desc_t *rd, int index)
+kiblnd_rd_frag_addr(struct kib_rdma_desc *rd, int index)
 {
 	return rd->rd_frags[index].rf_addr;
 }
 
 static inline __u32
-kiblnd_rd_frag_size(kib_rdma_desc_t *rd, int index)
+kiblnd_rd_frag_size(struct kib_rdma_desc *rd, int index)
 {
 	return rd->rd_frags[index].rf_nob;
 }
 
 static inline __u32
-kiblnd_rd_frag_key(kib_rdma_desc_t *rd, int index)
+kiblnd_rd_frag_key(struct kib_rdma_desc *rd, int index)
 {
 	return rd->rd_key;
 }
 
 static inline int
-kiblnd_rd_consume_frag(kib_rdma_desc_t *rd, int index, __u32 nob)
+kiblnd_rd_consume_frag(struct kib_rdma_desc *rd, int index, __u32 nob)
 {
 	if (nob < rd->rd_frags[index].rf_nob) {
 		rd->rd_frags[index].rf_addr += nob;
@@ -915,14 +913,14 @@ kiblnd_rd_consume_frag(kib_rdma_desc_t *rd, int index, __u32 nob)
 }
 
 static inline int
-kiblnd_rd_msg_size(kib_rdma_desc_t *rd, int msgtype, int n)
+kiblnd_rd_msg_size(struct kib_rdma_desc *rd, int msgtype, int n)
 {
 	LASSERT(msgtype == IBLND_MSG_GET_REQ ||
 		msgtype == IBLND_MSG_PUT_ACK);
 
 	return msgtype == IBLND_MSG_GET_REQ ?
-	       offsetof(kib_get_msg_t, ibgm_rd.rd_frags[n]) :
-	       offsetof(kib_putack_msg_t, ibpam_rd.rd_frags[n]);
+	       offsetof(struct kib_get_msg, ibgm_rd.rd_frags[n]) :
+	       offsetof(struct kib_putack_msg, ibpam_rd.rd_frags[n]);
 }
 
 static inline __u64
@@ -981,17 +979,17 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 #define KIBLND_CONN_PARAM(e)     ((e)->param.conn.private_data)
 #define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
 
-struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, kib_rdma_desc_t *rd,
+struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, struct kib_rdma_desc *rd,
 				    int negotiated_nfrags);
-void kiblnd_map_rx_descs(kib_conn_t *conn);
-void kiblnd_unmap_rx_descs(kib_conn_t *conn);
-void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node);
-struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps);
+void kiblnd_map_rx_descs(struct kib_conn *conn);
+void kiblnd_unmap_rx_descs(struct kib_conn *conn);
+void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node);
+struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps);
 
-int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
-			 kib_rdma_desc_t *rd, __u32 nob, __u64 iov,
-			 kib_fmr_t *fmr);
-void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
+int  kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
+			 struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
+			 struct kib_fmr *fmr);
+void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status);
 
 int kiblnd_tunables_setup(struct lnet_ni *ni);
 void kiblnd_tunables_init(void);
@@ -1001,30 +999,31 @@ int  kiblnd_scheduler(void *arg);
 int  kiblnd_thread_start(int (*fn)(void *arg), void *arg, char *name);
 int  kiblnd_failover_thread(void *arg);
 
-int  kiblnd_alloc_pages(kib_pages_t **pp, int cpt, int npages);
+int  kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages);
 
 int  kiblnd_cm_callback(struct rdma_cm_id *cmid,
 			struct rdma_cm_event *event);
 int  kiblnd_translate_mtu(int value);
 
-int  kiblnd_dev_failover(kib_dev_t *dev);
-int  kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid);
-void kiblnd_destroy_peer(kib_peer_t *peer);
-bool kiblnd_reconnect_peer(kib_peer_t *peer);
-void kiblnd_destroy_dev(kib_dev_t *dev);
-void kiblnd_unlink_peer_locked(kib_peer_t *peer);
-kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid);
-int  kiblnd_close_stale_conns_locked(kib_peer_t *peer,
+int  kiblnd_dev_failover(struct kib_dev *dev);
+int  kiblnd_create_peer(lnet_ni_t *ni, struct kib_peer **peerp, lnet_nid_t nid);
+void kiblnd_destroy_peer(struct kib_peer *peer);
+bool kiblnd_reconnect_peer(struct kib_peer *peer);
+void kiblnd_destroy_dev(struct kib_dev *dev);
+void kiblnd_unlink_peer_locked(struct kib_peer *peer);
+struct kib_peer *kiblnd_find_peer_locked(lnet_nid_t nid);
+int  kiblnd_close_stale_conns_locked(struct kib_peer *peer,
 				     int version, __u64 incarnation);
-int  kiblnd_close_peer_conns_locked(kib_peer_t *peer, int why);
+int  kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why);
 
-kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
-			       int state, int version);
-void kiblnd_destroy_conn(kib_conn_t *conn, bool free_conn);
-void kiblnd_close_conn(kib_conn_t *conn, int error);
-void kiblnd_close_conn_locked(kib_conn_t *conn, int error);
+struct kib_conn *kiblnd_create_conn(struct kib_peer *peer,
+				    struct rdma_cm_id *cmid,
+				    int state, int version);
+void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn);
+void kiblnd_close_conn(struct kib_conn *conn, int error);
+void kiblnd_close_conn_locked(struct kib_conn *conn, int error);
 
-void kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid);
+void kiblnd_launch_tx(lnet_ni_t *ni, struct kib_tx *tx, lnet_nid_t nid);
 void kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist,
 			int status);
 
@@ -1032,10 +1031,10 @@ void kiblnd_qp_event(struct ib_event *event, void *arg);
 void kiblnd_cq_event(struct ib_event *event, void *arg);
 void kiblnd_cq_completion(struct ib_cq *cq, void *arg);
 
-void kiblnd_pack_msg(lnet_ni_t *ni, kib_msg_t *msg, int version,
+void kiblnd_pack_msg(lnet_ni_t *ni, struct kib_msg *msg, int version,
 		     int credits, lnet_nid_t dstnid, __u64 dststamp);
-int  kiblnd_unpack_msg(kib_msg_t *msg, int nob);
-int  kiblnd_post_rx(kib_rx_t *rx, int credit);
+int  kiblnd_unpack_msg(struct kib_msg *msg, int nob);
+int  kiblnd_post_rx(struct kib_rx *rx, int credit);
 
 int  kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg);
 int  kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 0f7e3a1..b3cf62f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -40,22 +40,22 @@
 
 #include "o2iblnd.h"
 
-static void kiblnd_peer_alive(kib_peer_t *peer);
-static void kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error);
-static void kiblnd_check_sends(kib_conn_t *conn);
-static void kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx,
+static void kiblnd_peer_alive(struct kib_peer *peer);
+static void kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error);
+static void kiblnd_check_sends(struct kib_conn *conn);
+static void kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx,
 				int type, int body_nob);
-static int kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
-			     int resid, kib_rdma_desc_t *dstrd, __u64 dstcookie);
-static void kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn);
-static void kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn);
-static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx);
+static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
+			     int resid, struct kib_rdma_desc *dstrd, __u64 dstcookie);
+static void kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn);
+static void kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn);
+static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx);
 
 static void
-kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
+kiblnd_tx_done(lnet_ni_t *ni, struct kib_tx *tx)
 {
 	lnet_msg_t *lntmsg[2];
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 	int rc;
 	int i;
 
@@ -97,10 +97,10 @@ kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
 void
 kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int status)
 {
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 
 	while (!list_empty(txlist)) {
-		tx = list_entry(txlist->next, kib_tx_t, tx_list);
+		tx = list_entry(txlist->next, struct kib_tx, tx_list);
 
 		list_del(&tx->tx_list);
 		/* complete now */
@@ -110,19 +110,19 @@ kiblnd_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int status)
 	}
 }
 
-static kib_tx_t *
+static struct kib_tx *
 kiblnd_get_idle_tx(lnet_ni_t *ni, lnet_nid_t target)
 {
-	kib_net_t *net = (kib_net_t *)ni->ni_data;
+	struct kib_net *net = (struct kib_net *)ni->ni_data;
 	struct list_head *node;
-	kib_tx_t *tx;
-	kib_tx_poolset_t *tps;
+	struct kib_tx *tx;
+	struct kib_tx_poolset *tps;
 
 	tps = net->ibn_tx_ps[lnet_cpt_of_nid(target)];
 	node = kiblnd_pool_alloc_node(&tps->tps_poolset);
 	if (!node)
 		return NULL;
-	tx = list_entry(node, kib_tx_t, tx_list);
+	tx = list_entry(node, struct kib_tx, tx_list);
 
 	LASSERT(!tx->tx_nwrq);
 	LASSERT(!tx->tx_queued);
@@ -138,9 +138,9 @@ kiblnd_get_idle_tx(lnet_ni_t *ni, lnet_nid_t target)
 }
 
 static void
-kiblnd_drop_rx(kib_rx_t *rx)
+kiblnd_drop_rx(struct kib_rx *rx)
 {
-	kib_conn_t *conn = rx->rx_conn;
+	struct kib_conn *conn = rx->rx_conn;
 	struct kib_sched_info *sched = conn->ibc_sched;
 	unsigned long flags;
 
@@ -153,10 +153,10 @@ kiblnd_drop_rx(kib_rx_t *rx)
 }
 
 int
-kiblnd_post_rx(kib_rx_t *rx, int credit)
+kiblnd_post_rx(struct kib_rx *rx, int credit)
 {
-	kib_conn_t *conn = rx->rx_conn;
-	kib_net_t *net = conn->ibc_peer->ibp_ni->ni_data;
+	struct kib_conn *conn = rx->rx_conn;
+	struct kib_net *net = conn->ibc_peer->ibp_ni->ni_data;
 	struct ib_recv_wr *bad_wrq = NULL;
 	struct ib_mr *mr = conn->ibc_hdev->ibh_mrs;
 	int rc;
@@ -223,13 +223,13 @@ out:
 	return rc;
 }
 
-static kib_tx_t *
-kiblnd_find_waiting_tx_locked(kib_conn_t *conn, int txtype, __u64 cookie)
+static struct kib_tx *
+kiblnd_find_waiting_tx_locked(struct kib_conn *conn, int txtype, __u64 cookie)
 {
 	struct list_head *tmp;
 
 	list_for_each(tmp, &conn->ibc_active_txs) {
-		kib_tx_t *tx = list_entry(tmp, kib_tx_t, tx_list);
+		struct kib_tx *tx = list_entry(tmp, struct kib_tx, tx_list);
 
 		LASSERT(!tx->tx_queued);
 		LASSERT(tx->tx_sending || tx->tx_waiting);
@@ -249,9 +249,9 @@ kiblnd_find_waiting_tx_locked(kib_conn_t *conn, int txtype, __u64 cookie)
 }
 
 static void
-kiblnd_handle_completion(kib_conn_t *conn, int txtype, int status, __u64 cookie)
+kiblnd_handle_completion(struct kib_conn *conn, int txtype, int status, __u64 cookie)
 {
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
 	int idle;
 
@@ -287,10 +287,10 @@ kiblnd_handle_completion(kib_conn_t *conn, int txtype, int status, __u64 cookie)
 }
 
 static void
-kiblnd_send_completion(kib_conn_t *conn, int type, int status, __u64 cookie)
+kiblnd_send_completion(struct kib_conn *conn, int type, int status, __u64 cookie)
 {
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
-	kib_tx_t *tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
+	struct kib_tx *tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
 
 	if (!tx) {
 		CERROR("Can't get tx for completion %x for %s\n",
@@ -300,19 +300,19 @@ kiblnd_send_completion(kib_conn_t *conn, int type, int status, __u64 cookie)
 
 	tx->tx_msg->ibm_u.completion.ibcm_status = status;
 	tx->tx_msg->ibm_u.completion.ibcm_cookie = cookie;
-	kiblnd_init_tx_msg(ni, tx, type, sizeof(kib_completion_msg_t));
+	kiblnd_init_tx_msg(ni, tx, type, sizeof(struct kib_completion_msg));
 
 	kiblnd_queue_tx(tx, conn);
 }
 
 static void
-kiblnd_handle_rx(kib_rx_t *rx)
+kiblnd_handle_rx(struct kib_rx *rx)
 {
-	kib_msg_t *msg = rx->rx_msg;
-	kib_conn_t *conn = rx->rx_conn;
+	struct kib_msg *msg = rx->rx_msg;
+	struct kib_conn *conn = rx->rx_conn;
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
 	int credits = msg->ibm_credits;
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 	int rc = 0;
 	int rc2;
 	int post_credit;
@@ -467,12 +467,12 @@ kiblnd_handle_rx(kib_rx_t *rx)
 }
 
 static void
-kiblnd_rx_complete(kib_rx_t *rx, int status, int nob)
+kiblnd_rx_complete(struct kib_rx *rx, int status, int nob)
 {
-	kib_msg_t *msg = rx->rx_msg;
-	kib_conn_t *conn = rx->rx_conn;
+	struct kib_msg *msg = rx->rx_msg;
+	struct kib_conn *conn = rx->rx_conn;
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 	int rc;
 	int err = -EIO;
 
@@ -561,10 +561,10 @@ kiblnd_kvaddr_to_page(unsigned long vaddr)
 }
 
 static int
-kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, __u32 nob)
+kiblnd_fmr_map_tx(struct kib_net *net, struct kib_tx *tx, struct kib_rdma_desc *rd, __u32 nob)
 {
-	kib_hca_dev_t *hdev;
-	kib_fmr_poolset_t *fps;
+	struct kib_hca_dev *hdev;
+	struct kib_fmr_poolset *fps;
 	int cpt;
 	int rc;
 
@@ -593,9 +593,9 @@ kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, __u32 nob)
 	return 0;
 }
 
-static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx)
+static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx)
 {
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 
 	LASSERT(net);
 
@@ -609,11 +609,11 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx)
 	}
 }
 
-static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
+static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
 			 int nfrags)
 {
-	kib_net_t *net = ni->ni_data;
-	kib_hca_dev_t *hdev = net->ibn_dev->ibd_hdev;
+	struct kib_net *net = ni->ni_data;
+	struct kib_hca_dev *hdev = net->ibn_dev->ibd_hdev;
 	struct ib_mr *mr    = NULL;
 	__u32 nob;
 	int i;
@@ -651,10 +651,10 @@ static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 }
 
 static int
-kiblnd_setup_rd_iov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
+kiblnd_setup_rd_iov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
 		    unsigned int niov, struct kvec *iov, int offset, int nob)
 {
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 	struct page *page;
 	struct scatterlist *sg;
 	unsigned long vaddr;
@@ -708,10 +708,10 @@ kiblnd_setup_rd_iov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 }
 
 static int
-kiblnd_setup_rd_kiov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
+kiblnd_setup_rd_kiov(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc *rd,
 		     int nkiov, lnet_kiov_t *kiov, int offset, int nob)
 {
-	kib_net_t *net = ni->ni_data;
+	struct kib_net *net = ni->ni_data;
 	struct scatterlist *sg;
 	int fragnob;
 
@@ -752,11 +752,11 @@ kiblnd_setup_rd_kiov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 }
 
 static int
-kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
+kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 	__must_hold(&conn->ibc_lock)
 {
-	kib_msg_t *msg = tx->tx_msg;
-	kib_peer_t *peer = conn->ibc_peer;
+	struct kib_msg *msg = tx->tx_msg;
+	struct kib_peer *peer = conn->ibc_peer;
 	struct lnet_ni *ni = peer->ibp_ni;
 	int ver = conn->ibc_version;
 	int rc;
@@ -909,11 +909,11 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 }
 
 static void
-kiblnd_check_sends(kib_conn_t *conn)
+kiblnd_check_sends(struct kib_conn *conn)
 {
 	int ver = conn->ibc_version;
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 
 	/* Don't send anything until after the connection is established */
 	if (conn->ibc_state < IBLND_CONN_ESTABLISHED) {
@@ -932,7 +932,7 @@ kiblnd_check_sends(kib_conn_t *conn)
 	while (conn->ibc_reserved_credits > 0 &&
 	       !list_empty(&conn->ibc_tx_queue_rsrvd)) {
 		tx = list_entry(conn->ibc_tx_queue_rsrvd.next,
-				kib_tx_t, tx_list);
+				struct kib_tx, tx_list);
 		list_del(&tx->tx_list);
 		list_add_tail(&tx->tx_list, &conn->ibc_tx_queue);
 		conn->ibc_reserved_credits--;
@@ -956,16 +956,16 @@ kiblnd_check_sends(kib_conn_t *conn)
 		if (!list_empty(&conn->ibc_tx_queue_nocred)) {
 			credit = 0;
 			tx = list_entry(conn->ibc_tx_queue_nocred.next,
-					kib_tx_t, tx_list);
+					struct kib_tx, tx_list);
 		} else if (!list_empty(&conn->ibc_tx_noops)) {
 			LASSERT(!IBLND_OOB_CAPABLE(ver));
 			credit = 1;
 			tx = list_entry(conn->ibc_tx_noops.next,
-					kib_tx_t, tx_list);
+					struct kib_tx, tx_list);
 		} else if (!list_empty(&conn->ibc_tx_queue)) {
 			credit = 1;
 			tx = list_entry(conn->ibc_tx_queue.next,
-					kib_tx_t, tx_list);
+					struct kib_tx, tx_list);
 		} else {
 			break;
 		}
@@ -978,10 +978,10 @@ kiblnd_check_sends(kib_conn_t *conn)
 }
 
 static void
-kiblnd_tx_complete(kib_tx_t *tx, int status)
+kiblnd_tx_complete(struct kib_tx *tx, int status)
 {
 	int failed = (status != IB_WC_SUCCESS);
-	kib_conn_t *conn = tx->tx_conn;
+	struct kib_conn *conn = tx->tx_conn;
 	int idle;
 
 	LASSERT(tx->tx_sending > 0);
@@ -1033,12 +1033,12 @@ kiblnd_tx_complete(kib_tx_t *tx, int status)
 }
 
 static void
-kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
+kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx, int type, int body_nob)
 {
-	kib_hca_dev_t *hdev = tx->tx_pool->tpo_hdev;
+	struct kib_hca_dev *hdev = tx->tx_pool->tpo_hdev;
 	struct ib_sge *sge = &tx->tx_sge[tx->tx_nwrq];
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[tx->tx_nwrq];
-	int nob = offsetof(kib_msg_t, ibm_u) + body_nob;
+	int nob = offsetof(struct kib_msg, ibm_u) + body_nob;
 	struct ib_mr *mr = hdev->ibh_mrs;
 
 	LASSERT(tx->tx_nwrq >= 0);
@@ -1065,11 +1065,11 @@ kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
 }
 
 static int
-kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
-		 int resid, kib_rdma_desc_t *dstrd, __u64 dstcookie)
+kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
+		 int resid, struct kib_rdma_desc *dstrd, __u64 dstcookie)
 {
-	kib_msg_t *ibmsg = tx->tx_msg;
-	kib_rdma_desc_t *srcrd = tx->tx_rd;
+	struct kib_msg *ibmsg = tx->tx_msg;
+	struct kib_rdma_desc *srcrd = tx->tx_rd;
 	struct ib_sge *sge = &tx->tx_sge[0];
 	struct ib_rdma_wr *wrq, *next;
 	int rc  = resid;
@@ -1143,13 +1143,13 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	ibmsg->ibm_u.completion.ibcm_status = rc;
 	ibmsg->ibm_u.completion.ibcm_cookie = dstcookie;
 	kiblnd_init_tx_msg(conn->ibc_peer->ibp_ni, tx,
-			   type, sizeof(kib_completion_msg_t));
+			   type, sizeof(struct kib_completion_msg));
 
 	return rc;
 }
 
 static void
-kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn)
+kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn)
 {
 	struct list_head *q;
 
@@ -1204,7 +1204,7 @@ kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn)
 }
 
 static void
-kiblnd_queue_tx(kib_tx_t *tx, kib_conn_t *conn)
+kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn)
 {
 	spin_lock(&conn->ibc_lock);
 	kiblnd_queue_tx_locked(tx, conn);
@@ -1251,11 +1251,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 }
 
 static void
-kiblnd_connect_peer(kib_peer_t *peer)
+kiblnd_connect_peer(struct kib_peer *peer)
 {
 	struct rdma_cm_id *cmid;
-	kib_dev_t *dev;
-	kib_net_t *net = peer->ibp_ni->ni_data;
+	struct kib_dev *dev;
+	struct kib_net *net = peer->ibp_ni->ni_data;
 	struct sockaddr_in srcaddr;
 	struct sockaddr_in dstaddr;
 	int rc;
@@ -1319,7 +1319,7 @@ kiblnd_connect_peer(kib_peer_t *peer)
 }
 
 bool
-kiblnd_reconnect_peer(kib_peer_t *peer)
+kiblnd_reconnect_peer(struct kib_peer *peer)
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	char *reason = NULL;
@@ -1369,11 +1369,11 @@ no_reconnect:
 }
 
 void
-kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
+kiblnd_launch_tx(lnet_ni_t *ni, struct kib_tx *tx, lnet_nid_t nid)
 {
-	kib_peer_t *peer;
-	kib_peer_t *peer2;
-	kib_conn_t *conn;
+	struct kib_peer *peer;
+	struct kib_peer *peer2;
+	struct kib_conn *conn;
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
 	unsigned long flags;
 	int rc;
@@ -1476,7 +1476,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	peer->ibp_connecting = 1;
 
 	/* always called with a ref on ni, which prevents ni being shutdown */
-	LASSERT(!((kib_net_t *)ni->ni_data)->ibn_shutdown);
+	LASSERT(!((struct kib_net *)ni->ni_data)->ibn_shutdown);
 
 	if (tx)
 		list_add_tail(&tx->tx_list, &peer->ibp_tx_queue);
@@ -1503,9 +1503,9 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	lnet_kiov_t *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
-	kib_msg_t *ibmsg;
-	kib_rdma_desc_t  *rd;
-	kib_tx_t *tx;
+	struct kib_msg *ibmsg;
+	struct kib_rdma_desc  *rd;
+	struct kib_tx *tx;
 	int nob;
 	int rc;
 
@@ -1536,7 +1536,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 			break;		  /* send IMMEDIATE */
 
 		/* is the REPLY message too small for RDMA? */
-		nob = offsetof(kib_msg_t, ibm_u.immediate.ibim_payload[lntmsg->msg_md->md_length]);
+		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[lntmsg->msg_md->md_length]);
 		if (nob <= IBLND_MSG_SIZE)
 			break;		  /* send IMMEDIATE */
 
@@ -1566,7 +1566,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 			return -EIO;
 		}
 
-		nob = offsetof(kib_get_msg_t, ibgm_rd.rd_frags[rd->rd_nfrags]);
+		nob = offsetof(struct kib_get_msg, ibgm_rd.rd_frags[rd->rd_nfrags]);
 		ibmsg->ibm_u.get.ibgm_cookie = tx->tx_cookie;
 		ibmsg->ibm_u.get.ibgm_hdr = *hdr;
 
@@ -1588,7 +1588,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	case LNET_MSG_REPLY:
 	case LNET_MSG_PUT:
 		/* Is the payload small enough not to need RDMA? */
-		nob = offsetof(kib_msg_t, ibm_u.immediate.ibim_payload[payload_nob]);
+		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[payload_nob]);
 		if (nob <= IBLND_MSG_SIZE)
 			break;		  /* send IMMEDIATE */
 
@@ -1618,7 +1618,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 		ibmsg = tx->tx_msg;
 		ibmsg->ibm_u.putreq.ibprm_hdr = *hdr;
 		ibmsg->ibm_u.putreq.ibprm_cookie = tx->tx_cookie;
-		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_REQ, sizeof(kib_putreq_msg_t));
+		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_REQ, sizeof(struct kib_putreq_msg));
 
 		tx->tx_lntmsg[0] = lntmsg;      /* finalise lntmsg on completion */
 		tx->tx_waiting = 1;	     /* waiting for PUT_{ACK,NAK} */
@@ -1628,7 +1628,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 
 	/* send IMMEDIATE */
 
-	LASSERT(offsetof(kib_msg_t, ibm_u.immediate.ibim_payload[payload_nob])
+	LASSERT(offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[payload_nob])
 		 <= IBLND_MSG_SIZE);
 
 	tx = kiblnd_get_idle_tx(ni, target.nid);
@@ -1643,16 +1643,16 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 
 	if (payload_kiov)
 		lnet_copy_kiov2flat(IBLND_MSG_SIZE, ibmsg,
-				    offsetof(kib_msg_t, ibm_u.immediate.ibim_payload),
+				    offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
 				    payload_niov, payload_kiov,
 				    payload_offset, payload_nob);
 	else
 		lnet_copy_iov2flat(IBLND_MSG_SIZE, ibmsg,
-				   offsetof(kib_msg_t, ibm_u.immediate.ibim_payload),
+				   offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
 				   payload_niov, payload_iov,
 				   payload_offset, payload_nob);
 
-	nob = offsetof(kib_immediate_msg_t, ibim_payload[payload_nob]);
+	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
 	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
 
 	tx->tx_lntmsg[0] = lntmsg;	      /* finalise lntmsg on completion */
@@ -1661,7 +1661,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 }
 
 static void
-kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
+kiblnd_reply(lnet_ni_t *ni, struct kib_rx *rx, lnet_msg_t *lntmsg)
 {
 	lnet_process_id_t target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
@@ -1669,7 +1669,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 	lnet_kiov_t *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
 	unsigned int nob = lntmsg->msg_len;
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 	int rc;
 
 	tx = kiblnd_get_idle_tx(ni, rx->rx_conn->ibc_peer->ibp_nid);
@@ -1726,10 +1726,10 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 	    unsigned int niov, struct kvec *iov, lnet_kiov_t *kiov,
 	    unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
-	kib_rx_t *rx = private;
-	kib_msg_t *rxmsg = rx->rx_msg;
-	kib_conn_t *conn = rx->rx_conn;
-	kib_tx_t *tx;
+	struct kib_rx *rx = private;
+	struct kib_msg *rxmsg = rx->rx_msg;
+	struct kib_conn *conn = rx->rx_conn;
+	struct kib_tx *tx;
 	int nob;
 	int post_credit = IBLND_POSTRX_PEER_CREDIT;
 	int rc = 0;
@@ -1744,7 +1744,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		LBUG();
 
 	case IBLND_MSG_IMMEDIATE:
-		nob = offsetof(kib_msg_t, ibm_u.immediate.ibim_payload[rlen]);
+		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[rlen]);
 		if (nob > rx->rx_nob) {
 			CERROR("Immediate message from %s too big: %d(%d)\n",
 			       libcfs_nid2str(rxmsg->ibm_u.immediate.ibim_hdr.src_nid),
@@ -1756,19 +1756,19 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		if (kiov)
 			lnet_copy_flat2kiov(niov, kiov, offset,
 					    IBLND_MSG_SIZE, rxmsg,
-					    offsetof(kib_msg_t, ibm_u.immediate.ibim_payload),
+					    offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
 					    mlen);
 		else
 			lnet_copy_flat2iov(niov, iov, offset,
 					   IBLND_MSG_SIZE, rxmsg,
-					   offsetof(kib_msg_t, ibm_u.immediate.ibim_payload),
+					   offsetof(struct kib_msg, ibm_u.immediate.ibim_payload),
 					   mlen);
 		lnet_finalize(ni, lntmsg, 0);
 		break;
 
 	case IBLND_MSG_PUT_REQ: {
-		kib_msg_t	*txmsg;
-		kib_rdma_desc_t *rd;
+		struct kib_msg	*txmsg;
+		struct kib_rdma_desc *rd;
 
 		if (!mlen) {
 			lnet_finalize(ni, lntmsg, 0);
@@ -1804,7 +1804,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 			break;
 		}
 
-		nob = offsetof(kib_putack_msg_t, ibpam_rd.rd_frags[rd->rd_nfrags]);
+		nob = offsetof(struct kib_putack_msg, ibpam_rd.rd_frags[rd->rd_nfrags]);
 		txmsg->ibm_u.putack.ibpam_src_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
 		txmsg->ibm_u.putack.ibpam_dst_cookie = tx->tx_cookie;
 
@@ -1855,7 +1855,7 @@ kiblnd_thread_fini(void)
 }
 
 static void
-kiblnd_peer_alive(kib_peer_t *peer)
+kiblnd_peer_alive(struct kib_peer *peer)
 {
 	/* This is racy, but everyone's only writing cfs_time_current() */
 	peer->ibp_last_alive = cfs_time_current();
@@ -1863,7 +1863,7 @@ kiblnd_peer_alive(kib_peer_t *peer)
 }
 
 static void
-kiblnd_peer_notify(kib_peer_t *peer)
+kiblnd_peer_notify(struct kib_peer *peer)
 {
 	int error = 0;
 	unsigned long last_alive = 0;
@@ -1886,7 +1886,7 @@ kiblnd_peer_notify(kib_peer_t *peer)
 }
 
 void
-kiblnd_close_conn_locked(kib_conn_t *conn, int error)
+kiblnd_close_conn_locked(struct kib_conn *conn, int error)
 {
 	/*
 	 * This just does the immediate housekeeping. 'error' is zero for a
@@ -1896,8 +1896,8 @@ kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 	 * already dealing with it (either to set it up or tear it down).
 	 * Caller holds kib_global_lock exclusively in irq context
 	 */
-	kib_peer_t *peer = conn->ibc_peer;
-	kib_dev_t *dev;
+	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_dev *dev;
 	unsigned long flags;
 
 	LASSERT(error || conn->ibc_state >= IBLND_CONN_ESTABLISHED);
@@ -1926,7 +1926,7 @@ kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 		        list_empty(&conn->ibc_active_txs) ? "" : "(waiting)");
 	}
 
-	dev = ((kib_net_t *)peer->ibp_ni->ni_data)->ibn_dev;
+	dev = ((struct kib_net *)peer->ibp_ni->ni_data)->ibn_dev;
 	list_del(&conn->ibc_list);
 	/* connd (see below) takes over ibc_list's ref */
 
@@ -1956,7 +1956,7 @@ kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 }
 
 void
-kiblnd_close_conn(kib_conn_t *conn, int error)
+kiblnd_close_conn(struct kib_conn *conn, int error)
 {
 	unsigned long flags;
 
@@ -1968,11 +1968,11 @@ kiblnd_close_conn(kib_conn_t *conn, int error)
 }
 
 static void
-kiblnd_handle_early_rxs(kib_conn_t *conn)
+kiblnd_handle_early_rxs(struct kib_conn *conn)
 {
 	unsigned long flags;
-	kib_rx_t *rx;
-	kib_rx_t *tmp;
+	struct kib_rx *rx;
+	struct kib_rx *tmp;
 
 	LASSERT(!in_interrupt());
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
@@ -1990,17 +1990,17 @@ kiblnd_handle_early_rxs(kib_conn_t *conn)
 }
 
 static void
-kiblnd_abort_txs(kib_conn_t *conn, struct list_head *txs)
+kiblnd_abort_txs(struct kib_conn *conn, struct list_head *txs)
 {
 	LIST_HEAD(zombies);
 	struct list_head *tmp;
 	struct list_head *nxt;
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 
 	spin_lock(&conn->ibc_lock);
 
 	list_for_each_safe(tmp, nxt, txs) {
-		tx = list_entry(tmp, kib_tx_t, tx_list);
+		tx = list_entry(tmp, struct kib_tx, tx_list);
 
 		if (txs == &conn->ibc_active_txs) {
 			LASSERT(!tx->tx_queued);
@@ -2025,7 +2025,7 @@ kiblnd_abort_txs(kib_conn_t *conn, struct list_head *txs)
 }
 
 static void
-kiblnd_finalise_conn(kib_conn_t *conn)
+kiblnd_finalise_conn(struct kib_conn *conn)
 {
 	LASSERT(!in_interrupt());
 	LASSERT(conn->ibc_state > IBLND_CONN_INIT);
@@ -2053,7 +2053,7 @@ kiblnd_finalise_conn(kib_conn_t *conn)
 }
 
 static void
-kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
+kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error)
 {
 	LIST_HEAD(zombies);
 	unsigned long flags;
@@ -2107,11 +2107,11 @@ kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 }
 
 static void
-kiblnd_connreq_done(kib_conn_t *conn, int status)
+kiblnd_connreq_done(struct kib_conn *conn, int status)
 {
-	kib_peer_t *peer = conn->ibc_peer;
-	kib_tx_t *tx;
-	kib_tx_t *tmp;
+	struct kib_peer *peer = conn->ibc_peer;
+	struct kib_tx *tx;
+	struct kib_tx *tmp;
 	struct list_head txs;
 	unsigned long flags;
 	int active;
@@ -2217,7 +2217,7 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 }
 
 static void
-kiblnd_reject(struct rdma_cm_id *cmid, kib_rej_t *rej)
+kiblnd_reject(struct rdma_cm_id *cmid, struct kib_rej *rej)
 {
 	int rc;
 
@@ -2231,17 +2231,17 @@ static int
 kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 {
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
-	kib_msg_t *reqmsg = priv;
-	kib_msg_t *ackmsg;
-	kib_dev_t *ibdev;
-	kib_peer_t *peer;
-	kib_peer_t *peer2;
-	kib_conn_t *conn;
+	struct kib_msg *reqmsg = priv;
+	struct kib_msg *ackmsg;
+	struct kib_dev *ibdev;
+	struct kib_peer *peer;
+	struct kib_peer *peer2;
+	struct kib_conn *conn;
 	lnet_ni_t *ni  = NULL;
-	kib_net_t *net = NULL;
+	struct kib_net *net = NULL;
 	lnet_nid_t nid;
 	struct rdma_conn_param cp;
-	kib_rej_t rej;
+	struct kib_rej rej;
 	int version = IBLND_MSG_VERSION;
 	unsigned long flags;
 	int rc;
@@ -2250,7 +2250,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	LASSERT(!in_interrupt());
 
 	/* cmid inherits 'context' from the corresponding listener id */
-	ibdev = (kib_dev_t *)cmid->context;
+	ibdev = (struct kib_dev *)cmid->context;
 	LASSERT(ibdev);
 
 	memset(&rej, 0, sizeof(rej));
@@ -2268,7 +2268,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	if (priv_nob < offsetof(kib_msg_t, ibm_type)) {
+	if (priv_nob < offsetof(struct kib_msg, ibm_type)) {
 		CERROR("Short connection request\n");
 		goto failed;
 	}
@@ -2303,7 +2303,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	ni = lnet_net2ni(LNET_NIDNET(reqmsg->ibm_dstnid));
 
 	if (ni) {
-		net = (kib_net_t *)ni->ni_data;
+		net = (struct kib_net *)ni->ni_data;
 		rej.ibr_incarnation = net->ibn_incarnation;
 	}
 
@@ -2541,11 +2541,11 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 }
 
 static void
-kiblnd_check_reconnect(kib_conn_t *conn, int version,
-		       __u64 incarnation, int why, kib_connparams_t *cp)
+kiblnd_check_reconnect(struct kib_conn *conn, int version,
+		       __u64 incarnation, int why, struct kib_connparams *cp)
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	kib_peer_t *peer = conn->ibc_peer;
+	struct kib_peer *peer = conn->ibc_peer;
 	char *reason;
 	int msg_size = IBLND_MSG_SIZE;
 	int frag_num = -1;
@@ -2654,9 +2654,9 @@ out:
 }
 
 static void
-kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
+kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 {
-	kib_peer_t *peer = conn->ibc_peer;
+	struct kib_peer *peer = conn->ibc_peer;
 
 	LASSERT(!in_interrupt());
 	LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
@@ -2674,9 +2674,9 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 		break;
 
 	case IB_CM_REJ_CONSUMER_DEFINED:
-		if (priv_nob >= offsetof(kib_rej_t, ibr_padding)) {
-			kib_rej_t *rej = priv;
-			kib_connparams_t *cp = NULL;
+		if (priv_nob >= offsetof(struct kib_rej, ibr_padding)) {
+			struct kib_rej *rej = priv;
+			struct kib_connparams *cp = NULL;
 			int flip = 0;
 			__u64 incarnation = -1;
 
@@ -2699,7 +2699,7 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 				flip = 1;
 			}
 
-			if (priv_nob >= sizeof(kib_rej_t) &&
+			if (priv_nob >= sizeof(struct kib_rej) &&
 			    rej->ibr_version > IBLND_MSG_VERSION_1) {
 				/*
 				 * priv_nob is always 148 in current version
@@ -2782,12 +2782,12 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 }
 
 static void
-kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
+kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 {
-	kib_peer_t *peer = conn->ibc_peer;
+	struct kib_peer *peer = conn->ibc_peer;
 	lnet_ni_t *ni = peer->ibp_ni;
-	kib_net_t *net = ni->ni_data;
-	kib_msg_t *msg = priv;
+	struct kib_net *net = ni->ni_data;
+	struct kib_msg *msg = priv;
 	int ver = conn->ibc_version;
 	int rc = kiblnd_unpack_msg(msg, priv_nob);
 	unsigned long flags;
@@ -2884,9 +2884,9 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 static int
 kiblnd_active_connect(struct rdma_cm_id *cmid)
 {
-	kib_peer_t *peer = (kib_peer_t *)cmid->context;
-	kib_conn_t *conn;
-	kib_msg_t *msg;
+	struct kib_peer *peer = (struct kib_peer *)cmid->context;
+	struct kib_conn *conn;
+	struct kib_msg *msg;
 	struct rdma_conn_param cp;
 	int version;
 	__u64 incarnation;
@@ -2951,8 +2951,8 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 int
 kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 {
-	kib_peer_t *peer;
-	kib_conn_t *conn;
+	struct kib_peer *peer;
+	struct kib_conn *conn;
 	int rc;
 
 	switch (event->event) {
@@ -2970,7 +2970,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return rc;
 
 	case RDMA_CM_EVENT_ADDR_ERROR:
-		peer = (kib_peer_t *)cmid->context;
+		peer = (struct kib_peer *)cmid->context;
 		CNETERR("%s: ADDR ERROR %d\n",
 		        libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
@@ -2978,7 +2978,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return -EHOSTUNREACH;      /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
-		peer = (kib_peer_t *)cmid->context;
+		peer = (struct kib_peer *)cmid->context;
 
 		CDEBUG(D_NET, "%s Addr resolved: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), event->status);
@@ -3001,7 +3001,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return rc;		      /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_ERROR:
-		peer = (kib_peer_t *)cmid->context;
+		peer = (struct kib_peer *)cmid->context;
 		CNETERR("%s: ROUTE ERROR %d\n",
 			libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
@@ -3009,7 +3009,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return -EHOSTUNREACH;	   /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
-		peer = (kib_peer_t *)cmid->context;
+		peer = (struct kib_peer *)cmid->context;
 		CDEBUG(D_NET, "%s Route resolved: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), event->status);
 
@@ -3023,7 +3023,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return event->status;	   /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_UNREACHABLE:
-		conn = (kib_conn_t *)cmid->context;
+		conn = (struct kib_conn *)cmid->context;
 		LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
 			conn->ibc_state == IBLND_CONN_PASSIVE_WAIT);
 		CNETERR("%s: UNREACHABLE %d\n",
@@ -3033,7 +3033,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return 0;
 
 	case RDMA_CM_EVENT_CONNECT_ERROR:
-		conn = (kib_conn_t *)cmid->context;
+		conn = (struct kib_conn *)cmid->context;
 		LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
 			conn->ibc_state == IBLND_CONN_PASSIVE_WAIT);
 		CNETERR("%s: CONNECT ERROR %d\n",
@@ -3043,7 +3043,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return 0;
 
 	case RDMA_CM_EVENT_REJECTED:
-		conn = (kib_conn_t *)cmid->context;
+		conn = (struct kib_conn *)cmid->context;
 		switch (conn->ibc_state) {
 		default:
 			LBUG();
@@ -3065,7 +3065,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return 0;
 
 	case RDMA_CM_EVENT_ESTABLISHED:
-		conn = (kib_conn_t *)cmid->context;
+		conn = (struct kib_conn *)cmid->context;
 		switch (conn->ibc_state) {
 		default:
 			LBUG();
@@ -3091,7 +3091,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		CDEBUG(D_NET, "Ignore TIMEWAIT_EXIT event\n");
 		return 0;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		conn = (kib_conn_t *)cmid->context;
+		conn = (struct kib_conn *)cmid->context;
 		if (conn->ibc_state < IBLND_CONN_ESTABLISHED) {
 			CERROR("%s DISCONNECTED\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid));
@@ -3120,13 +3120,13 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 }
 
 static int
-kiblnd_check_txs_locked(kib_conn_t *conn, struct list_head *txs)
+kiblnd_check_txs_locked(struct kib_conn *conn, struct list_head *txs)
 {
-	kib_tx_t *tx;
+	struct kib_tx *tx;
 	struct list_head *ttmp;
 
 	list_for_each(ttmp, txs) {
-		tx = list_entry(ttmp, kib_tx_t, tx_list);
+		tx = list_entry(ttmp, struct kib_tx, tx_list);
 
 		if (txs != &conn->ibc_active_txs) {
 			LASSERT(tx->tx_queued);
@@ -3147,7 +3147,7 @@ kiblnd_check_txs_locked(kib_conn_t *conn, struct list_head *txs)
 }
 
 static int
-kiblnd_conn_timed_out_locked(kib_conn_t *conn)
+kiblnd_conn_timed_out_locked(struct kib_conn *conn)
 {
 	return  kiblnd_check_txs_locked(conn, &conn->ibc_tx_queue) ||
 		kiblnd_check_txs_locked(conn, &conn->ibc_tx_noops) ||
@@ -3163,10 +3163,10 @@ kiblnd_check_conns(int idx)
 	LIST_HEAD(checksends);
 	struct list_head *peers = &kiblnd_data.kib_peers[idx];
 	struct list_head *ptmp;
-	kib_peer_t *peer;
-	kib_conn_t *conn;
-	kib_conn_t *temp;
-	kib_conn_t *tmp;
+	struct kib_peer *peer;
+	struct kib_conn *conn;
+	struct kib_conn *temp;
+	struct kib_conn *tmp;
 	struct list_head *ctmp;
 	unsigned long flags;
 
@@ -3178,13 +3178,13 @@ kiblnd_check_conns(int idx)
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	list_for_each(ptmp, peers) {
-		peer = list_entry(ptmp, kib_peer_t, ibp_list);
+		peer = list_entry(ptmp, struct kib_peer, ibp_list);
 
 		list_for_each(ctmp, &peer->ibp_conns) {
 			int timedout;
 			int sendnoop;
 
-			conn = list_entry(ctmp, kib_conn_t, ibc_list);
+			conn = list_entry(ctmp, struct kib_conn, ibc_list);
 
 			LASSERT(conn->ibc_state == IBLND_CONN_ESTABLISHED);
 
@@ -3242,7 +3242,7 @@ kiblnd_check_conns(int idx)
 }
 
 static void
-kiblnd_disconnect_conn(kib_conn_t *conn)
+kiblnd_disconnect_conn(struct kib_conn *conn)
 {
 	LASSERT(!in_interrupt());
 	LASSERT(current == kiblnd_data.kib_connd);
@@ -3271,7 +3271,7 @@ kiblnd_connd(void *arg)
 	spinlock_t *lock= &kiblnd_data.kib_connd_lock;
 	wait_queue_t wait;
 	unsigned long flags;
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 	int timeout;
 	int i;
 	int dropped_lock;
@@ -3291,10 +3291,10 @@ kiblnd_connd(void *arg)
 		dropped_lock = 0;
 
 		if (!list_empty(&kiblnd_data.kib_connd_zombies)) {
-			kib_peer_t *peer = NULL;
+			struct kib_peer *peer = NULL;
 
 			conn = list_entry(kiblnd_data.kib_connd_zombies.next,
-					  kib_conn_t, ibc_list);
+					  struct kib_conn, ibc_list);
 			list_del(&conn->ibc_list);
 			if (conn->ibc_reconnect) {
 				peer = conn->ibc_peer;
@@ -3321,7 +3321,7 @@ kiblnd_connd(void *arg)
 
 		if (!list_empty(&kiblnd_data.kib_connd_conns)) {
 			conn = list_entry(kiblnd_data.kib_connd_conns.next,
-					  kib_conn_t, ibc_list);
+					  struct kib_conn, ibc_list);
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(lock, flags);
@@ -3345,7 +3345,7 @@ kiblnd_connd(void *arg)
 				break;
 
 			conn = list_entry(kiblnd_data.kib_reconn_list.next,
-					  kib_conn_t, ibc_list);
+					  struct kib_conn, ibc_list);
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(lock, flags);
@@ -3416,7 +3416,7 @@ kiblnd_connd(void *arg)
 void
 kiblnd_qp_event(struct ib_event *event, void *arg)
 {
-	kib_conn_t *conn = arg;
+	struct kib_conn *conn = arg;
 
 	switch (event->event) {
 	case IB_EVENT_COMM_EST:
@@ -3478,7 +3478,7 @@ kiblnd_cq_completion(struct ib_cq *cq, void *arg)
 	 * occurred.  But in this case, !ibc_nrx && !ibc_nsends_posted
 	 * and this CQ is about to be destroyed so I NOOP.
 	 */
-	kib_conn_t *conn = arg;
+	struct kib_conn *conn = arg;
 	struct kib_sched_info *sched = conn->ibc_sched;
 	unsigned long flags;
 
@@ -3505,7 +3505,7 @@ kiblnd_cq_completion(struct ib_cq *cq, void *arg)
 void
 kiblnd_cq_event(struct ib_event *event, void *arg)
 {
-	kib_conn_t *conn = arg;
+	struct kib_conn *conn = arg;
 
 	CERROR("%s: async CQ event type %d\n",
 	       libcfs_nid2str(conn->ibc_peer->ibp_nid), event->event);
@@ -3516,7 +3516,7 @@ kiblnd_scheduler(void *arg)
 {
 	long id = (long)arg;
 	struct kib_sched_info *sched;
-	kib_conn_t *conn;
+	struct kib_conn *conn;
 	wait_queue_t wait;
 	unsigned long flags;
 	struct ib_wc wc;
@@ -3551,7 +3551,7 @@ kiblnd_scheduler(void *arg)
 		did_something = 0;
 
 		if (!list_empty(&sched->ibs_conns)) {
-			conn = list_entry(sched->ibs_conns.next, kib_conn_t,
+			conn = list_entry(sched->ibs_conns.next, struct kib_conn,
 					  ibc_sched_list);
 			/* take over kib_sched_conns' ref on conn... */
 			LASSERT(conn->ibc_scheduled);
@@ -3651,7 +3651,7 @@ int
 kiblnd_failover_thread(void *arg)
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
-	kib_dev_t *dev;
+	struct kib_dev *dev;
 	wait_queue_t wait;
 	unsigned long flags;
 	int rc;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index f8fdd4a..fdc2f3b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -145,7 +145,7 @@ static int use_privileged_port = 1;
 module_param(use_privileged_port, int, 0644);
 MODULE_PARM_DESC(use_privileged_port, "use privileged port when initiating connection");
 
-kib_tunables_t kiblnd_tunables = {
+struct kib_tunables kiblnd_tunables = {
 	.kib_dev_failover      = &dev_failover,
 	.kib_service           = &service,
 	.kib_cksum             = &cksum,
-- 
1.7.1
