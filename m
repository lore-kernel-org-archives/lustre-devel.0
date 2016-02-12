From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:09 -0500
Subject: [lustre-devel] [PATCH 11/11] staging: lustre: fix all conditional
	comparison to zero in LNet layer
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Doing if (rc != 0) or if (rc == 0) is bad form. This patch corrects
the LNet code to behavior according to kernel coding standards.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   21 +--
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  137 +++++++-------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   14 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  186 ++++++++++----------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  139 +++++++--------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  148 ++++++++--------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   42 +++---
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   54 +++---
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   36 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  113 ++++++------
 drivers/staging/lustre/lnet/lnet/config.c          |   63 ++++----
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   18 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   42 +++---
 drivers/staging/lustre/lnet/lnet/lib-me.c          |    4 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   92 +++++-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   22 ++--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   52 +++---
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   58 +++---
 drivers/staging/lustre/lnet/lnet/module.c          |    8 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   52 +++---
 drivers/staging/lustre/lnet/lnet/peer.c            |   12 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   52 +++---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   46 +++---
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   36 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c      |   12 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  102 ++++++------
 drivers/staging/lustre/lnet/selftest/console.c     |  168 +++++++++---------
 drivers/staging/lustre/lnet/selftest/framework.c   |   79 ++++-----
 drivers/staging/lustre/lnet/selftest/module.c      |   10 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c   |   10 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  130 +++++++-------
 drivers/staging/lustre/lnet/selftest/selftest.h    |   10 +-
 drivers/staging/lustre/lnet/selftest/timer.c       |    4 +-
 35 files changed, 985 insertions(+), 991 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 618126b..b0f80b4 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -72,8 +72,8 @@ static inline int lnet_is_wire_handle_none(lnet_handle_wire_t *wh)
 
 static inline int lnet_md_exhausted(lnet_libmd_t *md)
 {
-	return (md->md_threshold == 0 ||
-		((md->md_options & LNET_MD_MAX_SIZE) != 0 &&
+	return (!md->md_threshold ||
+		((md->md_options & LNET_MD_MAX_SIZE) &&
 		 md->md_offset + md->md_max_size > md->md_length));
 }
 
@@ -85,13 +85,13 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 	 *    LNetM[DE]Unlink, in the latter case md may not be exhausted).
 	 *  - auto unlink is on and md is exhausted.
 	 */
-	if (md->md_refcount != 0)
+	if (md->md_refcount)
 		return 0;
 
-	if ((md->md_flags & LNET_MD_FLAG_ZOMBIE) != 0)
+	if (md->md_flags & LNET_MD_FLAG_ZOMBIE)
 		return 1;
 
-	return ((md->md_flags & LNET_MD_FLAG_AUTO_UNLINK) != 0 &&
+	return ((md->md_flags & LNET_MD_FLAG_AUTO_UNLINK) &&
 		lnet_md_exhausted(md));
 }
 
@@ -186,12 +186,11 @@ lnet_md_alloc(lnet_md_t *umd)
 	unsigned int size;
 	unsigned int niov;
 
-	if ((umd->options & LNET_MD_KIOV) != 0) {
+	if (umd->options & LNET_MD_KIOV) {
 		niov = umd->length;
 		size = offsetof(lnet_libmd_t, md_iov.kiov[niov]);
 	} else {
-		niov = ((umd->options & LNET_MD_IOVEC) != 0) ?
-		       umd->length : 1;
+		niov = umd->options & LNET_MD_IOVEC ? umd->length : 1;
 		size = offsetof(lnet_libmd_t, md_iov.iov[niov]);
 	}
 
@@ -212,7 +211,7 @@ lnet_md_free(lnet_libmd_t *md)
 {
 	unsigned int size;
 
-	if ((md->md_options & LNET_MD_KIOV) != 0)
+	if (md->md_options & LNET_MD_KIOV)
 		size = offsetof(lnet_libmd_t, md_iov.kiov[md->md_niov]);
 	else
 		size = offsetof(lnet_libmd_t, md_iov.iov[md->md_niov]);
@@ -364,14 +363,14 @@ lnet_peer_decref_locked(lnet_peer_t *lp)
 {
 	LASSERT(lp->lp_refcount > 0);
 	lp->lp_refcount--;
-	if (lp->lp_refcount == 0)
+	if (!lp->lp_refcount)
 		lnet_destroy_peer_locked(lp);
 }
 
 static inline int
 lnet_isrouter(lnet_peer_t *lp)
 {
-	return lp->lp_rtr_refcount != 0;
+	return lp->lp_rtr_refcount ? 1 : 0;
 }
 
 static inline void
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 42f08c8..d769c35 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -359,7 +359,7 @@ struct lnet_peer_table {
  * peer aliveness is enabled only on routers for peers in a network where the
  * lnet_ni_t::ni_peertimeout has been set to a positive value
  */
-#define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing != 0 && \
+#define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing && \
 					 (lp)->lp_ni->ni_peertimeout > 0)
 
 typedef struct {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index a3d654a..2e7b5ca 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -63,7 +63,7 @@ static __u32 kiblnd_cksum(void *ptr, int nob)
 		sum = ((sum << 1) | (sum >> 31)) + *c++;
 
 	/* ensure I don't return 0 (== no checksum) */
-	return (sum == 0) ? 1 : sum;
+	return !sum ? 1 : sum;
 }
 
 static char *kiblnd_msgtype2str(int type)
@@ -257,7 +257,7 @@ int kiblnd_unpack_msg(kib_msg_t *msg, int nob)
 	 */
 	msg_cksum = flip ? __swab32(msg->ibm_cksum) : msg->ibm_cksum;
 	msg->ibm_cksum = 0;
-	if (msg_cksum != 0 &&
+	if (msg_cksum &&
 	    msg_cksum != kiblnd_cksum(msg, msg_nob)) {
 		CERROR("Bad checksum\n");
 		return -EPROTO;
@@ -354,7 +354,7 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	/* always called with a ref on ni, which prevents ni being shutdown */
-	LASSERT(net->ibn_shutdown == 0);
+	LASSERT(!net->ibn_shutdown);
 
 	/* npeers only grows with the global lock held */
 	atomic_inc(&net->ibn_npeers);
@@ -370,10 +370,10 @@ void kiblnd_destroy_peer(kib_peer_t *peer)
 	kib_net_t *net = peer->ibp_ni->ni_data;
 
 	LASSERT(net);
-	LASSERT(atomic_read(&peer->ibp_refcount) == 0);
+	LASSERT(!atomic_read(&peer->ibp_refcount));
 	LASSERT(!kiblnd_peer_active(peer));
-	LASSERT(peer->ibp_connecting == 0);
-	LASSERT(peer->ibp_accepting == 0);
+	LASSERT(!peer->ibp_connecting);
+	LASSERT(!peer->ibp_accepting);
 	LASSERT(list_empty(&peer->ibp_conns));
 	LASSERT(list_empty(&peer->ibp_tx_queue));
 
@@ -609,7 +609,7 @@ static void kiblnd_setup_mtu_locked(struct rdma_cm_id *cmid)
 
 	mtu = kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu);
 	LASSERT(mtu >= 0);
-	if (mtu != 0)
+	if (mtu)
 		cmid->route.path_rec->mtu = mtu;
 }
 
@@ -632,7 +632,7 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 	/* hash NID to CPU id in this partition... */
 	off = do_div(nid, cpumask_weight(mask));
 	for_each_cpu(i, mask) {
-		if (off-- == 0)
+		if (!off--)
 			return i % vectors;
 	}
 
@@ -748,7 +748,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 
 	rc = kiblnd_alloc_pages(&conn->ibc_rx_pages, cpt,
 				IBLND_RX_MSG_PAGES(version));
-	if (rc != 0)
+	if (rc)
 		goto failed_2;
 
 	kiblnd_map_rx_descs(conn);
@@ -767,7 +767,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	conn->ibc_cq = cq;
 
 	rc = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't request completion notificiation: %d\n", rc);
 		goto failed_2;
 	}
@@ -786,7 +786,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	conn->ibc_sched = sched;
 
 	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d\n",
 		       rc, init_qp_attr->cap.max_send_wr,
 		       init_qp_attr->cap.max_recv_wr);
@@ -803,7 +803,7 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 	for (i = 0; i < IBLND_RX_MSGS(version); i++) {
 		rc = kiblnd_post_rx(&conn->ibc_rxs[i],
 				    IBLND_POSTRX_NO_CREDIT);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't post rxmsg: %d\n", rc);
 
 			/* Make posted receives complete */
@@ -857,15 +857,15 @@ void kiblnd_destroy_conn(kib_conn_t *conn)
 	int rc;
 
 	LASSERT(!in_interrupt());
-	LASSERT(atomic_read(&conn->ibc_refcount) == 0);
+	LASSERT(!atomic_read(&conn->ibc_refcount));
 	LASSERT(list_empty(&conn->ibc_early_rxs));
 	LASSERT(list_empty(&conn->ibc_tx_noops));
 	LASSERT(list_empty(&conn->ibc_tx_queue));
 	LASSERT(list_empty(&conn->ibc_tx_queue_rsrvd));
 	LASSERT(list_empty(&conn->ibc_tx_queue_nocred));
 	LASSERT(list_empty(&conn->ibc_active_txs));
-	LASSERT(conn->ibc_noops_posted == 0);
-	LASSERT(conn->ibc_nsends_posted == 0);
+	LASSERT(!conn->ibc_noops_posted);
+	LASSERT(!conn->ibc_nsends_posted);
 
 	switch (conn->ibc_state) {
 	default:
@@ -887,7 +887,7 @@ void kiblnd_destroy_conn(kib_conn_t *conn)
 
 	if (conn->ibc_cq) {
 		rc = ib_destroy_cq(conn->ibc_cq);
-		if (rc != 0)
+		if (rc)
 			CWARN("Error destroying CQ: %d\n", rc);
 	}
 
@@ -1011,7 +1011,7 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 	if (nid == LNET_NID_ANY)
 		return 0;
 
-	return (count == 0) ? -ENOENT : 0;
+	return !count ? -ENOENT : 0;
 }
 
 int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
@@ -1087,7 +1087,7 @@ void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 
 	read_unlock_irqrestore(glock, flags);
 
-	if (last_alive != 0)
+	if (last_alive)
 		*when = last_alive;
 
 	/*
@@ -1213,7 +1213,7 @@ static void kiblnd_unmap_tx_pool(kib_tx_pool_t *tpo)
 	kib_tx_t *tx;
 	int i;
 
-	LASSERT(tpo->tpo_pool.po_allocated == 0);
+	LASSERT(!tpo->tpo_pool.po_allocated);
 
 	if (!hdev)
 		return;
@@ -1239,7 +1239,7 @@ static kib_hca_dev_t *kiblnd_current_hdev(kib_dev_t *dev)
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 	while (dev->ibd_failover) {
 		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
-		if (i++ % 50 == 0)
+		if (!(i++ % 50))
 			CDEBUG(D_NET, "%s: Wait for failover\n",
 			       dev->ibd_ifname);
 		schedule_timeout(cfs_time_seconds(1) / 100);
@@ -1275,7 +1275,7 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 	CLASSERT(IBLND_MSG_SIZE <= PAGE_SIZE);
 
 	/* No fancy arithmetic when we do the buffer calculations */
-	CLASSERT(PAGE_SIZE % IBLND_MSG_SIZE == 0);
+	CLASSERT(!(PAGE_SIZE % IBLND_MSG_SIZE));
 
 	tpo->tpo_hdev = kiblnd_current_hdev(dev);
 
@@ -1359,7 +1359,7 @@ struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd)
 
 static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *pool)
 {
-	LASSERT(pool->fpo_map_count == 0);
+	LASSERT(!pool->fpo_map_count);
 
 	if (pool->fpo_fmr_pool)
 		ib_destroy_fmr_pool(pool->fpo_fmr_pool);
@@ -1449,7 +1449,7 @@ static void kiblnd_fail_fmr_poolset(kib_fmr_poolset_t *fps,
 						 kib_fmr_pool_t, fpo_list);
 		fpo->fpo_failed = 1;
 		list_del(&fpo->fpo_list);
-		if (fpo->fpo_map_count == 0)
+		if (!fpo->fpo_map_count)
 			list_add(&fpo->fpo_list, zombies);
 		else
 			list_add(&fpo->fpo_list, &fps->fps_failed_pool_list);
@@ -1484,7 +1484,7 @@ static int kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt,
 	INIT_LIST_HEAD(&fps->fps_failed_pool_list);
 
 	rc = kiblnd_create_fmr_pool(fps, &fpo);
-	if (rc == 0)
+	if (!rc)
 		list_add_tail(&fpo->fpo_list, &fps->fps_pool_list);
 
 	return rc;
@@ -1492,7 +1492,7 @@ static int kiblnd_init_fmr_poolset(kib_fmr_poolset_t *fps, int cpt,
 
 static int kiblnd_fmr_pool_is_idle(kib_fmr_pool_t *fpo, unsigned long now)
 {
-	if (fpo->fpo_map_count != 0) /* still in use */
+	if (fpo->fpo_map_count) /* still in use */
 		return 0;
 	if (fpo->fpo_failed)
 		return 1;
@@ -1509,11 +1509,11 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 	int rc;
 
 	rc = ib_fmr_pool_unmap(fmr->fmr_pfmr);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
-	if (status != 0) {
+	if (status) {
 		rc = ib_flush_fmr_pool(fpo->fpo_fmr_pool);
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 	}
 
 	fmr->fmr_pool = NULL;
@@ -1596,7 +1596,7 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 	rc = kiblnd_create_fmr_pool(fps, &fpo);
 	spin_lock(&fps->fps_lock);
 	fps->fps_increasing = 0;
-	if (rc == 0) {
+	if (!rc) {
 		fps->fps_version++;
 		list_add_tail(&fpo->fpo_list, &fps->fps_pool_list);
 	} else {
@@ -1610,7 +1610,7 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 static void kiblnd_fini_pool(kib_pool_t *pool)
 {
 	LASSERT(list_empty(&pool->po_free_list));
-	LASSERT(pool->po_allocated == 0);
+	LASSERT(!pool->po_allocated);
 
 	CDEBUG(D_NET, "Finalize %s pool\n", pool->po_owner->ps_name);
 }
@@ -1650,7 +1650,7 @@ static void kiblnd_fail_poolset(kib_poolset_t *ps, struct list_head *zombies)
 					    kib_pool_t, po_list);
 		po->po_failed = 1;
 		list_del(&po->po_list);
-		if (po->po_allocated == 0)
+		if (!po->po_allocated)
 			list_add(&po->po_list, zombies);
 		else
 			list_add(&po->po_list, &ps->ps_failed_pool_list);
@@ -1693,7 +1693,7 @@ static int kiblnd_init_poolset(kib_poolset_t *ps, int cpt,
 	INIT_LIST_HEAD(&ps->ps_failed_pool_list);
 
 	rc = ps->ps_pool_create(ps, size, &pool);
-	if (rc == 0)
+	if (!rc)
 		list_add(&pool->po_list, &ps->ps_pool_list);
 	else
 		CERROR("Failed to create the first pool for %s\n", ps->ps_name);
@@ -1703,7 +1703,7 @@ static int kiblnd_init_poolset(kib_poolset_t *ps, int cpt,
 
 static int kiblnd_pool_is_idle(kib_pool_t *pool, unsigned long now)
 {
-	if (pool->po_allocated != 0) /* still in use */
+	if (pool->po_allocated) /* still in use */
 		return 0;
 	if (pool->po_failed)
 		return 1;
@@ -1790,7 +1790,7 @@ struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps)
 
 	spin_lock(&ps->ps_lock);
 	ps->ps_increasing = 0;
-	if (rc == 0) {
+	if (!rc) {
 		list_add_tail(&pool->po_list, &ps->ps_pool_list);
 	} else {
 		ps->ps_next_retry = cfs_time_shift(IBLND_POOL_RETRY);
@@ -1807,7 +1807,7 @@ static void kiblnd_destroy_tx_pool(kib_pool_t *pool)
 	kib_tx_pool_t *tpo = container_of(pool, kib_tx_pool_t, tpo_pool);
 	int i;
 
-	LASSERT(pool->po_allocated == 0);
+	LASSERT(!pool->po_allocated);
 
 	if (tpo->tpo_tx_pages) {
 		kiblnd_unmap_tx_pool(tpo);
@@ -1877,7 +1877,7 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 	tpo->tpo_tx_pages = NULL;
 
 	npg = (size * IBLND_MSG_SIZE + PAGE_SIZE - 1) / PAGE_SIZE;
-	if (kiblnd_alloc_pages(&tpo->tpo_tx_pages, ps->ps_cpt, npg) != 0) {
+	if (kiblnd_alloc_pages(&tpo->tpo_tx_pages, ps->ps_cpt, npg)) {
 		CERROR("Can't allocate tx pages: %d\n", npg);
 		LIBCFS_FREE(tpo, sizeof(*tpo));
 		return -ENOMEM;
@@ -1988,7 +1988,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 	int i;
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
-	if (*kiblnd_tunables.kib_map_on_demand == 0 &&
+	if (!*kiblnd_tunables.kib_map_on_demand &&
 	    net->ibn_dev->ibd_hdev->ibh_nmrs == 1) {
 		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 		goto create_tx_pool;
@@ -2029,10 +2029,10 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 		rc = kiblnd_init_fmr_poolset(net->ibn_fmr_ps[cpt], cpt, net,
 					     kiblnd_fmr_pool_size(ncpts),
 					     kiblnd_fmr_flush_trigger(ncpts));
-		if (rc == -ENOSYS && i == 0) /* no FMR */
+		if (rc == -ENOSYS && !i) /* no FMR */
 			break;
 
-		if (rc != 0) { /* a real error */
+		if (rc) { /* a real error */
 			CERROR("Can't initialize FMR pool for CPT %d: %d\n",
 			       cpt, rc);
 			goto failed;
@@ -2067,7 +2067,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 					 kiblnd_create_tx_pool,
 					 kiblnd_destroy_tx_pool,
 					 kiblnd_tx_init, NULL);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't initialize TX pool for CPT %d: %d\n",
 			       cpt, rc);
 			goto failed;
@@ -2077,7 +2077,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 	return 0;
  failed:
 	kiblnd_net_fini_pools(net);
-	LASSERT(rc != 0);
+	LASSERT(rc);
 	return rc;
 }
 
@@ -2112,7 +2112,7 @@ static void kiblnd_hdev_cleanup_mrs(kib_hca_dev_t *hdev)
 {
 	int i;
 
-	if (hdev->ibh_nmrs == 0 || !hdev->ibh_mrs)
+	if (!hdev->ibh_nmrs || !hdev->ibh_mrs)
 		return;
 
 	for (i = 0; i < hdev->ibh_nmrs; i++) {
@@ -2147,7 +2147,7 @@ static int kiblnd_hdev_setup_mrs(kib_hca_dev_t *hdev)
 	int acflags = IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
 
 	rc = kiblnd_hdev_get_attr(hdev);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	LIBCFS_ALLOC(hdev->ibh_mrs, 1 * sizeof(*hdev->ibh_mrs));
@@ -2218,7 +2218,7 @@ static int kiblnd_dev_need_failover(kib_dev_t *dev)
 	dstaddr.sin_family = AF_INET;
 	rc = rdma_resolve_addr(cmid, (struct sockaddr *)&srcaddr,
 			       (struct sockaddr *)&dstaddr, 1);
-	if (rc != 0 || !cmid->device) {
+	if (rc || !cmid->device) {
 		CERROR("Failed to bind %s:%pI4h to device(%p): %d\n",
 		       dev->ibd_ifname, &dev->ibd_ifip,
 		       cmid->device, rc);
@@ -2289,7 +2289,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 
 	/* Bind to failover device or port */
 	rc = rdma_bind_addr(cmid, (struct sockaddr *)&addr);
-	if (rc != 0 || !cmid->device) {
+	if (rc || !cmid->device) {
 		CERROR("Failed to bind %s:%pI4h to device(%p): %d\n",
 		       dev->ibd_ifname, &dev->ibd_ifip,
 		       cmid->device, rc);
@@ -2320,13 +2320,13 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 	hdev->ibh_pd = pd;
 
 	rc = rdma_listen(cmid, 0);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't start new listener: %d\n", rc);
 		goto out;
 	}
 
 	rc = kiblnd_hdev_setup_mrs(hdev);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't setup device: %d\n", rc);
 		goto out;
 	}
@@ -2357,7 +2357,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 	if (hdev)
 		kiblnd_hdev_decref(hdev);
 
-	if (rc != 0)
+	if (rc)
 		dev->ibd_failed_failover++;
 	else
 		dev->ibd_failed_failover = 0;
@@ -2367,7 +2367,7 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 
 void kiblnd_destroy_dev(kib_dev_t *dev)
 {
-	LASSERT(dev->ibd_nnets == 0);
+	LASSERT(!dev->ibd_nnets);
 	LASSERT(list_empty(&dev->ibd_nets));
 
 	list_del(&dev->ibd_fail_list);
@@ -2389,7 +2389,7 @@ static kib_dev_t *kiblnd_create_dev(char *ifname)
 	int rc;
 
 	rc = lnet_ipif_query(ifname, &up, &ip, &netmask);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't query IPoIB interface %s: %d\n",
 		       ifname, rc);
 		return NULL;
@@ -2420,7 +2420,7 @@ static kib_dev_t *kiblnd_create_dev(char *ifname)
 
 	/* initialize the device */
 	rc = kiblnd_dev_failover(dev);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't initialize device: %d\n", rc);
 		LIBCFS_FREE(dev, sizeof(*dev));
 		return NULL;
@@ -2464,7 +2464,7 @@ static void kiblnd_base_shutdown(void)
 		wake_up_all(&kiblnd_data.kib_failover_waitq);
 
 		i = 2;
-		while (atomic_read(&kiblnd_data.kib_nthreads) != 0) {
+		while (atomic_read(&kiblnd_data.kib_nthreads)) {
 			i++;
 			/* power of 2 ? */
 			CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET,
@@ -2519,7 +2519,7 @@ void kiblnd_shutdown(lnet_ni_t *ni)
 
 		/* Wait for all peer state to clean up */
 		i = 2;
-		while (atomic_read(&net->ibn_npeers) != 0) {
+		while (atomic_read(&net->ibn_npeers)) {
 			i++;
 			CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET, /* 2**n? */
 			       "%s: waiting for %d peers to disconnect\n",
@@ -2540,10 +2540,9 @@ void kiblnd_shutdown(lnet_ni_t *ni)
 		/* fall through */
 
 	case IBLND_INIT_NOTHING:
-		LASSERT(atomic_read(&net->ibn_nconns) == 0);
+		LASSERT(!atomic_read(&net->ibn_nconns));
 
-		if (net->ibn_dev &&
-		    net->ibn_dev->ibd_nnets == 0)
+		if (net->ibn_dev && !net->ibn_dev->ibd_nnets)
 			kiblnd_destroy_dev(net->ibn_dev);
 
 		break;
@@ -2624,16 +2623,16 @@ static int kiblnd_base_startup(void)
 	/*****************************************************/
 
 	rc = kiblnd_thread_start(kiblnd_connd, NULL, "kiblnd_connd");
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't spawn o2iblnd connd: %d\n", rc);
 		goto failed;
 	}
 
-	if (*kiblnd_tunables.kib_dev_failover != 0)
+	if (*kiblnd_tunables.kib_dev_failover)
 		rc = kiblnd_thread_start(kiblnd_failover_thread, NULL,
 					 "kiblnd_failover");
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't spawn o2iblnd failover thread: %d\n", rc);
 		goto failed;
 	}
@@ -2655,7 +2654,7 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 	int nthrs;
 	int i;
 
-	if (sched->ibs_nthreads == 0) {
+	if (!sched->ibs_nthreads) {
 		if (*kiblnd_tunables.kib_nscheds > 0) {
 			nthrs = sched->ibs_nthreads_max;
 		} else {
@@ -2678,7 +2677,7 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 		snprintf(name, sizeof(name), "kiblnd_sd_%02ld_%02ld",
 			 KIB_THREAD_CPT(id), KIB_THREAD_TID(id));
 		rc = kiblnd_thread_start(kiblnd_scheduler, (void *)id, name);
-		if (rc == 0)
+		if (!rc)
 			continue;
 
 		CERROR("Can't spawn thread %d for scheduler[%d]: %d\n",
@@ -2707,7 +2706,7 @@ static int kiblnd_dev_start_threads(kib_dev_t *dev, int newdev, __u32 *cpts,
 			continue;
 
 		rc = kiblnd_start_schedulers(kiblnd_data.kib_scheds[cpt]);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Failed to start scheduler threads for %s\n",
 			       dev->ibd_ifname);
 			return rc;
@@ -2725,7 +2724,7 @@ static kib_dev_t *kiblnd_dev_search(char *ifname)
 
 	colon = strchr(ifname, ':');
 	list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
-		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
+		if (!strcmp(&dev->ibd_ifname[0], ifname))
 			return dev;
 
 		if (alias)
@@ -2737,7 +2736,7 @@ static kib_dev_t *kiblnd_dev_search(char *ifname)
 		if (colon2)
 			*colon2 = 0;
 
-		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
+		if (!strcmp(&dev->ibd_ifname[0], ifname))
 			alias = dev;
 
 		if (colon)
@@ -2762,7 +2761,7 @@ int kiblnd_startup(lnet_ni_t *ni)
 
 	if (kiblnd_data.kib_init == IBLND_INIT_NOTHING) {
 		rc = kiblnd_base_startup();
-		if (rc != 0)
+		if (rc)
 			return rc;
 	}
 
@@ -2803,7 +2802,7 @@ int kiblnd_startup(lnet_ni_t *ni)
 
 	newdev = !ibdev;
 	/* hmm...create kib_dev even for alias */
-	if (!ibdev || strcmp(&ibdev->ibd_ifname[0], ifname) != 0)
+	if (!ibdev || strcmp(&ibdev->ibd_ifname[0], ifname))
 		ibdev = kiblnd_create_dev(ifname);
 
 	if (!ibdev)
@@ -2814,11 +2813,11 @@ int kiblnd_startup(lnet_ni_t *ni)
 
 	rc = kiblnd_dev_start_threads(ibdev, newdev,
 				      ni->ni_cpts, ni->ni_ncpts);
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	rc = kiblnd_net_init_pools(net, ni->ni_cpts, ni->ni_ncpts);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Failed to initialize NI pools: %d\n", rc);
 		goto failed;
 	}
@@ -2861,7 +2860,7 @@ static int __init kiblnd_module_init(void)
 			  <= IBLND_MSG_SIZE);
 
 	rc = kiblnd_tunables_init();
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	lnet_register_lnd(&the_o2iblnd);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 16c90ed..2abb574 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -148,7 +148,7 @@ kiblnd_concurrent_sends_v1(void)
 
 #define IBLND_MSG_SIZE		(4 << 10)	 /* max size of queued messages (inc hdr) */
 #define IBLND_MAX_RDMA_FRAGS	 LNET_MAX_IOV	   /* max # of fragments supported */
-#define IBLND_CFG_RDMA_FRAGS       (*kiblnd_tunables.kib_map_on_demand != 0 ? \
+#define IBLND_CFG_RDMA_FRAGS       (*kiblnd_tunables.kib_map_on_demand ? \
 				    *kiblnd_tunables.kib_map_on_demand :      \
 				     IBLND_MAX_RDMA_FRAGS)  /* max # of fragments configured by user */
 #define IBLND_RDMA_FRAGS(v)	((v) == IBLND_MSG_VERSION_1 ? \
@@ -611,7 +611,7 @@ kiblnd_dev_can_failover(kib_dev_t *dev)
 	if (!list_empty(&dev->ibd_fail_list)) /* already scheduled */
 		return 0;
 
-	if (*kiblnd_tunables.kib_dev_failover == 0) /* disabled */
+	if (!*kiblnd_tunables.kib_dev_failover) /* disabled */
 		return 0;
 
 	if (*kiblnd_tunables.kib_dev_failover > 1) /* force failover */
@@ -710,16 +710,16 @@ kiblnd_need_noop(kib_conn_t *conn)
 
 		/* No tx to piggyback NOOP onto or no credit to send a tx */
 		return (list_empty(&conn->ibc_tx_queue) ||
-			conn->ibc_credits == 0);
+			!conn->ibc_credits);
 	}
 
 	if (!list_empty(&conn->ibc_tx_noops) || /* NOOP already queued */
 	    !list_empty(&conn->ibc_tx_queue_nocred) || /* piggyback NOOP */
-	    conn->ibc_credits == 0)		    /* no credit */
+	    !conn->ibc_credits)		    /* no credit */
 		return 0;
 
 	if (conn->ibc_credits == 1 &&      /* last credit reserved for */
-	    conn->ibc_outstanding_credits == 0) /* giving back credits */
+	    !conn->ibc_outstanding_credits) /* giving back credits */
 		return 0;
 
 	/* No tx to piggyback NOOP onto or no credit to send a tx */
@@ -765,8 +765,8 @@ kiblnd_ptr2wreqid(void *ptr, int type)
 {
 	unsigned long lptr = (unsigned long)ptr;
 
-	LASSERT((lptr & IBLND_WID_MASK) == 0);
-	LASSERT((type & ~IBLND_WID_MASK) == 0);
+	LASSERT(!(lptr & IBLND_WID_MASK));
+	LASSERT(!(type & ~IBLND_WID_MASK));
 	return (__u64)(lptr | type);
 }
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 674a4ee..0608431 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -53,7 +53,7 @@ kiblnd_tx_done(lnet_ni_t *ni, kib_tx_t *tx)
 	LASSERT(net);
 	LASSERT(!in_interrupt());
 	LASSERT(!tx->tx_queued);	       /* mustn't be queued for sending */
-	LASSERT(tx->tx_sending == 0);	  /* mustn't be awaiting sent callback */
+	LASSERT(!tx->tx_sending);	  /* mustn't be awaiting sent callback */
 	LASSERT(!tx->tx_waiting);	      /* mustn't be awaiting peer response */
 	LASSERT(tx->tx_pool);
 
@@ -115,15 +115,15 @@ kiblnd_get_idle_tx(lnet_ni_t *ni, lnet_nid_t target)
 		return NULL;
 	tx = container_of(node, kib_tx_t, tx_list);
 
-	LASSERT(tx->tx_nwrq == 0);
+	LASSERT(!tx->tx_nwrq);
 	LASSERT(!tx->tx_queued);
-	LASSERT(tx->tx_sending == 0);
+	LASSERT(!tx->tx_sending);
 	LASSERT(!tx->tx_waiting);
-	LASSERT(tx->tx_status == 0);
+	LASSERT(!tx->tx_status);
 	LASSERT(!tx->tx_conn);
 	LASSERT(!tx->tx_lntmsg[0]);
 	LASSERT(!tx->tx_lntmsg[1]);
-	LASSERT(tx->tx_nfrags == 0);
+	LASSERT(!tx->tx_nfrags);
 
 	return tx;
 }
@@ -185,7 +185,7 @@ kiblnd_post_rx(kib_rx_t *rx, int credit)
 	 */
 	kiblnd_conn_addref(conn);
 	rc = ib_post_recv(conn->ibc_cmid->qp, &rx->rx_wrq, &bad_wrq);
-	if (unlikely(rc != 0)) {
+	if (unlikely(rc)) {
 		CERROR("Can't post rx for %s: %d, bad_wrq: %p\n",
 		       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc, bad_wrq);
 		rx->rx_nob = 0;
@@ -194,7 +194,7 @@ kiblnd_post_rx(kib_rx_t *rx, int credit)
 	if (conn->ibc_state < IBLND_CONN_ESTABLISHED) /* Initial post */
 		goto out;
 
-	if (unlikely(rc != 0)) {
+	if (unlikely(rc)) {
 		kiblnd_close_conn(conn, rc);
 		kiblnd_drop_rx(rx);	     /* No more posts for this rx */
 		goto out;
@@ -225,7 +225,7 @@ kiblnd_find_waiting_tx_locked(kib_conn_t *conn, int txtype, __u64 cookie)
 		kib_tx_t *tx = list_entry(tmp, kib_tx_t, tx_list);
 
 		LASSERT(!tx->tx_queued);
-		LASSERT(tx->tx_sending != 0 || tx->tx_waiting);
+		LASSERT(tx->tx_sending || tx->tx_waiting);
 
 		if (tx->tx_cookie != cookie)
 			continue;
@@ -260,7 +260,7 @@ kiblnd_handle_completion(kib_conn_t *conn, int txtype, int status, __u64 cookie)
 		return;
 	}
 
-	if (tx->tx_status == 0) {	       /* success so far */
+	if (!tx->tx_status) {	       /* success so far */
 		if (status < 0) /* failed? */
 			tx->tx_status = status;
 		else if (txtype == IBLND_MSG_GET_REQ)
@@ -269,7 +269,7 @@ kiblnd_handle_completion(kib_conn_t *conn, int txtype, int status, __u64 cookie)
 
 	tx->tx_waiting = 0;
 
-	idle = !tx->tx_queued && (tx->tx_sending == 0);
+	idle = !tx->tx_queued && !tx->tx_sending;
 	if (idle)
 		list_del(&tx->tx_list);
 
@@ -316,7 +316,7 @@ kiblnd_handle_rx(kib_rx_t *rx)
 	       msg->ibm_type, credits,
 	       libcfs_nid2str(conn->ibc_peer->ibp_nid));
 
-	if (credits != 0) {
+	if (credits) {
 		/* Have I received credits that will let me send? */
 		spin_lock(&conn->ibc_lock);
 
@@ -360,7 +360,7 @@ kiblnd_handle_rx(kib_rx_t *rx)
 			break;
 		}
 
-		if (credits != 0) /* credit already posted */
+		if (credits) /* credit already posted */
 			post_credit = IBLND_POSTRX_NO_CREDIT;
 		else	      /* a keepalive NOOP */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
@@ -487,7 +487,7 @@ kiblnd_rx_complete(kib_rx_t *rx, int status, int nob)
 	rx->rx_nob = nob;
 
 	rc = kiblnd_unpack_msg(msg, rx->rx_nob);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d unpacking rx from %s\n",
 		       rc, libcfs_nid2str(conn->ibc_peer->ibp_nid));
 		goto failed;
@@ -583,7 +583,7 @@ kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, int nob)
 
 	fps = net->ibn_fmr_ps[cpt];
 	rc = kiblnd_fmr_pool_map(fps, pages, npages, 0, &tx->fmr);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't map %d pages: %d\n", npages, rc);
 		return rc;
 	}
@@ -612,7 +612,7 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx)
 		tx->fmr.fmr_pfmr = NULL;
 	}
 
-	if (tx->tx_nfrags != 0) {
+	if (tx->tx_nfrags) {
 		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev->ibh_ibdev,
 				    tx->tx_frags, tx->tx_nfrags, tx->tx_dmadir);
 		tx->tx_nfrags = 0;
@@ -769,7 +769,7 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	LASSERT(tx->tx_nwrq > 0);
 	LASSERT(tx->tx_nwrq <= 1 + IBLND_RDMA_FRAGS(ver));
 
-	LASSERT(credit == 0 || credit == 1);
+	LASSERT(!credit || credit == 1);
 	LASSERT(conn->ibc_outstanding_credits >= 0);
 	LASSERT(conn->ibc_outstanding_credits <= IBLND_MSG_QUEUE_SIZE(ver));
 	LASSERT(conn->ibc_credits >= 0);
@@ -782,13 +782,13 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 		return -EAGAIN;
 	}
 
-	if (credit != 0 && conn->ibc_credits == 0) {   /* no credits */
+	if (credit && !conn->ibc_credits) {   /* no credits */
 		CDEBUG(D_NET, "%s: no credits\n",
 		       libcfs_nid2str(peer->ibp_nid));
 		return -EAGAIN;
 	}
 
-	if (credit != 0 && !IBLND_OOB_CAPABLE(ver) &&
+	if (credit && !IBLND_OOB_CAPABLE(ver) &&
 	    conn->ibc_credits == 1 &&   /* last credit reserved */
 	    msg->ibm_type != IBLND_MSG_NOOP) {      /* for NOOP */
 		CDEBUG(D_NET, "%s: not using last credit\n",
@@ -851,7 +851,7 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 
 	conn->ibc_last_send = jiffies;
 
-	if (rc == 0)
+	if (!rc)
 		return 0;
 
 	/*
@@ -868,7 +868,7 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	tx->tx_waiting = 0;
 	tx->tx_sending--;
 
-	done = (tx->tx_sending == 0);
+	done = !tx->tx_sending;
 	if (done)
 		list_del(&tx->tx_list);
 
@@ -955,7 +955,7 @@ kiblnd_check_sends(kib_conn_t *conn)
 			break;
 		}
 
-		if (kiblnd_post_tx_locked(conn, tx, credit) != 0)
+		if (kiblnd_post_tx_locked(conn, tx, credit))
 			break;
 	}
 
@@ -1001,7 +1001,7 @@ kiblnd_tx_complete(kib_tx_t *tx, int status)
 		tx->tx_status = -EIO;
 	}
 
-	idle = (tx->tx_sending == 0) &&	 /* This is the final callback */
+	idle = !tx->tx_sending &&	 /* This is the final callback */
 	       !tx->tx_waiting &&	       /* Not waiting for peer */
 	       !tx->tx_queued;		  /* Not re-queued (PUT_DONE) */
 	if (idle)
@@ -1067,7 +1067,7 @@ kiblnd_init_rdma(kib_conn_t *conn, kib_tx_t *tx, int type,
 	int wrknob;
 
 	LASSERT(!in_interrupt());
-	LASSERT(tx->tx_nwrq == 0);
+	LASSERT(!tx->tx_nwrq);
 	LASSERT(type == IBLND_MSG_GET_DONE ||
 		type == IBLND_MSG_PUT_DONE);
 
@@ -1210,7 +1210,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	/* allow the port to be reused */
 	rc = rdma_set_reuseaddr(cmid, 1);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Unable to set reuse on cmid: %d\n", rc);
 		return rc;
 	}
@@ -1222,7 +1222,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 				       (struct sockaddr *)srcaddr,
 				       (struct sockaddr *)dstaddr,
 				       timeout_ms);
-		if (rc == 0) {
+		if (!rc) {
 			CDEBUG(D_NET, "bound to port %hu\n", port);
 			return 0;
 		} else if (rc == -EADDRINUSE || rc == -EADDRNOTAVAIL) {
@@ -1281,7 +1281,7 @@ kiblnd_connect_peer(kib_peer_t *peer)
 				       (struct sockaddr *)&dstaddr,
 				       *kiblnd_tunables.kib_timeout * 1000);
 	}
-	if (rc != 0) {
+	if (rc) {
 		/* Can't initiate address resolution:  */
 		CERROR("Can't resolve addr for %s: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), rc);
@@ -1347,8 +1347,8 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	if (peer) {
 		if (list_empty(&peer->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
-			LASSERT(peer->ibp_connecting != 0 ||
-				peer->ibp_accepting != 0);
+			LASSERT(peer->ibp_connecting ||
+				peer->ibp_accepting);
 			if (tx)
 				list_add_tail(&tx->tx_list,
 					      &peer->ibp_tx_queue);
@@ -1370,7 +1370,7 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 
 	/* Allocate a peer ready to add to the peer table and retry */
 	rc = kiblnd_create_peer(ni, &peer, nid);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create peer %s\n", libcfs_nid2str(nid));
 		if (tx) {
 			tx->tx_status = -EHOSTUNREACH;
@@ -1386,8 +1386,8 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	if (peer2) {
 		if (list_empty(&peer2->ibp_conns)) {
 			/* found a peer, but it's still connecting... */
-			LASSERT(peer2->ibp_connecting != 0 ||
-				peer2->ibp_accepting != 0);
+			LASSERT(peer2->ibp_connecting ||
+				peer2->ibp_accepting);
 			if (tx)
 				list_add_tail(&tx->tx_list,
 					      &peer2->ibp_tx_queue);
@@ -1408,11 +1408,11 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	}
 
 	/* Brand new peer */
-	LASSERT(peer->ibp_connecting == 0);
+	LASSERT(!peer->ibp_connecting);
 	peer->ibp_connecting = 1;
 
 	/* always called with a ref on ni, which prevents ni being shutdown */
-	LASSERT(((kib_net_t *)ni->ni_data)->ibn_shutdown == 0);
+	LASSERT(!((kib_net_t *)ni->ni_data)->ibn_shutdown);
 
 	if (tx)
 		list_add_tail(&tx->tx_list, &peer->ibp_tx_queue);
@@ -1450,7 +1450,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	CDEBUG(D_NET, "sending %d bytes in %d frags to %s\n",
 	       payload_nob, payload_niov, libcfs_id2str(target));
 
-	LASSERT(payload_nob == 0 || payload_niov > 0);
+	LASSERT(!payload_nob || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
 
 	/* Thread context */
@@ -1464,7 +1464,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 		return -EIO;
 
 	case LNET_MSG_ACK:
-		LASSERT(payload_nob == 0);
+		LASSERT(!payload_nob);
 		break;
 
 	case LNET_MSG_GET:
@@ -1485,7 +1485,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 
 		ibmsg = tx->tx_msg;
 		rd = &ibmsg->ibm_u.get.ibgm_rd;
-		if ((lntmsg->msg_md->md_options & LNET_MD_KIOV) == 0)
+		if (!(lntmsg->msg_md->md_options & LNET_MD_KIOV))
 			rc = kiblnd_setup_rd_iov(ni, tx, rd,
 						 lntmsg->msg_md->md_niov,
 						 lntmsg->msg_md->md_iov.iov,
@@ -1495,7 +1495,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 						  lntmsg->msg_md->md_niov,
 						  lntmsg->msg_md->md_iov.kiov,
 						  0, lntmsg->msg_md->md_length);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't setup GET sink for %s: %d\n",
 			       libcfs_nid2str(target.nid), rc);
 			kiblnd_tx_done(ni, tx);
@@ -1544,7 +1544,7 @@ kiblnd_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 			rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
 						  payload_niov, payload_kiov,
 						  payload_offset, payload_nob);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't setup PUT src for %s: %d\n",
 			       libcfs_nid2str(target.nid), rc);
 			kiblnd_tx_done(ni, tx);
@@ -1615,7 +1615,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 		goto failed_0;
 	}
 
-	if (nob == 0)
+	if (!nob)
 		rc = 0;
 	else if (!kiov)
 		rc = kiblnd_setup_rd_iov(ni, tx, tx->tx_rd,
@@ -1624,7 +1624,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 		rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
 					  niov, kiov, offset, nob);
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't setup GET src for %s: %d\n",
 		       libcfs_nid2str(target.nid), rc);
 		goto failed_1;
@@ -1640,7 +1640,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 		goto failed_1;
 	}
 
-	if (nob == 0) {
+	if (!nob) {
 		/* No RDMA: local completion may happen now! */
 		lnet_finalize(ni, lntmsg, 0);
 	} else {
@@ -1706,7 +1706,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		kib_msg_t	*txmsg;
 		kib_rdma_desc_t *rd;
 
-		if (mlen == 0) {
+		if (!mlen) {
 			lnet_finalize(ni, lntmsg, 0);
 			kiblnd_send_completion(rx->rx_conn, IBLND_MSG_PUT_NAK, 0,
 					       rxmsg->ibm_u.putreq.ibprm_cookie);
@@ -1730,7 +1730,7 @@ kiblnd_recv(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg, int delayed,
 		else
 			rc = kiblnd_setup_rd_kiov(ni, tx, rd,
 						  niov, kiov, offset, mlen);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't setup PUT sink for %s: %d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
 			kiblnd_tx_done(ni, tx);
@@ -1808,9 +1808,9 @@ kiblnd_peer_notify(kib_peer_t *peer)
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	if (list_empty(&peer->ibp_conns) &&
-	    peer->ibp_accepting == 0 &&
-	    peer->ibp_connecting == 0 &&
-	    peer->ibp_error != 0) {
+	    !peer->ibp_accepting &&
+	    !peer->ibp_connecting &&
+	    peer->ibp_error) {
 		error = peer->ibp_error;
 		peer->ibp_error = 0;
 
@@ -1819,7 +1819,7 @@ kiblnd_peer_notify(kib_peer_t *peer)
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	if (error != 0)
+	if (error)
 		lnet_notify(peer->ibp_ni,
 			    peer->ibp_nid, 0, last_alive);
 }
@@ -1839,15 +1839,15 @@ kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 	kib_dev_t *dev;
 	unsigned long flags;
 
-	LASSERT(error != 0 || conn->ibc_state >= IBLND_CONN_ESTABLISHED);
+	LASSERT(error || conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
-	if (error != 0 && conn->ibc_comms_error == 0)
+	if (error && !conn->ibc_comms_error)
 		conn->ibc_comms_error = error;
 
 	if (conn->ibc_state != IBLND_CONN_ESTABLISHED)
 		return; /* already being handled  */
 
-	if (error == 0 &&
+	if (!error &&
 	    list_empty(&conn->ibc_tx_noops) &&
 	    list_empty(&conn->ibc_tx_queue) &&
 	    list_empty(&conn->ibc_tx_queue_rsrvd) &&
@@ -1879,7 +1879,7 @@ kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 
 	kiblnd_set_conn_state(conn, IBLND_CONN_CLOSING);
 
-	if (error != 0 &&
+	if (error &&
 	    kiblnd_dev_can_failover(dev)) {
 		list_add_tail(&dev->ibd_fail_list,
 			      &kiblnd_data.kib_failed_devs);
@@ -1943,7 +1943,7 @@ kiblnd_abort_txs(kib_conn_t *conn, struct list_head *txs)
 
 		if (txs == &conn->ibc_active_txs) {
 			LASSERT(!tx->tx_queued);
-			LASSERT(tx->tx_waiting || tx->tx_sending != 0);
+			LASSERT(tx->tx_waiting || tx->tx_sending);
 		} else {
 			LASSERT(tx->tx_queued);
 		}
@@ -1951,7 +1951,7 @@ kiblnd_abort_txs(kib_conn_t *conn, struct list_head *txs)
 		tx->tx_status = -ECONNABORTED;
 		tx->tx_waiting = 0;
 
-		if (tx->tx_sending == 0) {
+		if (!tx->tx_sending) {
 			tx->tx_queued = 0;
 			list_del(&tx->tx_list);
 			list_add(&tx->tx_list, &zombies);
@@ -1997,7 +1997,7 @@ kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 	LIST_HEAD(zombies);
 	unsigned long flags;
 
-	LASSERT(error != 0);
+	LASSERT(error);
 	LASSERT(!in_interrupt());
 
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
@@ -2010,8 +2010,8 @@ kiblnd_peer_connect_failed(kib_peer_t *peer, int active, int error)
 		peer->ibp_accepting--;
 	}
 
-	if (peer->ibp_connecting != 0 ||
-	    peer->ibp_accepting != 0) {
+	if (peer->ibp_connecting ||
+	    peer->ibp_accepting) {
 		/* another connection attempt under way... */
 		write_unlock_irqrestore(&kiblnd_data.kib_global_lock,
 					flags);
@@ -2070,7 +2070,7 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 	LIBCFS_FREE(conn->ibc_connvars, sizeof(*conn->ibc_connvars));
 	conn->ibc_connvars = NULL;
 
-	if (status != 0) {
+	if (status) {
 		/* failed to establish connection */
 		kiblnd_peer_connect_failed(peer, active, status);
 		kiblnd_finalise_conn(conn);
@@ -2095,7 +2095,7 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 	else
 		peer->ibp_accepting--;
 
-	if (peer->ibp_version == 0) {
+	if (!peer->ibp_version) {
 		peer->ibp_version     = conn->ibc_version;
 		peer->ibp_incarnation = conn->ibc_incarnation;
 	}
@@ -2113,7 +2113,7 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 	list_del_init(&peer->ibp_tx_queue);
 
 	if (!kiblnd_peer_active(peer) ||	/* peer has been deleted */
-	    conn->ibc_comms_error != 0) {       /* error has happened already */
+	    conn->ibc_comms_error) {       /* error has happened already */
 		lnet_ni_t *ni = peer->ibp_ni;
 
 		/* start to shut down connection */
@@ -2149,7 +2149,7 @@ kiblnd_reject(struct rdma_cm_id *cmid, kib_rej_t *rej)
 
 	rc = rdma_reject(cmid, rej, sizeof(*rej));
 
-	if (rc != 0)
+	if (rc)
 		CWARN("Error %d sending reject\n", rc);
 }
 
@@ -2220,7 +2220,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 
 	rc = kiblnd_unpack_msg(reqmsg, priv_nob);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't parse connection request: %d\n", rc);
 		goto failed;
 	}
@@ -2247,7 +2247,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	}
 
        /* check time stamp as soon as possible */
-	if (reqmsg->ibm_dststamp != 0 &&
+	if (reqmsg->ibm_dststamp &&
 	    reqmsg->ibm_dststamp != net->ibn_incarnation) {
 		CWARN("Stale connection request\n");
 		rej.ibr_why = IBLND_REJECT_CONN_STALE;
@@ -2298,7 +2298,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
 	/* assume 'nid' is a new peer; create  */
 	rc = kiblnd_create_peer(ni, &peer, nid);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create peer for %s\n", libcfs_nid2str(nid));
 		rej.ibr_why = IBLND_REJECT_NO_RESOURCES;
 		goto failed;
@@ -2308,7 +2308,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 
 	peer2 = kiblnd_find_peer_locked(nid);
 	if (peer2) {
-		if (peer2->ibp_version == 0) {
+		if (!peer2->ibp_version) {
 			peer2->ibp_version     = version;
 			peer2->ibp_incarnation = reqmsg->ibm_srcstamp;
 		}
@@ -2328,7 +2328,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		}
 
 		/* tie-break connection race in favour of the higher NID */
-		if (peer2->ibp_connecting != 0 &&
+		if (peer2->ibp_connecting &&
 		    nid < ni->ni_nid) {
 			write_unlock_irqrestore(g_lock, flags);
 
@@ -2347,16 +2347,16 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		peer = peer2;
 	} else {
 		/* Brand new peer */
-		LASSERT(peer->ibp_accepting == 0);
-		LASSERT(peer->ibp_version == 0 &&
-			peer->ibp_incarnation == 0);
+		LASSERT(!peer->ibp_accepting);
+		LASSERT(!peer->ibp_version &&
+			!peer->ibp_incarnation);
 
 		peer->ibp_accepting   = 1;
 		peer->ibp_version     = version;
 		peer->ibp_incarnation = reqmsg->ibm_srcstamp;
 
 		/* I have a ref on ni that prevents it being shutdown */
-		LASSERT(net->ibn_shutdown == 0);
+		LASSERT(!net->ibn_shutdown);
 
 		kiblnd_peer_addref(peer);
 		list_add_tail(&peer->ibp_list, kiblnd_nid2peerlist(nid));
@@ -2405,7 +2405,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	CDEBUG(D_NET, "Accept %s\n", libcfs_nid2str(nid));
 
 	rc = rdma_accept(cmid, &cp);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't accept %s: %d\n", libcfs_nid2str(nid), rc);
 		rej.ibr_version = version;
 		rej.ibr_why     = IBLND_REJECT_FATAL;
@@ -2454,7 +2454,7 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 	if ((!list_empty(&peer->ibp_tx_queue) ||
 	     peer->ibp_version != version) &&
 	    peer->ibp_connecting == 1 &&
-	    peer->ibp_accepting == 0) {
+	    !peer->ibp_accepting) {
 		retry = 1;
 		peer->ibp_connecting++;
 
@@ -2649,7 +2649,7 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 
 	LASSERT(net);
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't unpack connack from %s: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), rc);
 		goto failed;
@@ -2706,7 +2706,7 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 		rc = -ESTALE;
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Bad connection reply from %s, rc = %d, version: %x max_frags: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), rc,
 		       msg->ibm_version, msg->ibm_u.connparams.ibcp_max_frags);
@@ -2729,7 +2729,7 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 	 * kiblnd_connreq_done(0) moves the conn state to ESTABLISHED, but then
 	 * immediately tears it down.
 	 */
-	LASSERT(rc != 0);
+	LASSERT(rc);
 	conn->ibc_comms_error = rc;
 	kiblnd_connreq_done(conn, 0);
 }
@@ -2749,8 +2749,8 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	incarnation = peer->ibp_incarnation;
-	version = (peer->ibp_version == 0) ? IBLND_MSG_VERSION :
-					     peer->ibp_version;
+	version = !peer->ibp_version ? IBLND_MSG_VERSION :
+				       peer->ibp_version;
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
@@ -2790,7 +2790,7 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	LASSERT(conn->ibc_cmid == cmid);
 
 	rc = rdma_connect(cmid, &cp);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't connect to %s: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), rc);
 		kiblnd_connreq_done(conn, rc);
@@ -2827,7 +2827,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		        libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer);
-		return -EHOSTUNREACH;      /* rc != 0 destroys cmid */
+		return -EHOSTUNREACH;      /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
 		peer = (kib_peer_t *)cmid->context;
@@ -2835,14 +2835,14 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		CDEBUG(D_NET, "%s Addr resolved: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), event->status);
 
-		if (event->status != 0) {
+		if (event->status) {
 			CNETERR("Can't resolve address for %s: %d\n",
 				libcfs_nid2str(peer->ibp_nid), event->status);
 			rc = event->status;
 		} else {
 			rc = rdma_resolve_route(
 				cmid, *kiblnd_tunables.kib_timeout * 1000);
-			if (rc == 0)
+			if (!rc)
 				return 0;
 			/* Can't initiate route resolution */
 			CERROR("Can't resolve route for %s: %d\n",
@@ -2850,7 +2850,7 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		}
 		kiblnd_peer_connect_failed(peer, 1, rc);
 		kiblnd_peer_decref(peer);
-		return rc;		      /* rc != 0 destroys cmid */
+		return rc;		      /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_ERROR:
 		peer = (kib_peer_t *)cmid->context;
@@ -2858,21 +2858,21 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 			libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer);
-		return -EHOSTUNREACH;	   /* rc != 0 destroys cmid */
+		return -EHOSTUNREACH;	   /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
 		peer = (kib_peer_t *)cmid->context;
 		CDEBUG(D_NET, "%s Route resolved: %d\n",
 		       libcfs_nid2str(peer->ibp_nid), event->status);
 
-		if (event->status == 0)
+		if (!event->status)
 			return kiblnd_active_connect(cmid);
 
 		CNETERR("Can't resolve route for %s: %d\n",
 		        libcfs_nid2str(peer->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer, 1, event->status);
 		kiblnd_peer_decref(peer);
-		return event->status;	   /* rc != 0 destroys cmid */
+		return event->status;	   /* rc destroys cmid */
 
 	case RDMA_CM_EVENT_UNREACHABLE:
 		conn = (kib_conn_t *)cmid->context;
@@ -2984,7 +2984,7 @@ kiblnd_check_txs_locked(kib_conn_t *conn, struct list_head *txs)
 			LASSERT(tx->tx_queued);
 		} else {
 			LASSERT(!tx->tx_queued);
-			LASSERT(tx->tx_waiting || tx->tx_sending != 0);
+			LASSERT(tx->tx_waiting || tx->tx_sending);
 		}
 
 		if (cfs_time_aftereq(jiffies, tx->tx_deadline)) {
@@ -3179,7 +3179,7 @@ kiblnd_connd(void *arg)
 			if (*kiblnd_tunables.kib_timeout > n * p)
 				chunk = (chunk * n * p) /
 					*kiblnd_tunables.kib_timeout;
-			if (chunk == 0)
+			if (!chunk)
 				chunk = 1;
 
 			for (i = 0; i < chunk; i++) {
@@ -3268,7 +3268,7 @@ kiblnd_cq_completion(struct ib_cq *cq, void *arg)
 	 * NB I'm not allowed to schedule this conn once its refcount has
 	 * reached 0.  Since fundamentally I'm racing with scheduler threads
 	 * consuming my CQ I could be called after all completions have
-	 * occurred.  But in this case, ibc_nrx == 0 && ibc_nsends_posted == 0
+	 * occurred.  But in this case, !ibc_nrx && !ibc_nsends_posted
 	 * and this CQ is about to be destroyed so I NOOP.
 	 */
 	kib_conn_t *conn = arg;
@@ -3324,7 +3324,7 @@ kiblnd_scheduler(void *arg)
 	sched = kiblnd_data.kib_scheds[KIB_THREAD_CPT(id)];
 
 	rc = cfs_cpt_bind(lnet_cpt_table(), sched->ibs_cpt);
-	if (rc != 0) {
+	if (rc) {
 		CWARN("Failed to bind on CPT %d, please verify whether all CPUs are healthy and reload modules if necessary, otherwise your system might under risk of low performance\n",
 		      sched->ibs_cpt);
 	}
@@ -3354,7 +3354,7 @@ kiblnd_scheduler(void *arg)
 			spin_unlock_irqrestore(&sched->ibs_lock, flags);
 
 			rc = ib_poll_cq(conn->ibc_cq, 1, &wc);
-			if (rc == 0) {
+			if (!rc) {
 				rc = ib_req_notify_cq(conn->ibc_cq,
 						      IB_CQ_NEXT_COMP);
 				if (rc < 0) {
@@ -3382,7 +3382,7 @@ kiblnd_scheduler(void *arg)
 
 			spin_lock_irqsave(&sched->ibs_lock, flags);
 
-			if (rc != 0 || conn->ibc_ready) {
+			if (rc || conn->ibc_ready) {
 				/*
 				 * There may be another completion waiting; get
 				 * another scheduler to check while I handle
@@ -3398,7 +3398,7 @@ kiblnd_scheduler(void *arg)
 				conn->ibc_scheduled = 0;
 			}
 
-			if (rc != 0) {
+			if (rc) {
 				spin_unlock_irqrestore(&sched->ibs_lock, flags);
 				kiblnd_complete(&wc);
 
@@ -3438,7 +3438,7 @@ kiblnd_failover_thread(void *arg)
 	unsigned long flags;
 	int rc;
 
-	LASSERT(*kiblnd_tunables.kib_dev_failover != 0);
+	LASSERT(*kiblnd_tunables.kib_dev_failover);
 
 	cfs_block_allsigs();
 
@@ -3497,7 +3497,7 @@ kiblnd_failover_thread(void *arg)
 		remove_wait_queue(&kiblnd_data.kib_failover_waitq, &wait);
 		write_lock_irqsave(glock, flags);
 
-		if (!long_sleep || rc != 0)
+		if (!long_sleep || rc)
 			continue;
 
 		/*
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index afbd6d1..b4607da 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -202,7 +202,7 @@ kiblnd_tunables_init(void)
 	if (*kiblnd_tunables.kib_map_on_demand == 1)
 		*kiblnd_tunables.kib_map_on_demand = 2; /* don't make sense to create map if only one fragment */
 
-	if (*kiblnd_tunables.kib_concurrent_sends == 0) {
+	if (!*kiblnd_tunables.kib_concurrent_sends) {
 		if (*kiblnd_tunables.kib_map_on_demand > 0 &&
 		    *kiblnd_tunables.kib_map_on_demand <= IBLND_MAX_RDMA_FRAGS / 8)
 			*kiblnd_tunables.kib_concurrent_sends = (*kiblnd_tunables.kib_peertxcredits) * 2;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 2c2d1c9..49d716d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -91,7 +91,7 @@ ksocknal_create_route(__u32 ipaddr, int port)
 void
 ksocknal_destroy_route(ksock_route_t *route)
 {
-	LASSERT(atomic_read(&route->ksnr_refcount) == 0);
+	LASSERT(!atomic_read(&route->ksnr_refcount));
 
 	if (route->ksnr_peer)
 		ksocknal_peer_decref(route->ksnr_peer);
@@ -154,8 +154,8 @@ ksocknal_destroy_peer(ksock_peer_t *peer)
 	CDEBUG(D_NET, "peer %s %p deleted\n",
 	       libcfs_id2str(peer->ksnp_id), peer);
 
-	LASSERT(atomic_read(&peer->ksnp_refcount) == 0);
-	LASSERT(peer->ksnp_accepting == 0);
+	LASSERT(!atomic_read(&peer->ksnp_refcount));
+	LASSERT(!peer->ksnp_accepting);
 	LASSERT(list_empty(&peer->ksnp_conns));
 	LASSERT(list_empty(&peer->ksnp_routes));
 	LASSERT(list_empty(&peer->ksnp_tx_queue));
@@ -269,7 +269,7 @@ ksocknal_get_peer_info(lnet_ni_t *ni, int index,
 			if (peer->ksnp_ni != ni)
 				continue;
 
-			if (peer->ksnp_n_passive_ips == 0 &&
+			if (!peer->ksnp_n_passive_ips &&
 			    list_empty(&peer->ksnp_routes)) {
 				if (index-- > 0)
 					continue;
@@ -332,7 +332,7 @@ ksocknal_associate_route_conn_locked(ksock_route_t *route, ksock_conn_t *conn)
 	ksocknal_route_addref(route);
 
 	if (route->ksnr_myipaddr != conn->ksnc_myipaddr) {
-		if (route->ksnr_myipaddr == 0) {
+		if (!route->ksnr_myipaddr) {
 			/* route wasn't bound locally yet (the initial route) */
 			CDEBUG(D_NET, "Binding %s %pI4h to %pI4h\n",
 			       libcfs_id2str(peer->ksnp_id),
@@ -378,7 +378,7 @@ ksocknal_add_route_locked(ksock_peer_t *peer, ksock_route_t *route)
 	LASSERT(!route->ksnr_peer);
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
-	LASSERT(route->ksnr_connected == 0);
+	LASSERT(!route->ksnr_connected);
 
 	/* LASSERT(unique) */
 	list_for_each(tmp, &peer->ksnp_routes) {
@@ -429,7 +429,7 @@ ksocknal_del_route_locked(ksock_route_t *route)
 		ksocknal_close_conn_locked(conn, 0);
 	}
 
-	if (route->ksnr_myipaddr != 0) {
+	if (route->ksnr_myipaddr) {
 		iface = ksocknal_ip2iface(route->ksnr_peer->ksnp_ni,
 					  route->ksnr_myipaddr);
 		if (iface)
@@ -466,7 +466,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 
 	/* Have a brand new peer ready... */
 	rc = ksocknal_create_peer(&peer, ni, id);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	route = ksocknal_create_route(ipaddr, port);
@@ -478,7 +478,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	/* always called with a ref on ni, so shutdown can't have started */
-	LASSERT(((ksock_net_t *) ni->ni_data)->ksnn_shutdown == 0);
+	LASSERT(!((ksock_net_t *) ni->ni_data)->ksnn_shutdown);
 
 	peer2 = ksocknal_find_peer_locked(ni, id);
 	if (peer2) {
@@ -530,7 +530,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 		route = list_entry(tmp, ksock_route_t, ksnr_list);
 
 		/* no match */
-		if (!(ip == 0 || route->ksnr_ipaddr == ip))
+		if (!(!ip || route->ksnr_ipaddr == ip))
 			continue;
 
 		route->ksnr_share_count = 0;
@@ -544,7 +544,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 		nshared += route->ksnr_share_count;
 	}
 
-	if (nshared == 0) {
+	if (!nshared) {
 		/*
 		 * remove everything else if there are no explicit entries
 		 * left
@@ -553,7 +553,7 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 			route = list_entry(tmp, ksock_route_t, ksnr_list);
 
 			/* we should only be removing auto-entries */
-			LASSERT(route->ksnr_share_count == 0);
+			LASSERT(!route->ksnr_share_count);
 			ksocknal_del_route_locked(route);
 		}
 
@@ -710,7 +710,7 @@ ksocknal_local_ipvec(lnet_ni_t *ni, __u32 *ipaddrs)
 
 	for (i = 0; i < nip; i++) {
 		ipaddrs[i] = net->ksnn_interfaces[i].ksni_ipaddr;
-		LASSERT(ipaddrs[i] != 0);
+		LASSERT(ipaddrs[i]);
 	}
 
 	read_unlock(&ksocknal_data.ksnd_global_lock);
@@ -728,11 +728,11 @@ ksocknal_match_peerip(ksock_interface_t *iface, __u32 *ips, int nips)
 	int i;
 
 	for (i = 0; i < nips; i++) {
-		if (ips[i] == 0)
+		if (!ips[i])
 			continue;
 
 		this_xor = ips[i] ^ iface->ksni_ipaddr;
-		this_netmatch = ((this_xor & iface->ksni_netmask) == 0) ? 1 : 0;
+		this_netmatch = !(this_xor & iface->ksni_netmask) ? 1 : 0;
 
 		if (!(best < 0 ||
 		      best_netmatch < this_netmatch ||
@@ -824,7 +824,7 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 
 				k = ksocknal_match_peerip(iface, peerips, n_peerips);
 				xor = ip ^ peerips[k];
-				this_netmatch = ((xor & iface->ksni_netmask) == 0) ? 1 : 0;
+				this_netmatch = !(xor & iface->ksni_netmask) ? 1 : 0;
 
 				if (!(!best_iface ||
 				      best_netmatch < this_netmatch ||
@@ -947,9 +947,9 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 			if (route)
 				continue;
 
-			this_netmatch = (((iface->ksni_ipaddr ^
+			this_netmatch = (!((iface->ksni_ipaddr ^
 					   newroute->ksnr_ipaddr) &
-					   iface->ksni_netmask) == 0) ? 1 : 0;
+					   iface->ksni_netmask)) ? 1 : 0;
 
 			if (!(!best_iface ||
 			      best_netmatch < this_netmatch ||
@@ -986,7 +986,7 @@ ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
 	int peer_port;
 
 	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
-	LASSERT(rc == 0);		      /* we succeeded before */
+	LASSERT(!rc);		      /* we succeeded before */
 
 	LIBCFS_ALLOC(cr, sizeof(*cr));
 	if (!cr) {
@@ -1082,7 +1082,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 	/* stash conn's local and remote addrs */
 	rc = ksocknal_lib_get_conn_addrs(conn);
-	if (rc != 0)
+	if (rc)
 		goto failed_1;
 
 	/*
@@ -1114,7 +1114,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		}
 
 		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
-		if (rc != 0)
+		if (rc)
 			goto failed_1;
 	} else {
 		peerid.nid = LNET_NID_ANY;
@@ -1128,7 +1128,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	if (rc < 0)
 		goto failed_1;
 
-	LASSERT(rc == 0 || active);
+	LASSERT(!rc || active);
 	LASSERT(conn->ksnc_proto);
 	LASSERT(peerid.nid != LNET_NID_ANY);
 
@@ -1139,13 +1139,13 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		write_lock_bh(global_lock);
 	} else {
 		rc = ksocknal_create_peer(&peer, ni, peerid);
-		if (rc != 0)
+		if (rc)
 			goto failed_1;
 
 		write_lock_bh(global_lock);
 
 		/* called with a ref on ni, so shutdown can't have started */
-		LASSERT(((ksock_net_t *) ni->ni_data)->ksnn_shutdown == 0);
+		LASSERT(!((ksock_net_t *) ni->ni_data)->ksnn_shutdown);
 
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
 		if (!peer2) {
@@ -1239,7 +1239,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 			 * Reply on a passive connection attempt so the peer
 			 * realises we're connected.
 			 */
-			LASSERT(rc == 0);
+			LASSERT(!rc);
 			if (!active)
 				rc = EALREADY;
 
@@ -1344,7 +1344,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	 * socket; this ensures the socket only tears down after the
 	 * response has been sent.
 	 */
-	if (rc == 0)
+	if (!rc)
 		rc = ksocknal_lib_setup_sock(sock);
 
 	write_lock_bh(global_lock);
@@ -1357,14 +1357,14 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 	write_unlock_bh(global_lock);
 
-	if (rc != 0) {
+	if (rc) {
 		write_lock_bh(global_lock);
 		if (!conn->ksnc_closing) {
 			/* could be closed by another thread */
 			ksocknal_close_conn_locked(conn, rc);
 		}
 		write_unlock_bh(global_lock);
-	} else if (ksocknal_connsock_addref(conn) == 0) {
+	} else if (!ksocknal_connsock_addref(conn)) {
 		/* Allow I/O to proceed. */
 		ksocknal_read_callback(conn);
 		ksocknal_write_callback(conn);
@@ -1439,7 +1439,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 	ksock_conn_t *conn2;
 	struct list_head *tmp;
 
-	LASSERT(peer->ksnp_error == 0);
+	LASSERT(!peer->ksnp_error);
 	LASSERT(!conn->ksnc_closing);
 	conn->ksnc_closing = 1;
 
@@ -1450,7 +1450,7 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 	if (route) {
 		/* dissociate conn from route... */
 		LASSERT(!route->ksnr_deleted);
-		LASSERT((route->ksnr_connected & (1 << conn->ksnc_type)) != 0);
+		LASSERT(route->ksnr_connected & (1 << conn->ksnc_type));
 
 		conn2 = NULL;
 		list_for_each(tmp, &peer->ksnp_conns) {
@@ -1531,9 +1531,9 @@ ksocknal_peer_failed(ksock_peer_t *peer)
 	 */
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
-	if ((peer->ksnp_id.pid & LNET_PID_USERFLAG) == 0 &&
+	if (!(peer->ksnp_id.pid & LNET_PID_USERFLAG) &&
 	    list_empty(&peer->ksnp_conns) &&
-	    peer->ksnp_accepting == 0 &&
+	    !peer->ksnp_accepting &&
 	    !ksocknal_find_connecting_route_locked(peer)) {
 		notify = 1;
 		last_alive = peer->ksnp_last_alive;
@@ -1566,7 +1566,7 @@ ksocknal_finalize_zcreq(ksock_conn_t *conn)
 		if (tx->tx_conn != conn)
 			continue;
 
-		LASSERT(tx->tx_msg.ksm_zc_cookies[0] != 0);
+		LASSERT(tx->tx_msg.ksm_zc_cookies[0]);
 
 		tx->tx_msg.ksm_zc_cookies[0] = 0;
 		tx->tx_zc_aborted = 1; /* mark it as not-acked */
@@ -1629,7 +1629,7 @@ ksocknal_terminate_conn(ksock_conn_t *conn)
 	 */
 	conn->ksnc_scheduler->kss_nconns--;
 
-	if (peer->ksnp_error != 0) {
+	if (peer->ksnp_error) {
 		/* peer's last conn closed in error */
 		LASSERT(list_empty(&peer->ksnp_conns));
 		failed = 1;
@@ -1656,7 +1656,7 @@ ksocknal_queue_zombie_conn(ksock_conn_t *conn)
 {
 	/* Queue the conn for the reaper to destroy */
 
-	LASSERT(atomic_read(&conn->ksnc_conn_refcount) == 0);
+	LASSERT(!atomic_read(&conn->ksnc_conn_refcount));
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
 	list_add_tail(&conn->ksnc_list, &ksocknal_data.ksnd_zombie_conns);
@@ -1673,8 +1673,8 @@ ksocknal_destroy_conn(ksock_conn_t *conn)
 	/* Final coup-de-grace of the reaper */
 	CDEBUG(D_NET, "connection %p\n", conn);
 
-	LASSERT(atomic_read(&conn->ksnc_conn_refcount) == 0);
-	LASSERT(atomic_read(&conn->ksnc_sock_refcount) == 0);
+	LASSERT(!atomic_read(&conn->ksnc_conn_refcount));
+	LASSERT(!atomic_read(&conn->ksnc_sock_refcount));
 	LASSERT(!conn->ksnc_sock);
 	LASSERT(!conn->ksnc_route);
 	LASSERT(!conn->ksnc_tx_scheduled);
@@ -1736,8 +1736,7 @@ ksocknal_close_peer_conns_locked(ksock_peer_t *peer, __u32 ipaddr, int why)
 	list_for_each_safe(ctmp, cnxt, &peer->ksnp_conns) {
 		conn = list_entry(ctmp, ksock_conn_t, ksnc_list);
 
-		if (ipaddr == 0 ||
-		    conn->ksnc_ipaddr == ipaddr) {
+		if (!ipaddr || conn->ksnc_ipaddr == ipaddr) {
 			count++;
 			ksocknal_close_conn_locked(conn, why);
 		}
@@ -1799,10 +1798,10 @@ ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	/* wildcards always succeed */
-	if (id.nid == LNET_NID_ANY || id.pid == LNET_PID_ANY || ipaddr == 0)
+	if (id.nid == LNET_NID_ANY || id.pid == LNET_PID_ANY || !ipaddr)
 		return 0;
 
-	if (count == 0)
+	if (!count)
 		return -ENOENT;
 	else
 		return 0;
@@ -1873,7 +1872,7 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 
 	read_unlock(glock);
 
-	if (last_alive != 0)
+	if (last_alive)
 		*when = last_alive;
 
 	CDEBUG(D_NET, "Peer %s %p, alive %ld secs ago, connect %d\n",
@@ -1966,7 +1965,7 @@ static int ksocknal_push(lnet_ni_t *ni, lnet_process_id_t id)
 			}
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 
-			if (i == 0) /* no match */
+			if (!i) /* no match */
 				break;
 
 			rc = 0;
@@ -1990,8 +1989,7 @@ ksocknal_add_interface(lnet_ni_t *ni, __u32 ipaddress, __u32 netmask)
 	struct list_head *rtmp;
 	ksock_route_t *route;
 
-	if (ipaddress == 0 ||
-	    netmask == 0)
+	if (!ipaddress || !netmask)
 		return -EINVAL;
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
@@ -2063,7 +2061,7 @@ ksocknal_peer_del_interface_locked(ksock_peer_t *peer, __u32 ipaddr)
 		if (route->ksnr_myipaddr != ipaddr)
 			continue;
 
-		if (route->ksnr_share_count != 0) {
+		if (route->ksnr_share_count) {
 			/* Manually created; keep, but unbind */
 			route->ksnr_myipaddr = 0;
 		} else {
@@ -2096,8 +2094,7 @@ ksocknal_del_interface(lnet_ni_t *ni, __u32 ipaddress)
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
 		this_ip = net->ksnn_interfaces[i].ksni_ipaddr;
 
-		if (!(ipaddress == 0 ||
-		      ipaddress == this_ip))
+		if (!(!ipaddress || ipaddress == this_ip))
 			continue;
 
 		rc = 0;
@@ -2175,7 +2172,7 @@ ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 		rc = ksocknal_get_peer_info(ni, data->ioc_count,
 					    &id, &myip, &ip, &port,
 					    &conn_count,  &share_count);
-		if (rc != 0)
+		if (rc)
 			return rc;
 
 		data->ioc_nid    = id.nid;
@@ -2256,7 +2253,7 @@ ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 static void
 ksocknal_free_buffers(void)
 {
-	LASSERT(atomic_read(&ksocknal_data.ksnd_nactive_txs) == 0);
+	LASSERT(!atomic_read(&ksocknal_data.ksnd_nactive_txs));
 
 	if (ksocknal_data.ksnd_sched_info) {
 		struct ksock_sched_info *info;
@@ -2304,7 +2301,7 @@ ksocknal_base_shutdown(void)
 	int i;
 	int j;
 
-	LASSERT(ksocknal_data.ksnd_nnets == 0);
+	LASSERT(!ksocknal_data.ksnd_nnets);
 
 	switch (ksocknal_data.ksnd_init) {
 	default:
@@ -2336,7 +2333,7 @@ ksocknal_base_shutdown(void)
 						&sched->kss_rx_conns));
 					LASSERT(list_empty(
 						&sched->kss_zombie_noop_txs));
-					LASSERT(sched->kss_nconns == 0);
+					LASSERT(!sched->kss_nconns);
 				}
 			}
 		}
@@ -2361,7 +2358,7 @@ ksocknal_base_shutdown(void)
 
 		i = 4;
 		read_lock(&ksocknal_data.ksnd_global_lock);
-		while (ksocknal_data.ksnd_nthreads != 0) {
+		while (ksocknal_data.ksnd_nthreads) {
 			i++;
 			CDEBUG(((i & (-i)) == i) ? D_WARNING : D_NET, /* power of 2? */
 			       "waiting for %d threads to terminate\n",
@@ -2399,7 +2396,7 @@ ksocknal_base_startup(void)
 	int i;
 
 	LASSERT(ksocknal_data.ksnd_init == SOCKNAL_INIT_NOTHING);
-	LASSERT(ksocknal_data.ksnd_nnets == 0);
+	LASSERT(!ksocknal_data.ksnd_nnets);
 
 	memset(&ksocknal_data, 0, sizeof(ksocknal_data)); /* zero pointers */
 
@@ -2502,7 +2499,7 @@ ksocknal_base_startup(void)
 		snprintf(name, sizeof(name), "socknal_cd%02d", i);
 		rc = ksocknal_thread_start(ksocknal_connd,
 					   (void *)((ulong_ptr_t)i), name);
-		if (rc != 0) {
+		if (rc) {
 			spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 			ksocknal_data.ksnd_connd_starting--;
 			spin_unlock_bh(&ksocknal_data.ksnd_connd_lock);
@@ -2512,7 +2509,7 @@ ksocknal_base_startup(void)
 	}
 
 	rc = ksocknal_thread_start(ksocknal_reaper, NULL, "socknal_reaper");
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't spawn socknal reaper: %d\n", rc);
 		goto failed;
 	}
@@ -2604,7 +2601,7 @@ ksocknal_shutdown(lnet_ni_t *ni)
 	/* Wait for all peer state to clean up */
 	i = 2;
 	spin_lock_bh(&net->ksnn_lock);
-	while (net->ksnn_npeers != 0) {
+	while (net->ksnn_npeers) {
 		spin_unlock_bh(&net->ksnn_lock);
 
 		i++;
@@ -2621,15 +2618,15 @@ ksocknal_shutdown(lnet_ni_t *ni)
 	spin_unlock_bh(&net->ksnn_lock);
 
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		LASSERT(net->ksnn_interfaces[i].ksni_npeers == 0);
-		LASSERT(net->ksnn_interfaces[i].ksni_nroutes == 0);
+		LASSERT(!net->ksnn_interfaces[i].ksni_npeers);
+		LASSERT(!net->ksnn_interfaces[i].ksni_nroutes);
 	}
 
 	list_del(&net->ksnn_list);
 	LIBCFS_FREE(net, sizeof(*net));
 
 	ksocknal_data.ksnd_nnets--;
-	if (ksocknal_data.ksnd_nnets == 0)
+	if (!ksocknal_data.ksnd_nnets)
 		ksocknal_base_shutdown();
 }
 
@@ -2657,7 +2654,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 			continue;
 
 		rc = lnet_ipif_query(names[i], &up, &ip, &mask);
-		if (rc != 0) {
+		if (rc) {
 			CWARN("Can't get interface %s info: %d\n",
 			      names[i], rc);
 			continue;
@@ -2684,7 +2681,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 
 	lnet_ipif_free_enumeration(names, n);
 
-	if (j == 0)
+	if (!j)
 		CERROR("Can't find any usable interfaces\n");
 
 	return j;
@@ -2715,7 +2712,7 @@ ksocknal_search_new_ipif(ksock_net_t *net)
 				if (colon2)
 					*colon2 = 0;
 
-				found = strcmp(ifnam, ifnam2) == 0;
+				found = !strcmp(ifnam, ifnam2);
 				if (colon2)
 					*colon2 = ':';
 			}
@@ -2738,7 +2735,7 @@ ksocknal_start_schedulers(struct ksock_sched_info *info)
 	int rc = 0;
 	int i;
 
-	if (info->ksi_nthreads == 0) {
+	if (!info->ksi_nthreads) {
 		if (*ksocknal_tunables.ksnd_nscheds > 0) {
 			nthrs = info->ksi_nthreads_max;
 		} else {
@@ -2766,7 +2763,7 @@ ksocknal_start_schedulers(struct ksock_sched_info *info)
 
 		rc = ksocknal_thread_start(ksocknal_scheduler,
 					   (void *)id, name);
-		if (rc == 0)
+		if (!rc)
 			continue;
 
 		CERROR("Can't spawn thread %d for scheduler[%d]: %d\n",
@@ -2798,7 +2795,7 @@ ksocknal_net_start_threads(ksock_net_t *net, __u32 *cpts, int ncpts)
 			continue;
 
 		rc = ksocknal_start_schedulers(info);
-		if (rc != 0)
+		if (rc)
 			return rc;
 	}
 	return 0;
@@ -2815,7 +2812,7 @@ ksocknal_startup(lnet_ni_t *ni)
 
 	if (ksocknal_data.ksnd_init == SOCKNAL_INIT_NOTHING) {
 		rc = ksocknal_base_startup();
-		if (rc != 0)
+		if (rc)
 			return rc;
 	}
 
@@ -2848,7 +2845,7 @@ ksocknal_startup(lnet_ni_t *ni)
 					     &net->ksnn_interfaces[i].ksni_ipaddr,
 					     &net->ksnn_interfaces[i].ksni_netmask);
 
-			if (rc != 0) {
+			if (rc) {
 				CERROR("Can't get interface %s info: %d\n",
 				       ni->ni_interfaces[i], rc);
 				goto fail_1;
@@ -2869,7 +2866,7 @@ ksocknal_startup(lnet_ni_t *ni)
 
 	/* call it before add it to ksocknal_data.ksnd_nets */
 	rc = ksocknal_net_start_threads(net, ni->ni_cpts, ni->ni_ncpts);
-	if (rc != 0)
+	if (rc)
 		goto fail_1;
 
 	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
@@ -2883,7 +2880,7 @@ ksocknal_startup(lnet_ni_t *ni)
  fail_1:
 	LIBCFS_FREE(net, sizeof(*net));
  fail_0:
-	if (ksocknal_data.ksnd_nnets == 0)
+	if (!ksocknal_data.ksnd_nnets)
 		ksocknal_base_shutdown();
 
 	return -ENETDOWN;
@@ -2916,7 +2913,7 @@ ksocknal_module_init(void)
 	the_ksocklnd.lnd_accept   = ksocknal_accept;
 
 	rc = ksocknal_tunables_init();
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	lnet_register_lnd(&the_ksocklnd);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index f9ec607..02da02d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -138,7 +138,7 @@ ksocknal_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
 		nob -= iov->iov_len;
 		tx->tx_iov = ++iov;
 		tx->tx_niov--;
-	} while (nob != 0);
+	} while (nob);
 
 	return rc;
 }
@@ -150,7 +150,7 @@ ksocknal_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 	int nob;
 	int rc;
 
-	LASSERT(tx->tx_niov == 0);
+	LASSERT(!tx->tx_niov);
 	LASSERT(tx->tx_nkiov > 0);
 
 	/* Never touch tx->tx_kiov inside ksocknal_lib_send_kiov() */
@@ -176,7 +176,7 @@ ksocknal_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 		nob -= (int)kiov->kiov_len;
 		tx->tx_kiov = ++kiov;
 		tx->tx_nkiov--;
-	} while (nob != 0);
+	} while (nob);
 
 	return rc;
 }
@@ -187,15 +187,15 @@ ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 	int rc;
 	int bufnob;
 
-	if (ksocknal_data.ksnd_stall_tx != 0) {
+	if (ksocknal_data.ksnd_stall_tx) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(cfs_time_seconds(ksocknal_data.ksnd_stall_tx));
 	}
 
-	LASSERT(tx->tx_resid != 0);
+	LASSERT(tx->tx_resid);
 
 	rc = ksocknal_connsock_addref(conn);
-	if (rc != 0) {
+	if (rc) {
 		LASSERT(conn->ksnc_closing);
 		return -ESHUTDOWN;
 	}
@@ -205,7 +205,7 @@ ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 			/* testing... */
 			ksocknal_data.ksnd_enomem_tx--;
 			rc = -EAGAIN;
-		} else if (tx->tx_niov != 0) {
+		} else if (tx->tx_niov) {
 			rc = ksocknal_send_iov(conn, tx);
 		} else {
 			rc = ksocknal_send_kiov(conn, tx);
@@ -229,7 +229,7 @@ ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 
 		if (rc <= 0) { /* Didn't write anything? */
 
-			if (rc == 0) /* some stacks return 0 instead of -EAGAIN */
+			if (!rc) /* some stacks return 0 instead of -EAGAIN */
 				rc = -EAGAIN;
 
 			/* Check if EAGAIN is due to memory pressure */
@@ -243,7 +243,7 @@ ksocknal_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 		atomic_sub(rc, &conn->ksnc_tx_nob);
 		rc = 0;
 
-	} while (tx->tx_resid != 0);
+	} while (tx->tx_resid);
 
 	ksocknal_connsock_decref(conn);
 	return rc;
@@ -291,7 +291,7 @@ ksocknal_recv_iov(ksock_conn_t *conn)
 		nob -= iov->iov_len;
 		conn->ksnc_rx_iov = ++iov;
 		conn->ksnc_rx_niov--;
-	} while (nob != 0);
+	} while (nob);
 
 	return rc;
 }
@@ -338,7 +338,7 @@ ksocknal_recv_kiov(ksock_conn_t *conn)
 		nob -= kiov->kiov_len;
 		conn->ksnc_rx_kiov = ++kiov;
 		conn->ksnc_rx_nkiov--;
-	} while (nob != 0);
+	} while (nob);
 
 	return 1;
 }
@@ -353,19 +353,19 @@ ksocknal_receive(ksock_conn_t *conn)
 	 */
 	int rc;
 
-	if (ksocknal_data.ksnd_stall_rx != 0) {
+	if (ksocknal_data.ksnd_stall_rx) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(cfs_time_seconds(ksocknal_data.ksnd_stall_rx));
 	}
 
 	rc = ksocknal_connsock_addref(conn);
-	if (rc != 0) {
+	if (rc) {
 		LASSERT(conn->ksnc_closing);
 		return -ESHUTDOWN;
 	}
 
 	for (;;) {
-		if (conn->ksnc_rx_niov != 0)
+		if (conn->ksnc_rx_niov)
 			rc = ksocknal_recv_iov(conn);
 		else
 			rc = ksocknal_recv_kiov(conn);
@@ -374,7 +374,7 @@ ksocknal_receive(ksock_conn_t *conn)
 			/* error/EOF or partial receive */
 			if (rc == -EAGAIN) {
 				rc = 1;
-			} else if (rc == 0 && conn->ksnc_rx_started) {
+			} else if (!rc && conn->ksnc_rx_started) {
 				/* EOF in the middle of a message */
 				rc = -EPROTO;
 			}
@@ -383,7 +383,7 @@ ksocknal_receive(ksock_conn_t *conn)
 
 		/* Completed a fragment */
 
-		if (conn->ksnc_rx_nob_wanted == 0) {
+		if (!conn->ksnc_rx_nob_wanted) {
 			rc = 1;
 			break;
 		}
@@ -397,7 +397,7 @@ void
 ksocknal_tx_done(lnet_ni_t *ni, ksock_tx_t *tx)
 {
 	lnet_msg_t *lnetmsg = tx->tx_lnetmsg;
-	int rc = (tx->tx_resid == 0 && !tx->tx_zc_aborted) ? 0 : -EIO;
+	int rc = (!tx->tx_resid && !tx->tx_zc_aborted) ? 0 : -EIO;
 
 	LASSERT(ni || tx->tx_conn);
 
@@ -472,11 +472,11 @@ ksocknal_check_zc_req(ksock_tx_t *tx)
 	tx->tx_deadline =
 		cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
 
-	LASSERT(tx->tx_msg.ksm_zc_cookies[0] == 0);
+	LASSERT(!tx->tx_msg.ksm_zc_cookies[0]);
 
 	tx->tx_msg.ksm_zc_cookies[0] = peer->ksnp_zc_next_cookie++;
 
-	if (peer->ksnp_zc_next_cookie == 0)
+	if (!peer->ksnp_zc_next_cookie)
 		peer->ksnp_zc_next_cookie = SOCKNAL_KEEPALIVE_PING + 1;
 
 	list_add_tail(&tx->tx_zc_list, &peer->ksnp_zc_req_list);
@@ -496,7 +496,7 @@ ksocknal_uncheck_zc_req(ksock_tx_t *tx)
 
 	spin_lock(&peer->ksnp_lock);
 
-	if (tx->tx_msg.ksm_zc_cookies[0] == 0) {
+	if (!tx->tx_msg.ksm_zc_cookies[0]) {
 		/* Not waiting for an ACK */
 		spin_unlock(&peer->ksnp_lock);
 		return;
@@ -522,9 +522,9 @@ ksocknal_process_transmit(ksock_conn_t *conn, ksock_tx_t *tx)
 
 	CDEBUG(D_NET, "send(%d) %d\n", tx->tx_resid, rc);
 
-	if (tx->tx_resid == 0) {
+	if (!tx->tx_resid) {
 		/* Sent everything OK */
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 
 		return 0;
 	}
@@ -592,7 +592,7 @@ ksocknal_launch_connection_locked(ksock_route_t *route)
 
 	LASSERT(!route->ksnr_scheduled);
 	LASSERT(!route->ksnr_connecting);
-	LASSERT((ksocknal_route_mask() & ~route->ksnr_connected) != 0);
+	LASSERT(ksocknal_route_mask() & ~route->ksnr_connected);
 
 	route->ksnr_scheduled = 1;	      /* scheduling conn for connd */
 	ksocknal_route_addref(route);	   /* extra ref for connd */
@@ -737,7 +737,7 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 	bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
 	spin_lock_bh(&sched->kss_lock);
 
-	if (list_empty(&conn->ksnc_tx_queue) && bufnob == 0) {
+	if (list_empty(&conn->ksnc_tx_queue) && !bufnob) {
 		/* First packet starts the timeout */
 		conn->ksnc_tx_deadline =
 			cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
@@ -752,7 +752,7 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 		 * The packet is noop ZC ACK, try to piggyback the ack_cookie
 		 * on a normal packet so I don't need to send it
 		 */
-		LASSERT(msg->ksm_zc_cookies[1] != 0);
+		LASSERT(msg->ksm_zc_cookies[1]);
 		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack);
 
 		if (conn->ksnc_proto->pro_queue_tx_zcack(conn, tx, 0))
@@ -763,7 +763,7 @@ ksocknal_queue_tx_locked(ksock_tx_t *tx, ksock_conn_t *conn)
 		 * It's a normal packet - can it piggback a noop zc-ack that
 		 * has been queued already?
 		 */
-		LASSERT(msg->ksm_zc_cookies[1] == 0);
+		LASSERT(!msg->ksm_zc_cookies[1]);
 		LASSERT(conn->ksnc_proto->pro_queue_tx_msg);
 
 		ztx = conn->ksnc_proto->pro_queue_tx_msg(conn, tx);
@@ -803,10 +803,10 @@ ksocknal_find_connectable_route_locked(ksock_peer_t *peer)
 			continue;
 
 		/* all route types connected ? */
-		if ((ksocknal_route_mask() & ~route->ksnr_connected) == 0)
+		if (!(ksocknal_route_mask() & ~route->ksnr_connected))
 			continue;
 
-		if (!(route->ksnr_retry_interval == 0 || /* first attempt */
+		if (!(!route->ksnr_retry_interval || /* first attempt */
 		      cfs_time_aftereq(now, route->ksnr_timeout))) {
 			CDEBUG(D_NET,
 			       "Too soon to retry route %pI4h (cnted %d, interval %ld, %ld secs later)\n",
@@ -884,7 +884,7 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 
 		write_unlock_bh(g_lock);
 
-		if ((id.pid & LNET_PID_USERFLAG) != 0) {
+		if (id.pid & LNET_PID_USERFLAG) {
 			CERROR("Refusing to create a connection to userspace process %s\n",
 			       libcfs_id2str(id));
 			return -EHOSTUNREACH;
@@ -898,7 +898,7 @@ ksocknal_launch_packet(lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 		rc = ksocknal_add_peer(ni, id,
 				       LNET_NIDADDR(id.nid),
 				       lnet_acceptor_port());
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't add peer %s: %d\n",
 			       libcfs_id2str(id), rc);
 			return rc;
@@ -956,7 +956,7 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	CDEBUG(D_NET, "sending %u bytes in %d frags to %s\n",
 	       payload_nob, payload_niov, libcfs_id2str(target));
 
-	LASSERT(payload_nob == 0 || payload_niov > 0);
+	LASSERT(!payload_nob || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
 	/* payload is either all vaddrs or all pages */
 	LASSERT(!(payload_kiov && payload_iov));
@@ -1010,7 +1010,7 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	if (!mpflag)
 		cfs_memory_pressure_restore(mpflag);
 
-	if (rc == 0)
+	if (!rc)
 		return 0;
 
 	ksocknal_free_tx(tx);
@@ -1050,12 +1050,12 @@ ksocknal_new_packet(ksock_conn_t *conn, int nob_to_skip)
 
 	LASSERT(conn->ksnc_proto);
 
-	if ((*ksocknal_tunables.ksnd_eager_ack & conn->ksnc_type) != 0) {
+	if (*ksocknal_tunables.ksnd_eager_ack & conn->ksnc_type) {
 		/* Remind the socket to ack eagerly... */
 		ksocknal_lib_eager_ack(conn);
 	}
 
-	if (nob_to_skip == 0) {	 /* right at next packet boundary now */
+	if (!nob_to_skip) {	 /* right at next packet boundary now */
 		conn->ksnc_rx_started = 0;
 		mb();		       /* racing with timeout thread */
 
@@ -1112,7 +1112,7 @@ ksocknal_new_packet(ksock_conn_t *conn, int nob_to_skip)
 		skipped += nob;
 		nob_to_skip -= nob;
 
-	} while (nob_to_skip != 0 &&    /* mustn't overflow conn's rx iov */
+	} while (nob_to_skip &&    /* mustn't overflow conn's rx iov */
 		 niov < sizeof(conn->ksnc_rx_iov_space) / sizeof(struct iovec));
 
 	conn->ksnc_rx_niov = niov;
@@ -1138,13 +1138,13 @@ ksocknal_process_receive(ksock_conn_t *conn)
 		conn->ksnc_rx_state == SOCKNAL_RX_LNET_HEADER ||
 		conn->ksnc_rx_state == SOCKNAL_RX_SLOP);
  again:
-	if (conn->ksnc_rx_nob_wanted != 0) {
+	if (conn->ksnc_rx_nob_wanted) {
 		rc = ksocknal_receive(conn);
 
 		if (rc <= 0) {
 			LASSERT(rc != -EAGAIN);
 
-			if (rc == 0)
+			if (!rc)
 				CDEBUG(D_NET, "[%p] EOF from %s ip %pI4h:%d\n",
 				       conn,
 				       libcfs_id2str(conn->ksnc_peer->ksnp_id),
@@ -1160,10 +1160,10 @@ ksocknal_process_receive(ksock_conn_t *conn)
 			/* it's not an error if conn is being closed */
 			ksocknal_close_conn_and_siblings(conn,
 							 (conn->ksnc_closing) ? 0 : rc);
-			return (rc == 0 ? -ESHUTDOWN : rc);
+			return (!rc ? -ESHUTDOWN : rc);
 		}
 
-		if (conn->ksnc_rx_nob_wanted != 0) {
+		if (conn->ksnc_rx_nob_wanted) {
 			/* short read */
 			return -EAGAIN;
 		}
@@ -1188,7 +1188,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 		}
 
 		if (conn->ksnc_msg.ksm_type == KSOCK_MSG_NOOP &&
-		    conn->ksnc_msg.ksm_csum != 0 &&     /* has checksum */
+		    conn->ksnc_msg.ksm_csum &&     /* has checksum */
 		    conn->ksnc_msg.ksm_csum != conn->ksnc_rx_csum) {
 			/* NOOP Checksum error */
 			CERROR("%s: Checksum error, wire:0x%08X data:0x%08X\n",
@@ -1199,7 +1199,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 			return -EIO;
 		}
 
-		if (conn->ksnc_msg.ksm_zc_cookies[1] != 0) {
+		if (conn->ksnc_msg.ksm_zc_cookies[1]) {
 			__u64 cookie = 0;
 
 			LASSERT(conn->ksnc_proto != &ksocknal_protocol_v1x);
@@ -1210,7 +1210,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 			rc = conn->ksnc_proto->pro_handle_zcack(conn, cookie,
 					       conn->ksnc_msg.ksm_zc_cookies[1]);
 
-			if (rc != 0) {
+			if (rc) {
 				CERROR("%s: Unknown ZC-ACK cookie: %llu, %llu\n",
 				       libcfs_id2str(conn->ksnc_peer->ksnp_id),
 				       cookie, conn->ksnc_msg.ksm_zc_cookies[1]);
@@ -1243,7 +1243,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 		/* unpack message header */
 		conn->ksnc_proto->pro_unpack(&conn->ksnc_msg);
 
-		if ((conn->ksnc_peer->ksnp_id.pid & LNET_PID_USERFLAG) != 0) {
+		if (conn->ksnc_peer->ksnp_id.pid & LNET_PID_USERFLAG) {
 			/* Userspace peer */
 			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr;
 			id = &conn->ksnc_peer->ksnp_id;
@@ -1281,8 +1281,8 @@ ksocknal_process_receive(ksock_conn_t *conn)
 		/* payload all received */
 		rc = 0;
 
-		if (conn->ksnc_rx_nob_left == 0 &&   /* not truncating */
-		    conn->ksnc_msg.ksm_csum != 0 &&  /* has checksum */
+		if (!conn->ksnc_rx_nob_left &&   /* not truncating */
+		    conn->ksnc_msg.ksm_csum &&  /* has checksum */
 		    conn->ksnc_msg.ksm_csum != conn->ksnc_rx_csum) {
 			CERROR("%s: Checksum error, wire:0x%08X data:0x%08X\n",
 			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
@@ -1290,7 +1290,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 			rc = -EIO;
 		}
 
-		if (rc == 0 && conn->ksnc_msg.ksm_zc_cookies[0] != 0) {
+		if (!rc && conn->ksnc_msg.ksm_zc_cookies[0]) {
 			LASSERT(conn->ksnc_proto != &ksocknal_protocol_v1x);
 
 			lhdr = &conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr;
@@ -1304,7 +1304,7 @@ ksocknal_process_receive(ksock_conn_t *conn)
 
 		lnet_finalize(conn->ksnc_peer->ksnp_ni, conn->ksnc_cookie, rc);
 
-		if (rc != 0) {
+		if (rc) {
 			ksocknal_new_packet(conn, 0);
 			ksocknal_close_conn_and_siblings(conn, rc);
 			return -EPROTO;
@@ -1341,7 +1341,7 @@ ksocknal_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	conn->ksnc_rx_nob_wanted = mlen;
 	conn->ksnc_rx_nob_left = rlen;
 
-	if (mlen == 0 || iov) {
+	if (!mlen || iov) {
 		conn->ksnc_rx_nkiov = 0;
 		conn->ksnc_rx_kiov = NULL;
 		conn->ksnc_rx_iov = conn->ksnc_rx_iov_space.iov;
@@ -1415,7 +1415,7 @@ int ksocknal_scheduler(void *arg)
 	cfs_block_allsigs();
 
 	rc = cfs_cpt_bind(lnet_cpt_table(), info->ksi_cpt);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set CPT affinity to %d: %d\n",
 		       info->ksi_cpt, rc);
 	}
@@ -1452,7 +1452,7 @@ int ksocknal_scheduler(void *arg)
 			LASSERT(conn->ksnc_rx_scheduled);
 
 			/* Did process_receive get everything it wanted? */
-			if (rc == 0)
+			if (!rc)
 				conn->ksnc_rx_ready = 1;
 
 			if (conn->ksnc_rx_state == SOCKNAL_RX_PARSE) {
@@ -1560,7 +1560,7 @@ int ksocknal_scheduler(void *arg)
 				rc = wait_event_interruptible_exclusive(
 					sched->kss_waitq,
 					!ksocknal_sched_cansleep(sched));
-				LASSERT(rc == 0);
+				LASSERT(!rc);
 			} else {
 				cond_resched();
 			}
@@ -1636,7 +1636,7 @@ ksocknal_parse_proto_version(ksock_hello_msg_t *hello)
 	else if (hello->kshm_magic == __swab32(LNET_PROTO_MAGIC))
 		version = __swab32(hello->kshm_version);
 
-	if (version != 0) {
+	if (version) {
 #if SOCKNAL_VERSION_DEBUG
 		if (*ksocknal_tunables.ksnd_protocol == 1)
 			return NULL;
@@ -1731,7 +1731,7 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 			    lnet_acceptor_timeout();
 
 	rc = lnet_sock_read(sock, &hello->kshm_magic, sizeof(hello->kshm_magic), timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0);
@@ -1751,7 +1751,7 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 
 	rc = lnet_sock_read(sock, &hello->kshm_version,
 			    sizeof(hello->kshm_version), timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0);
@@ -1785,7 +1785,7 @@ ksocknal_recv_hello(lnet_ni_t *ni, ksock_conn_t *conn,
 
 	/* receive the rest of hello message anyway */
 	rc = conn->ksnc_proto->pro_recv_hello(conn, hello, timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading or checking hello from from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0);
@@ -1879,7 +1879,7 @@ ksocknal_connect(ksock_route_t *route)
 		 * route got connected while queued
 		 */
 		if (peer->ksnp_closing || route->ksnr_deleted ||
-		    wanted == 0) {
+		    !wanted) {
 			retry_later = 0;
 			break;
 		}
@@ -1895,14 +1895,14 @@ ksocknal_connect(ksock_route_t *route)
 		if (retry_later) /* needs reschedule */
 			break;
 
-		if ((wanted & (1 << SOCKLND_CONN_ANY)) != 0) {
+		if (wanted & (1 << SOCKLND_CONN_ANY)) {
 			type = SOCKLND_CONN_ANY;
-		} else if ((wanted & (1 << SOCKLND_CONN_CONTROL)) != 0) {
+		} else if (wanted & (1 << SOCKLND_CONN_CONTROL)) {
 			type = SOCKLND_CONN_CONTROL;
-		} else if ((wanted & (1 << SOCKLND_CONN_BULK_IN)) != 0) {
+		} else if (wanted & (1 << SOCKLND_CONN_BULK_IN)) {
 			type = SOCKLND_CONN_BULK_IN;
 		} else {
-			LASSERT((wanted & (1 << SOCKLND_CONN_BULK_OUT)) != 0);
+			LASSERT(wanted & (1 << SOCKLND_CONN_BULK_OUT));
 			type = SOCKLND_CONN_BULK_OUT;
 		}
 
@@ -1919,7 +1919,7 @@ ksocknal_connect(ksock_route_t *route)
 		rc = lnet_connect(&sock, peer->ksnp_id.nid,
 				  route->ksnr_myipaddr,
 				  route->ksnr_ipaddr, route->ksnr_port);
-		if (rc != 0)
+		if (rc)
 			goto failed;
 
 		rc = ksocknal_create_conn(peer->ksnp_ni, route, sock, type);
@@ -1934,7 +1934,7 @@ ksocknal_connect(ksock_route_t *route)
 		 * A +ve RC means I have to retry because I lost the connection
 		 * race or I have to renegotiate protocol version
 		 */
-		retry_later = (rc != 0);
+		retry_later = (rc);
 		if (retry_later)
 			CDEBUG(D_NET, "peer %s: conn race, retry later.\n",
 			       libcfs_nid2str(peer->ksnp_id.nid));
@@ -1951,7 +1951,7 @@ ksocknal_connect(ksock_route_t *route)
 		 * the peer's incoming connection request
 		 */
 		if (rc == EALREADY ||
-		    (rc == 0 && peer->ksnp_accepting > 0)) {
+		    (!rc && peer->ksnp_accepting > 0)) {
 			/*
 			 * We want to introduce a delay before next
 			 * attempt to connect if we lost conn race,
@@ -1985,12 +1985,12 @@ ksocknal_connect(ksock_route_t *route)
 		min(route->ksnr_retry_interval,
 		    cfs_time_seconds(*ksocknal_tunables.ksnd_max_reconnectms) / 1000);
 
-	LASSERT(route->ksnr_retry_interval != 0);
+	LASSERT(route->ksnr_retry_interval);
 	route->ksnr_timeout = cfs_time_add(cfs_time_current(),
 					   route->ksnr_retry_interval);
 
 	if (!list_empty(&peer->ksnp_tx_queue) &&
-	    peer->ksnp_accepting == 0 &&
+	    !peer->ksnp_accepting &&
 	    !ksocknal_find_connecting_route_locked(peer)) {
 		ksock_conn_t *conn;
 
@@ -2078,7 +2078,7 @@ ksocknal_connd_check_start(time64_t sec, long *timeout)
 	rc = ksocknal_thread_start(ksocknal_connd, NULL, name);
 
 	spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
-	if (rc == 0)
+	if (!rc)
 		return 1;
 
 	/* we tried ... */
@@ -2145,7 +2145,7 @@ ksocknal_connd_get_route_locked(signed long *timeout_p)
 	/* connd_routes can contain both pending and ordinary routes */
 	list_for_each_entry(route, &ksocknal_data.ksnd_connd_routes,
 			    ksnr_connd_list) {
-		if (route->ksnr_retry_interval == 0 ||
+		if (!route->ksnr_retry_interval ||
 		    cfs_time_aftereq(now, route->ksnr_timeout))
 			return route;
 
@@ -2290,7 +2290,7 @@ ksocknal_find_timed_out_conn(ksock_peer_t *peer)
 		 * some platform (like Darwin8.x)
 		 */
 		error = conn->ksnc_sock->sk->sk_err;
-		if (error != 0) {
+		if (error) {
 			ksocknal_conn_addref(conn);
 
 			switch (error) {
@@ -2334,7 +2334,7 @@ ksocknal_find_timed_out_conn(ksock_peer_t *peer)
 		}
 
 		if ((!list_empty(&conn->ksnc_tx_queue) ||
-		     conn->ksnc_sock->sk->sk_wmem_queued != 0) &&
+		     conn->ksnc_sock->sk->sk_wmem_queued) &&
 		    cfs_time_aftereq(cfs_time_current(),
 				     conn->ksnc_tx_deadline)) {
 			/*
@@ -2429,7 +2429,7 @@ ksocknal_send_keepalive_locked(ksock_peer_t *peer)
 		return -ENOMEM;
 	}
 
-	if (ksocknal_launch_packet(peer->ksnp_ni, tx, peer->ksnp_id) == 0) {
+	if (!ksocknal_launch_packet(peer->ksnp_ni, tx, peer->ksnp_id)) {
 		read_lock(&ksocknal_data.ksnd_global_lock);
 		return 1;
 	}
@@ -2461,7 +2461,7 @@ ksocknal_check_peer_timeouts(int idx)
 		int resid = 0;
 		int n = 0;
 
-		if (ksocknal_send_keepalive_locked(peer) != 0) {
+		if (ksocknal_send_keepalive_locked(peer)) {
 			read_unlock(&ksocknal_data.ksnd_global_lock);
 			goto again;
 		}
@@ -2516,7 +2516,7 @@ ksocknal_check_peer_timeouts(int idx)
 			n++;
 		}
 
-		if (n == 0) {
+		if (!n) {
 			spin_unlock(&peer->ksnp_lock);
 			continue;
 		}
@@ -2639,7 +2639,7 @@ ksocknal_reaper(void *arg)
 			if (*ksocknal_tunables.ksnd_timeout > n * p)
 				chunk = (chunk * n * p) /
 					*ksocknal_tunables.ksnd_timeout;
-			if (chunk == 0)
+			if (!chunk)
 				chunk = 1;
 
 			for (i = 0; i < chunk; i++) {
@@ -2651,7 +2651,7 @@ ksocknal_reaper(void *arg)
 			deadline = cfs_time_add(deadline, cfs_time_seconds(p));
 		}
 
-		if (nenomem_conns != 0) {
+		if (nenomem_conns) {
 			/*
 			 * Reduce my timeout if I rescheduled ENOMEM conns.
 			 * This also prevents me getting woken immediately
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 40ce45d..3e1f24e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -45,13 +45,13 @@ ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
 	/* Didn't need the {get,put}connsock dance to deref ksnc_sock... */
 	LASSERT(!conn->ksnc_closing);
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d getting sock peer IP\n", rc);
 		return rc;
 	}
 
 	rc = lnet_sock_getaddr(conn->ksnc_sock, 0, &conn->ksnc_myipaddr, NULL);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d getting sock local IP\n", rc);
 		return rc;
 	}
@@ -71,7 +71,7 @@ ksocknal_lib_zc_capable(ksock_conn_t *conn)
 	 * ZC if the socket supports scatter/gather and doesn't need software
 	 * checksums
 	 */
-	return ((caps & NETIF_F_SG) != 0 && (caps & NETIF_F_CSUM_MASK) != 0);
+	return ((caps & NETIF_F_SG) && (caps & NETIF_F_CSUM_MASK));
 }
 
 int
@@ -84,7 +84,7 @@ ksocknal_lib_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
 	if (*ksocknal_tunables.ksnd_enable_csum	&& /* checksum enabled */
 	    conn->ksnc_proto == &ksocknal_protocol_v2x && /* V2.x connection  */
 	    tx->tx_nob == tx->tx_resid		 && /* frist sending    */
-	    tx->tx_msg.ksm_csum == 0)		     /* not checksummed  */
+	    !tx->tx_msg.ksm_csum)		     /* not checksummed  */
 		ksocknal_lib_csum_tx(tx);
 
 	/*
@@ -132,7 +132,7 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 	 * NB we can't trust socket ops to either consume our iovs
 	 * or leave them alone.
 	 */
-	if (tx->tx_msg.ksm_zc_cookies[0] != 0) {
+	if (tx->tx_msg.ksm_zc_cookies[0]) {
 		/* Zero copy is enabled */
 		struct sock *sk = sock->sk;
 		struct page *page = kiov->kiov_page;
@@ -245,7 +245,7 @@ ksocknal_lib_recv_iov(ksock_conn_t *conn)
 		conn->ksnc_msg.ksm_csum = 0;
 	}
 
-	if (saved_csum != 0) {
+	if (saved_csum) {
 		/* accumulate checksum */
 		for (i = 0, sum = rc; sum > 0; i++, sum -= fragnob) {
 			LASSERT(i < niov);
@@ -290,7 +290,7 @@ ksocknal_lib_kiov_vmap(lnet_kiov_t *kiov, int niov,
 		return NULL;
 
 	for (nob = i = 0; i < niov; i++) {
-		if ((kiov[i].kiov_offset != 0 && i > 0) ||
+		if ((kiov[i].kiov_offset && i > 0) ||
 		    (kiov[i].kiov_offset + kiov[i].kiov_len != PAGE_CACHE_SIZE && i < niov - 1))
 			return NULL;
 
@@ -360,7 +360,7 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 	rc = kernel_recvmsg(conn->ksnc_sock, &msg, (struct kvec *)scratchiov,
 			    n, nob, MSG_DONTWAIT);
 
-	if (conn->ksnc_msg.ksm_csum != 0) {
+	if (conn->ksnc_msg.ksm_csum) {
 		for (i = 0, sum = rc; sum > 0; i++, sum -= fragnob) {
 			LASSERT(i < niov);
 
@@ -439,14 +439,14 @@ ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem, int *rxmem, int *
 	int rc;
 
 	rc = ksocknal_connsock_addref(conn);
-	if (rc != 0) {
+	if (rc) {
 		LASSERT(conn->ksnc_closing);
 		*txmem = *rxmem = *nagle = 0;
 		return -ESHUTDOWN;
 	}
 
 	rc = lnet_sock_getbuf(sock, txmem, rxmem);
-	if (rc == 0) {
+	if (!rc) {
 		len = sizeof(*nagle);
 		rc = kernel_getsockopt(sock, SOL_TCP, TCP_NODELAY,
 				       (char *)nagle, &len);
@@ -454,7 +454,7 @@ ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem, int *rxmem, int *
 
 	ksocknal_connsock_decref(conn);
 
-	if (rc == 0)
+	if (!rc)
 		*nagle = !*nagle;
 	else
 		*txmem = *rxmem = *nagle = 0;
@@ -484,7 +484,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 
 	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_LINGER, (char *)&linger,
 			       sizeof(linger));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set SO_LINGER: %d\n", rc);
 		return rc;
 	}
@@ -492,7 +492,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 	option = -1;
 	rc = kernel_setsockopt(sock, SOL_TCP, TCP_LINGER2, (char *)&option,
 			       sizeof(option));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set SO_LINGER2: %d\n", rc);
 		return rc;
 	}
@@ -502,7 +502,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 
 		rc = kernel_setsockopt(sock, SOL_TCP, TCP_NODELAY,
 				       (char *)&option, sizeof(option));
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't disable nagle: %d\n", rc);
 			return rc;
 		}
@@ -510,7 +510,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 
 	rc = lnet_sock_setbuf(sock, *ksocknal_tunables.ksnd_tx_buffer_size,
 			      *ksocknal_tunables.ksnd_rx_buffer_size);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set buffer tx %d, rx %d buffers: %d\n",
 		       *ksocknal_tunables.ksnd_tx_buffer_size,
 		       *ksocknal_tunables.ksnd_rx_buffer_size, rc);
@@ -529,7 +529,7 @@ ksocknal_lib_setup_sock(struct socket *sock)
 	option = (do_keepalive ? 1 : 0);
 	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, (char *)&option,
 			       sizeof(option));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set SO_KEEPALIVE: %d\n", rc);
 		return rc;
 	}
@@ -539,21 +539,21 @@ ksocknal_lib_setup_sock(struct socket *sock)
 
 	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPIDLE, (char *)&keep_idle,
 			       sizeof(keep_idle));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set TCP_KEEPIDLE: %d\n", rc);
 		return rc;
 	}
 
 	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPINTVL,
 			       (char *)&keep_intvl, sizeof(keep_intvl));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set TCP_KEEPINTVL: %d\n", rc);
 		return rc;
 	}
 
 	rc = kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT, (char *)&keep_count,
 			       sizeof(keep_count));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set TCP_KEEPCNT: %d\n", rc);
 		return rc;
 	}
@@ -571,7 +571,7 @@ ksocknal_lib_push_conn(ksock_conn_t *conn)
 	int rc;
 
 	rc = ksocknal_connsock_addref(conn);
-	if (rc != 0)			    /* being shut down */
+	if (rc)			    /* being shut down */
 		return;
 
 	sk = conn->ksnc_sock->sk;
@@ -584,7 +584,7 @@ ksocknal_lib_push_conn(ksock_conn_t *conn)
 
 	rc = kernel_setsockopt(conn->ksnc_sock, SOL_TCP, TCP_NODELAY,
 			       (char *)&val, sizeof(val));
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	lock_sock(sk);
 	tp->nonagle = nonagle;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index d504685..70910ed 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -103,7 +103,7 @@ ksocknal_queue_tx_zcack_v2(ksock_conn_t *conn,
 	}
 
 	LASSERT(tx->tx_msg.ksm_type == KSOCK_MSG_LNET);
-	LASSERT(tx->tx_msg.ksm_zc_cookies[1] == 0);
+	LASSERT(!tx->tx_msg.ksm_zc_cookies[1]);
 
 	if (tx_ack)
 		cookie = tx_ack->tx_msg.ksm_zc_cookies[1];
@@ -185,7 +185,7 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 
 	if (tx->tx_msg.ksm_zc_cookies[1] == SOCKNAL_KEEPALIVE_PING) {
 		/* replace the keepalive PING with a real ACK */
-		LASSERT(tx->tx_msg.ksm_zc_cookies[0] == 0);
+		LASSERT(!tx->tx_msg.ksm_zc_cookies[0]);
 		tx->tx_msg.ksm_zc_cookies[1] = cookie;
 		return 1;
 	}
@@ -197,7 +197,7 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 		return 1; /* XXX return error in the future */
 	}
 
-	if (tx->tx_msg.ksm_zc_cookies[0] == 0) {
+	if (!tx->tx_msg.ksm_zc_cookies[0]) {
 		/* NOOP tx has only one ZC-ACK cookie, can carry at least one more */
 		if (tx->tx_msg.ksm_zc_cookies[1] > cookie) {
 			tx->tx_msg.ksm_zc_cookies[0] = tx->tx_msg.ksm_zc_cookies[1];
@@ -233,7 +233,7 @@ ksocknal_queue_tx_zcack_v3(ksock_conn_t *conn,
 			tmp = tx->tx_msg.ksm_zc_cookies[0];
 		}
 
-		if (tmp != 0) {
+		if (tmp) {
 			/* range of cookies */
 			tx->tx_msg.ksm_zc_cookies[0] = tmp - 1;
 			tx->tx_msg.ksm_zc_cookies[1] = tmp + 1;
@@ -394,7 +394,7 @@ ksocknal_handle_zcreq(ksock_conn_t *c, __u64 cookie, int remote)
 		return -ENOMEM;
 
 	rc = ksocknal_launch_packet(peer->ksnp_ni, tx, peer->ksnp_id);
-	if (rc == 0)
+	if (!rc)
 		return 0;
 
 	ksocknal_free_tx(tx);
@@ -411,7 +411,7 @@ ksocknal_handle_zcack(ksock_conn_t *conn, __u64 cookie1, __u64 cookie2)
 	LIST_HEAD(zlist);
 	int count;
 
-	if (cookie1 == 0)
+	if (!cookie1)
 		cookie1 = cookie2;
 
 	count = (cookie1 > cookie2) ? 2 : (cookie2 - cookie1 + 1);
@@ -433,7 +433,7 @@ ksocknal_handle_zcack(ksock_conn_t *conn, __u64 cookie1, __u64 cookie2)
 			list_del(&tx->tx_zc_list);
 			list_add(&tx->tx_zc_list, &zlist);
 
-			if (--count == 0)
+			if (!--count)
 				break;
 		}
 	}
@@ -446,7 +446,7 @@ ksocknal_handle_zcack(ksock_conn_t *conn, __u64 cookie1, __u64 cookie2)
 		ksocknal_tx_decref(tx);
 	}
 
-	return count == 0 ? 0 : -EPROTO;
+	return !count ? 0 : -EPROTO;
 }
 
 static int
@@ -476,14 +476,14 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	hmv->version_major = cpu_to_le16(KSOCK_PROTO_V1_MAJOR);
 	hmv->version_minor = cpu_to_le16(KSOCK_PROTO_V1_MINOR);
 
-	if (the_lnet.ln_testprotocompat != 0) {
+	if (the_lnet.ln_testprotocompat) {
 		/* single-shot proto check */
 		LNET_LOCK();
-		if ((the_lnet.ln_testprotocompat & 1) != 0) {
+		if (the_lnet.ln_testprotocompat & 1) {
 			hmv->version_major++;   /* just different! */
 			the_lnet.ln_testprotocompat &= ~1;
 		}
-		if ((the_lnet.ln_testprotocompat & 2) != 0) {
+		if (the_lnet.ln_testprotocompat & 2) {
 			hmv->magic = LNET_PROTO_MAGIC;
 			the_lnet.ln_testprotocompat &= ~2;
 		}
@@ -498,13 +498,13 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	hdr->msg.hello.incarnation = cpu_to_le64(hello->kshm_src_incarnation);
 
 	rc = lnet_sock_write(sock, hdr, sizeof(*hdr), lnet_acceptor_timeout());
-	if (rc != 0) {
+	if (rc) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
 			rc, &conn->ksnc_ipaddr, conn->ksnc_port);
 		goto out;
 	}
 
-	if (hello->kshm_nips == 0)
+	if (!hello->kshm_nips)
 		goto out;
 
 	for (i = 0; i < (int) hello->kshm_nips; i++)
@@ -513,7 +513,7 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	rc = lnet_sock_write(sock, hello->kshm_ips,
 			     hello->kshm_nips * sizeof(__u32),
 			     lnet_acceptor_timeout());
-	if (rc != 0) {
+	if (rc) {
 		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
 			rc, hello->kshm_nips,
 			&conn->ksnc_ipaddr, conn->ksnc_port);
@@ -533,10 +533,10 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	hello->kshm_magic   = LNET_PROTO_MAGIC;
 	hello->kshm_version = conn->ksnc_proto->pro_version;
 
-	if (the_lnet.ln_testprotocompat != 0) {
+	if (the_lnet.ln_testprotocompat) {
 		/* single-shot proto check */
 		LNET_LOCK();
-		if ((the_lnet.ln_testprotocompat & 1) != 0) {
+		if (the_lnet.ln_testprotocompat & 1) {
 			hello->kshm_version++;   /* just different! */
 			the_lnet.ln_testprotocompat &= ~1;
 		}
@@ -545,19 +545,19 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 
 	rc = lnet_sock_write(sock, hello, offsetof(ksock_hello_msg_t, kshm_ips),
 			     lnet_acceptor_timeout());
-	if (rc != 0) {
+	if (rc) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
 			rc, &conn->ksnc_ipaddr, conn->ksnc_port);
 		return rc;
 	}
 
-	if (hello->kshm_nips == 0)
+	if (!hello->kshm_nips)
 		return 0;
 
 	rc = lnet_sock_write(sock, hello->kshm_ips,
 			     hello->kshm_nips * sizeof(__u32),
 			     lnet_acceptor_timeout());
-	if (rc != 0) {
+	if (rc) {
 		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
 			rc, hello->kshm_nips,
 			&conn->ksnc_ipaddr, conn->ksnc_port);
@@ -584,7 +584,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 	rc = lnet_sock_read(sock, &hdr->src_nid,
 			    sizeof(*hdr) - offsetof(lnet_hdr_t, src_nid),
 			    timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading rest of HELLO hdr from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
@@ -614,12 +614,12 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 		goto out;
 	}
 
-	if (hello->kshm_nips == 0)
+	if (!hello->kshm_nips)
 		goto out;
 
 	rc = lnet_sock_read(sock, hello->kshm_ips,
 			    hello->kshm_nips * sizeof(__u32), timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
@@ -629,7 +629,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 	for (i = 0; i < (int) hello->kshm_nips; i++) {
 		hello->kshm_ips[i] = __le32_to_cpu(hello->kshm_ips[i]);
 
-		if (hello->kshm_ips[i] == 0) {
+		if (!hello->kshm_ips[i]) {
 			CERROR("Zero IP[%d] from ip %pI4h\n",
 			       i, &conn->ksnc_ipaddr);
 			rc = -EPROTO;
@@ -658,7 +658,7 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 			    offsetof(ksock_hello_msg_t, kshm_ips) -
 				     offsetof(ksock_hello_msg_t, kshm_src_nid),
 			    timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
@@ -682,12 +682,12 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 		return -EPROTO;
 	}
 
-	if (hello->kshm_nips == 0)
+	if (!hello->kshm_nips)
 		return 0;
 
 	rc = lnet_sock_read(sock, hello->kshm_ips,
 			    hello->kshm_nips * sizeof(__u32), timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
 		LASSERT(rc < 0 && rc != -EALREADY);
@@ -698,7 +698,7 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 		if (conn->ksnc_flip)
 			__swab32s(&hello->kshm_ips[i]);
 
-		if (hello->kshm_ips[i] == 0) {
+		if (!hello->kshm_ips[i]) {
 			CERROR("Zero IP[%d] from ip %pI4h\n",
 			       i, &conn->ksnc_ipaddr);
 			return -EPROTO;
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index ef61eaf..e5f24ff 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -159,7 +159,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 
 		rc = lnet_sock_connect(&sock, &fatal, local_ip, port, peer_ip,
 				       peer_port);
-		if (rc != 0) {
+		if (rc) {
 			if (fatal)
 				goto failed;
 			continue;
@@ -171,14 +171,14 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
 		cr.acr_nid     = peer_nid;
 
-		if (the_lnet.ln_testprotocompat != 0) {
+		if (the_lnet.ln_testprotocompat) {
 			/* single-shot proto check */
 			lnet_net_lock(LNET_LOCK_EX);
-			if ((the_lnet.ln_testprotocompat & 4) != 0) {
+			if (the_lnet.ln_testprotocompat & 4) {
 				cr.acr_version++;
 				the_lnet.ln_testprotocompat &= ~4;
 			}
-			if ((the_lnet.ln_testprotocompat & 8) != 0) {
+			if (the_lnet.ln_testprotocompat & 8) {
 				cr.acr_magic = LNET_PROTO_MAGIC;
 				the_lnet.ln_testprotocompat &= ~8;
 			}
@@ -186,7 +186,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 		}
 
 		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
-		if (rc != 0)
+		if (rc)
 			goto failed_sock;
 
 		*sockp = sock;
@@ -220,7 +220,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 	LASSERT(sizeof(cr) <= 16);	     /* not too big for the stack */
 
 	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
-	LASSERT(rc == 0);		      /* we succeeded before */
+	LASSERT(!rc);		      /* we succeeded before */
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
 		if (lnet_accept_magic(magic, LNET_PROTO_MAGIC)) {
@@ -236,7 +236,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 			rc = lnet_sock_write(sock, &cr, sizeof(cr),
 					     accept_timeout);
 
-			if (rc != 0)
+			if (rc)
 				CERROR("Error sending magic+version in response to LNET magic from %pI4h: %d\n",
 				       &peer_ip, rc);
 			return -EPROTO;
@@ -256,7 +256,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 	rc = lnet_sock_read(sock, &cr.acr_version, sizeof(cr.acr_version),
 			    accept_timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading connection request version from %pI4h\n",
 		       rc, &peer_ip);
 		return -EIO;
@@ -279,7 +279,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
 
 		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
-		if (rc != 0)
+		if (rc)
 			CERROR("Error sending magic+version in response to version %d from %pI4h: %d\n",
 			       peer_version, &peer_ip, rc);
 		return -EPROTO;
@@ -289,7 +289,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 			    sizeof(cr) -
 			    offsetof(lnet_acceptor_connreq_t, acr_nid),
 			    accept_timeout);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d reading connection request from %pI4h\n",
 		       rc, &peer_ip);
 		return -EIO;
@@ -341,7 +341,7 @@ lnet_acceptor(void *arg)
 
 	rc = lnet_sock_listen(&lnet_acceptor_state.pta_sock, 0, accept_port,
 			      accept_backlog);
-	if (rc != 0) {
+	if (rc) {
 		if (rc == -EADDRINUSE)
 			LCONSOLE_ERROR_MSG(0x122, "Can't start acceptor on port %d: port already in use\n",
 					   accept_port);
@@ -358,12 +358,12 @@ lnet_acceptor(void *arg)
 	lnet_acceptor_state.pta_shutdown = rc;
 	complete(&lnet_acceptor_state.pta_signal);
 
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	while (!lnet_acceptor_state.pta_shutdown) {
 		rc = lnet_sock_accept(&newsock, lnet_acceptor_state.pta_sock);
-		if (rc != 0) {
+		if (rc) {
 			if (rc != -EAGAIN) {
 				CWARN("Accept error %d: pausing...\n", rc);
 				set_current_state(TASK_UNINTERRUPTIBLE);
@@ -379,7 +379,7 @@ lnet_acceptor(void *arg)
 		}
 
 		rc = lnet_sock_getaddr(newsock, 1, &peer_ip, &peer_port);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't determine new connection's address\n");
 			goto failed;
 		}
@@ -392,14 +392,14 @@ lnet_acceptor(void *arg)
 
 		rc = lnet_sock_read(newsock, &magic, sizeof(magic),
 				    accept_timeout);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Error %d reading connection request from %pI4h\n",
 			       rc, &peer_ip);
 			goto failed;
 		}
 
 		rc = lnet_accept(newsock, magic);
-		if (rc != 0)
+		if (rc)
 			goto failed;
 
 		continue;
@@ -446,7 +446,7 @@ lnet_acceptor_start(void)
 	LASSERT(!lnet_acceptor_state.pta_sock);
 
 	rc = lnet_acceptor_get_tunables();
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	init_completion(&lnet_acceptor_state.pta_signal);
@@ -454,7 +454,7 @@ lnet_acceptor_start(void)
 	if (rc <= 0)
 		return rc;
 
-	if (lnet_count_acceptor_nis() == 0)  /* not required */
+	if (!lnet_count_acceptor_nis())  /* not required */
 		return 0;
 
 	rc2 = PTR_ERR(kthread_run(lnet_acceptor,
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index eb04958..58b30f1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -76,17 +76,17 @@ lnet_get_networks(void)
 	char *nets;
 	int rc;
 
-	if (*networks != 0 && *ip2nets != 0) {
+	if (*networks && *ip2nets) {
 		LCONSOLE_ERROR_MSG(0x101, "Please specify EITHER 'networks' or 'ip2nets' but not both@once\n");
 		return NULL;
 	}
 
-	if (*ip2nets != 0) {
+	if (*ip2nets) {
 		rc = lnet_parse_ip2nets(&nets, ip2nets);
-		return (rc == 0) ? nets : NULL;
+		return !rc ? nets : NULL;
 	}
 
-	if (*networks != 0)
+	if (*networks)
 		return networks;
 
 	return "tcp";
@@ -309,7 +309,7 @@ lnet_unregister_lnd(lnd_t *lnd)
 
 	LASSERT(the_lnet.ln_init);
 	LASSERT(lnet_find_lnd_by_type(lnd->lnd_type) == lnd);
-	LASSERT(lnd->lnd_refcount == 0);
+	LASSERT(!lnd->lnd_refcount);
 
 	list_del(&lnd->lnd_list);
 	CDEBUG(D_NET, "%s LND unregistered\n", libcfs_lnd2str(lnd->lnd_type));
@@ -379,7 +379,7 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 {
 	int count = 0;
 
-	if (rec->rec_type == 0) /* not set yet, it's uninitialized */
+	if (!rec->rec_type) /* not set yet, it's uninitialized */
 		return;
 
 	while (!list_empty(&rec->rec_active)) {
@@ -423,7 +423,7 @@ lnet_res_container_setup(struct lnet_res_container *rec, int cpt, int type)
 	int rc = 0;
 	int i;
 
-	LASSERT(rec->rec_type == 0);
+	LASSERT(!rec->rec_type);
 
 	rec->rec_type = type;
 	INIT_LIST_HEAD(&rec->rec_active);
@@ -478,7 +478,7 @@ lnet_res_containers_create(int type)
 
 	cfs_percpt_for_each(rec, i, recs) {
 		rc = lnet_res_container_setup(rec, i, type);
-		if (rc != 0) {
+		if (rc) {
 			lnet_res_containers_destroy(recs);
 			return NULL;
 		}
@@ -533,11 +533,11 @@ lnet_prepare(lnet_pid_t requested_pid)
 	struct lnet_res_container **recs;
 	int rc = 0;
 
-	LASSERT(the_lnet.ln_refcount == 0);
+	LASSERT(!the_lnet.ln_refcount);
 
 	the_lnet.ln_routing = 0;
 
-	LASSERT((requested_pid & LNET_PID_USERFLAG) == 0);
+	LASSERT(!(requested_pid & LNET_PID_USERFLAG));
 	the_lnet.ln_pid = requested_pid;
 
 	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
@@ -547,7 +547,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
 
 	rc = lnet_create_remote_nets_table();
-	if (rc != 0)
+	if (rc)
 		goto failed;
 	/*
 	 * NB the interface cookie in wire handles guards against delayed
@@ -564,16 +564,16 @@ lnet_prepare(lnet_pid_t requested_pid)
 	}
 
 	rc = lnet_peer_tables_create();
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	rc = lnet_msg_containers_create();
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	rc = lnet_res_container_setup(&the_lnet.ln_eq_container, 0,
 				      LNET_COOKIE_TYPE_EQ);
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME);
@@ -593,7 +593,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	the_lnet.ln_md_containers = recs;
 
 	rc = lnet_portals_create();
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Failed to create portals for LNet: %d\n", rc);
 		goto failed;
 	}
@@ -616,7 +616,7 @@ lnet_unprepare(void)
 	 */
 	lnet_fail_nid(LNET_NID_ANY, 0);
 
-	LASSERT(the_lnet.ln_refcount == 0);
+	LASSERT(!the_lnet.ln_refcount);
 	LASSERT(list_empty(&the_lnet.ln_test_peers));
 	LASSERT(list_empty(&the_lnet.ln_nis));
 	LASSERT(list_empty(&the_lnet.ln_nis_cpt));
@@ -847,7 +847,7 @@ lnet_shutdown_lndnis(void)
 
 	/* All quiet on the API front */
 	LASSERT(!the_lnet.ln_shutdown);
-	LASSERT(the_lnet.ln_refcount == 0);
+	LASSERT(!the_lnet.ln_refcount);
 	LASSERT(list_empty(&the_lnet.ln_nis_zombie));
 
 	lnet_net_lock(LNET_LOCK_EX);
@@ -908,7 +908,7 @@ lnet_shutdown_lndnis(void)
 				lnet_ni_t, ni_list);
 		list_del_init(&ni->ni_list);
 		cfs_percpt_for_each(ref, j, ni->ni_refs) {
-			if (*ref == 0)
+			if (!*ref)
 				continue;
 			/* still busy, add it back to zombie list */
 			list_add(&ni->ni_list, &the_lnet.ln_nis_zombie);
@@ -979,7 +979,7 @@ lnet_startup_lndnis(void)
 		goto failed;
 
 	rc = lnet_parse_networks(&nilist, nets);
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	while (!list_empty(&nilist)) {
@@ -1026,7 +1026,7 @@ lnet_startup_lndnis(void)
 
 		mutex_unlock(&the_lnet.ln_lnd_mutex);
 
-		if (rc != 0) {
+		if (rc) {
 			LCONSOLE_ERROR_MSG(0x105, "Error %d starting up LNI %s\n",
 					   rc, libcfs_lnd2str(lnd->lnd_type));
 			lnet_net_lock(LNET_LOCK_EX);
@@ -1058,11 +1058,10 @@ lnet_startup_lndnis(void)
 			continue;
 		}
 
-		if (ni->ni_peertxcredits == 0 ||
-		    ni->ni_maxtxcredits == 0) {
+		if (!ni->ni_peertxcredits || !ni->ni_maxtxcredits) {
 			LCONSOLE_ERROR_MSG(0x107, "LNI %s has no %scredits\n",
 					   libcfs_lnd2str(lnd->lnd_type),
-					   ni->ni_peertxcredits == 0 ?
+					   !ni->ni_peertxcredits ?
 					   "" : "per-peer ");
 			goto failed;
 		}
@@ -1138,7 +1137,7 @@ lnet_init(void)
 		the_lnet.ln_cpt_bits++;
 
 	rc = lnet_create_locks();
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create LNet global locks: %d\n", rc);
 		return -1;
 	}
@@ -1184,7 +1183,7 @@ void
 lnet_fini(void)
 {
 	LASSERT(the_lnet.ln_init);
-	LASSERT(the_lnet.ln_refcount == 0);
+	LASSERT(!the_lnet.ln_refcount);
 
 	while (!list_empty(&the_lnet.ln_lnds))
 		lnet_unregister_lnd(list_entry(the_lnet.ln_lnds.next,
@@ -1233,27 +1232,27 @@ LNetNIInit(lnet_pid_t requested_pid)
 	}
 
 	rc = lnet_prepare(requested_pid);
-	if (rc != 0)
+	if (rc)
 		goto failed0;
 
 	rc = lnet_startup_lndnis();
-	if (rc != 0)
+	if (rc)
 		goto failed1;
 
 	rc = lnet_parse_routes(lnet_get_routes(), &im_a_router);
-	if (rc != 0)
+	if (rc)
 		goto failed2;
 
 	rc = lnet_check_routes();
-	if (rc != 0)
+	if (rc)
 		goto failed2;
 
 	rc = lnet_rtrpools_alloc(im_a_router);
-	if (rc != 0)
+	if (rc)
 		goto failed2;
 
 	rc = lnet_acceptor_start();
-	if (rc != 0)
+	if (rc)
 		goto failed2;
 
 	the_lnet.ln_refcount = 1;
@@ -1264,11 +1263,11 @@ LNetNIInit(lnet_pid_t requested_pid)
 	 * lnet_router_checker -> lnet_update_ni_status_locked
 	  */
 	rc = lnet_ping_target_init();
-	if (rc != 0)
+	if (rc)
 		goto failed3;
 
 	rc = lnet_router_checker_start();
-	if (rc != 0)
+	if (rc)
 		goto failed4;
 
 	lnet_router_debugfs_init();
@@ -1360,7 +1359,7 @@ LNetCtl(unsigned int cmd, void *arg)
 	case IOC_LIBCFS_ADD_ROUTE:
 		rc = lnet_add_route(data->ioc_net, data->ioc_count,
 				    data->ioc_nid, data->ioc_priority);
-		return (rc != 0) ? rc : lnet_check_routes();
+		return (rc) ? rc : lnet_check_routes();
 
 	case IOC_LIBCFS_DEL_ROUTE:
 		return lnet_del_route(data->ioc_net, data->ioc_nid);
@@ -1445,13 +1444,13 @@ LNetGetId(unsigned int index, lnet_process_id_t *id)
 	LASSERT(the_lnet.ln_init);
 
 	/* LNetNI initilization failed? */
-	if (the_lnet.ln_refcount == 0)
+	if (!the_lnet.ln_refcount)
 		return rc;
 
 	cpt = lnet_net_lock_current();
 
 	list_for_each(tmp, &the_lnet.ln_nis) {
-		if (index-- != 0)
+		if (index--)
 			continue;
 
 		ni = list_entry(tmp, lnet_ni_t, ni_list);
@@ -1494,7 +1493,7 @@ lnet_create_ping_info(void)
 		if (rc == -ENOENT)
 			break;
 
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 	}
 
 	infosz = offsetof(lnet_ping_info_t, pi_ni[n]);
@@ -1513,7 +1512,7 @@ lnet_create_ping_info(void)
 		lnet_ni_status_t *ns = &pinfo->pi_ni[i];
 
 		rc = LNetGetId(i, &id);
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 
 		ns->ns_nid    = id.nid;
 		ns->ns_status = LNET_NI_STATUS_UP;
@@ -1568,7 +1567,7 @@ lnet_ping_target_init(void)
 	int infosz;
 
 	rc = lnet_create_ping_info();
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	/*
@@ -1576,7 +1575,7 @@ lnet_ping_target_init(void)
 	 * teardown, which by definition is the last one!
 	 */
 	rc = LNetEQAlloc(2, LNET_EQ_HANDLER_NONE, &the_lnet.ln_ping_target_eq);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't allocate ping EQ: %d\n", rc);
 		goto failed_0;
 	}
@@ -1589,7 +1588,7 @@ lnet_ping_target_init(void)
 			  LNET_PROTO_PING_MATCHBITS, 0,
 			  LNET_UNLINK, LNET_INS_AFTER,
 			  &meh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create ping ME: %d\n", rc);
 		goto failed_1;
 	}
@@ -1609,7 +1608,7 @@ lnet_ping_target_init(void)
 	rc = LNetMDAttach(meh, md,
 			  LNET_RETAIN,
 			  &the_lnet.ln_ping_target_md);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't attach ping MD: %d\n", rc);
 		goto failed_2;
 	}
@@ -1618,10 +1617,10 @@ lnet_ping_target_init(void)
 
  failed_2:
 	rc2 = LNetMEUnlink(meh);
-	LASSERT(rc2 == 0);
+	LASSERT(!rc2);
  failed_1:
 	rc2 = LNetEQFree(the_lnet.ln_ping_target_eq);
-	LASSERT(rc2 == 0);
+	LASSERT(!rc2);
  failed_0:
 	lnet_destroy_ping_info();
 	return rc;
@@ -1646,7 +1645,7 @@ lnet_ping_target_fini(void)
 		/* I expect overflow... */
 		LASSERT(rc >= 0 || rc == -EOVERFLOW);
 
-		if (rc == 0) {
+		if (!rc) {
 			/* timed out: provide a diagnostic */
 			CWARN("Still waiting for ping MD to unlink\n");
 			timeout_ms *= 2;
@@ -1659,7 +1658,7 @@ lnet_ping_target_fini(void)
 	}
 
 	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 	lnet_destroy_ping_info();
 	cfs_restore_sigs(blocked);
 }
@@ -1699,7 +1698,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 
 	/* NB 2 events max (including any unlink event) */
 	rc = LNetEQAlloc(2, LNET_EQ_HANDLER_NONE, &eqh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't allocate EQ: %d\n", rc);
 		goto out_0;
 	}
@@ -1714,7 +1713,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	md.eq_handle = eqh;
 
 	rc = LNetMDBind(md, LNET_UNLINK, &mdh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't bind MD: %d\n", rc);
 		goto out_1;
 	}
@@ -1723,11 +1722,11 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		     LNET_RESERVED_PORTAL,
 		     LNET_PROTO_PING_MATCHBITS, 0);
 
-	if (rc != 0) {
+	if (rc) {
 		/* Don't CERROR; this could be deliberate! */
 
 		rc2 = LNetMDUnlink(mdh);
-		LASSERT(rc2 == 0);
+		LASSERT(!rc2);
 
 		/* NB must wait for the UNLINK event below... */
 		unlinked = 1;
@@ -1751,11 +1750,11 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 
 		LASSERT(rc2 != -EOVERFLOW);     /* can't miss anything */
 
-		if (rc2 <= 0 || event.status != 0) {
+		if (rc2 <= 0 || event.status) {
 			/* timeout or error */
-			if (!replied && rc == 0)
+			if (!replied && !rc)
 				rc = (rc2 < 0) ? rc2 :
-				     (rc2 == 0) ? -ETIMEDOUT :
+				     !rc2 ? -ETIMEDOUT :
 				     event.status;
 
 			if (!unlinked) {
@@ -1764,7 +1763,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 				/* No assertion (racing with network) */
 				unlinked = 1;
 				timeout_ms = a_long_time;
-			} else if (rc2 == 0) {
+			} else if (!rc2) {
 				/* timed out waiting for unlink */
 				CWARN("ping %s: late network completion\n",
 				      libcfs_id2str(id));
@@ -1804,7 +1803,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		goto out_1;
 	}
 
-	if ((info->pi_features & LNET_PING_FEAT_NI_STATUS) == 0) {
+	if (!(info->pi_features & LNET_PING_FEAT_NI_STATUS)) {
 		CERROR("%s: ping w/o NI status: 0x%x\n",
 		       libcfs_id2str(id), info->pi_features);
 		goto out_1;
@@ -1838,9 +1837,9 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 
  out_1:
 	rc2 = LNetEQFree(eqh);
-	if (rc2 != 0)
+	if (rc2)
 		CERROR("rc2 %d\n", rc2);
-	LASSERT(rc2 == 0);
+	LASSERT(!rc2);
 
  out_0:
 	LIBCFS_FREE(info, infosz);
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index fcd2cfb..e817eb3 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -210,7 +210,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	if (!ni)
 		goto failed;
 
-	while (str && *str != 0) {
+	while (str && *str) {
 		char *comma = strchr(str, ',');
 		char *bracket = strchr(str, '(');
 		char *square = strchr(str, '[');
@@ -240,7 +240,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 
 			rc = cfs_expr_list_parse(square, tmp - square + 1,
 						 0, LNET_CPT_NUMBER - 1, &el);
-			if (rc != 0) {
+			if (rc) {
 				tmp = square;
 				goto failed_syntax;
 			}
@@ -309,7 +309,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 				*comma++ = 0;
 
 			iface = cfs_trimwhite(iface);
-			if (*iface == 0) {
+			if (!*iface) {
 				tmp = iface;
 				goto failed_syntax;
 			}
@@ -330,7 +330,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		if (comma) {
 			*comma = 0;
 			str = cfs_trimwhite(str);
-			if (*str != 0) {
+			if (*str) {
 				tmp = str;
 				goto failed_syntax;
 			}
@@ -339,7 +339,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		}
 
 		str = cfs_trimwhite(str);
-		if (*str != 0) {
+		if (*str) {
 			tmp = str;
 			goto failed_syntax;
 		}
@@ -434,7 +434,7 @@ lnet_str2tbs_sep(struct list_head *tbs, char *str)
 			str++;
 
 		/* scan for separator or comment */
-		for (sep = str; *sep != 0; sep++)
+		for (sep = str; *sep; sep++)
 			if (lnet_issep(*sep) || *sep == '#')
 				break;
 
@@ -461,10 +461,10 @@ lnet_str2tbs_sep(struct list_head *tbs, char *str)
 			/* scan for separator */
 			do {
 				sep++;
-			} while (*sep != 0 && !lnet_issep(*sep));
+			} while (*sep && !lnet_issep(*sep));
 		}
 
-		if (*sep == 0)
+		if (!*sep)
 			break;
 
 		str = sep + 1;
@@ -539,7 +539,7 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 				/* simple string enumeration */
 				if (lnet_expand1tb(&pending, str, sep, sep2,
 						   parsed,
-						   (int)(enditem - parsed)) != 0) {
+						   (int)(enditem - parsed))) {
 					goto failed;
 				}
 				continue;
@@ -554,7 +554,7 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 			goto failed;
 
 		if (hi < 0 || lo < 0 || stride < 0 || hi < lo ||
-		    (hi - lo) % stride != 0)
+		    (hi - lo) % stride)
 			goto failed;
 
 		for (i = lo; i <= hi; i += stride) {
@@ -564,7 +564,7 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 				goto failed;
 
 			if (lnet_expand1tb(&pending, str, sep, sep2,
-					   num, nob) != 0)
+					   num, nob))
 				goto failed;
 		}
 	}
@@ -656,7 +656,7 @@ lnet_parse_route(char *str, int *im_a_router)
 		/* scan for token start */
 		while (isspace(*sep))
 			sep++;
-		if (*sep == 0) {
+		if (!*sep) {
 			if (ntokens < (got_hops ? 3 : 2))
 				goto token_error;
 			break;
@@ -666,9 +666,9 @@ lnet_parse_route(char *str, int *im_a_router)
 		token = sep++;
 
 		/* scan for token end */
-		while (*sep != 0 && !isspace(*sep))
+		while (*sep && !isspace(*sep))
 			sep++;
-		if (*sep != 0)
+		if (*sep)
 			*sep++ = 0;
 
 		if (ntokens == 1) {
@@ -745,7 +745,7 @@ lnet_parse_route(char *str, int *im_a_router)
 			}
 
 			rc = lnet_add_route(net, hops, nid, priority);
-			if (rc != 0) {
+			if (rc) {
 				CERROR("Can't create route to %s via %s\n",
 				       libcfs_net2str(net),
 				       libcfs_nid2str(nid));
@@ -802,7 +802,7 @@ lnet_parse_routes(char *routes, int *im_a_router)
 		rc = lnet_parse_route_tbs(&tbs, im_a_router);
 	}
 
-	LASSERT(lnet_tbnob == 0);
+	LASSERT(!lnet_tbnob);
 	return rc;
 }
 
@@ -814,7 +814,7 @@ lnet_match_network_token(char *token, int len, __u32 *ipaddrs, int nip)
 	int i;
 
 	rc = cfs_ip_addr_parse(token, len, &list);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	for (rc = i = 0; !rc && i < nip; i++)
@@ -847,18 +847,18 @@ lnet_match_network_tokens(char *net_entry, __u32 *ipaddrs, int nip)
 		/* scan for token start */
 		while (isspace(*sep))
 			sep++;
-		if (*sep == 0)
+		if (!*sep)
 			break;
 
 		token = sep++;
 
 		/* scan for token end */
-		while (*sep != 0 && !isspace(*sep))
+		while (*sep && !isspace(*sep))
 			sep++;
-		if (*sep != 0)
+		if (*sep)
 			*sep++ = 0;
 
-		if (ntokens++ == 0) {
+		if (!ntokens++) {
 			net = token;
 			continue;
 		}
@@ -872,7 +872,8 @@ lnet_match_network_tokens(char *net_entry, __u32 *ipaddrs, int nip)
 			return rc;
 		}
 
-		matched |= (rc != 0);
+		if (rc)
+			matched |= 1;
 	}
 
 	if (!matched)
@@ -930,12 +931,12 @@ lnet_splitnets(char *source, struct list_head *nets)
 			bracket = strchr(bracket + 1, ')');
 
 			if (!bracket ||
-			    !(bracket[1] == ',' || bracket[1] == 0)) {
+			    !(bracket[1] == ',' || !bracket[1])) {
 				lnet_syntax("ip2nets", source, offset2, len);
 				return -EINVAL;
 			}
 
-			sep = (bracket[1] == 0) ? NULL : bracket + 1;
+			sep = !bracket[1] ? NULL : bracket + 1;
 		}
 
 		if (sep)
@@ -1002,7 +1003,7 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 	INIT_LIST_HEAD(&raw_entries);
 	if (lnet_str2tbs_sep(&raw_entries, ip2nets) < 0) {
 		CERROR("Error parsing ip2nets\n");
-		LASSERT(lnet_tbnob == 0);
+		LASSERT(!lnet_tbnob);
 		return -EINVAL;
 	}
 
@@ -1026,7 +1027,7 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 
 		list_del(&tb->ltb_list);
 
-		if (rc == 0) {		  /* no match */
+		if (!rc) {		  /* no match */
 			lnet_free_text_buf(tb);
 			continue;
 		}
@@ -1072,7 +1073,7 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 			list_add_tail(&tb->ltb_list, &matched_nets);
 
 			len += snprintf(networks + len, sizeof(networks) - len,
-					"%s%s", (len == 0) ? "" : ",",
+					"%s%s", !len ? "" : ",",
 					tb->ltb_text);
 
 			if (len >= sizeof(networks)) {
@@ -1089,7 +1090,7 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 	lnet_free_text_bufs(&raw_entries);
 	lnet_free_text_bufs(&matched_nets);
 	lnet_free_text_bufs(&current_nets);
-	LASSERT(lnet_tbnob == 0);
+	LASSERT(!lnet_tbnob);
 
 	if (rc < 0)
 		return rc;
@@ -1126,7 +1127,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 			continue;
 
 		rc = lnet_ipif_query(ifnames[i], &up, &ipaddrs[nip], &netmask);
-		if (rc != 0) {
+		if (rc) {
 			CWARN("Can't query interface %s: %d\n",
 			      ifnames[i], rc);
 			continue;
@@ -1177,7 +1178,7 @@ lnet_parse_ip2nets(char **networksp, char *ip2nets)
 		return nip;
 	}
 
-	if (nip == 0) {
+	if (!nip) {
 		LCONSOLE_ERROR_MSG(0x118,
 				   "No local IP interfaces for ip2nets to match\n");
 		return -ENOENT;
@@ -1191,7 +1192,7 @@ lnet_parse_ip2nets(char **networksp, char *ip2nets)
 		return rc;
 	}
 
-	if (rc == 0) {
+	if (!rc) {
 		LCONSOLE_ERROR_MSG(0x11a,
 				   "ip2nets does not match any local IP interfaces\n");
 		return -ENOENT;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 34012e9..b8f248e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -83,21 +83,21 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	if (count)
 		count = roundup_pow_of_two(count);
 
-	if (callback != LNET_EQ_HANDLER_NONE && count != 0)
+	if (callback != LNET_EQ_HANDLER_NONE && count)
 		CWARN("EQ callback is guaranteed to get every event, do you still want to set eqcount %d for polling event which will have locking overhead? Please contact with developer to confirm\n", count);
 
 	/*
 	 * count can be 0 if only need callback, we can eliminate
 	 * overhead of enqueue event
 	 */
-	if (count == 0 && callback == LNET_EQ_HANDLER_NONE)
+	if (!count && callback == LNET_EQ_HANDLER_NONE)
 		return -EINVAL;
 
 	eq = lnet_eq_alloc();
 	if (!eq)
 		return -ENOMEM;
 
-	if (count != 0) {
+	if (count) {
 		LIBCFS_ALLOC(eq->eq_events, count * sizeof(lnet_event_t));
 		if (!eq->eq_events)
 			goto failed;
@@ -185,7 +185,7 @@ LNetEQFree(lnet_handle_eq_t eqh)
 
 	cfs_percpt_for_each(ref, i, eq->eq_refs) {
 		LASSERT(*ref >= 0);
-		if (*ref == 0)
+		if (!*ref)
 			continue;
 
 		CDEBUG(D_NET, "Event equeue (%d: %d) busy on destroy.\n",
@@ -221,7 +221,7 @@ lnet_eq_enqueue_event(lnet_eq_t *eq, lnet_event_t *ev)
 	/* MUST called with resource lock hold but w/o lnet_eq_wait_lock */
 	int index;
 
-	if (eq->eq_size == 0) {
+	if (!eq->eq_size) {
 		LASSERT(eq->eq_callback != LNET_EQ_HANDLER_NONE);
 		eq->eq_callback(ev);
 		return;
@@ -321,7 +321,7 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
 	wait_queue_t wl;
 	unsigned long now;
 
-	if (tms == 0)
+	if (!tms)
 		return -1; /* don't want to wait and no new event */
 
 	init_waitqueue_entry(&wl, current);
@@ -340,7 +340,7 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
 			tms = 0;
 	}
 
-	wait = tms != 0; /* might need to call here again */
+	wait = tms; /* might need to call here again */
 	*timeout_ms = tms;
 
 	lnet_eq_wait_lock();
@@ -401,14 +401,14 @@ LNetEQPoll(lnet_handle_eq_t *eventqs, int neq, int timeout_ms,
 			}
 
 			rc = lnet_eq_dequeue_event(eq, event);
-			if (rc != 0) {
+			if (rc) {
 				lnet_eq_wait_unlock();
 				*which = i;
 				return rc;
 			}
 		}
 
-		if (wait == 0)
+		if (!wait)
 			break;
 
 		/*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 490edfb..f26bb03 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -46,7 +46,7 @@
 void
 lnet_md_unlink(lnet_libmd_t *md)
 {
-	if ((md->md_flags & LNET_MD_FLAG_ZOMBIE) == 0) {
+	if (!(md->md_flags & LNET_MD_FLAG_ZOMBIE)) {
 		/* first unlink attempt... */
 		lnet_me_t *me = md->md_me;
 
@@ -68,7 +68,7 @@ lnet_md_unlink(lnet_libmd_t *md)
 		lnet_res_lh_invalidate(&md->md_lh);
 	}
 
-	if (md->md_refcount != 0) {
+	if (md->md_refcount) {
 		CDEBUG(D_NET, "Queueing unlink of md %p\n", md);
 		return;
 	}
@@ -105,8 +105,8 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 	lmd->md_refcount = 0;
 	lmd->md_flags = (unlink == LNET_UNLINK) ? LNET_MD_FLAG_AUTO_UNLINK : 0;
 
-	if ((umd->options & LNET_MD_IOVEC) != 0) {
-		if ((umd->options & LNET_MD_KIOV) != 0) /* Can't specify both */
+	if (umd->options & LNET_MD_IOVEC) {
+		if (umd->options & LNET_MD_KIOV) /* Can't specify both */
 			return -EINVAL;
 
 		niov = umd->length;
@@ -125,12 +125,12 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 
 		lmd->md_length = total_length;
 
-		if ((umd->options & LNET_MD_MAX_SIZE) != 0 && /* use max size */
+		if ((umd->options & LNET_MD_MAX_SIZE) && /* use max size */
 		    (umd->max_size < 0 ||
 		     umd->max_size > total_length)) /* illegal max_size */
 			return -EINVAL;
 
-	} else if ((umd->options & LNET_MD_KIOV) != 0) {
+	} else if (umd->options & LNET_MD_KIOV) {
 		niov = umd->length;
 		lmd->md_niov = umd->length;
 		memcpy(lmd->md_iov.kiov, umd->start,
@@ -147,7 +147,7 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 
 		lmd->md_length = total_length;
 
-		if ((umd->options & LNET_MD_MAX_SIZE) != 0 && /* max size used */
+		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
 		     umd->max_size > total_length)) /* illegal max_size */
 			return -EINVAL;
@@ -158,7 +158,7 @@ lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
 		lmd->md_iov.iov[0].iov_base = umd->start;
 		lmd->md_iov.iov[0].iov_len = umd->length;
 
-		if ((umd->options & LNET_MD_MAX_SIZE) != 0 && /* max size used */
+		if ((umd->options & LNET_MD_MAX_SIZE) && /* max size used */
 		    (umd->max_size < 0 ||
 		     umd->max_size > (int)umd->length)) /* illegal max_size */
 			return -EINVAL;
@@ -216,8 +216,8 @@ lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd)
 	 * and that's all.
 	 */
 	umd->start = lmd->md_start;
-	umd->length = ((lmd->md_options &
-			(LNET_MD_IOVEC | LNET_MD_KIOV)) == 0) ?
+	umd->length = !(lmd->md_options &
+		      (LNET_MD_IOVEC | LNET_MD_KIOV)) ?
 		      lmd->md_length : lmd->md_niov;
 	umd->threshold = lmd->md_threshold;
 	umd->max_size = lmd->md_max_size;
@@ -229,13 +229,13 @@ lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd)
 static int
 lnet_md_validate(lnet_md_t *umd)
 {
-	if (!umd->start && umd->length != 0) {
+	if (!umd->start && umd->length) {
 		CERROR("MD start pointer can not be NULL with length %u\n",
 		       umd->length);
 		return -EINVAL;
 	}
 
-	if ((umd->options & (LNET_MD_KIOV | LNET_MD_IOVEC)) != 0 &&
+	if ((umd->options & (LNET_MD_KIOV | LNET_MD_IOVEC)) &&
 	    umd->length > LNET_MAX_IOV) {
 		CERROR("Invalid option: too many fragments %u, %d max\n",
 		       umd->length, LNET_MAX_IOV);
@@ -284,10 +284,10 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	if (lnet_md_validate(&umd) != 0)
+	if (lnet_md_validate(&umd))
 		return -EINVAL;
 
-	if ((umd.options & (LNET_MD_OP_GET | LNET_MD_OP_PUT)) == 0) {
+	if (!(umd.options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
 		CERROR("Invalid option: no MD_OP set\n");
 		return -EINVAL;
 	}
@@ -300,7 +300,7 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	cpt = lnet_cpt_of_cookie(meh.cookie);
 
 	lnet_res_lock(cpt);
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	me = lnet_handle2me(&meh);
@@ -311,7 +311,7 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	else
 		rc = lnet_md_link(md, umd.eq_handle, cpt);
 
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	/*
@@ -363,10 +363,10 @@ LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
 	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	if (lnet_md_validate(&umd) != 0)
+	if (lnet_md_validate(&umd))
 		return -EINVAL;
 
-	if ((umd.options & (LNET_MD_OP_GET | LNET_MD_OP_PUT)) != 0) {
+	if ((umd.options & (LNET_MD_OP_GET | LNET_MD_OP_PUT))) {
 		CERROR("Invalid option: GET|PUT illegal on active MDs\n");
 		return -EINVAL;
 	}
@@ -378,11 +378,11 @@ LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
 	rc = lnet_md_build(md, &umd, unlink);
 
 	cpt = lnet_res_lock_current();
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	rc = lnet_md_link(md, umd.eq_handle, cpt);
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	lnet_md2handle(handle, md);
@@ -453,7 +453,7 @@ LNetMDUnlink(lnet_handle_md_t mdh)
 	 * when the LND is done, the completion event flags that the MD was
 	 * unlinked.  Otherwise, we enqueue an event now...
 	 */
-	if (md->md_eq && md->md_refcount == 0) {
+	if (md->md_eq && !md->md_refcount) {
 		lnet_build_unlink_event(md, &ev);
 		lnet_eq_enqueue_event(md->md_eq, &ev);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index ab17bdb..3c59c88 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -109,7 +109,7 @@ LNetMEAttach(unsigned int portal,
 
 	lnet_res_lh_initialize(the_lnet.ln_me_containers[mtable->mt_cpt],
 			       &me->me_lh);
-	if (ignore_bits != 0)
+	if (ignore_bits)
 		head = &mtable->mt_mhash[LNET_MT_HASH_IGNORE];
 	else
 		head = lnet_mt_match_head(mtable, match_id, match_bits);
@@ -248,7 +248,7 @@ LNetMEUnlink(lnet_handle_me_t meh)
 	md = me->me_md;
 	if (md) {
 		md->md_flags |= LNET_MD_FLAG_ABORTED;
-		if (md->md_eq && md->md_refcount == 0) {
+		if (md->md_eq && !md->md_refcount) {
 			lnet_build_unlink_event(md, &ev);
 			lnet_eq_enqueue_event(md->md_eq, &ev);
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5e8a6ab..8f16913 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -57,7 +57,7 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 	LASSERT(the_lnet.ln_init);
 
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
-	if (threshold != 0) {
+	if (threshold) {
 		/* Adding a new entry */
 		LIBCFS_ALLOC(tp, sizeof(*tp));
 		if (!tp)
@@ -80,7 +80,7 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
 		tp = list_entry(el, lnet_test_peer_t, tp_list);
 
-		if (tp->tp_threshold == 0 ||    /* needs culling anyway */
+		if (!tp->tp_threshold ||    /* needs culling anyway */
 		    nid == LNET_NID_ANY ||       /* removing all entries */
 		    tp->tp_nid == nid) {	  /* matched this one */
 			list_del(&tp->tp_list);
@@ -116,7 +116,7 @@ fail_peer(lnet_nid_t nid, int outgoing)
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
 		tp = list_entry(el, lnet_test_peer_t, tp_list);
 
-		if (tp->tp_threshold == 0) {
+		if (!tp->tp_threshold) {
 			/* zombie entry */
 			if (outgoing) {
 				/*
@@ -137,7 +137,7 @@ fail_peer(lnet_nid_t nid, int outgoing)
 			if (tp->tp_threshold != LNET_MD_THRESH_INF) {
 				tp->tp_threshold--;
 				if (outgoing &&
-				    tp->tp_threshold == 0) {
+				    !tp->tp_threshold) {
 					/* see above */
 					list_del(&tp->tp_list);
 					list_add(&tp->tp_list, &cull);
@@ -179,7 +179,7 @@ lnet_copy_iov2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
 	/* NB diov, siov are READ-ONLY */
 	unsigned int this_nob;
 
-	if (nob == 0)
+	if (!nob)
 		return;
 
 	/* skip complete frags before 'doffset' */
@@ -243,7 +243,7 @@ lnet_extract_iov(int dst_niov, struct kvec *dst,
 	unsigned int frag_len;
 	unsigned int niov;
 
-	if (len == 0)			   /* no data => */
+	if (!len)			   /* no data => */
 		return 0;		     /* no frags */
 
 	LASSERT(src_niov > 0);
@@ -301,7 +301,7 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 	char *daddr = NULL;
 	char *saddr = NULL;
 
-	if (nob == 0)
+	if (!nob)
 		return;
 
 	LASSERT(!in_interrupt());
@@ -383,7 +383,7 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 	unsigned int this_nob;
 	char *addr = NULL;
 
-	if (nob == 0)
+	if (!nob)
 		return;
 
 	LASSERT(!in_interrupt());
@@ -454,7 +454,7 @@ lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
 	unsigned int this_nob;
 	char *addr = NULL;
 
-	if (nob == 0)
+	if (!nob)
 		return;
 
 	LASSERT(!in_interrupt());
@@ -527,7 +527,7 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 	unsigned int frag_len;
 	unsigned int niov;
 
-	if (len == 0)			   /* no data => */
+	if (!len)			   /* no data => */
 		return 0;		     /* no frags */
 
 	LASSERT(src_niov > 0);
@@ -577,7 +577,7 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	int rc;
 
 	LASSERT(!in_interrupt());
-	LASSERT(mlen == 0 || msg);
+	LASSERT(!mlen || msg);
 
 	if (msg) {
 		LASSERT(msg->msg_receiving);
@@ -589,7 +589,7 @@ lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 
 		msg->msg_receiving = 0;
 
-		if (mlen != 0) {
+		if (mlen) {
 			niov = msg->msg_niov;
 			iov  = msg->msg_iov;
 			kiov = msg->msg_kiov;
@@ -613,12 +613,12 @@ lnet_setpayloadbuffer(lnet_msg_t *msg)
 	LASSERT(msg->msg_len > 0);
 	LASSERT(!msg->msg_routing);
 	LASSERT(md);
-	LASSERT(msg->msg_niov == 0);
+	LASSERT(!msg->msg_niov);
 	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
 
 	msg->msg_niov = md->md_niov;
-	if ((md->md_options & LNET_MD_KIOV) != 0)
+	if (md->md_options & LNET_MD_KIOV)
 		msg->msg_kiov = md->md_iov.kiov;
 	else
 		msg->msg_iov = md->md_iov.iov;
@@ -633,7 +633,7 @@ lnet_prep_send(lnet_msg_t *msg, int type, lnet_process_id_t target,
 	msg->msg_len = len;
 	msg->msg_offset = offset;
 
-	if (len != 0)
+	if (len)
 		lnet_setpayloadbuffer(msg);
 
 	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
@@ -673,7 +673,7 @@ lnet_ni_eager_recv(lnet_ni_t *ni, lnet_msg_t *msg)
 	msg->msg_rx_ready_delay = 1;
 	rc = ni->ni_lnd->lnd_eager_recv(ni, msg->msg_private, msg,
 					&msg->msg_private);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("recv from %s / send to %s aborted: eager_recv failed %d\n",
 		       libcfs_nid2str(msg->msg_rxpeer->lp_nid),
 		       libcfs_id2str(msg->msg_target), rc);
@@ -698,7 +698,7 @@ lnet_ni_query_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 
 	lp->lp_last_query = cfs_time_current();
 
-	if (last_alive != 0) /* NI has updated timestamp */
+	if (last_alive) /* NI has updated timestamp */
 		lp->lp_last_alive = last_alive;
 }
 
@@ -727,7 +727,7 @@ lnet_peer_is_alive(lnet_peer_t *lp, unsigned long now)
 	 * case, and moreover lp_last_alive at peer creation is assumed.
 	 */
 	if (alive && !lp->lp_alive &&
-	    !(lnet_isrouter(lp) && lp->lp_alive_count == 0))
+	    !(lnet_isrouter(lp) && !lp->lp_alive_count))
 		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
 
 	return alive;
@@ -752,7 +752,7 @@ lnet_peer_alive_locked(lnet_peer_t *lp)
 	 * Peer appears dead, but we should avoid frequent NI queries (at
 	 * most once per lnet_queryinterval seconds).
 	 */
-	if (lp->lp_last_query != 0) {
+	if (lp->lp_last_query) {
 		static const int lnet_queryinterval = 1;
 
 		unsigned long next_query =
@@ -805,8 +805,8 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 	LASSERT(msg->msg_tx_committed);
 
 	/* NB 'lp' is always the next hop */
-	if ((msg->msg_target.pid & LNET_PID_USERFLAG) == 0 &&
-	    lnet_peer_alive_locked(lp) == 0) {
+	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
+	    !lnet_peer_alive_locked(lp)) {
 		the_lnet.ln_counters[cpt]->drop_count++;
 		the_lnet.ln_counters[cpt]->drop_length += msg->msg_len;
 		lnet_net_unlock(cpt);
@@ -821,7 +821,7 @@ lnet_post_send_locked(lnet_msg_t *msg, int do_send)
 	}
 
 	if (msg->msg_md &&
-	    (msg->msg_md->md_flags & LNET_MD_FLAG_ABORTED) != 0) {
+	    (msg->msg_md->md_flags & LNET_MD_FLAG_ABORTED)) {
 		lnet_net_unlock(cpt);
 
 		CNETERR("Aborting message for %s: LNetM[DE]Unlink() already called on the MD/ME.\n",
@@ -910,7 +910,7 @@ lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 
 	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
-	LASSERT(msg->msg_niov == 0);
+	LASSERT(!msg->msg_niov);
 	LASSERT(msg->msg_routing);
 	LASSERT(msg->msg_receiving);
 	LASSERT(!msg->msg_sending);
@@ -1157,8 +1157,8 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 		lp = rtr->lr_gateway;
 
 		if (!lp->lp_alive || /* gateway is down */
-		    ((lp->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) != 0 &&
-		     rtr->lr_downis != 0)) /* NI to target is down */
+		    ((lp->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) &&
+		     rtr->lr_downis)) /* NI to target is down */
 			continue;
 
 		if (ni && lp->lp_ni != ni)
@@ -1283,7 +1283,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 		rc = lnet_nid2peer_locked(&lp, dst_nid, cpt);
 		/* lp has ref on src_ni; lose mine */
 		lnet_ni_decref_locked(src_ni, cpt);
-		if (rc != 0) {
+		if (rc) {
 			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("Error %d finding peer %s\n", rc,
 				      libcfs_nid2str(dst_nid));
@@ -1365,10 +1365,10 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	if (rc == EHOSTUNREACH || rc == ECANCELED)
 		return -rc;
 
-	if (rc == 0)
+	if (!rc)
 		lnet_ni_send(src_ni, msg);
 
-	return 0; /* rc == 0 or EAGAIN */
+	return 0; /* !rc or EAGAIN */
 }
 
 static void
@@ -1387,7 +1387,7 @@ lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
 {
 	lnet_hdr_t *hdr = &msg->msg_hdr;
 
-	if (msg->msg_wanted != 0)
+	if (msg->msg_wanted)
 		lnet_setpayloadbuffer(msg);
 
 	lnet_build_msg_event(msg, LNET_EVENT_PUT);
@@ -1396,8 +1396,8 @@ lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
 	 * Must I ACK?  If so I'll grab the ack_wmd out of the header and put
 	 * it back into the ACK during lnet_finalize()
 	 */
-	msg->msg_ack = (!lnet_is_wire_handle_none(&hdr->msg.put.ack_wmd) &&
-			(msg->msg_md->md_options & LNET_MD_ACK_DISABLE) == 0);
+	msg->msg_ack = !lnet_is_wire_handle_none(&hdr->msg.put.ack_wmd) &&
+		       !(msg->msg_md->md_options & LNET_MD_ACK_DISABLE);
 
 	lnet_ni_recv(ni, msg->msg_private, msg, msg->msg_rx_delayed,
 		     msg->msg_offset, msg->msg_wanted, hdr->payload_length);
@@ -1440,7 +1440,7 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 			return 0;
 
 		rc = lnet_ni_eager_recv(ni, msg);
-		if (rc == 0)
+		if (!rc)
 			goto again;
 		/* fall through */
 
@@ -1536,7 +1536,7 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	/* NB handles only looked up by creator (no flips) */
 	md = lnet_wire_handle2md(&hdr->msg.reply.dst_wmd);
-	if (!md || md->md_threshold == 0 || md->md_me) {
+	if (!md || !md->md_threshold || md->md_me) {
 		CNETERR("%s: Dropping REPLY from %s for %s MD %#llx.%#llx\n",
 			libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
 			!md ? "invalid" : "inactive",
@@ -1550,13 +1550,13 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 		return ENOENT;		  /* +ve: OK but no match */
 	}
 
-	LASSERT(md->md_offset == 0);
+	LASSERT(!md->md_offset);
 
 	rlength = hdr->payload_length;
 	mlength = min_t(uint, rlength, md->md_length);
 
 	if (mlength < rlength &&
-	    (md->md_options & LNET_MD_TRUNCATE) == 0) {
+	    !(md->md_options & LNET_MD_TRUNCATE)) {
 		CNETERR("%s: Dropping REPLY from %s length %d for MD %#llx would overflow (%d)\n",
 			libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
 			rlength, hdr->msg.reply.dst_wmd.wh_object_cookie,
@@ -1571,7 +1571,7 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	lnet_msg_attach_md(msg, md, 0, mlength);
 
-	if (mlength != 0)
+	if (mlength)
 		lnet_setpayloadbuffer(msg);
 
 	lnet_res_unlock(cpt);
@@ -1602,7 +1602,7 @@ lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	/* NB handles only looked up by creator (no flips) */
 	md = lnet_wire_handle2md(&hdr->msg.ack.dst_wmd);
-	if (!md || md->md_threshold == 0 || md->md_me) {
+	if (!md || !md->md_threshold || md->md_me) {
 		/* Don't moan; this is expected */
 		CDEBUG(D_NET,
 		       "%s: Dropping ACK from %s to %s MD %#llx.%#llx\n",
@@ -1648,7 +1648,7 @@ lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 		}
 	}
 
-	if (rc == 0)
+	if (!rc)
 		rc = lnet_post_routed_recv_locked(msg, 0);
 	return rc;
 }
@@ -1893,7 +1893,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 	lnet_net_lock(cpt);
 	rc = lnet_nid2peer_locked(&msg->msg_rxpeer, from_nid, cpt);
-	if (rc != 0) {
+	if (rc) {
 		lnet_net_unlock(cpt);
 		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
@@ -1923,7 +1923,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 		if (rc < 0)
 			goto free_drop;
-		if (rc == 0) {
+		if (!rc) {
 			lnet_ni_recv(ni, msg->msg_private, msg, 0,
 				     0, payload_length, payload_length);
 		}
@@ -1951,7 +1951,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 		goto free_drop;  /* prevent an unused label if !kernel */
 	}
 
-	if (rc == 0)
+	if (!rc)
 		return 0;
 
 	LASSERT(rc == ENOENT);
@@ -2117,7 +2117,7 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 	lnet_res_lock(cpt);
 
 	md = lnet_handle2md(&mdh);
-	if (!md || md->md_threshold == 0 || md->md_me) {
+	if (!md || !md->md_threshold || md->md_me) {
 		CERROR("Dropping PUT (%llu:%d:%s): MD (%d) invalid\n",
 		       match_bits, portal, libcfs_id2str(target),
 		       !md ? -1 : md->md_threshold);
@@ -2159,7 +2159,7 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 	lnet_build_msg_event(msg, LNET_EVENT_SEND);
 
 	rc = lnet_send(self, msg, LNET_NID_ANY);
-	if (rc != 0) {
+	if (rc) {
 		CNETERR("Error sending PUT to %s: %d\n",
 			libcfs_id2str(target), rc);
 		lnet_finalize(NULL, msg, rc);
@@ -2200,7 +2200,7 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 		goto drop;
 	}
 
-	if (getmd->md_threshold == 0) {
+	if (!getmd->md_threshold) {
 		CERROR("%s: Dropping REPLY from %s for inactive MD %p\n",
 		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id),
 		       getmd);
@@ -2208,7 +2208,7 @@ lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 		goto drop;
 	}
 
-	LASSERT(getmd->md_offset == 0);
+	LASSERT(!getmd->md_offset);
 
 	CDEBUG(D_NET, "%s: Reply from %s md %p\n",
 	       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id), getmd);
@@ -2321,7 +2321,7 @@ LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
 	lnet_res_lock(cpt);
 
 	md = lnet_handle2md(&mdh);
-	if (!md || md->md_threshold == 0 || md->md_me) {
+	if (!md || !md->md_threshold || md->md_me) {
 		CERROR("Dropping GET (%llu:%d:%s): MD (%d) invalid\n",
 		       match_bits, portal, libcfs_id2str(target),
 		       !md ? -1 : md->md_threshold);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 5ee390c..749e76a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -172,7 +172,7 @@ lnet_msg_decommit_tx(lnet_msg_t *msg, int status)
 	lnet_event_t *ev = &msg->msg_ev;
 
 	LASSERT(msg->msg_tx_committed);
-	if (status != 0)
+	if (status)
 		goto out;
 
 	counters = the_lnet.ln_counters[msg->msg_tx_cpt];
@@ -180,7 +180,7 @@ lnet_msg_decommit_tx(lnet_msg_t *msg, int status)
 	default: /* routed message */
 		LASSERT(msg->msg_routing);
 		LASSERT(msg->msg_rx_committed);
-		LASSERT(ev->type == 0);
+		LASSERT(!ev->type);
 
 		counters->route_length += msg->msg_len;
 		counters->route_count++;
@@ -226,13 +226,13 @@ lnet_msg_decommit_rx(lnet_msg_t *msg, int status)
 	LASSERT(!msg->msg_tx_committed); /* decommitted or never committed */
 	LASSERT(msg->msg_rx_committed);
 
-	if (status != 0)
+	if (status)
 		goto out;
 
 	counters = the_lnet.ln_counters[msg->msg_rx_cpt];
 	switch (ev->type) {
 	default:
-		LASSERT(ev->type == 0);
+		LASSERT(!ev->type);
 		LASSERT(msg->msg_routing);
 		goto out;
 
@@ -371,7 +371,7 @@ lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 
 	LASSERT(msg->msg_onactivelist);
 
-	if (status == 0 && msg->msg_ack) {
+	if (!status && msg->msg_ack) {
 		/* Only send an ACK if the PUT completed successfully */
 
 		lnet_msg_decommit(msg, cpt, 0);
@@ -410,7 +410,7 @@ lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 		 */
 		return rc;
 
-	} else if (status == 0 &&	/* OK so far */
+	} else if (!status &&	/* OK so far */
 		   (msg->msg_routing && !msg->msg_sending)) {
 		/* not forwarded */
 		LASSERT(!msg->msg_receiving);	/* called back recv already */
@@ -531,14 +531,14 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 		 * anything, so my finalizing friends can chomp along too
 		 */
 		rc = lnet_complete_msg_locked(msg, cpt);
-		if (rc != 0)
+		if (rc)
 			break;
 	}
 
 	container->msc_finalizers[my_slot] = NULL;
 	lnet_net_unlock(cpt);
 
-	if (rc != 0)
+	if (rc)
 		goto again;
 }
 EXPORT_SYMBOL(lnet_finalize);
@@ -548,7 +548,7 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 {
 	int count = 0;
 
-	if (container->msc_init == 0)
+	if (!container->msc_init)
 		return;
 
 	while (!list_empty(&container->msc_active)) {
@@ -592,7 +592,7 @@ lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 
 	rc = lnet_freelist_init(&container->msc_freelist,
 				LNET_FL_MAX_MSGS, sizeof(lnet_msg_t));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Failed to init freelist for message container\n");
 		lnet_msg_container_cleanup(container);
 		return rc;
@@ -649,7 +649,7 @@ lnet_msg_containers_create(void)
 
 	cfs_percpt_for_each(container, i, the_lnet.ln_msg_containers) {
 		rc = lnet_msg_container_setup(container, i);
-		if (rc != 0) {
+		if (rc) {
 			lnet_msg_containers_destroy();
 			return rc;
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index aca47de..0cdeea9 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -50,7 +50,7 @@ lnet_ptl_match_type(unsigned int index, lnet_process_id_t match_id,
 	struct lnet_portal *ptl = the_lnet.ln_portals[index];
 	int unique;
 
-	unique = ignore_bits == 0 &&
+	unique = !ignore_bits &&
 		 match_id.nid != LNET_NID_ANY &&
 		 match_id.pid != LNET_PID_ANY;
 
@@ -152,7 +152,7 @@ lnet_try_match_md(lnet_libmd_t *md,
 		return LNET_MATCHMD_NONE | LNET_MATCHMD_EXHAUSTED;
 
 	/* mismatched MD op */
-	if ((md->md_options & info->mi_opc) == 0)
+	if (!(md->md_options & info->mi_opc))
 		return LNET_MATCHMD_NONE;
 
 	/* mismatched ME nid/pid? */
@@ -165,17 +165,17 @@ lnet_try_match_md(lnet_libmd_t *md,
 		return LNET_MATCHMD_NONE;
 
 	/* mismatched ME matchbits? */
-	if (((me->me_match_bits ^ info->mi_mbits) & ~me->me_ignore_bits) != 0)
+	if ((me->me_match_bits ^ info->mi_mbits) & ~me->me_ignore_bits)
 		return LNET_MATCHMD_NONE;
 
 	/* Hurrah! This _is_ a match; check it out... */
 
-	if ((md->md_options & LNET_MD_MANAGE_REMOTE) == 0)
+	if (!(md->md_options & LNET_MD_MANAGE_REMOTE))
 		offset = md->md_offset;
 	else
 		offset = info->mi_roffset;
 
-	if ((md->md_options & LNET_MD_MAX_SIZE) != 0) {
+	if (md->md_options & LNET_MD_MAX_SIZE) {
 		mlength = md->md_max_size;
 		LASSERT(md->md_offset + mlength <= md->md_length);
 	} else {
@@ -184,7 +184,7 @@ lnet_try_match_md(lnet_libmd_t *md,
 
 	if (info->mi_rlength <= mlength) {	/* fits in allowed space */
 		mlength = info->mi_rlength;
-	} else if ((md->md_options & LNET_MD_TRUNCATE) == 0) {
+	} else if (!(md->md_options & LNET_MD_TRUNCATE)) {
 		/* this packet _really_ is too big */
 		CERROR("Matching packet from %s, match %llu length %d too big: %d left, %d allowed\n",
 		       libcfs_id2str(info->mi_id), info->mi_mbits,
@@ -210,7 +210,7 @@ lnet_try_match_md(lnet_libmd_t *md,
 	 * We bumped md->md_refcount above so the MD just gets flagged
 	 * for unlink when it is finalized.
 	 */
-	if ((md->md_flags & LNET_MD_FLAG_AUTO_UNLINK) != 0)
+	if (md->md_flags & LNET_MD_FLAG_AUTO_UNLINK)
 		lnet_md_unlink(md);
 
 	return LNET_MATCHMD_OK | LNET_MATCHMD_EXHAUSTED;
@@ -304,7 +304,7 @@ lnet_mt_of_match(struct lnet_match_info *info, struct lnet_msg *msg)
 		/* is there any active entry for this portal? */
 		nmaps = ptl->ptl_mt_nmaps;
 		/* map to an active mtable to avoid heavy "stealing" */
-		if (nmaps != 0) {
+		if (nmaps) {
 			/*
 			 * NB: there is possibility that ptl_mt_maps is being
 			 * changed because we are not under protection of
@@ -339,7 +339,7 @@ lnet_mt_test_exhausted(struct lnet_match_table *mtable, int pos)
 	bmap = &mtable->mt_exhausted[pos >> LNET_MT_BITS_U64];
 	pos &= (1 << LNET_MT_BITS_U64) - 1;
 
-	return ((*bmap) & (1ULL << pos)) != 0;
+	return (*bmap & (1ULL << pos));
 }
 
 static void
@@ -405,10 +405,10 @@ lnet_mt_match_md(struct lnet_match_table *mtable,
 		LASSERT(me == me->me_md->md_me);
 
 		rc = lnet_try_match_md(me->me_md, info, msg);
-		if ((rc & LNET_MATCHMD_EXHAUSTED) == 0)
+		if (!(rc & LNET_MATCHMD_EXHAUSTED))
 			exhausted = 0; /* mlist is not empty */
 
-		if ((rc & LNET_MATCHMD_FINISH) != 0) {
+		if (rc & LNET_MATCHMD_FINISH) {
 			/*
 			 * don't return EXHAUSTED bit because we don't know
 			 * whether the mlist is empty or not
@@ -423,7 +423,7 @@ lnet_mt_match_md(struct lnet_match_table *mtable,
 			exhausted = 0;
 	}
 
-	if (exhausted == 0 && head == &mtable->mt_mhash[LNET_MT_HASH_IGNORE]) {
+	if (!exhausted && head == &mtable->mt_mhash[LNET_MT_HASH_IGNORE]) {
 		head = lnet_mt_match_head(mtable, info->mi_id, info->mi_mbits);
 		goto again; /* re-check MEs w/o ignore-bits */
 	}
@@ -490,13 +490,13 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 
 		cpt = (first + i) % LNET_CPT_NUMBER;
 		mtable = ptl->ptl_mtables[cpt];
-		if (i != 0 && i != LNET_CPT_NUMBER - 1 && !mtable->mt_enabled)
+		if (i && i != LNET_CPT_NUMBER - 1 && !mtable->mt_enabled)
 			continue;
 
 		lnet_res_lock(cpt);
 		lnet_ptl_lock(ptl);
 
-		if (i == 0) { /* the first try, attach on stealing list */
+		if (!i) { /* the first try, attach on stealing list */
 			list_add_tail(&msg->msg_list,
 				      &ptl->ptl_msg_stealing);
 		}
@@ -504,11 +504,11 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 		if (!list_empty(&msg->msg_list)) { /* on stealing list */
 			rc = lnet_mt_match_md(mtable, info, msg);
 
-			if ((rc & LNET_MATCHMD_EXHAUSTED) != 0 &&
+			if ((rc & LNET_MATCHMD_EXHAUSTED) &&
 			    mtable->mt_enabled)
 				lnet_ptl_disable_mt(ptl, cpt);
 
-			if ((rc & LNET_MATCHMD_FINISH) != 0)
+			if (rc & LNET_MATCHMD_FINISH)
 				list_del_init(&msg->msg_list);
 
 		} else {
@@ -522,7 +522,7 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 
 		if (!list_empty(&msg->msg_list) && /* not matched yet */
 		    (i == LNET_CPT_NUMBER - 1 || /* the last CPT */
-		     ptl->ptl_mt_nmaps == 0 ||   /* no active CPT */
+		     !ptl->ptl_mt_nmaps ||   /* no active CPT */
 		     (ptl->ptl_mt_nmaps == 1 &&  /* the only active CPT */
 		      ptl->ptl_mt_maps[0] == cpt))) {
 			/* nothing to steal, delay or drop */
@@ -541,7 +541,7 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 		lnet_ptl_unlock(ptl);
 		lnet_res_unlock(cpt);
 
-		if ((rc & LNET_MATCHMD_FINISH) != 0 || msg->msg_rx_delayed)
+		if ((rc & LNET_MATCHMD_FINISH) || msg->msg_rx_delayed)
 			break;
 	}
 
@@ -567,7 +567,7 @@ lnet_ptl_match_md(struct lnet_match_info *info, struct lnet_msg *msg)
 
 	ptl = the_lnet.ln_portals[info->mi_portal];
 	rc = lnet_ptl_match_early(ptl, msg);
-	if (rc != 0) /* matched or delayed early message */
+	if (rc) /* matched or delayed early message */
 		return rc;
 
 	mtable = lnet_mt_of_match(info, msg);
@@ -579,13 +579,13 @@ lnet_ptl_match_md(struct lnet_match_info *info, struct lnet_msg *msg)
 	}
 
 	rc = lnet_mt_match_md(mtable, info, msg);
-	if ((rc & LNET_MATCHMD_EXHAUSTED) != 0 && mtable->mt_enabled) {
+	if ((rc & LNET_MATCHMD_EXHAUSTED) && mtable->mt_enabled) {
 		lnet_ptl_lock(ptl);
 		lnet_ptl_disable_mt(ptl, mtable->mt_cpt);
 		lnet_ptl_unlock(ptl);
 	}
 
-	if ((rc & LNET_MATCHMD_FINISH) != 0)	/* matched or dropping */
+	if (rc & LNET_MATCHMD_FINISH)	/* matched or dropping */
 		goto out1;
 
 	if (!msg->msg_rx_ready_delay)
@@ -646,7 +646,7 @@ lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
 	int exhausted = 0;
 	int cpt;
 
-	LASSERT(md->md_refcount == 0); /* a brand new MD */
+	LASSERT(!md->md_refcount); /* a brand new MD */
 
 	me->me_md = md;
 	md->md_me = me;
@@ -680,15 +680,15 @@ lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
 
 		rc = lnet_try_match_md(md, &info, msg);
 
-		exhausted = (rc & LNET_MATCHMD_EXHAUSTED) != 0;
-		if ((rc & LNET_MATCHMD_NONE) != 0) {
+		exhausted = (rc & LNET_MATCHMD_EXHAUSTED);
+		if (rc & LNET_MATCHMD_NONE) {
 			if (exhausted)
 				break;
 			continue;
 		}
 
 		/* Hurrah! This _is_ a match */
-		LASSERT((rc & LNET_MATCHMD_FINISH) != 0);
+		LASSERT(rc & LNET_MATCHMD_FINISH);
 		list_del_init(&msg->msg_list);
 
 		if (head == &ptl->ptl_msg_stealing) {
@@ -698,7 +698,7 @@ lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
 			continue;
 		}
 
-		if ((rc & LNET_MATCHMD_OK) != 0) {
+		if (rc & LNET_MATCHMD_OK) {
 			list_add_tail(&msg->msg_list, matches);
 
 			CDEBUG(D_NET, "Resuming delayed PUT from %s portal %d match %llu offset %d length %d.\n",
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 0cf0645..53dd0bd 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -64,7 +64,7 @@ lnet_sock_ioctl(int cmd, unsigned long arg)
 	int rc;
 
 	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create socket: %d\n", rc);
 		return rc;
 	}
@@ -101,12 +101,12 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 
 	strcpy(ifr.ifr_name, name);
 	rc = lnet_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't get flags for interface %s\n", name);
 		return rc;
 	}
 
-	if ((ifr.ifr_flags & IFF_UP) == 0) {
+	if (!(ifr.ifr_flags & IFF_UP)) {
 		CDEBUG(D_NET, "Interface %s down\n", name);
 		*up = 0;
 		*ip = *mask = 0;
@@ -117,7 +117,7 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 	strcpy(ifr.ifr_name, name);
 	ifr.ifr_addr.sa_family = AF_INET;
 	rc = lnet_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't get IP address for interface %s\n", name);
 		return rc;
 	}
@@ -128,7 +128,7 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 	strcpy(ifr.ifr_name, name);
 	ifr.ifr_addr.sa_family = AF_INET;
 	rc = lnet_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't get netmask for interface %s\n", name);
 		return rc;
 	}
@@ -181,7 +181,7 @@ lnet_ipif_enumerate(char ***namesp)
 			goto out1;
 		}
 
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 
 		nfound = ifc.ifc_len / sizeof(*ifr);
 		LASSERT(nfound <= nalloc);
@@ -193,7 +193,7 @@ lnet_ipif_enumerate(char ***namesp)
 		nalloc *= 2;
 	}
 
-	if (nfound == 0)
+	if (!nfound)
 		goto out1;
 
 	LIBCFS_ALLOC(names, nfound * sizeof(*names));
@@ -268,10 +268,10 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 			.iov_len  = nob
 		};
 		struct msghdr msg = {
-			.msg_flags      = (timeout == 0) ? MSG_DONTWAIT : 0
+			.msg_flags      = !timeout ? MSG_DONTWAIT : 0
 		};
 
-		if (timeout != 0) {
+		if (timeout) {
 			/* Set send timeout to remaining time */
 			tv = (struct timeval) {
 				.tv_sec = ticks / HZ,
@@ -279,7 +279,7 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 			};
 			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
 					       (char *)&tv, sizeof(tv));
-			if (rc != 0) {
+			if (rc) {
 				CERROR("Can't set socket send timeout %ld.%06d: %d\n",
 				       (long)tv.tv_sec, (int)tv.tv_usec, rc);
 				return rc;
@@ -296,7 +296,7 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 		if (rc < 0)
 			return rc;
 
-		if (rc == 0) {
+		if (!rc) {
 			CERROR("Unexpected zero rc\n");
 			return -ECONNABORTED;
 		}
@@ -338,7 +338,7 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 		};
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
 				       (char *)&tv, sizeof(tv));
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't set socket recv timeout %ld.%06d: %d\n",
 			       (long)tv.tv_sec, (int)tv.tv_usec, rc);
 			return rc;
@@ -351,13 +351,13 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 		if (rc < 0)
 			return rc;
 
-		if (rc == 0)
+		if (!rc)
 			return -ECONNRESET;
 
 		buffer = ((char *)buffer) + rc;
 		nob -= rc;
 
-		if (nob == 0)
+		if (!nob)
 			return 0;
 
 		if (ticks <= 0)
@@ -380,7 +380,7 @@ lnet_sock_create(struct socket **sockp, int *fatal, __u32 local_ip,
 
 	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
 	*sockp = sock;
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create socket: %d\n", rc);
 		return rc;
 	}
@@ -388,16 +388,16 @@ lnet_sock_create(struct socket **sockp, int *fatal, __u32 local_ip,
 	option = 1;
 	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
 			       (char *)&option, sizeof(option));
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't set SO_REUSEADDR for socket: %d\n", rc);
 		goto failed;
 	}
 
-	if (local_ip != 0 || local_port != 0) {
+	if (local_ip || local_port) {
 		memset(&locaddr, 0, sizeof(locaddr));
 		locaddr.sin_family = AF_INET;
 		locaddr.sin_port = htons(local_port);
-		locaddr.sin_addr.s_addr = (local_ip == 0) ?
+		locaddr.sin_addr.s_addr = !local_ip ?
 					  INADDR_ANY : htonl(local_ip);
 
 		rc = kernel_bind(sock, (struct sockaddr *)&locaddr,
@@ -407,7 +407,7 @@ lnet_sock_create(struct socket **sockp, int *fatal, __u32 local_ip,
 			*fatal = 0;
 			goto failed;
 		}
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Error trying to bind to port %d: %d\n",
 			       local_port, rc);
 			goto failed;
@@ -426,22 +426,22 @@ lnet_sock_setbuf(struct socket *sock, int txbufsize, int rxbufsize)
 	int option;
 	int rc;
 
-	if (txbufsize != 0) {
+	if (txbufsize) {
 		option = txbufsize;
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDBUF,
 				       (char *)&option, sizeof(option));
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't set send buffer %d: %d\n",
 			       option, rc);
 			return rc;
 		}
 	}
 
-	if (rxbufsize != 0) {
+	if (rxbufsize) {
 		option = rxbufsize;
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
 				       (char *)&option, sizeof(option));
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't set receive buffer %d: %d\n",
 			       option, rc);
 			return rc;
@@ -462,7 +462,7 @@ lnet_sock_getaddr(struct socket *sock, bool remote, __u32 *ip, int *port)
 		rc = kernel_getpeername(sock, (struct sockaddr *)&sin, &len);
 	else
 		rc = kernel_getsockname(sock, (struct sockaddr *)&sin, &len);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Error %d getting sock %s IP/port\n",
 		       rc, remote ? "peer" : "local");
 		return rc;
@@ -499,7 +499,7 @@ lnet_sock_listen(struct socket **sockp, __u32 local_ip, int local_port,
 	int rc;
 
 	rc = lnet_sock_create(sockp, &fatal, local_ip, local_port);
-	if (rc != 0) {
+	if (rc) {
 		if (!fatal)
 			CERROR("Can't create socket: port %d already in use\n",
 			       local_port);
@@ -507,7 +507,7 @@ lnet_sock_listen(struct socket **sockp, __u32 local_ip, int local_port,
 	}
 
 	rc = kernel_listen(*sockp, backlog);
-	if (rc == 0)
+	if (!rc)
 		return 0;
 
 	CERROR("Can't set listen backlog %d: %d\n", backlog, rc);
@@ -548,7 +548,7 @@ lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 		rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
 	}
 
-	if (rc != 0)
+	if (rc)
 		goto failed;
 
 	*newsockp = newsock;
@@ -568,7 +568,7 @@ lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
 	int rc;
 
 	rc = lnet_sock_create(sockp, fatal, local_ip, local_port);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	memset(&srvaddr, 0, sizeof(srvaddr));
@@ -578,7 +578,7 @@ lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
 
 	rc = kernel_connect(*sockp, (struct sockaddr *)&srvaddr,
 			    sizeof(srvaddr), 0);
-	if (rc == 0)
+	if (!rc)
 		return 0;
 
 	/*
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 1e88033..cd37303 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -80,7 +80,7 @@ lnet_unconfigure(void)
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
 	mutex_unlock(&lnet_config_mutex);
-	return (refcount == 0) ? 0 : -EBUSY;
+	return !refcount ? 0 : -EBUSY;
 }
 
 static int
@@ -120,13 +120,13 @@ init_lnet(void)
 	mutex_init(&lnet_config_mutex);
 
 	rc = lnet_init();
-	if (rc != 0) {
+	if (rc) {
 		CERROR("lnet_init: error %d\n", rc);
 		return rc;
 	}
 
 	rc = libcfs_register_ioctl(&lnet_ioctl_handler);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	if (config_on_load) {
 		/*
@@ -145,7 +145,7 @@ fini_lnet(void)
 	int rc;
 
 	rc = libcfs_deregister_ioctl(&lnet_ioctl_handler);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	lnet_fini();
 }
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index c9c85e5..00010f3 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -206,7 +206,7 @@ add_nidrange(const struct cfs_lstr *src,
 	if (!nf)
 		return NULL;
 	endlen = src->ls_len - strlen(nf->nf_name);
-	if (endlen == 0)
+	if (!endlen)
 		/* network name only, e.g. "elan" or "tcp" */
 		netnum = 0;
 	else {
@@ -255,17 +255,17 @@ parse_nidrange(struct cfs_lstr *src, struct list_head *nidlist)
 	struct nidrange *nr;
 
 	tmp = *src;
-	if (cfs_gettok(src, '@', &addrrange) == 0)
+	if (!cfs_gettok(src, '@', &addrrange))
 		goto failed;
 
-	if (cfs_gettok(src, '@', &net) == 0 || src->ls_str)
+	if (!cfs_gettok(src, '@', &net) || src->ls_str)
 		goto failed;
 
 	nr = add_nidrange(&net, nidlist);
 	if (!nr)
 		goto failed;
 
-	if (parse_addrange(&addrrange, nr) != 0)
+	if (parse_addrange(&addrrange, nr))
 		goto failed;
 
 	return 1;
@@ -344,12 +344,12 @@ cfs_parse_nidlist(char *str, int len, struct list_head *nidlist)
 	INIT_LIST_HEAD(nidlist);
 	while (src.ls_str) {
 		rc = cfs_gettok(&src, ' ', &res);
-		if (rc == 0) {
+		if (!rc) {
 			cfs_free_nidlist(nidlist);
 			return 0;
 		}
 		rc = parse_nidrange(&res, nidlist);
-		if (rc == 0) {
+		if (!rc) {
 			cfs_free_nidlist(nidlist);
 			return 0;
 		}
@@ -397,7 +397,7 @@ cfs_print_network(char *buffer, int count, struct nidrange *nr)
 {
 	struct netstrfns *nf = nr->nr_netstrfns;
 
-	if (nr->nr_netnum == 0)
+	if (!nr->nr_netnum)
 		return scnprintf(buffer, count, "@%s", nf->nf_name);
 	else
 		return scnprintf(buffer, count, "@%s%u",
@@ -419,7 +419,7 @@ cfs_print_addrranges(char *buffer, int count, struct list_head *addrranges,
 	struct netstrfns *nf = nr->nr_netstrfns;
 
 	list_for_each_entry(ar, addrranges, ar_link) {
-		if (i != 0)
+		if (i)
 			i += scnprintf(buffer + i, count - i, " ");
 		i += nf->nf_print_addrlist(buffer + i, count - i,
 					   &ar->ar_numaddr_ranges);
@@ -444,10 +444,10 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 		return 0;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
-		if (i != 0)
+		if (i)
 			i += scnprintf(buffer + i, count - i, " ");
 
-		if (nr->nr_all != 0) {
+		if (nr->nr_all) {
 			LASSERT(list_empty(&nr->nr_addrranges));
 			i += scnprintf(buffer + i, count - i, "*");
 			i += cfs_print_network(buffer + i, count - i, nr);
@@ -517,7 +517,7 @@ static void cfs_num_ar_min_max(struct addrrange *ar, __u32 *min_nid,
 
 	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
 		list_for_each_entry(re, &el->el_exprs, re_link) {
-			if (re->re_lo < min_addr || min_addr == 0)
+			if (re->re_lo < min_addr || !min_addr)
 				min_addr = re->re_lo;
 			if (re->re_hi > max_addr)
 				max_addr = re->re_hi;
@@ -553,7 +553,7 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
 		if (netnum == -1)
 			netnum = nr->nr_netnum;
 
-		if (strcmp(lndname, nf->nf_name) != 0 ||
+		if (strcmp(lndname, nf->nf_name) ||
 		    netnum != nr->nr_netnum)
 			return false;
 	}
@@ -592,7 +592,7 @@ static bool cfs_num_is_contiguous(struct list_head *nidlist)
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
 			cfs_num_ar_min_max(ar, &current_start_nid,
 					   &current_end_nid);
-			if (last_end_nid != 0 &&
+			if (last_end_nid &&
 			    (current_start_nid - last_end_nid != 1))
 				return false;
 			last_end_nid = current_end_nid;
@@ -602,7 +602,7 @@ static bool cfs_num_is_contiguous(struct list_head *nidlist)
 						    re_link) {
 					if (re->re_stride > 1)
 						return false;
-					else if (last_hi != 0 &&
+					else if (last_hi &&
 						 re->re_hi - last_hi != 1)
 						return false;
 					last_hi = re->re_hi;
@@ -642,7 +642,7 @@ static bool cfs_ip_is_contiguous(struct list_head *nidlist)
 			last_diff = 0;
 			cfs_ip_ar_min_max(ar, &current_start_nid,
 					  &current_end_nid);
-			if (last_end_nid != 0 &&
+			if (last_end_nid &&
 			    (current_start_nid - last_end_nid != 1))
 				return false;
 			last_end_nid = current_end_nid;
@@ -726,7 +726,7 @@ static void cfs_num_min_max(struct list_head *nidlist, __u32 *min_nid,
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
 			cfs_num_ar_min_max(ar, &tmp_min_addr,
 					   &tmp_max_addr);
-			if (tmp_min_addr < min_addr || min_addr == 0)
+			if (tmp_min_addr < min_addr || !min_addr)
 				min_addr = tmp_min_addr;
 			if (tmp_max_addr > max_addr)
 				max_addr = tmp_min_addr;
@@ -758,7 +758,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
 			cfs_ip_ar_min_max(ar, &tmp_min_ip_addr,
 					  &tmp_max_ip_addr);
-			if (tmp_min_ip_addr < min_ip_addr || min_ip_addr == 0)
+			if (tmp_min_ip_addr < min_ip_addr || !min_ip_addr)
 				min_ip_addr = tmp_min_ip_addr;
 			if (tmp_max_ip_addr > max_ip_addr)
 				max_ip_addr = tmp_max_ip_addr;
@@ -806,8 +806,8 @@ libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 	/* numeric IP? */
 	if (sscanf(str, "%u.%u.%u.%u%n", &a, &b, &c, &d, &n) >= 4 &&
 	    n == nob &&
-	    (a & ~0xff) == 0 && (b & ~0xff) == 0 &&
-	    (c & ~0xff) == 0 && (d & ~0xff) == 0) {
+	    !(a & ~0xff) && !(b & ~0xff) &&
+	    !(c & ~0xff) && !(d & ~0xff)) {
 		*addr = ((a << 24) | (b << 16) | (c << 8) | d);
 		return 1;
 	}
@@ -837,7 +837,7 @@ cfs_ip_addr_parse(char *str, int len, struct list_head *list)
 		}
 
 		rc = cfs_expr_list_parse(res.ls_str, res.ls_len, 0, 255, &el);
-		if (rc != 0)
+		if (rc)
 			goto out;
 
 		list_add_tail(&el->el_link, list);
@@ -862,7 +862,7 @@ libcfs_ip_addr_range_print(char *buffer, int count, struct list_head *list)
 
 	list_for_each_entry(el, list, el_link) {
 		LASSERT(j++ < 4);
-		if (i != 0)
+		if (i)
 			i += scnprintf(buffer + i, count - i, ".");
 		i += cfs_expr_list_print(buffer + i, count - i, el);
 	}
@@ -932,7 +932,7 @@ libcfs_num_parse(char *str, int len, struct list_head *list)
 	int	rc;
 
 	rc = cfs_expr_list_parse(str, len, 0, MAX_NUMERIC_VALUE, &el);
-	if (rc == 0)
+	if (!rc)
 		list_add_tail(&el->el_link, list);
 
 	return rc;
@@ -1114,7 +1114,7 @@ libcfs_net2str_r(__u32 net, char *buf, size_t buf_size)
 	nf = libcfs_lnd2netstrfns(lnd);
 	if (!nf)
 		snprintf(buf, buf_size, "<%u:%u>", lnd, nnum);
-	else if (nnum == 0)
+	else if (!nnum)
 		snprintf(buf, buf_size, "%s", nf->nf_name);
 	else
 		snprintf(buf, buf_size, "%s%u", nf->nf_name, nnum);
@@ -1146,7 +1146,7 @@ libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size)
 
 		nf->nf_addr2str(addr, buf, buf_size);
 		addr_len = strlen(buf);
-		if (nnum == 0)
+		if (!nnum)
 			snprintf(buf + addr_len, buf_size - addr_len, "@%s",
 				 nf->nf_name);
 		else
@@ -1244,8 +1244,8 @@ libcfs_id2str(lnet_process_id_t id)
 	}
 
 	snprintf(str, LNET_NIDSTR_SIZE, "%s%u-%s",
-		 ((id.pid & LNET_PID_USERFLAG) != 0) ? "U" : "",
-		 (id.pid & ~LNET_PID_USERFLAG), libcfs_nid2str(id.nid));
+		 id.pid & LNET_PID_USERFLAG ? "U" : "",
+		 id.pid & ~LNET_PID_USERFLAG, libcfs_nid2str(id.nid));
 	return str;
 }
 EXPORT_SYMBOL(libcfs_id2str);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 43b459e..00086ee 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -137,10 +137,10 @@ lnet_peer_tables_cleanup(void)
 
 		lnet_net_lock(i);
 
-		for (j = 3; ptable->pt_number != 0; j++) {
+		for (j = 3; ptable->pt_number; j++) {
 			lnet_net_unlock(i);
 
-			if ((j & (j - 1)) == 0) {
+			if (!(j & (j - 1))) {
 				CDEBUG(D_WARNING,
 				       "Waiting for %d peers on peer table\n",
 				       ptable->pt_number);
@@ -167,11 +167,11 @@ lnet_destroy_peer_locked(lnet_peer_t *lp)
 {
 	struct lnet_peer_table *ptable;
 
-	LASSERT(lp->lp_refcount == 0);
-	LASSERT(lp->lp_rtr_refcount == 0);
+	LASSERT(!lp->lp_refcount);
+	LASSERT(!lp->lp_rtr_refcount);
 	LASSERT(list_empty(&lp->lp_txq));
 	LASSERT(list_empty(&lp->lp_hashlist));
-	LASSERT(lp->lp_txqnob == 0);
+	LASSERT(!lp->lp_txqnob);
 
 	ptable = the_lnet.ln_peer_tables[lp->lp_cpt];
 	LASSERT(ptable->pt_number > 0);
@@ -317,7 +317,7 @@ lnet_debug_peer(lnet_nid_t nid)
 	lnet_net_lock(cpt);
 
 	rc = lnet_nid2peer_locked(&lp, nid, cpt);
-	if (rc != 0) {
+	if (rc) {
 		lnet_net_unlock(cpt);
 		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nid2str(nid));
 		return;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index c6b747d..735a8f2 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -109,7 +109,7 @@ lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
 	lp->lp_timestamp = when;		/* update timestamp */
 	lp->lp_ping_deadline = 0;	       /* disable ping timeout */
 
-	if (lp->lp_alive_count != 0 &&	  /* got old news */
+	if (lp->lp_alive_count &&	  /* got old news */
 	    (!lp->lp_alive) == (!alive)) {      /* new date for old news */
 		CDEBUG(D_NET, "Old news\n");
 		return;
@@ -201,7 +201,7 @@ lnet_rtr_decref_locked(lnet_peer_t *lp)
 
 	/* lnet_net_lock must be exclusively locked */
 	lp->lp_rtr_refcount--;
-	if (lp->lp_rtr_refcount == 0) {
+	if (!lp->lp_rtr_refcount) {
 		LASSERT(list_empty(&lp->lp_routes));
 
 		if (lp->lp_rcd) {
@@ -283,7 +283,7 @@ lnet_add_route_to_rnet(lnet_remotenet_t *rnet, lnet_route_t *route)
 	/* len+1 positions to add a new entry, also prevents division by 0 */
 	offset = cfs_rand() % (len + 1);
 	list_for_each(e, &rnet->lrn_routes) {
-		if (offset == 0)
+		if (!offset)
 			break;
 		offset--;
 	}
@@ -342,7 +342,7 @@ lnet_add_route(__u32 net, unsigned int hops, lnet_nid_t gateway,
 	lnet_net_lock(LNET_LOCK_EX);
 
 	rc = lnet_nid2peer_locked(&route->lr_gateway, gateway, LNET_LOCK_EX);
-	if (rc != 0) {
+	if (rc) {
 		lnet_net_unlock(LNET_LOCK_EX);
 
 		LIBCFS_FREE(route, sizeof(*route));
@@ -565,7 +565,7 @@ lnet_get_route(int idx, __u32 *net, __u32 *hops,
 			list_for_each(e2, &rnet->lrn_routes) {
 				route = list_entry(e2, lnet_route_t, lr_list);
 
-				if (idx-- == 0) {
+				if (!idx--) {
 					*net      = rnet->lrn_net;
 					*hops     = route->lr_hops;
 					*priority = route->lr_priority;
@@ -625,13 +625,13 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 	}
 
 	gw->lp_ping_feats = info->pi_features;
-	if ((gw->lp_ping_feats & LNET_PING_FEAT_MASK) == 0) {
+	if (!(gw->lp_ping_feats & LNET_PING_FEAT_MASK)) {
 		CDEBUG(D_NET, "%s: Unexpected features 0x%x\n",
 		       libcfs_nid2str(gw->lp_nid), gw->lp_ping_feats);
 		return; /* nothing I can understand */
 	}
 
-	if ((gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) == 0)
+	if (!(gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS))
 		return; /* can't carry NI status info */
 
 	list_for_each_entry(rtr, &gw->lp_routes, lr_gwlist) {
@@ -722,7 +722,7 @@ lnet_router_checker_event(lnet_event_t *event)
 
 	if (event->type == LNET_EVENT_SEND) {
 		lp->lp_ping_notsent = 0;
-		if (event->status == 0)
+		if (!event->status)
 			goto out;
 	}
 
@@ -733,7 +733,7 @@ lnet_router_checker_event(lnet_event_t *event)
 	 * we ping alive routers to try to detect router death before
 	 * apps get burned).
 	 */
-	lnet_notify_locked(lp, 1, (event->status == 0), cfs_time_current());
+	lnet_notify_locked(lp, 1, !event->status, cfs_time_current());
 
 	/*
 	 * The router checker will wake up very shortly and do the
@@ -741,7 +741,7 @@ lnet_router_checker_event(lnet_event_t *event)
 	 * XXX If 'lp' stops being a router before then, it will still
 	 * have the notification pending!!!
 	 */
-	if (avoid_asym_router_failure && event->status == 0)
+	if (avoid_asym_router_failure && !event->status)
 		lnet_parse_rc_info(rcd);
 
  out:
@@ -764,7 +764,7 @@ lnet_wait_known_routerstate(void)
 		list_for_each(entry, &the_lnet.ln_routers) {
 			rtr = list_entry(entry, lnet_peer_t, lp_rtr_list);
 
-			if (rtr->lp_alive_count == 0) {
+			if (!rtr->lp_alive_count) {
 				all_known = 0;
 				break;
 			}
@@ -785,7 +785,7 @@ lnet_router_ni_update_locked(lnet_peer_t *gw, __u32 net)
 {
 	lnet_route_t *rte;
 
-	if ((gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS) != 0) {
+	if ((gw->lp_ping_feats & LNET_PING_FEAT_NI_STATUS)) {
 		list_for_each_entry(rte, &gw->lp_routes, lr_gwlist) {
 			if (rte->lr_net == net) {
 				rte->lr_downis = 0;
@@ -898,7 +898,7 @@ lnet_create_rc_data_locked(lnet_peer_t *gateway)
 		CERROR("Can't bind MD: %d\n", rc);
 		goto out;
 	}
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	lnet_net_lock(gateway->lp_cpt);
 	/* router table changed or someone has created rcd for this gateway */
@@ -918,7 +918,7 @@ lnet_create_rc_data_locked(lnet_peer_t *gateway)
 	if (rcd) {
 		if (!LNetHandleIsInvalid(rcd->rcd_mdh)) {
 			rc = LNetMDUnlink(rcd->rcd_mdh);
-			LASSERT(rc == 0);
+			LASSERT(!rc);
 		}
 		lnet_destroy_rc_data(rcd);
 	}
@@ -949,7 +949,7 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 
 	lnet_peer_addref_locked(rtr);
 
-	if (rtr->lp_ping_deadline != 0 && /* ping timed out? */
+	if (rtr->lp_ping_deadline && /* ping timed out? */
 	    cfs_time_after(now, rtr->lp_ping_deadline))
 		lnet_notify_locked(rtr, 1, 0, now);
 
@@ -977,7 +977,7 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 	       rtr->lp_ping_deadline, rtr->lp_ping_notsent,
 	       rtr->lp_alive, rtr->lp_alive_count, rtr->lp_ping_timestamp);
 
-	if (secs != 0 && !rtr->lp_ping_notsent &&
+	if (secs && !rtr->lp_ping_notsent &&
 	    cfs_time_after(now, cfs_time_add(rtr->lp_ping_timestamp,
 					     cfs_time_seconds(secs)))) {
 		int rc;
@@ -993,7 +993,7 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 
 		mdh = rcd->rcd_mdh;
 
-		if (rtr->lp_ping_deadline == 0) {
+		if (!rtr->lp_ping_deadline) {
 			rtr->lp_ping_deadline =
 				cfs_time_shift(router_ping_timeout);
 		}
@@ -1004,7 +1004,7 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 			     LNET_PROTO_PING_MATCHBITS, 0);
 
 		lnet_net_lock(rtr->lp_cpt);
-		if (rc != 0)
+		if (rc)
 			rtr->lp_ping_notsent = 0; /* no event pending */
 	}
 
@@ -1038,7 +1038,7 @@ lnet_router_checker_start(void)
 	eqsz = 0;
 	rc = LNetEQAlloc(eqsz, lnet_router_checker_event,
 			 &the_lnet.ln_rc_eqh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't allocate EQ(%d): %d\n", eqsz, rc);
 		return -ENOMEM;
 	}
@@ -1051,7 +1051,7 @@ lnet_router_checker_start(void)
 		/* block until event callback signals exit */
 		down(&the_lnet.ln_rc_signal);
 		rc = LNetEQFree(the_lnet.ln_rc_eqh);
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 		the_lnet.ln_rc_state = LNET_RC_STATE_SHUTDOWN;
 		return -ENOMEM;
 	}
@@ -1084,7 +1084,7 @@ lnet_router_checker_stop(void)
 	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_SHUTDOWN);
 
 	rc = LNetEQFree(the_lnet.ln_rc_eqh);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 }
 
 static void
@@ -1288,7 +1288,7 @@ lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp)
 	int nbuffers = 0;
 	lnet_rtrbuf_t *rb;
 
-	if (rbp->rbp_nbuffers == 0) /* not initialized or already freed */
+	if (!rbp->rbp_nbuffers) /* not initialized or already freed */
 		return;
 
 	LASSERT(list_empty(&rbp->rbp_msgs));
@@ -1317,7 +1317,7 @@ lnet_rtrpool_alloc_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
 	lnet_rtrbuf_t *rb;
 	int i;
 
-	if (rbp->rbp_nbuffers != 0) {
+	if (rbp->rbp_nbuffers) {
 		LASSERT(rbp->rbp_nbuffers == nbufs);
 		return 0;
 	}
@@ -1484,17 +1484,17 @@ lnet_rtrpools_alloc(int im_a_router)
 	cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
 		lnet_rtrpool_init(&rtrp[0], 0);
 		rc = lnet_rtrpool_alloc_bufs(&rtrp[0], nrb_tiny, i);
-		if (rc != 0)
+		if (rc)
 			goto failed;
 
 		lnet_rtrpool_init(&rtrp[1], small_pages);
 		rc = lnet_rtrpool_alloc_bufs(&rtrp[1], nrb_small, i);
-		if (rc != 0)
+		if (rc)
 			goto failed;
 
 		lnet_rtrpool_init(&rtrp[2], large_pages);
 		rc = lnet_rtrpool_alloc_bufs(&rtrp[2], nrb_large, i);
-		if (rc != 0)
+		if (rc)
 			goto failed;
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 230fc15..a7aaf0c 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -170,7 +170,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 
 	LASSERT(!write);
 
-	if (*lenp == 0)
+	if (!*lenp)
 		return 0;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
@@ -179,7 +179,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 
 	s = tmpstr; /* points to current position in tmpstr[] */
 
-	if (*ppos == 0) {
+	if (!*ppos) {
 		s += snprintf(s, tmpstr + tmpsiz - s, "Routing %s\n",
 			      the_lnet.ln_routing ? "enabled" : "disabled");
 		LASSERT(tmpstr + tmpsiz - s > 0);
@@ -224,7 +224,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 					lnet_route_t *re =
 						list_entry(r, lnet_route_t,
 							   lr_list);
-					if (skip == 0) {
+					if (!skip) {
 						route = re;
 						break;
 					}
@@ -271,7 +271,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 
 	LIBCFS_FREE(tmpstr, tmpsiz);
 
-	if (rc == 0)
+	if (!rc)
 		*lenp = len;
 
 	return rc;
@@ -293,7 +293,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 	LASSERT(!write);
 
-	if (*lenp == 0)
+	if (!*lenp)
 		return 0;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
@@ -302,7 +302,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 	s = tmpstr; /* points to current position in tmpstr[] */
 
-	if (*ppos == 0) {
+	if (!*ppos) {
 		s += snprintf(s, tmpstr + tmpsiz - s,
 			      "%-4s %7s %9s %6s %12s %9s %8s %7s %s\n",
 			      "ref", "rtr_ref", "alive_cnt", "state",
@@ -334,7 +334,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			lnet_peer_t *lp = list_entry(r, lnet_peer_t,
 						     lp_rtr_list);
 
-			if (skip == 0) {
+			if (!skip) {
 				peer = lp;
 				break;
 			}
@@ -358,21 +358,21 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			lnet_route_t *rtr;
 
 			if ((peer->lp_ping_feats &
-			     LNET_PING_FEAT_NI_STATUS) != 0) {
+			     LNET_PING_FEAT_NI_STATUS)) {
 				list_for_each_entry(rtr, &peer->lp_routes,
 						    lr_gwlist) {
 					/*
 					 * downis on any route should be the
 					 * number of downis on the gateway
 					 */
-					if (rtr->lr_downis != 0) {
+					if (rtr->lr_downis) {
 						down_ni = rtr->lr_downis;
 						break;
 					}
 				}
 			}
 
-			if (deadline == 0)
+			if (!deadline)
 				s += snprintf(s, tmpstr + tmpsiz - s,
 					      "%-4d %7d %9d %6s %12d %9d %8s %7d %s\n",
 					      nrefs, nrtrrefs, alive_cnt,
@@ -408,7 +408,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 
 	LIBCFS_FREE(tmpstr, tmpsiz);
 
-	if (rc == 0)
+	if (!rc)
 		*lenp = len;
 
 	return rc;
@@ -431,7 +431,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 	CLASSERT(LNET_PROC_HASH_BITS >= LNET_PEER_HASH_BITS);
 	LASSERT(!write);
 
-	if (*lenp == 0)
+	if (!*lenp)
 		return 0;
 
 	if (cpt >= LNET_CPT_NUMBER) {
@@ -445,7 +445,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 	s = tmpstr; /* points to current position in tmpstr[] */
 
-	if (*ppos == 0) {
+	if (!*ppos) {
 		s += snprintf(s, tmpstr + tmpsiz - s,
 			      "%-24s %4s %5s %5s %5s %5s %5s %5s %5s %s\n",
 			      "nid", "refs", "state", "last", "max",
@@ -480,7 +480,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			while (p != &ptable->pt_hash[hash]) {
 				lnet_peer_t *lp = list_entry(p, lnet_peer_t,
 							     lp_hashlist);
-				if (skip == 0) {
+				if (!skip) {
 					peer = lp;
 
 					/*
@@ -577,7 +577,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 	LIBCFS_FREE(tmpstr, tmpsiz);
 
-	if (rc == 0)
+	if (!rc)
 		*lenp = len;
 
 	return rc;
@@ -659,7 +659,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 
 	LASSERT(!write);
 
-	if (*lenp == 0)
+	if (!*lenp)
 		return 0;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
@@ -668,7 +668,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 
 	s = tmpstr; /* points to current position in tmpstr[] */
 
-	if (*ppos == 0) {
+	if (!*ppos) {
 		s += snprintf(s, tmpstr + tmpsiz - s,
 			      "%-24s %6s %5s %4s %4s %4s %5s %5s %5s\n",
 			      "nid", "status", "alive", "refs", "peer",
@@ -686,7 +686,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 		while (n != &the_lnet.ln_nis) {
 			lnet_ni_t *a_ni = list_entry(n, lnet_ni_t, ni_list);
 
-			if (skip == 0) {
+			if (!skip) {
 				ni = a_ni;
 				break;
 			}
@@ -730,7 +730,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 				if (j == ni->ni_ncpts)
 					continue;
 
-				if (i != 0)
+				if (i)
 					lnet_net_lock(i);
 
 				s += snprintf(s, tmpstr + tmpsiz - s,
@@ -742,7 +742,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 					      tq->tq_credits_max,
 					      tq->tq_credits,
 					      tq->tq_credits_min);
-				if (i != 0)
+				if (i)
 					lnet_net_unlock(i);
 			}
 			LASSERT(tmpstr + tmpsiz - s > 0);
@@ -764,7 +764,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 
 	LIBCFS_FREE(tmpstr, tmpsiz);
 
-	if (rc == 0)
+	if (!rc)
 		*lenp = len;
 
 	return rc;
@@ -854,8 +854,8 @@ static int __proc_lnet_portal_rotor(void *data, int write,
 	rc = -EINVAL;
 	lnet_res_lock(0);
 	for (i = 0; portal_rotors[i].pr_name; i++) {
-		if (strncasecmp(portal_rotors[i].pr_name, tmp,
-				strlen(portal_rotors[i].pr_name)) == 0) {
+		if (!strncasecmp(portal_rotors[i].pr_name, tmp,
+				 strlen(portal_rotors[i].pr_name))) {
 			portal_rotor = portal_rotors[i].pr_value;
 			rc = 0;
 			break;
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 38aed80..b71f4b4 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -80,7 +80,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 	LASSERT(sn);
 	LASSERT(tsi->tsi_is_client);
 
-	if ((sn->sn_features & LST_FEAT_BULK_LEN) == 0) {
+	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
 		test_bulk_req_t  *breq = &tsi->tsi_u.bulk_v0;
 
 		opc   = breq->blk_opc;
@@ -99,7 +99,7 @@ brw_client_init(sfw_test_instance_t *tsi)
 		 * I should never get this step if it's unknown feature
 		 * because make_session will reject unknown feature
 		 */
-		LASSERT((sn->sn_features & ~LST_FEATS_MASK) == 0);
+		LASSERT(!(sn->sn_features & ~LST_FEATS_MASK));
 
 		opc   = breq->blk_opc;
 		flags = breq->blk_flags;
@@ -145,7 +145,7 @@ brw_inject_one_error(void)
 
 	ktime_get_ts64(&ts);
 
-	if (((ts.tv_nsec / NSEC_PER_USEC) & 1) == 0)
+	if (!((ts.tv_nsec / NSEC_PER_USEC) & 1))
 		return 0;
 
 	return brw_inject_errors--;
@@ -244,7 +244,7 @@ brw_check_bulk(srpc_bulk_t *bk, int pattern, __u64 magic)
 
 	for (i = 0; i < bk->bk_niov; i++) {
 		pg = bk->bk_iovs[i].kiov_page;
-		if (brw_check_page(pg, pattern, magic) != 0) {
+		if (brw_check_page(pg, pattern, magic)) {
 			CERROR("Bulk page %p (%d/%d) is corrupted!\n",
 			       pg, i, bk->bk_niov);
 			return 1;
@@ -272,7 +272,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 	LASSERT(sn);
 	LASSERT(bulk);
 
-	if ((sn->sn_features & LST_FEAT_BULK_LEN) == 0) {
+	if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
 		test_bulk_req_t *breq = &tsi->tsi_u.bulk_v0;
 
 		opc   = breq->blk_opc;
@@ -287,7 +287,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 		 * I should never get this step if it's unknown feature
 		 * because make_session will reject unknown feature
 		 */
-		LASSERT((sn->sn_features & ~LST_FEATS_MASK) == 0);
+		LASSERT(!(sn->sn_features & ~LST_FEATS_MASK));
 
 		opc   = breq->blk_opc;
 		flags = breq->blk_flags;
@@ -296,7 +296,7 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 	}
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, npg, len, &rpc);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	memcpy(&rpc->crpc_bulk, bulk, offsetof(srpc_bulk_t, bk_iovs[npg]));
@@ -326,7 +326,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 
 	LASSERT(sn);
 
-	if (rpc->crpc_status != 0) {
+	if (rpc->crpc_status) {
 		CERROR("BRW RPC to %s failed with %d\n",
 		       libcfs_id2str(rpc->crpc_dest), rpc->crpc_status);
 		if (!tsi->tsi_stopping) /* rpc could have been aborted */
@@ -343,7 +343,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	       "BRW RPC to %s finished with brw_status: %d\n",
 	       libcfs_id2str(rpc->crpc_dest), reply->brw_status);
 
-	if (reply->brw_status != 0) {
+	if (reply->brw_status) {
 		atomic_inc(&sn->sn_brw_errors);
 		rpc->crpc_status = -(int)reply->brw_status;
 		goto out;
@@ -352,7 +352,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	if (reqst->brw_rw == LST_BRW_WRITE)
 		goto out;
 
-	if (brw_check_bulk(&rpc->crpc_bulk, reqst->brw_flags, magic) != 0) {
+	if (brw_check_bulk(&rpc->crpc_bulk, reqst->brw_flags, magic)) {
 		CERROR("Bulk data from %s is corrupted!\n",
 		       libcfs_id2str(rpc->crpc_dest));
 		atomic_inc(&sn->sn_brw_errors);
@@ -371,7 +371,7 @@ brw_server_rpc_done(struct srpc_server_rpc *rpc)
 	if (!blk)
 		return;
 
-	if (rpc->srpc_status != 0)
+	if (rpc->srpc_status)
 		CERROR("Bulk transfer %s %s has failed: %d\n",
 		       blk->bk_sink ? "from" : "to",
 		       libcfs_id2str(rpc->srpc_peer), rpc->srpc_status);
@@ -397,7 +397,7 @@ brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	reqstmsg = &rpc->srpc_reqstbuf->buf_msg;
 	reqst = &reqstmsg->msg_body.brw_reqst;
 
-	if (status != 0) {
+	if (status) {
 		CERROR("BRW bulk %s failed for RPC from %s: %d\n",
 		       reqst->brw_rw == LST_BRW_READ ? "READ" : "WRITE",
 		       libcfs_id2str(rpc->srpc_peer), status);
@@ -410,7 +410,7 @@ brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	if (reqstmsg->msg_magic != SRPC_MSG_MAGIC)
 		__swab64s(&magic);
 
-	if (brw_check_bulk(rpc->srpc_bulk, reqst->brw_flags, magic) != 0) {
+	if (brw_check_bulk(rpc->srpc_bulk, reqst->brw_flags, magic)) {
 		CERROR("Bulk data from %s is corrupted!\n",
 		       libcfs_id2str(rpc->srpc_peer));
 		reply->brw_status = EBADMSG;
@@ -454,15 +454,15 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 		return 0;
 	}
 
-	if ((reqstmsg->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
+	if (reqstmsg->msg_ses_feats & ~LST_FEATS_MASK) {
 		replymsg->msg_ses_feats = LST_FEATS_MASK;
 		reply->brw_status = EPROTO;
 		return 0;
 	}
 
-	if ((reqstmsg->msg_ses_feats & LST_FEAT_BULK_LEN) == 0) {
+	if (!(reqstmsg->msg_ses_feats & LST_FEAT_BULK_LEN)) {
 		/* compat with old version */
-		if ((reqst->brw_len & ~CFS_PAGE_MASK) != 0) {
+		if (reqst->brw_len & ~CFS_PAGE_MASK) {
 			reply->brw_status = EINVAL;
 			return 0;
 		}
@@ -474,7 +474,7 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 
 	replymsg->msg_ses_feats = reqstmsg->msg_ses_feats;
 
-	if (reqst->brw_len == 0 || npg > LNET_MAX_IOV) {
+	if (!reqst->brw_len || npg > LNET_MAX_IOV) {
 		reply->brw_status = EINVAL;
 		return 0;
 	}
@@ -482,7 +482,7 @@ brw_server_handle(struct srpc_server_rpc *rpc)
 	rc = sfw_alloc_pages(rpc, rpc->srpc_scd->scd_cpt, npg,
 			     reqst->brw_len,
 			     reqst->brw_rw == LST_BRW_WRITE);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	if (reqst->brw_rw == LST_BRW_READ)
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 8b9717c..210e24e 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -52,7 +52,7 @@ lst_session_new_ioctl(lstio_session_new_args_t *args)
 	int rc;
 
 	if (!args->lstio_ses_idp || /* address for output sid */
-	    args->lstio_ses_key   == 0 ||    /* no key is specified */
+	    !args->lstio_ses_key ||    /* no key is specified */
 	    !args->lstio_ses_namep || /* session name */
 	    args->lstio_ses_nmlen <= 0 ||
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
@@ -354,7 +354,7 @@ lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
 			      args->lstio_grp_resultp);
 
 	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
-	if (rc == 0 &&
+	if (!rc &&
 	    copy_to_user(args->lstio_grp_featp, &feats, sizeof(feats))) {
 		return -EINVAL;
 	}
@@ -431,7 +431,7 @@ lst_group_info_ioctl(lstio_group_info_args_t *args)
 
 	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
 
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	if (args->lstio_grp_dentsp &&
@@ -655,7 +655,7 @@ lst_batch_info_ioctl(lstio_batch_info_args_t *args)
 
 	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
 
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	if (args->lstio_bat_dentsp &&
@@ -733,7 +733,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	    args->lstio_tes_dgrp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	if (args->lstio_tes_loop == 0 || /* negative is infinite */
+	if (!args->lstio_tes_loop || /* negative is infinite */
 	    args->lstio_tes_concur <= 0 ||
 	    args->lstio_tes_dist <= 0 ||
 	    args->lstio_tes_span <= 0)
@@ -781,7 +781,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 			     args->lstio_tes_param_len,
 			     &ret, args->lstio_tes_resultp);
 
-	if (ret != 0)
+	if (ret)
 		rc = (copy_to_user(args->lstio_tes_retp, &ret,
 				   sizeof(ret))) ? -EFAULT : 0;
 out:
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 5315a37..b02a140 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -74,9 +74,9 @@ lstcon_rpc_done(srpc_client_rpc_t *rpc)
 	/* not an orphan RPC */
 	crpc->crp_finished = 1;
 
-	if (crpc->crp_stamp == 0) {
+	if (!crpc->crp_stamp) {
 		/* not aborted */
-		LASSERT(crpc->crp_status == 0);
+		LASSERT(!crpc->crp_status);
 
 		crpc->crp_stamp  = cfs_time_current();
 		crpc->crp_status = rpc->crpc_status;
@@ -138,7 +138,7 @@ lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
 	}
 
 	rc = lstcon_rpc_init(nd, service, feats, bulk_npg, bulk_len, 0, crpc);
-	if (rc == 0) {
+	if (!rc) {
 		*crpcpp = crpc;
 		return 0;
 	}
@@ -298,8 +298,8 @@ lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 		spin_lock(&rpc->crpc_lock);
 
 		if (!crpc->crp_posted || /* not posted */
-		    crpc->crp_stamp != 0) { /* rpc done or aborted already */
-			if (crpc->crp_stamp == 0) {
+		    crpc->crp_stamp) { /* rpc done or aborted already */
+			if (!crpc->crp_stamp) {
 				crpc->crp_stamp = cfs_time_current();
 				crpc->crp_status = -EINTR;
 			}
@@ -333,7 +333,7 @@ lstcon_rpc_trans_check(lstcon_rpc_trans_t *trans)
 	    !list_empty(&trans->tas_olink)) /* Not an end session RPC */
 		return 1;
 
-	return (atomic_read(&trans->tas_remaining) == 0) ? 1 : 0;
+	return !atomic_read(&trans->tas_remaining) ? 1 : 0;
 }
 
 int
@@ -370,7 +370,7 @@ lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout)
 	if (console_session.ses_shutdown)
 		rc = -ESHUTDOWN;
 
-	if (rc != 0 || atomic_read(&trans->tas_remaining) != 0) {
+	if (rc || atomic_read(&trans->tas_remaining)) {
 		/* treat short timeout as canceled */
 		if (rc == -ETIMEDOUT && timeout < LST_TRANS_MIN_TIMEOUT * 2)
 			rc = -EINTR;
@@ -394,9 +394,9 @@ lstcon_rpc_get_reply(lstcon_rpc_t *crpc, srpc_msg_t **msgpp)
 	srpc_generic_reply_t *rep;
 
 	LASSERT(nd && rpc);
-	LASSERT(crpc->crp_stamp != 0);
+	LASSERT(crpc->crp_stamp);
 
-	if (crpc->crp_status != 0) {
+	if (crpc->crp_status) {
 		*msgpp = NULL;
 		return crpc->crp_status;
 	}
@@ -437,12 +437,12 @@ lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 	list_for_each_entry(crpc, &trans->tas_rpcs_list, crp_link) {
 		lstcon_rpc_stat_total(stat, 1);
 
-		LASSERT(crpc->crp_stamp != 0);
+		LASSERT(crpc->crp_stamp);
 
 		error = lstcon_rpc_get_reply(crpc, &rep);
-		if (error != 0) {
+		if (error) {
 			lstcon_rpc_stat_failure(stat, 1);
-			if (stat->trs_rpc_errno == 0)
+			if (!stat->trs_rpc_errno)
 				stat->trs_rpc_errno = -error;
 
 			continue;
@@ -453,7 +453,7 @@ lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 		lstcon_rpc_stat_reply(trans, rep, crpc->crp_node, stat);
 	}
 
-	if (trans->tas_opc == LST_TRANS_SESNEW && stat->trs_fwk_errno == 0) {
+	if (trans->tas_opc == LST_TRANS_SESNEW && !stat->trs_fwk_errno) {
 		stat->trs_fwk_errno =
 		      lstcon_session_feats_check(trans->tas_features);
 	}
@@ -500,7 +500,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 
 		ent = list_entry(next, lstcon_rpc_ent_t, rpe_link);
 
-		LASSERT(crpc->crp_stamp != 0);
+		LASSERT(crpc->crp_stamp);
 
 		error = lstcon_rpc_get_reply(crpc, &msg);
 
@@ -519,7 +519,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 				 sizeof(error)))
 			return -EFAULT;
 
-		if (error != 0)
+		if (error)
 			continue;
 
 		/* RPC is done */
@@ -535,7 +535,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 
 		error = readent(trans->tas_opc, msg, ent);
 
-		if (error != 0)
+		if (error)
 			return error;
 	}
 
@@ -572,7 +572,7 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 		 * user wait for them, just abandon them, they will be recycled
 		 * in callback
 		 */
-		LASSERT(crpc->crp_status != 0);
+		LASSERT(crpc->crp_status);
 
 		crpc->crp_node  = NULL;
 		crpc->crp_trans = NULL;
@@ -584,7 +584,7 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 		atomic_dec(&trans->tas_remaining);
 	}
 
-	LASSERT(atomic_read(&trans->tas_remaining) == 0);
+	LASSERT(!atomic_read(&trans->tas_remaining));
 
 	list_del(&trans->tas_link);
 	if (!list_empty(&trans->tas_olink))
@@ -610,7 +610,7 @@ lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
 	case LST_TRANS_SESNEW:
 		rc = lstcon_rpc_prep(nd, SRPC_SERVICE_MAKE_SESSION,
 				     feats, 0, 0, crpc);
-		if (rc != 0)
+		if (rc)
 			return rc;
 
 		msrq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.mksn_reqst;
@@ -623,7 +623,7 @@ lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
 	case LST_TRANS_SESEND:
 		rc = lstcon_rpc_prep(nd, SRPC_SERVICE_REMOVE_SESSION,
 				     feats, 0, 0, crpc);
-		if (rc != 0)
+		if (rc)
 			return rc;
 
 		rsrq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.rmsn_reqst;
@@ -644,7 +644,7 @@ lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
 	int rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_DEBUG, feats, 0, 0, crpc);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	drq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.dbg_reqst;
@@ -664,7 +664,7 @@ lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	int		    rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_BATCH, feats, 0, 0, crpc);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	brq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.bat_reqst;
@@ -680,7 +680,7 @@ lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	    transop != LST_TRANS_TSBSTOP)
 		return 0;
 
-	LASSERT(tsb->tsb_index == 0);
+	LASSERT(!tsb->tsb_index);
 
 	batch = (lstcon_batch_t *)tsb;
 	brq->bar_arg = batch->bat_arg;
@@ -695,7 +695,7 @@ lstcon_statrpc_prep(lstcon_node_t *nd, unsigned feats, lstcon_rpc_t **crpc)
 	int		   rc;
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_QUERY_STAT, feats, 0, 0, crpc);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	srq = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.stat_reqst;
@@ -827,13 +827,13 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 
 	if (transop == LST_TRANS_TSBCLIADD) {
 		npg = sfw_id_pages(test->tes_span);
-		nob = (feats & LST_FEAT_BULK_LEN) == 0 ?
+		nob = !(feats & LST_FEAT_BULK_LEN) ?
 		      npg * PAGE_CACHE_SIZE :
 		      sizeof(lnet_process_id_packed_t) * test->tes_span;
 	}
 
 	rc = lstcon_rpc_prep(nd, SRPC_SERVICE_TEST, feats, npg, nob, crpc);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	trq  = &(*crpc)->crp_rpc->crpc_reqstmsg.msg_body.tes_reqst;
@@ -856,7 +856,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 
 			LASSERT(nob > 0);
 
-			len = (feats & LST_FEAT_BULK_LEN) == 0 ?
+			len = !(feats & LST_FEAT_BULK_LEN) ?
 			      PAGE_CACHE_SIZE :
 			      min_t(int, nob, PAGE_CACHE_SIZE);
 			nob -= len;
@@ -881,7 +881,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 					  test->tes_dist,
 					  test->tes_span,
 					  npg, &bulk->bk_iovs[0]);
-		if (rc != 0) {
+		if (rc) {
 			lstcon_rpc_put(*crpc);
 			return rc;
 		}
@@ -905,7 +905,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 
 	case LST_TEST_BULK:
 		trq->tsr_service = SRPC_SERVICE_BRW;
-		if ((feats & LST_FEAT_BULK_LEN) == 0) {
+		if (!(feats & LST_FEAT_BULK_LEN)) {
 			rc = lstcon_bulkrpc_v0_prep((lst_test_bulk_param_t *)
 						    &test->tes_param[0], trq);
 		} else {
@@ -929,8 +929,8 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 	srpc_mksn_reply_t *mksn_rep = &reply->msg_body.mksn_reply;
 	int		   status   = mksn_rep->mksn_status;
 
-	if (status == 0 &&
-	    (reply->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
+	if (!status &&
+	    (reply->msg_ses_feats & ~LST_FEATS_MASK)) {
 		mksn_rep->mksn_status = EPROTO;
 		status = EPROTO;
 	}
@@ -941,7 +941,7 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 			reply->msg_ses_feats);
 	}
 
-	if (status != 0)
+	if (status)
 		return status;
 
 	if (!trans->tas_feats_updated) {
@@ -957,7 +957,7 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 		status = EPROTO;
 	}
 
-	if (status == 0) {
+	if (!status) {
 		/* session timeout on remote node */
 		nd->nd_timeout = mksn_rep->mksn_timeout;
 	}
@@ -979,7 +979,7 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 	switch (trans->tas_opc) {
 	case LST_TRANS_SESNEW:
 		rc = lstcon_sesnew_stat_reply(trans, nd, msg);
-		if (rc == 0) {
+		if (!rc) {
 			lstcon_sesop_stat_success(stat, 1);
 			return;
 		}
@@ -990,7 +990,7 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 	case LST_TRANS_SESEND:
 		rmsn_rep = &msg->msg_body.rmsn_reply;
 		/* ESRCH is not an error for end session */
-		if (rmsn_rep->rmsn_status == 0 ||
+		if (!rmsn_rep->rmsn_status ||
 		    rmsn_rep->rmsn_status == ESRCH) {
 			lstcon_sesop_stat_success(stat, 1);
 			return;
@@ -1019,7 +1019,7 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 	case LST_TRANS_TSBSTOP:
 		bat_rep = &msg->msg_body.bat_reply;
 
-		if (bat_rep->bar_status == 0) {
+		if (!bat_rep->bar_status) {
 			lstcon_tsbop_stat_success(stat, 1);
 			return;
 		}
@@ -1038,12 +1038,12 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 	case LST_TRANS_TSBSRVQRY:
 		bat_rep = &msg->msg_body.bat_reply;
 
-		if (bat_rep->bar_active != 0)
+		if (bat_rep->bar_active)
 			lstcon_tsbqry_stat_run(stat, 1);
 		else
 			lstcon_tsbqry_stat_idle(stat, 1);
 
-		if (bat_rep->bar_status == 0)
+		if (!bat_rep->bar_status)
 			return;
 
 		lstcon_tsbqry_stat_failure(stat, 1);
@@ -1054,7 +1054,7 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 	case LST_TRANS_TSBSRVADD:
 		test_rep = &msg->msg_body.tes_reply;
 
-		if (test_rep->tsr_status == 0) {
+		if (!test_rep->tsr_status) {
 			lstcon_tsbop_stat_success(stat, 1);
 			return;
 		}
@@ -1066,7 +1066,7 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 	case LST_TRANS_STATQRY:
 		stat_rep = &msg->msg_body.stat_reply;
 
-		if (stat_rep->str_status == 0) {
+		if (!stat_rep->str_status) {
 			lstcon_statqry_stat_success(stat, 1);
 			return;
 		}
@@ -1079,7 +1079,7 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 		LBUG();
 	}
 
-	if (stat->trs_fwk_errno == 0)
+	if (!stat->trs_fwk_errno)
 		stat->trs_fwk_errno = rc;
 
 	return;
@@ -1101,7 +1101,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 	/* Creating session RPG for list of nodes */
 
 	rc = lstcon_rpc_trans_prep(translist, transop, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction %d: %d\n", transop, rc);
 		return rc;
 	}
@@ -1111,7 +1111,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 		rc = !condition ? 1 :
 		     condition(transop, ndl->ndl_node, arg);
 
-		if (rc == 0)
+		if (!rc)
 			continue;
 
 		if (rc < 0) {
@@ -1151,7 +1151,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 			break;
 		}
 
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Failed to create RPC for transaction %s: %d\n",
 			       lstcon_rpc_trans_name(transop), rc);
 			break;
@@ -1160,7 +1160,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 		lstcon_rpc_trans_addreq(trans, rpc);
 	}
 
-	if (rc == 0) {
+	if (!rc) {
 		*transpp = trans;
 		return 0;
 	}
@@ -1213,7 +1213,7 @@ lstcon_rpc_pinger(void *arg)
 
 			rc = lstcon_sesrpc_prep(nd, LST_TRANS_SESEND,
 						trans->tas_features, &crpc);
-			if (rc != 0) {
+			if (rc) {
 				CERROR("Out of memory\n");
 				break;
 			}
@@ -1258,7 +1258,7 @@ lstcon_rpc_pinger(void *arg)
 
 		rc = lstcon_rpc_init(nd, SRPC_SERVICE_DEBUG,
 				     trans->tas_features, 0, 0, 1, crpc);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Out of memory\n");
 			break;
 		}
@@ -1294,11 +1294,11 @@ lstcon_rpc_pinger_start(void)
 	int rc;
 
 	LASSERT(list_empty(&console_session.ses_rpc_freelist));
-	LASSERT(atomic_read(&console_session.ses_rpc_counter) == 0);
+	LASSERT(!atomic_read(&console_session.ses_rpc_counter));
 
 	rc = lstcon_rpc_trans_prep(NULL, LST_TRANS_SESPING,
 				   &console_session.ses_ping);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Failed to create console pinger\n");
 		return rc;
 	}
@@ -1361,7 +1361,7 @@ lstcon_rpc_cleanup_wait(void)
 
 	spin_lock(&console_session.ses_rpc_lock);
 
-	lst_wait_until((atomic_read(&console_session.ses_rpc_counter) == 0),
+	lst_wait_until(!atomic_read(&console_session.ses_rpc_counter),
 		       console_session.ses_rpc_lock,
 		       "Network is not accessible or target is down, waiting for %d console RPCs to being recycled\n",
 		       atomic_read(&console_session.ses_rpc_counter));
@@ -1399,5 +1399,5 @@ void
 lstcon_rpc_module_fini(void)
 {
 	LASSERT(list_empty(&console_session.ses_rpc_freelist));
-	LASSERT(atomic_read(&console_session.ses_rpc_counter) == 0);
+	LASSERT(!atomic_read(&console_session.ses_rpc_counter));
 }
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 8995417..59cd554 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -159,12 +159,12 @@ lstcon_ndlink_find(struct list_head *hash,
 		return 0;
 	}
 
-	if (create == 0)
+	if (!create)
 		return -ENOENT;
 
 	/* find or create in session hash */
 	rc = lstcon_node_find(id, &nd, (create == 1) ? 1 : 0);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	LIBCFS_ALLOC(ndl, sizeof(lstcon_ndlink_t));
@@ -236,7 +236,7 @@ lstcon_group_drain(lstcon_group_t *grp, int keep)
 	lstcon_ndlink_t *tmp;
 
 	list_for_each_entry_safe(ndl, tmp, &grp->grp_ndl_list, ndl_link) {
-		if ((ndl->ndl_node->nd_state & keep) == 0)
+		if (!(ndl->ndl_node->nd_state & keep))
 			lstcon_group_ndlink_release(grp, ndl);
 	}
 }
@@ -267,7 +267,7 @@ lstcon_group_find(const char *name, lstcon_group_t **grpp)
 	lstcon_group_t *grp;
 
 	list_for_each_entry(grp, &console_session.ses_grp_list, grp_link) {
-		if (strncmp(grp->grp_name, name, LST_NAME_SIZE) != 0)
+		if (strncmp(grp->grp_name, name, LST_NAME_SIZE))
 			continue;
 
 		lstcon_group_addref(grp);  /* +1 ref for caller */
@@ -285,7 +285,7 @@ lstcon_group_ndlink_find(lstcon_group_t *grp, lnet_process_id_t id,
 	int rc;
 
 	rc = lstcon_ndlink_find(&grp->grp_ndl_hash[0], id, ndlpp, create);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	if (!list_empty(&(*ndlpp)->ndl_link))
@@ -404,7 +404,7 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 	int rc;
 
 	rc = lstcon_group_alloc(NULL, &tmp);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Out of memory\n");
 		return -ENOMEM;
 	}
@@ -417,18 +417,18 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 
 		/* skip if it's in this group already */
 		rc = lstcon_group_ndlink_find(grp, id, &ndl, 0);
-		if (rc == 0)
+		if (!rc)
 			continue;
 
 		/* add to tmp group */
 		rc = lstcon_group_ndlink_find(tmp, id, &ndl, 1);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't create ndlink, out of memory\n");
 			break;
 		}
 	}
 
-	if (rc != 0) {
+	if (rc) {
 		lstcon_group_decref(tmp);
 		return rc;
 	}
@@ -436,7 +436,7 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 	rc = lstcon_rpc_trans_ndlist(&tmp->grp_ndl_list,
 				     &tmp->grp_trans_list, LST_TRANS_SESNEW,
 				     tmp, lstcon_sesrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		lstcon_group_decref(tmp);
 		return rc;
@@ -473,7 +473,7 @@ lstcon_group_nodes_remove(lstcon_group_t *grp,
 	/* End session and remove node from the group */
 
 	rc = lstcon_group_alloc(NULL, &tmp);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Out of memory\n");
 		return -ENOMEM;
 	}
@@ -485,14 +485,14 @@ lstcon_group_nodes_remove(lstcon_group_t *grp,
 		}
 
 		/* move node to tmp group */
-		if (lstcon_group_ndlink_find(grp, id, &ndl, 0) == 0)
+		if (!lstcon_group_ndlink_find(grp, id, &ndl, 0))
 			lstcon_group_ndlink_move(grp, tmp, ndl);
 	}
 
 	rc = lstcon_rpc_trans_ndlist(&tmp->grp_ndl_list,
 				     &tmp->grp_trans_list, LST_TRANS_SESEND,
 				     tmp, lstcon_sesrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		goto error;
 	}
@@ -519,15 +519,15 @@ lstcon_group_add(char *name)
 	lstcon_group_t *grp;
 	int rc;
 
-	rc = (lstcon_group_find(name, &grp) == 0) ? -EEXIST : 0;
-	if (rc != 0) {
+	rc = lstcon_group_find(name, &grp) ? 0: -EEXIST;
+	if (rc) {
 		/* find a group with same name */
 		lstcon_group_decref(grp);
 		return rc;
 	}
 
 	rc = lstcon_group_alloc(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't allocate descriptor for group %s\n", name);
 		return -ENOMEM;
 	}
@@ -548,7 +548,7 @@ lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
 	LASSERT(ids_up);
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group %s\n", name);
 		return rc;
 	}
@@ -576,7 +576,7 @@ lstcon_group_del(char *name)
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group: %s\n", name);
 		return rc;
 	}
@@ -591,7 +591,7 @@ lstcon_group_del(char *name)
 	rc = lstcon_rpc_trans_ndlist(&grp->grp_ndl_list,
 				     &grp->grp_trans_list, LST_TRANS_SESEND,
 				     grp, lstcon_sesrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		lstcon_group_decref(grp);
 		return rc;
@@ -618,7 +618,7 @@ lstcon_group_clean(char *name, int args)
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group %s\n", name);
 		return rc;
 	}
@@ -651,7 +651,7 @@ lstcon_nodes_remove(char *name, int count, lnet_process_id_t __user *ids_up,
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group: %s\n", name);
 		return rc;
 	}
@@ -681,7 +681,7 @@ lstcon_group_refresh(char *name, struct list_head __user *result_up)
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group: %s\n", name);
 		return rc;
 	}
@@ -697,7 +697,7 @@ lstcon_group_refresh(char *name, struct list_head __user *result_up)
 	rc = lstcon_rpc_trans_ndlist(&grp->grp_ndl_list,
 				     &grp->grp_trans_list, LST_TRANS_SESNEW,
 				     grp, lstcon_sesrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		/* local error, return */
 		CDEBUG(D_NET, "Can't create transaction: %d\n", rc);
 		lstcon_group_decref(grp);
@@ -724,7 +724,7 @@ lstcon_group_list(int index, int len, char __user *name_up)
 	LASSERT(name_up);
 
 	list_for_each_entry(grp, &console_session.ses_grp_list, grp_link) {
-		if (index-- == 0) {
+		if (!index--) {
 			return copy_to_user(name_up, grp->grp_name, len) ?
 			       -EFAULT : 0;
 		}
@@ -784,7 +784,7 @@ lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group %s\n", name);
 		return rc;
 	}
@@ -826,7 +826,7 @@ lstcon_batch_find(const char *name, lstcon_batch_t **batpp)
 	lstcon_batch_t *bat;
 
 	list_for_each_entry(bat, &console_session.ses_bat_list, bat_link) {
-		if (strncmp(bat->bat_name, name, LST_NAME_SIZE) == 0) {
+		if (!strncmp(bat->bat_name, name, LST_NAME_SIZE)) {
 			*batpp = bat;
 			return 0;
 		}
@@ -842,8 +842,8 @@ lstcon_batch_add(char *name)
 	int i;
 	int rc;
 
-	rc = (lstcon_batch_find(name, &bat) == 0) ? -EEXIST : 0;
-	if (rc != 0) {
+	rc = !lstcon_batch_find(name, &bat) ? -EEXIST : 0;
+	if (rc) {
 		CDEBUG(D_NET, "Batch %s already exists\n", name);
 		return rc;
 	}
@@ -904,7 +904,7 @@ lstcon_batch_list(int index, int len, char __user *name_up)
 	LASSERT(index >= 0);
 
 	list_for_each_entry(bat, &console_session.ses_bat_list, bat_link) {
-		if (index-- == 0) {
+		if (!index--) {
 			return copy_to_user(name_up, bat->bat_name, len) ?
 			       -EFAULT : 0;
 		}
@@ -927,7 +927,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 	int rc;
 
 	rc = lstcon_batch_find(name, &bat);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find batch %s\n", name);
 		return -ENOENT;
 	}
@@ -1017,7 +1017,7 @@ lstcon_batch_op(lstcon_batch_t *bat, int transop,
 	rc = lstcon_rpc_trans_ndlist(&bat->bat_cli_list,
 				     &bat->bat_trans_list, transop,
 				     bat, lstcon_batrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		return rc;
 	}
@@ -1037,7 +1037,7 @@ lstcon_batch_run(char *name, int timeout, struct list_head __user *result_up)
 	lstcon_batch_t *bat;
 	int rc;
 
-	if (lstcon_batch_find(name, &bat) != 0) {
+	if (lstcon_batch_find(name, &bat)) {
 		CDEBUG(D_NET, "Can't find batch %s\n", name);
 		return -ENOENT;
 	}
@@ -1047,7 +1047,7 @@ lstcon_batch_run(char *name, int timeout, struct list_head __user *result_up)
 	rc = lstcon_batch_op(bat, LST_TRANS_TSBRUN, result_up);
 
 	/* mark batch as running if it's started in any node */
-	if (lstcon_tsbop_stat_success(lstcon_trans_stat(), 0) != 0)
+	if (lstcon_tsbop_stat_success(lstcon_trans_stat(), 0))
 		bat->bat_state = LST_BATCH_RUNNING;
 
 	return rc;
@@ -1059,7 +1059,7 @@ lstcon_batch_stop(char *name, int force, struct list_head __user *result_up)
 	lstcon_batch_t *bat;
 	int rc;
 
-	if (lstcon_batch_find(name, &bat) != 0) {
+	if (lstcon_batch_find(name, &bat)) {
 		CDEBUG(D_NET, "Can't find batch %s\n", name);
 		return -ENOENT;
 	}
@@ -1069,7 +1069,7 @@ lstcon_batch_stop(char *name, int force, struct list_head __user *result_up)
 	rc = lstcon_batch_op(bat, LST_TRANS_TSBSTOP, result_up);
 
 	/* mark batch as stopped if all RPCs finished */
-	if (lstcon_tsbop_stat_failure(lstcon_trans_stat(), 0) == 0)
+	if (!lstcon_tsbop_stat_failure(lstcon_trans_stat(), 0))
 		bat->bat_state = LST_BATCH_IDLE;
 
 	return rc;
@@ -1163,7 +1163,7 @@ lstcon_testrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 
 	LASSERT(nd->nd_id.nid != LNET_NID_ANY);
 
-	if (lstcon_ndlink_find(hash, nd->nd_id, &ndl, 1) != 0)
+	if (lstcon_ndlink_find(hash, nd->nd_id, &ndl, 1))
 		return -ENOMEM;
 
 	if (list_empty(&ndl->ndl_link))
@@ -1189,15 +1189,15 @@ again:
 	rc = lstcon_rpc_trans_ndlist(&grp->grp_ndl_list,
 				     &test->tes_trans_list, transop,
 				     test, lstcon_testrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		return rc;
 	}
 
 	lstcon_rpc_trans_postwait(trans, LST_TRANS_TIMEOUT);
 
-	if (lstcon_trans_stat()->trs_rpc_errno != 0 ||
-	    lstcon_trans_stat()->trs_fwk_errno != 0) {
+	if (lstcon_trans_stat()->trs_rpc_errno ||
+	    lstcon_trans_stat()->trs_fwk_errno) {
 		lstcon_rpc_trans_interpreter(trans, result_up, NULL);
 
 		lstcon_rpc_trans_destroy(trans);
@@ -1229,7 +1229,7 @@ lstcon_verify_batch(const char *name, lstcon_batch_t **batch)
 	int rc;
 
 	rc = lstcon_batch_find(name, batch);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find batch %s\n", name);
 		return rc;
 	}
@@ -1249,7 +1249,7 @@ lstcon_verify_group(const char *name, lstcon_group_t **grp)
 	lstcon_ndlink_t *ndl;
 
 	rc = lstcon_group_find(name, grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "can't find group %s\n", name);
 		return rc;
 	}
@@ -1283,15 +1283,15 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	 * active node
 	 */
 	rc = lstcon_verify_batch(batch_name, &batch);
-	if (rc != 0)
+	if (rc)
 		goto out;
 
 	rc = lstcon_verify_group(src_name, &src_grp);
-	if (rc != 0)
+	if (rc)
 		goto out;
 
 	rc = lstcon_verify_group(dst_name, &dst_grp);
-	if (rc != 0)
+	if (rc)
 		goto out;
 
 	if (dst_grp->grp_userland)
@@ -1326,11 +1326,11 @@ lstcon_test_add(char *batch_name, int type, int loop,
 
 	rc = lstcon_test_nodes_add(test, result_up);
 
-	if (rc != 0)
+	if (rc)
 		goto out;
 
-	if (lstcon_trans_stat()->trs_rpc_errno != 0 ||
-	    lstcon_trans_stat()->trs_fwk_errno != 0)
+	if (lstcon_trans_stat()->trs_rpc_errno ||
+	    lstcon_trans_stat()->trs_fwk_errno)
 		CDEBUG(D_NET, "Failed to add test %d to batch %s\n", type,
 		       batch_name);
 
@@ -1401,12 +1401,12 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 	int rc;
 
 	rc = lstcon_batch_find(name, &batch);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find batch: %s\n", name);
 		return rc;
 	}
 
-	if (testidx == 0) {
+	if (!testidx) {
 		translist = &batch->bat_trans_list;
 		ndlist    = &batch->bat_cli_list;
 		hdr       = &batch->bat_hdr;
@@ -1414,7 +1414,7 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 	} else {
 		/* query specified test only */
 		rc = lstcon_test_find(batch, testidx, &test);
-		if (rc != 0) {
+		if (rc) {
 			CDEBUG(D_NET, "Can't find test: %d\n", testidx);
 			return rc;
 		}
@@ -1428,16 +1428,16 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 
 	rc = lstcon_rpc_trans_ndlist(ndlist, translist, transop, hdr,
 				     lstcon_batrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		return rc;
 	}
 
 	lstcon_rpc_trans_postwait(trans, timeout);
 
-	if (testidx == 0 && /* query a batch, not a test */
-	    lstcon_rpc_stat_failure(lstcon_trans_stat(), 0) == 0 &&
-	    lstcon_tsbqry_stat_run(lstcon_trans_stat(), 0) == 0) {
+	if (!testidx && /* query a batch, not a test */
+	    !lstcon_rpc_stat_failure(lstcon_trans_stat(), 0) &&
+	    !lstcon_tsbqry_stat_run(lstcon_trans_stat(), 0)) {
 		/* all RPCs finished, and no active test */
 		batch->bat_state = LST_BATCH_IDLE;
 	}
@@ -1458,7 +1458,7 @@ lstcon_statrpc_readent(int transop, srpc_msg_t *msg,
 	srpc_counters_t __user *srpc_stat;
 	lnet_counters_t __user *lnet_stat;
 
-	if (rep->str_status != 0)
+	if (rep->str_status)
 		return 0;
 
 	sfwk_stat = (sfw_counters_t __user *)&ent_up->rpe_payload[0];
@@ -1487,7 +1487,7 @@ lstcon_ndlist_stat(struct list_head *ndlist,
 
 	rc = lstcon_rpc_trans_ndlist(ndlist, &head,
 				     LST_TRANS_STATQRY, NULL, NULL, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		return rc;
 	}
@@ -1509,7 +1509,7 @@ lstcon_group_stat(char *grp_name, int timeout,
 	int rc;
 
 	rc = lstcon_group_find(grp_name, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Can't find group %s\n", grp_name);
 		return rc;
 	}
@@ -1532,7 +1532,7 @@ lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
 	int rc;
 
 	rc = lstcon_group_alloc(NULL, &tmp);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Out of memory\n");
 		return -ENOMEM;
 	}
@@ -1545,7 +1545,7 @@ lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
 
 		/* add to tmp group */
 		rc = lstcon_group_ndlink_find(tmp, id, &ndl, 2);
-		if (rc != 0) {
+		if (rc) {
 			CDEBUG((rc == -ENOMEM) ? D_ERROR : D_NET,
 			       "Failed to find or create %s: %d\n",
 			       libcfs_id2str(id), rc);
@@ -1553,7 +1553,7 @@ lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
 		}
 	}
 
-	if (rc != 0) {
+	if (rc) {
 		lstcon_group_decref(tmp);
 		return rc;
 	}
@@ -1575,7 +1575,7 @@ lstcon_debug_ndlist(struct list_head *ndlist,
 
 	rc = lstcon_rpc_trans_ndlist(ndlist, translist, LST_TRANS_SESQRY,
 				     NULL, lstcon_sesrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		return rc;
 	}
@@ -1604,7 +1604,7 @@ lstcon_batch_debug(int timeout, char *name,
 	int rc;
 
 	rc = lstcon_batch_find(name, &bat);
-	if (rc != 0)
+	if (rc)
 		return -ENOENT;
 
 	rc = lstcon_debug_ndlist(client ? &bat->bat_cli_list :
@@ -1622,7 +1622,7 @@ lstcon_group_debug(int timeout, char *name,
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
-	if (rc != 0)
+	if (rc)
 		return -ENOENT;
 
 	rc = lstcon_debug_ndlist(&grp->grp_ndl_list, NULL,
@@ -1644,7 +1644,7 @@ lstcon_nodes_debug(int timeout,
 	int rc;
 
 	rc = lstcon_group_alloc(NULL, &grp);
-	if (rc != 0) {
+	if (rc) {
 		CDEBUG(D_NET, "Out of memory\n");
 		return rc;
 	}
@@ -1657,13 +1657,13 @@ lstcon_nodes_debug(int timeout,
 
 		/* node is added to tmp group */
 		rc = lstcon_group_ndlink_find(grp, id, &ndl, 1);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Can't create node link\n");
 			break;
 		}
 	}
 
-	if (rc != 0) {
+	if (rc) {
 		lstcon_group_decref(grp);
 		return rc;
 	}
@@ -1715,11 +1715,11 @@ lstcon_session_new(char *name, int key, unsigned feats,
 		rc = lstcon_session_end();
 
 		/* lstcon_session_end() only return local error */
-		if  (rc != 0)
+		if  (rc)
 			return rc;
 	}
 
-	if ((feats & ~LST_FEATS_MASK) != 0) {
+	if (feats & ~LST_FEATS_MASK) {
 		CNETERR("Unknown session features %x\n",
 			(feats & ~LST_FEATS_MASK));
 		return -EINVAL;
@@ -1741,11 +1741,11 @@ lstcon_session_new(char *name, int key, unsigned feats,
 		sizeof(console_session.ses_name));
 
 	rc = lstcon_batch_add(LST_DEFAULT_BATCH);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	rc = lstcon_rpc_pinger_start();
-	if (rc != 0) {
+	if (rc) {
 		lstcon_batch_t *bat = NULL;
 
 		lstcon_batch_find(LST_DEFAULT_BATCH, &bat);
@@ -1754,8 +1754,8 @@ lstcon_session_new(char *name, int key, unsigned feats,
 		return rc;
 	}
 
-	if (copy_to_user(sid_up, &console_session.ses_id,
-			 sizeof(lst_sid_t)) == 0)
+	if (!copy_to_user(sid_up, &console_session.ses_id,
+			  sizeof(lst_sid_t)))
 		return rc;
 
 	lstcon_session_end();
@@ -1811,7 +1811,7 @@ lstcon_session_end(void)
 	rc = lstcon_rpc_trans_ndlist(&console_session.ses_ndl_list,
 				     NULL, LST_TRANS_SESEND, NULL,
 				     lstcon_sesrpc_condition, &trans);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Can't create transaction: %d\n", rc);
 		return rc;
 	}
@@ -1865,7 +1865,7 @@ lstcon_session_feats_check(unsigned feats)
 {
 	int rc = 0;
 
-	if ((feats & ~LST_FEATS_MASK) != 0) {
+	if (feats & ~LST_FEATS_MASK) {
 		CERROR("Can't support these features: %x\n",
 		       (feats & ~LST_FEATS_MASK));
 		return -EPROTO;
@@ -1883,7 +1883,7 @@ lstcon_session_feats_check(unsigned feats)
 
 	spin_unlock(&console_session.ses_rpc_lock);
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("remote features %x do not match with session features %x of console\n",
 		       feats, console_session.ses_features);
 	}
@@ -1913,7 +1913,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 		goto out;
 	}
 
-	if (lstcon_session_feats_check(req->msg_ses_feats) != 0) {
+	if (lstcon_session_feats_check(req->msg_ses_feats)) {
 		jrep->join_status = EPROTO;
 		goto out;
 	}
@@ -1924,9 +1924,9 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 		goto out;
 	}
 
-	if (lstcon_group_find(jreq->join_group, &grp) != 0) {
+	if (lstcon_group_find(jreq->join_group, &grp)) {
 		rc = lstcon_group_alloc(jreq->join_group, &grp);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Out of memory\n");
 			goto out;
 		}
@@ -1943,13 +1943,13 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 	}
 
 	rc = lstcon_group_ndlink_find(grp, rpc->srpc_peer, &ndl, 0);
-	if (rc == 0) {
+	if (!rc) {
 		jrep->join_status = EEXIST;
 		goto out;
 	}
 
 	rc = lstcon_group_ndlink_find(grp, rpc->srpc_peer, &ndl, 1);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Out of memory\n");
 		goto out;
 	}
@@ -1957,7 +1957,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 	ndl->ndl_node->nd_state   = LST_NODE_ACTIVE;
 	ndl->ndl_node->nd_timeout = console_session.ses_timeout;
 
-	if (grp->grp_userland == 0)
+	if (!grp->grp_userland)
 		grp->grp_userland = 1;
 
 	strlcpy(jrep->join_session, console_session.ses_name,
@@ -2027,7 +2027,7 @@ lstcon_console_init(void)
 
 	rc = srpc_add_service(&lstcon_acceptor_service);
 	LASSERT(rc != -EBUSY);
-	if (rc != 0) {
+	if (rc) {
 		LIBCFS_FREE(console_session.ses_ndl_hash,
 			    sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
 		return rc;
@@ -2035,14 +2035,14 @@ lstcon_console_init(void)
 
 	rc = srpc_service_add_buffers(&lstcon_acceptor_service,
 				      lstcon_acceptor_service.sv_wi_total);
-	if (rc != 0) {
+	if (rc) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
 	rc = libcfs_register_ioctl(&lstcon_ioctl_handler);
 
-	if (rc == 0) {
+	if (!rc) {
 		lstcon_rpc_module_init();
 		return 0;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index e8221a7..7eca046 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -100,8 +100,8 @@ do {                                    \
 	__swab64s(&(lc).route_length);  \
 } while (0)
 
-#define sfw_test_active(t)      (atomic_read(&(t)->tsi_nactive) != 0)
-#define sfw_batch_active(b)     (atomic_read(&(b)->bat_nactive) != 0)
+#define sfw_test_active(t)      (atomic_read(&(t)->tsi_nactive))
+#define sfw_batch_active(b)     (atomic_read(&(b)->bat_nactive))
 
 static struct smoketest_framework {
 	struct list_head  fw_zombie_rpcs;     /* RPCs to be recycled */
@@ -164,7 +164,7 @@ sfw_add_session_timer(void)
 
 	LASSERT(!sfw_data.fw_shuttingdown);
 
-	if (!sn || sn->sn_timeout == 0)
+	if (!sn || !sn->sn_timeout)
 		return;
 
 	LASSERT(!sn->sn_timer_active);
@@ -183,7 +183,7 @@ sfw_del_session_timer(void)
 	if (!sn || !sn->sn_timer_active)
 		return 0;
 
-	LASSERT(sn->sn_timeout != 0);
+	LASSERT(sn->sn_timeout);
 
 	if (stt_del_timer(&sn->sn_timer)) { /* timer defused */
 		sn->sn_timer_active = 0;
@@ -226,7 +226,7 @@ sfw_deactivate_session(void)
 		}
 	}
 
-	if (nactive != 0)
+	if (nactive)
 		return;   /* wait for active batches to stop */
 
 	list_del_init(&sn->sn_list);
@@ -302,9 +302,9 @@ sfw_server_rpc_done(struct srpc_server_rpc *rpc)
 static void
 sfw_client_rpc_fini(srpc_client_rpc_t *rpc)
 {
-	LASSERT(rpc->crpc_bulk.bk_niov == 0);
+	LASSERT(!rpc->crpc_bulk.bk_niov);
 	LASSERT(list_empty(&rpc->crpc_list));
-	LASSERT(atomic_read(&rpc->crpc_refcount) == 0);
+	LASSERT(!atomic_read(&rpc->crpc_refcount));
 
 	CDEBUG(D_NET, "Outgoing framework RPC done: service %d, peer %s, status %s:%d:%d\n",
 	       rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
@@ -445,7 +445,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	 * console's responsibility to make sure all nodes in a session have
 	 * same feature mask.
 	 */
-	if ((msg->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
+	if (msg->msg_ses_feats & ~LST_FEATS_MASK) {
 		reply->mksn_status = EPROTO;
 		return 0;
 	}
@@ -569,7 +569,7 @@ sfw_load_test(struct sfw_test_instance *tsi)
 	}
 
 	rc = srpc_service_add_buffers(svc, nbuf);
-	if (rc != 0) {
+	if (rc) {
 		CWARN("Failed to reserve enough buffers: service %s, %d needed: %d\n",
 		      svc->sv_name, nbuf, rc);
 		/*
@@ -696,7 +696,7 @@ sfw_unpack_addtest_req(srpc_msg_t *msg)
 	LASSERT(msg->msg_magic == __swab32(SRPC_MSG_MAGIC));
 
 	if (req->tsr_service == SRPC_SERVICE_BRW) {
-		if ((msg->msg_ses_feats & LST_FEAT_BULK_LEN) == 0) {
+		if (!(msg->msg_ses_feats & LST_FEAT_BULK_LEN)) {
 			test_bulk_req_t *bulk = &req->tsr_u.bulk_v0;
 
 			__swab32s(&bulk->blk_opc);
@@ -761,7 +761,7 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 	tsi->tsi_stoptsu_onerr = !!(req->tsr_stop_onerr);
 
 	rc = sfw_load_test(tsi);
-	if (rc != 0) {
+	if (rc) {
 		LIBCFS_FREE(tsi, sizeof(*tsi));
 		return rc;
 	}
@@ -811,13 +811,13 @@ sfw_add_test_instance(sfw_batch_t *tsb, struct srpc_server_rpc *rpc)
 	}
 
 	rc = tsi->tsi_ops->tso_init(tsi);
-	if (rc == 0) {
+	if (!rc) {
 		list_add_tail(&tsi->tsi_list, &tsb->bat_tests);
 		return 0;
 	}
 
 error:
-	LASSERT(rc != 0);
+	LASSERT(rc);
 	sfw_destroy_test_instance(tsi);
 	return rc;
 }
@@ -882,9 +882,8 @@ sfw_test_rpc_done(srpc_client_rpc_t *rpc)
 	list_del_init(&rpc->crpc_list);
 
 	/* batch is stopping or loop is done or get error */
-	if (tsi->tsi_stopping ||
-	    tsu->tsu_loop == 0 ||
-	    (rpc->crpc_status != 0 && tsi->tsi_stoptsu_onerr))
+	if (tsi->tsi_stopping || !tsu->tsu_loop ||
+	    (rpc->crpc_status && tsi->tsi_stoptsu_onerr))
 		done = 1;
 
 	/* dec ref for poster */
@@ -953,7 +952,7 @@ sfw_run_test(swi_workitem_t *wi)
 
 	LASSERT(wi == &tsu->tsu_worker);
 
-	if (tsi->tsi_ops->tso_prep_rpc(tsu, tsu->tsu_dest, &rpc) != 0) {
+	if (tsi->tsi_ops->tso_prep_rpc(tsu, tsu->tsu_dest, &rpc)) {
 		LASSERT(!rpc);
 		goto test_done;
 	}
@@ -1080,7 +1079,7 @@ sfw_query_batch(sfw_batch_t *tsb, int testidx, srpc_batch_reply_t *reply)
 	if (testidx < 0)
 		return -EINVAL;
 
-	if (testidx == 0) {
+	if (!testidx) {
 		reply->bar_active = atomic_read(&tsb->bat_nactive);
 		return 0;
 	}
@@ -1129,11 +1128,11 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 	request = &rpc->srpc_reqstbuf->buf_msg.msg_body.tes_reqst;
 	reply->tsr_sid = !sn ? LST_INVALID_SID : sn->sn_id;
 
-	if (request->tsr_loop == 0 ||
-	    request->tsr_concur == 0 ||
+	if (!request->tsr_loop ||
+	    !request->tsr_concur ||
 	    request->tsr_sid.ses_nid == LNET_NID_ANY ||
 	    request->tsr_ndest > SFW_MAX_NDESTS ||
-	    (request->tsr_is_client && request->tsr_ndest == 0) ||
+	    (request->tsr_is_client && !request->tsr_ndest) ||
 	    request->tsr_concur > SFW_MAX_CONCUR ||
 	    request->tsr_service > SRPC_SERVICE_MAX_ID ||
 	    request->tsr_service <= SRPC_FRAMEWORK_SERVICE_MAX_ID) {
@@ -1165,7 +1164,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 		int npg = sfw_id_pages(request->tsr_ndest);
 		int len;
 
-		if ((sn->sn_features & LST_FEAT_BULK_LEN) == 0) {
+		if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
 			len = npg * PAGE_CACHE_SIZE;
 
 		} else  {
@@ -1177,9 +1176,9 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 	}
 
 	rc = sfw_add_test_instance(bat, rpc);
-	CDEBUG(rc == 0 ? D_NET : D_WARNING,
+	CDEBUG(!rc ? D_NET : D_WARNING,
 	       "%s test: sv %d %s, loop %d, concur %d, ndest %d\n",
-	       rc == 0 ? "Added" : "Failed to add", request->tsr_service,
+	       !rc ? "Added" : "Failed to add", request->tsr_service,
 	       request->tsr_is_client ? "client" : "server",
 	       request->tsr_loop, request->tsr_concur, request->tsr_ndest);
 
@@ -1248,7 +1247,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 	}
 
 	/* Remove timer to avoid racing with it or expiring active session */
-	if (sfw_del_session_timer() != 0) {
+	if (sfw_del_session_timer()) {
 		CERROR("Dropping RPC (%s) from %s: racing with expiry timer.",
 		       sv->sv_name, libcfs_id2str(rpc->srpc_peer));
 		spin_unlock(&sfw_data.fw_lock);
@@ -1277,7 +1276,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 			goto out;
 		}
 
-	} else if ((request->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
+	} else if (request->msg_ses_feats & ~LST_FEATS_MASK) {
 		/*
 		 * NB: at this point, old version will ignore features and
 		 * create new session anyway, so console should be able
@@ -1348,7 +1347,7 @@ sfw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 
 	spin_lock(&sfw_data.fw_lock);
 
-	if (status != 0) {
+	if (status) {
 		CERROR("Bulk transfer failed for RPC: service %s, peer %s, status %d\n",
 		       sv->sv_name, libcfs_id2str(rpc->srpc_peer), status);
 		spin_unlock(&sfw_data.fw_lock);
@@ -1360,7 +1359,7 @@ sfw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 		return -ESHUTDOWN;
 	}
 
-	if (sfw_del_session_timer() != 0) {
+	if (sfw_del_session_timer()) {
 		CERROR("Dropping RPC (%s) from %s: racing with expiry timer",
 		       sv->sv_name, libcfs_id2str(rpc->srpc_peer));
 		spin_unlock(&sfw_data.fw_lock);
@@ -1394,7 +1393,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 	LASSERT(!sfw_data.fw_shuttingdown);
 	LASSERT(service <= SRPC_FRAMEWORK_SERVICE_MAX_ID);
 
-	if (nbulkiov == 0 && !list_empty(&sfw_data.fw_zombie_rpcs)) {
+	if (!nbulkiov && !list_empty(&sfw_data.fw_zombie_rpcs)) {
 		rpc = list_entry(sfw_data.fw_zombie_rpcs.next,
 				 srpc_client_rpc_t, crpc_list);
 		list_del(&rpc->crpc_list);
@@ -1408,7 +1407,7 @@ sfw_create_rpc(lnet_process_id_t peer, int service,
 	if (!rpc) {
 		rpc = srpc_create_client_rpc(peer, service,
 					     nbulkiov, bulklen, done,
-					     nbulkiov != 0 ?  NULL :
+					     nbulkiov ?  NULL :
 					     sfw_client_rpc_fini,
 					     priv);
 	}
@@ -1661,10 +1660,10 @@ sfw_startup(void)
 		return -EINVAL;
 	}
 
-	if (session_timeout == 0)
+	if (!session_timeout)
 		CWARN("Zero session_timeout specified - test sessions never expire.\n");
 
-	if (rpc_timeout == 0)
+	if (!rpc_timeout)
 		CWARN("Zero rpc_timeout specified - test RPC never expire.\n");
 
 	memset(&sfw_data, 0, sizeof(struct smoketest_framework));
@@ -1680,12 +1679,12 @@ sfw_startup(void)
 	brw_init_test_client();
 	brw_init_test_service();
 	rc = sfw_register_test(&brw_test_service, &brw_test_client);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	ping_init_test_client();
 	ping_init_test_service();
 	rc = sfw_register_test(&ping_test_service, &ping_test_client);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	error = 0;
 	list_for_each_entry(tsc, &sfw_data.fw_tests, tsc_list) {
@@ -1693,7 +1692,7 @@ sfw_startup(void)
 
 		rc = srpc_add_service(sv);
 		LASSERT(rc != -EBUSY);
-		if (rc != 0) {
+		if (rc) {
 			CWARN("Failed to add %s service: %d\n",
 			      sv->sv_name, rc);
 			error = rc;
@@ -1713,7 +1712,7 @@ sfw_startup(void)
 
 		rc = srpc_add_service(sv);
 		LASSERT(rc != -EBUSY);
-		if (rc != 0) {
+		if (rc) {
 			CWARN("Failed to add %s service: %d\n",
 			      sv->sv_name, rc);
 			error = rc;
@@ -1724,14 +1723,14 @@ sfw_startup(void)
 			continue;
 
 		rc = srpc_service_add_buffers(sv, sv->sv_wi_total);
-		if (rc != 0) {
+		if (rc) {
 			CWARN("Failed to reserve enough buffers: service %s, %d needed: %d\n",
 			      sv->sv_name, sv->sv_wi_total, rc);
 			error = -ENOMEM;
 		}
 	}
 
-	if (error != 0)
+	if (error)
 		sfw_shutdown();
 	return error;
 }
@@ -1749,12 +1748,12 @@ sfw_shutdown(void)
 	lst_wait_until(!sfw_data.fw_active_srpc, sfw_data.fw_lock,
 		       "waiting for active RPC to finish.\n");
 
-	if (sfw_del_session_timer() != 0)
+	if (sfw_del_session_timer())
 		lst_wait_until(!sfw_data.fw_session, sfw_data.fw_lock,
 			       "waiting for session timer to explode.\n");
 
 	sfw_deactivate_session();
-	lst_wait_until(atomic_read(&sfw_data.fw_nzombies) == 0,
+	lst_wait_until(!atomic_read(&sfw_data.fw_nzombies),
 		       sfw_data.fw_lock,
 		       "waiting for %d zombie sessions to die.\n",
 		       atomic_read(&sfw_data.fw_nzombies));
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 741509a..c4bf442 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -98,7 +98,7 @@ lnet_selftest_init(void)
 
 	rc = cfs_wi_sched_create("lst_s", lnet_cpt_table(), CFS_CPT_ANY,
 				 1, &lst_sched_serial);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("Failed to create serial WI scheduler for LST\n");
 		return rc;
 	}
@@ -117,7 +117,7 @@ lnet_selftest_init(void)
 		nthrs = max(nthrs - 1, 1);
 		rc = cfs_wi_sched_create("lst_t", lnet_cpt_table(), i,
 					 nthrs, &lst_sched_test[i]);
-		if (rc != 0) {
+		if (rc) {
 			CERROR("Failed to create CPT affinity WI scheduler %d for LST\n",
 			       i);
 			goto error;
@@ -125,21 +125,21 @@ lnet_selftest_init(void)
 	}
 
 	rc = srpc_startup();
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LST can't startup rpc\n");
 		goto error;
 	}
 	lst_init_step = LST_INIT_RPC;
 
 	rc = sfw_startup();
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LST can't startup framework\n");
 		goto error;
 	}
 	lst_init_step = LST_INIT_FW;
 
 	rc = lstcon_console_init();
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LST can't startup console\n");
 		goto error;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 01ceee5..9d27e39 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -61,7 +61,7 @@ ping_client_init(sfw_test_instance_t *tsi)
 	sfw_session_t *sn = tsi->tsi_batch->bat_session;
 
 	LASSERT(tsi->tsi_is_client);
-	LASSERT(sn && (sn->sn_features & ~LST_FEATS_MASK) == 0);
+	LASSERT(sn && !(sn->sn_features & ~LST_FEATS_MASK));
 
 	spin_lock_init(&lst_ping_data.pnd_lock);
 	lst_ping_data.pnd_counter = 0;
@@ -96,10 +96,10 @@ ping_client_prep_rpc(sfw_test_unit_t *tsu,
 	int rc;
 
 	LASSERT(sn);
-	LASSERT((sn->sn_features & ~LST_FEATS_MASK) == 0);
+	LASSERT(!(sn->sn_features & ~LST_FEATS_MASK));
 
 	rc = sfw_create_test_rpc(tsu, dest, sn->sn_features, 0, 0, rpc);
-	if (rc != 0)
+	if (rc)
 		return rc;
 
 	req = &(*rpc)->crpc_reqstmsg.msg_body.ping_reqst;
@@ -128,7 +128,7 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 
 	LASSERT(sn);
 
-	if (rpc->crpc_status != 0) {
+	if (rpc->crpc_status) {
 		if (!tsi->tsi_stopping) /* rpc could have been aborted */
 			atomic_inc(&sn->sn_ping_errors);
 		CERROR("Unable to ping %s (%d): %d\n",
@@ -198,7 +198,7 @@ ping_server_handle(struct srpc_server_rpc *rpc)
 	rep->pnr_seq   = req->pnr_seq;
 	rep->pnr_magic = LST_PING_TEST_MAGIC;
 
-	if ((reqstmsg->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
+	if (reqstmsg->msg_ses_feats & ~LST_FEATS_MASK) {
 		replymsg->msg_ses_feats = LST_FEATS_MASK;
 		rep->pnr_status = EPROTO;
 		return 0;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 1e78711..f95fd9b 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -284,7 +284,7 @@ srpc_service_init(struct srpc_service *svc)
 		swi_init_workitem(&scd->scd_buf_wi, scd,
 				  srpc_add_buffer, lst_sched_test[i]);
 
-		if (i != 0 && srpc_serv_is_framework(svc)) {
+		if (i && srpc_serv_is_framework(svc)) {
 			/*
 			 * NB: framework service only needs srpc_service_cd for
 			 * one partition, but we allocate for all to make
@@ -315,7 +315,7 @@ srpc_add_service(struct srpc_service *sv)
 
 	LASSERT(0 <= id && id <= SRPC_SERVICE_MAX_ID);
 
-	if (srpc_service_init(sv) != 0)
+	if (srpc_service_init(sv))
 		return -ENOMEM;
 
 	spin_lock(&srpc_data.rpc_glock);
@@ -366,7 +366,7 @@ srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 
 	rc = LNetMEAttach(portal, peer, matchbits, 0, LNET_UNLINK,
 			  local ? LNET_INS_LOCAL : LNET_INS_AFTER, &meh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LNetMEAttach failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
 		return -ENOMEM;
@@ -380,12 +380,12 @@ srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
 	md.eq_handle = srpc_data.rpc_lnet_eq;
 
 	rc = LNetMDAttach(meh, md, LNET_UNLINK, mdh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LNetMDAttach failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
 
 		rc = LNetMEUnlink(meh);
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 		return -ENOMEM;
 	}
 
@@ -406,11 +406,11 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 	md.start     = buf;
 	md.length    = len;
 	md.eq_handle = srpc_data.rpc_lnet_eq;
-	md.threshold = ((options & LNET_MD_OP_GET) != 0) ? 2 : 1;
+	md.threshold = options & LNET_MD_OP_GET ? 2 : 1;
 	md.options   = options & ~(LNET_MD_OP_PUT | LNET_MD_OP_GET);
 
 	rc = LNetMDBind(md, LNET_UNLINK, mdh);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LNetMDBind failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
 		return -ENOMEM;
@@ -421,18 +421,18 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 	 * they're only meaningful for MDs attached to an ME (i.e. passive
 	 * buffers...
 	 */
-	if ((options & LNET_MD_OP_PUT) != 0) {
+	if (options & LNET_MD_OP_PUT) {
 		rc = LNetPut(self, *mdh, LNET_NOACK_REQ, peer,
 			     portal, matchbits, 0, 0);
 	} else {
-		LASSERT((options & LNET_MD_OP_GET) != 0);
+		LASSERT(options & LNET_MD_OP_GET);
 
 		rc = LNetGet(self, *mdh, peer, portal, matchbits, 0);
 	}
 
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LNet%s(%s, %d, %lld) failed: %d\n",
-		       ((options & LNET_MD_OP_PUT) != 0) ? "Put" : "Get",
+		       options & LNET_MD_OP_PUT ? "Put" : "Get",
 		       libcfs_id2str(peer), portal, matchbits, rc);
 
 		/*
@@ -440,7 +440,7 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 		 * with failure, so fall through and return success here.
 		 */
 		rc = LNetMDUnlink(*mdh);
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 	} else {
 		CDEBUG(D_NET, "Posted active RDMA: peer %s, portal %u, matchbits %#llx\n",
 		       libcfs_id2str(peer), portal, matchbits);
@@ -487,7 +487,7 @@ srpc_service_post_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
 	 */
 	spin_lock(&scd->scd_lock);
 
-	if (rc == 0) {
+	if (!rc) {
 		if (!sv->sv_shuttingdown)
 			return 0;
 
@@ -555,7 +555,7 @@ srpc_add_buffer(struct swi_workitem *wi)
 		}
 
 		rc = srpc_service_post_buffer(scd, buf);
-		if (rc != 0)
+		if (rc)
 			break; /* buf has been freed inside */
 
 		LASSERT(scd->scd_buf_posting > 0);
@@ -564,7 +564,7 @@ srpc_add_buffer(struct swi_workitem *wi)
 		scd->scd_buf_low = max(2, scd->scd_buf_total / 4);
 	}
 
-	if (rc != 0) {
+	if (rc) {
 		scd->scd_buf_err_stamp = ktime_get_real_seconds();
 		scd->scd_buf_err = rc;
 
@@ -616,12 +616,12 @@ srpc_service_add_buffers(struct srpc_service *sv, int nbuffer)
 		 * block all WIs pending on lst_sched_serial for a moment
 		 * which is not good but not fatal.
 		 */
-		lst_wait_until(scd->scd_buf_err != 0 ||
-			       (scd->scd_buf_adjust == 0 &&
-				scd->scd_buf_posting == 0),
+		lst_wait_until(scd->scd_buf_err ||
+			       (!scd->scd_buf_adjust &&
+				!scd->scd_buf_posting),
 			       scd->scd_lock, "waiting for adding buffer\n");
 
-		if (scd->scd_buf_err != 0 && rc == 0)
+		if (scd->scd_buf_err && !rc)
 			rc = scd->scd_buf_err;
 
 		spin_unlock(&scd->scd_lock);
@@ -702,7 +702,7 @@ srpc_service_recycle_buffer(struct srpc_service_cd *scd, srpc_buffer_t *buf)
 	__must_hold(&scd->scd_lock)
 {
 	if (!scd->scd_svc->sv_shuttingdown && scd->scd_buf_adjust >= 0) {
-		if (srpc_service_post_buffer(scd, buf) != 0) {
+		if (srpc_service_post_buffer(scd, buf)) {
 			CWARN("Failed to post %s buffer\n",
 			      scd->scd_svc->sv_name);
 		}
@@ -715,7 +715,7 @@ srpc_service_recycle_buffer(struct srpc_service_cd *scd, srpc_buffer_t *buf)
 	if (scd->scd_buf_adjust < 0) {
 		scd->scd_buf_adjust++;
 		if (scd->scd_buf_adjust < 0 &&
-		    scd->scd_buf_total == 0 && scd->scd_buf_posting == 0) {
+		    !scd->scd_buf_total && !scd->scd_buf_posting) {
 			CDEBUG(D_INFO,
 			       "Try to recycle %d buffers but nothing left\n",
 			       scd->scd_buf_adjust);
@@ -807,7 +807,7 @@ srpc_send_request(srpc_client_rpc_t *rpc)
 				    sizeof(srpc_msg_t), LNET_MD_OP_PUT,
 				    rpc->crpc_dest, LNET_NID_ANY,
 				    &rpc->crpc_reqstmdh, ev);
-	if (rc != 0) {
+	if (rc) {
 		LASSERT(rc == -ENOMEM);
 		ev->ev_fired = 1;  /* no more event expected */
 	}
@@ -831,7 +831,7 @@ srpc_prepare_reply(srpc_client_rpc_t *rpc)
 				    &rpc->crpc_replymsg, sizeof(srpc_msg_t),
 				    LNET_MD_OP_PUT, rpc->crpc_dest,
 				    &rpc->crpc_replymdh, ev);
-	if (rc != 0) {
+	if (rc) {
 		LASSERT(rc == -ENOMEM);
 		ev->ev_fired = 1;  /* no more event expected */
 	}
@@ -849,7 +849,7 @@ srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 
 	LASSERT(bk->bk_niov <= LNET_MAX_IOV);
 
-	if (bk->bk_niov == 0)
+	if (!bk->bk_niov)
 		return 0; /* nothing to do */
 
 	opt = bk->bk_sink ? LNET_MD_OP_PUT : LNET_MD_OP_GET;
@@ -864,7 +864,7 @@ srpc_prepare_bulk(srpc_client_rpc_t *rpc)
 	rc = srpc_post_passive_rdma(SRPC_RDMA_PORTAL, 0, *id,
 				    &bk->bk_iovs[0], bk->bk_niov, opt,
 				    rpc->crpc_dest, &bk->bk_mdh, ev);
-	if (rc != 0) {
+	if (rc) {
 		LASSERT(rc == -ENOMEM);
 		ev->ev_fired = 1;  /* no more event expected */
 	}
@@ -893,7 +893,7 @@ srpc_do_bulk(struct srpc_server_rpc *rpc)
 				   &bk->bk_iovs[0], bk->bk_niov, opt,
 				   rpc->srpc_peer, rpc->srpc_self,
 				   &bk->bk_mdh, ev);
-	if (rc != 0)
+	if (rc)
 		ev->ev_fired = 1;  /* no more event expected */
 	return rc;
 }
@@ -906,16 +906,16 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	struct srpc_service *sv  = scd->scd_svc;
 	srpc_buffer_t *buffer;
 
-	LASSERT(status != 0 || rpc->srpc_wi.swi_state == SWI_STATE_DONE);
+	LASSERT(status || rpc->srpc_wi.swi_state == SWI_STATE_DONE);
 
 	rpc->srpc_status = status;
 
-	CDEBUG_LIMIT(status == 0 ? D_NET : D_NETERROR,
+	CDEBUG_LIMIT(!status ? D_NET : D_NETERROR,
 		     "Server RPC %p done: service %s, peer %s, status %s:%d\n",
 		     rpc, sv->sv_name, libcfs_id2str(rpc->srpc_peer),
 		     swi_state2str(rpc->srpc_wi.swi_state), status);
 
-	if (status != 0) {
+	if (status) {
 		spin_lock(&srpc_data.rpc_glock);
 		srpc_data.rpc_counters.rpcs_dropped++;
 		spin_unlock(&srpc_data.rpc_glock);
@@ -1003,7 +1003,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 		msg = &rpc->srpc_reqstbuf->buf_msg;
 		reply = &rpc->srpc_replymsg.msg_body.reply;
 
-		if (msg->msg_magic == 0) {
+		if (!msg->msg_magic) {
 			/* moaned already in srpc_lnet_ev_handler */
 			srpc_server_rpc_done(rpc, EBADMSG);
 			return 1;
@@ -1019,8 +1019,8 @@ srpc_handle_rpc(swi_workitem_t *wi)
 		} else {
 			reply->status = 0;
 			rc = (*sv->sv_handler)(rpc);
-			LASSERT(reply->status == 0 || !rpc->srpc_bulk);
-			if (rc != 0) {
+			LASSERT(!reply->status || !rpc->srpc_bulk);
+			if (rc) {
 				srpc_server_rpc_done(rpc, rc);
 				return 1;
 			}
@@ -1030,7 +1030,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 
 		if (rpc->srpc_bulk) {
 			rc = srpc_do_bulk(rpc);
-			if (rc == 0)
+			if (!rc)
 				return 0; /* wait for bulk */
 
 			LASSERT(ev->ev_fired);
@@ -1046,7 +1046,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 			if (sv->sv_bulk_ready)
 				rc = (*sv->sv_bulk_ready) (rpc, rc);
 
-			if (rc != 0) {
+			if (rc) {
 				srpc_server_rpc_done(rpc, rc);
 				return 1;
 			}
@@ -1054,7 +1054,7 @@ srpc_handle_rpc(swi_workitem_t *wi)
 
 		wi->swi_state = SWI_STATE_REPLY_SUBMITTED;
 		rc = srpc_send_reply(rpc);
-		if (rc == 0)
+		if (!rc)
 			return 0; /* wait for reply */
 		srpc_server_rpc_done(rpc, rc);
 		return 1;
@@ -1102,7 +1102,7 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
 {
 	stt_timer_t *timer = &rpc->crpc_timer;
 
-	if (rpc->crpc_timeout == 0)
+	if (!rpc->crpc_timeout)
 		return;
 
 	INIT_LIST_HEAD(&timer->stt_list);
@@ -1123,7 +1123,7 @@ static void
 srpc_del_client_rpc_timer(srpc_client_rpc_t *rpc)
 {
 	/* timer not planted or already exploded */
-	if (rpc->crpc_timeout == 0)
+	if (!rpc->crpc_timeout)
 		return;
 
 	/* timer successfully defused */
@@ -1131,7 +1131,7 @@ srpc_del_client_rpc_timer(srpc_client_rpc_t *rpc)
 		return;
 
 	/* timer detonated, wait for it to explode */
-	while (rpc->crpc_timeout != 0) {
+	while (rpc->crpc_timeout) {
 		spin_unlock(&rpc->crpc_lock);
 
 		schedule();
@@ -1145,17 +1145,17 @@ srpc_client_rpc_done(srpc_client_rpc_t *rpc, int status)
 {
 	swi_workitem_t *wi = &rpc->crpc_wi;
 
-	LASSERT(status != 0 || wi->swi_state == SWI_STATE_DONE);
+	LASSERT(status || wi->swi_state == SWI_STATE_DONE);
 
 	spin_lock(&rpc->crpc_lock);
 
 	rpc->crpc_closed = 1;
-	if (rpc->crpc_status == 0)
+	if (!rpc->crpc_status)
 		rpc->crpc_status = status;
 
 	srpc_del_client_rpc_timer(rpc);
 
-	CDEBUG_LIMIT((status == 0) ? D_NET : D_NETERROR,
+	CDEBUG_LIMIT(!status ? D_NET : D_NETERROR,
 		     "Client RPC done: service %d, peer %s, status %s:%d:%d\n",
 		     rpc->crpc_service, libcfs_id2str(rpc->crpc_dest),
 		     swi_state2str(wi->swi_state), rpc->crpc_aborted, status);
@@ -1212,13 +1212,13 @@ srpc_send_rpc(swi_workitem_t *wi)
 		LASSERT(!srpc_event_pending(rpc));
 
 		rc = srpc_prepare_reply(rpc);
-		if (rc != 0) {
+		if (rc) {
 			srpc_client_rpc_done(rpc, rc);
 			return 1;
 		}
 
 		rc = srpc_prepare_bulk(rpc);
-		if (rc != 0)
+		if (rc)
 			break;
 
 		wi->swi_state = SWI_STATE_REQUEST_SUBMITTED;
@@ -1235,7 +1235,7 @@ srpc_send_rpc(swi_workitem_t *wi)
 			break;
 
 		rc = rpc->crpc_reqstev.ev_status;
-		if (rc != 0)
+		if (rc)
 			break;
 
 		wi->swi_state = SWI_STATE_REQUEST_SENT;
@@ -1247,7 +1247,7 @@ srpc_send_rpc(swi_workitem_t *wi)
 			break;
 
 		rc = rpc->crpc_replyev.ev_status;
-		if (rc != 0)
+		if (rc)
 			break;
 
 		srpc_unpack_msg_hdr(reply);
@@ -1262,7 +1262,7 @@ srpc_send_rpc(swi_workitem_t *wi)
 			break;
 		}
 
-		if (do_bulk && reply->msg_body.reply.status != 0) {
+		if (do_bulk && reply->msg_body.reply.status) {
 			CWARN("Remote error %d at %s, unlink bulk buffer in case peer didn't initiate bulk transfer\n",
 			      reply->msg_body.reply.status,
 			      libcfs_id2str(rpc->crpc_dest));
@@ -1284,7 +1284,7 @@ srpc_send_rpc(swi_workitem_t *wi)
 		 * remote error.
 		 */
 		if (do_bulk && rpc->crpc_bulkev.ev_lnet == LNET_EVENT_UNLINK &&
-		    rpc->crpc_status == 0 && reply->msg_body.reply.status != 0)
+		    !rpc->crpc_status && reply->msg_body.reply.status)
 			rc = 0;
 
 		wi->swi_state = SWI_STATE_DONE;
@@ -1292,7 +1292,7 @@ srpc_send_rpc(swi_workitem_t *wi)
 		return 1;
 	}
 
-	if (rc != 0) {
+	if (rc) {
 		spin_lock(&rpc->crpc_lock);
 		srpc_abort_rpc(rpc, rc);
 		spin_unlock(&rpc->crpc_lock);
@@ -1334,7 +1334,7 @@ srpc_create_client_rpc(lnet_process_id_t peer, int service,
 void
 srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 {
-	LASSERT(why != 0);
+	LASSERT(why);
 
 	if (rpc->crpc_aborted || /* already aborted */
 	    rpc->crpc_closed)    /* callback imminent */
@@ -1387,7 +1387,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
 		 * Repost buffer before replying since test client
 		 * might send me another RPC once it gets the reply
 		 */
-		if (srpc_service_post_buffer(scd, buffer) != 0)
+		if (srpc_service_post_buffer(scd, buffer))
 			CWARN("Failed to repost %s buffer\n", sv->sv_name);
 		rpc->srpc_reqstbuf = NULL;
 	}
@@ -1406,7 +1406,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
 				   sizeof(*msg), LNET_MD_OP_PUT,
 				   rpc->srpc_peer, rpc->srpc_self,
 				   &rpc->srpc_replymdh, ev);
-	if (rc != 0)
+	if (rc)
 		ev->ev_fired = 1;  /* no more event expected */
 	return rc;
 }
@@ -1426,7 +1426,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 
 	LASSERT(!in_interrupt());
 
-	if (ev->status != 0) {
+	if (ev->status) {
 		spin_lock(&srpc_data.rpc_glock);
 		srpc_data.rpc_counters.errors++;
 		spin_unlock(&srpc_data.rpc_glock);
@@ -1440,7 +1440,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 		       rpcev->ev_status, rpcev->ev_type, rpcev->ev_lnet);
 		LBUG();
 	case SRPC_REQUEST_SENT:
-		if (ev->status == 0 && ev->type != LNET_EVENT_UNLINK) {
+		if (!ev->status && ev->type != LNET_EVENT_UNLINK) {
 			spin_lock(&srpc_data.rpc_glock);
 			srpc_data.rpc_counters.rpcs_sent++;
 			spin_unlock(&srpc_data.rpc_glock);
@@ -1462,7 +1462,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 
 		spin_lock(&crpc->crpc_lock);
 
-		LASSERT(rpcev->ev_fired == 0);
+		LASSERT(!rpcev->ev_fired);
 		rpcev->ev_fired  = 1;
 		rpcev->ev_status = (ev->type == LNET_EVENT_UNLINK) ?
 						-EINTR : ev->status;
@@ -1501,15 +1501,15 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 			break;
 		}
 
-		if (scd->scd_buf_err_stamp != 0 &&
+		if (scd->scd_buf_err_stamp &&
 		    scd->scd_buf_err_stamp < ktime_get_real_seconds()) {
 			/* re-enable adding buffer */
 			scd->scd_buf_err_stamp = 0;
 			scd->scd_buf_err = 0;
 		}
 
-		if (scd->scd_buf_err == 0 && /* adding buffer is enabled */
-		    scd->scd_buf_adjust == 0 &&
+		if (!scd->scd_buf_err && /* adding buffer is enabled */
+		    !scd->scd_buf_adjust &&
 		    scd->scd_buf_nposted < scd->scd_buf_low) {
 			scd->scd_buf_adjust = max(scd->scd_buf_total / 2,
 						  SFW_TEST_WI_MIN);
@@ -1520,7 +1520,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 		msg = &buffer->buf_msg;
 		type = srpc_service2request(sv->sv_id);
 
-		if (ev->status != 0 || ev->mlength != sizeof(*msg) ||
+		if (ev->status || ev->mlength != sizeof(*msg) ||
 		    (msg->msg_type != type &&
 		     msg->msg_type != __swab32(type)) ||
 		    (msg->msg_magic != SRPC_MSG_MAGIC &&
@@ -1569,7 +1569,7 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 			break; /* wait for final event */
 
 	case SRPC_BULK_PUT_SENT:
-		if (ev->status == 0 && ev->type != LNET_EVENT_UNLINK) {
+		if (!ev->status && ev->type != LNET_EVENT_UNLINK) {
 			spin_lock(&srpc_data.rpc_glock);
 
 			if (rpcev->ev_type == SRPC_BULK_GET_RPLD)
@@ -1622,22 +1622,22 @@ srpc_startup(void)
 
 	LNetInvalidateHandle(&srpc_data.rpc_lnet_eq);
 	rc = LNetEQAlloc(0, srpc_lnet_ev_handler, &srpc_data.rpc_lnet_eq);
-	if (rc != 0) {
+	if (rc) {
 		CERROR("LNetEQAlloc() has failed: %d\n", rc);
 		goto bail;
 	}
 
 	rc = LNetSetLazyPortal(SRPC_FRAMEWORK_REQUEST_PORTAL);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 	rc = LNetSetLazyPortal(SRPC_REQUEST_PORTAL);
-	LASSERT(rc == 0);
+	LASSERT(!rc);
 
 	srpc_data.rpc_state = SRPC_STATE_EQ_INIT;
 
 	rc = stt_startup();
 
 bail:
-	if (rc != 0)
+	if (rc)
 		srpc_shutdown();
 	else
 		srpc_data.rpc_state = SRPC_STATE_RUNNING;
@@ -1675,9 +1675,9 @@ srpc_shutdown(void)
 	case SRPC_STATE_EQ_INIT:
 		rc = LNetClearLazyPortal(SRPC_FRAMEWORK_REQUEST_PORTAL);
 		rc = LNetClearLazyPortal(SRPC_REQUEST_PORTAL);
-		LASSERT(rc == 0);
+		LASSERT(!rc);
 		rc = LNetEQFree(srpc_data.rpc_lnet_eq);
-		LASSERT(rc == 0); /* the EQ should have no user by now */
+		LASSERT(!rc); /* the EQ should have no user by now */
 
 	case SRPC_STATE_NI_INIT:
 		LNetNIFini();
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index e6367ec..f6c8244 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -255,9 +255,9 @@ do {                                                                     \
 		srpc_destroy_client_rpc(rpc);                            \
 } while (0)
 
-#define srpc_event_pending(rpc)   ((rpc)->crpc_bulkev.ev_fired == 0 ||   \
-				   (rpc)->crpc_reqstev.ev_fired == 0 ||  \
-				   (rpc)->crpc_replyev.ev_fired == 0)
+#define srpc_event_pending(rpc)   (!(rpc)->crpc_bulkev.ev_fired ||	\
+				   !(rpc)->crpc_reqstev.ev_fired ||	\
+				   !(rpc)->crpc_replyev.ev_fired)
 
 /* CPU partition data of srpc service */
 struct srpc_service_cd {
@@ -506,7 +506,7 @@ srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 {
 	LASSERT(rpc);
 	LASSERT(!srpc_event_pending(rpc));
-	LASSERT(atomic_read(&rpc->crpc_refcount) == 0);
+	LASSERT(!atomic_read(&rpc->crpc_refcount));
 
 	if (!rpc->crpc_fini)
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
@@ -601,7 +601,7 @@ srpc_wait_service_shutdown(srpc_service_t *sv)
 
 	LASSERT(sv->sv_shuttingdown);
 
-	while (srpc_finish_service(sv) == 0) {
+	while (!srpc_finish_service(sv)) {
 		i++;
 		CDEBUG(((i & -i) == i) ? D_WARNING : D_NET,
 		       "Waiting for %s service to shutdown...\n",
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index dce5137..c891371 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -218,7 +218,7 @@ stt_startup(void)
 	stt_data.stt_nthreads = 0;
 	init_waitqueue_head(&stt_data.stt_waitq);
 	rc = stt_start_timer_thread();
-	if (rc != 0)
+	if (rc)
 		CERROR("Can't spawn timer thread: %d\n", rc);
 
 	return rc;
@@ -237,7 +237,7 @@ stt_shutdown(void)
 	stt_data.stt_shuttingdown = 1;
 
 	wake_up(&stt_data.stt_waitq);
-	lst_wait_until(stt_data.stt_nthreads == 0, stt_data.stt_lock,
+	lst_wait_until(!stt_data.stt_nthreads, stt_data.stt_lock,
 		       "waiting for %d threads to terminate\n",
 		       stt_data.stt_nthreads);
 
-- 
1.7.1
