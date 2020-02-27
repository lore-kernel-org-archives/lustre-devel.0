From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:49 -0500
Subject: [lustre-devel] [PATCH 241/622] lustre: security: return security
 context for metadata ops
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-242-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Security layer needs to fetch security context of files/dirs
upon metadata ops like lookup, getattr, open, truncate, and
layout, for its own purpose and control checks.
Retrieving the security context consists in a getxattr operation
at the file system level. The fact that the requested metadata
operation and the getxattr are not atomic can create a window
for a dead-lock situation where, based on some access patterns,
all MDT service threads can become stuck waiting for lookup lock
to be released and thus unable to serve getxattr for security context.
Another problem is that sending an additional getxattr request for
every metadata op hurts performance.

This patch introduces a way to get atomicity by having
the MDT return security context upon granted lock reply,
sparing the client an additional getxattr request.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9193
Lustre-commit: fca35f74f9ec ("LU-9193 security: return security context for metadata ops")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/26831
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                |  3 +-
 fs/lustre/llite/llite_internal.h       |  3 ++
 fs/lustre/llite/namei.c                | 60 +++++++++++++++++++++++++++++++--
 fs/lustre/llite/xattr_security.c       | 19 +++++++++++
 fs/lustre/lmv/lmv_intent.c             | 21 ++++++++++--
 fs/lustre/mdc/mdc_locks.c              | 61 +++++++++++++++++++++++++++++++++-
 fs/lustre/mdc/mdc_request.c            |  2 ++
 fs/lustre/ptlrpc/layout.c              |  9 +++--
 include/uapi/linux/lustre/lustre_idl.h |  1 +
 9 files changed, 169 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index ff94092..758efc1 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -778,8 +778,9 @@ struct md_op_data {
 	u64			op_data_version;
 	struct lustre_handle	op_lease_handle;
 
-	/* File security context, for creates. */
+	/* File security context, for creates/metadata ops */
 	const char	       *op_file_secctx_name;
+	u32			op_file_secctx_name_size;
 	void		       *op_file_secctx;
 	u32			op_file_secctx_size;
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d41531b..3c81c3b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -279,6 +279,9 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
 int ll_inode_init_security(struct dentry *dentry, struct inode *inode,
 			   struct inode *dir);
 
+int ll_listsecurity(struct inode *inode, char *secctx_name,
+		    size_t secctx_name_size);
+
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
  * consistency between file size and KMS.
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index e410ff0..ee3ce70 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -592,7 +592,8 @@ struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 
 static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			       struct lookup_intent *it,
-			       struct inode *parent, struct dentry **de)
+			       struct inode *parent, struct dentry **de,
+			       void *secctx, u32 secctxlen)
 {
 	struct inode *inode = NULL;
 	u64 bits = 0;
@@ -605,6 +606,10 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	CDEBUG(D_DENTRY, "it %p it_disposition %x\n", it,
 	       it->it_disposition);
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
+		struct req_capsule *pill = &request->rq_pill;
+		struct mdt_body *body = req_capsule_server_get(pill,
+							       &RMF_MDT_BODY);
+
 		rc = ll_prep_inode(&inode, request, (*de)->d_sb, it);
 		if (rc)
 			return rc;
@@ -623,6 +628,32 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		 * ll_glimpse_size or some equivalent themselves anyway.
 		 * Also see bug 7198.
 		 */
+
+		/* If security context was returned by MDT, put it in
+		 * inode now to save an extra getxattr from security hooks,
+		 * and avoid deadlock.
+		 */
+		if (body->mbo_valid & OBD_MD_SECCTX) {
+			secctx = req_capsule_server_get(pill, &RMF_FILE_SECCTX);
+			secctxlen = req_capsule_get_size(pill,
+							 &RMF_FILE_SECCTX,
+							 RCL_SERVER);
+
+			if (secctxlen)
+				CDEBUG(D_SEC,
+				       "server returned security context for " DFID "\n",
+				       PFID(ll_inode2fid(inode)));
+		}
+
+		if (secctx && secctxlen != 0) {
+			inode_lock(inode);
+			rc = security_inode_notifysecctx(inode, secctx,
+							 secctxlen);
+			inode_unlock(inode);
+			if (rc)
+				CWARN("cannot set security context for " DFID ": rc = %d\n",
+				      PFID(ll_inode2fid(inode)), rc);
+		}
 	}
 
 	alias = ll_splice_alias(inode, *de);
@@ -680,6 +711,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	struct dentry *save = dentry, *retval;
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data = NULL;
+	char secctx_name[XATTR_NAME_MAX + 1];
 	struct inode *inode;
 	u32 opc;
 	int rc;
@@ -742,6 +774,28 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 			*secctx = op_data->op_file_secctx;
 		if (secctxlen)
 			*secctxlen = op_data->op_file_secctx_size;
+	} else {
+		if (secctx)
+			*secctx = NULL;
+		if (secctxlen)
+			*secctxlen = 0;
+	}
+
+	/* ask for security context upon intent */
+	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_OPEN)) {
+		/* get name of security xattr to request to server */
+		rc = ll_listsecurity(parent, secctx_name,
+				     sizeof(secctx_name));
+		if (rc < 0) {
+			CDEBUG(D_SEC,
+			       "cannot get security xattr name for " DFID ": rc = %d\n",
+			       PFID(ll_inode2fid(parent)), rc);
+		} else if (rc > 0) {
+			op_data->op_file_secctx_name = secctx_name;
+			op_data->op_file_secctx_name_size = rc;
+			CDEBUG(D_SEC, "'%.*s' is security xattr for " DFID "\n",
+			       rc, secctx_name, PFID(ll_inode2fid(parent)));
+		}
 	}
 
 	rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
@@ -783,7 +837,9 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 	/* dir layout may change */
 	ll_unlock_md_op_lsm(op_data);
-	rc = ll_lookup_it_finish(req, it, parent, &dentry);
+	rc = ll_lookup_it_finish(req, it, parent, &dentry,
+				 secctx ? *secctx : NULL,
+				 secctxlen ? *secctxlen : 0);
 	if (rc != 0) {
 		ll_intent_release(it);
 		retval = ERR_PTR(rc);
diff --git a/fs/lustre/llite/xattr_security.c b/fs/lustre/llite/xattr_security.c
index e5a52d9..e4fb64a 100644
--- a/fs/lustre/llite/xattr_security.c
+++ b/fs/lustre/llite/xattr_security.c
@@ -132,3 +132,22 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
 		return 0;
 	return err;
 }
+
+/**
+ * Get security context xattr name used by policy.
+ *
+ * \retval >= 0     length of xattr name
+ * \retval < 0      failure to get security context xattr name
+ */
+int
+ll_listsecurity(struct inode *inode, char *secctx_name, size_t secctx_name_size)
+{
+	int rc;
+
+	rc = security_inode_listsecurity(inode, secctx_name, secctx_name_size);
+	if (rc >= secctx_name_size)
+		rc = -ERANGE;
+	else if (rc >= 0)
+		secctx_name[rc] = '\0';
+	return rc;
+}
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 6933f7d..45f1ac5 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -52,7 +52,8 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 			     const struct lu_fid *parent_fid,
 			     struct ptlrpc_request **reqp,
 			     ldlm_blocking_callback cb_blocking,
-			     u64 extra_lock_flags)
+			     u64 extra_lock_flags,
+			     const char *secctx_name, u32 secctx_name_size)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
@@ -109,6 +110,16 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 	CDEBUG(D_INODE, "REMOTE_INTENT with fid=" DFID " -> mds #%u\n",
 	       PFID(&body->mbo_fid1), tgt->ltd_idx);
 
+	/* ask for security context upon intent */
+	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_OPEN) &&
+	    secctx_name_size != 0 && secctx_name) {
+		op_data->op_file_secctx_name = secctx_name;
+		op_data->op_file_secctx_name_size = secctx_name_size;
+		CDEBUG(D_SEC,
+		       "'%.*s' is security xattr to fetch for " DFID "\n",
+		       secctx_name_size, secctx_name, PFID(&body->mbo_fid1));
+	}
+
 	rc = md_intent_lock(tgt->ltd_exp, op_data, it, &req, cb_blocking,
 			    extra_lock_flags);
 	if (rc)
@@ -385,7 +396,9 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	/* Not cross-ref case, just get out of here. */
 	if (unlikely((body->mbo_valid & OBD_MD_MDS))) {
 		rc = lmv_intent_remote(exp, it, &op_data->op_fid1, reqp,
-				       cb_blocking, extra_lock_flags);
+				       cb_blocking, extra_lock_flags,
+				       op_data->op_file_secctx_name,
+				       op_data->op_file_secctx_name_size);
 		if (rc != 0)
 			return rc;
 
@@ -471,7 +484,9 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	/* Not cross-ref case, just get out of here. */
 	if (unlikely((body->mbo_valid & OBD_MD_MDS))) {
 		rc = lmv_intent_remote(exp, it, NULL, reqp, cb_blocking,
-				       extra_lock_flags);
+				       extra_lock_flags,
+				       op_data->op_file_secctx_name,
+				       op_data->op_file_secctx_name_size);
 		if (rc != 0)
 			return rc;
 		body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 55de559..6f4baa6 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -310,7 +310,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
 			     RCL_CLIENT, op_data->op_file_secctx_name ?
-			     strlen(op_data->op_file_secctx_name) + 1 : 0);
+			     op_data->op_file_secctx_name_size : 0);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
 			     op_data->op_file_secctx_size);
@@ -337,6 +337,30 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 			     obddev->u.cli.cl_max_mds_easize);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 
+	if (!(it->it_op & IT_CREAT) && it->it_op & IT_OPEN &&
+	    req_capsule_has_field(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+				  RCL_CLIENT) &&
+	    op_data->op_file_secctx_name_size > 0 &&
+	    op_data->op_file_secctx_name) {
+		char *secctx_name;
+
+		secctx_name = req_capsule_client_get(&req->rq_pill,
+						     &RMF_FILE_SECCTX_NAME);
+		memcpy(secctx_name, op_data->op_file_secctx_name,
+		       op_data->op_file_secctx_name_size);
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX,
+				     RCL_SERVER,
+				     obddev->u.cli.cl_max_mds_easize);
+
+		CDEBUG(D_SEC, "packed '%.*s' as security xattr name\n",
+		       op_data->op_file_secctx_name_size,
+		       op_data->op_file_secctx_name);
+
+	} else {
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX,
+				     RCL_SERVER, 0);
+	}
+
 	/**
 	 * Inline buffer for possible data from Data-on-MDT files.
 	 */
@@ -407,6 +431,8 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	/* pack the intent */
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
 	lit->opc = IT_GETXATTR;
+	CDEBUG(D_INFO, "%s: get xattrs for " DFID "\n",
+	       exp->exp_obd->obd_name, PFID(&op_data->op_fid1));
 
 	/* If the supplied buffer is too small then the server will
 	 * return -ERANGE and llite will fallback to using non cached
@@ -454,12 +480,25 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	struct ldlm_intent *lit;
 	int rc;
 	u32 easize;
+	bool have_secctx = false;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_LDLM_INTENT_GETATTR);
 	if (!req)
 		return ERR_PTR(-ENOMEM);
 
+	/* send name of security xattr to get upon intent */
+	if (it->it_op & (IT_LOOKUP | IT_GETATTR) &&
+	    req_capsule_has_field(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+				  RCL_CLIENT) &&
+	    op_data->op_file_secctx_name_size > 0 &&
+	    op_data->op_file_secctx_name) {
+		have_secctx = true;
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+				     RCL_CLIENT,
+				     op_data->op_file_secctx_name_size);
+	}
+
 	req_capsule_set_size(&req->rq_pill, &RMF_NAME, RCL_CLIENT,
 			     op_data->op_namelen + 1);
 
@@ -483,6 +522,26 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER, easize);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
+
+	if (have_secctx) {
+		char *secctx_name;
+
+		secctx_name = req_capsule_client_get(&req->rq_pill,
+						     &RMF_FILE_SECCTX_NAME);
+		memcpy(secctx_name, op_data->op_file_secctx_name,
+		       op_data->op_file_secctx_name_size);
+
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX,
+				     RCL_SERVER, easize);
+
+		CDEBUG(D_SEC, "packed '%.*s' as security xattr name\n",
+		       op_data->op_file_secctx_name_size,
+		       op_data->op_file_secctx_name);
+	} else {
+		req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX,
+				     RCL_SERVER, 0);
+	}
+
 	ptlrpc_request_set_replen(req);
 	return req;
 }
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index c08a6ee..88e790f0 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -439,6 +439,8 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	LASSERT(obd_md_valid == OBD_MD_FLXATTR ||
 		obd_md_valid == OBD_MD_FLXATTRLS);
 
+	CDEBUG(D_INFO, "%s: get xattr '%s' for " DFID "\n",
+	       exp->exp_obd->obd_name, name, PFID(fid));
 	rc = mdc_xattr_common(exp, &RQF_MDS_GETXATTR, fid, MDS_GETXATTR,
 			      obd_md_valid, name, NULL, 0, buf_size, 0, -1,
 			      req);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 2e74ae1b..1dd18b9 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -417,6 +417,7 @@
 	&RMF_CAPA1,
 	&RMF_CAPA2,
 	&RMF_NIOBUF_INLINE,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *ldlm_intent_getattr_client[] = {
@@ -425,7 +426,8 @@
 	&RMF_LDLM_INTENT,
 	&RMF_MDT_BODY,     /* coincides with mds_getattr_name_client[] */
 	&RMF_CAPA1,
-	&RMF_NAME
+	&RMF_NAME,
+	&RMF_FILE_SECCTX_NAME
 };
 
 static const struct req_msg_field *ldlm_intent_getattr_server[] = {
@@ -434,7 +436,8 @@
 	&RMF_MDT_BODY,
 	&RMF_MDT_MD,
 	&RMF_ACL,
-	&RMF_CAPA1
+	&RMF_CAPA1,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *ldlm_intent_create_client[] = {
@@ -935,7 +938,7 @@ struct req_msg_field RMF_FILE_SECCTX_NAME =
 EXPORT_SYMBOL(RMF_FILE_SECCTX_NAME);
 
 struct req_msg_field RMF_FILE_SECCTX =
-	DEFINE_MSGF("file_secctx", 0, -1, NULL, NULL);
+	DEFINE_MSGF("file_secctx", RMF_F_NO_SIZE_CHECK, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_FILE_SECCTX);
 
 struct req_msg_field RMF_LLOGD_BODY =
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 76068ee..1a1b6c6 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1198,6 +1198,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
 #define OBD_MD_FLOSTLAYOUT	(0x0080000000000000ULL)	/* contain ost_layout */
 #define OBD_MD_FLPROJID		(0x0100000000000000ULL) /* project ID */
+#define OBD_MD_SECCTX        (0x0200000000000000ULL) /* embed security xattr */
 
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
 			   OBD_MD_FLGRPQUOTA | \
-- 
1.8.3.1
