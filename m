From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Jan 2018 14:28:13 +1100
Subject: [lustre-devel] [PATCH 03/19] staging: lustre: replace simple cases
 of l_wait_event() with wait_event().
In-Reply-To: <151538168618.23920.8261096424342988792.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
Message-ID: <151538209336.23920.11626260931049480889.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

When the lwi arg is full of zeros, l_wait_event() behaves almost
identically to the standard wait_event_idle() interface, so use that
instead.

l_wait_event() uses TASK_INTERRUPTIBLE, but blocks all signals.
wait_event_idle() uses the new TASK_IDLE and so avoids adding
to the load average without needing to block signals.

In one case, wait_event_idle_exclusive() is needed.

Also remove all l_wait_condition*() macros which were short-cuts
for setting lwi to {0}.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h |   19 --------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    4 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    8 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    5 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   50 ++++++++------------
 drivers/staging/lustre/lustre/lov/lov_object.c     |    6 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    4 --
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    6 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |   15 ++----
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    5 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    4 --
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   10 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   11 ++--
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   13 ++---
 14 files changed, 53 insertions(+), 107 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index ca1dce15337e..7d950c53e962 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -333,24 +333,7 @@ do {									   \
 	__ret;						  \
 })
 
-#define l_wait_condition(wq, condition)			 \
-({							      \
-	struct l_wait_info lwi = { 0 };			 \
-	l_wait_event(wq, condition, &lwi);		      \
-})
-
-#define l_wait_condition_exclusive(wq, condition)	       \
-({							      \
-	struct l_wait_info lwi = { 0 };			 \
-	l_wait_event_exclusive(wq, condition, &lwi);	    \
-})
-
-#define l_wait_condition_exclusive_head(wq, condition)	  \
-({							      \
-	struct l_wait_info lwi = { 0 };			 \
-	l_wait_event_exclusive_head(wq, condition, &lwi);       \
-})
-
 /** @} lib */
 
+
 #endif /* _LUSTRE_LIB_H */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 7cbc6a06afec..4f700ddb47c6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1913,14 +1913,12 @@ void ldlm_cancel_callback(struct ldlm_lock *lock)
 		ldlm_set_bl_done(lock);
 		wake_up_all(&lock->l_waitq);
 	} else if (!ldlm_is_bl_done(lock)) {
-		struct l_wait_info lwi = { 0 };
-
 		/*
 		 * The lock is guaranteed to have been canceled once
 		 * returning from this function.
 		 */
 		unlock_res_and_lock(lock);
-		l_wait_event(lock->l_waitq, is_bl_done(lock), &lwi);
+		wait_event_idle(lock->l_waitq, is_bl_done(lock));
 		lock_res_and_lock(lock);
 	}
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 5f6e7c933b81..6c7c4b19a0a0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -833,17 +833,15 @@ static int ldlm_bl_thread_main(void *arg)
 	/* cannot use bltd after this, it is only on caller's stack */
 
 	while (1) {
-		struct l_wait_info lwi = { 0 };
 		struct ldlm_bl_work_item *blwi = NULL;
 		struct obd_export *exp = NULL;
 		int rc;
 
 		rc = ldlm_bl_get_work(blp, &blwi, &exp);
 		if (!rc)
-			l_wait_event_exclusive(blp->blp_waitq,
-					       ldlm_bl_get_work(blp, &blwi,
-								&exp),
-					       &lwi);
+			wait_event_idle_exclusive(blp->blp_waitq,
+						  ldlm_bl_get_work(blp, &blwi,
+								   &exp));
 		atomic_inc(&blp->blp_busy_threads);
 
 		if (ldlm_bl_thread_need_create(blp, blwi))
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 8563bd32befa..f27c2694793a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -1031,7 +1031,6 @@ static int ldlm_pools_thread_main(void *arg)
 
 static int ldlm_pools_thread_start(void)
 {
-	struct l_wait_info lwi = { 0 };
 	struct task_struct *task;
 
 	if (ldlm_pools_thread)
@@ -1052,8 +1051,8 @@ static int ldlm_pools_thread_start(void)
 		ldlm_pools_thread = NULL;
 		return PTR_ERR(task);
 	}
-	l_wait_event(ldlm_pools_thread->t_ctl_waitq,
-		     thread_is_running(ldlm_pools_thread), &lwi);
+	wait_event_idle(ldlm_pools_thread->t_ctl_waitq,
+			thread_is_running(ldlm_pools_thread));
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 90c7324575e4..78005cc6e831 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -864,7 +864,6 @@ static int ll_agl_thread(void *arg)
 	struct ll_sb_info	*sbi    = ll_i2sbi(dir);
 	struct ll_statahead_info *sai;
 	struct ptlrpc_thread *thread;
-	struct l_wait_info	lwi    = { 0 };
 
 	sai = ll_sai_get(dir);
 	thread = &sai->sai_agl_thread;
@@ -885,10 +884,9 @@ static int ll_agl_thread(void *arg)
 	wake_up(&thread->t_ctl_waitq);
 
 	while (1) {
-		l_wait_event(thread->t_ctl_waitq,
-			     !list_empty(&sai->sai_agls) ||
-			     !thread_is_running(thread),
-			     &lwi);
+		wait_event_idle(thread->t_ctl_waitq,
+				!list_empty(&sai->sai_agls) ||
+				!thread_is_running(thread));
 
 		if (!thread_is_running(thread))
 			break;
@@ -932,7 +930,6 @@ static int ll_agl_thread(void *arg)
 static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 {
 	struct ptlrpc_thread *thread = &sai->sai_agl_thread;
-	struct l_wait_info    lwi    = { 0 };
 	struct ll_inode_info  *plli;
 	struct task_struct *task;
 
@@ -948,9 +945,8 @@ static void ll_start_agl(struct dentry *parent, struct ll_statahead_info *sai)
 		return;
 	}
 
-	l_wait_event(thread->t_ctl_waitq,
-		     thread_is_running(thread) || thread_is_stopped(thread),
-		     &lwi);
+	wait_event_idle(thread->t_ctl_waitq,
+			thread_is_running(thread) || thread_is_stopped(thread));
 }
 
 /* statahead thread main function */
@@ -968,7 +964,6 @@ static int ll_statahead_thread(void *arg)
 	int		       first  = 0;
 	int		       rc     = 0;
 	struct md_op_data *op_data;
-	struct l_wait_info	lwi    = { 0 };
 
 	sai = ll_sai_get(dir);
 	sa_thread = &sai->sai_thread;
@@ -1069,12 +1064,11 @@ static int ll_statahead_thread(void *arg)
 
 			/* wait for spare statahead window */
 			do {
-				l_wait_event(sa_thread->t_ctl_waitq,
-					     !sa_sent_full(sai) ||
-					     sa_has_callback(sai) ||
-					     !list_empty(&sai->sai_agls) ||
-					     !thread_is_running(sa_thread),
-					     &lwi);
+				wait_event_idle(sa_thread->t_ctl_waitq,
+						!sa_sent_full(sai) ||
+						sa_has_callback(sai) ||
+						!list_empty(&sai->sai_agls) ||
+						!thread_is_running(sa_thread));
 				sa_handle_callback(sai);
 
 				spin_lock(&lli->lli_agl_lock);
@@ -1128,11 +1122,10 @@ static int ll_statahead_thread(void *arg)
 	 * for file release to stop me.
 	 */
 	while (thread_is_running(sa_thread)) {
-		l_wait_event(sa_thread->t_ctl_waitq,
-			     sa_has_callback(sai) ||
-			     !agl_list_empty(sai) ||
-			     !thread_is_running(sa_thread),
-			     &lwi);
+		wait_event_idle(sa_thread->t_ctl_waitq,
+				sa_has_callback(sai) ||
+				!agl_list_empty(sai) ||
+				!thread_is_running(sa_thread));
 
 		sa_handle_callback(sai);
 	}
@@ -1145,9 +1138,8 @@ static int ll_statahead_thread(void *arg)
 
 		CDEBUG(D_READA, "stop agl thread: sai %p pid %u\n",
 		       sai, (unsigned int)agl_thread->t_pid);
-		l_wait_event(agl_thread->t_ctl_waitq,
-			     thread_is_stopped(agl_thread),
-			     &lwi);
+		wait_event_idle(agl_thread->t_ctl_waitq,
+				thread_is_stopped(agl_thread));
 	} else {
 		/* Set agl_thread flags anyway. */
 		thread_set_flags(agl_thread, SVC_STOPPED);
@@ -1159,8 +1151,8 @@ static int ll_statahead_thread(void *arg)
 	 */
 	while (sai->sai_sent != sai->sai_replied) {
 		/* in case we're not woken up, timeout wait */
-		lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
-				  NULL, NULL);
+		struct l_wait_info lwi = LWI_TIMEOUT(msecs_to_jiffies(MSEC_PER_SEC >> 3),
+						     NULL, NULL);
 		l_wait_event(sa_thread->t_ctl_waitq,
 			     sai->sai_sent == sai->sai_replied, &lwi);
 	}
@@ -1520,7 +1512,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 {
 	struct ll_inode_info *lli = ll_i2info(dir);
 	struct ll_statahead_info *sai = NULL;
-	struct l_wait_info lwi = { 0 };
 	struct ptlrpc_thread *thread;
 	struct task_struct *task;
 	struct dentry *parent = dentry->d_parent;
@@ -1570,9 +1561,8 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 		goto out;
 	}
 
-	l_wait_event(thread->t_ctl_waitq,
-		     thread_is_running(thread) || thread_is_stopped(thread),
-		     &lwi);
+	wait_event_idle(thread->t_ctl_waitq,
+			thread_is_running(thread) || thread_is_stopped(thread));
 	ll_sai_put(sai);
 
 	/*
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 897cf2cd4a24..86cd4f9fbd0c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -723,15 +723,13 @@ static void lov_conf_unlock(struct lov_object *lov)
 
 static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov)
 {
-	struct l_wait_info lwi = { 0 };
-
 	while (atomic_read(&lov->lo_active_ios) > 0) {
 		CDEBUG(D_INODE, "file:" DFID " wait for active IO, now: %d.\n",
 		       PFID(lu_object_fid(lov2lu(lov))),
 		       atomic_read(&lov->lo_active_ios));
 
-		l_wait_event(lov->lo_waitq,
-			     atomic_read(&lov->lo_active_ios) == 0, &lwi);
+		wait_event_idle(lov->lo_waitq,
+				atomic_read(&lov->lo_active_ios) == 0);
 	}
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 79ff85feab64..b743aee62349 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -601,9 +601,7 @@ static int mgc_requeue_thread(void *data)
 			config_log_put(cld_prev);
 
 		/* Wait a bit to see if anyone else needs a requeue */
-		lwi = (struct l_wait_info) { 0 };
-		l_wait_event(rq_waitq, rq_state & (RQ_NOW | RQ_STOP),
-			     &lwi);
+		wait_event_idle(rq_waitq, rq_state & (RQ_NOW | RQ_STOP));
 		spin_lock(&config_list_lock);
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 6ec5218a18c1..902bad22013b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -1110,10 +1110,8 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		CERROR("IO failed: %d, still wait for %d remaining entries\n",
 		       rc, atomic_read(&anchor->csi_sync_nr));
 
-		lwi = (struct l_wait_info) { 0 };
-		(void)l_wait_event(anchor->csi_waitq,
-				   atomic_read(&anchor->csi_sync_nr) == 0,
-				   &lwi);
+		wait_event_idle(anchor->csi_waitq,
+				atomic_read(&anchor->csi_sync_nr) == 0);
 	} else {
 		rc = anchor->csi_sync_rc;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index b1d6ba4a3190..3ff25b8d3b48 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1237,12 +1237,10 @@ static int obd_zombie_is_idle(void)
  */
 void obd_zombie_barrier(void)
 {
-	struct l_wait_info lwi = { 0 };
-
 	if (obd_zombie_pid == current_pid())
 		/* don't wait for myself */
 		return;
-	l_wait_event(obd_zombie_waitq, obd_zombie_is_idle(), &lwi);
+	wait_event_idle(obd_zombie_waitq, obd_zombie_is_idle());
 }
 EXPORT_SYMBOL(obd_zombie_barrier);
 
@@ -1257,10 +1255,8 @@ static int obd_zombie_impexp_thread(void *unused)
 	obd_zombie_pid = current_pid();
 
 	while (!test_bit(OBD_ZOMBIE_STOP, &obd_zombie_flags)) {
-		struct l_wait_info lwi = { 0 };
-
-		l_wait_event(obd_zombie_waitq,
-			     !obd_zombie_impexp_check(NULL), &lwi);
+		wait_event_idle(obd_zombie_waitq,
+				!obd_zombie_impexp_check(NULL));
 		obd_zombie_impexp_cull();
 
 		/*
@@ -1593,7 +1589,6 @@ static inline bool obd_mod_rpc_slot_avail(struct client_obd *cli,
 u16 obd_get_mod_rpc_slot(struct client_obd *cli, __u32 opc,
 			 struct lookup_intent *it)
 {
-	struct l_wait_info lwi = LWI_INTR(NULL, NULL);
 	bool close_req = false;
 	u16 i, max;
 
@@ -1631,8 +1626,8 @@ u16 obd_get_mod_rpc_slot(struct client_obd *cli, __u32 opc,
 		CDEBUG(D_RPCTRACE, "%s: sleeping for a modify RPC slot opc %u, max %hu\n",
 		       cli->cl_import->imp_obd->obd_name, opc, max);
 
-		l_wait_event(cli->cl_mod_rpcs_waitq,
-			     obd_mod_rpc_slot_avail(cli, close_req), &lwi);
+		wait_event_idle(cli->cl_mod_rpcs_waitq,
+				obd_mod_rpc_slot_avail(cli, close_req));
 	} while (true);
 }
 EXPORT_SYMBOL(obd_get_mod_rpc_slot);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5767ac2a7d16..b8d5adca94e1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -964,9 +964,8 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 				"%s: wait ext to %u timedout, recovery in progress?\n",
 				cli_name(osc_cli(obj)), state);
 
-		lwi = LWI_INTR(NULL, NULL);
-		rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state),
-				  &lwi);
+		wait_event_idle(ext->oe_waitq, extent_wait_cb(ext, state));
+		rc = 0;
 	}
 	if (rc == 0 && ext->oe_rc < 0)
 		rc = ext->oe_rc;
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index f82c87a77550..6c424f0290bb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -454,12 +454,10 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 
 int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc)
 {
-	struct l_wait_info lwi = { 0 };
-
 	CDEBUG(D_INODE, "Invalidate osc object: %p, # of active IOs: %d\n",
 	       osc, atomic_read(&osc->oo_nr_ios));
 
-	l_wait_event(osc->oo_io_waitq, !atomic_read(&osc->oo_nr_ios), &lwi);
+	wait_event_idle(osc->oo_io_waitq, !atomic_read(&osc->oo_nr_ios));
 
 	/* Discard all dirty pages of this object. */
 	osc_cache_truncate_start(env, osc, 0, NULL);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index fe6b47bfe8be..af707cb2b62b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -291,7 +291,6 @@ static struct ptlrpc_thread pinger_thread;
 
 int ptlrpc_start_pinger(void)
 {
-	struct l_wait_info lwi = { 0 };
 	struct task_struct *task;
 	int rc;
 
@@ -310,8 +309,8 @@ int ptlrpc_start_pinger(void)
 		CERROR("cannot start pinger thread: rc = %d\n", rc);
 		return rc;
 	}
-	l_wait_event(pinger_thread.t_ctl_waitq,
-		     thread_is_running(&pinger_thread), &lwi);
+	wait_event_idle(pinger_thread.t_ctl_waitq,
+			thread_is_running(&pinger_thread));
 
 	return 0;
 }
@@ -320,7 +319,6 @@ static int ptlrpc_pinger_remove_timeouts(void);
 
 int ptlrpc_stop_pinger(void)
 {
-	struct l_wait_info lwi = { 0 };
 	int rc = 0;
 
 	if (thread_is_init(&pinger_thread) ||
@@ -331,8 +329,8 @@ int ptlrpc_stop_pinger(void)
 	thread_set_flags(&pinger_thread, SVC_STOPPING);
 	wake_up(&pinger_thread.t_ctl_waitq);
 
-	l_wait_event(pinger_thread.t_ctl_waitq,
-		     thread_is_stopped(&pinger_thread), &lwi);
+	wait_event_idle(pinger_thread.t_ctl_waitq,
+			thread_is_stopped(&pinger_thread));
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index d85c8638c009..b61e1aa25e8c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -197,7 +197,6 @@ static int sec_gc_main(void *arg)
 
 int sptlrpc_gc_init(void)
 {
-	struct l_wait_info lwi = { 0 };
 	struct task_struct *task;
 
 	mutex_init(&sec_gc_mutex);
@@ -214,18 +213,16 @@ int sptlrpc_gc_init(void)
 		return PTR_ERR(task);
 	}
 
-	l_wait_event(sec_gc_thread.t_ctl_waitq,
-		     thread_is_running(&sec_gc_thread), &lwi);
+	wait_event_idle(sec_gc_thread.t_ctl_waitq,
+			thread_is_running(&sec_gc_thread));
 	return 0;
 }
 
 void sptlrpc_gc_fini(void)
 {
-	struct l_wait_info lwi = { 0 };
-
 	thread_set_flags(&sec_gc_thread, SVC_STOPPING);
 	wake_up(&sec_gc_thread.t_ctl_waitq);
 
-	l_wait_event(sec_gc_thread.t_ctl_waitq,
-		     thread_is_stopped(&sec_gc_thread), &lwi);
+	wait_event_idle(sec_gc_thread.t_ctl_waitq,
+			thread_is_stopped(&sec_gc_thread));
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 63be6e7273f3..1f22926c1355 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2233,7 +2233,7 @@ static int ptlrpc_hr_main(void *arg)
 	wake_up(&ptlrpc_hr.hr_waitq);
 
 	while (!ptlrpc_hr.hr_stopping) {
-		l_wait_condition(hrt->hrt_waitq, hrt_dont_sleep(hrt, &replies));
+		wait_event_idle(hrt->hrt_waitq, hrt_dont_sleep(hrt, &replies));
 
 		while (!list_empty(&replies)) {
 			struct ptlrpc_reply_state *rs;
@@ -2312,7 +2312,6 @@ static int ptlrpc_start_hr_threads(void)
 
 static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 {
-	struct l_wait_info lwi = { 0 };
 	struct ptlrpc_thread *thread;
 	LIST_HEAD(zombie);
 
@@ -2341,8 +2340,8 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 
 		CDEBUG(D_INFO, "waiting for stopping-thread %s #%u\n",
 		       svcpt->scp_service->srv_thread_name, thread->t_id);
-		l_wait_event(thread->t_ctl_waitq,
-			     thread_is_stopped(thread), &lwi);
+		wait_event_idle(thread->t_ctl_waitq,
+				thread_is_stopped(thread));
 
 		spin_lock(&svcpt->scp_lock);
 	}
@@ -2403,7 +2402,6 @@ int ptlrpc_start_threads(struct ptlrpc_service *svc)
 
 int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 {
-	struct l_wait_info lwi = { 0 };
 	struct ptlrpc_thread *thread;
 	struct ptlrpc_service *svc;
 	struct task_struct *task;
@@ -2499,9 +2497,8 @@ int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 	if (!wait)
 		return 0;
 
-	l_wait_event(thread->t_ctl_waitq,
-		     thread_is_running(thread) || thread_is_stopped(thread),
-		     &lwi);
+	wait_event_idle(thread->t_ctl_waitq,
+			thread_is_running(thread) || thread_is_stopped(thread));
 
 	rc = thread_is_stopped(thread) ? thread->t_id : 0;
 	return rc;
