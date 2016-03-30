From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:51 -0400
Subject: [lustre-devel] [PATCH 19/43] staging/lustre/clio: cl_lock
	simplification
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Bobi Jam <bobijam.xu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In this patch, the cl_lock cache is eliminated. cl_lock is turned
into a cacheless data container for the requirements of locks to
complete the IO. cl_lock is created before I/O starts and destroyed
when the I/O is complete.

cl_lock depends on LDLM lock to fulfill lock semantics. LDLM lock
is attached to cl_lock at OSC layer. LDLM lock is still cacheable.

Two major methods are supported for cl_lock: clo_enqueue and
clo_cancel.  A cl_lock is enqueued by cl_lock_request(), which will
call clo_enqueue() methods for each layer to enqueue the lock.
At the LOV layer, if a cl_lock consists of multiple sub cl_locks,
each sub locks will be enqueued correspondingly. At OSC layer, the
lock enqueue request will tend to reuse cached LDLM lock; otherwise
a new LDLM lock will have to be requested from OST side.

cl_lock_cancel() must be called to release a cl_lock after use.
clo_cancel() method will be called for each layer to release the
resource held by this lock. At OSC layer, the reference count of LDLM
lock, which is held at clo_enqueue time, is released.

LDLM lock can only be canceled if there is no cl_lock using it.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/10858
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3259
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  590 +-----
 drivers/staging/lustre/lustre/include/lclient.h    |   26 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   16 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    1 +
 drivers/staging/lustre/lustre/llite/glimpse.c      |   49 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  107 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   14 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |    3 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   19 +-
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |   25 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   12 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   75 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |    5 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  996 +---------
 drivers/staging/lustre/lustre/lov/lov_object.c     |   13 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |  383 ----
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  168 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 2026 ++------------------
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   64 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    9 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |   60 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  110 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   62 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   10 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   41 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 1618 ++++++----------
 drivers/staging/lustre/lustre/osc/osc_object.c     |   33 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   14 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  207 +-
 33 files changed, 1203 insertions(+), 5560 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 91261b1..8f9512e 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -82,7 +82,6 @@
  *  - i_mutex
  *      - PG_locked
  *	  - cl_object_header::coh_page_guard
- *	  - cl_object_header::coh_lock_guard
  *	  - lu_site::ls_guard
  *
  * See the top comment in cl_object.c for the description of overall locking and
@@ -404,16 +403,6 @@ struct cl_object_header {
 	 * here.
 	 */
 	struct lu_object_header  coh_lu;
-	/** \name locks
-	 * \todo XXX move locks below to the separate cache-lines, they are
-	 * mostly useless otherwise.
-	 */
-	/** @{ */
-	/** Lock protecting lock list. */
-	spinlock_t		 coh_lock_guard;
-	/** @} locks */
-	/** List of cl_lock's granted for this object. */
-	struct list_head	       coh_locks;
 
 	/**
 	 * Parent object. It is assumed that an object has a well-defined
@@ -795,16 +784,9 @@ struct cl_page_slice {
 /**
  * Lock mode. For the client extent locks.
  *
- * \warning: cl_lock_mode_match() assumes particular ordering here.
  * \ingroup cl_lock
  */
 enum cl_lock_mode {
-	/**
-	 * Mode of a lock that protects no data, and exists only as a
-	 * placeholder. This is used for `glimpse' requests. A phantom lock
-	 * might get promoted to real lock at some point.
-	 */
-	CLM_PHANTOM,
 	CLM_READ,
 	CLM_WRITE,
 	CLM_GROUP
@@ -1114,12 +1096,6 @@ static inline struct page *cl_page_vmpage(struct cl_page *page)
  * (struct cl_lock) and a list of layers (struct cl_lock_slice), linked to
  * cl_lock::cll_layers list through cl_lock_slice::cls_linkage.
  *
- * All locks for a given object are linked into cl_object_header::coh_locks
- * list (protected by cl_object_header::coh_lock_guard spin-lock) through
- * cl_lock::cll_linkage. Currently this list is not sorted in any way. We can
- * sort it in starting lock offset, or use altogether different data structure
- * like a tree.
- *
  * Typical cl_lock consists of the two layers:
  *
  *     - vvp_lock (vvp specific data), and
@@ -1320,289 +1296,21 @@ struct cl_lock_descr {
 	__u32	     cld_enq_flags;
 };
 
-#define DDESCR "%s(%d):[%lu, %lu]"
+#define DDESCR "%s(%d):[%lu, %lu]:%x"
 #define PDESCR(descr)						   \
 	cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode,	\
-	(descr)->cld_start, (descr)->cld_end
+	(descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags
 
 const char *cl_lock_mode_name(const enum cl_lock_mode mode);
 
 /**
- * Lock state-machine states.
- *
- * \htmlonly
- * <pre>
- *
- * Possible state transitions:
- *
- *	      +------------------>NEW
- *	      |		    |
- *	      |		    | cl_enqueue_try()
- *	      |		    |
- *	      |    cl_unuse_try()  V
- *	      |  +--------------QUEUING (*)
- *	      |  |		 |
- *	      |  |		 | cl_enqueue_try()
- *	      |  |		 |
- *	      |  | cl_unuse_try()  V
- *    sub-lock  |  +-------------ENQUEUED (*)
- *    canceled  |  |		 |
- *	      |  |		 | cl_wait_try()
- *	      |  |		 |
- *	      |  |		(R)
- *	      |  |		 |
- *	      |  |		 V
- *	      |  |		HELD<---------+
- *	      |  |		 |	    |
- *	      |  |		 |	    | cl_use_try()
- *	      |  |  cl_unuse_try() |	    |
- *	      |  |		 |	    |
- *	      |  |		 V	 ---+
- *	      |  +------------>INTRANSIT (D) <--+
- *	      |		    |	    |
- *	      |     cl_unuse_try() |	    | cached lock found
- *	      |		    |	    | cl_use_try()
- *	      |		    |	    |
- *	      |		    V	    |
- *	      +------------------CACHED---------+
- *				   |
- *				  (C)
- *				   |
- *				   V
- *				FREEING
- *
- * Legend:
- *
- *	 In states marked with (*) transition to the same state (i.e., a loop
- *	 in the diagram) is possible.
- *
- *	 (R) is the point where Receive call-back is invoked: it allows layers
- *	 to handle arrival of lock reply.
- *
- *	 (C) is the point where Cancellation call-back is invoked.
- *
- *	 (D) is the transit state which means the lock is changing.
- *
- *	 Transition to FREEING state is possible from any other state in the
- *	 diagram in case of unrecoverable error.
- * </pre>
- * \endhtmlonly
- *
- * These states are for individual cl_lock object. Top-lock and its sub-locks
- * can be in the different states. Another way to say this is that we have
- * nested state-machines.
- *
- * Separate QUEUING and ENQUEUED states are needed to support non-blocking
- * operation for locks with multiple sub-locks. Imagine lock on a file F, that
- * intersects 3 stripes S0, S1, and S2. To enqueue F client has to send
- * enqueue to S0, wait for its completion, then send enqueue for S1, wait for
- * its completion and at last enqueue lock for S2, and wait for its
- * completion. In that case, top-lock is in QUEUING state while S0, S1 are
- * handled, and is in ENQUEUED state after enqueue to S2 has been sent (note
- * that in this case, sub-locks move from state to state, and top-lock remains
- * in the same state).
- */
-enum cl_lock_state {
-	/**
-	 * Lock that wasn't yet enqueued
-	 */
-	CLS_NEW,
-	/**
-	 * Enqueue is in progress, blocking for some intermediate interaction
-	 * with the other side.
-	 */
-	CLS_QUEUING,
-	/**
-	 * Lock is fully enqueued, waiting for server to reply when it is
-	 * granted.
-	 */
-	CLS_ENQUEUED,
-	/**
-	 * Lock granted, actively used by some IO.
-	 */
-	CLS_HELD,
-	/**
-	 * This state is used to mark the lock is being used, or unused.
-	 * We need this state because the lock may have several sublocks,
-	 * so it's impossible to have an atomic way to bring all sublocks
-	 * into CLS_HELD state at use case, or all sublocks to CLS_CACHED
-	 * at unuse case.
-	 * If a thread is referring to a lock, and it sees the lock is in this
-	 * state, it must wait for the lock.
-	 * See state diagram for details.
-	 */
-	CLS_INTRANSIT,
-	/**
-	 * Lock granted, not used.
-	 */
-	CLS_CACHED,
-	/**
-	 * Lock is being destroyed.
-	 */
-	CLS_FREEING,
-	CLS_NR
-};
-
-enum cl_lock_flags {
-	/**
-	 * lock has been cancelled. This flag is never cleared once set (by
-	 * cl_lock_cancel0()).
-	 */
-	CLF_CANCELLED	= 1 << 0,
-	/** cancellation is pending for this lock. */
-	CLF_CANCELPEND	= 1 << 1,
-	/** destruction is pending for this lock. */
-	CLF_DOOMED	= 1 << 2,
-	/** from enqueue RPC reply upcall. */
-	CLF_FROM_UPCALL	= 1 << 3,
-};
-
-/**
- * Lock closure.
- *
- * Lock closure is a collection of locks (both top-locks and sub-locks) that
- * might be updated in a result of an operation on a certain lock (which lock
- * this is a closure of).
- *
- * Closures are needed to guarantee dead-lock freedom in the presence of
- *
- *     - nested state-machines (top-lock state-machine composed of sub-lock
- *       state-machines), and
- *
- *     - shared sub-locks.
- *
- * Specifically, many operations, such as lock enqueue, wait, unlock,
- * etc. start from a top-lock, and then operate on a sub-locks of this
- * top-lock, holding a top-lock mutex. When sub-lock state changes as a result
- * of such operation, this change has to be propagated to all top-locks that
- * share this sub-lock. Obviously, no natural lock ordering (e.g.,
- * top-to-bottom or bottom-to-top) captures this scenario, so try-locking has
- * to be used. Lock closure systematizes this try-and-repeat logic.
- */
-struct cl_lock_closure {
-	/**
-	 * Lock that is mutexed when closure construction is started. When
-	 * closure in is `wait' mode (cl_lock_closure::clc_wait), mutex on
-	 * origin is released before waiting.
-	 */
-	struct cl_lock   *clc_origin;
-	/**
-	 * List of enclosed locks, so far. Locks are linked here through
-	 * cl_lock::cll_inclosure.
-	 */
-	struct list_head	clc_list;
-	/**
-	 * True iff closure is in a `wait' mode. This determines what
-	 * cl_lock_enclosure() does when a lock L to be added to the closure
-	 * is currently mutexed by some other thread.
-	 *
-	 * If cl_lock_closure::clc_wait is not set, then closure construction
-	 * fails with CLO_REPEAT immediately.
-	 *
-	 * In wait mode, cl_lock_enclosure() waits until next attempt to build
-	 * a closure might succeed. To this end it releases an origin mutex
-	 * (cl_lock_closure::clc_origin), that has to be the only lock mutex
-	 * owned by the current thread, and then waits on L mutex (by grabbing
-	 * it and immediately releasing), before returning CLO_REPEAT to the
-	 * caller.
-	 */
-	int	       clc_wait;
-	/** Number of locks in the closure. */
-	int	       clc_nr;
-};
-
-/**
  * Layered client lock.
  */
 struct cl_lock {
-	/** Reference counter. */
-	atomic_t	  cll_ref;
 	/** List of slices. Immutable after creation. */
 	struct list_head	    cll_layers;
-	/**
-	 * Linkage into cl_lock::cll_descr::cld_obj::coh_locks list. Protected
-	 * by cl_lock::cll_descr::cld_obj::coh_lock_guard.
-	 */
-	struct list_head	    cll_linkage;
-	/**
-	 * Parameters of this lock. Protected by
-	 * cl_lock::cll_descr::cld_obj::coh_lock_guard nested within
-	 * cl_lock::cll_guard. Modified only on lock creation and in
-	 * cl_lock_modify().
-	 */
+	/** lock attribute, extent, cl_object, etc. */
 	struct cl_lock_descr  cll_descr;
-	/** Protected by cl_lock::cll_guard. */
-	enum cl_lock_state    cll_state;
-	/** signals state changes. */
-	wait_queue_head_t	   cll_wq;
-	/**
-	 * Recursive lock, most fields in cl_lock{} are protected by this.
-	 *
-	 * Locking rules: this mutex is never held across network
-	 * communication, except when lock is being canceled.
-	 *
-	 * Lock ordering: a mutex of a sub-lock is taken first, then a mutex
-	 * on a top-lock. Other direction is implemented through a
-	 * try-lock-repeat loop. Mutices of unrelated locks can be taken only
-	 * by try-locking.
-	 *
-	 * \see osc_lock_enqueue_wait(), lov_lock_cancel(), lov_sublock_wait().
-	 */
-	struct mutex		cll_guard;
-	struct task_struct	*cll_guarder;
-	int		   cll_depth;
-
-	/**
-	 * the owner for INTRANSIT state
-	 */
-	struct task_struct	*cll_intransit_owner;
-	int		   cll_error;
-	/**
-	 * Number of holds on a lock. A hold prevents a lock from being
-	 * canceled and destroyed. Protected by cl_lock::cll_guard.
-	 *
-	 * \see cl_lock_hold(), cl_lock_unhold(), cl_lock_release()
-	 */
-	int		   cll_holds;
-	 /**
-	  * Number of lock users. Valid in cl_lock_state::CLS_HELD state
-	  * only. Lock user pins lock in CLS_HELD state. Protected by
-	  * cl_lock::cll_guard.
-	  *
-	  * \see cl_wait(), cl_unuse().
-	  */
-	int		   cll_users;
-	/**
-	 * Flag bit-mask. Values from enum cl_lock_flags. Updates are
-	 * protected by cl_lock::cll_guard.
-	 */
-	unsigned long	 cll_flags;
-	/**
-	 * A linkage into a list of locks in a closure.
-	 *
-	 * \see cl_lock_closure
-	 */
-	struct list_head	    cll_inclosure;
-	/**
-	 * Confict lock@queuing time.
-	 */
-	struct cl_lock       *cll_conflict;
-	/**
-	 * A list of references to this lock, for debugging.
-	 */
-	struct lu_ref	 cll_reference;
-	/**
-	 * A list of holds on this lock, for debugging.
-	 */
-	struct lu_ref	 cll_holders;
-	/**
-	 * A reference for cl_lock::cll_descr::cld_obj. For debugging.
-	 */
-	struct lu_ref_link    cll_obj_ref;
-#ifdef CONFIG_LOCKDEP
-	/* "dep_map" name is assumed by lockdep.h macros. */
-	struct lockdep_map    dep_map;
-#endif
 };
 
 /**
@@ -1622,170 +1330,32 @@ struct cl_lock_slice {
 };
 
 /**
- * Possible (non-error) return values of ->clo_{enqueue,wait,unlock}().
- *
- * NOTE: lov_subresult() depends on ordering here.
- */
-enum cl_lock_transition {
-	/** operation cannot be completed immediately. Wait for state change. */
-	CLO_WAIT	= 1,
-	/** operation had to release lock mutex, restart. */
-	CLO_REPEAT      = 2,
-	/** lower layer re-enqueued. */
-	CLO_REENQUEUED  = 3,
-};
-
-/**
  *
  * \see vvp_lock_ops, lov_lock_ops, lovsub_lock_ops, osc_lock_ops
  */
 struct cl_lock_operations {
-	/**
-	 * \name statemachine
-	 *
-	 * State machine transitions. These 3 methods are called to transfer
-	 * lock from one state to another, as described in the commentary
-	 * above enum #cl_lock_state.
-	 *
-	 * \retval 0	  this layer has nothing more to do to before
-	 *		       transition to the target state happens;
-	 *
-	 * \retval CLO_REPEAT method had to release and re-acquire cl_lock
-	 *		    mutex, repeat invocation of transition method
-	 *		    across all layers;
-	 *
-	 * \retval CLO_WAIT   this layer cannot move to the target state
-	 *		    immediately, as it has to wait for certain event
-	 *		    (e.g., the communication with the server). It
-	 *		    is guaranteed, that when the state transfer
-	 *		    becomes possible, cl_lock::cll_wq wait-queue
-	 *		    is signaled. Caller can wait for this event by
-	 *		    calling cl_lock_state_wait();
-	 *
-	 * \retval -ve	failure, abort state transition, move the lock
-	 *		    into cl_lock_state::CLS_FREEING state, and set
-	 *		    cl_lock::cll_error.
-	 *
-	 * Once all layers voted to agree to transition (by returning 0), lock
-	 * is moved into corresponding target state. All state transition
-	 * methods are optional.
-	 */
 	/** @{ */
 	/**
 	 * Attempts to enqueue the lock. Called top-to-bottom.
 	 *
+	 * \retval 0	this layer has enqueued the lock successfully
+	 * \retval >0	this layer has enqueued the lock, but need to wait on
+	 *		@anchor for resources
+	 * \retval -ve	failure
+	 *
 	 * \see ccc_lock_enqueue(), lov_lock_enqueue(), lovsub_lock_enqueue(),
 	 * \see osc_lock_enqueue()
 	 */
 	int  (*clo_enqueue)(const struct lu_env *env,
 			    const struct cl_lock_slice *slice,
-			    struct cl_io *io, __u32 enqflags);
-	/**
-	 * Attempts to wait for enqueue result. Called top-to-bottom.
-	 *
-	 * \see ccc_lock_wait(), lov_lock_wait(), osc_lock_wait()
-	 */
-	int  (*clo_wait)(const struct lu_env *env,
-			 const struct cl_lock_slice *slice);
-	/**
-	 * Attempts to unlock the lock. Called bottom-to-top. In addition to
-	 * usual return values of lock state-machine methods, this can return
-	 * -ESTALE to indicate that lock cannot be returned to the cache, and
-	 * has to be re-initialized.
-	 * unuse is a one-shot operation, so it must NOT return CLO_WAIT.
-	 *
-	 * \see ccc_lock_unuse(), lov_lock_unuse(), osc_lock_unuse()
-	 */
-	int  (*clo_unuse)(const struct lu_env *env,
-			  const struct cl_lock_slice *slice);
-	/**
-	 * Notifies layer that cached lock is started being used.
-	 *
-	 * \pre lock->cll_state == CLS_CACHED
-	 *
-	 * \see lov_lock_use(), osc_lock_use()
-	 */
-	int  (*clo_use)(const struct lu_env *env,
-			const struct cl_lock_slice *slice);
-	/** @} statemachine */
-	/**
-	 * A method invoked when lock state is changed (as a result of state
-	 * transition). This is used, for example, to track when the state of
-	 * a sub-lock changes, to propagate this change to the corresponding
-	 * top-lock. Optional
-	 *
-	 * \see lovsub_lock_state()
-	 */
-	void (*clo_state)(const struct lu_env *env,
-			  const struct cl_lock_slice *slice,
-			  enum cl_lock_state st);
-	/**
-	 * Returns true, iff given lock is suitable for the given io, idea
-	 * being, that there are certain "unsafe" locks, e.g., ones acquired
-	 * for O_APPEND writes, that we don't want to re-use for a normal
-	 * write, to avoid the danger of cascading evictions. Optional. Runs
-	 * under cl_object_header::coh_lock_guard.
-	 *
-	 * XXX this should take more information about lock needed by
-	 * io. Probably lock description or something similar.
-	 *
-	 * \see lov_fits_into()
-	 */
-	int (*clo_fits_into)(const struct lu_env *env,
-			     const struct cl_lock_slice *slice,
-			     const struct cl_lock_descr *need,
-			     const struct cl_io *io);
-	/**
-	 * \name ast
-	 * Asynchronous System Traps. All of then are optional, all are
-	 * executed bottom-to-top.
-	 */
-	/** @{ */
-
+			    struct cl_io *io, struct cl_sync_io *anchor);
 	/**
-	 * Cancellation callback. Cancel a lock voluntarily, or under
-	 * the request of server.
+	 * Cancel a lock, release its DLM lock ref, while does not cancel the
+	 * DLM lock
 	 */
 	void (*clo_cancel)(const struct lu_env *env,
 			   const struct cl_lock_slice *slice);
-	/**
-	 * Lock weighting ast. Executed to estimate how precious this lock
-	 * is. The sum of results across all layers is used to determine
-	 * whether lock worth keeping in cache given present memory usage.
-	 *
-	 * \see osc_lock_weigh(), vvp_lock_weigh(), lovsub_lock_weigh().
-	 */
-	unsigned long (*clo_weigh)(const struct lu_env *env,
-				   const struct cl_lock_slice *slice);
-	/** @} ast */
-
-	/**
-	 * \see lovsub_lock_closure()
-	 */
-	int (*clo_closure)(const struct lu_env *env,
-			   const struct cl_lock_slice *slice,
-			   struct cl_lock_closure *closure);
-	/**
-	 * Executed bottom-to-top when lock description changes (e.g., as a
-	 * result of server granting more generous lock than was requested).
-	 *
-	 * \see lovsub_lock_modify()
-	 */
-	int (*clo_modify)(const struct lu_env *env,
-			  const struct cl_lock_slice *slice,
-			  const struct cl_lock_descr *updated);
-	/**
-	 * Notifies layers (bottom-to-top) that lock is going to be
-	 * destroyed. Responsibility of layers is to prevent new references on
-	 * this lock from being acquired once this method returns.
-	 *
-	 * This can be called multiple times due to the races.
-	 *
-	 * \see cl_lock_delete()
-	 * \see osc_lock_delete(), lovsub_lock_delete()
-	 */
-	void (*clo_delete)(const struct lu_env *env,
-			   const struct cl_lock_slice *slice);
+	/** @} */
 	/**
 	 * Destructor. Frees resources and the slice.
 	 *
@@ -2165,9 +1735,13 @@ enum cl_enq_flags {
 	 */
 	CEF_AGL	  = 0x00000020,
 	/**
+	 * enqueue a lock to test DLM lock existence.
+	 */
+	CEF_PEEK	= 0x00000040,
+	/**
 	 * mask of enq_flags.
 	 */
-	CEF_MASK	 = 0x0000003f,
+	CEF_MASK         = 0x0000007f,
 };
 
 /**
@@ -2177,12 +1751,12 @@ enum cl_enq_flags {
 struct cl_io_lock_link {
 	/** linkage into one of cl_lockset lists. */
 	struct list_head	   cill_linkage;
-	struct cl_lock_descr cill_descr;
-	struct cl_lock      *cill_lock;
+	struct cl_lock          cill_lock;
 	/** optional destructor */
 	void	       (*cill_fini)(const struct lu_env *env,
 				    struct cl_io_lock_link *link);
 };
+#define cill_descr	cill_lock.cll_descr
 
 /**
  * Lock-set represents a collection of locks, that io needs at a
@@ -2216,8 +1790,6 @@ struct cl_io_lock_link {
 struct cl_lockset {
 	/** locks to be acquired. */
 	struct list_head  cls_todo;
-	/** locks currently being processed. */
-	struct list_head  cls_curr;
 	/** locks acquired. */
 	struct list_head  cls_done;
 };
@@ -2581,9 +2153,7 @@ struct cl_site {
 	 * and top-locks (and top-pages) are accounted here.
 	 */
 	struct cache_stats    cs_pages;
-	struct cache_stats    cs_locks;
 	atomic_t	  cs_pages_state[CPS_NR];
-	atomic_t	  cs_locks_state[CLS_NR];
 };
 
 int  cl_site_init(struct cl_site *s, struct cl_device *top);
@@ -2707,7 +2277,7 @@ int  cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
 		       struct ost_lvb *lvb);
 int  cl_conf_set(const struct lu_env *env, struct cl_object *obj,
 		 const struct cl_object_conf *conf);
-void cl_object_prune(const struct lu_env *env, struct cl_object *obj);
+int cl_object_prune(const struct lu_env *env, struct cl_object *obj);
 void cl_object_kill(const struct lu_env *env, struct cl_object *obj);
 
 /**
@@ -2845,121 +2415,17 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
  * @{
  */
 
-struct cl_lock *cl_lock_hold(const struct lu_env *env, const struct cl_io *io,
-			     const struct cl_lock_descr *need,
-			     const char *scope, const void *source);
-struct cl_lock *cl_lock_peek(const struct lu_env *env, const struct cl_io *io,
-			     const struct cl_lock_descr *need,
-			     const char *scope, const void *source);
-struct cl_lock *cl_lock_request(const struct lu_env *env, struct cl_io *io,
-				const struct cl_lock_descr *need,
-				const char *scope, const void *source);
-struct cl_lock *cl_lock_at_pgoff(const struct lu_env *env,
-				 struct cl_object *obj, pgoff_t index,
-				 struct cl_lock *except, int pending,
-				 int canceld);
+int cl_lock_request(const struct lu_env *env, struct cl_io *io,
+		    struct cl_lock *lock);
+int cl_lock_init(const struct lu_env *env, struct cl_lock *lock,
+		 const struct cl_io *io);
+void cl_lock_fini(const struct lu_env *env, struct cl_lock *lock);
 const struct cl_lock_slice *cl_lock_at(const struct cl_lock *lock,
 				       const struct lu_device_type *dtype);
-
-void cl_lock_get(struct cl_lock *lock);
-void cl_lock_get_trust(struct cl_lock *lock);
-void cl_lock_put(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_hold_add(const struct lu_env *env, struct cl_lock *lock,
-		      const char *scope, const void *source);
-void cl_lock_hold_release(const struct lu_env *env, struct cl_lock *lock,
-			  const char *scope, const void *source);
-void cl_lock_unhold(const struct lu_env *env, struct cl_lock *lock,
-		    const char *scope, const void *source);
-void cl_lock_release(const struct lu_env *env, struct cl_lock *lock,
-		     const char *scope, const void *source);
-void cl_lock_user_add(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_user_del(const struct lu_env *env, struct cl_lock *lock);
-
-int cl_lock_is_intransit(struct cl_lock *lock);
-
-int cl_lock_enqueue_wait(const struct lu_env *env, struct cl_lock *lock,
-			 int keep_mutex);
-
-/** \name statemachine statemachine
- * Interface to lock state machine consists of 3 parts:
- *
- *     - "try" functions that attempt to effect a state transition. If state
- *     transition is not possible right now (e.g., if it has to wait for some
- *     asynchronous event to occur), these functions return
- *     cl_lock_transition::CLO_WAIT.
- *
- *     - "non-try" functions that implement synchronous blocking interface on
- *     top of non-blocking "try" functions. These functions repeatedly call
- *     corresponding "try" versions, and if state transition is not possible
- *     immediately, wait for lock state change.
- *
- *     - methods from cl_lock_operations, called by "try" functions. Lock can
- *     be advanced to the target state only when all layers voted that they
- *     are ready for this transition. "Try" functions call methods under lock
- *     mutex. If a layer had to release a mutex, it re-acquires it and returns
- *     cl_lock_transition::CLO_REPEAT, causing "try" function to call all
- *     layers again.
- *
- * TRY	      NON-TRY      METHOD			    FINAL STATE
- *
- * cl_enqueue_try() cl_enqueue() cl_lock_operations::clo_enqueue() CLS_ENQUEUED
- *
- * cl_wait_try()    cl_wait()    cl_lock_operations::clo_wait()    CLS_HELD
- *
- * cl_unuse_try()   cl_unuse()   cl_lock_operations::clo_unuse()   CLS_CACHED
- *
- * cl_use_try()     NONE	 cl_lock_operations::clo_use()     CLS_HELD
- *
- * @{
- */
-
-int cl_wait(const struct lu_env *env, struct cl_lock *lock);
-void cl_unuse(const struct lu_env *env, struct cl_lock *lock);
-int cl_enqueue_try(const struct lu_env *env, struct cl_lock *lock,
-		   struct cl_io *io, __u32 flags);
-int cl_unuse_try(const struct lu_env *env, struct cl_lock *lock);
-int cl_wait_try(const struct lu_env *env, struct cl_lock *lock);
-int cl_use_try(const struct lu_env *env, struct cl_lock *lock, int atomic);
-
-/** @} statemachine */
-
-void cl_lock_signal(const struct lu_env *env, struct cl_lock *lock);
-int cl_lock_state_wait(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_state_set(const struct lu_env *env, struct cl_lock *lock,
-		       enum cl_lock_state state);
-int cl_queue_match(const struct list_head *queue,
-		   const struct cl_lock_descr *need);
-
-void cl_lock_mutex_get(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_mutex_put(const struct lu_env *env, struct cl_lock *lock);
-int cl_lock_is_mutexed(struct cl_lock *lock);
-int cl_lock_nr_mutexed(const struct lu_env *env);
-int cl_lock_discard_pages(const struct lu_env *env, struct cl_lock *lock);
-int cl_lock_ext_match(const struct cl_lock_descr *has,
-		      const struct cl_lock_descr *need);
-int cl_lock_descr_match(const struct cl_lock_descr *has,
-			const struct cl_lock_descr *need);
-int cl_lock_mode_match(enum cl_lock_mode has, enum cl_lock_mode need);
-int cl_lock_modify(const struct lu_env *env, struct cl_lock *lock,
-		   const struct cl_lock_descr *desc);
-
-void cl_lock_closure_init(const struct lu_env *env,
-			  struct cl_lock_closure *closure,
-			  struct cl_lock *origin, int wait);
-void cl_lock_closure_fini(struct cl_lock_closure *closure);
-int cl_lock_closure_build(const struct lu_env *env, struct cl_lock *lock,
-			  struct cl_lock_closure *closure);
-void cl_lock_disclosure(const struct lu_env *env,
-			struct cl_lock_closure *closure);
-int cl_lock_enclosure(const struct lu_env *env, struct cl_lock *lock,
-		      struct cl_lock_closure *closure);
-
+void cl_lock_release(const struct lu_env *env, struct cl_lock *lock);
+int cl_lock_enqueue(const struct lu_env *env, struct cl_io *io,
+		    struct cl_lock *lock, struct cl_sync_io *anchor);
 void cl_lock_cancel(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_delete(const struct lu_env *env, struct cl_lock *lock);
-void cl_lock_error(const struct lu_env *env, struct cl_lock *lock, int error);
-void cl_locks_prune(const struct lu_env *env, struct cl_object *obj, int wait);
-
-unsigned long cl_lock_weigh(const struct lu_env *env, struct cl_lock *lock);
 
 /** @} cl_lock */
 
diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index a8c8788..82af8ae 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -99,10 +99,6 @@ struct ccc_io {
 		} write;
 	} u;
 	/**
-	 * True iff io is processing glimpse right now.
-	 */
-	int		  cui_glimpse;
-	/**
 	 * Layout version when this IO is initialized
 	 */
 	__u32		cui_layout_gen;
@@ -123,6 +119,7 @@ extern struct lu_context_key ccc_key;
 extern struct lu_context_key ccc_session_key;
 
 struct ccc_thread_info {
+	struct cl_lock		cti_lock;
 	struct cl_lock_descr cti_descr;
 	struct cl_io	 cti_io;
 	struct cl_attr       cti_attr;
@@ -137,6 +134,14 @@ static inline struct ccc_thread_info *ccc_env_info(const struct lu_env *env)
 	return info;
 }
 
+static inline struct cl_lock *ccc_env_lock(const struct lu_env *env)
+{
+	struct cl_lock *lock = &ccc_env_info(env)->cti_lock;
+
+	memset(lock, 0, sizeof(*lock));
+	return lock;
+}
+
 static inline struct cl_attr *ccc_env_thread_attr(const struct lu_env *env)
 {
 	struct cl_attr *attr = &ccc_env_info(env)->cti_attr;
@@ -308,18 +313,7 @@ void ccc_lock_delete(const struct lu_env *env,
 void ccc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice);
 int ccc_lock_enqueue(const struct lu_env *env,
 		     const struct cl_lock_slice *slice,
-		     struct cl_io *io, __u32 enqflags);
-int ccc_lock_use(const struct lu_env *env, const struct cl_lock_slice *slice);
-int ccc_lock_unuse(const struct lu_env *env, const struct cl_lock_slice *slice);
-int ccc_lock_wait(const struct lu_env *env, const struct cl_lock_slice *slice);
-int ccc_lock_fits_into(const struct lu_env *env,
-		       const struct cl_lock_slice *slice,
-		       const struct cl_lock_descr *need,
-		       const struct cl_io *io);
-void ccc_lock_state(const struct lu_env *env,
-		    const struct cl_lock_slice *slice,
-		    enum cl_lock_state state);
-
+		     struct cl_io *io, struct cl_sync_io *anchor);
 int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end);
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index da8bc6e..4318511 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2582,6 +2582,8 @@ struct ldlm_extent {
 	__u64 gid;
 };
 
+#define LDLM_GID_ANY ((__u64)-1)
+
 static inline int ldlm_extent_overlap(struct ldlm_extent *ex1,
 				      struct ldlm_extent *ex2)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 8b0364f..b1abdc2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -71,6 +71,7 @@ struct obd_device;
  */
 enum ldlm_error {
 	ELDLM_OK = 0,
+	ELDLM_LOCK_MATCHED = 1,
 
 	ELDLM_LOCK_CHANGED = 300,
 	ELDLM_LOCK_ABORTED = 301,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b497ce4..7fedbec 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -748,6 +748,7 @@ int ldlm_error2errno(enum ldlm_error error)
 
 	switch (error) {
 	case ELDLM_OK:
+	case ELDLM_LOCK_MATCHED:
 		result = 0;
 		break;
 	case ELDLM_LOCK_CHANGED:
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index ecd65a7..27a051b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -657,7 +657,7 @@ void ldlm_lock_addref(struct lustre_handle *lockh, __u32 mode)
 	struct ldlm_lock *lock;
 
 	lock = ldlm_handle2lock(lockh);
-	LASSERT(lock);
+	LASSERTF(lock, "Non-existing lock: %llx\n", lockh->cookie);
 	ldlm_lock_addref_internal(lock, mode);
 	LDLM_LOCK_PUT(lock);
 }
@@ -1092,6 +1092,7 @@ static struct ldlm_lock *search_queue(struct list_head *queue,
 
 		if (unlikely(match == LCK_GROUP) &&
 		    lock->l_resource->lr_type == LDLM_EXTENT &&
+		    policy->l_extent.gid != LDLM_GID_ANY &&
 		    lock->l_policy_data.l_extent.gid != policy->l_extent.gid)
 			continue;
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index d5968e0..42925ac 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -347,7 +347,6 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	struct ldlm_lock *lock;
 	struct ldlm_reply *reply;
 	int cleanup_phase = 1;
-	int size = 0;
 
 	lock = ldlm_handle2lock(lockh);
 	/* ldlm_cli_enqueue is holding a reference on this lock. */
@@ -375,8 +374,8 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		goto cleanup;
 	}
 
-	if (lvb_len != 0) {
-		LASSERT(lvb);
+	if (lvb_len > 0) {
+		int size = 0;
 
 		size = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB,
 					    RCL_SERVER);
@@ -390,12 +389,13 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			rc = -EINVAL;
 			goto cleanup;
 		}
+		lvb_len = size;
 	}
 
 	if (rc == ELDLM_LOCK_ABORTED) {
-		if (lvb_len != 0)
+		if (lvb_len > 0 && lvb)
 			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
-					   lvb, size);
+					   lvb, lvb_len);
 		if (rc == 0)
 			rc = ELDLM_LOCK_ABORTED;
 		goto cleanup;
@@ -489,7 +489,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	/* If the lock has already been granted by a completion AST, don't
 	 * clobber the LVB with an older one.
 	 */
-	if (lvb_len != 0) {
+	if (lvb_len > 0) {
 		/* We must lock or a racing completion might update lvb without
 		 * letting us know and we'll clobber the correct value.
 		 * Cannot unlock after the check either, as that still leaves
@@ -498,7 +498,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		lock_res_and_lock(lock);
 		if (lock->l_req_mode != lock->l_granted_mode)
 			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
-					   lock->l_lvb_data, size);
+					   lock->l_lvb_data, lvb_len);
 		unlock_res_and_lock(lock);
 		if (rc < 0) {
 			cleanup_phase = 1;
@@ -518,7 +518,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		}
 	}
 
-	if (lvb_len && lvb) {
+	if (lvb_len > 0 && lvb) {
 		/* Copy the LVB here, and not earlier, because the completion
 		 * AST (if any) can override what we got in the reply
 		 */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 9dede87..242a664 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1400,3 +1400,4 @@ void ldlm_resource_dump(int level, struct ldlm_resource *res)
 			LDLM_DEBUG_LIMIT(level, lock, "###");
 	}
 }
+EXPORT_SYMBOL(ldlm_resource_dump);
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 9b0e2ec..0759dfc 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -86,17 +86,17 @@ blkcnt_t dirty_cnt(struct inode *inode)
 int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 		    struct inode *inode, struct cl_object *clob, int agl)
 {
-	struct cl_lock_descr *descr = &ccc_env_info(env)->cti_descr;
 	struct ll_inode_info *lli   = ll_i2info(inode);
 	const struct lu_fid  *fid   = lu_object_fid(&clob->co_lu);
-	struct ccc_io	*cio   = ccc_env_io(env);
-	struct cl_lock       *lock;
 	int result;
 
 	result = 0;
 	if (!(lli->lli_flags & LLIF_MDS_SIZE_LOCK)) {
 		CDEBUG(D_DLMTRACE, "Glimpsing inode " DFID "\n", PFID(fid));
 		if (lli->lli_has_smd) {
+			struct cl_lock *lock = ccc_env_lock(env);
+			struct cl_lock_descr *descr = &lock->cll_descr;
+
 			/* NOTE: this looks like DLM lock request, but it may
 			 *       not be one. Due to CEF_ASYNC flag (translated
 			 *       to LDLM_FL_HAS_INTENT by osc), this is
@@ -113,11 +113,10 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 			 */
 			*descr = whole_file;
 			descr->cld_obj   = clob;
-			descr->cld_mode  = CLM_PHANTOM;
+			descr->cld_mode  = CLM_READ;
 			descr->cld_enq_flags = CEF_ASYNC | CEF_MUST;
 			if (agl)
 				descr->cld_enq_flags |= CEF_AGL;
-			cio->cui_glimpse = 1;
 			/*
 			 * CEF_ASYNC is used because glimpse sub-locks cannot
 			 * deadlock (because they never conflict with other
@@ -126,19 +125,11 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 			 * CEF_MUST protects glimpse lock from conversion into
 			 * a lockless mode.
 			 */
-			lock = cl_lock_request(env, io, descr, "glimpse",
-					       current);
-			cio->cui_glimpse = 0;
-
-			if (!lock)
-				return 0;
+			result = cl_lock_request(env, io, lock);
+			if (result < 0)
+				return result;
 
-			if (IS_ERR(lock))
-				return PTR_ERR(lock);
-
-			LASSERT(agl == 0);
-			result = cl_wait(env, lock);
-			if (result == 0) {
+			if (!agl) {
 				ll_merge_attr(env, inode);
 				if (i_size_read(inode) > 0 &&
 				    inode->i_blocks == 0) {
@@ -150,9 +141,8 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 					 */
 					inode->i_blocks = dirty_cnt(inode);
 				}
-				cl_unuse(env, lock);
 			}
-			cl_lock_release(env, lock, "glimpse", current);
+			cl_lock_release(env, lock);
 		} else {
 			CDEBUG(D_DLMTRACE, "No objects for inode\n");
 			ll_merge_attr(env, inode);
@@ -233,10 +223,7 @@ int cl_local_size(struct inode *inode)
 {
 	struct lu_env	   *env = NULL;
 	struct cl_io	    *io  = NULL;
-	struct ccc_thread_info  *cti;
 	struct cl_object	*clob;
-	struct cl_lock_descr    *descr;
-	struct cl_lock	  *lock;
 	int		      result;
 	int		      refcheck;
 
@@ -252,19 +239,15 @@ int cl_local_size(struct inode *inode)
 	if (result > 0) {
 		result = io->ci_result;
 	} else if (result == 0) {
-		cti = ccc_env_info(env);
-		descr = &cti->cti_descr;
+		struct cl_lock *lock = ccc_env_lock(env);
 
-		*descr = whole_file;
-		descr->cld_obj = clob;
-		lock = cl_lock_peek(env, io, descr, "localsize", current);
-		if (lock) {
+		lock->cll_descr = whole_file;
+		lock->cll_descr.cld_enq_flags = CEF_PEEK;
+		lock->cll_descr.cld_obj = clob;
+		result = cl_lock_request(env, io, lock);
+		if (result == 0) {
 			ll_merge_attr(env, inode);
-			cl_unuse(env, lock);
-			cl_lock_release(env, lock, "localsize", current);
-			result = 0;
-		} else {
-			result = -ENODATA;
+			cl_lock_release(env, lock);
 		}
 	}
 	cl_io_fini(env, io);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index fde96d3..b339d1b 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -475,12 +475,6 @@ int ccc_transient_page_prep(const struct lu_env *env,
  *
  */
 
-void ccc_lock_delete(const struct lu_env *env,
-		     const struct cl_lock_slice *slice)
-{
-	CLOBINVRNT(env, slice->cls_obj, ccc_object_invariant(slice->cls_obj));
-}
-
 void ccc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice)
 {
 	struct ccc_lock *clk = cl2ccc_lock(slice);
@@ -490,111 +484,12 @@ void ccc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice)
 
 int ccc_lock_enqueue(const struct lu_env *env,
 		     const struct cl_lock_slice *slice,
-		     struct cl_io *unused, __u32 enqflags)
-{
-	CLOBINVRNT(env, slice->cls_obj, ccc_object_invariant(slice->cls_obj));
-	return 0;
-}
-
-int ccc_lock_use(const struct lu_env *env, const struct cl_lock_slice *slice)
-{
-	CLOBINVRNT(env, slice->cls_obj, ccc_object_invariant(slice->cls_obj));
-	return 0;
-}
-
-int ccc_lock_unuse(const struct lu_env *env, const struct cl_lock_slice *slice)
+		     struct cl_io *unused, struct cl_sync_io *anchor)
 {
 	CLOBINVRNT(env, slice->cls_obj, ccc_object_invariant(slice->cls_obj));
 	return 0;
 }
 
-int ccc_lock_wait(const struct lu_env *env, const struct cl_lock_slice *slice)
-{
-	CLOBINVRNT(env, slice->cls_obj, ccc_object_invariant(slice->cls_obj));
-	return 0;
-}
-
-/**
- * Implementation of cl_lock_operations::clo_fits_into() methods for ccc
- * layer. This function is executed every time io finds an existing lock in
- * the lock cache while creating new lock. This function has to decide whether
- * cached lock "fits" into io.
- *
- * \param slice lock to be checked
- * \param io    IO that wants a lock.
- *
- * \see lov_lock_fits_into().
- */
-int ccc_lock_fits_into(const struct lu_env *env,
-		       const struct cl_lock_slice *slice,
-		       const struct cl_lock_descr *need,
-		       const struct cl_io *io)
-{
-	const struct cl_lock       *lock  = slice->cls_lock;
-	const struct cl_lock_descr *descr = &lock->cll_descr;
-	const struct ccc_io	*cio   = ccc_env_io(env);
-	int			 result;
-
-	/*
-	 * Work around DLM peculiarity: it assumes that glimpse
-	 * (LDLM_FL_HAS_INTENT) lock is always LCK_PR, and returns reads lock
-	 * when asked for LCK_PW lock with LDLM_FL_HAS_INTENT flag set. Make
-	 * sure that glimpse doesn't get CLM_WRITE top-lock, so that it
-	 * doesn't enqueue CLM_WRITE sub-locks.
-	 */
-	if (cio->cui_glimpse)
-		result = descr->cld_mode != CLM_WRITE;
-
-	/*
-	 * Also, don't match incomplete write locks for read, otherwise read
-	 * would enqueue missing sub-locks in the write mode.
-	 */
-	else if (need->cld_mode != descr->cld_mode)
-		result = lock->cll_state >= CLS_ENQUEUED;
-	else
-		result = 1;
-	return result;
-}
-
-/**
- * Implements cl_lock_operations::clo_state() method for ccc layer, invoked
- * whenever lock state changes. Transfers object attributes, that might be
- * updated as a result of lock acquiring into inode.
- */
-void ccc_lock_state(const struct lu_env *env,
-		    const struct cl_lock_slice *slice,
-		    enum cl_lock_state state)
-{
-	struct cl_lock *lock = slice->cls_lock;
-
-	/*
-	 * Refresh inode attributes when the lock is moving into CLS_HELD
-	 * state, and only when this is a result of real enqueue, rather than
-	 * of finding lock in the cache.
-	 */
-	if (state == CLS_HELD && lock->cll_state < CLS_HELD) {
-		struct cl_object *obj;
-		struct inode     *inode;
-
-		obj   = slice->cls_obj;
-		inode = ccc_object_inode(obj);
-
-		/* vmtruncate() sets the i_size
-		 * under both a DLM lock and the
-		 * ll_inode_size_lock().  If we don't get the
-		 * ll_inode_size_lock() here we can match the DLM lock and
-		 * reset i_size.  generic_file_write can then trust the
-		 * stale i_size when doing appending writes and effectively
-		 * cancel the result of the truncate.  Getting the
-		 * ll_inode_size_lock() after the enqueue maintains the DLM
-		 * -> ll_inode_size_lock() acquiring order.
-		 */
-		if (lock->cll_descr.cld_start == 0 &&
-		    lock->cll_descr.cld_end == CL_PAGE_EOF)
-			ll_merge_attr(env, inode);
-	}
-}
-
 /*****************************************************************************
  *
  * io operations.
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index f68c368..4c12e21 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -145,7 +145,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 	io->ci_ignore_layout = 1;
 
 	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
-	if (rc) {
+	if (rc != 0) {
 		cl_io_fini(env, io);
 		cl_env_put(env, &refcheck);
 		/* Does not make sense to take GL for released layout */
@@ -154,7 +154,8 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		return rc;
 	}
 
-	descr = &ccc_env_info(env)->cti_descr;
+	lock = ccc_env_lock(env);
+	descr = &lock->cll_descr;
 	descr->cld_obj = obj;
 	descr->cld_start = 0;
 	descr->cld_end = CL_PAGE_EOF;
@@ -164,11 +165,11 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 	enqflags = CEF_MUST | (nonblock ? CEF_NONBLOCK : 0);
 	descr->cld_enq_flags = enqflags;
 
-	lock = cl_lock_request(env, io, descr, GROUPLOCK_SCOPE, current);
-	if (IS_ERR(lock)) {
+	rc = cl_lock_request(env, io, lock);
+	if (rc < 0) {
 		cl_io_fini(env, io);
 		cl_env_put(env, &refcheck);
-		return PTR_ERR(lock);
+		return rc;
 	}
 
 	cg->cg_env  = cl_env_get(&refcheck);
@@ -194,8 +195,7 @@ void cl_put_grouplock(struct ccc_grouplock *cg)
 	cl_env_implant(env, &refcheck);
 	cl_env_put(env, &refcheck);
 
-	cl_unuse(env, lock);
-	cl_lock_release(env, lock, GROUPLOCK_SCOPE, current);
+	cl_lock_release(env, lock);
 	cl_io_fini(env, io);
 	cl_env_put(env, NULL);
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index e2fea8c..50d8289 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -150,8 +150,7 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	 * If this page holds the last refc of cl_object, the following
 	 * call path may cause reschedule:
 	 *   cl_page_put -> cl_page_free -> cl_object_put ->
-	 *     lu_object_put -> lu_object_free -> lov_delete_raid0 ->
-	 *     cl_locks_prune.
+	 *     lu_object_put -> lu_object_free -> lov_delete_raid0.
 	 *
 	 * However, the kernel can't get rid of this inode until all pages have
 	 * been cleaned up. Now that we hold page lock here, it's pretty safe
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index c7db318..fb6f932 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -233,7 +233,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	ldlm_policy_data_t      policy;
 	unsigned long	   addr;
 	ssize_t		 count;
-	int		     result;
+	int		 result = 0;
 	struct iov_iter i;
 	struct iovec iov;
 
@@ -265,10 +265,10 @@ static int vvp_mmap_locks(const struct lu_env *env,
 
 			if (ll_file_nolock(vma->vm_file)) {
 				/*
-				 * For no lock case, a lockless lock will be
-				 * generated.
+				 * For no lock case is not allowed for mmap
 				 */
-				flags = CEF_NEVER;
+				result = -EINVAL;
+				break;
 			}
 
 			/*
@@ -290,10 +290,8 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			       descr->cld_mode, descr->cld_start,
 			       descr->cld_end);
 
-			if (result < 0) {
-				up_read(&mm->mmap_sem);
-				return result;
-			}
+			if (result < 0)
+				break;
 
 			if (vma->vm_end - addr >= count)
 				break;
@@ -302,8 +300,10 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			addr = vma->vm_end;
 		}
 		up_read(&mm->mmap_sem);
+		if (result < 0)
+			break;
 	}
-	return 0;
+	return result;
 }
 
 static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
@@ -781,6 +781,7 @@ static int vvp_io_write_start(const struct lu_env *env,
 		 * PARALLEL IO This has to be changed for parallel IO doing
 		 * out-of-order writes.
 		 */
+		ll_merge_attr(env, inode);
 		pos = io->u.ci_wr.wr.crw_pos = i_size_read(inode);
 		cio->cui_iocb->ki_pos = pos;
 	} else {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index ff09480..8c505a6 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -51,32 +51,9 @@
  *
  */
 
-/**
- * Estimates lock value for the purpose of managing the lock cache during
- * memory shortages.
- *
- * Locks for memory mapped files are almost infinitely precious, others are
- * junk. "Mapped locks" are heavy, but not infinitely heavy, so that they are
- * ordered within themselves by weights assigned from other layers.
- */
-static unsigned long vvp_lock_weigh(const struct lu_env *env,
-				    const struct cl_lock_slice *slice)
-{
-	struct ccc_object *cob = cl2ccc(slice->cls_obj);
-
-	return atomic_read(&cob->cob_mmap_cnt) > 0 ? ~0UL >> 2 : 0;
-}
-
 static const struct cl_lock_operations vvp_lock_ops = {
-	.clo_delete    = ccc_lock_delete,
 	.clo_fini      = ccc_lock_fini,
-	.clo_enqueue   = ccc_lock_enqueue,
-	.clo_wait      = ccc_lock_wait,
-	.clo_use       = ccc_lock_use,
-	.clo_unuse     = ccc_lock_unuse,
-	.clo_fits_into = ccc_lock_fits_into,
-	.clo_state     = ccc_lock_state,
-	.clo_weigh     = vvp_lock_weigh
+	.clo_enqueue   = ccc_lock_enqueue
 };
 
 int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index d03eb2b..34210db 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -170,11 +170,15 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 	struct inode *inode = ccc_object_inode(obj);
 	int rc;
 
-	rc = cl_sync_file_range(inode, 0, OBD_OBJECT_EOF, CL_FSYNC_ALL, 1);
-	if (rc == 0)
-		truncate_inode_pages(inode->i_mapping, 0);
+	rc = cl_sync_file_range(inode, 0, OBD_OBJECT_EOF, CL_FSYNC_LOCAL, 1);
+	if (rc < 0) {
+		CDEBUG(D_VFSTRACE, DFID ": writeback failed: %d\n",
+		       PFID(lu_object_fid(&obj->co_lu)), rc);
+		return rc;
+	}
 
-	return rc;
+	truncate_inode_pages(inode->i_mapping, 0);
+	return 0;
 }
 
 static const struct cl_object_operations vvp_ops = {
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 9b3d13b..dfe41a8 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -281,24 +281,17 @@ struct lov_object {
 };
 
 /**
- * Flags that top-lock can set on each of its sub-locks.
- */
-enum lov_sub_flags {
-	/** Top-lock acquired a hold (cl_lock_hold()) on a sub-lock. */
-	LSF_HELD = 1 << 0
-};
-
-/**
  * State lov_lock keeps for each sub-lock.
  */
 struct lov_lock_sub {
 	/** sub-lock itself */
-	struct lovsub_lock  *sub_lock;
-	/** An array of per-sub-lock flags, taken from enum lov_sub_flags */
-	unsigned	     sub_flags;
+	struct cl_lock		sub_lock;
+	/** Set if the sublock has ever been enqueued, meaning it may
+	 * hold resources of underlying layers
+	 */
+	unsigned int		sub_is_enqueued:1,
+				sub_initialized:1;
 	int		  sub_stripe;
-	struct cl_lock_descr sub_descr;
-	struct cl_lock_descr sub_got;
 };
 
 /**
@@ -308,59 +301,8 @@ struct lov_lock {
 	struct cl_lock_slice   lls_cl;
 	/** Number of sub-locks in this lock */
 	int		    lls_nr;
-	/**
-	 * Number of existing sub-locks.
-	 */
-	unsigned	       lls_nr_filled;
-	/**
-	 * Set when sub-lock was canceled, while top-lock was being
-	 * used, or unused.
-	 */
-	unsigned int	       lls_cancel_race:1;
-	/**
-	 * An array of sub-locks
-	 *
-	 * There are two issues with managing sub-locks:
-	 *
-	 *     - sub-locks are concurrently canceled, and
-	 *
-	 *     - sub-locks are shared with other top-locks.
-	 *
-	 * To manage cancellation, top-lock acquires a hold on a sublock
-	 * (lov_sublock_adopt()) when the latter is inserted into
-	 * lov_lock::lls_sub[]. This hold is released (lov_sublock_release())
-	 * when top-lock is going into CLS_CACHED state or destroyed. Hold
-	 * prevents sub-lock from cancellation.
-	 *
-	 * Sub-lock sharing means, among other things, that top-lock that is
-	 * in the process of creation (i.e., not yet inserted into lock list)
-	 * is already accessible to other threads once@least one of its
-	 * sub-locks is created, see lov_lock_sub_init().
-	 *
-	 * Sub-lock can be in one of the following states:
-	 *
-	 *     - doesn't exist, lov_lock::lls_sub[]::sub_lock == NULL. Such
-	 *       sub-lock was either never created (top-lock is in CLS_NEW
-	 *       state), or it was created, then canceled, then destroyed
-	 *       (lov_lock_unlink() cleared sub-lock pointer in the top-lock).
-	 *
-	 *     - sub-lock exists and is on
-	 *       hold. (lov_lock::lls_sub[]::sub_flags & LSF_HELD). This is a
-	 *       normal state of a sub-lock in CLS_HELD and CLS_CACHED states
-	 *       of a top-lock.
-	 *
-	 *     - sub-lock exists, but is not held by the top-lock. This
-	 *       happens after top-lock released a hold on sub-locks before
-	 *       going into cache (lov_lock_unuse()).
-	 *
-	 * \todo To support wide-striping, array has to be replaced with a set
-	 * of queues to avoid scanning.
-	 */
-	struct lov_lock_sub   *lls_sub;
-	/**
-	 * Original description with which lock was enqueued.
-	 */
-	struct cl_lock_descr   lls_orig;
+	/** sublock array */
+	struct lov_lock_sub     lls_sub[0];
 };
 
 struct lov_page {
@@ -445,7 +387,6 @@ struct lov_thread_info {
 	struct ost_lvb	  lti_lvb;
 	struct cl_2queue	lti_cl2q;
 	struct cl_page_list     lti_plist;
-	struct cl_lock_closure  lti_closure;
 	wait_queue_t	  lti_waiter;
 	struct cl_attr          lti_attr;
 };
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 532ef87..dccc634 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -143,9 +143,7 @@ static void *lov_key_init(const struct lu_context *ctx,
 	struct lov_thread_info *info;
 
 	info = kmem_cache_zalloc(lov_thread_kmem, GFP_NOFS);
-	if (info)
-		INIT_LIST_HEAD(&info->lti_closure.clc_list);
-	else
+	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
@@ -155,7 +153,6 @@ static void lov_key_fini(const struct lu_context *ctx,
 {
 	struct lov_thread_info *info = data;
 
-	LINVRNT(list_empty(&info->lti_closure.clc_list));
 	kmem_cache_free(lov_thread_kmem, info);
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index ae854bc..1b203d1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -46,11 +46,6 @@
  *  @{
  */
 
-static struct cl_lock_closure *lov_closure_get(const struct lu_env *env,
-					       struct cl_lock *parent);
-
-static int lov_lock_unuse(const struct lu_env *env,
-			  const struct cl_lock_slice *slice);
 /*****************************************************************************
  *
  * Lov lock operations.
@@ -58,7 +53,7 @@ static int lov_lock_unuse(const struct lu_env *env,
  */
 
 static struct lov_sublock_env *lov_sublock_env_get(const struct lu_env *env,
-						   struct cl_lock *parent,
+						   const struct cl_lock *parent,
 						   struct lov_lock_sub *lls)
 {
 	struct lov_sublock_env *subenv;
@@ -100,185 +95,26 @@ static void lov_sublock_env_put(struct lov_sublock_env *subenv)
 		lov_sub_put(subenv->lse_sub);
 }
 
-static void lov_sublock_adopt(const struct lu_env *env, struct lov_lock *lck,
-			      struct cl_lock *sublock, int idx,
-			      struct lov_lock_link *link)
+static int lov_sublock_init(const struct lu_env *env,
+			    const struct cl_lock *parent,
+			    struct lov_lock_sub *lls)
 {
-	struct lovsub_lock *lsl;
-	struct cl_lock     *parent = lck->lls_cl.cls_lock;
-	int		 rc;
-
-	LASSERT(cl_lock_is_mutexed(parent));
-	LASSERT(cl_lock_is_mutexed(sublock));
-
-	lsl = cl2sub_lock(sublock);
-	/*
-	 * check that sub-lock doesn't have lock link to this top-lock.
-	 */
-	LASSERT(!lov_lock_link_find(env, lck, lsl));
-	LASSERT(idx < lck->lls_nr);
-
-	lck->lls_sub[idx].sub_lock = lsl;
-	lck->lls_nr_filled++;
-	LASSERT(lck->lls_nr_filled <= lck->lls_nr);
-	list_add_tail(&link->lll_list, &lsl->lss_parents);
-	link->lll_idx = idx;
-	link->lll_super = lck;
-	cl_lock_get(parent);
-	lu_ref_add(&parent->cll_reference, "lov-child", sublock);
-	lck->lls_sub[idx].sub_flags |= LSF_HELD;
-	cl_lock_user_add(env, sublock);
-
-	rc = lov_sublock_modify(env, lck, lsl, &sublock->cll_descr, idx);
-	LASSERT(rc == 0); /* there is no way this can fail, currently */
-}
-
-static struct cl_lock *lov_sublock_alloc(const struct lu_env *env,
-					 const struct cl_io *io,
-					 struct lov_lock *lck,
-					 int idx, struct lov_lock_link **out)
-{
-	struct cl_lock       *sublock;
-	struct cl_lock       *parent;
-	struct lov_lock_link *link;
-
-	LASSERT(idx < lck->lls_nr);
-
-	link = kmem_cache_zalloc(lov_lock_link_kmem, GFP_NOFS);
-	if (link) {
-		struct lov_sublock_env *subenv;
-		struct lov_lock_sub  *lls;
-		struct cl_lock_descr *descr;
-
-		parent = lck->lls_cl.cls_lock;
-		lls    = &lck->lls_sub[idx];
-		descr  = &lls->sub_got;
-
-		subenv = lov_sublock_env_get(env, parent, lls);
-		if (!IS_ERR(subenv)) {
-			/* CAVEAT: Don't try to add a field in lov_lock_sub
-			 * to remember the subio. This is because lock is able
-			 * to be cached, but this is not true for IO. This
-			 * further means a sublock might be referenced in
-			 * different io context. -jay
-			 */
-
-			sublock = cl_lock_hold(subenv->lse_env, subenv->lse_io,
-					       descr, "lov-parent", parent);
-			lov_sublock_env_put(subenv);
-		} else {
-			/* error occurs. */
-			sublock = (void *)subenv;
-		}
-
-		if (!IS_ERR(sublock))
-			*out = link;
-		else
-			kmem_cache_free(lov_lock_link_kmem, link);
-	} else
-		sublock = ERR_PTR(-ENOMEM);
-	return sublock;
-}
-
-static void lov_sublock_unlock(const struct lu_env *env,
-			       struct lovsub_lock *lsl,
-			       struct cl_lock_closure *closure,
-			       struct lov_sublock_env *subenv)
-{
-	lov_sublock_env_put(subenv);
-	lsl->lss_active = NULL;
-	cl_lock_disclosure(env, closure);
-}
-
-static int lov_sublock_lock(const struct lu_env *env,
-			    struct lov_lock *lck,
-			    struct lov_lock_sub *lls,
-			    struct cl_lock_closure *closure,
-			    struct lov_sublock_env **lsep)
-{
-	struct lovsub_lock *sublock;
-	struct cl_lock     *child;
-	int		 result = 0;
-
-	LASSERT(list_empty(&closure->clc_list));
-
-	sublock = lls->sub_lock;
-	child = sublock->lss_cl.cls_lock;
-	result = cl_lock_closure_build(env, child, closure);
-	if (result == 0) {
-		struct cl_lock *parent = closure->clc_origin;
-
-		LASSERT(cl_lock_is_mutexed(child));
-		sublock->lss_active = parent;
-
-		if (unlikely((child->cll_state == CLS_FREEING) ||
-			     (child->cll_flags & CLF_CANCELLED))) {
-			struct lov_lock_link *link;
-			/*
-			 * we could race with lock deletion which temporarily
-			 * put the lock in freeing state, bug 19080.
-			 */
-			LASSERT(!(lls->sub_flags & LSF_HELD));
-
-			link = lov_lock_link_find(env, lck, sublock);
-			LASSERT(link);
-			lov_lock_unlink(env, link, sublock);
-			lov_sublock_unlock(env, sublock, closure, NULL);
-			lck->lls_cancel_race = 1;
-			result = CLO_REPEAT;
-		} else if (lsep) {
-			struct lov_sublock_env *subenv;
+	struct lov_sublock_env *subenv;
+	int result;
 
-			subenv = lov_sublock_env_get(env, parent, lls);
-			if (IS_ERR(subenv)) {
-				lov_sublock_unlock(env, sublock,
-						   closure, NULL);
-				result = PTR_ERR(subenv);
-			} else {
-				*lsep = subenv;
-			}
-		}
+	subenv = lov_sublock_env_get(env, parent, lls);
+	if (!IS_ERR(subenv)) {
+		result = cl_lock_init(subenv->lse_env, &lls->sub_lock,
+				      subenv->lse_io);
+		lov_sublock_env_put(subenv);
+	} else {
+		/* error occurs. */
+		result = PTR_ERR(subenv);
 	}
 	return result;
 }
 
 /**
- * Updates the result of a top-lock operation from a result of sub-lock
- * sub-operations. Top-operations like lov_lock_{enqueue,use,unuse}() iterate
- * over sub-locks and lov_subresult() is used to calculate return value of a
- * top-operation. To this end, possible return values of sub-operations are
- * ordered as
- *
- *     - 0		  success
- *     - CLO_WAIT	   wait for event
- *     - CLO_REPEAT	 repeat top-operation
- *     - -ne		fundamental error
- *
- * Top-level return code can only go down through this list. CLO_REPEAT
- * overwrites CLO_WAIT, because lock mutex was released and sleeping condition
- * has to be rechecked by the upper layer.
- */
-static int lov_subresult(int result, int rc)
-{
-	int result_rank;
-	int rc_rank;
-
-	LASSERTF(result <= 0 || result == CLO_REPEAT || result == CLO_WAIT,
-		 "result = %d\n", result);
-	LASSERTF(rc <= 0 || rc == CLO_REPEAT || rc == CLO_WAIT,
-		 "rc = %d\n", rc);
-	CLASSERT(CLO_WAIT < CLO_REPEAT);
-
-	/* calculate ranks in the ordering above */
-	result_rank = result < 0 ? 1 + CLO_REPEAT : result;
-	rc_rank = rc < 0 ? 1 + CLO_REPEAT : rc;
-
-	if (result_rank < rc_rank)
-		result = rc;
-	return result;
-}
-
-/**
  * Creates sub-locks for a given lov_lock for the first time.
  *
  * Goes through all sub-objects of top-object, and creates sub-locks on every
@@ -286,8 +122,9 @@ static int lov_subresult(int result, int rc)
  * fact that top-lock (that is being created) can be accessed concurrently
  * through already created sub-locks (possibly shared with other top-locks).
  */
-static int lov_lock_sub_init(const struct lu_env *env,
-			     struct lov_lock *lck, const struct cl_io *io)
+static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
+					  const struct cl_object *obj,
+					  struct cl_lock *lock)
 {
 	int result = 0;
 	int i;
@@ -297,241 +134,86 @@ static int lov_lock_sub_init(const struct lu_env *env,
 	u64 file_start;
 	u64 file_end;
 
-	struct lov_object       *loo    = cl2lov(lck->lls_cl.cls_obj);
+	struct lov_object       *loo    = cl2lov(obj);
 	struct lov_layout_raid0 *r0     = lov_r0(loo);
-	struct cl_lock	  *parent = lck->lls_cl.cls_lock;
+	struct lov_lock		*lovlck;
 
-	lck->lls_orig = parent->cll_descr;
-	file_start = cl_offset(lov2cl(loo), parent->cll_descr.cld_start);
-	file_end   = cl_offset(lov2cl(loo), parent->cll_descr.cld_end + 1) - 1;
+	file_start = cl_offset(lov2cl(loo), lock->cll_descr.cld_start);
+	file_end   = cl_offset(lov2cl(loo), lock->cll_descr.cld_end + 1) - 1;
 
 	for (i = 0, nr = 0; i < r0->lo_nr; i++) {
 		/*
 		 * XXX for wide striping smarter algorithm is desirable,
 		 * breaking out of the loop, early.
 		 */
-		if (likely(r0->lo_sub[i]) &&
+		if (likely(r0->lo_sub[i]) && /* spare layout */
 		    lov_stripe_intersects(loo->lo_lsm, i,
 					  file_start, file_end, &start, &end))
 			nr++;
 	}
 	LASSERT(nr > 0);
-	lck->lls_sub = libcfs_kvzalloc(nr * sizeof(lck->lls_sub[0]), GFP_NOFS);
-	if (!lck->lls_sub)
-		return -ENOMEM;
+	lovlck = libcfs_kvzalloc(offsetof(struct lov_lock, lls_sub[nr]),
+				 GFP_NOFS);
+	if (!lovlck)
+		return ERR_PTR(-ENOMEM);
 
-	lck->lls_nr = nr;
-	/*
-	 * First, fill in sub-lock descriptions in
-	 * lck->lls_sub[].sub_descr. They are used by lov_sublock_alloc()
-	 * (called below in this function, and by lov_lock_enqueue()) to
-	 * create sub-locks. At this moment, no other thread can access
-	 * top-lock.
-	 */
+	lovlck->lls_nr = nr;
 	for (i = 0, nr = 0; i < r0->lo_nr; ++i) {
 		if (likely(r0->lo_sub[i]) &&
 		    lov_stripe_intersects(loo->lo_lsm, i,
 					  file_start, file_end, &start, &end)) {
+			struct lov_lock_sub *lls = &lovlck->lls_sub[nr];
 			struct cl_lock_descr *descr;
 
-			descr = &lck->lls_sub[nr].sub_descr;
+			descr = &lls->sub_lock.cll_descr;
 
 			LASSERT(!descr->cld_obj);
 			descr->cld_obj   = lovsub2cl(r0->lo_sub[i]);
 			descr->cld_start = cl_index(descr->cld_obj, start);
 			descr->cld_end   = cl_index(descr->cld_obj, end);
-			descr->cld_mode  = parent->cll_descr.cld_mode;
-			descr->cld_gid   = parent->cll_descr.cld_gid;
-			descr->cld_enq_flags   = parent->cll_descr.cld_enq_flags;
-			/* XXX has no effect */
-			lck->lls_sub[nr].sub_got = *descr;
-			lck->lls_sub[nr].sub_stripe = i;
+			descr->cld_mode  = lock->cll_descr.cld_mode;
+			descr->cld_gid   = lock->cll_descr.cld_gid;
+			descr->cld_enq_flags = lock->cll_descr.cld_enq_flags;
+			lls->sub_stripe = i;
+
+			/* initialize sub lock */
+			result = lov_sublock_init(env, lock, lls);
+			if (result < 0)
+				break;
+
+			lls->sub_initialized = 1;
 			nr++;
 		}
 	}
-	LASSERT(nr == lck->lls_nr);
-
-	/*
-	 * Some sub-locks can be missing at this point. This is not a problem,
-	 * because enqueue will create them anyway. Main duty of this function
-	 * is to fill in sub-lock descriptions in a race free manner.
-	 */
-	return result;
-}
+	LASSERT(ergo(result == 0, nr == lovlck->lls_nr));
 
-static int lov_sublock_release(const struct lu_env *env, struct lov_lock *lck,
-			       int i, int deluser, int rc)
-{
-	struct cl_lock *parent = lck->lls_cl.cls_lock;
-
-	LASSERT(cl_lock_is_mutexed(parent));
-
-	if (lck->lls_sub[i].sub_flags & LSF_HELD) {
-		struct cl_lock    *sublock;
-		int dying;
-
-		sublock = lck->lls_sub[i].sub_lock->lss_cl.cls_lock;
-		LASSERT(cl_lock_is_mutexed(sublock));
+	if (result != 0) {
+		for (i = 0; i < nr; ++i) {
+			if (!lovlck->lls_sub[i].sub_initialized)
+				break;
 
-		lck->lls_sub[i].sub_flags &= ~LSF_HELD;
-		if (deluser)
-			cl_lock_user_del(env, sublock);
-		/*
-		 * If the last hold is released, and cancellation is pending
-		 * for a sub-lock, release parent mutex, to avoid keeping it
-		 * while sub-lock is being paged out.
-		 */
-		dying = (sublock->cll_descr.cld_mode == CLM_PHANTOM ||
-			 sublock->cll_descr.cld_mode == CLM_GROUP ||
-			 (sublock->cll_flags & (CLF_CANCELPEND|CLF_DOOMED))) &&
-			sublock->cll_holds == 1;
-		if (dying)
-			cl_lock_mutex_put(env, parent);
-		cl_lock_unhold(env, sublock, "lov-parent", parent);
-		if (dying) {
-			cl_lock_mutex_get(env, parent);
-			rc = lov_subresult(rc, CLO_REPEAT);
+			cl_lock_fini(env, &lovlck->lls_sub[i].sub_lock);
 		}
-		/*
-		 * From now on lck->lls_sub[i].sub_lock is a "weak" pointer,
-		 * not backed by a reference on a
-		 * sub-lock. lovsub_lock_delete() will clear
-		 * lck->lls_sub[i].sub_lock under semaphores, just before
-		 * sub-lock is destroyed.
-		 */
+		kvfree(lovlck);
+		lovlck = ERR_PTR(result);
 	}
-	return rc;
-}
-
-static void lov_sublock_hold(const struct lu_env *env, struct lov_lock *lck,
-			     int i)
-{
-	struct cl_lock *parent = lck->lls_cl.cls_lock;
-
-	LASSERT(cl_lock_is_mutexed(parent));
-
-	if (!(lck->lls_sub[i].sub_flags & LSF_HELD)) {
-		struct cl_lock *sublock;
-
-		sublock = lck->lls_sub[i].sub_lock->lss_cl.cls_lock;
-		LASSERT(cl_lock_is_mutexed(sublock));
-		LASSERT(sublock->cll_state != CLS_FREEING);
 
-		lck->lls_sub[i].sub_flags |= LSF_HELD;
-
-		cl_lock_get_trust(sublock);
-		cl_lock_hold_add(env, sublock, "lov-parent", parent);
-		cl_lock_user_add(env, sublock);
-		cl_lock_put(env, sublock);
-	}
+	return lovlck;
 }
 
 static void lov_lock_fini(const struct lu_env *env,
 			  struct cl_lock_slice *slice)
 {
-	struct lov_lock *lck;
+	struct lov_lock *lovlck;
 	int i;
 
-	lck = cl2lov_lock(slice);
-	LASSERT(lck->lls_nr_filled == 0);
-	if (lck->lls_sub) {
-		for (i = 0; i < lck->lls_nr; ++i)
-			/*
-			 * No sub-locks exists at this point, as sub-lock has
-			 * a reference on its parent.
-			 */
-			LASSERT(!lck->lls_sub[i].sub_lock);
-		kvfree(lck->lls_sub);
+	lovlck = cl2lov_lock(slice);
+	for (i = 0; i < lovlck->lls_nr; ++i) {
+		LASSERT(!lovlck->lls_sub[i].sub_is_enqueued);
+		if (lovlck->lls_sub[i].sub_initialized)
+			cl_lock_fini(env, &lovlck->lls_sub[i].sub_lock);
 	}
-	kmem_cache_free(lov_lock_kmem, lck);
-}
-
-static int lov_lock_enqueue_wait(const struct lu_env *env,
-				 struct lov_lock *lck,
-				 struct cl_lock *sublock)
-{
-	struct cl_lock *lock = lck->lls_cl.cls_lock;
-	int	     result;
-
-	LASSERT(cl_lock_is_mutexed(lock));
-
-	cl_lock_mutex_put(env, lock);
-	result = cl_lock_enqueue_wait(env, sublock, 0);
-	cl_lock_mutex_get(env, lock);
-	return result ?: CLO_REPEAT;
-}
-
-/**
- * Tries to advance a state machine of a given sub-lock toward enqueuing of
- * the top-lock.
- *
- * \retval 0 if state-transition can proceed
- * \retval -ve otherwise.
- */
-static int lov_lock_enqueue_one(const struct lu_env *env, struct lov_lock *lck,
-				struct cl_lock *sublock,
-				struct cl_io *io, __u32 enqflags, int last)
-{
-	int result;
-
-	/* first, try to enqueue a sub-lock ... */
-	result = cl_enqueue_try(env, sublock, io, enqflags);
-	if ((sublock->cll_state == CLS_ENQUEUED) && !(enqflags & CEF_AGL)) {
-		/* if it is enqueued, try to `wait' on it---maybe it's already
-		 * granted
-		 */
-		result = cl_wait_try(env, sublock);
-		if (result == CLO_REENQUEUED)
-			result = CLO_WAIT;
-	}
-	/*
-	 * If CEF_ASYNC flag is set, then all sub-locks can be enqueued in
-	 * parallel, otherwise---enqueue has to wait until sub-lock is granted
-	 * before proceeding to the next one.
-	 */
-	if ((result == CLO_WAIT) && (sublock->cll_state <= CLS_HELD) &&
-	    (enqflags & CEF_ASYNC) && (!last || (enqflags & CEF_AGL)))
-		result = 0;
-	return result;
-}
-
-/**
- * Helper function for lov_lock_enqueue() that creates missing sub-lock.
- */
-static int lov_sublock_fill(const struct lu_env *env, struct cl_lock *parent,
-			    struct cl_io *io, struct lov_lock *lck, int idx)
-{
-	struct lov_lock_link *link = NULL;
-	struct cl_lock       *sublock;
-	int		   result;
-
-	LASSERT(parent->cll_depth == 1);
-	cl_lock_mutex_put(env, parent);
-	sublock = lov_sublock_alloc(env, io, lck, idx, &link);
-	if (!IS_ERR(sublock))
-		cl_lock_mutex_get(env, sublock);
-	cl_lock_mutex_get(env, parent);
-
-	if (!IS_ERR(sublock)) {
-		cl_lock_get_trust(sublock);
-		if (parent->cll_state == CLS_QUEUING &&
-		    !lck->lls_sub[idx].sub_lock) {
-			lov_sublock_adopt(env, lck, sublock, idx, link);
-		} else {
-			kmem_cache_free(lov_lock_link_kmem, link);
-			/* other thread allocated sub-lock, or enqueue is no
-			 * longer going on
-			 */
-			cl_lock_mutex_put(env, parent);
-			cl_lock_unhold(env, sublock, "lov-parent", parent);
-			cl_lock_mutex_get(env, parent);
-		}
-		cl_lock_mutex_put(env, sublock);
-		cl_lock_put(env, sublock);
-		result = CLO_REPEAT;
-	} else
-		result = PTR_ERR(sublock);
-	return result;
+	kvfree(lovlck);
 }
 
 /**
@@ -543,529 +225,59 @@ static int lov_sublock_fill(const struct lu_env *env, struct cl_lock *parent,
  */
 static int lov_lock_enqueue(const struct lu_env *env,
 			    const struct cl_lock_slice *slice,
-			    struct cl_io *io, __u32 enqflags)
+			    struct cl_io *io, struct cl_sync_io *anchor)
 {
-	struct cl_lock	 *lock    = slice->cls_lock;
-	struct lov_lock	*lck     = cl2lov_lock(slice);
-	struct cl_lock_closure *closure = lov_closure_get(env, lock);
+	struct cl_lock *lock = slice->cls_lock;
+	struct lov_lock *lovlck = cl2lov_lock(slice);
 	int i;
-	int result;
-	enum cl_lock_state minstate;
+	int rc = 0;
 
-	for (result = 0, minstate = CLS_FREEING, i = 0; i < lck->lls_nr; ++i) {
-		int rc;
-		struct lovsub_lock     *sub;
-		struct lov_lock_sub    *lls;
-		struct cl_lock	 *sublock;
+	for (i = 0; i < lovlck->lls_nr; ++i) {
+		struct lov_lock_sub  *lls = &lovlck->lls_sub[i];
 		struct lov_sublock_env *subenv;
 
-		if (lock->cll_state != CLS_QUEUING) {
-			/*
-			 * Lock might have left QUEUING state if previous
-			 * iteration released its mutex. Stop enqueing in this
-			 * case and let the upper layer to decide what to do.
-			 */
-			LASSERT(i > 0 && result != 0);
-			break;
-		}
-
-		lls = &lck->lls_sub[i];
-		sub = lls->sub_lock;
-		/*
-		 * Sub-lock might have been canceled, while top-lock was
-		 * cached.
-		 */
-		if (!sub) {
-			result = lov_sublock_fill(env, lock, io, lck, i);
-			/* lov_sublock_fill() released @lock mutex,
-			 * restart.
-			 */
+		subenv = lov_sublock_env_get(env, lock, lls);
+		if (IS_ERR(subenv)) {
+			rc = PTR_ERR(subenv);
 			break;
 		}
-		sublock = sub->lss_cl.cls_lock;
-		rc = lov_sublock_lock(env, lck, lls, closure, &subenv);
-		if (rc == 0) {
-			lov_sublock_hold(env, lck, i);
-			rc = lov_lock_enqueue_one(subenv->lse_env, lck, sublock,
-						  subenv->lse_io, enqflags,
-						  i == lck->lls_nr - 1);
-			minstate = min(minstate, sublock->cll_state);
-			if (rc == CLO_WAIT) {
-				switch (sublock->cll_state) {
-				case CLS_QUEUING:
-					/* take recursive mutex, the lock is
-					 * released in lov_lock_enqueue_wait.
-					 */
-					cl_lock_mutex_get(env, sublock);
-					lov_sublock_unlock(env, sub, closure,
-							   subenv);
-					rc = lov_lock_enqueue_wait(env, lck,
-								   sublock);
-					break;
-				case CLS_CACHED:
-					cl_lock_get(sublock);
-					/* take recursive mutex of sublock */
-					cl_lock_mutex_get(env, sublock);
-					/* need to release all locks in closure
-					 * otherwise it may deadlock. LU-2683.
-					 */
-					lov_sublock_unlock(env, sub, closure,
-							   subenv);
-					/* sublock and parent are held. */
-					rc = lov_sublock_release(env, lck, i,
-								 1, rc);
-					cl_lock_mutex_put(env, sublock);
-					cl_lock_put(env, sublock);
-					break;
-				default:
-					lov_sublock_unlock(env, sub, closure,
-							   subenv);
-					break;
-				}
-			} else {
-				LASSERT(!sublock->cll_conflict);
-				lov_sublock_unlock(env, sub, closure, subenv);
-			}
-		}
-		result = lov_subresult(result, rc);
-		if (result != 0)
+		rc = cl_lock_enqueue(subenv->lse_env, subenv->lse_io,
+				     &lls->sub_lock, anchor);
+		lov_sublock_env_put(subenv);
+		if (rc != 0)
 			break;
-	}
-	cl_lock_closure_fini(closure);
-	return result ?: minstate >= CLS_ENQUEUED ? 0 : CLO_WAIT;
-}
-
-static int lov_lock_unuse(const struct lu_env *env,
-			  const struct cl_lock_slice *slice)
-{
-	struct lov_lock	*lck     = cl2lov_lock(slice);
-	struct cl_lock_closure *closure = lov_closure_get(env, slice->cls_lock);
-	int i;
-	int result;
-
-	for (result = 0, i = 0; i < lck->lls_nr; ++i) {
-		int rc;
-		struct lovsub_lock     *sub;
-		struct cl_lock	 *sublock;
-		struct lov_lock_sub    *lls;
-		struct lov_sublock_env *subenv;
 
-		/* top-lock state cannot change concurrently, because single
-		 * thread (one that released the last hold) carries unlocking
-		 * to the completion.
-		 */
-		LASSERT(slice->cls_lock->cll_state == CLS_INTRANSIT);
-		lls = &lck->lls_sub[i];
-		sub = lls->sub_lock;
-		if (!sub)
-			continue;
-
-		sublock = sub->lss_cl.cls_lock;
-		rc = lov_sublock_lock(env, lck, lls, closure, &subenv);
-		if (rc == 0) {
-			if (lls->sub_flags & LSF_HELD) {
-				LASSERT(sublock->cll_state == CLS_HELD ||
-					sublock->cll_state == CLS_ENQUEUED);
-				rc = cl_unuse_try(subenv->lse_env, sublock);
-				rc = lov_sublock_release(env, lck, i, 0, rc);
-			}
-			lov_sublock_unlock(env, sub, closure, subenv);
-		}
-		result = lov_subresult(result, rc);
+		lls->sub_is_enqueued = 1;
 	}
-
-	if (result == 0 && lck->lls_cancel_race) {
-		lck->lls_cancel_race = 0;
-		result = -ESTALE;
-	}
-	cl_lock_closure_fini(closure);
-	return result;
+	return rc;
 }
 
 static void lov_lock_cancel(const struct lu_env *env,
 			    const struct cl_lock_slice *slice)
 {
-	struct lov_lock	*lck     = cl2lov_lock(slice);
-	struct cl_lock_closure *closure = lov_closure_get(env, slice->cls_lock);
+	struct cl_lock *lock = slice->cls_lock;
+	struct lov_lock *lovlck = cl2lov_lock(slice);
 	int i;
-	int result;
 
-	for (result = 0, i = 0; i < lck->lls_nr; ++i) {
-		int rc;
-		struct lovsub_lock     *sub;
-		struct cl_lock	 *sublock;
-		struct lov_lock_sub    *lls;
+	for (i = 0; i < lovlck->lls_nr; ++i) {
+		struct lov_lock_sub *lls = &lovlck->lls_sub[i];
+		struct cl_lock *sublock = &lls->sub_lock;
 		struct lov_sublock_env *subenv;
 
-		/* top-lock state cannot change concurrently, because single
-		 * thread (one that released the last hold) carries unlocking
-		 * to the completion.
-		 */
-		lls = &lck->lls_sub[i];
-		sub = lls->sub_lock;
-		if (!sub)
-			continue;
-
-		sublock = sub->lss_cl.cls_lock;
-		rc = lov_sublock_lock(env, lck, lls, closure, &subenv);
-		if (rc == 0) {
-			if (!(lls->sub_flags & LSF_HELD)) {
-				lov_sublock_unlock(env, sub, closure, subenv);
-				continue;
-			}
-
-			switch (sublock->cll_state) {
-			case CLS_HELD:
-				rc = cl_unuse_try(subenv->lse_env, sublock);
-				lov_sublock_release(env, lck, i, 0, 0);
-				break;
-			default:
-				lov_sublock_release(env, lck, i, 1, 0);
-				break;
-			}
-			lov_sublock_unlock(env, sub, closure, subenv);
-		}
-
-		if (rc == CLO_REPEAT) {
-			--i;
-			continue;
-		}
-
-		result = lov_subresult(result, rc);
-	}
-
-	if (result)
-		CL_LOCK_DEBUG(D_ERROR, env, slice->cls_lock,
-			      "lov_lock_cancel fails with %d.\n", result);
-
-	cl_lock_closure_fini(closure);
-}
-
-static int lov_lock_wait(const struct lu_env *env,
-			 const struct cl_lock_slice *slice)
-{
-	struct lov_lock	*lck     = cl2lov_lock(slice);
-	struct cl_lock_closure *closure = lov_closure_get(env, slice->cls_lock);
-	enum cl_lock_state      minstate;
-	int		     reenqueued;
-	int		     result;
-	int		     i;
-
-again:
-	for (result = 0, minstate = CLS_FREEING, i = 0, reenqueued = 0;
-	     i < lck->lls_nr; ++i) {
-		int rc;
-		struct lovsub_lock     *sub;
-		struct cl_lock	 *sublock;
-		struct lov_lock_sub    *lls;
-		struct lov_sublock_env *subenv;
-
-		lls = &lck->lls_sub[i];
-		sub = lls->sub_lock;
-		sublock = sub->lss_cl.cls_lock;
-		rc = lov_sublock_lock(env, lck, lls, closure, &subenv);
-		if (rc == 0) {
-			LASSERT(sublock->cll_state >= CLS_ENQUEUED);
-			if (sublock->cll_state < CLS_HELD)
-				rc = cl_wait_try(env, sublock);
-
-			minstate = min(minstate, sublock->cll_state);
-			lov_sublock_unlock(env, sub, closure, subenv);
-		}
-		if (rc == CLO_REENQUEUED) {
-			reenqueued++;
-			rc = 0;
-		}
-		result = lov_subresult(result, rc);
-		if (result != 0)
-			break;
-	}
-	/* Each sublock only can be reenqueued once, so will not loop
-	 * forever.
-	 */
-	if (result == 0 && reenqueued != 0)
-		goto again;
-	cl_lock_closure_fini(closure);
-	return result ?: minstate >= CLS_HELD ? 0 : CLO_WAIT;
-}
-
-static int lov_lock_use(const struct lu_env *env,
-			const struct cl_lock_slice *slice)
-{
-	struct lov_lock	*lck     = cl2lov_lock(slice);
-	struct cl_lock_closure *closure = lov_closure_get(env, slice->cls_lock);
-	int		     result;
-	int		     i;
-
-	LASSERT(slice->cls_lock->cll_state == CLS_INTRANSIT);
-
-	for (result = 0, i = 0; i < lck->lls_nr; ++i) {
-		int rc;
-		struct lovsub_lock     *sub;
-		struct cl_lock	 *sublock;
-		struct lov_lock_sub    *lls;
-		struct lov_sublock_env *subenv;
-
-		LASSERT(slice->cls_lock->cll_state == CLS_INTRANSIT);
-
-		lls = &lck->lls_sub[i];
-		sub = lls->sub_lock;
-		if (!sub) {
-			/*
-			 * Sub-lock might have been canceled, while top-lock was
-			 * cached.
-			 */
-			result = -ESTALE;
-			break;
-		}
-
-		sublock = sub->lss_cl.cls_lock;
-		rc = lov_sublock_lock(env, lck, lls, closure, &subenv);
-		if (rc == 0) {
-			LASSERT(sublock->cll_state != CLS_FREEING);
-			lov_sublock_hold(env, lck, i);
-			if (sublock->cll_state == CLS_CACHED) {
-				rc = cl_use_try(subenv->lse_env, sublock, 0);
-				if (rc != 0)
-					rc = lov_sublock_release(env, lck,
-								 i, 1, rc);
-			} else if (sublock->cll_state == CLS_NEW) {
-				/* Sub-lock might have been canceled, while
-				 * top-lock was cached.
-				 */
-				result = -ESTALE;
-				lov_sublock_release(env, lck, i, 1, result);
-			}
-			lov_sublock_unlock(env, sub, closure, subenv);
-		}
-		result = lov_subresult(result, rc);
-		if (result != 0)
-			break;
-	}
-
-	if (lck->lls_cancel_race) {
-		/*
-		 * If there is unlocking happened at the same time, then
-		 * sublock_lock state should be FREEING, and lov_sublock_lock
-		 * should return CLO_REPEAT. In this case, it should return
-		 * ESTALE, and up layer should reset the lock state to be NEW.
-		 */
-		lck->lls_cancel_race = 0;
-		LASSERT(result != 0);
-		result = -ESTALE;
-	}
-	cl_lock_closure_fini(closure);
-	return result;
-}
-
-/**
- * Check if the extent region \a descr is covered by \a child against the
- * specific \a stripe.
- */
-static int lov_lock_stripe_is_matching(const struct lu_env *env,
-				       struct lov_object *lov, int stripe,
-				       const struct cl_lock_descr *child,
-				       const struct cl_lock_descr *descr)
-{
-	struct lov_stripe_md *lsm = lov->lo_lsm;
-	u64 start;
-	u64 end;
-	int result;
-
-	if (lov_r0(lov)->lo_nr == 1)
-		return cl_lock_ext_match(child, descr);
-
-	/*
-	 * For a multi-stripes object:
-	 * - make sure the descr only covers child's stripe, and
-	 * - check if extent is matching.
-	 */
-	start = cl_offset(&lov->lo_cl, descr->cld_start);
-	end   = cl_offset(&lov->lo_cl, descr->cld_end + 1) - 1;
-	result = 0;
-	/* glimpse should work on the object with LOV EA hole. */
-	if (end - start <= lsm->lsm_stripe_size) {
-		int idx;
-
-		idx = lov_stripe_number(lsm, start);
-		if (idx == stripe ||
-		    unlikely(!lov_r0(lov)->lo_sub[idx])) {
-			idx = lov_stripe_number(lsm, end);
-			if (idx == stripe ||
-			    unlikely(!lov_r0(lov)->lo_sub[idx]))
-				result = 1;
-		}
-	}
-
-	if (result != 0) {
-		struct cl_lock_descr *subd = &lov_env_info(env)->lti_ldescr;
-		u64 sub_start;
-		u64 sub_end;
-
-		subd->cld_obj  = NULL;   /* don't need sub object at all */
-		subd->cld_mode = descr->cld_mode;
-		subd->cld_gid  = descr->cld_gid;
-		result = lov_stripe_intersects(lsm, stripe, start, end,
-					       &sub_start, &sub_end);
-		LASSERT(result);
-		subd->cld_start = cl_index(child->cld_obj, sub_start);
-		subd->cld_end   = cl_index(child->cld_obj, sub_end);
-		result = cl_lock_ext_match(child, subd);
-	}
-	return result;
-}
-
-/**
- * An implementation of cl_lock_operations::clo_fits_into() method.
- *
- * Checks whether a lock (given by \a slice) is suitable for \a
- * io. Multi-stripe locks can be used only for "quick" io, like truncate, or
- * O_APPEND write.
- *
- * \see ccc_lock_fits_into().
- */
-static int lov_lock_fits_into(const struct lu_env *env,
-			      const struct cl_lock_slice *slice,
-			      const struct cl_lock_descr *need,
-			      const struct cl_io *io)
-{
-	struct lov_lock   *lov = cl2lov_lock(slice);
-	struct lov_object *obj = cl2lov(slice->cls_obj);
-	int result;
-
-	LASSERT(cl_object_same(need->cld_obj, slice->cls_obj));
-	LASSERT(lov->lls_nr > 0);
-
-	/* for top lock, it's necessary to match enq flags otherwise it will
-	 * run into problem if a sublock is missing and reenqueue.
-	 */
-	if (need->cld_enq_flags != lov->lls_orig.cld_enq_flags)
-		return 0;
-
-	if (need->cld_mode == CLM_GROUP)
-		/*
-		 * always allow to match group lock.
-		 */
-		result = cl_lock_ext_match(&lov->lls_orig, need);
-	else if (lov->lls_nr == 1) {
-		struct cl_lock_descr *got = &lov->lls_sub[0].sub_got;
-
-		result = lov_lock_stripe_is_matching(env,
-						     cl2lov(slice->cls_obj),
-						     lov->lls_sub[0].sub_stripe,
-						     got, need);
-	} else if (io->ci_type != CIT_SETATTR && io->ci_type != CIT_MISC &&
-		   !cl_io_is_append(io) && need->cld_mode != CLM_PHANTOM)
-		/*
-		 * Multi-stripe locks are only suitable for `quick' IO and for
-		 * glimpse.
-		 */
-		result = 0;
-	else
-		/*
-		 * Most general case: multi-stripe existing lock, and
-		 * (potentially) multi-stripe @need lock. Check that @need is
-		 * covered by @lov's sub-locks.
-		 *
-		 * For now, ignore lock expansions made by the server, and
-		 * match against original lock extent.
-		 */
-		result = cl_lock_ext_match(&lov->lls_orig, need);
-	CDEBUG(D_DLMTRACE, DDESCR"/"DDESCR" %d %d/%d: %d\n",
-	       PDESCR(&lov->lls_orig), PDESCR(&lov->lls_sub[0].sub_got),
-	       lov->lls_sub[0].sub_stripe, lov->lls_nr, lov_r0(obj)->lo_nr,
-	       result);
-	return result;
-}
-
-void lov_lock_unlink(const struct lu_env *env,
-		     struct lov_lock_link *link, struct lovsub_lock *sub)
-{
-	struct lov_lock *lck    = link->lll_super;
-	struct cl_lock  *parent = lck->lls_cl.cls_lock;
-
-	LASSERT(cl_lock_is_mutexed(parent));
-	LASSERT(cl_lock_is_mutexed(sub->lss_cl.cls_lock));
-
-	list_del_init(&link->lll_list);
-	LASSERT(lck->lls_sub[link->lll_idx].sub_lock == sub);
-	/* yank this sub-lock from parent's array */
-	lck->lls_sub[link->lll_idx].sub_lock = NULL;
-	LASSERT(lck->lls_nr_filled > 0);
-	lck->lls_nr_filled--;
-	lu_ref_del(&parent->cll_reference, "lov-child", sub->lss_cl.cls_lock);
-	cl_lock_put(env, parent);
-	kmem_cache_free(lov_lock_link_kmem, link);
-}
-
-struct lov_lock_link *lov_lock_link_find(const struct lu_env *env,
-					 struct lov_lock *lck,
-					 struct lovsub_lock *sub)
-{
-	struct lov_lock_link *scan;
-
-	LASSERT(cl_lock_is_mutexed(sub->lss_cl.cls_lock));
-
-	list_for_each_entry(scan, &sub->lss_parents, lll_list) {
-		if (scan->lll_super == lck)
-			return scan;
-	}
-	return NULL;
-}
-
-/**
- * An implementation of cl_lock_operations::clo_delete() method. This is
- * invoked for "top-to-bottom" delete, when lock destruction starts from the
- * top-lock, e.g., as a result of inode destruction.
- *
- * Unlinks top-lock from all its sub-locks. Sub-locks are not deleted there:
- * this is done separately elsewhere:
- *
- *     - for inode destruction, lov_object_delete() calls cl_object_kill() for
- *       each sub-object, purging its locks;
- *
- *     - in other cases (e.g., a fatal error with a top-lock) sub-locks are
- *       left in the cache.
- */
-static void lov_lock_delete(const struct lu_env *env,
-			    const struct cl_lock_slice *slice)
-{
-	struct lov_lock	*lck     = cl2lov_lock(slice);
-	struct cl_lock_closure *closure = lov_closure_get(env, slice->cls_lock);
-	struct lov_lock_link   *link;
-	int		     rc;
-	int		     i;
-
-	LASSERT(slice->cls_lock->cll_state == CLS_FREEING);
-
-	for (i = 0; i < lck->lls_nr; ++i) {
-		struct lov_lock_sub *lls = &lck->lls_sub[i];
-		struct lovsub_lock  *lsl = lls->sub_lock;
-
-		if (!lsl) /* already removed */
+		if (!lls->sub_is_enqueued)
 			continue;
 
-		rc = lov_sublock_lock(env, lck, lls, closure, NULL);
-		if (rc == CLO_REPEAT) {
-			--i;
-			continue;
+		lls->sub_is_enqueued = 0;
+		subenv = lov_sublock_env_get(env, lock, lls);
+		if (!IS_ERR(subenv)) {
+			cl_lock_cancel(subenv->lse_env, sublock);
+			lov_sublock_env_put(subenv);
+		} else {
+			CL_LOCK_DEBUG(D_ERROR, env, slice->cls_lock,
+				      "lov_lock_cancel fails with %ld.\n",
+				      PTR_ERR(subenv));
 		}
-
-		LASSERT(rc == 0);
-		LASSERT(lsl->lss_cl.cls_lock->cll_state < CLS_FREEING);
-
-		if (lls->sub_flags & LSF_HELD)
-			lov_sublock_release(env, lck, i, 1, 0);
-
-		link = lov_lock_link_find(env, lck, lsl);
-		LASSERT(link);
-		lov_lock_unlink(env, link, lsl);
-		LASSERT(!lck->lls_sub[i].sub_lock);
-
-		lov_sublock_unlock(env, lsl, closure, NULL);
 	}
-
-	cl_lock_closure_fini(closure);
 }
 
 static int lov_lock_print(const struct lu_env *env, void *cookie,
@@ -1079,12 +291,8 @@ static int lov_lock_print(const struct lu_env *env, void *cookie,
 		struct lov_lock_sub *sub;
 
 		sub = &lck->lls_sub[i];
-		(*p)(env, cookie, "    %d %x: ", i, sub->sub_flags);
-		if (sub->sub_lock)
-			cl_lock_print(env, cookie, p,
-				      sub->sub_lock->lss_cl.cls_lock);
-		else
-			(*p)(env, cookie, "---\n");
+		(*p)(env, cookie, "    %d %x: ", i, sub->sub_is_enqueued);
+		cl_lock_print(env, cookie, p, &sub->sub_lock);
 	}
 	return 0;
 }
@@ -1092,12 +300,7 @@ static int lov_lock_print(const struct lu_env *env, void *cookie,
 static const struct cl_lock_operations lov_lock_ops = {
 	.clo_fini      = lov_lock_fini,
 	.clo_enqueue   = lov_lock_enqueue,
-	.clo_wait      = lov_lock_wait,
-	.clo_use       = lov_lock_use,
-	.clo_unuse     = lov_lock_unuse,
 	.clo_cancel    = lov_lock_cancel,
-	.clo_fits_into = lov_lock_fits_into,
-	.clo_delete    = lov_lock_delete,
 	.clo_print     = lov_lock_print
 };
 
@@ -1105,14 +308,13 @@ int lov_lock_init_raid0(const struct lu_env *env, struct cl_object *obj,
 			struct cl_lock *lock, const struct cl_io *io)
 {
 	struct lov_lock *lck;
-	int result;
+	int result = 0;
 
-	lck = kmem_cache_zalloc(lov_lock_kmem, GFP_NOFS);
-	if (lck) {
+	lck = lov_lock_sub_init(env, obj, lock);
+	if (!IS_ERR(lck))
 		cl_lock_slice_add(lock, &lck->lls_cl, obj, &lov_lock_ops);
-		result = lov_lock_sub_init(env, lck, io);
-	} else
-		result = -ENOMEM;
+	else
+		result = PTR_ERR(lck);
 	return result;
 }
 
@@ -1147,21 +349,9 @@ int lov_lock_init_empty(const struct lu_env *env, struct cl_object *obj,
 	lck = kmem_cache_zalloc(lov_lock_kmem, GFP_NOFS);
 	if (lck) {
 		cl_lock_slice_add(lock, &lck->lls_cl, obj, &lov_empty_lock_ops);
-		lck->lls_orig = lock->cll_descr;
 		result = 0;
 	}
 	return result;
 }
 
-static struct cl_lock_closure *lov_closure_get(const struct lu_env *env,
-					       struct cl_lock *parent)
-{
-	struct cl_lock_closure *closure;
-
-	closure = &lov_env_info(env)->lti_closure;
-	LASSERT(list_empty(&closure->clc_list));
-	cl_lock_closure_init(env, closure, parent, 1);
-	return closure;
-}
-
 /** @} lov */
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 0159b6f..6a353d1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -310,8 +310,6 @@ static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
 	LASSERT(lov->lo_type == LLT_EMPTY || lov->lo_type == LLT_RELEASED);
 
 	lov_layout_wait(env, lov);
-
-	cl_locks_prune(env, &lov->lo_cl, 0);
 	return 0;
 }
 
@@ -379,7 +377,7 @@ static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			struct lovsub_object *los = r0->lo_sub[i];
 
 			if (los) {
-				cl_locks_prune(env, &los->lso_cl, 1);
+				cl_object_prune(env, &los->lso_cl);
 				/*
 				 * If top-level object is to be evicted from
 				 * the cache, so are its sub-objects.
@@ -388,7 +386,6 @@ static int lov_delete_raid0(const struct lu_env *env, struct lov_object *lov,
 			}
 		}
 	}
-	cl_locks_prune(env, &lov->lo_cl, 0);
 	return 0;
 }
 
@@ -714,7 +711,9 @@ static int lov_layout_change(const struct lu_env *unused,
 	old_ops = &lov_dispatch[lov->lo_type];
 	new_ops = &lov_dispatch[llt];
 
-	cl_object_prune(env, &lov->lo_cl);
+	result = cl_object_prune(env, &lov->lo_cl);
+	if (result != 0)
+		goto out;
 
 	result = old_ops->llo_delete(env, lov, &lov->u);
 	if (result == 0) {
@@ -736,6 +735,7 @@ static int lov_layout_change(const struct lu_env *unused,
 		}
 	}
 
+out:
 	cl_env_put(env, &refcheck);
 	cl_env_reexit(cookie);
 	return result;
@@ -816,7 +816,8 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 		goto out;
 	}
 
-	lov->lo_layout_invalid = lov_layout_change(env, lov, conf);
+	result = lov_layout_change(env, lov, conf);
+	lov->lo_layout_invalid = result != 0;
 
 out:
 	lov_conf_unlock(lov);
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index 3bb0c90..670d203 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -62,391 +62,8 @@ static void lovsub_lock_fini(const struct lu_env *env,
 	kmem_cache_free(lovsub_lock_kmem, lsl);
 }
 
-static void lovsub_parent_lock(const struct lu_env *env, struct lov_lock *lov)
-{
-	struct cl_lock *parent;
-
-	parent = lov->lls_cl.cls_lock;
-	cl_lock_get(parent);
-	lu_ref_add(&parent->cll_reference, "lovsub-parent", current);
-	cl_lock_mutex_get(env, parent);
-}
-
-static void lovsub_parent_unlock(const struct lu_env *env, struct lov_lock *lov)
-{
-	struct cl_lock *parent;
-
-	parent = lov->lls_cl.cls_lock;
-	cl_lock_mutex_put(env, lov->lls_cl.cls_lock);
-	lu_ref_del(&parent->cll_reference, "lovsub-parent", current);
-	cl_lock_put(env, parent);
-}
-
-/**
- * Implements cl_lock_operations::clo_state() method for lovsub layer, which
- * method is called whenever sub-lock state changes. Propagates state change
- * to the top-locks.
- */
-static void lovsub_lock_state(const struct lu_env *env,
-			      const struct cl_lock_slice *slice,
-			      enum cl_lock_state state)
-{
-	struct lovsub_lock   *sub = cl2lovsub_lock(slice);
-	struct lov_lock_link *scan;
-
-	LASSERT(cl_lock_is_mutexed(slice->cls_lock));
-
-	list_for_each_entry(scan, &sub->lss_parents, lll_list) {
-		struct lov_lock *lov    = scan->lll_super;
-		struct cl_lock  *parent = lov->lls_cl.cls_lock;
-
-		if (sub->lss_active != parent) {
-			lovsub_parent_lock(env, lov);
-			cl_lock_signal(env, parent);
-			lovsub_parent_unlock(env, lov);
-		}
-	}
-}
-
-/**
- * Implementation of cl_lock_operation::clo_weigh() estimating lock weight by
- * asking parent lock.
- */
-static unsigned long lovsub_lock_weigh(const struct lu_env *env,
-				       const struct cl_lock_slice *slice)
-{
-	struct lovsub_lock *lock = cl2lovsub_lock(slice);
-	struct lov_lock    *lov;
-	unsigned long       dumbbell;
-
-	LASSERT(cl_lock_is_mutexed(slice->cls_lock));
-
-	if (!list_empty(&lock->lss_parents)) {
-		/*
-		 * It is not clear whether all parents have to be asked and
-		 * their estimations summed, or it is enough to ask one. For
-		 * the current usages, one is always enough.
-		 */
-		lov = container_of(lock->lss_parents.next,
-				   struct lov_lock_link, lll_list)->lll_super;
-
-		lovsub_parent_lock(env, lov);
-		dumbbell = cl_lock_weigh(env, lov->lls_cl.cls_lock);
-		lovsub_parent_unlock(env, lov);
-	} else
-		dumbbell = 0;
-
-	return dumbbell;
-}
-
-/**
- * Maps start/end offsets within a stripe, to offsets within a file.
- */
-static void lovsub_lock_descr_map(const struct cl_lock_descr *in,
-				  struct lov_object *lov,
-				  int stripe, struct cl_lock_descr *out)
-{
-	pgoff_t size; /* stripe size in pages */
-	pgoff_t skip; /* how many pages in every stripe are occupied by
-		       * "other" stripes
-		       */
-	pgoff_t start;
-	pgoff_t end;
-
-	start = in->cld_start;
-	end   = in->cld_end;
-
-	if (lov->lo_lsm->lsm_stripe_count > 1) {
-		size = cl_index(lov2cl(lov), lov->lo_lsm->lsm_stripe_size);
-		skip = (lov->lo_lsm->lsm_stripe_count - 1) * size;
-
-		/* XXX overflow check here? */
-		start += start/size * skip + stripe * size;
-
-		if (end != CL_PAGE_EOF) {
-			end += end/size * skip + stripe * size;
-			/*
-			 * And check for overflow...
-			 */
-			if (end < in->cld_end)
-				end = CL_PAGE_EOF;
-		}
-	}
-	out->cld_start = start;
-	out->cld_end   = end;
-}
-
-/**
- * Adjusts parent lock extent when a sub-lock is attached to a parent. This is
- * called in two ways:
- *
- *     - as part of receive call-back, when server returns granted extent to
- *       the client, and
- *
- *     - when top-lock finds existing sub-lock in the cache.
- *
- * Note, that lock mode is not propagated to the parent: i.e., if CLM_READ
- * top-lock matches CLM_WRITE sub-lock, top-lock is still CLM_READ.
- */
-int lov_sublock_modify(const struct lu_env *env, struct lov_lock *lov,
-		       struct lovsub_lock *sublock,
-		       const struct cl_lock_descr *d, int idx)
-{
-	struct cl_lock       *parent;
-	struct lovsub_object *subobj;
-	struct cl_lock_descr *pd;
-	struct cl_lock_descr *parent_descr;
-	int		   result;
-
-	parent       = lov->lls_cl.cls_lock;
-	parent_descr = &parent->cll_descr;
-	LASSERT(cl_lock_mode_match(d->cld_mode, parent_descr->cld_mode));
-
-	subobj = cl2lovsub(sublock->lss_cl.cls_obj);
-	pd     = &lov_env_info(env)->lti_ldescr;
-
-	pd->cld_obj  = parent_descr->cld_obj;
-	pd->cld_mode = parent_descr->cld_mode;
-	pd->cld_gid  = parent_descr->cld_gid;
-	lovsub_lock_descr_map(d, subobj->lso_super, subobj->lso_index, pd);
-	lov->lls_sub[idx].sub_got = *d;
-	/*
-	 * Notify top-lock about modification, if lock description changes
-	 * materially.
-	 */
-	if (!cl_lock_ext_match(parent_descr, pd))
-		result = cl_lock_modify(env, parent, pd);
-	else
-		result = 0;
-	return result;
-}
-
-static int lovsub_lock_modify(const struct lu_env *env,
-			      const struct cl_lock_slice *s,
-			      const struct cl_lock_descr *d)
-{
-	struct lovsub_lock   *lock   = cl2lovsub_lock(s);
-	struct lov_lock_link *scan;
-	struct lov_lock      *lov;
-	int result		   = 0;
-
-	LASSERT(cl_lock_mode_match(d->cld_mode,
-				   s->cls_lock->cll_descr.cld_mode));
-	list_for_each_entry(scan, &lock->lss_parents, lll_list) {
-		int rc;
-
-		lov = scan->lll_super;
-		lovsub_parent_lock(env, lov);
-		rc = lov_sublock_modify(env, lov, lock, d, scan->lll_idx);
-		lovsub_parent_unlock(env, lov);
-		result = result ?: rc;
-	}
-	return result;
-}
-
-static int lovsub_lock_closure(const struct lu_env *env,
-			       const struct cl_lock_slice *slice,
-			       struct cl_lock_closure *closure)
-{
-	struct lovsub_lock   *sub;
-	struct cl_lock       *parent;
-	struct lov_lock_link *scan;
-	int		   result;
-
-	LASSERT(cl_lock_is_mutexed(slice->cls_lock));
-
-	sub    = cl2lovsub_lock(slice);
-	result = 0;
-
-	list_for_each_entry(scan, &sub->lss_parents, lll_list) {
-		parent = scan->lll_super->lls_cl.cls_lock;
-		result = cl_lock_closure_build(env, parent, closure);
-		if (result != 0)
-			break;
-	}
-	return result;
-}
-
-/**
- * A helper function for lovsub_lock_delete() that deals with a given parent
- * top-lock.
- */
-static int lovsub_lock_delete_one(const struct lu_env *env,
-				  struct cl_lock *child, struct lov_lock *lov)
-{
-	struct cl_lock *parent;
-	int	     result;
-
-	parent = lov->lls_cl.cls_lock;
-	if (parent->cll_error)
-		return 0;
-
-	result = 0;
-	switch (parent->cll_state) {
-	case CLS_ENQUEUED:
-		/* See LU-1355 for the case that a glimpse lock is
-		 * interrupted by signal
-		 */
-		LASSERT(parent->cll_flags & CLF_CANCELLED);
-		break;
-	case CLS_QUEUING:
-	case CLS_FREEING:
-		cl_lock_signal(env, parent);
-		break;
-	case CLS_INTRANSIT:
-		/*
-		 * Here lies a problem: a sub-lock is canceled while top-lock
-		 * is being unlocked. Top-lock cannot be moved into CLS_NEW
-		 * state, because unlocking has to succeed eventually by
-		 * placing lock into CLS_CACHED (or failing it), see
-		 * cl_unuse_try(). Nor can top-lock be left in CLS_CACHED
-		 * state, because lov maintains an invariant that all
-		 * sub-locks exist in CLS_CACHED (this allows cached top-lock
-		 * to be reused immediately). Nor can we wait for top-lock
-		 * state to change, because this can be synchronous to the
-		 * current thread.
-		 *
-		 * We know for sure that lov_lock_unuse() will be called at
-		 * least one more time to finish un-using, so leave a mark on
-		 * the top-lock, that will be seen by the next call to
-		 * lov_lock_unuse().
-		 */
-		if (cl_lock_is_intransit(parent))
-			lov->lls_cancel_race = 1;
-		break;
-	case CLS_CACHED:
-		/*
-		 * if a sub-lock is canceled move its top-lock into CLS_NEW
-		 * state to preserve an invariant that a top-lock in
-		 * CLS_CACHED is immediately ready for re-use (i.e., has all
-		 * sub-locks), and so that next attempt to re-use the top-lock
-		 * enqueues missing sub-lock.
-		 */
-		cl_lock_state_set(env, parent, CLS_NEW);
-		/* fall through */
-	case CLS_NEW:
-		/*
-		 * if last sub-lock is canceled, destroy the top-lock (which
-		 * is now `empty') proactively.
-		 */
-		if (lov->lls_nr_filled == 0) {
-			/* ... but unfortunately, this cannot be done easily,
-			 * as cancellation of a top-lock might acquire mutices
-			 * of its other sub-locks, violating lock ordering,
-			 * see cl_lock_{cancel,delete}() preconditions.
-			 *
-			 * To work around this, the mutex of this sub-lock is
-			 * released, top-lock is destroyed, and sub-lock mutex
-			 * acquired again. The list of parents has to be
-			 * re-scanned from the beginning after this.
-			 *
-			 * Only do this if no mutices other than on @child and
-			 * @parent are held by the current thread.
-			 *
-			 * TODO: The lock modal here is too complex, because
-			 * the lock may be canceled and deleted by voluntarily:
-			 *    cl_lock_request
-			 *      -> osc_lock_enqueue_wait
-			 *	-> osc_lock_cancel_wait
-			 *	  -> cl_lock_delete
-			 *	    -> lovsub_lock_delete
-			 *	      -> cl_lock_cancel/delete
-			 *		-> ...
-			 *
-			 * The better choice is to spawn a kernel thread for
-			 * this purpose. -jay
-			 */
-			if (cl_lock_nr_mutexed(env) == 2) {
-				cl_lock_mutex_put(env, child);
-				cl_lock_cancel(env, parent);
-				cl_lock_delete(env, parent);
-				result = 1;
-			}
-		}
-		break;
-	case CLS_HELD:
-		CL_LOCK_DEBUG(D_ERROR, env, parent, "Delete CLS_HELD lock\n");
-	default:
-		CERROR("Impossible state: %d\n", parent->cll_state);
-		LBUG();
-		break;
-	}
-
-	return result;
-}
-
-/**
- * An implementation of cl_lock_operations::clo_delete() method. This is
- * invoked in "bottom-to-top" delete, when lock destruction starts from the
- * sub-lock (e.g, as a result of ldlm lock LRU policy).
- */
-static void lovsub_lock_delete(const struct lu_env *env,
-			       const struct cl_lock_slice *slice)
-{
-	struct cl_lock     *child = slice->cls_lock;
-	struct lovsub_lock *sub   = cl2lovsub_lock(slice);
-	int restart;
-
-	LASSERT(cl_lock_is_mutexed(child));
-
-	/*
-	 * Destruction of a sub-lock might take multiple iterations, because
-	 * when the last sub-lock of a given top-lock is deleted, top-lock is
-	 * canceled proactively, and this requires to release sub-lock
-	 * mutex. Once sub-lock mutex has been released, list of its parents
-	 * has to be re-scanned from the beginning.
-	 */
-	do {
-		struct lov_lock      *lov;
-		struct lov_lock_link *scan;
-		struct lov_lock_link *temp;
-		struct lov_lock_sub  *subdata;
-
-		restart = 0;
-		list_for_each_entry_safe(scan, temp,
-					 &sub->lss_parents, lll_list) {
-			lov     = scan->lll_super;
-			subdata = &lov->lls_sub[scan->lll_idx];
-			lovsub_parent_lock(env, lov);
-			subdata->sub_got = subdata->sub_descr;
-			lov_lock_unlink(env, scan, sub);
-			restart = lovsub_lock_delete_one(env, child, lov);
-			lovsub_parent_unlock(env, lov);
-
-			if (restart) {
-				cl_lock_mutex_get(env, child);
-				break;
-			}
-	       }
-	} while (restart);
-}
-
-static int lovsub_lock_print(const struct lu_env *env, void *cookie,
-			     lu_printer_t p, const struct cl_lock_slice *slice)
-{
-	struct lovsub_lock   *sub = cl2lovsub_lock(slice);
-	struct lov_lock      *lov;
-	struct lov_lock_link *scan;
-
-	list_for_each_entry(scan, &sub->lss_parents, lll_list) {
-		lov = scan->lll_super;
-		(*p)(env, cookie, "[%d %p ", scan->lll_idx, lov);
-		if (lov)
-			cl_lock_descr_print(env, cookie, p,
-					    &lov->lls_cl.cls_lock->cll_descr);
-		(*p)(env, cookie, "] ");
-	}
-	return 0;
-}
-
 static const struct cl_lock_operations lovsub_lock_ops = {
 	.clo_fini    = lovsub_lock_fini,
-	.clo_state   = lovsub_lock_state,
-	.clo_delete  = lovsub_lock_delete,
-	.clo_modify  = lovsub_lock_modify,
-	.clo_closure = lovsub_lock_closure,
-	.clo_weigh   = lovsub_lock_weigh,
-	.clo_print   = lovsub_lock_print
 };
 
 int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 6a8dd9f..7655dc4 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -160,7 +160,6 @@ static int cl_io_init0(const struct lu_env *env, struct cl_io *io,
 
 	io->ci_type = iot;
 	INIT_LIST_HEAD(&io->ci_lockset.cls_todo);
-	INIT_LIST_HEAD(&io->ci_lockset.cls_curr);
 	INIT_LIST_HEAD(&io->ci_lockset.cls_done);
 	INIT_LIST_HEAD(&io->ci_layers);
 
@@ -242,37 +241,7 @@ static int cl_lock_descr_sort(const struct cl_lock_descr *d0,
 			      const struct cl_lock_descr *d1)
 {
 	return lu_fid_cmp(lu_object_fid(&d0->cld_obj->co_lu),
-			  lu_object_fid(&d1->cld_obj->co_lu)) ?:
-		__diff_normalize(d0->cld_start, d1->cld_start);
-}
-
-static int cl_lock_descr_cmp(const struct cl_lock_descr *d0,
-			     const struct cl_lock_descr *d1)
-{
-	int ret;
-
-	ret = lu_fid_cmp(lu_object_fid(&d0->cld_obj->co_lu),
-			 lu_object_fid(&d1->cld_obj->co_lu));
-	if (ret)
-		return ret;
-	if (d0->cld_end < d1->cld_start)
-		return -1;
-	if (d0->cld_start > d0->cld_end)
-		return 1;
-	return 0;
-}
-
-static void cl_lock_descr_merge(struct cl_lock_descr *d0,
-				const struct cl_lock_descr *d1)
-{
-	d0->cld_start = min(d0->cld_start, d1->cld_start);
-	d0->cld_end = max(d0->cld_end, d1->cld_end);
-
-	if (d1->cld_mode == CLM_WRITE && d0->cld_mode != CLM_WRITE)
-		d0->cld_mode = CLM_WRITE;
-
-	if (d1->cld_mode == CLM_GROUP && d0->cld_mode != CLM_GROUP)
-		d0->cld_mode = CLM_GROUP;
+			  lu_object_fid(&d1->cld_obj->co_lu));
 }
 
 /*
@@ -321,33 +290,35 @@ static void cl_io_locks_sort(struct cl_io *io)
 	} while (!done);
 }
 
-/**
- * Check whether \a queue contains locks matching \a need.
- *
- * \retval +ve there is a matching lock in the \a queue
- * \retval   0 there are no matching locks in the \a queue
- */
-int cl_queue_match(const struct list_head *queue,
-		   const struct cl_lock_descr *need)
+static void cl_lock_descr_merge(struct cl_lock_descr *d0,
+				const struct cl_lock_descr *d1)
 {
-	struct cl_io_lock_link *scan;
+	d0->cld_start = min(d0->cld_start, d1->cld_start);
+	d0->cld_end = max(d0->cld_end, d1->cld_end);
 
-	list_for_each_entry(scan, queue, cill_linkage) {
-		if (cl_lock_descr_match(&scan->cill_descr, need))
-			return 1;
-	}
-	return 0;
+	if (d1->cld_mode == CLM_WRITE && d0->cld_mode != CLM_WRITE)
+		d0->cld_mode = CLM_WRITE;
+
+	if (d1->cld_mode == CLM_GROUP && d0->cld_mode != CLM_GROUP)
+		d0->cld_mode = CLM_GROUP;
 }
-EXPORT_SYMBOL(cl_queue_match);
 
-static int cl_queue_merge(const struct list_head *queue,
-			  const struct cl_lock_descr *need)
+static int cl_lockset_merge(const struct cl_lockset *set,
+			    const struct cl_lock_descr *need)
 {
 	struct cl_io_lock_link *scan;
 
-	list_for_each_entry(scan, queue, cill_linkage) {
-		if (cl_lock_descr_cmp(&scan->cill_descr, need))
+	list_for_each_entry(scan, &set->cls_todo, cill_linkage) {
+		if (!cl_object_same(scan->cill_descr.cld_obj, need->cld_obj))
 			continue;
+
+		/* Merge locks for the same object because ldlm lock server
+		 * may expand the lock extent, otherwise there is a deadlock
+		 * case if two conflicted locks are queueud for the same object
+		 * and lock server expands one lock to overlap the another.
+		 * The side effect is that it can generate a multi-stripe lock
+		 * that may cause casacading problem
+		 */
 		cl_lock_descr_merge(&scan->cill_descr, need);
 		CDEBUG(D_VFSTRACE, "lock: %d: [%lu, %lu]\n",
 		       scan->cill_descr.cld_mode, scan->cill_descr.cld_start,
@@ -357,87 +328,20 @@ static int cl_queue_merge(const struct list_head *queue,
 	return 0;
 }
 
-static int cl_lockset_match(const struct cl_lockset *set,
-			    const struct cl_lock_descr *need)
-{
-	return cl_queue_match(&set->cls_curr, need) ||
-	       cl_queue_match(&set->cls_done, need);
-}
-
-static int cl_lockset_merge(const struct cl_lockset *set,
-			    const struct cl_lock_descr *need)
-{
-	return cl_queue_merge(&set->cls_todo, need) ||
-	       cl_lockset_match(set, need);
-}
-
-static int cl_lockset_lock_one(const struct lu_env *env,
-			       struct cl_io *io, struct cl_lockset *set,
-			       struct cl_io_lock_link *link)
-{
-	struct cl_lock *lock;
-	int	     result;
-
-	lock = cl_lock_request(env, io, &link->cill_descr, "io", io);
-
-	if (!IS_ERR(lock)) {
-		link->cill_lock = lock;
-		list_move(&link->cill_linkage, &set->cls_curr);
-		if (!(link->cill_descr.cld_enq_flags & CEF_ASYNC)) {
-			result = cl_wait(env, lock);
-			if (result == 0)
-				list_move(&link->cill_linkage, &set->cls_done);
-		} else
-			result = 0;
-	} else
-		result = PTR_ERR(lock);
-	return result;
-}
-
-static void cl_lock_link_fini(const struct lu_env *env, struct cl_io *io,
-			      struct cl_io_lock_link *link)
-{
-	struct cl_lock *lock = link->cill_lock;
-
-	list_del_init(&link->cill_linkage);
-	if (lock) {
-		cl_lock_release(env, lock, "io", io);
-		link->cill_lock = NULL;
-	}
-	if (link->cill_fini)
-		link->cill_fini(env, link);
-}
-
 static int cl_lockset_lock(const struct lu_env *env, struct cl_io *io,
 			   struct cl_lockset *set)
 {
 	struct cl_io_lock_link *link;
 	struct cl_io_lock_link *temp;
-	struct cl_lock	 *lock;
 	int result;
 
 	result = 0;
 	list_for_each_entry_safe(link, temp, &set->cls_todo, cill_linkage) {
-		if (!cl_lockset_match(set, &link->cill_descr)) {
-			/* XXX some locking to guarantee that locks aren't
-			 * expanded in between.
-			 */
-			result = cl_lockset_lock_one(env, io, set, link);
-			if (result != 0)
-				break;
-		} else
-			cl_lock_link_fini(env, io, link);
-	}
-	if (result == 0) {
-		list_for_each_entry_safe(link, temp,
-					 &set->cls_curr, cill_linkage) {
-			lock = link->cill_lock;
-			result = cl_wait(env, lock);
-			if (result == 0)
-				list_move(&link->cill_linkage, &set->cls_done);
-			else
-				break;
-		}
+		result = cl_lock_request(env, io, &link->cill_lock);
+		if (result < 0)
+			break;
+
+		list_move(&link->cill_linkage, &set->cls_done);
 	}
 	return result;
 }
@@ -493,16 +397,19 @@ void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
 
 	set = &io->ci_lockset;
 
-	list_for_each_entry_safe(link, temp, &set->cls_todo, cill_linkage)
-		cl_lock_link_fini(env, io, link);
-
-	list_for_each_entry_safe(link, temp, &set->cls_curr, cill_linkage)
-		cl_lock_link_fini(env, io, link);
+	list_for_each_entry_safe(link, temp, &set->cls_todo, cill_linkage) {
+		list_del_init(&link->cill_linkage);
+		if (link->cill_fini)
+			link->cill_fini(env, link);
+	}
 
 	list_for_each_entry_safe(link, temp, &set->cls_done, cill_linkage) {
-		cl_unuse(env, link->cill_lock);
-		cl_lock_link_fini(env, io, link);
+		list_del_init(&link->cill_linkage);
+		cl_lock_release(env, &link->cill_lock);
+		if (link->cill_fini)
+			link->cill_fini(env, link);
 	}
+
 	cl_io_for_each_reverse(scan, io) {
 		if (scan->cis_iop->op[io->ci_type].cio_unlock)
 			scan->cis_iop->op[io->ci_type].cio_unlock(env, scan);
@@ -1435,6 +1342,7 @@ EXPORT_SYMBOL(cl_sync_io_end);
 void cl_sync_io_init(struct cl_sync_io *anchor, int nr,
 		     void (*end)(const struct lu_env *, struct cl_sync_io *))
 {
+	memset(anchor, 0, sizeof(*anchor));
 	init_waitqueue_head(&anchor->csi_waitq);
 	atomic_set(&anchor->csi_sync_nr, nr);
 	atomic_set(&anchor->csi_barrier, nr > 0);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index fe8059a..26a576b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -48,1987 +48,187 @@
 #include "../include/cl_object.h"
 #include "cl_internal.h"
 
-/** Lock class of cl_lock::cll_guard */
-static struct lock_class_key cl_lock_guard_class;
-static struct kmem_cache *cl_lock_kmem;
-
-static struct lu_kmem_descr cl_lock_caches[] = {
-	{
-		.ckd_cache = &cl_lock_kmem,
-		.ckd_name  = "cl_lock_kmem",
-		.ckd_size  = sizeof (struct cl_lock)
-	},
-	{
-		.ckd_cache = NULL
-	}
-};
-
-#define CS_LOCK_INC(o, item)
-#define CS_LOCK_DEC(o, item)
-#define CS_LOCKSTATE_INC(o, state)
-#define CS_LOCKSTATE_DEC(o, state)
-
-/**
- * Basic lock invariant that is maintained at all times. Caller either has a
- * reference to \a lock, or somehow assures that \a lock cannot be freed.
- *
- * \see cl_lock_invariant()
- */
-static int cl_lock_invariant_trusted(const struct lu_env *env,
-				     const struct cl_lock *lock)
-{
-	return  ergo(lock->cll_state == CLS_FREEING, lock->cll_holds == 0) &&
-		atomic_read(&lock->cll_ref) >= lock->cll_holds &&
-		lock->cll_holds >= lock->cll_users &&
-		lock->cll_holds >= 0 &&
-		lock->cll_users >= 0 &&
-		lock->cll_depth >= 0;
-}
-
-/**
- * Stronger lock invariant, checking that caller has a reference on a lock.
- *
- * \see cl_lock_invariant_trusted()
- */
-static int cl_lock_invariant(const struct lu_env *env,
-			     const struct cl_lock *lock)
-{
-	int result;
-
-	result = atomic_read(&lock->cll_ref) > 0 &&
-		cl_lock_invariant_trusted(env, lock);
-	if (!result && env)
-		CL_LOCK_DEBUG(D_ERROR, env, lock, "invariant broken\n");
-	return result;
-}
-
-/**
- * Returns lock "nesting": 0 for a top-lock and 1 for a sub-lock.
- */
-static enum clt_nesting_level cl_lock_nesting(const struct cl_lock *lock)
-{
-	return cl_object_header(lock->cll_descr.cld_obj)->coh_nesting;
-}
-
-/**
- * Returns a set of counters for this lock, depending on a lock nesting.
- */
-static struct cl_thread_counters *cl_lock_counters(const struct lu_env *env,
-						   const struct cl_lock *lock)
-{
-	struct cl_thread_info *info;
-	enum clt_nesting_level nesting;
-
-	info = cl_env_info(env);
-	nesting = cl_lock_nesting(lock);
-	LASSERT(nesting < ARRAY_SIZE(info->clt_counters));
-	return &info->clt_counters[nesting];
-}
-
-static void cl_lock_trace0(int level, const struct lu_env *env,
-			   const char *prefix, const struct cl_lock *lock,
-			   const char *func, const int line)
-{
-	struct cl_object_header *h = cl_object_header(lock->cll_descr.cld_obj);
-
-	CDEBUG(level, "%s: %p@(%d %p %d %d %d %d %d %lx)(%p/%d/%d) at %s():%d\n",
-	       prefix, lock, atomic_read(&lock->cll_ref),
-	       lock->cll_guarder, lock->cll_depth,
-	       lock->cll_state, lock->cll_error, lock->cll_holds,
-	       lock->cll_users, lock->cll_flags,
-	       env, h->coh_nesting, cl_lock_nr_mutexed(env),
-	       func, line);
-}
-
-#define cl_lock_trace(level, env, prefix, lock)			 \
-	cl_lock_trace0(level, env, prefix, lock, __func__, __LINE__)
-
-#define RETIP ((unsigned long)__builtin_return_address(0))
-
-#ifdef CONFIG_LOCKDEP
-static struct lock_class_key cl_lock_key;
-
-static void cl_lock_lockdep_init(struct cl_lock *lock)
-{
-	lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
-}
-
-static void cl_lock_lockdep_acquire(const struct lu_env *env,
-				    struct cl_lock *lock, __u32 enqflags)
-{
-	cl_lock_counters(env, lock)->ctc_nr_locks_acquired++;
-	lock_map_acquire(&lock->dep_map);
-}
-
-static void cl_lock_lockdep_release(const struct lu_env *env,
-				    struct cl_lock *lock)
-{
-	cl_lock_counters(env, lock)->ctc_nr_locks_acquired--;
-	lock_release(&lock->dep_map, 0, RETIP);
-}
-
-#else /* !CONFIG_LOCKDEP */
-
-static void cl_lock_lockdep_init(struct cl_lock *lock)
-{}
-static void cl_lock_lockdep_acquire(const struct lu_env *env,
-				    struct cl_lock *lock, __u32 enqflags)
-{}
-static void cl_lock_lockdep_release(const struct lu_env *env,
-				    struct cl_lock *lock)
-{}
-
-#endif /* !CONFIG_LOCKDEP */
-
-/**
- * Adds lock slice to the compound lock.
- *
- * This is called by cl_object_operations::coo_lock_init() methods to add a
- * per-layer state to the lock. New state is added at the end of
- * cl_lock::cll_layers list, that is, it is at the bottom of the stack.
- *
- * \see cl_req_slice_add(), cl_page_slice_add(), cl_io_slice_add()
- */
-void cl_lock_slice_add(struct cl_lock *lock, struct cl_lock_slice *slice,
-		       struct cl_object *obj,
-		       const struct cl_lock_operations *ops)
-{
-	slice->cls_lock = lock;
-	list_add_tail(&slice->cls_linkage, &lock->cll_layers);
-	slice->cls_obj = obj;
-	slice->cls_ops = ops;
-}
-EXPORT_SYMBOL(cl_lock_slice_add);
-
-/**
- * Returns true iff a lock with the mode \a has provides at least the same
- * guarantees as a lock with the mode \a need.
- */
-int cl_lock_mode_match(enum cl_lock_mode has, enum cl_lock_mode need)
-{
-	LINVRNT(need == CLM_READ || need == CLM_WRITE ||
-		need == CLM_PHANTOM || need == CLM_GROUP);
-	LINVRNT(has == CLM_READ || has == CLM_WRITE ||
-		has == CLM_PHANTOM || has == CLM_GROUP);
-	CLASSERT(CLM_PHANTOM < CLM_READ);
-	CLASSERT(CLM_READ < CLM_WRITE);
-	CLASSERT(CLM_WRITE < CLM_GROUP);
-
-	if (has != CLM_GROUP)
-		return need <= has;
-	else
-		return need == has;
-}
-EXPORT_SYMBOL(cl_lock_mode_match);
-
-/**
- * Returns true iff extent portions of lock descriptions match.
- */
-int cl_lock_ext_match(const struct cl_lock_descr *has,
-		      const struct cl_lock_descr *need)
-{
-	return
-		has->cld_start <= need->cld_start &&
-		has->cld_end >= need->cld_end &&
-		cl_lock_mode_match(has->cld_mode, need->cld_mode) &&
-		(has->cld_mode != CLM_GROUP || has->cld_gid == need->cld_gid);
-}
-EXPORT_SYMBOL(cl_lock_ext_match);
-
-/**
- * Returns true iff a lock with the description \a has provides at least the
- * same guarantees as a lock with the description \a need.
- */
-int cl_lock_descr_match(const struct cl_lock_descr *has,
-			const struct cl_lock_descr *need)
-{
-	return
-		cl_object_same(has->cld_obj, need->cld_obj) &&
-		cl_lock_ext_match(has, need);
-}
-EXPORT_SYMBOL(cl_lock_descr_match);
-
-static void cl_lock_free(const struct lu_env *env, struct cl_lock *lock)
-{
-	struct cl_object *obj = lock->cll_descr.cld_obj;
-
-	LINVRNT(!cl_lock_is_mutexed(lock));
-
-	cl_lock_trace(D_DLMTRACE, env, "free lock", lock);
-	while (!list_empty(&lock->cll_layers)) {
-		struct cl_lock_slice *slice;
-
-		slice = list_entry(lock->cll_layers.next,
-				   struct cl_lock_slice, cls_linkage);
-		list_del_init(lock->cll_layers.next);
-		slice->cls_ops->clo_fini(env, slice);
-	}
-	CS_LOCK_DEC(obj, total);
-	CS_LOCKSTATE_DEC(obj, lock->cll_state);
-	lu_object_ref_del_at(&obj->co_lu, &lock->cll_obj_ref, "cl_lock", lock);
-	cl_object_put(env, obj);
-	lu_ref_fini(&lock->cll_reference);
-	lu_ref_fini(&lock->cll_holders);
-	mutex_destroy(&lock->cll_guard);
-	kmem_cache_free(cl_lock_kmem, lock);
-}
-
-/**
- * Releases a reference on a lock.
- *
- * When last reference is released, lock is returned to the cache, unless it
- * is in cl_lock_state::CLS_FREEING state, in which case it is destroyed
- * immediately.
- *
- * \see cl_object_put(), cl_page_put()
- */
-void cl_lock_put(const struct lu_env *env, struct cl_lock *lock)
-{
-	struct cl_object	*obj;
-
-	LINVRNT(cl_lock_invariant(env, lock));
-	obj = lock->cll_descr.cld_obj;
-	LINVRNT(obj);
-
-	CDEBUG(D_TRACE, "releasing reference: %d %p %lu\n",
-	       atomic_read(&lock->cll_ref), lock, RETIP);
-
-	if (atomic_dec_and_test(&lock->cll_ref)) {
-		if (lock->cll_state == CLS_FREEING) {
-			LASSERT(list_empty(&lock->cll_linkage));
-			cl_lock_free(env, lock);
-		}
-		CS_LOCK_DEC(obj, busy);
-	}
-}
-EXPORT_SYMBOL(cl_lock_put);
-
-/**
- * Acquires an additional reference to a lock.
- *
- * This can be called only by caller already possessing a reference to \a
- * lock.
- *
- * \see cl_object_get(), cl_page_get()
- */
-void cl_lock_get(struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_invariant(NULL, lock));
-	CDEBUG(D_TRACE, "acquiring reference: %d %p %lu\n",
-	       atomic_read(&lock->cll_ref), lock, RETIP);
-	atomic_inc(&lock->cll_ref);
-}
-EXPORT_SYMBOL(cl_lock_get);
-
-/**
- * Acquires a reference to a lock.
- *
- * This is much like cl_lock_get(), except that this function can be used to
- * acquire initial reference to the cached lock. Caller has to deal with all
- * possible races. Use with care!
- *
- * \see cl_page_get_trust()
- */
-void cl_lock_get_trust(struct cl_lock *lock)
-{
-	CDEBUG(D_TRACE, "acquiring trusted reference: %d %p %lu\n",
-	       atomic_read(&lock->cll_ref), lock, RETIP);
-	if (atomic_inc_return(&lock->cll_ref) == 1)
-		CS_LOCK_INC(lock->cll_descr.cld_obj, busy);
-}
-EXPORT_SYMBOL(cl_lock_get_trust);
-
-/**
- * Helper function destroying the lock that wasn't completely initialized.
- *
- * Other threads can acquire references to the top-lock through its
- * sub-locks. Hence, it cannot be cl_lock_free()-ed immediately.
- */
-static void cl_lock_finish(const struct lu_env *env, struct cl_lock *lock)
-{
-	cl_lock_mutex_get(env, lock);
-	cl_lock_cancel(env, lock);
-	cl_lock_delete(env, lock);
-	cl_lock_mutex_put(env, lock);
-	cl_lock_put(env, lock);
-}
-
-static struct cl_lock *cl_lock_alloc(const struct lu_env *env,
-				     struct cl_object *obj,
-				     const struct cl_io *io,
-				     const struct cl_lock_descr *descr)
-{
-	struct cl_lock	  *lock;
-	struct lu_object_header *head;
-
-	lock = kmem_cache_zalloc(cl_lock_kmem, GFP_NOFS);
-	if (lock) {
-		atomic_set(&lock->cll_ref, 1);
-		lock->cll_descr = *descr;
-		lock->cll_state = CLS_NEW;
-		cl_object_get(obj);
-		lu_object_ref_add_at(&obj->co_lu, &lock->cll_obj_ref, "cl_lock",
-				     lock);
-		INIT_LIST_HEAD(&lock->cll_layers);
-		INIT_LIST_HEAD(&lock->cll_linkage);
-		INIT_LIST_HEAD(&lock->cll_inclosure);
-		lu_ref_init(&lock->cll_reference);
-		lu_ref_init(&lock->cll_holders);
-		mutex_init(&lock->cll_guard);
-		lockdep_set_class(&lock->cll_guard, &cl_lock_guard_class);
-		init_waitqueue_head(&lock->cll_wq);
-		head = obj->co_lu.lo_header;
-		CS_LOCKSTATE_INC(obj, CLS_NEW);
-		CS_LOCK_INC(obj, total);
-		CS_LOCK_INC(obj, create);
-		cl_lock_lockdep_init(lock);
-		list_for_each_entry(obj, &head->loh_layers, co_lu.lo_linkage) {
-			int err;
-
-			err = obj->co_ops->coo_lock_init(env, obj, lock, io);
-			if (err != 0) {
-				cl_lock_finish(env, lock);
-				lock = ERR_PTR(err);
-				break;
-			}
-		}
-	} else
-		lock = ERR_PTR(-ENOMEM);
-	return lock;
-}
-
-/**
- * Transfer the lock into INTRANSIT state and return the original state.
- *
- * \pre  state: CLS_CACHED, CLS_HELD or CLS_ENQUEUED
- * \post state: CLS_INTRANSIT
- * \see CLS_INTRANSIT
- */
-static enum cl_lock_state cl_lock_intransit(const struct lu_env *env,
-					    struct cl_lock *lock)
-{
-	enum cl_lock_state state = lock->cll_state;
-
-	LASSERT(cl_lock_is_mutexed(lock));
-	LASSERT(state != CLS_INTRANSIT);
-	LASSERTF(state >= CLS_ENQUEUED && state <= CLS_CACHED,
-		 "Malformed lock state %d.\n", state);
-
-	cl_lock_state_set(env, lock, CLS_INTRANSIT);
-	lock->cll_intransit_owner = current;
-	cl_lock_hold_add(env, lock, "intransit", current);
-	return state;
-}
-
-/**
- *  Exit the intransit state and restore the lock state to the original state
- */
-static void cl_lock_extransit(const struct lu_env *env, struct cl_lock *lock,
-			      enum cl_lock_state state)
-{
-	LASSERT(cl_lock_is_mutexed(lock));
-	LASSERT(lock->cll_state == CLS_INTRANSIT);
-	LASSERT(state != CLS_INTRANSIT);
-	LASSERT(lock->cll_intransit_owner == current);
-
-	lock->cll_intransit_owner = NULL;
-	cl_lock_state_set(env, lock, state);
-	cl_lock_unhold(env, lock, "intransit", current);
-}
-
-/**
- * Checking whether the lock is intransit state
- */
-int cl_lock_is_intransit(struct cl_lock *lock)
-{
-	LASSERT(cl_lock_is_mutexed(lock));
-	return lock->cll_state == CLS_INTRANSIT &&
-	       lock->cll_intransit_owner != current;
-}
-EXPORT_SYMBOL(cl_lock_is_intransit);
-/**
- * Returns true iff lock is "suitable" for given io. E.g., locks acquired by
- * truncate and O_APPEND cannot be reused for read/non-append-write, as they
- * cover multiple stripes and can trigger cascading timeouts.
- */
-static int cl_lock_fits_into(const struct lu_env *env,
-			     const struct cl_lock *lock,
-			     const struct cl_lock_descr *need,
-			     const struct cl_io *io)
-{
-	const struct cl_lock_slice *slice;
-
-	LINVRNT(cl_lock_invariant_trusted(env, lock));
-	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_fits_into &&
-		    !slice->cls_ops->clo_fits_into(env, slice, need, io))
-			return 0;
-	}
-	return 1;
-}
-
-static struct cl_lock *cl_lock_lookup(const struct lu_env *env,
-				      struct cl_object *obj,
-				      const struct cl_io *io,
-				      const struct cl_lock_descr *need)
-{
-	struct cl_lock	  *lock;
-	struct cl_object_header *head;
-
-	head = cl_object_header(obj);
-	assert_spin_locked(&head->coh_lock_guard);
-	CS_LOCK_INC(obj, lookup);
-	list_for_each_entry(lock, &head->coh_locks, cll_linkage) {
-		int matched;
-
-		matched = cl_lock_ext_match(&lock->cll_descr, need) &&
-			  lock->cll_state < CLS_FREEING &&
-			  lock->cll_error == 0 &&
-			  !(lock->cll_flags & CLF_CANCELLED) &&
-			  cl_lock_fits_into(env, lock, need, io);
-		CDEBUG(D_DLMTRACE, "has: "DDESCR"(%d) need: "DDESCR": %d\n",
-		       PDESCR(&lock->cll_descr), lock->cll_state, PDESCR(need),
-		       matched);
-		if (matched) {
-			cl_lock_get_trust(lock);
-			CS_LOCK_INC(obj, hit);
-			return lock;
-		}
-	}
-	return NULL;
-}
-
-/**
- * Returns a lock matching description \a need.
- *
- * This is the main entry point into the cl_lock caching interface. First, a
- * cache (implemented as a per-object linked list) is consulted. If lock is
- * found there, it is returned immediately. Otherwise new lock is allocated
- * and returned. In any case, additional reference to lock is acquired.
- *
- * \see cl_object_find(), cl_page_find()
- */
-static struct cl_lock *cl_lock_find(const struct lu_env *env,
-				    const struct cl_io *io,
-				    const struct cl_lock_descr *need)
-{
-	struct cl_object_header *head;
-	struct cl_object	*obj;
-	struct cl_lock	  *lock;
-
-	obj  = need->cld_obj;
-	head = cl_object_header(obj);
-
-	spin_lock(&head->coh_lock_guard);
-	lock = cl_lock_lookup(env, obj, io, need);
-	spin_unlock(&head->coh_lock_guard);
-
-	if (!lock) {
-		lock = cl_lock_alloc(env, obj, io, need);
-		if (!IS_ERR(lock)) {
-			struct cl_lock *ghost;
-
-			spin_lock(&head->coh_lock_guard);
-			ghost = cl_lock_lookup(env, obj, io, need);
-			if (!ghost) {
-				cl_lock_get_trust(lock);
-				list_add_tail(&lock->cll_linkage,
-					      &head->coh_locks);
-				spin_unlock(&head->coh_lock_guard);
-				CS_LOCK_INC(obj, busy);
-			} else {
-				spin_unlock(&head->coh_lock_guard);
-				/*
-				 * Other threads can acquire references to the
-				 * top-lock through its sub-locks. Hence, it
-				 * cannot be cl_lock_free()-ed immediately.
-				 */
-				cl_lock_finish(env, lock);
-				lock = ghost;
-			}
-		}
-	}
-	return lock;
-}
-
-/**
- * Returns existing lock matching given description. This is similar to
- * cl_lock_find() except that no new lock is created, and returned lock is
- * guaranteed to be in enum cl_lock_state::CLS_HELD state.
- */
-struct cl_lock *cl_lock_peek(const struct lu_env *env, const struct cl_io *io,
-			     const struct cl_lock_descr *need,
-			     const char *scope, const void *source)
-{
-	struct cl_object_header *head;
-	struct cl_object	*obj;
-	struct cl_lock	  *lock;
-
-	obj  = need->cld_obj;
-	head = cl_object_header(obj);
-
-	do {
-		spin_lock(&head->coh_lock_guard);
-		lock = cl_lock_lookup(env, obj, io, need);
-		spin_unlock(&head->coh_lock_guard);
-		if (!lock)
-			return NULL;
-
-		cl_lock_mutex_get(env, lock);
-		if (lock->cll_state == CLS_INTRANSIT)
-			/* Don't care return value. */
-			cl_lock_state_wait(env, lock);
-		if (lock->cll_state == CLS_FREEING) {
-			cl_lock_mutex_put(env, lock);
-			cl_lock_put(env, lock);
-			lock = NULL;
-		}
-	} while (!lock);
-
-	cl_lock_hold_add(env, lock, scope, source);
-	cl_lock_user_add(env, lock);
-	if (lock->cll_state == CLS_CACHED)
-		cl_use_try(env, lock, 1);
-	if (lock->cll_state == CLS_HELD) {
-		cl_lock_mutex_put(env, lock);
-		cl_lock_lockdep_acquire(env, lock, 0);
-		cl_lock_put(env, lock);
-	} else {
-		cl_unuse_try(env, lock);
-		cl_lock_unhold(env, lock, scope, source);
-		cl_lock_mutex_put(env, lock);
-		cl_lock_put(env, lock);
-		lock = NULL;
-	}
-
-	return lock;
-}
-EXPORT_SYMBOL(cl_lock_peek);
-
-/**
- * Returns a slice within a lock, corresponding to the given layer in the
- * device stack.
- *
- * \see cl_page_at()
- */
-const struct cl_lock_slice *cl_lock_at(const struct cl_lock *lock,
-				       const struct lu_device_type *dtype)
-{
-	const struct cl_lock_slice *slice;
-
-	LINVRNT(cl_lock_invariant_trusted(NULL, lock));
-
-	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_obj->co_lu.lo_dev->ld_type == dtype)
-			return slice;
-	}
-	return NULL;
-}
-EXPORT_SYMBOL(cl_lock_at);
-
-static void cl_lock_mutex_tail(const struct lu_env *env, struct cl_lock *lock)
-{
-	struct cl_thread_counters *counters;
-
-	counters = cl_lock_counters(env, lock);
-	lock->cll_depth++;
-	counters->ctc_nr_locks_locked++;
-	lu_ref_add(&counters->ctc_locks_locked, "cll_guard", lock);
-	cl_lock_trace(D_TRACE, env, "got mutex", lock);
-}
-
-/**
- * Locks cl_lock object.
- *
- * This is used to manipulate cl_lock fields, and to serialize state
- * transitions in the lock state machine.
- *
- * \post cl_lock_is_mutexed(lock)
- *
- * \see cl_lock_mutex_put()
- */
-void cl_lock_mutex_get(const struct lu_env *env, struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	if (lock->cll_guarder == current) {
-		LINVRNT(cl_lock_is_mutexed(lock));
-		LINVRNT(lock->cll_depth > 0);
-	} else {
-		struct cl_object_header *hdr;
-		struct cl_thread_info   *info;
-		int i;
-
-		LINVRNT(lock->cll_guarder != current);
-		hdr = cl_object_header(lock->cll_descr.cld_obj);
-		/*
-		 * Check that mutices are taken in the bottom-to-top order.
-		 */
-		info = cl_env_info(env);
-		for (i = 0; i < hdr->coh_nesting; ++i)
-			LASSERT(info->clt_counters[i].ctc_nr_locks_locked == 0);
-		mutex_lock_nested(&lock->cll_guard, hdr->coh_nesting);
-		lock->cll_guarder = current;
-		LINVRNT(lock->cll_depth == 0);
-	}
-	cl_lock_mutex_tail(env, lock);
-}
-EXPORT_SYMBOL(cl_lock_mutex_get);
-
-/**
- * Try-locks cl_lock object.
- *
- * \retval 0 \a lock was successfully locked
- *
- * \retval -EBUSY \a lock cannot be locked right now
- *
- * \post ergo(result == 0, cl_lock_is_mutexed(lock))
- *
- * \see cl_lock_mutex_get()
- */
-static int cl_lock_mutex_try(const struct lu_env *env, struct cl_lock *lock)
-{
-	int result;
-
-	LINVRNT(cl_lock_invariant_trusted(env, lock));
-
-	result = 0;
-	if (lock->cll_guarder == current) {
-		LINVRNT(lock->cll_depth > 0);
-		cl_lock_mutex_tail(env, lock);
-	} else if (mutex_trylock(&lock->cll_guard)) {
-		LINVRNT(lock->cll_depth == 0);
-		lock->cll_guarder = current;
-		cl_lock_mutex_tail(env, lock);
-	} else
-		result = -EBUSY;
-	return result;
-}
-
-/**
- {* Unlocks cl_lock object.
- *
- * \pre cl_lock_is_mutexed(lock)
- *
- * \see cl_lock_mutex_get()
- */
-void cl_lock_mutex_put(const struct lu_env *env, struct cl_lock *lock)
-{
-	struct cl_thread_counters *counters;
-
-	LINVRNT(cl_lock_invariant(env, lock));
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(lock->cll_guarder == current);
-	LINVRNT(lock->cll_depth > 0);
-
-	counters = cl_lock_counters(env, lock);
-	LINVRNT(counters->ctc_nr_locks_locked > 0);
-
-	cl_lock_trace(D_TRACE, env, "put mutex", lock);
-	lu_ref_del(&counters->ctc_locks_locked, "cll_guard", lock);
-	counters->ctc_nr_locks_locked--;
-	if (--lock->cll_depth == 0) {
-		lock->cll_guarder = NULL;
-		mutex_unlock(&lock->cll_guard);
-	}
-}
-EXPORT_SYMBOL(cl_lock_mutex_put);
-
-/**
- * Returns true iff lock's mutex is owned by the current thread.
- */
-int cl_lock_is_mutexed(struct cl_lock *lock)
-{
-	return lock->cll_guarder == current;
-}
-EXPORT_SYMBOL(cl_lock_is_mutexed);
-
-/**
- * Returns number of cl_lock mutices held by the current thread (environment).
- */
-int cl_lock_nr_mutexed(const struct lu_env *env)
-{
-	struct cl_thread_info *info;
-	int i;
-	int locked;
-
-	/*
-	 * NOTE: if summation across all nesting levels (currently 2) proves
-	 *       too expensive, a summary counter can be added to
-	 *       struct cl_thread_info.
-	 */
-	info = cl_env_info(env);
-	for (i = 0, locked = 0; i < ARRAY_SIZE(info->clt_counters); ++i)
-		locked += info->clt_counters[i].ctc_nr_locks_locked;
-	return locked;
-}
-EXPORT_SYMBOL(cl_lock_nr_mutexed);
-
-static void cl_lock_cancel0(const struct lu_env *env, struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	if (!(lock->cll_flags & CLF_CANCELLED)) {
-		const struct cl_lock_slice *slice;
-
-		lock->cll_flags |= CLF_CANCELLED;
-		list_for_each_entry_reverse(slice, &lock->cll_layers,
-					    cls_linkage) {
-			if (slice->cls_ops->clo_cancel)
-				slice->cls_ops->clo_cancel(env, slice);
-		}
-	}
-}
-
-static void cl_lock_delete0(const struct lu_env *env, struct cl_lock *lock)
-{
-	struct cl_object_header    *head;
-	const struct cl_lock_slice *slice;
-
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	if (lock->cll_state < CLS_FREEING) {
-		bool in_cache;
-
-		LASSERT(lock->cll_state != CLS_INTRANSIT);
-		cl_lock_state_set(env, lock, CLS_FREEING);
-
-		head = cl_object_header(lock->cll_descr.cld_obj);
-
-		spin_lock(&head->coh_lock_guard);
-		in_cache = !list_empty(&lock->cll_linkage);
-		if (in_cache)
-			list_del_init(&lock->cll_linkage);
-		spin_unlock(&head->coh_lock_guard);
-
-		if (in_cache) /* coh_locks cache holds a refcount. */
-			cl_lock_put(env, lock);
-
-		/*
-		 * From now on, no new references to this lock can be acquired
-		 * by cl_lock_lookup().
-		 */
-		list_for_each_entry_reverse(slice, &lock->cll_layers,
-					    cls_linkage) {
-			if (slice->cls_ops->clo_delete)
-				slice->cls_ops->clo_delete(env, slice);
-		}
-		/*
-		 * From now on, no new references to this lock can be acquired
-		 * by layer-specific means (like a pointer from struct
-		 * ldlm_lock in osc, or a pointer from top-lock to sub-lock in
-		 * lov).
-		 *
-		 * Lock will be finally freed in cl_lock_put() when last of
-		 * existing references goes away.
-		 */
-	}
-}
-
-/**
- * Mod(ifie)s cl_lock::cll_holds counter for a given lock. Also, for a
- * top-lock (nesting == 0) accounts for this modification in the per-thread
- * debugging counters. Sub-lock holds can be released by a thread different
- * from one that acquired it.
- */
-static void cl_lock_hold_mod(const struct lu_env *env, struct cl_lock *lock,
-			     int delta)
-{
-	struct cl_thread_counters *counters;
-	enum clt_nesting_level     nesting;
-
-	lock->cll_holds += delta;
-	nesting = cl_lock_nesting(lock);
-	if (nesting == CNL_TOP) {
-		counters = &cl_env_info(env)->clt_counters[CNL_TOP];
-		counters->ctc_nr_held += delta;
-		LASSERT(counters->ctc_nr_held >= 0);
-	}
-}
-
-/**
- * Mod(ifie)s cl_lock::cll_users counter for a given lock. See
- * cl_lock_hold_mod() for the explanation of the debugging code.
- */
-static void cl_lock_used_mod(const struct lu_env *env, struct cl_lock *lock,
-			     int delta)
-{
-	struct cl_thread_counters *counters;
-	enum clt_nesting_level     nesting;
-
-	lock->cll_users += delta;
-	nesting = cl_lock_nesting(lock);
-	if (nesting == CNL_TOP) {
-		counters = &cl_env_info(env)->clt_counters[CNL_TOP];
-		counters->ctc_nr_used += delta;
-		LASSERT(counters->ctc_nr_used >= 0);
-	}
-}
-
-void cl_lock_hold_release(const struct lu_env *env, struct cl_lock *lock,
-			  const char *scope, const void *source)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERT(lock->cll_holds > 0);
-
-	cl_lock_trace(D_DLMTRACE, env, "hold release lock", lock);
-	lu_ref_del(&lock->cll_holders, scope, source);
-	cl_lock_hold_mod(env, lock, -1);
-	if (lock->cll_holds == 0) {
-		CL_LOCK_ASSERT(lock->cll_state != CLS_HELD, env, lock);
-		if (lock->cll_descr.cld_mode == CLM_PHANTOM ||
-		    lock->cll_descr.cld_mode == CLM_GROUP ||
-		    lock->cll_state != CLS_CACHED)
-			/*
-			 * If lock is still phantom or grouplock when user is
-			 * done with it---destroy the lock.
-			 */
-			lock->cll_flags |= CLF_CANCELPEND|CLF_DOOMED;
-		if (lock->cll_flags & CLF_CANCELPEND) {
-			lock->cll_flags &= ~CLF_CANCELPEND;
-			cl_lock_cancel0(env, lock);
-		}
-		if (lock->cll_flags & CLF_DOOMED) {
-			/* no longer doomed: it's dead... Jim. */
-			lock->cll_flags &= ~CLF_DOOMED;
-			cl_lock_delete0(env, lock);
-		}
-	}
-}
-EXPORT_SYMBOL(cl_lock_hold_release);
-
-/**
- * Waits until lock state is changed.
- *
- * This function is called with cl_lock mutex locked, atomically releases
- * mutex and goes to sleep, waiting for a lock state change (signaled by
- * cl_lock_signal()), and re-acquires the mutex before return.
- *
- * This function is used to wait until lock state machine makes some progress
- * and to emulate synchronous operations on top of asynchronous lock
- * interface.
- *
- * \retval -EINTR wait was interrupted
- *
- * \retval 0 wait wasn't interrupted
- *
- * \pre cl_lock_is_mutexed(lock)
- *
- * \see cl_lock_signal()
- */
-int cl_lock_state_wait(const struct lu_env *env, struct cl_lock *lock)
-{
-	wait_queue_t waiter;
-	sigset_t blocked;
-	int result;
-
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERT(lock->cll_depth == 1);
-	LASSERT(lock->cll_state != CLS_FREEING); /* too late to wait */
-
-	cl_lock_trace(D_DLMTRACE, env, "state wait lock", lock);
-	result = lock->cll_error;
-	if (result == 0) {
-		/* To avoid being interrupted by the 'non-fatal' signals
-		 * (SIGCHLD, for instance), we'd block them temporarily.
-		 * LU-305
-		 */
-		blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);
-
-		init_waitqueue_entry(&waiter, current);
-		add_wait_queue(&lock->cll_wq, &waiter);
-		set_current_state(TASK_INTERRUPTIBLE);
-		cl_lock_mutex_put(env, lock);
-
-		LASSERT(cl_lock_nr_mutexed(env) == 0);
-
-		/* Returning ERESTARTSYS instead of EINTR so syscalls
-		 * can be restarted if signals are pending here
-		 */
-		result = -ERESTARTSYS;
-		if (likely(!OBD_FAIL_CHECK(OBD_FAIL_LOCK_STATE_WAIT_INTR))) {
-			schedule();
-			if (!signal_pending(current))
-				result = 0;
-		}
-
-		cl_lock_mutex_get(env, lock);
-		set_current_state(TASK_RUNNING);
-		remove_wait_queue(&lock->cll_wq, &waiter);
-
-		/* Restore old blocked signals */
-		cfs_restore_sigs(blocked);
-	}
-	return result;
-}
-EXPORT_SYMBOL(cl_lock_state_wait);
-
-static void cl_lock_state_signal(const struct lu_env *env, struct cl_lock *lock,
-				 enum cl_lock_state state)
-{
-	const struct cl_lock_slice *slice;
-
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	list_for_each_entry(slice, &lock->cll_layers, cls_linkage)
-		if (slice->cls_ops->clo_state)
-			slice->cls_ops->clo_state(env, slice, state);
-	wake_up_all(&lock->cll_wq);
-}
-
-/**
- * Notifies waiters that lock state changed.
- *
- * Wakes up all waiters sleeping in cl_lock_state_wait(), also notifies all
- * layers about state change by calling cl_lock_operations::clo_state()
- * top-to-bottom.
- */
-void cl_lock_signal(const struct lu_env *env, struct cl_lock *lock)
-{
-	cl_lock_trace(D_DLMTRACE, env, "state signal lock", lock);
-	cl_lock_state_signal(env, lock, lock->cll_state);
-}
-EXPORT_SYMBOL(cl_lock_signal);
-
-/**
- * Changes lock state.
- *
- * This function is invoked to notify layers that lock state changed, possible
- * as a result of an asynchronous event such as call-back reception.
- *
- * \post lock->cll_state == state
- *
- * \see cl_lock_operations::clo_state()
- */
-void cl_lock_state_set(const struct lu_env *env, struct cl_lock *lock,
-		       enum cl_lock_state state)
-{
-	LASSERT(lock->cll_state <= state ||
-		(lock->cll_state == CLS_CACHED &&
-		 (state == CLS_HELD || /* lock found in cache */
-		  state == CLS_NEW  ||   /* sub-lock canceled */
-		  state == CLS_INTRANSIT)) ||
-		/* lock is in transit state */
-		lock->cll_state == CLS_INTRANSIT);
-
-	if (lock->cll_state != state) {
-		CS_LOCKSTATE_DEC(lock->cll_descr.cld_obj, lock->cll_state);
-		CS_LOCKSTATE_INC(lock->cll_descr.cld_obj, state);
-
-		cl_lock_state_signal(env, lock, state);
-		lock->cll_state = state;
-	}
-}
-EXPORT_SYMBOL(cl_lock_state_set);
-
-static int cl_unuse_try_internal(const struct lu_env *env, struct cl_lock *lock)
-{
-	const struct cl_lock_slice *slice;
-	int result;
-
-	do {
-		result = 0;
-
-		LINVRNT(cl_lock_is_mutexed(lock));
-		LINVRNT(cl_lock_invariant(env, lock));
-		LASSERT(lock->cll_state == CLS_INTRANSIT);
-
-		result = -ENOSYS;
-		list_for_each_entry_reverse(slice, &lock->cll_layers,
-					    cls_linkage) {
-			if (slice->cls_ops->clo_unuse) {
-				result = slice->cls_ops->clo_unuse(env, slice);
-				if (result != 0)
-					break;
-			}
-		}
-		LASSERT(result != -ENOSYS);
-	} while (result == CLO_REPEAT);
-
-	return result;
-}
-
-/**
- * Yanks lock from the cache (cl_lock_state::CLS_CACHED state) by calling
- * cl_lock_operations::clo_use() top-to-bottom to notify layers.
- * @atomic = 1, it must unuse the lock to recovery the lock to keep the
- *  use process atomic
- */
-int cl_use_try(const struct lu_env *env, struct cl_lock *lock, int atomic)
-{
-	const struct cl_lock_slice *slice;
-	int result;
-	enum cl_lock_state state;
-
-	cl_lock_trace(D_DLMTRACE, env, "use lock", lock);
-
-	LASSERT(lock->cll_state == CLS_CACHED);
-	if (lock->cll_error)
-		return lock->cll_error;
-
-	result = -ENOSYS;
-	state = cl_lock_intransit(env, lock);
-	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_use) {
-			result = slice->cls_ops->clo_use(env, slice);
-			if (result != 0)
-				break;
-		}
-	}
-	LASSERT(result != -ENOSYS);
-
-	LASSERTF(lock->cll_state == CLS_INTRANSIT, "Wrong state %d.\n",
-		 lock->cll_state);
-
-	if (result == 0) {
-		state = CLS_HELD;
-	} else {
-		if (result == -ESTALE) {
-			/*
-			 * ESTALE means sublock being cancelled
-			 * at this time, and set lock state to
-			 * be NEW here and ask the caller to repeat.
-			 */
-			state = CLS_NEW;
-			result = CLO_REPEAT;
-		}
-
-		/* @atomic means back-off-on-failure. */
-		if (atomic) {
-			int rc;
-
-			rc = cl_unuse_try_internal(env, lock);
-			/* Vet the results. */
-			if (rc < 0 && result > 0)
-				result = rc;
-		}
-
-	}
-	cl_lock_extransit(env, lock, state);
-	return result;
-}
-EXPORT_SYMBOL(cl_use_try);
-
-/**
- * Helper for cl_enqueue_try() that calls ->clo_enqueue() across all layers
- * top-to-bottom.
- */
-static int cl_enqueue_kick(const struct lu_env *env,
-			   struct cl_lock *lock,
-			   struct cl_io *io, __u32 flags)
-{
-	int result;
-	const struct cl_lock_slice *slice;
-
-	result = -ENOSYS;
-	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_enqueue) {
-			result = slice->cls_ops->clo_enqueue(env,
-							     slice, io, flags);
-			if (result != 0)
-				break;
-		}
-	}
-	LASSERT(result != -ENOSYS);
-	return result;
-}
-
-/**
- * Tries to enqueue a lock.
- *
- * This function is called repeatedly by cl_enqueue() until either lock is
- * enqueued, or error occurs. This function does not block waiting for
- * networking communication to complete.
- *
- * \post ergo(result == 0, lock->cll_state == CLS_ENQUEUED ||
- *			 lock->cll_state == CLS_HELD)
- *
- * \see cl_enqueue() cl_lock_operations::clo_enqueue()
- * \see cl_lock_state::CLS_ENQUEUED
- */
-int cl_enqueue_try(const struct lu_env *env, struct cl_lock *lock,
-		   struct cl_io *io, __u32 flags)
-{
-	int result;
-
-	cl_lock_trace(D_DLMTRACE, env, "enqueue lock", lock);
-	do {
-		LINVRNT(cl_lock_is_mutexed(lock));
-
-		result = lock->cll_error;
-		if (result != 0)
-			break;
-
-		switch (lock->cll_state) {
-		case CLS_NEW:
-			cl_lock_state_set(env, lock, CLS_QUEUING);
-			/* fall-through */
-		case CLS_QUEUING:
-			/* kick layers. */
-			result = cl_enqueue_kick(env, lock, io, flags);
-			/* For AGL case, the cl_lock::cll_state may
-			 * become CLS_HELD already.
-			 */
-			if (result == 0 && lock->cll_state == CLS_QUEUING)
-				cl_lock_state_set(env, lock, CLS_ENQUEUED);
-			break;
-		case CLS_INTRANSIT:
-			LASSERT(cl_lock_is_intransit(lock));
-			result = CLO_WAIT;
-			break;
-		case CLS_CACHED:
-			/* yank lock from the cache. */
-			result = cl_use_try(env, lock, 0);
-			break;
-		case CLS_ENQUEUED:
-		case CLS_HELD:
-			result = 0;
-			break;
-		default:
-		case CLS_FREEING:
-			/*
-			 * impossible, only held locks with increased
-			 * ->cll_holds can be enqueued, and they cannot be
-			 * freed.
-			 */
-			LBUG();
-		}
-	} while (result == CLO_REPEAT);
-	return result;
-}
-EXPORT_SYMBOL(cl_enqueue_try);
-
-/**
- * Cancel the conflicting lock found during previous enqueue.
- *
- * \retval 0 conflicting lock has been canceled.
- * \retval -ve error code.
- */
-int cl_lock_enqueue_wait(const struct lu_env *env,
-			 struct cl_lock *lock,
-			 int keep_mutex)
-{
-	struct cl_lock  *conflict;
-	int	      rc = 0;
-
-	LASSERT(cl_lock_is_mutexed(lock));
-	LASSERT(lock->cll_state == CLS_QUEUING);
-	LASSERT(lock->cll_conflict);
-
-	conflict = lock->cll_conflict;
-	lock->cll_conflict = NULL;
-
-	cl_lock_mutex_put(env, lock);
-	LASSERT(cl_lock_nr_mutexed(env) == 0);
-
-	cl_lock_mutex_get(env, conflict);
-	cl_lock_trace(D_DLMTRACE, env, "enqueue wait", conflict);
-	cl_lock_cancel(env, conflict);
-	cl_lock_delete(env, conflict);
-
-	while (conflict->cll_state != CLS_FREEING) {
-		rc = cl_lock_state_wait(env, conflict);
-		if (rc != 0)
-			break;
-	}
-	cl_lock_mutex_put(env, conflict);
-	lu_ref_del(&conflict->cll_reference, "cancel-wait", lock);
-	cl_lock_put(env, conflict);
-
-	if (keep_mutex)
-		cl_lock_mutex_get(env, lock);
-
-	LASSERT(rc <= 0);
-	return rc;
-}
-EXPORT_SYMBOL(cl_lock_enqueue_wait);
-
-static int cl_enqueue_locked(const struct lu_env *env, struct cl_lock *lock,
-			     struct cl_io *io, __u32 enqflags)
+static void cl_lock_trace0(int level, const struct lu_env *env,
+			   const char *prefix, const struct cl_lock *lock,
+			   const char *func, const int line)
 {
-	int result;
-
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERT(lock->cll_holds > 0);
+	struct cl_object_header *h = cl_object_header(lock->cll_descr.cld_obj);
 
-	cl_lock_user_add(env, lock);
-	do {
-		result = cl_enqueue_try(env, lock, io, enqflags);
-		if (result == CLO_WAIT) {
-			if (lock->cll_conflict)
-				result = cl_lock_enqueue_wait(env, lock, 1);
-			else
-				result = cl_lock_state_wait(env, lock);
-			if (result == 0)
-				continue;
-		}
-		break;
-	} while (1);
-	if (result != 0)
-		cl_unuse_try(env, lock);
-	LASSERT(ergo(result == 0 && !(enqflags & CEF_AGL),
-		     lock->cll_state == CLS_ENQUEUED ||
-		     lock->cll_state == CLS_HELD));
-	return result;
+	CDEBUG(level, "%s: %p (%p/%d) at %s():%d\n",
+	       prefix, lock, env, h->coh_nesting, func, line);
 }
+#define cl_lock_trace(level, env, prefix, lock)				\
+	cl_lock_trace0(level, env, prefix, lock, __func__, __LINE__)
 
 /**
- * Tries to unlock a lock.
- *
- * This function is called to release underlying resource:
- * 1. for top lock, the resource is sublocks it held;
- * 2. for sublock, the resource is the reference to dlmlock.
+ * Adds lock slice to the compound lock.
  *
- * cl_unuse_try is a one-shot operation, so it must NOT return CLO_WAIT.
+ * This is called by cl_object_operations::coo_lock_init() methods to add a
+ * per-layer state to the lock. New state is added at the end of
+ * cl_lock::cll_layers list, that is, it is at the bottom of the stack.
  *
- * \see cl_unuse() cl_lock_operations::clo_unuse()
- * \see cl_lock_state::CLS_CACHED
+ * \see cl_req_slice_add(), cl_page_slice_add(), cl_io_slice_add()
  */
-int cl_unuse_try(const struct lu_env *env, struct cl_lock *lock)
+void cl_lock_slice_add(struct cl_lock *lock, struct cl_lock_slice *slice,
+		       struct cl_object *obj,
+		       const struct cl_lock_operations *ops)
 {
-	int			 result;
-	enum cl_lock_state	  state = CLS_NEW;
-
-	cl_lock_trace(D_DLMTRACE, env, "unuse lock", lock);
-
-	if (lock->cll_users > 1) {
-		cl_lock_user_del(env, lock);
-		return 0;
-	}
-
-	/* Only if the lock is in CLS_HELD or CLS_ENQUEUED state, it can hold
-	 * underlying resources.
-	 */
-	if (!(lock->cll_state == CLS_HELD || lock->cll_state == CLS_ENQUEUED)) {
-		cl_lock_user_del(env, lock);
-		return 0;
-	}
-
-	/*
-	 * New lock users (->cll_users) are not protecting unlocking
-	 * from proceeding. From this point, lock eventually reaches
-	 * CLS_CACHED, is reinitialized to CLS_NEW or fails into
-	 * CLS_FREEING.
-	 */
-	state = cl_lock_intransit(env, lock);
-
-	result = cl_unuse_try_internal(env, lock);
-	LASSERT(lock->cll_state == CLS_INTRANSIT);
-	LASSERT(result != CLO_WAIT);
-	cl_lock_user_del(env, lock);
-	if (result == 0 || result == -ESTALE) {
-		/*
-		 * Return lock back to the cache. This is the only
-		 * place where lock is moved into CLS_CACHED state.
-		 *
-		 * If one of ->clo_unuse() methods returned -ESTALE, lock
-		 * cannot be placed into cache and has to be
-		 * re-initialized. This happens e.g., when a sub-lock was
-		 * canceled while unlocking was in progress.
-		 */
-		if (state == CLS_HELD && result == 0)
-			state = CLS_CACHED;
-		else
-			state = CLS_NEW;
-		cl_lock_extransit(env, lock, state);
-
-		/*
-		 * Hide -ESTALE error.
-		 * If the lock is a glimpse lock, and it has multiple
-		 * stripes. Assuming that one of its sublock returned -ENAVAIL,
-		 * and other sublocks are matched write locks. In this case,
-		 * we can't set this lock to error because otherwise some of
-		 * its sublocks may not be canceled. This causes some dirty
-		 * pages won't be written to OSTs. -jay
-		 */
-		result = 0;
-	} else {
-		CERROR("result = %d, this is unlikely!\n", result);
-		state = CLS_NEW;
-		cl_lock_extransit(env, lock, state);
-	}
-	return result ?: lock->cll_error;
+	slice->cls_lock = lock;
+	list_add_tail(&slice->cls_linkage, &lock->cll_layers);
+	slice->cls_obj = obj;
+	slice->cls_ops = ops;
 }
-EXPORT_SYMBOL(cl_unuse_try);
+EXPORT_SYMBOL(cl_lock_slice_add);
 
-static void cl_unuse_locked(const struct lu_env *env, struct cl_lock *lock)
+void cl_lock_fini(const struct lu_env *env, struct cl_lock *lock)
 {
-	int result;
+	cl_lock_trace(D_DLMTRACE, env, "destroy lock", lock);
 
-	result = cl_unuse_try(env, lock);
-	if (result)
-		CL_LOCK_DEBUG(D_ERROR, env, lock, "unuse return %d\n", result);
-}
+	while (!list_empty(&lock->cll_layers)) {
+		struct cl_lock_slice *slice;
 
-/**
- * Unlocks a lock.
- */
-void cl_unuse(const struct lu_env *env, struct cl_lock *lock)
-{
-	cl_lock_mutex_get(env, lock);
-	cl_unuse_locked(env, lock);
-	cl_lock_mutex_put(env, lock);
-	cl_lock_lockdep_release(env, lock);
+		slice = list_entry(lock->cll_layers.next,
+				   struct cl_lock_slice, cls_linkage);
+		list_del_init(lock->cll_layers.next);
+		slice->cls_ops->clo_fini(env, slice);
+	}
+	POISON(lock, 0x5a, sizeof(*lock));
 }
-EXPORT_SYMBOL(cl_unuse);
+EXPORT_SYMBOL(cl_lock_fini);
 
-/**
- * Tries to wait for a lock.
- *
- * This function is called repeatedly by cl_wait() until either lock is
- * granted, or error occurs. This function does not block waiting for network
- * communication to complete.
- *
- * \see cl_wait() cl_lock_operations::clo_wait()
- * \see cl_lock_state::CLS_HELD
- */
-int cl_wait_try(const struct lu_env *env, struct cl_lock *lock)
+int cl_lock_init(const struct lu_env *env, struct cl_lock *lock,
+		 const struct cl_io *io)
 {
-	const struct cl_lock_slice *slice;
-	int			 result;
-
-	cl_lock_trace(D_DLMTRACE, env, "wait lock try", lock);
-	do {
-		LINVRNT(cl_lock_is_mutexed(lock));
-		LINVRNT(cl_lock_invariant(env, lock));
-		LASSERTF(lock->cll_state == CLS_QUEUING ||
-			 lock->cll_state == CLS_ENQUEUED ||
-			 lock->cll_state == CLS_HELD ||
-			 lock->cll_state == CLS_INTRANSIT,
-			 "lock state: %d\n", lock->cll_state);
-		LASSERT(lock->cll_users > 0);
-		LASSERT(lock->cll_holds > 0);
+	struct cl_object *obj = lock->cll_descr.cld_obj;
+	struct cl_object *scan;
+	int result = 0;
 
-		result = lock->cll_error;
-		if (result != 0)
-			break;
+	/* Make sure cl_lock::cll_descr is initialized. */
+	LASSERT(obj);
 
-		if (cl_lock_is_intransit(lock)) {
-			result = CLO_WAIT;
+	INIT_LIST_HEAD(&lock->cll_layers);
+	list_for_each_entry(scan, &obj->co_lu.lo_header->loh_layers,
+			    co_lu.lo_linkage) {
+		result = scan->co_ops->coo_lock_init(env, scan, lock, io);
+		if (result != 0) {
+			cl_lock_fini(env, lock);
 			break;
 		}
+	}
 
-		if (lock->cll_state == CLS_HELD)
-			/* nothing to do */
-			break;
-
-		result = -ENOSYS;
-		list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-			if (slice->cls_ops->clo_wait) {
-				result = slice->cls_ops->clo_wait(env, slice);
-				if (result != 0)
-					break;
-			}
-		}
-		LASSERT(result != -ENOSYS);
-		if (result == 0) {
-			LASSERT(lock->cll_state != CLS_INTRANSIT);
-			cl_lock_state_set(env, lock, CLS_HELD);
-		}
-	} while (result == CLO_REPEAT);
 	return result;
 }
-EXPORT_SYMBOL(cl_wait_try);
+EXPORT_SYMBOL(cl_lock_init);
 
 /**
- * Waits until enqueued lock is granted.
- *
- * \pre current thread or io owns a hold on the lock
- * \pre ergo(result == 0, lock->cll_state == CLS_ENQUEUED ||
- *			lock->cll_state == CLS_HELD)
+ * Returns a slice with a lock, corresponding to the given layer in the
+ * device stack.
  *
- * \post ergo(result == 0, lock->cll_state == CLS_HELD)
- */
-int cl_wait(const struct lu_env *env, struct cl_lock *lock)
-{
-	int result;
-
-	cl_lock_mutex_get(env, lock);
-
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERTF(lock->cll_state == CLS_ENQUEUED || lock->cll_state == CLS_HELD,
-		 "Wrong state %d\n", lock->cll_state);
-	LASSERT(lock->cll_holds > 0);
-
-	do {
-		result = cl_wait_try(env, lock);
-		if (result == CLO_WAIT) {
-			result = cl_lock_state_wait(env, lock);
-			if (result == 0)
-				continue;
-		}
-		break;
-	} while (1);
-	if (result < 0) {
-		cl_unuse_try(env, lock);
-		cl_lock_lockdep_release(env, lock);
-	}
-	cl_lock_trace(D_DLMTRACE, env, "wait lock", lock);
-	cl_lock_mutex_put(env, lock);
-	LASSERT(ergo(result == 0, lock->cll_state == CLS_HELD));
-	return result;
-}
-EXPORT_SYMBOL(cl_wait);
-
-/**
- * Executes cl_lock_operations::clo_weigh(), and sums results to estimate lock
- * value.
+ * \see cl_page_at()
  */
-unsigned long cl_lock_weigh(const struct lu_env *env, struct cl_lock *lock)
+const struct cl_lock_slice *cl_lock_at(const struct cl_lock *lock,
+				       const struct lu_device_type *dtype)
 {
 	const struct cl_lock_slice *slice;
-	unsigned long pound;
-	unsigned long ounce;
 
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	pound = 0;
-	list_for_each_entry_reverse(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_weigh) {
-			ounce = slice->cls_ops->clo_weigh(env, slice);
-			pound += ounce;
-			if (pound < ounce) /* over-weight^Wflow */
-				pound = ~0UL;
-		}
+	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
+		if (slice->cls_obj->co_lu.lo_dev->ld_type == dtype)
+			return slice;
 	}
-	return pound;
+	return NULL;
 }
-EXPORT_SYMBOL(cl_lock_weigh);
+EXPORT_SYMBOL(cl_lock_at);
 
-/**
- * Notifies layers that lock description changed.
- *
- * The server can grant client a lock different from one that was requested
- * (e.g., larger in extent). This method is called when actually granted lock
- * description becomes known to let layers to accommodate for changed lock
- * description.
- *
- * \see cl_lock_operations::clo_modify()
- */
-int cl_lock_modify(const struct lu_env *env, struct cl_lock *lock,
-		   const struct cl_lock_descr *desc)
+void cl_lock_cancel(const struct lu_env *env, struct cl_lock *lock)
 {
 	const struct cl_lock_slice *slice;
-	struct cl_object	   *obj = lock->cll_descr.cld_obj;
-	struct cl_object_header    *hdr = cl_object_header(obj);
-	int result;
-
-	cl_lock_trace(D_DLMTRACE, env, "modify lock", lock);
-	/* don't allow object to change */
-	LASSERT(obj == desc->cld_obj);
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
 
+	cl_lock_trace(D_DLMTRACE, env, "cancel lock", lock);
 	list_for_each_entry_reverse(slice, &lock->cll_layers, cls_linkage) {
-		if (slice->cls_ops->clo_modify) {
-			result = slice->cls_ops->clo_modify(env, slice, desc);
-			if (result != 0)
-				return result;
-		}
-	}
-	CL_LOCK_DEBUG(D_DLMTRACE, env, lock, " -> "DDESCR"@"DFID"\n",
-		      PDESCR(desc), PFID(lu_object_fid(&desc->cld_obj->co_lu)));
-	/*
-	 * Just replace description in place. Nothing more is needed for
-	 * now. If locks were indexed according to their extent and/or mode,
-	 * that index would have to be updated here.
-	 */
-	spin_lock(&hdr->coh_lock_guard);
-	lock->cll_descr = *desc;
-	spin_unlock(&hdr->coh_lock_guard);
-	return 0;
-}
-EXPORT_SYMBOL(cl_lock_modify);
-
-/**
- * Initializes lock closure with a given origin.
- *
- * \see cl_lock_closure
- */
-void cl_lock_closure_init(const struct lu_env *env,
-			  struct cl_lock_closure *closure,
-			  struct cl_lock *origin, int wait)
-{
-	LINVRNT(cl_lock_is_mutexed(origin));
-	LINVRNT(cl_lock_invariant(env, origin));
-
-	INIT_LIST_HEAD(&closure->clc_list);
-	closure->clc_origin = origin;
-	closure->clc_wait   = wait;
-	closure->clc_nr     = 0;
-}
-EXPORT_SYMBOL(cl_lock_closure_init);
-
-/**
- * Builds a closure of \a lock.
- *
- * Building of a closure consists of adding initial lock (\a lock) into it,
- * and calling cl_lock_operations::clo_closure() methods of \a lock. These
- * methods might call cl_lock_closure_build() recursively again, adding more
- * locks to the closure, etc.
- *
- * \see cl_lock_closure
- */
-int cl_lock_closure_build(const struct lu_env *env, struct cl_lock *lock,
-			  struct cl_lock_closure *closure)
-{
-	const struct cl_lock_slice *slice;
-	int result;
-
-	LINVRNT(cl_lock_is_mutexed(closure->clc_origin));
-	LINVRNT(cl_lock_invariant(env, closure->clc_origin));
-
-	result = cl_lock_enclosure(env, lock, closure);
-	if (result == 0) {
-		list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
-			if (slice->cls_ops->clo_closure) {
-				result = slice->cls_ops->clo_closure(env, slice,
-								     closure);
-				if (result != 0)
-					break;
-			}
-		}
-	}
-	if (result != 0)
-		cl_lock_disclosure(env, closure);
-	return result;
-}
-EXPORT_SYMBOL(cl_lock_closure_build);
-
-/**
- * Adds new lock to a closure.
- *
- * Try-locks \a lock and if succeeded, adds it to the closure (never more than
- * once). If try-lock failed, returns CLO_REPEAT, after optionally waiting
- * until next try-lock is likely to succeed.
- */
-int cl_lock_enclosure(const struct lu_env *env, struct cl_lock *lock,
-		      struct cl_lock_closure *closure)
-{
-	int result = 0;
-
-	cl_lock_trace(D_DLMTRACE, env, "enclosure lock", lock);
-	if (!cl_lock_mutex_try(env, lock)) {
-		/*
-		 * If lock->cll_inclosure is not empty, lock is already in
-		 * this closure.
-		 */
-		if (list_empty(&lock->cll_inclosure)) {
-			cl_lock_get_trust(lock);
-			lu_ref_add(&lock->cll_reference, "closure", closure);
-			list_add(&lock->cll_inclosure, &closure->clc_list);
-			closure->clc_nr++;
-		} else
-			cl_lock_mutex_put(env, lock);
-		result = 0;
-	} else {
-		cl_lock_disclosure(env, closure);
-		if (closure->clc_wait) {
-			cl_lock_get_trust(lock);
-			lu_ref_add(&lock->cll_reference, "closure-w", closure);
-			cl_lock_mutex_put(env, closure->clc_origin);
-
-			LASSERT(cl_lock_nr_mutexed(env) == 0);
-			cl_lock_mutex_get(env, lock);
-			cl_lock_mutex_put(env, lock);
-
-			cl_lock_mutex_get(env, closure->clc_origin);
-			lu_ref_del(&lock->cll_reference, "closure-w", closure);
-			cl_lock_put(env, lock);
-		}
-		result = CLO_REPEAT;
-	}
-	return result;
-}
-EXPORT_SYMBOL(cl_lock_enclosure);
-
-/** Releases mutices of enclosed locks. */
-void cl_lock_disclosure(const struct lu_env *env,
-			struct cl_lock_closure *closure)
-{
-	struct cl_lock *scan;
-	struct cl_lock *temp;
-
-	cl_lock_trace(D_DLMTRACE, env, "disclosure lock", closure->clc_origin);
-	list_for_each_entry_safe(scan, temp, &closure->clc_list,
-				 cll_inclosure) {
-		list_del_init(&scan->cll_inclosure);
-		cl_lock_mutex_put(env, scan);
-		lu_ref_del(&scan->cll_reference, "closure", closure);
-		cl_lock_put(env, scan);
-		closure->clc_nr--;
-	}
-	LASSERT(closure->clc_nr == 0);
-}
-EXPORT_SYMBOL(cl_lock_disclosure);
-
-/** Finalizes a closure. */
-void cl_lock_closure_fini(struct cl_lock_closure *closure)
-{
-	LASSERT(closure->clc_nr == 0);
-	LASSERT(list_empty(&closure->clc_list));
-}
-EXPORT_SYMBOL(cl_lock_closure_fini);
-
-/**
- * Destroys this lock. Notifies layers (bottom-to-top) that lock is being
- * destroyed, then destroy the lock. If there are holds on the lock, postpone
- * destruction until all holds are released. This is called when a decision is
- * made to destroy the lock in the future. E.g., when a blocking AST is
- * received on it, or fatal communication error happens.
- *
- * Caller must have a reference on this lock to prevent a situation, when
- * deleted lock lingers in memory for indefinite time, because nobody calls
- * cl_lock_put() to finish it.
- *
- * \pre atomic_read(&lock->cll_ref) > 0
- * \pre ergo(cl_lock_nesting(lock) == CNL_TOP,
- *	   cl_lock_nr_mutexed(env) == 1)
- *      [i.e., if a top-lock is deleted, mutices of no other locks can be
- *      held, as deletion of sub-locks might require releasing a top-lock
- *      mutex]
- *
- * \see cl_lock_operations::clo_delete()
- * \see cl_lock::cll_holds
- */
-void cl_lock_delete(const struct lu_env *env, struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERT(ergo(cl_lock_nesting(lock) == CNL_TOP,
-		     cl_lock_nr_mutexed(env) == 1));
-
-	cl_lock_trace(D_DLMTRACE, env, "delete lock", lock);
-	if (lock->cll_holds == 0)
-		cl_lock_delete0(env, lock);
-	else
-		lock->cll_flags |= CLF_DOOMED;
-}
-EXPORT_SYMBOL(cl_lock_delete);
-
-/**
- * Mark lock as irrecoverably failed, and mark it for destruction. This
- * happens when, e.g., server fails to grant a lock to us, or networking
- * time-out happens.
- *
- * \pre atomic_read(&lock->cll_ref) > 0
- *
- * \see clo_lock_delete()
- * \see cl_lock::cll_holds
- */
-void cl_lock_error(const struct lu_env *env, struct cl_lock *lock, int error)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	if (lock->cll_error == 0 && error != 0) {
-		cl_lock_trace(D_DLMTRACE, env, "set lock error", lock);
-		lock->cll_error = error;
-		cl_lock_signal(env, lock);
-		cl_lock_cancel(env, lock);
-		cl_lock_delete(env, lock);
+		if (slice->cls_ops->clo_cancel)
+			slice->cls_ops->clo_cancel(env, slice);
 	}
 }
-EXPORT_SYMBOL(cl_lock_error);
-
-/**
- * Cancels this lock. Notifies layers
- * (bottom-to-top) that lock is being cancelled, then destroy the lock. If
- * there are holds on the lock, postpone cancellation until
- * all holds are released.
- *
- * Cancellation notification is delivered to layers at most once.
- *
- * \see cl_lock_operations::clo_cancel()
- * \see cl_lock::cll_holds
- */
-void cl_lock_cancel(const struct lu_env *env, struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	cl_lock_trace(D_DLMTRACE, env, "cancel lock", lock);
-	if (lock->cll_holds == 0)
-		cl_lock_cancel0(env, lock);
-	else
-		lock->cll_flags |= CLF_CANCELPEND;
-}
 EXPORT_SYMBOL(cl_lock_cancel);
 
 /**
- * Finds an existing lock covering given index and optionally different from a
- * given \a except lock.
+ * Enqueue a lock.
+ * \param anchor: if we need to wait for resources before getting the lock,
+ *		  use @anchor for the purpose.
+ * \retval 0  enqueue successfully
+ * \retval <0 error code
  */
-struct cl_lock *cl_lock_at_pgoff(const struct lu_env *env,
-				 struct cl_object *obj, pgoff_t index,
-				 struct cl_lock *except,
-				 int pending, int canceld)
+int cl_lock_enqueue(const struct lu_env *env, struct cl_io *io,
+		    struct cl_lock *lock, struct cl_sync_io *anchor)
 {
-	struct cl_object_header *head;
-	struct cl_lock	  *scan;
-	struct cl_lock	  *lock;
-	struct cl_lock_descr    *need;
-
-	head = cl_object_header(obj);
-	need = &cl_env_info(env)->clt_descr;
-	lock = NULL;
+	const struct cl_lock_slice *slice;
+	int rc = -ENOSYS;
 
-	need->cld_mode = CLM_READ; /* CLM_READ matches both READ & WRITE, but
-				    * not PHANTOM
-				    */
-	need->cld_start = need->cld_end = index;
-	need->cld_enq_flags = 0;
+	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
+		if (!slice->cls_ops->clo_enqueue)
+			continue;
 
-	spin_lock(&head->coh_lock_guard);
-	/* It is fine to match any group lock since there could be only one
-	 * with a uniq gid and it conflicts with all other lock modes too
-	 */
-	list_for_each_entry(scan, &head->coh_locks, cll_linkage) {
-		if (scan != except &&
-		    (scan->cll_descr.cld_mode == CLM_GROUP ||
-		    cl_lock_ext_match(&scan->cll_descr, need)) &&
-		    scan->cll_state >= CLS_HELD &&
-		    scan->cll_state < CLS_FREEING &&
-		    /*
-		     * This check is racy as the lock can be canceled right
-		     * after it is done, but this is fine, because page exists
-		     * already.
-		     */
-		    (canceld || !(scan->cll_flags & CLF_CANCELLED)) &&
-		    (pending || !(scan->cll_flags & CLF_CANCELPEND))) {
-			/* Don't increase cs_hit here since this
-			 * is just a helper function.
-			 */
-			cl_lock_get_trust(scan);
-			lock = scan;
+		rc = slice->cls_ops->clo_enqueue(env, slice, io, anchor);
+		if (rc != 0)
 			break;
 		}
-	}
-	spin_unlock(&head->coh_lock_guard);
-	return lock;
+	return rc;
 }
-EXPORT_SYMBOL(cl_lock_at_pgoff);
+EXPORT_SYMBOL(cl_lock_enqueue);
 
 /**
- * Eliminate all locks for a given object.
- *
- * Caller has to guarantee that no lock is in active use.
- *
- * \param cancel when this is set, cl_locks_prune() cancels locks before
- *	       destroying.
+ * Main high-level entry point of cl_lock interface that finds existing or
+ * enqueues new lock matching given description.
  */
-void cl_locks_prune(const struct lu_env *env, struct cl_object *obj, int cancel)
+int cl_lock_request(const struct lu_env *env, struct cl_io *io,
+		    struct cl_lock *lock)
 {
-	struct cl_object_header *head;
-	struct cl_lock	  *lock;
-
-	head = cl_object_header(obj);
-
-	spin_lock(&head->coh_lock_guard);
-	while (!list_empty(&head->coh_locks)) {
-		lock = container_of(head->coh_locks.next,
-				    struct cl_lock, cll_linkage);
-		cl_lock_get_trust(lock);
-		spin_unlock(&head->coh_lock_guard);
-		lu_ref_add(&lock->cll_reference, "prune", current);
-
-again:
-		cl_lock_mutex_get(env, lock);
-		if (lock->cll_state < CLS_FREEING) {
-			LASSERT(lock->cll_users <= 1);
-			if (unlikely(lock->cll_users == 1)) {
-				struct l_wait_info lwi = { 0 };
-
-				cl_lock_mutex_put(env, lock);
-				l_wait_event(lock->cll_wq,
-					     lock->cll_users == 0,
-					     &lwi);
-				goto again;
-			}
-
-			if (cancel)
-				cl_lock_cancel(env, lock);
-			cl_lock_delete(env, lock);
-		}
-		cl_lock_mutex_put(env, lock);
-		lu_ref_del(&lock->cll_reference, "prune", current);
-		cl_lock_put(env, lock);
-		spin_lock(&head->coh_lock_guard);
-	}
-	spin_unlock(&head->coh_lock_guard);
-}
-EXPORT_SYMBOL(cl_locks_prune);
+	struct cl_sync_io *anchor = NULL;
+	__u32 enq_flags = lock->cll_descr.cld_enq_flags;
+	int rc;
 
-static struct cl_lock *cl_lock_hold_mutex(const struct lu_env *env,
-					  const struct cl_io *io,
-					  const struct cl_lock_descr *need,
-					  const char *scope, const void *source)
-{
-	struct cl_lock *lock;
+	rc = cl_lock_init(env, lock, io);
+	if (rc < 0)
+		return rc;
 
-	while (1) {
-		lock = cl_lock_find(env, io, need);
-		if (IS_ERR(lock))
-			break;
-		cl_lock_mutex_get(env, lock);
-		if (lock->cll_state < CLS_FREEING &&
-		    !(lock->cll_flags & CLF_CANCELLED)) {
-			cl_lock_hold_mod(env, lock, 1);
-			lu_ref_add(&lock->cll_holders, scope, source);
-			lu_ref_add(&lock->cll_reference, scope, source);
-			break;
-		}
-		cl_lock_mutex_put(env, lock);
-		cl_lock_put(env, lock);
+	if ((enq_flags & CEF_ASYNC) && !(enq_flags & CEF_AGL)) {
+		anchor = &cl_env_info(env)->clt_anchor;
+		cl_sync_io_init(anchor, 1, cl_sync_io_end);
 	}
-	return lock;
-}
 
-/**
- * Returns a lock matching \a need description with a reference and a hold on
- * it.
- *
- * This is much like cl_lock_find(), except that cl_lock_hold() additionally
- * guarantees that lock is not in the CLS_FREEING state on return.
- */
-struct cl_lock *cl_lock_hold(const struct lu_env *env, const struct cl_io *io,
-			     const struct cl_lock_descr *need,
-			     const char *scope, const void *source)
-{
-	struct cl_lock *lock;
+	rc = cl_lock_enqueue(env, io, lock, anchor);
 
-	lock = cl_lock_hold_mutex(env, io, need, scope, source);
-	if (!IS_ERR(lock))
-		cl_lock_mutex_put(env, lock);
-	return lock;
-}
-EXPORT_SYMBOL(cl_lock_hold);
+	if (anchor) {
+		int rc2;
 
-/**
- * Main high-level entry point of cl_lock interface that finds existing or
- * enqueues new lock matching given description.
- */
-struct cl_lock *cl_lock_request(const struct lu_env *env, struct cl_io *io,
-				const struct cl_lock_descr *need,
-				const char *scope, const void *source)
-{
-	struct cl_lock       *lock;
-	int		   rc;
-	__u32		 enqflags = need->cld_enq_flags;
+		/* drop the reference count held at initialization time */
+		cl_sync_io_note(env, anchor, 0);
+		rc2 = cl_sync_io_wait(env, anchor, 0);
+		if (rc2 < 0 && rc == 0)
+			rc = rc2;
+	}
 
-	do {
-		lock = cl_lock_hold_mutex(env, io, need, scope, source);
-		if (IS_ERR(lock))
-			break;
+	if (rc < 0)
+		cl_lock_release(env, lock);
 
-		rc = cl_enqueue_locked(env, lock, io, enqflags);
-		if (rc == 0) {
-			if (cl_lock_fits_into(env, lock, need, io)) {
-				if (!(enqflags & CEF_AGL)) {
-					cl_lock_mutex_put(env, lock);
-					cl_lock_lockdep_acquire(env, lock,
-								enqflags);
-					break;
-				}
-				rc = 1;
-			}
-			cl_unuse_locked(env, lock);
-		}
-		cl_lock_trace(D_DLMTRACE, env,
-			      rc <= 0 ? "enqueue failed" : "agl succeed", lock);
-		cl_lock_hold_release(env, lock, scope, source);
-		cl_lock_mutex_put(env, lock);
-		lu_ref_del(&lock->cll_reference, scope, source);
-		cl_lock_put(env, lock);
-		if (rc > 0) {
-			LASSERT(enqflags & CEF_AGL);
-			lock = NULL;
-		} else if (rc != 0) {
-			lock = ERR_PTR(rc);
-		}
-	} while (rc == 0);
-	return lock;
+	return rc;
 }
 EXPORT_SYMBOL(cl_lock_request);
 
 /**
- * Adds a hold to a known lock.
- */
-void cl_lock_hold_add(const struct lu_env *env, struct cl_lock *lock,
-		      const char *scope, const void *source)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERT(lock->cll_state != CLS_FREEING);
-
-	cl_lock_get(lock);
-	cl_lock_hold_mod(env, lock, 1);
-	lu_ref_add(&lock->cll_holders, scope, source);
-	lu_ref_add(&lock->cll_reference, scope, source);
-}
-EXPORT_SYMBOL(cl_lock_hold_add);
-
-/**
- * Releases a hold and a reference on a lock, on which caller acquired a
- * mutex.
- */
-void cl_lock_unhold(const struct lu_env *env, struct cl_lock *lock,
-		    const char *scope, const void *source)
-{
-	LINVRNT(cl_lock_invariant(env, lock));
-	cl_lock_hold_release(env, lock, scope, source);
-	lu_ref_del(&lock->cll_reference, scope, source);
-	cl_lock_put(env, lock);
-}
-EXPORT_SYMBOL(cl_lock_unhold);
-
-/**
  * Releases a hold and a reference on a lock, obtained by cl_lock_hold().
  */
-void cl_lock_release(const struct lu_env *env, struct cl_lock *lock,
-		     const char *scope, const void *source)
+void cl_lock_release(const struct lu_env *env, struct cl_lock *lock)
 {
-	LINVRNT(cl_lock_invariant(env, lock));
 	cl_lock_trace(D_DLMTRACE, env, "release lock", lock);
-	cl_lock_mutex_get(env, lock);
-	cl_lock_hold_release(env, lock, scope, source);
-	cl_lock_mutex_put(env, lock);
-	lu_ref_del(&lock->cll_reference, scope, source);
-	cl_lock_put(env, lock);
+	cl_lock_cancel(env, lock);
+	cl_lock_fini(env, lock);
 }
 EXPORT_SYMBOL(cl_lock_release);
 
-void cl_lock_user_add(const struct lu_env *env, struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-
-	cl_lock_used_mod(env, lock, 1);
-}
-EXPORT_SYMBOL(cl_lock_user_add);
-
-void cl_lock_user_del(const struct lu_env *env, struct cl_lock *lock)
-{
-	LINVRNT(cl_lock_is_mutexed(lock));
-	LINVRNT(cl_lock_invariant(env, lock));
-	LASSERT(lock->cll_users > 0);
-
-	cl_lock_used_mod(env, lock, -1);
-	if (lock->cll_users == 0)
-		wake_up_all(&lock->cll_wq);
-}
-EXPORT_SYMBOL(cl_lock_user_del);
-
 const char *cl_lock_mode_name(const enum cl_lock_mode mode)
 {
 	static const char *names[] = {
-		[CLM_PHANTOM] = "P",
 		[CLM_READ]    = "R",
 		[CLM_WRITE]   = "W",
 		[CLM_GROUP]   = "G"
@@ -2061,10 +261,8 @@ void cl_lock_print(const struct lu_env *env, void *cookie,
 		   lu_printer_t printer, const struct cl_lock *lock)
 {
 	const struct cl_lock_slice *slice;
-	(*printer)(env, cookie, "lock@%p[%d %d %d %d %d %08lx] ",
-		   lock, atomic_read(&lock->cll_ref),
-		   lock->cll_state, lock->cll_error, lock->cll_holds,
-		   lock->cll_users, lock->cll_flags);
+
+	(*printer)(env, cookie, "lock@%p", lock);
 	cl_lock_descr_print(env, cookie, printer, &lock->cll_descr);
 	(*printer)(env, cookie, " {\n");
 
@@ -2079,13 +277,3 @@ void cl_lock_print(const struct lu_env *env, void *cookie,
 	(*printer)(env, cookie, "} lock@%p\n", lock);
 }
 EXPORT_SYMBOL(cl_lock_print);
-
-int cl_lock_init(void)
-{
-	return lu_kmem_init(cl_lock_caches);
-}
-
-void cl_lock_fini(void)
-{
-	lu_kmem_fini(cl_lock_caches);
-}
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 72e6333..395b92c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -44,7 +44,6 @@
  *
  *  i_mutex
  *      PG_locked
- *	  ->coh_lock_guard
  *	  ->coh_attr_guard
  *	  ->ls_guard
  */
@@ -63,8 +62,6 @@
 
 static struct kmem_cache *cl_env_kmem;
 
-/** Lock class of cl_object_header::coh_lock_guard */
-static struct lock_class_key cl_lock_guard_class;
 /** Lock class of cl_object_header::coh_attr_guard */
 static struct lock_class_key cl_attr_guard_class;
 
@@ -79,11 +76,8 @@ int cl_object_header_init(struct cl_object_header *h)
 
 	result = lu_object_header_init(&h->coh_lu);
 	if (result == 0) {
-		spin_lock_init(&h->coh_lock_guard);
 		spin_lock_init(&h->coh_attr_guard);
-		lockdep_set_class(&h->coh_lock_guard, &cl_lock_guard_class);
 		lockdep_set_class(&h->coh_attr_guard, &cl_attr_guard_class);
-		INIT_LIST_HEAD(&h->coh_locks);
 		h->coh_page_bufsize = 0;
 	}
 	return result;
@@ -310,7 +304,7 @@ EXPORT_SYMBOL(cl_conf_set);
 /**
  * Prunes caches of pages and locks for this object.
  */
-void cl_object_prune(const struct lu_env *env, struct cl_object *obj)
+int cl_object_prune(const struct lu_env *env, struct cl_object *obj)
 {
 	struct lu_object_header *top;
 	struct cl_object *o;
@@ -326,10 +320,7 @@ void cl_object_prune(const struct lu_env *env, struct cl_object *obj)
 		}
 	}
 
-	/* TODO: pruning locks will be moved into layers after cl_lock
-	 * simplification is done
-	 */
-	cl_locks_prune(env, obj, 1);
+	return result;
 }
 EXPORT_SYMBOL(cl_object_prune);
 
@@ -342,19 +333,9 @@ EXPORT_SYMBOL(cl_object_prune);
  */
 void cl_object_kill(const struct lu_env *env, struct cl_object *obj)
 {
-	struct cl_object_header *hdr;
-
-	hdr = cl_object_header(obj);
+	struct cl_object_header *hdr = cl_object_header(obj);
 
 	set_bit(LU_OBJECT_HEARD_BANSHEE, &hdr->coh_lu.loh_flags);
-	/*
-	 * Destroy all locks. Object destruction (including cl_inode_fini())
-	 * cannot cancel the locks, because in the case of a local client,
-	 * where client and server share the same thread running
-	 * prune_icache(), this can dead-lock with ldlm_cancel_handler()
-	 * waiting on __wait_on_freeing_inode().
-	 */
-	cl_locks_prune(env, obj, 0);
 }
 EXPORT_SYMBOL(cl_object_kill);
 
@@ -406,11 +387,8 @@ int cl_site_init(struct cl_site *s, struct cl_device *d)
 	result = lu_site_init(&s->cs_lu, &d->cd_lu_dev);
 	if (result == 0) {
 		cache_stats_init(&s->cs_pages, "pages");
-		cache_stats_init(&s->cs_locks, "locks");
 		for (i = 0; i < ARRAY_SIZE(s->cs_pages_state); ++i)
 			atomic_set(&s->cs_pages_state[0], 0);
-		for (i = 0; i < ARRAY_SIZE(s->cs_locks_state); ++i)
-			atomic_set(&s->cs_locks_state[i], 0);
 		cl_env_percpu_refill();
 	}
 	return result;
@@ -445,15 +423,6 @@ int cl_site_stats_print(const struct cl_site *site, struct seq_file *m)
 		[CPS_PAGEIN]  = "r",
 		[CPS_FREEING] = "f"
 	};
-	static const char *lstate[] = {
-		[CLS_NEW]       = "n",
-		[CLS_QUEUING]   = "q",
-		[CLS_ENQUEUED]  = "e",
-		[CLS_HELD]      = "h",
-		[CLS_INTRANSIT] = "t",
-		[CLS_CACHED]    = "c",
-		[CLS_FREEING]   = "f"
-	};
 /*
        lookup    hit  total   busy create
 pages: ...... ...... ...... ...... ...... [...... ...... ...... ......]
@@ -467,12 +436,6 @@ locks: ...... ...... ...... ...... ...... [...... ...... ...... ...... ......]
 		seq_printf(m, "%s: %u ", pstate[i],
 			   atomic_read(&site->cs_pages_state[i]));
 	seq_printf(m, "]\n");
-	cache_stats_print(&site->cs_locks, m, 0);
-	seq_printf(m, " [");
-	for (i = 0; i < ARRAY_SIZE(site->cs_locks_state); ++i)
-		seq_printf(m, "%s: %u ", lstate[i],
-			   atomic_read(&site->cs_locks_state[i]));
-	seq_printf(m, "]\n");
 	cache_stats_print(&cl_env_stats, m, 0);
 	seq_printf(m, "\n");
 	return 0;
@@ -1147,12 +1110,6 @@ void cl_stack_fini(const struct lu_env *env, struct cl_device *cl)
 }
 EXPORT_SYMBOL(cl_stack_fini);
 
-int  cl_lock_init(void);
-void cl_lock_fini(void);
-
-int  cl_page_init(void);
-void cl_page_fini(void);
-
 static struct lu_context_key cl_key;
 
 struct cl_thread_info *cl_env_info(const struct lu_env *env)
@@ -1247,22 +1204,13 @@ int cl_global_init(void)
 	if (result)
 		goto out_kmem;
 
-	result = cl_lock_init();
-	if (result)
-		goto out_context;
-
-	result = cl_page_init();
-	if (result)
-		goto out_lock;
-
 	result = cl_env_percpu_init();
 	if (result)
 		/* no cl_env_percpu_fini on error */
-		goto out_lock;
+		goto out_context;
 
 	return 0;
-out_lock:
-	cl_lock_fini();
+
 out_context:
 	lu_context_key_degister(&cl_key);
 out_kmem:
@@ -1278,8 +1226,6 @@ out_store:
 void cl_global_fini(void)
 {
 	cl_env_percpu_fini();
-	cl_lock_fini();
-	cl_page_fini();
 	lu_context_key_degister(&cl_key);
 	lu_kmem_fini(cl_object_caches);
 	cl_env_store_fini();
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index ad7f0ae..8df39ce 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1075,12 +1075,3 @@ void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
 	slice->cpl_page = page;
 }
 EXPORT_SYMBOL(cl_page_slice_add);
-
-int  cl_page_init(void)
-{
-	return 0;
-}
-
-void cl_page_fini(void)
-{
-}
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 0d84d04..a752bb4 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -171,7 +171,7 @@ struct echo_thread_info {
 
 	struct cl_2queue	eti_queue;
 	struct cl_io	    eti_io;
-	struct cl_lock_descr    eti_descr;
+	struct cl_lock          eti_lock;
 	struct lu_fid	   eti_fid;
 	struct lu_fid		eti_fid2;
 };
@@ -327,26 +327,8 @@ static void echo_lock_fini(const struct lu_env *env,
 	kmem_cache_free(echo_lock_kmem, ecl);
 }
 
-static void echo_lock_delete(const struct lu_env *env,
-			     const struct cl_lock_slice *slice)
-{
-	struct echo_lock *ecl      = cl2echo_lock(slice);
-
-	LASSERT(list_empty(&ecl->el_chain));
-}
-
-static int echo_lock_fits_into(const struct lu_env *env,
-			       const struct cl_lock_slice *slice,
-			       const struct cl_lock_descr *need,
-			       const struct cl_io *unused)
-{
-	return 1;
-}
-
 static struct cl_lock_operations echo_lock_ops = {
 	.clo_fini      = echo_lock_fini,
-	.clo_delete    = echo_lock_delete,
-	.clo_fits_into = echo_lock_fits_into
 };
 
 /** @} echo_lock */
@@ -811,16 +793,7 @@ static void echo_lock_release(const struct lu_env *env,
 {
 	struct cl_lock *clk = echo_lock2cl(ecl);
 
-	cl_lock_get(clk);
-	cl_unuse(env, clk);
-	cl_lock_release(env, clk, "ec enqueue", ecl->el_object);
-	if (!still_used) {
-		cl_lock_mutex_get(env, clk);
-		cl_lock_cancel(env, clk);
-		cl_lock_delete(env, clk);
-		cl_lock_mutex_put(env, clk);
-	}
-	cl_lock_put(env, clk);
+	cl_lock_release(env, clk);
 }
 
 static struct lu_device *echo_device_free(const struct lu_env *env,
@@ -1014,9 +987,11 @@ static int cl_echo_enqueue0(struct lu_env *env, struct echo_object *eco,
 
 	info = echo_env_info(env);
 	io = &info->eti_io;
-	descr = &info->eti_descr;
+	lck = &info->eti_lock;
 	obj = echo_obj2cl(eco);
 
+	memset(lck, 0, sizeof(*lck));
+	descr = &lck->cll_descr;
 	descr->cld_obj   = obj;
 	descr->cld_start = cl_index(obj, start);
 	descr->cld_end   = cl_index(obj, end);
@@ -1024,25 +999,20 @@ static int cl_echo_enqueue0(struct lu_env *env, struct echo_object *eco,
 	descr->cld_enq_flags = enqflags;
 	io->ci_obj = obj;
 
-	lck = cl_lock_request(env, io, descr, "ec enqueue", eco);
-	if (lck) {
+	rc = cl_lock_request(env, io, lck);
+	if (rc == 0) {
 		struct echo_client_obd *ec = eco->eo_dev->ed_ec;
 		struct echo_lock *el;
 
-		rc = cl_wait(env, lck);
-		if (rc == 0) {
-			el = cl2echo_lock(cl_lock_at(lck, &echo_device_type));
-			spin_lock(&ec->ec_lock);
-			if (list_empty(&el->el_chain)) {
-				list_add(&el->el_chain, &ec->ec_locks);
-				el->el_cookie = ++ec->ec_unique;
-			}
-			atomic_inc(&el->el_refcount);
-			*cookie = el->el_cookie;
-			spin_unlock(&ec->ec_lock);
-		} else {
-			cl_lock_release(env, lck, "ec enqueue", current);
+		el = cl2echo_lock(cl_lock_at(lck, &echo_device_type));
+		spin_lock(&ec->ec_lock);
+		if (list_empty(&el->el_chain)) {
+			list_add(&el->el_chain, &ec->ec_locks);
+			el->el_cookie = ++ec->ec_unique;
 		}
+		atomic_inc(&el->el_refcount);
+		*cookie = el->el_cookie;
+		spin_unlock(&ec->ec_lock);
 	}
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index c510659..d01f2a2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -76,6 +76,8 @@ static inline char *ext_flags(struct osc_extent *ext, char *flags)
 	*buf++ = ext->oe_rw ? 'r' : 'w';
 	if (ext->oe_intree)
 		*buf++ = 'i';
+	if (ext->oe_sync)
+		*buf++ = 'S';
 	if (ext->oe_srvlock)
 		*buf++ = 's';
 	if (ext->oe_hp)
@@ -121,9 +123,13 @@ static const char *oes_strings[] = {
 		__ext->oe_grants, __ext->oe_nr_pages,			      \
 		list_empty_marker(&__ext->oe_pages),			      \
 		waitqueue_active(&__ext->oe_waitq) ? '+' : '-',		      \
-		__ext->oe_osclock, __ext->oe_mppr, __ext->oe_owner,	      \
+		__ext->oe_dlmlock, __ext->oe_mppr, __ext->oe_owner,	      \
 		/* ----- part 4 ----- */				      \
 		## __VA_ARGS__);					      \
+	if (lvl == D_ERROR && __ext->oe_dlmlock)			      \
+		LDLM_ERROR(__ext->oe_dlmlock, "extent: %p\n", __ext);	      \
+	else								      \
+		LDLM_DEBUG(__ext->oe_dlmlock, "extent: %p\n", __ext);	      \
 } while (0)
 
 #undef EASSERTF
@@ -240,20 +246,25 @@ static int osc_extent_sanity_check0(struct osc_extent *ext,
 		goto out;
 	}
 
-	if (!ext->oe_osclock && ext->oe_grants > 0) {
+	if (ext->oe_sync && ext->oe_grants > 0) {
 		rc = 90;
 		goto out;
 	}
 
-	if (ext->oe_osclock) {
-		struct cl_lock_descr *descr;
+	if (ext->oe_dlmlock) {
+		struct ldlm_extent *extent;
 
-		descr = &ext->oe_osclock->cll_descr;
-		if (!(descr->cld_start <= ext->oe_start &&
-		      descr->cld_end >= ext->oe_max_end)) {
+		extent = &ext->oe_dlmlock->l_policy_data.l_extent;
+		if (!(extent->start <= cl_offset(osc2cl(obj), ext->oe_start) &&
+		      extent->end >= cl_offset(osc2cl(obj), ext->oe_max_end))) {
 			rc = 100;
 			goto out;
 		}
+
+		if (!(ext->oe_dlmlock->l_granted_mode & (LCK_PW | LCK_GROUP))) {
+			rc = 102;
+			goto out;
+		}
 	}
 
 	if (ext->oe_nr_pages > ext->oe_mppr) {
@@ -359,7 +370,7 @@ static struct osc_extent *osc_extent_alloc(struct osc_object *obj)
 	ext->oe_state = OES_INV;
 	INIT_LIST_HEAD(&ext->oe_pages);
 	init_waitqueue_head(&ext->oe_waitq);
-	ext->oe_osclock = NULL;
+	ext->oe_dlmlock = NULL;
 
 	return ext;
 }
@@ -385,9 +396,11 @@ static void osc_extent_put(const struct lu_env *env, struct osc_extent *ext)
 		LASSERT(ext->oe_state == OES_INV);
 		LASSERT(!ext->oe_intree);
 
-		if (ext->oe_osclock) {
-			cl_lock_put(env, ext->oe_osclock);
-			ext->oe_osclock = NULL;
+		if (ext->oe_dlmlock) {
+			lu_ref_add(&ext->oe_dlmlock->l_reference,
+				   "osc_extent", ext);
+			LDLM_LOCK_PUT(ext->oe_dlmlock);
+			ext->oe_dlmlock = NULL;
 		}
 		osc_extent_free(ext);
 	}
@@ -543,7 +556,7 @@ static int osc_extent_merge(const struct lu_env *env, struct osc_extent *cur,
 	if (cur->oe_max_end != victim->oe_max_end)
 		return -ERANGE;
 
-	LASSERT(cur->oe_osclock == victim->oe_osclock);
+	LASSERT(cur->oe_dlmlock == victim->oe_dlmlock);
 	ppc_bits = osc_cli(obj)->cl_chunkbits - PAGE_CACHE_SHIFT;
 	chunk_start = cur->oe_start >> ppc_bits;
 	chunk_end = cur->oe_end >> ppc_bits;
@@ -624,10 +637,10 @@ static inline int overlapped(struct osc_extent *ex1, struct osc_extent *ex2)
 static struct osc_extent *osc_extent_find(const struct lu_env *env,
 					  struct osc_object *obj, pgoff_t index,
 					  int *grants)
-
 {
 	struct client_obd *cli = osc_cli(obj);
-	struct cl_lock *lock;
+	struct osc_lock   *olck;
+	struct cl_lock_descr *descr;
 	struct osc_extent *cur;
 	struct osc_extent *ext;
 	struct osc_extent *conflict = NULL;
@@ -644,8 +657,12 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	if (!cur)
 		return ERR_PTR(-ENOMEM);
 
-	lock = cl_lock_at_pgoff(env, osc2cl(obj), index, NULL, 1, 0);
-	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
+	olck = osc_env_io(env)->oi_write_osclock;
+	LASSERTF(olck, "page %lu is not covered by lock\n", index);
+	LASSERT(olck->ols_state == OLS_GRANTED);
+
+	descr = &olck->ols_cl.cls_lock->cll_descr;
+	LASSERT(descr->cld_mode >= CLM_WRITE);
 
 	LASSERT(cli->cl_chunkbits >= PAGE_CACHE_SHIFT);
 	ppc_bits = cli->cl_chunkbits - PAGE_CACHE_SHIFT;
@@ -657,19 +674,23 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	max_pages = cli->cl_max_pages_per_rpc;
 	LASSERT((max_pages & ~chunk_mask) == 0);
 	max_end = index - (index % max_pages) + max_pages - 1;
-	max_end = min_t(pgoff_t, max_end, lock->cll_descr.cld_end);
+	max_end = min_t(pgoff_t, max_end, descr->cld_end);
 
 	/* initialize new extent by parameters so far */
 	cur->oe_max_end = max_end;
 	cur->oe_start = index & chunk_mask;
 	cur->oe_end = ((index + ~chunk_mask + 1) & chunk_mask) - 1;
-	if (cur->oe_start < lock->cll_descr.cld_start)
-		cur->oe_start = lock->cll_descr.cld_start;
+	if (cur->oe_start < descr->cld_start)
+		cur->oe_start = descr->cld_start;
 	if (cur->oe_end > max_end)
 		cur->oe_end = max_end;
-	cur->oe_osclock = lock;
 	cur->oe_grants = 0;
 	cur->oe_mppr = max_pages;
+	if (olck->ols_dlmlock) {
+		LASSERT(olck->ols_hold);
+		cur->oe_dlmlock = LDLM_LOCK_GET(olck->ols_dlmlock);
+		lu_ref_add(&olck->ols_dlmlock->l_reference, "osc_extent", cur);
+	}
 
 	/* grants has been allocated by caller */
 	LASSERTF(*grants >= chunksize + cli->cl_extent_tax,
@@ -691,7 +712,7 @@ restart:
 			break;
 
 		/* if covering by different locks, no chance to match */
-		if (lock != ext->oe_osclock) {
+		if (olck->ols_dlmlock != ext->oe_dlmlock) {
 			EASSERTF(!overlapped(ext, cur), ext,
 				 EXTSTR"\n", EXTPARA(cur));
 
@@ -795,7 +816,7 @@ restart:
 	if (found) {
 		LASSERT(!conflict);
 		if (!IS_ERR(found)) {
-			LASSERT(found->oe_osclock == cur->oe_osclock);
+			LASSERT(found->oe_dlmlock == cur->oe_dlmlock);
 			OSC_EXTENT_DUMP(D_CACHE, found,
 					"found caching ext for %lu.\n", index);
 		}
@@ -810,7 +831,7 @@ restart:
 		found = osc_extent_hold(cur);
 		osc_extent_insert(obj, cur);
 		OSC_EXTENT_DUMP(D_CACHE, cur, "add into tree %lu/%lu.\n",
-				index, lock->cll_descr.cld_end);
+				index, descr->cld_end);
 	}
 	osc_object_unlock(obj);
 
@@ -2630,6 +2651,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	}
 
 	ext->oe_rw = !!(cmd & OBD_BRW_READ);
+	ext->oe_sync = 1;
 	ext->oe_urgent = 1;
 	ext->oe_start = start;
 	ext->oe_end = ext->oe_max_end = end;
@@ -3087,27 +3109,27 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 				struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
-	struct cl_lock *lock = cbdata;
+	struct osc_object *osc = cbdata;
 	pgoff_t index;
 
 	index = osc_index(ops);
 	if (index >= info->oti_fn_index) {
-		struct cl_lock *tmp;
+		struct ldlm_lock *tmp;
 		struct cl_page *page = ops->ops_cl.cpl_page;
 
 		/* refresh non-overlapped index */
-		tmp = cl_lock_at_pgoff(env, lock->cll_descr.cld_obj, index,
-				       lock, 1, 0);
+		tmp = osc_dlmlock_at_pgoff(env, osc, index, 0, 0);
 		if (tmp) {
+			__u64 end = tmp->l_policy_data.l_extent.end;
 			/* Cache the first-non-overlapped index so as to skip
-			 * all pages within [index, oti_fn_index). This
-			 * is safe because if tmp lock is canceled, it will
-			 * discard these pages.
+			 * all pages within [index, oti_fn_index). This is safe
+			 * because if tmp lock is canceled, it will discard
+			 * these pages.
 			 */
-			info->oti_fn_index = tmp->cll_descr.cld_end + 1;
-			if (tmp->cll_descr.cld_end == CL_PAGE_EOF)
+			info->oti_fn_index = cl_index(osc2cl(osc), end + 1);
+			if (end == OBD_OBJECT_EOF)
 				info->oti_fn_index = CL_PAGE_EOF;
-			cl_lock_put(env, tmp);
+			LDLM_LOCK_PUT(tmp);
 		} else if (cl_page_own(env, io, page) == 0) {
 			/* discard the page */
 			cl_page_discard(env, io, page);
@@ -3125,11 +3147,8 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
 		      struct osc_page *ops, void *cbdata)
 {
 	struct osc_thread_info *info = osc_env_info(env);
-	struct cl_lock *lock = cbdata;
 	struct cl_page *page = ops->ops_cl.cpl_page;
 
-	LASSERT(lock->cll_descr.cld_mode >= CLM_WRITE);
-
 	/* page is top page. */
 	info->oti_next_index = osc_index(ops) + 1;
 	if (cl_page_own(env, io, page) == 0) {
@@ -3154,30 +3173,27 @@ static int discard_cb(const struct lu_env *env, struct cl_io *io,
  * If error happens on any step, the process continues anyway (the reasoning
  * behind this being that lock cancellation cannot be delayed indefinitely).
  */
-int osc_lock_discard_pages(const struct lu_env *env, struct osc_lock *ols)
+int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
+			   pgoff_t start, pgoff_t end, enum cl_lock_mode mode)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct cl_io *io = &info->oti_io;
-	struct cl_object *osc = ols->ols_cl.cls_obj;
-	struct cl_lock *lock = ols->ols_cl.cls_lock;
-	struct cl_lock_descr *descr = &lock->cll_descr;
 	osc_page_gang_cbt cb;
 	int res;
 	int result;
 
-	io->ci_obj = cl_object_top(osc);
+	io->ci_obj = cl_object_top(osc2cl(osc));
 	io->ci_ignore_layout = 1;
 	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (result != 0)
 		goto out;
 
-	cb = descr->cld_mode == CLM_READ ? check_and_discard_cb : discard_cb;
-	info->oti_fn_index = info->oti_next_index = descr->cld_start;
+	cb = mode == CLM_READ ? check_and_discard_cb : discard_cb;
+	info->oti_fn_index = info->oti_next_index = start;
 	do {
-		res = osc_page_gang_lookup(env, io, cl2osc(osc),
-					   info->oti_next_index, descr->cld_end,
-					   cb, (void *)lock);
-		if (info->oti_next_index > descr->cld_end)
+		res = osc_page_gang_lookup(env, io, osc,
+					   info->oti_next_index, end, cb, osc);
+		if (info->oti_next_index > end)
 			break;
 
 		if (res == CLP_GANG_RESCHED)
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index bb34b53a..c7a69e4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -68,6 +68,9 @@ struct osc_io {
 	struct cl_io_slice oi_cl;
 	/** true if this io is lockless. */
 	int		oi_lockless;
+	/** how many LRU pages are reserved for this IO */
+	int oi_lru_reserved;
+
 	/** active extents, we know how many bytes is going to be written,
 	 * so having an active extent will prevent it from being fragmented
 	 */
@@ -77,8 +80,8 @@ struct osc_io {
 	 */
 	struct osc_extent *oi_trunc;
 
-	int oi_lru_reserved;
-
+	/** write osc_lock for this IO, used by osc_extent_find(). */
+	struct osc_lock   *oi_write_osclock;
 	struct obd_info    oi_info;
 	struct obdo	oi_oa;
 	struct osc_async_cbargs {
@@ -117,6 +120,7 @@ struct osc_thread_info {
 	 */
 	pgoff_t			oti_next_index;
 	pgoff_t			oti_fn_index; /* first non-overlapped index */
+	struct cl_sync_io	oti_anchor;
 };
 
 struct osc_object {
@@ -173,6 +177,10 @@ struct osc_object {
 	struct radix_tree_root	oo_tree;
 	spinlock_t		oo_tree_lock;
 	unsigned long		oo_npages;
+
+	/* Protect osc_lock this osc_object has */
+	spinlock_t		oo_ol_spin;
+	struct list_head	oo_ol_list;
 };
 
 static inline void osc_object_lock(struct osc_object *obj)
@@ -212,8 +220,6 @@ enum osc_lock_state {
 	OLS_ENQUEUED,
 	OLS_UPCALL_RECEIVED,
 	OLS_GRANTED,
-	OLS_RELEASED,
-	OLS_BLOCKED,
 	OLS_CANCELLED
 };
 
@@ -222,10 +228,8 @@ enum osc_lock_state {
  *
  * Interaction with DLM.
  *
- * CLIO enqueues all DLM locks through ptlrpcd (that is, in "async" mode).
- *
  * Once receive upcall is invoked, osc_lock remembers a handle of DLM lock in
- * osc_lock::ols_handle and a pointer to that lock in osc_lock::ols_lock.
+ * osc_lock::ols_handle and a pointer to that lock in osc_lock::ols_dlmlock.
  *
  * This pointer is protected through a reference, acquired by
  * osc_lock_upcall0(). Also, an additional reference is acquired by
@@ -263,16 +267,27 @@ enum osc_lock_state {
  */
 struct osc_lock {
 	struct cl_lock_slice     ols_cl;
+	/** Internal lock to protect states, etc. */
+	spinlock_t		ols_lock;
+	/** Owner sleeps on this channel for state change */
+	struct cl_sync_io	*ols_owner;
+	/** waiting list for this lock to be cancelled */
+	struct list_head	ols_waiting_list;
+	/** wait entry of ols_waiting_list */
+	struct list_head	ols_wait_entry;
+	/** list entry for osc_object::oo_ol_list */
+	struct list_head	ols_nextlock_oscobj;
+
 	/** underlying DLM lock */
-	struct ldlm_lock	*ols_lock;
-	/** lock value block */
-	struct ost_lvb	   ols_lvb;
+	struct ldlm_lock	*ols_dlmlock;
 	/** DLM flags with which osc_lock::ols_lock was enqueued */
 	__u64		    ols_flags;
 	/** osc_lock::ols_lock handle */
 	struct lustre_handle     ols_handle;
 	struct ldlm_enqueue_info ols_einfo;
 	enum osc_lock_state      ols_state;
+	/** lock value block */
+	struct ost_lvb		ols_lvb;
 
 	/**
 	 * true, if ldlm_lock_addref() was called against
@@ -303,16 +318,6 @@ struct osc_lock {
 	 */
 				 ols_locklessable:1,
 	/**
-	 * set by osc_lock_use() to wait until blocking AST enters into
-	 * osc_ldlm_blocking_ast0(), so that cl_lock mutex can be used for
-	 * further synchronization.
-	 */
-				 ols_ast_wait:1,
-	/**
-	 * If the data of this lock has been flushed to server side.
-	 */
-				 ols_flush:1,
-	/**
 	 * if set, the osc_lock is a glimpse lock. For glimpse locks, we treat
 	 * the EVAVAIL error as tolerable, this will make upper logic happy
 	 * to wait all glimpse locks to each OSTs to be completed.
@@ -325,15 +330,6 @@ struct osc_lock {
 	 * For async glimpse lock.
 	 */
 				 ols_agl:1;
-	/**
-	 * IO that owns this lock. This field is used for a dead-lock
-	 * avoidance by osc_lock_enqueue_wait().
-	 *
-	 * XXX: unfortunately, the owner of a osc_lock is not unique,
-	 * the lock may have multiple users, if the lock is granted and
-	 * then matched.
-	 */
-	struct osc_io	   *ols_owner;
 };
 
 /**
@@ -627,6 +623,8 @@ struct osc_extent {
 	unsigned int       oe_intree:1,
 	/** 0 is write, 1 is read */
 			   oe_rw:1,
+	/** sync extent, queued by osc_queue_sync_pages() */
+				oe_sync:1,
 			   oe_srvlock:1,
 			   oe_memalloc:1,
 	/** an ACTIVE extent is going to be truncated, so when this extent
@@ -675,7 +673,7 @@ struct osc_extent {
 	 */
 	wait_queue_head_t	oe_waitq;
 	/** lock covering this extent */
-	struct cl_lock    *oe_osclock;
+	struct ldlm_lock	*oe_dlmlock;
 	/** terminator of this extent. Must be true if this extent is in IO. */
 	struct task_struct	*oe_owner;
 	/** return value of writeback. If somebody is waiting for this extent,
@@ -690,14 +688,14 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 		      int sent, int rc);
 void osc_extent_release(const struct lu_env *env, struct osc_extent *ext);
 
-int osc_lock_discard_pages(const struct lu_env *env, struct osc_lock *lock);
+int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
+			   pgoff_t start, pgoff_t end, enum cl_lock_mode mode);
 
 typedef int (*osc_page_gang_cbt)(const struct lu_env *, struct cl_io *,
 				 struct osc_page *, void *);
 int osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 			 struct osc_object *osc, pgoff_t start, pgoff_t end,
 			 osc_page_gang_cbt cb, void *cbdata);
-
 /** @} osc */
 
 #endif /* OSC_CL_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index b7fb01a..cf9f8b7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -108,12 +108,14 @@ void osc_update_next_shrink(struct client_obd *cli);
 
 extern struct ptlrpc_request_set *PTLRPCD_SET;
 
+typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
+				    int rc);
+
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     __u64 *flags, ldlm_policy_data_t *policy,
 		     struct ost_lvb *lvb, int kms_valid,
-		     obd_enqueue_update_f upcall,
+		     osc_enqueue_upcall_f upcall,
 		     void *cookie, struct ldlm_enqueue_info *einfo,
-		     struct lustre_handle *lockh,
 		     struct ptlrpc_request_set *rqset, int async, int agl);
 int osc_cancel_base(struct lustre_handle *lockh, __u32 mode);
 
@@ -140,7 +142,6 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		   int target, bool force);
 int osc_lru_reclaim(struct client_obd *cli);
 
-extern spinlock_t osc_ast_guard;
 unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
@@ -199,5 +200,8 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 		   struct obd_quotactl *oqctl);
 int osc_quota_poll_check(struct obd_export *exp, struct if_quotacheck *qchk);
+struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
+				       struct osc_object *obj, pgoff_t index,
+				       int pending, int canceling);
 
 #endif /* OSC_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 1ae8a22..cf7743d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -354,6 +354,7 @@ static void osc_io_rw_iter_fini(const struct lu_env *env,
 		atomic_add(oio->oi_lru_reserved, cli->cl_lru_left);
 		oio->oi_lru_reserved = 0;
 	}
+	oio->oi_write_osclock = NULL;
 }
 
 static int osc_io_fault_start(const struct lu_env *env,
@@ -751,8 +752,7 @@ static void osc_req_attr_set(const struct lu_env *env,
 	struct lov_oinfo *oinfo;
 	struct cl_req *clerq;
 	struct cl_page *apage; /* _some_ page in @clerq */
-	struct cl_lock *lock;  /* _some_ lock protecting @apage */
-	struct osc_lock *olck;
+	struct ldlm_lock *lock;  /* _some_ lock protecting @apage */
 	struct osc_page *opg;
 	struct obdo *oa;
 	struct ost_lvb *lvb;
@@ -782,38 +782,37 @@ static void osc_req_attr_set(const struct lu_env *env,
 		oa->o_valid |= OBD_MD_FLID;
 	}
 	if (flags & OBD_MD_FLHANDLE) {
-		struct cl_object *subobj;
 
 		clerq = slice->crs_req;
 		LASSERT(!list_empty(&clerq->crq_pages));
 		apage = container_of(clerq->crq_pages.next,
 				     struct cl_page, cp_flight);
 		opg = osc_cl_page_osc(apage, NULL);
-		subobj = opg->ops_cl.cpl_obj;
-		lock = cl_lock_at_pgoff(env, subobj, osc_index(opg),
-					NULL, 1, 1);
-		if (!lock) {
-			struct cl_object_header *head;
-			struct cl_lock *scan;
-
-			head = cl_object_header(subobj);
-			list_for_each_entry(scan, &head->coh_locks, cll_linkage)
-				CL_LOCK_DEBUG(D_ERROR, env, scan,
-					      "no cover page!\n");
-			CL_PAGE_DEBUG(D_ERROR, env, apage,
-				      "dump uncover page!\n");
+		lock = osc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
+					    1, 1);
+		if (!lock && !opg->ops_srvlock) {
+			struct ldlm_resource *res;
+			struct ldlm_res_id *resname;
+
+			CL_PAGE_DEBUG(D_ERROR, env, apage, "uncovered page!\n");
+
+			resname = &osc_env_info(env)->oti_resname;
+			ostid_build_res_name(&oinfo->loi_oi, resname);
+			res = ldlm_resource_get(
+				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
+				NULL, resname, LDLM_EXTENT, 0);
+			ldlm_resource_dump(D_ERROR, res);
+
 			dump_stack();
 			LBUG();
 		}
 
-		olck = osc_lock_at(lock);
-		LASSERT(ergo(opg->ops_srvlock, !olck->ols_lock));
 		/* check for lockless io. */
-		if (olck->ols_lock) {
-			oa->o_handle = olck->ols_lock->l_remote_handle;
+		if (lock) {
+			oa->o_handle = lock->l_remote_handle;
 			oa->o_valid |= OBD_MD_FLHANDLE;
+			LDLM_LOCK_PUT(lock);
 		}
-		cl_lock_put(env, lock);
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 978b6ea..68c5013 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -61,7 +61,6 @@ static const struct cl_lock_operations osc_lock_ops;
 static const struct cl_lock_operations osc_lock_lockless_ops;
 static void osc_lock_to_lockless(const struct lu_env *env,
 				 struct osc_lock *ols, int force);
-static int osc_lock_has_pages(struct osc_lock *olck);
 
 int osc_lock_is_lockless(const struct osc_lock *olck)
 {
@@ -89,11 +88,11 @@ static struct ldlm_lock *osc_handle_ptr(struct lustre_handle *handle)
 static int osc_lock_invariant(struct osc_lock *ols)
 {
 	struct ldlm_lock *lock = osc_handle_ptr(&ols->ols_handle);
-	struct ldlm_lock *olock = ols->ols_lock;
+	struct ldlm_lock *olock = ols->ols_dlmlock;
 	int handle_used = lustre_handle_is_used(&ols->ols_handle);
 
 	if (ergo(osc_lock_is_lockless(ols),
-		 ols->ols_locklessable && !ols->ols_lock))
+		 ols->ols_locklessable && !ols->ols_dlmlock))
 		return 1;
 
 	/*
@@ -110,7 +109,7 @@ static int osc_lock_invariant(struct osc_lock *ols)
 		  ergo(!lock, !olock)))
 		return 0;
 	/*
-	 * Check that ->ols_handle and ->ols_lock are consistent, but
+	 * Check that ->ols_handle and ->ols_dlmlock are consistent, but
 	 * take into account that they are set at the different time.
 	 */
 	if (!ergo(ols->ols_state == OLS_CANCELLED,
@@ -137,115 +136,13 @@ static int osc_lock_invariant(struct osc_lock *ols)
  *
  */
 
-/**
- * Breaks a link between osc_lock and dlm_lock.
- */
-static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
-{
-	struct ldlm_lock *dlmlock;
-
-	spin_lock(&osc_ast_guard);
-	dlmlock = olck->ols_lock;
-	if (!dlmlock) {
-		spin_unlock(&osc_ast_guard);
-		return;
-	}
-
-	olck->ols_lock = NULL;
-	/* wb(); --- for all who checks (ols->ols_lock != NULL) before
-	 * call to osc_lock_detach()
-	 */
-	dlmlock->l_ast_data = NULL;
-	olck->ols_handle.cookie = 0ULL;
-	spin_unlock(&osc_ast_guard);
-
-	lock_res_and_lock(dlmlock);
-	if (dlmlock->l_granted_mode == dlmlock->l_req_mode) {
-		struct cl_object *obj = olck->ols_cl.cls_obj;
-		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
-		__u64 old_kms;
-
-		cl_object_attr_lock(obj);
-		/* Must get the value under the lock to avoid possible races. */
-		old_kms = cl2osc(obj)->oo_oinfo->loi_kms;
-		/* Update the kms. Need to loop all granted locks.
-		 * Not a problem for the client
-		 */
-		attr->cat_kms = ldlm_extent_shift_kms(dlmlock, old_kms);
-
-		cl_object_attr_set(env, obj, attr, CAT_KMS);
-		cl_object_attr_unlock(obj);
-	}
-	unlock_res_and_lock(dlmlock);
-
-	/* release a reference taken in osc_lock_upcall0(). */
-	LASSERT(olck->ols_has_ref);
-	lu_ref_del(&dlmlock->l_reference, "osc_lock", olck);
-	LDLM_LOCK_RELEASE(dlmlock);
-	olck->ols_has_ref = 0;
-}
-
-static int osc_lock_unhold(struct osc_lock *ols)
-{
-	int result = 0;
-
-	if (ols->ols_hold) {
-		ols->ols_hold = 0;
-		result = osc_cancel_base(&ols->ols_handle,
-					 ols->ols_einfo.ei_mode);
-	}
-	return result;
-}
-
-static int osc_lock_unuse(const struct lu_env *env,
-			  const struct cl_lock_slice *slice)
-{
-	struct osc_lock *ols = cl2osc_lock(slice);
-
-	LINVRNT(osc_lock_invariant(ols));
-
-	switch (ols->ols_state) {
-	case OLS_NEW:
-		LASSERT(!ols->ols_hold);
-		LASSERT(ols->ols_agl);
-		return 0;
-	case OLS_UPCALL_RECEIVED:
-		osc_lock_unhold(ols);
-	case OLS_ENQUEUED:
-		LASSERT(!ols->ols_hold);
-		osc_lock_detach(env, ols);
-		ols->ols_state = OLS_NEW;
-		return 0;
-	case OLS_GRANTED:
-		LASSERT(!ols->ols_glimpse);
-		LASSERT(ols->ols_hold);
-		/*
-		 * Move lock into OLS_RELEASED state before calling
-		 * osc_cancel_base() so that possible synchronous cancellation
-		 * sees that lock is released.
-		 */
-		ols->ols_state = OLS_RELEASED;
-		return osc_lock_unhold(ols);
-	default:
-		CERROR("Impossible state: %d\n", ols->ols_state);
-		LBUG();
-	}
-}
-
 static void osc_lock_fini(const struct lu_env *env,
 			  struct cl_lock_slice *slice)
 {
 	struct osc_lock *ols = cl2osc_lock(slice);
 
 	LINVRNT(osc_lock_invariant(ols));
-	/*
-	 * ->ols_hold can still be true at this point if, for example, a
-	 * thread that requested a lock was killed (and released a reference
-	 * to the lock), before reply from a server was received. In this case
-	 * lock is destroyed immediately after upcall.
-	 */
-	osc_lock_unhold(ols);
-	LASSERT(!ols->ols_lock);
+	LASSERT(!ols->ols_dlmlock);
 
 	kmem_cache_free(osc_lock_kmem, ols);
 }
@@ -272,55 +169,12 @@ static __u64 osc_enq2ldlm_flags(__u32 enqflags)
 		result |= LDLM_FL_HAS_INTENT;
 	if (enqflags & CEF_DISCARD_DATA)
 		result |= LDLM_FL_AST_DISCARD_DATA;
+	if (enqflags & CEF_PEEK)
+		result |= LDLM_FL_TEST_LOCK;
 	return result;
 }
 
 /**
- * Global spin-lock protecting consistency of ldlm_lock::l_ast_data
- * pointers. Initialized in osc_init().
- */
-spinlock_t osc_ast_guard;
-
-static struct osc_lock *osc_ast_data_get(struct ldlm_lock *dlm_lock)
-{
-	struct osc_lock *olck;
-
-	lock_res_and_lock(dlm_lock);
-	spin_lock(&osc_ast_guard);
-	olck = dlm_lock->l_ast_data;
-	if (olck) {
-		struct cl_lock *lock = olck->ols_cl.cls_lock;
-		/*
-		 * If osc_lock holds a reference on ldlm lock, return it even
-		 * when cl_lock is in CLS_FREEING state. This way
-		 *
-		 *	 osc_ast_data_get(dlmlock) == NULL
-		 *
-		 * guarantees that all osc references on dlmlock were
-		 * released. osc_dlm_blocking_ast0() relies on that.
-		 */
-		if (lock->cll_state < CLS_FREEING || olck->ols_has_ref) {
-			cl_lock_get_trust(lock);
-			lu_ref_add_atomic(&lock->cll_reference,
-					  "ast", current);
-		} else
-			olck = NULL;
-	}
-	spin_unlock(&osc_ast_guard);
-	unlock_res_and_lock(dlm_lock);
-	return olck;
-}
-
-static void osc_ast_data_put(const struct lu_env *env, struct osc_lock *olck)
-{
-	struct cl_lock *lock;
-
-	lock = olck->ols_cl.cls_lock;
-	lu_ref_del(&lock->cll_reference, "ast", current);
-	cl_lock_put(env, lock);
-}
-
-/**
  * Updates object attributes from a lock value block (lvb) received together
  * with the DLM lock reply from the server. Copy of osc_update_enqueue()
  * logic.
@@ -330,35 +184,30 @@ static void osc_ast_data_put(const struct lu_env *env, struct osc_lock *olck)
  *
  * Called under lock and resource spin-locks.
  */
-static void osc_lock_lvb_update(const struct lu_env *env, struct osc_lock *olck,
-				int rc)
+static void osc_lock_lvb_update(const struct lu_env *env,
+				struct osc_object *osc,
+				struct ldlm_lock *dlmlock,
+				struct ost_lvb *lvb)
 {
-	struct ost_lvb *lvb;
-	struct cl_object *obj;
-	struct lov_oinfo *oinfo;
-	struct cl_attr *attr;
+	struct cl_object *obj = osc2cl(osc);
+	struct lov_oinfo *oinfo = osc->oo_oinfo;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	unsigned valid;
 
-	if (!(olck->ols_flags & LDLM_FL_LVB_READY))
-		return;
-
-	lvb = &olck->ols_lvb;
-	obj = olck->ols_cl.cls_obj;
-	oinfo = cl2osc(obj)->oo_oinfo;
-	attr = &osc_env_info(env)->oti_attr;
 	valid = CAT_BLOCKS | CAT_ATIME | CAT_CTIME | CAT_MTIME | CAT_SIZE;
+	if (!lvb)
+		lvb = dlmlock->l_lvb_data;
+
 	cl_lvb2attr(attr, lvb);
 
 	cl_object_attr_lock(obj);
-	if (rc == 0) {
-		struct ldlm_lock *dlmlock;
+	if (dlmlock) {
 		__u64 size;
 
-		dlmlock = olck->ols_lock;
-
-		/* re-grab LVB from a dlm lock under DLM spin-locks. */
-		*lvb = *(struct ost_lvb *)dlmlock->l_lvb_data;
+		check_res_locked(dlmlock->l_resource);
+		LASSERT(lvb == dlmlock->l_lvb_data);
 		size = lvb->lvb_size;
+
 		/* Extend KMS up to the end of this lock and no further
 		 * A lock on [x,y] means a KMS of up to y + 1 bytes!
 		 */
@@ -375,102 +224,67 @@ static void osc_lock_lvb_update(const struct lu_env *env, struct osc_lock *olck,
 				   dlmlock->l_policy_data.l_extent.end);
 		}
 		ldlm_lock_allow_match_locked(dlmlock);
-	} else if (rc == -ENAVAIL && olck->ols_glimpse) {
-		CDEBUG(D_INODE, "glimpsed, setting rss=%llu; leaving kms=%llu\n",
-		       lvb->lvb_size, oinfo->loi_kms);
-	} else
-		valid = 0;
-
-	if (valid != 0)
-		cl_object_attr_set(env, obj, attr, valid);
+	}
 
+	cl_object_attr_set(env, obj, attr, valid);
 	cl_object_attr_unlock(obj);
 }
 
-/**
- * Called when a lock is granted, from an upcall (when server returned a
- * granted lock), or from completion AST, when server returned a blocked lock.
- *
- * Called under lock and resource spin-locks, that are released temporarily
- * here.
- */
-static void osc_lock_granted(const struct lu_env *env, struct osc_lock *olck,
-			     struct ldlm_lock *dlmlock, int rc)
+static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
+			     struct lustre_handle *lockh, bool lvb_update)
 {
-	struct ldlm_extent *ext;
-	struct cl_lock *lock;
-	struct cl_lock_descr *descr;
+	struct ldlm_lock *dlmlock;
 
-	LASSERT(dlmlock->l_granted_mode == dlmlock->l_req_mode);
+	dlmlock = ldlm_handle2lock_long(lockh, 0);
+	LASSERT(dlmlock);
+
+	/* lock reference taken by ldlm_handle2lock_long() is
+	 * owned by osc_lock and released in osc_lock_detach()
+	 */
+	lu_ref_add(&dlmlock->l_reference, "osc_lock", oscl);
+	oscl->ols_has_ref = 1;
 
-	if (olck->ols_state < OLS_GRANTED) {
-		lock = olck->ols_cl.cls_lock;
-		ext = &dlmlock->l_policy_data.l_extent;
-		descr = &osc_env_info(env)->oti_descr;
-		descr->cld_obj = lock->cll_descr.cld_obj;
+	LASSERT(!oscl->ols_dlmlock);
+	oscl->ols_dlmlock = dlmlock;
 
-		/* XXX check that ->l_granted_mode is valid. */
-		descr->cld_mode = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
-		descr->cld_start = cl_index(descr->cld_obj, ext->start);
-		descr->cld_end = cl_index(descr->cld_obj, ext->end);
-		descr->cld_gid = ext->gid;
-		/*
-		 * tell upper layers the extent of the lock that was actually
-		 * granted
-		 */
-		olck->ols_state = OLS_GRANTED;
-		osc_lock_lvb_update(env, olck, rc);
-
-		/* release DLM spin-locks to allow cl_lock_{modify,signal}()
-		 * to take a semaphore on a parent lock. This is safe, because
-		 * spin-locks are needed to protect consistency of
-		 * dlmlock->l_*_mode and LVB, and we have finished processing
-		 * them.
+	/* This may be a matched lock for glimpse request, do not hold
+	 * lock reference in that case.
+	 */
+	if (!oscl->ols_glimpse) {
+		/* hold a refc for non glimpse lock which will
+		 * be released in osc_lock_cancel()
 		 */
-		unlock_res_and_lock(dlmlock);
-		cl_lock_modify(env, lock, descr);
-		cl_lock_signal(env, lock);
-		LINVRNT(osc_lock_invariant(olck));
-		lock_res_and_lock(dlmlock);
+		lustre_handle_copy(&oscl->ols_handle, lockh);
+		ldlm_lock_addref(lockh, oscl->ols_einfo.ei_mode);
+		oscl->ols_hold = 1;
 	}
-}
-
-static void osc_lock_upcall0(const struct lu_env *env, struct osc_lock *olck)
-
-{
-	struct ldlm_lock *dlmlock;
-
-	dlmlock = ldlm_handle2lock_long(&olck->ols_handle, 0);
-	LASSERT(dlmlock);
 
+	/* Lock must have been granted. */
 	lock_res_and_lock(dlmlock);
-	spin_lock(&osc_ast_guard);
-	LASSERT(dlmlock->l_ast_data == olck);
-	LASSERT(!olck->ols_lock);
-	olck->ols_lock = dlmlock;
-	spin_unlock(&osc_ast_guard);
+	if (dlmlock->l_granted_mode == dlmlock->l_req_mode) {
+		struct ldlm_extent *ext = &dlmlock->l_policy_data.l_extent;
+		struct cl_lock_descr *descr = &oscl->ols_cl.cls_lock->cll_descr;
 
-	/*
-	 * Lock might be not yet granted. In this case, completion ast
-	 * (osc_ldlm_completion_ast()) comes later and finishes lock
-	 * granting.
-	 */
-	if (dlmlock->l_granted_mode == dlmlock->l_req_mode)
-		osc_lock_granted(env, olck, dlmlock, 0);
-	unlock_res_and_lock(dlmlock);
+		/* extend the lock extent, otherwise it will have problem when
+		 * we decide whether to grant a lockless lock.
+		 */
+		descr->cld_mode = osc_ldlm2cl_lock(dlmlock->l_granted_mode);
+		descr->cld_start = cl_index(descr->cld_obj, ext->start);
+		descr->cld_end = cl_index(descr->cld_obj, ext->end);
+		descr->cld_gid = ext->gid;
 
-	/*
-	 * osc_enqueue_interpret() decrefs asynchronous locks, counter
-	 * this.
-	 */
-	ldlm_lock_addref(&olck->ols_handle, olck->ols_einfo.ei_mode);
-	olck->ols_hold = 1;
+		/* no lvb update for matched lock */
+		if (lvb_update) {
+			LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
+			osc_lock_lvb_update(env, cl2osc(oscl->ols_cl.cls_obj),
+					    dlmlock, NULL);
+		}
+		LINVRNT(osc_lock_invariant(oscl));
+	}
+	unlock_res_and_lock(dlmlock);
 
-	/* lock reference taken by ldlm_handle2lock_long() is owned by
-	 * osc_lock and released in osc_lock_detach()
-	 */
-	lu_ref_add(&dlmlock->l_reference, "osc_lock", olck);
-	olck->ols_has_ref = 1;
+	LASSERT(oscl->ols_state != OLS_GRANTED);
+	oscl->ols_state = OLS_GRANTED;
 }
 
 /**
@@ -478,143 +292,124 @@ static void osc_lock_upcall0(const struct lu_env *env, struct osc_lock *olck)
  * received from a server, or after osc_enqueue_base() matched a local DLM
  * lock.
  */
-static int osc_lock_upcall(void *cookie, int errcode)
+static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
+			   int errcode)
 {
-	struct osc_lock	*olck = cookie;
-	struct cl_lock_slice *slice = &olck->ols_cl;
-	struct cl_lock *lock = slice->cls_lock;
+	struct osc_lock *oscl = cookie;
+	struct cl_lock_slice *slice = &oscl->ols_cl;
 	struct lu_env *env;
 	struct cl_env_nest nest;
+	int rc;
 
 	env = cl_env_nested_get(&nest);
-	if (!IS_ERR(env)) {
-		int rc;
-
-		cl_lock_mutex_get(env, lock);
+	/* should never happen, similar to osc_ldlm_blocking_ast(). */
+	LASSERT(!IS_ERR(env));
+
+	rc = ldlm_error2errno(errcode);
+	if (oscl->ols_state == OLS_ENQUEUED) {
+		oscl->ols_state = OLS_UPCALL_RECEIVED;
+	} else if (oscl->ols_state == OLS_CANCELLED) {
+		rc = -EIO;
+	} else {
+		CERROR("Impossible state: %d\n", oscl->ols_state);
+		LBUG();
+	}
 
-		LASSERT(lock->cll_state >= CLS_QUEUING);
-		if (olck->ols_state == OLS_ENQUEUED) {
-			olck->ols_state = OLS_UPCALL_RECEIVED;
-			rc = ldlm_error2errno(errcode);
-		} else if (olck->ols_state == OLS_CANCELLED) {
-			rc = -EIO;
-		} else {
-			CERROR("Impossible state: %d\n", olck->ols_state);
-			LBUG();
-		}
-		if (rc) {
-			struct ldlm_lock *dlmlock;
-
-			dlmlock = ldlm_handle2lock(&olck->ols_handle);
-			if (dlmlock) {
-				lock_res_and_lock(dlmlock);
-				spin_lock(&osc_ast_guard);
-				LASSERT(!olck->ols_lock);
-				dlmlock->l_ast_data = NULL;
-				olck->ols_handle.cookie = 0ULL;
-				spin_unlock(&osc_ast_guard);
-				ldlm_lock_fail_match_locked(dlmlock);
-				unlock_res_and_lock(dlmlock);
-				LDLM_LOCK_PUT(dlmlock);
-			}
-		} else {
-			if (olck->ols_glimpse)
-				olck->ols_glimpse = 0;
-			osc_lock_upcall0(env, olck);
-		}
+	if (rc == 0)
+		osc_lock_granted(env, oscl, lockh, errcode == ELDLM_OK);
 
-		/* Error handling, some errors are tolerable. */
-		if (olck->ols_locklessable && rc == -EUSERS) {
-			/* This is a tolerable error, turn this lock into
-			 * lockless lock.
-			 */
-			osc_object_set_contended(cl2osc(slice->cls_obj));
-			LASSERT(slice->cls_ops == &osc_lock_ops);
+	/* Error handling, some errors are tolerable. */
+	if (oscl->ols_locklessable && rc == -EUSERS) {
+		/* This is a tolerable error, turn this lock into
+		 * lockless lock.
+		 */
+		osc_object_set_contended(cl2osc(slice->cls_obj));
+		LASSERT(slice->cls_ops == &osc_lock_ops);
+
+		/* Change this lock to ldlmlock-less lock. */
+		osc_lock_to_lockless(env, oscl, 1);
+		oscl->ols_state = OLS_GRANTED;
+		rc = 0;
+	} else if (oscl->ols_glimpse && rc == -ENAVAIL) {
+		LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
+		osc_lock_lvb_update(env, cl2osc(slice->cls_obj),
+				    NULL, &oscl->ols_lvb);
+		/* Hide the error. */
+		rc = 0;
+	}
 
-			/* Change this lock to ldlmlock-less lock. */
-			osc_lock_to_lockless(env, olck, 1);
-			olck->ols_state = OLS_GRANTED;
-			rc = 0;
-		} else if (olck->ols_glimpse && rc == -ENAVAIL) {
-			osc_lock_lvb_update(env, olck, rc);
-			cl_lock_delete(env, lock);
-			/* Hide the error. */
-			rc = 0;
-		}
+	if (oscl->ols_owner)
+		cl_sync_io_note(env, oscl->ols_owner, rc);
+	cl_env_nested_put(&nest, env);
 
-		if (rc == 0) {
-			/* For AGL case, the RPC sponsor may exits the cl_lock
-			*  processing without wait() called before related OSC
-			*  lock upcall(). So update the lock status according
-			*  to the enqueue result inside AGL upcall().
-			*/
-			if (olck->ols_agl) {
-				lock->cll_flags |= CLF_FROM_UPCALL;
-				cl_wait_try(env, lock);
-				lock->cll_flags &= ~CLF_FROM_UPCALL;
-				if (!olck->ols_glimpse)
-					olck->ols_agl = 0;
-			}
-			cl_lock_signal(env, lock);
-			/* del user for lock upcall cookie */
-			cl_unuse_try(env, lock);
-		} else {
-			/* del user for lock upcall cookie */
-			cl_lock_user_del(env, lock);
-			cl_lock_error(env, lock, rc);
-		}
+	return rc;
+}
 
-		/* release cookie reference, acquired by osc_lock_enqueue() */
-		cl_lock_hold_release(env, lock, "upcall", lock);
-		cl_lock_mutex_put(env, lock);
+static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
+			       int errcode)
+{
+	struct osc_object *osc = cookie;
+	struct ldlm_lock *dlmlock;
+	struct lu_env *env;
+	struct cl_env_nest nest;
 
-		lu_ref_del(&lock->cll_reference, "upcall", lock);
-		/* This maybe the last reference, so must be called after
-		 * cl_lock_mutex_put().
-		 */
-		cl_lock_put(env, lock);
+	env = cl_env_nested_get(&nest);
+	LASSERT(!IS_ERR(env));
 
-		cl_env_nested_put(&nest, env);
-	} else {
-		/* should never happen, similar to osc_ldlm_blocking_ast(). */
-		LBUG();
+	if (errcode == ELDLM_LOCK_MATCHED) {
+		errcode = ELDLM_OK;
+		goto out;
 	}
-	return errcode;
+
+	if (errcode != ELDLM_OK)
+		goto out;
+
+	dlmlock = ldlm_handle2lock(lockh);
+	LASSERT(dlmlock);
+
+	lock_res_and_lock(dlmlock);
+	LASSERT(dlmlock->l_granted_mode == dlmlock->l_req_mode);
+
+	/* there is no osc_lock associated with AGL lock */
+	osc_lock_lvb_update(env, osc, dlmlock, NULL);
+
+	unlock_res_and_lock(dlmlock);
+	LDLM_LOCK_PUT(dlmlock);
+
+out:
+	cl_object_put(env, osc2cl(osc));
+	cl_env_nested_put(&nest, env);
+	return ldlm_error2errno(errcode);
 }
 
-/**
- * Core of osc_dlm_blocking_ast() logic.
- */
-static void osc_lock_blocking(const struct lu_env *env,
-			      struct ldlm_lock *dlmlock,
-			      struct osc_lock *olck, int blocking)
+static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
+			  enum cl_lock_mode mode, int discard)
 {
-	struct cl_lock *lock = olck->ols_cl.cls_lock;
+	struct lu_env *env;
+	struct cl_env_nest nest;
+	int rc = 0;
+	int rc2 = 0;
 
-	LASSERT(olck->ols_lock == dlmlock);
-	CLASSERT(OLS_BLOCKED < OLS_CANCELLED);
-	LASSERT(!osc_lock_is_lockless(olck));
+	env = cl_env_nested_get(&nest);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	if (mode == CLM_WRITE) {
+		rc = osc_cache_writeback_range(env, obj, start, end, 1,
+					       discard);
+		CDEBUG(D_CACHE, "object %p: [%lu -> %lu] %d pages were %s.\n",
+		       obj, start, end, rc,
+		       discard ? "discarded" : "written back");
+		if (rc > 0)
+			rc = 0;
+	}
 
-	/*
-	 * Lock might be still addref-ed here, if e.g., blocking ast
-	 * is sent for a failed lock.
-	 */
-	osc_lock_unhold(olck);
+	rc2 = osc_lock_discard_pages(env, obj, start, end, mode);
+	if (rc == 0 && rc2 < 0)
+		rc = rc2;
 
-	if (blocking && olck->ols_state < OLS_BLOCKED)
-		/*
-		 * Move osc_lock into OLS_BLOCKED before canceling the lock,
-		 * because it recursively re-enters osc_lock_blocking(), with
-		 * the state set to OLS_CANCELLED.
-		 */
-		olck->ols_state = OLS_BLOCKED;
-	/*
-	 * cancel and destroy lock at least once no matter how blocking ast is
-	 * entered (see comment above osc_ldlm_blocking_ast() for use
-	 * cases). cl_lock_cancel() and cl_lock_delete() are idempotent.
-	 */
-	cl_lock_cancel(env, lock);
-	cl_lock_delete(env, lock);
+	cl_env_nested_put(&nest, env);
+	return rc;
 }
 
 /**
@@ -625,65 +420,63 @@ static int osc_dlm_blocking_ast0(const struct lu_env *env,
 				 struct ldlm_lock *dlmlock,
 				 void *data, int flag)
 {
-	struct osc_lock *olck;
-	struct cl_lock *lock;
-	int result;
-	int cancel;
-
-	LASSERT(flag == LDLM_CB_BLOCKING || flag == LDLM_CB_CANCELING);
-
-	cancel = 0;
-	olck = osc_ast_data_get(dlmlock);
-	if (olck) {
-		lock = olck->ols_cl.cls_lock;
-		cl_lock_mutex_get(env, lock);
-		LINVRNT(osc_lock_invariant(olck));
-		if (olck->ols_ast_wait) {
-			/* wake up osc_lock_use() */
-			cl_lock_signal(env, lock);
-			olck->ols_ast_wait = 0;
-		}
-		/*
-		 * Lock might have been canceled while this thread was
-		 * sleeping for lock mutex, but olck is pinned in memory.
-		 */
-		if (olck == dlmlock->l_ast_data) {
-			/*
-			 * NOTE: DLM sends blocking AST's for failed locks
-			 *       (that are still in pre-OLS_GRANTED state)
-			 *       too, and they have to be canceled otherwise
-			 *       DLM lock is never destroyed and stuck in
-			 *       the memory.
-			 *
-			 *       Alternatively, ldlm_cli_cancel() can be
-			 *       called here directly for osc_locks with
-			 *       ols_state < OLS_GRANTED to maintain an
-			 *       invariant that ->clo_cancel() is only called
-			 *       for locks that were granted.
-			 */
-			LASSERT(data == olck);
-			osc_lock_blocking(env, dlmlock,
-					  olck, flag == LDLM_CB_BLOCKING);
-		} else
-			cancel = 1;
-		cl_lock_mutex_put(env, lock);
-		osc_ast_data_put(env, olck);
-	} else
-		/*
-		 * DLM lock exists, but there is no cl_lock attached to it.
-		 * This is a `normal' race. cl_object and its cl_lock's can be
-		 * removed by memory pressure, together with all pages.
+	struct cl_object *obj = NULL;
+	int result = 0;
+	int discard;
+	enum cl_lock_mode mode = CLM_READ;
+
+	LASSERT(flag == LDLM_CB_CANCELING);
+
+	lock_res_and_lock(dlmlock);
+	if (dlmlock->l_granted_mode != dlmlock->l_req_mode) {
+		dlmlock->l_ast_data = NULL;
+		unlock_res_and_lock(dlmlock);
+		return 0;
+	}
+
+	discard = ldlm_is_discard_data(dlmlock);
+	if (dlmlock->l_granted_mode & (LCK_PW | LCK_GROUP))
+		mode = CLM_WRITE;
+
+	if (dlmlock->l_ast_data) {
+		obj = osc2cl(dlmlock->l_ast_data);
+		dlmlock->l_ast_data = NULL;
+
+		cl_object_get(obj);
+	}
+
+	unlock_res_and_lock(dlmlock);
+
+	/* if l_ast_data is NULL, the dlmlock was enqueued by AGL or
+	 * the object has been destroyed.
+	 */
+	if (obj) {
+		struct ldlm_extent *extent = &dlmlock->l_policy_data.l_extent;
+		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+		__u64 old_kms;
+
+		/* Destroy pages covered by the extent of the DLM lock */
+		result = osc_lock_flush(cl2osc(obj),
+					cl_index(obj, extent->start),
+					cl_index(obj, extent->end),
+					mode, discard);
+
+		/* losing a lock, update kms */
+		lock_res_and_lock(dlmlock);
+		cl_object_attr_lock(obj);
+		/* Must get the value under the lock to avoid race. */
+		old_kms = cl2osc(obj)->oo_oinfo->loi_kms;
+		/* Update the kms. Need to loop all granted locks.
+		 * Not a problem for the client
 		 */
-		cancel = (flag == LDLM_CB_BLOCKING);
+		attr->cat_kms = ldlm_extent_shift_kms(dlmlock, old_kms);
 
-	if (cancel) {
-		struct lustre_handle *lockh;
+		cl_object_attr_set(env, obj, attr, CAT_KMS);
+		cl_object_attr_unlock(obj);
+		unlock_res_and_lock(dlmlock);
 
-		lockh = &osc_env_info(env)->oti_handle;
-		ldlm_lock2handle(dlmlock, lockh);
-		result = ldlm_cli_cancel(lockh, LCF_ASYNC);
-	} else
-		result = 0;
+		cl_object_put(env, obj);
+	}
 	return result;
 }
 
@@ -733,107 +526,52 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 				 struct ldlm_lock_desc *new, void *data,
 				 int flag)
 {
-	struct lu_env *env;
-	struct cl_env_nest nest;
-	int result;
+	int result = 0;
 
-	/*
-	 * This can be called in the context of outer IO, e.g.,
-	 *
-	 *     cl_enqueue()->...
-	 *       ->osc_enqueue_base()->...
-	 *	 ->ldlm_prep_elc_req()->...
-	 *	   ->ldlm_cancel_callback()->...
-	 *	     ->osc_ldlm_blocking_ast()
-	 *
-	 * new environment has to be created to not corrupt outer context.
-	 */
-	env = cl_env_nested_get(&nest);
-	if (!IS_ERR(env)) {
-		result = osc_dlm_blocking_ast0(env, dlmlock, data, flag);
-		cl_env_nested_put(&nest, env);
-	} else {
-		result = PTR_ERR(env);
-		/*
-		 * XXX This should never happen, as cl_lock is
-		 * stuck. Pre-allocated environment a la vvp_inode_fini_env
-		 * should be used.
-		 */
-		LBUG();
-	}
-	if (result != 0) {
+	switch (flag) {
+	case LDLM_CB_BLOCKING: {
+		struct lustre_handle lockh;
+
+		ldlm_lock2handle(dlmlock, &lockh);
+		result = ldlm_cli_cancel(&lockh, LCF_ASYNC);
 		if (result == -ENODATA)
 			result = 0;
-		else
-			CERROR("BAST failed: %d\n", result);
+		break;
 	}
-	return result;
-}
-
-static int osc_ldlm_completion_ast(struct ldlm_lock *dlmlock,
-				   __u64 flags, void *data)
-{
-	struct cl_env_nest nest;
-	struct lu_env *env;
-	struct osc_lock *olck;
-	struct cl_lock *lock;
-	int result;
-	int dlmrc;
+	case LDLM_CB_CANCELING: {
+		struct lu_env *env;
+		struct cl_env_nest nest;
 
-	/* first, do dlm part of the work */
-	dlmrc = ldlm_completion_ast_async(dlmlock, flags, data);
-	/* then, notify cl_lock */
-	env = cl_env_nested_get(&nest);
-	if (!IS_ERR(env)) {
-		olck = osc_ast_data_get(dlmlock);
-		if (olck) {
-			lock = olck->ols_cl.cls_lock;
-			cl_lock_mutex_get(env, lock);
-			/*
-			 * ldlm_handle_cp_callback() copied LVB from request
-			 * to lock->l_lvb_data, store it in osc_lock.
-			 */
-			LASSERT(dlmlock->l_lvb_data);
-			lock_res_and_lock(dlmlock);
-			olck->ols_lvb = *(struct ost_lvb *)dlmlock->l_lvb_data;
-			if (!olck->ols_lock) {
-				/*
-				 * upcall (osc_lock_upcall()) hasn't yet been
-				 * called. Do nothing now, upcall will bind
-				 * olck to dlmlock and signal the waiters.
-				 *
-				 * This maintains an invariant that osc_lock
-				 * and ldlm_lock are always bound when
-				 * osc_lock is in OLS_GRANTED state.
-				 */
-			} else if (dlmlock->l_granted_mode ==
-				   dlmlock->l_req_mode) {
-				osc_lock_granted(env, olck, dlmlock, dlmrc);
-			}
-			unlock_res_and_lock(dlmlock);
+		/*
+		 * This can be called in the context of outer IO, e.g.,
+		 *
+		 *     osc_enqueue_base()->...
+		 *	 ->ldlm_prep_elc_req()->...
+		 *	   ->ldlm_cancel_callback()->...
+		 *	     ->osc_ldlm_blocking_ast()
+		 *
+		 * new environment has to be created to not corrupt outer
+		 * context.
+		 */
+		env = cl_env_nested_get(&nest);
+		if (IS_ERR(env)) {
+			result = PTR_ERR(env);
+			break;
+		}
 
-			if (dlmrc != 0) {
-				CL_LOCK_DEBUG(D_ERROR, env, lock,
-					      "dlmlock returned %d\n", dlmrc);
-				cl_lock_error(env, lock, dlmrc);
-			}
-			cl_lock_mutex_put(env, lock);
-			osc_ast_data_put(env, olck);
-			result = 0;
-		} else
-			result = -ELDLM_NO_LOCK_DATA;
+		result = osc_dlm_blocking_ast0(env, dlmlock, data, flag);
 		cl_env_nested_put(&nest, env);
-	} else
-		result = PTR_ERR(env);
-	return dlmrc ?: result;
+		break;
+		}
+	default:
+		LBUG();
+	}
+	return result;
 }
 
 static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 {
 	struct ptlrpc_request *req = data;
-	struct osc_lock	*olck;
-	struct cl_lock *lock;
-	struct cl_object *obj;
 	struct cl_env_nest nest;
 	struct lu_env *env;
 	struct ost_lvb *lvb;
@@ -844,14 +582,16 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 
 	env = cl_env_nested_get(&nest);
 	if (!IS_ERR(env)) {
-		/* osc_ast_data_get() has to go after environment is
-		 * allocated, because osc_ast_data() acquires a
-		 * reference to a lock, and it can only be released in
-		 * environment.
-		 */
-		olck = osc_ast_data_get(dlmlock);
-		if (olck) {
-			lock = olck->ols_cl.cls_lock;
+		struct cl_object *obj = NULL;
+
+		lock_res_and_lock(dlmlock);
+		if (dlmlock->l_ast_data) {
+			obj = osc2cl(dlmlock->l_ast_data);
+			cl_object_get(obj);
+		}
+		unlock_res_and_lock(dlmlock);
+
+		if (obj) {
 			/* Do not grab the mutex of cl_lock for glimpse.
 			 * See LU-1274 for details.
 			 * BTW, it's okay for cl_lock to be cancelled during
@@ -866,7 +606,6 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 			result = req_capsule_server_pack(cap);
 			if (result == 0) {
 				lvb = req_capsule_server_get(cap, &RMF_DLM_LVB);
-				obj = lock->cll_descr.cld_obj;
 				result = cl_object_glimpse(env, obj, lvb);
 			}
 			if (!exp_connect_lvb_type(req->rq_export))
@@ -874,7 +613,7 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 						   &RMF_DLM_LVB,
 						   sizeof(struct ost_lvb_v1),
 						   RCL_SERVER);
-			osc_ast_data_put(env, olck);
+			cl_object_put(env, obj);
 		} else {
 			/*
 			 * These errors are normal races, so we don't want to
@@ -905,23 +644,24 @@ static int weigh_cb(const struct lu_env *env, struct cl_io *io,
 }
 
 static unsigned long osc_lock_weight(const struct lu_env *env,
-				     const struct osc_lock *ols)
+				     struct osc_object *oscobj,
+				     struct ldlm_extent *extent)
 {
 	struct cl_io *io = &osc_env_info(env)->oti_io;
-	struct cl_lock_descr *descr = &ols->ols_cl.cls_lock->cll_descr;
-	struct cl_object *obj = ols->ols_cl.cls_obj;
+	struct cl_object *obj = cl_object_top(&oscobj->oo_cl);
 	unsigned long npages = 0;
 	int result;
 
-	io->ci_obj = cl_object_top(obj);
+	io->ci_obj = obj;
 	io->ci_ignore_layout = 1;
 	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (result != 0)
 		return result;
 
 	do {
-		result = osc_page_gang_lookup(env, io, cl2osc(obj),
-					      descr->cld_start, descr->cld_end,
+		result = osc_page_gang_lookup(env, io, oscobj,
+					      cl_index(obj, extent->start),
+					      cl_index(obj, extent->end),
 					      weigh_cb, (void *)&npages);
 		if (result == CLP_GANG_ABORT)
 			break;
@@ -940,8 +680,10 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 {
 	struct cl_env_nest       nest;
 	struct lu_env           *env;
-	struct osc_lock         *lock;
+	struct osc_object	*obj;
+	struct osc_lock		*oscl;
 	unsigned long            weight;
+	bool			 found = false;
 
 	might_sleep();
 	/*
@@ -957,18 +699,28 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 		return 1;
 
 	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT);
-	lock = osc_ast_data_get(dlmlock);
-	if (!lock) {
-		/* cl_lock was destroyed because of memory pressure.
-		 * It is much reasonable to assign this type of lock
-		 * a lower cost.
+	obj = dlmlock->l_ast_data;
+	if (obj) {
+		weight = 1;
+		goto out;
+	}
+
+	spin_lock(&obj->oo_ol_spin);
+	list_for_each_entry(oscl, &obj->oo_ol_list, ols_nextlock_oscobj) {
+		if (oscl->ols_dlmlock && oscl->ols_dlmlock != dlmlock)
+			continue;
+		found = true;
+	}
+	spin_unlock(&obj->oo_ol_spin);
+	if (found) {
+		/*
+		 * If the lock is being used by an IO, definitely not cancel it.
 		 */
-		weight = 0;
+		weight = 1;
 		goto out;
 	}
 
-	weight = osc_lock_weight(env, lock);
-	osc_ast_data_put(env, lock);
+	weight = osc_lock_weight(env, obj, &dlmlock->l_policy_data.l_extent);
 
 out:
 	cl_env_nested_put(&nest, env);
@@ -976,27 +728,16 @@ out:
 }
 
 static void osc_lock_build_einfo(const struct lu_env *env,
-				 const struct cl_lock *clock,
-				 struct osc_lock *lock,
+				 const struct cl_lock *lock,
+				 struct osc_object *osc,
 				 struct ldlm_enqueue_info *einfo)
 {
-	enum cl_lock_mode mode;
-
-	mode = clock->cll_descr.cld_mode;
-	if (mode == CLM_PHANTOM)
-		/*
-		 * For now, enqueue all glimpse locks in read mode. In the
-		 * future, client might choose to enqueue LCK_PW lock for
-		 * glimpse on a file opened for write.
-		 */
-		mode = CLM_READ;
-
 	einfo->ei_type = LDLM_EXTENT;
-	einfo->ei_mode = osc_cl_lock2ldlm(mode);
+	einfo->ei_mode   = osc_cl_lock2ldlm(lock->cll_descr.cld_mode);
 	einfo->ei_cb_bl = osc_ldlm_blocking_ast;
-	einfo->ei_cb_cp = osc_ldlm_completion_ast;
+	einfo->ei_cb_cp  = ldlm_completion_ast;
 	einfo->ei_cb_gl = osc_ldlm_glimpse_ast;
-	einfo->ei_cbdata = lock; /* value to be put into ->l_ast_data */
+	einfo->ei_cbdata = osc; /* value to be put into ->l_ast_data */
 }
 
 /**
@@ -1052,113 +793,100 @@ static void osc_lock_to_lockless(const struct lu_env *env,
 	LASSERT(ergo(ols->ols_glimpse, !osc_lock_is_lockless(ols)));
 }
 
-static int osc_lock_compatible(const struct osc_lock *qing,
-			       const struct osc_lock *qed)
+static bool osc_lock_compatible(const struct osc_lock *qing,
+				const struct osc_lock *qed)
 {
-	enum cl_lock_mode qing_mode;
-	enum cl_lock_mode qed_mode;
+	struct cl_lock_descr *qed_descr = &qed->ols_cl.cls_lock->cll_descr;
+	struct cl_lock_descr *qing_descr = &qing->ols_cl.cls_lock->cll_descr;
 
-	qing_mode = qing->ols_cl.cls_lock->cll_descr.cld_mode;
-	if (qed->ols_glimpse &&
-	    (qed->ols_state >= OLS_UPCALL_RECEIVED || qing_mode == CLM_READ))
-		return 1;
+	if (qed->ols_glimpse)
+		return true;
+
+	if (qing_descr->cld_mode == CLM_READ && qed_descr->cld_mode == CLM_READ)
+		return true;
+
+	if (qed->ols_state < OLS_GRANTED)
+		return true;
+
+	if (qed_descr->cld_mode  >= qing_descr->cld_mode &&
+	    qed_descr->cld_start <= qing_descr->cld_start &&
+	    qed_descr->cld_end   >= qing_descr->cld_end)
+		return true;
 
-	qed_mode = qed->ols_cl.cls_lock->cll_descr.cld_mode;
-	return ((qing_mode == CLM_READ) && (qed_mode == CLM_READ));
+	return false;
 }
 
-/**
- * Cancel all conflicting locks and wait for them to be destroyed.
- *
- * This function is used for two purposes:
- *
- *     - early cancel all conflicting locks before starting IO, and
- *
- *     - guarantee that pages added to the page cache by lockless IO are never
- *       covered by locks other than lockless IO lock, and, hence, are not
- *       visible to other threads.
- */
-static int osc_lock_enqueue_wait(const struct lu_env *env,
-				 const struct osc_lock *olck)
+static void osc_lock_wake_waiters(const struct lu_env *env,
+				  struct osc_object *osc,
+				  struct osc_lock *oscl)
 {
-	struct cl_lock *lock = olck->ols_cl.cls_lock;
-	struct cl_lock_descr *descr = &lock->cll_descr;
-	struct cl_object_header *hdr = cl_object_header(descr->cld_obj);
-	struct cl_lock *scan;
-	struct cl_lock *conflict = NULL;
-	int lockless = osc_lock_is_lockless(olck);
-	int rc = 0;
+	spin_lock(&osc->oo_ol_spin);
+	list_del_init(&oscl->ols_nextlock_oscobj);
+	spin_unlock(&osc->oo_ol_spin);
 
-	LASSERT(cl_lock_is_mutexed(lock));
+	spin_lock(&oscl->ols_lock);
+	while (!list_empty(&oscl->ols_waiting_list)) {
+		struct osc_lock *scan;
 
-	/* make it enqueue anyway for glimpse lock, because we actually
-	 * don't need to cancel any conflicting locks.
-	 */
-	if (olck->ols_glimpse)
-		return 0;
+		scan = list_entry(oscl->ols_waiting_list.next, struct osc_lock,
+				  ols_wait_entry);
+		list_del_init(&scan->ols_wait_entry);
+
+		cl_sync_io_note(env, scan->ols_owner, 0);
+	}
+	spin_unlock(&oscl->ols_lock);
+}
 
-	spin_lock(&hdr->coh_lock_guard);
-	list_for_each_entry(scan, &hdr->coh_locks, cll_linkage) {
-		struct cl_lock_descr *cld = &scan->cll_descr;
-		const struct osc_lock *scan_ols;
+static void osc_lock_enqueue_wait(const struct lu_env *env,
+				  struct osc_object *obj,
+				  struct osc_lock *oscl)
+{
+	struct osc_lock *tmp_oscl;
+	struct cl_lock_descr *need = &oscl->ols_cl.cls_lock->cll_descr;
+	struct cl_sync_io *waiter = &osc_env_info(env)->oti_anchor;
+
+	spin_lock(&obj->oo_ol_spin);
+	list_add_tail(&oscl->ols_nextlock_oscobj, &obj->oo_ol_list);
 
-		if (scan == lock)
+restart:
+	list_for_each_entry(tmp_oscl, &obj->oo_ol_list,
+			    ols_nextlock_oscobj) {
+		struct cl_lock_descr *descr;
+
+		if (tmp_oscl == oscl)
 			break;
 
-		if (scan->cll_state < CLS_QUEUING ||
-		    scan->cll_state == CLS_FREEING ||
-		    cld->cld_start > descr->cld_end ||
-		    cld->cld_end < descr->cld_start)
+		descr = &tmp_oscl->ols_cl.cls_lock->cll_descr;
+		if (descr->cld_start > need->cld_end ||
+		    descr->cld_end   < need->cld_start)
 			continue;
 
-		/* overlapped and living locks. */
+		/* We're not supposed to give up group lock */
+		if (descr->cld_mode == CLM_GROUP)
+			break;
 
-		/* We're not supposed to give up group lock. */
-		if (scan->cll_descr.cld_mode == CLM_GROUP) {
-			LASSERT(descr->cld_mode != CLM_GROUP ||
-				descr->cld_gid != scan->cll_descr.cld_gid);
+		if (!osc_lock_is_lockless(oscl) &&
+		    osc_lock_compatible(oscl, tmp_oscl))
 			continue;
-		}
 
-		scan_ols = osc_lock_at(scan);
+		/* wait for conflicting lock to be canceled */
+		cl_sync_io_init(waiter, 1, cl_sync_io_end);
+		oscl->ols_owner = waiter;
 
-		/* We need to cancel the compatible locks if we're enqueuing
-		 * a lockless lock, for example:
-		 * imagine that client has PR lock on [0, 1000], and thread T0
-		 * is doing lockless IO in [500, 1500] region. Concurrent
-		 * thread T1 can see lockless data in [500, 1000], which is
-		 * wrong, because these data are possibly stale.
-		 */
-		if (!lockless && osc_lock_compatible(olck, scan_ols))
-			continue;
+		spin_lock(&tmp_oscl->ols_lock);
+		/* add oscl into tmp's ols_waiting list */
+		list_add_tail(&oscl->ols_wait_entry,
+			      &tmp_oscl->ols_waiting_list);
+		spin_unlock(&tmp_oscl->ols_lock);
 
-		cl_lock_get_trust(scan);
-		conflict = scan;
-		break;
-	}
-	spin_unlock(&hdr->coh_lock_guard);
+		spin_unlock(&obj->oo_ol_spin);
+		(void)cl_sync_io_wait(env, waiter, 0);
 
-	if (conflict) {
-		if (lock->cll_descr.cld_mode == CLM_GROUP) {
-			/* we want a group lock but a previous lock request
-			 * conflicts, we do not wait but return 0 so the
-			 * request is send to the server
-			 */
-			CDEBUG(D_DLMTRACE, "group lock %p is conflicted with %p, no wait, send to server\n",
-			       lock, conflict);
-			cl_lock_put(env, conflict);
-			rc = 0;
-		} else {
-			CDEBUG(D_DLMTRACE, "lock %p is conflicted with %p, will wait\n",
-			       lock, conflict);
-			LASSERT(!lock->cll_conflict);
-			lu_ref_add(&conflict->cll_reference, "cancel-wait",
-				   lock);
-			lock->cll_conflict = conflict;
-			rc = CLO_WAIT;
-		}
+		spin_lock(&obj->oo_ol_spin);
+		oscl->ols_owner = NULL;
+		goto restart;
 	}
-	return rc;
+	spin_unlock(&obj->oo_ol_spin);
 }
 
 /**
@@ -1177,188 +905,122 @@ static int osc_lock_enqueue_wait(const struct lu_env *env,
  */
 static int osc_lock_enqueue(const struct lu_env *env,
 			    const struct cl_lock_slice *slice,
-			    struct cl_io *unused, __u32 enqflags)
+			    struct cl_io *unused, struct cl_sync_io *anchor)
 {
-	struct osc_lock *ols = cl2osc_lock(slice);
-	struct cl_lock *lock = ols->ols_cl.cls_lock;
+	struct osc_thread_info *info = osc_env_info(env);
+	struct osc_io *oio = osc_env_io(env);
+	struct osc_object *osc = cl2osc(slice->cls_obj);
+	struct osc_lock *oscl = cl2osc_lock(slice);
+	struct cl_lock *lock = slice->cls_lock;
+	struct ldlm_res_id *resname = &info->oti_resname;
+	ldlm_policy_data_t *policy = &info->oti_policy;
+	osc_enqueue_upcall_f upcall = osc_lock_upcall;
+	void *cookie = oscl;
+	bool async = false;
 	int result;
 
-	LASSERT(cl_lock_is_mutexed(lock));
-	LASSERTF(ols->ols_state == OLS_NEW,
-		 "Impossible state: %d\n", ols->ols_state);
-
-	LASSERTF(ergo(ols->ols_glimpse, lock->cll_descr.cld_mode <= CLM_READ),
-		 "lock = %p, ols = %p\n", lock, ols);
+	LASSERTF(ergo(oscl->ols_glimpse, lock->cll_descr.cld_mode <= CLM_READ),
+		 "lock = %p, ols = %p\n", lock, oscl);
 
-	result = osc_lock_enqueue_wait(env, ols);
-	if (result == 0) {
-		if (!osc_lock_is_lockless(ols)) {
-			struct osc_object *obj = cl2osc(slice->cls_obj);
-			struct osc_thread_info *info = osc_env_info(env);
-			struct ldlm_res_id *resname = &info->oti_resname;
-			ldlm_policy_data_t *policy = &info->oti_policy;
-			struct ldlm_enqueue_info *einfo = &ols->ols_einfo;
+	if (oscl->ols_state == OLS_GRANTED)
+		return 0;
 
-			/* lock will be passed as upcall cookie,
-			 * hold ref to prevent to be released.
-			 */
-			cl_lock_hold_add(env, lock, "upcall", lock);
-			/* a user for lock also */
-			cl_lock_user_add(env, lock);
-			ols->ols_state = OLS_ENQUEUED;
+	if (oscl->ols_flags & LDLM_FL_TEST_LOCK)
+		goto enqueue_base;
 
-			/*
-			 * XXX: this is possible blocking point as
-			 * ldlm_lock_match(LDLM_FL_LVB_READY) waits for
-			 * LDLM_CP_CALLBACK.
-			 */
-			ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
-			osc_lock_build_policy(env, lock, policy);
-			result = osc_enqueue_base(osc_export(obj), resname,
-						  &ols->ols_flags, policy,
-						  &ols->ols_lvb,
-						  obj->oo_oinfo->loi_kms_valid,
-						  osc_lock_upcall,
-						  ols, einfo, &ols->ols_handle,
-						  PTLRPCD_SET, 1, ols->ols_agl);
-			if (result != 0) {
-				cl_lock_user_del(env, lock);
-				cl_lock_unhold(env, lock, "upcall", lock);
-				if (unlikely(result == -ECANCELED)) {
-					ols->ols_state = OLS_NEW;
-					result = 0;
-				}
-			}
-		} else {
-			ols->ols_state = OLS_GRANTED;
-			ols->ols_owner = osc_env_io(env);
-		}
+	if (oscl->ols_glimpse) {
+		LASSERT(equi(oscl->ols_agl, !anchor));
+		async = true;
+		goto enqueue_base;
 	}
-	LASSERT(ergo(ols->ols_glimpse, !osc_lock_is_lockless(ols)));
-	return result;
-}
 
-static int osc_lock_wait(const struct lu_env *env,
-			 const struct cl_lock_slice *slice)
-{
-	struct osc_lock *olck = cl2osc_lock(slice);
-	struct cl_lock *lock = olck->ols_cl.cls_lock;
-
-	LINVRNT(osc_lock_invariant(olck));
-
-	if (olck->ols_glimpse && olck->ols_state >= OLS_UPCALL_RECEIVED) {
-		if (olck->ols_flags & LDLM_FL_LVB_READY) {
-			return 0;
-		} else if (olck->ols_agl) {
-			if (lock->cll_flags & CLF_FROM_UPCALL)
-				/* It is from enqueue RPC reply upcall for
-				 * updating state. Do not re-enqueue.
-				 */
-				return -ENAVAIL;
-			olck->ols_state = OLS_NEW;
-		} else {
-			LASSERT(lock->cll_error);
-			return lock->cll_error;
-		}
+	osc_lock_enqueue_wait(env, osc, oscl);
+
+	/* we can grant lockless lock right after all conflicting locks
+	 * are canceled.
+	 */
+	if (osc_lock_is_lockless(oscl)) {
+		oscl->ols_state = OLS_GRANTED;
+		oio->oi_lockless = 1;
+		return 0;
 	}
 
-	if (olck->ols_state == OLS_NEW) {
-		int rc;
-
-		LASSERT(olck->ols_agl);
-		olck->ols_agl = 0;
-		olck->ols_flags &= ~LDLM_FL_BLOCK_NOWAIT;
-		rc = osc_lock_enqueue(env, slice, NULL, CEF_ASYNC | CEF_MUST);
-		if (rc != 0)
-			return rc;
-		else
-			return CLO_REENQUEUED;
+enqueue_base:
+	oscl->ols_state = OLS_ENQUEUED;
+	if (anchor) {
+		atomic_inc(&anchor->csi_sync_nr);
+		oscl->ols_owner = anchor;
 	}
 
-	LASSERT(equi(olck->ols_state >= OLS_UPCALL_RECEIVED &&
-		     lock->cll_error == 0, olck->ols_lock));
+	/**
+	 * DLM lock's ast data must be osc_object;
+	 * if glimpse or AGL lock, async of osc_enqueue_base() must be true,
+	 * DLM's enqueue callback set to osc_lock_upcall() with cookie as
+	 * osc_lock.
+	 */
+	ostid_build_res_name(&osc->oo_oinfo->loi_oi, resname);
+	osc_lock_build_einfo(env, lock, osc, &oscl->ols_einfo);
+	osc_lock_build_policy(env, lock, policy);
+	if (oscl->ols_agl) {
+		oscl->ols_einfo.ei_cbdata = NULL;
+		/* hold a reference for callback */
+		cl_object_get(osc2cl(osc));
+		upcall = osc_lock_upcall_agl;
+		cookie = osc;
+	}
+	result = osc_enqueue_base(osc_export(osc), resname, &oscl->ols_flags,
+				  policy, &oscl->ols_lvb,
+				  osc->oo_oinfo->loi_kms_valid,
+				  upcall, cookie,
+				  &oscl->ols_einfo, PTLRPCD_SET, async,
+				  oscl->ols_agl);
+	if (result != 0) {
+		oscl->ols_state = OLS_CANCELLED;
+		osc_lock_wake_waiters(env, osc, oscl);
 
-	return lock->cll_error ?: olck->ols_state >= OLS_GRANTED ? 0 : CLO_WAIT;
+		/* hide error for AGL lock. */
+		if (oscl->ols_agl) {
+			cl_object_put(env, osc2cl(osc));
+			result = 0;
+		}
+		if (anchor)
+			cl_sync_io_note(env, anchor, result);
+	} else {
+		if (osc_lock_is_lockless(oscl)) {
+			oio->oi_lockless = 1;
+		} else if (!async) {
+			LASSERT(oscl->ols_state == OLS_GRANTED);
+			LASSERT(oscl->ols_hold);
+			LASSERT(oscl->ols_dlmlock);
+		}
+	}
+	return result;
 }
 
 /**
- * An implementation of cl_lock_operations::clo_use() method that pins cached
- * lock.
+ * Breaks a link between osc_lock and dlm_lock.
  */
-static int osc_lock_use(const struct lu_env *env,
-			const struct cl_lock_slice *slice)
+static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 {
-	struct osc_lock *olck = cl2osc_lock(slice);
-	int rc;
-
-	LASSERT(!olck->ols_hold);
+	struct ldlm_lock *dlmlock;
 
-	/*
-	 * Atomically check for LDLM_FL_CBPENDING and addref a lock if this
-	 * flag is not set. This protects us from a concurrent blocking ast.
-	 */
-	rc = ldlm_lock_addref_try(&olck->ols_handle, olck->ols_einfo.ei_mode);
-	if (rc == 0) {
-		olck->ols_hold = 1;
-		olck->ols_state = OLS_GRANTED;
-	} else {
-		struct cl_lock *lock;
+	dlmlock = olck->ols_dlmlock;
+	if (!dlmlock)
+		return;
 
-		/*
-		 * Lock is being cancelled somewhere within
-		 * ldlm_handle_bl_callback(): LDLM_FL_CBPENDING is already
-		 * set, but osc_ldlm_blocking_ast() hasn't yet acquired
-		 * cl_lock mutex.
-		 */
-		lock = slice->cls_lock;
-		LASSERT(lock->cll_state == CLS_INTRANSIT);
-		LASSERT(lock->cll_users > 0);
-		/* set a flag for osc_dlm_blocking_ast0() to signal the
-		 * lock.
-		 */
-		olck->ols_ast_wait = 1;
-		rc = CLO_WAIT;
+	if (olck->ols_hold) {
+		olck->ols_hold = 0;
+		osc_cancel_base(&olck->ols_handle, olck->ols_einfo.ei_mode);
+		olck->ols_handle.cookie = 0ULL;
 	}
-	return rc;
-}
 
-static int osc_lock_flush(struct osc_lock *ols, int discard)
-{
-	struct cl_lock *lock = ols->ols_cl.cls_lock;
-	struct cl_env_nest nest;
-	struct lu_env *env;
-	int result = 0;
+	olck->ols_dlmlock = NULL;
 
-	env = cl_env_nested_get(&nest);
-	if (!IS_ERR(env)) {
-		struct osc_object *obj = cl2osc(ols->ols_cl.cls_obj);
-		struct cl_lock_descr *descr = &lock->cll_descr;
-		int rc = 0;
-
-		if (descr->cld_mode >= CLM_WRITE) {
-			result = osc_cache_writeback_range(env, obj,
-							   descr->cld_start,
-							   descr->cld_end,
-							   1, discard);
-			LDLM_DEBUG(ols->ols_lock,
-				   "lock %p: %d pages were %s.\n", lock, result,
-				   discard ? "discarded" : "written");
-			if (result > 0)
-				result = 0;
-		}
-
-		rc = osc_lock_discard_pages(env, ols);
-		if (result == 0 && rc < 0)
-			result = rc;
-
-		cl_env_nested_put(&nest, env);
-	} else
-		result = PTR_ERR(env);
-	if (result == 0) {
-		ols->ols_flush = 1;
-		LINVRNT(!osc_lock_has_pages(ols));
-	}
-	return result;
+	/* release a reference taken in osc_lock_upcall(). */
+	LASSERT(olck->ols_has_ref);
+	lu_ref_del(&dlmlock->l_reference, "osc_lock", olck);
+	LDLM_LOCK_RELEASE(dlmlock);
+	olck->ols_has_ref = 0;
 }
 
 /**
@@ -1378,96 +1040,16 @@ static int osc_lock_flush(struct osc_lock *ols, int discard)
 static void osc_lock_cancel(const struct lu_env *env,
 			    const struct cl_lock_slice *slice)
 {
-	struct cl_lock *lock = slice->cls_lock;
-	struct osc_lock *olck = cl2osc_lock(slice);
-	struct ldlm_lock *dlmlock = olck->ols_lock;
-	int result = 0;
-	int discard;
-
-	LASSERT(cl_lock_is_mutexed(lock));
-	LINVRNT(osc_lock_invariant(olck));
-
-	if (dlmlock) {
-		int do_cancel;
-
-		discard = !!(dlmlock->l_flags & LDLM_FL_DISCARD_DATA);
-		if (olck->ols_state >= OLS_GRANTED)
-			result = osc_lock_flush(olck, discard);
-		osc_lock_unhold(olck);
-
-		lock_res_and_lock(dlmlock);
-		/* Now that we're the only user of dlm read/write reference,
-		 * mostly the ->l_readers + ->l_writers should be zero.
-		 * However, there is a corner case.
-		 * See bug 18829 for details.
-		 */
-		do_cancel = (dlmlock->l_readers == 0 &&
-			     dlmlock->l_writers == 0);
-		dlmlock->l_flags |= LDLM_FL_CBPENDING;
-		unlock_res_and_lock(dlmlock);
-		if (do_cancel)
-			result = ldlm_cli_cancel(&olck->ols_handle, LCF_ASYNC);
-		if (result < 0)
-			CL_LOCK_DEBUG(D_ERROR, env, lock,
-				      "lock %p cancel failure with error(%d)\n",
-				      lock, result);
-	}
-	olck->ols_state = OLS_CANCELLED;
-	olck->ols_flags &= ~LDLM_FL_LVB_READY;
-	osc_lock_detach(env, olck);
-}
-
-static int osc_lock_has_pages(struct osc_lock *olck)
-{
-	return 0;
-}
-
-static void osc_lock_delete(const struct lu_env *env,
-			    const struct cl_lock_slice *slice)
-{
-	struct osc_lock *olck;
-
-	olck = cl2osc_lock(slice);
-	if (olck->ols_glimpse) {
-		LASSERT(!olck->ols_hold);
-		LASSERT(!olck->ols_lock);
-		return;
-	}
-
-	LINVRNT(osc_lock_invariant(olck));
-	LINVRNT(!osc_lock_has_pages(olck));
-
-	osc_lock_unhold(olck);
-	osc_lock_detach(env, olck);
-}
+	struct osc_object *obj  = cl2osc(slice->cls_obj);
+	struct osc_lock *oscl = cl2osc_lock(slice);
 
-/**
- * Implements cl_lock_operations::clo_state() method for osc layer.
- *
- * Maintains osc_lock::ols_owner field.
- *
- * This assumes that lock always enters CLS_HELD (from some other state) in
- * the same IO context as one that requested the lock. This should not be a
- * problem, because context is by definition shared by all activity pertaining
- * to the same high-level IO.
- */
-static void osc_lock_state(const struct lu_env *env,
-			   const struct cl_lock_slice *slice,
-			   enum cl_lock_state state)
-{
-	struct osc_lock *lock = cl2osc_lock(slice);
+	LINVRNT(osc_lock_invariant(oscl));
 
-	/*
-	 * XXX multiple io contexts can use the lock at the same time.
-	 */
-	LINVRNT(osc_lock_invariant(lock));
-	if (state == CLS_HELD && slice->cls_lock->cll_state != CLS_HELD) {
-		struct osc_io *oio = osc_env_io(env);
+	osc_lock_detach(env, oscl);
+	oscl->ols_state = OLS_CANCELLED;
+	oscl->ols_flags &= ~LDLM_FL_LVB_READY;
 
-		LASSERT(!lock->ols_owner);
-		lock->ols_owner = oio;
-	} else if (state != CLS_HELD)
-		lock->ols_owner = NULL;
+	osc_lock_wake_waiters(env, obj, oscl);
 }
 
 static int osc_lock_print(const struct lu_env *env, void *cookie,
@@ -1475,197 +1057,161 @@ static int osc_lock_print(const struct lu_env *env, void *cookie,
 {
 	struct osc_lock *lock = cl2osc_lock(slice);
 
-	/*
-	 * XXX print ldlm lock and einfo properly.
-	 */
 	(*p)(env, cookie, "%p %#16llx %#llx %d %p ",
-	     lock->ols_lock, lock->ols_flags, lock->ols_handle.cookie,
+	     lock->ols_dlmlock, lock->ols_flags, lock->ols_handle.cookie,
 	     lock->ols_state, lock->ols_owner);
 	osc_lvb_print(env, cookie, p, &lock->ols_lvb);
 	return 0;
 }
 
-static int osc_lock_fits_into(const struct lu_env *env,
-			      const struct cl_lock_slice *slice,
-			      const struct cl_lock_descr *need,
-			      const struct cl_io *io)
-{
-	struct osc_lock *ols = cl2osc_lock(slice);
-
-	if (need->cld_enq_flags & CEF_NEVER)
-		return 0;
-
-	if (ols->ols_state >= OLS_CANCELLED)
-		return 0;
-
-	if (need->cld_mode == CLM_PHANTOM) {
-		if (ols->ols_agl)
-			return !(ols->ols_state > OLS_RELEASED);
-
-		/*
-		 * Note: the QUEUED lock can't be matched here, otherwise
-		 * it might cause the deadlocks.
-		 * In read_process,
-		 * P1: enqueued read lock, create sublock1
-		 * P2: enqueued write lock, create sublock2(conflicted
-		 *     with sublock1).
-		 * P1: Grant read lock.
-		 * P1: enqueued glimpse lock(with holding sublock1_read),
-		 *     matched with sublock2, waiting sublock2 to be granted.
-		 *     But sublock2 can not be granted, because P1
-		 *     will not release sublock1. Bang!
-		 */
-		if (ols->ols_state < OLS_GRANTED ||
-		    ols->ols_state > OLS_RELEASED)
-			return 0;
-	} else if (need->cld_enq_flags & CEF_MUST) {
-		/*
-		 * If the lock hasn't ever enqueued, it can't be matched
-		 * because enqueue process brings in many information
-		 * which can be used to determine things such as lockless,
-		 * CEF_MUST, etc.
-		 */
-		if (ols->ols_state < OLS_UPCALL_RECEIVED &&
-		    ols->ols_locklessable)
-			return 0;
-	}
-	return 1;
-}
-
 static const struct cl_lock_operations osc_lock_ops = {
 	.clo_fini    = osc_lock_fini,
 	.clo_enqueue = osc_lock_enqueue,
-	.clo_wait    = osc_lock_wait,
-	.clo_unuse   = osc_lock_unuse,
-	.clo_use     = osc_lock_use,
-	.clo_delete  = osc_lock_delete,
-	.clo_state   = osc_lock_state,
 	.clo_cancel  = osc_lock_cancel,
 	.clo_print   = osc_lock_print,
-	.clo_fits_into = osc_lock_fits_into,
 };
 
-static int osc_lock_lockless_unuse(const struct lu_env *env,
-				   const struct cl_lock_slice *slice)
-{
-	struct osc_lock *ols = cl2osc_lock(slice);
-	struct cl_lock *lock = slice->cls_lock;
-
-	LASSERT(ols->ols_state == OLS_GRANTED);
-	LINVRNT(osc_lock_invariant(ols));
-
-	cl_lock_cancel(env, lock);
-	cl_lock_delete(env, lock);
-	return 0;
-}
-
 static void osc_lock_lockless_cancel(const struct lu_env *env,
 				     const struct cl_lock_slice *slice)
 {
 	struct osc_lock *ols = cl2osc_lock(slice);
+	struct osc_object *osc = cl2osc(slice->cls_obj);
+	struct cl_lock_descr *descr = &slice->cls_lock->cll_descr;
 	int result;
 
-	result = osc_lock_flush(ols, 0);
+	LASSERT(!ols->ols_dlmlock);
+	result = osc_lock_flush(osc, descr->cld_start, descr->cld_end,
+				descr->cld_mode, 0);
 	if (result)
 		CERROR("Pages for lockless lock %p were not purged(%d)\n",
 		       ols, result);
-	ols->ols_state = OLS_CANCELLED;
-}
 
-static int osc_lock_lockless_wait(const struct lu_env *env,
-				  const struct cl_lock_slice *slice)
-{
-	struct osc_lock *olck = cl2osc_lock(slice);
-	struct cl_lock *lock = olck->ols_cl.cls_lock;
-
-	LINVRNT(osc_lock_invariant(olck));
-	LASSERT(olck->ols_state >= OLS_UPCALL_RECEIVED);
-
-	return lock->cll_error;
+	osc_lock_wake_waiters(env, osc, ols);
 }
 
-static void osc_lock_lockless_state(const struct lu_env *env,
-				    const struct cl_lock_slice *slice,
-				    enum cl_lock_state state)
-{
-	struct osc_lock *lock = cl2osc_lock(slice);
+static const struct cl_lock_operations osc_lock_lockless_ops = {
+	.clo_fini	= osc_lock_fini,
+	.clo_enqueue	= osc_lock_enqueue,
+	.clo_cancel	= osc_lock_lockless_cancel,
+	.clo_print	= osc_lock_print
+};
 
-	LINVRNT(osc_lock_invariant(lock));
-	if (state == CLS_HELD) {
-		struct osc_io *oio = osc_env_io(env);
+static void osc_lock_set_writer(const struct lu_env *env,
+				const struct cl_io *io,
+				struct cl_object *obj, struct osc_lock *oscl)
+{
+	struct cl_lock_descr *descr = &oscl->ols_cl.cls_lock->cll_descr;
+	pgoff_t io_start;
+	pgoff_t io_end;
 
-		LASSERT(ergo(lock->ols_owner, lock->ols_owner == oio));
-		lock->ols_owner = oio;
+	if (!cl_object_same(io->ci_obj, obj))
+		return;
 
-		/* set the io to be lockless if this lock is for io's
-		 * host object
-		 */
-		if (cl_object_same(oio->oi_cl.cis_obj, slice->cls_obj))
-			oio->oi_lockless = 1;
+	if (likely(io->ci_type == CIT_WRITE)) {
+		io_start = cl_index(obj, io->u.ci_rw.crw_pos);
+		io_end = cl_index(obj, io->u.ci_rw.crw_pos +
+				  io->u.ci_rw.crw_count - 1);
+		if (cl_io_is_append(io)) {
+			io_start = 0;
+			io_end = CL_PAGE_EOF;
+		}
+	} else {
+		LASSERT(cl_io_is_mkwrite(io));
+		io_start = io_end = io->u.ci_fault.ft_index;
 	}
-}
 
-static int osc_lock_lockless_fits_into(const struct lu_env *env,
-				       const struct cl_lock_slice *slice,
-				       const struct cl_lock_descr *need,
-				       const struct cl_io *io)
-{
-	struct osc_lock *lock = cl2osc_lock(slice);
-
-	if (!(need->cld_enq_flags & CEF_NEVER))
-		return 0;
+	if (descr->cld_mode >= CLM_WRITE &&
+	    descr->cld_start <= io_start && descr->cld_end >= io_end) {
+		struct osc_io *oio = osc_env_io(env);
 
-	/* lockless lock should only be used by its owning io. b22147 */
-	return (lock->ols_owner == osc_env_io(env));
+		/* There must be only one lock to match the write region */
+		LASSERT(!oio->oi_write_osclock);
+		oio->oi_write_osclock = oscl;
+	}
 }
 
-static const struct cl_lock_operations osc_lock_lockless_ops = {
-	.clo_fini      = osc_lock_fini,
-	.clo_enqueue   = osc_lock_enqueue,
-	.clo_wait      = osc_lock_lockless_wait,
-	.clo_unuse     = osc_lock_lockless_unuse,
-	.clo_state     = osc_lock_lockless_state,
-	.clo_fits_into = osc_lock_lockless_fits_into,
-	.clo_cancel    = osc_lock_lockless_cancel,
-	.clo_print     = osc_lock_print
-};
-
 int osc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
-		  const struct cl_io *unused)
+		  const struct cl_io *io)
 {
-	struct osc_lock *clk;
-	int result;
+	struct osc_lock *oscl;
+	__u32 enqflags = lock->cll_descr.cld_enq_flags;
+
+	oscl = kmem_cache_zalloc(osc_lock_kmem, GFP_NOFS);
+	if (!oscl)
+		return -ENOMEM;
+
+	oscl->ols_state = OLS_NEW;
+	spin_lock_init(&oscl->ols_lock);
+	INIT_LIST_HEAD(&oscl->ols_waiting_list);
+	INIT_LIST_HEAD(&oscl->ols_wait_entry);
+	INIT_LIST_HEAD(&oscl->ols_nextlock_oscobj);
+
+	oscl->ols_flags = osc_enq2ldlm_flags(enqflags);
+	oscl->ols_agl = !!(enqflags & CEF_AGL);
+	if (oscl->ols_agl)
+		oscl->ols_flags |= LDLM_FL_BLOCK_NOWAIT;
+	if (oscl->ols_flags & LDLM_FL_HAS_INTENT) {
+		oscl->ols_flags |= LDLM_FL_BLOCK_GRANTED;
+		oscl->ols_glimpse = 1;
+	}
 
-	clk = kmem_cache_zalloc(osc_lock_kmem, GFP_NOFS);
-	if (clk) {
-		__u32 enqflags = lock->cll_descr.cld_enq_flags;
+	cl_lock_slice_add(lock, &oscl->ols_cl, obj, &osc_lock_ops);
 
-		osc_lock_build_einfo(env, lock, clk, &clk->ols_einfo);
-		clk->ols_state = OLS_NEW;
+	if (!(enqflags & CEF_MUST))
+		/* try to convert this lock to a lockless lock */
+		osc_lock_to_lockless(env, oscl, (enqflags & CEF_NEVER));
+	if (oscl->ols_locklessable && !(enqflags & CEF_DISCARD_DATA))
+		oscl->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
 
-		clk->ols_flags = osc_enq2ldlm_flags(enqflags);
-		clk->ols_agl = !!(enqflags & CEF_AGL);
-		if (clk->ols_agl)
-			clk->ols_flags |= LDLM_FL_BLOCK_NOWAIT;
-		if (clk->ols_flags & LDLM_FL_HAS_INTENT)
-			clk->ols_glimpse = 1;
+	if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io))
+		osc_lock_set_writer(env, io, obj, oscl);
 
-		cl_lock_slice_add(lock, &clk->ols_cl, obj, &osc_lock_ops);
 
-		if (!(enqflags & CEF_MUST))
-			/* try to convert this lock to a lockless lock */
-			osc_lock_to_lockless(env, clk, (enqflags & CEF_NEVER));
-		if (clk->ols_locklessable && !(enqflags & CEF_DISCARD_DATA))
-			clk->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
+	LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx\n",
+			  lock, oscl, oscl->ols_flags);
 
-		LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx",
-				  lock, clk, clk->ols_flags);
+	return 0;
+}
 
-		result = 0;
-	} else
-		result = -ENOMEM;
-	return result;
+/**
+ * Finds an existing lock covering given index and optionally different from a
+ * given \a except lock.
+ */
+struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
+				       struct osc_object *obj, pgoff_t index,
+				       int pending, int canceling)
+{
+	struct osc_thread_info *info = osc_env_info(env);
+	struct ldlm_res_id *resname = &info->oti_resname;
+	ldlm_policy_data_t *policy  = &info->oti_policy;
+	struct lustre_handle lockh;
+	struct ldlm_lock *lock = NULL;
+	enum ldlm_mode mode;
+	__u64 flags;
+
+	ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
+	osc_index2policy(policy, osc2cl(obj), index, index);
+	policy->l_extent.gid = LDLM_GID_ANY;
+
+	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_TEST_LOCK;
+	if (pending)
+		flags |= LDLM_FL_CBPENDING;
+	/*
+	 * It is fine to match any group lock since there could be only one
+	 * with a uniq gid and it conflicts with all other lock modes too
+	 */
+again:
+	mode = ldlm_lock_match(osc_export(obj)->exp_obd->obd_namespace,
+			       flags, resname, LDLM_EXTENT, policy,
+			       LCK_PR | LCK_PW | LCK_GROUP, &lockh, canceling);
+	if (mode != 0) {
+		lock = ldlm_handle2lock(&lockh);
+		/* RACE: the lock is cancelled so let's try again */
+		if (unlikely(!lock))
+			goto again;
+	}
+	return lock;
 }
 
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 2d2d39a..a06bdf1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -96,6 +96,8 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 	atomic_set(&osc->oo_nr_writes, 0);
 	spin_lock_init(&osc->oo_lock);
 	spin_lock_init(&osc->oo_tree_lock);
+	spin_lock_init(&osc->oo_ol_spin);
+	INIT_LIST_HEAD(&osc->oo_ol_list);
 
 	cl_object_page_init(lu2cl(obj), sizeof(struct osc_page));
 
@@ -122,6 +124,7 @@ static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	LASSERT(list_empty(&osc->oo_reading_exts));
 	LASSERT(atomic_read(&osc->oo_nr_reads) == 0);
 	LASSERT(atomic_read(&osc->oo_nr_writes) == 0);
+	LASSERT(list_empty(&osc->oo_ol_list));
 
 	lu_object_fini(obj);
 	kmem_cache_free(osc_object_kmem, osc);
@@ -194,6 +197,32 @@ static int osc_object_glimpse(const struct lu_env *env,
 	return 0;
 }
 
+static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
+{
+	LASSERT(lock->l_granted_mode == lock->l_req_mode);
+	if (lock->l_ast_data == data)
+		lock->l_ast_data = NULL;
+	return LDLM_ITER_CONTINUE;
+}
+
+static int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
+{
+	struct osc_object       *osc = cl2osc(obj);
+	struct ldlm_res_id      *resname = &osc_env_info(env)->oti_resname;
+
+	LASSERTF(osc->oo_npages == 0,
+		 DFID "still have %lu pages, obj: %p, osc: %p\n",
+		 PFID(lu_object_fid(&obj->co_lu)), osc->oo_npages, obj, osc);
+
+	/* DLM locks don't hold a reference of osc_object so we have to
+	 * clear it before the object is being destroyed.
+	 */
+	ostid_build_res_name(&osc->oo_oinfo->loi_oi, resname);
+	ldlm_resource_iterate(osc_export(osc)->exp_obd->obd_namespace, resname,
+			      osc_object_ast_clear, osc);
+	return 0;
+}
+
 void osc_object_set_contended(struct osc_object *obj)
 {
 	obj->oo_contention_time = cfs_time_current();
@@ -238,12 +267,12 @@ static const struct cl_object_operations osc_ops = {
 	.coo_io_init   = osc_io_init,
 	.coo_attr_get  = osc_attr_get,
 	.coo_attr_set  = osc_attr_set,
-	.coo_glimpse   = osc_object_glimpse
+	.coo_glimpse   = osc_object_glimpse,
+	.coo_prune     = osc_object_prune
 };
 
 static const struct lu_object_operations osc_lu_obj_ops = {
 	.loo_object_init      = osc_object_init,
-	.loo_object_delete    = NULL,
 	.loo_object_release   = NULL,
 	.loo_object_free      = osc_object_free,
 	.loo_object_print     = osc_object_print,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 5b31351..82979f4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -135,15 +135,15 @@ static int osc_page_is_under_lock(const struct lu_env *env,
 				  struct cl_io *unused, pgoff_t *max_index)
 {
 	struct osc_page *opg = cl2osc_page(slice);
-	struct cl_lock *lock;
+	struct ldlm_lock *dlmlock;
 	int result = -ENODATA;
 
-	*max_index = 0;
-	lock = cl_lock_at_pgoff(env, slice->cpl_obj, osc_index(opg),
-				NULL, 1, 0);
-	if (lock) {
-		*max_index = lock->cll_descr.cld_end;
-		cl_lock_put(env, lock);
+	dlmlock = osc_dlmlock_at_pgoff(env, cl2osc(slice->cpl_obj),
+				       osc_index(opg), 1, 0);
+	if (dlmlock) {
+		*max_index = cl_index(slice->cpl_obj,
+				      dlmlock->l_policy_data.l_extent.end);
+		LDLM_LOCK_PUT(dlmlock);
 		result = 0;
 	}
 	return result;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 372bd26..368b997 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -92,12 +92,13 @@ struct osc_fsync_args {
 
 struct osc_enqueue_args {
 	struct obd_export	*oa_exp;
+	enum ldlm_type		oa_type;
+	enum ldlm_mode		oa_mode;
 	__u64		    *oa_flags;
-	obd_enqueue_update_f      oa_upcall;
+	osc_enqueue_upcall_f	oa_upcall;
 	void		     *oa_cookie;
 	struct ost_lvb	   *oa_lvb;
-	struct lustre_handle     *oa_lockh;
-	struct ldlm_enqueue_info *oa_ei;
+	struct lustre_handle	oa_lockh;
 	unsigned int	      oa_agl:1;
 };
 
@@ -2068,14 +2069,12 @@ static int osc_set_lock_data_with_check(struct ldlm_lock *lock,
 	LASSERT(lock->l_glimpse_ast == einfo->ei_cb_gl);
 
 	lock_res_and_lock(lock);
-	spin_lock(&osc_ast_guard);
 
 	if (!lock->l_ast_data)
 		lock->l_ast_data = data;
 	if (lock->l_ast_data == data)
 		set = 1;
 
-	spin_unlock(&osc_ast_guard);
 	unlock_res_and_lock(lock);
 
 	return set;
@@ -2117,36 +2116,38 @@ static int osc_find_cbdata(struct obd_export *exp, struct lov_stripe_md *lsm,
 	return rc;
 }
 
-static int osc_enqueue_fini(struct ptlrpc_request *req, struct ost_lvb *lvb,
-			    obd_enqueue_update_f upcall, void *cookie,
-			    __u64 *flags, int agl, int rc)
+static int osc_enqueue_fini(struct ptlrpc_request *req,
+			    osc_enqueue_upcall_f upcall, void *cookie,
+			    struct lustre_handle *lockh, enum ldlm_mode mode,
+			    __u64 *flags, int agl, int errcode)
 {
-	int intent = *flags & LDLM_FL_HAS_INTENT;
-
-	if (intent) {
-		/* The request was created before ldlm_cli_enqueue call. */
-		if (rc == ELDLM_LOCK_ABORTED) {
-			struct ldlm_reply *rep;
+	bool intent = *flags & LDLM_FL_HAS_INTENT;
+	int rc;
 
-			rep = req_capsule_server_get(&req->rq_pill,
-						     &RMF_DLM_REP);
+	/* The request was created before ldlm_cli_enqueue call. */
+	if (intent && errcode == ELDLM_LOCK_ABORTED) {
+		struct ldlm_reply *rep;
 
-			rep->lock_policy_res1 =
-				ptlrpc_status_ntoh(rep->lock_policy_res1);
-			if (rep->lock_policy_res1)
-				rc = rep->lock_policy_res1;
-		}
-	}
+		rep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
 
-	if ((intent != 0 && rc == ELDLM_LOCK_ABORTED && agl == 0) ||
-	    (rc == 0)) {
+		rep->lock_policy_res1 =
+			ptlrpc_status_ntoh(rep->lock_policy_res1);
+		if (rep->lock_policy_res1)
+			errcode = rep->lock_policy_res1;
+		if (!agl)
+			*flags |= LDLM_FL_LVB_READY;
+	} else if (errcode == ELDLM_OK) {
 		*flags |= LDLM_FL_LVB_READY;
-		CDEBUG(D_INODE, "got kms %llu blocks %llu mtime %llu\n",
-		       lvb->lvb_size, lvb->lvb_blocks, lvb->lvb_mtime);
 	}
 
 	/* Call the update callback. */
-	rc = (*upcall)(cookie, rc);
+	rc = (*upcall)(cookie, lockh, errcode);
+	/* release the reference taken in ldlm_cli_enqueue() */
+	if (errcode == ELDLM_LOCK_MATCHED)
+		errcode = ELDLM_OK;
+	if (errcode == ELDLM_OK && lustre_handle_is_used(lockh))
+		ldlm_lock_decref(lockh, mode);
+
 	return rc;
 }
 
@@ -2155,62 +2156,47 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 				 struct osc_enqueue_args *aa, int rc)
 {
 	struct ldlm_lock *lock;
-	struct lustre_handle handle;
-	__u32 mode;
-	struct ost_lvb *lvb;
-	__u32 lvb_len;
-	__u64 *flags = aa->oa_flags;
-
-	/* Make a local copy of a lock handle and a mode, because aa->oa_*
-	 * might be freed anytime after lock upcall has been called.
-	 */
-	lustre_handle_copy(&handle, aa->oa_lockh);
-	mode = aa->oa_ei->ei_mode;
+	struct lustre_handle *lockh = &aa->oa_lockh;
+	enum ldlm_mode mode = aa->oa_mode;
+	struct ost_lvb *lvb = aa->oa_lvb;
+	__u32 lvb_len = sizeof(*lvb);
+	__u64 flags = 0;
+
 
 	/* ldlm_cli_enqueue is holding a reference on the lock, so it must
 	 * be valid.
 	 */
-	lock = ldlm_handle2lock(&handle);
+	lock = ldlm_handle2lock(lockh);
+	LASSERTF(lock, "lockh %llx, req %p, aa %p - client evicted?\n",
+		 lockh->cookie, req, aa);
 
 	/* Take an additional reference so that a blocking AST that
 	 * ldlm_cli_enqueue_fini() might post for a failed lock, is guaranteed
 	 * to arrive after an upcall has been executed by
 	 * osc_enqueue_fini().
 	 */
-	ldlm_lock_addref(&handle, mode);
+	ldlm_lock_addref(lockh, mode);
 
 	/* Let CP AST to grant the lock first. */
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
-	if (aa->oa_agl && rc == ELDLM_LOCK_ABORTED) {
-		lvb = NULL;
-		lvb_len = 0;
-	} else {
-		lvb = aa->oa_lvb;
-		lvb_len = sizeof(*aa->oa_lvb);
+	if (aa->oa_agl) {
+		LASSERT(!aa->oa_lvb);
+		LASSERT(!aa->oa_flags);
+		aa->oa_flags = &flags;
 	}
 
 	/* Complete obtaining the lock procedure. */
-	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, aa->oa_ei->ei_type, 1,
-				   mode, flags, lvb, lvb_len, &handle, rc);
+	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, aa->oa_type, 1,
+				   aa->oa_mode, aa->oa_flags, lvb, lvb_len,
+				   lockh, rc);
 	/* Complete osc stuff. */
-	rc = osc_enqueue_fini(req, aa->oa_lvb, aa->oa_upcall, aa->oa_cookie,
-			      flags, aa->oa_agl, rc);
+	rc = osc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
+			      aa->oa_flags, aa->oa_agl, rc);
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_CANCEL_RACE, 10);
 
-	/* Release the lock for async request. */
-	if (lustre_handle_is_used(&handle) && rc == ELDLM_OK)
-		/*
-		 * Releases a reference taken by ldlm_cli_enqueue(), if it is
-		 * not already released by
-		 * ldlm_cli_enqueue_fini()->failed_lock_cleanup()
-		 */
-		ldlm_lock_decref(&handle, mode);
-
-	LASSERTF(lock, "lockh %p, req %p, aa %p - client evicted?\n",
-		 aa->oa_lockh, req, aa);
-	ldlm_lock_decref(&handle, mode);
+	ldlm_lock_decref(lockh, mode);
 	LDLM_LOCK_PUT(lock);
 	return rc;
 }
@@ -2222,21 +2208,21 @@ struct ptlrpc_request_set *PTLRPCD_SET = (void *)1;
  * other synchronous requests, however keeping some locks and trying to obtain
  * others may take a considerable amount of time in a case of ost failure; and
  * when other sync requests do not get released lock from a client, the client
- * is excluded from the cluster -- such scenarious make the life difficult, so
+ * is evicted from the cluster -- such scenaries make the life difficult, so
  * release locks just after they are obtained.
  */
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     __u64 *flags, ldlm_policy_data_t *policy,
 		     struct ost_lvb *lvb, int kms_valid,
-		     obd_enqueue_update_f upcall, void *cookie,
+		     osc_enqueue_upcall_f upcall, void *cookie,
 		     struct ldlm_enqueue_info *einfo,
-		     struct lustre_handle *lockh,
 		     struct ptlrpc_request_set *rqset, int async, int agl)
 {
 	struct obd_device *obd = exp->exp_obd;
+	struct lustre_handle lockh = { 0 };
 	struct ptlrpc_request *req = NULL;
 	int intent = *flags & LDLM_FL_HAS_INTENT;
-	__u64 match_lvb = (agl != 0 ? 0 : LDLM_FL_LVB_READY);
+	__u64 match_lvb = agl ? 0 : LDLM_FL_LVB_READY;
 	enum ldlm_mode mode;
 	int rc;
 
@@ -2272,55 +2258,39 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
 	mode = ldlm_lock_match(obd->obd_namespace, *flags | match_lvb, res_id,
-			       einfo->ei_type, policy, mode, lockh, 0);
+			       einfo->ei_type, policy, mode, &lockh, 0);
 	if (mode) {
-		struct ldlm_lock *matched = ldlm_handle2lock(lockh);
+		struct ldlm_lock *matched;
 
-		if ((agl != 0) && !(matched->l_flags & LDLM_FL_LVB_READY)) {
-			/* For AGL, if enqueue RPC is sent but the lock is not
-			 * granted, then skip to process this strpe.
-			 * Return -ECANCELED to tell the caller.
+		if (*flags & LDLM_FL_TEST_LOCK)
+			return ELDLM_OK;
+
+		matched = ldlm_handle2lock(&lockh);
+		if (agl) {
+			/* AGL enqueues DLM locks speculatively. Therefore if
+			 * it already exists a DLM lock, it wll just inform the
+			 * caller to cancel the AGL process for this stripe.
 			 */
-			ldlm_lock_decref(lockh, mode);
+			ldlm_lock_decref(&lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return -ECANCELED;
-		}
-
-		if (osc_set_lock_data_with_check(matched, einfo)) {
+		} else if (osc_set_lock_data_with_check(matched, einfo)) {
 			*flags |= LDLM_FL_LVB_READY;
-			/* addref the lock only if not async requests and PW
-			 * lock is matched whereas we asked for PR.
-			 */
-			if (!rqset && einfo->ei_mode != mode)
-				ldlm_lock_addref(lockh, LCK_PR);
-			if (intent) {
-				/* I would like to be able to ASSERT here that
-				 * rss <= kms, but I can't, for reasons which
-				 * are explained in lov_enqueue()
-				 */
-			}
-
-			/* We already have a lock, and it's referenced.
-			 *
-			 * At this point, the cl_lock::cll_state is CLS_QUEUING,
-			 * AGL upcall may change it to CLS_HELD directly.
-			 */
-			(*upcall)(cookie, ELDLM_OK);
+			/* We already have a lock, and it's referenced. */
+			(*upcall)(cookie, &lockh, ELDLM_LOCK_MATCHED);
 
-			if (einfo->ei_mode != mode)
-				ldlm_lock_decref(lockh, LCK_PW);
-			else if (rqset)
-				/* For async requests, decref the lock. */
-				ldlm_lock_decref(lockh, einfo->ei_mode);
+			ldlm_lock_decref(&lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return ELDLM_OK;
+		} else {
+			ldlm_lock_decref(&lockh, mode);
+			LDLM_LOCK_PUT(matched);
 		}
-
-		ldlm_lock_decref(lockh, mode);
-		LDLM_LOCK_PUT(matched);
 	}
 
- no_match:
+no_match:
+	if (*flags & LDLM_FL_TEST_LOCK)
+		return -ENOLCK;
 	if (intent) {
 		LIST_HEAD(cancels);
 
@@ -2344,21 +2314,31 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	*flags &= ~LDLM_FL_BLOCK_GRANTED;
 
 	rc = ldlm_cli_enqueue(exp, &req, einfo, res_id, policy, flags, lvb,
-			      sizeof(*lvb), LVB_T_OST, lockh, async);
-	if (rqset) {
+			      sizeof(*lvb), LVB_T_OST, &lockh, async);
+	if (async) {
 		if (!rc) {
 			struct osc_enqueue_args *aa;
 
-			CLASSERT (sizeof(*aa) <= sizeof(req->rq_async_args));
+			CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
 			aa = ptlrpc_req_async_args(req);
-			aa->oa_ei = einfo;
 			aa->oa_exp = exp;
-			aa->oa_flags  = flags;
+			aa->oa_mode = einfo->ei_mode;
+			aa->oa_type = einfo->ei_type;
+			lustre_handle_copy(&aa->oa_lockh, &lockh);
 			aa->oa_upcall = upcall;
 			aa->oa_cookie = cookie;
-			aa->oa_lvb    = lvb;
-			aa->oa_lockh  = lockh;
 			aa->oa_agl    = !!agl;
+			if (!agl) {
+				aa->oa_flags = flags;
+				aa->oa_lvb = lvb;
+			} else {
+				/* AGL is essentially to enqueue an DLM lock
+				* in advance, so we don't care about the
+				* result of AGL enqueue.
+				*/
+				aa->oa_lvb = NULL;
+				aa->oa_flags = NULL;
+			}
 
 			req->rq_interpret_reply =
 				(ptlrpc_interpterer_t)osc_enqueue_interpret;
@@ -2372,7 +2352,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		return rc;
 	}
 
-	rc = osc_enqueue_fini(req, lvb, upcall, cookie, flags, agl, rc);
+	rc = osc_enqueue_fini(req, upcall, cookie, &lockh, einfo->ei_mode,
+			      flags, agl, rc);
 	if (intent)
 		ptlrpc_req_finished(req);
 
@@ -3359,7 +3340,6 @@ static struct obd_ops osc_obd_ops = {
 };
 
 extern struct lu_kmem_descr osc_caches[];
-extern spinlock_t osc_ast_guard;
 extern struct lock_class_key osc_ast_guard_class;
 
 static int __init osc_init(void)
@@ -3386,9 +3366,6 @@ static int __init osc_init(void)
 	if (rc)
 		goto out_kmem;
 
-	spin_lock_init(&osc_ast_guard);
-	lockdep_set_class(&osc_ast_guard, &osc_ast_guard_class);
-
 	/* This is obviously too much memory, only prevent overflow here */
 	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
 		rc = -EINVAL;
-- 
2.1.0
