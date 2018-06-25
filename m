From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 17:42:50 -0400
Subject: [lustre-devel] [PATCH v2 1/7] lustre: libcfs: move tracefile
 locking from linux-tracefile.c to tracefile.c
In-Reply-To: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
References: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529962976-15048-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

There is no value in keeping it separate.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 22 -------------------
 drivers/staging/lustre/lnet/libcfs/tracefile.c     | 25 +++++++++++-----------
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |  5 -----
 3 files changed, 13 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index 3471384..9e72220 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -47,8 +47,6 @@
 
 char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 
-static DECLARE_RWSEM(cfs_tracefile_sem);
-
 int cfs_tracefile_init_arch(void)
 {
 	int i;
@@ -109,26 +107,6 @@ void cfs_tracefile_fini_arch(void)
 	}
 }
 
-void cfs_tracefile_read_lock(void)
-{
-	down_read(&cfs_tracefile_sem);
-}
-
-void cfs_tracefile_read_unlock(void)
-{
-	up_read(&cfs_tracefile_sem);
-}
-
-void cfs_tracefile_write_lock(void)
-{
-	down_write(&cfs_tracefile_sem);
-}
-
-void cfs_tracefile_write_unlock(void)
-{
-	up_write(&cfs_tracefile_sem);
-}
-
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 {
 	if (in_irq())
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 7ca562e..5f31933 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -59,6 +59,7 @@
 static int thread_running;
 
 static atomic_t cfs_tage_allocated = ATOMIC_INIT(0);
+static DECLARE_RWSEM(cfs_tracefile_sem);
 
 struct page_collection {
 	struct list_head	pc_pages;
@@ -711,7 +712,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	mm_segment_t __oldfs;
 	int rc;
 
-	cfs_tracefile_write_lock();
+	down_write(&cfs_tracefile_sem);
 
 	filp = filp_open(filename, O_CREAT | O_EXCL | O_WRONLY | O_LARGEFILE,
 			 0600);
@@ -759,7 +760,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 close:
 	filp_close(filp, NULL);
 out:
-	cfs_tracefile_write_unlock();
+	up_write(&cfs_tracefile_sem);
 	return rc;
 }
 
@@ -873,12 +874,12 @@ int cfs_trace_daemon_command(char *str)
 {
 	int rc = 0;
 
-	cfs_tracefile_write_lock();
+	down_write(&cfs_tracefile_sem);
 
 	if (!strcmp(str, "stop")) {
-		cfs_tracefile_write_unlock();
+		up_write(&cfs_tracefile_sem);
 		cfs_trace_stop_thread();
-		cfs_tracefile_write_lock();
+		down_write(&cfs_tracefile_sem);
 		memset(cfs_tracefile, 0, sizeof(cfs_tracefile));
 
 	} else if (!strncmp(str, "size=", 5)) {
@@ -905,7 +906,7 @@ int cfs_trace_daemon_command(char *str)
 		cfs_trace_start_thread();
 	}
 
-	cfs_tracefile_write_unlock();
+	up_write(&cfs_tracefile_sem);
 	return rc;
 }
 
@@ -950,12 +951,12 @@ int cfs_trace_set_debug_mb(int mb)
 	mb /= num_possible_cpus();
 	pages = mb << (20 - PAGE_SHIFT);
 
-	cfs_tracefile_write_lock();
+	down_write(&cfs_tracefile_sem);
 
 	cfs_tcd_for_each(tcd, i, j)
 		tcd->tcd_max_pages = (pages * tcd->tcd_pages_factor) / 100;
 
-	cfs_tracefile_write_unlock();
+	up_write(&cfs_tracefile_sem);
 
 	return 0;
 }
@@ -967,12 +968,12 @@ int cfs_trace_get_debug_mb(void)
 	struct cfs_trace_cpu_data *tcd;
 	int total_pages = 0;
 
-	cfs_tracefile_read_lock();
+	down_read(&cfs_tracefile_sem);
 
 	cfs_tcd_for_each(tcd, i, j)
 		total_pages += tcd->tcd_max_pages;
 
-	cfs_tracefile_read_unlock();
+	up_read(&cfs_tracefile_sem);
 
 	return (total_pages >> (20 - PAGE_SHIFT)) + 1;
 }
@@ -1002,7 +1003,7 @@ static int tracefiled(void *arg)
 			goto end_loop;
 
 		filp = NULL;
-		cfs_tracefile_read_lock();
+		down_read(&cfs_tracefile_sem);
 		if (cfs_tracefile[0]) {
 			filp = filp_open(cfs_tracefile,
 					 O_CREAT | O_RDWR | O_LARGEFILE,
@@ -1014,7 +1015,7 @@ static int tracefiled(void *arg)
 					rc);
 			}
 		}
-		cfs_tracefile_read_unlock();
+		up_read(&cfs_tracefile_sem);
 		if (!filp) {
 			put_pages_on_daemon_list(&pc);
 			__LASSERT(list_empty(&pc.pc_pages));
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 0608240..9f6b73d 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -65,11 +65,6 @@ enum cfs_trace_buf_type {
 int  cfs_tracefile_init_arch(void);
 void cfs_tracefile_fini_arch(void);
 
-void cfs_tracefile_read_lock(void);
-void cfs_tracefile_read_unlock(void);
-void cfs_tracefile_write_lock(void);
-void cfs_tracefile_write_unlock(void);
-
 int cfs_tracefile_dump_all_pages(char *filename);
 void cfs_trace_debug_print(void);
 void cfs_trace_flush_pages(void);
-- 
1.8.3.1
