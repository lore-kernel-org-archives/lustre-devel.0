From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:33 -0400
Subject: [lustre-devel] [PATCH 074/151] lustre: flr: mirror read and write
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-75-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

Support to perform I/O to designated mirror.

Create a new LL_IOC_FLR_SET_MIRROR kernel side so user
land applications can set the mirror id.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 5d7c4fa61ce7 ("LU-9771 flr: mirror read and write")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29095
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h           |  4 ++++
 fs/lustre/llite/file.c                  | 34 +++++++++++++++++++++++++++++++++
 fs/lustre/llite/lcommon_cl.c            |  3 +++
 fs/lustre/llite/llite_internal.h        |  5 +++++
 fs/lustre/lov/lov_io.c                  | 27 +++++++++++++++++++++++++-
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 6 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index d164294..99534f5 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1891,6 +1891,10 @@ struct cl_io {
 	 */
 	unsigned int		ci_ndelay_tried;
 	/**
+	 * Designated mirror index for this I/O.
+	 */
+	unsigned int	     ci_designated_mirror;
+	/**
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
 	unsigned int		ci_owned_nr;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 05a9fea..335f9bf 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1104,6 +1104,28 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	return rc;
 }
 
+/**
+ * Set designated mirror for I/O.
+ *
+ * So far only read, write, and truncated can support to issue I/O to
+ * designated mirror.
+ */
+void ll_io_set_mirror(struct cl_io *io, const struct file *file)
+{
+	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+
+	/* FLR: disable non-delay for designated mirror I/O because obviously
+	 * only one mirror is available
+	 */
+	if (fd->fd_designated_mirror > 0) {
+		io->ci_ndelay = 0;
+		io->ci_designated_mirror = fd->fd_designated_mirror;
+	}
+
+	CDEBUG(D_VFSTRACE, "%s: desiginated mirror: %d\n",
+	       file->f_path.dentry->d_name.name, io->ci_designated_mirror);
+}
+
 static bool file_is_noatime(const struct file *file)
 {
 	const struct vfsmount *mnt = file->f_path.mnt;
@@ -1160,6 +1182,8 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
 	 * available mirror for write.
 	 */
 	io->ci_ndelay = !write;
+
+	ll_io_set_mirror(io, file);
 }
 
 static ssize_t
@@ -2976,6 +3000,16 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		kfree(k_ladvise_hdr);
 		return rc;
 	}
+	case LL_IOC_FLR_SET_MIRROR: {
+		/* mirror I/O must be direct to avoid polluting page cache
+		 * by stale data.
+		 */
+		if (!(file->f_flags & O_DIRECT))
+			return -EINVAL;
+
+		fd->fd_designated_mirror = (u32)arg;
+		return 0;
+	}
 	case FS_IOC_FSGETXATTR:
 		return ll_ioctl_fsgetxattr(inode, cmd, arg);
 	case FS_IOC_FSSETXATTR:
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index e859351..156b1ad 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -103,6 +103,9 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 	io->u.ci_setattr.sa_xvalid = xvalid;
 	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&obj->co_lu);
 
+	if (attr->ia_valid & ATTR_FILE)
+		ll_io_set_mirror(io, attr->ia_file);
+
 again:
 	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0) {
 		struct vvp_io *vio = vvp_env_io(env);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 392d82c..2d32c5e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -653,6 +653,10 @@ struct ll_file_data {
 	 */
 	bool fd_write_failed;
 	bool ll_lock_no_expand;
+	/* Used by mirrored file to lead IOs to a specific mirror, usually
+	 * for mirror resync. 0 means default.
+	 */
+	u32 fd_designated_mirror;
 	rwlock_t fd_lock; /* protect lcc list */
 	struct list_head fd_lccs; /* list of ll_cl_context */
 };
@@ -840,6 +844,7 @@ int ll_dir_getstripe(struct inode *inode, void **lmmp, int *lmm_size,
 int ll_data_version(struct inode *inode, u64 *data_version, int flags);
 int ll_hsm_release(struct inode *inode);
 int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss);
+void ll_io_set_mirror(struct cl_io *io, const struct file *file);
 
 /* llite/dcache.c */
 
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 8e4ff6c..628057d 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -299,6 +299,27 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		return 0;
 	}
 
+	/* find the corresponding mirror for designated mirror IO */
+	if (io->ci_designated_mirror > 0) {
+		struct lov_mirror_entry *entry;
+
+		LASSERT(!io->ci_ndelay);
+
+		index = 0;
+		lio->lis_mirror_index = -1;
+		lov_foreach_mirror_entry(obj, entry) {
+			if (entry->lre_mirror_id ==
+			    io->ci_designated_mirror) {
+				lio->lis_mirror_index = index;
+				break;
+			}
+
+			index++;
+		}
+
+		return (lio->lis_mirror_index < 0) ? -EINVAL : 0;
+	}
+
 	result = lov_io_mirror_write_intent(lio, obj, io);
 	if (result)
 		return result;
@@ -998,7 +1019,11 @@ static int lov_io_submit(const struct lu_env *env,
 		if (lov_page_is_empty(page)) {
 			cl_page_list_move(&queue->c2_qout, qin, page);
 
-			cl_page_prep(env, ios->cis_io, page, crt);
+			/* it could only be mirror read to get here therefore
+			 * the pages will be transient. We don't care about
+			 * the return code of cl_page_prep() at all.
+			 */
+			(void) cl_page_prep(env, ios->cis_io, page, crt);
 			cl_page_completion(env, page, crt, 0);
 			continue;
 		}
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index fe60e67..f5cd979 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -276,7 +276,7 @@ struct ll_futimes_3 {
 #define LL_IOC_GET_CONNECT_FLAGS	_IOWR('f', 174, __u64 *)
 #define LL_IOC_GET_MDTIDX		_IOR('f', 175, int)
 #define LL_IOC_FUTIMES_3		_IOWR('f', 176, struct ll_futimes_3)
-
+#define LL_IOC_FLR_SET_MIRROR		_IOW('f', 177, long)
 /*	lustre_ioctl.h			177-210 */
 #define LL_IOC_HSM_STATE_GET		_IOR('f', 211, struct hsm_user_state)
 #define LL_IOC_HSM_STATE_SET		_IOW('f', 212, struct hsm_state_set)
-- 
1.8.3.1
