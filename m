From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:04 -0400
Subject: [lustre-devel] [PATCH 32/43] staging/lustre/llite: move vvp_io
	functions to vvp_io.c
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-33-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Move all vvp_io related functions from lustre/llite/lcommon_cl.c to
the sole file where they are used lustre/llite/vvp_io.c.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13376
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 197 --------------------
 .../staging/lustre/lustre/llite/llite_internal.h   |   1 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  22 +--
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 198 ++++++++++++++++++++-
 4 files changed, 196 insertions(+), 222 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 630c371..1b11103 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -184,192 +184,6 @@ void ccc_global_fini(struct lu_device_type *device_type)
 	lu_kmem_fini(ccc_caches);
 }
 
-static void vvp_object_size_lock(struct cl_object *obj)
-{
-	struct inode *inode = vvp_object_inode(obj);
-
-	ll_inode_size_lock(inode);
-	cl_object_attr_lock(obj);
-}
-
-static void vvp_object_size_unlock(struct cl_object *obj)
-{
-	struct inode *inode = vvp_object_inode(obj);
-
-	cl_object_attr_unlock(obj);
-	ll_inode_size_unlock(inode);
-}
-
-/*****************************************************************************
- *
- * io operations.
- *
- */
-
-int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
-			  __u32 enqflags, enum cl_lock_mode mode,
-			  pgoff_t start, pgoff_t end)
-{
-	struct vvp_io          *vio   = vvp_env_io(env);
-	struct cl_lock_descr   *descr = &vio->vui_link.cill_descr;
-	struct cl_object       *obj   = io->ci_obj;
-
-	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
-
-	CDEBUG(D_VFSTRACE, "lock: %d [%lu, %lu]\n", mode, start, end);
-
-	memset(&vio->vui_link, 0, sizeof(vio->vui_link));
-
-	if (vio->vui_fd && (vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
-		descr->cld_mode = CLM_GROUP;
-		descr->cld_gid  = vio->vui_fd->fd_grouplock.cg_gid;
-	} else {
-		descr->cld_mode  = mode;
-	}
-	descr->cld_obj   = obj;
-	descr->cld_start = start;
-	descr->cld_end   = end;
-	descr->cld_enq_flags = enqflags;
-
-	cl_io_lock_add(env, io, &vio->vui_link);
-	return 0;
-}
-
-void vvp_io_update_iov(const struct lu_env *env,
-		       struct vvp_io *vio, struct cl_io *io)
-{
-	size_t size = io->u.ci_rw.crw_count;
-
-	if (!cl_is_normalio(env, io) || !vio->vui_iter)
-		return;
-
-	iov_iter_truncate(vio->vui_iter, size);
-}
-
-int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
-		    __u32 enqflags, enum cl_lock_mode mode,
-		    loff_t start, loff_t end)
-{
-	struct cl_object *obj = io->ci_obj;
-
-	return vvp_io_one_lock_index(env, io, enqflags, mode,
-				     cl_index(obj, start), cl_index(obj, end));
-}
-
-void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
-{
-	CLOBINVRNT(env, ios->cis_io->ci_obj,
-		   vvp_object_invariant(ios->cis_io->ci_obj));
-}
-
-void vvp_io_advance(const struct lu_env *env,
-		    const struct cl_io_slice *ios,
-		    size_t nob)
-{
-	struct vvp_io    *vio = cl2vvp_io(env, ios);
-	struct cl_io     *io  = ios->cis_io;
-	struct cl_object *obj = ios->cis_io->ci_obj;
-
-	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
-
-	if (!cl_is_normalio(env, io))
-		return;
-
-	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count  -= nob);
-}
-
-/**
- * Helper function that if necessary adjusts file size (inode->i_size), when
- * position at the offset \a pos is accessed. File size can be arbitrary stale
- * on a Lustre client, but client at least knows KMS. If accessed area is
- * inside [0, KMS], set file size to KMS, otherwise glimpse file size.
- *
- * Locking: cl_isize_lock is used to serialize changes to inode size and to
- * protect consistency between inode size and cl_object
- * attributes. cl_object_size_lock() protects consistency between cl_attr's of
- * top-object and sub-objects.
- */
-int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_io *io, loff_t start, size_t count, int *exceed)
-{
-	struct cl_attr *attr  = ccc_env_thread_attr(env);
-	struct inode   *inode = vvp_object_inode(obj);
-	loff_t	  pos   = start + count - 1;
-	loff_t kms;
-	int result;
-
-	/*
-	 * Consistency guarantees: following possibilities exist for the
-	 * relation between region being accessed and real file size at this
-	 * moment:
-	 *
-	 *  (A): the region is completely inside of the file;
-	 *
-	 *  (B-x): x bytes of region are inside of the file, the rest is
-	 *  outside;
-	 *
-	 *  (C): the region is completely outside of the file.
-	 *
-	 * This classification is stable under DLM lock already acquired by
-	 * the caller, because to change the class, other client has to take
-	 * DLM lock conflicting with our lock. Also, any updates to ->i_size
-	 * by other threads on this client are serialized by
-	 * ll_inode_size_lock(). This guarantees that short reads are handled
-	 * correctly in the face of concurrent writes and truncates.
-	 */
-	vvp_object_size_lock(obj);
-	result = cl_object_attr_get(env, obj, attr);
-	if (result == 0) {
-		kms = attr->cat_kms;
-		if (pos > kms) {
-			/*
-			 * A glimpse is necessary to determine whether we
-			 * return a short read (B) or some zeroes at the end
-			 * of the buffer (C)
-			 */
-			vvp_object_size_unlock(obj);
-			result = cl_glimpse_lock(env, io, inode, obj, 0);
-			if (result == 0 && exceed) {
-				/* If objective page index exceed end-of-file
-				 * page index, return directly. Do not expect
-				 * kernel will check such case correctly.
-				 * linux-2.6.18-128.1.1 miss to do that.
-				 * --bug 17336
-				 */
-				loff_t size = i_size_read(inode);
-				loff_t cur_index = start >> PAGE_CACHE_SHIFT;
-				loff_t size_index = (size - 1) >>
-						    PAGE_CACHE_SHIFT;
-
-				if ((size == 0 && cur_index != 0) ||
-				    size_index < cur_index)
-					*exceed = 1;
-			}
-			return result;
-		}
-		/*
-		 * region is within kms and, hence, within real file
-		 * size (A). We need to increase i_size to cover the
-		 * read region so that generic_file_read() will do its
-		 * job, but that doesn't mean the kms size is
-		 * _correct_, it is only the _minimum_ size. If
-		 * someone does a stat they will get the correct size
-		 * which will always be >= the kms value here.
-		 * b=11081
-		 */
-		if (i_size_read(inode) < kms) {
-			i_size_write(inode, kms);
-			CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
-			       PFID(lu_object_fid(&obj->co_lu)),
-			       (__u64)i_size_read(inode));
-		}
-	}
-
-	vvp_object_size_unlock(obj);
-
-	return result;
-}
-
 /*****************************************************************************
  *
  * Transfer operations.
@@ -493,17 +307,6 @@ again:
  *
  */
 
-struct vvp_io *cl2vvp_io(const struct lu_env *env,
-			 const struct cl_io_slice *slice)
-{
-	struct vvp_io *vio;
-
-	vio = container_of(slice, struct vvp_io, vui_cl);
-	LASSERT(vio == vvp_env_io(env));
-
-	return vio;
-}
-
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice)
 {
 	return container_of0(slice, struct ccc_req, crq_cl);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 9856bb6..86e93c0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -693,7 +693,6 @@ void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		 struct cl_page_list *queue, struct ll_readahead_state *ras,
 		 bool hit);
-int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
 struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage);
 void ll_cl_fini(struct ll_cl_context *lcc);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index e04f23e..7af8c44 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -164,12 +164,6 @@ struct vvp_io {
 	bool		vui_ra_valid;
 };
 
-/**
- * True, if \a io is a normal io, False for other splice_{read,write}.
- * must be implemented in arch specific code.
- */
-int cl_is_normalio(const struct lu_env *env, const struct cl_io *io);
-
 extern struct lu_context_key ccc_key;
 extern struct lu_context_key vvp_session_key;
 
@@ -334,19 +328,6 @@ void ccc_umount(const struct lu_env *env, struct cl_device *dev);
 int ccc_global_init(struct lu_device_type *device_type);
 void ccc_global_fini(struct lu_device_type *device_type);
 
-int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
-			  __u32 enqflags, enum cl_lock_mode mode,
-			  pgoff_t start, pgoff_t end);
-int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
-		    __u32 enqflags, enum cl_lock_mode mode,
-		    loff_t start, loff_t end);
-void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios);
-void vvp_io_advance(const struct lu_env *env, const struct cl_io_slice *ios,
-		    size_t nob);
-void vvp_io_update_iov(const struct lu_env *env, struct vvp_io *cio,
-		       struct cl_io *io);
-int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_io *io, loff_t start, size_t count, int *exceed);
 void ccc_req_completion(const struct lu_env *env,
 			const struct cl_req_slice *slice, int ioret);
 void ccc_req_attr_set(const struct lu_env *env,
@@ -397,8 +378,6 @@ static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
 	return container_of(slice, struct vvp_lock, vlk_cl);
 }
 
-struct vvp_io *cl2vvp_io(const struct lu_env *env,
-			 const struct cl_io_slice *slice);
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice);
 
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
@@ -447,6 +426,7 @@ void ccc_inode_lsm_put(struct inode *inode, struct lov_stripe_md *lsm);
 
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io);
+int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
 int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io);
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 53cf2be..48b0693 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -47,10 +47,21 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
+struct vvp_io *cl2vvp_io(const struct lu_env *env,
+			 const struct cl_io_slice *slice)
+{
+	struct vvp_io *vio;
+
+	vio = container_of(slice, struct vvp_io, vui_cl);
+	LASSERT(vio == vvp_env_io(env));
+
+	return vio;
+}
+
 /**
  * True, if \a io is a normal io, False for splice_{read,write}
  */
-int cl_is_normalio(const struct lu_env *env, const struct cl_io *io)
+static int cl_is_normalio(const struct lu_env *env, const struct cl_io *io)
 {
 	struct vvp_io *vio = vvp_env_io(env);
 
@@ -93,12 +104,160 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
+static void vvp_object_size_lock(struct cl_object *obj)
+{
+	struct inode *inode = vvp_object_inode(obj);
+
+	ll_inode_size_lock(inode);
+	cl_object_attr_lock(obj);
+}
+
+static void vvp_object_size_unlock(struct cl_object *obj)
+{
+	struct inode *inode = vvp_object_inode(obj);
+
+	cl_object_attr_unlock(obj);
+	ll_inode_size_unlock(inode);
+}
+
+/**
+ * Helper function that if necessary adjusts file size (inode->i_size), when
+ * position at the offset \a pos is accessed. File size can be arbitrary stale
+ * on a Lustre client, but client at least knows KMS. If accessed area is
+ * inside [0, KMS], set file size to KMS, otherwise glimpse file size.
+ *
+ * Locking: cl_isize_lock is used to serialize changes to inode size and to
+ * protect consistency between inode size and cl_object
+ * attributes. cl_object_size_lock() protects consistency between cl_attr's of
+ * top-object and sub-objects.
+ */
+static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_io *io, loff_t start, size_t count,
+			 int *exceed)
+{
+	struct cl_attr *attr  = ccc_env_thread_attr(env);
+	struct inode   *inode = vvp_object_inode(obj);
+	loff_t	  pos   = start + count - 1;
+	loff_t kms;
+	int result;
+
+	/*
+	 * Consistency guarantees: following possibilities exist for the
+	 * relation between region being accessed and real file size at this
+	 * moment:
+	 *
+	 *  (A): the region is completely inside of the file;
+	 *
+	 *  (B-x): x bytes of region are inside of the file, the rest is
+	 *  outside;
+	 *
+	 *  (C): the region is completely outside of the file.
+	 *
+	 * This classification is stable under DLM lock already acquired by
+	 * the caller, because to change the class, other client has to take
+	 * DLM lock conflicting with our lock. Also, any updates to ->i_size
+	 * by other threads on this client are serialized by
+	 * ll_inode_size_lock(). This guarantees that short reads are handled
+	 * correctly in the face of concurrent writes and truncates.
+	 */
+	vvp_object_size_lock(obj);
+	result = cl_object_attr_get(env, obj, attr);
+	if (result == 0) {
+		kms = attr->cat_kms;
+		if (pos > kms) {
+			/*
+			 * A glimpse is necessary to determine whether we
+			 * return a short read (B) or some zeroes at the end
+			 * of the buffer (C)
+			 */
+			vvp_object_size_unlock(obj);
+			result = cl_glimpse_lock(env, io, inode, obj, 0);
+			if (result == 0 && exceed) {
+				/* If objective page index exceed end-of-file
+				 * page index, return directly. Do not expect
+				 * kernel will check such case correctly.
+				 * linux-2.6.18-128.1.1 miss to do that.
+				 * --bug 17336
+				 */
+				loff_t size = i_size_read(inode);
+				loff_t cur_index = start >> PAGE_CACHE_SHIFT;
+				loff_t size_index = (size - 1) >>
+						    PAGE_CACHE_SHIFT;
+
+				if ((size == 0 && cur_index != 0) ||
+				    size_index < cur_index)
+					*exceed = 1;
+			}
+			return result;
+		}
+		/*
+		 * region is within kms and, hence, within real file
+		 * size (A). We need to increase i_size to cover the
+		 * read region so that generic_file_read() will do its
+		 * job, but that doesn't mean the kms size is
+		 * _correct_, it is only the _minimum_ size. If
+		 * someone does a stat they will get the correct size
+		 * which will always be >= the kms value here.
+		 * b=11081
+		 */
+		if (i_size_read(inode) < kms) {
+			i_size_write(inode, kms);
+			CDEBUG(D_VFSTRACE, DFID " updating i_size %llu\n",
+			       PFID(lu_object_fid(&obj->co_lu)),
+			       (__u64)i_size_read(inode));
+		}
+	}
+
+	vvp_object_size_unlock(obj);
+
+	return result;
+}
+
 /*****************************************************************************
  *
  * io operations.
  *
  */
 
+static int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
+				 __u32 enqflags, enum cl_lock_mode mode,
+			  pgoff_t start, pgoff_t end)
+{
+	struct vvp_io          *vio   = vvp_env_io(env);
+	struct cl_lock_descr   *descr = &vio->vui_link.cill_descr;
+	struct cl_object       *obj   = io->ci_obj;
+
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
+
+	CDEBUG(D_VFSTRACE, "lock: %d [%lu, %lu]\n", mode, start, end);
+
+	memset(&vio->vui_link, 0, sizeof(vio->vui_link));
+
+	if (vio->vui_fd && (vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
+		descr->cld_mode = CLM_GROUP;
+		descr->cld_gid  = vio->vui_fd->fd_grouplock.cg_gid;
+	} else {
+		descr->cld_mode  = mode;
+	}
+	descr->cld_obj   = obj;
+	descr->cld_start = start;
+	descr->cld_end   = end;
+	descr->cld_enq_flags = enqflags;
+
+	cl_io_lock_add(env, io, &vio->vui_link);
+	return 0;
+}
+
+static int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
+			   __u32 enqflags, enum cl_lock_mode mode,
+			   loff_t start, loff_t end)
+{
+	struct cl_object *obj = io->ci_obj;
+
+	return vvp_io_one_lock_index(env, io, enqflags, mode,
+				     cl_index(obj, start), cl_index(obj, end));
+}
+
 static int vvp_io_write_iter_init(const struct lu_env *env,
 				  const struct cl_io_slice *ios)
 {
@@ -303,6 +462,33 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	return result;
 }
 
+static void vvp_io_advance(const struct lu_env *env,
+			   const struct cl_io_slice *ios,
+			   size_t nob)
+{
+	struct vvp_io    *vio = cl2vvp_io(env, ios);
+	struct cl_io     *io  = ios->cis_io;
+	struct cl_object *obj = ios->cis_io->ci_obj;
+
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
+
+	if (!cl_is_normalio(env, io))
+		return;
+
+	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count  -= nob);
+}
+
+static void vvp_io_update_iov(const struct lu_env *env,
+			      struct vvp_io *vio, struct cl_io *io)
+{
+	size_t size = io->u.ci_rw.crw_count;
+
+	if (!cl_is_normalio(env, io) || !vio->vui_iter)
+		return;
+
+	iov_iter_truncate(vio->vui_iter, size);
+}
+
 static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
 			  enum cl_lock_mode mode, loff_t start, loff_t end)
 {
@@ -514,7 +700,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	if (!can_populate_pages(env, io, inode))
 		return 0;
 
-	result = ccc_prep_size(env, obj, io, pos, tot, &exceed);
+	result = vvp_prep_size(env, obj, io, pos, tot, &exceed);
 	if (result != 0)
 		return result;
 	else if (exceed != 0)
@@ -886,7 +1072,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	/* offset of the last byte on the page */
 	offset = cl_offset(obj, fio->ft_index + 1) - 1;
 	LASSERT(cl_index(obj, offset) == fio->ft_index);
-	result = ccc_prep_size(env, obj, io, 0, offset + 1, NULL);
+	result = vvp_prep_size(env, obj, io, 0, offset + 1, NULL);
 	if (result != 0)
 		return result;
 
@@ -1075,6 +1261,12 @@ static int vvp_io_read_page(const struct lu_env *env,
 	return 0;
 }
 
+void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
+{
+	CLOBINVRNT(env, ios->cis_io->ci_obj,
+		   vvp_object_invariant(ios->cis_io->ci_obj));
+}
+
 static const struct cl_io_operations vvp_io_ops = {
 	.op = {
 		[CIT_READ] = {
-- 
2.1.0
