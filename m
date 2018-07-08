From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:25 -0400
Subject: [lustre-devel] [PATCH v4 11/14] lustre: libcfs: fold
 cfs_tracefile_*_arch into their only callers.
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

There is no need to separate "arch" init/fini from
the rest, so fold it all in.
This requires some slightly subtle changes to clean-up
to make sure we don't walk lists before they are
initialized.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c | 147 +++++++++++--------------
 drivers/staging/lustre/lnet/libcfs/tracefile.h |   3 -
 2 files changed, 63 insertions(+), 87 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index a3fde61..282b7f6 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -200,82 +200,6 @@ static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
 	put_cpu();
 }
 
-/* percents to share the total debug memory for each type */
-static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
-	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
-	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
-	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
-};
-
-int cfs_tracefile_init_arch(void)
-{
-	struct cfs_trace_cpu_data *tcd;
-	int i;
-	int j;
-
-	/* initialize trace_data */
-	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
-		cfs_trace_data[i] =
-			kmalloc_array(num_possible_cpus(),
-				      sizeof(union cfs_trace_data_union),
-				      GFP_KERNEL);
-		if (!cfs_trace_data[i])
-			goto out_trace_data;
-	}
-
-	/* arch related info initialized */
-	cfs_tcd_for_each(tcd, i, j) {
-		spin_lock_init(&tcd->tcd_lock);
-		tcd->tcd_pages_factor = pages_factor[i];
-		tcd->tcd_type = i;
-		tcd->tcd_cpu = j;
-	}
-
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			cfs_trace_console_buffers[i][j] =
-				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
-					GFP_KERNEL);
-
-			if (!cfs_trace_console_buffers[i][j])
-				goto out_buffers;
-		}
-
-	return 0;
-
-out_buffers:
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
-out_trace_data:
-	for (i = 0; cfs_trace_data[i]; i++) {
-		kfree(cfs_trace_data[i]);
-		cfs_trace_data[i] = NULL;
-	}
-	pr_err("lnet: Not enough memory\n");
-	return -ENOMEM;
-}
-
-void cfs_tracefile_fini_arch(void)
-{
-	int i;
-	int j;
-
-	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
-			kfree(cfs_trace_console_buffers[i][j]);
-			cfs_trace_console_buffers[i][j] = NULL;
-		}
-
-	for (i = 0; cfs_trace_data[i]; i++) {
-		kfree(cfs_trace_data[i]);
-		cfs_trace_data[i] = NULL;
-	}
-}
-
 static inline struct cfs_trace_page *
 cfs_tage_from_list(struct list_head *list)
 {
@@ -1334,21 +1258,38 @@ void cfs_trace_stop_thread(void)
 	mutex_unlock(&cfs_trace_thread_mutex);
 }
 
+/* percents to share the total debug memory for each type */
+static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
+	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
+	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
+	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
+};
+
 int cfs_tracefile_init(int max_pages)
 {
 	struct cfs_trace_cpu_data *tcd;
 	int i;
 	int j;
-	int rc;
-	int factor;
 
-	rc = cfs_tracefile_init_arch();
-	if (rc)
-		return rc;
+	/* initialize trace_data */
+	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
+	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
+		cfs_trace_data[i] =
+			kmalloc_array(num_possible_cpus(),
+				      sizeof(union cfs_trace_data_union),
+				      GFP_KERNEL);
+		if (!cfs_trace_data[i])
+			goto out_trace_data;
+	}
 
+	/* arch related info initialized */
 	cfs_tcd_for_each(tcd, i, j) {
-		/* tcd_pages_factor is initialized int tracefile_init_arch. */
-		factor = tcd->tcd_pages_factor;
+		int factor = pages_factor[i];
+
+		spin_lock_init(&tcd->tcd_lock);
+		tcd->tcd_pages_factor = factor;
+		tcd->tcd_type = i;
+		tcd->tcd_cpu = j;
 		INIT_LIST_HEAD(&tcd->tcd_pages);
 		INIT_LIST_HEAD(&tcd->tcd_stock_pages);
 		INIT_LIST_HEAD(&tcd->tcd_daemon_pages);
@@ -1360,7 +1301,31 @@ int cfs_tracefile_init(int max_pages)
 		tcd->tcd_shutting_down = 0;
 	}
 
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			cfs_trace_console_buffers[i][j] =
+				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
+					GFP_KERNEL);
+
+			if (!cfs_trace_console_buffers[i][j])
+				goto out_buffers;
+		}
+
 	return 0;
+
+out_buffers:
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			kfree(cfs_trace_console_buffers[i][j]);
+			cfs_trace_console_buffers[i][j] = NULL;
+		}
+out_trace_data:
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
+	pr_err("lnet: Not enough memory\n");
+	return -ENOMEM;
 }
 
 static void trace_cleanup_on_all_cpus(void)
@@ -1372,6 +1337,9 @@ static void trace_cleanup_on_all_cpus(void)
 
 	for_each_possible_cpu(cpu) {
 		cfs_tcd_for_each_type_lock(tcd, i, cpu) {
+			if (!tcd->tcd_pages_factor)
+				/* Not initialised */
+				continue;
 			tcd->tcd_shutting_down = 1;
 
 			list_for_each_entry_safe(tage, tmp, &tcd->tcd_pages,
@@ -1390,12 +1358,23 @@ static void trace_cleanup_on_all_cpus(void)
 static void cfs_trace_cleanup(void)
 {
 	struct page_collection pc;
+	int i;
+	int j;
 
 	INIT_LIST_HEAD(&pc.pc_pages);
 
 	trace_cleanup_on_all_cpus();
 
-	cfs_tracefile_fini_arch();
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			kfree(cfs_trace_console_buffers[i][j]);
+			cfs_trace_console_buffers[i][j] = NULL;
+		}
+
+	for (i = 0; cfs_trace_data[i]; i++) {
+		kfree(cfs_trace_data[i]);
+		cfs_trace_data[i] = NULL;
+	}
 }
 
 void cfs_tracefile_exit(void)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 3e7b6fa..dc782a6 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -53,9 +53,6 @@
 
 void libcfs_run_debug_log_upcall(char *file);
 
-int  cfs_tracefile_init_arch(void);
-void cfs_tracefile_fini_arch(void);
-
 int cfs_tracefile_dump_all_pages(char *filename);
 void cfs_trace_debug_print(void);
 void cfs_trace_flush_pages(void);
-- 
1.8.3.1
