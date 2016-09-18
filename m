From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:01 -0400
Subject: [lustre-devel] [PATCH 062/124] staging: lustre: replace direct HZ
	access with kernel APIs
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-63-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jian Yu <jian.yu@intel.com>

On some customer's systems, kernel was compiled with HZ defined to
100, instead of 1000. This improves performance for HPC applications.
However, to use these systems with Lustre, customers have to re-build
Lustre for the kernel because Lustre directly uses the defined
constant HZ.

Since kernel 2.6.21, some non-HZ dependent timing APIs become non-
inline functions, which can be used in Lustre codes to replace the
direct HZ access.

These kernel APIs include:
  jiffies_to_msecs()
  jiffies_to_usecs()
  jiffies_to_timespec()
  msecs_to_jiffies()
  usecs_to_jiffies()
  timespec_to_jiffies()

And here are some samples of the replacement:
  HZ            -> msecs_to_jiffies(MSEC_PER_SEC)
  n * HZ        -> msecs_to_jiffies(n * MSEC_PER_SEC)
  HZ / n        -> msecs_to_jiffies(MSEC_PER_SEC / n)
  n / HZ        -> jiffies_to_msecs(n) / MSEC_PER_SEC
  n / HZ * 1000 -> jiffies_to_msecs(n)

This patch replaces the direct HZ access in lustre modules.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5443
Reviewed-on: http://review.whamcloud.com/12052
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    3 ++-
 drivers/staging/lustre/lustre/llite/statahead.c    |    3 ++-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    5 +++--
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    7 ++++---
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    9 +++++----
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    3 ++-
 6 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 912cd68..a09c25a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -880,7 +880,8 @@ static int __ldlm_namespace_free(struct ldlm_namespace *ns, int force)
 		       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
 force_wait:
 		if (force)
-			lwi = LWI_TIMEOUT(obd_timeout * HZ / 4, NULL, NULL);
+			lwi = LWI_TIMEOUT(msecs_to_jiffies(obd_timeout *
+					  MSEC_PER_SEC) / 4, NULL, NULL);
 
 		rc = l_wait_event(ns->ns_waitq,
 				  atomic_read(&ns->ns_bref) == 0, &lwi);
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 70ca252..323a175 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1154,7 +1154,8 @@ out:
 	 */
 	while (sai->sai_sent != sai->sai_replied) {
 		/* in case we're not woken up, timeout wait */
-		lwi = LWI_TIMEOUT(HZ >> 3, NULL, NULL);
+		lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
+				  NULL, NULL);
 		l_wait_event(thread->t_ctl_waitq,
 			     sai->sai_sent == sai->sai_replied, &lwi);
 	}
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index f3d4f7f..88d4d10 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -549,8 +549,9 @@ static int mgc_requeue_thread(void *data)
 		 * caused the lock revocation to finish its setup, plus some
 		 * random so everyone doesn't try to reconnect at once.
 		 */
-		to = MGC_TIMEOUT_MIN_SECONDS * HZ;
-		to += rand * HZ / 100; /* rand is centi-seconds */
+		to = msecs_to_jiffies(MGC_TIMEOUT_MIN_SECONDS * MSEC_PER_SEC);
+		/* rand is centi-seconds */
+		to += msecs_to_jiffies(rand * MSEC_PER_SEC / 100);
 		lwi = LWI_TIMEOUT(to, NULL, NULL);
 		l_wait_event(rq_waitq, rq_state & (RQ_STOP | RQ_PRECLEANUP),
 			     &lwi);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index dbd819f..523579f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -499,7 +499,7 @@ static int sptlrpc_req_replace_dead_ctx(struct ptlrpc_request *req)
 		       newctx, newctx->cc_flags);
 
 		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(HZ);
+		schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC));
 	} else {
 		/*
 		 * it's possible newctx == oldctx if we're switching
@@ -718,8 +718,9 @@ again:
 	req->rq_restart = 0;
 	spin_unlock(&req->rq_lock);
 
-	lwi = LWI_TIMEOUT_INTR(timeout * HZ, ctx_refresh_timeout,
-			       ctx_refresh_interrupt, req);
+	lwi = LWI_TIMEOUT_INTR(msecs_to_jiffies(timeout * MSEC_PER_SEC),
+			       ctx_refresh_timeout, ctx_refresh_interrupt,
+			       req);
 	rc = l_wait_event(req->rq_reply_waitq, ctx_check_refresh(ctx), &lwi);
 
 	/*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index fdb32d5..6adf274 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -139,7 +139,7 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   "cache missing:	   %lu\n"
 		   "low free mark:	   %lu\n"
 		   "max waitqueue depth:     %u\n"
-		   "max wait time:	   %ld/%u\n",
+		   "max wait time:	   %ld/%lu\n",
 		   totalram_pages,
 		   PAGES_PER_POOL,
 		   page_pools.epp_max_pages,
@@ -158,7 +158,7 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   page_pools.epp_st_lowfree,
 		   page_pools.epp_st_max_wqlen,
 		   page_pools.epp_st_max_wait,
-		   HZ);
+		   msecs_to_jiffies(MSEC_PER_SEC));
 
 	spin_unlock(&page_pools.epp_lock);
 
@@ -432,12 +432,13 @@ void sptlrpc_enc_pool_fini(void)
 
 	if (page_pools.epp_st_access > 0) {
 		CDEBUG(D_SEC,
-		       "max pages %lu, grows %u, grow fails %u, shrinks %u, access %lu, missing %lu, max qlen %u, max wait %ld/%d\n",
+		       "max pages %lu, grows %u, grow fails %u, shrinks %u, access %lu, missing %lu, max qlen %u, max wait %ld/%ld\n",
 		       page_pools.epp_st_max_pages, page_pools.epp_st_grows,
 		       page_pools.epp_st_grow_fails,
 		       page_pools.epp_st_shrinks, page_pools.epp_st_access,
 		       page_pools.epp_st_missings, page_pools.epp_st_max_wqlen,
-		       page_pools.epp_st_max_wait, HZ);
+		       page_pools.epp_st_max_wait,
+		       msecs_to_jiffies(MSEC_PER_SEC));
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 9b9801e..f79a889 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -182,7 +182,8 @@ again:
 		/* check ctx list again before sleep */
 		sec_process_ctx_list();
 
-		lwi = LWI_TIMEOUT(SEC_GC_INTERVAL * HZ, NULL, NULL);
+		lwi = LWI_TIMEOUT(msecs_to_jiffies(SEC_GC_INTERVAL * MSEC_PER_SEC),
+				  NULL, NULL);
 		l_wait_event(thread->t_ctl_waitq,
 			     thread_is_stopping(thread) ||
 			     thread_is_signal(thread),
-- 
1.7.1
