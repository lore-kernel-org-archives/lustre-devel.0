From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:46 -0500
Subject: [lustre-devel] [PATCH 13/28] lustre: llite: pass name in getattr by
 FID
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Now parent FID is packed in getattr_by_FID request
(see https://review.whamcloud.com/39290), it should also pass in name
from llite, so that lmv can replace fid1 with stripe FID, otherwise
MDS may treat sub files under striped directory as remote object.

Note, the name is not packed in request, because if it's packed, MDS
will getattr by name instead of FID.

Fixes: 3a3a9eeaa ("lustre: llite: pack parent FID in getattr")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13437
Lustre-commit: 90ebab5833007d ("LU-13437 llite: pass name in getattr by FID")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40219
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |  1 +
 fs/lustre/llite/file.c      | 15 +++++++++++----
 fs/lustre/llite/llite_lib.c |  4 +++-
 fs/lustre/lmv/lmv_intent.c  | 22 +++++++++++++++++++---
 fs/lustre/lmv/lmv_obd.c     |  8 ++++++--
 5 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 39e3d51..a017997 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -704,6 +704,7 @@ enum md_op_flags {
 	MF_MDC_CANCEL_FID3	= BIT(2),
 	MF_MDC_CANCEL_FID4	= BIT(3),
 	MF_GET_MDT_IDX		= BIT(4),
+	MF_GETATTR_BY_FID	= BIT(5),
 };
 
 enum md_cli_flags {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 0a9a689..3ba9152 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4587,22 +4587,29 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 	};
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
+	const char *name = NULL;
+	size_t namelen = 0;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),name=%pd\n",
 	       PFID(ll_inode2fid(inode)), inode, dentry);
 
-	if (exp_connect_flags2(exp) & OBD_CONNECT2_GETATTR_PFID)
+	if (exp_connect_flags2(exp) & OBD_CONNECT2_GETATTR_PFID) {
 		parent = dentry->d_parent->d_inode;
-	else
+		name = dentry->d_name.name;
+		namelen = dentry->d_name.len;
+	} else {
 		parent = inode;
+	}
 
-	/* Call getattr by fid, so do not provide name at all. */
-	op_data = ll_prep_md_op_data(NULL, parent, inode, NULL, 0, 0,
+	op_data = ll_prep_md_op_data(NULL, parent, inode, name, namelen, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	/* Call getattr by fid */
+	if (exp_connect_flags2(exp) & OBD_CONNECT2_GETATTR_PFID)
+		op_data->op_flags = MF_GETATTR_BY_FID;
 	rc = md_intent_lock(exp, op_data, &oit, &req, &ll_md_blocking_ast, 0);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 8ef2437..d94c6ca 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2811,7 +2811,9 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		if (namelen > ll_i2sbi(i1)->ll_namelen)
 			return ERR_PTR(-ENAMETOOLONG);
 
-		if (!lu_name_is_valid_2(name, namelen))
+		/* "/" is not valid name, but it's allowed */
+		if (!lu_name_is_valid_2(name, namelen) &&
+		    strncmp("/", name, namelen) != 0)
 			return ERR_PTR(-EINVAL);
 	}
 
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 3960b93..ad59b64 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -448,13 +448,29 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	}
 
 retry:
-	if (op_data->op_name) {
+	if (op_data->op_flags & MF_GETATTR_BY_FID) {
+		/* getattr by FID, replace fid1 with stripe FID */
+		LASSERT(op_data->op_name);
+		tgt = lmv_locate_tgt(lmv, op_data);
+		if (IS_ERR(tgt))
+			return PTR_ERR(tgt);
+
+		/* name is used to locate stripe target, clear it here
+		 * to avoid packing name in request, so that MDS knows
+		 * it's getattr by FID.
+		 */
+		op_data->op_name = NULL;
+		op_data->op_namelen = 0;
+
+		/* getattr request is sent to MDT where fid2 inode is */
+		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
+	} else if (op_data->op_name) {
+		/* getattr by name */
 		tgt = lmv_locate_tgt(lmv, op_data);
 		if (!fid_is_sane(&op_data->op_fid2))
 			fid_zero(&op_data->op_fid2);
-	} else if (fid_is_sane(&op_data->op_fid2)) {
-		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
 	} else {
+		/* old way to getattr by FID, parent FID not packed */
 		tgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
 	}
 	if (IS_ERR(tgt))
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 5a75c69..fa1dae5 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1513,6 +1513,9 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 	return ERR_PTR(-ENODEV);
 }
 
+/* locate MDT by file name, for striped directory, the file name hash decides
+ * which stripe its dirent is stored.
+ */
 static struct lmv_tgt_desc *
 lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 		       const char *name, int namelen, struct lu_fid *fid,
@@ -1564,8 +1567,9 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
  * For plain direcotry, it just locate the MDT of op_data->op_fid1.
  *
  * @lmv:	LMV device
- * @op_data:	client MD stack parameters, name, namelen
- *		mds_num etc.
+ * @op_data:	client MD stack parameters, name, namelen etc,
+ *		op_mds and op_fid1 will be updated if op_mea1
+ *		indicates fid1 represents a striped directory.
  *
  * Returns:	pointer to the lmv_tgt_desc if succeed.
  *		ERR_PTR(errno) if failed.
-- 
1.8.3.1
