From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:38 -0400
Subject: [lustre-devel] [PATCH 139/151] lustre: ptlrpc: clarify 64 bit time
 usage
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-140-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In the lustre code various small bits are left for the move to
64 bit time handling. This finishes some of the last bits left.
To make clear that a value is in seconds change unsigned int
values used for seconds to time64_t. Migrate scp_at_checktime
to ktime.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: fdb5d3d508ed ("libcfs: remove the remaining cfs_time wrappers")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/31068
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  4 ++--
 fs/lustre/ldlm/ldlm_pool.c     |  4 ++--
 fs/lustre/ptlrpc/import.c      |  2 +-
 fs/lustre/ptlrpc/service.c     | 19 ++++++++++---------
 net/lnet/libcfs/debug.c        |  2 +-
 5 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 22c9668..ffa6977 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1558,7 +1558,7 @@ struct ptlrpc_service_part {
 	struct list_head		scp_rqbd_posted;
 	/** incoming reqs */
 	struct list_head		scp_req_incoming;
-	/** timeout before re-posting reqs, in tick */
+	/** timeout before re-posting reqs, in jiffies */
 	long				scp_rqbd_timeout;
 	/**
 	 * all threads sleep on this. This wait-queue is signalled when new
@@ -1611,7 +1611,7 @@ struct ptlrpc_service_part {
 	/** early reply timer */
 	struct timer_list		scp_at_timer;
 	/** debug */
-	unsigned long			scp_at_checktime;
+	ktime_t				scp_at_checktime;
 	/** check early replies */
 	unsigned			scp_at_check;
 	/** @} */
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 25b1ada..04bf5de 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -887,7 +887,7 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 	struct ldlm_namespace *ns;
 	struct ldlm_namespace *ns_old = NULL;
 	/* seconds of sleep if no active namespaces */
-	int time = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
+	time64_t time = LDLM_POOL_CLI_DEF_RECALC_PERIOD;
 	int nr;
 
 	/*
@@ -953,7 +953,7 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 		 * After setup is done - recalc the pool.
 		 */
 		if (!skip) {
-			int ttime = ldlm_pool_recalc(&ns->ns_pool);
+			time64_t ttime = ldlm_pool_recalc(&ns->ns_pool);
 
 			if (ttime < time)
 				time = ttime;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 6fc0c6b..32bd218 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -242,7 +242,7 @@ void ptlrpc_deactivate_import(struct obd_import *imp)
 	return dl - now;
 }
 
-static unsigned int ptlrpc_inflight_timeout(struct obd_import *imp)
+static time64_t ptlrpc_inflight_timeout(struct obd_import *imp)
 {
 	time64_t now = ktime_get_real_seconds();
 	struct ptlrpc_request *req, *n;
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 57c5e28..f07f549 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -342,7 +342,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
 	svcpt = from_timer(svcpt, t, scp_at_timer);
 
 	svcpt->scp_at_check = 1;
-	svcpt->scp_at_checktime = jiffies;
+	svcpt->scp_at_checktime = ktime_get();
 	wake_up(&svcpt->scp_waitq);
 }
 
@@ -933,7 +933,7 @@ static int ptlrpc_check_req(struct ptlrpc_request *req)
 static void ptlrpc_at_set_timer(struct ptlrpc_service_part *svcpt)
 {
 	struct ptlrpc_at_array *array = &svcpt->scp_at_array;
-	s32 next;
+	time64_t next;
 
 	if (array->paa_count == 0) {
 		del_timer(&svcpt->scp_at_timer);
@@ -941,13 +941,14 @@ static void ptlrpc_at_set_timer(struct ptlrpc_service_part *svcpt)
 	}
 
 	/* Set timer for closest deadline */
-	next = (s32)(array->paa_deadline - ktime_get_real_seconds() -
-		       at_early_margin);
+	next = array->paa_deadline - ktime_get_real_seconds() -
+		at_early_margin;
 	if (next <= 0) {
 		ptlrpc_at_timer(&svcpt->scp_at_timer);
 	} else {
-		mod_timer(&svcpt->scp_at_timer, jiffies + next * HZ);
-		CDEBUG(D_INFO, "armed %s at %+ds\n",
+		mod_timer(&svcpt->scp_at_timer,
+			  jiffies + nsecs_to_jiffies(next * NSEC_PER_SEC));
+		CDEBUG(D_INFO, "armed %s at %+llds\n",
 		       svcpt->scp_service->srv_name, next);
 	}
 }
@@ -1181,7 +1182,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	u32 index, count;
 	time64_t deadline;
 	time64_t now = ktime_get_real_seconds();
-	long delay;
+	s64 delay;
 	int first, counter = 0;
 
 	spin_lock(&svcpt->scp_at_lock);
@@ -1189,7 +1190,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		spin_unlock(&svcpt->scp_at_lock);
 		return;
 	}
-	delay = jiffies - svcpt->scp_at_checktime;
+	delay = ktime_ms_delta(ktime_get(), svcpt->scp_at_checktime);
 	svcpt->scp_at_check = 0;
 
 	if (array->paa_count == 0) {
@@ -1254,7 +1255,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 		 */
 		LCONSOLE_WARN("%s: This server is not able to keep up with request traffic (cpu-bound).\n",
 			      svcpt->scp_service->srv_name);
-		CWARN("earlyQ=%d reqQ=%d recA=%d, svcEst=%d, delay=%ld(jiff)\n",
+		CWARN("earlyQ=%d reqQ=%d recA=%d, svcEst=%d, delay=%lld\n",
 		      counter, svcpt->scp_nreqs_incoming,
 		      svcpt->scp_nreqs_active,
 		      at_get(&svcpt->scp_at_estimate), delay);
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index fd8ed81..6b8f783e6 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -129,7 +129,7 @@ static int param_get_delay(char *buffer, const struct kernel_param *kp)
 {
 	unsigned int d = *(unsigned int *)kp->arg;
 
-	return sprintf(buffer, "%u", (unsigned int)(d * 100) / HZ);
+	return sprintf(buffer, "%lu", jiffies_to_msecs(d * 10) / MSEC_PER_SEC);
 }
 
 unsigned int libcfs_console_max_delay;
-- 
1.8.3.1
