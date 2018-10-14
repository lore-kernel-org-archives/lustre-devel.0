From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:12 -0400
Subject: [lustre-devel] [PATCH 22/28] lustre: clio: update spare bit handling
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Turn the OP_ATTR_* values into an enum and rename them to make
their purpose clear.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10030
Reviewed-on: https://review.whamcloud.com/32825
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h    |  2 +-
 drivers/staging/lustre/lustre/include/obd.h          | 16 +++++++++-------
 drivers/staging/lustre/lustre/llite/file.c           |  4 ++--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c     |  2 +-
 drivers/staging/lustre/lustre/llite/llite_internal.h |  4 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 18 +++++++++---------
 drivers/staging/lustre/lustre/mdc/mdc_lib.c          | 10 +++++-----
 drivers/staging/lustre/lustre/osc/osc_io.c           |  6 +++---
 8 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 382bfe8..9ff1ca5 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1778,7 +1778,7 @@ struct cl_io {
 			struct ost_lvb   sa_attr;
 			unsigned int		 sa_attr_flags;
 			unsigned int     sa_avalid;
-			unsigned int     sa_xvalid;
+			unsigned int		sa_xvalid; /* OP_XVALID */
 			int		sa_stripe_index;
 			const struct lu_fid	*sa_parent_fid;
 		} ci_setattr;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 76ae0b3..cf3dbd6 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -664,6 +664,14 @@ struct obd_device {
 #define KEY_CACHE_SET		"cache_set"
 #define KEY_CACHE_LRU_SHRINK	"cache_lru_shrink"
 
+/* Flags for op_xvalid */
+enum op_xvalid {
+	OP_XVALID_CTIME_SET	= BIT(0),	/* 0x0001 */
+	OP_XVALID_BLOCKS	= BIT(1),	/* 0x0002 */
+	OP_XVALID_OWNEROVERRIDE	= BIT(2),	/* 0x0004 */
+	OP_XVALID_FLAGS		= BIT(3),	/* 0x0008 */
+};
+
 struct lu_context;
 
 static inline int it_to_lock_mode(struct lookup_intent *it)
@@ -733,7 +741,7 @@ struct md_op_data {
 
 	/* iattr fields and blocks. */
 	struct iattr	    op_attr;
-	unsigned int		op_xvalid; /* eXtra validity flags */
+	enum op_xvalid		op_xvalid;	/* eXtra validity flags */
 	unsigned int	    op_attr_flags;
 	__u64		   op_valid;
 	loff_t		  op_attr_blocks;
@@ -764,12 +772,6 @@ struct md_op_data {
 	__u32			op_default_stripe_offset;
 };
 
-/* Flags for op_xvalid */
-#define OP_ATTR_CTIME_SET	(1 << 0)
-#define OP_ATTR_BLOCKS		(1 << 1)
-#define OP_ATTR_OWNEROVERRIDE	(1 << 2)
-#define OP_ATTR_FLAGS		(1 << 3)
-
 struct md_callback {
 	int (*md_blocking_ast)(struct ldlm_lock *lock,
 			       struct ldlm_lock_desc *desc,
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 3bfc6d84..d80bda4 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -96,7 +96,7 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
 	op_data->op_attr.ia_valid |= (ATTR_MODE | ATTR_ATIME | ATTR_ATIME_SET |
 				      ATTR_MTIME | ATTR_MTIME_SET |
 				      ATTR_CTIME);
-	op_data->op_xvalid |= OP_ATTR_CTIME_SET;
+	op_data->op_xvalid |= OP_XVALID_CTIME_SET;
 	op_data->op_attr_blocks = inode->i_blocks;
 	op_data->op_attr_flags = ll_inode_to_ext_flags(inode->i_flags);
 	op_data->op_handle = och->och_fh;
@@ -163,7 +163,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		op_data->op_data_version = *(__u64 *)data;
 		op_data->op_lease_handle = och->och_lease_handle;
 		op_data->op_attr.ia_valid |= ATTR_SIZE;
-		op_data->op_xvalid |= OP_ATTR_BLOCKS;
+		op_data->op_xvalid |= OP_XVALID_BLOCKS;
 		break;
 
 	default:
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 20a3c74..ade3b12 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -80,7 +80,7 @@
 static DEFINE_MUTEX(cl_inode_fini_guard);
 
 int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
-		   unsigned int xvalid, unsigned int attr_flags)
+		   enum op_xvalid xvalid, unsigned int attr_flags)
 {
 	struct lu_env *env;
 	struct cl_io  *io;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 796a8ae..ad380f1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -843,7 +843,7 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 void ll_dir_clear_lsm_md(struct inode *inode);
 void ll_clear_inode(struct inode *inode);
 int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
-		   unsigned int xvalid, bool hsm_import);
+		   enum op_xvalid xvalid, bool hsm_import);
 int ll_setattr(struct dentry *de, struct iattr *attr);
 int ll_statfs(struct dentry *de, struct kstatfs *sfs);
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
@@ -1357,7 +1357,7 @@ int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
 
 /* lcommon_cl.c */
 int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
-		   unsigned int xvalid, unsigned int attr_flags);
+		   enum op_xvalid xvalid, unsigned int attr_flags);
 
 extern struct lu_env *cl_inode_fini_env;
 extern u16 cl_inode_fini_refcheck;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 153aa12..a5e65db 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1492,7 +1492,7 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
  * In case of HSMimport, we only set attr on MDS.
  */
 int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
-		   unsigned int xvalid, bool hsm_import)
+		   enum op_xvalid xvalid, bool hsm_import)
 {
 	struct inode *inode = d_inode(dentry);
 	struct ll_inode_info *lli = ll_i2info(inode);
@@ -1531,10 +1531,10 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	}
 
 	/* We mark all of the fields "set" so MDS/OST does not re-set them */
-	if (!(xvalid & OP_ATTR_CTIME_SET) &&
+	if (!(xvalid & OP_XVALID_CTIME_SET) &&
 	    attr->ia_valid & ATTR_CTIME) {
 		attr->ia_ctime = current_time(inode);
-		xvalid |= OP_ATTR_CTIME_SET;
+		xvalid |= OP_XVALID_CTIME_SET;
 	}
 	if (!(attr->ia_valid & ATTR_ATIME_SET) &&
 	    (attr->ia_valid & ATTR_ATIME)) {
@@ -1570,7 +1570,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 		 * If we are changing file size, file content is
 		 * modified, flag it.
 		 */
-		xvalid |= OP_ATTR_OWNEROVERRIDE;
+		xvalid |= OP_XVALID_OWNEROVERRIDE;
 		op_data->op_bias |= MDS_DATA_MODIFIED;
 		clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags);
 	}
@@ -1589,7 +1589,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 
 	if (attr->ia_valid & (ATTR_SIZE | ATTR_ATIME | ATTR_ATIME_SET |
 			      ATTR_MTIME | ATTR_MTIME_SET | ATTR_CTIME) ||
-	    xvalid & OP_ATTR_CTIME_SET) {
+	    xvalid & OP_XVALID_CTIME_SET) {
 		/* For truncate and utimes sending attributes to OSTs, setting
 		 * mtime/atime to the past will be performed under PW [0:EOF]
 		 * extent lock (new_size:EOF for truncate).  It may seem
@@ -1655,11 +1655,11 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 int ll_setattr(struct dentry *de, struct iattr *attr)
 {
 	int mode = d_inode(de)->i_mode;
-	unsigned int xvalid = 0;
+	enum op_xvalid xvalid = 0;
 
 	if ((attr->ia_valid & (ATTR_CTIME | ATTR_SIZE | ATTR_MODE)) ==
 			      (ATTR_CTIME | ATTR_SIZE | ATTR_MODE))
-		xvalid |= OP_ATTR_OWNEROVERRIDE;
+		xvalid |= OP_XVALID_OWNEROVERRIDE;
 
 	if (((attr->ia_valid & (ATTR_MODE | ATTR_FORCE | ATTR_SIZE)) ==
 			       (ATTR_SIZE | ATTR_MODE)) &&
@@ -2014,7 +2014,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 			return PTR_ERR(op_data);
 
 		op_data->op_attr_flags = flags;
-		op_data->op_xvalid |= OP_ATTR_FLAGS;
+		op_data->op_xvalid |= OP_XVALID_FLAGS;
 		rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &req);
 		ll_finish_md_op_data(op_data);
 		ptlrpc_req_finished(req);
@@ -2031,7 +2031,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		if (!attr)
 			return -ENOMEM;
 
-		rc = cl_setattr_ost(obj, attr, OP_ATTR_FLAGS, flags);
+		rc = cl_setattr_ost(obj, attr, OP_XVALID_FLAGS, flags);
 		kfree(attr);
 		return rc;
 	}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index fc5a51d..1ab1ad2 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -266,7 +266,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	set_mrc_cr_flags(rec, cr_flags);
 }
 
-static inline __u64 attr_pack(unsigned int ia_valid, unsigned int ia_xvalid)
+static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
 {
 	__u64 sa_valid = 0;
 
@@ -290,19 +290,19 @@ static inline __u64 attr_pack(unsigned int ia_valid, unsigned int ia_xvalid)
 		sa_valid |= MDS_ATTR_MTIME_SET;
 	if (ia_valid & ATTR_FORCE)
 		sa_valid |= MDS_ATTR_FORCE;
-	if (ia_xvalid & OP_ATTR_FLAGS)
+	if (ia_xvalid & OP_XVALID_FLAGS)
 		sa_valid |= MDS_ATTR_ATTR_FLAG;
 	if (ia_valid & ATTR_KILL_SUID)
 		sa_valid |=  MDS_ATTR_KILL_SUID;
 	if (ia_valid & ATTR_KILL_SGID)
 		sa_valid |= MDS_ATTR_KILL_SGID;
-	if (ia_xvalid & OP_ATTR_CTIME_SET)
+	if (ia_xvalid & OP_XVALID_CTIME_SET)
 		sa_valid |= MDS_ATTR_CTIME_SET;
 	if (ia_valid & ATTR_OPEN)
 		sa_valid |= MDS_ATTR_FROM_OPEN;
-	if (ia_xvalid & OP_ATTR_BLOCKS)
+	if (ia_xvalid & OP_XVALID_BLOCKS)
 		sa_valid |= MDS_ATTR_BLOCKS;
-	if (ia_xvalid & OP_ATTR_OWNEROVERRIDE)
+	if (ia_xvalid & OP_XVALID_OWNEROVERRIDE)
 		/* NFSD hack (see bug 5781) */
 		sa_valid |= MDS_OPEN_OWNEROVERRIDE;
 	return sa_valid;
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index e7151ed..dabdf6d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -500,7 +500,7 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
 	__u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 	unsigned int ia_avalid = io->u.ci_setattr.sa_avalid;
-	unsigned int ia_xvalid = io->u.ci_setattr.sa_xvalid;
+	enum op_xvalid ia_xvalid = io->u.ci_setattr.sa_xvalid;
 	int result = 0;
 
 	/* truncate cache dirty pages first */
@@ -528,7 +528,7 @@ static int osc_io_setattr_start(const struct lu_env *env,
 				attr->cat_atime = lvb->lvb_atime;
 				cl_valid |= CAT_ATIME;
 			}
-			if (ia_xvalid & OP_ATTR_CTIME_SET) {
+			if (ia_xvalid & OP_XVALID_CTIME_SET) {
 				attr->cat_ctime = lvb->lvb_ctime;
 				cl_valid |= CAT_CTIME;
 			}
@@ -567,7 +567,7 @@ static int osc_io_setattr_start(const struct lu_env *env,
 		} else {
 			LASSERT(oio->oi_lockless == 0);
 		}
-		if (ia_xvalid & OP_ATTR_FLAGS) {
+		if (ia_xvalid & OP_XVALID_FLAGS) {
 			oa->o_flags = io->u.ci_setattr.sa_attr_flags;
 			oa->o_valid |= OBD_MD_FLFLAGS;
 		}
-- 
1.8.3.1
