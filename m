From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:22:36 +1100
Subject: [lustre-devel] [PATCH 01/19] sched/wait: add wait_event_idle()
 functions.
In-Reply-To: <151847037709.22826.16175867257667686132.stgit@noble>
References: <151847037709.22826.16175867257667686132.stgit@noble>
Message-ID: <151847055644.22826.9130972646394182562.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The new TASK_IDLE state (TASK_UNINTERRUPTIBLE | __TASK_NOLOAD)
is not much used.  One way to make it easier to use is to
add wait_event*() family functions that make use of it.
This patch adds:
  wait_event_idle()
  wait_event_idle_timeout()
  wait_event_idle_exclusive()
  wait_event_idle_exclusive_timeout()

This set was chosen because lustre needs them before
it can discard its own l_wait_event() macro.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/wait.h |  114 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 114 insertions(+)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 55a611486bac..d9f131ecf708 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -599,6 +599,120 @@ do {										\
 	__ret;									\
 })
 
+/**
+ * wait_event_idle - wait for a condition without contributing to system load
+ * @wq_head: the waitqueue to wait on
+ * @condition: a C expression for the event to wait for
+ *
+ * The process is put to sleep (TASK_IDLE) until the
+ * @condition evaluates to true.
+ * The @condition is checked each time the waitqueue @wq_head is woken up.
+ *
+ * wake_up() has to be called after changing any variable that could
+ * change the result of the wait condition.
+ *
+ */
+#define wait_event_idle(wq_head, condition)					\
+do {										\
+	might_sleep();								\
+	if (!(condition))							\
+		___wait_event(wq_head, condition, TASK_IDLE, 0, 0, schedule());	\
+} while (0)
+
+/**
+ * wait_event_idle_exclusive - wait for a condition with contributing to system load
+ * @wq_head: the waitqueue to wait on
+ * @condition: a C expression for the event to wait for
+ *
+ * The process is put to sleep (TASK_IDLE) until the
+ * @condition evaluates to true.
+ * The @condition is checked each time the waitqueue @wq_head is woken up.
+ *
+ * The process is put on the wait queue with an WQ_FLAG_EXCLUSIVE flag
+ * set thus if other processes wait on the same list, when this
+ * process is woken further processes are not considered.
+ *
+ * wake_up() has to be called after changing any variable that could
+ * change the result of the wait condition.
+ *
+ */
+#define wait_event_idle_exclusive(wq_head, condition)				\
+do {										\
+	might_sleep();								\
+	if (!(condition))							\
+		___wait_event(wq_head, condition, TASK_IDLE, 1, 0, schedule());	\
+} while (0)
+
+#define __wait_event_idle_timeout(wq_head, condition, timeout)			\
+	___wait_event(wq_head, ___wait_cond_timeout(condition),			\
+		      TASK_IDLE, 0, timeout,					\
+		      __ret = schedule_timeout(__ret))
+
+/**
+ * wait_event_idle_timeout - sleep without load until a condition becomes true or a timeout elapses
+ * @wq_head: the waitqueue to wait on
+ * @condition: a C expression for the event to wait for
+ * @timeout: timeout, in jiffies
+ *
+ * The process is put to sleep (TASK_IDLE) until the
+ * @condition evaluates to true. The @condition is checked each time
+ * the waitqueue @wq_head is woken up.
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
+#define wait_event_idle_timeout(wq_head, condition, timeout)			\
+({										\
+	long __ret = timeout;							\
+	might_sleep();								\
+	if (!___wait_cond_timeout(condition))					\
+		__ret = __wait_event_idle_timeout(wq_head, condition, timeout);	\
+	__ret;									\
+})
+
+#define __wait_event_idle_exclusive_timeout(wq_head, condition, timeout)	\
+	___wait_event(wq_head, ___wait_cond_timeout(condition),			\
+		      TASK_IDLE, 1, timeout,					\
+		      __ret = schedule_timeout(__ret))
+
+/**
+ * wait_event_idle_exclusive_timeout - sleep without load until a condition becomes true or a timeout elapses
+ * @wq_head: the waitqueue to wait on
+ * @condition: a C expression for the event to wait for
+ * @timeout: timeout, in jiffies
+ *
+ * The process is put to sleep (TASK_IDLE) until the
+ * @condition evaluates to true. The @condition is checked each time
+ * the waitqueue @wq_head is woken up.
+ *
+ * The process is put on the wait queue with an WQ_FLAG_EXCLUSIVE flag
+ * set thus if other processes wait on the same list, when this
+ * process is woken further processes are not considered.
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
+#define wait_event_idle_exclusive_timeout(wq_head, condition, timeout)		\
+({										\
+	long __ret = timeout;							\
+	might_sleep();								\
+	if (!___wait_cond_timeout(condition))					\
+		__ret = __wait_event_idle_exclusive_timeout(wq_head, condition, timeout);\
+	__ret;									\
+})
+
 extern int do_wait_intr(wait_queue_head_t *, wait_queue_entry_t *);
 extern int do_wait_intr_irq(wait_queue_head_t *, wait_queue_entry_t *);
 
