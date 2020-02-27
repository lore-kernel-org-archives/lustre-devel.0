From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:12 -0500
Subject: [lustre-devel] [PATCH 564/622] lustre: llite: fetch default layout
 for a directory
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-565-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jian Yu <yujian@whamcloud.com>

For a directory that does not have trusted.lov xattr, the current
"lfs getstripe" will only print the stripe_count, stripe_size,
and stripe_index that are fetched from the /sys/fs/lustre/lov values.
It doesn't show the actual default layout that will be used when
new files will be created in that directory.

This patch fixes the above issue in ll_dir_getstripe_default() by
fetching the layout from root FID after ll_dir_get_default_layout()
returns -ENODATA from a directory that does not have trusted.lov xattr.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11656
Lustre-commit: 3e8fa8a7396c ("LU-11656 llite: fetch default layout for a directory")
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36609
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                  | 102 ++++++++++++++++++++++++++++-----
 fs/lustre/llite/llite_internal.h       |   9 ++-
 fs/lustre/llite/xattr.c                |   7 ++-
 include/uapi/linux/lustre/lustre_fid.h |   7 +++
 4 files changed, 107 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index c38862e..b1ec905 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -635,16 +635,10 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	return rc;
 }
 
-/**
- * This function will be used to get default LOV/LMV/Default LMV
- * @valid will be used to indicate which stripe it will retrieve
- *	OBD_MD_MEA		LMV stripe EA
- *	OBD_MD_DEFAULT_MEA	Default LMV stripe EA
- *	otherwise		Default LOV EA.
- * Each time, it can only retrieve 1 stripe EA
- **/
-int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
-		     struct ptlrpc_request **request, u64 valid)
+static int ll_dir_get_default_layout(struct inode *inode, void **plmm,
+				     int *plmm_size,
+				     struct ptlrpc_request **request, u64 valid,
+				     enum get_default_layout_type type)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct mdt_body *body;
@@ -652,6 +646,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 	struct ptlrpc_request *req = NULL;
 	int rc, lmmsize;
 	struct md_op_data *op_data;
+	struct lu_fid fid;
 
 	rc = ll_get_max_mdsize(sbi, &lmmsize);
 	if (rc)
@@ -664,11 +659,19 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		return PTR_ERR(op_data);
 
 	op_data->op_valid = valid | OBD_MD_FLEASIZE | OBD_MD_FLDIREA;
+
+	if (type == GET_DEFAULT_LAYOUT_ROOT) {
+		lu_root_fid(&op_data->op_fid1);
+		fid = op_data->op_fid1;
+	} else {
+		fid = *ll_inode2fid(inode);
+	}
+
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
 		CDEBUG(D_INFO, "md_getattr failed on inode " DFID ": rc %d\n",
-		       PFID(ll_inode2fid(inode)), rc);
+		       PFID(&fid), rc);
 		goto out;
 	}
 
@@ -730,6 +733,70 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 	return rc;
 }
 
+/**
+ * This function will be used to get default LOV/LMV/Default LMV
+ * @valid will be used to indicate which stripe it will retrieve.
+ * If the directory does not have its own default layout, then the
+ * function will request the default layout from root FID.
+ *	OBD_MD_MEA		LMV stripe EA
+ *	OBD_MD_DEFAULT_MEA	Default LMV stripe EA
+ *	otherwise		Default LOV EA.
+ * Each time, it can only retrieve 1 stripe EA
+ */
+int ll_dir_getstripe_default(struct inode *inode, void **plmm, int *plmm_size,
+			     struct ptlrpc_request **request,
+			     struct ptlrpc_request **root_request,
+			     u64 valid)
+{
+	struct ptlrpc_request *req = NULL;
+	struct ptlrpc_request *root_req = NULL;
+	struct lov_mds_md *lmm = NULL;
+	int lmm_size = 0;
+	int rc = 0;
+
+	rc = ll_dir_get_default_layout(inode, (void **)&lmm, &lmm_size,
+				       &req, valid, 0);
+	if (rc == -ENODATA && !fid_is_root(ll_inode2fid(inode)) &&
+	    !(valid & (OBD_MD_MEA|OBD_MD_DEFAULT_MEA)) && root_request)
+		rc = ll_dir_get_default_layout(inode, (void **)&lmm, &lmm_size,
+					       &root_req, valid,
+					       GET_DEFAULT_LAYOUT_ROOT);
+
+	*plmm = lmm;
+	*plmm_size = lmm_size;
+	*request = req;
+	if (root_request)
+		*root_request = root_req;
+
+	return rc;
+}
+
+/**
+ * This function will be used to get default LOV/LMV/Default LMV
+ * @valid will be used to indicate which stripe it will retrieve
+ *	OBD_MD_MEA		LMV stripe EA
+ *	OBD_MD_DEFAULT_MEA	Default LMV stripe EA
+ *	otherwise		Default LOV EA.
+ * Each time, it can only retrieve 1 stripe EA
+ */
+int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
+		     struct ptlrpc_request **request, u64 valid)
+{
+	struct ptlrpc_request *req = NULL;
+	struct lov_mds_md *lmm = NULL;
+	int lmm_size = 0;
+	int rc = 0;
+
+	rc = ll_dir_get_default_layout(inode, (void **)&lmm, &lmm_size,
+				       &req, valid, 0);
+
+	*plmm = lmm;
+	*plmm_size = lmm_size;
+	*request = req;
+
+	return rc;
+}
+
 int ll_get_mdt_idx_by_fid(struct ll_sb_info *sbi, const struct lu_fid *fid)
 {
 	struct md_op_data *op_data;
@@ -1465,6 +1532,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lmv_user_md __user *ulmv;
 		struct lmv_user_md lum;
 		struct ptlrpc_request *request = NULL;
+		struct ptlrpc_request *root_request = NULL;
 		struct lmv_user_md *tmp = NULL;
 		union lmv_mds_md *lmm = NULL;
 		u64 valid = 0;
@@ -1493,8 +1561,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		else
 			return -EINVAL;
 
-		rc = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize, &request,
-				      valid);
+		rc = ll_dir_getstripe_default(inode, (void **)&lmm, &lmmsize,
+					      &request, &root_request, valid);
 		if (rc)
 			goto finish_req;
 
@@ -1595,6 +1663,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(tmp);
 finish_req:
 		ptlrpc_req_finished(request);
+		ptlrpc_req_finished(root_request);
 		return rc;
 	}
 	case LL_IOC_RMFID:
@@ -1611,6 +1680,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case IOC_MDC_GETFILEINFO_OLD:
 	case IOC_MDC_GETFILESTRIPE: {
 		struct ptlrpc_request *request = NULL;
+		struct ptlrpc_request *root_request = NULL;
 		struct lov_user_md __user *lump;
 		struct lov_mds_md *lmm = NULL;
 		struct mdt_body *body;
@@ -1632,8 +1702,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			rc = ll_lov_getstripe_ea_info(inode, filename, &lmm,
 						      &lmmsize, &request);
 		} else {
-			rc = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize,
-					      &request, 0);
+			rc = ll_dir_getstripe_default(inode, (void **)&lmm,
+						      &lmmsize, &request,
+						      &root_request, 0);
 		}
 
 		if (request) {
@@ -1786,6 +1857,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 out_req:
 		ptlrpc_req_finished(request);
+		ptlrpc_req_finished(root_request);
 		if (filename)
 			ll_putname(filename);
 		return rc;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index fe9d568..def4df0 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -841,6 +841,10 @@ struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 			     u64 offset);
 void ll_release_page(struct inode *inode, struct page *page, bool remove);
 
+enum get_default_layout_type {
+	GET_DEFAULT_LAYOUT_ROOT = 1,
+};
+
 /* llite/namei.c */
 extern const struct inode_operations ll_special_inode_operations;
 
@@ -911,7 +915,10 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct ptlrpc_request **request);
 int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		     int set_default);
-int ll_dir_getstripe(struct inode *inode, void **lmmp, int *lmm_size,
+int ll_dir_getstripe_default(struct inode *inode, void **lmmp,
+			     int *lmm_size, struct ptlrpc_request **request,
+			     struct ptlrpc_request **root_request, u64 valid);
+int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		     struct ptlrpc_request **request, u64 valid);
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
 int ll_merge_attr(const struct lu_env *env, struct inode *inode);
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 7134f10..e76d2c3 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -522,11 +522,12 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		return rc;
 	} else if (S_ISDIR(inode->i_mode)) {
 		struct ptlrpc_request *req = NULL;
+		struct ptlrpc_request *root_req = NULL;
 		struct lov_mds_md *lmm = NULL;
 		int lmm_size = 0;
 
-		rc = ll_dir_getstripe(inode, (void **)&lmm, &lmm_size,
-				      &req, 0);
+		rc = ll_dir_getstripe_default(inode, (void **)&lmm, &lmm_size,
+					      &req, &root_req, 0);
 		if (rc < 0)
 			goto out_req;
 
@@ -545,6 +546,8 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 out_req:
 		if (req)
 			ptlrpc_req_finished(req);
+		if (root_req)
+			ptlrpc_req_finished(root_req);
 
 		return rc;
 	} else {
diff --git a/include/uapi/linux/lustre/lustre_fid.h b/include/uapi/linux/lustre/lustre_fid.h
index 79574c0..d6e59cc 100644
--- a/include/uapi/linux/lustre/lustre_fid.h
+++ b/include/uapi/linux/lustre/lustre_fid.h
@@ -135,6 +135,13 @@ static inline bool fid_is_mdt0(const struct lu_fid *fid)
 	return fid_seq_is_mdt0(fid_seq(fid));
 }
 
+static inline void lu_root_fid(struct lu_fid *fid)
+{
+	fid->f_seq = FID_SEQ_ROOT;
+	fid->f_oid = FID_OID_ROOT;
+	fid->f_ver = 0;
+}
+
 /**
  * Check if a fid is igif or not.
  *
-- 
1.8.3.1
