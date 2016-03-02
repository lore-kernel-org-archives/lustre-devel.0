From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:03 -0500
Subject: [lustre-devel] [PATCH 20/27] staging: lustre: change ibh_mrs from
	array to pointer
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

With the removal of PMR we no longer require ibh_mrs field
to be a array so change it to a simple pointer.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6850
Reviewed-on: http://review.whamcloud.com/15788
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   95 ++------------------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    5 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   10 +--
 3 files changed, 13 insertions(+), 97 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index c1ca8dc..1dc18d7 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1296,55 +1296,15 @@ static void kiblnd_map_tx_pool(kib_tx_pool_t *tpo)
 	}
 }
 
-struct ib_mr *kiblnd_find_dma_mr(kib_hca_dev_t *hdev, __u64 addr, __u64 size)
-{
-	__u64 index;
-
-	LASSERT(hdev->ibh_mrs[0]);
-
-	if (hdev->ibh_nmrs == 1)
-		return hdev->ibh_mrs[0];
-
-	index = addr >> hdev->ibh_mr_shift;
-
-	if (index <  hdev->ibh_nmrs &&
-	    index == ((addr + size - 1) >> hdev->ibh_mr_shift))
-		return hdev->ibh_mrs[index];
-
-	return NULL;
-}
-
 struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd)
 {
-	struct ib_mr *prev_mr;
-	struct ib_mr *mr;
-	int i;
-
-	LASSERT(hdev->ibh_mrs[0]);
+	LASSERT(hdev->ibh_mrs);
 
 	if (*kiblnd_tunables.kib_map_on_demand > 0 &&
 	    *kiblnd_tunables.kib_map_on_demand <= rd->rd_nfrags)
 		return NULL;
 
-	if (hdev->ibh_nmrs == 1)
-		return hdev->ibh_mrs[0];
-
-	for (i = 0, mr = prev_mr = NULL;
-	     i < rd->rd_nfrags; i++) {
-		mr = kiblnd_find_dma_mr(hdev,
-					rd->rd_frags[i].rf_addr,
-					rd->rd_frags[i].rf_nob);
-		if (!prev_mr)
-			prev_mr = mr;
-
-		if (!mr || prev_mr != mr) {
-			/* Can't covered by one single MR */
-			mr = NULL;
-			break;
-		}
-	}
-
-	return mr;
+	return hdev->ibh_mrs;
 }
 
 static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *pool)
@@ -1978,8 +1938,7 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 	int i;
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
-	if (!*kiblnd_tunables.kib_map_on_demand &&
-	    net->ibn_dev->ibd_hdev->ibh_nmrs == 1) {
+	if (!*kiblnd_tunables.kib_map_on_demand) {
 		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 		goto create_tx_pool;
 	}
@@ -2019,26 +1978,15 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 		rc = kiblnd_init_fmr_poolset(net->ibn_fmr_ps[cpt], cpt, net,
 					     kiblnd_fmr_pool_size(ncpts),
 					     kiblnd_fmr_flush_trigger(ncpts));
-		if (rc == -ENOSYS && !i) /* no FMR */
-			break;
-
-		if (rc) { /* a real error */
+		if (rc) {
 			CERROR("Can't initialize FMR pool for CPT %d: %d\n",
 			       cpt, rc);
 			goto failed;
 		}
 	}
 
-	if (i > 0) {
+	if (i > 0)
 		LASSERT(i == ncpts);
-		goto create_tx_pool;
-	}
-
-	cfs_percpt_free(net->ibn_fmr_ps);
-	net->ibn_fmr_ps = NULL;
-
-	CWARN("Device does not support FMR\n");
-			goto failed;
 
  create_tx_pool:
 	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
@@ -2087,34 +2035,18 @@ static int kiblnd_hdev_get_attr(kib_hca_dev_t *hdev)
 		return 0;
 	}
 
-	for (hdev->ibh_mr_shift = 0;
-	     hdev->ibh_mr_shift < 64; hdev->ibh_mr_shift++) {
-		if (hdev->ibh_mr_size == (1ULL << hdev->ibh_mr_shift) ||
-		    hdev->ibh_mr_size == (1ULL << hdev->ibh_mr_shift) - 1)
-			return 0;
-	}
-
 	CERROR("Invalid mr size: %#llx\n", hdev->ibh_mr_size);
 	return -EINVAL;
 }
 
 static void kiblnd_hdev_cleanup_mrs(kib_hca_dev_t *hdev)
 {
-	int i;
-
-	if (!hdev->ibh_nmrs || !hdev->ibh_mrs)
+	if (!hdev->ibh_mrs)
 		return;
 
-	for (i = 0; i < hdev->ibh_nmrs; i++) {
-		if (!hdev->ibh_mrs[i])
-			break;
-
-		ib_dereg_mr(hdev->ibh_mrs[i]);
-	}
+	ib_dereg_mr(hdev->ibh_mrs);
 
-	LIBCFS_FREE(hdev->ibh_mrs, sizeof(*hdev->ibh_mrs) * hdev->ibh_nmrs);
-	hdev->ibh_mrs  = NULL;
-	hdev->ibh_nmrs = 0;
+	hdev->ibh_mrs = NULL;
 }
 
 void kiblnd_hdev_destroy(kib_hca_dev_t *hdev)
@@ -2140,15 +2072,6 @@ static int kiblnd_hdev_setup_mrs(kib_hca_dev_t *hdev)
 	if (rc)
 		return rc;
 
-	LIBCFS_ALLOC(hdev->ibh_mrs, 1 * sizeof(*hdev->ibh_mrs));
-	if (!hdev->ibh_mrs) {
-		CERROR("Failed to allocate MRs table\n");
-		return -ENOMEM;
-	}
-
-	hdev->ibh_mrs[0] = NULL;
-	hdev->ibh_nmrs   = 1;
-
 	mr = ib_get_dma_mr(hdev->ibh_pd, acflags);
 	if (IS_ERR(mr)) {
 		CERROR("Failed ib_get_dma_mr : %ld\n", PTR_ERR(mr));
@@ -2156,7 +2079,7 @@ static int kiblnd_hdev_setup_mrs(kib_hca_dev_t *hdev)
 		return PTR_ERR(mr);
 	}
 
-	hdev->ibh_mrs[0] = mr;
+	hdev->ibh_mrs = mr;
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 4fe38cb..0c88e8b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -209,8 +209,7 @@ typedef struct kib_hca_dev {
 	__u64              ibh_page_mask;       /* page mask of current HCA */
 	int                ibh_mr_shift;        /* bits shift of max MR size */
 	__u64              ibh_mr_size;         /* size of MR */
-	int                ibh_nmrs;            /* # of global MRs */
-	struct ib_mr       **ibh_mrs;           /* global MR */
+	struct ib_mr	   *ibh_mrs;		/* global MR */
 	struct ib_pd       *ibh_pd;             /* PD */
 	kib_dev_t          *ibh_dev;            /* owner */
 	atomic_t           ibh_ref;             /* refcount */
@@ -909,8 +908,6 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 
 struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev,
 				    kib_rdma_desc_t *rd);
-struct ib_mr *kiblnd_find_dma_mr(kib_hca_dev_t *hdev,
-				 __u64 addr, __u64 size);
 void kiblnd_map_rx_descs(kib_conn_t *conn);
 void kiblnd_unmap_rx_descs(kib_conn_t *conn);
 void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 11c0b49..fc788b0 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -158,7 +158,7 @@ kiblnd_post_rx(kib_rx_t *rx, int credit)
 	kib_conn_t *conn = rx->rx_conn;
 	kib_net_t *net = conn->ibc_peer->ibp_ni->ni_data;
 	struct ib_recv_wr *bad_wrq = NULL;
-	struct ib_mr *mr;
+	struct ib_mr *mr = conn->ibc_hdev->ibh_mrs;
 	int rc;
 
 	LASSERT(net);
@@ -166,8 +166,6 @@ kiblnd_post_rx(kib_rx_t *rx, int credit)
 	LASSERT(credit == IBLND_POSTRX_NO_CREDIT ||
 		credit == IBLND_POSTRX_PEER_CREDIT ||
 		credit == IBLND_POSTRX_RSRVD_CREDIT);
-
-	mr = kiblnd_find_dma_mr(conn->ibc_hdev, rx->rx_msgaddr, IBLND_MSG_SIZE);
 	LASSERT(mr);
 
 	rx->rx_sge.lkey   = mr->lkey;
@@ -1035,17 +1033,15 @@ kiblnd_init_tx_msg(lnet_ni_t *ni, kib_tx_t *tx, int type, int body_nob)
 	struct ib_sge *sge = &tx->tx_sge[tx->tx_nwrq];
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[tx->tx_nwrq];
 	int nob = offsetof(kib_msg_t, ibm_u) + body_nob;
-	struct ib_mr *mr;
+	struct ib_mr *mr = hdev->ibh_mrs;
 
 	LASSERT(tx->tx_nwrq >= 0);
 	LASSERT(tx->tx_nwrq < IBLND_MAX_RDMA_FRAGS + 1);
 	LASSERT(nob <= IBLND_MSG_SIZE);
+	LASSERT(mr);
 
 	kiblnd_init_msg(tx->tx_msg, type, body_nob);
 
-	mr = kiblnd_find_dma_mr(hdev, tx->tx_msgaddr, nob);
-	LASSERT(mr);
-
 	sge->lkey   = mr->lkey;
 	sge->addr   = tx->tx_msgaddr;
 	sge->length = nob;
-- 
1.7.1
