From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:28 -0500
Subject: [lustre-devel] [PATCH 580/622] lustre: u_object: factor out extra
 per-bucket data
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-581-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

The hash tables managed by lu_object store some extra
information in each bucket in the hash table.  This prevents the use
of resizeable hash tables, so lu_site_init() goes to some trouble
to try to guess a good hash size.

There is no real need for the extra data to be closely associated with
hash buckets.  There is a small advantage as both the hash bucket and
the extra information can then be protected by the same lock, but as
these locks have low contention, that should rarely be noticed.

The extra data is updated frequently and accessed rarely, such an lru
list and a wait_queue head.  There could just be a single copy of this
data for the whole array, but on a many-cpu machine, that could become
a contention bottle neck.  So it makes sense keep multiple shards and
combine them only when needed.  It does not make sense to have many
more copies than there are CPUs.

This patch takes the extra data out of the hash table buckets and
creates a separate array, which never has more entries than twice the
number of possible cpus.  As this extra data contains a
wait_queue_head, which contains a spinlock, that lock is used to
protect the other data (counter and lru list).

The code currently uses a very simple hash to choose a
hash-table bucket:

(fid_seq(fid) + fid_oid(fid)) & (CFS_HASH_NBKT(hs) - 1)

There is no documented reason for this and I cannot see any value in
not using a general hash function. We can use hash_32() and hash_64()
on the fid value with a random seed created for each lu_site. The
hash_*() functions where picked over the jhash() functions since
it performances way better.

The lock ordering requires that a hash-table lock cannot be taken
while an extra-data lock is held.  This means that in
lu_site_purge_objects() we much first remove objects from the lru
(with the extra information locked) and then remove each one from the
hash table.  To ensure the object is not found between these two
steps, the LU_OBJECT_HEARD_BANSHEE flag is set.

As the extra info is now separate from the hash buckets, we cannot
report statistic from both at the same time.  I think the lru
statistics are probably more useful than the hash-table statistics, so
I have preserved the former and discarded the latter.  When the
hashtable becomes resizeable, those statistics will be irrelevant.

As the lru and the hash table are now managed by different locks
we need to be careful to prevent htable_lookup() finding an
object that lu_site_purge_objects() is purging.
To help with this we introduce a new lu_object flag to say
that and object is being purged.  Once set, the object will
be quickly removed from the hash table, and is already
removed from the lru.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8130
Lustre-commit: e6f7f8a7b349 ("LU-8130 lu_object: factor out extra per-bucket data")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36216
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h  |  13 +++-
 fs/lustre/obdclass/lu_object.c | 167 +++++++++++++++++++++++++----------------
 2 files changed, 113 insertions(+), 67 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index e92f12f..4608937 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -463,7 +463,12 @@ enum lu_object_header_flags {
 	 * Object is initialized, when object is found in cache, it may not be
 	 * initialized yet, the object allocator will initialize it.
 	 */
-	LU_OBJECT_INITED	= 2
+	LU_OBJECT_INITED	= 2,
+	/**
+	 * Object is being purged, so mustn't be returned by
+	 * htable_lookup()
+	 */
+	LU_OBJECT_PURGING	= 3,
 };
 
 enum lu_object_header_attr {
@@ -553,6 +558,12 @@ struct lu_site {
 	 * objects hash table
 	 */
 	struct cfs_hash	       *ls_obj_hash;
+	/*
+	 * buckets for summary data
+	 */
+	struct lu_site_bkt_data	*ls_bkts;
+	int			ls_bkt_cnt;
+	u32			ls_bkt_seed;
 	/**
 	 * index of bucket on hash table while purging
 	 */
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 38c04c7..7ea9948 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -43,6 +43,7 @@
 
 #include <linux/module.h>
 #include <linux/processor.h>
+#include <linux/random.h>
 
 /* hash_long() */
 #include <linux/libcfs/libcfs_hash.h>
@@ -58,11 +59,10 @@
 struct lu_site_bkt_data {
 	/**
 	 * LRU list, updated on each access to object. Protected by
-	 * bucket lock of lu_site::ls_obj_hash.
+	 * lsb_waitq.lock.
 	 *
 	 * "Cold" end of LRU is lu_site::ls_lru.next. Accessed object are
-	 * moved to the lu_site::ls_lru.prev (this is due to the non-existence
-	 * of list_for_each_entry_safe_reverse()).
+	 * moved to the lu_site::ls_lru.prev
 	 */
 	struct list_head		lsb_lru;
 	/**
@@ -92,9 +92,11 @@ enum {
 #define LU_SITE_BITS_MAX		24
 #define LU_SITE_BITS_MAX_CL		19
 /**
- * total 256 buckets, we don't want too many buckets because:
- * - consume too much memory
+ * Max 256 buckets, we don't want too many buckets because:
+ * - consume too much memory (currently max 16K)
  * - avoid unbalanced LRU list
+ * With few cpus there is little gain from extra buckets, so
+ * we treat this as a maximum in lu_site_init().
  */
 #define LU_SITE_BKT_BITS		8
 
@@ -109,14 +111,27 @@ enum {
 static void lu_object_free(const struct lu_env *env, struct lu_object *o);
 static u32 ls_stats_read(struct lprocfs_stats *stats, int idx);
 
+static u32 lu_fid_hash(const void *data, u32 seed)
+{
+	const struct lu_fid *fid = data;
+
+	seed = hash_32(seed ^ fid->f_oid, 32);
+	seed ^= hash_64(fid->f_seq, 32);
+	return seed;
+}
+
+static inline int lu_bkt_hash(struct lu_site *s, const struct lu_fid *fid)
+{
+	return lu_fid_hash(fid, s->ls_bkt_seed) &
+	       (s->ls_bkt_cnt - 1);
+}
+
 wait_queue_head_t *
 lu_site_wq_from_fid(struct lu_site *site, struct lu_fid *fid)
 {
-	struct cfs_hash_bd bd;
 	struct lu_site_bkt_data *bkt;
 
-	cfs_hash_bd_get(site->ls_obj_hash, fid, &bd);
-	bkt = cfs_hash_bd_extra_get(site->ls_obj_hash, &bd);
+	bkt = &site->ls_bkts[lu_bkt_hash(site, fid)];
 	return &bkt->lsb_waitq;
 }
 EXPORT_SYMBOL(lu_site_wq_from_fid);
@@ -155,7 +170,6 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	}
 
 	cfs_hash_bd_get(site->ls_obj_hash, &top->loh_fid, &bd);
-	bkt = cfs_hash_bd_extra_get(site->ls_obj_hash, &bd);
 
 	is_dying = lu_object_is_dying(top);
 	if (!cfs_hash_bd_dec_and_lock(site->ls_obj_hash, &bd, &top->loh_ref)) {
@@ -169,6 +183,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 			 * somebody may be waiting for this, currently only
 			 * used for cl_object, see cl_object_put_last().
 			 */
+			bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
 			wake_up_all(&bkt->lsb_waitq);
 		}
 		return;
@@ -183,6 +198,9 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 			o->lo_ops->loo_object_release(env, o);
 	}
 
+	bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
+	spin_lock(&bkt->lsb_waitq.lock);
+
 	/* don't use local 'is_dying' here because if was taken without lock
 	 * but here we need the latest actual value of it so check lu_object
 	 * directly here.
@@ -190,6 +208,7 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 	if (!lu_object_is_dying(top)) {
 		LASSERT(list_empty(&top->loh_lru));
 		list_add_tail(&top->loh_lru, &bkt->lsb_lru);
+		spin_unlock(&bkt->lsb_waitq.lock);
 		percpu_counter_inc(&site->ls_lru_len_counter);
 		CDEBUG(D_INODE, "Add %p/%p to site lru. hash: %p, bkt: %p\n",
 		       orig, top, site->ls_obj_hash, bkt);
@@ -199,22 +218,19 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 
 	/*
 	 * If object is dying (will not be cached), then removed it
-	 * from hash table and LRU.
+	 * from hash table (it is already not on the LRU).
 	 *
-	 * This is done with hash table and LRU lists locked. As the only
+	 * This is done with hash table lists locked. As the only
 	 * way to acquire first reference to previously unreferenced
-	 * object is through hash-table lookup (lu_object_find()),
-	 * or LRU scanning (lu_site_purge()), that are done under hash-table
-	 * and LRU lock, no race with concurrent object lookup is possible
-	 * and we can safely destroy object below.
+	 * object is through hash-table lookup (lu_object_find())
+	 * which is done under hash-table, no race with concurrent
+	 * object lookup is possible and we can safely destroy object below.
 	 */
 	if (!test_and_set_bit(LU_OBJECT_UNHASHED, &top->loh_flags))
 		cfs_hash_bd_del_locked(site->ls_obj_hash, &bd, &top->loh_hash);
+	spin_unlock(&bkt->lsb_waitq.lock);
 	cfs_hash_bd_unlock(site->ls_obj_hash, &bd, 1);
-	/*
-	 * Object was already removed from hash and lru above, can
-	 * kill it.
-	 */
+	/* Object was already removed from hash above, can kill it. */
 	lu_object_free(env, orig);
 }
 EXPORT_SYMBOL(lu_object_put);
@@ -238,8 +254,10 @@ void lu_object_unhash(const struct lu_env *env, struct lu_object *o)
 		if (!list_empty(&top->loh_lru)) {
 			struct lu_site_bkt_data *bkt;
 
+			bkt = &site->ls_bkts[lu_bkt_hash(site, &top->loh_fid)];
+			spin_lock(&bkt->lsb_waitq.lock);
 			list_del_init(&top->loh_lru);
-			bkt = cfs_hash_bd_extra_get(obj_hash, &bd);
+			spin_unlock(&bkt->lsb_waitq.lock);
 			percpu_counter_dec(&site->ls_lru_len_counter);
 		}
 		cfs_hash_bd_del_locked(obj_hash, &bd, &top->loh_hash);
@@ -390,8 +408,6 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	struct lu_object_header *h;
 	struct lu_object_header *temp;
 	struct lu_site_bkt_data *bkt;
-	struct cfs_hash_bd bd;
-	struct cfs_hash_bd bd2;
 	struct list_head dispose;
 	int did_sth;
 	unsigned int start = 0;
@@ -409,7 +425,7 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 	 */
 	if (nr != ~0)
 		start = s->ls_purge_start;
-	bnr = (nr == ~0) ? -1 : nr / (int)CFS_HASH_NBKT(s->ls_obj_hash) + 1;
+	bnr = (nr == ~0) ? -1 : nr / s->ls_bkt_cnt + 1;
 again:
 	/*
 	 * It doesn't make any sense to make purge threads parallel, that can
@@ -421,21 +437,21 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 		goto out;
 
 	did_sth = 0;
-	cfs_hash_for_each_bucket(s->ls_obj_hash, &bd, i) {
-		if (i < start)
-			continue;
+	for (i = start; i < s->ls_bkt_cnt ; i++) {
 		count = bnr;
-		cfs_hash_bd_lock(s->ls_obj_hash, &bd, 1);
-		bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, &bd);
+		bkt = &s->ls_bkts[i];
+		spin_lock(&bkt->lsb_waitq.lock);
 
 		list_for_each_entry_safe(h, temp, &bkt->lsb_lru, loh_lru) {
 			LASSERT(atomic_read(&h->loh_ref) == 0);
 
-			cfs_hash_bd_get(s->ls_obj_hash, &h->loh_fid, &bd2);
-			LASSERT(bd.bd_bucket == bd2.bd_bucket);
+			LINVRNT(lu_bkt_hash(s, &h->loh_fid) == i);
 
-			cfs_hash_bd_del_locked(s->ls_obj_hash,
-					       &bd2, &h->loh_hash);
+			/* Cannot remove from hash under current spinlock,
+			 * so set flag to stop object from being found
+			 * by htable_lookup().
+			 */
+			set_bit(LU_OBJECT_PURGING, &h->loh_flags);
 			list_move(&h->loh_lru, &dispose);
 			percpu_counter_dec(&s->ls_lru_len_counter);
 			if (did_sth == 0)
@@ -447,14 +463,16 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 			if (count > 0 && --count == 0)
 				break;
 		}
-		cfs_hash_bd_unlock(s->ls_obj_hash, &bd, 1);
+		spin_unlock(&bkt->lsb_waitq.lock);
 		cond_resched();
 		/*
 		 * Free everything on the dispose list. This is safe against
 		 * races due to the reasons described in lu_object_put().
 		 */
-		while ((h = list_first_entry_or_null(
-				&dispose, struct lu_object_header, loh_lru)) != NULL) {
+		while ((h = list_first_entry_or_null(&dispose,
+						     struct lu_object_header,
+						     loh_lru)) != NULL) {
+			cfs_hash_del(s->ls_obj_hash, &h->loh_fid, &h->loh_hash);
 			list_del_init(&h->loh_lru);
 			lu_object_free(env, lu_object_top(h));
 			lprocfs_counter_incr(s->ls_stats, LU_SS_LRU_PURGED);
@@ -470,7 +488,7 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
 		goto again;
 	}
 	/* race on s->ls_purge_start, but nobody cares */
-	s->ls_purge_start = i % CFS_HASH_NBKT(s->ls_obj_hash);
+	s->ls_purge_start = i % (s->ls_bkt_cnt - 1);
 out:
 	return nr;
 }
@@ -631,12 +649,29 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 	}
 
 	h = container_of(hnode, struct lu_object_header, loh_hash);
-	cfs_hash_get(s->ls_obj_hash, hnode);
-	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
 	if (!list_empty(&h->loh_lru)) {
+		struct lu_site_bkt_data *bkt;
+
+		bkt = &s->ls_bkts[lu_bkt_hash(s, &h->loh_fid)];
+		spin_lock(&bkt->lsb_waitq.lock);
+		/* Might have just been moved to the dispose list, in which
+		 * case LU_OBJECT_PURGING will be set.  In that case,
+		 * delete it from the hash table immediately.
+		 * When lu_site_purge_objects() tried, it will find it
+		 * isn't there, which is harmless.
+		 */
+		if (test_bit(LU_OBJECT_PURGING, &h->loh_flags)) {
+			spin_unlock(&bkt->lsb_waitq.lock);
+			cfs_hash_bd_del_locked(s->ls_obj_hash, bd, hnode);
+			lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
+			return ERR_PTR(-ENOENT);
+		}
 		list_del_init(&h->loh_lru);
+		spin_unlock(&bkt->lsb_waitq.lock);
 		percpu_counter_dec(&s->ls_lru_len_counter);
 	}
+	cfs_hash_get(s->ls_obj_hash, hnode);
+	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
 	return lu_object_top(h);
 }
 
@@ -721,8 +756,8 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
 	if (unlikely(OBD_FAIL_PRECHECK(OBD_FAIL_OBD_ZERO_NLINK_RACE)))
 		lu_site_purge(env, s, -1);
 
+	bkt = &s->ls_bkts[lu_bkt_hash(s, f)];
 	cfs_hash_bd_get(hs, f, &bd);
-	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, &bd);
 	if (!(conf && conf->loc_flags & LOC_F_NEW)) {
 		cfs_hash_bd_lock(hs, &bd, 1);
 		o = htable_lookup(s, &bd, f, &version);
@@ -1029,7 +1064,6 @@ static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 int lu_site_init(struct lu_site *s, struct lu_device *top)
 {
 	struct lu_site_bkt_data *bkt;
-	struct cfs_hash_bd bd;
 	unsigned long bits;
 	unsigned long i;
 	char name[16];
@@ -1046,7 +1080,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	for (bits = lu_htable_order(top); bits >= LU_SITE_BITS_MIN; bits--) {
 		s->ls_obj_hash = cfs_hash_create(name, bits, bits,
 						 bits - LU_SITE_BKT_BITS,
-						 sizeof(*bkt), 0, 0,
+						 0, 0, 0,
 						 &lu_site_hash_ops,
 						 CFS_HASH_SPIN_BKTLOCK |
 						 CFS_HASH_NO_ITEMREF |
@@ -1062,16 +1096,31 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 		return -ENOMEM;
 	}
 
-	cfs_hash_for_each_bucket(s->ls_obj_hash, &bd, i) {
-		bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, &bd);
+	s->ls_bkt_seed = prandom_u32();
+	s->ls_bkt_cnt = max_t(long, 1 << LU_SITE_BKT_BITS,
+			      2 * num_possible_cpus());
+	s->ls_bkt_cnt = roundup_pow_of_two(s->ls_bkt_cnt);
+	s->ls_bkts = kvmalloc_array(s->ls_bkt_cnt, sizeof(*bkt),
+				    GFP_KERNEL | __GFP_ZERO);
+	if (!s->ls_bkts) {
+		cfs_hash_putref(s->ls_obj_hash);
+		s->ls_obj_hash = NULL;
+		s->ls_bkts = NULL;
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < s->ls_bkt_cnt; i++) {
+		bkt = &s->ls_bkts[i];
 		INIT_LIST_HEAD(&bkt->lsb_lru);
 		init_waitqueue_head(&bkt->lsb_waitq);
 	}
 
 	s->ls_stats = lprocfs_alloc_stats(LU_SS_LAST_STAT, 0);
 	if (!s->ls_stats) {
+		kvfree(s->ls_bkts);
 		cfs_hash_putref(s->ls_obj_hash);
 		s->ls_obj_hash = NULL;
+		s->ls_bkts = NULL;
 		return -ENOMEM;
 	}
 
@@ -1119,6 +1168,8 @@ void lu_site_fini(struct lu_site *s)
 		s->ls_obj_hash = NULL;
 	}
 
+	kvfree(s->ls_bkts);
+
 	if (s->ls_top_dev) {
 		s->ls_top_dev->ld_site = NULL;
 		lu_ref_del(&s->ls_top_dev->ld_reference, "site-top", s);
@@ -1878,37 +1929,21 @@ struct lu_site_stats {
 };
 
 static void lu_site_stats_get(const struct lu_site *s,
-			      struct lu_site_stats *stats, int populated)
+			      struct lu_site_stats *stats)
 {
-	struct cfs_hash *hs = s->ls_obj_hash;
-	struct cfs_hash_bd bd;
-	unsigned int i;
+	int cnt = cfs_hash_size_get(s->ls_obj_hash);
 	/*
 	 * percpu_counter_sum_positive() won't accept a const pointer
 	 * as it does modify the struct by taking a spinlock
 	 */
 	struct lu_site *s2 = (struct lu_site *)s;
 
-	stats->lss_busy += cfs_hash_size_get(hs) -
+	stats->lss_busy += cnt -
 		percpu_counter_sum_positive(&s2->ls_lru_len_counter);
-	cfs_hash_for_each_bucket(hs, &bd, i) {
-		struct hlist_head *hhead;
 
-		cfs_hash_bd_lock(hs, &bd, 1);
-		stats->lss_total += cfs_hash_bd_count_get(&bd);
-		stats->lss_max_search = max((int)stats->lss_max_search,
-					    cfs_hash_bd_depmax_get(&bd));
-		if (!populated) {
-			cfs_hash_bd_unlock(hs, &bd, 1);
-			continue;
-		}
-
-		cfs_hash_bd_for_each_hlist(hs, &bd, hhead) {
-			if (!hlist_empty(hhead))
-				stats->lss_populated++;
-		}
-		cfs_hash_bd_unlock(hs, &bd, 1);
-	}
+	stats->lss_total += cnt;
+	stats->lss_max_search = 0;
+	stats->lss_populated = 0;
 }
 
 /*
@@ -2201,7 +2236,7 @@ int lu_site_stats_print(const struct lu_site *s, struct seq_file *m)
 	struct lu_site_stats stats;
 
 	memset(&stats, 0, sizeof(stats));
-	lu_site_stats_get(s, &stats, 1);
+	lu_site_stats_get(s, &stats);
 
 	seq_printf(m, "%d/%d %d/%ld %d %d %d %d %d %d %d\n",
 		   stats.lss_busy,
-- 
1.8.3.1
