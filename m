From: James Simmons <jsimmons@infradead.org>
Date: Mon,  9 May 2016 10:53:48 -0400
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: ko2iblnd: fix memory
	corruption with fragments
In-Reply-To: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
References: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462805628-23403-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

In my test of the upstream client this change exposed a long
standing issues where we have a offset that is not page algined
would causes us to access memory beyond the scatter gather list
which was causing memory corruption when all 256 fragments were
in use.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    9 +++++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 ++++++++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index bc179a2..8a18384 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2020,8 +2020,8 @@ static void kiblnd_destroy_tx_pool(kib_pool_t *pool)
 				    sizeof(*tx->tx_pages));
 		if (tx->tx_frags)
 			LIBCFS_FREE(tx->tx_frags,
-				    IBLND_MAX_RDMA_FRAGS *
-					    sizeof(*tx->tx_frags));
+				    (1 + IBLND_MAX_RDMA_FRAGS) *
+				     sizeof(*tx->tx_frags));
 		if (tx->tx_wrq)
 			LIBCFS_FREE(tx->tx_wrq,
 				    (1 + IBLND_MAX_RDMA_FRAGS) *
@@ -2099,11 +2099,12 @@ static int kiblnd_create_tx_pool(kib_poolset_t *ps, int size,
 		}
 
 		LIBCFS_CPT_ALLOC(tx->tx_frags, lnet_cpt_table(), ps->ps_cpt,
-				 IBLND_MAX_RDMA_FRAGS * sizeof(*tx->tx_frags));
+				 (1 + IBLND_MAX_RDMA_FRAGS) *
+				 sizeof(*tx->tx_frags));
 		if (!tx->tx_frags)
 			break;
 
-		sg_init_table(tx->tx_frags, IBLND_MAX_RDMA_FRAGS);
+		sg_init_table(tx->tx_frags, IBLND_MAX_RDMA_FRAGS + 1);
 
 		LIBCFS_CPT_ALLOC(tx->tx_wrq, lnet_cpt_table(), ps->ps_cpt,
 				 (1 + IBLND_MAX_RDMA_FRAGS) *
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index bbfee53..0f7e3a1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -689,6 +689,10 @@ kiblnd_setup_rd_iov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 
 		sg_set_page(sg, page, fragnob, page_offset);
 		sg = sg_next(sg);
+		if (!sg) {
+			CERROR("lacking enough sg entries to map tx\n");
+			return -EFAULT;
+		}
 
 		if (offset + fragnob < iov->iov_len) {
 			offset += fragnob;
@@ -733,6 +737,10 @@ kiblnd_setup_rd_kiov(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 		sg_set_page(sg, kiov->kiov_page, fragnob,
 			    kiov->kiov_offset + offset);
 		sg = sg_next(sg);
+		if (!sg) {
+			CERROR("lacking enough sg entries to map tx\n");
+			return -EFAULT;
+		}
 
 		offset = 0;
 		kiov++;
-- 
1.7.1
