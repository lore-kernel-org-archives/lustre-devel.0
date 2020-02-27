From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:05 -0500
Subject: [lustre-devel] [PATCH 497/622] lustre: osc: wrong cache of LVB
 attrs, part2
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-498-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

It may happen that osc oinfo lvb cache has size < kms.

It occurs if a reply re-ordering happens and an older size is applied
to oinfo unconditionally.

Another possibility is RA, when osc_match_base() attaches the dlm lock
to osc object but does not cache the lvb. The next layout change will
overwrites the lock lvb by the oinfo cache (previous LUS-7731 fix),
presumably smaller values. Therefore, the next lock re-use may run
into a problem with partial page write which thinks the preliminary
read is not needed.

Do not let the cached oinfo lvb size to become less than kms.
Also, cache the lock's lvb in the oinfo on osc_match_base().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12681
Lustre-commit: 40319db5bc64 ("LU-12681 osc: wrong cache of LVB attrs, part2")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Cray-bug-id: LUS-7731
Reviewed-on: https://review.whamcloud.com/36200
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c      | 72 +++++++++++++++++++++++++++-----------------
 fs/lustre/osc/osc_internal.h | 12 ++++++--
 fs/lustre/osc/osc_lock.c     | 40 +++++++++++++-----------
 fs/lustre/osc/osc_object.c   | 16 ++++++----
 fs/lustre/osc/osc_request.c  | 19 +++++++++---
 5 files changed, 100 insertions(+), 59 deletions(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index d589f97..312e527 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -69,21 +69,17 @@ static void mdc_lock_lvb_update(const struct lu_env *env,
 				struct ldlm_lock *dlmlock,
 				struct ost_lvb *lvb);
 
-static int mdc_set_dom_lock_data(const struct lu_env *env,
-				 struct ldlm_lock *lock, void *data)
+static int mdc_set_dom_lock_data(struct ldlm_lock *lock, void *data)
 {
-	struct osc_object *obj = data;
 	int set = 0;
 
 	LASSERT(lock);
 	LASSERT(lock->l_glimpse_ast == mdc_ldlm_glimpse_ast);
 
 	lock_res_and_lock(lock);
-	if (!lock->l_ast_data) {
-		lock->l_ast_data = data;
-		mdc_lock_lvb_update(env, obj, lock, NULL);
-	}
 
+	if (!lock->l_ast_data)
+		lock->l_ast_data = data;
 	if (lock->l_ast_data == data)
 		set = 1;
 
@@ -93,9 +89,9 @@ static int mdc_set_dom_lock_data(const struct lu_env *env,
 }
 
 int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
-		       struct ldlm_res_id *res_id,
-		       enum ldlm_type type, union ldlm_policy_data *policy,
-		       enum ldlm_mode mode, u64 *flags, void *data,
+		       struct ldlm_res_id *res_id, enum ldlm_type type,
+		       union ldlm_policy_data *policy, enum ldlm_mode mode,
+		       u64 *flags, struct osc_object *obj,
 		       struct lustre_handle *lockh, int unref)
 {
 	struct obd_device *obd = exp->exp_obd;
@@ -107,11 +103,19 @@ int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
 	if (rc == 0 || lflags & LDLM_FL_TEST_LOCK)
 		return rc;
 
-	if (data) {
+	if (obj) {
 		struct ldlm_lock *lock = ldlm_handle2lock(lockh);
 
 		LASSERT(lock);
-		if (!mdc_set_dom_lock_data(env, lock, data)) {
+		if (mdc_set_dom_lock_data(lock, obj)) {
+			lock_res_and_lock(lock);
+			if (!ldlm_is_lvb_cached(lock)) {
+				LASSERT(lock->l_ast_data == obj);
+				mdc_lock_lvb_update(env, obj, lock, NULL);
+				ldlm_set_lvb_cached(lock);
+			}
+			unlock_res_and_lock(lock);
+		} else {
 			ldlm_lock_decref(lockh, rc);
 			rc = 0;
 		}
@@ -400,6 +404,7 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	unsigned int valid = CAT_BLOCKS | CAT_ATIME | CAT_CTIME | CAT_MTIME |
 			     CAT_SIZE;
+	unsigned int setkms = 0;
 
 	if (!lvb) {
 		LASSERT(dlmlock);
@@ -415,17 +420,23 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 		size = lvb->lvb_size;
 
 		if (size >= oinfo->loi_kms) {
-			LDLM_DEBUG(dlmlock,
-				   "lock acquired, setting rss=%llu, kms=%llu",
-				   lvb->lvb_size, size);
 			valid |= CAT_KMS;
 			attr->cat_kms = size;
-		} else {
-			LDLM_DEBUG(dlmlock,
-				   "lock acquired, setting rss=%llu, leaving kms=%llu",
-				   lvb->lvb_size, oinfo->loi_kms);
+			setkms = 1;
 		}
 	}
+
+	/* The size should not be less than the kms */
+	if (attr->cat_size < oinfo->loi_kms)
+		attr->cat_size = oinfo->loi_kms;
+
+	LDLM_DEBUG(dlmlock,
+		   "acquired size %llu, setting rss=%llu;%s kms=%llu, end=%llu",
+		   lvb->lvb_size, attr->cat_size,
+		   setkms ? "" : " leaving",
+		   setkms ? attr->cat_kms : oinfo->loi_kms,
+		   dlmlock ? dlmlock->l_policy_data.l_extent.end : -1ull);
+
 	cl_object_attr_update(env, obj, attr, valid);
 	cl_object_attr_unlock(obj);
 }
@@ -433,6 +444,7 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 			     struct lustre_handle *lockh)
 {
+	struct osc_object *osc = cl2osc(oscl->ols_cl.cls_obj);
 	struct ldlm_lock *dlmlock;
 
 	dlmlock = ldlm_handle2lock_long(lockh, 0);
@@ -474,8 +486,8 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 		/* no lvb update for matched lock */
 		if (!ldlm_is_lvb_cached(dlmlock)) {
 			LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
-			mdc_lock_lvb_update(env, cl2osc(oscl->ols_cl.cls_obj),
-					    dlmlock, NULL);
+			LASSERT(osc == dlmlock->l_ast_data);
+			mdc_lock_lvb_update(env, osc, dlmlock, NULL);
 			ldlm_set_lvb_cached(dlmlock);
 		}
 	}
@@ -698,7 +710,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 		if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GLIMPSE_DDOS))
 			ldlm_set_kms_ignore(matched);
 
-		if (mdc_set_dom_lock_data(env, matched, einfo->ei_cbdata)) {
+		if (mdc_set_dom_lock_data(matched, einfo->ei_cbdata)) {
 			*flags |= LDLM_FL_LVB_READY;
 
 			/* We already have a lock, and it's referenced. */
@@ -1365,15 +1377,19 @@ static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
 
 		/* Updates lvb in lock by the cached oinfo */
 		oinfo = osc->oo_oinfo;
-		cl_object_attr_lock(&osc->oo_cl);
-		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
-		cl_object_attr_unlock(&osc->oo_cl);
 
 		LDLM_DEBUG(lock,
-			   "update lvb size %llu blocks %llu [cma]time: %llu %llu %llu",
-			   lvb->lvb_size, lvb->lvb_blocks,
-			   lvb->lvb_ctime, lvb->lvb_mtime, lvb->lvb_atime);
+			   "update lock size %llu blocks %llu [cma]time: %llu %llu %llu by oinfo size %llu blocks %llu [cma]time %llu %llu %llu",
+			   lvb->lvb_size,
+			   lvb->lvb_blocks, lvb->lvb_ctime, lvb->lvb_mtime,
+			   lvb->lvb_atime, oinfo->loi_lvb.lvb_size,
+			   oinfo->loi_lvb.lvb_blocks, oinfo->loi_lvb.lvb_ctime,
+			   oinfo->loi_lvb.lvb_mtime, oinfo->loi_lvb.lvb_atime);
+		LASSERT(oinfo->loi_lvb.lvb_size >= oinfo->loi_kms);
 
+		cl_object_attr_lock(&osc->oo_cl);
+		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
+		cl_object_attr_unlock(&osc->oo_cl);
 		ldlm_clear_lvb_cached(lock);
 	}
 	return LDLM_ITER_CONTINUE;
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index b3b365a..492c60d 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -52,6 +52,11 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 			   pgoff_t start, pgoff_t end, bool discard);
 
+void osc_lock_lvb_update(const struct lu_env *env,
+			 struct osc_object *osc,
+			 struct ldlm_lock *dlmlock,
+			 struct ost_lvb *lvb);
+
 int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     u64 *flags, union ldlm_policy_data *policy,
 		     struct ost_lvb *lvb, osc_enqueue_upcall_f upcall,
@@ -59,9 +64,10 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     struct ptlrpc_request_set *rqset, int async,
 		     bool speculative);
 
-int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		   enum ldlm_type type, union ldlm_policy_data *policy,
-		   enum ldlm_mode mode, u64 *flags, void *data,
+int osc_match_base(const struct lu_env *env, struct obd_export *exp,
+		   struct ldlm_res_id *res_id, enum ldlm_type type,
+		   union ldlm_policy_data *policy, enum ldlm_mode mode,
+		   u64 *flags, struct osc_object *obj,
 		   struct lustre_handle *lockh, int unref);
 
 int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 02d3436..ce592d7 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -145,15 +145,16 @@ static void osc_lock_build_policy(const struct lu_env *env,
  *
  * Called under lock and resource spin-locks.
  */
-static void osc_lock_lvb_update(const struct lu_env *env,
-				struct osc_object *osc,
-				struct ldlm_lock *dlmlock,
-				struct ost_lvb *lvb)
+void osc_lock_lvb_update(const struct lu_env *env,
+			 struct osc_object *osc,
+			 struct ldlm_lock *dlmlock,
+			 struct ost_lvb *lvb)
 {
 	struct cl_object *obj = osc2cl(osc);
 	struct lov_oinfo *oinfo = osc->oo_oinfo;
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	unsigned int valid;
+	unsigned int setkms = 0;
 
 	valid = CAT_BLOCKS | CAT_ATIME | CAT_CTIME | CAT_MTIME | CAT_SIZE;
 	if (!lvb)
@@ -175,20 +176,24 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 		if (size > dlmlock->l_policy_data.l_extent.end)
 			size = dlmlock->l_policy_data.l_extent.end + 1;
 		if (size >= oinfo->loi_kms) {
-			LDLM_DEBUG(dlmlock,
-				   "lock acquired, setting rss=%llu, kms=%llu",
-				   lvb->lvb_size, size);
 			valid |= CAT_KMS;
 			attr->cat_kms = size;
-		} else {
-			LDLM_DEBUG(dlmlock,
-				   "lock acquired, setting rss=%llu; leaving kms=%llu, end=%llu",
-				   lvb->lvb_size, oinfo->loi_kms,
-				   dlmlock->l_policy_data.l_extent.end);
+			setkms = 1;
 		}
 		ldlm_lock_allow_match_locked(dlmlock);
 	}
 
+	/* The size should not be less than the kms */
+	if (attr->cat_size < oinfo->loi_kms)
+		attr->cat_size = oinfo->loi_kms;
+
+	LDLM_DEBUG(dlmlock,
+		   "acquired size %llu, setting rss=%llu;%s kms=%llu, end=%llu",
+		   lvb->lvb_size, attr->cat_size,
+		   setkms ? "" : " leaving",
+		   setkms ? attr->cat_kms : oinfo->loi_kms,
+		   dlmlock ? dlmlock->l_policy_data.l_extent.end : -1ull);
+
 	cl_object_attr_update(env, obj, attr, valid);
 	cl_object_attr_unlock(obj);
 }
@@ -196,6 +201,7 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 			     struct lustre_handle *lockh)
 {
+	struct osc_object *osc = cl2osc(oscl->ols_cl.cls_obj);
 	struct ldlm_lock *dlmlock;
 
 	dlmlock = ldlm_handle2lock_long(lockh, 0);
@@ -239,8 +245,8 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 		/* no lvb update for matched lock */
 		if (!ldlm_is_lvb_cached(dlmlock)) {
 			LASSERT(oscl->ols_flags & LDLM_FL_LVB_READY);
-			osc_lock_lvb_update(env, cl2osc(oscl->ols_cl.cls_obj),
-					    dlmlock, NULL);
+			LASSERT(osc == dlmlock->l_ast_data);
+			osc_lock_lvb_update(env, osc, dlmlock, NULL);
 			ldlm_set_lvb_cached(dlmlock);
 		}
 		LINVRNT(osc_lock_invariant(oscl));
@@ -1271,9 +1277,9 @@ struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
 	 * with a uniq gid and it conflicts with all other lock modes too
 	 */
 again:
-	mode = osc_match_base(osc_export(obj), resname, LDLM_EXTENT, policy,
-			      LCK_PR | LCK_PW | LCK_GROUP, &flags, obj, &lockh,
-			      dap_flags & OSC_DAP_FL_CANCELING);
+	mode = osc_match_base(env, osc_export(obj), resname, LDLM_EXTENT,
+			      policy, LCK_PR | LCK_PW | LCK_GROUP, &flags,
+			      obj, &lockh, dap_flags & OSC_DAP_FL_CANCELING);
 	if (mode != 0) {
 		lock = ldlm_handle2lock(&lockh);
 		/* RACE: the lock is cancelled so let's try again */
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index d2206e8..6d24cd3 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -209,15 +209,19 @@ static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 
 		/* Updates lvb in lock by the cached oinfo */
 		oinfo = osc->oo_oinfo;
-		cl_object_attr_lock(&osc->oo_cl);
-		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
-		cl_object_attr_unlock(&osc->oo_cl);
 
 		LDLM_DEBUG(lock,
-			   "update lvb size %llu blocks %llu [cma]time: %llu %llu %llu",
-			   lvb->lvb_size, lvb->lvb_blocks,
-			   lvb->lvb_ctime, lvb->lvb_mtime, lvb->lvb_atime);
+			   "update lock size %llu blocks %llu [cma]time: %llu %llu %llu by oinfo size %llu blocks %llu [cma]time %llu %llu %llu",
+			   lvb->lvb_size,
+			   lvb->lvb_blocks, lvb->lvb_ctime, lvb->lvb_mtime,
+			   lvb->lvb_atime, oinfo->loi_lvb.lvb_size,
+			   oinfo->loi_lvb.lvb_blocks, oinfo->loi_lvb.lvb_ctime,
+			   oinfo->loi_lvb.lvb_mtime, oinfo->loi_lvb.lvb_atime);
+		LASSERT(oinfo->loi_lvb.lvb_size >= oinfo->loi_kms);
 
+		cl_object_attr_lock(&osc->oo_cl);
+		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
+		cl_object_attr_unlock(&osc->oo_cl);
 		ldlm_clear_lvb_cached(lock);
 	}
 	return LDLM_ITER_CONTINUE;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 0e32496..95e09ce 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2643,9 +2643,10 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	return rc;
 }
 
-int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		   enum ldlm_type type, union ldlm_policy_data *policy,
-		   enum ldlm_mode mode, u64 *flags, void *data,
+int osc_match_base(const struct lu_env *env, struct obd_export *exp,
+		   struct ldlm_res_id *res_id, enum ldlm_type type,
+		   union ldlm_policy_data *policy, enum ldlm_mode mode,
+		   u64 *flags, struct osc_object *obj,
 		   struct lustre_handle *lockh, int unref)
 {
 	struct obd_device *obd = exp->exp_obd;
@@ -2674,11 +2675,19 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	if (!rc || lflags & LDLM_FL_TEST_LOCK)
 		return rc;
 
-	if (data) {
+	if (obj) {
 		struct ldlm_lock *lock = ldlm_handle2lock(lockh);
 
 		LASSERT(lock);
-		if (!osc_set_lock_data(lock, data)) {
+		if (osc_set_lock_data(lock, obj)) {
+			lock_res_and_lock(lock);
+			if (!ldlm_is_lvb_cached(lock)) {
+				LASSERT(lock->l_ast_data == obj);
+				osc_lock_lvb_update(env, obj, lock, NULL);
+				ldlm_set_lvb_cached(lock);
+			}
+			unlock_res_and_lock(lock);
+		} else {
 			ldlm_lock_decref(lockh, rc);
 			rc = 0;
 		}
-- 
1.8.3.1
