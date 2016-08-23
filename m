From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 23 Aug 2016 17:11:37 -0400
Subject: [lustre-devel] [PATCH 3/8] staging/lustre: avoid clearing i_nlink
	for inodes in use
In-Reply-To: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
References: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471986702-682922-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andrew Perepechko <andrew.perepechko@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Andrew Perepechko <andrew.perepechko@seagate.com>

The patch removes find_cbdata callbacks and clear_nlink
from dentry_iput path, since this piece of code makes
a few races possible.

The test case reproduces one of the possible races
described in LU-7925:

1) two hard links are created for the same file
2) the test calls stat(2) for link #1
3) in the middle of 2) the test opens and closes link #2
4) in the middle of 2) the test drops the ldlm locks and
   forces dentry reclaim via vm.drop_caches=2
5) in the middle of 2) ll_d_iput() clears i_nlink for
   the inode
6) the initial stat(2) continues and copies the wrong
   i_nlink value into st_nlink

Signed-off-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Seagate-bug-id: MRP-3271
Reviewed-on: http://review.whamcloud.com/19164
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7925
Reviewed-by: Wally Wang <wang@cray.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h        |  4 --
 drivers/staging/lustre/lustre/include/obd_class.h  | 25 ----------
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/llite/dcache.c       | 55 ----------------------
 drivers/staging/lustre/lustre/llite/file.c         |  2 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 42 -----------------
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 41 ----------------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |  3 --
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 22 ---------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  1 -
 drivers/staging/lustre/lustre/osc/osc_request.c    | 22 ---------
 11 files changed, 3 insertions(+), 215 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ed0fd41..f3d141b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -896,8 +896,6 @@ struct obd_ops {
 			struct niobuf_remote *remote, int pages,
 			struct niobuf_local *local,
 			struct obd_trans_info *oti, int rc);
-	int (*find_cbdata)(struct obd_export *, struct lov_stripe_md *,
-			   ldlm_iterator_t it, void *data);
 	int (*init_export)(struct obd_export *exp);
 	int (*destroy_export)(struct obd_export *exp);
 
@@ -958,8 +956,6 @@ struct cl_attr;
 struct md_ops {
 	int (*getstatus)(struct obd_export *, struct lu_fid *);
 	int (*null_inode)(struct obd_export *, const struct lu_fid *);
-	int (*find_cbdata)(struct obd_export *, const struct lu_fid *,
-			   ldlm_iterator_t, void *);
 	int (*close)(struct obd_export *, struct md_op_data *,
 		     struct md_open_data *, struct ptlrpc_request **);
 	int (*create)(struct obd_export *, struct md_op_data *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 4f48968..9702ad4 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1177,19 +1177,6 @@ static inline int obd_iocontrol(unsigned int cmd, struct obd_export *exp,
 	return rc;
 }
 
-static inline int obd_find_cbdata(struct obd_export *exp,
-				  struct lov_stripe_md *lsm,
-				  ldlm_iterator_t it, void *data)
-{
-	int rc;
-
-	EXP_CHECK_DT_OP(exp, find_cbdata);
-	EXP_COUNTER_INCREMENT(exp, find_cbdata);
-
-	rc = OBP(exp->exp_obd, find_cbdata)(exp, lsm, it, data);
-	return rc;
-}
-
 static inline void obd_import_event(struct obd_device *obd,
 				    struct obd_import *imp,
 				    enum obd_import_event event)
@@ -1358,18 +1345,6 @@ static inline int md_null_inode(struct obd_export *exp,
 	return rc;
 }
 
-static inline int md_find_cbdata(struct obd_export *exp,
-				 const struct lu_fid *fid,
-				 ldlm_iterator_t it, void *data)
-{
-	int rc;
-
-	EXP_CHECK_MD_OP(exp, find_cbdata);
-	EXP_MD_COUNTER_INCREMENT(exp, find_cbdata);
-	rc = MDP(exp->exp_obd, find_cbdata)(exp, fid, it, data);
-	return rc;
-}
-
 static inline int md_close(struct obd_export *exp, struct md_op_data *op_data,
 			   struct md_open_data *mod,
 			   struct ptlrpc_request **request)
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 4a9fe88..4d7a5c8 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -458,6 +458,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LOV_INIT			    0x1403
 #define OBD_FAIL_GLIMPSE_DELAY			    0x1404
 #define OBD_FAIL_LLITE_XATTR_ENOMEM		    0x1405
+#define OBD_FAIL_GETATTR_DELAY			    0x1409
 
 #define OBD_FAIL_FID_INDIR	0x1501
 #define OBD_FAIL_FID_INLMA	0x1502
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 463b1a3..f4b6f38 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -102,39 +102,6 @@ static int ll_dcompare(const struct dentry *dentry,
 	return 0;
 }
 
-static inline int return_if_equal(struct ldlm_lock *lock, void *data)
-{
-	return (ldlm_is_canceling(lock) && ldlm_is_discard_data(lock)) ?
-		LDLM_ITER_CONTINUE : LDLM_ITER_STOP;
-}
-
-/* find any ldlm lock of the inode in mdc and lov
- * return 0    not find
- *	1    find one
- *      < 0    error
- */
-static int find_cbdata(struct inode *inode)
-{
-	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct lov_stripe_md *lsm;
-	int rc = 0;
-
-	LASSERT(inode);
-	rc = md_find_cbdata(sbi->ll_md_exp, ll_inode2fid(inode),
-			    return_if_equal, NULL);
-	if (rc != 0)
-		return rc;
-
-	lsm = ccc_inode_lsm_get(inode);
-	if (!lsm)
-		return rc;
-
-	rc = obd_find_cbdata(sbi->ll_dt_exp, lsm, return_if_equal, NULL);
-	ccc_inode_lsm_put(inode, lsm);
-
-	return rc;
-}
-
 /**
  * Called when last reference to a dentry is dropped and dcache wants to know
  * whether or not it should cache it:
@@ -155,19 +122,6 @@ static int ll_ddelete(const struct dentry *de)
 	/* kernel >= 2.6.38 last refcount is decreased after this function. */
 	LASSERT(d_count(de) == 1);
 
-	/* Disable this piece of code temporarily because this is called
-	 * inside dcache_lock so it's not appropriate to do lots of work
-	 * here. ATTENTION: Before this piece of code enabling, LU-2487 must be
-	 * resolved.
-	 */
-#if 0
-	/* if not ldlm lock for this inode, set i_nlink to 0 so that
-	 * this inode can be recycled later b=20433
-	 */
-	if (d_really_is_positive(de) && !find_cbdata(d_inode(de)))
-		clear_nlink(d_inode(de));
-#endif
-
 	if (d_lustre_invalid((struct dentry *)de))
 		return 1;
 	return 0;
@@ -347,18 +301,9 @@ static int ll_revalidate_nd(struct dentry *dentry, unsigned int flags)
 	return ll_revalidate_dentry(dentry, flags);
 }
 
-static void ll_d_iput(struct dentry *de, struct inode *inode)
-{
-	LASSERT(inode);
-	if (!find_cbdata(inode))
-		clear_nlink(inode);
-	iput(inode);
-}
-
 const struct dentry_operations ll_d_ops = {
 	.d_revalidate = ll_revalidate_nd,
 	.d_release = ll_release,
 	.d_delete  = ll_ddelete,
-	.d_iput    = ll_d_iput,
 	.d_compare = ll_dcompare,
 };
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 13ff212..e2e81bf 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3191,6 +3191,8 @@ int ll_getattr(struct vfsmount *mnt, struct dentry *de, struct kstat *stat)
 	if (res)
 		return res;
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_GETATTR_DELAY, 30);
+
 	stat->dev = inode->i_sb->s_dev;
 	if (ll_need_32bit_api(sbi))
 		stat->ino = cl_fid_build_ino(&lli->lli_fid, 1);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 22b7896..dc752d5 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1609,47 +1609,6 @@ static int lmv_null_inode(struct obd_export *exp, const struct lu_fid *fid)
 	return 0;
 }
 
-static int lmv_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
-			   ldlm_iterator_t it, void *data)
-{
-	struct obd_device   *obd = exp->exp_obd;
-	struct lmv_obd      *lmv = &obd->u.lmv;
-	int tgt;
-	u32 i;
-	int		  rc;
-
-	rc = lmv_check_connect(obd);
-	if (rc)
-		return rc;
-
-	CDEBUG(D_INODE, "CBDATA for "DFID"\n", PFID(fid));
-
-	/*
-	 * With DNE every object can have two locks in different namespaces:
-	 * lookup lock in space of MDT storing direntry and update/open lock in
-	 * space of MDT storing inode. Try the MDT that the FID maps to first,
-	 * since this can be easily found, and only try others if that fails.
-	 */
-	for (i = 0, tgt = lmv_find_target_index(lmv, fid);
-	     i < lmv->desc.ld_tgt_count;
-	     i++, tgt = (tgt + 1) % lmv->desc.ld_tgt_count) {
-		if (tgt < 0) {
-			CDEBUG(D_HA, "%s: "DFID" is inaccessible: rc = %d\n",
-			       obd->obd_name, PFID(fid), tgt);
-			tgt = 0;
-		}
-
-		if (!lmv->tgts[tgt] || !lmv->tgts[tgt]->ltd_exp)
-			continue;
-
-		rc = md_find_cbdata(lmv->tgts[tgt]->ltd_exp, fid, it, data);
-		if (rc)
-			return rc;
-	}
-
-	return rc;
-}
-
 static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
 		     struct md_open_data *mod, struct ptlrpc_request **request)
 {
@@ -3373,7 +3332,6 @@ static struct obd_ops lmv_obd_ops = {
 static struct md_ops lmv_md_ops = {
 	.getstatus		= lmv_getstatus,
 	.null_inode		= lmv_null_inode,
-	.find_cbdata		= lmv_find_cbdata,
 	.close			= lmv_close,
 	.create			= lmv_create,
 	.done_writing		= lmv_done_writing,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 2817f38..265be08 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1268,46 +1268,6 @@ static int lov_setattr_async(struct obd_export *exp, struct obd_info *oinfo,
 	return 0;
 }
 
-/* find any ldlm lock of the inode in lov
- * return 0    not find
- *	1    find one
- *      < 0    error
- */
-static int lov_find_cbdata(struct obd_export *exp,
-			   struct lov_stripe_md *lsm, ldlm_iterator_t it,
-			   void *data)
-{
-	struct lov_obd *lov;
-	int rc = 0, i;
-
-	ASSERT_LSM_MAGIC(lsm);
-
-	if (!exp || !exp->exp_obd)
-		return -ENODEV;
-
-	lov = &exp->exp_obd->u.lov;
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_stripe_md submd;
-		struct lov_oinfo *loi = lsm->lsm_oinfo[i];
-
-		if (lov_oinfo_is_dummy(loi))
-			continue;
-
-		if (!lov->lov_tgts[loi->loi_ost_idx]) {
-			CDEBUG(D_HA, "lov idx %d NULL\n", loi->loi_ost_idx);
-			continue;
-		}
-
-		submd.lsm_oi = loi->loi_oi;
-		submd.lsm_stripe_count = 0;
-		rc = obd_find_cbdata(lov->lov_tgts[loi->loi_ost_idx]->ltd_exp,
-				     &submd, it, data);
-		if (rc != 0)
-			return rc;
-	}
-	return rc;
-}
-
 int lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
 {
 	struct lov_request_set *lovset = (struct lov_request_set *)data;
@@ -2326,7 +2286,6 @@ static struct obd_ops lov_obd_ops = {
 	.getattr_async  = lov_getattr_async,
 	.setattr_async  = lov_setattr_async,
 	.adjust_kms     = lov_adjust_kms,
-	.find_cbdata    = lov_find_cbdata,
 	.iocontrol      = lov_iocontrol,
 	.get_info       = lov_get_info,
 	.set_info_async = lov_set_info_async,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index f778a92..c10441d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -66,9 +66,6 @@ int mdc_set_lock_data(struct obd_export *exp,
 
 int mdc_null_inode(struct obd_export *exp, const struct lu_fid *fid);
 
-int mdc_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
-		    ldlm_iterator_t it, void *data);
-
 int mdc_intent_lock(struct obd_export *exp,
 		    struct md_op_data *op_data,
 		    struct lookup_intent *it,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 95dd291..54de46b 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -185,28 +185,6 @@ int mdc_null_inode(struct obd_export *exp,
 	return 0;
 }
 
-/* find any ldlm lock of the inode in mdc
- * return 0    not find
- *	1    find one
- *      < 0    error
- */
-int mdc_find_cbdata(struct obd_export *exp,
-		    const struct lu_fid *fid,
-		    ldlm_iterator_t it, void *data)
-{
-	struct ldlm_res_id res_id;
-	int rc = 0;
-
-	fid_build_reg_res_name((struct lu_fid *)fid, &res_id);
-	rc = ldlm_resource_iterate(class_exp2obd(exp)->obd_namespace, &res_id,
-				   it, data);
-	if (rc == LDLM_ITER_STOP)
-		return 1;
-	else if (rc == LDLM_ITER_CONTINUE)
-		return 0;
-	return rc;
-}
-
 static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
 {
 	/* Don't hold error requests for replay. */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 8369afd..75ce74f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2868,7 +2868,6 @@ static struct obd_ops mdc_obd_ops = {
 static struct md_ops mdc_md_ops = {
 	.getstatus		= mdc_getstatus,
 	.null_inode		= mdc_null_inode,
-	.find_cbdata		= mdc_find_cbdata,
 	.close			= mdc_close,
 	.create			= mdc_create,
 	.done_writing		= mdc_done_writing,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 53c191d..bdb329d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2119,27 +2119,6 @@ static int osc_set_data_with_check(struct lustre_handle *lockh,
 	return set;
 }
 
-/* find any ldlm lock of the inode in osc
- * return 0    not find
- *	1    find one
- *      < 0    error
- */
-static int osc_find_cbdata(struct obd_export *exp, struct lov_stripe_md *lsm,
-			   ldlm_iterator_t replace, void *data)
-{
-	struct ldlm_res_id res_id;
-	struct obd_device *obd = class_exp2obd(exp);
-	int rc = 0;
-
-	ostid_build_res_name(&lsm->lsm_oi, &res_id);
-	rc = ldlm_resource_iterate(obd->obd_namespace, &res_id, replace, data);
-	if (rc == LDLM_ITER_STOP)
-		return 1;
-	if (rc == LDLM_ITER_CONTINUE)
-		return 0;
-	return rc;
-}
-
 static int osc_enqueue_fini(struct ptlrpc_request *req,
 			    osc_enqueue_upcall_f upcall, void *cookie,
 			    struct lustre_handle *lockh, enum ldlm_mode mode,
@@ -3358,7 +3337,6 @@ static struct obd_ops osc_obd_ops = {
 	.getattr_async  = osc_getattr_async,
 	.setattr        = osc_setattr,
 	.setattr_async  = osc_setattr_async,
-	.find_cbdata    = osc_find_cbdata,
 	.iocontrol      = osc_iocontrol,
 	.get_info       = osc_get_info,
 	.set_info_async = osc_set_info_async,
-- 
2.7.4
