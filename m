From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:13 -0400
Subject: [lustre-devel] [PATCH 114/151] lustre: acl: prepare small buffer
 for ACL RPC reply
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-115-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

For most of files, their ACL entries are very limited, under
such case, it is unnecessary to prepare very large reply buffer
to hold unknown-sized ACL entries for the getattr/open RPCs.
Instead, we can prepare some relative small buffer, such as the
LUSTRE_POSIX_ACL_MAX_SIZE_OLD (260) bytes, that is equal to the
ACL size before patch 64b2fad22a4eb4727315709e014d8f74c5a7f289.
If the target file has too many ACL entries and exceeds the
prepared reply buffer, then the MDT will reply -ERANGE failure
to the client, and then the client can prepare more large buffer
and try again. Since the file with large ACL is rare case, such
retrying getattr/open RPCs will not affect the real performance
too much.

The advantage is that it reduces the client side RAM pressure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10513
Lustre-commit: 416e88938f68 ("LU-10513 acl: prepare small buffer for ACL RPC reply")
Signed-off-by: Fan Yong <fan.yong@intel.com>
Reviewed-on: https://review.whamcloud.com/28116
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c       | 43 +++++++++++++++++++++--------
 fs/lustre/mdc/mdc_request.c     | 61 +++++++++++++++++++++++++++++++----------
 fs/lustre/ptlrpc/pack_generic.c |  1 +
 fs/lustre/ptlrpc/sec.c          |  1 +
 4 files changed, 79 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 2eb6e8a..0787ba3 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -44,6 +44,7 @@
 #include <lustre_net.h>
 #include <lustre_req_layout.h>
 #include <lustre_swab.h>
+#include <lustre_acl.h>
 
 #include "mdc_internal.h"
 
@@ -244,7 +245,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 static struct ptlrpc_request *
 mdc_intent_open_pack(struct obd_export *exp, struct lookup_intent *it,
-		     struct md_op_data *op_data)
+		     struct md_op_data *op_data, u32 acl_bufsize)
 {
 	struct ptlrpc_request *req;
 	struct obd_device *obddev = class_exp2obd(exp);
@@ -333,8 +334,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     obddev->u.cli.cl_max_mds_easize);
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     req->rq_import->imp_connect_data.ocd_max_easize);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 
 	ptlrpc_request_set_replen(req);
 	return req;
@@ -440,9 +440,9 @@ static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
 	return req;
 }
 
-static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
-						      struct lookup_intent *it,
-						     struct md_op_data *op_data)
+static struct ptlrpc_request *
+mdc_intent_getattr_pack(struct obd_export *exp, struct lookup_intent *it,
+			struct md_op_data *op_data, u32 acl_bufsize)
 {
 	struct ptlrpc_request *req;
 	struct obd_device *obddev = class_exp2obd(exp);
@@ -480,8 +480,7 @@ static struct ptlrpc_request *mdc_intent_getattr_pack(struct obd_export *exp,
 	mdc_getattr_pack(req, valid, it->it_flags, op_data, easize);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, easize);
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     req->rq_import->imp_connect_data.ocd_max_easize);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 	ptlrpc_request_set_replen(req);
 	return req;
 }
@@ -782,6 +781,8 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	struct ldlm_res_id res_id;
 	int generation, resends = 0;
 	struct ldlm_reply *lockrep;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	u32 acl_bufsize;
 	enum lvb_type lvb_type = LVB_T_NONE;
 	int rc;
 
@@ -804,6 +805,11 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	}
 
 	generation = obddev->u.cli.cl_import->imp_generation;
+	if (!it || (it->it_op & (IT_CREAT | IT_OPEN_CREAT)))
+		acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+	else
+		acl_bufsize = LUSTRE_POSIX_ACL_MAX_SIZE_OLD;
+
 resend:
 	flags = saved_flags;
 	if (!it) {
@@ -812,15 +818,15 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 			 einfo->ei_type);
 		res_id.name[3] = LDLM_FLOCK;
 	} else if (it->it_op & IT_OPEN) {
-		req = mdc_intent_open_pack(exp, it, op_data);
+		req = mdc_intent_open_pack(exp, it, op_data, acl_bufsize);
 	} else if (it->it_op & IT_UNLINK) {
 		req = mdc_intent_unlink_pack(exp, it, op_data);
 	} else if (it->it_op & (IT_GETATTR | IT_LOOKUP)) {
-		req = mdc_intent_getattr_pack(exp, it, op_data);
+		req = mdc_intent_getattr_pack(exp, it, op_data, acl_bufsize);
 	} else if (it->it_op & IT_READDIR) {
 		req = mdc_enqueue_pack(exp, 0);
 	} else if (it->it_op & IT_LAYOUT) {
-		if (!imp_connect_lvb_type(class_exp2cliimp(exp)))
+		if (!imp_connect_lvb_type(imp))
 			return -EOPNOTSUPP;
 		req = mdc_intent_layout_pack(exp, it, op_data);
 		lvb_type = LVB_T_LAYOUT;
@@ -926,6 +932,15 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		}
 	}
 
+	if ((int)lockrep->lock_policy_res2 == -ERANGE &&
+	    it->it_op & (IT_OPEN | IT_GETATTR | IT_LOOKUP) &&
+	    acl_bufsize != imp->imp_connect_data.ocd_max_easize) {
+		mdc_clear_replay_flag(req, -ERANGE);
+		ptlrpc_req_finished(req);
+		acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+		goto resend;
+	}
+
 	rc = mdc_finish_enqueue(exp, req, einfo, it, lockh, rc);
 	if (rc < 0) {
 		if (lustre_handle_is_used(lockh)) {
@@ -1284,7 +1299,11 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	       PFID(&op_data->op_fid1), ldlm_it2str(it->it_op), it->it_flags);
 
 	fid_build_reg_res_name(&op_data->op_fid1, &res_id);
-	req = mdc_intent_getattr_pack(exp, it, op_data);
+	/* If the MDT return -ERANGE because of large ACL, then the sponsor
+	 * of the async getattr RPC will handle that by itself.
+	 */
+	req = mdc_intent_getattr_pack(exp, it, op_data,
+				      LUSTRE_POSIX_ACL_MAX_SIZE_OLD);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index dd9ab5a..e344e78 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -188,10 +188,23 @@ static int mdc_getattr_common(struct obd_export *exp,
 	return 0;
 }
 
+static void mdc_reset_acl_req(struct ptlrpc_request *req)
+{
+	spin_lock(&req->rq_early_free_lock);
+	sptlrpc_cli_free_repbuf(req);
+	req->rq_repbuf = NULL;
+	req->rq_repbuf_len = 0;
+	req->rq_repdata = NULL;
+	req->rq_reqdata_len = 0;
+	spin_unlock(&req->rq_early_free_lock);
+}
+
 static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		       struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	u32 acl_bufsize = LUSTRE_POSIX_ACL_MAX_SIZE_OLD;
 	int rc;
 
 	/* Single MDS without an LMV case */
@@ -199,8 +212,9 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		op_data->op_mds = 0;
 		return 0;
 	}
+
 	*request = NULL;
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_MDS_GETATTR);
+	req = ptlrpc_request_alloc(imp, &RQF_MDS_GETATTR);
 	if (!req)
 		return -ENOMEM;
 
@@ -210,20 +224,28 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
+again:
 	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
 		      op_data->op_mode, -1, 0);
-
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     req->rq_import->imp_connect_data.ocd_max_easize);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_getattr_common(exp, req);
-	if (rc)
+	if (rc) {
+		if (rc == -ERANGE &&
+		    acl_bufsize != imp->imp_connect_data.ocd_max_easize) {
+			acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+			mdc_reset_acl_req(req);
+			goto again;
+		}
+
 		ptlrpc_req_finished(req);
-	else
+	} else {
 		*request = req;
+	}
+
 	return rc;
 }
 
@@ -231,11 +253,12 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 			    struct ptlrpc_request **request)
 {
 	struct ptlrpc_request *req;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	u32 acl_bufsize = LUSTRE_POSIX_ACL_MAX_SIZE_OLD;
 	int rc;
 
 	*request = NULL;
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-				   &RQF_MDS_GETATTR_NAME);
+	req = ptlrpc_request_alloc(imp, &RQF_MDS_GETATTR_NAME);
 	if (!req)
 		return -ENOMEM;
 
@@ -248,9 +271,6 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 	}
 
-	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
-		      op_data->op_mode, op_data->op_suppgids[0], 0);
-
 	if (op_data->op_name) {
 		char *name = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
 
@@ -259,17 +279,28 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 		memcpy(name, op_data->op_name, op_data->op_namelen);
 	}
 
+again:
+	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
+		      op_data->op_mode, op_data->op_suppgids[0], 0);
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
 			     op_data->op_mode);
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     req->rq_import->imp_connect_data.ocd_max_easize);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_getattr_common(exp, req);
-	if (rc)
+	if (rc) {
+		if (rc == -ERANGE &&
+		    acl_bufsize != imp->imp_connect_data.ocd_max_easize) {
+			acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+			mdc_reset_acl_req(req);
+			goto again;
+		}
+
 		ptlrpc_req_finished(req);
-	else
+	} else {
 		*request = req;
+	}
+
 	return rc;
 }
 
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index cac4b8d..1face33 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -164,6 +164,7 @@ u32 lustre_packed_msg_size(struct lustre_msg *msg)
 		return 0;
 	}
 }
+EXPORT_SYMBOL(lustre_packed_msg_size);
 
 void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, u32 *lens,
 			char **bufs)
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 21055a3..54ca97c 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -1680,6 +1680,7 @@ void sptlrpc_cli_free_repbuf(struct ptlrpc_request *req)
 	policy->sp_cops->free_repbuf(ctx->cc_sec, req);
 	req->rq_repmsg = NULL;
 }
+EXPORT_SYMBOL(sptlrpc_cli_free_repbuf);
 
 static int sptlrpc_svc_install_rvs_ctx(struct obd_import *imp,
 				       struct ptlrpc_svc_ctx *ctx)
-- 
1.8.3.1
