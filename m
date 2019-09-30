From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:41 -0400
Subject: [lustre-devel] [PATCH 082/151] lustre: llite: simplify
 ll_inode_revalidate()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-83-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

ll_inode_revalidate() is only called by ll_getattr() so move the
contents of ll_inode_revalidate() to ll_getattr() and rename
__ll_inode_revalidate() to ll_inode_revalidate().

WC-bug-id: https://jira.whamcloud.com/browse/LU-8402
Lustre-commit: a430c3376c6b ("LU-8402 llite: simplify ll_inode_revalidate()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30036
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 75 +++++++++++++++++++++-----------------------------
 1 file changed, 31 insertions(+), 44 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 7f04e4f..47e270d 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3733,26 +3733,23 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 	return rc;
 }
 
-static int __ll_inode_revalidate(struct dentry *dentry,
-				 enum ldlm_intent_flags op)
+static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 {
 	struct inode *inode = d_inode(dentry);
+	struct obd_export *exp = ll_i2mdexp(inode);
 	struct lookup_intent oit = {
 		.it_op = op,
 	};
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
-	struct obd_export *exp;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p),name=%pd\n",
 	       PFID(ll_inode2fid(inode)), inode, dentry);
 
-	exp = ll_i2mdexp(inode);
-
 	/* Call getattr by fid, so do not provide name at all. */
-	op_data = ll_prep_md_op_data(NULL, d_inode(dentry), d_inode(dentry),
-				     NULL, 0, 0, LUSTRE_OPC_ANY, NULL);
+	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
@@ -3809,30 +3806,21 @@ static int ll_merge_md_attr(struct inode *inode)
 	return 0;
 }
 
-static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
+int ll_getattr(const struct path *path, struct kstat *stat,
+	       u32 request_mask, unsigned int flags)
 {
-	struct inode *inode = d_inode(dentry);
+	struct inode *inode = d_inode(path->dentry);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc;
 
-	rc = __ll_inode_revalidate(dentry, op);
-	if (rc != 0)
-		return rc;
-
-	/* if object isn't regular file, don't validate size */
-	if (!S_ISREG(inode->i_mode)) {
-		if (S_ISDIR(inode->i_mode) &&
-		    ll_i2info(inode)->lli_lsm_md) {
-			rc = ll_merge_md_attr(inode);
-			if (rc)
-				return rc;
-		}
+	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR, 1);
 
-		inode->i_atime.tv_sec = ll_i2info(inode)->lli_atime;
-		inode->i_mtime.tv_sec = ll_i2info(inode)->lli_mtime;
-		inode->i_ctime.tv_sec = ll_i2info(inode)->lli_ctime;
-	} else {
-		struct ll_inode_info *lli = ll_i2info(inode);
+	rc = ll_inode_revalidate(path->dentry, IT_GETATTR);
+	if (rc < 0)
+		return rc;
 
+	if (S_ISREG(inode->i_mode)) {
 		/* In case of restore, the MDT has the right size and has
 		 * already send it back without granting the layout lock,
 		 * inode is up-to-date so glimpse is useless.
@@ -3840,25 +3828,24 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 		 * restore the MDT holds the layout lock so the glimpse will
 		 * block up to the end of restore (getattr will block)
 		 */
-		if (!test_bit(LLIF_FILE_RESTORING, &lli->lli_flags))
+		if (!test_bit(LLIF_FILE_RESTORING, &lli->lli_flags)) {
 			rc = ll_glimpse_size(inode);
-	}
-	return rc;
-}
-
-int ll_getattr(const struct path *path, struct kstat *stat,
-	       u32 request_mask, unsigned int flags)
-{
-	struct inode *inode = d_inode(path->dentry);
-	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct ll_inode_info *lli = ll_i2info(inode);
-	int res;
-
-	res = ll_inode_revalidate(path->dentry, IT_GETATTR);
-	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR, 1);
+			if (rc < 0)
+				return rc;
+		}
+	} else {
+		/* If object isn't regular a file then don't validate size. */
+		if (S_ISDIR(inode->i_mode) &&
+		    lli->lli_lsm_md != NULL) {
+			rc = ll_merge_md_attr(inode);
+			if (rc < 0)
+				return rc;
+		}
 
-	if (res)
-		return res;
+		inode->i_atime.tv_sec = lli->lli_atime;
+		inode->i_mtime.tv_sec = lli->lli_mtime;
+		inode->i_ctime.tv_sec = lli->lli_ctime;
+	}
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_GETATTR_DELAY, 30);
 
@@ -3948,7 +3935,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	*/
 
 	if (is_root_inode(inode)) {
-		rc = __ll_inode_revalidate(inode->i_sb->s_root, IT_LOOKUP);
+		rc = ll_inode_revalidate(inode->i_sb->s_root, IT_LOOKUP);
 		if (rc)
 			return rc;
 	}
-- 
1.8.3.1
