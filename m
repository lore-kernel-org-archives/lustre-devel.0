From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:28 -0500
Subject: [lustre-devel] [PATCH 160/622] lustre: mdc: move empty xattr
 handling to mdc layer
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-161-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Extract duplicated logic around empty xattr handling from several
places in llite and consolidate it in mdc_getxattr().

WC-bug-id: https://jira.whamcloud.com/browse/LU-11380
Lustre-commit: 0f42b388432c ("LU-11380 mdc: move empty xattr handling to mdc layer")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33198
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      | 16 +++++--------
 fs/lustre/llite/xattr.c     | 44 ++++------------------------------
 fs/lustre/mdc/mdc_request.c | 57 ++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 65 insertions(+), 52 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e1fba1c..246d5de 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4391,7 +4391,6 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req;
-	struct mdt_body *body;
 	void *lvbdata;
 	void *lmm;
 	int lmmsize;
@@ -4411,19 +4410,16 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	 * completion AST because it doesn't have a large enough buffer
 	 */
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
-	if (rc == 0)
-		rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-				 OBD_MD_FLXATTR, XATTR_NAME_LOV, lmmsize, &req);
 	if (rc < 0)
 		return rc;
 
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	if (!body) {
-		rc = -EPROTO;
-		goto out;
-	}
+	rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode), OBD_MD_FLXATTR,
+			 XATTR_NAME_LOV, lmmsize, &req);
+	if (rc < 0)
+		return rc;
 
-	lmmsize = body->mbo_eadatasize;
+	lmmsize = rc;
+	rc = 0;
 	if (lmmsize == 0) /* empty layout */ {
 		rc = 0;
 		goto out;
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 636334e..948aaf6 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -326,7 +326,6 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
-	struct mdt_body *body;
 	void *xdata;
 	int rc;
 
@@ -358,57 +357,24 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 		if (rc < 0)
 			goto out_xattr;
 
-		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		LASSERT(body);
-
 		/* only detect the xattr size */
-		if (size == 0) {
-			/* LU-11109: Older MDTs do not distinguish
-			 * between nonexistent xattrs and zero length
-			 * values in this case. Newer MDTs will return
-			 * -ENODATA or set OBD_MD_FLXATTR.
-			 */
-			rc = body->mbo_eadatasize;
+		if (size == 0)
 			goto out;
-		}
 
-		if (size < body->mbo_eadatasize) {
-			CERROR("server bug: replied size %u > %u\n",
-			       body->mbo_eadatasize, (int)size);
+		if (size < rc) {
 			rc = -ERANGE;
 			goto out;
 		}
 
-		if (body->mbo_eadatasize == 0) {
-			/* LU-11109: Newer MDTs set OBD_MD_FLXATTR on
-			 * success so that we can distinguish between
-			 * zero length value and nonexistent xattr.
-			 *
-			 * If OBD_MD_FLXATTR is not set then we keep
-			 * the old behavior and return -ENODATA for
-			 * getxattr() when mbo_eadatasize is 0. But
-			 * -ENODATA only makes sense for getxattr()
-			 * and not for listxattr().
-			 */
-			if (body->mbo_valid & OBD_MD_FLXATTR)
-				rc = 0;
-			else if (valid == OBD_MD_FLXATTR)
-				rc = -ENODATA;
-			else
-				rc = 0;
-			goto out;
-		}
-
 		/* do not need swab xattr data */
 		xdata = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA,
-						     body->mbo_eadatasize);
+						     rc);
 		if (!xdata) {
-			rc = -EFAULT;
+			rc = -EPROTO;
 			goto out;
 		}
 
-		memcpy(buffer, xdata, body->mbo_eadatasize);
-		rc = body->mbo_eadatasize;
+		memcpy(buffer, xdata, rc);
 	}
 
 out_xattr:
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 5cc1e1f..6934e57 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -432,12 +432,63 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 			u64 obd_md_valid, const char *name, size_t buf_size,
 			struct ptlrpc_request **req)
 {
+	struct mdt_body *body;
+	int rc;
+
 	LASSERT(obd_md_valid == OBD_MD_FLXATTR ||
 		obd_md_valid == OBD_MD_FLXATTRLS);
 
-	return mdc_xattr_common(exp, &RQF_MDS_GETXATTR, fid, MDS_GETXATTR,
-				obd_md_valid, name, NULL, 0, buf_size, 0, -1,
-				req);
+	rc = mdc_xattr_common(exp, &RQF_MDS_GETXATTR, fid, MDS_GETXATTR,
+			      obd_md_valid, name, NULL, 0, buf_size, 0, -1,
+			      req);
+	if (rc < 0)
+		goto out;
+
+	body = req_capsule_server_get(&(*req)->rq_pill, &RMF_MDT_BODY);
+	if (!body) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	/* only detect the xattr size */
+	if (buf_size == 0) {
+		/* LU-11109: Older MDTs do not distinguish
+		 * between nonexistent xattrs and zero length
+		 * values in this case. Newer MDTs will return
+		 * -ENODATA or set OBD_MD_FLXATTR.
+		 */
+		rc = body->mbo_eadatasize;
+		goto out;
+	}
+
+	if (body->mbo_eadatasize == 0) {
+		/* LU-11109: Newer MDTs set OBD_MD_FLXATTR on
+		 * success so that we can distinguish between
+		 * zero length value and nonexistent xattr.
+		 *
+		 * If OBD_MD_FLXATTR is not set then we keep
+		 * the old behavior and return -ENODATA for
+		 * getxattr() when mbo_eadatasize is 0. But
+		 * -ENODATA only makes sense for getxattr()
+		 * and not for listxattr().
+		 */
+		if (body->mbo_valid & OBD_MD_FLXATTR)
+			rc = 0;
+		else if (obd_md_valid == OBD_MD_FLXATTR)
+			rc = -ENODATA;
+		else
+			rc = 0;
+		goto out;
+	}
+
+	rc = body->mbo_eadatasize;
+out:
+	if (rc < 0) {
+		ptlrpc_req_finished(*req);
+		*req = NULL;
+	}
+
+	return rc;
 }
 
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
-- 
1.8.3.1
