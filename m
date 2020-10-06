From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:07 -0400
Subject: [lustre-devel] [PATCH 28/42] lustre: ldlm: don't use a locks
 without l_ast_data
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

Partially initialized lock (without l_ast_data to be init)
caused a fail with blocking ast, as discard from page cache
skipped, and stale data will read later with fast read.
Slow read have chance to attach this lock to right IO, but
it don?t true always, so that should disabled, until lock
will have l_ast_data set always for DoM and Lock Ahead locks.

HPE-bugid: LUS-8750
WC-bug-id: https://jira.whamcloud.com/browse/LU-13645
Lustre-commit: a6798c5806088d ("LU-13645 ldlm: don't use a locks without l_ast_data")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/39318
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 17 +++++++++++------
 fs/lustre/include/lustre_osc.h |  4 ++++
 fs/lustre/ldlm/ldlm_lock.c     | 15 ++++++++-------
 fs/lustre/mdc/mdc_dev.c        | 22 +++++++++++++++-------
 fs/lustre/mdc/mdc_locks.c      |  5 ++---
 fs/lustre/osc/osc_cache.c      |  2 +-
 fs/lustre/osc/osc_internal.h   |  3 ++-
 fs/lustre/osc/osc_lock.c       | 12 +++++++++---
 fs/lustre/osc/osc_object.c     |  2 +-
 fs/lustre/osc/osc_request.c    | 11 +++++++----
 10 files changed, 60 insertions(+), 33 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index e2a7b6b..871d4ff 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -821,6 +821,12 @@ struct ldlm_lock {
 #endif
 };
 
+enum ldlm_match_flags {
+	LDLM_MATCH_UNREF	= BIT(0),
+	LDLM_MATCH_AST		= BIT(1),
+	LDLM_MATCH_AST_ANY	= BIT(2),
+};
+
 /**
  * Describe the overlap between two locks.  itree_overlap_cb data.
  */
@@ -831,8 +837,7 @@ struct ldlm_match_data {
 	union ldlm_policy_data	*lmd_policy;
 	u64			 lmd_flags;
 	u64			 lmd_skip_flags;
-	int			 lmd_unref;
-	bool			 lmd_has_ast_data;
+	enum ldlm_match_flags	 lmd_match;
 };
 
 /**
@@ -1172,6 +1177,7 @@ void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
+
 enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 					 u64 flags, u64 skip_flags,
 					 const struct ldlm_res_id *res_id,
@@ -1179,18 +1185,17 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 					 union ldlm_policy_data *policy,
 					 enum ldlm_mode mode,
 					 struct lustre_handle *lh,
-					 int unref);
+					 enum ldlm_match_flags match_flags);
 static inline enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns,
 					     u64 flags,
 					     const struct ldlm_res_id *res_id,
 					     enum ldlm_type type,
 					     union ldlm_policy_data *policy,
 					     enum ldlm_mode mode,
-					     struct lustre_handle *lh,
-					     int unref)
+					     struct lustre_handle *lh)
 {
 	return ldlm_lock_match_with_skip(ns, flags, 0, res_id, type, policy,
-					 mode, lh, unref);
+					 mode, lh, 0);
 }
 struct ldlm_lock *search_itree(struct ldlm_resource *res,
 			       struct ldlm_match_data *data);
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 3956ab4..24cfec8 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -244,6 +244,10 @@ enum osc_dap_flags {
 	 * Return the lock even if it is being canceled.
 	 */
 	OSC_DAP_FL_CANCELING = BIT(1),
+	/**
+	 * check ast data is present, requested to cancel cb
+	 */
+	OSC_DAP_FL_AST	     = BIT(2),
 };
 
 /*
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 7fda7b8..f5dedc9 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1074,7 +1074,7 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	    !(data->lmd_flags & LDLM_FL_CBPENDING))
 		return false;
 
-	if (!data->lmd_unref && ldlm_is_cbpending(lock) &&
+	if (!(data->lmd_match & LDLM_MATCH_UNREF) && ldlm_is_cbpending(lock) &&
 	    !lock->l_readers && !lock->l_writers)
 		return false;
 
@@ -1084,11 +1084,12 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	/* When we search for ast_data, we are not doing a traditional match,
 	 * so we don't worry about IBITS or extent matching.
 	 */
-	if (data->lmd_has_ast_data) {
+	if (data->lmd_match & (LDLM_MATCH_AST | LDLM_MATCH_AST_ANY)) {
 		if (!lock->l_ast_data)
 			return false;
 
-		goto matched;
+		if (data->lmd_match & LDLM_MATCH_AST_ANY)
+			goto matched;
 	}
 
 	match = lock->l_req_mode;
@@ -1121,7 +1122,7 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	 * We match if we have existing lock with same or wider set
 	 * of bits.
 	 */
-	if (!data->lmd_unref && LDLM_HAVE_MASK(lock, GONE))
+	if (!(data->lmd_match & LDLM_MATCH_UNREF) && LDLM_HAVE_MASK(lock, GONE))
 		return false;
 
 	if (!equi(data->lmd_flags & LDLM_FL_LOCAL_ONLY, ldlm_is_local(lock)))
@@ -1273,7 +1274,8 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 					 enum ldlm_type type,
 					 union ldlm_policy_data *policy,
 					 enum ldlm_mode mode,
-					 struct lustre_handle *lockh, int unref)
+					 struct lustre_handle *lockh,
+					 enum ldlm_match_flags match_flags)
 {
 	struct ldlm_match_data data = {
 		.lmd_old	= NULL,
@@ -1282,8 +1284,7 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 		.lmd_policy	= policy,
 		.lmd_flags	= flags,
 		.lmd_skip_flags	= skip_flags,
-		.lmd_unref	= unref,
-		.lmd_has_ast_data = false,
+		.lmd_match	= match_flags,
 	};
 	struct ldlm_resource *res;
 	struct ldlm_lock *lock;
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index d6d98ae..329371b 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -92,14 +92,16 @@ int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
 		       struct ldlm_res_id *res_id, enum ldlm_type type,
 		       union ldlm_policy_data *policy, enum ldlm_mode mode,
 		       u64 *flags, struct osc_object *obj,
-		       struct lustre_handle *lockh, int unref)
+		       struct lustre_handle *lockh,
+		       enum ldlm_match_flags match_flags)
 {
 	struct obd_device *obd = exp->exp_obd;
 	u64 lflags = *flags;
 	enum ldlm_mode rc;
 
-	rc = ldlm_lock_match(obd->obd_namespace, lflags,
-			     res_id, type, policy, mode, lockh, unref);
+	rc = ldlm_lock_match_with_skip(obd->obd_namespace, lflags, 0,
+				       res_id, type, policy, mode, lockh,
+				       match_flags);
 	if (rc == 0 || lflags & LDLM_FL_TEST_LOCK)
 		return rc;
 
@@ -139,6 +141,7 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
 	struct ldlm_lock *lock = NULL;
 	enum ldlm_mode mode;
 	u64 flags;
+	enum ldlm_match_flags match_flags = 0;
 
 	fid_build_reg_res_name(lu_object_fid(osc2lu(obj)), resname);
 	mdc_lock_build_policy(env, policy);
@@ -147,6 +150,12 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
 	if (dap_flags & OSC_DAP_FL_TEST_LOCK)
 		flags |= LDLM_FL_TEST_LOCK;
 
+	if (dap_flags & OSC_DAP_FL_AST)
+		match_flags |= LDLM_MATCH_AST;
+
+	if (dap_flags & OSC_DAP_FL_CANCELING)
+		match_flags |= LDLM_MATCH_UNREF;
+
 again:
 	/* Next, search for already existing extent locks that will cover us */
 	/* If we're trying to read, we also search for an existing PW lock.  The
@@ -155,8 +164,7 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
 	 */
 	mode = mdc_dom_lock_match(env, osc_export(obj), resname, LDLM_IBITS,
 				  policy, LCK_PR | LCK_PW | LCK_GROUP, &flags,
-				  obj, &lockh,
-				  dap_flags & OSC_DAP_FL_CANCELING);
+				  obj, &lockh, match_flags);
 	if (mode) {
 		lock = ldlm_handle2lock(&lockh);
 		/* RACE: the lock is cancelled so let's try again */
@@ -184,7 +192,7 @@ static bool mdc_check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 
 		/* refresh non-overlapped index */
 		tmp = mdc_dlmlock_at_pgoff(env, osc, index,
-					   OSC_DAP_FL_TEST_LOCK);
+					   OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_AST);
 		if (tmp) {
 			info->oti_fn_index = CL_PAGE_EOF;
 			LDLM_LOCK_PUT(tmp);
@@ -692,7 +700,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	 * such locks should be skipped.
 	 */
 	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
-			       einfo->ei_type, policy, mode, &lockh, 0);
+			       einfo->ei_type, policy, mode, &lockh);
 	if (mode) {
 		struct ldlm_lock *matched;
 
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 2d623ff..72ee070 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -146,7 +146,7 @@ enum ldlm_mode mdc_lock_match(struct obd_export *exp, u64 flags,
 	/* LU-4405: Clear bits not supported by server */
 	policy->l_inodebits.bits &= exp_connect_ibits(exp);
 	rc = ldlm_lock_match(class_exp2obd(exp)->obd_namespace, flags,
-			     &res_id, type, policy, mode, lockh, 0);
+			     &res_id, type, policy, mode, lockh);
 	return rc;
 }
 
@@ -1185,8 +1185,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 
 		memcpy(&old_lock, lockh, sizeof(*lockh));
 		if (ldlm_lock_match(NULL, LDLM_FL_BLOCK_GRANTED, NULL,
-				    LDLM_IBITS, &policy, LCK_NL,
-				    &old_lock, 0)) {
+				    LDLM_IBITS, &policy, LCK_NL, &old_lock)) {
 			ldlm_lock_decref_and_cancel(lockh,
 						    it->it_lock_mode);
 			memcpy(lockh, &old_lock, sizeof(old_lock));
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index c7aaabb..ddf6fb1 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -3216,7 +3216,7 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 
 		/* refresh non-overlapped index */
 		tmp = osc_dlmlock_at_pgoff(env, osc, index,
-					   OSC_DAP_FL_TEST_LOCK);
+					   OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_AST);
 		if (tmp) {
 			u64 end = tmp->l_policy_data.l_extent.end;
 			/* Cache the first-non-overlapped index so as to skip
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 6bec6bf..fc3ca8a 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -68,7 +68,8 @@ int osc_match_base(const struct lu_env *env, struct obd_export *exp,
 		   struct ldlm_res_id *res_id, enum ldlm_type type,
 		   union ldlm_policy_data *policy, enum ldlm_mode mode,
 		   u64 *flags, struct osc_object *obj,
-		   struct lustre_handle *lockh, int unref);
+		   struct lustre_handle *lockh,
+		   enum ldlm_match_flags match_flags);
 
 int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		      obd_enqueue_update_f upcall, void *cookie,
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 27495e3..ed9f0a0 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -579,8 +579,7 @@ int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	matchdata.lmd_mode = &mode;
 	matchdata.lmd_policy = &policy;
 	matchdata.lmd_flags = LDLM_FL_TEST_LOCK | LDLM_FL_CBPENDING;
-	matchdata.lmd_unref = 1;
-	matchdata.lmd_has_ast_data = true;
+	matchdata.lmd_match = LDLM_MATCH_UNREF | LDLM_MATCH_AST_ANY;
 
 	LDLM_LOCK_GET(dlmlock);
 
@@ -1267,6 +1266,7 @@ struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
 	struct ldlm_lock *lock = NULL;
 	enum ldlm_mode mode;
 	u64 flags;
+	enum ldlm_match_flags match_flags = 0;
 
 	ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
 	osc_index2policy(policy, osc2cl(obj), index, index);
@@ -1276,6 +1276,12 @@ struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
 	if (dap_flags & OSC_DAP_FL_TEST_LOCK)
 		flags |= LDLM_FL_TEST_LOCK;
 
+	if (dap_flags & OSC_DAP_FL_AST)
+		match_flags |= LDLM_MATCH_AST;
+
+	if (dap_flags & OSC_DAP_FL_CANCELING)
+		match_flags |= LDLM_MATCH_UNREF;
+
 	/*
 	 * It is fine to match any group lock since there could be only one
 	 * with a uniq gid and it conflicts with all other lock modes too
@@ -1283,7 +1289,7 @@ struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
 again:
 	mode = osc_match_base(env, osc_export(obj), resname, LDLM_EXTENT,
 			      policy, LCK_PR | LCK_PW | LCK_GROUP, &flags,
-			      obj, &lockh, dap_flags & OSC_DAP_FL_CANCELING);
+			      obj, &lockh, match_flags);
 	if (mode != 0) {
 		lock = ldlm_handle2lock(&lockh);
 		/* RACE: the lock is cancelled so let's try again */
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 1f7ff24..9a0fc54 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -275,7 +275,7 @@ static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	mode = ldlm_lock_match(exp->exp_obd->obd_namespace,
 			       LDLM_FL_BLOCK_GRANTED | LDLM_FL_LVB_READY,
 			       &resid, LDLM_EXTENT, &policy,
-			       LCK_PR | LCK_PW, &lockh, 0);
+			       LCK_PR | LCK_PW, &lockh);
 	if (mode) { /* lock is cached on client */
 		if (mode != LCK_PR) {
 			ldlm_lock_addref(&lockh, LCK_PR);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 53f87ea..8a8a624 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2723,7 +2723,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	if (intent != 0)
 		match_flags |= LDLM_FL_BLOCK_GRANTED;
 	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
-			       einfo->ei_type, policy, mode, &lockh, 0);
+			       einfo->ei_type, policy, mode, &lockh);
 	if (mode) {
 		struct ldlm_lock *matched;
 
@@ -2830,7 +2830,8 @@ int osc_match_base(const struct lu_env *env, struct obd_export *exp,
 		   struct ldlm_res_id *res_id, enum ldlm_type type,
 		   union ldlm_policy_data *policy, enum ldlm_mode mode,
 		   u64 *flags, struct osc_object *obj,
-		   struct lustre_handle *lockh, int unref)
+		   struct lustre_handle *lockh,
+		   enum ldlm_match_flags match_flags)
 {
 	struct obd_device *obd = exp->exp_obd;
 	u64 lflags = *flags;
@@ -2853,8 +2854,10 @@ int osc_match_base(const struct lu_env *env, struct obd_export *exp,
 	rc = mode;
 	if (mode == LCK_PR)
 		rc |= LCK_PW;
-	rc = ldlm_lock_match(obd->obd_namespace, lflags,
-			     res_id, type, policy, rc, lockh, unref);
+
+	rc = ldlm_lock_match_with_skip(obd->obd_namespace, lflags, 0,
+				       res_id, type, policy, rc, lockh,
+				       match_flags);
 	if (!rc || lflags & LDLM_FL_TEST_LOCK)
 		return rc;
 
-- 
1.8.3.1
