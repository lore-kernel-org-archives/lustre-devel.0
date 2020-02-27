From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:38 -0500
Subject: [lustre-devel] [PATCH 110/622] lustre: ldlm: don't cancel DoM locks
 before replay
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-111-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Weigh a DOM locks before lock replay like that is done
for OSC EXTENT locks and don't cancel locks with data.

Add DoM replay tests for file creation and write cases.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10961
Lustre-commit: b44b1ff8c7fc ("LU-10961 ldlm: don't cancel DoM locks before replay")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32791
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  1 +
 fs/lustre/mdc/mdc_request.c    |  6 ++++++
 fs/lustre/osc/osc_lock.c       | 22 ++++++++++++++--------
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 5ba4f97..dc8071a 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -714,6 +714,7 @@ void osc_lock_cancel(const struct lu_env *env,
 		     const struct cl_lock_slice *slice);
 void osc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice);
 int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
+unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
 /****************************************************************************
  *
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 3341761..0ee42dd 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2510,6 +2510,12 @@ static int mdc_cancel_weight(struct ldlm_lock *lock)
 	if (lock->l_policy_data.l_inodebits.bits & MDS_INODELOCK_OPEN)
 		return 0;
 
+	/* Special case for DoM locks, cancel only unused and granted locks */
+	if (ldlm_has_dom(lock) &&
+	    (lock->l_granted_mode != lock->l_req_mode ||
+	     osc_ldlm_weigh_ast(lock) != 0))
+		return 0;
+
 	return 1;
 }
 
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index b7b33fb..1a2b0bd 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -608,8 +608,8 @@ static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
 	struct cl_page *page = ops->ops_cl.cpl_page;
 
 	if (cl_page_is_vmlocked(env, page) ||
-	    PageDirty(page->cp_vmpage) || PageWriteback(page->cp_vmpage)
-	   )
+	    PageDirty(page->cp_vmpage) ||
+	    PageWriteback(page->cp_vmpage))
 		return false;
 
 	*(pgoff_t *)cbdata = osc_index(ops) + 1;
@@ -618,7 +618,7 @@ static bool weigh_cb(const struct lu_env *env, struct cl_io *io,
 
 static unsigned long osc_lock_weight(const struct lu_env *env,
 				     struct osc_object *oscobj,
-				     struct ldlm_extent *extent)
+				     loff_t start, loff_t end)
 {
 	struct cl_io *io = osc_env_thread_io(env);
 	struct cl_object *obj = cl_object_top(&oscobj->oo_cl);
@@ -631,11 +631,10 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 	if (result != 0)
 		return result;
 
-	page_index = cl_index(obj, extent->start);
+	page_index = cl_index(obj, start);
 
 	if (!osc_page_gang_lookup(env, io, oscobj,
-				 page_index,
-				 cl_index(obj, extent->end),
+				 page_index, cl_index(obj, end),
 				 weigh_cb, (void *)&page_index))
 		result = 1;
 	cl_io_fini(env, io);
@@ -668,7 +667,8 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 		/* Mostly because lack of memory, do not eliminate this lock */
 		return 1;
 
-	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT);
+	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT ||
+		ldlm_has_dom(dlmlock));
 	lock_res_and_lock(dlmlock);
 	obj = dlmlock->l_ast_data;
 	if (obj)
@@ -695,7 +695,12 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 		goto out;
 	}
 
-	weight = osc_lock_weight(env, obj, &dlmlock->l_policy_data.l_extent);
+	if (ldlm_has_dom(dlmlock))
+		weight = osc_lock_weight(env, obj, 0, OBD_OBJECT_EOF);
+	else
+		weight = osc_lock_weight(env, obj,
+					 dlmlock->l_policy_data.l_extent.start,
+					 dlmlock->l_policy_data.l_extent.end);
 
 out:
 	if (obj)
@@ -704,6 +709,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 	cl_env_put(env, &refcheck);
 	return weight;
 }
+EXPORT_SYMBOL(osc_ldlm_weigh_ast);
 
 static void osc_lock_build_einfo(const struct lu_env *env,
 				 const struct cl_lock *lock,
-- 
1.8.3.1
