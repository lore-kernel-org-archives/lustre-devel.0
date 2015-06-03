From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 18:38:06 -0400
Subject: [lustre-devel] [PATCH v2] staging:lustre: cleanup libcfs lock
	handling
Message-ID: <1433371086-17609-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Previously with libcfs being built for user land and kernel
space wrappers were created to transparently handle locking.
Now that user land support has been removed we delete all
those locking wrappers with this patch. Many of those changes
landed upstream but some nice cleanups still remain that are
pushed in this patch.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13793
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 +-
 drivers/staging/lustre/lustre/libcfs/fail.c        |    2 +-
 .../lustre/lustre/libcfs/linux/linux-tracefile.c   |    4 +---
 drivers/staging/lustre/lustre/libcfs/module.c      |   11 ++---------
 drivers/staging/lustre/lustre/libcfs/tracefile.c   |    2 +-
 5 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 4928f5c..99f8396 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -35,9 +35,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
+#include <linux/completion.h>
 #include "../../include/linux/lnet/lib-lnet.h"
 
-
 static int   accept_port    = 988;
 static int   accept_backlog = 127;
 static int   accept_timeout = 5;
diff --git a/drivers/staging/lustre/lustre/libcfs/fail.c b/drivers/staging/lustre/lustre/libcfs/fail.c
index 92444b0..7b7fc21 100644
--- a/drivers/staging/lustre/lustre/libcfs/fail.c
+++ b/drivers/staging/lustre/lustre/libcfs/fail.c
@@ -41,7 +41,7 @@ EXPORT_SYMBOL(cfs_fail_loc);
 unsigned int cfs_fail_val = 0;
 EXPORT_SYMBOL(cfs_fail_val);
 
-wait_queue_head_t cfs_race_waitq;
+DECLARE_WAIT_QUEUE_HEAD(cfs_race_waitq);
 EXPORT_SYMBOL(cfs_race_waitq);
 
 int cfs_race_state;
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index 483cbc8..eb10e3b 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -49,7 +49,7 @@ static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
 
 char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 
-struct rw_semaphore cfs_tracefile_sem;
+static DECLARE_RWSEM(cfs_tracefile_sem);
 
 int cfs_tracefile_init_arch(void)
 {
@@ -57,8 +57,6 @@ int cfs_tracefile_init_arch(void)
 	int    j;
 	struct cfs_trace_cpu_data *tcd;
 
-	init_rwsem(&cfs_tracefile_sem);
-
 	/* initialize trace_data */
 	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
 	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 83b1a70..e60b2e9 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -66,8 +66,6 @@ MODULE_DESCRIPTION("Portals v3.1");
 MODULE_LICENSE("GPL");
 
 extern struct miscdevice libcfs_dev;
-extern struct rw_semaphore cfs_tracefile_sem;
-extern struct mutex cfs_trace_thread_mutex;
 extern struct cfs_wi_sched *cfs_sched_rehash;
 extern void libcfs_init_nidstrings(void);
 
@@ -248,8 +246,8 @@ static int libcfs_psdev_release(unsigned long flags, void *args)
 	return 0;
 }
 
-static struct rw_semaphore ioctl_list_sem;
-static struct list_head ioctl_list;
+static DECLARE_RWSEM(ioctl_list_sem);
+static LIST_HEAD(ioctl_list);
 
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand)
 {
@@ -392,11 +390,6 @@ static int init_libcfs_module(void)
 
 	libcfs_arch_init();
 	libcfs_init_nidstrings();
-	init_rwsem(&cfs_tracefile_sem);
-	mutex_init(&cfs_trace_thread_mutex);
-	init_rwsem(&ioctl_list_sem);
-	INIT_LIST_HEAD(&ioctl_list);
-	init_waitqueue_head(&cfs_race_waitq);
 
 	rc = libcfs_debug_init(5 * 1024 * 1024);
 	if (rc < 0) {
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index c86394f..6ee2adc 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -52,7 +52,7 @@ union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
 static struct tracefiled_ctl trace_tctl;
-struct mutex cfs_trace_thread_mutex;
+static DEFINE_MUTEX(cfs_trace_thread_mutex);
 static int thread_running;
 
 static atomic_t cfs_tage_allocated = ATOMIC_INIT(0);
-- 
1.7.1
