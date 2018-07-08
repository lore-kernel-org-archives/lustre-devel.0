From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:22 -0400
Subject: [lustre-devel] [PATCH v4 08/14] lustre: libcfs: remove
 cfs_trace_refill_stack()
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The function cfs_trace_refill_stack() is not used anywhere so
remove it.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c | 21 ---------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.h |  3 ---
 2 files changed, 24 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 066476d..ec90b36 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -302,27 +302,6 @@ static void cfs_tage_to_tail(struct cfs_trace_page *tage,
 	list_move_tail(&tage->linkage, queue);
 }
 
-int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
-			   struct list_head *stock)
-{
-	int i;
-
-	/*
-	 * XXX nikita: do NOT call portals_debug_msg() (CDEBUG/ENTRY/EXIT)
-	 * from here: this will lead to infinite recursion.
-	 */
-
-	for (i = 0; i + tcd->tcd_cur_stock_pages < TCD_STOCK_PAGES ; ++i) {
-		struct cfs_trace_page *tage;
-
-		tage = cfs_tage_alloc(gfp);
-		if (!tage)
-			break;
-		list_add_tail(&tage->linkage, stock);
-	}
-	return i;
-}
-
 /* return a page that has 'len' bytes left at the end */
 static struct cfs_trace_page *
 cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 399e0bf..b9e4a8e 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -204,9 +204,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 	return cfs_trace_console_buffers[i][j];
 }
 
-int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
-			   struct list_head *stock);
-
 void cfs_trace_assertion_failed(const char *str,
 				struct libcfs_debug_msg_data *m);
 
-- 
1.8.3.1
