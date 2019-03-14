From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:51 +1100
Subject: [lustre-devel] [PATCH 25/32] lustre: incorporate BUILD_BUG_ON into
 ptlrpc_req_async_args()
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231128.26912.13060548976707885497.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Every call to ptlrpc_req_async_args() should be preceded by a
BUILD_BUG_ON(), though two aren't.

To improve maintainability, include the BUILD_BUG_ON into the
ptlrpc_req_async_args() macro.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    7 +++--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    3 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    7 ++---
 drivers/staging/lustre/lustre/osc/osc_io.c         |    3 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   29 +++++++-------------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    6 +---
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    3 +-
 7 files changed, 23 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 8c61b02a0ae5..f1326a0286ba 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -277,8 +277,11 @@
  */
 #define OST_MAXREQSIZE		(16 * 1024)
 
-/* Macro to hide a typecast. */
-#define ptlrpc_req_async_args(req) ((void *)&req->rq_async_args)
+/* Macro to hide a typecast and BUILD_BUG. */
+#define ptlrpc_req_async_args(_var, req) ({				\
+		BUILD_BUG_ON(sizeof(*_var) > sizeof(req->rq_async_args)); \
+		(typeof(_var))&req->rq_async_args;			\
+	})
 
 struct ptlrpc_replay_async_args {
 	int		praa_old_state;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index fbb12f540dbd..a1e86a495076 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1986,8 +1986,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	LDLM_DEBUG(lock, "replaying lock:");
 
 	atomic_inc(&req->rq_import->imp_replay_inflight);
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	aa->lock_handle = body->lock_handle[0];
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)replay_lock_interpret;
 	ptlrpcd_add_req(req);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 430c422ed627..9c3f4e9d7a34 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -48,8 +48,8 @@
 #include "mdc_internal.h"
 
 struct mdc_getattr_args {
-	struct obd_export	   *ga_exp;
-	struct md_enqueue_info      *ga_minfo;
+	struct obd_export	*ga_exp;
+	struct md_enqueue_info	*ga_minfo;
 };
 
 int it_open_error(int phase, struct lookup_intent *it)
@@ -1266,8 +1266,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 		return rc;
 	}
 
-	BUILD_BUG_ON(sizeof(*ga) > sizeof(req->rq_async_args));
-	ga = ptlrpc_req_async_args(req);
+	ga = ptlrpc_req_async_args(ga, req);
 	ga->ga_exp = exp;
 	ga->ga_minfo = minfo;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 0b9ed01658e6..efeb94b7dc15 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -696,8 +696,7 @@ static int osc_io_data_version_start(const struct lu_env *env,
 
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_data_version_interpret;
-	BUILD_BUG_ON(sizeof(*dva) > sizeof(req->rq_async_args));
-	dva = ptlrpc_req_async_args(req);
+	dva = ptlrpc_req_async_args(dva, req);
 	dva->dva_oio = oio;
 
 	ptlrpcd_add_req(req);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 88302ff795ae..72437da1d892 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -259,8 +259,7 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		req->rq_interpret_reply =
 			(ptlrpc_interpterer_t)osc_setattr_interpret;
 
-		BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
-		sa = ptlrpc_req_async_args(req);
+		sa = ptlrpc_req_async_args(sa, req);
 		sa->sa_oa = oa;
 		sa->sa_upcall = upcall;
 		sa->sa_cookie = cookie;
@@ -344,8 +343,7 @@ int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
 	}
 
 	req->rq_interpret_reply = osc_ladvise_interpret;
-	BUILD_BUG_ON(sizeof(*la) > sizeof(req->rq_async_args));
-	la = ptlrpc_req_async_args(req);
+	la = ptlrpc_req_async_args(la, req);
 	la->la_oa = oa;
 	la->la_upcall = upcall;
 	la->la_cookie = cookie;
@@ -438,8 +436,7 @@ int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 	ptlrpc_request_set_replen(req);
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
-	BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
-	sa = ptlrpc_req_async_args(req);
+	sa = ptlrpc_req_async_args(sa, req);
 	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
 	sa->sa_cookie = cookie;
@@ -516,8 +513,7 @@ int osc_sync_base(struct osc_object *obj, struct obdo *oa,
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_sync_interpret;
 
-	BUILD_BUG_ON(sizeof(*fa) > sizeof(req->rq_async_args));
-	fa = ptlrpc_req_async_args(req);
+	fa = ptlrpc_req_async_args(fa, req);
 	fa->fa_obj = obj;
 	fa->fa_oa = oa;
 	fa->fa_upcall = upcall;
@@ -1302,8 +1298,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	}
 	ptlrpc_request_set_replen(req);
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	aa->aa_oa = oa;
 	aa->aa_requested_nob = requested_nob;
 	aa->aa_nio_count = niocount;
@@ -1650,7 +1645,7 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	new_req->rq_generation_set = 1;
 	new_req->rq_import_generation = request->rq_import_generation;
 
-	new_aa = ptlrpc_req_async_args(new_req);
+	new_aa = ptlrpc_req_async_args(new_aa, new_req);
 
 	INIT_LIST_HEAD(&new_aa->aa_oaps);
 	list_splice_init(&aa->aa_oaps, &new_aa->aa_oaps);
@@ -1973,8 +1968,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	cl_req_attr_set(env, osc2cl(obj), crattr);
 	lustre_msg_set_jobid(req->rq_reqmsg, crattr->cra_jobid);
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	INIT_LIST_HEAD(&aa->aa_oaps);
 	list_splice_init(&rpc_list, &aa->aa_oaps);
 	INIT_LIST_HEAD(&aa->aa_exts);
@@ -2251,8 +2245,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		if (!rc) {
 			struct osc_enqueue_args *aa;
 
-			BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-			aa = ptlrpc_req_async_args(req);
+			aa = ptlrpc_req_async_args(aa, req);
 			aa->oa_exp = exp;
 			aa->oa_mode = einfo->ei_mode;
 			aa->oa_type = einfo->ei_type;
@@ -2405,8 +2398,7 @@ static int osc_statfs_async(struct obd_export *exp,
 	}
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_statfs_interpret;
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	aa->aa_oi = oinfo;
 
 	ptlrpc_set_add_req(rqset, req);
@@ -2610,8 +2602,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		struct osc_brw_async_args *aa;
 		struct obdo *oa;
 
-		BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
-		aa = ptlrpc_req_async_args(req);
+		aa = ptlrpc_req_async_args(aa, req);
 		oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
 		if (!oa) {
 			ptlrpc_req_finished(req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1ee1ad4ca088..476435633694 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2878,8 +2878,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 
 	LASSERT(req->rq_import->imp_state == LUSTRE_IMP_REPLAY);
 
-	LASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
+	aa = ptlrpc_req_async_args(aa, req);
 	memset(aa, 0, sizeof(*aa));
 
 	/* Prepare request to be resent with ptlrpcd */
@@ -3209,8 +3208,7 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 	req->rq_no_resend = 1;
 	req->rq_pill.rc_fmt = (void *)&worker_format;
 
-	BUILD_BUG_ON(sizeof(*args) > sizeof(req->rq_async_args));
-	args = ptlrpc_req_async_args(req);
+	args = ptlrpc_req_async_args(args, req);
 	args->cb = cb;
 	args->cbdata = cbdata;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index a68b870faad2..db4ed6dbf362 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -690,8 +690,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	ptlrpc_request_set_replen(request);
 	request->rq_interpret_reply = ptlrpc_connect_interpret;
 
-	BUILD_BUG_ON(sizeof(*aa) > sizeof(request->rq_async_args));
-	aa = ptlrpc_req_async_args(request);
+	aa = ptlrpc_req_async_args(aa, request);
 	memset(aa, 0, sizeof(*aa));
 
 	aa->pcaa_peer_committed = committed_before_reconnect;
