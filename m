From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:30 -0400
Subject: [lustre-devel] [PATCH 091/124] staging: lustre: clio: add
	coo_getstripe interface
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-92-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Use cl_object_operations::coo_getstripe() to handle
LL_IOC_LOV_GETSTRIPE ops.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
Reviewed-on: http://review.whamcloud.com/12452
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    7 +++
 drivers/staging/lustre/lustre/llite/file.c         |   38 +++++++++---------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    6 +++
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 -
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    3 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |   35 +++++++++++++----
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   40 +++++++++++++-------
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   21 ++++++++++
 8 files changed, 105 insertions(+), 47 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index f360ec9..c1bcff8 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -395,6 +395,11 @@ struct cl_object_operations {
 	 * mainly pages and locks.
 	 */
 	int (*coo_prune)(const struct lu_env *env, struct cl_object *obj);
+	/**
+	 * Object getstripe method.
+	 */
+	int (*coo_getstripe)(const struct lu_env *env, struct cl_object *obj,
+			     struct lov_user_md __user *lum);
 };
 
 /**
@@ -2174,6 +2179,8 @@ int  cl_conf_set(const struct lu_env *env, struct cl_object *obj,
 		 const struct cl_object_conf *conf);
 int cl_object_prune(const struct lu_env *env, struct cl_object *obj);
 void cl_object_kill(const struct lu_env *env, struct cl_object *obj);
+int  cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
+			 struct lov_user_md __user *lum);
 
 /**
  * Returns true, iff \a o0 and \a o1 are slices of the same object.
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 0b3b387..2cb0b65 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1449,6 +1449,22 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 	return rc;
 }
 
+static int ll_file_getstripe(struct inode *inode,
+			     struct lov_user_md __user *lum)
+{
+	struct lu_env *env;
+	int refcheck;
+	int rc;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	rc = cl_object_getstripe(env, ll_i2info(inode)->lli_clob, lum);
+	cl_env_put(env, &refcheck);
+	return rc;
+}
+
 static int ll_lov_setstripe(struct inode *inode, struct file *file,
 			    unsigned long arg)
 {
@@ -1466,35 +1482,18 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 				      lum_size);
 	cl_lov_delay_create_clear(&file->f_flags);
 	if (rc == 0) {
-		struct lov_stripe_md *lsm;
 		__u32 gen;
 
 		put_user(0, &lum->lmm_stripe_count);
 
 		ll_layout_refresh(inode, &gen);
-		lsm = ccc_inode_lsm_get(inode);
-		rc = obd_iocontrol(LL_IOC_LOV_GETSTRIPE, ll_i2dtexp(inode),
-				   0, lsm, lum);
-		ccc_inode_lsm_put(inode, lsm);
+		rc = ll_file_getstripe(inode, (struct lov_user_md __user *)arg);
 	}
 
 	kfree(klum);
 	return rc;
 }
 
-static int ll_lov_getstripe(struct inode *inode, unsigned long arg)
-{
-	struct lov_stripe_md *lsm;
-	int rc = -ENODATA;
-
-	lsm = ccc_inode_lsm_get(inode);
-	if (lsm)
-		rc = obd_iocontrol(LL_IOC_LOV_GETSTRIPE, ll_i2dtexp(inode), 0,
-				   lsm, (void __user *)arg);
-	ccc_inode_lsm_put(inode, lsm);
-	return rc;
-}
-
 static int
 ll_get_grouplock(struct inode *inode, struct file *file, unsigned long arg)
 {
@@ -2233,7 +2232,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case LL_IOC_LOV_GETSTRIPE:
-		return ll_lov_getstripe(inode, arg);
+		return ll_file_getstripe(inode,
+					 (struct lov_user_md __user *)arg);
 	case FSFILT_IOC_FIEMAP:
 		return ll_ioctl_fiemap(inode, arg);
 	case FSFILT_IOC_GETFLAGS:
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 43d1a3f..ec40cf2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -556,6 +556,8 @@ struct lov_lock_link *lov_lock_link_find(const struct lu_env *env,
 					 struct lovsub_lock *sub);
 struct lov_io_sub *lov_page_subio(const struct lu_env *env, struct lov_io *lio,
 				  const struct cl_page_slice *slice);
+
+struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
 int lov_page_stripe(const struct cl_page *page);
 
 #define lov_foreach_target(lov, var)		    \
@@ -747,6 +749,10 @@ static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov)
 	return &lov->u.raid0;
 }
 
+/* lov_pack.c */
+int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
+		  struct lov_user_md __user *lump);
+
 /** @} lov */
 
 #endif
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 0e5fc2e..07e5ede 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -190,8 +190,6 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmm,
 	       struct lov_stripe_md *lsm);
 int lov_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
 		 struct lov_mds_md *lmm, int lmm_bytes);
-int lov_getstripe(struct obd_export *exp,
-		  struct lov_stripe_md *lsm, struct lov_user_md __user *lump);
 int lov_alloc_memmd(struct lov_stripe_md **lsmp, __u16 stripe_count,
 		    int pattern, int magic);
 int lov_free_memmd(struct lov_stripe_md **lsmp);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9ab3033..b23016f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1299,9 +1299,6 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		obd_ioctl_freedata(buf, len);
 		break;
 	}
-	case LL_IOC_LOV_GETSTRIPE:
-		rc = lov_getstripe(exp, karg, uarg);
-		break;
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl = karg;
 		struct lov_tgt_desc *tgt = NULL;
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 4f766e0..01f95a9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -75,6 +75,13 @@ struct lov_layout_operations {
 
 static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov);
 
+void lov_lsm_put(struct cl_object *unused, struct lov_stripe_md *lsm)
+{
+	if (lsm)
+		lov_free_memmd(&lsm);
+}
+EXPORT_SYMBOL(lov_lsm_put);
+
 /*****************************************************************************
  *
  * Lov object layout operations.
@@ -904,13 +911,30 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
 				    io);
 }
 
+static int lov_object_getstripe(const struct lu_env *env, struct cl_object *obj,
+				struct lov_user_md __user *lum)
+{
+	struct lov_object *lov = cl2lov(obj);
+	struct lov_stripe_md *lsm;
+	int rc = 0;
+
+	lsm = lov_lsm_addref(lov);
+	if (!lsm)
+		return -ENODATA;
+
+	rc = lov_getstripe(cl2lov(obj), lsm, lum);
+	lov_lsm_put(obj, lsm);
+	return rc;
+}
+
 static const struct cl_object_operations lov_ops = {
 	.coo_page_init = lov_page_init,
 	.coo_lock_init = lov_lock_init,
 	.coo_io_init   = lov_io_init,
 	.coo_attr_get  = lov_attr_get,
 	.coo_attr_set  = lov_attr_set,
-	.coo_conf_set  = lov_conf_set
+	.coo_conf_set  = lov_conf_set,
+	.coo_getstripe = lov_object_getstripe
 };
 
 static const struct lu_object_operations lov_lu_obj_ops = {
@@ -947,7 +971,7 @@ struct lu_object *lov_object_alloc(const struct lu_env *env,
 	return obj;
 }
 
-static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
+struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 {
 	struct lov_stripe_md *lsm = NULL;
 
@@ -978,13 +1002,6 @@ struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
 }
 EXPORT_SYMBOL(lov_lsm_get);
 
-void lov_lsm_put(struct cl_object *unused, struct lov_stripe_md *lsm)
-{
-	if (lsm)
-		lov_free_memmd(&lsm);
-}
-EXPORT_SYMBOL(lov_lsm_put);
-
 int lov_read_and_clear_async_rc(struct cl_object *clob)
 {
 	struct lu_object *luobj;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 595cf16..be6e985 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -45,6 +45,7 @@
 #include "../include/lustre/lustre_user.h"
 
 #include "lov_internal.h"
+#include "lov_cl_internal.h"
 
 void lov_dump_lmm_common(int level, void *lmmp)
 {
@@ -104,11 +105,9 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
  *     LOVs properly.  For now lov_mds_md_size() just assumes one u64
  *     per stripe.
  */
-int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
-	       struct lov_stripe_md *lsm)
+int lov_obd_packmd(struct lov_obd *lov, struct lov_mds_md **lmmp,
+		   struct lov_stripe_md *lsm)
 {
-	struct obd_device *obd = class_exp2obd(exp);
-	struct lov_obd *lov = &obd->u.lov;
 	struct lov_mds_md_v1 *lmmv1;
 	struct lov_mds_md_v3 *lmmv3;
 	__u16 stripe_count;
@@ -220,6 +219,15 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 	return lmm_size;
 }
 
+int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
+	       struct lov_stripe_md *lsm)
+{
+	struct obd_device *obd = class_exp2obd(exp);
+	struct lov_obd *lov = &obd->u.lov;
+
+	return lov_obd_packmd(lov, lmmp, lsm);
+}
+
 /* Find the max stripecount we should use */
 __u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
 {
@@ -367,16 +375,17 @@ int lov_unpackmd(struct obd_export *exp,  struct lov_stripe_md **lsmp,
  * the maximum number of OST indices which will fit in the user buffer.
  * lmm_magic must be LOV_USER_MAGIC.
  */
-int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
+int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		  struct lov_user_md __user *lump)
 {
 	/*
 	 * XXX huge struct allocated on stack.
 	 */
 	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
+	struct lov_obd *lov;
 	struct lov_user_md_v3 lum;
 	struct lov_mds_md *lmmk = NULL;
-	int rc, lmm_size;
+	int rc, lmmk_size, lmm_size;
 	int lum_size;
 	mm_segment_t seg;
 
@@ -396,13 +405,13 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 	lum_size = sizeof(struct lov_user_md_v1);
 	if (copy_from_user(&lum, lump, lum_size)) {
 		rc = -EFAULT;
-		goto out_set;
+		goto out;
 	}
 	if (lum.lmm_magic != LOV_USER_MAGIC_V1 &&
 	    lum.lmm_magic != LOV_USER_MAGIC_V3 &&
 	    lum.lmm_magic != LOV_USER_MAGIC_SPECIFIC) {
 		rc = -EINVAL;
-		goto out_set;
+		goto out;
 	}
 
 	if (lum.lmm_stripe_count &&
@@ -411,11 +420,13 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 		lum.lmm_stripe_count = lsm->lsm_stripe_count;
 		rc = copy_to_user(lump, &lum, lum_size);
 		rc = -EOVERFLOW;
-		goto out_set;
+		goto out;
 	}
-	rc = lov_packmd(exp, &lmmk, lsm);
+	lov = lu2lov_dev(obj->lo_cl.co_lu.lo_dev)->ld_lov;
+	rc = lov_obd_packmd(lov, &lmmk, lsm);
 	if (rc < 0)
-		goto out_set;
+		goto out;
+	lmmk_size = rc;
 	lmm_size = rc;
 	rc = 0;
 
@@ -451,7 +462,7 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 		lmm_size = lum_size;
 	} else if (lum.lmm_stripe_count < lmmk->lmm_stripe_count) {
 		rc = -EOVERFLOW;
-		goto out_set;
+		goto out_free;
 	}
 	/*
 	 * Have a difference between lov_mds_md & lov_user_md.
@@ -464,8 +475,9 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 	if (copy_to_user(lump, lmmk, lmm_size))
 		rc = -EFAULT;
 
-	obd_free_diskmd(exp, &lmmk);
-out_set:
+out_free:
+	kfree(lmmk);
+out:
 	set_fs(seg);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index bd85455..ef5b1aa 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -321,6 +321,27 @@ int cl_object_prune(const struct lu_env *env, struct cl_object *obj)
 EXPORT_SYMBOL(cl_object_prune);
 
 /**
+ * Get stripe information of this object.
+ */
+int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
+			struct lov_user_md __user *uarg)
+{
+	struct lu_object_header *top;
+	int result = 0;
+
+	top = obj->co_lu.lo_header;
+	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
+		if (obj->co_ops->coo_getstripe) {
+			result = obj->co_ops->coo_getstripe(env, obj, uarg);
+			if (result)
+			break;
+		}
+	}
+	return result;
+}
+EXPORT_SYMBOL(cl_object_getstripe);
+
+/**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
  *
-- 
1.7.1
