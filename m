From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:42 -0400
Subject: [lustre-devel] [PATCH 10/43] staging/lustre/osc: add weight
	function for DLM lock
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Use weigh_ast to decide if a lock covers any pages.
In recovery, weigh_ast will be used to decide if a DLM read lock
covers any locked pages, or it will be canceled instead being
recovered.

The problem with the original implementation is that it attached
each osc_page to an osc_lock also changed lock state to add every
pages for readahead.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7894
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   9 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  20 ----
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   3 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 113 +++++++++++++++------
 drivers/staging/lustre/lustre/osc/osc_page.c       |  78 +-------------
 drivers/staging/lustre/lustre/osc/osc_request.c    |   5 +-
 6 files changed, 89 insertions(+), 139 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c7904a9..d5968e0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1139,10 +1139,10 @@ static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
 	ldlm_policy_res_t result = LDLM_POLICY_CANCEL_LOCK;
 	ldlm_cancel_for_recovery cb = ns->ns_cancel_for_recovery;
 
-	lock_res_and_lock(lock);
-
 	/* don't check added & count since we want to process all locks
-	 * from unused list
+	 * from unused list.
+	 * It's fine to not take lock to access lock->l_resource since
+	 * the lock has already been granted so it won't change.
 	 */
 	switch (lock->l_resource->lr_type) {
 	case LDLM_EXTENT:
@@ -1151,11 +1151,12 @@ static ldlm_policy_res_t ldlm_cancel_no_wait_policy(struct ldlm_namespace *ns,
 			break;
 	default:
 		result = LDLM_POLICY_SKIP_LOCK;
+		lock_res_and_lock(lock);
 		lock->l_flags |= LDLM_FL_SKIPPED;
+		unlock_res_and_lock(lock);
 		break;
 	}
 
-	unlock_res_and_lock(lock);
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 0e06bed..cf87043 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -275,16 +275,6 @@ struct osc_lock {
 	enum osc_lock_state      ols_state;
 
 	/**
-	 * How many pages are using this lock for io, currently only used by
-	 * read-ahead. If non-zero, the underlying dlm lock won't be cancelled
-	 * during recovery to avoid deadlock. see bz16774.
-	 *
-	 * \see osc_page::ops_lock
-	 * \see osc_page_addref_lock(), osc_page_putref_lock()
-	 */
-	atomic_t	     ols_pageref;
-
-	/**
 	 * true, if ldlm_lock_addref() was called against
 	 * osc_lock::ols_lock. This is used for sanity checking.
 	 *
@@ -400,16 +390,6 @@ struct osc_page {
 	 * Submit time - the time when the page is starting RPC. For debugging.
 	 */
 	unsigned long	    ops_submit_time;
-
-	/**
-	 * A lock of which we hold a reference covers this page. Only used by
-	 * read-ahead: for a readahead page, we hold it's covering lock to
-	 * prevent it from being canceled during recovery.
-	 *
-	 * \see osc_lock::ols_pageref
-	 * \see osc_page_addref_lock(), osc_page_putref_lock().
-	 */
-	struct cl_lock       *ops_lock;
 };
 
 extern struct kmem_cache *osc_lock_kmem;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 906225c..b7fb01a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -141,6 +141,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 int osc_lru_reclaim(struct client_obd *cli);
 
 extern spinlock_t osc_ast_guard;
+unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
 
@@ -181,8 +182,6 @@ static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
 	return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
 }
 
-int osc_dlm_lock_pageref(struct ldlm_lock *dlm);
-
 extern struct kmem_cache *osc_quota_kmem;
 struct osc_quota_info {
 	/** linkage for quota hash table */
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 3a8a6d1..978b6ea 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -51,8 +51,6 @@
  *  @{
  */
 
-#define _PAGEREF_MAGIC  (-10000000)
-
 /*****************************************************************************
  *
  * Type conversions.
@@ -248,8 +246,6 @@ static void osc_lock_fini(const struct lu_env *env,
 	 */
 	osc_lock_unhold(ols);
 	LASSERT(!ols->ols_lock);
-	LASSERT(atomic_read(&ols->ols_pageref) == 0 ||
-		atomic_read(&ols->ols_pageref) == _PAGEREF_MAGIC);
 
 	kmem_cache_free(osc_lock_kmem, ols);
 }
@@ -895,11 +891,88 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 	return result;
 }
 
-static unsigned long osc_lock_weigh(const struct lu_env *env,
-				    const struct cl_lock_slice *slice)
+static int weigh_cb(const struct lu_env *env, struct cl_io *io,
+		    struct osc_page *ops, void *cbdata)
 {
-	/* TODO: check how many pages are covered by this lock */
-	return cl2osc(slice->cls_obj)->oo_npages;
+	struct cl_page *page = ops->ops_cl.cpl_page;
+
+	if (cl_page_is_vmlocked(env, page)) {
+		(*(unsigned long *)cbdata)++;
+		return CLP_GANG_ABORT;
+	}
+
+	return CLP_GANG_OKAY;
+}
+
+static unsigned long osc_lock_weight(const struct lu_env *env,
+				     const struct osc_lock *ols)
+{
+	struct cl_io *io = &osc_env_info(env)->oti_io;
+	struct cl_lock_descr *descr = &ols->ols_cl.cls_lock->cll_descr;
+	struct cl_object *obj = ols->ols_cl.cls_obj;
+	unsigned long npages = 0;
+	int result;
+
+	io->ci_obj = cl_object_top(obj);
+	io->ci_ignore_layout = 1;
+	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
+	if (result != 0)
+		return result;
+
+	do {
+		result = osc_page_gang_lookup(env, io, cl2osc(obj),
+					      descr->cld_start, descr->cld_end,
+					      weigh_cb, (void *)&npages);
+		if (result == CLP_GANG_ABORT)
+			break;
+		if (result == CLP_GANG_RESCHED)
+			cond_resched();
+	} while (result != CLP_GANG_OKAY);
+	cl_io_fini(env, io);
+
+	return npages;
+}
+
+/**
+ * Get the weight of dlm lock for early cancellation.
+ */
+unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
+{
+	struct cl_env_nest       nest;
+	struct lu_env           *env;
+	struct osc_lock         *lock;
+	unsigned long            weight;
+
+	might_sleep();
+	/*
+	 * osc_ldlm_weigh_ast has a complex context since it might be called
+	 * because of lock canceling, or from user's input. We have to make
+	 * a new environment for it. Probably it is implementation safe to use
+	 * the upper context because cl_lock_put don't modify environment
+	 * variables. But just in case ..
+	 */
+	env = cl_env_nested_get(&nest);
+	if (IS_ERR(env))
+		/* Mostly because lack of memory, do not eliminate this lock */
+		return 1;
+
+	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT);
+	lock = osc_ast_data_get(dlmlock);
+	if (!lock) {
+		/* cl_lock was destroyed because of memory pressure.
+		 * It is much reasonable to assign this type of lock
+		 * a lower cost.
+		 */
+		weight = 0;
+		goto out;
+	}
+
+	weight = osc_lock_weight(env, lock);
+	osc_ast_data_put(env, lock);
+
+out:
+	cl_env_nested_put(&nest, env);
+	return weight;
 }
 
 static void osc_lock_build_einfo(const struct lu_env *env,
@@ -1468,7 +1541,6 @@ static const struct cl_lock_operations osc_lock_ops = {
 	.clo_delete  = osc_lock_delete,
 	.clo_state   = osc_lock_state,
 	.clo_cancel  = osc_lock_cancel,
-	.clo_weigh   = osc_lock_weigh,
 	.clo_print   = osc_lock_print,
 	.clo_fits_into = osc_lock_fits_into,
 };
@@ -1570,7 +1642,6 @@ int osc_lock_init(const struct lu_env *env,
 		__u32 enqflags = lock->cll_descr.cld_enq_flags;
 
 		osc_lock_build_einfo(env, lock, clk, &clk->ols_einfo);
-		atomic_set(&clk->ols_pageref, 0);
 		clk->ols_state = OLS_NEW;
 
 		clk->ols_flags = osc_enq2ldlm_flags(enqflags);
@@ -1597,26 +1668,4 @@ int osc_lock_init(const struct lu_env *env,
 	return result;
 }
 
-int osc_dlm_lock_pageref(struct ldlm_lock *dlm)
-{
-	struct osc_lock *olock;
-	int rc = 0;
-
-	spin_lock(&osc_ast_guard);
-	olock = dlm->l_ast_data;
-	/*
-	 * there's a very rare race with osc_page_addref_lock(), but that
-	 * doesn't matter because in the worst case we don't cancel a lock
-	 * which we actually can, that's no harm.
-	 */
-	if (olock &&
-	    atomic_add_return(_PAGEREF_MAGIC,
-			      &olock->ols_pageref) != _PAGEREF_MAGIC) {
-		atomic_sub(_PAGEREF_MAGIC, &olock->ols_pageref);
-		rc = 1;
-	}
-	spin_unlock(&osc_ast_guard);
-	return rc;
-}
-
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index eff3b4b..8dc62fa 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -67,10 +67,6 @@ static int osc_page_protected(const struct lu_env *env,
 static void osc_page_fini(const struct lu_env *env,
 			  struct cl_page_slice *slice)
 {
-	struct osc_page *opg = cl2osc_page(slice);
-
-	CDEBUG(D_TRACE, "%p\n", opg);
-	LASSERT(!opg->ops_lock);
 }
 
 static void osc_page_transfer_get(struct osc_page *opg, const char *label)
@@ -139,42 +135,6 @@ void osc_index2policy(ldlm_policy_data_t *policy, const struct cl_object *obj,
 	policy->l_extent.end = cl_offset(obj, end + 1) - 1;
 }
 
-static int osc_page_addref_lock(const struct lu_env *env,
-				struct osc_page *opg,
-				struct cl_lock *lock)
-{
-	struct osc_lock *olock;
-	int rc;
-
-	LASSERT(!opg->ops_lock);
-
-	olock = osc_lock_at(lock);
-	if (atomic_inc_return(&olock->ols_pageref) <= 0) {
-		atomic_dec(&olock->ols_pageref);
-		rc = -ENODATA;
-	} else {
-		cl_lock_get(lock);
-		opg->ops_lock = lock;
-		rc = 0;
-	}
-	return rc;
-}
-
-static void osc_page_putref_lock(const struct lu_env *env,
-				 struct osc_page *opg)
-{
-	struct cl_lock *lock = opg->ops_lock;
-	struct osc_lock *olock;
-
-	LASSERT(lock);
-	olock = osc_lock_at(lock);
-
-	atomic_dec(&olock->ols_pageref);
-	opg->ops_lock = NULL;
-
-	cl_lock_put(env, lock);
-}
-
 static int osc_page_is_under_lock(const struct lu_env *env,
 				  const struct cl_page_slice *slice,
 				  struct cl_io *unused)
@@ -185,39 +145,12 @@ static int osc_page_is_under_lock(const struct lu_env *env,
 	lock = cl_lock_at_page(env, slice->cpl_obj, slice->cpl_page,
 			       NULL, 1, 0);
 	if (lock) {
-		if (osc_page_addref_lock(env, cl2osc_page(slice), lock) == 0)
-			result = -EBUSY;
 		cl_lock_put(env, lock);
+		result = -EBUSY;
 	}
 	return result;
 }
 
-static void osc_page_disown(const struct lu_env *env,
-			    const struct cl_page_slice *slice,
-			    struct cl_io *io)
-{
-	struct osc_page *opg = cl2osc_page(slice);
-
-	if (unlikely(opg->ops_lock))
-		osc_page_putref_lock(env, opg);
-}
-
-static void osc_page_completion_read(const struct lu_env *env,
-				     const struct cl_page_slice *slice,
-				     int ioret)
-{
-	struct osc_page *opg = cl2osc_page(slice);
-
-	if (likely(opg->ops_lock))
-		osc_page_putref_lock(env, opg);
-}
-
-static void osc_page_completion_write(const struct lu_env *env,
-				      const struct cl_page_slice *slice,
-				      int ioret)
-{
-}
-
 static const char *osc_list(struct list_head *head)
 {
 	return list_empty(head) ? "-" : "+";
@@ -366,15 +299,6 @@ static const struct cl_page_operations osc_page_ops = {
 	.cpo_print	 = osc_page_print,
 	.cpo_delete	= osc_page_delete,
 	.cpo_is_under_lock = osc_page_is_under_lock,
-	.cpo_disown	= osc_page_disown,
-	.io = {
-		[CRT_READ] = {
-			.cpo_completion = osc_page_completion_read
-		},
-		[CRT_WRITE] = {
-			.cpo_completion = osc_page_completion_write
-		}
-	},
 	.cpo_clip	   = osc_page_clip,
 	.cpo_cancel	 = osc_page_cancel,
 	.cpo_flush	  = osc_page_flush
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 1ff497f..1e378e6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -3131,8 +3131,6 @@ static int osc_import_event(struct obd_device *obd,
  */
 static int osc_cancel_for_recovery(struct ldlm_lock *lock)
 {
-	check_res_locked(lock->l_resource);
-
 	/*
 	 * Cancel all unused extent lock in granted mode LCK_PR or LCK_CR.
 	 *
@@ -3141,8 +3139,7 @@ static int osc_cancel_for_recovery(struct ldlm_lock *lock)
 	 */
 	if (lock->l_resource->lr_type == LDLM_EXTENT &&
 	    (lock->l_granted_mode == LCK_PR ||
-	     lock->l_granted_mode == LCK_CR) &&
-	    (osc_dlm_lock_pageref(lock) == 0))
+	     lock->l_granted_mode == LCK_CR) && osc_ldlm_weigh_ast(lock) == 0)
 		return 1;
 
 	return 0;
-- 
2.1.0
