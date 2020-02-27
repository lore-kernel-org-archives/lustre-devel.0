From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:28 -0500
Subject: [lustre-devel] [PATCH 100/622] lustre: mdc: remove obsolete intent
 opcodes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-101-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In enum ldlm_intent_flags, remove the obsolete constants IT_UNLINK,
IT_TRUNC, IT_EXEC, IT_PIN, IT_SETXATTR. Remove any handling code for
these opcodes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11014
Lustre-commit: 511ea5850f25 ("LU-11014 mdc: remove obsolete intent opcodes")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32361
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h  |  1 -
 fs/lustre/include/obd.h                |  4 +---
 fs/lustre/ldlm/ldlm_lock.c             |  2 --
 fs/lustre/mdc/mdc_locks.c              | 44 +++-------------------------------
 fs/lustre/ptlrpc/layout.c              | 15 ------------
 include/uapi/linux/lustre/lustre_idl.h | 14 +++++------
 6 files changed, 11 insertions(+), 69 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 807d080..ed4fc42 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -203,7 +203,6 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_LDLM_INTENT_GETATTR;
 extern struct req_format RQF_LDLM_INTENT_OPEN;
 extern struct req_format RQF_LDLM_INTENT_CREATE;
-extern struct req_format RQF_LDLM_INTENT_UNLINK;
 extern struct req_format RQF_LDLM_INTENT_GETXATTR;
 extern struct req_format RQF_LDLM_CANCEL;
 extern struct req_format RQF_LDLM_CALLBACK;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index de9642f..175a99f 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -700,8 +700,6 @@ static inline int it_to_lock_mode(struct lookup_intent *it)
 		return LCK_PR;
 	else if (it->it_op &  IT_GETXATTR)
 		return LCK_PR;
-	else if (it->it_op &  IT_SETXATTR)
-		return LCK_PW;
 
 	LASSERTF(0, "Invalid it_op: %d\n", it->it_op);
 	return -EINVAL;
@@ -730,7 +728,7 @@ enum md_cli_flags {
  */
 static inline bool it_has_reply_body(const struct lookup_intent *it)
 {
-	return it->it_op & (IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR);
+	return it->it_op & (IT_OPEN | IT_LOOKUP | IT_GETATTR);
 }
 
 struct md_op_data {
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 1bf387a..4f746ad 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -123,8 +123,6 @@ const char *ldlm_it2str(enum ldlm_intent_flags it)
 		return "getattr";
 	case IT_LOOKUP:
 		return "lookup";
-	case IT_UNLINK:
-		return "unlink";
 	case IT_GETXATTR:
 		return "getxattr";
 	case IT_LAYOUT:
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index abbc908..80f2e10 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -430,42 +430,6 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	return req;
 }
 
-static struct ptlrpc_request *mdc_intent_unlink_pack(struct obd_export *exp,
-						     struct lookup_intent *it,
-						     struct md_op_data *op_data)
-{
-	struct ptlrpc_request *req;
-	struct obd_device *obddev = class_exp2obd(exp);
-	struct ldlm_intent *lit;
-	int rc;
-
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-				   &RQF_LDLM_INTENT_UNLINK);
-	if (!req)
-		return ERR_PTR(-ENOMEM);
-
-	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
-			     op_data->op_namelen + 1);
-
-	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return ERR_PTR(rc);
-	}
-
-	/* pack the intent */
-	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
-	lit->opc = (u64)it->it_op;
-
-	/* pack the intended request */
-	mdc_unlink_pack(req, op_data);
-
-	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
-			     obddev->u.cli.cl_default_mds_easize);
-	ptlrpc_request_set_replen(req);
-	return req;
-}
-
 static struct ptlrpc_request *
 mdc_intent_getattr_pack(struct obd_export *exp, struct lookup_intent *it,
 			struct md_op_data *op_data, u32 acl_bufsize)
@@ -820,18 +784,18 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		LASSERT(!policy);
 
 		saved_flags |= LDLM_FL_HAS_INTENT;
-		if (it->it_op & (IT_UNLINK | IT_GETATTR | IT_READDIR))
+		if (it->it_op & (IT_GETATTR | IT_READDIR))
 			policy = &update_policy;
 		else if (it->it_op & IT_LAYOUT)
 			policy = &layout_policy;
-		else if (it->it_op & (IT_GETXATTR | IT_SETXATTR))
+		else if (it->it_op & IT_GETXATTR)
 			policy = &getxattr_policy;
 		else
 			policy = &lookup_policy;
 	}
 
 	generation = obddev->u.cli.cl_import->imp_generation;
-	if (!it || (it->it_op & (IT_CREAT | IT_OPEN_CREAT)))
+	if (!it || (it->it_op & (IT_OPEN | IT_CREAT)))
 		acl_bufsize = imp->imp_connect_data.ocd_max_easize;
 	else
 		acl_bufsize = LUSTRE_POSIX_ACL_MAX_SIZE_OLD;
@@ -845,8 +809,6 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		res_id.name[3] = LDLM_FLOCK;
 	} else if (it->it_op & IT_OPEN) {
 		req = mdc_intent_open_pack(exp, it, op_data, acl_bufsize);
-	} else if (it->it_op & IT_UNLINK) {
-		req = mdc_intent_unlink_pack(exp, it, op_data);
 	} else if (it->it_op & (IT_GETATTR | IT_LOOKUP)) {
 		req = mdc_intent_getattr_pack(exp, it, op_data, acl_bufsize);
 	} else if (it->it_op & IT_READDIR) {
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index ae573a2..70344b9 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -462,15 +462,6 @@
 	&RMF_FILE_SECCTX
 };
 
-static const struct req_msg_field *ldlm_intent_unlink_client[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_DLM_REQ,
-	&RMF_LDLM_INTENT,
-	&RMF_REC_REINT,    /* coincides with mds_reint_unlink_client[] */
-	&RMF_CAPA1,
-	&RMF_NAME
-};
-
 static const struct req_msg_field *ldlm_intent_getxattr_client[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_DLM_REQ,
@@ -756,7 +747,6 @@
 	&RQF_LDLM_INTENT_GETATTR,
 	&RQF_LDLM_INTENT_OPEN,
 	&RQF_LDLM_INTENT_CREATE,
-	&RQF_LDLM_INTENT_UNLINK,
 	&RQF_LDLM_INTENT_GETXATTR,
 	&RQF_LLOG_ORIGIN_HANDLE_CREATE,
 	&RQF_LLOG_ORIGIN_HANDLE_NEXT_BLOCK,
@@ -1431,11 +1421,6 @@ struct req_format RQF_LDLM_INTENT_CREATE =
 			ldlm_intent_create_client, ldlm_intent_getattr_server);
 EXPORT_SYMBOL(RQF_LDLM_INTENT_CREATE);
 
-struct req_format RQF_LDLM_INTENT_UNLINK =
-	DEFINE_REQ_FMT0("LDLM_INTENT_UNLINK",
-			ldlm_intent_unlink_client, ldlm_intent_server);
-EXPORT_SYMBOL(RQF_LDLM_INTENT_UNLINK);
-
 struct req_format RQF_LDLM_INTENT_GETXATTR =
 	DEFINE_REQ_FMT0("LDLM_INTENT_GETXATTR",
 			ldlm_intent_getxattr_client,
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index dc9872cf3..249a3d5 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2190,19 +2190,19 @@ struct ldlm_flock_wire {
 enum ldlm_intent_flags {
 	IT_OPEN		= 0x00000001,
 	IT_CREAT	= 0x00000002,
-	IT_OPEN_CREAT	= 0x00000003,
-	IT_READDIR	= 0x00000004,
+	IT_OPEN_CREAT	= IT_OPEN | IT_CREAT, /* To allow case label. */
+	IT_READDIR	= 0x00000004, /* Used by mdc, not put on the wire. */
 	IT_GETATTR	= 0x00000008,
 	IT_LOOKUP	= 0x00000010,
-	IT_UNLINK	= 0x00000020,
-	IT_TRUNC	= 0x00000040,
+/*	IT_UNLINK	= 0x00000020, Obsolete. */
+/*	IT_TRUNC	= 0x00000040, Obsolete. */
 	IT_GETXATTR	= 0x00000080,
-	IT_EXEC		= 0x00000100,
-	IT_PIN		= 0x00000200,
+/*	IT_EXEC		= 0x00000100, Obsolete. */
+/*	IT_PIN		= 0x00000200, Obsolete. */
 	IT_LAYOUT	= 0x00000400,
 	IT_QUOTA_DQACQ	= 0x00000800,
 	IT_QUOTA_CONN	= 0x00001000,
-	IT_SETXATTR	= 0x00002000,
+/*	IT_SETXATTR	= 0x00002000, Obsolete. */
 	IT_GLIMPSE     = 0x00004000,
 	IT_BRW	       = 0x00008000,
 };
-- 
1.8.3.1
