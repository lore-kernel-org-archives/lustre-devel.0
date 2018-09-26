From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:14 -0400
Subject: [lustre-devel] [PATCH 22/25] lustre: lnd: Don't Page Align
 remote_addr with FastReg
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Doug Oucharek <dougso@me.com>

Trying to page align the remote_addr for IB_RDMA_WRITE work
requests is triggering "dump_cqe" errors from MOFED 4.x + mlx5.

This patch removes the address masking we were doing with FastReg
which was trying to page align remote_addr values. I am also
removing the setting of "mr->iova" with FastReg as this is being
done in the call to ib_map_mr_sg() and could cause problems.

Signed-off-by: Doug Oucharek <dougso@me.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9500
Reviewed-on: https://review.whamcloud.com/27149
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 6 +++---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 6 ++++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 50c0c00..c207663 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1651,7 +1651,7 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 
 int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
-			struct kib_fmr *fmr)
+			struct kib_fmr *fmr, bool *is_fastreg)
 {
 	__u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
@@ -1671,6 +1671,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		if (fpo->fpo_is_fmr) {
 			struct ib_pool_fmr *pfmr;
 
+			*is_fastreg = 0;
 			spin_unlock(&fps->fps_lock);
 
 			if (!tx_pages_mapped) {
@@ -1690,6 +1691,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			}
 			rc = PTR_ERR(pfmr);
 		} else {
+			*is_fastreg = 1;
 			if (!list_empty(&fpo->fast_reg.fpo_pool_list)) {
 				struct kib_fast_reg_descriptor *frd;
 				struct ib_reg_wr *wr;
@@ -1727,8 +1729,6 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 					return n < 0 ? n : -EINVAL;
 				}
 
-				mr->iova = iov;
-
 				/* Prepare FastReg WR */
 				wr = &frd->frd_fastreg_wr;
 				memset(wr, 0, sizeof(*wr));
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index f21bdee..a4438d2 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -1003,7 +1003,7 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 
 int  kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			 struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
-			 struct kib_fmr *fmr);
+			 struct kib_fmr *fmr, bool *is_fastreg);
 void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status);
 
 int kiblnd_tunables_setup(struct lnet_ni *ni);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index db563c0..346d368 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -538,6 +538,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 {
 	struct kib_hca_dev *hdev;
 	struct kib_fmr_poolset *fps;
+	bool is_fastreg = 0;
 	int cpt;
 	int rc;
 
@@ -548,7 +549,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	cpt = tx->tx_pool->tpo_pool.po_owner->ps_cpt;
 
 	fps = net->ibn_fmr_ps[cpt];
-	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->fmr);
+	rc = kiblnd_fmr_pool_map(fps, tx, rd, nob, 0, &tx->fmr, &is_fastreg);
 	if (rc) {
 		CERROR("Can't map %u bytes: %d\n", nob, rc);
 		return rc;
@@ -559,7 +560,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	 * who will need the rkey
 	 */
 	rd->rd_key = tx->fmr.fmr_key;
-	rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
+	if (!is_fastreg)
+		rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
 	rd->rd_frags[0].rf_nob = nob;
 	rd->rd_nfrags = 1;
 
-- 
1.8.3.1
