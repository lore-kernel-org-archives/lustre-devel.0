From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Jun 2018 15:38:38 -0400
Subject: [lustre-devel] [PATCH v3 09/13] lustre: libcfs: cleanup tracefile.h
In-Reply-To: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
References: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530128322-32535-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With many things moved into tracefile.c we can cleanup a lot of
things in tracefile.h. Move some items that are only used in
tracefile.c from tracefile.h into tracefile.c. In tracefile.h
we have the ifdef LUSTRE_TRACEFILE_PRIVATE which has several
duplicate defines. We can remove those duplicates.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/tracefile.c | 18 +++++++++++--
 drivers/staging/lustre/lnet/libcfs/tracefile.h | 37 --------------------------
 2 files changed, 16 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 914cd94..5095e66 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -37,8 +37,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#define LUSTRE_TRACEFILE_PRIVATE
-#define pr_fmt(fmt) "Lustre: " fmt
 
 #include <linux/ratelimit.h>
 #include <linux/highmem.h>
@@ -49,8 +47,16 @@
 #include <linux/uaccess.h>
 #include "tracefile.h"
 
+#define CFS_TRACE_CONSOLE_BUFFER_SIZE	1024
 #define TCD_MAX_TYPES			8
 
+enum cfs_trace_buf_type {
+	CFS_TCD_TYPE_PROC = 0,
+	CFS_TCD_TYPE_SOFTIRQ,
+	CFS_TCD_TYPE_IRQ,
+	CFS_TCD_TYPE_MAX
+};
+
 union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
 
 char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
@@ -168,6 +174,14 @@ enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 	return CFS_TCD_TYPE_PROC;
 }
 
+static inline char *cfs_trace_get_console_buffer(void)
+{
+	unsigned int i = get_cpu();
+	unsigned int j = cfs_trace_buf_idx_get();
+
+	return cfs_trace_console_buffers[i][j];
+}
+
 static inline struct cfs_trace_cpu_data *
 cfs_trace_get_tcd(void)
 {
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index 072c720..3e7b6fa 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -42,13 +42,6 @@
 #include <linux/smp.h>
 #include <linux/libcfs/libcfs.h>
 
-enum cfs_trace_buf_type {
-	CFS_TCD_TYPE_PROC = 0,
-	CFS_TCD_TYPE_SOFTIRQ,
-	CFS_TCD_TYPE_IRQ,
-	CFS_TCD_TYPE_MAX
-};
-
 #define TRACEFILE_NAME_SIZE 1024
 extern char cfs_tracefile[TRACEFILE_NAME_SIZE];
 extern long long cfs_tracefile_size;
@@ -91,22 +84,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 #define TCD_STOCK_PAGES (TCD_MAX_PAGES)
 #define CFS_TRACEFILE_SIZE (500 << 20)
 
-#ifdef LUSTRE_TRACEFILE_PRIVATE
-
-/*
- * Private declare for tracefile
- */
-#define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
-#define TCD_STOCK_PAGES (TCD_MAX_PAGES)
-
-#define CFS_TRACEFILE_SIZE (500 << 20)
-
-/*
- * Size of a buffer for sprinting console messages if we can't get a page
- * from system
- */
-#define CFS_TRACE_CONSOLE_BUFFER_SIZE   1024
-
 union cfs_trace_data_union {
 	struct cfs_trace_cpu_data {
 		/*
@@ -183,18 +160,6 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 	char __pad[L1_CACHE_ALIGN(sizeof(struct cfs_trace_cpu_data))];
 };
 
-extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
-enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
-
-static inline char *
-cfs_trace_get_console_buffer(void)
-{
-	unsigned int i = get_cpu();
-	unsigned int j = cfs_trace_buf_idx_get();
-
-	return cfs_trace_console_buffers[i][j];
-}
-
 void cfs_trace_assertion_failed(const char *str,
 				struct libcfs_debug_msg_data *m);
 
@@ -216,6 +181,4 @@ void cfs_trace_assertion_failed(const char *str,
 	__LASSERT(page_count(tage->page) > 0);		      \
 } while (0)
 
-#endif	/* LUSTRE_TRACEFILE_PRIVATE */
-
 #endif /* __LIBCFS_TRACEFILE_H__ */
-- 
1.8.3.1
