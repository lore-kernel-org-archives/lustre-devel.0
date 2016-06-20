From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:16 -0400
Subject: [lustre-devel] [PATCH 01/28] staging/lustre/llite: allocate and
	free client cache asynchronously
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Emoly Liu <emoly.liu@intel.com>

Since the inflight request holds import refcount as well as export,
sometimes obd_disconnect() in client_common_put_super() can't put
the last refcount of OSC import (e.g. due to network disconnection),
this will cause cl_cache being accessed after free.

To fix this issue, ccc_users is used as cl_cache refcount, and
lov/llite/osc all hold one cl_cache refcount respectively, to avoid
the race that a new OST is being added into the system when the client
is mounted.
The following cl_cache functions are added:
- cl_cache_init(): allocate and initialize cl_cache
- cl_cache_incref(): increase cl_cache refcount
- cl_cache_decref(): decrease cl_cache refcount and free the cache
  if refcount=0.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-on: http://review.whamcloud.com/13746
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6173
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h  | 10 ++++-
 drivers/staging/lustre/lustre/include/obd.h        |  2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 35 +++++++---------
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  6 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  7 ++++
 drivers/staging/lustre/lustre/obdclass/cl_page.c   | 46 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_page.c       |  4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  4 +-
 9 files changed, 86 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 36ca935..3cd4a25 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2322,7 +2322,8 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
  */
 struct cl_client_cache {
 	/**
-	 * # of users (OSCs)
+	 * # of client cache refcount
+	 * # of users (OSCs) + 2 (held by llite and lov)
 	 */
 	atomic_t		ccc_users;
 	/**
@@ -2357,6 +2358,13 @@ struct cl_client_cache {
 
 };
 
+/**
+ * cl_cache functions
+ */
+struct cl_client_cache *cl_cache_init(unsigned long lru_page_max);
+void cl_cache_incref(struct cl_client_cache *cache);
+void cl_cache_decref(struct cl_client_cache *cache);
+
 /** @} cl_page */
 
 /** \defgroup cl_lock cl_lock
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e654d42..ed1081a 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -415,7 +415,7 @@ struct lov_obd {
 	enum lustre_sec_part    lov_sp_me;
 
 	/* Cached LRU and unstable data from upper layer */
-	void		       *lov_cache;
+	struct cl_client_cache *lov_cache;
 
 	struct rw_semaphore     lov_notify_lock;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 7c1a3254..74cd241 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -493,7 +493,7 @@ struct ll_sb_info {
 	 * any page which is sent to a server as part of a bulk request,
 	 * but is uncommitted to stable storage.
 	 */
-	struct cl_client_cache    ll_cache;
+	struct cl_client_cache    *ll_cache;
 
 	struct lprocfs_stats     *ll_ra_stats;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ac833db..83f4e1a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -83,15 +83,11 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	pages = si.totalram - si.totalhigh;
 	lru_page_max = pages / 2;
 
-	/* initialize ll_cache data */
-	atomic_set(&sbi->ll_cache.ccc_users, 0);
-	sbi->ll_cache.ccc_lru_max = lru_page_max;
-	atomic_set(&sbi->ll_cache.ccc_lru_left, lru_page_max);
-	spin_lock_init(&sbi->ll_cache.ccc_lru_lock);
-	INIT_LIST_HEAD(&sbi->ll_cache.ccc_lru);
-
-	atomic_set(&sbi->ll_cache.ccc_unstable_nr, 0);
-	init_waitqueue_head(&sbi->ll_cache.ccc_unstable_waitq);
+	sbi->ll_cache = cl_cache_init(lru_page_max);
+	if (!sbi->ll_cache) {
+		kfree(sbi);
+		return NULL;
+	}
 
 	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
 					   SBI_DEFAULT_READAHEAD_MAX);
@@ -131,6 +127,11 @@ static void ll_free_sbi(struct super_block *sb)
 {
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 
+	if (sbi->ll_cache) {
+		cl_cache_decref(sbi->ll_cache);
+		sbi->ll_cache = NULL;
+	}
+
 	kfree(sbi);
 }
 
@@ -514,8 +515,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	cl_sb_init(sb);
 
 	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CACHE_SET),
-				 KEY_CACHE_SET, sizeof(sbi->ll_cache),
-				 &sbi->ll_cache, NULL);
+				 KEY_CACHE_SET, sizeof(*sbi->ll_cache),
+				 sbi->ll_cache, NULL);
 
 	sb->s_root = d_make_root(root);
 	if (!sb->s_root) {
@@ -560,8 +561,6 @@ out_lock_cn_cb:
 out_dt:
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
-	/* Make sure all OScs are gone, since cl_cache is accessing sbi. */
-	obd_zombie_barrier();
 out_md_fid:
 	obd_fid_fini(sbi->ll_md_exp->exp_obd);
 out_md:
@@ -618,10 +617,6 @@ static void client_common_put_super(struct super_block *sb)
 	obd_fid_fini(sbi->ll_dt_exp->exp_obd);
 	obd_disconnect(sbi->ll_dt_exp);
 	sbi->ll_dt_exp = NULL;
-	/* wait till all OSCs are gone, since cl_cache is accessing sbi.
-	 * see LU-2543.
-	 */
-	obd_zombie_barrier();
 
 	ldebugfs_unregister_mountpoint(sbi);
 
@@ -962,12 +957,12 @@ void ll_put_super(struct super_block *sb)
 	if (!force) {
 		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 
-		rc = l_wait_event(sbi->ll_cache.ccc_unstable_waitq,
-				  !atomic_read(&sbi->ll_cache.ccc_unstable_nr),
+		rc = l_wait_event(sbi->ll_cache->ccc_unstable_waitq,
+				  !atomic_read(&sbi->ll_cache->ccc_unstable_nr),
 				  &lwi);
 	}
 
-	ccc_count = atomic_read(&sbi->ll_cache.ccc_unstable_nr);
+	ccc_count = atomic_read(&sbi->ll_cache->ccc_unstable_nr);
 	if (!force && rc != -EINTR)
 		LASSERTF(!ccc_count, "count: %i\n", ccc_count);
 
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 6e9a8a5..1f00bce 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -360,7 +360,7 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 {
 	struct super_block     *sb    = m->private;
 	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
-	struct cl_client_cache *cache = &sbi->ll_cache;
+	struct cl_client_cache *cache = sbi->ll_cache;
 	int shift = 20 - PAGE_SHIFT;
 	int max_cached_mb;
 	int unused_mb;
@@ -387,7 +387,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 {
 	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
-	struct cl_client_cache *cache = &sbi->ll_cache;
+	struct cl_client_cache *cache = sbi->ll_cache;
 	struct lu_env *env;
 	int refcheck;
 	int mult, rc, pages_number;
@@ -826,7 +826,7 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kobj);
-	struct cl_client_cache *cache = &sbi->ll_cache;
+	struct cl_client_cache *cache = sbi->ll_cache;
 	int pages, mb;
 
 	pages = atomic_read(&cache->ccc_unstable_nr);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index c87096e..9b92d55 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -892,6 +892,12 @@ static int lov_cleanup(struct obd_device *obd)
 		kfree(lov->lov_tgts);
 		lov->lov_tgt_size = 0;
 	}
+
+	if (lov->lov_cache) {
+		cl_cache_decref(lov->lov_cache);
+		lov->lov_cache = NULL;
+	}
+
 	return 0;
 }
 
@@ -2121,6 +2127,7 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		LASSERT(!lov->lov_cache);
 		lov->lov_cache = val;
 		do_inactive = 1;
+		cl_cache_incref(lov->lov_cache);
 	}
 
 	for (i = 0; i < count; i++, val = (char *)val + incr) {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 71bff49..db2dc6b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1072,3 +1072,49 @@ void cl_page_slice_add(struct cl_page *page, struct cl_page_slice *slice,
 	slice->cpl_page = page;
 }
 EXPORT_SYMBOL(cl_page_slice_add);
+
+/**
+ * Allocate and initialize cl_cache, called by ll_init_sbi().
+ */
+struct cl_client_cache *cl_cache_init(unsigned long lru_page_max)
+{
+	struct cl_client_cache	*cache = NULL;
+
+	cache = kzalloc(sizeof(*cache), GFP_KERNEL);
+	if (!cache)
+		return NULL;
+
+	/* Initialize cache data */
+	atomic_set(&cache->ccc_users, 1);
+	cache->ccc_lru_max = lru_page_max;
+	atomic_set(&cache->ccc_lru_left, lru_page_max);
+	spin_lock_init(&cache->ccc_lru_lock);
+	INIT_LIST_HEAD(&cache->ccc_lru);
+
+	atomic_set(&cache->ccc_unstable_nr, 0);
+	init_waitqueue_head(&cache->ccc_unstable_waitq);
+
+	return cache;
+}
+EXPORT_SYMBOL(cl_cache_init);
+
+/**
+ * Increase cl_cache refcount
+ */
+void cl_cache_incref(struct cl_client_cache *cache)
+{
+	atomic_inc(&cache->ccc_users);
+}
+EXPORT_SYMBOL(cl_cache_incref);
+
+/**
+ * Decrease cl_cache refcount and free the cache if refcount=0.
+ * Since llite, lov and osc all hold cl_cache refcount,
+ * the free will not cause race. (LU-6173)
+ */
+void cl_cache_decref(struct cl_client_cache *cache)
+{
+	if (atomic_dec_and_test(&cache->ccc_users))
+		kfree(cache);
+}
+EXPORT_SYMBOL(cl_cache_decref);
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 57d8a5a..c1aa11e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -414,7 +414,7 @@ static int osc_cache_too_much(struct client_obd *cli)
 	int pages = atomic_read(&cli->cl_lru_in_list);
 	unsigned long budget;
 
-	budget = cache->ccc_lru_max / atomic_read(&cache->ccc_users);
+	budget = cache->ccc_lru_max / (atomic_read(&cache->ccc_users) - 2);
 
 	/* if it's going to run out LRU slots, we should free some, but not
 	 * too much to maintain fairness among OSCs.
@@ -714,7 +714,7 @@ int osc_lru_reclaim(struct client_obd *cli)
 	cache->ccc_lru_shrinkers++;
 	list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
 
-	max_scans = atomic_read(&cache->ccc_users);
+	max_scans = atomic_read(&cache->ccc_users) - 2;
 	while (--max_scans > 0 && !list_empty(&cache->ccc_lru)) {
 		cli = list_entry(cache->ccc_lru.next, struct client_obd,
 				 cl_lru_osc);
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7260027..9334349 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2913,7 +2913,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 		LASSERT(!cli->cl_cache); /* only once */
 		cli->cl_cache = val;
-		atomic_inc(&cli->cl_cache->ccc_users);
+		cl_cache_incref(cli->cl_cache);
 		cli->cl_lru_left = &cli->cl_cache->ccc_lru_left;
 
 		/* add this osc into entity list */
@@ -3293,7 +3293,7 @@ static int osc_cleanup(struct obd_device *obd)
 		list_del_init(&cli->cl_lru_osc);
 		spin_unlock(&cli->cl_cache->ccc_lru_lock);
 		cli->cl_lru_left = NULL;
-		atomic_dec(&cli->cl_cache->ccc_users);
+		cl_cache_decref(cli->cl_cache);
 		cli->cl_cache = NULL;
 	}
 
-- 
2.7.4
