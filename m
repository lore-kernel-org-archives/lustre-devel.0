From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:26 -0400
Subject: [lustre-devel] [PATCH v4 12/14] lustre: libcfs: renamed
 CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

The possible TCD types are 0, 1, 2.
So the MAX is 2.
The count of the number of types is 3.

CFS_TCD_TYPE_MAX is 3 - obviously wrong.

So rename it to CFS_TCD_TYPE_CNT.

Also there are 2 places where "3" is used rather
than the macro - fix them.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 282b7f6..bf6bcd5 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -54,12 +54,12 @@ enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
 	CFS_TCD_TYPE_SOFTIRQ,
 	CFS_TCD_TYPE_IRQ,
-	CFS_TCD_TYPE_MAX
+	CFS_TCD_TYPE_CNT
 };
 
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
 
-char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
+char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_CNT];
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
 long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
 static struct tracefiled_ctl trace_tctl;
@@ -127,7 +127,7 @@ static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 	__acquires(&tcd->tc_lock)
 {
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_CNT);
 	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
 		spin_lock_irqsave(&tcd->tcd_lock, tcd->tcd_lock_flags);
 	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
@@ -142,7 +142,7 @@ int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 	__releases(&tcd->tcd_lock)
 {
-	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_MAX);
+	__LASSERT(tcd->tcd_type < CFS_TCD_TYPE_CNT);
 	if (tcd->tcd_type == CFS_TCD_TYPE_IRQ)
 		spin_unlock_irqrestore(&tcd->tcd_lock, tcd->tcd_lock_flags);
 	else if (tcd->tcd_type == CFS_TCD_TYPE_SOFTIRQ)
@@ -1259,7 +1259,7 @@ void cfs_trace_stop_thread(void)
 }
 
 /* percents to share the total debug memory for each type */
-static unsigned int pages_factor[CFS_TCD_TYPE_MAX] = {
+static unsigned int pages_factor[CFS_TCD_TYPE_CNT] = {
 	80,  /* 80% pages for CFS_TCD_TYPE_PROC */
 	10,  /* 10% pages for CFS_TCD_TYPE_SOFTIRQ */
 	10   /* 10% pages for CFS_TCD_TYPE_IRQ */
@@ -1273,7 +1273,7 @@ int cfs_tracefile_init(int max_pages)
 
 	/* initialize trace_data */
 	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
-	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
+	for (i = 0; i < CFS_TCD_TYPE_CNT; i++) {
 		cfs_trace_data[i] =
 			kmalloc_array(num_possible_cpus(),
 				      sizeof(union cfs_trace_data_union),
@@ -1302,7 +1302,7 @@ int cfs_tracefile_init(int max_pages)
 	}
 
 	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
+		for (j = 0; j < CFS_TCD_TYPE_CNT; j++) {
 			cfs_trace_console_buffers[i][j] =
 				kmalloc(CFS_TRACE_CONSOLE_BUFFER_SIZE,
 					GFP_KERNEL);
@@ -1366,7 +1366,7 @@ static void cfs_trace_cleanup(void)
 	trace_cleanup_on_all_cpus();
 
 	for (i = 0; i < num_possible_cpus(); i++)
-		for (j = 0; j < 3; j++) {
+		for (j = 0; j < CFS_TCD_TYPE_CNT; j++) {
 			kfree(cfs_trace_console_buffers[i][j]);
 			cfs_trace_console_buffers[i][j] = NULL;
 		}
-- 
1.8.3.1
