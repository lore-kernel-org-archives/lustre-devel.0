From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:33 -0500
Subject: [lustre-devel] [PATCH 165/622] lustre: ldlm: don't skip bl_ast for
 local lock
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-166-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

During downgrade to COS the lock renews own blocking AST states
and start reprocessing. Any new lock conflict will cause new
blocking AST and related async commit as needed.

For the linux client we can remove server specific code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11102
Lustre-commit: 75a417fa0065 ("LU-11102 ldlm: don't skip bl_ast for local lock")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33458
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lock.c | 130 ++++-----------------------------------------
 1 file changed, 9 insertions(+), 121 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 869d664..b9771ef 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -595,9 +595,15 @@ static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
 		 */
 		if (ldlm_is_ast_discard_data(new))
 			ldlm_set_discard_data(lock);
-		LASSERT(list_empty(&lock->l_bl_ast));
-		list_add(&lock->l_bl_ast, work_list);
-		LDLM_LOCK_GET(lock);
+		/* Lock can be converted from a blocking state back to granted
+		 * after lock convert or COS downgrade but still be in an
+		 * older bl_list because it is controlled only by
+		 * ldlm_work_bl_ast_lock(), let it be processed there.
+		 */
+		if (list_empty(&lock->l_bl_ast)) {
+			list_add(&lock->l_bl_ast, work_list);
+			LDLM_LOCK_GET(lock);
+		}
 		LASSERT(!lock->l_blocking_lock);
 		lock->l_blocking_lock = LDLM_LOCK_GET(new);
 	}
@@ -1624,47 +1630,6 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 }
 
 /**
- * Process a call to blocking AST callback for a lock in ast_work list
- */
-static int
-ldlm_work_bl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_lock_desc d;
-	int rc;
-	struct ldlm_lock *lock;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	lock = list_first_entry(arg->list, struct ldlm_lock, l_bl_ast);
-
-	LASSERT(lock->l_blocking_lock);
-	ldlm_lock2desc(lock->l_blocking_lock, &d);
-	/* copy blocking lock ibits in cancel_bits as well,
-	 * new client may use them for lock convert and it is
-	 * important to use new field to convert locks from
-	 * new servers only
-	 */
-	d.l_policy_data.l_inodebits.cancel_bits =
-		lock->l_blocking_lock->l_policy_data.l_inodebits.bits;
-
-	/* nobody should touch l_bl_ast */
-	lock_res_and_lock(lock);
-	list_del_init(&lock->l_bl_ast);
-
-	LASSERT(ldlm_is_ast_sent(lock));
-	LASSERT(lock->l_bl_ast_run == 0);
-	lock->l_bl_ast_run++;
-	unlock_res_and_lock(lock);
-
-	rc = lock->l_blocking_ast(lock, &d, (void *)arg, LDLM_CB_BLOCKING);
-	LDLM_LOCK_RELEASE(lock);
-
-	return rc;
-}
-
-/**
  * Process a call to completion AST callback for a lock in ast_work list
  */
 static int
@@ -1711,71 +1676,6 @@ enum ldlm_error ldlm_lock_enqueue(const struct lu_env *env,
 }
 
 /**
- * Process a call to revocation AST callback for a lock in ast_work list
- */
-static int
-ldlm_work_revoke_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_lock_desc desc;
-	int rc;
-	struct ldlm_lock *lock;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	lock = list_first_entry(arg->list, struct ldlm_lock, l_rk_ast);
-	list_del_init(&lock->l_rk_ast);
-
-	/* the desc just pretend to exclusive */
-	ldlm_lock2desc(lock, &desc);
-	desc.l_req_mode = LCK_EX;
-	desc.l_granted_mode = 0;
-
-	rc = lock->l_blocking_ast(lock, &desc, (void *)arg, LDLM_CB_BLOCKING);
-	LDLM_LOCK_RELEASE(lock);
-
-	return rc;
-}
-
-/**
- * Process a call to glimpse AST callback for a lock in ast_work list
- */
-static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
-{
-	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_glimpse_work *gl_work;
-	struct ldlm_lock *lock;
-	int rc = 0;
-
-	if (list_empty(arg->list))
-		return -ENOENT;
-
-	gl_work = list_first_entry(arg->list, struct ldlm_glimpse_work,
-				   gl_list);
-	list_del_init(&gl_work->gl_list);
-
-	lock = gl_work->gl_lock;
-
-	/* transfer the glimpse descriptor to ldlm_cb_set_arg */
-	arg->gl_desc = gl_work->gl_desc;
-
-	/* invoke the actual glimpse callback */
-	if (lock->l_glimpse_ast(lock, (void *)arg) == 0)
-		rc = 1;
-
-	LDLM_LOCK_RELEASE(lock);
-
-	if (gl_work->gl_flags & LDLM_GL_WORK_SLAB_ALLOCATED)
-		kmem_cache_free(ldlm_glimpse_work_kmem, gl_work);
-	else
-		kfree(gl_work);
-	gl_work = NULL;
-
-	return rc;
-}
-
-/**
  * Process list of locks in need of ASTs being sent.
  *
  * Used on server to send multiple ASTs together instead of sending one by
@@ -1799,22 +1699,10 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 	arg->list = rpc_list;
 
 	switch (ast_type) {
-	case LDLM_WORK_BL_AST:
-		arg->type = LDLM_BL_CALLBACK;
-		work_ast_lock = ldlm_work_bl_ast_lock;
-		break;
 	case LDLM_WORK_CP_AST:
 		arg->type = LDLM_CP_CALLBACK;
 		work_ast_lock = ldlm_work_cp_ast_lock;
 		break;
-	case LDLM_WORK_REVOKE_AST:
-		arg->type = LDLM_BL_CALLBACK;
-		work_ast_lock = ldlm_work_revoke_ast_lock;
-		break;
-	case LDLM_WORK_GL_AST:
-		arg->type = LDLM_GL_CALLBACK;
-		work_ast_lock = ldlm_work_gl_ast_lock;
-		break;
 	default:
 		LBUG();
 	}
-- 
1.8.3.1
