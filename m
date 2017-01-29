From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:45 -0500
Subject: [lustre-devel] [PATCH 17/60] staging: lustre: obdclass: do not call
	lu_site_purge() for single object exceed
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, James Simmons <jsimmons@infradead.org>

From: Alex Zhuravlev <alexey.zhuravlev@intel.com>

First of all, this is expensive procedure including a global
mutex and per-bucket spinlocks. also, all the threads observed
exceed will be calling lu_site_purge() and essentially serialized
on that. instead we can let other threads to skip the whole
procedure.

Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7896
Reviewed-on: http://review.whamcloud.com/19082
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |  8 ++++++-
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 26 +++++++++++++++-------
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index f442a96..c7dee1d 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -712,8 +712,14 @@ static inline int lu_object_is_dying(const struct lu_object_header *h)
 
 void lu_object_put(const struct lu_env *env, struct lu_object *o);
 void lu_object_unhash(const struct lu_env *env, struct lu_object *o);
+int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s, int nr,
+			  bool canblock);
 
-int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr);
+static inline int lu_site_purge(const struct lu_env *env, struct lu_site *s,
+				int nr)
+{
+	return lu_site_purge_objects(env, s, nr, true);
+}
 
 void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
 		   lu_printer_t printer);
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 1805861..abcf951 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -60,7 +60,7 @@ enum {
 	LU_CACHE_PERCENT_DEFAULT = 20
 };
 
-#define LU_CACHE_NR_MAX_ADJUST		128
+#define LU_CACHE_NR_MAX_ADJUST		512
 #define LU_CACHE_NR_UNLIMITED		-1
 #define LU_CACHE_NR_DEFAULT		LU_CACHE_NR_UNLIMITED
 #define LU_CACHE_NR_LDISKFS_LIMIT	LU_CACHE_NR_UNLIMITED
@@ -329,8 +329,11 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 
 /**
  * Free \a nr objects from the cold end of the site LRU list.
+ * if canblock is false, then don't block awaiting for another
+ * instance of lu_site_purge() to complete
  */
-int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
+int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
+			  int nr, bool canblock)
 {
 	struct lu_object_header *h;
 	struct lu_object_header *temp;
@@ -360,7 +363,11 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	 * It doesn't make any sense to make purge threads parallel, that can
 	 * only bring troubles to us. See LU-5331.
 	 */
-	mutex_lock(&s->ls_purge_mutex);
+	if (canblock)
+		mutex_lock(&s->ls_purge_mutex);
+	else if (!mutex_trylock(&s->ls_purge_mutex))
+		goto out;
+
 	did_sth = 0;
 	cfs_hash_for_each_bucket(s->ls_obj_hash, &bd, i) {
 		if (i < start)
@@ -414,10 +421,10 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	}
 	/* race on s->ls_purge_start, but nobody cares */
 	s->ls_purge_start = i % CFS_HASH_NBKT(s->ls_obj_hash);
-
+out:
 	return nr;
 }
-EXPORT_SYMBOL(lu_site_purge);
+EXPORT_SYMBOL(lu_site_purge_objects);
 
 /*
  * Object printing.
@@ -625,9 +632,12 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
 
 	size = cfs_hash_size_get(dev->ld_site->ls_obj_hash);
 	nr = (__u64)lu_cache_nr;
-	if (size > nr)
-		lu_site_purge(env, dev->ld_site,
-			      min_t(__u64, size - nr, LU_CACHE_NR_MAX_ADJUST));
+	if (size <= nr)
+		return;
+
+	lu_site_purge_objects(env, dev->ld_site,
+			      min_t(__u64, size - nr, LU_CACHE_NR_MAX_ADJUST),
+			      false);
 }
 
 static struct lu_object *lu_object_new(const struct lu_env *env,
-- 
1.8.3.1
