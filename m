From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:25:40 +0530
Subject: [lustre-devel] [PATCH v2 3/8] Staging: lustre: namei: Replace calls
	with kfree
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <21f6b3b5ee44344e4405c5d3b26d13180e545dd4.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replace the calls of the function ll_finish_md_op_data() with the
standard function kfree().

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
Changes in v2:
        Fix commit message and merge a patch

 drivers/staging/lustre/lustre/llite/namei.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 2ca2200..f058ebe2 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -531,7 +531,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 	rc = md_intent_lock(ll_i2mdexp(parent), op_data, NULL, 0, it,
 			    lookup_flags, &req, ll_md_blocking_ast, 0);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc < 0) {
 		retval = ERR_PTR(rc);
 		goto out;
@@ -786,7 +786,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			cfs_curproc_cap_pack(), rdev, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (err)
 		goto err_exit;
 
@@ -961,7 +961,7 @@ static int ll_unlink(struct inode *dir, struct dentry *dentry)
 	ll_get_child_fid(dentry, &op_data->op_fid3);
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc)
 		goto out;
 
@@ -1011,7 +1011,7 @@ static int ll_rmdir(struct inode *dir, struct dentry *dentry)
 	ll_get_child_fid(dentry, &op_data->op_fid3);
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc == 0) {
 		ll_update_times(request, dir);
 		ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_RMDIR, 1);
@@ -1060,7 +1060,7 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 		return PTR_ERR(op_data);
 
 	err = md_link(sbi->ll_md_exp, op_data, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (err)
 		goto out;
 
@@ -1096,7 +1096,7 @@ static int ll_rename(struct inode *old_dir, struct dentry *old_dentry,
 			old_dentry->d_name.len,
 			new_dentry->d_name.name,
 			new_dentry->d_name.len, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (!err) {
 		ll_update_times(request, old_dir);
 		ll_update_times(request, new_dir);
-- 
2.1.0
