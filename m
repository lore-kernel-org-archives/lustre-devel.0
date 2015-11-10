From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Tue, 10 Nov 2015 10:22:19 +0530
Subject: [lustre-devel] [PATCH v2 2/8] Staging: lustre: file: Replace
	function calls with standard function
In-Reply-To: <cover.1447129813.git.shivanib134@gmail.com>
References: <cover.1447129813.git.shivanib134@gmail.com>
Message-ID: <ae41e6d049a9e5af7aafad3a3ac275064858f965.1447129813.git.shivanib134@gmail.com>
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

 drivers/staging/lustre/lustre/llite/file.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 02f2759..186b5af 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -202,7 +202,7 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 			rc = -EBUSY;
 	}
 
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 out:
 	if (exp_connect_som(exp) && !epoch_close &&
@@ -420,7 +420,7 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 	itp->it_flags |= MDS_OPEN_BY_FID;
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, lmm, lmmsize, itp,
 			    0 /*unused */, &req, ll_md_blocking_ast, 0);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc == -ESTALE) {
 		/* reason for keep own exit path - don`t flood log
 		* with messages with -ESTALE errors.
@@ -819,7 +819,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	 * open in ll_md_blocking_ast(). Otherwise as ll_md_blocking_lease_ast
 	 * doesn't deal with openhandle, so normal openhandle will be leaked. */
 				LDLM_FL_NO_LRU | LDLM_FL_EXCL);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	ptlrpc_req_finished(req);
 	if (rc < 0)
 		goto out_release_it;
@@ -1393,7 +1393,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 
 	op_data->op_valid = OBD_MD_FLEASIZE | OBD_MD_FLDIREA;
 	rc = md_getattr_name(sbi->ll_md_exp, op_data, &req);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 	if (rc < 0) {
 		CDEBUG(D_INFO, "md_getattr_name failed on %s: rc %d\n",
 		       filename, rc);
@@ -2056,7 +2056,7 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 
 	rc = obd_iocontrol(LL_IOC_LOV_SWAP_LAYOUTS, ll_i2mdexp(llss->inode1),
 			   sizeof(*op_data), op_data, NULL);
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 putgl:
 	if (gid != 0) {
@@ -2131,7 +2131,7 @@ static int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 	rc = obd_iocontrol(LL_IOC_HSM_STATE_SET, ll_i2mdexp(inode),
 			   sizeof(*op_data), op_data, NULL);
 
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 	return rc;
 }
@@ -2350,7 +2350,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (copy_to_user((void *)arg, hus, sizeof(*hus)))
 			rc = -EFAULT;
 
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		kfree(hus);
 		return rc;
 	}
@@ -2389,7 +2389,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (copy_to_user((char *)arg, hca, sizeof(*hca)))
 			rc = -EFAULT;
 
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		kfree(hca);
 		return rc;
 	}
@@ -2761,7 +2761,7 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 		rc = rc2;
 	}
 
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 	return rc;
 }
@@ -2896,7 +2896,7 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 				       based lookup */
 				    &oit, 0, &req,
 				    ll_md_blocking_ast, 0);
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		oit.it_create_mode &= ~M_CHECK_STALE;
 		if (rc < 0) {
 			rc = ll_inode_revalidate_fini(inode, rc);
@@ -2938,7 +2938,7 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 
 		op_data->op_valid = valid;
 		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
-		ll_finish_md_op_data(op_data);
+		kfree(op_data);
 		if (rc) {
 			rc = ll_inode_revalidate_fini(inode, rc);
 			return rc;
@@ -3533,7 +3533,7 @@ again:
 		ptlrpc_req_finished(it.d.lustre.it_data);
 	it.d.lustre.it_data = NULL;
 
-	ll_finish_md_op_data(op_data);
+	kfree(op_data);
 
 	mode = it.d.lustre.it_lock_mode;
 	it.d.lustre.it_lock_mode = 0;
-- 
2.1.0
