From: Binoy Jayan <binoy.jayan@linaro.org>
Date: Wed,  8 Jun 2016 13:20:41 +0530
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: lloop_device: Replace
	semaphore lo_sem with completion
In-Reply-To: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
References: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
Message-ID: <1465372242-7116-2-git-send-email-binoy.jayan@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org
Cc: Binoy Jayan <binoy.jayan@linaro.org>, driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

The semaphore 'lo_sem' in lloop_device is used as completion, so it
should be written as one. Semaphores are going away in the future.

Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
---
 drivers/staging/lustre/lustre/llite/lloop.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index 813a9a3..90b31ba 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -131,7 +131,7 @@ struct lloop_device {
 	struct bio		*lo_bio;
 	struct bio		*lo_biotail;
 	int			lo_state;
-	struct semaphore	lo_sem;
+	struct completion	lo_comp;
 	struct mutex		lo_ctl_mutex;
 	atomic_t	 lo_pending;
 	wait_queue_head_t	  lo_bh_wait;
@@ -423,9 +423,9 @@ static int loop_thread(void *data)
 	lo->lo_pvec.ldp_offsets = lo->lo_requests[0].lrd_offsets;
 
 	/*
-	 * up sem, we are running
+	 * signal completion, we are running
 	 */
-	up(&lo->lo_sem);
+	complete(&lo->lo_comp);
 
 	for (;;) {
 		wait_event(lo->lo_bh_wait, loop_active(lo));
@@ -466,7 +466,7 @@ static int loop_thread(void *data)
 	cl_env_put(env, &refcheck);
 
 out:
-	up(&lo->lo_sem);
+	complete(&lo->lo_comp);
 	return ret;
 }
 
@@ -539,7 +539,7 @@ static int loop_set_fd(struct lloop_device *lo, struct file *unused,
 	set_blocksize(bdev, lo->lo_blocksize);
 
 	kthread_run(loop_thread, lo, "lloop%d", lo->lo_number);
-	down(&lo->lo_sem);
+	wait_for_completion(&lo->lo_comp);
 	return 0;
 
 out:
@@ -568,7 +568,7 @@ static int loop_clr_fd(struct lloop_device *lo, struct block_device *bdev,
 	spin_unlock_irq(&lo->lo_lock);
 	wake_up(&lo->lo_bh_wait);
 
-	down(&lo->lo_sem);
+	wait_for_completion(&lo->lo_comp);
 	lo->lo_backing_file = NULL;
 	lo->lo_device = NULL;
 	lo->lo_offset = 0;
@@ -821,7 +821,7 @@ static int __init lloop_init(void)
 			goto out_mem4;
 
 		mutex_init(&lo->lo_ctl_mutex);
-		sema_init(&lo->lo_sem, 0);
+		init_completion(&lo->lo_comp);
 		init_waitqueue_head(&lo->lo_bh_wait);
 		lo->lo_number = i;
 		spin_lock_init(&lo->lo_lock);
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
