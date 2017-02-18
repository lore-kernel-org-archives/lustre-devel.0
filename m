From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:09 -0500
Subject: [lustre-devel] [PATCH 08/14] staging: lustre: llite: remove
	extraneous export parameter
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

The ll_close_inode_openhandle() and ll_md_close() functions passed an
extra "obd_export *md_exp" parameter, but it turns out that all of the
callers already pass inode->i_sb->s_fs_info->lsi_llsbi->ll_md_exp in
one form or another, so it can just be extracted from "inode" directly
as needed.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6627
Reviewed-on: http://review.whamcloud.com/14953
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c | 33 +++++++++++++-----------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index b1c9573..d8a5e70 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -116,13 +116,13 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
  * If \a bias is MDS_CLOSE_LAYOUT_SWAP then \a data is a pointer to the inode to
  * swap layouts with.
  */
-static int ll_close_inode_openhandle(struct obd_export *md_exp,
+static int ll_close_inode_openhandle(struct inode *inode,
 				     struct obd_client_handle *och,
-				     struct inode *inode,
 				     enum mds_op_bias bias,
 				     void *data)
 {
 	const struct ll_inode_info *lli = ll_i2info(inode);
+	struct obd_export *md_exp = ll_i2mdexp(inode);
 	struct md_op_data *op_data;
 	struct ptlrpc_request *req = NULL;
 	int rc;
@@ -231,15 +231,13 @@ int ll_md_real_close(struct inode *inode, fmode_t fmode)
 		/* There might be a race and this handle may already
 		 * be closed.
 		 */
-		rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp,
-					       och, inode, 0, NULL);
+		rc = ll_close_inode_openhandle(inode, och, 0, NULL);
 	}
 
 	return rc;
 }
 
-static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
-		       struct file *file)
+static int ll_md_close(struct inode *inode, struct file *file)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -270,8 +268,7 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 	}
 
 	if (fd->fd_och) {
-		rc = ll_close_inode_openhandle(md_exp, fd->fd_och, inode, 0,
-					       NULL);
+		rc = ll_close_inode_openhandle(inode, fd->fd_och, 0, NULL);
 		fd->fd_och = NULL;
 		goto out;
 	}
@@ -296,7 +293,7 @@ static int ll_md_close(struct obd_export *md_exp, struct inode *inode,
 	}
 	mutex_unlock(&lli->lli_och_mutex);
 
-	if (!md_lock_match(md_exp, flags, ll_inode2fid(inode),
+	if (!md_lock_match(ll_i2mdexp(inode), flags, ll_inode2fid(inode),
 			   LDLM_IBITS, &policy, lockmode, &lockh))
 		rc = ll_md_real_close(inode, fd->fd_omode);
 
@@ -345,7 +342,7 @@ int ll_file_release(struct inode *inode, struct file *file)
 		lli->lli_async_rc = 0;
 	}
 
-	rc = ll_md_close(sbi->ll_md_exp, inode, file);
+	rc = ll_md_close(inode, file);
 
 	if (CFS_FAIL_TIMEOUT_MS(OBD_FAIL_PTLRPC_DUMP_LOG, cfs_fail_val))
 		libcfs_debug_dumplog();
@@ -835,7 +832,7 @@ static int ll_md_blocking_lease_ast(struct ldlm_lock *lock,
 		it.it_lock_mode = 0;
 		och->och_lease_handle.cookie = 0ULL;
 	}
-	rc2 = ll_close_inode_openhandle(sbi->ll_md_exp, och, inode, 0, NULL);
+	rc2 = ll_close_inode_openhandle(inode, och, 0, NULL);
 	if (rc2 < 0)
 		CERROR("%s: error closing file "DFID": %d\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
@@ -901,8 +898,8 @@ static int ll_swap_layouts_close(struct obd_client_handle *och,
 	 * NB: lease lock handle is released in mdc_close_layout_swap_pack()
 	 * because we still need it to pack l_remote_handle to MDT.
 	 */
-	rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp, och, inode,
-				       MDS_CLOSE_LAYOUT_SWAP, inode2);
+	rc = ll_close_inode_openhandle(inode, och, MDS_CLOSE_LAYOUT_SWAP,
+				       inode2);
 
 	och = NULL; /* freed in ll_close_inode_openhandle() */
 
@@ -937,8 +934,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 	if (lease_broken)
 		*lease_broken = cancelled;
 
-	return ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp,
-					 och, inode, 0, NULL);
+	return ll_close_inode_openhandle(inode, och, 0, NULL);
 }
 
 int ll_merge_attr(const struct lu_env *env, struct inode *inode)
@@ -1494,8 +1490,7 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
 
 	ll_och_fill(ll_i2sbi(inode)->ll_md_exp, it, och);
 
-	rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp,
-				       och, inode, 0, NULL);
+	rc = ll_close_inode_openhandle(inode, och, 0, NULL);
 out:
 	/* this one is in place of ll_file_open */
 	if (it_disposition(it, DISP_ENQ_OPEN_REF)) {
@@ -1698,8 +1693,8 @@ int ll_hsm_release(struct inode *inode)
 	 * NB: lease lock handle is released in mdc_hsm_release_pack() because
 	 * we still need it to pack l_remote_handle to MDT.
 	 */
-	rc = ll_close_inode_openhandle(ll_i2sbi(inode)->ll_md_exp, och, inode,
-				       MDS_HSM_RELEASE, &data_version);
+	rc = ll_close_inode_openhandle(inode, och, MDS_HSM_RELEASE,
+				       &data_version);
 	och = NULL;
 
 out:
-- 
1.8.3.1
