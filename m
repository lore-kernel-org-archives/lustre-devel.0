From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:33 -0400
Subject: [lustre-devel] [PATCH 10/17] staging: lustre: llite: Truncate to
	restore file
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Truncate up is safe so it won't trigger restore.

Copy optimization for truncate down - only copy the part under
truncate length. If a file is truncated to zero usually it'll be
followed by write so I choose to restore the file and set correct
stripe information.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3817
Reviewed-on: http://review.whamcloud.com/7505
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         |    5 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   60 +++++++++----------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    5 +-
 4 files changed, 35 insertions(+), 37 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 9b553d2..24fa24b 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3621,7 +3621,7 @@ again:
 /**
  *  This function send a restore request to the MDT
  */
-int ll_layout_restore(struct inode *inode)
+int ll_layout_restore(struct inode *inode, loff_t offset, __u64 length)
 {
 	struct hsm_user_request	*hur;
 	int			 len, rc;
@@ -3637,7 +3637,8 @@ int ll_layout_restore(struct inode *inode)
 	hur->hur_request.hr_flags = 0;
 	memcpy(&hur->hur_user_item[0].hui_fid, &ll_i2info(inode)->lli_fid,
 	       sizeof(hur->hur_user_item[0].hui_fid));
-	hur->hur_user_item[0].hui_extent.length = -1;
+	hur->hur_user_item[0].hui_extent.offset = offset;
+	hur->hur_user_item[0].hui_extent.length = length;
 	hur->hur_request.hr_itemcount = 1;
 	rc = obd_iocontrol(LL_IOC_HSM_REQUEST, ll_i2sbi(inode)->ll_md_exp,
 			   len, hur, NULL);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index d67c8c0..bb582f1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1377,7 +1377,7 @@ enum {
 
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf);
 int ll_layout_refresh(struct inode *inode, __u32 *gen);
-int ll_layout_restore(struct inode *inode);
+int ll_layout_restore(struct inode *inode, loff_t start, __u64 length);
 
 int ll_xattr_init(void);
 void ll_xattr_fini(void);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9571742..49bfbbd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1266,14 +1266,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		       LTIME_S(attr->ia_mtime), LTIME_S(attr->ia_ctime),
 		       (s64)ktime_get_real_seconds());
 
-	/* If we are changing file size, file content is modified, flag it. */
-	if (attr->ia_valid & ATTR_SIZE) {
-		attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
-		spin_lock(&lli->lli_lock);
-		lli->lli_flags |= LLIF_DATA_MODIFIED;
-		spin_unlock(&lli->lli_lock);
-	}
-
 	/* We always do an MDS RPC, even if we're only changing the size;
 	 * only the MDS knows whether truncate() should fail with -ETXTBUSY
 	 */
@@ -1285,13 +1277,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	if (!S_ISDIR(inode->i_mode))
 		inode_unlock(inode);
 
-	memcpy(&op_data->op_attr, attr, sizeof(*attr));
-
-	/* Open epoch for truncate. */
-	if (exp_connect_som(ll_i2mdexp(inode)) &&
-	    (attr->ia_valid & (ATTR_SIZE | ATTR_MTIME | ATTR_MTIME_SET)))
-		op_data->op_flags = MF_EPOCH_OPEN;
-
 	/* truncate on a released file must failed with -ENODATA,
 	 * so size must not be set on MDS for released file
 	 * but other attributes must be set
@@ -1305,29 +1290,40 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		if (lsm && lsm->lsm_pattern & LOV_PATTERN_F_RELEASED)
 			file_is_released = true;
 		ccc_inode_lsm_put(inode, lsm);
+
+		if (!hsm_import && attr->ia_valid & ATTR_SIZE) {
+			if (file_is_released) {
+				rc = ll_layout_restore(inode, 0, attr->ia_size);
+				if (rc < 0)
+					goto out;
+
+				file_is_released = false;
+				ll_layout_refresh(inode, &gen);
+			}
+
+			/*
+			 * If we are changing file size, file content is
+			 * modified, flag it.
+			 */
+			attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
+			spin_lock(&lli->lli_lock);
+			lli->lli_flags |= LLIF_DATA_MODIFIED;
+			spin_unlock(&lli->lli_lock);
+			op_data->op_bias |= MDS_DATA_MODIFIED;
+		}
 	}
 
-	/* if not in HSM import mode, clear size attr for released file
-	 * we clear the attribute send to MDT in op_data, not the original
-	 * received from caller in attr which is used later to
-	 * decide return code
-	 */
-	if (file_is_released && (attr->ia_valid & ATTR_SIZE) && !hsm_import)
-		op_data->op_attr.ia_valid &= ~ATTR_SIZE;
+	memcpy(&op_data->op_attr, attr, sizeof(*attr));
+
+	/* Open epoch for truncate. */
+	if (exp_connect_som(ll_i2mdexp(inode)) && !hsm_import &&
+	    (attr->ia_valid & (ATTR_SIZE | ATTR_MTIME | ATTR_MTIME_SET)))
+		op_data->op_flags = MF_EPOCH_OPEN;
 
 	rc = ll_md_setattr(dentry, op_data, &mod);
 	if (rc)
 		goto out;
 
-	/* truncate failed (only when non HSM import), others succeed */
-	if (file_is_released) {
-		if ((attr->ia_valid & ATTR_SIZE) && !hsm_import)
-			rc = -ENODATA;
-		else
-			rc = 0;
-		goto out;
-	}
-
 	/* RPC to MDT is sent, cancel data modification flag */
 	if (op_data->op_bias & MDS_DATA_MODIFIED) {
 		spin_lock(&lli->lli_lock);
@@ -1336,7 +1332,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	}
 
 	ll_ioepoch_open(lli, op_data->op_ioepoch);
-	if (!S_ISREG(inode->i_mode)) {
+	if (!S_ISREG(inode->i_mode) || file_is_released) {
 		rc = 0;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index aed7b8e..65d4637 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -295,6 +295,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	struct cl_io     *io  = ios->cis_io;
 	struct cl_object *obj = io->ci_obj;
 	struct vvp_io    *vio = cl2vvp_io(env, ios);
+	struct inode *inode = vvp_object_inode(obj);
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -310,7 +311,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		/* file was detected release, we need to restore it
 		 * before finishing the io
 		 */
-		rc = ll_layout_restore(vvp_object_inode(obj));
+		rc = ll_layout_restore(inode, 0, OBD_OBJECT_EOF);
 		/* if restore registration failed, no restart,
 		 * we will return -ENODATA
 		 */
@@ -336,7 +337,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		__u32 gen = 0;
 
 		/* check layout version */
-		ll_layout_refresh(vvp_object_inode(obj), &gen);
+		ll_layout_refresh(inode, &gen);
 		io->ci_need_restart = vio->vui_layout_gen != gen;
 		if (io->ci_need_restart) {
 			CDEBUG(D_VFSTRACE,
-- 
1.7.1
