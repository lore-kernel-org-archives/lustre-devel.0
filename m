From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 17:42:52 -0400
Subject: [lustre-devel] [PATCH v2 3/7] lustre: libcfs: move tcd locking
 across to tracefile.c
In-Reply-To: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
References: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529962976-15048-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

No need to have this in linux-tracefile.c

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 35 -------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 59 ++++++++++++++++++++++
 drivers/staging/lustre/lnet/libcfs/tracefile.h     | 28 ----------
 3 files changed, 59 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index 64a5bc1..3af7722 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -116,41 +116,6 @@ enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 	return CFS_TCD_TYPE_PROC;
 }
 
-/*
- * The walking argument indicates the locking comes from all tcd types
- * iterator and we must lock it and dissable local irqs to avoid deadlocks
- * with other interrupt locks that might be happening. See LU-1311
- * for details.
- */
-int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
-	__acquires(&tcd->tc_lock)
-{
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
-	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
-		spin_lock_irqsave(&tcd->tcd_lock, tcd->tcd_lock_flags);
-	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
-		spin_lock_bh(&tcd->tcd_lock);
-	else if (unlikely(walking))
-		spin_lock_irq(&tcd->tcd_lock);
-	else
-		spin_lock(&tcd->tcd_lock);
-	return 1;
-}
-
-void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
-	__releases(&tcd->tcd_lock)
-{
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
-	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
-		spin_unlock_irqrestore(&tcd->tcd_lock, tcd->tcd_lock_flags);
-	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
-		spin_unlock_bh(&tcd->tcd_lock);
-	else if (unlikely(walking))
-		spin_unlock_irq(&tcd->tcd_lock);
-	else
-		spin_unlock(&tcd->tcd_lock);
-}
-
 void
 cfs_set_ptldebug_header(struct ptldebug_header *header,
 			struct libcfs_debug_msg_data *msgdata,
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 72321ce..6d567a9 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -109,6 +109,65 @@ struct cfs_trace_page {
 static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 					 struct cfs_trace_cpu_data *tcd);
 
+/* trace file lock routines */
+/*
+ * The walking argument indicates the locking comes from all tcd types
+ * iterator and we must lock it and dissable local irqs to avoid deadlocks
+ * with other interrupt locks that might be happening. See LU-1311
+ * for details.
+ */
+int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
+	__acquires(&tcd->tc_lock)
+{
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
+		spin_lock_irqsave(&tcd->tcd_lock, tcd->tcd_lock_flags);
+	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
+		spin_lock_bh(&tcd->tcd_lock);
+	else if (unlikely(walking))
+		spin_lock_irq(&tcd->tcd_lock);
+	else
+		spin_lock(&tcd->tcd_lock);
+	return 1;
+}
+
+void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
+	__releases(&tcd->tcd_lock)
+{
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
+		spin_unlock_irqrestore(&tcd->tcd_lock, tcd->tcd_lock_flags);
+	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
+		spin_unlock_bh(&tcd->tcd_lock);
+	else if (unlikely(walking))
+		spin_unlock_irq(&tcd->tcd_lock);
+	else
+		spin_unlock(&tcd->tcd_lock);
+}
+
+#define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
+	for (i = 0; cfs_trace_data[i] &&				\
+	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
+	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
+
+static inline struct cfs_trace_cpu_data *
+cfs_trace_get_tcd(void)
+{
+	struct cfs_trace_cpu_data *tcd =
+		&(*cfs_trace_data[cfs_trace_buf_idx_get()])[get_cpu()].tcd;
+
+	cfs_trace_lock_tcd(tcd, 0);
+
+	return tcd;
+}
+
+static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
+{
+	cfs_trace_unlock_tcd(tcd, 0);
+
+	put_cpu();
+}
+
 static inline struct cfs_trace_page *
 cfs_tage_from_list(struct list_head *list)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 9f6b73d..f49a9ba 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -49,8 +49,6 @@ enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_MAX
 };
 
-/* trace file lock routines */
-
 #define TRACEFILE_NAME_SIZE 1024
 extern char cfs_tracefile[TRACEFILE_NAME_SIZE];
 extern long long cfs_tracefile_size;
@@ -195,11 +193,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		     j < num_possible_cpus();				 \
 		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
 
-#define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
-	for (i = 0; cfs_trace_data[i] &&				\
-	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
-	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
-
 void cfs_set_ptldebug_header(struct ptldebug_header *header,
 			     struct libcfs_debug_msg_data *m,
 			     unsigned long stack);
@@ -207,9 +200,6 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 			  const char *buf, int len, const char *file,
 			  const char *fn);
 
-int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking);
-void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking);
-
 extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
 
@@ -222,24 +212,6 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 	return cfs_trace_console_buffers[i][j];
 }
 
-static inline struct cfs_trace_cpu_data *
-cfs_trace_get_tcd(void)
-{
-	struct cfs_trace_cpu_data *tcd =
-		&(*cfs_trace_data[cfs_trace_buf_idx_get()])[get_cpu()].tcd;
-
-	cfs_trace_lock_tcd(tcd, 0);
-
-	return tcd;
-}
-
-static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
-{
-	cfs_trace_unlock_tcd(tcd, 0);
-
-	put_cpu();
-}
-
 int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
 			   struct list_head *stock);
 
-- 
1.8.3.1
