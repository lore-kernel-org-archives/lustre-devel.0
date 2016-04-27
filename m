From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:04 -0400
Subject: [lustre-devel] [PATCH 12/15] staging: lustre: osc: Track and limit
	"unstable" pages
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Prakash Surya <surya1@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Prakash Surya <surya1@llnl.gov>

This change adds a global counter to track the number of "unstable"
pages held by a given client, along with per file system counters. An
"unstable" page is defined as a page which has been sent to the server
as part of a bulk request, but is uncommitted to stable storage.

In addition to simply tracking the unstable pages, they now also count
towards the maximum number of "pinned" pages on the system at any given
time. Thus, a client will now be bound on the number of dirty and
unstable pages it can pin in memory. Previously only dirty pages were
accounted for in this limit.

In addition to tracking the number of unstable pages in Lustre, the
NR_UNSTABLE_NFS memory zone is also incremented and decremented for
easy monitoring using the "NFS_Unstable:" field in /proc/meminfo.
This field is also used internally by the kernel to limit the total
amount of unstable pages on the system.

The motivation for this change is twofold. First, the client must not
allow itself to disconnect from an OST while still holding unstable
pages. Otherwise, these unstable pages can get lost due to an OST
failure, and replay is not possible due to the disconnect via unmount.

Secondly, the client needs a mechanism to prevent it from allocating too
much of its available RAM to unreclaimable pages pinned by the ptlrpc
layer. If this case occurs, out of memory events can trigger as a side
effect, which we need to avoid.

The current number of unstable pages accounted for on a per file system
granularity is exported by the unstable_stats proc file, contained under
each file system's llite namespace. An example of retrieving this
information is below:

	$ lctl get_param llite.*.unstable_stats

Signed-off-by: Prakash Surya <surya1@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2139
Reviewed-on: http://review.whamcloud.com/6284
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |   10 ++
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 .../staging/lustre/lustre/include/obd_support.h    |    1 +
 .../staging/lustre/lustre/llite/llite_internal.h   |    6 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   20 ++++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   18 ++++
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   99 +++++++++++++++++++-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    3 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |   28 +++++-
 11 files changed, 182 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 918be65..587a236 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2351,6 +2351,16 @@ struct cl_client_cache {
 	 * Lock to protect ccc_lru list
 	 */
 	spinlock_t		ccc_lru_lock;
+	/**
+	 * # of unstable pages for this mount point
+	 */
+	atomic_t		ccc_unstable_nr;
+	/**
+	 * Waitq for awaiting unstable pages to reach zero.
+	 * Used at umounting time and signaled on BRW commit
+	 */
+        wait_queue_head_t	ccc_unstable_waitq;
+
 };
 
 /** @} cl_page */
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 69586a5..a7973d5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1327,7 +1327,9 @@ struct ptlrpc_request {
 		/* allow the req to be sent if the import is in recovery
 		 * status
 		 */
-		rq_allow_replay:1;
+		rq_allow_replay:1,
+		/* bulk request, sent to server, but uncommitted */
+		rq_unstable:1;
 
 	unsigned int rq_nr_resend;
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e97e25b..3f24a5b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -477,7 +477,7 @@ struct lov_obd {
 	struct dentry		*lov_pool_debugfs_entry;
 	enum lustre_sec_part    lov_sp_me;
 
-	/* Cached LRU pages from upper layer */
+	/* Cached LRU and unstable data from upper layer */
 	void		       *lov_cache;
 
 	struct rw_semaphore     lov_notify_lock;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index f8ee3a3..c7267b7 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -58,6 +58,7 @@ extern int at_early_margin;
 extern int at_extra;
 extern unsigned int obd_sync_filter;
 extern unsigned int obd_max_dirty_pages;
+extern atomic_t obd_unstable_pages;
 extern atomic_t obd_dirty_pages;
 extern atomic_t obd_dirty_transit_pages;
 extern char obd_jobid_var[];
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 2c6ae05..59e8ab1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -491,6 +491,12 @@ struct ll_sb_info {
 
 	struct lprocfs_stats     *ll_stats; /* lprocfs stats counter */
 
+	/*
+	 * Used to track "unstable" pages on a client, and maintain a
+	 * LRU list of clean pages. An "unstable" page is defined as
+	 * any page which is sent to a server as part of a bulk request,
+	 * but is uncommitted to stable storage.
+	 */
 	struct cl_client_cache    ll_cache;
 
 	struct lprocfs_stats     *ll_ra_stats;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 55cddc7..8d88d4c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -87,13 +87,16 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	pages = si.totalram - si.totalhigh;
 	lru_page_max = pages / 2;
 
-	/* initialize lru data */
+	/* initialize ll_cache data */
 	atomic_set(&sbi->ll_cache.ccc_users, 0);
 	sbi->ll_cache.ccc_lru_max = lru_page_max;
 	atomic_set(&sbi->ll_cache.ccc_lru_left, lru_page_max);
 	spin_lock_init(&sbi->ll_cache.ccc_lru_lock);
 	INIT_LIST_HEAD(&sbi->ll_cache.ccc_lru);
 
+	atomic_set(&sbi->ll_cache.ccc_unstable_nr, 0);
+	init_waitqueue_head(&sbi->ll_cache.ccc_unstable_waitq);
+
 	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
 					   SBI_DEFAULT_READAHEAD_MAX);
 	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
@@ -946,7 +949,7 @@ void ll_put_super(struct super_block *sb)
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char *profilenm = get_profile_name(sb);
-	int next, force = 1;
+	int ccc_count, next, force = 1, rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p - %s\n", sb, profilenm);
 
@@ -962,6 +965,19 @@ void ll_put_super(struct super_block *sb)
 			force = obd->obd_force;
 	}
 
+	/* Wait for unstable pages to be committed to stable storage */
+	if (!force) {
+		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
+
+		rc = l_wait_event(sbi->ll_cache.ccc_unstable_waitq,
+				  !atomic_read(&sbi->ll_cache.ccc_unstable_nr),
+				  &lwi);
+	}
+
+	ccc_count = atomic_read(&sbi->ll_cache.ccc_unstable_nr);
+	if (!force && rc != -EINTR)
+		LASSERTF(!ccc_count, "count: %i\n", ccc_count);
+
 	/* We need to set force before the lov_disconnect in
 	 * lustre_common_put_super, since l_d cleans up osc's as well.
 	 */
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 501b93b..55d62eb 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -824,6 +824,23 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(xattr_cache);
 
+static ssize_t unstable_stats_show(struct kobject *kobj,
+				   struct attribute *attr,
+				   char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+	struct cl_client_cache *cache = &sbi->ll_cache;
+	int pages, mb;
+
+	pages = atomic_read(&cache->ccc_unstable_nr);
+	mb = (pages * PAGE_SIZE) >> 20;
+
+	return sprintf(buf, "unstable_pages: %8d\n"
+			    "unstable_mb:    %8d\n", pages, mb);
+}
+LUSTRE_RO_ATTR(unstable_stats);
+
 static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	/* { "mntpt_path",   ll_rd_path,	     0, 0 }, */
 	{ "site",	  &ll_site_stats_fops,    NULL, 0 },
@@ -859,6 +876,7 @@ static struct attribute *llite_attrs[] = {
 	&lustre_attr_max_easize.attr,
 	&lustre_attr_default_easize.attr,
 	&lustre_attr_xattr_cache.attr,
+	&lustre_attr_unstable_stats.attr,
 	NULL,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index a3c7e7b..f48816a 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -60,6 +60,8 @@ unsigned int obd_dump_on_eviction;
 EXPORT_SYMBOL(obd_dump_on_eviction);
 unsigned int obd_max_dirty_pages = 256;
 EXPORT_SYMBOL(obd_max_dirty_pages);
+atomic_t obd_unstable_pages;
+EXPORT_SYMBOL(obd_unstable_pages);
 atomic_t obd_dirty_pages;
 EXPORT_SYMBOL(obd_dirty_pages);
 unsigned int obd_timeout = OBD_TIMEOUT_DEFAULT;   /* seconds */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index de28e42..5cd8eef 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1388,11 +1388,13 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 #define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			      \
 	struct client_obd *__tmp = (cli);				      \
 	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %d/%d "	      \
-	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d } "	      \
-	       "lru {in list: %d, left: %d, waiters: %d }" fmt,		      \
+	       "unstable_pages: %d/%d dropped: %ld avail: %ld, "	      \
+	       "reserved: %ld, flight: %d } lru {in list: %d, "		      \
+	       "left: %d, waiters: %d }" fmt,                                 \
 	       __tmp->cl_import->imp_obd->obd_name,			      \
 	       __tmp->cl_dirty, __tmp->cl_dirty_max,			      \
 	       atomic_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
+	       atomic_read(&obd_unstable_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
 	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		      \
 	       atomic_read(&__tmp->cl_lru_in_list),			      \
@@ -1544,7 +1546,8 @@ static int osc_enter_cache_try(struct client_obd *cli,
 		return 0;
 
 	if (cli->cl_dirty + PAGE_SIZE <= cli->cl_dirty_max &&
-	    atomic_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
+	    atomic_read(&obd_unstable_pages) + 1 +
+	    atomic_read(&obd_dirty_pages) <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
 		if (transient) {
 			cli->cl_dirty_transit += PAGE_SIZE;
@@ -1672,8 +1675,8 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 		ocw->ocw_rc = -EDQUOT;
 		/* we can't dirty more */
 		if ((cli->cl_dirty + PAGE_SIZE > cli->cl_dirty_max) ||
-		    (atomic_read(&obd_dirty_pages) + 1 >
-		     obd_max_dirty_pages)) {
+		    (atomic_read(&obd_unstable_pages) + 1 +
+		     atomic_read(&obd_dirty_pages) > obd_max_dirty_pages)) {
 			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %d\n",
 			       cli->cl_dirty,
 			       cli->cl_dirty_max, obd_max_dirty_pages);
@@ -1844,6 +1847,89 @@ static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
 		ar->ar_force_sync = 0;
 }
 
+/**
+ * Performs "unstable" page accounting. This function balances the
+ * increment operations performed in osc_inc_unstable_pages. It is
+ * registered as the RPC request callback, and is executed when the
+ * bulk RPC is committed on the server. Thus at this point, the pages
+ * involved in the bulk transfer are no longer considered unstable.
+ */
+void osc_dec_unstable_pages(struct ptlrpc_request *req)
+{
+	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
+	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
+	int page_count = desc->bd_iov_count;
+	int i;
+
+	/* No unstable page tracking */
+	if (!cli->cl_cache)
+		return;
+
+	LASSERT(page_count >= 0);
+
+	for (i = 0; i < page_count; i++)
+		dec_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
+
+	atomic_sub(page_count, &cli->cl_cache->ccc_unstable_nr);
+	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
+
+	atomic_sub(page_count, &obd_unstable_pages);
+	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
+
+	spin_lock(&req->rq_lock);
+	req->rq_committed = 1;
+	req->rq_unstable  = 0;
+	spin_unlock(&req->rq_lock);
+
+	wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
+}
+
+/* "unstable" page accounting. See: osc_dec_unstable_pages. */
+void osc_inc_unstable_pages(struct ptlrpc_request *req)
+{
+	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
+	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
+	long page_count = desc->bd_iov_count;
+	int i;
+
+	/* No unstable page tracking */
+	if (!cli->cl_cache)
+		return;
+
+	LASSERT(page_count >= 0);
+
+	for (i = 0; i < page_count; i++)
+		inc_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
+
+	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
+	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
+
+	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
+	atomic_add(page_count, &obd_unstable_pages);
+
+	spin_lock(&req->rq_lock);
+
+	/*
+	 * If the request has already been committed (i.e. brw_commit
+	 * called via rq_commit_cb), we need to undo the unstable page
+	 * increments we just performed because rq_commit_cb wont be
+	 * called again. Otherwise, just set the commit callback so the
+	 * unstable page accounting is properly updated when the request
+	 * is committed
+	 */
+	if (req->rq_committed) {
+		/* Drop lock before calling osc_dec_unstable_pages */
+		spin_unlock(&req->rq_lock);
+		osc_dec_unstable_pages(req);
+		spin_lock(&req->rq_lock);
+	} else {
+		req->rq_unstable = 1;
+		req->rq_commit_cb = osc_dec_unstable_pages;
+	}
+
+	spin_unlock(&req->rq_lock);
+}
+
 /* this must be called holding the loi list lock to give coverage to exit_cache,
  * async_flag maintenance, and oap_request
  */
@@ -1855,6 +1941,9 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 	__u64 xid = 0;
 
 	if (oap->oap_request) {
+		if (!rc)
+			osc_inc_unstable_pages(oap->oap_request);
+
 		xid = ptlrpc_req_xid(oap->oap_request);
 		ptlrpc_req_finished(oap->oap_request);
 		oap->oap_request = NULL;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index cf9f8b7..39e6138 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -200,6 +200,9 @@ int osc_quotactl(struct obd_device *unused, struct obd_export *exp,
 int osc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 		   struct obd_quotactl *oqctl);
 int osc_quota_poll_check(struct obd_export *exp, struct if_quotacheck *qchk);
+void osc_inc_unstable_pages(struct ptlrpc_request *req);
+void osc_dec_unstable_pages(struct ptlrpc_request *req);
+
 struct ldlm_lock *osc_dlmlock_at_pgoff(const struct lu_env *env,
 				       struct osc_object *obj, pgoff_t index,
 				       int pending, int canceling);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e5794fb..e8a80eb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -809,14 +809,17 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		CERROR("dirty %lu - %lu > dirty_max %lu\n",
 		       cli->cl_dirty, cli->cl_dirty_transit, cli->cl_dirty_max);
 		oa->o_undirty = 0;
-	} else if (unlikely(atomic_read(&obd_dirty_pages) -
+	} else if (unlikely(atomic_read(&obd_unstable_pages) +
+			    atomic_read(&obd_dirty_pages) -
 			    atomic_read(&obd_dirty_transit_pages) >
 			    (long)(obd_max_dirty_pages + 1))) {
 		/* The atomic_read() allowing the atomic_inc() are
 		 * not covered by a lock thus they may safely race and trip
 		 * this CERROR() unless we add in a small fudge factor (+1).
 		 */
-		CERROR("dirty %d - %d > system dirty_max %d\n",
+		CERROR("%s: dirty %d + %d - %d > system dirty_max %d\n",
+		       cli->cl_import->imp_obd->obd_name,
+		       atomic_read(&obd_unstable_pages),
 		       atomic_read(&obd_dirty_pages),
 		       atomic_read(&obd_dirty_transit_pages),
 		       obd_max_dirty_pages);
@@ -1655,6 +1658,7 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	aa->aa_resends++;
 	new_req->rq_interpret_reply = request->rq_interpret_reply;
 	new_req->rq_async_args = request->rq_async_args;
+	new_req->rq_commit_cb = request->rq_commit_cb;
 	/* cap resend delay to the current request timeout, this is similar to
 	 * what ptlrpc does (see after_reply())
 	 */
@@ -1843,6 +1847,25 @@ static int brw_interpret(const struct lu_env *env,
 	return rc;
 }
 
+static void brw_commit(struct ptlrpc_request *req)
+{
+	spin_lock(&req->rq_lock);
+	/*
+	 * If osc_inc_unstable_pages (via osc_extent_finish) races with
+	 * this called via the rq_commit_cb, I need to ensure
+	 * osc_dec_unstable_pages is still called. Otherwise unstable
+	 * pages may be leaked.
+	 */
+	if (req->rq_unstable) {
+		spin_unlock(&req->rq_lock);
+		osc_dec_unstable_pages(req);
+		spin_lock(&req->rq_lock);
+	} else {
+		req->rq_committed = 1;
+	}
+	spin_unlock(&req->rq_lock);
+}
+
 /**
  * Build an RPC by the list of extent @ext_list. The caller must ensure
  * that the total pages in this list are NOT over max pages per RPC.
@@ -1962,6 +1985,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		goto out;
 	}
 
+	req->rq_commit_cb = brw_commit;
 	req->rq_interpret_reply = brw_interpret;
 
 	if (mem_tight != 0)
-- 
1.7.1
