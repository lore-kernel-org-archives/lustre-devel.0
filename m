From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:08 -0500
Subject: [lustre-devel] [PATCH 10/11] staging: lustre: fix all NULL
	comparisons in LNet layer
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This removes every instance of checking a variable against
NULL in the LNet source code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   12 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  208 ++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  142 +++++++-------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  122 ++++++------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   82 ++++----
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   28 ++--
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   46 +++---
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   16 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   78 ++++----
 drivers/staging/lustre/lnet/lnet/config.c          |   83 ++++----
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   18 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   10 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   16 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  142 +++++++-------
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   20 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   20 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   16 +-
 drivers/staging/lustre/lnet/lnet/lo.c              |    8 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   48 +++---
 drivers/staging/lustre/lnet/lnet/peer.c            |   20 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   68 ++++----
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   43 ++--
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   22 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |  157 ++++++++--------
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   36 ++--
 drivers/staging/lustre/lnet/selftest/console.c     |   64 +++---
 drivers/staging/lustre/lnet/selftest/framework.c   |  108 +++++-----
 drivers/staging/lustre/lnet/selftest/module.c      |    4 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c   |    8 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   47 +++---
 drivers/staging/lustre/lnet/selftest/selftest.h    |    4 +-
 drivers/staging/lustre/lnet/selftest/timer.c       |    2 +-
 32 files changed, 846 insertions(+), 852 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index b8be9b6..618126b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -197,7 +197,7 @@ lnet_md_alloc(lnet_md_t *umd)
 
 	LIBCFS_ALLOC(md, size);
 
-	if (md != NULL) {
+	if (md) {
 		/* Set here in case of early free */
 		md->md_options = umd->options;
 		md->md_niov = niov;
@@ -267,7 +267,7 @@ lnet_res_lh_invalidate(lnet_libhandle_t *lh)
 static inline void
 lnet_eq2handle(lnet_handle_eq_t *handle, lnet_eq_t *eq)
 {
-	if (eq == NULL) {
+	if (!eq) {
 		LNetInvalidateHandle(handle);
 		return;
 	}
@@ -281,7 +281,7 @@ lnet_handle2eq(lnet_handle_eq_t *handle)
 	lnet_libhandle_t *lh;
 
 	lh = lnet_res_lh_lookup(&the_lnet.ln_eq_container, handle->cookie);
-	if (lh == NULL)
+	if (!lh)
 		return NULL;
 
 	return lh_entry(lh, lnet_eq_t, eq_lh);
@@ -303,7 +303,7 @@ lnet_handle2md(lnet_handle_md_t *handle)
 	cpt = lnet_cpt_of_cookie(handle->cookie);
 	lh = lnet_res_lh_lookup(the_lnet.ln_md_containers[cpt],
 				handle->cookie);
-	if (lh == NULL)
+	if (!lh)
 		return NULL;
 
 	return lh_entry(lh, lnet_libmd_t, md_lh);
@@ -322,7 +322,7 @@ lnet_wire_handle2md(lnet_handle_wire_t *wh)
 	cpt = lnet_cpt_of_cookie(wh->wh_object_cookie);
 	lh = lnet_res_lh_lookup(the_lnet.ln_md_containers[cpt],
 				wh->wh_object_cookie);
-	if (lh == NULL)
+	if (!lh)
 		return NULL;
 
 	return lh_entry(lh, lnet_libmd_t, md_lh);
@@ -344,7 +344,7 @@ lnet_handle2me(lnet_handle_me_t *handle)
 	cpt = lnet_cpt_of_cookie(handle->cookie);
 	lh = lnet_res_lh_lookup(the_lnet.ln_me_containers[cpt],
 				handle->cookie);
-	if (lh == NULL)
+	if (!lh)
 		return NULL;
 
 	return lh_entry(lh, lnet_me_t, me_lh);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index db551e4..a3d654a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -330,11 +330,11 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 	int cpt = lnet_cpt_of_nid(nid);
 	unsigned long flags;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(nid != LNET_NID_ANY);
 
 	LIBCFS_CPT_ALLOC(peer, lnet_cpt_table(), cpt, sizeof(*peer));
-	if (peer == NULL) {
+	if (!peer) {
 		CERROR("Cannot allocate peer\n");
 		return -ENOMEM;
 	}
@@ -369,7 +369,7 @@ void kiblnd_destroy_peer(kib_peer_t *peer)
 {
 	kib_net_t *net = peer->ibp_ni->ni_data;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(atomic_read(&peer->ibp_refcount) == 0);
 	LASSERT(!kiblnd_peer_active(peer));
 	LASSERT(peer->ibp_connecting == 0);
@@ -604,7 +604,7 @@ static void kiblnd_setup_mtu_locked(struct rdma_cm_id *cmid)
 	int mtu;
 
 	/* XXX There is no path record for iWARP, set by netdev->change_mtu? */
-	if (cmid->route.path_rec == NULL)
+	if (!cmid->route.path_rec)
 		return;
 
 	mtu = kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu);
@@ -626,7 +626,7 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 		return 0;
 
 	mask = cfs_cpt_cpumask(lnet_cpt_table(), cpt);
-	if (mask == NULL)
+	if (!mask)
 		return 0;
 
 	/* hash NID to CPU id in this partition... */
@@ -665,7 +665,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	int rc;
 	int i;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(!in_interrupt());
 
 	dev = net->ibn_dev;
@@ -677,14 +677,14 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	LIBCFS_CPT_ALLOC(init_qp_attr, lnet_cpt_table(), cpt,
 			 sizeof(*init_qp_attr));
-	if (init_qp_attr == NULL) {
+	if (!init_qp_attr) {
 		CERROR("Can't allocate qp_attr for %s\n",
 		       libcfs_nid2str(peer->ibp_nid));
 		goto failed_0;
 	}
 
 	LIBCFS_CPT_ALLOC(conn, lnet_cpt_table(), cpt, sizeof(*conn));
-	if (conn == NULL) {
+	if (!conn) {
 		CERROR("Can't allocate connection for %s\n",
 		       libcfs_nid2str(peer->ibp_nid));
 		goto failed_1;
@@ -706,7 +706,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	LIBCFS_CPT_ALLOC(conn->ibc_connvars, lnet_cpt_table(), cpt,
 			 sizeof(*conn->ibc_connvars));
-	if (conn->ibc_connvars == NULL) {
+	if (!conn->ibc_connvars) {
 		CERROR("Can't allocate in-progress connection state\n");
 		goto failed_2;
 	}
@@ -741,7 +741,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	LIBCFS_CPT_ALLOC(conn->ibc_rxs, lnet_cpt_table(), cpt,
 			 IBLND_RX_MSGS(version) * sizeof(kib_rx_t));
-	if (conn->ibc_rxs == NULL) {
+	if (!conn->ibc_rxs) {
 		CERROR("Cannot allocate RX buffers\n");
 		goto failed_2;
 	}
@@ -874,7 +874,7 @@ void kiblnd_destroy_conn(kib_conn_t *conn)
 
 	case IBLND_CONN_DISCONNECTED:
 		/* connvars should have been freed already */
-		LASSERT(conn->ibc_connvars == NULL);
+		LASSERT(!conn->ibc_connvars);
 		break;
 
 	case IBLND_CONN_INIT:
@@ -882,28 +882,28 @@ void kiblnd_destroy_conn(kib_conn_t *conn)
 	}
 
 	/* conn->ibc_cmid might be destroyed by CM already */
-	if (cmid != NULL && cmid->qp != NULL)
+	if (cmid && cmid->qp)
 		rdma_destroy_qp(cmid);
 
-	if (conn->ibc_cq != NULL) {
+	if (conn->ibc_cq) {
 		rc = ib_destroy_cq(conn->ibc_cq);
 		if (rc != 0)
 			CWARN("Error destroying CQ: %d\n", rc);
 	}
 
-	if (conn->ibc_rx_pages != NULL)
+	if (conn->ibc_rx_pages)
 		kiblnd_unmap_rx_descs(conn);
 
-	if (conn->ibc_rxs != NULL) {
+	if (conn->ibc_rxs) {
 		LIBCFS_FREE(conn->ibc_rxs,
 			    IBLND_RX_MSGS(conn->ibc_version)
 			      * sizeof(kib_rx_t));
 	}
 
-	if (conn->ibc_connvars != NULL)
+	if (conn->ibc_connvars)
 		LIBCFS_FREE(conn->ibc_connvars, sizeof(*conn->ibc_connvars));
 
-	if (conn->ibc_hdev != NULL)
+	if (conn->ibc_hdev)
 		kiblnd_hdev_decref(conn->ibc_hdev);
 
 	/* See CAVEAT EMPTOR above in kiblnd_create_conn */
@@ -1040,14 +1040,14 @@ int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 
 		rc = 0;
 		conn = kiblnd_get_conn_by_idx(ni, data->ioc_count);
-		if (conn == NULL) {
+		if (!conn) {
 			rc = -ENOENT;
 			break;
 		}
 
-		LASSERT(conn->ibc_cmid != NULL);
+		LASSERT(conn->ibc_cmid);
 		data->ioc_nid = conn->ibc_peer->ibp_nid;
-		if (conn->ibc_cmid->route.path_rec == NULL)
+		if (!conn->ibc_cmid->route.path_rec)
 			data->ioc_u32[0] = 0; /* iWarp has no path MTU */
 		else
 			data->ioc_u32[0] =
@@ -1078,7 +1078,7 @@ void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	read_lock_irqsave(glock, flags);
 
 	peer = kiblnd_find_peer_locked(nid);
-	if (peer != NULL) {
+	if (peer) {
 		LASSERT(peer->ibp_connecting > 0 || /* creating conns */
 			 peer->ibp_accepting > 0 ||
 			 !list_empty(&peer->ibp_conns));  /* active conn */
@@ -1094,7 +1094,7 @@ void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	 * peer is not persistent in hash, trigger peer creation
 	 * and connection establishment with a NULL tx
 	 */
-	if (peer == NULL)
+	if (!peer)
 		kiblnd_launch_tx(ni, NULL, nid);
 
 	CDEBUG(D_NET, "Peer %s %p, alive %ld secs ago\n",
@@ -1108,7 +1108,7 @@ void kiblnd_free_pages(kib_pages_t *p)
 	int i;
 
 	for (i = 0; i < npages; i++) {
-		if (p->ibp_pages[i] != NULL)
+		if (p->ibp_pages[i])
 			__free_page(p->ibp_pages[i]);
 	}
 
@@ -1122,7 +1122,7 @@ int kiblnd_alloc_pages(kib_pages_t **pp, int cpt, int npages)
 
 	LIBCFS_CPT_ALLOC(p, lnet_cpt_table(), cpt,
 			 offsetof(kib_pages_t, ibp_pages[npages]));
-	if (p == NULL) {
+	if (!p) {
 		CERROR("Can't allocate descriptor for %d pages\n", npages);
 		return -ENOMEM;
 	}
@@ -1134,7 +1134,7 @@ int kiblnd_alloc_pages(kib_pages_t **pp, int cpt, int npages)
 		p->ibp_pages[i] = alloc_pages_node(
 				    cfs_cpt_spread_node(lnet_cpt_table(), cpt),
 				    GFP_NOFS, 0);
-		if (p->ibp_pages[i] == NULL) {
+		if (!p->ibp_pages[i]) {
 			CERROR("Can't allocate page %d of %d\n", i, npages);
 			kiblnd_free_pages(p);
 			return -ENOMEM;
@@ -1150,8 +1150,8 @@ void kiblnd_unmap_rx_descs(kib_conn_t *conn)
 	kib_rx_t *rx;
 	int i;
 
-	LASSERT(conn->ibc_rxs != NULL);
-	LASSERT(conn->ibc_hdev != NULL);
+	LASSERT(conn->ibc_rxs);
+	LASSERT(conn->ibc_hdev);
 
 	for (i = 0; i < IBLND_RX_MSGS(conn->ibc_version); i++) {
 		rx = &conn->ibc_rxs[i];
@@ -1215,7 +1215,7 @@ static void kiblnd_unmap_tx_pool(kib_tx_pool_t *tpo)
 
 	LASSERT(tpo->tpo_pool.po_allocated == 0);
 
-	if (hdev == NULL)
+	if (!hdev)
 		return;
 
 	for (i = 0; i < tpo->tpo_pool.po_size; i++) {
@@ -1267,7 +1267,7 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 	int ipage;
 	int i;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 
 	dev = net->ibn_dev;
 
@@ -1310,7 +1310,7 @@ struct ib_mr *kiblnd_find_dma_mr(kib_hca_dev_t *hdev, __u64 addr, __u64 size)
 {
 	__u64 index;
 
-	LASSERT(hdev->ibh_mrs[0] != NULL);
+	LASSERT(hdev->ibh_mrs[0]);
 
 	if (hdev->ibh_nmrs == 1)
 		return hdev->ibh_mrs[0];
@@ -1330,7 +1330,7 @@ struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd)
 	struct ib_mr *mr;
 	int i;
 
-	LASSERT(hdev->ibh_mrs[0] != NULL);
+	LASSERT(hdev->ibh_mrs[0]);
 
 	if (*kiblnd_tunables.kib_map_on_demand > 0 &&
 	    *kiblnd_tunables.kib_map_on_demand <= rd->rd_nfrags)
@@ -1344,10 +1344,10 @@ struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd)
 		mr = kiblnd_find_dma_mr(hdev,
 					rd->rd_frags[i].rf_addr,
 					rd->rd_frags[i].rf_nob);
-		if (prev_mr == NULL)
+		if (!prev_mr)
 			prev_mr = mr;
 
-		if (mr == NULL || prev_mr != mr) {
+		if (!mr || prev_mr != mr) {
 			/* Can't covered by one single MR */
 			mr = NULL;
 			break;
@@ -1361,10 +1361,10 @@ static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *pool)
 {
 	LASSERT(pool->fpo_map_count == 0);
 
-	if (pool->fpo_fmr_pool != NULL)
+	if (pool->fpo_fmr_pool)
 		ib_destroy_fmr_pool(pool->fpo_fmr_pool);
 
-	if (pool->fpo_hdev != NULL)
+	if (pool->fpo_hdev)
 		kiblnd_hdev_decref(pool->fpo_hdev);
 
 	LIBCFS_FREE(pool, sizeof(*pool));
@@ -1414,7 +1414,7 @@ static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
 	int rc;
 
 	LIBCFS_CPT_ALLOC(fpo, lnet_cpt_table(), fps->fps_cpt, sizeof(*fpo));
-	if (fpo == NULL)
+	if (!fpo)
 		return -ENOMEM;
 
 	fpo->fpo_hdev = kiblnd_current_hdev(dev);
@@ -1439,7 +1439,7 @@ static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
 static void kiblnd_fail_fmr_poolset(kib_fmr_poolset_t *fps,
 				    struct list_head *zombies)
 {
-	if (fps->fps_net == NULL) /* intialized? */
+	if (!fps->fps_net) /* intialized? */
 		return;
 
 	spin_lock(&fps->fps_lock);
@@ -1460,7 +1460,7 @@ static void kiblnd_fail_fmr_poolset(kib_fmr_poolset_t *fps,
 
 static void kiblnd_fini_fmr_poolset(kib_fmr_poolset_t *fps)
 {
-	if (fps->fps_net != NULL) { /* initialized? */
+	if (fps->fps_net) { /* initialized? */
 		kiblnd_destroy_fmr_pool_list(&fps->fps_failed_pool_list);
 		kiblnd_destroy_fmr_pool_list(&fps->fps_pool_list);
 	}
@@ -1634,14 +1634,14 @@ static void kiblnd_destroy_pool_list(struct list_head *head)
 		pool = list_entry(head->next, kib_pool_t, po_list);
 		list_del(&pool->po_list);
 
-		LASSERT(pool->po_owner != NULL);
+		LASSERT(pool->po_owner);
 		pool->po_owner->ps_pool_destroy(pool);
 	}
 }
 
 static void kiblnd_fail_poolset(kib_poolset_t *ps, struct list_head *zombies)
 {
-	if (ps->ps_net == NULL) /* intialized? */
+	if (!ps->ps_net) /* intialized? */
 		return;
 
 	spin_lock(&ps->ps_lock);
@@ -1660,7 +1660,7 @@ static void kiblnd_fail_poolset(kib_poolset_t *ps, struct list_head *zombies)
 
 static void kiblnd_fini_poolset(kib_poolset_t *ps)
 {
-	if (ps->ps_net != NULL) { /* initialized? */
+	if (ps->ps_net) { /* initialized? */
 		kiblnd_destroy_pool_list(&ps->ps_failed_pool_list);
 		kiblnd_destroy_pool_list(&ps->ps_pool_list);
 	}
@@ -1719,7 +1719,7 @@ void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node)
 
 	spin_lock(&ps->ps_lock);
 
-	if (ps->ps_node_fini != NULL)
+	if (ps->ps_node_fini)
 		ps->ps_node_fini(pool, node);
 
 	LASSERT(pool->po_allocated > 0);
@@ -1757,7 +1757,7 @@ struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
 		node = pool->po_free_list.next;
 		list_del(node);
 
-		if (ps->ps_node_init != NULL) {
+		if (ps->ps_node_init) {
 			/* still hold the lock */
 			ps->ps_node_init(pool, node);
 		}
@@ -1809,35 +1809,35 @@ static void kiblnd_destroy_tx_pool(kib_pool_t *pool)
 
 	LASSERT(pool->po_allocated == 0);
 
-	if (tpo->tpo_tx_pages != NULL) {
+	if (tpo->tpo_tx_pages) {
 		kiblnd_unmap_tx_pool(tpo);
 		kiblnd_free_pages(tpo->tpo_tx_pages);
 	}
 
-	if (tpo->tpo_tx_descs == NULL)
+	if (!tpo->tpo_tx_descs)
 		goto out;
 
 	for (i = 0; i < pool->po_size; i++) {
 		kib_tx_t *tx = &tpo->tpo_tx_descs[i];
 
 		list_del(&tx->tx_list);
-		if (tx->tx_pages != NULL)
+		if (tx->tx_pages)
 			LIBCFS_FREE(tx->tx_pages,
 				    LNET_MAX_IOV *
 				    sizeof(*tx->tx_pages));
-		if (tx->tx_frags != NULL)
+		if (tx->tx_frags)
 			LIBCFS_FREE(tx->tx_frags,
 				    IBLND_MAX_RDMA_FRAGS *
 					    sizeof(*tx->tx_frags));
-		if (tx->tx_wrq != NULL)
+		if (tx->tx_wrq)
 			LIBCFS_FREE(tx->tx_wrq,
 				    (1 + IBLND_MAX_RDMA_FRAGS) *
 				    sizeof(*tx->tx_wrq));
-		if (tx->tx_sge != NULL)
+		if (tx->tx_sge)
 			LIBCFS_FREE(tx->tx_sge,
 				    (1 + IBLND_MAX_RDMA_FRAGS) *
 				    sizeof(*tx->tx_sge));
-		if (tx->tx_rd != NULL)
+		if (tx->tx_rd)
 			LIBCFS_FREE(tx->tx_rd,
 				    offsetof(kib_rdma_desc_t,
 					     rd_frags[IBLND_MAX_RDMA_FRAGS]));
@@ -1866,7 +1866,7 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 	kib_tx_pool_t *tpo;
 
 	LIBCFS_CPT_ALLOC(tpo, lnet_cpt_table(), ps->ps_cpt, sizeof(*tpo));
-	if (tpo == NULL) {
+	if (!tpo) {
 		CERROR("Failed to allocate TX pool\n");
 		return -ENOMEM;
 	}
@@ -1885,7 +1885,7 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 
 	LIBCFS_CPT_ALLOC(tpo->tpo_tx_descs, lnet_cpt_table(), ps->ps_cpt,
 			 size * sizeof(kib_tx_t));
-	if (tpo->tpo_tx_descs == NULL) {
+	if (!tpo->tpo_tx_descs) {
 		CERROR("Can't allocate %d tx descriptors\n", size);
 		ps->ps_pool_destroy(pool);
 		return -ENOMEM;
@@ -1897,17 +1897,17 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 		kib_tx_t *tx = &tpo->tpo_tx_descs[i];
 
 		tx->tx_pool = tpo;
-		if (ps->ps_net->ibn_fmr_ps != NULL) {
+		if (ps->ps_net->ibn_fmr_ps) {
 			LIBCFS_CPT_ALLOC(tx->tx_pages,
 					 lnet_cpt_table(), ps->ps_cpt,
 					 LNET_MAX_IOV * sizeof(*tx->tx_pages));
-			if (tx->tx_pages == NULL)
+			if (!tx->tx_pages)
 				break;
 		}
 
 		LIBCFS_CPT_ALLOC(tx->tx_frags, lnet_cpt_table(), ps->ps_cpt,
 				 IBLND_MAX_RDMA_FRAGS * sizeof(*tx->tx_frags));
-		if (tx->tx_frags == NULL)
+		if (!tx->tx_frags)
 			break;
 
 		sg_init_table(tx->tx_frags, IBLND_MAX_RDMA_FRAGS);
@@ -1915,19 +1915,19 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 		LIBCFS_CPT_ALLOC(tx->tx_wrq, lnet_cpt_table(), ps->ps_cpt,
 				 (1 + IBLND_MAX_RDMA_FRAGS) *
 				 sizeof(*tx->tx_wrq));
-		if (tx->tx_wrq == NULL)
+		if (!tx->tx_wrq)
 			break;
 
 		LIBCFS_CPT_ALLOC(tx->tx_sge, lnet_cpt_table(), ps->ps_cpt,
 				 (1 + IBLND_MAX_RDMA_FRAGS) *
 				 sizeof(*tx->tx_sge));
-		if (tx->tx_sge == NULL)
+		if (!tx->tx_sge)
 			break;
 
 		LIBCFS_CPT_ALLOC(tx->tx_rd, lnet_cpt_table(), ps->ps_cpt,
 				 offsetof(kib_rdma_desc_t,
 					  rd_frags[IBLND_MAX_RDMA_FRAGS]));
-		if (tx->tx_rd == NULL)
+		if (!tx->tx_rd)
 			break;
 	}
 
@@ -1958,23 +1958,23 @@ static void kiblnd_net_fini_pools(kib_net_t *net)
 		kib_tx_poolset_t *tps;
 		kib_fmr_poolset_t *fps;
 
-		if (net->ibn_tx_ps != NULL) {
+		if (net->ibn_tx_ps) {
 			tps = net->ibn_tx_ps[i];
 			kiblnd_fini_poolset(&tps->tps_poolset);
 		}
 
-		if (net->ibn_fmr_ps != NULL) {
+		if (net->ibn_fmr_ps) {
 			fps = net->ibn_fmr_ps[i];
 			kiblnd_fini_fmr_poolset(fps);
 		}
 	}
 
-	if (net->ibn_tx_ps != NULL) {
+	if (net->ibn_tx_ps) {
 		cfs_percpt_free(net->ibn_tx_ps);
 		net->ibn_tx_ps = NULL;
 	}
 
-	if (net->ibn_fmr_ps != NULL) {
+	if (net->ibn_fmr_ps) {
 		cfs_percpt_free(net->ibn_fmr_ps);
 		net->ibn_fmr_ps = NULL;
 	}
@@ -2009,7 +2009,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 	 * TX pool must be created later than FMR, see LU-2268
 	 * for details
 	 */
-	LASSERT(net->ibn_tx_ps == NULL);
+	LASSERT(!net->ibn_tx_ps);
 
 	/*
 	 * premapping can fail if ibd_nmr > 1, so we always create
@@ -2018,14 +2018,14 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 
 	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
 					   sizeof(kib_fmr_poolset_t));
-	if (net->ibn_fmr_ps == NULL) {
+	if (!net->ibn_fmr_ps) {
 		CERROR("Failed to allocate FMR pool array\n");
 		rc = -ENOMEM;
 		goto failed;
 	}
 
 	for (i = 0; i < ncpts; i++) {
-		cpt = (cpts == NULL) ? i : cpts[i];
+		cpt = !cpts ? i : cpts[i];
 		rc = kiblnd_init_fmr_poolset(net->ibn_fmr_ps[cpt], cpt, net,
 					     kiblnd_fmr_pool_size(ncpts),
 					     kiblnd_fmr_flush_trigger(ncpts));
@@ -2053,14 +2053,14 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
  create_tx_pool:
 	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
 					  sizeof(kib_tx_poolset_t));
-	if (net->ibn_tx_ps == NULL) {
+	if (!net->ibn_tx_ps) {
 		CERROR("Failed to allocate tx pool array\n");
 		rc = -ENOMEM;
 		goto failed;
 	}
 
 	for (i = 0; i < ncpts; i++) {
-		cpt = (cpts == NULL) ? i : cpts[i];
+		cpt = !cpts ? i : cpts[i];
 		rc = kiblnd_init_poolset(&net->ibn_tx_ps[cpt]->tps_poolset,
 					 cpt, net, "TX",
 					 kiblnd_tx_pool_size(ncpts),
@@ -2112,11 +2112,11 @@ static void kiblnd_hdev_cleanup_mrs(kib_hca_dev_t *hdev)
 {
 	int i;
 
-	if (hdev->ibh_nmrs == 0 || hdev->ibh_mrs == NULL)
+	if (hdev->ibh_nmrs == 0 || !hdev->ibh_mrs)
 		return;
 
 	for (i = 0; i < hdev->ibh_nmrs; i++) {
-		if (hdev->ibh_mrs[i] == NULL)
+		if (!hdev->ibh_mrs[i])
 			break;
 
 		ib_dereg_mr(hdev->ibh_mrs[i]);
@@ -2131,10 +2131,10 @@ void kiblnd_hdev_destroy(kib_hca_dev_t *hdev)
 {
 	kiblnd_hdev_cleanup_mrs(hdev);
 
-	if (hdev->ibh_pd != NULL)
+	if (hdev->ibh_pd)
 		ib_dealloc_pd(hdev->ibh_pd);
 
-	if (hdev->ibh_cmid != NULL)
+	if (hdev->ibh_cmid)
 		rdma_destroy_id(hdev->ibh_cmid);
 
 	LIBCFS_FREE(hdev, sizeof(*hdev));
@@ -2151,7 +2151,7 @@ static int kiblnd_hdev_setup_mrs(kib_hca_dev_t *hdev)
 		return rc;
 
 	LIBCFS_ALLOC(hdev->ibh_mrs, 1 * sizeof(*hdev->ibh_mrs));
-	if (hdev->ibh_mrs == NULL) {
+	if (!hdev->ibh_mrs) {
 		CERROR("Failed to allocate MRs table\n");
 		return -ENOMEM;
 	}
@@ -2185,8 +2185,8 @@ static int kiblnd_dev_need_failover(kib_dev_t *dev)
 	struct sockaddr_in dstaddr;
 	int rc;
 
-	if (dev->ibd_hdev == NULL || /* initializing */
-	    dev->ibd_hdev->ibh_cmid == NULL || /* listener is dead */
+	if (!dev->ibd_hdev || /* initializing */
+	    !dev->ibd_hdev->ibh_cmid || /* listener is dead */
 	    *kiblnd_tunables.kib_dev_failover > 1) /* debugging */
 		return 1;
 
@@ -2218,7 +2218,7 @@ static int kiblnd_dev_need_failover(kib_dev_t *dev)
 	dstaddr.sin_family = AF_INET;
 	rc = rdma_resolve_addr(cmid, (struct sockaddr *)&srcaddr,
 			       (struct sockaddr *)&dstaddr, 1);
-	if (rc != 0 || cmid->device == NULL) {
+	if (rc != 0 || !cmid->device) {
 		CERROR("Failed to bind %s:%pI4h to device(%p): %d\n",
 		       dev->ibd_ifname, &dev->ibd_ifip,
 		       cmid->device, rc);
@@ -2247,14 +2247,14 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 	int i;
 
 	LASSERT(*kiblnd_tunables.kib_dev_failover > 1 ||
-		dev->ibd_can_failover || dev->ibd_hdev == NULL);
+		dev->ibd_can_failover || !dev->ibd_hdev);
 
 	rc = kiblnd_dev_need_failover(dev);
 	if (rc <= 0)
 		goto out;
 
-	if (dev->ibd_hdev != NULL &&
-	    dev->ibd_hdev->ibh_cmid != NULL) {
+	if (dev->ibd_hdev &&
+	    dev->ibd_hdev->ibh_cmid) {
 		/*
 		 * XXX it's not good to close old listener at here,
 		 * because we can fail to create new listener.
@@ -2289,7 +2289,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 
 	/* Bind to failover device or port */
 	rc = rdma_bind_addr(cmid, (struct sockaddr *)&addr);
-	if (rc != 0 || cmid->device == NULL) {
+	if (rc != 0 || !cmid->device) {
 		CERROR("Failed to bind %s:%pI4h to device(%p): %d\n",
 		       dev->ibd_ifname, &dev->ibd_ifip,
 		       cmid->device, rc);
@@ -2298,7 +2298,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 	}
 
 	LIBCFS_ALLOC(hdev, sizeof(*hdev));
-	if (hdev == NULL) {
+	if (!hdev) {
 		CERROR("Failed to allocate kib_hca_dev\n");
 		rdma_destroy_id(cmid);
 		rc = -ENOMEM;
@@ -2354,7 +2354,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 		kiblnd_destroy_pool_list(&zombie_ppo);
 	if (!list_empty(&zombie_fpo))
 		kiblnd_destroy_fmr_pool_list(&zombie_fpo);
-	if (hdev != NULL)
+	if (hdev)
 		kiblnd_hdev_decref(hdev);
 
 	if (rc != 0)
@@ -2373,7 +2373,7 @@ void kiblnd_destroy_dev(kib_dev_t *dev)
 	list_del(&dev->ibd_fail_list);
 	list_del(&dev->ibd_list);
 
-	if (dev->ibd_hdev != NULL)
+	if (dev->ibd_hdev)
 		kiblnd_hdev_decref(dev->ibd_hdev);
 
 	LIBCFS_FREE(dev, sizeof(*dev));
@@ -2401,11 +2401,11 @@ static kib_dev_t *kiblnd_create_dev(char *ifname)
 	}
 
 	LIBCFS_ALLOC(dev, sizeof(*dev));
-	if (dev == NULL)
+	if (!dev)
 		return NULL;
 
 	netdev = dev_get_by_name(&init_net, ifname);
-	if (netdev == NULL) {
+	if (!netdev) {
 		dev->ibd_can_failover = 0;
 	} else {
 		dev->ibd_can_failover = !!(netdev->flags & IFF_MASTER);
@@ -2443,7 +2443,7 @@ static void kiblnd_base_shutdown(void)
 
 	case IBLND_INIT_ALL:
 	case IBLND_INIT_DATA:
-		LASSERT(kiblnd_data.kib_peers != NULL);
+		LASSERT(kiblnd_data.kib_peers);
 		for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++)
 			LASSERT(list_empty(&kiblnd_data.kib_peers[i]));
 		LASSERT(list_empty(&kiblnd_data.kib_connd_zombies));
@@ -2480,13 +2480,13 @@ static void kiblnd_base_shutdown(void)
 		break;
 	}
 
-	if (kiblnd_data.kib_peers != NULL) {
+	if (kiblnd_data.kib_peers) {
 		LIBCFS_FREE(kiblnd_data.kib_peers,
 			    sizeof(struct list_head) *
 			    kiblnd_data.kib_peer_hash_size);
 	}
 
-	if (kiblnd_data.kib_scheds != NULL)
+	if (kiblnd_data.kib_scheds)
 		cfs_percpt_free(kiblnd_data.kib_scheds);
 
 	kiblnd_data.kib_init = IBLND_INIT_NOTHING;
@@ -2502,7 +2502,7 @@ void kiblnd_shutdown(lnet_ni_t *ni)
 
 	LASSERT(kiblnd_data.kib_init == IBLND_INIT_ALL);
 
-	if (net == NULL)
+	if (!net)
 		goto out;
 
 	write_lock_irqsave(g_lock, flags);
@@ -2542,7 +2542,7 @@ void kiblnd_shutdown(lnet_ni_t *ni)
 	case IBLND_INIT_NOTHING:
 		LASSERT(atomic_read(&net->ibn_nconns) == 0);
 
-		if (net->ibn_dev != NULL &&
+		if (net->ibn_dev &&
 		    net->ibn_dev->ibd_nnets == 0)
 			kiblnd_destroy_dev(net->ibn_dev);
 
@@ -2579,7 +2579,7 @@ static int kiblnd_base_startup(void)
 	kiblnd_data.kib_peer_hash_size = IBLND_PEER_HASH_SIZE;
 	LIBCFS_ALLOC(kiblnd_data.kib_peers,
 		     sizeof(struct list_head) * kiblnd_data.kib_peer_hash_size);
-	if (kiblnd_data.kib_peers == NULL)
+	if (!kiblnd_data.kib_peers)
 		goto failed;
 	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++)
 		INIT_LIST_HEAD(&kiblnd_data.kib_peers[i]);
@@ -2592,7 +2592,7 @@ static int kiblnd_base_startup(void)
 
 	kiblnd_data.kib_scheds = cfs_percpt_alloc(lnet_cpt_table(),
 						  sizeof(*sched));
-	if (kiblnd_data.kib_scheds == NULL)
+	if (!kiblnd_data.kib_scheds)
 		goto failed;
 
 	cfs_percpt_for_each(sched, i, kiblnd_data.kib_scheds) {
@@ -2700,7 +2700,7 @@ static int kiblnd_dev_start_threads(kib_dev_t *dev, int newdev, __u32 *cpts,
 	for (i = 0; i < ncpts; i++) {
 		struct kib_sched_info *sched;
 
-		cpt = (cpts == NULL) ? i : cpts[i];
+		cpt = !cpts ? i : cpts[i];
 		sched = kiblnd_data.kib_scheds[cpt];
 
 		if (!newdev && sched->ibs_nthreads > 0)
@@ -2728,21 +2728,21 @@ static kib_dev_t *kiblnd_dev_search(char *ifname)
 		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
 			return dev;
 
-		if (alias != NULL)
+		if (alias)
 			continue;
 
 		colon2 = strchr(dev->ibd_ifname, ':');
-		if (colon != NULL)
+		if (colon)
 			*colon = 0;
-		if (colon2 != NULL)
+		if (colon2)
 			*colon2 = 0;
 
 		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
 			alias = dev;
 
-		if (colon != NULL)
+		if (colon)
 			*colon = ':';
-		if (colon2 != NULL)
+		if (colon2)
 			*colon2 = ':';
 	}
 	return alias;
@@ -2768,7 +2768,7 @@ int kiblnd_startup(lnet_ni_t *ni)
 
 	LIBCFS_ALLOC(net, sizeof(*net));
 	ni->ni_data = net;
-	if (net == NULL)
+	if (!net)
 		goto net_failed;
 
 	ktime_get_real_ts64(&tv);
@@ -2780,11 +2780,11 @@ int kiblnd_startup(lnet_ni_t *ni)
 	ni->ni_peertxcredits  = *kiblnd_tunables.kib_peertxcredits;
 	ni->ni_peerrtrcredits = *kiblnd_tunables.kib_peerrtrcredits;
 
-	if (ni->ni_interfaces[0] != NULL) {
+	if (ni->ni_interfaces[0]) {
 		/* Use the IPoIB interface specified in 'networks=' */
 
 		CLASSERT(LNET_MAX_INTERFACES > 1);
-		if (ni->ni_interfaces[1] != NULL) {
+		if (ni->ni_interfaces[1]) {
 			CERROR("Multiple interfaces not supported\n");
 			goto failed;
 		}
@@ -2801,12 +2801,12 @@ int kiblnd_startup(lnet_ni_t *ni)
 
 	ibdev = kiblnd_dev_search(ifname);
 
-	newdev = ibdev == NULL;
+	newdev = !ibdev;
 	/* hmm...create kib_dev even for alias */
-	if (ibdev == NULL || strcmp(&ibdev->ibd_ifname[0], ifname) != 0)
+	if (!ibdev || strcmp(&ibdev->ibd_ifname[0], ifname) != 0)
 		ibdev = kiblnd_create_dev(ifname);
 
-	if (ibdev == NULL)
+	if (!ibdev)
 		goto failed;
 
 	net->ibn_dev = ibdev;
@@ -2833,7 +2833,7 @@ int kiblnd_startup(lnet_ni_t *ni)
 	return 0;
 
 failed:
-	if (net->ibn_dev == NULL && ibdev != NULL)
+	if (!net->ibn_dev && ibdev)
 		kiblnd_destroy_dev(ibdev);
 
 net_failed:
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index d9c7089..674a4ee 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -50,12 +50,12 @@ kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
 	int rc;
 	int i;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(!in_interrupt());
 	LASSERT(!tx->tx_queued);	       /* mustn't be queued for sending */
 	LASSERT(tx->tx_sending == 0);	  /* mustn't be awaiting sent callback */
 	LASSERT(!tx->tx_waiting);	      /* mustn't be awaiting peer response */
-	LASSERT(tx->tx_pool != NULL);
+	LASSERT(tx->tx_pool);
 
 	kiblnd_unmap_tx(ni, tx);
 
@@ -64,7 +64,7 @@ kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
 	lntmsg[1] = tx->tx_lntmsg[1]; tx->tx_lntmsg[1] = NULL;
 	rc = tx->tx_status;
 
-	if (tx->tx_conn != NULL) {
+	if (tx->tx_conn) {
 		LASSERT(ni == tx->tx_conn->ibc_peer->ibp_ni);
 
 		kiblnd_conn_decref(tx->tx_conn);
@@ -78,7 +78,7 @@ kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
 
 	/* delay finalize until my descs have been freed */
 	for (i = 0; i < 2; i++) {
-		if (lntmsg[i] == NULL)
+		if (!lntmsg[i])
 			continue;
 
 		lnet_finalize(ni, lntmsg[i], rc);
@@ -111,7 +111,7 @@ kiblnd_get_idle_tx(lnet_ni_t *ni, lnet_nid_t target)
 
 	tps = net->ibn_tx_ps[lnet_cpt_of_nid(target)];
 	node = kiblnd_pool_alloc_node(&tps->tps_poolset);
-	if (node == NULL)
+	if (!node)
 		return NULL;
 	tx = container_of(node, kib_tx_t, tx_list);
 
@@ -120,9 +120,9 @@ kiblnd_get_idle_tx(lnet_ni_t *ni, lnet_nid_t target)
 	LASSERT(tx->tx_sending == 0);
 	LASSERT(!tx->tx_waiting);
 	LASSERT(tx->tx_status == 0);
-	LASSERT(tx->tx_conn == NULL);
-	LASSERT(tx->tx_lntmsg[0] == NULL);
-	LASSERT(tx->tx_lntmsg[1] == NULL);
+	LASSERT(!tx->tx_conn);
+	LASSERT(!tx->tx_lntmsg[0]);
+	LASSERT(!tx->tx_lntmsg[1]);
 	LASSERT(tx->tx_nfrags == 0);
 
 	return tx;
@@ -152,14 +152,14 @@ kiblnd_post_rx(kib_rx_t *rx, int credit)
 	struct ib_mr *mr;
 	int rc;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(!in_interrupt());
 	LASSERT(credit == IBLND_POSTRX_NO_CREDIT ||
 		credit == IBLND_POSTRX_PEER_CREDIT ||
 		credit == IBLND_POSTRX_RSRVD_CREDIT);
 
 	mr = kiblnd_find_dma_mr(conn->ibc_hdev, rx->rx_msgaddr, IBLND_MSG_SIZE);
-	LASSERT(mr != NULL);
+	LASSERT(mr);
 
 	rx->rx_sge.lkey   = mr->lkey;
 	rx->rx_sge.addr   = rx->rx_msgaddr;
@@ -251,7 +251,7 @@ kiblnd_handle_completion(kib_conn_t *conn, int txtype, int status, __u64 cookie)
 	spin_lock(&conn->ibc_lock);
 
 	tx = kiblnd_find_waiting_tx_locked(conn, txtype, cookie);
-	if (tx == NULL) {
+	if (!tx) {
 		spin_unlock(&conn->ibc_lock);
 
 		CWARN("Unmatched completion type %x cookie %#llx from %s\n",
@@ -285,7 +285,7 @@ kiblnd_send_completion(kib_conn_t *conn, int type, int status, __u64 cookie)
 	lnet_ni_t *ni = conn->ibc_peer->ibp_ni;
 	kib_tx_t *tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
 
-	if (tx == NULL) {
+	if (!tx) {
 		CERROR("Can't get tx for completion %x for %s\n",
 		       type, libcfs_nid2str(conn->ibc_peer->ibp_nid));
 		return;
@@ -397,11 +397,11 @@ kiblnd_handle_rx(kib_rx_t *rx)
 		spin_lock(&conn->ibc_lock);
 		tx = kiblnd_find_waiting_tx_locked(conn, IBLND_MSG_PUT_REQ,
 						   msg->ibm_u.putack.ibpam_src_cookie);
-		if (tx != NULL)
+		if (tx)
 			list_del(&tx->tx_list);
 		spin_unlock(&conn->ibc_lock);
 
-		if (tx == NULL) {
+		if (!tx) {
 			CERROR("Unmatched PUT_ACK from %s\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid));
 			rc = -EPROTO;
@@ -470,7 +470,7 @@ kiblnd_rx_complete(kib_rx_t *rx, int status, int nob)
 	int rc;
 	int err = -EIO;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(rx->rx_nob < 0);	       /* was posted */
 	rx->rx_nob = 0;			 /* isn't now */
 
@@ -538,7 +538,7 @@ kiblnd_kvaddr_to_page(unsigned long vaddr)
 
 	if (is_vmalloc_addr((void *)vaddr)) {
 		page = vmalloc_to_page((void *)vaddr);
-		LASSERT(page != NULL);
+		LASSERT(page);
 		return page;
 	}
 #ifdef CONFIG_HIGHMEM
@@ -550,7 +550,7 @@ kiblnd_kvaddr_to_page(unsigned long vaddr)
 	}
 #endif
 	page = virt_to_page(vaddr);
-	LASSERT(page != NULL);
+	LASSERT(page);
 	return page;
 }
 
@@ -566,8 +566,8 @@ kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, int nob)
 	int rc;
 	int i;
 
-	LASSERT(tx->tx_pool != NULL);
-	LASSERT(tx->tx_pool->tpo_pool.po_owner != NULL);
+	LASSERT(tx->tx_pool);
+	LASSERT(tx->tx_pool->tpo_pool.po_owner);
 
 	hdev = tx->tx_pool->tpo_hdev;
 
@@ -605,7 +605,7 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx)
 {
 	kib_net_t *net = ni->ni_data;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 
 	if (net->ibn_fmr_ps && tx->fmr.fmr_pfmr) {
 		kiblnd_fmr_pool_unmap(&tx->fmr, tx->tx_status);
@@ -648,13 +648,13 @@ static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 
 	/* looking for pre-mapping MR */
 	mr = kiblnd_find_rd_dma_mr(hdev, rd);
-	if (mr != NULL) {
+	if (mr) {
 		/* found pre-mapping MR */
 		rd->rd_key = (rd != tx->tx_rd) ? mr->rkey : mr->lkey;
 		return 0;
 	}
 
-	if (net->ibn_fmr_ps != NULL)
+	if (net->ibn_fmr_ps)
 		return kiblnd_fmr_map_tx(net, tx, rd, nob);
 
 	return -EINVAL;
@@ -673,7 +673,7 @@ kiblnd_setup_rd_iov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 
 	LASSERT(nob > 0);
 	LASSERT(niov > 0);
-	LASSERT(net != NULL);
+	LASSERT(net);
 
 	while (offset >= iov->iov_len) {
 		offset -= iov->iov_len;
@@ -689,7 +689,7 @@ kiblnd_setup_rd_iov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 		vaddr = ((unsigned long)iov->iov_base) + offset;
 		page_offset = vaddr & (PAGE_SIZE - 1);
 		page = kiblnd_kvaddr_to_page(vaddr);
-		if (page == NULL) {
+		if (!page) {
 			CERROR("Can't find page\n");
 			return -EFAULT;
 		}
@@ -725,7 +725,7 @@ kiblnd_setup_rd_kiov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 
 	LASSERT(nob > 0);
 	LASSERT(nkiov > 0);
-	LASSERT(net != NULL);
+	LASSERT(net);
 
 	while (offset >= kiov->kiov_len) {
 		offset -= kiov->kiov_len;
@@ -925,11 +925,11 @@ kiblnd_check_sends(kib_conn_t *conn)
 		spin_unlock(&conn->ibc_lock);
 
 		tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
-		if (tx != NULL)
+		if (tx)
 			kiblnd_init_tx_msg(ni, tx, IBLND_MSG_NOOP, 0);
 
 		spin_lock(&conn->ibc_lock);
-		if (tx != NULL)
+		if (tx)
 			kiblnd_queue_tx_locked(tx, conn);
 	}
 
@@ -1035,7 +1035,7 @@ kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
 	kiblnd_init_msg(tx->tx_msg, type, body_nob);
 
 	mr = kiblnd_find_dma_mr(hdev, tx->tx_msgaddr, nob);
-	LASSERT(mr != NULL);
+	LASSERT(mr);
 
 	sge->lkey   = mr->lkey;
 	sge->addr   = tx->tx_msgaddr;
@@ -1149,7 +1149,7 @@ kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn)
 	tx->tx_queued = 1;
 	tx->tx_deadline = jiffies + (*kiblnd_tunables.kib_timeout * HZ);
 
-	if (tx->tx_conn == NULL) {
+	if (!tx->tx_conn) {
 		kiblnd_conn_addref(conn);
 		tx->tx_conn = conn;
 		LASSERT(tx->tx_msg->ibm_type != IBLND_MSG_PUT_DONE);
@@ -1247,7 +1247,7 @@ kiblnd_connect_peer(kib_peer_t *peer)
 	struct sockaddr_in dstaddr;
 	int rc;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 	LASSERT(peer->ibp_connecting > 0);
 
 	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, peer, RDMA_PS_TCP,
@@ -1288,7 +1288,7 @@ kiblnd_connect_peer(kib_peer_t *peer)
 		goto failed2;
 	}
 
-	LASSERT(cmid->device != NULL);
+	LASSERT(cmid->device);
 	CDEBUG(D_NET, "%s: connection bound to %s:%pI4h:%s\n",
 	       libcfs_nid2str(peer->ibp_nid), dev->ibd_ifname,
 	       &dev->ibd_ifip, cmid->device->name);
@@ -1316,8 +1316,8 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	 * If I get here, I've committed to send, so I complete the tx with
 	 * failure on any problems
 	 */
-	LASSERT(tx == NULL || tx->tx_conn == NULL); /* only set when assigned a conn */
-	LASSERT(tx == NULL || tx->tx_nwrq > 0);     /* work items have been set up */
+	LASSERT(!tx || !tx->tx_conn); /* only set when assigned a conn */
+	LASSERT(!tx || tx->tx_nwrq > 0);     /* work items have been set up */
 
 	/*
 	 * First time, just use a read lock since I expect to find my peer
@@ -1326,14 +1326,14 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	read_lock_irqsave(g_lock, flags);
 
 	peer = kiblnd_find_peer_locked(nid);
-	if (peer != NULL && !list_empty(&peer->ibp_conns)) {
+	if (peer && !list_empty(&peer->ibp_conns)) {
 		/* Found a peer with an established connection */
 		conn = kiblnd_get_conn_locked(peer);
 		kiblnd_conn_addref(conn); /* 1 ref for me... */
 
 		read_unlock_irqrestore(g_lock, flags);
 
-		if (tx != NULL)
+		if (tx)
 			kiblnd_queue_tx(tx, conn);
 		kiblnd_conn_decref(conn); /* ...to here */
 		return;
@@ -1344,12 +1344,12 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	write_lock(g_lock);
 
 	peer = kiblnd_find_peer_locked(nid);
-	if (peer != NULL) {
+	if (peer) {
 		if (list_empty(&peer->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
 			LASSERT(peer->ibp_connecting != 0 ||
 				peer->ibp_accepting != 0);
-			if (tx != NULL)
+			if (tx)
 				list_add_tail(&tx->tx_list,
 					      &peer->ibp_tx_queue);
 			write_unlock_irqrestore(g_lock, flags);
@@ -1359,7 +1359,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 
 			write_unlock_irqrestore(g_lock, flags);
 
-			if (tx != NULL)
+			if (tx)
 				kiblnd_queue_tx(tx, conn);
 			kiblnd_conn_decref(conn); /* ...to here */
 		}
@@ -1372,7 +1372,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	rc = kiblnd_create_peer(ni, &peer, nid);
 	if (rc != 0) {
 		CERROR("Can't create peer %s\n", libcfs_nid2str(nid));
-		if (tx != NULL) {
+		if (tx) {
 			tx->tx_status = -EHOSTUNREACH;
 			tx->tx_waiting = 0;
 			kiblnd_tx_done(ni, tx);
@@ -1383,12 +1383,12 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	write_lock_irqsave(g_lock, flags);
 
 	peer2 = kiblnd_find_peer_locked(nid);
-	if (peer2 != NULL) {
+	if (peer2) {
 		if (list_empty(&peer2->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
 			LASSERT(peer2->ibp_connecting != 0 ||
 				peer2->ibp_accepting != 0);
-			if (tx != NULL)
+			if (tx)
 				list_add_tail(&tx->tx_list,
 					      &peer2->ibp_tx_queue);
 			write_unlock_irqrestore(g_lock, flags);
@@ -1398,7 +1398,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 
 			write_unlock_irqrestore(g_lock, flags);
 
-			if (tx != NULL)
+			if (tx)
 				kiblnd_queue_tx(tx, conn);
 			kiblnd_conn_decref(conn); /* ...to here */
 		}
@@ -1414,7 +1414,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	/* always called with a ref on ni, which prevents ni being shutdown */
 	LASSERT(((kib_net_t *)ni->ni_data)->ibn_shutdown == 0);
 
-	if (tx != NULL)
+	if (tx)
 		list_add_tail(&tx->tx_list, &peer->ibp_tx_queue);
 
 	kiblnd_peer_addref(peer);
@@ -1456,7 +1456,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	/* Thread context */
 	LASSERT(!in_interrupt());
 	/* payload is either all vaddrs or all pages */
-	LASSERT(!(payload_kiov != NULL && payload_iov != NULL));
+	LASSERT(!(payload_kiov && payload_iov));
 
 	switch (type) {
 	default:
@@ -1477,7 +1477,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 			break;		  /* send IMMEDIATE */
 
 		tx = kiblnd_get_idle_tx(ni, target.nid);
-		if (tx == NULL) {
+		if (!tx) {
 			CERROR("Can't allocate txd for GET to %s\n",
 			       libcfs_nid2str(target.nid));
 			return -ENOMEM;
@@ -1509,7 +1509,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_GET_REQ, nob);
 
 		tx->tx_lntmsg[1] = lnet_create_reply_msg(ni, lntmsg);
-		if (tx->tx_lntmsg[1] == NULL) {
+		if (!tx->tx_lntmsg[1]) {
 			CERROR("Can't create reply for GET -> %s\n",
 			       libcfs_nid2str(target.nid));
 			kiblnd_tx_done(ni, tx);
@@ -1529,14 +1529,14 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 			break;		  /* send IMMEDIATE */
 
 		tx = kiblnd_get_idle_tx(ni, target.nid);
-		if (tx == NULL) {
+		if (!tx) {
 			CERROR("Can't allocate %s txd for %s\n",
 			       type == LNET_MSG_PUT ? "PUT" : "REPLY",
 			       libcfs_nid2str(target.nid));
 			return -ENOMEM;
 		}
 
-		if (payload_kiov == NULL)
+		if (!payload_kiov)
 			rc = kiblnd_setup_rd_iov(ni, tx, tx->tx_rd,
 						 payload_niov, payload_iov,
 						 payload_offset, payload_nob);
@@ -1568,7 +1568,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 		 <= IBLND_MSG_SIZE);
 
 	tx = kiblnd_get_idle_tx(ni, target.nid);
-	if (tx == NULL) {
+	if (!tx) {
 		CERROR("Can't send %d to %s: tx descs exhausted\n",
 		       type, libcfs_nid2str(target.nid));
 		return -ENOMEM;
@@ -1577,7 +1577,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	ibmsg = tx->tx_msg;
 	ibmsg->ibm_u.immediate.ibim_hdr = *hdr;
 
-	if (payload_kiov != NULL)
+	if (payload_kiov)
 		lnet_copy_kiov2flat(IBLND_MSG_SIZE, ibmsg,
 				    offsetof(kib_msg_t, ibm_u.immediate.ibim_payload),
 				    payload_niov, payload_kiov,
@@ -1609,7 +1609,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 	int rc;
 
 	tx = kiblnd_get_idle_tx(ni, rx->rx_conn->ibc_peer->ibp_nid);
-	if (tx == NULL) {
+	if (!tx) {
 		CERROR("Can't get tx for REPLY to %s\n",
 		       libcfs_nid2str(target.nid));
 		goto failed_0;
@@ -1617,7 +1617,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 
 	if (nob == 0)
 		rc = 0;
-	else if (kiov == NULL)
+	else if (!kiov)
 		rc = kiblnd_setup_rd_iov(ni, tx, tx->tx_rd,
 					 niov, iov, offset, nob);
 	else
@@ -1673,7 +1673,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 	LASSERT(mlen <= rlen);
 	LASSERT(!in_interrupt());
 	/* Either all pages or all vaddrs */
-	LASSERT(!(kiov != NULL && iov != NULL));
+	LASSERT(!(kiov && iov));
 
 	switch (rxmsg->ibm_type) {
 	default:
@@ -1689,7 +1689,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 			break;
 		}
 
-		if (kiov != NULL)
+		if (kiov)
 			lnet_copy_flat2kiov(niov, kiov, offset,
 					    IBLND_MSG_SIZE, rxmsg,
 					    offsetof(kib_msg_t, ibm_u.immediate.ibim_payload),
@@ -1714,7 +1714,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		}
 
 		tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
-		if (tx == NULL) {
+		if (!tx) {
 			CERROR("Can't allocate tx for %s\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid));
 			/* Not replying will break the connection */
@@ -1724,7 +1724,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 
 		txmsg = tx->tx_msg;
 		rd = &txmsg->ibm_u.putack.ibpam_rd;
-		if (kiov == NULL)
+		if (!kiov)
 			rc = kiblnd_setup_rd_iov(ni, tx, rd,
 						 niov, iov, offset, mlen);
 		else
@@ -1756,7 +1756,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		}
 
 	case IBLND_MSG_GET_REQ:
-		if (lntmsg != NULL) {
+		if (lntmsg) {
 			/* Optimized GET; RDMA lntmsg's payload */
 			kiblnd_reply(ni, rx, lntmsg);
 		} else {
@@ -2177,7 +2177,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
 	/* cmid inherits 'context' from the corresponding listener id */
 	ibdev = (kib_dev_t *)cmid->context;
-	LASSERT(ibdev != NULL);
+	LASSERT(ibdev);
 
 	memset(&rej, 0, sizeof(rej));
 	rej.ibr_magic = IBLND_MSG_MAGIC;
@@ -2228,17 +2228,17 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	nid = reqmsg->ibm_srcnid;
 	ni = lnet_net2ni(LNET_NIDNET(reqmsg->ibm_dstnid));
 
-	if (ni != NULL) {
+	if (ni) {
 		net = (kib_net_t *)ni->ni_data;
 		rej.ibr_incarnation = net->ibn_incarnation;
 	}
 
-	if (ni == NULL ||			 /* no matching net */
+	if (!ni ||			 /* no matching net */
 	    ni->ni_nid != reqmsg->ibm_dstnid ||   /* right NET, wrong NID! */
 	    net->ibn_dev != ibdev) {	      /* wrong device */
 		CERROR("Can't accept %s on %s (%s:%d:%pI4h): bad dst nid %s\n",
 		       libcfs_nid2str(nid),
-		       ni == NULL ? "NA" : libcfs_nid2str(ni->ni_nid),
+		       !ni ? "NA" : libcfs_nid2str(ni->ni_nid),
 		       ibdev->ibd_ifname, ibdev->ibd_nnets,
 		       &ibdev->ibd_ifip,
 		       libcfs_nid2str(reqmsg->ibm_dstnid));
@@ -2307,7 +2307,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	write_lock_irqsave(g_lock, flags);
 
 	peer2 = kiblnd_find_peer_locked(nid);
-	if (peer2 != NULL) {
+	if (peer2) {
 		if (peer2->ibp_version == 0) {
 			peer2->ibp_version     = version;
 			peer2->ibp_incarnation = reqmsg->ibm_srcstamp;
@@ -2365,7 +2365,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	}
 
 	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_PASSIVE_WAIT, version);
-	if (conn == NULL) {
+	if (!conn) {
 		kiblnd_peer_connect_failed(peer, 0, -ENOMEM);
 		kiblnd_peer_decref(peer);
 		rej.ibr_why = IBLND_REJECT_NO_RESOURCES;
@@ -2419,7 +2419,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	return 0;
 
  failed:
-	if (ni != NULL)
+	if (ni)
 		lnet_ni_decref(ni);
 
 	rej.ibr_version             = version;
@@ -2488,9 +2488,9 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 	CNETERR("%s: retrying (%s), %x, %x, queue_dep: %d, max_frag: %d, msg_size: %d\n",
 		libcfs_nid2str(peer->ibp_nid),
 		reason, IBLND_MSG_VERSION, version,
-		cp != NULL ? cp->ibcp_queue_depth  : IBLND_MSG_QUEUE_SIZE(version),
-		cp != NULL ? cp->ibcp_max_frags    : IBLND_RDMA_FRAGS(version),
-		cp != NULL ? cp->ibcp_max_msg_size : IBLND_MSG_SIZE);
+		cp ? cp->ibcp_queue_depth  : IBLND_MSG_QUEUE_SIZE(version),
+		cp ? cp->ibcp_max_frags    : IBLND_RDMA_FRAGS(version),
+		cp ? cp->ibcp_max_msg_size : IBLND_MSG_SIZE);
 
 	kiblnd_connect_peer(peer);
 }
@@ -2595,7 +2595,7 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 			case IBLND_REJECT_MSG_QUEUE_SIZE:
 				CERROR("%s rejected: incompatible message queue depth %d, %d\n",
 				       libcfs_nid2str(peer->ibp_nid),
-				       cp != NULL ? cp->ibcp_queue_depth :
+				       cp ? cp->ibcp_queue_depth :
 				       IBLND_MSG_QUEUE_SIZE(rej->ibr_version),
 				       IBLND_MSG_QUEUE_SIZE(conn->ibc_version));
 				break;
@@ -2603,7 +2603,7 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 			case IBLND_REJECT_RDMA_FRAGS:
 				CERROR("%s rejected: incompatible # of RDMA fragments %d, %d\n",
 				       libcfs_nid2str(peer->ibp_nid),
-				       cp != NULL ? cp->ibcp_max_frags :
+				       cp ? cp->ibcp_max_frags :
 				       IBLND_RDMA_FRAGS(rej->ibr_version),
 				       IBLND_RDMA_FRAGS(conn->ibc_version));
 				break;
@@ -2647,7 +2647,7 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 	int rc = kiblnd_unpack_msg(msg, priv_nob);
 	unsigned long flags;
 
-	LASSERT(net != NULL);
+	LASSERT(net);
 
 	if (rc != 0) {
 		CERROR("Can't unpack connack from %s: %d\n",
@@ -2755,7 +2755,7 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	conn = kiblnd_create_conn(peer, cmid, IBLND_CONN_ACTIVE_CONNECT, version);
-	if (conn == NULL) {
+	if (!conn) {
 		kiblnd_peer_connect_failed(peer, 1, -ENOMEM);
 		kiblnd_peer_decref(peer); /* lose cmid's ref */
 		return -ENOMEM;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 7c9525d..2c2d1c9 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -70,7 +70,7 @@ ksocknal_create_route(__u32 ipaddr, int port)
 	ksock_route_t *route;
 
 	LIBCFS_ALLOC(route, sizeof(*route));
-	if (route == NULL)
+	if (!route)
 		return NULL;
 
 	atomic_set(&route->ksnr_refcount, 1);
@@ -93,7 +93,7 @@ ksocknal_destroy_route(ksock_route_t *route)
 {
 	LASSERT(atomic_read(&route->ksnr_refcount) == 0);
 
-	if (route->ksnr_peer != NULL)
+	if (route->ksnr_peer)
 		ksocknal_peer_decref(route->ksnr_peer);
 
 	LIBCFS_FREE(route, sizeof(*route));
@@ -110,7 +110,7 @@ ksocknal_create_peer(ksock_peer_t **peerp, lnet_ni_t *ni, lnet_process_id_t id)
 	LASSERT(!in_interrupt());
 
 	LIBCFS_ALLOC(peer, sizeof(*peer));
-	if (peer == NULL)
+	if (!peer)
 		return -ENOMEM;
 
 	peer->ksnp_ni = ni;
@@ -208,7 +208,7 @@ ksocknal_find_peer(lnet_ni_t *ni, lnet_process_id_t id)
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
 	peer = ksocknal_find_peer_locked(ni, id);
-	if (peer != NULL)			/* +1 ref for caller? */
+	if (peer)			/* +1 ref for caller? */
 		ksocknal_peer_addref(peer);
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 
@@ -231,7 +231,7 @@ ksocknal_unlink_peer_locked(ksock_peer_t *peer)
 		 * All IPs in peer->ksnp_passive_ips[] come from the
 		 * interface list, therefore the call must succeed.
 		 */
-		LASSERT(iface != NULL);
+		LASSERT(iface);
 
 		CDEBUG(D_NET, "peer=%p iface=%p ksni_nroutes=%d\n",
 		       peer, iface, iface->ksni_nroutes);
@@ -347,13 +347,13 @@ ksocknal_associate_route_conn_locked(ksock_route_t *route, ksock_conn_t *conn)
 
 			iface = ksocknal_ip2iface(route->ksnr_peer->ksnp_ni,
 						  route->ksnr_myipaddr);
-			if (iface != NULL)
+			if (iface)
 				iface->ksni_nroutes--;
 		}
 		route->ksnr_myipaddr = conn->ksnc_myipaddr;
 		iface = ksocknal_ip2iface(route->ksnr_peer->ksnp_ni,
 					  route->ksnr_myipaddr);
-		if (iface != NULL)
+		if (iface)
 			iface->ksni_nroutes++;
 	}
 
@@ -375,7 +375,7 @@ ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
 	ksock_route_t *route2;
 
 	LASSERT(!peer->ksnp_closing);
-	LASSERT(route->ksnr_peer == NULL);
+	LASSERT(!route->ksnr_peer);
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
 	LASSERT(route->ksnr_connected == 0);
@@ -432,7 +432,7 @@ ksocknal_del_route_locked(ksock_route_t *route)
 	if (route->ksnr_myipaddr != 0) {
 		iface = ksocknal_ip2iface(route->ksnr_peer->ksnp_ni,
 					  route->ksnr_myipaddr);
-		if (iface != NULL)
+		if (iface)
 			iface->ksni_nroutes--;
 	}
 
@@ -470,7 +470,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 		return rc;
 
 	route = ksocknal_create_route(ipaddr, port);
-	if (route == NULL) {
+	if (!route) {
 		ksocknal_peer_decref(peer);
 		return -ENOMEM;
 	}
@@ -481,7 +481,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 	LASSERT(((ksock_net_t *) ni->ni_data)->ksnn_shutdown == 0);
 
 	peer2 = ksocknal_find_peer_locked(ni, id);
-	if (peer2 != NULL) {
+	if (peer2) {
 		ksocknal_peer_decref(peer);
 		peer = peer2;
 	} else {
@@ -499,7 +499,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 
 		route2 = NULL;
 	}
-	if (route2 == NULL) {
+	if (!route2) {
 		ksocknal_add_route_locked(peer, route);
 		route->ksnr_share_count++;
 	} else {
@@ -826,7 +826,7 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 				xor = ip ^ peerips[k];
 				this_netmatch = ((xor & iface->ksni_netmask) == 0) ? 1 : 0;
 
-				if (!(best_iface == NULL ||
+				if (!(!best_iface ||
 				      best_netmatch < this_netmatch ||
 				      (best_netmatch == this_netmatch &&
 				       best_npeers > iface->ksni_npeers)))
@@ -894,13 +894,13 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 	LASSERT(npeer_ipaddrs <= LNET_MAX_INTERFACES);
 
 	for (i = 0; i < npeer_ipaddrs; i++) {
-		if (newroute != NULL) {
+		if (newroute) {
 			newroute->ksnr_ipaddr = peer_ipaddrs[i];
 		} else {
 			write_unlock_bh(global_lock);
 
 			newroute = ksocknal_create_route(peer_ipaddrs[i], port);
-			if (newroute == NULL)
+			if (!newroute)
 				return;
 
 			write_lock_bh(global_lock);
@@ -921,7 +921,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 
 			route = NULL;
 		}
-		if (route != NULL)
+		if (route)
 			continue;
 
 		best_iface = NULL;
@@ -944,14 +944,14 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 
 				route = NULL;
 			}
-			if (route != NULL)
+			if (route)
 				continue;
 
 			this_netmatch = (((iface->ksni_ipaddr ^
 					   newroute->ksnr_ipaddr) &
 					   iface->ksni_netmask) == 0) ? 1 : 0;
 
-			if (!(best_iface == NULL ||
+			if (!(!best_iface ||
 			      best_netmatch < this_netmatch ||
 			      (best_netmatch == this_netmatch &&
 			       best_nroutes > iface->ksni_nroutes)))
@@ -962,7 +962,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 			best_nroutes = iface->ksni_nroutes;
 		}
 
-		if (best_iface == NULL)
+		if (!best_iface)
 			continue;
 
 		newroute->ksnr_myipaddr = best_iface->ksni_ipaddr;
@@ -973,7 +973,7 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 	}
 
 	write_unlock_bh(global_lock);
-	if (newroute != NULL)
+	if (newroute)
 		ksocknal_route_decref(newroute);
 }
 
@@ -989,7 +989,7 @@ ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
 	LASSERT(rc == 0);		      /* we succeeded before */
 
 	LIBCFS_ALLOC(cr, sizeof(*cr));
-	if (cr == NULL) {
+	if (!cr) {
 		LCONSOLE_ERROR_MSG(0x12f, "Dropping connection request from %pI4h: memory exhausted\n",
 				   &peer_ip);
 		return -ENOMEM;
@@ -1042,12 +1042,12 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	int active;
 	char *warn = NULL;
 
-	active = (route != NULL);
+	active = !!route;
 
 	LASSERT(active == (type != SOCKLND_CONN_NONE));
 
 	LIBCFS_ALLOC(conn, sizeof(*conn));
-	if (conn == NULL) {
+	if (!conn) {
 		rc = -ENOMEM;
 		goto failed_0;
 	}
@@ -1075,7 +1075,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 	LIBCFS_ALLOC(hello, offsetof(ksock_hello_msg_t,
 				     kshm_ips[LNET_MAX_INTERFACES]));
-	if (hello == NULL) {
+	if (!hello) {
 		rc = -ENOMEM;
 		goto failed_1;
 	}
@@ -1103,7 +1103,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		conn->ksnc_proto = peer->ksnp_proto;
 		write_unlock_bh(global_lock);
 
-		if (conn->ksnc_proto == NULL) {
+		if (!conn->ksnc_proto) {
 			 conn->ksnc_proto = &ksocknal_protocol_v3x;
 #if SOCKNAL_VERSION_DEBUG
 			 if (*ksocknal_tunables.ksnd_protocol == 2)
@@ -1129,7 +1129,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		goto failed_1;
 
 	LASSERT(rc == 0 || active);
-	LASSERT(conn->ksnc_proto != NULL);
+	LASSERT(conn->ksnc_proto);
 	LASSERT(peerid.nid != LNET_NID_ANY);
 
 	cpt = lnet_cpt_of_nid(peerid.nid);
@@ -1148,7 +1148,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		LASSERT(((ksock_net_t *) ni->ni_data)->ksnn_shutdown == 0);
 
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
-		if (peer2 == NULL) {
+		if (!peer2) {
 			/*
 			 * NB this puts an "empty" peer in the peer
 			 * table (which takes my ref)
@@ -1184,7 +1184,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		goto failed_2;
 	}
 
-	if (peer->ksnp_proto == NULL) {
+	if (!peer->ksnp_proto) {
 		/*
 		 * Never connected before.
 		 * NB recv_hello may have returned EPROTO to signal my peer
@@ -1386,7 +1386,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 	write_unlock_bh(global_lock);
 
-	if (warn != NULL) {
+	if (warn) {
 		if (rc < 0)
 			CERROR("Not creating conn %s type %d: %s\n",
 			       libcfs_id2str(peerid), conn->ksnc_type, warn);
@@ -1415,7 +1415,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	ksocknal_peer_decref(peer);
 
 failed_1:
-	if (hello != NULL)
+	if (hello)
 		LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
 					    kshm_ips[LNET_MAX_INTERFACES]));
 
@@ -1447,7 +1447,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 	list_del(&conn->ksnc_list);
 
 	route = conn->ksnc_route;
-	if (route != NULL) {
+	if (route) {
 		/* dissociate conn from route... */
 		LASSERT(!route->ksnr_deleted);
 		LASSERT((route->ksnr_connected & (1 << conn->ksnc_type)) != 0);
@@ -1462,7 +1462,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 
 			conn2 = NULL;
 		}
-		if (conn2 == NULL)
+		if (!conn2)
 			route->ksnr_connected &= ~(1 << conn->ksnc_type);
 
 		conn->ksnc_route = NULL;
@@ -1534,7 +1534,7 @@ ksocknal_peer_failed(ksock_peer_t *peer)
 	if ((peer->ksnp_id.pid & LNET_PID_USERFLAG) == 0 &&
 	    list_empty(&peer->ksnp_conns) &&
 	    peer->ksnp_accepting == 0 &&
-	    ksocknal_find_connecting_route_locked(peer) == NULL) {
+	    !ksocknal_find_connecting_route_locked(peer)) {
 		notify = 1;
 		last_alive = peer->ksnp_last_alive;
 	}
@@ -1558,7 +1558,7 @@ ksocknal_finalize_zcreq(ksock_conn_t *conn)
 	 * NB safe to finalize TXs because closing of socket will
 	 * abort all buffered data
 	 */
-	LASSERT(conn->ksnc_sock == NULL);
+	LASSERT(!conn->ksnc_sock);
 
 	spin_lock(&peer->ksnp_lock);
 
@@ -1675,8 +1675,8 @@ ksocknal_destroy_conn(ksock_conn_t *conn)
 
 	LASSERT(atomic_read(&conn->ksnc_conn_refcount) == 0);
 	LASSERT(atomic_read(&conn->ksnc_sock_refcount) == 0);
-	LASSERT(conn->ksnc_sock == NULL);
-	LASSERT(conn->ksnc_route == NULL);
+	LASSERT(!conn->ksnc_sock);
+	LASSERT(!conn->ksnc_route);
 	LASSERT(!conn->ksnc_tx_scheduled);
 	LASSERT(!conn->ksnc_rx_scheduled);
 	LASSERT(list_empty(&conn->ksnc_tx_queue));
@@ -1848,7 +1848,7 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	read_lock(glock);
 
 	peer = ksocknal_find_peer_locked(ni, id);
-	if (peer != NULL) {
+	if (peer) {
 		struct list_head *tmp;
 		ksock_conn_t *conn;
 		int bufnob;
@@ -1867,7 +1867,7 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 		}
 
 		last_alive = peer->ksnp_last_alive;
-		if (ksocknal_find_connectable_route_locked(peer) == NULL)
+		if (!ksocknal_find_connectable_route_locked(peer))
 			connect = 0;
 	}
 
@@ -1889,7 +1889,7 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	write_lock_bh(glock);
 
 	peer = ksocknal_find_peer_locked(ni, id);
-	if (peer != NULL)
+	if (peer)
 		ksocknal_launch_all_connections_locked(peer);
 
 	write_unlock_bh(glock);
@@ -1920,7 +1920,7 @@ ksocknal_push_peer(ksock_peer_t *peer)
 
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 
-		if (conn == NULL)
+		if (!conn)
 			break;
 
 		ksocknal_lib_push_conn(conn);
@@ -1997,7 +1997,7 @@ ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	iface = ksocknal_ip2iface(ni, ipaddress);
-	if (iface != NULL) {
+	if (iface) {
 		/* silently ignore dups */
 		rc = 0;
 	} else if (net->ksnn_ninterfaces == LNET_MAX_INTERFACES) {
@@ -2207,7 +2207,7 @@ ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 		int nagle;
 		ksock_conn_t *conn = ksocknal_get_conn_by_idx(ni, data->ioc_count);
 
-		if (conn == NULL)
+		if (!conn)
 			return -ENOENT;
 
 		ksocknal_lib_get_conn_tunables(conn, &txmem, &rxmem, &nagle);
@@ -2258,12 +2258,12 @@ ksocknal_free_buffers(void)
 {
 	LASSERT(atomic_read(&ksocknal_data.ksnd_nactive_txs) == 0);
 
-	if (ksocknal_data.ksnd_sched_info != NULL) {
+	if (ksocknal_data.ksnd_sched_info) {
 		struct ksock_sched_info *info;
 		int i;
 
 		cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
-			if (info->ksi_scheds != NULL) {
+			if (info->ksi_scheds) {
 				LIBCFS_FREE(info->ksi_scheds,
 					    info->ksi_nthreads_max *
 					    sizeof(info->ksi_scheds[0]));
@@ -2312,7 +2312,7 @@ ksocknal_base_shutdown(void)
 
 	case SOCKNAL_INIT_ALL:
 	case SOCKNAL_INIT_DATA:
-		LASSERT(ksocknal_data.ksnd_peers != NULL);
+		LASSERT(ksocknal_data.ksnd_peers);
 		for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++)
 			LASSERT(list_empty(&ksocknal_data.ksnd_peers[i]));
 
@@ -2322,10 +2322,10 @@ ksocknal_base_shutdown(void)
 		LASSERT(list_empty(&ksocknal_data.ksnd_connd_connreqs));
 		LASSERT(list_empty(&ksocknal_data.ksnd_connd_routes));
 
-		if (ksocknal_data.ksnd_sched_info != NULL) {
+		if (ksocknal_data.ksnd_sched_info) {
 			cfs_percpt_for_each(info, i,
 					    ksocknal_data.ksnd_sched_info) {
-				if (info->ksi_scheds == NULL)
+				if (!info->ksi_scheds)
 					continue;
 
 				for (j = 0; j < info->ksi_nthreads_max; j++) {
@@ -2346,10 +2346,10 @@ ksocknal_base_shutdown(void)
 		wake_up_all(&ksocknal_data.ksnd_connd_waitq);
 		wake_up_all(&ksocknal_data.ksnd_reaper_waitq);
 
-		if (ksocknal_data.ksnd_sched_info != NULL) {
+		if (ksocknal_data.ksnd_sched_info) {
 			cfs_percpt_for_each(info, i,
 					    ksocknal_data.ksnd_sched_info) {
-				if (info->ksi_scheds == NULL)
+				if (!info->ksi_scheds)
 					continue;
 
 				for (j = 0; j < info->ksi_nthreads_max; j++) {
@@ -2407,7 +2407,7 @@ ksocknal_base_startup(void)
 	LIBCFS_ALLOC(ksocknal_data.ksnd_peers,
 		     sizeof(struct list_head) *
 		     ksocknal_data.ksnd_peer_hash_size);
-	if (ksocknal_data.ksnd_peers == NULL)
+	if (!ksocknal_data.ksnd_peers)
 		return -ENOMEM;
 
 	for (i = 0; i < ksocknal_data.ksnd_peer_hash_size; i++)
@@ -2438,7 +2438,7 @@ ksocknal_base_startup(void)
 
 	ksocknal_data.ksnd_sched_info = cfs_percpt_alloc(lnet_cpt_table(),
 							 sizeof(*info));
-	if (ksocknal_data.ksnd_sched_info == NULL)
+	if (!ksocknal_data.ksnd_sched_info)
 		goto failed;
 
 	cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
@@ -2461,7 +2461,7 @@ ksocknal_base_startup(void)
 
 		LIBCFS_CPT_ALLOC(info->ksi_scheds, lnet_cpt_table(), i,
 				 info->ksi_nthreads_max * sizeof(*sched));
-		if (info->ksi_scheds == NULL)
+		if (!info->ksi_scheds)
 			goto failed;
 
 		for (; nthrs > 0; nthrs--) {
@@ -2547,7 +2547,7 @@ ksocknal_debug_peerhash(lnet_ni_t *ni)
 		}
 	}
 
-	if (peer != NULL) {
+	if (peer) {
 		ksock_route_t *route;
 		ksock_conn_t  *conn;
 
@@ -2703,7 +2703,7 @@ ksocknal_search_new_ipif(ksock_net_t *net)
 		ksock_net_t *tmp;
 		int j;
 
-		if (colon != NULL) /* ignore alias device */
+		if (colon) /* ignore alias device */
 			*colon = 0;
 
 		list_for_each_entry(tmp, &ksocknal_data.ksnd_nets, ksnn_list) {
@@ -2712,11 +2712,11 @@ ksocknal_search_new_ipif(ksock_net_t *net)
 					&tmp->ksnn_interfaces[j].ksni_name[0];
 				char *colon2 = strchr(ifnam2, ':');
 
-				if (colon2 != NULL)
+				if (colon2)
 					*colon2 = 0;
 
 				found = strcmp(ifnam, ifnam2) == 0;
-				if (colon2 != NULL)
+				if (colon2)
 					*colon2 = ':';
 			}
 			if (found)
@@ -2724,7 +2724,7 @@ ksocknal_search_new_ipif(ksock_net_t *net)
 		}
 
 		new_ipif += !found;
-		if (colon != NULL)
+		if (colon)
 			*colon = ':';
 	}
 
@@ -2789,7 +2789,7 @@ ksocknal_net_start_threads(ksock_net_t *net, __u32 *cpts, int ncpts)
 
 	for (i = 0; i < ncpts; i++) {
 		struct ksock_sched_info *info;
-		int cpt = (cpts == NULL) ? i : cpts[i];
+		int cpt = !cpts ? i : cpts[i];
 
 		LASSERT(cpt < cfs_cpt_number(lnet_cpt_table()));
 		info = ksocknal_data.ksnd_sched_info[cpt];
@@ -2820,7 +2820,7 @@ ksocknal_startup(lnet_ni_t *ni)
 	}
 
 	LIBCFS_ALLOC(net, sizeof(*net));
-	if (net == NULL)
+	if (!net)
 		goto fail_0;
 
 	spin_lock_init(&net->ksnn_lock);
@@ -2831,7 +2831,7 @@ ksocknal_startup(lnet_ni_t *ni)
 	ni->ni_peertxcredits  = *ksocknal_tunables.ksnd_peertxcredits;
 	ni->ni_peerrtrcredits = *ksocknal_tunables.ksnd_peerrtrcredits;
 
-	if (ni->ni_interfaces[0] == NULL) {
+	if (!ni->ni_interfaces[0]) {
 		rc = ksocknal_enumerate_interfaces(net);
 		if (rc <= 0)
 			goto fail_1;
@@ -2841,7 +2841,7 @@ ksocknal_startup(lnet_ni_t *ni)
 		for (i = 0; i < LNET_MAX_INTERFACES; i++) {
 			int up;
 
-			if (ni->ni_interfaces[i] == NULL)
+			if (!ni->ni_interfaces[i])
 				break;
 
 			rc = lnet_ipif_query(ni->ni_interfaces[i], &up,
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 16c9bac..f9ec607 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -47,10 +47,10 @@ ksocknal_alloc_tx(int type, int size)
 		spin_unlock(&ksocknal_data.ksnd_tx_lock);
 	}
 
-	if (tx == NULL)
+	if (!tx)
 		LIBCFS_ALLOC(tx, size);
 
-	if (tx == NULL)
+	if (!tx)
 		return NULL;
 
 	atomic_set(&tx->tx_refcount, 1);
@@ -70,7 +70,7 @@ ksocknal_alloc_tx_noop(__u64 cookie, int nonblk)
 	ksock_tx_t *tx;
 
 	tx = ksocknal_alloc_tx(KSOCK_MSG_NOOP, KSOCK_NOOP_TX_SIZE);
-	if (tx == NULL) {
+	if (!tx) {
 		CERROR("Can't allocate noop tx desc\n");
 		return NULL;
 	}
@@ -94,7 +94,7 @@ ksocknal_free_tx(ksock_tx_t *tx)
 {
 	atomic_dec(&ksocknal_data.ksnd_nactive_txs);
 
-	if (tx->tx_lnetmsg == NULL && tx->tx_desc_size == KSOCK_NOOP_TX_SIZE) {
+	if (!tx->tx_lnetmsg && tx->tx_desc_size == KSOCK_NOOP_TX_SIZE) {
 		/* it's a noop tx */
 		spin_lock(&ksocknal_data.ksnd_tx_lock);
 
@@ -399,16 +399,16 @@ ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx)
 	lnet_msg_t *lnetmsg = tx->tx_lnetmsg;
 	int rc = (tx->tx_resid == 0 && !tx->tx_zc_aborted) ? 0 : -EIO;
 
-	LASSERT(ni != NULL || tx->tx_conn != NULL);
+	LASSERT(ni || tx->tx_conn);
 
-	if (tx->tx_conn != NULL)
+	if (tx->tx_conn)
 		ksocknal_conn_decref(tx->tx_conn);
 
-	if (ni == NULL && tx->tx_conn != NULL)
+	if (!ni && tx->tx_conn)
 		ni = tx->tx_conn->ksnc_peer->ksnp_ni;
 
 	ksocknal_free_tx(tx);
-	if (lnetmsg != NULL) /* KSOCK_MSG_NOOP go without lnetmsg */
+	if (lnetmsg) /* KSOCK_MSG_NOOP go without lnetmsg */
 		lnet_finalize(ni, lnetmsg, rc);
 }
 
@@ -420,7 +420,7 @@ ksocknal_txlist_done(lnet_ni_t *ni, struct list_head *txlist, int error)
 	while (!list_empty(txlist)) {
 		tx = list_entry(txlist->next, ksock_tx_t, tx_list);
 
-		if (error && tx->tx_lnetmsg != NULL) {
+		if (error && tx->tx_lnetmsg) {
 			CNETERR("Deleting packet type %d len %d %s->%s\n",
 				le32_to_cpu(tx->tx_lnetmsg->msg_hdr.type),
 				le32_to_cpu(tx->tx_lnetmsg->msg_hdr.payload_length),
@@ -615,7 +615,7 @@ ksocknal_launch_all_connections_locked(ksock_peer_t *peer)
 	for (;;) {
 		/* launch any/all connections that need it */
 		route = ksocknal_find_connectable_route_locked(peer);
-		if (route == NULL)
+		if (!route)
 			return;
 
 		ksocknal_launch_connection_locked(route);
@@ -639,8 +639,8 @@ ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
 		int rc;
 
 		LASSERT(!c->ksnc_closing);
-		LASSERT(c->ksnc_proto != NULL &&
-			c->ksnc_proto->pro_match_tx != NULL);
+		LASSERT(c->ksnc_proto &&
+			c->ksnc_proto->pro_match_tx);
 
 		rc = c->ksnc_proto->pro_match_tx(c, tx, nonblk);
 
@@ -651,7 +651,7 @@ ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
 			continue;
 
 		case SOCKNAL_MATCH_YES: /* typed connection */
-			if (typed == NULL || tnob > nob ||
+			if (!typed || tnob > nob ||
 			    (tnob == nob && *ksocknal_tunables.ksnd_round_robin &&
 			     cfs_time_after(typed->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
 				typed = c;
@@ -660,7 +660,7 @@ ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
 			break;
 
 		case SOCKNAL_MATCH_MAY: /* fallback connection */
-			if (fallback == NULL || fnob > nob ||
+			if (!fallback || fnob > nob ||
 			    (fnob == nob && *ksocknal_tunables.ksnd_round_robin &&
 			     cfs_time_after(fallback->ksnc_tx_last_post, c->ksnc_tx_last_post))) {
 				fallback = c;
@@ -671,9 +671,9 @@ ksocknal_find_conn_locked(ksock_peer_t *peer, ksock_tx_t *tx, int nonblk)
 	}
 
 	/* prefer the typed selection */
-	conn = (typed != NULL) ? typed : fallback;
+	conn = (typed) ? typed : fallback;
 
-	if (conn != NULL)
+	if (conn)
 		conn->ksnc_tx_last_post = cfs_time_current();
 
 	return conn;
@@ -726,7 +726,7 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 	LASSERT(tx->tx_resid == tx->tx_nob);
 
 	CDEBUG(D_NET, "Packet %p type %d, nob %d niov %d nkiov %d\n",
-	       tx, (tx->tx_lnetmsg != NULL) ? tx->tx_lnetmsg->msg_hdr.type :
+	       tx, (tx->tx_lnetmsg) ? tx->tx_lnetmsg->msg_hdr.type :
 					      KSOCK_MSG_NOOP,
 	       tx->tx_nob, tx->tx_niov, tx->tx_nkiov);
 
@@ -753,7 +753,7 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 		 * on a normal packet so I don't need to send it
 		 */
 		LASSERT(msg->ksm_zc_cookies[1] != 0);
-		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack != NULL);
+		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack);
 
 		if (conn->ksnc_proto->pro_queue_tx_zcack(conn, tx, 0))
 			ztx = tx; /* ZC ACK piggybacked on ztx release tx later */
@@ -764,13 +764,13 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 		 * has been queued already?
 		 */
 		LASSERT(msg->ksm_zc_cookies[1] == 0);
-		LASSERT(conn->ksnc_proto->pro_queue_tx_msg != NULL);
+		LASSERT(conn->ksnc_proto->pro_queue_tx_msg);
 
 		ztx = conn->ksnc_proto->pro_queue_tx_msg(conn, tx);
 		/* ztx will be released later */
 	}
 
-	if (ztx != NULL) {
+	if (ztx) {
 		atomic_sub(ztx->tx_nob, &conn->ksnc_tx_nob);
 		list_add_tail(&ztx->tx_list, &sched->kss_zombie_noop_txs);
 	}
@@ -850,17 +850,17 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 	int retry;
 	int rc;
 
-	LASSERT(tx->tx_conn == NULL);
+	LASSERT(!tx->tx_conn);
 
 	g_lock = &ksocknal_data.ksnd_global_lock;
 
 	for (retry = 0;; retry = 1) {
 		read_lock(g_lock);
 		peer = ksocknal_find_peer_locked(ni, id);
-		if (peer != NULL) {
-			if (ksocknal_find_connectable_route_locked(peer) == NULL) {
+		if (peer) {
+			if (!ksocknal_find_connectable_route_locked(peer)) {
 				conn = ksocknal_find_conn_locked(peer, tx, tx->tx_nonblk);
-				if (conn != NULL) {
+				if (conn) {
 					/*
 					 * I've got no routes that need to be
 					 * connecting and I do have an actual
@@ -879,7 +879,7 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 		write_lock_bh(g_lock);
 
 		peer = ksocknal_find_peer_locked(ni, id);
-		if (peer != NULL)
+		if (peer)
 			break;
 
 		write_unlock_bh(g_lock);
@@ -908,7 +908,7 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 	ksocknal_launch_all_connections_locked(peer);
 
 	conn = ksocknal_find_conn_locked(peer, tx, tx->tx_nonblk);
-	if (conn != NULL) {
+	if (conn) {
 		/* Connection exists; queue message on it */
 		ksocknal_queue_tx_locked(tx, conn);
 		write_unlock_bh(g_lock);
@@ -916,7 +916,7 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 	}
 
 	if (peer->ksnp_accepting > 0 ||
-	    ksocknal_find_connecting_route_locked(peer) != NULL) {
+	    ksocknal_find_connecting_route_locked(peer)) {
 		/* the message is going to be pinned to the peer */
 		tx->tx_deadline =
 			cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
@@ -959,10 +959,10 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	LASSERT(payload_nob == 0 || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
 	/* payload is either all vaddrs or all pages */
-	LASSERT(!(payload_kiov != NULL && payload_iov != NULL));
+	LASSERT(!(payload_kiov && payload_iov));
 	LASSERT(!in_interrupt());
 
-	if (payload_iov != NULL)
+	if (payload_iov)
 		desc_size = offsetof(ksock_tx_t,
 				     tx_frags.virt.iov[1 + payload_niov]);
 	else
@@ -972,7 +972,7 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	if (lntmsg->msg_vmflush)
 		mpflag = cfs_memory_pressure_get_and_set();
 	tx = ksocknal_alloc_tx(KSOCK_MSG_LNET, desc_size);
-	if (tx == NULL) {
+	if (!tx) {
 		CERROR("Can't allocate tx desc type %d size %d\n",
 		       type, desc_size);
 		if (lntmsg->msg_vmflush)
@@ -983,7 +983,7 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	tx->tx_conn = NULL;		     /* set when assigned a conn */
 	tx->tx_lnetmsg = lntmsg;
 
-	if (payload_iov != NULL) {
+	if (payload_iov) {
 		tx->tx_kiov = NULL;
 		tx->tx_nkiov = 0;
 		tx->tx_iov = tx->tx_frags.virt.iov;
@@ -1048,7 +1048,7 @@ ksocknal_new_packet(ksock_conn_t *conn, int nob_to_skip)
 	unsigned int niov;
 	int skipped;
 
-	LASSERT(conn->ksnc_proto != NULL);
+	LASSERT(conn->ksnc_proto);
 
 	if ((*ksocknal_tunables.ksnd_eager_ack & conn->ksnc_type) != 0) {
 		/* Remind the socket to ack eagerly... */
@@ -1341,7 +1341,7 @@ ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	conn->ksnc_rx_nob_wanted = mlen;
 	conn->ksnc_rx_nob_left = rlen;
 
-	if (mlen == 0 || iov != NULL) {
+	if (mlen == 0 || iov) {
 		conn->ksnc_rx_nkiov = 0;
 		conn->ksnc_rx_kiov = NULL;
 		conn->ksnc_rx_iov = conn->ksnc_rx_iov_space.iov;
@@ -1678,7 +1678,7 @@ ksocknal_send_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 	LASSERT(hello->kshm_nips <= LNET_MAX_INTERFACES);
 
 	/* rely on caller to hold a ref on socket so it wouldn't disappear */
-	LASSERT(conn->ksnc_proto != NULL);
+	LASSERT(conn->ksnc_proto);
 
 	hello->kshm_src_nid = ni->ni_nid;
 	hello->kshm_dst_nid = peer_nid;
@@ -1717,7 +1717,7 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 	 *	EPROTO     protocol version mismatch
 	 */
 	struct socket *sock = conn->ksnc_sock;
-	int active = (conn->ksnc_proto != NULL);
+	int active = !!conn->ksnc_proto;
 	int timeout;
 	int proto_match;
 	int rc;
@@ -1759,7 +1759,7 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 	}
 
 	proto = ksocknal_parse_proto_version(hello);
-	if (proto == NULL) {
+	if (!proto) {
 		if (!active) {
 			/* unknown protocol from peer, tell peer my protocol */
 			conn->ksnc_proto = &ksocknal_protocol_v3x;
@@ -1991,7 +1991,7 @@ ksocknal_connect(ksock_route_t *route)
 
 	if (!list_empty(&peer->ksnp_tx_queue) &&
 	    peer->ksnp_accepting == 0 &&
-	    ksocknal_find_connecting_route_locked(peer) == NULL) {
+	    !ksocknal_find_connecting_route_locked(peer)) {
 		ksock_conn_t *conn;
 
 		/*
@@ -2219,7 +2219,7 @@ ksocknal_connd(void *arg)
 		    ksocknal_data.ksnd_connd_running) {
 			route = ksocknal_connd_get_route_locked(&timeout);
 		}
-		if (route != NULL) {
+		if (route) {
 			list_del(&route->ksnr_connd_list);
 			ksocknal_data.ksnd_connd_connecting++;
 			spin_unlock_bh(connd_lock);
@@ -2407,7 +2407,7 @@ ksocknal_send_keepalive_locked(ksock_peer_t *peer)
 	peer->ksnp_send_keepalive = cfs_time_shift(10);
 
 	conn = ksocknal_find_conn_locked(peer, NULL, 1);
-	if (conn != NULL) {
+	if (conn) {
 		sched = conn->ksnc_scheduler;
 
 		spin_lock_bh(&sched->kss_lock);
@@ -2424,7 +2424,7 @@ ksocknal_send_keepalive_locked(ksock_peer_t *peer)
 
 	/* cookie = 1 is reserved for keepalive PING */
 	tx = ksocknal_alloc_tx_noop(1, 1);
-	if (tx == NULL) {
+	if (!tx) {
 		read_lock(&ksocknal_data.ksnd_global_lock);
 		return -ENOMEM;
 	}
@@ -2468,7 +2468,7 @@ ksocknal_check_peer_timeouts(int idx)
 
 		conn = ksocknal_find_timed_out_conn(peer);
 
-		if (conn != NULL) {
+		if (conn) {
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 
 			ksocknal_close_conn_and_siblings(conn, -ETIMEDOUT);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index db5662b..40ce45d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -126,7 +126,7 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 	int nob;
 
 	/* Not NOOP message */
-	LASSERT(tx->tx_lnetmsg != NULL);
+	LASSERT(tx->tx_lnetmsg);
 
 	/*
 	 * NB we can't trust socket ops to either consume our iovs
@@ -147,7 +147,7 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 		    fragsize < tx->tx_resid)
 			msgflg |= MSG_MORE;
 
-		if (sk->sk_prot->sendpage != NULL) {
+		if (sk->sk_prot->sendpage) {
 			rc = sk->sk_prot->sendpage(sk, page,
 						   offset, fragsize, msgflg);
 		} else {
@@ -266,7 +266,7 @@ ksocknal_lib_recv_iov(ksock_conn_t *conn)
 static void
 ksocknal_lib_kiov_vunmap(void *addr)
 {
-	if (addr == NULL)
+	if (!addr)
 		return;
 
 	vunmap(addr);
@@ -280,7 +280,7 @@ ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
 	int nob;
 	int i;
 
-	if (!*ksocknal_tunables.ksnd_zc_recv || pages == NULL)
+	if (!*ksocknal_tunables.ksnd_zc_recv || !pages)
 		return NULL;
 
 	LASSERT(niov <= LNET_MAX_IOV);
@@ -299,7 +299,7 @@ ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
 	}
 
 	addr = vmap(pages, niov, VM_MAP, PAGE_KERNEL);
-	if (addr == NULL)
+	if (!addr)
 		return NULL;
 
 	iov->iov_base = addr + kiov[0].kiov_offset;
@@ -342,7 +342,7 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 	 * or leave them alone.
 	 */
 	addr = ksocknal_lib_kiov_vmap(kiov, niov, scratchiov, pages);
-	if (addr != NULL) {
+	if (addr) {
 		nob = scratchiov[0].iov_len;
 		n = 1;
 
@@ -382,7 +382,7 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 		}
 	}
 
-	if (addr != NULL) {
+	if (addr) {
 		ksocknal_lib_kiov_vunmap(addr);
 	} else {
 		for (i = 0; i < niov; i++)
@@ -400,7 +400,7 @@ ksocknal_lib_csum_tx(ksock_tx_t *tx)
 	void *base;
 
 	LASSERT(tx->tx_iov[0].iov_base == &tx->tx_msg);
-	LASSERT(tx->tx_conn != NULL);
+	LASSERT(tx->tx_conn);
 	LASSERT(tx->tx_conn->ksnc_proto == &ksocknal_protocol_v2x);
 
 	tx->tx_msg.ksm_csum = 0;
@@ -408,7 +408,7 @@ ksocknal_lib_csum_tx(ksock_tx_t *tx)
 	csum = ksocknal_csum(~0, tx->tx_iov[0].iov_base,
 			     tx->tx_iov[0].iov_len);
 
-	if (tx->tx_kiov != NULL) {
+	if (tx->tx_kiov) {
 		for (i = 0; i < tx->tx_nkiov; i++) {
 			base = kmap(tx->tx_kiov[i].kiov_page) +
 			       tx->tx_kiov[i].kiov_offset;
@@ -606,7 +606,7 @@ ksocknal_data_ready(struct sock *sk)
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	conn = sk->sk_user_data;
-	if (conn == NULL) {	     /* raced with ksocknal_terminate_conn */
+	if (!conn) {	     /* raced with ksocknal_terminate_conn */
 		LASSERT(sk->sk_data_ready != &ksocknal_data_ready);
 		sk->sk_data_ready(sk);
 	} else {
@@ -633,14 +633,14 @@ ksocknal_write_space(struct sock *sk)
 
 	CDEBUG(D_NET, "sk %p wspace %d low water %d conn %p%s%s%s\n",
 	       sk, wspace, min_wpace, conn,
-	       (conn == NULL) ? "" : (conn->ksnc_tx_ready ?
+	       !conn ? "" : (conn->ksnc_tx_ready ?
 				      " ready" : " blocked"),
-	       (conn == NULL) ? "" : (conn->ksnc_tx_scheduled ?
+	       !conn ? "" : (conn->ksnc_tx_scheduled ?
 				      " scheduled" : " idle"),
-	       (conn == NULL) ? "" : (list_empty(&conn->ksnc_tx_queue) ?
+	       !conn ? "" : (list_empty(&conn->ksnc_tx_queue) ?
 				      " empty" : " queued"));
 
-	if (conn == NULL) {	     /* raced with ksocknal_terminate_conn */
+	if (!conn) {	     /* raced with ksocknal_terminate_conn */
 		LASSERT(sk->sk_write_space != &ksocknal_write_space);
 		sk->sk_write_space(sk);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 041f972..d504685 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -56,7 +56,7 @@ ksocknal_next_tx_carrier(ksock_conn_t *conn)
 
 	/* Called holding BH lock: conn->ksnc_scheduler->kss_lock */
 	LASSERT(!list_empty(&conn->ksnc_tx_queue));
-	LASSERT(tx != NULL);
+	LASSERT(tx);
 
 	/* Next TX that can carry ZC-ACK or LNet message */
 	if (tx->tx_list.next == &conn->ksnc_tx_queue) {
@@ -75,7 +75,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 {
 	ksock_tx_t *tx = conn->ksnc_tx_carrier;
 
-	LASSERT(tx_ack == NULL ||
+	LASSERT(!tx_ack ||
 		tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
 	/*
@@ -85,8 +85,8 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 	 * . There is tx can piggyback cookie of tx_ack (or cookie),
 	 *   piggyback the cookie and return the tx.
 	 */
-	if (tx == NULL) {
-		if (tx_ack != NULL) {
+	if (!tx) {
+		if (tx_ack) {
 			list_add_tail(&tx_ack->tx_list,
 				      &conn->ksnc_tx_queue);
 			conn->ksnc_tx_carrier = tx_ack;
@@ -96,7 +96,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 
 	if (tx->tx_msg.ksm_type == KSOCK_MSG_NOOP) {
 		/* tx is noop zc-ack, can't piggyback zc-ack cookie */
-		if (tx_ack != NULL)
+		if (tx_ack)
 			list_add_tail(&tx_ack->tx_list,
 				      &conn->ksnc_tx_queue);
 		return 0;
@@ -105,7 +105,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 	LASSERT(tx->tx_msg.ksm_type == KSOCK_MSG_LNET);
 	LASSERT(tx->tx_msg.ksm_zc_cookies[1] == 0);
 
-	if (tx_ack != NULL)
+	if (tx_ack)
 		cookie = tx_ack->tx_msg.ksm_zc_cookies[1];
 
 	/* piggyback the zc-ack cookie */
@@ -128,7 +128,7 @@ ksocknal_queue_tx_msg_v2(ksock_conn_t *conn, ksock_tx_t *tx_msg)
 	 * . If there is NOOP on the connection, piggyback the cookie
 	 *   and replace the NOOP tx, and return the NOOP tx.
 	 */
-	if (tx == NULL) { /* nothing on queue */
+	if (!tx) { /* nothing on queue */
 		list_add_tail(&tx_msg->tx_list, &conn->ksnc_tx_queue);
 		conn->ksnc_tx_carrier = tx_msg;
 		return NULL;
@@ -162,12 +162,12 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 		return ksocknal_queue_tx_zcack_v2(conn, tx_ack, cookie);
 
 	/* non-blocking ZC-ACK (to router) */
-	LASSERT(tx_ack == NULL ||
+	LASSERT(!tx_ack ||
 		tx_ack->tx_msg.ksm_type == KSOCK_MSG_NOOP);
 
 	tx = conn->ksnc_tx_carrier;
-	if (tx == NULL) {
-		if (tx_ack != NULL) {
+	if (!tx) {
+		if (tx_ack) {
 			list_add_tail(&tx_ack->tx_list,
 				      &conn->ksnc_tx_queue);
 			conn->ksnc_tx_carrier = tx_ack;
@@ -175,9 +175,9 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 		return 0;
 	}
 
-	/* conn->ksnc_tx_carrier != NULL */
+	/* conn->ksnc_tx_carrier */
 
-	if (tx_ack != NULL)
+	if (tx_ack)
 		cookie = tx_ack->tx_msg.ksm_zc_cookies[1];
 
 	if (cookie == SOCKNAL_KEEPALIVE_PING) /* ignore keepalive PING */
@@ -261,7 +261,7 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 	}
 
 	/* failed to piggyback ZC-ACK */
-	if (tx_ack != NULL) {
+	if (tx_ack) {
 		list_add_tail(&tx_ack->tx_list, &conn->ksnc_tx_queue);
 		/* the next tx can piggyback at least 1 ACK */
 		ksocknal_next_tx_carrier(conn);
@@ -280,7 +280,7 @@ ksocknal_match_tx(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
 		return SOCKNAL_MATCH_YES;
 #endif
 
-	if (tx == NULL || tx->tx_lnetmsg == NULL) {
+	if (!tx || !tx->tx_lnetmsg) {
 		/* noop packet */
 		nob = offsetof(ksock_msg_t, ksm_u);
 	} else {
@@ -319,7 +319,7 @@ ksocknal_match_tx_v3(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
 {
 	int nob;
 
-	if (tx == NULL || tx->tx_lnetmsg == NULL)
+	if (!tx || !tx->tx_lnetmsg)
 		nob = offsetof(ksock_msg_t, ksm_u);
 	else
 		nob = tx->tx_lnetmsg->msg_len + sizeof(ksock_msg_t);
@@ -334,7 +334,7 @@ ksocknal_match_tx_v3(ksock_conn_t *conn, ksock_tx_t *tx, int nonblk)
 	case SOCKLND_CONN_ACK:
 		if (nonblk)
 			return SOCKNAL_MATCH_YES;
-		else if (tx == NULL || tx->tx_lnetmsg == NULL)
+		else if (!tx || !tx->tx_lnetmsg)
 			return SOCKNAL_MATCH_MAY;
 		else
 			return SOCKNAL_MATCH_NO;
@@ -369,10 +369,10 @@ ksocknal_handle_zcreq(ksock_conn_t *c, __u64 cookie, int remote)
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	conn = ksocknal_find_conn_locked(peer, NULL, !!remote);
-	if (conn != NULL) {
+	if (conn) {
 		ksock_sched_t *sched = conn->ksnc_scheduler;
 
-		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack != NULL);
+		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack);
 
 		spin_lock_bh(&sched->kss_lock);
 
@@ -390,7 +390,7 @@ ksocknal_handle_zcreq(ksock_conn_t *c, __u64 cookie, int remote)
 
 	/* ACK connection is not ready, or can't piggyback the ACK */
 	tx = ksocknal_alloc_tx_noop(cookie, !!remote);
-	if (tx == NULL)
+	if (!tx)
 		return -ENOMEM;
 
 	rc = ksocknal_launch_packet(peer->ksnp_ni, tx, peer->ksnp_id);
@@ -461,7 +461,7 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	CLASSERT(sizeof(lnet_magicversion_t) == offsetof(lnet_hdr_t, src_nid));
 
 	LIBCFS_ALLOC(hdr, sizeof(*hdr));
-	if (hdr == NULL) {
+	if (!hdr) {
 		CERROR("Can't allocate lnet_hdr_t\n");
 		return -ENOMEM;
 	}
@@ -576,7 +576,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 	int i;
 
 	LIBCFS_ALLOC(hdr, sizeof(*hdr));
-	if (hdr == NULL) {
+	if (!hdr) {
 		CERROR("Can't allocate lnet_hdr_t\n");
 		return -ENOMEM;
 	}
@@ -713,7 +713,7 @@ ksocknal_pack_msg_v1(ksock_tx_t *tx)
 {
 	/* V1.x has no KSOCK_MSG_NOOP */
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
-	LASSERT(tx->tx_lnetmsg != NULL);
+	LASSERT(tx->tx_lnetmsg);
 
 	tx->tx_iov[0].iov_base = &tx->tx_lnetmsg->msg_hdr;
 	tx->tx_iov[0].iov_len  = sizeof(lnet_hdr_t);
@@ -727,7 +727,7 @@ ksocknal_pack_msg_v2(ksock_tx_t *tx)
 {
 	tx->tx_iov[0].iov_base = &tx->tx_msg;
 
-	if (tx->tx_lnetmsg != NULL) {
+	if (tx->tx_lnetmsg) {
 		LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 
 		tx->tx_msg.ksm_u.lnetmsg.ksnm_hdr = tx->tx_lnetmsg->msg_hdr;
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 8c95cc5..ef61eaf 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -299,16 +299,16 @@ lnet_accept(struct socket *sock, __u32 magic)
 		__swab64s(&cr.acr_nid);
 
 	ni = lnet_net2ni(LNET_NIDNET(cr.acr_nid));
-	if (ni == NULL ||	       /* no matching net */
+	if (!ni ||	       /* no matching net */
 	    ni->ni_nid != cr.acr_nid) { /* right NET, wrong NID! */
-		if (ni != NULL)
+		if (ni)
 			lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x120, "Refusing connection from %pI4h for %s: No matching NI\n",
 				   &peer_ip, libcfs_nid2str(cr.acr_nid));
 		return -EPERM;
 	}
 
-	if (ni->ni_lnd->lnd_accept == NULL) {
+	if (!ni->ni_lnd->lnd_accept) {
 		/* This catches a request for the loopback LND */
 		lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x121, "Refusing connection from %pI4h for %s: NI doesn not accept IP connections\n",
@@ -335,7 +335,7 @@ lnet_acceptor(void *arg)
 	int peer_port;
 	int secure = (int)((long_ptr_t)arg);
 
-	LASSERT(lnet_acceptor_state.pta_sock == NULL);
+	LASSERT(!lnet_acceptor_state.pta_sock);
 
 	cfs_block_allsigs();
 
@@ -443,7 +443,7 @@ lnet_acceptor_start(void)
 	long rc2;
 	long secure;
 
-	LASSERT(lnet_acceptor_state.pta_sock == NULL);
+	LASSERT(!lnet_acceptor_state.pta_sock);
 
 	rc = lnet_acceptor_get_tunables();
 	if (rc != 0)
@@ -471,11 +471,11 @@ lnet_acceptor_start(void)
 
 	if (!lnet_acceptor_state.pta_shutdown) {
 		/* started OK */
-		LASSERT(lnet_acceptor_state.pta_sock != NULL);
+		LASSERT(lnet_acceptor_state.pta_sock);
 		return 0;
 	}
 
-	LASSERT(lnet_acceptor_state.pta_sock == NULL);
+	LASSERT(!lnet_acceptor_state.pta_sock);
 
 	return -ENETDOWN;
 }
@@ -483,7 +483,7 @@ lnet_acceptor_start(void)
 void
 lnet_acceptor_stop(void)
 {
-	if (lnet_acceptor_state.pta_sock == NULL) /* not running */
+	if (!lnet_acceptor_state.pta_sock) /* not running */
 		return;
 
 	lnet_acceptor_state.pta_shutdown = 1;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f7d53cd..eb04958 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -107,10 +107,10 @@ lnet_create_remote_nets_table(void)
 	int i;
 	struct list_head *hash;
 
-	LASSERT(the_lnet.ln_remote_nets_hash == NULL);
+	LASSERT(!the_lnet.ln_remote_nets_hash);
 	LASSERT(the_lnet.ln_remote_nets_hbits > 0);
 	LIBCFS_ALLOC(hash, LNET_REMOTE_NETS_HASH_SIZE * sizeof(*hash));
-	if (hash == NULL) {
+	if (!hash) {
 		CERROR("Failed to create remote nets hash table\n");
 		return -ENOMEM;
 	}
@@ -126,7 +126,7 @@ lnet_destroy_remote_nets_table(void)
 {
 	int i;
 
-	if (the_lnet.ln_remote_nets_hash == NULL)
+	if (!the_lnet.ln_remote_nets_hash)
 		return;
 
 	for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE; i++)
@@ -141,12 +141,12 @@ lnet_destroy_remote_nets_table(void)
 static void
 lnet_destroy_locks(void)
 {
-	if (the_lnet.ln_res_lock != NULL) {
+	if (the_lnet.ln_res_lock) {
 		cfs_percpt_lock_free(the_lnet.ln_res_lock);
 		the_lnet.ln_res_lock = NULL;
 	}
 
-	if (the_lnet.ln_net_lock != NULL) {
+	if (the_lnet.ln_net_lock) {
 		cfs_percpt_lock_free(the_lnet.ln_net_lock);
 		the_lnet.ln_net_lock = NULL;
 	}
@@ -158,11 +158,11 @@ lnet_create_locks(void)
 	lnet_init_locks();
 
 	the_lnet.ln_res_lock = cfs_percpt_lock_alloc(lnet_cpt_table());
-	if (the_lnet.ln_res_lock == NULL)
+	if (!the_lnet.ln_res_lock)
 		goto failed;
 
 	the_lnet.ln_net_lock = cfs_percpt_lock_alloc(lnet_cpt_table());
-	if (the_lnet.ln_net_lock == NULL)
+	if (!the_lnet.ln_net_lock)
 		goto failed;
 
 	return 0;
@@ -291,7 +291,7 @@ lnet_register_lnd(lnd_t *lnd)
 
 	LASSERT(the_lnet.ln_init);
 	LASSERT(libcfs_isknown_lnd(lnd->lnd_type));
-	LASSERT(lnet_find_lnd_by_type(lnd->lnd_type) == NULL);
+	LASSERT(!lnet_find_lnd_by_type(lnd->lnd_type));
 
 	list_add_tail(&lnd->lnd_list, &the_lnet.ln_lnds);
 	lnd->lnd_refcount = 0;
@@ -408,7 +408,7 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 		       count, lnet_res_type2str(rec->rec_type));
 	}
 
-	if (rec->rec_lh_hash != NULL) {
+	if (rec->rec_lh_hash) {
 		LIBCFS_FREE(rec->rec_lh_hash,
 			    LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]));
 		rec->rec_lh_hash = NULL;
@@ -432,7 +432,7 @@ lnet_res_container_setup(struct lnet_res_container *rec, int cpt, int type)
 	/* Arbitrary choice of hash table size */
 	LIBCFS_CPT_ALLOC(rec->rec_lh_hash, lnet_cpt_table(), cpt,
 			 LNET_LH_HASH_SIZE * sizeof(rec->rec_lh_hash[0]));
-	if (rec->rec_lh_hash == NULL) {
+	if (!rec->rec_lh_hash) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -470,7 +470,7 @@ lnet_res_containers_create(int type)
 	int i;
 
 	recs = cfs_percpt_alloc(lnet_cpt_table(), sizeof(*rec));
-	if (recs == NULL) {
+	if (!recs) {
 		CERROR("Failed to allocate %s resource containers\n",
 		       lnet_res_type2str(type));
 		return NULL;
@@ -557,7 +557,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 
 	the_lnet.ln_counters = cfs_percpt_alloc(lnet_cpt_table(),
 						sizeof(lnet_counters_t));
-	if (the_lnet.ln_counters == NULL) {
+	if (!the_lnet.ln_counters) {
 		CERROR("Failed to allocate counters for LNet\n");
 		rc = -ENOMEM;
 		goto failed;
@@ -577,7 +577,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 		goto failed;
 
 	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME);
-	if (recs == NULL) {
+	if (!recs) {
 		rc = -ENOMEM;
 		goto failed;
 	}
@@ -585,7 +585,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	the_lnet.ln_me_containers = recs;
 
 	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD);
-	if (recs == NULL) {
+	if (!recs) {
 		rc = -ENOMEM;
 		goto failed;
 	}
@@ -624,12 +624,12 @@ lnet_unprepare(void)
 
 	lnet_portals_destroy();
 
-	if (the_lnet.ln_md_containers != NULL) {
+	if (the_lnet.ln_md_containers) {
 		lnet_res_containers_destroy(the_lnet.ln_md_containers);
 		the_lnet.ln_md_containers = NULL;
 	}
 
-	if (the_lnet.ln_me_containers != NULL) {
+	if (the_lnet.ln_me_containers) {
 		lnet_res_containers_destroy(the_lnet.ln_me_containers);
 		the_lnet.ln_me_containers = NULL;
 	}
@@ -640,7 +640,7 @@ lnet_unprepare(void)
 	lnet_peer_tables_destroy();
 	lnet_rtrpools_free();
 
-	if (the_lnet.ln_counters != NULL) {
+	if (the_lnet.ln_counters) {
 		cfs_percpt_free(the_lnet.ln_counters);
 		the_lnet.ln_counters = NULL;
 	}
@@ -716,7 +716,7 @@ lnet_cpt_of_nid_locked(lnet_nid_t nid)
 			if (LNET_NIDNET(ni->ni_nid) != LNET_NIDNET(nid))
 				continue;
 
-			LASSERT(ni->ni_cpts != NULL);
+			LASSERT(ni->ni_cpts);
 			return ni->ni_cpts[lnet_nid_cpt_hash
 					   (nid, ni->ni_ncpts)];
 		}
@@ -754,12 +754,12 @@ lnet_islocalnet(__u32 net)
 	cpt = lnet_net_lock_current();
 
 	ni = lnet_net2ni_locked(net, cpt);
-	if (ni != NULL)
+	if (ni)
 		lnet_ni_decref_locked(ni, cpt);
 
 	lnet_net_unlock(cpt);
 
-	return ni != NULL;
+	return !!ni;
 }
 
 lnet_ni_t  *
@@ -790,11 +790,11 @@ lnet_islocalnid(lnet_nid_t nid)
 
 	cpt = lnet_net_lock_current();
 	ni = lnet_nid2ni_locked(nid, cpt);
-	if (ni != NULL)
+	if (ni)
 		lnet_ni_decref_locked(ni, cpt);
 	lnet_net_unlock(cpt);
 
-	return ni != NULL;
+	return !!ni;
 }
 
 int
@@ -810,7 +810,7 @@ lnet_count_acceptor_nis(void)
 	list_for_each(tmp, &the_lnet.ln_nis) {
 		ni = list_entry(tmp, lnet_ni_t, ni_list);
 
-		if (ni->ni_lnd->lnd_accept != NULL)
+		if (ni->ni_lnd->lnd_accept)
 			count++;
 	}
 
@@ -868,13 +868,13 @@ lnet_shutdown_lndnis(void)
 	}
 
 	/* Drop the cached eqwait NI. */
-	if (the_lnet.ln_eq_waitni != NULL) {
+	if (the_lnet.ln_eq_waitni) {
 		lnet_ni_decref_locked(the_lnet.ln_eq_waitni, 0);
 		the_lnet.ln_eq_waitni = NULL;
 	}
 
 	/* Drop the cached loopback NI. */
-	if (the_lnet.ln_loni != NULL) {
+	if (the_lnet.ln_loni) {
 		lnet_ni_decref_locked(the_lnet.ln_loni, 0);
 		the_lnet.ln_loni = NULL;
 	}
@@ -953,7 +953,7 @@ lnet_shutdown_lndnis(void)
 	the_lnet.ln_shutdown = 0;
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	if (the_lnet.ln_network_tokens != NULL) {
+	if (the_lnet.ln_network_tokens) {
 		LIBCFS_FREE(the_lnet.ln_network_tokens,
 			    the_lnet.ln_network_tokens_nob);
 		the_lnet.ln_network_tokens = NULL;
@@ -975,7 +975,7 @@ lnet_startup_lndnis(void)
 
 	INIT_LIST_HEAD(&nilist);
 
-	if (nets == NULL)
+	if (!nets)
 		goto failed;
 
 	rc = lnet_parse_networks(&nilist, nets);
@@ -1000,14 +1000,14 @@ lnet_startup_lndnis(void)
 		mutex_lock(&the_lnet.ln_lnd_mutex);
 		lnd = lnet_find_lnd_by_type(lnd_type);
 
-		if (lnd == NULL) {
+		if (!lnd) {
 			mutex_unlock(&the_lnet.ln_lnd_mutex);
 			rc = request_module("%s",
 					    libcfs_lnd2modname(lnd_type));
 			mutex_lock(&the_lnet.ln_lnd_mutex);
 
 			lnd = lnet_find_lnd_by_type(lnd_type);
-			if (lnd == NULL) {
+			if (!lnd) {
 				mutex_unlock(&the_lnet.ln_lnd_mutex);
 				CERROR("Can't load LND %s, module %s, rc=%d\n",
 				       libcfs_lnd2str(lnd_type),
@@ -1035,7 +1035,7 @@ lnet_startup_lndnis(void)
 			goto failed;
 		}
 
-		LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query != NULL);
+		LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
 
 		list_del(&ni->ni_list);
 
@@ -1043,7 +1043,7 @@ lnet_startup_lndnis(void)
 		/* refcount for ln_nis */
 		lnet_ni_addref_locked(ni, 0);
 		list_add_tail(&ni->ni_list, &the_lnet.ln_nis);
-		if (ni->ni_cpts != NULL) {
+		if (ni->ni_cpts) {
 			list_add_tail(&ni->ni_cptlist,
 				      &the_lnet.ln_nis_cpt);
 			lnet_ni_addref_locked(ni, 0);
@@ -1053,7 +1053,7 @@ lnet_startup_lndnis(void)
 
 		if (lnd->lnd_type == LOLND) {
 			lnet_ni_addref(ni);
-			LASSERT(the_lnet.ln_loni == NULL);
+			LASSERT(!the_lnet.ln_loni);
 			the_lnet.ln_loni = ni;
 			continue;
 		}
@@ -1081,7 +1081,7 @@ lnet_startup_lndnis(void)
 		nicount++;
 	}
 
-	if (the_lnet.ln_eq_waitni != NULL && nicount > 1) {
+	if (the_lnet.ln_eq_waitni && nicount > 1) {
 		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
 		LCONSOLE_ERROR_MSG(0x109, "LND %s can only run single-network\n",
 				   libcfs_lnd2str(lnd_type));
@@ -1402,10 +1402,10 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	default:
 		ni = lnet_net2ni(data->ioc_net);
-		if (ni == NULL)
+		if (!ni)
 			return -EINVAL;
 
-		if (ni->ni_lnd->lnd_ctl == NULL)
+		if (!ni->ni_lnd->lnd_ctl)
 			rc = -EINVAL;
 		else
 			rc = ni->ni_lnd->lnd_ctl(ni, cmd, arg);
@@ -1499,7 +1499,7 @@ lnet_create_ping_info(void)
 
 	infosz = offsetof(lnet_ping_info_t, pi_ni[n]);
 	LIBCFS_ALLOC(pinfo, infosz);
-	if (pinfo == NULL) {
+	if (!pinfo) {
 		CERROR("Can't allocate ping info[%d]\n", n);
 		return -ENOMEM;
 	}
@@ -1521,10 +1521,10 @@ lnet_create_ping_info(void)
 		lnet_net_lock(0);
 
 		ni = lnet_nid2ni_locked(id.nid, 0);
-		LASSERT(ni != NULL);
+		LASSERT(ni);
 
 		lnet_ni_lock(ni);
-		LASSERT(ni->ni_status == NULL);
+		LASSERT(!ni->ni_status);
 		ni->ni_status = ns;
 		lnet_ni_unlock(ni);
 
@@ -1694,7 +1694,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		id.pid = LUSTRE_SRV_LNET_PID;
 
 	LIBCFS_ALLOC(info, infosz);
-	if (info == NULL)
+	if (!info)
 		return -ENOMEM;
 
 	/* NB 2 events max (including any unlink event) */
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index d02353d..fcd2cfb 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -96,13 +96,13 @@ lnet_net_unique(__u32 net, struct list_head *nilist)
 void
 lnet_ni_free(struct lnet_ni *ni)
 {
-	if (ni->ni_refs != NULL)
+	if (ni->ni_refs)
 		cfs_percpt_free(ni->ni_refs);
 
-	if (ni->ni_tx_queues != NULL)
+	if (ni->ni_tx_queues)
 		cfs_percpt_free(ni->ni_tx_queues);
 
-	if (ni->ni_cpts != NULL)
+	if (ni->ni_cpts)
 		cfs_expr_list_values_free(ni->ni_cpts, ni->ni_ncpts);
 
 	LIBCFS_FREE(ni, sizeof(*ni));
@@ -123,7 +123,7 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 	}
 
 	LIBCFS_ALLOC(ni, sizeof(*ni));
-	if (ni == NULL) {
+	if (!ni) {
 		CERROR("Out of memory creating network %s\n",
 		       libcfs_net2str(net));
 		return NULL;
@@ -133,18 +133,18 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 	INIT_LIST_HEAD(&ni->ni_cptlist);
 	ni->ni_refs = cfs_percpt_alloc(lnet_cpt_table(),
 				       sizeof(*ni->ni_refs[0]));
-	if (ni->ni_refs == NULL)
+	if (!ni->ni_refs)
 		goto failed;
 
 	ni->ni_tx_queues = cfs_percpt_alloc(lnet_cpt_table(),
 					    sizeof(*ni->ni_tx_queues[0]));
-	if (ni->ni_tx_queues == NULL)
+	if (!ni->ni_tx_queues)
 		goto failed;
 
 	cfs_percpt_for_each(tq, i, ni->ni_tx_queues)
 		INIT_LIST_HEAD(&tq->tq_delayed);
 
-	if (el == NULL) {
+	if (!el) {
 		ni->ni_cpts  = NULL;
 		ni->ni_ncpts = LNET_CPT_NUMBER;
 	} else {
@@ -194,7 +194,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	}
 
 	LIBCFS_ALLOC(tokens, tokensize);
-	if (tokens == NULL) {
+	if (!tokens) {
 		CERROR("Can't allocate net tokens\n");
 		return -ENOMEM;
 	}
@@ -207,10 +207,10 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 
 	/* Add in the loopback network */
 	ni = lnet_ni_alloc(LNET_MKNET(LOLND, 0), NULL, nilist);
-	if (ni == NULL)
+	if (!ni)
 		goto failed;
 
-	while (str != NULL && *str != 0) {
+	while (str && *str != 0) {
 		char *comma = strchr(str, ',');
 		char *bracket = strchr(str, '(');
 		char *square = strchr(str, '[');
@@ -222,18 +222,18 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		 * NB we don't check interface conflicts here; it's the LNDs
 		 * responsibility (if it cares at all)
 		 */
-		if (square != NULL && (comma == NULL || square < comma)) {
+		if (square && (!comma || square < comma)) {
 			/*
 			 * i.e: o2ib0(ib0)[1,2], number between square
 			 * brackets are CPTs this NI needs to be bond
 			 */
-			if (bracket != NULL && bracket > square) {
+			if (bracket && bracket > square) {
 				tmp = square;
 				goto failed_syntax;
 			}
 
 			tmp = strchr(square, ']');
-			if (tmp == NULL) {
+			if (!tmp) {
 				tmp = square;
 				goto failed_syntax;
 			}
@@ -249,11 +249,10 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 				*square++ = ' ';
 		}
 
-		if (bracket == NULL ||
-		    (comma != NULL && comma < bracket)) {
+		if (!bracket || (comma && comma < bracket)) {
 			/* no interface list specified */
 
-			if (comma != NULL)
+			if (comma)
 				*comma++ = 0;
 			net = libcfs_str2net(cfs_trimwhite(str));
 
@@ -265,10 +264,10 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 			}
 
 			if (LNET_NETTYP(net) != LOLND && /* LO is implicit */
-			    lnet_ni_alloc(net, el, nilist) == NULL)
+			    !lnet_ni_alloc(net, el, nilist))
 				goto failed;
 
-			if (el != NULL) {
+			if (el) {
 				cfs_expr_list_free(el);
 				el = NULL;
 			}
@@ -286,10 +285,10 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 
 		nnets++;
 		ni = lnet_ni_alloc(net, el, nilist);
-		if (ni == NULL)
+		if (!ni)
 			goto failed;
 
-		if (el != NULL) {
+		if (el) {
 			cfs_expr_list_free(el);
 			el = NULL;
 		}
@@ -298,7 +297,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		iface = bracket + 1;
 
 		bracket = strchr(iface, ')');
-		if (bracket == NULL) {
+		if (!bracket) {
 			tmp = iface;
 			goto failed_syntax;
 		}
@@ -306,7 +305,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		*bracket = 0;
 		do {
 			comma = strchr(iface, ',');
-			if (comma != NULL)
+			if (comma)
 				*comma++ = 0;
 
 			iface = cfs_trimwhite(iface);
@@ -324,11 +323,11 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 
 			ni->ni_interfaces[niface++] = iface;
 			iface = comma;
-		} while (iface != NULL);
+		} while (iface);
 
 		str = bracket + 1;
 		comma = strchr(bracket + 1, ',');
-		if (comma != NULL) {
+		if (comma) {
 			*comma = 0;
 			str = cfs_trimwhite(str);
 			if (*str != 0) {
@@ -359,7 +358,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		lnet_ni_free(ni);
 	}
 
-	if (el != NULL)
+	if (el)
 		cfs_expr_list_free(el);
 
 	LIBCFS_FREE(tokens, tokensize);
@@ -388,7 +387,7 @@ lnet_new_text_buf(int str_len)
 	}
 
 	LIBCFS_ALLOC(ltb, nob);
-	if (ltb == NULL)
+	if (!ltb)
 		return NULL;
 
 	ltb->ltb_size = nob;
@@ -442,7 +441,7 @@ lnet_str2tbs_sep(struct list_head *tbs, char *str)
 		nob = (int)(sep - str);
 		if (nob > 0) {
 			ltb = lnet_new_text_buf(nob);
-			if (ltb == NULL) {
+			if (!ltb) {
 				lnet_free_text_bufs(&pending);
 				return -1;
 			}
@@ -488,7 +487,7 @@ lnet_expand1tb(struct list_head *list,
 	LASSERT(*sep2 == ']');
 
 	ltb = lnet_new_text_buf(len1 + itemlen + len2);
-	if (ltb == NULL)
+	if (!ltb)
 		return -ENOMEM;
 
 	memcpy(ltb->ltb_text, str, len1);
@@ -519,11 +518,11 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 	INIT_LIST_HEAD(&pending);
 
 	sep = strchr(str, '[');
-	if (sep == NULL)			/* nothing to expand */
+	if (!sep)			/* nothing to expand */
 		return 0;
 
 	sep2 = strchr(sep, ']');
-	if (sep2 == NULL)
+	if (!sep2)
 		goto failed;
 
 	for (parsed = sep; parsed < sep2; parsed = enditem) {
@@ -599,7 +598,7 @@ lnet_parse_priority(char *str, unsigned int *priority, char **token)
 	int len;
 
 	sep = strchr(str, LNET_PRIORITY_SEPARATOR);
-	if (sep == NULL) {
+	if (!sep) {
 		*priority = 0;
 		return 0;
 	}
@@ -683,7 +682,7 @@ lnet_parse_route(char *str, int *im_a_router)
 		}
 
 		ltb = lnet_new_text_buf(strlen(token));
-		if (ltb == NULL)
+		if (!ltb)
 			goto out;
 
 		strcpy(ltb->ltb_text, token);
@@ -889,12 +888,12 @@ lnet_netspec2net(char *netspec)
 	char *bracket = strchr(netspec, '(');
 	__u32 net;
 
-	if (bracket != NULL)
+	if (bracket)
 		*bracket = 0;
 
 	net = libcfs_str2net(netspec);
 
-	if (bracket != NULL)
+	if (bracket)
 		*bracket = '(';
 
 	return net;
@@ -922,9 +921,7 @@ lnet_splitnets(char *source, struct list_head *nets)
 		sep = strchr(tb->ltb_text, ',');
 		bracket = strchr(tb->ltb_text, '(');
 
-		if (sep != NULL &&
-		    bracket != NULL &&
-		    bracket < sep) {
+		if (sep && bracket && bracket < sep) {
 			/* netspec lists interfaces... */
 
 			offset2 = offset + (int)(bracket - tb->ltb_text);
@@ -932,7 +929,7 @@ lnet_splitnets(char *source, struct list_head *nets)
 
 			bracket = strchr(bracket + 1, ')');
 
-			if (bracket == NULL ||
+			if (!bracket ||
 			    !(bracket[1] == ',' || bracket[1] == 0)) {
 				lnet_syntax("ip2nets", source, offset2, len);
 				return -EINVAL;
@@ -941,7 +938,7 @@ lnet_splitnets(char *source, struct list_head *nets)
 			sep = (bracket[1] == 0) ? NULL : bracket + 1;
 		}
 
-		if (sep != NULL)
+		if (sep)
 			*sep++ = 0;
 
 		net = lnet_netspec2net(tb->ltb_text);
@@ -965,13 +962,13 @@ lnet_splitnets(char *source, struct list_head *nets)
 			}
 		}
 
-		if (sep == NULL)
+		if (!sep)
 			return 0;
 
 		offset += (int)(sep - tb->ltb_text);
 		len = strlen(sep);
 		tb2 = lnet_new_text_buf(len);
-		if (tb2 == NULL)
+		if (!tb2)
 			return -ENOMEM;
 
 		strncpy(tb2->ltb_text, sep, len);
@@ -1118,7 +1115,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 		return nif;
 
 	LIBCFS_ALLOC(ipaddrs, nif * sizeof(*ipaddrs));
-	if (ipaddrs == NULL) {
+	if (!ipaddrs) {
 		CERROR("Can't allocate ipaddrs[%d]\n", nif);
 		lnet_ipif_free_enumeration(ifnames, nif);
 		return -ENOMEM;
@@ -1151,7 +1148,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 	} else {
 		if (nip > 0) {
 			LIBCFS_ALLOC(ipaddrs2, nip * sizeof(*ipaddrs2));
-			if (ipaddrs2 == NULL) {
+			if (!ipaddrs2) {
 				CERROR("Can't allocate ipaddrs[%d]\n", nip);
 				nip = -ENOMEM;
 			} else {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 683eb45..34012e9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -94,12 +94,12 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 		return -EINVAL;
 
 	eq = lnet_eq_alloc();
-	if (eq == NULL)
+	if (!eq)
 		return -ENOMEM;
 
 	if (count != 0) {
 		LIBCFS_ALLOC(eq->eq_events, count * sizeof(lnet_event_t));
-		if (eq->eq_events == NULL)
+		if (!eq->eq_events)
 			goto failed;
 		/*
 		 * NB allocator has set all event sequence numbers to 0,
@@ -114,7 +114,7 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 
 	eq->eq_refs = cfs_percpt_alloc(lnet_cpt_table(),
 				       sizeof(*eq->eq_refs[0]));
-	if (eq->eq_refs == NULL)
+	if (!eq->eq_refs)
 		goto failed;
 
 	/* MUST hold both exclusive lnet_res_lock */
@@ -135,10 +135,10 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	return 0;
 
 failed:
-	if (eq->eq_events != NULL)
+	if (eq->eq_events)
 		LIBCFS_FREE(eq->eq_events, count * sizeof(lnet_event_t));
 
-	if (eq->eq_refs != NULL)
+	if (eq->eq_refs)
 		cfs_percpt_free(eq->eq_refs);
 
 	lnet_eq_free(eq);
@@ -178,7 +178,7 @@ LNetEQFree(lnet_handle_eq_t eqh)
 	lnet_eq_wait_lock();
 
 	eq = lnet_handle2eq(&eqh);
-	if (eq == NULL) {
+	if (!eq) {
 		rc = -ENOENT;
 		goto out;
 	}
@@ -206,9 +206,9 @@ LNetEQFree(lnet_handle_eq_t eqh)
 	lnet_eq_wait_unlock();
 	lnet_res_unlock(LNET_LOCK_EX);
 
-	if (events != NULL)
+	if (events)
 		LIBCFS_FREE(events, size * sizeof(lnet_event_t));
-	if (refs != NULL)
+	if (refs)
 		cfs_percpt_free(refs);
 
 	return rc;
@@ -395,7 +395,7 @@ LNetEQPoll(lnet_handle_eq_t *eventqs, int neq, int timeout_ms,
 		for (i = 0; i < neq; i++) {
 			lnet_eq_t *eq = lnet_handle2eq(&eventqs[i]);
 
-			if (eq == NULL) {
+			if (!eq) {
 				lnet_eq_wait_unlock();
 				return -ENOENT;
 			}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 55bd7a1..490edfb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -57,7 +57,7 @@ lnet_md_unlink(lnet_libmd_t *md)
 		 * and unlink it if it was created
 		 * with LNET_UNLINK
 		 */
-		if (me != NULL) {
+		if (me) {
 			/* detach MD from portal */
 			lnet_ptl_detach_md(me, md);
 			if (me->me_unlink == LNET_UNLINK)
@@ -75,7 +75,7 @@ lnet_md_unlink(lnet_libmd_t *md)
 
 	CDEBUG(D_NET, "Unlinking md %p\n", md);
 
-	if (md->md_eq != NULL) {
+	if (md->md_eq) {
 		int cpt = lnet_cpt_of_cookie(md->md_lh.lh_cookie);
 
 		LASSERT(*md->md_eq->eq_refs[cpt] > 0);
@@ -187,7 +187,7 @@ lnet_md_link(lnet_libmd_t *md, lnet_handle_eq_t eq_handle, int cpt)
 	 * TODO - reevaluate what should be here in light of
 	 * the removal of the start and end events
 	 * maybe there we shouldn't even allow LNET_EQ_NONE!)
-	 * LASSERT (eq == NULL);
+	 * LASSERT(!eq);
 	 */
 	if (!LNetHandleIsInvalid(eq_handle)) {
 		md->md_eq = lnet_handle2eq(&eq_handle);
@@ -306,7 +306,7 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	me = lnet_handle2me(&meh);
 	if (!me)
 		rc = -ENOENT;
-	else if (me->me_md != NULL)
+	else if (me->me_md)
 		rc = -EBUSY;
 	else
 		rc = lnet_md_link(md, umd.eq_handle, cpt);
@@ -453,7 +453,7 @@ LNetMDUnlink(lnet_handle_md_t mdh)
 	 * when the LND is done, the completion event flags that the MD was
 	 * unlinked.  Otherwise, we enqueue an event now...
 	 */
-	if (md->md_eq != NULL && md->md_refcount == 0) {
+	if (md->md_eq && md->md_refcount == 0) {
 		lnet_build_unlink_event(md, &ev);
 		lnet_eq_enqueue_event(md->md_eq, &ev);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 42fc99e..ab17bdb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -91,11 +91,11 @@ LNetMEAttach(unsigned int portal,
 
 	mtable = lnet_mt_of_attach(portal, match_id,
 				   match_bits, ignore_bits, pos);
-	if (mtable == NULL) /* can't match portal type */
+	if (!mtable) /* can't match portal type */
 		return -EPERM;
 
 	me = lnet_me_alloc();
-	if (me == NULL)
+	if (!me)
 		return -ENOMEM;
 
 	lnet_res_lock(mtable->mt_cpt);
@@ -163,7 +163,7 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 		return -EPERM;
 
 	new_me = lnet_me_alloc();
-	if (new_me == NULL)
+	if (!new_me)
 		return -ENOMEM;
 
 	cpt = lnet_cpt_of_cookie(current_meh.cookie);
@@ -171,7 +171,7 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 	lnet_res_lock(cpt);
 
 	current_me = lnet_handle2me(&current_meh);
-	if (current_me == NULL) {
+	if (!current_me) {
 		lnet_me_free(new_me);
 
 		lnet_res_unlock(cpt);
@@ -240,15 +240,15 @@ LNetMEUnlink(lnet_handle_me_t meh)
 	lnet_res_lock(cpt);
 
 	me = lnet_handle2me(&meh);
-	if (me == NULL) {
+	if (!me) {
 		lnet_res_unlock(cpt);
 		return -ENOENT;
 	}
 
 	md = me->me_md;
-	if (md != NULL) {
+	if (md) {
 		md->md_flags |= LNET_MD_FLAG_ABORTED;
-		if (md->md_eq != NULL && md->md_refcount == 0) {
+		if (md->md_eq && md->md_refcount == 0) {
 			lnet_build_unlink_event(md, &ev);
 			lnet_eq_enqueue_event(md->md_eq, &ev);
 		}
@@ -267,7 +267,7 @@ lnet_me_unlink(lnet_me_t *me)
 {
 	list_del(&me->me_list);
 
-	if (me->me_md != NULL) {
+	if (me->me_md) {
 		lnet_libmd_t *md = me->me_md;
 
 		/* detach MD from portal of this ME */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index b40220a..5e8a6ab 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -60,7 +60,7 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 	if (threshold != 0) {
 		/* Adding a new entry */
 		LIBCFS_ALLOC(tp, sizeof(*tp));
-		if (tp == NULL)
+		if (!tp)
 			return -ENOMEM;
 
 		tp->tp_nid = nid;
@@ -329,10 +329,10 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 			       siov->kiov_len - soffset);
 		this_nob = min(this_nob, nob);
 
-		if (daddr == NULL)
+		if (!daddr)
 			daddr = ((char *)kmap(diov->kiov_page)) +
 				diov->kiov_offset + doffset;
-		if (saddr == NULL)
+		if (!saddr)
 			saddr = ((char *)kmap(siov->kiov_page)) +
 				siov->kiov_offset + soffset;
 
@@ -367,9 +367,9 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 		}
 	} while (nob > 0);
 
-	if (daddr != NULL)
+	if (daddr)
 		kunmap(diov->kiov_page);
-	if (saddr != NULL)
+	if (saddr)
 		kunmap(siov->kiov_page);
 }
 EXPORT_SYMBOL(lnet_copy_kiov2kiov);
@@ -411,7 +411,7 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 			       (__kernel_size_t) kiov->kiov_len - kiovoffset);
 		this_nob = min(this_nob, nob);
 
-		if (addr == NULL)
+		if (!addr)
 			addr = ((char *)kmap(kiov->kiov_page)) +
 				kiov->kiov_offset + kiovoffset;
 
@@ -439,7 +439,7 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 
 	} while (nob > 0);
 
-	if (addr != NULL)
+	if (addr)
 		kunmap(kiov->kiov_page);
 }
 EXPORT_SYMBOL(lnet_copy_kiov2iov);
@@ -482,7 +482,7 @@ lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
 			       iov->iov_len - iovoffset);
 		this_nob = min(this_nob, nob);
 
-		if (addr == NULL)
+		if (!addr)
 			addr = ((char *)kmap(kiov->kiov_page)) +
 				kiov->kiov_offset + kiovoffset;
 
@@ -509,7 +509,7 @@ lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
 		}
 	} while (nob > 0);
 
-	if (addr != NULL)
+	if (addr)
 		kunmap(kiov->kiov_page);
 }
 EXPORT_SYMBOL(lnet_copy_iov2kiov);
@@ -577,9 +577,9 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	int rc;
 
 	LASSERT(!in_interrupt());
-	LASSERT(mlen == 0 || msg != NULL);
+	LASSERT(mlen == 0 || msg);
 
-	if (msg != NULL) {
+	if (msg) {
 		LASSERT(msg->msg_receiving);
 		LASSERT(!msg->msg_sending);
 		LASSERT(rlen == msg->msg_len);
@@ -595,7 +595,7 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 			kiov = msg->msg_kiov;
 
 			LASSERT(niov > 0);
-			LASSERT((iov == NULL) != (kiov == NULL));
+			LASSERT(!iov != !kiov);
 		}
 	}
 
@@ -612,10 +612,10 @@ lnet_setpayloadbuffer(lnet_msg_t *msg)
 
 	LASSERT(msg->msg_len > 0);
 	LASSERT(!msg->msg_routing);
-	LASSERT(md != NULL);
+	LASSERT(md);
 	LASSERT(msg->msg_niov == 0);
-	LASSERT(msg->msg_iov == NULL);
-	LASSERT(msg->msg_kiov == NULL);
+	LASSERT(!msg->msg_iov);
+	LASSERT(!msg->msg_kiov);
 
 	msg->msg_niov = md->md_niov;
 	if ((md->md_options & LNET_MD_KIOV) != 0)
@@ -668,7 +668,7 @@ lnet_ni_eager_recv(lnet_ni_t *ni, lnet_msg_t *msg)
 	LASSERT(!msg->msg_sending);
 	LASSERT(msg->msg_receiving);
 	LASSERT(!msg->msg_rx_ready_delay);
-	LASSERT(ni->ni_lnd->lnd_eager_recv != NULL);
+	LASSERT(ni->ni_lnd->lnd_eager_recv);
 
 	msg->msg_rx_ready_delay = 1;
 	rc = ni->ni_lnd->lnd_eager_recv(ni, msg->msg_private, msg,
@@ -690,7 +690,7 @@ lnet_ni_query_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 	unsigned long last_alive = 0;
 
 	LASSERT(lnet_peer_aliveness_enabled(lp));
-	LASSERT(ni->ni_lnd->lnd_query != NULL);
+	LASSERT(ni->ni_lnd->lnd_query);
 
 	lnet_net_unlock(lp->lp_cpt);
 	ni->ni_lnd->lnd_query(ni, lp->lp_nid, &last_alive);
@@ -820,7 +820,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 		return EHOSTUNREACH;
 	}
 
-	if (msg->msg_md != NULL &&
+	if (msg->msg_md &&
 	    (msg->msg_md->md_flags & LNET_MD_FLAG_ABORTED) != 0) {
 		lnet_net_unlock(cpt);
 
@@ -908,8 +908,8 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 	lnet_rtrbufpool_t *rbp;
 	lnet_rtrbuf_t *rb;
 
-	LASSERT(msg->msg_iov == NULL);
-	LASSERT(msg->msg_kiov == NULL);
+	LASSERT(!msg->msg_iov);
+	LASSERT(!msg->msg_kiov);
 	LASSERT(msg->msg_niov == 0);
 	LASSERT(msg->msg_routing);
 	LASSERT(msg->msg_receiving);
@@ -1026,7 +1026,7 @@ lnet_return_tx_credits_locked(lnet_msg_t *msg)
 		}
 	}
 
-	if (txpeer != NULL) {
+	if (txpeer) {
 		msg->msg_txpeer = NULL;
 		lnet_peer_decref_locked(txpeer);
 	}
@@ -1048,7 +1048,7 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 		 * there until it gets one allocated, or aborts the wait
 		 * itself
 		 */
-		LASSERT(msg->msg_kiov != NULL);
+		LASSERT(msg->msg_kiov);
 
 		rb = list_entry(msg->msg_kiov, lnet_rtrbuf_t, rb_kiov[0]);
 		rbp = rb->rb_pool;
@@ -1089,7 +1089,7 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 			(void) lnet_post_routed_recv_locked(msg2, 1);
 		}
 	}
-	if (rxpeer != NULL) {
+	if (rxpeer) {
 		msg->msg_rxpeer = NULL;
 		lnet_peer_decref_locked(rxpeer);
 	}
@@ -1147,7 +1147,7 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 	 * rtr_nid nid, otherwise find the best gateway I can use
 	 */
 	rnet = lnet_find_net_locked(LNET_NIDNET(target));
-	if (rnet == NULL)
+	if (!rnet)
 		return NULL;
 
 	lp_best = NULL;
@@ -1161,13 +1161,13 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 		     rtr->lr_downis != 0)) /* NI to target is down */
 			continue;
 
-		if (ni != NULL && lp->lp_ni != ni)
+		if (ni && lp->lp_ni != ni)
 			continue;
 
 		if (lp->lp_nid == rtr_nid) /* it's pre-determined router */
 			return lp;
 
-		if (lp_best == NULL) {
+		if (!lp_best) {
 			rtr_best = rtr;
 			rtr_last = rtr;
 			lp_best = lp;
@@ -1191,7 +1191,7 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 	 * so we can round-robin all routers, it's race and inaccurate but
 	 * harmless and functional
 	 */
-	if (rtr_best != NULL)
+	if (rtr_best)
 		rtr_best->lr_seq = rtr_last->lr_seq + 1;
 	return lp_best;
 }
@@ -1212,8 +1212,8 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	 * but we might want to use pre-determined router for ACK/REPLY
 	 * in the future
 	 */
-	/* NB: ni != NULL == interface pre-determined (ACK/REPLY) */
-	LASSERT(msg->msg_txpeer == NULL);
+	/* NB: ni == interface pre-determined (ACK/REPLY) */
+	LASSERT(!msg->msg_txpeer);
 	LASSERT(!msg->msg_sending);
 	LASSERT(!msg->msg_target_is_router);
 	LASSERT(!msg->msg_receiving);
@@ -1234,7 +1234,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 		src_ni = NULL;
 	} else {
 		src_ni = lnet_nid2ni_locked(src_nid, cpt);
-		if (src_ni == NULL) {
+		if (!src_ni) {
 			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("Can't send to %s: src %s is not a local nid\n",
 				      libcfs_nid2str(dst_nid),
@@ -1247,8 +1247,8 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	/* Is this for someone on a local network? */
 	local_ni = lnet_net2ni_locked(LNET_NIDNET(dst_nid), cpt);
 
-	if (local_ni != NULL) {
-		if (src_ni == NULL) {
+	if (local_ni) {
+		if (!src_ni) {
 			src_ni = local_ni;
 			src_nid = src_ni->ni_nid;
 		} else if (src_ni == local_ni) {
@@ -1294,8 +1294,8 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	} else {
 		/* sending to a remote network */
 		lp = lnet_find_route_locked(src_ni, dst_nid, rtr_nid);
-		if (lp == NULL) {
-			if (src_ni != NULL)
+		if (!lp) {
+			if (src_ni)
 				lnet_ni_decref_locked(src_ni, cpt);
 			lnet_net_unlock(cpt);
 
@@ -1314,7 +1314,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 		if (rtr_nid != lp->lp_nid) {
 			cpt2 = lnet_cpt_of_nid_locked(lp->lp_nid);
 			if (cpt2 != cpt) {
-				if (src_ni != NULL)
+				if (src_ni)
 					lnet_ni_decref_locked(src_ni, cpt);
 				lnet_net_unlock(cpt);
 
@@ -1328,7 +1328,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 		       libcfs_nid2str(dst_nid), libcfs_nid2str(lp->lp_nid),
 		       lnet_msgtyp2str(msg->msg_type), msg->msg_len);
 
-		if (src_ni == NULL) {
+		if (!src_ni) {
 			src_ni = lp->lp_ni;
 			src_nid = src_ni->ni_nid;
 		} else {
@@ -1355,7 +1355,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 
 	LASSERT(!msg->msg_peertxcredit);
 	LASSERT(!msg->msg_txcredit);
-	LASSERT(msg->msg_txpeer == NULL);
+	LASSERT(!msg->msg_txpeer);
 
 	msg->msg_txpeer = lp;		   /* msg takes my ref on lp */
 
@@ -1423,7 +1423,7 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 	info.mi_roffset	= hdr->msg.put.offset;
 	info.mi_mbits	= hdr->msg.put.match_bits;
 
-	msg->msg_rx_ready_delay = ni->ni_lnd->lnd_eager_recv == NULL;
+	msg->msg_rx_ready_delay = !ni->ni_lnd->lnd_eager_recv;
 
  again:
 	rc = lnet_ptl_match_md(&info, msg);
@@ -1536,13 +1536,13 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	/* NB handles only looked up by creator (no flips) */
 	md = lnet_wire_handle2md(&hdr->msg.reply.dst_wmd);
-	if (md == NULL || md->md_threshold == 0 || md->md_me != NULL) {
+	if (!md || md->md_threshold == 0 || md->md_me) {
 		CNETERR("%s: Dropping REPLY from %s for %s MD %#llx.%#llx\n",
 			libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
-			(md == NULL) ? "invalid" : "inactive",
+			!md ? "invalid" : "inactive",
 			hdr->msg.reply.dst_wmd.wh_interface_cookie,
 			hdr->msg.reply.dst_wmd.wh_object_cookie);
-		if (md != NULL && md->md_me != NULL)
+		if (md && md->md_me)
 			CERROR("REPLY MD also attached to portal %d\n",
 			       md->md_me->me_portal);
 
@@ -1602,15 +1602,15 @@ lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	/* NB handles only looked up by creator (no flips) */
 	md = lnet_wire_handle2md(&hdr->msg.ack.dst_wmd);
-	if (md == NULL || md->md_threshold == 0 || md->md_me != NULL) {
+	if (!md || md->md_threshold == 0 || md->md_me) {
 		/* Don't moan; this is expected */
 		CDEBUG(D_NET,
 		       "%s: Dropping ACK from %s to %s MD %#llx.%#llx\n",
 		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
-		       (md == NULL) ? "invalid" : "inactive",
+		       !md ? "invalid" : "inactive",
 		       hdr->msg.ack.dst_wmd.wh_interface_cookie,
 		       hdr->msg.ack.dst_wmd.wh_object_cookie);
-		if (md != NULL && md->md_me != NULL)
+		if (md && md->md_me)
 			CERROR("Source MD also attached to portal %d\n",
 			       md->md_me->me_portal);
 
@@ -1639,7 +1639,7 @@ lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	if (msg->msg_rxpeer->lp_rtrcredits <= 0 ||
 	    lnet_msg2bufpool(msg)->rbp_credits <= 0) {
-		if (ni->ni_lnd->lnd_eager_recv == NULL) {
+		if (!ni->ni_lnd->lnd_eager_recv) {
 			msg->msg_rx_ready_delay = 1;
 		} else {
 			lnet_net_unlock(msg->msg_rx_cpt);
@@ -1794,7 +1794,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 		/* NB: so far here is the only place to set NI status to "up */
 		ni->ni_last_alive = ktime_get_real_seconds();
-		if (ni->ni_status != NULL &&
+		if (ni->ni_status &&
 		    ni->ni_status->ns_status == LNET_NI_STATUS_DOWN)
 			ni->ni_status->ns_status = LNET_NI_STATUS_UP;
 		lnet_ni_unlock(ni);
@@ -1857,7 +1857,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 	}
 
 	msg = lnet_msg_alloc();
-	if (msg == NULL) {
+	if (!msg) {
 		CERROR("%s, src %s: Dropping %s (out of memory)\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type));
@@ -1957,7 +1957,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 	LASSERT(rc == ENOENT);
 
  free_drop:
-	LASSERT(msg->msg_md == NULL);
+	LASSERT(!msg->msg_md);
 	lnet_finalize(ni, msg, rc);
 
  drop:
@@ -1979,9 +1979,9 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 		id.nid = msg->msg_hdr.src_nid;
 		id.pid = msg->msg_hdr.src_pid;
 
-		LASSERT(msg->msg_md == NULL);
+		LASSERT(!msg->msg_md);
 		LASSERT(msg->msg_rx_delayed);
-		LASSERT(msg->msg_rxpeer != NULL);
+		LASSERT(msg->msg_rxpeer);
 		LASSERT(msg->msg_hdr.type == LNET_MSG_PUT);
 
 		CWARN("Dropping delayed PUT from %s portal %d match %llu offset %d length %d: %s\n",
@@ -2026,8 +2026,8 @@ lnet_recv_delayed_msg_list(struct list_head *head)
 		id.pid = msg->msg_hdr.src_pid;
 
 		LASSERT(msg->msg_rx_delayed);
-		LASSERT(msg->msg_md != NULL);
-		LASSERT(msg->msg_rxpeer != NULL);
+		LASSERT(msg->msg_md);
+		LASSERT(msg->msg_rxpeer);
 		LASSERT(msg->msg_hdr.type == LNET_MSG_PUT);
 
 		CDEBUG(D_NET, "Resuming delayed PUT from %s portal %d match %llu offset %d length %d.\n",
@@ -2106,7 +2106,7 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 	}
 
 	msg = lnet_msg_alloc();
-	if (msg == NULL) {
+	if (!msg) {
 		CERROR("Dropping PUT to %s: ENOMEM on lnet_msg_t\n",
 		       libcfs_id2str(target));
 		return -ENOMEM;
@@ -2117,11 +2117,11 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 	lnet_res_lock(cpt);
 
 	md = lnet_handle2md(&mdh);
-	if (md == NULL || md->md_threshold == 0 || md->md_me != NULL) {
+	if (!md || md->md_threshold == 0 || md->md_me) {
 		CERROR("Dropping PUT (%llu:%d:%s): MD (%d) invalid\n",
 		       match_bits, portal, libcfs_id2str(target),
-		       md == NULL ? -1 : md->md_threshold);
-		if (md != NULL && md->md_me != NULL)
+		       !md ? -1 : md->md_threshold);
+		if (md && md->md_me)
 			CERROR("Source MD also attached to portal %d\n",
 			       md->md_me->me_portal);
 		lnet_res_unlock(cpt);
@@ -2194,7 +2194,7 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 
 	LASSERT(getmd->md_refcount > 0);
 
-	if (msg == NULL) {
+	if (!msg) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
 		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
 		goto drop;
@@ -2241,7 +2241,7 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 	the_lnet.ln_counters[cpt]->drop_length += getmd->md_length;
 	lnet_net_unlock(cpt);
 
-	if (msg != NULL)
+	if (msg)
 		lnet_msg_free(msg);
 
 	return NULL;
@@ -2255,7 +2255,7 @@ lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *reply, unsigned int len)
 	 * Set the REPLY length, now the RDMA that elides the REPLY message has
 	 * completed and I know it.
 	 */
-	LASSERT(reply != NULL);
+	LASSERT(reply);
 	LASSERT(reply->msg_type == LNET_MSG_GET);
 	LASSERT(reply->msg_ev.type == LNET_EVENT_REPLY);
 
@@ -2311,7 +2311,7 @@ LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
 	}
 
 	msg = lnet_msg_alloc();
-	if (msg == NULL) {
+	if (!msg) {
 		CERROR("Dropping GET to %s: ENOMEM on lnet_msg_t\n",
 		       libcfs_id2str(target));
 		return -ENOMEM;
@@ -2321,11 +2321,11 @@ LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
 	lnet_res_lock(cpt);
 
 	md = lnet_handle2md(&mdh);
-	if (md == NULL || md->md_threshold == 0 || md->md_me != NULL) {
+	if (!md || md->md_threshold == 0 || md->md_me) {
 		CERROR("Dropping GET (%llu:%d:%s): MD (%d) invalid\n",
 		       match_bits, portal, libcfs_id2str(target),
-		       md == NULL ? -1 : md->md_threshold);
-		if (md != NULL && md->md_me != NULL)
+		       !md ? -1 : md->md_threshold);
+		if (md && md->md_me)
 			CERROR("REPLY MD also attached to portal %d\n",
 			       md->md_me->me_portal);
 
@@ -2409,9 +2409,9 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 		ni = list_entry(e, lnet_ni_t, ni_list);
 
 		if (ni->ni_nid == dstnid) {
-			if (srcnidp != NULL)
+			if (srcnidp)
 				*srcnidp = dstnid;
-			if (orderp != NULL) {
+			if (orderp) {
 				if (LNET_NETTYP(LNET_NIDNET(dstnid)) == LOLND)
 					*orderp = 0;
 				else
@@ -2423,9 +2423,9 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 		}
 
 		if (LNET_NIDNET(ni->ni_nid) == dstnet) {
-			if (srcnidp != NULL)
+			if (srcnidp)
 				*srcnidp = ni->ni_nid;
-			if (orderp != NULL)
+			if (orderp)
 				*orderp = order;
 			lnet_net_unlock(cpt);
 			return 1;
@@ -2446,16 +2446,16 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 
 			list_for_each_entry(route, &rnet->lrn_routes,
 					    lr_list) {
-				if (shortest == NULL ||
+				if (!shortest ||
 				    route->lr_hops < shortest->lr_hops)
 					shortest = route;
 			}
 
-			LASSERT(shortest != NULL);
+			LASSERT(shortest);
 			hops = shortest->lr_hops;
-			if (srcnidp != NULL)
+			if (srcnidp)
 				*srcnidp = shortest->lr_gateway->lp_ni->ni_nid;
-			if (orderp != NULL)
+			if (orderp)
 				*orderp = order;
 			lnet_net_unlock(cpt);
 			return hops + 1;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index eb4aa34..5ee390c 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -350,7 +350,7 @@ lnet_msg_detach_md(lnet_msg_t *msg, int status)
 	LASSERT(md->md_refcount >= 0);
 
 	unlink = lnet_md_unlinkable(md);
-	if (md->md_eq != NULL) {
+	if (md->md_eq) {
 		msg->msg_ev.status   = status;
 		msg->msg_ev.unlinked = unlink;
 		lnet_eq_enqueue_event(md->md_eq, &msg->msg_ev);
@@ -451,7 +451,7 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 
 	LASSERT(!in_interrupt());
 
-	if (msg == NULL)
+	if (!msg)
 		return;
 #if 0
 	CDEBUG(D_WARNING, "%s msg->%s Flags:%s%s%s%s%s%s%s%s%s%s%s txp %s rxp %s\n",
@@ -467,12 +467,12 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 	       msg->msg_rtrcredit ? "F" : "",
 	       msg->msg_peerrtrcredit ? "f" : "",
 	       msg->msg_onactivelist ? "!" : "",
-	       msg->msg_txpeer == NULL ? "<none>" : libcfs_nid2str(msg->msg_txpeer->lp_nid),
-	       msg->msg_rxpeer == NULL ? "<none>" : libcfs_nid2str(msg->msg_rxpeer->lp_nid));
+	       !msg->msg_txpeer ? "<none>" : libcfs_nid2str(msg->msg_txpeer->lp_nid),
+	       !msg->msg_rxpeer ? "<none>" : libcfs_nid2str(msg->msg_rxpeer->lp_nid));
 #endif
 	msg->msg_ev.status = status;
 
-	if (msg->msg_md != NULL) {
+	if (msg->msg_md) {
 		cpt = lnet_cpt_of_cookie(msg->msg_md->md_lh.lh_cookie);
 
 		lnet_res_lock(cpt);
@@ -509,7 +509,7 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 		if (container->msc_finalizers[i] == current)
 			break;
 
-		if (my_slot < 0 && container->msc_finalizers[i] == NULL)
+		if (my_slot < 0 && !container->msc_finalizers[i])
 			my_slot = i;
 	}
 
@@ -565,7 +565,7 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 	if (count > 0)
 		CERROR("%d active msg on exit\n", count);
 
-	if (container->msc_finalizers != NULL) {
+	if (container->msc_finalizers) {
 		LIBCFS_FREE(container->msc_finalizers,
 			    container->msc_nfinalizers *
 			    sizeof(*container->msc_finalizers));
@@ -607,7 +607,7 @@ lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 			 container->msc_nfinalizers *
 			 sizeof(*container->msc_finalizers));
 
-	if (container->msc_finalizers == NULL) {
+	if (!container->msc_finalizers) {
 		CERROR("Failed to allocate message finalizers\n");
 		lnet_msg_container_cleanup(container);
 		return -ENOMEM;
@@ -622,7 +622,7 @@ lnet_msg_containers_destroy(void)
 	struct lnet_msg_container *container;
 	int i;
 
-	if (the_lnet.ln_msg_containers == NULL)
+	if (!the_lnet.ln_msg_containers)
 		return;
 
 	cfs_percpt_for_each(container, i, the_lnet.ln_msg_containers)
@@ -642,7 +642,7 @@ lnet_msg_containers_create(void)
 	the_lnet.ln_msg_containers = cfs_percpt_alloc(lnet_cpt_table(),
 						      sizeof(*container));
 
-	if (the_lnet.ln_msg_containers == NULL) {
+	if (!the_lnet.ln_msg_containers) {
 		CERROR("Failed to allocate cpu-partition data for network\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index d99364f..aca47de 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -243,7 +243,7 @@ lnet_mt_of_attach(unsigned int index, lnet_process_id_t id,
 	ptl = the_lnet.ln_portals[index];
 
 	mtable = lnet_match2mt(ptl, id, mbits);
-	if (mtable != NULL) /* unique portal or only one match-table */
+	if (mtable) /* unique portal or only one match-table */
 		return mtable;
 
 	/* it's a wildcard portal */
@@ -280,7 +280,7 @@ lnet_mt_of_match(struct lnet_match_info *info, struct lnet_msg *msg)
 	LASSERT(lnet_ptl_is_wildcard(ptl) || lnet_ptl_is_unique(ptl));
 
 	mtable = lnet_match2mt(ptl, info->mi_id, info->mi_mbits);
-	if (mtable != NULL)
+	if (mtable)
 		return mtable;
 
 	/* it's a wildcard portal */
@@ -399,7 +399,7 @@ lnet_mt_match_md(struct lnet_match_table *mtable,
 
 	list_for_each_entry_safe(me, tmp, head, me_list) {
 		/* ME attached but MD not attached yet */
-		if (me->me_md == NULL)
+		if (!me->me_md)
 			continue;
 
 		LASSERT(me == me->me_md->md_me);
@@ -516,7 +516,7 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 			 * could be matched by lnet_ptl_attach_md()
 			 * which is called by another thread
 			 */
-			rc = msg->msg_md == NULL ?
+			rc = !msg->msg_md ?
 			     LNET_MATCHMD_DROP : LNET_MATCHMD_OK;
 		}
 
@@ -733,7 +733,7 @@ lnet_ptl_cleanup(struct lnet_portal *ptl)
 	struct lnet_match_table	*mtable;
 	int i;
 
-	if (ptl->ptl_mtables == NULL) /* uninitialized portal */
+	if (!ptl->ptl_mtables) /* uninitialized portal */
 		return;
 
 	LASSERT(list_empty(&ptl->ptl_msg_delayed));
@@ -743,7 +743,7 @@ lnet_ptl_cleanup(struct lnet_portal *ptl)
 		lnet_me_t *me;
 		int j;
 
-		if (mtable->mt_mhash == NULL) /* uninitialized match-table */
+		if (!mtable->mt_mhash) /* uninitialized match-table */
 			continue;
 
 		mhash = mtable->mt_mhash;
@@ -775,7 +775,7 @@ lnet_ptl_setup(struct lnet_portal *ptl, int index)
 
 	ptl->ptl_mtables = cfs_percpt_alloc(lnet_cpt_table(),
 					    sizeof(struct lnet_match_table));
-	if (ptl->ptl_mtables == NULL) {
+	if (!ptl->ptl_mtables) {
 		CERROR("Failed to create match table for portal %d\n", index);
 		return -ENOMEM;
 	}
@@ -788,7 +788,7 @@ lnet_ptl_setup(struct lnet_portal *ptl, int index)
 		/* the extra entry is for MEs with ignore bits */
 		LIBCFS_CPT_ALLOC(mhash, lnet_cpt_table(), i,
 				 sizeof(*mhash) * (LNET_MT_HASH_SIZE + 1));
-		if (mhash == NULL) {
+		if (!mhash) {
 			CERROR("Failed to create match hash for portal %d\n",
 			       index);
 			goto failed;
@@ -816,7 +816,7 @@ lnet_portals_destroy(void)
 {
 	int i;
 
-	if (the_lnet.ln_portals == NULL)
+	if (!the_lnet.ln_portals)
 		return;
 
 	for (i = 0; i < the_lnet.ln_nportals; i++)
@@ -836,7 +836,7 @@ lnet_portals_create(void)
 
 	the_lnet.ln_nportals = MAX_PORTALS;
 	the_lnet.ln_portals = cfs_array_alloc(the_lnet.ln_nportals, size);
-	if (the_lnet.ln_portals == NULL) {
+	if (!the_lnet.ln_portals) {
 		CERROR("Failed to allocate portals table\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index f775879..0cf0645 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -165,7 +165,7 @@ lnet_ipif_enumerate(char ***namesp)
 		}
 
 		LIBCFS_ALLOC(ifr, nalloc * sizeof(*ifr));
-		if (ifr == NULL) {
+		if (!ifr) {
 			CERROR("ENOMEM enumerating up to %d interfaces\n",
 			       nalloc);
 			rc = -ENOMEM;
@@ -197,7 +197,7 @@ lnet_ipif_enumerate(char ***namesp)
 		goto out1;
 
 	LIBCFS_ALLOC(names, nfound * sizeof(*names));
-	if (names == NULL) {
+	if (!names) {
 		rc = -ENOMEM;
 		goto out1;
 	}
@@ -213,7 +213,7 @@ lnet_ipif_enumerate(char ***namesp)
 		}
 
 		LIBCFS_ALLOC(names[i], IFNAMSIZ);
-		if (names[i] == NULL) {
+		if (!names[i]) {
 			rc = -ENOMEM;
 			goto out2;
 		}
@@ -242,7 +242,7 @@ lnet_ipif_free_enumeration(char **names, int n)
 
 	LASSERT(n > 0);
 
-	for (i = 0; i < n && names[i] != NULL; i++)
+	for (i = 0; i < n && names[i]; i++)
 		LIBCFS_FREE(names[i], IFNAMSIZ);
 
 	LIBCFS_FREE(names, n * sizeof(*names));
@@ -468,10 +468,10 @@ lnet_sock_getaddr(struct socket *sock, bool remote, __u32 *ip, int *port)
 		return rc;
 	}
 
-	if (ip != NULL)
+	if (ip)
 		*ip = ntohl(sin.sin_addr.s_addr);
 
-	if (port != NULL)
+	if (port)
 		*port = ntohs(sin.sin_port);
 
 	return 0;
@@ -481,10 +481,10 @@ EXPORT_SYMBOL(lnet_sock_getaddr);
 int
 lnet_sock_getbuf(struct socket *sock, int *txbufsize, int *rxbufsize)
 {
-	if (txbufsize != NULL)
+	if (txbufsize)
 		*txbufsize = sock->sk->sk_sndbuf;
 
-	if (rxbufsize != NULL)
+	if (rxbufsize)
 		*rxbufsize = sock->sk->sk_rcvbuf;
 
 	return 0;
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 314e164..468eda6 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -52,9 +52,9 @@ lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
 {
 	lnet_msg_t *sendmsg = private;
 
-	if (lntmsg != NULL) {		   /* not discarding */
-		if (sendmsg->msg_iov != NULL) {
-			if (iov != NULL)
+	if (lntmsg) {		   /* not discarding */
+		if (sendmsg->msg_iov) {
+			if (iov)
 				lnet_copy_iov2iov(niov, iov, offset,
 						  sendmsg->msg_niov,
 						  sendmsg->msg_iov,
@@ -65,7 +65,7 @@ lolnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg,
 						   sendmsg->msg_iov,
 						   sendmsg->msg_offset, mlen);
 		} else {
-			if (iov != NULL)
+			if (iov)
 				lnet_copy_kiov2iov(niov, iov, offset,
 						   sendmsg->msg_niov,
 						   sendmsg->msg_kiov,
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index d7c9836..c9c85e5 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -170,7 +170,7 @@ parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
 	}
 
 	LIBCFS_ALLOC(addrrange, sizeof(struct addrrange));
-	if (addrrange == NULL)
+	if (!addrrange)
 		return -ENOMEM;
 	list_add_tail(&addrrange->ar_link, &nidrange->nr_addrranges);
 	INIT_LIST_HEAD(&addrrange->ar_numaddr_ranges);
@@ -203,7 +203,7 @@ add_nidrange(const struct cfs_lstr *src,
 		return NULL;
 
 	nf = libcfs_namenum2netstrfns(src->ls_str);
-	if (nf == NULL)
+	if (!nf)
 		return NULL;
 	endlen = src->ls_len - strlen(nf->nf_name);
 	if (endlen == 0)
@@ -229,7 +229,7 @@ add_nidrange(const struct cfs_lstr *src,
 	}
 
 	LIBCFS_ALLOC(nr, sizeof(struct nidrange));
-	if (nr == NULL)
+	if (!nr)
 		return NULL;
 	list_add_tail(&nr->nr_link, nidlist);
 	INIT_LIST_HEAD(&nr->nr_addrranges);
@@ -258,11 +258,11 @@ parse_nidrange(struct cfs_lstr *src, struct list_head *nidlist)
 	if (cfs_gettok(src, '@', &addrrange) == 0)
 		goto failed;
 
-	if (cfs_gettok(src, '@', &net) == 0 || src->ls_str != NULL)
+	if (cfs_gettok(src, '@', &net) == 0 || src->ls_str)
 		goto failed;
 
 	nr = add_nidrange(&net, nidlist);
-	if (nr == NULL)
+	if (!nr)
 		goto failed;
 
 	if (parse_addrange(&addrrange, nr) != 0)
@@ -489,13 +489,13 @@ static void cfs_ip_ar_min_max(struct addrrange *ar, __u32 *min_nid,
 	tmp_ip_addr = ((min_ip[0] << 24) | (min_ip[1] << 16) |
 		       (min_ip[2] << 8) | min_ip[3]);
 
-	if (min_nid != NULL)
+	if (min_nid)
 		*min_nid = tmp_ip_addr;
 
 	tmp_ip_addr = ((max_ip[0] << 24) | (max_ip[1] << 16) |
 		       (max_ip[2] << 8) | max_ip[3]);
 
-	if (max_nid != NULL)
+	if (max_nid)
 		*max_nid = tmp_ip_addr;
 }
 
@@ -524,9 +524,9 @@ static void cfs_num_ar_min_max(struct addrrange *ar, __u32 *min_nid,
 		}
 	}
 
-	if (min_nid != NULL)
+	if (min_nid)
 		*min_nid = min_addr;
-	if (max_nid != NULL)
+	if (max_nid)
 		*max_nid = max_addr;
 }
 
@@ -548,7 +548,7 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
 
 	list_for_each_entry(nr, nidlist, nr_link) {
 		nf = nr->nr_netstrfns;
-		if (lndname == NULL)
+		if (!lndname)
 			lndname = nf->nf_name;
 		if (netnum == -1)
 			netnum = nr->nr_netnum;
@@ -558,7 +558,7 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
 			return false;
 	}
 
-	if (nf == NULL)
+	if (!nf)
 		return false;
 
 	if (!nf->nf_is_contiguous(nidlist))
@@ -765,9 +765,9 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 		}
 	}
 
-	if (min_nid != NULL)
+	if (min_nid)
 		*min_nid = min_ip_addr;
-	if (max_nid != NULL)
+	if (max_nid)
 		*max_nid = max_ip_addr;
 }
 
@@ -828,7 +828,7 @@ cfs_ip_addr_parse(char *str, int len, struct list_head *list)
 	src.ls_len = len;
 	i = 0;
 
-	while (src.ls_str != NULL) {
+	while (src.ls_str) {
 		struct cfs_lstr res;
 
 		if (!cfs_gettok(&src, '.', &res)) {
@@ -1064,7 +1064,7 @@ libcfs_name2netstrfns(const char *name)
 int
 libcfs_isknown_lnd(__u32 lnd)
 {
-	return libcfs_lnd2netstrfns(lnd) != NULL;
+	return !!libcfs_lnd2netstrfns(lnd);
 }
 EXPORT_SYMBOL(libcfs_isknown_lnd);
 
@@ -1073,7 +1073,7 @@ libcfs_lnd2modname(__u32 lnd)
 {
 	struct netstrfns *nf = libcfs_lnd2netstrfns(lnd);
 
-	return (nf == NULL) ? NULL : nf->nf_modname;
+	return nf ? nf->nf_modname : NULL;
 }
 EXPORT_SYMBOL(libcfs_lnd2modname);
 
@@ -1082,7 +1082,7 @@ libcfs_str2lnd(const char *str)
 {
 	struct netstrfns *nf = libcfs_name2netstrfns(str);
 
-	if (nf != NULL)
+	if (nf)
 		return nf->nf_type;
 
 	return -1;
@@ -1095,7 +1095,7 @@ libcfs_lnd2str_r(__u32 lnd, char *buf, size_t buf_size)
 	struct netstrfns *nf;
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL)
+	if (!nf)
 		snprintf(buf, buf_size, "?%u?", lnd);
 	else
 		snprintf(buf, buf_size, "%s", nf->nf_name);
@@ -1112,7 +1112,7 @@ libcfs_net2str_r(__u32 net, char *buf, size_t buf_size)
 	struct netstrfns *nf;
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL)
+	if (!nf)
 		snprintf(buf, buf_size, "<%u:%u>", lnd, nnum);
 	else if (nnum == 0)
 		snprintf(buf, buf_size, "%s", nf->nf_name);
@@ -1139,7 +1139,7 @@ libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size)
 	}
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL) {
+	if (!nf) {
 		snprintf(buf, buf_size, "%x@<%u:%u>", addr, lnd, nnum);
 	} else {
 		size_t addr_len;
@@ -1199,7 +1199,7 @@ libcfs_str2net(const char *str)
 {
 	__u32  net;
 
-	if (libcfs_str2net_internal(str, &net) != NULL)
+	if (libcfs_str2net_internal(str, &net))
 		return net;
 
 	return LNET_NIDNET(LNET_NID_ANY);
@@ -1214,15 +1214,15 @@ libcfs_str2nid(const char *str)
 	__u32 net;
 	__u32 addr;
 
-	if (sep != NULL) {
+	if (sep) {
 		nf = libcfs_str2net_internal(sep + 1, &net);
-		if (nf == NULL)
+		if (!nf)
 			return LNET_NID_ANY;
 	} else {
 		sep = str + strlen(str);
 		net = LNET_MKNET(SOCKLND, 0);
 		nf = libcfs_lnd2netstrfns(SOCKLND);
-		LASSERT(nf != NULL);
+		LASSERT(nf);
 	}
 
 	if (!nf->nf_str2addr(str, (int)(sep - str), &addr))
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index a8e25b0..43b459e 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -50,7 +50,7 @@ lnet_peer_tables_create(void)
 
 	the_lnet.ln_peer_tables = cfs_percpt_alloc(lnet_cpt_table(),
 						   sizeof(*ptable));
-	if (the_lnet.ln_peer_tables == NULL) {
+	if (!the_lnet.ln_peer_tables) {
 		CERROR("Failed to allocate cpu-partition peer tables\n");
 		return -ENOMEM;
 	}
@@ -60,7 +60,7 @@ lnet_peer_tables_create(void)
 
 		LIBCFS_CPT_ALLOC(hash, lnet_cpt_table(), i,
 				 LNET_PEER_HASH_SIZE * sizeof(*hash));
-		if (hash == NULL) {
+		if (!hash) {
 			CERROR("Failed to create peer hash table\n");
 			lnet_peer_tables_destroy();
 			return -ENOMEM;
@@ -82,12 +82,12 @@ lnet_peer_tables_destroy(void)
 	int i;
 	int j;
 
-	if (the_lnet.ln_peer_tables == NULL)
+	if (!the_lnet.ln_peer_tables)
 		return;
 
 	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
 		hash = ptable->pt_hash;
-		if (hash == NULL) /* not initialized */
+		if (!hash) /* not initialized */
 			break;
 
 		LASSERT(list_empty(&ptable->pt_deathrow));
@@ -220,7 +220,7 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 
 	ptable = the_lnet.ln_peer_tables[cpt2];
 	lp = lnet_find_peer_locked(ptable, nid);
-	if (lp != NULL) {
+	if (lp) {
 		*lpp = lp;
 		return 0;
 	}
@@ -238,12 +238,12 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 	ptable->pt_number++;
 	lnet_net_unlock(cpt);
 
-	if (lp != NULL)
+	if (lp)
 		memset(lp, 0, sizeof(*lp));
 	else
 		LIBCFS_CPT_ALLOC(lp, lnet_cpt_table(), cpt2, sizeof(*lp));
 
-	if (lp == NULL) {
+	if (!lp) {
 		rc = -ENOMEM;
 		lnet_net_lock(cpt);
 		goto out;
@@ -276,13 +276,13 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 	}
 
 	lp2 = lnet_find_peer_locked(ptable, nid);
-	if (lp2 != NULL) {
+	if (lp2) {
 		*lpp = lp2;
 		goto out;
 	}
 
 	lp->lp_ni = lnet_net2ni_locked(LNET_NIDNET(nid), cpt2);
-	if (lp->lp_ni == NULL) {
+	if (!lp->lp_ni) {
 		rc = -EHOSTUNREACH;
 		goto out;
 	}
@@ -299,7 +299,7 @@ lnet_nid2peer_locked(lnet_peer_t **lpp, lnet_nid_t nid, int cpt)
 
 	return 0;
 out:
-	if (lp != NULL)
+	if (lp)
 		list_add(&lp->lp_hashlist, &ptable->pt_deathrow);
 	ptable->pt_number--;
 	return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 36f3caa..c6b747d 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -138,7 +138,7 @@ lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 	 * NB individual events can be missed; the only guarantee is that you
 	 * always get the most recent news
 	 */
-	if (lp->lp_notifying || ni == NULL)
+	if (lp->lp_notifying || !ni)
 		return;
 
 	lp->lp_notifying = 1;
@@ -150,7 +150,7 @@ lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 		lp->lp_notifylnd = 0;
 		lp->lp_notify    = 0;
 
-		if (notifylnd && ni->ni_lnd->lnd_notify != NULL) {
+		if (notifylnd && ni->ni_lnd->lnd_notify) {
 			lnet_net_unlock(lp->lp_cpt);
 
 			/*
@@ -204,7 +204,7 @@ lnet_rtr_decref_locked(lnet_peer_t *lp)
 	if (lp->lp_rtr_refcount == 0) {
 		LASSERT(list_empty(&lp->lp_routes));
 
-		if (lp->lp_rcd != NULL) {
+		if (lp->lp_rcd) {
 			list_add(&lp->lp_rcd->rcd_list,
 				 &the_lnet.ln_rcd_deathrow);
 			lp->lp_rcd = NULL;
@@ -323,12 +323,12 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	/* Assume net, route, all new */
 	LIBCFS_ALLOC(route, sizeof(*route));
 	LIBCFS_ALLOC(rnet, sizeof(*rnet));
-	if (route == NULL || rnet == NULL) {
+	if (!route || !rnet) {
 		CERROR("Out of memory creating route %s %d %s\n",
 		       libcfs_net2str(net), hops, libcfs_nid2str(gateway));
-		if (route != NULL)
+		if (route)
 			LIBCFS_FREE(route, sizeof(*route));
-		if (rnet != NULL)
+		if (rnet)
 			LIBCFS_FREE(rnet, sizeof(*rnet));
 		return -ENOMEM;
 	}
@@ -359,7 +359,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	LASSERT(!the_lnet.ln_shutdown);
 
 	rnet2 = lnet_find_net_locked(net);
-	if (rnet2 == NULL) {
+	if (!rnet2) {
 		/* new network */
 		list_add_tail(&rnet->lrn_list, lnet_net2rnethash(net));
 		rnet2 = rnet;
@@ -387,7 +387,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 		lnet_net_unlock(LNET_LOCK_EX);
 
 		/* XXX Assume alive */
-		if (ni->ni_lnd->lnd_notify != NULL)
+		if (ni->ni_lnd->lnd_notify)
 			ni->ni_lnd->lnd_notify(ni, gateway, 1);
 
 		lnet_net_lock(LNET_LOCK_EX);
@@ -433,7 +433,7 @@ lnet_check_routes(void)
 
 				route = list_entry(e2, lnet_route_t, lr_list);
 
-				if (route2 == NULL) {
+				if (!route2) {
 					route2 = route;
 					continue;
 				}
@@ -518,7 +518,7 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
 
 			LIBCFS_FREE(route, sizeof(*route));
 
-			if (rnet != NULL)
+			if (rnet)
 				LIBCFS_FREE(rnet, sizeof(*rnet));
 
 			rc = 0;
@@ -696,7 +696,7 @@ lnet_router_checker_event(lnet_event_t *event)
 	lnet_rc_data_t *rcd = event->md.user_ptr;
 	struct lnet_peer *lp;
 
-	LASSERT(rcd != NULL);
+	LASSERT(rcd);
 
 	if (event->unlinked) {
 		LNetInvalidateHandle(&rcd->rcd_mdh);
@@ -707,7 +707,7 @@ lnet_router_checker_event(lnet_event_t *event)
 		event->type == LNET_EVENT_REPLY);
 
 	lp = rcd->rcd_gateway;
-	LASSERT(lp != NULL);
+	LASSERT(lp);
 
 	/*
 	 * NB: it's called with holding lnet_res_lock, we have a few
@@ -822,7 +822,7 @@ lnet_update_ni_status_locked(void)
 			continue;
 		}
 
-		LASSERT(ni->ni_status != NULL);
+		LASSERT(ni->ni_status);
 
 		if (ni->ni_status->ns_status != LNET_NI_STATUS_DOWN) {
 			CDEBUG(D_NET, "NI(%s:%d) status changed to down\n",
@@ -844,7 +844,7 @@ lnet_destroy_rc_data(lnet_rc_data_t *rcd)
 	/* detached from network */
 	LASSERT(LNetHandleIsInvalid(rcd->rcd_mdh));
 
-	if (rcd->rcd_gateway != NULL) {
+	if (rcd->rcd_gateway) {
 		int cpt = rcd->rcd_gateway->lp_cpt;
 
 		lnet_net_lock(cpt);
@@ -852,7 +852,7 @@ lnet_destroy_rc_data(lnet_rc_data_t *rcd)
 		lnet_net_unlock(cpt);
 	}
 
-	if (rcd->rcd_pinginfo != NULL)
+	if (rcd->rcd_pinginfo)
 		LIBCFS_FREE(rcd->rcd_pinginfo, LNET_PINGINFO_SIZE);
 
 	LIBCFS_FREE(rcd, sizeof(*rcd));
@@ -869,14 +869,14 @@ lnet_create_rc_data_locked(lnet_peer_t *gateway)
 	lnet_net_unlock(gateway->lp_cpt);
 
 	LIBCFS_ALLOC(rcd, sizeof(*rcd));
-	if (rcd == NULL)
+	if (!rcd)
 		goto out;
 
 	LNetInvalidateHandle(&rcd->rcd_mdh);
 	INIT_LIST_HEAD(&rcd->rcd_list);
 
 	LIBCFS_ALLOC(pi, LNET_PINGINFO_SIZE);
-	if (pi == NULL)
+	if (!pi)
 		goto out;
 
 	for (i = 0; i < LNET_MAX_RTR_NIS; i++) {
@@ -902,7 +902,7 @@ lnet_create_rc_data_locked(lnet_peer_t *gateway)
 
 	lnet_net_lock(gateway->lp_cpt);
 	/* router table changed or someone has created rcd for this gateway */
-	if (!lnet_isrouter(gateway) || gateway->lp_rcd != NULL) {
+	if (!lnet_isrouter(gateway) || gateway->lp_rcd) {
 		lnet_net_unlock(gateway->lp_cpt);
 		goto out;
 	}
@@ -915,7 +915,7 @@ lnet_create_rc_data_locked(lnet_peer_t *gateway)
 	return rcd;
 
  out:
-	if (rcd != NULL) {
+	if (rcd) {
 		if (!LNetHandleIsInvalid(rcd->rcd_mdh)) {
 			rc = LNetMDUnlink(rcd->rcd_mdh);
 			LASSERT(rc == 0);
@@ -963,10 +963,10 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 		return;
 	}
 
-	rcd = rtr->lp_rcd != NULL ?
+	rcd = rtr->lp_rcd ?
 	      rtr->lp_rcd : lnet_create_rc_data_locked(rtr);
 
-	if (rcd == NULL)
+	if (!rcd)
 		return;
 
 	secs = lnet_router_check_interval(rtr);
@@ -1109,7 +1109,7 @@ lnet_prune_rc_data(int wait_unlink)
 		/* router checker is stopping, prune all */
 		list_for_each_entry(lp, &the_lnet.ln_routers,
 				    lp_rtr_list) {
-			if (lp->lp_rcd == NULL)
+			if (!lp->lp_rcd)
 				continue;
 
 			LASSERT(list_empty(&lp->lp_rcd->rcd_list));
@@ -1256,7 +1256,7 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 	int i;
 
 	LIBCFS_CPT_ALLOC(rb, lnet_cpt_table(), cpt, sz);
-	if (rb == NULL)
+	if (!rb)
 		return NULL;
 
 	rb->rb_pool = rbp;
@@ -1265,7 +1265,7 @@ lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
 		page = alloc_pages_node(
 				cfs_cpt_spread_node(lnet_cpt_table(), cpt),
 				GFP_KERNEL | __GFP_ZERO, 0);
-		if (page == NULL) {
+		if (!page) {
 			while (--i >= 0)
 				__free_page(rb->rb_kiov[i].kiov_page);
 
@@ -1325,7 +1325,7 @@ lnet_rtrpool_alloc_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
 	for (i = 0; i < nbufs; i++) {
 		rb = lnet_new_rtrbuf(rbp, cpt);
 
-		if (rb == NULL) {
+		if (!rb) {
 			CERROR("Failed to allocate %d router bufs of %d pages\n",
 			       nbufs, rbp->rbp_npages);
 			return -ENOMEM;
@@ -1362,7 +1362,7 @@ lnet_rtrpools_free(void)
 	lnet_rtrbufpool_t *rtrp;
 	int i;
 
-	if (the_lnet.ln_rtrpools == NULL) /* uninitialized or freed */
+	if (!the_lnet.ln_rtrpools) /* uninitialized or freed */
 		return;
 
 	cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
@@ -1475,7 +1475,7 @@ lnet_rtrpools_alloc(int im_a_router)
 	the_lnet.ln_rtrpools = cfs_percpt_alloc(lnet_cpt_table(),
 						LNET_NRBPOOLS *
 						sizeof(lnet_rtrbufpool_t));
-	if (the_lnet.ln_rtrpools == NULL) {
+	if (!the_lnet.ln_rtrpools) {
 		LCONSOLE_ERROR_MSG(0x10c,
 				   "Failed to initialize router buffe pool\n");
 		return -ENOMEM;
@@ -1519,11 +1519,11 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	LASSERT(!in_interrupt());
 
 	CDEBUG(D_NET, "%s notifying %s: %s\n",
-	       (ni == NULL) ? "userspace" : libcfs_nid2str(ni->ni_nid),
+	       !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
 	       libcfs_nid2str(nid),
 	       alive ? "up" : "down");
 
-	if (ni != NULL &&
+	if (ni &&
 	    LNET_NIDNET(ni->ni_nid) != LNET_NIDNET(nid)) {
 		CWARN("Ignoring notification of %s %s by %s (different net)\n",
 		      libcfs_nid2str(nid), alive ? "birth" : "death",
@@ -1534,13 +1534,13 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	/* can't do predictions... */
 	if (cfs_time_after(when, now)) {
 		CWARN("Ignoring prediction from %s of %s %s %ld seconds in the future\n",
-		      (ni == NULL) ? "userspace" : libcfs_nid2str(ni->ni_nid),
+		      !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
 		      libcfs_nid2str(nid), alive ? "up" : "down",
 		      cfs_duration_sec(cfs_time_sub(when, now)));
 		return -EINVAL;
 	}
 
-	if (ni != NULL && !alive &&	     /* LND telling me she's down */
+	if (ni && !alive &&	     /* LND telling me she's down */
 	    !auto_down) {		       /* auto-down disabled */
 		CDEBUG(D_NET, "Auto-down disabled\n");
 		return 0;
@@ -1554,7 +1554,7 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	}
 
 	lp = lnet_find_peer_locked(the_lnet.ln_peer_tables[cpt], nid);
-	if (lp == NULL) {
+	if (!lp) {
 		/* nid not found */
 		lnet_net_unlock(cpt);
 		CDEBUG(D_NET, "%s not found\n", libcfs_nid2str(nid));
@@ -1567,10 +1567,10 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 	 * call us with when == _time_when_the_node_was_booted_ if
 	 * no connections were successfully established
 	 */
-	if (ni != NULL && !alive && when < lp->lp_last_alive)
+	if (ni && !alive && when < lp->lp_last_alive)
 		when = lp->lp_last_alive;
 
-	lnet_notify_locked(lp, ni == NULL, alive, when);
+	lnet_notify_locked(lp, !ni, alive, when);
 
 	lnet_ni_notify_locked(ni, lp);
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 124737e..230fc15 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -114,11 +114,11 @@ static int __proc_lnet_stats(void *data, int write,
 	/* read */
 
 	LIBCFS_ALLOC(ctrs, sizeof(*ctrs));
-	if (ctrs == NULL)
+	if (!ctrs)
 		return -ENOMEM;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
-	if (tmpstr == NULL) {
+	if (!tmpstr) {
 		LIBCFS_FREE(ctrs, sizeof(*ctrs));
 		return -ENOMEM;
 	}
@@ -174,7 +174,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 		return 0;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
-	if (tmpstr == NULL)
+	if (!tmpstr)
 		return -ENOMEM;
 
 	s = tmpstr; /* points to current position in tmpstr[] */
@@ -209,13 +209,12 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			return -ESTALE;
 		}
 
-		for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE && route == NULL;
-		     i++) {
+		for (i = 0; i < LNET_REMOTE_NETS_HASH_SIZE && !route; i++) {
 			rn_list = &the_lnet.ln_remote_nets_hash[i];
 
 			n = rn_list->next;
 
-			while (n != rn_list && route == NULL) {
+			while (n != rn_list && !route) {
 				rnet = list_entry(n, lnet_remotenet_t,
 						  lrn_list);
 
@@ -238,7 +237,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 			}
 		}
 
-		if (route != NULL) {
+		if (route) {
 			__u32 net = rnet->lrn_net;
 			unsigned int hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
@@ -298,7 +297,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		return 0;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
-	if (tmpstr == NULL)
+	if (!tmpstr)
 		return -ENOMEM;
 
 	s = tmpstr; /* points to current position in tmpstr[] */
@@ -344,7 +343,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			r = r->next;
 		}
 
-		if (peer != NULL) {
+		if (peer) {
 			lnet_nid_t nid = peer->lp_nid;
 			unsigned long now = cfs_time_current();
 			unsigned long deadline = peer->lp_ping_deadline;
@@ -441,7 +440,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 	}
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
-	if (tmpstr == NULL)
+	if (!tmpstr)
 		return -ENOMEM;
 
 	s = tmpstr; /* points to current position in tmpstr[] */
@@ -475,7 +474,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 		}
 
 		while (hash < LNET_PEER_HASH_SIZE) {
-			if (p == NULL)
+			if (!p)
 				p = ptable->pt_hash[hash].next;
 
 			while (p != &ptable->pt_hash[hash]) {
@@ -504,7 +503,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				p = lp->lp_hashlist.next;
 			}
 
-			if (peer != NULL)
+			if (peer)
 				break;
 
 			p = NULL;
@@ -512,7 +511,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			hash++;
 		}
 
-		if (peer != NULL) {
+		if (peer) {
 			lnet_nid_t nid = peer->lp_nid;
 			int nrefs = peer->lp_refcount;
 			int lastalive = -1;
@@ -560,7 +559,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			cpt++;
 			hash = 0;
 			hoff = 1;
-			if (peer == NULL && cpt < LNET_CPT_NUMBER)
+			if (!peer && cpt < LNET_CPT_NUMBER)
 				goto again;
 		}
 	}
@@ -600,7 +599,7 @@ static int __proc_lnet_buffers(void *data, int write,
 	/* (4 %d) * 4 * LNET_CPT_NUMBER */
 	tmpsiz = 64 * (LNET_NRBPOOLS + 1) * LNET_CPT_NUMBER;
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
-	if (tmpstr == NULL)
+	if (!tmpstr)
 		return -ENOMEM;
 
 	s = tmpstr; /* points to current position in tmpstr[] */
@@ -610,7 +609,7 @@ static int __proc_lnet_buffers(void *data, int write,
 		      "pages", "count", "credits", "min");
 	LASSERT(tmpstr + tmpsiz - s > 0);
 
-	if (the_lnet.ln_rtrpools == NULL)
+	if (!the_lnet.ln_rtrpools)
 		goto out; /* I'm not a router */
 
 	for (idx = 0; idx < LNET_NRBPOOLS; idx++) {
@@ -664,7 +663,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 		return 0;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
-	if (tmpstr == NULL)
+	if (!tmpstr)
 		return -ENOMEM;
 
 	s = tmpstr; /* points to current position in tmpstr[] */
@@ -696,7 +695,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 			n = n->next;
 		}
 
-		if (ni != NULL) {
+		if (ni) {
 			struct lnet_tx_queue *tq;
 			char *stat;
 			time64_t now = ktime_get_real_seconds();
@@ -712,7 +711,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 				last_alive = 0;
 
 			lnet_ni_lock(ni);
-			LASSERT(ni->ni_status != NULL);
+			LASSERT(ni->ni_status);
 			stat = (ni->ni_status->ns_status ==
 				LNET_NI_STATUS_UP) ? "up" : "down";
 			lnet_ni_unlock(ni);
@@ -722,7 +721,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 			 * TX queue of each partition
 			 */
 			cfs_percpt_for_each(tq, i, ni->ni_tx_queues) {
-				for (j = 0; ni->ni_cpts != NULL &&
+				for (j = 0; ni->ni_cpts &&
 				     j < ni->ni_ncpts; j++) {
 					if (i == ni->ni_cpts[j])
 						break;
@@ -817,7 +816,7 @@ static int __proc_lnet_portal_rotor(void *data, int write,
 	int i;
 
 	LIBCFS_ALLOC(buf, buf_len);
-	if (buf == NULL)
+	if (!buf)
 		return -ENOMEM;
 
 	if (!write) {
@@ -854,7 +853,7 @@ static int __proc_lnet_portal_rotor(void *data, int write,
 
 	rc = -EINVAL;
 	lnet_res_lock(0);
-	for (i = 0; portal_rotors[i].pr_name != NULL; i++) {
+	for (i = 0; portal_rotors[i].pr_name; i++) {
 		if (strncasecmp(portal_rotors[i].pr_name, tmp,
 				strlen(portal_rotors[i].pr_name)) == 0) {
 			portal_rotor = portal_rotors[i].pr_value;
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 4af91cb..38aed80 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -58,7 +58,7 @@ brw_client_fini(sfw_test_instance_t *tsi)
 
 	list_for_each_entry(tsu, &tsi->tsi_units, tsu_list) {
 		bulk = tsu->tsu_private;
-		if (bulk == NULL)
+		if (!bulk)
 			continue;
 
 		srpc_free_bulk(bulk);
@@ -77,7 +77,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 	srpc_bulk_t	 *bulk;
 	sfw_test_unit_t	 *tsu;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 	LASSERT(tsi->tsi_is_client);
 
 	if ((sn->sn_features & LST_FEAT_BULK_LEN) == 0) {
@@ -120,7 +120,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 	list_for_each_entry(tsu, &tsi->tsi_units, tsu_list) {
 		bulk = srpc_alloc_bulk(lnet_cpt_of_nid(tsu->tsu_dest.nid),
 				       npg, len, opc == LST_BRW_READ);
-		if (bulk == NULL) {
+		if (!bulk) {
 			brw_client_fini(tsi);
 			return -ENOMEM;
 		}
@@ -157,7 +157,7 @@ brw_fill_page(struct page *pg, int pattern, __u64 magic)
 	char *addr = page_address(pg);
 	int   i;
 
-	LASSERT(addr != NULL);
+	LASSERT(addr);
 
 	if (pattern == LST_BRW_CHECK_NONE)
 		return;
@@ -188,7 +188,7 @@ brw_check_page(struct page *pg, int pattern, __u64 magic)
 	__u64  data = 0; /* make compiler happy */
 	int    i;
 
-	LASSERT(addr != NULL);
+	LASSERT(addr);
 
 	if (pattern == LST_BRW_CHECK_NONE)
 		return 0;
@@ -269,8 +269,8 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 	int opc;
 	int rc;
 
-	LASSERT(sn != NULL);
-	LASSERT(bulk != NULL);
+	LASSERT(sn);
+	LASSERT(bulk);
 
 	if ((sn->sn_features & LST_FEAT_BULK_LEN) == 0) {
 		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
@@ -324,7 +324,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	srpc_brw_reply_t *reply = &msg->msg_body.brw_reply;
 	srpc_brw_reqst_t *reqst = &rpc->crpc_reqstmsg.msg_body.brw_reqst;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 
 	if (rpc->crpc_status != 0) {
 		CERROR("BRW RPC to %s failed with %d\n",
@@ -368,7 +368,7 @@ brw_server_rpc_done(struct srpc_server_rpc *rpc)
 {
 	srpc_bulk_t *blk = rpc->srpc_bulk;
 
-	if (blk == NULL)
+	if (!blk)
 		return;
 
 	if (rpc->srpc_status != 0)
@@ -391,8 +391,8 @@ brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	srpc_brw_reqst_t *reqst;
 	srpc_msg_t *reqstmsg;
 
-	LASSERT(rpc->srpc_bulk != NULL);
-	LASSERT(rpc->srpc_reqstbuf != NULL);
+	LASSERT(rpc->srpc_bulk);
+	LASSERT(rpc->srpc_reqstbuf);
 
 	reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
 	reqst = &reqstmsg->msg_body.brw_reqst;
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index cb5c125..8b9717c 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -51,15 +51,15 @@ lst_session_new_ioctl(lstio_session_new_args_t *args)
 	char *name;
 	int rc;
 
-	if (args->lstio_ses_idp   == NULL || /* address for output sid */
+	if (!args->lstio_ses_idp || /* address for output sid */
 	    args->lstio_ses_key   == 0 ||    /* no key is specified */
-	    args->lstio_ses_namep == NULL || /* session name */
+	    !args->lstio_ses_namep || /* session name */
 	    args->lstio_ses_nmlen <= 0 ||
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_ses_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_ses_namep,
@@ -95,11 +95,11 @@ lst_session_info_ioctl(lstio_session_info_args_t *args)
 {
 	/* no checking of key */
 
-	if (args->lstio_ses_idp    == NULL || /* address for output sid */
-	    args->lstio_ses_keyp   == NULL || /* address for output key */
-	    args->lstio_ses_featp  == NULL || /* address for output features */
-	    args->lstio_ses_ndinfo == NULL || /* address for output ndinfo */
-	    args->lstio_ses_namep  == NULL || /* address for output name */
+	if (!args->lstio_ses_idp || /* address for output sid */
+	    !args->lstio_ses_keyp || /* address for output key */
+	    !args->lstio_ses_featp || /* address for output features */
+	    !args->lstio_ses_ndinfo || /* address for output ndinfo */
+	    !args->lstio_ses_namep || /* address for output name */
 	    args->lstio_ses_nmlen  <= 0 ||
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -122,17 +122,17 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 	if (args->lstio_dbg_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_dbg_resultp == NULL)
+	if (!args->lstio_dbg_resultp)
 		return -EINVAL;
 
-	if (args->lstio_dbg_namep != NULL && /* name of batch/group */
+	if (args->lstio_dbg_namep && /* name of batch/group */
 	    (args->lstio_dbg_nmlen <= 0 ||
 	     args->lstio_dbg_nmlen > LST_NAME_SIZE))
 		return -EINVAL;
 
-	if (args->lstio_dbg_namep != NULL) {
+	if (args->lstio_dbg_namep) {
 		LIBCFS_ALLOC(name, args->lstio_dbg_nmlen + 1);
-		if (name == NULL)
+		if (!name)
 			return -ENOMEM;
 
 		if (copy_from_user(name, args->lstio_dbg_namep,
@@ -156,7 +156,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 	case LST_OPC_BATCHSRV:
 		client = 0;
 	case LST_OPC_BATCHCLI:
-		if (name == NULL)
+		if (!name)
 			goto out;
 
 		rc = lstcon_batch_debug(args->lstio_dbg_timeout,
@@ -164,7 +164,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 		break;
 
 	case LST_OPC_GROUP:
-		if (name == NULL)
+		if (!name)
 			goto out;
 
 		rc = lstcon_group_debug(args->lstio_dbg_timeout,
@@ -173,7 +173,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 
 	case LST_OPC_NODES:
 		if (args->lstio_dbg_count <= 0 ||
-		    args->lstio_dbg_idsp == NULL)
+		    !args->lstio_dbg_idsp)
 			goto out;
 
 		rc = lstcon_nodes_debug(args->lstio_dbg_timeout,
@@ -187,7 +187,7 @@ lst_debug_ioctl(lstio_debug_args_t *args)
 	}
 
 out:
-	if (name != NULL)
+	if (name)
 		LIBCFS_FREE(name, args->lstio_dbg_nmlen + 1);
 
 	return rc;
@@ -202,13 +202,13 @@ lst_group_add_ioctl(lstio_group_add_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_grp_namep == NULL ||
+	if (!args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_grp_namep,
@@ -235,13 +235,13 @@ lst_group_del_ioctl(lstio_group_del_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_grp_namep == NULL ||
+	if (!args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_grp_namep,
@@ -268,14 +268,14 @@ lst_group_update_ioctl(lstio_group_update_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_grp_resultp == NULL ||
-	    args->lstio_grp_namep == NULL ||
+	if (!args->lstio_grp_resultp ||
+	    !args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name,
@@ -298,7 +298,7 @@ lst_group_update_ioctl(lstio_group_update_args_t *args)
 
 	case LST_GROUP_RMND:
 		if (args->lstio_grp_count  <= 0 ||
-		    args->lstio_grp_idsp == NULL) {
+		    !args->lstio_grp_idsp) {
 			rc = -EINVAL;
 			break;
 		}
@@ -327,17 +327,17 @@ lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_grp_idsp == NULL || /* array of ids */
+	if (!args->lstio_grp_idsp || /* array of ids */
 	    args->lstio_grp_count <= 0 ||
-	    args->lstio_grp_resultp == NULL ||
-	    args->lstio_grp_featp == NULL ||
-	    args->lstio_grp_namep == NULL ||
+	    !args->lstio_grp_resultp ||
+	    !args->lstio_grp_featp ||
+	    !args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_grp_namep,
@@ -369,7 +369,7 @@ lst_group_list_ioctl(lstio_group_list_args_t *args)
 		return -EACCES;
 
 	if (args->lstio_grp_idx   < 0 ||
-	    args->lstio_grp_namep == NULL ||
+	    !args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -390,18 +390,18 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_grp_namep == NULL ||
+	if (!args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (args->lstio_grp_entp  == NULL && /* output: group entry */
-	    args->lstio_grp_dentsp == NULL)  /* output: node entry */
+	if (!args->lstio_grp_entp &&  /* output: group entry */
+	    !args->lstio_grp_dentsp)  /* output: node entry */
 		return -EINVAL;
 
-	if (args->lstio_grp_dentsp != NULL) { /* have node entry */
-		if (args->lstio_grp_idxp == NULL || /* node index */
-		    args->lstio_grp_ndentp == NULL) /* # of node entry */
+	if (args->lstio_grp_dentsp) { /* have node entry */
+		if (!args->lstio_grp_idxp || /* node index */
+		    !args->lstio_grp_ndentp) /* # of node entry */
 			return -EINVAL;
 
 		if (copy_from_user(&ndent, args->lstio_grp_ndentp,
@@ -415,7 +415,7 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 	}
 
 	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_grp_namep,
@@ -434,7 +434,7 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 	if (rc != 0)
 		return rc;
 
-	if (args->lstio_grp_dentsp != NULL &&
+	if (args->lstio_grp_dentsp &&
 	    (copy_to_user(args->lstio_grp_idxp, &index, sizeof(index)) ||
 	     copy_to_user(args->lstio_grp_ndentp, &ndent, sizeof(ndent))))
 		return -EFAULT;
@@ -451,13 +451,13 @@ lst_batch_add_ioctl(lstio_batch_add_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_bat_namep == NULL ||
+	if (!args->lstio_bat_namep ||
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_bat_namep,
@@ -484,13 +484,13 @@ lst_batch_run_ioctl(lstio_batch_run_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_bat_namep == NULL ||
+	if (!args->lstio_bat_namep ||
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_bat_namep,
@@ -518,14 +518,14 @@ lst_batch_stop_ioctl(lstio_batch_stop_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_bat_resultp == NULL ||
-	    args->lstio_bat_namep == NULL ||
+	if (!args->lstio_bat_resultp ||
+	    !args->lstio_bat_namep ||
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_bat_namep,
@@ -553,8 +553,8 @@ lst_batch_query_ioctl(lstio_batch_query_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_bat_resultp == NULL ||
-	    args->lstio_bat_namep == NULL ||
+	if (!args->lstio_bat_resultp ||
+	    !args->lstio_bat_namep ||
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -563,7 +563,7 @@ lst_batch_query_ioctl(lstio_batch_query_args_t *args)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_bat_namep,
@@ -592,7 +592,7 @@ lst_batch_list_ioctl(lstio_batch_list_args_t *args)
 		return -EACCES;
 
 	if (args->lstio_bat_idx   < 0 ||
-	    args->lstio_bat_namep == NULL ||
+	    !args->lstio_bat_namep ||
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -613,18 +613,18 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_bat_namep == NULL || /* batch name */
+	if (!args->lstio_bat_namep || /* batch name */
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (args->lstio_bat_entp == NULL && /* output: batch entry */
-	    args->lstio_bat_dentsp == NULL) /* output: node entry */
+	if (!args->lstio_bat_entp && /* output: batch entry */
+	    !args->lstio_bat_dentsp) /* output: node entry */
 		return -EINVAL;
 
-	if (args->lstio_bat_dentsp != NULL) { /* have node entry */
-		if (args->lstio_bat_idxp == NULL || /* node index */
-		    args->lstio_bat_ndentp == NULL) /* # of node entry */
+	if (args->lstio_bat_dentsp) { /* have node entry */
+		if (!args->lstio_bat_idxp || /* node index */
+		    !args->lstio_bat_ndentp) /* # of node entry */
 			return -EINVAL;
 
 		if (copy_from_user(&index, args->lstio_bat_idxp,
@@ -638,7 +638,7 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 	}
 
 	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_bat_namep,
@@ -658,7 +658,7 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 	if (rc != 0)
 		return rc;
 
-	if (args->lstio_bat_dentsp != NULL &&
+	if (args->lstio_bat_dentsp &&
 	    (copy_to_user(args->lstio_bat_idxp, &index, sizeof(index)) ||
 	     copy_to_user(args->lstio_bat_ndentp, &ndent, sizeof(ndent))))
 		rc = -EFAULT;
@@ -676,19 +676,18 @@ lst_stat_query_ioctl(lstio_stat_args_t *args)
 	if (args->lstio_sta_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_sta_resultp == NULL ||
-	    (args->lstio_sta_namep  == NULL &&
-	     args->lstio_sta_idsp   == NULL) ||
+	if (!args->lstio_sta_resultp ||
+	    (!args->lstio_sta_namep && !args->lstio_sta_idsp) ||
 	    args->lstio_sta_nmlen <= 0 ||
 	    args->lstio_sta_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (args->lstio_sta_idsp != NULL &&
+	if (args->lstio_sta_idsp &&
 	    args->lstio_sta_count <= 0)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
-	if (name == NULL)
+	if (!name)
 		return -ENOMEM;
 
 	if (copy_from_user(name, args->lstio_sta_namep,
@@ -697,7 +696,7 @@ lst_stat_query_ioctl(lstio_stat_args_t *args)
 		return -EFAULT;
 	}
 
-	if (args->lstio_sta_idsp == NULL) {
+	if (!args->lstio_sta_idsp) {
 		rc = lstcon_group_stat(name, args->lstio_sta_timeout,
 				       args->lstio_sta_resultp);
 	} else {
@@ -721,15 +720,15 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	int		ret = 0;
 	int		rc = -ENOMEM;
 
-	if (args->lstio_tes_resultp == NULL ||
-	    args->lstio_tes_retp == NULL ||
-	    args->lstio_tes_bat_name == NULL || /* no specified batch */
+	if (!args->lstio_tes_resultp ||
+	    !args->lstio_tes_retp ||
+	    !args->lstio_tes_bat_name || /* no specified batch */
 	    args->lstio_tes_bat_nmlen <= 0 ||
 	    args->lstio_tes_bat_nmlen > LST_NAME_SIZE ||
-	    args->lstio_tes_sgrp_name == NULL || /* no source group */
+	    !args->lstio_tes_sgrp_name || /* no source group */
 	    args->lstio_tes_sgrp_nmlen <= 0 ||
 	    args->lstio_tes_sgrp_nmlen > LST_NAME_SIZE ||
-	    args->lstio_tes_dgrp_name == NULL || /* no target group */
+	    !args->lstio_tes_dgrp_name || /* no target group */
 	    args->lstio_tes_dgrp_nmlen <= 0 ||
 	    args->lstio_tes_dgrp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
@@ -741,26 +740,26 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		return -EINVAL;
 
 	/* have parameter, check if parameter length is valid */
-	if (args->lstio_tes_param != NULL &&
+	if (args->lstio_tes_param &&
 	    (args->lstio_tes_param_len <= 0 ||
 	     args->lstio_tes_param_len > PAGE_CACHE_SIZE - sizeof(lstcon_test_t)))
 		return -EINVAL;
 
 	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
-	if (batch_name == NULL)
+	if (!batch_name)
 		return rc;
 
 	LIBCFS_ALLOC(src_name, args->lstio_tes_sgrp_nmlen + 1);
-	if (src_name == NULL)
+	if (!src_name)
 		goto out;
 
 	LIBCFS_ALLOC(dst_name, args->lstio_tes_dgrp_nmlen + 1);
-	 if (dst_name == NULL)
+	 if (!dst_name)
 		goto out;
 
-	if (args->lstio_tes_param != NULL) {
+	if (args->lstio_tes_param) {
 		LIBCFS_ALLOC(param, args->lstio_tes_param_len);
-		if (param == NULL)
+		if (!param)
 			goto out;
 	}
 
@@ -786,16 +785,16 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = (copy_to_user(args->lstio_tes_retp, &ret,
 				   sizeof(ret))) ? -EFAULT : 0;
 out:
-	if (batch_name != NULL)
+	if (batch_name)
 		LIBCFS_FREE(batch_name, args->lstio_tes_bat_nmlen + 1);
 
-	if (src_name != NULL)
+	if (src_name)
 		LIBCFS_FREE(src_name, args->lstio_tes_sgrp_nmlen + 1);
 
-	if (dst_name != NULL)
+	if (dst_name)
 		LIBCFS_FREE(dst_name, args->lstio_tes_dgrp_nmlen + 1);
 
-	if (param != NULL)
+	if (param)
 		LIBCFS_FREE(param, args->lstio_tes_param_len);
 
 	return rc;
@@ -815,7 +814,7 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data)
 		return -EINVAL;
 
 	LIBCFS_ALLOC(buf, data->ioc_plen1);
-	if (buf == NULL)
+	if (!buf)
 		return -ENOMEM;
 
 	/* copy in parameter */
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 817be93..5315a37 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -54,12 +54,12 @@ lstcon_rpc_done(srpc_client_rpc_t *rpc)
 {
 	lstcon_rpc_t *crpc = (lstcon_rpc_t *)rpc->crpc_priv;
 
-	LASSERT(crpc != NULL && rpc == crpc->crp_rpc);
+	LASSERT(crpc && rpc == crpc->crp_rpc);
 	LASSERT(crpc->crp_posted && !crpc->crp_finished);
 
 	spin_lock(&rpc->crpc_lock);
 
-	if (crpc->crp_trans == NULL) {
+	if (!crpc->crp_trans) {
 		/*
 		 * Orphan RPC is not in any transaction,
 		 * I'm just a poor body and nobody loves me
@@ -96,7 +96,7 @@ lstcon_rpc_init(lstcon_node_t *nd, int service, unsigned feats,
 	crpc->crp_rpc = sfw_create_rpc(nd->nd_id, service,
 				       feats, bulk_npg, bulk_len,
 				       lstcon_rpc_done, (void *)crpc);
-	if (crpc->crp_rpc == NULL)
+	if (!crpc->crp_rpc)
 		return -ENOMEM;
 
 	crpc->crp_trans    = NULL;
@@ -131,9 +131,9 @@ lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
 
 	spin_unlock(&console_session.ses_rpc_lock);
 
-	if (crpc == NULL) {
+	if (!crpc) {
 		LIBCFS_ALLOC(crpc, sizeof(*crpc));
-		if (crpc == NULL)
+		if (!crpc)
 			return -ENOMEM;
 	}
 
@@ -157,7 +157,7 @@ lstcon_rpc_put(lstcon_rpc_t *crpc)
 	LASSERT(list_empty(&crpc->crp_link));
 
 	for (i = 0; i < bulk->bk_niov; i++) {
-		if (bulk->bk_iovs[i].kiov_page == NULL)
+		if (!bulk->bk_iovs[i].kiov_page)
 			continue;
 
 		__free_page(bulk->bk_iovs[i].kiov_page);
@@ -188,7 +188,7 @@ lstcon_rpc_post(lstcon_rpc_t *crpc)
 {
 	lstcon_rpc_trans_t *trans = crpc->crp_trans;
 
-	LASSERT(trans != NULL);
+	LASSERT(trans);
 
 	atomic_inc(&trans->tas_remaining);
 	crpc->crp_posted = 1;
@@ -241,7 +241,7 @@ lstcon_rpc_trans_prep(struct list_head *translist,
 {
 	lstcon_rpc_trans_t *trans;
 
-	if (translist != NULL) {
+	if (translist) {
 		list_for_each_entry(trans, translist, tas_link) {
 			/*
 			 * Can't enqueue two private transaction on
@@ -254,12 +254,12 @@ lstcon_rpc_trans_prep(struct list_head *translist,
 
 	/* create a trans group */
 	LIBCFS_ALLOC(trans, sizeof(*trans));
-	if (trans == NULL)
+	if (!trans)
 		return -ENOMEM;
 
 	trans->tas_opc = transop;
 
-	if (translist == NULL)
+	if (!translist)
 		INIT_LIST_HEAD(&trans->tas_olink);
 	else
 		list_add_tail(&trans->tas_olink, translist);
@@ -393,7 +393,7 @@ lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
 	srpc_client_rpc_t *rpc = crpc->crp_rpc;
 	srpc_generic_reply_t *rep;
 
-	LASSERT(nd != NULL && rpc != NULL);
+	LASSERT(nd && rpc);
 	LASSERT(crpc->crp_stamp != 0);
 
 	if (crpc->crp_status != 0) {
@@ -430,7 +430,7 @@ lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 	srpc_msg_t *rep;
 	int error;
 
-	LASSERT(stat != NULL);
+	LASSERT(stat);
 
 	memset(stat, 0, sizeof(*stat));
 
@@ -484,7 +484,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 	struct timeval tv;
 	int error;
 
-	LASSERT(head_up != NULL);
+	LASSERT(head_up);
 
 	next = head_up;
 
@@ -530,7 +530,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 				 sizeof(rep->status)))
 			return -EFAULT;
 
-		if (readent == NULL)
+		if (!readent)
 			continue;
 
 		error = readent(trans->tas_opc, msg, ent);
@@ -866,7 +866,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 			bulk->bk_iovs[i].kiov_page   =
 				alloc_page(GFP_KERNEL);
 
-			if (bulk->bk_iovs[i].kiov_page == NULL) {
+			if (!bulk->bk_iovs[i].kiov_page) {
 				lstcon_rpc_put(*crpc);
 				return -ENOMEM;
 			}
@@ -1108,7 +1108,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 
 	feats = trans->tas_features;
 	list_for_each_entry(ndl, ndlist, ndl_link) {
-		rc = condition == NULL ? 1 :
+		rc = !condition ? 1 :
 		     condition(transop, ndl->ndl_node, arg);
 
 		if (rc == 0)
@@ -1201,7 +1201,7 @@ lstcon_rpc_pinger(void *arg)
 
 	trans = console_session.ses_ping;
 
-	LASSERT(trans != NULL);
+	LASSERT(trans);
 
 	list_for_each_entry(ndl, &console_session.ses_ndl_list, ndl_link) {
 		nd = ndl->ndl_node;
@@ -1226,7 +1226,7 @@ lstcon_rpc_pinger(void *arg)
 
 		crpc = &nd->nd_ping;
 
-		if (crpc->crp_rpc != NULL) {
+		if (crpc->crp_rpc) {
 			LASSERT(crpc->crp_trans == trans);
 			LASSERT(!list_empty(&crpc->crp_link));
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 914d842..8995417 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -90,7 +90,7 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 		return -ENOENT;
 
 	LIBCFS_ALLOC(*ndpp, sizeof(lstcon_node_t) + sizeof(lstcon_ndlink_t));
-	if (*ndpp == NULL)
+	if (!*ndpp)
 		return -ENOMEM;
 
 	ndl = (lstcon_ndlink_t *)(*ndpp + 1);
@@ -168,7 +168,7 @@ lstcon_ndlink_find(struct list_head *hash,
 		return rc;
 
 	LIBCFS_ALLOC(ndl, sizeof(lstcon_ndlink_t));
-	if (ndl == NULL) {
+	if (!ndl) {
 		lstcon_node_put(nd);
 		return -ENOMEM;
 	}
@@ -202,11 +202,11 @@ lstcon_group_alloc(char *name, lstcon_group_t **grpp)
 
 	LIBCFS_ALLOC(grp, offsetof(lstcon_group_t,
 				   grp_ndl_hash[LST_NODE_HASHSIZE]));
-	if (grp == NULL)
+	if (!grp)
 		return -ENOMEM;
 
 	grp->grp_ref = 1;
-	if (name != NULL)
+	if (name)
 		strcpy(grp->grp_name, name);
 
 	INIT_LIST_HEAD(&grp->grp_link);
@@ -348,7 +348,7 @@ lstcon_sesrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 		if (nd->nd_state != LST_NODE_ACTIVE)
 			return 0;
 
-		if (grp != NULL && nd->nd_ref > 1)
+		if (grp && nd->nd_ref > 1)
 			return 0;
 		break;
 
@@ -545,7 +545,7 @@ lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
 	int rc;
 
 	LASSERT(count > 0);
-	LASSERT(ids_up != NULL);
+	LASSERT(ids_up);
 
 	rc = lstcon_group_find(name, &grp);
 	if (rc != 0) {
@@ -721,7 +721,7 @@ lstcon_group_list(int index, int len, char __user *name_up)
 	lstcon_group_t *grp;
 
 	LASSERT(index >= 0);
-	LASSERT(name_up != NULL);
+	LASSERT(name_up);
 
 	list_for_each_entry(grp, &console_session.ses_grp_list, grp_link) {
 		if (index-- == 0) {
@@ -742,8 +742,8 @@ lstcon_nodes_getent(struct list_head *head, int *index_p,
 	int count = 0;
 	int index = 0;
 
-	LASSERT(index_p != NULL && count_p != NULL);
-	LASSERT(dents_up != NULL);
+	LASSERT(index_p && count_p);
+	LASSERT(dents_up);
 	LASSERT(*index_p >= 0);
 	LASSERT(*count_p > 0);
 
@@ -800,7 +800,7 @@ lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 
 	/* non-verbose query */
 	LIBCFS_ALLOC(gentp, sizeof(lstcon_ndlist_ent_t));
-	if (gentp == NULL) {
+	if (!gentp) {
 		CERROR("Can't allocate ndlist_ent\n");
 		lstcon_group_decref(grp);
 
@@ -849,14 +849,14 @@ lstcon_batch_add(char *name)
 	}
 
 	LIBCFS_ALLOC(bat, sizeof(lstcon_batch_t));
-	if (bat == NULL) {
+	if (!bat) {
 		CERROR("Can't allocate descriptor for batch %s\n", name);
 		return -ENOMEM;
 	}
 
 	LIBCFS_ALLOC(bat->bat_cli_hash,
 		     sizeof(struct list_head) * LST_NODE_HASHSIZE);
-	if (bat->bat_cli_hash == NULL) {
+	if (!bat->bat_cli_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
 		LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
 
@@ -865,7 +865,7 @@ lstcon_batch_add(char *name)
 
 	LIBCFS_ALLOC(bat->bat_srv_hash,
 		     sizeof(struct list_head) * LST_NODE_HASHSIZE);
-	if (bat->bat_srv_hash == NULL) {
+	if (!bat->bat_srv_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
 		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
 		LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
@@ -900,7 +900,7 @@ lstcon_batch_list(int index, int len, char __user *name_up)
 {
 	lstcon_batch_t *bat;
 
-	LASSERT(name_up != NULL);
+	LASSERT(name_up);
 	LASSERT(index >= 0);
 
 	list_for_each_entry(bat, &console_session.ses_bat_list, bat_link) {
@@ -945,12 +945,12 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		}
 	}
 
-	clilst = (test == NULL) ? &bat->bat_cli_list :
-				  &test->tes_src_grp->grp_ndl_list;
-	srvlst = (test == NULL) ? &bat->bat_srv_list :
-				  &test->tes_dst_grp->grp_ndl_list;
+	clilst = !test ? &bat->bat_cli_list :
+			 &test->tes_src_grp->grp_ndl_list;
+	srvlst = !test ? &bat->bat_srv_list :
+			 &test->tes_dst_grp->grp_ndl_list;
 
-	if (dents_up != NULL) {
+	if (dents_up) {
 		rc = lstcon_nodes_getent((server ? srvlst : clilst),
 					 index_p, ndent_p, dents_up);
 		return rc;
@@ -958,10 +958,10 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 
 	/* non-verbose query */
 	LIBCFS_ALLOC(entp, sizeof(lstcon_test_batch_ent_t));
-	if (entp == NULL)
+	if (!entp)
 		return -ENOMEM;
 
-	if (test == NULL) {
+	if (!test) {
 		entp->u.tbe_batch.bae_ntest = bat->bat_ntest;
 		entp->u.tbe_batch.bae_state = bat->bat_state;
 
@@ -1138,10 +1138,10 @@ lstcon_testrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 	struct list_head *head;
 
 	test = (lstcon_test_t *)arg;
-	LASSERT(test != NULL);
+	LASSERT(test);
 
 	batch = test->tes_batch;
-	LASSERT(batch != NULL);
+	LASSERT(batch);
 
 	if (test->tes_oneside &&
 	    transop == LST_TRANS_TSBSRVADD)
@@ -1180,8 +1180,8 @@ lstcon_test_nodes_add(lstcon_test_t *test, struct list_head __user *result_up)
 	int transop;
 	int rc;
 
-	LASSERT(test->tes_src_grp != NULL);
-	LASSERT(test->tes_dst_grp != NULL);
+	LASSERT(test->tes_src_grp);
+	LASSERT(test->tes_dst_grp);
 
 	transop = LST_TRANS_TSBSRVADD;
 	grp  = test->tes_dst_grp;
@@ -1319,7 +1319,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	test->tes_dst_grp	= dst_grp;
 	INIT_LIST_HEAD(&test->tes_trans_list);
 
-	if (param != NULL) {
+	if (param) {
 		test->tes_paramlen = paramlen;
 		memcpy(&test->tes_param[0], param, paramlen);
 	}
@@ -1343,13 +1343,13 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	/*  hold groups so nobody can change them */
 	return rc;
 out:
-	if (test != NULL)
+	if (test)
 		LIBCFS_FREE(test, offsetof(lstcon_test_t, tes_param[paramlen]));
 
-	if (dst_grp != NULL)
+	if (dst_grp)
 		lstcon_group_decref(dst_grp);
 
-	if (src_grp != NULL)
+	if (src_grp)
 		lstcon_group_decref(src_grp);
 
 	return rc;
@@ -1777,7 +1777,7 @@ lstcon_session_info(lst_sid_t __user *sid_up, int __user *key_up,
 		return -ESRCH;
 
 	LIBCFS_ALLOC(entp, sizeof(*entp));
-	if (entp == NULL)
+	if (!entp)
 		return -ENOMEM;
 
 	list_for_each_entry(ndl, &console_session.ses_ndl_list, ndl_link)
@@ -1967,7 +1967,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 
 out:
 	rep->msg_ses_feats = console_session.ses_features;
-	if (grp != NULL)
+	if (grp)
 		lstcon_group_decref(grp);
 
 	mutex_unlock(&console_session.ses_mutex);
@@ -2016,7 +2016,7 @@ lstcon_console_init(void)
 
 	LIBCFS_ALLOC(console_session.ses_ndl_hash,
 		     sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
-	if (console_session.ses_ndl_hash == NULL)
+	if (!console_session.ses_ndl_hash)
 		return -ENOMEM;
 
 	for (i = 0; i < LST_GLOBAL_HASHSIZE; i++)
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index c61d3e7..e8221a7 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -139,14 +139,14 @@ sfw_register_test(srpc_service_t *service, sfw_test_client_ops_t *cliops)
 {
 	sfw_test_case_t *tsc;
 
-	if (sfw_find_test_case(service->sv_id) != NULL) {
+	if (sfw_find_test_case(service->sv_id)) {
 		CERROR("Failed to register test %s (%d)\n",
 		       service->sv_name, service->sv_id);
 		return -EEXIST;
 	}
 
 	LIBCFS_ALLOC(tsc, sizeof(sfw_test_case_t));
-	if (tsc == NULL)
+	if (!tsc)
 		return -ENOMEM;
 
 	tsc->tsc_cli_ops     = cliops;
@@ -164,7 +164,7 @@ sfw_add_session_timer(void)
 
 	LASSERT(!sfw_data.fw_shuttingdown);
 
-	if (sn == NULL || sn->sn_timeout == 0)
+	if (!sn || sn->sn_timeout == 0)
 		return;
 
 	LASSERT(!sn->sn_timer_active);
@@ -180,7 +180,7 @@ sfw_del_session_timer(void)
 {
 	sfw_session_t *sn = sfw_data.fw_session;
 
-	if (sn == NULL || !sn->sn_timer_active)
+	if (!sn || !sn->sn_timer_active)
 		return 0;
 
 	LASSERT(sn->sn_timeout != 0);
@@ -202,7 +202,7 @@ sfw_deactivate_session(void)
 	sfw_batch_t *tsb;
 	sfw_test_case_t *tsc;
 
-	if (sn == NULL)
+	if (!sn)
 		return;
 
 	LASSERT(!sn->sn_timer_active);
@@ -294,7 +294,7 @@ sfw_server_rpc_done(struct srpc_server_rpc *rpc)
 	       swi_state2str(rpc->srpc_wi.swi_state),
 	       status);
 
-	if (rpc->srpc_bulk != NULL)
+	if (rpc->srpc_bulk)
 		sfw_free_pages(rpc);
 	return;
 }
@@ -326,7 +326,7 @@ sfw_find_batch(lst_bid_t bid)
 	sfw_session_t *sn = sfw_data.fw_session;
 	sfw_batch_t *bat;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 
 	list_for_each_entry(bat, &sn->sn_batches, bat_list) {
 		if (bat->bat_id.bat_id == bid.bat_id)
@@ -342,14 +342,14 @@ sfw_bid2batch(lst_bid_t bid)
 	sfw_session_t *sn = sfw_data.fw_session;
 	sfw_batch_t *bat;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 
 	bat = sfw_find_batch(bid);
-	if (bat != NULL)
+	if (bat)
 		return bat;
 
 	LIBCFS_ALLOC(bat, sizeof(sfw_batch_t));
-	if (bat == NULL)
+	if (!bat)
 		return NULL;
 
 	bat->bat_error    = 0;
@@ -369,14 +369,14 @@ sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 	sfw_counters_t *cnt = &reply->str_fw;
 	sfw_batch_t *bat;
 
-	reply->str_sid = (sn == NULL) ? LST_INVALID_SID : sn->sn_id;
+	reply->str_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
 	if (request->str_sid.ses_nid == LNET_NID_ANY) {
 		reply->str_status = EINVAL;
 		return 0;
 	}
 
-	if (sn == NULL || !sfw_sid_equal(request->str_sid, sn->sn_id)) {
+	if (!sn || !sfw_sid_equal(request->str_sid, sn->sn_id)) {
 		reply->str_status = ESRCH;
 		return 0;
 	}
@@ -412,12 +412,12 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	int cplen = 0;
 
 	if (request->mksn_sid.ses_nid == LNET_NID_ANY) {
-		reply->mksn_sid = (sn == NULL) ? LST_INVALID_SID : sn->sn_id;
+		reply->mksn_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 		reply->mksn_status = EINVAL;
 		return 0;
 	}
 
-	if (sn != NULL) {
+	if (sn) {
 		reply->mksn_status  = 0;
 		reply->mksn_sid     = sn->sn_id;
 		reply->mksn_timeout = sn->sn_timeout;
@@ -452,7 +452,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 
 	/* brand new or create by force */
 	LIBCFS_ALLOC(sn, sizeof(sfw_session_t));
-	if (sn == NULL) {
+	if (!sn) {
 		CERROR("Dropping RPC (mksn) under memory pressure.\n");
 		return -ENOMEM;
 	}
@@ -463,7 +463,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	spin_lock(&sfw_data.fw_lock);
 
 	sfw_deactivate_session();
-	LASSERT(sfw_data.fw_session == NULL);
+	LASSERT(!sfw_data.fw_session);
 	sfw_data.fw_session = sn;
 
 	spin_unlock(&sfw_data.fw_lock);
@@ -479,15 +479,15 @@ sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
 {
 	sfw_session_t *sn = sfw_data.fw_session;
 
-	reply->rmsn_sid = (sn == NULL) ? LST_INVALID_SID : sn->sn_id;
+	reply->rmsn_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
 	if (request->rmsn_sid.ses_nid == LNET_NID_ANY) {
 		reply->rmsn_status = EINVAL;
 		return 0;
 	}
 
-	if (sn == NULL || !sfw_sid_equal(request->rmsn_sid, sn->sn_id)) {
-		reply->rmsn_status = (sn == NULL) ? ESRCH : EBUSY;
+	if (!sn || !sfw_sid_equal(request->rmsn_sid, sn->sn_id)) {
+		reply->rmsn_status = !sn ? ESRCH : EBUSY;
 		return 0;
 	}
 
@@ -502,7 +502,7 @@ sfw_remove_session(srpc_rmsn_reqst_t *request, srpc_rmsn_reply_t *reply)
 
 	reply->rmsn_status = 0;
 	reply->rmsn_sid    = LST_INVALID_SID;
-	LASSERT(sfw_data.fw_session == NULL);
+	LASSERT(!sfw_data.fw_session);
 	return 0;
 }
 
@@ -511,7 +511,7 @@ sfw_debug_session(srpc_debug_reqst_t *request, srpc_debug_reply_t *reply)
 {
 	sfw_session_t *sn = sfw_data.fw_session;
 
-	if (sn == NULL) {
+	if (!sn) {
 		reply->dbg_status = ESRCH;
 		reply->dbg_sid    = LST_INVALID_SID;
 		return 0;
@@ -557,10 +557,10 @@ sfw_load_test(struct sfw_test_instance *tsi)
 	int nbuf;
 	int rc;
 
-	LASSERT(tsi != NULL);
+	LASSERT(tsi);
 	tsc = sfw_find_test_case(tsi->tsi_service);
 	nbuf = sfw_test_buffers(tsi);
-	LASSERT(tsc != NULL);
+	LASSERT(tsc);
 	svc = tsc->tsc_srv_service;
 
 	if (tsi->tsi_is_client) {
@@ -593,7 +593,7 @@ sfw_unload_test(struct sfw_test_instance *tsi)
 {
 	struct sfw_test_case *tsc = sfw_find_test_case(tsi->tsi_service);
 
-	LASSERT(tsc != NULL);
+	LASSERT(tsc);
 
 	if (tsi->tsi_is_client)
 		return;
@@ -740,7 +740,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 	int rc;
 
 	LIBCFS_ALLOC(tsi, sizeof(*tsi));
-	if (tsi == NULL) {
+	if (!tsi) {
 		CERROR("Can't allocate test instance for batch: %llu\n",
 		       tsb->bat_id.bat_id);
 		return -ENOMEM;
@@ -774,7 +774,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 		return 0;
 	}
 
-	LASSERT(bk != NULL);
+	LASSERT(bk);
 	LASSERT(bk->bk_niov * SFW_ID_PER_PAGE >= (unsigned int)ndest);
 	LASSERT((unsigned int)bk->bk_len >=
 		sizeof(lnet_process_id_packed_t) * ndest);
@@ -788,14 +788,14 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 		int j;
 
 		dests = page_address(bk->bk_iovs[i / SFW_ID_PER_PAGE].kiov_page);
-		LASSERT(dests != NULL);  /* my pages are within KVM always */
+		LASSERT(dests);  /* my pages are within KVM always */
 		id = dests[i % SFW_ID_PER_PAGE];
 		if (msg->msg_magic != SRPC_MSG_MAGIC)
 			sfw_unpack_id(id);
 
 		for (j = 0; j < tsi->tsi_concur; j++) {
 			LIBCFS_ALLOC(tsu, sizeof(sfw_test_unit_t));
-			if (tsu == NULL) {
+			if (!tsu) {
 				rc = -ENOMEM;
 				CERROR("Can't allocate tsu for %d\n",
 				       tsi->tsi_service);
@@ -923,7 +923,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 
 	spin_unlock(&tsi->tsi_lock);
 
-	if (rpc == NULL) {
+	if (!rpc) {
 		rpc = srpc_create_client_rpc(peer, tsi->tsi_service, nblk,
 					     blklen, sfw_test_rpc_done,
 					     sfw_test_rpc_fini, tsu);
@@ -933,7 +933,7 @@ sfw_create_test_rpc(sfw_test_unit_t *tsu, lnet_process_id_t peer,
 				     sfw_test_rpc_fini, tsu);
 	}
 
-	if (rpc == NULL) {
+	if (!rpc) {
 		CERROR("Can't create rpc for test %d\n", tsi->tsi_service);
 		return -ENOMEM;
 	}
@@ -954,11 +954,11 @@ sfw_run_test(swi_workitem_t *wi)
 	LASSERT(wi == &tsu->tsu_worker);
 
 	if (tsi->tsi_ops->tso_prep_rpc(tsu, tsu->tsu_dest, &rpc) != 0) {
-		LASSERT(rpc == NULL);
+		LASSERT(!rpc);
 		goto test_done;
 	}
 
-	LASSERT(rpc != NULL);
+	LASSERT(rpc);
 
 	spin_lock(&tsi->tsi_lock);
 
@@ -1107,11 +1107,11 @@ int
 sfw_alloc_pages(struct srpc_server_rpc *rpc, int cpt, int npages, int len,
 		int sink)
 {
-	LASSERT(rpc->srpc_bulk == NULL);
+	LASSERT(!rpc->srpc_bulk);
 	LASSERT(npages > 0 && npages <= LNET_MAX_IOV);
 
 	rpc->srpc_bulk = srpc_alloc_bulk(cpt, npages, len, sink);
-	if (rpc->srpc_bulk == NULL)
+	if (!rpc->srpc_bulk)
 		return -ENOMEM;
 
 	return 0;
@@ -1127,7 +1127,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 	sfw_batch_t *bat;
 
 	request = &rpc->srpc_reqstbuf->buf_msg.msg_body.tes_reqst;
-	reply->tsr_sid = (sn == NULL) ? LST_INVALID_SID : sn->sn_id;
+	reply->tsr_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
 	if (request->tsr_loop == 0 ||
 	    request->tsr_concur == 0 ||
@@ -1141,14 +1141,14 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 		return 0;
 	}
 
-	if (sn == NULL || !sfw_sid_equal(request->tsr_sid, sn->sn_id) ||
-	    sfw_find_test_case(request->tsr_service) == NULL) {
+	if (!sn || !sfw_sid_equal(request->tsr_sid, sn->sn_id) ||
+	    !sfw_find_test_case(request->tsr_service)) {
 		reply->tsr_status = ENOENT;
 		return 0;
 	}
 
 	bat = sfw_bid2batch(request->tsr_bid);
-	if (bat == NULL) {
+	if (!bat) {
 		CERROR("Dropping RPC (%s) from %s under memory pressure.\n",
 		       rpc->srpc_scd->scd_svc->sv_name,
 		       libcfs_id2str(rpc->srpc_peer));
@@ -1160,7 +1160,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 		return 0;
 	}
 
-	if (request->tsr_is_client && rpc->srpc_bulk == NULL) {
+	if (request->tsr_is_client && !rpc->srpc_bulk) {
 		/* rpc will be resumed later in sfw_bulk_ready */
 		int npg = sfw_id_pages(request->tsr_ndest);
 		int len;
@@ -1194,15 +1194,15 @@ sfw_control_batch(srpc_batch_reqst_t *request, srpc_batch_reply_t *reply)
 	int rc = 0;
 	sfw_batch_t *bat;
 
-	reply->bar_sid = (sn == NULL) ? LST_INVALID_SID : sn->sn_id;
+	reply->bar_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
-	if (sn == NULL || !sfw_sid_equal(request->bar_sid, sn->sn_id)) {
+	if (!sn || !sfw_sid_equal(request->bar_sid, sn->sn_id)) {
 		reply->bar_status = ESRCH;
 		return 0;
 	}
 
 	bat = sfw_find_batch(request->bar_bid);
-	if (bat == NULL) {
+	if (!bat) {
 		reply->bar_status = ENOENT;
 		return 0;
 	}
@@ -1237,7 +1237,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 	unsigned features = LST_FEATS_MASK;
 	int rc = 0;
 
-	LASSERT(sfw_data.fw_active_srpc == NULL);
+	LASSERT(!sfw_data.fw_active_srpc);
 	LASSERT(sv->sv_id <= SRPC_FRAMEWORK_SERVICE_MAX_ID);
 
 	spin_lock(&sfw_data.fw_lock);
@@ -1268,7 +1268,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 	    sv->sv_id != SRPC_SERVICE_DEBUG) {
 		sfw_session_t *sn = sfw_data.fw_session;
 
-		if (sn != NULL &&
+		if (sn &&
 		    sn->sn_features != request->msg_ses_feats) {
 			CNETERR("Features of framework RPC don't match features of current session: %x/%x\n",
 				request->msg_ses_feats, sn->sn_features);
@@ -1320,7 +1320,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 		break;
 	}
 
-	if (sfw_data.fw_session != NULL)
+	if (sfw_data.fw_session)
 		features = sfw_data.fw_session->sn_features;
  out:
 	reply->msg_ses_feats = features;
@@ -1341,9 +1341,9 @@ sfw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
 	int rc;
 
-	LASSERT(rpc->srpc_bulk != NULL);
+	LASSERT(rpc->srpc_bulk);
 	LASSERT(sv->sv_id == SRPC_SERVICE_TEST);
-	LASSERT(sfw_data.fw_active_srpc == NULL);
+	LASSERT(!sfw_data.fw_active_srpc);
 	LASSERT(rpc->srpc_reqstbuf->buf_msg.msg_body.tes_reqst.tsr_is_client);
 
 	spin_lock(&sfw_data.fw_lock);
@@ -1405,7 +1405,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 
 	spin_unlock(&sfw_data.fw_lock);
 
-	if (rpc == NULL) {
+	if (!rpc) {
 		rpc = srpc_create_client_rpc(peer, service,
 					     nbulkiov, bulklen, done,
 					     nbulkiov != 0 ?  NULL :
@@ -1413,7 +1413,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 					     priv);
 	}
 
-	if (rpc != NULL) /* "session" is concept in framework */
+	if (rpc) /* "session" is concept in framework */
 		rpc->crpc_reqstmsg.msg_ses_feats = features;
 
 	return rpc;
@@ -1702,7 +1702,7 @@ sfw_startup(void)
 
 	for (i = 0; ; i++) {
 		sv = &sfw_services[i];
-		if (sv->sv_name == NULL)
+		if (!sv->sv_name)
 			break;
 
 		sv->sv_bulk_ready = NULL;
@@ -1746,11 +1746,11 @@ sfw_shutdown(void)
 	spin_lock(&sfw_data.fw_lock);
 
 	sfw_data.fw_shuttingdown = 1;
-	lst_wait_until(sfw_data.fw_active_srpc == NULL, sfw_data.fw_lock,
+	lst_wait_until(!sfw_data.fw_active_srpc, sfw_data.fw_lock,
 		       "waiting for active RPC to finish.\n");
 
 	if (sfw_del_session_timer() != 0)
-		lst_wait_until(sfw_data.fw_session == NULL, sfw_data.fw_lock,
+		lst_wait_until(!sfw_data.fw_session, sfw_data.fw_lock,
 			       "waiting for session timer to explode.\n");
 
 	sfw_deactivate_session();
@@ -1763,7 +1763,7 @@ sfw_shutdown(void)
 
 	for (i = 0; ; i++) {
 		sv = &sfw_services[i];
-		if (sv->sv_name == NULL)
+		if (!sv->sv_name)
 			break;
 
 		srpc_shutdown_service(sv);
@@ -1788,7 +1788,7 @@ sfw_shutdown(void)
 
 	for (i = 0; ; i++) {
 		sv = &sfw_services[i];
-		if (sv->sv_name == NULL)
+		if (!sv->sv_name)
 			break;
 
 		srpc_wait_service_shutdown(sv);
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 46cbdf0..741509a 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -70,7 +70,7 @@ lnet_selftest_fini(void)
 	case LST_INIT_WI_TEST:
 		for (i = 0;
 		     i < cfs_cpt_number(lnet_cpt_table()); i++) {
-			if (lst_sched_test[i] == NULL)
+			if (!lst_sched_test[i])
 				continue;
 			cfs_wi_sched_destroy(lst_sched_test[i]);
 		}
@@ -106,7 +106,7 @@ lnet_selftest_init(void)
 
 	nscheds = cfs_cpt_number(lnet_cpt_table());
 	LIBCFS_ALLOC(lst_sched_test, sizeof(lst_sched_test[0]) * nscheds);
-	if (lst_sched_test == NULL)
+	if (!lst_sched_test)
 		goto error;
 
 	lst_init_step = LST_INIT_WI_TEST;
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 1d23a30..01ceee5 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -61,7 +61,7 @@ ping_client_init(sfw_test_instance_t *tsi)
 	sfw_session_t *sn = tsi->tsi_batch->bat_session;
 
 	LASSERT(tsi->tsi_is_client);
-	LASSERT(sn != NULL && (sn->sn_features & ~LST_FEATS_MASK) == 0);
+	LASSERT(sn && (sn->sn_features & ~LST_FEATS_MASK) == 0);
 
 	spin_lock_init(&lst_ping_data.pnd_lock);
 	lst_ping_data.pnd_counter = 0;
@@ -75,7 +75,7 @@ ping_client_fini(sfw_test_instance_t *tsi)
 	sfw_session_t *sn = tsi->tsi_batch->bat_session;
 	int errors;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 	LASSERT(tsi->tsi_is_client);
 
 	errors = atomic_read(&sn->sn_ping_errors);
@@ -95,7 +95,7 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu,
 	struct timespec64 ts;
 	int rc;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 	LASSERT((sn->sn_features & ~LST_FEATS_MASK) == 0);
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, 0, 0, rpc);
@@ -126,7 +126,7 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	srpc_ping_reply_t *reply = &rpc->crpc_replymsg.msg_body.ping_reply;
 	struct timespec64 ts;
 
-	LASSERT(sn != NULL);
+	LASSERT(sn);
 
 	if (rpc->crpc_status != 0) {
 		if (!tsi->tsi_stopping) /* rpc could have been aborted */
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 6b10216..1e78711 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -107,11 +107,11 @@ srpc_free_bulk(srpc_bulk_t *bk)
 	int i;
 	struct page *pg;
 
-	LASSERT(bk != NULL);
+	LASSERT(bk);
 
 	for (i = 0; i < bk->bk_niov; i++) {
 		pg = bk->bk_iovs[i].kiov_page;
-		if (pg == NULL)
+		if (!pg)
 			break;
 
 		__free_page(pg);
@@ -131,7 +131,7 @@ srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len, int sink)
 
 	LIBCFS_CPT_ALLOC(bk, lnet_cpt_table(), cpt,
 			 offsetof(srpc_bulk_t, bk_iovs[bulk_npg]));
-	if (bk == NULL) {
+	if (!bk) {
 		CERROR("Can't allocate descriptor for %d pages\n", bulk_npg);
 		return NULL;
 	}
@@ -147,7 +147,7 @@ srpc_alloc_bulk(int cpt, unsigned bulk_npg, unsigned bulk_len, int sink)
 
 		pg = alloc_pages_node(cfs_cpt_spread_node(lnet_cpt_table(), cpt),
 				      GFP_KERNEL, 0);
-		if (pg == NULL) {
+		if (!pg) {
 			CERROR("Can't allocate page %d of %d\n", i, bulk_npg);
 			srpc_free_bulk(bk);
 			return NULL;
@@ -199,7 +199,7 @@ srpc_service_fini(struct srpc_service *svc)
 	struct list_head *q;
 	int i;
 
-	if (svc->sv_cpt_data == NULL)
+	if (!svc->sv_cpt_data)
 		return;
 
 	cfs_percpt_for_each(scd, i, svc->sv_cpt_data) {
@@ -258,7 +258,7 @@ srpc_service_init(struct srpc_service *svc)
 
 	svc->sv_cpt_data = cfs_percpt_alloc(lnet_cpt_table(),
 					    sizeof(struct srpc_service_cd));
-	if (svc->sv_cpt_data == NULL)
+	if (!svc->sv_cpt_data)
 		return -ENOMEM;
 
 	svc->sv_ncpts = srpc_serv_is_framework(svc) ?
@@ -297,7 +297,7 @@ srpc_service_init(struct srpc_service *svc)
 		for (j = 0; j < nrpcs; j++) {
 			LIBCFS_CPT_ALLOC(rpc, lnet_cpt_table(),
 					 i, sizeof(*rpc));
-			if (rpc == NULL) {
+			if (!rpc) {
 				srpc_service_fini(svc);
 				return -ENOMEM;
 			}
@@ -322,7 +322,7 @@ srpc_add_service(struct srpc_service *sv)
 
 	LASSERT(srpc_data.rpc_state == SRPC_STATE_RUNNING);
 
-	if (srpc_data.rpc_services[id] != NULL) {
+	if (srpc_data.rpc_services[id]) {
 		spin_unlock(&srpc_data.rpc_glock);
 		goto failed;
 	}
@@ -536,7 +536,7 @@ srpc_add_buffer(struct swi_workitem *wi)
 		spin_unlock(&scd->scd_lock);
 
 		LIBCFS_ALLOC(buf, sizeof(*buf));
-		if (buf == NULL) {
+		if (!buf) {
 			CERROR("Failed to add new buf to service: %s\n",
 			       scd->scd_svc->sv_name);
 			spin_lock(&scd->scd_lock);
@@ -880,7 +880,7 @@ srpc_do_bulk(struct srpc_server_rpc *rpc)
 	int rc;
 	int opt;
 
-	LASSERT(bk != NULL);
+	LASSERT(bk);
 
 	opt = bk->bk_sink ? LNET_MD_OP_GET : LNET_MD_OP_PUT;
 	opt |= LNET_MD_KIOV;
@@ -921,13 +921,13 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 		spin_unlock(&srpc_data.rpc_glock);
 	}
 
-	if (rpc->srpc_done != NULL)
+	if (rpc->srpc_done)
 		(*rpc->srpc_done) (rpc);
-	LASSERT(rpc->srpc_bulk == NULL);
+	LASSERT(!rpc->srpc_bulk);
 
 	spin_lock(&scd->scd_lock);
 
-	if (rpc->srpc_reqstbuf != NULL) {
+	if (rpc->srpc_reqstbuf) {
 		/*
 		 * NB might drop sv_lock in srpc_service_recycle_buffer, but
 		 * sv won't go away for scd_rpc_active must not be empty
@@ -980,7 +980,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 	if (sv->sv_shuttingdown || rpc->srpc_aborted) {
 		spin_unlock(&scd->scd_lock);
 
-		if (rpc->srpc_bulk != NULL)
+		if (rpc->srpc_bulk)
 			LNetMDUnlink(rpc->srpc_bulk->bk_mdh);
 		LNetMDUnlink(rpc->srpc_replymdh);
 
@@ -1028,7 +1028,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 
 		wi->swi_state = SWI_STATE_BULK_STARTED;
 
-		if (rpc->srpc_bulk != NULL) {
+		if (rpc->srpc_bulk) {
 			rc = srpc_do_bulk(rpc);
 			if (rc == 0)
 				return 0; /* wait for bulk */
@@ -1038,12 +1038,12 @@ srpc_handle_rpc(swi_workitem_t *wi)
 		}
 	}
 	case SWI_STATE_BULK_STARTED:
-		LASSERT(rpc->srpc_bulk == NULL || ev->ev_fired);
+		LASSERT(!rpc->srpc_bulk || ev->ev_fired);
 
-		if (rpc->srpc_bulk != NULL) {
+		if (rpc->srpc_bulk) {
 			rc = ev->ev_status;
 
-			if (sv->sv_bulk_ready != NULL)
+			if (sv->sv_bulk_ready)
 				rc = (*sv->sv_bulk_ready) (rpc, rc);
 
 			if (rc != 0) {
@@ -1186,11 +1186,11 @@ srpc_send_rpc(swi_workitem_t *wi)
 	srpc_msg_t *reply;
 	int do_bulk;
 
-	LASSERT(wi != NULL);
+	LASSERT(wi);
 
 	rpc = wi->swi_workitem.wi_data;
 
-	LASSERT(rpc != NULL);
+	LASSERT(rpc);
 	LASSERT(wi == &rpc->crpc_wi);
 
 	reply = &rpc->crpc_replymsg;
@@ -1322,7 +1322,7 @@ srpc_create_client_rpc(lnet_process_id_t peer, int service,
 
 	LIBCFS_ALLOC(rpc, offsetof(srpc_client_rpc_t,
 				   crpc_bulk.bk_iovs[nbulkiov]));
-	if (rpc == NULL)
+	if (!rpc)
 		return NULL;
 
 	srpc_init_client_rpc(rpc, peer, service, nbulkiov,
@@ -1377,7 +1377,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
 	__u64 rpyid;
 	int rc;
 
-	LASSERT(buffer != NULL);
+	LASSERT(buffer);
 	rpyid = buffer->buf_msg.msg_body.reqst.rpyid;
 
 	spin_lock(&scd->scd_lock);
@@ -1664,8 +1664,7 @@ srpc_shutdown(void)
 		for (i = 0; i <= SRPC_SERVICE_MAX_ID; i++) {
 			srpc_service_t *sv = srpc_data.rpc_services[i];
 
-			LASSERTF(sv == NULL,
-				 "service not empty: id %d, name %s\n",
+			LASSERTF(!sv, "service not empty: id %d, name %s\n",
 				 i, sv->sv_name);
 		}
 
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 906e26a..e6367ec 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -504,11 +504,11 @@ void srpc_shutdown(void);
 static inline void
 srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 {
-	LASSERT(rpc != NULL);
+	LASSERT(rpc);
 	LASSERT(!srpc_event_pending(rpc));
 	LASSERT(atomic_read(&rpc->crpc_refcount) == 0);
 
-	if (rpc->crpc_fini == NULL)
+	if (!rpc->crpc_fini)
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
 	else
 		(*rpc->crpc_fini) (rpc);
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index b98c08a..dce5137 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -75,7 +75,7 @@ stt_add_timer(stt_timer_t *timer)
 
 	LASSERT(stt_data.stt_nthreads > 0);
 	LASSERT(!stt_data.stt_shuttingdown);
-	LASSERT(timer->stt_func != NULL);
+	LASSERT(timer->stt_func);
 	LASSERT(list_empty(&timer->stt_list));
 	LASSERT(timer->stt_expires > ktime_get_real_seconds());
 
-- 
1.7.1
