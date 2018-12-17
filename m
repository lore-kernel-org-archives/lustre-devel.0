From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:30:01 -0500
Subject: [lustre-devel] [PATCH 27/28] lustre: llite: restore
 ll_file_getstripe in ll_lov_setstripe
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

Commit fafe6b4d4a6fa63cedff3bd44e6578009578b3d7 has get rid of
the call to ll_file_getstripe in ll_lov_setstripe.

Add a @size parameter for series of xxx_getstripe interfaces,
indicating the max buffer size that user provides to hold the
stripe information. It is mainly for the ll_lov_setstripe, which
will call ll_file_getstripe to fetch basic stripe inforation.

Add LL_IOC_LOV_SETSTRIPE_NEW/LL_IOC_LOV_GETSTRIPE_NEW ioctl interface
which defines the interface correctly, which could be used in later
Lustre versions.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9367
Reviewed-on: https://review.whamcloud.com/26915
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  2 ++
 drivers/staging/lustre/lustre/include/cl_object.h  |  4 +--
 drivers/staging/lustre/lustre/llite/dir.c          |  5 ++-
 drivers/staging/lustre/lustre/llite/file.c         | 36 +++++++++++++++-------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  5 +--
 drivers/staging/lustre/lustre/lov/lov_object.c     |  4 +--
 drivers/staging/lustre/lustre/lov/lov_pack.c       | 33 ++++++++++++++------
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  5 +--
 8 files changed, 64 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 833a57a..e9451a5 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -227,7 +227,9 @@ struct ost_id {
 #define LL_IOC_SETFLAGS		 _IOW('f', 152, long)
 #define LL_IOC_CLRFLAGS		 _IOW('f', 153, long)
 #define LL_IOC_LOV_SETSTRIPE	    _IOW('f', 154, long)
+#define LL_IOC_LOV_SETSTRIPE_NEW	_IOWR('f', 154, struct lov_user_md)
 #define LL_IOC_LOV_GETSTRIPE	    _IOW('f', 155, long)
+#define LL_IOC_LOV_GETSTRIPE_NEW	_IOR('f', 155, struct lov_user_md)
 #define LL_IOC_LOV_SETEA		_IOW('f', 156, long)
 /*	LL_IOC_RECREATE_OBJ		157 obsolete */
 /*	LL_IOC_RECREATE_FID		158 obsolete */
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index ee71f1c..4f0e8e2 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -390,7 +390,7 @@ struct cl_object_operations {
 	 * Object getstripe method.
 	 */
 	int (*coo_getstripe)(const struct lu_env *env, struct cl_object *obj,
-			     struct lov_user_md __user *lum);
+			     struct lov_user_md __user *lum, size_t size);
 	/**
 	 * Get FIEMAP mapping from the object.
 	 */
@@ -2057,7 +2057,7 @@ int  cl_conf_set(const struct lu_env *env, struct cl_object *obj,
 int cl_object_prune(const struct lu_env *env, struct cl_object *obj);
 void cl_object_kill(const struct lu_env *env, struct cl_object *obj);
 int  cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
-			 struct lov_user_md __user *lum);
+			 struct lov_user_md __user *lum, size_t size);
 int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		     struct ll_fiemap_info_key *fmkey, struct fiemap *fiemap,
 		     size_t *buflen);
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 8fbce96..25cd42ee 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1224,6 +1224,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		return rc;
 	}
+	case LL_IOC_LOV_SETSTRIPE_NEW:
 	case LL_IOC_LOV_SETSTRIPE: {
 		struct lov_user_md_v3 lumv3;
 		struct lov_user_md_v1 *lumv1 = (struct lov_user_md_v1 *)&lumv3;
@@ -1362,6 +1363,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case IOC_OBD_STATFS:
 		return ll_obd_statfs(inode, (void __user *)arg);
 	case LL_IOC_LOV_GETSTRIPE:
+	case LL_IOC_LOV_GETSTRIPE_NEW:
 	case LL_IOC_MDC_GETINFO:
 	case IOC_MDC_GETFILEINFO:
 	case IOC_MDC_GETFILESTRIPE: {
@@ -1404,7 +1406,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		if (cmd == IOC_MDC_GETFILESTRIPE ||
-		    cmd == LL_IOC_LOV_GETSTRIPE) {
+		    cmd == LL_IOC_LOV_GETSTRIPE ||
+		    cmd == LL_IOC_LOV_GETSTRIPE_NEW) {
 			lump = (struct lov_user_md __user *)arg;
 		} else {
 			struct lov_user_mds_data __user *lmdp;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 5f6695f..1980c79 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1481,7 +1481,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 }
 
 static int ll_lov_setea(struct inode *inode, struct file *file,
-			unsigned long arg)
+			void __user *arg)
 {
 	__u64			 flags = MDS_OPEN_HAS_OBJS | FMODE_WRITE;
 	struct lov_user_md	*lump;
@@ -1496,7 +1496,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 	if (!lump)
 		return -ENOMEM;
 
-	if (copy_from_user(lump, (struct lov_user_md __user *)arg, lum_size)) {
+	if (copy_from_user(lump, arg, lum_size)) {
 		kvfree(lump);
 		return -EFAULT;
 	}
@@ -1509,8 +1509,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 	return rc;
 }
 
-static int ll_file_getstripe(struct inode *inode,
-			     struct lov_user_md __user *lum)
+static int ll_file_getstripe(struct inode *inode, void __user *lum, size_t size)
 {
 	struct lu_env *env;
 	u16 refcheck;
@@ -1520,13 +1519,13 @@ static int ll_file_getstripe(struct inode *inode,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	rc = cl_object_getstripe(env, ll_i2info(inode)->lli_clob, lum);
+	rc = cl_object_getstripe(env, ll_i2info(inode)->lli_clob, lum, size);
 	cl_env_put(env, &refcheck);
 	return rc;
 }
 
 static int ll_lov_setstripe(struct inode *inode, struct file *file,
-			    unsigned long arg)
+			    void __user *arg)
 {
 	struct lov_user_md __user *lum = (struct lov_user_md __user *)arg;
 	struct lov_user_md *klum;
@@ -1540,8 +1539,22 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	lum_size = rc;
 	rc = ll_lov_setstripe_ea_info(inode, file->f_path.dentry, flags, klum,
 				      lum_size);
-	cl_lov_delay_create_clear(&file->f_flags);
+	if (!rc) {
+		u32 gen;
+
+		rc = put_user(0, &lum->lmm_stripe_count);
+		if (rc)
+			goto out;
 
+		rc = ll_layout_refresh(inode, &gen);
+		if (rc)
+			goto out;
+
+		rc = ll_file_getstripe(inode, arg, lum_size);
+	}
+
+	cl_lov_delay_create_clear(&file->f_flags);
+out:
 	kfree(klum);
 	return rc;
 }
@@ -2293,9 +2306,10 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		}
 		return 0;
 	case LL_IOC_LOV_SETSTRIPE:
-		return ll_lov_setstripe(inode, file, arg);
+	case LL_IOC_LOV_SETSTRIPE_NEW:
+		return ll_lov_setstripe(inode, file, (void __user *) arg);
 	case LL_IOC_LOV_SETEA:
-		return ll_lov_setea(inode, file, arg);
+		return ll_lov_setea(inode, file, (void __user *) arg);
 	case LL_IOC_LOV_SWAP_LAYOUTS: {
 		struct file *file2;
 		struct lustre_swap_layouts lsl;
@@ -2348,8 +2362,8 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return rc;
 	}
 	case LL_IOC_LOV_GETSTRIPE:
-		return ll_file_getstripe(inode,
-					 (struct lov_user_md __user *)arg);
+	case LL_IOC_LOV_GETSTRIPE_NEW:
+		return ll_file_getstripe(inode, (void __user *)arg, 0);
 	case FSFILT_IOC_GETFLAGS:
 	case FSFILT_IOC_SETFLAGS:
 		return ll_iocontrol(inode, file, cmd, arg);
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 96e6636..5d4c83b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -651,8 +651,9 @@ static inline struct lov_stripe_md_entry *lov_lse(struct lov_object *lov, int i)
 }
 
 /* lov_pack.c */
-int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
-		  struct lov_user_md __user *lump);
+int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
+		  struct lov_stripe_md *lsm, struct lov_user_md __user *lump,
+		  size_t size);
 
 /** @} lov */
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index ca18c1e..4696f7c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1605,7 +1605,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 }
 
 static int lov_object_getstripe(const struct lu_env *env, struct cl_object *obj,
-				struct lov_user_md __user *lum)
+				struct lov_user_md __user *lum, size_t size)
 {
 	struct lov_object *lov = cl2lov(obj);
 	struct lov_stripe_md *lsm;
@@ -1615,7 +1615,7 @@ static int lov_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 	if (!lsm)
 		return -ENODATA;
 
-	rc = lov_getstripe(env, cl2lov(obj), lsm, lum);
+	rc = lov_getstripe(env, cl2lov(obj), lsm, lum, size);
 	lov_lsm_put(lsm);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 10be119..ef3c040 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -314,12 +314,16 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
  * @lump is a pointer to an in-core struct with lmm_ost_count indicating
  * the maximum number of OST indices which will fit in the user buffer.
  * lmm_magic must be LOV_USER_MAGIC.
+ *
+ * If @size > 0, User specified limited buffer size, usually the buffer is from
+ * ll_lov_setstripe(), and the buffer can only hold basic layout template info.
  */
 int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
-		  struct lov_stripe_md *lsm, struct lov_user_md __user *lump)
+		  struct lov_stripe_md *lsm, struct lov_user_md __user *lump,
+		  size_t size)
 {
 	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
-	struct lov_mds_md *lmmk;
+	struct lov_mds_md *lmmk, *lmm;
 	struct lov_user_md_v1 lum;
 	ssize_t lmm_size, lum_size = 0;
 	static bool printed;
@@ -410,15 +414,24 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 			comp_md = (struct lov_mds_md *)((char *)comp_v1 +
 					comp_v1->lcm_entries[i].lcme_offset);
 		}
-		if (copy_to_user(lump, comp_md, lum_size)) {
-			rc = -EFAULT;
-			goto out_free;
-		}
+
+		lmm = comp_md;
+		lmm_size = lum_size;
 	} else {
-		if (copy_to_user(lump, lmmk, lmmk_size)) {
-			rc = -EFAULT;
-			goto out_free;
-		}
+		lmm = lmmk;
+		lmm_size = lmmk_size;
+	}
+	/**
+	 * User specified limited buffer size, usually the buffer is
+	 * from ll_lov_setstripe(), and the buffer can only hold basic
+	 * layout template info.
+	 */
+	if (size == 0 || size > lmm_size)
+		size = lmm_size;
+
+	if (copy_to_user(lump, lmm, size)) {
+		rc = -EFAULT;
+		goto out_free;
 	}
 
 out_free:
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 09fc7e7..b2bf570 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -323,7 +323,7 @@ int cl_object_prune(const struct lu_env *env, struct cl_object *obj)
  * Get stripe information of this object.
  */
 int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
-			struct lov_user_md __user *uarg)
+			struct lov_user_md __user *uarg, size_t size)
 {
 	struct lu_object_header *top;
 	int result = 0;
@@ -331,7 +331,8 @@ int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 	top = obj->co_lu.lo_header;
 	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
 		if (obj->co_ops->coo_getstripe) {
-			result = obj->co_ops->coo_getstripe(env, obj, uarg);
+			result = obj->co_ops->coo_getstripe(env, obj, uarg,
+							    size);
 			if (result)
 				break;
 		}
-- 
1.8.3.1
