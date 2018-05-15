From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 May 2018 22:17:00 -0400
Subject: [lustre-devel] [PATCH v2 2/5] staging: lustre: llite: remove unused
 parameters from md_{get, set}xattr()
In-Reply-To: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
References: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1526350623-4616-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: "John L. Hammond" <john.hammond@intel.com>

md_getxattr() and md_setxattr() each have several unused
parameters. Remove them and improve the naming or remaining
parameters.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10792
Reviewed-on: https://review.whamcloud.com/
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch ported to staging tree
v2) Rebased on fixed parent patch

 drivers/staging/lustre/lustre/include/obd.h       |  7 ++---
 drivers/staging/lustre/lustre/include/obd_class.h | 21 ++++++--------
 drivers/staging/lustre/lustre/llite/file.c        |  5 ++--
 drivers/staging/lustre/lustre/llite/xattr.c       |  6 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       | 22 +++++++--------
 drivers/staging/lustre/lustre/mdc/mdc_request.c   | 34 +++++++++++++----------
 6 files changed, 46 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index fe21987..a69564d 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -940,12 +940,11 @@ struct md_ops {
 		      struct ptlrpc_request **);
 
 	int (*setxattr)(struct obd_export *, const struct lu_fid *,
-			u64, const char *, const char *, int, int, int, __u32,
-			struct ptlrpc_request **);
+			u64, const char *, const void *, size_t, unsigned int,
+			u32, struct ptlrpc_request **);
 
 	int (*getxattr)(struct obd_export *, const struct lu_fid *,
-			u64, const char *, const char *, int, int, int,
-			struct ptlrpc_request **);
+			u64, const char *, size_t, struct ptlrpc_request **);
 
 	int (*init_ea_size)(struct obd_export *, u32, u32);
 
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index a76f016..0081578 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1385,29 +1385,26 @@ static inline int md_merge_attr(struct obd_export *exp,
 }
 
 static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
-			      u64 valid, const char *name,
-			      const char *input, int input_size,
-			      int output_size, int flags, __u32 suppgid,
+			      u64 obd_md_valid, const char *name,
+			      const char *value, size_t value_size,
+			      unsigned int xattr_flags, u32 suppgid,
 			      struct ptlrpc_request **request)
 {
 	EXP_CHECK_MD_OP(exp, setxattr);
 	EXP_MD_COUNTER_INCREMENT(exp, setxattr);
-	return MDP(exp->exp_obd, setxattr)(exp, fid, valid, name, input,
-					   input_size, output_size, flags,
+	return MDP(exp->exp_obd, setxattr)(exp, fid, obd_md_valid, name,
+					   value, value_size, xattr_flags,
 					   suppgid, request);
 }
 
 static inline int md_getxattr(struct obd_export *exp, const struct lu_fid *fid,
-			      u64 valid, const char *name,
-			      const char *input, int input_size,
-			      int output_size, int flags,
-			      struct ptlrpc_request **request)
+			      u64 obd_md_valid, const char *name,
+			      size_t buf_size, struct ptlrpc_request **req)
 {
 	EXP_CHECK_MD_OP(exp, getxattr);
 	EXP_MD_COUNTER_INCREMENT(exp, getxattr);
-	return MDP(exp->exp_obd, getxattr)(exp, fid, valid, name, input,
-					   input_size, output_size, flags,
-					   request);
+	return MDP(exp->exp_obd, getxattr)(exp, fid, obd_md_valid, name,
+					   buf_size, req);
 }
 
 static inline int md_set_open_replay_data(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 64a5698..de30df2 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3088,7 +3088,7 @@ int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
 			 value ? OBD_MD_FLXATTR : OBD_MD_FLXATTRRM,
-			 name, value, value_size, 0, 0, 0, &req);
+			 name, value, value_size, 0, 0, &req);
 
 	ptlrpc_req_finished(req);
 out_value:
@@ -3400,8 +3400,7 @@ static int ll_layout_fetch(struct inode *inode, struct ldlm_lock *lock)
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
 	if (rc == 0)
 		rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-				 OBD_MD_FLXATTR, XATTR_NAME_LOV, NULL, 0,
-				 lmmsize, 0, &req);
+				 OBD_MD_FLXATTR, XATTR_NAME_LOV, lmmsize, &req);
 	if (rc < 0)
 		return rc;
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 1a597a6..7fa0a41 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -145,7 +145,7 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 		return -ENOMEM;
 
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode), valid, fullname,
-			 pv, size, 0, flags, ll_i2suppgid(inode), &req);
+			 pv, size, flags, ll_i2suppgid(inode), &req);
 	kfree(fullname);
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
@@ -344,8 +344,8 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 		}
 	} else {
 getxattr_nocache:
-		rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode),
-				 valid, name, NULL, 0, size, 0, &req);
+		rc = md_getxattr(sbi->ll_md_exp, ll_inode2fid(inode), valid,
+				 name, size, &req);
 		if (rc < 0)
 			goto out_xattr;
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7198a63..1ec42e2 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1398,9 +1398,8 @@ static int lmv_getstatus(struct obd_export *exp,
 }
 
 static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
-			u64 valid, const char *name,
-			const char *input, int input_size, int output_size,
-			int flags, struct ptlrpc_request **request)
+			u64 obd_md_valid, const char *name, size_t buf_size,
+			struct ptlrpc_request **req)
 {
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
@@ -1410,15 +1409,15 @@ static int lmv_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	return md_getxattr(tgt->ltd_exp, fid, valid, name, input,
-			 input_size, output_size, flags, request);
+	return md_getxattr(tgt->ltd_exp, fid, obd_md_valid, name, buf_size,
+			   req);
 }
 
 static int lmv_setxattr(struct obd_export *exp, const struct lu_fid *fid,
-			u64 valid, const char *name,
-			const char *input, int input_size, int output_size,
-			int flags, __u32 suppgid,
-			struct ptlrpc_request **request)
+			u64 obd_md_valid, const char *name,
+			const void *value, size_t value_size,
+			unsigned int xattr_flags, u32 suppgid,
+			struct ptlrpc_request **req)
 {
 	struct obd_device      *obd = exp->exp_obd;
 	struct lmv_obd	 *lmv = &obd->u.lmv;
@@ -1428,9 +1427,8 @@ static int lmv_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	return md_setxattr(tgt->ltd_exp, fid, valid, name, input,
-			 input_size, output_size, flags, suppgid,
-			 request);
+	return md_setxattr(tgt->ltd_exp, fid, obd_md_valid, name,
+			   value, value_size, xattr_flags, suppgid, req);
 }
 
 static int lmv_getattr(struct obd_export *exp, struct md_op_data *op_data,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 7d577bf..a90647a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -347,26 +347,30 @@ static int mdc_xattr_common(struct obd_export *exp,
 }
 
 static int mdc_setxattr(struct obd_export *exp, const struct lu_fid *fid,
-			u64 valid, const char *xattr_name,
-			const char *input, int input_size, int output_size,
-			int flags, __u32 suppgid,
-			struct ptlrpc_request **request)
+			u64 obd_md_valid, const char *name,
+			const void *value, size_t value_size,
+			unsigned int xattr_flags, u32 suppgid,
+			struct ptlrpc_request **req)
 {
+	LASSERT(obd_md_valid == OBD_MD_FLXATTR ||
+		obd_md_valid == OBD_MD_FLXATTRRM);
+
 	return mdc_xattr_common(exp, &RQF_MDS_REINT_SETXATTR,
-				fid, MDS_REINT, valid, xattr_name,
-				input, input_size, output_size, flags,
-				suppgid, request);
+				fid, MDS_REINT, obd_md_valid, name,
+				value, value_size, 0, xattr_flags, suppgid,
+				req);
 }
 
 static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
-			u64 valid, const char *xattr_name,
-			const char *input, int input_size, int output_size,
-			int flags, struct ptlrpc_request **request)
-{
-	return mdc_xattr_common(exp, &RQF_MDS_GETXATTR,
-				fid, MDS_GETXATTR, valid, xattr_name,
-				input, input_size, output_size, flags,
-				-1, request);
+			u64 obd_md_valid, const char *name, size_t buf_size,
+			struct ptlrpc_request **req)
+{
+	LASSERT(obd_md_valid == OBD_MD_FLXATTR ||
+		obd_md_valid == OBD_MD_FLXATTRLS);
+
+	return mdc_xattr_common(exp, &RQF_MDS_GETXATTR, fid, MDS_GETXATTR,
+				obd_md_valid, name, NULL, 0, buf_size, 0, -1,
+				req);
 }
 
 #ifdef CONFIG_FS_POSIX_ACL
-- 
1.8.3.1
