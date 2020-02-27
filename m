From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:37 -0500
Subject: [lustre-devel] [PATCH 229/622] lustre: mdc: prevent glimpse lock
 count grow
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-230-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

DOM locks matching tries to ignore locks with
LDLM_FL_KMS_IGNORE flag during ldlm_lock_match() but
checks that after ldlm_lock_match() call. Therefore if
there is any lock with such flag in queue then all other
locks after it are ignored and new lock is created causing
big amount of locks on single resource in some access
patterns.
Patch extends lock_matches() function to check flags to
exclude and adds ldlm_lock_match_with_skip() to use that
when needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11964
Lustre-commit: b915221b6d0f ("LU-11964 mdc: prevent glimpse lock count grow")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34261
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h  | 27 ++++++++++---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ldlm/ldlm_lock.c      | 90 ++++++++++++++++++-----------------------
 fs/lustre/mdc/mdc_dev.c         | 28 +++++++++----
 4 files changed, 82 insertions(+), 64 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 1133e20..a95555e 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1136,12 +1136,27 @@ void ldlm_lock_decref_and_cancel(const struct lustre_handle *lockh,
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
-enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
-			       const struct ldlm_res_id *res_id,
-			       enum ldlm_type type,
-			       union ldlm_policy_data *policy,
-			       enum ldlm_mode mode, struct lustre_handle *lh,
-			       int unref);
+enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
+					 u64 flags, u64 skip_flags,
+					 const struct ldlm_res_id *res_id,
+					 enum ldlm_type type,
+					 union ldlm_policy_data *policy,
+					 enum ldlm_mode mode,
+					 struct lustre_handle *lh,
+					 int unref);
+static inline enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns,
+					     u64 flags,
+					     const struct ldlm_res_id *res_id,
+					     enum ldlm_type type,
+					     union ldlm_policy_data *policy,
+					     enum ldlm_mode mode,
+					     struct lustre_handle *lh,
+					     int unref)
+{
+	return ldlm_lock_match_with_skip(ns, flags, 0, res_id, type, policy,
+					 mode, lh, unref);
+}
+
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 					   u64 *bits);
 void ldlm_lock_cancel(struct ldlm_lock *lock);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 5e5cf3a..39547a0 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -391,6 +391,7 @@
 #define OBD_FAIL_MDC_LIGHTWEIGHT			0x805
 #define OBD_FAIL_MDC_CLOSE				0x806
 #define OBD_FAIL_MDC_MERGE				0x807
+#define OBD_FAIL_MDC_GLIMPSE_DDOS			0x808
 
 #define OBD_FAIL_MGS					0x900
 #define OBD_FAIL_MGS_ALL_REQUEST_NET			0x901
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 06690a6..cc96fbd 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1053,6 +1053,7 @@ struct lock_match_data {
 	enum ldlm_mode		*lmd_mode;
 	union ldlm_policy_data	*lmd_policy;
 	u64			 lmd_flags;
+	u64			 lmd_skip_flags;
 	int			 lmd_unref;
 };
 
@@ -1133,6 +1134,10 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	if (!equi(data->lmd_flags & LDLM_FL_LOCAL_ONLY, ldlm_is_local(lock)))
 		return false;
 
+	/* Filter locks by skipping flags */
+	if (data->lmd_skip_flags & lock->l_flags)
+		return false;
+
 	if (data->lmd_flags & LDLM_FL_TEST_LOCK) {
 		LDLM_LOCK_GET(lock);
 		ldlm_lock_touch_in_lru(lock);
@@ -1267,12 +1272,13 @@ void ldlm_lock_allow_match(struct ldlm_lock *lock)
  * keep caller code unchanged), the context failure will be discovered by
  * caller sometime later.
  */
-enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
-			       const struct ldlm_res_id *res_id,
-			       enum ldlm_type type,
-			       union ldlm_policy_data *policy,
-			       enum ldlm_mode mode,
-			       struct lustre_handle *lockh, int unref)
+enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
+					 u64 flags, u64 skip_flags,
+					 const struct ldlm_res_id *res_id,
+					 enum ldlm_type type,
+					 union ldlm_policy_data *policy,
+					 enum ldlm_mode mode,
+					 struct lustre_handle *lockh, int unref)
 {
 	struct lock_match_data data = {
 		.lmd_old	= NULL,
@@ -1280,11 +1286,12 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 		.lmd_mode	= &mode,
 		.lmd_policy	= policy,
 		.lmd_flags	= flags,
+		.lmd_skip_flags	= skip_flags,
 		.lmd_unref	= unref,
 	};
 	struct ldlm_resource *res;
 	struct ldlm_lock *lock;
-	int rc = 0;
+	int matched;
 
 	if (!ns) {
 		data.lmd_old = ldlm_handle2lock(lockh);
@@ -1304,25 +1311,13 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 
 	LDLM_RESOURCE_ADDREF(res);
 	lock_res(res);
-
 	if (res->lr_type == LDLM_EXTENT)
 		lock = search_itree(res, &data);
 	else
 		lock = search_queue(&res->lr_granted, &data);
-	if (lock) {
-		rc = 1;
-		goto out;
-	}
-	if (flags & LDLM_FL_BLOCK_GRANTED) {
-		rc = 0;
-		goto out;
-	}
-	lock = search_queue(&res->lr_waiting, &data);
-	if (lock) {
-		rc = 1;
-		goto out;
-	}
-out:
+	if (!lock && !(flags & LDLM_FL_BLOCK_GRANTED))
+		lock = search_queue(&res->lr_waiting, &data);
+	matched = lock ? mode : 0;
 	unlock_res(res);
 	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
@@ -1338,13 +1333,8 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 							  LDLM_FL_WAIT_NOREPROC,
 								 NULL);
 				if (err) {
-					if (flags & LDLM_FL_TEST_LOCK)
-						LDLM_LOCK_RELEASE(lock);
-					else
-						ldlm_lock_decref_internal(lock,
-									  mode);
-					rc = 0;
-					goto out2;
+					matched = 0;
+					goto out_fail_match;
 				}
 			}
 
@@ -1352,49 +1342,49 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 			wait_event_idle_timeout(lock->l_waitq,
 						lock->l_flags & wait_flags,
 						obd_timeout * HZ);
+
 			if (!ldlm_is_lvb_ready(lock)) {
-				if (flags & LDLM_FL_TEST_LOCK)
-					LDLM_LOCK_RELEASE(lock);
-				else
-					ldlm_lock_decref_internal(lock, mode);
-				rc = 0;
+				matched = 0;
+				goto out_fail_match;
 			}
 		}
-	}
-out2:
-	if (rc) {
-		LDLM_DEBUG(lock, "matched (%llu %llu)",
-			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-				res_id->name[2] : policy->l_extent.start,
-			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-				res_id->name[3] : policy->l_extent.end);
 
 		/* check user's security context */
 		if (lock->l_conn_export &&
 		    sptlrpc_import_check_ctx(class_exp2cliimp(lock->l_conn_export))) {
-			if (!(flags & LDLM_FL_TEST_LOCK))
-				ldlm_lock_decref_internal(lock, mode);
-			rc = 0;
+			matched = 0;
+			goto out_fail_match;
 		}
 
+		LDLM_DEBUG(lock, "matched (%llu %llu)",
+			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
+			   res_id->name[2] : policy->l_extent.start,
+			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
+			   res_id->name[3] : policy->l_extent.end);
+
+out_fail_match:
 		if (flags & LDLM_FL_TEST_LOCK)
 			LDLM_LOCK_RELEASE(lock);
+		else if (!matched)
+			ldlm_lock_decref_internal(lock, mode);
+	}
 
-	} else if (!(flags & LDLM_FL_TEST_LOCK)) {/*less verbose for test-only*/
+	/* less verbose for test-only */
+	if (!matched && !(flags & LDLM_FL_TEST_LOCK)) {
 		LDLM_DEBUG_NOLOCK("not matched ns %p type %u mode %u res %llu/%llu (%llu %llu)",
 				  ns, type, mode, res_id->name[0],
 				  res_id->name[1],
 				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-					res_id->name[2] : policy->l_extent.start,
+				  res_id->name[2] : policy->l_extent.start,
 				  (type == LDLM_PLAIN || type == LDLM_IBITS) ?
-					res_id->name[3] : policy->l_extent.end);
+				  res_id->name[3] : policy->l_extent.end);
 	}
 	if (data.lmd_old)
 		LDLM_LOCK_PUT(data.lmd_old);
 
-	return rc ? mode : 0;
+	return matched;
 }
-EXPORT_SYMBOL(ldlm_lock_match);
+EXPORT_SYMBOL(ldlm_lock_match_with_skip);
 
 enum ldlm_mode ldlm_revalidate_lock_handle(const struct lustre_handle *lockh,
 					   u64 *bits)
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index f23f6cf..cb173f4 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -676,10 +676,16 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
 
-	if (!glimpse)
+	if (glimpse)
 		match_flags |= LDLM_FL_BLOCK_GRANTED;
-	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
-			       einfo->ei_type, policy, mode, &lockh, 0);
+	/* DOM locking uses LDLM_FL_KMS_IGNORE to mark locks wich have no valid
+	 * LVB information, e.g. canceled locks or locks of just pruned object,
+	 * such locks should be skipped.
+	 */
+	mode = ldlm_lock_match_with_skip(obd->obd_namespace, match_flags,
+					 LDLM_FL_KMS_IGNORE, res_id,
+					 einfo->ei_type, policy, mode,
+					 &lockh, 0);
 	if (mode) {
 		struct ldlm_lock *matched;
 
@@ -687,8 +693,16 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 			return ELDLM_OK;
 
 		matched = ldlm_handle2lock(&lockh);
-		if (!matched || ldlm_is_kms_ignore(matched))
+		/* this shouldn't happen but this check is kept to make
+		 * related test fail if problem occurs
+		 */
+		if (unlikely(ldlm_is_kms_ignore(matched))) {
+			LDLM_ERROR(matched, "matched lock has KMS ignore flag");
 			goto no_match;
+		}
+
+		if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GLIMPSE_DDOS))
+			ldlm_set_kms_ignore(matched);
 
 		if (mdc_set_dom_lock_data(env, matched, einfo->ei_cbdata)) {
 			*flags |= LDLM_FL_LVB_READY;
@@ -1337,11 +1351,9 @@ static int mdc_attr_get(const struct lu_env *env, struct cl_object *obj,
 
 static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
 {
-	if ((!lock->l_ast_data && !ldlm_is_kms_ignore(lock)) ||
-	    (lock->l_ast_data == data)) {
+	if (lock->l_ast_data == data)
 		lock->l_ast_data = NULL;
-		ldlm_set_kms_ignore(lock);
-	}
+	ldlm_set_kms_ignore(lock);
 	return LDLM_ITER_CONTINUE;
 }
 
-- 
1.8.3.1
