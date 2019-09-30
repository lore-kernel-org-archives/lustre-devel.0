From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:40 -0400
Subject: [lustre-devel] [PATCH 081/151] lustre: llite: assume
 OBD_CONNECT_ATTRFID
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-82-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

OBD_CONNECT_ATTRFID has been supported by MDSs since before 1.6 so add
it to the client side required flags and remove some code to handle
servers that do not support it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8402
Lustre-commit: deaef32d1fd6 ("LU-8402 llite: assume OBD_CONNECT_ATTRFID")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30010
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                 | 112 +++++++++++----------------------
 include/uapi/linux/lustre/lustre_idl.h |   1 +
 2 files changed, 39 insertions(+), 74 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 164948c..7f04e4f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3733,10 +3733,15 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 	return rc;
 }
 
-static int __ll_inode_revalidate(struct dentry *dentry, u64 ibits)
+static int __ll_inode_revalidate(struct dentry *dentry,
+				 enum ldlm_intent_flags op)
 {
 	struct inode *inode = d_inode(dentry);
+	struct lookup_intent oit = {
+		.it_op = op,
+	};
 	struct ptlrpc_request *req = NULL;
+	struct md_op_data *op_data;
 	struct obd_export *exp;
 	int rc = 0;
 
@@ -3745,79 +3750,40 @@ static int __ll_inode_revalidate(struct dentry *dentry, u64 ibits)
 
 	exp = ll_i2mdexp(inode);
 
-	/* XXX: Enable OBD_CONNECT_ATTRFID to reduce unnecessary getattr RPC.
-	 *      But under CMD case, it caused some lock issues, should be fixed
-	 *      with new CMD ibits lock. See bug 12718
-	 */
-	if (exp_connect_flags(exp) & OBD_CONNECT_ATTRFID) {
-		struct lookup_intent oit = { .it_op = IT_GETATTR };
-		struct md_op_data *op_data;
-
-		if (ibits == MDS_INODELOCK_LOOKUP)
-			oit.it_op = IT_LOOKUP;
-
-		/* Call getattr by fid, so do not provide name at all. */
-		op_data = ll_prep_md_op_data(NULL, inode,
-					     inode, NULL, 0, 0,
-					     LUSTRE_OPC_ANY, NULL);
-		if (IS_ERR(op_data))
-			return PTR_ERR(op_data);
-
-		rc = md_intent_lock(exp, op_data, &oit, &req,
-				    &ll_md_blocking_ast, 0);
-		ll_finish_md_op_data(op_data);
-		if (rc < 0) {
-			rc = ll_inode_revalidate_fini(inode, rc);
-			goto out;
-		}
-
-		rc = ll_revalidate_it_finish(req, &oit, inode);
-		if (rc != 0) {
-			ll_intent_release(&oit);
-			goto out;
-		}
-
-		/* Unlinked? Unhash dentry, so it is not picked up later by
-		 * do_lookup() -> ll_revalidate_it(). We cannot use d_drop
-		 * here to preserve get_cwd functionality on 2.6.
-		 * Bug 10503
-		 */
-		if (!d_inode(dentry)->i_nlink) {
-			spin_lock(&inode->i_lock);
-			d_lustre_invalidate(dentry, 0);
-			spin_unlock(&inode->i_lock);
-		}
-
-		ll_lookup_finish_locks(&oit, inode);
-	} else if (!ll_have_md_lock(d_inode(dentry), &ibits, LCK_MINMODE)) {
-		struct ll_sb_info *sbi = ll_i2sbi(d_inode(dentry));
-		u64 valid = OBD_MD_FLGETATTR;
-		struct md_op_data *op_data;
-		int ealen = 0;
-
-		if (S_ISREG(inode->i_mode)) {
-			rc = ll_get_default_mdsize(sbi, &ealen);
-			if (rc)
-				return rc;
-			valid |= OBD_MD_FLEASIZE | OBD_MD_FLMODEASIZE;
-		}
+	/* Call getattr by fid, so do not provide name at all. */
+	op_data = ll_prep_md_op_data(NULL, d_inode(dentry), d_inode(dentry),
+				     NULL, 0, 0, LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
 
-		op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL,
-					     0, ealen, LUSTRE_OPC_ANY,
-					     NULL);
-		if (IS_ERR(op_data))
-			return PTR_ERR(op_data);
+	rc = md_intent_lock(exp, op_data, &oit, &req, &ll_md_blocking_ast, 0);
+	ll_finish_md_op_data(op_data);
+	if (rc < 0) {
+		rc = ll_inode_revalidate_fini(inode, rc);
+		goto out;
+	}
 
-		op_data->op_valid = valid;
-		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
-		ll_finish_md_op_data(op_data);
-		if (rc)
-			return ll_inode_revalidate_fini(inode, rc);
+	rc = ll_revalidate_it_finish(req, &oit, inode);
+	if (rc != 0) {
+		ll_intent_release(&oit);
+		goto out;
+	}
 
-		rc = ll_prep_inode(&inode, req, NULL, NULL);
+	/* Unlinked? Unhash dentry, so it is not picked up later by
+	 * do_lookup() -> ll_revalidate_it(). We cannot use d_drop
+	 * here to preserve get_cwd functionality on 2.6.
+	 * Bug 10503
+	 */
+	if (!d_inode(dentry)->i_nlink) {
+		spin_lock(&inode->i_lock);
+		d_lustre_invalidate(dentry, 0);
+		spin_unlock(&inode->i_lock);
 	}
+
+	ll_lookup_finish_locks(&oit, inode);
 out:
 	ptlrpc_req_finished(req);
+
 	return rc;
 }
 
@@ -3843,12 +3809,12 @@ static int ll_merge_md_attr(struct inode *inode)
 	return 0;
 }
 
-static int ll_inode_revalidate(struct dentry *dentry, u64 ibits)
+static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 {
 	struct inode *inode = d_inode(dentry);
 	int rc;
 
-	rc = __ll_inode_revalidate(dentry, ibits);
+	rc = __ll_inode_revalidate(dentry, op);
 	if (rc != 0)
 		return rc;
 
@@ -3888,8 +3854,7 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int res;
 
-	res = ll_inode_revalidate(path->dentry,
-				  MDS_INODELOCK_UPDATE | MDS_INODELOCK_LOOKUP);
+	res = ll_inode_revalidate(path->dentry, IT_GETATTR);
 	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR, 1);
 
 	if (res)
@@ -3983,8 +3948,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	*/
 
 	if (is_root_inode(inode)) {
-		rc = __ll_inode_revalidate(inode->i_sb->s_root,
-					   MDS_INODELOCK_LOOKUP);
+		rc = __ll_inode_revalidate(inode->i_sb->s_root, IT_LOOKUP);
 		if (rc)
 			return rc;
 	}
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 078ad6c..15b0710 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -810,6 +810,7 @@ struct ptlrpc_body_v2 {
 
 /* Features required for this version of the client to work with server */
 #define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_FID |	\
+				 OBD_CONNECT_ATTRFID |	\
 				 OBD_CONNECT_FULL20)
 
 /* This structure is used for both request and reply.
-- 
1.8.3.1
