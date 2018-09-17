From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:31:20 -0400
Subject: [lustre-devel] [PATCH 7/8] lustre: obdclass: restore md_stats code
In-Reply-To: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
References: <1537205481-6899-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205481-6899-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Originally the linux lustre client contained the md_stats code
but no one used it at that time so some parts of the code was
removed. The remaining md_stats code is layered in many levels
of macros that make the code difficult to read as well as
introduce undetected errors. This patch peels away the macro
wrappers by replacing it with the function lprocfs_count_incr()
which doesn't care about the order of the function pointers in
struct md_ops as the original code did.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9855
Reviewed-on: https://review.whamcloud.com/32822
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |   5 +-
 drivers/staging/lustre/lustre/include/obd.h        |   8 +-
 drivers/staging/lustre/lustre/include/obd_class.h  | 233 +++++++++++----------
 drivers/staging/lustre/lustre/obdclass/genops.c    |   3 -
 .../lustre/lustre/obdclass/lprocfs_status.c        |  66 +++++-
 5 files changed, 192 insertions(+), 123 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 5da26e3..c22ae3d 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -442,11 +442,12 @@ __u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 lprocfs_alloc_stats(unsigned int num, enum lprocfs_stats_flags flags);
 void lprocfs_clear_stats(struct lprocfs_stats *stats);
 void lprocfs_free_stats(struct lprocfs_stats **stats);
+int ldebugfs_alloc_md_stats(struct obd_device *obddev,
+			    unsigned int num_private_stats);
+void ldebugfs_free_md_stats(struct obd_device *obddev);
 void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 			  unsigned int conf, const char *name,
 			  const char *units);
-struct obd_export;
-int lprocfs_exp_cleanup(struct obd_export *exp);
 extern const struct file_operations lprocfs_stats_seq_fops;
 
 /* lprocfs_status.c */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 8691aec..6e78c50 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -599,8 +599,7 @@ struct obd_device {
 	/* Fields used by LProcFS */
 	struct lprocfs_stats	*obd_stats;
 
-	struct lprocfs_stats	*md_stats;
-	unsigned int		 md_cntr_base;
+	struct lprocfs_stats	*obd_md_stats;
 
 	struct dentry		*obd_debugfs_entry;
 	struct dentry		*obd_svc_debugfs_entry;
@@ -1000,11 +999,6 @@ struct md_ops {
 
 	int (*unpackmd)(struct obd_export *exp, struct lmv_stripe_md **plsm,
 			const union lmv_mds_md *lmv, size_t lmv_size);
-	/*
-	 * NOTE: If adding ops, add another LPROCFS_MD_OP_INIT() line to
-	 * lprocfs_alloc_md_stats() in obdclass/lprocfs_status.c. Also, add a
-	 * wrapper function in include/linux/obd_class.h.
-	 */
 };
 
 static inline struct md_open_data *obd_mod_alloc(void)
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 0c1922e..2514b39 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -334,36 +334,6 @@ static inline int obd_check_dev_active(struct obd_device *obd)
 	return rc;
 }
 
-#define MD_COUNTER_OFFSET(op)					\
-	((offsetof(struct md_ops, op) -				\
-		offsetof(struct md_ops, get_root))		\
-		/ sizeof(((struct md_ops *)(0))->get_root))
-
-#define MD_COUNTER_INCREMENT(obdx, op)				 \
-do {								 \
-	if ((obd)->md_stats) {					 \
-		unsigned int coffset;				 \
-		coffset = (unsigned int)((obdx)->md_cntr_base) + \
-			MD_COUNTER_OFFSET(op);			 \
-		LASSERT(coffset < (obdx)->md_stats->ls_num);	 \
-		lprocfs_counter_incr((obdx)->md_stats, coffset); \
-	}							 \
-} while (0)
-
-#define EXP_MD_COUNTER_INCREMENT(export, op)				    \
-do {									    \
-	if ((export)->exp_obd->obd_stats) {				    \
-		unsigned int coffset;					    \
-		coffset = (unsigned int)((export)->exp_obd->md_cntr_base) + \
-			MD_COUNTER_OFFSET(op);				    \
-		LASSERT(coffset < (export)->exp_obd->md_stats->ls_num);	    \
-		lprocfs_counter_incr((export)->exp_obd->md_stats, coffset); \
-		if ((export)->exp_md_stats)				    \
-			lprocfs_counter_incr(				    \
-				(export)->exp_md_stats, coffset);	    \
-	}								    \
-} while (0)
-
 static inline int exp_check_ops(struct obd_export *exp)
 {
 	if (!exp)
@@ -1186,6 +1156,25 @@ static inline int obd_register_observer(struct obd_device *obd,
 }
 
 /* metadata helpers */
+enum mps_stat_idx {
+	LPROC_MD_CLOSE,
+	LPROC_MD_CREATE,
+	LPROC_MD_ENQUEUE,
+	LPROC_MD_GETATTR,
+	LPROC_MD_INTENT_LOCK,
+	LPROC_MD_LINK,
+	LPROC_MD_RENAME,
+	LPROC_MD_SETATTR,
+	LPROC_MD_FSYNC,
+	LPROC_MD_READ_PAGE,
+	LPROC_MD_UNLINK,
+	LPROC_MD_SETXATTR,
+	LPROC_MD_GETXATTR,
+	LPROC_MD_INTENT_GETATTR_ASYNC,
+	LPROC_MD_REVALIDATE_LOCK,
+	LPROC_MD_LAST_OPC,
+};
+
 static inline int md_get_root(struct obd_export *exp, const char *fileset,
 			      struct lu_fid *fid)
 {
@@ -1194,9 +1183,8 @@ static inline int md_get_root(struct obd_export *exp, const char *fileset,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, get_root);
-	rc = MDP(exp->exp_obd, get_root)(exp, fileset, fid);
-	return rc;
+
+	return MDP(exp->exp_obd, get_root)(exp, fileset, fid);
 }
 
 static inline int md_getattr(struct obd_export *exp, struct md_op_data *op_data,
@@ -1207,9 +1195,11 @@ static inline int md_getattr(struct obd_export *exp, struct md_op_data *op_data,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, getattr);
-	rc = MDP(exp->exp_obd, getattr)(exp, op_data, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_GETATTR);
+
+	return MDP(exp->exp_obd, getattr)(exp, op_data, request);
 }
 
 static inline int md_null_inode(struct obd_export *exp,
@@ -1220,9 +1210,8 @@ static inline int md_null_inode(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, null_inode);
-	rc = MDP(exp->exp_obd, null_inode)(exp, fid);
-	return rc;
+
+	return MDP(exp->exp_obd, null_inode)(exp, fid);
 }
 
 static inline int md_close(struct obd_export *exp, struct md_op_data *op_data,
@@ -1234,25 +1223,29 @@ static inline int md_close(struct obd_export *exp, struct md_op_data *op_data,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, close);
-	rc = MDP(exp->exp_obd, close)(exp, op_data, mod, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_CLOSE);
+
+	return MDP(exp->exp_obd, close)(exp, op_data, mod, request);
 }
 
 static inline int md_create(struct obd_export *exp, struct md_op_data *op_data,
 			    const void *data, size_t datalen, umode_t mode,
 			    uid_t uid, gid_t gid, kernel_cap_t cap_effective,
-			    __u64 rdev, struct ptlrpc_request **request)
+			    u64 rdev, struct ptlrpc_request **request)
 {
 	int rc;
 
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, create);
-	rc = MDP(exp->exp_obd, create)(exp, op_data, data, datalen, mode,
-				       uid, gid, cap_effective, rdev, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_CREATE);
+
+	return MDP(exp->exp_obd, create)(exp, op_data, data, datalen, mode,
+					 uid, gid, cap_effective, rdev, request);
 }
 
 static inline int md_enqueue(struct obd_export *exp,
@@ -1260,17 +1253,19 @@ static inline int md_enqueue(struct obd_export *exp,
 			     const union ldlm_policy_data *policy,
 			     struct md_op_data *op_data,
 			     struct lustre_handle *lockh,
-			     __u64 extra_lock_flags)
+			     u64 extra_lock_flags)
 {
 	int rc;
 
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, enqueue);
-	rc = MDP(exp->exp_obd, enqueue)(exp, einfo, policy, op_data, lockh,
-					extra_lock_flags);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_ENQUEUE);
+
+	return MDP(exp->exp_obd, enqueue)(exp, einfo, policy, op_data, lockh,
+					  extra_lock_flags);
 }
 
 static inline int md_getattr_name(struct obd_export *exp,
@@ -1282,9 +1277,8 @@ static inline int md_getattr_name(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, getattr_name);
-	rc = MDP(exp->exp_obd, getattr_name)(exp, op_data, request);
-	return rc;
+
+	return MDP(exp->exp_obd, getattr_name)(exp, op_data, request);
 }
 
 static inline int md_intent_lock(struct obd_export *exp,
@@ -1292,17 +1286,19 @@ static inline int md_intent_lock(struct obd_export *exp,
 				 struct lookup_intent *it,
 				 struct ptlrpc_request **reqp,
 				 ldlm_blocking_callback cb_blocking,
-				 __u64 extra_lock_flags)
+				 u64 extra_lock_flags)
 {
 	int rc;
 
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, intent_lock);
-	rc = MDP(exp->exp_obd, intent_lock)(exp, op_data, it, reqp,
-					    cb_blocking, extra_lock_flags);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_INTENT_LOCK);
+
+	return MDP(exp->exp_obd, intent_lock)(exp, op_data, it, reqp,
+					      cb_blocking, extra_lock_flags);
 }
 
 static inline int md_link(struct obd_export *exp, struct md_op_data *op_data,
@@ -1313,24 +1309,29 @@ static inline int md_link(struct obd_export *exp, struct md_op_data *op_data,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, link);
-	rc = MDP(exp->exp_obd, link)(exp, op_data, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_LINK);
+
+	return MDP(exp->exp_obd, link)(exp, op_data, request);
 }
 
 static inline int md_rename(struct obd_export *exp, struct md_op_data *op_data,
-			    const char *old, size_t oldlen, const char *new,
-			    size_t newlen, struct ptlrpc_request **request)
+			    const char *old_name, size_t oldlen,
+			    const char *new_name, size_t newlen,
+			    struct ptlrpc_request **request)
 {
 	int rc;
 
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, rename);
-	rc = MDP(exp->exp_obd, rename)(exp, op_data, old, oldlen, new,
-				       newlen, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_RENAME);
+
+	return MDP(exp->exp_obd, rename)(exp, op_data, old_name, oldlen,
+					 new_name, newlen, request);
 }
 
 static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
@@ -1342,9 +1343,11 @@ static inline int md_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, setattr);
-	rc = MDP(exp->exp_obd, setattr)(exp, op_data, ea, ealen, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_SETATTR);
+
+	return MDP(exp->exp_obd, setattr)(exp, op_data, ea, ealen, request);
 }
 
 static inline int md_sync(struct obd_export *exp, const struct lu_fid *fid,
@@ -1355,15 +1358,17 @@ static inline int md_sync(struct obd_export *exp, const struct lu_fid *fid,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, sync);
-	rc = MDP(exp->exp_obd, sync)(exp, fid, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_FSYNC);
+
+	return MDP(exp->exp_obd, sync)(exp, fid, request);
 }
 
 static inline int md_read_page(struct obd_export *exp,
 			       struct md_op_data *op_data,
 			       struct md_callback *cb_op,
-			       __u64  hash_offset,
+			       u64 hash_offset,
 			       struct page **ppage)
 {
 	int rc;
@@ -1371,10 +1376,12 @@ static inline int md_read_page(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, read_page);
-	rc = MDP(exp->exp_obd, read_page)(exp, op_data, cb_op, hash_offset,
-					  ppage);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_READ_PAGE);
+
+	return MDP(exp->exp_obd, read_page)(exp, op_data, cb_op, hash_offset,
+					    ppage);
 }
 
 static inline int md_unlink(struct obd_export *exp, struct md_op_data *op_data,
@@ -1385,9 +1392,11 @@ static inline int md_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, unlink);
-	rc = MDP(exp->exp_obd, unlink)(exp, op_data, request);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_UNLINK);
+
+	return MDP(exp->exp_obd, unlink)(exp, op_data, request);
 }
 
 static inline int md_get_lustre_md(struct obd_export *exp,
@@ -1401,7 +1410,7 @@ static inline int md_get_lustre_md(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, get_lustre_md);
+
 	return MDP(exp->exp_obd, get_lustre_md)(exp, req, dt_exp, md_exp, md);
 }
 
@@ -1413,7 +1422,7 @@ static inline int md_free_lustre_md(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, free_lustre_md);
+
 	return MDP(exp->exp_obd, free_lustre_md)(exp, md);
 }
 
@@ -1427,7 +1436,7 @@ static inline int md_merge_attr(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, merge_attr);
+
 	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr, cb);
 }
 
@@ -1442,7 +1451,10 @@ static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, setxattr);
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_SETXATTR);
+
 	return MDP(exp->exp_obd, setxattr)(exp, fid, obd_md_valid, name,
 					   value, value_size, xattr_flags,
 					   suppgid, request);
@@ -1457,7 +1469,10 @@ static inline int md_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, getxattr);
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_GETXATTR);
+
 	return MDP(exp->exp_obd, getxattr)(exp, fid, obd_md_valid, name,
 					   buf_size, req);
 }
@@ -1471,7 +1486,7 @@ static inline int md_set_open_replay_data(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, set_open_replay_data);
+
 	return MDP(exp->exp_obd, set_open_replay_data)(exp, och, it);
 }
 
@@ -1483,7 +1498,7 @@ static inline int md_clear_open_replay_data(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, clear_open_replay_data);
+
 	return MDP(exp->exp_obd, clear_open_replay_data)(exp, och);
 }
 
@@ -1496,7 +1511,7 @@ static inline int md_set_lock_data(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, set_lock_data);
+
 	return MDP(exp->exp_obd, set_lock_data)(exp, lockh, data, bits);
 }
 
@@ -1512,11 +1527,9 @@ static inline int md_cancel_unused(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, cancel_unused);
 
-	rc = MDP(exp->exp_obd, cancel_unused)(exp, fid, policy, mode,
-					      flags, opaque);
-	return rc;
+	return MDP(exp->exp_obd, cancel_unused)(exp, fid, policy, mode,
+						flags, opaque);
 }
 
 static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
@@ -1531,7 +1544,7 @@ static inline enum ldlm_mode md_lock_match(struct obd_export *exp, __u64 flags,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, lock_match);
+
 	return MDP(exp->exp_obd, lock_match)(exp, flags, fid, type,
 					     policy, mode, lockh);
 }
@@ -1544,7 +1557,7 @@ static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, init_ea_size);
+
 	return MDP(exp->exp_obd, init_ea_size)(exp, easize, def_asize);
 }
 
@@ -1556,9 +1569,11 @@ static inline int md_intent_getattr_async(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, intent_getattr_async);
-	rc = MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_INTENT_GETATTR_ASYNC);
+
+	return MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
 }
 
 static inline int md_revalidate_lock(struct obd_export *exp,
@@ -1570,9 +1585,11 @@ static inline int md_revalidate_lock(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, revalidate_lock);
-	rc = MDP(exp->exp_obd, revalidate_lock)(exp, it, fid, bits);
-	return rc;
+
+	lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+			     LPROC_MD_REVALIDATE_LOCK);
+
+	return MDP(exp->exp_obd, revalidate_lock)(exp, it, fid, bits);
 }
 
 static inline int md_get_fid_from_lsm(struct obd_export *exp,
@@ -1585,9 +1602,8 @@ static inline int md_get_fid_from_lsm(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, get_fid_from_lsm);
-	rc = MDP(exp->exp_obd, get_fid_from_lsm)(exp, lsm, name, namelen, fid);
-	return rc;
+
+	return MDP(exp->exp_obd, get_fid_from_lsm)(exp, lsm, name, namelen, fid);
 }
 
 /*
@@ -1606,9 +1622,8 @@ static inline int md_unpackmd(struct obd_export *exp,
 	rc = exp_check_ops(exp);
 	if (rc)
 		return rc;
-	EXP_MD_COUNTER_INCREMENT(exp, unpackmd);
-	rc = MDP(exp->exp_obd, unpackmd)(exp, plsm, lmm, lmm_size);
-	return rc;
+
+	return MDP(exp->exp_obd, unpackmd)(exp, plsm, lmm, lmm_size);
 }
 
 /* OBD Metadata Support */
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 29ed498..59891a8 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -712,9 +712,6 @@ void class_export_put(struct obd_export *exp)
 		CDEBUG(D_IOCTL, "final put %p/%s\n",
 		       exp, exp->exp_client_uuid.uuid);
 
-		/* release nid stat refererence */
-		lprocfs_exp_cleanup(exp);
-
 		obd_zombie_export_add(exp);
 	}
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index a540abb..dc1d540 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1403,11 +1403,73 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 }
 EXPORT_SYMBOL(lprocfs_counter_init);
 
-int lprocfs_exp_cleanup(struct obd_export *exp)
+static const char * const mps_stats[] = {
+	[LPROC_MD_CLOSE]		= "close",
+	[LPROC_MD_CREATE]		= "create",
+	[LPROC_MD_ENQUEUE]		= "enqueue",
+	[LPROC_MD_GETATTR]		= "getattr",
+	[LPROC_MD_INTENT_LOCK]		= "intent_lock",
+	[LPROC_MD_LINK]			= "link",
+	[LPROC_MD_RENAME]		= "rename",
+	[LPROC_MD_SETATTR]		= "setattr",
+	[LPROC_MD_FSYNC]		= "fsync",
+	[LPROC_MD_READ_PAGE]		= "read_page",
+	[LPROC_MD_UNLINK]		= "unlink",
+	[LPROC_MD_SETXATTR]		= "setxattr",
+	[LPROC_MD_GETXATTR]		= "getxattr",
+	[LPROC_MD_INTENT_GETATTR_ASYNC]	= "intent_getattr_async",
+	[LPROC_MD_REVALIDATE_LOCK]	= "revalidate_lock",
+};
+
+int ldebugfs_alloc_md_stats(struct obd_device *obd,
+			    unsigned int num_private_stats)
 {
+	struct lprocfs_stats *stats;
+	unsigned int num_stats;
+	int i;
+
+	/* No obd device debugfs tree to attach too */
+	if (!obd->obd_debugfs_entry) {
+		CWARN("%s: missing debugfs tree for registering md_stats.\n",
+		      obd->obd_name);
+		return 0;
+	}
+
+	if (obd->obd_md_stats)
+		return -EINVAL;
+
+	num_stats = ARRAY_SIZE(mps_stats) + num_private_stats;
+	stats = lprocfs_alloc_stats(num_stats, 0);
+	if (!stats)
+		return -ENOMEM;
+
+	for (i = 0; i < ARRAY_SIZE(mps_stats); i++) {
+		lprocfs_counter_init(stats, i, 0, mps_stats[i], "reqs");
+		if (!stats->ls_cnt_header[i].lc_name) {
+			CERROR("Missing md_stat initializer md_op operation at offset %d. Aborting.\n",
+			       i);
+			LBUG();
+		}
+	}
+	obd->obd_md_stats = stats;
+
+	debugfs_create_file("md_stats", 0644, obd->obd_debugfs_entry,
+			    obd->obd_md_stats, &lprocfs_stats_seq_fops);
 	return 0;
 }
-EXPORT_SYMBOL(lprocfs_exp_cleanup);
+EXPORT_SYMBOL(ldebugfs_alloc_md_stats);
+
+void ldebugfs_free_md_stats(struct obd_device *obd)
+{
+	struct lprocfs_stats *stats = obd->obd_md_stats;
+
+	if (!stats)
+		return;
+
+	obd->obd_md_stats = NULL;
+	lprocfs_free_stats(&stats);
+}
+EXPORT_SYMBOL(ldebugfs_free_md_stats);
 
 __s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 			  struct lprocfs_counter_header *header,
-- 
1.8.3.1
