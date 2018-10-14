From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:43 -0400
Subject: [lustre-devel] [PATCH 4/7] lustre: quota: add setting/getting
 project id function
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Extend Attr RPC to support project ID attribute, new
ioctl is introduced to get/set project id, it is kept
same ioctl number as VFS, you could use:

lsattr -p <file>
chattr -p <file>

Signed-off-by: Wang Shilong <wshilong@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4017
Reviewed-on: https://review.whamcloud.com/26202
Reviewed-on: https://review.whamcloud.com/26577
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Tested-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  5 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  6 ++-
 drivers/staging/lustre/lustre/include/obd.h        |  3 ++
 drivers/staging/lustre/lustre/llite/dir.c          |  5 +-
 drivers/staging/lustre/lustre/llite/file.c         | 57 ++++++++++++++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |  5 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  5 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  3 ++
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  1 +
 drivers/staging/lustre/lustre/osc/osc_request.c    | 11 +++--
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 11 +++--
 11 files changed, 97 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index a8ffde2..a7b3168 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1562,7 +1562,7 @@ struct mdt_rec_setattr {
 	__u32		sa_attr_flags;
 	__u32		sa_mode;
 	__u32		sa_bias;      /* some operation flags */
-	__u32		sa_padding_3;
+	__u32		sa_projid;
 	__u32		sa_padding_4;
 	__u32		sa_padding_5;
 };
@@ -1590,7 +1590,8 @@ struct mdt_rec_setattr {
 #define MDS_ATTR_FROM_OPEN	0x4000ULL /* = 16384, called from open path,
 					   * ie O_TRUNC
 					   */
-#define MDS_ATTR_BLOCKS		0x8000ULL /* = 32768 */
+#define MDS_ATTR_BLOCKS		0x8000ULL  /* = 32768 */
+#define MDS_ATTR_PROJID		0x10000ULL /* = 65536 */
 
 #define MDS_FMODE_CLOSED	00000000
 #define MDS_FMODE_EXEC		00000004
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 9ff1ca5..a1e07f8 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -165,6 +165,9 @@ struct cl_attr {
 
 	/* nlink of the directory */
 	__u64  cat_nlink;
+
+	/* Project identifier for quota purpose. */
+	u32	cat_projid;
 };
 
 /**
@@ -178,7 +181,8 @@ enum cl_attr_valid {
 	CAT_CTIME  = 1 << 5,
 	CAT_BLOCKS = 1 << 6,
 	CAT_UID    = 1 << 7,
-	CAT_GID    = 1 << 8
+	CAT_GID		= BIT(8),
+	CAT_PROJID	= BIT(9),
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 81b4750..d6a968c 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -670,6 +670,7 @@ enum op_xvalid {
 	OP_XVALID_BLOCKS	= BIT(1),	/* 0x0002 */
 	OP_XVALID_OWNEROVERRIDE	= BIT(2),	/* 0x0004 */
 	OP_XVALID_FLAGS		= BIT(3),	/* 0x0008 */
+	OP_XVALID_PROJID	= BIT(4),	/* 0x0010 */
 };
 
 struct lu_context;
@@ -770,6 +771,8 @@ struct md_op_data {
 
 	/* default stripe offset */
 	__u32			op_default_stripe_offset;
+
+	u32			op_projid;
 };
 
 struct md_callback {
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 9fa0e2e..f1c1c9c 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1667,7 +1667,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		return rc;
 	}
-
+	case FS_IOC_FSGETXATTR:
+		return ll_ioctl_fsgetxattr(inode, cmd, arg);
+	case FS_IOC_FSSETXATTR:
+		return ll_ioctl_fssetxattr(inode, cmd, arg);
 	default:
 		return obd_iocontrol(cmd, sbi->ll_dt_exp, 0, NULL,
 				     (void __user *)arg);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 5df2b87..30a731f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2148,6 +2148,59 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 	return rc;
 }
 
+int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
+			unsigned long arg)
+{
+	struct fsxattr fsxattr;
+
+	if (copy_from_user(&fsxattr,
+			   (const struct fsxattr __user *)arg,
+			   sizeof(fsxattr)))
+		return -EFAULT;
+
+	fsxattr.fsx_projid = ll_i2info(inode)->lli_projid;
+	if (copy_to_user((struct fsxattr __user *)arg,
+			  &fsxattr, sizeof(fsxattr)))
+		return -EFAULT;
+
+	return 0;
+}
+
+int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
+			unsigned long arg)
+{
+	struct ptlrpc_request *req = NULL;
+	struct md_op_data *op_data;
+	struct fsxattr fsxattr;
+	int rc = 0;
+
+	/* only root could change project ID */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	if (copy_from_user(&fsxattr,
+			   (const struct fsxattr __user *)arg,
+			   sizeof(fsxattr))) {
+		rc = -EFAULT;
+		goto out_fsxattr;
+	}
+
+	op_data->op_projid = fsxattr.fsx_projid;
+	op_data->op_xvalid |= OP_XVALID_PROJID;
+	rc = md_setattr(ll_i2sbi(inode)->ll_md_exp, op_data, NULL,
+			0, &req);
+	ptlrpc_req_finished(req);
+
+out_fsxattr:
+	ll_finish_md_op_data(op_data);
+	return rc;
+}
+
 static long
 ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -2532,6 +2585,10 @@ static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
 		kfree(ladvise_hdr);
 		return rc;
 	}
+	case FS_IOC_FSGETXATTR:
+		return ll_ioctl_fsgetxattr(inode, cmd, arg);
+	case FS_IOC_FSSETXATTR:
+		return ll_ioctl_fssetxattr(inode, cmd, arg);
 	default: {
 		int err;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ba9ba49..34bcb4b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -808,7 +808,10 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
 int ll_get_fid_by_name(struct inode *parent, const char *name,
 		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
-
+int ll_ioctl_fsgetxattr(struct inode *inode, unsigned int cmd,
+			unsigned long arg);
+int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
+			unsigned long arg);
 int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 			     __u64 flags, struct lov_user_md *lum,
 			     int lum_size);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index c1f8b50..e1000f6 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -95,6 +95,7 @@ static int vvp_attr_get(const struct lu_env *env, struct cl_object *obj,
 	attr->cat_blocks = inode->i_blocks;
 	attr->cat_uid = from_kuid(&init_user_ns, inode->i_uid);
 	attr->cat_gid = from_kgid(&init_user_ns, inode->i_gid);
+	attr->cat_projid = ll_i2info(inode)->lli_projid;
 	/* KMS is not known by this layer */
 	return 0; /* layers below have to fill in the rest */
 }
@@ -116,8 +117,10 @@ static int vvp_attr_update(const struct lu_env *env, struct cl_object *obj,
 		inode->i_ctime.tv_sec = attr->cat_ctime;
 	if (0 && valid & CAT_SIZE)
 		i_size_write(inode, attr->cat_size);
+	if (valid & CAT_PROJID)
+		ll_i2info(inode)->lli_projid = attr->cat_projid;
 	/* not currently necessary */
-	if (0 && valid & (CAT_UID | CAT_GID | CAT_SIZE))
+	if (0 && valid & (CAT_UID | CAT_GID | CAT_SIZE | CAT_PROJID))
 		mark_inode_dirty(inode);
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 1ab1ad2..415127f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -305,6 +305,8 @@ static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
 	if (ia_xvalid & OP_XVALID_OWNEROVERRIDE)
 		/* NFSD hack (see bug 5781) */
 		sa_valid |= MDS_OPEN_OWNEROVERRIDE;
+	if (ia_xvalid & OP_XVALID_PROJID)
+		sa_valid |= MDS_ATTR_PROJID;
 	return sa_valid;
 }
 
@@ -323,6 +325,7 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 	rec->sa_mode   = op_data->op_attr.ia_mode;
 	rec->sa_uid    = from_kuid(&init_user_ns, op_data->op_attr.ia_uid);
 	rec->sa_gid    = from_kgid(&init_user_ns, op_data->op_attr.ia_gid);
+	rec->sa_projid = op_data->op_projid;
 	rec->sa_size   = op_data->op_attr.ia_size;
 	rec->sa_blocks = op_data->op_attr_blocks;
 	rec->sa_atime  = op_data->op_attr.ia_atime.tv_sec;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5d09a4f..93330cb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2467,6 +2467,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 		qid[USRQUOTA] = attr->cat_uid;
 		qid[GRPQUOTA] = attr->cat_gid;
+		qid[PRJQUOTA] = attr->cat_projid;
 		if (rc == 0)
 			rc = osc_quota_chkdq(cli, qid);
 		if (rc)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 1d21159..b28fbac 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1474,14 +1474,15 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		return -EPROTO;
 	}
 
-	/* set/clear over quota flag for a uid/gid */
+	/* set/clear over quota flag for a uid/gid/projid */
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE &&
 	    body->oa.o_valid & OBD_MD_FLALLQUOTA) {
-		unsigned int qid[MAXQUOTAS] = { body->oa.o_uid, body->oa.o_gid };
+		unsigned int qid[MAXQUOTAS] = { body->oa.o_uid, body->oa.o_gid,
+						body->oa.o_projid };
 
-		CDEBUG(D_QUOTA, "setdq for [%u %u] with valid %#llx, flags %x\n",
-		       body->oa.o_uid, body->oa.o_gid, body->oa.o_valid,
-		       body->oa.o_flags);
+		CDEBUG(D_QUOTA, "setdq for [%u %u %u] with valid %#llx, flags %x\n",
+		       body->oa.o_uid, body->oa.o_gid, body->oa.o_projid,
+		       body->oa.o_valid, body->oa.o_flags);
 		osc_quota_setdq(cli, qid, body->oa.o_valid, body->oa.o_flags);
 	}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index b4774d6..3aaaebb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -253,6 +253,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_ATTR_FROM_OPEN);
 	LASSERTF(MDS_ATTR_BLOCKS == 0x0000000000008000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_BLOCKS);
+	LASSERTF(MDS_ATTR_PROJID == 0x0000000000010000ULL, "found 0x%.16llxULL\n",
+		 (long long)MDS_ATTR_PROJID);
+
 	LASSERTF(FLD_QUERY == 900, "found %lld\n",
 		 (long long)FLD_QUERY);
 	LASSERTF(FLD_FIRST_OPC == 900, "found %lld\n",
@@ -2080,10 +2083,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_rec_setattr, sa_bias));
 	LASSERTF((int)sizeof(((struct mdt_rec_setattr *)0)->sa_bias) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_setattr *)0)->sa_bias));
-	LASSERTF((int)offsetof(struct mdt_rec_setattr, sa_padding_3) == 124, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_rec_setattr, sa_padding_3));
-	LASSERTF((int)sizeof(((struct mdt_rec_setattr *)0)->sa_padding_3) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_rec_setattr *)0)->sa_padding_3));
+	LASSERTF((int)offsetof(struct mdt_rec_setattr, sa_projid) == 124, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_setattr, sa_projid));
+	LASSERTF((int)sizeof(((struct mdt_rec_setattr *)0)->sa_projid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_setattr *)0)->sa_projid));
 	LASSERTF((int)offsetof(struct mdt_rec_setattr, sa_padding_4) == 128, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_rec_setattr, sa_padding_4));
 	LASSERTF((int)sizeof(((struct mdt_rec_setattr *)0)->sa_padding_4) == 4, "found %lld\n",
-- 
1.8.3.1
