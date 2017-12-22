From: NeilBrown <neilb@suse.com>
Date: Fri, 22 Dec 2017 14:11:04 +1100
Subject: [lustre-devel] [PATCH 1/2] sched/wait: add wait_event_idle()
 functions.
In-Reply-To: <151391203805.23157.8332034037737592042.stgit@noble>
References: <151391203805.23157.8332034037737592042.stgit@noble>
Message-ID: <151391226402.23157.5260361528373791240.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, lustre <lustre-devel@lists.lustre.org>

The new TASK_IDLE state (TASK_UNINTERRUPTIBLE | __TASK_NOLOAD)
is not much used.  One way to make it easier to use is to
add wait_event*() family functions that make use of it.
This patch adds:
  wait_event_idle()
  wait_event_idle_timeout()
  wait_event_idle_exclusive()

This set were chosen because lustre needs them before
it can discard its own l_wait_event() macro.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/wait.h |   77 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 158715445ffb..3aea0780c9d0 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -597,6 +597,83 @@ do {										\
 	__ret;									\
 })
 
+/**
+ * wait_event_idle - wait for a condition with contributing to system load
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
+ * set thus when other process waits process on the list if this
+ * process is awaken further processes are not considered.
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
+ * wait_event_idle_timeout - sleep without load until a condition gets true or a timeout elapses
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
+		__ret = __wait_event_timeout(wq_head, condition, timeout);	\
+	__ret;									\
+})
+
 extern int do_wait_intr(wait_queue_head_t *, wait_queue_entry_t *);
 extern int do_wait_intr_irq(wait_queue_head_t *, wait_queue_entry_t *);
 
