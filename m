From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:08 -0400
Subject: [lustre-devel] [PATCH 36/43] staging/lustre/llite: rename struct
	ccc_thread_info to vvp_thread_info
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-37-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, John Hammond <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: John Hammond <john.hammond@intel.com>

struct ccc_thread_info is used in the VVP parts of llite so rename
it struct vvp_thread_info. Rename supporting functions accordingly.
Move init code from lcommon_cl.c to vvp_dev.c

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/13714
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c         |  6 +--
 drivers/staging/lustre/lustre/llite/glimpse.c      |  6 +--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 48 +---------------------
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  4 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  2 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  4 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 34 ++++++++++++++-
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 34 +++++++--------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  8 ++--
 10 files changed, 68 insertions(+), 80 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index f7aabac..69b56a8 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -998,7 +998,7 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object *obj = lli->lli_clob;
-	struct cl_attr *attr = ccc_env_thread_attr(env);
+	struct cl_attr *attr = vvp_env_thread_attr(env);
 	s64 atime;
 	s64 mtime;
 	s64 ctime;
@@ -1131,7 +1131,7 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 	       file->f_path.dentry->d_name.name, iot, *ppos, count);
 
 restart:
-	io = ccc_env_thread_io(env);
+	io = vvp_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE);
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
@@ -2612,7 +2612,7 @@ int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	io = ccc_env_thread_io(env);
+	io = vvp_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
 	io->ci_ignore_layout = ignore_layout;
 
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index d76fa16..d8ea754 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -93,7 +93,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 	if (!(lli->lli_flags & LLIF_MDS_SIZE_LOCK)) {
 		CDEBUG(D_DLMTRACE, "Glimpsing inode " DFID "\n", PFID(fid));
 		if (lli->lli_has_smd) {
-			struct cl_lock *lock = ccc_env_lock(env);
+			struct cl_lock *lock = vvp_env_lock(env);
 			struct cl_lock_descr *descr = &lock->cll_descr;
 
 			/* NOTE: this looks like DLM lock request, but it may
@@ -163,7 +163,7 @@ static int cl_io_get(struct inode *inode, struct lu_env **envout,
 	if (S_ISREG(inode->i_mode)) {
 		env = cl_env_get(refcheck);
 		if (!IS_ERR(env)) {
-			io = ccc_env_thread_io(env);
+			io = vvp_env_thread_io(env);
 			io->ci_obj = clob;
 			*envout = env;
 			*ioout  = io;
@@ -238,7 +238,7 @@ int cl_local_size(struct inode *inode)
 	if (result > 0) {
 		result = io->ci_result;
 	} else if (result == 0) {
-		struct cl_lock *lock = ccc_env_lock(env);
+		struct cl_lock *lock = vvp_env_lock(env);
 
 		lock->cll_descr = whole_file;
 		lock->cll_descr.cld_enq_flags = CEF_PEEK;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index d28546a..5b523e33 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -65,49 +65,12 @@
  * ccc_ prefix stands for "Common Client Code".
  */
 
-static struct kmem_cache *ccc_thread_kmem;
-
-static struct lu_kmem_descr ccc_caches[] = {
-	{
-		.ckd_cache = &ccc_thread_kmem,
-		.ckd_name  = "ccc_thread_kmem",
-		.ckd_size  = sizeof(struct ccc_thread_info),
-	},
-	{
-		.ckd_cache = NULL
-	}
-};
-
 /*****************************************************************************
  *
  * Vvp device and device type functions.
  *
  */
 
-void *ccc_key_init(const struct lu_context *ctx, struct lu_context_key *key)
-{
-	struct ccc_thread_info *info;
-
-	info = kmem_cache_zalloc(ccc_thread_kmem, GFP_NOFS);
-	if (!info)
-		info = ERR_PTR(-ENOMEM);
-	return info;
-}
-
-void ccc_key_fini(const struct lu_context *ctx,
-		  struct lu_context_key *key, void *data)
-{
-	struct ccc_thread_info *info = data;
-
-	kmem_cache_free(ccc_thread_kmem, info);
-}
-
-struct lu_context_key ccc_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = ccc_key_init,
-	.lct_fini = ccc_key_fini
-};
-
 /**
  * An `emergency' environment used by ccc_inode_fini() when cl_env_get()
  * fails. Access to this environment is serialized by ccc_inode_fini_guard
@@ -126,13 +89,9 @@ int ccc_global_init(struct lu_device_type *device_type)
 {
 	int result;
 
-	result = lu_kmem_init(ccc_caches);
-	if (result)
-		return result;
-
 	result = lu_device_type_init(device_type);
 	if (result)
-		goto out_kmem;
+		return result;
 
 	ccc_inode_fini_env = cl_env_alloc(&dummy_refcheck,
 					  LCT_REMEMBER | LCT_NOREF);
@@ -145,8 +104,6 @@ int ccc_global_init(struct lu_device_type *device_type)
 	return 0;
 out_device:
 	lu_device_type_fini(device_type);
-out_kmem:
-	lu_kmem_fini(ccc_caches);
 	return result;
 }
 
@@ -157,7 +114,6 @@ void ccc_global_fini(struct lu_device_type *device_type)
 		ccc_inode_fini_env = NULL;
 	}
 	lu_device_type_fini(device_type);
-	lu_kmem_fini(ccc_caches);
 }
 
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
@@ -171,7 +127,7 @@ int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	io = ccc_env_thread_io(env);
+	io = vvp_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
 
 	io->u.ci_setattr.sa_attr.lvb_atime = LTIME_S(attr->ia_atime);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 5e3e43f..12f3e71 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -140,7 +140,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	io = ccc_env_thread_io(env);
+	io = vvp_env_thread_io(env);
 	io->ci_obj = obj;
 	io->ci_ignore_layout = 1;
 
@@ -154,7 +154,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		return rc;
 	}
 
-	lock = ccc_env_lock(env);
+	lock = vvp_env_lock(env);
 	descr = &lock->cll_descr;
 	descr->cld_obj = obj;
 	descr->cld_start = 0;
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index a7693c5..83d7006 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -123,7 +123,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 
 	*env_ret = env;
 
-	io = ccc_env_thread_io(env);
+	io = vvp_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
 	LASSERT(io->ci_obj);
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index f9bc3e4..7d5dd38 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -524,7 +524,7 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
-	struct cl_attr *attr = ccc_env_thread_attr(env);
+	struct cl_attr *attr = vvp_env_thread_attr(env);
 	unsigned long start = 0, end = 0, reserved;
 	unsigned long ra_end, len, mlen = 0;
 	struct inode *inode;
@@ -999,7 +999,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 	clob  = ll_i2info(inode)->lli_clob;
 	LASSERT(clob);
 
-	io = ccc_env_thread_io(env);
+	io = vvp_env_thread_io(env);
 	io->ci_obj = clob;
 	io->ci_ignore_layout = 1;
 	result = cl_io_init(env, io, CIT_MISC, clob);
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 106473e..65baeeb 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -455,7 +455,7 @@ out:
 static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 				   struct cl_page *pg)
 {
-	struct cl_attr *attr   = ccc_env_thread_attr(env);
+	struct cl_attr *attr   = vvp_env_thread_attr(env);
 	struct cl_object *obj  = io->ci_obj;
 	struct vvp_page *vpg   = cl_object_page_slice(obj, pg);
 	loff_t          offset = cl_offset(obj, vvp_index(vpg));
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index cafc2c2..c27cb1a 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -62,6 +62,8 @@ struct kmem_cache *vvp_lock_kmem;
 struct kmem_cache *vvp_object_kmem;
 struct kmem_cache *vvp_req_kmem;
 static struct kmem_cache *vvp_session_kmem;
+static struct kmem_cache *vvp_thread_kmem;
+
 static struct lu_kmem_descr vvp_caches[] = {
 	{
 		.ckd_cache = &ll_thread_kmem,
@@ -94,6 +96,11 @@ static struct lu_kmem_descr vvp_caches[] = {
 		.ckd_size  = sizeof(struct vvp_session)
 	},
 	{
+		.ckd_cache = &vvp_thread_kmem,
+		.ckd_name  = "vvp_thread_kmem",
+		.ckd_size  = sizeof(struct vvp_thread_info),
+	},
+	{
 		.ckd_cache = NULL
 	}
 };
@@ -148,8 +155,33 @@ struct lu_context_key vvp_session_key = {
 	.lct_fini = vvp_session_key_fini
 };
 
+void *vvp_thread_key_init(const struct lu_context *ctx,
+			  struct lu_context_key *key)
+{
+	struct vvp_thread_info *vti;
+
+	vti = kmem_cache_zalloc(vvp_thread_kmem, GFP_NOFS);
+	if (!vti)
+		vti = ERR_PTR(-ENOMEM);
+	return vti;
+}
+
+void vvp_thread_key_fini(const struct lu_context *ctx,
+			 struct lu_context_key *key, void *data)
+{
+	struct vvp_thread_info *vti = data;
+
+	kmem_cache_free(vvp_thread_kmem, vti);
+}
+
+struct lu_context_key vvp_thread_key = {
+	.lct_tags = LCT_CL_THREAD,
+	.lct_init = vvp_thread_key_init,
+	.lct_fini = vvp_thread_key_fini
+};
+
 /* type constructor/destructor: vvp_type_{init,fini,start,stop}(). */
-LU_TYPE_INIT_FINI(vvp, &ccc_key, &ll_thread_key, &vvp_session_key);
+LU_TYPE_INIT_FINI(vvp, &vvp_thread_key, &ll_thread_key, &vvp_session_key);
 
 static const struct lu_device_operations vvp_lu_ops = {
 	.ldo_object_alloc      = vvp_object_alloc
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 4740ff5..0e15202 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -164,50 +164,50 @@ struct vvp_io {
 	bool		vui_ra_valid;
 };
 
-extern struct lu_context_key ccc_key;
 extern struct lu_context_key vvp_session_key;
+extern struct lu_context_key vvp_thread_key;
 
 extern struct kmem_cache *vvp_lock_kmem;
 extern struct kmem_cache *vvp_object_kmem;
 extern struct kmem_cache *vvp_req_kmem;
 
-struct ccc_thread_info {
-	struct cl_lock		cti_lock;
-	struct cl_lock_descr	cti_descr;
-	struct cl_io		cti_io;
-	struct cl_attr		cti_attr;
+struct vvp_thread_info {
+	struct cl_lock		vti_lock;
+	struct cl_lock_descr	vti_descr;
+	struct cl_io		vti_io;
+	struct cl_attr		vti_attr;
 };
 
-static inline struct ccc_thread_info *ccc_env_info(const struct lu_env *env)
+static inline struct vvp_thread_info *vvp_env_info(const struct lu_env *env)
 {
-	struct ccc_thread_info      *info;
+	struct vvp_thread_info      *vti;
 
-	info = lu_context_key_get(&env->le_ctx, &ccc_key);
-	LASSERT(info);
+	vti = lu_context_key_get(&env->le_ctx, &vvp_thread_key);
+	LASSERT(vti);
 
-	return info;
+	return vti;
 }
 
-static inline struct cl_lock *ccc_env_lock(const struct lu_env *env)
+static inline struct cl_lock *vvp_env_lock(const struct lu_env *env)
 {
-	struct cl_lock *lock = &ccc_env_info(env)->cti_lock;
+	struct cl_lock *lock = &vvp_env_info(env)->vti_lock;
 
 	memset(lock, 0, sizeof(*lock));
 	return lock;
 }
 
-static inline struct cl_attr *ccc_env_thread_attr(const struct lu_env *env)
+static inline struct cl_attr *vvp_env_thread_attr(const struct lu_env *env)
 {
-	struct cl_attr *attr = &ccc_env_info(env)->cti_attr;
+	struct cl_attr *attr = &vvp_env_info(env)->vti_attr;
 
 	memset(attr, 0, sizeof(*attr));
 
 	return attr;
 }
 
-static inline struct cl_io *ccc_env_thread_io(const struct lu_env *env)
+static inline struct cl_io *vvp_env_thread_io(const struct lu_env *env)
 {
-	struct cl_io *io = &ccc_env_info(env)->cti_io;
+	struct cl_io *io = &vvp_env_info(env)->vti_io;
 
 	memset(io, 0, sizeof(*io));
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 18bc71b..366ac1c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -135,7 +135,7 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
 			 struct cl_io *io, loff_t start, size_t count,
 			 int *exceed)
 {
-	struct cl_attr *attr  = ccc_env_thread_attr(env);
+	struct cl_attr *attr  = vvp_env_thread_attr(env);
 	struct inode   *inode = vvp_object_inode(obj);
 	loff_t	  pos   = start + count - 1;
 	loff_t kms;
@@ -382,10 +382,10 @@ static enum cl_lock_mode vvp_mode_from_vma(struct vm_area_struct *vma)
 static int vvp_mmap_locks(const struct lu_env *env,
 			  struct vvp_io *vio, struct cl_io *io)
 {
-	struct ccc_thread_info *cti = ccc_env_info(env);
+	struct vvp_thread_info *cti = vvp_env_info(env);
 	struct mm_struct       *mm = current->mm;
 	struct vm_area_struct  *vma;
-	struct cl_lock_descr   *descr = &cti->cti_descr;
+	struct cl_lock_descr   *descr = &cti->vti_descr;
 	ldlm_policy_data_t      policy;
 	unsigned long	   addr;
 	ssize_t		 count;
@@ -621,7 +621,7 @@ static int vvp_io_setattr_time(const struct lu_env *env,
 {
 	struct cl_io       *io    = ios->cis_io;
 	struct cl_object   *obj   = io->ci_obj;
-	struct cl_attr     *attr  = ccc_env_thread_attr(env);
+	struct cl_attr     *attr  = vvp_env_thread_attr(env);
 	int result;
 	unsigned valid = CAT_CTIME;
 
-- 
2.1.0
