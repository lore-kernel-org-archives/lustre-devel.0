From: James Simmons <jsimmons@infradead.org>
Date: Thu,  1 Dec 2016 17:35:30 -0500
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: osc: add and fixup
	comments for LRU handling
In-Reply-To: <1480631732-6880-1-git-send-email-jsimmons@infradead.org>
References: <1480631732-6880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480631732-6880-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Add new information about the fields in struct client_obd.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5108
Reviewed-on: http://review.whamcloud.com/10458
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h  |   27 ++++++++++++++++++++++---
 drivers/staging/lustre/lustre/osc/osc_page.c |   17 +++++++++++----
 2 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d4d2ffa..6d6e479 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -247,15 +247,34 @@ struct client_obd {
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
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 7a1f102..2cdc30a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -343,16 +343,17 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
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
 static const int lru_shrink_min = 2 << (20 - PAGE_SHIFT);  /* 2M */
-/* free this number@most otherwise it will take too long time to finish. */
 static const int lru_shrink_max = 8 << (20 - PAGE_SHIFT); /* 8M */
 
-/* Check if we can free LRU slots from this OSC. If there exists LRU waiters,
+/**
+ * Check if we can free LRU slots from this OSC. If there exists LRU waiters,
  * we should free slots aggressively. In this way, slots are freed in a steady
  * step to maintain fairness among OSCs.
  *
@@ -643,6 +644,12 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	return count > 0 ? count : rc;
 }
 
+/**
+ * Reclaim LRU pages by an IO thread. The caller wants to reclaim at least
+ * \@npages of LRU slots. For performance consideration, it's better to drop
+ * LRU pages in batch. Therefore, the actual number is adjusted at least
+ * max_pages_per_rpc.
+ */
 long osc_lru_reclaim(struct client_obd *cli)
 {
 	struct lu_env *env;
-- 
1.7.1
