From: NeilBrown <neilb@suse.com>
Date: Mon, 06 Aug 2018 13:40:59 +1000
Subject: [lustre-devel] lustre: RFC patch to restore watchdog functionality
Message-ID: <87d0uwnovo.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Lustre in drivers/staging lost the watchdog functionality some time ago
Commit: 5d4450c41fe3 ("staging/lustre: fix build error on non-x86 platforms")

This is an attempt to provide the same core functionality in a simpler
way. It compiles, but I haven't tested it.

I don't plan to pursue this further at the moment, but as watchdogs have
been under discussion lately I thought it might be interesting to some.

NeilBrown


From: NeilBrown <neilb@suse.com>
Date: Mon, 6 Aug 2018 13:37:40 +1000
Subject: [PATCH] lustre: add watchdog for ptlrpc service threads.

If a ptlrpc thread takes longer than expected, it
can be used to get a stack trace to see where the
problem is.
This patch restores this functionality by using
a delayed work struct to report a back trace of
the thread if it ever fires.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 10 +--
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 87 ++++++++++++++++++----
 2 files changed, 76 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 361b8970368e..3eccec7c7dcc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1283,18 +1283,14 @@ struct ptlrpc_thread {
 	 */
 	unsigned int t_id;
 	/**
-	 * service thread pid
+	 * service thread
 	 */
+	struct task_struct *t_task;
 	pid_t t_pid;
 	/**
 	 * put watchdog in the structure per thread b=14840
-	 *
-	 * Lustre watchdog is removed for client in the hope
-	 * of a generic watchdog can be merged in kernel.
-	 * When that happens, we should add below back.
-	 *
-	 * struct lc_watchdog *t_watchdog;
 	 */
+	struct delayed_work t_watchdog;
 	/**
 	 * the svc this thread belonged to b=18582
 	 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 55f68b9b3818..4d508a691e89 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1949,6 +1949,73 @@ ptlrpc_at_check(struct ptlrpc_service_part *svcpt)
 	return svcpt->scp_at_check;
 }
 
+/*
+ * If a thread spends too long, we want to know about it,
+ * so we set up a delayed work item as a watchdog.
+ * If it fires, we display a stack trace of the delayed thread,
+ * providing we aren't rate-limited
+ */
+#ifdef CONFIG_STACKTRACE
+#define MAX_STACK_TRACE_DEPTH	64
+static void lc_watchdog_fire(struct work_struct *w)
+{
+	struct ptlrpc_thread *thread = container_of(w, struct ptlrpc_thread,
+						    t_watchdog.work);
+	struct stack_trace trace;
+	unsigned long *entries;
+	unsigned int i;
+	static DEFINE_RATELIMIT_STATE(_rs,
+				      DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
+
+	pr_emerg("ptlrpc thread %d blocked for too long\n", thread->t_pid);
+
+	if (!__ratelimit(&_rs))
+		return;
+
+	entries = kmalloc_array(MAX_STACK_TRACE_DEPTH, sizeof(*entries),
+				GFP_KERNEL);
+	if (!entries)
+		return;
+
+	trace.nr_entries	= 0;
+	trace.max_entries	= MAX_STACK_TRACE_DEPTH;
+	trace.entries		= entries;
+	trace.skip		= 0;
+
+	pr_warn("Stack trace of blocked thread\n");
+	save_stack_trace_tsk(thread->t_task, &trace);
+
+	for (i = 0; i < trace.nr_entries; i++)
+		pr_warn("[<0>] %pB\n", (void *)entries[i]);
+
+	kfree(entries);
+}
+#else
+static void lc_watchdog_fire(struct work_struct *w)
+{
+	struct ptlrpc_thread *thread = container_of(w, struct ptlrpc_thread,
+						    lc_watchdog.work);
+	pr_emerg("ptlrpc thread %d blocked for too long\n", thread->t_pid);
+
+}
+#endif
+
+static inline void lc_watchdog_init(struct delayed_work *work, int time)
+{
+	INIT_DELAYED_WORK(work, lc_watchdog_fire);
+	schedule_delayed_work(work, time);
+}
+
+static inline void lc_watchdog_disable(struct delayed_work *work)
+{
+	cancel_delayed_work_sync(work);
+}
+static inline void lc_watchdog_touch(struct delayed_work *work, int time)
+{
+	mod_delayed_work(system_wq, work, time);
+}
+
 /**
  * requests wait on preprocessing
  * user can call it w/o any lock but need to hold
@@ -1972,9 +2039,7 @@ ptlrpc_wait_event(struct ptlrpc_service_part *svcpt,
 {
 	/* Don't exit while there are replies to be handled */
 
-	/* XXX: Add this back when libcfs watchdog is merged upstream
-	lc_watchdog_disable(thread->t_watchdog);
-	 */
+	lc_watchdog_disable(&thread->t_watchdog);
 
 	cond_resched();
 
@@ -2001,10 +2066,8 @@ ptlrpc_wait_event(struct ptlrpc_service_part *svcpt,
 	if (ptlrpc_thread_stopping(thread))
 		return -EINTR;
 
-	/*
-	lc_watchdog_touch(thread->t_watchdog,
+	lc_watchdog_touch(&thread->t_watchdog,
 			  ptlrpc_server_get_timeout(svcpt));
-	 */
 	return 0;
 }
 
@@ -2024,6 +2087,7 @@ static int ptlrpc_main(void *arg)
 	struct lu_env *env;
 	int counter = 0, rc = 0;
 
+	thread->t_task = current;
 	thread->t_pid = current->pid;
 	unshare_fs_struct();
 
@@ -2104,10 +2168,8 @@ static int ptlrpc_main(void *arg)
 	/* wake up our creator in case he's still waiting. */
 	wake_up(&thread->t_ctl_waitq);
 
-	/*
-	thread->t_watchdog = lc_watchdog_add(ptlrpc_server_get_timeout(svcpt),
-					     NULL, NULL);
-	 */
+	lc_watchdog_init(&thread->t_watchdog,
+			 ptlrpc_server_get_timeout(svcpt));
 
 	spin_lock(&svcpt->scp_rep_lock);
 	list_add(&rs->rs_list, &svcpt->scp_rep_idle);
@@ -2163,10 +2225,7 @@ static int ptlrpc_main(void *arg)
 		}
 	}
 
-	/*
-	lc_watchdog_delete(thread->t_watchdog);
-	thread->t_watchdog = NULL;
-	*/
+	lc_watchdog_disable(&thread->t_watchdog);
 
 out_srv_fini:
 	/*
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180806/23f62175/attachment.sig>
