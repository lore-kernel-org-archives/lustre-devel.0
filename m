From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:47 -0500
Subject: [lustre-devel] [PATCH 15/45] staging/lustre/ldlm: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Also remove some redundant assertions.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |  2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  9 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    | 13 ++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 16 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 65 +++++++++++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 45 ++++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 17 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 65 +++++++++++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 25 ++++-----
 9 files changed, 123 insertions(+), 134 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index a2ea8e5..fd70f65 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -49,13 +49,11 @@ enum {
 
 static inline int node_is_left_child(struct interval_node *node)
 {
-	LASSERT(node->in_parent != NULL);
 	return node == node->in_parent->in_left;
 }
 
 static inline int node_is_right_child(struct interval_node *node)
 {
-	LASSERT(node->in_parent != NULL);
 	return node == node->in_parent->in_right;
 }
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 9c70f31..aa92682 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -113,7 +113,7 @@ struct ldlm_interval *ldlm_interval_alloc(struct ldlm_lock *lock)
 
 	LASSERT(lock->l_resource->lr_type == LDLM_EXTENT);
 	node = kmem_cache_alloc(ldlm_interval_slab, GFP_NOFS | __GFP_ZERO);
-	if (node == NULL)
+	if (!node)
 		return NULL;
 
 	INIT_LIST_HEAD(&node->li_group);
@@ -134,7 +134,7 @@ struct ldlm_interval *ldlm_interval_detach(struct ldlm_lock *l)
 {
 	struct ldlm_interval *n = l->l_tree_node;
 
-	if (n == NULL)
+	if (!n)
 		return NULL;
 
 	LASSERT(!list_empty(&n->li_group));
@@ -168,7 +168,7 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 	LASSERT(lock->l_granted_mode == lock->l_req_mode);
 
 	node = lock->l_tree_node;
-	LASSERT(node != NULL);
+	LASSERT(node);
 	LASSERT(!interval_is_intree(&node->li_node));
 
 	idx = lock_mode_to_index(lock->l_granted_mode);
@@ -185,7 +185,6 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 		struct ldlm_interval *tmp;
 
 		tmp = ldlm_interval_detach(lock);
-		LASSERT(tmp != NULL);
 		ldlm_interval_free(tmp);
 		ldlm_interval_attach(to_ldlm_interval(found), lock);
 	}
@@ -211,7 +210,7 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 	LASSERT(lock->l_granted_mode == 1 << idx);
 	tree = &res->lr_itree[idx];
 
-	LASSERT(tree->lit_root != NULL); /* assure the tree is not null */
+	LASSERT(tree->lit_root); /* assure the tree is not null */
 
 	tree->lit_size--;
 	node = ldlm_interval_detach(lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 4310154..7c671e3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -361,7 +361,7 @@ reprocess:
 		lock->l_policy_data.l_flock.start =
 			new->l_policy_data.l_flock.end + 1;
 		new2->l_conn_export = lock->l_conn_export;
-		if (lock->l_export != NULL) {
+		if (lock->l_export) {
 			new2->l_export = class_export_lock_get(lock->l_export,
 							       new2);
 			if (new2->l_export->exp_lock_hash &&
@@ -381,7 +381,7 @@ reprocess:
 	}
 
 	/* if new2 is created but never used, destroy it*/
-	if (splitted == 0 && new2 != NULL)
+	if (splitted == 0 && new2)
 		ldlm_lock_destroy_nolock(new2);
 
 	/* At this point we're granting the lock request. */
@@ -462,8 +462,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	if ((lock->l_flags & (LDLM_FL_FAILED|LDLM_FL_LOCAL_ONLY)) ==
 	    (LDLM_FL_FAILED|LDLM_FL_LOCAL_ONLY)) {
 		if (lock->l_req_mode == lock->l_granted_mode &&
-		    lock->l_granted_mode != LCK_NL &&
-		    data == NULL)
+		    lock->l_granted_mode != LCK_NL && !data)
 			ldlm_lock_decref_internal(lock, lock->l_req_mode);
 
 		/* Need to wake up the waiter if we were evicted */
@@ -475,7 +474,7 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 
 	if (!(flags & (LDLM_FL_BLOCK_WAIT | LDLM_FL_BLOCK_GRANTED |
 		       LDLM_FL_BLOCK_CONV))) {
-		if (data == NULL)
+		if (!data)
 			/* mds granted the lock in the reply */
 			goto granted;
 		/* CP AST RPC: lock get granted, wake it up */
@@ -488,10 +487,10 @@ ldlm_flock_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data)
 	obd = class_exp2obd(lock->l_conn_export);
 
 	/* if this is a local lock, there is no import */
-	if (obd != NULL)
+	if (obd)
 		imp = obd->u.cli.cl_import;
 
-	if (imp != NULL) {
+	if (imp) {
 		spin_lock(&imp->imp_lock);
 		fwd.fwd_generation = imp->imp_generation;
 		spin_unlock(&imp->imp_lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 774d89c..0e25c45 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -373,7 +373,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 			   &obddev->obd_ldlm_client);
 
 	imp = class_new_import(obddev);
-	if (imp == NULL) {
+	if (!imp) {
 		rc = -ENOENT;
 		goto err_ldlm;
 	}
@@ -409,7 +409,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 						   LDLM_NAMESPACE_CLIENT,
 						   LDLM_NAMESPACE_GREEDY,
 						   ns_type);
-	if (obddev->obd_namespace == NULL) {
+	if (!obddev->obd_namespace) {
 		CERROR("Unable to create client namespace - %s\n",
 		       obddev->obd_name);
 		rc = -ENOMEM;
@@ -435,7 +435,7 @@ int client_obd_cleanup(struct obd_device *obddev)
 	ldlm_namespace_free_post(obddev->obd_namespace);
 	obddev->obd_namespace = NULL;
 
-	LASSERT(obddev->u.cli.cl_import == NULL);
+	LASSERT(!obddev->u.cli.cl_import);
 
 	ldlm_put_ref();
 	return 0;
@@ -486,7 +486,7 @@ int client_connect_import(const struct lu_env *env,
 		LASSERT(imp->imp_state == LUSTRE_IMP_DISCON);
 		goto out_ldlm;
 	}
-	LASSERT(*exp != NULL && (*exp)->exp_connection);
+	LASSERT(*exp && (*exp)->exp_connection);
 
 	if (data) {
 		LASSERTF((ocd->ocd_connect_flags & data->ocd_connect_flags) ==
@@ -555,7 +555,7 @@ int client_disconnect_export(struct obd_export *exp)
 	 * never added.) */
 	(void)ptlrpc_pinger_del_import(imp);
 
-	if (obd->obd_namespace != NULL) {
+	if (obd->obd_namespace) {
 		/* obd_force == local only */
 		ldlm_cli_cancel_unused(obd->obd_namespace, NULL,
 				       obd->obd_force ? LCF_LOCAL : 0, NULL);
@@ -642,14 +642,14 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 
 	svcpt = req->rq_rqbd->rqbd_svcpt;
 	rs = req->rq_reply_state;
-	if (rs == NULL || !rs->rs_difficult) {
+	if (!rs || !rs->rs_difficult) {
 		/* no notifiers */
 		target_send_reply_msg(req, rc, fail_id);
 		return;
 	}
 
 	/* must be an export if locks saved */
-	LASSERT(req->rq_export != NULL);
+	LASSERT(req->rq_export);
 	/* req/reply consistent */
 	LASSERT(rs->rs_svcpt == svcpt);
 
@@ -658,7 +658,7 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 	LASSERT(!rs->rs_scheduled_ever);
 	LASSERT(!rs->rs_handled);
 	LASSERT(!rs->rs_on_net);
-	LASSERT(rs->rs_export == NULL);
+	LASSERT(!rs->rs_export);
 	LASSERT(list_empty(&rs->rs_obd_list));
 	LASSERT(list_empty(&rs->rs_exp_list));
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index cf9ec0c..4fd735f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -412,11 +412,10 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 {
 	struct ldlm_lock *lock;
 
-	if (resource == NULL)
-		LBUG();
+	LASSERT(resource);
 
 	lock = kmem_cache_alloc(ldlm_lock_slab, GFP_NOFS | __GFP_ZERO);
-	if (lock == NULL)
+	if (!lock)
 		return NULL;
 
 	spin_lock_init(&lock->l_lock);
@@ -485,7 +484,7 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	unlock_res_and_lock(lock);
 
 	newres = ldlm_resource_get(ns, NULL, new_resid, type, 1);
-	if (newres == NULL)
+	if (!newres)
 		return -ENOMEM;
 
 	lu_ref_add(&newres->lr_reference, "lock", lock);
@@ -547,7 +546,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 	LASSERT(handle);
 
 	lock = class_handle2object(handle->cookie);
-	if (lock == NULL)
+	if (!lock)
 		return NULL;
 
 	/* It's unlikely but possible that someone marked the lock as
@@ -559,7 +558,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	lock_res_and_lock(lock);
 
-	LASSERT(lock->l_resource != NULL);
+	LASSERT(lock->l_resource);
 
 	lu_ref_add_atomic(&lock->l_reference, "handle", current);
 	if (unlikely(lock->l_flags & LDLM_FL_DESTROYED)) {
@@ -617,7 +616,7 @@ static void ldlm_add_bl_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
 		LASSERT(list_empty(&lock->l_bl_ast));
 		list_add(&lock->l_bl_ast, work_list);
 		LDLM_LOCK_GET(lock);
-		LASSERT(lock->l_blocking_lock == NULL);
+		LASSERT(!lock->l_blocking_lock);
 		lock->l_blocking_lock = LDLM_LOCK_GET(new);
 	}
 }
@@ -664,7 +663,7 @@ void ldlm_lock_addref(struct lustre_handle *lockh, __u32 mode)
 	struct ldlm_lock *lock;
 
 	lock = ldlm_handle2lock(lockh);
-	LASSERT(lock != NULL);
+	LASSERT(lock);
 	ldlm_lock_addref_internal(lock, mode);
 	LDLM_LOCK_PUT(lock);
 }
@@ -708,7 +707,7 @@ int ldlm_lock_addref_try(struct lustre_handle *lockh, __u32 mode)
 
 	result = -EAGAIN;
 	lock = ldlm_handle2lock(lockh);
-	if (lock != NULL) {
+	if (lock) {
 		lock_res_and_lock(lock);
 		if (lock->l_readers != 0 || lock->l_writers != 0 ||
 		    !(lock->l_flags & LDLM_FL_CBPENDING)) {
@@ -835,7 +834,7 @@ void ldlm_lock_decref(struct lustre_handle *lockh, __u32 mode)
 {
 	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
 
-	LASSERTF(lock != NULL, "Non-existing lock: %#llx\n", lockh->cookie);
+	LASSERTF(lock, "Non-existing lock: %#llx\n", lockh->cookie);
 	ldlm_lock_decref_internal(lock, mode);
 	LDLM_LOCK_PUT(lock);
 }
@@ -852,7 +851,7 @@ void ldlm_lock_decref_and_cancel(struct lustre_handle *lockh, __u32 mode)
 {
 	struct ldlm_lock *lock = __ldlm_handle2lock(lockh, 0);
 
-	LASSERT(lock != NULL);
+	LASSERT(lock);
 
 	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
 	lock_res_and_lock(lock);
@@ -1037,7 +1036,7 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 	if (lock->l_granted_mode < res->lr_most_restr)
 		res->lr_most_restr = lock->l_granted_mode;
 
-	if (work_list && lock->l_completion_ast != NULL)
+	if (work_list && lock->l_completion_ast)
 		ldlm_add_ast_work_item(lock, NULL, work_list);
 
 	ldlm_pool_add(&ldlm_res_to_ns(res)->ns_pool, lock);
@@ -1201,7 +1200,7 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 	struct ldlm_lock *lock, *old_lock = NULL;
 	int rc = 0;
 
-	if (ns == NULL) {
+	if (!ns) {
 		old_lock = ldlm_handle2lock(lockh);
 		LASSERT(old_lock);
 
@@ -1212,8 +1211,8 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 	}
 
 	res = ldlm_resource_get(ns, NULL, res_id, type, 0);
-	if (res == NULL) {
-		LASSERT(old_lock == NULL);
+	if (!res) {
+		LASSERT(!old_lock);
 		return 0;
 	}
 
@@ -1222,7 +1221,7 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 
 	lock = search_queue(&res->lr_granted, &mode, policy, old_lock,
 			    flags, unref);
-	if (lock != NULL) {
+	if (lock) {
 		rc = 1;
 		goto out;
 	}
@@ -1232,7 +1231,7 @@ ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 	}
 	lock = search_queue(&res->lr_waiting, &mode, policy, old_lock,
 			    flags, unref);
-	if (lock != NULL) {
+	if (lock) {
 		rc = 1;
 		goto out;
 	}
@@ -1324,7 +1323,7 @@ ldlm_mode_t ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
 	ldlm_mode_t mode = 0;
 
 	lock = ldlm_handle2lock(lockh);
-	if (lock != NULL) {
+	if (lock) {
 		lock_res_and_lock(lock);
 		if (lock->l_flags & LDLM_FL_GONE_MASK)
 			goto out;
@@ -1340,7 +1339,7 @@ ldlm_mode_t ldlm_revalidate_lock_handle(struct lustre_handle *lockh,
 	}
 
 out:
-	if (lock != NULL) {
+	if (lock) {
 		unlock_res_and_lock(lock);
 		LDLM_LOCK_PUT(lock);
 	}
@@ -1354,7 +1353,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 {
 	void *lvb;
 
-	LASSERT(data != NULL);
+	LASSERT(data);
 	LASSERT(size >= 0);
 
 	switch (lock->l_lvb_type) {
@@ -1368,7 +1367,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 				lvb = req_capsule_server_swab_get(pill,
 						&RMF_DLM_LVB,
 						lustre_swab_ost_lvb);
-			if (unlikely(lvb == NULL)) {
+			if (unlikely(!lvb)) {
 				LDLM_ERROR(lock, "no LVB");
 				return -EPROTO;
 			}
@@ -1385,7 +1384,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 				lvb = req_capsule_server_sized_swab_get(pill,
 						&RMF_DLM_LVB, size,
 						lustre_swab_ost_lvb_v1);
-			if (unlikely(lvb == NULL)) {
+			if (unlikely(!lvb)) {
 				LDLM_ERROR(lock, "no LVB");
 				return -EPROTO;
 			}
@@ -1410,7 +1409,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 				lvb = req_capsule_server_swab_get(pill,
 						&RMF_DLM_LVB,
 						lustre_swab_lquota_lvb);
-			if (unlikely(lvb == NULL)) {
+			if (unlikely(!lvb)) {
 				LDLM_ERROR(lock, "no LVB");
 				return -EPROTO;
 			}
@@ -1431,7 +1430,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 			lvb = req_capsule_client_get(pill, &RMF_DLM_LVB);
 		else
 			lvb = req_capsule_server_get(pill, &RMF_DLM_LVB);
-		if (unlikely(lvb == NULL)) {
+		if (unlikely(!lvb)) {
 			LDLM_ERROR(lock, "no LVB");
 			return -EPROTO;
 		}
@@ -1463,12 +1462,12 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	struct ldlm_resource *res;
 
 	res = ldlm_resource_get(ns, NULL, res_id, type, 1);
-	if (res == NULL)
+	if (!res)
 		return NULL;
 
 	lock = ldlm_lock_new(res);
 
-	if (lock == NULL)
+	if (!lock)
 		return NULL;
 
 	lock->l_req_mode = mode;
@@ -1483,7 +1482,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	lock->l_tree_node = NULL;
 	/* if this is the extent lock, allocate the interval tree node */
 	if (type == LDLM_EXTENT) {
-		if (ldlm_interval_alloc(lock) == NULL)
+		if (!ldlm_interval_alloc(lock))
 			goto out;
 	}
 
@@ -1633,7 +1632,7 @@ ldlm_work_cp_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 	lock->l_flags &= ~LDLM_FL_CP_REQD;
 	unlock_res_and_lock(lock);
 
-	if (completion_callback != NULL)
+	if (completion_callback)
 		rc = completion_callback(lock, 0, (void *)arg);
 	LDLM_LOCK_RELEASE(lock);
 
@@ -1752,7 +1751,7 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 	 * to keep the number of requests in flight to ns_max_parallel_ast */
 	arg->set = ptlrpc_prep_fcset(ns->ns_max_parallel_ast ? : UINT_MAX,
 				     work_ast_lock, arg);
-	if (arg->set == NULL) {
+	if (!arg->set) {
 		rc = -ENOMEM;
 		goto out;
 	}
@@ -1846,7 +1845,7 @@ int ldlm_lock_set_data(struct lustre_handle *lockh, void *data)
 	int rc = -EINVAL;
 
 	if (lock) {
-		if (lock->l_ast_data == NULL)
+		if (!lock->l_ast_data)
 			lock->l_ast_data = data;
 		if (lock->l_ast_data == data)
 			rc = 0;
@@ -1874,7 +1873,7 @@ void ldlm_lock_dump_handle(int level, struct lustre_handle *lockh)
 		return;
 
 	lock = ldlm_handle2lock(lockh);
-	if (lock == NULL)
+	if (!lock)
 		return;
 
 	LDLM_DEBUG_LIMIT(level, lock, "###");
@@ -1900,13 +1899,13 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	if (exp && exp->exp_connection) {
 		nid = libcfs_nid2str(exp->exp_connection->c_peer.nid);
-	} else if (exp && exp->exp_obd != NULL) {
+	} else if (exp && exp->exp_obd) {
 		struct obd_import *imp = exp->exp_obd->u.cli.cl_import;
 
 		nid = libcfs_nid2str(imp->imp_connection->c_peer.nid);
 	}
 
-	if (resource == NULL) {
+	if (!resource) {
 		libcfs_debug_vmsg2(msgdata, fmt, args,
 				   " ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
 				   lock,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 79aeb2b..0737ded 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -136,7 +136,7 @@ void ldlm_handle_bl_callback(struct ldlm_namespace *ns,
 		CDEBUG(D_DLMTRACE,
 		       "Lock %p already unused, calling callback (%p)\n", lock,
 		       lock->l_blocking_ast);
-		if (lock->l_blocking_ast != NULL)
+		if (lock->l_blocking_ast)
 			lock->l_blocking_ast(lock, ld, lock->l_ast_data,
 					     LDLM_CB_BLOCKING);
 	} else {
@@ -185,7 +185,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 	} else if (lvb_len > 0) {
 		if (lock->l_lvb_len > 0) {
 			/* for extent lock, lvb contains ost_lvb{}. */
-			LASSERT(lock->l_lvb_data != NULL);
+			LASSERT(lock->l_lvb_data);
 
 			if (unlikely(lock->l_lvb_len < lvb_len)) {
 				LDLM_ERROR(lock, "Replied LVB is larger than expectation, expected = %d, replied = %d",
@@ -205,7 +205,7 @@ static void ldlm_handle_cp_callback(struct ptlrpc_request *req,
 			}
 
 			lock_res_and_lock(lock);
-			LASSERT(lock->l_lvb_data == NULL);
+			LASSERT(!lock->l_lvb_data);
 			lock->l_lvb_type = LVB_T_LAYOUT;
 			lock->l_lvb_data = lvb_data;
 			lock->l_lvb_len = lvb_len;
@@ -312,10 +312,10 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
 
 	LDLM_DEBUG(lock, "client glimpse AST callback handler");
 
-	if (lock->l_glimpse_ast != NULL)
+	if (lock->l_glimpse_ast)
 		rc = lock->l_glimpse_ast(lock, req);
 
-	if (req->rq_repmsg != NULL) {
+	if (req->rq_repmsg) {
 		ptlrpc_reply(req);
 	} else {
 		req->rq_status = rc;
@@ -393,7 +393,7 @@ static inline void init_blwi(struct ldlm_bl_work_item *blwi,
 
 	blwi->blwi_ns = ns;
 	blwi->blwi_flags = cancel_flags;
-	if (ld != NULL)
+	if (ld)
 		blwi->blwi_ld = *ld;
 	if (count) {
 		list_add(&blwi->blwi_head, cancels);
@@ -470,14 +470,14 @@ static int ldlm_handle_setinfo(struct ptlrpc_request *req)
 	req_capsule_set(&req->rq_pill, &RQF_OBD_SET_INFO);
 
 	key = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_KEY);
-	if (key == NULL) {
+	if (!key) {
 		DEBUG_REQ(D_IOCTL, req, "no set_info key");
 		return -EFAULT;
 	}
 	keylen = req_capsule_get_size(&req->rq_pill, &RMF_SETINFO_KEY,
 				      RCL_CLIENT);
 	val = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_VAL);
-	if (val == NULL) {
+	if (!val) {
 		DEBUG_REQ(D_IOCTL, req, "no set_info val");
 		return -EFAULT;
 	}
@@ -519,7 +519,7 @@ static int ldlm_handle_qc_callback(struct ptlrpc_request *req)
 	struct client_obd *cli = &req->rq_export->exp_obd->u.cli;
 
 	oqctl = req_capsule_client_get(&req->rq_pill, &RMF_OBD_QUOTACTL);
-	if (oqctl == NULL) {
+	if (!oqctl) {
 		CERROR("Can't unpack obd_quotactl\n");
 		return -EPROTO;
 	}
@@ -549,15 +549,14 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 
 	req_capsule_init(&req->rq_pill, req, RCL_SERVER);
 
-	if (req->rq_export == NULL) {
+	if (!req->rq_export) {
 		rc = ldlm_callback_reply(req, -ENOTCONN);
 		ldlm_callback_errmsg(req, "Operate on unconnected server",
 				     rc, NULL);
 		return 0;
 	}
 
-	LASSERT(req->rq_export != NULL);
-	LASSERT(req->rq_export->exp_obd != NULL);
+	LASSERT(req->rq_export->exp_obd);
 
 	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
 	case LDLM_BL_CALLBACK:
@@ -591,12 +590,12 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 	}
 
 	ns = req->rq_export->exp_obd->obd_namespace;
-	LASSERT(ns != NULL);
+	LASSERT(ns);
 
 	req_capsule_set(&req->rq_pill, &RQF_LDLM_CALLBACK);
 
 	dlm_req = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	if (dlm_req == NULL) {
+	if (!dlm_req) {
 		rc = ldlm_callback_reply(req, -EPROTO);
 		ldlm_callback_errmsg(req, "Operate without parameter", rc,
 				     NULL);
@@ -781,17 +780,17 @@ static int ldlm_bl_thread_main(void *arg)
 
 		blwi = ldlm_bl_get_work(blp);
 
-		if (blwi == NULL) {
+		if (!blwi) {
 			atomic_dec(&blp->blp_busy_threads);
 			l_wait_event_exclusive(blp->blp_waitq,
-					 (blwi = ldlm_bl_get_work(blp)) != NULL,
+					 (blwi = ldlm_bl_get_work(blp)),
 					 &lwi);
 			busy = atomic_inc_return(&blp->blp_busy_threads);
 		} else {
 			busy = atomic_read(&blp->blp_busy_threads);
 		}
 
-		if (blwi->blwi_ns == NULL)
+		if (!blwi->blwi_ns)
 			/* added by ldlm_cleanup() */
 			break;
 
@@ -915,7 +914,7 @@ static int ldlm_setup(void)
 	int rc = 0;
 	int i;
 
-	if (ldlm_state != NULL)
+	if (ldlm_state)
 		return -EALREADY;
 
 	ldlm_state = kzalloc(sizeof(*ldlm_state), GFP_NOFS);
@@ -1040,7 +1039,7 @@ static int ldlm_cleanup(void)
 
 	ldlm_pools_fini();
 
-	if (ldlm_state->ldlm_bl_pool != NULL) {
+	if (ldlm_state->ldlm_bl_pool) {
 		struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
 
 		while (atomic_read(&blp->blp_num_threads) > 0) {
@@ -1059,7 +1058,7 @@ static int ldlm_cleanup(void)
 		kfree(blp);
 	}
 
-	if (ldlm_state->ldlm_cb_service != NULL)
+	if (ldlm_state->ldlm_cb_service)
 		ptlrpc_unregister_service(ldlm_state->ldlm_cb_service);
 
 	if (ldlm_ns_kset)
@@ -1085,13 +1084,13 @@ int ldlm_init(void)
 	ldlm_resource_slab = kmem_cache_create("ldlm_resources",
 					       sizeof(struct ldlm_resource), 0,
 					       SLAB_HWCACHE_ALIGN, NULL);
-	if (ldlm_resource_slab == NULL)
+	if (!ldlm_resource_slab)
 		return -ENOMEM;
 
 	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
 			      sizeof(struct ldlm_lock), 0,
 			      SLAB_HWCACHE_ALIGN | SLAB_DESTROY_BY_RCU, NULL);
-	if (ldlm_lock_slab == NULL) {
+	if (!ldlm_lock_slab) {
 		kmem_cache_destroy(ldlm_resource_slab);
 		return -ENOMEM;
 	}
@@ -1099,7 +1098,7 @@ int ldlm_init(void)
 	ldlm_interval_slab = kmem_cache_create("interval_node",
 					sizeof(struct ldlm_interval),
 					0, SLAB_HWCACHE_ALIGN, NULL);
-	if (ldlm_interval_slab == NULL) {
+	if (!ldlm_interval_slab) {
 		kmem_cache_destroy(ldlm_resource_slab);
 		kmem_cache_destroy(ldlm_lock_slab);
 		return -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 3d7c137..3e937b0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -246,7 +246,6 @@ static void ldlm_cli_pool_pop_slv(struct ldlm_pool *pl)
 	 */
 	obd = container_of(pl, struct ldlm_namespace,
 			   ns_pool)->ns_obd;
-	LASSERT(obd != NULL);
 	read_lock(&obd->obd_pool_lock);
 	pl->pl_server_lock_volume = obd->obd_pool_slv;
 	atomic_set(&pl->pl_limit, obd->obd_pool_limit);
@@ -381,7 +380,7 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
 	spin_unlock(&pl->pl_lock);
 
  recalc:
-	if (pl->pl_ops->po_recalc != NULL) {
+	if (pl->pl_ops->po_recalc) {
 		count = pl->pl_ops->po_recalc(pl);
 		lprocfs_counter_add(pl->pl_stats, LDLM_POOL_RECALC_STAT,
 				    count);
@@ -409,7 +408,7 @@ static int ldlm_pool_shrink(struct ldlm_pool *pl, int nr, gfp_t gfp_mask)
 {
 	int cancel = 0;
 
-	if (pl->pl_ops->po_shrink != NULL) {
+	if (pl->pl_ops->po_shrink) {
 		cancel = pl->pl_ops->po_shrink(pl, nr, gfp_mask);
 		if (nr > 0) {
 			lprocfs_counter_add(pl->pl_stats,
@@ -643,11 +642,11 @@ static void ldlm_pool_sysfs_fini(struct ldlm_pool *pl)
 
 static void ldlm_pool_debugfs_fini(struct ldlm_pool *pl)
 {
-	if (pl->pl_stats != NULL) {
+	if (pl->pl_stats) {
 		lprocfs_free_stats(&pl->pl_stats);
 		pl->pl_stats = NULL;
 	}
-	if (pl->pl_debugfs_entry != NULL) {
+	if (pl->pl_debugfs_entry) {
 		ldebugfs_remove(&pl->pl_debugfs_entry);
 		pl->pl_debugfs_entry = NULL;
 	}
@@ -834,7 +833,7 @@ static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
 			continue;
 		}
 
-		if (ns_old == NULL)
+		if (!ns_old)
 			ns_old = ns;
 
 		ldlm_namespace_get(ns);
@@ -957,7 +956,7 @@ static int ldlm_pools_recalc(ldlm_side_t client)
 			continue;
 		}
 
-		if (ns_old == NULL)
+		if (!ns_old)
 			ns_old = ns;
 
 		spin_lock(&ns->ns_lock);
@@ -1040,7 +1039,7 @@ static int ldlm_pools_thread_start(void)
 	struct l_wait_info lwi = { 0 };
 	struct task_struct *task;
 
-	if (ldlm_pools_thread != NULL)
+	if (ldlm_pools_thread)
 		return -EALREADY;
 
 	ldlm_pools_thread = kzalloc(sizeof(*ldlm_pools_thread), GFP_NOFS);
@@ -1065,7 +1064,7 @@ static int ldlm_pools_thread_start(void)
 
 static void ldlm_pools_thread_stop(void)
 {
-	if (ldlm_pools_thread == NULL)
+	if (!ldlm_pools_thread)
 		return;
 
 	thread_set_flags(ldlm_pools_thread, SVC_STOPPING);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index b9eb377..de276af 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -94,7 +94,7 @@ static int ldlm_expired_completion_wait(void *data)
 	struct obd_import *imp;
 	struct obd_device *obd;
 
-	if (lock->l_conn_export == NULL) {
+	if (!lock->l_conn_export) {
 		static unsigned long next_dump, last_dump;
 
 		LCONSOLE_WARN("lock timed out (enqueued at %lld, %llds ago)\n",
@@ -239,7 +239,7 @@ noreproc:
 	obd = class_exp2obd(lock->l_conn_export);
 
 	/* if this is a local lock, then there is no import */
-	if (obd != NULL)
+	if (obd)
 		imp = obd->u.cli.cl_import;
 
 	/* Wait a long time for enqueue - server may have to callback a
@@ -258,7 +258,7 @@ noreproc:
 				       interrupted_completion_wait, &lwd);
 	}
 
-	if (imp != NULL) {
+	if (imp) {
 		spin_lock(&imp->imp_lock);
 		lwd.lwd_conn_cnt = imp->imp_conn_cnt;
 		spin_unlock(&imp->imp_lock);
@@ -363,13 +363,13 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 	/* Before we return, swab the reply */
 	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	if (reply == NULL) {
+	if (!reply) {
 		rc = -EPROTO;
 		goto cleanup;
 	}
 
 	if (lvb_len != 0) {
-		LASSERT(lvb != NULL);
+		LASSERT(lvb);
 
 		size = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB,
 					    RCL_SERVER);
@@ -445,7 +445,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 			rc = ldlm_lock_change_resource(ns, lock,
 					&reply->lock_desc.l_resource.lr_name);
-			if (rc || lock->l_resource == NULL) {
+			if (rc || !lock->l_resource) {
 				rc = -ENOMEM;
 				goto cleanup;
 			}
@@ -495,7 +495,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 	if (!is_replay) {
 		rc = ldlm_lock_enqueue(ns, &lock, NULL, flags);
-		if (lock->l_completion_ast != NULL) {
+		if (lock->l_completion_ast) {
 			int err = lock->l_completion_ast(lock, *flags, NULL);
 
 			if (!rc)
@@ -505,7 +505,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		}
 	}
 
-	if (lvb_len && lvb != NULL) {
+	if (lvb_len && lvb) {
 		/* Copy the LVB here, and not earlier, because the completion
 		 * AST (if any) can override what we got in the reply */
 		memcpy(lvb, lock->l_lvb_data, lvb_len);
@@ -579,7 +579,7 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 	LIST_HEAD(head);
 	int rc;
 
-	if (cancels == NULL)
+	if (!cancels)
 		cancels = &head;
 	if (ns_connect_cancelset(ns)) {
 		/* Estimate the amount of available space in the request. */
@@ -665,15 +665,13 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	int		    rc, err;
 	struct ptlrpc_request *req;
 
-	LASSERT(exp != NULL);
-
 	ns = exp->exp_obd->obd_namespace;
 
 	/* If we're replaying this lock, just check some invariants.
 	 * If we're creating a new lock, get everything all setup nice. */
 	if (is_replay) {
 		lock = ldlm_handle2lock_long(lockh, 0);
-		LASSERT(lock != NULL);
+		LASSERT(lock);
 		LDLM_DEBUG(lock, "client-side enqueue START");
 		LASSERT(exp == lock->l_conn_export);
 	} else {
@@ -685,13 +683,13 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		lock = ldlm_lock_create(ns, res_id, einfo->ei_type,
 					einfo->ei_mode, &cbs, einfo->ei_cbdata,
 					lvb_len, lvb_type);
-		if (lock == NULL)
+		if (!lock)
 			return -ENOMEM;
 		/* for the local lock, add the reference */
 		ldlm_lock_addref_internal(lock, einfo->ei_mode);
 		ldlm_lock2handle(lock, lockh);
-		if (policy != NULL)
-				lock->l_policy_data = *policy;
+		if (policy)
+			lock->l_policy_data = *policy;
 
 		if (einfo->ei_type == LDLM_EXTENT)
 			lock->l_req_extent = policy->l_extent;
@@ -706,12 +704,12 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 	/* lock not sent to server yet */
 
-	if (reqp == NULL || *reqp == NULL) {
+	if (!reqp || !*reqp) {
 		req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp),
 						&RQF_LDLM_ENQUEUE,
 						LUSTRE_DLM_VERSION,
 						LDLM_ENQUEUE);
-		if (req == NULL) {
+		if (!req) {
 			failed_lock_cleanup(ns, lock, einfo->ei_mode);
 			LDLM_LOCK_RELEASE(lock);
 			return -ENOMEM;
@@ -754,7 +752,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     policy->l_extent.end == OBD_OBJECT_EOF));
 
 	if (async) {
-		LASSERT(reqp != NULL);
+		LASSERT(reqp);
 		return 0;
 	}
 
@@ -773,7 +771,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	else
 		rc = err;
 
-	if (!req_passed_in && req != NULL) {
+	if (!req_passed_in && req) {
 		ptlrpc_req_finished(req);
 		if (reqp)
 			*reqp = NULL;
@@ -832,7 +830,7 @@ static void ldlm_cancel_pack(struct ptlrpc_request *req,
 	int max, packed = 0;
 
 	dlm = req_capsule_client_get(&req->rq_pill, &RMF_DLM_REQ);
-	LASSERT(dlm != NULL);
+	LASSERT(dlm);
 
 	/* Check the room in the request buffer. */
 	max = req_capsule_get_size(&req->rq_pill, &RMF_DLM_REQ, RCL_CLIENT) -
@@ -868,7 +866,7 @@ static int ldlm_cli_cancel_req(struct obd_export *exp,
 	int free, sent = 0;
 	int rc = 0;
 
-	LASSERT(exp != NULL);
+	LASSERT(exp);
 	LASSERT(count > 0);
 
 	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL, cfs_fail_val);
@@ -883,14 +881,14 @@ static int ldlm_cli_cancel_req(struct obd_export *exp,
 
 	while (1) {
 		imp = class_exp2cliimp(exp);
-		if (imp == NULL || imp->imp_invalid) {
+		if (!imp || imp->imp_invalid) {
 			CDEBUG(D_DLMTRACE,
 			       "skipping cancel on invalid import %p\n", imp);
 			return count;
 		}
 
 		req = ptlrpc_request_alloc(imp, &RQF_LDLM_CANCEL);
-		if (req == NULL) {
+		if (!req) {
 			rc = -ENOMEM;
 			goto out;
 		}
@@ -946,7 +944,6 @@ out:
 
 static inline struct ldlm_pool *ldlm_imp2pl(struct obd_import *imp)
 {
-	LASSERT(imp != NULL);
 	return &imp->imp_obd->obd_namespace->ns_pool;
 }
 
@@ -1016,7 +1013,7 @@ int ldlm_cli_cancel(struct lustre_handle *lockh,
 
 	/* concurrent cancels on the same handle can happen */
 	lock = ldlm_handle2lock_long(lockh, LDLM_FL_CANCELING);
-	if (lock == NULL) {
+	if (!lock) {
 		LDLM_DEBUG_NOLOCK("lock is already being destroyed\n");
 		return 0;
 	}
@@ -1307,7 +1304,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		count += unused - ns->ns_max_unused;
 
 	pf = ldlm_cancel_lru_policy(ns, flags);
-	LASSERT(pf != NULL);
+	LASSERT(pf);
 
 	while (!list_empty(&ns->ns_unused_list)) {
 		ldlm_policy_res_t result;
@@ -1476,7 +1473,7 @@ int ldlm_cancel_resource_local(struct ldlm_resource *res,
 
 	lock_res(res);
 	list_for_each_entry(lock, &res->lr_granted, l_res_link) {
-		if (opaque != NULL && lock->l_ast_data != opaque) {
+		if (opaque && lock->l_ast_data != opaque) {
 			LDLM_ERROR(lock, "data %p doesn't match opaque %p",
 				   lock->l_ast_data, opaque);
 			continue;
@@ -1591,7 +1588,7 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 	int rc;
 
 	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
-	if (res == NULL) {
+	if (!res) {
 		/* This is not a problem. */
 		CDEBUG(D_INFO, "No resource %llu\n", res_id->name[0]);
 		return 0;
@@ -1645,10 +1642,10 @@ int ldlm_cli_cancel_unused(struct ldlm_namespace *ns,
 		.lc_opaque      = opaque,
 	};
 
-	if (ns == NULL)
+	if (!ns)
 		return ELDLM_OK;
 
-	if (res_id != NULL) {
+	if (res_id) {
 		return ldlm_cli_cancel_unused_resource(ns, res_id, NULL,
 						       LCK_MINMODE, flags,
 						       opaque);
@@ -1743,13 +1740,13 @@ int ldlm_resource_iterate(struct ldlm_namespace *ns,
 	struct ldlm_resource *res;
 	int rc;
 
-	if (ns == NULL) {
+	if (!ns) {
 		CERROR("must pass in namespace\n");
 		LBUG();
 	}
 
 	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
-	if (res == NULL)
+	if (!res)
 		return 0;
 
 	LDLM_RESOURCE_ADDREF(res);
@@ -1796,7 +1793,7 @@ static int replay_lock_interpret(const struct lu_env *env,
 		goto out;
 
 	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
-	if (reply == NULL) {
+	if (!reply) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1882,7 +1879,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 
 	req = ptlrpc_request_alloc_pack(imp, &RQF_LDLM_ENQUEUE,
 					LUSTRE_DLM_VERSION, LDLM_ENQUEUE);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	/* We're part of recovery, so don't wait for it. */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 0ae6100..6ae8c60 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -380,7 +380,7 @@ static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
 	else
 		ldebugfs_remove(&ns->ns_debugfs_entry);
 
-	if (ns->ns_stats != NULL)
+	if (ns->ns_stats)
 		lprocfs_free_stats(&ns->ns_stats);
 }
 
@@ -400,7 +400,7 @@ static int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
 				   "%s", ldlm_ns_name(ns));
 
 	ns->ns_stats = lprocfs_alloc_stats(LDLM_NSS_LAST, 0);
-	if (ns->ns_stats == NULL) {
+	if (!ns->ns_stats) {
 		kobject_put(&ns->ns_kobj);
 		return -ENOMEM;
 	}
@@ -420,7 +420,7 @@ static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
 	} else {
 		ns_entry = debugfs_create_dir(ldlm_ns_name(ns),
 					      ldlm_ns_debugfs_dir);
-		if (ns_entry == NULL)
+		if (!ns_entry)
 			return -ENOMEM;
 		ns->ns_debugfs_entry = ns_entry;
 	}
@@ -631,7 +631,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	int		    idx;
 	int		    rc;
 
-	LASSERT(obd != NULL);
+	LASSERT(obd);
 
 	rc = ldlm_get_ref();
 	if (rc) {
@@ -664,7 +664,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 					 CFS_HASH_BIGNAME |
 					 CFS_HASH_SPIN_BKTLOCK |
 					 CFS_HASH_NO_ITEMREF);
-	if (ns->ns_rs_hash == NULL)
+	if (!ns->ns_rs_hash)
 		goto out_ns;
 
 	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, idx) {
@@ -763,7 +763,7 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 			break;
 		}
 
-		if (lock == NULL) {
+		if (!lock) {
 			unlock_res(res);
 			break;
 		}
@@ -837,7 +837,7 @@ static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
  */
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags)
 {
-	if (ns == NULL) {
+	if (!ns) {
 		CDEBUG(D_INFO, "NULL ns, skipping cleanup\n");
 		return ELDLM_OK;
 	}
@@ -1032,7 +1032,7 @@ static struct ldlm_resource *ldlm_resource_new(void)
 	int idx;
 
 	res = kmem_cache_alloc(ldlm_resource_slab, GFP_NOFS | __GFP_ZERO);
-	if (res == NULL)
+	if (!res)
 		return NULL;
 
 	INIT_LIST_HEAD(&res->lr_granted);
@@ -1073,14 +1073,13 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	__u64		 version;
 	int		      ns_refcount = 0;
 
-	LASSERT(ns != NULL);
-	LASSERT(parent == NULL);
-	LASSERT(ns->ns_rs_hash != NULL);
+	LASSERT(!parent);
+	LASSERT(ns->ns_rs_hash);
 	LASSERT(name->name[0] != 0);
 
 	cfs_hash_bd_get_and_lock(ns->ns_rs_hash, (void *)name, &bd, 0);
 	hnode = cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
-	if (hnode != NULL) {
+	if (hnode) {
 		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
 		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
 		/* Synchronize with regard to resource creation. */
@@ -1117,7 +1116,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	hnode = (version == cfs_hash_bd_version_get(&bd)) ?  NULL :
 		cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
 
-	if (hnode != NULL) {
+	if (hnode) {
 		/* Someone won the race and already added the resource. */
 		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
 		/* Clean lu_ref for failed resource. */
-- 
2.1.0
