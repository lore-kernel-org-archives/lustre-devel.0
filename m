From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:45 -0400
Subject: [lustre-devel] [PATCH 146/151] lustre: ptlrpc: incorporate
 BUILD_BUG_ON into ptlrpc_req_async_args()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-147-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Every call to ptlrpc_req_async_args() should be preceded by a
BUILD_BUG_ON() (aka LASSERT()), though a few aren't.

To improve maintainability, include the BUILD_BUG_ON into the
ptlrpc_req_async_args() macro.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Lustre-commit: b56177451975 ("LU-4423 ptlrpc: incorporate BUILD_BUG_ON into ptlrpc_req_async_args()")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35509
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  7 +++++--
 fs/lustre/ldlm/ldlm_request.c  |  3 +--
 fs/lustre/mdc/mdc_dev.c        |  5 ++---
 fs/lustre/mdc/mdc_locks.c      |  7 +++----
 fs/lustre/osc/osc_io.c         |  3 +--
 fs/lustre/osc/osc_request.c    | 29 ++++++++++-------------------
 fs/lustre/ptlrpc/client.c      |  6 ++----
 fs/lustre/ptlrpc/import.c      |  3 +--
 8 files changed, 25 insertions(+), 38 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index a8aa327..8024367 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -309,8 +309,11 @@
 #define OBD_MAX_SHORT_IO_BYTES	(min(max(PAGE_SIZE, 16UL * 1024UL), \
 					 OST_SHORT_IO_SPACE & PAGE_MASK))
 
-/* Macro to hide a typecast. */
-#define ptlrpc_req_async_args(req) ((void *)&req->rq_async_args)
+/* Macro to hide a typecast and BUILD_BUG. */
+#define ptlrpc_req_async_args(_var, req) ({				\
+		BUILD_BUG_ON(sizeof(*_var) > sizeof(req->rq_async_args)); \
+		(typeof(_var))&req->rq_async_args;			\
+	})
 
 struct ptlrpc_replay_async_args {
 	int		praa_old_state;
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 00336ca..92e4f69 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -2016,8 +2016,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	LDLM_DEBUG(lock, "replaying lock:");
 
 	atomic_inc(&req->rq_import->imp_replay_inflight);
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	aa->lock_handle = body->lock_handle[0];
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)replay_lock_interpret;
 	ptlrpcd_add_req(req);
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 22749ea..ca0822d 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -733,7 +733,7 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 		if (!rc) {
 			struct osc_enqueue_args *aa;
 
-			aa = ptlrpc_req_async_args(req);
+			aa = ptlrpc_req_async_args(aa, req);
 			aa->oa_exp = exp;
 			aa->oa_mode = einfo->ei_mode;
 			aa->oa_type = einfo->ei_type;
@@ -1195,8 +1195,7 @@ static int mdc_io_data_version_start(const struct lu_env *env,
 	ptlrpc_request_set_replen(req);
 
 	req->rq_interpret_reply = mdc_data_version_interpret;
-	BUILD_BUG_ON(sizeof(*dva) > sizeof(req->rq_async_args));
-	dva = ptlrpc_req_async_args(req);
+	dva = ptlrpc_req_async_args(dva, req);
 	dva->dva_oio = oio;
 
 	ptlrpcd_add_req(req);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 123f0f0..2e4a5c6 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -49,8 +49,8 @@
 #include "mdc_internal.h"
 
 struct mdc_getattr_args {
-	struct obd_export	   *ga_exp;
-	struct md_enqueue_info      *ga_minfo;
+	struct obd_export	*ga_exp;
+	struct md_enqueue_info	*ga_minfo;
 };
 
 int it_open_error(int phase, struct lookup_intent *it)
@@ -1329,8 +1329,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 		return rc;
 	}
 
-	BUILD_BUG_ON(sizeof(*ga) > sizeof(req->rq_async_args));
-	ga = ptlrpc_req_async_args(req);
+	ga = ptlrpc_req_async_args(ga, req);
 	ga->ga_exp = exp;
 	ga->ga_minfo = minfo;
 
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 98726cd..970e8a7 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -689,8 +689,7 @@ static int osc_io_data_version_start(const struct lu_env *env,
 
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_data_version_interpret;
-	BUILD_BUG_ON(sizeof(*dva) > sizeof(req->rq_async_args));
-	dva = ptlrpc_req_async_args(req);
+	dva = ptlrpc_req_async_args(dva, req);
 	dva->dva_oio = oio;
 
 	ptlrpcd_add_req(req);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 0a3d05e..300dee5 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -236,8 +236,7 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		req->rq_interpret_reply =
 			(ptlrpc_interpterer_t)osc_setattr_interpret;
 
-		BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
-		sa = ptlrpc_req_async_args(req);
+		sa = ptlrpc_req_async_args(sa, req);
 		sa->sa_oa = oa;
 		sa->sa_upcall = upcall;
 		sa->sa_cookie = cookie;
@@ -321,8 +320,7 @@ int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
 	}
 
 	req->rq_interpret_reply = osc_ladvise_interpret;
-	BUILD_BUG_ON(sizeof(*la) > sizeof(req->rq_async_args));
-	la = ptlrpc_req_async_args(req);
+	la = ptlrpc_req_async_args(la, req);
 	la->la_oa = oa;
 	la->la_upcall = upcall;
 	la->la_cookie = cookie;
@@ -417,8 +415,7 @@ int osc_punch_send(struct obd_export *exp, struct obdo *oa,
 	ptlrpc_request_set_replen(req);
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
-	BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
-	sa = ptlrpc_req_async_args(req);
+	sa = ptlrpc_req_async_args(sa, req);
 	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
 	sa->sa_cookie = cookie;
@@ -497,8 +494,7 @@ int osc_sync_base(struct osc_object *obj, struct obdo *oa,
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_sync_interpret;
 
-	BUILD_BUG_ON(sizeof(*fa) > sizeof(req->rq_async_args));
-	fa = ptlrpc_req_async_args(req);
+	fa = ptlrpc_req_async_args(fa, req);
 	fa->fa_obj = obj;
 	fa->fa_oa = oa;
 	fa->fa_upcall = upcall;
@@ -1338,8 +1334,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	}
 	ptlrpc_request_set_replen(req);
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	aa->aa_oa = oa;
 	aa->aa_requested_nob = requested_nob;
 	aa->aa_nio_count = niocount;
@@ -1725,7 +1720,7 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	new_req->rq_generation_set = 1;
 	new_req->rq_import_generation = request->rq_import_generation;
 
-	new_aa = ptlrpc_req_async_args(new_req);
+	new_aa = ptlrpc_req_async_args(new_aa, new_req);
 
 	INIT_LIST_HEAD(&new_aa->aa_oaps);
 	list_splice_init(&aa->aa_oaps, &new_aa->aa_oaps);
@@ -2074,8 +2069,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	cl_req_attr_set(env, osc2cl(obj), crattr);
 	lustre_msg_set_jobid(req->rq_reqmsg, crattr->cra_jobid);
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	INIT_LIST_HEAD(&aa->aa_oaps);
 	list_splice_init(&rpc_list, &aa->aa_oaps);
 	INIT_LIST_HEAD(&aa->aa_exts);
@@ -2365,8 +2359,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		if (!rc) {
 			struct osc_enqueue_args *aa;
 
-			BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-			aa = ptlrpc_req_async_args(req);
+			aa = ptlrpc_req_async_args(aa, req);
 			aa->oa_exp = exp;
 			aa->oa_mode = einfo->ei_mode;
 			aa->oa_type = einfo->ei_type;
@@ -2519,8 +2512,7 @@ static int osc_statfs_async(struct obd_export *exp,
 	}
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_statfs_interpret;
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	aa->aa_oi = oinfo;
 
 	ptlrpc_set_add_req(rqset, req);
@@ -2725,8 +2717,7 @@ int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		struct osc_brw_async_args *aa;
 		struct obdo *oa;
 
-		BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-		aa = ptlrpc_req_async_args(req);
+		aa = ptlrpc_req_async_args(aa, req);
 		oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
 		if (!oa) {
 			ptlrpc_req_finished(req);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 8328c71..6086770 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2926,8 +2926,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 
 	LASSERT(req->rq_import->imp_state == LUSTRE_IMP_REPLAY);
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	memset(aa, 0, sizeof(*aa));
 
 	/* Prepare request to be resent with ptlrpcd */
@@ -3258,8 +3257,7 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 	req->rq_no_resend = 1;
 	req->rq_pill.rc_fmt = (void *)&worker_format;
 
-	BUILD_BUG_ON(sizeof(*args) > sizeof(req->rq_async_args));
-	args = ptlrpc_req_async_args(req);
+	args = ptlrpc_req_async_args(args, req);
 	args->cb = cb;
 	args->cbdata = cbdata;
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index eb19ca6..d032962 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -696,8 +696,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	ptlrpc_request_set_replen(request);
 	request->rq_interpret_reply = ptlrpc_connect_interpret;
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(request->rq_async_args));
-	aa = ptlrpc_req_async_args(request);
+	aa = ptlrpc_req_async_args(aa, request);
 	memset(aa, 0, sizeof(*aa));
 
 	aa->pcaa_peer_committed = committed_before_reconnect;
-- 
1.8.3.1
