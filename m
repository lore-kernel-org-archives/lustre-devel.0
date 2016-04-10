From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:28 -0400
Subject: [lustre-devel] [PATCH 05/17] staging: lustre: llite: variable
	rename in namei.c
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andrew Perepechko <andrew_perepechko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Andrew Perepechko <andrew_perepechko@xyratex.com>

With the patch 6648 a fee variables were renamed. We do these
renames in broken out patch to the fix obvious.

Signed-off-by: Andrew Perepechko <andrew_perepechko@xyratex.com>
Reviewed-by: Alexander Boyko <Alexander_Boyko@xyratex.com>
Reviewed-by: Vitaly Fertman <Vitaly_Fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3473
Xyratex-bug-id: MRP-1027
Reviewed-on: http://review.whamcloud.com/6648
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |   52 +++++++++++++-------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index f8f98e4..6445bc1 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -927,23 +927,23 @@ out:
  * is any lock existing. They will recycle dentries and inodes based upon locks
  * too. b=20433
  */
-static int ll_unlink(struct inode *dir, struct dentry *dentry)
+static int ll_unlink(struct inode *dir, struct dentry *dchild)
 {
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
-	       dentry, dir->i_ino, dir->i_generation, dir);
+	       dchild, dir->i_ino, dir->i_generation, dir);
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
-				     dentry->d_name.name,
-				     dentry->d_name.len,
+				     dchild->d_name.name,
+				     dchild->d_name.len,
 				     0, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	ll_get_child_fid(dentry, &op_data->op_fid3);
+	ll_get_child_fid(dchild, &op_data->op_fid3);
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
@@ -977,23 +977,23 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	return err;
 }
 
-static int ll_rmdir(struct inode *dir, struct dentry *dentry)
+static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 {
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
-	       dentry, dir->i_ino, dir->i_generation, dir);
+	       dchild, dir->i_ino, dir->i_generation, dir);
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
-				     dentry->d_name.name,
-				     dentry->d_name.len,
+				     dchild->d_name.name,
+				     dchild->d_name.len,
 				     S_IFDIR, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	ll_get_child_fid(dentry, &op_data->op_fid3);
+	ll_get_child_fid(dchild, &op_data->op_fid3);
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
@@ -1056,42 +1056,42 @@ out:
 	return err;
 }
 
-static int ll_rename(struct inode *old_dir, struct dentry *old_dentry,
-		     struct inode *new_dir, struct dentry *new_dentry)
+static int ll_rename(struct inode *src, struct dentry *src_dchild,
+		     struct inode *tgt, struct dentry *tgt_dchild)
 {
 	struct ptlrpc_request *request = NULL;
-	struct ll_sb_info *sbi = ll_i2sbi(old_dir);
+	struct ll_sb_info *sbi = ll_i2sbi(src);
 	struct md_op_data *op_data;
 	int err;
 
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:oldname=%pd,src_dir=%lu/%u(%p),newname=%pd,tgt_dir=%lu/%u(%p)\n",
-	       old_dentry, old_dir->i_ino, old_dir->i_generation, old_dir,
-	       new_dentry, new_dir->i_ino, new_dir->i_generation, new_dir);
+	       src_dchild, src->i_ino, src->i_generation, src,
+	       tgt_dchild, tgt->i_ino, tgt->i_generation, tgt);
 
-	op_data = ll_prep_md_op_data(NULL, old_dir, new_dir, NULL, 0, 0,
+	op_data = ll_prep_md_op_data(NULL, src, tgt, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	ll_get_child_fid(old_dentry, &op_data->op_fid3);
-	ll_get_child_fid(new_dentry, &op_data->op_fid4);
+	ll_get_child_fid(src_dchild, &op_data->op_fid3);
+	ll_get_child_fid(tgt_dchild, &op_data->op_fid4);
 	err = md_rename(sbi->ll_md_exp, op_data,
-			old_dentry->d_name.name,
-			old_dentry->d_name.len,
-			new_dentry->d_name.name,
-			new_dentry->d_name.len, &request);
+			src_dchild->d_name.name,
+			src_dchild->d_name.len,
+			tgt_dchild->d_name.name,
+			tgt_dchild->d_name.len, &request);
 	ll_finish_md_op_data(op_data);
 	if (!err) {
-		ll_update_times(request, old_dir);
-		ll_update_times(request, new_dir);
+		ll_update_times(request, src);
+		ll_update_times(request, tgt);
 		ll_stats_ops_tally(sbi, LPROC_LL_RENAME, 1);
-		err = ll_objects_destroy(request, old_dir);
+		err = ll_objects_destroy(request, src);
 	}
 
 	ptlrpc_req_finished(request);
 	if (!err)
-		d_move(old_dentry, new_dentry);
+		d_move(src_dchild, tgt_dchild);
 	return err;
 }
 
-- 
1.7.1
