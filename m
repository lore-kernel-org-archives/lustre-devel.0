From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:12 -0500
Subject: [lustre-devel] [PATCH 11/14] staging: lustre: ldlm: fix race of
	starting bl threads
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

There is race in the code of starting bl threads which leads to
thread number exceeds the maximum number when race happened, it
can also lead to duplicated thread name. This patch fixes the
race and cleanup the code a bit.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7330
Reviewed-on: http://review.whamcloud.com/17026
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 49 ++++++++++++++-----------
 1 file changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 4c21b9b..6f9d540 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -714,7 +714,6 @@ static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
 
 /* This only contains temporary data until the thread starts */
 struct ldlm_bl_thread_data {
-	char			bltd_name[CFS_CURPROC_COMM_MAX];
 	struct ldlm_bl_pool	*bltd_blp;
 	struct completion	bltd_comp;
 	int			bltd_num;
@@ -722,19 +721,32 @@ struct ldlm_bl_thread_data {
 
 static int ldlm_bl_thread_main(void *arg);
 
-static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp)
+static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp, bool check_busy)
 {
 	struct ldlm_bl_thread_data bltd = { .bltd_blp = blp };
 	struct task_struct *task;
 
 	init_completion(&bltd.bltd_comp);
-	bltd.bltd_num = atomic_read(&blp->blp_num_threads);
-	snprintf(bltd.bltd_name, sizeof(bltd.bltd_name),
-		 "ldlm_bl_%02d", bltd.bltd_num);
-	task = kthread_run(ldlm_bl_thread_main, &bltd, "%s", bltd.bltd_name);
+
+	bltd.bltd_num = atomic_inc_return(&blp->blp_num_threads);
+	if (bltd.bltd_num >= blp->blp_max_threads) {
+		atomic_dec(&blp->blp_num_threads);
+		return 0;
+	}
+
+	LASSERTF(bltd.bltd_num > 0, "thread num:%d\n", bltd.bltd_num);
+	if (check_busy &&
+	    atomic_read(&blp->blp_busy_threads) < (bltd.bltd_num - 1)) {
+		atomic_dec(&blp->blp_num_threads);
+		return 0;
+	}
+
+	task = kthread_run(ldlm_bl_thread_main, &bltd, "ldlm_bl_%02d",
+			   bltd.bltd_num);
 	if (IS_ERR(task)) {
 		CERROR("cannot start LDLM thread ldlm_bl_%02d: rc %ld\n",
-		       atomic_read(&blp->blp_num_threads), PTR_ERR(task));
+		       bltd.bltd_num, PTR_ERR(task));
+		atomic_dec(&blp->blp_num_threads);
 		return PTR_ERR(task);
 	}
 	wait_for_completion(&bltd.bltd_comp);
@@ -746,12 +758,11 @@ static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp)
 static int ldlm_bl_thread_need_create(struct ldlm_bl_pool *blp,
 				      struct ldlm_bl_work_item *blwi)
 {
-	int busy = atomic_read(&blp->blp_busy_threads);
-
-	if (busy >= blp->blp_max_threads)
+	if (atomic_read(&blp->blp_num_threads) >= blp->blp_max_threads)
 		return 0;
 
-	if (busy < atomic_read(&blp->blp_num_threads))
+	if (atomic_read(&blp->blp_busy_threads) <
+	    atomic_read(&blp->blp_num_threads))
 		return 0;
 
 	if (blwi && (!blwi->blwi_ns || blwi->blwi_mem_pressure))
@@ -815,9 +826,6 @@ static int ldlm_bl_thread_main(void *arg)
 
 	blp = bltd->bltd_blp;
 
-	atomic_inc(&blp->blp_num_threads);
-	atomic_inc(&blp->blp_busy_threads);
-
 	complete(&bltd->bltd_comp);
 	/* cannot use bltd after this, it is only on caller's stack */
 
@@ -828,27 +836,26 @@ static int ldlm_bl_thread_main(void *arg)
 		int rc;
 
 		rc = ldlm_bl_get_work(blp, &blwi, &exp);
-		if (!rc) {
-			atomic_dec(&blp->blp_busy_threads);
+		if (!rc)
 			l_wait_event_exclusive(blp->blp_waitq,
 					       ldlm_bl_get_work(blp, &blwi,
 								&exp),
 					       &lwi);
-			atomic_inc(&blp->blp_busy_threads);
-		}
+		atomic_inc(&blp->blp_busy_threads);
 
 		if (ldlm_bl_thread_need_create(blp, blwi))
 			/* discard the return value, we tried */
-			ldlm_bl_thread_start(blp);
+			ldlm_bl_thread_start(blp, true);
 
 		if (blwi)
 			rc = ldlm_bl_thread_blwi(blp, blwi);
 
+		atomic_dec(&blp->blp_busy_threads);
+
 		if (rc == LDLM_ITER_STOP)
 			break;
 	}
 
-	atomic_dec(&blp->blp_busy_threads);
 	atomic_dec(&blp->blp_num_threads);
 	complete(&blp->blp_comp);
 	return 0;
@@ -1028,7 +1035,7 @@ static int ldlm_setup(void)
 	}
 
 	for (i = 0; i < blp->blp_min_threads; i++) {
-		rc = ldlm_bl_thread_start(blp);
+		rc = ldlm_bl_thread_start(blp, false);
 		if (rc < 0)
 			goto out;
 	}
-- 
1.8.3.1
