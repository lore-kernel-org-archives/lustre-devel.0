From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Sun,  8 Nov 2015 14:47:34 +0530
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: workitem: Remove
	cfs_wi_sched_unlock wrapper
In-Reply-To: <cover.1446974107.git.shivanib134@gmail.com>
References: <cover.1446974107.git.shivanib134@gmail.com>
Message-ID: <7039ec871e3d3b34c6f6a958d38e14cb87b87761.1446974107.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function cfs_wi_sched_unlock() and replace all its
calls with the function it wrapped.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/libcfs/workitem.c | 26 ++++++++++---------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index e8bac9b..60bb88a 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -86,26 +86,20 @@ static struct cfs_workitem_data {
 	int			wi_stopping;
 } cfs_wi_data;
 
-static inline void
-cfs_wi_sched_unlock(struct cfs_wi_sched *sched)
-{
-	spin_unlock(&sched->ws_lock);
-}
-
 static inline int
 cfs_wi_sched_cansleep(struct cfs_wi_sched *sched)
 {
 	spin_lock(&sched->ws_lock);
 	if (sched->ws_stopping) {
-		cfs_wi_sched_unlock(sched);
+		spin_unlock(&sched->ws_lock);
 		return 0;
 	}
 
 	if (!list_empty(&sched->ws_runq)) {
-		cfs_wi_sched_unlock(sched);
+		spin_unlock(&sched->ws_lock);
 		return 0;
 	}
-	cfs_wi_sched_unlock(sched);
+	spin_unlock(&sched->ws_lock);
 	return 1;
 }
 
@@ -133,7 +127,7 @@ cfs_wi_exit(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 	LASSERT(list_empty(&wi->wi_list));
 
 	wi->wi_scheduled = 1; /* LBUG future schedule attempts */
-	cfs_wi_sched_unlock(sched);
+	spin_unlock(&sched->ws_lock);
 
 	return;
 }
@@ -171,7 +165,7 @@ cfs_wi_deschedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 
 	LASSERT (list_empty(&wi->wi_list));
 
-	cfs_wi_sched_unlock(sched);
+	spin_unlock(&sched->ws_lock);
 	return rc;
 }
 EXPORT_SYMBOL(cfs_wi_deschedule);
@@ -205,7 +199,7 @@ cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 	}
 
 	LASSERT (!list_empty(&wi->wi_list));
-	cfs_wi_sched_unlock(sched);
+	spin_unlock(&sched->ws_lock);
 	return;
 }
 EXPORT_SYMBOL(cfs_wi_schedule);
@@ -252,7 +246,7 @@ cfs_wi_scheduler (void *arg)
 			wi->wi_running   = 1;
 			wi->wi_scheduled = 0;
 
-			cfs_wi_sched_unlock(sched);
+			spin_unlock(&sched->ws_lock);
 			nloops++;
 
 			rc = (*wi->wi_action) (wi);
@@ -272,7 +266,7 @@ cfs_wi_scheduler (void *arg)
 		}
 
 		if (!list_empty(&sched->ws_runq)) {
-			cfs_wi_sched_unlock(sched);
+			spin_unlock(&sched->ws_lock);
 			/* don't sleep because some workitems still
 			 * expect me to come back soon */
 			cond_resched();
@@ -280,13 +274,13 @@ cfs_wi_scheduler (void *arg)
 			continue;
 		}
 
-		cfs_wi_sched_unlock(sched);
+		spin_unlock(&sched->ws_lock);
 		rc = wait_event_interruptible_exclusive(sched->ws_waitq,
 						!cfs_wi_sched_cansleep(sched));
 		spin_lock(&sched->ws_lock);
 	}
 
-	cfs_wi_sched_unlock(sched);
+	spin_unlock(&sched->ws_lock);
 
 	spin_lock(&cfs_wi_data.wi_glock);
 	sched->ws_nthreads--;
-- 
2.1.0
