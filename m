From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 14/21] lustre: make ccc_users in
 cl_client_cache a refcount_t
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781324.10620.6961645123977299300.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As this is used as a refcount, it should be declared
as one.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h |    2 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c  |    6 +++---
 drivers/staging/lustre/lustre/osc/osc_page.c      |    4 ++--
 drivers/staging/lustre/lustre/osc/osc_request.c   |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index c2273c3100e8..05be85306663 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2181,7 +2181,7 @@ struct cl_client_cache {
 	 * # of client cache refcount
 	 * # of users (OSCs) + 2 (held by llite and lov)
 	 */
-	atomic_t		ccc_users;
+	refcount_t		ccc_users;
 	/**
 	 * # of threads are doing shrinking
 	 */
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 001bed90f4da..8215296dc15d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -467,7 +467,7 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 		   "used_mb: %ld\n"
 		   "unused_mb: %ld\n"
 		   "reclaim_count: %u\n",
-		   atomic_read(&cache->ccc_users),
+		   refcount_read(&cache->ccc_users),
 		   max_cached_mb,
 		   max_cached_mb - unused_mb,
 		   unused_mb,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index f0ece7e9a4ac..7dcd3aff229f 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -960,7 +960,7 @@ struct cl_client_cache *cl_cache_init(unsigned long lru_page_max)
 		return NULL;
 
 	/* Initialize cache data */
-	atomic_set(&cache->ccc_users, 1);
+	refcount_set(&cache->ccc_users, 1);
 	cache->ccc_lru_max = lru_page_max;
 	atomic_long_set(&cache->ccc_lru_left, lru_page_max);
 	spin_lock_init(&cache->ccc_lru_lock);
@@ -978,7 +978,7 @@ EXPORT_SYMBOL(cl_cache_init);
  */
 void cl_cache_incref(struct cl_client_cache *cache)
 {
-	atomic_inc(&cache->ccc_users);
+	refcount_inc(&cache->ccc_users);
 }
 EXPORT_SYMBOL(cl_cache_incref);
 
@@ -989,7 +989,7 @@ EXPORT_SYMBOL(cl_cache_incref);
  */
 void cl_cache_decref(struct cl_client_cache *cache)
 {
-	if (atomic_dec_and_test(&cache->ccc_users))
+	if (refcount_dec_and_test(&cache->ccc_users))
 		kfree(cache);
 }
 EXPORT_SYMBOL(cl_cache_decref);
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 135bfe5e1b37..ce911b82512d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -346,7 +346,7 @@ static int osc_cache_too_much(struct client_obd *cli)
 	long pages = atomic_long_read(&cli->cl_lru_in_list);
 	unsigned long budget;
 
-	budget = cache->ccc_lru_max / (atomic_read(&cache->ccc_users) - 2);
+	budget = cache->ccc_lru_max / (refcount_read(&cache->ccc_users) - 2);
 
 	/* if it's going to run out LRU slots, we should free some, but not
 	 * too much to maintain fairness among OSCs.
@@ -707,7 +707,7 @@ static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 	cache->ccc_lru_shrinkers++;
 	list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
 
-	max_scans = atomic_read(&cache->ccc_users) - 2;
+	max_scans = refcount_read(&cache->ccc_users) - 2;
 	while (--max_scans > 0 &&
 	       (cli = list_first_entry_or_null(&cache->ccc_lru,
 					       struct client_obd,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 9e72fa8f68b3..0dfc506f6d01 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2959,7 +2959,7 @@ static int osc_cleanup(struct obd_device *obd)
 
 	/* lru cleanup */
 	if (cli->cl_cache) {
-		LASSERT(atomic_read(&cli->cl_cache->ccc_users) > 0);
+		LASSERT(refcount_read(&cli->cl_cache->ccc_users) > 0);
 		spin_lock(&cli->cl_cache->ccc_lru_lock);
 		list_del_init(&cli->cl_lru_osc);
 		spin_unlock(&cli->cl_cache->ccc_lru_lock);
