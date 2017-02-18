From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:07 -0500
Subject: [lustre-devel] [PATCH 06/14] staging: lustre: osc: further LRU OSC
	cleanup after eviction
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Define osc_lru_reserve() and osc_lru_unreserve() to reserve LRU
slots in osc_io_write_iter_init() and unreserve them in fini();

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6271
Reviewed-on: http://review.whamcloud.com/16456
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  4 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  3 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         | 48 +++++---------
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 46 ++++++++------
 drivers/staging/lustre/lustre/osc/osc_object.c     |  8 ++-
 drivers/staging/lustre/lustre/osc/osc_page.c       | 73 +++++++++++++++++++---
 6 files changed, 118 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index c09ab97d..270212f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -62,7 +62,9 @@ struct osc_io {
 	/** super class */
 	struct cl_io_slice oi_cl;
 	/** true if this io is lockless. */
-	unsigned int		oi_lockless;
+	unsigned int		oi_lockless:1,
+	/** true if this io is counted as active IO */
+				oi_is_active:1;
 	/** how many LRU pages are reserved for this IO */
 	unsigned long		oi_lru_reserved;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 8abd83f..845e795 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -133,7 +133,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
 long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		    long target, bool force);
-long osc_lru_reclaim(struct client_obd *cli, unsigned long npages);
+unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages);
+void osc_lru_unreserve(struct client_obd *cli, unsigned long npages);
 
 unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 0b4cc42..f991bee 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -354,7 +354,10 @@ static int osc_io_iter_init(const struct lu_env *env,
 
 	spin_lock(&imp->imp_lock);
 	if (likely(!imp->imp_invalid)) {
+		struct osc_io *oio = osc_env_io(env);
+
 		atomic_inc(&osc->oo_nr_ios);
+		oio->oi_is_active = 1;
 		rc = 0;
 	}
 	spin_unlock(&imp->imp_lock);
@@ -368,10 +371,7 @@ static int osc_io_write_iter_init(const struct lu_env *env,
 	struct cl_io *io = ios->cis_io;
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_object *osc = cl2osc(ios->cis_obj);
-	struct client_obd *cli = osc_cli(osc);
-	unsigned long c;
 	unsigned long npages;
-	unsigned long max_pages;
 
 	if (cl_io_is_append(io))
 		return osc_io_iter_init(env, ios);
@@ -380,31 +380,7 @@ static int osc_io_write_iter_init(const struct lu_env *env,
 	if (io->u.ci_rw.crw_pos & ~PAGE_MASK)
 		++npages;
 
-	max_pages = cli->cl_max_pages_per_rpc * cli->cl_max_rpcs_in_flight;
-	if (npages > max_pages)
-		npages = max_pages;
-
-	c = atomic_long_read(cli->cl_lru_left);
-	if (c < npages && osc_lru_reclaim(cli, npages) > 0)
-		c = atomic_long_read(cli->cl_lru_left);
-	while (c >= npages) {
-		if (c == atomic_long_cmpxchg(cli->cl_lru_left, c, c - npages)) {
-			oio->oi_lru_reserved = npages;
-			break;
-		}
-		c = atomic_long_read(cli->cl_lru_left);
-	}
-	if (atomic_long_read(cli->cl_lru_left) < max_pages) {
-		/*
-		 * If there aren't enough pages in the per-OSC LRU then
-		 * wake up the LRU thread to try and clear out space, so
-		 * we don't block if pages are being dirtied quickly.
-		 */
-		CDEBUG(D_CACHE, "%s: queue LRU, left: %lu/%ld.\n",
-		       cli_name(cli), atomic_long_read(cli->cl_lru_left),
-		       max_pages);
-		(void)ptlrpcd_queue_work(cli->cl_lru_work);
-	}
+	oio->oi_lru_reserved = osc_lru_reserve(osc_cli(osc), npages);
 
 	return osc_io_iter_init(env, ios);
 }
@@ -412,11 +388,16 @@ static int osc_io_write_iter_init(const struct lu_env *env,
 static void osc_io_iter_fini(const struct lu_env *env,
 			     const struct cl_io_slice *ios)
 {
-	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct osc_io *oio = osc_env_io(env);
 
-	LASSERT(atomic_read(&osc->oo_nr_ios) > 0);
-	if (atomic_dec_and_test(&osc->oo_nr_ios))
-		wake_up_all(&osc->oo_io_waitq);
+	if (oio->oi_is_active) {
+		struct osc_object *osc = cl2osc(ios->cis_obj);
+
+		oio->oi_is_active = 0;
+		LASSERT(atomic_read(&osc->oo_nr_ios) > 0);
+		if (atomic_dec_and_test(&osc->oo_nr_ios))
+			wake_up_all(&osc->oo_io_waitq);
+	}
 }
 
 static void osc_io_write_iter_fini(const struct lu_env *env,
@@ -424,10 +405,9 @@ static void osc_io_write_iter_fini(const struct lu_env *env,
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_object *osc = cl2osc(ios->cis_obj);
-	struct client_obd *cli = osc_cli(osc);
 
 	if (oio->oi_lru_reserved > 0) {
-		atomic_long_add(oio->oi_lru_reserved, cli->cl_lru_left);
+		osc_lru_unreserve(osc_cli(osc), oio->oi_lru_reserved);
 		oio->oi_lru_reserved = 0;
 	}
 	oio->oi_write_osclock = NULL;
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index efecd92..5f7c030 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -840,13 +840,14 @@ static void osc_lock_wake_waiters(const struct lu_env *env,
 	spin_unlock(&oscl->ols_lock);
 }
 
-static void osc_lock_enqueue_wait(const struct lu_env *env,
-				  struct osc_object *obj,
-				  struct osc_lock *oscl)
+static int osc_lock_enqueue_wait(const struct lu_env *env,
+				 struct osc_object *obj,
+				 struct osc_lock *oscl)
 {
 	struct osc_lock *tmp_oscl;
 	struct cl_lock_descr *need = &oscl->ols_cl.cls_lock->cll_descr;
 	struct cl_sync_io *waiter = &osc_env_info(env)->oti_anchor;
+	int rc = 0;
 
 	spin_lock(&obj->oo_ol_spin);
 	list_add_tail(&oscl->ols_nextlock_oscobj, &obj->oo_ol_list);
@@ -883,13 +884,17 @@ static void osc_lock_enqueue_wait(const struct lu_env *env,
 		spin_unlock(&tmp_oscl->ols_lock);
 
 		spin_unlock(&obj->oo_ol_spin);
-		(void)cl_sync_io_wait(env, waiter, 0);
-
+		rc = cl_sync_io_wait(env, waiter, 0);
 		spin_lock(&obj->oo_ol_spin);
+		if (rc < 0)
+			break;
+
 		oscl->ols_owner = NULL;
 		goto restart;
 	}
 	spin_unlock(&obj->oo_ol_spin);
+
+	return rc;
 }
 
 /**
@@ -937,7 +942,9 @@ static int osc_lock_enqueue(const struct lu_env *env,
 		goto enqueue_base;
 	}
 
-	osc_lock_enqueue_wait(env, osc, oscl);
+	result = osc_lock_enqueue_wait(env, osc, oscl);
+	if (result < 0)
+		goto out;
 
 	/* we can grant lockless lock right after all conflicting locks
 	 * are canceled.
@@ -962,7 +969,6 @@ static int osc_lock_enqueue(const struct lu_env *env,
 	 * osc_lock.
 	 */
 	ostid_build_res_name(&osc->oo_oinfo->loi_oi, resname);
-	osc_lock_build_einfo(env, lock, osc, &oscl->ols_einfo);
 	osc_lock_build_policy(env, lock, policy);
 	if (oscl->ols_agl) {
 		oscl->ols_einfo.ei_cbdata = NULL;
@@ -977,18 +983,7 @@ static int osc_lock_enqueue(const struct lu_env *env,
 				  upcall, cookie,
 				  &oscl->ols_einfo, PTLRPCD_SET, async,
 				  oscl->ols_agl);
-	if (result != 0) {
-		oscl->ols_state = OLS_CANCELLED;
-		osc_lock_wake_waiters(env, osc, oscl);
-
-		/* hide error for AGL lock. */
-		if (oscl->ols_agl) {
-			cl_object_put(env, osc2cl(osc));
-			result = 0;
-		}
-		if (anchor)
-			cl_sync_io_note(env, anchor, result);
-	} else {
+	if (!result) {
 		if (osc_lock_is_lockless(oscl)) {
 			oio->oi_lockless = 1;
 		} else if (!async) {
@@ -996,6 +991,18 @@ static int osc_lock_enqueue(const struct lu_env *env,
 			LASSERT(oscl->ols_hold);
 			LASSERT(oscl->ols_dlmlock);
 		}
+	} else if (oscl->ols_agl) {
+		cl_object_put(env, osc2cl(osc));
+		result = 0;
+	}
+
+out:
+	if (result < 0) {
+		oscl->ols_state = OLS_CANCELLED;
+		osc_lock_wake_waiters(env, osc, oscl);
+
+		if (anchor)
+			cl_sync_io_note(env, anchor, result);
 	}
 	return result;
 }
@@ -1159,6 +1166,7 @@ int osc_lock_init(const struct lu_env *env,
 		oscl->ols_flags |= LDLM_FL_BLOCK_GRANTED;
 		oscl->ols_glimpse = 1;
 	}
+	osc_lock_build_einfo(env, lock, cl2osc(obj), &oscl->ols_einfo);
 
 	cl_lock_slice_add(lock, &oscl->ols_cl, obj, &osc_lock_ops);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 4f8e78b..fa621bd 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -453,9 +453,15 @@ int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc)
 
 	l_wait_event(osc->oo_io_waitq, !atomic_read(&osc->oo_nr_ios), &lwi);
 
-	/* Discard all pages of this object. */
+	/* Discard all dirty pages of this object. */
 	osc_cache_truncate_start(env, osc, 0, NULL);
 
+	/* Discard all caching pages */
+	osc_lock_discard_pages(env, osc, 0, CL_PAGE_EOF, CLM_WRITE);
+
+	/* Clear ast data of dlm lock. Do this after discarding all pages */
+	osc_object_prune(env, osc2cl(osc));
+
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index ab9d0d7..03ee340 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -42,8 +42,8 @@
 
 static void osc_lru_del(struct client_obd *cli, struct osc_page *opg);
 static void osc_lru_use(struct client_obd *cli, struct osc_page *opg);
-static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
-			   struct osc_page *opg);
+static int osc_lru_alloc(const struct lu_env *env, struct client_obd *cli,
+			 struct osc_page *opg);
 
 /** \addtogroup osc
  *  @{
@@ -273,7 +273,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 
 	/* reserve an LRU space for this page */
 	if (page->cp_type == CPT_CACHEABLE && result == 0) {
-		result = osc_lru_reserve(env, osc, opg);
+		result = osc_lru_alloc(env, osc_cli(osc), opg);
 		if (result == 0) {
 			spin_lock(&osc->oo_tree_lock);
 			result = radix_tree_insert(&osc->oo_tree, index, opg);
@@ -676,7 +676,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
  * LRU pages in batch. Therefore, the actual number is adjusted at least
  * max_pages_per_rpc.
  */
-long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
+static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 {
 	struct lu_env *env;
 	struct cl_client_cache *cache = cli->cl_cache;
@@ -749,18 +749,17 @@ long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 }
 
 /**
- * osc_lru_reserve() is called to reserve an LRU slot for a cl_page.
+ * osc_lru_alloc() is called to reserve an LRU slot for a cl_page.
  *
  * Usually the LRU slots are reserved in osc_io_iter_rw_init().
  * Only in the case that the LRU slots are in extreme shortage, it should
  * have reserved enough slots for an IO.
  */
-static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
-			   struct osc_page *opg)
+static int osc_lru_alloc(const struct lu_env *env, struct client_obd *cli,
+			 struct osc_page *opg)
 {
 	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 	struct osc_io *oio = osc_env_io(env);
-	struct client_obd *cli = osc_cli(obj);
 	int rc = 0;
 
 	if (!cli->cl_cache) /* shall not be in LRU */
@@ -801,6 +800,64 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 }
 
 /**
+ * osc_lru_reserve() is called to reserve enough LRU slots for I/O.
+ *
+ * The benefit of doing this is to reduce contention against atomic counter
+ * cl_lru_left by changing it from per-page access to per-IO access.
+ */
+unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages)
+{
+	unsigned long reserved = 0;
+	unsigned long max_pages;
+	unsigned long c;
+
+	/*
+	 * reserve a full RPC window at most to avoid that a thread accidentally
+	 * consumes too many LRU slots
+	 */
+	max_pages = cli->cl_max_pages_per_rpc * cli->cl_max_rpcs_in_flight;
+	if (npages > max_pages)
+		npages = max_pages;
+
+	c = atomic_long_read(cli->cl_lru_left);
+	if (c < npages && osc_lru_reclaim(cli, npages) > 0)
+		c = atomic_long_read(cli->cl_lru_left);
+	while (c >= npages) {
+		if (c == atomic_long_cmpxchg(cli->cl_lru_left, c, c - npages)) {
+			reserved = npages;
+			break;
+		}
+		c = atomic_long_read(cli->cl_lru_left);
+	}
+	if (atomic_long_read(cli->cl_lru_left) < max_pages) {
+		/*
+		 * If there aren't enough pages in the per-OSC LRU then
+		 * wake up the LRU thread to try and clear out space, so
+		 * we don't block if pages are being dirtied quickly.
+		 */
+		CDEBUG(D_CACHE, "%s: queue LRU, left: %lu/%ld.\n",
+		       cli_name(cli), atomic_long_read(cli->cl_lru_left),
+		       max_pages);
+		(void)ptlrpcd_queue_work(cli->cl_lru_work);
+	}
+
+	return reserved;
+}
+
+/**
+ * osc_lru_unreserve() is called to unreserve LRU slots.
+ *
+ * LRU slots reserved by osc_lru_reserve() may have entries left due to several
+ * reasons such as page already existing or I/O error. Those reserved slots
+ * should be freed by calling this function.
+ */
+void osc_lru_unreserve(struct client_obd *cli, unsigned long npages)
+{
+	atomic_long_add(npages, cli->cl_lru_left);
+	wake_up_all(&osc_lru_waitq);
+}
+
+/**
  * Atomic operations are expensive. We accumulate the accounting for the
  * same page pgdat to get better performance.
  * In practice this can work pretty good because the pages in the same RPC
-- 
1.8.3.1
