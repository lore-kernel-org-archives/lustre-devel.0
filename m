From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 22/24] lustre: fold cfs_tracefile_*_arch into
 their only callers.
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669087.10587.4562289436203420686.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There is no need to separate "arch" init/fini from
the rest, so fold it all in.
This requires some slightly subtle changes to clean-up
to make sure we don't walk lists before they are
initialized.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c |  116 ++++++++++--------------
 1 file changed, 49 insertions(+), 67 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 617edc291035..fbd05905e1c4 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -177,65 +177,6 @@ static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
 
 char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 
-int cfs_tracefile_init_arch(void)
-{
-	int i;
-	int j;
-	struct cfs_trace_cpu_data *tcd;
-
-	/* initialize trace_data */
-	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
-		cfs_trace_data[i] =
-			kmalloc_array(num_possible_cpus(),
-				      sizeof(union cfs_trace_data_union),
-				      GFP_KERNEL);
-		if (!cfs_trace_data[i])
-			goto out;
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
-				goto out;
-		}
-
-	return 0;
-
-out:
-	cfs_tracefile_fini_arch();
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
 
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 {
@@ -1343,21 +1284,33 @@ void cfs_trace_stop_thread(void)
 	mutex_unlock(&cfs_trace_thread_mutex);
 }
 
+static void cfs_trace_cleanup(void);
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
+			goto out;
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
@@ -1369,7 +1322,21 @@ int cfs_tracefile_init(int max_pages)
 		tcd->tcd_shutting_down = 0;
 	}
 
+	for (i = 0; i < num_possible_cpus(); i++)
+		for (j = 0; j < 3; j++) {
+			cfs_trace_console_buffers[i][j] =
+				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
+					GFP_KERNEL);
+
+			if (!cfs_trace_console_buffers[i][j])
+				goto out;
+		}
+
 	return 0;
+out:
+	cfs_trace_cleanup();
+	pr_err("lnet: Not enough memory\n");
+	return -ENOMEM;
 }
 
 static void trace_cleanup_on_all_cpus(void)
@@ -1381,6 +1348,9 @@ static void trace_cleanup_on_all_cpus(void)
 
 	for_each_possible_cpu(cpu) {
 		cfs_tcd_for_each_type_lock(tcd, i, cpu) {
+			if (!tcd->tcd_pages_factor)
+				/* Not initialised */
+				continue;
 			tcd->tcd_shutting_down = 1;
 
 			list_for_each_entry_safe(tage, tmp, &tcd->tcd_pages,
@@ -1399,12 +1369,24 @@ static void trace_cleanup_on_all_cpus(void)
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
+
 }
 
 void cfs_tracefile_exit(void)
