From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:07 -0400
Subject: [lustre-devel] [PATCH 30/45] lustre: fallocate: Implement fallocate
 preallocate operation
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Swapnil Pimpale <spimpale@ddn.com>

This patch adds fallocate(2) preallocate operation support
for Lustre. fallocate(2) method of the inode_operations or
file_operations is implemented and transported to the OSTs
to interface with the underlying OSD's fallocate(2) code.

In a saperate patch, a new RPC, OST_FALLOCATE has been
added and reserved for space preallocation. The fallocate
functionality (prealloc) in CLIO has been multiplexed
with CIT_SETATTR. (https://review.whamcloud.com/37277)

Lustre fsx(File system exerciser) is updated in a saperate
patch to handle fallocate calls. (https://review.whamcloud.com/37277)

Only fallocate preallocate operation is supported by this
patch for now. Other operations like, FALLOC_FL_PUNCH
(deallocate), FALLOC_FL_ZERO_RANGE, FALLOC_FL_COLLAPSE_RANGE
and FALLOC_FL_INSPECT_RANGE is not supported by this patch
and will be addressed by a separate patch.

ZFS operation is not supported by this patch. ZFS fallocate(2)
will be addressed by patch (https://review.whamcloud.com/36506/)

New test case under sanity is added to verify fallocate
call.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3606
Lustre-commit: 48457868a02ae ("LU-3606 fallocate: Implement fallocate preallocate operation")
Signed-off-by: Swapnil Pimpale <spimpale@ddn.com>
Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Abrarahmed Momin <abrar.momin@gmail.com>
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/9275
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h         | 44 +++++++++++++++++-
 fs/lustre/include/lustre_req_layout.h |  1 +
 fs/lustre/include/obd_support.h       |  5 ++-
 fs/lustre/llite/file.c                | 84 +++++++++++++++++++++++++++++++++--
 fs/lustre/llite/lcommon_cl.c          |  2 +
 fs/lustre/llite/llite_internal.h      |  1 +
 fs/lustre/llite/lproc_llite.c         |  1 +
 fs/lustre/llite/vvp_io.c              | 17 ++++---
 fs/lustre/lov/lov_io.c                | 27 ++++++++---
 fs/lustre/osc/osc_internal.h          |  3 ++
 fs/lustre/osc/osc_io.c                | 56 +++++++++++++++++++----
 fs/lustre/osc/osc_request.c           | 65 ++++++++++++++++++++++++++-
 fs/lustre/ptlrpc/layout.c             |  5 +++
 13 files changed, 286 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 91d3172..cde89f67 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -89,6 +89,7 @@
 /*
  * super-class definitions.
  */
+#include <linux/uio.h>
 #include <lu_object.h>
 #include <linux/atomic.h>
 #include <linux/mutex.h>
@@ -1765,6 +1766,32 @@ struct cl_io_rw_common {
 	int			crw_nonblock;
 };
 
+enum cl_setattr_subtype {
+	/** regular setattr **/
+	CL_SETATTR_REG	= 1,
+	/** truncate(2) **/
+	CL_SETATTR_TRUNC,
+	/** fallocate(2) - mode preallocate **/
+	CL_SETATTR_FALLOCATE
+};
+
+struct cl_io_range {
+	loff_t		cir_pos;
+	size_t		cir_count;
+};
+
+struct cl_io_pt {
+	struct cl_io_pt	*cip_next;
+	struct kiocb	cip_iocb;
+	struct iov_iter	cip_iter;
+	struct file	*cip_file;
+	enum cl_io_type	cip_iot;
+	unsigned int	cip_need_restart:1;
+	loff_t		cip_pos;
+	size_t		cip_count;
+	ssize_t		cip_result;
+};
+
 /**
  * State for io.
  *
@@ -1812,6 +1839,14 @@ struct cl_io {
 			int			sa_stripe_index;
 			struct ost_layout	sa_layout;
 			const struct lu_fid	*sa_parent_fid;
+			/* SETATTR interface is used for regular setattr, */
+			/* truncate(2) and fallocate(2) subtypes */
+			enum cl_setattr_subtype	sa_subtype;
+			/* The following are used for fallocate(2) */
+			int			sa_falloc_mode;
+			loff_t			sa_falloc_offset;
+			loff_t			sa_falloc_len;
+			loff_t			sa_falloc_end;
 		} ci_setattr;
 		struct cl_data_version_io {
 			u64			dv_data_version;
@@ -2399,7 +2434,14 @@ static inline int cl_io_is_mkwrite(const struct cl_io *io)
 static inline int cl_io_is_trunc(const struct cl_io *io)
 {
 	return io->ci_type == CIT_SETATTR &&
-		(io->u.ci_setattr.sa_avalid & ATTR_SIZE);
+		(io->u.ci_setattr.sa_avalid & ATTR_SIZE) &&
+		(io->u.ci_setattr.sa_subtype != CL_SETATTR_FALLOCATE);
+}
+
+static inline int cl_io_is_fallocate(const struct cl_io *io)
+{
+	return (io->ci_type == CIT_SETATTR) &&
+	       (io->u.ci_setattr.sa_subtype == CL_SETATTR_FALLOCATE);
 }
 
 struct cl_io *cl_io_top(struct cl_io *io);
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 8efdf7f..72d9df0 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -186,6 +186,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_OST_SETATTR;
 extern struct req_format RQF_OST_CREATE;
 extern struct req_format RQF_OST_PUNCH;
+extern struct req_format RQF_OST_FALLOCATE;
 extern struct req_format RQF_OST_SYNC;
 extern struct req_format RQF_OST_DESTROY;
 extern struct req_format RQF_OST_BRW_READ;
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 1f69530..ce0aa8c 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -264,8 +264,9 @@
 #define OBD_FAIL_OST_DQACQ_NET				0x230
 #define OBD_FAIL_OST_STATFS_EINPROGRESS			0x231
 #define OBD_FAIL_OST_SET_INFO_NET			0x232
-#define OBD_FAIL_OST_DISCONNECT_DELAY	 0x245
-#define OBD_FAIL_OST_PREPARE_DELAY	 0x247
+#define OBD_FAIL_OST_DISCONNECT_DELAY			0x245
+#define OBD_FAIL_OST_PREPARE_DELAY			0x247
+#define OBD_FAIL_OST_FALLOCATE_NET			0x249
 
 #define OBD_FAIL_LDLM					0x300
 #define OBD_FAIL_LDLM_NAMESPACE_NEW			0x301
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index be20b74..871fa59 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -43,6 +43,8 @@
 #include <linux/file.h>
 #include <linux/sched.h>
 #include <linux/mount.h>
+#include <linux/falloc.h>
+
 #include <uapi/linux/lustre/lustre_fiemap.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <lustre_swab.h>
@@ -4635,6 +4637,79 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 	return 0;
 }
 
+int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
+{
+	struct lu_env *env;
+	struct cl_io *io;
+	u16 refcheck;
+	int rc; loff_t sa_falloc_end;
+	loff_t size = i_size_read(inode);
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	io = vvp_env_thread_io(env);
+	io->ci_obj = ll_i2info(inode)->lli_clob;
+	io->ci_verify_layout = 1;
+	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&io->ci_obj->co_lu);
+	io->u.ci_setattr.sa_falloc_mode = mode;
+	io->u.ci_setattr.sa_falloc_offset = offset;
+	io->u.ci_setattr.sa_falloc_len = len;
+	io->u.ci_setattr.sa_falloc_end = io->u.ci_setattr.sa_falloc_offset +
+					 io->u.ci_setattr.sa_falloc_len;
+	io->u.ci_setattr.sa_subtype = CL_SETATTR_FALLOCATE;
+	sa_falloc_end = io->u.ci_setattr.sa_falloc_end;
+	if (sa_falloc_end > size) {
+		/* Check new size against VFS/VM file size limit and rlimit */
+		rc = inode_newsize_ok(inode, sa_falloc_end);
+		if (rc)
+			goto out;
+		if (sa_falloc_end > ll_file_maxbytes(inode)) {
+			CDEBUG(D_INODE, "file size too large %llu > %llu\n",
+			       (unsigned long long)(sa_falloc_end),
+			       ll_file_maxbytes(inode));
+			rc = -EFBIG;
+			goto out;
+		}
+		io->u.ci_setattr.sa_attr.lvb_size = sa_falloc_end;
+		if (!(mode & FALLOC_FL_KEEP_SIZE))
+			io->u.ci_setattr.sa_avalid |= ATTR_SIZE;
+	} else {
+		io->u.ci_setattr.sa_attr.lvb_size = size;
+	}
+
+again:
+	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0)
+		rc = cl_io_loop(env, io);
+	else
+		rc = io->ci_result;
+
+	cl_io_fini(env, io);
+	if (unlikely(io->ci_need_restart))
+		goto again;
+
+out:
+	cl_env_put(env, &refcheck);
+	return rc;
+}
+
+long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	/*
+	 * Only mode == 0 (which is standard prealloc) is supported now.
+	 * Punch is not supported yet.
+	 */
+	if (mode & ~FALLOC_FL_KEEP_SIZE)
+		return -EOPNOTSUPP;
+
+	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FALLOCATE, 1);
+
+	return cl_falloc(inode, mode, offset, len);
+}
+
 static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		     u64 start, u64 len)
 {
@@ -4759,7 +4834,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.llseek			= ll_file_seek,
 	.splice_read		= generic_file_splice_read,
 	.fsync			= ll_fsync,
-	.flush			= ll_flush
+	.flush			= ll_flush,
+	.fallocate		= ll_fallocate,
 };
 
 const struct file_operations ll_file_operations_flock = {
@@ -4774,7 +4850,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.fsync			= ll_fsync,
 	.flush			= ll_flush,
 	.flock			= ll_file_flock,
-	.lock			= ll_file_flock
+	.lock			= ll_file_flock,
+	.fallocate		= ll_fallocate,
 };
 
 /* These are for -o noflock - to return ENOSYS on flock calls */
@@ -4790,7 +4867,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.fsync			= ll_fsync,
 	.flush			= ll_flush,
 	.flock			= ll_file_noflock,
-	.lock			= ll_file_noflock
+	.lock			= ll_file_noflock,
+	.fallocate		= ll_fallocate,
 };
 
 const struct inode_operations ll_file_inode_operations = {
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 8cfcfe5..c945351 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -102,6 +102,8 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 	io->u.ci_setattr.sa_xvalid = xvalid;
 	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&obj->co_lu);
 
+	if (attr->ia_valid & ATTR_SIZE)
+		io->u.ci_setattr.sa_subtype = CL_SETATTR_TRUNC;
 again:
 	if (attr->ia_valid & ATTR_FILE)
 		ll_io_set_mirror(io, attr->ia_file);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 76715818..2544a40 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -916,6 +916,7 @@ enum {
 	LPROC_LL_LISTXATTR,
 	LPROC_LL_REMOVEXATTR,
 	LPROC_LL_INODE_PERM,
+	LPROC_LL_FALLOCATE,
 	LPROC_LL_FILE_OPCODES
 };
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 36cc8bc..4bce3a6 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1580,6 +1580,7 @@ static void sbi_kobj_release(struct kobject *kobj)
 	{ LPROC_LL_TRUNC,	LPROCFS_TYPE_LATENCY,	"truncate" },
 	{ LPROC_LL_FLOCK,	LPROCFS_TYPE_LATENCY,	"flock" },
 	{ LPROC_LL_GETATTR,	LPROCFS_TYPE_LATENCY,	"getattr" },
+	{ LPROC_LL_FALLOCATE,	 LPROCFS_TYPE_LATENCY,	"fallocate" },
 	/* dir inode operation */
 	{ LPROC_LL_CREATE,	LPROCFS_TYPE_LATENCY,	"create" },
 	{ LPROC_LL_LINK,	LPROCFS_TYPE_LATENCY,	"link" },
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 5a488de..d755551 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -615,13 +615,16 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
 	struct cl_io *io = ios->cis_io;
-	u64 new_size;
+	u64 lock_start = 0;
+	u64 lock_end = OBD_OBJECT_EOF;
 	u32 enqflags = 0;
 
 	if (cl_io_is_trunc(io)) {
-		new_size = io->u.ci_setattr.sa_attr.lvb_size;
-		if (new_size == 0)
+		if (io->u.ci_setattr.sa_attr.lvb_size == 0)
 			enqflags = CEF_DISCARD_DATA;
+	} else if (cl_io_is_fallocate(io)) {
+		lock_start = io->u.ci_setattr.sa_falloc_offset;
+		lock_end = lock_start + io->u.ci_setattr.sa_attr.lvb_size;
 	} else {
 		unsigned int valid = io->u.ci_setattr.sa_avalid;
 
@@ -635,11 +638,10 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 		     io->u.ci_setattr.sa_attr.lvb_atime >=
 		     io->u.ci_setattr.sa_attr.lvb_ctime))
 			return 0;
-		new_size = 0;
 	}
 
 	return vvp_io_one_lock(env, io, enqflags, CLM_WRITE,
-			       new_size, OBD_OBJECT_EOF);
+			       lock_start, lock_end);
 }
 
 static int vvp_do_vmtruncate(struct inode *inode, size_t size)
@@ -695,6 +697,9 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 		trunc_sem_down_write(&lli->lli_trunc_sem);
 		inode_lock(inode);
 		inode_dio_wait(inode);
+	} else if (cl_io_is_fallocate(io)) {
+		inode_lock(inode);
+		inode_dio_wait(inode);
 	} else {
 		inode_lock(inode);
 	}
@@ -719,6 +724,8 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 		vvp_do_vmtruncate(inode, io->u.ci_setattr.sa_attr.lvb_size);
 		inode_unlock(inode);
 		trunc_sem_up_write(&lli->lli_trunc_sem);
+	} else if (cl_io_is_fallocate(io)) {
+		inode_unlock(inode);
 	} else {
 		inode_unlock(inode);
 	}
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index fefbf39..615db73 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -486,11 +486,16 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		break;
 
 	case CIT_SETATTR:
-		if (cl_io_is_trunc(io))
+		if (cl_io_is_fallocate(io)) {
+			lio->lis_pos = io->u.ci_setattr.sa_falloc_offset;
+			lio->lis_endpos = io->u.ci_setattr.sa_falloc_end;
+		} else if (cl_io_is_trunc(io)) {
 			lio->lis_pos = io->u.ci_setattr.sa_attr.lvb_size;
-		else
+			lio->lis_endpos = OBD_OBJECT_EOF;
+		} else {
 			lio->lis_pos = 0;
-		lio->lis_endpos = OBD_OBJECT_EOF;
+			lio->lis_endpos = OBD_OBJECT_EOF;
+		}
 		break;
 
 	case CIT_DATA_VERSION:
@@ -639,15 +644,24 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 			parent->u.ci_setattr.sa_attr_flags;
 		io->u.ci_setattr.sa_avalid = parent->u.ci_setattr.sa_avalid;
 		io->u.ci_setattr.sa_xvalid = parent->u.ci_setattr.sa_xvalid;
+		io->u.ci_setattr.sa_falloc_mode =
+			parent->u.ci_setattr.sa_falloc_mode;
 		io->u.ci_setattr.sa_stripe_index = stripe;
 		io->u.ci_setattr.sa_parent_fid =
 			parent->u.ci_setattr.sa_parent_fid;
+		/* For SETATTR(fallocate) pass the subtype to lower IO */
+		io->u.ci_setattr.sa_subtype = parent->u.ci_setattr.sa_subtype;
 		if (cl_io_is_trunc(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
 
 			new_size = lov_size_to_stripe(lsm, index, new_size,
 						      stripe);
 			io->u.ci_setattr.sa_attr.lvb_size = new_size;
+		} else if (cl_io_is_fallocate(io)) {
+			io->u.ci_setattr.sa_falloc_offset = start;
+			io->u.ci_setattr.sa_falloc_end = end;
+			io->u.ci_setattr.sa_attr.lvb_size =
+				parent->u.ci_setattr.sa_attr.lvb_size;
 		}
 		lov_lsm2layout(lsm, lsm->lsm_entries[index],
 			       &io->u.ci_setattr.sa_layout);
@@ -1488,8 +1502,11 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 		 * - in open, for open O_TRUNC
 		 * - in setattr, for truncate
 		 */
-		/* the truncate is for size > 0 so triggers a restore */
-		if (cl_io_is_trunc(io)) {
+		/*
+		 * the truncate is for size > 0 so triggers a restore,
+		 * also trigger a restore for prealloc/punch
+		 */
+		if (cl_io_is_trunc(io) || cl_io_is_fallocate(io)) {
 			io->ci_restore_needed = 1;
 			result = -ENODATA;
 		} else {
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 47bb5f2..d05595a 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -73,6 +73,9 @@ int osc_match_base(const struct lu_env *env, struct obd_export *exp,
 int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		      obd_enqueue_update_f upcall, void *cookie,
 		      struct ptlrpc_request_set *rqset);
+int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
+		       obd_enqueue_update_f upcall, void *cookie,
+		       int mode);
 int osc_sync_base(struct osc_object *exp, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset);
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 7976a91..7ec059a 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -41,6 +41,7 @@
 #include <lustre_obdo.h>
 #include <lustre_osc.h>
 #include <linux/pagevec.h>
+#include <linux/falloc.h>
 
 #include "osc_internal.h"
 
@@ -543,15 +544,22 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	struct obdo *oa = &oio->oi_oa;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
-	u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 	unsigned int ia_avalid = io->u.ci_setattr.sa_avalid;
 	enum op_xvalid ia_xvalid = io->u.ci_setattr.sa_xvalid;
+	u64 size = io->u.ci_setattr.sa_attr.lvb_size;
+	u64 end = OBD_OBJECT_EOF;
+	bool io_is_falloc = false;
 	int result = 0;
 
 	/* truncate cache dirty pages first */
-	if (cl_io_is_trunc(io))
+	if (cl_io_is_trunc(io)) {
 		result = osc_cache_truncate_start(env, cl2osc(obj), size,
 						  &oio->oi_trunc);
+	} else if (cl_io_is_fallocate(io)) {
+		io_is_falloc = true;
+		size = io->u.ci_setattr.sa_falloc_offset;
+		end = io->u.ci_setattr.sa_falloc_end;
+	}
 
 	if (result == 0 && oio->oi_lockless == 0) {
 		cl_object_attr_lock(obj);
@@ -603,9 +611,15 @@ static int osc_io_setattr_start(const struct lu_env *env,
 			oa->o_mtime = attr->cat_mtime;
 		}
 		if (ia_avalid & ATTR_SIZE) {
-			oa->o_size = size;
-			oa->o_blocks = OBD_OBJECT_EOF;
-			oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
+			if (io_is_falloc) {
+				oa->o_size = size;
+				oa->o_blocks = end;
+				oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
+			} else {
+				oa->o_size = size;
+				oa->o_blocks = OBD_OBJECT_EOF;
+				oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
+			}
 
 			if (oio->oi_lockless) {
 				oa->o_flags = OBD_FL_SRVLOCK;
@@ -627,13 +641,20 @@ static int osc_io_setattr_start(const struct lu_env *env,
 
 		init_completion(&cbargs->opc_sync);
 
-		if (ia_avalid & ATTR_SIZE)
+		if (io_is_falloc) {
+			int falloc_mode = io->u.ci_setattr.sa_falloc_mode;
+
+			result = osc_fallocate_base(osc_export(cl2osc(obj)),
+						    oa, osc_async_upcall,
+						    cbargs, falloc_mode);
+		} else if (ia_avalid & ATTR_SIZE) {
 			result = osc_punch_send(osc_export(cl2osc(obj)),
 						oa, osc_async_upcall, cbargs);
-		else
+		} else {
 			result = osc_setattr_async(osc_export(cl2osc(obj)),
 						   oa, osc_async_upcall,
 						   cbargs, PTLRPCD_SET);
+		}
 		cbargs->opc_rpc_sent = result == 0;
 	}
 	return result;
@@ -661,7 +682,7 @@ void osc_io_setattr_end(const struct lu_env *env,
 			/* lockless truncate */
 			struct osc_device *osd = lu2osc_dev(obj->co_lu.lo_dev);
 
-			LASSERT(cl_io_is_trunc(io));
+			LASSERT(cl_io_is_trunc(io) || cl_io_is_fallocate(io));
 			/* XXX: Need a lock. */
 			osd->od_stats.os_lockless_truncates++;
 		}
@@ -682,6 +703,25 @@ void osc_io_setattr_end(const struct lu_env *env,
 		osc_cache_truncate_end(env, oio->oi_trunc);
 		oio->oi_trunc = NULL;
 	}
+
+	if (cl_io_is_fallocate(io)) {
+		cl_object_attr_lock(obj);
+
+		/* update blocks */
+		if (oa->o_valid & OBD_MD_FLBLOCKS) {
+			attr->cat_blocks = oa->o_blocks;
+			cl_valid |= CAT_BLOCKS;
+		}
+
+		/* update size */
+		if (oa->o_valid & OBD_MD_FLSIZE) {
+			attr->cat_size = oa->o_size;
+			cl_valid |= CAT_SIZE;
+		}
+
+		cl_object_attr_update(env, obj, attr, cl_valid);
+		cl_object_attr_unlock(obj);
+	}
 }
 EXPORT_SYMBOL(osc_io_setattr_end);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 4db249e..b1bf8c6 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -34,8 +34,8 @@
 #define DEBUG_SUBSYSTEM S_OSC
 
 #include <linux/workqueue.h>
+#include <linux/falloc.h>
 #include <linux/highmem.h>
-#include <linux/libcfs/libcfs_hash.h>
 #include <linux/sched/mm.h>
 
 #include <lustre_dlm.h>
@@ -427,6 +427,69 @@ int osc_punch_send(struct obd_export *exp, struct obdo *oa,
 }
 EXPORT_SYMBOL(osc_punch_send);
 
+/**
+ * osc_fallocate_base() - Handles fallocate request.
+ *
+ * @exp:	Export structure
+ * @oa:		Attributes passed to OSS from client (obdo structure)
+ * @upcall:	Primary & supplementary group information
+ * @cookie:	Exclusive identifier
+ * @rqset:	Request list.
+ * @mode:	Operation done on given range.
+ *
+ * osc_fallocate_base() - Handles fallocate requests only. Only block
+ * allocation or standard preallocate operation is supported currently.
+ * Other mode flags is not supported yet. ftruncate(2) or truncate(2)
+ * is supported via SETATTR request.
+ *
+ * Return: Non-zero on failure and O on success.
+ */
+int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
+		       obd_enqueue_update_f upcall, void *cookie, int mode)
+{
+	struct ptlrpc_request *req;
+	struct osc_setattr_args *sa;
+	struct ost_body *body;
+	struct obd_import *imp = class_exp2cliimp(exp);
+	int rc;
+
+	/*
+	 * Only mode == 0 (which is standard prealloc) is supported now.
+	 * Punch is not supported yet.
+	 */
+	if (mode & ~FALLOC_FL_KEEP_SIZE)
+		return -EOPNOTSUPP;
+	oa->o_falloc_mode = mode;
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
+				   &RQF_OST_FALLOCATE);
+	if (!req)
+		return -ENOMEM;
+
+	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_FALLOCATE);
+	if (rc != 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
+	LASSERT(body);
+
+	lustre_set_wire_obdo(&imp->imp_connect_data, &body->oa, oa);
+
+	ptlrpc_request_set_replen(req);
+
+	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
+	BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
+	sa = ptlrpc_req_async_args(sa, req);
+	sa->sa_oa = oa;
+	sa->sa_upcall = upcall;
+	sa->sa_cookie = cookie;
+
+	ptlrpcd_add_req(req);
+	return 0;
+}
+
 static int osc_sync_interpret(const struct lu_env *env,
 			      struct ptlrpc_request *req,
 			      void *arg, int rc)
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 832c896..754c87d 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -757,6 +757,7 @@
 	&RQF_OST_SETATTR,
 	&RQF_OST_CREATE,
 	&RQF_OST_PUNCH,
+	&RQF_OST_FALLOCATE,
 	&RQF_OST_SYNC,
 	&RQF_OST_DESTROY,
 	&RQF_OST_BRW_READ,
@@ -1595,6 +1596,10 @@ struct req_format RQF_OST_PUNCH =
 	DEFINE_REQ_FMT0("OST_PUNCH", ost_body_capa, ost_body_only);
 EXPORT_SYMBOL(RQF_OST_PUNCH);
 
+struct req_format RQF_OST_FALLOCATE =
+	DEFINE_REQ_FMT0("OST_FALLOCATE", ost_body_capa, ost_body_only);
+EXPORT_SYMBOL(RQF_OST_FALLOCATE);
+
 struct req_format RQF_OST_SYNC =
 	DEFINE_REQ_FMT0("OST_SYNC", ost_body_capa, ost_body_only);
 EXPORT_SYMBOL(RQF_OST_SYNC);
-- 
1.8.3.1
