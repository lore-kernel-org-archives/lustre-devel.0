From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 14:07:30 -0400
Subject: [lustre-devel] [PATCH 6/7] staging: lustre: obd: decruft
	md_enqueue() and md_intent_lock()
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471630051-26700-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove the lmm and lmmsize parameters from both functions, storing
that data in md_op_data when needed. Remove the unused lookup_flags
parameter from md_intent_lock(), and the unused reqp parameter from
md_enqueue(). Add a union ldlm_policy_data * parameter to
md_enqueue(). Remove the unused function lmv_enqueue_remote().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/10205
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |    7 +-
 drivers/staging/lustre/lustre/include/obd_class.h |   18 ++---
 drivers/staging/lustre/lustre/llite/file.c        |   39 +++++------
 drivers/staging/lustre/lustre/llite/namei.c       |    4 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c |   12 ++--
 drivers/staging/lustre/lustre/lmv/lmv_intent.c    |   50 ++++++--------
 drivers/staging/lustre/lustre/lmv/lmv_internal.h  |    3 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       |   72 +-------------------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h  |   10 ++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c     |   47 +++++--------
 drivers/staging/lustre/lustre/mdc/mdc_request.c   |    2 +-
 11 files changed, 90 insertions(+), 174 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6fc0bcc..ac620fd 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -747,6 +747,7 @@ struct md_op_data {
 	__u32		   op_fsgid;
 	cfs_cap_t	       op_cap;
 	void		   *op_data;
+	size_t			op_data_size;
 
 	/* iattr fields and blocks. */
 	struct iattr	    op_attr;
@@ -967,15 +968,15 @@ struct md_ops {
 	int (*done_writing)(struct obd_export *, struct md_op_data  *,
 			    struct md_open_data *);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
+		       const ldlm_policy_data_t *,
 		       struct lookup_intent *, struct md_op_data *,
-		       struct lustre_handle *, void *, int,
-		       struct ptlrpc_request **, __u64);
+		       struct lustre_handle *, __u64);
 	int (*getattr)(struct obd_export *, struct md_op_data *,
 		       struct ptlrpc_request **);
 	int (*getattr_name)(struct obd_export *, struct md_op_data *,
 			    struct ptlrpc_request **);
 	int (*intent_lock)(struct obd_export *, struct md_op_data *,
-			   void *, int, struct lookup_intent *, int,
+			   struct lookup_intent *,
 			   struct ptlrpc_request **,
 			   ldlm_blocking_callback, __u64);
 	int (*link)(struct obd_export *, struct md_op_data *,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index fe1af94..79fc041 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1410,19 +1410,18 @@ static inline int md_done_writing(struct obd_export *exp,
 
 static inline int md_enqueue(struct obd_export *exp,
 			     struct ldlm_enqueue_info *einfo,
+			     const ldlm_policy_data_t *policy,
 			     struct lookup_intent *it,
 			     struct md_op_data *op_data,
 			     struct lustre_handle *lockh,
-			     void *lmm, int lmmsize,
-			     struct ptlrpc_request **req,
 			     __u64 extra_lock_flags)
 {
 	int rc;
 
 	EXP_CHECK_MD_OP(exp, enqueue);
 	EXP_MD_COUNTER_INCREMENT(exp, enqueue);
-	rc = MDP(exp->exp_obd, enqueue)(exp, einfo, it, op_data, lockh,
-					lmm, lmmsize, req, extra_lock_flags);
+	rc = MDP(exp->exp_obd, enqueue)(exp, einfo, policy, it, op_data, lockh,
+					extra_lock_flags);
 	return rc;
 }
 
@@ -1439,9 +1438,9 @@ static inline int md_getattr_name(struct obd_export *exp,
 }
 
 static inline int md_intent_lock(struct obd_export *exp,
-				 struct md_op_data *op_data, void *lmm,
-				 int lmmsize, struct lookup_intent *it,
-				 int lookup_flags, struct ptlrpc_request **reqp,
+				 struct md_op_data *op_data,
+				 struct lookup_intent *it,
+				 struct ptlrpc_request **reqp,
 				 ldlm_blocking_callback cb_blocking,
 				 __u64 extra_lock_flags)
 {
@@ -1449,9 +1448,8 @@ static inline int md_intent_lock(struct obd_export *exp,
 
 	EXP_CHECK_MD_OP(exp, intent_lock);
 	EXP_MD_COUNTER_INCREMENT(exp, intent_lock);
-	rc = MDP(exp->exp_obd, intent_lock)(exp, op_data, lmm, lmmsize,
-					    it, lookup_flags, reqp, cb_blocking,
-					    extra_lock_flags);
+	rc = MDP(exp->exp_obd, intent_lock)(exp, op_data, it, reqp,
+					    cb_blocking, extra_lock_flags);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 015b0ab..b680618 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -387,7 +387,7 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	struct dentry *parent = de->d_parent;
 	const char *name = NULL;
 	struct md_op_data *op_data;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req = NULL;
 	int len = 0, rc;
 
 	LASSERT(parent);
@@ -407,9 +407,11 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 				      O_RDWR, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
+	op_data->op_data = lmm;
+	op_data->op_data_size = lmmsize;
 
-	rc = md_intent_lock(sbi->ll_md_exp, op_data, lmm, lmmsize, itp,
-			    0 /*unused */, &req, ll_md_blocking_ast, 0);
+	rc = md_intent_lock(sbi->ll_md_exp, op_data, itp, &req,
+			    &ll_md_blocking_ast, 0);
 	ll_finish_md_op_data(op_data);
 	if (rc == -ESTALE) {
 		/* reason for keep own exit path - don`t flood log
@@ -759,7 +761,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	struct lookup_intent it = { .it_op = IT_OPEN };
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct md_op_data *op_data;
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req = NULL;
 	struct lustre_handle old_handle = { 0 };
 	struct obd_client_handle *och = NULL;
 	int rc;
@@ -826,8 +828,8 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 
 	it.it_flags = fmode | open_flags;
 	it.it_flags |= MDS_OPEN_LOCK | MDS_OPEN_BY_FID | MDS_OPEN_LEASE;
-	rc = md_intent_lock(sbi->ll_md_exp, op_data, NULL, 0, &it, 0, &req,
-			    ll_md_blocking_lease_ast,
+	rc = md_intent_lock(sbi->ll_md_exp, op_data, &it, &req,
+			    &ll_md_blocking_lease_ast,
 	/* LDLM_FL_NO_LRU: To not put the lease lock into LRU list, otherwise
 	 * it can be cancelled which may mislead applications that the lease is
 	 * broken;
@@ -835,7 +837,7 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 	 * open in ll_md_blocking_ast(). Otherwise as ll_md_blocking_lease_ast
 	 * doesn't deal with openhandle, so normal openhandle will be leaked.
 	 */
-				LDLM_FL_NO_LRU | LDLM_FL_EXCL);
+			    LDLM_FL_NO_LRU | LDLM_FL_EXCL);
 	ll_finish_md_op_data(op_data);
 	ptlrpc_req_finished(req);
 	if (rc < 0)
@@ -2806,8 +2808,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	       PFID(ll_inode2fid(inode)), flock.l_flock.pid, flags,
 	       einfo.ei_mode, flock.l_flock.start, flock.l_flock.end);
 
-	rc = md_enqueue(sbi->ll_md_exp, &einfo, NULL,
-			op_data, &lockh, &flock, 0, NULL /* req */, flags);
+	rc = md_enqueue(sbi->ll_md_exp, &einfo, &flock, NULL, op_data, &lockh,
+			flags);
 
 	/* Restore the file lock type if not TEST lock. */
 	if (!(flags & LDLM_FL_TEST_LOCK))
@@ -2819,8 +2821,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 
 	if (rc2 && file_lock->fl_type != F_UNLCK) {
 		einfo.ei_mode = LCK_NL;
-		md_enqueue(sbi->ll_md_exp, &einfo, NULL,
-			   op_data, &lockh, &flock, 0, NULL /* req */, flags);
+		md_enqueue(sbi->ll_md_exp, &einfo, &flock, NULL, op_data,
+			   &lockh, flags);
 		rc = rc2;
 	}
 
@@ -3059,12 +3061,8 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		if (IS_ERR(op_data))
 			return PTR_ERR(op_data);
 
-		rc = md_intent_lock(exp, op_data, NULL, 0,
-				    /* we are not interested in name
-				     * based lookup
-				     */
-				    &oit, 0, &req,
-				    ll_md_blocking_ast, 0);
+		rc = md_intent_lock(exp, op_data, &oit, &req,
+				    &ll_md_blocking_ast, 0);
 		ll_finish_md_op_data(op_data);
 		if (rc < 0) {
 			rc = ll_inode_revalidate_fini(inode, rc);
@@ -3742,8 +3740,8 @@ int ll_layout_refresh(struct inode *inode, __u32 *gen)
 	struct ldlm_enqueue_info einfo = {
 		.ei_type = LDLM_IBITS,
 		.ei_mode = LCK_CR,
-		.ei_cb_bl = ll_md_blocking_ast,
-		.ei_cb_cp = ldlm_completion_ast,
+		.ei_cb_bl = &ll_md_blocking_ast,
+		.ei_cb_cp = &ldlm_completion_ast,
 	};
 	int rc;
 
@@ -3789,8 +3787,7 @@ again:
 			  ll_get_fsname(inode->i_sb, NULL, 0),
 			  PFID(&lli->lli_fid), inode);
 
-	rc = md_enqueue(sbi->ll_md_exp, &einfo, &it, op_data, &lockh,
-			NULL, 0, NULL, 0);
+	rc = md_enqueue(sbi->ll_md_exp, &einfo, NULL, &it, op_data, &lockh, 0);
 	ptlrpc_req_finished(it.it_request);
 	it.it_request = NULL;
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index ee5a42e..6345099 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -562,8 +562,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (!IS_POSIXACL(parent) || !exp_connect_umask(ll_i2mdexp(parent)))
 		it->it_create_mode &= ~current_umask();
 
-	rc = md_intent_lock(ll_i2mdexp(parent), op_data, NULL, 0, it,
-			    lookup_flags, &req, ll_md_blocking_ast, 0);
+	rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
+			    &ll_md_blocking_ast, 0);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
 		retval = ERR_PTR(rc);
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index b66542c..0330d1a 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -270,10 +270,12 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 	struct lustre_handle lockh = { 0 };
 	struct md_op_data *op_data;
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ldlm_enqueue_info einfo = { .ei_type = LDLM_IBITS,
-					   .ei_mode = it_to_lock_mode(oit),
-					   .ei_cb_bl = ll_md_blocking_ast,
-					   .ei_cb_cp = ldlm_completion_ast };
+	struct ldlm_enqueue_info einfo = {
+		.ei_type = LDLM_IBITS,
+		.ei_mode = it_to_lock_mode(oit),
+		.ei_cb_bl = &ll_md_blocking_ast,
+		.ei_cb_cp = &ldlm_completion_ast,
+	};
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct obd_export *exp = sbi->ll_md_exp;
 	int rc;
@@ -304,7 +306,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 
 	op_data->op_valid = OBD_MD_FLXATTR | OBD_MD_FLXATTRLS;
 
-	rc = md_enqueue(exp, &einfo, oit, op_data, &lockh, NULL, 0, NULL, 0);
+	rc = md_enqueue(exp, &einfo, NULL, oit, op_data, &lockh, 0);
 	ll_finish_md_op_data(op_data);
 
 	if (rc < 0) {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 0559445..62f6bd0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -48,9 +48,8 @@
 #include "../include/lprocfs_status.h"
 #include "lmv_internal.h"
 
-static int lmv_intent_remote(struct obd_export *exp, void *lmm,
-			     int lmmsize, struct lookup_intent *it,
-			     const struct lu_fid *parent_fid, int flags,
+static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
+			     const struct lu_fid *parent_fid,
 			     struct ptlrpc_request **reqp,
 			     ldlm_blocking_callback cb_blocking,
 			     __u64 extra_lock_flags)
@@ -117,8 +116,8 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	CDEBUG(D_INODE, "REMOTE_INTENT with fid="DFID" -> mds #%d\n",
 	       PFID(&body->mbo_fid1), tgt->ltd_idx);
 
-	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
-			    flags, &req, cb_blocking, extra_lock_flags);
+	rc = md_intent_lock(tgt->ltd_exp, op_data, it, &req, cb_blocking,
+			    extra_lock_flags);
 	if (rc)
 		goto out_free_op_data;
 
@@ -206,8 +205,8 @@ int lmv_revalidate_slaves(struct obd_export *exp, struct mdt_body *mbody,
 		CDEBUG(D_INODE, "Revalidate slave "DFID" -> mds #%d\n",
 		       PFID(&fid), tgt->ltd_idx);
 
-		rc = md_intent_lock(tgt->ltd_exp, op_data, NULL, 0, &it, 0,
-				    &req, cb_blocking, extra_lock_flags);
+		rc = md_intent_lock(tgt->ltd_exp, op_data, &it, &req,
+				    cb_blocking, extra_lock_flags);
 		if (rc < 0)
 			goto cleanup;
 
@@ -298,8 +297,8 @@ cleanup:
  * may be split dir.
  */
 static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
-			   void *lmm, int lmmsize, struct lookup_intent *it,
-			   int flags, struct ptlrpc_request **reqp,
+			   struct lookup_intent *it,
+			   struct ptlrpc_request **reqp,
 			   ldlm_blocking_callback cb_blocking,
 			   __u64 extra_lock_flags)
 {
@@ -352,8 +351,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	       PFID(&op_data->op_fid1),
 	       PFID(&op_data->op_fid2), op_data->op_name, tgt->ltd_idx);
 
-	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it, flags,
-			    reqp, cb_blocking, extra_lock_flags);
+	rc = md_intent_lock(tgt->ltd_exp, op_data, it, reqp, cb_blocking,
+			    extra_lock_flags);
 	if (rc != 0)
 		return rc;
 	/*
@@ -371,9 +370,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 
 	/* Not cross-ref case, just get out of here. */
 	if (unlikely((body->mbo_valid & OBD_MD_MDS))) {
-		rc = lmv_intent_remote(exp, lmm, lmmsize, it, &op_data->op_fid1,
-				       flags, reqp, cb_blocking,
-				       extra_lock_flags);
+		rc = lmv_intent_remote(exp, it, &op_data->op_fid1, reqp,
+				       cb_blocking, extra_lock_flags);
 		if (rc != 0)
 			return rc;
 
@@ -390,8 +388,8 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
  */
 static int lmv_intent_lookup(struct obd_export *exp,
 			     struct md_op_data *op_data,
-			     void *lmm, int lmmsize, struct lookup_intent *it,
-			     int flags, struct ptlrpc_request **reqp,
+			     struct lookup_intent *it,
+			     struct ptlrpc_request **reqp,
 			     ldlm_blocking_callback cb_blocking,
 			     __u64 extra_lock_flags)
 {
@@ -434,8 +432,8 @@ static int lmv_intent_lookup(struct obd_export *exp,
 
 	op_data->op_bias &= ~MDS_CROSS_REF;
 
-	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
-			    flags, reqp, cb_blocking, extra_lock_flags);
+	rc = md_intent_lock(tgt->ltd_exp, op_data, it, reqp, cb_blocking,
+			    extra_lock_flags);
 	if (rc < 0)
 		return rc;
 
@@ -480,8 +478,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 
 			op_data->op_fid1 = oinfo->lmo_fid;
 			it->it_disposition &= ~DISP_ENQ_COMPLETE;
-			rc = md_intent_lock(tgt->ltd_exp, op_data, lmm,
-					    lmmsize, it, flags, reqp,
+			rc = md_intent_lock(tgt->ltd_exp, op_data, it, reqp,
 					    cb_blocking, extra_lock_flags);
 			if (rc)
 				return rc;
@@ -498,8 +495,8 @@ static int lmv_intent_lookup(struct obd_export *exp,
 
 	/* Not cross-ref case, just get out of here. */
 	if (unlikely((body->mbo_valid & OBD_MD_MDS))) {
-		rc = lmv_intent_remote(exp, lmm, lmmsize, it, NULL, flags,
-				       reqp, cb_blocking, extra_lock_flags);
+		rc = lmv_intent_remote(exp, it, NULL, reqp, cb_blocking,
+				       extra_lock_flags);
 		if (rc != 0)
 			return rc;
 		body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
@@ -511,8 +508,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 }
 
 int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
-		    void *lmm, int lmmsize, struct lookup_intent *it,
-		    int flags, struct ptlrpc_request **reqp,
+		    struct lookup_intent *it, struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
 		    __u64 extra_lock_flags)
 {
@@ -530,12 +526,10 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 
 	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_LAYOUT))
-		rc = lmv_intent_lookup(exp, op_data, lmm, lmmsize, it,
-				       flags, reqp, cb_blocking,
+		rc = lmv_intent_lookup(exp, op_data, it, reqp, cb_blocking,
 				       extra_lock_flags);
 	else if (it->it_op & IT_OPEN)
-		rc = lmv_intent_open(exp, op_data, lmm, lmmsize, it,
-				     flags, reqp, cb_blocking,
+		rc = lmv_intent_open(exp, op_data, it, reqp, cb_blocking,
 				     extra_lock_flags);
 	else
 		LBUG();
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index ea528ae..3ce17da 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -45,8 +45,7 @@
 int lmv_check_connect(struct obd_device *obd);
 
 int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
-		    void *lmm, int lmmsize, struct lookup_intent *it,
-		    int flags, struct ptlrpc_request **reqp,
+		    struct lookup_intent *it, struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
 		    __u64 extra_lock_flags);
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 44a334a..72249bb 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1812,70 +1812,10 @@ static int lmv_done_writing(struct obd_export *exp,
 }
 
 static int
-lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
-		   struct lookup_intent *it, struct md_op_data *op_data,
-		   struct lustre_handle *lockh, void *lmm, int lmmsize,
-		   __u64 extra_lock_flags)
-{
-	struct ptlrpc_request      *req = it->it_request;
-	struct obd_device	  *obd = exp->exp_obd;
-	struct lmv_obd	     *lmv = &obd->u.lmv;
-	struct lustre_handle	plock;
-	struct lmv_tgt_desc	*tgt;
-	struct md_op_data	  *rdata;
-	struct lu_fid	       fid1;
-	struct mdt_body	    *body;
-	int			 rc = 0;
-	int			 pmode;
-
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-
-	if (!(body->mbo_valid & OBD_MD_MDS))
-		return 0;
-
-	CDEBUG(D_INODE, "REMOTE_ENQUEUE '%s' on "DFID" -> "DFID"\n",
-	       LL_IT2STR(it), PFID(&op_data->op_fid1), PFID(&body->mbo_fid1));
-
-	/*
-	 * We got LOOKUP lock, but we really need attrs.
-	 */
-	pmode = it->it_lock_mode;
-	LASSERT(pmode != 0);
-	memcpy(&plock, lockh, sizeof(plock));
-	it->it_lock_mode = 0;
-	it->it_request = NULL;
-	fid1 = body->mbo_fid1;
-
-	ptlrpc_req_finished(req);
-
-	tgt = lmv_find_target(lmv, &fid1);
-	if (IS_ERR(tgt)) {
-		rc = PTR_ERR(tgt);
-		goto out;
-	}
-
-	rdata = kzalloc(sizeof(*rdata), GFP_NOFS);
-	if (!rdata) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
-	rdata->op_fid1 = fid1;
-	rdata->op_bias = MDS_CROSS_REF;
-
-	rc = md_enqueue(tgt->ltd_exp, einfo, it, rdata, lockh,
-			lmm, lmmsize, NULL, extra_lock_flags);
-	kfree(rdata);
-out:
-	ldlm_lock_decref(&plock, pmode);
-	return rc;
-}
-
-static int
 lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
+	    const ldlm_policy_data_t *policy,
 	    struct lookup_intent *it, struct md_op_data *op_data,
-	    struct lustre_handle *lockh, void *lmm, int lmmsize,
-	    struct ptlrpc_request **req, __u64 extra_lock_flags)
+	    struct lustre_handle *lockh, __u64 extra_lock_flags)
 {
 	struct obd_device	*obd = exp->exp_obd;
 	struct lmv_obd	   *lmv = &obd->u.lmv;
@@ -1896,13 +1836,9 @@ lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	CDEBUG(D_INODE, "ENQUEUE '%s' on "DFID" -> mds #%d\n",
 	       LL_IT2STR(it), PFID(&op_data->op_fid1), tgt->ltd_idx);
 
-	rc = md_enqueue(tgt->ltd_exp, einfo, it, op_data, lockh,
-			lmm, lmmsize, req, extra_lock_flags);
+	rc = md_enqueue(tgt->ltd_exp, einfo, policy, it, op_data, lockh,
+			extra_lock_flags);
 
-	if (rc == 0 && it && it->it_op == IT_OPEN) {
-		rc = lmv_enqueue_remote(exp, einfo, it, op_data, lockh,
-					lmm, lmmsize, extra_lock_flags);
-	}
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index f4d0c36..9e65cdb 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -69,16 +69,16 @@ int mdc_find_cbdata(struct obd_export *exp, const struct lu_fid *fid,
 		    ldlm_iterator_t it, void *data);
 
 int mdc_intent_lock(struct obd_export *exp,
-		    struct md_op_data *,
-		    void *lmm, int lmmsize,
-		    struct lookup_intent *, int,
+		    struct md_op_data *op_data,
+		    struct lookup_intent *it,
 		    struct ptlrpc_request **reqp,
 		    ldlm_blocking_callback cb_blocking,
 		    __u64 extra_lock_flags);
+
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
+		const ldlm_policy_data_t *policy,
 		struct lookup_intent *it, struct md_op_data *op_data,
-		struct lustre_handle *lockh, void *lmm, int lmmsize,
-		struct ptlrpc_request **req, __u64 extra_lock_flags);
+		struct lustre_handle *lockh, __u64 extra_lock_flags);
 
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode  mode,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 1c3b78d..89b4ae7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -249,15 +249,15 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	}
 }
 
-static struct ptlrpc_request *mdc_intent_open_pack(struct obd_export *exp,
-						   struct lookup_intent *it,
-						   struct md_op_data *op_data,
-						   void *lmm, int lmmsize,
-						   void *cb_data)
+static struct ptlrpc_request *
+mdc_intent_open_pack(struct obd_export *exp, struct lookup_intent *it,
+		     struct md_op_data *op_data)
 {
 	struct ptlrpc_request *req;
 	struct obd_device     *obddev = class_exp2obd(exp);
 	struct ldlm_intent    *lit;
+	const void *lmm = op_data->op_data;
+	int lmmsize = op_data->op_data_size;
 	LIST_HEAD(cancels);
 	int		    count = 0;
 	int		    mode;
@@ -708,9 +708,9 @@ static int mdc_finish_enqueue(struct obd_export *exp,
  * we don't know in advance the file type.
  */
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
+		const ldlm_policy_data_t *policy,
 		struct lookup_intent *it, struct md_op_data *op_data,
-		struct lustre_handle *lockh, void *lmm, int lmmsize,
-		struct ptlrpc_request **reqp, u64 extra_lock_flags)
+		struct lustre_handle *lockh, u64 extra_lock_flags)
 {
 	static const ldlm_policy_data_t lookup_policy = {
 		.l_inodebits = { MDS_INODELOCK_LOOKUP }
@@ -724,9 +724,8 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	static const ldlm_policy_data_t getxattr_policy = {
 		.l_inodebits = { MDS_INODELOCK_XATTR }
 	};
-	ldlm_policy_data_t const *policy = &lookup_policy;
 	struct obd_device *obddev = class_exp2obd(exp);
-	struct ptlrpc_request *req;
+	struct ptlrpc_request *req = NULL;
 	u64 flags, saved_flags = extra_lock_flags;
 	struct ldlm_res_id res_id;
 	int generation, resends = 0;
@@ -736,40 +735,32 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 
 	LASSERTF(!it || einfo->ei_type == LDLM_IBITS, "lock type %d\n",
 		 einfo->ei_type);
-
 	fid_build_reg_res_name(&op_data->op_fid1, &res_id);
 
 	if (it) {
+		LASSERT(!policy);
+
 		saved_flags |= LDLM_FL_HAS_INTENT;
-		if (it->it_op & (IT_UNLINK | IT_GETATTR | IT_READDIR))
+		if (it->it_op & (IT_OPEN | IT_UNLINK | IT_GETATTR | IT_READDIR))
 			policy = &update_policy;
 		else if (it->it_op & IT_LAYOUT)
 			policy = &layout_policy;
 		else if (it->it_op & (IT_GETXATTR | IT_SETXATTR))
 			policy = &getxattr_policy;
+		else
+			policy = &lookup_policy;
 	}
 
-	LASSERT(!reqp);
-
 	generation = obddev->u.cli.cl_import->imp_generation;
 resend:
 	flags = saved_flags;
 	if (!it) {
-		/* The only way right now is FLOCK, in this case we hide flock
-		 * policy as lmm, but lmmsize is 0
-		 */
-		LASSERT(lmm && lmmsize == 0);
+		/* The only way right now is FLOCK. */
 		LASSERTF(einfo->ei_type == LDLM_FLOCK, "lock type %d\n",
 			 einfo->ei_type);
-		policy = lmm;
 		res_id.name[3] = LDLM_FLOCK;
-		req = NULL;
 	} else if (it->it_op & IT_OPEN) {
-		req = mdc_intent_open_pack(exp, it, op_data, lmm, lmmsize,
-					   einfo->ei_cbdata);
-		policy = &update_policy;
-		einfo->ei_cbdata = NULL;
-		lmm = NULL;
+		req = mdc_intent_open_pack(exp, it, op_data);
 	} else if (it->it_op & IT_UNLINK) {
 		req = mdc_intent_unlink_pack(exp, it, op_data);
 	} else if (it->it_op & (IT_GETATTR | IT_LOOKUP)) {
@@ -1082,10 +1073,8 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
  * child lookup.
  */
 int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
-		    void *lmm, int lmmsize, struct lookup_intent *it,
-		    int lookup_flags, struct ptlrpc_request **reqp,
-		    ldlm_blocking_callback cb_blocking,
-		    __u64 extra_lock_flags)
+		    struct lookup_intent *it, struct ptlrpc_request **reqp,
+		    ldlm_blocking_callback cb_blocking, __u64 extra_lock_flags)
 {
 	struct ldlm_enqueue_info einfo = {
 		.ei_type	= LDLM_IBITS,
@@ -1128,7 +1117,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 		}
 	}
-	rc = mdc_enqueue(exp, &einfo, it, op_data, &lockh, lmm, lmmsize, NULL,
+	rc = mdc_enqueue(exp, &einfo, NULL, it, op_data, &lockh,
 			 extra_lock_flags);
 	if (rc < 0)
 		return rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 213f31b..88848d8 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1330,7 +1330,7 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	LASSERT(dir);
 	mapping = dir->i_mapping;
 
-	rc = mdc_intent_lock(exp, op_data, NULL, 0, &it, 0, &enq_req,
+	rc = mdc_intent_lock(exp, op_data, &it, &enq_req,
 			     cb_op->md_blocking_ast, 0);
 	if (enq_req)
 		ptlrpc_req_finished(enq_req);
-- 
1.7.1
