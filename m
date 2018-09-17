From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:39 -0400
Subject: [lustre-devel] [PATCH 29/30] lustre: libcfs: use save_stack_trace
 for stack dump
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

The function libcfs_debug_dumpstack() was removed due to it being
x86 specific upstream. This restores this functionality using
save_stack_trace_tsk for stack trace dumps. This will be used for
the restored ptlrpc watchdog that will be landed in the future.

Signed-off-by: Yang Sheng <ys@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11062
Reviewed-on: https://review.whamcloud.com/32952
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_debug.h     |  1 +
 drivers/staging/lustre/lnet/libcfs/debug.c         | 46 ++++++++++++++++++++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  2 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |  2 +-
 4 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 17534a7..27a3b12 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -58,6 +58,7 @@
 
 int libcfs_debug_mask2str(char *str, int size, int mask, int is_subsys);
 int libcfs_debug_str2mask(int *mask, const char *str, int is_subsys);
+void libcfs_debug_dumpstack(struct task_struct *tsk);
 
 /* Has there been an LBUG? */
 extern unsigned int libcfs_catastrophe;
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index dd06a4c..90d756c 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -42,6 +42,8 @@
 #include <linux/ctype.h>
 #include <linux/libcfs/libcfs_string.h>
 #include <linux/kthread.h>
+#include <linux/stacktrace.h>
+#include <linux/utsname.h>
 #include "tracefile.h"
 
 static char debug_file_name[1024];
@@ -435,17 +437,55 @@ void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
 		/* not reached */
 	}
 
-	dump_stack();
-	if (!libcfs_panic_on_lbug)
-		libcfs_debug_dumplog();
+	libcfs_debug_dumpstack(NULL);
 	if (libcfs_panic_on_lbug)
 		panic("LBUG");
+	else
+		libcfs_debug_dumplog();
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	while (1)
 		schedule();
 }
 EXPORT_SYMBOL(lbug_with_loc);
 
+#ifdef CONFIG_STACKTRACE
+#define MAX_ST_ENTRIES 100
+static DEFINE_SPINLOCK(st_lock);
+
+static void libcfs_call_trace(struct task_struct *tsk)
+{
+	static unsigned long entries[MAX_ST_ENTRIES];
+	struct stack_trace trace;
+
+	trace.nr_entries = 0;
+	trace.max_entries = MAX_ST_ENTRIES;
+	trace.entries = entries;
+	trace.skip = 0;
+
+	spin_lock(&st_lock);
+	pr_info("Pid: %d, comm: %.20s %s %s\n", tsk->pid, tsk->comm,
+		init_utsname()->release, init_utsname()->version);
+	pr_info("Call Trace:\n");
+	save_stack_trace_tsk(tsk, &trace);
+	print_stack_trace(&trace, 0);
+	spin_unlock(&st_lock);
+}
+#else /* !CONFIG_STACKTRACE */
+static void libcfs_call_trace(struct task_struct *tsk)
+{
+	if (tsk == current)
+		dump_stack();
+	else
+		CWARN("can't show stack: kernel doesn't export show_task\n");
+}
+#endif /* !CONFIG_STACKTRACE */
+
+void libcfs_debug_dumpstack(struct task_struct *tsk)
+{
+	libcfs_call_trace(tsk ?: current);
+}
+EXPORT_SYMBOL(libcfs_debug_dumpstack);
+
 static int panic_notifier(struct notifier_block *self, unsigned long unused1,
 			  void *unused2)
 {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 3cbdc81..bc6b122 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1503,7 +1503,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		break;
 	default:
 		LDLM_ERROR(lock, "Unknown LVB type: %d", lock->l_lvb_type);
-		dump_stack();
+		libcfs_debug_dumpstack(NULL);
 		return -EINVAL;
 	}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index b9bf2b8..a86d4c2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -399,7 +399,7 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
 				NULL, resname, LDLM_EXTENT, 0);
 			ldlm_resource_dump(D_ERROR, res);
-
+			libcfs_debug_dumpstack(NULL);
 			LBUG();
 		}
 
-- 
1.8.3.1
