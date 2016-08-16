From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:10 -0400
Subject: [lustre-devel] [PATCH 57/80] staging: lustre: osc: revise unstable
	pages accounting
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-58-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

A few changes are made in this patch for unstable pages tracking:

1. Remove kernel NFS unstable pages tracking because it killed
   performance
2. Track unstable pages as part of LRU cache. Otherwise Lustre
   can use much more memory than max_cached_mb
3. Remove obd_unstable_pages tracking to avoid using global
   atomic counter
4. Make unstable pages track optional. Tracking unstable pages is
   turned off by default, and can be controlled by
   llite.*.unstable_stats.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4841
Reviewed-on: http://review.whamcloud.com/10003
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   35 +++-
 .../staging/lustre/lustre/include/obd_support.h    |    1 -
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   41 ++++-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 -
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   96 +---------
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  208 +++++++++++++++++---
 drivers/staging/lustre/lustre/osc/osc_request.c    |   13 +-
 8 files changed, 253 insertions(+), 145 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index d269b32..ec6cf7c 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1039,23 +1039,32 @@ do {									  \
 	}								     \
 } while (0)
 
-static inline int __page_in_use(const struct cl_page *page, int refc)
-{
-	if (page->cp_type == CPT_CACHEABLE)
-		++refc;
-	LASSERT(atomic_read(&page->cp_ref) > 0);
-	return (atomic_read(&page->cp_ref) > refc);
-}
-
-#define cl_page_in_use(pg)       __page_in_use(pg, 1)
-#define cl_page_in_use_noref(pg) __page_in_use(pg, 0)
-
 static inline struct page *cl_page_vmpage(struct cl_page *page)
 {
 	LASSERT(page->cp_vmpage);
 	return page->cp_vmpage;
 }
 
+/**
+ * Check if a cl_page is in use.
+ *
+ * Client cache holds a refcount, this refcount will be dropped when
+ * the page is taken out of cache, see vvp_page_delete().
+ */
+static inline bool __page_in_use(const struct cl_page *page, int refc)
+{
+	return (atomic_read(&page->cp_ref) > refc + 1);
+}
+
+/**
+ * Caller itself holds a refcount of cl_page.
+ */
+#define cl_page_in_use(pg)	 __page_in_use(pg, 1)
+/**
+ * Caller doesn't hold a refcount.
+ */
+#define cl_page_in_use_noref(pg) __page_in_use(pg, 0)
+
 /** @} cl_page */
 
 /** \addtogroup cl_lock cl_lock
@@ -2331,6 +2340,10 @@ struct cl_client_cache {
 	 */
 	spinlock_t		ccc_lru_lock;
 	/**
+	 * Set if unstable check is enabled
+	 */
+	unsigned int		ccc_unstable_check:1;
+	/**
 	 * # of unstable pages for this mount point
 	 */
 	atomic_t		ccc_unstable_nr;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 26fdff6..a11fff1 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -54,7 +54,6 @@ extern int at_early_margin;
 extern int at_extra;
 extern unsigned int obd_sync_filter;
 extern unsigned int obd_max_dirty_pages;
-extern atomic_t obd_unstable_pages;
 extern atomic_t obd_dirty_pages;
 extern atomic_t obd_dirty_transit_pages;
 extern char obd_jobid_var[];
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 2f1f389..5f8e78d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -828,10 +828,45 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 	pages = atomic_read(&cache->ccc_unstable_nr);
 	mb = (pages * PAGE_SIZE) >> 20;
 
-	return sprintf(buf, "unstable_pages: %8d\n"
-			    "unstable_mb:    %8d\n", pages, mb);
+	return sprintf(buf, "unstable_check: %8d\n"
+			    "unstable_pages: %8d\n"
+			    "unstable_mb:    %8d\n",
+			    cache->ccc_unstable_check, pages, mb);
 }
-LUSTRE_RO_ATTR(unstable_stats);
+
+static ssize_t unstable_stats_store(struct kobject *kobj,
+				    struct attribute *attr,
+				    const char *buffer,
+				    size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+	char kernbuf[128];
+	int val, rc;
+
+	if (!count)
+		return 0;
+	if (count < 0 || count >= sizeof(kernbuf))
+		return -EINVAL;
+
+	if (copy_from_user(kernbuf, buffer, count))
+		return -EFAULT;
+	kernbuf[count] = 0;
+
+	buffer += lprocfs_find_named_value(kernbuf, "unstable_check:", &count) -
+		  kernbuf;
+	rc = lprocfs_write_helper(buffer, count, &val);
+	if (rc < 0)
+		return rc;
+
+	/* borrow lru lock to set the value */
+	spin_lock(&sbi->ll_cache->ccc_lru_lock);
+	sbi->ll_cache->ccc_unstable_check = !!val;
+	spin_unlock(&sbi->ll_cache->ccc_lru_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(unstable_stats);
 
 static ssize_t root_squash_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 6edf53e..90a365b 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -57,8 +57,6 @@ unsigned int obd_dump_on_eviction;
 EXPORT_SYMBOL(obd_dump_on_eviction);
 unsigned int obd_max_dirty_pages = 256;
 EXPORT_SYMBOL(obd_max_dirty_pages);
-atomic_t obd_unstable_pages;
-EXPORT_SYMBOL(obd_unstable_pages);
 atomic_t obd_dirty_pages;
 EXPORT_SYMBOL(obd_dirty_pages);
 unsigned int obd_timeout = OBD_TIMEOUT_DEFAULT;   /* seconds */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 683b3c2..deaf912 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1384,13 +1384,11 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 #define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			      \
 	struct client_obd *__tmp = (cli);				      \
 	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %d/%d "	      \
-	       "unstable_pages: %d/%d dropped: %ld avail: %ld, "	      \
-	       "reserved: %ld, flight: %d } lru {in list: %d, "		      \
-	       "left: %d, waiters: %d }" fmt,                                 \
+	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
+	       "lru {in list: %d, left: %d, waiters: %d }" fmt,		      \
 	       __tmp->cl_import->imp_obd->obd_name,			      \
 	       __tmp->cl_dirty, __tmp->cl_dirty_max,			      \
 	       atomic_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
-	       atomic_read(&obd_unstable_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
 	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		      \
 	       atomic_read(&__tmp->cl_lru_in_list),			      \
@@ -1542,8 +1540,7 @@ static int osc_enter_cache_try(struct client_obd *cli,
 		return 0;
 
 	if (cli->cl_dirty + PAGE_SIZE <= cli->cl_dirty_max &&
-	    atomic_read(&obd_unstable_pages) + 1 +
-	    atomic_read(&obd_dirty_pages) <= obd_max_dirty_pages) {
+	    atomic_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
 		if (transient) {
 			cli->cl_dirty_transit += PAGE_SIZE;
@@ -1671,8 +1668,7 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 		ocw->ocw_rc = -EDQUOT;
 		/* we can't dirty more */
 		if ((cli->cl_dirty + PAGE_SIZE > cli->cl_dirty_max) ||
-		    (atomic_read(&obd_unstable_pages) + 1 +
-		     atomic_read(&obd_dirty_pages) > obd_max_dirty_pages)) {
+		    (atomic_read(&obd_dirty_pages) + 1 > obd_max_dirty_pages)) {
 			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %d\n",
 			       cli->cl_dirty,
 			       cli->cl_dirty_max, obd_max_dirty_pages);
@@ -1843,84 +1839,6 @@ static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
 		ar->ar_force_sync = 0;
 }
 
-/**
- * Performs "unstable" page accounting. This function balances the
- * increment operations performed in osc_inc_unstable_pages. It is
- * registered as the RPC request callback, and is executed when the
- * bulk RPC is committed on the server. Thus at this point, the pages
- * involved in the bulk transfer are no longer considered unstable.
- */
-void osc_dec_unstable_pages(struct ptlrpc_request *req)
-{
-	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
-	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	int page_count = desc->bd_iov_count;
-	int i;
-
-	/* No unstable page tracking */
-	if (!cli->cl_cache)
-		return;
-
-	LASSERT(page_count >= 0);
-
-	for (i = 0; i < page_count; i++)
-		dec_node_page_state(desc->bd_iov[i].bv_page, NR_UNSTABLE_NFS);
-
-	atomic_sub(page_count, &cli->cl_cache->ccc_unstable_nr);
-	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
-
-	atomic_sub(page_count, &cli->cl_unstable_count);
-	LASSERT(atomic_read(&cli->cl_unstable_count) >= 0);
-
-	atomic_sub(page_count, &obd_unstable_pages);
-	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
-
-	wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
-}
-
-/* "unstable" page accounting. See: osc_dec_unstable_pages. */
-void osc_inc_unstable_pages(struct ptlrpc_request *req)
-{
-	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
-	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	long page_count = desc->bd_iov_count;
-	int i;
-
-	/* No unstable page tracking */
-	if (!cli->cl_cache)
-		return;
-
-	LASSERT(page_count >= 0);
-
-	for (i = 0; i < page_count; i++)
-		inc_node_page_state(desc->bd_iov[i].bv_page, NR_UNSTABLE_NFS);
-
-	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
-	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
-
-	LASSERT(atomic_read(&cli->cl_unstable_count) >= 0);
-	atomic_add(page_count, &cli->cl_unstable_count);
-
-	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
-	atomic_add(page_count, &obd_unstable_pages);
-
-	/*
-	 * If the request has already been committed (i.e. brw_commit
-	 * called via rq_commit_cb), we need to undo the unstable page
-	 * increments we just performed because rq_commit_cb wont be
-	 * called again.
-	 */
-	spin_lock(&req->rq_lock);
-	if (unlikely(req->rq_committed)) {
-		/* Drop lock before calling osc_dec_unstable_pages */
-		spin_unlock(&req->rq_lock);
-		osc_dec_unstable_pages(req);
-	} else {
-		req->rq_unstable = 1;
-		spin_unlock(&req->rq_lock);
-	}
-}
-
 /* this must be called holding the loi list lock to give coverage to exit_cache,
  * async_flag maintenance, and oap_request
  */
@@ -1932,9 +1850,6 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 	__u64 xid = 0;
 
 	if (oap->oap_request) {
-		if (!rc)
-			osc_inc_unstable_pages(oap->oap_request);
-
 		xid = ptlrpc_req_xid(oap->oap_request);
 		ptlrpc_req_finished(oap->oap_request);
 		oap->oap_request = NULL;
@@ -2421,9 +2336,6 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 			return rc;
 	}
 
-	if (osc_over_unstable_soft_limit(cli))
-		brw_flags |= OBD_BRW_SOFT_SYNC;
-
 	oap->oap_cmd = cmd;
 	oap->oap_page_off = ops->ops_from;
 	oap->oap_count = ops->ops_to - ops->ops_from;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 2038885..eca5fef 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -197,7 +197,7 @@ int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 int osc_quota_poll_check(struct obd_export *exp, struct if_quotacheck *qchk);
 void osc_inc_unstable_pages(struct ptlrpc_request *req);
 void osc_dec_unstable_pages(struct ptlrpc_request *req);
-int  osc_over_unstable_soft_limit(struct client_obd *cli);
+bool osc_over_unstable_soft_limit(struct client_obd *cli);
 
 struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 				       struct osc_object *obj, pgoff_t index,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 355f496..583a0af 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -323,32 +323,6 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	return result;
 }
 
-int osc_over_unstable_soft_limit(struct client_obd *cli)
-{
-	long obd_upages, obd_dpages, osc_upages;
-
-	/* Can't check cli->cl_unstable_count, therefore, no soft limit */
-	if (!cli)
-		return 0;
-
-	obd_upages = atomic_read(&obd_unstable_pages);
-	obd_dpages = atomic_read(&obd_dirty_pages);
-
-	osc_upages = atomic_read(&cli->cl_unstable_count);
-
-	/*
-	 * obd_max_dirty_pages is the max number of (dirty + unstable)
-	 * pages allowed at any given time. To simulate an unstable page
-	 * only limit, we subtract the current number of dirty pages
-	 * from this max. This difference is roughly the amount of pages
-	 * currently available for unstable pages. Thus, the soft limit
-	 * is half of that difference. Check osc_upages to ensure we don't
-	 * set SOFT_SYNC for OSCs without any outstanding unstable pages.
-	 */
-	return osc_upages &&
-	       obd_upages >= (obd_max_dirty_pages - obd_dpages) / 2;
-}
-
 /**
  * Helper function called by osc_io_submit() for every page in an immediate
  * transfer (i.e., transferred synchronously).
@@ -368,9 +342,6 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_count = opg->ops_to - opg->ops_from;
 	oap->oap_brw_flags = brw_flags | OBD_BRW_SYNC;
 
-	if (osc_over_unstable_soft_limit(oap->oap_cli))
-		oap->oap_brw_flags |= OBD_BRW_SOFT_SYNC;
-
 	if (capable(CFS_CAP_SYS_RESOURCE)) {
 		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
@@ -540,6 +511,28 @@ static void discard_pagevec(const struct lu_env *env, struct cl_io *io,
 }
 
 /**
+ * Check if a cl_page can be released, i.e, it's not being used.
+ *
+ * If unstable account is turned on, bulk transfer may hold one refcount
+ * for recovery so we need to check vmpage refcount as well; otherwise,
+ * even we can destroy cl_page but the corresponding vmpage can't be reused.
+ */
+static inline bool lru_page_busy(struct client_obd *cli, struct cl_page *page)
+{
+	if (cl_page_in_use_noref(page))
+		return true;
+
+	if (cli->cl_cache->ccc_unstable_check) {
+		struct page *vmpage = cl_page_vmpage(page);
+
+		/* vmpage have two known users: cl_page and VM page cache */
+		if (page_count(vmpage) - page_mapcount(vmpage) > 2)
+			return true;
+	}
+	return false;
+}
+
+/**
  * Drop @target of pages from LRU at most.
  */
 int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
@@ -584,7 +577,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 			break;
 
 		page = opg->ops_cl.cpl_page;
-		if (cl_page_in_use_noref(page)) {
+		if (lru_page_busy(cli, page)) {
 			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
 			continue;
 		}
@@ -620,7 +613,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		}
 
 		if (cl_page_own_try(env, io, page) == 0) {
-			if (!cl_page_in_use_noref(page)) {
+			if (!lru_page_busy(cli, page)) {
 				/* remove it from lru list earlier to avoid
 				 * lock contention
 				 */
@@ -742,6 +735,13 @@ out:
 	return rc;
 }
 
+/**
+ * osc_lru_reserve() is called to reserve an LRU slot for a cl_page.
+ *
+ * Usually the LRU slots are reserved in osc_io_iter_rw_init().
+ * Only in the case that the LRU slots are in extreme shortage, it should
+ * have reserved enough slots for an IO.
+ */
 static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 			   struct osc_page *opg)
 {
@@ -787,4 +787,150 @@ out:
 	return rc;
 }
 
+/**
+ * Atomic operations are expensive. We accumulate the accounting for the
+ * same page zone to get better performance.
+ * In practice this can work pretty good because the pages in the same RPC
+ * are likely from the same page zone.
+ */
+static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
+					    int factor)
+{
+	int page_count = desc->bd_iov_count;
+	void *zone = NULL;
+	int count = 0;
+	int i;
+
+	for (i = 0; i < page_count; i++) {
+		void *pz = page_zone(desc->bd_iov[i].bv_page);
+
+		if (likely(pz == zone)) {
+			++count;
+			continue;
+		}
+
+		if (count > 0) {
+			mod_zone_page_state(zone, NR_UNSTABLE_NFS,
+					    factor * count);
+			count = 0;
+		}
+		zone = pz;
+		++count;
+	}
+	if (count > 0)
+		mod_zone_page_state(zone, NR_UNSTABLE_NFS, factor * count);
+}
+
+static inline void add_unstable_page_accounting(struct ptlrpc_bulk_desc *desc)
+{
+	unstable_page_accounting(desc, 1);
+}
+
+static inline void dec_unstable_page_accounting(struct ptlrpc_bulk_desc *desc)
+{
+	unstable_page_accounting(desc, -1);
+}
+
+/**
+ * Performs "unstable" page accounting. This function balances the
+ * increment operations performed in osc_inc_unstable_pages. It is
+ * registered as the RPC request callback, and is executed when the
+ * bulk RPC is committed on the server. Thus at this point, the pages
+ * involved in the bulk transfer are no longer considered unstable.
+ *
+ * If this function is called, the request should have been committed
+ * or req:rq_unstable must have been set; it implies that the unstable
+ * statistic have been added.
+ */
+void osc_dec_unstable_pages(struct ptlrpc_request *req)
+{
+	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
+	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
+	int page_count = desc->bd_iov_count;
+	int unstable_count;
+
+	LASSERT(page_count >= 0);
+	dec_unstable_page_accounting(desc);
+
+	unstable_count = atomic_sub_return(page_count, &cli->cl_unstable_count);
+	LASSERT(unstable_count >= 0);
+
+	unstable_count = atomic_sub_return(page_count,
+					   &cli->cl_cache->ccc_unstable_nr);
+	LASSERT(unstable_count >= 0);
+	if (!unstable_count)
+		wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
+
+	if (osc_cache_too_much(cli))
+		(void)ptlrpcd_queue_work(cli->cl_lru_work);
+}
+
+/**
+ * "unstable" page accounting. See: osc_dec_unstable_pages.
+ */
+void osc_inc_unstable_pages(struct ptlrpc_request *req)
+{
+	struct client_obd *cli  = &req->rq_import->imp_obd->u.cli;
+	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
+	int page_count = desc->bd_iov_count;
+
+	/* No unstable page tracking */
+	if (!cli->cl_cache || !cli->cl_cache->ccc_unstable_check)
+		return;
+
+	add_unstable_page_accounting(desc);
+	atomic_add(page_count, &cli->cl_unstable_count);
+	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
+
+	/*
+	 * If the request has already been committed (i.e. brw_commit
+	 * called via rq_commit_cb), we need to undo the unstable page
+	 * increments we just performed because rq_commit_cb wont be
+	 * called again.
+	 */
+	spin_lock(&req->rq_lock);
+	if (unlikely(req->rq_committed)) {
+		spin_unlock(&req->rq_lock);
+
+		osc_dec_unstable_pages(req);
+	} else {
+		req->rq_unstable = 1;
+		spin_unlock(&req->rq_lock);
+	}
+}
+
+/**
+ * Check if it piggybacks SOFT_SYNC flag to OST from this OSC.
+ * This function will be called by every BRW RPC so it's critical
+ * to make this function fast.
+ */
+bool osc_over_unstable_soft_limit(struct client_obd *cli)
+{
+	long unstable_nr, osc_unstable_count;
+
+	/* Can't check cli->cl_unstable_count, therefore, no soft limit */
+	if (!cli->cl_cache || !cli->cl_cache->ccc_unstable_check)
+		return false;
+
+	osc_unstable_count = atomic_read(&cli->cl_unstable_count);
+	unstable_nr = atomic_read(&cli->cl_cache->ccc_unstable_nr);
+
+	CDEBUG(D_CACHE,
+	       "%s: cli: %p unstable pages: %lu, osc unstable pages: %lu\n",
+	       cli->cl_import->imp_obd->obd_name, cli,
+	       unstable_nr, osc_unstable_count);
+
+	/*
+	 * If the LRU slots are in shortage - 25% remaining AND this OSC
+	 * has one full RPC window of unstable pages, it's a good chance
+	 * to piggyback a SOFT_SYNC flag.
+	 * Please notice that the OST won't take immediate response for the
+	 * SOFT_SYNC request so active OSCs will have more chance to carry
+	 * the flag, this is reasonable.
+	 */
+	return unstable_nr > cli->cl_cache->ccc_lru_max >> 2 &&
+	       osc_unstable_count > cli->cl_max_pages_per_rpc *
+				    cli->cl_max_rpcs_in_flight;
+}
+
 /** @} osc */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 042a081..e5669e2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -807,17 +807,15 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		CERROR("dirty %lu - %lu > dirty_max %lu\n",
 		       cli->cl_dirty, cli->cl_dirty_transit, cli->cl_dirty_max);
 		oa->o_undirty = 0;
-	} else if (unlikely(atomic_read(&obd_unstable_pages) +
-			    atomic_read(&obd_dirty_pages) -
+	} else if (unlikely(atomic_read(&obd_dirty_pages) -
 			    atomic_read(&obd_dirty_transit_pages) >
 			    (long)(obd_max_dirty_pages + 1))) {
 		/* The atomic_read() allowing the atomic_inc() are
 		 * not covered by a lock thus they may safely race and trip
 		 * this CERROR() unless we add in a small fudge factor (+1).
 		 */
-		CERROR("%s: dirty %d + %d - %d > system dirty_max %d\n",
+		CERROR("%s: dirty %d + %d > system dirty_max %d\n",
 		       cli->cl_import->imp_obd->obd_name,
-		       atomic_read(&obd_unstable_pages),
 		       atomic_read(&obd_dirty_pages),
 		       atomic_read(&obd_dirty_transit_pages),
 		       obd_max_dirty_pages);
@@ -1818,6 +1816,9 @@ static int brw_interpret(const struct lu_env *env,
 	}
 	kmem_cache_free(obdo_cachep, aa->aa_oa);
 
+	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE && rc == 0)
+		osc_inc_unstable_pages(req);
+
 	list_for_each_entry_safe(ext, tmp, &aa->aa_exts, oe_link) {
 		list_del_init(&ext->oe_link);
 		osc_extent_finish(env, ext, 1, rc);
@@ -1888,6 +1889,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	int mpflag = 0;
 	int mem_tight = 0;
 	int page_count = 0;
+	bool soft_sync = false;
 	int i;
 	int rc;
 	struct ost_body *body;
@@ -1915,6 +1917,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		}
 	}
 
+	soft_sync = osc_over_unstable_soft_limit(cli);
 	if (mem_tight)
 		mpflag = cfs_memory_pressure_get_and_set();
 
@@ -1950,6 +1953,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		}
 		if (mem_tight)
 			oap->oap_brw_flags |= OBD_BRW_MEMALLOC;
+		if (soft_sync)
+			oap->oap_brw_flags |= OBD_BRW_SOFT_SYNC;
 		pga[i] = &oap->oap_brw_page;
 		pga[i]->off = oap->oap_obj_off + oap->oap_page_off;
 		CDEBUG(0, "put page %p index %lu oap %p flg %x to pga\n",
-- 
1.7.1
