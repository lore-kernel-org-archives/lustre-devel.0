From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:48 -0400
Subject: [lustre-devel] [PATCH 55/58] staging: lustre: ldlm: flock
	completion fixes.
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-56-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, Andriy Skulysh <andriy.skulysh@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

Move checks for FAILED, DESTROYED flags under ldlm spinlock,
destroy flock atomically with the check it is not destroyed yet.
Do not put the granted flock into the resource if this is
UNLOCK, TEST, or DEADLOCK'ed flock.

Later a regression for this patch was reported under LU-7626.
The refcount nonzero (1) after lock cleanup errors was reported.
The reason is that the case LCK_NL was not handled for obdecho.
Patch 17791 resolved this issue which has been combined into
this upstream patch.

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Signed-off-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2177
Reviewed-by: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Reviewed-by: Andriy Skulysh <andriy_skulysh@xyratex.com>
Reviewed-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Xyratex-bug-id: MRP-1588
Reviewed-on: http://review.whamcloud.com/10005
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7626
Reviewed-by: Mirza Arshad Mirza Hussain <arshad.hussain@seagate.com>
Reviewed-by: Alexey Leonidovich Lyashkov <alexey.lyashkov@seagate.com>
Reviewed-on: http://review.whamcloud.com/17791
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    3 +
 drivers/staging/lustre/lnet/libcfs/fail.c          |    6 +-
 .../lustre/lustre/include/lustre_dlm_flags.h       |   36 ++++---
 .../staging/lustre/lustre/include/obd_support.h    |    4 +
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   98 ++++++++++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   23 ++++-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   16 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 ++-
 drivers/staging/lustre/lustre/llite/file.c         |   20 +++--
 9 files changed, 148 insertions(+), 66 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index d3f9a60..bdbbe93 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -143,6 +143,9 @@ static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
 #define CFS_FAIL_TIMEOUT_ORSET(id, value, secs) \
 	cfs_fail_timeout_set(id, value, secs * 1000, CFS_FAIL_LOC_ORSET)
 
+#define CFS_FAIL_TIMEOUT_RESET(id, value, secs) \
+	cfs_fail_timeout_set(id, value, secs * 1000, CFS_FAIL_LOC_RESET)
+
 #define CFS_FAIL_TIMEOUT_MS_ORSET(id, value, ms) \
 	cfs_fail_timeout_set(id, value, ms, CFS_FAIL_LOC_ORSET)
 
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 9288ee0..e4b1a0a 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -90,8 +90,10 @@ int __cfs_fail_check_set(__u32 id, __u32 value, int set)
 		}
 	}
 
-	if ((set == CFS_FAIL_LOC_ORSET || set == CFS_FAIL_LOC_RESET) &&
-	    (value & CFS_FAIL_ONCE))
+	/* Take into account the current call for FAIL_ONCE for ORSET only,
+	 * as RESET is a new fail_loc, it does not change the current call
+	 */
+	if ((set == CFS_FAIL_LOC_ORSET) && (value & CFS_FAIL_ONCE))
 		set_bit(CFS_FAIL_ONCE_BIT, &cfs_fail_loc);
 	/* Lost race to set CFS_FAILED_BIT. */
 	if (test_and_set_bit(CFS_FAILED_BIT, &cfs_fail_loc)) {
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index e7e0c21..a0f064d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -28,21 +28,6 @@
 /** l_flags bits marked as "all_flags" bits */
 #define LDLM_FL_ALL_FLAGS_MASK          0x00FFFFFFC08F932FULL
 
-/** l_flags bits marked as "ast" bits */
-#define LDLM_FL_AST_MASK                0x0000000080008000ULL
-
-/** l_flags bits marked as "blocked" bits */
-#define LDLM_FL_BLOCKED_MASK            0x000000000000000EULL
-
-/** l_flags bits marked as "gone" bits */
-#define LDLM_FL_GONE_MASK               0x0006004000000000ULL
-
-/** l_flags bits marked as "inherit" bits */
-#define LDLM_FL_INHERIT_MASK            0x0000000000800000ULL
-
-/** l_flags bits marked as "off_wire" bits */
-#define LDLM_FL_OFF_WIRE_MASK           0x00FFFFFF00000000ULL
-
 /** extent, mode, or resource changed */
 #define LDLM_FL_LOCK_CHANGED            0x0000000000000001ULL /* bit 0 */
 #define ldlm_is_lock_changed(_l)        LDLM_TEST_FLAG((_l), 1ULL <<  0)
@@ -372,6 +357,27 @@
 #define ldlm_set_excl(_l)               LDLM_SET_FLAG((_l), 1ULL << 55)
 #define ldlm_clear_excl(_l)             LDLM_CLEAR_FLAG((_l), 1ULL << 55)
 
+/** l_flags bits marked as "ast" bits */
+#define LDLM_FL_AST_MASK		(LDLM_FL_FLOCK_DEADLOCK		|\
+					 LDLM_FL_AST_DISCARD_DATA)
+
+/** l_flags bits marked as "blocked" bits */
+#define LDLM_FL_BLOCKED_MASK		(LDLM_FL_BLOCK_GRANTED		|\
+					 LDLM_FL_BLOCK_CONV		|\
+					 LDLM_FL_BLOCK_WAIT)
+
+/** l_flags bits marked as "gone" bits */
+#define LDLM_FL_GONE_MASK		(LDLM_FL_DESTROYED		|\
+					 LDLM_FL_FAILED)
+
+/** l_flags bits marked as "inherit" bits */
+/* Flags inherited from wire on enqueue/reply between client/server. */
+/* NO_TIMEOUT flag to force ldlm_lock_match() to wait with no timeout. */
+/* TEST_LOCK flag to not let TEST lock to be granted. */
+#define LDLM_FL_INHERIT_MASK		(LDLM_FL_CANCEL_ON_BLOCK	|\
+					 LDLM_FL_NO_TIMEOUT		|\
+					 LDLM_FL_TEST_LOCK)
+
 /** test for ldlm_lock flag bit set */
 #define LDLM_TEST_FLAG(_l, _b)        (((_l)->l_flags & (_b)) != 0)
 
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 71bf844..26fdff6 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -318,6 +318,10 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LDLM_AGL_NOLOCK	 0x31b
 #define OBD_FAIL_LDLM_OST_LVB		 0x31c
 #define OBD_FAIL_LDLM_ENQUEUE_HANG	 0x31d
+#define OBD_FAIL_LDLM_CP_CB_WAIT2	 0x320
+#define OBD_FAIL_LDLM_CP_CB_WAIT3	 0x321
+#define OBD_FAIL_LDLM_CP_CB_WAIT4	 0x322
+#define OBD_FAIL_LDLM_CP_CB_WAIT5	 0x323
 
 /* LOCKLESS IO */
 #define OBD_FAIL_LDLM_SET_CONTENTION     0x385
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index d6b61bc..65e8e14 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -97,7 +97,7 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
 	LASSERT(hlist_unhashed(&lock->l_exp_flock_hash));
 
 	list_del_init(&lock->l_res_link);
-	if (flags == LDLM_FL_WAIT_NOREPROC && !ldlm_is_failed(lock)) {
+	if (flags == LDLM_FL_WAIT_NOREPROC) {
 		/* client side - set a flag to prevent sending a CANCEL */
 		lock->l_flags |= LDLM_FL_LOCAL_ONLY | LDLM_FL_CBPENDING;
 
@@ -455,27 +455,21 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	enum ldlm_error		    err;
 	int			     rc = 0;
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
+		lock_res_and_lock(lock);
+		lock->l_flags |= LDLM_FL_FAIL_LOC;
+		unlock_res_and_lock(lock);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT3, 4);
+	}
 	CDEBUG(D_DLMTRACE, "flags: 0x%llx data: %p getlk: %p\n",
 	       flags, data, getlk);
 
-	/* Import invalidation. We need to actually release the lock
-	 * references being held, so that it can go away. No point in
-	 * holding the lock even if app still believes it has it, since
-	 * server already dropped it anyway. Only for granted locks too.
-	 */
-	if ((lock->l_flags & (LDLM_FL_FAILED|LDLM_FL_LOCAL_ONLY)) ==
-	    (LDLM_FL_FAILED|LDLM_FL_LOCAL_ONLY)) {
-		if (lock->l_req_mode == lock->l_granted_mode &&
-		    lock->l_granted_mode != LCK_NL && !data)
-			ldlm_lock_decref_internal(lock, lock->l_req_mode);
-
-		/* Need to wake up the waiter if we were evicted */
-		wake_up(&lock->l_waitq);
-		return 0;
-	}
-
 	LASSERT(flags != LDLM_FL_WAIT_NOREPROC);
 
+	if (flags & LDLM_FL_FAILED)
+		goto granted;
+
 	if (!(flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED |
 		       LDLM_FL_BLOCK_CONV))) {
 		if (!data)
@@ -514,12 +508,21 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 granted:
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT, 10);
 
-	if (ldlm_is_failed(lock)) {
-		LDLM_DEBUG(lock, "client-side enqueue waking up: failed");
-		return -EIO;
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT4)) {
+		lock_res_and_lock(lock);
+		/* DEADLOCK is always set with CBPENDING */
+		lock->l_flags |= LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
+		unlock_res_and_lock(lock);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT4, 4);
+	}
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT5)) {
+		lock_res_and_lock(lock);
+		/* DEADLOCK is always set with CBPENDING */
+		lock->l_flags |= LDLM_FL_FAIL_LOC |
+				 LDLM_FL_FLOCK_DEADLOCK | LDLM_FL_CBPENDING;
+		unlock_res_and_lock(lock);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT5, 4);
 	}
-
-	LDLM_DEBUG(lock, "client-side enqueue granted");
 
 	lock_res_and_lock(lock);
 
@@ -530,20 +533,59 @@ granted:
 	if (ldlm_is_destroyed(lock)) {
 		unlock_res_and_lock(lock);
 		LDLM_DEBUG(lock, "client-side enqueue waking up: destroyed");
-		return 0;
+		/*
+		 * An error is still to be returned, to propagate it up to
+		 * ldlm_cli_enqueue_fini() caller.
+		 */
+		return -EIO;
 	}
 
 	/* ldlm_lock_enqueue() has already placed lock on the granted list. */
-	list_del_init(&lock->l_res_link);
+	ldlm_resource_unlink_lock(lock);
+
+	/*
+	 * Import invalidation. We need to actually release the lock
+	 * references being held, so that it can go away. No point in
+	 * holding the lock even if app still believes it has it, since
+	 * server already dropped it anyway. Only for granted locks too.
+	 */
+	/* Do the same for DEADLOCK'ed locks. */
+	if (ldlm_is_failed(lock) || ldlm_is_flock_deadlock(lock)) {
+		int mode;
+
+		if (flags & LDLM_FL_TEST_LOCK)
+			LASSERT(ldlm_is_test_lock(lock));
+
+		if (ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
+			mode = getlk->fl_type;
+		else
+			mode = lock->l_granted_mode;
+
+		if (ldlm_is_flock_deadlock(lock)) {
+			LDLM_DEBUG(lock, "client-side enqueue deadlock received");
+			rc = -EDEADLK;
+		}
+		ldlm_flock_destroy(lock, mode, LDLM_FL_WAIT_NOREPROC);
+		unlock_res_and_lock(lock);
+
+		/* Need to wake up the waiter if we were evicted */
+		wake_up(&lock->l_waitq);
+
+		/*
+		 * An error is still to be returned, to propagate it up to
+		 * ldlm_cli_enqueue_fini() caller.
+		 */
+		return rc ? : -EIO;
+	}
+
+	LDLM_DEBUG(lock, "client-side enqueue granted");
 
-	if (ldlm_is_flock_deadlock(lock)) {
-		LDLM_DEBUG(lock, "client-side enqueue deadlock received");
-		rc = -EDEADLK;
-	} else if (flags & LDLM_FL_TEST_LOCK) {
+	if (flags & LDLM_FL_TEST_LOCK) {
 		/* fcntl(F_GETLK) request */
 		/* The old mode was saved in getlk->fl_type so that if the mode
 		 * in the lock changes we can decref the appropriate refcount.
 		 */
+		LASSERT(ldlm_is_test_lock(lock));
 		ldlm_flock_destroy(lock, getlk->fl_type, LDLM_FL_WAIT_NOREPROC);
 		switch (lock->l_granted_mode) {
 		case LCK_PR:
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index a5993f7..1a0fce1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1028,15 +1028,28 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 	check_res_locked(res);
 
 	lock->l_granted_mode = lock->l_req_mode;
+
+	if (work_list && lock->l_completion_ast)
+		ldlm_add_ast_work_item(lock, NULL, work_list);
+
 	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS)
 		ldlm_grant_lock_with_skiplist(lock);
 	else if (res->lr_type == LDLM_EXTENT)
 		ldlm_extent_add_lock(res, lock);
-	else
+	else if (res->lr_type == LDLM_FLOCK) {
+		/*
+		 * We should not add locks to granted list in the following cases:
+		 * - this is an UNLOCK but not a real lock;
+		 * - this is a TEST lock;
+		 * - this is a F_CANCELLK lock (async flock has req_mode == 0)
+		 * - this is a deadlock (flock cannot be granted)
+		 */
+		if (!lock->l_req_mode || lock->l_req_mode == LCK_NL ||
+		    ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
+			return;
 		ldlm_resource_add_lock(res, &res->lr_granted, lock);
-
-	if (work_list && lock->l_completion_ast)
-		ldlm_add_ast_work_item(lock, NULL, work_list);
+	} else
+		LBUG();
 
 	ldlm_pool_add(&ldlm_res_to_ns(res)->ns_pool, lock);
 }
@@ -1546,6 +1559,8 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 	 */
 	if (*flags & LDLM_FL_AST_DISCARD_DATA)
 		ldlm_set_ast_discard_data(lock);
+	if (*flags & LDLM_FL_TEST_LOCK)
+		ldlm_set_test_lock(lock);
 
 	/*
 	 * This distinction between local lock trees is very important; a client
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index af487f9..984a460 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -309,8 +309,6 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 	else
 		LDLM_DEBUG(lock, "lock was granted or failed in race");
 
-	ldlm_lock_decref_internal(lock, mode);
-
 	/* XXX - HACK because we shouldn't call ldlm_lock_destroy()
 	 *       from llite/file.c/ll_file_flock().
 	 */
@@ -321,9 +319,14 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 	 */
 	if (lock->l_resource->lr_type == LDLM_FLOCK) {
 		lock_res_and_lock(lock);
-		ldlm_resource_unlink_lock(lock);
-		ldlm_lock_destroy_nolock(lock);
+		if (!ldlm_is_destroyed(lock)) {
+			ldlm_resource_unlink_lock(lock);
+			ldlm_lock_decref_internal_nolock(lock, mode);
+			ldlm_lock_destroy_nolock(lock);
+		}
 		unlock_res_and_lock(lock);
+	} else {
+		ldlm_lock_decref_internal(lock, mode);
 	}
 }
 
@@ -418,11 +421,6 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	*flags = ldlm_flags_from_wire(reply->lock_flags);
 	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
 					      LDLM_FL_INHERIT_MASK);
-	/* move NO_TIMEOUT flag to the lock to force ldlm_lock_match()
-	 * to wait with no timeout as well
-	 */
-	lock->l_flags |= ldlm_flags_from_wire(reply->lock_flags &
-					      LDLM_FL_NO_TIMEOUT);
 	unlock_res_and_lock(lock);
 
 	CDEBUG(D_INFO, "local: %p, remote cookie: %#llx, flags: 0x%llx\n",
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 51a28d9..5866b00 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -793,8 +793,14 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 			 */
 			unlock_res(res);
 			LDLM_DEBUG(lock, "setting FL_LOCAL_ONLY");
+			if (lock->l_flags & LDLM_FL_FAIL_LOC) {
+				set_current_state(TASK_UNINTERRUPTIBLE);
+				schedule_timeout(cfs_time_seconds(4));
+				set_current_state(TASK_RUNNING);
+			}
 			if (lock->l_completion_ast)
-				lock->l_completion_ast(lock, 0, NULL);
+				lock->l_completion_ast(lock, LDLM_FL_FAILED,
+						       NULL);
 			LDLM_LOCK_RELEASE(lock);
 			continue;
 		}
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 4e483c0..1452a14 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2717,6 +2717,7 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	struct md_op_data *op_data;
 	struct lustre_handle lockh = {0};
 	ldlm_policy_data_t flock = { {0} };
+	int fl_type = file_lock->fl_type;
 	__u64 flags = 0;
 	int rc;
 	int rc2 = 0;
@@ -2747,7 +2748,7 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	if (file_lock->fl_lmops && file_lock->fl_lmops->lm_compare_owner)
 		flock.l_flock.owner = (unsigned long)file_lock->fl_pid;
 
-	switch (file_lock->fl_type) {
+	switch (fl_type) {
 	case F_RDLCK:
 		einfo.ei_mode = LCK_PR;
 		break;
@@ -2767,8 +2768,7 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 		einfo.ei_mode = LCK_PW;
 		break;
 	default:
-		CDEBUG(D_INFO, "Unknown fcntl lock type: %d\n",
-		       file_lock->fl_type);
+		CDEBUG(D_INFO, "Unknown fcntl lock type: %d\n", fl_type);
 		return -ENOTSUPP;
 	}
 
@@ -2790,16 +2790,18 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	case F_GETLK64:
 #endif
 		flags = LDLM_FL_TEST_LOCK;
-		/* Save the old mode so that if the mode in the lock changes we
-		 * can decrement the appropriate reader or writer refcount.
-		 */
-		file_lock->fl_type = einfo.ei_mode;
 		break;
 	default:
 		CERROR("unknown fcntl lock command: %d\n", cmd);
 		return -EINVAL;
 	}
 
+	/*
+	 * Save the old mode so that if the mode in the lock changes we
+	 * can decrement the appropriate reader or writer refcount.
+	 */
+	file_lock->fl_type = einfo.ei_mode;
+
 	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
@@ -2812,6 +2814,10 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, NULL,
 			op_data, &lockh, &flock, 0, NULL /* req */, flags);
 
+	/* Restore the file lock type if not TEST lock. */
+	if (!(flags & LDLM_FL_TEST_LOCK))
+		file_lock->fl_type = fl_type;
+
 	if ((rc == 0 || file_lock->fl_type == F_UNLCK) &&
 	    !(flags & LDLM_FL_TEST_LOCK))
 		rc2  = locks_lock_file_wait(file, file_lock);
-- 
1.7.1
