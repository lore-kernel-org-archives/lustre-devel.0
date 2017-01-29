From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:39 -0500
Subject: [lustre-devel] [PATCH 11/60] staging: lustre: obd: RCU stalls in
	lu_cache_shrink_count()
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ann Koehler <amk@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ann Koehler <amk@cray.com>

The algorithm for counting freeable objects in the lu_cache shrinker
does not scale with the number of cpus. The LU_SS_LRU_LEN counter
for each cpu is read and summed at shrink time while holding the
lu_sites_guard mutex. With a large number of cpus and low memory
conditions, processes bottleneck on the mutex.

This mod reduces the time spent counting by using the kernel's percpu
counter functions to maintain the length of a site's lru. The summing
occurs when a percpu value is incremented or decremented and a
threshold is exceeded. lu_cache_shrink_count() simply returns the
last such computed sum.

This mod also replaces the lu_sites_guard mutex with a rw semaphore.
The lock protects the lu_site list, which is modified when a file
system is mounted/umounted or when the lu_site is purged.
lu_cache_shrink_count simply reads data so it does not need to wait
for other readers. lu_cache_shrink_scan, which actually frees the
unused objects, is still serialized.

Signed-off-by: Ann Koehler <amk@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7997
Reviewed-on: http://review.whamcloud.com/19390
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |  6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 80 ++++++++++------------
 2 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 69b2812..f442a96 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -34,6 +34,7 @@
 #define __LUSTRE_LU_OBJECT_H
 
 #include <stdarg.h>
+#include <linux/percpu_counter.h>
 #include "../../include/linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
 #include "lu_ref.h"
@@ -580,7 +581,6 @@ enum {
 	LU_SS_CACHE_RACE,
 	LU_SS_CACHE_DEATH_RACE,
 	LU_SS_LRU_PURGED,
-	LU_SS_LRU_LEN,	/* # of objects in lsb_lru lists */
 	LU_SS_LAST_STAT
 };
 
@@ -635,6 +635,10 @@ struct lu_site {
 	 * XXX: a hack! fld has to find md_site via site, remove when possible
 	 */
 	struct seq_server_site	*ld_seq_site;
+	/**
+	 * Number of objects in lsb_lru_lists - used for shrinking
+	 */
+	struct percpu_counter	 ls_lru_len_counter;
 };
 
 static inline struct lu_site_bkt_data *
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 7971562..1805861 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -151,7 +151,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 		LASSERT(list_empty(&top->loh_lru));
 		list_add_tail(&top->loh_lru, &bkt->lsb_lru);
 		bkt->lsb_lru_len++;
-		lprocfs_counter_incr(site->ls_stats, LU_SS_LRU_LEN);
+		percpu_counter_inc(&site->ls_lru_len_counter);
 		CDEBUG(D_INODE, "Add %p to site lru. hash: %p, bkt: %p, lru_len: %ld\n",
 		       o, site->ls_obj_hash, bkt, bkt->lsb_lru_len);
 		cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
@@ -202,7 +202,7 @@ void lu_object_unhash(const struct lu_env *env, struct lu_object *o)
 			list_del_init(&top->loh_lru);
 			bkt = cfs_hash_bd_extra_get(obj_hash, &bd);
 			bkt->lsb_lru_len--;
-			lprocfs_counter_decr(site->ls_stats, LU_SS_LRU_LEN);
+			percpu_counter_dec(&site->ls_lru_len_counter);
 		}
 		cfs_hash_bd_del_locked(obj_hash, &bd, &top->loh_hash);
 		cfs_hash_bd_unlock(obj_hash, &bd, 1);
@@ -379,7 +379,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 					       &bd2, &h->loh_hash);
 			list_move(&h->loh_lru, &dispose);
 			bkt->lsb_lru_len--;
-			lprocfs_counter_decr(s->ls_stats, LU_SS_LRU_LEN);
+			percpu_counter_dec(&s->ls_lru_len_counter);
 			if (did_sth == 0)
 				did_sth = 1;
 
@@ -578,7 +578,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 		if (!list_empty(&h->loh_lru)) {
 			list_del_init(&h->loh_lru);
 			bkt->lsb_lru_len--;
-			lprocfs_counter_decr(s->ls_stats, LU_SS_LRU_LEN);
+			percpu_counter_dec(&s->ls_lru_len_counter);
 		}
 		return lu_object_top(h);
 	}
@@ -820,7 +820,7 @@ void lu_device_type_fini(struct lu_device_type *ldt)
  * Global list of all sites on this node
  */
 static LIST_HEAD(lu_sites);
-static DEFINE_MUTEX(lu_sites_guard);
+static DECLARE_RWSEM(lu_sites_guard);
 
 /**
  * Global environment used by site shrinker.
@@ -994,9 +994,15 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	unsigned long bits;
 	unsigned long i;
 	char name[16];
+	int rc;
 
 	memset(s, 0, sizeof(*s));
 	mutex_init(&s->ls_purge_mutex);
+
+	rc = percpu_counter_init(&s->ls_lru_len_counter, 0, GFP_NOFS);
+	if (rc)
+		return -ENOMEM;
+
 	snprintf(name, sizeof(name), "lu_site_%s", top->ld_type->ldt_name);
 	for (bits = lu_htable_order(top); bits >= LU_SITE_BITS_MIN; bits--) {
 		s->ls_obj_hash = cfs_hash_create(name, bits, bits,
@@ -1042,12 +1048,6 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 			     0, "cache_death_race", "cache_death_race");
 	lprocfs_counter_init(s->ls_stats, LU_SS_LRU_PURGED,
 			     0, "lru_purged", "lru_purged");
-	/*
-	 * Unlike other counters, lru_len can be decremented so
-	 * need lc_sum instead of just lc_count
-	 */
-	lprocfs_counter_init(s->ls_stats, LU_SS_LRU_LEN,
-			     LPROCFS_CNTR_AVGMINMAX, "lru_len", "lru_len");
 
 	INIT_LIST_HEAD(&s->ls_linkage);
 	s->ls_top_dev = top;
@@ -1069,9 +1069,11 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
  */
 void lu_site_fini(struct lu_site *s)
 {
-	mutex_lock(&lu_sites_guard);
+	down_write(&lu_sites_guard);
 	list_del_init(&s->ls_linkage);
-	mutex_unlock(&lu_sites_guard);
+	up_write(&lu_sites_guard);
+
+	percpu_counter_destroy(&s->ls_lru_len_counter);
 
 	if (s->ls_obj_hash) {
 		cfs_hash_putref(s->ls_obj_hash);
@@ -1097,11 +1099,11 @@ int lu_site_init_finish(struct lu_site *s)
 {
 	int result;
 
-	mutex_lock(&lu_sites_guard);
+	down_write(&lu_sites_guard);
 	result = lu_context_refill(&lu_shrink_env.le_ctx);
 	if (result == 0)
 		list_add(&s->ls_linkage, &lu_sites);
-	mutex_unlock(&lu_sites_guard);
+	up_write(&lu_sites_guard);
 	return result;
 }
 EXPORT_SYMBOL(lu_site_init_finish);
@@ -1820,12 +1822,15 @@ static void lu_site_stats_get(struct cfs_hash *hs,
 }
 
 /*
- * lu_cache_shrink_count returns the number of cached objects that are
- * candidates to be freed by shrink_slab(). A counter, which tracks
- * the number of items in the site's lru, is maintained in the per cpu
- * stats of each site. The counter is incremented when an object is added
- * to a site's lru and decremented when one is removed. The number of
- * free-able objects is the sum of all per cpu counters for all sites.
+ * lu_cache_shrink_count() returns an approximate number of cached objects
+ * that can be freed by shrink_slab(). A counter, which tracks the
+ * number of items in the site's lru, is maintained in a percpu_counter
+ * for each site. The percpu values are incremented and decremented as
+ * objects are added or removed from the lru. The percpu values are summed
+ * and saved whenever a percpu value exceeds a threshold. Thus the saved,
+ * summed value at any given time may not accurately reflect the current
+ * lru length. But this value is sufficiently accurate for the needs of
+ * a shrinker.
  *
  * Using a per cpu counter is a compromise solution to concurrent access:
  * lu_object_put() can update the counter without locking the site and
@@ -1842,11 +1847,10 @@ static unsigned long lu_cache_shrink_count(struct shrinker *sk,
 	if (!(sc->gfp_mask & __GFP_FS))
 		return 0;
 
-	mutex_lock(&lu_sites_guard);
-	list_for_each_entry_safe(s, tmp, &lu_sites, ls_linkage) {
-		cached += ls_stats_read(s->ls_stats, LU_SS_LRU_LEN);
-	}
-	mutex_unlock(&lu_sites_guard);
+	down_read(&lu_sites_guard);
+	list_for_each_entry_safe(s, tmp, &lu_sites, ls_linkage)
+		cached += percpu_counter_read_positive(&s->ls_lru_len_counter);
+	up_read(&lu_sites_guard);
 
 	cached = (cached / 100) * sysctl_vfs_cache_pressure;
 	CDEBUG(D_INODE, "%ld objects cached, cache pressure %d\n",
@@ -1877,7 +1881,7 @@ static unsigned long lu_cache_shrink_scan(struct shrinker *sk,
 		 */
 		return SHRINK_STOP;
 
-	mutex_lock(&lu_sites_guard);
+	down_write(&lu_sites_guard);
 	list_for_each_entry_safe(s, tmp, &lu_sites, ls_linkage) {
 		freed = lu_site_purge(&lu_shrink_env, s, remain);
 		remain -= freed;
@@ -1888,7 +1892,7 @@ static unsigned long lu_cache_shrink_scan(struct shrinker *sk,
 		list_move_tail(&s->ls_linkage, &splice);
 	}
 	list_splice(&splice, lu_sites.prev);
-	mutex_unlock(&lu_sites_guard);
+	up_write(&lu_sites_guard);
 
 	return sc->nr_to_scan - remain;
 }
@@ -1925,9 +1929,9 @@ int lu_global_init(void)
 	 * conservatively. This should not be too bad, because this
 	 * environment is global.
 	 */
-	mutex_lock(&lu_sites_guard);
+	down_write(&lu_sites_guard);
 	result = lu_env_init(&lu_shrink_env, LCT_SHRINKER);
-	mutex_unlock(&lu_sites_guard);
+	up_write(&lu_sites_guard);
 	if (result != 0)
 		return result;
 
@@ -1953,9 +1957,9 @@ void lu_global_fini(void)
 	 * Tear shrinker environment down _after_ de-registering
 	 * lu_global_key, because the latter has a value in the former.
 	 */
-	mutex_lock(&lu_sites_guard);
+	down_write(&lu_sites_guard);
 	lu_env_fini(&lu_shrink_env);
-	mutex_unlock(&lu_sites_guard);
+	up_write(&lu_sites_guard);
 
 	lu_ref_global_fini();
 }
@@ -1965,13 +1969,6 @@ static __u32 ls_stats_read(struct lprocfs_stats *stats, int idx)
 	struct lprocfs_counter ret;
 
 	lprocfs_stats_collect(stats, idx, &ret);
-	if (idx == LU_SS_LRU_LEN)
-		/*
-		 * protect against counter on cpu A being decremented
-		 * before counter is incremented on cpu B; unlikely
-		 */
-		return (__u32)((ret.lc_sum > 0) ? ret.lc_sum : 0);
-
 	return (__u32)ret.lc_count;
 }
 
@@ -1986,7 +1983,7 @@ int lu_site_stats_print(const struct lu_site *s, struct seq_file *m)
 	memset(&stats, 0, sizeof(stats));
 	lu_site_stats_get(s->ls_obj_hash, &stats, 1);
 
-	seq_printf(m, "%d/%d %d/%ld %d %d %d %d %d %d %d %d\n",
+	seq_printf(m, "%d/%d %d/%ld %d %d %d %d %d %d %d\n",
 		   stats.lss_busy,
 		   stats.lss_total,
 		   stats.lss_populated,
@@ -1997,8 +1994,7 @@ int lu_site_stats_print(const struct lu_site *s, struct seq_file *m)
 		   ls_stats_read(s->ls_stats, LU_SS_CACHE_MISS),
 		   ls_stats_read(s->ls_stats, LU_SS_CACHE_RACE),
 		   ls_stats_read(s->ls_stats, LU_SS_CACHE_DEATH_RACE),
-		   ls_stats_read(s->ls_stats, LU_SS_LRU_PURGED),
-		   ls_stats_read(s->ls_stats, LU_SS_LRU_LEN));
+		   ls_stats_read(s->ls_stats, LU_SS_LRU_PURGED));
 	return 0;
 }
 EXPORT_SYMBOL(lu_site_stats_print);
-- 
1.8.3.1
