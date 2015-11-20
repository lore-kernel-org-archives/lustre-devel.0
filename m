From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:42 -0500
Subject: [lustre-devel] [PATCH 06/40] staging: lustre: remove uses of
	IS_ERR_VALUE()
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Remove most uses of IS_ERR_VALUE(). This macro was often given an int
argument coming from PTR_ERR(). This invokes implementation defined
behavior since the long value gotten by applying PTR_ERR() to a kernel
pointer will usually not be representable as an int. Moreover it may
be just plain wrong to do this since the expressions IS_ERR(p) and
IS_ERR_VALUE((int) PTR_ERR(p)) are not equivalent for a general
pointer p.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3498
Reviewed-on: http://review.whamcloud.com/6759
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/acceptor.c      |    9 ++++---
 drivers/staging/lustre/lnet/lnet/router.c        |    7 +++--
 drivers/staging/lustre/lustre/libcfs/tracefile.c |    6 +++-
 drivers/staging/lustre/lustre/llite/statahead.c  |    8 ++++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c  |   18 +++++++++----
 drivers/staging/lustre/lustre/mgc/mgc_request.c  |    9 ++++---
 drivers/staging/lustre/lustre/obdclass/llog.c    |   13 ++++++----
 drivers/staging/lustre/lustre/ptlrpc/pinger.c    |   10 ++++---
 drivers/staging/lustre/lustre/ptlrpc/service.c   |   29 +++++++++++++---------
 9 files changed, 66 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 92ca1dd..d05754d 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -436,6 +436,7 @@ accept2secure(const char *acc, long *sec)
 int
 lnet_acceptor_start(void)
 {
+	struct task_struct *task;
 	int rc;
 	long rc2;
 	long secure;
@@ -454,10 +455,10 @@ lnet_acceptor_start(void)
 	if (lnet_count_acceptor_nis() == 0)  /* not required */
 		return 0;
 
-	rc2 = PTR_ERR(kthread_run(lnet_acceptor,
-				  (void *)(ulong_ptr_t)secure,
-				  "acceptor_%03ld", secure));
-	if (IS_ERR_VALUE(rc2)) {
+	task = kthread_run(lnet_acceptor, (void *)(ulong_ptr_t)secure,
+			   "acceptor_%03ld", secure);
+	if (IS_ERR(task)) {
+		rc2 = PTR_ERR(task);
 		CERROR("Can't start acceptor thread: %ld\n", rc2);
 
 		return -ESRCH;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index fa61ec9..47f80aa 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -993,6 +993,7 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 int
 lnet_router_checker_start(void)
 {
+	struct task_struct *task;
 	int rc;
 	int eqsz;
 
@@ -1021,9 +1022,9 @@ lnet_router_checker_start(void)
 	}
 
 	the_lnet.ln_rc_state = LNET_RC_STATE_RUNNING;
-	rc = PTR_ERR(kthread_run(lnet_router_checker,
-				 NULL, "router_checker"));
-	if (IS_ERR_VALUE(rc)) {
+	task = kthread_run(lnet_router_checker, NULL, "router_checker");
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
 		CERROR("Can't start router checker thread: %d\n", rc);
 		/* block until event callback signals exit */
 		down(&the_lnet.ln_rc_signal);
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 65c4f1a..bc5d0ee 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -1056,6 +1056,7 @@ end_loop:
 int cfs_trace_start_thread(void)
 {
 	struct tracefiled_ctl *tctl = &trace_tctl;
+	struct task_struct *task;
 	int rc = 0;
 
 	mutex_lock(&cfs_trace_thread_mutex);
@@ -1067,8 +1068,9 @@ int cfs_trace_start_thread(void)
 	init_waitqueue_head(&tctl->tctl_waitq);
 	atomic_set(&tctl->tctl_shutdown, 0);
 
-	if (IS_ERR(kthread_run(tracefiled, tctl, "ktracefiled"))) {
-		rc = -ECHILD;
+	task = kthread_run(tracefiled, tctl, "ktracefiled");
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
 		goto out;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 18f5f2b..e17daf8 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1512,6 +1512,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	struct ll_sa_entry       *entry;
 	struct ptlrpc_thread     *thread;
 	struct l_wait_info	lwi   = { 0 };
+	struct task_struct *task;
 	int		       rc    = 0;
 	struct ll_inode_info     *plli;
 
@@ -1670,10 +1671,11 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 	lli->lli_sai = sai;
 
 	plli = ll_i2info(d_inode(parent));
-	rc = PTR_ERR(kthread_run(ll_statahead_thread, parent,
-				 "ll_sa_%u", plli->lli_opendir_pid));
+	task = kthread_run(ll_statahead_thread, parent, "ll_sa_%u",
+			   plli->lli_opendir_pid);
 	thread = &sai->sai_thread;
-	if (IS_ERR_VALUE(rc)) {
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
 		CERROR("can't start ll_sa thread, rc: %d\n", rc);
 		dput(parent);
 		lli->lli_opendir_key = NULL;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 294c050..ef25ccd 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1560,6 +1560,7 @@ static int mdc_ioc_changelog_send(struct obd_device *obd,
 				  struct ioc_changelog *icc)
 {
 	struct changelog_show *cs;
+	struct task_struct *task;
 	int rc;
 
 	/* Freed in mdc_changelog_send_thread */
@@ -1577,15 +1578,20 @@ static int mdc_ioc_changelog_send(struct obd_device *obd,
 	 * New thread because we should return to user app before
 	 * writing into our pipe
 	 */
-	rc = PTR_ERR(kthread_run(mdc_changelog_send_thread, cs,
-				 "mdc_clg_send_thread"));
-	if (!IS_ERR_VALUE(rc)) {
-		CDEBUG(D_CHANGELOG, "start changelog thread\n");
-		return 0;
+	task = kthread_run(mdc_changelog_send_thread, cs,
+			   "mdc_clg_send_thread");
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
+		CERROR("%s: can't start changelog thread: rc = %d\n",
+		       obd->obd_name, rc);
+		kfree(cs);
+	} else {
+		rc = 0;
+		CDEBUG(D_CHANGELOG, "%s: started changelog thread\n",
+		       obd->obd_name);
 	}
 
 	CERROR("Failed to start changelog thread: %d\n", rc);
-	kfree(cs);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2c48847..1395a1a 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -711,6 +711,7 @@ static int mgc_cleanup(struct obd_device *obd)
 static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 {
 	struct lprocfs_static_vars lvars = { NULL };
+	struct task_struct *task;
 	int rc;
 
 	ptlrpcd_addref();
@@ -734,10 +735,10 @@ static int mgc_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		init_waitqueue_head(&rq_waitq);
 
 		/* start requeue thread */
-		rc = PTR_ERR(kthread_run(mgc_requeue_thread, NULL,
-					     "ll_cfg_requeue"));
-		if (IS_ERR_VALUE(rc)) {
-			CERROR("%s: Cannot start requeue thread (%d),no more log updates!\n",
+		task = kthread_run(mgc_requeue_thread, NULL, "ll_cfg_requeue");
+		if (IS_ERR(task)) {
+			rc = PTR_ERR(task);
+			CERROR("%s: cannot start requeue thread: rc = %d; no more log updates\n",
 			       obd->obd_name, rc);
 			goto err_cleanup;
 		}
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 7cb55ef..741c258 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -376,17 +376,19 @@ int llog_process_or_fork(const struct lu_env *env,
 	lpi->lpi_catdata   = catdata;
 
 	if (fork) {
+		struct task_struct *task;
+
 		/* The new thread can't use parent env,
 		 * init the new one in llog_process_thread_daemonize. */
 		lpi->lpi_env = NULL;
 		init_completion(&lpi->lpi_completion);
-		rc = PTR_ERR(kthread_run(llog_process_thread_daemonize, lpi,
-					     "llog_process_thread"));
-		if (IS_ERR_VALUE(rc)) {
+		task = kthread_run(llog_process_thread_daemonize, lpi,
+				   "llog_process_thread");
+		if (IS_ERR(task)) {
+			rc = PTR_ERR(task);
 			CERROR("%s: cannot start thread: rc = %d\n",
 			       loghandle->lgh_ctxt->loc_obd->obd_name, rc);
-			kfree(lpi);
-			return rc;
+			goto out_lpi;
 		}
 		wait_for_completion(&lpi->lpi_completion);
 	} else {
@@ -394,6 +396,7 @@ int llog_process_or_fork(const struct lu_env *env,
 		llog_process_thread(lpi);
 	}
 	rc = lpi->lpi_rc;
+out_lpi:
 	kfree(lpi);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 5c719f1..a94265a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -293,6 +293,7 @@ static struct ptlrpc_thread pinger_thread;
 int ptlrpc_start_pinger(void)
 {
 	struct l_wait_info lwi = { 0 };
+	struct task_struct *task;
 	int rc;
 
 	if (!thread_is_init(&pinger_thread) &&
@@ -303,10 +304,11 @@ int ptlrpc_start_pinger(void)
 
 	strcpy(pinger_thread.t_name, "ll_ping");
 
-	rc = PTR_ERR(kthread_run(ptlrpc_pinger_main, &pinger_thread,
-				 "%s", pinger_thread.t_name));
-	if (IS_ERR_VALUE(rc)) {
-		CERROR("cannot start thread: %d\n", rc);
+	task = kthread_run(ptlrpc_pinger_main, &pinger_thread,
+			   pinger_thread.t_name);
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
+		CERROR("cannot start pinger thread: rc = %d\n", rc);
 		return rc;
 	}
 	l_wait_event(pinger_thread.t_ctl_waitq,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index f45898f..5d02055 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2255,24 +2255,27 @@ static int ptlrpc_start_hr_threads(void)
 
 		for (j = 0; j < hrp->hrp_nthrs; j++) {
 			struct	ptlrpc_hr_thread *hrt = &hrp->hrp_thrs[j];
+			struct task_struct *task;
 
-			rc = PTR_ERR(kthread_run(ptlrpc_hr_main,
+			task = kthread_run(ptlrpc_hr_main,
 						 &hrp->hrp_thrs[j],
 						 "ptlrpc_hr%02d_%03d",
 						 hrp->hrp_cpt,
-						 hrt->hrt_id));
-			if (IS_ERR_VALUE(rc))
+						 hrt->hrt_id);
+			if (IS_ERR(task)) {
+				rc = PTR_ERR(task);
 				break;
+			}
 		}
 		wait_event(ptlrpc_hr.hr_waitq,
 			       atomic_read(&hrp->hrp_nstarted) == j);
-		if (!IS_ERR_VALUE(rc))
-			continue;
 
-		CERROR("Reply handling thread %d:%d Failed on starting: rc = %d\n",
-		       i, j, rc);
-		ptlrpc_stop_hr_threads();
-		return rc;
+		if (rc < 0) {
+			CERROR("cannot start reply handler thread %d:%d: rc = %d\n",
+			       i, j, rc);
+			ptlrpc_stop_hr_threads();
+			return rc;
+		}
 	}
 	return 0;
 }
@@ -2374,6 +2377,7 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	struct l_wait_info lwi = { 0 };
 	struct ptlrpc_thread *thread;
 	struct ptlrpc_service *svc;
+	struct task_struct *task;
 	int rc;
 
 	LASSERT(svcpt != NULL);
@@ -2442,9 +2446,10 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	}
 
 	CDEBUG(D_RPCTRACE, "starting thread '%s'\n", thread->t_name);
-	rc = PTR_ERR(kthread_run(ptlrpc_main, thread, "%s", thread->t_name));
-	if (IS_ERR_VALUE(rc)) {
-		CERROR("cannot start thread '%s': rc %d\n",
+	task = kthread_run(ptlrpc_main, thread, "%s", thread->t_name);
+	if (IS_ERR(task)) {
+		rc = PTR_ERR(task);
+		CERROR("cannot start thread '%s': rc = %d\n",
 		       thread->t_name, rc);
 		spin_lock(&svcpt->scp_lock);
 		--svcpt->scp_nthrs_starting;
-- 
1.7.1
