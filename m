From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:53 -0400
Subject: [lustre-devel] [PATCH 04/22] staging: lustre: ldlm: xattr locks are
 lost on mdt
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vitaly Fertman <vitaly.fertman@seagate.com>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@seagate.com>

On the server side mdt_intent_getxattr() can return EFAULT if a
buffer cannot be found, it is returned after lock_replace, where a
new lock is installed into lockp. An error forces ldlm_lock_enqueue()
to destroy the original lock, but ldlm_handle_enqueue0() drops the
reference on the new lock. The xattr client code implied intent
error is returned under a lock, which is immediately cancelled.
Check if a lock obtained and cancel it properly for error cases.
Note: we should support both cases for interop needs, an intent
error under a lock and with a lock abort. Keep returning a lock
with an intent error for interop purposes for now, to be dropped
later when client will get old enough. make all intent ops to
work through md_intent_lock: getxattr and layout, which should
extract the intent error.

Signed-off-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7433
Seagate-bug-id: MRP-3072 MRP-3137
Reviewed-on: http://review.whamcloud.com/17220
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Tested-by: Elena V. Gryaznova <elena.gryaznova@seagate.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |  3 +-
 drivers/staging/lustre/lustre/include/obd_class.h |  3 +-
 drivers/staging/lustre/lustre/llite/file.c        | 16 ++---
 drivers/staging/lustre/lustre/llite/xattr_cache.c | 75 ++++++++---------------
 drivers/staging/lustre/lustre/lmv/lmv_intent.c    | 12 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       |  7 +--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h  |  4 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c     | 66 ++++++++++++++------
 8 files changed, 95 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ea6056b..48cf7ab 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -909,8 +909,7 @@ struct md_ops {
 		      const void *, size_t, umode_t, uid_t, gid_t,
 		      cfs_cap_t, __u64, struct ptlrpc_request **);
 	int (*enqueue)(struct obd_export *, struct ldlm_enqueue_info *,
-		       const union ldlm_policy_data *,
-		       struct lookup_intent *, struct md_op_data *,
+		       const union ldlm_policy_data *, struct md_op_data *,
 		       struct lustre_handle *, __u64);
 	int (*getattr)(struct obd_export *, struct md_op_data *,
 		       struct ptlrpc_request **);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 176b63e..a76f016 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1241,7 +1241,6 @@ static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
 static inline int md_enqueue(struct obd_export *exp,
 			     struct ldlm_enqueue_info *einfo,
 			     const union ldlm_policy_data *policy,
-			     struct lookup_intent *it,
 			     struct md_op_data *op_data,
 			     struct lustre_handle *lockh,
 			     __u64 extra_lock_flags)
@@ -1250,7 +1249,7 @@ static inline int md_enqueue(struct obd_export *exp,
 
 	EXP_CHECK_MD_OP(exp, enqueue);
 	EXP_MD_COUNTER_INCREMENT(exp, enqueue);
-	rc = MDP(exp->exp_obd, enqueue)(exp, einfo, policy, it, op_data, lockh,
+	rc = MDP(exp->exp_obd, enqueue)(exp, einfo, policy, op_data, lockh,
 					extra_lock_flags);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ca5faea..0026fde 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2514,7 +2514,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	       PFID(ll_inode2fid(inode)), flock.l_flock.pid, flags,
 	       einfo.ei_mode, flock.l_flock.start, flock.l_flock.end);
 
-	rc = md_enqueue(sbi->ll_md_exp, &einfo, &flock, NULL, op_data, &lockh,
+	rc = md_enqueue(sbi->ll_md_exp, &einfo, &flock, op_data, &lockh,
 			flags);
 
 	/* Restore the file lock type if not TEST lock. */
@@ -2527,7 +2527,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	if (rc2 && file_lock->fl_type != F_UNLCK) {
 		einfo.ei_mode = LCK_NL;
-		md_enqueue(sbi->ll_md_exp, &einfo, &flock, NULL, op_data,
+		md_enqueue(sbi->ll_md_exp, &einfo, &flock, op_data,
 			   &lockh, flags);
 		rc = rc2;
 	}
@@ -3474,12 +3474,7 @@ static int ll_layout_refresh_locked(struct inode *inode)
 	struct lookup_intent   it;
 	struct lustre_handle   lockh;
 	enum ldlm_mode	       mode;
-	struct ldlm_enqueue_info einfo = {
-		.ei_type = LDLM_IBITS,
-		.ei_mode = LCK_CR,
-		.ei_cb_bl = &ll_md_blocking_ast,
-		.ei_cb_cp = &ldlm_completion_ast,
-	};
+	struct ptlrpc_request *req;
 	int rc;
 
 again:
@@ -3503,13 +3498,13 @@ static int ll_layout_refresh_locked(struct inode *inode)
 	/* have to enqueue one */
 	memset(&it, 0, sizeof(it));
 	it.it_op = IT_LAYOUT;
-	lockh.cookie = 0ULL;
 
 	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file " DFID "(%p)",
 			  ll_get_fsname(inode->i_sb, NULL, 0),
 			  PFID(&lli->lli_fid), inode);
 
-	rc = md_enqueue(sbi->ll_md_exp, &einfo, NULL, &it, op_data, &lockh, 0);
+	rc = md_intent_lock(sbi->ll_md_exp, op_data, &it, &req,
+			    &ll_md_blocking_ast, 0);
 	ptlrpc_req_finished(it.it_request);
 	it.it_request = NULL;
 
@@ -3522,6 +3517,7 @@ static int ll_layout_refresh_locked(struct inode *inode)
 	if (rc == 0) {
 		/* set lock data in case this is a new lock */
 		ll_set_lock_data(sbi->ll_md_exp, inode, &it, NULL);
+		lockh.cookie = it.it_lock_handle;
 		rc = ll_layout_lock_set(&lockh, mode, inode);
 		if (rc == -EAGAIN)
 			goto again;
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index ef66949..53dfaea 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -272,12 +272,6 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 	struct lustre_handle lockh = { 0 };
 	struct md_op_data *op_data;
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct ldlm_enqueue_info einfo = {
-		.ei_type = LDLM_IBITS,
-		.ei_mode = it_to_lock_mode(oit),
-		.ei_cb_bl = &ll_md_blocking_ast,
-		.ei_cb_cp = &ldlm_completion_ast,
-	};
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct obd_export *exp = sbi->ll_md_exp;
 	int rc;
@@ -308,8 +302,9 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 
 	op_data->op_valid = OBD_MD_FLXATTR | OBD_MD_FLXATTRLS;
 
-	rc = md_enqueue(exp, &einfo, NULL, oit, op_data, &lockh, 0);
+	rc = md_intent_lock(exp, op_data, oit, req, &ll_md_blocking_ast, 0);
 	ll_finish_md_op_data(op_data);
+	*req = oit->it_request;
 
 	if (rc < 0) {
 		CDEBUG(D_CACHE,
@@ -319,7 +314,6 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 		return rc;
 	}
 
-	*req = oit->it_request;
 out:
 	down_write(&lli->lli_xattrs_list_rwsem);
 	mutex_unlock(&lli->lli_xattrs_enq_lock);
@@ -330,16 +324,15 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 /**
  * Refill the xattr cache.
  *
- * Fetch and cache the whole of xattrs for @inode, acquiring
- * a read or a write xattr lock depending on operation in @oit.
- * Intent is dropped on exit unless the operation is setxattr.
+ * Fetch and cache the whole of xattrs for @inode, acquiring a read lock.
  *
  * \retval 0       no error occurred
  * \retval -EPROTO network protocol error
  * \retval -ENOMEM not enough memory for the cache
  */
-static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
+static int ll_xattr_cache_refill(struct inode *inode)
 {
+	struct lookup_intent oit = { .it_op = IT_GETXATTR };
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct ptlrpc_request *req = NULL;
 	const char *xdata, *xval, *xtail, *xvtail;
@@ -348,40 +341,31 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	__u32 *xsizes;
 	int rc, i;
 
-	rc = ll_xattr_find_get_lock(inode, oit, &req);
+	rc = ll_xattr_find_get_lock(inode, &oit, &req);
 	if (rc)
-		goto out_no_unlock;
+		goto err_req;
 
 	/* Do we have the data at this point? */
 	if (ll_xattr_cache_valid(lli)) {
 		ll_stats_ops_tally(sbi, LPROC_LL_GETXATTR_HITS, 1);
+		ll_intent_drop_lock(&oit);
 		rc = 0;
-		goto out_maybe_drop;
+		goto err_req;
 	}
 
 	/* Matched but no cache? Cancelled on error by a parallel refill. */
 	if (unlikely(!req)) {
 		CDEBUG(D_CACHE, "cancelled by a parallel getxattr\n");
+		ll_intent_drop_lock(&oit);
 		rc = -EIO;
-		goto out_maybe_drop;
-	}
-
-	if (oit->it_status < 0) {
-		CDEBUG(D_CACHE,
-		       "getxattr intent returned %d for fid " DFID "\n",
-		       oit->it_status, PFID(ll_inode2fid(inode)));
-		rc = oit->it_status;
-		/* xattr data is so large that we don't want to cache it */
-		if (rc == -ERANGE)
-			rc = -EAGAIN;
-		goto out_destroy;
+		goto err_unlock;
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	if (!body) {
 		CERROR("no MDT BODY in the refill xattr reply\n");
 		rc = -EPROTO;
-		goto out_destroy;
+		goto err_cancel;
 	}
 	/* do not need swab xattr data */
 	xdata = req_capsule_server_sized_get(&req->rq_pill, &RMF_EADATA,
@@ -393,7 +377,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	if (!xdata || !xval || !xsizes) {
 		CERROR("wrong setxattr reply\n");
 		rc = -EPROTO;
-		goto out_destroy;
+		goto err_cancel;
 	}
 
 	xtail = xdata + body->mbo_eadatasize;
@@ -429,7 +413,7 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 		}
 		if (rc < 0) {
 			ll_xattr_cache_destroy_locked(lli);
-			goto out_destroy;
+			goto err_cancel;
 		}
 		xdata += strlen(xdata) + 1;
 		xval  += *xsizes;
@@ -439,28 +423,24 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 	if (xdata != xtail || xval != xvtail)
 		CERROR("a hole in xattr data\n");
 
-	ll_set_lock_data(sbi->ll_md_exp, inode, oit, NULL);
-
-	goto out_maybe_drop;
-out_maybe_drop:
-
-		ll_intent_drop_lock(oit);
+	ll_set_lock_data(sbi->ll_md_exp, inode, &oit, NULL);
+	ll_intent_drop_lock(&oit);
 
-	if (rc != 0)
-		up_write(&lli->lli_xattrs_list_rwsem);
-out_no_unlock:
 	ptlrpc_req_finished(req);
-
 	return rc;
 
-out_destroy:
-	up_write(&lli->lli_xattrs_list_rwsem);
-
+err_cancel:
 	ldlm_lock_decref_and_cancel((struct lustre_handle *)
-					&oit->it_lock_handle,
-					oit->it_lock_mode);
+				    &oit.it_lock_handle,
+				    oit.it_lock_mode);
+err_unlock:
+	up_write(&lli->lli_xattrs_list_rwsem);
+err_req:
+	if (rc == -ERANGE)
+		rc = -EAGAIN;
 
-	goto out_no_unlock;
+	ptlrpc_req_finished(req);
+	return rc;
 }
 
 /**
@@ -480,7 +460,6 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 		       size_t size, __u64 valid)
 {
-	struct lookup_intent oit = { .it_op = IT_GETXATTR };
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc = 0;
 
@@ -489,7 +468,7 @@ int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 	down_read(&lli->lli_xattrs_list_rwsem);
 	if (!ll_xattr_cache_valid(lli)) {
 		up_read(&lli->lli_xattrs_list_rwsem);
-		rc = ll_xattr_cache_refill(inode, &oit);
+		rc = ll_xattr_cache_refill(inode);
 		if (rc)
 			return rc;
 		downgrade_write(&lli->lli_xattrs_list_rwsem);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 1793c9f..1e850fd 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -447,6 +447,9 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		}
 	}
 
+	if (!it_has_reply_body(it))
+		return 0;
+
 	/*
 	 * MDS has returned success. Probably name has been resolved in
 	 * remote inode. Let's check this.
@@ -483,7 +486,7 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	       (int)op_data->op_namelen, op_data->op_name,
 	       PFID(&op_data->op_fid1));
 
-	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_LAYOUT))
+	if (it->it_op & (IT_LOOKUP | IT_GETATTR | IT_LAYOUT | IT_GETXATTR))
 		rc = lmv_intent_lookup(exp, op_data, it, reqp, cb_blocking,
 				       extra_lock_flags);
 	else if (it->it_op & IT_OPEN)
@@ -497,7 +500,8 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 		if (it->it_lock_mode) {
 			lock_handle.cookie = it->it_lock_handle;
-			ldlm_lock_decref(&lock_handle, it->it_lock_mode);
+			ldlm_lock_decref_and_cancel(&lock_handle,
+						    it->it_lock_mode);
 		}
 
 		it->it_lock_handle = 0;
@@ -505,8 +509,8 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 		if (it->it_remote_lock_mode) {
 			lock_handle.cookie = it->it_remote_lock_handle;
-			ldlm_lock_decref(&lock_handle,
-					 it->it_remote_lock_mode);
+			ldlm_lock_decref_and_cancel(&lock_handle,
+						    it->it_remote_lock_mode);
 		}
 
 		it->it_remote_lock_handle = 0;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index e1c93cd..7198a63 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1652,8 +1652,7 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 
 static int
 lmv_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
-	    const union ldlm_policy_data *policy,
-	    struct lookup_intent *it, struct md_op_data *op_data,
+	    const union ldlm_policy_data *policy, struct md_op_data *op_data,
 	    struct lustre_handle *lockh, __u64 extra_lock_flags)
 {
 	struct obd_device	*obd = exp->exp_obd;
@@ -1669,8 +1668,8 @@ static int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	CDEBUG(D_INODE, "ENQUEUE on " DFID " -> mds #%u\n",
 	       PFID(&op_data->op_fid1), tgt->ltd_idx);
 
-	return md_enqueue(tgt->ltd_exp, einfo, policy, it, op_data, lockh,
-			extra_lock_flags);
+	return md_enqueue(tgt->ltd_exp, einfo, policy, op_data, lockh,
+			  extra_lock_flags);
 }
 
 static int
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index e0300c3..88ee3271 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -77,8 +77,8 @@ int mdc_intent_lock(struct obd_export *exp,
 
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		const union ldlm_policy_data *policy,
-		struct lookup_intent *it, struct md_op_data *op_data,
-		struct lustre_handle *lockh, __u64 extra_lock_flags);
+		struct md_op_data *op_data,
+		struct lustre_handle *lockh, u64 extra_lock_flags);
 
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode  mode,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 309ead1..253a545 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -688,10 +688,10 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 /* We always reserve enough space in the reply packet for a stripe MD, because
  * we don't know in advance the file type.
  */
-int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
-		const union ldlm_policy_data *policy,
-		struct lookup_intent *it, struct md_op_data *op_data,
-		struct lustre_handle *lockh, u64 extra_lock_flags)
+int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
+		     const union ldlm_policy_data *policy,
+		     struct lookup_intent *it, struct md_op_data *op_data,
+		     struct lustre_handle *lockh, u64 extra_lock_flags)
 {
 	static const union ldlm_policy_data lookup_policy = {
 		.l_inodebits = { MDS_INODELOCK_LOOKUP }
@@ -859,6 +859,15 @@ int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	return rc;
 }
 
+int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
+		const union ldlm_policy_data *policy,
+		struct md_op_data *op_data,
+		struct lustre_handle *lockh, u64 extra_lock_flags)
+{
+	return mdc_enqueue_base(exp, einfo, policy, NULL,
+				op_data, lockh, extra_lock_flags);
+}
+
 static int mdc_finish_intent_lock(struct obd_export *exp,
 				  struct ptlrpc_request *request,
 				  struct md_op_data *op_data,
@@ -866,9 +875,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 				  struct lustre_handle *lockh)
 {
 	struct lustre_handle old_lock;
-	struct mdt_body *mdt_body;
 	struct ldlm_lock *lock;
-	int rc;
+	int rc = 0;
 
 	LASSERT(request != LP_POISON);
 	LASSERT(request->rq_repmsg != LP_POISON);
@@ -876,23 +884,30 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	if (it->it_op & IT_READDIR)
 		return 0;
 
+	if (it->it_op & (IT_GETXATTR | IT_LAYOUT)) {
+		if (it->it_status != 0) {
+			rc = it->it_status;
+			goto out;
+		}
+		goto matching_lock;
+	}
+
 	if (!it_disposition(it, DISP_IT_EXECD)) {
 		/* The server failed before it even started executing the
 		 * intent, i.e. because it couldn't unpack the request.
 		 */
 		LASSERT(it->it_status != 0);
-		return it->it_status;
+		rc = it->it_status;
+		goto out;
 	}
+
 	rc = it_open_error(DISP_IT_EXECD, it);
 	if (rc)
-		return rc;
-
-	mdt_body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-	LASSERT(mdt_body);      /* mdc_enqueue checked */
+		goto out;
 
 	rc = it_open_error(DISP_LOOKUP_EXECD, it);
 	if (rc)
-		return rc;
+		goto out;
 
 	/* keep requests around for the multiple phases of the call
 	 * this shows the DISP_XX must guarantee we make it into the call
@@ -918,8 +933,9 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	else if (it->it_op == IT_OPEN)
 		LASSERT(!it_disposition(it, DISP_OPEN_CREATE));
 	else
-		LASSERT(it->it_op & (IT_GETATTR | IT_LOOKUP | IT_LAYOUT));
+		LASSERT(it->it_op & (IT_GETATTR | IT_LOOKUP));
 
+matching_lock:
 	/* If we already have a matching lock, then cancel the new
 	 * one.  We have to set the data here instead of in
 	 * mdc_enqueue, because we need to use the child's inode as
@@ -932,10 +948,20 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 
 		LDLM_DEBUG(lock, "matching against this");
 
-		LASSERTF(fid_res_name_eq(&mdt_body->mbo_fid1,
-					 &lock->l_resource->lr_name),
-			 "Lock res_id: " DLDLMRES ", fid: " DFID "\n",
-			 PLDLMRES(lock->l_resource), PFID(&mdt_body->mbo_fid1));
+		if (it_has_reply_body(it)) {
+			struct mdt_body *body;
+
+			body = req_capsule_server_get(&request->rq_pill,
+						      &RMF_MDT_BODY);
+
+			/* mdc_enqueue checked */
+			LASSERT(body);
+			LASSERTF(fid_res_name_eq(&body->mbo_fid1,
+						 &lock->l_resource->lr_name),
+				 "Lock res_id: " DLDLMRES ", fid: " DFID "\n",
+				 PLDLMRES(lock->l_resource),
+				 PFID(&body->mbo_fid1));
+		}
 		LDLM_LOCK_PUT(lock);
 
 		memcpy(&old_lock, lockh, sizeof(*lockh));
@@ -948,6 +974,7 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 			it->it_lock_handle = lockh->cookie;
 		}
 	}
+out:
 	CDEBUG(D_DENTRY,
 	       "D_IT dentry %.*s intent: %s status %d disp %x rc %d\n",
 	       (int)op_data->op_namelen, op_data->op_name,
@@ -1094,8 +1121,9 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 			return rc;
 		}
 	}
-	rc = mdc_enqueue(exp, &einfo, NULL, it, op_data, &lockh,
-			 extra_lock_flags);
+
+	rc = mdc_enqueue_base(exp, &einfo, NULL, it, op_data, &lockh,
+			      extra_lock_flags);
 	if (rc < 0)
 		return rc;
 
-- 
1.8.3.1
