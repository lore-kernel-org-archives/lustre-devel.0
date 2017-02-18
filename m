From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:06 -0500
Subject: [lustre-devel] [PATCH 05/14] staging: lustre: ldlm: handle ldlm
	lock cancel race when evicting client.
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

A ldlm lock could be canceled simutaneously by ldlm bl thread and
cleanup_resource(). In this case, only one side will win the race
and the other side should wait for the work to complete. Eviction
on group lock is now well supported.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6271
Reviewed-on: http://review.whamcloud.com/16456
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  7 +++-
 .../lustre/lustre/include/lustre_dlm_flags.h       |  3 ++
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 46 ++++++++++++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 14 ++++++-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  1 +
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  2 +
 drivers/staging/lustre/lustre/osc/osc_request.c    | 10 ++++-
 8 files changed, 68 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index e4c0c44..12b3222 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1640,9 +1640,14 @@ enum cl_enq_flags {
 	 */
 	CEF_PEEK	= 0x00000040,
 	/**
+	 * Lock match only. Used by group lock in I/O as group lock
+	 * is known to exist.
+	 */
+	CEF_LOCK_MATCH	= BIT(7),
+	/**
 	 * mask of enq_flags.
 	 */
-	CEF_MASK         = 0x0000007f,
+	CEF_MASK	= 0x000000ff,
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
index a0f064d..11331ae 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
@@ -121,6 +121,9 @@
 #define ldlm_set_test_lock(_l)          LDLM_SET_FLAG((_l), 1ULL << 19)
 #define ldlm_clear_test_lock(_l)        LDLM_CLEAR_FLAG((_l), 1ULL << 19)
 
+/** match lock only */
+#define LDLM_FL_MATCH_LOCK		0x0000000000100000ULL /* bit  20 */
+
 /**
  * Immediately cancel such locks when they block some other locks. Send
  * cancel notification to original lock holder, but expect no reply. This
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 5a94265..16c2a8b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -771,19 +771,11 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 
 	ldlm_lock_decref_internal_nolock(lock, mode);
 
-	if (ldlm_is_local(lock) &&
+	if ((ldlm_is_local(lock) || lock->l_req_mode == LCK_GROUP) &&
 	    !lock->l_readers && !lock->l_writers) {
 		/* If this is a local lock on a server namespace and this was
 		 * the last reference, cancel the lock.
-		 */
-		CDEBUG(D_INFO, "forcing cancel of local lock\n");
-		ldlm_set_cbpending(lock);
-	}
-
-	if (!lock->l_readers && !lock->l_writers &&
-	    (ldlm_is_cbpending(lock) || lock->l_req_mode == LCK_GROUP)) {
-		/* If we received a blocked AST and this was the last reference,
-		 * run the callback.
+		 *
 		 * Group locks are special:
 		 * They must not go in LRU, but they are not called back
 		 * like non-group locks, instead they are manually released.
@@ -791,6 +783,13 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode)
 		 * they are manually released, so we remove them when they have
 		 * no more reader or writer references. - LU-6368
 		 */
+		ldlm_set_cbpending(lock);
+	}
+
+	if (!lock->l_readers && !lock->l_writers && ldlm_is_cbpending(lock)) {
+		/* If we received a blocked AST and this was the last reference,
+		 * run the callback.
+		 */
 		LDLM_DEBUG(lock, "final decref done on cbpending lock");
 
 		LDLM_LOCK_GET(lock); /* dropped by bl thread */
@@ -1882,6 +1881,19 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 	return rc;
 }
 
+static bool is_bl_done(struct ldlm_lock *lock)
+{
+	bool bl_done = true;
+
+	if (!ldlm_is_bl_done(lock)) {
+		lock_res_and_lock(lock);
+		bl_done = ldlm_is_bl_done(lock);
+		unlock_res_and_lock(lock);
+	}
+
+	return bl_done;
+}
+
 /**
  * Helper function to call blocking AST for LDLM lock \a lock in a
  * "cancelling" mode.
@@ -1899,8 +1911,20 @@ void ldlm_cancel_callback(struct ldlm_lock *lock)
 		} else {
 			LDLM_DEBUG(lock, "no blocking ast");
 		}
+		/* only canceller can set bl_done bit */
+		ldlm_set_bl_done(lock);
+		wake_up_all(&lock->l_waitq);
+	} else if (!ldlm_is_bl_done(lock)) {
+		struct l_wait_info lwi = { 0 };
+
+		/*
+		 * The lock is guaranteed to have been canceled once
+		 * returning from this function.
+		 */
+		unlock_res_and_lock(lock);
+		l_wait_event(lock->l_waitq, is_bl_done(lock), &lwi);
+		lock_res_and_lock(lock);
 	}
-	ldlm_set_bl_done(lock);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index ebfda36..84eeaa5 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1029,13 +1029,23 @@ int ldlm_cli_cancel(const struct lustre_handle *lockh,
 	struct ldlm_lock *lock;
 	LIST_HEAD(cancels);
 
-	/* concurrent cancels on the same handle can happen */
-	lock = ldlm_handle2lock_long(lockh, LDLM_FL_CANCELING);
+	lock = ldlm_handle2lock_long(lockh, 0);
 	if (!lock) {
 		LDLM_DEBUG_NOLOCK("lock is already being destroyed");
 		return 0;
 	}
 
+	lock_res_and_lock(lock);
+	/* Lock is being canceled and the caller doesn't want to wait */
+	if (ldlm_is_canceling(lock) && (cancel_flags & LCF_ASYNC)) {
+		unlock_res_and_lock(lock);
+		LDLM_LOCK_RELEASE(lock);
+		return 0;
+	}
+
+	ldlm_set_canceling(lock);
+	unlock_res_and_lock(lock);
+
 	rc = ldlm_cli_cancel_local(lock);
 	if (rc == LDLM_FL_LOCAL_ONLY || cancel_flags & LCF_LOCAL) {
 		LDLM_LOCK_RELEASE(lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index d16f5e9..633f65b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -806,7 +806,7 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 
 		unlock_res(res);
 		ldlm_lock2handle(lock, &lockh);
-		rc = ldlm_cli_cancel(&lockh, LCF_ASYNC);
+		rc = ldlm_cli_cancel(&lockh, LCF_LOCAL);
 		if (rc)
 			CERROR("ldlm_cli_cancel: %d\n", rc);
 		LDLM_LOCK_RELEASE(lock);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 3e9cf71..711126e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -219,6 +219,7 @@ static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 	if (vio->vui_fd && (vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
 		descr->cld_mode = CLM_GROUP;
 		descr->cld_gid  = vio->vui_fd->fd_grouplock.lg_gid;
+		enqflags |= CEF_LOCK_MATCH;
 	} else {
 		descr->cld_mode  = mode;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 5f799a4..efecd92 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -167,6 +167,8 @@ static __u64 osc_enq2ldlm_flags(__u32 enqflags)
 		result |= LDLM_FL_AST_DISCARD_DATA;
 	if (enqflags & CEF_PEEK)
 		result |= LDLM_FL_TEST_LOCK;
+	if (enqflags & CEF_LOCK_MATCH)
+		result |= LDLM_FL_MATCH_LOCK;
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c4cfe18..8e22807 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2011,7 +2011,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	}
 
 no_match:
-	if (*flags & LDLM_FL_TEST_LOCK)
+	if (*flags & (LDLM_FL_TEST_LOCK | LDLM_FL_MATCH_LOCK))
 		return -ENOLCK;
 	if (intent) {
 		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -2495,7 +2495,13 @@ static int osc_ldlm_resource_invalidate(struct cfs_hash *hs,
 			osc = lock->l_ast_data;
 			cl_object_get(osc2cl(osc));
 		}
-		lock->l_ast_data = NULL;
+
+		/*
+		 * clear LDLM_FL_CLEANED flag to make sure it will be canceled
+		 * by the 2nd round of ldlm_namespace_clean() call in
+		 * osc_import_event().
+		 */
+		ldlm_clear_cleaned(lock);
 	}
 	unlock_res(res);
 
-- 
1.8.3.1
