From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:45 -0400
Subject: [lustre-devel] [PATCH 6/7] lustre: llite: extend inode flags into
 GET/SETXATTR ioctl
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

This is very useful for projet quota tools to save RPC call
to change project inherit attribute together with project ID.

Signed-off-by: Wang Shilong <wshilong@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10030
Reviewed-on: https://review.whamcloud.com/30072
WC-bug-id: https://jira.whamcloud.com/browse/LU-11165
Reviewed-on: https://review.whamcloud.com/32860
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 72101bd..f69eefc 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2178,6 +2178,8 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	struct ptlrpc_request *req = NULL;
 	struct md_op_data *op_data;
 	struct fsxattr fsxattr;
+	struct cl_object *obj;
+	struct iattr *attr;
 	int rc = 0;
 	int flags;
 
@@ -2206,8 +2208,23 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data, NULL,
 			0, &req);
 	ptlrpc_req_finished(req);
+	if (rc)
+		goto out_fsxattr;
+
 	ll_update_inode_flags(inode, op_data->op_attr_flags);
+	obj = ll_i2info(inode)->lli_clob;
+	if (!obj)
+		goto out_fsxattr;
+
+	attr = kzalloc(sizeof(*attr), GFP_KERNEL);
+	if (!attr) {
+		rc = -ENOMEM;
+		goto out_fsxattr;
+	}
 
+	rc = cl_setattr_ost(obj, attr, OP_XVALID_FLAGS,
+			    fsxattr.fsx_xflags);
+	kfree(attr);
 out_fsxattr:
 	ll_finish_md_op_data(op_data);
 	return rc;
-- 
1.8.3.1
