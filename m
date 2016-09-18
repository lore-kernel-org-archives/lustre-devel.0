From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:43 -0400
Subject: [lustre-devel] [PATCH 044/124] staging: lustre: misc: Reduce
	exposure to overflow on page counters.
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Stephen Champion <schamp@sgi.com>, James Simmons <jsimmons@infradead.org>

From: Stephen Champion <schamp@sgi.com>

When the number of an object in use or circulation is tied to memory
size of the system, very large memory systems can overflow 32 bit
counters.  This patch addresses overflow on page counters in the osc LRU
and obd accounting.

Signed-off-by: Stephen Champion <schamp@sgi.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4856
Reviewed-on: http://review.whamcloud.com/10537
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    4 +-
 drivers/staging/lustre/lustre/include/obd.h        |    8 +-
 .../staging/lustre/lustre/include/obd_support.h    |    6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    6 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    9 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   50 +++++++-----
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    4 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    6 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |    3 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   31 ++++---
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   27 +++---
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   14 ++--
 drivers/staging/lustre/lustre/osc/osc_page.c       |   88 +++++++++----------
 drivers/staging/lustre/lustre/osc/osc_request.c    |   18 ++--
 15 files changed, 146 insertions(+), 134 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 41e0801..5039643 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2326,7 +2326,7 @@ struct cl_client_cache {
 	/**
 	 * # of LRU entries available
 	 */
-	atomic_t		ccc_lru_left;
+	atomic_long_t		ccc_lru_left;
 	/**
 	 * List of entities(OSCs) for this LRU cache
 	 */
@@ -2346,7 +2346,7 @@ struct cl_client_cache {
 	/**
 	 * # of unstable pages for this mount point
 	 */
-	atomic_t		ccc_unstable_nr;
+	atomic_long_t		ccc_unstable_nr;
 	/**
 	 * Waitq for awaiting unstable pages to reach zero.
 	 * Used at umounting time and signaled on BRW commit
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 27fb4d7..3fbb873 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -293,13 +293,13 @@ struct client_obd {
 	/* lru for osc caching pages */
 	struct cl_client_cache	*cl_cache;
 	struct list_head	 cl_lru_osc; /* member of cl_cache->ccc_lru */
-	atomic_t		*cl_lru_left;
-	atomic_t		 cl_lru_busy;
+	atomic_long_t		*cl_lru_left;
+	atomic_long_t		 cl_lru_busy;
+	atomic_long_t		 cl_lru_in_list;
 	atomic_t		 cl_lru_shrinkers;
-	atomic_t		 cl_lru_in_list;
 	struct list_head	 cl_lru_list; /* lru page list */
 	spinlock_t		 cl_lru_list_lock; /* page list protector */
-	atomic_t		 cl_unstable_count;
+	atomic_long_t		 cl_unstable_count;
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
 	atomic_t	     cl_destroy_in_flight;
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 4d7a5c8..d4c41d0 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -52,9 +52,9 @@ extern unsigned int at_max;
 extern unsigned int at_history;
 extern int at_early_margin;
 extern int at_extra;
-extern unsigned int obd_max_dirty_pages;
-extern atomic_t obd_dirty_pages;
-extern atomic_t obd_dirty_transit_pages;
+extern unsigned long obd_max_dirty_pages;
+extern atomic_long_t obd_dirty_pages;
+extern atomic_long_t obd_dirty_transit_pages;
 extern char obd_jobid_var[];
 
 /* Some hash init argument constants */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 0d466e2..9a5f56a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -328,11 +328,11 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	/* lru for osc. */
 	INIT_LIST_HEAD(&cli->cl_lru_osc);
 	atomic_set(&cli->cl_lru_shrinkers, 0);
-	atomic_set(&cli->cl_lru_busy, 0);
-	atomic_set(&cli->cl_lru_in_list, 0);
+	atomic_long_set(&cli->cl_lru_busy, 0);
+	atomic_long_set(&cli->cl_lru_in_list, 0);
 	INIT_LIST_HEAD(&cli->cl_lru_list);
 	spin_lock_init(&cli->cl_lru_list_lock);
-	atomic_set(&cli->cl_unstable_count, 0);
+	atomic_long_set(&cli->cl_unstable_count, 0);
 
 	init_waitqueue_head(&cli->cl_destroy_waitq);
 	atomic_set(&cli->cl_destroy_in_flight, 0);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 19d18e8..2aab396 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -926,7 +926,8 @@ void ll_put_super(struct super_block *sb)
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char *profilenm = get_profile_name(sb);
-	int ccc_count, next, force = 1, rc = 0;
+	int next, force = 1, rc = 0;
+	long ccc_count;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p - %s\n", sb, profilenm);
 
@@ -947,13 +948,13 @@ void ll_put_super(struct super_block *sb)
 		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 
 		rc = l_wait_event(sbi->ll_cache->ccc_unstable_waitq,
-				  !atomic_read(&sbi->ll_cache->ccc_unstable_nr),
+				  !atomic_long_read(&sbi->ll_cache->ccc_unstable_nr),
 				  &lwi);
 	}
 
-	ccc_count = atomic_read(&sbi->ll_cache->ccc_unstable_nr);
+	ccc_count = atomic_long_read(&sbi->ll_cache->ccc_unstable_nr);
 	if (!force && rc != -EINTR)
-		LASSERTF(!ccc_count, "count: %i\n", ccc_count);
+		LASSERTF(!ccc_count, "count: %li\n", ccc_count);
 
 	/* We need to set force before the lov_disconnect in
 	 * lustre_common_put_super, since l_d cleans up osc's as well.
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 6123435..188fd37 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -357,16 +357,16 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 	struct ll_sb_info      *sbi   = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	int shift = 20 - PAGE_SHIFT;
-	int max_cached_mb;
-	int unused_mb;
+	long max_cached_mb;
+	long unused_mb;
 
 	max_cached_mb = cache->ccc_lru_max >> shift;
-	unused_mb = atomic_read(&cache->ccc_lru_left) >> shift;
+	unused_mb = atomic_long_read(&cache->ccc_lru_left) >> shift;
 	seq_printf(m,
 		   "users: %d\n"
-		   "max_cached_mb: %d\n"
-		   "used_mb: %d\n"
-		   "unused_mb: %d\n"
+		   "max_cached_mb: %ld\n"
+		   "used_mb: %ld\n"
+		   "unused_mb: %ld\n"
 		   "reclaim_count: %u\n",
 		   atomic_read(&cache->ccc_users),
 		   max_cached_mb,
@@ -384,10 +384,13 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	struct lu_env *env;
+	long diff = 0;
+	long nrpages = 0;
 	int refcheck;
-	int mult, rc, pages_number;
-	int diff = 0;
-	int nrpages = 0;
+	long pages_number;
+	int mult;
+	long rc;
+	u64 val;
 	char kernbuf[128];
 
 	if (count >= sizeof(kernbuf))
@@ -400,10 +403,14 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 	mult = 1 << (20 - PAGE_SHIFT);
 	buffer += lprocfs_find_named_value(kernbuf, "max_cached_mb:", &count) -
 		  kernbuf;
-	rc = lprocfs_write_frac_helper(buffer, count, &pages_number, mult);
+	rc = lprocfs_write_frac_u64_helper(buffer, count, &val, mult);
 	if (rc)
 		return rc;
 
+	if (val > LONG_MAX)
+		return -ERANGE;
+	pages_number = (long)val;
+
 	if (pages_number < 0 || pages_number > totalram_pages) {
 		CERROR("%s: can't set max cache more than %lu MB\n",
 		       ll_get_fsname(sb, NULL, 0),
@@ -417,7 +424,7 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 
 	/* easy - add more LRU slots. */
 	if (diff >= 0) {
-		atomic_add(diff, &cache->ccc_lru_left);
+		atomic_long_add(diff, &cache->ccc_lru_left);
 		rc = 0;
 		goto out;
 	}
@@ -428,18 +435,18 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 
 	diff = -diff;
 	while (diff > 0) {
-		int tmp;
+		long tmp;
 
 		/* reduce LRU budget from free slots. */
 		do {
-			int ov, nv;
+			long ov, nv;
 
-			ov = atomic_read(&cache->ccc_lru_left);
+			ov = atomic_long_read(&cache->ccc_lru_left);
 			if (ov == 0)
 				break;
 
 			nv = ov > diff ? ov - diff : 0;
-			rc = atomic_cmpxchg(&cache->ccc_lru_left, ov, nv);
+			rc = atomic_long_cmpxchg(&cache->ccc_lru_left, ov, nv);
 			if (likely(ov == rc)) {
 				diff -= ov - nv;
 				nrpages += ov - nv;
@@ -473,7 +480,7 @@ out:
 		spin_unlock(&sbi->ll_lock);
 		rc = count;
 	} else {
-		atomic_add(nrpages, &cache->ccc_lru_left);
+		atomic_long_add(nrpages, &cache->ccc_lru_left);
 	}
 	return rc;
 }
@@ -822,14 +829,15 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kobj);
 	struct cl_client_cache *cache = sbi->ll_cache;
-	int pages, mb;
+	long pages;
+	int mb;
 
-	pages = atomic_read(&cache->ccc_unstable_nr);
+	pages = atomic_long_read(&cache->ccc_unstable_nr);
 	mb = (pages * PAGE_SIZE) >> 20;
 
-	return sprintf(buf, "unstable_check: %8d\n"
-			    "unstable_pages: %8d\n"
-			    "unstable_mb:    %8d\n",
+	return sprintf(buf, "unstable_check:     %8d\n"
+			    "unstable_pages: %12ld\n"
+			    "unstable_mb:        %8d\n",
 			    cache->ccc_unstable_check, pages, mb);
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index cae8d21..5c89dbd 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -1073,11 +1073,11 @@ struct cl_client_cache *cl_cache_init(unsigned long lru_page_max)
 	/* Initialize cache data */
 	atomic_set(&cache->ccc_users, 1);
 	cache->ccc_lru_max = lru_page_max;
-	atomic_set(&cache->ccc_lru_left, lru_page_max);
+	atomic_long_set(&cache->ccc_lru_left, lru_page_max);
 	spin_lock_init(&cache->ccc_lru_lock);
 	INIT_LIST_HEAD(&cache->ccc_lru);
 
-	atomic_set(&cache->ccc_unstable_nr, 0);
+	atomic_long_set(&cache->ccc_unstable_nr, 0);
 	init_waitqueue_head(&cache->ccc_unstable_waitq);
 
 	return cache;
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 2293f6a..629d8b5 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -55,9 +55,9 @@ unsigned int obd_dump_on_timeout;
 EXPORT_SYMBOL(obd_dump_on_timeout);
 unsigned int obd_dump_on_eviction;
 EXPORT_SYMBOL(obd_dump_on_eviction);
-unsigned int obd_max_dirty_pages = 256;
+unsigned long obd_max_dirty_pages;
 EXPORT_SYMBOL(obd_max_dirty_pages);
-atomic_t obd_dirty_pages;
+atomic_long_t obd_dirty_pages;
 EXPORT_SYMBOL(obd_dirty_pages);
 unsigned int obd_timeout = OBD_TIMEOUT_DEFAULT;   /* seconds */
 EXPORT_SYMBOL(obd_timeout);
@@ -75,7 +75,7 @@ EXPORT_SYMBOL(at_early_margin);
 int at_extra = 30;
 EXPORT_SYMBOL(at_extra);
 
-atomic_t obd_dirty_transit_pages;
+atomic_long_t obd_dirty_transit_pages;
 EXPORT_SYMBOL(obd_dirty_transit_pages);
 
 char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index aea1abd..e6c785a 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -97,8 +97,7 @@ static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
 {
 	return sprintf(buf, "%lu\n",
-		       (unsigned long)obd_max_dirty_pages /
-		       (1 << (20 - PAGE_SHIFT)));
+		       obd_max_dirty_pages / (1 << (20 - PAGE_SHIFT)));
 }
 
 static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 9172b78..f0062d4 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -182,11 +182,11 @@ static int osc_cached_mb_seq_show(struct seq_file *m, void *v)
 	int shift = 20 - PAGE_SHIFT;
 
 	seq_printf(m,
-		   "used_mb: %d\n"
-		   "busy_cnt: %d\n",
-		   (atomic_read(&cli->cl_lru_in_list) +
-		    atomic_read(&cli->cl_lru_busy)) >> shift,
-		   atomic_read(&cli->cl_lru_busy));
+		   "used_mb: %ld\n"
+		   "busy_cnt: %ld\n",
+		   (atomic_long_read(&cli->cl_lru_in_list) +
+		    atomic_long_read(&cli->cl_lru_busy)) >> shift,
+		   atomic_long_read(&cli->cl_lru_busy));
 
 	return 0;
 }
@@ -198,8 +198,10 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 {
 	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &dev->u.cli;
-	int pages_number, mult, rc;
+	long pages_number, rc;
 	char kernbuf[128];
+	int mult;
+	u64 val;
 
 	if (count >= sizeof(kernbuf))
 		return -EINVAL;
@@ -211,14 +213,18 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 	mult = 1 << (20 - PAGE_SHIFT);
 	buffer += lprocfs_find_named_value(kernbuf, "used_mb:", &count) -
 		  kernbuf;
-	rc = lprocfs_write_frac_helper(buffer, count, &pages_number, mult);
+	rc = lprocfs_write_frac_u64_helper(buffer, count, &val, mult);
 	if (rc)
 		return rc;
 
+	if (val > LONG_MAX)
+		return -ERANGE;
+	pages_number = (long)val;
+
 	if (pages_number < 0)
 		return -ERANGE;
 
-	rc = atomic_read(&cli->cl_lru_in_list) - pages_number;
+	rc = atomic_long_read(&cli->cl_lru_in_list) - pages_number;
 	if (rc > 0) {
 		struct lu_env *env;
 		int refcheck;
@@ -598,13 +604,14 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kobj);
 	struct client_obd *cli = &dev->u.cli;
-	int pages, mb;
+	long pages;
+	int mb;
 
-	pages = atomic_read(&cli->cl_unstable_count);
+	pages = atomic_long_read(&cli->cl_unstable_count);
 	mb = (pages * PAGE_SIZE) >> 20;
 
-	return sprintf(buf, "unstable_pages: %8d\n"
-		       "unstable_mb:    %8d\n", pages, mb);
+	return sprintf(buf, "unstable_pages: %20ld\n"
+		       "unstable_mb:              %10d\n", pages, mb);
 }
 LUSTRE_RO_ATTR(unstable_stats);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 97f936e..26ad360 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1383,16 +1383,16 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 
 #define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			      \
 	struct client_obd *__tmp = (cli);				      \
-	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %d/%d "	      \
+	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	      \
 	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
-	       "lru {in list: %d, left: %d, waiters: %d }" fmt,		      \
+	       "lru {in list: %ld, left: %ld, waiters: %d }" fmt,	      \
 	       __tmp->cl_import->imp_obd->obd_name,			      \
 	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
-	       atomic_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
+	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
 	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		      \
-	       atomic_read(&__tmp->cl_lru_in_list),			      \
-	       atomic_read(&__tmp->cl_lru_busy),			      \
+	       atomic_long_read(&__tmp->cl_lru_in_list),		      \
+	       atomic_long_read(&__tmp->cl_lru_busy),			      \
 	       atomic_read(&__tmp->cl_lru_shrinkers), ##args);		      \
 } while (0)
 
@@ -1402,7 +1402,7 @@ static void osc_consume_write_grant(struct client_obd *cli,
 {
 	assert_spin_locked(&cli->cl_loi_list_lock);
 	LASSERT(!(pga->flag & OBD_BRW_FROM_GRANT));
-	atomic_inc(&obd_dirty_pages);
+	atomic_long_inc(&obd_dirty_pages);
 	cli->cl_dirty_pages++;
 	pga->flag |= OBD_BRW_FROM_GRANT;
 	CDEBUG(D_CACHE, "using %lu grant credits for brw %p page %p\n",
@@ -1422,11 +1422,11 @@ static void osc_release_write_grant(struct client_obd *cli,
 	}
 
 	pga->flag &= ~OBD_BRW_FROM_GRANT;
-	atomic_dec(&obd_dirty_pages);
+	atomic_long_dec(&obd_dirty_pages);
 	cli->cl_dirty_pages--;
 	if (pga->flag & OBD_BRW_NOCACHE) {
 		pga->flag &= ~OBD_BRW_NOCACHE;
-		atomic_dec(&obd_dirty_transit_pages);
+		atomic_long_dec(&obd_dirty_transit_pages);
 		cli->cl_dirty_transit--;
 	}
 }
@@ -1495,7 +1495,7 @@ static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 	int grant = (1 << cli->cl_chunkbits) + cli->cl_extent_tax;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	atomic_sub(nr_pages, &obd_dirty_pages);
+	atomic_long_sub(nr_pages, &obd_dirty_pages);
 	cli->cl_dirty_pages -= nr_pages;
 	cli->cl_lost_grant += lost_grant;
 	if (cli->cl_avail_grant < grant && cli->cl_lost_grant >= grant) {
@@ -1540,11 +1540,11 @@ static int osc_enter_cache_try(struct client_obd *cli,
 		return 0;
 
 	if (cli->cl_dirty_pages <= cli->cl_dirty_max_pages &&
-	    atomic_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
+	    atomic_long_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
 		if (transient) {
 			cli->cl_dirty_transit++;
-			atomic_inc(&obd_dirty_transit_pages);
+			atomic_long_inc(&obd_dirty_transit_pages);
 			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
 		}
 		rc = 1;
@@ -1668,8 +1668,9 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 		ocw->ocw_rc = -EDQUOT;
 		/* we can't dirty more */
 		if ((cli->cl_dirty_pages > cli->cl_dirty_max_pages) ||
-		    (atomic_read(&obd_dirty_pages) + 1 > obd_max_dirty_pages)) {
-			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %d\n",
+		    (atomic_long_read(&obd_dirty_pages) + 1 >
+		     obd_max_dirty_pages)) {
+			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %ld\n",
 			       cli->cl_dirty_pages, cli->cl_dirty_max_pages,
 			       obd_max_dirty_pages);
 			goto wakeup;
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index eca5fef..67fe0a2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -133,9 +133,9 @@ int osc_sync_base(struct obd_export *exp, struct obd_info *oinfo,
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *cfg);
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
-int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
-		   int target, bool force);
-int osc_lru_reclaim(struct client_obd *cli);
+long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
+		    long target, bool force);
+long osc_lru_reclaim(struct client_obd *cli);
 
 unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index f6db60c..7698054 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -319,8 +319,8 @@ static int osc_io_rw_iter_init(const struct lu_env *env,
 	struct osc_object *osc = cl2osc(ios->cis_obj);
 	struct client_obd *cli = osc_cli(osc);
 	unsigned long c;
-	unsigned int npages;
-	unsigned int max_pages;
+	unsigned long npages;
+	unsigned long max_pages;
 
 	if (cl_io_is_append(io))
 		return 0;
@@ -333,15 +333,15 @@ static int osc_io_rw_iter_init(const struct lu_env *env,
 	if (npages > max_pages)
 		npages = max_pages;
 
-	c = atomic_read(cli->cl_lru_left);
+	c = atomic_long_read(cli->cl_lru_left);
 	if (c < npages && osc_lru_reclaim(cli) > 0)
-		c = atomic_read(cli->cl_lru_left);
+		c = atomic_long_read(cli->cl_lru_left);
 	while (c >= npages) {
-		if (c == atomic_cmpxchg(cli->cl_lru_left, c, c - npages)) {
+		if (c == atomic_long_cmpxchg(cli->cl_lru_left, c, c - npages)) {
 			oio->oi_lru_reserved = npages;
 			break;
 		}
-		c = atomic_read(cli->cl_lru_left);
+		c = atomic_long_read(cli->cl_lru_left);
 	}
 
 	return 0;
@@ -355,7 +355,7 @@ static void osc_io_rw_iter_fini(const struct lu_env *env,
 	struct client_obd *cli = osc_cli(osc);
 
 	if (oio->oi_lru_reserved > 0) {
-		atomic_add(oio->oi_lru_reserved, cli->cl_lru_left);
+		atomic_long_add(oio->oi_lru_reserved, cli->cl_lru_left);
 		oio->oi_lru_reserved = 0;
 	}
 	oio->oi_write_osclock = NULL;
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index c8889ea..2a7a70a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -380,7 +380,7 @@ static const int lru_shrink_max = 8 << (20 - PAGE_SHIFT); /* 8M */
 static int osc_cache_too_much(struct client_obd *cli)
 {
 	struct cl_client_cache *cache = cli->cl_cache;
-	int pages = atomic_read(&cli->cl_lru_in_list);
+	long pages = atomic_long_read(&cli->cl_lru_in_list);
 	unsigned long budget;
 
 	budget = cache->ccc_lru_max / (atomic_read(&cache->ccc_users) - 2);
@@ -388,7 +388,7 @@ static int osc_cache_too_much(struct client_obd *cli)
 	/* if it's going to run out LRU slots, we should free some, but not
 	 * too much to maintain fairness among OSCs.
 	 */
-	if (atomic_read(cli->cl_lru_left) < cache->ccc_lru_max >> 4) {
+	if (atomic_long_read(cli->cl_lru_left) < cache->ccc_lru_max >> 4) {
 		if (pages >= budget)
 			return lru_shrink_max;
 		else if (pages >= budget / 2)
@@ -415,7 +415,7 @@ void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 {
 	LIST_HEAD(lru);
 	struct osc_async_page *oap;
-	int npages = 0;
+	long npages = 0;
 
 	list_for_each_entry(oap, plist, oap_pending_item) {
 		struct osc_page *opg = oap2osc_page(oap);
@@ -431,8 +431,8 @@ void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 	if (npages > 0) {
 		spin_lock(&cli->cl_lru_list_lock);
 		list_splice_tail(&lru, &cli->cl_lru_list);
-		atomic_sub(npages, &cli->cl_lru_busy);
-		atomic_add(npages, &cli->cl_lru_in_list);
+		atomic_long_sub(npages, &cli->cl_lru_busy);
+		atomic_long_add(npages, &cli->cl_lru_in_list);
 		spin_unlock(&cli->cl_lru_list_lock);
 
 		/* XXX: May set force to be true for better performance */
@@ -443,9 +443,9 @@ void osc_lru_add_batch(struct client_obd *cli, struct list_head *plist)
 
 static void __osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 {
-	LASSERT(atomic_read(&cli->cl_lru_in_list) > 0);
+	LASSERT(atomic_long_read(&cli->cl_lru_in_list) > 0);
 	list_del_init(&opg->ops_lru);
-	atomic_dec(&cli->cl_lru_in_list);
+	atomic_long_dec(&cli->cl_lru_in_list);
 }
 
 /**
@@ -459,12 +459,12 @@ static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 		if (!list_empty(&opg->ops_lru)) {
 			__osc_lru_del(cli, opg);
 		} else {
-			LASSERT(atomic_read(&cli->cl_lru_busy) > 0);
-			atomic_dec(&cli->cl_lru_busy);
+			LASSERT(atomic_long_read(&cli->cl_lru_busy) > 0);
+			atomic_long_dec(&cli->cl_lru_busy);
 		}
 		spin_unlock(&cli->cl_lru_list_lock);
 
-		atomic_inc(cli->cl_lru_left);
+		atomic_long_inc(cli->cl_lru_left);
 		/* this is a great place to release more LRU pages if
 		 * this osc occupies too many LRU pages and kernel is
 		 * stealing one of them.
@@ -489,7 +489,7 @@ static void osc_lru_use(struct client_obd *cli, struct osc_page *opg)
 		spin_lock(&cli->cl_lru_list_lock);
 		__osc_lru_del(cli, opg);
 		spin_unlock(&cli->cl_lru_list_lock);
-		atomic_inc(&cli->cl_lru_busy);
+		atomic_long_inc(&cli->cl_lru_busy);
 	}
 }
 
@@ -535,8 +535,8 @@ static inline bool lru_page_busy(struct client_obd *cli, struct cl_page *page)
 /**
  * Drop @target of pages from LRU at most.
  */
-int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
-		   int target, bool force)
+long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
+		    long target, bool force)
 {
 	struct cl_io *io;
 	struct cl_object *clobj = NULL;
@@ -544,12 +544,12 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	struct osc_page *opg;
 	struct osc_page *temp;
 	int maxscan = 0;
-	int count = 0;
+	long count = 0;
 	int index = 0;
 	int rc = 0;
 
-	LASSERT(atomic_read(&cli->cl_lru_in_list) >= 0);
-	if (atomic_read(&cli->cl_lru_in_list) == 0 || target <= 0)
+	LASSERT(atomic_long_read(&cli->cl_lru_in_list) >= 0);
+	if (atomic_long_read(&cli->cl_lru_in_list) == 0 || target <= 0)
 		return 0;
 
 	if (!force) {
@@ -568,7 +568,7 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	io = &osc_env_info(env)->oti_io;
 
 	spin_lock(&cli->cl_lru_list_lock);
-	maxscan = min(target << 1, atomic_read(&cli->cl_lru_in_list));
+	maxscan = min(target << 1, atomic_long_read(&cli->cl_lru_in_list));
 	list_for_each_entry_safe(opg, temp, &cli->cl_lru_list, ops_lru) {
 		struct cl_page *page;
 		bool will_free = false;
@@ -656,24 +656,19 @@ int osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 
 	atomic_dec(&cli->cl_lru_shrinkers);
 	if (count > 0) {
-		atomic_add(count, cli->cl_lru_left);
+		atomic_long_add(count, cli->cl_lru_left);
 		wake_up_all(&osc_lru_waitq);
 	}
 	return count > 0 ? count : rc;
 }
 
-static inline int max_to_shrink(struct client_obd *cli)
-{
-	return min(atomic_read(&cli->cl_lru_in_list) >> 1, lru_shrink_max);
-}
-
-int osc_lru_reclaim(struct client_obd *cli)
+long osc_lru_reclaim(struct client_obd *cli)
 {
 	struct cl_env_nest nest;
 	struct lu_env *env;
 	struct cl_client_cache *cache = cli->cl_cache;
 	int max_scans;
-	int rc = 0;
+	long rc = 0;
 
 	LASSERT(cache);
 
@@ -686,15 +681,15 @@ int osc_lru_reclaim(struct client_obd *cli)
 		if (rc == -EBUSY)
 			rc = 0;
 
-		CDEBUG(D_CACHE, "%s: Free %d pages from own LRU: %p.\n",
+		CDEBUG(D_CACHE, "%s: Free %ld pages from own LRU: %p.\n",
 		       cli->cl_import->imp_obd->obd_name, rc, cli);
 		goto out;
 	}
 
-	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %d, busy: %d.\n",
+	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %ld, busy: %ld.\n",
 	       cli->cl_import->imp_obd->obd_name, cli,
-	       atomic_read(&cli->cl_lru_in_list),
-	       atomic_read(&cli->cl_lru_busy));
+	       atomic_long_read(&cli->cl_lru_in_list),
+	       atomic_long_read(&cli->cl_lru_busy));
 
 	/* Reclaim LRU slots from other client_obd as it can't free enough
 	 * from its own. This should rarely happen.
@@ -710,10 +705,10 @@ int osc_lru_reclaim(struct client_obd *cli)
 		cli = list_entry(cache->ccc_lru.next, struct client_obd,
 				 cl_lru_osc);
 
-		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %d, busy: %d.\n",
+		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %ld, busy: %ld.\n",
 		       cli->cl_import->imp_obd->obd_name, cli,
-		       atomic_read(&cli->cl_lru_in_list),
-		       atomic_read(&cli->cl_lru_busy));
+		       atomic_long_read(&cli->cl_lru_in_list),
+		       atomic_long_read(&cli->cl_lru_busy));
 
 		list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
 		if (osc_cache_too_much(cli) > 0) {
@@ -730,7 +725,7 @@ int osc_lru_reclaim(struct client_obd *cli)
 
 out:
 	cl_env_nested_put(&nest, env);
-	CDEBUG(D_CACHE, "%s: cli %p freed %d pages.\n",
+	CDEBUG(D_CACHE, "%s: cli %p freed %ld pages.\n",
 	       cli->cl_import->imp_obd->obd_name, cli, rc);
 	return rc;
 }
@@ -758,8 +753,8 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 		goto out;
 	}
 
-	LASSERT(atomic_read(cli->cl_lru_left) >= 0);
-	while (!atomic_add_unless(cli->cl_lru_left, -1, 0)) {
+	LASSERT(atomic_long_read(cli->cl_lru_left) >= 0);
+	while (!atomic_long_add_unless(cli->cl_lru_left, -1, 0)) {
 		/* run out of LRU spaces, try to drop some by itself */
 		rc = osc_lru_reclaim(cli);
 		if (rc < 0)
@@ -770,7 +765,7 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 		cond_resched();
 
 		rc = l_wait_event(osc_lru_waitq,
-				  atomic_read(cli->cl_lru_left) > 0,
+				  atomic_long_read(cli->cl_lru_left) > 0,
 				  &lwi);
 
 		if (rc < 0)
@@ -779,7 +774,7 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 
 out:
 	if (rc >= 0) {
-		atomic_inc(&cli->cl_lru_busy);
+		atomic_long_inc(&cli->cl_lru_busy);
 		opg->ops_in_lru = 1;
 		rc = 0;
 	}
@@ -847,16 +842,17 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 	struct client_obd *cli = &req->rq_import->imp_obd->u.cli;
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
 	int page_count = desc->bd_iov_count;
-	int unstable_count;
+	long unstable_count;
 
 	LASSERT(page_count >= 0);
 	dec_unstable_page_accounting(desc);
 
-	unstable_count = atomic_sub_return(page_count, &cli->cl_unstable_count);
+	unstable_count = atomic_long_sub_return(page_count,
+						&cli->cl_unstable_count);
 	LASSERT(unstable_count >= 0);
 
-	unstable_count = atomic_sub_return(page_count,
-					   &cli->cl_cache->ccc_unstable_nr);
+	unstable_count = atomic_long_sub_return(page_count,
+						&cli->cl_cache->ccc_unstable_nr);
 	LASSERT(unstable_count >= 0);
 	if (!unstable_count)
 		wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
@@ -872,15 +868,15 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req)
 {
 	struct client_obd *cli  = &req->rq_import->imp_obd->u.cli;
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	int page_count = desc->bd_iov_count;
+	long page_count = desc->bd_iov_count;
 
 	/* No unstable page tracking */
 	if (!cli->cl_cache || !cli->cl_cache->ccc_unstable_check)
 		return;
 
 	add_unstable_page_accounting(desc);
-	atomic_add(page_count, &cli->cl_unstable_count);
-	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
+	atomic_long_add(page_count, &cli->cl_unstable_count);
+	atomic_long_add(page_count, &cli->cl_cache->ccc_unstable_nr);
 
 	/*
 	 * If the request has already been committed (i.e. brw_commit
@@ -912,8 +908,8 @@ bool osc_over_unstable_soft_limit(struct client_obd *cli)
 	if (!cli->cl_cache || !cli->cl_cache->ccc_unstable_check)
 		return false;
 
-	osc_unstable_count = atomic_read(&cli->cl_unstable_count);
-	unstable_nr = atomic_read(&cli->cl_cache->ccc_unstable_nr);
+	osc_unstable_count = atomic_long_read(&cli->cl_unstable_count);
+	unstable_nr = atomic_long_read(&cli->cl_cache->ccc_unstable_nr);
 
 	CDEBUG(D_CACHE,
 	       "%s: cli: %p unstable pages: %lu, osc unstable pages: %lu\n",
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7f7c318..7449b77 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -804,17 +804,17 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		       cli->cl_dirty_pages, cli->cl_dirty_transit,
 		       cli->cl_dirty_max_pages);
 		oa->o_undirty = 0;
-	} else if (unlikely(atomic_read(&obd_dirty_pages) -
-			    atomic_read(&obd_dirty_transit_pages) >
-			    (long)(obd_max_dirty_pages + 1))) {
+	} else if (unlikely(atomic_long_read(&obd_dirty_pages) -
+			    atomic_long_read(&obd_dirty_transit_pages) >
+			    (obd_max_dirty_pages + 1))) {
 		/* The atomic_read() allowing the atomic_inc() are
 		 * not covered by a lock thus they may safely race and trip
 		 * this CERROR() unless we add in a small fudge factor (+1).
 		 */
-		CERROR("%s: dirty %d + %d > system dirty_max %d\n",
+		CERROR("%s: dirty %ld + %ld > system dirty_max %lu\n",
 		       cli->cl_import->imp_obd->obd_name,
-		       atomic_read(&obd_dirty_pages),
-		       atomic_read(&obd_dirty_transit_pages),
+		       atomic_long_read(&obd_dirty_pages),
+		       atomic_long_read(&obd_dirty_transit_pages),
 		       obd_max_dirty_pages);
 		oa->o_undirty = 0;
 	} else if (unlikely(cli->cl_dirty_max_pages - cli->cl_dirty_pages >
@@ -2920,11 +2920,11 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 
 	if (KEY_IS(KEY_CACHE_LRU_SHRINK)) {
 		struct client_obd *cli = &obd->u.cli;
-		int nr = atomic_read(&cli->cl_lru_in_list) >> 1;
-		int target = *(int *)val;
+		long nr = atomic_long_read(&cli->cl_lru_in_list) >> 1;
+		long target = *(long *)val;
 
 		nr = osc_lru_shrink(env, cli, min(nr, target), true);
-		*(int *)val -= nr;
+		*(long *)val -= nr;
 		return 0;
 	}
 
-- 
1.7.1
