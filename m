From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:33 -0500
Subject: [lustre-devel] [PATCH 225/622] lustre: llite: make sure name pack
 atomic
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-226-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

We are trying to access dentry name directly and pass it
down without holding @d_lock, this is racy and possibly
make us trigger assertions:

(mdc_lib.c:137:mdc_pack_name()) ASSERTION( lu_name_is_valid_2(buf, cpy_len) ) failed:

Fix the problem by allocting memory and copy name with @d_lock
held.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12020
Lustre-Commit: f575b6551b2b ("LU-12020 llite: make sure name pack atomic")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34330
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a73d11f..4560ae0 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -502,7 +502,7 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	struct inode *inode = d_inode(de);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct dentry *parent = de->d_parent;
-	const char *name = NULL;
+	char *name = NULL;
 	struct md_op_data *op_data;
 	struct ptlrpc_request *req = NULL;
 	int len = 0, rc;
@@ -514,21 +514,41 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	 * if server supports open-by-fid, or file name is invalid, don't pack
 	 * name in open request
 	 */
-	if (!(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_OPEN_BY_FID) &&
-	    lu_name_is_valid_2(de->d_name.name, de->d_name.len)) {
-		name = de->d_name.name;
+	if (!(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_OPEN_BY_FID)) {
+retry:
 		len = de->d_name.len;
+		name = kmalloc(len, GFP_NOFS);
+		if (!name)
+			return -ENOMEM;
+		/* race here */
+		spin_lock(&de->d_lock);
+		if (len != de->d_name.len) {
+			spin_unlock(&de->d_lock);
+			kfree(name);
+			goto retry;
+		}
+		memcpy(name, de->d_name.name, len);
+		spin_unlock(&de->d_lock);
+
+		if (!lu_name_is_valid_2(name, len)) {
+			kfree(name);
+			name = NULL;
+			len = 0;
+		}
 	}
 
 	op_data  = ll_prep_md_op_data(NULL, d_inode(parent), inode, name, len,
 				      O_RDWR, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data))
+	if (IS_ERR(op_data)) {
+		kfree(name);
 		return PTR_ERR(op_data);
+	}
 	op_data->op_data = lmm;
 	op_data->op_data_size = lmmsize;
 
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, itp, &req,
 			    &ll_md_blocking_ast, 0);
+	kfree(name);
 	ll_finish_md_op_data(op_data);
 	if (rc == -ESTALE) {
 		/* reason for keep own exit path - don`t flood log
-- 
1.8.3.1
