From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:21:41 +0530
Subject: [lustre-devel] [PATCH v2 1/8] Staging: lustre: dir: Replace
	function calls
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <11b41372e68c9a5edc4043b3bb7c408aabfb760a.1447129813.git.shivanib134@gmail.com>
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

 drivers/staging/lustre/lustre/llite/dir.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5c2ef92..ba3f469 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -182,7 +182,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	op_data->op_npages = npages;
 	op_data->op_offset = hash;
 	rc = md_readpage(exp, op_data, page_pool, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc < 0) {
 		/* page0 is special, which was added into page cache early */
 		delete_from_page_cache(page0);
@@ -363,7 +363,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 		rc = md_enqueue(ll_i2sbi(dir)->ll_md_exp, &einfo, &it,
 				op_data, &lockh, NULL, 0, NULL, 0);
 
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 
 		request = (struct ptlrpc_request *)it.d.lustre.it_data;
 		if (request)
@@ -669,7 +669,7 @@ static int ll_dir_setdirstripe(struct inode *dir, struct lmv_user_md *lump,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			cfs_curproc_cap_pack(), 0, &request);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (err)
 		goto err_exit;
 err_exit:
@@ -730,7 +730,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	/* swabbing is done in lov_setstripe() on server side */
 	rc = md_setattr(sbi->ll_md_exp, op_data, lump, lum_size,
 			NULL, 0, &req, NULL);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	ptlrpc_req_finished(req);
 	if (rc) {
 		if (rc != -EPERM && rc != -EACCES)
@@ -802,7 +802,7 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 
 	op_data->op_valid = OBD_MD_FLEASIZE | OBD_MD_FLDIREA;
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc < 0) {
 		CDEBUG(D_INFO, "md_getattr failed on inode %lu/%u: rc %d\n",
 		       inode->i_ino,
@@ -868,7 +868,7 @@ int ll_get_mdt_idx(struct inode *inode)
 	op_data->op_flags |= MF_GET_MDT_IDX;
 	rc = md_getattr(sbi->ll_md_exp, op_data, NULL);
 	mdtidx = op_data->op_mds;
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc < 0) {
 		CDEBUG(D_INFO, "md_getattr_name: %d\n", rc);
 		return rc;
@@ -1301,7 +1301,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		op_data->op_valid = OBD_MD_FLID;
 		rc = md_getattr_name(sbi->ll_md_exp, op_data, &request);
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		if (rc < 0) {
 			CDEBUG(D_INFO, "md_getattr_name: %d\n", rc);
 			goto out_free;
-- 
2.1.0
