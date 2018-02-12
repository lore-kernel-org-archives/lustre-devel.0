From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 10:47:59 +1100
Subject: [lustre-devel] [PATCH 17/19] staging: lustre: remove l_wait_event
 from ptlrpc_set_wait
In-Reply-To: <151847037709.22826.16175867257667686132.stgit@noble>
References: <151847037709.22826.16175867257667686132.stgit@noble>
Message-ID: <151847927923.19840.5570834902527836784.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This is the last remaining use of l_wait_event().
It is the only use of LWI_TIMEOUT_INTR_ALL() which
has a meaning that timeouts can be interrupted.
Only interrupts by "fatal" signals are allowed, so
introduce l_wait_event_abortable_timeout() to
support this.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h |   14 +++
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   84 ++++++++------------
 2 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 1939e959b92a..ccc1a329e42b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -196,6 +196,10 @@ struct l_wait_info {
 #define LUSTRE_FATAL_SIGS (sigmask(SIGKILL) | sigmask(SIGINT) |		\
 			   sigmask(SIGTERM) | sigmask(SIGQUIT) |	\
 			   sigmask(SIGALRM))
+static inline int l_fatal_signal_pending(struct task_struct *p)
+{
+	return signal_pending(p) && sigtestsetmask(&p->pending.signal, LUSTRE_FATAL_SIGS);
+}
 
 /**
  * wait_queue_entry_t of Linux (version < 2.6.34) is a FIFO list for exclusively
@@ -347,6 +351,16 @@ do {									   \
 	__ret;								\
 })
 
+#define l_wait_event_abortable_timeout(wq, condition, timeout)		\
+({									\
+	sigset_t __blocked;						\
+	int __ret = 0;							\
+	__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);		\
+	__ret = wait_event_interruptible_timeout(wq, condition, timeout);\
+	cfs_restore_sigs(__blocked);					\
+	__ret;								\
+})
+
 #define l_wait_event_abortable_exclusive(wq, condition)			\
 ({									\
 	sigset_t __blocked;						\
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index ffdd3ffd62c6..3d689d6100bc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1774,7 +1774,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 		}
 
 		/*
-		 * ptlrpc_set_wait->l_wait_event sets lwi_allow_intr
+		 * ptlrpc_set_wait allow signal to abort the timeout
 		 * so it sets rq_intr regardless of individual rpc
 		 * timeouts. The synchronous IO waiting path sets
 		 * rq_intr irrespective of whether ptlrpcd
@@ -2122,8 +2122,7 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 
 /**
  * Time out all uncompleted requests in request set pointed by \a data
- * Callback used when waiting on sets with l_wait_event.
- * Always returns 1.
+ * Called when wait_event_idle_timeout times out.
  */
 void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 {
@@ -2156,18 +2155,6 @@ void ptlrpc_expired_set(struct ptlrpc_request_set *set)
 		ptlrpc_expire_one_request(req, 1);
 	}
 }
-static int ptlrpc_expired_set_void(void *data)
-{
-	struct ptlrpc_request_set *set = data;
-
-	ptlrpc_expired_set(set);
-	/*
-	 * When waiting for a whole set, we always break out of the
-	 * sleep so we can recalculate the timeout, or enable interrupts
-	 * if everyone's timed out.
-	 */
-	return 1;
-}
 
 /**
  * Sets rq_intr flag in \a req under spinlock.
@@ -2182,11 +2169,10 @@ EXPORT_SYMBOL(ptlrpc_mark_interrupted);
 
 /**
  * Interrupts (sets interrupted flag) all uncompleted requests in
- * a set \a data. Callback for l_wait_event for interruptible waits.
+ * a set \a data. Called when l_wait_event_abortable_timeout receives signal.
  */
-static void ptlrpc_interrupted_set(void *data)
+static void ptlrpc_interrupted_set(struct ptlrpc_request_set *set)
 {
-	struct ptlrpc_request_set *set = data;
 	struct list_head *tmp;
 
 	CDEBUG(D_RPCTRACE, "INTERRUPTED SET %p\n", set);
@@ -2256,7 +2242,6 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 {
 	struct list_head *tmp;
 	struct ptlrpc_request *req;
-	struct l_wait_info lwi;
 	int rc, timeout;
 
 	if (set->set_producer)
@@ -2282,46 +2267,47 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		CDEBUG(D_RPCTRACE, "set %p going to sleep for %d seconds\n",
 		       set, timeout);
 
-		if (timeout == 0 && !signal_pending(current))
+		if (timeout == 0 && !signal_pending(current)) {
 			/*
 			 * No requests are in-flight (ether timed out
 			 * or delayed), so we can allow interrupts.
 			 * We still want to block for a limited time,
 			 * so we allow interrupts during the timeout.
 			 */
-			lwi = LWI_TIMEOUT_INTR_ALL(HZ,
-						   ptlrpc_expired_set_void,
-						   ptlrpc_interrupted_set, set);
-		else
+			rc = l_wait_event_abortable_timeout(set->set_waitq,
+							    ptlrpc_check_set(NULL, set),
+							    HZ);
+			if (rc == 0) {
+				rc = -ETIMEDOUT;
+				ptlrpc_expired_set(set);
+			} else if (rc < 0) {
+				rc = -EINTR;
+				ptlrpc_interrupted_set(set);
+			} else
+				rc = 0;
+		} else {
 			/*
 			 * At least one request is in flight, so no
 			 * interrupts are allowed. Wait until all
 			 * complete, or an in-flight req times out.
 			 */
-			lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
-					  ptlrpc_expired_set_void, set);
-
-		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set), &lwi);
-
-		/*
-		 * LU-769 - if we ignored the signal because it was already
-		 * pending when we started, we need to handle it now or we risk
-		 * it being ignored forever
-		 */
-		if (rc == -ETIMEDOUT && !lwi.lwi_allow_intr &&
-		    signal_pending(current)) {
-			sigset_t blocked_sigs =
-					   cfs_block_sigsinv(LUSTRE_FATAL_SIGS);
-
-			/*
-			 * In fact we only interrupt for the "fatal" signals
-			 * like SIGINT or SIGKILL. We still ignore less
-			 * important signals since ptlrpc set is not easily
-			 * reentrant from userspace again
-			 */
-			if (signal_pending(current))
-				ptlrpc_interrupted_set(set);
-			cfs_restore_sigs(blocked_sigs);
+			rc = wait_event_idle_timeout(set->set_waitq,
+						     ptlrpc_check_set(NULL, set),
+						     (timeout ? timeout : 1) * HZ);
+			if (rc == 0) {
+				ptlrpc_expired_set(set);
+				rc = -ETIMEDOUT;
+				/*
+				 * LU-769 - if we ignored the signal
+				 * because it was already pending when
+				 * we started, we need to handle it
+				 * now or we risk it being ignored
+				 * forever
+				 */
+				if (l_fatal_signal_pending(current))
+					ptlrpc_interrupted_set(set);
+			} else
+				rc = 0;
 		}
 
 		LASSERT(rc == 0 || rc == -EINTR || rc == -ETIMEDOUT);
@@ -2528,7 +2514,7 @@ static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 		return 0;
 
 	/*
-	 * We have to l_wait_event() whatever the result, to give liblustre
+	 * We have to wait_event_idle_timeout() whatever the result, to give liblustre
 	 * a chance to run reply_in_callback(), and to make sure we've
 	 * unlinked before returning a req to the pool.
 	 */
