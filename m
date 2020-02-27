From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:04 -0500
Subject: [lustre-devel] [PATCH 496/622] lustre: osc: wrong cache of LVB attrs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-497-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

osc object keeps the cache of LVB, obtained on lock enqueue, in
lov_oinfo. This cache gets all the modifications happenning on
the client, whereas the original LVB in locks does not get them.
At the same time, this cache is lost on object destroy, which
may appear on layout change in particular.

ldlm locks are left in LRU and could be matched on next operations.
First enqueue does not match a lock in LRU due to @kms_ignore in
enqueue_base, however if the lock will be obtained on a small offset
with some locks existent in LRU on larger offsets, the obtained size
will be cut by the policy region when set to KMS.

2nd enqueue can already match and add stale data to oinfo. Thus the
OSC cache is left with a small KMS. However the logic of preparing
a partial page code checks the KMS to decide if to read a page and
as it is small,the page is not read and therefore the non-read part
of the page is zeroed.

The object destroy detaches dlm locks from osc object, offload the
current osc oinfo cache to all the locks, so that it could be
reconstructed for the next osc oinfo. Introduce per-lock flag to
control the cached attribute status and drop re-enqueue after osc
object replacement.

This patch also fixes the handling of KMS_IGNORE added in LU-11964. It
is used only for skip the self lock in a search there is no other logic
for it and it is not needed for DOM locks at all - all the relevant
semantics is supposed to be accomplished by cbpending flag.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12681
Lustre-commit: 8ac020df4592 ("LU-12681 osc: wrong cache of LVB attrs")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Cray-bug-id: LUS-7731
Reviewed-on: https://review.whamcloud.com/36199
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm_flags.h |  8 ++++++
 fs/lustre/llite/namei.c              |  3 ---
 fs/lustre/mdc/mdc_dev.c              | 47 ++++++++++++++++++++++--------------
 fs/lustre/osc/osc_internal.h         |  3 +--
 fs/lustre/osc/osc_lock.c             | 15 ++++++------
 fs/lustre/osc/osc_object.c           | 24 +++++++++++++++++-
 fs/lustre/osc/osc_request.c          | 15 ++----------
 7 files changed, 70 insertions(+), 45 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index 3d69c49..06337d3 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -399,6 +399,14 @@
 #define ldlm_is_ndelay(_l)		LDLM_TEST_FLAG((_l), 1ULL << 58)
 #define ldlm_set_ndelay(_l)		LDLM_SET_FLAG((_l), 1ULL << 58)
 
+/**
+ * LVB from this lock is cached in osc object
+ */
+#define LDLM_FL_LVB_CACHED              0x0800000000000000ULL /* bit  59 */
+#define ldlm_is_lvb_cached(_l)          LDLM_TEST_FLAG((_l), 1ULL << 59)
+#define ldlm_set_lvb_cached(_l)         LDLM_SET_FLAG((_l), 1ULL << 59)
+#define ldlm_clear_lvb_cached(_l)       LDLM_CLEAR_FLAG((_l), 1ULL << 59)
+
 /** l_flags bits marked as "ast" bits */
 #define LDLM_FL_AST_MASK		(LDLM_FL_FLOCK_DEADLOCK		|\
 					 LDLM_FL_DISCARD_DATA)
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index de01a73..ce72910 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -276,9 +276,6 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 			CDEBUG(D_INODE, "cannot flush DoM data "
 			       DFID": rc = %d\n",
 			       PFID(ll_inode2fid(inode)), rc);
-		lock_res_and_lock(lock);
-		ldlm_set_kms_ignore(lock);
-		unlock_res_and_lock(lock);
 	}
 
 	if (bits & MDS_INODELOCK_LAYOUT) {
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index b49509c..d589f97 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -312,7 +312,6 @@ static int mdc_dlm_blocking_ast0(const struct lu_env *env,
 		dlmlock->l_ast_data = NULL;
 		cl_object_get(obj);
 	}
-	ldlm_set_kms_ignore(dlmlock);
 	unlock_res_and_lock(dlmlock);
 
 	/* if l_ast_data is NULL, the dlmlock was enqueued by AGL or
@@ -432,7 +431,7 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 }
 
 static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
-			     struct lustre_handle *lockh, bool lvb_update)
+			     struct lustre_handle *lockh)
 {
 	struct ldlm_lock *dlmlock;
 
@@ -473,10 +472,11 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 		descr->cld_end = CL_PAGE_EOF;
 
 		/* no lvb update for matched lock */
-		if (lvb_update) {
+		if (!ldlm_is_lvb_cached(dlmlock)) {
 			LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
 			mdc_lock_lvb_update(env, cl2osc(oscl->ols_cl.cls_obj),
 					    dlmlock, NULL);
+			ldlm_set_lvb_cached(dlmlock);
 		}
 	}
 	unlock_res_and_lock(dlmlock);
@@ -514,7 +514,7 @@ static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 
 	CDEBUG(D_INODE, "rc %d, err %d\n", rc, errcode);
 	if (rc == 0)
-		mdc_lock_granted(env, oscl, lockh, errcode == ELDLM_OK);
+		mdc_lock_granted(env, oscl, lockh);
 
 	/* Error handling, some errors are tolerable. */
 	if (oscl->ols_locklessable && rc == -EUSERS) {
@@ -685,10 +685,8 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	 * LVB information, e.g. canceled locks or locks of just pruned object,
 	 * such locks should be skipped.
 	 */
-	mode = ldlm_lock_match_with_skip(obd->obd_namespace, match_flags,
-					 LDLM_FL_KMS_IGNORE, res_id,
-					 einfo->ei_type, policy, mode,
-					 &lockh, 0);
+	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
+			       einfo->ei_type, policy, mode, &lockh, 0);
 	if (mode) {
 		struct ldlm_lock *matched;
 
@@ -696,13 +694,6 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 			return ELDLM_OK;
 
 		matched = ldlm_handle2lock(&lockh);
-		/* this shouldn't happen but this check is kept to make
-		 * related test fail if problem occurs
-		 */
-		if (unlikely(ldlm_is_kms_ignore(matched))) {
-			LDLM_ERROR(matched, "matched lock has KMS ignore flag");
-			goto no_match;
-		}
 
 		if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GLIMPSE_DDOS))
 			ldlm_set_kms_ignore(matched);
@@ -717,7 +708,6 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 			LDLM_LOCK_PUT(matched);
 			return ELDLM_OK;
 		}
-no_match:
 		ldlm_lock_decref(&lockh, mode);
 		LDLM_LOCK_PUT(matched);
 	}
@@ -1362,9 +1352,30 @@ static int mdc_attr_get(const struct lu_env *env, struct cl_object *obj,
 
 static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
 {
-	if (lock->l_ast_data == data)
+	struct osc_object *osc = (struct osc_object *)data;
+	struct ost_lvb *lvb = &lock->l_ost_lvb;
+	struct lov_oinfo *oinfo;
+
+	if (lock->l_ast_data == data) {
 		lock->l_ast_data = NULL;
-	ldlm_set_kms_ignore(lock);
+
+		LASSERT(osc);
+		LASSERT(osc->oo_oinfo);
+		LASSERT(lvb);
+
+		/* Updates lvb in lock by the cached oinfo */
+		oinfo = osc->oo_oinfo;
+		cl_object_attr_lock(&osc->oo_cl);
+		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
+		cl_object_attr_unlock(&osc->oo_cl);
+
+		LDLM_DEBUG(lock,
+			   "update lvb size %llu blocks %llu [cma]time: %llu %llu %llu",
+			   lvb->lvb_size, lvb->lvb_blocks,
+			   lvb->lvb_ctime, lvb->lvb_mtime, lvb->lvb_atime);
+
+		ldlm_clear_lvb_cached(lock);
+	}
 	return LDLM_ITER_CONTINUE;
 }
 
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 6f71d8d..b3b365a 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -54,8 +54,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     u64 *flags, union ldlm_policy_data *policy,
-		     struct ost_lvb *lvb, int kms_valid,
-		     osc_enqueue_upcall_f upcall,
+		     struct ost_lvb *lvb, osc_enqueue_upcall_f upcall,
 		     void *cookie, struct ldlm_enqueue_info *einfo,
 		     struct ptlrpc_request_set *rqset, int async,
 		     bool speculative);
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index dcddf17..02d3436 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -143,9 +143,6 @@ static void osc_lock_build_policy(const struct lu_env *env,
  * with the DLM lock reply from the server. Copy of osc_update_enqueue()
  * logic.
  *
- * This can be optimized to not update attributes when lock is a result of a
- * local match.
- *
  * Called under lock and resource spin-locks.
  */
 static void osc_lock_lvb_update(const struct lu_env *env,
@@ -197,7 +194,7 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 }
 
 static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
-			     struct lustre_handle *lockh, bool lvb_update)
+			     struct lustre_handle *lockh)
 {
 	struct ldlm_lock *dlmlock;
 
@@ -240,10 +237,11 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 		descr->cld_gid = ext->gid;
 
 		/* no lvb update for matched lock */
-		if (lvb_update) {
+		if (!ldlm_is_lvb_cached(dlmlock)) {
 			LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
 			osc_lock_lvb_update(env, cl2osc(oscl->ols_cl.cls_obj),
 					    dlmlock, NULL);
+			ldlm_set_lvb_cached(dlmlock);
 		}
 		LINVRNT(osc_lock_invariant(oscl));
 	}
@@ -281,7 +279,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	}
 
 	if (rc == 0)
-		osc_lock_granted(env, oscl, lockh, errcode == ELDLM_OK);
+		osc_lock_granted(env, oscl, lockh);
 
 	/* Error handling, some errors are tolerable. */
 	if (oscl->ols_locklessable && rc == -EUSERS) {
@@ -338,7 +336,9 @@ static int osc_lock_upcall_speculative(void *cookie,
 	lock_res_and_lock(dlmlock);
 	LASSERT(ldlm_is_granted(dlmlock));
 
-	/* there is no osc_lock associated with speculative lock */
+	/* there is no osc_lock associated with speculative lock
+	 * thus no need to set LDLM_FL_LVB_CACHED
+	 */
 	osc_lock_lvb_update(env, osc, dlmlock, NULL);
 
 	unlock_res_and_lock(dlmlock);
@@ -1022,7 +1022,6 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	}
 	result = osc_enqueue_base(exp, resname, &oscl->ols_flags,
 				  policy, &oscl->ols_lvb,
-				  osc->oo_oinfo->loi_kms_valid,
 				  upcall, cookie,
 				  &oscl->ols_einfo, PTLRPCD_SET, async,
 				  oscl->ols_speculative);
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index fdee8fa..d2206e8 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -196,8 +196,30 @@ int osc_object_glimpse(const struct lu_env *env,
 
 static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 {
-	if (lock->l_ast_data == data)
+	struct osc_object *osc = (struct osc_object *)data;
+	struct ost_lvb *lvb = lock->l_lvb_data;
+	struct lov_oinfo *oinfo;
+
+	if (lock->l_ast_data == data) {
 		lock->l_ast_data = NULL;
+
+		LASSERT(osc);
+		LASSERT(osc->oo_oinfo);
+		LASSERT(lvb);
+
+		/* Updates lvb in lock by the cached oinfo */
+		oinfo = osc->oo_oinfo;
+		cl_object_attr_lock(&osc->oo_cl);
+		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
+		cl_object_attr_unlock(&osc->oo_cl);
+
+		LDLM_DEBUG(lock,
+			   "update lvb size %llu blocks %llu [cma]time: %llu %llu %llu",
+			   lvb->lvb_size, lvb->lvb_blocks,
+			   lvb->lvb_ctime, lvb->lvb_mtime, lvb->lvb_atime);
+
+		ldlm_clear_lvb_cached(lock);
+	}
 	return LDLM_ITER_CONTINUE;
 }
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 7ba9ea5..0e32496 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2496,9 +2496,8 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
  */
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     u64 *flags, union ldlm_policy_data *policy,
-		     struct ost_lvb *lvb, int kms_valid,
-		     osc_enqueue_upcall_f upcall, void *cookie,
-		     struct ldlm_enqueue_info *einfo,
+		     struct ost_lvb *lvb, osc_enqueue_upcall_f upcall,
+		     void *cookie, struct ldlm_enqueue_info *einfo,
 		     struct ptlrpc_request_set *rqset, int async,
 		     bool speculative)
 {
@@ -2516,15 +2515,6 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	policy->l_extent.start -= policy->l_extent.start & ~PAGE_MASK;
 	policy->l_extent.end |= ~PAGE_MASK;
 
-	/*
-	 * kms is not valid when either object is completely fresh (so that no
-	 * locks are cached), or object was evicted. In the latter case cached
-	 * lock cannot be used, because it would prime inode state with
-	 * potentially stale LVB.
-	 */
-	if (!kms_valid)
-		goto no_match;
-
 	/* Next, search for already existing extent locks that will cover us */
 	/* If we're trying to read, we also search for an existing PW lock.  The
 	 * VFS and page cache already protect us locally, so lots of readers/
@@ -2589,7 +2579,6 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		LDLM_LOCK_PUT(matched);
 	}
 
-no_match:
 	if (*flags & (LDLM_FL_TEST_LOCK | LDLM_FL_MATCH_LOCK))
 		return -ENOLCK;
 	if (intent) {
-- 
1.8.3.1
