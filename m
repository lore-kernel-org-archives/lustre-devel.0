From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:25 -0400
Subject: [lustre-devel] [PATCH 08/18] lustre: security: send file security
 context for creates
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Send file security context to MDT along with create RPCs. This closes
the insecure window between creation and setting of the security
context that existed previously. It also avoids a potential LDLM hang
which arises from ll_create_it() when we send a MDS_SETXATTR RPC while
holding the lookup+layout lock returned from open.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-5560
Reviewed-on: http://review.whamcloud.com/19971
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre_req_layout.h      |  4 +-
 drivers/staging/lustre/lustre/include/obd.h        |  5 ++
 drivers/staging/lustre/lustre/llite/dir.c          | 54 ++++++++++++++++------
 .../staging/lustre/lustre/llite/llite_internal.h   | 11 ++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 14 ++++++
 drivers/staging/lustre/lustre/llite/namei.c        | 40 ++++++++++++++--
 .../staging/lustre/lustre/llite/xattr_security.c   | 38 ++++++++++++++-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |  4 ++
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        | 32 +++++++++++++
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  7 +++
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  7 +++
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 28 +++++++++--
 12 files changed, 218 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 9d718b7..3387ab2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -60,7 +60,7 @@ enum req_location {
 };
 
 /* Maximal number of fields (buffers) in a request message. */
-#define REQ_MAX_FIELD_NR  9
+#define REQ_MAX_FIELD_NR 10
 
 struct req_capsule {
 	struct ptlrpc_request   *rc_req;
@@ -236,6 +236,8 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_GETINFO_VALLEN;
 extern struct req_msg_field RMF_GETINFO_KEY;
 extern struct req_msg_field RMF_CLOSE_DATA;
+extern struct req_msg_field RMF_FILE_SECCTX_NAME;
+extern struct req_msg_field RMF_FILE_SECCTX;
 
 /*
  * connection handle received in MDS_CONNECT request.
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d4574ef..62f85a1 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -755,6 +755,11 @@ struct md_op_data {
 	__u64			op_data_version;
 	struct lustre_handle	op_lease_handle;
 
+	/* File security context, for creates. */
+	const char	       *op_file_secctx_name;
+	void		       *op_file_secctx;
+	u32			op_file_secctx_size;
+
 	/* default stripe offset */
 	__u32			op_default_stripe_offset;
 };
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 52a8ecc..987f4b2 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -398,7 +398,7 @@ static int ll_send_mgc_param(struct obd_export *mgc, char *string)
 /**
  * Create striped directory with specified stripe(@lump)
  *
- * param[in] parent	the parent of the directory.
+ * param[in] dparent	the parent of the directory.
  * param[in] lump	the specified stripes.
  * param[in] dirname	the name of the directory.
  * param[in] mode	the specified mode of the directory.
@@ -406,14 +406,23 @@ static int ll_send_mgc_param(struct obd_export *mgc, char *string)
  * retval		=0 if striped directory is being created successfully.
  *			<0 if the creation is failed.
  */
-static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
+static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 			       const char *dirname, umode_t mode)
 {
+	struct inode *parent = dparent->d_inode;
 	struct ptlrpc_request *request = NULL;
 	struct md_op_data *op_data;
 	struct ll_sb_info *sbi = ll_i2sbi(parent);
 	struct inode *inode = NULL;
-	struct dentry dentry;
+	struct dentry dentry = {
+		.d_parent = dparent,
+		.d_name = {
+			.name = dirname,
+			.len = strlen(dirname),
+			.hash = full_name_hash(dparent, dirname,
+					       strlen(dirname)),
+		},
+	};
 	int err;
 
 	if (unlikely(lump->lum_magic != LMV_USER_MAGIC))
@@ -436,9 +445,21 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, dirname,
 				     strlen(dirname), mode, LUSTRE_OPC_MKDIR,
 				     lump);
-	if (IS_ERR(op_data)) {
-		err = PTR_ERR(op_data);
-		goto err_exit;
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
+	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+		/*
+		 * selinux_dentry_init_security() uses dentry->d_parent and name
+		 * to determine the security context for the file. So our fake
+		 * dentry should be real enough for this purpose.
+		 */
+		err = ll_dentry_init_security(&dentry, mode, &dentry.d_name,
+					      &op_data->op_file_secctx_name,
+					      &op_data->op_file_secctx,
+					      &op_data->op_file_secctx_size);
+		if (err < 0)
+			goto out_op_data;
 	}
 
 	op_data->op_cli_flags |= CLI_SET_MEA;
@@ -446,20 +467,26 @@ static int ll_dir_setdirstripe(struct inode *parent, struct lmv_user_md *lump,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), 0, &request);
-	ll_finish_md_op_data(op_data);
+	if (err)
+		goto out_request;
 
 	err = ll_prep_inode(&inode, request, parent->i_sb, NULL);
 	if (err)
-		goto err_exit;
+		goto out_inode;
 
-	memset(&dentry, 0, sizeof(dentry));
 	dentry.d_inode = inode;
 
-	err = ll_init_security(&dentry, inode, parent);
-	iput(inode);
+	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
+		err = ll_inode_init_security(&dentry, inode, parent);
 
-err_exit:
+out_inode:
+	if (inode)
+		iput(inode);
+out_request:
 	ptlrpc_req_finished(request);
+out_op_data:
+	ll_finish_md_op_data(op_data);
+
 	return err;
 }
 
@@ -1033,6 +1060,7 @@ static char *ll_getname(const char __user *filename)
 
 static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
+	struct dentry *dentry = file_dentry(file);
 	struct inode *inode = file_inode(file);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct obd_ioctl_data *data;
@@ -1146,7 +1174,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 #else
 		mode = data->ioc_type;
 #endif
-		rc = ll_dir_setdirstripe(inode, lum, filename, mode);
+		rc = ll_dir_setdirstripe(dentry, lum, filename, mode);
 lmv_out_free:
 		kvfree(buf);
 		return rc;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 86914c9..8399501 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -261,8 +261,11 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, __u32 gen)
 int ll_xattr_cache_get(struct inode *inode, const char *name,
 		       char *buffer, size_t size, __u64 valid);
 
-int ll_init_security(struct dentry *dentry, struct inode *inode,
-		     struct inode *dir);
+int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
+			    const char **secctx_name, void **secctx,
+			    u32 *secctx_size);
+int ll_inode_init_security(struct dentry *dentry, struct inode *inode,
+			   struct inode *dir);
 
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
@@ -396,6 +399,9 @@ enum stats_track_type {
 					  * suppress_pings
 					  */
 #define LL_SBI_FAST_READ	0x400000 /* fast read support */
+#define LL_SBI_FILE_SECCTX	0x800000 /* set file security context at
+					  * create
+					  */
 
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
@@ -421,6 +427,7 @@ enum stats_track_type {
 	"norootsquash",	\
 	"always_ping",	\
 	"fast_read",    \
+	"file_secctx",	\
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 640205a..7a414e2 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -42,6 +42,7 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/random.h>
+#include <linux/security.h>
 #include <linux/fs_struct.h>
 
 #include <uapi/linux/lustre/lustre_ioctl.h>
@@ -149,6 +150,12 @@ static void ll_free_sbi(struct super_block *sb)
 	kfree(sbi);
 }
 
+static inline int obd_connect_has_secctx(struct obd_connect_data *data)
+{
+	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
+	       data->ocd_connect_flags2 & OBD_CONNECT2_FILE_SECCTX;
+}
+
 static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 {
 	struct inode *root = NULL;
@@ -240,6 +247,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
+	data->ocd_connect_flags2 |= OBD_CONNECT2_FILE_SECCTX;
+
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
 	err = obd_connect(NULL, &sbi->ll_md_exp, obd, &sbi->ll_sb_uuid,
@@ -347,6 +356,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK)
 		sbi->ll_flags |= LL_SBI_LAYOUT_LOCK;
 
+	if (obd_connect_has_secctx(data))
+		sbi->ll_flags |= LL_SBI_FILE_SECCTX;
+
 	if (data->ocd_ibits_known & MDS_INODELOCK_XATTR) {
 		if (!(data->ocd_connect_flags & OBD_CONNECT_MAX_EASIZE)) {
 			LCONSOLE_INFO(
@@ -2370,6 +2382,8 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 
 void ll_finish_md_op_data(struct md_op_data *op_data)
 {
+	security_release_secctx(op_data->op_file_secctx,
+				op_data->op_file_secctx_size);
 	kfree(op_data);
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index abcb1c8..134cc31 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -577,13 +577,28 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, dentry->d_name.name,
 				     dentry->d_name.len, 0, opc, NULL);
-	if (IS_ERR(op_data))
-		return (void *)op_data;
+	if (IS_ERR(op_data)) {
+		retval = ERR_CAST(op_data);
+		goto out;
+	}
 
 	/* enforce umask if acl disabled or MDS doesn't support umask */
 	if (!IS_POSIXACL(parent) || !exp_connect_umask(ll_i2mdexp(parent)))
 		it->it_create_mode &= ~current_umask();
 
+	if (it->it_op & IT_CREAT &&
+	    ll_i2sbi(parent)->ll_flags & LL_SBI_FILE_SECCTX) {
+		rc = ll_dentry_init_security(dentry, it->it_create_mode,
+					     &dentry->d_name,
+					     &op_data->op_file_secctx_name,
+					     &op_data->op_file_secctx,
+					     &op_data->op_file_secctx_size);
+		if (rc < 0) {
+			retval = ERR_PTR(rc);
+			goto out;
+		}
+	}
+
 	rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
 			    &ll_md_blocking_ast, 0);
 	/*
@@ -838,7 +853,10 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 
 	d_instantiate(dentry, inode);
 
-	return ll_init_security(dentry, inode, dir);
+	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX))
+		rc = ll_inode_init_security(dentry, inode, dir);
+
+	return rc;
 }
 
 void ll_update_times(struct ptlrpc_request *request, struct inode *inode)
@@ -882,11 +900,21 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		goto err_exit;
 	}
 
+	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
+		err = ll_dentry_init_security(dentry, mode, &dentry->d_name,
+					      &op_data->op_file_secctx_name,
+					      &op_data->op_file_secctx,
+					      &op_data->op_file_secctx_size);
+		if (err < 0)
+			goto err_exit;
+	}
+
 	err = md_create(sbi->ll_md_exp, op_data, tgt, tgt_len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
 	ll_finish_md_op_data(op_data);
+	op_data = NULL;
 	if (err < 0 && err != -EREMOTE)
 		goto err_exit;
 
@@ -934,11 +962,15 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 	d_instantiate(dentry, inode);
 
-	err = ll_init_security(dentry, inode, dir);
+	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
+		err = ll_inode_init_security(dentry, inode, dir);
 err_exit:
 	if (request)
 		ptlrpc_req_finished(request);
 
+	if (!IS_ERR_OR_NULL(op_data))
+		ll_finish_md_op_data(op_data);
+
 	return err;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr_security.c b/drivers/staging/lustre/lustre/llite/xattr_security.c
index 93ec075..b419d8f 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_security.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_security.c
@@ -36,6 +36,41 @@
 #include <linux/xattr.h>
 #include "llite_internal.h"
 
+/*
+ * Check for LL_SBI_FILE_SECCTX before calling.
+ */
+int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
+			    const char **secctx_name, void **secctx,
+			    u32 *secctx_size)
+{
+	int rc;
+
+	/*
+	 * security_dentry_init_security() is strange. Like
+	 * security_inode_init_security() it may return a context (provided a
+	 * Linux security module is enabled) but unlike
+	 * security_inode_init_security() it does not return to us the name of
+	 * the extended attribute to store the context under (for example
+	 * "security.selinux"). So we only call it when we think we know what
+	 * the name of the extended attribute will be. This is OK-ish since
+	 * SELinux is the only module that implements
+	 * security_dentry_init_security(). Note that the NFS client code just
+	 * calls it and assumes that if anything is returned then it must come
+	 * from SELinux.
+	 */
+	if (!selinux_is_enabled())
+		return 0;
+
+	rc = security_dentry_init_security(dentry, mode, name, secctx,
+					   secctx_size);
+	if (rc < 0)
+		return rc;
+
+	*secctx_name = XATTR_NAME_SELINUX;
+
+	return 0;
+}
+
 /**
  * A helper function for ll_security_inode_init_security()
  * that takes care of setting xattrs
@@ -86,7 +121,8 @@
  * \retval < 0      failure to get security context or set xattr
  */
 int
-ll_init_security(struct dentry *dentry, struct inode *inode, struct inode *dir)
+ll_inode_init_security(struct dentry *dentry, struct inode *inode,
+		       struct inode *dir)
 {
 	if (!selinux_is_enabled())
 		return 0;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 28924e9..f19b0ce 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -54,6 +54,10 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		   umode_t mode, __u64 rdev, __u64 flags, const void *data,
 		   size_t datalen);
+void mdc_file_secctx_pack(struct ptlrpc_request *req,
+			  const char *secctx_name,
+			  const void *secctx, size_t secctx_size);
+
 void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data);
 void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 9cb4d24..fc5a51d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -110,6 +110,30 @@ static void mdc_pack_name(struct ptlrpc_request *req,
 	LASSERT(cpy_len == name_len && lu_name_is_valid_2(buf, cpy_len));
 }
 
+void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
+			  const void *secctx, size_t secctx_size)
+{
+	size_t buf_size;
+	void *buf;
+
+	if (!secctx_name)
+		return;
+
+	buf = req_capsule_client_get(&req->rq_pill, &RMF_FILE_SECCTX_NAME);
+	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+					RCL_CLIENT);
+
+	LASSERT(buf_size == strlen(secctx_name) + 1);
+	memcpy(buf, secctx_name, buf_size);
+
+	buf = req_capsule_client_get(&req->rq_pill, &RMF_FILE_SECCTX);
+	buf_size = req_capsule_get_size(&req->rq_pill, &RMF_FILE_SECCTX,
+					RCL_CLIENT);
+
+	LASSERT(buf_size == secctx_size);
+	memcpy(buf, secctx, buf_size);
+}
+
 void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
 		      const struct lu_fid *fid)
 {
@@ -159,6 +183,10 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		tmp = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
 		memcpy(tmp, data, datalen);
 	}
+
+	mdc_file_secctx_pack(req, op_data->op_file_secctx_name,
+			     op_data->op_file_secctx,
+			     op_data->op_file_secctx_size);
 }
 
 static inline __u64 mds_pack_open_flags(__u64 flags)
@@ -224,6 +252,10 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 		if (op_data->op_bias & MDS_CREATE_VOLATILE)
 			cr_flags |= MDS_OPEN_VOLATILE;
+
+		mdc_file_secctx_pack(req, op_data->op_file_secctx_name,
+				     op_data->op_file_secctx,
+				     op_data->op_file_secctx_size);
 	}
 
 	if (lmm) {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index a8aa0fa..cfe917c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -288,6 +288,13 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
 			     max(lmmsize, obddev->u.cli.cl_default_mds_easize));
 
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+			     RCL_CLIENT, op_data->op_file_secctx_name ?
+			     strlen(op_data->op_file_secctx_name) + 1 : 0);
+
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
+			     op_data->op_file_secctx_size);
+
 	rc = ldlm_prep_enqueue_req(exp, req, &cancels, count);
 	if (rc < 0) {
 		ptlrpc_request_free(req);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index da5f14c3..bdffe6d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -190,6 +190,13 @@ int mdc_create(struct obd_export *exp, struct md_op_data *op_data,
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT,
 			     data && datalen ? datalen : 0);
 
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX_NAME,
+			     RCL_CLIENT, op_data->op_file_secctx_name ?
+			     strlen(op_data->op_file_secctx_name) + 1 : 0);
+
+	req_capsule_set_size(&req->rq_pill, &RMF_FILE_SECCTX, RCL_CLIENT,
+			     op_data->op_file_secctx_size);
+
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
 		ptlrpc_request_free(req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 0b3ac14..d3c0dd6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -196,7 +196,9 @@
 	&RMF_CAPA1,
 	&RMF_NAME,
 	&RMF_EADATA,
-	&RMF_DLM_REQ
+	&RMF_DLM_REQ,
+	&RMF_FILE_SECCTX_NAME,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *mds_reint_create_sym_client[] = {
@@ -205,7 +207,9 @@
 	&RMF_CAPA1,
 	&RMF_NAME,
 	&RMF_SYMTGT,
-	&RMF_DLM_REQ
+	&RMF_DLM_REQ,
+	&RMF_FILE_SECCTX_NAME,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *mds_reint_open_client[] = {
@@ -214,7 +218,9 @@
 	&RMF_CAPA1,
 	&RMF_CAPA2,
 	&RMF_NAME,
-	&RMF_EADATA
+	&RMF_EADATA,
+	&RMF_FILE_SECCTX_NAME,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *mds_reint_open_server[] = {
@@ -435,7 +441,9 @@
 	&RMF_REC_REINT,    /* coincides with mds_reint_create_client[] */
 	&RMF_CAPA1,
 	&RMF_NAME,
-	&RMF_EADATA
+	&RMF_EADATA,
+	&RMF_FILE_SECCTX_NAME,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *ldlm_intent_open_client[] = {
@@ -446,7 +454,9 @@
 	&RMF_CAPA1,
 	&RMF_CAPA2,
 	&RMF_NAME,
-	&RMF_EADATA
+	&RMF_EADATA,
+	&RMF_FILE_SECCTX_NAME,
+	&RMF_FILE_SECCTX
 };
 
 static const struct req_msg_field *ldlm_intent_unlink_client[] = {
@@ -931,6 +941,14 @@ struct req_msg_field RMF_STRING =
 	DEFINE_MSGF("string", RMF_F_STRING, -1, NULL, NULL);
 EXPORT_SYMBOL(RMF_STRING);
 
+struct req_msg_field RMF_FILE_SECCTX_NAME =
+	DEFINE_MSGF("file_secctx_name", RMF_F_STRING, -1, NULL, NULL);
+EXPORT_SYMBOL(RMF_FILE_SECCTX_NAME);
+
+struct req_msg_field RMF_FILE_SECCTX =
+	DEFINE_MSGF("file_secctx", 0, -1, NULL, NULL);
+EXPORT_SYMBOL(RMF_FILE_SECCTX);
+
 struct req_msg_field RMF_LLOGD_BODY =
 	DEFINE_MSGF("llogd_body", 0,
 		    sizeof(struct llogd_body), lustre_swab_llogd_body, NULL);
-- 
1.8.3.1
