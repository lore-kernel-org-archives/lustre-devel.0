From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:39 -0400
Subject: [lustre-devel] [PATCH 140/151] lustre: ptlrpc: add watchdog for
 ptlrpc service threads.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-141-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

If a ptlrpc thread takes longer than expected, it
can be used to get a stack trace to see where the
problem is.

This patch restores this functionality by using
a delayed work struct to report a back trace of
the thread if it ever fires.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: fc9de679a4c2 ("LU-9859 ptlrpc: add watchdog for ptlrpc service threads")
Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33018
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h      | 11 ++----
 fs/lustre/ptlrpc/service.c          | 79 ++++++++++++++++++++++++++++++-------
 include/linux/libcfs/libcfs_debug.h |  1 +
 net/lnet/libcfs/debug.c             |  3 ++
 net/lnet/libcfs/module.c            | 12 ++++++
 5 files changed, 84 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index ffa6977..a8aa327 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1298,18 +1298,15 @@ struct ptlrpc_thread {
 	 */
 	unsigned int			t_id;
 	/**
-	 * service thread pid
+	 * service thread
 	 */
+	struct task_struct		*t_task;
+	ktime_t				t_touched;
 	pid_t				t_pid;
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
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index f07f549..e0cce15 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -34,7 +34,9 @@
 #define DEBUG_SUBSYSTEM S_RPC
 
 #include <linux/kthread.h>
+#include <linux/ratelimit.h>
 #include <linux/fs_struct.h>
+
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
@@ -1977,6 +1979,57 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	return svcpt->scp_at_check;
 }
 
+/*
+ * If a thread runs too long or spends to much time on a single request,
+ * we want to know about it, so we set up a delayed work item as a watchdog.
+ * If it fires, we display a stack trace of the delayed thread,
+ * providing we aren't rate-limited
+ *
+ * Watchdog stack traces are limited to 3 per 'libcfs_watchdog_ratelimit'
+ * seconds
+ */
+static struct ratelimit_state watchdog_limit;
+
+static void ptlrpc_watchdog_fire(struct work_struct *w)
+{
+	struct ptlrpc_thread *thread = container_of(w, struct ptlrpc_thread,
+						    t_watchdog.work);
+	s64 ms_lapse = ktime_ms_delta(ktime_get(), thread->t_touched);
+	u32 ms_frac = do_div(ms_lapse, MSEC_PER_SEC);
+
+	if (!__ratelimit(&watchdog_limit)) {
+		LCONSOLE_WARN("%s: service thread pid %u was inactive for %llu.%.03u seconds. The thread might be hung, or it might only be slow and will resume later. Dumping the stack trace for debugging purposes:\n",
+			      thread->t_task->comm, thread->t_task->pid,
+			      ms_lapse, ms_frac);
+
+		libcfs_debug_dumpstack(thread->t_task);
+	} else {
+		LCONSOLE_WARN("%s: service thread pid %u was inactive for %llu.%.03u seconds. Watchdog stack traces are limited to 3 per %u seconds, skipping this one.\n",
+			      thread->t_task->comm, thread->t_task->pid,
+			      ms_lapse, ms_frac, libcfs_watchdog_ratelimit);
+	}
+}
+
+static void ptlrpc_watchdog_init(struct delayed_work *work, time_t time)
+{
+	INIT_DELAYED_WORK(work, ptlrpc_watchdog_fire);
+	schedule_delayed_work(work, time * HZ);
+}
+
+static void ptlrpc_watchdog_disable(struct delayed_work *work)
+{
+	cancel_delayed_work_sync(work);
+}
+
+static void ptlrpc_watchdog_touch(struct delayed_work *work, time_t time)
+{
+	struct ptlrpc_thread *thread = container_of(&work->work,
+						    struct ptlrpc_thread,
+						    t_watchdog.work);
+	thread->t_touched = ktime_get();
+	mod_delayed_work(system_wq, work, time * HZ);
+}
+
 /**
  * requests wait on preprocessing
  * user can call it w/o any lock but need to hold
@@ -2000,9 +2053,7 @@ static __attribute__((__noinline__)) int
 {
 	/* Don't exit while there are replies to be handled */
 
-	/* XXX: Add this back when libcfs watchdog is merged upstream
-	lc_watchdog_disable(thread->t_watchdog);
-	 */
+	ptlrpc_watchdog_disable(&thread->t_watchdog);
 
 	cond_resched();
 
@@ -2029,10 +2080,8 @@ static __attribute__((__noinline__)) int
 	if (ptlrpc_thread_stopping(thread))
 		return -EINTR;
 
-	/*
-	lc_watchdog_touch(thread->t_watchdog,
-			  ptlrpc_server_get_timeout(svcpt));
-	 */
+	ptlrpc_watchdog_touch(&thread->t_watchdog,
+			      ptlrpc_server_get_timeout(svcpt));
 	return 0;
 }
 
@@ -2052,6 +2101,7 @@ static int ptlrpc_main(void *arg)
 	struct lu_env *env;
 	int counter = 0, rc = 0;
 
+	thread->t_task = current;
 	thread->t_pid = current->pid;
 	unshare_fs_struct();
 
@@ -2132,10 +2182,9 @@ static int ptlrpc_main(void *arg)
 	/* wake up our creator in case he's still waiting. */
 	wake_up(&thread->t_ctl_waitq);
 
-	/*
-	thread->t_watchdog = lc_watchdog_add(ptlrpc_server_get_timeout(svcpt),
-					     NULL, NULL);
-	 */
+	thread->t_touched = ktime_get();
+	ptlrpc_watchdog_init(&thread->t_watchdog,
+			     ptlrpc_server_get_timeout(svcpt));
 
 	spin_lock(&svcpt->scp_rep_lock);
 	list_add(&rs->rs_list, &svcpt->scp_rep_idle);
@@ -2191,10 +2240,7 @@ static int ptlrpc_main(void *arg)
 		}
 	}
 
-	/*
-	lc_watchdog_delete(thread->t_watchdog);
-	thread->t_watchdog = NULL;
-	*/
+	ptlrpc_watchdog_disable(&thread->t_watchdog);
 
 out_srv_fini:
 	/*
@@ -2559,6 +2605,9 @@ int ptlrpc_hr_init(void)
 	if (!ptlrpc_hr.hr_partitions)
 		return -ENOMEM;
 
+	ratelimit_state_init(&watchdog_limit, libcfs_watchdog_ratelimit * HZ,
+			     3);
+
 	init_waitqueue_head(&ptlrpc_hr.hr_waitq);
 
 	preempt_disable();
diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index 89deab4..ed00320 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -49,6 +49,7 @@
 extern unsigned int libcfs_stack;
 extern unsigned int libcfs_debug;
 extern unsigned int libcfs_printk;
+extern unsigned int libcfs_watchdog_ratelimit;
 extern unsigned int libcfs_console_ratelimit;
 extern unsigned int libcfs_console_max_delay;
 extern unsigned int libcfs_console_min_delay;
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index 6b8f783e6..e779d6b 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -214,6 +214,9 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 unsigned int libcfs_catastrophe;
 EXPORT_SYMBOL(libcfs_catastrophe);
 
+unsigned int libcfs_watchdog_ratelimit = 300;
+EXPORT_SYMBOL(libcfs_watchdog_ratelimit);
+
 unsigned int libcfs_panic_on_lbug = 1;
 module_param(libcfs_panic_on_lbug, uint, 0644);
 MODULE_PARM_DESC(libcfs_panic_on_lbug, "Lustre kernel panic on LBUG");
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 49731bd..bee2581 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -336,6 +336,9 @@ static int proc_dobitmasks(struct ctl_table *table, int write,
 	return rc;
 }
 
+static int min_watchdog_ratelimit;			/* disable ratelimiting */
+static int max_watchdog_ratelimit = (24 * 60 * 60);	/* limit to once per day */
+
 static int proc_dump_kernel(struct ctl_table *table, int write,
 			    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -531,6 +534,15 @@ static int proc_cpt_distance(struct ctl_table *table, int write,
 		.proc_handler	= &proc_daemon_file,
 	},
 	{
+		.procname	= "watchdog_ratelimit",
+		.data		= &libcfs_watchdog_ratelimit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= &min_watchdog_ratelimit,
+		.extra2		= &max_watchdog_ratelimit,
+	},
+	{
 		.procname	= "force_lbug",
 		.data		= NULL,
 		.maxlen		= 0,
-- 
1.8.3.1
