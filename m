From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:55 -0400
Subject: [lustre-devel] [PATCH 10/18] staging: lustre: llite: reset
	writeback index in ll_writepages
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Otherwise after one round the writeback index will become beyond
the file size and ->writepages() turns into an empty operation.

Also, a safety guard is added to limit the wait time for grant to
10 minutes(take recovery into consideration) at maximum in the
osc_enter_cache() function. Otherwise, EDQUOT will be returned to
the applications to start sync write.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3416
Reviewed-on: http://review.whamcloud.com/6554
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw.c      |    5 ++-
 drivers/staging/lustre/lustre/osc/osc_cache.c |   31 +++++++++++++++++--------
 2 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 7d5dd38..ab490a5 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -1110,8 +1110,9 @@ int ll_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0)) {
 		if (end == OBD_OBJECT_EOF)
-			end = i_size_read(inode);
-		mapping->writeback_index = (end >> PAGE_CACHE_SHIFT) + 1;
+			mapping->writeback_index = 0;
+		else
+			mapping->writeback_index = (end >> PAGE_CACHE_SHIFT) + 1;
 	}
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d01f2a2..f09b89d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1379,15 +1379,19 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	return 0;
 }
 
-#define OSC_DUMP_GRANT(cli, fmt, args...) do {				      \
+#define OSC_DUMP_GRANT(lvl, cli, fmt, args...) do {			\
 	struct client_obd *__tmp = (cli);				      \
-	CDEBUG(D_CACHE, "%s: { dirty: %ld/%ld dirty_pages: %d/%d "	      \
-	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d } " fmt,   \
+	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %d/%d "	      \
+	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d } "	\
+	       "lru {in list: %d, left: %d, waiters: %d }" fmt,		\
 	       __tmp->cl_import->imp_obd->obd_name,			      \
 	       __tmp->cl_dirty, __tmp->cl_dirty_max,			      \
 	       atomic_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
-	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight, ##args);      \
+	       __tmp->cl_reserved_grant, __tmp->cl_w_in_flight,		\
+	       atomic_read(&__tmp->cl_lru_in_list),			\
+	       atomic_read(&__tmp->cl_lru_busy),			\
+	       atomic_read(&__tmp->cl_lru_shrinkers), ##args);		\
 } while (0)
 
 /* caller must hold loi_list_lock */
@@ -1527,7 +1531,7 @@ static int osc_enter_cache_try(struct client_obd *cli,
 {
 	int rc;
 
-	OSC_DUMP_GRANT(cli, "need:%d.\n", bytes);
+	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d.\n", bytes);
 
 	rc = osc_reserve_grant(cli, bytes);
 	if (rc < 0)
@@ -1572,10 +1576,11 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	struct osc_object *osc = oap->oap_obj;
 	struct lov_oinfo *loi = osc->oo_oinfo;
 	struct osc_cache_waiter ocw;
-	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
+	struct l_wait_info lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(600), NULL,
+						  LWI_ON_SIGNAL_NOOP, NULL);
 	int rc = -EDQUOT;
 
-	OSC_DUMP_GRANT(cli, "need:%d.\n", bytes);
+	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d.\n", bytes);
 
 	spin_lock(&cli->cl_loi_list_lock);
 
@@ -1619,8 +1624,14 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 
 		spin_lock(&cli->cl_loi_list_lock);
 
-		/* l_wait_event is interrupted by signal */
+		/* l_wait_event is interrupted by signal, or timed out */
 		if (rc < 0) {
+			if (rc == -ETIMEDOUT) {
+				OSC_DUMP_GRANT(D_ERROR, cli,
+					       "try to reserve %d.\n", bytes);
+				osc_extent_tree_dump(D_ERROR, osc);
+				rc = -EDQUOT;
+			}
 			list_del_init(&ocw.ocw_entry);
 			goto out;
 		}
@@ -1637,7 +1648,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	}
 out:
 	spin_unlock(&cli->cl_loi_list_lock);
-	OSC_DUMP_GRANT(cli, "returned %d.\n", rc);
+	OSC_DUMP_GRANT(D_CACHE, cli, "returned %d.\n", rc);
 	return rc;
 }
 
@@ -3007,7 +3018,7 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 			result = rc;
 	}
 
-	OSC_IO_DEBUG(obj, "cache page out.\n");
+	OSC_IO_DEBUG(obj, "pageout [%lu, %lu], %d.\n", start, end, result);
 	return result;
 }
 
-- 
1.7.1
