From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:43 -0400
Subject: [lustre-devel] [PATCH 104/124] staging: lustre: clio: rename
	coo_attr_set to coo_attr_update
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-105-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

coo_attr_set() is used to update object's attribute but its name
makes confusion that people intuitively think that it is used to
pass object's attribute down to server sides.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1154
Reviewed-on: http://review.whamcloud.com/12888
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    8 ++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    6 +++---
 drivers/staging/lustre/lustre/lov/lov_object.c     |    6 +++---
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |    6 +++---
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   17 +++++++++--------
 drivers/staging/lustre/lustre/osc/osc_io.c         |    9 +++++----
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    4 ++--
 drivers/staging/lustre/lustre/osc/osc_object.c     |    6 +++---
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 10 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 409a324..9403c0c 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -369,8 +369,8 @@ struct cl_object_operations {
 	 * \return the same convention as for
 	 * cl_object_operations::coo_attr_get() is used.
 	 */
-	int (*coo_attr_set)(const struct lu_env *env, struct cl_object *obj,
-			    const struct cl_attr *attr, unsigned valid);
+	int (*coo_attr_update)(const struct lu_env *env, struct cl_object *obj,
+			       const struct cl_attr *attr, unsigned int valid);
 	/**
 	 * Update object configuration. Called top-to-bottom to modify object
 	 * configuration.
@@ -2171,8 +2171,8 @@ void cl_object_attr_lock(struct cl_object *o);
 void cl_object_attr_unlock(struct cl_object *o);
 int  cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
 			struct cl_attr *attr);
-int  cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
-			const struct cl_attr *attr, unsigned valid);
+int  cl_object_attr_update(const struct lu_env *env, struct cl_object *obj,
+			   const struct cl_attr *attr, unsigned int valid);
 int  cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
 		       struct ost_lvb *lvb);
 int  cl_conf_set(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 27fc0b0..2ab4503 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -627,7 +627,7 @@ static int vvp_io_setattr_time(const struct lu_env *env,
 		attr->cat_mtime = io->u.ci_setattr.sa_attr.lvb_mtime;
 		valid |= CAT_MTIME;
 	}
-	result = cl_object_attr_set(env, obj, attr, valid);
+	result = cl_object_attr_update(env, obj, attr, valid);
 	cl_object_attr_unlock(obj);
 
 	return result;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 6b6a63d..b57195d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -101,8 +101,8 @@ static int vvp_attr_get(const struct lu_env *env, struct cl_object *obj,
 	return 0; /* layers below have to fill in the rest */
 }
 
-static int vvp_attr_set(const struct lu_env *env, struct cl_object *obj,
-			const struct cl_attr *attr, unsigned valid)
+static int vvp_attr_update(const struct lu_env *env, struct cl_object *obj,
+			   const struct cl_attr *attr, unsigned int valid)
 {
 	struct inode *inode = vvp_object_inode(obj);
 
@@ -209,7 +209,7 @@ static const struct cl_object_operations vvp_ops = {
 	.coo_lock_init = vvp_lock_init,
 	.coo_io_init   = vvp_io_init,
 	.coo_attr_get  = vvp_attr_get,
-	.coo_attr_set  = vvp_attr_set,
+	.coo_attr_update = vvp_attr_update,
 	.coo_conf_set  = vvp_conf_set,
 	.coo_prune     = vvp_prune,
 	.coo_glimpse   = vvp_object_glimpse
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 01f95a9..52f7363 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -894,8 +894,8 @@ static int lov_attr_get(const struct lu_env *env, struct cl_object *obj,
 	return LOV_2DISPATCH_NOLOCK(cl2lov(obj), llo_getattr, env, obj, attr);
 }
 
-static int lov_attr_set(const struct lu_env *env, struct cl_object *obj,
-			const struct cl_attr *attr, unsigned valid)
+static int lov_attr_update(const struct lu_env *env, struct cl_object *obj,
+			   const struct cl_attr *attr, unsigned int valid)
 {
 	/*
 	 * No dispatch is required here, as no layout implements this.
@@ -932,7 +932,7 @@ static const struct cl_object_operations lov_ops = {
 	.coo_lock_init = lov_lock_init,
 	.coo_io_init   = lov_io_init,
 	.coo_attr_get  = lov_attr_get,
-	.coo_attr_set  = lov_attr_set,
+	.coo_attr_update = lov_attr_update,
 	.coo_conf_set  = lov_conf_set,
 	.coo_getstripe = lov_object_getstripe
 };
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index fb2f266..a2bac7a 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -98,8 +98,8 @@ static int lovsub_object_print(const struct lu_env *env, void *cookie,
 	return (*p)(env, cookie, "[%d]", los->lso_index);
 }
 
-static int lovsub_attr_set(const struct lu_env *env, struct cl_object *obj,
-			   const struct cl_attr *attr, unsigned valid)
+static int lovsub_attr_update(const struct lu_env *env, struct cl_object *obj,
+			      const struct cl_attr *attr, unsigned int valid)
 {
 	struct lov_object *lov = cl2lovsub(obj)->lso_super;
 
@@ -119,7 +119,7 @@ static int lovsub_object_glimpse(const struct lu_env *env,
 static const struct cl_object_operations lovsub_ops = {
 	.coo_page_init = lovsub_page_init,
 	.coo_lock_init = lovsub_lock_init,
-	.coo_attr_set  = lovsub_attr_set,
+	.coo_attr_update = lovsub_attr_update,
 	.coo_glimpse   = lovsub_object_glimpse
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index ef5b1aa..e493c80 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -163,7 +163,7 @@ static spinlock_t *cl_object_attr_guard(struct cl_object *o)
  *
  * Prevents data-attributes from changing, until lock is released by
  * cl_object_attr_unlock(). This has to be called before calls to
- * cl_object_attr_get(), cl_object_attr_set().
+ * cl_object_attr_get(), cl_object_attr_update().
  */
 void cl_object_attr_lock(struct cl_object *o)
 	__acquires(cl_object_attr_guard(o))
@@ -217,11 +217,11 @@ EXPORT_SYMBOL(cl_object_attr_get);
  * Updates data-attributes of an object \a obj.
  *
  * Only attributes, mentioned in a validness bit-mask \a v are
- * updated. Calls cl_object_operations::coo_attr_set() on every layer, bottom
- * to top.
+ * updated. Calls cl_object_operations::coo_attr_update() on every layer,
+ * bottom to top.
  */
-int cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
-		       const struct cl_attr *attr, unsigned v)
+int cl_object_attr_update(const struct lu_env *env, struct cl_object *obj,
+			  const struct cl_attr *attr, unsigned int v)
 {
 	struct lu_object_header *top;
 	int result;
@@ -231,8 +231,9 @@ int cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
 	top = obj->co_lu.lo_header;
 	result = 0;
 	list_for_each_entry_reverse(obj, &top->loh_layers, co_lu.lo_linkage) {
-		if (obj->co_ops->coo_attr_set) {
-			result = obj->co_ops->coo_attr_set(env, obj, attr, v);
+		if (obj->co_ops->coo_attr_update) {
+			result = obj->co_ops->coo_attr_update(env, obj, attr,
+							      v);
 			if (result != 0) {
 				if (result > 0)
 					result = 0;
@@ -242,7 +243,7 @@ int cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
 	}
 	return result;
 }
-EXPORT_SYMBOL(cl_object_attr_set);
+EXPORT_SYMBOL(cl_object_attr_update);
 
 /**
  * Notifies layers (bottom-to-top) that glimpse AST was received.
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 8bbb2a6..42e9761 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -233,7 +233,7 @@ static void osc_page_touch_at(const struct lu_env *env,
 		attr->cat_size = kms;
 		valid |= CAT_SIZE;
 	}
-	cl_object_attr_set(env, obj, attr, valid);
+	cl_object_attr_update(env, obj, attr, valid);
 	cl_object_attr_unlock(obj);
 }
 
@@ -476,7 +476,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 				attr->cat_ctime = lvb->lvb_ctime;
 				cl_valid |= CAT_CTIME;
 			}
-			result = cl_object_attr_set(env, obj, attr, cl_valid);
+			result = cl_object_attr_update(env, obj, attr,
+						       cl_valid);
 		}
 		cl_object_attr_unlock(obj);
 	}
@@ -564,7 +565,7 @@ static int osc_io_read_start(const struct lu_env *env,
 	if (!slice->cis_io->ci_noatime) {
 		cl_object_attr_lock(obj);
 		attr->cat_atime = ktime_get_real_seconds();
-		rc = cl_object_attr_set(env, obj, attr, CAT_ATIME);
+		rc = cl_object_attr_update(env, obj, attr, CAT_ATIME);
 		cl_object_attr_unlock(obj);
 	}
 	return rc;
@@ -581,7 +582,7 @@ static int osc_io_write_start(const struct lu_env *env,
 	cl_object_attr_lock(obj);
 	attr->cat_ctime = ktime_get_real_seconds();
 	attr->cat_mtime = attr->cat_ctime;
-	rc = cl_object_attr_set(env, obj, attr, CAT_MTIME | CAT_CTIME);
+	rc = cl_object_attr_update(env, obj, attr, CAT_MTIME | CAT_CTIME);
 	cl_object_attr_unlock(obj);
 
 	return rc;
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 717d3ff..39a8a58 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -222,7 +222,7 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 		ldlm_lock_allow_match_locked(dlmlock);
 	}
 
-	cl_object_attr_set(env, obj, attr, valid);
+	cl_object_attr_update(env, obj, attr, valid);
 	cl_object_attr_unlock(obj);
 }
 
@@ -467,7 +467,7 @@ static int osc_dlm_blocking_ast0(const struct lu_env *env,
 		 */
 		attr->cat_kms = ldlm_extent_shift_kms(dlmlock, old_kms);
 
-		cl_object_attr_set(env, obj, attr, CAT_KMS);
+		cl_object_attr_update(env, obj, attr, CAT_KMS);
 		cl_object_attr_unlock(obj);
 		unlock_res_and_lock(dlmlock);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 5fc5479..aae3a2d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -159,8 +159,8 @@ static int osc_attr_get(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
-static int osc_attr_set(const struct lu_env *env, struct cl_object *obj,
-			const struct cl_attr *attr, unsigned valid)
+static int osc_attr_update(const struct lu_env *env, struct cl_object *obj,
+			   const struct cl_attr *attr, unsigned int valid)
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
 	struct ost_lvb *lvb = &oinfo->loi_lvb;
@@ -261,7 +261,7 @@ static const struct cl_object_operations osc_ops = {
 	.coo_lock_init = osc_lock_init,
 	.coo_io_init   = osc_io_init,
 	.coo_attr_get  = osc_attr_get,
-	.coo_attr_set  = osc_attr_set,
+	.coo_attr_update = osc_attr_update,
 	.coo_glimpse   = osc_object_glimpse,
 	.coo_prune     = osc_object_prune
 };
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3b59c2d..68cf115 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1749,7 +1749,7 @@ static int brw_interpret(const struct lu_env *env,
 		}
 
 		if (valid != 0)
-			cl_object_attr_set(env, obj, attr, valid);
+			cl_object_attr_update(env, obj, attr, valid);
 		cl_object_attr_unlock(obj);
 	}
 	kmem_cache_free(obdo_cachep, aa->aa_oa);
-- 
1.7.1
