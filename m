From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:52 -0400
Subject: [lustre-devel] [PATCH 20/43] staging/lustre: update comments after
	cl_lock simplification
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-21-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bobi Jam <bobijam.xu@intel.com>

Update comments to reflect current cl_lock situations.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reviewed-on: http://review.whamcloud.com/13137
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6046
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  | 130 +++------------------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  13 ---
 2 files changed, 19 insertions(+), 124 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 8f9512e..e613007 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1117,111 +1117,29 @@ static inline struct page *cl_page_vmpage(struct cl_page *page)
  *
  * LIFE CYCLE
  *
- * cl_lock is reference counted. When reference counter drops to 0, lock is
- * placed in the cache, except when lock is in CLS_FREEING state. CLS_FREEING
- * lock is destroyed when last reference is released. Referencing between
- * top-lock and its sub-locks is described in the lov documentation module.
- *
- * STATE MACHINE
- *
- * Also, cl_lock is a state machine. This requires some clarification. One of
- * the goals of client IO re-write was to make IO path non-blocking, or at
- * least to make it easier to make it non-blocking in the future. Here
- * `non-blocking' means that when a system call (read, write, truncate)
- * reaches a situation where it has to wait for a communication with the
- * server, it should --instead of waiting-- remember its current state and
- * switch to some other work.  E.g,. instead of waiting for a lock enqueue,
- * client should proceed doing IO on the next stripe, etc. Obviously this is
- * rather radical redesign, and it is not planned to be fully implemented at
- * this time, instead we are putting some infrastructure in place, that would
- * make it easier to do asynchronous non-blocking IO easier in the
- * future. Specifically, where old locking code goes to sleep (waiting for
- * enqueue, for example), new code returns cl_lock_transition::CLO_WAIT. When
- * enqueue reply comes, its completion handler signals that lock state-machine
- * is ready to transit to the next state. There is some generic code in
- * cl_lock.c that sleeps, waiting for these signals. As a result, for users of
- * this cl_lock.c code, it looks like locking is done in normal blocking
- * fashion, and it the same time it is possible to switch to the non-blocking
- * locking (simply by returning cl_lock_transition::CLO_WAIT from cl_lock.c
- * functions).
- *
- * For a description of state machine states and transitions see enum
- * cl_lock_state.
- *
- * There are two ways to restrict a set of states which lock might move to:
- *
- *     - placing a "hold" on a lock guarantees that lock will not be moved
- *       into cl_lock_state::CLS_FREEING state until hold is released. Hold
- *       can be only acquired on a lock that is not in
- *       cl_lock_state::CLS_FREEING. All holds on a lock are counted in
- *       cl_lock::cll_holds. Hold protects lock from cancellation and
- *       destruction. Requests to cancel and destroy a lock on hold will be
- *       recorded, but only honored when last hold on a lock is released;
- *
- *     - placing a "user" on a lock guarantees that lock will not leave
- *       cl_lock_state::CLS_NEW, cl_lock_state::CLS_QUEUING,
- *       cl_lock_state::CLS_ENQUEUED and cl_lock_state::CLS_HELD set of
- *       states, once it enters this set. That is, if a user is added onto a
- *       lock in a state not from this set, it doesn't immediately enforce
- *       lock to move to this set, but once lock enters this set it will
- *       remain there until all users are removed. Lock users are counted in
- *       cl_lock::cll_users.
- *
- *       User is used to assure that lock is not canceled or destroyed while
- *       it is being enqueued, or actively used by some IO.
- *
- *       Currently, a user always comes with a hold (cl_lock_invariant()
- *       checks that a number of holds is not less than a number of users).
- *
- * CONCURRENCY
- *
- * This is how lock state-machine operates. struct cl_lock contains a mutex
- * cl_lock::cll_guard that protects struct fields.
- *
- *     - mutex is taken, and cl_lock::cll_state is examined.
- *
- *     - for every state there are possible target states where lock can move
- *       into. They are tried in order. Attempts to move into next state are
- *       done by _try() functions in cl_lock.c:cl_{enqueue,unlock,wait}_try().
- *
- *     - if the transition can be performed immediately, state is changed,
- *       and mutex is released.
- *
- *     - if the transition requires blocking, _try() function returns
- *       cl_lock_transition::CLO_WAIT. Caller unlocks mutex and goes to
- *       sleep, waiting for possibility of lock state change. It is woken
- *       up when some event occurs, that makes lock state change possible
- *       (e.g., the reception of the reply from the server), and repeats
- *       the loop.
- *
- * Top-lock and sub-lock has separate mutexes and the latter has to be taken
- * first to avoid dead-lock.
- *
- * To see an example of interaction of all these issues, take a look at the
- * lov_cl.c:lov_lock_enqueue() function. It is called as a part of
- * cl_enqueue_try(), and tries to advance top-lock to ENQUEUED state, by
- * advancing state-machines of its sub-locks (lov_lock_enqueue_one()). Note
- * also, that it uses trylock to grab sub-lock mutex to avoid dead-lock. It
- * also has to handle CEF_ASYNC enqueue, when sub-locks enqueues have to be
- * done in parallel, rather than one after another (this is used for glimpse
- * locks, that cannot dead-lock).
+ * cl_lock is a cacheless data container for the requirements of locks to
+ * complete the IO. cl_lock is created before I/O starts and destroyed when the
+ * I/O is complete.
+ *
+ * cl_lock depends on LDLM lock to fulfill lock semantics. LDLM lock is attached
+ * to cl_lock at OSC layer. LDLM lock is still cacheable.
  *
  * INTERFACE AND USAGE
  *
- * struct cl_lock_operations provide a number of call-backs that are invoked
- * when events of interest occurs. Layers can intercept and handle glimpse,
- * blocking, cancel ASTs and a reception of the reply from the server.
+ * Two major methods are supported for cl_lock: clo_enqueue and clo_cancel.  A
+ * cl_lock is enqueued by cl_lock_request(), which will call clo_enqueue()
+ * methods for each layer to enqueue the lock. At the LOV layer, if a cl_lock
+ * consists of multiple sub cl_locks, each sub locks will be enqueued
+ * correspondingly. At OSC layer, the lock enqueue request will tend to reuse
+ * cached LDLM lock; otherwise a new LDLM lock will have to be requested from
+ * OST side.
  *
- * One important difference with the old client locking model is that new
- * client has a representation for the top-lock, whereas in the old code only
- * sub-locks existed as real data structures and file-level locks are
- * represented by "request sets" that are created and destroyed on each and
- * every lock creation.
+ * cl_lock_cancel() must be called to release a cl_lock after use. clo_cancel()
+ * method will be called for each layer to release the resource held by this
+ * lock. At OSC layer, the reference count of LDLM lock, which is held at
+ * clo_enqueue time, is released.
  *
- * Top-locks are cached, and can be found in the cache by the system calls. It
- * is possible that top-lock is in cache, but some of its sub-locks were
- * canceled and destroyed. In that case top-lock has to be enqueued again
- * before it can be used.
+ * LDLM lock can only be canceled if there is no cl_lock using it.
  *
  * Overall process of the locking during IO operation is as following:
  *
@@ -1234,7 +1152,7 @@ static inline struct page *cl_page_vmpage(struct cl_page *page)
  *
  *     - when all locks are acquired, IO is performed;
  *
- *     - locks are released into cache.
+ *     - locks are released after IO is complete.
  *
  * Striping introduces major additional complexity into locking. The
  * fundamental problem is that it is generally unsafe to actively use (hold)
@@ -1256,16 +1174,6 @@ static inline struct page *cl_page_vmpage(struct cl_page *page)
  * buf is a part of memory mapped Lustre file, a lock or locks protecting buf
  * has to be held together with the usual lock on [offset, offset + count].
  *
- * As multi-stripe locks have to be allowed, it makes sense to cache them, so
- * that, for example, a sequence of O_APPEND writes can proceed quickly
- * without going down to the individual stripes to do lock matching. On the
- * other hand, multi-stripe locks shouldn't be used by normal read/write
- * calls. To achieve this, every layer can implement ->clo_fits_into() method,
- * that is called by lock matching code (cl_lock_lookup()), and that can be
- * used to selectively disable matching of certain locks for certain IOs. For
- * example, lov layer implements lov_lock_fits_into() that allow multi-stripe
- * locks to be matched only for truncates and O_APPEND writes.
- *
  * Interaction with DLM
  *
  * In the expected setup, cl_lock is ultimately backed up by a collection of
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index dfe41a8..ac9744e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -73,19 +73,6 @@
  *     - top-page keeps a reference to its sub-page, and destroys it when it
  *       is destroyed.
  *
- *     - sub-lock keep a reference to its top-locks. Top-lock keeps a
- *       reference (and a hold, see cl_lock_hold()) on its sub-locks when it
- *       actively using them (that is, in cl_lock_state::CLS_QUEUING,
- *       cl_lock_state::CLS_ENQUEUED, cl_lock_state::CLS_HELD states). When
- *       moving into cl_lock_state::CLS_CACHED state, top-lock releases a
- *       hold. From this moment top-lock has only a 'weak' reference to its
- *       sub-locks. This reference is protected by top-lock
- *       cl_lock::cll_guard, and will be automatically cleared by the sub-lock
- *       when the latter is destroyed. When a sub-lock is canceled, a
- *       reference to it is removed from the top-lock array, and top-lock is
- *       moved into CLS_NEW state. It is guaranteed that all sub-locks exist
- *       while their top-lock is in CLS_HELD or CLS_CACHED states.
- *
  *     - IO's are not reference counted.
  *
  * To implement a connection between top and sub entities, lov layer is split
-- 
2.1.0
