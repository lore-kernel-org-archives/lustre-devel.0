From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:11 -0500
Subject: [lustre-devel] [PATCH 10/14] staging: lustre: ldlm: disconnect
	speedup
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

disconnect takes too long time if there are many locks to cancel.
besides the amount of time spent on each lock cancel, there is a
resched() in cfs_hash_for_each_relax(), i.e. disconnect or eviction
may take unexpectedly long time. While this patch only contains
the client side fixes the original fix covered changes to both
the server and client code to ensure proper disconnect handling.
Below details the change done on both the server and client so
people can examine the disconnect behavior with both source bases.

- do not cancel locks on disconnect_export;
- export will be left in obd_unlinked_exports list pinned by live
  locks;
- new re-connects will created other non-conflicting exports;
- new locks will cancel obsolete locks on conflicts;
- once all the locks on the disconnected export will be cancelled,
  the export will be destroyed on the last ref put;
- do not cancel in small portions, cancel all together in just 1
  dedicated thread - use server side blocking thread for that;
- cancel blocked locks first so that waiting locks could proceed;
- take care about blocked waiting locks, so that they would get
  cancelled quickly too;
- do not remove lock from waiting list on AST error before moving
  it to elt_expired_locks list, because it removes it from export
  list too; otherwise this blocked lock will not be cancelled
  immediately on failed export;
- cancel lock instead of just destroy for failed export, to make
  full cleanup, i.e. remove it from export list.

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3031
Xyratex-bug-id: MRP-395 MRP-1366 MRP-1366
Reviewed-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Reviewed-by: Alexey Lyashkov <Alexey_Lyashkov@xyratex.com>
Reviewed-on: http://review.whamcloud.com/5843
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  11 +-
 .../staging/lustre/lustre/include/obd_support.h    |   1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 143 +++++++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   4 +
 6 files changed, 101 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index b7e61d0..1e86fb5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -812,13 +812,6 @@ struct ldlm_lock {
 	/** referenced export object */
 	struct obd_export	*l_exp_refs_target;
 #endif
-	/**
-	 * export blocking dlm lock list, protected by
-	 * l_export->exp_bl_list_lock.
-	 * Lock order of waiting_lists_spinlock, exp_bl_list_lock and res lock
-	 * is: res lock -> exp_bl_list_lock -> wanting_lists_spinlock.
-	 */
-	struct list_head		l_exp_list;
 };
 
 /**
@@ -1192,6 +1185,10 @@ struct ldlm_namespace *
 		   enum ldlm_side client, enum ldlm_appetite apt,
 		   enum ldlm_ns_type ns_type);
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
+void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
+			       struct obd_import *imp,
+			       int force);
+void ldlm_namespace_free_post(struct ldlm_namespace *ns);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
 void ldlm_namespace_put(struct ldlm_namespace *ns);
 int ldlm_debugfs_setup(void);
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index aaedec7..05a958a 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -316,6 +316,7 @@
 #define OBD_FAIL_LDLM_AGL_NOLOCK	 0x31b
 #define OBD_FAIL_LDLM_OST_LVB		 0x31c
 #define OBD_FAIL_LDLM_ENQUEUE_HANG	 0x31d
+#define OBD_FAIL_LDLM_PAUSE_CANCEL2	 0x31f
 #define OBD_FAIL_LDLM_CP_CB_WAIT2	 0x320
 #define OBD_FAIL_LDLM_CP_CB_WAIT3	 0x321
 #define OBD_FAIL_LDLM_CP_CB_WAIT4	 0x322
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 5c02501..5d24b48 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -108,9 +108,7 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 
 /* ldlm_resource.c */
 int ldlm_resource_putref_locked(struct ldlm_resource *res);
-void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
-			       struct obd_import *imp, int force);
-void ldlm_namespace_free_post(struct ldlm_namespace *ns);
+
 /* ldlm_lock.c */
 
 struct ldlm_cb_set_arg {
@@ -156,6 +154,7 @@ int ldlm_bl_to_thread_list(struct ldlm_namespace *ns,
 			   struct ldlm_lock_desc *ld,
 			   struct list_head *cancels, int count,
 			   enum ldlm_cancel_flags cancel_flags);
+int ldlm_bl_thread_wakeup(void);
 
 void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 			     struct ldlm_lock_desc *ld, struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 16c2a8b..ddb4642 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -435,7 +435,6 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lock->l_exp_refs_nr = 0;
 	lock->l_exp_refs_target = NULL;
 #endif
-	INIT_LIST_HEAD(&lock->l_exp_list);
 
 	return lock;
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 12647af..4c21b9b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -454,6 +454,12 @@ int ldlm_bl_to_thread_list(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
 	return ldlm_bl_to_thread(ns, ld, NULL, cancels, count, cancel_flags);
 }
 
+int ldlm_bl_thread_wakeup(void)
+{
+	wake_up(&ldlm_state->ldlm_bl_pool->blp_waitq);
+	return 0;
+}
+
 /* Setinfo coming from Server (eg MDT) to Client (eg MDC)! */
 static int ldlm_handle_setinfo(struct ptlrpc_request *req)
 {
@@ -675,8 +681,11 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	return 0;
 }
 
-static struct ldlm_bl_work_item *ldlm_bl_get_work(struct ldlm_bl_pool *blp)
+static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
+			    struct ldlm_bl_work_item **p_blwi,
+			    struct obd_export **p_exp)
 {
+	int num_th = atomic_read(&blp->blp_num_threads);
 	struct ldlm_bl_work_item *blwi = NULL;
 	static unsigned int num_bl;
 
@@ -693,13 +702,14 @@ static struct ldlm_bl_work_item *ldlm_bl_get_work(struct ldlm_bl_pool *blp)
 					  blwi_entry);
 
 	if (blwi) {
-		if (++num_bl >= atomic_read(&blp->blp_num_threads))
+		if (++num_bl >= num_th)
 			num_bl = 0;
 		list_del(&blwi->blwi_entry);
 	}
 	spin_unlock(&blp->blp_lock);
+	*p_blwi = blwi;
 
-	return blwi;
+	return (*p_blwi || *p_exp) ? 1 : 0;
 }
 
 /* This only contains temporary data until the thread starts */
@@ -732,6 +742,65 @@ static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp)
 	return 0;
 }
 
+/* Not fatal if racy and have a few too many threads */
+static int ldlm_bl_thread_need_create(struct ldlm_bl_pool *blp,
+				      struct ldlm_bl_work_item *blwi)
+{
+	int busy = atomic_read(&blp->blp_busy_threads);
+
+	if (busy >= blp->blp_max_threads)
+		return 0;
+
+	if (busy < atomic_read(&blp->blp_num_threads))
+		return 0;
+
+	if (blwi && (!blwi->blwi_ns || blwi->blwi_mem_pressure))
+		return 0;
+
+	return 1;
+}
+
+static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
+			       struct ldlm_bl_work_item *blwi)
+{
+	if (!blwi->blwi_ns)
+		/* added by ldlm_cleanup() */
+		return LDLM_ITER_STOP;
+
+	if (blwi->blwi_mem_pressure)
+		memory_pressure_set();
+
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL2, 4);
+
+	if (blwi->blwi_count) {
+		int count;
+
+		/*
+		 * The special case when we cancel locks in lru
+		 * asynchronously, we pass the list of locks here.
+		 * Thus locks are marked LDLM_FL_CANCELING, but NOT
+		 * canceled locally yet.
+		 */
+		count = ldlm_cli_cancel_list_local(&blwi->blwi_head,
+						   blwi->blwi_count,
+						   LCF_BL_AST);
+		ldlm_cli_cancel_list(&blwi->blwi_head, count, NULL,
+				     blwi->blwi_flags);
+	} else {
+		ldlm_handle_bl_callback(blwi->blwi_ns, &blwi->blwi_ld,
+					blwi->blwi_lock);
+	}
+	if (blwi->blwi_mem_pressure)
+		memory_pressure_clr();
+
+	if (blwi->blwi_flags & LCF_ASYNC)
+		kfree(blwi);
+	else
+		complete(&blwi->blwi_comp);
+
+	return 0;
+}
+
 /**
  * Main blocking requests processing thread.
  *
@@ -742,73 +811,41 @@ static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp)
 static int ldlm_bl_thread_main(void *arg)
 {
 	struct ldlm_bl_pool *blp;
+	struct ldlm_bl_thread_data *bltd = arg;
 
-	{
-		struct ldlm_bl_thread_data *bltd = arg;
-
-		blp = bltd->bltd_blp;
+	blp = bltd->bltd_blp;
 
-		atomic_inc(&blp->blp_num_threads);
-		atomic_inc(&blp->blp_busy_threads);
+	atomic_inc(&blp->blp_num_threads);
+	atomic_inc(&blp->blp_busy_threads);
 
-		complete(&bltd->bltd_comp);
-		/* cannot use bltd after this, it is only on caller's stack */
-	}
+	complete(&bltd->bltd_comp);
+	/* cannot use bltd after this, it is only on caller's stack */
 
 	while (1) {
 		struct l_wait_info lwi = { 0 };
 		struct ldlm_bl_work_item *blwi = NULL;
-		int busy;
+		struct obd_export *exp = NULL;
+		int rc;
 
-		blwi = ldlm_bl_get_work(blp);
-
-		if (!blwi) {
+		rc = ldlm_bl_get_work(blp, &blwi, &exp);
+		if (!rc) {
 			atomic_dec(&blp->blp_busy_threads);
 			l_wait_event_exclusive(blp->blp_waitq,
-					       (blwi = ldlm_bl_get_work(blp)),
+					       ldlm_bl_get_work(blp, &blwi,
+								&exp),
 					       &lwi);
-			busy = atomic_inc_return(&blp->blp_busy_threads);
-		} else {
-			busy = atomic_read(&blp->blp_busy_threads);
+			atomic_inc(&blp->blp_busy_threads);
 		}
 
-		if (!blwi->blwi_ns)
-			/* added by ldlm_cleanup() */
-			break;
-
-		/* Not fatal if racy and have a few too many threads */
-		if (unlikely(busy < blp->blp_max_threads &&
-			     busy >= atomic_read(&blp->blp_num_threads) &&
-			     !blwi->blwi_mem_pressure))
+		if (ldlm_bl_thread_need_create(blp, blwi))
 			/* discard the return value, we tried */
 			ldlm_bl_thread_start(blp);
 
-		if (blwi->blwi_mem_pressure)
-			memory_pressure_set();
-
-		if (blwi->blwi_count) {
-			int count;
-			/* The special case when we cancel locks in LRU
-			 * asynchronously, we pass the list of locks here.
-			 * Thus locks are marked LDLM_FL_CANCELING, but NOT
-			 * canceled locally yet.
-			 */
-			count = ldlm_cli_cancel_list_local(&blwi->blwi_head,
-							   blwi->blwi_count,
-							   LCF_BL_AST);
-			ldlm_cli_cancel_list(&blwi->blwi_head, count, NULL,
-					     blwi->blwi_flags);
-		} else {
-			ldlm_handle_bl_callback(blwi->blwi_ns, &blwi->blwi_ld,
-						blwi->blwi_lock);
-		}
-		if (blwi->blwi_mem_pressure)
-			memory_pressure_clr();
+		if (blwi)
+			rc = ldlm_bl_thread_blwi(blp, blwi);
 
-		if (blwi->blwi_flags & LCF_ASYNC)
-			kfree(blwi);
-		else
-			complete(&blwi->blwi_comp);
+		if (rc == LDLM_ITER_STOP)
+			break;
 	}
 
 	atomic_dec(&blp->blp_busy_threads);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 13fbbed..cf3fc57 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -975,6 +975,10 @@ static int ldlm_pools_recalc(enum ldlm_side client)
 			ldlm_namespace_put(ns);
 		}
 	}
+
+	/* Wake up the blocking threads from time to time. */
+	ldlm_bl_thread_wakeup();
+
 	return time;
 }
 
-- 
1.8.3.1
