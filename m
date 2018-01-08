From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Jan 2018 14:28:14 +1100
Subject: [lustre-devel] [PATCH 19/19] staging: lustre: remove l_wait_event()
 and related code
In-Reply-To: <151538168618.23920.8261096424342988792.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
Message-ID: <151538209403.23920.14521634003346477815.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These macros are no longer used, so they can
be removed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h |  249 --------------------
 1 file changed, 249 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index ccc1a329e42b..1efd86f18c1f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -76,123 +76,6 @@ int do_set_info_async(struct obd_import *imp,
 
 void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id);
 
-/*
- * l_wait_event is a flexible sleeping function, permitting simple caller
- * configuration of interrupt and timeout sensitivity along with actions to
- * be performed in the event of either exception.
- *
- * The first form of usage looks like this:
- *
- * struct l_wait_info lwi = LWI_TIMEOUT_INTR(timeout, timeout_handler,
- *					   intr_handler, callback_data);
- * rc = l_wait_event(waitq, condition, &lwi);
- *
- * l_wait_event() makes the current process wait on 'waitq' until 'condition'
- * is TRUE or a "killable" signal (SIGTERM, SIKGILL, SIGINT) is pending.  It
- * returns 0 to signify 'condition' is TRUE, but if a signal wakes it before
- * 'condition' becomes true, it optionally calls the specified 'intr_handler'
- * if not NULL, and returns -EINTR.
- *
- * If a non-zero timeout is specified, signals are ignored until the timeout
- * has expired.  At this time, if 'timeout_handler' is not NULL it is called.
- * If it returns FALSE l_wait_event() continues to wait as described above with
- * signals enabled.  Otherwise it returns -ETIMEDOUT.
- *
- * LWI_INTR(intr_handler, callback_data) is shorthand for
- * LWI_TIMEOUT_INTR(0, NULL, intr_handler, callback_data)
- *
- * The second form of usage looks like this:
- *
- * struct l_wait_info lwi = LWI_TIMEOUT(timeout, timeout_handler);
- * rc = l_wait_event(waitq, condition, &lwi);
- *
- * This form is the same as the first except that it COMPLETELY IGNORES
- * SIGNALS.  The caller must therefore beware that if 'timeout' is zero, or if
- * 'timeout_handler' is not NULL and returns FALSE, then the ONLY thing that
- * can unblock the current process is 'condition' becoming TRUE.
- *
- * Another form of usage is:
- * struct l_wait_info lwi = LWI_TIMEOUT_INTERVAL(timeout, interval,
- *					       timeout_handler);
- * rc = l_wait_event(waitq, condition, &lwi);
- * This is the same as previous case, but condition is checked once every
- * 'interval' jiffies (if non-zero).
- *
- * Subtle synchronization point: this macro does *not* necessary takes
- * wait-queue spin-lock before returning, and, hence, following idiom is safe
- * ONLY when caller provides some external locking:
- *
- *	     Thread1			    Thread2
- *
- *   l_wait_event(&obj->wq, ....);				       (1)
- *
- *				    wake_up(&obj->wq):		 (2)
- *					 spin_lock(&q->lock);	  (2.1)
- *					 __wake_up_common(q, ...);     (2.2)
- *					 spin_unlock(&q->lock, flags); (2.3)
- *
- *   kfree(obj);						  (3)
- *
- * As l_wait_event() may "short-cut" execution and return without taking
- * wait-queue spin-lock, some additional synchronization is necessary to
- * guarantee that step (3) can begin only after (2.3) finishes.
- *
- * XXX nikita: some ptlrpc daemon threads have races of that sort.
- *
- */
-
-#define LWI_ON_SIGNAL_NOOP ((void (*)(void *))(-1))
-
-struct l_wait_info {
-	long lwi_timeout;
-	long lwi_interval;
-	int	    lwi_allow_intr;
-	int  (*lwi_on_timeout)(void *);
-	void (*lwi_on_signal)(void *);
-	void  *lwi_cb_data;
-};
-
-/* NB: LWI_TIMEOUT ignores signals completely */
-#define LWI_TIMEOUT(time, cb, data)	     \
-((struct l_wait_info) {			 \
-	.lwi_timeout    = time,		 \
-	.lwi_on_timeout = cb,		   \
-	.lwi_cb_data    = data,		 \
-	.lwi_interval   = 0,		    \
-	.lwi_allow_intr = 0		     \
-})
-
-#define LWI_TIMEOUT_INTERVAL(time, interval, cb, data)  \
-((struct l_wait_info) {				 \
-	.lwi_timeout    = time,			 \
-	.lwi_on_timeout = cb,			   \
-	.lwi_cb_data    = data,			 \
-	.lwi_interval   = interval,		     \
-	.lwi_allow_intr = 0			     \
-})
-
-#define LWI_TIMEOUT_INTR(time, time_cb, sig_cb, data)   \
-((struct l_wait_info) {				 \
-	.lwi_timeout    = time,			 \
-	.lwi_on_timeout = time_cb,		      \
-	.lwi_on_signal  = sig_cb,		       \
-	.lwi_cb_data    = data,			 \
-	.lwi_interval   = 0,			    \
-	.lwi_allow_intr = 0			     \
-})
-
-#define LWI_TIMEOUT_INTR_ALL(time, time_cb, sig_cb, data)       \
-((struct l_wait_info) {					 \
-	.lwi_timeout    = time,				 \
-	.lwi_on_timeout = time_cb,			      \
-	.lwi_on_signal  = sig_cb,			       \
-	.lwi_cb_data    = data,				 \
-	.lwi_interval   = 0,				    \
-	.lwi_allow_intr = 1				     \
-})
-
-#define LWI_INTR(cb, data)  LWI_TIMEOUT_INTR(0, NULL, cb, data)
-
 #define LUSTRE_FATAL_SIGS (sigmask(SIGKILL) | sigmask(SIGINT) |		\
 			   sigmask(SIGTERM) | sigmask(SIGQUIT) |	\
 			   sigmask(SIGALRM))
@@ -201,138 +84,6 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
 	return signal_pending(p) && sigtestsetmask(&p->pending.signal, LUSTRE_FATAL_SIGS);
 }
 
-/**
- * wait_queue_entry_t of Linux (version < 2.6.34) is a FIFO list for exclusively
- * waiting threads, which is not always desirable because all threads will
- * be waken up again and again, even user only needs a few of them to be
- * active most time. This is not good for performance because cache can
- * be polluted by different threads.
- *
- * LIFO list can resolve this problem because we always wakeup the most
- * recent active thread by default.
- *
- * NB: please don't call non-exclusive & exclusive wait on the same
- * waitq if add_wait_queue_exclusive_head is used.
- */
-#define add_wait_queue_exclusive_head(waitq, link)		\
-{								\
-	unsigned long flags;					\
-								\
-	spin_lock_irqsave(&((waitq)->lock), flags);		\
-	__add_wait_queue_exclusive(waitq, link);		\
-	spin_unlock_irqrestore(&((waitq)->lock), flags);	\
-}
-
-/*
- * wait for @condition to become true, but no longer than timeout, specified
- * by @info.
- */
-#define __l_wait_event(wq, condition, info, ret, l_add_wait)		   \
-do {									   \
-	wait_queue_entry_t __wait;						 \
-	long __timeout = info->lwi_timeout;			  \
-	sigset_t   __blocked;					      \
-	int   __allow_intr = info->lwi_allow_intr;			     \
-									       \
-	ret = 0;							       \
-	if (condition)							 \
-		break;							 \
-									       \
-	init_waitqueue_entry(&__wait, current);					    \
-	l_add_wait(&wq, &__wait);					      \
-									       \
-	/* Block all signals (just the non-fatal ones if no timeout). */       \
-	if (info->lwi_on_signal && (__timeout == 0 || __allow_intr))   \
-		__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);	      \
-	else								   \
-		__blocked = cfs_block_sigsinv(0);			      \
-									       \
-	for (;;) {							     \
-		if (condition)						 \
-			break;						 \
-									       \
-		set_current_state(TASK_INTERRUPTIBLE);			       \
-									       \
-		if (__timeout == 0) {					  \
-			schedule();					       \
-		} else {						       \
-			long interval = info->lwi_interval ?	  \
-					     min_t(long,	     \
-						 info->lwi_interval, __timeout) : \
-					     __timeout;			\
-			long remaining = schedule_timeout(interval);\
-			__timeout = cfs_time_sub(__timeout,		    \
-					    cfs_time_sub(interval, remaining));\
-			if (__timeout == 0) {				  \
-				if (!info->lwi_on_timeout ||		      \
-				    info->lwi_on_timeout(info->lwi_cb_data)) { \
-					ret = -ETIMEDOUT;		      \
-					break;				 \
-				}					      \
-				/* Take signals after the timeout expires. */  \
-				if (info->lwi_on_signal)		       \
-				    (void)cfs_block_sigsinv(LUSTRE_FATAL_SIGS);\
-			}						      \
-		}							      \
-									       \
-		set_current_state(TASK_RUNNING);			       \
-									       \
-		if (condition)						 \
-			break;						 \
-		if (signal_pending(current)) {				    \
-			if (info->lwi_on_signal &&		     \
-			    (__timeout == 0 || __allow_intr)) {		\
-				if (info->lwi_on_signal != LWI_ON_SIGNAL_NOOP) \
-					info->lwi_on_signal(info->lwi_cb_data);\
-				ret = -EINTR;				  \
-				break;					 \
-			}						      \
-			/* We have to do this here because some signals */     \
-			/* are not blockable - ie from strace(1).       */     \
-			/* In these cases we want to schedule_timeout() */     \
-			/* again, because we don't want that to return  */     \
-			/* -EINTR when the RPC actually succeeded.      */     \
-			/* the recalc_sigpending() below will deliver the */     \
-			/* signal properly.			     */     \
-			cfs_clear_sigpending();				\
-		}							      \
-	}								      \
-									       \
-	cfs_restore_sigs(__blocked);					   \
-									       \
-	remove_wait_queue(&wq, &__wait);					   \
-} while (0)
-
-#define l_wait_event(wq, condition, info)		       \
-({							      \
-	int		 __ret;			      \
-	struct l_wait_info *__info = (info);		    \
-								\
-	__l_wait_event(wq, condition, __info,		   \
-		       __ret, add_wait_queue);		   \
-	__ret;						  \
-})
-
-#define l_wait_event_exclusive(wq, condition, info)	     \
-({							      \
-	int		 __ret;			      \
-	struct l_wait_info *__info = (info);		    \
-								\
-	__l_wait_event(wq, condition, __info,		   \
-		       __ret, add_wait_queue_exclusive);	 \
-	__ret;						  \
-})
-
-#define l_wait_event_exclusive_head(wq, condition, info)	\
-({							      \
-	int		 __ret;			      \
-	struct l_wait_info *__info = (info);		    \
-								\
-	__l_wait_event(wq, condition, __info,		   \
-		       __ret, add_wait_queue_exclusive_head);    \
-	__ret;						  \
-})
-
 /** @} lib */
 
 
