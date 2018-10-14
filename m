From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:00 -0400
Subject: [lustre-devel] [PATCH 10/28] lustre: llite: Update i_nlink on unlink
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

Currently, the client inode link count is not updated on
last unlink.  This is fine because the dentries are all
gone and the inode is eligible for reclaim, but it's still
incorrect.  This causes two problems:

1. Inode is not immediately reclaimed
2. i_nlink count is > 0 for a fully unlinked file, which
   confuses wrapfs

On last unlink, the MDT sends back attributes.  Use the
nlink count from these to update the client inode.

Remove null check inherited from ll_get_child_fid, because
the inode should never be null on an unlink.

Signed-off-by: Patrick Farrell <paf@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10131
Reviewed-on: https://review.whamcloud.com/29651
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 09cdf02..f2bd57e 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -1073,6 +1073,7 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 {
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
+	struct mdt_body *body;
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
@@ -1085,8 +1086,7 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	if (dchild->d_inode)
-		op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
+	op_data->op_fid3 = *ll_inode2fid(dchild->d_inode);
 
 	op_data->op_fid2 = op_data->op_fid3;
 	rc = md_unlink(ll_i2sbi(dir)->ll_md_exp, op_data, &request);
@@ -1094,6 +1094,14 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	if (rc)
 		goto out;
 
+	/*
+	 * The server puts attributes in on the last unlink, use them to update
+	 * the link count so the inode can be freed immediately.
+	 */
+	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
+	if (body->mbo_valid & OBD_MD_FLNLINK)
+		set_nlink(dchild->d_inode, body->mbo_nlink);
+
 	ll_update_times(request, dir);
 	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK, 1);
 
-- 
1.8.3.1
