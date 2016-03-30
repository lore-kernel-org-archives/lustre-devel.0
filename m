From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:56 -0400
Subject: [lustre-devel] [PATCH v2 35/46] staging/lustre/llite: Rename struct
	vvp_thread_info to ll_thread_info
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-36-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, John Hammond <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: John Hammond <john.hammond@intel.com>

struct vvp_thread_info is used in the non-VVP parts of llite so rename
it struct ll_thread_info. Rename supporting functions accordingly.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/13714
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c         |  6 ++--
 .../staging/lustre/lustre/llite/llite_internal.h   | 30 ++++++++---------
 drivers/staging/lustre/lustre/llite/rw.c           |  6 ++--
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 38 +++++++++++-----------
 4 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 210d1e2..f7aabac 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1221,7 +1221,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	args = vvp_env_args(env, IO_NORMAL);
+	args = ll_env_args(env, IO_NORMAL);
 	args->u.normal.via_iter = to;
 	args->u.normal.via_iocb = iocb;
 
@@ -1245,7 +1245,7 @@ static ssize_t ll_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	args = vvp_env_args(env, IO_NORMAL);
+	args = ll_env_args(env, IO_NORMAL);
 	args->u.normal.via_iter = from;
 	args->u.normal.via_iocb = iocb;
 
@@ -1271,7 +1271,7 @@ static ssize_t ll_file_splice_read(struct file *in_file, loff_t *ppos,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	args = vvp_env_args(env, IO_SPLICE);
+	args = ll_env_args(env, IO_SPLICE);
 	args->u.splice.via_pipe = pipe;
 	args->u.splice.via_flags = flags;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 8b943df..a6ee2fe 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -855,30 +855,30 @@ struct ll_cl_context {
 	int	     lcc_refcheck;
 };
 
-struct vvp_thread_info {
-	struct vvp_io_args   vti_args;
-	struct ra_io_arg     vti_ria;
-	struct ll_cl_context vti_io_ctx;
+struct ll_thread_info {
+	struct vvp_io_args   lti_args;
+	struct ra_io_arg     lti_ria;
+	struct ll_cl_context lti_io_ctx;
 };
 
-static inline struct vvp_thread_info *vvp_env_info(const struct lu_env *env)
+extern struct lu_context_key ll_thread_key;
+static inline struct ll_thread_info *ll_env_info(const struct lu_env *env)
 {
-	extern struct lu_context_key vvp_key;
-	struct vvp_thread_info      *info;
+	struct ll_thread_info *lti;
 
-	info = lu_context_key_get(&env->le_ctx, &vvp_key);
-	LASSERT(info);
-	return info;
+	lti = lu_context_key_get(&env->le_ctx, &ll_thread_key);
+	LASSERT(lti);
+	return lti;
 }
 
-static inline struct vvp_io_args *vvp_env_args(const struct lu_env *env,
-					       enum vvp_io_subtype type)
+static inline struct vvp_io_args *ll_env_args(const struct lu_env *env,
+					      enum vvp_io_subtype type)
 {
-	struct vvp_io_args *ret = &vvp_env_info(env)->vti_args;
+	struct vvp_io_args *via = &ll_env_info(env)->lti_args;
 
-	ret->via_io_subtype = type;
+	via->via_io_subtype = type;
 
-	return ret;
+	return via;
 }
 
 int vvp_global_init(void);
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 634f0bb..f9bc3e4 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -102,7 +102,7 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 	if (IS_ERR(env))
 		return ERR_CAST(env);
 
-	lcc = &vvp_env_info(env)->vti_io_ctx;
+	lcc = &ll_env_info(env)->lti_io_ctx;
 	memset(lcc, 0, sizeof(*lcc));
 	lcc->lcc_env = env;
 	lcc->lcc_refcheck = refcheck;
@@ -523,12 +523,12 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 		 bool hit)
 {
 	struct vvp_io *vio = vvp_env_io(env);
-	struct vvp_thread_info *vti = vvp_env_info(env);
+	struct ll_thread_info *lti = ll_env_info(env);
 	struct cl_attr *attr = ccc_env_thread_attr(env);
 	unsigned long start = 0, end = 0, reserved;
 	unsigned long ra_end, len, mlen = 0;
 	struct inode *inode;
-	struct ra_io_arg *ria = &vti->vti_ria;
+	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
 	int ret = 0;
 	__u64 kms;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 5d3beb6..2278433 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -57,13 +57,18 @@
  * "llite_" (var. "ll_") prefix.
  */
 
+static struct kmem_cache *ll_thread_kmem;
 struct kmem_cache *vvp_lock_kmem;
 struct kmem_cache *vvp_object_kmem;
 struct kmem_cache *vvp_req_kmem;
-static struct kmem_cache *vvp_thread_kmem;
 static struct kmem_cache *vvp_session_kmem;
 static struct lu_kmem_descr vvp_caches[] = {
 	{
+		.ckd_cache = &ll_thread_kmem,
+		.ckd_name  = "ll_thread_kmem",
+		.ckd_size  = sizeof(struct ll_thread_info),
+	},
+	{
 		.ckd_cache = &vvp_lock_kmem,
 		.ckd_name  = "vvp_lock_kmem",
 		.ckd_size  = sizeof(struct vvp_lock),
@@ -79,11 +84,6 @@ static struct lu_kmem_descr vvp_caches[] = {
 		.ckd_size  = sizeof(struct vvp_req),
 	},
 	{
-		.ckd_cache = &vvp_thread_kmem,
-		.ckd_name  = "vvp_thread_kmem",
-		.ckd_size  = sizeof(struct vvp_thread_info),
-	},
-	{
 		.ckd_cache = &vvp_session_kmem,
 		.ckd_name  = "vvp_session_kmem",
 		.ckd_size  = sizeof(struct vvp_session)
@@ -93,25 +93,31 @@ static struct lu_kmem_descr vvp_caches[] = {
 	}
 };
 
-static void *vvp_key_init(const struct lu_context *ctx,
-			  struct lu_context_key *key)
+static void *ll_thread_key_init(const struct lu_context *ctx,
+				struct lu_context_key *key)
 {
 	struct vvp_thread_info *info;
 
-	info = kmem_cache_zalloc(vvp_thread_kmem, GFP_NOFS);
+	info = kmem_cache_zalloc(ll_thread_kmem, GFP_NOFS);
 	if (!info)
 		info = ERR_PTR(-ENOMEM);
 	return info;
 }
 
-static void vvp_key_fini(const struct lu_context *ctx,
-			 struct lu_context_key *key, void *data)
+static void ll_thread_key_fini(const struct lu_context *ctx,
+			       struct lu_context_key *key, void *data)
 {
 	struct vvp_thread_info *info = data;
 
-	kmem_cache_free(vvp_thread_kmem, info);
+	kmem_cache_free(ll_thread_kmem, info);
 }
 
+struct lu_context_key ll_thread_key = {
+	.lct_tags = LCT_CL_THREAD,
+	.lct_init = ll_thread_key_init,
+	.lct_fini = ll_thread_key_fini
+};
+
 static void *vvp_session_key_init(const struct lu_context *ctx,
 				  struct lu_context_key *key)
 {
@@ -131,12 +137,6 @@ static void vvp_session_key_fini(const struct lu_context *ctx,
 	kmem_cache_free(vvp_session_kmem, session);
 }
 
-struct lu_context_key vvp_key = {
-	.lct_tags = LCT_CL_THREAD,
-	.lct_init = vvp_key_init,
-	.lct_fini = vvp_key_fini
-};
-
 struct lu_context_key vvp_session_key = {
 	.lct_tags = LCT_SESSION,
 	.lct_init = vvp_session_key_init,
@@ -144,7 +144,7 @@ struct lu_context_key vvp_session_key = {
 };
 
 /* type constructor/destructor: vvp_type_{init,fini,start,stop}(). */
-LU_TYPE_INIT_FINI(vvp, &ccc_key, &vvp_key, &vvp_session_key);
+LU_TYPE_INIT_FINI(vvp, &ccc_key, &ll_thread_key, &vvp_session_key);
 
 static const struct lu_device_operations vvp_lu_ops = {
 	.ldo_object_alloc      = vvp_object_alloc
-- 
2.1.0
