From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:15 -0400
Subject: [lustre-devel] [PATCH 62/80] staging: lustre: obd: limit lu_object
	cache
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-63-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Brian Behlendorf <behlendorf1@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Brian Behlendorf <behlendorf1@llnl.gov>

As the LU cache grows it can consume large enough chunks of
memory that ends up preventing buffers for other objects,
such as the OIs, from being cached and severely impacting
the performance for FID lookups. Limit the lu_object cache
to a maximum of lu_cache_nr objects.

NOTES:

* In order to be able to quickly determine the number of objects in
  the hash table the CFS_HASH_COUNTER flag is added.  This adds an
  atomic_inc/dec to the hash insert/remove paths but is not expected
  to have any measurable impact of performance.

Signed-off-by: Brian Behlendorf <behlendorf1@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5164
Reviewed-on: http://review.whamcloud.com/10237
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   91 ++++++++++++++------
 1 files changed, 64 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0c00bf8..9d1c96b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -55,6 +55,34 @@
 #include "../include/lu_ref.h"
 #include <linux/list.h>
 
+enum {
+	LU_CACHE_PERCENT_MAX	 = 50,
+	LU_CACHE_PERCENT_DEFAULT = 20
+};
+
+#define LU_CACHE_NR_MAX_ADJUST		128
+#define LU_CACHE_NR_UNLIMITED		-1
+#define LU_CACHE_NR_DEFAULT		LU_CACHE_NR_UNLIMITED
+#define LU_CACHE_NR_LDISKFS_LIMIT	LU_CACHE_NR_UNLIMITED
+#define LU_CACHE_NR_ZFS_LIMIT		256
+
+#define LU_SITE_BITS_MIN	12
+#define LU_SITE_BITS_MAX	24
+/**
+ * total 256 buckets, we don't want too many buckets because:
+ * - consume too much memory
+ * - avoid unbalanced LRU list
+ */
+#define LU_SITE_BKT_BITS	8
+
+static unsigned int lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
+module_param(lu_cache_percent, int, 0644);
+MODULE_PARM_DESC(lu_cache_percent, "Percentage of memory to be used as lu_object cache");
+
+static long lu_cache_nr = LU_CACHE_NR_DEFAULT;
+module_param(lu_cache_nr, long, 0644);
+MODULE_PARM_DESC(lu_cache_nr, "Maximum number of objects in lu_object cache");
+
 static void lu_object_free(const struct lu_env *env, struct lu_object *o);
 static __u32 ls_stats_read(struct lprocfs_stats *stats, int idx);
 
@@ -573,6 +601,27 @@ static struct lu_object *lu_object_find(const struct lu_env *env,
 	return lu_object_find_at(env, dev->ld_site->ls_top_dev, f, conf);
 }
 
+/*
+ * Limit the lu_object cache to a maximum of lu_cache_nr objects.  Because
+ * the calculation for the number of objects to reclaim is not covered by
+ * a lock the maximum number of objects is capped by LU_CACHE_MAX_ADJUST.
+ * This ensures that many concurrent threads will not accidentally purge
+ * the entire cache.
+ */
+static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
+{
+	__u64 size, nr;
+
+	if (lu_cache_nr == LU_CACHE_NR_UNLIMITED)
+		return;
+
+	size = cfs_hash_size_get(dev->ld_site->ls_obj_hash);
+	nr = (__u64)lu_cache_nr;
+	if (size > nr)
+		lu_site_purge(env, dev->ld_site,
+			      min_t(__u64, size - nr, LU_CACHE_NR_MAX_ADJUST));
+}
+
 static struct lu_object *lu_object_new(const struct lu_env *env,
 				       struct lu_device *dev,
 				       const struct lu_fid *f,
@@ -590,6 +639,9 @@ static struct lu_object *lu_object_new(const struct lu_env *env,
 	cfs_hash_bd_get_and_lock(hs, (void *)f, &bd, 1);
 	cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
 	cfs_hash_bd_unlock(hs, &bd, 1);
+
+	lu_object_limit(env, dev);
+
 	return o;
 }
 
@@ -656,6 +708,9 @@ static struct lu_object *lu_object_find_try(const struct lu_env *env,
 	if (likely(PTR_ERR(shadow) == -ENOENT)) {
 		cfs_hash_bd_add_locked(hs, &bd, &o->lo_header->loh_hash);
 		cfs_hash_bd_unlock(hs, &bd, 1);
+
+		lu_object_limit(env, dev);
+
 		return o;
 	}
 
@@ -805,20 +860,12 @@ void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
 }
 EXPORT_SYMBOL(lu_site_print);
 
-enum {
-	LU_CACHE_PERCENT_MAX     = 50,
-	LU_CACHE_PERCENT_DEFAULT = 20
-};
-
-static unsigned int lu_cache_percent = LU_CACHE_PERCENT_DEFAULT;
-module_param(lu_cache_percent, int, 0644);
-MODULE_PARM_DESC(lu_cache_percent, "Percentage of memory to be used as lu_object cache");
-
 /**
  * Return desired hash table order.
  */
-static int lu_htable_order(void)
+static int lu_htable_order(struct lu_device *top)
 {
+	unsigned long bits_max = LU_SITE_BITS_MAX;
 	unsigned long cache_size;
 	int bits;
 
@@ -851,7 +898,7 @@ static int lu_htable_order(void)
 	for (bits = 1; (1 << bits) < cache_size; ++bits) {
 		;
 	}
-	return bits;
+	return clamp_t(typeof(bits), bits, LU_SITE_BITS_MIN, bits_max);
 }
 
 static unsigned lu_obj_hop_hash(struct cfs_hash *hs,
@@ -927,28 +974,17 @@ static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 /**
  * Initialize site \a s, with \a d as the top level device.
  */
-#define LU_SITE_BITS_MIN    12
-#define LU_SITE_BITS_MAX    19
-/**
- * total 256 buckets, we don't want too many buckets because:
- * - consume too much memory
- * - avoid unbalanced LRU list
- */
-#define LU_SITE_BKT_BITS    8
-
 int lu_site_init(struct lu_site *s, struct lu_device *top)
 {
 	struct lu_site_bkt_data *bkt;
 	struct cfs_hash_bd bd;
+	unsigned long bits;
+	unsigned long i;
 	char name[16];
-	int bits;
-	int i;
 
 	memset(s, 0, sizeof(*s));
-	bits = lu_htable_order();
 	snprintf(name, 16, "lu_site_%s", top->ld_type->ldt_name);
-	for (bits = min(max(LU_SITE_BITS_MIN, bits), LU_SITE_BITS_MAX);
-	     bits >= LU_SITE_BITS_MIN; bits--) {
+	for (bits = lu_htable_order(top); bits >= LU_SITE_BITS_MIN; bits--) {
 		s->ls_obj_hash = cfs_hash_create(name, bits, bits,
 						 bits - LU_SITE_BKT_BITS,
 						 sizeof(*bkt), 0, 0,
@@ -956,13 +992,14 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 						 CFS_HASH_SPIN_BKTLOCK |
 						 CFS_HASH_NO_ITEMREF |
 						 CFS_HASH_DEPTH |
-						 CFS_HASH_ASSERT_EMPTY);
+						 CFS_HASH_ASSERT_EMPTY |
+						 CFS_HASH_COUNTER);
 		if (s->ls_obj_hash)
 			break;
 	}
 
 	if (!s->ls_obj_hash) {
-		CERROR("failed to create lu_site hash with bits: %d\n", bits);
+		CERROR("failed to create lu_site hash with bits: %lu\n", bits);
 		return -ENOMEM;
 	}
 
-- 
1.7.1
