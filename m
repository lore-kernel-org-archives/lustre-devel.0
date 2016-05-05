From: James Simmons <jsimmons@infradead.org>
Date: Thu,  5 May 2016 14:53:02 -0400
Subject: [lustre-devel] [PATCH 3/8] staging: lustre: o2iblnd: create union
	to contain FMR
In-Reply-To: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
References: <1462474387-11406-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462474387-11406-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Create an union to contain the FMR pool structure. This is
for the preparation of adding handling Fast Registeration
support.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5783
Reviewed-on: http://review.whamcloud.com/17606
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   14 +++++++-------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    8 ++++++--
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 4a4b68c..26d8a11 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1302,8 +1302,8 @@ static void kiblnd_destroy_fmr_pool(kib_fmr_pool_t *fpo)
 {
 	LASSERT(!fpo->fpo_map_count);
 
-	if (fpo->fpo_fmr_pool)
-		ib_destroy_fmr_pool(fpo->fpo_fmr_pool);
+	if (fpo->fmr.fpo_fmr_pool)
+		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
 
 	if (fpo->fpo_hdev)
 		kiblnd_hdev_decref(fpo->fpo_hdev);
@@ -1359,9 +1359,9 @@ static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
 
 	fpo->fpo_hdev = kiblnd_current_hdev(dev);
 
-	fpo->fpo_fmr_pool = ib_create_fmr_pool(fpo->fpo_hdev->ibh_pd, &param);
-	if (IS_ERR(fpo->fpo_fmr_pool)) {
-		rc = PTR_ERR(fpo->fpo_fmr_pool);
+	fpo->fmr.fpo_fmr_pool = ib_create_fmr_pool(fpo->fpo_hdev->ibh_pd, &param);
+	if (IS_ERR(fpo->fmr.fpo_fmr_pool)) {
+		rc = PTR_ERR(fpo->fmr.fpo_fmr_pool);
 		CERROR("Failed to create FMR pool: %d\n", rc);
 
 		kiblnd_hdev_decref(fpo->fpo_hdev);
@@ -1452,7 +1452,7 @@ void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status)
 	LASSERT(!rc);
 
 	if (status) {
-		rc = ib_flush_fmr_pool(fpo->fpo_fmr_pool);
+		rc = ib_flush_fmr_pool(fpo->fmr.fpo_fmr_pool);
 		LASSERT(!rc);
 	}
 
@@ -1494,7 +1494,7 @@ int kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages, int npages,
 		fpo->fpo_map_count++;
 		spin_unlock(&fps->fps_lock);
 
-		pfmr = ib_fmr_pool_map_phys(fpo->fpo_fmr_pool,
+		pfmr = ib_fmr_pool_map_phys(fpo->fmr.fpo_fmr_pool,
 					    pages, npages, iov);
 		if (likely(!IS_ERR(pfmr))) {
 			fmr->fmr_pool = fpo;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index bfcbdd1..0120170 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -295,15 +295,19 @@ typedef struct {
 	struct list_head      fpo_list;            /* chain on pool list */
 	struct kib_hca_dev    *fpo_hdev;           /* device for this pool */
 	kib_fmr_poolset_t     *fpo_owner;          /* owner of this pool */
-	struct ib_fmr_pool    *fpo_fmr_pool;       /* IB FMR pool */
+	union {
+		struct {
+			struct ib_fmr_pool *fpo_fmr_pool; /* IB FMR pool */
+		} fmr;
+	};
 	unsigned long         fpo_deadline;        /* deadline of this pool */
 	int                   fpo_failed;          /* fmr pool is failed */
 	int                   fpo_map_count;       /* # of mapped FMR */
 } kib_fmr_pool_t;
 
 typedef struct {
-	struct ib_pool_fmr    *fmr_pfmr;           /* IB pool fmr */
 	kib_fmr_pool_t        *fmr_pool;           /* pool of FMR */
+	struct ib_pool_fmr    *fmr_pfmr;           /* IB pool fmr */
 } kib_fmr_t;
 
 typedef struct kib_net {
-- 
1.7.1
