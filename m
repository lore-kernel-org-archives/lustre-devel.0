From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Sun,  8 Nov 2015 14:47:10 +0530
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: workitem: Remove
	cfs_wi_sched_lock wrapper
In-Reply-To: <cover.1446974107.git.shivanib134@gmail.com>
References: <cover.1446974107.git.shivanib134@gmail.com>
Message-ID: <136bf99ca0c65cc577199e26f6fba3182422c7de.1446974107.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function cfs_wi_sched_lock() and replace all its
calls with the function it wrapped.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/libcfs/workitem.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index b57acbf..e8bac9b 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -87,12 +87,6 @@ static struct cfs_workitem_data {
 } cfs_wi_data;
 
 static inline void
-cfs_wi_sched_lock(struct cfs_wi_sched *sched)
-{
-	spin_lock(&sched->ws_lock);
-}
-
-static inline void
 cfs_wi_sched_unlock(struct cfs_wi_sched *sched)
 {
 	spin_unlock(&sched->ws_lock);
@@ -101,7 +95,7 @@ cfs_wi_sched_unlock(struct cfs_wi_sched *sched)
 static inline int
 cfs_wi_sched_cansleep(struct cfs_wi_sched *sched)
 {
-	cfs_wi_sched_lock(sched);
+	spin_lock(&sched->ws_lock);
 	if (sched->ws_stopping) {
 		cfs_wi_sched_unlock(sched);
 		return 0;
@@ -125,7 +119,7 @@ cfs_wi_exit(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
 	LASSERT(!sched->ws_stopping);
 
-	cfs_wi_sched_lock(sched);
+	spin_lock(&sched->ws_lock);
 
 	LASSERT(wi->wi_running);
 	if (wi->wi_scheduled) { /* cancel pending schedules */
@@ -161,7 +155,7 @@ cfs_wi_deschedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 	 * means the workitem will not be scheduled and will not have
 	 * any race with wi_action.
 	 */
-	cfs_wi_sched_lock(sched);
+	spin_lock(&sched->ws_lock);
 
 	rc = !(wi->wi_running);
 
@@ -195,7 +189,7 @@ cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
 	LASSERT(!sched->ws_stopping);
 
-	cfs_wi_sched_lock(sched);
+	spin_lock(&sched->ws_lock);
 
 	if (!wi->wi_scheduled) {
 		LASSERT (list_empty(&wi->wi_list));
@@ -237,7 +231,7 @@ cfs_wi_scheduler (void *arg)
 
 	spin_unlock(&cfs_wi_data.wi_glock);
 
-	cfs_wi_sched_lock(sched);
+	spin_lock(&sched->ws_lock);
 
 	while (!sched->ws_stopping) {
 		int	     nloops = 0;
@@ -263,7 +257,7 @@ cfs_wi_scheduler (void *arg)
 
 			rc = (*wi->wi_action) (wi);
 
-			cfs_wi_sched_lock(sched);
+			spin_lock(&sched->ws_lock);
 			if (rc != 0) /* WI should be dead, even be freed! */
 				continue;
 
@@ -282,14 +276,14 @@ cfs_wi_scheduler (void *arg)
 			/* don't sleep because some workitems still
 			 * expect me to come back soon */
 			cond_resched();
-			cfs_wi_sched_lock(sched);
+			spin_lock(&sched->ws_lock);
 			continue;
 		}
 
 		cfs_wi_sched_unlock(sched);
 		rc = wait_event_interruptible_exclusive(sched->ws_waitq,
 						!cfs_wi_sched_cansleep(sched));
-		cfs_wi_sched_lock(sched);
+		spin_lock(&sched->ws_lock);
 	}
 
 	cfs_wi_sched_unlock(sched);
-- 
2.1.0
