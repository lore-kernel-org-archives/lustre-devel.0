From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:00 -0400
Subject: [lustre-devel] [PATCH 28/43] staging/lustre/llite: rename ccc_lock
	to vvp_lock
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-29-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Rename struct ccc_lock to struct vvp_lock and merge the CCC lock
methods into the VVP lock methods.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/13088
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5971
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  6 +--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 52 ----------------------
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  6 +++
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 20 ++++-----
 drivers/staging/lustre/lustre/llite/vvp_lock.c     | 38 +++++++++++++---
 5 files changed, 50 insertions(+), 72 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3488349..d509f94 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1227,7 +1227,7 @@ struct cl_lock {
 /**
  * Per-layer part of cl_lock
  *
- * \see ccc_lock, lov_lock, lovsub_lock, osc_lock
+ * \see vvp_lock, lov_lock, lovsub_lock, osc_lock
  */
 struct cl_lock_slice {
 	struct cl_lock		  *cls_lock;
@@ -1254,7 +1254,7 @@ struct cl_lock_operations {
 	 *		@anchor for resources
 	 * \retval -ve	failure
 	 *
-	 * \see ccc_lock_enqueue(), lov_lock_enqueue(), lovsub_lock_enqueue(),
+	 * \see vvp_lock_enqueue(), lov_lock_enqueue(), lovsub_lock_enqueue(),
 	 * \see osc_lock_enqueue()
 	 */
 	int  (*clo_enqueue)(const struct lu_env *env,
@@ -1270,7 +1270,7 @@ struct cl_lock_operations {
 	/**
 	 * Destructor. Frees resources and the slice.
 	 *
-	 * \see ccc_lock_fini(), lov_lock_fini(), lovsub_lock_fini(),
+	 * \see vvp_lock_fini(), lov_lock_fini(), lovsub_lock_fini(),
 	 * \see osc_lock_fini()
 	 */
 	void (*clo_fini)(const struct lu_env *env, struct cl_lock_slice *slice);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 0762032..8884317 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -67,18 +67,12 @@ static const struct cl_req_operations ccc_req_ops;
  * ccc_ prefix stands for "Common Client Code".
  */
 
-static struct kmem_cache *ccc_lock_kmem;
 static struct kmem_cache *ccc_thread_kmem;
 static struct kmem_cache *ccc_session_kmem;
 static struct kmem_cache *ccc_req_kmem;
 
 static struct lu_kmem_descr ccc_caches[] = {
 	{
-		.ckd_cache = &ccc_lock_kmem,
-		.ckd_name  = "ccc_lock_kmem",
-		.ckd_size  = sizeof(struct ccc_lock)
-	},
-	{
 		.ckd_cache = &ccc_thread_kmem,
 		.ckd_name  = "ccc_thread_kmem",
 		.ckd_size  = sizeof(struct ccc_thread_info),
@@ -221,26 +215,6 @@ void ccc_global_fini(struct lu_device_type *device_type)
 	lu_kmem_fini(ccc_caches);
 }
 
-int ccc_lock_init(const struct lu_env *env,
-		  struct cl_object *obj, struct cl_lock *lock,
-		  const struct cl_io *unused,
-		  const struct cl_lock_operations *lkops)
-{
-	struct ccc_lock *clk;
-	int result;
-
-	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
-
-	clk = kmem_cache_zalloc(ccc_lock_kmem, GFP_NOFS);
-	if (clk) {
-		cl_lock_slice_add(lock, &clk->clk_cl, obj, lkops);
-		result = 0;
-	} else {
-		result = -ENOMEM;
-	}
-	return result;
-}
-
 static void vvp_object_size_lock(struct cl_object *obj)
 {
 	struct inode *inode = vvp_object_inode(obj);
@@ -259,27 +233,6 @@ static void vvp_object_size_unlock(struct cl_object *obj)
 
 /*****************************************************************************
  *
- * Lock operations.
- *
- */
-
-void ccc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice)
-{
-	struct ccc_lock *clk = cl2ccc_lock(slice);
-
-	kmem_cache_free(ccc_lock_kmem, clk);
-}
-
-int ccc_lock_enqueue(const struct lu_env *env,
-		     const struct cl_lock_slice *slice,
-		     struct cl_io *unused, struct cl_sync_io *anchor)
-{
-	CLOBINVRNT(env, slice->cls_obj, vvp_object_invariant(slice->cls_obj));
-	return 0;
-}
-
-/*****************************************************************************
- *
  * io operations.
  *
  */
@@ -571,11 +524,6 @@ again:
  *
  */
 
-struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice)
-{
-	return container_of(slice, struct ccc_lock, clk_cl);
-}
-
 struct ccc_io *cl2ccc_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice)
 {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 3891b0d..4b77db3 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -57,11 +57,17 @@
  * "llite_" (var. "ll_") prefix.
  */
 
+struct kmem_cache *vvp_lock_kmem;
 struct kmem_cache *vvp_object_kmem;
 static struct kmem_cache *vvp_thread_kmem;
 static struct kmem_cache *vvp_session_kmem;
 static struct lu_kmem_descr vvp_caches[] = {
 	{
+		.ckd_cache = &vvp_lock_kmem,
+		.ckd_name  = "vvp_lock_kmem",
+		.ckd_size  = sizeof(struct vvp_lock),
+	},
+	{
 		.ckd_cache = &vvp_object_kmem,
 		.ckd_name  = "vvp_object_kmem",
 		.ckd_size  = sizeof(struct vvp_object),
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 4991ce7..403d2a7 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -128,6 +128,7 @@ int cl_is_normalio(const struct lu_env *env, const struct cl_io *io);
 extern struct lu_context_key ccc_key;
 extern struct lu_context_key ccc_session_key;
 
+extern struct kmem_cache *vvp_lock_kmem;
 extern struct kmem_cache *vvp_object_kmem;
 
 struct ccc_thread_info {
@@ -269,8 +270,8 @@ struct vvp_device {
 	struct cl_device   *vdv_next;
 };
 
-struct ccc_lock {
-	struct cl_lock_slice clk_cl;
+struct vvp_lock {
+	struct cl_lock_slice vlk_cl;
 };
 
 struct ccc_req {
@@ -291,15 +292,6 @@ int ccc_req_init(const struct lu_env *env, struct cl_device *dev,
 void ccc_umount(const struct lu_env *env, struct cl_device *dev);
 int ccc_global_init(struct lu_device_type *device_type);
 void ccc_global_fini(struct lu_device_type *device_type);
-int ccc_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *io,
-		  const struct cl_lock_operations *lkops);
-void ccc_lock_delete(const struct lu_env *env,
-		     const struct cl_lock_slice *slice);
-void ccc_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice);
-int ccc_lock_enqueue(const struct lu_env *env,
-		     const struct cl_lock_slice *slice,
-		     struct cl_io *io, struct cl_sync_io *anchor);
 
 int ccc_io_one_lock_index(const struct lu_env *env, struct cl_io *io,
 			  __u32 enqflags, enum cl_lock_mode mode,
@@ -359,7 +351,11 @@ static inline struct page *cl2vm_page(const struct cl_page_slice *slice)
 	return cl2vvp_page(slice)->vpg_page;
 }
 
-struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice);
+static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
+{
+	return container_of(slice, struct vvp_lock, vlk_cl);
+}
+
 struct ccc_io *cl2ccc_io(const struct lu_env *env,
 			 const struct cl_io_slice *slice);
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index 8c505a6..f5bd6c2 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -40,7 +40,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include "../include/obd.h"
+#include "../include/obd_support.h"
 #include "../include/lustre_lite.h"
 
 #include "vvp_internal.h"
@@ -51,13 +51,41 @@
  *
  */
 
+static void vvp_lock_fini(const struct lu_env *env, struct cl_lock_slice *slice)
+{
+	struct vvp_lock *vlk = cl2vvp_lock(slice);
+
+	kmem_cache_free(vvp_lock_kmem, vlk);
+}
+
+static int vvp_lock_enqueue(const struct lu_env *env,
+			    const struct cl_lock_slice *slice,
+			    struct cl_io *unused, struct cl_sync_io *anchor)
+{
+	CLOBINVRNT(env, slice->cls_obj, vvp_object_invariant(slice->cls_obj));
+
+	return 0;
+}
+
 static const struct cl_lock_operations vvp_lock_ops = {
-	.clo_fini      = ccc_lock_fini,
-	.clo_enqueue   = ccc_lock_enqueue
+	.clo_fini	= vvp_lock_fini,
+	.clo_enqueue	= vvp_lock_enqueue,
 };
 
 int vvp_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *io)
+		  struct cl_lock *lock, const struct cl_io *unused)
 {
-	return ccc_lock_init(env, obj, lock, io, &vvp_lock_ops);
+	struct vvp_lock *vlk;
+	int result;
+
+	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
+
+	vlk = kmem_cache_zalloc(vvp_lock_kmem, GFP_NOFS);
+	if (vlk) {
+		cl_lock_slice_add(lock, &vlk->vlk_cl, obj, &vvp_lock_ops);
+		result = 0;
+	} else {
+		result = -ENOMEM;
+	}
+	return result;
 }
-- 
2.1.0
