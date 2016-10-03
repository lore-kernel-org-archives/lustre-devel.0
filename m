From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:00 -0400
Subject: [lustre-devel] [PATCH 04/41] staging: lustre: obd: remove client
	Size on MDS support
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove the unused OBD MD API method md_done_writing(). Remove the
unused logcookie and struct md_open_data ** parameters from
md_setattr(). Remove the unused functions iattr_from_obdo(),
md_from_obdo(), and obdo_refresh_inode().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6047
Reviewed-on: http://review.whamcloud.com/13169
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 -
 drivers/staging/lustre/lustre/include/obd.h        |    7 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |   22 +----
 drivers/staging/lustre/lustre/llite/dir.c          |    3 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   12 +--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   31 +------
 drivers/staging/lustre/lustre/lov/lov_request.c    |   14 ---
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    5 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   20 +----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   58 ++-----------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   93 +-------------------
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 +-
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |   80 -----------------
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   65 --------------
 14 files changed, 26 insertions(+), 388 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 72eaee9..d164545 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2049,8 +2049,6 @@ enum md_op_flags {
 	MF_GET_MDT_IDX	  = (1 << 9),
 };
 
-#define MF_SOM_LOCAL_FLAGS (MF_SOM_CHANGE | MF_EPOCH_OPEN | MF_EPOCH_CLOSE)
-
 #define LUSTRE_BFLAG_UNCOMMITTED_WRITES   0x1
 
 /* these should be identical to their EXT4_*_FL counterparts, they are
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f6fc4dd..51d5487 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -789,8 +789,6 @@ struct md_op_data {
 	__u64		   op_valid;
 	loff_t		  op_attr_blocks;
 
-	/* Size-on-MDS epoch and flags. */
-	__u64		   op_ioepoch;
 	__u32		   op_flags;
 
 	/* Various operation flags. */
@@ -992,8 +990,6 @@ struct md_ops {
 	int (*create)(struct obd_export *, struct md_op_data *,
 		      const void *, size_t, umode_t, uid_t, gid_t,
 		      cfs_cap_t, __u64, struct ptlrpc_request **);
-	int (*done_writing)(struct obd_export *, struct md_op_data  *,
-			    struct md_open_data *);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
 		       const ldlm_policy_data_t *,
 		       struct lookup_intent *, struct md_op_data *,
@@ -1012,8 +1008,7 @@ struct md_ops {
 		      const char *, size_t, const char *, size_t,
 		      struct ptlrpc_request **);
 	int (*setattr)(struct obd_export *, struct md_op_data *, void *,
-		       size_t, void *, size_t, struct ptlrpc_request **,
-			 struct md_open_data **mod);
+		       size_t, struct ptlrpc_request **);
 	int (*sync)(struct obd_export *, const struct lu_fid *,
 		    struct ptlrpc_request **);
 	int (*read_page)(struct obd_export *, struct md_op_data *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 16094db..2ea102d 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -269,10 +269,8 @@ static inline int lprocfs_climp_check(struct obd_device *obd)
 struct inode;
 struct lu_attr;
 struct obdo;
-void obdo_refresh_inode(struct inode *dst, const struct obdo *src, u32 valid);
 
 void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj);
-void md_from_obdo(struct md_op_data *op_data, const struct obdo *oa, u32 valid);
 
 #define OBT(dev)	(dev)->obd_type
 #define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->op
@@ -1346,18 +1344,6 @@ static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
-static inline int md_done_writing(struct obd_export *exp,
-				  struct md_op_data *op_data,
-				  struct md_open_data *mod)
-{
-	int rc;
-
-	EXP_CHECK_MD_OP(exp, done_writing);
-	EXP_MD_COUNTER_INCREMENT(exp, done_writing);
-	rc = MDP(exp->exp_obd, done_writing)(exp, op_data, mod);
-	return rc;
-}
-
 static inline int md_enqueue(struct obd_export *exp,
 			     struct ldlm_enqueue_info *einfo,
 			     const ldlm_policy_data_t *policy,
@@ -1428,16 +1414,14 @@ static inline int md_rename(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
-			     void *ea, size_t ealen, void *ea2, size_t ea2len,
-			     struct ptlrpc_request **request,
-			     struct md_open_data **mod)
+			     void *ea, size_t ealen,
+			     struct ptlrpc_request **request)
 {
 	int rc;
 
 	EXP_CHECK_MD_OP(exp, setattr);
 	EXP_MD_COUNTER_INCREMENT(exp, setattr);
-	rc = MDP(exp->exp_obd, setattr)(exp, op_data, ea, ealen,
-					ea2, ea2len, request, mod);
+	rc = MDP(exp->exp_obd, setattr)(exp, op_data, ea, ealen, request);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 7f32a53..3641327 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -501,8 +501,7 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		return PTR_ERR(op_data);
 
 	/* swabbing is done in lov_setstripe() on server side */
-	rc = md_setattr(sbi->ll_md_exp, op_data, lump, lum_size,
-			NULL, 0, &req, NULL);
+	rc = md_setattr(sbi->ll_md_exp, op_data, lump, lum_size, &req);
 	ll_finish_md_op_data(op_data);
 	ptlrpc_req_finished(req);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 4f83275..e75ab2f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1295,8 +1295,7 @@ void ll_clear_inode(struct inode *inode)
 
 #define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
 
-static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
-			 struct md_open_data **mod)
+static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 {
 	struct lustre_md md;
 	struct inode *inode = d_inode(dentry);
@@ -1309,8 +1308,7 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, NULL, 0,
-			&request, mod);
+	rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &request);
 	if (rc) {
 		ptlrpc_req_finished(request);
 		if (rc == -ENOENT) {
@@ -1372,7 +1370,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	struct inode *inode = d_inode(dentry);
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct md_op_data *op_data = NULL;
-	struct md_open_data *mod = NULL;
 	bool file_is_released = false;
 	int rc = 0;
 
@@ -1477,7 +1474,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 
 	memcpy(&op_data->op_attr, attr, sizeof(*attr));
 
-	rc = ll_md_setattr(dentry, op_data, &mod);
+	rc = ll_md_setattr(dentry, op_data);
 	if (rc)
 		goto out;
 
@@ -1896,8 +1893,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		op_data->op_attr_flags = flags;
 		op_data->op_attr.ia_valid |= ATTR_ATTR_FLAG;
-		rc = md_setattr(sbi->ll_md_exp, op_data,
-				NULL, 0, NULL, 0, &req, NULL);
+		rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &req);
 		ll_finish_md_op_data(op_data);
 		ptlrpc_req_finished(req);
 		if (rc)
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7dbb2b9..b401ffb 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1728,27 +1728,6 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	return rc;
 }
 
-static int lmv_done_writing(struct obd_export *exp,
-			    struct md_op_data *op_data,
-			    struct md_open_data *mod)
-{
-	struct obd_device     *obd = exp->exp_obd;
-	struct lmv_obd	*lmv = &obd->u.lmv;
-	struct lmv_tgt_desc   *tgt;
-	int		    rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
-	tgt = lmv_find_target(lmv, &op_data->op_fid1);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
-
-	rc = md_done_writing(tgt->ltd_exp, op_data, mod);
-	return rc;
-}
-
 static int
 lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	    const ldlm_policy_data_t *policy,
@@ -2065,9 +2044,7 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 }
 
 static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
-		       void *ea, size_t ealen, void *ea2, size_t ea2len,
-		       struct ptlrpc_request **request,
-		       struct md_open_data **mod)
+		       void *ea, size_t ealen, struct ptlrpc_request **request)
 {
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
@@ -2086,10 +2063,7 @@ static int lmv_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(tgt))
 		return PTR_ERR(tgt);
 
-	rc = md_setattr(tgt->ltd_exp, op_data, ea, ealen, ea2,
-			ea2len, request, mod);
-
-	return rc;
+	return md_setattr(tgt->ltd_exp, op_data, ea, ealen, request);
 }
 
 static int lmv_sync(struct obd_export *exp, const struct lu_fid *fid,
@@ -3363,7 +3337,6 @@ static struct md_ops lmv_md_ops = {
 	.null_inode		= lmv_null_inode,
 	.close			= lmv_close,
 	.create			= lmv_create,
-	.done_writing		= lmv_done_writing,
 	.enqueue		= lmv_enqueue,
 	.getattr		= lmv_getattr,
 	.getxattr		= lmv_getxattr,
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 09dcaf4..8e40702 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -214,15 +214,6 @@ static int common_attr_done(struct lov_request_set *set)
 		CERROR("No stripes had valid attrs\n");
 		rc = -EIO;
 	}
-	if ((set->set_oi->oi_oa->o_valid & OBD_MD_FLEPOCH) &&
-	    (set->set_oi->oi_md->lsm_stripe_count != attrset)) {
-		/* When we take attributes of some epoch, we require all the
-		 * ost to be active.
-		 */
-		CERROR("Not all the stripes had valid attrs\n");
-		rc = -EIO;
-		goto out;
-	}
 
 	tmp_oa->o_oi = set->set_oi->oi_oa->o_oi;
 	memcpy(set->set_oi->oi_oa, tmp_oa, sizeof(*set->set_oi->oi_oa));
@@ -284,11 +275,6 @@ int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
 
 		if (!lov_check_and_wait_active(lov, loi->loi_ost_idx)) {
 			CDEBUG(D_HA, "lov idx %d inactive\n", loi->loi_ost_idx);
-			if (oinfo->oi_oa->o_valid & OBD_MD_FLEPOCH) {
-				/* SOM requires all the OSTs to be active. */
-				rc = -EIO;
-				goto out_set;
-			}
 			continue;
 		}
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index f446c1c..d2af8e7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -46,7 +46,7 @@ void mdc_readdir_pack(struct ptlrpc_request *req, __u64 pgoff, size_t size,
 void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, u32 flags,
 		      struct md_op_data *data, size_t ea_size);
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		      void *ea, size_t ealen, void *ea2, size_t ea2len);
+		      void *ea, size_t ealen);
 void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 		     const void *data, size_t datalen, umode_t mode, uid_t uid,
 		     gid_t gid, cfs_cap_t capability, __u64 rdev);
@@ -105,8 +105,7 @@ int mdc_rename(struct obd_export *exp, struct md_op_data *op_data,
 	       const char *new, size_t newlen,
 	       struct ptlrpc_request **request);
 int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
-		void *ea, size_t ealen, void *ea2, size_t ea2len,
-		struct ptlrpc_request **request, struct md_open_data **mod);
+		void *ea, size_t ealen, struct ptlrpc_request **request);
 int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	       struct ptlrpc_request **request);
 int mdc_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index aac7e04..709440b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -139,7 +139,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec->cr_time     = op_data->op_mod_time;
 	rec->cr_suppgid1 = op_data->op_suppgids[0];
 	rec->cr_suppgid2 = op_data->op_suppgids[1];
-	flags = op_data->op_flags & MF_SOM_LOCAL_FLAGS;
+	flags = 0;
 	if (op_data->op_bias & MDS_CREATE_VOLATILE)
 		flags |= MDS_OPEN_VOLATILE;
 	set_mrc_cr_flags(rec, flags);
@@ -302,15 +302,14 @@ static void mdc_ioepoch_pack(struct mdt_ioepoch *epoch,
 			     struct md_op_data *op_data)
 {
 	memcpy(&epoch->handle, &op_data->op_handle, sizeof(epoch->handle));
-	epoch->ioepoch = op_data->op_ioepoch;
-	epoch->flags = op_data->op_flags & MF_SOM_LOCAL_FLAGS;
+	epoch->ioepoch = 0;
+	epoch->flags = 0;
 }
 
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
-		      void *ea, size_t ealen, void *ea2, size_t ea2len)
+		      void *ea, size_t ealen)
 {
 	struct mdt_rec_setattr *rec;
-	struct mdt_ioepoch *epoch;
 	struct lov_user_md *lum = NULL;
 
 	CLASSERT(sizeof(struct mdt_rec_reint) ==
@@ -318,11 +317,6 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 	mdc_setattr_pack_rec(rec, op_data);
 
-	if (op_data->op_flags & (MF_SOM_CHANGE | MF_EPOCH_OPEN)) {
-		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
-		mdc_ioepoch_pack(epoch, op_data);
-	}
-
 	if (ealen == 0)
 		return;
 
@@ -335,12 +329,6 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	} else {
 		memcpy(lum, ea, ealen);
 	}
-
-	if (ea2len == 0)
-		return;
-
-	memcpy(req_capsule_client_get(&req->rq_pill, &RMF_LOGCOOKIES), ea2,
-	       ea2len);
 }
 
 void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index c921e47..6f62a95 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -99,8 +99,7 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 }
 
 int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
-		void *ea, size_t ealen, void *ea2, size_t ea2len,
-		struct ptlrpc_request **request, struct md_open_data **mod)
+		void *ea, size_t ealen, struct ptlrpc_request **request)
 {
 	LIST_HEAD(cancels);
 	struct ptlrpc_request *req;
@@ -122,12 +121,9 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		ldlm_lock_list_put(&cancels, l_bl_ast, count);
 		return -ENOMEM;
 	}
-	if ((op_data->op_flags & (MF_SOM_CHANGE | MF_EPOCH_OPEN)) == 0)
-		req_capsule_set_size(&req->rq_pill, &RMF_MDT_EPOCH, RCL_CLIENT,
-				     0);
+	req_capsule_set_size(&req->rq_pill, &RMF_MDT_EPOCH, RCL_CLIENT, 0);
 	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_CLIENT, ealen);
-	req_capsule_set_size(&req->rq_pill, &RMF_LOGCOOKIES, RCL_CLIENT,
-			     ea2len);
+	req_capsule_set_size(&req->rq_pill, &RMF_LOGCOOKIES, RCL_CLIENT, 0);
 
 	rc = mdc_prep_elc_req(exp, req, MDS_REINT, &cancels, count);
 	if (rc) {
@@ -141,57 +137,17 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 		CDEBUG(D_INODE, "setting mtime %ld, ctime %ld\n",
 		       LTIME_S(op_data->op_attr.ia_mtime),
 		       LTIME_S(op_data->op_attr.ia_ctime));
-	mdc_setattr_pack(req, op_data, ea, ealen, ea2, ea2len);
+	mdc_setattr_pack(req, op_data, ea, ealen);
 
 	ptlrpc_request_set_replen(req);
-	if (mod && (op_data->op_flags & MF_EPOCH_OPEN) &&
-	    req->rq_import->imp_replayable) {
-		LASSERT(!*mod);
-
-		*mod = obd_mod_alloc();
-		if (!*mod) {
-			DEBUG_REQ(D_ERROR, req, "Can't allocate md_open_data");
-		} else {
-			req->rq_replay = 1;
-			req->rq_cb_data = *mod;
-			(*mod)->mod_open_req = req;
-			req->rq_commit_cb = mdc_commit_open;
-			(*mod)->mod_is_create = true;
-			/**
-			 * Take an extra reference on \var mod, it protects \var
-			 * mod from being freed on eviction (commit callback is
-			 * called despite rq_replay flag).
-			 * Will be put on mdc_done_writing().
-			 */
-			obd_mod_get(*mod);
-		}
-	}
 
 	rc = mdc_reint(req, rpc_lock, LUSTRE_IMP_FULL);
 
-	/* Save the obtained info in the original RPC for the replay case. */
-	if (rc == 0 && (op_data->op_flags & MF_EPOCH_OPEN)) {
-		struct mdt_ioepoch *epoch;
-		struct mdt_body  *body;
-
-		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
-		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		epoch->handle = body->mbo_handle;
-		epoch->ioepoch = body->mbo_ioepoch;
-		req->rq_replay_cb = mdc_replay_open;
-	/** bug 3633, open may be committed and estale answer is not error */
-	} else if (rc == -ESTALE && (op_data->op_flags & MF_SOM_CHANGE)) {
-		rc = 0;
-	} else if (rc == -ERESTARTSYS) {
+	if (rc == -ERESTARTSYS)
 		rc = 0;
-	}
+
 	*request = req;
-	if (rc && req->rq_commit_cb) {
-		/* Put an extra reference on \var mod on error case. */
-		if (mod && *mod)
-			obd_mod_put(*mod);
-		req->rq_commit_cb(req);
-	}
+
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index f56ea64..3ef1bae 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -528,10 +528,6 @@ static int mdc_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
 	return 0;
 }
 
-/**
- * Handles both OPEN and SETATTR RPCs for OPEN-CLOSE and SETATTR-DONE_WRITING
- * RPC chains.
- */
 void mdc_replay_open(struct ptlrpc_request *req)
 {
 	struct md_open_data *mod = req->rq_cb_data;
@@ -565,7 +561,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 		__u32 opc = lustre_msg_get_opc(close_req->rq_reqmsg);
 		struct mdt_ioepoch *epoch;
 
-		LASSERT(opc == MDS_CLOSE || opc == MDS_DONE_WRITING);
+		LASSERT(opc == MDS_CLOSE);
 		epoch = req_capsule_client_get(&close_req->rq_pill,
 					       &RMF_MDT_EPOCH);
 		LASSERT(epoch);
@@ -715,22 +711,6 @@ static int mdc_clear_open_replay_data(struct obd_export *exp,
 	return 0;
 }
 
-/* Prepares the request for the replay by the given reply */
-static void mdc_close_handle_reply(struct ptlrpc_request *req,
-				   struct md_op_data *op_data, int rc) {
-	struct mdt_body  *repbody;
-	struct mdt_ioepoch *epoch;
-
-	if (req && rc == -EAGAIN) {
-		repbody = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-		epoch = req_capsule_client_get(&req->rq_pill, &RMF_MDT_EPOCH);
-
-		epoch->flags |= MF_SOM_AU;
-		if (repbody->mbo_valid & OBD_MD_FLGETATTRLOCK)
-			op_data->op_flags |= MF_GETATTR_LOCK;
-	}
-}
-
 static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		     struct md_open_data *mod, struct ptlrpc_request **request)
 {
@@ -857,79 +837,9 @@ out:
 		obd_mod_put(mod);
 	}
 	*request = req;
-	mdc_close_handle_reply(req, op_data, rc);
 	return rc < 0 ? rc : saved_rc;
 }
 
-static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
-			    struct md_open_data *mod)
-{
-	struct obd_device     *obd = class_exp2obd(exp);
-	struct ptlrpc_request *req;
-	int		    rc;
-
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-				   &RQF_MDS_DONE_WRITING);
-	if (!req)
-		return -ENOMEM;
-
-	rc = ptlrpc_request_pack(req, LUSTRE_MDS_VERSION, MDS_DONE_WRITING);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return rc;
-	}
-
-	if (mod) {
-		LASSERTF(mod->mod_open_req &&
-			 mod->mod_open_req->rq_type != LI_POISON,
-			 "POISONED setattr %p!\n", mod->mod_open_req);
-
-		mod->mod_close_req = req;
-		DEBUG_REQ(D_HA, mod->mod_open_req, "matched setattr");
-		/* We no longer want to preserve this setattr for replay even
-		 * though the open was committed. b=3632, b=3633
-		 */
-		spin_lock(&mod->mod_open_req->rq_lock);
-		mod->mod_open_req->rq_replay = 0;
-		spin_unlock(&mod->mod_open_req->rq_lock);
-	}
-
-	mdc_close_pack(req, op_data);
-	ptlrpc_request_set_replen(req);
-
-	mdc_get_rpc_lock(obd->u.cli.cl_close_lock, NULL);
-	rc = ptlrpc_queue_wait(req);
-	mdc_put_rpc_lock(obd->u.cli.cl_close_lock, NULL);
-
-	if (rc == -ESTALE) {
-		/**
-		 * it can be allowed error after 3633 if open or setattr were
-		 * committed and server failed before close was sent.
-		 * Let's check if mod exists and return no error in that case
-		 */
-		if (mod) {
-			if (mod->mod_open_req->rq_committed)
-				rc = 0;
-		}
-	}
-
-	if (mod) {
-		if (rc != 0)
-			mod->mod_close_req = NULL;
-		LASSERT(mod->mod_open_req);
-		mdc_free_open(mod);
-
-		/* Since now, mod is accessed through setattr req only,
-		 * thus DW req does not keep a reference on mod anymore.
-		 */
-		obd_mod_put(mod);
-	}
-
-	mdc_close_handle_reply(req, op_data, rc);
-	ptlrpc_req_finished(req);
-	return rc;
-}
-
 static int mdc_getpage(struct obd_export *exp, const struct lu_fid *fid,
 		       u64 offset, struct page **pages, int npages,
 		       struct ptlrpc_request **request)
@@ -2889,7 +2799,6 @@ static struct md_ops mdc_md_ops = {
 	.null_inode		= mdc_null_inode,
 	.close			= mdc_close,
 	.create			= mdc_create,
-	.done_writing		= mdc_done_writing,
 	.enqueue		= mdc_enqueue,
 	.getattr		= mdc_getattr,
 	.getattr_name		= mdc_getattr_name,
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index b42e109..af570c0 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -1,6 +1,6 @@
 obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 
-obdclass-y := linux/linux-module.o linux/linux-obdo.o linux/linux-sysctl.o \
+obdclass-y := linux/linux-module.o linux/linux-sysctl.o \
 	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
 	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
deleted file mode 100644
index 41b77a3..0000000
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ /dev/null
@@ -1,80 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/obdclass/linux/linux-obdo.c
- *
- * Object Devices Class Driver
- * These are the only exported functions, they provide some generic
- * infrastructure for managing object devices
- */
-
-#define DEBUG_SUBSYSTEM S_CLASS
-
-#include <linux/module.h>
-#include "../../include/obd_class.h"
-#include "../../include/lustre/lustre_idl.h"
-
-#include <linux/fs.h>
-
-void obdo_refresh_inode(struct inode *dst, const struct obdo *src, u32 valid)
-{
-	valid &= src->o_valid;
-
-	if (valid & (OBD_MD_FLCTIME | OBD_MD_FLMTIME))
-		CDEBUG(D_INODE,
-		       "valid %#llx, cur time %lu/%lu, new %llu/%llu\n",
-		       src->o_valid, LTIME_S(dst->i_mtime),
-		       LTIME_S(dst->i_ctime), src->o_mtime, src->o_ctime);
-
-	if (valid & OBD_MD_FLATIME && src->o_atime > LTIME_S(dst->i_atime))
-		LTIME_S(dst->i_atime) = src->o_atime;
-	if (valid & OBD_MD_FLMTIME && src->o_mtime > LTIME_S(dst->i_mtime))
-		LTIME_S(dst->i_mtime) = src->o_mtime;
-	if (valid & OBD_MD_FLCTIME && src->o_ctime > LTIME_S(dst->i_ctime))
-		LTIME_S(dst->i_ctime) = src->o_ctime;
-	if (valid & OBD_MD_FLSIZE)
-		i_size_write(dst, src->o_size);
-	/* optimum IO size */
-	if (valid & OBD_MD_FLBLKSZ && src->o_blksize > (1 << dst->i_blkbits))
-		dst->i_blkbits = ffs(src->o_blksize) - 1;
-
-	if (dst->i_blkbits < PAGE_SHIFT)
-		dst->i_blkbits = PAGE_SHIFT;
-
-	/* allocation of space */
-	if (valid & OBD_MD_FLBLOCKS && src->o_blocks > dst->i_blocks)
-		/*
-		 * XXX shouldn't overflow be checked here like in
-		 * obdo_to_inode().
-		 */
-		dst->i_blocks = src->o_blocks;
-}
-EXPORT_SYMBOL(obdo_refresh_inode);
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 79104a6..c52b9e0 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -124,68 +124,3 @@ void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj)
 	ioobj->ioo_max_brw = 0;
 }
 EXPORT_SYMBOL(obdo_to_ioobj);
-
-static void iattr_from_obdo(struct iattr *attr, const struct obdo *oa,
-			    u32 valid)
-{
-	valid &= oa->o_valid;
-
-	if (valid & (OBD_MD_FLCTIME | OBD_MD_FLMTIME))
-		CDEBUG(D_INODE, "valid %#llx, new time %llu/%llu\n",
-		       oa->o_valid, oa->o_mtime, oa->o_ctime);
-
-	attr->ia_valid = 0;
-	if (valid & OBD_MD_FLATIME) {
-		LTIME_S(attr->ia_atime) = oa->o_atime;
-		attr->ia_valid |= ATTR_ATIME;
-	}
-	if (valid & OBD_MD_FLMTIME) {
-		LTIME_S(attr->ia_mtime) = oa->o_mtime;
-		attr->ia_valid |= ATTR_MTIME;
-	}
-	if (valid & OBD_MD_FLCTIME) {
-		LTIME_S(attr->ia_ctime) = oa->o_ctime;
-		attr->ia_valid |= ATTR_CTIME;
-	}
-	if (valid & OBD_MD_FLSIZE) {
-		attr->ia_size = oa->o_size;
-		attr->ia_valid |= ATTR_SIZE;
-	}
-#if 0   /* you shouldn't be able to change a file's type with setattr */
-	if (valid & OBD_MD_FLTYPE) {
-		attr->ia_mode = (attr->ia_mode & ~S_IFMT) |
-				(oa->o_mode & S_IFMT);
-		attr->ia_valid |= ATTR_MODE;
-	}
-#endif
-	if (valid & OBD_MD_FLMODE) {
-		attr->ia_mode = (attr->ia_mode & S_IFMT) |
-				(oa->o_mode & ~S_IFMT);
-		attr->ia_valid |= ATTR_MODE;
-		if (!in_group_p(make_kgid(&init_user_ns, oa->o_gid)) &&
-		    !capable(CFS_CAP_FSETID))
-			attr->ia_mode &= ~S_ISGID;
-	}
-	if (valid & OBD_MD_FLUID) {
-		attr->ia_uid = make_kuid(&init_user_ns, oa->o_uid);
-		attr->ia_valid |= ATTR_UID;
-	}
-	if (valid & OBD_MD_FLGID) {
-		attr->ia_gid = make_kgid(&init_user_ns, oa->o_gid);
-		attr->ia_valid |= ATTR_GID;
-	}
-}
-
-void md_from_obdo(struct md_op_data *op_data, const struct obdo *oa, u32 valid)
-{
-	iattr_from_obdo(&op_data->op_attr, oa, valid);
-	if (valid & OBD_MD_FLBLOCKS) {
-		op_data->op_attr_blocks = oa->o_blocks;
-		op_data->op_attr.ia_valid |= ATTR_BLOCKS;
-	}
-	if (valid & OBD_MD_FLFLAGS) {
-		op_data->op_attr_flags = oa->o_flags;
-		op_data->op_attr.ia_valid |= ATTR_ATTR_FLAG;
-	}
-}
-EXPORT_SYMBOL(md_from_obdo);
-- 
1.7.1
