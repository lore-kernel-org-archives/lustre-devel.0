From: Doug Oucharek <doug.s.oucharek@intel.com>
Date: Sat, 11 Feb 2017 22:56:29 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: ko2iblnd: Adapt to the
	removal of ib_get_dma_mr()
Message-ID: <1486882589-648-1-git-send-email-doug.s.oucharek@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <doug.s.oucharek@intel.com>

In Linux kernel 4.9-rc1, the function ib_get_dma_mr()
was removed and a second parameter was added to ib_alloc_pd().
As this broke the building of the ko2iblnd module in
staging, the Kconfig for LNet has marked ko2iblnd as broken
and stopped building it.

This patch fixes this breakage by:

- Removing the BROKEN tag from lnet/Kconfig.
- Make it so the module parameter map_on_demand can no longer be
  zero (we have to configure FMR/FastReg pools; it can no longer be
  off).
- No longer try to use the global DMA memory region, but make use
  of the FMR/FastReg pool for all RDMA Tx operations.
- Everywhere we are using the device DMA mr to derive the
  L-key for non-registered memory regions, use the
  pd->local_dma_lkey value instead.
- Make the default map_on_demand = 256.  This will allow nodes with
  this patch to still connected to older nodes without this patch
  and FMR/FastReg turned off.  When FMR/FastReg is turned off, we
  use 256 as the max frags so the two sides will still be able to
  communicate and work.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9026
---
 drivers/staging/lustre/lnet/Kconfig                |  1 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 69 +---------------------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  3 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 17 +-----
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  | 12 ++--
 5 files changed, 12 insertions(+), 90 deletions(-)

diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index 13b4327..2b59301 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -35,7 +35,6 @@ config LNET_SELFTEST
 config LNET_XPRT_IB
 	tristate "LNET infiniband support"
 	depends on LNET && INFINIBAND && INFINIBAND_ADDR_TRANS
-	depends on BROKEN
 	default LNET && INFINIBAND
 	help
 	  This option allows the LNET users to use infiniband as an
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index b1e8508..d39ba14 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1281,27 +1281,6 @@ static void kiblnd_map_tx_pool(struct kib_tx_pool *tpo)
 	}
 }
 
-struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, struct kib_rdma_desc *rd,
-				    int negotiated_nfrags)
-{
-	struct kib_net *net = ni->ni_data;
-	struct kib_hca_dev *hdev = net->ibn_dev->ibd_hdev;
-	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
-	__u16 nfrags;
-	int mod;
-
-	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
-	mod = tunables->lnd_map_on_demand;
-	nfrags = (negotiated_nfrags != -1) ? negotiated_nfrags : mod;
-
-	LASSERT(hdev->ibh_mrs);
-
-	if (mod > 0 && nfrags <= rd->rd_nfrags)
-		return NULL;
-
-	return hdev->ibh_mrs;
-}
-
 static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 {
 	LASSERT(!fpo->fpo_map_count);
@@ -2168,21 +2147,12 @@ static int kiblnd_net_init_pools(struct kib_net *net, lnet_ni_t *ni, __u32 *cpts
 				 int ncpts)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
-	unsigned long flags;
 	int cpt;
 	int rc;
 	int i;
 
 	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
 
-	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
-	if (!tunables->lnd_map_on_demand) {
-		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
-		goto create_tx_pool;
-	}
-
-	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
-
 	if (tunables->lnd_fmr_pool_size < *kiblnd_tunables.kib_ntx / 4) {
 		CERROR("Can't set fmr pool size (%d) < ntx / 4(%d)\n",
 		       tunables->lnd_fmr_pool_size,
@@ -2227,7 +2197,6 @@ static int kiblnd_net_init_pools(struct kib_net *net, lnet_ni_t *ni, __u32 *cpts
 	if (i > 0)
 		LASSERT(i == ncpts);
 
- create_tx_pool:
 	/*
 	 * cfs_precpt_alloc is creating an array of struct kib_tx_poolset
 	 * The number of struct kib_tx_poolsets create is equal to the
@@ -2283,20 +2252,8 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	return -EINVAL;
 }
 
-static void kiblnd_hdev_cleanup_mrs(struct kib_hca_dev *hdev)
-{
-	if (!hdev->ibh_mrs)
-		return;
-
-	ib_dereg_mr(hdev->ibh_mrs);
-
-	hdev->ibh_mrs = NULL;
-}
-
 void kiblnd_hdev_destroy(struct kib_hca_dev *hdev)
 {
-	kiblnd_hdev_cleanup_mrs(hdev);
-
 	if (hdev->ibh_pd)
 		ib_dealloc_pd(hdev->ibh_pd);
 
@@ -2306,28 +2263,6 @@ void kiblnd_hdev_destroy(struct kib_hca_dev *hdev)
 	LIBCFS_FREE(hdev, sizeof(*hdev));
 }
 
-static int kiblnd_hdev_setup_mrs(struct kib_hca_dev *hdev)
-{
-	struct ib_mr *mr;
-	int rc;
-	int acflags = IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
-
-	rc = kiblnd_hdev_get_attr(hdev);
-	if (rc)
-		return rc;
-
-	mr = ib_get_dma_mr(hdev->ibh_pd, acflags);
-	if (IS_ERR(mr)) {
-		CERROR("Failed ib_get_dma_mr : %ld\n", PTR_ERR(mr));
-		kiblnd_hdev_cleanup_mrs(hdev);
-		return PTR_ERR(mr);
-	}
-
-	hdev->ibh_mrs = mr;
-
-	return 0;
-}
-
 /* DUMMY */
 static int kiblnd_dummy_callback(struct rdma_cm_id *cmid,
 				 struct rdma_cm_event *event)
@@ -2482,9 +2417,9 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 		goto out;
 	}
 
-	rc = kiblnd_hdev_setup_mrs(hdev);
+	rc = kiblnd_hdev_get_attr(hdev);
 	if (rc) {
-		CERROR("Can't setup device: %d\n", rc);
+		CERROR("Can't get device attributes: %d\n", rc);
 		goto out;
 	}
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 2cb4298..366372d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -172,7 +172,6 @@ struct kib_hca_dev {
 	__u64              ibh_page_mask;       /* page mask of current HCA */
 	int                ibh_mr_shift;        /* bits shift of max MR size */
 	__u64              ibh_mr_size;         /* size of MR */
-	struct ib_mr	   *ibh_mrs;		/* global MR */
 	struct ib_pd       *ibh_pd;             /* PD */
 	struct kib_dev	   *ibh_dev;		/* owner */
 	atomic_t           ibh_ref;             /* refcount */
@@ -978,8 +977,6 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 #define KIBLND_CONN_PARAM(e)     ((e)->param.conn.private_data)
 #define KIBLND_CONN_PARAM_LEN(e) ((e)->param.conn.private_data_len)
 
-struct ib_mr *kiblnd_find_rd_dma_mr(struct lnet_ni *ni, struct kib_rdma_desc *rd,
-				    int negotiated_nfrags);
 void kiblnd_map_rx_descs(struct kib_conn *conn);
 void kiblnd_unmap_rx_descs(struct kib_conn *conn);
 void kiblnd_pool_free_node(struct kib_pool *pool, struct list_head *node);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index e2f3f72..6eaa548 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -157,7 +157,6 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	struct kib_conn *conn = rx->rx_conn;
 	struct kib_net *net = conn->ibc_peer->ibp_ni->ni_data;
 	struct ib_recv_wr *bad_wrq = NULL;
-	struct ib_mr *mr = conn->ibc_hdev->ibh_mrs;
 	int rc;
 
 	LASSERT(net);
@@ -165,9 +164,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	LASSERT(credit == IBLND_POSTRX_NO_CREDIT ||
 		credit == IBLND_POSTRX_PEER_CREDIT ||
 		credit == IBLND_POSTRX_RSRVD_CREDIT);
-	LASSERT(mr);
 
-	rx->rx_sge.lkey   = mr->lkey;
+	rx->rx_sge.lkey   = conn->ibc_hdev->ibh_pd->local_dma_lkey;
 	rx->rx_sge.addr   = rx->rx_msgaddr;
 	rx->rx_sge.length = IBLND_MSG_SIZE;
 
@@ -613,7 +611,6 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 {
 	struct kib_net *net = ni->ni_data;
 	struct kib_hca_dev *hdev = net->ibn_dev->ibd_hdev;
-	struct ib_mr *mr    = NULL;
 	__u32 nob;
 	int i;
 
@@ -635,14 +632,6 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 		nob += rd->rd_frags[i].rf_nob;
 	}
 
-	mr = kiblnd_find_rd_dma_mr(ni, rd, tx->tx_conn ?
-				   tx->tx_conn->ibc_max_frags : -1);
-	if (mr) {
-		/* found pre-mapping MR */
-		rd->rd_key = (rd != tx->tx_rd) ? mr->rkey : mr->lkey;
-		return 0;
-	}
-
 	if (net->ibn_fmr_ps)
 		return kiblnd_fmr_map_tx(net, tx, rd, nob);
 
@@ -1028,16 +1017,14 @@ static int kiblnd_map_tx(lnet_ni_t *ni, struct kib_tx *tx, struct kib_rdma_desc
 	struct ib_sge *sge = &tx->tx_sge[tx->tx_nwrq];
 	struct ib_rdma_wr *wrq = &tx->tx_wrq[tx->tx_nwrq];
 	int nob = offsetof(struct kib_msg, ibm_u) + body_nob;
-	struct ib_mr *mr = hdev->ibh_mrs;
 
 	LASSERT(tx->tx_nwrq >= 0);
 	LASSERT(tx->tx_nwrq < IBLND_MAX_RDMA_FRAGS + 1);
 	LASSERT(nob <= IBLND_MSG_SIZE);
-	LASSERT(mr);
 
 	kiblnd_init_msg(tx->tx_msg, type, body_nob);
 
-	sge->lkey   = mr->lkey;
+	sge->lkey   = hdev->ibh_pd->local_dma_lkey;
 	sge->addr   = tx->tx_msgaddr;
 	sge->length = nob;
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 44e960f..3c81b527 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -106,7 +106,8 @@
 module_param(concurrent_sends, int, 0444);
 MODULE_PARM_DESC(concurrent_sends, "send work-queue sizing");
 
-static int map_on_demand;
+#define IBLND_DEFAULT_MAP_ON_DEMAND IBLND_MAX_RDMA_FRAGS
+static int map_on_demand = IBLND_DEFAULT_MAP_ON_DEMAND;
 module_param(map_on_demand, int, 0444);
 MODULE_PARM_DESC(map_on_demand, "map on demand");
 
@@ -228,10 +229,13 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	if (tunables->lnd_peercredits_hiw >= ni->ni_peertxcredits)
 		tunables->lnd_peercredits_hiw = ni->ni_peertxcredits - 1;
 
-	if (tunables->lnd_map_on_demand < 0 ||
+	if (tunables->lnd_map_on_demand <= 0 ||
 	    tunables->lnd_map_on_demand > IBLND_MAX_RDMA_FRAGS) {
-		/* disable map-on-demand */
-		tunables->lnd_map_on_demand = 0;
+		/* Use the default */
+		CWARN("Invalid map_on_demand (%d), expects 1 - %d. Using default of %d\n",
+		      tunables->lnd_map_on_demand,
+		      IBLND_MAX_RDMA_FRAGS, IBLND_DEFAULT_MAP_ON_DEMAND);
+		tunables->lnd_map_on_demand = IBLND_DEFAULT_MAP_ON_DEMAND;
 	}
 
 	if (tunables->lnd_map_on_demand == 1) {
-- 
1.8.3.1
