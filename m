From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:19 -0500
Subject: [lustre-devel] [PATCH 03/12] lustre: lnd: test fpo_fmr_pool pointer
 instead of special bool
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For the ko2iblnd driver it sets a fpo_is_fmr bool to tell use if
a pool was allocated. The name fpo_is_fmr is very misleading to
its function and its a weak test to tell us if a pool was allocated
in the FMR case. It is much easier to test the actually FMR pool
pointer then manually setting a bool flag to tell us if the FMR
pool is valide.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11152
Reviewed-on: https://review.whamcloud.com/33408
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 12 ++++--------
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h |  1 -
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 281004a..5394c1a 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1356,9 +1356,8 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 {
 	LASSERT(!fpo->fpo_map_count);
 
-	if (fpo->fpo_is_fmr) {
-		if (fpo->fmr.fpo_fmr_pool)
-			ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
+	if (!IS_ERR_OR_NULL(fpo->fmr.fpo_fmr_pool)) {
+		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
 	} else {
 		struct kib_fast_reg_descriptor *frd;
 		int i = 0;
@@ -1435,7 +1434,6 @@ static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_poo
 		else
 			CERROR("FMRs are not supported\n");
 	}
-	fpo->fpo_is_fmr = true;
 
 	return rc;
 }
@@ -1447,8 +1445,6 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
 	struct kib_fast_reg_descriptor *frd;
 	int i, rc;
 
-	fpo->fpo_is_fmr = false;
-
 	INIT_LIST_HEAD(&fpo->fast_reg.fpo_pool_list);
 	fpo->fast_reg.fpo_pool_size = 0;
 	for (i = 0; i < fps->fps_pool_size; i++) {
@@ -1646,7 +1642,7 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 		return;
 
 	fps = fpo->fpo_owner;
-	if (fpo->fpo_is_fmr) {
+	if (!IS_ERR_OR_NULL(fpo->fmr.fpo_fmr_pool)) {
 		if (fmr->fmr_pfmr) {
 			rc = ib_fmr_pool_unmap(fmr->fmr_pfmr);
 			LASSERT(!rc);
@@ -1708,7 +1704,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 		fpo->fpo_deadline = ktime_get_seconds() + IBLND_POOL_DEADLINE;
 		fpo->fpo_map_count++;
 
-		if (fpo->fpo_is_fmr) {
+		if (!IS_ERR_OR_NULL(fpo->fmr.fpo_fmr_pool)) {
 			struct ib_pool_fmr *pfmr;
 
 			spin_unlock(&fps->fps_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 0994fae..2ddd83b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -288,7 +288,6 @@ struct kib_fmr_pool {
 	time64_t		fpo_deadline;	/* deadline of this pool */
 	int                   fpo_failed;          /* fmr pool is failed */
 	int                   fpo_map_count;       /* # of mapped FMR */
-	bool			fpo_is_fmr;	/* True if FMR pools allocated */
 };
 
 struct kib_fmr {
-- 
1.8.3.1
