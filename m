From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 16:14:06 -0400
Subject: [lustre-devel] [PATCH v2 06/16] staging: lustre: llite: speedup in
	unlink/rmdir
In-Reply-To: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
References: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460492056-31792-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andrew Perepechko <andrew_perepechko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Andrew Perepechko <andrew_perepechko@xyratex.com>

Assume dchild argument is fully initialized in ->unlink and
->rmdir callbacks, so additional lookup for ELC is not needed.

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
 drivers/staging/lustre/lustre/llite/namei.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 73e61cf..9fa862b 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -847,12 +847,6 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 	return rc;
 }
 
-static inline void ll_get_child_fid(struct dentry *child, struct lu_fid *fid)
-{
-	if (d_really_is_positive(child))
-		*fid = *ll_inode2fid(d_inode(child));
-}
-
 int ll_objects_destroy(struct ptlrpc_request *request, struct inode *dir)
 {
 	struct mdt_body *body;
@@ -945,7 +939,9 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	ll_get_child_fid(dchild, &op_data->op_fid3);
+	if (dchild && dchild->d_inode)
+		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
+
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
@@ -995,7 +991,9 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	ll_get_child_fid(dchild, &op_data->op_fid3);
+	if (dchild && dchild->d_inode)
+		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
+
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
 	ll_finish_md_op_data(op_data);
@@ -1076,8 +1074,11 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	ll_get_child_fid(src_dchild, &op_data->op_fid3);
-	ll_get_child_fid(tgt_dchild, &op_data->op_fid4);
+	if (src_dchild && src_dchild->d_inode)
+		op_data->op_fid3 = *ll_inode2fid(src_dchild->d_inode);
+	if (tgt_dchild && tgt_dchild->d_inode)
+		op_data->op_fid4 = *ll_inode2fid(tgt_dchild->d_inode);
+
 	err = md_rename(sbi->ll_md_exp, op_data,
 			src_dchild->d_name.name,
 			src_dchild->d_name.len,
-- 
1.7.1
