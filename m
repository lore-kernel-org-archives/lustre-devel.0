From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Jan 2018 14:28:13 +1100
Subject: [lustre-devel] [PATCH 05/19] staging: lustre: use
 wait_event_idle_timeout() where appropriate.
In-Reply-To: <151538168618.23920.8261096424342988792.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
Message-ID: <151538209348.23920.11616107274431655046.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

When the lwi arg has a timeout, but no timeout
callback function, l_wait_event() acts much the same as
wait_event_idle_timeout() - the wait is not interruptible and
simply waits for the event or the timeouts.

The most noticable difference is that the return value is
-ETIMEDOUT or 0, rather than 0 or non-zero.

Another difference is that if the timeout is zero, l_wait_event()
will not time out at all.  In the one case where that is possible
we need to conditionally use wait_event_idle().

So replace all such calls with wait_event_idle_timeout(), being
careful of the return value.

In one case, there is no event expected, only the timeout
is needed.  So use schedule_timeout_uninterruptible().

Note that the presence or absence of LWI_ON_SIGNAL_NOOP
has no effect in these cases.  It only has effect if the timeout
callback is non-NULL, or the timeout is zero, or
LWI_TIMEOUT_INTR_ALL() is used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   10 ++------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   12 +++-------
 drivers/staging/lustre/lustre/llite/statahead.c    |   14 ++++-------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    5 +---
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   15 +++++-------
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   17 ++++++++------
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   25 ++++++++++----------
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    7 +-----
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   12 ++++------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    9 +++----
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   12 +++-------
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   12 ++++------
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   10 ++------
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   11 ++++-----
 14 files changed, 68 insertions(+), 103 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 773abe78708a..95bea351d21d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1349,7 +1349,6 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 		if ((flags & LDLM_FL_LVB_READY) && !ldlm_is_lvb_ready(lock)) {
 			__u64 wait_flags = LDLM_FL_LVB_READY |
 				LDLM_FL_DESTROYED | LDLM_FL_FAIL_NOTIFIED;
-			struct l_wait_info lwi;
 
 			if (lock->l_completion_ast) {
 				int err = lock->l_completion_ast(lock,
@@ -1366,13 +1365,10 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 				}
 			}
 
-			lwi = LWI_TIMEOUT_INTR(obd_timeout * HZ,
-					       NULL, LWI_ON_SIGNAL_NOOP, NULL);
-
 			/* XXX FIXME see comment on CAN_MATCH in lustre_dlm.h */
-			l_wait_event(lock->l_waitq,
-				     lock->l_flags & wait_flags,
-				     &lwi);
+			wait_event_idle_timeout(lock->l_waitq,
+						lock->l_flags & wait_flags,
+						obd_timeout * HZ);
 			if (!ldlm_is_lvb_ready(lock)) {
 				if (flags & LDLM_FL_TEST_LOCK)
 					LDLM_LOCK_RELEASE(lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 622245a5f049..a0e486b57e08 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -997,8 +997,6 @@ static int ldlm_pools_thread_main(void *arg)
 	       "ldlm_poold", current_pid());
 
 	while (1) {
-		struct l_wait_info lwi;
-
 		/*
 		 * Recal all pools on this tick.
 		 */
@@ -1008,12 +1006,10 @@ static int ldlm_pools_thread_main(void *arg)
 		 * Wait until the next check time, or until we're
 		 * stopped.
 		 */
-		lwi = LWI_TIMEOUT(c_time * HZ,
-				  NULL, NULL);
-		l_wait_event(thread->t_ctl_waitq,
-			     thread_is_stopping(thread) ||
-			     thread_is_event(thread),
-			     &lwi);
+		wait_event_idle_timeout(thread->t_ctl_waitq,
+					thread_is_stopping(thread) ||
+					thread_is_event(thread),
+					c_time * HZ);
 
 		if (thread_test_and_clear_flags(thread, SVC_STOPPING))
 			break;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 96360f104b92..6052bfd7ff05 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1151,10 +1151,9 @@ static int ll_statahead_thread(void *arg)
 	 */
 	while (sai->sai_sent != sai->sai_replied) {
 		/* in case we're not woken up, timeout wait */
-		struct l_wait_info lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
-						     NULL, NULL);
-		l_wait_event(sa_thread->t_ctl_waitq,
-			     sai->sai_sent == sai->sai_replied, &lwi);
+		wait_event_idle_timeout(sa_thread->t_ctl_waitq,
+					sai->sai_sent == sai->sai_replied,
+					HZ>>3);
 	}
 
 	/* release resources held by statahead RPCs */
@@ -1374,7 +1373,6 @@ static int revalidate_statahead_dentry(struct inode *dir,
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct sa_entry *entry = NULL;
-	struct l_wait_info lwi = { 0 };
 	struct ll_dentry_data *ldd;
 	int rc = 0;
 
@@ -1424,10 +1422,8 @@ static int revalidate_statahead_dentry(struct inode *dir,
 		spin_lock(&lli->lli_sa_lock);
 		sai->sai_index_wait = entry->se_index;
 		spin_unlock(&lli->lli_sa_lock);
-		lwi = LWI_TIMEOUT_INTR(30 * HZ, NULL,
-				       LWI_ON_SIGNAL_NOOP, NULL);
-		rc = l_wait_event(sai->sai_waitq, sa_ready(entry), &lwi);
-		if (rc < 0) {
+		if (0 == wait_event_idle_timeout(sai->sai_waitq,
+						 sa_ready(entry), 30 * HZ)) {
 			/*
 			 * entry may not be ready, so it may be used by inflight
 			 * statahead RPC, don't free it.
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index b12518ba5ae9..ab48746ce433 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -838,7 +838,6 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 	struct ptlrpc_bulk_desc *desc;
 	struct ptlrpc_request *req;
 	wait_queue_head_t waitq;
-	struct l_wait_info lwi;
 	int resends = 0;
 	int rc;
 	int i;
@@ -888,9 +887,7 @@ static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 			       exp->exp_obd->obd_name, -EIO);
 			return -EIO;
 		}
-		lwi = LWI_TIMEOUT_INTR(resends * HZ, NULL, NULL,
-				       NULL);
-		l_wait_event(waitq, 0, &lwi);
+		wait_event_idle_timeout(waitq, 0, resends * HZ);
 
 		goto restart_bulk;
 	}
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index a01d13bde102..c61cd23a96df 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -535,7 +535,6 @@ static int mgc_requeue_thread(void *data)
 	spin_lock(&config_list_lock);
 	rq_state |= RQ_RUNNING;
 	while (!(rq_state & RQ_STOP)) {
-		struct l_wait_info lwi;
 		struct config_llog_data *cld, *cld_prev;
 		int rand = prandom_u32_max(MGC_TIMEOUT_RAND_CENTISEC);
 		int to;
@@ -556,9 +555,9 @@ static int mgc_requeue_thread(void *data)
 		to = msecs_to_jiffies(MGC_TIMEOUT_MIN_SECONDS * MSEC_PER_SEC);
 		/* rand is centi-seconds */
 		to += msecs_to_jiffies(rand * MSEC_PER_SEC / 100);
-		lwi = LWI_TIMEOUT(to, NULL, NULL);
-		l_wait_event(rq_waitq, rq_state & (RQ_STOP | RQ_PRECLEANUP),
-			     &lwi);
+		wait_event_idle_timeout(rq_waitq,
+					rq_state & (RQ_STOP | RQ_PRECLEANUP),
+					to);
 
 		/*
 		 * iterate & processing through the list. for each cld, process
@@ -1628,9 +1627,7 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 
 		if (rcl == -ESHUTDOWN &&
 		    atomic_read(&mgc->u.cli.cl_mgc_refcount) > 0 && !retry) {
-			int secs = obd_timeout * HZ;
 			struct obd_import *imp;
-			struct l_wait_info lwi;
 
 			mutex_unlock(&cld->cld_lock);
 			imp = class_exp2cliimp(mgc->u.cli.cl_mgc_mgsexp);
@@ -1645,9 +1642,9 @@ int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 			 */
 			ptlrpc_pinger_force(imp);
 
-			lwi = LWI_TIMEOUT(secs, NULL, NULL);
-			l_wait_event(imp->imp_recovery_waitq,
-				     !mgc_import_in_recovery(imp), &lwi);
+			wait_event_idle_timeout(imp->imp_recovery_waitq,
+						!mgc_import_in_recovery(imp),
+						obd_timeout * HZ);
 
 			if (imp->imp_state == LUSTRE_IMP_FULL) {
 				retry = true;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index ce5e7bdda692..ab84e011b560 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1097,16 +1097,19 @@ EXPORT_SYMBOL(cl_sync_io_init);
 int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		    long timeout)
 {
-	struct l_wait_info lwi = LWI_TIMEOUT_INTR(timeout * HZ,
-						  NULL, NULL, NULL);
-	int rc;
+	int rc = 1;
 
 	LASSERT(timeout >= 0);
 
-	rc = l_wait_event(anchor->csi_waitq,
-			  atomic_read(&anchor->csi_sync_nr) == 0,
-			  &lwi);
-	if (rc < 0) {
+	if (timeout == 0)
+		wait_event_idle(anchor->csi_waitq,
+				atomic_read(&anchor->csi_sync_nr) == 0);
+	else
+		rc = wait_event_idle_timeout(anchor->csi_waitq,
+					     atomic_read(&anchor->csi_sync_nr) == 0,
+					     timeout * HZ);
+	if (rc == 0) {
+		rc = -ETIMEDOUT;
 		CERROR("IO failed: %d, still wait for %d remaining entries\n",
 		       rc, atomic_read(&anchor->csi_sync_nr));
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 0797e671f667..dacfab12c501 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -934,8 +934,6 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 			   enum osc_extent_state state)
 {
 	struct osc_object *obj = ext->oe_obj;
-	struct l_wait_info lwi = LWI_TIMEOUT_INTR(600 * HZ, NULL,
-						  LWI_ON_SIGNAL_NOOP, NULL);
 	int rc = 0;
 
 	osc_object_lock(obj);
@@ -958,17 +956,19 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 		osc_extent_release(env, ext);
 
 	/* wait for the extent until its state becomes @state */
-	rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state), &lwi);
-	if (rc == -ETIMEDOUT) {
+	rc = wait_event_idle_timeout(ext->oe_waitq,
+				     extent_wait_cb(ext, state), 600 * HZ);
+	if (rc == 0) {
 		OSC_EXTENT_DUMP(D_ERROR, ext,
 				"%s: wait ext to %u timedout, recovery in progress?\n",
 				cli_name(osc_cli(obj)), state);
 
 		wait_event_idle(ext->oe_waitq, extent_wait_cb(ext, state));
-		rc = 0;
 	}
-	if (rc == 0 && ext->oe_rc < 0)
+	if (ext->oe_rc < 0)
 		rc = ext->oe_rc;
+	else
+		rc = 0;
 	return rc;
 }
 
@@ -1568,12 +1568,9 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	struct osc_object *osc = oap->oap_obj;
 	struct lov_oinfo *loi = osc->oo_oinfo;
 	struct osc_cache_waiter ocw;
-	struct l_wait_info lwi;
+	unsigned long timeout = (AT_OFF ? obd_timeout : at_max) * HZ;
 	int rc = -EDQUOT;
 
-	lwi = LWI_TIMEOUT_INTR((AT_OFF ? obd_timeout : at_max) * HZ,
-			       NULL, LWI_ON_SIGNAL_NOOP, NULL);
-
 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
 	spin_lock(&cli->cl_loi_list_lock);
@@ -1616,13 +1613,15 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		CDEBUG(D_CACHE, "%s: sleeping for cache space @ %p for %p\n",
 		       cli_name(cli), &ocw, oap);
 
-		rc = l_wait_event(ocw.ocw_waitq, ocw_granted(cli, &ocw), &lwi);
+		rc = wait_event_idle_timeout(ocw.ocw_waitq,
+					     ocw_granted(cli, &ocw), timeout);
 
 		spin_lock(&cli->cl_loi_list_lock);
 
-		if (rc < 0) {
-			/* l_wait_event is interrupted by signal, or timed out */
+		if (rc == 0) {
+			/* wait_event is interrupted by signal, or timed out */
 			list_del_init(&ocw.ocw_entry);
+			rc = -ETIMEDOUT;
 			break;
 		}
 		LASSERT(list_empty(&ocw.ocw_entry));
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 71f7588570ef..130bacc2c891 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -490,8 +490,6 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 
 static void ptlrpc_ni_fini(void)
 {
-	wait_queue_head_t waitq;
-	struct l_wait_info lwi;
 	int rc;
 	int retries;
 
@@ -515,10 +513,7 @@ static void ptlrpc_ni_fini(void)
 			if (retries != 0)
 				CWARN("Event queue still busy\n");
 
-			/* Wait for a bit */
-			init_waitqueue_head(&waitq);
-			lwi = LWI_TIMEOUT(2 * HZ, NULL, NULL);
-			l_wait_event(waitq, 0, &lwi);
+			schedule_timeout_uninterruptible(2 * HZ);
 			break;
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 0eba5f18bd3b..ed210550f61f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -430,21 +430,19 @@ void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt)
 
 int ptlrpc_reconnect_import(struct obd_import *imp)
 {
-	struct l_wait_info lwi;
-	int secs = obd_timeout * HZ;
 	int rc;
 
 	ptlrpc_pinger_force(imp);
 
 	CDEBUG(D_HA, "%s: recovery started, waiting %u seconds\n",
-	       obd2cli_tgt(imp->imp_obd), secs);
+	       obd2cli_tgt(imp->imp_obd), obd_timeout);
 
-	lwi = LWI_TIMEOUT(secs, NULL, NULL);
-	rc = l_wait_event(imp->imp_recovery_waitq,
-			  !ptlrpc_import_in_recovery(imp), &lwi);
+	rc = wait_event_idle_timeout(imp->imp_recovery_waitq,
+				     !ptlrpc_import_in_recovery(imp),
+				     obd_timeout * HZ);
 	CDEBUG(D_HA, "%s: recovery finished s:%s\n", obd2cli_tgt(imp->imp_obd),
 	       ptlrpc_import_state_name(imp->imp_state));
-	return rc;
+	return rc == 0 ? -ETIMEDOUT : 0;
 }
 EXPORT_SYMBOL(ptlrpc_reconnect_import);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index c060d6f5015a..f73463ac401f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -260,17 +260,16 @@ lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt)
 
 	/* See if we have anything in a pool, and wait if nothing */
 	while (list_empty(&svcpt->scp_rep_idle)) {
-		struct l_wait_info lwi;
 		int rc;
 
 		spin_unlock(&svcpt->scp_rep_lock);
 		/* If we cannot get anything for some long time, we better
 		 * bail out instead of waiting infinitely
 		 */
-		lwi = LWI_TIMEOUT(10 * HZ, NULL, NULL);
-		rc = l_wait_event(svcpt->scp_rep_waitq,
-				  !list_empty(&svcpt->scp_rep_idle), &lwi);
-		if (rc != 0)
+		rc = wait_event_idle_timeout(svcpt->scp_rep_waitq,
+					     !list_empty(&svcpt->scp_rep_idle),
+					     10 * HZ);
+		if (rc == 0)
 			goto out;
 		spin_lock(&svcpt->scp_rep_lock);
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 010a1cdf05fa..639070f6e68e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -228,7 +228,6 @@ static int ptlrpc_pinger_main(void *arg)
 	/* And now, loop forever, pinging as needed. */
 	while (1) {
 		unsigned long this_ping = cfs_time_current();
-		struct l_wait_info lwi;
 		long time_to_next_wake;
 		struct timeout_item *item;
 		struct list_head *iter;
@@ -266,13 +265,10 @@ static int ptlrpc_pinger_main(void *arg)
 		       cfs_time_add(this_ping,
 				    PING_INTERVAL * HZ));
 		if (time_to_next_wake > 0) {
-			lwi = LWI_TIMEOUT(max_t(long, time_to_next_wake,
-						HZ),
-					  NULL, NULL);
-			l_wait_event(thread->t_ctl_waitq,
-				     thread_is_stopping(thread) ||
-				     thread_is_event(thread),
-				     &lwi);
+			wait_event_idle_timeout(thread->t_ctl_waitq,
+						thread_is_stopping(thread) ||
+						thread_is_event(thread),
+						max_t(long, time_to_next_wake, HZ));
 			if (thread_test_and_clear_flags(thread, SVC_STOPPING))
 				break;
 			/* woken after adding import to reset timer */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 5bbd23eebfa6..7b5f2429d144 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -346,17 +346,15 @@ int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async)
 		goto out;
 
 	if (!async) {
-		struct l_wait_info lwi;
-		int secs = obd_timeout * HZ;
-
 		CDEBUG(D_HA, "%s: recovery started, waiting %u seconds\n",
-		       obd2cli_tgt(imp->imp_obd), secs);
+		       obd2cli_tgt(imp->imp_obd), obd_timeout);
 
-		lwi = LWI_TIMEOUT(secs, NULL, NULL);
-		rc = l_wait_event(imp->imp_recovery_waitq,
-				  !ptlrpc_import_in_recovery(imp), &lwi);
+		rc = wait_event_idle_timeout(imp->imp_recovery_waitq,
+					     !ptlrpc_import_in_recovery(imp),
+					     obd_timeout * HZ);
 		CDEBUG(D_HA, "%s: recovery finished\n",
 		       obd2cli_tgt(imp->imp_obd));
+		rc = rc? 0 : -ETIMEDOUT;
 	}
 
 out:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index b61e1aa25e8c..48f1a72afd77 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -142,7 +142,6 @@ static void sec_do_gc(struct ptlrpc_sec *sec)
 static int sec_gc_main(void *arg)
 {
 	struct ptlrpc_thread *thread = arg;
-	struct l_wait_info lwi;
 
 	unshare_fs_struct();
 
@@ -179,12 +178,9 @@ static int sec_gc_main(void *arg)
 
 		/* check ctx list again before sleep */
 		sec_process_ctx_list();
-
-		lwi = LWI_TIMEOUT(msecs_to_jiffies(SEC_GC_INTERVAL * MSEC_PER_SEC),
-				  NULL, NULL);
-		l_wait_event(thread->t_ctl_waitq,
-			     thread_is_stopping(thread),
-			     &lwi);
+		wait_event_idle_timeout(thread->t_ctl_waitq,
+					thread_is_stopping(thread),
+					SEC_GC_INTERVAL * HZ);
 
 		if (thread_test_and_clear_flags(thread, SVC_STOPPING))
 			break;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 6d4229ebc9d9..5c41297d23d2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2588,13 +2588,12 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 {
 	while (1) {
 		int rc;
-		struct l_wait_info lwi = LWI_TIMEOUT(10 * HZ,
-						     NULL, NULL);
 
-		rc = l_wait_event(svcpt->scp_waitq,
-				  atomic_read(&svcpt->scp_nreps_difficult) == 0,
-				  &lwi);
-		if (rc == 0)
+		rc = wait_event_idle_timeout(
+			svcpt->scp_waitq,
+			atomic_read(&svcpt->scp_nreps_difficult) == 0,
+			10 * HZ);
+		if (rc > 0)
 			break;
 		CWARN("Unexpectedly long timeout %s %p\n",
 		      svcpt->scp_service->srv_name, svcpt->scp_service);
