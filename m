Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5C0C8FA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:13:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynZY6GRXz21BM;
	Thu, 27 Oct 2022 07:08:05 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynZ51LRpz217K
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:07:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7F9C910090FF;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7A9B4E8CAE; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:34 -0400
Message-Id: <1666879542-10737-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/15] lustre: ldlm: group lock fix
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Vitaly Fertman <vitaly.fertman@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@hpe.com>

The original LU-9964 fix had a problem because with many pages in
memory grouplock unlock takes 10+ seconds just to discard them.

The current patch makes grouplock unlock asynchronous. It introduces
a logic similar to the original one, but on mdc/osc layer.

HPE-bug-id: LUS-10644, LUS-10906
WC-bug-id: https://jira.whamcloud.com/browse/LU-16046
Lustre-commit: 3ffcb5b700ebfd68 ("LU-16046 ldlm: group lock fix")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://es-gerrit.dev.cray.com/159856
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Tested-by: Elena Gryaznova <c17455@cray.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48038
Reviewed-by: Alexander <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  15 ++++
 fs/lustre/mdc/mdc_dev.c        |  46 ++++++++++--
 fs/lustre/osc/osc_lock.c       | 157 +++++++++++++++++++++++++++++++++++++++--
 fs/lustre/osc/osc_object.c     |  16 +++++
 4 files changed, 222 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 884eafe..2e8c184 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -321,6 +321,11 @@ struct osc_object {
 
 	const struct osc_object_operations *oo_obj_ops;
 	bool			oo_initialized;
+
+	wait_queue_head_t	oo_group_waitq;
+	struct mutex		oo_group_mutex;
+	u64			oo_group_users;
+	unsigned long		oo_group_gid;
 };
 
 static inline void osc_build_res_name(struct osc_object *osc,
@@ -657,6 +662,16 @@ int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
 int osc_object_find_cbdata(const struct lu_env *env, struct cl_object *obj,
 			   ldlm_iterator_t iter, void *data);
 int osc_object_prune(const struct lu_env *env, struct cl_object *obj);
+void osc_grouplock_inc_locked(struct osc_object *osc, struct ldlm_lock *lock);
+void osc_grouplock_dec(struct osc_object *osc, struct ldlm_lock *lock);
+int osc_grouplock_enqueue_init(const struct lu_env *env,
+			       struct osc_object *obj,
+			       struct osc_lock *oscl,
+			       struct lustre_handle *lh);
+void osc_grouplock_enqueue_fini(const struct lu_env *env,
+				struct osc_object *obj,
+				struct osc_lock *oscl,
+				struct lustre_handle *lh);
 
 /* osc_request.c */
 void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd);
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 2fd137d..978fee3 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -330,6 +330,7 @@ static int mdc_dlm_canceling(const struct lu_env *env,
 	 */
 	if (obj) {
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+		void *data;
 
 		/* Destroy pages covered by the extent of the DLM lock */
 		result = mdc_lock_flush(env, cl2osc(obj), cl_index(obj, 0),
@@ -339,12 +340,17 @@ static int mdc_dlm_canceling(const struct lu_env *env,
 		 */
 		/* losing a lock, update kms */
 		lock_res_and_lock(dlmlock);
+		data = dlmlock->l_ast_data;
 		dlmlock->l_ast_data = NULL;
 		cl_object_attr_lock(obj);
 		attr->cat_kms = 0;
 		cl_object_attr_update(env, obj, attr, CAT_KMS);
 		cl_object_attr_unlock(obj);
 		unlock_res_and_lock(dlmlock);
+
+		/* Skip dec in case mdc_object_ast_clear() did it */
+		if (data && dlmlock->l_req_mode == LCK_GROUP)
+			osc_grouplock_dec(cl2osc(obj), dlmlock);
 		cl_object_put(env, obj);
 	}
 	return result;
@@ -451,7 +457,7 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 }
 
 static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
-			     struct lustre_handle *lockh)
+			     struct lustre_handle *lockh, int errcode)
 {
 	struct osc_object *osc = cl2osc(oscl->ols_cl.cls_obj);
 	struct ldlm_lock *dlmlock;
@@ -504,6 +510,9 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 	LASSERT(oscl->ols_state != OLS_GRANTED);
 	oscl->ols_state = OLS_GRANTED;
+
+	if (errcode != ELDLM_LOCK_MATCHED && dlmlock->l_req_mode == LCK_GROUP)
+		osc_grouplock_inc_locked(osc, dlmlock);
 }
 
 /**
@@ -535,7 +544,7 @@ static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 
 	CDEBUG(D_INODE, "rc %d, err %d\n", rc, errcode);
 	if (rc == 0)
-		mdc_lock_granted(env, oscl, lockh);
+		mdc_lock_granted(env, oscl, lockh, errcode);
 
 	/* Error handling, some errors are tolerable. */
 	if (oscl->ols_glimpse && rc == -ENAVAIL) {
@@ -824,9 +833,9 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
  *
  * This function does not wait for the network communication to complete.
  */
-static int mdc_lock_enqueue(const struct lu_env *env,
-			    const struct cl_lock_slice *slice,
-			    struct cl_io *unused, struct cl_sync_io *anchor)
+static int __mdc_lock_enqueue(const struct lu_env *env,
+			      const struct cl_lock_slice *slice,
+			      struct cl_io *unused, struct cl_sync_io *anchor)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_io *oio = osc_env_io(env);
@@ -912,6 +921,28 @@ static int mdc_lock_enqueue(const struct lu_env *env,
 	return result;
 }
 
+static int mdc_lock_enqueue(const struct lu_env *env,
+			    const struct cl_lock_slice *slice,
+			    struct cl_io *unused, struct cl_sync_io *anchor)
+{
+	struct osc_object *obj = cl2osc(slice->cls_obj);
+	struct osc_lock	*oscl = cl2osc_lock(slice);
+	struct lustre_handle lh = { 0 };
+	int rc;
+
+	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP) {
+		rc = osc_grouplock_enqueue_init(env, obj, oscl, &lh);
+		if (rc < 0)
+			return rc;
+	}
+
+	rc = __mdc_lock_enqueue(env, slice, unused, anchor);
+
+	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP)
+		osc_grouplock_enqueue_fini(env, obj, oscl, &lh);
+	return rc;
+}
+
 static const struct cl_lock_operations mdc_lock_lockless_ops = {
 	.clo_fini	= osc_lock_fini,
 	.clo_enqueue	= mdc_lock_enqueue,
@@ -950,8 +981,6 @@ int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
 
 	ols->ols_flags = flags;
 	ols->ols_speculative = !!(enqflags & CEF_SPECULATIVE);
-	if (lock->cll_descr.cld_mode == CLM_GROUP)
-		ols->ols_flags |= LDLM_FL_ATOMIC_CB;
 
 	if (ols->ols_flags & LDLM_FL_HAS_INTENT) {
 		ols->ols_flags |= LDLM_FL_BLOCK_GRANTED;
@@ -1439,6 +1468,9 @@ static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
 		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
 		cl_object_attr_unlock(&osc->oo_cl);
 		ldlm_clear_lvb_cached(lock);
+
+		if (lock->l_req_mode == LCK_GROUP)
+			osc_grouplock_dec(osc, lock);
 	}
 	return LDLM_ITER_CONTINUE;
 }
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 3b22688..a3e72a6 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -198,7 +198,7 @@ void osc_lock_lvb_update(const struct lu_env *env,
 }
 
 static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
-			     struct lustre_handle *lockh)
+			     struct lustre_handle *lockh, int errcode)
 {
 	struct osc_object *osc = cl2osc(oscl->ols_cl.cls_obj);
 	struct ldlm_lock *dlmlock;
@@ -254,7 +254,126 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 	LASSERT(oscl->ols_state != OLS_GRANTED);
 	oscl->ols_state = OLS_GRANTED;
+
+	if (errcode != ELDLM_LOCK_MATCHED && dlmlock->l_req_mode == LCK_GROUP)
+		osc_grouplock_inc_locked(osc, dlmlock);
+}
+
+void osc_grouplock_inc_locked(struct osc_object *osc, struct ldlm_lock *lock)
+{
+	LASSERT(lock->l_req_mode == LCK_GROUP);
+
+	if (osc->oo_group_users == 0)
+		osc->oo_group_gid = lock->l_policy_data.l_extent.gid;
+	osc->oo_group_users++;
+
+	LDLM_DEBUG(lock, "users %llu gid %llu\n",
+		   osc->oo_group_users,
+		   lock->l_policy_data.l_extent.gid);
+}
+EXPORT_SYMBOL(osc_grouplock_inc_locked);
+
+void osc_grouplock_dec(struct osc_object *osc, struct ldlm_lock *lock)
+{
+	LASSERT(lock->l_req_mode == LCK_GROUP);
+
+	mutex_lock(&osc->oo_group_mutex);
+
+	LASSERT(osc->oo_group_users > 0);
+	osc->oo_group_users--;
+	if (osc->oo_group_users == 0) {
+		osc->oo_group_gid = 0;
+		wake_up_all(&osc->oo_group_waitq);
+	}
+	mutex_unlock(&osc->oo_group_mutex);
+
+	LDLM_DEBUG(lock, "users %llu gid %lu\n",
+		   osc->oo_group_users, osc->oo_group_gid);
 }
+EXPORT_SYMBOL(osc_grouplock_dec);
+
+int osc_grouplock_enqueue_init(const struct lu_env *env,
+			       struct osc_object *obj,
+			       struct osc_lock *oscl,
+			       struct lustre_handle *lh)
+{
+	struct cl_lock_descr *need = &oscl->ols_cl.cls_lock->cll_descr;
+	int rc = 0;
+
+	LASSERT(need->cld_mode == CLM_GROUP);
+
+	while (true) {
+		bool check_gid = true;
+
+		if (oscl->ols_flags & LDLM_FL_BLOCK_NOWAIT) {
+			if (!mutex_trylock(&obj->oo_group_mutex))
+				return -EAGAIN;
+		} else {
+			mutex_lock(&obj->oo_group_mutex);
+		}
+
+		/**
+		 * If a grouplock of the same gid already exists, match it
+		 * here in advance. Otherwise, if that lock is being cancelled
+		 * there is a chance to get 2 grouplocks for the same file.
+		 */
+		if (obj->oo_group_users &&
+		    obj->oo_group_gid == need->cld_gid) {
+			struct osc_thread_info *info = osc_env_info(env);
+			struct ldlm_res_id *resname = &info->oti_resname;
+			union ldlm_policy_data *policy = &info->oti_policy;
+			struct cl_lock *lock = oscl->ols_cl.cls_lock;
+			u64 flags = oscl->ols_flags | LDLM_FL_BLOCK_GRANTED;
+			struct ldlm_namespace *ns;
+			enum ldlm_mode mode;
+
+			ns = osc_export(obj)->exp_obd->obd_namespace;
+			ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
+			osc_lock_build_policy(env, lock, policy);
+			mode = ldlm_lock_match(ns, flags, resname,
+					       oscl->ols_einfo.ei_type, policy,
+					       oscl->ols_einfo.ei_mode, lh);
+			if (mode)
+				oscl->ols_flags |= LDLM_FL_MATCH_LOCK;
+			else
+				check_gid = false;
+		}
+
+		/**
+		 * If a grouplock exists but cannot be matched, let it to flush
+		 * and wait just for zero users for now.
+		 */
+		if (obj->oo_group_users == 0 ||
+		    (check_gid && obj->oo_group_gid == need->cld_gid))
+			break;
+
+		mutex_unlock(&obj->oo_group_mutex);
+		if (oscl->ols_flags & LDLM_FL_BLOCK_NOWAIT)
+			return -EAGAIN;
+
+		rc = l_wait_event_abortable(obj->oo_group_waitq,
+					    !obj->oo_group_users);
+		if (rc)
+			return rc;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(osc_grouplock_enqueue_init);
+
+void osc_grouplock_enqueue_fini(const struct lu_env *env,
+				struct osc_object *obj,
+				struct osc_lock *oscl,
+				struct lustre_handle *lh)
+{
+	LASSERT(oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP);
+
+	/* If a user was added on enqueue_init, decref it */
+	if (lustre_handle_is_used(lh))
+		ldlm_lock_decref(lh, oscl->ols_einfo.ei_mode);
+	mutex_unlock(&obj->oo_group_mutex);
+}
+EXPORT_SYMBOL(osc_grouplock_enqueue_fini);
 
 /**
  * Lock upcall function that is executed either when a reply to ENQUEUE rpc is
@@ -284,7 +403,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	}
 
 	if (rc == 0)
-		osc_lock_granted(env, oscl, lockh);
+		osc_lock_granted(env, oscl, lockh, errcode);
 
 	/* Error handling, some errors are tolerable. */
 	if (oscl->ols_glimpse && rc == -ENAVAIL) {
@@ -421,6 +540,7 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 		struct ldlm_extent *extent = &dlmlock->l_policy_data.l_extent;
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 		u64 old_kms;
+		void *data;
 
 		/* Destroy pages covered by the extent of the DLM lock */
 		result = osc_lock_flush(cl2osc(obj),
@@ -433,6 +553,7 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 		/* clearing l_ast_data after flushing data,
 		 * to let glimpse ast find the lock and the object
 		 */
+		data = dlmlock->l_ast_data;
 		dlmlock->l_ast_data = NULL;
 		cl_object_attr_lock(obj);
 		/* Must get the value under the lock to avoid race. */
@@ -446,6 +567,9 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 		cl_object_attr_unlock(obj);
 		unlock_res_and_lock(dlmlock);
 
+		/* Skip dec in case osc_object_ast_clear() did it */
+		if (data && dlmlock->l_req_mode == LCK_GROUP)
+			osc_grouplock_dec(cl2osc(obj), dlmlock);
 		cl_object_put(env, obj);
 	}
 	return result;
@@ -931,9 +1055,9 @@ int osc_lock_enqueue_wait(const struct lu_env *env, struct osc_object *obj,
  *
  * This function does not wait for the network communication to complete.
  */
-static int osc_lock_enqueue(const struct lu_env *env,
-			    const struct cl_lock_slice *slice,
-			    struct cl_io *unused, struct cl_sync_io *anchor)
+static int __osc_lock_enqueue(const struct lu_env *env,
+			      const struct cl_lock_slice *slice,
+			      struct cl_io *unused, struct cl_sync_io *anchor)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_io *oio = osc_env_io(env);
@@ -1053,6 +1177,29 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	return result;
 }
 
+static int osc_lock_enqueue(const struct lu_env *env,
+			    const struct cl_lock_slice *slice,
+			    struct cl_io *unused, struct cl_sync_io *anchor)
+{
+	struct osc_object *obj = cl2osc(slice->cls_obj);
+	struct osc_lock	*oscl = cl2osc_lock(slice);
+	struct lustre_handle lh = { 0 };
+	int rc;
+
+	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP) {
+		rc = osc_grouplock_enqueue_init(env, obj, oscl, &lh);
+		if (rc < 0)
+			return rc;
+	}
+
+	rc = __osc_lock_enqueue(env, slice, unused, anchor);
+
+	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP)
+		osc_grouplock_enqueue_fini(env, obj, oscl, &lh);
+
+	return rc;
+}
+
 /**
  * Breaks a link between osc_lock and dlm_lock.
  */
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index efb0533..c3667a3 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -74,6 +74,10 @@ int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 
 	atomic_set(&osc->oo_nr_ios, 0);
 	init_waitqueue_head(&osc->oo_io_waitq);
+	init_waitqueue_head(&osc->oo_group_waitq);
+	mutex_init(&osc->oo_group_mutex);
+	osc->oo_group_users = 0;
+	osc->oo_group_gid = 0;
 
 	osc->oo_root.rb_node = NULL;
 	INIT_LIST_HEAD(&osc->oo_hp_exts);
@@ -113,6 +117,7 @@ void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	LASSERT(atomic_read(&osc->oo_nr_writes) == 0);
 	LASSERT(list_empty(&osc->oo_ol_list));
 	LASSERT(!atomic_read(&osc->oo_nr_ios));
+	LASSERT(!osc->oo_group_users);
 
 	lu_object_fini(obj);
 	/* osc doen't contain an lu_object_header, so we don't need call_rcu */
@@ -225,6 +230,17 @@ static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
 		cl_object_attr_unlock(&osc->oo_cl);
 		ldlm_clear_lvb_cached(lock);
+
+		/**
+		 * Object is being destroyed and gets unlinked from the lock,
+		 * IO is finished and no cached data is left under the lock. As
+		 * grouplock is immediately marked CBPENDING it is not reused.
+		 * It will also be not possible to flush data later due to a
+		 * NULL l_ast_data - enough conditions to let new grouplocks to
+		 * be enqueued even if the lock still exists on client.
+		 */
+		if (lock->l_req_mode == LCK_GROUP)
+			osc_grouplock_dec(osc, lock);
 	}
 	return LDLM_ITER_CONTINUE;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
