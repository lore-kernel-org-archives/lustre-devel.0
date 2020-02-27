From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:52 -0500
Subject: [lustre-devel] [PATCH 124/622] lustre: ldlm: pass preallocated env
 to methods
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-125-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

to save on env allocation.

Benchmarks made by Shuichi Ihara demonstrated 13% improvement
for small I/Os: 564k vs 639k IOPS. the details can be found at
https://jira.whamcloud.com/browse/LU-11164.

Lustre-commit:e02cb40761ff8 ("LU-11164 ldlm: pass env to lvbo methods")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32832
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  2 +-
 fs/lustre/ldlm/ldlm_internal.h |  3 ++-
 fs/lustre/ldlm/ldlm_lock.c     |  6 ++++--
 fs/lustre/ldlm/ldlm_request.c  |  3 ++-
 fs/lustre/lov/lov_obd.c        |  4 ++--
 fs/lustre/ptlrpc/client.c      | 23 ++++++++++++++++++++---
 fs/lustre/ptlrpc/ptlrpcd.c     |  2 +-
 7 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index cf13555..cbd524c 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1842,7 +1842,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
 					     void *arg);
 int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set);
-int ptlrpc_set_wait(struct ptlrpc_request_set *);
+int ptlrpc_set_wait(const struct lu_env *env, struct ptlrpc_request_set *set);
 void ptlrpc_set_destroy(struct ptlrpc_request_set *);
 void ptlrpc_set_add_req(struct ptlrpc_request_set *, struct ptlrpc_request *);
 #define PTLRPCD_SET ((struct ptlrpc_request_set *)1)
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index ec68713..df57c02 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -137,7 +137,8 @@ struct ldlm_lock *
 		 enum ldlm_type type, enum ldlm_mode mode,
 		 const struct ldlm_callback_suite *cbs,
 		 void *data, u32 lvb_len, enum lvb_type lvb_type);
-enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
+enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
+				  struct ldlm_namespace *ns,
 				  struct ldlm_lock **lock, void *cookie,
 				  u64 *flags);
 void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 4f746ad..bdbbfec 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1578,7 +1578,8 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
  * Does not block. As a result of enqueue the lock would be put
  * into granted or waiting list.
  */
-enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
+enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
+				  struct ldlm_namespace *ns,
 				  struct ldlm_lock **lockp,
 				  void *cookie, u64 *flags)
 {
@@ -1832,7 +1833,7 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		goto out;
 	}
 
-	ptlrpc_set_wait(arg->set);
+	ptlrpc_set_wait(NULL, arg->set);
 	ptlrpc_set_destroy(arg->set);
 
 	rc = atomic_read(&arg->restart) ? -ERESTART : 0;
@@ -1945,6 +1946,7 @@ int ldlm_lock_set_data(const struct lustre_handle *lockh, void *data)
 EXPORT_SYMBOL(ldlm_lock_set_data);
 
 struct export_cl_data {
+	const struct lu_env	*ecl_env;
 	struct obd_export	*ecl_exp;
 	int			ecl_loop;
 };
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index f045d30..9d3330c 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -343,6 +343,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  const struct lustre_handle *lockh, int rc)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
+	const struct lu_env *env = NULL;
 	int is_replay = *flags & LDLM_FL_REPLAY;
 	struct ldlm_lock *lock;
 	struct ldlm_reply *reply;
@@ -487,7 +488,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	}
 
 	if (!is_replay) {
-		rc = ldlm_lock_enqueue(ns, &lock, NULL, flags);
+		rc = ldlm_lock_enqueue(env, ns, &lock, NULL, flags);
 		if (lock->l_completion_ast) {
 			int err = lock->l_completion_ast(lock, *flags, NULL);
 
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 35eaa1f..9a6ffe8 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -948,7 +948,7 @@ static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
 			goto out_set;
 	}
 
-	rc = ptlrpc_set_wait(rqset);
+	rc = ptlrpc_set_wait(env, rqset);
 
 out_set:
 	if (rc < 0)
@@ -1249,7 +1249,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 	lov_tgts_putref(obddev);
 	if (no_set) {
-		err = ptlrpc_set_wait(set);
+		err = ptlrpc_set_wait(env, set);
 		if (rc == 0)
 			rc = err;
 		ptlrpc_set_destroy(set);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 7be597c..fabe675 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2278,9 +2278,10 @@ time64_t ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
  * error or otherwise be interrupted).
  * Returns 0 on success or error code otherwise.
  */
-int ptlrpc_set_wait(struct ptlrpc_request_set *set)
+int ptlrpc_set_wait(const struct lu_env *env, struct ptlrpc_request_set *set)
 {
 	struct ptlrpc_request *req;
+	struct lu_env _env;
 	time64_t timeout;
 	int rc;
 
@@ -2295,6 +2296,19 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 	if (list_empty(&set->set_requests))
 		return 0;
 
+	/* ideally we want env provide by the caller all the time,
+	 * but at the moment that would mean a massive change in
+	 * LDLM while benefits would be close to zero, so just
+	 * initialize env here for those rare cases
+	 */
+	if (!env) {
+		/* XXX: skip on the client side? */
+		rc = lu_env_init(&_env, LCT_DT_THREAD);
+		if (rc)
+			return rc;
+		env = &_env;
+	}
+
 	do {
 		timeout = ptlrpc_set_next_timeout(set);
 
@@ -2313,7 +2327,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			 * so we allow interrupts during the timeout.
 			 */
 			rc = l_wait_event_abortable_timeout(set->set_waitq,
-							    ptlrpc_check_set(NULL, set),
+							    ptlrpc_check_set(env, set),
 							    HZ);
 			if (rc == 0) {
 				rc = -ETIMEDOUT;
@@ -2380,6 +2394,9 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			rc = req->rq_status;
 	}
 
+	if (env && env == &_env)
+		lu_env_fini(&_env);
+
 	return rc;
 }
 EXPORT_SYMBOL(ptlrpc_set_wait);
@@ -2841,7 +2858,7 @@ int ptlrpc_queue_wait(struct ptlrpc_request *req)
 	/* add a ref for the set (see comment in ptlrpc_set_add_req) */
 	ptlrpc_request_addref(req);
 	ptlrpc_set_add_req(set, req);
-	rc = ptlrpc_set_wait(set);
+	rc = ptlrpc_set_wait(NULL, set);
 	ptlrpc_set_destroy(set);
 
 	return rc;
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index c0b091c..e9c03ba 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -469,7 +469,7 @@ static int ptlrpcd(void *arg)
 	 * Wait for inflight requests to drain.
 	 */
 	if (!list_empty(&set->set_requests))
-		ptlrpc_set_wait(set);
+		ptlrpc_set_wait(&env, set);
 	lu_context_fini(&env.le_ctx);
 	lu_context_fini(env.le_ses);
 
-- 
1.8.3.1
