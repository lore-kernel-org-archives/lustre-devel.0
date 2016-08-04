From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:48 -0400
Subject: [lustre-devel] [PATCH 12/32] staging: lustre: llite: use the
	correct mode for striped directory
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Create striped directory with correct mode, which should be
handling same as mkdir.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4929
Reviewed-on: http://review.whamcloud.com/10028
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |   40 +++++++++++++++++++---------
 1 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 3fed80d..a1b5143 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -694,28 +694,40 @@ static int ll_send_mgc_param(struct obd_export *mgc, char *string)
 	return rc;
 }
 
-static int ll_dir_setdirstripe(struct inode *dir, struct lmv_user_md *lump,
-			       const char *filename)
+/**
+ * Create striped directory with specified stripe(@lump)
+ *
+ * param[in] parent	the parent of the directory.
+ * param[in] lump	the specified stripes.
+ * param[in] dirname	the name of the directory.
+ * param[in] mode	the specified mode of the directory.
+ *
+ * retval		=0 if striped directory is being created successfully.
+ *			<0 if the creation is failed.
+ */
+static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
+			       const char *dirname, umode_t mode)
 {
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
-	struct ll_sb_info *sbi = ll_i2sbi(dir);
-	int mode;
+	struct ll_sb_info *sbi = ll_i2sbi(parent);
 	int err;
 
 	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
 		return -EINVAL;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) name %s stripe_offset %d, stripe_count: %u\n",
-	       PFID(ll_inode2fid(dir)), dir, filename,
+	       PFID(ll_inode2fid(parent)), parent, dirname,
 	       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
 
 	if (lump->lum_magic != cpu_to_le32(LMV_USER_MAGIC))
 		lustre_swab_lmv_user_md(lump);
 
-	mode = (~current_umask() & 0755) | S_IFDIR;
-	op_data = ll_prep_md_op_data(NULL, dir, NULL, filename,
-				     strlen(filename), mode, LUSTRE_OPC_MKDIR,
+	if (!IS_POSIXACL(parent) || !exp_connect_umask(ll_i2mdexp(parent)))
+		mode &= ~current_umask();
+	mode = (mode & (S_IRWXUGO | S_ISVTX)) | S_IFDIR;
+	op_data = ll_prep_md_op_data(NULL, parent, NULL, dirname,
+				     strlen(dirname), mode, LUSTRE_OPC_MKDIR,
 				     lump);
 	if (IS_ERR(op_data)) {
 		err = PTR_ERR(op_data);
@@ -1379,6 +1391,7 @@ out_free:
 		char		*filename;
 		int		 namelen = 0;
 		int		 lumlen = 0;
+		umode_t mode;
 		int		 len;
 		int		 rc;
 
@@ -1412,11 +1425,12 @@ out_free:
 			goto lmv_out_free;
 		}
 
-		/**
-		 * ll_dir_setdirstripe will be used to set dir stripe
-		 *  mdc_create--->mdt_reint_create (with dirstripe)
-		 */
-		rc = ll_dir_setdirstripe(inode, lum, filename);
+#if OBD_OCD_VERSION(2, 9, 50, 0) > LUSTRE_VERSION_CODE
+		mode = data->ioc_type != 0 ? data->ioc_type : S_IRWXUGO;
+#else
+		mode = data->ioc_type;
+#endif
+		rc = ll_dir_setdirstripe(inode, lum, filename, mode);
 lmv_out_free:
 		obd_ioctl_freedata(buf, len);
 		return rc;
-- 
1.7.1
