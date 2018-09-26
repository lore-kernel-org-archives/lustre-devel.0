From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:17 -0400
Subject: [lustre-devel] [PATCH 25/25] lustre: ko2iblnd: allow for
 discontiguous fragments
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <john.hammond@intel.com>

In the IOVEC case the buffers passed to the LND may not span
complete pages, therefore the RDMA descriptor needs to describe
all the buffers.  Moreover for the FMR case, the addresses that get
set in the RDMA descriptor need to be relative addresses. This
issue was exposed after ko2iblnd was changed to handle the
removal of ib_get_dma_mr()

Fastreg still expects only one fragment with the total nob.
Otherwise there is a dump_cqe error from MLX5

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9983
Reviewed-on: https://review.whamcloud.com/29290
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index f2a01eb..b16153f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -541,6 +541,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	bool is_fastreg = 0;
 	int cpt;
 	int rc;
+	int i;
 
 	LASSERT(tx->tx_pool);
 	LASSERT(tx->tx_pool->tpo_pool.po_owner);
@@ -560,10 +561,15 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	 * who will need the rkey
 	 */
 	rd->rd_key = tx->fmr.fmr_key;
-	if (!is_fastreg)
-		rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
-	rd->rd_frags[0].rf_nob = nob;
-	rd->rd_nfrags = 1;
+	if (!is_fastreg) {
+		for (i = 0; i < rd->rd_nfrags; i++) {
+			rd->rd_frags[i].rf_addr &= ~hdev->ibh_page_mask;
+			rd->rd_frags[i].rf_addr += i << hdev->ibh_page_shift;
+		}
+	} else {
+		rd->rd_frags[0].rf_nob = nob;
+		rd->rd_nfrags = 1;
+	}
 
 	return 0;
 }
-- 
1.8.3.1
