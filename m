From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:47 -0500
Subject: [lustre-devel] [PATCH 299/622] lustre: dom: per-resource ELC for
 WRITE lock enqueue
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-300-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Improve client write lock enqueue by doing ELC for any
read lock on the same resource. This helps with read/write
access, e.g. compilebench shows ~10% better results with
about 45% less ldlm cancel RPCs.

In mdc_enqueue_send() collect resource unused read locks
and pack them into enqueue request.

The ldlm_cancel_resource_local() is changed also to don't
skip DOM lock if it is set in policy explicitly

WC-bug-id: https://jira.whamcloud.com/browse/LU-10894
Lustre-commit: 16c156c3218b ("LU-10894 dom: per-resource ELC for WRITE lock enqueue")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34736
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 17 ++++++++++++-----
 fs/lustre/mdc/mdc_dev.c       | 13 +++++++++++--
 fs/lustre/mdc/mdc_internal.h  |  5 ++++-
 fs/lustre/mdc/mdc_reint.c     | 26 +++++++++++++++++---------
 4 files changed, 44 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 71892a5..5a7026d 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1888,12 +1888,19 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 		/*
 		 * If policy is given and this is IBITS lock, add to list only
 		 * those locks that match by policy.
-		 * Skip locks with DoM bit always to don't flush data.
 		 */
-		if (policy && (lock->l_resource->lr_type == LDLM_IBITS) &&
-		    (!(lock->l_policy_data.l_inodebits.bits &
-		      policy->l_inodebits.bits) || ldlm_has_dom(lock)))
-			continue;
+		if (policy && (lock->l_resource->lr_type == LDLM_IBITS)) {
+			if (!(lock->l_policy_data.l_inodebits.bits &
+			      policy->l_inodebits.bits))
+				continue;
+			/* Skip locks with DoM bit if it is not set in policy
+			 * to don't flush data by side-bits. Lock convert will
+			 * drop those bits separately.
+			 */
+			if (ldlm_has_dom(lock) &&
+			    !(policy->l_inodebits.bits & MDS_INODELOCK_DOM))
+				continue;
+		}
 
 		/* See CBPENDING comment in ldlm_cancel_lru */
 		lock->l_flags |= LDLM_FL_CBPENDING | LDLM_FL_CANCELING |
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index cb173f4..8f0e283 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -670,7 +670,8 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	enum ldlm_mode mode;
 	bool glimpse = *flags & LDLM_FL_HAS_INTENT;
 	u64 match_flags = *flags;
-	int rc;
+	LIST_HEAD(cancels);
+	int rc, count;
 
 	mode = einfo->ei_mode;
 	if (einfo->ei_mode == LCK_PR)
@@ -726,7 +727,15 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	if (!req)
 		return -ENOMEM;
 
-	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
+	/* For WRITE lock cancel other locks on resource early if any */
+	if (einfo->ei_mode & LCK_PW)
+		count = mdc_resource_get_unused_res(exp, res_id, &cancels,
+						    einfo->ei_mode,
+						    MDS_INODELOCK_DOM);
+	else
+		count = 0;
+
+	rc = ldlm_prep_enqueue_req(exp, req, &cancels, count);
 	if (rc < 0) {
 		ptlrpc_request_free(req);
 		return rc;
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index f75498a..2b540f8 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -86,7 +86,10 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		const union ldlm_policy_data *policy,
 		struct md_op_data *op_data,
 		struct lustre_handle *lockh, u64 extra_lock_flags);
-
+int mdc_resource_get_unused_res(struct obd_export *exp,
+				struct ldlm_res_id *res_id,
+				struct list_head *cancels,
+				enum ldlm_mode mode, u64 bits);
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode  mode,
 			    u64 bits);
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 86acb4e..d26e27d 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -62,13 +62,13 @@ static int mdc_reint(struct ptlrpc_request *request, int level)
  * found by @fid. Found locks are added into @cancel list. Returns the amount of
  * locks added to @cancels list.
  */
-int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
-			    struct list_head *cancels, enum ldlm_mode mode,
-			    u64 bits)
+int mdc_resource_get_unused_res(struct obd_export *exp,
+				struct ldlm_res_id *res_id,
+				struct list_head *cancels,
+				enum ldlm_mode mode, u64 bits)
 {
 	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
 	union ldlm_policy_data policy = {};
-	struct ldlm_res_id res_id;
 	struct ldlm_resource *res;
 	int count;
 
@@ -82,21 +82,29 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 	if (exp_connect_cancelset(exp) && !ns_connect_cancelset(ns))
 		return 0;
 
-	fid_build_reg_res_name(fid, &res_id);
-	res = ldlm_resource_get(exp->exp_obd->obd_namespace,
-				NULL, &res_id, 0, 0);
+	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
 	if (IS_ERR(res))
 		return 0;
 	LDLM_RESOURCE_ADDREF(res);
 	/* Initialize ibits lock policy. */
 	policy.l_inodebits.bits = bits;
-	count = ldlm_cancel_resource_local(res, cancels, &policy,
-					   mode, 0, 0, NULL);
+	count = ldlm_cancel_resource_local(res, cancels, &policy, mode, 0, 0,
+					   NULL);
 	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
 	return count;
 }
 
+int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
+			    struct list_head *cancels, enum ldlm_mode mode,
+			    u64 bits)
+{
+	struct ldlm_res_id res_id;
+
+	fid_build_reg_res_name(fid, &res_id);
+	return mdc_resource_get_unused_res(exp, &res_id, cancels, mode, bits);
+}
+
 int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		void *ea, size_t ealen, struct ptlrpc_request **request)
 {
-- 
1.8.3.1
