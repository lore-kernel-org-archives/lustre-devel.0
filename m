From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:52 -0500
Subject: [lustre-devel] [PATCH 244/622] lustre: ptlrpc: manage SELinux
 policy info for metadata ops
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-245-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Add SELinux policy info for following metedata operations:
- create
- open
- unlink
- rename
- getxattr
- setxattr
- setattr
- getattr
- symlink
- hardlink

On server side, get SELinux policy info from nodemap and compare
it with the one received from client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8955
Lustre-commit: 0a773f04b288 ("LU-8955 ptlrpc: manage SELinux policy info for metadata ops")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/24424
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h |  2 +-
 fs/lustre/mdc/mdc_internal.h          |  1 +
 fs/lustre/mdc/mdc_lib.c               | 31 +++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_locks.c             | 23 ++++++++++++++++++++
 fs/lustre/mdc/mdc_reint.c             | 40 +++++++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_request.c           | 17 ++++++++++++---
 fs/lustre/ptlrpc/layout.c             | 32 +++++++++++++++++++---------
 7 files changed, 132 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 9b618fe..378f0b6 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -60,7 +60,7 @@ enum req_location {
 };
 
 /* Maximal number of fields (buffers) in a request message. */
-#define REQ_MAX_FIELD_NR 10
+#define REQ_MAX_FIELD_NR 11
 
 struct req_capsule {
 	struct ptlrpc_request		*rc_req;
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index a5fe164..f75498a 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -57,6 +57,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 void mdc_file_secctx_pack(struct ptlrpc_request *req,
 			  const char *secctx_name,
 			  const void *secctx, size_t secctx_size);
+void mdc_file_sepol_pack(struct ptlrpc_request *req);
 
 void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 00a6be4..980676a 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -138,6 +138,22 @@ void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
 	memcpy(buf, secctx, buf_size);
 }
 
+void mdc_file_sepol_pack(struct ptlrpc_request *req)
+{
+	void *buf;
+	size_t buf_size;
+
+	if (strlen(req->rq_sepol) == 0)
+		return;
+
+	buf = req_capsule_client_get(&req->rq_pill, &RMF_SELINUX_POL);
+	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_SELINUX_POL,
+					RCL_CLIENT);
+
+	LASSERT(buf_size == strlen(req->rq_sepol) + 1);
+	snprintf(buf, strlen(req->rq_sepol) + 1, "%s", req->rq_sepol);
+}
+
 void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
 		      const struct lu_fid *fid)
 {
@@ -192,6 +208,9 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	mdc_file_secctx_pack(req, op_data->op_file_secctx_name,
 			     op_data->op_file_secctx,
 			     op_data->op_file_secctx_size);
+
+	/* pack SELinux policy info if any */
+	mdc_file_sepol_pack(req);
 }
 
 static inline u64 mds_pack_open_flags(u64 flags)
@@ -266,6 +285,9 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		mdc_file_secctx_pack(req, op_data->op_file_secctx_name,
 				     op_data->op_file_secctx,
 				     op_data->op_file_secctx_size);
+
+		/* pack SELinux policy info if any */
+		mdc_file_sepol_pack(req);
 	}
 
 	if (lmm) {
@@ -412,6 +434,9 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->ul_bias = op_data->op_bias;
 
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
+
+	/* pack SELinux policy info if any */
+	mdc_file_sepol_pack(req);
 }
 
 void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
@@ -434,6 +459,9 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec->lk_bias = op_data->op_bias;
 
 	mdc_pack_name(req, &RMF_NAME, op_data->op_name, op_data->op_namelen);
+
+	/* pack SELinux policy info if any */
+	mdc_file_sepol_pack(req);
 }
 
 static void mdc_close_intent_pack(struct ptlrpc_request *req,
@@ -505,6 +533,9 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	if (new)
 		mdc_pack_name(req, &RMF_SYMTGT, new, newlen);
+
+	/* pack SELinux policy info if any */
+	mdc_file_sepol_pack(req);
 }
 
 void mdc_migrate_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 6f4baa6..05447ea 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -315,6 +315,16 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
 			     op_data->op_file_secctx_size);
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return ERR_PTR(rc);
+	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
+
 	rc = ldlm_prep_enqueue_req(exp, req, &cancels, count);
 	if (rc < 0) {
 		ptlrpc_request_free(req);
@@ -422,6 +432,16 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	if (!req)
 		return ERR_PTR(-ENOMEM);
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return ERR_PTR(rc);
+	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
+
 	rc = ldlm_prep_enqueue_req(exp, req, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
@@ -452,6 +472,9 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
 		      ea_vals_buf_size, -1, 0);
 
+	/* get SELinux policy info if any */
+	mdc_file_sepol_pack(req);
+
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER,
 			     GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM);
 
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 0e5f012..86acb4e 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -197,6 +197,16 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
 			     op_data->op_file_secctx_size);
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
+
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
@@ -286,6 +296,16 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
 			     op_data->op_namelen + 1);
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
+
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
@@ -332,6 +352,16 @@ int mdc_link(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
 			     op_data->op_namelen + 1);
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
+
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
@@ -394,6 +424,16 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 		req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
 				     op_data->op_data_size);
 
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
+
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 88e790f0..80e58c8 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -328,11 +328,20 @@ static int mdc_xattr_common(struct obd_export *exp,
 		req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
 				     xattr_namelen);
 	}
-	if (input_size) {
+	if (input_size)
 		LASSERT(input);
-		req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
-				     input_size);
+	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
+			     input_size);
+
+	/* get SELinux policy info if any */
+	rc = sptlrpc_get_sepol(req);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
 	}
+	req_capsule_set_size(&req->rq_pill, &RMF_SELINUX_POL, RCL_CLIENT,
+			     strlen(req->rq_sepol) ?
+			     strlen(req->rq_sepol) + 1 : 0);
 
 	/* Flush local XATTR locks to get rid of a possible cancel RPC */
 	if (opcode == MDS_REINT && fid_is_sane(fid) &&
@@ -393,6 +402,8 @@ static int mdc_xattr_common(struct obd_export *exp,
 		memcpy(tmp, input, input_size);
 	}
 
+	mdc_file_sepol_pack(req);
+
 	if (req_capsule_has_field(&req->rq_pill, &RMF_EADATA, RCL_SERVER))
 		req_capsule_set_size(&req->rq_pill, &RMF_EADATA,
 				     RCL_SERVER, output_size);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index f80c627..9a676ae 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -193,7 +193,8 @@
 	&RMF_EADATA,
 	&RMF_DLM_REQ,
 	&RMF_FILE_SECCTX_NAME,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_create_sym_client[] = {
@@ -204,7 +205,8 @@
 	&RMF_SYMTGT,
 	&RMF_DLM_REQ,
 	&RMF_FILE_SECCTX_NAME,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_open_client[] = {
@@ -215,7 +217,8 @@
 	&RMF_NAME,
 	&RMF_EADATA,
 	&RMF_FILE_SECCTX_NAME,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_open_server[] = {
@@ -232,7 +235,8 @@
 	&RMF_REC_REINT,
 	&RMF_CAPA1,
 	&RMF_NAME,
-	&RMF_DLM_REQ
+	&RMF_DLM_REQ,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_link_client[] = {
@@ -241,7 +245,8 @@
 	&RMF_CAPA1,
 	&RMF_CAPA2,
 	&RMF_NAME,
-	&RMF_DLM_REQ
+	&RMF_DLM_REQ,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_rename_client[] = {
@@ -251,7 +256,8 @@
 	&RMF_CAPA2,
 	&RMF_NAME,
 	&RMF_SYMTGT,
-	&RMF_DLM_REQ
+	&RMF_DLM_REQ,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_migrate_client[] = {
@@ -262,6 +268,7 @@
 	&RMF_NAME,
 	&RMF_SYMTGT,
 	&RMF_DLM_REQ,
+	&RMF_SELINUX_POL,
 	&RMF_MDT_EPOCH,
 	&RMF_CLOSE_DATA,
 	&RMF_EADATA
@@ -292,7 +299,8 @@
 	&RMF_CAPA1,
 	&RMF_NAME,
 	&RMF_EADATA,
-	&RMF_DLM_REQ
+	&RMF_DLM_REQ,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_reint_resync[] = {
@@ -450,7 +458,8 @@
 	&RMF_NAME,
 	&RMF_EADATA,
 	&RMF_FILE_SECCTX_NAME,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *ldlm_intent_open_client[] = {
@@ -463,7 +472,8 @@
 	&RMF_NAME,
 	&RMF_EADATA,
 	&RMF_FILE_SECCTX_NAME,
-	&RMF_FILE_SECCTX
+	&RMF_FILE_SECCTX,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *ldlm_intent_getxattr_client[] = {
@@ -472,6 +482,7 @@
 	&RMF_LDLM_INTENT,
 	&RMF_MDT_BODY,
 	&RMF_CAPA1,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *ldlm_intent_getxattr_server[] = {
@@ -496,7 +507,8 @@
 	&RMF_MDT_BODY,
 	&RMF_CAPA1,
 	&RMF_NAME,
-	&RMF_EADATA
+	&RMF_EADATA,
+	&RMF_SELINUX_POL
 };
 
 static const struct req_msg_field *mds_getxattr_server[] = {
-- 
1.8.3.1
