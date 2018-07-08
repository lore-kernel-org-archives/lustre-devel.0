From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:23 -0400
Subject: [lustre-devel] [PATCH v4 09/14] lustre: libcfs: move cfs_trace_data
 data to tracefile.c
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The macro cfs_tcd_for_each() is only used in tracefile.c so move
it from the header tracefile.h along with related material in
the header file.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c | 12 ++++++++++--
 drivers/staging/lustre/lnet/libcfs/tracefile.h |  9 ---------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index ec90b36..d80685c 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -49,7 +49,8 @@
 #include <linux/uaccess.h>
 #include "tracefile.h"
 
-/* XXX move things up to the top, comment */
+#define TCD_MAX_TYPES			8
+
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
 
 char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
@@ -146,7 +147,14 @@ void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 		spin_unlock(&tcd->tcd_lock);
 }
 
-#define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
+#define cfs_tcd_for_each(tcd, i, j)					\
+	for (i = 0; cfs_trace_data[i]; i++)				\
+		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
+		     j < num_possible_cpus();				\
+		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
+
+
+#define cfs_tcd_for_each_type_lock(tcd, i, cpu)				\
 	for (i = 0; cfs_trace_data[i] &&				\
 	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
 	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index b9e4a8e..072c720 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -183,15 +183,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 	char __pad[L1_CACHE_ALIGN(sizeof(struct cfs_trace_cpu_data))];
 };
 
-#define TCD_MAX_TYPES      8
-extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
-
-#define cfs_tcd_for_each(tcd, i, j)				       \
-	for (i = 0; cfs_trace_data[i]; i++)				\
-		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
-		     j < num_possible_cpus();				 \
-		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
-
 extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
 
-- 
1.8.3.1
