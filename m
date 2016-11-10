From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:36 -0500
Subject: [lustre-devel] [PATCH 06/35] staging: lustre: osc: Performance tune
	for LRU
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Early launch page LRU work in osc_io_rw_iter_init();
Change the page LRU shrinking policy by OSC attributes;
Delete the contented lock osc_object::oo_seatbelt

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5108
Reviewed-on: http://review.whamcloud.com/10458
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   35 ++++-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    6 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   34 ++---
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   19 ---
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    7 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   13 ++-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    9 --
 drivers/staging/lustre/lustre/osc/osc_page.c       |  146 ++++++++++++--------
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   17 +--
 10 files changed, 160 insertions(+), 130 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5ebcfb8..2ab7560 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -247,15 +247,42 @@ struct client_obd {
 	struct obd_histogram     cl_read_offset_hist;
 	struct obd_histogram     cl_write_offset_hist;
 
-	/* lru for osc caching pages */
+	/* LRU for osc caching pages */
 	struct cl_client_cache	*cl_cache;
-	struct list_head	 cl_lru_osc; /* member of cl_cache->ccc_lru */
+	/** member of cl_cache->ccc_lru */
+	struct list_head	 cl_lru_osc;
+	/** # of available LRU slots left in the per-OSC cache.
+	 * Available LRU slots are shared by all OSCs of the same file system,
+	 * therefore this is a pointer to cl_client_cache::ccc_lru_left.
+	 */
 	atomic_long_t		*cl_lru_left;
+	/** # of busy LRU pages. A page is considered busy if it's in writeback
+	 * queue, or in transfer. Busy pages can't be discarded so they are not
+	 * in LRU cache.
+	 */
 	atomic_long_t		 cl_lru_busy;
+	/** # of LRU pages in the cache for this client_obd */
 	atomic_long_t		 cl_lru_in_list;
+	/** # of threads are shrinking LRU cache. To avoid contention, it's not
+	 * allowed to have multiple threads shrinking LRU cache.
+	 */
 	atomic_t		 cl_lru_shrinkers;
-	struct list_head	 cl_lru_list; /* lru page list */
-	spinlock_t		 cl_lru_list_lock; /* page list protector */
+	/** The time when this LRU cache was last used. */
+	time64_t		 cl_lru_last_used;
+	/** stats: how many reclaims have happened for this client_obd.
+	 * reclaim and shrink - shrink is async, voluntarily rebalancing;
+	 * reclaim is sync, initiated by IO thread when the LRU slots are
+	 * in shortage.
+	 */
+	u64			 cl_lru_reclaim;
+	/** List of LRU pages for this client_obd */
+	struct list_head	 cl_lru_list;
+	/** Lock for LRU page list */
+	spinlock_t		 cl_lru_list_lock;
+	/** # of unstable pages in this client_obd.
+	 * An unstable page is a page state that WRITE RPC has finished but
+	 * the transaction has NOT yet committed.
+	 */
 	atomic_long_t		 cl_unstable_count;
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index a837362..4421cfe 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -183,10 +183,12 @@ static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 
 	seq_printf(m,
 		   "used_mb: %ld\n"
-		   "busy_cnt: %ld\n",
+		   "busy_cnt: %ld\n"
+		   "reclaim: %llu\n",
 		   (atomic_long_read(&cli->cl_lru_in_list) +
 		    atomic_long_read(&cli->cl_lru_busy)) >> shift,
-		   atomic_long_read(&cli->cl_lru_busy));
+		   atomic_long_read(&cli->cl_lru_busy),
+		   cli->cl_lru_reclaim);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index cbbe85e..b939c9c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -959,7 +959,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 	if (rc == -ETIMEDOUT) {
 		OSC_EXTENT_DUMP(D_ERROR, ext,
 				"%s: wait ext to %u timedout, recovery in progress?\n",
-				osc_export(obj)->exp_obd->obd_name, state);
+				cli_name(osc_cli(obj)), state);
 
 		lwi = LWI_INTR(NULL, NULL);
 		rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state),
@@ -1327,7 +1327,6 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 {
 	struct osc_page *opg = oap2osc_page(oap);
 	struct cl_page    *page = oap2cl_page(oap);
-	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 	enum cl_req_type crt;
 	int srvlock;
 
@@ -1350,13 +1349,6 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	/* Clear opg->ops_transfer_pinned before VM lock is released. */
 	opg->ops_transfer_pinned = 0;
 
-	spin_lock(&obj->oo_seatbelt);
-	LASSERT(opg->ops_submitter);
-	LASSERT(!list_empty(&opg->ops_inflight));
-	list_del_init(&opg->ops_inflight);
-	opg->ops_submitter = NULL;
-	spin_unlock(&obj->oo_seatbelt);
-
 	opg->ops_submit_time = 0;
 	srvlock = oap->oap_brw_flags & OBD_BRW_SRVLOCK;
 
@@ -1386,10 +1378,10 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 
 #define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			      \
 	struct client_obd *__tmp = (cli);				      \
-	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	      \
+	CDEBUG(lvl, "%s: grant { dirty: %lu/%lu dirty_pages: %ld/%lu "	      \
 	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
 	       "lru {in list: %ld, left: %ld, waiters: %d }" fmt "\n",	      \
-	       __tmp->cl_import->imp_obd->obd_name,			      \
+	       cli_name(__tmp),						      \
 	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
 	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
@@ -1627,7 +1619,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		osc_io_unplug_async(env, cli, NULL);
 
 		CDEBUG(D_CACHE, "%s: sleeping for cache space @ %p for %p\n",
-		       cli->cl_import->imp_obd->obd_name, &ocw, oap);
+		       cli_name(cli), &ocw, oap);
 
 		rc = l_wait_event(ocw.ocw_waitq, ocw_granted(cli, &ocw), &lwi);
 
@@ -1671,7 +1663,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		break;
 	default:
 		CDEBUG(D_CACHE, "%s: event for cache space @ %p never arrived due to %d, fall back to sync i/o\n",
-		       cli->cl_import->imp_obd->obd_name, &ocw, rc);
+		       cli_name(cli), &ocw, rc);
 		break;
 	}
 out:
@@ -2250,14 +2242,9 @@ static int osc_io_unplug0(const struct lu_env *env, struct client_obd *cli,
 		return 0;
 
 	if (!async) {
-		/* disable osc_lru_shrink() temporarily to avoid
-		 * potential stack overrun problem. LU-2859
-		 */
-		atomic_inc(&cli->cl_lru_shrinkers);
 		spin_lock(&cli->cl_loi_list_lock);
 		osc_check_rpcs(env, cli);
 		spin_unlock(&cli->cl_loi_list_lock);
-		atomic_dec(&cli->cl_lru_shrinkers);
 	} else {
 		CDEBUG(D_CACHE, "Queue writeback work for client %p.\n", cli);
 		LASSERT(cli->cl_writeback_work);
@@ -2479,7 +2466,6 @@ int osc_teardown_async_page(const struct lu_env *env,
 			    struct osc_object *obj, struct osc_page *ops)
 {
 	struct osc_async_page *oap = &ops->ops_oap;
-	struct osc_extent *ext = NULL;
 	int rc = 0;
 
 	LASSERT(oap->oap_magic == OAP_MAGIC);
@@ -2487,12 +2473,15 @@ int osc_teardown_async_page(const struct lu_env *env,
 	CDEBUG(D_INFO, "teardown oap %p page %p at index %lu.\n",
 	       oap, ops, osc_index(oap2osc(oap)));
 
-	osc_object_lock(obj);
 	if (!list_empty(&oap->oap_rpc_item)) {
 		CDEBUG(D_CACHE, "oap %p is not in cache.\n", oap);
 		rc = -EBUSY;
 	} else if (!list_empty(&oap->oap_pending_item)) {
+		struct osc_extent *ext = NULL;
+
+		osc_object_lock(obj);
 		ext = osc_extent_lookup(obj, osc_index(oap2osc(oap)));
+		osc_object_unlock(obj);
 		/* only truncated pages are allowed to be taken out.
 		 * See osc_extent_truncate() and osc_cache_truncate_start()
 		 * for details.
@@ -2502,10 +2491,9 @@ int osc_teardown_async_page(const struct lu_env *env,
 					osc_index(oap2osc(oap)));
 			rc = -EBUSY;
 		}
+		if (ext)
+			osc_extent_put(env, ext);
 	}
-	osc_object_unlock(obj);
-	if (ext)
-		osc_extent_put(env, ext);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 8a55412..513397a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -126,16 +126,6 @@ struct osc_object {
 	int		oo_contended;
 	unsigned long	 oo_contention_time;
 	/**
-	 * List of pages in transfer.
-	 */
-	struct list_head	 oo_inflight[CRT_NR];
-	/**
-	 * Lock, protecting osc_page::ops_inflight, because a seat-belt is
-	 * locked during take-off and landing.
-	 */
-	spinlock_t	   oo_seatbelt;
-
-	/**
 	 * used by the osc to keep track of what objects to build into rpcs.
 	 * Protected by client_obd->cli_loi_list_lock.
 	 */
@@ -363,15 +353,6 @@ struct osc_page {
 	 */
 	struct list_head	      ops_lru;
 	/**
-	 * Linkage into a per-osc_object list of pages in flight. For
-	 * debugging.
-	 */
-	struct list_head	    ops_inflight;
-	/**
-	 * Thread that submitted this page for transfer. For debugging.
-	 */
-	struct task_struct	*ops_submitter;
-	/**
 	 * Submit time - the time when the page is starting RPC. For debugging.
 	 */
 	unsigned long	    ops_submit_time;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 12d3b58..0e181e2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -133,7 +133,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
 long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		    long target, bool force);
-long osc_lru_reclaim(struct client_obd *cli);
+long osc_lru_reclaim(struct client_obd *cli, unsigned long npages);
 
 unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
@@ -155,6 +155,11 @@ static inline unsigned long rpcs_in_flight(struct client_obd *cli)
 	return cli->cl_r_in_flight + cli->cl_w_in_flight;
 }
 
+static inline char *cli_name(struct client_obd *cli)
+{
+	return cli->cl_import->imp_obd->obd_name;
+}
+
 struct osc_device {
 	struct cl_device    od_cl;
 	struct obd_export  *od_exp;
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 3b82d0a..e0f81a4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -372,7 +372,7 @@ static int osc_io_rw_iter_init(const struct lu_env *env,
 		npages = max_pages;
 
 	c = atomic_long_read(cli->cl_lru_left);
-	if (c < npages && osc_lru_reclaim(cli) > 0)
+	if (c < npages && osc_lru_reclaim(cli, npages) > 0)
 		c = atomic_long_read(cli->cl_lru_left);
 	while (c >= npages) {
 		if (c == atomic_long_cmpxchg(cli->cl_lru_left, c, c - npages)) {
@@ -381,6 +381,17 @@ static int osc_io_rw_iter_init(const struct lu_env *env,
 		}
 		c = atomic_long_read(cli->cl_lru_left);
 	}
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
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index dc0c173..a6dafbf 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -71,13 +71,8 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 {
 	struct osc_object *osc = lu2osc(obj);
 	const struct cl_object_conf *cconf = lu2cl_conf(conf);
-	int i;
 
 	osc->oo_oinfo = cconf->u.coc_oinfo;
-	spin_lock_init(&osc->oo_seatbelt);
-	for (i = 0; i < CRT_NR; ++i)
-		INIT_LIST_HEAD(&osc->oo_inflight[i]);
-
 	INIT_LIST_HEAD(&osc->oo_ready_item);
 	INIT_LIST_HEAD(&osc->oo_hp_ready_item);
 	INIT_LIST_HEAD(&osc->oo_write_item);
@@ -103,10 +98,6 @@ static int osc_object_init(const struct lu_env *env, struct lu_object *obj,
 static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 {
 	struct osc_object *osc = lu2osc(obj);
-	int i;
-
-	for (i = 0; i < CRT_NR; ++i)
-		LASSERT(list_empty(&osc->oo_inflight[i]));
 
 	LASSERT(list_empty(&osc->oo_ready_item));
 	LASSERT(list_empty(&osc->oo_hp_ready_item));
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 93248d1..29dfd5d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -86,11 +86,6 @@ static void osc_page_transfer_add(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
 
 	osc_lru_use(osc_cli(obj), opg);
-
-	spin_lock(&obj->oo_seatbelt);
-	list_add(&opg->ops_inflight, &obj->oo_inflight[crt]);
-	opg->ops_submitter = current;
-	spin_unlock(&obj->oo_seatbelt);
 }
 
 int osc_page_cache_add(const struct lu_env *env,
@@ -139,7 +134,7 @@ static int osc_page_print(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(slice->cpl_obj);
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
-	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %u %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %s %p %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
+	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %u %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
 			  opg, osc_index(opg),
 			  /* 1 */
 			  oap->oap_magic, oap->oap_cmd,
@@ -151,8 +146,7 @@ static int osc_page_print(const struct lu_env *env,
 			  oap->oap_async_flags, oap->oap_brw_flags,
 			  oap->oap_request, oap->oap_cli, obj,
 			  /* 3 */
-			  osc_list(&opg->ops_inflight),
-			  opg->ops_submitter, opg->ops_transfer_pinned,
+			  opg->ops_transfer_pinned,
 			  osc_submit_duration(opg), opg->ops_srvlock,
 			  /* 4 */
 			  cli->cl_r_in_flight, cli->cl_w_in_flight,
@@ -191,14 +185,6 @@ static void osc_page_delete(const struct lu_env *env,
 		LASSERT(0);
 	}
 
-	spin_lock(&obj->oo_seatbelt);
-	if (opg->ops_submitter) {
-		LASSERT(!list_empty(&opg->ops_inflight));
-		list_del_init(&opg->ops_inflight);
-		opg->ops_submitter = NULL;
-	}
-	spin_unlock(&obj->oo_seatbelt);
-
 	osc_lru_del(osc_cli(obj), opg);
 
 	if (slice->cpl_page->cp_type == CPT_CACHEABLE) {
@@ -281,10 +267,6 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 		cl_page_slice_add(page, &opg->ops_cl, obj, index,
 				  &osc_page_ops);
 	}
-	/* ops_inflight and ops_lru are the same field, but it doesn't
-	 * hurt to initialize it twice :-)
-	 */
-	INIT_LIST_HEAD(&opg->ops_inflight);
 	INIT_LIST_HEAD(&opg->ops_lru);
 
 	/* reserve an LRU space for this page */
@@ -342,16 +324,27 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
  * OSC to free slots voluntarily to maintain a reasonable number of free slots
  * at any time.
  */
-
 static DECLARE_WAIT_QUEUE_HEAD(osc_lru_waitq);
-/* LRU pages are freed in batch mode. OSC should at least free this
- * number of pages to avoid running out of LRU budget, and..
+
+/**
+ * LRU pages are freed in batch mode. OSC should at least free this
+ * number of pages to avoid running out of LRU slots.
  */
-static const int lru_shrink_min = 2 << (20 - PAGE_SHIFT);  /* 2M */
-/* free this number@most otherwise it will take too long time to finish. */
-static const int lru_shrink_max = 8 << (20 - PAGE_SHIFT); /* 8M */
+static inline int lru_shrink_min(struct client_obd *cli)
+{
+	return cli->cl_max_pages_per_rpc * 2;
+}
+
+/**
+ * free this number at most otherwise it will take too long time to finish.
+ */
+static inline int lru_shrink_max(struct client_obd *cli)
+{
+	return cli->cl_max_pages_per_rpc * cli->cl_max_rpcs_in_flight;
+}
 
-/* Check if we can free LRU slots from this OSC. If there exists LRU waiters,
+/**
+ * Check if we can free LRU slots from this OSC. If there exists LRU waiters,
  * we should free slots aggressively. In this way, slots are freed in a steady
  * step to maintain fairness among OSCs.
  *
@@ -368,13 +361,19 @@ static int osc_cache_too_much(struct client_obd *cli)
 	/* if it's going to run out LRU slots, we should free some, but not
 	 * too much to maintain fairness among OSCs.
 	 */
-	if (atomic_long_read(cli->cl_lru_left) < cache->ccc_lru_max >> 4) {
+	if (atomic_long_read(cli->cl_lru_left) < cache->ccc_lru_max >> 2) {
 		if (pages >= budget)
-			return lru_shrink_max;
+			return lru_shrink_max(cli);
 		else if (pages >= budget / 2)
-			return lru_shrink_min;
-	} else if (pages >= budget * 2) {
-		return lru_shrink_min;
+			return lru_shrink_min(cli);
+	} else {
+		time64_t duration = ktime_get_real_seconds();
+
+		/* knock out pages by duration of no IO activity */
+		duration =- cli->cl_lru_last_used;
+		duration >>= 6; /* approximately 1 minute */
+		if (duration > 0 && pages >= budget / duration)
+			return lru_shrink_min(cli);
 	}
 	return 0;
 }
@@ -382,11 +381,21 @@ static int osc_cache_too_much(struct client_obd *cli)
 int lru_queue_work(const struct lu_env *env, void *data)
 {
 	struct client_obd *cli = data;
+	int count;
 
-	CDEBUG(D_CACHE, "Run LRU work for client obd %p.\n", cli);
+	CDEBUG(D_CACHE, "%s: run LRU work for client obd\n", cli_name(cli));
 
-	if (osc_cache_too_much(cli))
-		osc_lru_shrink(env, cli, lru_shrink_max, true);
+	count = osc_cache_too_much(cli);
+	if (count > 0) {
+		int rc = osc_lru_shrink(env, cli, count, false);
+
+		CDEBUG(D_CACHE, "%s: shrank %d/%d pages from client obd\n",
+		       cli_name(cli), rc, count);
+		if (rc >= count) {
+			CDEBUG(D_CACHE, "%s: queue again\n", cli_name(cli));
+			ptlrpcd_queue_work(cli->cl_lru_work);
+		}
+	}
 
 	return 0;
 }
@@ -413,10 +422,10 @@ void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 		list_splice_tail(&lru, &cli->cl_lru_list);
 		atomic_long_sub(npages, &cli->cl_lru_busy);
 		atomic_long_add(npages, &cli->cl_lru_in_list);
+		cli->cl_lru_last_used = ktime_get_real_seconds();
 		spin_unlock(&cli->cl_lru_list_lock);
 
-		/* XXX: May set force to be true for better performance */
-		if (osc_cache_too_much(cli))
+		if (waitqueue_active(&osc_lru_waitq))
 			(void)ptlrpcd_queue_work(cli->cl_lru_work);
 	}
 }
@@ -449,8 +458,10 @@ static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 		 * this osc occupies too many LRU pages and kernel is
 		 * stealing one of them.
 		 */
-		if (!memory_pressure_get())
+		if (osc_cache_too_much(cli)) {
+			CDEBUG(D_CACHE, "%s: queue LRU workn", cli_name(cli));
 			(void)ptlrpcd_queue_work(cli->cl_lru_work);
+		}
 		wake_up(&osc_lru_waitq);
 	} else {
 		LASSERT(list_empty(&opg->ops_lru));
@@ -482,6 +493,7 @@ static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
 		struct cl_page *page = pvec[i];
 
 		LASSERT(cl_page_is_owned(page, io));
+		cl_page_delete(env, page);
 		cl_page_discard(env, io, page);
 		cl_page_disown(env, io, page);
 		cl_page_put(env, page);
@@ -532,6 +544,8 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	if (atomic_long_read(&cli->cl_lru_in_list) == 0 || target <= 0)
 		return 0;
 
+	CDEBUG(D_CACHE, "%s: shrinkers: %d, force: %d\n",
+	       cli_name(cli), atomic_read(&cli->cl_lru_shrinkers), force);
 	if (!force) {
 		if (atomic_read(&cli->cl_lru_shrinkers) > 0)
 			return -EBUSY;
@@ -548,11 +562,16 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	io = &osc_env_info(env)->oti_io;
 
 	spin_lock(&cli->cl_lru_list_lock);
+	if (force)
+		cli->cl_lru_reclaim++;
 	maxscan = min(target << 1, atomic_long_read(&cli->cl_lru_in_list));
 	list_for_each_entry_safe(opg, temp, &cli->cl_lru_list, ops_lru) {
 		struct cl_page *page;
 		bool will_free = false;
 
+		if (!force && atomic_read(&cli->cl_lru_shrinkers) > 1)
+			break;
+
 		if (--maxscan < 0)
 			break;
 
@@ -642,7 +661,13 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	return count > 0 ? count : rc;
 }
 
-long osc_lru_reclaim(struct client_obd *cli)
+/**
+ * Reclaim LRU pages by an IO thread. The caller wants to reclaim at least
+ * \@npages of LRU slots. For performance consideration, it's better to drop
+ * LRU pages in batch. Therefore, the actual number is adjusted at least
+ * max_pages_per_rpc.
+ */
+long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 {
 	struct lu_env *env;
 	struct cl_client_cache *cache = cli->cl_cache;
@@ -656,20 +681,23 @@ long osc_lru_reclaim(struct client_obd *cli)
 	if (IS_ERR(env))
 		return 0;
 
-	rc = osc_lru_shrink(env, cli, osc_cache_too_much(cli), false);
-	if (rc != 0) {
-		if (rc == -EBUSY)
-			rc = 0;
-
-		CDEBUG(D_CACHE, "%s: Free %ld pages from own LRU: %p.\n",
-		       cli->cl_import->imp_obd->obd_name, rc, cli);
+	npages = max_t(int, npages, cli->cl_max_pages_per_rpc);
+	CDEBUG(D_CACHE, "%s: start to reclaim %ld pages from LRU\n",
+	       cli_name(cli), npages);
+	rc = osc_lru_shrink(env, cli, npages, true);
+	if (rc >= npages) {
+		CDEBUG(D_CACHE, "%s: reclaimed %ld/%ld pages from LRU\n",
+		       cli_name(cli), rc, npages);
+		if (osc_cache_too_much(cli) > 0)
+			ptlrpcd_queue_work(cli->cl_lru_work);
 		goto out;
+	} else if (rc > 0) {
+		npages -= rc;
 	}
 
-	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %ld, busy: %ld.\n",
-	       cli->cl_import->imp_obd->obd_name, cli,
-	       atomic_long_read(&cli->cl_lru_in_list),
-	       atomic_long_read(&cli->cl_lru_busy));
+	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %ld/%ld, want: %ld\n",
+	       cli_name(cli), cli, atomic_long_read(&cli->cl_lru_in_list),
+	       atomic_long_read(&cli->cl_lru_busy), npages);
 
 	/* Reclaim LRU slots from other client_obd as it can't free enough
 	 * from its own. This should rarely happen.
@@ -686,7 +714,7 @@ long osc_lru_reclaim(struct client_obd *cli)
 				 cl_lru_osc);
 
 		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %ld, busy: %ld.\n",
-		       cli->cl_import->imp_obd->obd_name, cli,
+		       cli_name(cli), cli,
 		       atomic_long_read(&cli->cl_lru_in_list),
 		       atomic_long_read(&cli->cl_lru_busy));
 
@@ -694,11 +722,12 @@ long osc_lru_reclaim(struct client_obd *cli)
 		if (osc_cache_too_much(cli) > 0) {
 			spin_unlock(&cache->ccc_lru_lock);
 
-			rc = osc_lru_shrink(env, cli, osc_cache_too_much(cli),
-					    true);
+			rc = osc_lru_shrink(env, cli, npages, true);
 			spin_lock(&cache->ccc_lru_lock);
-			if (rc != 0)
+			if (rc >= npages)
 				break;
+			if (rc > 0)
+				npages -= rc;
 		}
 	}
 	spin_unlock(&cache->ccc_lru_lock);
@@ -706,7 +735,7 @@ long osc_lru_reclaim(struct client_obd *cli)
 out:
 	cl_env_put(env, &refcheck);
 	CDEBUG(D_CACHE, "%s: cli %p freed %ld pages.\n",
-	       cli->cl_import->imp_obd->obd_name, cli, rc);
+	       cli_name(cli), cli, rc);
 	return rc;
 }
 
@@ -736,7 +765,7 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 	LASSERT(atomic_long_read(cli->cl_lru_left) >= 0);
 	while (!atomic_long_add_unless(cli->cl_lru_left, -1, 0)) {
 		/* run out of LRU spaces, try to drop some by itself */
-		rc = osc_lru_reclaim(cli);
+		rc = osc_lru_reclaim(cli, 1);
 		if (rc < 0)
 			break;
 		if (rc > 0)
@@ -839,7 +868,7 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 	if (!unstable_count)
 		wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
 
-	if (osc_cache_too_much(cli))
+	if (waitqueue_active(&osc_lru_waitq))
 		(void)ptlrpcd_queue_work(cli->cl_lru_work);
 }
 
@@ -895,8 +924,7 @@ bool osc_over_unstable_soft_limit(struct client_obd *cli)
 
 	CDEBUG(D_CACHE,
 	       "%s: cli: %p unstable pages: %lu, osc unstable pages: %lu\n",
-	       cli->cl_import->imp_obd->obd_name, cli,
-	       unstable_nr, osc_unstable_count);
+	       cli_name(cli), cli, unstable_nr, osc_unstable_count);
 
 	/*
 	 * If the LRU slots are in shortage - 25% remaining AND this OSC
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index acdd91a..4bb3b45 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -106,7 +106,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			}
 
 			CDEBUG(D_QUOTA, "%s: setdq to insert for %s %d (%d)\n",
-			       cli->cl_import->imp_obd->obd_name,
+			       cli_name(cli),
 			       type == USRQUOTA ? "user" : "group",
 			       qid[type], rc);
 		} else {
@@ -122,7 +122,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 				kmem_cache_free(osc_quota_kmem, oqi);
 
 			CDEBUG(D_QUOTA, "%s: setdq to remove for %s %d (%p)\n",
-			       cli->cl_import->imp_obd->obd_name,
+			       cli_name(cli),
 			       type == USRQUOTA ? "user" : "group",
 			       qid[type], oqi);
 		}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 8023561..3daca63 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -584,14 +584,13 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		oa->o_undirty = 0;
 	} else if (unlikely(atomic_long_read(&obd_dirty_pages) -
 			    atomic_long_read(&obd_dirty_transit_pages) >
-			    (obd_max_dirty_pages + 1))) {
+			    (long)(obd_max_dirty_pages + 1))) {
 		/* The atomic_read() allowing the atomic_inc() are
 		 * not covered by a lock thus they may safely race and trip
 		 * this CERROR() unless we add in a small fudge factor (+1).
 		 */
-		CERROR("%s: dirty %ld + %ld > system dirty_max %lu\n",
-		       cli->cl_import->imp_obd->obd_name,
-		       atomic_long_read(&obd_dirty_pages),
+		CERROR("%s: dirty %ld + %ld > system dirty_max %ld\n",
+		       cli_name(cli), atomic_long_read(&obd_dirty_pages),
 		       atomic_long_read(&obd_dirty_transit_pages),
 		       obd_max_dirty_pages);
 		oa->o_undirty = 0;
@@ -786,12 +785,10 @@ static int osc_add_shrink_grant(struct client_obd *client)
 				       osc_grant_shrink_grant_cb, NULL,
 				       &client->cl_grant_shrink_list);
 	if (rc) {
-		CERROR("add grant client %s error %d\n",
-		       client->cl_import->imp_obd->obd_name, rc);
+		CERROR("add grant client %s error %d\n", cli_name(client), rc);
 		return rc;
 	}
-	CDEBUG(D_CACHE, "add grant client %s\n",
-	       client->cl_import->imp_obd->obd_name);
+	CDEBUG(D_CACHE, "add grant client %s\n", cli_name(client));
 	osc_update_next_shrink(client);
 	return 0;
 }
@@ -825,8 +822,8 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	spin_unlock(&cli->cl_loi_list_lock);
 
 	CDEBUG(D_CACHE, "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d\n",
-	       cli->cl_import->imp_obd->obd_name,
-	       cli->cl_avail_grant, cli->cl_lost_grant, cli->cl_chunkbits);
+	       cli_name(cli), cli->cl_avail_grant, cli->cl_lost_grant,
+	       cli->cl_chunkbits);
 
 	if (ocd->ocd_connect_flags & OBD_CONNECT_GRANT_SHRINK &&
 	    list_empty(&cli->cl_grant_shrink_list))
-- 
1.7.1
