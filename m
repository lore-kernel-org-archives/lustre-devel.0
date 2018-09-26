From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:09 -0400
Subject: [lustre-devel] [PATCH 17/25] lustre: o2iblnd: multiple sges for
 work request
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Liang Zhen <liang.zhen@intel.com>

In current protocol, lnet router cannot align buffer for rdma,
o2iblnd may run into "too fragmented RDMA" issue while routing
non-page-aligned IO larger than 512K, because each page will
be splited into two fragments by kiblnd_init_rdma().

With this patch, o2iblnd can have multiple sges for each work
request, and combine multiple remote fragments of the same page
into one work request to resovle the "too fragmented RDMA" issue.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-5718
Reviewed-on: https://review.whamcloud.com/12451
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 13 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  5 ++
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 73 ++++++++++++----------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  7 ++-
 4 files changed, 60 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index aea83a5..9e8248e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -761,7 +761,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	init_qp_attr->qp_context = conn;
 	init_qp_attr->cap.max_send_wr = IBLND_SEND_WRS(conn);
 	init_qp_attr->cap.max_recv_wr = IBLND_RECV_WRS(conn);
-	init_qp_attr->cap.max_send_sge = 1;
+	init_qp_attr->cap.max_send_sge = *kiblnd_tunables.kib_wrq_sge;
 	init_qp_attr->cap.max_recv_sge = 1;
 	init_qp_attr->sq_sig_type = IB_SIGNAL_REQ_WR;
 	init_qp_attr->qp_type = IB_QPT_RC;
@@ -772,9 +772,11 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
 	if (rc) {
-		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d\n",
+		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d, send_sge: %d, recv_sge: %d\n",
 		       rc, init_qp_attr->cap.max_send_wr,
-		       init_qp_attr->cap.max_recv_wr);
+		       init_qp_attr->cap.max_recv_wr,
+		       init_qp_attr->cap.max_send_sge,
+		       init_qp_attr->cap.max_recv_sge);
 		goto failed_2;
 	}
 
@@ -2039,6 +2041,7 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 
 	for (i = 0; i < size; i++) {
 		struct kib_tx *tx = &tpo->tpo_tx_descs[i];
+		int wrq_sge = *kiblnd_tunables.kib_wrq_sge;
 
 		tx->tx_pool = tpo;
 		if (ps->ps_net->ibn_fmr_ps) {
@@ -2063,8 +2066,8 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 			break;
 
 		tx->tx_sge = kzalloc_cpt((1 + IBLND_MAX_RDMA_FRAGS) *
-					 sizeof(*tx->tx_sge),
-					 GFP_NOFS, ps->ps_cpt);
+					 wrq_sge * sizeof(*tx->tx_sge),
+					 GFP_KERNEL, ps->ps_cpt);
 		if (!tx->tx_sge)
 			break;
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index de04355..f21bdee 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -89,6 +89,7 @@ struct kib_tunables {
 	int *kib_require_priv_port;      /* accept only privileged ports */
 	int *kib_use_priv_port; /* use privileged port for active connect */
 	int *kib_nscheds;                /* # threads on each CPT */
+	int *kib_wrq_sge;		 /* # sg elements per wrq */
 };
 
 extern struct kib_tunables  kiblnd_tunables;
@@ -495,7 +496,11 @@ struct kib_tx {					/* transmit message */
 	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
 	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
 	DECLARE_PCI_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
+	/** sge for tx_msgaddr */
+	struct ib_sge		tx_msgsge;
 	int                   tx_nwrq;        /* # send work items */
+	/* # used scatter/gather elements */
+	int			tx_nsge;
 	struct ib_rdma_wr     *tx_wrq;        /* send work items... */
 	struct ib_sge         *tx_sge;        /* ...and their memory */
 	struct kib_rdma_desc  *tx_rd;         /* rdma descriptor */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 3218999..80398c1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -79,6 +79,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	}
 
 	tx->tx_nwrq = 0;
+	tx->tx_nsge = 0;
 	tx->tx_status = 0;
 
 	kiblnd_pool_free_node(&tx->tx_pool->tpo_pool, &tx->tx_list);
@@ -415,6 +416,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		 * (b) tx_waiting set tells tx_complete() it's not done.
 		 */
 		tx->tx_nwrq = 0;		/* overwrite PUT_REQ */
+		tx->tx_nsge = 0;
 
 		rc2 = kiblnd_init_rdma(conn, tx, IBLND_MSG_PUT_DONE,
 				       kiblnd_rd_size(&msg->ibm_u.putack.ibpam_rd),
@@ -724,7 +726,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	LASSERT(tx->tx_queued);
 	/* We rely on this for QP sizing */
-	LASSERT(tx->tx_nwrq > 0);
+	LASSERT(tx->tx_nwrq > 0 && tx->tx_nsge >= 0);
 
 	LASSERT(!credit || credit == 1);
 	LASSERT(conn->ibc_outstanding_credits >= 0);
@@ -988,7 +990,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		   int body_nob)
 {
 	struct kib_hca_dev *hdev = tx->tx_pool->tpo_hdev;
-	struct ib_sge *sge = &tx->tx_sge[tx->tx_nwrq];
+	struct ib_sge *sge = &tx->tx_msgsge;
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[tx->tx_nwrq];
 	int nob = offsetof(struct kib_msg, ibm_u) + body_nob;
 
@@ -1020,17 +1022,17 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	struct kib_msg *ibmsg = tx->tx_msg;
 	struct kib_rdma_desc *srcrd = tx->tx_rd;
-	struct ib_sge *sge = &tx->tx_sge[0];
-	struct ib_rdma_wr *wrq, *next;
+	struct ib_rdma_wr *wrq = NULL;
+	struct ib_sge *sge;
 	int rc  = resid;
 	int srcidx = 0;
 	int dstidx = 0;
-	int wrknob;
+	int sge_nob;
+	int wrq_sge;
 
 	LASSERT(!in_interrupt());
-	LASSERT(!tx->tx_nwrq);
-	LASSERT(type == IBLND_MSG_GET_DONE ||
-		type == IBLND_MSG_PUT_DONE);
+	LASSERT(!tx->tx_nwrq && !tx->tx_nsge);
+	LASSERT(type == IBLND_MSG_GET_DONE || type == IBLND_MSG_PUT_DONE);
 
 	if (kiblnd_rd_size(srcrd) > conn->ibc_max_frags << PAGE_SHIFT) {
 		CERROR("RDMA is too large for peer_ni %s (%d), src size: %d dst size: %d\n",
@@ -1041,7 +1043,10 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		goto too_big;
 	}
 
-	while (resid > 0) {
+	for (srcidx = dstidx = wrq_sge = sge_nob = 0;
+	     resid > 0; resid -= sge_nob) {
+		int prev = dstidx;
+
 		if (srcidx >= srcrd->rd_nfrags) {
 			CERROR("Src buffer exhausted: %d frags\n", srcidx);
 			rc = -EPROTO;
@@ -1064,40 +1069,44 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			break;
 		}
 
-		wrknob = min3(kiblnd_rd_frag_size(srcrd, srcidx),
-			      kiblnd_rd_frag_size(dstrd, dstidx),
-			      (__u32)resid);
+		sge_nob = min3(kiblnd_rd_frag_size(srcrd, srcidx),
+			       kiblnd_rd_frag_size(dstrd, dstidx),
+			       (u32)resid);
 
-		sge = &tx->tx_sge[tx->tx_nwrq];
+		sge = &tx->tx_sge[tx->tx_nsge];
 		sge->addr   = kiblnd_rd_frag_addr(srcrd, srcidx);
 		sge->lkey   = kiblnd_rd_frag_key(srcrd, srcidx);
-		sge->length = wrknob;
-
-		wrq = &tx->tx_wrq[tx->tx_nwrq];
-		next = wrq + 1;
+		sge->length = sge_nob;
 
-		wrq->wr.next       = &next->wr;
-		wrq->wr.wr_id      = kiblnd_ptr2wreqid(tx, IBLND_WID_RDMA);
-		wrq->wr.sg_list    = sge;
-		wrq->wr.num_sge    = 1;
-		wrq->wr.opcode     = IB_WR_RDMA_WRITE;
-		wrq->wr.send_flags = 0;
+		if (wrq_sge == 0) {
+			wrq = &tx->tx_wrq[tx->tx_nwrq];
 
-		wrq->remote_addr = kiblnd_rd_frag_addr(dstrd, dstidx);
-		wrq->rkey        = kiblnd_rd_frag_key(dstrd, dstidx);
+			wrq->wr.next = &(wrq + 1)->wr;
+			wrq->wr.wr_id = kiblnd_ptr2wreqid(tx, IBLND_WID_RDMA);
+			wrq->wr.sg_list = sge;
+			wrq->wr.opcode = IB_WR_RDMA_WRITE;
+			wrq->wr.send_flags = 0;
 
-		srcidx = kiblnd_rd_consume_frag(srcrd, srcidx, wrknob);
-		dstidx = kiblnd_rd_consume_frag(dstrd, dstidx, wrknob);
+			wrq->remote_addr = kiblnd_rd_frag_addr(dstrd, dstidx);
+			wrq->rkey = kiblnd_rd_frag_key(dstrd, dstidx);
+		}
 
-		resid -= wrknob;
+		srcidx = kiblnd_rd_consume_frag(srcrd, srcidx, sge_nob);
+		dstidx = kiblnd_rd_consume_frag(dstrd, dstidx, sge_nob);
 
-		tx->tx_nwrq++;
-		wrq++;
-		sge++;
+		wrq_sge++;
+		if (wrq_sge == *kiblnd_tunables.kib_wrq_sge || dstidx != prev) {
+			tx->tx_nwrq++;
+			wrq->wr.num_sge = wrq_sge;
+			wrq_sge = 0;
+		}
+		tx->tx_nsge++;
 	}
 too_big:
-	if (rc < 0)			     /* no RDMA if completing with failure */
+	if (rc < 0) { /* no RDMA if completing with failure */
+		tx->tx_nsge = 0;
 		tx->tx_nwrq = 0;
+	}
 
 	ibmsg->ibm_u.completion.ibcm_status = rc;
 	ibmsg->ibm_u.completion.ibcm_cookie = dstcookie;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 5117594..891708e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -147,6 +147,10 @@
 module_param(use_privileged_port, int, 0644);
 MODULE_PARM_DESC(use_privileged_port, "use privileged port when initiating connection");
 
+static unsigned int wrq_sge = 1;
+module_param(wrq_sge, uint, 0444);
+MODULE_PARM_DESC(wrq_sge, "# scatter/gather element per work request");
+
 struct kib_tunables kiblnd_tunables = {
 	.kib_dev_failover      = &dev_failover,
 	.kib_service           = &service,
@@ -160,7 +164,8 @@ struct kib_tunables kiblnd_tunables = {
 	.kib_ib_mtu            = &ib_mtu,
 	.kib_require_priv_port = &require_privileged_port,
 	.kib_use_priv_port     = &use_privileged_port,
-	.kib_nscheds           = &nscheds
+	.kib_nscheds		= &nscheds,
+	.kib_wrq_sge		= &wrq_sge,
 };
 
 static struct lnet_ioctl_config_o2iblnd_tunables default_tunables;
-- 
1.8.3.1
