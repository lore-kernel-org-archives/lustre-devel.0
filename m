From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:29:51 +0530
Subject: [lustre-devel] [PATCH v2 8/8] Staging: lustre: llite: Remove
	ll_finish_md_op_data wrapper
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <6b7b11c3a0fec2e7c24d4dac18b351b9c4a7a069.1447129813.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function ll_finish_md_op_data() and replace all
its calls with the standard function kfree() that it wraps. Also,
prototype of the function is removed as it is no longer of any use.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
Changes in v2:
        Fix commit message and merge a patch

 drivers/staging/lustre/lustre/llite/llite_internal.h |  1 -
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 13 ++++---------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 157c3284..d12d483 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -792,7 +792,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
 				      const char *name, int namelen,
 				      int mode, __u32 opc, void *data);
-void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 char *ll_get_fsname(struct super_block *sb, char *buf, int buflen);
 void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 4a8c759..143be87 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1355,7 +1355,7 @@ out:
 		if (!rc)
 			rc = rc1;
 	}
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 	if (!S_ISDIR(inode->i_mode)) {
 		mutex_lock(&inode->i_mutex);
@@ -1732,7 +1732,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		op_data->op_valid = OBD_MD_FLFLAGS;
 		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		if (rc) {
 			CERROR("failure %d inode %lu\n", rc, inode->i_ino);
 			return -abs(rc);
@@ -1763,7 +1763,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		op_data->op_attr.ia_valid |= ATTR_ATTR_FLAG;
 		rc = md_setattr(sbi->ll_md_exp, op_data,
 				NULL, 0, NULL, 0, &req, NULL);
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		ptlrpc_req_finished(req);
 		if (rc)
 			return rc;
@@ -1934,7 +1934,7 @@ void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 	op_data->op_mod_time = get_seconds();
 	md_close(exp, op_data, NULL, &close_req);
 	ptlrpc_req_finished(close_req);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 }
 
 int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
@@ -2170,11 +2170,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	return op_data;
 }
 
-void ll_finish_md_op_data(struct md_op_data *op_data)
-{
-	kfree(op_data);
-}
-
 int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 {
 	struct ll_sb_info *sbi;
-- 
2.1.0
