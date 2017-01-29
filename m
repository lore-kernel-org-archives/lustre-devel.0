From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:29 -0500
Subject: [lustre-devel] [PATCH 01/60] staging: lustre: llite: Remove access
	of stripe in ll_setattr_raw
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In ll_setattr_raw(), it needs to know if a file is released
when the file is being truncated. It used to get this information
by accessing lov_stripe_md. This turns out not necessary. This
patch removes the access of lov_stripe_md and solves the problem
in lov_io_init_released().

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
Reviewed-on: http://review.whamcloud.com/13514
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   6 --
 drivers/staging/lustre/lustre/llite/file.c         |   2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   9 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 109 ++++++++++-----------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  10 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |   7 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |   3 -
 8 files changed, 68 insertions(+), 79 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index dc68561..a1b8301 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -284,12 +284,6 @@ struct cl_layout {
 	size_t		cl_size;
 	/** Layout generation. */
 	u32		cl_layout_gen;
-	/**
-	 * True if this is a released file.
-	 * Temporarily added for released file truncate in ll_setattr_raw().
-	 * It will be removed later. -Jinshan
-	 */
-	bool		cl_is_released;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index a171188..0ee02f1 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1821,7 +1821,7 @@ static int ll_swap_layouts(struct file *file1, struct file *file2,
 	return rc;
 }
 
-static int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
+int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss)
 {
 	struct md_op_data	*op_data;
 	int			 rc;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index dd1cfd8..f1036f4 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -94,6 +94,7 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 
 	io = vvp_env_thread_io(env);
 	io->ci_obj = obj;
+	io->ci_verify_layout = 1;
 
 	io->u.ci_setattr.sa_attr.lvb_atime = LTIME_S(attr->ia_atime);
 	io->u.ci_setattr.sa_attr.lvb_mtime = LTIME_S(attr->ia_mtime);
@@ -120,13 +121,7 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 	cl_io_fini(env, io);
 	if (unlikely(io->ci_need_restart))
 		goto again;
-	/* HSM import case: file is released, cannot be restored
-	 * no need to fail except if restore registration failed
-	 * with -ENODATA
-	 */
-	if (result == -ENODATA && io->ci_restore_needed &&
-	    io->ci_result != -ENODATA)
-		result = 0;
+
 	cl_env_put(env, &refcheck);
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 065a9a7..2c72177 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -766,6 +766,7 @@ int ll_dir_getstripe(struct inode *inode, void **lmmp, int *lmm_size,
 int ll_fid2path(struct inode *inode, void __user *arg);
 int ll_data_version(struct inode *inode, __u64 *data_version, int flags);
 int ll_hsm_release(struct inode *inode);
+int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss);
 
 /* llite/dcache.c */
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9cb4909..769b307 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1402,7 +1402,11 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 	 * cache is not cleared yet.
 	 */
 	op_data->op_attr.ia_valid &= ~(TIMES_SET_FLAGS | ATTR_SIZE);
+	if (S_ISREG(inode->i_mode))
+		inode_lock(inode);
 	rc = simple_setattr(dentry, &op_data->op_attr);
+	if (S_ISREG(inode->i_mode))
+		inode_unlock(inode);
 	op_data->op_attr.ia_valid = ia_valid;
 
 	rc = ll_update_inode(inode, &md);
@@ -1431,7 +1435,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	struct inode *inode = d_inode(dentry);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct md_op_data *op_data = NULL;
-	bool file_is_released = false;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "%s: setattr inode "DFID"(%p) from %llu to %llu, valid %x, hsm_import %d\n",
@@ -1486,76 +1489,35 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		       LTIME_S(attr->ia_mtime), LTIME_S(attr->ia_ctime),
 		       (s64)ktime_get_real_seconds());
 
-	/* We always do an MDS RPC, even if we're only changing the size;
-	 * only the MDS knows whether truncate() should fail with -ETXTBUSY
-	 */
-
-	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
-	if (!op_data)
-		return -ENOMEM;
-
-	if (!S_ISDIR(inode->i_mode))
+	if (S_ISREG(inode->i_mode))
 		inode_unlock(inode);
 
-	/* truncate on a released file must failed with -ENODATA,
-	 * so size must not be set on MDS for released file
-	 * but other attributes must be set
+	/*
+	 * We always do an MDS RPC, even if we're only changing the size;
+	 * only the MDS knows whether truncate() should fail with -ETXTBUSY
 	 */
-	if (S_ISREG(inode->i_mode)) {
-		struct cl_layout cl = {
-			.cl_is_released = false,
-		};
-		struct lu_env *env;
-		int refcheck;
-		__u32 gen;
+	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
+	if (!op_data) {
+		rc = -ENOMEM;
+		goto out;
+	}
 
-		rc = ll_layout_refresh(inode, &gen);
-		if (rc < 0)
-			goto out;
+	op_data->op_attr = *attr;
 
+	if (!hsm_import && attr->ia_valid & ATTR_SIZE) {
 		/*
-		 * XXX: the only place we need to know the layout type,
-		 * this will be removed by a later patch. -Jinshan
+		 * If we are changing file size, file content is
+		 * modified, flag it.
 		 */
-		env = cl_env_get(&refcheck);
-		if (IS_ERR(env)) {
-			rc = PTR_ERR(env);
-			goto out;
-		}
-
-		rc = cl_object_layout_get(env, lli->lli_clob, &cl);
-		cl_env_put(env, &refcheck);
-		if (rc < 0)
-			goto out;
-
-		file_is_released = cl.cl_is_released;
-
-		if (!hsm_import && attr->ia_valid & ATTR_SIZE) {
-			if (file_is_released) {
-				rc = ll_layout_restore(inode, 0, attr->ia_size);
-				if (rc < 0)
-					goto out;
-
-				file_is_released = false;
-				ll_layout_refresh(inode, &gen);
-			}
-
-			/*
-			 * If we are changing file size, file content is
-			 * modified, flag it.
-			 */
-			attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
-			op_data->op_bias |= MDS_DATA_MODIFIED;
-		}
+		attr->ia_valid |= MDS_OPEN_OWNEROVERRIDE;
+		op_data->op_bias |= MDS_DATA_MODIFIED;
 	}
 
-	memcpy(&op_data->op_attr, attr, sizeof(*attr));
-
 	rc = ll_md_setattr(dentry, op_data);
 	if (rc)
 		goto out;
 
-	if (!S_ISREG(inode->i_mode) || file_is_released) {
+	if (!S_ISREG(inode->i_mode) || hsm_import) {
 		rc = 0;
 		goto out;
 	}
@@ -1572,11 +1534,40 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		 */
 		rc = cl_setattr_ost(ll_i2info(inode)->lli_clob, attr, 0);
 	}
+
+	/*
+	 * If the file was restored, it needs to set dirty flag.
+	 *
+	 * We've already sent MDS_DATA_MODIFIED flag in
+	 * ll_md_setattr() for truncate. However, the MDT refuses to
+	 * set the HS_DIRTY flag on released files, so we have to set
+	 * it again if the file has been restored. Please check how
+	 * LLIF_DATA_MODIFIED is set in vvp_io_setattr_fini().
+	 *
+	 * Please notice that if the file is not released, the previous
+	 * MDS_DATA_MODIFIED has taken effect and usually
+	 * LLIF_DATA_MODIFIED is not set(see vvp_io_setattr_fini()).
+	 * This way we can save an RPC for common open + trunc
+	 * operation.
+	 */
+	if (test_and_clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags)) {
+		struct hsm_state_set hss = {
+			.hss_valid = HSS_SETMASK,
+			.hss_setmask = HS_DIRTY,
+		};
+		int rc2;
+
+		rc2 = ll_hsm_state_set(inode, &hss);
+		if (rc2 < 0)
+			CERROR(DFID "HSM set dirty failed: rc2 = %d\n",
+			       PFID(ll_inode2fid(inode)), rc2);
+	}
+
 out:
 	if (op_data)
 		ll_finish_md_op_data(op_data);
 
-	if (!S_ISDIR(inode->i_mode)) {
+	if (S_ISREG(inode->i_mode)) {
 		inode_lock(inode);
 		if ((attr->ia_valid & ATTR_SIZE) && !hsm_import)
 			inode_dio_wait(inode);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 697cbfb..19f85fc 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -288,7 +288,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	       io->ci_ignore_layout, io->ci_verify_layout,
 	       vio->vui_layout_gen, io->ci_restore_needed);
 
-	if (io->ci_restore_needed == 1) {
+	if (io->ci_restore_needed) {
 		int	rc;
 
 		/* file was detected release, we need to restore it
@@ -657,7 +657,15 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 static void vvp_io_setattr_fini(const struct lu_env *env,
 				const struct cl_io_slice *ios)
 {
+	bool restore_needed = ios->cis_io->ci_restore_needed;
+	struct inode *inode = vvp_object_inode(ios->cis_obj);
+
 	vvp_io_fini(env, ios);
+
+	if (restore_needed && !ios->cis_io->ci_restore_needed) {
+		/* restore finished, set data modified flag for HSM */
+		set_bit(LLIF_DATA_MODIFIED, &(ll_i2info(inode))->lli_flags);
+	}
 }
 
 static int vvp_io_read_start(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 002326c..e0f0756 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -1056,9 +1056,12 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 		 * - in setattr, for truncate
 		 */
 		/* the truncate is for size > 0 so triggers a restore */
-		if (cl_io_is_trunc(io))
+		if (cl_io_is_trunc(io)) {
 			io->ci_restore_needed = 1;
-		result = -ENODATA;
+			result = -ENODATA;
+		} else {
+			result = 1;
+		}
 		break;
 	case CIT_READ:
 	case CIT_WRITE:
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 76d4256..46ec46e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1453,14 +1453,11 @@ static int lov_object_layout_get(const struct lu_env *env,
 	if (!lsm) {
 		cl->cl_size = 0;
 		cl->cl_layout_gen = CL_LAYOUT_GEN_EMPTY;
-		cl->cl_is_released = false;
-
 		return 0;
 	}
 
 	cl->cl_size = lov_mds_md_size(lsm->lsm_stripe_count, lsm->lsm_magic);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
-	cl->cl_is_released = lsm_is_released(lsm);
 
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
 	lov_lsm_put(lsm);
-- 
1.8.3.1
