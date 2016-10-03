From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:20 -0400
Subject: [lustre-devel] [PATCH 24/41] staging: lustre: clio: add
	CIT_DATA_VERSION and remove IOC_LOV_GETINFO
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

During development a new api, cl_object_obd_info_get()
and cl_object_data_version() which then were later
replaced by a better solution CIT_DATA_VERSION. For
the case of the upstream client their is no point in
introducing a API to only have it removed later. Due
to the way the patches landed with their dependencies
it is not possible to separate out two patches. These
two combined patches do the following:

 * Add a new cl_io type CIT_DATA_VERSION to get file
   data version.
 * Remove the unused IOC_LOV_GETINFO ioctl.
 * Remove ll_glimpse_ioctl() and ll_lsm_getattr().
 * Remove the OBD API method obd_getattr_async().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
Reviewed-on: http://review.whamcloud.com/12748
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6356
Reviewed-on: http://review.whamcloud.com/14649
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    6 +
 .../lustre/lustre/include/lustre/lustre_user.h     |    6 +-
 drivers/staging/lustre/lustre/include/obd.h        |    2 -
 drivers/staging/lustre/lustre/include/obd_class.h  |   13 --
 drivers/staging/lustre/lustre/llite/dir.c          |   71 ----------
 drivers/staging/lustre/lustre/llite/file.c         |  125 +++++-------------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    4 -
 drivers/staging/lustre/lustre/lov/lov_io.c         |   40 ++++++
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   50 -------
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   69 ----------
 drivers/staging/lustre/lustre/lov/lov_request.c    |  144 --------------------
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    1 +
 drivers/staging/lustre/lustre/osc/osc_io.c         |  105 ++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_request.c    |   59 --------
 15 files changed, 189 insertions(+), 508 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 0b66d02..e46a510 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1373,6 +1373,8 @@ enum cl_io_type {
 	CIT_WRITE,
 	/** truncate, utime system calls */
 	CIT_SETATTR,
+	/** get data version */
+	CIT_DATA_VERSION,
 	/**
 	 * page fault handling
 	 */
@@ -1777,6 +1779,10 @@ struct cl_io {
 			int		sa_stripe_index;
 			const struct lu_fid	*sa_parent_fid;
 		} ci_setattr;
+		struct cl_data_version_io {
+			u64 dv_data_version;
+			int dv_flags;
+		} ci_data_version;
 		struct cl_fault_io {
 			/** page index within file. */
 			pgoff_t	 ft_index;
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index dced31f..043fc1c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -63,9 +63,13 @@
 #if __BITS_PER_LONG != 64 || defined(__ARCH_WANT_STAT64)
 typedef struct stat64   lstat_t;
 #define lstat_f  lstat64
+#define fstat_f		fstat64
+#define fstatat_f	fstatat64
 #else
 typedef struct stat     lstat_t;
 #define lstat_f  lstat
+#define fstat_f		fstat
+#define fstatat_f	fstatat
 #endif
 
 #define HAVE_LOV_USER_MDS_DATA
@@ -234,7 +238,7 @@ struct ost_id {
 /* #define LL_IOC_POLL_QUOTACHECK	161 OBD_IOC_POLL_QUOTACHECK */
 /* #define LL_IOC_QUOTACTL		162 OBD_IOC_QUOTACTL */
 #define IOC_OBD_STATFS		  _IOWR('f', 164, struct obd_statfs *)
-#define IOC_LOV_GETINFO		 _IOWR('f', 165, struct lov_user_mds_data *)
+/*	IOC_LOV_GETINFO			165 obsolete */
 #define LL_IOC_FLUSHCTX		 _IOW('f', 166, long)
 /* LL_IOC_RMTACL			167 obsolete */
 #define LL_IOC_GETOBDCOUNT	      _IOR('f', 168, long)
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index c72a1e1..f254d88 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -905,8 +905,6 @@ struct obd_ops {
 		       struct obd_info *oinfo, struct obd_trans_info *oti);
 	int (*getattr)(const struct lu_env *env, struct obd_export *exp,
 		       struct obd_info *oinfo);
-	int (*getattr_async)(struct obd_export *exp, struct obd_info *oinfo,
-			     struct ptlrpc_request_set *set);
 	int (*preprw)(const struct lu_env *env, int cmd,
 		      struct obd_export *exp, struct obdo *oa, int objcount,
 		      struct obd_ioobj *obj, struct niobuf_remote *remote,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7a5d75a..cb7160e 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -721,19 +721,6 @@ static inline int obd_getattr(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-static inline int obd_getattr_async(struct obd_export *exp,
-				    struct obd_info *oinfo,
-				    struct ptlrpc_request_set *set)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, getattr_async);
-	EXP_COUNTER_INCREMENT(exp, getattr_async);
-
-	rc = OBP(exp->exp_obd, getattr_async)(exp, oinfo, set);
-	return rc;
-}
-
 static inline int obd_setattr(const struct lu_env *env, struct obd_export *exp,
 			      struct obd_info *oinfo,
 			      struct obd_trans_info *oti)
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 12e9a38..360d97f 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1369,77 +1369,6 @@ out_req:
 			ll_putname(filename);
 		return rc;
 	}
-	case IOC_LOV_GETINFO: {
-		struct lov_user_mds_data __user *lumd;
-		struct lov_stripe_md *lsm;
-		struct lov_user_md __user *lum;
-		struct lov_mds_md *lmm;
-		int lmmsize;
-		lstat_t st;
-
-		lumd = (struct lov_user_mds_data __user *)arg;
-		lum = &lumd->lmd_lmm;
-
-		rc = ll_get_max_mdsize(sbi, &lmmsize);
-		if (rc)
-			return rc;
-
-		lmm = libcfs_kvzalloc(lmmsize, GFP_NOFS);
-		if (!lmm)
-			return -ENOMEM;
-		if (copy_from_user(lmm, lum, lmmsize)) {
-			rc = -EFAULT;
-			goto free_lmm;
-		}
-
-		switch (lmm->lmm_magic) {
-		case LOV_USER_MAGIC_V1:
-			if (cpu_to_le32(LOV_USER_MAGIC_V1) == LOV_USER_MAGIC_V1)
-				break;
-			/* swab objects first so that stripes num will be sane */
-			lustre_swab_lov_user_md_objects(
-				((struct lov_user_md_v1 *)lmm)->lmm_objects,
-				((struct lov_user_md_v1 *)lmm)->lmm_stripe_count);
-			lustre_swab_lov_user_md_v1((struct lov_user_md_v1 *)lmm);
-			break;
-		case LOV_USER_MAGIC_V3:
-			if (cpu_to_le32(LOV_USER_MAGIC_V3) == LOV_USER_MAGIC_V3)
-				break;
-			/* swab objects first so that stripes num will be sane */
-			lustre_swab_lov_user_md_objects(
-				((struct lov_user_md_v3 *)lmm)->lmm_objects,
-				((struct lov_user_md_v3 *)lmm)->lmm_stripe_count);
-			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
-			break;
-		default:
-			rc = -EINVAL;
-			goto free_lmm;
-		}
-
-		rc = obd_unpackmd(sbi->ll_dt_exp, &lsm, lmm, lmmsize);
-		if (rc < 0) {
-			rc = -ENOMEM;
-			goto free_lmm;
-		}
-
-		/* Perform glimpse_size operation. */
-		memset(&st, 0, sizeof(st));
-
-		rc = ll_glimpse_ioctl(sbi, lsm, &st);
-		if (rc)
-			goto free_lsm;
-
-		if (copy_to_user(&lumd->lmd_st, &st, sizeof(st))) {
-			rc = -EFAULT;
-			goto free_lsm;
-		}
-
-free_lsm:
-		obd_free_memmd(sbi->ll_dt_exp, &lsm);
-free_lmm:
-		kvfree(lmm);
-		return rc;
-	}
 	case OBD_IOC_QUOTACHECK: {
 		struct obd_quotactl *oqctl;
 		int error = 0;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 89a2841..8fa65a5 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -865,55 +865,6 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 					 inode, och, NULL);
 }
 
-/* Fills the obdo with the attributes for the lsm */
-static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
-			  struct obdo *obdo, int dv_flags)
-{
-	struct ptlrpc_request_set *set;
-	struct obd_info	    oinfo = { };
-	int			rc;
-
-	LASSERT(lsm);
-
-	oinfo.oi_md = lsm;
-	oinfo.oi_oa = obdo;
-	oinfo.oi_oa->o_oi = lsm->lsm_oi;
-	oinfo.oi_oa->o_mode = S_IFREG;
-	oinfo.oi_oa->o_valid = OBD_MD_FLID | OBD_MD_FLTYPE |
-			       OBD_MD_FLSIZE | OBD_MD_FLBLOCKS |
-			       OBD_MD_FLBLKSZ | OBD_MD_FLATIME |
-			       OBD_MD_FLMTIME | OBD_MD_FLCTIME |
-			       OBD_MD_FLGROUP | OBD_MD_FLDATAVERSION;
-	if (dv_flags & (LL_DV_WR_FLUSH | LL_DV_RD_FLUSH)) {
-		oinfo.oi_oa->o_valid |= OBD_MD_FLFLAGS;
-		oinfo.oi_oa->o_flags |= OBD_FL_SRVLOCK;
-		if (dv_flags & LL_DV_WR_FLUSH)
-			oinfo.oi_oa->o_flags |= OBD_FL_FLUSH;
-	}
-
-	set = ptlrpc_prep_set();
-	if (!set) {
-		CERROR("cannot allocate ptlrpc set: rc = %d\n", -ENOMEM);
-		rc = -ENOMEM;
-	} else {
-		rc = obd_getattr_async(exp, &oinfo, set);
-		if (rc == 0)
-			rc = ptlrpc_set_wait(set);
-		ptlrpc_set_destroy(set);
-	}
-	if (rc == 0) {
-		oinfo.oi_oa->o_valid &= (OBD_MD_FLBLOCKS | OBD_MD_FLBLKSZ |
-					 OBD_MD_FLATIME | OBD_MD_FLMTIME |
-					 OBD_MD_FLCTIME | OBD_MD_FLSIZE |
-					 OBD_MD_FLDATAVERSION | OBD_MD_FLFLAGS);
-		if (dv_flags & LL_DV_WR_FLUSH &&
-		    !(oinfo.oi_oa->o_valid & OBD_MD_FLFLAGS &&
-		      oinfo.oi_oa->o_flags & OBD_FL_FLUSH))
-			return -ENOTSUPP;
-	}
-	return rc;
-}
-
 int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -970,23 +921,6 @@ out_size_unlock:
 	return rc;
 }
 
-int ll_glimpse_ioctl(struct ll_sb_info *sbi, struct lov_stripe_md *lsm,
-		     lstat_t *st)
-{
-	struct obdo obdo = { 0 };
-	int rc;
-
-	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, &obdo, 0);
-	if (rc == 0) {
-		st->st_size   = obdo.o_size;
-		st->st_blocks = obdo.o_blocks;
-		st->st_mtime  = obdo.o_mtime;
-		st->st_atime  = obdo.o_atime;
-		st->st_ctime  = obdo.o_ctime;
-	}
-	return rc;
-}
-
 static bool file_is_noatime(const struct file *file)
 {
 	const struct vfsmount *mnt = file->f_path.mnt;
@@ -1635,45 +1569,50 @@ gf_free:
  * This value is computed using stripe object version on OST.
  * Version is computed using server side locking.
  *
- * @param sync  if do sync on the OST side;
+ * @param flags if do sync on the OST side;
  *		0: no sync
  *		LL_DV_RD_FLUSH: flush dirty pages, LCK_PR on OSTs
  *		LL_DV_WR_FLUSH: drop all caching pages, LCK_PW on OSTs
  */
 int ll_data_version(struct inode *inode, __u64 *data_version, int flags)
 {
-	struct lov_stripe_md	*lsm = NULL;
-	struct ll_sb_info	*sbi = ll_i2sbi(inode);
-	struct obdo		*obdo = NULL;
-	int			 rc;
+	struct cl_object *obj = ll_i2info(inode)->lli_clob;
+	struct lu_env *env;
+	struct cl_io *io;
+	int refcheck;
+	int result;
 
-	/* If no stripe, we consider version is 0. */
-	lsm = ccc_inode_lsm_get(inode);
-	if (!lsm_has_objects(lsm)) {
+	/* If no file object initialized, we consider its version is 0. */
+	if (!obj) {
 		*data_version = 0;
-		CDEBUG(D_INODE, "No object for inode\n");
-		rc = 0;
-		goto out;
+		return 0;
 	}
 
-	obdo = kzalloc(sizeof(*obdo), GFP_NOFS);
-	if (!obdo) {
-		rc = -ENOMEM;
-		goto out;
-	}
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
 
-	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, obdo, flags);
-	if (rc == 0) {
-		if (!(obdo->o_valid & OBD_MD_FLDATAVERSION))
-			rc = -EOPNOTSUPP;
-		else
-			*data_version = obdo->o_data_version;
-	}
+	io = vvp_env_thread_io(env);
+	io->ci_obj = obj;
+	io->u.ci_data_version.dv_data_version = 0;
+	io->u.ci_data_version.dv_flags = flags;
 
-	kfree(obdo);
-out:
-	ccc_inode_lsm_put(inode, lsm);
-	return rc;
+restart:
+	if (!cl_io_init(env, io, CIT_DATA_VERSION, io->ci_obj))
+		result = cl_io_loop(env, io);
+	else
+		result = io->ci_result;
+
+	*data_version = io->u.ci_data_version.dv_data_version;
+
+	cl_io_fini(env, io);
+
+	if (unlikely(io->ci_need_restart))
+		goto restart;
+
+	cl_env_put(env, &refcheck);
+
+	return result;
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 02541b1..e249895 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -741,8 +741,6 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 			       enum ldlm_mode mode);
 int ll_file_open(struct inode *inode, struct file *file);
 int ll_file_release(struct inode *inode, struct file *file);
-int ll_glimpse_ioctl(struct ll_sb_info *sbi,
-		     struct lov_stripe_md *lsm, lstat_t *st);
 int ll_release_openhandle(struct inode *, struct lookup_intent *);
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
 void ll_pack_inode2opdata(struct inode *inode, struct md_op_data *op_data,
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 4743c65..fffc18c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -132,8 +132,6 @@ static inline void lov_put_reqset(struct lov_request_set *set)
 	(char *)((lv)->lov_tgts[index]->ltd_uuid.uuid)
 
 /* lov_merge.c */
-void lov_merge_attrs(struct obdo *tgt, struct obdo *src, u64 valid,
-		     struct lov_stripe_md *lsm, int stripeno, int *set);
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 		      struct ost_lvb *lvb, __u64 *kms_place);
 
@@ -150,8 +148,6 @@ pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
 			 int stripe);
 
 /* lov_request.c */
-int lov_update_common_set(struct lov_request_set *set,
-			  struct lov_request *req, int rc);
 int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
 			 struct lov_request_set **reqset);
 int lov_fini_getattr_set(struct lov_request_set *set);
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 369718e..d6be613 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -100,6 +100,12 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 		}
 		break;
 	}
+	case CIT_DATA_VERSION: {
+		io->u.ci_data_version.dv_data_version = 0;
+		io->u.ci_data_version.dv_flags =
+			parent->u.ci_data_version.dv_flags;
+		break;
+	}
 	case CIT_FAULT: {
 		struct cl_object *obj = parent->ci_obj;
 		loff_t off = cl_offset(obj, parent->u.ci_fault.ft_index);
@@ -339,6 +345,11 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		lio->lis_endpos = OBD_OBJECT_EOF;
 		break;
 
+	case CIT_DATA_VERSION:
+		lio->lis_pos = 0;
+		lio->lis_endpos = OBD_OBJECT_EOF;
+		break;
+
 	case CIT_FAULT: {
 		pgoff_t index = io->u.ci_fault.ft_index;
 
@@ -516,6 +527,24 @@ static int lov_io_end_wrapper(const struct lu_env *env, struct cl_io *io)
 	return 0;
 }
 
+static void
+lov_io_data_version_end(const struct lu_env *env, const struct cl_io_slice *ios)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct cl_io *parent = lio->lis_cl.cis_io;
+	struct lov_io_sub *sub;
+
+	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
+		lov_io_end_wrapper(env, sub->sub_io);
+
+		parent->u.ci_data_version.dv_data_version +=
+			sub->sub_io->u.ci_data_version.dv_data_version;
+
+		if (!parent->ci_result)
+			parent->ci_result = sub->sub_io->ci_result;
+	}
+}
+
 static int lov_io_iter_fini_wrapper(const struct lu_env *env, struct cl_io *io)
 {
 	cl_io_iter_fini(env, io);
@@ -838,6 +867,15 @@ static const struct cl_io_operations lov_io_ops = {
 			.cio_start     = lov_io_start,
 			.cio_end       = lov_io_end
 		},
+		[CIT_DATA_VERSION] = {
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_data_version_end,
+		},
 		[CIT_FAULT] = {
 			.cio_fini      = lov_io_fini,
 			.cio_iter_init = lov_io_iter_init,
@@ -969,6 +1007,7 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 		break;
 	case CIT_FSYNC:
 	case CIT_SETATTR:
+	case CIT_DATA_VERSION:
 		result = 1;
 		break;
 	case CIT_WRITE:
@@ -1004,6 +1043,7 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 		LASSERTF(0, "invalid type %d\n", io->ci_type);
 	case CIT_MISC:
 	case CIT_FSYNC:
+	case CIT_DATA_VERSION:
 		result = 1;
 		break;
 	case CIT_SETATTR:
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 674af10..391dfd2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -104,53 +104,3 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm,
 	lvb->lvb_ctime = current_ctime;
 	return rc;
 }
-
-void lov_merge_attrs(struct obdo *tgt, struct obdo *src, u64 valid,
-		     struct lov_stripe_md *lsm, int stripeno, int *set)
-{
-	valid &= src->o_valid;
-
-	if (*set) {
-		tgt->o_valid &= valid;
-		if (valid & OBD_MD_FLSIZE) {
-			/* this handles sparse files properly */
-			u64 lov_size;
-
-			lov_size = lov_stripe_size(lsm, src->o_size, stripeno);
-			if (lov_size > tgt->o_size)
-				tgt->o_size = lov_size;
-		}
-		if (valid & OBD_MD_FLBLOCKS)
-			tgt->o_blocks += src->o_blocks;
-		if (valid & OBD_MD_FLBLKSZ)
-			tgt->o_blksize += src->o_blksize;
-		if (valid & OBD_MD_FLCTIME && tgt->o_ctime < src->o_ctime)
-			tgt->o_ctime = src->o_ctime;
-		if (valid & OBD_MD_FLMTIME && tgt->o_mtime < src->o_mtime)
-			tgt->o_mtime = src->o_mtime;
-		if (valid & OBD_MD_FLDATAVERSION)
-			tgt->o_data_version += src->o_data_version;
-
-		/* handle flags */
-		if (valid & OBD_MD_FLFLAGS)
-			tgt->o_flags &= src->o_flags;
-		else
-			tgt->o_flags = 0;
-	} else {
-		memcpy(tgt, src, sizeof(*tgt));
-		tgt->o_oi = lsm->lsm_oi;
-		tgt->o_valid = valid;
-		if (valid & OBD_MD_FLSIZE)
-			tgt->o_size = lov_stripe_size(lsm, src->o_size,
-						      stripeno);
-		tgt->o_flags = 0;
-		if (valid & OBD_MD_FLFLAGS)
-			tgt->o_flags = src->o_flags;
-	}
-
-	/* data_version needs to be valid on all stripes to be correct! */
-	if (!(valid & OBD_MD_FLDATAVERSION))
-		tgt->o_valid &= ~OBD_MD_FLDATAVERSION;
-
-	*set += 1;
-}
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 44f53c7..019fe95 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -979,74 +979,6 @@ do {									    \
 		 "%p->lsm_magic=%x\n", (lsmp), (lsmp)->lsm_magic);	      \
 } while (0)
 
-static int lov_getattr_interpret(struct ptlrpc_request_set *rqset,
-				 void *data, int rc)
-{
-	struct lov_request_set *lovset = (struct lov_request_set *)data;
-	int err;
-
-	/* don't do attribute merge if this async op failed */
-	if (rc)
-		atomic_set(&lovset->set_completes, 0);
-	err = lov_fini_getattr_set(lovset);
-	return rc ? rc : err;
-}
-
-static int lov_getattr_async(struct obd_export *exp, struct obd_info *oinfo,
-			     struct ptlrpc_request_set *rqset)
-{
-	struct lov_request_set *lovset;
-	struct lov_obd *lov;
-	struct lov_request *req;
-	int rc = 0, err;
-
-	LASSERT(oinfo);
-	ASSERT_LSM_MAGIC(oinfo->oi_md);
-
-	if (!exp || !exp->exp_obd)
-		return -ENODEV;
-
-	lov = &exp->exp_obd->u.lov;
-
-	rc = lov_prep_getattr_set(exp, oinfo, &lovset);
-	if (rc)
-		return rc;
-
-	CDEBUG(D_INFO, "objid "DOSTID": %ux%u byte stripes\n",
-	       POSTID(&oinfo->oi_md->lsm_oi), oinfo->oi_md->lsm_stripe_count,
-	       oinfo->oi_md->lsm_stripe_size);
-
-	list_for_each_entry(req, &lovset->set_list, rq_link) {
-		CDEBUG(D_INFO, "objid " DOSTID "[%d] has subobj " DOSTID " at idx%u\n",
-		       POSTID(&oinfo->oi_oa->o_oi), req->rq_stripe,
-		       POSTID(&req->rq_oi.oi_oa->o_oi), req->rq_idx);
-		rc = obd_getattr_async(lov->lov_tgts[req->rq_idx]->ltd_exp,
-				       &req->rq_oi, rqset);
-		if (rc) {
-			CERROR("%s: getattr objid "DOSTID" subobj"
-			       DOSTID" on OST idx %d: rc = %d\n",
-			       exp->exp_obd->obd_name,
-			       POSTID(&oinfo->oi_oa->o_oi),
-			       POSTID(&req->rq_oi.oi_oa->o_oi),
-			       req->rq_idx, rc);
-			goto out;
-		}
-	}
-
-	if (!list_empty(&rqset->set_requests)) {
-		LASSERT(rc == 0);
-		LASSERT(!rqset->set_interpret);
-		rqset->set_interpret = lov_getattr_interpret;
-		rqset->set_arg = (void *)lovset;
-		return rc;
-	}
-out:
-	if (rc)
-		atomic_set(&lovset->set_completes, 0);
-	err = lov_fini_getattr_set(lovset);
-	return rc ? rc : err;
-}
-
 int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
 {
 	struct lov_request_set *lovset = (struct lov_request_set *)data;
@@ -1530,7 +1462,6 @@ static struct obd_ops lov_obd_ops = {
 	.statfs_async   = lov_statfs_async,
 	.packmd         = lov_packmd,
 	.unpackmd       = lov_unpackmd,
-	.getattr_async  = lov_getattr_async,
 	.iocontrol      = lov_iocontrol,
 	.get_info       = lov_get_info,
 	.set_info_async = lov_set_info_async,
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 048e597..42e66d1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -97,22 +97,6 @@ static void lov_update_set(struct lov_request_set *set,
 	wake_up(&set->set_waitq);
 }
 
-int lov_update_common_set(struct lov_request_set *set,
-			  struct lov_request *req, int rc)
-{
-	struct lov_obd *lov = &set->set_exp->exp_obd->u.lov;
-
-	lov_update_set(set, req, rc);
-
-	/* grace error on inactive ost */
-	if (rc && !(lov->lov_tgts[req->rq_idx] &&
-		    lov->lov_tgts[req->rq_idx]->ltd_active))
-		rc = 0;
-
-	/* FIXME in raid1 regime, should return 0 */
-	return rc;
-}
-
 static void lov_set_add_req(struct lov_request *req,
 			    struct lov_request_set *set)
 {
@@ -183,134 +167,6 @@ out:
 	return rc;
 }
 
-static int common_attr_done(struct lov_request_set *set)
-{
-	struct lov_request *req;
-	struct obdo *tmp_oa;
-	int rc = 0, attrset = 0;
-
-	if (!set->set_oi->oi_oa)
-		return 0;
-
-	if (!atomic_read(&set->set_success))
-		return -EIO;
-
-	tmp_oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-	if (!tmp_oa) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	list_for_each_entry(req, &set->set_list, rq_link) {
-		if (!req->rq_complete || req->rq_rc)
-			continue;
-		if (req->rq_oi.oi_oa->o_valid == 0)   /* inactive stripe */
-			continue;
-		lov_merge_attrs(tmp_oa, req->rq_oi.oi_oa,
-				req->rq_oi.oi_oa->o_valid,
-				set->set_oi->oi_md, req->rq_stripe, &attrset);
-	}
-	if (!attrset) {
-		CERROR("No stripes had valid attrs\n");
-		rc = -EIO;
-	}
-
-	tmp_oa->o_oi = set->set_oi->oi_oa->o_oi;
-	memcpy(set->set_oi->oi_oa, tmp_oa, sizeof(*set->set_oi->oi_oa));
-out:
-	if (tmp_oa)
-		kmem_cache_free(obdo_cachep, tmp_oa);
-	return rc;
-}
-
-int lov_fini_getattr_set(struct lov_request_set *set)
-{
-	int rc = 0;
-
-	if (!set)
-		return 0;
-	LASSERT(set->set_exp);
-	if (atomic_read(&set->set_completes))
-		rc = common_attr_done(set);
-
-	lov_put_reqset(set);
-
-	return rc;
-}
-
-/* The callback for osc_getattr_async that finalizes a request info when a
- * response is received.
- */
-static int cb_getattr_update(void *cookie, int rc)
-{
-	struct obd_info *oinfo = cookie;
-	struct lov_request *lovreq;
-
-	lovreq = container_of(oinfo, struct lov_request, rq_oi);
-	return lov_update_common_set(lovreq->rq_rqset, lovreq, rc);
-}
-
-int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
-			 struct lov_request_set **reqset)
-{
-	struct lov_request_set *set;
-	struct lov_obd *lov = &exp->exp_obd->u.lov;
-	int rc = 0, i;
-
-	set = kzalloc(sizeof(*set), GFP_NOFS);
-	if (!set)
-		return -ENOMEM;
-	lov_init_set(set);
-
-	set->set_exp = exp;
-	set->set_oi = oinfo;
-
-	for (i = 0; i < oinfo->oi_md->lsm_stripe_count; i++) {
-		struct lov_oinfo *loi;
-		struct lov_request *req;
-
-		loi = oinfo->oi_md->lsm_oinfo[i];
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (!lov_check_and_wait_active(lov, loi->loi_ost_idx)) {
-			CDEBUG(D_HA, "lov idx %d inactive\n", loi->loi_ost_idx);
-			continue;
-		}
-
-		req = kzalloc(sizeof(*req), GFP_NOFS);
-		if (!req) {
-			rc = -ENOMEM;
-			goto out_set;
-		}
-
-		req->rq_stripe = i;
-		req->rq_idx = loi->loi_ost_idx;
-
-		req->rq_oi.oi_oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-		if (!req->rq_oi.oi_oa) {
-			kfree(req);
-			rc = -ENOMEM;
-			goto out_set;
-		}
-		memcpy(req->rq_oi.oi_oa, oinfo->oi_oa,
-		       sizeof(*req->rq_oi.oi_oa));
-		req->rq_oi.oi_oa->o_oi = loi->loi_oi;
-		req->rq_oi.oi_cb_up = cb_getattr_update;
-
-		lov_set_add_req(req, set);
-	}
-	if (!set->set_count) {
-		rc = -EIO;
-		goto out_set;
-	}
-	*reqset = set;
-	return rc;
-out_set:
-	lov_fini_getattr_set(set);
-	return rc;
-}
-
 #define LOV_U64_MAX ((__u64)~0ULL)
 #define LOV_SUM_MAX(tot, add)					   \
 	do {							    \
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 577f76e..c5621ad 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -126,6 +126,7 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 	switch (io->ci_type) {
 	case CIT_READ:
 	case CIT_WRITE:
+	case CIT_DATA_VERSION:
 		break;
 	case CIT_FAULT:
 		break;
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index a96addf..b4e062d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -606,6 +606,107 @@ static void osc_io_setattr_end(const struct lu_env *env,
 	}
 }
 
+struct osc_data_version_args {
+	struct osc_io *dva_oio;
+};
+
+static int
+osc_data_version_interpret(const struct lu_env *env, struct ptlrpc_request *req,
+			   void *arg, int rc)
+{
+	struct osc_data_version_args *dva = arg;
+	struct osc_io *oio = dva->dva_oio;
+	const struct ost_body *body;
+
+	if (rc < 0)
+		goto out;
+
+	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
+	if (!body) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, &oio->oi_oa,
+			     &body->oa);
+out:
+	oio->oi_cbarg.opc_rc = rc;
+	complete(&oio->oi_cbarg.opc_sync);
+
+	return 0;
+}
+
+static int osc_io_data_version_start(const struct lu_env *env,
+				     const struct cl_io_slice *slice)
+{
+	struct cl_data_version_io *dv = &slice->cis_io->u.ci_data_version;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct osc_object *obj = cl2osc(slice->cis_obj);
+	struct obd_export *exp = osc_export(obj);
+	struct lov_oinfo *loi = obj->oo_oinfo;
+	struct osc_data_version_args *dva;
+	struct obdo *oa = &oio->oi_oa;
+	struct ptlrpc_request *req;
+	struct ost_body *body;
+	int rc;
+
+	memset(oa, 0, sizeof(*oa));
+	oa->o_oi = loi->loi_oi;
+	oa->o_valid = OBD_MD_FLID | OBD_MD_FLGROUP;
+
+	if (dv->dv_flags & (LL_DV_RD_FLUSH | LL_DV_WR_FLUSH)) {
+		oa->o_valid |= OBD_MD_FLFLAGS;
+		oa->o_flags |= OBD_FL_SRVLOCK;
+		if (dv->dv_flags & LL_DV_WR_FLUSH)
+			oa->o_flags |= OBD_FL_FLUSH;
+	}
+
+	init_completion(&cbargs->opc_sync);
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_GETATTR);
+	if (!req)
+		return -ENOMEM;
+
+	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GETATTR);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
+	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
+
+	ptlrpc_request_set_replen(req);
+	req->rq_interpret_reply = osc_data_version_interpret;
+	CLASSERT(sizeof(*dva) <= sizeof(req->rq_async_args));
+	dva = ptlrpc_req_async_args(req);
+	dva->dva_oio = oio;
+
+	ptlrpcd_add_req(req);
+
+	return 0;
+}
+
+static void osc_io_data_version_end(const struct lu_env *env,
+				    const struct cl_io_slice *slice)
+{
+	struct cl_data_version_io *dv = &slice->cis_io->u.ci_data_version;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+
+	wait_for_completion(&cbargs->opc_sync);
+
+	if (cbargs->opc_rc) {
+		slice->cis_io->ci_result = cbargs->opc_rc;
+	} else if (!(oio->oi_oa.o_valid & OBD_MD_FLDATAVERSION)) {
+		slice->cis_io->ci_result = -EOPNOTSUPP;
+	} else {
+		dv->dv_data_version = oio->oi_oa.o_data_version;
+		slice->cis_io->ci_result = 0;
+	}
+}
+
 static int osc_io_read_start(const struct lu_env *env,
 			     const struct cl_io_slice *slice)
 {
@@ -759,6 +860,10 @@ static const struct cl_io_operations osc_io_ops = {
 			.cio_start  = osc_io_setattr_start,
 			.cio_end    = osc_io_setattr_end
 		},
+		[CIT_DATA_VERSION] = {
+			.cio_start	= osc_io_data_version_start,
+			.cio_end	= osc_io_data_version_end,
+		},
 		[CIT_FAULT] = {
 			.cio_start  = osc_io_fault_start,
 			.cio_end    = osc_io_end,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0413b88..2e4d2d5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -177,64 +177,6 @@ static inline void osc_pack_req_body(struct ptlrpc_request *req,
 			     oinfo->oi_oa);
 }
 
-static int osc_getattr_interpret(const struct lu_env *env,
-				 struct ptlrpc_request *req,
-				 struct osc_async_args *aa, int rc)
-{
-	struct ost_body *body;
-
-	if (rc != 0)
-		goto out;
-
-	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
-	if (body) {
-		CDEBUG(D_INODE, "mode: %o\n", body->oa.o_mode);
-		lustre_get_wire_obdo(&req->rq_import->imp_connect_data,
-				     aa->aa_oi->oi_oa, &body->oa);
-
-		/* This should really be sent by the OST */
-		aa->aa_oi->oi_oa->o_blksize = DT_MAX_BRW_SIZE;
-		aa->aa_oi->oi_oa->o_valid |= OBD_MD_FLBLKSZ;
-	} else {
-		CDEBUG(D_INFO, "can't unpack ost_body\n");
-		rc = -EPROTO;
-		aa->aa_oi->oi_oa->o_valid = 0;
-	}
-out:
-	rc = aa->aa_oi->oi_cb_up(aa->aa_oi, rc);
-	return rc;
-}
-
-static int osc_getattr_async(struct obd_export *exp, struct obd_info *oinfo,
-			     struct ptlrpc_request_set *set)
-{
-	struct ptlrpc_request *req;
-	struct osc_async_args *aa;
-	int rc;
-
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_GETATTR);
-	if (!req)
-		return -ENOMEM;
-
-	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GETATTR);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return rc;
-	}
-
-	osc_pack_req_body(req, oinfo);
-
-	ptlrpc_request_set_replen(req);
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_getattr_interpret;
-
-	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
-	aa = ptlrpc_req_async_args(req);
-	aa->aa_oi = oinfo;
-
-	ptlrpc_set_add_req(set, req);
-	return 0;
-}
-
 static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
 		       struct obd_info *oinfo)
 {
@@ -2986,7 +2928,6 @@ static struct obd_ops osc_obd_ops = {
 	.create         = osc_create,
 	.destroy        = osc_destroy,
 	.getattr        = osc_getattr,
-	.getattr_async  = osc_getattr_async,
 	.setattr        = osc_setattr,
 	.iocontrol      = osc_iocontrol,
 	.set_info_async = osc_set_info_async,
-- 
1.7.1
