From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:25 -0400
Subject: [lustre-devel] [PATCH 03/10] lustre: lnd: rework map_on_demand
 behavior
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

map_on_demand use is ambiguous. In kernels which supported global
memory regions, map-on-demand was used to limit the number of RDMA
fragments transferred between peers. That tuanble didn't impact the
memory allocation since the maximum allowed was always allocated. It
was used however as a variable in determining max_send_wr. With the
introduction of FMR if the number of fragments exceed the negotiated
number of fragments, which is determined by the map-on-demand value,
then FMR is used because we can transfer all the fragments in one FMR
fragment.

The latest kernels have removed support for global memory regions so
the use of map-on-demand has become ineffectual. However, we need to
keep it for backwards compatibility.  The behavior has changed as
follows:

map_on_demand is a flag used to determine if we can use FMR or
FastReg. This is applicable for kernels which support global memory
regions. For later kernels this flag is always enabled, since we will
always either use FMR or FastReg For kernels which support global
memory regions map_on_demand defaults to 0 which means we will be
using global memory regions exclusively.  If it is set to a value
other than 0, then we will behave as follows:
  1. Always default the number of fragments to IBLND_MAX_RDMA_FRAGS
  2. Create FMR/FastReg pools
  3. Negotiate the supported number of fragments per connection
  4. Attempt to transmit using global memory regions only if
     map-on-demand is off, otherwise use FMR or FastReg.
  5. In case of transmitting tx with GAPS over FMR we will need to
     transmit it with multiple fragments. Look at the comments in
     kiblnd_fmr_map_tx() for an explanation of the behavior.

For later kernels we default map_on_demand to 1 and not allow it to be
set to 0, since there is no longer support for global memory regions.
Behavior:
  1. Default the number of fragments to IBLND_MAX_RDMA_FRAGS
  2. Create FMR/FastReg pools
  3. Negotiate the supported number of fragments per connection
  4. Look at the comments in kiblnd_fmr_map_tx() for an explanation of
     the behavior when transmit with GAPS verses contiguous.

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10129
Reviewed-on: https://review.whamcloud.com/29995
WC-bug-id: https://jira.whamcloud.com/browse/LU-8573
Reviewed-on: http://review.whamcloud.com/23439
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  31 ++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  37 ++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 125 +++++++++++++++------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  55 ++++++---
 4 files changed, 154 insertions(+), 94 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index ca3e9ce..8f984a0 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -130,7 +130,6 @@ static int kiblnd_msgtype2size(int type)
 static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 {
 	struct kib_rdma_desc *rd;
-	int msg_size;
 	int nob;
 	int n;
 	int i;
@@ -149,6 +148,12 @@ static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 
 	n = rd->rd_nfrags;
 
+	if (n <= 0 || n > IBLND_MAX_RDMA_FRAGS) {
+		CERROR("Bad nfrags: %d, should be 0 < n <= %d\n",
+		       n, IBLND_MAX_RDMA_FRAGS);
+		return 1;
+	}
+
 	nob = offsetof(struct kib_msg, ibm_u) +
 	      kiblnd_rd_msg_size(rd, msg->ibm_type, n);
 
@@ -158,13 +163,6 @@ static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 		return 1;
 	}
 
-	msg_size = kiblnd_rd_size(rd);
-	if (msg_size <= 0 || msg_size > LNET_MAX_PAYLOAD) {
-		CERROR("Bad msg_size: %d, should be 0 < n <= %d\n",
-		       msg_size, LNET_MAX_PAYLOAD);
-		return 1;
-	}
-
 	if (!flip)
 		return 0;
 
@@ -336,7 +334,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 	peer_ni->ibp_nid = nid;
 	peer_ni->ibp_error = 0;
 	peer_ni->ibp_last_alive = 0;
-	peer_ni->ibp_max_frags = kiblnd_cfg_rdma_frags(peer_ni->ibp_ni);
+	peer_ni->ibp_max_frags = IBLND_MAX_RDMA_FRAGS;
 	peer_ni->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
 	atomic_set(&peer_ni->ibp_refcount, 1);  /* 1 ref for caller */
 
@@ -782,6 +780,12 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 			  kiblnd_cq_completion, kiblnd_cq_event, conn,
 			  &cq_attr);
 	if (IS_ERR(cq)) {
+		/*
+		 * on MLX-5 (possibly MLX-4 as well) this error could be
+		 * hit if the concurrent_sends and/or peer_tx_credits is set
+		 * too high. Or due to an MLX-5 bug which tries to
+		 * allocate 256kb via kmalloc for WR cookie array
+		 */
 		CERROR("Failed to create CQ with %d CQEs: %ld\n",
 		       IBLND_CQ_ENTRIES(conn), PTR_ERR(cq));
 		goto failed_2;
@@ -1320,9 +1324,8 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 {
 	LASSERT(!fpo->fpo_map_count);
 
-	if (fpo->fpo_is_fmr) {
-		if (fpo->fmr.fpo_fmr_pool)
-			ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
+	if (fpo->fpo_is_fmr && fpo->fmr.fpo_fmr_pool) {
+		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
 	} else {
 		struct kib_fast_reg_descriptor *frd;
 		int i = 0;
@@ -1654,7 +1657,7 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 
 int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
-			struct kib_fmr *fmr, bool *is_fastreg)
+			struct kib_fmr *fmr)
 {
 	__u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
@@ -1674,7 +1677,6 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		if (fpo->fpo_is_fmr) {
 			struct ib_pool_fmr *pfmr;
 
-			*is_fastreg = 0;
 			spin_unlock(&fps->fps_lock);
 
 			if (!tx_pages_mapped) {
@@ -1694,7 +1696,6 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			}
 			rc = PTR_ERR(pfmr);
 		} else {
-			*is_fastreg = 1;
 			if (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
 				struct kib_fast_reg_descriptor *frd;
 				struct ib_reg_wr *wr;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index aaf0118..a6008ea 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -121,9 +121,8 @@ struct kib_tunables {
 #define IBLND_OOB_CAPABLE(v)       ((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	   (IBLND_OOB_CAPABLE(v) ? 2 : 0)
 
-#define IBLND_FRAG_SHIFT	(PAGE_SHIFT - 12)	/* frag size on wire is in 4K units */
-#define IBLND_MSG_SIZE		(4 << 10)		/* max size of queued messages (inc hdr) */
-#define IBLND_MAX_RDMA_FRAGS	(LNET_MAX_PAYLOAD >> 12)/* max # of fragments supported in 4K size */
+#define IBLND_MSG_SIZE		(4 << 10)	/* max size of queued messages (inc hdr) */
+#define IBLND_MAX_RDMA_FRAGS	LNET_MAX_IOV	/* max # of fragments supported */
 
 /************************/
 /* derived constants... */
@@ -141,8 +140,8 @@ struct kib_tunables {
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 #define IBLND_SEND_WRS(c)	\
-	(((c->ibc_max_frags + 1) << IBLND_FRAG_SHIFT) * \
-	  kiblnd_concurrent_sends(c->ibc_version, c->ibc_peer->ibp_ni))
+	((c->ibc_max_frags + 1) * kiblnd_concurrent_sends(c->ibc_version, \
+							  c->ibc_peer->ibp_ni))
 #define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + IBLND_SEND_WRS(c))
 
 struct kib_hca_dev;
@@ -288,7 +287,7 @@ struct kib_fmr_pool {
 	time64_t		fpo_deadline;	/* deadline of this pool */
 	int                   fpo_failed;          /* fmr pool is failed */
 	int                   fpo_map_count;       /* # of mapped FMR */
-	int		      fpo_is_fmr;
+	bool			fpo_is_fmr;	/* True if FMR pools allocated */
 };
 
 struct kib_fmr {
@@ -515,7 +514,9 @@ struct kib_tx {					/* transmit message */
 	int                   tx_nfrags;      /* # entries in... */
 	struct scatterlist    *tx_frags;      /* dma_map_sg descriptor */
 	__u64                 *tx_pages;      /* rdma phys page addrs */
-	struct kib_fmr        fmr;	      /* FMR */
+	/* gaps in fragments */
+	bool			tx_gaps;
+	struct kib_fmr		tx_fmr;		/* FMR */
 	int                   tx_dmadir;      /* dma direction */
 };
 
@@ -616,26 +617,6 @@ struct kib_peer_ni {
 
 int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
 
-/* max # of fragments configured by user */
-static inline int
-kiblnd_cfg_rdma_frags(struct lnet_ni *ni)
-{
-	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
-	int mod;
-
-	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
-	mod = tunables->lnd_map_on_demand;
-	return mod ? mod : IBLND_MAX_RDMA_FRAGS >> IBLND_FRAG_SHIFT;
-}
-
-static inline int
-kiblnd_rdma_frags(int version, struct lnet_ni *ni)
-{
-	return version == IBLND_MSG_VERSION_1 ?
-			  (IBLND_MAX_RDMA_FRAGS >> IBLND_FRAG_SHIFT) :
-			  kiblnd_cfg_rdma_frags(ni);
-}
-
 static inline int
 kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
 {
@@ -1011,7 +992,7 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 
 int  kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			 struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
-			 struct kib_fmr *fmr, bool *is_fastreg);
+			 struct kib_fmr *fmr);
 void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status);
 
 int kiblnd_tunables_setup(struct lnet_ni *ni);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b16153f..9d30f31 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -133,6 +133,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	LASSERT(!tx->tx_lntmsg[1]);
 	LASSERT(!tx->tx_nfrags);
 
+	tx->tx_gaps = false;
+
 	return tx;
 }
 
@@ -538,7 +540,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 {
 	struct kib_hca_dev *hdev;
 	struct kib_fmr_poolset *fps;
-	bool is_fastreg = 0;
+	struct kib_dev *dev;
 	int cpt;
 	int rc;
 	int i;
@@ -546,11 +548,42 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	LASSERT(tx->tx_pool);
 	LASSERT(tx->tx_pool->tpo_pool.po_owner);
 
+	dev = net->ibn_dev;
 	hdev = tx->tx_pool->tpo_hdev;
 	cpt = tx->tx_pool->tpo_pool.po_owner->ps_cpt;
 
+	/*
+	 * If we're dealing with FastReg, but the device doesn't
+	 * support GAPS and the tx has GAPS, then there is no real point
+	 * in trying to map the memory, because it'll just fail. So
+	 * preemptively fail with an appropriate message
+	 */
+	if ((dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED) &&
+	    !(dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_GAPS_SUPPORT) &&
+	    tx->tx_gaps) {
+		CERROR("Using FastReg with no GAPS support, but tx has gaps\n");
+		return -EPROTONOSUPPORT;
+	}
+
+	/*
+	 * FMR does not support gaps but the tx has gaps then
+	 * we should make sure that the number of fragments we'll be sending
+	 * over fits within the number of fragments negotiated on the
+	 * connection, otherwise, we won't be able to RDMA the data.
+	 * We need to maintain the number of fragments negotiation on the
+	 * connection for backwards compatibility.
+	 */
+	if (tx->tx_gaps && (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)) {
+		if (tx->tx_conn &&
+		    tx->tx_conn->ibc_max_frags <= rd->rd_nfrags) {
+			CERROR("TX number of frags (%d) is <= than connection number of frags (%d). Consider setting peer's map_on_demand to 256\n",
+			       tx->tx_nfrags, tx->tx_conn->ibc_max_frags);
+			return -EFBIG;
+		}
+	}
+
 	fps = net->ibn_fmr_ps[cpt];
-	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->fmr, &is_fastreg);
+	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->tx_fmr);
 	if (rc) {
 		CERROR("Can't map %u bytes: %d\n", nob, rc);
 		return rc;
@@ -560,15 +593,28 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	 * If rd is not tx_rd, it's going to get sent to a peer_ni,
 	 * who will need the rkey
 	 */
-	rd->rd_key = tx->fmr.fmr_key;
-	if (!is_fastreg) {
+	rd->rd_key = tx->tx_fmr.fmr_key;
+	/*
+	 * for FastReg or FMR with no gaps we can accumulate all
+	 * the fragments in one FastReg or FMR fragment.
+	 */
+	if (((dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED) && !tx->tx_gaps) ||
+	    (dev->ibd_dev_caps & IBLND_DEV_CAPS_FASTREG_ENABLED)) {
+		/* FMR requires zero based address */
+		if (dev->ibd_dev_caps & IBLND_DEV_CAPS_FMR_ENABLED)
+			rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
+		rd->rd_frags[0].rf_nob = nob;
+		rd->rd_nfrags = 1;
+	} else {
+		/*
+		 * We're transmitting with gaps using FMR.
+		 * We'll need to use multiple fragments and identify the
+		 * zero based address of each fragment.
+		 */
 		for (i = 0; i < rd->rd_nfrags; i++) {
 			rd->rd_frags[i].rf_addr &= ~hdev->ibh_page_mask;
 			rd->rd_frags[i].rf_addr += i << hdev->ibh_page_shift;
 		}
-	} else {
-		rd->rd_frags[0].rf_nob = nob;
-		rd->rd_nfrags = 1;
 	}
 
 	return 0;
@@ -576,8 +622,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 static void kiblnd_unmap_tx(struct kib_tx *tx)
 {
-	if (tx->fmr.fmr_pfmr || tx->fmr.fmr_frd)
-		kiblnd_fmr_pool_unmap(&tx->fmr, tx->tx_status);
+	if (tx->tx_fmr.fmr_pfmr || tx->tx_fmr.fmr_frd)
+		kiblnd_fmr_pool_unmap(&tx->tx_fmr, tx->tx_status);
 
 	if (tx->tx_nfrags) {
 		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev->ibh_ibdev,
@@ -656,6 +702,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		fragnob = min((int)(iov->iov_len - offset), nob);
 		fragnob = min(fragnob, (int)PAGE_SIZE - page_offset);
 
+		if ((fragnob < (int)PAGE_SIZE - page_offset) && (niov > 1)) {
+			CDEBUG(D_NET,
+			       "fragnob %d < available page %d: with remaining %d iovs\n",
+			       fragnob, (int)PAGE_SIZE - page_offset, niov);
+			tx->tx_gaps = true;
+		}
+
 		sg_set_page(sg, page, fragnob, page_offset);
 		sg = sg_next(sg);
 		if (!sg) {
@@ -704,6 +757,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 		fragnob = min((int)(kiov->bv_len - offset), nob);
 
+		if ((fragnob < (int)(kiov->bv_len - offset)) && nkiov > 1) {
+			CDEBUG(D_NET,
+			       "fragnob %d < available page %d: with remaining %d kiovs\n",
+			       fragnob, (int)(kiov->bv_len - offset), nkiov);
+			tx->tx_gaps = true;
+		}
+
 		sg_set_page(sg, kiov->bv_page, fragnob,
 			    kiov->bv_offset + offset);
 		sg = sg_next(sg);
@@ -735,6 +795,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(tx->tx_queued);
 	/* We rely on this for QP sizing */
 	LASSERT(tx->tx_nwrq > 0 && tx->tx_nsge >= 0);
+	LASSERT(tx->tx_nwrq <= 1 + conn->ibc_max_frags);
 
 	LASSERT(!credit || credit == 1);
 	LASSERT(conn->ibc_outstanding_credits >= 0);
@@ -814,7 +875,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		/* close_conn will launch failover */
 		rc = -ENETDOWN;
 	} else {
-		struct kib_fast_reg_descriptor *frd = tx->fmr.fmr_frd;
+		struct kib_fast_reg_descriptor *frd = tx->tx_fmr.fmr_frd;
 		const struct ib_send_wr *bad = &tx->tx_wrq[tx->tx_nwrq - 1].wr;
 		struct ib_send_wr *wrq = &tx->tx_wrq[0].wr;
 
@@ -1042,15 +1103,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(!tx->tx_nwrq && !tx->tx_nsge);
 	LASSERT(type == IBLND_MSG_GET_DONE || type == IBLND_MSG_PUT_DONE);
 
-	if (kiblnd_rd_size(srcrd) > conn->ibc_max_frags << PAGE_SHIFT) {
-		CERROR("RDMA is too large for peer_ni %s (%d), src size: %d dst size: %d\n",
-		       libcfs_nid2str(conn->ibc_peer->ibp_nid),
-		       conn->ibc_max_frags << PAGE_SHIFT,
-		       kiblnd_rd_size(srcrd), kiblnd_rd_size(dstrd));
-		rc = -EMSGSIZE;
-		goto too_big;
-	}
-
 	for (srcidx = dstidx = wrq_sge = sge_nob = 0;
 	     resid > 0; resid -= sge_nob) {
 		int prev = dstidx;
@@ -1067,10 +1119,10 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			break;
 		}
 
-		if (tx->tx_nwrq >= IBLND_MAX_RDMA_FRAGS) {
+		if (tx->tx_nwrq >= conn->ibc_max_frags) {
 			CERROR("RDMA has too many fragments for peer_ni %s (%d), src idx/frags: %d/%d dst idx/frags: %d/%d\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
-			       IBLND_MAX_RDMA_FRAGS,
+			       conn->ibc_max_frags,
 			       srcidx, srcrd->rd_nfrags,
 			       dstidx, dstrd->rd_nfrags);
 			rc = -EMSGSIZE;
@@ -1110,7 +1162,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		}
 		tx->tx_nsge++;
 	}
-too_big:
+
 	if (rc < 0) { /* no RDMA if completing with failure */
 		tx->tx_nsge = 0;
 		tx->tx_nwrq = 0;
@@ -2335,21 +2387,20 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		goto failed;
 	}
 
-	max_frags = reqmsg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT;
-	if (max_frags > kiblnd_rdma_frags(version, ni)) {
+	max_frags = reqmsg->ibm_u.connparams.ibcp_max_frags;
+	if (max_frags > IBLND_MAX_RDMA_FRAGS) {
 		CWARN("Can't accept conn from %s (version %x): max message size %d is too large (%d wanted)\n",
 		      libcfs_nid2str(nid), version, max_frags,
-		      kiblnd_rdma_frags(version, ni));
+		      IBLND_MAX_RDMA_FRAGS);
 
 		if (version >= IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
 
 		goto failed;
-	} else if (max_frags < kiblnd_rdma_frags(version, ni) &&
-		   !net->ibn_fmr_ps) {
+	} else if (max_frags < IBLND_MAX_RDMA_FRAGS && !net->ibn_fmr_ps) {
 		CWARN("Can't accept conn from %s (version %x): max message size %d incompatible without FMR pool (%d wanted)\n",
 		      libcfs_nid2str(nid), version, max_frags,
-		      kiblnd_rdma_frags(version, ni));
+		      IBLND_MAX_RDMA_FRAGS);
 
 		if (version == IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
@@ -2495,7 +2546,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	kiblnd_init_msg(ackmsg, IBLND_MSG_CONNACK,
 			sizeof(ackmsg->ibm_u.connparams));
 	ackmsg->ibm_u.connparams.ibcp_queue_depth = conn->ibc_queue_depth;
-	ackmsg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags << IBLND_FRAG_SHIFT;
+	ackmsg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags;
 	ackmsg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
 	kiblnd_pack_msg(ni, ackmsg, version, 0, nid, reqmsg->ibm_srcstamp);
@@ -2528,7 +2579,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
  failed:
 	if (ni) {
 		rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
-		rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
+		rej.ibr_cp.ibcp_max_frags = IBLND_MAX_RDMA_FRAGS;
 		lnet_ni_decref(ni);
 	}
 
@@ -2556,7 +2607,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	if (cp) {
 		msg_size = cp->ibcp_max_msg_size;
-		frag_num	= cp->ibcp_max_frags << IBLND_FRAG_SHIFT;
+		frag_num = cp->ibcp_max_frags;
 		queue_dep = cp->ibcp_queue_depth;
 	}
 
@@ -2590,6 +2641,10 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			goto out;
 		}
 		tunables = &peer_ni->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+		/*
+		 * This check only makes sense if the kernel supports global
+		 * memory registration. Otherwise, map_on_demand will never == 0
+		 */
 		if (!tunables->lnd_map_on_demand) {
 			reason = "map_on_demand must be enabled";
 			goto out;
@@ -2829,11 +2884,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		goto failed;
 	}
 
-	if ((msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT) >
+	if ((msg->ibm_u.connparams.ibcp_max_frags) >
 	    conn->ibc_max_frags) {
 		CERROR("%s has incompatible max_frags %d (<=%d wanted)\n",
 		       libcfs_nid2str(peer_ni->ibp_nid),
-		       msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT,
+		       msg->ibm_u.connparams.ibcp_max_frags,
 		       conn->ibc_max_frags);
 		rc = -EPROTO;
 		goto failed;
@@ -2867,7 +2922,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	conn->ibc_credits = msg->ibm_u.connparams.ibcp_queue_depth;
 	conn->ibc_reserved_credits = msg->ibm_u.connparams.ibcp_queue_depth;
 	conn->ibc_queue_depth = msg->ibm_u.connparams.ibcp_queue_depth;
-	conn->ibc_max_frags = msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT;
+	conn->ibc_max_frags = msg->ibm_u.connparams.ibcp_max_frags;
 	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits +
 		IBLND_OOB_MSGS(ver) <= IBLND_RX_MSGS(conn));
 
@@ -2924,7 +2979,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	memset(msg, 0, sizeof(*msg));
 	kiblnd_init_msg(msg, IBLND_MSG_CONNREQ, sizeof(msg->ibm_u.connparams));
 	msg->ibm_u.connparams.ibcp_queue_depth = conn->ibc_queue_depth;
-	msg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags << IBLND_FRAG_SHIFT;
+	msg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags;
 	msg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
 	kiblnd_pack_msg(peer_ni->ibp_ni, msg, version,
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 985ccdf..7fc6a8a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -115,10 +115,37 @@
 module_param(use_fastreg_gaps, bool, 0444);
 MODULE_PARM_DESC(use_fastreg_gaps, "Enable discontiguous fastreg fragment support. Expect performance drop");
 
-#define IBLND_DEFAULT_MAP_ON_DEMAND IBLND_MAX_RDMA_FRAGS
+/*
+ * map_on_demand is a flag used to determine if we can use FMR or FastReg.
+ * This is applicable for kernels which support global memory regions. For
+ * later kernels this flag is always enabled, since we will always either
+ * use FMR or FastReg
+ * For kernels which support global memory regions map_on_demand defaults
+ * to 0 which means we will be using global memory regions exclusively.
+ * If it is set to a value other than 0, then we will behave as follows:
+ *  1. Always default the number of fragments to IBLND_MAX_RDMA_FRAGS
+ *  2. Create FMR/FastReg pools
+ *  3. Negotiate the supported number of fragments per connection
+ *  4. Attempt to transmit using global memory regions only if
+ *     map-on-demand is not turned on, otherwise use FMR or FastReg
+ *  5. In case of transmitting tx with GAPS over FMR we will need to
+ *     transmit it with multiple fragments. Look at the comments in
+ *     kiblnd_fmr_map_tx() for an explanation of the behavior.
+ *
+ * For later kernels we default map_on_demand to 1 and not allow
+ * it to be set to 0, since there is no longer support for global memory
+ * regions. Behavior:
+ *  1. Default the number of fragments to IBLND_MAX_RDMA_FRAGS
+ *  2. Create FMR/FastReg pools
+ *  3. Negotiate the supported number of fragments per connection
+ *  4. Look at the comments in kiblnd_fmr_map_tx() for an explanation of
+ *     the behavior when transmit with GAPS verses contiguous.
+ */
+
+#define IBLND_DEFAULT_MAP_ON_DEMAND 1
 static int map_on_demand = IBLND_DEFAULT_MAP_ON_DEMAND;
 module_param(map_on_demand, int, 0444);
-MODULE_PARM_DESC(map_on_demand, "map on demand");
+MODULE_PARM_DESC(map_on_demand, "map on demand (obsolete)");
 
 /* NB: this value is shared by all CPTs, it can grow at runtime */
 static int fmr_pool_size = 512;
@@ -234,6 +261,13 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 		net_tunables->lct_peer_tx_credits =
 			net_tunables->lct_max_tx_credits;
 
+	/*
+	 * For kernels which do not support global memory regions, always
+	 * enable map_on_demand
+	 */
+	if (tunables->lnd_map_on_demand == 0)
+		tunables->lnd_map_on_demand = 1;
+
 	if (!tunables->lnd_peercredits_hiw)
 		tunables->lnd_peercredits_hiw = peer_credits_hiw;
 
@@ -243,19 +277,8 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	if (tunables->lnd_peercredits_hiw >= net_tunables->lct_peer_tx_credits)
 		tunables->lnd_peercredits_hiw = net_tunables->lct_peer_tx_credits - 1;
 
-	if (tunables->lnd_map_on_demand <= 0 ||
-	    tunables->lnd_map_on_demand > IBLND_MAX_RDMA_FRAGS) {
-		/* Use the default */
-		CWARN("Invalid map_on_demand (%d), expects 1 - %d. Using default of %d\n",
-		      tunables->lnd_map_on_demand,
-		      IBLND_MAX_RDMA_FRAGS, IBLND_DEFAULT_MAP_ON_DEMAND);
-		tunables->lnd_map_on_demand = IBLND_DEFAULT_MAP_ON_DEMAND;
-	}
-
-	if (tunables->lnd_map_on_demand == 1) {
-		/* don't make sense to create map if only one fragment */
-		tunables->lnd_map_on_demand = 2;
-	}
+	if (tunables->lnd_concurrent_sends == 0)
+		tunables->lnd_concurrent_sends = net_tunables->lct_peer_tx_credits;
 
 	if (!tunables->lnd_concurrent_sends) {
 		if (tunables->lnd_map_on_demand > 0 &&
@@ -299,7 +322,7 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 void kiblnd_tunables_init(void)
 {
 	default_tunables.lnd_version = 0;
-	default_tunables.lnd_peercredits_hiw = peer_credits_hiw,
+	default_tunables.lnd_peercredits_hiw = peer_credits_hiw;
 	default_tunables.lnd_map_on_demand = map_on_demand;
 	default_tunables.lnd_concurrent_sends = concurrent_sends;
 	default_tunables.lnd_fmr_pool_size = fmr_pool_size;
-- 
1.8.3.1
