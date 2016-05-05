From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:53:00 -0400
Subject: [lustre-devel] [PATCH 1/8] staging: lustre: o2iblnd: rename
	kib_fmr_pool_t
In-Reply-To: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
References: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462474387-11406-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Rename kib_fmr_pool_t named pool to fpo.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5783
Reviewed-on: http://review.whamcloud.com/17606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   22 ++++++++++----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index e89c2a1..60647bc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1298,27 +1298,27 @@ struct ib_mr *kiblnd_find_rd_dma_mr(kib_hca_dev_t *hdev, kib_rdma_desc_t *rd,
 	return hdev->ibh_mrs;
 }
 
-static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *pool)
+static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *fpo)
 {
-	LASSERT(!pool->fpo_map_count);
+	LASSERT(!fpo->fpo_map_count);
 
-	if (pool->fpo_fmr_pool)
-		ib_destroy_fmr_pool(pool->fpo_fmr_pool);
+	if (fpo->fpo_fmr_pool)
+		ib_destroy_fmr_pool(fpo->fpo_fmr_pool);
 
-	if (pool->fpo_hdev)
-		kiblnd_hdev_decref(pool->fpo_hdev);
+	if (fpo->fpo_hdev)
+		kiblnd_hdev_decref(fpo->fpo_hdev);
 
-	LIBCFS_FREE(pool, sizeof(*pool));
+	LIBCFS_FREE(fpo, sizeof(*fpo));
 }
 
 static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 {
-	kib_fmr_pool_t *pool;
+	kib_fmr_pool_t *fpo;
 
 	while (!list_empty(head)) {
-		pool = list_entry(head->next, kib_fmr_pool_t, fpo_list);
-		list_del(&pool->fpo_list);
-		kiblnd_destroy_fmr_pool(pool);
+		fpo = list_entry(head->next, kib_fmr_pool_t, fpo_list);
+		list_del(&fpo->fpo_list);
+		kiblnd_destroy_fmr_pool(fpo);
 	}
 }
 
-- 
1.7.1
