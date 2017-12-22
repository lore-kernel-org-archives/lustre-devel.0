From: NeilBrown <neilb@suse.com>
Date: Fri, 22 Dec 2017 14:11:04 +1100
Subject: [lustre-devel] [PATCH 2/2] sched/wait: add
 wait_event_idle_exclusive_lifo()
In-Reply-To: <151391203805.23157.8332034037737592042.stgit@noble>
References: <151391203805.23157.8332034037737592042.stgit@noble>
Message-ID: <151391226407.23157.14719462856574834182.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, lustre <lustre-devel@lists.lustre.org>

wait_event_*_exclusive() adds new waiters to the end of the
quest, while non-exclusive wait_event adds to the head.

This ensures that a wake_up will wake all non-exclusive
waiters and at most one exclusive wait, but it means that
exclusive waiters are woken in a FIFO order, so the task
woken is the one least likely to have data in the CPU cache.

When simple interaction with non-exclusive waiters is not
important, and when choosing a cache-hot task is, the new

  wait_event_idle_exclusive_lifo()
and
  wait_event_idle_exclusive_lifo_timeout()

can be used.  To implement these we introduce a new
WQ_FLAG_LIFO which causes prepare_to_wait_event() to
add to the head of the queue.

This will be used to allow lustre's l_wait_event() to be
replaced with more standard wait.h macros.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/wait.h |   95 +++++++++++++++++++++++++++++++++++++++++++++++---
 kernel/sched/wait.c  |    3 +-
 2 files changed, 91 insertions(+), 7 deletions(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 3aea0780c9d0..49cb393c53d5 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -20,6 +20,9 @@ int default_wake_function(struct wait_queue_entry *wq_entry, unsigned mode, int
 #define WQ_FLAG_EXCLUSIVE	0x01
 #define WQ_FLAG_WOKEN		0x02
 #define WQ_FLAG_BOOKMARK	0x04
+#define WQ_FLAG_LIFO		0x08 /* used with WQ_FLAG_EXCLUSIVE to force
+				      * LIFO scheduling in prepare_to_wait_event().
+				      */
 
 /*
  * A single wait-queue entry structure:
@@ -247,7 +250,7 @@ extern void init_wait_entry(struct wait_queue_entry *wq_entry, int flags);
 	struct wait_queue_entry __wq_entry;					\
 	long __ret = ret;	/* explicit shadow */				\
 										\
-	init_wait_entry(&__wq_entry, exclusive ? WQ_FLAG_EXCLUSIVE : 0);	\
+	init_wait_entry(&__wq_entry, exclusive);	\
 	for (;;) {								\
 		long __int = prepare_to_wait_event(&wq_head, &__wq_entry, state);\
 										\
@@ -381,7 +384,8 @@ do {										\
 })
 
 #define __wait_event_exclusive_cmd(wq_head, condition, cmd1, cmd2)		\
-	(void)___wait_event(wq_head, condition, TASK_UNINTERRUPTIBLE, 1, 0,	\
+	(void)___wait_event(wq_head, condition, TASK_UNINTERRUPTIBLE,		\
+			    WQ_FLAG_EXCLUSIVE, 0,				\
 			    cmd1; schedule(); cmd2)
 /*
  * Just like wait_event_cmd(), except it sets exclusive flag
@@ -558,7 +562,7 @@ do {										\
 })
 
 #define __wait_event_interruptible_exclusive(wq, condition)			\
-	___wait_event(wq, condition, TASK_INTERRUPTIBLE, 1, 0,			\
+	___wait_event(wq, condition, TASK_INTERRUPTIBLE, WQ_FLAG_EXCLUSIVE, 0,	\
 		      schedule())
 
 #define wait_event_interruptible_exclusive(wq, condition)			\
@@ -571,7 +575,7 @@ do {										\
 })
 
 #define __wait_event_killable_exclusive(wq, condition)				\
-	___wait_event(wq, condition, TASK_KILLABLE, 1, 0,			\
+	___wait_event(wq, condition, TASK_KILLABLE, WQ_FLAG_EXCLUSIVE, 0,	\
 		      schedule())
 
 #define wait_event_killable_exclusive(wq, condition)				\
@@ -585,7 +589,7 @@ do {										\
 
 
 #define __wait_event_freezable_exclusive(wq, condition)				\
-	___wait_event(wq, condition, TASK_INTERRUPTIBLE, 1, 0,			\
+	___wait_event(wq, condition, TASK_INTERRUPTIBLE, WQ_FLAG_EXCLUSIVE, 0,	\
 			schedule(); try_to_freeze())
 
 #define wait_event_freezable_exclusive(wq, condition)				\
@@ -638,9 +642,88 @@ do {										\
 do {										\
 	might_sleep();								\
 	if (!(condition))							\
-		___wait_event(wq_head, condition, TASK_IDLE, 1, 0, schedule());	\
+		___wait_event(wq_head, condition, TASK_IDLE, WQ_FLAG_EXCLUSIVE,	\
+			      0, schedule());					\
 } while (0)
 
+/**
+ * wait_event_idle_exclusive_lifo - wait for a condition without contributing to system load
+ * @wq_head: the waitqueue to wait on
+ * @condition: a C expression for the event to wait for
+ *
+ * The process is put to sleep (TASK_IDLE) until the
+ * @condition evaluates to true.
+ * The @condition is checked each time the waitqueue @wq_head is woken up.
+ *
+ * The process is put on the wait queue with an WQ_FLAG_EXCLUSIVE flag
+ * set thus when other process waits process on the list if this
+ * process is awaken further processes are not considered.
+ *
+ * Contrary to the usual practice with exclusive wait, this call adds
+ * the task to the head of the queue so that tasks are woken in a
+ * LIFO (rather than FIFO) order.  This means that if both exclusive and
+ * non-exclusive waiter are waiting on the same queue, the non-exclusive
+ * waiters may *not* be woken on the next wakeup event.  The benefit
+ * of using LIFO waits is that when multiple worker threads are
+ * available, the one with the warmest cache will preferentially
+ * be woken.
+ *
+ * wake_up() has to be called after changing any variable that could
+ * change the result of the wait condition.
+ *
+ */
+#define wait_event_idle_exclusive_lifo(wq_head, condition)			\
+do {										\
+	might_sleep();								\
+	if (!(condition))							\
+		___wait_event(wq_head, condition, TASK_IDLE,			\
+			      WQ_FLAG_EXCLUSIVE | WQ_FLAG_LIFO,			\
+			      0, schedule());					\
+} while (0)
+
+/**
+ * wait_event_idle_exclusive_lifo_timeout - wait for a condition with timeout, without contributing to system load
+ * @wq_head: the waitqueue to wait on
+ * @condition: a C expression for the event to wait for
+ * @timeout: timeout, in jiffies
+ *
+ * The process is put to sleep (TASK_IDLE) until the
+ * @condition evaluates to true.
+ * The @condition is checked each time the waitqueue @wq_head is woken up.
+ *
+ * The process is put on the wait queue with an WQ_FLAG_EXCLUSIVE flag
+ * set thus when other process waits process on the list if this
+ * process is awaken further processes are not considered.
+ *
+ * Contrary to the usual practice with exclusive wait, this call adds
+ * the task to the head of the queue so that tasks are woken in a
+ * LIFO (rather than FIFO) order.  This means that if both exclusive and
+ * non-exclusive waiter are waiting on the same queue, the non-exclusive
+ * waiters may *not* be woken on the next wakeup event.  The benefit
+ * of using LIFO waits is that when multiple worker threads are
+ * available, the one with the warmest cache will preferentially
+ * be woken.
+ *
+ * wake_up() has to be called after changing any variable that could
+ * change the result of the wait condition.
+ *
+ * Returns:
+ * 0 if the @condition evaluated to %false after the @timeout elapsed,
+ * 1 if the @condition evaluated to %true after the @timeout elapsed,
+ * or the remaining jiffies (at least 1) if the @condition evaluated
+ * to %true before the @timeout elapsed.
+ */
+#define wait_event_idle_exclusive_lifo_timeout(wq_head, condition, timeout)	\
+({										\
+	long __ret = timeout;							\
+	might_sleep();								\
+	if (!___wait_cond_timeout(condition))					\
+		__ret = ___wait_event(wq_head, ___wait_cond_timeout(condition), TASK_IDLE, \
+			      WQ_FLAG_EXCLUSIVE | WQ_FLAG_LIFO,			\
+			      timeout, __ret = schedule_timeout(__ret));	\
+	__ret;									\
+})
+
 #define __wait_event_idle_timeout(wq_head, condition, timeout)			\
 	___wait_event(wq_head, ___wait_cond_timeout(condition),			\
 		      TASK_IDLE, 0, timeout,					\
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 929ecb7d6b78..a92f368acbb0 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -285,7 +285,8 @@ long prepare_to_wait_event(struct wait_queue_head *wq_head, struct wait_queue_en
 		ret = -ERESTARTSYS;
 	} else {
 		if (list_empty(&wq_entry->entry)) {
-			if (wq_entry->flags & WQ_FLAG_EXCLUSIVE)
+			if ((wq_entry->flags & (WQ_FLAG_EXCLUSIVE | WQ_FLAG_LIFO)) ==
+				WQ_FLAG_EXCLUSIVE)
 				__add_wait_queue_entry_tail(wq_head, wq_entry);
 			else
 				__add_wait_queue(wq_head, wq_entry);
