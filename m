From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:36 -0400
Subject: [lustre-devel] [PATCH 077/151] lustre: flr: instantiate component
 for truncate
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-78-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

layout intent for truncate IO needs stale components for non
primary mirror overlapping [trunc_size, eof), while needs to
instantiate components overlapping [0, trunc_size).

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: 173981742e69 ("LU-9771 flr: instantiate component for truncate")
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29099
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                 | 27 +++++++++++++++------------
 fs/lustre/llite/lcommon_cl.c           |  2 +-
 fs/lustre/llite/llite_internal.h       |  3 ++-
 fs/lustre/llite/vvp_io.c               |  8 ++++++--
 fs/lustre/lov/lov_io.c                 |  6 +++---
 include/uapi/linux/lustre/lustre_idl.h |  2 +-
 6 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d13c583..22e3494 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1723,6 +1723,10 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 		struct cl_layout cl = {
 			.cl_is_composite = false,
 		};
+		struct lu_extent ext = {
+			.e_start = 0,
+			.e_end = OBD_OBJECT_EOF,
+		};
 		struct lu_env *env;
 		u16 refcheck;
 
@@ -1732,7 +1736,8 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 
 		rc = cl_object_layout_get(env, obj, &cl);
 		if (!rc && cl.cl_is_composite)
-			rc = ll_layout_write_intent(inode, 0, OBD_OBJECT_EOF);
+			rc = ll_layout_write_intent(inode, LAYOUT_INTENT_WRITE,
+						    &ext);
 
 		cl_env_put(env, &refcheck);
 		if (rc)
@@ -4396,25 +4401,23 @@ int ll_layout_refresh(struct inode *inode, u32 *gen)
  * Issue layout intent RPC indicating where in a file an IO is about to write.
  *
  * @inode:	file inode.
- * @start:	start offset of fille in bytes where an IO is about to
- *		write.
- * @end:	exclusive end offset in bytes of the write range.
+ * @ext:	write range with start offset of fille in bytes where
+ *		an IO is about to write, and exclusive end offset in
+ *		bytes.
  *
  * Returns:	0 on success
  *		< 0 error code
  */
-int ll_layout_write_intent(struct inode *inode, u64 start, u64 end)
+int ll_layout_write_intent(struct inode *inode, enum layout_intent_opc opc,
+			   struct lu_extent *ext)
 {
 	struct layout_intent intent = {
-		.li_opc = LAYOUT_INTENT_WRITE,
-		.li_extent.e_start = start,
-		.li_extent.e_end = end,
+		.li_opc = opc,
+		.li_extent.e_start = ext->e_start,
+		.li_extent.e_end = ext->e_end,
 	};
-	int rc;
 
-	rc = ll_layout_intent(inode, &intent);
-
-	return rc;
+	return ll_layout_intent(inode, &intent);
 }
 
 /**
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 0361adc..24e58c2 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -103,10 +103,10 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
 	io->u.ci_setattr.sa_xvalid = xvalid;
 	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&obj->co_lu);
 
+again:
 	if (attr->ia_valid & ATTR_FILE)
 		ll_io_set_mirror(io, attr->ia_file);
 
-again:
 	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0) {
 		struct vvp_io *vio = vvp_env_io(env);
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index dc81474..a44aec06 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1332,7 +1332,8 @@ static inline void d_lustre_revalidate(struct dentry *dentry)
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf);
 int ll_layout_refresh(struct inode *inode, u32 *gen);
 int ll_layout_restore(struct inode *inode, loff_t start, u64 length);
-int ll_layout_write_intent(struct inode *inode, u64 start, u64 end);
+int ll_layout_write_intent(struct inode *inode, enum layout_intent_opc opc,
+			   struct lu_extent *ext);
 
 int ll_xattr_init(void);
 void ll_xattr_fini(void);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index dc9ccef..c8a1ff1 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -347,6 +347,8 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 	 * RPC.
 	 */
 	if (io->ci_need_write_intent) {
+		enum layout_intent_opc opc = LAYOUT_INTENT_WRITE;
+
 		io->ci_need_write_intent = 0;
 
 		LASSERT(io->ci_type == CIT_WRITE ||
@@ -356,8 +358,10 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		       PFID(lu_object_fid(&obj->co_lu)), io->ci_type,
 		       PEXT(&io->ci_write_intent));
 
-		rc = ll_layout_write_intent(inode, io->ci_write_intent.e_start,
-					    io->ci_write_intent.e_end);
+		if (cl_io_is_trunc(io))
+			opc = LAYOUT_INTENT_TRUNC;
+
+		rc = ll_layout_write_intent(inode, opc, &io->ci_write_intent);
 		io->ci_result = rc;
 		if (!rc)
 			io->ci_need_restart = 1;
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 9fd1b52..75fa646 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -538,9 +538,10 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		goto out;
 	}
 
-	ext.e_start = lio->lis_pos;
-	ext.e_end = lio->lis_endpos;
+	io->ci_write_intent.e_start = lio->lis_pos;
+	io->ci_write_intent.e_end = lio->lis_endpos;
 
+	ext = io->ci_write_intent;
 	/* for truncate, it only needs to instantiate the components
 	 * before the truncated size.
 	 */
@@ -553,7 +554,6 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	lov_foreach_io_layout(index, lio, &ext) {
 		if (!lsm_entry_inited(obj->lo_lsm, index)) {
 			io->ci_need_write_intent = 1;
-			io->ci_write_intent = ext;
 			break;
 		}
 	}
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 0692c98..b2f68edd 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2845,7 +2845,7 @@ struct getparent {
 	char		gp_name[0];	/**< zero-terminated link name */
 } __packed;
 
-enum {
+enum layout_intent_opc {
 	LAYOUT_INTENT_ACCESS	= 0,	/** generic access */
 	LAYOUT_INTENT_READ	= 1,	/** not used */
 	LAYOUT_INTENT_WRITE	= 2,	/** write file, for comp layout */
-- 
1.8.3.1
