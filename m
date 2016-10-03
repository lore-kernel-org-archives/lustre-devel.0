From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:21 -0400
Subject: [lustre-devel] [PATCH 25/41] staging: lustre: lov: add
	cl_object_layout_get()
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add cl_object_layout_get() to return the layout and generation of an
object. Replace some direct accesses to object LSM with calls to this
function.

In ll_getxattr() factor out the LOV xattr specific handling into a new
function ll_getxattr_lov() which calls cl_object_layout_get(). In
ll_listxattr() call ll_getxattr_lov() to determine if a lustre.lov
xattr should be emitted.  Add lov_lsm_pack() to generate LOV xattrs
from a LSM.

Remove the unused functions ccc_inode_lsm_{get,put}() and
lov_lsm_get().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/13680
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   27 +++
 .../lustre/lustre/include/lustre/lustre_user.h     |    3 +
 drivers/staging/lustre/lustre/llite/file.c         |  149 +++++++------
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   19 --
 .../staging/lustre/lustre/llite/llite_internal.h   |    5 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   33 +++-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |   13 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    4 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  234 ++++++++++----------
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 +
 drivers/staging/lustre/lustre/lov/lov_object.c     |   51 +++--
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   99 +++++----
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   14 ++
 13 files changed, 364 insertions(+), 289 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index e46a510..b80539d 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -301,6 +301,26 @@ enum {
 	OBJECT_CONF_WAIT = 2
 };
 
+enum {
+	CL_LAYOUT_GEN_NONE	= (u32)-2,	/* layout lock was cancelled */
+	CL_LAYOUT_GEN_EMPTY	= (u32)-1,	/* for empty layout */
+};
+
+struct cl_layout {
+	/** the buffer to return the layout in lov_mds_md format. */
+	struct lu_buf	cl_buf;
+	/** size of layout in lov_mds_md format. */
+	size_t		cl_size;
+	/** Layout generation. */
+	u32		cl_layout_gen;
+	/**
+	 * True if this is a released file.
+	 * Temporarily added for released file truncate in ll_setattr_raw().
+	 * It will be removed later. -Jinshan
+	 */
+	bool		cl_is_released;
+};
+
 /**
  * Operations implemented for each cl object layer.
  *
@@ -406,6 +426,11 @@ struct cl_object_operations {
 	int (*coo_fiemap)(const struct lu_env *env, struct cl_object *obj,
 			  struct ll_fiemap_info_key *fmkey,
 			  struct fiemap *fiemap, size_t *buflen);
+	/**
+	 * Get layout and generation of the object.
+	 */
+	int (*coo_layout_get)(const struct lu_env *env, struct cl_object *obj,
+			      struct cl_layout *layout);
 };
 
 /**
@@ -2200,6 +2225,8 @@ int  cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		     struct ll_fiemap_info_key *fmkey, struct fiemap *fiemap,
 		     size_t *buflen);
+int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_layout *cl);
 
 /**
  * Returns true, iff \a o0 and \a o1 are slices of the same object.
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 043fc1c..80fecba 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -346,6 +346,9 @@ enum ll_lease_type {
 #define LOV_ALL_STRIPES       0xffff /* only valid for directories */
 #define LOV_V1_INSANE_STRIPE_COUNT 65532 /* maximum stripe count bz13933 */
 
+#define XATTR_LUSTRE_PREFIX	"lustre."
+#define XATTR_LUSTRE_LOV	"lustre.lov"
+
 #define lov_user_ost_data lov_user_ost_data_v1
 struct lov_user_ost_data_v1 {     /* per-stripe data structure */
 	struct ost_id l_ost_oi;	  /* OST object ID */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 8fa65a5..73ea446 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3187,35 +3187,51 @@ ll_iocontrol_call(struct inode *inode, struct file *file,
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct cl_object *obj = lli->lli_clob;
 	struct cl_env_nest nest;
 	struct lu_env *env;
-	int result;
+	int rc;
 
-	if (!lli->lli_clob)
+	if (!obj)
 		return 0;
 
 	env = cl_env_nested_get(&nest);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	result = cl_conf_set(env, lli->lli_clob, conf);
-	cl_env_nested_put(&nest, env);
+	rc = cl_conf_set(env, obj, conf);
+	if (rc < 0)
+		goto out;
 
 	if (conf->coc_opc == OBJECT_CONF_SET) {
 		struct ldlm_lock *lock = conf->coc_lock;
+		struct cl_layout cl = {
+			.cl_layout_gen = 0,
+		};
 
 		LASSERT(lock);
 		LASSERT(ldlm_has_layout(lock));
-		if (result == 0) {
-			/* it can only be allowed to match after layout is
-			 * applied to inode otherwise false layout would be
-			 * seen. Applying layout should happen before dropping
-			 * the intent lock.
-			 */
-			ldlm_lock_allow_match(lock);
-		}
+
+		/* it can only be allowed to match after layout is
+		 * applied to inode otherwise false layout would be
+		 * seen. Applying layout should happen before dropping
+		 * the intent lock.
+		 */
+		ldlm_lock_allow_match(lock);
+
+		rc = cl_object_layout_get(env, obj, &cl);
+		if (rc < 0)
+			goto out;
+
+		CDEBUG(D_VFSTRACE, DFID ": layout version change: %u -> %u\n",
+		       PFID(&lli->lli_fid), ll_layout_version_get(lli),
+		       cl.cl_layout_gen);
+		ll_layout_version_set(lli, cl.cl_layout_gen);
+		lli->lli_has_smd = lsm_has_objects(conf->u.coc_md->lsm);
 	}
-	return result;
+out:
+	cl_env_nested_put(&nest, env);
+	return rc;
 }
 
 /* Fetch layout from MDT with getxattr request, if it's not ready yet */
@@ -3294,7 +3310,7 @@ out:
  * in this function.
  */
 static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
-			      struct inode *inode, __u32 *gen, bool reconf)
+			      struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info    *sbi = ll_i2sbi(inode);
@@ -3311,8 +3327,8 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	LASSERT(lock);
 	LASSERT(ldlm_has_layout(lock));
 
-	LDLM_DEBUG(lock, "File "DFID"(%p) being reconfigured: %d",
-		   PFID(&lli->lli_fid), inode, reconf);
+	LDLM_DEBUG(lock, "File " DFID "(%p) being reconfigured",
+		   PFID(&lli->lli_fid), inode);
 
 	/* in case this is a caching lock and reinstate with new inode */
 	md_set_lock_data(sbi->ll_md_exp, lockh, inode, NULL);
@@ -3323,15 +3339,8 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	/* checking lvb_ready is racy but this is okay. The worst case is
 	 * that multi processes may configure the file on the same time.
 	 */
-	if (lvb_ready || !reconf) {
-		rc = -ENODATA;
-		if (lvb_ready) {
-			/* layout_gen must be valid if layout lock is not
-			 * cancelled and stripe has already set
-			 */
-			*gen = ll_layout_version_get(lli);
-			rc = 0;
-		}
+	if (lvb_ready) {
+		rc = 0;
 		goto out;
 	}
 
@@ -3347,19 +3356,17 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	if (lock->l_lvb_data) {
 		rc = obd_unpackmd(sbi->ll_dt_exp, &md.lsm,
 				  lock->l_lvb_data, lock->l_lvb_len);
-		if (rc >= 0) {
-			*gen = LL_LAYOUT_GEN_EMPTY;
-			if (md.lsm)
-				*gen = md.lsm->lsm_layout_gen;
-			rc = 0;
-		} else {
+		if (rc < 0) {
 			CERROR("%s: file " DFID " unpackmd error: %d\n",
 			       ll_get_fsname(inode->i_sb, NULL, 0),
 			       PFID(&lli->lli_fid), rc);
+			goto out;
 		}
+
+		LASSERTF(md.lsm, "lvb_data = %p, lvb_len = %u\n",
+			 lock->l_lvb_data, lock->l_lvb_len);
+		rc = 0;
 	}
-	if (rc < 0)
-		goto out;
 
 	/* set layout to file. Unlikely this will fail as old layout was
 	 * surely eliminated
@@ -3401,20 +3408,7 @@ out:
 	return rc;
 }
 
-/**
- * This function checks if there exists a LAYOUT lock on the client side,
- * or enqueues it if it doesn't have one in cache.
- *
- * This function will not hold layout lock so it may be revoked any time after
- * this function returns. Any operations depend on layout should be redone
- * in that case.
- *
- * This function should be called before lov_io_init() to get an uptodate
- * layout version, the caller should save the version number and after IO
- * is finished, this function should be called again to verify that layout
- * is not changed during IO time.
- */
-int ll_layout_refresh(struct inode *inode, __u32 *gen)
+static int ll_layout_refresh_locked(struct inode *inode)
 {
 	struct ll_inode_info  *lli = ll_i2info(inode);
 	struct ll_sb_info     *sbi = ll_i2sbi(inode);
@@ -3430,17 +3424,6 @@ int ll_layout_refresh(struct inode *inode, __u32 *gen)
 	};
 	int rc;
 
-	*gen = ll_layout_version_get(lli);
-	if (!(sbi->ll_flags & LL_SBI_LAYOUT_LOCK) || *gen != LL_LAYOUT_GEN_NONE)
-		return 0;
-
-	/* sanity checks */
-	LASSERT(fid_is_sane(ll_inode2fid(inode)));
-	LASSERT(S_ISREG(inode->i_mode));
-
-	/* take layout lock mutex to enqueue layout lock exclusively. */
-	mutex_lock(&lli->lli_layout_mutex);
-
 again:
 	/* mostly layout lock is caching on the local side, so try to match
 	 * it before grabbing layout lock mutex.
@@ -3448,20 +3431,16 @@ again:
 	mode = ll_take_md_lock(inode, MDS_INODELOCK_LAYOUT, &lockh, 0,
 			       LCK_CR | LCK_CW | LCK_PR | LCK_PW);
 	if (mode != 0) { /* hit cached lock */
-		rc = ll_layout_lock_set(&lockh, mode, inode, gen, true);
+		rc = ll_layout_lock_set(&lockh, mode, inode);
 		if (rc == -EAGAIN)
 			goto again;
-
-		mutex_unlock(&lli->lli_layout_mutex);
 		return rc;
 	}
 
 	op_data = ll_prep_md_op_data(NULL, inode, inode, NULL,
 				     0, 0, LUSTRE_OPC_ANY, NULL);
-	if (IS_ERR(op_data)) {
-		mutex_unlock(&lli->lli_layout_mutex);
+	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
-	}
 
 	/* have to enqueue one */
 	memset(&it, 0, sizeof(it));
@@ -3485,10 +3464,50 @@ again:
 	if (rc == 0) {
 		/* set lock data in case this is a new lock */
 		ll_set_lock_data(sbi->ll_md_exp, inode, &it, NULL);
-		rc = ll_layout_lock_set(&lockh, mode, inode, gen, true);
+		rc = ll_layout_lock_set(&lockh, mode, inode);
 		if (rc == -EAGAIN)
 			goto again;
 	}
+
+	return rc;
+}
+
+/**
+ * This function checks if there exists a LAYOUT lock on the client side,
+ * or enqueues it if it doesn't have one in cache.
+ *
+ * This function will not hold layout lock so it may be revoked any time after
+ * this function returns. Any operations depend on layout should be redone
+ * in that case.
+ *
+ * This function should be called before lov_io_init() to get an uptodate
+ * layout version, the caller should save the version number and after IO
+ * is finished, this function should be called again to verify that layout
+ * is not changed during IO time.
+ */
+int ll_layout_refresh(struct inode *inode, __u32 *gen)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	int rc;
+
+	*gen = ll_layout_version_get(lli);
+	if (!(sbi->ll_flags & LL_SBI_LAYOUT_LOCK) || *gen != CL_LAYOUT_GEN_NONE)
+		return 0;
+
+	/* sanity checks */
+	LASSERT(fid_is_sane(ll_inode2fid(inode)));
+	LASSERT(S_ISREG(inode->i_mode));
+
+	/* take layout lock mutex to enqueue layout lock exclusively. */
+	mutex_lock(&lli->lli_layout_mutex);
+
+	rc = ll_layout_refresh_locked(inode);
+	if (rc < 0)
+		goto out;
+
+	*gen = ll_layout_version_get(lli);
+out:
 	mutex_unlock(&lli->lli_layout_mutex);
 
 	return rc;
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 64f4aed..bd98ec2 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -304,22 +304,3 @@ __u32 cl_fid_build_gen(const struct lu_fid *fid)
 	gen = fid_flatten(fid) >> 32;
 	return gen;
 }
-
-/* lsm is unreliable after hsm implementation as layout can be changed at
- * any time. This is only to support old, non-clio-ized interfaces. It will
- * cause deadlock if clio operations are called with this extra layout refcount
- * because in case the layout changed during the IO, ll_layout_refresh() will
- * have to wait for the refcount to become zero to destroy the older layout.
- *
- * Notice that the lsm returned by this function may not be valid unless called
- * inside layout lock - MDS_INODELOCK_LAYOUT.
- */
-struct lov_stripe_md *ccc_inode_lsm_get(struct inode *inode)
-{
-	return lov_lsm_get(ll_i2info(inode)->lli_clob);
-}
-
-inline void ccc_inode_lsm_put(struct inode *inode, struct lov_stripe_md *lsm)
-{
-	lov_lsm_put(ll_i2info(inode)->lli_clob, lsm);
-}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index e249895..c89e1b8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1327,11 +1327,6 @@ static inline void d_lustre_revalidate(struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 }
 
-enum {
-	LL_LAYOUT_GEN_NONE  = ((__u32)-2),	/* layout lock was cancelled */
-	LL_LAYOUT_GEN_EMPTY = ((__u32)-1)	/* for empty layout */
-};
-
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf);
 int ll_layout_refresh(struct inode *inode, __u32 *gen);
 int ll_layout_restore(struct inode *inode, loff_t start, __u64 length);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6270301..4b53119 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -800,7 +800,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 	spin_lock_init(&lli->lli_agl_lock);
 	lli->lli_has_smd = false;
 	spin_lock_init(&lli->lli_layout_lock);
-	ll_layout_version_set(lli, LL_LAYOUT_GEN_NONE);
+	ll_layout_version_set(lli, CL_LAYOUT_GEN_NONE);
 	lli->lli_clob = NULL;
 
 	init_rwsem(&lli->lli_xattrs_list_rwsem);
@@ -1441,14 +1441,33 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	 * but other attributes must be set
 	 */
 	if (S_ISREG(inode->i_mode)) {
-		struct lov_stripe_md *lsm;
+		struct cl_layout cl = {
+			.cl_is_released = false,
+		};
+		struct lu_env *env;
+		int refcheck;
 		__u32 gen;
 
-		ll_layout_refresh(inode, &gen);
-		lsm = ccc_inode_lsm_get(inode);
-		if (lsm && lsm->lsm_pattern & LOV_PATTERN_F_RELEASED)
-			file_is_released = true;
-		ccc_inode_lsm_put(inode, lsm);
+		rc = ll_layout_refresh(inode, &gen);
+		if (rc < 0)
+			goto out;
+
+		/*
+		 * XXX: the only place we need to know the layout type,
+		 * this will be removed by a later patch. -Jinshan
+		 */
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env)) {
+			rc = PTR_ERR(env);
+			goto out;
+		}
+
+		rc = cl_object_layout_get(env, lli->lli_clob, &cl);
+		cl_env_put(env, &refcheck);
+		if (rc < 0)
+			goto out;
+
+		file_is_released = cl.cl_is_released;
 
 		if (!hsm_import && attr->ia_valid & ATTR_SIZE) {
 			if (file_is_released) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 47d035e..a025b35 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -323,21 +323,8 @@ static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
 # define CLOBINVRNT(env, clob, expr)					\
 	((void)sizeof(env), (void)sizeof(clob), (void)sizeof(!!(expr)))
 
-/**
- * New interfaces to get and put lov_stripe_md from lov layer. This violates
- * layering because lov_stripe_md is supposed to be a private data in lov.
- *
- * NB: If you find you have to use these interfaces for your new code, please
- * think about it again. These interfaces may be removed in the future for
- * better layering.
- */
-struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj);
-void lov_lsm_put(struct cl_object *clobj, struct lov_stripe_md *lsm);
 int lov_read_and_clear_async_rc(struct cl_object *clob);
 
-struct lov_stripe_md *ccc_inode_lsm_get(struct inode *inode);
-void ccc_inode_lsm_put(struct inode *inode, struct lov_stripe_md *lsm);
-
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 3214885..420a649 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -132,7 +132,7 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 		CDEBUG(D_VFSTRACE, DFID ": losing layout lock\n",
 		       PFID(&lli->lli_fid));
 
-		ll_layout_version_set(lli, LL_LAYOUT_GEN_NONE);
+		ll_layout_version_set(lli, CL_LAYOUT_GEN_NONE);
 
 		/* Clean up page mmap for this inode.
 		 * The reason for us to do this is that if the page has
@@ -164,7 +164,7 @@ static int vvp_conf_set(const struct lu_env *env, struct cl_object *obj,
 		       PFID(&lli->lli_fid), lli->lli_layout_gen);
 
 		lli->lli_has_smd = false;
-		ll_layout_version_set(lli, LL_LAYOUT_GEN_EMPTY);
+		ll_layout_version_set(lli, CL_LAYOUT_GEN_EMPTY);
 	}
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index e070adb..b8b5c32 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -353,80 +353,99 @@ static int ll_xattr_get_common(const struct xattr_handler *handler,
 			     OBD_MD_FLXATTR);
 }
 
-static int ll_xattr_get(const struct xattr_handler *handler,
-			struct dentry *dentry, struct inode *inode,
-			const char *name, void *buffer, size_t size)
+static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 {
-	LASSERT(inode);
-	LASSERT(name);
+	ssize_t rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
-	       PFID(ll_inode2fid(inode)), inode, name);
-
-	if (!strcmp(name, "lov")) {
-		struct lov_stripe_md *lsm;
-		struct lov_user_md *lump;
-		struct lov_mds_md *lmm = NULL;
-		struct ptlrpc_request *request = NULL;
-		int rc = 0, lmmsize = 0;
+	if (S_ISREG(inode->i_mode)) {
+		struct cl_object *obj = ll_i2info(inode)->lli_clob;
+		struct cl_layout cl = {
+			.cl_buf.lb_buf = buf,
+			.cl_buf.lb_len = buf_size,
+		};
+		struct lu_env *env;
+		int refcheck;
+
+		if (!obj)
+			return -ENODATA;
 
-		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
+		env = cl_env_get(&refcheck);
+		if (IS_ERR(env))
+			return PTR_ERR(env);
 
-		if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
-			return -ENODATA;
+		rc = cl_object_layout_get(env, obj, &cl);
+		if (rc < 0)
+			goto out_env;
 
-		lsm = ccc_inode_lsm_get(inode);
-		if (!lsm) {
-			if (S_ISDIR(inode->i_mode)) {
-				rc = ll_dir_getstripe(inode, (void **)&lmm,
-						      &lmmsize, &request, 0);
-			} else {
-				rc = -ENODATA;
-			}
-		} else {
-			/* LSM is present already after lookup/getattr call.
-			 * we need to grab layout lock once it is implemented
-			 */
-			rc = obd_packmd(ll_i2dtexp(inode), &lmm, lsm);
-			lmmsize = rc;
+		if (!cl.cl_size) {
+			rc = -ENODATA;
+			goto out_env;
 		}
-		ccc_inode_lsm_put(inode, lsm);
 
+		rc = cl.cl_size;
+
+		if (!buf_size)
+			goto out_env;
+
+		LASSERT(buf && rc <= buf_size);
+
+		/*
+		 * Do not return layout gen for getxattr() since
+		 * otherwise it would confuse tar --xattr by
+		 * recognizing layout gen as stripe offset when the
+		 * file is restored. See LU-2809.
+		 */
+		((struct lov_mds_md *)buf)->lmm_layout_gen = 0;
+out_env:
+		cl_env_put(env, &refcheck);
+
+		return rc;
+	} else if (S_ISDIR(inode->i_mode)) {
+		struct ptlrpc_request *req = NULL;
+		struct lov_mds_md *lmm = NULL;
+		int lmm_size = 0;
+
+		rc = ll_dir_getstripe(inode, (void **)&lmm, &lmm_size,
+				      &req, 0);
 		if (rc < 0)
-			goto out;
+			goto out_req;
 
-		if (size == 0) {
-			/* used to call ll_get_max_mdsize() forward to get
-			 * the maximum buffer size, while some apps (such as
-			 * rsync 3.0.x) care much about the exact xattr value
-			 * size
-			 */
-			rc = lmmsize;
-			goto out;
+		if (!buf_size) {
+			rc = lmm_size;
+			goto out_req;
 		}
 
-		if (size < lmmsize) {
-			CERROR("server bug: replied size %d > %d for %pd (%s)\n",
-			       lmmsize, (int)size, dentry, name);
+		if (buf_size < lmm_size) {
 			rc = -ERANGE;
-			goto out;
+			goto out_req;
 		}
 
-		lump = buffer;
-		memcpy(lump, lmm, lmmsize);
-		/* do not return layout gen for getxattr otherwise it would
-		 * confuse tar --xattr by recognizing layout gen as stripe
-		 * offset when the file is restored. See LU-2809.
-		 */
-		lump->lmm_layout_gen = 0;
+		memcpy(buf, lmm, lmm_size);
+		rc = lmm_size;
+out_req:
+		if (req)
+			ptlrpc_req_finished(req);
 
-		rc = lmmsize;
-out:
-		if (request)
-			ptlrpc_req_finished(request);
-		else if (lmm)
-			obd_free_diskmd(ll_i2dtexp(inode), &lmm);
 		return rc;
+	} else {
+		return -ENODATA;
+	}
+}
+
+static int ll_xattr_get(const struct xattr_handler *handler,
+			struct dentry *dentry, struct inode *inode,
+			const char *name, void *buffer, size_t size)
+{
+	LASSERT(inode);
+	LASSERT(name);
+
+	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), xattr %s\n",
+	       PFID(ll_inode2fid(inode)), inode, name);
+
+	if (!strcmp(name, "lov")) {
+		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
+
+		return ll_getxattr_lov(inode, buffer, size);
 	}
 
 	return ll_xattr_get_common(handler, dentry, inode, name, buffer, size);
@@ -435,10 +454,10 @@ out:
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 {
 	struct inode *inode = d_inode(dentry);
-	int rc = 0, rc2 = 0;
-	struct lov_mds_md *lmm = NULL;
-	struct ptlrpc_request *request = NULL;
-	int lmmsize;
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	char *xattr_name;
+	ssize_t rc, rc2;
+	size_t len, rem;
 
 	LASSERT(inode);
 
@@ -450,65 +469,48 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 	rc = ll_xattr_list(inode, NULL, XATTR_OTHER_T, buffer, size,
 			   OBD_MD_FLXATTRLS);
 	if (rc < 0)
-		goto out;
-
-	if (buffer) {
-		struct ll_sb_info *sbi = ll_i2sbi(inode);
-		char *xattr_name = buffer;
-		int xlen, rem = rc;
-
-		while (rem > 0) {
-			xlen = strnlen(xattr_name, rem - 1) + 1;
-			rem -= xlen;
-			if (xattr_type_filter(sbi,
-					get_xattr_type(xattr_name)) == 0) {
-				/* skip OK xattr type
-				 * leave it in buffer
-				 */
-				xattr_name += xlen;
-				continue;
-			}
-			/* move up remaining xattrs in buffer
-			 * removing the xattr that is not OK
-			 */
-			memmove(xattr_name, xattr_name + xlen, rem);
-			rc -= xlen;
+		return rc;
+	/*
+	 * If we're being called to get the size of the xattr list
+	 * (buf_size == 0) then just assume that a lustre.lov xattr
+	 * exists.
+	 */
+	if (!size)
+		return rc + sizeof(XATTR_LUSTRE_LOV);
+
+	xattr_name = buffer;
+	rem = rc;
+
+	while (rem > 0) {
+		len = strnlen(xattr_name, rem - 1) + 1;
+		rem -= len;
+		if (!xattr_type_filter(sbi, get_xattr_type(xattr_name))) {
+			/* Skip OK xattr type leave it in buffer */
+			xattr_name += len;
+			continue;
 		}
-	}
-	if (S_ISREG(inode->i_mode)) {
-		if (!ll_i2info(inode)->lli_has_smd)
-			rc2 = -1;
-	} else if (S_ISDIR(inode->i_mode)) {
-		rc2 = ll_dir_getstripe(inode, (void **)&lmm, &lmmsize,
-				       &request, 0);
+
+		/*
+		 * Move up remaining xattrs in buffer
+		 * removing the xattr that is not OK
+		 */
+		memmove(xattr_name, xattr_name + len, rem);
+		rc -= len;
 	}
 
-	if (rc2 < 0) {
-		rc2 = 0;
-		goto out;
-	} else if (S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)) {
-		const int prefix_len = sizeof(XATTR_LUSTRE_PREFIX) - 1;
-		const size_t name_len   = sizeof("lov") - 1;
-		const size_t total_len  = prefix_len + name_len + 1;
-
-		if (((rc + total_len) > size) && buffer) {
-			ptlrpc_req_finished(request);
-			return -ERANGE;
-		}
+	rc2 = ll_getxattr_lov(inode, NULL, 0);
+	if (rc2 == -ENODATA)
+		return rc;
 
-		if (buffer) {
-			buffer += rc;
-			memcpy(buffer, XATTR_LUSTRE_PREFIX, prefix_len);
-			memcpy(buffer + prefix_len, "lov", name_len);
-			buffer[prefix_len + name_len] = '\0';
-		}
-		rc2 = total_len;
-	}
-out:
-	ptlrpc_req_finished(request);
-	rc = rc + rc2;
+	if (rc2 < 0)
+		return rc2;
 
-	return rc;
+	if (size < rc + sizeof(XATTR_LUSTRE_LOV))
+		return -ERANGE;
+
+	memcpy(buffer + rc, XATTR_LUSTRE_LOV, sizeof(XATTR_LUSTRE_LOV));
+
+	return rc + sizeof(XATTR_LUSTRE_LOV);
 }
 
 static const struct xattr_handler ll_user_xattr_handler = {
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index fffc18c..60397a2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -176,6 +176,8 @@ int lov_del_target(struct obd_device *obd, __u32 index,
 		   struct obd_uuid *uuidp, int gen);
 
 /* lov_pack.c */
+ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
+		     size_t buf_size);
 int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmm,
 	       struct lov_stripe_md *lsm);
 int lov_unpackmd(struct obd_export *exp, struct lov_stripe_md **lsmp,
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 07bef44..d39724a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -75,12 +75,11 @@ struct lov_layout_operations {
 
 static int lov_layout_wait(const struct lu_env *env, struct lov_object *lov);
 
-void lov_lsm_put(struct cl_object *unused, struct lov_stripe_md *lsm)
+static void lov_lsm_put(struct lov_stripe_md *lsm)
 {
 	if (lsm)
 		lov_free_memmd(&lsm);
 }
-EXPORT_SYMBOL(lov_lsm_put);
 
 /*****************************************************************************
  *
@@ -1408,7 +1407,7 @@ obj_put:
 		cl_object_put(env, subobj);
 out:
 	kvfree(fm_local);
-	lov_lsm_put(obj, lsm);
+	lov_lsm_put(lsm);
 	return rc;
 }
 
@@ -1424,10 +1423,37 @@ static int lov_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 		return -ENODATA;
 
 	rc = lov_getstripe(cl2lov(obj), lsm, lum);
-	lov_lsm_put(obj, lsm);
+	lov_lsm_put(lsm);
 	return rc;
 }
 
+static int lov_object_layout_get(const struct lu_env *env,
+				 struct cl_object *obj,
+				 struct cl_layout *cl)
+{
+	struct lov_object *lov = cl2lov(obj);
+	struct lov_stripe_md *lsm = lov_lsm_addref(lov);
+	struct lu_buf *buf = &cl->cl_buf;
+	ssize_t rc;
+
+	if (!lsm) {
+		cl->cl_size = 0;
+		cl->cl_layout_gen = CL_LAYOUT_GEN_EMPTY;
+		cl->cl_is_released = false;
+
+		return 0;
+	}
+
+	cl->cl_size = lov_mds_md_size(lsm->lsm_stripe_count, lsm->lsm_magic);
+	cl->cl_layout_gen = lsm->lsm_layout_gen;
+	cl->cl_is_released = lsm_is_released(lsm);
+
+	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
+	lov_lsm_put(lsm);
+
+	return rc < 0 ? rc : 0;
+}
+
 static const struct cl_object_operations lov_ops = {
 	.coo_page_init = lov_page_init,
 	.coo_lock_init = lov_lock_init,
@@ -1436,6 +1462,7 @@ static const struct cl_object_operations lov_ops = {
 	.coo_attr_update = lov_attr_update,
 	.coo_conf_set  = lov_conf_set,
 	.coo_getstripe = lov_object_getstripe,
+	.coo_layout_get	 = lov_object_layout_get,
 	.coo_fiemap	 = lov_object_fiemap,
 };
 
@@ -1488,22 +1515,6 @@ struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 	return lsm;
 }
 
-struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
-{
-	struct lu_object *luobj;
-	struct lov_stripe_md *lsm = NULL;
-
-	if (!clobj)
-		return NULL;
-
-	luobj = lu_object_locate(&cl_object_header(clobj)->coh_lu,
-				 &lov_device_type);
-	if (luobj)
-		lsm = lov_lsm_addref(lu2lov(luobj));
-	return lsm;
-}
-EXPORT_SYMBOL(lov_lsm_get);
-
 int lov_read_and_clear_async_rc(struct cl_object *clob)
 {
 	struct lu_object *luobj;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index be6e985..1156ef9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -97,6 +97,62 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
 			     le16_to_cpu(lmm->lmm_stripe_count));
 }
 
+/**
+ * Pack LOV striping metadata for disk storage format (in little
+ * endian byte order).
+ *
+ * This follows the getxattr() conventions. If \a buf_size is zero
+ * then return the size needed. If \a buf_size is too small then
+ * return -ERANGE. Otherwise return the size of the result.
+ */
+ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
+		     size_t buf_size)
+{
+	struct lov_ost_data_v1 *lmm_objects;
+	struct lov_mds_md_v1 *lmmv1 = buf;
+	struct lov_mds_md_v3 *lmmv3 = buf;
+	size_t lmm_size;
+	unsigned int i;
+
+	lmm_size = lov_mds_md_size(lsm->lsm_stripe_count, lsm->lsm_magic);
+	if (!buf_size)
+		return lmm_size;
+
+	if (buf_size < lmm_size)
+		return -ERANGE;
+
+	/*
+	 * lmmv1 and lmmv3 point to the same struct and have the
+	 * same first fields
+	 */
+	lmmv1->lmm_magic = cpu_to_le32(lsm->lsm_magic);
+	lmm_oi_cpu_to_le(&lmmv1->lmm_oi, &lsm->lsm_oi);
+	lmmv1->lmm_stripe_size = cpu_to_le32(lsm->lsm_stripe_size);
+	lmmv1->lmm_stripe_count = cpu_to_le16(lsm->lsm_stripe_count);
+	lmmv1->lmm_pattern = cpu_to_le32(lsm->lsm_pattern);
+	lmmv1->lmm_layout_gen = cpu_to_le16(lsm->lsm_layout_gen);
+
+	if (lsm->lsm_magic == LOV_MAGIC_V3) {
+		CLASSERT(sizeof(lsm->lsm_pool_name) ==
+			 sizeof(lmmv3->lmm_pool_name));
+		strlcpy(lmmv3->lmm_pool_name, lsm->lsm_pool_name,
+			sizeof(lmmv3->lmm_pool_name));
+		lmm_objects = lmmv3->lmm_objects;
+	} else {
+		lmm_objects = lmmv1->lmm_objects;
+	}
+
+	for (i = 0; i < lsm->lsm_stripe_count; i++) {
+		struct lov_oinfo *loi = lsm->lsm_oinfo[i];
+
+		ostid_cpu_to_le(&loi->loi_oi, &lmm_objects[i].l_ost_oi);
+		lmm_objects[i].l_ost_gen = cpu_to_le32(loi->loi_ost_gen);
+		lmm_objects[i].l_ost_idx = cpu_to_le32(loi->loi_ost_idx);
+	}
+
+	return lmm_size;
+}
+
 /* Pack LOV object metadata for disk storage.  It is packed in LE byte
  * order and is opaque to the networking layer.
  *
@@ -108,13 +164,8 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
 int lov_obd_packmd(struct lov_obd *lov, struct lov_mds_md **lmmp,
 		   struct lov_stripe_md *lsm)
 {
-	struct lov_mds_md_v1 *lmmv1;
-	struct lov_mds_md_v3 *lmmv3;
 	__u16 stripe_count;
-	struct lov_ost_data_v1 *lmm_objects;
 	int lmm_size, lmm_magic;
-	int i;
-	int cplen = 0;
 
 	if (lsm) {
 		lmm_magic = lsm->lsm_magic;
@@ -177,46 +228,10 @@ int lov_obd_packmd(struct lov_obd *lov, struct lov_mds_md **lmmp,
 	CDEBUG(D_INFO, "lov_packmd: LOV_MAGIC 0x%08X, lmm_size = %d\n",
 	       lmm_magic, lmm_size);
 
-	lmmv1 = *lmmp;
-	lmmv3 = (struct lov_mds_md_v3 *)*lmmp;
-	if (lmm_magic == LOV_MAGIC_V3)
-		lmmv3->lmm_magic = cpu_to_le32(LOV_MAGIC_V3);
-	else
-		lmmv1->lmm_magic = cpu_to_le32(LOV_MAGIC_V1);
-
 	if (!lsm)
 		return lmm_size;
 
-	/* lmmv1 and lmmv3 point to the same struct and have the
-	 * same first fields
-	 */
-	lmm_oi_cpu_to_le(&lmmv1->lmm_oi, &lsm->lsm_oi);
-	lmmv1->lmm_stripe_size = cpu_to_le32(lsm->lsm_stripe_size);
-	lmmv1->lmm_stripe_count = cpu_to_le16(stripe_count);
-	lmmv1->lmm_pattern = cpu_to_le32(lsm->lsm_pattern);
-	lmmv1->lmm_layout_gen = cpu_to_le16(lsm->lsm_layout_gen);
-	if (lsm->lsm_magic == LOV_MAGIC_V3) {
-		cplen = strlcpy(lmmv3->lmm_pool_name, lsm->lsm_pool_name,
-				sizeof(lmmv3->lmm_pool_name));
-		if (cplen >= sizeof(lmmv3->lmm_pool_name))
-			return -E2BIG;
-		lmm_objects = lmmv3->lmm_objects;
-	} else {
-		lmm_objects = lmmv1->lmm_objects;
-	}
-
-	for (i = 0; i < stripe_count; i++) {
-		struct lov_oinfo *loi = lsm->lsm_oinfo[i];
-		/* XXX LOV STACKING call down to osc_packmd() to do packing */
-		LASSERTF(ostid_id(&loi->loi_oi) != 0, "lmm_oi "DOSTID
-			 " stripe %u/%u idx %u\n", POSTID(&lmmv1->lmm_oi),
-			 i, stripe_count, loi->loi_ost_idx);
-		ostid_cpu_to_le(&loi->loi_oi, &lmm_objects[i].l_ost_oi);
-		lmm_objects[i].l_ost_gen = cpu_to_le32(loi->loi_ost_gen);
-		lmm_objects[i].l_ost_idx = cpu_to_le32(loi->loi_ost_idx);
-	}
-
-	return lmm_size;
+	return lov_lsm_pack(lsm, *lmmp, lmm_size);
 }
 
 int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 4ad2ee5..dd80b83 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -374,6 +374,20 @@ int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 }
 EXPORT_SYMBOL(cl_object_fiemap);
 
+int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_layout *cl)
+{
+	struct lu_object_header *top = obj->co_lu.lo_header;
+
+	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
+		if (obj->co_ops->coo_layout_get)
+			return obj->co_ops->coo_layout_get(env, obj, cl);
+	}
+
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(cl_object_layout_get);
+
 /**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
-- 
1.7.1
