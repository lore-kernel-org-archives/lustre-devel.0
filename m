From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:40 -0500
Subject: [lustre-devel] [PATCH 232/622] lustre: llite: optimizations for not
 granted lock processing
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-233-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andrew Perepechko <c17827@cray.com>

This patch removes ll_md_blocking_ast() processing for
not granted locks. The reason is ll_invalidate_negative_children()
can slow down I/O significantly without a reason if there
are thousands or millions of files in the directory
cache.

Seagate-bug-id: MRP-3409
WC-bug-id: https://jira.whamcloud.com/browse/LU-8047
Lustre-commit: 2c126c5a73ed ("LU-8047 llite: optimizations for not granted lock processing")
Signed-off-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/19665
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 5 +++++
 fs/lustre/ldlm/ldlm_extent.c   | 2 +-
 fs/lustre/ldlm/ldlm_internal.h | 3 +--
 fs/lustre/ldlm/ldlm_lock.c     | 6 +++---
 fs/lustre/ldlm/ldlm_lockd.c    | 4 ++--
 fs/lustre/ldlm/ldlm_request.c  | 7 +++----
 fs/lustre/llite/namei.c        | 4 ++++
 fs/lustre/osc/osc_lock.c       | 8 ++++----
 fs/lustre/osc/osc_request.c    | 2 +-
 9 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index a95555e..355049f 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -876,6 +876,11 @@ struct ldlm_resource {
 	struct lu_ref			lr_reference;
 };
 
+static inline int ldlm_is_granted(struct ldlm_lock *lock)
+{
+	return lock->l_req_mode == lock->l_granted_mode;
+}
+
 static inline bool ldlm_has_layout(struct ldlm_lock *lock)
 {
 	return lock->l_resource->lr_type == LDLM_IBITS &&
diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 7c72d04..98e2a75 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -151,7 +151,7 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 	struct ldlm_interval_tree *tree;
 	int idx;
 
-	LASSERT(lock->l_granted_mode == lock->l_req_mode);
+	LASSERT(ldlm_is_granted(lock));
 
 	LASSERT(RB_EMPTY_NODE(&lock->l_rb));
 
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index df57c02..ede48b2 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -310,8 +310,7 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 	int ret = 0;
 
 	lock_res_and_lock(lock);
-	if ((lock->l_req_mode == lock->l_granted_mode) &&
-	    !ldlm_is_cp_reqd(lock))
+	if (ldlm_is_granted(lock) && !ldlm_is_cp_reqd(lock))
 		ret = 1;
 	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
 		ret = 1;
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index cc96fbd..b6c49c5 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -992,7 +992,7 @@ void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock)
 {
 	struct sl_insert_point prev;
 
-	LASSERT(lock->l_req_mode == lock->l_granted_mode);
+	LASSERT(ldlm_is_granted(lock));
 
 	search_granted_lock(&lock->l_resource->lr_granted, lock, &prev);
 	ldlm_granted_list_add_lock(lock, &prev);
@@ -1591,7 +1591,7 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 	struct ldlm_resource *res = lock->l_resource;
 
 	lock_res_and_lock(lock);
-	if (lock->l_req_mode == lock->l_granted_mode) {
+	if (ldlm_is_granted(lock)) {
 		/* The server returned a blocked lock, but it was granted
 		 * before we got a chance to actually enqueue it.  We don't
 		 * need to do anything else.
@@ -1799,7 +1799,7 @@ void ldlm_lock_cancel(struct ldlm_lock *lock)
 	ldlm_resource_unlink_lock(lock);
 	ldlm_lock_destroy_nolock(lock);
 
-	if (lock->l_granted_mode == lock->l_req_mode)
+	if (ldlm_is_granted(lock))
 		ldlm_pool_del(&ns->ns_pool, lock);
 
 	/* Make sure we will not be called again for same lock what is possible
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 2985e37..db0da99 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -193,7 +193,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 
 		while (to > 0) {
 			schedule_timeout_interruptible(to);
-			if (lock->l_granted_mode == lock->l_req_mode ||
+			if (ldlm_is_granted(lock) ||
 			    ldlm_is_destroyed(lock))
 				break;
 		}
@@ -236,7 +236,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	}
 
 	if (ldlm_is_destroyed(lock) ||
-	    lock->l_granted_mode == lock->l_req_mode) {
+	    ldlm_is_granted(lock)) {
 		/* bug 11300: the lock has already been granted */
 		unlock_res_and_lock(lock);
 		LDLM_DEBUG(lock, "Double grant race happened");
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index b9e9ae9..7c3935f 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -292,8 +292,7 @@ static void failed_lock_cleanup(struct ldlm_namespace *ns,
 	/* Set a flag to prevent us from sending a CANCEL (bug 407) */
 	lock_res_and_lock(lock);
 	/* Check that lock is not granted or failed, we might race. */
-	if ((lock->l_req_mode != lock->l_granted_mode) &&
-	    !ldlm_is_failed(lock)) {
+	if (!ldlm_is_granted(lock) && !ldlm_is_failed(lock)) {
 		/* Make sure that this lock will not be found by raced
 		 * bl_ast and -EINVAL reply is sent to server anyways.
 		 * bug 17645
@@ -477,7 +476,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		 * a tiny window for completion to get in
 		 */
 		lock_res_and_lock(lock);
-		if (lock->l_req_mode != lock->l_granted_mode)
+		if (!ldlm_is_granted(lock))
 			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
 					   lock->l_lvb_data, lvb_len);
 		unlock_res_and_lock(lock);
@@ -2196,7 +2195,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	 * This happens whenever a lock enqueue is the request that triggers
 	 * recovery.
 	 */
-	if (lock->l_granted_mode == lock->l_req_mode)
+	if (ldlm_is_granted(lock))
 		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_GRANTED;
 	else if (lock->l_granted_mode)
 		flags = LDLM_FL_REPLAY | LDLM_FL_BLOCK_CONV;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 3e3fbd9..e410ff0 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -464,6 +464,10 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		break;
 	}
 	case LDLM_CB_CANCELING:
+		/* Nothing to do for non-granted locks */
+		if (!ldlm_is_granted(lock))
+			break;
+
 		if (ldlm_is_converting(lock)) {
 			/* this is called on already converted lock, so
 			 * ibits has remained bits only and cancel_bits
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index eccea37..29d8373 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -105,7 +105,7 @@ static int osc_lock_invariant(struct osc_lock *ols)
 		return 0;
 
 	if (!ergo(ols->ols_state == OLS_GRANTED,
-		  olock && olock->l_req_mode == olock->l_granted_mode &&
+		  olock && ldlm_is_granted(olock) &&
 		  ols->ols_hold))
 		return 0;
 	return 1;
@@ -227,7 +227,7 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 	/* Lock must have been granted. */
 	lock_res_and_lock(dlmlock);
-	if (dlmlock->l_granted_mode == dlmlock->l_req_mode) {
+	if (ldlm_is_granted(dlmlock)) {
 		struct ldlm_extent *ext = &dlmlock->l_policy_data.l_extent;
 		struct cl_lock_descr *descr = &oscl->ols_cl.cls_lock->cll_descr;
 
@@ -336,7 +336,7 @@ static int osc_lock_upcall_speculative(void *cookie,
 	LASSERT(dlmlock);
 
 	lock_res_and_lock(dlmlock);
-	LASSERT(dlmlock->l_granted_mode == dlmlock->l_req_mode);
+	LASSERT(ldlm_is_granted(dlmlock));
 
 	/* there is no osc_lock associated with speculative lock */
 	osc_lock_lvb_update(env, osc, dlmlock, NULL);
@@ -401,7 +401,7 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 	LASSERT(flag == LDLM_CB_CANCELING);
 
 	lock_res_and_lock(dlmlock);
-	if (dlmlock->l_granted_mode != dlmlock->l_req_mode) {
+	if (!ldlm_is_granted(dlmlock)) {
 		dlmlock->l_ast_data = NULL;
 		unlock_res_and_lock(dlmlock);
 		return 0;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index c55d5a9..7190da9 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3163,7 +3163,7 @@ static int osc_cancel_weight(struct ldlm_lock *lock)
 	 * Cancel all unused and granted extent lock.
 	 */
 	if (lock->l_resource->lr_type == LDLM_EXTENT &&
-	    lock->l_granted_mode == lock->l_req_mode &&
+	    ldlm_is_granted(lock) &&
 	    osc_ldlm_weigh_ast(lock) == 0)
 		return 1;
 
-- 
1.8.3.1
