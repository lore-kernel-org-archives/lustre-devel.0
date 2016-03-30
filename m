From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:02 -0400
Subject: [lustre-devel] [PATCH 30/43] staging/lustre/llite: merge ccc_io and
	vvp_io
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-31-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Move the contents of struct vvp_io into struct ccc_io, delete the
former, and rename the latter to struct vvp_io. Rename various ccc_io
related functions to use vvp rather than ccc.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13351
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  13 ++-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  60 +++---------
 .../staging/lustre/lustre/llite/llite_internal.h   |  72 ---------------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  12 +--
 drivers/staging/lustre/lustre/llite/rw.c           |   4 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  10 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  81 +++++++++++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       | 101 ++++++++++-----------
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   2 +-
 11 files changed, 144 insertions(+), 215 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index d509f94..104dc9f 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1461,7 +1461,7 @@ enum cl_io_state {
  * This is usually embedded into layer session data, rather than allocated
  * dynamically.
  *
- * \see vvp_io, lov_io, osc_io, ccc_io
+ * \see vvp_io, lov_io, osc_io
  */
 struct cl_io_slice {
 	struct cl_io		  *cis_io;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index bf2a5ee..27e7e65 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1135,14 +1135,13 @@ restart:
 	ll_io_init(io, file, iot == CIT_WRITE);
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
-		struct vvp_io *vio = vvp_env_io(env);
-		struct ccc_io *cio = ccc_env_io(env);
+		struct vvp_io *cio = vvp_env_io(env);
 		int write_mutex_locked = 0;
 
 		cio->cui_fd  = LUSTRE_FPRIVATE(file);
-		vio->cui_io_subtype = args->via_io_subtype;
+		cio->cui_io_subtype = args->via_io_subtype;
 
-		switch (vio->cui_io_subtype) {
+		switch (cio->cui_io_subtype) {
 		case IO_NORMAL:
 			cio->cui_iter = args->u.normal.via_iter;
 			cio->cui_iocb = args->u.normal.via_iocb;
@@ -1158,11 +1157,11 @@ restart:
 			down_read(&lli->lli_trunc_sem);
 			break;
 		case IO_SPLICE:
-			vio->u.splice.cui_pipe = args->u.splice.via_pipe;
-			vio->u.splice.cui_flags = args->u.splice.via_flags;
+			cio->u.splice.cui_pipe = args->u.splice.via_pipe;
+			cio->u.splice.cui_flags = args->u.splice.via_flags;
 			break;
 		default:
-			CERROR("Unknown IO type - %u\n", vio->cui_io_subtype);
+			CERROR("Unknown IO type - %u\n", cio->cui_io_subtype);
 			LBUG();
 		}
 		result = cl_io_loop(env, io);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 8884317..9a9d706 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -68,7 +68,6 @@ static const struct cl_req_operations ccc_req_ops;
  */
 
 static struct kmem_cache *ccc_thread_kmem;
-static struct kmem_cache *ccc_session_kmem;
 static struct kmem_cache *ccc_req_kmem;
 
 static struct lu_kmem_descr ccc_caches[] = {
@@ -78,11 +77,6 @@ static struct lu_kmem_descr ccc_caches[] = {
 		.ckd_size  = sizeof(struct ccc_thread_info),
 	},
 	{
-		.ckd_cache = &ccc_session_kmem,
-		.ckd_name  = "ccc_session_kmem",
-		.ckd_size  = sizeof(struct ccc_session)
-	},
-	{
 		.ckd_cache = &ccc_req_kmem,
 		.ckd_name  = "ccc_req_kmem",
 		.ckd_size  = sizeof(struct ccc_req)
@@ -116,37 +110,12 @@ void ccc_key_fini(const struct lu_context *ctx,
 	kmem_cache_free(ccc_thread_kmem, info);
 }
 
-void *ccc_session_key_init(const struct lu_context *ctx,
-			   struct lu_context_key *key)
-{
-	struct ccc_session *session;
-
-	session = kmem_cache_zalloc(ccc_session_kmem, GFP_NOFS);
-	if (!session)
-		session = ERR_PTR(-ENOMEM);
-	return session;
-}
-
-void ccc_session_key_fini(const struct lu_context *ctx,
-			  struct lu_context_key *key, void *data)
-{
-	struct ccc_session *session = data;
-
-	kmem_cache_free(ccc_session_kmem, session);
-}
-
 struct lu_context_key ccc_key = {
 	.lct_tags = LCT_CL_THREAD,
 	.lct_init = ccc_key_init,
 	.lct_fini = ccc_key_fini
 };
 
-struct lu_context_key ccc_session_key = {
-	.lct_tags = LCT_SESSION,
-	.lct_init = ccc_session_key_init,
-	.lct_fini = ccc_session_key_fini
-};
-
 int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
 		 struct cl_req *req)
 {
@@ -237,11 +206,11 @@ static void vvp_object_size_unlock(struct cl_object *obj)
  *
  */
 
-int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
+int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end)
 {
-	struct ccc_io	  *cio   = ccc_env_io(env);
+	struct vvp_io *cio = vvp_env_io(env);
 	struct cl_lock_descr   *descr = &cio->cui_link.cill_descr;
 	struct cl_object       *obj   = io->ci_obj;
 
@@ -266,8 +235,8 @@ int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 	return 0;
 }
 
-void ccc_io_update_iov(const struct lu_env *env,
-		       struct ccc_io *cio, struct cl_io *io)
+void vvp_io_update_iov(const struct lu_env *env,
+		       struct vvp_io *cio, struct cl_io *io)
 {
 	size_t size = io->u.ci_rw.crw_count;
 
@@ -277,27 +246,27 @@ void ccc_io_update_iov(const struct lu_env *env,
 	iov_iter_truncate(cio->cui_iter, size);
 }
 
-int ccc_io_one_lock(const struct lu_env *env, struct cl_io *io,
+int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
 		    __u32 enqflags, enum cl_lock_mode mode,
 		    loff_t start, loff_t end)
 {
 	struct cl_object *obj = io->ci_obj;
 
-	return ccc_io_one_lock_index(env, io, enqflags, mode,
+	return vvp_io_one_lock_index(env, io, enqflags, mode,
 				     cl_index(obj, start), cl_index(obj, end));
 }
 
-void ccc_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
+void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	CLOBINVRNT(env, ios->cis_io->ci_obj,
 		   vvp_object_invariant(ios->cis_io->ci_obj));
 }
 
-void ccc_io_advance(const struct lu_env *env,
+void vvp_io_advance(const struct lu_env *env,
 		    const struct cl_io_slice *ios,
 		    size_t nob)
 {
-	struct ccc_io    *cio = cl2ccc_io(env, ios);
+	struct vvp_io    *cio = cl2vvp_io(env, ios);
 	struct cl_io     *io  = ios->cis_io;
 	struct cl_object *obj = ios->cis_io->ci_obj;
 
@@ -492,7 +461,7 @@ int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 
 again:
 	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0) {
-		struct ccc_io *cio = ccc_env_io(env);
+		struct vvp_io *cio = vvp_env_io(env);
 
 		if (attr->ia_valid & ATTR_FILE)
 			/* populate the file descriptor for ftruncate to honor
@@ -524,13 +493,14 @@ again:
  *
  */
 
-struct ccc_io *cl2ccc_io(const struct lu_env *env,
+struct vvp_io *cl2vvp_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice)
 {
-	struct ccc_io *cio;
+	struct vvp_io *cio;
+
+	cio = container_of(slice, struct vvp_io, cui_cl);
+	LASSERT(cio == vvp_env_io(env));
 
-	cio = container_of(slice, struct ccc_io, cui_cl);
-	LASSERT(cio == ccc_env_io(env));
 	return cio;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 9dd4325..9856bb6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -817,59 +817,6 @@ struct ll_close_queue {
 void vvp_write_pending(struct vvp_object *club, struct vvp_page *page);
 void vvp_write_complete(struct vvp_object *club, struct vvp_page *page);
 
-/* specific architecture can implement only part of this list */
-enum vvp_io_subtype {
-	/** normal IO */
-	IO_NORMAL,
-	/** io started from splice_{read|write} */
-	IO_SPLICE
-};
-
-/* IO subtypes */
-struct vvp_io {
-	/** io subtype */
-	enum vvp_io_subtype    cui_io_subtype;
-
-	union {
-		struct {
-			struct pipe_inode_info *cui_pipe;
-			unsigned int	    cui_flags;
-		} splice;
-		struct vvp_fault_io {
-			/**
-			 * Inode modification time that is checked across DLM
-			 * lock request.
-			 */
-			time64_t	    ft_mtime;
-			struct vm_area_struct *ft_vma;
-			/**
-			 *  locked page returned from vvp_io
-			 */
-			struct page	    *ft_vmpage;
-			struct vm_fault_api {
-				/**
-				 * kernel fault info
-				 */
-				struct vm_fault *ft_vmf;
-				/**
-				 * fault API used bitflags for return code.
-				 */
-				unsigned int    ft_flags;
-				/**
-				 * check that flags are from filemap_fault
-				 */
-				bool		ft_flags_valid;
-			} fault;
-		} fault;
-	} u;
-
-	/* Readahead state. */
-	pgoff_t	cui_ra_start;
-	pgoff_t cui_ra_count;
-	/* Set when cui_ra_{start,count} have been initialized. */
-	bool	cui_ra_valid;
-};
-
 /**
  * IO arguments for various VFS I/O interfaces.
  */
@@ -923,25 +870,6 @@ static inline struct vvp_io_args *vvp_env_args(const struct lu_env *env,
 	return ret;
 }
 
-struct vvp_session {
-	struct vvp_io	 vs_ios;
-};
-
-static inline struct vvp_session *vvp_env_session(const struct lu_env *env)
-{
-	extern struct lu_context_key vvp_session_key;
-	struct vvp_session *ses;
-
-	ses = lu_context_key_get(env->le_ses, &vvp_session_key);
-	LASSERT(ses);
-	return ses;
-}
-
-static inline struct vvp_io *vvp_env_io(const struct lu_env *env)
-{
-	return &vvp_env_session(env)->vs_ios;
-}
-
 int vvp_global_init(void);
 void vvp_global_fini(void);
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 1263da8..7c214f8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -146,7 +146,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 
 	rc = cl_io_init(env, io, CIT_FAULT, io->ci_obj);
 	if (rc == 0) {
-		struct ccc_io *cio = ccc_env_io(env);
+		struct vvp_io *cio = vvp_env_io(env);
 		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 
 		LASSERT(cio->cui_cl.cis_io == io);
@@ -307,17 +307,17 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
 		vio = vvp_env_io(env);
 		vio->u.fault.ft_vma       = vma;
 		vio->u.fault.ft_vmpage    = NULL;
-		vio->u.fault.fault.ft_vmf = vmf;
-		vio->u.fault.fault.ft_flags = 0;
-		vio->u.fault.fault.ft_flags_valid = false;
+		vio->u.fault.ft_vmf = vmf;
+		vio->u.fault.ft_flags = 0;
+		vio->u.fault.ft_flags_valid = false;
 
 		result = cl_io_loop(env, io);
 
 		/* ft_flags are only valid if we reached
 		 * the call to filemap_fault
 		 */
-		if (vio->u.fault.fault.ft_flags_valid)
-			fault_ret = vio->u.fault.fault.ft_flags;
+		if (vio->u.fault.ft_flags_valid)
+			fault_ret = vio->u.fault.ft_flags;
 
 		vmpage = vio->u.fault.ft_vmpage;
 		if (result != 0 && vmpage) {
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index f06d8be..da44107 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -90,7 +90,7 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 	struct lu_env    *env;
 	struct cl_io     *io;
 	struct cl_object *clob;
-	struct ccc_io    *cio;
+	struct vvp_io    *cio;
 
 	int refcheck;
 	int result = 0;
@@ -108,7 +108,7 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 	lcc->lcc_refcheck = refcheck;
 	lcc->lcc_cookie = current;
 
-	cio = ccc_env_io(env);
+	cio = vvp_env_io(env);
 	io = cio->cui_cl.cis_io;
 	lcc->lcc_io = io;
 	if (!io) {
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index bb85629..2f69634 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -376,7 +376,7 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 
 	env = cl_env_get(&refcheck);
 	LASSERT(!IS_ERR(env));
-	io = ccc_env_io(env)->cui_cl.cis_io;
+	io = vvp_env_io(env)->cui_cl.cis_io;
 	LASSERT(io);
 
 	/* 0. Need locking between buffered and direct access. and race with
@@ -439,7 +439,7 @@ out:
 		inode_unlock(inode);
 
 	if (tot_bytes > 0) {
-		struct ccc_io *cio = ccc_env_io(env);
+		struct vvp_io *cio = vvp_env_io(env);
 
 		/* no commit async for direct IO */
 		cio->u.write.cui_written += tot_bytes;
@@ -513,7 +513,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	/* To avoid deadlock, try to lock page first. */
 	vmpage = grab_cache_page_nowait(mapping, index);
 	if (unlikely(!vmpage || PageDirty(vmpage) || PageWriteback(vmpage))) {
-		struct ccc_io *cio = ccc_env_io(env);
+		struct vvp_io *cio = vvp_env_io(env);
 		struct cl_page_list *plist = &cio->u.write.cui_queue;
 
 		/* if the page is already in dirty cache, we have to commit
@@ -595,7 +595,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	struct ll_cl_context *lcc = fsdata;
 	struct lu_env *env;
 	struct cl_io *io;
-	struct ccc_io *cio;
+	struct vvp_io *cio;
 	struct cl_page *page;
 	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
 	bool unplug = false;
@@ -606,7 +606,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 	env  = lcc->lcc_env;
 	page = lcc->lcc_page;
 	io   = lcc->lcc_io;
-	cio  = ccc_env_io(env);
+	cio  = vvp_env_io(env);
 
 	LASSERT(cl_page_is_owned(page, io));
 	if (copied > 0) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 4b77db3..030a246 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -138,7 +138,7 @@ struct lu_context_key vvp_session_key = {
 };
 
 /* type constructor/destructor: vvp_type_{init,fini,start,stop}(). */
-LU_TYPE_INIT_FINI(vvp, &ccc_key, &ccc_session_key, &vvp_key, &vvp_session_key);
+LU_TYPE_INIT_FINI(vvp, &ccc_key, &vvp_key, &vvp_session_key);
 
 static const struct lu_device_operations vvp_lu_ops = {
 	.ldo_object_alloc      = vvp_object_alloc
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 403d2a7..443485c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -81,10 +81,18 @@ enum ccc_setattr_lock_type {
 	SETATTR_MATCH_LOCK
 };
 
+/* specific architecture can implement only part of this list */
+enum vvp_io_subtype {
+	/** normal IO */
+	IO_NORMAL,
+	/** io started from splice_{read|write} */
+	IO_SPLICE
+};
+
 /**
- * IO state private to vvp or slp layers.
+ * IO state private to IO state private to VVP layer.
  */
-struct ccc_io {
+struct vvp_io {
 	/** super class */
 	struct cl_io_slice     cui_cl;
 	struct cl_io_lock_link cui_link;
@@ -98,16 +106,47 @@ struct ccc_io {
 	size_t cui_tot_count;
 
 	union {
+		struct vvp_fault_io {
+			/**
+			 * Inode modification time that is checked across DLM
+			 * lock request.
+			 */
+			time64_t	    ft_mtime;
+			struct vm_area_struct *ft_vma;
+			/**
+			 *  locked page returned from vvp_io
+			 */
+			struct page	    *ft_vmpage;
+			/**
+			 * kernel fault info
+			 */
+			struct vm_fault *ft_vmf;
+			/**
+			 * fault API used bitflags for return code.
+			 */
+			unsigned int    ft_flags;
+			/**
+			 * check that flags are from filemap_fault
+			 */
+			bool		ft_flags_valid;
+		} fault;
 		struct {
 			enum ccc_setattr_lock_type cui_local_lock;
 		} setattr;
 		struct {
+			struct pipe_inode_info	*cui_pipe;
+			unsigned int		 cui_flags;
+		} splice;
+		struct {
 			struct cl_page_list cui_queue;
 			unsigned long cui_written;
 			int cui_from;
 			int cui_to;
 		} write;
 	} u;
+
+	enum vvp_io_subtype	cui_io_subtype;
+
 	/**
 	 * Layout version when this IO is initialized
 	 */
@@ -117,6 +156,12 @@ struct ccc_io {
 	 */
 	struct ll_file_data *cui_fd;
 	struct kiocb *cui_iocb;
+
+	/* Readahead state. */
+	pgoff_t	cui_ra_start;
+	pgoff_t	cui_ra_count;
+	/* Set when cui_ra_{start,count} have been initialized. */
+	bool		cui_ra_valid;
 };
 
 /**
@@ -126,7 +171,7 @@ struct ccc_io {
 int cl_is_normalio(const struct lu_env *env, const struct cl_io *io);
 
 extern struct lu_context_key ccc_key;
-extern struct lu_context_key ccc_session_key;
+extern struct lu_context_key vvp_session_key;
 
 extern struct kmem_cache *vvp_lock_kmem;
 extern struct kmem_cache *vvp_object_kmem;
@@ -174,23 +219,23 @@ static inline struct cl_io *ccc_env_thread_io(const struct lu_env *env)
 	return io;
 }
 
-struct ccc_session {
-	struct ccc_io cs_ios;
+struct vvp_session {
+	struct vvp_io cs_ios;
 };
 
-static inline struct ccc_session *ccc_env_session(const struct lu_env *env)
+static inline struct vvp_session *vvp_env_session(const struct lu_env *env)
 {
-	struct ccc_session *ses;
+	struct vvp_session *ses;
 
-	ses = lu_context_key_get(env->le_ses, &ccc_session_key);
+	ses = lu_context_key_get(env->le_ses, &vvp_session_key);
 	LASSERT(ses);
 
 	return ses;
 }
 
-static inline struct ccc_io *ccc_env_io(const struct lu_env *env)
+static inline struct vvp_io *vvp_env_io(const struct lu_env *env)
 {
-	return &ccc_env_session(env)->cs_ios;
+	return &vvp_env_session(env)->cs_ios;
 }
 
 /**
@@ -282,10 +327,6 @@ void *ccc_key_init(const struct lu_context *ctx,
 		   struct lu_context_key *key);
 void ccc_key_fini(const struct lu_context *ctx,
 		  struct lu_context_key *key, void *data);
-void *ccc_session_key_init(const struct lu_context *ctx,
-			   struct lu_context_key *key);
-void  ccc_session_key_fini(const struct lu_context *ctx,
-			   struct lu_context_key *key, void *data);
 
 int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
 		 struct cl_req *req);
@@ -293,16 +334,16 @@ void ccc_umount(const struct lu_env *env, struct cl_device *dev);
 int ccc_global_init(struct lu_device_type *device_type);
 void ccc_global_fini(struct lu_device_type *device_type);
 
-int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
+int vvp_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
 			  pgoff_t start, pgoff_t end);
-int ccc_io_one_lock(const struct lu_env *env, struct cl_io *io,
+int vvp_io_one_lock(const struct lu_env *env, struct cl_io *io,
 		    __u32 enqflags, enum cl_lock_mode mode,
 		    loff_t start, loff_t end);
-void ccc_io_end(const struct lu_env *env, const struct cl_io_slice *ios);
-void ccc_io_advance(const struct lu_env *env, const struct cl_io_slice *ios,
+void vvp_io_end(const struct lu_env *env, const struct cl_io_slice *ios);
+void vvp_io_advance(const struct lu_env *env, const struct cl_io_slice *ios,
 		    size_t nob);
-void ccc_io_update_iov(const struct lu_env *env, struct ccc_io *cio,
+void vvp_io_update_iov(const struct lu_env *env, struct vvp_io *cio,
 		       struct cl_io *io);
 int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_io *io, loff_t start, size_t count, int *exceed);
@@ -356,7 +397,7 @@ static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
 	return container_of(slice, struct vvp_lock, vlk_cl);
 }
 
-struct ccc_io *cl2ccc_io(const struct lu_env *env,
+struct vvp_io *cl2vvp_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice);
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 86e73d5..1059c63 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -47,9 +47,6 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
-static struct vvp_io *cl2vvp_io(const struct lu_env *env,
-				const struct cl_io_slice *slice);
-
 /**
  * True, if \a io is a normal io, False for splice_{read,write}
  */
@@ -72,7 +69,7 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 			       struct inode *inode)
 {
 	struct ll_inode_info	*lli = ll_i2info(inode);
-	struct ccc_io		*cio = ccc_env_io(env);
+	struct vvp_io		*cio = vvp_env_io(env);
 	bool rc = true;
 
 	switch (io->ci_type) {
@@ -105,7 +102,7 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 static int vvp_io_write_iter_init(const struct lu_env *env,
 				  const struct cl_io_slice *ios)
 {
-	struct ccc_io *cio = cl2ccc_io(env, ios);
+	struct vvp_io *cio = cl2vvp_io(env, ios);
 
 	cl_page_list_init(&cio->u.write.cui_queue);
 	cio->u.write.cui_written = 0;
@@ -118,7 +115,7 @@ static int vvp_io_write_iter_init(const struct lu_env *env,
 static void vvp_io_write_iter_fini(const struct lu_env *env,
 				   const struct cl_io_slice *ios)
 {
-	struct ccc_io *cio = cl2ccc_io(env, ios);
+	struct vvp_io *cio = cl2vvp_io(env, ios);
 
 	LASSERT(cio->u.write.cui_queue.pl_nr == 0);
 }
@@ -129,8 +126,7 @@ static int vvp_io_fault_iter_init(const struct lu_env *env,
 	struct vvp_io *vio   = cl2vvp_io(env, ios);
 	struct inode  *inode = vvp_object_inode(ios->cis_obj);
 
-	LASSERT(inode ==
-		file_inode(cl2ccc_io(env, ios)->cui_fd->fd_file));
+	LASSERT(inode == file_inode(vio->cui_fd->fd_file));
 	vio->u.fault.ft_mtime = inode->i_mtime.tv_sec;
 	return 0;
 }
@@ -139,7 +135,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	struct cl_io     *io  = ios->cis_io;
 	struct cl_object *obj = io->ci_obj;
-	struct ccc_io    *cio = cl2ccc_io(env, ios);
+	struct vvp_io    *cio = cl2vvp_io(env, ios);
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -225,7 +221,7 @@ static enum cl_lock_mode vvp_mode_from_vma(struct vm_area_struct *vma)
 }
 
 static int vvp_mmap_locks(const struct lu_env *env,
-			  struct ccc_io *vio, struct cl_io *io)
+			  struct vvp_io *vio, struct cl_io *io)
 {
 	struct ccc_thread_info *cti = ccc_env_info(env);
 	struct mm_struct       *mm = current->mm;
@@ -310,19 +306,19 @@ static int vvp_mmap_locks(const struct lu_env *env,
 static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
 			  enum cl_lock_mode mode, loff_t start, loff_t end)
 {
-	struct ccc_io *cio = ccc_env_io(env);
+	struct vvp_io *cio = vvp_env_io(env);
 	int result;
 	int ast_flags = 0;
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
-	ccc_io_update_iov(env, cio, io);
+	vvp_io_update_iov(env, cio, io);
 
 	if (io->u.ci_rw.crw_nonblock)
 		ast_flags |= CEF_NONBLOCK;
 	result = vvp_mmap_locks(env, cio, io);
 	if (result == 0)
-		result = ccc_io_one_lock(env, io, ast_flags, mode, start, end);
+		result = vvp_io_one_lock(env, io, ast_flags, mode, start, end);
 	return result;
 }
 
@@ -347,9 +343,11 @@ static int vvp_io_fault_lock(const struct lu_env *env,
 	/*
 	 * XXX LDLM_FL_CBPENDING
 	 */
-	return ccc_io_one_lock_index
-		(env, io, 0, vvp_mode_from_vma(vio->u.fault.ft_vma),
-		 io->u.ci_fault.ft_index, io->u.ci_fault.ft_index);
+	return vvp_io_one_lock_index(env,
+				     io, 0,
+				     vvp_mode_from_vma(vio->u.fault.ft_vma),
+				     io->u.ci_fault.ft_index,
+				     io->u.ci_fault.ft_index);
 }
 
 static int vvp_io_write_lock(const struct lu_env *env,
@@ -383,7 +381,7 @@ static int vvp_io_setattr_iter_init(const struct lu_env *env,
 static int vvp_io_setattr_lock(const struct lu_env *env,
 			       const struct cl_io_slice *ios)
 {
-	struct ccc_io *cio = ccc_env_io(env);
+	struct vvp_io *cio = vvp_env_io(env);
 	struct cl_io  *io  = ios->cis_io;
 	__u64 new_size;
 	__u32 enqflags = 0;
@@ -401,7 +399,8 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 		new_size = 0;
 	}
 	cio->u.setattr.cui_local_lock = SETATTR_EXTENT_LOCK;
-	return ccc_io_one_lock(env, io, enqflags, CLM_WRITE,
+
+	return vvp_io_one_lock(env, io, enqflags, CLM_WRITE,
 			       new_size, OBD_OBJECT_EOF);
 }
 
@@ -496,16 +495,15 @@ static int vvp_io_read_start(const struct lu_env *env,
 			     const struct cl_io_slice *ios)
 {
 	struct vvp_io     *vio   = cl2vvp_io(env, ios);
-	struct ccc_io     *cio   = cl2ccc_io(env, ios);
 	struct cl_io      *io    = ios->cis_io;
 	struct cl_object  *obj   = io->ci_obj;
 	struct inode      *inode = vvp_object_inode(obj);
-	struct file       *file  = cio->cui_fd->fd_file;
+	struct file       *file  = vio->cui_fd->fd_file;
 
 	int     result;
 	loff_t  pos = io->u.ci_rd.rd.crw_pos;
 	long    cnt = io->u.ci_rd.rd.crw_count;
-	long    tot = cio->cui_tot_count;
+	long    tot = vio->cui_tot_count;
 	int     exceed = 0;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
@@ -526,7 +524,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 			 inode->i_ino, cnt, pos, i_size_read(inode));
 
 	/* turn off the kernel's read-ahead */
-	cio->cui_fd->fd_file->f_ra.ra_pages = 0;
+	vio->cui_fd->fd_file->f_ra.ra_pages = 0;
 
 	/* initialize read-ahead window once per syscall */
 	if (!vio->cui_ra_valid) {
@@ -540,8 +538,8 @@ static int vvp_io_read_start(const struct lu_env *env,
 	file_accessed(file);
 	switch (vio->cui_io_subtype) {
 	case IO_NORMAL:
-		LASSERT(cio->cui_iocb->ki_pos == pos);
-		result = generic_file_read_iter(cio->cui_iocb, cio->cui_iter);
+		LASSERT(vio->cui_iocb->ki_pos == pos);
+		result = generic_file_read_iter(vio->cui_iocb, vio->cui_iter);
 		break;
 	case IO_SPLICE:
 		result = generic_file_splice_read(file, &pos,
@@ -564,7 +562,7 @@ out:
 			io->ci_continue = 0;
 		io->ci_nob += result;
 		ll_rw_stats_tally(ll_i2sbi(inode), current->pid,
-				  cio->cui_fd, pos, result, READ);
+				  vio->cui_fd, pos, result, READ);
 		result = 0;
 	}
 	return result;
@@ -676,7 +674,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 {
 	struct cl_object *obj = io->ci_obj;
 	struct inode *inode = vvp_object_inode(obj);
-	struct ccc_io *cio = ccc_env_io(env);
+	struct vvp_io *cio = vvp_env_io(env);
 	struct cl_page_list *queue = &cio->u.write.cui_queue;
 	struct cl_page *page;
 	int rc = 0;
@@ -755,7 +753,7 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 static int vvp_io_write_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
-	struct ccc_io      *cio   = cl2ccc_io(env, ios);
+	struct vvp_io      *cio   = cl2vvp_io(env, ios);
 	struct cl_io       *io    = ios->cis_io;
 	struct cl_object   *obj   = io->ci_obj;
 	struct inode       *inode = vvp_object_inode(obj);
@@ -813,10 +811,10 @@ static int vvp_io_write_start(const struct lu_env *env,
 
 static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 {
-	struct vm_fault *vmf = cfio->fault.ft_vmf;
+	struct vm_fault *vmf = cfio->ft_vmf;
 
-	cfio->fault.ft_flags = filemap_fault(cfio->ft_vma, vmf);
-	cfio->fault.ft_flags_valid = 1;
+	cfio->ft_flags = filemap_fault(cfio->ft_vma, vmf);
+	cfio->ft_flags_valid = 1;
 
 	if (vmf->page) {
 		CDEBUG(D_PAGE,
@@ -824,29 +822,29 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 		       vmf->page, vmf->page->mapping, vmf->page->index,
 		       (long)vmf->page->flags, page_count(vmf->page),
 		       page_private(vmf->page), vmf->virtual_address);
-		if (unlikely(!(cfio->fault.ft_flags & VM_FAULT_LOCKED))) {
+		if (unlikely(!(cfio->ft_flags & VM_FAULT_LOCKED))) {
 			lock_page(vmf->page);
-			cfio->fault.ft_flags |= VM_FAULT_LOCKED;
+			cfio->ft_flags |= VM_FAULT_LOCKED;
 		}
 
 		cfio->ft_vmpage = vmf->page;
 		return 0;
 	}
 
-	if (cfio->fault.ft_flags & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV)) {
+	if (cfio->ft_flags & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV)) {
 		CDEBUG(D_PAGE, "got addr %p - SIGBUS\n", vmf->virtual_address);
 		return -EFAULT;
 	}
 
-	if (cfio->fault.ft_flags & VM_FAULT_OOM) {
+	if (cfio->ft_flags & VM_FAULT_OOM) {
 		CDEBUG(D_PAGE, "got addr %p - OOM\n", vmf->virtual_address);
 		return -ENOMEM;
 	}
 
-	if (cfio->fault.ft_flags & VM_FAULT_RETRY)
+	if (cfio->ft_flags & VM_FAULT_RETRY)
 		return -EAGAIN;
 
-	CERROR("Unknown error in page fault %d!\n", cfio->fault.ft_flags);
+	CERROR("Unknown error in page fault %d!\n", cfio->ft_flags);
 	return -EINVAL;
 }
 
@@ -1024,7 +1022,9 @@ out:
 	/* return unlocked vmpage to avoid deadlocking */
 	if (vmpage)
 		unlock_page(vmpage);
-	cfio->fault.ft_flags &= ~VM_FAULT_LOCKED;
+
+	cfio->ft_flags &= ~VM_FAULT_LOCKED;
+
 	return result;
 }
 
@@ -1047,7 +1047,7 @@ static int vvp_io_read_page(const struct lu_env *env,
 	struct cl_page	    *page   = slice->cpl_page;
 	struct inode              *inode  = vvp_object_inode(slice->cpl_obj);
 	struct ll_sb_info	 *sbi    = ll_i2sbi(inode);
-	struct ll_file_data       *fd     = cl2ccc_io(env, ios)->cui_fd;
+	struct ll_file_data       *fd     = cl2vvp_io(env, ios)->cui_fd;
 	struct ll_readahead_state *ras    = &fd->fd_ras;
 	struct cl_2queue	  *queue  = &io->ci_queue;
 
@@ -1080,7 +1080,7 @@ static const struct cl_io_operations vvp_io_ops = {
 			.cio_fini	= vvp_io_fini,
 			.cio_lock      = vvp_io_read_lock,
 			.cio_start     = vvp_io_read_start,
-			.cio_advance	= ccc_io_advance,
+			.cio_advance	= vvp_io_advance,
 		},
 		[CIT_WRITE] = {
 			.cio_fini      = vvp_io_fini,
@@ -1088,7 +1088,7 @@ static const struct cl_io_operations vvp_io_ops = {
 			.cio_iter_fini = vvp_io_write_iter_fini,
 			.cio_lock      = vvp_io_write_lock,
 			.cio_start     = vvp_io_write_start,
-			.cio_advance   = ccc_io_advance
+			.cio_advance   = vvp_io_advance,
 		},
 		[CIT_SETATTR] = {
 			.cio_fini       = vvp_io_setattr_fini,
@@ -1102,7 +1102,7 @@ static const struct cl_io_operations vvp_io_ops = {
 			.cio_iter_init = vvp_io_fault_iter_init,
 			.cio_lock      = vvp_io_fault_lock,
 			.cio_start     = vvp_io_fault_start,
-			.cio_end       = ccc_io_end
+			.cio_end       = vvp_io_end,
 		},
 		[CIT_FSYNC] = {
 			.cio_start  = vvp_io_fsync_start,
@@ -1119,7 +1119,6 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io)
 {
 	struct vvp_io      *vio   = vvp_env_io(env);
-	struct ccc_io      *cio   = ccc_env_io(env);
 	struct inode       *inode = vvp_object_inode(obj);
 	int		 result;
 
@@ -1129,10 +1128,10 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 	       " ignore/verify layout %d/%d, layout version %d restore needed %d\n",
 	       PFID(lu_object_fid(&obj->co_lu)),
 	       io->ci_ignore_layout, io->ci_verify_layout,
-	       cio->cui_layout_gen, io->ci_restore_needed);
+	       vio->cui_layout_gen, io->ci_restore_needed);
 
-	CL_IO_SLICE_CLEAN(cio, cui_cl);
-	cl_io_slice_add(io, &cio->cui_cl, obj, &vvp_io_ops);
+	CL_IO_SLICE_CLEAN(vio, cui_cl);
+	cl_io_slice_add(io, &vio->cui_cl, obj, &vvp_io_ops);
 	vio->cui_ra_valid = false;
 	result = 0;
 	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE) {
@@ -1146,7 +1145,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		if (count == 0)
 			result = 1;
 		else
-			cio->cui_tot_count = count;
+			vio->cui_tot_count = count;
 
 		/* for read/write, we store the jobid in the inode, and
 		 * it'll be fetched by osc when building RPC.
@@ -1172,7 +1171,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 	 * because it might not grant layout lock in IT_OPEN.
 	 */
 	if (result == 0 && !io->ci_ignore_layout) {
-		result = ll_layout_refresh(inode, &cio->cui_layout_gen);
+		result = ll_layout_refresh(inode, &vio->cui_layout_gen);
 		if (result == -ENOENT)
 			/* If the inode on MDS has been removed, but the objects
 			 * on OSTs haven't been destroyed (async unlink), layout
@@ -1188,11 +1187,3 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 
 	return result;
 }
-
-static struct vvp_io *cl2vvp_io(const struct lu_env *env,
-				const struct cl_io_slice *slice)
-{
-	/* Calling just for assertion */
-	cl2ccc_io(env, slice);
-	return vvp_env_io(env);
-}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 5ebbe27..4f7dfe2 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -372,7 +372,7 @@ static int vvp_page_is_under_lock(const struct lu_env *env,
 {
 	if (io->ci_type == CIT_READ || io->ci_type == CIT_WRITE ||
 	    io->ci_type == CIT_FAULT) {
-		struct ccc_io *cio = ccc_env_io(env);
+		struct vvp_io *cio = vvp_env_io(env);
 
 		if (unlikely(cio->cui_fd->fd_flags & LL_FILE_GROUP_LOCKED))
 			*max_index = CL_PAGE_EOF;
-- 
2.1.0
