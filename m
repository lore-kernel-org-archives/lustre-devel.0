From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:09 -0400
Subject: [lustre-devel] [PATCH 13/41] staging: lustre: clio: use CIT_SETATTR
	for FSFILT_IOC_SETFLAGS
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add handling of inode flags to the handlers of CIT_SETATTR in lov and
osc. In the FSFILT_IOC_SETFLAGS case of ll_iocontrol() use
cl_setattr_ost() rather than obd_setattr_rqset() to set inode flags on
OST objects. Remove the then unused OBD API methods
obd_setattr_rqset() and obd_setattr_async() along with their
supporting functions.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
Reviewed-on: http://review.whamcloud.com/13422
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    3 +-
 .../staging/lustre/lustre/include/lustre_compat.h  |    2 +
 drivers/staging/lustre/lustre/include/obd.h        |    3 -
 drivers/staging/lustre/lustre/include/obd_class.h  |   39 ------
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    8 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   33 ++----
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   15 ++-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    6 -
 drivers/staging/lustre/lustre/lov/lov_io.c         |    2 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   82 ------------
 drivers/staging/lustre/lustre/lov/lov_request.c    |  131 --------------------
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    7 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   29 +++--
 drivers/staging/lustre/lustre/osc/osc_request.c    |   19 +---
 15 files changed, 60 insertions(+), 322 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 3af9aa3..0b66d02 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1772,9 +1772,10 @@ struct cl_io {
 		struct cl_io_rw_common ci_rw;
 		struct cl_setattr_io {
 			struct ost_lvb   sa_attr;
+			unsigned int		 sa_attr_flags;
 			unsigned int     sa_valid;
 			int		sa_stripe_index;
-			struct lu_fid  *sa_parent_fid;
+			const struct lu_fid	*sa_parent_fid;
 		} ci_setattr;
 		struct cl_fault_io {
 			/** page index within file. */
diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 567c438..300e96f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -74,4 +74,6 @@
 # define ext2_find_next_zero_bit  find_next_zero_bit_le
 #endif
 
+#define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
+
 #endif /* _LUSTRE_COMPAT_H */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 51d5487..fe05cc6 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -896,9 +896,6 @@ struct obd_ops {
 		       struct obdo *oa, struct obd_trans_info *oti);
 	int (*setattr)(const struct lu_env *, struct obd_export *exp,
 		       struct obd_info *oinfo, struct obd_trans_info *oti);
-	int (*setattr_async)(struct obd_export *exp, struct obd_info *oinfo,
-			     struct obd_trans_info *oti,
-			     struct ptlrpc_request_set *rqset);
 	int (*getattr)(const struct lu_env *env, struct obd_export *exp,
 		       struct obd_info *oinfo);
 	int (*getattr_async)(struct obd_export *exp, struct obd_info *oinfo,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 2ea102d..b2ced8b 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -749,45 +749,6 @@ static inline int obd_setattr(const struct lu_env *env, struct obd_export *exp,
 	return rc;
 }
 
-/* This performs all the requests set init/wait/destroy actions. */
-static inline int obd_setattr_rqset(struct obd_export *exp,
-				    struct obd_info *oinfo,
-				    struct obd_trans_info *oti)
-{
-	struct ptlrpc_request_set *set = NULL;
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, setattr_async);
-	EXP_COUNTER_INCREMENT(exp, setattr_async);
-
-	set =  ptlrpc_prep_set();
-	if (!set)
-		return -ENOMEM;
-
-	rc = OBP(exp->exp_obd, setattr_async)(exp, oinfo, oti, set);
-	if (rc == 0)
-		rc = ptlrpc_set_wait(set);
-	ptlrpc_set_destroy(set);
-	return rc;
-}
-
-/* This adds all the requests into @set if @set != NULL, otherwise
- * all requests are sent asynchronously without waiting for response.
- */
-static inline int obd_setattr_async(struct obd_export *exp,
-				    struct obd_info *oinfo,
-				    struct obd_trans_info *oti,
-				    struct ptlrpc_request_set *set)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, setattr_async);
-	EXP_COUNTER_INCREMENT(exp, setattr_async);
-
-	rc = OBP(exp->exp_obd, setattr_async)(exp, oinfo, oti, set);
-	return rc;
-}
-
 static inline int obd_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 			       int priority)
 {
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 084330d..64f4aed 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -80,7 +80,8 @@ int cl_inode_fini_refcheck;
  */
 static DEFINE_MUTEX(cl_inode_fini_guard);
 
-int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
+int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
+		   unsigned int attr_flags)
 {
 	struct lu_env *env;
 	struct cl_io  *io;
@@ -92,14 +93,15 @@ int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 		return PTR_ERR(env);
 
 	io = vvp_env_thread_io(env);
-	io->ci_obj = ll_i2info(inode)->lli_clob;
+	io->ci_obj = obj;
 
 	io->u.ci_setattr.sa_attr.lvb_atime = LTIME_S(attr->ia_atime);
 	io->u.ci_setattr.sa_attr.lvb_mtime = LTIME_S(attr->ia_mtime);
 	io->u.ci_setattr.sa_attr.lvb_ctime = LTIME_S(attr->ia_ctime);
 	io->u.ci_setattr.sa_attr.lvb_size = attr->ia_size;
+	io->u.ci_setattr.sa_attr_flags = attr_flags;
 	io->u.ci_setattr.sa_valid = attr->ia_valid;
-	io->u.ci_setattr.sa_parent_fid = ll_inode2fid(inode);
+	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&obj->co_lu);
 
 again:
 	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index b06cd3c..02541b1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1347,7 +1347,8 @@ int ll_page_sync_io(const struct lu_env *env, struct cl_io *io,
 int ll_getparent(struct file *file, struct getparent __user *arg);
 
 /* lcommon_cl.c */
-int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
+int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
+		   unsigned int attr_flags);
 
 extern struct lu_env *cl_inode_fini_env;
 extern int cl_inode_fini_refcheck;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index c7aab3f..9112a52 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1502,7 +1502,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		 */
 		if (attr->ia_valid & ATTR_SIZE)
 			down_write(&lli->lli_trunc_sem);
-		rc = cl_setattr_ost(inode, attr);
+		rc = cl_setattr_ost(ll_i2info(inode)->lli_clob, attr, 0);
 		if (attr->ia_valid & ATTR_SIZE)
 			up_write(&lli->lli_trunc_sem);
 	}
@@ -1879,9 +1879,9 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		return put_user(flags, (int __user *)arg);
 	}
 	case FSFILT_IOC_SETFLAGS: {
-		struct lov_stripe_md *lsm;
-		struct obd_info oinfo = { };
 		struct md_op_data *op_data;
+		struct cl_object *obj;
+		struct iattr *attr;
 
 		if (get_user(flags, (int __user *)arg))
 			return -EFAULT;
@@ -1901,30 +1901,17 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 
 		inode->i_flags = ll_ext_to_inode_flags(flags);
 
-		lsm = ccc_inode_lsm_get(inode);
-		if (!lsm_has_objects(lsm)) {
-			ccc_inode_lsm_put(inode, lsm);
+		obj = ll_i2info(inode)->lli_clob;
+		if (!obj)
 			return 0;
-		}
 
-		oinfo.oi_oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-		if (!oinfo.oi_oa) {
-			ccc_inode_lsm_put(inode, lsm);
+		attr = kzalloc(sizeof(*attr), GFP_NOFS);
+		if (!attr)
 			return -ENOMEM;
-		}
-		oinfo.oi_md = lsm;
-		oinfo.oi_oa->o_oi = lsm->lsm_oi;
-		oinfo.oi_oa->o_flags = flags;
-		oinfo.oi_oa->o_valid = OBD_MD_FLID | OBD_MD_FLFLAGS |
-				       OBD_MD_FLGROUP;
-		obdo_set_parent_fid(oinfo.oi_oa, &ll_i2info(inode)->lli_fid);
-		rc = obd_setattr_rqset(sbi->ll_dt_exp, &oinfo, NULL);
-		kmem_cache_free(obdo_cachep, oinfo.oi_oa);
-		ccc_inode_lsm_put(inode, lsm);
-
-		if (rc && rc != -EPERM && rc != -EACCES)
-			CERROR("osc_setattr_async fails: rc = %d\n", rc);
 
+		attr->ia_valid = ATTR_ATTR_FLAG;
+		rc = cl_setattr_ost(obj, attr, flags);
+		kfree(attr);
 		return rc;
 	}
 	default:
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 8187fa3..8f1964f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -571,9 +571,16 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 		if (new_size == 0)
 			enqflags = CEF_DISCARD_DATA;
 	} else {
-		if ((io->u.ci_setattr.sa_attr.lvb_mtime >=
-		     io->u.ci_setattr.sa_attr.lvb_ctime) ||
-		    (io->u.ci_setattr.sa_attr.lvb_atime >=
+		unsigned int valid = io->u.ci_setattr.sa_valid;
+
+		if (!(valid & TIMES_SET_FLAGS))
+			return 0;
+
+		if ((!(valid & ATTR_MTIME) ||
+		     io->u.ci_setattr.sa_attr.lvb_mtime >=
+		     io->u.ci_setattr.sa_attr.lvb_ctime) &&
+		    (!(valid & ATTR_ATIME) ||
+		     io->u.ci_setattr.sa_attr.lvb_atime >=
 		     io->u.ci_setattr.sa_attr.lvb_ctime))
 			return 0;
 		new_size = 0;
@@ -644,7 +651,7 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 	if (cl_io_is_trunc(io))
 		result = vvp_io_setattr_trunc(env, ios, inode,
 					io->u.ci_setattr.sa_attr.lvb_size);
-	if (result == 0)
+	if (!result && io->u.ci_setattr.sa_valid & TIMES_SET_FLAGS)
 		result = vvp_io_setattr_time(env, ios);
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 07e5ede..4743c65 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -155,12 +155,6 @@ int lov_update_common_set(struct lov_request_set *set,
 int lov_prep_getattr_set(struct obd_export *exp, struct obd_info *oinfo,
 			 struct lov_request_set **reqset);
 int lov_fini_getattr_set(struct lov_request_set *set);
-int lov_prep_setattr_set(struct obd_export *exp, struct obd_info *oinfo,
-			 struct obd_trans_info *oti,
-			 struct lov_request_set **reqset);
-int lov_update_setattr_set(struct lov_request_set *set,
-			   struct lov_request *req, int rc);
-int lov_fini_setattr_set(struct lov_request_set *set);
 int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 			struct lov_request_set **reqset);
 int lov_fini_statfs(struct obd_device *obd, struct obd_statfs *osfs,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index e75e5d2..369718e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -86,6 +86,8 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 	switch (io->ci_type) {
 	case CIT_SETATTR: {
 		io->u.ci_setattr.sa_attr = parent->u.ci_setattr.sa_attr;
+		io->u.ci_setattr.sa_attr_flags =
+					parent->u.ci_setattr.sa_attr_flags;
 		io->u.ci_setattr.sa_valid = parent->u.ci_setattr.sa_valid;
 		io->u.ci_setattr.sa_stripe_index = stripe;
 		io->u.ci_setattr.sa_parent_fid =
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 02c7087..30903fc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1047,87 +1047,6 @@ out:
 	return rc ? rc : err;
 }
 
-static int lov_setattr_interpret(struct ptlrpc_request_set *rqset,
-				 void *data, int rc)
-{
-	struct lov_request_set *lovset = (struct lov_request_set *)data;
-	int err;
-
-	if (rc)
-		atomic_set(&lovset->set_completes, 0);
-	err = lov_fini_setattr_set(lovset);
-	return rc ? rc : err;
-}
-
-/* If @oti is given, the request goes from MDS and responses from OSTs are not
- * needed. Otherwise, a client is waiting for responses.
- */
-static int lov_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
-			     struct obd_trans_info *oti,
-			     struct ptlrpc_request_set *rqset)
-{
-	struct lov_request_set *set;
-	struct lov_request *req;
-	struct lov_obd *lov;
-	int rc = 0;
-
-	LASSERT(oinfo);
-	ASSERT_LSM_MAGIC(oinfo->oi_md);
-	if (oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE) {
-		LASSERT(oti);
-		LASSERT(oti->oti_logcookies);
-	}
-
-	if (!exp || !exp->exp_obd)
-		return -ENODEV;
-
-	lov = &exp->exp_obd->u.lov;
-	rc = lov_prep_setattr_set(exp, oinfo, oti, &set);
-	if (rc)
-		return rc;
-
-	CDEBUG(D_INFO, "objid "DOSTID": %ux%u byte stripes\n",
-	       POSTID(&oinfo->oi_md->lsm_oi),
-	       oinfo->oi_md->lsm_stripe_count,
-	       oinfo->oi_md->lsm_stripe_size);
-
-	list_for_each_entry(req, &set->set_list, rq_link) {
-		if (oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE)
-			oti->oti_logcookies = set->set_cookies + req->rq_stripe;
-
-		CDEBUG(D_INFO, "objid " DOSTID "[%d] has subobj " DOSTID " at idx%u\n",
-		       POSTID(&oinfo->oi_oa->o_oi), req->rq_stripe,
-		       POSTID(&req->rq_oi.oi_oa->o_oi), req->rq_idx);
-
-		rc = obd_setattr_async(lov->lov_tgts[req->rq_idx]->ltd_exp,
-				       &req->rq_oi, oti, rqset);
-		if (rc) {
-			CERROR("error: setattr objid "DOSTID" subobj"
-			       DOSTID" on OST idx %d: rc = %d\n",
-			       POSTID(&set->set_oi->oi_oa->o_oi),
-			       POSTID(&req->rq_oi.oi_oa->o_oi),
-			       req->rq_idx, rc);
-			break;
-		}
-	}
-
-	/* If we are not waiting for responses on async requests, return. */
-	if (rc || !rqset || list_empty(&rqset->set_requests)) {
-		int err;
-
-		if (rc)
-			atomic_set(&set->set_completes, 0);
-		err = lov_fini_setattr_set(set);
-		return rc ? rc : err;
-	}
-
-	LASSERT(!rqset->set_interpret);
-	rqset->set_interpret = lov_setattr_interpret;
-	rqset->set_arg = (void *)set;
-
-	return 0;
-}
-
 int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
 {
 	struct lov_request_set *lovset = (struct lov_request_set *)data;
@@ -1613,7 +1532,6 @@ static struct obd_ops lov_obd_ops = {
 	.packmd         = lov_packmd,
 	.unpackmd       = lov_unpackmd,
 	.getattr_async  = lov_getattr_async,
-	.setattr_async  = lov_setattr_async,
 	.iocontrol      = lov_iocontrol,
 	.get_info       = lov_get_info,
 	.set_info_async = lov_set_info_async,
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 8e40702..048e597 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -311,137 +311,6 @@ out_set:
 	return rc;
 }
 
-int lov_fini_setattr_set(struct lov_request_set *set)
-{
-	int rc = 0;
-
-	if (!set)
-		return 0;
-	LASSERT(set->set_exp);
-	if (atomic_read(&set->set_completes)) {
-		rc = common_attr_done(set);
-		/* FIXME update qos data here */
-	}
-
-	lov_put_reqset(set);
-	return rc;
-}
-
-int lov_update_setattr_set(struct lov_request_set *set,
-			   struct lov_request *req, int rc)
-{
-	struct lov_obd *lov = &req->rq_rqset->set_exp->exp_obd->u.lov;
-	struct lov_stripe_md *lsm = req->rq_rqset->set_oi->oi_md;
-
-	lov_update_set(set, req, rc);
-
-	/* grace error on inactive ost */
-	if (rc && !(lov->lov_tgts[req->rq_idx] &&
-		    lov->lov_tgts[req->rq_idx]->ltd_active))
-		rc = 0;
-
-	if (rc == 0) {
-		if (req->rq_oi.oi_oa->o_valid & OBD_MD_FLCTIME)
-			lsm->lsm_oinfo[req->rq_stripe]->loi_lvb.lvb_ctime =
-				req->rq_oi.oi_oa->o_ctime;
-		if (req->rq_oi.oi_oa->o_valid & OBD_MD_FLMTIME)
-			lsm->lsm_oinfo[req->rq_stripe]->loi_lvb.lvb_mtime =
-				req->rq_oi.oi_oa->o_mtime;
-		if (req->rq_oi.oi_oa->o_valid & OBD_MD_FLATIME)
-			lsm->lsm_oinfo[req->rq_stripe]->loi_lvb.lvb_atime =
-				req->rq_oi.oi_oa->o_atime;
-	}
-
-	return rc;
-}
-
-/* The callback for osc_setattr_async that finalizes a request info when a
- * response is received.
- */
-static int cb_setattr_update(void *cookie, int rc)
-{
-	struct obd_info *oinfo = cookie;
-	struct lov_request *lovreq;
-
-	lovreq = container_of(oinfo, struct lov_request, rq_oi);
-	return lov_update_setattr_set(lovreq->rq_rqset, lovreq, rc);
-}
-
-int lov_prep_setattr_set(struct obd_export *exp, struct obd_info *oinfo,
-			 struct obd_trans_info *oti,
-			 struct lov_request_set **reqset)
-{
-	struct lov_request_set *set;
-	struct lov_obd *lov = &exp->exp_obd->u.lov;
-	int rc = 0, i;
-
-	set = kzalloc(sizeof(*set), GFP_NOFS);
-	if (!set)
-		return -ENOMEM;
-	lov_init_set(set);
-
-	set->set_exp = exp;
-	set->set_oi = oinfo;
-	if (oti && oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE)
-		set->set_cookies = oti->oti_logcookies;
-
-	for (i = 0; i < oinfo->oi_md->lsm_stripe_count; i++) {
-		struct lov_oinfo *loi = oinfo->oi_md->lsm_oinfo[i];
-		struct lov_request *req;
-
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (!lov_check_and_wait_active(lov, loi->loi_ost_idx)) {
-			CDEBUG(D_HA, "lov idx %d inactive\n", loi->loi_ost_idx);
-			continue;
-		}
-
-		req = kzalloc(sizeof(*req), GFP_NOFS);
-		if (!req) {
-			rc = -ENOMEM;
-			goto out_set;
-		}
-		req->rq_stripe = i;
-		req->rq_idx = loi->loi_ost_idx;
-
-		req->rq_oi.oi_oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
-		if (!req->rq_oi.oi_oa) {
-			kfree(req);
-			rc = -ENOMEM;
-			goto out_set;
-		}
-		memcpy(req->rq_oi.oi_oa, oinfo->oi_oa,
-		       sizeof(*req->rq_oi.oi_oa));
-		req->rq_oi.oi_oa->o_oi = loi->loi_oi;
-		req->rq_oi.oi_oa->o_stripe_idx = i;
-		req->rq_oi.oi_cb_up = cb_setattr_update;
-
-		if (oinfo->oi_oa->o_valid & OBD_MD_FLSIZE) {
-			int off = lov_stripe_offset(oinfo->oi_md,
-						    oinfo->oi_oa->o_size, i,
-						    &req->rq_oi.oi_oa->o_size);
-
-			if (off < 0 && req->rq_oi.oi_oa->o_size)
-				req->rq_oi.oi_oa->o_size--;
-
-			CDEBUG(D_INODE, "stripe %d has size %llu/%llu\n",
-			       i, req->rq_oi.oi_oa->o_size,
-			       oinfo->oi_oa->o_size);
-		}
-		lov_set_add_req(req, set);
-	}
-	if (!set->set_count) {
-		rc = -EIO;
-		goto out_set;
-	}
-	*reqset = set;
-	return rc;
-out_set:
-	lov_fini_setattr_set(set);
-	return rc;
-}
-
 #define LOV_U64_MAX ((__u64)~0ULL)
 #define LOV_SUM_MAX(tot, add)					   \
 	do {							    \
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 9a61c9b..90ea0d1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -119,10 +119,9 @@ int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		   __u64 *flags, void *data, struct lustre_handle *lockh,
 		   int unref);
 
-int osc_setattr_async_base(struct obd_export *exp, struct obd_info *oinfo,
-			   struct obd_trans_info *oti,
-			   obd_enqueue_update_f upcall, void *cookie,
-			   struct ptlrpc_request_set *rqset);
+int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
+		      obd_enqueue_update_f upcall, void *cookie,
+		      struct ptlrpc_request_set *rqset);
 int osc_punch_base(struct obd_export *exp, struct obd_info *oinfo,
 		   obd_enqueue_update_f upcall, void *cookie,
 		   struct ptlrpc_request_set *rqset);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 47c6371..a96addf 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -524,11 +524,19 @@ static int osc_io_setattr_start(const struct lu_env *env,
 		oa->o_oi = loi->loi_oi;
 		obdo_set_parent_fid(oa, io->u.ci_setattr.sa_parent_fid);
 		oa->o_stripe_idx = io->u.ci_setattr.sa_stripe_index;
-		oa->o_mtime = attr->cat_mtime;
-		oa->o_atime = attr->cat_atime;
-		oa->o_ctime = attr->cat_ctime;
-		oa->o_valid |= OBD_MD_FLID | OBD_MD_FLGROUP | OBD_MD_FLATIME |
-			       OBD_MD_FLCTIME | OBD_MD_FLMTIME;
+		oa->o_valid |= OBD_MD_FLID | OBD_MD_FLGROUP;
+		if (ia_valid & ATTR_CTIME) {
+			oa->o_valid |= OBD_MD_FLCTIME;
+			oa->o_ctime = attr->cat_ctime;
+		}
+		if (ia_valid & ATTR_ATIME) {
+			oa->o_valid |= OBD_MD_FLATIME;
+			oa->o_atime = attr->cat_atime;
+		}
+		if (ia_valid & ATTR_MTIME) {
+			oa->o_valid |= OBD_MD_FLMTIME;
+			oa->o_mtime = attr->cat_mtime;
+		}
 		if (ia_valid & ATTR_SIZE) {
 			oa->o_size = size;
 			oa->o_blocks = OBD_OBJECT_EOF;
@@ -541,6 +549,10 @@ static int osc_io_setattr_start(const struct lu_env *env,
 		} else {
 			LASSERT(oio->oi_lockless == 0);
 		}
+		if (ia_valid & ATTR_ATTR_FLAG) {
+			oa->o_flags = io->u.ci_setattr.sa_attr_flags;
+			oa->o_valid |= OBD_MD_FLFLAGS;
+		}
 
 		oinfo.oi_oa = oa;
 		init_completion(&cbargs->opc_sync);
@@ -550,10 +562,9 @@ static int osc_io_setattr_start(const struct lu_env *env,
 						&oinfo, osc_async_upcall,
 						cbargs, PTLRPCD_SET);
 		else
-			result = osc_setattr_async_base(osc_export(cl2osc(obj)),
-							&oinfo, NULL,
-							osc_async_upcall,
-							cbargs, PTLRPCD_SET);
+			result = osc_setattr_async(osc_export(cl2osc(obj)),
+						   &oinfo, osc_async_upcall,
+						   cbargs, PTLRPCD_SET);
 		cbargs->opc_rpc_sent = result == 0;
 	}
 	return result;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 963a485..de2f522 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -341,10 +341,9 @@ out:
 	return rc;
 }
 
-int osc_setattr_async_base(struct obd_export *exp, struct obd_info *oinfo,
-			   struct obd_trans_info *oti,
-			   obd_enqueue_update_f upcall, void *cookie,
-			   struct ptlrpc_request_set *rqset)
+int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
+		      obd_enqueue_update_f upcall, void *cookie,
+		      struct ptlrpc_request_set *rqset)
 {
 	struct ptlrpc_request *req;
 	struct osc_setattr_args *sa;
@@ -360,9 +359,6 @@ int osc_setattr_async_base(struct obd_export *exp, struct obd_info *oinfo,
 		return rc;
 	}
 
-	if (oti && oinfo->oi_oa->o_valid & OBD_MD_FLCOOKIE)
-		oinfo->oi_oa->o_lcookie = *oti->oti_logcookies;
-
 	osc_pack_req_body(req, oinfo);
 
 	ptlrpc_request_set_replen(req);
@@ -390,14 +386,6 @@ int osc_setattr_async_base(struct obd_export *exp, struct obd_info *oinfo,
 	return 0;
 }
 
-static int osc_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
-			     struct obd_trans_info *oti,
-			     struct ptlrpc_request_set *rqset)
-{
-	return osc_setattr_async_base(exp, oinfo, oti,
-				      oinfo->oi_cb_up, oinfo, rqset);
-}
-
 static int osc_create(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa, struct obd_trans_info *oti)
 {
@@ -3013,7 +3001,6 @@ static struct obd_ops osc_obd_ops = {
 	.getattr        = osc_getattr,
 	.getattr_async  = osc_getattr_async,
 	.setattr        = osc_setattr,
-	.setattr_async  = osc_setattr_async,
 	.iocontrol      = osc_iocontrol,
 	.set_info_async = osc_set_info_async,
 	.import_event   = osc_import_event,
-- 
1.7.1
