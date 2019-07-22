From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:22 -0400
Subject: [lustre-devel] [PATCH 10/10] lustre: ptlrpc: simplify struct
 ptlrpc_request_set
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove obd_statfs_rqset(), replacing its only use with
obd_statfs(). Collapse lov_statfs_async() and lov_statfs() into a
single function, removing the need for lov_statfs_interpret().

Remove the then unused set_wakeup_ptr, set_cblist, set_interpret, and
set_arg members of struct ptlrpc_request_set. Remove struct
ptlrpc_set_cbdata and ptlrpc_set_add_cb(). On x86_64 this reduces the
size of struct ptlrpc_request_set from 152 bytes to 112.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10227
Reviewed-on: https://review.whamcloud.com/30060
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 24 ------------
 fs/lustre/include/obd_class.h  | 22 -----------
 fs/lustre/llite/llite_lib.c    |  2 +-
 fs/lustre/lov/lov_obd.c        | 85 ++++++++++++++----------------------------
 fs/lustre/ptlrpc/client.c      | 19 ----------
 5 files changed, 28 insertions(+), 124 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f7bd8ad..fde59df 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -331,7 +331,6 @@ struct ptlrpc_client {
 };
 
 struct ptlrpc_request_set;
-typedef int (*set_interpreter_func)(struct ptlrpc_request_set *, void *, int);
 typedef int (*set_producer_func)(struct ptlrpc_request_set *, void *);
 
 /**
@@ -353,20 +352,9 @@ struct ptlrpc_request_set {
 	atomic_t		set_remaining;
 	/** wait queue to wait on for request events */
 	wait_queue_head_t	set_waitq;
-	wait_queue_head_t	*set_wakeup_ptr;
 	/** List of requests in the set */
 	struct list_head	set_requests;
 	/**
-	 * List of completion callbacks to be called when the set is completed
-	 * This is only used if @set_interpret is NULL.
-	 * Links struct ptlrpc_set_cbdata.
-	 */
-	struct list_head	set_cblist;
-	/** Completion callback, if only one. */
-	set_interpreter_func	set_interpret;
-	/** opaq argument passed to completion @set_interpret callback. */
-	void			*set_arg;
-	/**
 	 * Lock for @set_new_requests manipulations
 	 * locked so that any old caller can communicate requests to
 	 * the set holder who can then fold them into the lock-free set
@@ -386,18 +374,6 @@ struct ptlrpc_request_set {
 	void			*set_producer_arg;
 };
 
-/**
- * Description of a single ptrlrpc_set callback
- */
-struct ptlrpc_set_cbdata {
-	/** List linkage item */
-	struct list_head	psc_item;
-	/** Pointer to interpreting function */
-	set_interpreter_func    psc_interpret;
-	/** Opaq argument to pass to the callback */
-	void			*psc_data;
-};
-
 struct ptlrpc_bulk_desc;
 struct ptlrpc_service_part;
 struct ptlrpc_service;
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 2f02efe..f26ca17 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -909,28 +909,6 @@ static inline int obd_statfs_async(struct obd_export *exp,
 	return rc;
 }
 
-static inline int obd_statfs_rqset(struct obd_export *exp,
-				   struct obd_statfs *osfs, u64 max_age,
-				   u32 flags)
-{
-	struct ptlrpc_request_set *set = NULL;
-	struct obd_info oinfo = {
-		.oi_osfs = osfs,
-		.oi_flags = flags,
-	};
-	int rc = 0;
-
-	set = ptlrpc_prep_set();
-	if (!set)
-		return -ENOMEM;
-
-	rc = obd_statfs_async(exp, &oinfo, max_age, set);
-	if (rc == 0)
-		rc = ptlrpc_set_wait(set);
-	ptlrpc_set_destroy(set);
-	return rc;
-}
-
 /*
  * @max_age is the oldest time in jiffies that we accept using a cached data.
  * If the cache is older than @max_age we will get a new value from the
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b933f37..83b63d8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1710,7 +1710,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	if (sbi->ll_flags & LL_SBI_LAZYSTATFS)
 		flags |= OBD_STATFS_NODELAY;
 
-	rc = obd_statfs_rqset(sbi->ll_dt_exp, &obd_osfs, max_age, flags);
+	rc = obd_statfs(NULL, sbi->ll_dt_exp, &obd_osfs, max_age, flags);
 	if (rc) {
 		CERROR("obd_statfs fails: rc = %d\n", rc);
 		return rc;
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 1d96f28..5dbc00e 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -911,78 +911,48 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 	return rc;
 }
 
-static int
-lov_statfs_interpret(struct ptlrpc_request_set *rqset, void *data, int rc)
-{
-	struct lov_request_set *lovset = (struct lov_request_set *)data;
-	int err;
-
-	if (rc)
-		atomic_set(&lovset->set_completes, 0);
-
-	err = lov_fini_statfs_set(lovset);
-	return rc ? rc : err;
-}
-
-static int lov_statfs_async(struct obd_export *exp, struct obd_info *oinfo,
-			    u64 max_age, struct ptlrpc_request_set *rqset)
+static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
+		      struct obd_statfs *osfs, u64 max_age, u32 flags)
 {
 	struct obd_device *obd = class_exp2obd(exp);
-	struct lov_request_set *set;
+	struct lov_obd *lov = &obd->u.lov;
+	struct ptlrpc_request_set *rqset;
+	struct obd_info oinfo = {
+		.oi_osfs = osfs,
+		.oi_flags = flags,
+	};
+	struct lov_request_set *set = NULL;
 	struct lov_request *req;
-	struct lov_obd *lov;
 	int rc = 0;
+	int rc2;
 
-	LASSERT(oinfo->oi_osfs);
+	rqset = ptlrpc_prep_set();
+	if (!rqset)
+		return -ENOMEM;
 
-	lov = &obd->u.lov;
-	rc = lov_prep_statfs_set(obd, oinfo, &set);
-	if (rc)
-		return rc;
+	rc = lov_prep_statfs_set(obd, &oinfo, &set);
+	if (rc < 0)
+		goto out_rqset;
 
 	list_for_each_entry(req, &set->set_list, rq_link) {
 		rc = obd_statfs_async(lov->lov_tgts[req->rq_idx]->ltd_exp,
 				      &req->rq_oi, max_age, rqset);
-		if (rc)
-			break;
-	}
-
-	if (rc || list_empty(&rqset->set_requests)) {
-		int err;
-
-		if (rc)
-			atomic_set(&set->set_completes, 0);
-		err = lov_fini_statfs_set(set);
-		return rc ? rc : err;
+		if (rc < 0)
+			goto out_set;
 	}
 
-	LASSERT(!rqset->set_interpret);
-	rqset->set_interpret = lov_statfs_interpret;
-	rqset->set_arg = (void *)set;
-	return 0;
-}
+	rc = ptlrpc_set_wait(rqset);
 
-static int lov_statfs(const struct lu_env *env, struct obd_export *exp,
-		      struct obd_statfs *osfs, u64 max_age, u32 flags)
-{
-	struct ptlrpc_request_set *set = NULL;
-	struct obd_info oinfo = {
-		.oi_osfs = osfs,
-		.oi_flags = flags,
-	};
-	int rc = 0;
+out_set:
+	if (rc < 0)
+		atomic_set(&set->set_completes, 0);
 
-	/* for obdclass we forbid using obd_statfs_rqset, but prefer using async
-	 * statfs requests
-	 */
-	set = ptlrpc_prep_set();
-	if (!set)
-		return -ENOMEM;
-
-	rc = lov_statfs_async(exp, &oinfo, max_age, set);
+	rc2 = lov_fini_statfs_set(set);
 	if (rc == 0)
-		rc = ptlrpc_set_wait(set);
-	ptlrpc_set_destroy(set);
+		rc = rc2;
+
+out_rqset:
+	ptlrpc_set_destroy(rqset);
 
 	return rc;
 }
@@ -1341,7 +1311,6 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	.connect	= lov_connect,
 	.disconnect	= lov_disconnect,
 	.statfs		= lov_statfs,
-	.statfs_async	= lov_statfs_async,
 	.iocontrol	= lov_iocontrol,
 	.get_info	= lov_get_info,
 	.set_info_async	= lov_set_info_async,
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 5c0a3ec..f7f3678 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -980,7 +980,6 @@ struct ptlrpc_request_set *ptlrpc_prep_set(void)
 	atomic_set(&set->set_remaining, 0);
 	spin_lock_init(&set->set_new_req_lock);
 	INIT_LIST_HEAD(&set->set_new_requests);
-	INIT_LIST_HEAD(&set->set_cblist);
 	set->set_max_inflight = UINT_MAX;
 	set->set_producer = NULL;
 	set->set_producer_arg = NULL;
@@ -2353,24 +2352,6 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			rc = req->rq_status;
 	}
 
-	if (set->set_interpret) {
-		int (*interpreter)(struct ptlrpc_request_set *set, void *, int) =
-			set->set_interpret;
-		rc = interpreter(set, set->set_arg, rc);
-	} else {
-		struct ptlrpc_set_cbdata *cbdata, *n;
-		int err;
-
-		list_for_each_entry_safe(cbdata, n,
-					 &set->set_cblist, psc_item) {
-			list_del_init(&cbdata->psc_item);
-			err = cbdata->psc_interpret(set, cbdata->psc_data, rc);
-			if (err && !rc)
-				rc = err;
-			kfree(cbdata);
-		}
-	}
-
 	return rc;
 }
 EXPORT_SYMBOL(ptlrpc_set_wait);
-- 
1.8.3.1
