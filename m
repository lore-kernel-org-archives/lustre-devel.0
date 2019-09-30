From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:11 -0400
Subject: [lustre-devel] [PATCH 052/151] lustre: mds: combine DoM bit with
 other IBITS
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-53-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

The DoM bit combining with other ibits opens way to several
optimization, like getting IO lock in advance along with OPEN,
size attribute caching at client and others.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 238a309ea608 ("LU-3285 mds: combine DoM bit with other IBITS")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Reviewed-on: https://review.whamcloud.com/28024
Lustre-commit: f8929e6d0f3c ("LU-3285 mdc: remove wrong assertion from mdc_object_ast_clear")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30021
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h          |  2 +
 fs/lustre/include/lustre_dlm.h         |  2 +
 fs/lustre/ldlm/ldlm_inodebits.c        | 22 ++++++++
 fs/lustre/ldlm/ldlm_internal.h         |  1 +
 fs/lustre/ldlm/ldlm_lock.c             |  2 +-
 fs/lustre/llite/namei.c                | 57 ++++++++++++++++++---
 fs/lustre/lov/lov_object.c             |  8 ++-
 fs/lustre/mdc/mdc_dev.c                | 94 +++++++++++++++++++++++-----------
 fs/lustre/mdc/mdc_internal.h           |  3 +-
 fs/lustre/mdc/mdc_locks.c              | 50 +++++++++++++++---
 fs/lustre/ptlrpc/pack_generic.c        |  4 +-
 fs/lustre/ptlrpc/wiretest.c            | 16 +++---
 include/uapi/linux/lustre/lustre_idl.h |  7 +--
 13 files changed, 209 insertions(+), 59 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c04f6c9..0894b2e 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -286,6 +286,8 @@ struct cl_layout {
 	struct lu_buf		cl_buf;
 	/** size of layout in lov_mds_md format. */
 	size_t			cl_size;
+	/** size of DoM component if exists or zero otherwise */
+	u32		cl_dom_comp_size;
 	/** Layout generation. */
 	u32			cl_layout_gen;
 	/** whether layout is a composite one */
diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index feef43a..28b5cfa 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1390,5 +1390,7 @@ static inline int ldlm_extent_contain(const struct ldlm_extent *ex1,
 	return ex1->start <= ex2->start && ex1->end >= ex2->end;
 }
 
+int ldlm_inodebits_drop(struct ldlm_lock *lock,  __u64 to_drop);
+
 #endif
 /** @} LDLM */
diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index 2926208..ea63d9d 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -67,3 +67,25 @@ void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
 }
+
+int ldlm_inodebits_drop(struct ldlm_lock *lock,  __u64 to_drop)
+{
+	check_res_locked(lock->l_resource);
+
+	/* Just return if there are no conflicting bits */
+	if ((lock->l_policy_data.l_inodebits.bits & to_drop) == 0) {
+		LDLM_WARN(lock, "try to drop unset bits %#llx/%#llx\n",
+			  lock->l_policy_data.l_inodebits.bits, to_drop);
+		/* nothing to do */
+		return 0;
+	}
+
+	/* remove lock from a skiplist and put in the new place
+	 * according with new inodebits
+	 */
+	ldlm_resource_unlink_lock(lock);
+	lock->l_policy_data.l_inodebits.bits &= ~to_drop;
+	ldlm_grant_lock_with_skiplist(lock);
+	return 0;
+}
+EXPORT_SYMBOL(ldlm_inodebits_drop);
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 275d823..b9d2e9a 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -128,6 +128,7 @@ enum ldlm_desc_ast_t {
 	LDLM_WORK_GL_AST
 };
 
+void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock);
 void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list);
 int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		  enum req_location loc, void *data, int size);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 235a137..6b4dd41 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -981,7 +981,7 @@ static void ldlm_granted_list_add_lock(struct ldlm_lock *lock,
  * Add a lock to granted list on a resource maintaining skiplist
  * correctness.
  */
-static void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock)
+void ldlm_grant_lock_with_skiplist(struct ldlm_lock *lock)
 {
 	struct sl_insert_point prev;
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 9c9acf2..fb75441 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -177,6 +177,43 @@ int ll_test_inode_by_fid(struct inode *inode, void *opaque)
 	return lu_fid_eq(&ll_i2info(inode)->lli_fid, opaque);
 }
 
+int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
+{
+	struct lu_env *env;
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct cl_layout clt = { .cl_layout_gen = 0, };
+	int rc;
+	u16 refcheck;
+
+	if (!lli->lli_clob)
+		return 0;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	rc = cl_object_layout_get(env, lli->lli_clob, &clt);
+	if (rc) {
+		CDEBUG(D_INODE, "Cannot get layout for "DFID"\n",
+		       PFID(ll_inode2fid(inode)));
+		rc = -ENODATA;
+	} else if (clt.cl_dom_comp_size == 0) {
+		CDEBUG(D_INODE, "DOM lock without DOM layout for "DFID"\n",
+		       PFID(ll_inode2fid(inode)));
+		rc = -EINVAL;
+	} else {
+		enum cl_fsync_mode mode;
+		loff_t end = clt.cl_dom_comp_size - 1;
+
+		mode = ldlm_is_discard_data(lock) ?
+					CL_FSYNC_DISCARD : CL_FSYNC_LOCAL;
+		rc = cl_sync_file_range(inode, 0, end, mode, 1);
+		truncate_inode_pages_range(inode->i_mapping, 0, end);
+	}
+	cl_env_put(env, &refcheck);
+	return rc;
+}
+
 int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		       void *data, int flag)
 {
@@ -196,11 +233,6 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		struct inode *inode = ll_inode_from_resource_lock(lock);
 		u64 bits = lock->l_policy_data.l_inodebits.bits;
 
-		/* Inode is set to lock->l_resource->lr_lvb_inode
-		 * for mdc - bug 24555
-		 */
-		LASSERT(!lock->l_ast_data);
-
 		if (!inode)
 			break;
 
@@ -250,9 +282,22 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		}
 
 		if (bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE |
-			    MDS_INODELOCK_LAYOUT | MDS_INODELOCK_PERM))
+			    MDS_INODELOCK_LAYOUT | MDS_INODELOCK_PERM |
+			    MDS_INODELOCK_DOM))
 			ll_have_md_lock(inode, &bits, LCK_MINMODE);
 
+		if (bits & MDS_INODELOCK_DOM) {
+			rc =  ll_dom_lock_cancel(inode, lock);
+			if (rc < 0)
+				CDEBUG(D_INODE, "cannot flush DoM data "
+				       DFID": rc = %d\n",
+				       PFID(ll_inode2fid(inode)), rc);
+			lock_res_and_lock(lock);
+			ldlm_set_kms_ignore(lock);
+			unlock_res_and_lock(lock);
+			bits &= ~MDS_INODELOCK_DOM;
+		}
+
 		if (bits & MDS_INODELOCK_LAYOUT) {
 			struct cl_object_conf conf = {
 				.coc_opc = OBJECT_CONF_INVALIDATE,
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 34575dc..9fcf51b 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1869,8 +1869,14 @@ static int lov_object_layout_get(const struct lu_env *env,
 
 	cl->cl_size = lov_comp_md_size(lsm);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
-	cl->cl_is_composite = lsm_is_composite(lsm->lsm_magic);
+	if (lsm_is_composite(lsm->lsm_magic)) {
+		struct lov_stripe_md_entry *lsme = lsm->lsm_entries[0];
 
+		cl->cl_is_composite = true;
+
+		if (lsme_is_dom(lsme))
+			cl->cl_dom_comp_size = lsme->lsme_extent.e_end;
+	}
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
 	lov_lsm_put(lsm);
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 3a7afab..e28c863 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -63,16 +63,26 @@ static void mdc_lock_build_einfo(const struct lu_env *env,
 	einfo->ei_cbdata = osc; /* value to be put into ->l_ast_data */
 }
 
-static int mdc_set_dom_lock_data(struct ldlm_lock *lock, void *data)
+static void mdc_lock_lvb_update(const struct lu_env *env,
+				struct osc_object *osc,
+				struct ldlm_lock *dlmlock,
+				struct ost_lvb *lvb);
+
+static int mdc_set_dom_lock_data(const struct lu_env *env,
+				 struct ldlm_lock *lock, void *data)
 {
+	struct osc_object *obj = data;
 	int set = 0;
 
 	LASSERT(lock);
+	LASSERT(lock->l_glimpse_ast == mdc_ldlm_glimpse_ast);
 
 	lock_res_and_lock(lock);
-
-	if (!lock->l_ast_data)
+	if (!lock->l_ast_data) {
 		lock->l_ast_data = data;
+		mdc_lock_lvb_update(env, obj, lock, NULL);
+	}
+
 	if (lock->l_ast_data == data)
 		set = 1;
 
@@ -81,7 +91,8 @@ static int mdc_set_dom_lock_data(struct ldlm_lock *lock, void *data)
 	return set;
 }
 
-int mdc_dom_lock_match(struct obd_export *exp, struct ldlm_res_id *res_id,
+int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
+		       struct ldlm_res_id *res_id,
 		       enum ldlm_type type, union ldlm_policy_data *policy,
 		       enum ldlm_mode mode, u64 *flags, void *data,
 		       struct lustre_handle *lockh, int unref)
@@ -99,7 +110,7 @@ int mdc_dom_lock_match(struct obd_export *exp, struct ldlm_res_id *res_id,
 		struct ldlm_lock *lock = ldlm_handle2lock(lockh);
 
 		LASSERT(lock);
-		if (!mdc_set_dom_lock_data(lock, data)) {
+		if (!mdc_set_dom_lock_data(env, lock, data)) {
 			ldlm_lock_decref(lockh, rc);
 			rc = 0;
 		}
@@ -137,8 +148,8 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
 	 * VFS and page cache already protect us locally, so lots of readers/
 	 * writers can share a single PW lock.
 	 */
-	mode = mdc_dom_lock_match(osc_export(obj), resname, LDLM_IBITS, policy,
-				  LCK_PR | LCK_PW, &flags, obj, &lockh,
+	mode = mdc_dom_lock_match(env, osc_export(obj), resname, LDLM_IBITS,
+				  policy, LCK_PR | LCK_PW, &flags, obj, &lockh,
 				  dap_flags & OSC_DAP_FL_CANCELING);
 	if (mode) {
 		lock = ldlm_handle2lock(&lockh);
@@ -297,6 +308,7 @@ static int mdc_dlm_blocking_ast0(const struct lu_env *env,
 		dlmlock->l_ast_data = NULL;
 		cl_object_get(obj);
 	}
+	ldlm_set_kms_ignore(dlmlock);
 	unlock_res_and_lock(dlmlock);
 
 	/* if l_ast_data is NULL, the dlmlock was enqueued by AGL or
@@ -377,10 +389,8 @@ int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
  *
  * Called under lock and resource spin-locks.
  */
-static void mdc_lock_lvb_update(const struct lu_env *env,
-				struct osc_object *osc,
-				struct ldlm_lock *dlmlock,
-				struct ost_lvb *lvb)
+void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
+			 struct ldlm_lock *dlmlock, struct ost_lvb *lvb)
 {
 	struct cl_object *obj = osc2cl(osc);
 	struct lov_oinfo *oinfo = osc->oo_oinfo;
@@ -409,9 +419,8 @@ static void mdc_lock_lvb_update(const struct lu_env *env,
 			attr->cat_kms = size;
 		} else {
 			LDLM_DEBUG(dlmlock,
-				   "lock acquired, setting rss=%llu, leaving kms=%llu, end=%llu",
-				   lvb->lvb_size, oinfo->loi_kms,
-				   dlmlock->l_policy_data.l_extent.end);
+				   "lock acquired, setting rss=%llu, leaving kms=%llu",
+				   lvb->lvb_size, oinfo->loi_kms);
 		}
 	}
 	cl_object_attr_update(env, obj, attr, valid);
@@ -541,8 +550,9 @@ int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb)
 	lvb->lvb_mtime = body->mbo_mtime;
 	lvb->lvb_atime = body->mbo_atime;
 	lvb->lvb_ctime = body->mbo_ctime;
-	lvb->lvb_blocks = body->mbo_blocks;
-	lvb->lvb_size = body->mbo_size;
+	lvb->lvb_blocks = body->mbo_dom_blocks;
+	lvb->lvb_size = body->mbo_dom_size;
+
 	return 0;
 }
 
@@ -643,8 +653,9 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
  * is excluded from the cluster -- such scenarious make the life difficult, so
  * release locks just after they are obtained.
  */
-int mdc_enqueue_send(struct obd_export *exp, struct ldlm_res_id *res_id,
-		     u64 *flags, union ldlm_policy_data *policy,
+int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
+		     struct ldlm_res_id *res_id, u64 *flags,
+		     union ldlm_policy_data *policy,
 		     struct ost_lvb *lvb, int kms_valid,
 		     osc_enqueue_upcall_f upcall, void *cookie,
 		     struct ldlm_enqueue_info *einfo, int async)
@@ -658,9 +669,6 @@ int mdc_enqueue_send(struct obd_export *exp, struct ldlm_res_id *res_id,
 	u64 match_flags = *flags;
 	int rc;
 
-	if (!kms_valid)
-		goto no_match;
-
 	mode = einfo->ei_mode;
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
@@ -676,10 +684,10 @@ int mdc_enqueue_send(struct obd_export *exp, struct ldlm_res_id *res_id,
 			return ELDLM_OK;
 
 		matched = ldlm_handle2lock(&lockh);
-		if (!mdc_set_dom_lock_data(matched, einfo->ei_cbdata)) {
-			ldlm_lock_decref(&lockh, mode);
-			LDLM_LOCK_PUT(matched);
-		} else {
+		if (ldlm_is_kms_ignore(matched))
+			goto no_match;
+
+		if (mdc_set_dom_lock_data(env, matched, einfo->ei_cbdata)) {
 			*flags |= LDLM_FL_LVB_READY;
 
 			/* We already have a lock, and it's referenced. */
@@ -689,9 +697,11 @@ int mdc_enqueue_send(struct obd_export *exp, struct ldlm_res_id *res_id,
 			LDLM_LOCK_PUT(matched);
 			return ELDLM_OK;
 		}
+no_match:
+		ldlm_lock_decref(&lockh, mode);
+		LDLM_LOCK_PUT(matched);
 	}
 
-no_match:
 	if (*flags & (LDLM_FL_TEST_LOCK | LDLM_FL_MATCH_LOCK))
 		return -ENOLCK;
 
@@ -828,9 +838,9 @@ static int mdc_lock_enqueue(const struct lu_env *env,
 	fid_build_reg_res_name(lu_object_fid(osc2lu(osc)), resname);
 	mdc_lock_build_policy(env, policy);
 	LASSERT(!oscl->ols_speculative);
-	result = mdc_enqueue_send(osc_export(osc), resname, &oscl->ols_flags,
-				  policy, &oscl->ols_lvb,
-				  osc->oo_oinfo->loi_kms_valid,
+	result = mdc_enqueue_send(env, osc_export(osc), resname,
+				  &oscl->ols_flags, policy,
+				  &oscl->ols_lvb, osc->oo_oinfo->loi_kms_valid,
 				  upcall, cookie, &oscl->ols_einfo, async);
 	if (result == 0) {
 		if (osc_lock_is_lockless(oscl)) {
@@ -1155,6 +1165,30 @@ static int mdc_attr_get(const struct lu_env *env, struct cl_object *obj,
 	return osc_attr_get(env, obj, attr);
 }
 
+static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
+{
+	if ((!lock->l_ast_data && !ldlm_is_kms_ignore(lock)) ||
+	    (lock->l_ast_data == data)) {
+		lock->l_ast_data = NULL;
+		ldlm_set_kms_ignore(lock);
+	}
+	return LDLM_ITER_CONTINUE;
+}
+
+int mdc_object_prune(const struct lu_env *env, struct cl_object *obj)
+{
+	struct osc_object *osc = cl2osc(obj);
+	struct ldlm_res_id *resname = &osc_env_info(env)->oti_resname;
+
+	/* DLM locks don't hold a reference of osc_object so we have to
+	 * clear it before the object is being destroyed.
+	 */
+	osc_build_res_name(osc, resname);
+	ldlm_resource_iterate(osc_export(osc)->exp_obd->obd_namespace, resname,
+			      mdc_object_ast_clear, osc);
+	return 0;
+}
+
 static const struct cl_object_operations mdc_ops = {
 	.coo_page_init		= osc_page_init,
 	.coo_lock_init		= mdc_lock_init,
@@ -1163,7 +1197,7 @@ static int mdc_attr_get(const struct lu_env *env, struct cl_object *obj,
 	.coo_attr_update	= osc_attr_update,
 	.coo_glimpse		= osc_object_glimpse,
 	.coo_req_attr_set	= mdc_req_attr_set,
-	.coo_prune		= osc_object_prune,
+	.coo_prune		= mdc_object_prune,
 };
 
 static const struct osc_object_operations mdc_object_ops = {
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 6e69dfe..6b282b2 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -156,5 +156,6 @@ static inline unsigned long hash_x_index(u64 hash, int hash64)
 extern struct lu_device_type mdc_device_type;
 int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 			  struct ldlm_lock_desc *new, void *data, int flag);
-
+int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
+int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb);
 #endif
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 4e6928e..9c4dcad 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -550,6 +550,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	struct ldlm_request *lockreq;
 	struct ldlm_reply *lockrep;
 	struct ldlm_lock *lock;
+	struct mdt_body *body = NULL;
 	void *lvb_data = NULL;
 	u32 lvb_len = 0;
 
@@ -611,8 +612,6 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 	/* We know what to expect, so we do any byte flipping required here */
 	if (it_has_reply_body(it)) {
-		struct mdt_body *body;
-
 		body = req_capsule_server_get(pill, &RMF_MDT_BODY);
 		if (!body) {
 			CERROR("Can't swab mdt_body\n");
@@ -699,7 +698,10 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	 * server. - Jinshan
 	 */
 	lock = ldlm_handle2lock(lockh);
-	if (lock && ldlm_has_layout(lock) && lvb_data &&
+	if (!lock)
+		return rc;
+
+	if (ldlm_has_layout(lock) && lvb_data &&
 	    !(lockrep->lock_flags & LDLM_FL_BLOCKED_MASK)) {
 		void *lmm;
 
@@ -708,8 +710,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 		lmm = kvzalloc(lvb_len, GFP_NOFS);
 		if (!lmm) {
-			LDLM_LOCK_PUT(lock);
-			return -ENOMEM;
+			rc = -ENOMEM;
+			goto out_lock;
 		}
 		memcpy(lmm, lvb_data, lvb_len);
 
@@ -725,8 +727,25 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		if (lmm)
 			kvfree(lmm);
 	}
-	if (lock)
-		LDLM_LOCK_PUT(lock);
+
+	if (ldlm_has_dom(lock)) {
+		LASSERT(lock->l_glimpse_ast == mdc_ldlm_glimpse_ast);
+
+		body = req_capsule_server_get(pill, &RMF_MDT_BODY);
+		if (!(body->mbo_valid & OBD_MD_DOM_SIZE)) {
+			LDLM_ERROR(lock, "%s: DoM lock without size.\n",
+				   exp->exp_obd->obd_name);
+			rc = -EPROTO;
+			goto out_lock;
+		}
+
+		LDLM_DEBUG(lock, "DoM lock is returned by: %s, size: %llu",
+			   ldlm_it2str(it->it_op), body->mbo_dom_size);
+
+		rc = mdc_fill_lvb(req, &lock->l_ost_lvb);
+	}
+out_lock:
+	LDLM_LOCK_PUT(lock);
 
 	return rc;
 }
@@ -831,6 +850,14 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		}
 	}
 
+	/* With Data-on-MDT the glimpse callback is needed too.
+	 * It is set here in advance but not in mdc_finish_enqueue()
+	 * to avoid possible races. It is safe to have glimpse handler
+	 * for non-DOM locks and costs nothing.
+	 */
+	if (!einfo->ei_cb_gl)
+		einfo->ei_cb_gl = mdc_ldlm_glimpse_ast;
+
 	rc = ldlm_cli_enqueue(exp, &req, einfo, &res_id, policy, &flags, NULL,
 			      0, lvb_type, lockh, 0);
 	if (!it) {
@@ -1133,6 +1160,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		.ei_mode	= it_to_lock_mode(it),
 		.ei_cb_bl	= cb_blocking,
 		.ei_cb_cp	= ldlm_completion_ast,
+		.ei_cb_gl	= mdc_ldlm_glimpse_ast,
 	};
 	struct lustre_handle lockh;
 	int rc = 0;
@@ -1258,6 +1286,14 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 		return rc;
 	}
 
+	/* With Data-on-MDT the glimpse callback is needed too.
+	 * It is set here in advance but not in mdc_finish_enqueue()
+	 * to avoid possible races. It is safe to have glimpse handler
+	 * for non-DOM locks and costs nothing.
+	 */
+	if (!minfo->mi_einfo.ei_cb_gl)
+		minfo->mi_einfo.ei_cb_gl = mdc_ldlm_glimpse_ast;
+
 	rc = ldlm_cli_enqueue(exp, &req, &minfo->mi_einfo, &res_id, &policy,
 			      &flags, NULL, 0, LVB_T_NONE, &minfo->mi_lockh, 1);
 	if (rc < 0) {
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 6d61cc7..a631dde 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1758,8 +1758,8 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab32s(&b->mbo_uid_h);
 	__swab32s(&b->mbo_gid_h);
 	__swab32s(&b->mbo_projid);
-	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_6) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_7) == 0);
+	__swab64s(&b->mbo_dom_size);
+	__swab64s(&b->mbo_dom_blocks);
 	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_8) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_9) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_10) == 0);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 2a38d1e..1092cc2 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1982,14 +1982,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_projid));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_projid) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_projid));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_6) == 176, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_padding_6));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_6) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_6));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_7) == 184, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_padding_7));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_7) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_7));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_dom_size) == 176, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_dom_size));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_dom_size) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_dom_size));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_dom_blocks) == 184, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_dom_blocks));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_dom_blocks) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_dom_blocks));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_8) == 192, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_padding_8));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_8) == 8, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 57a869f..2b585b6 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1088,6 +1088,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLUID		(0x00000200ULL) /* user ID */
 #define OBD_MD_FLGID		(0x00000400ULL) /* group ID */
 #define OBD_MD_FLFLAGS		(0x00000800ULL) /* flags word */
+#define OBD_MD_DOM_SIZE		(0x00001000ULL) /* Data-on-MDT component size */
 #define OBD_MD_FLNLINK		(0x00002000ULL) /* link count */
 #define OBD_MD_FLGENER		(0x00004000ULL) /* generation number */
 /*#define OBD_MD_FLINLINE	(0x00008000ULL)  inline data. used until 1.6.5 */
@@ -1547,9 +1548,9 @@ struct mdt_body {
 	__u32	mbo_uid_h;	/* high 32-bits of uid, for FUID */
 	__u32	mbo_gid_h;	/* high 32-bits of gid, for FUID */
 	__u32	mbo_projid;	/* also fix lustre_swab_mdt_body */
-	__u64	mbo_padding_6;
-	__u64	mbo_padding_7;
-	__u64	mbo_padding_8;
+	__u64	mbo_dom_size;	/* size of DOM component */
+	__u64	mbo_dom_blocks; /* blocks consumed by DOM component */
+	__u64	mbo_padding_8; /* also fix lustre_swab_mdt_body */
 	__u64	mbo_padding_9;
 	__u64	mbo_padding_10;
 }; /* 216 */
-- 
1.8.3.1
