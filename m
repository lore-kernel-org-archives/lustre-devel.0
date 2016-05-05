From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:53:04 -0400
Subject: [lustre-devel] [PATCH 5/8] staging: lustre: o2iblnd: cache FMR key
	in kib_fmr_t
In-Reply-To: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
References: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462474387-11406-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Move the FMR key handling from kiblnd_fmr_map_tx() to the
function kiblnd_fmr_pool_map(). This will allow the
function kiblnd_fmr_map_tx() to handle keys for both
FMR and Fast Registration.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5783
Reviewed-on: http://review.whamcloud.com/17606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   11 +++++++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    5 +++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 ++++----
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 9c30915..491bd6c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1506,7 +1506,7 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 }
 
 int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
-			__u64 iov, kib_fmr_t *fmr)
+			__u32 nob, __u64 iov, bool is_rx, kib_fmr_t *fmr)
 {
 	struct ib_pool_fmr *pfmr;
 	kib_fmr_pool_t *fpo;
@@ -1524,16 +1524,19 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 		pfmr = ib_fmr_pool_map_phys(fpo->fmr.fpo_fmr_pool,
 					    pages, npages, iov);
 		if (likely(!IS_ERR(pfmr))) {
-			fmr->fmr_pool = fpo;
+			fmr->fmr_key = is_rx ? pfmr->fmr->rkey :
+					       pfmr->fmr->lkey;
 			fmr->fmr_pfmr = pfmr;
+			fmr->fmr_pool = fpo;
 			return 0;
 		}
+		rc = PTR_ERR(pfmr);
 
 		spin_lock(&fps->fps_lock);
 		fpo->fpo_map_count--;
-		if (PTR_ERR(pfmr) != -EAGAIN) {
+		if (rc != -EAGAIN) {
 			spin_unlock(&fps->fps_lock);
-			return PTR_ERR(pfmr);
+			return rc;
 		}
 
 		/* EAGAIN and ... */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 0120170..90c8aa5 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -308,6 +308,7 @@ typedef struct {
 typedef struct {
 	kib_fmr_pool_t        *fmr_pool;           /* pool of FMR */
 	struct ib_pool_fmr    *fmr_pfmr;           /* IB pool fmr */
+	u32		       fmr_key;
 } kib_fmr_t;
 
 typedef struct kib_net {
@@ -959,8 +960,8 @@ void kiblnd_unmap_rx_descs(kib_conn_t *conn);
 void kiblnd_pool_free_node(kib_pool_t *pool, struct list_head *node);
 struct list_head *kiblnd_pool_alloc_node(kib_poolset_t *ps);
 
-int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages,
-			 int npages, __u64 iov, kib_fmr_t *fmr);
+int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
+			 __u32 nob, __u64 iov, bool is_rx, kib_fmr_t *fmr);
 void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
 
 int  kiblnd_tunables_init(void);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index cd3fde7..b243f1f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -561,7 +561,7 @@ kiblnd_kvaddr_to_page(unsigned long vaddr)
 }
 
 static int
-kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, int nob)
+kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, __u32 nob)
 {
 	kib_hca_dev_t *hdev;
 	__u64 *pages = tx->tx_pages;
@@ -588,7 +588,8 @@ kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, int nob)
 	cpt = tx->tx_pool->tpo_pool.po_owner->ps_cpt;
 
 	fps = net->ibn_fmr_ps[cpt];
-	rc = kiblnd_fmr_pool_map(fps, pages, npages, 0, &tx->fmr);
+	rc = kiblnd_fmr_pool_map(fps, pages, npages, nob, 0, (rd != tx->tx_rd),
+				 &tx->fmr);
 	if (rc) {
 		CERROR("Can't map %d pages: %d\n", npages, rc);
 		return rc;
@@ -598,8 +599,7 @@ kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, int nob)
 	 * If rd is not tx_rd, it's going to get sent to a peer, who will need
 	 * the rkey
 	 */
-	rd->rd_key = (rd != tx->tx_rd) ? tx->fmr.fmr_pfmr->fmr->rkey :
-					 tx->fmr.fmr_pfmr->fmr->lkey;
+	rd->rd_key = tx->fmr.fmr_key;
 	rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
 	rd->rd_frags[0].rf_nob = nob;
 	rd->rd_nfrags = 1;
-- 
1.7.1
