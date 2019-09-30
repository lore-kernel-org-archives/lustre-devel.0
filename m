From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:20 -0400
Subject: [lustre-devel] [PATCH 121/151] lustre: mdc: high-priority request
 handling for DOM
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-122-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Implement high-priority request handling and lock
prolongation for Data-on-MDT BRW requests to avoid incorrect
timeouts and client eviction under heavy MDS load.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10181
Lustre-commit: 9e338ee25609 ("LU-10181 mdc: high-priority request handling for DOM")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29968
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c | 72 +++++++++++++++++++++++++++++++------------------
 1 file changed, 46 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 4ff5cc6..2de849a 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -937,6 +937,34 @@ static int mdc_async_upcall(void *a, int rc)
 	return 0;
 }
 
+static int mdc_get_lock_handle(const struct lu_env *env, struct osc_object *osc,
+			       pgoff_t index, struct lustre_handle *lh)
+{
+	struct ldlm_lock *lock;
+	int rc = 0;
+
+	/* find DOM lock protecting object */
+	lock = mdc_dlmlock_at_pgoff(env, osc, index,
+				    OSC_DAP_FL_TEST_LOCK |
+				    OSC_DAP_FL_CANCELING);
+	if (!lock) {
+		struct ldlm_resource *res;
+		struct ldlm_res_id *resname;
+
+		resname = &osc_env_info(env)->oti_resname;
+		fid_build_reg_res_name(lu_object_fid(osc2lu(osc)), resname);
+		res = ldlm_resource_get(osc_export(osc)->exp_obd->obd_namespace,
+					NULL, resname, LDLM_IBITS, 0);
+		ldlm_resource_dump(D_ERROR, res);
+		libcfs_debug_dumpstack(NULL);
+		rc = -ENOENT;
+	} else {
+		*lh = lock->l_remote_handle;
+		LDLM_LOCK_PUT(lock);
+	}
+	return rc;
+}
+
 static int mdc_io_setattr_start(const struct lu_env *env,
 				const struct cl_io_slice *slice)
 {
@@ -1008,6 +1036,11 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 	if (oio->oi_lockless) {
 		oa->o_flags = OBD_FL_SRVLOCK;
 		oa->o_valid |= OBD_MD_FLFLAGS;
+	} else {
+		rc = mdc_get_lock_handle(env, cl2osc(obj), CL_PAGE_EOF,
+					 &oa->o_handle);
+		if (!rc)
+			oa->o_valid |= OBD_MD_FLHANDLE;
 	}
 
 	init_completion(&cbargs->opc_sync);
@@ -1157,35 +1190,22 @@ static void mdc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 		attr->cra_oa->o_valid |= OBD_MD_FLID;
 
 	if (flags & OBD_MD_FLHANDLE) {
-		struct ldlm_lock *lock;  /* _some_ lock protecting @apage */
 		struct osc_page *opg;
 
 		opg = osc_cl_page_osc(attr->cra_page, cl2osc(obj));
-		lock = mdc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
-				OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
-		if (!lock && !opg->ops_srvlock) {
-			struct ldlm_resource *res;
-			struct ldlm_res_id *resname;
-
-			CL_PAGE_DEBUG(D_ERROR, env, attr->cra_page,
-				      "uncovered page!\n");
-
-			resname = &osc_env_info(env)->oti_resname;
-			mdc_build_res_name(cl2osc(obj), resname);
-			res = ldlm_resource_get(
-				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
-				NULL, resname, LDLM_IBITS, 0);
-			ldlm_resource_dump(D_ERROR, res);
-
-			libcfs_debug_dumpstack(NULL);
-			LBUG();
-		}
-
-		/* check for lockless io. */
-		if (lock) {
-			attr->cra_oa->o_handle = lock->l_remote_handle;
-			attr->cra_oa->o_valid |= OBD_MD_FLHANDLE;
-			LDLM_LOCK_PUT(lock);
+		if (!opg->ops_srvlock) {
+			int rc;
+
+			rc = mdc_get_lock_handle(env, cl2osc(obj),
+						 osc_index(opg),
+						 &attr->cra_oa->o_handle);
+			if (rc) {
+				CL_PAGE_DEBUG(D_ERROR, env, attr->cra_page,
+					      "uncovered page!\n");
+				LBUG();
+			} else {
+				attr->cra_oa->o_valid |= OBD_MD_FLHANDLE;
+			}
 		}
 	}
 }
-- 
1.8.3.1
