Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CDEC4C19F2A
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrwh3ChVz23JL;
	Wed,  3 Aug 2022 18:38:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwS6XYLz23JB
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:32 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BD269100AFFA;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BA6388D620; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:55 -0400
Message-Id: <1659577097-19253-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/32] lnet: Replace msg_rdma_force with a
 new md_flag LNET_MD_FLAG_GPU.
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Chris Horn <chris.horn@hpe.com>, Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

HPE-bug-id: LUS-10520
WC-bug-id: https://jira.whamcloud.com/browse/LU-15189
Lustre-commit: 959304eac7ec5b156 ("LU-15189 lnet: fix memory mapping.")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/45482
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
HPE-bug-id: LUS-10997
WC-bug-id: https://jira.whamcloud.com/browse/LU-15914
Lustre-commit: cb0220db3ce517b0e ("LU-15914 lnet: Fix null md deref for finalized message")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h       |  4 +++-
 fs/lustre/osc/osc_request.c          |  3 +++
 fs/lustre/ptlrpc/pers.c              |  3 +++
 include/linux/lnet/lib-types.h       |  3 +--
 include/uapi/linux/lnet/lnet-types.h |  2 ++
 net/lnet/klnds/o2iblnd/o2iblnd.h     | 23 +++++++++++++++--------
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c  | 31 +++++++++++++++++++++----------
 net/lnet/lnet/lib-md.c               |  3 +++
 net/lnet/lnet/lib-move.c             | 10 ++++++----
 9 files changed, 57 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 7d29542..f70cc7c 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1186,7 +1186,9 @@ struct ptlrpc_bulk_desc {
 	/** completed with failure */
 	unsigned long			bd_failure:1;
 	/** client side */
-	unsigned long			bd_registered:1;
+	unsigned long			bd_registered:1,
+	/* bulk request is RDMA transfer, use page->host as real address */
+					bd_is_rdma:1;
 	/** For serialization with callback */
 	spinlock_t			bd_lock;
 	/** {put,get}{source,sink}{kiov} */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index d84884f..21e036e 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1416,6 +1416,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct inode *inode = NULL;
 	bool directio = false;
+	bool gpu = 0;
 	bool enable_checksum = true;
 	struct cl_page *clpage;
 
@@ -1581,6 +1582,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	if (brw_page2oap(pga[0])->oap_brw_flags & OBD_BRW_RDMA_ONLY) {
 		enable_checksum = false;
 		short_io_size = 0;
+		gpu = 1;
 	}
 
 	/* Check if read/write is small enough to be a short io. */
@@ -1632,6 +1634,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		goto out;
 	}
 	/* NB request now owns desc and will free it when it gets freed */
+	desc->bd_is_rdma = gpu;
 no_bulk:
 	body = req_capsule_client_get(pill, &RMF_OST_BODY);
 	ioobj = req_capsule_client_get(pill, &RMF_OBD_IOOBJ);
diff --git a/fs/lustre/ptlrpc/pers.c b/fs/lustre/ptlrpc/pers.c
index e24c8e3..b35d2fe 100644
--- a/fs/lustre/ptlrpc/pers.c
+++ b/fs/lustre/ptlrpc/pers.c
@@ -58,6 +58,9 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 		return;
 	}
 
+	if (desc->bd_is_rdma)
+		md->options |= LNET_MD_GPU_ADDR;
+
 	if (mdidx == (desc->bd_md_count - 1))
 		md->length = desc->bd_iov_count - start;
 	else
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index f7f0b0b..1827f4e 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -138,8 +138,6 @@ struct lnet_msg {
 	enum lnet_msg_hstatus	msg_health_status;
 	/* This is a recovery message */
 	bool			msg_recovery;
-	/* force an RDMA even if the message size is < 4K */
-	bool			msg_rdma_force;
 	/* the number of times a transmission has been retried */
 	int			msg_retry_count;
 	/* flag to indicate that we do not want to resend this message */
@@ -245,6 +243,7 @@ struct lnet_libmd {
  */
 #define LNET_MD_FLAG_HANDLING		BIT(3)
 #define LNET_MD_FLAG_DISCARD		BIT(4)
+#define LNET_MD_FLAG_GPU		BIT(5) /**< Special mapping needs */
 
 struct lnet_test_peer {
 	/* info about peers we are trying to fail */
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index c5fca5c..5a2ea45 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -467,6 +467,8 @@ struct lnet_md {
 #define LNET_MD_TRACK_RESPONSE		(1 << 10)
 /** See struct lnet_md::options. */
 #define LNET_MD_NO_TRACK_RESPONSE	(1 << 11)
+/** Special page mapping handling */
+#define LNET_MD_GPU_ADDR		(1 << 13)
 
 /** Infinite threshold on MD operations. See lnet_md::threshold */
 #define LNET_MD_THRESH_INF	(-1)
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index e798695..0066e85 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -401,8 +401,9 @@ struct kib_tx {					/* transmit message */
 	struct kib_tx_pool     *tx_pool;	/* pool I'm from */
 	struct kib_conn	       *tx_conn;	/* owning conn */
 	short			tx_sending;	/* # tx callbacks outstanding */
-	short			tx_queued;	/* queued for sending */
-	short			tx_waiting;	/* waiting for peer_ni */
+	unsigned long		tx_queued:1,	/* queued for sending */
+				tx_waiting:1,	/* waiting for peer_ni */
+				tx_gpu:1;	/* force DMA */
 	int			tx_status;	/* LNET completion status */
 	enum lnet_msg_hstatus	tx_hstatus;	/* health status of the transmit */
 	ktime_t			tx_deadline;	/* completion deadline */
@@ -861,17 +862,23 @@ static inline void kiblnd_dma_unmap_single(struct ib_device *dev,
 #define KIBLND_UNMAP_ADDR_SET(p, m, a)	do {} while (0)
 #define KIBLND_UNMAP_ADDR(p, m, a)	(a)
 
-static inline int kiblnd_dma_map_sg(struct kib_hca_dev *hdev,
-				    struct scatterlist *sg, int nents,
-				    enum dma_data_direction direction)
+static inline
+int kiblnd_dma_map_sg(struct kib_hca_dev *hdev, struct kib_tx *tx)
 {
+	struct scatterlist *sg = tx->tx_frags;
+	int nents = tx->tx_nfrags;
+	enum dma_data_direction direction = tx->tx_dmadir;
+
 	return ib_dma_map_sg(hdev->ibh_ibdev, sg, nents, direction);
 }
 
-static inline void kiblnd_dma_unmap_sg(struct kib_hca_dev *hdev,
-				       struct scatterlist *sg, int nents,
-				       enum dma_data_direction direction)
+static inline
+void kiblnd_dma_unmap_sg(struct kib_hca_dev *hdev, struct kib_tx *tx)
 {
+	struct scatterlist *sg = tx->tx_frags;
+	int nents = tx->tx_nfrags;
+	enum dma_data_direction direction = tx->tx_dmadir;
+
 	ib_dma_unmap_sg(hdev->ibh_ibdev, sg, nents, direction);
 }
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index cb96282..01fa499 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -623,8 +623,7 @@ static void kiblnd_unmap_tx(struct kib_tx *tx)
 		kiblnd_fmr_pool_unmap(&tx->tx_fmr, tx->tx_status);
 
 	if (tx->tx_nfrags) {
-		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev,
-				    tx->tx_frags, tx->tx_nfrags, tx->tx_dmadir);
+		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev, tx);
 		tx->tx_nfrags = 0;
 	}
 }
@@ -644,9 +643,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	tx->tx_dmadir = (rd != tx->tx_rd) ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 	tx->tx_nfrags = nfrags;
 
-	rd->rd_nfrags = kiblnd_dma_map_sg(hdev, tx->tx_frags,
-					  tx->tx_nfrags, tx->tx_dmadir);
-
+	rd->rd_nfrags = kiblnd_dma_map_sg(hdev, tx);
 	for (i = 0, nob = 0; i < rd->rd_nfrags; i++) {
 		rd->rd_frags[i].rf_nob  = kiblnd_sg_dma_len(
 			hdev->ibh_ibdev, &tx->tx_frags[i]);
@@ -1076,7 +1073,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		int prev = dstidx;
 
 		if (srcidx >= srcrd->rd_nfrags) {
-			CERROR("Src buffer exhausted: %d frags\n", srcidx);
+			CERROR("Src buffer exhausted: %d frags %px\n",
+			       srcidx, tx);
 			rc = -EPROTO;
 			break;
 		}
@@ -1540,10 +1538,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
+	struct lnet_libmd *msg_md = lntmsg->msg_md;
 	struct iov_iter from;
 	struct kib_msg *ibmsg;
 	struct kib_rdma_desc *rd;
 	struct kib_tx *tx;
+	bool gpu;
 	int nob;
 	int rc;
 
@@ -1571,6 +1571,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		return -ENOMEM;
 	}
 	ibmsg = tx->tx_msg;
+	gpu = msg_md ? (msg_md->md_flags & LNET_MD_FLAG_GPU) : false;
 
 	switch (type) {
 	default:
@@ -1586,11 +1587,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			break;		/* send IMMEDIATE */
 
 		/* is the REPLY message too small for RDMA? */
-		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[lntmsg->msg_md->md_length]);
-		if (nob <= IBLND_MSG_SIZE && !lntmsg->msg_rdma_force)
+		nob = offsetof(struct kib_msg,
+			       ibm_u.immediate.ibim_payload[lntmsg->msg_md->md_length]);
+		if (nob <= IBLND_MSG_SIZE && !gpu)
 			break;		/* send IMMEDIATE */
 
 		rd = &ibmsg->ibm_u.get.ibgm_rd;
+		tx->tx_gpu = gpu;
 		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
 					  payload_niov, payload_kiov,
 					  payload_offset, payload_nob);
@@ -1626,9 +1629,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case LNET_MSG_PUT:
 		/* Is the payload small enough not to need RDMA? */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[payload_nob]);
-		if (nob <= IBLND_MSG_SIZE && !lntmsg->msg_rdma_force)
+		if (nob <= IBLND_MSG_SIZE && !gpu)
 			break;			/* send IMMEDIATE */
 
+		tx->tx_gpu = gpu;
+
 		rc = kiblnd_setup_rd_kiov(ni, tx, tx->tx_rd,
 					  payload_niov, payload_kiov,
 					  payload_offset, payload_nob);
@@ -1712,6 +1717,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct bio_vec *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
 	unsigned int nob = lntmsg->msg_len;
+	struct lnet_libmd *payload_md = lntmsg->msg_md;
 	struct kib_tx *tx;
 	int rc;
 
@@ -1722,6 +1728,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		goto failed_0;
 	}
 
+	tx->tx_gpu = !!(payload_md->md_flags & LNET_MD_FLAG_GPU);
 	if (!nob)
 		rc = 0;
 	else
@@ -1784,7 +1791,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct kib_tx *tx;
 	int nob;
 	int post_credit = IBLND_POSTRX_PEER_CREDIT;
-	u64 ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
+	u64 ibprm_cookie;
 	int rc = 0;
 
 	LASSERT(iov_iter_count(to) <= rlen);
@@ -1819,6 +1826,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case IBLND_MSG_PUT_REQ: {
 		struct kib_msg *txmsg;
 		struct kib_rdma_desc *rd;
+		struct lnet_libmd *payload_md = lntmsg->msg_md;
+
+		ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
 
 		if (!iov_iter_count(to)) {
 			lnet_finalize(lntmsg, 0);
@@ -1836,6 +1846,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			break;
 		}
 
+		tx->tx_gpu = !!(payload_md->md_flags & LNET_MD_FLAG_GPU);
 		txmsg = tx->tx_msg;
 		rd = &txmsg->ibm_u.putack.ibpam_rd;
 		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index affa921..05fb666 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -192,6 +192,9 @@ struct page *
 	lmd->md_flags = (unlink == LNET_UNLINK) ? LNET_MD_FLAG_AUTO_UNLINK : 0;
 	lmd->md_bulk_handle = umd->bulk_handle;
 
+	if (umd->options & LNET_MD_GPU_ADDR)
+		lmd->md_flags |= LNET_MD_FLAG_GPU;
+
 	if (umd->options & LNET_MD_KIOV) {
 		niov = umd->length;
 		lmd->md_niov = umd->length;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 0c5bf82..53e953f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1450,11 +1450,13 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	u32 best_sel_prio;
 	unsigned int best_dev_prio;
 	unsigned int dev_idx = UINT_MAX;
-	struct page *page = lnet_get_first_page(md, offset);
+	bool gpu = md ? (md->md_flags & LNET_MD_FLAG_GPU) : false;
+
+	if (gpu) {
+		struct page *page = lnet_get_first_page(md, offset);
 
-	msg->msg_rdma_force = lnet_is_rdma_only_page(page);
-	if (msg->msg_rdma_force)
 		dev_idx = lnet_get_dev_idx(page);
+	}
 
 	/* If there is no peer_ni that we can send to on this network,
 	 * then there is no point in looking for a new best_ni here.
@@ -1505,7 +1507,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * All distances smaller than the NUMA range
 		 * are treated equally.
 		 */
-		if (distance < lnet_numa_range)
+		if (!gpu && distance < lnet_numa_range)
 			distance = lnet_numa_range;
 
 		/* * Select on health, selection policy, direct dma prio,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
