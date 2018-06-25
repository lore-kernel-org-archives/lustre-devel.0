From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 Jun 2018 17:42:56 -0400
Subject: [lustre-devel] [PATCH v2 7/7] lustre: libcfs: discard TCD_MAX_TYPES
In-Reply-To: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
References: <1529962976-15048-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529962976-15048-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

As well as CFS_TCD_TYPE_CNT we have TCD_MAX_TYPES which has a larger
value but a similar meaning.  Discard it and just use
CFS_TCD_TYPE_CNT.

Two places relied on the fact that TCD_MAX_TYPES was larger and so
there would be NULLs at the end of the array.  Change
them to check the array size properly.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index e9d8b22..47998e8 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -48,7 +48,6 @@
 #include "tracefile.h"
 
 #define CFS_TRACE_CONSOLE_BUFFER_SIZE	1024
-#define TCD_MAX_TYPES			8
 
 enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
@@ -57,7 +56,7 @@ enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_CNT
 };
 
-union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
+union cfs_trace_data_union (*cfs_trace_data[CFS_TCD_TYPE_CNT])[NR_CPUS] __cacheline_aligned;
 
 char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_CNT];
 char cfs_tracefile[TRACEFILE_NAME_SIZE];
@@ -154,14 +153,14 @@ void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 }
 
 #define cfs_tcd_for_each(tcd, i, j)					\
-	for (i = 0; cfs_trace_data[i]; i++)				\
+	for (i = 0; i < CFS_TCD_TYPE_CNT && cfs_trace_data[i]; i++)	\
 		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
 		     j < num_possible_cpus();				\
 		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
 
 
 #define cfs_tcd_for_each_type_lock(tcd, i, cpu)				\
-	for (i = 0; cfs_trace_data[i] &&				\
+	for (i = 0;  i < CFS_TCD_TYPE_CNT && cfs_trace_data[i] &&	\
 	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
 	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
 
@@ -1360,7 +1359,7 @@ static void cfs_trace_cleanup(void)
 			cfs_trace_console_buffers[i][j] = NULL;
 		}
 
-	for (i = 0; cfs_trace_data[i]; i++) {
+	for (i = 0; i < CFS_TCD_TYPE_CNT && cfs_trace_data[i]; i++) {
 		kfree(cfs_trace_data[i]);
 		cfs_trace_data[i] = NULL;
 	}
-- 
1.8.3.1
