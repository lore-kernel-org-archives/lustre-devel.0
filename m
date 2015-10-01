From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:14 -0400
Subject: [lustre-devel] [PATCH 04/32] staging/lustre/llite: Remove unused
	ll_rmdir_entry()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

The ioctl for this function was removed, but the function was
forgotten, so kill it now.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |  1 -
 drivers/staging/lustre/lustre/llite/namei.c        | 28 ----------------------
 2 files changed, 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index d6bdfed..4c20b1e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -687,7 +687,6 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 int ll_md_blocking_ast(struct ldlm_lock *, struct ldlm_lock_desc *,
 		       void *data, int flag);
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de);
-int ll_rmdir_entry(struct inode *dir, char *name, int namelen);
 
 /* llite/rw.c */
 int ll_prepare_write(struct file *, struct page *, unsigned from, unsigned to);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 2e663ea..a22e252 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -870,34 +870,6 @@ static inline void ll_get_child_fid(struct dentry *child, struct lu_fid *fid)
 		*fid = *ll_inode2fid(d_inode(child));
 }
 
-/**
- * Remove dir entry
- **/
-int ll_rmdir_entry(struct inode *dir, char *name, int namelen)
-{
-	struct ptlrpc_request *request = NULL;
-	struct md_op_data *op_data;
-	int rc;
-
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%.*s,dir=%lu/%u(%p)\n",
-	       namelen, name, dir->i_ino, dir->i_generation, dir);
-
-	op_data = ll_prep_md_op_data(NULL, dir, NULL, name, strlen(name),
-				     S_IFDIR, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
-	op_data->op_cli_flags |= CLI_RM_ENTRY;
-	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
-	ll_finish_md_op_data(op_data);
-	if (rc == 0) {
-		ll_update_times(request, dir);
-		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_RMDIR, 1);
-	}
-
-	ptlrpc_req_finished(request);
-	return rc;
-}
-
 int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 {
 	struct mdt_body *body;
-- 
2.1.0
