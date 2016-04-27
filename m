From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:57 -0400
Subject: [lustre-devel] [PATCH 05/15] staging: lustre: ldlm: use accessor
	macros for l_flags
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruce Korb <bruce.korb@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Bruce Korb <bruce.korb@gmail.com>

Convert most of the ldlm lock's l_flags references from direct
bit twiddling to using bit specific macros.  A few multi-bit
operations are left as an exercise for the reader.

The changes are mostly in ldlm, but also in llite, osc and quota.
Also add a multi-bit (mask) test.

Signed-off-by: Bruce Korb <bruce.korb@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2906
Reviewed-by: Keith Mannthey <Keith.Mannthey@intel.com>
Reviewed-on: http://review.whamcloud.com/7963
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_dlm_flags.h       |    3 +
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   11 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    7 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   95 ++++++++++----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   26 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   32 +++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   12 ++--
 drivers/staging/lustre/lustre/llite/dcache.c       |    7 +-
 drivers/staging/lustre/lustre/llite/file.c         |    6 +-
 drivers/staging/lustre/lustre/llite/namei.c        |    2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 +-
 13 files changed, 102 insertions(+), 109 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index 7f2ba2f..aff0904 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -381,6 +381,9 @@
 /** test for ldlm_lock flag bit set */
 #define LDLM_TEST_FLAG(_l, _b)        (((_l)->l_flags & (_b)) != 0)
 
+/** multi-bit test: are any of mask bits set? */
+#define LDLM_HAVE_MASK(_l, _m)		((_l)->l_flags & LDLM_FL_##_m##_MASK)
+
 /** set a ldlm_lock flag bit */
 #define LDLM_SET_FLAG(_l, _b)         ((_l)->l_flags |= (_b))
 
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index e5d1344..621323f 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -54,7 +54,7 @@ struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
 
 	lock_res(lock->l_resource);
 
-	lock->l_flags |= LDLM_FL_RES_LOCKED;
+	ldlm_set_res_locked(lock);
 	return lock->l_resource;
 }
 EXPORT_SYMBOL(lock_res_and_lock);
@@ -65,7 +65,7 @@ EXPORT_SYMBOL(lock_res_and_lock);
 void unlock_res_and_lock(struct ldlm_lock *lock)
 {
 	/* on server-side resource of lock doesn't change */
-	lock->l_flags &= ~LDLM_FL_RES_LOCKED;
+	ldlm_clear_res_locked(lock);
 
 	unlock_res(lock->l_resource);
 	spin_unlock(&lock->l_lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index a803e20..cf1f178 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -75,12 +75,12 @@ __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 	 * just after we finish and take our lock into account in its
 	 * calculation of the kms
 	 */
-	lock->l_flags |= LDLM_FL_KMS_IGNORE;
+	ldlm_set_kms_ignore(lock);
 
 	list_for_each(tmp, &res->lr_granted) {
 		lck = list_entry(tmp, struct ldlm_lock, l_res_link);
 
-		if (lck->l_flags & LDLM_FL_KMS_IGNORE)
+		if (ldlm_is_kms_ignore(lck))
 			continue;
 
 		if (lck->l_policy_data.l_extent.end >= old_kms)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 5102d78..349bfcc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -101,8 +101,7 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
 	LASSERT(hlist_unhashed(&lock->l_exp_flock_hash));
 
 	list_del_init(&lock->l_res_link);
-	if (flags == LDLM_FL_WAIT_NOREPROC &&
-	    !(lock->l_flags & LDLM_FL_FAILED)) {
+	if (flags == LDLM_FL_WAIT_NOREPROC && !ldlm_is_failed(lock)) {
 		/* client side - set a flag to prevent sending a CANCEL */
 		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_CBPENDING;
 
@@ -436,7 +435,7 @@ ldlm_flock_interrupted_wait(void *data)
 	lock_res_and_lock(lock);
 
 	/* client side - set flag to prevent lock from being put on LRU list */
-	lock->l_flags |= LDLM_FL_CBPENDING;
+	ldlm_set_cbpending(lock);
 	unlock_res_and_lock(lock);
 }
 
@@ -520,7 +519,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 granted:
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
 
-	if (lock->l_flags & LDLM_FL_FAILED) {
+	if (ldlm_is_failed(lock)) {
 		LDLM_DEBUG(lock, "client-side enqueue waking up: failed");
 		return -EIO;
 	}
@@ -533,7 +532,7 @@ granted:
 	 * Protect against race where lock could have been just destroyed
 	 * due to overlap in ldlm_process_flock_lock().
 	 */
-	if (lock->l_flags & LDLM_FL_DESTROYED) {
+	if (ldlm_is_destroyed(lock)) {
 		unlock_res_and_lock(lock);
 		LDLM_DEBUG(lock, "client-side enqueue waking up: destroyed");
 		return 0;
@@ -542,7 +541,7 @@ granted:
 	/* ldlm_lock_enqueue() has already placed lock on the granted list. */
 	list_del_init(&lock->l_res_link);
 
-	if (lock->l_flags & LDLM_FL_FLOCK_DEADLOCK) {
+	if (ldlm_is_flock_deadlock(lock)) {
 		LDLM_DEBUG(lock, "client-side enqueue deadlock received");
 		rc = -EDEADLK;
 	} else if (flags & LDLM_FL_TEST_LOCK) {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index ba643e6..32f227f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -305,9 +305,10 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 	int ret = 0;
 
 	lock_res_and_lock(lock);
-	if (((lock->l_req_mode == lock->l_granted_mode) &&
-	     !(lock->l_flags & LDLM_FL_CP_REQD)) ||
-	    (lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_CANCEL)))
+	if ((lock->l_req_mode == lock->l_granted_mode) &&
+	     !ldlm_is_cp_reqd(lock))
+		ret = 1;
+	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
 		ret = 1;
 	unlock_res_and_lock(lock);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 6c27b23..bff94ea 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -185,7 +185,7 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 			   "final lock_put on destroyed lock, freeing it.");
 
 		res = lock->l_resource;
-		LASSERT(lock->l_flags & LDLM_FL_DESTROYED);
+		LASSERT(ldlm_is_destroyed(lock));
 		LASSERT(list_empty(&lock->l_res_link));
 		LASSERT(list_empty(&lock->l_pending_chain));
 
@@ -262,8 +262,7 @@ static void ldlm_lock_add_to_lru_nolock(struct ldlm_lock *lock)
 	LASSERT(list_empty(&lock->l_lru));
 	LASSERT(lock->l_resource->lr_type != LDLM_FLOCK);
 	list_add_tail(&lock->l_lru, &ns->ns_unused_list);
-	if (lock->l_flags & LDLM_FL_SKIPPED)
-		lock->l_flags &= ~LDLM_FL_SKIPPED;
+	ldlm_clear_skipped(lock);
 	LASSERT(ns->ns_nr_unused >= 0);
 	ns->ns_nr_unused++;
 }
@@ -328,11 +327,11 @@ static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 		LBUG();
 	}
 
-	if (lock->l_flags & LDLM_FL_DESTROYED) {
+	if (ldlm_is_destroyed(lock)) {
 		LASSERT(list_empty(&lock->l_lru));
 		return 0;
 	}
-	lock->l_flags |= LDLM_FL_DESTROYED;
+	ldlm_set_destroyed(lock);
 
 	if (lock->l_export && lock->l_export->exp_lock_hash) {
 		/* NB: it's safe to call cfs_hash_del() even lock isn't
@@ -554,7 +553,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 	/* It's unlikely but possible that someone marked the lock as
 	 * destroyed after we did handle2object on it
 	 */
-	if (flags == 0 && ((lock->l_flags & LDLM_FL_DESTROYED) == 0)) {
+	if (flags == 0 && !ldlm_is_destroyed(lock)) {
 		lu_ref_add(&lock->l_reference, "handle", current);
 		return lock;
 	}
@@ -564,21 +563,22 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 	LASSERT(lock->l_resource);
 
 	lu_ref_add_atomic(&lock->l_reference, "handle", current);
-	if (unlikely(lock->l_flags & LDLM_FL_DESTROYED)) {
+	if (unlikely(ldlm_is_destroyed(lock))) {
 		unlock_res_and_lock(lock);
 		CDEBUG(D_INFO, "lock already destroyed: lock %p\n", lock);
 		LDLM_LOCK_PUT(lock);
 		return NULL;
 	}
 
-	if (flags && (lock->l_flags & flags)) {
-		unlock_res_and_lock(lock);
-		LDLM_LOCK_PUT(lock);
-		return NULL;
-	}
+	if (flags) {
+		if (lock->l_flags & flags) {
+			unlock_res_and_lock(lock);
+			LDLM_LOCK_PUT(lock);
+			return NULL;
+		}
 
-	if (flags)
 		lock->l_flags |= flags;
+	}
 
 	unlock_res_and_lock(lock);
 	return lock;
@@ -609,14 +609,14 @@ EXPORT_SYMBOL(ldlm_lock2desc);
 static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
 				  struct list_head *work_list)
 {
-	if ((lock->l_flags & LDLM_FL_AST_SENT) == 0) {
+	if (!ldlm_is_ast_sent(lock)) {
 		LDLM_DEBUG(lock, "lock incompatible; sending blocking AST.");
-		lock->l_flags |= LDLM_FL_AST_SENT;
+		ldlm_set_ast_sent(lock);
 		/* If the enqueuing client said so, tell the AST recipient to
 		 * discard dirty data, rather than writing back.
 		 */
-		if (new->l_flags & LDLM_FL_AST_DISCARD_DATA)
-			lock->l_flags |= LDLM_FL_DISCARD_DATA;
+		if (ldlm_is_ast_discard_data(new))
+			ldlm_set_discard_data(lock);
 		LASSERT(list_empty(&lock->l_bl_ast));
 		list_add(&lock->l_bl_ast, work_list);
 		LDLM_LOCK_GET(lock);
@@ -631,8 +631,8 @@ static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
 static void ldlm_add_cp_work_item(struct ldlm_lock *lock,
 				  struct list_head *work_list)
 {
-	if ((lock->l_flags & LDLM_FL_CP_REQD) == 0) {
-		lock->l_flags |= LDLM_FL_CP_REQD;
+	if (!ldlm_is_cp_reqd(lock)) {
+		ldlm_set_cp_reqd(lock);
 		LDLM_DEBUG(lock, "lock granted; sending completion AST.");
 		LASSERT(list_empty(&lock->l_cp_ast));
 		list_add(&lock->l_cp_ast, work_list);
@@ -714,7 +714,7 @@ int ldlm_lock_addref_try(struct lustre_handle *lockh, __u32 mode)
 	if (lock) {
 		lock_res_and_lock(lock);
 		if (lock->l_readers != 0 || lock->l_writers != 0 ||
-		    !(lock->l_flags & LDLM_FL_CBPENDING)) {
+		    !ldlm_is_cbpending(lock)) {
 			ldlm_lock_addref_internal_nolock(lock, mode);
 			result = 0;
 		}
@@ -780,17 +780,17 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 
 	ldlm_lock_decref_internal_nolock(lock, mode);
 
-	if (lock->l_flags & LDLM_FL_LOCAL &&
+	if (ldlm_is_local(lock) &&
 	    !lock->l_readers && !lock->l_writers) {
 		/* If this is a local lock on a server namespace and this was
 		 * the last reference, cancel the lock.
 		 */
 		CDEBUG(D_INFO, "forcing cancel of local lock\n");
-		lock->l_flags |= LDLM_FL_CBPENDING;
+		ldlm_set_cbpending(lock);
 	}
 
 	if (!lock->l_readers && !lock->l_writers &&
-	    (lock->l_flags & LDLM_FL_CBPENDING)) {
+	    ldlm_is_cbpending(lock)) {
 		/* If we received a blocked AST and this was the last reference,
 		 * run the callback.
 		 */
@@ -801,15 +801,14 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 		ldlm_lock_remove_from_lru(lock);
 		unlock_res_and_lock(lock);
 
-		if (lock->l_flags & LDLM_FL_FAIL_LOC)
+		if (ldlm_is_fail_loc(lock))
 			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
-		if ((lock->l_flags & LDLM_FL_ATOMIC_CB) ||
+		if (ldlm_is_atomic_cb(lock) ||
 		    ldlm_bl_to_thread_lock(ns, NULL, lock) != 0)
 			ldlm_handle_bl_callback(ns, NULL, lock);
 	} else if (!lock->l_readers && !lock->l_writers &&
-		   !(lock->l_flags & LDLM_FL_NO_LRU) &&
-		   !(lock->l_flags & LDLM_FL_BL_AST)) {
+		   !ldlm_is_no_lru(lock) && !ldlm_is_bl_ast(lock)) {
 		LDLM_DEBUG(lock, "add lock into lru list");
 
 		/* If this is a client-side namespace and this was the last
@@ -818,7 +817,7 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 		ldlm_lock_add_to_lru(lock);
 		unlock_res_and_lock(lock);
 
-		if (lock->l_flags & LDLM_FL_FAIL_LOC)
+		if (ldlm_is_fail_loc(lock))
 			OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
 		/* Call ldlm_cancel_lru() only if EARLY_CANCEL and LRU RESIZE
@@ -862,7 +861,7 @@ void ldlm_lock_decref_and_cancel(struct lustre_handle *lockh, __u32 mode)
 
 	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
 	lock_res_and_lock(lock);
-	lock->l_flags |= LDLM_FL_CBPENDING;
+	ldlm_set_cbpending(lock);
 	unlock_res_and_lock(lock);
 	ldlm_lock_decref_internal(lock, mode);
 	LDLM_LOCK_PUT(lock);
@@ -980,7 +979,7 @@ static void ldlm_granted_list_add_lock(struct ldlm_lock *lock,
 	ldlm_resource_dump(D_INFO, res);
 	LDLM_DEBUG(lock, "About to add lock:");
 
-	if (lock->l_flags & LDLM_FL_DESTROYED) {
+	if (ldlm_is_destroyed(lock)) {
 		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
 		return;
 	}
@@ -1082,10 +1081,9 @@ static struct ldlm_lock *search_queue(struct list_head *queue,
 		 * whose parents already hold a lock so forward progress
 		 * can still happen.
 		 */
-		if (lock->l_flags & LDLM_FL_CBPENDING &&
-		    !(flags & LDLM_FL_CBPENDING))
+		if (ldlm_is_cbpending(lock) && !(flags & LDLM_FL_CBPENDING))
 			continue;
-		if (!unref && lock->l_flags & LDLM_FL_CBPENDING &&
+		if (!unref && ldlm_is_cbpending(lock) &&
 		    lock->l_readers == 0 && lock->l_writers == 0)
 			continue;
 
@@ -1114,11 +1112,10 @@ static struct ldlm_lock *search_queue(struct list_head *queue,
 		      policy->l_inodebits.bits))
 			continue;
 
-		if (!unref && (lock->l_flags & LDLM_FL_GONE_MASK))
+		if (!unref && LDLM_HAVE_MASK(lock, GONE))
 			continue;
 
-		if ((flags & LDLM_FL_LOCAL_ONLY) &&
-		    !(lock->l_flags & LDLM_FL_LOCAL))
+		if ((flags & LDLM_FL_LOCAL_ONLY) && !ldlm_is_local(lock))
 			continue;
 
 		if (flags & LDLM_FL_TEST_LOCK) {
@@ -1152,7 +1149,7 @@ EXPORT_SYMBOL(ldlm_lock_fail_match_locked);
  */
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock)
 {
-	lock->l_flags |= LDLM_FL_LVB_READY;
+	ldlm_set_lvb_ready(lock);
 	wake_up_all(&lock->l_waitq);
 }
 EXPORT_SYMBOL(ldlm_lock_allow_match_locked);
@@ -1253,8 +1250,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 
 	if (lock) {
 		ldlm_lock2handle(lock, lockh);
-		if ((flags & LDLM_FL_LVB_READY) &&
-		    (!(lock->l_flags & LDLM_FL_LVB_READY))) {
+		if ((flags & LDLM_FL_LVB_READY) && !ldlm_is_lvb_ready(lock)) {
 			__u64 wait_flags = LDLM_FL_LVB_READY |
 				LDLM_FL_DESTROYED | LDLM_FL_FAIL_NOTIFIED;
 			struct l_wait_info lwi;
@@ -1281,7 +1277,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 			l_wait_event(lock->l_waitq,
 				     lock->l_flags & wait_flags,
 				     &lwi);
-			if (!(lock->l_flags & LDLM_FL_LVB_READY)) {
+			if (!ldlm_is_lvb_ready(lock)) {
 				if (flags & LDLM_FL_TEST_LOCK)
 					LDLM_LOCK_RELEASE(lock);
 				else
@@ -1335,10 +1331,10 @@ enum ldlm_mode ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
 	lock = ldlm_handle2lock(lockh);
 	if (lock) {
 		lock_res_and_lock(lock);
-		if (lock->l_flags & LDLM_FL_GONE_MASK)
+		if (LDLM_HAVE_MASK(lock, GONE))
 			goto out;
 
-		if (lock->l_flags & LDLM_FL_CBPENDING &&
+		if (ldlm_is_cbpending(lock) &&
 		    lock->l_readers == 0 && lock->l_writers == 0)
 			goto out;
 
@@ -1552,7 +1548,8 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 	/* Some flags from the enqueue want to make it into the AST, via the
 	 * lock's l_flags.
 	 */
-	lock->l_flags |= *flags & LDLM_FL_AST_DISCARD_DATA;
+	if (*flags & LDLM_FL_AST_DISCARD_DATA)
+		ldlm_set_ast_discard_data(lock);
 
 	/*
 	 * This distinction between local lock trees is very important; a client
@@ -1591,7 +1588,7 @@ ldlm_work_bl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	lock_res_and_lock(lock);
 	list_del_init(&lock->l_bl_ast);
 
-	LASSERT(lock->l_flags & LDLM_FL_AST_SENT);
+	LASSERT(ldlm_is_ast_sent(lock));
 	LASSERT(lock->l_bl_ast_run == 0);
 	LASSERT(lock->l_blocking_lock);
 	lock->l_bl_ast_run++;
@@ -1638,12 +1635,12 @@ ldlm_work_cp_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	/* nobody should touch l_cp_ast */
 	lock_res_and_lock(lock);
 	list_del_init(&lock->l_cp_ast);
-	LASSERT(lock->l_flags & LDLM_FL_CP_REQD);
+	LASSERT(ldlm_is_cp_reqd(lock));
 	/* save l_completion_ast since it can be changed by
 	 * mds_intent_policy(), see bug 14225
 	 */
 	completion_callback = lock->l_completion_ast;
-	lock->l_flags &= ~LDLM_FL_CP_REQD;
+	ldlm_clear_cp_reqd(lock);
 	unlock_res_and_lock(lock);
 
 	if (completion_callback)
@@ -1788,8 +1785,8 @@ out:
 void ldlm_cancel_callback(struct ldlm_lock *lock)
 {
 	check_res_locked(lock->l_resource);
-	if (!(lock->l_flags & LDLM_FL_CANCEL)) {
-		lock->l_flags |= LDLM_FL_CANCEL;
+	if (!ldlm_is_cancel(lock)) {
+		ldlm_set_cancel(lock);
 		if (lock->l_blocking_ast) {
 			unlock_res_and_lock(lock);
 			lock->l_blocking_ast(lock, NULL, lock->l_ast_data,
@@ -1799,7 +1796,7 @@ void ldlm_cancel_callback(struct ldlm_lock *lock)
 			LDLM_DEBUG(lock, "no blocking ast");
 		}
 	}
-	lock->l_flags |= LDLM_FL_BL_DONE;
+	ldlm_set_bl_done(lock);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ebe9042..024185b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -124,10 +124,10 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 	LDLM_DEBUG(lock, "client blocking AST callback handler");
 
 	lock_res_and_lock(lock);
-	lock->l_flags |= LDLM_FL_CBPENDING;
+	ldlm_set_cbpending(lock);
 
-	if (lock->l_flags & LDLM_FL_CANCEL_ON_BLOCK)
-		lock->l_flags |= LDLM_FL_CANCEL;
+	if (ldlm_is_cancel_on_block(lock))
+		ldlm_set_cancel(lock);
 
 	do_ast = !lock->l_readers && !lock->l_writers;
 	unlock_res_and_lock(lock);
@@ -172,7 +172,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 			set_current_state(TASK_INTERRUPTIBLE);
 			schedule_timeout(to);
 			if (lock->l_granted_mode == lock->l_req_mode ||
-			    lock->l_flags & LDLM_FL_DESTROYED)
+			    ldlm_is_destroyed(lock))
 				break;
 		}
 	}
@@ -215,7 +215,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	}
 
 	lock_res_and_lock(lock);
-	if ((lock->l_flags & LDLM_FL_DESTROYED) ||
+	if (ldlm_is_destroyed(lock) ||
 	    lock->l_granted_mode == lock->l_req_mode) {
 		/* bug 11300: the lock has already been granted */
 		unlock_res_and_lock(lock);
@@ -291,7 +291,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 out:
 	if (rc < 0) {
 		lock_res_and_lock(lock);
-		lock->l_flags |= LDLM_FL_FAILED;
+		ldlm_set_failed(lock);
 		unlock_res_and_lock(lock);
 		wake_up(&lock->l_waitq);
 	}
@@ -360,8 +360,7 @@ static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
 	struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
 
 	spin_lock(&blp->blp_lock);
-	if (blwi->blwi_lock &&
-	    blwi->blwi_lock->l_flags & LDLM_FL_DISCARD_DATA) {
+	if (blwi->blwi_lock && ldlm_is_discard_data(blwi->blwi_lock)) {
 		/* add LDLM_FL_DISCARD_DATA requests to the priority list */
 		list_add_tail(&blwi->blwi_entry, &blp->blp_prio_list);
 	} else {
@@ -626,7 +625,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		return 0;
 	}
 
-	if ((lock->l_flags & LDLM_FL_FAIL_LOC) &&
+	if (ldlm_is_fail_loc(lock) &&
 	    lustre_msg_get_opc(req->rq_reqmsg) == LDLM_BL_CALLBACK)
 		OBD_RACE(OBD_FAIL_LDLM_CP_BL_RACE);
 
@@ -640,9 +639,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		 * we can tell the server we have no lock. Otherwise, we
 		 * should send cancel after dropping the cache.
 		 */
-		if (((lock->l_flags & LDLM_FL_CANCELING) &&
-		    (lock->l_flags & LDLM_FL_BL_DONE)) ||
-		    (lock->l_flags & LDLM_FL_FAILED)) {
+		if ((ldlm_is_canceling(lock) && ldlm_is_bl_done(lock)) ||
+		    ldlm_is_failed(lock)) {
 			LDLM_DEBUG(lock, "callback on lock %#llx - lock disappeared\n",
 				   dlm_req->lock_handle[0].cookie);
 			unlock_res_and_lock(lock);
@@ -656,7 +654,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		 * Let ldlm_cancel_lru() be fast.
 		 */
 		ldlm_lock_remove_from_lru(lock);
-		lock->l_flags |= LDLM_FL_BL_AST;
+		ldlm_set_bl_ast(lock);
 	}
 	unlock_res_and_lock(lock);
 
@@ -674,7 +672,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	case LDLM_BL_CALLBACK:
 		CDEBUG(D_INODE, "blocking ast\n");
 		req_capsule_extend(&req->rq_pill, &RQF_LDLM_BL_CALLBACK);
-		if (!(lock->l_flags & LDLM_FL_CANCEL_ON_BLOCK)) {
+		if (!ldlm_is_cancel_on_block(lock)) {
 			rc = ldlm_callback_reply(req, 0);
 			if (req->rq_no_reply || rc)
 				ldlm_callback_errmsg(req, "Normal process", rc,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 861e4be..0e4ab2c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -153,7 +153,7 @@ static int ldlm_completion_tail(struct ldlm_lock *lock)
 	long delay;
 	int  result;
 
-	if (lock->l_flags & (LDLM_FL_DESTROYED | LDLM_FL_FAILED)) {
+	if (ldlm_is_destroyed(lock) || ldlm_is_failed(lock)) {
 		LDLM_DEBUG(lock, "client-side enqueue: destroyed");
 		result = -EIO;
 	} else {
@@ -252,7 +252,7 @@ noreproc:
 
 	lwd.lwd_lock = lock;
 
-	if (lock->l_flags & LDLM_FL_NO_TIMEOUT) {
+	if (ldlm_is_no_timeout(lock)) {
 		LDLM_DEBUG(lock, "waiting indefinitely because of NO_TIMEOUT");
 		lwi = LWI_INTR(interrupted_completion_wait, &lwd);
 	} else {
@@ -269,7 +269,7 @@ noreproc:
 
 	if (OBD_FAIL_CHECK_RESET(OBD_FAIL_LDLM_INTR_CP_AST,
 				 OBD_FAIL_LDLM_CP_BL_RACE | OBD_FAIL_ONCE)) {
-		lock->l_flags |= LDLM_FL_FAIL_LOC;
+		ldlm_set_fail_loc(lock);
 		rc = -EINTR;
 	} else {
 		/* Go to sleep until the lock is granted or cancelled. */
@@ -296,7 +296,7 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 	lock_res_and_lock(lock);
 	/* Check that lock is not granted or failed, we might race. */
 	if ((lock->l_req_mode != lock->l_granted_mode) &&
-	    !(lock->l_flags & LDLM_FL_FAILED)) {
+	    !ldlm_is_failed(lock)) {
 		/* Make sure that this lock will not be found by raced
 		 * bl_ast and -EINVAL reply is sent to server anyways.
 		 * bug 17645
@@ -821,12 +821,11 @@ static __u64 ldlm_cli_cancel_local(struct ldlm_lock *lock)
 		LDLM_DEBUG(lock, "client-side cancel");
 		/* Set this flag to prevent others from getting new references*/
 		lock_res_and_lock(lock);
-		lock->l_flags |= LDLM_FL_CBPENDING;
+		ldlm_set_cbpending(lock);
 		local_only = !!(lock->l_flags &
 				(LDLM_FL_LOCAL_ONLY|LDLM_FL_CANCEL_ON_BLOCK));
 		ldlm_cancel_callback(lock);
-		rc = (lock->l_flags & LDLM_FL_BL_AST) ?
-			LDLM_FL_BL_AST : LDLM_FL_CANCELING;
+		rc = ldlm_is_bl_ast(lock) ? LDLM_FL_BL_AST : LDLM_FL_CANCELING;
 		unlock_res_and_lock(lock);
 
 		if (local_only) {
@@ -1150,7 +1149,7 @@ ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	default:
 		result = LDLM_POLICY_SKIP_LOCK;
 		lock_res_and_lock(lock);
-		lock->l_flags |= LDLM_FL_SKIPPED;
+		ldlm_set_skipped(lock);
 		unlock_res_and_lock(lock);
 		break;
 	}
@@ -1381,9 +1380,9 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		list_for_each_entry_safe(lock, next, &ns->ns_unused_list,
 					     l_lru) {
 			/* No locks which got blocking requests. */
-			LASSERT(!(lock->l_flags & LDLM_FL_BL_AST));
+			LASSERT(!ldlm_is_bl_ast(lock));
 
-			if (no_wait && lock->l_flags & LDLM_FL_SKIPPED)
+			if (no_wait && ldlm_is_skipped(lock))
 				/* already processed */
 				continue;
 
@@ -1394,7 +1393,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			/* Somebody is already doing CANCEL. No need for this
 			 * lock in LRU, do not traverse it again.
 			 */
-			if (!(lock->l_flags & LDLM_FL_CANCELING))
+			if (!ldlm_is_canceling(lock))
 				break;
 
 			ldlm_lock_remove_from_lru_nolock(lock);
@@ -1437,7 +1436,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 		lock_res_and_lock(lock);
 		/* Check flags again under the lock. */
-		if ((lock->l_flags & LDLM_FL_CANCELING) ||
+		if (ldlm_is_canceling(lock) ||
 		    (ldlm_lock_remove_from_lru_check(lock, last_use) == 0)) {
 			/* Another thread is removing lock from LRU, or
 			 * somebody is already doing CANCEL, or there
@@ -1461,7 +1460,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 * where while we are doing cancel here, server is also
 		 * silently cancelling this lock.
 		 */
-		lock->l_flags &= ~LDLM_FL_CANCEL_ON_BLOCK;
+		ldlm_clear_cancel_on_block(lock);
 
 		/* Setting the CBPENDING flag is a little misleading,
 		 * but prevents an important race; namely, once
@@ -1558,8 +1557,7 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 		/* If somebody is already doing CANCEL, or blocking AST came,
 		 * skip this lock.
 		 */
-		if (lock->l_flags & LDLM_FL_BL_AST ||
-		    lock->l_flags & LDLM_FL_CANCELING)
+		if (ldlm_is_bl_ast(lock) || ldlm_is_canceling(lock))
 			continue;
 
 		if (lockmode_compat(lock->l_granted_mode, mode))
@@ -1918,7 +1916,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	int flags;
 
 	/* Bug 11974: Do not replay a lock which is actively being canceled */
-	if (lock->l_flags & LDLM_FL_CANCELING) {
+	if (ldlm_is_canceling(lock)) {
 		LDLM_DEBUG(lock, "Not replaying canceled lock:");
 		return 0;
 	}
@@ -1927,7 +1925,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	 * server might have long dropped it, but notification of that event was
 	 * lost by network. (and server granted conflicting lock already)
 	 */
-	if (lock->l_flags & LDLM_FL_CANCEL_ON_BLOCK) {
+	if (ldlm_is_cancel_on_block(lock)) {
 		LDLM_DEBUG(lock, "Not replaying reply-less lock:");
 		ldlm_lock_cancel(lock);
 		return 0;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 242a664..475fabb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -758,12 +758,12 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 		list_for_each(tmp, q) {
 			lock = list_entry(tmp, struct ldlm_lock,
 					      l_res_link);
-			if (lock->l_flags & LDLM_FL_CLEANED) {
+			if (ldlm_is_cleaned(lock)) {
 				lock = NULL;
 				continue;
 			}
 			LDLM_LOCK_GET(lock);
-			lock->l_flags |= LDLM_FL_CLEANED;
+			ldlm_set_cleaned(lock);
 			break;
 		}
 
@@ -775,13 +775,13 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 		/* Set CBPENDING so nothing in the cancellation path
 		 * can match this lock.
 		 */
-		lock->l_flags |= LDLM_FL_CBPENDING;
-		lock->l_flags |= LDLM_FL_FAILED;
+		ldlm_set_cbpending(lock);
+		ldlm_set_failed(lock);
 		lock->l_flags |= flags;
 
 		/* ... without sending a CANCEL message for local_only. */
 		if (local_only)
-			lock->l_flags |= LDLM_FL_LOCAL_ONLY;
+			ldlm_set_local_only(lock);
 
 		if (local_only && (lock->l_readers || lock->l_writers)) {
 			/* This is a little bit gross, but much better than the
@@ -1275,7 +1275,7 @@ void ldlm_resource_add_lock(struct ldlm_resource *res, struct list_head *head,
 
 	LDLM_DEBUG(lock, "About to add this lock:\n");
 
-	if (lock->l_flags & LDLM_FL_DESTROYED) {
+	if (ldlm_is_destroyed(lock)) {
 		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
 		return;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index dd1c827..5596b13 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -108,11 +108,8 @@ static int ll_dcompare(const struct dentry *parent, const struct dentry *dentry,
 
 static inline int return_if_equal(struct ldlm_lock *lock, void *data)
 {
-	if ((lock->l_flags &
-	     (LDLM_FL_CANCELING | LDLM_FL_DISCARD_DATA)) ==
-	    (LDLM_FL_CANCELING | LDLM_FL_DISCARD_DATA))
-		return LDLM_ITER_CONTINUE;
-	return LDLM_ITER_STOP;
+	return (ldlm_is_canceling(lock) && ldlm_is_discard_data(lock)) ?
+		LDLM_ITER_CONTINUE : LDLM_ITER_STOP;
 }
 
 /* find any ldlm lock of the inode in mdc and lov
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 24fa24b..18e0fec 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3355,10 +3355,10 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	int rc;
 
 	CDEBUG(D_INODE, DFID" LVB_READY=%d l_lvb_data=%p l_lvb_len=%d\n",
-	       PFID(ll_inode2fid(inode)), !!(lock->l_flags & LDLM_FL_LVB_READY),
+	       PFID(ll_inode2fid(inode)), ldlm_is_lvb_ready(lock),
 	       lock->l_lvb_data, lock->l_lvb_len);
 
-	if (lock->l_lvb_data && (lock->l_flags & LDLM_FL_LVB_READY))
+	if (lock->l_lvb_data && ldlm_is_lvb_ready(lock))
 		return 0;
 
 	/* if layout lock was granted right away, the layout is returned
@@ -3442,7 +3442,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	md_set_lock_data(sbi->ll_md_exp, &lockh->cookie, inode, NULL);
 
 	lock_res_and_lock(lock);
-	lvb_ready = !!(lock->l_flags & LDLM_FL_LVB_READY);
+	lvb_ready = ldlm_is_lvb_ready(lock);
 	unlock_res_and_lock(lock);
 	/* checking lvb_ready is racy but this is okay. The worst case is
 	 * that multi processes may configure the file on the same time.
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 9fa862b..cf4ad93 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -190,7 +190,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 			break;
 
 		/* Invalidate all dentries associated with this inode */
-		LASSERT(lock->l_flags & LDLM_FL_CANCELING);
+		LASSERT(ldlm_is_canceling(lock));
 
 		if (!fid_res_name_eq(ll_inode2fid(inode),
 				     &lock->l_resource->lr_name)) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 7ea6489..16f9cd9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -120,7 +120,7 @@ static int osc_lock_invariant(struct osc_lock *ols)
 	 * ast.
 	 */
 	if (!ergo(olock && ols->ols_state < OLS_CANCELLED,
-		  ((olock->l_flags & LDLM_FL_DESTROYED) == 0)))
+		  !ldlm_is_destroyed(olock)))
 		return 0;
 
 	if (!ergo(ols->ols_state == OLS_GRANTED,
-- 
1.7.1
