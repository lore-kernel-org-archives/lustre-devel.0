From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:53:05 -0400
Subject: [lustre-devel] [PATCH 6/8] staging: lustre: o2iblnd: handle
	unmapping of FMR in kiblnd_fmr_pool_unmap
In-Reply-To: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
References: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462474387-11406-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Move FMR unmapping from kiblnd_unmap_tx() to the function
kiblnd_fmr_pool_unmap() so kiblnd_unmap_tx() can be used
with the Fast Registration API as well.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5783
Reviewed-on: http://review.whamcloud.com/17606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   14 ++++++++++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 +---
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 491bd6c..fc29d5c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1470,13 +1470,20 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 {
 	LIST_HEAD(zombies);
 	kib_fmr_pool_t *fpo = fmr->fmr_pool;
-	kib_fmr_poolset_t *fps = fpo->fpo_owner;
+	kib_fmr_poolset_t *fps;
 	unsigned long now = cfs_time_current();
 	kib_fmr_pool_t *tmp;
 	int rc;
 
-	rc = ib_fmr_pool_unmap(fmr->fmr_pfmr);
-	LASSERT(!rc);
+	if (!fpo)
+		return;
+
+	fps = fpo->fpo_owner;
+	if (fmr->fmr_pfmr) {
+		rc = ib_fmr_pool_unmap(fmr->fmr_pfmr);
+		LASSERT(!rc);
+		fmr->fmr_pfmr = NULL;
+	}
 
 	if (status) {
 		rc = ib_flush_fmr_pool(fpo->fmr.fpo_fmr_pool);
@@ -1484,7 +1491,6 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 	}
 
 	fmr->fmr_pool = NULL;
-	fmr->fmr_pfmr = NULL;
 
 	spin_lock(&fps->fps_lock);
 	fpo->fpo_map_count--;  /* decref the pool */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b243f1f..7d1c750 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -613,10 +613,8 @@ static void kiblnd_unmap_tx(lnet_ni_t *ni, kib_tx_t *tx)
 
 	LASSERT(net);
 
-	if (net->ibn_fmr_ps && tx->fmr.fmr_pfmr) {
+	if (net->ibn_fmr_ps)
 		kiblnd_fmr_pool_unmap(&tx->fmr, tx->tx_status);
-		tx->fmr.fmr_pfmr = NULL;
-	}
 
 	if (tx->tx_nfrags) {
 		kiblnd_dma_unmap_sg(tx->tx_pool->tpo_hdev->ibh_ibdev,
-- 
1.7.1
