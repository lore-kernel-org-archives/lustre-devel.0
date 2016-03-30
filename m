From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 19:48:26 -0400
Subject: [lustre-devel] [PATCH v2 05/46] staging/lustre/osc: Adjustment on
	osc LRU for performance
In-Reply-To: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
References: <1459381747-2886687-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459381747-2886687-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Add and discard pages from LRU in batch.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/7890
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3321
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   5 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   2 +
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  26 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   3 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  51 ++++
 drivers/staging/lustre/lustre/osc/osc_page.c       | 301 +++++++++++----------
 drivers/staging/lustre/lustre/osc/osc_request.c    |   2 +-
 8 files changed, 235 insertions(+), 157 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 673d31e..a4401f2 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -85,10 +85,7 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 
 	si_meminfo(&si);
 	pages = si.totalram - si.totalhigh;
-	if (pages >> (20 - PAGE_CACHE_SHIFT) < 512)
-		lru_page_max = pages / 2;
-	else
-		lru_page_max = (pages / 4) * 3;
+	lru_page_max = pages / 2;
 
 	/* initialize lru data */
 	atomic_set(&sbi->ll_cache.ccc_users, 0);
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 57c43c5..3eff12c 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -223,7 +223,7 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 
 	rc = atomic_read(&cli->cl_lru_in_list) - pages_number;
 	if (rc > 0)
-		(void)osc_lru_shrink(cli, rc);
+		(void)osc_lru_shrink(cli, rc, true);
 
 	return count;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 3cfd2b0..6196c3b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -856,6 +856,8 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 
 	ext->oe_rc = rc ?: ext->oe_nr_pages;
 	EASSERT(ergo(rc == 0, ext->oe_state == OES_RPC), ext);
+
+	osc_lru_add_batch(cli, &ext->oe_pages);
 	list_for_each_entry_safe(oap, tmp, &ext->oe_pages, oap_pending_item) {
 		list_del_init(&oap->oap_rpc_item);
 		list_del_init(&oap->oap_pending_item);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index d55d04d..f516848 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -77,6 +77,8 @@ struct osc_io {
 	 */
 	struct osc_extent *oi_trunc;
 
+	int oi_lru_reserved;
+
 	struct obd_info    oi_info;
 	struct obdo	oi_oa;
 	struct osc_async_cbargs {
@@ -100,7 +102,7 @@ struct osc_session {
 	struct osc_io       os_io;
 };
 
-#define OTI_PVEC_SIZE 64
+#define OTI_PVEC_SIZE 256
 struct osc_thread_info {
 	struct ldlm_res_id      oti_resname;
 	ldlm_policy_data_t      oti_policy;
@@ -369,18 +371,15 @@ struct osc_page {
 	 * Set if the page must be transferred with OBD_BRW_SRVLOCK.
 	 */
 			      ops_srvlock:1;
-	union {
-		/**
-		 * lru page list. ops_inflight and ops_lru are exclusive so
-		 * that they can share the same data.
-		 */
-		struct list_head	      ops_lru;
-		/**
-		 * Linkage into a per-osc_object list of pages in flight. For
-		 * debugging.
-		 */
-		struct list_head	    ops_inflight;
-	};
+	/**
+	 * lru page list. See osc_lru_{del|use}() in osc_page.c for usage.
+	 */
+	struct list_head	      ops_lru;
+	/**
+	 * Linkage into a per-osc_object list of pages in flight. For
+	 * debugging.
+	 */
+	struct list_head	    ops_inflight;
 	/**
 	 * Thread that submitted this page for transfer. For debugging.
 	 */
@@ -432,6 +431,7 @@ void osc_index2policy  (ldlm_policy_data_t *policy, const struct cl_object *obj,
 int  osc_lvb_print     (const struct lu_env *env, void *cookie,
 			lu_printer_t p, const struct ost_lvb *lvb);
 
+void osc_lru_add_batch(struct client_obd *cli, struct list_head *list);
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		     enum cl_req_type crt, int brw_flags);
 int osc_cancel_async_page(const struct lu_env *env, struct osc_page *ops);
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index ea695c2..ec12962 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -130,7 +130,8 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *cfg);
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
-int osc_lru_shrink(struct client_obd *cli, int target);
+int osc_lru_shrink(struct client_obd *cli, int target, bool force);
+int osc_lru_reclaim(struct client_obd *cli);
 
 extern spinlock_t osc_ast_guard;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 6bd0a45..a0fa533 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -308,6 +308,55 @@ static int osc_io_commit_write(const struct lu_env *env,
 	return 0;
 }
 
+static int osc_io_rw_iter_init(const struct lu_env *env,
+			       const struct cl_io_slice *ios)
+{
+	struct cl_io *io = ios->cis_io;
+	struct osc_io *oio = osc_env_io(env);
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct client_obd *cli = osc_cli(osc);
+	unsigned long c;
+	unsigned int npages;
+	unsigned int max_pages;
+
+	if (cl_io_is_append(io))
+		return 0;
+
+	npages = io->u.ci_rw.crw_count >> PAGE_CACHE_SHIFT;
+	if (io->u.ci_rw.crw_pos & ~PAGE_MASK)
+		++npages;
+
+	max_pages = cli->cl_max_pages_per_rpc * cli->cl_max_rpcs_in_flight;
+	if (npages > max_pages)
+		npages = max_pages;
+
+	c = atomic_read(cli->cl_lru_left);
+	if (c < npages && osc_lru_reclaim(cli) > 0)
+		c = atomic_read(cli->cl_lru_left);
+	while (c >= npages) {
+		if (c == atomic_cmpxchg(cli->cl_lru_left, c, c - npages)) {
+			oio->oi_lru_reserved = npages;
+			break;
+		}
+		c = atomic_read(cli->cl_lru_left);
+	}
+
+	return 0;
+}
+
+static void osc_io_rw_iter_fini(const struct lu_env *env,
+				const struct cl_io_slice *ios)
+{
+	struct osc_io *oio = osc_env_io(env);
+	struct osc_object *osc = cl2osc(ios->cis_obj);
+	struct client_obd *cli = osc_cli(osc);
+
+	if (oio->oi_lru_reserved > 0) {
+		atomic_add(oio->oi_lru_reserved, cli->cl_lru_left);
+		oio->oi_lru_reserved = 0;
+	}
+}
+
 static int osc_io_fault_start(const struct lu_env *env,
 			      const struct cl_io_slice *ios)
 {
@@ -650,6 +699,8 @@ static const struct cl_io_operations osc_io_ops = {
 			.cio_fini   = osc_io_fini
 		},
 		[CIT_WRITE] = {
+			.cio_iter_init = osc_io_rw_iter_init,
+			.cio_iter_fini = osc_io_rw_iter_fini,
 			.cio_start  = osc_io_write_start,
 			.cio_end    = osc_io_end,
 			.cio_fini   = osc_io_fini
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index d720b1a..a60b783 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -42,8 +42,8 @@
 
 #include "osc_cl_internal.h"
 
-static void osc_lru_del(struct client_obd *cli, struct osc_page *opg, bool del);
-static void osc_lru_add(struct client_obd *cli, struct osc_page *opg);
+static void osc_lru_del(struct client_obd *cli, struct osc_page *opg);
+static void osc_lru_use(struct client_obd *cli, struct osc_page *opg);
 static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 			   struct osc_page *opg);
 
@@ -104,10 +104,7 @@ static void osc_page_transfer_add(const struct lu_env *env,
 {
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 
-	/* ops_lru and ops_inflight share the same field, so take it from LRU
-	 * first and then use it as inflight.
-	 */
-	osc_lru_del(osc_cli(obj), opg, false);
+	osc_lru_use(osc_cli(obj), opg);
 
 	spin_lock(&obj->oo_seatbelt);
 	list_add(&opg->ops_inflight, &obj->oo_inflight[crt]);
@@ -222,21 +219,15 @@ static void osc_page_completion_read(const struct lu_env *env,
 				     int ioret)
 {
 	struct osc_page *opg = cl2osc_page(slice);
-	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 
 	if (likely(opg->ops_lock))
 		osc_page_putref_lock(env, opg);
-	osc_lru_add(osc_cli(obj), opg);
 }
 
 static void osc_page_completion_write(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      int ioret)
 {
-	struct osc_page *opg = cl2osc_page(slice);
-	struct osc_object *obj = cl2osc(slice->cpl_obj);
-
-	osc_lru_add(osc_cli(obj), opg);
 }
 
 static int osc_page_fail(const struct lu_env *env,
@@ -334,7 +325,7 @@ static void osc_page_delete(const struct lu_env *env,
 	}
 	spin_unlock(&obj->oo_seatbelt);
 
-	osc_lru_del(osc_cli(obj), opg, true);
+	osc_lru_del(osc_cli(obj), opg);
 }
 
 static void osc_page_clip(const struct lu_env *env,
@@ -483,13 +474,12 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
  */
 
 static DECLARE_WAIT_QUEUE_HEAD(osc_lru_waitq);
-static atomic_t osc_lru_waiters = ATOMIC_INIT(0);
 /* LRU pages are freed in batch mode. OSC should at least free this
  * number of pages to avoid running out of LRU budget, and..
  */
 static const int lru_shrink_min = 2 << (20 - PAGE_CACHE_SHIFT);  /* 2M */
 /* free this number@most otherwise it will take too long time to finish. */
-static const int lru_shrink_max = 32 << (20 - PAGE_CACHE_SHIFT); /* 32M */
+static const int lru_shrink_max = 8 << (20 - PAGE_CACHE_SHIFT); /* 8M */
 
 /* Check if we can free LRU slots from this OSC. If there exists LRU waiters,
  * we should free slots aggressively. In this way, slots are freed in a steady
@@ -500,62 +490,127 @@ static const int lru_shrink_max = 32 << (20 - PAGE_CACHE_SHIFT); /* 32M */
 static int osc_cache_too_much(struct client_obd *cli)
 {
 	struct cl_client_cache *cache = cli->cl_cache;
-	int pages = atomic_read(&cli->cl_lru_in_list) >> 1;
+	int pages = atomic_read(&cli->cl_lru_in_list);
+	unsigned long budget;
 
-	if (atomic_read(&osc_lru_waiters) > 0 &&
-	    atomic_read(cli->cl_lru_left) < lru_shrink_max)
-		/* drop lru pages aggressively */
-		return min(pages, lru_shrink_max);
+	budget = cache->ccc_lru_max / atomic_read(&cache->ccc_users);
 
 	/* if it's going to run out LRU slots, we should free some, but not
 	 * too much to maintain fairness among OSCs.
 	 */
 	if (atomic_read(cli->cl_lru_left) < cache->ccc_lru_max >> 4) {
-		unsigned long tmp;
+		if (pages >= budget)
+			return lru_shrink_max;
+		else if (pages >= budget / 2)
+			return lru_shrink_min;
+	} else if (pages >= budget * 2)
+		return lru_shrink_min;
+	return 0;
+}
 
-		tmp = cache->ccc_lru_max / atomic_read(&cache->ccc_users);
-		if (pages > tmp)
-			return min(pages, lru_shrink_max);
+void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
+{
+	LIST_HEAD(lru);
+	struct osc_async_page *oap;
+	int npages = 0;
+
+	list_for_each_entry(oap, plist, oap_pending_item) {
+		struct osc_page *opg = oap2osc_page(oap);
+
+		if (!opg->ops_in_lru)
+			continue;
 
-		return pages > lru_shrink_min ? lru_shrink_min : 0;
+		++npages;
+		LASSERT(list_empty(&opg->ops_lru));
+		list_add(&opg->ops_lru, &lru);
 	}
 
-	return 0;
+	if (npages > 0) {
+		client_obd_list_lock(&cli->cl_lru_list_lock);
+		list_splice_tail(&lru, &cli->cl_lru_list);
+		atomic_sub(npages, &cli->cl_lru_busy);
+		atomic_add(npages, &cli->cl_lru_in_list);
+		client_obd_list_unlock(&cli->cl_lru_list_lock);
+
+		/* XXX: May set force to be true for better performance */
+		osc_lru_shrink(cli, osc_cache_too_much(cli), false);
+	}
 }
 
-/* Return how many pages are not discarded in @pvec. */
-static int discard_pagevec(const struct lu_env *env, struct cl_io *io,
-			   struct cl_page **pvec, int max_index)
+static void __osc_lru_del(struct client_obd *cli, struct osc_page *opg)
+{
+	LASSERT(atomic_read(&cli->cl_lru_in_list) > 0);
+	list_del_init(&opg->ops_lru);
+	atomic_dec(&cli->cl_lru_in_list);
+}
+
+/**
+ * Page is being destroyed. The page may be not in LRU list, if the transfer
+ * has never finished(error occurred).
+ */
+static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
+{
+	if (opg->ops_in_lru) {
+		client_obd_list_lock(&cli->cl_lru_list_lock);
+		if (!list_empty(&opg->ops_lru)) {
+			__osc_lru_del(cli, opg);
+		} else {
+			LASSERT(atomic_read(&cli->cl_lru_busy) > 0);
+			atomic_dec(&cli->cl_lru_busy);
+		}
+		client_obd_list_unlock(&cli->cl_lru_list_lock);
+
+		atomic_inc(cli->cl_lru_left);
+		/* this is a great place to release more LRU pages if
+		 * this osc occupies too many LRU pages and kernel is
+		 * stealing one of them.
+		 */
+		if (!memory_pressure_get())
+			osc_lru_shrink(cli, osc_cache_too_much(cli), false);
+		wake_up(&osc_lru_waitq);
+	} else {
+		LASSERT(list_empty(&opg->ops_lru));
+	}
+}
+
+/**
+ * Delete page from LRUlist for redirty.
+ */
+static void osc_lru_use(struct client_obd *cli, struct osc_page *opg)
+{
+	/* If page is being transferred for the first time,
+	 * ops_lru should be empty
+	 */
+	if (opg->ops_in_lru && !list_empty(&opg->ops_lru)) {
+		client_obd_list_lock(&cli->cl_lru_list_lock);
+		__osc_lru_del(cli, opg);
+		client_obd_list_unlock(&cli->cl_lru_list_lock);
+		atomic_inc(&cli->cl_lru_busy);
+	}
+}
+
+static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
+			    struct cl_page **pvec, int max_index)
 {
-	int count;
 	int i;
 
-	for (count = 0, i = 0; i < max_index; i++) {
+	for (i = 0; i < max_index; i++) {
 		struct cl_page *page = pvec[i];
 
-		if (cl_page_own_try(env, io, page) == 0) {
-			/* free LRU page only if nobody is using it.
-			 * This check is necessary to avoid freeing the pages
-			 * having already been removed from LRU and pinned
-			 * for IO.
-			 */
-			if (!cl_page_in_use(page)) {
-				cl_page_unmap(env, io, page);
-				cl_page_discard(env, io, page);
-				++count;
-			}
-			cl_page_disown(env, io, page);
-		}
+		LASSERT(cl_page_is_owned(page, io));
+		cl_page_unmap(env, io, page);
+		cl_page_discard(env, io, page);
+		cl_page_disown(env, io, page);
 		cl_page_put(env, page);
+
 		pvec[i] = NULL;
 	}
-	return max_index - count;
 }
 
 /**
  * Drop @target of pages from LRU@most.
  */
-int osc_lru_shrink(struct client_obd *cli, int target)
+int osc_lru_shrink(struct client_obd *cli, int target, bool force)
 {
 	struct cl_env_nest nest;
 	struct lu_env *env;
@@ -573,18 +628,32 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 	if (atomic_read(&cli->cl_lru_in_list) == 0 || target <= 0)
 		return 0;
 
+	if (!force) {
+		if (atomic_read(&cli->cl_lru_shrinkers) > 0)
+			return -EBUSY;
+
+		if (atomic_inc_return(&cli->cl_lru_shrinkers) > 1) {
+			atomic_dec(&cli->cl_lru_shrinkers);
+			return -EBUSY;
+		}
+	} else {
+		atomic_inc(&cli->cl_lru_shrinkers);
+	}
+
 	env = cl_env_nested_get(&nest);
-	if (IS_ERR(env))
-		return PTR_ERR(env);
+	if (IS_ERR(env)) {
+		rc = PTR_ERR(env);
+		goto out;
+	}
 
 	pvec = osc_env_info(env)->oti_pvec;
 	io = &osc_env_info(env)->oti_io;
 
 	client_obd_list_lock(&cli->cl_lru_list_lock);
-	atomic_inc(&cli->cl_lru_shrinkers);
 	maxscan = min(target << 1, atomic_read(&cli->cl_lru_in_list));
 	list_for_each_entry_safe(opg, temp, &cli->cl_lru_list, ops_lru) {
 		struct cl_page *page;
+		bool will_free = false;
 
 		if (--maxscan < 0)
 			break;
@@ -603,7 +672,7 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 			client_obd_list_unlock(&cli->cl_lru_list_lock);
 
 			if (clobj) {
-				count -= discard_pagevec(env, io, pvec, index);
+				discard_pagevec(env, io, pvec, index);
 				index = 0;
 
 				cl_io_fini(env, io);
@@ -625,98 +694,56 @@ int osc_lru_shrink(struct client_obd *cli, int target)
 			continue;
 		}
 
-		/* move this page to the end of list as it will be discarded
-		 * soon. The page will be finally removed from LRU list in
-		 * osc_page_delete().
-		 */
-		list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
+		if (cl_page_own_try(env, io, page) == 0) {
+			if (!cl_page_in_use_noref(page)) {
+				/* remove it from lru list earlier to avoid
+				 * lock contention
+				 */
+				__osc_lru_del(cli, opg);
+				opg->ops_in_lru = 0; /* will be discarded */
+
+				cl_page_get(page);
+				will_free = true;
+			} else {
+				cl_page_disown(env, io, page);
+			}
+		}
 
-		/* it's okay to grab a refcount here w/o holding lock because
-		 * it has to grab cl_lru_list_lock to delete the page.
-		 */
-		cl_page_get(page);
-		pvec[index++] = page;
-		if (++count >= target)
-			break;
+		if (!will_free) {
+			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
+			continue;
+		}
 
+		/* Don't discard and free the page with cl_lru_list held */
+		pvec[index++] = page;
 		if (unlikely(index == OTI_PVEC_SIZE)) {
 			client_obd_list_unlock(&cli->cl_lru_list_lock);
-			count -= discard_pagevec(env, io, pvec, index);
+			discard_pagevec(env, io, pvec, index);
 			index = 0;
 
 			client_obd_list_lock(&cli->cl_lru_list_lock);
 		}
+
+		if (++count >= target)
+			break;
 	}
 	client_obd_list_unlock(&cli->cl_lru_list_lock);
 
 	if (clobj) {
-		count -= discard_pagevec(env, io, pvec, index);
+		discard_pagevec(env, io, pvec, index);
 
 		cl_io_fini(env, io);
 		cl_object_put(env, clobj);
 	}
 	cl_env_nested_put(&nest, env);
 
+out:
 	atomic_dec(&cli->cl_lru_shrinkers);
-	return count > 0 ? count : rc;
-}
-
-static void osc_lru_add(struct client_obd *cli, struct osc_page *opg)
-{
-	bool wakeup = false;
-
-	if (!opg->ops_in_lru)
-		return;
-
-	atomic_dec(&cli->cl_lru_busy);
-	client_obd_list_lock(&cli->cl_lru_list_lock);
-	if (list_empty(&opg->ops_lru)) {
-		list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
-		atomic_inc_return(&cli->cl_lru_in_list);
-		wakeup = atomic_read(&osc_lru_waiters) > 0;
-	}
-	client_obd_list_unlock(&cli->cl_lru_list_lock);
-
-	if (wakeup) {
-		osc_lru_shrink(cli, osc_cache_too_much(cli));
+	if (count > 0) {
+		atomic_add(count, cli->cl_lru_left);
 		wake_up_all(&osc_lru_waitq);
 	}
-}
-
-/* delete page from LRUlist. The page can be deleted from LRUlist for two
- * reasons: redirtied or deleted from page cache.
- */
-static void osc_lru_del(struct client_obd *cli, struct osc_page *opg, bool del)
-{
-	if (opg->ops_in_lru) {
-		client_obd_list_lock(&cli->cl_lru_list_lock);
-		if (!list_empty(&opg->ops_lru)) {
-			LASSERT(atomic_read(&cli->cl_lru_in_list) > 0);
-			list_del_init(&opg->ops_lru);
-			atomic_dec(&cli->cl_lru_in_list);
-			if (!del)
-				atomic_inc(&cli->cl_lru_busy);
-		} else if (del) {
-			LASSERT(atomic_read(&cli->cl_lru_busy) > 0);
-			atomic_dec(&cli->cl_lru_busy);
-		}
-		client_obd_list_unlock(&cli->cl_lru_list_lock);
-		if (del) {
-			atomic_inc(cli->cl_lru_left);
-			/* this is a great place to release more LRU pages if
-			 * this osc occupies too many LRU pages and kernel is
-			 * stealing one of them.
-			 * cl_lru_shrinkers is to avoid recursive call in case
-			 * we're already in the context of osc_lru_shrink().
-			 */
-			if (atomic_read(&cli->cl_lru_shrinkers) == 0 &&
-			    !memory_pressure_get())
-				osc_lru_shrink(cli, osc_cache_too_much(cli));
-			wake_up(&osc_lru_waitq);
-		}
-	} else {
-		LASSERT(list_empty(&opg->ops_lru));
-	}
+	return count > 0 ? count : rc;
 }
 
 static inline int max_to_shrink(struct client_obd *cli)
@@ -724,16 +751,19 @@ static inline int max_to_shrink(struct client_obd *cli)
 	return min(atomic_read(&cli->cl_lru_in_list) >> 1, lru_shrink_max);
 }
 
-static int osc_lru_reclaim(struct client_obd *cli)
+int osc_lru_reclaim(struct client_obd *cli)
 {
 	struct cl_client_cache *cache = cli->cl_cache;
 	int max_scans;
-	int rc;
+	int rc = 0;
 
 	LASSERT(cache);
 
-	rc = osc_lru_shrink(cli, lru_shrink_min);
+	rc = osc_lru_shrink(cli, lru_shrink_min, false);
 	if (rc != 0) {
+		if (rc == -EBUSY)
+			rc = 0;
+
 		CDEBUG(D_CACHE, "%s: Free %d pages from own LRU: %p.\n",
 		       cli->cl_import->imp_obd->obd_name, rc, cli);
 		return rc;
@@ -764,10 +794,10 @@ static int osc_lru_reclaim(struct client_obd *cli)
 		       atomic_read(&cli->cl_lru_busy));
 
 		list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
-		if (atomic_read(&cli->cl_lru_in_list) > 0) {
+		if (osc_cache_too_much(cli) > 0) {
 			spin_unlock(&cache->ccc_lru_lock);
 
-			rc = osc_lru_shrink(cli, max_to_shrink(cli));
+			rc = osc_lru_shrink(cli, osc_cache_too_much(cli), true);
 			spin_lock(&cache->ccc_lru_lock);
 			if (rc != 0)
 				break;
@@ -784,15 +814,20 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 			   struct osc_page *opg)
 {
 	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
+	struct osc_io *oio = osc_env_io(env);
 	struct client_obd *cli = osc_cli(obj);
 	int rc = 0;
 
 	if (!cli->cl_cache) /* shall not be in LRU */
 		return 0;
 
+	if (oio->oi_lru_reserved > 0) {
+		--oio->oi_lru_reserved;
+		goto out;
+	}
+
 	LASSERT(atomic_read(cli->cl_lru_left) >= 0);
 	while (!atomic_add_unless(cli->cl_lru_left, -1, 0)) {
-		int gen;
 
 		/* run out of LRU spaces, try to drop some by itself */
 		rc = osc_lru_reclaim(cli);
@@ -803,23 +838,15 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 
 		cond_resched();
 
-		/* slowest case, all of caching pages are busy, notifying
-		 * other OSCs that we're lack of LRU slots.
-		 */
-		atomic_inc(&osc_lru_waiters);
-
-		gen = atomic_read(&cli->cl_lru_in_list);
 		rc = l_wait_event(osc_lru_waitq,
-				  atomic_read(cli->cl_lru_left) > 0 ||
-				  (atomic_read(&cli->cl_lru_in_list) > 0 &&
-				   gen != atomic_read(&cli->cl_lru_in_list)),
+				  atomic_read(cli->cl_lru_left) > 0,
 				  &lwi);
 
-		atomic_dec(&osc_lru_waiters);
 		if (rc < 0)
 			break;
 	}
 
+out:
 	if (rc >= 0) {
 		atomic_inc(&cli->cl_lru_busy);
 		opg->ops_in_lru = 1;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 850d5dd..6dadda4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2910,7 +2910,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		int nr = atomic_read(&cli->cl_lru_in_list) >> 1;
 		int target = *(int *)val;
 
-		nr = osc_lru_shrink(cli, min(nr, target));
+		nr = osc_lru_shrink(cli, min(nr, target), true);
 		*(int *)val -= nr;
 		return 0;
 	}
-- 
2.1.0
