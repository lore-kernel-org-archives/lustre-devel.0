From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 23/24] lustre: renamed CFS_TCD_TYPE_MAX to
 CFS_TCD_TYPE_CNT
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669090.10587.11055011083558241355.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The possible TCD types are 0, 1, 2.
So the MAX is 2.
The count of the number of types is 3.

CFS_TCD_TYPE_MAX is 3 - obviously wrong.

So rename it to CFS_TCD_TYPE_CNT.

Also there are 2 places where "3" is used rather
than the macro - fix them.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c |   15 +++++++--------
 drivers/staging/lustre/lnet/libcfs/tracefile.h |    4 ++--
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index fbd05905e1c4..cdef67391a72 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -119,7 +119,7 @@ static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 	__acquires(&tcd->tc_lock)
 {
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_CNT);
 	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
 		spin_lock_irqsave(&tcd->tcd_lock, tcd->tcd_lock_flags);
 	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
@@ -134,7 +134,7 @@ int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 	__releases(&tcd->tcd_lock)
 {
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_CNT);
 	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
 		spin_unlock_irqrestore(&tcd->tcd_lock, tcd->tcd_lock_flags);
 	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
@@ -169,14 +169,13 @@ static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
 }
 
 /* percents to share the total debug memory for each type */
-static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
+static unsigned int pages_factor[CFS_TCD_TYPE_CNT] = {
 	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
 	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
 	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
 };
 
-char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
-
+char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_CNT];
 
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 {
@@ -1294,7 +1293,7 @@ int cfs_tracefile_init(int max_pages)
 
 	/* initialize trace_data */
 	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
+	for (i = 0; i < CFS_TCD_TYPE_CNT; i++) {
 		cfs_trace_data[i] =
 			kmalloc_array(num_possible_cpus(),
 				      sizeof(union cfs_trace_data_union),
@@ -1323,7 +1322,7 @@ int cfs_tracefile_init(int max_pages)
 	}
 
 	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
+		for (j = 0; j < CFS_TCD_TYPE_CNT; j++) {
 			cfs_trace_console_buffers[i][j] =
 				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
 					GFP_KERNEL);
@@ -1377,7 +1376,7 @@ static void cfs_trace_cleanup(void)
 	trace_cleanup_on_all_cpus();
 
 	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
+		for (j = 0; j < CFS_TCD_TYPE_CNT; j++) {
 			kfree(cfs_trace_console_buffers[i][j]);
 			cfs_trace_console_buffers[i][j] = NULL;
 		}
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index f49a9ba00864..23faecf886c1 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -46,7 +46,7 @@ enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
 	CFS_TCD_TYPE_SOFTIRQ,
 	CFS_TCD_TYPE_IRQ,
-	CFS_TCD_TYPE_MAX
+	CFS_TCD_TYPE_CNT
 };
 
 #define TRACEFILE_NAME_SIZE 1024
@@ -200,7 +200,7 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 			  const char *buf, int len, const char *file,
 			  const char *fn);
 
-extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
+extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_CNT];
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
 
 static inline char *
