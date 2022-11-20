Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A4480C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:39:09 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXln5tp7z21b5;
	Sun, 20 Nov 2022 06:22:13 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXl63d6fz21Jn
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:21:38 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E56F91009354;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E2164E8B89; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:02 -0500
Message-Id: <1668953828-10909-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/22] lustre: ldlm: group lock unlock fix
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

The current patch makes grouplock unlock thread to be not atomic, but
makes a new grouplock enqueue to wait until previous CBPENDING lock
gets destroyed.

HPE-bug-id: LUS-10644

WC-bug-id: https://jira.whamcloud.com/browse/LU-16046
Lustre-commit: 3dc261c06434eceee ("LU-16046 ldlm: group lock unlock fix")
Lustre-commit: 62fd8f9b498ae3d16 ("Revert "LU-16046 revert: "LU-9964 llite: prevent mulitple group locks"")
Lustre-commit: dd609c6f31adeadab ("Revert "LU-16046 ldlm: group lock fix")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://es-gerrit.dev.cray.com/161411
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Tested-by: Alexander Lezhoev <alexander.lezhoev@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49008
Reviewed-by: Alexander <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h   |   1 +
 fs/lustre/include/lustre_osc.h   |  15 ----
 fs/lustre/ldlm/ldlm_lock.c       |  28 ++++++-
 fs/lustre/llite/file.c           |  76 ++++++++++++-------
 fs/lustre/llite/llite_internal.h |   3 +
 fs/lustre/llite/llite_lib.c      |   3 +
 fs/lustre/mdc/mdc_dev.c          |  58 ++++-----------
 fs/lustre/osc/osc_lock.c         | 157 ++-------------------------------------
 fs/lustre/osc/osc_object.c       |  16 ----
 fs/lustre/osc/osc_request.c      |  14 ++--
 10 files changed, 110 insertions(+), 261 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 6053e01..d08c48f 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -855,6 +855,7 @@ enum ldlm_match_flags {
 	LDLM_MATCH_AST		= BIT(1),
 	LDLM_MATCH_AST_ANY	= BIT(2),
 	LDLM_MATCH_RIGHT	= BIT(3),
+	LDLM_MATCH_GROUP	= BIT(4),
 };
 
 /**
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index a0f1afc..d15f46b 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -319,11 +319,6 @@ struct osc_object {
 
 	const struct osc_object_operations *oo_obj_ops;
 	bool			oo_initialized;
-
-	wait_queue_head_t	oo_group_waitq;
-	struct mutex		oo_group_mutex;
-	u64			oo_group_users;
-	unsigned long		oo_group_gid;
 };
 
 static inline void osc_build_res_name(struct osc_object *osc,
@@ -660,16 +655,6 @@ int osc_object_glimpse(const struct lu_env *env, const struct cl_object *obj,
 int osc_object_find_cbdata(const struct lu_env *env, struct cl_object *obj,
 			   ldlm_iterator_t iter, void *data);
 int osc_object_prune(const struct lu_env *env, struct cl_object *obj);
-void osc_grouplock_inc_locked(struct osc_object *osc, struct ldlm_lock *lock);
-void osc_grouplock_dec(struct osc_object *osc, struct ldlm_lock *lock);
-int osc_grouplock_enqueue_init(const struct lu_env *env,
-			       struct osc_object *obj,
-			       struct osc_lock *oscl,
-			       struct lustre_handle *lh);
-void osc_grouplock_enqueue_fini(const struct lu_env *env,
-				struct osc_object *obj,
-				struct osc_lock *oscl,
-				struct lustre_handle *lh);
 
 /* osc_request.c */
 void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 39ab2a0..8659aa5 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -324,6 +324,7 @@ static int ldlm_lock_destroy_internal(struct ldlm_lock *lock)
 		return 0;
 	}
 	ldlm_set_destroyed(lock);
+	wake_up(&lock->l_waitq);
 
 	ldlm_lock_remove_from_lru(lock);
 	class_handle_unhash(&lock->l_handle);
@@ -1067,10 +1068,12 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 	 * can still happen.
 	 */
 	if (ldlm_is_cbpending(lock) &&
-	    !(data->lmd_flags & LDLM_FL_CBPENDING))
+	    !(data->lmd_flags & LDLM_FL_CBPENDING) &&
+	    !(data->lmd_match & LDLM_MATCH_GROUP))
 		return false;
 
-	if (!(data->lmd_match & LDLM_MATCH_UNREF) && ldlm_is_cbpending(lock) &&
+	if (!(data->lmd_match & (LDLM_MATCH_UNREF | LDLM_MATCH_GROUP)) &&
+	    ldlm_is_cbpending(lock) &&
 	    !lock->l_readers && !lock->l_writers)
 		return false;
 
@@ -1136,7 +1139,12 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 		return false;
 
 matched:
-	if (data->lmd_flags & LDLM_FL_TEST_LOCK) {
+	/**
+	 * In case the lock is a CBPENDING grouplock, just pin it and return,
+	 * we need to wait until it gets to DESTROYED.
+	 */
+	if ((data->lmd_flags & LDLM_FL_TEST_LOCK) ||
+	    (ldlm_is_cbpending(lock) && (data->lmd_match & LDLM_MATCH_GROUP))) {
 		LDLM_LOCK_GET(lock);
 		ldlm_lock_touch_in_lru(lock);
 	} else {
@@ -1296,6 +1304,7 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 	};
 	struct ldlm_resource *res;
 	struct ldlm_lock *lock;
+	struct ldlm_lock *group_lock;
 	int matched;
 
 	if (!ns) {
@@ -1314,6 +1323,8 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 		return 0;
 	}
 
+repeat:
+	group_lock = NULL;
 	LDLM_RESOURCE_ADDREF(res);
 	lock_res(res);
 	if (res->lr_type == LDLM_EXTENT)
@@ -1323,8 +1334,19 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 	if (!lock && !(flags & LDLM_FL_BLOCK_GRANTED))
 		lock = search_queue(&res->lr_waiting, &data);
 	matched = lock ? mode : 0;
+
+	if (lock && ldlm_is_cbpending(lock) &&
+	    (data.lmd_match & LDLM_MATCH_GROUP))
+		group_lock = lock;
 	unlock_res(res);
 	LDLM_RESOURCE_DELREF(res);
+
+	if (group_lock) {
+		l_wait_event_abortable(group_lock->l_waitq,
+				       ldlm_is_destroyed(lock));
+		LDLM_LOCK_RELEASE(lock);
+		goto repeat;
+	}
 	ldlm_resource_putref(res);
 
 	if (lock) {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 34a449e..dac829f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2522,15 +2522,30 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	if (ll_file_nolock(file))
 		return -EOPNOTSUPP;
 
-	read_lock(&lli->lli_lock);
+retry:
+	if (file->f_flags & O_NONBLOCK) {
+		if (!mutex_trylock(&lli->lli_group_mutex))
+			return -EAGAIN;
+	} else
+		mutex_lock(&lli->lli_group_mutex);
+
 	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
 		CWARN("group lock already existed with gid %lu\n",
 		      fd->fd_grouplock.lg_gid);
-		read_unlock(&lli->lli_lock);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
+	}
+	if (arg != lli->lli_group_gid && lli->lli_group_users != 0) {
+		if (file->f_flags & O_NONBLOCK) {
+			rc = -EAGAIN;
+			goto out;
+		}
+		mutex_unlock(&lli->lli_group_mutex);
+		wait_var_event(&lli->lli_group_users, !lli->lli_group_users);
+		rc = 0;
+		goto retry;
 	}
 	LASSERT(!fd->fd_grouplock.lg_lock);
-	read_unlock(&lli->lli_lock);
 
 	/**
 	 * XXX: group lock needs to protect all OST objects while PFL
@@ -2549,8 +2564,10 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 		u16 refcheck;
 
 		env = cl_env_get(&refcheck);
-		if (IS_ERR(env))
-			return PTR_ERR(env);
+		if (IS_ERR(env)) {
+			rc = PTR_ERR(env);
+			goto out;
+		}
 
 		rc = cl_object_layout_get(env, obj, &cl);
 		if (rc >= 0 && cl.cl_is_composite)
@@ -2559,28 +2576,26 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 
 		cl_env_put(env, &refcheck);
 		if (rc < 0)
-			return rc;
+			goto out;
 	}
 
 	rc = cl_get_grouplock(ll_i2info(inode)->lli_clob,
 			      arg, (file->f_flags & O_NONBLOCK), &grouplock);
-	if (rc)
-		return rc;
 
-	write_lock(&lli->lli_lock);
-	if (fd->fd_flags & LL_FILE_GROUP_LOCKED) {
-		write_unlock(&lli->lli_lock);
-		CERROR("another thread just won the race\n");
-		cl_put_grouplock(&grouplock);
-		return -EINVAL;
-	}
+	if (rc)
+		goto out;
 
 	fd->fd_flags |= LL_FILE_GROUP_LOCKED;
 	fd->fd_grouplock = grouplock;
-	write_unlock(&lli->lli_lock);
+	if (lli->lli_group_users == 0)
+		lli->lli_group_gid = grouplock.lg_gid;
+	lli->lli_group_users++;
 
 	CDEBUG(D_INFO, "group lock %lu obtained\n", arg);
-	return 0;
+out:
+	mutex_unlock(&lli->lli_group_mutex);
+
+	return rc;
 }
 
 static int ll_put_grouplock(struct inode *inode, struct file *file,
@@ -2589,31 +2604,40 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_file_data *fd = file->private_data;
 	struct ll_grouplock grouplock;
+	int rc;
 
-	write_lock(&lli->lli_lock);
+	mutex_lock(&lli->lli_group_mutex);
 	if (!(fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
-		write_unlock(&lli->lli_lock);
 		CWARN("no group lock held\n");
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
-
 	LASSERT(fd->fd_grouplock.lg_lock);
 
 	if (fd->fd_grouplock.lg_gid != arg) {
 		CWARN("group lock %lu doesn't match current id %lu\n",
 		      arg, fd->fd_grouplock.lg_gid);
-		write_unlock(&lli->lli_lock);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
 	grouplock = fd->fd_grouplock;
 	memset(&fd->fd_grouplock, 0, sizeof(fd->fd_grouplock));
 	fd->fd_flags &= ~LL_FILE_GROUP_LOCKED;
-	write_unlock(&lli->lli_lock);
 
 	cl_put_grouplock(&grouplock);
+
+	lli->lli_group_users--;
+	if (lli->lli_group_users == 0) {
+		lli->lli_group_gid = 0;
+		wake_up_var(&lli->lli_group_users);
+	}
 	CDEBUG(D_INFO, "group lock %lu released\n", arg);
-	return 0;
+	rc = 0;
+out:
+	mutex_unlock(&lli->lli_group_mutex);
+
+	return rc;
 }
 
 /**
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d245dd8..998eed8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -253,6 +253,9 @@ struct ll_inode_info {
 			u64				lli_pcc_generation;
 			enum pcc_dataset_flags		lli_pcc_dsflags;
 			struct pcc_inode		*lli_pcc_inode;
+			struct mutex			lli_group_mutex;
+			u64				lli_group_users;
+			unsigned long			lli_group_gid;
 
 			u64				lli_attr_valid;
 			u64				lli_lazysize;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 3dc0030..176e61b5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1194,6 +1194,9 @@ void ll_lli_init(struct ll_inode_info *lli)
 		lli->lli_pcc_inode = NULL;
 		lli->lli_pcc_dsflags = PCC_DATASET_INVALID;
 		lli->lli_pcc_generation = 0;
+		mutex_init(&lli->lli_group_mutex);
+		lli->lli_group_users = 0;
+		lli->lli_group_gid = 0;
 	}
 	mutex_init(&lli->lli_layout_mutex);
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 978fee3..e0f5b45 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -330,7 +330,6 @@ static int mdc_dlm_canceling(const struct lu_env *env,
 	 */
 	if (obj) {
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
-		void *data;
 
 		/* Destroy pages covered by the extent of the DLM lock */
 		result = mdc_lock_flush(env, cl2osc(obj), cl_index(obj, 0),
@@ -340,17 +339,12 @@ static int mdc_dlm_canceling(const struct lu_env *env,
 		 */
 		/* losing a lock, update kms */
 		lock_res_and_lock(dlmlock);
-		data = dlmlock->l_ast_data;
 		dlmlock->l_ast_data = NULL;
 		cl_object_attr_lock(obj);
 		attr->cat_kms = 0;
 		cl_object_attr_update(env, obj, attr, CAT_KMS);
 		cl_object_attr_unlock(obj);
 		unlock_res_and_lock(dlmlock);
-
-		/* Skip dec in case mdc_object_ast_clear() did it */
-		if (data && dlmlock->l_req_mode == LCK_GROUP)
-			osc_grouplock_dec(cl2osc(obj), dlmlock);
 		cl_object_put(env, obj);
 	}
 	return result;
@@ -457,7 +451,7 @@ void mdc_lock_lvb_update(const struct lu_env *env, struct osc_object *osc,
 }
 
 static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
-			     struct lustre_handle *lockh, int errcode)
+			     struct lustre_handle *lockh)
 {
 	struct osc_object *osc = cl2osc(oscl->ols_cl.cls_obj);
 	struct ldlm_lock *dlmlock;
@@ -510,9 +504,6 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 	LASSERT(oscl->ols_state != OLS_GRANTED);
 	oscl->ols_state = OLS_GRANTED;
-
-	if (errcode != ELDLM_LOCK_MATCHED && dlmlock->l_req_mode == LCK_GROUP)
-		osc_grouplock_inc_locked(osc, dlmlock);
 }
 
 /**
@@ -544,7 +535,7 @@ static int mdc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 
 	CDEBUG(D_INODE, "rc %d, err %d\n", rc, errcode);
 	if (rc == 0)
-		mdc_lock_granted(env, oscl, lockh, errcode);
+		mdc_lock_granted(env, oscl, lockh);
 
 	/* Error handling, some errors are tolerable. */
 	if (oscl->ols_glimpse && rc == -ENAVAIL) {
@@ -706,7 +697,8 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	struct ldlm_intent *lit;
 	enum ldlm_mode mode;
 	bool glimpse = *flags & LDLM_FL_HAS_INTENT;
-	u64 match_flags = *flags;
+	u64 search_flags = *flags;
+	u64 match_flags = 0;
 	LIST_HEAD(cancels);
 	int rc, count;
 	int lvb_size;
@@ -716,11 +708,14 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
 	if (einfo->ei_mode == LCK_PR)
 		mode |= LCK_PW;
 
-	match_flags |= LDLM_FL_LVB_READY;
+	search_flags |= LDLM_FL_LVB_READY;
 	if (glimpse)
-		match_flags |= LDLM_FL_BLOCK_GRANTED;
-	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
-			       einfo->ei_type, policy, mode, &lockh);
+		search_flags |= LDLM_FL_BLOCK_GRANTED;
+	if (mode == LCK_GROUP)
+		match_flags = LDLM_MATCH_GROUP;
+	mode = ldlm_lock_match_with_skip(obd->obd_namespace, search_flags, 0,
+					 res_id, einfo->ei_type, policy, mode,
+					 &lockh, match_flags);
 	if (mode) {
 		struct ldlm_lock *matched;
 
@@ -833,9 +828,9 @@ int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
  *
  * This function does not wait for the network communication to complete.
  */
-static int __mdc_lock_enqueue(const struct lu_env *env,
-			      const struct cl_lock_slice *slice,
-			      struct cl_io *unused, struct cl_sync_io *anchor)
+static int mdc_lock_enqueue(const struct lu_env *env,
+			    const struct cl_lock_slice *slice,
+			    struct cl_io *unused, struct cl_sync_io *anchor)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_io *oio = osc_env_io(env);
@@ -921,28 +916,6 @@ static int __mdc_lock_enqueue(const struct lu_env *env,
 	return result;
 }
 
-static int mdc_lock_enqueue(const struct lu_env *env,
-			    const struct cl_lock_slice *slice,
-			    struct cl_io *unused, struct cl_sync_io *anchor)
-{
-	struct osc_object *obj = cl2osc(slice->cls_obj);
-	struct osc_lock	*oscl = cl2osc_lock(slice);
-	struct lustre_handle lh = { 0 };
-	int rc;
-
-	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP) {
-		rc = osc_grouplock_enqueue_init(env, obj, oscl, &lh);
-		if (rc < 0)
-			return rc;
-	}
-
-	rc = __mdc_lock_enqueue(env, slice, unused, anchor);
-
-	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP)
-		osc_grouplock_enqueue_fini(env, obj, oscl, &lh);
-	return rc;
-}
-
 static const struct cl_lock_operations mdc_lock_lockless_ops = {
 	.clo_fini	= osc_lock_fini,
 	.clo_enqueue	= mdc_lock_enqueue,
@@ -1468,9 +1441,6 @@ static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
 		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
 		cl_object_attr_unlock(&osc->oo_cl);
 		ldlm_clear_lvb_cached(lock);
-
-		if (lock->l_req_mode == LCK_GROUP)
-			osc_grouplock_dec(osc, lock);
 	}
 	return LDLM_ITER_CONTINUE;
 }
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index a3e72a6..3b22688 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -198,7 +198,7 @@ void osc_lock_lvb_update(const struct lu_env *env,
 }
 
 static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
-			     struct lustre_handle *lockh, int errcode)
+			     struct lustre_handle *lockh)
 {
 	struct osc_object *osc = cl2osc(oscl->ols_cl.cls_obj);
 	struct ldlm_lock *dlmlock;
@@ -254,126 +254,7 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 
 	LASSERT(oscl->ols_state != OLS_GRANTED);
 	oscl->ols_state = OLS_GRANTED;
-
-	if (errcode != ELDLM_LOCK_MATCHED && dlmlock->l_req_mode == LCK_GROUP)
-		osc_grouplock_inc_locked(osc, dlmlock);
-}
-
-void osc_grouplock_inc_locked(struct osc_object *osc, struct ldlm_lock *lock)
-{
-	LASSERT(lock->l_req_mode == LCK_GROUP);
-
-	if (osc->oo_group_users == 0)
-		osc->oo_group_gid = lock->l_policy_data.l_extent.gid;
-	osc->oo_group_users++;
-
-	LDLM_DEBUG(lock, "users %llu gid %llu\n",
-		   osc->oo_group_users,
-		   lock->l_policy_data.l_extent.gid);
-}
-EXPORT_SYMBOL(osc_grouplock_inc_locked);
-
-void osc_grouplock_dec(struct osc_object *osc, struct ldlm_lock *lock)
-{
-	LASSERT(lock->l_req_mode == LCK_GROUP);
-
-	mutex_lock(&osc->oo_group_mutex);
-
-	LASSERT(osc->oo_group_users > 0);
-	osc->oo_group_users--;
-	if (osc->oo_group_users == 0) {
-		osc->oo_group_gid = 0;
-		wake_up_all(&osc->oo_group_waitq);
-	}
-	mutex_unlock(&osc->oo_group_mutex);
-
-	LDLM_DEBUG(lock, "users %llu gid %lu\n",
-		   osc->oo_group_users, osc->oo_group_gid);
 }
-EXPORT_SYMBOL(osc_grouplock_dec);
-
-int osc_grouplock_enqueue_init(const struct lu_env *env,
-			       struct osc_object *obj,
-			       struct osc_lock *oscl,
-			       struct lustre_handle *lh)
-{
-	struct cl_lock_descr *need = &oscl->ols_cl.cls_lock->cll_descr;
-	int rc = 0;
-
-	LASSERT(need->cld_mode == CLM_GROUP);
-
-	while (true) {
-		bool check_gid = true;
-
-		if (oscl->ols_flags & LDLM_FL_BLOCK_NOWAIT) {
-			if (!mutex_trylock(&obj->oo_group_mutex))
-				return -EAGAIN;
-		} else {
-			mutex_lock(&obj->oo_group_mutex);
-		}
-
-		/**
-		 * If a grouplock of the same gid already exists, match it
-		 * here in advance. Otherwise, if that lock is being cancelled
-		 * there is a chance to get 2 grouplocks for the same file.
-		 */
-		if (obj->oo_group_users &&
-		    obj->oo_group_gid == need->cld_gid) {
-			struct osc_thread_info *info = osc_env_info(env);
-			struct ldlm_res_id *resname = &info->oti_resname;
-			union ldlm_policy_data *policy = &info->oti_policy;
-			struct cl_lock *lock = oscl->ols_cl.cls_lock;
-			u64 flags = oscl->ols_flags | LDLM_FL_BLOCK_GRANTED;
-			struct ldlm_namespace *ns;
-			enum ldlm_mode mode;
-
-			ns = osc_export(obj)->exp_obd->obd_namespace;
-			ostid_build_res_name(&obj->oo_oinfo->loi_oi, resname);
-			osc_lock_build_policy(env, lock, policy);
-			mode = ldlm_lock_match(ns, flags, resname,
-					       oscl->ols_einfo.ei_type, policy,
-					       oscl->ols_einfo.ei_mode, lh);
-			if (mode)
-				oscl->ols_flags |= LDLM_FL_MATCH_LOCK;
-			else
-				check_gid = false;
-		}
-
-		/**
-		 * If a grouplock exists but cannot be matched, let it to flush
-		 * and wait just for zero users for now.
-		 */
-		if (obj->oo_group_users == 0 ||
-		    (check_gid && obj->oo_group_gid == need->cld_gid))
-			break;
-
-		mutex_unlock(&obj->oo_group_mutex);
-		if (oscl->ols_flags & LDLM_FL_BLOCK_NOWAIT)
-			return -EAGAIN;
-
-		rc = l_wait_event_abortable(obj->oo_group_waitq,
-					    !obj->oo_group_users);
-		if (rc)
-			return rc;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(osc_grouplock_enqueue_init);
-
-void osc_grouplock_enqueue_fini(const struct lu_env *env,
-				struct osc_object *obj,
-				struct osc_lock *oscl,
-				struct lustre_handle *lh)
-{
-	LASSERT(oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP);
-
-	/* If a user was added on enqueue_init, decref it */
-	if (lustre_handle_is_used(lh))
-		ldlm_lock_decref(lh, oscl->ols_einfo.ei_mode);
-	mutex_unlock(&obj->oo_group_mutex);
-}
-EXPORT_SYMBOL(osc_grouplock_enqueue_fini);
 
 /**
  * Lock upcall function that is executed either when a reply to ENQUEUE rpc is
@@ -403,7 +284,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 	}
 
 	if (rc == 0)
-		osc_lock_granted(env, oscl, lockh, errcode);
+		osc_lock_granted(env, oscl, lockh);
 
 	/* Error handling, some errors are tolerable. */
 	if (oscl->ols_glimpse && rc == -ENAVAIL) {
@@ -540,7 +421,6 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 		struct ldlm_extent *extent = &dlmlock->l_policy_data.l_extent;
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 		u64 old_kms;
-		void *data;
 
 		/* Destroy pages covered by the extent of the DLM lock */
 		result = osc_lock_flush(cl2osc(obj),
@@ -553,7 +433,6 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 		/* clearing l_ast_data after flushing data,
 		 * to let glimpse ast find the lock and the object
 		 */
-		data = dlmlock->l_ast_data;
 		dlmlock->l_ast_data = NULL;
 		cl_object_attr_lock(obj);
 		/* Must get the value under the lock to avoid race. */
@@ -567,9 +446,6 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 		cl_object_attr_unlock(obj);
 		unlock_res_and_lock(dlmlock);
 
-		/* Skip dec in case osc_object_ast_clear() did it */
-		if (data && dlmlock->l_req_mode == LCK_GROUP)
-			osc_grouplock_dec(cl2osc(obj), dlmlock);
 		cl_object_put(env, obj);
 	}
 	return result;
@@ -1055,9 +931,9 @@ int osc_lock_enqueue_wait(const struct lu_env *env, struct osc_object *obj,
  *
  * This function does not wait for the network communication to complete.
  */
-static int __osc_lock_enqueue(const struct lu_env *env,
-			      const struct cl_lock_slice *slice,
-			      struct cl_io *unused, struct cl_sync_io *anchor)
+static int osc_lock_enqueue(const struct lu_env *env,
+			    const struct cl_lock_slice *slice,
+			    struct cl_io *unused, struct cl_sync_io *anchor)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_io *oio = osc_env_io(env);
@@ -1177,29 +1053,6 @@ static int __osc_lock_enqueue(const struct lu_env *env,
 	return result;
 }
 
-static int osc_lock_enqueue(const struct lu_env *env,
-			    const struct cl_lock_slice *slice,
-			    struct cl_io *unused, struct cl_sync_io *anchor)
-{
-	struct osc_object *obj = cl2osc(slice->cls_obj);
-	struct osc_lock	*oscl = cl2osc_lock(slice);
-	struct lustre_handle lh = { 0 };
-	int rc;
-
-	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP) {
-		rc = osc_grouplock_enqueue_init(env, obj, oscl, &lh);
-		if (rc < 0)
-			return rc;
-	}
-
-	rc = __osc_lock_enqueue(env, slice, unused, anchor);
-
-	if (oscl->ols_cl.cls_lock->cll_descr.cld_mode == CLM_GROUP)
-		osc_grouplock_enqueue_fini(env, obj, oscl, &lh);
-
-	return rc;
-}
-
 /**
  * Breaks a link between osc_lock and dlm_lock.
  */
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index c3667a3..efb0533 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -74,10 +74,6 @@ int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 
 	atomic_set(&osc->oo_nr_ios, 0);
 	init_waitqueue_head(&osc->oo_io_waitq);
-	init_waitqueue_head(&osc->oo_group_waitq);
-	mutex_init(&osc->oo_group_mutex);
-	osc->oo_group_users = 0;
-	osc->oo_group_gid = 0;
 
 	osc->oo_root.rb_node = NULL;
 	INIT_LIST_HEAD(&osc->oo_hp_exts);
@@ -117,7 +113,6 @@ void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 	LASSERT(atomic_read(&osc->oo_nr_writes) == 0);
 	LASSERT(list_empty(&osc->oo_ol_list));
 	LASSERT(!atomic_read(&osc->oo_nr_ios));
-	LASSERT(!osc->oo_group_users);
 
 	lu_object_fini(obj);
 	/* osc doen't contain an lu_object_header, so we don't need call_rcu */
@@ -230,17 +225,6 @@ static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
 		cl_object_attr_unlock(&osc->oo_cl);
 		ldlm_clear_lvb_cached(lock);
-
-		/**
-		 * Object is being destroyed and gets unlinked from the lock,
-		 * IO is finished and no cached data is left under the lock. As
-		 * grouplock is immediately marked CBPENDING it is not reused.
-		 * It will also be not possible to flush data later due to a
-		 * NULL l_ast_data - enough conditions to let new grouplocks to
-		 * be enqueued even if the lock still exists on client.
-		 */
-		if (lock->l_req_mode == LCK_GROUP)
-			osc_grouplock_dec(osc, lock);
 	}
 	return LDLM_ITER_CONTINUE;
 }
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 7577fad..5a3f418 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3009,7 +3009,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	struct lustre_handle lockh = { 0 };
 	struct ptlrpc_request *req = NULL;
 	int intent = *flags & LDLM_FL_HAS_INTENT;
-	u64 match_flags = *flags;
+	u64 search_flags = *flags;
+	u64 match_flags = 0;
 	enum ldlm_mode mode;
 	int rc;
 
@@ -3040,11 +3041,14 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 	 * because they will not actually use the lock.
 	 */
 	if (!speculative)
-		match_flags |= LDLM_FL_LVB_READY;
+		search_flags |= LDLM_FL_LVB_READY;
 	if (intent != 0)
-		match_flags |= LDLM_FL_BLOCK_GRANTED;
-	mode = ldlm_lock_match(obd->obd_namespace, match_flags, res_id,
-			       einfo->ei_type, policy, mode, &lockh);
+		search_flags |= LDLM_FL_BLOCK_GRANTED;
+	if (mode == LCK_GROUP)
+		match_flags = LDLM_MATCH_GROUP;
+	mode = ldlm_lock_match_with_skip(obd->obd_namespace, search_flags, 0,
+					 res_id, einfo->ei_type, policy, mode,
+					 &lockh, match_flags);
 	if (mode) {
 		struct ldlm_lock *matched;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
